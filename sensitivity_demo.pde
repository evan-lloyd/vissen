import java.util.*;
import java.awt.event.*;

BeliefNetwork net = null;
EvidenceController evidence = null;
InferenceEngine engine = null;
HuginNode graphNodes[] = null;
Node nodes[] = null;

boolean leftMBHeld, rightMBHeld, centerMBHeld;
int lxPress, lyPress, rxPress, ryPress, cxPress, cyPress; // location of mouse at button press event
int prevMouseX, prevMouseY;
int nodeDragged = -1;
public float panX = 0, panY = 0;
public float zoom = 1.0;

color bgColor;
color nodeHighlightColor;
color nodeDefaultColor;
color nodeUnobservedColor;
color nodeTrueColor;
color nodeFalseColor;
public PFont nodeFont;

void initNetwork() {
  net = loadNetwork("pubmedquery.net");
  evidence = net.getEvidenceController();
  JEngineGenerator gen = new JEngineGenerator();
  gen.getSettings((PropertySuperintendent)net, true).setEliminationHeuristic(EliminationHeuristic.MIN_FILL);
  engine = gen.manufactureInferenceEngine(net);

  Object v[] = net.vertices().toArray();
  graphNodes = new HuginNode[net.vertices().size()];
  nodes = new Node[net.vertices().size()];

  for(int i = 0; i < nodes.length; i++) {
    graphNodes[i] = (HuginNode)v[i];
    nodes[i] = new Node();
    nodes[i].nodePosition[0] = random(60, 940);
    nodes[i].nodePosition[1] = random(60, 940);
    nodes[i].nodeLabel = graphNodes[i].getLabel();
  }

  rescaleNodes();
}

void animateAssertion() {
  rescaleNodes();
}

void rescaleNodes() {
  // find min and max marginals to set scale of nodes
  double minP = Double.MAX_VALUE, maxP = -Double.MAX_VALUE;
  for(int i = 0; i < nodes.length; i++) {
    if(nodes[i].asserted != -1)
      continue;
    double p = Prob.logOdds(engine.conditional(graphNodes[i]).getCP(1));
    nodes[i].p = p;

    if(Double.isInfinite(p))
    {
      print("hey not a number\n");
      continue;
    }

    if(p < minP)
      minP = p;
    if(p > maxP)
      maxP = p;
  }

  for(int i = 0; i < nodes.length; i++) {
    nodes[i].setScale(nodes[i].p, minP, maxP);
  }
}

void setup() {
  size(1000, 1000);
  stroke(255);

  initNetwork();

  smooth();

  colorMode(HSB, 1.0);
  frameRate(60);
  nodeDefaultColor = color(1);
  nodeHighlightColor = color(55.0 / 360.0, .96, .96);
  nodeUnobservedColor = color(0);
  nodeTrueColor = color(113.0 / 360, .99, .52);
  nodeFalseColor = color(13.0 / 360, .99, .52);
  bgColor = color(0.4);
  nodeFont = loadFont("nodeLabel.vlw");

  // thanks to example code from Processing forums, by Guillaume LaBelle
  // http://ingallian.design.uqam.ca/goo/P55/ImageExplorer/
  addMouseWheelListener(new java.awt.event.MouseWheelListener() {
    public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) {
      int notches = evt.getWheelRotation();
      if(notches!=0){
        //println(notches);
        float oldCenterX = (-panX + width / 2) * zoom;
        float oldCenterY = (-panY + height / 2) * zoom;

        zoom *= (1.0 - 0.20 * notches);
        //zoomFactor+=notches*-0.05;
        if(zoom < 0.3)
          zoom = 0.3;
        if(zoom > 5.0)
          zoom = 5.0;

        panX = -oldCenterX / zoom + width / 2;
        panY = -oldCenterY / zoom + height / 2;

      }
    }
  }
  );
}

void draw() {
  background(bgColor);
  for(int i = nodes.length - 1; i >= 0; i--) {
    nodes[i].draw();
  }
}

void mouseDragged() {
  int dx = mouseX - prevMouseX;
  int dy = mouseY - prevMouseY;

  if(centerMBHeld) { // pan view
    panX -= dx / zoom;
    panY -= dy / zoom;
  }

  if(nodeDragged != -1) { // drag node
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
        int value = (nodes[i].asserted + 2) % 3 - 1;

        try {
          if(value == -1)
            evidence.unobserve(graphNodes[i]);
          else if(value == 0)
            evidence.observe(graphNodes[i], "F");
          else if(value == 1)
            evidence.observe(graphNodes[i], "T");
        } 
        catch (StateNotFoundException e) {
          print("oh noes state not found");
        }

        nodes[i].asserted = value;
        animateAssertion();
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
  if(mouseButton == RIGHT)
    rightMBHeld = false;
  if(mouseButton == CENTER)
    centerMBHeld = false;
}

