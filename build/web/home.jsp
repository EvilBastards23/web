<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">

<sql:setDataSource var="con" 
                   driver="com.mysql.cj.jdbc.Driver"
                   url="jdbc:mysql://localhost:3306/e_commerce" 
                   user="end_user" 
                   password="Irmuun2018"/>

<%
    String selectedCategory = request.getParameter("category");
    if (selectedCategory == null || selectedCategory.isEmpty()) {
        selectedCategory = "%";
    }
    pageContext.setAttribute("selectedCategory", selectedCategory);
%>

<sql:query dataSource="${con}" var="result">
    SELECT 
        p.model_number, 
        min(p.product_name) as product_name, 
       max(p.price) as price, 
        min(c.category_name) as category_name,
        GROUP_CONCAT(DISTINCT p.color) AS colors,
        GROUP_CONCAT(DISTINCT p.size) AS sizes,
        GROUP_CONCAT(DISTINCT TO_BASE64(p.image_blob)) AS images
    FROM 
        product p
    LEFT JOIN 
        category c 
    ON 
        p.category_id = c.category_id
    WHERE 
        c.category_name LIKE ?
    GROUP BY 
        p.model_number;
    <sql:param value="${selectedCategory}"/>
</sql:query>


<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Muunee's</title>
  <link rel="stylesheet" href="new_home.css">
  <script>
   
    function changeImage(event, modelNumber, color, images) {
        event.preventDefault();
        const imageElement = document.getElementById("product-image-" + modelNumber);
        const imageArray = images.split(',');
        const colorArray = color.split(',');
        let selectedImageUrl = '';
        for (let i = 0; i < colorArray.length; i++) {
            if (colorArray[i].toLowerCase() === color.toLowerCase()) {
                selectedImageUrl = imageArray[i];
                break;
            }
        }
        if (selectedImageUrl) {
            imageElement.src = `data:image/png;base64,${selectedImageUrl}`;
        }
    }
  </script>
  <style>
    .color-button {
        width: 20px;
        height: 20px;
        border-radius: 50%;
        border: none;
        margin: 0 5px;
        cursor: pointer;
    }
    .color-options {
        margin-top: 10px;
    }
    .cart-sidebar {
        position: fixed;
        right: -300px;
        top: 0;
        width: 300px;
        height: 100%;
        background: #f4f4f4;
        transition: right 0.3s;
    }
    .cart-sidebar.open {
        right: 0;
    }
  </style>
</head>
<body>
    <%@ include file="header.jsp" %>

  <!-- Filters -->
  <div class="filters">
    <form method="get" action="home.jsp">
      <select name="category" onchange="this.form.submit()">
        <option value="">All Categories</option>
        <option value="hat" ${selectedCategory == 'hat' ? 'selected' : ''}>Hat</option>
        <option value="scarf" ${selectedCategory == 'scarf' ? 'selected' : ''}>Scarf</option>
        <option value="hoodie" ${selectedCategory == 'hoodie' ? 'selected' : ''}>Hoodie</option>
        <option value="cardigan" ${selectedCategory == 'cardigan' ? 'selected' : ''}>Cardigan</option>
        <option value="gloves" ${selectedCategory == 'gloves' ? 'selected' : ''}>Gloves</option>
        <option value="sweater" ${selectedCategory == 'sweater' ? 'selected' : ''}>Sweater</option>
        <option value="vest" ${selectedCategory == 'vest' ? 'selected' : ''}>Vest</option>
      </select>
    </form>
  </div>

  <!-- Product Grid -->
  <div class="main-content">
    <section class="product-grid">
      <c:forEach var="product" items="${result.rows}">
        <a href="product_detail.jsp?model_number=${product.model_number}" class="product-card-link" id="product-link-${product.model_number}">
          <div class="product-card">
            <div class="image-container">
              <img id="product-image-${product.model_number}" 
                   src="data:image/jpg;base64,${fn:split(product.images, ',')[0]}" 
                   alt="${product.product_name}"
                   >
              
            </div>
            <p class="product-name">${product.product_name}</p>
            <p class="price">Price: $${product.price}</p>
            <div class="details">
              <p>Colors: ${fn:join(fn:split(product.colors, ','), ', ')}</p>
              <div class="color-options">
                <c:forEach var="color" items="${fn:split(product.colors, ',')}">
                  <button class="color-button" style="background-color: ${color};" 
                          onclick="changeImage(event, '${product.model_number}', '${color}', '${product.images}')"></button>
                </c:forEach>
              </div>
            </div>
          </div>
        </a>
      </c:forEach>
    </section>
  </div>
  

  <!-- Cart Sidebar -->
 
