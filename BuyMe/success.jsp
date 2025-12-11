<!DOCTYPE html>
<html>
<head>
    <title>BuyMe - Dashboard</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="container">
<%
    if ((session.getAttribute("user") == null)) {
%>
<div class="info">You are not logged in<br/>
<a href="login.jsp">Please Login</a></div>
<%} else {
%>
<h2>Welcome <%=session.getAttribute("user")%></h2>

<h3>Auction Management</h3>
<ul>
    <li><a href="browseAuctions.jsp">Browse & Search Auctions</a></li>
    <li><a href="viewAuctions.jsp">View All Auctions</a></li>
    <li><a href="createAuction.jsp">Create New Auction (Seller)</a></li>
    <li><a href="myWins.jsp">My Wins</a></li>
    <li><a href="viewAlerts.jsp">My Bid Alerts</a></li>
    <li><a href="viewUserAuctions.jsp">My Auction History</a></li>
</ul>

<h3>Customer Service</h3>
<ul>
    <li><a href="askQuestion.jsp">Ask a Question</a></li>
    <li><a href="myQuestions.jsp">View My Questions & Replies</a></li>
</ul>

<a href='logout.jsp'>Log out</a>
<%
    }
%>
</div>
</body>
</html>
