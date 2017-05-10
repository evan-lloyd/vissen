double minP, maxP;

// Color and font styles
color bgColor;
color nodeSelectedColor;
color nodeHighlightColor;
color nodeDefaultColor;
color nodeUnobservedColor;
color nodeTrueColor;
color nodeFalseColor;
color selectionBoxColor;
color statusBackground;
PFont nodeFont;
PFont controlsSmall;
PFont controlsLarge;

// Rendering state
boolean drawEdges = true;
boolean dynamicLayout = false;
public String statusString = "";
int nPapers = 84065;
double curP = 1.0;
Node nodes[] = null;
