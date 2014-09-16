// TP 0 - Mandelbrot
#include <getopt.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define TP0_VERSION "Version 1.0 Tp 0 - 6620 Organizacion de Computadoras"
#define FALSE 0
#define TRUE  1

// Global constants
static const int iterations = 50;

int mandelbrot(double cRe, double cIm) {
  double zRe = cRe;
  double zIm = cIm;

  int color = 0;
  int n = 0;
  for (n = 0; n < iterations; n++) {
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

void initPGM(FILE *pgmFile, int width, int height) {

  fprintf(pgmFile, "P2");
  fprintf(pgmFile,"\n");
  fprintf(pgmFile, "%d %d", width, height);
  fprintf(pgmFile,"\n");
  fprintf(pgmFile, "%d", iterations);
  fprintf(pgmFile,"\n");
}

void usage () {
  fprintf( stderr," Usage:\n");
  fprintf( stderr,"\t tp0 -h\n");
  fprintf( stderr,"\t tp0 -v\n");
  fprintf( stderr,"\t tp0 -c 0+0i -r 1x1 -o -\n");
  fprintf( stderr," Options:\n");
  fprintf( stderr,"\t -v, --version \t Show version string.\n");
  fprintf( stderr,"\t -h, --help \t Print this message and quit.\n");
  fprintf( stderr,"\t -r, --resolution \t Set image resolution to WxH pixels.\n");
  fprintf( stderr,"\t -c, --center \t Set center of the image, expressed in binomial form a+bi.\n");
  fprintf( stderr,"\t -w, --width \t Set width of the rectangle of the complex plane.\n");
  fprintf( stderr,"\t -H, --height \t Set height of the rectangle of the complex plane.\n");
  fprintf( stderr,"\t -o, --output \t Path to output file.\n");
}

static struct option const longopts[] = {
  {"resolution", required_argument, 0, 'r'},
  {"center", required_argument, 0, 'c'},
  {"width", required_argument, 0, 'w'},
  {"height", required_argument, 0, 'H'},
  {"output", required_argument, 0, 'o'},
  {"help", no_argument, 0, 'h'},
  {"version", no_argument, 0, 'v'},
  {0, 0, 0, 0}
};

int main(int argc, char **argv) {

  int optc;
  // Size
  int width = 640;
  int height = 480;

  // Area
  double minRe = -2.0;
  double maxRe = 2.0;
  double minIm = -2.0;
  double maxIm = 2.0;
  int centerRe = 0;
  int centerIm = 0;

  const double realFactor = (maxRe - minRe) / (width - 1);
  const double imaginaryFactor = (maxIm - minIm) / (height -1);

  char *res;
  char *resx;
  char *center;
  char *cen;
  char *output;
  int w = 4;
  int h = 4;
  short int res_value = FALSE;
  short int center_value = FALSE;
  short int o_value = FALSE;
  FILE *fout;

  while ((optc = getopt_long (argc, argv, "hvr:c:w:H:o:", longopts, (int *) 0)) != EOF) {
    switch (optc) {
      case 'h':
        usage();
        return 0;
        break;

      case 'v':
        fprintf (stderr, "\n" );
        fprintf (stderr, TP0_VERSION );
        fprintf (stderr, "\n\n" );
        return 0;
        break;

      case 'r':
        res = optarg;
        res_value = TRUE;
        break;

      case 'c':
        center = optarg;
        center_value = TRUE;
        break;

      case 'w':
        w = atoi(optarg);
        break;

      case 'H':
        h = atoi(optarg);
        break;

      case 'o':
        output = optarg;
        o_value = TRUE;
        break;

      case '?':
        fprintf(stderr, "Opcion invalida-%c\n", optc);
        return 1;

      default:
        usage ();
        return 0;
    }
  }

  /*Resolucion*/
  if(res_value == TRUE) {
    resx = strstr( res, "x" );

    if ( resx == NULL ||  /* Si nos tiene x */
        resx == res || /* Si la x esta al principio */
        resx == &res[strlen(res)-1] ) { /* Si la x esta al final */

          fprintf(stderr, "Error al parsear resolucion -%s\n", res);
          return 0;
    }

    // Width
    resx = strstr( res, "x" );
    char *p = res;
    int i = 0;
    char num[32];

    while( p!=NULL && p != resx ) {
      num[i] = *p; i++; p++;
    }

    num[i] = 0;
    width = atoi( num );

    // Height
    i = 0;
    resx = &res[strlen(res)-1];

    while ( p!=NULL && p != resx ) {
      p++; num[i] = *p; i++;
    }

    num[i] = 0;
    height = atoi( num );
    p++;

  	}

  	// Center
  	if(center_value == TRUE) {
  		cen = strstr(center,"+");
  		if(cen == NULL || /*Si no tiene el + */
  			cen == center || /*Si el + esta al principio */
  			cen == &center[strlen(center)-1]){ /*Si el + esta al final*/
          fprintf(stderr, "Error al parsear centro -%s\n", center);
          return 0;
  		}

  		cen = strstr(center,"i");
  		if(cen == NULL || /*Si no tiene el i */
  			cen != &center[strlen(center)-1]){ /*Si el i no esta al final*/
          fprintf(stderr, "Error al parsear centro -%s\n", center);
          return 0;
  			}

  		// Parte real
  		cen = strstr( center, "+" );
      char *p = center;
      int i = 0;
      char num[32];

      while( p!=NULL && p != cen ) {
        num[i] = *p; i++; p++;
      }

      num[i] = 0;
      centerRe = atoi( num );

      // Parte imaginaria
    	i = 0;
    	cen = &center[strlen(center)-2];

    	while ( p!=NULL && p != cen ) {
      	p++; num[i] = *p; i++;
    	}

    	num[i] = 0;
    	centerIm = atoi( num );
    	p++;
  	}

  	maxRe = centerRe+(w/2);
  	minRe = centerRe-(w/2);
  	maxIm = centerIm+(h/2);
  	minIm = centerIm-(h/2);

  // File
  if(o_value == TRUE) {
  	if (strlen( output )==1 && *output=='-' ) {
      fout = stdout;
    } else {
      fout = fopen( output, "wb");
    }

    if ( fout == NULL ) {
      fprintf(stderr, "Error al abrir archivo output -%s\n", output);
      return 0;
    }
  } else {
  	fout = stdout;
  }

  initPGM(fout, width, height);

  int color;
  int y = 0;
  int x = 0;

  for (y = 0; y < height; y++) {
    double cIm = maxIm - y * imaginaryFactor;

    for (x = 0; x < width; x++) {
      double cRe = minRe + x * realFactor;

      color = mandelbrot(cRe, cIm);
      fprintf(fout, "%d ", color);
    }

    // New line
    fprintf( fout, "\n");
  }


  fclose(fout);

}
