<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"%>
<!DOCTYPE html>
<html>
<head>
    <title>Pending Orders</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css">
    <style>
        .order-card {
            margin: 15px 0;
            padding: 15px;
            border: 1px solid #ddd;
            border-radius: 8px;
        }
    </style>
</head>
<body>
    <%@ include file="header.jsp" %>
    <div class="container">
        <h1>Your Pending Orders</h1>

        <c:if test="${sessionScope.user_id == null}">
            <%response.sendRedirect("sign_in_page.jsp");%> 
        </c:if>

        <c:catch var="error">
            <sql:setDataSource var="dataSource" driver="com.mysql.cj.jdbc.Driver"
                               url="jdbc:mysql://localhost:3306/e_commerce"
                               user="end_user" password="Irmuun2018" />

            <sql:query var="orders" dataSource="${dataSource}">
                SELECT o.order_id, o.order_date, o.total_price, 
                       GROUP_CONCAT(
                           CONCAT(
                               'Product: ', p.product_name, 
                               ', Color: ', COALESCE(p.color, 'N/A'),
                               ', Size: ', COALESCE(p.size, 'N/A'),
                               ', Quantity: ', oi.quantity, 
                               ', Price: $', FORMAT(oi.price, 2)
                           ) SEPARATOR '; '
                       ) AS order_items
                FROM orders o
                INNER JOIN order_items oi ON o.order_id = oi.order_id
                INNER JOIN product p ON oi.product_id = p.product_id
                WHERE o.status = 'Pending' AND o.user_id = ?
                GROUP BY o.order_id, o.order_date, o.total_price
                ORDER BY o.order_date DESC
                <sql:param value="${sessionScope.user_id}" />
            </sql:query>
        </c:catch>
        <c:if test="${not empty error}">
            <div class="alert alert-danger">
                Error querying orders: ${error}
            </div>
        </c:if>
        <c:if test="${not empty orders.rows}">
            <c:forEach var="order" items="${orders.rows}">
                
                <div class="card mb-3">
                    <div class="card-header">
                        <strong>Order ID: ${order.order_id}</strong>
                    </div>
                    <div class="card-body">
                        <div class="order-card">
                            <p>Date: ${order.order_date}</p>
                            <p>Total Price: $${order.total_price}</p>
                            <h6>Items:</h6>
                            <ul>
                                <c:forEach var="item" items="${order.order_items.split('; ')}">
                                    <li>${item}</li>
                                </c:forEach>
                            </ul>
                            <!-- Payment Form -->
                            <form method="post" action="payment_handler.jsp" class="mt-3">
                                <input type="hidden" name="order_id" value="${order.order_id}">
                                <div class="form-group">
                                    <label for="cardNumber_${order.order_id}">Card Number:</label>
                                    <input type="text" class="form-control" id="cardNumber_${order.order_id}" name="card_number" required>
                                </div>
                                <div class="form-group">
                                    <label for="cardCVC_${order.order_id}">CVC:</label>
                                    <input type="text" class="form-control" id="cardCVC_${order.order_id}" name="card_cvc" required>
                                </div>
                                <div class="form-group">
                                    <label for="cardExpiry_${order.order_id}">Expiry Date:</label>
                                    <input type="text" class="form-control" id="cardExpiry_${order.order_id}" name="card_expiry" placeholder="MM/YY" required>
                                </div>
                                <button type="submit" class="btn btn-primary">Pay Now</button>
                            </form>
                                <form method="post" action="cancel_order_handler.jsp" class="mt-3">
                                    <input type="hidden" name="order_id" value="${order.order_id}">
                                    <button type="submit" class="btn btn-danger">Cancel Order</button>
                                </form>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </c:if>

        <c:if test="${empty orders.rows}">
            <p>No pending orders found.</p>
        </c:if>
    </div>
    <!-- Bootstrap JS (optional) -->
    <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js"></script>
</body>
</html>
