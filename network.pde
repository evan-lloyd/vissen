import java.io.*;

BeliefNetwork net = null;
EvidenceController evidence = null;
InferenceEngine engine = null;
HuginNode graphNodes[] = null;

void resetNetwork() {
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

BeliefNetwork loadNetwork(String fileName) {
  byte bytes[] = loadBytes(fileName);
  HuginReader reader = new HuginReader(new ByteArrayInputStream(bytes));
  try {
  return reader.beliefNetwork();
  }
  catch (edu.ucla.belief.io.ParseException e){
  }
  return null;
}

void animateAssertion() {
  rescaleNodes();
}

void updateP() {
  curP = engine.probability();
  statusString = "Number of papers matching current filters: " + Integer.toString((int)(curP * nPapers + 0.5)) + " / " + Integer.toString(nPapers);
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
  updateLayout();
}
