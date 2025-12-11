<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>User Auction History - BuyMe</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 1200px;
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
        .user-info {
            background-color: #f9f9f9;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .user-info h2 {
            margin-top: 0;
            color: #4CAF50;
        }
        .filter-section {
            margin: 20px 0;
            padding: 15px;
            background-color: #f0f0f0;
            border-radius: 5px;
        }
        .filter-section label {
            margin-right: 10px;
            font-weight: bold;
        }
        .filter-section select {
            padding: 8px;
            border-radius: 4px;
            border: 1px solid #ddd;
            margin-right: 10px;
        }
        .filter-section button {
            padding: 8px 15px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .filter-section button:hover {
            background-color: #45a049;
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
        .auction-link {
            color: #2196F3;
            text-decoration: none;
        }
        .auction-link:hover {
            text-decoration: underline;
        }
        .status-active {
            color: #4CAF50;
            font-weight: bold;
        }
        .status-closed {
            color: #f44336;
        }
        .won-badge {
            background-color: #FFD700;
            color: #333;
            padding: 3px 8px;
            border-radius: 3px;
            font-size: 0.85em;
            font-weight: bold;
        }
        .selling-badge {
            background-color: #9C27B0;
            color: white;
            padding: 3px 8px;
            border-radius: 3px;
            font-size: 0.85em;
            font-weight: bold;
        }
        .no-auctions {
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
        .stats {
            display: flex;
            gap: 20px;
            margin: 20px 0;
        }
        .stat-box {
            flex: 1;
            padding: 15px;
            background-color: #e3f2fd;
            border-radius: 5px;
            text-align: center;
        }
        .stat-number {
            font-size: 2em;
            font-weight: bold;
            color: #1976D2;
        }
        .stat-label {
            color: #666;
            margin-top: 5px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>User Auction History</h1>
        
        <%
        String username = request.getParameter("username");
        String viewType = request.getParameter("view");
        
        // Default to current user if logged in and no username specified
        if (username == null && session.getAttribute("user") != null) {
            username = (String) session.getAttribute("user");
        }
        
        if (username == null) {
            out.println("<div class='error'>Error: No username specified.</div>");
            out.println("<a href='success.jsp' class='back-link'>Back to Dashboard</a>");
            return;
        }
        
        if (viewType == null) {
            viewType = "all";
        }
        
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/BuyMe", "root", "Linuxfs123!");
            
            // Get user details
            String userQuery = "SELECT * FROM user WHERE username = ?";
            ps = con.prepareStatement(userQuery);
            ps.setString(1, username);
            rs = ps.executeQuery();
            
            if (!rs.next()) {
                out.println("<div class='error'>User not found.</div>");
                out.println("<a href='browseAuctions.jsp' class='back-link'>Back to Browse</a>");
                return;
            }
            
            int userId = rs.getInt("user_id");
            String fullName = rs.getString("full_name");
            String userRole = rs.getString("user_role");
            
            rs.close();
            ps.close();
        %>
        
        <div class="user-info">
            <h2><%= username %></h2>
            <div><strong>Full Name:</strong> <%= fullName != null ? fullName : "N/A" %></div>
            <div><strong>Role:</strong> <%= userRole %></div>
        </div>
        
        <%
            // Get statistics
            String statsQuery = "SELECT " +
                               "(SELECT COUNT(DISTINCT auction_id) FROM bid WHERE user_id = ?) as total_bids, " +
                               "(SELECT COUNT(*) FROM sells WHERE user_id = ?) as total_selling, " +
                               "(SELECT COUNT(*) FROM buys WHERE user_id = ?) as total_won";
            ps = con.prepareStatement(statsQuery);
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            ps.setInt(3, userId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
        %>
        
        <div class="stats">
            <div class="stat-box">
                <div class="stat-number"><%= rs.getInt("total_bids") %></div>
                <div class="stat-label">Auctions Bid On</div>
            </div>
            <div class="stat-box">
                <div class="stat-number"><%= rs.getInt("total_selling") %></div>
                <div class="stat-label">Auctions Selling</div>
            </div>
            <div class="stat-box">
                <div class="stat-number"><%= rs.getInt("total_won") %></div>
                <div class="stat-label">Auctions Won</div>
            </div>
        </div>
        
        <%
            }
            rs.close();
            ps.close();
        %>
        
        <div class="filter-section">
            <form method="get" action="viewUserAuctions.jsp">
                <input type="hidden" name="username" value="<%= username %>">
                <label>View:</label>
                <select name="view" onchange="this.form.submit()">
                    <option value="all" <%= viewType.equals("all") ? "selected" : "" %>>All Auctions</option>
                    <option value="bidding" <%= viewType.equals("bidding") ? "selected" : "" %>>Bidding On</option>
                    <option value="selling" <%= viewType.equals("selling") ? "selected" : "" %>>Selling</option>
                    <option value="won" <%= viewType.equals("won") ? "selected" : "" %>>Won</option>
                </select>
            </form>
        </div>
        
        <%
            String auctionQuery = "";
            SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy HH:mm");
            
            if (viewType.equals("bidding")) {
                // Auctions user has bid on
                auctionQuery = "SELECT DISTINCT a.*, i.title, i.make, i.model, i.year, i.color, " +
                              "u.username as seller_name, " +
                              "(SELECT MAX(amount) FROM bid WHERE auction_id = a.auction_id AND item_id = a.item_id) as current_bid, " +
                              "(SELECT MAX(amount) FROM bid WHERE auction_id = a.auction_id AND item_id = a.item_id AND user_id = ?) as my_highest_bid, " +
                              "(SELECT COUNT(*) FROM bid WHERE auction_id = a.auction_id AND item_id = a.item_id) as total_bids " +
                              "FROM auction a " +
                              "JOIN item i ON a.item_id = i.item_id " +
                              "JOIN sells s ON i.item_id = s.item_id " +
                              "JOIN user u ON s.user_id = u.user_id " +
                              "JOIN bid b ON a.auction_id = b.auction_id AND a.item_id = b.item_id " +
                              "WHERE b.user_id = ? " +
                              "ORDER BY a.start_time DESC";
                ps = con.prepareStatement(auctionQuery);
                ps.setInt(1, userId);
                ps.setInt(2, userId);
                
            } else if (viewType.equals("selling")) {
                // Auctions user is selling
                auctionQuery = "SELECT a.*, i.title, i.make, i.model, i.year, i.color, " +
                              "(SELECT MAX(amount) FROM bid WHERE auction_id = a.auction_id AND item_id = a.item_id) as current_bid, " +
                              "(SELECT COUNT(*) FROM bid WHERE auction_id = a.auction_id AND item_id = a.item_id) as total_bids " +
                              "FROM auction a " +
                              "JOIN item i ON a.item_id = i.item_id " +
                              "JOIN sells s ON i.item_id = s.item_id " +
                              "WHERE s.user_id = ? " +
                              "ORDER BY a.start_time DESC";
                ps = con.prepareStatement(auctionQuery);
                ps.setInt(1, userId);
                
            } else if (viewType.equals("won")) {
                // Auctions user has won
                auctionQuery = "SELECT a.*, i.title, i.make, i.model, i.year, i.color, " +
                              "u.username as seller_name, " +
                              "(SELECT MAX(amount) FROM bid WHERE auction_id = a.auction_id AND item_id = a.item_id) as winning_bid " +
                              "FROM auction a " +
                              "JOIN item i ON a.item_id = i.item_id " +
                              "JOIN sells s ON i.item_id = s.item_id " +
                              "JOIN user u ON s.user_id = u.user_id " +
                              "JOIN buys buy ON i.item_id = buy.item_id " +
                              "WHERE buy.user_id = ? " +
                              "ORDER BY a.end_time DESC";
                ps = con.prepareStatement(auctionQuery);
                ps.setInt(1, userId);
                
            } else {
                // All auctions (bidding or selling)
                auctionQuery = "SELECT DISTINCT a.*, i.title, i.make, i.model, i.year, i.color, " +
                              "u.username as seller_name, " +
                              "(SELECT MAX(amount) FROM bid WHERE auction_id = a.auction_id AND item_id = a.item_id) as current_bid, " +
                              "(SELECT COUNT(*) FROM bid WHERE auction_id = a.auction_id AND item_id = a.item_id) as total_bids, " +
                              "CASE WHEN s.user_id = ? THEN 'selling' ELSE 'bidding' END as participation_type " +
                              "FROM auction a " +
                              "JOIN item i ON a.item_id = i.item_id " +
                              "JOIN sells s ON i.item_id = s.item_id " +
                              "JOIN user u ON s.user_id = u.user_id " +
                              "LEFT JOIN bid b ON a.auction_id = b.auction_id AND a.item_id = b.item_id " +
                              "WHERE s.user_id = ? OR b.user_id = ? " +
                              "ORDER BY a.start_time DESC";
                ps = con.prepareStatement(auctionQuery);
                ps.setInt(1, userId);
                ps.setInt(2, userId);
                ps.setInt(3, userId);
            }
            
            rs = ps.executeQuery();
            
            // Collect all results first
            java.util.ArrayList<java.util.HashMap<String, Object>> results = new java.util.ArrayList<>();
            while (rs.next()) {
                java.util.HashMap<String, Object> row = new java.util.HashMap<>();
                row.put("auction_id", rs.getInt("auction_id"));
                row.put("item_id", rs.getInt("item_id"));
                row.put("title", rs.getString("title"));
                row.put("make", rs.getString("make"));
                row.put("model", rs.getString("model"));
                row.put("year", rs.getInt("year"));
                row.put("color", rs.getString("color"));
                if (!viewType.equals("selling")) {
                    row.put("seller_name", rs.getString("seller_name"));
                }
                if (viewType.equals("won")) {
                    row.put("winning_bid", rs.getDouble("winning_bid"));
                } else {
                    row.put("current_bid", rs.getDouble("current_bid"));
                }
                if (viewType.equals("bidding")) {
                    row.put("my_highest_bid", rs.getDouble("my_highest_bid"));
                }
                if (!viewType.equals("won")) {
                    row.put("total_bids", rs.getInt("total_bids"));
                }
                row.put("start_time", rs.getTimestamp("start_time"));
                row.put("end_time", rs.getTimestamp("end_time"));
                row.put("auction_status", rs.getString("auction_status"));
                row.put("start_price", rs.getDouble("start_price"));
                if (viewType.equals("all")) {
                    row.put("participation_type", rs.getString("participation_type"));
                }
                results.add(row);
            }
            
            if (results.size() > 0) {
                out.println("<table>");
                out.println("<tr>");
                out.println("<th>Auction</th>");
                out.println("<th>Vehicle</th>");
                
                if (!viewType.equals("selling")) {
                    out.println("<th>Seller</th>");
                }
                
                out.println("<th>Current Bid</th>");
                
                if (viewType.equals("bidding")) {
                    out.println("<th>My Highest Bid</th>");
                }
                
                if (viewType.equals("won")) {
                    out.println("<th>Winning Bid</th>");
                }
                
                if (!viewType.equals("won")) {
                    out.println("<th>Total Bids</th>");
                }
                
                out.println("<th>Start Time</th>");
                out.println("<th>End Time</th>");
                out.println("<th>Status</th>");
                
                if (viewType.equals("all")) {
                    out.println("<th>Type</th>");
                }
                
                out.println("<th>Actions</th>");
                out.println("</tr>");
                
                for (java.util.HashMap<String, Object> row : results) {
                    int auctionId = (Integer) row.get("auction_id");
                    int itemId = (Integer) row.get("item_id");
                    String title = (String) row.get("title");
                    String vehicle = row.get("year") + " " + row.get("make") + " " + row.get("model");
                    String status = (String) row.get("auction_status");
                    
                    out.println("<tr>");
                    out.println("<td>#" + auctionId + "</td>");
                    out.println("<td>" + title + "<br><small>" + vehicle + "</small></td>");
                    
                    if (!viewType.equals("selling")) {
                        out.println("<td>" + row.get("seller_name") + "</td>");
                    }
                    
                    double startPrice = (Double) row.get("start_price");
                    if (viewType.equals("won")) {
                        double winningBid = (Double) row.get("winning_bid");
                        if (winningBid > 0) {
                            out.println("<td>$" + String.format("%.2f", winningBid) + "</td>");
                        } else {
                            out.println("<td>$" + String.format("%.2f", startPrice) + " (Start)</td>");
                        }
                    } else {
                        double currentBid = (Double) row.get("current_bid");
                        if (currentBid > 0) {
                            out.println("<td>$" + String.format("%.2f", currentBid) + "</td>");
                        } else {
                            out.println("<td>$" + String.format("%.2f", startPrice) + " (Start)</td>");
                        }
                    }
                    
                    if (viewType.equals("bidding")) {
                        double myBid = (Double) row.get("my_highest_bid");
                        double currentBid = (Double) row.get("current_bid");
                        String bidClass = (myBid >= currentBid) ? "won-badge" : "";
                        out.println("<td class='" + bidClass + "'>$" + String.format("%.2f", myBid) + "</td>");
                    }
                    
                    if (viewType.equals("won")) {
                        out.println("<td class='won-badge'>$" + String.format("%.2f", (Double) row.get("winning_bid")) + "</td>");
                    }
                    
                    if (!viewType.equals("won")) {
                        out.println("<td>" + row.get("total_bids") + "</td>");
                    }
                    
                    out.println("<td>" + sdf.format((Timestamp) row.get("start_time")) + "</td>");
                    out.println("<td>" + sdf.format((Timestamp) row.get("end_time")) + "</td>");
                    
                    String statusClass = status.equals("active") ? "status-active" : "status-closed";
                    out.println("<td class='" + statusClass + "'>" + status + "</td>");
                    
                    if (viewType.equals("all")) {
                        String participationType = (String) row.get("participation_type");
                        String badge = participationType.equals("selling") ? "selling-badge" : "";
                        out.println("<td><span class='" + badge + "'>" + participationType + "</span></td>");
                    }
                    
                    out.println("<td>");
                    out.println("<a href='viewBidHistory.jsp?auction_id=" + auctionId + "&item_id=" + itemId + "' class='auction-link'>View Bids</a>");
                    if (status.equals("active") && !viewType.equals("selling")) {
                        out.println(" | <a href='placeBid.jsp?auction_id=" + auctionId + "&item_id=" + itemId + "' class='auction-link'>Place Bid</a>");
                    }
                    out.println("</td>");
                    out.println("</tr>");
                }
                
                out.println("</table>");
            } else {
                out.println("<div class='no-auctions'>No auctions found for this view.</div>");
            }
            
        } catch (Exception e) {
            out.println("<div class='error'>Error loading auction history: " + e.getMessage() + "</div>");
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
        
        <a href="success.jsp" class="back-link">Back to Dashboard</a>
    </div>
</body>
</html>
