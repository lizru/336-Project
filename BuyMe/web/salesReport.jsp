<%
if (!"admin".equals(session.getAttribute("role"))) {
    response.sendRedirect("login.jsp");
    return;
}
%>

<h2>Sales Reports</h2>

<form method="GET" action="salesReports.jsp">
    <select name="report">
        <option value="total">Total Earnings</option>
        <option value="item">Earnings per Item</option>
        <option value="itemtype">Earnings per Item Type</option>
        <option value="user">Earnings per End-User</option>
        <option value="bestselling">Best-Selling Items</option>
        <option value="bestbuyers">Best Buyers</option>
    </select>
    <input type="submit" value="Generate">
</form>
<hr>

<%
String report = request.getParameter("report");
if (report != null) {

    Class.forName("com.mysql.jdbc.Driver");
    Connection con = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/AuctionHouse",
        "jaiveer", "root"
    );
    Statement st = con.createStatement();
    ResultSet rs = null;

    if ("total".equals(report)) {
        rs = st.executeQuery(
            "SELECT SUM(final_price) AS total FROM Auctions WHERE status='closed'"
        );
        if (rs.next()) out.println("<h3>Total Earnings: $" + rs.getDouble("total") + "</h3>");
    }

    else if ("item".equals(report)) {
        rs = st.executeQuery(
            "SELECT item_id, SUM(final_price) AS earn FROM Auctions GROUP BY item_id"
        );
        out.println("<h3>Earnings Per Item</h3>");
        while (rs.next()) {
            out.println("Item " + rs.getInt("item_id") + ": $" + rs.getDouble("earn") + "<br>");
        }
    }

    else if ("itemtype".equals(report)) {
        rs = st.executeQuery(
            "SELECT item_type, SUM(final_price) AS earn FROM Auctions GROUP BY item_type"
        );
        out.println("<h3>Earnings Per Item Type</h3>");
        while (rs.next()) {
            out.println(rs.getString("item_type") + ": $" + rs.getDouble("earn") + "<br>");
        }
    }

    else if ("user".equals(report)) {
        rs = st.executeQuery(
            "SELECT buyer_id, SUM(final_price) AS spent FROM Auctions GROUP BY buyer_id"
        );
        out.println("<h3>Earnings Per End-User</h3>");
        while (rs.next()) {
            out.println("User " + rs.getString("buyer_id") + ": $" + rs.getDouble("spent") + "<br>");
        }
    }

    else if ("bestselling".equals(report)) {
        rs = st.executeQuery(
            "SELECT item_id, COUNT(*) AS countSold FROM Auctions GROUP BY item_id ORDER BY countSold DESC"
        );
        out.println("<h3>Best-Selling Items</h3>");
        while (rs.next()) {
            out.println("Item " + rs.getInt("item_id") + ": sold " + rs.getInt("countSold") + " times<br>");
        }
    }

    else if ("bestbuyers".equals(report)) {
        rs = st.executeQuery(
            "SELECT buyer_id, SUM(final_price) AS spent FROM Auctions GROUP BY buyer_id ORDER BY spent DESC"
        );
        out.println("<h3>Best Buyers</h3>");
        while (rs.next()) {
            out.println(rs.getString("buyer_id") + ": $" + rs.getDouble("spent") + "<br>");
        }
    }

    con.close();
}
%>
