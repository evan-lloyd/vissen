void setupInterface() {
  controlP5 = new ControlP5(this);
  
  ControlGroup g = controlP5.addGroup("infoTab", 5, height - 200, width - 10);
  
  controlP5.addButton("renderSettingsTab", 0, 5, 5, 100, 20).setGroup(g);
  controlP5.controller("renderSettingsTab").setLabel("Render Settings");
  controlP5.addButton("selectedTermsTab", 0, 110, 5, 100, 20).setGroup(g);
  controlP5.controller("selectedTermsTab").setLabel("Selected Terms");
  
  controlP5.controller("selectedTermsTab").captionLabel().toUpperCase(false);
  controlP5.controller("renderSettingsTab").captionLabel().toUpperCase(false);
  controlP5.controller("renderSettingsTab").setMoveable(false);
  controlP5.controller("selectedTermsTab").setMoveable(false);
  
  controlP5.addSlider("edgeThresh", edgeThreshMin, edgeThreshMax, edgeThresh, 5, 35, 200, 20).setGroup(g);
  controlP5.controller("edgeThresh").setColorLabel(color(0.0));
  controlP5.controller("edgeThresh").setMoveable(false);
  controlP5.controller("edgeThresh").setLabel("Edge drawing threshold");
  controlP5.controller("edgeThresh").captionLabel().toUpperCase(false);
  
  
  controlP5.group("infoTab").captionLabel().toUpperCase(false);
  controlP5.group("infoTab").setLabel("");
  
  g.setBackgroundColor(statusBackground);
  g.setBackgroundHeight(195);
  g.setBarHeight(20);
  g.setMoveable(false);
  g.setId(infoTab);
  g.activateEvent(true);

  controlP5.setControlFont(controlsSmall);
  controlP5.setAutoDraw(false);
  
}

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

void draw() {
  updateControls();
  
  if(dynamicLayout)
    layoutTick();
  
  background(bgColor);
  
  if(drawEdges) {
    strokeWeight(6.0 * zoom);
    for(int i = 0; i < nodes.length; i++) {
      for(int j = 0; j < nodes.length; j++) {
        if(i == j)
          continue;
        if(sens[i][j][1] > edgeThresh) {
          stroke(nodeTrueColor);
          line(nodes[i].x(), nodes[i].y(), nodes[j].x(), nodes[j].y());
        }
        else if(sens[i][j][1] < -edgeThresh) {
          stroke(nodeFalseColor);
          line(nodes[i].x(), nodes[i].y(), nodes[j].x(), nodes[j].y());
        }
      }
    }
  }
  
  for(int i = nodes.length - 1; i >= 0; i--) {
    nodes[i].draw();
  }
  
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
