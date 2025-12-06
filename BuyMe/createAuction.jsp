<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
    <title>Create Auction</title>
    <script>
        var vehicleData = {
            "1": { // Cars
                "Toyota": ["Camry", "Corolla", "RAV4", "Highlander"],
                "Honda": ["Civic", "Accord", "CR-V", "Pilot"],
                "Ford": ["Mustang", "Explorer", "Escape", "Fusion"],
                "Chevrolet": ["Malibu", "Equinox", "Tahoe", "Camaro"],
                "BMW": ["3 Series", "5 Series", "X3", "X5"]
            },
            "2": { // Trucks
                "Toyota": ["Tacoma", "Tundra"],
                "Honda": ["Ridgeline"],
                "Ford": ["F-150", "Ranger", "Super Duty"],
                "Chevrolet": ["Silverado", "Colorado"],
                "BMW": []
            },
            "3": { // Motorcycles
                "Harley-Davidson": ["Street 750", "Iron 883", "Fat Boy", "Road Glide"],
                "Yamaha": ["YZF-R1", "MT-07", "V-Star", "FZ-09"],
                "Honda": ["CBR600RR", "Gold Wing", "Africa Twin", "Rebel 500"],
                "Kawasaki": ["Ninja 650", "Z900", "Vulcan", "KLR650"],
                "Ducati": ["Monster", "Panigale", "Scrambler", "Multistrada"]
            }
        };
        
        function updateMakes() {
            var typeSelect = document.getElementById("sub_category_id");
            var makeSelect = document.getElementById("make");
            var modelSelect = document.getElementById("model");
            var selectedType = typeSelect.value;
            
            // Clear make and model
            makeSelect.innerHTML = '<option value="">Select Make</option>';
            modelSelect.innerHTML = '<option value="">Select Model</option>';
            modelSelect.disabled = true;
            
            // Populate makes for selected type
            if (selectedType && vehicleData[selectedType]) {
                var makes = Object.keys(vehicleData[selectedType]);
                makes.forEach(function(make) {
                    if (vehicleData[selectedType][make].length > 0) {
                        var option = document.createElement("option");
                        option.value = make;
                        option.text = make;
                        makeSelect.appendChild(option);
                    }
                });
                makeSelect.disabled = false;
            } else {
                makeSelect.disabled = true;
            }
        }
        
        function updateModels() {
            var typeSelect = document.getElementById("sub_category_id");
            var makeSelect = document.getElementById("make");
            var modelSelect = document.getElementById("model");
            var selectedType = typeSelect.value;
            var selectedMake = makeSelect.value;
            
            // Clear existing models
            modelSelect.innerHTML = '<option value="">Select Model</option>';
            
            // Add models for selected type and make
            if (selectedType && selectedMake && vehicleData[selectedType] && vehicleData[selectedType][selectedMake]) {
                vehicleData[selectedType][selectedMake].forEach(function(model) {
                    var option = document.createElement("option");
                    option.value = model;
                    option.text = model;
                    modelSelect.appendChild(option);
                });
                modelSelect.disabled = false;
            } else {
                modelSelect.disabled = true;
            }
        }
    </script>
</head>
<body>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Check if user has seller role
    String username = (String) session.getAttribute("user");
    Connection con = null;
    PreparedStatement pst = null;
    ResultSet rs = null;
    boolean isSeller = false;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/BuyMe", "root", "Linuxfs123!");
        
        pst = con.prepareStatement("SELECT user_role FROM user WHERE username = ?");
        pst.setString(1, username);
        rs = pst.executeQuery();
        
        if (rs.next()) {
            String role = rs.getString("user_role");
            isSeller = "seller".equals(role);
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch(SQLException e) {}
        if (pst != null) try { pst.close(); } catch(SQLException e) {}
        if (con != null) try { con.close(); } catch(SQLException e) {}
    }
    
    if (!isSeller) {
%>
        <h2>Access Denied</h2>
        <p>Only sellers can create auctions.</p>
        <p><a href="success.jsp">Back to Home</a></p>
<%
        return;
    }
%>

<h2>Create New Vehicle Auction</h2>
<a href="success.jsp">Back to Home</a> | <a href="logout.jsp">Logout</a>
<hr>

<form action="processCreateAuction.jsp" method="POST">
    <h3>Vehicle Information</h3>
    
    <label>Vehicle Title:</label><br>
    <input type="text" name="title" required maxlength="50"><br><br>
    
    <label>Vehicle Type:</label><br>
    <select name="sub_category_id" id="sub_category_id" required onchange="updateMakes()">
        <option value="">Select Type</option>
        <option value="1">Cars</option>
        <option value="2">Trucks</option>
        <option value="3">Motorcycles</option>
    </select><br><br>
    
    <label>Make:</label><br>
    <select name="make" id="make" required disabled onchange="updateModels()">
        <option value="">Select Make</option>
    </select><br><br>
    
    <label>Model:</label><br>
    <select name="model" id="model" required disabled>
        <option value="">Select Model</option>
    </select><br><br>
    
    <label>Year:</label><br>
    <select name="year" required>
        <option value="">Select Year</option>
        <% for(int y = 2025; y >= 1990; y--) { %>
            <option value="<%= y %>"><%= y %></option>
        <% } %>
    </select><br><br>
    
    <label>Mileage:</label><br>
    <input type="number" name="mileage" required min="0"><br><br>
    
    <label>Color:</label><br>
    <select name="color" required>
        <option value="">Select Color</option>
        <option value="Black">Black</option>
        <option value="White">White</option>
        <option value="Silver">Silver</option>
        <option value="Gray">Gray</option>
        <option value="Red">Red</option>
        <option value="Blue">Blue</option>
        <option value="Green">Green</option>
        <option value="Yellow">Yellow</option>
        <option value="Orange">Orange</option>
        <option value="Brown">Brown</option>
        <option value="Gold">Gold</option>
        <option value="Beige">Beige</option>
        <option value="Purple">Purple</option>
    </select><br><br>
    
    <label>Condition:</label><br>
    <select name="condition" required>
        <option value="New">New</option>
        <option value="Like New">Like New</option>
        <option value="Used">Used</option>
        <option value="Refurbished">Refurbished</option>
    </select><br><br>
    
    <label>Description:</label><br>
    <textarea name="description" rows="5" cols="50" required></textarea><br><br>
    
    <h3>Auction Settings</h3>
    
    <label>Starting Price ($):</label><br>
    <input type="number" name="start_price" step="0.01" min="0" required><br><br>
    
    <label>Reserve Price (minimum acceptable price - hidden from buyers) ($):</label><br>
    <input type="number" name="min_price" step="0.01" min="0" required><br><br>
    
    <label>Bid Increment ($):</label><br>
    <input type="number" name="increment" step="0.01" min="0.01" value="10.00" required><br><br>
    
    <label>Auction End Date and Time:</label><br>
    <input type="datetime-local" name="end_time" required><br><br>
    
    <input type="submit" value="Create Auction">
    <input type="reset" value="Clear Form">
</form>

</body>
</html>
