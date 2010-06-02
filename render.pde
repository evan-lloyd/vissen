void setColorsAndFonts() {
  colorMode(HSB, 1.0);
  nodeDefaultColor = color(0);
  nodeSelectedColor = color(220.0 / 360.0, .48, 1.0);
  nodeHighlightColor = color(62.0 / 360.0, 0.8, 0.8);
  selectionBoxColor = color(220.0 / 360.0, .48, 1.0, 0.5);
  nodeUnobservedColor = color(0.92);
  nodeTrueColor = color(113.0 / 360, .49, .82);
  nodeFalseColor = color(13.0 / 360, .49, .82);
  bgColor = color(1.0);
  
  nodeFont = loadFont("nodeLabel.vlw");
  controlsSmall = loadFont("controlsSmall.vlw");
  controlsLarge = loadFont("controlsLarge.vlw");
  
  statusBackground = color(220.0/360.0, .48, 1.0);
}

void drawInfoTab() {
  if(infoTabMode == selectedTermsInfo) {
    fill(nodeDefaultColor);
    textFont(controlsLarge, 18);
    textSize(18);
    
    text(statusString, 10, height - 200 + 55);
  }
}

void drawEdges() { 
  strokeWeight(6.0 * zoom);
  for(int i = 0; i < nodes.length; i++) {
    for(int j = 0; j < nodes.length; j++) {
      if(i == j)
        continue;
      if(sens[i][j][1] > edgeThresh && showPositive) {
        stroke(nodeTrueColor);
        line(nodes[i].x(), nodes[i].y(), nodes[j].x(), nodes[j].y());
      }
      else if(sens[i][j][1] < -edgeThresh && showNegative) {
        stroke(nodeFalseColor);
        line(nodes[i].x(), nodes[i].y(), nodes[j].x(), nodes[j].y());
      }
    }
  }
}

void drawNodes() { 
  for(int i = nodes.length - 1; i >= 0; i--) {
    nodes[i].draw();
  }
}

void draw() {
  updateControls();
  
  if(dynamicLayout)
    layoutTick();
  
  background(bgColor);
  
  if(drawEdges)
    drawEdges();
  
  drawNodes();
  
  if(draggingSelection) { // draw selection box
      stroke(nodeDefaultColor);
      strokeWeight(2.0);
      fill(selectionBoxColor);
      rect(min(lxPress, mouseX), min(lyPress, mouseY), abs(lxPress - mouseX), abs(lyPress - mouseY));
  }
  
  textAlign(LEFT);
  controlP5.draw();
  
  if(infoTabVisible)
    drawInfoTab();
}

PVector screenToWorld(float x, float y) {
  return new PVector(x / zoom + panX, y / zoom + panY);
}

PVector worldToScreen(float x, float y) {
  return new PVector((x - panX) * zoom, (y - panY) * zoom);  
}

float screenToWorldX(float x) {
  return x / zoom + panX;
}

float screenToWorldY(float y) {
  return y / zoom + panY;
}

float worldToScreenX(float x) {
  return (x - panX) * zoom;
}

float worldToScreenY(float y) {
  return (y - panY) * zoom;
}
