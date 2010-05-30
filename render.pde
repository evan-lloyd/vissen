void setColorsAndFonts() {
  colorMode(HSB, 1.0);
  nodeDefaultColor = color(0);
  nodeHighlightColor = color(58.0 / 360.0, .8, .72);
  selectionBoxColor = color(58.0 / 360.0, .8, .72, 0.5);
  nodeUnobservedColor = color(0.92);
  nodeTrueColor = color(113.0 / 360, .49, .82);
  nodeFalseColor = color(13.0 / 360, .49, .82);
  bgColor = color(1.0);
  nodeFont = loadFont("nodeLabel.vlw");
  statusBackground = color(220.0/360.0, .48, 1.0);
}

void draw() {
  background(bgColor);
  
  if(drawEdges) {
    strokeWeight(6.0);
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
  
  stroke(nodeDefaultColor);
  strokeWeight(2.0);
  fill(statusBackground);
  rect(5, height - 40, width - 10, 35);
  
  fill(nodeDefaultColor);
  textFont(nodeFont, 24 * zoom);
  textAlign(LEFT);
  textSize(24);
  text(statusString, 8, height - 14);
}
