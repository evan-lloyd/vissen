ParticleSystem particles = new ParticleSystem(0.1, 0.1);

Vector dragSprings = new Vector();
Vector dragTargets = new Vector();

void updateDragTargets(float dx, float dy) {
  for(int i = 0; i < dragTargets.size(); i++) {
    Particle t = (Particle)dragTargets.get(i);
    t.position().add(dx, dy, 0.0);
  }
}

void startPhysicsDrag(float toX, float toY, Vector toDrag) {
}

void initLayout() {
  for(int i = 0; i < nodes.length; i++) {
    // TODO: mass based on size?
    particles.makeParticle(1.0, nodes[i].nodePosition[0], nodes[i].nodePosition[1], 0.0);
  }
}

void resetLayout() {
  for(int i = 0; i < nodes.length; i++) {
    Particle p = particles.getParticle(i);
    p.position().set(nodes[i].nodePosition[0], nodes[i].nodePosition[1], 0.0);
    p.velocity().set(0, 0, 0);
  }
}

void layoutTick() {
  particles.tick(1);
  for(int i = 0; i < nodes.length; i++) {
    Particle p = particles.getParticle(i);
    nodes[i].nodePosition[0] = int(p.position().x());
    nodes[i].nodePosition[1] = int(p.position().y());
  }
}
