<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    Integer userId = (Integer) session.getAttribute("user_id");
    String title = request.getParameter("title");
    String questionText = request.getParameter("question_text");
    
    if (userId == null || title == null || questionText == null) {
        out.println("<script>alert('Error: Missing information'); window.location='askQuestion.jsp';</script>");
        return;
    }
    
    Connection con = null;
    PreparedStatement pst = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/BuyMe", "root", "Linuxfs123!");
        
        String sql = "INSERT INTO question (user_id, title, question_text, date_posted, status) VALUES (?, ?, ?, NOW(), 'open')";
        pst = con.prepareStatement(sql);
        pst.setInt(1, userId);
        pst.setString(2, title);
        pst.setString(3, questionText);
        
        int result = pst.executeUpdate();
        
        if (result > 0) {
            out.println("<script>alert('Question submitted successfully! A customer service representative will respond soon.'); window.location='myQuestions.jsp';</script>");
        } else {
            out.println("<script>alert('Error submitting question. Please try again.'); window.location='askQuestion.jsp';</script>");
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('Database error: " + e.getMessage() + "'); window.location='askQuestion.jsp';</script>");
    } finally {
        if (pst != null) try { pst.close(); } catch(SQLException e) {}
        if (con != null) try { con.close(); } catch(SQLException e) {}
    }
%>
