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

  .cprestore	SRA_RA         #almaceno SRA
  sw		ra,SRA_RA(sp)
  sw		$fp,SRA_FP(sp)
  sw		gp,SRA_GP(sp)
  move	$fp,sp

  sw		a0,TAM_FRAME(sp)     #almaceno argumento

  lw    t0,TAM_FRAME(sp)
  lw    a0,36(t0)            #llamo a fprintf para imprimir P2 en el header
  lw    a1,p2
  la    t9,fprintf
  jal   ra,t9

  lw    t0,TAM_FRAME(sp)     #TODO: ver si es necesario cargarlo siempre
  lw    t1,TAM_FRAME(sp)
  lw    a0,36(t0)            #imprimo x_res
  lw    a1,u_format
  lw    a2,24(t1)
  la    t9,fprintf
  jal   ra,t9

  lw    t0,TAM_FRAME(sp)
  lw    t1,TAM_FRAME(sp)
  lw    a0,36(t0)            #imprimo y_res
  lw    a1,u_format
  lw    a2,28(t0)
  la    t9,fprintf
  jal   ra,t9

  lw    t0,TAM_FRAME(sp)
  lw    t1,TAM_FRAME(sp)
  lw    a0,36(t0)            #imprimo shades
  lw    a1,u_format
  lw    a2,32(t1)
  la    t9,fprintf
  jal   ra,t9


  lw    t0, TAM_FRAME(sp)
  lw    t1, TAM_FRAME(sp)
  li 	  t1, 0       		# guardo en t1 y = 0
  lw 	  t2, 4(t1)  			# ci = UL_im
  lw 	  t3, 28(t1)			# en t3 guardo y_res

loop1:

  addi	t1, t1, 1			# ++y
  lw  	t4, 20(t1)			# cargo d_im
  subu 	t2, t2, t4			# ci -= d_im
  sltu	$v0,$t1,$t3
  bne	  $v0,$zero,$loop2	# si y < y_res entra al 2do for

loop2:

  li    t5, 0				# cargo en t5 x=0
  lw    t6, 0(t1)			# cargo en t6 cr = parms->UL_re
  lw    t7, 24(t1)			# cargo en t7 x_res
  sltu	$v0,$t5,$t7
  bne   $v0,$zero,$loop2	# si x < x_res entra al 3do loop

loop3:

  li    t8,	0 				# cargo en t8  c = 0
  lw    t9, 32(t1)			# TODO: CASI SEGURO NO SE PUEDE USAR t9, arreglarlo despues, cargo shades en t9
  sltu 	$v0, $t8, $t9
  bne 	$v0, $zero, $loop4  # si c < parms->shades va a loop 4

loop4:

  addiu	t8, t8, 1
  mul	  $f0, $t6, $t6 		# f0 es zr*zr
  mul	  $f1, $t2, $t2 		# f1 es zi*zi
  addu  $f3, $f0, $f1		# f3 es la suma de f1 y f2
  slti  $v0, $f3, 4			# si es menor que 4
  bne	  $v0, $zero, $fin	# si es menor a 4 rompe el ciclo

  mul 	t4, $f0, t2			# guardo en t4 zr * zr * zi f0 es zr*zr
  mul 	t5, t4, 3			# TODO: multiplico por 3, pero creo que falta un li para el 3
  subu	t4, t4, t5
  addu	t4, t4, t6			# le sumo cr = zr
  sw 	  t4, 24(sp)			#nose si esta bien, guardo el resultado en zr

  mul 	t4, $f1, t2			# guardo en t4 zi * zi * zi f1 es zi*zi
  mul 	t5, t4, 3			  # TODO: multiplico por 3, pero creo que falta un li para el 3
  subu	t4, t4, t5
  addu	t4, t4, t2			# le sumo ci = zi
  sw    t4, 28(sp)			# guardo el resultaod en zi
  sw 	  t8, 52(sp)			#guardo C en 52 del sp


  lw    t0,TAM_FRAME(sp)
  lw    t1,TAM_FRAME(sp)
  lw    a0,36(t0)            #imprimo shades
  lw    a1,u_format
  lw    a2,36(t1)			# cargo FP
  lw 	  a3,52(sp)			# TODO: cargo C, verifiacr si esta bien
  la    t9,fprintf
  jal   ra,t9

if1:

  bge   v0,0,if2
  lw    a0,2          #imprimo mesaje de error por stderr
  lw    a1,io_error
  la    t9,fprintf
  jal   ra,t9

  lw    v0, SYS_EXIT  #exit(1)
  lw    a1,1
  syscall

if2:

  lw    t0,TAM_FRAME(sp)
  lw    a0,36(t0)
  la    t9,fflush
  jal   ra,t9

  beqz  v0,end
  lw    a0,2          #imprimo mesaje de error por stderr
  lw    a1,f_error
  la    t9,fprintf
  jal   ra,t9

  lw    v0, SYS_EXIT  #exit(1)
  lw    a1,1
  syscall

end:

  move	sp,$fp				       #detruyo stack
  lw		ra,SRA_RA(sp)
  lw		$fp,SRA_FP(sp)
  addu	sp,sp,TAM_FRAME
  j     ra

  .end mips32_plot

p2:       .ascii "P2\n"           #textos para el header y mensajes
u_format: .ascii "%u\n"
io_error: .ascii "i/o error.\n"
f_error:  .ascii "cannot flush output file.\n"
