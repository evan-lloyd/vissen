class Node {
  String nodeLabel = "";
  float nodeSize = 30;
  float radiusSq = 900;
  float [] nodePosition = {0, 0};
  int asserted = -1;
  boolean highlight = false;
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
    else if(p == Double.POSITIVE_INFINITY)
      stroke(nodeTrueColor);
    else if(p == Double.NEGATIVE_INFINITY)
      stroke(nodeFalseColor);
    else
      stroke(nodeDefaultColor);
    
    strokeWeight(3.0 * zoom);
    ellipse((nodePosition[0] - panX) * zoom, (nodePosition[1] - panY) * zoom, nodeSize * zoom, nodeSize * zoom);
    
    if(highlight)
      fill(nodeHighlightColor);
    else if(p == Double.POSITIVE_INFINITY)
      fill(nodeTrueColor);
    else if(p == Double.NEGATIVE_INFINITY)
      fill(nodeFalseColor);
    else
      fill(nodeDefaultColor);
      
      
    textFont(nodeFont, 24 * zoom);
    textAlign(CENTER);
    text(nodeLabel, (nodePosition[0] - panX) * zoom, (nodePosition[1] - panY - 8) * zoom);
    text(pString, (nodePosition[0] - panX) * zoom, (nodePosition[1] - panY + 14) * zoom);
    
    if(showDP) { // preview a change in p
        strokeWeight(10.0 * zoom);
        float lineLen = lerp(10, 50, (float)Math.abs(dp));
      if(dp > 0.01) {
        stroke(nodeTrueColor);
        line((nodePosition[0] - panX) * zoom, (nodePosition[1] - panY) * zoom, (nodePosition[0] - panX) * zoom, (nodePosition[1] - panY - lineLen) * zoom);
      }
      else if(dp < -0.01) {
        stroke(nodeFalseColor);
        line((nodePosition[0] - panX) * zoom, (nodePosition[1] - panY) * zoom, (nodePosition[0] - panX) * zoom, (nodePosition[1] - panY + lineLen) * zoom);
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
      pString = Double.toString(p);
    showDP = false;
  }
  
  void setScale(double val, double lower, double upper) {
    final float s;
    
    if(val == Double.NEGATIVE_INFINITY || val == Double.NaN)
      s = 0.0f;
    else if(val == Double.POSITIVE_INFINITY)
      s = 1.0f;
    else
      s = (float)(val - lower) / (float)(upper - lower);
    float minSize = 10, maxSize = 80;
    nodeSize = minSize + s * (maxSize - minSize);
    radiusSq = nodeSize * nodeSize;
  }
  
  void update() {
  }
  
  boolean pointInBounds(float x, float y) {
    float dx = x - nodePosition[0];
    float dy = y - nodePosition[1];
    
    if((dx * dx + dy * dy) <= radiusSq)
      return true;
      
    return false;
  }
}
