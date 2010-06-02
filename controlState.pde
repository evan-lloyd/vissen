import controlP5.*;
ControlP5 controlP5;

// Key states
boolean leftMBHeld, rightMBHeld, centerMBHeld;
int lxPress, lyPress, rxPress, ryPress, cxPress, cyPress; // location of mouse at button press event
int prevMouseX, prevMouseY;

// Navigation parameters
boolean panUp = false, panDown = false, panLeft = false, panRight = false;
boolean zoomIn = false, zoomOut = false;
public float panX = 0, panY = 0;
public float zoom = 1.0;
int keyPanSpeed = 20;
float keyZoomSpeed = 0.5;

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
float edgeThreshMin = 0.0;
float edgeThreshMax = 10.0;
float edgeThresh = 5.0;
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
