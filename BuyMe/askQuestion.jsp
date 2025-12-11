<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
    <title>Ask Customer Service - BuyMe</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="container">
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String username = (String) session.getAttribute("user");
    Integer userId = (Integer) session.getAttribute("user_id");
    
    if (userId == null) {
        out.println("<h2>Error</h2>");
        out.println("<p>User ID not found. Please log in again.</p>");
        out.println("<a href='login.jsp'>Back to Login</a>");
        return;
    }
%>

<h2>Ask Customer Service</h2>
<a href="success.jsp">Back to Home</a> | <a href="myQuestions.jsp">View My Questions</a> | <a href="logout.jsp">Logout</a>
<hr>

<p>Have a question? Submit it here and a customer service representative will respond soon.</p>

<form action="submitQuestion.jsp" method="POST">
    <label><strong>Question Title:</strong></label><br>
    <input type="text" name="title" required maxlength="100" size="60" 
           placeholder="Brief summary of your question"><br><br>
    
    <label><strong>Your Question:</strong></label><br>
    <textarea name="question_text" rows="8" cols="60" required 
              placeholder="Please describe your question in detail..."></textarea><br><br>
    
    <input type="submit" value="Submit Question">
    <input type="reset" value="Clear">
</form>

</div>
</body>
</html>
