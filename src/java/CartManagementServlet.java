import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/CartManagementServlet")
public class CartManagementServlet extends HttpServlet {
     private static final String DB_URL = "jdbc:mysql://localhost:3306/e_commerce?maxAllowedPacket=104857600";
    private static final String DB_USER = "end_user";
    private static final String DB_PASSWORD = "Irmuun2018";

   

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("user_id");
        
        if (userId == null) {
            response.sendRedirect("sign_in_page.jsp");
            return;
        }

        String action = request.getParameter("action");
        int cartItemId = Integer.parseInt(request.getParameter("cart_item_id"));

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
            switch (action) {
                case "remove":
                    removeCartItem(conn, cartItemId);
                    break;
                case "increase":
                    updateQuantity(conn, cartItemId, 1);
                    break;
                case "decrease":
                    updateQuantity(conn, cartItemId, -1);
                    break;
            }

            // Recalculate total price
            updateCartTotalPrice(conn, userId);

            response.sendRedirect("home.jsp");
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                               "Error processing cart request");
        }
    }

    private void removeCartItem(Connection conn, int cartItemId) throws SQLException {
        String sql = "DELETE FROM cart_item WHERE cart_item_id = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, cartItemId);
            pstmt.executeUpdate();
        }
    }

    private void updateQuantity(Connection conn, int cartItemId, int change) throws SQLException {
        // First, check current quantity to prevent going below 1
        String checkSql = "SELECT quantity FROM cart_item WHERE cart_item_id = ?";
        String updateSql = "UPDATE cart_item SET quantity = quantity + ? WHERE cart_item_id = ? AND quantity + ? >= 1";
        
        try (PreparedStatement checkStmt = conn.prepareStatement(checkSql);
             PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
            
            checkStmt.setInt(1, cartItemId);
            
            updateStmt.setInt(1, change);
            updateStmt.setInt(2, cartItemId);
            updateStmt.setInt(3, change);
            
            updateStmt.executeUpdate();
        }
    }

    private void updateCartTotalPrice(Connection conn, int userId) throws SQLException {
        String sql = "UPDATE cart c " +
                     "SET total_price = (" +
                     "    SELECT COALESCE(SUM(ci.quantity * ci.price), 0) " +
                     "    FROM cart_item ci " +
                     "    WHERE ci.cart_id = c.cart_id" +
                     ") " +
                     "WHERE c.user_id = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.executeUpdate();
        }
    }
}