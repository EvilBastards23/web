<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Cancel Order</title>
</head>
<body>
    <c:catch var="error">
        <sql:setDataSource var="dataSource" driver="com.mysql.cj.jdbc.Driver"
                           url="jdbc:mysql://localhost:3306/e_commerce"
                           user="end_user" password="Irmuun2018" />

        <sql:update dataSource="${dataSource}">
            UPDATE orders
            SET status = 'Cancelled'
            WHERE order_id = ?
            <sql:param value="${param.order_id}" />
        </sql:update>
    </c:catch>

    <c:if test="${not empty error}">
        <p>Error cancelling order: ${error}</p>
    </c:if>

    <c:if test="${empty error}">
        <p>Order successfully cancelled.</p>
    </c:if>

    <script>
        // Redirect back to the Pending Orders page
        window.location.href = "payment.jsp";
    </script>
</body>
</html>
