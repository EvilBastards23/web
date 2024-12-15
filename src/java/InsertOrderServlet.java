import java.io.IOException;
import java.net.URLEncoder;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/InsertOrderServlet")
public class InsertOrderServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(InsertOrderServlet.class.getName());

    // Database connection parameters
    private static final String DB_URL = "jdbc:mysql://localhost:3306/e_commerce?maxAllowedPacket=104857600";
    private static final String DB_USER = "end_user";
    private static final String DB_PASSWORD = "Irmuun2018";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        Connection conn = null;
        
        try {
            // Check user session
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("user_id") == null) {
                response.sendRedirect("login.jsp");
                return;
            }
            
            // Safely extract user ID
            int userId = extractUserId(session);
            
            // Establish database connection
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            conn.setAutoCommit(false);  // Start transaction
            
            // Validate user and cart
            validateUserCart(conn, userId);
            
            // Calculate total price
            long totalPrice = calculateTotalPrice(conn, userId);
            
            // Insert order
            int orderId = insertOrder(conn, userId, totalPrice);
            
            // Insert order items
            insertOrderItems(conn, orderId, userId);
            
            // Clear user's cart
            clearUserCart(conn, userId);
            
            // Commit transaction
            conn.commit();
            
            // Redirect to order confirmation
            response.sendRedirect("payment.jsp?order_id=" + orderId);
        
        } catch (SQLException ex) {
            // Log full error details
            LOGGER.log(Level.SEVERE, "Error processing order", ex);
            
            // Rollback transaction if possible
            rollbackTransaction(conn);
            
            // Encode error message to handle special characters
            String encodedMessage = URLEncoder.encode(
                "Order processing failed: " + getDetailedErrorMessage(ex), 
                "UTF-8"
            );
            
            // Redirect to error page with detailed error information
            response.sendRedirect(
                "error.jsp?message=" + encodedMessage + 
                "&errorCode=" + ex.getErrorCode() + 
                "&sqlState=" + ex.getSQLState()
            );
        
        } catch (Exception ex) {
            // Handle other unexpected exceptions
            LOGGER.log(Level.SEVERE, "Unexpected error in order processing", ex);
            
            String encodedMessage = URLEncoder.encode(
                "Unexpected error: " + ex.getMessage(), 
                "UTF-8"
            );
            
            response.sendRedirect(
                "error.jsp?message=" + encodedMessage
            );
        
        } finally {
            // Close connection
            closeConnection(conn);
        }
    }

    // Safely extract user ID with type checking
    private int extractUserId(HttpSession session) throws ServletException {
        Object userIdObj = session.getAttribute("user_id");
        
        if (userIdObj instanceof Integer) {
            return (Integer) userIdObj;
        } else if (userIdObj instanceof String) {
            try {
                return Integer.parseInt((String) userIdObj);
            } catch (NumberFormatException e) {
                throw new ServletException("Invalid user ID format", e);
            }
        } else {
            throw new ServletException("Unexpected user ID type: " + 
                (userIdObj != null ? userIdObj.getClass() : "null"));
        }
    }

    // Validate that user has items in cart
    private void validateUserCart(Connection conn, int userId) throws SQLException {
        String validateCartSQL = "SELECT COUNT(*) AS cart_count " +
                                 "FROM cart_item ci " +
                                 "JOIN cart c ON ci.cart_id = c.cart_id " +
                                 "WHERE c.user_id = ?";
        
        try (PreparedStatement pstmt = conn.prepareStatement(validateCartSQL)) {
            pstmt.setInt(1, userId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    int cartCount = rs.getInt("cart_count");
                    if (cartCount == 0) {
                        throw new SQLException("User cart is empty");
                    }
                } else {
                    throw new SQLException("Unable to validate cart");
                }
            }
        }
    }

    // Method to insert order and return generated order ID
    private int insertOrder(Connection conn, int userId, long totalPrice) throws SQLException {
        String insertOrderSQL = "INSERT INTO orders (user_id, order_date, total_price, status) " +
                "VALUES (?, NOW(), ?, 'PENDING')";
        
        try (PreparedStatement pstmt = conn.prepareStatement(insertOrderSQL, PreparedStatement.RETURN_GENERATED_KEYS)) {
            pstmt.setInt(1, userId);
            pstmt.setLong(2, totalPrice);
            
            int affectedRows = pstmt.executeUpdate();
            
            if (affectedRows == 0) {
                throw new SQLException("Creating order failed, no rows affected.");
            }
            
            try (ResultSet rs = pstmt.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                } else {
                    throw new SQLException("Creating order failed, no ID obtained.");
                }
            }
        }
    }

    // Method to insert order items
    private void insertOrderItems(Connection conn, int orderId, int userId) throws SQLException {
        String insertOrderItemsSQL = "INSERT INTO order_items (order_id, product_id, quantity, price) " +
                "SELECT ?, product_id, quantity, price " +
                "FROM cart_item " +
                "WHERE cart_id = (SELECT cart_id FROM cart WHERE user_id = ?)";
        
        try (PreparedStatement pstmt = conn.prepareStatement(insertOrderItemsSQL)) {
            pstmt.setInt(1, orderId);
            pstmt.setInt(2, userId);
            int itemsInserted = pstmt.executeUpdate();
            
            if (itemsInserted == 0) {
                throw new SQLException("No order items were inserted");
            }
        }
    }

    // Method to clear user's cart
    private void clearUserCart(Connection conn, int userId) throws SQLException {
        String clearCartSQL = "DELETE FROM cart_item " +
                "WHERE cart_id = (SELECT cart_id FROM cart WHERE user_id = ?)";
        
        try (PreparedStatement pstmt = conn.prepareStatement(clearCartSQL)) {
            pstmt.setInt(1, userId);
            pstmt.executeUpdate();
        }
    }

    // Method to calculate total price
    private long calculateTotalPrice(Connection conn, int userId) throws SQLException {
        String calculatePriceSQL = "SELECT COALESCE(SUM(price * quantity), 0) AS total " +
                                   "FROM cart_item " +
                                   "WHERE cart_id = (SELECT cart_id FROM cart WHERE user_id = ?)";
        
        try (PreparedStatement pstmt = conn.prepareStatement(calculatePriceSQL)) {
            pstmt.setInt(1, userId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    long total = rs.getLong("total");
                    if (total <= 0) {
                        throw new SQLException("Invalid cart total");
                    }
                    return total;
                } else {
                    throw new SQLException("Unable to calculate total price");
                }
            }
        }
    }

    // Rollback transaction safely
    private void rollbackTransaction(Connection conn) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException rollbackEx) {
                LOGGER.log(Level.SEVERE, "Error during rollback", rollbackEx);
            }
        }
    }

    // Close database connection safely
    private void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException ex) {
                LOGGER.log(Level.SEVERE, "Error closing database connection", ex);
            }
        }
    }

    // Get detailed error message
    private String getDetailedErrorMessage(SQLException ex) {
        return ex.getMessage() + " [Error Code: " + ex.getErrorCode() + 
               ", SQL State: " + ex.getSQLState() + "]";
    }
}