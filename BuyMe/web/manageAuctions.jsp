<%@ page import="java.sql.*" %>
<%
if (!"rep".equals(session.getAttribute("role"))) {
    response.sendRedirect("login.jsp");
    return;
}
%>

<!DOCTYPE html>
<html>
<head>
    <title>Manage Bids & Auctions</title>
</head>
<body>
    <h2>Manage Bids & Auctions</h2>
    <a href="repDashboard.jsp">Back to Dashboard</a>
    
    <h3>All Bids</h3>
    <%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/AuctionHouse", "jaiveer", "root");
        
        Statement st = con.createStatement();
        ResultSet rs = st.executeQuery(
            "SELECT b.bid_id, b.auction_id, b.item_id, b.user_id, b.amount, b.time, " +
            "u.username, i.title FROM bid b " +
            "JOIN user u ON b.user_id = u.user_id " +
            "JOIN item i ON b.item_id = i.item_id " +
            "ORDER BY b.time DESC"
        );
        
        out.println("<table border='1' cellpadding='5'>");
        out.println("<tr><th>Bid ID</th><th>Auction</th><th>Item</th><th>User</th><th>Amount</th><th>Time</th><th>Action</th></tr>");
        
        while (rs.next()) {
            out.println("<tr>");
            out.println("<td>" + rs.getInt("bid_id") + "</td>");
            out.println("<td>" + rs.getInt("auction_id") + "</td>");
            out.println("<td>" + rs.getString("title") + " (" + rs.getInt("item_id") + ")</td>");
            out.println("<td>" + rs.getString("username") + " (" + rs.getInt("user_id") + ")</td>");
            out.println("<td>$" + rs.getDouble("amount") + "</td>");
            out.println("<td>" + rs.getTimestamp("time") + "</td>");
            out.println("<td><form method='POST' style='margin:0;'>");
            out.println("<input type='hidden' name='action' value='removebid'>");
            out.println("<input type='hidden' name='bid_id' value='" + rs.getInt("bid_id") + "'>");
            out.println("<input type='hidden' name='auction_id' value='" + rs.getInt("auction_id") + "'>");
            out.println("<input type='hidden' name='item_id' value='" + rs.getInt("item_id") + "'>");
            out.println("<input type='hidden' name='user_id' value='" + rs.getInt("user_id") + "'>");
            out.println("<input type='submit' value='Remove' style='background:red; color:white;'>");
            out.println("</form></td>");
            out.println("</tr>");
        }
        out.println("</table>");
        
        con.close();
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
    }
    %>
    
    <hr>
    <h3>All Auctions</h3>
    <%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/AuctionHouse", "jaiveer", "root");
        
        Statement st = con.createStatement();
        ResultSet rs = st.executeQuery(
            "SELECT a.auction_id, a.item_id, i.title, a.start_price, a.min_price, " +
            "a.start_time, a.end_time, a.auction_status FROM auction a " +
            "JOIN item i ON a.item_id = i.item_id " +
            "ORDER BY a.start_time DESC"
        );
        
        out.println("<table border='1' cellpadding='5'>");
        out.println("<tr><th>Auction ID</th><th>Item</th><th>Start Price</th><th>Min Price</th><th>Start</th><th>End</th><th>Status</th><th>Action</th></tr>");
        
        while (rs.next()) {
            out.println("<tr>");
            out.println("<td>" + rs.getInt("auction_id") + "</td>");
            out.println("<td>" + rs.getString("title") + " (" + rs.getInt("item_id") + ")</td>");
            out.println("<td>$" + rs.getDouble("start_price") + "</td>");
            out.println("<td>$" + rs.getDouble("min_price") + "</td>");
            out.println("<td>" + rs.getTimestamp("start_time") + "</td>");
            out.println("<td>" + rs.getTimestamp("end_time") + "</td>");
            out.println("<td>" + rs.getString("auction_status") + "</td>");
            out.println("<td><form method='POST' style='margin:0;'>");
            out.println("<input type='hidden' name='action' value='removeauction'>");
            out.println("<input type='hidden' name='auction_id' value='" + rs.getInt("auction_id") + "'>");
            out.println("<input type='hidden' name='item_id' value='" + rs.getInt("item_id") + "'>");
            out.println("<input type='submit' value='Remove' style='background:red; color:white;'>");
            out.println("</form></td>");
            out.println("</tr>");
        }
        out.println("</table>");
        
        con.close();
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
    }
    
    // POST requests
    
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String action = request.getParameter("action");
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/AuctionHouse", "jaiveer", "root");
            
            if ("removebid".equals(action)) {
                PreparedStatement ps = con.prepareStatement(
                    "DELETE FROM bid WHERE user_id=? AND item_id=? AND auction_id=? AND bid_id=?"
                );
                ps.setInt(1, Integer.parseInt(request.getParameter("user_id")));
                ps.setInt(2, Integer.parseInt(request.getParameter("item_id")));
                ps.setInt(3, Integer.parseInt(request.getParameter("auction_id")));
                ps.setInt(4, Integer.parseInt(request.getParameter("bid_id")));
                ps.executeUpdate();
                
                out.println("<p style='color:green;'>Bid removed!</p>");
                out.println("<meta http-equiv='refresh' content='1'>");
                
            } else if ("removeauction".equals(action)) {
                int auctionId = Integer.parseInt(request.getParameter("auction_id"));
                int itemId = Integer.parseInt(request.getParameter("item_id"));
                
                PreparedStatement ps1 = con.prepareStatement("DELETE FROM bid WHERE auction_id = ? AND item_id = ?");
                ps1.setInt(1, auctionId);
                ps1.setInt(2, itemId);
                ps1.executeUpdate();
                
                PreparedStatement ps2 = con.prepareStatement("DELETE FROM auction WHERE auction_id = ? AND item_id = ?");
                ps2.setInt(1, auctionId);
                ps2.setInt(2, itemId);
                ps2.executeUpdate();
                
                out.println("<p style='color:green;'>Auction removed!</p>");
                out.println("<meta http-equiv='refresh' content='1'>");
            }
            
            con.close();
        } catch (Exception e) {
            out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
        }
    }
    %>
</body>
</html>