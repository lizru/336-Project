<%
if (!"admin".equals(session.getAttribute("role"))) {
    response.sendRedirect("login.jsp");
    return;
}
%>

<h2>Create Customer Representative</h2>

<form action="createRep.jsp" method="POST">
    Username: <input type="text" name="userid"><br>
    Password: <input type="password" name="password"><br>
    Email: <input type="text" name="email"><br>
    <input type="submit" value="Create Rep">
</form>

<%
if ("POST".equalsIgnoreCase(request.getMethod())) {

    Class.forName("com.mysql.jdbc.Driver");
    Connection con = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/AuctionHouse",
        "jaiveer", "root"
    );

    PreparedStatement ps = con.prepareStatement(
        "INSERT INTO Users (username,password,email,role) VALUES (?,?,?,'rep')"
    );

    ps.setString(1, request.getParameter("userid"));
    ps.setString(2, request.getParameter("password"));
    ps.setString(3, request.getParameter("email"));

    ps.executeUpdate();
    con.close();

    out.println("<p>Representative created!</p>");
}
%>
