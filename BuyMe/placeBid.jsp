<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
    <title>Place Bid - BuyMe</title>
    <link rel="stylesheet" href="css/style.css">
    <script>
        function toggleAutoBid() {
            var bidType = document.querySelector('input[name="bid_type"]:checked').value;
            var autoBidFields = document.getElementById('autoBidFields');
            if (bidType === 'auto') {
                autoBidFields.style.display = 'block';
            } else {
                autoBidFields.style.display = 'none';
            }
        }
    </script>
</head>
<body>
<div class="container">
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String auctionIdStr = request.getParameter("auction_id");
    String itemIdStr = request.getParameter("item_id");
    
    if (auctionIdStr == null || itemIdStr == null) {
        response.sendRedirect("viewAuctions.jsp");
        return;
    }
%>

<h2>Place Bid</h2>
<a href="viewAuctions.jsp">Back to Auctions</a> | <a href="success.jsp">Home</a>
<hr>

<%
    Connection con = null;
    PreparedStatement pst = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/BuyMe", "root", "Linuxfs123!");
        
        int auctionId = Integer.parseInt(auctionIdStr);
        int itemId = Integer.parseInt(itemIdStr);
        
        // Get auction details
        String query = "SELECT a.auction_id, a.item_id, i.title, i.make, i.model, i.year, i.mileage, i.color, i.item_condition, " +
                      "a.start_price, a.increment, a.end_time, a.auction_status, " +
                      "COALESCE(MAX(b.amount), a.start_price) as current_price " +
                      "FROM auction a " +
                      "JOIN item i ON a.item_id = i.item_id " +
                      "LEFT JOIN bid b ON a.auction_id = b.auction_id AND a.item_id = b.item_id " +
                      "WHERE a.auction_id = ? AND a.item_id = ? " +
                      "GROUP BY a.auction_id, a.item_id, i.title, i.make, i.model, i.year, i.mileage, i.color, i.item_condition, " +
                      "a.start_price, a.increment, a.end_time, a.auction_status";
        
        pst = con.prepareStatement(query);
        pst.setInt(1, auctionId);
        pst.setInt(2, itemId);
        rs = pst.executeQuery();
        
        if (rs.next()) {
            String title = rs.getString("title");
            String make = rs.getString("make");
            String model = rs.getString("model");
            int year = rs.getInt("year");
            int mileage = rs.getInt("mileage");
            String color = rs.getString("color");
            String condition = rs.getString("item_condition");
            double currentPrice = rs.getDouble("current_price");
            double increment = rs.getDouble("increment");
            Timestamp endTime = rs.getTimestamp("end_time");
            String status = rs.getString("auction_status");
            
            double minBid = currentPrice + increment;
%>

<h3><%= title %></h3>
<p><strong>Make:</strong> <%= make %></p>
<p><strong>Model:</strong> <%= model %></p>
<p><strong>Year:</strong> <%= year %></p>
<p><strong>Mileage:</strong> <%= String.format("%,d", mileage) %> miles</p>
<p><strong>Color:</strong> <%= color %></p>
<p><strong>Condition:</strong> <%= condition %></p>
<p><strong>Current Price:</strong> $<%= String.format("%.2f", currentPrice) %></p>
<p><strong>Minimum Bid:</strong> $<%= String.format("%.2f", minBid) %></p>
<p><strong>Bid Increment:</strong> $<%= String.format("%.2f", increment) %></p>
<p><strong>Auction Ends:</strong> <%= endTime %></p>

<form action="processBid.jsp" method="POST">
    <input type="hidden" name="auction_id" value="<%= auctionId %>">
    <input type="hidden" name="item_id" value="<%= itemId %>">
    <input type="hidden" name="current_price" value="<%= currentPrice %>">
    <input type="hidden" name="increment" value="<%= increment %>">
    
    <h3>Bid Type:</h3>
    <input type="radio" name="bid_type" value="manual" checked onclick="toggleAutoBid()"> Manual Bid<br>
    <input type="radio" name="bid_type" value="auto" onclick="toggleAutoBid()"> Automatic Bid<br><br>
    
    <label>Your Bid Amount ($):</label><br>
    <input type="number" name="bid_amount" step="<%= increment %>" min="<%= minBid %>" value="<%= minBid %>" required><br>
    <small>Bid must be in increments of $<%= String.format("%.2f", increment) %></small><br><br>
    
    <div id="autoBidFields" style="display:none;">
        <h3>Automatic Bidding Settings</h3>
        <p>The system will automatically bid on your behalf up to your maximum limit.</p>
        
        <label>Maximum Bid Limit ($):</label><br>
        <input type="number" name="autobid_limit" step="<%= increment %>" min="<%= minBid %>"><br>
        <small>Limit must be in increments of $<%= String.format("%.2f", increment) %></small><br><br>
        
        <p><em>Note: Each time you are outbid, the system will automatically place a new bid (current price + increment) until your maximum limit is reached.</em></p>
    </div>
    
    <input type="submit" value="Place Bid">
    <input type="button" value="Cancel" onclick="window.location.href='viewAuctions.jsp'">
</form>

<%
        } else {
            out.println("<p>Auction not found.</p>");
        }
    } catch (Exception e) {
        out.println("<p>Error: " + e.getMessage() + "</p>");
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch(SQLException e) {}
        if (pst != null) try { pst.close(); } catch(SQLException e) {}
        if (con != null) try { con.close(); } catch(SQLException e) {}
    }
%>

</div>
</body>
</html>
