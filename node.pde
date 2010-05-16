class Node {
  String nodeLabel = "";
  float nodeSize = 30;
  float radiusSq = 900;
  float [] nodePosition = {0, 0};
  int asserted = -1;
  boolean highlight = false;
  double p;
  
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
    else
      stroke(nodeDefaultColor);
    
    strokeWeight(3.0 * zoom);
      
    ellipse((nodePosition[0] - panX) * zoom, (nodePosition[1] - panY) * zoom, nodeSize * zoom, nodeSize * zoom);
    textFont(nodeFont, 32 * zoom);
    if(highlight)
      fill(nodeHighlightColor);
    else
      fill(nodeDefaultColor);
    textAlign(CENTER);
    text(nodeLabel, (nodePosition[0] - panX) * zoom, (nodePosition[1] - panY + 8) * zoom);
  }
  
  void setScale(double val, double lower, double upper) {
    final float s;
    
    if(Double.isInfinite(val))
      s = (float)lower;
    else
      s = (float)(val - lower) / (float)(upper - lower);
    float minSize = 10, maxSize = 120;
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
