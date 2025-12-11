<%@ page import="java.sql.*" %>
<%
if (!"admin".equals(session.getAttribute("role"))) {
    response.sendRedirect("login.jsp");
    return;
}
%>
<!DOCTYPE html>
<html>
<head>
    <title>Create Customer Representative - BuyMe</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="container">
    <h2>Create Customer Representative</h2>
    
    <form action="createRep.jsp" method="POST">
        Name: <input type="text" name="rep_name" required><br><br>
        Email (used for login): <input type="email" name="email" required><br><br>
        Password: <input type="password" name="password" required><br><br>
        <input type="submit" value="Create Rep">
    </form>
    
    <%
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/BuyMe",
                "root", "Linuxfs123!"
            );
            
            // Get next rep_id
            Statement st = con.createStatement();
            ResultSet rs = st.executeQuery("SELECT COALESCE(MAX(rep_id), 0) + 1 as next_id FROM customer_representative");
            int nextId = 1;
            if (rs.next()) {
                nextId = rs.getInt("next_id");
            }
            rs.close();
            
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO customer_representative (rep_id, rep_name, email, rep_password) VALUES (?, ?, ?, ?)"
            );
            
            ps.setInt(1, nextId);
            ps.setString(2, request.getParameter("rep_name"));
            ps.setString(3, request.getParameter("email"));
            ps.setString(4, request.getParameter("password"));
            
            ps.executeUpdate();
            
            // Also insert into creates table (admin creates rep)
            PreparedStatement ps2 = con.prepareStatement(
                "INSERT INTO creates (admin_id, rep_id) VALUES (1, ?)"
            );
            ps2.setInt(1, nextId);
            ps2.executeUpdate();
            ps2.close();
            
            ps.close();
            st.close();
            con.close();
            
            out.println("<p style='color: green;'>Representative created successfully! (ID: " + nextId + ")</p>");
        } catch (Exception e) {
            out.println("<p style='color: red;'>Error: " + e.getMessage() + "</p>");
        }
    }
    %>
    
    <hr>
    <a href="admin.jsp">Back to Admin Dashboard</a>
</div>
</body>
</html>