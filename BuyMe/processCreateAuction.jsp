<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
    <title>Processing Auction</title>
</head>
<body>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String username = (String) session.getAttribute("user");
    
    // Get form parameters
    String title = request.getParameter("title");
    String subCategoryId = request.getParameter("sub_category_id");
    String make = request.getParameter("make");
    String model = request.getParameter("model");
    String year = request.getParameter("year");
    String mileage = request.getParameter("mileage");
    String color = request.getParameter("color");
    String condition = request.getParameter("condition");
    String description = request.getParameter("description");
    String startPrice = request.getParameter("start_price");
    String minPrice = request.getParameter("min_price");
    String increment = request.getParameter("increment");
    String endTime = request.getParameter("end_time");
    
    // Debug output
    out.println("<h3>Debug: Form Parameters Received</h3>");
    out.println("<p>Make: [" + make + "]</p>");
    out.println("<p>Model: [" + model + "]</p>");
    out.println("<p>Year: [" + year + "]</p>");
    out.println("<p>Mileage: [" + mileage + "]</p>");
    out.println("<p>Color: [" + color + "]</p>");
    out.println("<p>Description: [" + description + "]</p>");
    out.println("<hr>");
    
    Connection con = null;
    PreparedStatement pst = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/BuyMe", "root", "Linuxfs123!");
        con.setAutoCommit(false);
        
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
        
        // Get next item_id
        pst = con.prepareStatement("SELECT COALESCE(MAX(item_id), 0) + 1 as next_id FROM item");
        rs = pst.executeQuery();
        rs.next();
        int itemId = rs.getInt("next_id");
        rs.close();
        pst.close();
        
        // Insert item
        pst = con.prepareStatement("INSERT INTO item (item_id, title, item_description, item_condition, date_posted, sub_category_id, make, model, year, mileage, color) VALUES (?, ?, ?, ?, CURDATE(), ?, ?, ?, ?, ?, ?)");
        pst.setInt(1, itemId);
        pst.setString(2, title);
        pst.setString(3, description);
        pst.setString(4, condition);
        pst.setInt(5, Integer.parseInt(subCategoryId));
        pst.setString(6, make);
        pst.setString(7, model);
        pst.setInt(8, Integer.parseInt(year));
        pst.setInt(9, Integer.parseInt(mileage));
        pst.setString(10, color);
        pst.executeUpdate();
        pst.close();
        
        // Get next auction_id
        pst = con.prepareStatement("SELECT COALESCE(MAX(auction_id), 0) + 1 as next_id FROM auction");
        rs = pst.executeQuery();
        rs.next();
        int auctionId = rs.getInt("next_id");
        rs.close();
        pst.close();
        
        // Insert auction
        pst = con.prepareStatement("INSERT INTO auction (auction_id, item_id, start_price, min_price, increment, start_time, end_time, auction_status) VALUES (?, ?, ?, ?, ?, NOW(), ?, 'active')");
        pst.setInt(1, auctionId);
        pst.setInt(2, itemId);
        pst.setDouble(3, Double.parseDouble(startPrice));
        pst.setDouble(4, Double.parseDouble(minPrice));
        pst.setDouble(5, Double.parseDouble(increment));
        pst.setString(6, endTime.replace("T", " ") + ":00");
        pst.executeUpdate();
        pst.close();
        
        // Link seller to item
        pst = con.prepareStatement("INSERT INTO sells (user_id, item_id) VALUES (?, ?)");
        pst.setInt(1, userId);
        pst.setInt(2, itemId);
        pst.executeUpdate();
        pst.close();
        
        con.commit();
        
        out.println("<h2>Auction Created Successfully!</h2>");
        out.println("<p>Your vehicle auction has been created.</p>");
        out.println("<p>Auction ID: " + auctionId + "</p>");
        out.println("<p>Item ID: " + itemId + "</p>");
        out.println("<p><a href='viewAuctions.jsp'>View All Auctions</a></p>");
        out.println("<p><a href='createAuction.jsp'>Create Another Auction</a></p>");
        out.println("<p><a href='success.jsp'>Back to Home</a></p>");
        
    } catch (Exception e) {
        if (con != null) {
            try {
                con.rollback();
            } catch (SQLException se) {}
        }
        out.println("<h2>Error Creating Auction</h2>");
        out.println("<p>" + e.getMessage() + "</p>");
        out.println("<p><a href='createAuction.jsp'>Try Again</a></p>");
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch(SQLException e) {}
        if (pst != null) try { pst.close(); } catch(SQLException e) {}
        if (con != null) try { con.setAutoCommit(true); con.close(); } catch(SQLException e) {}
    }
%>
</body>
</html>
