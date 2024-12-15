
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%  HttpSession ses = request.getSession();
    String user_role = (String) ses.getAttribute("Role");
    if (user_role == null || !user_role.equalsIgnoreCase("user")) {
        response.sendRedirect("home.jsp"); // Redirect non-sellers
        return;
    }%>
<sql:setDataSource var="con" 
                   driver="com.mysql.cj.jdbc.Driver"
                   url="jdbc:mysql://localhost:3306/e_commerce" 
                   user="end_user" 
                   password="Irmuun2018"/>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<c:if test="${not empty sessionScope.user_id}">
    <sql:query dataSource="${con}" var="cart_items">
        SELECT 
            ci.cart_id,
            ci.cart_item_id, 
            ci.quantity, 
            ci.price, 
            p.product_name, 
            TO_BASE64(p.image_blob) AS image_blob
        FROM 
            cart_item ci 
        JOIN 
            product p 
        ON 
            ci.product_id = p.product_id
        WHERE 
            ci.cart_id = (
                SELECT cart_id 
                FROM cart 
                WHERE user_id = ${sessionScope.user_id}
            );
    </sql:query>
    <sql:query dataSource="${con}" var="total_price_number">
        SELECT total_price 
        FROM cart 
        WHERE cart_id = (
            SELECT cart_id 
            FROM cart 
            WHERE user_id = ${sessionScope.user_id}
        );
    </sql:query>
</c:if>
        
        <html>
            
            <head>
            </head>
            <body>
                <%@ include file="header.jsp" %>
     <c:if test="${not empty sessionScope.user_id}">
         <form method="post" action="InsertOrderServlet">
      <div class="cart-header">
        <h2>Your Cart</h2>
        <i class="fas fa-times" onclick="toggleCart()"></i>
      </div>
      <div class="cart-items">
        <c:forEach var="item" items="${cart_items.rows}">
          <div class="cart-item">
          <img src="data:image/jpg;base64,${item.image_blob}" 
     alt="${item.product_name}" 
     style="width: 200px; height: 200px; object-fit: cover;">
            <div class="cart-item-details">
              <p>${item.product_name}</p>
              <p>Price: $${item.price}</p>
              <p>Quantity: ${item.quantity}</p>
            </div>
          </div>
        </c:forEach>
        <div class="cart-footer">
          <p>Total: $${total_price_number.rows[0].total_price}</p>
          <button type="submit">buy</button>
        </div>
      </div>
         </form>
  </c:if>
            </body>
            
            
        </html>