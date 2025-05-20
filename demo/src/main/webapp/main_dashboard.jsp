<jsp:include page="/ConnServlet" />
<%@ page import="model.*" %>
<%@ page import="model.dao.*" %>
<%@ page import="java.util.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>IoTBay - Dashboard</title>
    <style>
        .device-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        .device-table th, .device-table td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }
        .device-table th {
            background-color: #f2f2f2;
        }
        .device-form {
            margin: 20px 0;
            padding: 15px;
            border: 1px solid #ddd;
            background-color: #f9f9f9;
        }
        .action-buttons form {
            display: inline;
        }
    </style>
</head>
<body>
    <h1>Main Dashboard</h1>
    <p>Logged in as: ${user.email} (${user.staff ? 'Staff' : 'Customer'})</p>
    <a href="logout.jsp">Logout</a>

    <h2>Device Catalogue</h2>
    
    <!-- Search Form -->
    <form action="DeviceServlet" method="get">
        <input type="hidden" name="action" value="search">
        <input type="text" name="searchName" placeholder="Search by name" 
               value="${param.searchName}">
        <select name="searchType">
            <option value="">All Types</option>
            <c:forEach items="${deviceTypes}" var="type">
                <option value="${type}" ${param.searchType eq type ? 'selected' : ''}>
                    ${type}
                </option>
            </c:forEach>
        </select>
        <button type="submit">Search</button>
        <a href="DeviceServlet">Clear</a>
    </form>
    
    <!-- Show Add/Edit Form based on request parameter -->
    <c:if test="${not empty param.showForm or not empty param.editId}">
        <div class="device-form">
            <form action="DeviceServlet" method="post">
                <input type="hidden" name="action" 
                       value="${not empty param.editId ? 'update' : 'add'}">
                
                <c:if test="${not empty param.editId}">
                    <input type="hidden" name="deviceId" value="${param.editId}">
                </c:if>
                
                <div>
                    <label for="name">Device Name:</label>
                    <input type="text" id="name" name="name" required
                           value="${not empty param.editId ? deviceToEdit.name : ''}">
                </div>
                
                <div>
                    <label for="type">Device Type:</label>
                    <select id="type" name="type" required>
                        <c:forEach items="${deviceTypes}" var="type">
                            <option value="${type}" 
                                ${(not empty param.editId and deviceToEdit.type eq type) ? 'selected' : ''}>
                                ${type}
                            </option>
                        </c:forEach>
                    </select>
                </div>
                
                <div>
                    <label for="price">Unit Price:</label>
                    <input type="number" step="0.01" id="price" name="price" required
                           value="${not empty param.editId ? deviceToEdit.price : ''}">
                </div>
                
                <div>
                    <label for="stock">Stock Quantity:</label>
                    <input type="number" id="stock" name="stock" required
                           value="${not empty param.editId ? deviceToEdit.stock : ''}">
                </div>
                
                <button type="submit">Save</button>
                <a href="DeviceServlet">Cancel</a>
            </form>
        </div>
    </c:if>
    
    <!-- Staff Only: Add Device Button -->
    <c:if test="${user.staff and empty param.showForm and empty param.editId}">
        <form action="DeviceServlet" method="get" style="display:inline;">
            <input type="hidden" name="showForm" value="true">
            <button type="submit">Add New Device</button>
        </form>
    </c:if>
    
    <!-- Device List Table -->
    <table class="device-table">
        <thead>
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Type</th>
                <th>Price</th>
                <th>Stock</th>
                <c:if test="${user.staff}">
                    <th>Actions</th>
                </c:if>
            </tr>
        </thead>
        <tbody>
            <c:forEach items="${deviceList}" var="device">
                <tr>
                    <td>${device.id}</td>
                    <td>${device.name}</td>
                    <td>${device.type}</td>
                    <td>$${device.price}</td>
                    <td>${device.stock}</td>
                    <c:if test="${user.staff}">
                        <td class="action-buttons">
                            <form action="DeviceServlet" method="get">
                                <input type="hidden" name="editId" value="${device.id}">
                                <button type="submit">Edit</button>
                            </form>
                            <form action="DeviceServlet" method="post" 
                                  onsubmit="return confirm('Are you sure you want to delete this device?')">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="deviceId" value="${device.id}">
                                <button type="submit">Delete</button>
                            </form>
                        </td>
                    </c:if>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</body>
</html>