<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<!DOCTYPE html>
<html>
<head>
    <title>Close Auctions</title>
</head>
<body>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<h2>Closing Expired Auctions</h2>
<a href="success.jsp">Home</a> | <a href="viewAuctions.jsp">View Auctions</a>
<hr>

<%
    Connection con = null;
    PreparedStatement pst = null;
    ResultSet rs = null;
    
    int closedCount = 0;
    int winnersFound = 0;
    int noWinnersCount = 0;
    List<String> messages = new ArrayList<>();
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/BuyMe", "root", "Linuxfs123!");
        con.setAutoCommit(false);
        
        // Find all auctions that have ended but are still marked as active
        pst = con.prepareStatement(
            "SELECT a.auction_id, a.item_id, i.title, a.min_price, a.end_time " +
            "FROM auction a " +
            "JOIN item i ON a.item_id = i.item_id " +
            "WHERE a.auction_status = 'active' AND a.end_time <= NOW()"
        );
        rs = pst.executeQuery();
        
        List<Map<String, Object>> expiredAuctions = new ArrayList<>();
        while (rs.next()) {
            Map<String, Object> auction = new HashMap<>();
            auction.put("auction_id", rs.getInt("auction_id"));
            auction.put("item_id", rs.getInt("item_id"));
            auction.put("title", rs.getString("title"));
            auction.put("min_price", rs.getDouble("min_price"));
            auction.put("end_time", rs.getTimestamp("end_time"));
            expiredAuctions.add(auction);
        }
        rs.close();
        pst.close();
        
        // Process each expired auction
        for (Map<String, Object> auction : expiredAuctions) {
            int auctionId = (Integer) auction.get("auction_id");
            int itemId = (Integer) auction.get("item_id");
            String title = (String) auction.get("title");
            double minPrice = (Double) auction.get("min_price");
            
            // Get highest bid for this auction
            pst = con.prepareStatement(
                "SELECT b.user_id, b.amount, u.username " +
                "FROM bid b " +
                "JOIN user u ON b.user_id = u.user_id " +
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
                String winnerUsername = rs.getString("username");
                rs.close();
                pst.close();
                
                // Check if winning bid meets reserve price
                if (winningBid >= minPrice) {
                    // Winner found - record in buys table
                    pst = con.prepareStatement("INSERT INTO buys (user_id, item_id) VALUES (?, ?)");
                    pst.setInt(1, winnerId);
                    pst.setInt(2, itemId);
                    try {
                        pst.executeUpdate();
                    } catch (SQLException e) {
                        // Item might already be in buys table, ignore
                    }
                    pst.close();
                    
                    messages.add("<p><strong>Auction #" + auctionId + " - " + title + ":</strong> SOLD to " + winnerUsername + " for $" + String.format("%.2f", winningBid) + "</p>");
                    winnersFound++;
                } else {
                    // Reserve price not met
                    messages.add("<p><strong>Auction #" + auctionId + " - " + title + ":</strong> Reserve price ($" + String.format("%.2f", minPrice) + ") not met. Highest bid was $" + String.format("%.2f", winningBid) + ". No winner.</p>");
                    noWinnersCount++;
                }
            } else {
                // No bids placed
                rs.close();
                pst.close();
                messages.add("<p><strong>Auction #" + auctionId + " - " + title + ":</strong> No bids were placed. No winner.</p>");
                noWinnersCount++;
            }
            
            // Update auction status to ended
            pst = con.prepareStatement("UPDATE auction SET auction_status = 'ended' WHERE auction_id = ? AND item_id = ?");
            pst.setInt(1, auctionId);
            pst.setInt(2, itemId);
            pst.executeUpdate();
            pst.close();
            
            closedCount++;
        }
        
        con.commit();
        
        out.println("<h3>Auction Closing Summary</h3>");
        out.println("<p>Total auctions closed: " + closedCount + "</p>");
        out.println("<p>Winners determined: " + winnersFound + "</p>");
        out.println("<p>No winner (reserve not met or no bids): " + noWinnersCount + "</p>");
        out.println("<hr>");
        
        if (closedCount > 0) {
            out.println("<h3>Details:</h3>");
            for (String message : messages) {
                out.println(message);
            }
        } else {
            out.println("<p>No auctions needed to be closed at this time.</p>");
        }
        
        out.println("<hr>");
        out.println("<p><a href='viewAuctions.jsp'>View All Auctions</a></p>");
        out.println("<p><a href='success.jsp'>Back to Home</a></p>");
        
    } catch (Exception e) {
        if (con != null) {
            try {
                con.rollback();
            } catch (SQLException se) {}
        }
        out.println("<h3>Error Closing Auctions</h3>");
        out.println("<p>" + e.getMessage() + "</p>");
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch(SQLException e) {}
        if (pst != null) try { pst.close(); } catch(SQLException e) {}
        if (con != null) try { con.setAutoCommit(true); con.close(); } catch(SQLException e) {}
    }
%>

</body>
</html>
