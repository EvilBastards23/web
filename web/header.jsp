<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<sql:setDataSource var="con" 
                   driver="com.mysql.cj.jdbc.Driver"
                   url="jdbc:mysql://localhost:3306/e_commerce" 
                   user="end_user" 
                   password="Irmuun2018"/>

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
<header class="header">
    <script>
      function toggleCart() {
      const cartSidebar = document.getElementById("cartSidebar");
      cartSidebar.classList.toggle("open");
    }
    </script>
    <div class="logo">Muunee's</div>
    <nav class="nav">
      <ul>
        <li><a href="home.jsp">Home</a></li>
        <li><a href="#">Sale</a></li>
        <li><a href="#">About Us</a></li>
      </ul>
    </nav>
    <div class="icons">
        <c:if test="${sessionScope.Role == 'user'}">
            <i class="fas fa-shopping-cart" onclick="toggleCart()"></i>
          </c:if>
        
      
      <c:choose>
        <c:when test="${empty sessionScope.user_id}">
          <a href="sign_in_page.jsp" class="button">Sign In</a>
          <a href="sign_up_page.jsp" class="button">Sign Up</a>
        </c:when>
        <c:otherwise>
          <a href="profile.jsp" class="button">My Profile</a>
          <a href="logout.jsp" class="button">Logout</a>
          <c:if test="${sessionScope.Role == 'seller'}">
            <a href="seller_page.jsp" class="button">Dashboard</a>
          </c:if>
        </c:otherwise>
      </c:choose>
    </div>
    <link rel="stylesheet" href="new_home.css">
</header>
 <c:if test="${not empty sessionScope.user_id}">
<aside class="cart-sidebar" id="cartSidebar">
  <div class="cart-header">
    <h2>Your Cart</h2>
    <i class="fas fa-times" onclick="toggleCart()"></i>
  </div>
  <div class="cart-items">
    <c:forEach var="item" items="${cart_items.rows}">
      <div class="cart-item">
        <img src="data:image/jpg;base64,${item.image_blob}" 
             alt="${item.product_name}" 
             style="width: 100px; height: 100px; object-fit: cover;">
        <div class="cart-item-details">
          <p>${item.product_name}</p>
          <p>Price: $${item.price}</p>
          
          <!-- Quantity Management for Sidebar -->
          <div class="quantity-control">
            <form action="CartManagementServlet" method="post" style="display:inline;">
              <input type="hidden" name="cart_item_id" value="${item.cart_item_id}">
              <input type="hidden" name="action" value="decrease">
              <button type="submit" class="quantity-btn">-</button>
            </form>
            
            <span class="quantity">${item.quantity}</span>
            
            <form action="CartManagementServlet" method="post" style="display:inline;">
              <input type="hidden" name="cart_item_id" value="${item.cart_item_id}">
              <input type="hidden" name="action" value="increase">
              <button type="submit" class="quantity-btn">+</button>
            </form>
          </div>
          
          <!-- Remove Item Button -->
          <form action="CartManagementServlet" method="post">
            <input type="hidden" name="cart_item_id" value="${item.cart_item_id}">
            <input type="hidden" name="action" value="remove">
            <button type="submit" class="remove-btn">Remove</button>
          </form>
        </div>
      </div>
    </c:forEach>
  </div>
  <div class="cart-footer">
    <p>Total: $${total_price_number.rows[0].total_price}</p>
    <a href="do_order_page.jsp" class="button">Checkout</a>
  </div>
</aside>
  </c:if>
</body>
</html>
