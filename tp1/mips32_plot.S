#include <mips/regdef.h>
#include <sys/syscall.h>

#define	TAM_FRAME	80
#define	SRA_RA		72
#define	SRA_FP		68
#define	SRA_GP		64


  .text
  .globl mips32_plot
  .ent mips32_plot

mips32_plot:
  .frame	$fp,TAM_FRAME,ra   #creo stack
  .set	noreorder
  .cpload	t9
  .set	reorder
  subu	sp,sp,TAM_FRAME

  .cprestore	SRA_GP         #almaceno SRA
  sw		ra,SRA_RA(sp)
  sw		$fp,SRA_FP(sp)
  sw		gp,SRA_GP(sp)
  move	$fp,sp

  sw		a0,TAM_FRAME(sp)     #almaceno argumento

  lw    t0,TAM_FRAME(sp)
  lw    a0,36(t0)            #llamo a fprintf para imprimir P2 en el header
  la    a1,p2
  la    t9,fprintf
  jal   ra,t9

  lw    t0,TAM_FRAME(sp)
  lw    t1,TAM_FRAME(sp)
  lw    a0,36(t0)            #imprimo x_res
  la    a1,u_format
  lw    a2,24(t1)
  la    t9,fprintf
  jal   ra,t9

  lw    t0,TAM_FRAME(sp)
  lw    t1,TAM_FRAME(sp)
  lw    a0,36(t0)            #imprimo y_res
  la    a1,u_format
  lw    a2,28(t0)
  la    t9,fprintf
  jal   ra,t9

  lw    t0,TAM_FRAME(sp)
  lw    t1,TAM_FRAME(sp)
  lw    a0,36(t0)            #imprimo shades
  la    a1,u_format
  lw    a2,32(t1)
  la    t9,fprintf
  jal   ra,t9

  sw    zero, 48(sp)      # guardo y = 0
  lw    t1, TAM_FRAME(sp)
  lw 	  t2, 4(t1)  			# ci = UL_im
  sw    t2, 20(sp)      # guardo ci

for1:

  lw    t0, 48(sp)      # cargo y
  lw    t1, TAM_FRAME(sp)
  lw 	  t2, 28(t1)			# cargo y_res
  bge	  t0, t1, if3	    # si y < y_res entra al for1 sino va a if3

  sw    zero, 44(sp)    # guardo x = 0
  lw    t1, TAM_FRAME(sp)
  lw    t2, 0(t1)			# cargo en t2 = parms->UL_re
  sw    t2, 16(sp)    # guardo cr = parms->UL_re

for2:

  lw    t0, 44(sp)    #cargo x
  lw    t1, TAM_FRAME(sp)
  lw    t2, 24(t1)    #cargo parms->x_res
  bge   t0,t2,endFor2	# si x < x_res entra al for2 sino va a endFor2

  lw    t0, 16(sp)    #cargo cr
  sw    t0, 24(sp)    #guardo zr = cr
  lw    t1, 20(sp)    #cargo ci
  sw    t1, 28(sp)    #guardo zi = ci

  sw    zero, 52(sp)    #guardo c=0

for3:

  lw    t0,	52(sp)  		# cargo c
  lw    t1, TAM_FRAME(sp)
  lw    t2, 32(t1)			# cargo shades
  bge 	t0, t2, endFor3  # si c < parms->shades entra a for3 sino va a endFor3

if1:

  lw    t0,24(sp)       # cargo zr
  mul	  t2,t0,t0 		    # t2 es zr*zr
  lw    t1,28(sp)
  mul	  t3,t1,t1     		# t3 es zi*zi
  addu  t4,t2,t3    		# t4 = t2 + t3
  sw    t4,40(sp)       # absz = t4
  bge   t4,4,endFor3 	  # si es mayor o igual 4 rompe el ciclo

  lw    t0,24(sp)       # calculo zr * zr * zr
  mul 	t1,t0,t0			  # t1 = zr * zr
  mul 	t1,t1,t0			  # t1 = t1 * zr
  sw    t1,32(sp)       # sr = t1
  lw    t2,28(sp)       # calculo 3 * zi * zi * zr
  mul 	t3,t2,t2			  # t3 = zi * zi
  lw    t4,24(sp)
  mul 	t3,t3,t4			  # t3 = t3 * zr
  mul 	t3,t3,3  			  # t3 = t3 * 3
  lw    t4,32(sp)
  subu	t4,t4,t3        # sr - t3
  lw    t5,16(sp)
  addu	t4,t4,t5			  # le sumo sr + cr
  sw 	  t4,32(sp)			  #guardo sr

  lw    t0,24(sp)       # calculo 3 * zr * zr * zi
  mul 	t1,t0,t0			  # t1 = zr * zr
  lw    t2,28(sp)
  mul 	t1,t1,t2			  # t1 = t1 * zi
  mul 	t1,t1,3  			  # t1 = t1 * 3
  sw    t1,36(sp)       # si = t1
  mul   t3,t2,t2        # t3 = zi * zi
  mul   t3,t3,t2        # t3 = t3 * zi
  lw    t1,36(sp)
  subu	t1,t1,t3        # si - t3
  sw    t1,36(sp)
  lw    t4,20(sp)
  addu	t4,t4,t1			  # si + ci
  sw    t4,36(sp) 			# guardo el resultado en si

  lw    t0,32(sp)
  sw    t0,24(sp)       #zr = sr

  lw    t1,36(sp)
  sw    t1,28(sp)       #zi = si

endIf1:
  lw    t0,52(sp)     #cargo c
  addu  t0,t0,1       #++c
  sw    t0,52(sp)
  b     for3

endFor3:

  lw    t0,TAM_FRAME(sp)
  lw    a0,36(t0)       # cargo FP
  la    a1,u_format
  lw    a2,52(sp)			  # cargo C
  la    t9,fprintf      # imprimo shades
  jal   ra,t9

  bltz  v0,if2

  lw    t0,44(sp)    #cargo x
  addu  t0,t0,1       #++x
  sw    t0,44(sp)
  lw    t2,TAM_FRAME(sp)
  lw  	t3,16(t2)			# cargo d_re
  lw    t4,16(sp)      # cargo cr
  addu 	t4,t4,t3			# cr += d_re
  sw    t4,16(sp)      # guardo cr
  b     for2

if2:

  la    a0,__sF+176   #imprimo mesaje de error por stderr
  la    a1,io_error
  la    t9,fprintf
  jal   ra,t9

  li    v0, SYS_exit  #exit(1)
  li    a0,1
  syscall

endFor2:

  lw    t1,48(sp)     # cargo y
  addu	t1,t1, 1			# ++y
  sw    t1,48(sp)     # guardo y
  lw    t2,TAM_FRAME(sp)
  lw  	t3,20(t2)			# cargo d_im
  lw    t4,20(sp)     # cargo ci
  subu 	t4,t4,t3			# ci -= d_im
  sw    t4,20(sp)     # guardo ci
  b     for1

if3:

  lw    t0,TAM_FRAME(sp)  #flush
  lw    a0,36(t0)
  la    t9,fflush
  jal   ra,t9

  beqz  v0,end        #si es 0 termino sino es error
  la    a0,__sF+176   #imprimo mesaje de error por stderr
  la    a1,f_error
  la    t9,fprintf
  jal   ra,t9

  li    v0, SYS_exit  #exit(1)
  li    a0,1
  syscall

end:

  move	sp,$fp				       #detruyo stack
  lw		ra,SRA_RA(sp)
  lw		$fp,SRA_FP(sp)
  addu	sp,sp,TAM_FRAME
  j     ra

  .end mips32_plot

.data
p2:       .asciiz "P2\n"           #textos para el header y mensajes
u_format: .asciiz "%u\n"
io_error: .asciiz "i/o error.\n"
f_error:  .asciiz "cannot flush output file.\n"
