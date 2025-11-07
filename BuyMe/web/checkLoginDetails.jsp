<%@ page import="java.sql." %>
<%@ 
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:330/dbname", "root", "dbpass");
    Statement stmt = conn.createStatement();
    ResultSet rs = stmt.executeQuery("SELECT FROM users WHERE username='" + username + "' AND password='" + password + "'");
    if (rs.next()) {
        session.setAttribute("username", username);
        out.println("<script>alert('Login successful');</script>");
        out.println("<script>window.location='AuctionDashboard.jsp';</script>");
    } else {
        out.println("<script>alert('Invalid username or password'); window.location='login.jsp';</script>");
    }