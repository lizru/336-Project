<%
if (!"rep".equals(session.getAttribute("role"))) {
    response.sendRedirect("login.jsp");
    return;
}
%>

<!DOCTYPE html>
<html>
<head>
    <title>Customer Representative Dashboard</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="container">
    <h1>Customer Representative Dashboard</h1>
    <p>Welcome, <%=session.getAttribute("user")%></p>
    
    <ul>
        <li><a href="customerService.jsp">Manage Questions</a></li>
        <li><a href="manageAccounts.jsp">Manage User Accounts</a></li>
        <li><a href="manageAuctions.jsp">Manage Bids & Auctions</a></li>
    </ul>
    
    <a href="logout.jsp">Logout</a>
</div>
</body>
</html>