<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Bid History - BuyMe</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 1000px;
            margin: 0 auto;
            background-color: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            border-bottom: 3px solid #4CAF50;
            padding-bottom: 10px;
        }
        .auction-details {
            background-color: #f9f9f9;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .auction-details h2 {
            margin-top: 0;
            color: #4CAF50;
        }
        .detail-row {
            margin: 8px 0;
        }
        .detail-label {
            font-weight: bold;
            color: #555;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th {
            background-color: #4CAF50;
            color: white;
            padding: 12px;
            text-align: left;
            font-weight: bold;
        }
        td {
            padding: 12px;
            border-bottom: 1px solid #ddd;
        }
        tr:hover {
            background-color: #f5f5f5;
        }
        .highest-bid {
            background-color: #fff9c4;
            font-weight: bold;
        }
        .autobid-badge {
            background-color: #2196F3;
            color: white;
            padding: 2px 8px;
            border-radius: 3px;
            font-size: 0.85em;
            margin-left: 5px;
        }
        .no-bids {
            text-align: center;
            padding: 40px;
            color: #999;
            font-style: italic;
        }
        .back-link {
            display: inline-block;
            margin-top: 20px;
            padding: 10px 20px;
            background-color: #4CAF50;
            color: white;
            text-decoration: none;
            border-radius: 5px;
        }
        .back-link:hover {
            background-color: #45a049;
        }
        .error {
            color: #d32f2f;
            padding: 15px;
            background-color: #ffebee;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .bid-count {
            color: #666;
            font-size: 0.95em;
            margin-top: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Bid History</h1>
        
        <%
        String auctionId = request.getParameter("auction_id");
        String itemId = request.getParameter("item_id");
        
        if (auctionId == null || itemId == null) {
            out.println("<div class='error'>Error: Missing auction or item ID.</div>");
            out.println("<a href='browseAuctions.jsp' class='back-link'>Back to Browse</a>");
            return;
        }
        
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/BuyMe", "root", "Linuxfs123!");
            
            // Get auction and item details
            String auctionQuery = "SELECT a.*, i.title, i.make, i.model, i.year, i.color, " +
                                 "u.username as seller_name " +
                                 "FROM auction a " +
                                 "JOIN item i ON a.item_id = i.item_id " +
                                 "JOIN sells s ON i.item_id = s.item_id " +
                                 "JOIN user u ON s.user_id = u.user_id " +
                                 "WHERE a.auction_id = ? AND a.item_id = ?";
            ps = con.prepareStatement(auctionQuery);
            ps.setInt(1, Integer.parseInt(auctionId));
            ps.setInt(2, Integer.parseInt(itemId));
            rs = ps.executeQuery();
            
            if (rs.next()) {
                SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy HH:mm");
        %>
        
        <div class="auction-details">
            <h2><%= rs.getString("title") %></h2>
            <div class="detail-row">
                <span class="detail-label">Vehicle:</span> 
                <%= rs.getInt("year") %> <%= rs.getString("make") %> <%= rs.getString("model") %> 
                (<%= rs.getString("color") %>)
            </div>
            <div class="detail-row">
                <span class="detail-label">Seller:</span> <%= rs.getString("seller_name") %>
            </div>
            <div class="detail-row">
                <span class="detail-label">Auction ID:</span> <%= auctionId %>
            </div>
            <div class="detail-row">
                <span class="detail-label">Starting Price:</span> $<%= String.format("%.2f", rs.getDouble("start_price")) %>
            </div>
            <div class="detail-row">
                <span class="detail-label">Reserve Price:</span> $<%= String.format("%.2f", rs.getDouble("min_price")) %>
            </div>
            <div class="detail-row">
                <span class="detail-label">Bid Increment:</span> $<%= String.format("%.2f", rs.getDouble("increment")) %>
            </div>
            <div class="detail-row">
                <span class="detail-label">Start Time:</span> <%= sdf.format(rs.getTimestamp("start_time")) %>
            </div>
            <div class="detail-row">
                <span class="detail-label">End Time:</span> <%= sdf.format(rs.getTimestamp("end_time")) %>
            </div>
            <div class="detail-row">
                <span class="detail-label">Status:</span> <%= rs.getString("auction_status") %>
            </div>
        </div>
        
        <%
                rs.close();
                ps.close();
                
                // Get all bids for this auction
                String bidQuery = "SELECT b.*, u.username, u.full_name " +
                                 "FROM bid b " +
                                 "JOIN user u ON b.user_id = u.user_id " +
                                 "WHERE b.auction_id = ? AND b.item_id = ? " +
                                 "ORDER BY b.amount DESC, b.time DESC";
                ps = con.prepareStatement(bidQuery);
                ps.setInt(1, Integer.parseInt(auctionId));
                ps.setInt(2, Integer.parseInt(itemId));
                rs = ps.executeQuery();
                
                // Collect all bids first
                java.util.ArrayList<java.util.HashMap<String, Object>> bids = new java.util.ArrayList<>();
                while (rs.next()) {
                    java.util.HashMap<String, Object> bid = new java.util.HashMap<>();
                    bid.put("username", rs.getString("username"));
                    bid.put("full_name", rs.getString("full_name"));
                    bid.put("amount", rs.getDouble("amount"));
                    bid.put("time", rs.getTimestamp("time"));
                    bid.put("is_autobid", rs.getBoolean("is_autobid"));
                    bid.put("autobid_limit", rs.getObject("autobid_limit"));
                    bids.add(bid);
                }
                
                int bidCount = bids.size();
                
                if (bidCount > 0) {
                    out.println("<div class='bid-count'>Total Bids: " + bidCount + "</div>");
                    out.println("<table>");
                    out.println("<tr>");
                    out.println("<th>Rank</th>");
                    out.println("<th>Bidder</th>");
                    out.println("<th>Amount</th>");
                    out.println("<th>Time</th>");
                    out.println("<th>Type</th>");
                    out.println("</tr>");
                    
                    int rank = 1;
                    double highestBid = (Double) bids.get(0).get("amount");
                    
                    for (java.util.HashMap<String, Object> bid : bids) {
                        double amount = (Double) bid.get("amount");
                        boolean isHighest = (amount == highestBid);
                        String rowClass = isHighest ? "highest-bid" : "";
                        
                        out.println("<tr class='" + rowClass + "'>");
                        out.println("<td>" + rank + "</td>");
                        
                        String fullName = (String) bid.get("full_name");
                        out.println("<td>" + bid.get("username") + 
                                   (fullName != null ? " (" + fullName + ")" : "") + 
                                   "</td>");
                        out.println("<td>$" + String.format("%.2f", amount) + "</td>");
                        out.println("<td>" + sdf.format((Timestamp) bid.get("time")) + "</td>");
                        
                        String bidType = "Manual";
                        if ((Boolean) bid.get("is_autobid")) {
                            bidType = "<span class='autobid-badge'>Auto</span>";
                            if (bid.get("autobid_limit") != null) {
                                bidType += " (Limit: $" + String.format("%.2f", (Double) bid.get("autobid_limit")) + ")";
                            }
                        }
                        out.println("<td>" + bidType + "</td>");
                        out.println("</tr>");
                        
                        rank++;
                    }
                    
                    out.println("</table>");
                } else {
                    out.println("<div class='no-bids'>No bids have been placed on this auction yet.</div>");
                }
            } else {
                out.println("<div class='error'>Auction not found.</div>");
            }
            
        } catch (Exception e) {
            out.println("<div class='error'>Error loading bid history: " + e.getMessage() + "</div>");
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        %>
        
        <a href="browseAuctions.jsp" class="back-link">Back to Browse</a>
    </div>
</body>
</html>
