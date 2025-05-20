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
        .action-buttons {
            display: flex;
            gap: 5px;
        }
    </style>
</head>
<body>
    <h1>Main Dashboard</h1>
    <p>Logged in as: ${user.email} (${user.staff ? 'Staff' : 'Customer'})</p>
    <a href="logout.jsp">Logout</a>

    <h2>Device Catalogue</h2>
    
    <!-- Device Search Form -->
    <form action="DeviceServlet" method="get">
        <input type="hidden" name="action" value="search">
        <input type="text" name="searchName" placeholder="Search by name">
        <select name="searchType">
            <option value="">All Types</option>
            <c:forEach items="${deviceTypes}" var="type">
                <option value="${type}">${type}</option>
            </c:forEach>
        </select>
        <button type="submit">Search</button>
    </form>
    
    <!-- Staff Only: Add Device Button -->
    <c:if test="${user.staff}">
        <button onclick="toggleDeviceForm()">Add New Device</button>
    </c:if>
    
    <!-- Device Form (Initially Hidden) -->
    <div id="deviceForm" style="display: none;" class="device-form">
        <form action="DeviceServlet" method="post">
            <input type="hidden" name="action" id="formAction" value="add">
            <input type="hidden" name="deviceId" id="deviceId" value="">
            
            <div>
                <label for="name">Device Name:</label>
                <input type="text" id="name" name="name" required>
            </div>
            
            <div>
                <label for="type">Device Type:</label>
                <select id="type" name="type" required>
                    <c:forEach items="${deviceTypes}" var="type">
                        <option value="${type}">${type}</option>
                    </c:forEach>
                </select>
            </div>
            
            <div>
                <label for="price">Unit Price:</label>
                <input type="number" step="0.01" id="price" name="price" required>
            </div>
            
            <div>
                <label for="stock">Stock Quantity:</label>
                <input type="number" id="stock" name="stock" required>
            </div>
            
            <button type="submit">Save</button>
            <button type="button" onclick="toggleDeviceForm()">Cancel</button>
        </form>
    </div>
    
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
                            <button onclick="editDevice(${device.id}, '${device.name}', '${device.type}', ${device.price}, ${device.stock})">Edit</button>
                            <form action="DeviceServlet" method="post" style="display:inline;">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="deviceId" value="${device.id}">
                                <button type="submit" onclick="return confirm('Are you sure you want to delete this device?')">Delete</button>
                            </form>
                        </td>
                    </c:if>
                </tr>
            </c:forEach>
        </tbody>
    </table>

    <script>
        function toggleDeviceForm() {
            const form = document.getElementById('deviceForm');
            form.style.display = form.style.display === 'none' ? 'block' : 'none';
            
            // Reset form when showing
            if (form.style.display === 'block') {
                document.getElementById('formAction').value = 'add';
                document.getElementById('deviceId').value = '';
                document.getElementById('name').value = '';
                document.getElementById('type').value = '';
                document.getElementById('price').value = '';
                document.getElementById('stock').value = '';
            }
        }
        
        function editDevice(id, name, type, price, stock) {
            document.getElementById('formAction').value = 'update';
            document.getElementById('deviceId').value = id;
            document.getElementById('name').value = name;
            document.getElementById('type').value = type;
            document.getElementById('price').value = price;
            document.getElementById('stock').value = stock;
            
            document.getElementById('deviceForm').style.display = 'block';
        }
    </script>
</body>
</html>