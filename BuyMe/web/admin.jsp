<%
if (!"admin".equals(session.getAttribute("role"))) {
    response.sendRedirect("login.jsp");
    return;
}
%>

<h1>Admin Dashboard</h1>

<ul>
    <li><a href="createRep.jsp">Create Customer Representative</a></li>
    <li><a href="salesReports.jsp">View Sales Reports</a></li>
</ul>

<a href="logout.jsp">Logout</a>
