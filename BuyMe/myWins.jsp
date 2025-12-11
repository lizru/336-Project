<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<!DOCTYPE html>
<html>
<head>
    <title>My Wins - BuyMe</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="container">
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String username = (String) session.getAttribute("user");
%>

<h2>My Wins</h2>
<p>Items you've won in closed auctions</p>
<a href="success.jsp">Home</a> | <a href="viewAuctions.jsp">View Active Auctions</a>
<hr>

<%
    Connection con = null;
    PreparedStatement pst = null;
    ResultSet rs = null;
    
    // FIRST: Automatically close any expired auctions before showing wins
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/BuyMe", "root", "Linuxfs123!");
        con.setAutoCommit(false);
        
        // Find all auctions that have ended but are still marked as active
        pst = con.prepareStatement(
            "SELECT a.auction_id, a.item_id, a.min_price " +
            "FROM auction a " +
            "WHERE a.auction_status = 'active' AND a.end_time <= NOW()"
        );
        rs = pst.executeQuery();
        
        List<Map<String, Object>> expiredAuctions = new ArrayList<>();
        while (rs.next()) {
            Map<String, Object> auction = new HashMap<>();
            auction.put("auction_id", rs.getInt("auction_id"));
            auction.put("item_id", rs.getInt("item_id"));
            auction.put("min_price", rs.getDouble("min_price"));
            expiredAuctions.add(auction);
        }
        rs.close();
        pst.close();
        
        // Process each expired auction
        for (Map<String, Object> auction : expiredAuctions) {
            int auctionId = (Integer) auction.get("auction_id");
            int itemId = (Integer) auction.get("item_id");
            double minPrice = (Double) auction.get("min_price");
            
            // Get highest bid for this auction
            pst = con.prepareStatement(
                "SELECT b.user_id, b.amount " +
                "FROM bid b " +
                "WHERE b.auction_id = ? AND b.item_id = ? " +
                "ORDER BY b.amount DESC, b.time ASC " +
                "LIMIT 1"
            );
            pst.setInt(1, auctionId);
            pst.setInt(2, itemId);
            rs = pst.executeQuery();
            
            if (rs.next()) {
                int winnerId = rs.getInt("user_id");
                double winningBid = rs.getDouble("amount");
                
                // Check if winning bid meets reserve price
                if (winningBid >= minPrice) {
                    rs.close();
                    pst.close();
                    
                    // Check if already in buys table
                    pst = con.prepareStatement("SELECT * FROM buys WHERE item_id = ?");
                    pst.setInt(1, itemId);
                    ResultSet buyCheck = pst.executeQuery();
                    
                    if (!buyCheck.next()) {
                        buyCheck.close();
                        pst.close();
                        
                        // Insert winner
                        pst = con.prepareStatement("INSERT INTO buys (user_id, item_id) VALUES (?, ?)");
                        pst.setInt(1, winnerId);
                        pst.setInt(2, itemId);
                        pst.executeUpdate();
                        pst.close();
                    } else {
                        buyCheck.close();
                        pst.close();
                    }
                } else {
                    rs.close();
                    pst.close();
                }
            } else {
                rs.close();
                pst.close();
            }
            
            // Mark auction as closed
            pst = con.prepareStatement("UPDATE auction SET auction_status = 'closed' WHERE auction_id = ? AND item_id = ?");
            pst.setInt(1, auctionId);
            pst.setInt(2, itemId);
            pst.executeUpdate();
            pst.close();
        }
        
        con.commit();
        
    } catch (Exception e) {
        if (con != null) {
            try { con.rollback(); } catch (SQLException se) {}
        }
        // Silently handle errors, don't show to user
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pst != null) try { pst.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
    
    // NOW: Show the user's wins
    con = null;
    pst = null;
    rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/BuyMe", "root", "Linuxfs123!");
        
        // Get current user's ID
        pst = con.prepareStatement("SELECT user_id FROM user WHERE username = ?");
        pst.setString(1, username);
        rs = pst.executeQuery();
        
        if (!rs.next()) {
            out.println("<p>User not found.</p>");
            return;
        }
        
        int userId = rs.getInt("user_id");
        rs.close();
        pst.close();
        
        // Get all items this user won (items in buys table where they are the buyer)
        pst = con.prepareStatement(
            "SELECT i.item_id, i.title, i.make, i.model, i.year, i.mileage, i.color, i.item_condition, " +
            "sc.sub_name, a.auction_id, a.end_time, " +
            "COALESCE(MAX(b.amount), a.start_price) as winning_bid, " +
            "s.user_id as seller_id, u.username as seller_name " +
            "FROM buys bx " +
            "JOIN item i ON bx.item_id = i.item_id " +
            "JOIN auction a ON a.item_id = i.item_id " +
            "JOIN sub_category sc ON i.sub_category_id = sc.sub_category_id " +
            "LEFT JOIN bid b ON b.item_id = i.item_id AND b.auction_id = a.auction_id " +
            "JOIN sells s ON s.item_id = i.item_id " +
            "JOIN user u ON s.user_id = u.user_id " +
            "WHERE bx.user_id = ? AND a.auction_status = 'closed' " +
            "GROUP BY i.item_id, i.title, i.make, i.model, i.year, i.mileage, i.color, i.item_condition, " +
            "sc.sub_name, a.auction_id, a.end_time, s.user_id, u.username " +
            "ORDER BY a.end_time DESC"
        );
        pst.setInt(1, userId);
        rs = pst.executeQuery();
        
        boolean hasWins = false;
        
        out.println("<table>");
        out.println("<tr>");
        out.println("<th>Item</th>");
        out.println("<th>Category</th>");
        out.println("<th>Make</th>");
        out.println("<th>Model</th>");
        out.println("<th>Year</th>");
        out.println("<th>Mileage</th>");
        out.println("<th>Color</th>");
        out.println("<th>Condition</th>");
        out.println("<th>Winning Bid</th>");
        out.println("<th>Seller</th>");
        out.println("<th>Auction Ended</th>");
        out.println("</tr>");
        
        while (rs.next()) {
            hasWins = true;
            out.println("<tr>");
            out.println("<td><b>" + rs.getString("title") + "</b></td>");
            out.println("<td>" + rs.getString("sub_name") + "</td>");
            out.println("<td>" + rs.getString("make") + "</td>");
            out.println("<td>" + rs.getString("model") + "</td>");
            out.println("<td>" + rs.getInt("year") + "</td>");
            out.println("<td>" + String.format("%,d", rs.getInt("mileage")) + "</td>");
            out.println("<td>" + rs.getString("color") + "</td>");
            out.println("<td>" + rs.getString("item_condition") + "</td>");
            out.println("<td class='win-amount'>$" + String.format("%.2f", rs.getDouble("winning_bid")) + "</td>");
            out.println("<td>" + rs.getString("seller_name") + "</td>");
            out.println("<td>" + rs.getTimestamp("end_time") + "</td>");
            out.println("</tr>");
        }
        
        out.println("</table>");
        
        if (!hasWins) {
            out.println("<p class='no-wins'>You haven't won any auctions yet. Keep bidding!</p>");
        }
        
    } catch (Exception e) {
        out.println("<p style='color: red;'>Error: " + e.getMessage() + "</p>");
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pst != null) try { pst.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
%>

</div>
</body>
</html>
