<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
    <title>My Questions - BuyMe</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .question-box {
            border: 1px solid #ddd;
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 5px;
            background-color: #f9f9f9;
        }
        .question-title {
            font-size: 18px;
            font-weight: bold;
            color: #333;
            margin-bottom: 10px;
        }
        .question-meta {
            color: #666;
            font-size: 13px;
            margin-bottom: 10px;
        }
        .question-text {
            margin-bottom: 15px;
            line-height: 1.5;
        }
        .reply-box {
            background-color: #e8f4f8;
            border-left: 3px solid #667eea;
            padding: 10px;
            margin-top: 10px;
        }
        .reply-meta {
            font-size: 12px;
            color: #555;
            margin-bottom: 5px;
        }
        .status-open {
            color: orange;
            font-weight: bold;
        }
        .status-answered {
            color: green;
            font-weight: bold;
        }
        .status-closed {
            color: gray;
            font-weight: bold;
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
%>

<h2>My Questions to Customer Service</h2>
<a href="success.jsp">Back to Home</a> | <a href="askQuestion.jsp">Ask New Question</a> | <a href="logout.jsp">Logout</a>
<hr>

<%
    Connection con = null;
    PreparedStatement pst = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/BuyMe", "root", "Linuxfs123!");
        
        // Get all questions by this user
        String sql = "SELECT q.question_id, q.title, q.question_text, q.date_posted, q.status " +
                     "FROM question q WHERE q.user_id = ? ORDER BY q.date_posted DESC";
        pst = con.prepareStatement(sql);
        pst.setInt(1, userId);
        rs = pst.executeQuery();
        
        boolean hasQuestions = false;
        
        while (rs.next()) {
            hasQuestions = true;
            int questionId = rs.getInt("question_id");
            String title = rs.getString("title");
            String questionText = rs.getString("question_text");
            Timestamp datePosted = rs.getTimestamp("date_posted");
            String status = rs.getString("status");
            
            out.println("<div class='question-box'>");
            out.println("<div class='question-title'>" + title + "</div>");
            out.println("<div class='question-meta'>Asked on: " + datePosted + " | Status: ");
            
            if ("open".equals(status)) {
                out.println("<span class='status-open'>Open (Waiting for response)</span>");
            } else if ("answered".equals(status)) {
                out.println("<span class='status-answered'>Answered</span>");
            } else {
                out.println("<span class='status-closed'>Closed</span>");
            }
            
            out.println("</div>");
            out.println("<div class='question-text'><strong>Question:</strong> " + questionText + "</div>");
            
            // Get replies for this question
            PreparedStatement pstReply = con.prepareStatement(
                "SELECT r.reply_text, r.date_replied, cr.rep_name " +
                "FROM reply r JOIN customer_representative cr ON r.rep_id = cr.rep_id " +
                "WHERE r.question_id = ? ORDER BY r.date_replied ASC"
            );
            pstReply.setInt(1, questionId);
            ResultSet rsReply = pstReply.executeQuery();
            
            while (rsReply.next()) {
                String replyText = rsReply.getString("reply_text");
                Timestamp dateReplied = rsReply.getTimestamp("date_replied");
                String repName = rsReply.getString("rep_name");
                
                out.println("<div class='reply-box'>");
                out.println("<div class='reply-meta'><strong>Reply from " + repName + "</strong> on " + dateReplied + "</div>");
                out.println("<div>" + replyText + "</div>");
                out.println("</div>");
            }
            
            rsReply.close();
            pstReply.close();
            
            out.println("</div>");
        }
        
        if (!hasQuestions) {
            out.println("<p>You haven't asked any questions yet.</p>");
            out.println("<p><a href='askQuestion.jsp'>Ask your first question</a></p>");
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<p>Error loading questions: " + e.getMessage() + "</p>");
    } finally {
        if (rs != null) try { rs.close(); } catch(SQLException e) {}
        if (pst != null) try { pst.close(); } catch(SQLException e) {}
        if (con != null) try { con.close(); } catch(SQLException e) {}
    }
%>

</div>
</body>
</html>
