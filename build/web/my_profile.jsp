<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%
    String userIdStr = (String)session.getAttribute("user_id");
    // Check if user is logged in
    if(userIdStr == null) {
        response.sendRedirect("sign_in_page.jsp");
        return;
    }

    int userId = Integer.parseInt(userIdStr);
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet userRs = null;
    ResultSet orderRs = null;
    
   
        // Establish database connection
        Class.forName("com.mysql.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/e_commerce", "end_user", "Irmuun2018");
        
        // Fetch User Details
        pstmt = conn.prepareStatement("SELECT username, phone_number, email FROM username WHERE user_id = ?");
        pstmt.setInt(1, userId);
        userRs = pstmt.executeQuery();
        
        String userName = "";
        String userPhone = "";
        String userEmail = "";
        
        if(userRs.next()) {
            userName = userRs.getString("username");
            userPhone = userRs.getString("phone_number");
            userEmail = userRs.getString("email");
        }
        
        // Fetch Order History
        pstmt = conn.prepareStatement(
            "SELECT order_id, order_date, total_price, status " +
            "FROM orders WHERE user_id = ? ORDER BY order_date DESC"
        );
        pstmt.setInt(1, userId);
        orderRs = pstmt.executeQuery();
        
        // Count Pending Orders
        pstmt = conn.prepareStatement(
            "SELECT COUNT(*) as pending_count FROM orders WHERE user_id = ? AND status = 'pending'"
        );
        pstmt.setInt(1, userId);
        ResultSet pendingRs = pstmt.executeQuery();
        int pendingOrderCount = 0;
        if(pendingRs.next()) {
            pendingOrderCount = pendingRs.getInt("pending_count");
        }
%>

<!DOCTYPE html>
<html>
<head>
    <title>My Profile</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .profile-section { background: #f4f4f4; padding: 20px; margin-bottom: 20px; }
        table { width: 100%; border-collapse: collapse; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        .pending-orders { 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            margin-bottom: 15px; 
        }
    </style>
</head>
<body>
    <div class="profile-section">
        <h2>Personal Information</h2>
        <p><strong>Name:</strong> <%= userName %></p>
        <p><strong>Phone:</strong> <%= userPhone %></p>
        <p><strong>Email:</strong> <%= userEmail %></p>
    </div>

    <div class="profile-section">
        <div class="pending-orders">
            <h2>Order History</h2>
            <p>Pending Orders: <%= pendingOrderCount %></p>
            <a href="payment.jsp" style="text-decoration: none; background-color: #007bff; color: white; padding: 5px 10px; border-radius: 5px;">
                View Pending Orders
            </a>
        </div>

        <table>
            <thead>
                <tr>
                    <th>Order ID</th>
                    <th>Date</th>
                    <th>Total Amount</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                <% while(orderRs.next()) { %>
                    <tr>
                        <td><%= orderRs.getInt("order_id") %></td>
                        <td><%= orderRs.getDate("order_date") %></td>
                        <td>$<%= orderRs.getDouble("total_price") %></td>
                        <td><%= orderRs.getString("status") %></td>
                    </tr>
                <% } %>
            </tbody>
        </table>
    </div>
</body>
</html>
