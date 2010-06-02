import traer.physics.*;

ParticleSystem particles = new ParticleSystem(0.0, 0.9999);

Vector dragSprings = new Vector();
Vector dragTargets = new Vector();

void updateDragTargets(float dx, float dy) {
  for(int i = 0; i < dragTargets.size(); i++) {
    Particle t = (Particle)dragTargets.get(i);
    t.position().add(dx, dy, 0.0);
  }
}

void startPhysicsDrag(Vector toDrag) {
  for(int i = 0; i < toDrag.size(); i++) {
    Integer j = (Integer)toDrag.get(i);
    Particle target = particles.makeParticle(1.0, nodes[j].nodePosition[0], nodes[j].nodePosition[1], 0.0);
    target.makeFixed();
    dragTargets.add(target);
    Spring spring = particles.makeSpring(particles.getParticle(j + 1), target, 10000, 1000, 0);
    dragSprings.add(spring);
  }
}

void endPhysicsDrag() {
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
void initLayout() {
  layoutInitialized = true;
  // attach nodes to centroid by springs to keep them from flying too far away
  float cx = 0, cy = 0;
  for(int i = 0; i < nodes.length; i++) {
    cx += nodes[i].nodePosition[0];
    cy += nodes[i].nodePosition[1];
  }
  cx /= nodes.length;
  cy /= nodes.length;
  
  Particle centroidPoint = particles.makeParticle(1.0, cx, cy, 0);
  centroidPoint.makeFixed();
  
  for(int i = 0; i < nodes.length; i++) {
    // TODO: mass based on size?
    particles.makeParticle(nodes[i].nodeSize, nodes[i].nodePosition[0], nodes[i].nodePosition[1], 0.0);
    particles.makeSpring(particles.getParticle(i+1), centroidPoint, 1000, 800, 0);
  }
  
  for(int i = 0; i < nodes.length; i++) {
    for(int j = 0; j < nodes.length; j++) {
      if(i == j)
        continue;
      particles.makeAttraction(particles.getParticle(i+1), particles.getParticle(j+1), min(10.0, max(-10.0, (float)sens[i][j][1]))*sensScale, 10);
      
      if(j > i)
        particles.addCustomForce(new NodeConstraintForce(particles.getParticle(i+1), particles.getParticle(j+1), nodes[i], nodes[j]));
    }
  }
}

void updateLayout() {
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

void resetLayout() {
  for(int i = 0; i < nodes.length; i++) {
    Particle p = particles.getParticle(i + 1);
    p.position().set(nodes[i].nodePosition[0], nodes[i].nodePosition[1], 0.0);
    p.velocity().set(0, 0, 0);
  }
}

void layoutTick() {
  particles.tick(0.001);
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
