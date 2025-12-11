<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<!DOCTYPE html>
<html>
<head>
    <title>Browse Auctions - BuyMe</title>
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
    
    // Get filter parameters
    String makeFilter = request.getParameter("make") != null ? request.getParameter("make") : "";
    String modelFilter = request.getParameter("model") != null ? request.getParameter("model") : "";
    String minYearStr = request.getParameter("minYear");
    String maxYearStr = request.getParameter("maxYear");
    String maxMileageStr = request.getParameter("maxMileage");
    String colorFilter = request.getParameter("color") != null ? request.getParameter("color") : "";
    String categoryFilter = request.getParameter("category") != null ? request.getParameter("category") : "";
    String sortBy = request.getParameter("sortBy") != null ? request.getParameter("sortBy") : "ending";
    
    int minYear = 1900;
    int maxYear = 2025;
    int maxMileage = Integer.MAX_VALUE;
    
    if (minYearStr != null && !minYearStr.isEmpty()) {
        minYear = Integer.parseInt(minYearStr);
    }
    if (maxYearStr != null && !maxYearStr.isEmpty()) {
        maxYear = Integer.parseInt(maxYearStr);
    }
    if (maxMileageStr != null && !maxMileageStr.isEmpty()) {
        maxMileage = Integer.parseInt(maxMileageStr);
    }
%>

<h2>Browse Auctions</h2>
<p>Welcome, <%= username %>!</p>
<a href="success.jsp">Home</a> | <a href="viewAuctions.jsp">All Auctions</a> | <a href="myWins.jsp">My Wins</a> | <a href="viewUserAuctions.jsp">My Auction History</a>
<hr>

<!-- Search and Filter Form -->
<form method="GET" action="browseAuctions.jsp">
    <h3>Filter & Search</h3>
    
    <label>Make:</label>
    <input type="text" name="make" value="<%= makeFilter %>" placeholder="Toyota, Honda, Ford...">
    
    <label>Model:</label>
    <input type="text" name="model" value="<%= modelFilter %>" placeholder="Camry, Civic, F-150...">
    
    <label>Year Range:</label>
    <input type="number" name="minYear" value="<%= minYearStr != null ? minYearStr : "" %>" placeholder="Min Year" min="1900" max="2025">
    to
    <input type="number" name="maxYear" value="<%= maxYearStr != null ? maxYearStr : "" %>" placeholder="Max Year" min="1900" max="2025">
    
    <label>Max Mileage:</label>
    <input type="number" name="maxMileage" value="<%= maxMileageStr != null ? maxMileageStr : "" %>" placeholder="e.g., 50000">
    
    <label>Color:</label>
    <input type="text" name="color" value="<%= colorFilter %>" placeholder="Any color">
    
    <label>Category:</label>
    <select name="category">
        <option value="">All Categories</option>
        <option value="Cars" <%= categoryFilter.equals("Cars") ? "selected" : "" %>>Cars</option>
        <option value="Trucks" <%= categoryFilter.equals("Trucks") ? "selected" : "" %>>Trucks</option>
        <option value="Motorcycles" <%= categoryFilter.equals("Motorcycles") ? "selected" : "" %>>Motorcycles</option>
    </select>
    
    <label>Sort By:</label>
    <select name="sortBy">
        <option value="ending" <%= sortBy.equals("ending") ? "selected" : "" %>>Ending Soon</option>
        <option value="price-low" <%= sortBy.equals("price-low") ? "selected" : "" %>>Price: Low to High</option>
        <option value="price-high" <%= sortBy.equals("price-high") ? "selected" : "" %>>Price: High to Low</option>
        <option value="year-new" <%= sortBy.equals("year-new") ? "selected" : "" %>>Year: Newest</option>
        <option value="year-old" <%= sortBy.equals("year-old") ? "selected" : "" %>>Year: Oldest</option>
        <option value="mileage" <%= sortBy.equals("mileage") ? "selected" : "" %>>Mileage: Low to High</option>
    </select>
    
    <button type="submit">Apply Filters</button>
    <a href="browseAuctions.jsp">Clear Filters</a>
</form>
<hr>

<%
    Connection con = null;
    PreparedStatement pst = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/BuyMe", "root", "Linuxfs123!");
        
        // Build dynamic SQL query based on filters
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT a.auction_id, a.item_id, i.title, i.make, i.model, i.year, i.mileage, i.color, ");
        sql.append("i.item_condition, a.start_price, a.end_time, a.auction_status, sc.sub_name, ");
        sql.append("COALESCE(MAX(b.amount), a.start_price) as current_price ");
        sql.append("FROM auction a ");
        sql.append("JOIN item i ON a.item_id = i.item_id ");
        sql.append("LEFT JOIN sub_category sc ON i.sub_category_id = sc.sub_category_id ");
        sql.append("LEFT JOIN bid b ON a.auction_id = b.auction_id AND a.item_id = b.item_id ");
        sql.append("WHERE a.auction_status = 'active' AND a.end_time > NOW() ");
        
        List<Object> params = new ArrayList<>();
        
        if (!makeFilter.isEmpty()) {
            sql.append("AND LOWER(i.make) LIKE ? ");
            params.add("%" + makeFilter.toLowerCase() + "%");
        }
        if (!modelFilter.isEmpty()) {
            sql.append("AND LOWER(i.model) LIKE ? ");
            params.add("%" + modelFilter.toLowerCase() + "%");
        }
        if (minYearStr != null && !minYearStr.isEmpty()) {
            sql.append("AND i.year >= ? ");
            params.add(minYear);
        }
        if (maxYearStr != null && !maxYearStr.isEmpty()) {
            sql.append("AND i.year <= ? ");
            params.add(maxYear);
        }
        if (maxMileageStr != null && !maxMileageStr.isEmpty()) {
            sql.append("AND i.mileage <= ? ");
            params.add(maxMileage);
        }
        if (!colorFilter.isEmpty()) {
            sql.append("AND LOWER(i.color) LIKE ? ");
            params.add("%" + colorFilter.toLowerCase() + "%");
        }
        if (!categoryFilter.isEmpty()) {
            sql.append("AND sc.sub_name = ? ");
            params.add(categoryFilter);
        }
        
        sql.append("GROUP BY a.auction_id, a.item_id, i.title, i.make, i.model, i.year, i.mileage, i.color, ");
        sql.append("i.item_condition, a.start_price, a.end_time, a.auction_status, sc.sub_name ");
        
        // Add ORDER BY based on sortBy parameter
        switch(sortBy) {
            case "ending":
                sql.append("ORDER BY a.end_time ASC");
                break;
            case "price-low":
                sql.append("ORDER BY current_price ASC");
                break;
            case "price-high":
                sql.append("ORDER BY current_price DESC");
                break;
            case "year-new":
                sql.append("ORDER BY i.year DESC");
                break;
            case "year-old":
                sql.append("ORDER BY i.year ASC");
                break;
            case "mileage":
                sql.append("ORDER BY i.mileage ASC");
                break;
            default:
                sql.append("ORDER BY a.end_time ASC");
        }
        
        pst = con.prepareStatement(sql.toString());
        
        // Set parameters
        for (int i = 0; i < params.size(); i++) {
            Object param = params.get(i);
            if (param instanceof String) {
                pst.setString(i + 1, (String) param);
            } else if (param instanceof Integer) {
                pst.setInt(i + 1, (Integer) param);
            }
        }
        
        rs = pst.executeQuery();
        
        int resultCount = 0;
%>

<h3>Search Results</h3>
<table>
    <tr>
        <th>Auction ID</th>
        <th>Title</th>
        <th>Make</th>
        <th>Model</th>
        <th>Year</th>
        <th>Mileage</th>
        <th>Color</th>
        <th>Category</th>
        <th>Condition</th>
        <th>Current Price</th>
        <th>Ends</th>
        <th>Actions</th>
    </tr>
<%
        while (rs.next()) {
            resultCount++;
            int auctionId = rs.getInt("auction_id");
            int itemId = rs.getInt("item_id");
            String title = rs.getString("title");
            String make = rs.getString("make");
            String model = rs.getString("model");
            int year = rs.getInt("year");
            int mileage = rs.getInt("mileage");
            String color = rs.getString("color");
            String condition = rs.getString("item_condition");
            double currentPrice = rs.getDouble("current_price");
            Timestamp endTime = rs.getTimestamp("end_time");
            String subName = rs.getString("sub_name");
%>
    <tr>
        <td><%= auctionId %></td>
        <td><%= title %></td>
        <td><%= make %></td>
        <td><%= model %></td>
        <td><%= year %></td>
        <td><%= String.format("%,d", mileage) %></td>
        <td><%= color %></td>
        <td><%= subName %></td>
        <td><%= condition %></td>
        <td>$<%= String.format("%.2f", currentPrice) %></td>
        <td><%= endTime %></td>
        <td>
            <a href="placeBid.jsp?auction_id=<%= auctionId %>&item_id=<%= itemId %>">Place Bid</a> |
            <a href="viewBidHistory.jsp?auction_id=<%= auctionId %>&item_id=<%= itemId %>">View Bids</a>
        </td>
    </tr>
<%
        }
        
        if (resultCount == 0) {
%>
    <tr>
        <td colspan="12" style="text-align: center;">No auctions found matching your criteria. Try adjusting your filters.</td>
    </tr>
<%
        } else {
%>
    <tr>
        <td colspan="12" style="text-align: center;"><strong>Found <%= resultCount %> auction(s)</strong></td>
    </tr>
<%
        }
%>
</table>

<%
    } catch (Exception e) {
        out.println("<p style='color: red;'>Error: " + e.getMessage() + "</p>");
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pst != null) try { pst.close(); } catch (SQLException e) {}
        if (con != null) try { con.close(); } catch (SQLException e) {}
    }
%>

</div>
</body>
</html>
