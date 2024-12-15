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

@WebServlet("/RemoveProductServlet")
public class RemoveProductServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Get the product ID from the request
        String productId = request.getParameter("product_id");
        
        // Validate product ID
        if (productId == null || productId.isEmpty()) {
            // Log and send error
            System.err.println("Error: No product ID provided");
            request.setAttribute("errorMessage", "Invalid product ID. No ID was provided.");
            request.getRequestDispatcher("error.jsp").forward(request, response);
            return;
        }

        Connection connection = null;
        PreparedStatement statement = null;

        try {
            // Database connection details (consider using a connection pool in production)
            String dbURL = "jdbc:mysql://localhost:3306/e_commerce";
            String dbUser = "seller";
            String dbPassword = "Irmuun2018";

            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");

            // Establish the connection
            connection = DriverManager.getConnection(dbURL, dbUser, dbPassword);

            // Prepare the DELETE statement
            String sql = "DELETE FROM product WHERE product_id = ?";
            statement = connection.prepareStatement(sql);
            
            // Convert and set the product ID
            int productIdInt = Integer.parseInt(productId);
            statement.setInt(1, productIdInt);

            // Execute the delete
            int rowsAffected = statement.executeUpdate();

            // Check if deletion was successful
            if (rowsAffected > 0) {
                // Log successful deletion
                System.out.println("Product removed successfully. Product ID: " + productId);
                
                // Redirect with success message
                response.sendRedirect("seller_page.jsp?success=Product+removed+successfully#products_list");
            } else {
                // Log failed deletion
                System.err.println("No product found with ID: " + productId);
                
                // Forward to error page
                request.setAttribute("errorMessage", "No product found with the specified ID.");
                request.getRequestDispatcher("error.jsp").forward(request, response);
            }

        } catch (NumberFormatException e) {
            // Log invalid number format
            System.err.println("Error: Invalid product ID format - " + productId);
            request.setAttribute("errorMessage", "Invalid product ID format.");
            request.getRequestDispatcher("error.jsp").forward(request, response);

        } catch (SQLException e) {
            // Log SQL exception
            System.err.println("Database error occurred: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "Database error: " + e.getMessage());
            request.getRequestDispatcher("error.jsp").forward(request, response);

        } catch (ClassNotFoundException e) {
            // Log driver not found
            System.err.println("JDBC Driver not found");
            request.setAttribute("errorMessage", "Database driver error.");
            request.getRequestDispatcher("error.jsp").forward(request, response);

        } finally {
            // Properly close resources
            try {
                if (statement != null) statement.close();
                if (connection != null) connection.close();
            } catch (SQLException e) {
                System.err.println("Error closing database resources: " + e.getMessage());
            }
        }
    }
}