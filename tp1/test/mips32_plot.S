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
  l.s 	$f0, 4(t1)  			# ci = UL_im
  s.s   $f0, 20(sp)      # guardo ci

for1:

  lw    t0, 48(sp)      # cargo y
  lw    t1, TAM_FRAME(sp)
  lw 	  t2, 28(t1)			# cargo y_res
  bge	  t0, t2, if3	    # si y < y_res entra al for1 sino va a if3

  sw    zero, 44(sp)    # guardo x = 0
  lw    t1, TAM_FRAME(sp)
  l.s   $f0, 0(t1)			# cargo en t2 = parms->UL_re
  s.s   $f0, 16(sp)    # guardo cr = parms->UL_re

for2:

  lw    t0, 44(sp)    #cargo x
  lw    t1, TAM_FRAME(sp)
  lw    t2, 24(t1)    #cargo parms->x_res
  bge   t0,t2,endFor2	# si x < x_res entra al for2 sino va a endFor2

  l.s   $f0, 16(sp)    #cargo cr
  s.s   $f0, 24(sp)    #guardo zr = cr
  l.s   $f0, 20(sp)    #cargo ci
  s.s   $f0, 28(sp)    #guardo zi = ci

  sw    zero, 52(sp)    #guardo c=0

for3:

  lw    t0,	52(sp)  		# cargo c
  lw    t1, TAM_FRAME(sp)
  lw    t2, 32(t1)			# cargo shades
  bge 	t0, t2, endFor3  # si c < parms->shades entra a for3 sino va a endFor3

if1:

  l.s   $f4,24(sp)          # cargo zr
  mul.s $f6,$f4,$f4 		    # f6 es zr*zr
  l.s   $f8,28(sp)
  mul.s $f10,$f8,$f8     		# f10 es zi*zi
  add.s $f4,$f4,$f10    		# f4 = f4 + f10
  s.s   $f4,40(sp)          # absz = f4
  l.s   $f6,cuatro
  c.lt.s  $f4,$f6 	        # si es menor a 4 continua, si es mayor o igual 4 rompe el ciclo
  bc1f  endFor3

  #calculo zr * zr * zr
  l.s   $f4,24(sp)       # zr
  mul.s	$f6,$f4,$f4			  # zr * zr
  mul.s $f6,$f6,$f4			  # zr * zr * zr
  s.s   $f6,32(sp)       # guardo sr

  # calculo 3 * zi * zi * zr
  l.s   $f4,28(sp)       # zi
  mul.s $f4,$f4,$f4			  # zi * zi
  l.s   $f6,24(sp)        # zr
  mul.s	$f4,$f4,$f6			  # zi * zi * zr
  l.s   $f8,tres
  mul.s $f4,$f4,$f8		  # zi * zi * zr * 3
  l.s   $f10,32(sp)     # sr
  sub.s	$f10,$f10,$f4   # sr - zi * zi * zr * 3
  l.s   $f8,16(sp)      # cr
  add.s	$f10,$f10,$f8		# sr + cr
  s.s 	$f10,32(sp)			#guardo sr

  # calculo 3 * zr * zr * zi
  l.s   $f4,24(sp)       # zr
  mul.s $f4,$f4,$f4			 # zr * zr
  l.s   $f6,28(sp)      # zi
  mul.s $f4,$f4,$f6			# zr * zr * zi
  l.s   $f8,tres
  mul.s $f4,$f4,$f8  		# zr * zr * zi * 3
  s.s   $f4,36(sp)       # guardo si

  # calculo zi * zi * zi
  mul.s $f10,$f6,$f6     # zi * zi
  mul.s $f10,$f10,$f6    # zi * zi * zi
  l.s   $f4,36(sp)       # si
  sub.s	$f4,$f4,$f10     # si - zi * zi * zi
  s.s   $f4,36(sp)       # guardo si
  l.s   $f6,20(sp)      # ci
  add.s	$f4,$f4,$f6			# si + ci
  s.s   $f4,36(sp) 			# guardo el resultado en si

  l.s   $f0,32(sp)
  s.s   $f0,24(sp)       #zr = sr

  l.s   $f0,36(sp)
  s.s   $f0,28(sp)       #zi = si

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
  l.s  	$f4,16(t2)			# cargo d_re
  l.s   $f6,16(sp)      # cargo cr
  add.s	$f6,$f6,$f4			# cr += d_re
  s.s   $f6,16(sp)      # guardo cr
  b     for2

if2:

  #la    a0,__sF+176   #imprimo mesaje de error por stderr
  #la    a1,io_error
  #la    t9,fprintf
  #jal   ra,t9

  li	v0, SYS_write
  li	a0, 2         # a0: stderr file descriptor.
  la	a1, io_error   # a1: mensaje de error.
  li	a2, 11	      # a2: data length
  syscall

  li    v0, SYS_exit  #exit(1)
  li    a0,1
  syscall

endFor2:

  lw    t1,48(sp)     # cargo y
  addu	t1,t1, 1			# ++y
  sw    t1,48(sp)     # guardo y
  lw    t2,TAM_FRAME(sp)
  l.s  	$f4,20(t2)			# cargo d_im
  l.s   $f6,20(sp)     # cargo ci
  sub.s $f6,$f6,$f4			# ci -= d_im
  s.s   $f6,20(sp)     # guardo ci
  b     for1

if3:

  lw    t0,TAM_FRAME(sp)  #flush
  lw    a0,36(t0)
  la    t9,fflush
  jal   ra,t9

  beqz  v0,end        #si es 0 termino sino es error
  #la    a0,__sF+176   #imprimo mesaje de error por stderr
  #la    a1,f_error
  #la    t9,fprintf
  #jal   ra,t9

  li	v0, SYS_write
	li	a0, 2         # a0: stderr file descriptor.
	la	a1, f_error   # a1: mensaje de error.
	li	a2, 26	      # a2: data length
	syscall

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
cuatro:   .float 4.0
tres:     .float 3.0
