import java.util.*;
import java.awt.event.*;
import java.awt.*;

BeliefNetwork net = null;
EvidenceController evidence = null;
InferenceEngine engine = null;
HuginNode graphNodes[] = null;
Node nodes[] = null;

double sens[][][];

boolean drawEdges = true;
boolean leftMBHeld, rightMBHeld, centerMBHeld;
int lxPress, lyPress, rxPress, ryPress, cxPress, cyPress; // location of mouse at button press event
int prevMouseX, prevMouseY;
int nodeDragged = -1;
int nodeAsserting = -1;
public float panX = 0, panY = 0;
public float zoom = 1.0;

public double minP, maxP;

color bgColor;
color nodeHighlightColor;
color nodeDefaultColor;
color nodeUnobservedColor;
color nodeTrueColor;
color nodeFalseColor;
public PFont nodeFont;

int nPapers = 84065;
double curP = 1.0;
public String statusString = "";
public color statusBackground;

void updateP() {
  curP = engine.probability();
  statusString = "Number of papers matching current filters: " + Integer.toString((int)(curP * nPapers + 0.5)) + " / " + Integer.toString(nPapers);
}

void initNetwork() {
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

void animateAssertion() {
  rescaleNodes();
}

void rescaleNodes() {
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
}

void setup() {
  size(1000, 1000);
  stroke(255);

  initNetwork();

  smooth();

  colorMode(HSB, 1.0);
  frameRate(60);
  nodeDefaultColor = color(0);
  nodeHighlightColor = color(58.0 / 360.0, .8, .72);
  nodeUnobservedColor = color(0.92);
  nodeTrueColor = color(113.0 / 360, .49, .82);
  nodeFalseColor = color(13.0 / 360, .49, .82);
  bgColor = color(1.0);
  nodeFont = loadFont("nodeLabel.vlw");
  statusBackground = color(220.0/360.0, .48, 1.0);

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

void draw() {
  background(bgColor);
  
  if(drawEdges) {
    strokeWeight(6.0);
    for(int i = 0; i < nodes.length; i++) {
      for(int j = 0; j < nodes.length; j++) {
        if(i == j)
          continue;
        if(sens[i][j][1] > 5) {
          stroke(nodeTrueColor);
          line(nodes[i].x(), nodes[i].y(), nodes[j].x(), nodes[j].y());
        }
        else if(sens[i][j][1] < -5) {
          stroke(nodeFalseColor);
          line(nodes[i].x(), nodes[i].y(), nodes[j].x(), nodes[j].y());
        }
      }
    }
  }
  
  for(int i = nodes.length - 1; i >= 0; i--) {
    nodes[i].draw();
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

void assertEvidence(int n, int value) {
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

void previewEvidence(int n, int value) {
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

void assertCurrentEvidence(int n) {
  assertEvidence(nodeAsserting, nodes[nodeAsserting].asserted);
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
  if(key == 'e') {
    drawEdges = !drawEdges;
  }
}

