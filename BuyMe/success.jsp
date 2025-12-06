<%
    if ((session.getAttribute("user") == null)) {
%>
You are not logged in<br/>
<a href="login.jsp">Please Login</a>
<%} else {
%>
<h2>Welcome <%=session.getAttribute("user")%></h2>

<h3>Auction Management</h3>
<ul>
    <li><a href="viewAuctions.jsp">View All Auctions</a></li>
    <li><a href="createAuction.jsp">Create New Auction (Seller)</a></li>
    <li><a href="closeAuctions.jsp">Close Expired Auctions</a></li>
</ul>

<a href='logout.jsp'>Log out</a>
<%
    }
%>
