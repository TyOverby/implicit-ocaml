#include <stdlib.h>
#include <stdio.h>
#include <math.h>

typedef struct float2 {
  float x;
  float y;
} float2;

/*
const static float2 A = {-0.5f, -0.5f};
const static float2 B = {0.5f, -0.5f};
const static float2 C = {0.5f, 0.5f};
const static float2 D = {-0.5f, 0.5f};
*/

const static float2 N = {0.0f, -0.5f};
const static float2 S = {0.0f, 0.5f};
const static float2 E = {0.5f, 0.0f};
const static float2 W = {-0.5f, 0.0f};

float lerp(float fa, float fb, float dist)
{
    return -dist / 2.0f + dist * ((-fa) / (fb - fa));
}

float2 float2_scale(float2 v, float f) {
  return (float2){v.x * f, v.y * f};
}

float2 float2_add(float2 a, float2 b) {
  return (float2){a.x + b.x, a.y + b.y};
}

float2 float2_scale_add(float2 a, float scale, float2 b) {
 return float2_add(float2_scale(a, scale), b);
}

float2 n(float distance, float2 point, float how_much)
{
    float2 result = float2_scale_add(N, distance, point);
    result.x += how_much;
    return result;
}

float2 s(float distance, float2 point, float how_much)
{
    float2 result = float2_scale_add(S , distance , point);
    result.x += how_much;
    return result;
}

float2 e(float distance, float2 point, float how_much)
{
    float2 result = float2_scale_add(E , distance , point);
    result.y += how_much;
    return result;
}

float2 w(float distance, float2 point, float how_much)
{
    float2 result = float2_scale_add(W, distance, point);
    result.y += how_much;
    return result;
}

void write_line(float2 o1, float2 o2, float *out, int* atomic)
{
    if (o1.x == o2.x && o1.y == o2.y) {
        return;
    }

    if (isnan(o1.x)) {
        return;
    }

    int p = (*atomic)++;
    int out_pos = p * 4;
    out[out_pos + 0] = o1.x;
    out[out_pos + 1] = o1.y;
    out[out_pos + 2] = o2.x;
    out[out_pos + 3] = o2.y;
}

void march(
    float sra, float srb, float src, float srd,
    float2 p,
    float dist,
    float *out,
    int *atomic)
{

    char a_on = sra <= 0.0f;
    char b_on = srb <= 0.0f;
    char c_on = src <= 0.0f;
    char d_on = srd <= 0.0f;

    char which = (a_on << 3) + (b_on << 2) + (c_on << 1) + (d_on << 0);

    float2 o1 = (float2){NAN, NAN};
    float2 o2 = (float2){NAN, NAN};

    float2 o3 = (float2){NAN, NAN};
    float2 o4 = (float2){NAN, NAN};

    switch (which)
    {
    // 0000
    // 00
    // 00
    case 0:
        // Don't do anything
        break;

    // 0001
    // 00
    // 10
    case 1:
        o1 = w(dist, p, lerp(sra, srd, dist));
        o2 = s(dist, p, -lerp(src, srd, dist));
        break;

    // 0010
    // 00
    // 01
    case 2:
        o1 = s(dist, p, lerp(srd, src, dist));
        o2 = e(dist, p, -lerp(src, srb, dist));
        break;

    // 0011
    // 00
    // 11
    case 3:
        o1 = w(dist, p, lerp(sra, srd, dist));
        o2 = e(dist, p, lerp(srb, src, dist));
        break;

    // 0100
    // 01
    // 00
    case 4:
        o2 = n(dist, p, lerp(sra, srb, dist));
        o1 = e(dist, p, lerp(srb, src, dist));
        break;

    // 0101
    // 01
    // 10
    case 5:
        o2 = n(dist, p, lerp(sra, srb, dist));
        o1 = e(dist, p, lerp(srb, src, dist));

        o3 = w(dist, p, lerp(sra, srd, dist));
        o4 = s(dist, p, -lerp(src, srd, dist));
        // WEW LADS
        break;

    // 0110
    // 01
    // 01
    case 6:
        o2 = n(dist, p, -lerp(srb, sra, dist));
        o1 = s(dist, p, -lerp(src, srd, dist));
        break;

    // 0111
    // 01
    // 11
    case 7:
        o1 = w(dist, p, lerp(sra, srd, dist));
        o2 = n(dist, p, lerp(sra, srb, dist));
        break;

    // 1000
    // 10
    // 00
    case 8:
        o2 = w(dist, p, lerp(sra, srd, dist));
        o1 = n(dist, p, lerp(sra, srb, dist));
        break;

    // 1001
    // 10
    // 10
    case 9:
        o1 = n(dist, p, -lerp(srb, sra, dist));
        o2 = s(dist, p, -lerp(src, srd, dist));
        break;

    // 1010
    // 10
    // 01
    case 10:
        o1 = s(dist, p, lerp(srd, src, dist));
        o2 = e(dist, p, -lerp(src, srb, dist));

        o4 = w(dist, p, lerp(sra, srd, dist));
        o3 = n(dist, p, lerp(sra, srb, dist));
        // PUNT
        break;

    // 1011
    // 10
    // 11
    case 11:
        o1 = n(dist, p, lerp(sra, srb, dist));
        o2 = e(dist, p, -lerp(src, srb, dist));
        break;

    // 1100
    // 11
    // 00
    case 12:
        o2 = w(dist, p, lerp(sra, srd, dist));
        o1 = e(dist, p, lerp(srb, src, dist));
        break;

    // 1101
    // 11
    // 10
    case 13:
        /*
            let db = lerp(srb, src, dist);
            let dd = lerp(srd, src, dist);
            MarchResult::One(Line(s(dist, p, dd), e(dist, p, db)))
            */
        o2 = s(dist, p, lerp(srd, src, dist));
        o1 = e(dist, p, lerp(srb, src, dist));
        break;

    // 1110
    // 11
    // 01
    case 14:
        o2 = w(dist, p, lerp(sra, srd, dist));
        o1 = s(dist, p, lerp(srd, src, dist));
        break;

    // 1111
    // 11
    // 11
    case 15:
        // do nothing
        break;
    }

    write_line(o1, o2, out, atomic);
    write_line(o3, o4, out, atomic);
}

void apply(
    float* restrict buffer,
    unsigned int width, 
    unsigned int height,
    float* restrict out,
    int *atomic,
    unsigned int x,
    unsigned int y)
{
    unsigned int pos = x + y * width;

    if (x == width - 1 || y == height - 1)
    {
        return;
    }

    unsigned int a = pos;
    unsigned int b = pos + 1;
    unsigned int c = pos + 1 + width;
    unsigned int d = pos + width;

    float sra = buffer[a];
    float srb = buffer[b];
    float src = buffer[c];
    float srd = buffer[d];

    float2 p = (float2){x + 0.5f, y + 0.5f};
    march(sra, srb, src, srd, p, 1.0f, out, atomic);
}

extern void run_marching_squares(
    float* restrict buffer,
    unsigned int width,
    unsigned int height,
    int* atomic,
    float* restrict out) {
    *atomic = 0;
    for (unsigned int y = 0; y < height; y++) {
        for (unsigned int x = 0; x < width; x++) {
            apply(buffer, width, height, out, atomic, x, y);
        }
    }
}
