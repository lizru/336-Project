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
</head>
<body>
    <h1>Customer Representative Dashboard</h1>
    <p>Welcome, <%=session.getAttribute("username")%></p>
    
    <ul>
        <li><a href="customerService.jsp">Manage Questions</a></li>
        <li><a href="manageAccounts.jsp">Manage User Accounts</a></li>
        <li><a href="manageAuctions.jsp">Manage Bids & Auctions</a></li>
    </ul>
    
    <a href="logout.jsp">Logout</a>
</body>
</html>