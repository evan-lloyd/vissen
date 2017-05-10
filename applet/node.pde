class Node {
  String nodeLabel = "";
  float nodeSize = 30;
  float radiusSq = 900;
  float [] nodePosition = {0, 0};
  int asserted = -1;
  boolean highlight = false;
  boolean selected = false;
  double p;
  double dp;
  boolean showDP = false;
  String pString = "";
  
  void draw() {
    ellipseMode(RADIUS);
    if(asserted == -1)
      fill(nodeUnobservedColor);
    else if(asserted == 0)
      fill(nodeFalseColor);
    else
      fill(nodeTrueColor);
    
    if(highlight)
      stroke(nodeHighlightColor);
    else if(selected)
      stroke(nodeSelectedColor);
    else if(p == Double.POSITIVE_INFINITY)
      stroke(nodeTrueColor);
    else if(p == Double.NEGATIVE_INFINITY)
      stroke(nodeFalseColor);
    else
      stroke(nodeDefaultColor);
    
    strokeWeight(3.0 * zoom);
    ellipse(x(), y(), nodeSize * zoom, nodeSize * zoom);
    
    if(highlight)
      fill(nodeHighlightColor);
    else if(selected)
      fill(nodeSelectedColor);
    else if(p == Double.POSITIVE_INFINITY)
      fill(nodeTrueColor);
    else if(p == Double.NEGATIVE_INFINITY)
      fill(nodeFalseColor);
    else
      fill(nodeDefaultColor);
      
      
    textFont(nodeFont, 24 * zoom);
    textAlign(CENTER);
    text(nodeLabel, x(), yOff(-8));
    text(pString, x(), yOff(14));
    
    if(showDP) { // preview a change in p
        strokeWeight(10.0 * zoom);
        float lineLen = lerp(10, 50, (float)Math.abs(dp));
      if(dp > 0.01) {
        stroke(nodeTrueColor);
        line(x(), y(), x(), yOff(-lineLen));
      }
      else if(dp < -0.01) {
        stroke(nodeFalseColor);
        line(x(), y(), x(), yOff(lineLen));
      }
    }
  }
  
  void previewNewP(double newp) {
    dp = newp - p;
    showDP = true;
  }
  
  void setP(double pval) {
    p = pval;
    if(pval == Double.POSITIVE_INFINITY)
      pString = "Certain";
    else if(pval == Double.NEGATIVE_INFINITY)
      pString = "Impossible";
    else
      pString = String.format("%.3f", pval);
    showDP = false;
  }
  
  float xOff(float off) {
    return worldToScreenX(nodePosition[0] + off);
  }
  
  float yOff(float off) {
    return worldToScreenY(nodePosition[1] + off);
  }
  
  float x() { 
    return worldToScreenX(nodePosition[0]);
  }
  float y() {
    return worldToScreenY(nodePosition[1]);
  }
  
  void setScale(double val, double lower, double upper) {
    float s;
    
    if(val == Double.NEGATIVE_INFINITY || val == Double.NaN)
      s = 0.0f;
    else if(val == Double.POSITIVE_INFINITY)
      s = 1.0f;
    else
      s = (float)(val - lower) / (float)(upper - lower);
    s = min(s, 1.0f);
    s = max(s, 0.0f);
    nodeSize = lerp(10, 80, s);
    radiusSq = nodeSize * nodeSize;
  }
  
  void update() {
  }
  
  boolean pointInBounds(PVector p) {
    float dx = p.x - nodePosition[0];
    float dy = p.y - nodePosition[1];
    
    if((dx * dx + dy * dy) <= radiusSq)
      return true;
      
    return false;
  }
}
