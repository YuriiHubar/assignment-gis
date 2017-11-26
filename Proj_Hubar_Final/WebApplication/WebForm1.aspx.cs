using System;
using System.Web.UI.WebControls;
using Npgsql;
public partial class WebForm1 : System.Web.UI.Page
{
  public static string addJsonTagProperty(string name, string xy, string points)
  { 
    return String.Format("\"properties\":{0}\"title\":\"Point #{1}\",\"description\":\"({2})<br>Score = {3} pts.\",\"marker-color\":\"#ee3030\",\"marker-size\":\"small\"{4}", "{", name, xy, points, "}"); ;
  }
  public static string addJsonTag(string name, string way, string xy, string points)
  {
    return String.Format("{0}\"type\": \"Feature\",\"geometry\":{1},{2}{3}", "{", way, addJsonTagProperty(name, xy, points), "}");
  }

  [System.Web.Services.WebMethod]
  public static Object FindPoints(string latC, string longC, string distance, string count, string level, string sens, string w1, string w2, string w3, string w4, string w5)
  {
    try
    {
      String geojson = String.Empty;
      NpgsqlConnection conn = new NpgsqlConnection("Server=127.0.0.1;User Id=project_user;Password=1;Database=gis;");
      conn.Open();

      NpgsqlCommand cmd;
    
      String cmd_txt =
        String.Format(
      @"WITH candidates as (
  SELECT DISTINCT ON (way) *
  FROM planet_support_point
  WHERE st_dwithin(st_makepoint('{0}', '{1}')::geography, st_transform(way, 4326), {2})
  AND dist_supermarket is not null
  AND dist_pharmacy is not null
  AND dist_bank is not null
  AND dist_public_transport is not null
)
SELECT c.osm_id, st_asgeojson(st_transform(c.way, 4326)),
round(cast(st_x(st_transform(way, 4236))as numeric), 5) || ', ' || round(cast(st_y(st_transform(way, 4236))as numeric), 5), 
round (1000 * {6}/(dist_food + {4}) + 
1000 * {7}/(dist_supermarket + {4}) + 
1000 * {8}/(dist_pharmacy + {4}) + 
1000 * {9}/(dist_bank + {4}) + 
1000 * {10}/(dist_public_transport + {4}), 4) points
FROM candidates c
WHERE 
  dist_food is not null
  AND level = {5}
ORDER BY points DESC
LIMIT {3}", longC, latC, distance, count, sens, level, w1, w2, w3, w4, w5);
      
      cmd = new NpgsqlCommand(cmd_txt, conn);
      NpgsqlDataReader reader = cmd.ExecuteReader();
      
      while (reader.Read())
        geojson += addJsonTag(reader.GetString(0), reader.GetString(1), reader.GetString(2), reader.GetString(3)) + ",";
      conn.Close();
      if (geojson.Length > 1)
        geojson = geojson.Remove(geojson.Length - 1);     
      return String.Format("[{0}]", geojson);
    }
    catch (Exception ex)
    {    
      Console.WriteLine(ex.Message);
      return "[]";
    }
  }
  protected void TB_Distance_TextChanged(object sender, EventArgs e)
  {
    TextBox textbox = (TextBox)sender;
    int value;
    if (!int.TryParse(textbox.Text, out value))
      textbox.Text = "1000";
    else if(value < 1 || value > 10000)
      textbox.Text = "1000";
  }
  protected void TB_Count_TextChanged(object sender, EventArgs e)
  {
    TextBox textbox = (TextBox)sender;
    int value;
    if (!int.TryParse(textbox.Text, out value))
      textbox.Text = "350";
    else if (value < 1 || value > 350)
      textbox.Text = "350";
  }
  protected void TB_Sensivity_TextChanged(object sender, EventArgs e)
  {
    TextBox textbox = (TextBox)sender;
    int value;
    if (!int.TryParse(textbox.Text, out value))
      textbox.Text = "300";
    else if (value < 1 || value > 3000)
      textbox.Text = "300";
  }
  protected void TB_Weight_TextChanged(object sender, EventArgs e)
  {
    TextBox textbox = (TextBox)sender;
    int value;
    if (!int.TryParse(textbox.Text, out value))
      textbox.Text = "5";
    else if (value < -10 || value > 10)
      textbox.Text = "5";
  }
  protected void TB_Level_TextChanged(object sender, EventArgs e)
  {
    TextBox textbox = (TextBox)sender;
    int value;
    if (!int.TryParse(textbox.Text, out value))
      textbox.Text = "1";
    else if (value < 0 || value > 3)
      textbox.Text = "1";
  }
}