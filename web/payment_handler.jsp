<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.util.*" %>

<%
    String orderId = request.getParameter("order_id");
    String cardNumber = request.getParameter("card_number");
    String cardCVC = request.getParameter("card_cvc");
    String cardExpiry = request.getParameter("card_expiry");

    if (orderId == null || cardNumber == null || cardCVC == null || cardExpiry == null) {
        response.sendRedirect("error.jsp"); // Handle missing data
        return;
    }

    // Simulate payment (real implementation would use a payment gateway)
    boolean paymentSuccess = true; // Assume payment always succeeds for now

    if (paymentSuccess) {
        String updateOrderQuery = "UPDATE orders SET status = 'Done' WHERE order_id = ?";
        String fetchOrderDetailsQuery = "SELECT product_id, quantity FROM order_items WHERE order_id = ?";
        String updateProductQuantityQuery = "UPDATE product SET quantity = quantity - ? WHERE product_id = ?";
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            java.sql.Connection conn = java.sql.DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/e_commerce", "end_user", "Irmuun2018");
            
            // Update order status
            java.sql.PreparedStatement updateOrderStmt = conn.prepareStatement(updateOrderQuery);
            updateOrderStmt.setString(1, orderId);
            updateOrderStmt.executeUpdate();

            // Fetch products and quantities from order_details table
            java.sql.PreparedStatement fetchDetailsStmt = conn.prepareStatement(fetchOrderDetailsQuery);
            fetchDetailsStmt.setString(1, orderId);
            java.sql.ResultSet rs = fetchDetailsStmt.executeQuery();

            // Update product quantities in products table
            java.sql.PreparedStatement updateProductStmt = conn.prepareStatement(updateProductQuantityQuery);
            while (rs.next()) {
                int productId = rs.getInt("product_id");
                int quantity = rs.getInt("quantity");
                
                updateProductStmt.setInt(1, quantity);
                updateProductStmt.setInt(2, productId);
                updateProductStmt.executeUpdate();
            }

            // Close all resources
            rs.close();
            updateOrderStmt.close();
            fetchDetailsStmt.close();
            updateProductStmt.close();
            conn.close();

            // Redirect to home page after successful operation
            response.sendRedirect("home.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
            return;
        }
    } else {
        response.sendRedirect("error.jsp");
    }
%>
