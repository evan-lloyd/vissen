import traer.physics.*;

import java.util.*;
import java.awt.*;

double sens[][][];

void setup() {
  size(1000, 1000);

  initNetwork();

  frameRate(60);
  smooth();
  setColorsAndFonts();
  setupControls();
  setupInterface();
  
  initLayout();
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
