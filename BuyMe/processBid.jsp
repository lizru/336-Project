<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
    <title>Processing Bid</title>
</head>
<body>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String username = (String) session.getAttribute("user");
    String auctionIdStr = request.getParameter("auction_id");
    String itemIdStr = request.getParameter("item_id");
    String bidAmountStr = request.getParameter("bid_amount");
    String bidType = request.getParameter("bid_type");
    String autobidLimitStr = request.getParameter("autobid_limit");
    
    Connection con = null;
    PreparedStatement pst = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/BuyMe", "root", "Linuxfs123!");
        con.setAutoCommit(false);
        
        int auctionId = Integer.parseInt(auctionIdStr);
        int itemId = Integer.parseInt(itemIdStr);
        double bidAmount = Double.parseDouble(bidAmountStr);
        boolean isAutoBid = "auto".equals(bidType);
        Double autobidLimit = null;
        
        if (isAutoBid && autobidLimitStr != null && !autobidLimitStr.isEmpty()) {
            autobidLimit = Double.parseDouble(autobidLimitStr);
        }
        
        // Get user_id
        pst = con.prepareStatement("SELECT user_id FROM user WHERE username = ?");
        pst.setString(1, username);
        rs = pst.executeQuery();
        
        if (!rs.next()) {
            throw new Exception("User not found");
        }
        int userId = rs.getInt("user_id");
        rs.close();
        pst.close();
        
        // Get auction details and current highest bid
        pst = con.prepareStatement(
            "SELECT a.increment, a.end_time, a.auction_status, " +
            "COALESCE(MAX(b.amount), a.start_price) as current_price " +
            "FROM auction a " +
            "LEFT JOIN bid b ON a.auction_id = b.auction_id AND a.item_id = b.item_id " +
            "WHERE a.auction_id = ? AND a.item_id = ? " +
            "GROUP BY a.increment, a.end_time, a.auction_status"
        );
        pst.setInt(1, auctionId);
        pst.setInt(2, itemId);
        rs = pst.executeQuery();
        
        if (!rs.next()) {
            throw new Exception("Auction not found");
        }
        
        double increment = rs.getDouble("increment");
        Timestamp endTime = rs.getTimestamp("end_time");
        String auctionStatus = rs.getString("auction_status");
        double currentPrice = rs.getDouble("current_price");
        rs.close();
        pst.close();
        
        // Validate auction is still active
        if (!"active".equals(auctionStatus) || endTime.before(new Timestamp(System.currentTimeMillis()))) {
            throw new Exception("This auction has ended");
        }
        
        // Validate bid amount
        double minBid = currentPrice + increment;
        if (bidAmount < minBid) {
            throw new Exception("Bid must be at least $" + String.format("%.2f", minBid));
        }
        
        // Validate bid is in proper increments
        double amountAboveMin = bidAmount - minBid;
        if (amountAboveMin % increment != 0 && Math.abs(amountAboveMin % increment) > 0.01) {
            throw new Exception("Bid must be in increments of $" + String.format("%.2f", increment) + ". Next valid bids: $" + 
                              String.format("%.2f", minBid) + ", $" + String.format("%.2f", minBid + increment) + ", etc.");
        }
        
        // Get next bid_id for this auction
        pst = con.prepareStatement("SELECT COALESCE(MAX(bid_id), 0) + 1 as next_bid_id FROM bid WHERE auction_id = ? AND item_id = ?");
        pst.setInt(1, auctionId);
        pst.setInt(2, itemId);
        rs = pst.executeQuery();
        rs.next();
        int nextBidId = rs.getInt("next_bid_id");
        rs.close();
        pst.close();
        
        // Insert the bid
        pst = con.prepareStatement(
            "INSERT INTO bid (bid_id, auction_id, item_id, user_id, amount, time, is_autobid, autobid_limit) " +
            "VALUES (?, ?, ?, ?, ?, NOW(), ?, ?)"
        );
        pst.setInt(1, nextBidId);
        pst.setInt(2, auctionId);
        pst.setInt(3, itemId);
        pst.setInt(4, userId);
        pst.setDouble(5, bidAmount);
        pst.setBoolean(6, isAutoBid);
        if (autobidLimit != null) {
            pst.setDouble(7, autobidLimit);
        } else {
            pst.setNull(7, Types.DOUBLE);
        }
        pst.executeUpdate();
        pst.close();
        
        // If this is a manual bid, check if there are any active auto-bidders and trigger their auto-bid
        if (!isAutoBid) {
            // Find users with auto-bid who were previously highest bidder
            pst = con.prepareStatement(
                "SELECT DISTINCT b.user_id, b.autobid_limit " +
                "FROM bid b " +
                "WHERE b.auction_id = ? AND b.item_id = ? " +
                "AND b.is_autobid = true " +
                "AND b.autobid_limit IS NOT NULL " +
                "AND b.autobid_limit > ? " +
                "AND b.user_id != ?"
            );
            pst.setInt(1, auctionId);
            pst.setInt(2, itemId);
            pst.setDouble(3, bidAmount);
            pst.setInt(4, userId);
            rs = pst.executeQuery();
            
            // Process auto-bids
            while (rs.next()) {
                int autoBidUserId = rs.getInt("user_id");
                double autoBidLimit = rs.getDouble("autobid_limit");
                
                double newAutoBidAmount = bidAmount + increment;
                
                // Only place auto-bid if within limit
                if (newAutoBidAmount <= autoBidLimit) {
                    // Get next bid_id
                    PreparedStatement pst2 = con.prepareStatement("SELECT COALESCE(MAX(bid_id), 0) + 1 as next_bid_id FROM bid WHERE auction_id = ? AND item_id = ?");
                    pst2.setInt(1, auctionId);
                    pst2.setInt(2, itemId);
                    ResultSet rs2 = pst2.executeQuery();
                    rs2.next();
                    int autoBidId = rs2.getInt("next_bid_id");
                    rs2.close();
                    pst2.close();
                    
                    // Place auto-bid
                    pst2 = con.prepareStatement(
                        "INSERT INTO bid (bid_id, auction_id, item_id, user_id, amount, time, is_autobid, autobid_limit) " +
                        "VALUES (?, ?, ?, ?, ?, NOW(), true, ?)"
                    );
                    pst2.setInt(1, autoBidId);
                    pst2.setInt(2, auctionId);
                    pst2.setInt(3, itemId);
                    pst2.setInt(4, autoBidUserId);
                    pst2.setDouble(5, newAutoBidAmount);
                    pst2.setDouble(6, autoBidLimit);
                    pst2.executeUpdate();
                    pst2.close();
                    
                    out.println("<p><strong>Alert:</strong> An automatic bid of $" + String.format("%.2f", newAutoBidAmount) + " was placed by another bidder!</p>");
                }
            }
            rs.close();
            pst.close();
        }
        
        con.commit();
        
        out.println("<h2>Bid Placed Successfully!</h2>");
        out.println("<p>Your bid of $" + String.format("%.2f", bidAmount) + " has been recorded.</p>");
        if (isAutoBid && autobidLimit != null) {
            out.println("<p>Automatic bidding is active up to $" + String.format("%.2f", autobidLimit) + "</p>");
        }
        out.println("<p><a href='viewAuctions.jsp'>View All Auctions</a></p>");
        out.println("<p><a href='placeBid.jsp?auction_id=" + auctionId + "&item_id=" + itemId + "'>Place Another Bid</a></p>");
        out.println("<p><a href='success.jsp'>Back to Home</a></p>");
        
    } catch (Exception e) {
        if (con != null) {
            try {
                con.rollback();
            } catch (SQLException se) {}
        }
        out.println("<h2>Error Placing Bid</h2>");
        out.println("<p>" + e.getMessage() + "</p>");
        out.println("<p><a href='placeBid.jsp?auction_id=" + auctionIdStr + "&item_id=" + itemIdStr + "'>Try Again</a></p>");
        out.println("<p><a href='viewAuctions.jsp'>Back to Auctions</a></p>");
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch(SQLException e) {}
        if (pst != null) try { pst.close(); } catch(SQLException e) {}
        if (con != null) try { con.setAutoCommit(true); con.close(); } catch(SQLException e) {}
    }
%>
</body>
</html>
