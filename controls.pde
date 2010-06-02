import java.awt.event.*;
import java.util.*;

int infoTabHeight = 150;

void setupInterface() {
  controlP5 = new ControlP5(this);
  
  infoTab = controlP5.addGroup("infoTab", 5, height - infoTabHeight, width - 10);
  
  controlP5.addButton("renderSettingsTab", 0, 5, 5, 100, 20).setGroup(infoTab);
  controlP5.controller("renderSettingsTab").setLabel("Render Settings");
  controlP5.addButton("selectedTermsTab", 0, 110, 5, 100, 20).setGroup(infoTab);
  controlP5.controller("selectedTermsTab").setLabel("Selected Terms");
  
  controlP5.controller("selectedTermsTab").captionLabel().toUpperCase(false);
  controlP5.controller("renderSettingsTab").captionLabel().toUpperCase(false);
  controlP5.controller("renderSettingsTab").setMoveable(false);
  controlP5.controller("selectedTermsTab").setMoveable(false);
  
  controlP5.addSlider("edgeThresh", edgeThreshMin, edgeThreshMax, edgeThresh, 5, 35, 200, 20).setGroup(infoTab);
  controlP5.controller("edgeThresh").setColorLabel(color(0.0));
  controlP5.controller("edgeThresh").setMoveable(false);
  controlP5.controller("edgeThresh").setLabel("Edge drawing threshold");
  controlP5.controller("edgeThresh").captionLabel().toUpperCase(false);
  
  controlP5.addToggle("showPositive", showPositive, 5, 60, 20, 20).setGroup(infoTab);
  controlP5.controller("showPositive").setColorLabel(color(0.0));
  controlP5.controller("showPositive").setMoveable(false);
  controlP5.controller("showPositive").captionLabel().toUpperCase(false);
  controlP5.controller("showPositive").setLabel("Show positive connections");
  
  controlP5.addToggle("showNegative", showNegative, 5, 95, 20, 20).setGroup(infoTab);
  controlP5.controller("showNegative").setColorLabel(color(0.0));
  controlP5.controller("showNegative").setMoveable(false);
  controlP5.controller("showNegative").captionLabel().toUpperCase(false);
  controlP5.controller("showNegative").setLabel("Show negative connections");

  
  infoTab.captionLabel().toUpperCase(false);
  infoTab.setLabel("");
  
  infoTab.setBackgroundColor(statusBackground);
  infoTab.setBackgroundHeight(infoTabHeight - 5);
  infoTab.setBarHeight(20);
  infoTab.setMoveable(false);
//  infoTab.setId(infoTab);
  infoTab.activateEvent(true);

  controlP5.setControlFont(controlsSmall);
  controlP5.setAutoDraw(false);
  
}

public void updateControls() {
  if(panLeft)
    panX -= keyPanSpeed;
  if(panRight)
    panX += keyPanSpeed;
  if(panUp)
    panY -= keyPanSpeed;
  if(panDown)
    panY += keyPanSpeed;
  
  if(zoomIn || zoomOut) {
    doZoom(zoomIn ? -keyZoomSpeed : keyZoomSpeed);
  }
}

boolean boxIntersectsNode(int x1, int x2, int y1, int y2, int i) {
  PVector upperLeft = worldToScreen(nodes[i].nodePosition[0] - nodes[i].nodeSize,
                                    nodes[i].nodePosition[1] - nodes[i].nodeSize);
  PVector lowerRight = worldToScreen(nodes[i].nodePosition[0] + nodes[i].nodeSize,
                                     nodes[i].nodePosition[1] + nodes[i].nodeSize);
  
  return !(upperLeft.x > x2 || lowerRight.x < x1 || upperLeft.y > y2 || lowerRight.y < y1);
}

boolean currentlySelected(int i) {
  return selectedNodes.contains(i);
  //for(int j = 0; j < selectedNodes.size(); j++) {
    //if(selectedNodes.get(j) == i)
      //return true;
  //}
//  return false;
}

public void selectNode(int i, boolean s) {
  if(i < 0)
    return;
    
  if(s && !currentlySelected(i)) {
    selectedNodes.add(i);
    nodes[i].selected = true;
  }
  else if(!s && currentlySelected(i)) {
    selectedNodes.remove(new Integer(i));
    nodes[i].selected = false;
  }
}

public void toggleNodeSelection(int i) {
  selectNode(i, !currentlySelected(i));
}

public void selectNode(int i) {
  if(i < 0)
    return;
  if(!currentlySelected(i))
    selectedNodes.add(i);
  nodes[i].selected = true;
}

public void clearNodeSelection() {
  selectedNodes.clear();
  for(int i = 0; i < nodes.length; i++) {
    nodes[i].selected = false;
  }
}

public void doNodeClicked(int i) {
  if(!controlHeld && !shiftHeld)
    clearNodeSelection();
    
  if(controlHeld)
    toggleNodeSelection(i);
  else
    selectNode(i);
}

public void doSelectionBox() {
  int x1 = min(mouseX, lxPress);
  int x2 = max(mouseX, lxPress);
  int y1 = min(mouseY, lyPress);
  int y2 = max(mouseY, lyPress);
  
  if(!controlHeld && !shiftHeld)
    clearNodeSelection();
  
  for(int i = 0; i < nodes.length; i++) {
    if(boxIntersectsNode(x1, x2, y1, y2, i)) {
      if(controlHeld)
        toggleNodeSelection(i);
      else
        selectNode(i);
    }
    
  }
  
}

public void setupControls() {
  setupMouseWheel();
}

public void doZoom(float notches) {
      //println(notches);
    float oldCenterX = panX + width / (2 * zoom);
    float oldCenterY = panY + height / (2 * zoom);

    zoom *= (1.0 - 0.20 * notches);
    //zoomFactor+=notches*-0.05;
    if(zoom < minZoom)
      zoom = minZoom;
    if(zoom > maxZoom)
      zoom = maxZoom;

    panX = oldCenterX - width / (2 * zoom);
    panY = oldCenterY - height / (2 * zoom);
}

public void setupMouseWheel() {
  // thanks to example code from Processing forums, by Guillaume LaBelle
  // http://ingallian.design.uqam.ca/goo/P55/ImageExplorer/
  addMouseWheelListener(new java.awt.event.MouseWheelListener() {
    public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) {
      int notches = evt.getWheelRotation();
      if(notches!=0){
        doZoom(notches);
      }
    }
  }
  );
}

void updateControlVisibility(int oldMode, int newMode) {
  switch (oldMode) {
    case renderSettingsInfo:
    controlP5.controller("edgeThresh").hide();
    controlP5.controller("showNegative").hide();
    controlP5.controller("showPositive").hide();
    break;
    case selectedTermsInfo:
    break;
  }
  switch (newMode) {
    case renderSettingsInfo:
    controlP5.controller("edgeThresh").show();
    controlP5.controller("showNegative").show();
    controlP5.controller("showPositive").show();
    break;
    case selectedTermsInfo:
    break;
  }
}

void renderSettingsTab() {
  updateControlVisibility(infoTabMode, renderSettingsInfo);
  infoTabMode = renderSettingsInfo;
}

void selectedTermsTab() {
  updateControlVisibility(infoTabMode, selectedTermsInfo);
  infoTabMode = selectedTermsInfo;
}

public void controlEvent(ControlEvent e) {
  draggingSelection = false;
  
  if(e.isGroup()) {
    if(e.group() == infoTab) {
      infoTabVisible = !infoTabVisible;
      if(infoTabVisible)
        infoTab.setPosition(5, height - infoTabHeight);
      else
        infoTab.setPosition(5, height - 4);
    }
  }
}

void dragSelectedNodes(float dx, float dy) {
  if(dynamicLayout)
    updateDragTargets(dx, dy);
  else
    for(int i = 0; i < selectedNodes.size(); i++) {
      Node n = nodes[(Integer)selectedNodes.get(i)];
      n.nodePosition[0] += dx;
      n.nodePosition[1] += dy;
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
  
      if(dragStarting) {
        if(!nodes[nodeDragged].selected)
          doNodeClicked(nodeDragged);
        if(dynamicLayout)
          startPhysicsDrag(selectedNodes);
          
        dragStarting = false;
      }
      
      dragSelectedNodes(dx / zoom, dy / zoom);
  }

  prevMouseX = mouseX;
  prevMouseY = mouseY;
}

void mouseMoved() {
  prevMouseX = mouseX;
  prevMouseY = mouseY;

  boolean oneHighlighted = false;
  for(int i = 0; i < nodes.length; i++) {
    if(!oneHighlighted && nodes[i].pointInBounds(screenToWorld(mouseX, mouseY))) {
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
      if(nodes[i].pointInBounds(screenToWorld(mouseX, mouseY))) {
        nodeDragged = i;
        dragStarting = true;
        break;
      }
    }
    lxPress = mouseX;
    lyPress = mouseY;

    if(nodeDragged == -1 && !altHeld)
      draggingSelection = true;
    leftMBHeld = true;
  }
  if(mouseButton == RIGHT) {
    for(int i = 0; i < nodes.length; i++) {
      if(nodes[i].pointInBounds(screenToWorld(mouseX, mouseY))) {
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
    if(dragStarting) // didn't actually drag
      doNodeClicked(nodeDragged);
    if(draggingSelection)
      doSelectionBox();
    draggingSelection = false;
    nodeDragged = -1;
    
    // don't check that we're in physics mode, since it *could* have been turned off since we started
    endPhysicsDrag();
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
    case 'n':
    resetNetwork();
    break;
    case 'e':
    drawEdges = !drawEdges;
    break;
    case 'r':
    dynamicLayout = !dynamicLayout;
    if(dynamicLayout)
      resetLayout();
    break;
    
    case 'a':
    panLeft = true;
    break;
    case 's':
    panDown = true;
    break;
    case 'd':
    panRight = true;
    break;
    case 'w':
    panUp = true;
    break;
    
    case '+':
    case '=':
    zoomIn = true;
    break;
    case '-':
    zoomOut = true;
    break;
    
    case CODED:
    switch(keyCode) {
      case SHIFT:
      shiftHeld = true;
      break;
    
      case CONTROL:
      controlHeld = true;
      break;
      
      case ALT:
      altHeld = true;
      break;
    }
    break;
  }
}

void keyReleased() {
  switch(key) {
    case 'a':
    panLeft = false;
    break;
    case 's':
    panDown = false;
    break;
    case 'd':
    panRight = false;
    break;
    case 'w':
    panUp = false;
    break;
    
    case '+':
    case '=':
    zoomIn = false;
    break;
    case '-':
    zoomOut = false;
    break;
    
    case CODED:
    switch(keyCode) {
      case SHIFT:
      shiftHeld = false;
      break;
    
      case CONTROL:
      controlHeld = false;
      break;
      
      case ALT:
      altHeld = false;
      break;
    }
    break;
  }
}
