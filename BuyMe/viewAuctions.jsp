<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
    <title>View Auctions</title>
</head>
<body>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<h2>Active Vehicle Auctions</h2>
<a href="success.jsp">Home</a> | <a href="createAuction.jsp">Create Auction</a> | <a href="logout.jsp">Logout</a>
<hr>

<table border="1">
    <tr>
        <th>Auction ID</th>
        <th>Title</th>
        <th>Type</th>
        <th>Description</th>
        <th>Condition</th>
        <th>Current Price</th>
        <th>Ends</th>
        <th>Status</th>
        <th>Actions</th>
    </tr>
<%
    Connection con = null;
    Statement st = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/BuyMe", "root", "Linuxfs123!");
        
        String query = "SELECT a.auction_id, a.item_id, i.title, i.item_description, i.item_condition, " +
                      "a.start_price, a.end_time, a.auction_status, sc.sub_name, " +
                      "COALESCE(MAX(b.amount), a.start_price) as current_price " +
                      "FROM auction a " +
                      "JOIN item i ON a.item_id = i.item_id " +
                      "LEFT JOIN sub_category sc ON i.sub_category_id = sc.sub_category_id " +
                      "LEFT JOIN bid b ON a.auction_id = b.auction_id AND a.item_id = b.item_id " +
                      "GROUP BY a.auction_id, a.item_id, i.title, i.item_description, i.item_condition, " +
                      "a.start_price, a.end_time, a.auction_status, sc.sub_name " +
                      "ORDER BY a.end_time ASC";
        
        st = con.createStatement();
        rs = st.executeQuery(query);
        
        while (rs.next()) {
            int auctionId = rs.getInt("auction_id");
            int itemId = rs.getInt("item_id");
            String title = rs.getString("title");
            String description = rs.getString("item_description");
            String condition = rs.getString("item_condition");
            double currentPrice = rs.getDouble("current_price");
            Timestamp endTime = rs.getTimestamp("end_time");
            String status = rs.getString("auction_status");
            String subName = rs.getString("sub_name");
            
            boolean isActive = "active".equals(status) && endTime.after(new Timestamp(System.currentTimeMillis()));
%>
    <tr>
        <td><%= auctionId %></td>
        <td><%= title %></td>
        <td><%= subName %></td>
        <td><%= description.length() > 100 ? description.substring(0, 100) + "..." : description %></td>
        <td><%= condition %></td>
        <td>$<%= String.format("%.2f", currentPrice) %></td>
        <td><%= endTime %></td>
        <td><%= isActive ? "ACTIVE" : "ENDED" %></td>
        <td>
            <% if (isActive) { %>
                <a href="placeBid.jsp?auction_id=<%= auctionId %>&item_id=<%= itemId %>">Place Bid</a>
            <% } else { %>
                Closed
            <% } %>
        </td>
    </tr>
<%
        }
    } catch (Exception e) {
        out.println("<tr><td colspan='9'>Error: " + e.getMessage() + "</td></tr>");
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch(SQLException e) {}
        if (st != null) try { st.close(); } catch(SQLException e) {}
        if (con != null) try { con.close(); } catch(SQLException e) {}
    }
%>
</table>

</body>
</html>
