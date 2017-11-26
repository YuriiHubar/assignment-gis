<%@ Page Language="C#" AutoEventWireup="true" CodeFile="WebForm1.aspx.cs" Inherits="WebForm1" Debug="true" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <title>PDT projekt 1.0</title>
    <meta name='viewport' content='initial-scale=1,maximum-scale=1,user-scalable=no' />
    <script src='https://api.mapbox.com/mapbox.js/v2.2.3/mapbox.js'></script>
    <link href='https://api.mapbox.com/mapbox.js/v2.2.3/mapbox.css' rel='stylesheet' />
    <link rel="stylesheet" type="text/css" href="style.css">
    <link rel="stylesheet" href="//code.jquery.com/ui/1.11.4/themes/smoothness/jquery-ui.css">
    <script src="https://code.jquery.com/jquery-1.10.2.js"></script>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css" />
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap-theme.min.css" />
    <link rel="stylesheet" href="https://ajax.googleapis.com/ajax/libs/jqueryui/1.11.4/themes/smoothness/jquery-ui.css">
    <script src="http://ajax.aspnetcdn.com/ajax/jquery.ui/1.8.13/jquery-ui.min.js" type="text/javascript"></script>
    <link href="http://ajax.aspnetcdn.com/ajax/jquery.ui/1.8.13/themes/redmond/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js" type="text/javascript"></script>
</head>
<body>
    <form id="form1" runat="server">
        <div id="menu">
            <p>
                <asp:Label ID="Label1" runat="server" Text="Max distance [m]"></asp:Label>
            <br>   
                <asp:TextBox ID="TB_Distance" runat="server" AutoPostBack="true" OnTextChanged="TB_Distance_TextChanged">2000</asp:TextBox>
            <p>
                <asp:Label ID="Label2" runat="server" Text="Get item count"></asp:Label>
            <br>  
                 <asp:TextBox ID="TB_Count" runat="server" AutoPostBack="true" OnTextChanged="TB_Count_TextChanged">350</asp:TextBox>
            <p>
                <asp:Label ID="Label3" runat="server" Text="Sensivity factor"></asp:Label>    
            <br>  
                <asp:TextBox ID="TB_Sensivity" runat="server" AutoPostBack="true" OnTextChanged="TB_Sensivity_TextChanged">300</asp:TextBox>             
            <p>
                <asp:Label ID="Label4" runat="server" Text="Level"></asp:Label> 
            <br>  
                <asp:TextBox ID="TB_Level" runat="server" AutoPostBack="true" OnTextChanged="TB_Level_TextChanged">1</asp:TextBox>      
            <p>
                <asp:Label ID="Label5" runat="server" Text="Food facility"></asp:Label> 
            <br>  
                <asp:TextBox ID="TB_Weight1" runat="server" AutoPostBack="true" OnTextChanged="TB_Weight_TextChanged">1</asp:TextBox>      
            <p>
                <asp:Label ID="Label6" runat="server" Text="Supermarket"></asp:Label> 
            <br>  
                <asp:TextBox ID="TB_Weight2" runat="server" AutoPostBack="true" OnTextChanged="TB_Weight_TextChanged">1</asp:TextBox>      
            <p>
                <asp:Label ID="Label7" runat="server" Text="Pharmacy"></asp:Label> 
            <br>  
                <asp:TextBox ID="TB_Weight3" runat="server" AutoPostBack="true" OnTextChanged="TB_Weight_TextChanged">1</asp:TextBox>      
            <p>
                <asp:Label ID="Label8" runat="server" Text="Bank"></asp:Label> 
            <br>  
                <asp:TextBox ID="TB_Weight4" runat="server" AutoPostBack="true" OnTextChanged="TB_Weight_TextChanged">1</asp:TextBox>      
            <p>
                <asp:Label ID="Label9" runat="server" Text="Bus stop"></asp:Label> 
            <br>  
                <asp:TextBox ID="TB_Weight5" runat="server" AutoPostBack="true" OnTextChanged="TB_Weight_TextChanged">1</asp:TextBox>      
            <p>         
                <button type="button" onclick="update()">Search</button>
        </div>

        <div id="map">
            <script type="text/javascript">               
                var distance = document.getElementById('TB_Distance');
                var count = document.getElementById('TB_Count');
                var sensivity = document.getElementById('TB_Sensivity');
                var level = document.getElementById('TB_Level');
                var weight1 = document.getElementById('TB_Weight1');
                var weight2 = document.getElementById('TB_Weight2');
                var weight3 = document.getElementById('TB_Weight3');
                var weight4 = document.getElementById('TB_Weight4');
                var weight5 = document.getElementById('TB_Weight5');

                L.mapbox.accessToken = 'pk.eyJ1IjoieXVyaWktaHViYXIiLCJhIjoiY2o4bDlwNnlpMGgxNTMzbGR1MHQ4YzE3cCJ9.qs4HdNKVJliJpfIea_CUow';

                var map = L.mapbox.map('map', 'mapbox.streets').setView([48.153840297249474, 17.07171320915222], 15);

                var actualLocation = L.marker([48.153840297249474, 17.07171320915222], {
                    icon: L.mapbox.marker.icon({
                        'marker-color': '#3bb2d0',
                        'marker-size': 'large',
                        'marker-symbol': 'circle'
                    }),
                    draggable: true
                }).bindPopup('<b> Aktualna pozicia </b>').addTo(map);

                actualLocation.on('dragend', refreshPosition);
                refreshPosition();

                function refreshPosition() {
                    actualLocation.bindPopup('<b> Current position </b><br>' + actualLocation.getLatLng().lat + '<br>' + actualLocation.getLatLng().lng);
                    update();
                }

                function getPoints() {
                    $.ajax({
                        type: "POST",
                        async: true,
                        processData: true,
                        cache: false,
                        url: 'WebForm1.aspx/FindPoints',
                        data: '{"latC":"' + actualLocation.getLatLng().lat +
                            '","longC":"' + actualLocation.getLatLng().lng +
                            '","distance":"' + distance.value +
                            '","count":"' + count.value +
                            '","level":"' + level.value +
                            '","sens":"' + sensivity.value +
                            '","w1":"' + weight1.value +
                            '","w2":"' + weight2.value +
                            '","w3":"' + weight3.value +
                            '","w4":"' + weight4.value +
                            '","w5":"' + weight5.value +
                            '"}',
                        contentType: 'application/json; charset=utf-8',
                        dataType: "json",
                        success: function (data) {
                            try {
                                var geojson = jQuery.parseJSON(data.d);
                                map.featureLayer.setGeoJSON(geojson);
                            }
                            catch (err) {
                                console.log(err.message);
                                console.log(data.d);
                            }
                        },
                        error: function (err) {
                            console.log(err.message);
                        }
                    });
                }             

                function update() {
                    getPoints();
                }
            </script>
        </div>
    </form>
</body>
</html>
