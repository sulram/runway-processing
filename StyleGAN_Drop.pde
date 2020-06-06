// RunwayML OSC
// Truncation 0.8
// Drop vectors to transition

// use thunar for batch renaming
// ffmpeg -r 8 -i xxx_%05d.png -c:v libx264 -vf fps=30 -pix_fmt yuv420p stylegan.mp4

import drop.*;
import com.runwayml.*;

JSONArray json;
SDrop drop;
RunwayHTTP runway;

PImage runwayResult;

JSONArray vin;
JSONArray vout;

float[] a = new float [512];
float[] ain = new float [512];
float[] aout = new float [512];

float step = 0;
int k = 0;

void setup() {

  size(1024, 1024);
  frameRate(30);

  drop = new SDrop(this);

  delay(1000);

  runway = new RunwayHTTP(this);
  runway.setAutoUpdate(false);

  delay(1000);
}

void draw() {
  if (runwayResult != null) {
    image(runwayResult, 0, 0);
    saveFrame("gan-######.png");
    runwayResult = null;
  }
}

void loadVector() {

  for (int i = 0; i < 512; i++ ) {
    a[i] = vin.getFloat(i);
    ain[i] = vin.getFloat(i);
    aout[i] = vout.getFloat(i);
  }

  step = 0;
  oneStep();
}

void oneStep() {

  String input = "{\"truncation\":0.8,\"z\":[";

  for (int i = 0; i < 512; i++) {
    if (i>0) {
      input += ",";
    }
    a[i] = lerp(ain[i], aout[i], step);
    input += str(a[i]);
  }

  input += "]}";

  println(input);

  runway.query(input);
}

void dropEvent(DropEvent theDropEvent) {

  String file = theDropEvent.file().getPath();
  println("received "+file);
  json = loadJSONArray(file);

  if (k == 0) {
    vin = json;
    vout = json;
    println("load one more to start");
  } else {
    vin = vout;
    vout = json;
    println("transition "+k);
    loadVector();
  }

  k++;
}

// this is called when new Runway data is available
void runwayDataEvent(JSONObject runwayData) {
  // point the sketch data to the Runway incoming data 
  String base64ImageString = runwayData.getString("image");
  // try to decode the image from
  try {
    PImage result = ModelUtils.fromBase64(base64ImageString);
    if (result != null) {
      runwayResult = result;
      doNext();
    }
  }
  catch(Exception e) {
    e.printStackTrace();
  }
}

void doNext() {

  if (step < 1) {
    step += .05;
    oneStep();
  }

  println("step "+ step);
}
