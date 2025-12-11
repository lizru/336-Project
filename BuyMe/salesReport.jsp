<%@ page import="java.sql.*" %>
<%
if (!"admin".equals(session.getAttribute("role"))) {
    response.sendRedirect("login.jsp");
    return;
}
%>
<!DOCTYPE html>
<html>
<head>
    <title>Sales Reports - BuyMe</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="container">
    <h2>Sales Reports</h2>
    
    <form method="GET" action="salesReport.jsp">
        <select name="report">
            <option value="">-- Select Report --</option>
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
    if (report != null && !report.isEmpty()) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/BuyMe",
                "root", "Linuxfs123!"
            );
            Statement st = con.createStatement();
            ResultSet rs = null;
            
            if ("total".equals(report)) {
                rs = st.executeQuery(
                    "SELECT SUM(winning_bid) AS total FROM (" +
                    "SELECT bx.item_id, COALESCE(MAX(b.amount), a.start_price) as winning_bid " +
                    "FROM buys bx " +
                    "JOIN auction a ON a.item_id = bx.item_id " +
                    "LEFT JOIN bid b ON b.item_id = bx.item_id AND b.auction_id = a.auction_id " +
                    "WHERE a.auction_status = 'closed' " +
                    "GROUP BY bx.item_id, a.start_price" +
                    ") AS wins"
                );
                if (rs.next()) {
                    double total = rs.getDouble("total");
                    out.println("<h3>Total Earnings: $" + String.format("%.2f", total) + "</h3>");
                }
            }
            
            else if ("item".equals(report)) {
                rs = st.executeQuery(
                    "SELECT i.item_id, i.title, COALESCE(MAX(b.amount), a.start_price) AS earn " +
                    "FROM item i " +
                    "JOIN auction a ON a.item_id = i.item_id " +
                    "LEFT JOIN bid b ON b.item_id = i.item_id " +
                    "WHERE a.auction_status = 'closed' AND i.item_id IN (SELECT item_id FROM buys) " +
                    "GROUP BY i.item_id, i.title, a.start_price"
                );
                out.println("<h3>Earnings Per Item (Sold Items Only)</h3>");
                while (rs.next()) {
                    out.println("Item #" + rs.getInt("item_id") + " (" + rs.getString("title") + "): $" + 
                               String.format("%.2f", rs.getDouble("earn")) + "<br>");
                }
            }
            
            else if ("itemtype".equals(report)) {
                rs = st.executeQuery(
                    "SELECT sc.sub_name, COUNT(*) as count, SUM(COALESCE(MAX_BID.max_bid, a.start_price)) AS earn " +
                    "FROM item i " +
                    "JOIN sub_category sc ON sc.sub_category_id = i.sub_category_id " +
                    "JOIN auction a ON a.item_id = i.item_id " +
                    "LEFT JOIN (SELECT item_id, MAX(amount) as max_bid FROM bid GROUP BY item_id) MAX_BID ON MAX_BID.item_id = i.item_id " +
                    "WHERE a.auction_status = 'closed' AND i.item_id IN (SELECT item_id FROM buys) " +
                    "GROUP BY sc.sub_name"
                );
                out.println("<h3>Earnings Per Item Type</h3>");
                while (rs.next()) {
                    out.println(rs.getString("sub_name") + ": $" + String.format("%.2f", rs.getDouble("earn")) + 
                               " (" + rs.getInt("count") + " items sold)<br>");
                }
            }
            
            else if ("user".equals(report)) {
                rs = st.executeQuery(
                    "SELECT u.username, u.full_name, COUNT(*) as items_bought, SUM(COALESCE(MAX_BID.max_bid, a.start_price)) AS spent " +
                    "FROM user u " +
                    "JOIN buys bx ON bx.user_id = u.user_id " +
                    "JOIN auction a ON a.item_id = bx.item_id " +
                    "LEFT JOIN (SELECT item_id, MAX(amount) as max_bid FROM bid GROUP BY item_id) MAX_BID ON MAX_BID.item_id = bx.item_id " +
                    "GROUP BY u.user_id, u.username, u.full_name"
                );
                out.println("<h3>Earnings Per End-User (Buyers)</h3>");
                while (rs.next()) {
                    out.println(rs.getString("full_name") + " (@" + rs.getString("username") + "): $" + 
                               String.format("%.2f", rs.getDouble("spent")) + 
                               " (" + rs.getInt("items_bought") + " items)<br>");
                }
            }
            
            else if ("bestselling".equals(report)) {
                rs = st.executeQuery(
                    "SELECT sc.sub_name, COUNT(*) AS countSold " +
                    "FROM item i " +
                    "JOIN sub_category sc ON sc.sub_category_id = i.sub_category_id " +
                    "JOIN buys bx ON bx.item_id = i.item_id " +
                    "GROUP BY sc.sub_name " +
                    "ORDER BY countSold DESC"
                );
                out.println("<h3>Best-Selling Item Types</h3>");
                while (rs.next()) {
                    out.println(rs.getString("sub_name") + ": " + rs.getInt("countSold") + " sold<br>");
                }
            }
            
            else if ("bestbuyers".equals(report)) {
                rs = st.executeQuery(
                    "SELECT u.username, u.full_name, COUNT(*) as items_bought, SUM(COALESCE(MAX_BID.max_bid, a.start_price)) AS spent " +
                    "FROM user u " +
                    "JOIN buys bx ON bx.user_id = u.user_id " +
                    "JOIN auction a ON a.item_id = bx.item_id " +
                    "LEFT JOIN (SELECT item_id, MAX(amount) as max_bid FROM bid GROUP BY item_id) MAX_BID ON MAX_BID.item_id = bx.item_id " +
                    "GROUP BY u.user_id, u.username, u.full_name " +
                    "ORDER BY spent DESC"
                );
                out.println("<h3>Best Buyers (Top Spenders)</h3>");
                int rank = 1;
                while (rs.next()) {
                    out.println(rank++ + ". " + rs.getString("full_name") + " (@" + rs.getString("username") + "): $" + 
                               String.format("%.2f", rs.getDouble("spent")) + 
                               " (" + rs.getInt("items_bought") + " items)<br>");
                }
            }
            
            if (rs != null) rs.close();
            st.close();
            con.close();
        } catch (Exception e) {
            out.println("<p style='color: red;'>Error generating report: " + e.getMessage() + "</p>");
            e.printStackTrace();
        }
    }
    %>
    
    <hr>
    <a href="admin.jsp">Back to Admin Dashboard</a>
</div>
</body>
</html>