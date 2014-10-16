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

  move	sp,$fp				       #detruyo stack
  lw		ra,SRA_RA(sp)
  lw		$fp,SRA_FP(sp)
  addu	sp,sp,TAM_FRAME
  j		ra

  .end mips32_plot

p2: .ascii "P2\n"           #defino textos para el header PGM
u_format: .ascii "%u\n"
