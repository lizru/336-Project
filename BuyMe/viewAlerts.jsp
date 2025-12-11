<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
    <title>My Bid Alerts - BuyMe</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .alert-box {
            border: 1px solid #ddd;
            padding: 15px;
            margin-bottom: 15px;
            border-radius: 5px;
        }
        .alert-outbid {
            background-color: #fff3cd;
            border-left: 4px solid #ffc107;
        }
        .alert-limit {
            background-color: #f8d7da;
            border-left: 4px solid #dc3545;
        }
        .alert-read {
            background-color: #f8f9fa;
            opacity: 0.7;
        }
        .alert-header {
            font-weight: bold;
            font-size: 16px;
            margin-bottom: 8px;
        }
        .alert-time {
            color: #666;
            font-size: 13px;
            margin-bottom: 8px;
        }
        .alert-message {
            margin-bottom: 10px;
        }
        .alert-actions {
            margin-top: 10px;
        }
        .mark-read-btn {
            background-color: #28a745;
            color: white;
            padding: 5px 10px;
            border: none;
            cursor: pointer;
            border-radius: 3px;
        }
        .view-auction-btn {
            background-color: #667eea;
            color: white;
            padding: 5px 10px;
            text-decoration: none;
            border-radius: 3px;
            display: inline-block;
        }
        .no-alerts {
            text-align: center;
            padding: 40px;
            color: #666;
        }
        .unread-badge {
            background-color: #dc3545;
            color: white;
            padding: 2px 6px;
            border-radius: 10px;
            font-size: 12px;
            margin-left: 10px;
        }
    </style>
</head>
<body>
<div class="container">
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    Integer userId = (Integer) session.getAttribute("user_id");
    if (userId == null) {
        out.println("<h2>Error</h2>");
        out.println("<p>User ID not found. Please log in again.</p>");
        return;
    }
    
    // Handle mark as read action
    String markReadId = request.getParameter("mark_read");
    if (markReadId != null) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/BuyMe", "root", "Linuxfs123!");
            PreparedStatement pst = con.prepareStatement("UPDATE bid_alert SET is_read = true WHERE alert_id = ? AND user_id = ?");
            pst.setInt(1, Integer.parseInt(markReadId));
            pst.setInt(2, userId);
            pst.executeUpdate();
            pst.close();
            con.close();
            response.sendRedirect("viewAlerts.jsp");
            return;
        } catch (Exception e) {
            out.println("<p style='color:red;'>Error marking alert as read: " + e.getMessage() + "</p>");
        }
    }
    
    // Handle mark all as read
    if ("all".equals(request.getParameter("mark_all_read"))) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/BuyMe", "root", "Linuxfs123!");
            PreparedStatement pst = con.prepareStatement("UPDATE bid_alert SET is_read = true WHERE user_id = ? AND is_read = false");
            pst.setInt(1, userId);
            int updated = pst.executeUpdate();
            pst.close();
            con.close();
            out.println("<p style='color:green;'>Marked " + updated + " alerts as read.</p>");
        } catch (Exception e) {
            out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
        }
    }
%>

<%
    Connection con = null;
    PreparedStatement pst = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/BuyMe", "root", "Linuxfs123!");
        
        // Get unread count
        pst = con.prepareStatement("SELECT COUNT(*) as unread_count FROM bid_alert WHERE user_id = ? AND is_read = false");
        pst.setInt(1, userId);
        rs = pst.executeQuery();
        rs.next();
        int unreadCount = rs.getInt("unread_count");
        rs.close();
        pst.close();
%>

<h2>My Bid Alerts 
<% if (unreadCount > 0) { %>
    <span class="unread-badge"><%= unreadCount %> New</span>
<% } %>
</h2>

<a href="success.jsp">Back to Home</a> | <a href="viewAuctions.jsp">View All Auctions</a> | <a href="logout.jsp">Logout</a>
<% if (unreadCount > 0) { %>
    | <a href="viewAlerts.jsp?mark_all_read=all">Mark All as Read</a>
<% } %>
<hr>

<%
        // Get all alerts for this user
        pst = con.prepareStatement(
            "SELECT a.alert_id, a.auction_id, a.item_id, a.alert_type, a.message, " +
            "a.new_bid_amount, a.date_created, a.is_read, i.title " +
            "FROM bid_alert a " +
            "JOIN item i ON a.item_id = i.item_id " +
            "WHERE a.user_id = ? " +
            "ORDER BY a.is_read ASC, a.date_created DESC"
        );
        pst.setInt(1, userId);
        rs = pst.executeQuery();
        
        boolean hasAlerts = false;
        
        while (rs.next()) {
            hasAlerts = true;
            int alertId = rs.getInt("alert_id");
            int auctionId = rs.getInt("auction_id");
            int itemId = rs.getInt("item_id");
            String alertType = rs.getString("alert_type");
            String message = rs.getString("message");
            double newBidAmount = rs.getDouble("new_bid_amount");
            Timestamp dateCreated = rs.getTimestamp("date_created");
            boolean isRead = rs.getBoolean("is_read");
            String itemTitle = rs.getString("title");
            
            String alertClass = "alert-box ";
            if ("outbid".equals(alertType)) {
                alertClass += "alert-outbid";
            } else if ("limit_exceeded".equals(alertType)) {
                alertClass += "alert-limit";
            }
            if (isRead) {
                alertClass += " alert-read";
            }
            
            out.println("<div class='" + alertClass + "'>");
            
            if ("outbid".equals(alertType)) {
                out.println("<div class='alert-header'>&#9888; You've Been Outbid!</div>");
            } else if ("limit_exceeded".equals(alertType)) {
                out.println("<div class='alert-header'>&#128683; Autobid Limit Exceeded</div>");
            }
            
            out.println("<div class='alert-time'>" + dateCreated + (isRead ? " (Read)" : " (New)") + "</div>");
            out.println("<div class='alert-message'>");
            out.println("<strong>Item:</strong> " + itemTitle + " (Auction #" + auctionId + ")<br>");
            out.println("<strong>Message:</strong> " + message);
            out.println("</div>");
            
            out.println("<div class='alert-actions'>");
            out.println("<a href='placeBid.jsp?auction_id=" + auctionId + "&item_id=" + itemId + "' class='view-auction-btn'>View Auction & Place Bid</a> ");
            
            if (!isRead) {
                out.println("<form method='GET' style='display:inline; margin-left:10px;'>");
                out.println("<input type='hidden' name='mark_read' value='" + alertId + "'>");
                out.println("<button type='submit' class='mark-read-btn'>Mark as Read</button>");
                out.println("</form>");
            }
            
            out.println("</div>");
            out.println("</div>");
        }
        
        if (!hasAlerts) {
            out.println("<div class='no-alerts'>");
            out.println("<h3>No Alerts</h3>");
            out.println("<p>You don't have any bid alerts yet.</p>");
            out.println("<p>When someone outbids you or your autobid limit is exceeded, you'll see notifications here.</p>");
            out.println("</div>");
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<p style='color:red;'>Error loading alerts: " + e.getMessage() + "</p>");
    } finally {
        if (rs != null) try { rs.close(); } catch(SQLException e) {}
        if (pst != null) try { pst.close(); } catch(SQLException e) {}
        if (con != null) try { con.close(); } catch(SQLException e) {}
    }
%>

</div>
</body>
</html>
