import java.awt.event.*;

public void doSelectionBox() {
  x1 = min(mouseX, lxPress);
  x2 = max(mouseX, lxPress);
  y1 = min(mouseY, lyPress);
  y2 = max(mouseY, lyPress);
}

public void setupControls() {
  controlP5 = new ControlP5(this);
  Slider ets = controlP5.addSlider("Edge drawing threshold", edgeThreshMin, edgeThreshMax, edgeThresh, 0, 0, 200, 20);
  ets.setId(edgeThreshSlider);
  ets.setColorLabel(color(0.0));
}

public void setupMouseWheel() {
  // thanks to example code from Processing forums, by Guillaume LaBelle
  // http://ingallian.design.uqam.ca/goo/P55/ImageExplorer/
  addMouseWheelListener(new java.awt.event.MouseWheelListener() {
    public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) {
      int notches = evt.getWheelRotation();
      if(notches!=0){
        //println(notches);
        float oldCenterX = panX + width / (2 * zoom);
        float oldCenterY = panY + height / (2 * zoom);

        zoom *= (1.0 - 0.20 * notches);
        //zoomFactor+=notches*-0.05;
        if(zoom < 0.3)
          zoom = 0.3;
        if(zoom > 5.0)
          zoom = 5.0;

        panX = oldCenterX - width / (2 * zoom);
        panY = oldCenterY - height / (2 * zoom);

      }
    }
  }
  );
}

public void controlEvent(ControlEvent e) {
  switch(e.controller().id()) {
    case(edgeThreshSlider):
    edgeThresh = e.controller().value();
    break;
  }
}

void mouseDragged() {
  int dx = mouseX - prevMouseX;
  int dy = mouseY - prevMouseY;

  if(centerMBHeld) { // pan view
    panX -= dx / zoom;
    panY -= dy / zoom;
  }  
  else if(nodeAsserting != -1) { // assert evidence
    int value = -1;
    if(mouseY - ryPress > 10)
      value = 0;
    else if(mouseY - ryPress < -10)
      value = 1;
    
    nodes[nodeAsserting].asserted = value;
    previewEvidence(nodeAsserting, value);
    //animateAssertion();
  }
  else if(nodeDragged != -1) { // drag node
    nodes[nodeDragged].nodePosition[0] += dx / zoom;
    nodes[nodeDragged].nodePosition[1] += dy / zoom;
  }

  prevMouseX = mouseX;
  prevMouseY = mouseY;
}

void mouseMoved() {
  prevMouseX = mouseX;
  prevMouseY = mouseY;

  boolean oneHighlighted = false;
  for(int i = 0; i < nodes.length; i++) {
    if(!oneHighlighted && nodes[i].pointInBounds(mouseX / zoom + panX, mouseY / zoom + panY)) {
      nodes[i].highlight = true;
      oneHighlighted = true;
    }
    else
      nodes[i].highlight = false;
  }
}

void mousePressed() {
  if(mouseButton == LEFT) {
    for(int i = 0; i < nodes.length; i++) {
      if(nodes[i].pointInBounds(mouseX / zoom + panX, mouseY / zoom + panY)) {
        nodeDragged = i;
        break;
      }
    }
    lxPress = mouseX;
    lyPress = mouseY;
    if(nodeDragged == -1)
      draggingSelection = true;
    leftMBHeld = true;
  }
  if(mouseButton == RIGHT) {
    for(int i = 0; i < nodes.length; i++) {
      if(nodes[i].pointInBounds(mouseX / zoom + panX, mouseY / zoom + panY)) {
        nodeAsserting = i;
        rxPress = mouseX;
        ryPress = mouseY;
        previewEvidence(i, -1);
        nodes[i].asserted = -1;
        //animateAssertion();
        break;
      }
    }  
    rightMBHeld = true;
  }
  if(mouseButton == CENTER) {
    centerMBHeld = true;
  }
}

void mouseReleased() {
  if(mouseButton == LEFT) { 
    leftMBHeld = false;
    if(draggingSelection)
      doSelectionBox();
    draggingSelection = false;
    nodeDragged = -1;
  }
  if(mouseButton == RIGHT) {
    rightMBHeld = false;
    if(nodeAsserting != -1) {
      assertCurrentEvidence(nodeAsserting);
      animateAssertion();
      nodeAsserting = -1;
    }
  }
  if(mouseButton == CENTER)
    centerMBHeld = false;
}

void keyPressed() {
  switch(key) {
    case 'e':
    drawEdges = !drawEdges;
    break;
    
    case SHIFT:
    shiftHeld = true;
    break;
    
    case CONTROL:
    controlHeld = true;
    break;
  }
}

void keyReleased() {
  switch(key) {
    case SHIFT:
    shiftHeld = false;
    break;
    
    case CONTROL:
    controlHeld = false;
    break;
  }
}
