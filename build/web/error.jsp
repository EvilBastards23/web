<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Error Page</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f8d7da;
            color: #721c24;
            text-align: center;
            padding: 20px;
        }
        h1 {
            font-size: 2rem;
            margin-bottom: 20px;
        }
        p {
            font-size: 1.2rem;
        }
        .btn {
            display: inline-block;
            margin-top: 20px;
            padding: 10px 20px;
            background-color: #721c24;
            color: #fff;
            text-decoration: none;
            border-radius: 5px;
        }
        .btn:hover {
            background-color: #501217;
        }
    </style>
</head>
<body>
    <h1>Error</h1>

    <!-- Display error message from request attribute or parameter -->
    <c:choose>
        <c:when test="${not empty errorMessage}">
            <p>${errorMessage}</p>
        </c:when>
        <c:when test="${not empty param.message}">
            <p>${param.message}</p>
        </c:when>
        <c:otherwise>
            <p>An unexpected error occurred. Please try again later.</p>
        </c:otherwise>
    </c:choose>

    <!-- Provide a button to navigate back -->
    <a href="seller_dashboard.jsp" class="btn">Return to Dashboard</a>
</body>
</html>
