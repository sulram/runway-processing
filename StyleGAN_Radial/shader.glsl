#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;

varying vec4 vertColor;
varying vec4 vertTexCoord;

float circle(in vec2 st, in float r){
  vec2 dist = st-vec2(0.5);
  return 1. -smoothstep(r-(r*0.01),r+(r*0.01),dot(dist,dist)*4.0);
}
  
void main() {
  vec2 st = vertTexCoord.st;
  vec4 col = texture2D(texture, st);
  vec4 mask = vec4(circle(st,0.99));
  gl_FragColor = mask * col;
}

