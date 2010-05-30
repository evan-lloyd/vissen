import controlP5.*;
ControlP5 controlP5;

// Navigation state
boolean leftMBHeld, rightMBHeld, centerMBHeld;
int lxPress, lyPress, rxPress, ryPress, cxPress, cyPress; // location of mouse at button press event
int prevMouseX, prevMouseY;

// Manipulation state
boolean shiftHeld, controlHeld;
boolean draggingSelection;
int nodeDragged = -1;
int nodeAsserting = -1;
int selectedNodes[] = null;

// Render settings controls
public static final int edgeThreshSlider = 0;
