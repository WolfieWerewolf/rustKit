//VERTEX
#version 300 es
uniform mat4 u_worldViewProjection;
uniform vec3 u_lightWorldPos;
uniform mat4 u_world;
uniform mat4 u_viewInverse;
uniform mat4 u_worldInverseTranspose;

in vec4 a_position;
in vec3 a_normal;

out vec4 v_position;
out vec3 v_normal;
out vec3 v_surfaceToLight;
out vec3 v_surfaceToView;

void main() {
  v_position = (u_worldViewProjection * a_position);
  v_normal = (u_worldInverseTranspose * vec4(a_normal, 0)).xyz;
  v_surfaceToLight = u_lightWorldPos - (u_world * a_position).xyz;
  v_surfaceToView = (u_viewInverse[3] - (u_world * a_position)).xyz;
  gl_Position = v_position;
}

//FRAGMENT
#version 300 es
precision mediump float;

in vec4 v_position;
in vec3 v_normal;
in vec3 v_surfaceToLight;
in vec3 v_surfaceToView;

out vec4 outColor;

uniform vec4 u_lightColor;
uniform vec4 u_ambient;
uniform vec4 u_diffuse;
uniform vec4 u_specular;
uniform float u_shininess;
uniform float u_specularFactor;

vec4 lit(float l ,float h, float m) {
  return vec4(1.0,
              pow(l, 2.5),
              (l > 0.0) ? pow(max(0.0, h), m) : 0.0,
              1.0);
}

void main() {
  float depth = gl_FragCoord.z / gl_FragCoord.w;
  vec4 diffuseColor = u_diffuse;
  vec3 a_normal = normalize(v_normal);
  vec3 surfaceToLight = normalize(v_surfaceToLight);
  vec3 surfaceToView = normalize(v_surfaceToView);
  vec3 halfVector = normalize(surfaceToLight + surfaceToView);
  vec4 litR = lit(dot(a_normal, surfaceToLight),
                    dot(a_normal, halfVector), u_shininess);
  outColor = vec4((
  u_lightColor * (diffuseColor * litR.y + diffuseColor * u_ambient +
                u_specular * litR.z * u_specularFactor)).rgb,
      diffuseColor.a);
}