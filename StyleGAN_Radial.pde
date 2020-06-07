import com.runwayml.*;
RunwayHTTP runway;
PImage runwayResult;
float truncation = 0.8;

int n = 512;
int affect = 3; // good for 512 vectors, default is 1

int dmin = 256;
int dmax = 500;

float vectors[] = new float[512];
float angles[] = new float[512];

boolean wait = false;
int waitFrame = 0;

PShader myShader;

void setup() {
  
  size(1024, 1024, P2D);
  background(0);
  
  for(int i = 0; i < n; i++){
    angles[i] = (radians(float(i)/n * 360.0));
    vectors[i] = 0.5;
  }
  
  delay(1000);

  runway = new RunwayHTTP(this);
  runway.setAutoUpdate(false);

  delay(1000);
  
  myShader = loadShader("shader.glsl");
  
}

void draw() {
  
  background(0);
  shader(myShader);
  if (runwayResult != null) {
    pushMatrix();
    translate(width * 0.5, height * 0.5);
    image(runwayResult, -256, -256, 512, 512);
    popMatrix();
  }
  resetShader();
  
  float mouseAngle = atan2(mouseY - height * 0.5, mouseX - width * 0.5);
  float mouseDist = dist(mouseX, mouseY, width * 0.5, height * 0.5);
  mouseDist = constrain(mouseDist,dmin,dmax);
  
  int current = (n + round(degrees(mouseAngle)/360.0 * n)) % n;
  
  if(mousePressed){
    for(int i = 0; i < affect; i++){
      vectors[(current+i-floor(affect/2)+512)%n] = (mouseDist-dmin)/(dmax-dmin);
    }
    if(!wait && waitFrame == 0){
      wait = true;
      runwayNewQuery();
    }
  }
  
  waitFrame = (waitFrame+1) % 10;
    
  for(int i = 0; i < n; i++){
    
    float a = angles[i];
    
    float x1 = width * 0.5 + cos(a) * dmin;
    float x2 = width * 0.5 + cos(a) * dmax;
    float y1 = height * 0.5 + sin(a) * dmin;
    float y2 = height * 0.5 + sin(a) * dmax;
    
    stroke(100);
    line(x1,y1,x2,y2);
    
    if(i == current){
      stroke(255);
      x2 = width * 0.5 + cos(a) * mouseDist;
      y2 = height * 0.5 + sin(a) * mouseDist;
    } else {
      stroke(200);
      x2 = width * 0.5 + cos(a) * (dmin + (dmax-dmin) * vectors[i]);
      y2 = height * 0.5 + sin(a) * (dmin + (dmax-dmin) * vectors[i]);
    }
    
    line(x1,y1,x2,y2);
    
  }
  
}

void runwayNewQuery() {

  String input = "{\"truncation\":" + str(truncation) + ",\"z\":[";
  
  for (int i = 0; i < 512; i++) {
    if (i>0) {
      input += ",";
    }
    input += str(vectors[i]*2.0-1.0);
  }

  input += "]}";

  println(input);

  runway.query(input);
}

void runwayDataEvent(JSONObject runwayData) {
  // point the sketch data to the Runway incoming data 
  String base64ImageString = runwayData.getString("image");
  // try to decode the image from
  try {
    PImage result = ModelUtils.fromBase64(base64ImageString);
    if (result != null) {
      runwayResult = result;
      wait = false;
      println("received");
    }
  }
  catch(Exception e) {
    e.printStackTrace();
  }
}
