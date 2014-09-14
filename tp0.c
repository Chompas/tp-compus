// TP 0 - Mandelbrot

#include <stdio.h>

// Settings
static const int iterations = 50;

int mandelbrot(double cRe, double cIm) {
  double zRe = cRe;
  double zIm = cIm;

  int color = 0;
  for (int n = 0; n < iterations; n++) {
    double zRe2 = zRe * zRe;
    double zIm2 = zIm * zIm;

    color = n;

    if (zRe2 + zIm2 > 4) {
      break;
    }

    // (a + bi)^2 = a*2 + abi + abi + (bi)^2 = a^2 - b^2 + 2abi
    zIm = 2 * zRe * zIm + cIm;
    zRe = zRe2 - zIm2 + cRe;
  }

  // Testing
  //printf("Color: %i", color);

  return color;
}

int main(int argc, char *argv[]) {

  // Size
  const int width = 1000;
  const int height = 1000;

  // Area
  const double minRe = -2.0;
  const double maxRe = 2.0;
  const double minIm = -2.0;
  const double maxIm = 2.0;

  const double realFactor = (maxRe - minRe) / (width - 1);
  const double imaginaryFactor = (maxIm - minIm) / (height -1);

  int color;

  for (int y = 0; y < height; y++) {
    double cIm = maxIm - y * imaginaryFactor;

    for (int x = 0; x < width; x++) {
      double cRe = minRe + x * realFactor;

      color = mandelbrot(cRe, cIm);

      //TODO: Guardar el color en el archivo en las posiciones x,y
    }
  }

}
