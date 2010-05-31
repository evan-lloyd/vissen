import java.awt.event.*;
import java.util.*;

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
    float oldCenterX = panX + width / (2 * zoom);
    float oldCenterY = panY + height / (2 * zoom);
  
    zoom *= (1.0 - 0.20 * (zoomIn ? -keyZoomSpeed : keyZoomSpeed));
    //zoomFactor+=notches*-0.05;
    if(zoom < 0.3)
      zoom = 0.3;
    if(zoom > 5.0)
      zoom = 5.0;
  
    panX = oldCenterX - width / (2 * zoom);
    panY = oldCenterY - height / (2 * zoom);
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
  if(selectedNodes == null)
    return false;
    
  for(int j = 0; j < selectedNodes.length; j++) {
    if(selectedNodes[j] == i)
      return true;
  }
  return false;
}

public void doNodeClicked(int i) {
  if(controlHeld)
    nodes[i].selected = !nodes[i].selected;
  else if(shiftHeld)
    nodes[i].selected = true;
    
  if(controlHeld || shiftHeld) {
    if(nodes[i].selected) { // add to selection
      if(currentlySelected(i)) // already in selectedNodes
        return;
      Integer [] temp = new Integer[selectedNodes.length + 1];
      
      if(selectedNodes != null)
      for(int j = 0; j < selectedNodes.length; j++)
        temp[j] = selectedNodes[j];
      temp[selectedNodes.length] = i;
      selectedNodes = temp;
    }
    else{ // remove from selection
      Integer [] temp = new Integer[selectedNodes.length - 1];
      int pos = 0;
      
      if(selectedNodes != null)
      for(int j = 0; j < selectedNodes.length; j++) {
        if(selectedNodes[j] != i)
          temp[pos++] = selectedNodes[j];
      }
      selectedNodes = temp;
    }
  }
  else if(!(nodes[i].selected && max(abs(mouseX - lxPress), abs(mouseY - lyPress)) > moveSelectThresh)){ // set as only selection
    for(int j = 0; j < nodes.length; j++)
      nodes[j].selected = false;
    selectedNodes = new Integer[1];
    selectedNodes[0] = i;
    nodes[i].selected = true;
  }
}

public void doSelectionBox() {
  int x1 = min(mouseX, lxPress);
  int x2 = max(mouseX, lxPress);
  int y1 = min(mouseY, lyPress);
  int y2 = max(mouseY, lyPress);
  
  Vector nodesToSelect = null;
  if(selectedNodes != null && (controlHeld || shiftHeld))
    nodesToSelect = new Vector(Arrays.asList(selectedNodes));
  else
    nodesToSelect = new Vector();
  
  for(int i = 0; i < nodes.length; i++) {
    if(boxIntersectsNode(x1, x2, y1, y2, i)) {
      if(shiftHeld && !currentlySelected(i))
        nodesToSelect.add(i);
      else if(controlHeld) {
        if(currentlySelected(i))
          nodesToSelect.remove(new Integer(i));
        else
          nodesToSelect.add(i);
      }
      else if(!shiftHeld)
        nodesToSelect.add(i);
    }
    
    nodes[i].selected = false;
  }
  
  if(nodesToSelect.size() == 0)
    selectedNodes = null;
  else {
    selectedNodes = new Integer[nodesToSelect.size()];
    nodesToSelect.copyInto(selectedNodes);
  }
  
  if(selectedNodes != null)
  for(int i = 0; i < selectedNodes.length; i++) {
    nodes[selectedNodes[i]].selected = true;
  }
}

public void setupControls() {
  setupMouseWheel();
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

void updateControlVisibility(int oldMode, int newMode) {
  switch (oldMode) {
    case renderSettingsInfo:
    controlP5.controller("edgeThresh").hide();
    break;
    case selectedTermsInfo:
    break;
  }
  switch (newMode) {
    case renderSettingsInfo:
    controlP5.controller("edgeThresh").show();
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
  
  if(e.isGroup()) { // info tab
    infoTabVisible = !infoTabVisible;
    if(infoTabVisible)
      controlP5.getGroup("infoTab").setPosition(5, height - 200);
    else
      controlP5.getGroup("infoTab").setPosition(5, height - 4);
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
    if(selectedNodes != null) {
      if(!nodes[nodeDragged].selected) {
        doNodeClicked(nodeDragged);
      }
      for(int i = 0; i < selectedNodes.length; i++) {
        nodes[selectedNodes[i]].nodePosition[0] += dx / zoom;
        nodes[selectedNodes[i]].nodePosition[1] += dy / zoom;
      }
    }
    
    
    if(!nodes[nodeDragged].selected) {
      nodes[nodeDragged].nodePosition[0] += dx / zoom;
      nodes[nodeDragged].nodePosition[1] += dy / zoom;
    }
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
    if(nodeDragged != -1)
      doNodeClicked(nodeDragged);
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
