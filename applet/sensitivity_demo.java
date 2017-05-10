import processing.core.*; 
import processing.xml.*; 

import java.util.*; 
import java.awt.*; 
import controlP5.*; 
import java.awt.event.*; 
import java.util.*; 
import traer.physics.*; 
import java.io.*; 

import il2.inf.structure.*; 
import il2.bridge.*; 
import il2.inf.rc.*; 
import edu.ucla.belief.io.geneticlinkage.*; 
import edu.ucla.belief.io.netica.*; 
import edu.ucla.belief.inference.*; 
import edu.ucla.belief.recursiveconditioning.*; 
import edu.ucla.belief.uai2006.*; 
import il2.inf.bp.*; 
import edu.ucla.belief.dtree.*; 
import controlP5.*; 
import il2.inf.map.*; 
import il2.inf.jointree.*; 
import edu.ucla.belief.tree.*; 
import edu.ucla.belief.approx.*; 
import edu.ucla.belief.rc2.caching.*; 
import edu.ucla.belief.io.dsl.*; 
import edu.ucla.util.code.*; 
import edu.ucla.belief.rc2.kb.*; 
import edu.ucla.belief.learn.*; 
import il2.inf.*; 
import edu.ucla.belief.*; 
import edu.ucla.belief.rc2.tools.*; 
import edu.ucla.belief.rc2.structure.*; 
import edu.ucla.belief.io.xmlbif.*; 
import il2.model.*; 
import il2.util.*; 
import edu.ucla.belief.rc2.kb.sat.*; 
import traer.physics.*; 
import il2.inf.bp.schedules.*; 
import edu.ucla.belief.inference.map.*; 
import il2.inf.structure.minfill2.*; 
import edu.ucla.structure.*; 
import edu.ucla.belief.io.*; 
import edu.ucla.belief.io.hugin.*; 
import edu.ucla.util.*; 
import edu.ucla.belief.rc2.creation.*; 
import edu.ucla.belief.sensitivity.*; 
import il2.inf.edgedeletion.*; 
import edu.ucla.belief.decision.*; 
import il2.inf.experimental.*; 
import edu.ucla.belief.rc2.io.*; 
import il2.inf.mini.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class sensitivity_demo extends PApplet {




double sens[][][];

public void setup() {
  size(800, 800);

  initNetwork();

  frameRate(60);
  smooth();
  setColorsAndFonts();
  setupControls();
  setupInterface();
  
  // cheap hack to center and size right for 800x800
  doZoom(1);
  panY += 100;
  
  initLayout();
}

public void assertEvidence(int n, int value) {
  try {
    if(value == -1)
      evidence.unobserve(graphNodes[n]);
    else if(value == 0)
      evidence.observe(graphNodes[n], "F");
    else if(value == 1)
      evidence.observe(graphNodes[n], "T");
  } 
  catch (StateNotFoundException e) {
  }
  nodes[n].asserted = value;
}

public void previewEvidence(int n, int value) {
  Object oldValue = evidence.getValue(graphNodes[n]);
  try {
    if(value == -1)
      evidence.unobserve(graphNodes[n]);
    else if(value == 0)
      evidence.observe(graphNodes[n], "F");
    else if(value == 1)
      evidence.observe(graphNodes[n], "T");
      
    for(int i = 0; i < nodes.length; i++) {
      if(nodes[i].asserted == -1 && i != nodeAsserting)
        nodes[i].previewNewP(Prob.logOdds(engine.conditional(graphNodes[i]).getCP(1)));
    }
    
    if(oldValue == null) {
      evidence.unobserve(graphNodes[n]);
    }
    else
      evidence.observe(graphNodes[n], oldValue);
  }
  catch (StateNotFoundException e) {
  }
}

public void assertCurrentEvidence(int n) {
  assertEvidence(nodeAsserting, nodes[nodeAsserting].asserted);
}

ControlP5 controlP5;

// Key states
boolean leftMBHeld, rightMBHeld, centerMBHeld;
int lxPress, lyPress, rxPress, ryPress, cxPress, cyPress; // location of mouse at button press event
int prevMouseX, prevMouseY;

// Navigation parameters
boolean panUp = false, panDown = false, panLeft = false, panRight = false;
boolean zoomIn = false, zoomOut = false;
public float panX = 0, panY = 0;

public float zoom = 1.0f;
public float minZoom = 0.3f;
public float maxZoom = 4.0f;

int keyPanSpeed = 20;
float keyZoomSpeed = 0.5f;

// Manipulation state
boolean shiftHeld, controlHeld, altHeld;
boolean draggingSelection;
boolean dragStarting;

// Info tab modes
ControlGroup infoTab;
boolean infoTabVisible = true;
int infoTabMode = 0;
public static final int renderSettingsInfo = 0;
public static final int selectedTermsInfo = 1;

// Rendering controls
float edgeThreshMin = 0.0f;
float edgeThreshMax = 10.0f;
float edgeThresh = 5.0f;
boolean showNegative = true;
boolean showPositive = true;

int nodeDragged = -1;
int nodeAsserting = -1;
Vector selectedNodes = new Vector();

// TODO: base on held time?
public static final int moveSelectThresh = 1; // how much can node move to count as a "click" instead of drag?

// Render settings controls
public static final int edgeThreshSlider = 0;
//public static final int infoTab = 1;



int infoTabHeight = 150;

public void setupInterface() {
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
  controlP5.controller("edgeThresh").setColorLabel(color(0.0f));
  controlP5.controller("edgeThresh").setMoveable(false);
  controlP5.controller("edgeThresh").setLabel("Edge drawing threshold");
  controlP5.controller("edgeThresh").captionLabel().toUpperCase(false);
  
  controlP5.addToggle("showPositive", showPositive, 5, 60, 20, 20).setGroup(infoTab);
  controlP5.controller("showPositive").setColorLabel(color(0.0f));
  controlP5.controller("showPositive").setMoveable(false);
  controlP5.controller("showPositive").captionLabel().toUpperCase(false);
  controlP5.controller("showPositive").setLabel("Show positive connections");
  
  controlP5.addToggle("showNegative", showNegative, 5, 95, 20, 20).setGroup(infoTab);
  controlP5.controller("showNegative").setColorLabel(color(0.0f));
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

public boolean boxIntersectsNode(int x1, int x2, int y1, int y2, int i) {
  PVector upperLeft = worldToScreen(nodes[i].nodePosition[0] - nodes[i].nodeSize,
                                    nodes[i].nodePosition[1] - nodes[i].nodeSize);
  PVector lowerRight = worldToScreen(nodes[i].nodePosition[0] + nodes[i].nodeSize,
                                     nodes[i].nodePosition[1] + nodes[i].nodeSize);
  
  return !(upperLeft.x > x2 || lowerRight.x < x1 || upperLeft.y > y2 || lowerRight.y < y1);
}

public boolean currentlySelected(int i) {
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

    zoom *= (1.0f - 0.20f * notches);
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

public void updateControlVisibility(int oldMode, int newMode) {
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

public void renderSettingsTab() {
  updateControlVisibility(infoTabMode, renderSettingsInfo);
  infoTabMode = renderSettingsInfo;
}

public void selectedTermsTab() {
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

public void dragSelectedNodes(float dx, float dy) {
  if(dynamicLayout)
    updateDragTargets(dx, dy);
  else
    for(int i = 0; i < selectedNodes.size(); i++) {
      Node n = nodes[(Integer)selectedNodes.get(i)];
      n.nodePosition[0] += dx;
      n.nodePosition[1] += dy;
    }
}

public void mouseDragged() {
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

public void mouseMoved() {
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

public void mousePressed() {
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

public void mouseReleased() {
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

public void keyPressed() {
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

public void keyReleased() {
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


ParticleSystem particles = new ParticleSystem(0.0f, 0.9999f);

Vector dragSprings = new Vector();
Vector dragTargets = new Vector();

public void updateDragTargets(float dx, float dy) {
  for(int i = 0; i < dragTargets.size(); i++) {
    Particle t = (Particle)dragTargets.get(i);
    t.position().add(dx, dy, 0.0f);
  }
}

public void startPhysicsDrag(Vector toDrag) {
  for(int i = 0; i < toDrag.size(); i++) {
    Integer j = (Integer)toDrag.get(i);
    Particle target = particles.makeParticle(1.0f, nodes[j].nodePosition[0], nodes[j].nodePosition[1], 0.0f);
    target.makeFixed();
    dragTargets.add(target);
    Spring spring = particles.makeSpring(particles.getParticle(j + 1), target, 10000, 1000, 0);
    dragSprings.add(spring);
  }
}

public void endPhysicsDrag() {
  for(int i = 0; i < dragSprings.size(); i++) {
    particles.removeSpring((Spring)dragSprings.get(i));
  }
  for(int i = 0; i < dragTargets.size(); i++) {
    particles.removeParticle((Particle)dragTargets.get(i));
  }
  dragSprings.clear();
  dragTargets.clear();
}

boolean layoutInitialized = false;
float sensScale = 100000;
public void initLayout() {
  layoutInitialized = true;
  // attach nodes to centroid by springs to keep them from flying too far away
  float cx = 0, cy = 0;
  for(int i = 0; i < nodes.length; i++) {
    cx += nodes[i].nodePosition[0];
    cy += nodes[i].nodePosition[1];
  }
  cx /= nodes.length;
  cy /= nodes.length;
  
  Particle centroidPoint = particles.makeParticle(1.0f, cx, cy, 0);
  centroidPoint.makeFixed();
  
  for(int i = 0; i < nodes.length; i++) {
    // TODO: mass based on size?
    particles.makeParticle(nodes[i].nodeSize, nodes[i].nodePosition[0], nodes[i].nodePosition[1], 0.0f);
    particles.makeSpring(particles.getParticle(i+1), centroidPoint, 1000, 800, 0);
  }
  
  for(int i = 0; i < nodes.length; i++) {
    for(int j = 0; j < nodes.length; j++) {
      if(i == j)
        continue;
      particles.makeAttraction(particles.getParticle(i+1), particles.getParticle(j+1), min(10.0f, max(-10.0f, (float)sens[i][j][1]))*sensScale, 10);
      
      if(j > i)
        particles.addCustomForce(new NodeConstraintForce(particles.getParticle(i+1), particles.getParticle(j+1), nodes[i], nodes[j]));
    }
  }
}

public void updateLayout() {
  if(!layoutInitialized)
    return;
  int count = 0;
  for(int i = 0; i < nodes.length; i++) {
    for(int j = 0; j < nodes.length; j++) {
      if(i == j)
        continue; 
      particles.getAttraction(count++).setStrength((float)sens[i][j][1] * sensScale);
    }
  }
}

public void resetLayout() {
  for(int i = 0; i < nodes.length; i++) {
    Particle p = particles.getParticle(i + 1);
    p.position().set(nodes[i].nodePosition[0], nodes[i].nodePosition[1], 0.0f);
    p.velocity().set(0, 0, 0);
  }
}

public void layoutTick() {
  particles.tick(0.001f);
  for(int i = 0; i < nodes.length; i++) {
    Particle p = particles.getParticle(i + 1);
    nodes[i].nodePosition[0] = round(p.position().x());
    nodes[i].nodePosition[1] = round(p.position().y());
  }
}

public class NodeConstraintForce implements Force {
  Particle p1, p2;
  Node n1, n2;
  
  static final float border = 30;
  static final float borderSq = 100;
  
  NodeConstraintForce(Particle part1, Particle part2, Node node1, Node node2) {
    p1 = part1;
    p2 = part2;
    n1 = node1;
    n2 = node2;
  }
  
  public boolean isOff() {
    return !isOn();
  }
  public boolean isOn() {
    return true;
  }
  public void turnOn() {
    return;
  }
  public void turnOff() {
    return;
  }
  
  public void apply() {
    // get point on p1 closest to p2
    float dx = p2.position().x() - p1.position().x();
    float dy = p2.position().y() - p1.position().y();
    float n = sqrt(dx * dx + dy * dy);
    if(n > n1.nodeSize + n2.nodeSize + border) // can't be inside
      return;
    dx /= n;
    dy /= n;
    // TODO: handle small n
    
    float pointX = p1.position().x() + dx * n1.nodeSize;
    float pointY = p1.position().y() + dy * n1.nodeSize;
    
    dx = (p2.position().x() - pointX);
    dy = (p2.position().y() - pointY);
    n = dx * dx + dy * dy;
    float dn = n2.nodeSize + border - sqrt(n);
    dx /= n;
    dy /= n;
    float dnSq = dn * dn * 100000;
    //n *= 1000;/// n2.nodeSize;
    
    p1.force().add(-dx*dnSq, -dy*dnSq, 0);
    p2.force().add(dx*dnSq, dy*dnSq, 0);
  }
}


BeliefNetwork net = null;
EvidenceController evidence = null;
InferenceEngine engine = null;
HuginNode graphNodes[] = null;

public void resetNetwork() {
  Point pt = new Point();
  for(int i = 0; i < nodes.length; i++) {
    nodes[i].nodePosition[0] = graphNodes[i].getLocation(pt).x;
    nodes[i].nodePosition[1] = graphNodes[i].getLocation(pt).y;
  }

  if(dynamicLayout) {
    dynamicLayout = false;
  }  
  clearNodeSelection();
  evidence.resetEvidence();
}

public void initNetwork() {
  net = loadNetwork("pubmedquery.net");
  evidence = net.getEvidenceController();
  JEngineGenerator gen = new JEngineGenerator();
  gen.getSettings((PropertySuperintendent)net, true).setEliminationHeuristic(EliminationHeuristic.MIN_FILL);
  engine = gen.manufactureInferenceEngine(net);

  Object v[] = net.vertices().toArray();
  graphNodes = new HuginNode[net.vertices().size()];
  nodes = new Node[net.vertices().size()];
  
  Point pt = new Point();

  float minX = Float.MAX_VALUE, maxX = -Float.MAX_VALUE;
  float minY = Float.MAX_VALUE, maxY = -Float.MAX_VALUE;
  
  sens = new double[nodes.length][][];

  for(int i = 0; i < nodes.length; i++) {
    graphNodes[i] = (HuginNode)v[i];
    nodes[i] = new Node();
    nodes[i].nodePosition[0] = graphNodes[i].getLocation(pt).x;
    nodes[i].nodePosition[1] = graphNodes[i].getLocation(pt).y;
    nodes[i].nodeLabel = graphNodes[i].getLabel();
    
    minX = min(minX, graphNodes[i].getLocation(pt).x);
    minY = min(minY, graphNodes[i].getLocation(pt).y);
    maxX = max(maxX, graphNodes[i].getLocation(pt).x);
    maxY = max(maxY, graphNodes[i].getLocation(pt).y);
    
    sens[i] = new double[nodes.length][];
    for(int j = 0; j < nodes.length; j++)
      sens[i][j] = new double[2];
  }
  
  minP = Double.MAX_VALUE;
  maxP = -Double.MAX_VALUE;
  for(int i = 0; i < nodes.length; i++) {
    double p = Prob.logOdds(engine.conditional(graphNodes[i]).getCP(1));

    minP = Math.min(minP, p);
    maxP = Math.max(maxP, p);
  }
  
  panX = (maxX - minX - width) / 2;
  panY = (maxY + minY - height) / 2;

  rescaleNodes();
}

public BeliefNetwork loadNetwork(String fileName) {
  byte bytes[] = loadBytes(fileName);
  HuginReader reader = new HuginReader(new ByteArrayInputStream(bytes));
  try {
  return reader.beliefNetwork();
  }
  catch (edu.ucla.belief.io.ParseException e){
  }
  return null;
}

public void animateAssertion() {
  rescaleNodes();
}

public void updateP() {
  curP = engine.probability();
  statusString = "Number of papers matching current filters: " + Integer.toString((int)(curP * nPapers + 0.5f)) + " / " + Integer.toString(nPapers);
}

public void rescaleNodes() {
  for(int i = 0; i < nodes.length; i++) {
    if(nodes[i].asserted != -1)
      continue;
    double p = Prob.logOdds(engine.conditional(graphNodes[i]).getCP(1));
    nodes[i].setP(p);
  }

  for(int i = 0; i < nodes.length; i++) {
    if(nodes[i].asserted == -1)
      nodes[i].setScale(nodes[i].p, minP, maxP);
  }
  
  for(int i = 0; i < nodes.length; i++) {
    if(nodes[i].asserted != -1)
      continue;
    try {
      evidence.observe(graphNodes[i], "F");
    }
    catch (StateNotFoundException e) {}
    
    for(int j = 0; j < nodes.length; j++) {
      if(i == j || nodes[j].asserted != -1)
        continue;
      sens[i][j][0] = Prob.logOdds(engine.conditional(graphNodes[j]).getCP(1)) - nodes[j].p;
    }
    
    try {
      evidence.observe(graphNodes[i], "T");
    }
    catch (StateNotFoundException e) {}
    
    for(int j = 0; j < nodes.length; j++) {
      if(i == j || nodes[j].asserted != -1)
        continue;
      sens[i][j][1] = Prob.logOdds(engine.conditional(graphNodes[j]).getCP(1)) - nodes[j].p;
    }

    evidence.unobserve(graphNodes[i]);
  }

  updateP();
  updateLayout();
}
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
  
  public void draw() {
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
    
    strokeWeight(3.0f * zoom);
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
        strokeWeight(10.0f * zoom);
        float lineLen = lerp(10, 50, (float)Math.abs(dp));
      if(dp > 0.01f) {
        stroke(nodeTrueColor);
        line(x(), y(), x(), yOff(-lineLen));
      }
      else if(dp < -0.01f) {
        stroke(nodeFalseColor);
        line(x(), y(), x(), yOff(lineLen));
      }
    }
  }
  
  public void previewNewP(double newp) {
    dp = newp - p;
    showDP = true;
  }
  
  public void setP(double pval) {
    p = pval;
    if(pval == Double.POSITIVE_INFINITY)
      pString = "Certain";
    else if(pval == Double.NEGATIVE_INFINITY)
      pString = "Impossible";
    else
      pString = String.format("%.3f", pval);
    showDP = false;
  }
  
  public float xOff(float off) {
    return worldToScreenX(nodePosition[0] + off);
  }
  
  public float yOff(float off) {
    return worldToScreenY(nodePosition[1] + off);
  }
  
  public float x() { 
    return worldToScreenX(nodePosition[0]);
  }
  public float y() {
    return worldToScreenY(nodePosition[1]);
  }
  
  public void setScale(double val, double lower, double upper) {
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
  
  public void update() {
  }
  
  public boolean pointInBounds(PVector p) {
    float dx = p.x - nodePosition[0];
    float dy = p.y - nodePosition[1];
    
    if((dx * dx + dy * dy) <= radiusSq)
      return true;
      
    return false;
  }
}
public void setColorsAndFonts() {
  colorMode(HSB, 1.0f);
  nodeDefaultColor = color(0);
  nodeSelectedColor = color(220.0f / 360.0f, .48f, 1.0f);
  nodeHighlightColor = color(62.0f / 360.0f, 0.8f, 0.8f);
  selectionBoxColor = color(220.0f / 360.0f, .48f, 1.0f, 0.5f);
  nodeUnobservedColor = color(0.92f);
  nodeTrueColor = color(113.0f / 360, .49f, .82f);
  nodeFalseColor = color(13.0f / 360, .49f, .82f);
  bgColor = color(1.0f);
  
  nodeFont = loadFont("nodeLabel.vlw");
  controlsSmall = loadFont("controlsSmall.vlw");
  controlsLarge = loadFont("controlsLarge.vlw");
  
  statusBackground = color(220.0f/360.0f, .48f, 1.0f);
}

public void drawInfoTab() {
  if(infoTabMode == selectedTermsInfo) {
    fill(nodeDefaultColor);
    textFont(controlsLarge, 18);
    textSize(18);
    
    text(statusString, 10, height - infoTabHeight + 55);
  }
}

public void drawEdges() { 
  strokeWeight(6.0f * zoom);
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

public void drawNodes() { 
  for(int i = nodes.length - 1; i >= 0; i--) {
    nodes[i].draw();
  }
}

public void draw() {
  updateControls();
  
  if(dynamicLayout)
    layoutTick();
  
  background(bgColor);
  
  if(drawEdges)
    drawEdges();
  
  drawNodes();
  
  if(draggingSelection) { // draw selection box
      stroke(nodeDefaultColor);
      strokeWeight(2.0f);
      fill(selectionBoxColor);
      rect(min(lxPress, mouseX), min(lyPress, mouseY), abs(lxPress - mouseX), abs(lyPress - mouseY));
  }
  
  textAlign(LEFT);
  controlP5.draw();
  
  if(infoTabVisible)
    drawInfoTab();
}

public PVector screenToWorld(float x, float y) {
  return new PVector(x / zoom + panX, y / zoom + panY);
}

public PVector worldToScreen(float x, float y) {
  return new PVector((x - panX) * zoom, (y - panY) * zoom);  
}

public float screenToWorldX(float x) {
  return x / zoom + panX;
}

public float screenToWorldY(float y) {
  return y / zoom + panY;
}

public float worldToScreenX(float x) {
  return (x - panX) * zoom;
}

public float worldToScreenY(float y) {
  return (y - panY) * zoom;
}
double minP, maxP;

// Color and font styles
int bgColor;
int nodeSelectedColor;
int nodeHighlightColor;
int nodeDefaultColor;
int nodeUnobservedColor;
int nodeTrueColor;
int nodeFalseColor;
int selectionBoxColor;
int statusBackground;
PFont nodeFont;
PFont controlsSmall;
PFont controlsLarge;

// Rendering state
boolean drawEdges = true;
boolean dynamicLayout = false;
public String statusString = "";
int nPapers = 84065;
double curP = 1.0f;
Node nodes[] = null;
  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#F0F0F0", "sensitivity_demo" });
  }
}
