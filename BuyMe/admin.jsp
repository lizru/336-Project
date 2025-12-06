<%
if (!"admin".equals(session.getAttribute("role"))) {
    response.sendRedirect("login.jsp");
    return;
}
%>
<!DOCTYPE html>
<html>
<head>
    <title>Admin Dashboard - BuyMe</title>
</head>
<body>
    <h1>Admin Dashboard</h1>
    <p>Welcome, <%= session.getAttribute("user") %>!</p>
    
    <ul>
        <li><a href="createRep.jsp">Create Customer Representative</a></li>
        <li><a href="salesReport.jsp">View Sales Reports</a></li>
    </ul>
    
    <hr>
    <a href="logout.jsp">Logout</a>
</body>
</html>