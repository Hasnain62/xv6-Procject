
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	19010113          	addi	sp,sp,400 # 80009190 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	00070713          	mv	a4,a4
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	4ce78793          	addi	a5,a5,1230 # 80006530 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd87ff>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	dc678793          	addi	a5,a5,-570 # 80000e72 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00003097          	auipc	ra,0x3
    8000012e:	ba0080e7          	jalr	-1120(ra) # 80002cca <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	77e080e7          	jalr	1918(ra) # 800008b8 <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	00650513          	addi	a0,a0,6 # 80011190 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a3e080e7          	jalr	-1474(ra) # 80000bd0 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	ff648493          	addi	s1,s1,-10 # 80011190 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	08690913          	addi	s2,s2,134 # 80011228 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001aa:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001ae:	4ca9                	li	s9,10
  while(n > 0){
    800001b0:	07305863          	blez	s3,80000220 <consoleread+0xbc>
    while(cons.r == cons.w){
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71463          	bne	a4,a5,800001e4 <consoleread+0x80>
      if(myproc()->killed){
    800001c0:	00002097          	auipc	ra,0x2
    800001c4:	85e080e7          	jalr	-1954(ra) # 80001a1e <myproc>
    800001c8:	551c                	lw	a5,40(a0)
    800001ca:	e7b5                	bnez	a5,80000236 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001cc:	85a6                	mv	a1,s1
    800001ce:	854a                	mv	a0,s2
    800001d0:	00002097          	auipc	ra,0x2
    800001d4:	2ae080e7          	jalr	686(ra) # 8000247e <sleep>
    while(cons.r == cons.w){
    800001d8:	0984a783          	lw	a5,152(s1)
    800001dc:	09c4a703          	lw	a4,156(s1)
    800001e0:	fef700e3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001e4:	0017871b          	addiw	a4,a5,1
    800001e8:	08e4ac23          	sw	a4,152(s1)
    800001ec:	07f7f713          	andi	a4,a5,127
    800001f0:	9726                	add	a4,a4,s1
    800001f2:	01874703          	lbu	a4,24(a4)
    800001f6:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    800001fa:	077d0563          	beq	s10,s7,80000264 <consoleread+0x100>
    cbuf = c;
    800001fe:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000202:	4685                	li	a3,1
    80000204:	f9f40613          	addi	a2,s0,-97
    80000208:	85d2                	mv	a1,s4
    8000020a:	8556                	mv	a0,s5
    8000020c:	00003097          	auipc	ra,0x3
    80000210:	a68080e7          	jalr	-1432(ra) # 80002c74 <either_copyout>
    80000214:	01850663          	beq	a0,s8,80000220 <consoleread+0xbc>
    dst++;
    80000218:	0a05                	addi	s4,s4,1
    --n;
    8000021a:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    8000021c:	f99d1ae3          	bne	s10,s9,800001b0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000220:	00011517          	auipc	a0,0x11
    80000224:	f7050513          	addi	a0,a0,-144 # 80011190 <cons>
    80000228:	00001097          	auipc	ra,0x1
    8000022c:	a5c080e7          	jalr	-1444(ra) # 80000c84 <release>

  return target - n;
    80000230:	413b053b          	subw	a0,s6,s3
    80000234:	a811                	j	80000248 <consoleread+0xe4>
        release(&cons.lock);
    80000236:	00011517          	auipc	a0,0x11
    8000023a:	f5a50513          	addi	a0,a0,-166 # 80011190 <cons>
    8000023e:	00001097          	auipc	ra,0x1
    80000242:	a46080e7          	jalr	-1466(ra) # 80000c84 <release>
        return -1;
    80000246:	557d                	li	a0,-1
}
    80000248:	70a6                	ld	ra,104(sp)
    8000024a:	7406                	ld	s0,96(sp)
    8000024c:	64e6                	ld	s1,88(sp)
    8000024e:	6946                	ld	s2,80(sp)
    80000250:	69a6                	ld	s3,72(sp)
    80000252:	6a06                	ld	s4,64(sp)
    80000254:	7ae2                	ld	s5,56(sp)
    80000256:	7b42                	ld	s6,48(sp)
    80000258:	7ba2                	ld	s7,40(sp)
    8000025a:	7c02                	ld	s8,32(sp)
    8000025c:	6ce2                	ld	s9,24(sp)
    8000025e:	6d42                	ld	s10,16(sp)
    80000260:	6165                	addi	sp,sp,112
    80000262:	8082                	ret
      if(n < target){
    80000264:	0009871b          	sext.w	a4,s3
    80000268:	fb677ce3          	bgeu	a4,s6,80000220 <consoleread+0xbc>
        cons.r--;
    8000026c:	00011717          	auipc	a4,0x11
    80000270:	faf72e23          	sw	a5,-68(a4) # 80011228 <cons+0x98>
    80000274:	b775                	j	80000220 <consoleread+0xbc>

0000000080000276 <consputc>:
{
    80000276:	1141                	addi	sp,sp,-16
    80000278:	e406                	sd	ra,8(sp)
    8000027a:	e022                	sd	s0,0(sp)
    8000027c:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000027e:	10000793          	li	a5,256
    80000282:	00f50a63          	beq	a0,a5,80000296 <consputc+0x20>
    uartputc_sync(c);
    80000286:	00000097          	auipc	ra,0x0
    8000028a:	560080e7          	jalr	1376(ra) # 800007e6 <uartputc_sync>
}
    8000028e:	60a2                	ld	ra,8(sp)
    80000290:	6402                	ld	s0,0(sp)
    80000292:	0141                	addi	sp,sp,16
    80000294:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000296:	4521                	li	a0,8
    80000298:	00000097          	auipc	ra,0x0
    8000029c:	54e080e7          	jalr	1358(ra) # 800007e6 <uartputc_sync>
    800002a0:	02000513          	li	a0,32
    800002a4:	00000097          	auipc	ra,0x0
    800002a8:	542080e7          	jalr	1346(ra) # 800007e6 <uartputc_sync>
    800002ac:	4521                	li	a0,8
    800002ae:	00000097          	auipc	ra,0x0
    800002b2:	538080e7          	jalr	1336(ra) # 800007e6 <uartputc_sync>
    800002b6:	bfe1                	j	8000028e <consputc+0x18>

00000000800002b8 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002b8:	1101                	addi	sp,sp,-32
    800002ba:	ec06                	sd	ra,24(sp)
    800002bc:	e822                	sd	s0,16(sp)
    800002be:	e426                	sd	s1,8(sp)
    800002c0:	e04a                	sd	s2,0(sp)
    800002c2:	1000                	addi	s0,sp,32
    800002c4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c6:	00011517          	auipc	a0,0x11
    800002ca:	eca50513          	addi	a0,a0,-310 # 80011190 <cons>
    800002ce:	00001097          	auipc	ra,0x1
    800002d2:	902080e7          	jalr	-1790(ra) # 80000bd0 <acquire>

  switch(c){
    800002d6:	47d5                	li	a5,21
    800002d8:	0af48663          	beq	s1,a5,80000384 <consoleintr+0xcc>
    800002dc:	0297ca63          	blt	a5,s1,80000310 <consoleintr+0x58>
    800002e0:	47a1                	li	a5,8
    800002e2:	0ef48763          	beq	s1,a5,800003d0 <consoleintr+0x118>
    800002e6:	47c1                	li	a5,16
    800002e8:	10f49a63          	bne	s1,a5,800003fc <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002ec:	00003097          	auipc	ra,0x3
    800002f0:	a34080e7          	jalr	-1484(ra) # 80002d20 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002f4:	00011517          	auipc	a0,0x11
    800002f8:	e9c50513          	addi	a0,a0,-356 # 80011190 <cons>
    800002fc:	00001097          	auipc	ra,0x1
    80000300:	988080e7          	jalr	-1656(ra) # 80000c84 <release>
}
    80000304:	60e2                	ld	ra,24(sp)
    80000306:	6442                	ld	s0,16(sp)
    80000308:	64a2                	ld	s1,8(sp)
    8000030a:	6902                	ld	s2,0(sp)
    8000030c:	6105                	addi	sp,sp,32
    8000030e:	8082                	ret
  switch(c){
    80000310:	07f00793          	li	a5,127
    80000314:	0af48e63          	beq	s1,a5,800003d0 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000318:	00011717          	auipc	a4,0x11
    8000031c:	e7870713          	addi	a4,a4,-392 # 80011190 <cons>
    80000320:	0a072783          	lw	a5,160(a4)
    80000324:	09872703          	lw	a4,152(a4)
    80000328:	9f99                	subw	a5,a5,a4
    8000032a:	07f00713          	li	a4,127
    8000032e:	fcf763e3          	bltu	a4,a5,800002f4 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000332:	47b5                	li	a5,13
    80000334:	0cf48763          	beq	s1,a5,80000402 <consoleintr+0x14a>
      consputc(c);
    80000338:	8526                	mv	a0,s1
    8000033a:	00000097          	auipc	ra,0x0
    8000033e:	f3c080e7          	jalr	-196(ra) # 80000276 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000342:	00011797          	auipc	a5,0x11
    80000346:	e4e78793          	addi	a5,a5,-434 # 80011190 <cons>
    8000034a:	0a07a703          	lw	a4,160(a5)
    8000034e:	0017069b          	addiw	a3,a4,1
    80000352:	0006861b          	sext.w	a2,a3
    80000356:	0ad7a023          	sw	a3,160(a5)
    8000035a:	07f77713          	andi	a4,a4,127
    8000035e:	97ba                	add	a5,a5,a4
    80000360:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000364:	47a9                	li	a5,10
    80000366:	0cf48563          	beq	s1,a5,80000430 <consoleintr+0x178>
    8000036a:	4791                	li	a5,4
    8000036c:	0cf48263          	beq	s1,a5,80000430 <consoleintr+0x178>
    80000370:	00011797          	auipc	a5,0x11
    80000374:	eb87a783          	lw	a5,-328(a5) # 80011228 <cons+0x98>
    80000378:	0807879b          	addiw	a5,a5,128
    8000037c:	f6f61ce3          	bne	a2,a5,800002f4 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000380:	863e                	mv	a2,a5
    80000382:	a07d                	j	80000430 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000384:	00011717          	auipc	a4,0x11
    80000388:	e0c70713          	addi	a4,a4,-500 # 80011190 <cons>
    8000038c:	0a072783          	lw	a5,160(a4)
    80000390:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000394:	00011497          	auipc	s1,0x11
    80000398:	dfc48493          	addi	s1,s1,-516 # 80011190 <cons>
    while(cons.e != cons.w &&
    8000039c:	4929                	li	s2,10
    8000039e:	f4f70be3          	beq	a4,a5,800002f4 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003a2:	37fd                	addiw	a5,a5,-1
    800003a4:	07f7f713          	andi	a4,a5,127
    800003a8:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003aa:	01874703          	lbu	a4,24(a4)
    800003ae:	f52703e3          	beq	a4,s2,800002f4 <consoleintr+0x3c>
      cons.e--;
    800003b2:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003b6:	10000513          	li	a0,256
    800003ba:	00000097          	auipc	ra,0x0
    800003be:	ebc080e7          	jalr	-324(ra) # 80000276 <consputc>
    while(cons.e != cons.w &&
    800003c2:	0a04a783          	lw	a5,160(s1)
    800003c6:	09c4a703          	lw	a4,156(s1)
    800003ca:	fcf71ce3          	bne	a4,a5,800003a2 <consoleintr+0xea>
    800003ce:	b71d                	j	800002f4 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d0:	00011717          	auipc	a4,0x11
    800003d4:	dc070713          	addi	a4,a4,-576 # 80011190 <cons>
    800003d8:	0a072783          	lw	a5,160(a4)
    800003dc:	09c72703          	lw	a4,156(a4)
    800003e0:	f0f70ae3          	beq	a4,a5,800002f4 <consoleintr+0x3c>
      cons.e--;
    800003e4:	37fd                	addiw	a5,a5,-1
    800003e6:	00011717          	auipc	a4,0x11
    800003ea:	e4f72523          	sw	a5,-438(a4) # 80011230 <cons+0xa0>
      consputc(BACKSPACE);
    800003ee:	10000513          	li	a0,256
    800003f2:	00000097          	auipc	ra,0x0
    800003f6:	e84080e7          	jalr	-380(ra) # 80000276 <consputc>
    800003fa:	bded                	j	800002f4 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    800003fc:	ee048ce3          	beqz	s1,800002f4 <consoleintr+0x3c>
    80000400:	bf21                	j	80000318 <consoleintr+0x60>
      consputc(c);
    80000402:	4529                	li	a0,10
    80000404:	00000097          	auipc	ra,0x0
    80000408:	e72080e7          	jalr	-398(ra) # 80000276 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000040c:	00011797          	auipc	a5,0x11
    80000410:	d8478793          	addi	a5,a5,-636 # 80011190 <cons>
    80000414:	0a07a703          	lw	a4,160(a5)
    80000418:	0017069b          	addiw	a3,a4,1
    8000041c:	0006861b          	sext.w	a2,a3
    80000420:	0ad7a023          	sw	a3,160(a5)
    80000424:	07f77713          	andi	a4,a4,127
    80000428:	97ba                	add	a5,a5,a4
    8000042a:	4729                	li	a4,10
    8000042c:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000430:	00011797          	auipc	a5,0x11
    80000434:	dec7ae23          	sw	a2,-516(a5) # 8001122c <cons+0x9c>
        wakeup(&cons.r);
    80000438:	00011517          	auipc	a0,0x11
    8000043c:	df050513          	addi	a0,a0,-528 # 80011228 <cons+0x98>
    80000440:	00002097          	auipc	ra,0x2
    80000444:	526080e7          	jalr	1318(ra) # 80002966 <wakeup>
    80000448:	b575                	j	800002f4 <consoleintr+0x3c>

000000008000044a <consoleinit>:

void
consoleinit(void)
{
    8000044a:	1141                	addi	sp,sp,-16
    8000044c:	e406                	sd	ra,8(sp)
    8000044e:	e022                	sd	s0,0(sp)
    80000450:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000452:	00008597          	auipc	a1,0x8
    80000456:	bbe58593          	addi	a1,a1,-1090 # 80008010 <etext+0x10>
    8000045a:	00011517          	auipc	a0,0x11
    8000045e:	d3650513          	addi	a0,a0,-714 # 80011190 <cons>
    80000462:	00000097          	auipc	ra,0x0
    80000466:	6de080e7          	jalr	1758(ra) # 80000b40 <initlock>

  uartinit();
    8000046a:	00000097          	auipc	ra,0x0
    8000046e:	32c080e7          	jalr	812(ra) # 80000796 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000472:	00021797          	auipc	a5,0x21
    80000476:	62e78793          	addi	a5,a5,1582 # 80021aa0 <devsw>
    8000047a:	00000717          	auipc	a4,0x0
    8000047e:	cea70713          	addi	a4,a4,-790 # 80000164 <consoleread>
    80000482:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000484:	00000717          	auipc	a4,0x0
    80000488:	c7c70713          	addi	a4,a4,-900 # 80000100 <consolewrite>
    8000048c:	ef98                	sd	a4,24(a5)
}
    8000048e:	60a2                	ld	ra,8(sp)
    80000490:	6402                	ld	s0,0(sp)
    80000492:	0141                	addi	sp,sp,16
    80000494:	8082                	ret

0000000080000496 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000496:	7179                	addi	sp,sp,-48
    80000498:	f406                	sd	ra,40(sp)
    8000049a:	f022                	sd	s0,32(sp)
    8000049c:	ec26                	sd	s1,24(sp)
    8000049e:	e84a                	sd	s2,16(sp)
    800004a0:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a2:	c219                	beqz	a2,800004a8 <printint+0x12>
    800004a4:	08054763          	bltz	a0,80000532 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004a8:	2501                	sext.w	a0,a0
    800004aa:	4881                	li	a7,0
    800004ac:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b0:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b2:	2581                	sext.w	a1,a1
    800004b4:	00008617          	auipc	a2,0x8
    800004b8:	b8c60613          	addi	a2,a2,-1140 # 80008040 <digits>
    800004bc:	883a                	mv	a6,a4
    800004be:	2705                	addiw	a4,a4,1
    800004c0:	02b577bb          	remuw	a5,a0,a1
    800004c4:	1782                	slli	a5,a5,0x20
    800004c6:	9381                	srli	a5,a5,0x20
    800004c8:	97b2                	add	a5,a5,a2
    800004ca:	0007c783          	lbu	a5,0(a5)
    800004ce:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d2:	0005079b          	sext.w	a5,a0
    800004d6:	02b5553b          	divuw	a0,a0,a1
    800004da:	0685                	addi	a3,a3,1
    800004dc:	feb7f0e3          	bgeu	a5,a1,800004bc <printint+0x26>

  if(sign)
    800004e0:	00088c63          	beqz	a7,800004f8 <printint+0x62>
    buf[i++] = '-';
    800004e4:	fe070793          	addi	a5,a4,-32
    800004e8:	00878733          	add	a4,a5,s0
    800004ec:	02d00793          	li	a5,45
    800004f0:	fef70823          	sb	a5,-16(a4)
    800004f4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004f8:	02e05763          	blez	a4,80000526 <printint+0x90>
    800004fc:	fd040793          	addi	a5,s0,-48
    80000500:	00e784b3          	add	s1,a5,a4
    80000504:	fff78913          	addi	s2,a5,-1
    80000508:	993a                	add	s2,s2,a4
    8000050a:	377d                	addiw	a4,a4,-1
    8000050c:	1702                	slli	a4,a4,0x20
    8000050e:	9301                	srli	a4,a4,0x20
    80000510:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000514:	fff4c503          	lbu	a0,-1(s1)
    80000518:	00000097          	auipc	ra,0x0
    8000051c:	d5e080e7          	jalr	-674(ra) # 80000276 <consputc>
  while(--i >= 0)
    80000520:	14fd                	addi	s1,s1,-1
    80000522:	ff2499e3          	bne	s1,s2,80000514 <printint+0x7e>
}
    80000526:	70a2                	ld	ra,40(sp)
    80000528:	7402                	ld	s0,32(sp)
    8000052a:	64e2                	ld	s1,24(sp)
    8000052c:	6942                	ld	s2,16(sp)
    8000052e:	6145                	addi	sp,sp,48
    80000530:	8082                	ret
    x = -xx;
    80000532:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000536:	4885                	li	a7,1
    x = -xx;
    80000538:	bf95                	j	800004ac <printint+0x16>

000000008000053a <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053a:	1101                	addi	sp,sp,-32
    8000053c:	ec06                	sd	ra,24(sp)
    8000053e:	e822                	sd	s0,16(sp)
    80000540:	e426                	sd	s1,8(sp)
    80000542:	1000                	addi	s0,sp,32
    80000544:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000546:	00011797          	auipc	a5,0x11
    8000054a:	d007a523          	sw	zero,-758(a5) # 80011250 <pr+0x18>
  printf("panic: ");
    8000054e:	00008517          	auipc	a0,0x8
    80000552:	aca50513          	addi	a0,a0,-1334 # 80008018 <etext+0x18>
    80000556:	00000097          	auipc	ra,0x0
    8000055a:	02e080e7          	jalr	46(ra) # 80000584 <printf>
  printf(s);
    8000055e:	8526                	mv	a0,s1
    80000560:	00000097          	auipc	ra,0x0
    80000564:	024080e7          	jalr	36(ra) # 80000584 <printf>
  printf("\n");
    80000568:	00008517          	auipc	a0,0x8
    8000056c:	b6050513          	addi	a0,a0,-1184 # 800080c8 <digits+0x88>
    80000570:	00000097          	auipc	ra,0x0
    80000574:	014080e7          	jalr	20(ra) # 80000584 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000578:	4785                	li	a5,1
    8000057a:	00009717          	auipc	a4,0x9
    8000057e:	a8f72323          	sw	a5,-1402(a4) # 80009000 <panicked>
  for(;;)
    80000582:	a001                	j	80000582 <panic+0x48>

0000000080000584 <printf>:
{
    80000584:	7131                	addi	sp,sp,-192
    80000586:	fc86                	sd	ra,120(sp)
    80000588:	f8a2                	sd	s0,112(sp)
    8000058a:	f4a6                	sd	s1,104(sp)
    8000058c:	f0ca                	sd	s2,96(sp)
    8000058e:	ecce                	sd	s3,88(sp)
    80000590:	e8d2                	sd	s4,80(sp)
    80000592:	e4d6                	sd	s5,72(sp)
    80000594:	e0da                	sd	s6,64(sp)
    80000596:	fc5e                	sd	s7,56(sp)
    80000598:	f862                	sd	s8,48(sp)
    8000059a:	f466                	sd	s9,40(sp)
    8000059c:	f06a                	sd	s10,32(sp)
    8000059e:	ec6e                	sd	s11,24(sp)
    800005a0:	0100                	addi	s0,sp,128
    800005a2:	8a2a                	mv	s4,a0
    800005a4:	e40c                	sd	a1,8(s0)
    800005a6:	e810                	sd	a2,16(s0)
    800005a8:	ec14                	sd	a3,24(s0)
    800005aa:	f018                	sd	a4,32(s0)
    800005ac:	f41c                	sd	a5,40(s0)
    800005ae:	03043823          	sd	a6,48(s0)
    800005b2:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005b6:	00011d97          	auipc	s11,0x11
    800005ba:	c9adad83          	lw	s11,-870(s11) # 80011250 <pr+0x18>
  if(locking)
    800005be:	020d9b63          	bnez	s11,800005f4 <printf+0x70>
  if (fmt == 0)
    800005c2:	040a0263          	beqz	s4,80000606 <printf+0x82>
  va_start(ap, fmt);
    800005c6:	00840793          	addi	a5,s0,8
    800005ca:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005ce:	000a4503          	lbu	a0,0(s4)
    800005d2:	14050f63          	beqz	a0,80000730 <printf+0x1ac>
    800005d6:	4981                	li	s3,0
    if(c != '%'){
    800005d8:	02500a93          	li	s5,37
    switch(c){
    800005dc:	07000b93          	li	s7,112
  consputc('x');
    800005e0:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e2:	00008b17          	auipc	s6,0x8
    800005e6:	a5eb0b13          	addi	s6,s6,-1442 # 80008040 <digits>
    switch(c){
    800005ea:	07300c93          	li	s9,115
    800005ee:	06400c13          	li	s8,100
    800005f2:	a82d                	j	8000062c <printf+0xa8>
    acquire(&pr.lock);
    800005f4:	00011517          	auipc	a0,0x11
    800005f8:	c4450513          	addi	a0,a0,-956 # 80011238 <pr>
    800005fc:	00000097          	auipc	ra,0x0
    80000600:	5d4080e7          	jalr	1492(ra) # 80000bd0 <acquire>
    80000604:	bf7d                	j	800005c2 <printf+0x3e>
    panic("null fmt");
    80000606:	00008517          	auipc	a0,0x8
    8000060a:	a2250513          	addi	a0,a0,-1502 # 80008028 <etext+0x28>
    8000060e:	00000097          	auipc	ra,0x0
    80000612:	f2c080e7          	jalr	-212(ra) # 8000053a <panic>
      consputc(c);
    80000616:	00000097          	auipc	ra,0x0
    8000061a:	c60080e7          	jalr	-928(ra) # 80000276 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000061e:	2985                	addiw	s3,s3,1
    80000620:	013a07b3          	add	a5,s4,s3
    80000624:	0007c503          	lbu	a0,0(a5)
    80000628:	10050463          	beqz	a0,80000730 <printf+0x1ac>
    if(c != '%'){
    8000062c:	ff5515e3          	bne	a0,s5,80000616 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000630:	2985                	addiw	s3,s3,1
    80000632:	013a07b3          	add	a5,s4,s3
    80000636:	0007c783          	lbu	a5,0(a5)
    8000063a:	0007849b          	sext.w	s1,a5
    if(c == 0)
    8000063e:	cbed                	beqz	a5,80000730 <printf+0x1ac>
    switch(c){
    80000640:	05778a63          	beq	a5,s7,80000694 <printf+0x110>
    80000644:	02fbf663          	bgeu	s7,a5,80000670 <printf+0xec>
    80000648:	09978863          	beq	a5,s9,800006d8 <printf+0x154>
    8000064c:	07800713          	li	a4,120
    80000650:	0ce79563          	bne	a5,a4,8000071a <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000654:	f8843783          	ld	a5,-120(s0)
    80000658:	00878713          	addi	a4,a5,8
    8000065c:	f8e43423          	sd	a4,-120(s0)
    80000660:	4605                	li	a2,1
    80000662:	85ea                	mv	a1,s10
    80000664:	4388                	lw	a0,0(a5)
    80000666:	00000097          	auipc	ra,0x0
    8000066a:	e30080e7          	jalr	-464(ra) # 80000496 <printint>
      break;
    8000066e:	bf45                	j	8000061e <printf+0x9a>
    switch(c){
    80000670:	09578f63          	beq	a5,s5,8000070e <printf+0x18a>
    80000674:	0b879363          	bne	a5,s8,8000071a <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80000678:	f8843783          	ld	a5,-120(s0)
    8000067c:	00878713          	addi	a4,a5,8
    80000680:	f8e43423          	sd	a4,-120(s0)
    80000684:	4605                	li	a2,1
    80000686:	45a9                	li	a1,10
    80000688:	4388                	lw	a0,0(a5)
    8000068a:	00000097          	auipc	ra,0x0
    8000068e:	e0c080e7          	jalr	-500(ra) # 80000496 <printint>
      break;
    80000692:	b771                	j	8000061e <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000694:	f8843783          	ld	a5,-120(s0)
    80000698:	00878713          	addi	a4,a5,8
    8000069c:	f8e43423          	sd	a4,-120(s0)
    800006a0:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a4:	03000513          	li	a0,48
    800006a8:	00000097          	auipc	ra,0x0
    800006ac:	bce080e7          	jalr	-1074(ra) # 80000276 <consputc>
  consputc('x');
    800006b0:	07800513          	li	a0,120
    800006b4:	00000097          	auipc	ra,0x0
    800006b8:	bc2080e7          	jalr	-1086(ra) # 80000276 <consputc>
    800006bc:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006be:	03c95793          	srli	a5,s2,0x3c
    800006c2:	97da                	add	a5,a5,s6
    800006c4:	0007c503          	lbu	a0,0(a5)
    800006c8:	00000097          	auipc	ra,0x0
    800006cc:	bae080e7          	jalr	-1106(ra) # 80000276 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d0:	0912                	slli	s2,s2,0x4
    800006d2:	34fd                	addiw	s1,s1,-1
    800006d4:	f4ed                	bnez	s1,800006be <printf+0x13a>
    800006d6:	b7a1                	j	8000061e <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006d8:	f8843783          	ld	a5,-120(s0)
    800006dc:	00878713          	addi	a4,a5,8
    800006e0:	f8e43423          	sd	a4,-120(s0)
    800006e4:	6384                	ld	s1,0(a5)
    800006e6:	cc89                	beqz	s1,80000700 <printf+0x17c>
      for(; *s; s++)
    800006e8:	0004c503          	lbu	a0,0(s1)
    800006ec:	d90d                	beqz	a0,8000061e <printf+0x9a>
        consputc(*s);
    800006ee:	00000097          	auipc	ra,0x0
    800006f2:	b88080e7          	jalr	-1144(ra) # 80000276 <consputc>
      for(; *s; s++)
    800006f6:	0485                	addi	s1,s1,1
    800006f8:	0004c503          	lbu	a0,0(s1)
    800006fc:	f96d                	bnez	a0,800006ee <printf+0x16a>
    800006fe:	b705                	j	8000061e <printf+0x9a>
        s = "(null)";
    80000700:	00008497          	auipc	s1,0x8
    80000704:	92048493          	addi	s1,s1,-1760 # 80008020 <etext+0x20>
      for(; *s; s++)
    80000708:	02800513          	li	a0,40
    8000070c:	b7cd                	j	800006ee <printf+0x16a>
      consputc('%');
    8000070e:	8556                	mv	a0,s5
    80000710:	00000097          	auipc	ra,0x0
    80000714:	b66080e7          	jalr	-1178(ra) # 80000276 <consputc>
      break;
    80000718:	b719                	j	8000061e <printf+0x9a>
      consputc('%');
    8000071a:	8556                	mv	a0,s5
    8000071c:	00000097          	auipc	ra,0x0
    80000720:	b5a080e7          	jalr	-1190(ra) # 80000276 <consputc>
      consputc(c);
    80000724:	8526                	mv	a0,s1
    80000726:	00000097          	auipc	ra,0x0
    8000072a:	b50080e7          	jalr	-1200(ra) # 80000276 <consputc>
      break;
    8000072e:	bdc5                	j	8000061e <printf+0x9a>
  if(locking)
    80000730:	020d9163          	bnez	s11,80000752 <printf+0x1ce>
}
    80000734:	70e6                	ld	ra,120(sp)
    80000736:	7446                	ld	s0,112(sp)
    80000738:	74a6                	ld	s1,104(sp)
    8000073a:	7906                	ld	s2,96(sp)
    8000073c:	69e6                	ld	s3,88(sp)
    8000073e:	6a46                	ld	s4,80(sp)
    80000740:	6aa6                	ld	s5,72(sp)
    80000742:	6b06                	ld	s6,64(sp)
    80000744:	7be2                	ld	s7,56(sp)
    80000746:	7c42                	ld	s8,48(sp)
    80000748:	7ca2                	ld	s9,40(sp)
    8000074a:	7d02                	ld	s10,32(sp)
    8000074c:	6de2                	ld	s11,24(sp)
    8000074e:	6129                	addi	sp,sp,192
    80000750:	8082                	ret
    release(&pr.lock);
    80000752:	00011517          	auipc	a0,0x11
    80000756:	ae650513          	addi	a0,a0,-1306 # 80011238 <pr>
    8000075a:	00000097          	auipc	ra,0x0
    8000075e:	52a080e7          	jalr	1322(ra) # 80000c84 <release>
}
    80000762:	bfc9                	j	80000734 <printf+0x1b0>

0000000080000764 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000764:	1101                	addi	sp,sp,-32
    80000766:	ec06                	sd	ra,24(sp)
    80000768:	e822                	sd	s0,16(sp)
    8000076a:	e426                	sd	s1,8(sp)
    8000076c:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000076e:	00011497          	auipc	s1,0x11
    80000772:	aca48493          	addi	s1,s1,-1334 # 80011238 <pr>
    80000776:	00008597          	auipc	a1,0x8
    8000077a:	8c258593          	addi	a1,a1,-1854 # 80008038 <etext+0x38>
    8000077e:	8526                	mv	a0,s1
    80000780:	00000097          	auipc	ra,0x0
    80000784:	3c0080e7          	jalr	960(ra) # 80000b40 <initlock>
  pr.locking = 1;
    80000788:	4785                	li	a5,1
    8000078a:	cc9c                	sw	a5,24(s1)
}
    8000078c:	60e2                	ld	ra,24(sp)
    8000078e:	6442                	ld	s0,16(sp)
    80000790:	64a2                	ld	s1,8(sp)
    80000792:	6105                	addi	sp,sp,32
    80000794:	8082                	ret

0000000080000796 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000796:	1141                	addi	sp,sp,-16
    80000798:	e406                	sd	ra,8(sp)
    8000079a:	e022                	sd	s0,0(sp)
    8000079c:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000079e:	100007b7          	lui	a5,0x10000
    800007a2:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007a6:	f8000713          	li	a4,-128
    800007aa:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007ae:	470d                	li	a4,3
    800007b0:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b4:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007b8:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007bc:	469d                	li	a3,7
    800007be:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c2:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007c6:	00008597          	auipc	a1,0x8
    800007ca:	89258593          	addi	a1,a1,-1902 # 80008058 <digits+0x18>
    800007ce:	00011517          	auipc	a0,0x11
    800007d2:	a8a50513          	addi	a0,a0,-1398 # 80011258 <uart_tx_lock>
    800007d6:	00000097          	auipc	ra,0x0
    800007da:	36a080e7          	jalr	874(ra) # 80000b40 <initlock>
}
    800007de:	60a2                	ld	ra,8(sp)
    800007e0:	6402                	ld	s0,0(sp)
    800007e2:	0141                	addi	sp,sp,16
    800007e4:	8082                	ret

00000000800007e6 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007e6:	1101                	addi	sp,sp,-32
    800007e8:	ec06                	sd	ra,24(sp)
    800007ea:	e822                	sd	s0,16(sp)
    800007ec:	e426                	sd	s1,8(sp)
    800007ee:	1000                	addi	s0,sp,32
    800007f0:	84aa                	mv	s1,a0
  push_off();
    800007f2:	00000097          	auipc	ra,0x0
    800007f6:	392080e7          	jalr	914(ra) # 80000b84 <push_off>

  if(panicked){
    800007fa:	00009797          	auipc	a5,0x9
    800007fe:	8067a783          	lw	a5,-2042(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000802:	10000737          	lui	a4,0x10000
  if(panicked){
    80000806:	c391                	beqz	a5,8000080a <uartputc_sync+0x24>
    for(;;)
    80000808:	a001                	j	80000808 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080a:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000080e:	0207f793          	andi	a5,a5,32
    80000812:	dfe5                	beqz	a5,8000080a <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000814:	0ff4f513          	zext.b	a0,s1
    80000818:	100007b7          	lui	a5,0x10000
    8000081c:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000820:	00000097          	auipc	ra,0x0
    80000824:	404080e7          	jalr	1028(ra) # 80000c24 <pop_off>
}
    80000828:	60e2                	ld	ra,24(sp)
    8000082a:	6442                	ld	s0,16(sp)
    8000082c:	64a2                	ld	s1,8(sp)
    8000082e:	6105                	addi	sp,sp,32
    80000830:	8082                	ret

0000000080000832 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000832:	00008797          	auipc	a5,0x8
    80000836:	7d67b783          	ld	a5,2006(a5) # 80009008 <uart_tx_r>
    8000083a:	00008717          	auipc	a4,0x8
    8000083e:	7d673703          	ld	a4,2006(a4) # 80009010 <uart_tx_w>
    80000842:	06f70a63          	beq	a4,a5,800008b6 <uartstart+0x84>
{
    80000846:	7139                	addi	sp,sp,-64
    80000848:	fc06                	sd	ra,56(sp)
    8000084a:	f822                	sd	s0,48(sp)
    8000084c:	f426                	sd	s1,40(sp)
    8000084e:	f04a                	sd	s2,32(sp)
    80000850:	ec4e                	sd	s3,24(sp)
    80000852:	e852                	sd	s4,16(sp)
    80000854:	e456                	sd	s5,8(sp)
    80000856:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000858:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000085c:	00011a17          	auipc	s4,0x11
    80000860:	9fca0a13          	addi	s4,s4,-1540 # 80011258 <uart_tx_lock>
    uart_tx_r += 1;
    80000864:	00008497          	auipc	s1,0x8
    80000868:	7a448493          	addi	s1,s1,1956 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000086c:	00008997          	auipc	s3,0x8
    80000870:	7a498993          	addi	s3,s3,1956 # 80009010 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000874:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000878:	02077713          	andi	a4,a4,32
    8000087c:	c705                	beqz	a4,800008a4 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000087e:	01f7f713          	andi	a4,a5,31
    80000882:	9752                	add	a4,a4,s4
    80000884:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    80000888:	0785                	addi	a5,a5,1
    8000088a:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000088c:	8526                	mv	a0,s1
    8000088e:	00002097          	auipc	ra,0x2
    80000892:	0d8080e7          	jalr	216(ra) # 80002966 <wakeup>
    
    WriteReg(THR, c);
    80000896:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000089a:	609c                	ld	a5,0(s1)
    8000089c:	0009b703          	ld	a4,0(s3)
    800008a0:	fcf71ae3          	bne	a4,a5,80000874 <uartstart+0x42>
  }
}
    800008a4:	70e2                	ld	ra,56(sp)
    800008a6:	7442                	ld	s0,48(sp)
    800008a8:	74a2                	ld	s1,40(sp)
    800008aa:	7902                	ld	s2,32(sp)
    800008ac:	69e2                	ld	s3,24(sp)
    800008ae:	6a42                	ld	s4,16(sp)
    800008b0:	6aa2                	ld	s5,8(sp)
    800008b2:	6121                	addi	sp,sp,64
    800008b4:	8082                	ret
    800008b6:	8082                	ret

00000000800008b8 <uartputc>:
{
    800008b8:	7179                	addi	sp,sp,-48
    800008ba:	f406                	sd	ra,40(sp)
    800008bc:	f022                	sd	s0,32(sp)
    800008be:	ec26                	sd	s1,24(sp)
    800008c0:	e84a                	sd	s2,16(sp)
    800008c2:	e44e                	sd	s3,8(sp)
    800008c4:	e052                	sd	s4,0(sp)
    800008c6:	1800                	addi	s0,sp,48
    800008c8:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008ca:	00011517          	auipc	a0,0x11
    800008ce:	98e50513          	addi	a0,a0,-1650 # 80011258 <uart_tx_lock>
    800008d2:	00000097          	auipc	ra,0x0
    800008d6:	2fe080e7          	jalr	766(ra) # 80000bd0 <acquire>
  if(panicked){
    800008da:	00008797          	auipc	a5,0x8
    800008de:	7267a783          	lw	a5,1830(a5) # 80009000 <panicked>
    800008e2:	c391                	beqz	a5,800008e6 <uartputc+0x2e>
    for(;;)
    800008e4:	a001                	j	800008e4 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e6:	00008717          	auipc	a4,0x8
    800008ea:	72a73703          	ld	a4,1834(a4) # 80009010 <uart_tx_w>
    800008ee:	00008797          	auipc	a5,0x8
    800008f2:	71a7b783          	ld	a5,1818(a5) # 80009008 <uart_tx_r>
    800008f6:	02078793          	addi	a5,a5,32
    800008fa:	02e79b63          	bne	a5,a4,80000930 <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    800008fe:	00011997          	auipc	s3,0x11
    80000902:	95a98993          	addi	s3,s3,-1702 # 80011258 <uart_tx_lock>
    80000906:	00008497          	auipc	s1,0x8
    8000090a:	70248493          	addi	s1,s1,1794 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090e:	00008917          	auipc	s2,0x8
    80000912:	70290913          	addi	s2,s2,1794 # 80009010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000916:	85ce                	mv	a1,s3
    80000918:	8526                	mv	a0,s1
    8000091a:	00002097          	auipc	ra,0x2
    8000091e:	b64080e7          	jalr	-1180(ra) # 8000247e <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000922:	00093703          	ld	a4,0(s2)
    80000926:	609c                	ld	a5,0(s1)
    80000928:	02078793          	addi	a5,a5,32
    8000092c:	fee785e3          	beq	a5,a4,80000916 <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000930:	00011497          	auipc	s1,0x11
    80000934:	92848493          	addi	s1,s1,-1752 # 80011258 <uart_tx_lock>
    80000938:	01f77793          	andi	a5,a4,31
    8000093c:	97a6                	add	a5,a5,s1
    8000093e:	01478c23          	sb	s4,24(a5)
      uart_tx_w += 1;
    80000942:	0705                	addi	a4,a4,1
    80000944:	00008797          	auipc	a5,0x8
    80000948:	6ce7b623          	sd	a4,1740(a5) # 80009010 <uart_tx_w>
      uartstart();
    8000094c:	00000097          	auipc	ra,0x0
    80000950:	ee6080e7          	jalr	-282(ra) # 80000832 <uartstart>
      release(&uart_tx_lock);
    80000954:	8526                	mv	a0,s1
    80000956:	00000097          	auipc	ra,0x0
    8000095a:	32e080e7          	jalr	814(ra) # 80000c84 <release>
}
    8000095e:	70a2                	ld	ra,40(sp)
    80000960:	7402                	ld	s0,32(sp)
    80000962:	64e2                	ld	s1,24(sp)
    80000964:	6942                	ld	s2,16(sp)
    80000966:	69a2                	ld	s3,8(sp)
    80000968:	6a02                	ld	s4,0(sp)
    8000096a:	6145                	addi	sp,sp,48
    8000096c:	8082                	ret

000000008000096e <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000096e:	1141                	addi	sp,sp,-16
    80000970:	e422                	sd	s0,8(sp)
    80000972:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000974:	100007b7          	lui	a5,0x10000
    80000978:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000097c:	8b85                	andi	a5,a5,1
    8000097e:	cb81                	beqz	a5,8000098e <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000980:	100007b7          	lui	a5,0x10000
    80000984:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    80000988:	6422                	ld	s0,8(sp)
    8000098a:	0141                	addi	sp,sp,16
    8000098c:	8082                	ret
    return -1;
    8000098e:	557d                	li	a0,-1
    80000990:	bfe5                	j	80000988 <uartgetc+0x1a>

0000000080000992 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    80000992:	1101                	addi	sp,sp,-32
    80000994:	ec06                	sd	ra,24(sp)
    80000996:	e822                	sd	s0,16(sp)
    80000998:	e426                	sd	s1,8(sp)
    8000099a:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000099c:	54fd                	li	s1,-1
    8000099e:	a029                	j	800009a8 <uartintr+0x16>
      break;
    consoleintr(c);
    800009a0:	00000097          	auipc	ra,0x0
    800009a4:	918080e7          	jalr	-1768(ra) # 800002b8 <consoleintr>
    int c = uartgetc();
    800009a8:	00000097          	auipc	ra,0x0
    800009ac:	fc6080e7          	jalr	-58(ra) # 8000096e <uartgetc>
    if(c == -1)
    800009b0:	fe9518e3          	bne	a0,s1,800009a0 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009b4:	00011497          	auipc	s1,0x11
    800009b8:	8a448493          	addi	s1,s1,-1884 # 80011258 <uart_tx_lock>
    800009bc:	8526                	mv	a0,s1
    800009be:	00000097          	auipc	ra,0x0
    800009c2:	212080e7          	jalr	530(ra) # 80000bd0 <acquire>
  uartstart();
    800009c6:	00000097          	auipc	ra,0x0
    800009ca:	e6c080e7          	jalr	-404(ra) # 80000832 <uartstart>
  release(&uart_tx_lock);
    800009ce:	8526                	mv	a0,s1
    800009d0:	00000097          	auipc	ra,0x0
    800009d4:	2b4080e7          	jalr	692(ra) # 80000c84 <release>
}
    800009d8:	60e2                	ld	ra,24(sp)
    800009da:	6442                	ld	s0,16(sp)
    800009dc:	64a2                	ld	s1,8(sp)
    800009de:	6105                	addi	sp,sp,32
    800009e0:	8082                	ret

00000000800009e2 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e2:	1101                	addi	sp,sp,-32
    800009e4:	ec06                	sd	ra,24(sp)
    800009e6:	e822                	sd	s0,16(sp)
    800009e8:	e426                	sd	s1,8(sp)
    800009ea:	e04a                	sd	s2,0(sp)
    800009ec:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009ee:	03451793          	slli	a5,a0,0x34
    800009f2:	ebb9                	bnez	a5,80000a48 <kfree+0x66>
    800009f4:	84aa                	mv	s1,a0
    800009f6:	00025797          	auipc	a5,0x25
    800009fa:	60a78793          	addi	a5,a5,1546 # 80026000 <end>
    800009fe:	04f56563          	bltu	a0,a5,80000a48 <kfree+0x66>
    80000a02:	47c5                	li	a5,17
    80000a04:	07ee                	slli	a5,a5,0x1b
    80000a06:	04f57163          	bgeu	a0,a5,80000a48 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a0a:	6605                	lui	a2,0x1
    80000a0c:	4585                	li	a1,1
    80000a0e:	00000097          	auipc	ra,0x0
    80000a12:	2be080e7          	jalr	702(ra) # 80000ccc <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a16:	00011917          	auipc	s2,0x11
    80000a1a:	87a90913          	addi	s2,s2,-1926 # 80011290 <kmem>
    80000a1e:	854a                	mv	a0,s2
    80000a20:	00000097          	auipc	ra,0x0
    80000a24:	1b0080e7          	jalr	432(ra) # 80000bd0 <acquire>
  r->next = kmem.freelist;
    80000a28:	01893783          	ld	a5,24(s2)
    80000a2c:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a2e:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a32:	854a                	mv	a0,s2
    80000a34:	00000097          	auipc	ra,0x0
    80000a38:	250080e7          	jalr	592(ra) # 80000c84 <release>
}
    80000a3c:	60e2                	ld	ra,24(sp)
    80000a3e:	6442                	ld	s0,16(sp)
    80000a40:	64a2                	ld	s1,8(sp)
    80000a42:	6902                	ld	s2,0(sp)
    80000a44:	6105                	addi	sp,sp,32
    80000a46:	8082                	ret
    panic("kfree");
    80000a48:	00007517          	auipc	a0,0x7
    80000a4c:	61850513          	addi	a0,a0,1560 # 80008060 <digits+0x20>
    80000a50:	00000097          	auipc	ra,0x0
    80000a54:	aea080e7          	jalr	-1302(ra) # 8000053a <panic>

0000000080000a58 <freerange>:
{
    80000a58:	7179                	addi	sp,sp,-48
    80000a5a:	f406                	sd	ra,40(sp)
    80000a5c:	f022                	sd	s0,32(sp)
    80000a5e:	ec26                	sd	s1,24(sp)
    80000a60:	e84a                	sd	s2,16(sp)
    80000a62:	e44e                	sd	s3,8(sp)
    80000a64:	e052                	sd	s4,0(sp)
    80000a66:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a68:	6785                	lui	a5,0x1
    80000a6a:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a6e:	00e504b3          	add	s1,a0,a4
    80000a72:	777d                	lui	a4,0xfffff
    80000a74:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a76:	94be                	add	s1,s1,a5
    80000a78:	0095ee63          	bltu	a1,s1,80000a94 <freerange+0x3c>
    80000a7c:	892e                	mv	s2,a1
    kfree(p);
    80000a7e:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a80:	6985                	lui	s3,0x1
    kfree(p);
    80000a82:	01448533          	add	a0,s1,s4
    80000a86:	00000097          	auipc	ra,0x0
    80000a8a:	f5c080e7          	jalr	-164(ra) # 800009e2 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a8e:	94ce                	add	s1,s1,s3
    80000a90:	fe9979e3          	bgeu	s2,s1,80000a82 <freerange+0x2a>
}
    80000a94:	70a2                	ld	ra,40(sp)
    80000a96:	7402                	ld	s0,32(sp)
    80000a98:	64e2                	ld	s1,24(sp)
    80000a9a:	6942                	ld	s2,16(sp)
    80000a9c:	69a2                	ld	s3,8(sp)
    80000a9e:	6a02                	ld	s4,0(sp)
    80000aa0:	6145                	addi	sp,sp,48
    80000aa2:	8082                	ret

0000000080000aa4 <kinit>:
{
    80000aa4:	1141                	addi	sp,sp,-16
    80000aa6:	e406                	sd	ra,8(sp)
    80000aa8:	e022                	sd	s0,0(sp)
    80000aaa:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000aac:	00007597          	auipc	a1,0x7
    80000ab0:	5bc58593          	addi	a1,a1,1468 # 80008068 <digits+0x28>
    80000ab4:	00010517          	auipc	a0,0x10
    80000ab8:	7dc50513          	addi	a0,a0,2012 # 80011290 <kmem>
    80000abc:	00000097          	auipc	ra,0x0
    80000ac0:	084080e7          	jalr	132(ra) # 80000b40 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ac4:	45c5                	li	a1,17
    80000ac6:	05ee                	slli	a1,a1,0x1b
    80000ac8:	00025517          	auipc	a0,0x25
    80000acc:	53850513          	addi	a0,a0,1336 # 80026000 <end>
    80000ad0:	00000097          	auipc	ra,0x0
    80000ad4:	f88080e7          	jalr	-120(ra) # 80000a58 <freerange>
}
    80000ad8:	60a2                	ld	ra,8(sp)
    80000ada:	6402                	ld	s0,0(sp)
    80000adc:	0141                	addi	sp,sp,16
    80000ade:	8082                	ret

0000000080000ae0 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae0:	1101                	addi	sp,sp,-32
    80000ae2:	ec06                	sd	ra,24(sp)
    80000ae4:	e822                	sd	s0,16(sp)
    80000ae6:	e426                	sd	s1,8(sp)
    80000ae8:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000aea:	00010497          	auipc	s1,0x10
    80000aee:	7a648493          	addi	s1,s1,1958 # 80011290 <kmem>
    80000af2:	8526                	mv	a0,s1
    80000af4:	00000097          	auipc	ra,0x0
    80000af8:	0dc080e7          	jalr	220(ra) # 80000bd0 <acquire>
  r = kmem.freelist;
    80000afc:	6c84                	ld	s1,24(s1)
  if(r)
    80000afe:	c885                	beqz	s1,80000b2e <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b00:	609c                	ld	a5,0(s1)
    80000b02:	00010517          	auipc	a0,0x10
    80000b06:	78e50513          	addi	a0,a0,1934 # 80011290 <kmem>
    80000b0a:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b0c:	00000097          	auipc	ra,0x0
    80000b10:	178080e7          	jalr	376(ra) # 80000c84 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b14:	6605                	lui	a2,0x1
    80000b16:	4595                	li	a1,5
    80000b18:	8526                	mv	a0,s1
    80000b1a:	00000097          	auipc	ra,0x0
    80000b1e:	1b2080e7          	jalr	434(ra) # 80000ccc <memset>
  return (void*)r;
}
    80000b22:	8526                	mv	a0,s1
    80000b24:	60e2                	ld	ra,24(sp)
    80000b26:	6442                	ld	s0,16(sp)
    80000b28:	64a2                	ld	s1,8(sp)
    80000b2a:	6105                	addi	sp,sp,32
    80000b2c:	8082                	ret
  release(&kmem.lock);
    80000b2e:	00010517          	auipc	a0,0x10
    80000b32:	76250513          	addi	a0,a0,1890 # 80011290 <kmem>
    80000b36:	00000097          	auipc	ra,0x0
    80000b3a:	14e080e7          	jalr	334(ra) # 80000c84 <release>
  if(r)
    80000b3e:	b7d5                	j	80000b22 <kalloc+0x42>

0000000080000b40 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b40:	1141                	addi	sp,sp,-16
    80000b42:	e422                	sd	s0,8(sp)
    80000b44:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b46:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b48:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b4c:	00053823          	sd	zero,16(a0)
}
    80000b50:	6422                	ld	s0,8(sp)
    80000b52:	0141                	addi	sp,sp,16
    80000b54:	8082                	ret

0000000080000b56 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b56:	411c                	lw	a5,0(a0)
    80000b58:	e399                	bnez	a5,80000b5e <holding+0x8>
    80000b5a:	4501                	li	a0,0
  return r;
}
    80000b5c:	8082                	ret
{
    80000b5e:	1101                	addi	sp,sp,-32
    80000b60:	ec06                	sd	ra,24(sp)
    80000b62:	e822                	sd	s0,16(sp)
    80000b64:	e426                	sd	s1,8(sp)
    80000b66:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b68:	6904                	ld	s1,16(a0)
    80000b6a:	00001097          	auipc	ra,0x1
    80000b6e:	e98080e7          	jalr	-360(ra) # 80001a02 <mycpu>
    80000b72:	40a48533          	sub	a0,s1,a0
    80000b76:	00153513          	seqz	a0,a0
}
    80000b7a:	60e2                	ld	ra,24(sp)
    80000b7c:	6442                	ld	s0,16(sp)
    80000b7e:	64a2                	ld	s1,8(sp)
    80000b80:	6105                	addi	sp,sp,32
    80000b82:	8082                	ret

0000000080000b84 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b84:	1101                	addi	sp,sp,-32
    80000b86:	ec06                	sd	ra,24(sp)
    80000b88:	e822                	sd	s0,16(sp)
    80000b8a:	e426                	sd	s1,8(sp)
    80000b8c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b8e:	100024f3          	csrr	s1,sstatus
    80000b92:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b96:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b98:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b9c:	00001097          	auipc	ra,0x1
    80000ba0:	e66080e7          	jalr	-410(ra) # 80001a02 <mycpu>
    80000ba4:	5d3c                	lw	a5,120(a0)
    80000ba6:	cf89                	beqz	a5,80000bc0 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000ba8:	00001097          	auipc	ra,0x1
    80000bac:	e5a080e7          	jalr	-422(ra) # 80001a02 <mycpu>
    80000bb0:	5d3c                	lw	a5,120(a0)
    80000bb2:	2785                	addiw	a5,a5,1
    80000bb4:	dd3c                	sw	a5,120(a0)
}
    80000bb6:	60e2                	ld	ra,24(sp)
    80000bb8:	6442                	ld	s0,16(sp)
    80000bba:	64a2                	ld	s1,8(sp)
    80000bbc:	6105                	addi	sp,sp,32
    80000bbe:	8082                	ret
    mycpu()->intena = old;
    80000bc0:	00001097          	auipc	ra,0x1
    80000bc4:	e42080e7          	jalr	-446(ra) # 80001a02 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bc8:	8085                	srli	s1,s1,0x1
    80000bca:	8885                	andi	s1,s1,1
    80000bcc:	dd64                	sw	s1,124(a0)
    80000bce:	bfe9                	j	80000ba8 <push_off+0x24>

0000000080000bd0 <acquire>:
{
    80000bd0:	1101                	addi	sp,sp,-32
    80000bd2:	ec06                	sd	ra,24(sp)
    80000bd4:	e822                	sd	s0,16(sp)
    80000bd6:	e426                	sd	s1,8(sp)
    80000bd8:	1000                	addi	s0,sp,32
    80000bda:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bdc:	00000097          	auipc	ra,0x0
    80000be0:	fa8080e7          	jalr	-88(ra) # 80000b84 <push_off>
  if(holding(lk))
    80000be4:	8526                	mv	a0,s1
    80000be6:	00000097          	auipc	ra,0x0
    80000bea:	f70080e7          	jalr	-144(ra) # 80000b56 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bee:	4705                	li	a4,1
  if(holding(lk))
    80000bf0:	e115                	bnez	a0,80000c14 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf2:	87ba                	mv	a5,a4
    80000bf4:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bf8:	2781                	sext.w	a5,a5
    80000bfa:	ffe5                	bnez	a5,80000bf2 <acquire+0x22>
  __sync_synchronize();
    80000bfc:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c00:	00001097          	auipc	ra,0x1
    80000c04:	e02080e7          	jalr	-510(ra) # 80001a02 <mycpu>
    80000c08:	e888                	sd	a0,16(s1)
}
    80000c0a:	60e2                	ld	ra,24(sp)
    80000c0c:	6442                	ld	s0,16(sp)
    80000c0e:	64a2                	ld	s1,8(sp)
    80000c10:	6105                	addi	sp,sp,32
    80000c12:	8082                	ret
    panic("acquire");
    80000c14:	00007517          	auipc	a0,0x7
    80000c18:	45c50513          	addi	a0,a0,1116 # 80008070 <digits+0x30>
    80000c1c:	00000097          	auipc	ra,0x0
    80000c20:	91e080e7          	jalr	-1762(ra) # 8000053a <panic>

0000000080000c24 <pop_off>:

void
pop_off(void)
{
    80000c24:	1141                	addi	sp,sp,-16
    80000c26:	e406                	sd	ra,8(sp)
    80000c28:	e022                	sd	s0,0(sp)
    80000c2a:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c2c:	00001097          	auipc	ra,0x1
    80000c30:	dd6080e7          	jalr	-554(ra) # 80001a02 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c34:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c38:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c3a:	e78d                	bnez	a5,80000c64 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c3c:	5d3c                	lw	a5,120(a0)
    80000c3e:	02f05b63          	blez	a5,80000c74 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c42:	37fd                	addiw	a5,a5,-1
    80000c44:	0007871b          	sext.w	a4,a5
    80000c48:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c4a:	eb09                	bnez	a4,80000c5c <pop_off+0x38>
    80000c4c:	5d7c                	lw	a5,124(a0)
    80000c4e:	c799                	beqz	a5,80000c5c <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c50:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c54:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c58:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c5c:	60a2                	ld	ra,8(sp)
    80000c5e:	6402                	ld	s0,0(sp)
    80000c60:	0141                	addi	sp,sp,16
    80000c62:	8082                	ret
    panic("pop_off - interruptible");
    80000c64:	00007517          	auipc	a0,0x7
    80000c68:	41450513          	addi	a0,a0,1044 # 80008078 <digits+0x38>
    80000c6c:	00000097          	auipc	ra,0x0
    80000c70:	8ce080e7          	jalr	-1842(ra) # 8000053a <panic>
    panic("pop_off");
    80000c74:	00007517          	auipc	a0,0x7
    80000c78:	41c50513          	addi	a0,a0,1052 # 80008090 <digits+0x50>
    80000c7c:	00000097          	auipc	ra,0x0
    80000c80:	8be080e7          	jalr	-1858(ra) # 8000053a <panic>

0000000080000c84 <release>:
{
    80000c84:	1101                	addi	sp,sp,-32
    80000c86:	ec06                	sd	ra,24(sp)
    80000c88:	e822                	sd	s0,16(sp)
    80000c8a:	e426                	sd	s1,8(sp)
    80000c8c:	1000                	addi	s0,sp,32
    80000c8e:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c90:	00000097          	auipc	ra,0x0
    80000c94:	ec6080e7          	jalr	-314(ra) # 80000b56 <holding>
    80000c98:	c115                	beqz	a0,80000cbc <release+0x38>
  lk->cpu = 0;
    80000c9a:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c9e:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca2:	0f50000f          	fence	iorw,ow
    80000ca6:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000caa:	00000097          	auipc	ra,0x0
    80000cae:	f7a080e7          	jalr	-134(ra) # 80000c24 <pop_off>
}
    80000cb2:	60e2                	ld	ra,24(sp)
    80000cb4:	6442                	ld	s0,16(sp)
    80000cb6:	64a2                	ld	s1,8(sp)
    80000cb8:	6105                	addi	sp,sp,32
    80000cba:	8082                	ret
    panic("release");
    80000cbc:	00007517          	auipc	a0,0x7
    80000cc0:	3dc50513          	addi	a0,a0,988 # 80008098 <digits+0x58>
    80000cc4:	00000097          	auipc	ra,0x0
    80000cc8:	876080e7          	jalr	-1930(ra) # 8000053a <panic>

0000000080000ccc <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000ccc:	1141                	addi	sp,sp,-16
    80000cce:	e422                	sd	s0,8(sp)
    80000cd0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd2:	ca19                	beqz	a2,80000ce8 <memset+0x1c>
    80000cd4:	87aa                	mv	a5,a0
    80000cd6:	1602                	slli	a2,a2,0x20
    80000cd8:	9201                	srli	a2,a2,0x20
    80000cda:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cde:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce2:	0785                	addi	a5,a5,1
    80000ce4:	fee79de3          	bne	a5,a4,80000cde <memset+0x12>
  }
  return dst;
}
    80000ce8:	6422                	ld	s0,8(sp)
    80000cea:	0141                	addi	sp,sp,16
    80000cec:	8082                	ret

0000000080000cee <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cee:	1141                	addi	sp,sp,-16
    80000cf0:	e422                	sd	s0,8(sp)
    80000cf2:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf4:	ca05                	beqz	a2,80000d24 <memcmp+0x36>
    80000cf6:	fff6069b          	addiw	a3,a2,-1
    80000cfa:	1682                	slli	a3,a3,0x20
    80000cfc:	9281                	srli	a3,a3,0x20
    80000cfe:	0685                	addi	a3,a3,1
    80000d00:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d02:	00054783          	lbu	a5,0(a0)
    80000d06:	0005c703          	lbu	a4,0(a1)
    80000d0a:	00e79863          	bne	a5,a4,80000d1a <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d0e:	0505                	addi	a0,a0,1
    80000d10:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d12:	fed518e3          	bne	a0,a3,80000d02 <memcmp+0x14>
  }

  return 0;
    80000d16:	4501                	li	a0,0
    80000d18:	a019                	j	80000d1e <memcmp+0x30>
      return *s1 - *s2;
    80000d1a:	40e7853b          	subw	a0,a5,a4
}
    80000d1e:	6422                	ld	s0,8(sp)
    80000d20:	0141                	addi	sp,sp,16
    80000d22:	8082                	ret
  return 0;
    80000d24:	4501                	li	a0,0
    80000d26:	bfe5                	j	80000d1e <memcmp+0x30>

0000000080000d28 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d28:	1141                	addi	sp,sp,-16
    80000d2a:	e422                	sd	s0,8(sp)
    80000d2c:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d2e:	c205                	beqz	a2,80000d4e <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d30:	02a5e263          	bltu	a1,a0,80000d54 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d34:	1602                	slli	a2,a2,0x20
    80000d36:	9201                	srli	a2,a2,0x20
    80000d38:	00c587b3          	add	a5,a1,a2
{
    80000d3c:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d3e:	0585                	addi	a1,a1,1
    80000d40:	0705                	addi	a4,a4,1
    80000d42:	fff5c683          	lbu	a3,-1(a1)
    80000d46:	fed70fa3          	sb	a3,-1(a4) # ffffffffffffefff <end+0xffffffff7ffd8fff>
    while(n-- > 0)
    80000d4a:	fef59ae3          	bne	a1,a5,80000d3e <memmove+0x16>

  return dst;
}
    80000d4e:	6422                	ld	s0,8(sp)
    80000d50:	0141                	addi	sp,sp,16
    80000d52:	8082                	ret
  if(s < d && s + n > d){
    80000d54:	02061693          	slli	a3,a2,0x20
    80000d58:	9281                	srli	a3,a3,0x20
    80000d5a:	00d58733          	add	a4,a1,a3
    80000d5e:	fce57be3          	bgeu	a0,a4,80000d34 <memmove+0xc>
    d += n;
    80000d62:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d64:	fff6079b          	addiw	a5,a2,-1
    80000d68:	1782                	slli	a5,a5,0x20
    80000d6a:	9381                	srli	a5,a5,0x20
    80000d6c:	fff7c793          	not	a5,a5
    80000d70:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d72:	177d                	addi	a4,a4,-1
    80000d74:	16fd                	addi	a3,a3,-1
    80000d76:	00074603          	lbu	a2,0(a4)
    80000d7a:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d7e:	fee79ae3          	bne	a5,a4,80000d72 <memmove+0x4a>
    80000d82:	b7f1                	j	80000d4e <memmove+0x26>

0000000080000d84 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d84:	1141                	addi	sp,sp,-16
    80000d86:	e406                	sd	ra,8(sp)
    80000d88:	e022                	sd	s0,0(sp)
    80000d8a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d8c:	00000097          	auipc	ra,0x0
    80000d90:	f9c080e7          	jalr	-100(ra) # 80000d28 <memmove>
}
    80000d94:	60a2                	ld	ra,8(sp)
    80000d96:	6402                	ld	s0,0(sp)
    80000d98:	0141                	addi	sp,sp,16
    80000d9a:	8082                	ret

0000000080000d9c <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d9c:	1141                	addi	sp,sp,-16
    80000d9e:	e422                	sd	s0,8(sp)
    80000da0:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da2:	ce11                	beqz	a2,80000dbe <strncmp+0x22>
    80000da4:	00054783          	lbu	a5,0(a0)
    80000da8:	cf89                	beqz	a5,80000dc2 <strncmp+0x26>
    80000daa:	0005c703          	lbu	a4,0(a1)
    80000dae:	00f71a63          	bne	a4,a5,80000dc2 <strncmp+0x26>
    n--, p++, q++;
    80000db2:	367d                	addiw	a2,a2,-1
    80000db4:	0505                	addi	a0,a0,1
    80000db6:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000db8:	f675                	bnez	a2,80000da4 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dba:	4501                	li	a0,0
    80000dbc:	a809                	j	80000dce <strncmp+0x32>
    80000dbe:	4501                	li	a0,0
    80000dc0:	a039                	j	80000dce <strncmp+0x32>
  if(n == 0)
    80000dc2:	ca09                	beqz	a2,80000dd4 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dc4:	00054503          	lbu	a0,0(a0)
    80000dc8:	0005c783          	lbu	a5,0(a1)
    80000dcc:	9d1d                	subw	a0,a0,a5
}
    80000dce:	6422                	ld	s0,8(sp)
    80000dd0:	0141                	addi	sp,sp,16
    80000dd2:	8082                	ret
    return 0;
    80000dd4:	4501                	li	a0,0
    80000dd6:	bfe5                	j	80000dce <strncmp+0x32>

0000000080000dd8 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dd8:	1141                	addi	sp,sp,-16
    80000dda:	e422                	sd	s0,8(sp)
    80000ddc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dde:	872a                	mv	a4,a0
    80000de0:	8832                	mv	a6,a2
    80000de2:	367d                	addiw	a2,a2,-1
    80000de4:	01005963          	blez	a6,80000df6 <strncpy+0x1e>
    80000de8:	0705                	addi	a4,a4,1
    80000dea:	0005c783          	lbu	a5,0(a1)
    80000dee:	fef70fa3          	sb	a5,-1(a4)
    80000df2:	0585                	addi	a1,a1,1
    80000df4:	f7f5                	bnez	a5,80000de0 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000df6:	86ba                	mv	a3,a4
    80000df8:	00c05c63          	blez	a2,80000e10 <strncpy+0x38>
    *s++ = 0;
    80000dfc:	0685                	addi	a3,a3,1
    80000dfe:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e02:	40d707bb          	subw	a5,a4,a3
    80000e06:	37fd                	addiw	a5,a5,-1
    80000e08:	010787bb          	addw	a5,a5,a6
    80000e0c:	fef048e3          	bgtz	a5,80000dfc <strncpy+0x24>
  return os;
}
    80000e10:	6422                	ld	s0,8(sp)
    80000e12:	0141                	addi	sp,sp,16
    80000e14:	8082                	ret

0000000080000e16 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e16:	1141                	addi	sp,sp,-16
    80000e18:	e422                	sd	s0,8(sp)
    80000e1a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e1c:	02c05363          	blez	a2,80000e42 <safestrcpy+0x2c>
    80000e20:	fff6069b          	addiw	a3,a2,-1
    80000e24:	1682                	slli	a3,a3,0x20
    80000e26:	9281                	srli	a3,a3,0x20
    80000e28:	96ae                	add	a3,a3,a1
    80000e2a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e2c:	00d58963          	beq	a1,a3,80000e3e <safestrcpy+0x28>
    80000e30:	0585                	addi	a1,a1,1
    80000e32:	0785                	addi	a5,a5,1
    80000e34:	fff5c703          	lbu	a4,-1(a1)
    80000e38:	fee78fa3          	sb	a4,-1(a5)
    80000e3c:	fb65                	bnez	a4,80000e2c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e3e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e42:	6422                	ld	s0,8(sp)
    80000e44:	0141                	addi	sp,sp,16
    80000e46:	8082                	ret

0000000080000e48 <strlen>:

int
strlen(const char *s)
{
    80000e48:	1141                	addi	sp,sp,-16
    80000e4a:	e422                	sd	s0,8(sp)
    80000e4c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e4e:	00054783          	lbu	a5,0(a0)
    80000e52:	cf91                	beqz	a5,80000e6e <strlen+0x26>
    80000e54:	0505                	addi	a0,a0,1
    80000e56:	87aa                	mv	a5,a0
    80000e58:	4685                	li	a3,1
    80000e5a:	9e89                	subw	a3,a3,a0
    80000e5c:	00f6853b          	addw	a0,a3,a5
    80000e60:	0785                	addi	a5,a5,1
    80000e62:	fff7c703          	lbu	a4,-1(a5)
    80000e66:	fb7d                	bnez	a4,80000e5c <strlen+0x14>
    ;
  return n;
}
    80000e68:	6422                	ld	s0,8(sp)
    80000e6a:	0141                	addi	sp,sp,16
    80000e6c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e6e:	4501                	li	a0,0
    80000e70:	bfe5                	j	80000e68 <strlen+0x20>

0000000080000e72 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e72:	1141                	addi	sp,sp,-16
    80000e74:	e406                	sd	ra,8(sp)
    80000e76:	e022                	sd	s0,0(sp)
    80000e78:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e7a:	00001097          	auipc	ra,0x1
    80000e7e:	b78080e7          	jalr	-1160(ra) # 800019f2 <cpuid>
    init_freelist(); //initialize freelist
    
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e82:	00008717          	auipc	a4,0x8
    80000e86:	19670713          	addi	a4,a4,406 # 80009018 <started>
  if(cpuid() == 0){
    80000e8a:	c139                	beqz	a0,80000ed0 <main+0x5e>
    while(started == 0)
    80000e8c:	431c                	lw	a5,0(a4)
    80000e8e:	2781                	sext.w	a5,a5
    80000e90:	dff5                	beqz	a5,80000e8c <main+0x1a>
      ;
    __sync_synchronize();
    80000e92:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e96:	00001097          	auipc	ra,0x1
    80000e9a:	b5c080e7          	jalr	-1188(ra) # 800019f2 <cpuid>
    80000e9e:	85aa                	mv	a1,a0
    80000ea0:	00007517          	auipc	a0,0x7
    80000ea4:	21850513          	addi	a0,a0,536 # 800080b8 <digits+0x78>
    80000ea8:	fffff097          	auipc	ra,0xfffff
    80000eac:	6dc080e7          	jalr	1756(ra) # 80000584 <printf>
    kvminithart();    // turn on paging
    80000eb0:	00000097          	auipc	ra,0x0
    80000eb4:	0e0080e7          	jalr	224(ra) # 80000f90 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eb8:	00002097          	auipc	ra,0x2
    80000ebc:	faa080e7          	jalr	-86(ra) # 80002e62 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec0:	00005097          	auipc	ra,0x5
    80000ec4:	6b0080e7          	jalr	1712(ra) # 80006570 <plicinithart>
  }

  scheduler();        
    80000ec8:	00001097          	auipc	ra,0x1
    80000ecc:	2da080e7          	jalr	730(ra) # 800021a2 <scheduler>
    consoleinit();
    80000ed0:	fffff097          	auipc	ra,0xfffff
    80000ed4:	57a080e7          	jalr	1402(ra) # 8000044a <consoleinit>
    printfinit();
    80000ed8:	00000097          	auipc	ra,0x0
    80000edc:	88c080e7          	jalr	-1908(ra) # 80000764 <printfinit>
    printf("\n");
    80000ee0:	00007517          	auipc	a0,0x7
    80000ee4:	1e850513          	addi	a0,a0,488 # 800080c8 <digits+0x88>
    80000ee8:	fffff097          	auipc	ra,0xfffff
    80000eec:	69c080e7          	jalr	1692(ra) # 80000584 <printf>
    printf("xv6 kernel is booting\n");
    80000ef0:	00007517          	auipc	a0,0x7
    80000ef4:	1b050513          	addi	a0,a0,432 # 800080a0 <digits+0x60>
    80000ef8:	fffff097          	auipc	ra,0xfffff
    80000efc:	68c080e7          	jalr	1676(ra) # 80000584 <printf>
    printf("\n");
    80000f00:	00007517          	auipc	a0,0x7
    80000f04:	1c850513          	addi	a0,a0,456 # 800080c8 <digits+0x88>
    80000f08:	fffff097          	auipc	ra,0xfffff
    80000f0c:	67c080e7          	jalr	1660(ra) # 80000584 <printf>
    kinit();         // physical page allocator
    80000f10:	00000097          	auipc	ra,0x0
    80000f14:	b94080e7          	jalr	-1132(ra) # 80000aa4 <kinit>
    kvminit();       // create kernel page table
    80000f18:	00000097          	auipc	ra,0x0
    80000f1c:	32a080e7          	jalr	810(ra) # 80001242 <kvminit>
    kvminithart();   // turn on paging
    80000f20:	00000097          	auipc	ra,0x0
    80000f24:	070080e7          	jalr	112(ra) # 80000f90 <kvminithart>
    procinit();      // process table
    80000f28:	00001097          	auipc	ra,0x1
    80000f2c:	9ea080e7          	jalr	-1558(ra) # 80001912 <procinit>
    trapinit();      // trap vectors
    80000f30:	00002097          	auipc	ra,0x2
    80000f34:	f0a080e7          	jalr	-246(ra) # 80002e3a <trapinit>
    trapinithart();  // install kernel trap vector
    80000f38:	00002097          	auipc	ra,0x2
    80000f3c:	f2a080e7          	jalr	-214(ra) # 80002e62 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f40:	00005097          	auipc	ra,0x5
    80000f44:	61a080e7          	jalr	1562(ra) # 8000655a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f48:	00005097          	auipc	ra,0x5
    80000f4c:	628080e7          	jalr	1576(ra) # 80006570 <plicinithart>
    binit();         // buffer cache
    80000f50:	00002097          	auipc	ra,0x2
    80000f54:	7e8080e7          	jalr	2024(ra) # 80003738 <binit>
    iinit();         // inode table
    80000f58:	00003097          	auipc	ra,0x3
    80000f5c:	e76080e7          	jalr	-394(ra) # 80003dce <iinit>
    fileinit();      // file table
    80000f60:	00004097          	auipc	ra,0x4
    80000f64:	e28080e7          	jalr	-472(ra) # 80004d88 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f68:	00005097          	auipc	ra,0x5
    80000f6c:	728080e7          	jalr	1832(ra) # 80006690 <virtio_disk_init>
    userinit();      // first user process
    80000f70:	00001097          	auipc	ra,0x1
    80000f74:	ff8080e7          	jalr	-8(ra) # 80001f68 <userinit>
    init_freelist(); //initialize freelist
    80000f78:	00001097          	auipc	ra,0x1
    80000f7c:	8b4080e7          	jalr	-1868(ra) # 8000182c <init_freelist>
    __sync_synchronize();
    80000f80:	0ff0000f          	fence
    started = 1;
    80000f84:	4785                	li	a5,1
    80000f86:	00008717          	auipc	a4,0x8
    80000f8a:	08f72923          	sw	a5,146(a4) # 80009018 <started>
    80000f8e:	bf2d                	j	80000ec8 <main+0x56>

0000000080000f90 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f90:	1141                	addi	sp,sp,-16
    80000f92:	e422                	sd	s0,8(sp)
    80000f94:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000f96:	00008797          	auipc	a5,0x8
    80000f9a:	08a7b783          	ld	a5,138(a5) # 80009020 <kernel_pagetable>
    80000f9e:	83b1                	srli	a5,a5,0xc
    80000fa0:	577d                	li	a4,-1
    80000fa2:	177e                	slli	a4,a4,0x3f
    80000fa4:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fa6:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000faa:	12000073          	sfence.vma
  sfence_vma();
}
    80000fae:	6422                	ld	s0,8(sp)
    80000fb0:	0141                	addi	sp,sp,16
    80000fb2:	8082                	ret

0000000080000fb4 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb4:	7139                	addi	sp,sp,-64
    80000fb6:	fc06                	sd	ra,56(sp)
    80000fb8:	f822                	sd	s0,48(sp)
    80000fba:	f426                	sd	s1,40(sp)
    80000fbc:	f04a                	sd	s2,32(sp)
    80000fbe:	ec4e                	sd	s3,24(sp)
    80000fc0:	e852                	sd	s4,16(sp)
    80000fc2:	e456                	sd	s5,8(sp)
    80000fc4:	e05a                	sd	s6,0(sp)
    80000fc6:	0080                	addi	s0,sp,64
    80000fc8:	84aa                	mv	s1,a0
    80000fca:	89ae                	mv	s3,a1
    80000fcc:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fce:	57fd                	li	a5,-1
    80000fd0:	83e9                	srli	a5,a5,0x1a
    80000fd2:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd4:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fd6:	04b7f263          	bgeu	a5,a1,8000101a <walk+0x66>
    panic("walk");
    80000fda:	00007517          	auipc	a0,0x7
    80000fde:	0f650513          	addi	a0,a0,246 # 800080d0 <digits+0x90>
    80000fe2:	fffff097          	auipc	ra,0xfffff
    80000fe6:	558080e7          	jalr	1368(ra) # 8000053a <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fea:	060a8663          	beqz	s5,80001056 <walk+0xa2>
    80000fee:	00000097          	auipc	ra,0x0
    80000ff2:	af2080e7          	jalr	-1294(ra) # 80000ae0 <kalloc>
    80000ff6:	84aa                	mv	s1,a0
    80000ff8:	c529                	beqz	a0,80001042 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ffa:	6605                	lui	a2,0x1
    80000ffc:	4581                	li	a1,0
    80000ffe:	00000097          	auipc	ra,0x0
    80001002:	cce080e7          	jalr	-818(ra) # 80000ccc <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001006:	00c4d793          	srli	a5,s1,0xc
    8000100a:	07aa                	slli	a5,a5,0xa
    8000100c:	0017e793          	ori	a5,a5,1
    80001010:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001014:	3a5d                	addiw	s4,s4,-9
    80001016:	036a0063          	beq	s4,s6,80001036 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000101a:	0149d933          	srl	s2,s3,s4
    8000101e:	1ff97913          	andi	s2,s2,511
    80001022:	090e                	slli	s2,s2,0x3
    80001024:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001026:	00093483          	ld	s1,0(s2)
    8000102a:	0014f793          	andi	a5,s1,1
    8000102e:	dfd5                	beqz	a5,80000fea <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001030:	80a9                	srli	s1,s1,0xa
    80001032:	04b2                	slli	s1,s1,0xc
    80001034:	b7c5                	j	80001014 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001036:	00c9d513          	srli	a0,s3,0xc
    8000103a:	1ff57513          	andi	a0,a0,511
    8000103e:	050e                	slli	a0,a0,0x3
    80001040:	9526                	add	a0,a0,s1
}
    80001042:	70e2                	ld	ra,56(sp)
    80001044:	7442                	ld	s0,48(sp)
    80001046:	74a2                	ld	s1,40(sp)
    80001048:	7902                	ld	s2,32(sp)
    8000104a:	69e2                	ld	s3,24(sp)
    8000104c:	6a42                	ld	s4,16(sp)
    8000104e:	6aa2                	ld	s5,8(sp)
    80001050:	6b02                	ld	s6,0(sp)
    80001052:	6121                	addi	sp,sp,64
    80001054:	8082                	ret
        return 0;
    80001056:	4501                	li	a0,0
    80001058:	b7ed                	j	80001042 <walk+0x8e>

000000008000105a <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000105a:	57fd                	li	a5,-1
    8000105c:	83e9                	srli	a5,a5,0x1a
    8000105e:	00b7f463          	bgeu	a5,a1,80001066 <walkaddr+0xc>
    return 0;
    80001062:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001064:	8082                	ret
{
    80001066:	1141                	addi	sp,sp,-16
    80001068:	e406                	sd	ra,8(sp)
    8000106a:	e022                	sd	s0,0(sp)
    8000106c:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000106e:	4601                	li	a2,0
    80001070:	00000097          	auipc	ra,0x0
    80001074:	f44080e7          	jalr	-188(ra) # 80000fb4 <walk>
  if(pte == 0)
    80001078:	c105                	beqz	a0,80001098 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000107a:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000107c:	0117f693          	andi	a3,a5,17
    80001080:	4745                	li	a4,17
    return 0;
    80001082:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001084:	00e68663          	beq	a3,a4,80001090 <walkaddr+0x36>
}
    80001088:	60a2                	ld	ra,8(sp)
    8000108a:	6402                	ld	s0,0(sp)
    8000108c:	0141                	addi	sp,sp,16
    8000108e:	8082                	ret
  pa = PTE2PA(*pte);
    80001090:	83a9                	srli	a5,a5,0xa
    80001092:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001096:	bfcd                	j	80001088 <walkaddr+0x2e>
    return 0;
    80001098:	4501                	li	a0,0
    8000109a:	b7fd                	j	80001088 <walkaddr+0x2e>

000000008000109c <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000109c:	715d                	addi	sp,sp,-80
    8000109e:	e486                	sd	ra,72(sp)
    800010a0:	e0a2                	sd	s0,64(sp)
    800010a2:	fc26                	sd	s1,56(sp)
    800010a4:	f84a                	sd	s2,48(sp)
    800010a6:	f44e                	sd	s3,40(sp)
    800010a8:	f052                	sd	s4,32(sp)
    800010aa:	ec56                	sd	s5,24(sp)
    800010ac:	e85a                	sd	s6,16(sp)
    800010ae:	e45e                	sd	s7,8(sp)
    800010b0:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010b2:	c639                	beqz	a2,80001100 <mappages+0x64>
    800010b4:	8aaa                	mv	s5,a0
    800010b6:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010b8:	777d                	lui	a4,0xfffff
    800010ba:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010be:	fff58993          	addi	s3,a1,-1
    800010c2:	99b2                	add	s3,s3,a2
    800010c4:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010c8:	893e                	mv	s2,a5
    800010ca:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010ce:	6b85                	lui	s7,0x1
    800010d0:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d4:	4605                	li	a2,1
    800010d6:	85ca                	mv	a1,s2
    800010d8:	8556                	mv	a0,s5
    800010da:	00000097          	auipc	ra,0x0
    800010de:	eda080e7          	jalr	-294(ra) # 80000fb4 <walk>
    800010e2:	cd1d                	beqz	a0,80001120 <mappages+0x84>
    if(*pte & PTE_V)
    800010e4:	611c                	ld	a5,0(a0)
    800010e6:	8b85                	andi	a5,a5,1
    800010e8:	e785                	bnez	a5,80001110 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010ea:	80b1                	srli	s1,s1,0xc
    800010ec:	04aa                	slli	s1,s1,0xa
    800010ee:	0164e4b3          	or	s1,s1,s6
    800010f2:	0014e493          	ori	s1,s1,1
    800010f6:	e104                	sd	s1,0(a0)
    if(a == last)
    800010f8:	05390063          	beq	s2,s3,80001138 <mappages+0x9c>
    a += PGSIZE;
    800010fc:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010fe:	bfc9                	j	800010d0 <mappages+0x34>
    panic("mappages: size");
    80001100:	00007517          	auipc	a0,0x7
    80001104:	fd850513          	addi	a0,a0,-40 # 800080d8 <digits+0x98>
    80001108:	fffff097          	auipc	ra,0xfffff
    8000110c:	432080e7          	jalr	1074(ra) # 8000053a <panic>
      panic("mappages: remap");
    80001110:	00007517          	auipc	a0,0x7
    80001114:	fd850513          	addi	a0,a0,-40 # 800080e8 <digits+0xa8>
    80001118:	fffff097          	auipc	ra,0xfffff
    8000111c:	422080e7          	jalr	1058(ra) # 8000053a <panic>
      return -1;
    80001120:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001122:	60a6                	ld	ra,72(sp)
    80001124:	6406                	ld	s0,64(sp)
    80001126:	74e2                	ld	s1,56(sp)
    80001128:	7942                	ld	s2,48(sp)
    8000112a:	79a2                	ld	s3,40(sp)
    8000112c:	7a02                	ld	s4,32(sp)
    8000112e:	6ae2                	ld	s5,24(sp)
    80001130:	6b42                	ld	s6,16(sp)
    80001132:	6ba2                	ld	s7,8(sp)
    80001134:	6161                	addi	sp,sp,80
    80001136:	8082                	ret
  return 0;
    80001138:	4501                	li	a0,0
    8000113a:	b7e5                	j	80001122 <mappages+0x86>

000000008000113c <kvmmap>:
{
    8000113c:	1141                	addi	sp,sp,-16
    8000113e:	e406                	sd	ra,8(sp)
    80001140:	e022                	sd	s0,0(sp)
    80001142:	0800                	addi	s0,sp,16
    80001144:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001146:	86b2                	mv	a3,a2
    80001148:	863e                	mv	a2,a5
    8000114a:	00000097          	auipc	ra,0x0
    8000114e:	f52080e7          	jalr	-174(ra) # 8000109c <mappages>
    80001152:	e509                	bnez	a0,8000115c <kvmmap+0x20>
}
    80001154:	60a2                	ld	ra,8(sp)
    80001156:	6402                	ld	s0,0(sp)
    80001158:	0141                	addi	sp,sp,16
    8000115a:	8082                	ret
    panic("kvmmap");
    8000115c:	00007517          	auipc	a0,0x7
    80001160:	f9c50513          	addi	a0,a0,-100 # 800080f8 <digits+0xb8>
    80001164:	fffff097          	auipc	ra,0xfffff
    80001168:	3d6080e7          	jalr	982(ra) # 8000053a <panic>

000000008000116c <kvmmake>:
{
    8000116c:	1101                	addi	sp,sp,-32
    8000116e:	ec06                	sd	ra,24(sp)
    80001170:	e822                	sd	s0,16(sp)
    80001172:	e426                	sd	s1,8(sp)
    80001174:	e04a                	sd	s2,0(sp)
    80001176:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001178:	00000097          	auipc	ra,0x0
    8000117c:	968080e7          	jalr	-1688(ra) # 80000ae0 <kalloc>
    80001180:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001182:	6605                	lui	a2,0x1
    80001184:	4581                	li	a1,0
    80001186:	00000097          	auipc	ra,0x0
    8000118a:	b46080e7          	jalr	-1210(ra) # 80000ccc <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000118e:	4719                	li	a4,6
    80001190:	6685                	lui	a3,0x1
    80001192:	10000637          	lui	a2,0x10000
    80001196:	100005b7          	lui	a1,0x10000
    8000119a:	8526                	mv	a0,s1
    8000119c:	00000097          	auipc	ra,0x0
    800011a0:	fa0080e7          	jalr	-96(ra) # 8000113c <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a4:	4719                	li	a4,6
    800011a6:	6685                	lui	a3,0x1
    800011a8:	10001637          	lui	a2,0x10001
    800011ac:	100015b7          	lui	a1,0x10001
    800011b0:	8526                	mv	a0,s1
    800011b2:	00000097          	auipc	ra,0x0
    800011b6:	f8a080e7          	jalr	-118(ra) # 8000113c <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011ba:	4719                	li	a4,6
    800011bc:	004006b7          	lui	a3,0x400
    800011c0:	0c000637          	lui	a2,0xc000
    800011c4:	0c0005b7          	lui	a1,0xc000
    800011c8:	8526                	mv	a0,s1
    800011ca:	00000097          	auipc	ra,0x0
    800011ce:	f72080e7          	jalr	-142(ra) # 8000113c <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011d2:	00007917          	auipc	s2,0x7
    800011d6:	e2e90913          	addi	s2,s2,-466 # 80008000 <etext>
    800011da:	4729                	li	a4,10
    800011dc:	80007697          	auipc	a3,0x80007
    800011e0:	e2468693          	addi	a3,a3,-476 # 8000 <_entry-0x7fff8000>
    800011e4:	4605                	li	a2,1
    800011e6:	067e                	slli	a2,a2,0x1f
    800011e8:	85b2                	mv	a1,a2
    800011ea:	8526                	mv	a0,s1
    800011ec:	00000097          	auipc	ra,0x0
    800011f0:	f50080e7          	jalr	-176(ra) # 8000113c <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f4:	4719                	li	a4,6
    800011f6:	46c5                	li	a3,17
    800011f8:	06ee                	slli	a3,a3,0x1b
    800011fa:	412686b3          	sub	a3,a3,s2
    800011fe:	864a                	mv	a2,s2
    80001200:	85ca                	mv	a1,s2
    80001202:	8526                	mv	a0,s1
    80001204:	00000097          	auipc	ra,0x0
    80001208:	f38080e7          	jalr	-200(ra) # 8000113c <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000120c:	4729                	li	a4,10
    8000120e:	6685                	lui	a3,0x1
    80001210:	00006617          	auipc	a2,0x6
    80001214:	df060613          	addi	a2,a2,-528 # 80007000 <_trampoline>
    80001218:	040005b7          	lui	a1,0x4000
    8000121c:	15fd                	addi	a1,a1,-1
    8000121e:	05b2                	slli	a1,a1,0xc
    80001220:	8526                	mv	a0,s1
    80001222:	00000097          	auipc	ra,0x0
    80001226:	f1a080e7          	jalr	-230(ra) # 8000113c <kvmmap>
  proc_mapstacks(kpgtbl);
    8000122a:	8526                	mv	a0,s1
    8000122c:	00000097          	auipc	ra,0x0
    80001230:	650080e7          	jalr	1616(ra) # 8000187c <proc_mapstacks>
}
    80001234:	8526                	mv	a0,s1
    80001236:	60e2                	ld	ra,24(sp)
    80001238:	6442                	ld	s0,16(sp)
    8000123a:	64a2                	ld	s1,8(sp)
    8000123c:	6902                	ld	s2,0(sp)
    8000123e:	6105                	addi	sp,sp,32
    80001240:	8082                	ret

0000000080001242 <kvminit>:
{
    80001242:	1141                	addi	sp,sp,-16
    80001244:	e406                	sd	ra,8(sp)
    80001246:	e022                	sd	s0,0(sp)
    80001248:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000124a:	00000097          	auipc	ra,0x0
    8000124e:	f22080e7          	jalr	-222(ra) # 8000116c <kvmmake>
    80001252:	00008797          	auipc	a5,0x8
    80001256:	dca7b723          	sd	a0,-562(a5) # 80009020 <kernel_pagetable>
}
    8000125a:	60a2                	ld	ra,8(sp)
    8000125c:	6402                	ld	s0,0(sp)
    8000125e:	0141                	addi	sp,sp,16
    80001260:	8082                	ret

0000000080001262 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001262:	715d                	addi	sp,sp,-80
    80001264:	e486                	sd	ra,72(sp)
    80001266:	e0a2                	sd	s0,64(sp)
    80001268:	fc26                	sd	s1,56(sp)
    8000126a:	f84a                	sd	s2,48(sp)
    8000126c:	f44e                	sd	s3,40(sp)
    8000126e:	f052                	sd	s4,32(sp)
    80001270:	ec56                	sd	s5,24(sp)
    80001272:	e85a                	sd	s6,16(sp)
    80001274:	e45e                	sd	s7,8(sp)
    80001276:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001278:	03459793          	slli	a5,a1,0x34
    8000127c:	e795                	bnez	a5,800012a8 <uvmunmap+0x46>
    8000127e:	8a2a                	mv	s4,a0
    80001280:	892e                	mv	s2,a1
    80001282:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001284:	0632                	slli	a2,a2,0xc
    80001286:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000128a:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000128c:	6b05                	lui	s6,0x1
    8000128e:	0735e263          	bltu	a1,s3,800012f2 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001292:	60a6                	ld	ra,72(sp)
    80001294:	6406                	ld	s0,64(sp)
    80001296:	74e2                	ld	s1,56(sp)
    80001298:	7942                	ld	s2,48(sp)
    8000129a:	79a2                	ld	s3,40(sp)
    8000129c:	7a02                	ld	s4,32(sp)
    8000129e:	6ae2                	ld	s5,24(sp)
    800012a0:	6b42                	ld	s6,16(sp)
    800012a2:	6ba2                	ld	s7,8(sp)
    800012a4:	6161                	addi	sp,sp,80
    800012a6:	8082                	ret
    panic("uvmunmap: not aligned");
    800012a8:	00007517          	auipc	a0,0x7
    800012ac:	e5850513          	addi	a0,a0,-424 # 80008100 <digits+0xc0>
    800012b0:	fffff097          	auipc	ra,0xfffff
    800012b4:	28a080e7          	jalr	650(ra) # 8000053a <panic>
      panic("uvmunmap: walk");
    800012b8:	00007517          	auipc	a0,0x7
    800012bc:	e6050513          	addi	a0,a0,-416 # 80008118 <digits+0xd8>
    800012c0:	fffff097          	auipc	ra,0xfffff
    800012c4:	27a080e7          	jalr	634(ra) # 8000053a <panic>
      panic("uvmunmap: not mapped");
    800012c8:	00007517          	auipc	a0,0x7
    800012cc:	e6050513          	addi	a0,a0,-416 # 80008128 <digits+0xe8>
    800012d0:	fffff097          	auipc	ra,0xfffff
    800012d4:	26a080e7          	jalr	618(ra) # 8000053a <panic>
      panic("uvmunmap: not a leaf");
    800012d8:	00007517          	auipc	a0,0x7
    800012dc:	e6850513          	addi	a0,a0,-408 # 80008140 <digits+0x100>
    800012e0:	fffff097          	auipc	ra,0xfffff
    800012e4:	25a080e7          	jalr	602(ra) # 8000053a <panic>
    *pte = 0;
    800012e8:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ec:	995a                	add	s2,s2,s6
    800012ee:	fb3972e3          	bgeu	s2,s3,80001292 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012f2:	4601                	li	a2,0
    800012f4:	85ca                	mv	a1,s2
    800012f6:	8552                	mv	a0,s4
    800012f8:	00000097          	auipc	ra,0x0
    800012fc:	cbc080e7          	jalr	-836(ra) # 80000fb4 <walk>
    80001300:	84aa                	mv	s1,a0
    80001302:	d95d                	beqz	a0,800012b8 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001304:	6108                	ld	a0,0(a0)
    80001306:	00157793          	andi	a5,a0,1
    8000130a:	dfdd                	beqz	a5,800012c8 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000130c:	3ff57793          	andi	a5,a0,1023
    80001310:	fd7784e3          	beq	a5,s7,800012d8 <uvmunmap+0x76>
    if(do_free){
    80001314:	fc0a8ae3          	beqz	s5,800012e8 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001318:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000131a:	0532                	slli	a0,a0,0xc
    8000131c:	fffff097          	auipc	ra,0xfffff
    80001320:	6c6080e7          	jalr	1734(ra) # 800009e2 <kfree>
    80001324:	b7d1                	j	800012e8 <uvmunmap+0x86>

0000000080001326 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001326:	1101                	addi	sp,sp,-32
    80001328:	ec06                	sd	ra,24(sp)
    8000132a:	e822                	sd	s0,16(sp)
    8000132c:	e426                	sd	s1,8(sp)
    8000132e:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001330:	fffff097          	auipc	ra,0xfffff
    80001334:	7b0080e7          	jalr	1968(ra) # 80000ae0 <kalloc>
    80001338:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000133a:	c519                	beqz	a0,80001348 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000133c:	6605                	lui	a2,0x1
    8000133e:	4581                	li	a1,0
    80001340:	00000097          	auipc	ra,0x0
    80001344:	98c080e7          	jalr	-1652(ra) # 80000ccc <memset>
  return pagetable;
}
    80001348:	8526                	mv	a0,s1
    8000134a:	60e2                	ld	ra,24(sp)
    8000134c:	6442                	ld	s0,16(sp)
    8000134e:	64a2                	ld	s1,8(sp)
    80001350:	6105                	addi	sp,sp,32
    80001352:	8082                	ret

0000000080001354 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001354:	7179                	addi	sp,sp,-48
    80001356:	f406                	sd	ra,40(sp)
    80001358:	f022                	sd	s0,32(sp)
    8000135a:	ec26                	sd	s1,24(sp)
    8000135c:	e84a                	sd	s2,16(sp)
    8000135e:	e44e                	sd	s3,8(sp)
    80001360:	e052                	sd	s4,0(sp)
    80001362:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001364:	6785                	lui	a5,0x1
    80001366:	04f67863          	bgeu	a2,a5,800013b6 <uvminit+0x62>
    8000136a:	8a2a                	mv	s4,a0
    8000136c:	89ae                	mv	s3,a1
    8000136e:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001370:	fffff097          	auipc	ra,0xfffff
    80001374:	770080e7          	jalr	1904(ra) # 80000ae0 <kalloc>
    80001378:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000137a:	6605                	lui	a2,0x1
    8000137c:	4581                	li	a1,0
    8000137e:	00000097          	auipc	ra,0x0
    80001382:	94e080e7          	jalr	-1714(ra) # 80000ccc <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001386:	4779                	li	a4,30
    80001388:	86ca                	mv	a3,s2
    8000138a:	6605                	lui	a2,0x1
    8000138c:	4581                	li	a1,0
    8000138e:	8552                	mv	a0,s4
    80001390:	00000097          	auipc	ra,0x0
    80001394:	d0c080e7          	jalr	-756(ra) # 8000109c <mappages>
  memmove(mem, src, sz);
    80001398:	8626                	mv	a2,s1
    8000139a:	85ce                	mv	a1,s3
    8000139c:	854a                	mv	a0,s2
    8000139e:	00000097          	auipc	ra,0x0
    800013a2:	98a080e7          	jalr	-1654(ra) # 80000d28 <memmove>
}
    800013a6:	70a2                	ld	ra,40(sp)
    800013a8:	7402                	ld	s0,32(sp)
    800013aa:	64e2                	ld	s1,24(sp)
    800013ac:	6942                	ld	s2,16(sp)
    800013ae:	69a2                	ld	s3,8(sp)
    800013b0:	6a02                	ld	s4,0(sp)
    800013b2:	6145                	addi	sp,sp,48
    800013b4:	8082                	ret
    panic("inituvm: more than a page");
    800013b6:	00007517          	auipc	a0,0x7
    800013ba:	da250513          	addi	a0,a0,-606 # 80008158 <digits+0x118>
    800013be:	fffff097          	auipc	ra,0xfffff
    800013c2:	17c080e7          	jalr	380(ra) # 8000053a <panic>

00000000800013c6 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c6:	1101                	addi	sp,sp,-32
    800013c8:	ec06                	sd	ra,24(sp)
    800013ca:	e822                	sd	s0,16(sp)
    800013cc:	e426                	sd	s1,8(sp)
    800013ce:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013d0:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013d2:	00b67d63          	bgeu	a2,a1,800013ec <uvmdealloc+0x26>
    800013d6:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013d8:	6785                	lui	a5,0x1
    800013da:	17fd                	addi	a5,a5,-1
    800013dc:	00f60733          	add	a4,a2,a5
    800013e0:	76fd                	lui	a3,0xfffff
    800013e2:	8f75                	and	a4,a4,a3
    800013e4:	97ae                	add	a5,a5,a1
    800013e6:	8ff5                	and	a5,a5,a3
    800013e8:	00f76863          	bltu	a4,a5,800013f8 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013ec:	8526                	mv	a0,s1
    800013ee:	60e2                	ld	ra,24(sp)
    800013f0:	6442                	ld	s0,16(sp)
    800013f2:	64a2                	ld	s1,8(sp)
    800013f4:	6105                	addi	sp,sp,32
    800013f6:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013f8:	8f99                	sub	a5,a5,a4
    800013fa:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013fc:	4685                	li	a3,1
    800013fe:	0007861b          	sext.w	a2,a5
    80001402:	85ba                	mv	a1,a4
    80001404:	00000097          	auipc	ra,0x0
    80001408:	e5e080e7          	jalr	-418(ra) # 80001262 <uvmunmap>
    8000140c:	b7c5                	j	800013ec <uvmdealloc+0x26>

000000008000140e <uvmalloc>:
  if(newsz < oldsz)
    8000140e:	0ab66163          	bltu	a2,a1,800014b0 <uvmalloc+0xa2>
{
    80001412:	7139                	addi	sp,sp,-64
    80001414:	fc06                	sd	ra,56(sp)
    80001416:	f822                	sd	s0,48(sp)
    80001418:	f426                	sd	s1,40(sp)
    8000141a:	f04a                	sd	s2,32(sp)
    8000141c:	ec4e                	sd	s3,24(sp)
    8000141e:	e852                	sd	s4,16(sp)
    80001420:	e456                	sd	s5,8(sp)
    80001422:	0080                	addi	s0,sp,64
    80001424:	8aaa                	mv	s5,a0
    80001426:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001428:	6785                	lui	a5,0x1
    8000142a:	17fd                	addi	a5,a5,-1
    8000142c:	95be                	add	a1,a1,a5
    8000142e:	77fd                	lui	a5,0xfffff
    80001430:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001434:	08c9f063          	bgeu	s3,a2,800014b4 <uvmalloc+0xa6>
    80001438:	894e                	mv	s2,s3
    mem = kalloc();
    8000143a:	fffff097          	auipc	ra,0xfffff
    8000143e:	6a6080e7          	jalr	1702(ra) # 80000ae0 <kalloc>
    80001442:	84aa                	mv	s1,a0
    if(mem == 0){
    80001444:	c51d                	beqz	a0,80001472 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001446:	6605                	lui	a2,0x1
    80001448:	4581                	li	a1,0
    8000144a:	00000097          	auipc	ra,0x0
    8000144e:	882080e7          	jalr	-1918(ra) # 80000ccc <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001452:	4779                	li	a4,30
    80001454:	86a6                	mv	a3,s1
    80001456:	6605                	lui	a2,0x1
    80001458:	85ca                	mv	a1,s2
    8000145a:	8556                	mv	a0,s5
    8000145c:	00000097          	auipc	ra,0x0
    80001460:	c40080e7          	jalr	-960(ra) # 8000109c <mappages>
    80001464:	e905                	bnez	a0,80001494 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001466:	6785                	lui	a5,0x1
    80001468:	993e                	add	s2,s2,a5
    8000146a:	fd4968e3          	bltu	s2,s4,8000143a <uvmalloc+0x2c>
  return newsz;
    8000146e:	8552                	mv	a0,s4
    80001470:	a809                	j	80001482 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001472:	864e                	mv	a2,s3
    80001474:	85ca                	mv	a1,s2
    80001476:	8556                	mv	a0,s5
    80001478:	00000097          	auipc	ra,0x0
    8000147c:	f4e080e7          	jalr	-178(ra) # 800013c6 <uvmdealloc>
      return 0;
    80001480:	4501                	li	a0,0
}
    80001482:	70e2                	ld	ra,56(sp)
    80001484:	7442                	ld	s0,48(sp)
    80001486:	74a2                	ld	s1,40(sp)
    80001488:	7902                	ld	s2,32(sp)
    8000148a:	69e2                	ld	s3,24(sp)
    8000148c:	6a42                	ld	s4,16(sp)
    8000148e:	6aa2                	ld	s5,8(sp)
    80001490:	6121                	addi	sp,sp,64
    80001492:	8082                	ret
      kfree(mem);
    80001494:	8526                	mv	a0,s1
    80001496:	fffff097          	auipc	ra,0xfffff
    8000149a:	54c080e7          	jalr	1356(ra) # 800009e2 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000149e:	864e                	mv	a2,s3
    800014a0:	85ca                	mv	a1,s2
    800014a2:	8556                	mv	a0,s5
    800014a4:	00000097          	auipc	ra,0x0
    800014a8:	f22080e7          	jalr	-222(ra) # 800013c6 <uvmdealloc>
      return 0;
    800014ac:	4501                	li	a0,0
    800014ae:	bfd1                	j	80001482 <uvmalloc+0x74>
    return oldsz;
    800014b0:	852e                	mv	a0,a1
}
    800014b2:	8082                	ret
  return newsz;
    800014b4:	8532                	mv	a0,a2
    800014b6:	b7f1                	j	80001482 <uvmalloc+0x74>

00000000800014b8 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014b8:	7179                	addi	sp,sp,-48
    800014ba:	f406                	sd	ra,40(sp)
    800014bc:	f022                	sd	s0,32(sp)
    800014be:	ec26                	sd	s1,24(sp)
    800014c0:	e84a                	sd	s2,16(sp)
    800014c2:	e44e                	sd	s3,8(sp)
    800014c4:	e052                	sd	s4,0(sp)
    800014c6:	1800                	addi	s0,sp,48
    800014c8:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014ca:	84aa                	mv	s1,a0
    800014cc:	6905                	lui	s2,0x1
    800014ce:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014d0:	4985                	li	s3,1
    800014d2:	a829                	j	800014ec <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014d4:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800014d6:	00c79513          	slli	a0,a5,0xc
    800014da:	00000097          	auipc	ra,0x0
    800014de:	fde080e7          	jalr	-34(ra) # 800014b8 <freewalk>
      pagetable[i] = 0;
    800014e2:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014e6:	04a1                	addi	s1,s1,8
    800014e8:	03248163          	beq	s1,s2,8000150a <freewalk+0x52>
    pte_t pte = pagetable[i];
    800014ec:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014ee:	00f7f713          	andi	a4,a5,15
    800014f2:	ff3701e3          	beq	a4,s3,800014d4 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014f6:	8b85                	andi	a5,a5,1
    800014f8:	d7fd                	beqz	a5,800014e6 <freewalk+0x2e>
      panic("freewalk: leaf");
    800014fa:	00007517          	auipc	a0,0x7
    800014fe:	c7e50513          	addi	a0,a0,-898 # 80008178 <digits+0x138>
    80001502:	fffff097          	auipc	ra,0xfffff
    80001506:	038080e7          	jalr	56(ra) # 8000053a <panic>
    }
  }
  kfree((void*)pagetable);
    8000150a:	8552                	mv	a0,s4
    8000150c:	fffff097          	auipc	ra,0xfffff
    80001510:	4d6080e7          	jalr	1238(ra) # 800009e2 <kfree>
}
    80001514:	70a2                	ld	ra,40(sp)
    80001516:	7402                	ld	s0,32(sp)
    80001518:	64e2                	ld	s1,24(sp)
    8000151a:	6942                	ld	s2,16(sp)
    8000151c:	69a2                	ld	s3,8(sp)
    8000151e:	6a02                	ld	s4,0(sp)
    80001520:	6145                	addi	sp,sp,48
    80001522:	8082                	ret

0000000080001524 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001524:	1101                	addi	sp,sp,-32
    80001526:	ec06                	sd	ra,24(sp)
    80001528:	e822                	sd	s0,16(sp)
    8000152a:	e426                	sd	s1,8(sp)
    8000152c:	1000                	addi	s0,sp,32
    8000152e:	84aa                	mv	s1,a0
  if(sz > 0)
    80001530:	e999                	bnez	a1,80001546 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001532:	8526                	mv	a0,s1
    80001534:	00000097          	auipc	ra,0x0
    80001538:	f84080e7          	jalr	-124(ra) # 800014b8 <freewalk>
}
    8000153c:	60e2                	ld	ra,24(sp)
    8000153e:	6442                	ld	s0,16(sp)
    80001540:	64a2                	ld	s1,8(sp)
    80001542:	6105                	addi	sp,sp,32
    80001544:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001546:	6785                	lui	a5,0x1
    80001548:	17fd                	addi	a5,a5,-1
    8000154a:	95be                	add	a1,a1,a5
    8000154c:	4685                	li	a3,1
    8000154e:	00c5d613          	srli	a2,a1,0xc
    80001552:	4581                	li	a1,0
    80001554:	00000097          	auipc	ra,0x0
    80001558:	d0e080e7          	jalr	-754(ra) # 80001262 <uvmunmap>
    8000155c:	bfd9                	j	80001532 <uvmfree+0xe>

000000008000155e <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000155e:	c679                	beqz	a2,8000162c <uvmcopy+0xce>
{
    80001560:	715d                	addi	sp,sp,-80
    80001562:	e486                	sd	ra,72(sp)
    80001564:	e0a2                	sd	s0,64(sp)
    80001566:	fc26                	sd	s1,56(sp)
    80001568:	f84a                	sd	s2,48(sp)
    8000156a:	f44e                	sd	s3,40(sp)
    8000156c:	f052                	sd	s4,32(sp)
    8000156e:	ec56                	sd	s5,24(sp)
    80001570:	e85a                	sd	s6,16(sp)
    80001572:	e45e                	sd	s7,8(sp)
    80001574:	0880                	addi	s0,sp,80
    80001576:	8b2a                	mv	s6,a0
    80001578:	8aae                	mv	s5,a1
    8000157a:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000157c:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000157e:	4601                	li	a2,0
    80001580:	85ce                	mv	a1,s3
    80001582:	855a                	mv	a0,s6
    80001584:	00000097          	auipc	ra,0x0
    80001588:	a30080e7          	jalr	-1488(ra) # 80000fb4 <walk>
    8000158c:	c531                	beqz	a0,800015d8 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000158e:	6118                	ld	a4,0(a0)
    80001590:	00177793          	andi	a5,a4,1
    80001594:	cbb1                	beqz	a5,800015e8 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001596:	00a75593          	srli	a1,a4,0xa
    8000159a:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000159e:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015a2:	fffff097          	auipc	ra,0xfffff
    800015a6:	53e080e7          	jalr	1342(ra) # 80000ae0 <kalloc>
    800015aa:	892a                	mv	s2,a0
    800015ac:	c939                	beqz	a0,80001602 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015ae:	6605                	lui	a2,0x1
    800015b0:	85de                	mv	a1,s7
    800015b2:	fffff097          	auipc	ra,0xfffff
    800015b6:	776080e7          	jalr	1910(ra) # 80000d28 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015ba:	8726                	mv	a4,s1
    800015bc:	86ca                	mv	a3,s2
    800015be:	6605                	lui	a2,0x1
    800015c0:	85ce                	mv	a1,s3
    800015c2:	8556                	mv	a0,s5
    800015c4:	00000097          	auipc	ra,0x0
    800015c8:	ad8080e7          	jalr	-1320(ra) # 8000109c <mappages>
    800015cc:	e515                	bnez	a0,800015f8 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015ce:	6785                	lui	a5,0x1
    800015d0:	99be                	add	s3,s3,a5
    800015d2:	fb49e6e3          	bltu	s3,s4,8000157e <uvmcopy+0x20>
    800015d6:	a081                	j	80001616 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015d8:	00007517          	auipc	a0,0x7
    800015dc:	bb050513          	addi	a0,a0,-1104 # 80008188 <digits+0x148>
    800015e0:	fffff097          	auipc	ra,0xfffff
    800015e4:	f5a080e7          	jalr	-166(ra) # 8000053a <panic>
      panic("uvmcopy: page not present");
    800015e8:	00007517          	auipc	a0,0x7
    800015ec:	bc050513          	addi	a0,a0,-1088 # 800081a8 <digits+0x168>
    800015f0:	fffff097          	auipc	ra,0xfffff
    800015f4:	f4a080e7          	jalr	-182(ra) # 8000053a <panic>
      kfree(mem);
    800015f8:	854a                	mv	a0,s2
    800015fa:	fffff097          	auipc	ra,0xfffff
    800015fe:	3e8080e7          	jalr	1000(ra) # 800009e2 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001602:	4685                	li	a3,1
    80001604:	00c9d613          	srli	a2,s3,0xc
    80001608:	4581                	li	a1,0
    8000160a:	8556                	mv	a0,s5
    8000160c:	00000097          	auipc	ra,0x0
    80001610:	c56080e7          	jalr	-938(ra) # 80001262 <uvmunmap>
  return -1;
    80001614:	557d                	li	a0,-1
}
    80001616:	60a6                	ld	ra,72(sp)
    80001618:	6406                	ld	s0,64(sp)
    8000161a:	74e2                	ld	s1,56(sp)
    8000161c:	7942                	ld	s2,48(sp)
    8000161e:	79a2                	ld	s3,40(sp)
    80001620:	7a02                	ld	s4,32(sp)
    80001622:	6ae2                	ld	s5,24(sp)
    80001624:	6b42                	ld	s6,16(sp)
    80001626:	6ba2                	ld	s7,8(sp)
    80001628:	6161                	addi	sp,sp,80
    8000162a:	8082                	ret
  return 0;
    8000162c:	4501                	li	a0,0
}
    8000162e:	8082                	ret

0000000080001630 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001630:	1141                	addi	sp,sp,-16
    80001632:	e406                	sd	ra,8(sp)
    80001634:	e022                	sd	s0,0(sp)
    80001636:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001638:	4601                	li	a2,0
    8000163a:	00000097          	auipc	ra,0x0
    8000163e:	97a080e7          	jalr	-1670(ra) # 80000fb4 <walk>
  if(pte == 0)
    80001642:	c901                	beqz	a0,80001652 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001644:	611c                	ld	a5,0(a0)
    80001646:	9bbd                	andi	a5,a5,-17
    80001648:	e11c                	sd	a5,0(a0)
}
    8000164a:	60a2                	ld	ra,8(sp)
    8000164c:	6402                	ld	s0,0(sp)
    8000164e:	0141                	addi	sp,sp,16
    80001650:	8082                	ret
    panic("uvmclear");
    80001652:	00007517          	auipc	a0,0x7
    80001656:	b7650513          	addi	a0,a0,-1162 # 800081c8 <digits+0x188>
    8000165a:	fffff097          	auipc	ra,0xfffff
    8000165e:	ee0080e7          	jalr	-288(ra) # 8000053a <panic>

0000000080001662 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001662:	c6bd                	beqz	a3,800016d0 <copyout+0x6e>
{
    80001664:	715d                	addi	sp,sp,-80
    80001666:	e486                	sd	ra,72(sp)
    80001668:	e0a2                	sd	s0,64(sp)
    8000166a:	fc26                	sd	s1,56(sp)
    8000166c:	f84a                	sd	s2,48(sp)
    8000166e:	f44e                	sd	s3,40(sp)
    80001670:	f052                	sd	s4,32(sp)
    80001672:	ec56                	sd	s5,24(sp)
    80001674:	e85a                	sd	s6,16(sp)
    80001676:	e45e                	sd	s7,8(sp)
    80001678:	e062                	sd	s8,0(sp)
    8000167a:	0880                	addi	s0,sp,80
    8000167c:	8b2a                	mv	s6,a0
    8000167e:	8c2e                	mv	s8,a1
    80001680:	8a32                	mv	s4,a2
    80001682:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001684:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001686:	6a85                	lui	s5,0x1
    80001688:	a015                	j	800016ac <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000168a:	9562                	add	a0,a0,s8
    8000168c:	0004861b          	sext.w	a2,s1
    80001690:	85d2                	mv	a1,s4
    80001692:	41250533          	sub	a0,a0,s2
    80001696:	fffff097          	auipc	ra,0xfffff
    8000169a:	692080e7          	jalr	1682(ra) # 80000d28 <memmove>

    len -= n;
    8000169e:	409989b3          	sub	s3,s3,s1
    src += n;
    800016a2:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016a4:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016a8:	02098263          	beqz	s3,800016cc <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016ac:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016b0:	85ca                	mv	a1,s2
    800016b2:	855a                	mv	a0,s6
    800016b4:	00000097          	auipc	ra,0x0
    800016b8:	9a6080e7          	jalr	-1626(ra) # 8000105a <walkaddr>
    if(pa0 == 0)
    800016bc:	cd01                	beqz	a0,800016d4 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016be:	418904b3          	sub	s1,s2,s8
    800016c2:	94d6                	add	s1,s1,s5
    800016c4:	fc99f3e3          	bgeu	s3,s1,8000168a <copyout+0x28>
    800016c8:	84ce                	mv	s1,s3
    800016ca:	b7c1                	j	8000168a <copyout+0x28>
  }
  return 0;
    800016cc:	4501                	li	a0,0
    800016ce:	a021                	j	800016d6 <copyout+0x74>
    800016d0:	4501                	li	a0,0
}
    800016d2:	8082                	ret
      return -1;
    800016d4:	557d                	li	a0,-1
}
    800016d6:	60a6                	ld	ra,72(sp)
    800016d8:	6406                	ld	s0,64(sp)
    800016da:	74e2                	ld	s1,56(sp)
    800016dc:	7942                	ld	s2,48(sp)
    800016de:	79a2                	ld	s3,40(sp)
    800016e0:	7a02                	ld	s4,32(sp)
    800016e2:	6ae2                	ld	s5,24(sp)
    800016e4:	6b42                	ld	s6,16(sp)
    800016e6:	6ba2                	ld	s7,8(sp)
    800016e8:	6c02                	ld	s8,0(sp)
    800016ea:	6161                	addi	sp,sp,80
    800016ec:	8082                	ret

00000000800016ee <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016ee:	caa5                	beqz	a3,8000175e <copyin+0x70>
{
    800016f0:	715d                	addi	sp,sp,-80
    800016f2:	e486                	sd	ra,72(sp)
    800016f4:	e0a2                	sd	s0,64(sp)
    800016f6:	fc26                	sd	s1,56(sp)
    800016f8:	f84a                	sd	s2,48(sp)
    800016fa:	f44e                	sd	s3,40(sp)
    800016fc:	f052                	sd	s4,32(sp)
    800016fe:	ec56                	sd	s5,24(sp)
    80001700:	e85a                	sd	s6,16(sp)
    80001702:	e45e                	sd	s7,8(sp)
    80001704:	e062                	sd	s8,0(sp)
    80001706:	0880                	addi	s0,sp,80
    80001708:	8b2a                	mv	s6,a0
    8000170a:	8a2e                	mv	s4,a1
    8000170c:	8c32                	mv	s8,a2
    8000170e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001710:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001712:	6a85                	lui	s5,0x1
    80001714:	a01d                	j	8000173a <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001716:	018505b3          	add	a1,a0,s8
    8000171a:	0004861b          	sext.w	a2,s1
    8000171e:	412585b3          	sub	a1,a1,s2
    80001722:	8552                	mv	a0,s4
    80001724:	fffff097          	auipc	ra,0xfffff
    80001728:	604080e7          	jalr	1540(ra) # 80000d28 <memmove>

    len -= n;
    8000172c:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001730:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001732:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001736:	02098263          	beqz	s3,8000175a <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000173a:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000173e:	85ca                	mv	a1,s2
    80001740:	855a                	mv	a0,s6
    80001742:	00000097          	auipc	ra,0x0
    80001746:	918080e7          	jalr	-1768(ra) # 8000105a <walkaddr>
    if(pa0 == 0)
    8000174a:	cd01                	beqz	a0,80001762 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    8000174c:	418904b3          	sub	s1,s2,s8
    80001750:	94d6                	add	s1,s1,s5
    80001752:	fc99f2e3          	bgeu	s3,s1,80001716 <copyin+0x28>
    80001756:	84ce                	mv	s1,s3
    80001758:	bf7d                	j	80001716 <copyin+0x28>
  }
  return 0;
    8000175a:	4501                	li	a0,0
    8000175c:	a021                	j	80001764 <copyin+0x76>
    8000175e:	4501                	li	a0,0
}
    80001760:	8082                	ret
      return -1;
    80001762:	557d                	li	a0,-1
}
    80001764:	60a6                	ld	ra,72(sp)
    80001766:	6406                	ld	s0,64(sp)
    80001768:	74e2                	ld	s1,56(sp)
    8000176a:	7942                	ld	s2,48(sp)
    8000176c:	79a2                	ld	s3,40(sp)
    8000176e:	7a02                	ld	s4,32(sp)
    80001770:	6ae2                	ld	s5,24(sp)
    80001772:	6b42                	ld	s6,16(sp)
    80001774:	6ba2                	ld	s7,8(sp)
    80001776:	6c02                	ld	s8,0(sp)
    80001778:	6161                	addi	sp,sp,80
    8000177a:	8082                	ret

000000008000177c <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000177c:	c2dd                	beqz	a3,80001822 <copyinstr+0xa6>
{
    8000177e:	715d                	addi	sp,sp,-80
    80001780:	e486                	sd	ra,72(sp)
    80001782:	e0a2                	sd	s0,64(sp)
    80001784:	fc26                	sd	s1,56(sp)
    80001786:	f84a                	sd	s2,48(sp)
    80001788:	f44e                	sd	s3,40(sp)
    8000178a:	f052                	sd	s4,32(sp)
    8000178c:	ec56                	sd	s5,24(sp)
    8000178e:	e85a                	sd	s6,16(sp)
    80001790:	e45e                	sd	s7,8(sp)
    80001792:	0880                	addi	s0,sp,80
    80001794:	8a2a                	mv	s4,a0
    80001796:	8b2e                	mv	s6,a1
    80001798:	8bb2                	mv	s7,a2
    8000179a:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    8000179c:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000179e:	6985                	lui	s3,0x1
    800017a0:	a02d                	j	800017ca <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017a2:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017a6:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017a8:	37fd                	addiw	a5,a5,-1
    800017aa:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017ae:	60a6                	ld	ra,72(sp)
    800017b0:	6406                	ld	s0,64(sp)
    800017b2:	74e2                	ld	s1,56(sp)
    800017b4:	7942                	ld	s2,48(sp)
    800017b6:	79a2                	ld	s3,40(sp)
    800017b8:	7a02                	ld	s4,32(sp)
    800017ba:	6ae2                	ld	s5,24(sp)
    800017bc:	6b42                	ld	s6,16(sp)
    800017be:	6ba2                	ld	s7,8(sp)
    800017c0:	6161                	addi	sp,sp,80
    800017c2:	8082                	ret
    srcva = va0 + PGSIZE;
    800017c4:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017c8:	c8a9                	beqz	s1,8000181a <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017ca:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017ce:	85ca                	mv	a1,s2
    800017d0:	8552                	mv	a0,s4
    800017d2:	00000097          	auipc	ra,0x0
    800017d6:	888080e7          	jalr	-1912(ra) # 8000105a <walkaddr>
    if(pa0 == 0)
    800017da:	c131                	beqz	a0,8000181e <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017dc:	417906b3          	sub	a3,s2,s7
    800017e0:	96ce                	add	a3,a3,s3
    800017e2:	00d4f363          	bgeu	s1,a3,800017e8 <copyinstr+0x6c>
    800017e6:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017e8:	955e                	add	a0,a0,s7
    800017ea:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017ee:	daf9                	beqz	a3,800017c4 <copyinstr+0x48>
    800017f0:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017f2:	41650633          	sub	a2,a0,s6
    800017f6:	fff48593          	addi	a1,s1,-1
    800017fa:	95da                	add	a1,a1,s6
    while(n > 0){
    800017fc:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    800017fe:	00f60733          	add	a4,a2,a5
    80001802:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd9000>
    80001806:	df51                	beqz	a4,800017a2 <copyinstr+0x26>
        *dst = *p;
    80001808:	00e78023          	sb	a4,0(a5)
      --max;
    8000180c:	40f584b3          	sub	s1,a1,a5
      dst++;
    80001810:	0785                	addi	a5,a5,1
    while(n > 0){
    80001812:	fed796e3          	bne	a5,a3,800017fe <copyinstr+0x82>
      dst++;
    80001816:	8b3e                	mv	s6,a5
    80001818:	b775                	j	800017c4 <copyinstr+0x48>
    8000181a:	4781                	li	a5,0
    8000181c:	b771                	j	800017a8 <copyinstr+0x2c>
      return -1;
    8000181e:	557d                	li	a0,-1
    80001820:	b779                	j	800017ae <copyinstr+0x32>
  int got_null = 0;
    80001822:	4781                	li	a5,0
  if(got_null){
    80001824:	37fd                	addiw	a5,a5,-1
    80001826:	0007851b          	sext.w	a0,a5
}
    8000182a:	8082                	ret

000000008000182c <init_freelist>:
// must be acquired before any p->lock.

struct spinlock wait_lock;

/*Initialize freelist */
 int init_freelist(){
    8000182c:	1141                	addi	sp,sp,-16
    8000182e:	e422                	sd	s0,8(sp)
    80001830:	0800                	addi	s0,sp,16
    if(i == maxtweettotal -1){
      free_list[i].next = 0 ;
    }

    else{
      free_list[i].next = &free_list[i+1];
    80001832:	00010797          	auipc	a5,0x10
    80001836:	a7e78793          	addi	a5,a5,-1410 # 800112b0 <free_list>
    8000183a:	00010717          	auipc	a4,0x10
    8000183e:	b1670713          	addi	a4,a4,-1258 # 80011350 <free_list+0xa0>
    80001842:	ebd8                	sd	a4,144(a5)
    80001844:	00010717          	auipc	a4,0x10
    80001848:	bac70713          	addi	a4,a4,-1108 # 800113f0 <free_list+0x140>
    8000184c:	12e7b823          	sd	a4,304(a5)
    80001850:	00010717          	auipc	a4,0x10
    80001854:	c4070713          	addi	a4,a4,-960 # 80011490 <free_list+0x1e0>
    80001858:	1ce7b823          	sd	a4,464(a5)
    8000185c:	00010717          	auipc	a4,0x10
    80001860:	cd470713          	addi	a4,a4,-812 # 80011530 <free_list+0x280>
    80001864:	26e7b823          	sd	a4,624(a5)
    if(i == maxtweettotal -1){
    80001868:	3007b823          	sd	zero,784(a5)
    }
  }

  head_available = &free_list[0];
    8000186c:	00007717          	auipc	a4,0x7
    80001870:	7cf73223          	sd	a5,1988(a4) # 80009030 <head_available>
   return 0;
 }
    80001874:	4501                	li	a0,0
    80001876:	6422                	ld	s0,8(sp)
    80001878:	0141                	addi	sp,sp,16
    8000187a:	8082                	ret

000000008000187c <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page. 

void
proc_mapstacks(pagetable_t kpgtbl) {
    8000187c:	7139                	addi	sp,sp,-64
    8000187e:	fc06                	sd	ra,56(sp)
    80001880:	f822                	sd	s0,48(sp)
    80001882:	f426                	sd	s1,40(sp)
    80001884:	f04a                	sd	s2,32(sp)
    80001886:	ec4e                	sd	s3,24(sp)
    80001888:	e852                	sd	s4,16(sp)
    8000188a:	e456                	sd	s5,8(sp)
    8000188c:	e05a                	sd	s6,0(sp)
    8000188e:	0080                	addi	s0,sp,64
    80001890:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001892:	00010497          	auipc	s1,0x10
    80001896:	1c648493          	addi	s1,s1,454 # 80011a58 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000189a:	8b26                	mv	s6,s1
    8000189c:	00006a97          	auipc	s5,0x6
    800018a0:	764a8a93          	addi	s5,s5,1892 # 80008000 <etext>
    800018a4:	04000937          	lui	s2,0x4000
    800018a8:	197d                	addi	s2,s2,-1
    800018aa:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800018ac:	00016a17          	auipc	s4,0x16
    800018b0:	faca0a13          	addi	s4,s4,-84 # 80017858 <tickslock>
    char *pa = kalloc();
    800018b4:	fffff097          	auipc	ra,0xfffff
    800018b8:	22c080e7          	jalr	556(ra) # 80000ae0 <kalloc>
    800018bc:	862a                	mv	a2,a0
    if(pa == 0)
    800018be:	c131                	beqz	a0,80001902 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    800018c0:	416485b3          	sub	a1,s1,s6
    800018c4:	858d                	srai	a1,a1,0x3
    800018c6:	000ab783          	ld	a5,0(s5)
    800018ca:	02f585b3          	mul	a1,a1,a5
    800018ce:	2585                	addiw	a1,a1,1
    800018d0:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800018d4:	4719                	li	a4,6
    800018d6:	6685                	lui	a3,0x1
    800018d8:	40b905b3          	sub	a1,s2,a1
    800018dc:	854e                	mv	a0,s3
    800018de:	00000097          	auipc	ra,0x0
    800018e2:	85e080e7          	jalr	-1954(ra) # 8000113c <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018e6:	17848493          	addi	s1,s1,376
    800018ea:	fd4495e3          	bne	s1,s4,800018b4 <proc_mapstacks+0x38>
  }

}
    800018ee:	70e2                	ld	ra,56(sp)
    800018f0:	7442                	ld	s0,48(sp)
    800018f2:	74a2                	ld	s1,40(sp)
    800018f4:	7902                	ld	s2,32(sp)
    800018f6:	69e2                	ld	s3,24(sp)
    800018f8:	6a42                	ld	s4,16(sp)
    800018fa:	6aa2                	ld	s5,8(sp)
    800018fc:	6b02                	ld	s6,0(sp)
    800018fe:	6121                	addi	sp,sp,64
    80001900:	8082                	ret
      panic("kalloc");
    80001902:	00007517          	auipc	a0,0x7
    80001906:	8d650513          	addi	a0,a0,-1834 # 800081d8 <digits+0x198>
    8000190a:	fffff097          	auipc	ra,0xfffff
    8000190e:	c30080e7          	jalr	-976(ra) # 8000053a <panic>

0000000080001912 <procinit>:

// initialize the proc table at boot time.

void
procinit(void)
{
    80001912:	7139                	addi	sp,sp,-64
    80001914:	fc06                	sd	ra,56(sp)
    80001916:	f822                	sd	s0,48(sp)
    80001918:	f426                	sd	s1,40(sp)
    8000191a:	f04a                	sd	s2,32(sp)
    8000191c:	ec4e                	sd	s3,24(sp)
    8000191e:	e852                	sd	s4,16(sp)
    80001920:	e456                	sd	s5,8(sp)
    80001922:	e05a                	sd	s6,0(sp)
    80001924:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001926:	00007597          	auipc	a1,0x7
    8000192a:	8ba58593          	addi	a1,a1,-1862 # 800081e0 <digits+0x1a0>
    8000192e:	00010517          	auipc	a0,0x10
    80001932:	ca250513          	addi	a0,a0,-862 # 800115d0 <pid_lock>
    80001936:	fffff097          	auipc	ra,0xfffff
    8000193a:	20a080e7          	jalr	522(ra) # 80000b40 <initlock>
  initlock(&wait_lock, "wait_lock");
    8000193e:	00007597          	auipc	a1,0x7
    80001942:	8aa58593          	addi	a1,a1,-1878 # 800081e8 <digits+0x1a8>
    80001946:	00010517          	auipc	a0,0x10
    8000194a:	ca250513          	addi	a0,a0,-862 # 800115e8 <wait_lock>
    8000194e:	fffff097          	auipc	ra,0xfffff
    80001952:	1f2080e7          	jalr	498(ra) # 80000b40 <initlock>
  initlock(&tweet_lock, "tweet_lock");
    80001956:	00007597          	auipc	a1,0x7
    8000195a:	8a258593          	addi	a1,a1,-1886 # 800081f8 <digits+0x1b8>
    8000195e:	00010517          	auipc	a0,0x10
    80001962:	ca250513          	addi	a0,a0,-862 # 80011600 <tweet_lock>
    80001966:	fffff097          	auipc	ra,0xfffff
    8000196a:	1da080e7          	jalr	474(ra) # 80000b40 <initlock>
  initlock(&free_lock , "free_lock");
    8000196e:	00007597          	auipc	a1,0x7
    80001972:	89a58593          	addi	a1,a1,-1894 # 80008208 <digits+0x1c8>
    80001976:	00010517          	auipc	a0,0x10
    8000197a:	ca250513          	addi	a0,a0,-862 # 80011618 <free_lock>
    8000197e:	fffff097          	auipc	ra,0xfffff
    80001982:	1c2080e7          	jalr	450(ra) # 80000b40 <initlock>

  for(p = proc; p < &proc[NPROC]; p++) {
    80001986:	00010497          	auipc	s1,0x10
    8000198a:	0d248493          	addi	s1,s1,210 # 80011a58 <proc>
      initlock(&p->lock, "proc");
    8000198e:	00007b17          	auipc	s6,0x7
    80001992:	88ab0b13          	addi	s6,s6,-1910 # 80008218 <digits+0x1d8>
      p->kstack = KSTACK((int) (p - proc));
    80001996:	8aa6                	mv	s5,s1
    80001998:	00006a17          	auipc	s4,0x6
    8000199c:	668a0a13          	addi	s4,s4,1640 # 80008000 <etext>
    800019a0:	04000937          	lui	s2,0x4000
    800019a4:	197d                	addi	s2,s2,-1
    800019a6:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800019a8:	00016997          	auipc	s3,0x16
    800019ac:	eb098993          	addi	s3,s3,-336 # 80017858 <tickslock>
      initlock(&p->lock, "proc");
    800019b0:	85da                	mv	a1,s6
    800019b2:	8526                	mv	a0,s1
    800019b4:	fffff097          	auipc	ra,0xfffff
    800019b8:	18c080e7          	jalr	396(ra) # 80000b40 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    800019bc:	415487b3          	sub	a5,s1,s5
    800019c0:	878d                	srai	a5,a5,0x3
    800019c2:	000a3703          	ld	a4,0(s4)
    800019c6:	02e787b3          	mul	a5,a5,a4
    800019ca:	2785                	addiw	a5,a5,1
    800019cc:	00d7979b          	slliw	a5,a5,0xd
    800019d0:	40f907b3          	sub	a5,s2,a5
    800019d4:	e8bc                	sd	a5,80(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800019d6:	17848493          	addi	s1,s1,376
    800019da:	fd349be3          	bne	s1,s3,800019b0 <procinit+0x9e>

    }

 }
    800019de:	70e2                	ld	ra,56(sp)
    800019e0:	7442                	ld	s0,48(sp)
    800019e2:	74a2                	ld	s1,40(sp)
    800019e4:	7902                	ld	s2,32(sp)
    800019e6:	69e2                	ld	s3,24(sp)
    800019e8:	6a42                	ld	s4,16(sp)
    800019ea:	6aa2                	ld	s5,8(sp)
    800019ec:	6b02                	ld	s6,0(sp)
    800019ee:	6121                	addi	sp,sp,64
    800019f0:	8082                	ret

00000000800019f2 <cpuid>:
// to a different CPU.

int
cpuid()

{
    800019f2:	1141                	addi	sp,sp,-16
    800019f4:	e422                	sd	s0,8(sp)
    800019f6:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019f8:	8512                	mv	a0,tp

  int id = r_tp();
  return id;

}
    800019fa:	2501                	sext.w	a0,a0
    800019fc:	6422                	ld	s0,8(sp)
    800019fe:	0141                	addi	sp,sp,16
    80001a00:	8082                	ret

0000000080001a02 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.

struct cpu*
mycpu(void) {
    80001a02:	1141                	addi	sp,sp,-16
    80001a04:	e422                	sd	s0,8(sp)
    80001a06:	0800                	addi	s0,sp,16
    80001a08:	8792                	mv	a5,tp

  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001a0a:	2781                	sext.w	a5,a5
    80001a0c:	079e                	slli	a5,a5,0x7
  return c;

}
    80001a0e:	00010517          	auipc	a0,0x10
    80001a12:	c2250513          	addi	a0,a0,-990 # 80011630 <cpus>
    80001a16:	953e                	add	a0,a0,a5
    80001a18:	6422                	ld	s0,8(sp)
    80001a1a:	0141                	addi	sp,sp,16
    80001a1c:	8082                	ret

0000000080001a1e <myproc>:

// Return the current struct proc *, or zero if none.

struct proc*
myproc(void) {
    80001a1e:	1101                	addi	sp,sp,-32
    80001a20:	ec06                	sd	ra,24(sp)
    80001a22:	e822                	sd	s0,16(sp)
    80001a24:	e426                	sd	s1,8(sp)
    80001a26:	1000                	addi	s0,sp,32

  push_off();
    80001a28:	fffff097          	auipc	ra,0xfffff
    80001a2c:	15c080e7          	jalr	348(ra) # 80000b84 <push_off>
    80001a30:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a32:	2781                	sext.w	a5,a5
    80001a34:	079e                	slli	a5,a5,0x7
    80001a36:	00010717          	auipc	a4,0x10
    80001a3a:	87a70713          	addi	a4,a4,-1926 # 800112b0 <free_list>
    80001a3e:	97ba                	add	a5,a5,a4
    80001a40:	3807b483          	ld	s1,896(a5)
  pop_off();
    80001a44:	fffff097          	auipc	ra,0xfffff
    80001a48:	1e0080e7          	jalr	480(ra) # 80000c24 <pop_off>
  return p;
}
    80001a4c:	8526                	mv	a0,s1
    80001a4e:	60e2                	ld	ra,24(sp)
    80001a50:	6442                	ld	s0,16(sp)
    80001a52:	64a2                	ld	s1,8(sp)
    80001a54:	6105                	addi	sp,sp,32
    80001a56:	8082                	ret

0000000080001a58 <tget>:
 int tget (topic_t tag , uint64 buf){
    80001a58:	7179                	addi	sp,sp,-48
    80001a5a:	f406                	sd	ra,40(sp)
    80001a5c:	f022                	sd	s0,32(sp)
    80001a5e:	ec26                	sd	s1,24(sp)
    80001a60:	e84a                	sd	s2,16(sp)
    80001a62:	e44e                	sd	s3,8(sp)
    80001a64:	1800                	addi	s0,sp,48
    80001a66:	84aa                	mv	s1,a0
    80001a68:	892e                	mv	s2,a1
    acquire(&free_lock);
    80001a6a:	00010997          	auipc	s3,0x10
    80001a6e:	bae98993          	addi	s3,s3,-1106 # 80011618 <free_lock>
    80001a72:	854e                	mv	a0,s3
    80001a74:	fffff097          	auipc	ra,0xfffff
    80001a78:	15c080e7          	jalr	348(ra) # 80000bd0 <acquire>
    copyout(myproc()->pagetable, buf , topics_array[tag]->data,140);
    80001a7c:	00000097          	auipc	ra,0x0
    80001a80:	fa2080e7          	jalr	-94(ra) # 80001a1e <myproc>
    80001a84:	02049713          	slli	a4,s1,0x20
    80001a88:	01d75793          	srli	a5,a4,0x1d
    80001a8c:	00010497          	auipc	s1,0x10
    80001a90:	82448493          	addi	s1,s1,-2012 # 800112b0 <free_list>
    80001a94:	94be                	add	s1,s1,a5
    80001a96:	08c00693          	li	a3,140
    80001a9a:	7804b603          	ld	a2,1920(s1)
    80001a9e:	85ca                	mv	a1,s2
    80001aa0:	7128                	ld	a0,96(a0)
    80001aa2:	00000097          	auipc	ra,0x0
    80001aa6:	bc0080e7          	jalr	-1088(ra) # 80001662 <copyout>
    head_available = topics_array[tag];
    80001aaa:	7804b783          	ld	a5,1920(s1)
    80001aae:	00007717          	auipc	a4,0x7
    80001ab2:	58f73123          	sd	a5,1410(a4) # 80009030 <head_available>
    topics_array[tag] = topics_array[tag]->next;
    80001ab6:	6bd8                	ld	a4,144(a5)
    80001ab8:	78e4b023          	sd	a4,1920(s1)
    head_available->next = 0;
    80001abc:	0807b823          	sd	zero,144(a5)
    release(&free_lock);
    80001ac0:	854e                	mv	a0,s3
    80001ac2:	fffff097          	auipc	ra,0xfffff
    80001ac6:	1c2080e7          	jalr	450(ra) # 80000c84 <release>
    printf(" BTGET :First tag node : %s\n",topics_array[tag]);
    80001aca:	7804b583          	ld	a1,1920(s1)
    80001ace:	00006517          	auipc	a0,0x6
    80001ad2:	75250513          	addi	a0,a0,1874 # 80008220 <digits+0x1e0>
    80001ad6:	fffff097          	auipc	ra,0xfffff
    80001ada:	aae080e7          	jalr	-1362(ra) # 80000584 <printf>
   }
    80001ade:	4501                	li	a0,0
    80001ae0:	70a2                	ld	ra,40(sp)
    80001ae2:	7402                	ld	s0,32(sp)
    80001ae4:	64e2                	ld	s1,24(sp)
    80001ae6:	6942                	ld	s2,16(sp)
    80001ae8:	69a2                	ld	s3,8(sp)
    80001aea:	6145                	addi	sp,sp,48
    80001aec:	8082                	ret

0000000080001aee <tput>:
 int tput(topic_t tag , uint64 message){
    80001aee:	7139                	addi	sp,sp,-64
    80001af0:	fc06                	sd	ra,56(sp)
    80001af2:	f822                	sd	s0,48(sp)
    80001af4:	f426                	sd	s1,40(sp)
    80001af6:	f04a                	sd	s2,32(sp)
    80001af8:	ec4e                	sd	s3,24(sp)
    80001afa:	e852                	sd	s4,16(sp)
    80001afc:	e456                	sd	s5,8(sp)
    80001afe:	e05a                	sd	s6,0(sp)
    80001b00:	0080                	addi	s0,sp,64
    80001b02:	892a                	mv	s2,a0
    80001b04:	89ae                	mv	s3,a1
  for (int all =0 ; all<maxtweettotal ; all++){
    80001b06:	00010797          	auipc	a5,0x10
    80001b0a:	84278793          	addi	a5,a5,-1982 # 80011348 <free_list+0x98>
    80001b0e:	0000f497          	auipc	s1,0xf
    80001b12:	7a248493          	addi	s1,s1,1954 # 800112b0 <free_list>
    80001b16:	00010697          	auipc	a3,0x10
    80001b1a:	b5268693          	addi	a3,a3,-1198 # 80011668 <cpus+0x38>
    if(free_list[all].tag==0){
    80001b1e:	4398                	lw	a4,0(a5)
    80001b20:	c779                	beqz	a4,80001bee <tput+0x100>
  for (int all =0 ; all<maxtweettotal ; all++){
    80001b22:	0a078793          	addi	a5,a5,160
    80001b26:	fed79ce3          	bne	a5,a3,80001b1e <tput+0x30>
    printf("tput failed : maxtweettotal tweeets already sent");
    80001b2a:	00006517          	auipc	a0,0x6
    80001b2e:	73e50513          	addi	a0,a0,1854 # 80008268 <digits+0x228>
    80001b32:	fffff097          	auipc	ra,0xfffff
    80001b36:	a52080e7          	jalr	-1454(ra) # 80000584 <printf>
    return -1;
    80001b3a:	557d                	li	a0,-1
    80001b3c:	a879                	j	80001bda <tput+0xec>
      topics_array[tag] = head_available;
    80001b3e:	02091793          	slli	a5,s2,0x20
    80001b42:	01d7d713          	srli	a4,a5,0x1d
    80001b46:	0000f797          	auipc	a5,0xf
    80001b4a:	76a78793          	addi	a5,a5,1898 # 800112b0 <free_list>
    80001b4e:	97ba                	add	a5,a5,a4
    80001b50:	00007717          	auipc	a4,0x7
    80001b54:	4e073703          	ld	a4,1248(a4) # 80009030 <head_available>
    80001b58:	78e7b023          	sd	a4,1920(a5)
    80001b5c:	a8e9                	j	80001c36 <tput+0x148>
        head_available = free_list[i].next; // 
    80001b5e:	00299793          	slli	a5,s3,0x2
    80001b62:	97ce                	add	a5,a5,s3
    80001b64:	0796                	slli	a5,a5,0x5
    80001b66:	0000f717          	auipc	a4,0xf
    80001b6a:	74a70713          	addi	a4,a4,1866 # 800112b0 <free_list>
    80001b6e:	97ba                	add	a5,a5,a4
    80001b70:	6bd8                	ld	a4,144(a5)
    80001b72:	00007697          	auipc	a3,0x7
    80001b76:	4ae6bf23          	sd	a4,1214(a3) # 80009030 <head_available>
        free_list[i].tag = tag; // set the tag for the particular tweet
    80001b7a:	0927ac23          	sw	s2,152(a5)
        if (i!=0){       
    80001b7e:	02098763          	beqz	s3,80001bac <tput+0xbe>
          if (free_list[i-1].tag!=free_list[i].tag){
    80001b82:	39fd                	addiw	s3,s3,-1
    80001b84:	00299793          	slli	a5,s3,0x2
    80001b88:	97ce                	add	a5,a5,s3
    80001b8a:	0796                	slli	a5,a5,0x5
    80001b8c:	0000f717          	auipc	a4,0xf
    80001b90:	72470713          	addi	a4,a4,1828 # 800112b0 <free_list>
    80001b94:	97ba                	add	a5,a5,a4
    80001b96:	0987a783          	lw	a5,152(a5)
    80001b9a:	01278963          	beq	a5,s2,80001bac <tput+0xbe>
              free_list[i-1].next = 0;
    80001b9e:	00299793          	slli	a5,s3,0x2
    80001ba2:	97ce                	add	a5,a5,s3
    80001ba4:	0796                	slli	a5,a5,0x5
    80001ba6:	97ba                	add	a5,a5,a4
    80001ba8:	0807b823          	sd	zero,144(a5)
         tweet_t * temp = topics_array[tag];
    80001bac:	02091793          	slli	a5,s2,0x20
    80001bb0:	01d7d713          	srli	a4,a5,0x1d
    80001bb4:	0000f797          	auipc	a5,0xf
    80001bb8:	6fc78793          	addi	a5,a5,1788 # 800112b0 <free_list>
    80001bbc:	97ba                	add	a5,a5,a4
    80001bbe:	7807b783          	ld	a5,1920(a5)
         while(temp->tag == tag ){
    80001bc2:	0987a703          	lw	a4,152(a5)
    80001bc6:	09271e63          	bne	a4,s2,80001c62 <tput+0x174>
            if(temp->next ==0){
    80001bca:	6bd8                	ld	a4,144(a5)
    80001bcc:	c319                	beqz	a4,80001bd2 <tput+0xe4>
            temp = temp->next;
    80001bce:	87ba                	mv	a5,a4
    80001bd0:	bfcd                	j	80001bc2 <tput+0xd4>
                temp->next = &free_list[i];
    80001bd2:	0967b823          	sd	s6,144(a5)
                break;
    80001bd6:	a071                	j	80001c62 <tput+0x174>
  return 0;
    80001bd8:	4501                	li	a0,0
}
    80001bda:	70e2                	ld	ra,56(sp)
    80001bdc:	7442                	ld	s0,48(sp)
    80001bde:	74a2                	ld	s1,40(sp)
    80001be0:	7902                	ld	s2,32(sp)
    80001be2:	69e2                	ld	s3,24(sp)
    80001be4:	6a42                	ld	s4,16(sp)
    80001be6:	6aa2                	ld	s5,8(sp)
    80001be8:	6b02                	ld	s6,0(sp)
    80001bea:	6121                	addi	sp,sp,64
    80001bec:	8082                	ret
  copyin(myproc()->pagetable,head_available->data,message,140);
    80001bee:	00000097          	auipc	ra,0x0
    80001bf2:	e30080e7          	jalr	-464(ra) # 80001a1e <myproc>
    80001bf6:	08c00693          	li	a3,140
    80001bfa:	864e                	mv	a2,s3
    80001bfc:	00007597          	auipc	a1,0x7
    80001c00:	4345b583          	ld	a1,1076(a1) # 80009030 <head_available>
    80001c04:	7128                	ld	a0,96(a0)
    80001c06:	00000097          	auipc	ra,0x0
    80001c0a:	ae8080e7          	jalr	-1304(ra) # 800016ee <copyin>
  release(&free_lock);
    80001c0e:	00010517          	auipc	a0,0x10
    80001c12:	a0a50513          	addi	a0,a0,-1526 # 80011618 <free_lock>
    80001c16:	fffff097          	auipc	ra,0xfffff
    80001c1a:	06e080e7          	jalr	110(ra) # 80000c84 <release>
  if (topics_array[tag]==0){
    80001c1e:	02091793          	slli	a5,s2,0x20
    80001c22:	01d7d713          	srli	a4,a5,0x1d
    80001c26:	0000f797          	auipc	a5,0xf
    80001c2a:	68a78793          	addi	a5,a5,1674 # 800112b0 <free_list>
    80001c2e:	97ba                	add	a5,a5,a4
    80001c30:	7807b783          	ld	a5,1920(a5)
    80001c34:	d789                	beqz	a5,80001b3e <tput+0x50>
 int tput(topic_t tag , uint64 message){
    80001c36:	4981                	li	s3,0
    if (strncmp(free_list[i].data,head_available->data,140)==0){
    80001c38:	00007a17          	auipc	s4,0x7
    80001c3c:	3f8a0a13          	addi	s4,s4,1016 # 80009030 <head_available>
  for (int i = 0; i < maxtweettotal ; i++){
    80001c40:	4a95                	li	s5,5
    if (strncmp(free_list[i].data,head_available->data,140)==0){
    80001c42:	8b26                	mv	s6,s1
    80001c44:	08c00613          	li	a2,140
    80001c48:	000a3583          	ld	a1,0(s4)
    80001c4c:	8526                	mv	a0,s1
    80001c4e:	fffff097          	auipc	ra,0xfffff
    80001c52:	14e080e7          	jalr	334(ra) # 80000d9c <strncmp>
    80001c56:	d501                	beqz	a0,80001b5e <tput+0x70>
  for (int i = 0; i < maxtweettotal ; i++){
    80001c58:	2985                	addiw	s3,s3,1
    80001c5a:	0a048493          	addi	s1,s1,160
    80001c5e:	ff5992e3          	bne	s3,s5,80001c42 <tput+0x154>
  tweet_t * dup_temp = topics_array[tag];
    80001c62:	02091793          	slli	a5,s2,0x20
    80001c66:	01d7d713          	srli	a4,a5,0x1d
    80001c6a:	0000f797          	auipc	a5,0xf
    80001c6e:	64678793          	addi	a5,a5,1606 # 800112b0 <free_list>
    80001c72:	97ba                	add	a5,a5,a4
    80001c74:	7807b483          	ld	s1,1920(a5)
            printf(" TEST tput : MESSAGE : %s\n next:: %s\n", dup_temp , dup_temp->next );
    80001c78:	00006997          	auipc	s3,0x6
    80001c7c:	5c898993          	addi	s3,s3,1480 # 80008240 <digits+0x200>
          while(dup_temp->tag == tag ){
    80001c80:	0984a783          	lw	a5,152(s1)
    80001c84:	f5279ae3          	bne	a5,s2,80001bd8 <tput+0xea>
            printf(" TEST tput : MESSAGE : %s\n next:: %s\n", dup_temp , dup_temp->next );
    80001c88:	68d0                	ld	a2,144(s1)
    80001c8a:	85a6                	mv	a1,s1
    80001c8c:	854e                	mv	a0,s3
    80001c8e:	fffff097          	auipc	ra,0xfffff
    80001c92:	8f6080e7          	jalr	-1802(ra) # 80000584 <printf>
            if(dup_temp->next ==0){
    80001c96:	68c4                	ld	s1,144(s1)
    80001c98:	f4e5                	bnez	s1,80001c80 <tput+0x192>
  return 0;
    80001c9a:	4501                	li	a0,0
    80001c9c:	bf3d                	j	80001bda <tput+0xec>

0000000080001c9e <forkret>:
// A fork child's very first scheduling by scheduler()
// will swtch to forkret.

void
forkret(void)
{
    80001c9e:	1141                	addi	sp,sp,-16
    80001ca0:	e406                	sd	ra,8(sp)
    80001ca2:	e022                	sd	s0,0(sp)
    80001ca4:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001ca6:	00000097          	auipc	ra,0x0
    80001caa:	d78080e7          	jalr	-648(ra) # 80001a1e <myproc>
    80001cae:	fffff097          	auipc	ra,0xfffff
    80001cb2:	fd6080e7          	jalr	-42(ra) # 80000c84 <release>

  if (first) {
    80001cb6:	00007797          	auipc	a5,0x7
    80001cba:	c7a7a783          	lw	a5,-902(a5) # 80008930 <first.1>
    80001cbe:	eb89                	bnez	a5,80001cd0 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001cc0:	00001097          	auipc	ra,0x1
    80001cc4:	1ba080e7          	jalr	442(ra) # 80002e7a <usertrapret>
}
    80001cc8:	60a2                	ld	ra,8(sp)
    80001cca:	6402                	ld	s0,0(sp)
    80001ccc:	0141                	addi	sp,sp,16
    80001cce:	8082                	ret
    first = 0;
    80001cd0:	00007797          	auipc	a5,0x7
    80001cd4:	c607a023          	sw	zero,-928(a5) # 80008930 <first.1>
    fsinit(ROOTDEV);
    80001cd8:	4505                	li	a0,1
    80001cda:	00002097          	auipc	ra,0x2
    80001cde:	074080e7          	jalr	116(ra) # 80003d4e <fsinit>
    80001ce2:	bff9                	j	80001cc0 <forkret+0x22>

0000000080001ce4 <allocpid>:
allocpid() {
    80001ce4:	1101                	addi	sp,sp,-32
    80001ce6:	ec06                	sd	ra,24(sp)
    80001ce8:	e822                	sd	s0,16(sp)
    80001cea:	e426                	sd	s1,8(sp)
    80001cec:	e04a                	sd	s2,0(sp)
    80001cee:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001cf0:	00010917          	auipc	s2,0x10
    80001cf4:	8e090913          	addi	s2,s2,-1824 # 800115d0 <pid_lock>
    80001cf8:	854a                	mv	a0,s2
    80001cfa:	fffff097          	auipc	ra,0xfffff
    80001cfe:	ed6080e7          	jalr	-298(ra) # 80000bd0 <acquire>
  pid = nextpid;
    80001d02:	00007797          	auipc	a5,0x7
    80001d06:	c3278793          	addi	a5,a5,-974 # 80008934 <nextpid>
    80001d0a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001d0c:	0014871b          	addiw	a4,s1,1
    80001d10:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001d12:	854a                	mv	a0,s2
    80001d14:	fffff097          	auipc	ra,0xfffff
    80001d18:	f70080e7          	jalr	-144(ra) # 80000c84 <release>
}
    80001d1c:	8526                	mv	a0,s1
    80001d1e:	60e2                	ld	ra,24(sp)
    80001d20:	6442                	ld	s0,16(sp)
    80001d22:	64a2                	ld	s1,8(sp)
    80001d24:	6902                	ld	s2,0(sp)
    80001d26:	6105                	addi	sp,sp,32
    80001d28:	8082                	ret

0000000080001d2a <proc_pagetable>:
{
    80001d2a:	1101                	addi	sp,sp,-32
    80001d2c:	ec06                	sd	ra,24(sp)
    80001d2e:	e822                	sd	s0,16(sp)
    80001d30:	e426                	sd	s1,8(sp)
    80001d32:	e04a                	sd	s2,0(sp)
    80001d34:	1000                	addi	s0,sp,32
    80001d36:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001d38:	fffff097          	auipc	ra,0xfffff
    80001d3c:	5ee080e7          	jalr	1518(ra) # 80001326 <uvmcreate>
    80001d40:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001d42:	c121                	beqz	a0,80001d82 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001d44:	4729                	li	a4,10
    80001d46:	00005697          	auipc	a3,0x5
    80001d4a:	2ba68693          	addi	a3,a3,698 # 80007000 <_trampoline>
    80001d4e:	6605                	lui	a2,0x1
    80001d50:	040005b7          	lui	a1,0x4000
    80001d54:	15fd                	addi	a1,a1,-1
    80001d56:	05b2                	slli	a1,a1,0xc
    80001d58:	fffff097          	auipc	ra,0xfffff
    80001d5c:	344080e7          	jalr	836(ra) # 8000109c <mappages>
    80001d60:	02054863          	bltz	a0,80001d90 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001d64:	4719                	li	a4,6
    80001d66:	06893683          	ld	a3,104(s2)
    80001d6a:	6605                	lui	a2,0x1
    80001d6c:	020005b7          	lui	a1,0x2000
    80001d70:	15fd                	addi	a1,a1,-1
    80001d72:	05b6                	slli	a1,a1,0xd
    80001d74:	8526                	mv	a0,s1
    80001d76:	fffff097          	auipc	ra,0xfffff
    80001d7a:	326080e7          	jalr	806(ra) # 8000109c <mappages>
    80001d7e:	02054163          	bltz	a0,80001da0 <proc_pagetable+0x76>
}
    80001d82:	8526                	mv	a0,s1
    80001d84:	60e2                	ld	ra,24(sp)
    80001d86:	6442                	ld	s0,16(sp)
    80001d88:	64a2                	ld	s1,8(sp)
    80001d8a:	6902                	ld	s2,0(sp)
    80001d8c:	6105                	addi	sp,sp,32
    80001d8e:	8082                	ret
    uvmfree(pagetable, 0);
    80001d90:	4581                	li	a1,0
    80001d92:	8526                	mv	a0,s1
    80001d94:	fffff097          	auipc	ra,0xfffff
    80001d98:	790080e7          	jalr	1936(ra) # 80001524 <uvmfree>
    return 0;
    80001d9c:	4481                	li	s1,0
    80001d9e:	b7d5                	j	80001d82 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001da0:	4681                	li	a3,0
    80001da2:	4605                	li	a2,1
    80001da4:	040005b7          	lui	a1,0x4000
    80001da8:	15fd                	addi	a1,a1,-1
    80001daa:	05b2                	slli	a1,a1,0xc
    80001dac:	8526                	mv	a0,s1
    80001dae:	fffff097          	auipc	ra,0xfffff
    80001db2:	4b4080e7          	jalr	1204(ra) # 80001262 <uvmunmap>
    uvmfree(pagetable, 0);
    80001db6:	4581                	li	a1,0
    80001db8:	8526                	mv	a0,s1
    80001dba:	fffff097          	auipc	ra,0xfffff
    80001dbe:	76a080e7          	jalr	1898(ra) # 80001524 <uvmfree>
    return 0;
    80001dc2:	4481                	li	s1,0
    80001dc4:	bf7d                	j	80001d82 <proc_pagetable+0x58>

0000000080001dc6 <proc_freepagetable>:
{
    80001dc6:	1101                	addi	sp,sp,-32
    80001dc8:	ec06                	sd	ra,24(sp)
    80001dca:	e822                	sd	s0,16(sp)
    80001dcc:	e426                	sd	s1,8(sp)
    80001dce:	e04a                	sd	s2,0(sp)
    80001dd0:	1000                	addi	s0,sp,32
    80001dd2:	84aa                	mv	s1,a0
    80001dd4:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001dd6:	4681                	li	a3,0
    80001dd8:	4605                	li	a2,1
    80001dda:	040005b7          	lui	a1,0x4000
    80001dde:	15fd                	addi	a1,a1,-1
    80001de0:	05b2                	slli	a1,a1,0xc
    80001de2:	fffff097          	auipc	ra,0xfffff
    80001de6:	480080e7          	jalr	1152(ra) # 80001262 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001dea:	4681                	li	a3,0
    80001dec:	4605                	li	a2,1
    80001dee:	020005b7          	lui	a1,0x2000
    80001df2:	15fd                	addi	a1,a1,-1
    80001df4:	05b6                	slli	a1,a1,0xd
    80001df6:	8526                	mv	a0,s1
    80001df8:	fffff097          	auipc	ra,0xfffff
    80001dfc:	46a080e7          	jalr	1130(ra) # 80001262 <uvmunmap>
  uvmfree(pagetable, sz);
    80001e00:	85ca                	mv	a1,s2
    80001e02:	8526                	mv	a0,s1
    80001e04:	fffff097          	auipc	ra,0xfffff
    80001e08:	720080e7          	jalr	1824(ra) # 80001524 <uvmfree>
}
    80001e0c:	60e2                	ld	ra,24(sp)
    80001e0e:	6442                	ld	s0,16(sp)
    80001e10:	64a2                	ld	s1,8(sp)
    80001e12:	6902                	ld	s2,0(sp)
    80001e14:	6105                	addi	sp,sp,32
    80001e16:	8082                	ret

0000000080001e18 <freeproc>:
{
    80001e18:	1101                	addi	sp,sp,-32
    80001e1a:	ec06                	sd	ra,24(sp)
    80001e1c:	e822                	sd	s0,16(sp)
    80001e1e:	e426                	sd	s1,8(sp)
    80001e20:	1000                	addi	s0,sp,32
    80001e22:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001e24:	7528                	ld	a0,104(a0)
    80001e26:	c509                	beqz	a0,80001e30 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001e28:	fffff097          	auipc	ra,0xfffff
    80001e2c:	bba080e7          	jalr	-1094(ra) # 800009e2 <kfree>
  p->trapframe = 0;
    80001e30:	0604b423          	sd	zero,104(s1)
  if(p->pagetable)
    80001e34:	70a8                	ld	a0,96(s1)
    80001e36:	c511                	beqz	a0,80001e42 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001e38:	6cac                	ld	a1,88(s1)
    80001e3a:	00000097          	auipc	ra,0x0
    80001e3e:	f8c080e7          	jalr	-116(ra) # 80001dc6 <proc_freepagetable>
  p->pagetable = 0;
    80001e42:	0604b023          	sd	zero,96(s1)
  p->sz = 0;
    80001e46:	0404bc23          	sd	zero,88(s1)
  p->pid = 0;
    80001e4a:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001e4e:	0404b423          	sd	zero,72(s1)
  p->name[0] = 0;
    80001e52:	16048423          	sb	zero,360(s1)
  p->chan = 0;
    80001e56:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001e5a:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001e5e:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001e62:	0004ac23          	sw	zero,24(s1)
}
    80001e66:	60e2                	ld	ra,24(sp)
    80001e68:	6442                	ld	s0,16(sp)
    80001e6a:	64a2                	ld	s1,8(sp)
    80001e6c:	6105                	addi	sp,sp,32
    80001e6e:	8082                	ret

0000000080001e70 <allocproc>:
{
    80001e70:	1101                	addi	sp,sp,-32
    80001e72:	ec06                	sd	ra,24(sp)
    80001e74:	e822                	sd	s0,16(sp)
    80001e76:	e426                	sd	s1,8(sp)
    80001e78:	e04a                	sd	s2,0(sp)
    80001e7a:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e7c:	00010497          	auipc	s1,0x10
    80001e80:	bdc48493          	addi	s1,s1,-1060 # 80011a58 <proc>
    80001e84:	00016917          	auipc	s2,0x16
    80001e88:	9d490913          	addi	s2,s2,-1580 # 80017858 <tickslock>
    acquire(&p->lock);
    80001e8c:	8526                	mv	a0,s1
    80001e8e:	fffff097          	auipc	ra,0xfffff
    80001e92:	d42080e7          	jalr	-702(ra) # 80000bd0 <acquire>
    if(p->state == UNUSED) {
    80001e96:	4c9c                	lw	a5,24(s1)
    80001e98:	cf81                	beqz	a5,80001eb0 <allocproc+0x40>
      release(&p->lock);
    80001e9a:	8526                	mv	a0,s1
    80001e9c:	fffff097          	auipc	ra,0xfffff
    80001ea0:	de8080e7          	jalr	-536(ra) # 80000c84 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ea4:	17848493          	addi	s1,s1,376
    80001ea8:	ff2492e3          	bne	s1,s2,80001e8c <allocproc+0x1c>
  return 0;
    80001eac:	4481                	li	s1,0
    80001eae:	a8b5                	j	80001f2a <allocproc+0xba>
  p->pid = allocpid();
    80001eb0:	00000097          	auipc	ra,0x0
    80001eb4:	e34080e7          	jalr	-460(ra) # 80001ce4 <allocpid>
    80001eb8:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001eba:	4785                	li	a5,1
    80001ebc:	cc9c                	sw	a5,24(s1)
  acquire(&tickslock);
    80001ebe:	00016517          	auipc	a0,0x16
    80001ec2:	99a50513          	addi	a0,a0,-1638 # 80017858 <tickslock>
    80001ec6:	fffff097          	auipc	ra,0xfffff
    80001eca:	d0a080e7          	jalr	-758(ra) # 80000bd0 <acquire>
  p->created = ticks;
    80001ece:	00007797          	auipc	a5,0x7
    80001ed2:	1727a783          	lw	a5,370(a5) # 80009040 <ticks>
    80001ed6:	d8dc                	sw	a5,52(s1)
  release(&tickslock);
    80001ed8:	00016517          	auipc	a0,0x16
    80001edc:	98050513          	addi	a0,a0,-1664 # 80017858 <tickslock>
    80001ee0:	fffff097          	auipc	ra,0xfffff
    80001ee4:	da4080e7          	jalr	-604(ra) # 80000c84 <release>
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001ee8:	fffff097          	auipc	ra,0xfffff
    80001eec:	bf8080e7          	jalr	-1032(ra) # 80000ae0 <kalloc>
    80001ef0:	892a                	mv	s2,a0
    80001ef2:	f4a8                	sd	a0,104(s1)
    80001ef4:	c131                	beqz	a0,80001f38 <allocproc+0xc8>
  p->pagetable = proc_pagetable(p);
    80001ef6:	8526                	mv	a0,s1
    80001ef8:	00000097          	auipc	ra,0x0
    80001efc:	e32080e7          	jalr	-462(ra) # 80001d2a <proc_pagetable>
    80001f00:	892a                	mv	s2,a0
    80001f02:	f0a8                	sd	a0,96(s1)
  if(p->pagetable == 0){
    80001f04:	c531                	beqz	a0,80001f50 <allocproc+0xe0>
  memset(&p->context, 0, sizeof(p->context));
    80001f06:	07000613          	li	a2,112
    80001f0a:	4581                	li	a1,0
    80001f0c:	07048513          	addi	a0,s1,112
    80001f10:	fffff097          	auipc	ra,0xfffff
    80001f14:	dbc080e7          	jalr	-580(ra) # 80000ccc <memset>
  p->context.ra = (uint64)forkret;
    80001f18:	00000797          	auipc	a5,0x0
    80001f1c:	d8678793          	addi	a5,a5,-634 # 80001c9e <forkret>
    80001f20:	f8bc                	sd	a5,112(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001f22:	68bc                	ld	a5,80(s1)
    80001f24:	6705                	lui	a4,0x1
    80001f26:	97ba                	add	a5,a5,a4
    80001f28:	fcbc                	sd	a5,120(s1)
}
    80001f2a:	8526                	mv	a0,s1
    80001f2c:	60e2                	ld	ra,24(sp)
    80001f2e:	6442                	ld	s0,16(sp)
    80001f30:	64a2                	ld	s1,8(sp)
    80001f32:	6902                	ld	s2,0(sp)
    80001f34:	6105                	addi	sp,sp,32
    80001f36:	8082                	ret
    freeproc(p);
    80001f38:	8526                	mv	a0,s1
    80001f3a:	00000097          	auipc	ra,0x0
    80001f3e:	ede080e7          	jalr	-290(ra) # 80001e18 <freeproc>
    release(&p->lock);
    80001f42:	8526                	mv	a0,s1
    80001f44:	fffff097          	auipc	ra,0xfffff
    80001f48:	d40080e7          	jalr	-704(ra) # 80000c84 <release>
    return 0;
    80001f4c:	84ca                	mv	s1,s2
    80001f4e:	bff1                	j	80001f2a <allocproc+0xba>
    freeproc(p);
    80001f50:	8526                	mv	a0,s1
    80001f52:	00000097          	auipc	ra,0x0
    80001f56:	ec6080e7          	jalr	-314(ra) # 80001e18 <freeproc>
    release(&p->lock);
    80001f5a:	8526                	mv	a0,s1
    80001f5c:	fffff097          	auipc	ra,0xfffff
    80001f60:	d28080e7          	jalr	-728(ra) # 80000c84 <release>
    return 0;
    80001f64:	84ca                	mv	s1,s2
    80001f66:	b7d1                	j	80001f2a <allocproc+0xba>

0000000080001f68 <userinit>:
{
    80001f68:	1101                	addi	sp,sp,-32
    80001f6a:	ec06                	sd	ra,24(sp)
    80001f6c:	e822                	sd	s0,16(sp)
    80001f6e:	e426                	sd	s1,8(sp)
    80001f70:	1000                	addi	s0,sp,32
  p = allocproc();
    80001f72:	00000097          	auipc	ra,0x0
    80001f76:	efe080e7          	jalr	-258(ra) # 80001e70 <allocproc>
    80001f7a:	84aa                	mv	s1,a0
  initproc = p;
    80001f7c:	00007797          	auipc	a5,0x7
    80001f80:	0aa7be23          	sd	a0,188(a5) # 80009038 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001f84:	03400613          	li	a2,52
    80001f88:	00007597          	auipc	a1,0x7
    80001f8c:	9c858593          	addi	a1,a1,-1592 # 80008950 <initcode>
    80001f90:	7128                	ld	a0,96(a0)
    80001f92:	fffff097          	auipc	ra,0xfffff
    80001f96:	3c2080e7          	jalr	962(ra) # 80001354 <uvminit>
  p->sz = PGSIZE;
    80001f9a:	6785                	lui	a5,0x1
    80001f9c:	ecbc                	sd	a5,88(s1)
  p->trapframe->epc = 0;      // user program counter
    80001f9e:	74b8                	ld	a4,104(s1)
    80001fa0:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001fa4:	74b8                	ld	a4,104(s1)
    80001fa6:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001fa8:	4641                	li	a2,16
    80001faa:	00006597          	auipc	a1,0x6
    80001fae:	2f658593          	addi	a1,a1,758 # 800082a0 <digits+0x260>
    80001fb2:	16848513          	addi	a0,s1,360
    80001fb6:	fffff097          	auipc	ra,0xfffff
    80001fba:	e60080e7          	jalr	-416(ra) # 80000e16 <safestrcpy>
  p->cwd = namei("/");
    80001fbe:	00006517          	auipc	a0,0x6
    80001fc2:	2f250513          	addi	a0,a0,754 # 800082b0 <digits+0x270>
    80001fc6:	00002097          	auipc	ra,0x2
    80001fca:	7be080e7          	jalr	1982(ra) # 80004784 <namei>
    80001fce:	16a4b023          	sd	a0,352(s1)
  p->state = RUNNABLE;
    80001fd2:	478d                	li	a5,3
    80001fd4:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001fd6:	8526                	mv	a0,s1
    80001fd8:	fffff097          	auipc	ra,0xfffff
    80001fdc:	cac080e7          	jalr	-852(ra) # 80000c84 <release>
}
    80001fe0:	60e2                	ld	ra,24(sp)
    80001fe2:	6442                	ld	s0,16(sp)
    80001fe4:	64a2                	ld	s1,8(sp)
    80001fe6:	6105                	addi	sp,sp,32
    80001fe8:	8082                	ret

0000000080001fea <growproc>:
{
    80001fea:	1101                	addi	sp,sp,-32
    80001fec:	ec06                	sd	ra,24(sp)
    80001fee:	e822                	sd	s0,16(sp)
    80001ff0:	e426                	sd	s1,8(sp)
    80001ff2:	e04a                	sd	s2,0(sp)
    80001ff4:	1000                	addi	s0,sp,32
    80001ff6:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001ff8:	00000097          	auipc	ra,0x0
    80001ffc:	a26080e7          	jalr	-1498(ra) # 80001a1e <myproc>
    80002000:	892a                	mv	s2,a0
  sz = p->sz;
    80002002:	6d2c                	ld	a1,88(a0)
    80002004:	0005879b          	sext.w	a5,a1
  if(n > 0){
    80002008:	00904f63          	bgtz	s1,80002026 <growproc+0x3c>
  } else if(n < 0){
    8000200c:	0204cd63          	bltz	s1,80002046 <growproc+0x5c>
  p->sz = sz;
    80002010:	1782                	slli	a5,a5,0x20
    80002012:	9381                	srli	a5,a5,0x20
    80002014:	04f93c23          	sd	a5,88(s2)
  return 0;
    80002018:	4501                	li	a0,0
}
    8000201a:	60e2                	ld	ra,24(sp)
    8000201c:	6442                	ld	s0,16(sp)
    8000201e:	64a2                	ld	s1,8(sp)
    80002020:	6902                	ld	s2,0(sp)
    80002022:	6105                	addi	sp,sp,32
    80002024:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80002026:	00f4863b          	addw	a2,s1,a5
    8000202a:	1602                	slli	a2,a2,0x20
    8000202c:	9201                	srli	a2,a2,0x20
    8000202e:	1582                	slli	a1,a1,0x20
    80002030:	9181                	srli	a1,a1,0x20
    80002032:	7128                	ld	a0,96(a0)
    80002034:	fffff097          	auipc	ra,0xfffff
    80002038:	3da080e7          	jalr	986(ra) # 8000140e <uvmalloc>
    8000203c:	0005079b          	sext.w	a5,a0
    80002040:	fbe1                	bnez	a5,80002010 <growproc+0x26>
      return -1;
    80002042:	557d                	li	a0,-1
    80002044:	bfd9                	j	8000201a <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80002046:	00f4863b          	addw	a2,s1,a5
    8000204a:	1602                	slli	a2,a2,0x20
    8000204c:	9201                	srli	a2,a2,0x20
    8000204e:	1582                	slli	a1,a1,0x20
    80002050:	9181                	srli	a1,a1,0x20
    80002052:	7128                	ld	a0,96(a0)
    80002054:	fffff097          	auipc	ra,0xfffff
    80002058:	372080e7          	jalr	882(ra) # 800013c6 <uvmdealloc>
    8000205c:	0005079b          	sext.w	a5,a0
    80002060:	bf45                	j	80002010 <growproc+0x26>

0000000080002062 <fork>:
{
    80002062:	7139                	addi	sp,sp,-64
    80002064:	fc06                	sd	ra,56(sp)
    80002066:	f822                	sd	s0,48(sp)
    80002068:	f426                	sd	s1,40(sp)
    8000206a:	f04a                	sd	s2,32(sp)
    8000206c:	ec4e                	sd	s3,24(sp)
    8000206e:	e852                	sd	s4,16(sp)
    80002070:	e456                	sd	s5,8(sp)
    80002072:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80002074:	00000097          	auipc	ra,0x0
    80002078:	9aa080e7          	jalr	-1622(ra) # 80001a1e <myproc>
    8000207c:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    8000207e:	00000097          	auipc	ra,0x0
    80002082:	df2080e7          	jalr	-526(ra) # 80001e70 <allocproc>
    80002086:	10050c63          	beqz	a0,8000219e <fork+0x13c>
    8000208a:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    8000208c:	058ab603          	ld	a2,88(s5)
    80002090:	712c                	ld	a1,96(a0)
    80002092:	060ab503          	ld	a0,96(s5)
    80002096:	fffff097          	auipc	ra,0xfffff
    8000209a:	4c8080e7          	jalr	1224(ra) # 8000155e <uvmcopy>
    8000209e:	04054863          	bltz	a0,800020ee <fork+0x8c>
  np->sz = p->sz;
    800020a2:	058ab783          	ld	a5,88(s5)
    800020a6:	04fa3c23          	sd	a5,88(s4)
  *(np->trapframe) = *(p->trapframe);
    800020aa:	068ab683          	ld	a3,104(s5)
    800020ae:	87b6                	mv	a5,a3
    800020b0:	068a3703          	ld	a4,104(s4)
    800020b4:	12068693          	addi	a3,a3,288
    800020b8:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    800020bc:	6788                	ld	a0,8(a5)
    800020be:	6b8c                	ld	a1,16(a5)
    800020c0:	6f90                	ld	a2,24(a5)
    800020c2:	01073023          	sd	a6,0(a4)
    800020c6:	e708                	sd	a0,8(a4)
    800020c8:	eb0c                	sd	a1,16(a4)
    800020ca:	ef10                	sd	a2,24(a4)
    800020cc:	02078793          	addi	a5,a5,32
    800020d0:	02070713          	addi	a4,a4,32
    800020d4:	fed792e3          	bne	a5,a3,800020b8 <fork+0x56>
  np->trapframe->a0 = 0;
    800020d8:	068a3783          	ld	a5,104(s4)
    800020dc:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    800020e0:	0e0a8493          	addi	s1,s5,224
    800020e4:	0e0a0913          	addi	s2,s4,224
    800020e8:	160a8993          	addi	s3,s5,352
    800020ec:	a00d                	j	8000210e <fork+0xac>
    freeproc(np);
    800020ee:	8552                	mv	a0,s4
    800020f0:	00000097          	auipc	ra,0x0
    800020f4:	d28080e7          	jalr	-728(ra) # 80001e18 <freeproc>
    release(&np->lock);
    800020f8:	8552                	mv	a0,s4
    800020fa:	fffff097          	auipc	ra,0xfffff
    800020fe:	b8a080e7          	jalr	-1142(ra) # 80000c84 <release>
    return -1;
    80002102:	597d                	li	s2,-1
    80002104:	a059                	j	8000218a <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80002106:	04a1                	addi	s1,s1,8
    80002108:	0921                	addi	s2,s2,8
    8000210a:	01348b63          	beq	s1,s3,80002120 <fork+0xbe>
    if(p->ofile[i])
    8000210e:	6088                	ld	a0,0(s1)
    80002110:	d97d                	beqz	a0,80002106 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80002112:	00003097          	auipc	ra,0x3
    80002116:	d08080e7          	jalr	-760(ra) # 80004e1a <filedup>
    8000211a:	00a93023          	sd	a0,0(s2)
    8000211e:	b7e5                	j	80002106 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80002120:	160ab503          	ld	a0,352(s5)
    80002124:	00002097          	auipc	ra,0x2
    80002128:	e66080e7          	jalr	-410(ra) # 80003f8a <idup>
    8000212c:	16aa3023          	sd	a0,352(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002130:	4641                	li	a2,16
    80002132:	168a8593          	addi	a1,s5,360
    80002136:	168a0513          	addi	a0,s4,360
    8000213a:	fffff097          	auipc	ra,0xfffff
    8000213e:	cdc080e7          	jalr	-804(ra) # 80000e16 <safestrcpy>
  pid = np->pid;
    80002142:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80002146:	8552                	mv	a0,s4
    80002148:	fffff097          	auipc	ra,0xfffff
    8000214c:	b3c080e7          	jalr	-1220(ra) # 80000c84 <release>
  acquire(&wait_lock); 
    80002150:	0000f497          	auipc	s1,0xf
    80002154:	49848493          	addi	s1,s1,1176 # 800115e8 <wait_lock>
    80002158:	8526                	mv	a0,s1
    8000215a:	fffff097          	auipc	ra,0xfffff
    8000215e:	a76080e7          	jalr	-1418(ra) # 80000bd0 <acquire>
  np->parent = p;
    80002162:	055a3423          	sd	s5,72(s4)
  release(&wait_lock);
    80002166:	8526                	mv	a0,s1
    80002168:	fffff097          	auipc	ra,0xfffff
    8000216c:	b1c080e7          	jalr	-1252(ra) # 80000c84 <release>
  acquire(&np->lock);
    80002170:	8552                	mv	a0,s4
    80002172:	fffff097          	auipc	ra,0xfffff
    80002176:	a5e080e7          	jalr	-1442(ra) # 80000bd0 <acquire>
  np->state = RUNNABLE;
    8000217a:	478d                	li	a5,3
    8000217c:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80002180:	8552                	mv	a0,s4
    80002182:	fffff097          	auipc	ra,0xfffff
    80002186:	b02080e7          	jalr	-1278(ra) # 80000c84 <release>
}
    8000218a:	854a                	mv	a0,s2
    8000218c:	70e2                	ld	ra,56(sp)
    8000218e:	7442                	ld	s0,48(sp)
    80002190:	74a2                	ld	s1,40(sp)
    80002192:	7902                	ld	s2,32(sp)
    80002194:	69e2                	ld	s3,24(sp)
    80002196:	6a42                	ld	s4,16(sp)
    80002198:	6aa2                	ld	s5,8(sp)
    8000219a:	6121                	addi	sp,sp,64
    8000219c:	8082                	ret
    return -1;
    8000219e:	597d                	li	s2,-1
    800021a0:	b7ed                	j	8000218a <fork+0x128>

00000000800021a2 <scheduler>:
{
    800021a2:	7119                	addi	sp,sp,-128
    800021a4:	fc86                	sd	ra,120(sp)
    800021a6:	f8a2                	sd	s0,112(sp)
    800021a8:	f4a6                	sd	s1,104(sp)
    800021aa:	f0ca                	sd	s2,96(sp)
    800021ac:	ecce                	sd	s3,88(sp)
    800021ae:	e8d2                	sd	s4,80(sp)
    800021b0:	e4d6                	sd	s5,72(sp)
    800021b2:	e0da                	sd	s6,64(sp)
    800021b4:	fc5e                	sd	s7,56(sp)
    800021b6:	f862                	sd	s8,48(sp)
    800021b8:	f466                	sd	s9,40(sp)
    800021ba:	f06a                	sd	s10,32(sp)
    800021bc:	ec6e                	sd	s11,24(sp)
    800021be:	0100                	addi	s0,sp,128
    800021c0:	8792                	mv	a5,tp
  int id = r_tp();
    800021c2:	2781                	sext.w	a5,a5
  c->proc = 0;
    800021c4:	00779c13          	slli	s8,a5,0x7
    800021c8:	0000f717          	auipc	a4,0xf
    800021cc:	0e870713          	addi	a4,a4,232 # 800112b0 <free_list>
    800021d0:	9762                	add	a4,a4,s8
    800021d2:	38073023          	sd	zero,896(a4)
        swtch(&c->context, &p->context);
    800021d6:	0000f717          	auipc	a4,0xf
    800021da:	46270713          	addi	a4,a4,1122 # 80011638 <cpus+0x8>
    800021de:	9c3a                	add	s8,s8,a4
  int scheduling_decisionL=0;
    800021e0:	4c81                	li	s9,0
  int scheduling_decisionM=0;
    800021e2:	4d01                	li	s10,0
        c->proc = p;
    800021e4:	079e                	slli	a5,a5,0x7
    800021e6:	0000fa17          	auipc	s4,0xf
    800021ea:	0caa0a13          	addi	s4,s4,202 # 800112b0 <free_list>
    800021ee:	9a3e                	add	s4,s4,a5
        p->priority = 1 ; // set the prioroty to medium
    800021f0:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) { // HIGH PRIORITY
    800021f2:	00015917          	auipc	s2,0x15
    800021f6:	66690913          	addi	s2,s2,1638 # 80017858 <tickslock>
    800021fa:	a085                	j	8000225a <scheduler+0xb8>
      release(&p->lock);
    800021fc:	8526                	mv	a0,s1
    800021fe:	fffff097          	auipc	ra,0xfffff
    80002202:	a86080e7          	jalr	-1402(ra) # 80000c84 <release>
    for(p = proc; p < &proc[NPROC]; p++) { // HIGH PRIORITY
    80002206:	17848493          	addi	s1,s1,376
    8000220a:	05248263          	beq	s1,s2,8000224e <scheduler+0xac>
      acquire(&p->lock);
    8000220e:	8526                	mv	a0,s1
    80002210:	fffff097          	auipc	ra,0xfffff
    80002214:	9c0080e7          	jalr	-1600(ra) # 80000bd0 <acquire>
      if(p->state == RUNNABLE && p->priority==2) { 
    80002218:	4c9c                	lw	a5,24(s1)
    8000221a:	ff5791e3          	bne	a5,s5,800021fc <scheduler+0x5a>
    8000221e:	40bc                	lw	a5,64(s1)
    80002220:	fd679ee3          	bne	a5,s6,800021fc <scheduler+0x5a>
        p->state = RUNNING;
    80002224:	01b4ac23          	sw	s11,24(s1)
        c->proc = p;
    80002228:	389a3023          	sd	s1,896(s4)
        p->priority = 1 ; // set the prioroty to medium
    8000222c:	0574a023          	sw	s7,64(s1)
        swtch(&c->context, &p->context);
    80002230:	07048593          	addi	a1,s1,112
    80002234:	8562                	mv	a0,s8
    80002236:	00001097          	auipc	ra,0x1
    8000223a:	b9a080e7          	jalr	-1126(ra) # 80002dd0 <swtch>
        p->running++;
    8000223e:	5cdc                	lw	a5,60(s1)
    80002240:	2785                	addiw	a5,a5,1
    80002242:	dcdc                	sw	a5,60(s1)
        c->proc = 0;
    80002244:	380a3023          	sd	zero,896(s4)
        foundhigh = 1;
    80002248:	f9743423          	sd	s7,-120(s0)
    8000224c:	bf45                	j	800021fc <scheduler+0x5a>
    if (foundhigh != 1){
    8000224e:	f8843783          	ld	a5,-120(s0)
    80002252:	03779463          	bne	a5,s7,8000227a <scheduler+0xd8>
      scheduling_decisionM++;  
    80002256:	2d05                	addiw	s10,s10,1
      scheduling_decisionL++;  
    80002258:	2c85                	addiw	s9,s9,1
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000225a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000225e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002262:	10079073          	csrw	sstatus,a5
    int foundhigh = 0;
    80002266:	f8043423          	sd	zero,-120(s0)
    for(p = proc; p < &proc[NPROC]; p++) { // HIGH PRIORITY
    8000226a:	0000f497          	auipc	s1,0xf
    8000226e:	7ee48493          	addi	s1,s1,2030 # 80011a58 <proc>
      if(p->state == RUNNABLE && p->priority==2) { 
    80002272:	4a8d                	li	s5,3
    80002274:	4b09                	li	s6,2
        p->state = RUNNING;
    80002276:	4d91                	li	s11,4
    80002278:	bf59                	j	8000220e <scheduler+0x6c>
    int foundmedium = 0;
    8000227a:	f8f43023          	sd	a5,-128(s0)
      for(p = proc; p < &proc[NPROC]; p++) { // MEDIUM PRIORITY
    8000227e:	0000f497          	auipc	s1,0xf
    80002282:	7da48493          	addi	s1,s1,2010 # 80011a58 <proc>
        if(p->state == RUNNABLE && p->priority==1) {
    80002286:	4a8d                	li	s5,3
          if(scheduling_decisionM == moveup){ // set priority high if mtimes scheduling decisions have been made
    80002288:	4d95                	li	s11,5
    8000228a:	a83d                	j	800022c8 <scheduler+0x126>
            p->priority = 2; 
    8000228c:	4789                	li	a5,2
    8000228e:	c0bc                	sw	a5,64(s1)
            scheduling_decisionM=0;
    80002290:	f8843d03          	ld	s10,-120(s0)
    80002294:	a889                	j	800022e6 <scheduler+0x144>
          p->timesRun++;
    80002296:	2785                	addiw	a5,a5,1
    80002298:	c0fc                	sw	a5,68(s1)
          swtch(&c->context, &p->context);
    8000229a:	07098593          	addi	a1,s3,112
    8000229e:	8562                	mv	a0,s8
    800022a0:	00001097          	auipc	ra,0x1
    800022a4:	b30080e7          	jalr	-1232(ra) # 80002dd0 <swtch>
          p->running++;
    800022a8:	5cdc                	lw	a5,60(s1)
    800022aa:	2785                	addiw	a5,a5,1
    800022ac:	dcdc                	sw	a5,60(s1)
          c->proc = 0;
    800022ae:	380a3023          	sd	zero,896(s4)
          foundmedium = 1;
    800022b2:	f9643023          	sd	s6,-128(s0)
        release(&p->lock);
    800022b6:	8526                	mv	a0,s1
    800022b8:	fffff097          	auipc	ra,0xfffff
    800022bc:	9cc080e7          	jalr	-1588(ra) # 80000c84 <release>
      for(p = proc; p < &proc[NPROC]; p++) { // MEDIUM PRIORITY
    800022c0:	17848493          	addi	s1,s1,376
    800022c4:	03248c63          	beq	s1,s2,800022fc <scheduler+0x15a>
        acquire(&p->lock);
    800022c8:	89a6                	mv	s3,s1
    800022ca:	8526                	mv	a0,s1
    800022cc:	fffff097          	auipc	ra,0xfffff
    800022d0:	904080e7          	jalr	-1788(ra) # 80000bd0 <acquire>
        if(p->state == RUNNABLE && p->priority==1) {
    800022d4:	4c9c                	lw	a5,24(s1)
    800022d6:	ff5790e3          	bne	a5,s5,800022b6 <scheduler+0x114>
    800022da:	0404ab03          	lw	s6,64(s1)
    800022de:	fd7b1ce3          	bne	s6,s7,800022b6 <scheduler+0x114>
          if(scheduling_decisionM == moveup){ // set priority high if mtimes scheduling decisions have been made
    800022e2:	fbbd05e3          	beq	s10,s11,8000228c <scheduler+0xea>
          p->state = RUNNING;
    800022e6:	4791                	li	a5,4
    800022e8:	cc9c                	sw	a5,24(s1)
          c->proc = p;
    800022ea:	389a3023          	sd	s1,896(s4)
          if(p->timesRun == mtimes){
    800022ee:	40fc                	lw	a5,68(s1)
    800022f0:	4729                	li	a4,10
    800022f2:	fae792e3          	bne	a5,a4,80002296 <scheduler+0xf4>
            p->priority = 0 ; // set the priority to low
    800022f6:	0404a023          	sw	zero,64(s1)
    800022fa:	bf71                	j	80002296 <scheduler+0xf4>
    if(foundmedium!=1 && foundhigh !=1){ 
    800022fc:	f8043783          	ld	a5,-128(s0)
    80002300:	f5778be3          	beq	a5,s7,80002256 <scheduler+0xb4>
      for(p = proc; p < &proc[NPROC]; p++) { // LOW PRIORITY
    80002304:	0000f497          	auipc	s1,0xf
    80002308:	75448493          	addi	s1,s1,1876 # 80011a58 <proc>
          if(p->state == RUNNABLE && p->priority==0) {
    8000230c:	4a8d                	li	s5,3
           if(scheduling_decisionL == moveup){ // set priority high if mtimes scheduling decisions have been made
    8000230e:	4d95                	li	s11,5
            p->state = RUNNING;
    80002310:	4b11                	li	s6,4
    80002312:	a825                	j	8000234a <scheduler+0x1a8>
    80002314:	0164ac23          	sw	s6,24(s1)
            c->proc = p;
    80002318:	389a3023          	sd	s1,896(s4)
            p->timesRun = 0; /// change the m times counter to 0
    8000231c:	0404a223          	sw	zero,68(s1)
            swtch(&c->context, &p->context);
    80002320:	07098593          	addi	a1,s3,112
    80002324:	8562                	mv	a0,s8
    80002326:	00001097          	auipc	ra,0x1
    8000232a:	aaa080e7          	jalr	-1366(ra) # 80002dd0 <swtch>
            p-> running++;
    8000232e:	5cdc                	lw	a5,60(s1)
    80002330:	2785                	addiw	a5,a5,1
    80002332:	dcdc                	sw	a5,60(s1)
            c->proc = 0;
    80002334:	380a3023          	sd	zero,896(s4)
          release(&p->lock);
    80002338:	8526                	mv	a0,s1
    8000233a:	fffff097          	auipc	ra,0xfffff
    8000233e:	94a080e7          	jalr	-1718(ra) # 80000c84 <release>
      for(p = proc; p < &proc[NPROC]; p++) { // LOW PRIORITY
    80002342:	17848493          	addi	s1,s1,376
    80002346:	f12488e3          	beq	s1,s2,80002256 <scheduler+0xb4>
          acquire(&p->lock);
    8000234a:	89a6                	mv	s3,s1
    8000234c:	8526                	mv	a0,s1
    8000234e:	fffff097          	auipc	ra,0xfffff
    80002352:	882080e7          	jalr	-1918(ra) # 80000bd0 <acquire>
          if(p->state == RUNNABLE && p->priority==0) {
    80002356:	4c9c                	lw	a5,24(s1)
    80002358:	ff5790e3          	bne	a5,s5,80002338 <scheduler+0x196>
    8000235c:	40bc                	lw	a5,64(s1)
    8000235e:	ffe9                	bnez	a5,80002338 <scheduler+0x196>
           if(scheduling_decisionL == moveup){ // set priority high if mtimes scheduling decisions have been made
    80002360:	fbbc9ae3          	bne	s9,s11,80002314 <scheduler+0x172>
            p->priority = 2; 
    80002364:	4709                	li	a4,2
    80002366:	c0b8                	sw	a4,64(s1)
            scheduling_decisionL= 0;
    80002368:	8cbe                	mv	s9,a5
    8000236a:	b76d                	j	80002314 <scheduler+0x172>

000000008000236c <sched>:
{
    8000236c:	7179                	addi	sp,sp,-48
    8000236e:	f406                	sd	ra,40(sp)
    80002370:	f022                	sd	s0,32(sp)
    80002372:	ec26                	sd	s1,24(sp)
    80002374:	e84a                	sd	s2,16(sp)
    80002376:	e44e                	sd	s3,8(sp)
    80002378:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000237a:	fffff097          	auipc	ra,0xfffff
    8000237e:	6a4080e7          	jalr	1700(ra) # 80001a1e <myproc>
    80002382:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002384:	ffffe097          	auipc	ra,0xffffe
    80002388:	7d2080e7          	jalr	2002(ra) # 80000b56 <holding>
    8000238c:	c93d                	beqz	a0,80002402 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000238e:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002390:	2781                	sext.w	a5,a5
    80002392:	079e                	slli	a5,a5,0x7
    80002394:	0000f717          	auipc	a4,0xf
    80002398:	f1c70713          	addi	a4,a4,-228 # 800112b0 <free_list>
    8000239c:	97ba                	add	a5,a5,a4
    8000239e:	3f87a703          	lw	a4,1016(a5)
    800023a2:	4785                	li	a5,1
    800023a4:	06f71763          	bne	a4,a5,80002412 <sched+0xa6>
  if(p->state == RUNNING)
    800023a8:	4c98                	lw	a4,24(s1)
    800023aa:	4791                	li	a5,4
    800023ac:	06f70b63          	beq	a4,a5,80002422 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800023b0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800023b4:	8b89                	andi	a5,a5,2
  if(intr_get())
    800023b6:	efb5                	bnez	a5,80002432 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800023b8:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800023ba:	0000f917          	auipc	s2,0xf
    800023be:	ef690913          	addi	s2,s2,-266 # 800112b0 <free_list>
    800023c2:	2781                	sext.w	a5,a5
    800023c4:	079e                	slli	a5,a5,0x7
    800023c6:	97ca                	add	a5,a5,s2
    800023c8:	3fc7a983          	lw	s3,1020(a5)
    800023cc:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800023ce:	2781                	sext.w	a5,a5
    800023d0:	079e                	slli	a5,a5,0x7
    800023d2:	0000f597          	auipc	a1,0xf
    800023d6:	26658593          	addi	a1,a1,614 # 80011638 <cpus+0x8>
    800023da:	95be                	add	a1,a1,a5
    800023dc:	07048513          	addi	a0,s1,112
    800023e0:	00001097          	auipc	ra,0x1
    800023e4:	9f0080e7          	jalr	-1552(ra) # 80002dd0 <swtch>
    800023e8:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800023ea:	2781                	sext.w	a5,a5
    800023ec:	079e                	slli	a5,a5,0x7
    800023ee:	993e                	add	s2,s2,a5
    800023f0:	3f392e23          	sw	s3,1020(s2)
}
    800023f4:	70a2                	ld	ra,40(sp)
    800023f6:	7402                	ld	s0,32(sp)
    800023f8:	64e2                	ld	s1,24(sp)
    800023fa:	6942                	ld	s2,16(sp)
    800023fc:	69a2                	ld	s3,8(sp)
    800023fe:	6145                	addi	sp,sp,48
    80002400:	8082                	ret
    panic("sched p->lock");
    80002402:	00006517          	auipc	a0,0x6
    80002406:	eb650513          	addi	a0,a0,-330 # 800082b8 <digits+0x278>
    8000240a:	ffffe097          	auipc	ra,0xffffe
    8000240e:	130080e7          	jalr	304(ra) # 8000053a <panic>
    panic("sched locks");
    80002412:	00006517          	auipc	a0,0x6
    80002416:	eb650513          	addi	a0,a0,-330 # 800082c8 <digits+0x288>
    8000241a:	ffffe097          	auipc	ra,0xffffe
    8000241e:	120080e7          	jalr	288(ra) # 8000053a <panic>
    panic("sched running");
    80002422:	00006517          	auipc	a0,0x6
    80002426:	eb650513          	addi	a0,a0,-330 # 800082d8 <digits+0x298>
    8000242a:	ffffe097          	auipc	ra,0xffffe
    8000242e:	110080e7          	jalr	272(ra) # 8000053a <panic>
    panic("sched interruptible");
    80002432:	00006517          	auipc	a0,0x6
    80002436:	eb650513          	addi	a0,a0,-330 # 800082e8 <digits+0x2a8>
    8000243a:	ffffe097          	auipc	ra,0xffffe
    8000243e:	100080e7          	jalr	256(ra) # 8000053a <panic>

0000000080002442 <yield>:
{
    80002442:	1101                	addi	sp,sp,-32
    80002444:	ec06                	sd	ra,24(sp)
    80002446:	e822                	sd	s0,16(sp)
    80002448:	e426                	sd	s1,8(sp)
    8000244a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000244c:	fffff097          	auipc	ra,0xfffff
    80002450:	5d2080e7          	jalr	1490(ra) # 80001a1e <myproc>
    80002454:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002456:	ffffe097          	auipc	ra,0xffffe
    8000245a:	77a080e7          	jalr	1914(ra) # 80000bd0 <acquire>
  p->state = RUNNABLE;
    8000245e:	478d                	li	a5,3
    80002460:	cc9c                	sw	a5,24(s1)
  sched();
    80002462:	00000097          	auipc	ra,0x0
    80002466:	f0a080e7          	jalr	-246(ra) # 8000236c <sched>
  release(&p->lock);
    8000246a:	8526                	mv	a0,s1
    8000246c:	fffff097          	auipc	ra,0xfffff
    80002470:	818080e7          	jalr	-2024(ra) # 80000c84 <release>
}
    80002474:	60e2                	ld	ra,24(sp)
    80002476:	6442                	ld	s0,16(sp)
    80002478:	64a2                	ld	s1,8(sp)
    8000247a:	6105                	addi	sp,sp,32
    8000247c:	8082                	ret

000000008000247e <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000247e:	7179                	addi	sp,sp,-48
    80002480:	f406                	sd	ra,40(sp)
    80002482:	f022                	sd	s0,32(sp)
    80002484:	ec26                	sd	s1,24(sp)
    80002486:	e84a                	sd	s2,16(sp)
    80002488:	e44e                	sd	s3,8(sp)
    8000248a:	1800                	addi	s0,sp,48
    8000248c:	89aa                	mv	s3,a0
    8000248e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002490:	fffff097          	auipc	ra,0xfffff
    80002494:	58e080e7          	jalr	1422(ra) # 80001a1e <myproc>
    80002498:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000249a:	ffffe097          	auipc	ra,0xffffe
    8000249e:	736080e7          	jalr	1846(ra) # 80000bd0 <acquire>
  release(lk);
    800024a2:	854a                	mv	a0,s2
    800024a4:	ffffe097          	auipc	ra,0xffffe
    800024a8:	7e0080e7          	jalr	2016(ra) # 80000c84 <release>

  // Go to sleep.
  p->chan = chan;
    800024ac:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800024b0:	4789                	li	a5,2
    800024b2:	cc9c                	sw	a5,24(s1)

  sched();
    800024b4:	00000097          	auipc	ra,0x0
    800024b8:	eb8080e7          	jalr	-328(ra) # 8000236c <sched>

  // Tidy up.
  p->chan = 0;
    800024bc:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800024c0:	8526                	mv	a0,s1
    800024c2:	ffffe097          	auipc	ra,0xffffe
    800024c6:	7c2080e7          	jalr	1986(ra) # 80000c84 <release>
  acquire(lk);
    800024ca:	854a                	mv	a0,s2
    800024cc:	ffffe097          	auipc	ra,0xffffe
    800024d0:	704080e7          	jalr	1796(ra) # 80000bd0 <acquire>
}
    800024d4:	70a2                	ld	ra,40(sp)
    800024d6:	7402                	ld	s0,32(sp)
    800024d8:	64e2                	ld	s1,24(sp)
    800024da:	6942                	ld	s2,16(sp)
    800024dc:	69a2                	ld	s3,8(sp)
    800024de:	6145                	addi	sp,sp,48
    800024e0:	8082                	ret

00000000800024e2 <btput>:
int btput(topic_t tag, uint64 message){
    800024e2:	7139                	addi	sp,sp,-64
    800024e4:	fc06                	sd	ra,56(sp)
    800024e6:	f822                	sd	s0,48(sp)
    800024e8:	f426                	sd	s1,40(sp)
    800024ea:	f04a                	sd	s2,32(sp)
    800024ec:	ec4e                	sd	s3,24(sp)
    800024ee:	e852                	sd	s4,16(sp)
    800024f0:	e456                	sd	s5,8(sp)
    800024f2:	e05a                	sd	s6,0(sp)
    800024f4:	0080                	addi	s0,sp,64
    800024f6:	892a                	mv	s2,a0
    800024f8:	8a2e                	mv	s4,a1
  for (int all =0 ; all<maxtweettotal ; all++){
    800024fa:	0000f797          	auipc	a5,0xf
    800024fe:	e4e78793          	addi	a5,a5,-434 # 80011348 <free_list+0x98>
    80002502:	0000f497          	auipc	s1,0xf
    80002506:	dae48493          	addi	s1,s1,-594 # 800112b0 <free_list>
    8000250a:	0000f697          	auipc	a3,0xf
    8000250e:	15e68693          	addi	a3,a3,350 # 80011668 <cpus+0x38>
    if(free_list[all].tag==0){
    80002512:	4398                	lw	a4,0(a5)
    80002514:	1a070663          	beqz	a4,800026c0 <btput+0x1de>
  for (int all =0 ; all<maxtweettotal ; all++){
    80002518:	0a078793          	addi	a5,a5,160
    8000251c:	fed79be3          	bne	a5,a3,80002512 <btput+0x30>
  acquire(&free_lock);
    80002520:	0000f517          	auipc	a0,0xf
    80002524:	0f850513          	addi	a0,a0,248 # 80011618 <free_lock>
    80002528:	ffffe097          	auipc	ra,0xffffe
    8000252c:	6a8080e7          	jalr	1704(ra) # 80000bd0 <acquire>
    printf("sleeping... Till I find a wake up call\n");
    80002530:	00006517          	auipc	a0,0x6
    80002534:	df850513          	addi	a0,a0,-520 # 80008328 <digits+0x2e8>
    80002538:	ffffe097          	auipc	ra,0xffffe
    8000253c:	04c080e7          	jalr	76(ra) # 80000584 <printf>
    while(head_available!=0){
    80002540:	00007797          	auipc	a5,0x7
    80002544:	af07b783          	ld	a5,-1296(a5) # 80009030 <head_available>
      sleep(&head_available,&free_lock);
    80002548:	0000fa97          	auipc	s5,0xf
    8000254c:	0d0a8a93          	addi	s5,s5,208 # 80011618 <free_lock>
    80002550:	00007997          	auipc	s3,0x7
    80002554:	ae098993          	addi	s3,s3,-1312 # 80009030 <head_available>
    while(head_available!=0){
    80002558:	cb91                	beqz	a5,8000256c <btput+0x8a>
      sleep(&head_available,&free_lock);
    8000255a:	85d6                	mv	a1,s5
    8000255c:	854e                	mv	a0,s3
    8000255e:	00000097          	auipc	ra,0x0
    80002562:	f20080e7          	jalr	-224(ra) # 8000247e <sleep>
    while(head_available!=0){
    80002566:	0009b783          	ld	a5,0(s3)
    8000256a:	fbe5                	bnez	a5,8000255a <btput+0x78>
  copyin(myproc()->pagetable,head_available->data,message,140);
    8000256c:	fffff097          	auipc	ra,0xfffff
    80002570:	4b2080e7          	jalr	1202(ra) # 80001a1e <myproc>
    80002574:	08c00693          	li	a3,140
    80002578:	8652                	mv	a2,s4
    8000257a:	00007597          	auipc	a1,0x7
    8000257e:	ab65b583          	ld	a1,-1354(a1) # 80009030 <head_available>
    80002582:	7128                	ld	a0,96(a0)
    80002584:	fffff097          	auipc	ra,0xfffff
    80002588:	16a080e7          	jalr	362(ra) # 800016ee <copyin>
  release(&free_lock);
    8000258c:	0000f517          	auipc	a0,0xf
    80002590:	08c50513          	addi	a0,a0,140 # 80011618 <free_lock>
    80002594:	ffffe097          	auipc	ra,0xffffe
    80002598:	6f0080e7          	jalr	1776(ra) # 80000c84 <release>
  if (topics_array[tag]==0){
    8000259c:	02091793          	slli	a5,s2,0x20
    800025a0:	01d7d713          	srli	a4,a5,0x1d
    800025a4:	0000f797          	auipc	a5,0xf
    800025a8:	d0c78793          	addi	a5,a5,-756 # 800112b0 <free_list>
    800025ac:	97ba                	add	a5,a5,a4
    800025ae:	7807b783          	ld	a5,1920(a5)
    800025b2:	cfb5                	beqz	a5,8000262e <btput+0x14c>
int btput(topic_t tag, uint64 message){
    800025b4:	4981                	li	s3,0
    if (strncmp(free_list[i].data,head_available->data,140)==0){
    800025b6:	00007a17          	auipc	s4,0x7
    800025ba:	a7aa0a13          	addi	s4,s4,-1414 # 80009030 <head_available>
  for (int i = 0; i < maxtweettotal ; i++){
    800025be:	4a95                	li	s5,5
    if (strncmp(free_list[i].data,head_available->data,140)==0){
    800025c0:	8b26                	mv	s6,s1
    800025c2:	08c00613          	li	a2,140
    800025c6:	000a3583          	ld	a1,0(s4)
    800025ca:	8526                	mv	a0,s1
    800025cc:	ffffe097          	auipc	ra,0xffffe
    800025d0:	7d0080e7          	jalr	2000(ra) # 80000d9c <strncmp>
    800025d4:	c92d                	beqz	a0,80002646 <btput+0x164>
  for (int i = 0; i < maxtweettotal ; i++){
    800025d6:	2985                	addiw	s3,s3,1
    800025d8:	0a048493          	addi	s1,s1,160
    800025dc:	ff5992e3          	bne	s3,s5,800025c0 <btput+0xde>
  tweet_t * dup_temp = topics_array[tag];
    800025e0:	02091793          	slli	a5,s2,0x20
    800025e4:	01d7d713          	srli	a4,a5,0x1d
    800025e8:	0000f797          	auipc	a5,0xf
    800025ec:	cc878793          	addi	a5,a5,-824 # 800112b0 <free_list>
    800025f0:	97ba                	add	a5,a5,a4
    800025f2:	7807b483          	ld	s1,1920(a5)
            printf(" TEST : MESSAGE : %s\n next:: %s\n", dup_temp , dup_temp->next );
    800025f6:	00006997          	auipc	s3,0x6
    800025fa:	d0a98993          	addi	s3,s3,-758 # 80008300 <digits+0x2c0>
          while(dup_temp->tag == tag ){
    800025fe:	0984a783          	lw	a5,152(s1)
    80002602:	01279b63          	bne	a5,s2,80002618 <btput+0x136>
            printf(" TEST : MESSAGE : %s\n next:: %s\n", dup_temp , dup_temp->next );
    80002606:	68d0                	ld	a2,144(s1)
    80002608:	85a6                	mv	a1,s1
    8000260a:	854e                	mv	a0,s3
    8000260c:	ffffe097          	auipc	ra,0xffffe
    80002610:	f78080e7          	jalr	-136(ra) # 80000584 <printf>
            if(dup_temp->next ==0){
    80002614:	68c4                	ld	s1,144(s1)
    80002616:	f4e5                	bnez	s1,800025fe <btput+0x11c>
}
    80002618:	4501                	li	a0,0
    8000261a:	70e2                	ld	ra,56(sp)
    8000261c:	7442                	ld	s0,48(sp)
    8000261e:	74a2                	ld	s1,40(sp)
    80002620:	7902                	ld	s2,32(sp)
    80002622:	69e2                	ld	s3,24(sp)
    80002624:	6a42                	ld	s4,16(sp)
    80002626:	6aa2                	ld	s5,8(sp)
    80002628:	6b02                	ld	s6,0(sp)
    8000262a:	6121                	addi	sp,sp,64
    8000262c:	8082                	ret
      topics_array[tag] = head_available;
    8000262e:	0000f797          	auipc	a5,0xf
    80002632:	c8278793          	addi	a5,a5,-894 # 800112b0 <free_list>
    80002636:	97ba                	add	a5,a5,a4
    80002638:	00007717          	auipc	a4,0x7
    8000263c:	9f873703          	ld	a4,-1544(a4) # 80009030 <head_available>
    80002640:	78e7b023          	sd	a4,1920(a5)
    80002644:	bf85                	j	800025b4 <btput+0xd2>
        head_available = free_list[i].next; // 
    80002646:	00299793          	slli	a5,s3,0x2
    8000264a:	97ce                	add	a5,a5,s3
    8000264c:	0796                	slli	a5,a5,0x5
    8000264e:	0000f717          	auipc	a4,0xf
    80002652:	c6270713          	addi	a4,a4,-926 # 800112b0 <free_list>
    80002656:	97ba                	add	a5,a5,a4
    80002658:	6bd8                	ld	a4,144(a5)
    8000265a:	00007697          	auipc	a3,0x7
    8000265e:	9ce6bb23          	sd	a4,-1578(a3) # 80009030 <head_available>
        free_list[i].tag = tag; // set the tag for the particular tweet
    80002662:	0927ac23          	sw	s2,152(a5)
        if (i!=0){       
    80002666:	02098763          	beqz	s3,80002694 <btput+0x1b2>
          if (free_list[i-1].tag!=free_list[i].tag){
    8000266a:	39fd                	addiw	s3,s3,-1
    8000266c:	00299793          	slli	a5,s3,0x2
    80002670:	97ce                	add	a5,a5,s3
    80002672:	0796                	slli	a5,a5,0x5
    80002674:	0000f717          	auipc	a4,0xf
    80002678:	c3c70713          	addi	a4,a4,-964 # 800112b0 <free_list>
    8000267c:	97ba                	add	a5,a5,a4
    8000267e:	0987a783          	lw	a5,152(a5)
    80002682:	01278963          	beq	a5,s2,80002694 <btput+0x1b2>
              free_list[i-1].next = 0;
    80002686:	00299793          	slli	a5,s3,0x2
    8000268a:	97ce                	add	a5,a5,s3
    8000268c:	0796                	slli	a5,a5,0x5
    8000268e:	97ba                	add	a5,a5,a4
    80002690:	0807b823          	sd	zero,144(a5)
         tweet_t * temp = topics_array[tag];
    80002694:	02091793          	slli	a5,s2,0x20
    80002698:	01d7d713          	srli	a4,a5,0x1d
    8000269c:	0000f797          	auipc	a5,0xf
    800026a0:	c1478793          	addi	a5,a5,-1004 # 800112b0 <free_list>
    800026a4:	97ba                	add	a5,a5,a4
    800026a6:	7807b783          	ld	a5,1920(a5)
         while(temp->tag == tag ){
    800026aa:	0987a703          	lw	a4,152(a5)
    800026ae:	f32719e3          	bne	a4,s2,800025e0 <btput+0xfe>
            if(temp->next ==0){
    800026b2:	6bd8                	ld	a4,144(a5)
    800026b4:	c319                	beqz	a4,800026ba <btput+0x1d8>
            temp = temp->next;
    800026b6:	87ba                	mv	a5,a4
    800026b8:	bfcd                	j	800026aa <btput+0x1c8>
                temp->next = &free_list[i];
    800026ba:	0967b823          	sd	s6,144(a5)
                break;
    800026be:	b70d                	j	800025e0 <btput+0xfe>
  acquire(&free_lock);
    800026c0:	0000f517          	auipc	a0,0xf
    800026c4:	f5850513          	addi	a0,a0,-168 # 80011618 <free_lock>
    800026c8:	ffffe097          	auipc	ra,0xffffe
    800026cc:	508080e7          	jalr	1288(ra) # 80000bd0 <acquire>
  if (all_Notoccupied != 0){
    800026d0:	bd71                	j	8000256c <btput+0x8a>

00000000800026d2 <wait>:
{
    800026d2:	715d                	addi	sp,sp,-80
    800026d4:	e486                	sd	ra,72(sp)
    800026d6:	e0a2                	sd	s0,64(sp)
    800026d8:	fc26                	sd	s1,56(sp)
    800026da:	f84a                	sd	s2,48(sp)
    800026dc:	f44e                	sd	s3,40(sp)
    800026de:	f052                	sd	s4,32(sp)
    800026e0:	ec56                	sd	s5,24(sp)
    800026e2:	e85a                	sd	s6,16(sp)
    800026e4:	e45e                	sd	s7,8(sp)
    800026e6:	e062                	sd	s8,0(sp)
    800026e8:	0880                	addi	s0,sp,80
    800026ea:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800026ec:	fffff097          	auipc	ra,0xfffff
    800026f0:	332080e7          	jalr	818(ra) # 80001a1e <myproc>
    800026f4:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800026f6:	0000f517          	auipc	a0,0xf
    800026fa:	ef250513          	addi	a0,a0,-270 # 800115e8 <wait_lock>
    800026fe:	ffffe097          	auipc	ra,0xffffe
    80002702:	4d2080e7          	jalr	1234(ra) # 80000bd0 <acquire>
    havekids = 0;
    80002706:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002708:	4a15                	li	s4,5
        havekids = 1;
    8000270a:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    8000270c:	00015997          	auipc	s3,0x15
    80002710:	14c98993          	addi	s3,s3,332 # 80017858 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002714:	0000fc17          	auipc	s8,0xf
    80002718:	ed4c0c13          	addi	s8,s8,-300 # 800115e8 <wait_lock>
    havekids = 0;
    8000271c:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    8000271e:	0000f497          	auipc	s1,0xf
    80002722:	33a48493          	addi	s1,s1,826 # 80011a58 <proc>
    80002726:	a0bd                	j	80002794 <wait+0xc2>
          pid = np->pid;
    80002728:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000272c:	000b0e63          	beqz	s6,80002748 <wait+0x76>
    80002730:	4691                	li	a3,4
    80002732:	02c48613          	addi	a2,s1,44
    80002736:	85da                	mv	a1,s6
    80002738:	06093503          	ld	a0,96(s2)
    8000273c:	fffff097          	auipc	ra,0xfffff
    80002740:	f26080e7          	jalr	-218(ra) # 80001662 <copyout>
    80002744:	02054563          	bltz	a0,8000276e <wait+0x9c>
          freeproc(np);
    80002748:	8526                	mv	a0,s1
    8000274a:	fffff097          	auipc	ra,0xfffff
    8000274e:	6ce080e7          	jalr	1742(ra) # 80001e18 <freeproc>
          release(&np->lock);
    80002752:	8526                	mv	a0,s1
    80002754:	ffffe097          	auipc	ra,0xffffe
    80002758:	530080e7          	jalr	1328(ra) # 80000c84 <release>
          release(&wait_lock);
    8000275c:	0000f517          	auipc	a0,0xf
    80002760:	e8c50513          	addi	a0,a0,-372 # 800115e8 <wait_lock>
    80002764:	ffffe097          	auipc	ra,0xffffe
    80002768:	520080e7          	jalr	1312(ra) # 80000c84 <release>
          return pid;
    8000276c:	a09d                	j	800027d2 <wait+0x100>
            release(&np->lock);
    8000276e:	8526                	mv	a0,s1
    80002770:	ffffe097          	auipc	ra,0xffffe
    80002774:	514080e7          	jalr	1300(ra) # 80000c84 <release>
            release(&wait_lock);
    80002778:	0000f517          	auipc	a0,0xf
    8000277c:	e7050513          	addi	a0,a0,-400 # 800115e8 <wait_lock>
    80002780:	ffffe097          	auipc	ra,0xffffe
    80002784:	504080e7          	jalr	1284(ra) # 80000c84 <release>
            return -1;
    80002788:	59fd                	li	s3,-1
    8000278a:	a0a1                	j	800027d2 <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    8000278c:	17848493          	addi	s1,s1,376
    80002790:	03348463          	beq	s1,s3,800027b8 <wait+0xe6>
      if(np->parent == p){
    80002794:	64bc                	ld	a5,72(s1)
    80002796:	ff279be3          	bne	a5,s2,8000278c <wait+0xba>
        acquire(&np->lock);
    8000279a:	8526                	mv	a0,s1
    8000279c:	ffffe097          	auipc	ra,0xffffe
    800027a0:	434080e7          	jalr	1076(ra) # 80000bd0 <acquire>
        if(np->state == ZOMBIE){
    800027a4:	4c9c                	lw	a5,24(s1)
    800027a6:	f94781e3          	beq	a5,s4,80002728 <wait+0x56>
        release(&np->lock);
    800027aa:	8526                	mv	a0,s1
    800027ac:	ffffe097          	auipc	ra,0xffffe
    800027b0:	4d8080e7          	jalr	1240(ra) # 80000c84 <release>
        havekids = 1;
    800027b4:	8756                	mv	a4,s5
    800027b6:	bfd9                	j	8000278c <wait+0xba>
    if(!havekids || p->killed){
    800027b8:	c701                	beqz	a4,800027c0 <wait+0xee>
    800027ba:	02892783          	lw	a5,40(s2)
    800027be:	c79d                	beqz	a5,800027ec <wait+0x11a>
      release(&wait_lock);
    800027c0:	0000f517          	auipc	a0,0xf
    800027c4:	e2850513          	addi	a0,a0,-472 # 800115e8 <wait_lock>
    800027c8:	ffffe097          	auipc	ra,0xffffe
    800027cc:	4bc080e7          	jalr	1212(ra) # 80000c84 <release>
      return -1;
    800027d0:	59fd                	li	s3,-1
}
    800027d2:	854e                	mv	a0,s3
    800027d4:	60a6                	ld	ra,72(sp)
    800027d6:	6406                	ld	s0,64(sp)
    800027d8:	74e2                	ld	s1,56(sp)
    800027da:	7942                	ld	s2,48(sp)
    800027dc:	79a2                	ld	s3,40(sp)
    800027de:	7a02                	ld	s4,32(sp)
    800027e0:	6ae2                	ld	s5,24(sp)
    800027e2:	6b42                	ld	s6,16(sp)
    800027e4:	6ba2                	ld	s7,8(sp)
    800027e6:	6c02                	ld	s8,0(sp)
    800027e8:	6161                	addi	sp,sp,80
    800027ea:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800027ec:	85e2                	mv	a1,s8
    800027ee:	854a                	mv	a0,s2
    800027f0:	00000097          	auipc	ra,0x0
    800027f4:	c8e080e7          	jalr	-882(ra) # 8000247e <sleep>
    havekids = 0;
    800027f8:	b715                	j	8000271c <wait+0x4a>

00000000800027fa <waitstat>:
{
    800027fa:	7159                	addi	sp,sp,-112
    800027fc:	f486                	sd	ra,104(sp)
    800027fe:	f0a2                	sd	s0,96(sp)
    80002800:	eca6                	sd	s1,88(sp)
    80002802:	e8ca                	sd	s2,80(sp)
    80002804:	e4ce                	sd	s3,72(sp)
    80002806:	e0d2                	sd	s4,64(sp)
    80002808:	fc56                	sd	s5,56(sp)
    8000280a:	f85a                	sd	s6,48(sp)
    8000280c:	f45e                	sd	s7,40(sp)
    8000280e:	f062                	sd	s8,32(sp)
    80002810:	ec66                	sd	s9,24(sp)
    80002812:	e86a                	sd	s10,16(sp)
    80002814:	1880                	addi	s0,sp,112
    80002816:	8b2a                	mv	s6,a0
    80002818:	8c2e                	mv	s8,a1
    8000281a:	8bb2                	mv	s7,a2
  struct proc *p = myproc();
    8000281c:	fffff097          	auipc	ra,0xfffff
    80002820:	202080e7          	jalr	514(ra) # 80001a1e <myproc>
    80002824:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002826:	0000f517          	auipc	a0,0xf
    8000282a:	dc250513          	addi	a0,a0,-574 # 800115e8 <wait_lock>
    8000282e:	ffffe097          	auipc	ra,0xffffe
    80002832:	3a2080e7          	jalr	930(ra) # 80000bd0 <acquire>
    havekids = 0;
    80002836:	4c81                	li	s9,0
        if(np->state == ZOMBIE){
    80002838:	4a15                	li	s4,5
        havekids = 1;
    8000283a:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    8000283c:	00015997          	auipc	s3,0x15
    80002840:	01c98993          	addi	s3,s3,28 # 80017858 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002844:	0000fd17          	auipc	s10,0xf
    80002848:	da4d0d13          	addi	s10,s10,-604 # 800115e8 <wait_lock>
    havekids = 0;
    8000284c:	8766                	mv	a4,s9
    for(np = proc; np < &proc[NPROC]; np++){
    8000284e:	0000f497          	auipc	s1,0xf
    80002852:	20a48493          	addi	s1,s1,522 # 80011a58 <proc>
    80002856:	a05d                	j	800028fc <waitstat+0x102>
          pid = np->pid;
    80002858:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000285c:	000b0e63          	beqz	s6,80002878 <waitstat+0x7e>
    80002860:	4691                	li	a3,4
    80002862:	02c48613          	addi	a2,s1,44
    80002866:	85da                	mv	a1,s6
    80002868:	06093503          	ld	a0,96(s2)
    8000286c:	fffff097          	auipc	ra,0xfffff
    80002870:	df6080e7          	jalr	-522(ra) # 80001662 <copyout>
    80002874:	06054163          	bltz	a0,800028d6 <waitstat+0xdc>
          uint calc = np-> ended - np-> created;
    80002878:	5c9c                	lw	a5,56(s1)
    8000287a:	58d8                	lw	a4,52(s1)
    8000287c:	9f99                	subw	a5,a5,a4
    8000287e:	f8f42c23          	sw	a5,-104(s0)
          copyout(p->pagetable, turnaround_time , (char *) &calc , sizeof(calc));
    80002882:	4691                	li	a3,4
    80002884:	f9840613          	addi	a2,s0,-104
    80002888:	85e2                	mv	a1,s8
    8000288a:	06093503          	ld	a0,96(s2)
    8000288e:	fffff097          	auipc	ra,0xfffff
    80002892:	dd4080e7          	jalr	-556(ra) # 80001662 <copyout>
          uint RunTime = np-> running;
    80002896:	5cdc                	lw	a5,60(s1)
    80002898:	f8f42e23          	sw	a5,-100(s0)
          copyout(p->pagetable, running, (char *) &RunTime, sizeof(RunTime));
    8000289c:	4691                	li	a3,4
    8000289e:	f9c40613          	addi	a2,s0,-100
    800028a2:	85de                	mv	a1,s7
    800028a4:	06093503          	ld	a0,96(s2)
    800028a8:	fffff097          	auipc	ra,0xfffff
    800028ac:	dba080e7          	jalr	-582(ra) # 80001662 <copyout>
          freeproc(np);
    800028b0:	8526                	mv	a0,s1
    800028b2:	fffff097          	auipc	ra,0xfffff
    800028b6:	566080e7          	jalr	1382(ra) # 80001e18 <freeproc>
          release(&np->lock);
    800028ba:	8526                	mv	a0,s1
    800028bc:	ffffe097          	auipc	ra,0xffffe
    800028c0:	3c8080e7          	jalr	968(ra) # 80000c84 <release>
          release(&wait_lock);
    800028c4:	0000f517          	auipc	a0,0xf
    800028c8:	d2450513          	addi	a0,a0,-732 # 800115e8 <wait_lock>
    800028cc:	ffffe097          	auipc	ra,0xffffe
    800028d0:	3b8080e7          	jalr	952(ra) # 80000c84 <release>
          return pid;
    800028d4:	a09d                	j	8000293a <waitstat+0x140>
            release(&np->lock);
    800028d6:	8526                	mv	a0,s1
    800028d8:	ffffe097          	auipc	ra,0xffffe
    800028dc:	3ac080e7          	jalr	940(ra) # 80000c84 <release>
            release(&wait_lock);
    800028e0:	0000f517          	auipc	a0,0xf
    800028e4:	d0850513          	addi	a0,a0,-760 # 800115e8 <wait_lock>
    800028e8:	ffffe097          	auipc	ra,0xffffe
    800028ec:	39c080e7          	jalr	924(ra) # 80000c84 <release>
            return -1;
    800028f0:	59fd                	li	s3,-1
    800028f2:	a0a1                	j	8000293a <waitstat+0x140>
    for(np = proc; np < &proc[NPROC]; np++){
    800028f4:	17848493          	addi	s1,s1,376
    800028f8:	03348463          	beq	s1,s3,80002920 <waitstat+0x126>
      if(np->parent == p){
    800028fc:	64bc                	ld	a5,72(s1)
    800028fe:	ff279be3          	bne	a5,s2,800028f4 <waitstat+0xfa>
        acquire(&np->lock);
    80002902:	8526                	mv	a0,s1
    80002904:	ffffe097          	auipc	ra,0xffffe
    80002908:	2cc080e7          	jalr	716(ra) # 80000bd0 <acquire>
        if(np->state == ZOMBIE){
    8000290c:	4c9c                	lw	a5,24(s1)
    8000290e:	f54785e3          	beq	a5,s4,80002858 <waitstat+0x5e>
        release(&np->lock);
    80002912:	8526                	mv	a0,s1
    80002914:	ffffe097          	auipc	ra,0xffffe
    80002918:	370080e7          	jalr	880(ra) # 80000c84 <release>
        havekids = 1;
    8000291c:	8756                	mv	a4,s5
    8000291e:	bfd9                	j	800028f4 <waitstat+0xfa>
    if(!havekids || p->killed){
    80002920:	c701                	beqz	a4,80002928 <waitstat+0x12e>
    80002922:	02892783          	lw	a5,40(s2)
    80002926:	cb8d                	beqz	a5,80002958 <waitstat+0x15e>
      release(&wait_lock);
    80002928:	0000f517          	auipc	a0,0xf
    8000292c:	cc050513          	addi	a0,a0,-832 # 800115e8 <wait_lock>
    80002930:	ffffe097          	auipc	ra,0xffffe
    80002934:	354080e7          	jalr	852(ra) # 80000c84 <release>
      return -1;
    80002938:	59fd                	li	s3,-1
}
    8000293a:	854e                	mv	a0,s3
    8000293c:	70a6                	ld	ra,104(sp)
    8000293e:	7406                	ld	s0,96(sp)
    80002940:	64e6                	ld	s1,88(sp)
    80002942:	6946                	ld	s2,80(sp)
    80002944:	69a6                	ld	s3,72(sp)
    80002946:	6a06                	ld	s4,64(sp)
    80002948:	7ae2                	ld	s5,56(sp)
    8000294a:	7b42                	ld	s6,48(sp)
    8000294c:	7ba2                	ld	s7,40(sp)
    8000294e:	7c02                	ld	s8,32(sp)
    80002950:	6ce2                	ld	s9,24(sp)
    80002952:	6d42                	ld	s10,16(sp)
    80002954:	6165                	addi	sp,sp,112
    80002956:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002958:	85ea                	mv	a1,s10
    8000295a:	854a                	mv	a0,s2
    8000295c:	00000097          	auipc	ra,0x0
    80002960:	b22080e7          	jalr	-1246(ra) # 8000247e <sleep>
    havekids = 0;
    80002964:	b5e5                	j	8000284c <waitstat+0x52>

0000000080002966 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002966:	7139                	addi	sp,sp,-64
    80002968:	fc06                	sd	ra,56(sp)
    8000296a:	f822                	sd	s0,48(sp)
    8000296c:	f426                	sd	s1,40(sp)
    8000296e:	f04a                	sd	s2,32(sp)
    80002970:	ec4e                	sd	s3,24(sp)
    80002972:	e852                	sd	s4,16(sp)
    80002974:	e456                	sd	s5,8(sp)
    80002976:	0080                	addi	s0,sp,64
    80002978:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000297a:	0000f497          	auipc	s1,0xf
    8000297e:	0de48493          	addi	s1,s1,222 # 80011a58 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002982:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002984:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002986:	00015917          	auipc	s2,0x15
    8000298a:	ed290913          	addi	s2,s2,-302 # 80017858 <tickslock>
    8000298e:	a811                	j	800029a2 <wakeup+0x3c>
      }
      release(&p->lock);
    80002990:	8526                	mv	a0,s1
    80002992:	ffffe097          	auipc	ra,0xffffe
    80002996:	2f2080e7          	jalr	754(ra) # 80000c84 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000299a:	17848493          	addi	s1,s1,376
    8000299e:	03248663          	beq	s1,s2,800029ca <wakeup+0x64>
    if(p != myproc()){
    800029a2:	fffff097          	auipc	ra,0xfffff
    800029a6:	07c080e7          	jalr	124(ra) # 80001a1e <myproc>
    800029aa:	fea488e3          	beq	s1,a0,8000299a <wakeup+0x34>
      acquire(&p->lock);
    800029ae:	8526                	mv	a0,s1
    800029b0:	ffffe097          	auipc	ra,0xffffe
    800029b4:	220080e7          	jalr	544(ra) # 80000bd0 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800029b8:	4c9c                	lw	a5,24(s1)
    800029ba:	fd379be3          	bne	a5,s3,80002990 <wakeup+0x2a>
    800029be:	709c                	ld	a5,32(s1)
    800029c0:	fd4798e3          	bne	a5,s4,80002990 <wakeup+0x2a>
        p->state = RUNNABLE;
    800029c4:	0154ac23          	sw	s5,24(s1)
    800029c8:	b7e1                	j	80002990 <wakeup+0x2a>
    }
  }
}
    800029ca:	70e2                	ld	ra,56(sp)
    800029cc:	7442                	ld	s0,48(sp)
    800029ce:	74a2                	ld	s1,40(sp)
    800029d0:	7902                	ld	s2,32(sp)
    800029d2:	69e2                	ld	s3,24(sp)
    800029d4:	6a42                	ld	s4,16(sp)
    800029d6:	6aa2                	ld	s5,8(sp)
    800029d8:	6121                	addi	sp,sp,64
    800029da:	8082                	ret

00000000800029dc <btget>:
 int btget(topic_t tag , uint64 buf){
    800029dc:	7179                	addi	sp,sp,-48
    800029de:	f406                	sd	ra,40(sp)
    800029e0:	f022                	sd	s0,32(sp)
    800029e2:	ec26                	sd	s1,24(sp)
    800029e4:	e84a                	sd	s2,16(sp)
    800029e6:	e44e                	sd	s3,8(sp)
    800029e8:	1800                	addi	s0,sp,48
    800029ea:	84aa                	mv	s1,a0
    800029ec:	892e                	mv	s2,a1
    acquire(&tweet_lock);
    800029ee:	0000f997          	auipc	s3,0xf
    800029f2:	c1298993          	addi	s3,s3,-1006 # 80011600 <tweet_lock>
    800029f6:	854e                	mv	a0,s3
    800029f8:	ffffe097          	auipc	ra,0xffffe
    800029fc:	1d8080e7          	jalr	472(ra) # 80000bd0 <acquire>
    copyout(myproc()->pagetable, buf , topics_array[tag]->data,140);
    80002a00:	fffff097          	auipc	ra,0xfffff
    80002a04:	01e080e7          	jalr	30(ra) # 80001a1e <myproc>
    80002a08:	02049713          	slli	a4,s1,0x20
    80002a0c:	01d75793          	srli	a5,a4,0x1d
    80002a10:	0000f497          	auipc	s1,0xf
    80002a14:	8a048493          	addi	s1,s1,-1888 # 800112b0 <free_list>
    80002a18:	94be                	add	s1,s1,a5
    80002a1a:	08c00693          	li	a3,140
    80002a1e:	7804b603          	ld	a2,1920(s1)
    80002a22:	85ca                	mv	a1,s2
    80002a24:	7128                	ld	a0,96(a0)
    80002a26:	fffff097          	auipc	ra,0xfffff
    80002a2a:	c3c080e7          	jalr	-964(ra) # 80001662 <copyout>
    head_available = topics_array[tag];
    80002a2e:	7804b783          	ld	a5,1920(s1)
    80002a32:	00006517          	auipc	a0,0x6
    80002a36:	5fe50513          	addi	a0,a0,1534 # 80009030 <head_available>
    80002a3a:	e11c                	sd	a5,0(a0)
    topics_array[tag] = topics_array[tag]->next;
    80002a3c:	6bd8                	ld	a4,144(a5)
    80002a3e:	78e4b023          	sd	a4,1920(s1)
    head_available->next = 0;
    80002a42:	0807b823          	sd	zero,144(a5)
    wakeup(&head_available);
    80002a46:	00000097          	auipc	ra,0x0
    80002a4a:	f20080e7          	jalr	-224(ra) # 80002966 <wakeup>
    release(&tweet_lock);
    80002a4e:	854e                	mv	a0,s3
    80002a50:	ffffe097          	auipc	ra,0xffffe
    80002a54:	234080e7          	jalr	564(ra) # 80000c84 <release>
    printf(" BTGET :First tag node : %s\n",topics_array[tag]);
    80002a58:	7804b583          	ld	a1,1920(s1)
    80002a5c:	00005517          	auipc	a0,0x5
    80002a60:	7c450513          	addi	a0,a0,1988 # 80008220 <digits+0x1e0>
    80002a64:	ffffe097          	auipc	ra,0xffffe
    80002a68:	b20080e7          	jalr	-1248(ra) # 80000584 <printf>
  }
    80002a6c:	4501                	li	a0,0
    80002a6e:	70a2                	ld	ra,40(sp)
    80002a70:	7402                	ld	s0,32(sp)
    80002a72:	64e2                	ld	s1,24(sp)
    80002a74:	6942                	ld	s2,16(sp)
    80002a76:	69a2                	ld	s3,8(sp)
    80002a78:	6145                	addi	sp,sp,48
    80002a7a:	8082                	ret

0000000080002a7c <reparent>:
{
    80002a7c:	7179                	addi	sp,sp,-48
    80002a7e:	f406                	sd	ra,40(sp)
    80002a80:	f022                	sd	s0,32(sp)
    80002a82:	ec26                	sd	s1,24(sp)
    80002a84:	e84a                	sd	s2,16(sp)
    80002a86:	e44e                	sd	s3,8(sp)
    80002a88:	e052                	sd	s4,0(sp)
    80002a8a:	1800                	addi	s0,sp,48
    80002a8c:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002a8e:	0000f497          	auipc	s1,0xf
    80002a92:	fca48493          	addi	s1,s1,-54 # 80011a58 <proc>
      pp->parent = initproc;
    80002a96:	00006a17          	auipc	s4,0x6
    80002a9a:	5a2a0a13          	addi	s4,s4,1442 # 80009038 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002a9e:	00015997          	auipc	s3,0x15
    80002aa2:	dba98993          	addi	s3,s3,-582 # 80017858 <tickslock>
    80002aa6:	a029                	j	80002ab0 <reparent+0x34>
    80002aa8:	17848493          	addi	s1,s1,376
    80002aac:	01348d63          	beq	s1,s3,80002ac6 <reparent+0x4a>
    if(pp->parent == p){
    80002ab0:	64bc                	ld	a5,72(s1)
    80002ab2:	ff279be3          	bne	a5,s2,80002aa8 <reparent+0x2c>
      pp->parent = initproc;
    80002ab6:	000a3503          	ld	a0,0(s4)
    80002aba:	e4a8                	sd	a0,72(s1)
      wakeup(initproc);
    80002abc:	00000097          	auipc	ra,0x0
    80002ac0:	eaa080e7          	jalr	-342(ra) # 80002966 <wakeup>
    80002ac4:	b7d5                	j	80002aa8 <reparent+0x2c>
}
    80002ac6:	70a2                	ld	ra,40(sp)
    80002ac8:	7402                	ld	s0,32(sp)
    80002aca:	64e2                	ld	s1,24(sp)
    80002acc:	6942                	ld	s2,16(sp)
    80002ace:	69a2                	ld	s3,8(sp)
    80002ad0:	6a02                	ld	s4,0(sp)
    80002ad2:	6145                	addi	sp,sp,48
    80002ad4:	8082                	ret

0000000080002ad6 <exit>:
{
    80002ad6:	7179                	addi	sp,sp,-48
    80002ad8:	f406                	sd	ra,40(sp)
    80002ada:	f022                	sd	s0,32(sp)
    80002adc:	ec26                	sd	s1,24(sp)
    80002ade:	e84a                	sd	s2,16(sp)
    80002ae0:	e44e                	sd	s3,8(sp)
    80002ae2:	e052                	sd	s4,0(sp)
    80002ae4:	1800                	addi	s0,sp,48
    80002ae6:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002ae8:	fffff097          	auipc	ra,0xfffff
    80002aec:	f36080e7          	jalr	-202(ra) # 80001a1e <myproc>
    80002af0:	89aa                	mv	s3,a0
  if(p == initproc)
    80002af2:	00006797          	auipc	a5,0x6
    80002af6:	5467b783          	ld	a5,1350(a5) # 80009038 <initproc>
    80002afa:	0e050493          	addi	s1,a0,224
    80002afe:	16050913          	addi	s2,a0,352
    80002b02:	02a79363          	bne	a5,a0,80002b28 <exit+0x52>
    panic("init exiting");
    80002b06:	00006517          	auipc	a0,0x6
    80002b0a:	84a50513          	addi	a0,a0,-1974 # 80008350 <digits+0x310>
    80002b0e:	ffffe097          	auipc	ra,0xffffe
    80002b12:	a2c080e7          	jalr	-1492(ra) # 8000053a <panic>
      fileclose(f);
    80002b16:	00002097          	auipc	ra,0x2
    80002b1a:	356080e7          	jalr	854(ra) # 80004e6c <fileclose>
      p->ofile[fd] = 0;
    80002b1e:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002b22:	04a1                	addi	s1,s1,8
    80002b24:	01248563          	beq	s1,s2,80002b2e <exit+0x58>
    if(p->ofile[fd]){
    80002b28:	6088                	ld	a0,0(s1)
    80002b2a:	f575                	bnez	a0,80002b16 <exit+0x40>
    80002b2c:	bfdd                	j	80002b22 <exit+0x4c>
  begin_op();
    80002b2e:	00002097          	auipc	ra,0x2
    80002b32:	e76080e7          	jalr	-394(ra) # 800049a4 <begin_op>
  iput(p->cwd);
    80002b36:	1609b503          	ld	a0,352(s3)
    80002b3a:	00001097          	auipc	ra,0x1
    80002b3e:	648080e7          	jalr	1608(ra) # 80004182 <iput>
  end_op();
    80002b42:	00002097          	auipc	ra,0x2
    80002b46:	ee0080e7          	jalr	-288(ra) # 80004a22 <end_op>
  p->cwd = 0;
    80002b4a:	1609b023          	sd	zero,352(s3)
  acquire(&wait_lock);
    80002b4e:	0000f497          	auipc	s1,0xf
    80002b52:	a9a48493          	addi	s1,s1,-1382 # 800115e8 <wait_lock>
    80002b56:	8526                	mv	a0,s1
    80002b58:	ffffe097          	auipc	ra,0xffffe
    80002b5c:	078080e7          	jalr	120(ra) # 80000bd0 <acquire>
  reparent(p);
    80002b60:	854e                	mv	a0,s3
    80002b62:	00000097          	auipc	ra,0x0
    80002b66:	f1a080e7          	jalr	-230(ra) # 80002a7c <reparent>
  wakeup(p->parent);
    80002b6a:	0489b503          	ld	a0,72(s3)
    80002b6e:	00000097          	auipc	ra,0x0
    80002b72:	df8080e7          	jalr	-520(ra) # 80002966 <wakeup>
  acquire(&p->lock);
    80002b76:	854e                	mv	a0,s3
    80002b78:	ffffe097          	auipc	ra,0xffffe
    80002b7c:	058080e7          	jalr	88(ra) # 80000bd0 <acquire>
  p->xstate = status;
    80002b80:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002b84:	4795                	li	a5,5
    80002b86:	00f9ac23          	sw	a5,24(s3)
  acquire(&tickslock);
    80002b8a:	00015517          	auipc	a0,0x15
    80002b8e:	cce50513          	addi	a0,a0,-818 # 80017858 <tickslock>
    80002b92:	ffffe097          	auipc	ra,0xffffe
    80002b96:	03e080e7          	jalr	62(ra) # 80000bd0 <acquire>
  p->ended = ticks; // Note the time when the process ended. 
    80002b9a:	00006797          	auipc	a5,0x6
    80002b9e:	4a67a783          	lw	a5,1190(a5) # 80009040 <ticks>
    80002ba2:	02f9ac23          	sw	a5,56(s3)
  release(&tickslock);
    80002ba6:	00015517          	auipc	a0,0x15
    80002baa:	cb250513          	addi	a0,a0,-846 # 80017858 <tickslock>
    80002bae:	ffffe097          	auipc	ra,0xffffe
    80002bb2:	0d6080e7          	jalr	214(ra) # 80000c84 <release>
  release(&wait_lock);
    80002bb6:	8526                	mv	a0,s1
    80002bb8:	ffffe097          	auipc	ra,0xffffe
    80002bbc:	0cc080e7          	jalr	204(ra) # 80000c84 <release>
  sched();
    80002bc0:	fffff097          	auipc	ra,0xfffff
    80002bc4:	7ac080e7          	jalr	1964(ra) # 8000236c <sched>
  panic("zombie exit");
    80002bc8:	00005517          	auipc	a0,0x5
    80002bcc:	79850513          	addi	a0,a0,1944 # 80008360 <digits+0x320>
    80002bd0:	ffffe097          	auipc	ra,0xffffe
    80002bd4:	96a080e7          	jalr	-1686(ra) # 8000053a <panic>

0000000080002bd8 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002bd8:	7179                	addi	sp,sp,-48
    80002bda:	f406                	sd	ra,40(sp)
    80002bdc:	f022                	sd	s0,32(sp)
    80002bde:	ec26                	sd	s1,24(sp)
    80002be0:	e84a                	sd	s2,16(sp)
    80002be2:	e44e                	sd	s3,8(sp)
    80002be4:	1800                	addi	s0,sp,48
    80002be6:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002be8:	0000f497          	auipc	s1,0xf
    80002bec:	e7048493          	addi	s1,s1,-400 # 80011a58 <proc>
    80002bf0:	00015997          	auipc	s3,0x15
    80002bf4:	c6898993          	addi	s3,s3,-920 # 80017858 <tickslock>
    acquire(&p->lock);
    80002bf8:	8526                	mv	a0,s1
    80002bfa:	ffffe097          	auipc	ra,0xffffe
    80002bfe:	fd6080e7          	jalr	-42(ra) # 80000bd0 <acquire>
    if(p->pid == pid){
    80002c02:	589c                	lw	a5,48(s1)
    80002c04:	01278d63          	beq	a5,s2,80002c1e <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002c08:	8526                	mv	a0,s1
    80002c0a:	ffffe097          	auipc	ra,0xffffe
    80002c0e:	07a080e7          	jalr	122(ra) # 80000c84 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002c12:	17848493          	addi	s1,s1,376
    80002c16:	ff3491e3          	bne	s1,s3,80002bf8 <kill+0x20>
  }
  return -1;
    80002c1a:	557d                	li	a0,-1
    80002c1c:	a091                	j	80002c60 <kill+0x88>
      p->killed = 1;
    80002c1e:	4785                	li	a5,1
    80002c20:	d49c                	sw	a5,40(s1)
      acquire(&tickslock); // not ethe time for exiting
    80002c22:	00015517          	auipc	a0,0x15
    80002c26:	c3650513          	addi	a0,a0,-970 # 80017858 <tickslock>
    80002c2a:	ffffe097          	auipc	ra,0xffffe
    80002c2e:	fa6080e7          	jalr	-90(ra) # 80000bd0 <acquire>
      p->ended = ticks;
    80002c32:	00006797          	auipc	a5,0x6
    80002c36:	40e7a783          	lw	a5,1038(a5) # 80009040 <ticks>
    80002c3a:	dc9c                	sw	a5,56(s1)
      release(&tickslock);
    80002c3c:	00015517          	auipc	a0,0x15
    80002c40:	c1c50513          	addi	a0,a0,-996 # 80017858 <tickslock>
    80002c44:	ffffe097          	auipc	ra,0xffffe
    80002c48:	040080e7          	jalr	64(ra) # 80000c84 <release>
      if(p->state == SLEEPING){
    80002c4c:	4c98                	lw	a4,24(s1)
    80002c4e:	4789                	li	a5,2
    80002c50:	00f70f63          	beq	a4,a5,80002c6e <kill+0x96>
      release(&p->lock);
    80002c54:	8526                	mv	a0,s1
    80002c56:	ffffe097          	auipc	ra,0xffffe
    80002c5a:	02e080e7          	jalr	46(ra) # 80000c84 <release>
      return 0;
    80002c5e:	4501                	li	a0,0
}
    80002c60:	70a2                	ld	ra,40(sp)
    80002c62:	7402                	ld	s0,32(sp)
    80002c64:	64e2                	ld	s1,24(sp)
    80002c66:	6942                	ld	s2,16(sp)
    80002c68:	69a2                	ld	s3,8(sp)
    80002c6a:	6145                	addi	sp,sp,48
    80002c6c:	8082                	ret
        p->state = RUNNABLE;
    80002c6e:	478d                	li	a5,3
    80002c70:	cc9c                	sw	a5,24(s1)
    80002c72:	b7cd                	j	80002c54 <kill+0x7c>

0000000080002c74 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002c74:	7179                	addi	sp,sp,-48
    80002c76:	f406                	sd	ra,40(sp)
    80002c78:	f022                	sd	s0,32(sp)
    80002c7a:	ec26                	sd	s1,24(sp)
    80002c7c:	e84a                	sd	s2,16(sp)
    80002c7e:	e44e                	sd	s3,8(sp)
    80002c80:	e052                	sd	s4,0(sp)
    80002c82:	1800                	addi	s0,sp,48
    80002c84:	84aa                	mv	s1,a0
    80002c86:	892e                	mv	s2,a1
    80002c88:	89b2                	mv	s3,a2
    80002c8a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002c8c:	fffff097          	auipc	ra,0xfffff
    80002c90:	d92080e7          	jalr	-622(ra) # 80001a1e <myproc>
  if(user_dst){
    80002c94:	c08d                	beqz	s1,80002cb6 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002c96:	86d2                	mv	a3,s4
    80002c98:	864e                	mv	a2,s3
    80002c9a:	85ca                	mv	a1,s2
    80002c9c:	7128                	ld	a0,96(a0)
    80002c9e:	fffff097          	auipc	ra,0xfffff
    80002ca2:	9c4080e7          	jalr	-1596(ra) # 80001662 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002ca6:	70a2                	ld	ra,40(sp)
    80002ca8:	7402                	ld	s0,32(sp)
    80002caa:	64e2                	ld	s1,24(sp)
    80002cac:	6942                	ld	s2,16(sp)
    80002cae:	69a2                	ld	s3,8(sp)
    80002cb0:	6a02                	ld	s4,0(sp)
    80002cb2:	6145                	addi	sp,sp,48
    80002cb4:	8082                	ret
    memmove((char *)dst, src, len);
    80002cb6:	000a061b          	sext.w	a2,s4
    80002cba:	85ce                	mv	a1,s3
    80002cbc:	854a                	mv	a0,s2
    80002cbe:	ffffe097          	auipc	ra,0xffffe
    80002cc2:	06a080e7          	jalr	106(ra) # 80000d28 <memmove>
    return 0;
    80002cc6:	8526                	mv	a0,s1
    80002cc8:	bff9                	j	80002ca6 <either_copyout+0x32>

0000000080002cca <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002cca:	7179                	addi	sp,sp,-48
    80002ccc:	f406                	sd	ra,40(sp)
    80002cce:	f022                	sd	s0,32(sp)
    80002cd0:	ec26                	sd	s1,24(sp)
    80002cd2:	e84a                	sd	s2,16(sp)
    80002cd4:	e44e                	sd	s3,8(sp)
    80002cd6:	e052                	sd	s4,0(sp)
    80002cd8:	1800                	addi	s0,sp,48
    80002cda:	892a                	mv	s2,a0
    80002cdc:	84ae                	mv	s1,a1
    80002cde:	89b2                	mv	s3,a2
    80002ce0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002ce2:	fffff097          	auipc	ra,0xfffff
    80002ce6:	d3c080e7          	jalr	-708(ra) # 80001a1e <myproc>
  if(user_src){
    80002cea:	c08d                	beqz	s1,80002d0c <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002cec:	86d2                	mv	a3,s4
    80002cee:	864e                	mv	a2,s3
    80002cf0:	85ca                	mv	a1,s2
    80002cf2:	7128                	ld	a0,96(a0)
    80002cf4:	fffff097          	auipc	ra,0xfffff
    80002cf8:	9fa080e7          	jalr	-1542(ra) # 800016ee <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002cfc:	70a2                	ld	ra,40(sp)
    80002cfe:	7402                	ld	s0,32(sp)
    80002d00:	64e2                	ld	s1,24(sp)
    80002d02:	6942                	ld	s2,16(sp)
    80002d04:	69a2                	ld	s3,8(sp)
    80002d06:	6a02                	ld	s4,0(sp)
    80002d08:	6145                	addi	sp,sp,48
    80002d0a:	8082                	ret
    memmove(dst, (char*)src, len);
    80002d0c:	000a061b          	sext.w	a2,s4
    80002d10:	85ce                	mv	a1,s3
    80002d12:	854a                	mv	a0,s2
    80002d14:	ffffe097          	auipc	ra,0xffffe
    80002d18:	014080e7          	jalr	20(ra) # 80000d28 <memmove>
    return 0;
    80002d1c:	8526                	mv	a0,s1
    80002d1e:	bff9                	j	80002cfc <either_copyin+0x32>

0000000080002d20 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002d20:	715d                	addi	sp,sp,-80
    80002d22:	e486                	sd	ra,72(sp)
    80002d24:	e0a2                	sd	s0,64(sp)
    80002d26:	fc26                	sd	s1,56(sp)
    80002d28:	f84a                	sd	s2,48(sp)
    80002d2a:	f44e                	sd	s3,40(sp)
    80002d2c:	f052                	sd	s4,32(sp)
    80002d2e:	ec56                	sd	s5,24(sp)
    80002d30:	e85a                	sd	s6,16(sp)
    80002d32:	e45e                	sd	s7,8(sp)
    80002d34:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002d36:	00005517          	auipc	a0,0x5
    80002d3a:	39250513          	addi	a0,a0,914 # 800080c8 <digits+0x88>
    80002d3e:	ffffe097          	auipc	ra,0xffffe
    80002d42:	846080e7          	jalr	-1978(ra) # 80000584 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002d46:	0000f497          	auipc	s1,0xf
    80002d4a:	e7a48493          	addi	s1,s1,-390 # 80011bc0 <proc+0x168>
    80002d4e:	00015917          	auipc	s2,0x15
    80002d52:	c7290913          	addi	s2,s2,-910 # 800179c0 <bcache+0x150>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002d56:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002d58:	00005997          	auipc	s3,0x5
    80002d5c:	61898993          	addi	s3,s3,1560 # 80008370 <digits+0x330>
    printf("%d %s %s", p->pid, state, p->name);
    80002d60:	00005a97          	auipc	s5,0x5
    80002d64:	618a8a93          	addi	s5,s5,1560 # 80008378 <digits+0x338>
    printf("\n");
    80002d68:	00005a17          	auipc	s4,0x5
    80002d6c:	360a0a13          	addi	s4,s4,864 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002d70:	00005b97          	auipc	s7,0x5
    80002d74:	640b8b93          	addi	s7,s7,1600 # 800083b0 <states.0>
    80002d78:	a00d                	j	80002d9a <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002d7a:	ec86a583          	lw	a1,-312(a3)
    80002d7e:	8556                	mv	a0,s5
    80002d80:	ffffe097          	auipc	ra,0xffffe
    80002d84:	804080e7          	jalr	-2044(ra) # 80000584 <printf>
    printf("\n");
    80002d88:	8552                	mv	a0,s4
    80002d8a:	ffffd097          	auipc	ra,0xffffd
    80002d8e:	7fa080e7          	jalr	2042(ra) # 80000584 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002d92:	17848493          	addi	s1,s1,376
    80002d96:	03248263          	beq	s1,s2,80002dba <procdump+0x9a>
    if(p->state == UNUSED)
    80002d9a:	86a6                	mv	a3,s1
    80002d9c:	eb04a783          	lw	a5,-336(s1)
    80002da0:	dbed                	beqz	a5,80002d92 <procdump+0x72>
      state = "???";
    80002da2:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002da4:	fcfb6be3          	bltu	s6,a5,80002d7a <procdump+0x5a>
    80002da8:	02079713          	slli	a4,a5,0x20
    80002dac:	01d75793          	srli	a5,a4,0x1d
    80002db0:	97de                	add	a5,a5,s7
    80002db2:	6390                	ld	a2,0(a5)
    80002db4:	f279                	bnez	a2,80002d7a <procdump+0x5a>
      state = "???";
    80002db6:	864e                	mv	a2,s3
    80002db8:	b7c9                	j	80002d7a <procdump+0x5a>
  }
}
    80002dba:	60a6                	ld	ra,72(sp)
    80002dbc:	6406                	ld	s0,64(sp)
    80002dbe:	74e2                	ld	s1,56(sp)
    80002dc0:	7942                	ld	s2,48(sp)
    80002dc2:	79a2                	ld	s3,40(sp)
    80002dc4:	7a02                	ld	s4,32(sp)
    80002dc6:	6ae2                	ld	s5,24(sp)
    80002dc8:	6b42                	ld	s6,16(sp)
    80002dca:	6ba2                	ld	s7,8(sp)
    80002dcc:	6161                	addi	sp,sp,80
    80002dce:	8082                	ret

0000000080002dd0 <swtch>:
    80002dd0:	00153023          	sd	ra,0(a0)
    80002dd4:	00253423          	sd	sp,8(a0)
    80002dd8:	e900                	sd	s0,16(a0)
    80002dda:	ed04                	sd	s1,24(a0)
    80002ddc:	03253023          	sd	s2,32(a0)
    80002de0:	03353423          	sd	s3,40(a0)
    80002de4:	03453823          	sd	s4,48(a0)
    80002de8:	03553c23          	sd	s5,56(a0)
    80002dec:	05653023          	sd	s6,64(a0)
    80002df0:	05753423          	sd	s7,72(a0)
    80002df4:	05853823          	sd	s8,80(a0)
    80002df8:	05953c23          	sd	s9,88(a0)
    80002dfc:	07a53023          	sd	s10,96(a0)
    80002e00:	07b53423          	sd	s11,104(a0)
    80002e04:	0005b083          	ld	ra,0(a1)
    80002e08:	0085b103          	ld	sp,8(a1)
    80002e0c:	6980                	ld	s0,16(a1)
    80002e0e:	6d84                	ld	s1,24(a1)
    80002e10:	0205b903          	ld	s2,32(a1)
    80002e14:	0285b983          	ld	s3,40(a1)
    80002e18:	0305ba03          	ld	s4,48(a1)
    80002e1c:	0385ba83          	ld	s5,56(a1)
    80002e20:	0405bb03          	ld	s6,64(a1)
    80002e24:	0485bb83          	ld	s7,72(a1)
    80002e28:	0505bc03          	ld	s8,80(a1)
    80002e2c:	0585bc83          	ld	s9,88(a1)
    80002e30:	0605bd03          	ld	s10,96(a1)
    80002e34:	0685bd83          	ld	s11,104(a1)
    80002e38:	8082                	ret

0000000080002e3a <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002e3a:	1141                	addi	sp,sp,-16
    80002e3c:	e406                	sd	ra,8(sp)
    80002e3e:	e022                	sd	s0,0(sp)
    80002e40:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002e42:	00005597          	auipc	a1,0x5
    80002e46:	59e58593          	addi	a1,a1,1438 # 800083e0 <states.0+0x30>
    80002e4a:	00015517          	auipc	a0,0x15
    80002e4e:	a0e50513          	addi	a0,a0,-1522 # 80017858 <tickslock>
    80002e52:	ffffe097          	auipc	ra,0xffffe
    80002e56:	cee080e7          	jalr	-786(ra) # 80000b40 <initlock>
}
    80002e5a:	60a2                	ld	ra,8(sp)
    80002e5c:	6402                	ld	s0,0(sp)
    80002e5e:	0141                	addi	sp,sp,16
    80002e60:	8082                	ret

0000000080002e62 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002e62:	1141                	addi	sp,sp,-16
    80002e64:	e422                	sd	s0,8(sp)
    80002e66:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002e68:	00003797          	auipc	a5,0x3
    80002e6c:	63878793          	addi	a5,a5,1592 # 800064a0 <kernelvec>
    80002e70:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002e74:	6422                	ld	s0,8(sp)
    80002e76:	0141                	addi	sp,sp,16
    80002e78:	8082                	ret

0000000080002e7a <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002e7a:	1141                	addi	sp,sp,-16
    80002e7c:	e406                	sd	ra,8(sp)
    80002e7e:	e022                	sd	s0,0(sp)
    80002e80:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002e82:	fffff097          	auipc	ra,0xfffff
    80002e86:	b9c080e7          	jalr	-1124(ra) # 80001a1e <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e8a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002e8e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002e90:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002e94:	00004697          	auipc	a3,0x4
    80002e98:	16c68693          	addi	a3,a3,364 # 80007000 <_trampoline>
    80002e9c:	00004717          	auipc	a4,0x4
    80002ea0:	16470713          	addi	a4,a4,356 # 80007000 <_trampoline>
    80002ea4:	8f15                	sub	a4,a4,a3
    80002ea6:	040007b7          	lui	a5,0x4000
    80002eaa:	17fd                	addi	a5,a5,-1
    80002eac:	07b2                	slli	a5,a5,0xc
    80002eae:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002eb0:	10571073          	csrw	stvec,a4

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002eb4:	7538                	ld	a4,104(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002eb6:	18002673          	csrr	a2,satp
    80002eba:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002ebc:	7530                	ld	a2,104(a0)
    80002ebe:	6938                	ld	a4,80(a0)
    80002ec0:	6585                	lui	a1,0x1
    80002ec2:	972e                	add	a4,a4,a1
    80002ec4:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002ec6:	7538                	ld	a4,104(a0)
    80002ec8:	00000617          	auipc	a2,0x0
    80002ecc:	13860613          	addi	a2,a2,312 # 80003000 <usertrap>
    80002ed0:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002ed2:	7538                	ld	a4,104(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002ed4:	8612                	mv	a2,tp
    80002ed6:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ed8:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002edc:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002ee0:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ee4:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002ee8:	7538                	ld	a4,104(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002eea:	6f18                	ld	a4,24(a4)
    80002eec:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002ef0:	712c                	ld	a1,96(a0)
    80002ef2:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002ef4:	00004717          	auipc	a4,0x4
    80002ef8:	19c70713          	addi	a4,a4,412 # 80007090 <userret>
    80002efc:	8f15                	sub	a4,a4,a3
    80002efe:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002f00:	577d                	li	a4,-1
    80002f02:	177e                	slli	a4,a4,0x3f
    80002f04:	8dd9                	or	a1,a1,a4
    80002f06:	02000537          	lui	a0,0x2000
    80002f0a:	157d                	addi	a0,a0,-1
    80002f0c:	0536                	slli	a0,a0,0xd
    80002f0e:	9782                	jalr	a5
}
    80002f10:	60a2                	ld	ra,8(sp)
    80002f12:	6402                	ld	s0,0(sp)
    80002f14:	0141                	addi	sp,sp,16
    80002f16:	8082                	ret

0000000080002f18 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002f18:	1101                	addi	sp,sp,-32
    80002f1a:	ec06                	sd	ra,24(sp)
    80002f1c:	e822                	sd	s0,16(sp)
    80002f1e:	e426                	sd	s1,8(sp)
    80002f20:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002f22:	00015497          	auipc	s1,0x15
    80002f26:	93648493          	addi	s1,s1,-1738 # 80017858 <tickslock>
    80002f2a:	8526                	mv	a0,s1
    80002f2c:	ffffe097          	auipc	ra,0xffffe
    80002f30:	ca4080e7          	jalr	-860(ra) # 80000bd0 <acquire>
  ticks++;
    80002f34:	00006517          	auipc	a0,0x6
    80002f38:	10c50513          	addi	a0,a0,268 # 80009040 <ticks>
    80002f3c:	411c                	lw	a5,0(a0)
    80002f3e:	2785                	addiw	a5,a5,1
    80002f40:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002f42:	00000097          	auipc	ra,0x0
    80002f46:	a24080e7          	jalr	-1500(ra) # 80002966 <wakeup>
  release(&tickslock);
    80002f4a:	8526                	mv	a0,s1
    80002f4c:	ffffe097          	auipc	ra,0xffffe
    80002f50:	d38080e7          	jalr	-712(ra) # 80000c84 <release>
}
    80002f54:	60e2                	ld	ra,24(sp)
    80002f56:	6442                	ld	s0,16(sp)
    80002f58:	64a2                	ld	s1,8(sp)
    80002f5a:	6105                	addi	sp,sp,32
    80002f5c:	8082                	ret

0000000080002f5e <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002f5e:	1101                	addi	sp,sp,-32
    80002f60:	ec06                	sd	ra,24(sp)
    80002f62:	e822                	sd	s0,16(sp)
    80002f64:	e426                	sd	s1,8(sp)
    80002f66:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002f68:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002f6c:	00074d63          	bltz	a4,80002f86 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002f70:	57fd                	li	a5,-1
    80002f72:	17fe                	slli	a5,a5,0x3f
    80002f74:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002f76:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002f78:	06f70363          	beq	a4,a5,80002fde <devintr+0x80>
  }
}
    80002f7c:	60e2                	ld	ra,24(sp)
    80002f7e:	6442                	ld	s0,16(sp)
    80002f80:	64a2                	ld	s1,8(sp)
    80002f82:	6105                	addi	sp,sp,32
    80002f84:	8082                	ret
     (scause & 0xff) == 9){
    80002f86:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    80002f8a:	46a5                	li	a3,9
    80002f8c:	fed792e3          	bne	a5,a3,80002f70 <devintr+0x12>
    int irq = plic_claim();
    80002f90:	00003097          	auipc	ra,0x3
    80002f94:	618080e7          	jalr	1560(ra) # 800065a8 <plic_claim>
    80002f98:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002f9a:	47a9                	li	a5,10
    80002f9c:	02f50763          	beq	a0,a5,80002fca <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002fa0:	4785                	li	a5,1
    80002fa2:	02f50963          	beq	a0,a5,80002fd4 <devintr+0x76>
    return 1;
    80002fa6:	4505                	li	a0,1
    } else if(irq){
    80002fa8:	d8f1                	beqz	s1,80002f7c <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002faa:	85a6                	mv	a1,s1
    80002fac:	00005517          	auipc	a0,0x5
    80002fb0:	43c50513          	addi	a0,a0,1084 # 800083e8 <states.0+0x38>
    80002fb4:	ffffd097          	auipc	ra,0xffffd
    80002fb8:	5d0080e7          	jalr	1488(ra) # 80000584 <printf>
      plic_complete(irq);
    80002fbc:	8526                	mv	a0,s1
    80002fbe:	00003097          	auipc	ra,0x3
    80002fc2:	60e080e7          	jalr	1550(ra) # 800065cc <plic_complete>
    return 1;
    80002fc6:	4505                	li	a0,1
    80002fc8:	bf55                	j	80002f7c <devintr+0x1e>
      uartintr();
    80002fca:	ffffe097          	auipc	ra,0xffffe
    80002fce:	9c8080e7          	jalr	-1592(ra) # 80000992 <uartintr>
    80002fd2:	b7ed                	j	80002fbc <devintr+0x5e>
      virtio_disk_intr();
    80002fd4:	00004097          	auipc	ra,0x4
    80002fd8:	a84080e7          	jalr	-1404(ra) # 80006a58 <virtio_disk_intr>
    80002fdc:	b7c5                	j	80002fbc <devintr+0x5e>
    if(cpuid() == 0){
    80002fde:	fffff097          	auipc	ra,0xfffff
    80002fe2:	a14080e7          	jalr	-1516(ra) # 800019f2 <cpuid>
    80002fe6:	c901                	beqz	a0,80002ff6 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002fe8:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002fec:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002fee:	14479073          	csrw	sip,a5
    return 2;
    80002ff2:	4509                	li	a0,2
    80002ff4:	b761                	j	80002f7c <devintr+0x1e>
      clockintr();
    80002ff6:	00000097          	auipc	ra,0x0
    80002ffa:	f22080e7          	jalr	-222(ra) # 80002f18 <clockintr>
    80002ffe:	b7ed                	j	80002fe8 <devintr+0x8a>

0000000080003000 <usertrap>:
{
    80003000:	1101                	addi	sp,sp,-32
    80003002:	ec06                	sd	ra,24(sp)
    80003004:	e822                	sd	s0,16(sp)
    80003006:	e426                	sd	s1,8(sp)
    80003008:	e04a                	sd	s2,0(sp)
    8000300a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000300c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80003010:	1007f793          	andi	a5,a5,256
    80003014:	e3ad                	bnez	a5,80003076 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003016:	00003797          	auipc	a5,0x3
    8000301a:	48a78793          	addi	a5,a5,1162 # 800064a0 <kernelvec>
    8000301e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80003022:	fffff097          	auipc	ra,0xfffff
    80003026:	9fc080e7          	jalr	-1540(ra) # 80001a1e <myproc>
    8000302a:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000302c:	753c                	ld	a5,104(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000302e:	14102773          	csrr	a4,sepc
    80003032:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003034:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80003038:	47a1                	li	a5,8
    8000303a:	04f71c63          	bne	a4,a5,80003092 <usertrap+0x92>
    if(p->killed)
    8000303e:	551c                	lw	a5,40(a0)
    80003040:	e3b9                	bnez	a5,80003086 <usertrap+0x86>
    p->trapframe->epc += 4;
    80003042:	74b8                	ld	a4,104(s1)
    80003044:	6f1c                	ld	a5,24(a4)
    80003046:	0791                	addi	a5,a5,4
    80003048:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000304a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000304e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003052:	10079073          	csrw	sstatus,a5
    syscall();
    80003056:	00000097          	auipc	ra,0x0
    8000305a:	2e0080e7          	jalr	736(ra) # 80003336 <syscall>
  if(p->killed)
    8000305e:	549c                	lw	a5,40(s1)
    80003060:	ebc1                	bnez	a5,800030f0 <usertrap+0xf0>
  usertrapret();
    80003062:	00000097          	auipc	ra,0x0
    80003066:	e18080e7          	jalr	-488(ra) # 80002e7a <usertrapret>
}
    8000306a:	60e2                	ld	ra,24(sp)
    8000306c:	6442                	ld	s0,16(sp)
    8000306e:	64a2                	ld	s1,8(sp)
    80003070:	6902                	ld	s2,0(sp)
    80003072:	6105                	addi	sp,sp,32
    80003074:	8082                	ret
    panic("usertrap: not from user mode");
    80003076:	00005517          	auipc	a0,0x5
    8000307a:	39250513          	addi	a0,a0,914 # 80008408 <states.0+0x58>
    8000307e:	ffffd097          	auipc	ra,0xffffd
    80003082:	4bc080e7          	jalr	1212(ra) # 8000053a <panic>
      exit(-1);
    80003086:	557d                	li	a0,-1
    80003088:	00000097          	auipc	ra,0x0
    8000308c:	a4e080e7          	jalr	-1458(ra) # 80002ad6 <exit>
    80003090:	bf4d                	j	80003042 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80003092:	00000097          	auipc	ra,0x0
    80003096:	ecc080e7          	jalr	-308(ra) # 80002f5e <devintr>
    8000309a:	892a                	mv	s2,a0
    8000309c:	c501                	beqz	a0,800030a4 <usertrap+0xa4>
  if(p->killed)
    8000309e:	549c                	lw	a5,40(s1)
    800030a0:	c3a1                	beqz	a5,800030e0 <usertrap+0xe0>
    800030a2:	a815                	j	800030d6 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800030a4:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800030a8:	5890                	lw	a2,48(s1)
    800030aa:	00005517          	auipc	a0,0x5
    800030ae:	37e50513          	addi	a0,a0,894 # 80008428 <states.0+0x78>
    800030b2:	ffffd097          	auipc	ra,0xffffd
    800030b6:	4d2080e7          	jalr	1234(ra) # 80000584 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800030ba:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800030be:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800030c2:	00005517          	auipc	a0,0x5
    800030c6:	39650513          	addi	a0,a0,918 # 80008458 <states.0+0xa8>
    800030ca:	ffffd097          	auipc	ra,0xffffd
    800030ce:	4ba080e7          	jalr	1210(ra) # 80000584 <printf>
    p->killed = 1;
    800030d2:	4785                	li	a5,1
    800030d4:	d49c                	sw	a5,40(s1)
    exit(-1);
    800030d6:	557d                	li	a0,-1
    800030d8:	00000097          	auipc	ra,0x0
    800030dc:	9fe080e7          	jalr	-1538(ra) # 80002ad6 <exit>
  if(which_dev == 2)
    800030e0:	4789                	li	a5,2
    800030e2:	f8f910e3          	bne	s2,a5,80003062 <usertrap+0x62>
    yield();
    800030e6:	fffff097          	auipc	ra,0xfffff
    800030ea:	35c080e7          	jalr	860(ra) # 80002442 <yield>
    800030ee:	bf95                	j	80003062 <usertrap+0x62>
  int which_dev = 0;
    800030f0:	4901                	li	s2,0
    800030f2:	b7d5                	j	800030d6 <usertrap+0xd6>

00000000800030f4 <kerneltrap>:
{
    800030f4:	7179                	addi	sp,sp,-48
    800030f6:	f406                	sd	ra,40(sp)
    800030f8:	f022                	sd	s0,32(sp)
    800030fa:	ec26                	sd	s1,24(sp)
    800030fc:	e84a                	sd	s2,16(sp)
    800030fe:	e44e                	sd	s3,8(sp)
    80003100:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003102:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003106:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000310a:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000310e:	1004f793          	andi	a5,s1,256
    80003112:	cb85                	beqz	a5,80003142 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003114:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80003118:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000311a:	ef85                	bnez	a5,80003152 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    8000311c:	00000097          	auipc	ra,0x0
    80003120:	e42080e7          	jalr	-446(ra) # 80002f5e <devintr>
    80003124:	cd1d                	beqz	a0,80003162 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80003126:	4789                	li	a5,2
    80003128:	06f50a63          	beq	a0,a5,8000319c <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000312c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003130:	10049073          	csrw	sstatus,s1
}
    80003134:	70a2                	ld	ra,40(sp)
    80003136:	7402                	ld	s0,32(sp)
    80003138:	64e2                	ld	s1,24(sp)
    8000313a:	6942                	ld	s2,16(sp)
    8000313c:	69a2                	ld	s3,8(sp)
    8000313e:	6145                	addi	sp,sp,48
    80003140:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80003142:	00005517          	auipc	a0,0x5
    80003146:	33650513          	addi	a0,a0,822 # 80008478 <states.0+0xc8>
    8000314a:	ffffd097          	auipc	ra,0xffffd
    8000314e:	3f0080e7          	jalr	1008(ra) # 8000053a <panic>
    panic("kerneltrap: interrupts enabled");
    80003152:	00005517          	auipc	a0,0x5
    80003156:	34e50513          	addi	a0,a0,846 # 800084a0 <states.0+0xf0>
    8000315a:	ffffd097          	auipc	ra,0xffffd
    8000315e:	3e0080e7          	jalr	992(ra) # 8000053a <panic>
    printf("scause %p\n", scause);
    80003162:	85ce                	mv	a1,s3
    80003164:	00005517          	auipc	a0,0x5
    80003168:	35c50513          	addi	a0,a0,860 # 800084c0 <states.0+0x110>
    8000316c:	ffffd097          	auipc	ra,0xffffd
    80003170:	418080e7          	jalr	1048(ra) # 80000584 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003174:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003178:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000317c:	00005517          	auipc	a0,0x5
    80003180:	35450513          	addi	a0,a0,852 # 800084d0 <states.0+0x120>
    80003184:	ffffd097          	auipc	ra,0xffffd
    80003188:	400080e7          	jalr	1024(ra) # 80000584 <printf>
    panic("kerneltrap");
    8000318c:	00005517          	auipc	a0,0x5
    80003190:	35c50513          	addi	a0,a0,860 # 800084e8 <states.0+0x138>
    80003194:	ffffd097          	auipc	ra,0xffffd
    80003198:	3a6080e7          	jalr	934(ra) # 8000053a <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000319c:	fffff097          	auipc	ra,0xfffff
    800031a0:	882080e7          	jalr	-1918(ra) # 80001a1e <myproc>
    800031a4:	d541                	beqz	a0,8000312c <kerneltrap+0x38>
    800031a6:	fffff097          	auipc	ra,0xfffff
    800031aa:	878080e7          	jalr	-1928(ra) # 80001a1e <myproc>
    800031ae:	4d18                	lw	a4,24(a0)
    800031b0:	4791                	li	a5,4
    800031b2:	f6f71de3          	bne	a4,a5,8000312c <kerneltrap+0x38>
    yield();
    800031b6:	fffff097          	auipc	ra,0xfffff
    800031ba:	28c080e7          	jalr	652(ra) # 80002442 <yield>
    800031be:	b7bd                	j	8000312c <kerneltrap+0x38>

00000000800031c0 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800031c0:	1101                	addi	sp,sp,-32
    800031c2:	ec06                	sd	ra,24(sp)
    800031c4:	e822                	sd	s0,16(sp)
    800031c6:	e426                	sd	s1,8(sp)
    800031c8:	1000                	addi	s0,sp,32
    800031ca:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800031cc:	fffff097          	auipc	ra,0xfffff
    800031d0:	852080e7          	jalr	-1966(ra) # 80001a1e <myproc>
  switch (n) {
    800031d4:	4795                	li	a5,5
    800031d6:	0497e163          	bltu	a5,s1,80003218 <argraw+0x58>
    800031da:	048a                	slli	s1,s1,0x2
    800031dc:	00005717          	auipc	a4,0x5
    800031e0:	34470713          	addi	a4,a4,836 # 80008520 <states.0+0x170>
    800031e4:	94ba                	add	s1,s1,a4
    800031e6:	409c                	lw	a5,0(s1)
    800031e8:	97ba                	add	a5,a5,a4
    800031ea:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800031ec:	753c                	ld	a5,104(a0)
    800031ee:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800031f0:	60e2                	ld	ra,24(sp)
    800031f2:	6442                	ld	s0,16(sp)
    800031f4:	64a2                	ld	s1,8(sp)
    800031f6:	6105                	addi	sp,sp,32
    800031f8:	8082                	ret
    return p->trapframe->a1;
    800031fa:	753c                	ld	a5,104(a0)
    800031fc:	7fa8                	ld	a0,120(a5)
    800031fe:	bfcd                	j	800031f0 <argraw+0x30>
    return p->trapframe->a2;
    80003200:	753c                	ld	a5,104(a0)
    80003202:	63c8                	ld	a0,128(a5)
    80003204:	b7f5                	j	800031f0 <argraw+0x30>
    return p->trapframe->a3;
    80003206:	753c                	ld	a5,104(a0)
    80003208:	67c8                	ld	a0,136(a5)
    8000320a:	b7dd                	j	800031f0 <argraw+0x30>
    return p->trapframe->a4;
    8000320c:	753c                	ld	a5,104(a0)
    8000320e:	6bc8                	ld	a0,144(a5)
    80003210:	b7c5                	j	800031f0 <argraw+0x30>
    return p->trapframe->a5;
    80003212:	753c                	ld	a5,104(a0)
    80003214:	6fc8                	ld	a0,152(a5)
    80003216:	bfe9                	j	800031f0 <argraw+0x30>
  panic("argraw");
    80003218:	00005517          	auipc	a0,0x5
    8000321c:	2e050513          	addi	a0,a0,736 # 800084f8 <states.0+0x148>
    80003220:	ffffd097          	auipc	ra,0xffffd
    80003224:	31a080e7          	jalr	794(ra) # 8000053a <panic>

0000000080003228 <fetchaddr>:
{
    80003228:	1101                	addi	sp,sp,-32
    8000322a:	ec06                	sd	ra,24(sp)
    8000322c:	e822                	sd	s0,16(sp)
    8000322e:	e426                	sd	s1,8(sp)
    80003230:	e04a                	sd	s2,0(sp)
    80003232:	1000                	addi	s0,sp,32
    80003234:	84aa                	mv	s1,a0
    80003236:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003238:	ffffe097          	auipc	ra,0xffffe
    8000323c:	7e6080e7          	jalr	2022(ra) # 80001a1e <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80003240:	6d3c                	ld	a5,88(a0)
    80003242:	02f4f863          	bgeu	s1,a5,80003272 <fetchaddr+0x4a>
    80003246:	00848713          	addi	a4,s1,8
    8000324a:	02e7e663          	bltu	a5,a4,80003276 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000324e:	46a1                	li	a3,8
    80003250:	8626                	mv	a2,s1
    80003252:	85ca                	mv	a1,s2
    80003254:	7128                	ld	a0,96(a0)
    80003256:	ffffe097          	auipc	ra,0xffffe
    8000325a:	498080e7          	jalr	1176(ra) # 800016ee <copyin>
    8000325e:	00a03533          	snez	a0,a0
    80003262:	40a00533          	neg	a0,a0
}
    80003266:	60e2                	ld	ra,24(sp)
    80003268:	6442                	ld	s0,16(sp)
    8000326a:	64a2                	ld	s1,8(sp)
    8000326c:	6902                	ld	s2,0(sp)
    8000326e:	6105                	addi	sp,sp,32
    80003270:	8082                	ret
    return -1;
    80003272:	557d                	li	a0,-1
    80003274:	bfcd                	j	80003266 <fetchaddr+0x3e>
    80003276:	557d                	li	a0,-1
    80003278:	b7fd                	j	80003266 <fetchaddr+0x3e>

000000008000327a <fetchstr>:
{
    8000327a:	7179                	addi	sp,sp,-48
    8000327c:	f406                	sd	ra,40(sp)
    8000327e:	f022                	sd	s0,32(sp)
    80003280:	ec26                	sd	s1,24(sp)
    80003282:	e84a                	sd	s2,16(sp)
    80003284:	e44e                	sd	s3,8(sp)
    80003286:	1800                	addi	s0,sp,48
    80003288:	892a                	mv	s2,a0
    8000328a:	84ae                	mv	s1,a1
    8000328c:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    8000328e:	ffffe097          	auipc	ra,0xffffe
    80003292:	790080e7          	jalr	1936(ra) # 80001a1e <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80003296:	86ce                	mv	a3,s3
    80003298:	864a                	mv	a2,s2
    8000329a:	85a6                	mv	a1,s1
    8000329c:	7128                	ld	a0,96(a0)
    8000329e:	ffffe097          	auipc	ra,0xffffe
    800032a2:	4de080e7          	jalr	1246(ra) # 8000177c <copyinstr>
  if(err < 0)
    800032a6:	00054763          	bltz	a0,800032b4 <fetchstr+0x3a>
  return strlen(buf);
    800032aa:	8526                	mv	a0,s1
    800032ac:	ffffe097          	auipc	ra,0xffffe
    800032b0:	b9c080e7          	jalr	-1124(ra) # 80000e48 <strlen>
}
    800032b4:	70a2                	ld	ra,40(sp)
    800032b6:	7402                	ld	s0,32(sp)
    800032b8:	64e2                	ld	s1,24(sp)
    800032ba:	6942                	ld	s2,16(sp)
    800032bc:	69a2                	ld	s3,8(sp)
    800032be:	6145                	addi	sp,sp,48
    800032c0:	8082                	ret

00000000800032c2 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    800032c2:	1101                	addi	sp,sp,-32
    800032c4:	ec06                	sd	ra,24(sp)
    800032c6:	e822                	sd	s0,16(sp)
    800032c8:	e426                	sd	s1,8(sp)
    800032ca:	1000                	addi	s0,sp,32
    800032cc:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800032ce:	00000097          	auipc	ra,0x0
    800032d2:	ef2080e7          	jalr	-270(ra) # 800031c0 <argraw>
    800032d6:	c088                	sw	a0,0(s1)
  return 0;
}
    800032d8:	4501                	li	a0,0
    800032da:	60e2                	ld	ra,24(sp)
    800032dc:	6442                	ld	s0,16(sp)
    800032de:	64a2                	ld	s1,8(sp)
    800032e0:	6105                	addi	sp,sp,32
    800032e2:	8082                	ret

00000000800032e4 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    800032e4:	1101                	addi	sp,sp,-32
    800032e6:	ec06                	sd	ra,24(sp)
    800032e8:	e822                	sd	s0,16(sp)
    800032ea:	e426                	sd	s1,8(sp)
    800032ec:	1000                	addi	s0,sp,32
    800032ee:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800032f0:	00000097          	auipc	ra,0x0
    800032f4:	ed0080e7          	jalr	-304(ra) # 800031c0 <argraw>
    800032f8:	e088                	sd	a0,0(s1)
  return 0;
}
    800032fa:	4501                	li	a0,0
    800032fc:	60e2                	ld	ra,24(sp)
    800032fe:	6442                	ld	s0,16(sp)
    80003300:	64a2                	ld	s1,8(sp)
    80003302:	6105                	addi	sp,sp,32
    80003304:	8082                	ret

0000000080003306 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80003306:	1101                	addi	sp,sp,-32
    80003308:	ec06                	sd	ra,24(sp)
    8000330a:	e822                	sd	s0,16(sp)
    8000330c:	e426                	sd	s1,8(sp)
    8000330e:	e04a                	sd	s2,0(sp)
    80003310:	1000                	addi	s0,sp,32
    80003312:	84ae                	mv	s1,a1
    80003314:	8932                	mv	s2,a2
  *ip = argraw(n);
    80003316:	00000097          	auipc	ra,0x0
    8000331a:	eaa080e7          	jalr	-342(ra) # 800031c0 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    8000331e:	864a                	mv	a2,s2
    80003320:	85a6                	mv	a1,s1
    80003322:	00000097          	auipc	ra,0x0
    80003326:	f58080e7          	jalr	-168(ra) # 8000327a <fetchstr>
}
    8000332a:	60e2                	ld	ra,24(sp)
    8000332c:	6442                	ld	s0,16(sp)
    8000332e:	64a2                	ld	s1,8(sp)
    80003330:	6902                	ld	s2,0(sp)
    80003332:	6105                	addi	sp,sp,32
    80003334:	8082                	ret

0000000080003336 <syscall>:
[SYS_tget]    sys_tget,
};

void
syscall(void)
{
    80003336:	1101                	addi	sp,sp,-32
    80003338:	ec06                	sd	ra,24(sp)
    8000333a:	e822                	sd	s0,16(sp)
    8000333c:	e426                	sd	s1,8(sp)
    8000333e:	e04a                	sd	s2,0(sp)
    80003340:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80003342:	ffffe097          	auipc	ra,0xffffe
    80003346:	6dc080e7          	jalr	1756(ra) # 80001a1e <myproc>
    8000334a:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000334c:	06853903          	ld	s2,104(a0)
    80003350:	0a893783          	ld	a5,168(s2)
    80003354:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003358:	37fd                	addiw	a5,a5,-1
    8000335a:	4765                	li	a4,25
    8000335c:	00f76f63          	bltu	a4,a5,8000337a <syscall+0x44>
    80003360:	00369713          	slli	a4,a3,0x3
    80003364:	00005797          	auipc	a5,0x5
    80003368:	1d478793          	addi	a5,a5,468 # 80008538 <syscalls>
    8000336c:	97ba                	add	a5,a5,a4
    8000336e:	639c                	ld	a5,0(a5)
    80003370:	c789                	beqz	a5,8000337a <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80003372:	9782                	jalr	a5
    80003374:	06a93823          	sd	a0,112(s2)
    80003378:	a839                	j	80003396 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    8000337a:	16848613          	addi	a2,s1,360
    8000337e:	588c                	lw	a1,48(s1)
    80003380:	00005517          	auipc	a0,0x5
    80003384:	18050513          	addi	a0,a0,384 # 80008500 <states.0+0x150>
    80003388:	ffffd097          	auipc	ra,0xffffd
    8000338c:	1fc080e7          	jalr	508(ra) # 80000584 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80003390:	74bc                	ld	a5,104(s1)
    80003392:	577d                	li	a4,-1
    80003394:	fbb8                	sd	a4,112(a5)
  }
}
    80003396:	60e2                	ld	ra,24(sp)
    80003398:	6442                	ld	s0,16(sp)
    8000339a:	64a2                	ld	s1,8(sp)
    8000339c:	6902                	ld	s2,0(sp)
    8000339e:	6105                	addi	sp,sp,32
    800033a0:	8082                	ret

00000000800033a2 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800033a2:	1101                	addi	sp,sp,-32
    800033a4:	ec06                	sd	ra,24(sp)
    800033a6:	e822                	sd	s0,16(sp)
    800033a8:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    800033aa:	fec40593          	addi	a1,s0,-20
    800033ae:	4501                	li	a0,0
    800033b0:	00000097          	auipc	ra,0x0
    800033b4:	f12080e7          	jalr	-238(ra) # 800032c2 <argint>
    return -1;
    800033b8:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800033ba:	00054963          	bltz	a0,800033cc <sys_exit+0x2a>
  exit(n);
    800033be:	fec42503          	lw	a0,-20(s0)
    800033c2:	fffff097          	auipc	ra,0xfffff
    800033c6:	714080e7          	jalr	1812(ra) # 80002ad6 <exit>
  return 0;  // not reached
    800033ca:	4781                	li	a5,0
}
    800033cc:	853e                	mv	a0,a5
    800033ce:	60e2                	ld	ra,24(sp)
    800033d0:	6442                	ld	s0,16(sp)
    800033d2:	6105                	addi	sp,sp,32
    800033d4:	8082                	ret

00000000800033d6 <sys_getpid>:

uint64
sys_getpid(void)
{
    800033d6:	1141                	addi	sp,sp,-16
    800033d8:	e406                	sd	ra,8(sp)
    800033da:	e022                	sd	s0,0(sp)
    800033dc:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800033de:	ffffe097          	auipc	ra,0xffffe
    800033e2:	640080e7          	jalr	1600(ra) # 80001a1e <myproc>
}
    800033e6:	5908                	lw	a0,48(a0)
    800033e8:	60a2                	ld	ra,8(sp)
    800033ea:	6402                	ld	s0,0(sp)
    800033ec:	0141                	addi	sp,sp,16
    800033ee:	8082                	ret

00000000800033f0 <sys_fork>:

uint64
sys_fork(void)
{
    800033f0:	1141                	addi	sp,sp,-16
    800033f2:	e406                	sd	ra,8(sp)
    800033f4:	e022                	sd	s0,0(sp)
    800033f6:	0800                	addi	s0,sp,16
  return fork();
    800033f8:	fffff097          	auipc	ra,0xfffff
    800033fc:	c6a080e7          	jalr	-918(ra) # 80002062 <fork>
}
    80003400:	60a2                	ld	ra,8(sp)
    80003402:	6402                	ld	s0,0(sp)
    80003404:	0141                	addi	sp,sp,16
    80003406:	8082                	ret

0000000080003408 <sys_wait>:

uint64
sys_wait(void)
{
    80003408:	1101                	addi	sp,sp,-32
    8000340a:	ec06                	sd	ra,24(sp)
    8000340c:	e822                	sd	s0,16(sp)
    8000340e:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003410:	fe840593          	addi	a1,s0,-24
    80003414:	4501                	li	a0,0
    80003416:	00000097          	auipc	ra,0x0
    8000341a:	ece080e7          	jalr	-306(ra) # 800032e4 <argaddr>
    8000341e:	87aa                	mv	a5,a0
    return -1;
    80003420:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80003422:	0007c863          	bltz	a5,80003432 <sys_wait+0x2a>
  return wait(p);
    80003426:	fe843503          	ld	a0,-24(s0)
    8000342a:	fffff097          	auipc	ra,0xfffff
    8000342e:	2a8080e7          	jalr	680(ra) # 800026d2 <wait>
}
    80003432:	60e2                	ld	ra,24(sp)
    80003434:	6442                	ld	s0,16(sp)
    80003436:	6105                	addi	sp,sp,32
    80003438:	8082                	ret

000000008000343a <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000343a:	7179                	addi	sp,sp,-48
    8000343c:	f406                	sd	ra,40(sp)
    8000343e:	f022                	sd	s0,32(sp)
    80003440:	ec26                	sd	s1,24(sp)
    80003442:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80003444:	fdc40593          	addi	a1,s0,-36
    80003448:	4501                	li	a0,0
    8000344a:	00000097          	auipc	ra,0x0
    8000344e:	e78080e7          	jalr	-392(ra) # 800032c2 <argint>
    80003452:	87aa                	mv	a5,a0
    return -1;
    80003454:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80003456:	0207c063          	bltz	a5,80003476 <sys_sbrk+0x3c>
  addr = myproc()->sz;
    8000345a:	ffffe097          	auipc	ra,0xffffe
    8000345e:	5c4080e7          	jalr	1476(ra) # 80001a1e <myproc>
    80003462:	4d24                	lw	s1,88(a0)
  if(growproc(n) < 0)
    80003464:	fdc42503          	lw	a0,-36(s0)
    80003468:	fffff097          	auipc	ra,0xfffff
    8000346c:	b82080e7          	jalr	-1150(ra) # 80001fea <growproc>
    80003470:	00054863          	bltz	a0,80003480 <sys_sbrk+0x46>
    return -1;
  return addr;
    80003474:	8526                	mv	a0,s1
}
    80003476:	70a2                	ld	ra,40(sp)
    80003478:	7402                	ld	s0,32(sp)
    8000347a:	64e2                	ld	s1,24(sp)
    8000347c:	6145                	addi	sp,sp,48
    8000347e:	8082                	ret
    return -1;
    80003480:	557d                	li	a0,-1
    80003482:	bfd5                	j	80003476 <sys_sbrk+0x3c>

0000000080003484 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003484:	7139                	addi	sp,sp,-64
    80003486:	fc06                	sd	ra,56(sp)
    80003488:	f822                	sd	s0,48(sp)
    8000348a:	f426                	sd	s1,40(sp)
    8000348c:	f04a                	sd	s2,32(sp)
    8000348e:	ec4e                	sd	s3,24(sp)
    80003490:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80003492:	fcc40593          	addi	a1,s0,-52
    80003496:	4501                	li	a0,0
    80003498:	00000097          	auipc	ra,0x0
    8000349c:	e2a080e7          	jalr	-470(ra) # 800032c2 <argint>
    return -1;
    800034a0:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800034a2:	06054563          	bltz	a0,8000350c <sys_sleep+0x88>
  acquire(&tickslock);
    800034a6:	00014517          	auipc	a0,0x14
    800034aa:	3b250513          	addi	a0,a0,946 # 80017858 <tickslock>
    800034ae:	ffffd097          	auipc	ra,0xffffd
    800034b2:	722080e7          	jalr	1826(ra) # 80000bd0 <acquire>
  ticks0 = ticks;
    800034b6:	00006917          	auipc	s2,0x6
    800034ba:	b8a92903          	lw	s2,-1142(s2) # 80009040 <ticks>
  while(ticks - ticks0 < n){
    800034be:	fcc42783          	lw	a5,-52(s0)
    800034c2:	cf85                	beqz	a5,800034fa <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800034c4:	00014997          	auipc	s3,0x14
    800034c8:	39498993          	addi	s3,s3,916 # 80017858 <tickslock>
    800034cc:	00006497          	auipc	s1,0x6
    800034d0:	b7448493          	addi	s1,s1,-1164 # 80009040 <ticks>
    if(myproc()->killed){
    800034d4:	ffffe097          	auipc	ra,0xffffe
    800034d8:	54a080e7          	jalr	1354(ra) # 80001a1e <myproc>
    800034dc:	551c                	lw	a5,40(a0)
    800034de:	ef9d                	bnez	a5,8000351c <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    800034e0:	85ce                	mv	a1,s3
    800034e2:	8526                	mv	a0,s1
    800034e4:	fffff097          	auipc	ra,0xfffff
    800034e8:	f9a080e7          	jalr	-102(ra) # 8000247e <sleep>
  while(ticks - ticks0 < n){
    800034ec:	409c                	lw	a5,0(s1)
    800034ee:	412787bb          	subw	a5,a5,s2
    800034f2:	fcc42703          	lw	a4,-52(s0)
    800034f6:	fce7efe3          	bltu	a5,a4,800034d4 <sys_sleep+0x50>
  }
  release(&tickslock);
    800034fa:	00014517          	auipc	a0,0x14
    800034fe:	35e50513          	addi	a0,a0,862 # 80017858 <tickslock>
    80003502:	ffffd097          	auipc	ra,0xffffd
    80003506:	782080e7          	jalr	1922(ra) # 80000c84 <release>
  return 0;
    8000350a:	4781                	li	a5,0
}
    8000350c:	853e                	mv	a0,a5
    8000350e:	70e2                	ld	ra,56(sp)
    80003510:	7442                	ld	s0,48(sp)
    80003512:	74a2                	ld	s1,40(sp)
    80003514:	7902                	ld	s2,32(sp)
    80003516:	69e2                	ld	s3,24(sp)
    80003518:	6121                	addi	sp,sp,64
    8000351a:	8082                	ret
      release(&tickslock);
    8000351c:	00014517          	auipc	a0,0x14
    80003520:	33c50513          	addi	a0,a0,828 # 80017858 <tickslock>
    80003524:	ffffd097          	auipc	ra,0xffffd
    80003528:	760080e7          	jalr	1888(ra) # 80000c84 <release>
      return -1;
    8000352c:	57fd                	li	a5,-1
    8000352e:	bff9                	j	8000350c <sys_sleep+0x88>

0000000080003530 <sys_kill>:

uint64
sys_kill(void)
{
    80003530:	1101                	addi	sp,sp,-32
    80003532:	ec06                	sd	ra,24(sp)
    80003534:	e822                	sd	s0,16(sp)
    80003536:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80003538:	fec40593          	addi	a1,s0,-20
    8000353c:	4501                	li	a0,0
    8000353e:	00000097          	auipc	ra,0x0
    80003542:	d84080e7          	jalr	-636(ra) # 800032c2 <argint>
    80003546:	87aa                	mv	a5,a0
    return -1;
    80003548:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    8000354a:	0007c863          	bltz	a5,8000355a <sys_kill+0x2a>
  return kill(pid);
    8000354e:	fec42503          	lw	a0,-20(s0)
    80003552:	fffff097          	auipc	ra,0xfffff
    80003556:	686080e7          	jalr	1670(ra) # 80002bd8 <kill>
}
    8000355a:	60e2                	ld	ra,24(sp)
    8000355c:	6442                	ld	s0,16(sp)
    8000355e:	6105                	addi	sp,sp,32
    80003560:	8082                	ret

0000000080003562 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003562:	1101                	addi	sp,sp,-32
    80003564:	ec06                	sd	ra,24(sp)
    80003566:	e822                	sd	s0,16(sp)
    80003568:	e426                	sd	s1,8(sp)
    8000356a:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000356c:	00014517          	auipc	a0,0x14
    80003570:	2ec50513          	addi	a0,a0,748 # 80017858 <tickslock>
    80003574:	ffffd097          	auipc	ra,0xffffd
    80003578:	65c080e7          	jalr	1628(ra) # 80000bd0 <acquire>
  xticks = ticks;
    8000357c:	00006497          	auipc	s1,0x6
    80003580:	ac44a483          	lw	s1,-1340(s1) # 80009040 <ticks>
  release(&tickslock);
    80003584:	00014517          	auipc	a0,0x14
    80003588:	2d450513          	addi	a0,a0,724 # 80017858 <tickslock>
    8000358c:	ffffd097          	auipc	ra,0xffffd
    80003590:	6f8080e7          	jalr	1784(ra) # 80000c84 <release>
  return xticks;
}
    80003594:	02049513          	slli	a0,s1,0x20
    80003598:	9101                	srli	a0,a0,0x20
    8000359a:	60e2                	ld	ra,24(sp)
    8000359c:	6442                	ld	s0,16(sp)
    8000359e:	64a2                	ld	s1,8(sp)
    800035a0:	6105                	addi	sp,sp,32
    800035a2:	8082                	ret

00000000800035a4 <sys_waitstat>:

uint64
sys_waitstat(void)
{
    800035a4:	7179                	addi	sp,sp,-48
    800035a6:	f406                	sd	ra,40(sp)
    800035a8:	f022                	sd	s0,32(sp)
    800035aa:	1800                	addi	s0,sp,48
  uint64 p;
  uint64 ttime;
  uint64 running;
  if(argaddr(0, &p) < 0){
    800035ac:	fe840593          	addi	a1,s0,-24
    800035b0:	4501                	li	a0,0
    800035b2:	00000097          	auipc	ra,0x0
    800035b6:	d32080e7          	jalr	-718(ra) # 800032e4 <argaddr>
    return -1;
    800035ba:	57fd                	li	a5,-1
  if(argaddr(0, &p) < 0){
    800035bc:	04054163          	bltz	a0,800035fe <sys_waitstat+0x5a>
  }
  if(argaddr(1, &ttime) < 0) {
    800035c0:	fe040593          	addi	a1,s0,-32
    800035c4:	4505                	li	a0,1
    800035c6:	00000097          	auipc	ra,0x0
    800035ca:	d1e080e7          	jalr	-738(ra) # 800032e4 <argaddr>
     return -1;
    800035ce:	57fd                	li	a5,-1
  if(argaddr(1, &ttime) < 0) {
    800035d0:	02054763          	bltz	a0,800035fe <sys_waitstat+0x5a>
  }
  if(argaddr(2, &running) < 0){
    800035d4:	fd840593          	addi	a1,s0,-40
    800035d8:	4509                	li	a0,2
    800035da:	00000097          	auipc	ra,0x0
    800035de:	d0a080e7          	jalr	-758(ra) # 800032e4 <argaddr>
    return -1;
    800035e2:	57fd                	li	a5,-1
  if(argaddr(2, &running) < 0){
    800035e4:	00054d63          	bltz	a0,800035fe <sys_waitstat+0x5a>
  }
  return waitstat(p,ttime,running);
    800035e8:	fd843603          	ld	a2,-40(s0)
    800035ec:	fe043583          	ld	a1,-32(s0)
    800035f0:	fe843503          	ld	a0,-24(s0)
    800035f4:	fffff097          	auipc	ra,0xfffff
    800035f8:	206080e7          	jalr	518(ra) # 800027fa <waitstat>
    800035fc:	87aa                	mv	a5,a0
}
    800035fe:	853e                	mv	a0,a5
    80003600:	70a2                	ld	ra,40(sp)
    80003602:	7402                	ld	s0,32(sp)
    80003604:	6145                	addi	sp,sp,48
    80003606:	8082                	ret

0000000080003608 <sys_btput>:

uint64
sys_btput(void)
{
    80003608:	1101                	addi	sp,sp,-32
    8000360a:	ec06                	sd	ra,24(sp)
    8000360c:	e822                	sd	s0,16(sp)
    8000360e:	1000                	addi	s0,sp,32
  
  // if (tag == 0){
  //     return-1;
  // }
  
  if(argint(0,&tag)<0){
    80003610:	fec40593          	addi	a1,s0,-20
    80003614:	4501                	li	a0,0
    80003616:	00000097          	auipc	ra,0x0
    8000361a:	cac080e7          	jalr	-852(ra) # 800032c2 <argint>
    return-1;
    8000361e:	57fd                	li	a5,-1
  if(argint(0,&tag)<0){
    80003620:	02054563          	bltz	a0,8000364a <sys_btput+0x42>
  }
  

  if(argaddr(1,&message) < 0) {
    80003624:	fe040593          	addi	a1,s0,-32
    80003628:	4505                	li	a0,1
    8000362a:	00000097          	auipc	ra,0x0
    8000362e:	cba080e7          	jalr	-838(ra) # 800032e4 <argaddr>
      return -1;
    80003632:	57fd                	li	a5,-1
  if(argaddr(1,&message) < 0) {
    80003634:	00054b63          	bltz	a0,8000364a <sys_btput+0x42>
  }
  
  return btput(tag ,message);
    80003638:	fe043583          	ld	a1,-32(s0)
    8000363c:	fec42503          	lw	a0,-20(s0)
    80003640:	fffff097          	auipc	ra,0xfffff
    80003644:	ea2080e7          	jalr	-350(ra) # 800024e2 <btput>
    80003648:	87aa                	mv	a5,a0
}
    8000364a:	853e                	mv	a0,a5
    8000364c:	60e2                	ld	ra,24(sp)
    8000364e:	6442                	ld	s0,16(sp)
    80003650:	6105                	addi	sp,sp,32
    80003652:	8082                	ret

0000000080003654 <sys_tput>:

uint64
sys_tput(void)
{
    80003654:	1101                	addi	sp,sp,-32
    80003656:	ec06                	sd	ra,24(sp)
    80003658:	e822                	sd	s0,16(sp)
    8000365a:	1000                	addi	s0,sp,32
  int tag;
  uint64 message;

  if(argint(0,&tag) < 0) {
    8000365c:	fec40593          	addi	a1,s0,-20
    80003660:	4501                	li	a0,0
    80003662:	00000097          	auipc	ra,0x0
    80003666:	c60080e7          	jalr	-928(ra) # 800032c2 <argint>
      return -1;
    8000366a:	57fd                	li	a5,-1
  if(argint(0,&tag) < 0) {
    8000366c:	02054563          	bltz	a0,80003696 <sys_tput+0x42>
  }
  if(argaddr(1,&message) < 0) {
    80003670:	fe040593          	addi	a1,s0,-32
    80003674:	4505                	li	a0,1
    80003676:	00000097          	auipc	ra,0x0
    8000367a:	c6e080e7          	jalr	-914(ra) # 800032e4 <argaddr>
      return -1;
    8000367e:	57fd                	li	a5,-1
  if(argaddr(1,&message) < 0) {
    80003680:	00054b63          	bltz	a0,80003696 <sys_tput+0x42>
  }
  
  return tput(tag , message);
    80003684:	fe043583          	ld	a1,-32(s0)
    80003688:	fec42503          	lw	a0,-20(s0)
    8000368c:	ffffe097          	auipc	ra,0xffffe
    80003690:	462080e7          	jalr	1122(ra) # 80001aee <tput>
    80003694:	87aa                	mv	a5,a0
}
    80003696:	853e                	mv	a0,a5
    80003698:	60e2                	ld	ra,24(sp)
    8000369a:	6442                	ld	s0,16(sp)
    8000369c:	6105                	addi	sp,sp,32
    8000369e:	8082                	ret

00000000800036a0 <sys_btget>:

uint64
sys_btget(void)
{
    800036a0:	1101                	addi	sp,sp,-32
    800036a2:	ec06                	sd	ra,24(sp)
    800036a4:	e822                	sd	s0,16(sp)
    800036a6:	1000                	addi	s0,sp,32
  int tag;
  uint64 buf;

  if(argint(0,&tag) < 0) {
    800036a8:	fec40593          	addi	a1,s0,-20
    800036ac:	4501                	li	a0,0
    800036ae:	00000097          	auipc	ra,0x0
    800036b2:	c14080e7          	jalr	-1004(ra) # 800032c2 <argint>
      return -1;
    800036b6:	57fd                	li	a5,-1
  if(argint(0,&tag) < 0) {
    800036b8:	02054563          	bltz	a0,800036e2 <sys_btget+0x42>
  }
  if(argaddr(1,&buf) < 0) {
    800036bc:	fe040593          	addi	a1,s0,-32
    800036c0:	4505                	li	a0,1
    800036c2:	00000097          	auipc	ra,0x0
    800036c6:	c22080e7          	jalr	-990(ra) # 800032e4 <argaddr>
      return -1; }
    800036ca:	57fd                	li	a5,-1
  if(argaddr(1,&buf) < 0) {
    800036cc:	00054b63          	bltz	a0,800036e2 <sys_btget+0x42>

  return btget(tag , buf);
    800036d0:	fe043583          	ld	a1,-32(s0)
    800036d4:	fec42503          	lw	a0,-20(s0)
    800036d8:	fffff097          	auipc	ra,0xfffff
    800036dc:	304080e7          	jalr	772(ra) # 800029dc <btget>
    800036e0:	87aa                	mv	a5,a0
}
    800036e2:	853e                	mv	a0,a5
    800036e4:	60e2                	ld	ra,24(sp)
    800036e6:	6442                	ld	s0,16(sp)
    800036e8:	6105                	addi	sp,sp,32
    800036ea:	8082                	ret

00000000800036ec <sys_tget>:

uint64
sys_tget(void)
{
    800036ec:	1101                	addi	sp,sp,-32
    800036ee:	ec06                	sd	ra,24(sp)
    800036f0:	e822                	sd	s0,16(sp)
    800036f2:	1000                	addi	s0,sp,32
  int tag;
  uint64 buf;

  if(argint(0,&tag) < 0) {
    800036f4:	fec40593          	addi	a1,s0,-20
    800036f8:	4501                	li	a0,0
    800036fa:	00000097          	auipc	ra,0x0
    800036fe:	bc8080e7          	jalr	-1080(ra) # 800032c2 <argint>
      return -1;
    80003702:	57fd                	li	a5,-1
  if(argint(0,&tag) < 0) {
    80003704:	02054563          	bltz	a0,8000372e <sys_tget+0x42>
  }
  if(argaddr(1,&buf) < 0) {
    80003708:	fe040593          	addi	a1,s0,-32
    8000370c:	4505                	li	a0,1
    8000370e:	00000097          	auipc	ra,0x0
    80003712:	bd6080e7          	jalr	-1066(ra) # 800032e4 <argaddr>
      return -1;
    80003716:	57fd                	li	a5,-1
  if(argaddr(1,&buf) < 0) {
    80003718:	00054b63          	bltz	a0,8000372e <sys_tget+0x42>
  }
  
  return btget(tag , buf);
    8000371c:	fe043583          	ld	a1,-32(s0)
    80003720:	fec42503          	lw	a0,-20(s0)
    80003724:	fffff097          	auipc	ra,0xfffff
    80003728:	2b8080e7          	jalr	696(ra) # 800029dc <btget>
    8000372c:	87aa                	mv	a5,a0
}
    8000372e:	853e                	mv	a0,a5
    80003730:	60e2                	ld	ra,24(sp)
    80003732:	6442                	ld	s0,16(sp)
    80003734:	6105                	addi	sp,sp,32
    80003736:	8082                	ret

0000000080003738 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003738:	7179                	addi	sp,sp,-48
    8000373a:	f406                	sd	ra,40(sp)
    8000373c:	f022                	sd	s0,32(sp)
    8000373e:	ec26                	sd	s1,24(sp)
    80003740:	e84a                	sd	s2,16(sp)
    80003742:	e44e                	sd	s3,8(sp)
    80003744:	e052                	sd	s4,0(sp)
    80003746:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003748:	00005597          	auipc	a1,0x5
    8000374c:	ec858593          	addi	a1,a1,-312 # 80008610 <syscalls+0xd8>
    80003750:	00014517          	auipc	a0,0x14
    80003754:	12050513          	addi	a0,a0,288 # 80017870 <bcache>
    80003758:	ffffd097          	auipc	ra,0xffffd
    8000375c:	3e8080e7          	jalr	1000(ra) # 80000b40 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003760:	0001c797          	auipc	a5,0x1c
    80003764:	11078793          	addi	a5,a5,272 # 8001f870 <bcache+0x8000>
    80003768:	0001c717          	auipc	a4,0x1c
    8000376c:	37070713          	addi	a4,a4,880 # 8001fad8 <bcache+0x8268>
    80003770:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003774:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003778:	00014497          	auipc	s1,0x14
    8000377c:	11048493          	addi	s1,s1,272 # 80017888 <bcache+0x18>
    b->next = bcache.head.next;
    80003780:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003782:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003784:	00005a17          	auipc	s4,0x5
    80003788:	e94a0a13          	addi	s4,s4,-364 # 80008618 <syscalls+0xe0>
    b->next = bcache.head.next;
    8000378c:	2b893783          	ld	a5,696(s2)
    80003790:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003792:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003796:	85d2                	mv	a1,s4
    80003798:	01048513          	addi	a0,s1,16
    8000379c:	00001097          	auipc	ra,0x1
    800037a0:	4c2080e7          	jalr	1218(ra) # 80004c5e <initsleeplock>
    bcache.head.next->prev = b;
    800037a4:	2b893783          	ld	a5,696(s2)
    800037a8:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800037aa:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800037ae:	45848493          	addi	s1,s1,1112
    800037b2:	fd349de3          	bne	s1,s3,8000378c <binit+0x54>
  }
}
    800037b6:	70a2                	ld	ra,40(sp)
    800037b8:	7402                	ld	s0,32(sp)
    800037ba:	64e2                	ld	s1,24(sp)
    800037bc:	6942                	ld	s2,16(sp)
    800037be:	69a2                	ld	s3,8(sp)
    800037c0:	6a02                	ld	s4,0(sp)
    800037c2:	6145                	addi	sp,sp,48
    800037c4:	8082                	ret

00000000800037c6 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800037c6:	7179                	addi	sp,sp,-48
    800037c8:	f406                	sd	ra,40(sp)
    800037ca:	f022                	sd	s0,32(sp)
    800037cc:	ec26                	sd	s1,24(sp)
    800037ce:	e84a                	sd	s2,16(sp)
    800037d0:	e44e                	sd	s3,8(sp)
    800037d2:	1800                	addi	s0,sp,48
    800037d4:	892a                	mv	s2,a0
    800037d6:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800037d8:	00014517          	auipc	a0,0x14
    800037dc:	09850513          	addi	a0,a0,152 # 80017870 <bcache>
    800037e0:	ffffd097          	auipc	ra,0xffffd
    800037e4:	3f0080e7          	jalr	1008(ra) # 80000bd0 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800037e8:	0001c497          	auipc	s1,0x1c
    800037ec:	3404b483          	ld	s1,832(s1) # 8001fb28 <bcache+0x82b8>
    800037f0:	0001c797          	auipc	a5,0x1c
    800037f4:	2e878793          	addi	a5,a5,744 # 8001fad8 <bcache+0x8268>
    800037f8:	02f48f63          	beq	s1,a5,80003836 <bread+0x70>
    800037fc:	873e                	mv	a4,a5
    800037fe:	a021                	j	80003806 <bread+0x40>
    80003800:	68a4                	ld	s1,80(s1)
    80003802:	02e48a63          	beq	s1,a4,80003836 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003806:	449c                	lw	a5,8(s1)
    80003808:	ff279ce3          	bne	a5,s2,80003800 <bread+0x3a>
    8000380c:	44dc                	lw	a5,12(s1)
    8000380e:	ff3799e3          	bne	a5,s3,80003800 <bread+0x3a>
      b->refcnt++;
    80003812:	40bc                	lw	a5,64(s1)
    80003814:	2785                	addiw	a5,a5,1
    80003816:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003818:	00014517          	auipc	a0,0x14
    8000381c:	05850513          	addi	a0,a0,88 # 80017870 <bcache>
    80003820:	ffffd097          	auipc	ra,0xffffd
    80003824:	464080e7          	jalr	1124(ra) # 80000c84 <release>
      acquiresleep(&b->lock);
    80003828:	01048513          	addi	a0,s1,16
    8000382c:	00001097          	auipc	ra,0x1
    80003830:	46c080e7          	jalr	1132(ra) # 80004c98 <acquiresleep>
      return b;
    80003834:	a8b9                	j	80003892 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003836:	0001c497          	auipc	s1,0x1c
    8000383a:	2ea4b483          	ld	s1,746(s1) # 8001fb20 <bcache+0x82b0>
    8000383e:	0001c797          	auipc	a5,0x1c
    80003842:	29a78793          	addi	a5,a5,666 # 8001fad8 <bcache+0x8268>
    80003846:	00f48863          	beq	s1,a5,80003856 <bread+0x90>
    8000384a:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000384c:	40bc                	lw	a5,64(s1)
    8000384e:	cf81                	beqz	a5,80003866 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003850:	64a4                	ld	s1,72(s1)
    80003852:	fee49de3          	bne	s1,a4,8000384c <bread+0x86>
  panic("bget: no buffers");
    80003856:	00005517          	auipc	a0,0x5
    8000385a:	dca50513          	addi	a0,a0,-566 # 80008620 <syscalls+0xe8>
    8000385e:	ffffd097          	auipc	ra,0xffffd
    80003862:	cdc080e7          	jalr	-804(ra) # 8000053a <panic>
      b->dev = dev;
    80003866:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000386a:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000386e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003872:	4785                	li	a5,1
    80003874:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003876:	00014517          	auipc	a0,0x14
    8000387a:	ffa50513          	addi	a0,a0,-6 # 80017870 <bcache>
    8000387e:	ffffd097          	auipc	ra,0xffffd
    80003882:	406080e7          	jalr	1030(ra) # 80000c84 <release>
      acquiresleep(&b->lock);
    80003886:	01048513          	addi	a0,s1,16
    8000388a:	00001097          	auipc	ra,0x1
    8000388e:	40e080e7          	jalr	1038(ra) # 80004c98 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003892:	409c                	lw	a5,0(s1)
    80003894:	cb89                	beqz	a5,800038a6 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003896:	8526                	mv	a0,s1
    80003898:	70a2                	ld	ra,40(sp)
    8000389a:	7402                	ld	s0,32(sp)
    8000389c:	64e2                	ld	s1,24(sp)
    8000389e:	6942                	ld	s2,16(sp)
    800038a0:	69a2                	ld	s3,8(sp)
    800038a2:	6145                	addi	sp,sp,48
    800038a4:	8082                	ret
    virtio_disk_rw(b, 0);
    800038a6:	4581                	li	a1,0
    800038a8:	8526                	mv	a0,s1
    800038aa:	00003097          	auipc	ra,0x3
    800038ae:	f28080e7          	jalr	-216(ra) # 800067d2 <virtio_disk_rw>
    b->valid = 1;
    800038b2:	4785                	li	a5,1
    800038b4:	c09c                	sw	a5,0(s1)
  return b;
    800038b6:	b7c5                	j	80003896 <bread+0xd0>

00000000800038b8 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800038b8:	1101                	addi	sp,sp,-32
    800038ba:	ec06                	sd	ra,24(sp)
    800038bc:	e822                	sd	s0,16(sp)
    800038be:	e426                	sd	s1,8(sp)
    800038c0:	1000                	addi	s0,sp,32
    800038c2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800038c4:	0541                	addi	a0,a0,16
    800038c6:	00001097          	auipc	ra,0x1
    800038ca:	46c080e7          	jalr	1132(ra) # 80004d32 <holdingsleep>
    800038ce:	cd01                	beqz	a0,800038e6 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800038d0:	4585                	li	a1,1
    800038d2:	8526                	mv	a0,s1
    800038d4:	00003097          	auipc	ra,0x3
    800038d8:	efe080e7          	jalr	-258(ra) # 800067d2 <virtio_disk_rw>
}
    800038dc:	60e2                	ld	ra,24(sp)
    800038de:	6442                	ld	s0,16(sp)
    800038e0:	64a2                	ld	s1,8(sp)
    800038e2:	6105                	addi	sp,sp,32
    800038e4:	8082                	ret
    panic("bwrite");
    800038e6:	00005517          	auipc	a0,0x5
    800038ea:	d5250513          	addi	a0,a0,-686 # 80008638 <syscalls+0x100>
    800038ee:	ffffd097          	auipc	ra,0xffffd
    800038f2:	c4c080e7          	jalr	-948(ra) # 8000053a <panic>

00000000800038f6 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800038f6:	1101                	addi	sp,sp,-32
    800038f8:	ec06                	sd	ra,24(sp)
    800038fa:	e822                	sd	s0,16(sp)
    800038fc:	e426                	sd	s1,8(sp)
    800038fe:	e04a                	sd	s2,0(sp)
    80003900:	1000                	addi	s0,sp,32
    80003902:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003904:	01050913          	addi	s2,a0,16
    80003908:	854a                	mv	a0,s2
    8000390a:	00001097          	auipc	ra,0x1
    8000390e:	428080e7          	jalr	1064(ra) # 80004d32 <holdingsleep>
    80003912:	c92d                	beqz	a0,80003984 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003914:	854a                	mv	a0,s2
    80003916:	00001097          	auipc	ra,0x1
    8000391a:	3d8080e7          	jalr	984(ra) # 80004cee <releasesleep>

  acquire(&bcache.lock);
    8000391e:	00014517          	auipc	a0,0x14
    80003922:	f5250513          	addi	a0,a0,-174 # 80017870 <bcache>
    80003926:	ffffd097          	auipc	ra,0xffffd
    8000392a:	2aa080e7          	jalr	682(ra) # 80000bd0 <acquire>
  b->refcnt--;
    8000392e:	40bc                	lw	a5,64(s1)
    80003930:	37fd                	addiw	a5,a5,-1
    80003932:	0007871b          	sext.w	a4,a5
    80003936:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003938:	eb05                	bnez	a4,80003968 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000393a:	68bc                	ld	a5,80(s1)
    8000393c:	64b8                	ld	a4,72(s1)
    8000393e:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003940:	64bc                	ld	a5,72(s1)
    80003942:	68b8                	ld	a4,80(s1)
    80003944:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003946:	0001c797          	auipc	a5,0x1c
    8000394a:	f2a78793          	addi	a5,a5,-214 # 8001f870 <bcache+0x8000>
    8000394e:	2b87b703          	ld	a4,696(a5)
    80003952:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003954:	0001c717          	auipc	a4,0x1c
    80003958:	18470713          	addi	a4,a4,388 # 8001fad8 <bcache+0x8268>
    8000395c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000395e:	2b87b703          	ld	a4,696(a5)
    80003962:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003964:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003968:	00014517          	auipc	a0,0x14
    8000396c:	f0850513          	addi	a0,a0,-248 # 80017870 <bcache>
    80003970:	ffffd097          	auipc	ra,0xffffd
    80003974:	314080e7          	jalr	788(ra) # 80000c84 <release>
}
    80003978:	60e2                	ld	ra,24(sp)
    8000397a:	6442                	ld	s0,16(sp)
    8000397c:	64a2                	ld	s1,8(sp)
    8000397e:	6902                	ld	s2,0(sp)
    80003980:	6105                	addi	sp,sp,32
    80003982:	8082                	ret
    panic("brelse");
    80003984:	00005517          	auipc	a0,0x5
    80003988:	cbc50513          	addi	a0,a0,-836 # 80008640 <syscalls+0x108>
    8000398c:	ffffd097          	auipc	ra,0xffffd
    80003990:	bae080e7          	jalr	-1106(ra) # 8000053a <panic>

0000000080003994 <bpin>:

void
bpin(struct buf *b) {
    80003994:	1101                	addi	sp,sp,-32
    80003996:	ec06                	sd	ra,24(sp)
    80003998:	e822                	sd	s0,16(sp)
    8000399a:	e426                	sd	s1,8(sp)
    8000399c:	1000                	addi	s0,sp,32
    8000399e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800039a0:	00014517          	auipc	a0,0x14
    800039a4:	ed050513          	addi	a0,a0,-304 # 80017870 <bcache>
    800039a8:	ffffd097          	auipc	ra,0xffffd
    800039ac:	228080e7          	jalr	552(ra) # 80000bd0 <acquire>
  b->refcnt++;
    800039b0:	40bc                	lw	a5,64(s1)
    800039b2:	2785                	addiw	a5,a5,1
    800039b4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800039b6:	00014517          	auipc	a0,0x14
    800039ba:	eba50513          	addi	a0,a0,-326 # 80017870 <bcache>
    800039be:	ffffd097          	auipc	ra,0xffffd
    800039c2:	2c6080e7          	jalr	710(ra) # 80000c84 <release>
}
    800039c6:	60e2                	ld	ra,24(sp)
    800039c8:	6442                	ld	s0,16(sp)
    800039ca:	64a2                	ld	s1,8(sp)
    800039cc:	6105                	addi	sp,sp,32
    800039ce:	8082                	ret

00000000800039d0 <bunpin>:

void
bunpin(struct buf *b) {
    800039d0:	1101                	addi	sp,sp,-32
    800039d2:	ec06                	sd	ra,24(sp)
    800039d4:	e822                	sd	s0,16(sp)
    800039d6:	e426                	sd	s1,8(sp)
    800039d8:	1000                	addi	s0,sp,32
    800039da:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800039dc:	00014517          	auipc	a0,0x14
    800039e0:	e9450513          	addi	a0,a0,-364 # 80017870 <bcache>
    800039e4:	ffffd097          	auipc	ra,0xffffd
    800039e8:	1ec080e7          	jalr	492(ra) # 80000bd0 <acquire>
  b->refcnt--;
    800039ec:	40bc                	lw	a5,64(s1)
    800039ee:	37fd                	addiw	a5,a5,-1
    800039f0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800039f2:	00014517          	auipc	a0,0x14
    800039f6:	e7e50513          	addi	a0,a0,-386 # 80017870 <bcache>
    800039fa:	ffffd097          	auipc	ra,0xffffd
    800039fe:	28a080e7          	jalr	650(ra) # 80000c84 <release>
}
    80003a02:	60e2                	ld	ra,24(sp)
    80003a04:	6442                	ld	s0,16(sp)
    80003a06:	64a2                	ld	s1,8(sp)
    80003a08:	6105                	addi	sp,sp,32
    80003a0a:	8082                	ret

0000000080003a0c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003a0c:	1101                	addi	sp,sp,-32
    80003a0e:	ec06                	sd	ra,24(sp)
    80003a10:	e822                	sd	s0,16(sp)
    80003a12:	e426                	sd	s1,8(sp)
    80003a14:	e04a                	sd	s2,0(sp)
    80003a16:	1000                	addi	s0,sp,32
    80003a18:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003a1a:	00d5d59b          	srliw	a1,a1,0xd
    80003a1e:	0001c797          	auipc	a5,0x1c
    80003a22:	52e7a783          	lw	a5,1326(a5) # 8001ff4c <sb+0x1c>
    80003a26:	9dbd                	addw	a1,a1,a5
    80003a28:	00000097          	auipc	ra,0x0
    80003a2c:	d9e080e7          	jalr	-610(ra) # 800037c6 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003a30:	0074f713          	andi	a4,s1,7
    80003a34:	4785                	li	a5,1
    80003a36:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003a3a:	14ce                	slli	s1,s1,0x33
    80003a3c:	90d9                	srli	s1,s1,0x36
    80003a3e:	00950733          	add	a4,a0,s1
    80003a42:	05874703          	lbu	a4,88(a4)
    80003a46:	00e7f6b3          	and	a3,a5,a4
    80003a4a:	c69d                	beqz	a3,80003a78 <bfree+0x6c>
    80003a4c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003a4e:	94aa                	add	s1,s1,a0
    80003a50:	fff7c793          	not	a5,a5
    80003a54:	8f7d                	and	a4,a4,a5
    80003a56:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003a5a:	00001097          	auipc	ra,0x1
    80003a5e:	120080e7          	jalr	288(ra) # 80004b7a <log_write>
  brelse(bp);
    80003a62:	854a                	mv	a0,s2
    80003a64:	00000097          	auipc	ra,0x0
    80003a68:	e92080e7          	jalr	-366(ra) # 800038f6 <brelse>
}
    80003a6c:	60e2                	ld	ra,24(sp)
    80003a6e:	6442                	ld	s0,16(sp)
    80003a70:	64a2                	ld	s1,8(sp)
    80003a72:	6902                	ld	s2,0(sp)
    80003a74:	6105                	addi	sp,sp,32
    80003a76:	8082                	ret
    panic("freeing free block");
    80003a78:	00005517          	auipc	a0,0x5
    80003a7c:	bd050513          	addi	a0,a0,-1072 # 80008648 <syscalls+0x110>
    80003a80:	ffffd097          	auipc	ra,0xffffd
    80003a84:	aba080e7          	jalr	-1350(ra) # 8000053a <panic>

0000000080003a88 <balloc>:
{
    80003a88:	711d                	addi	sp,sp,-96
    80003a8a:	ec86                	sd	ra,88(sp)
    80003a8c:	e8a2                	sd	s0,80(sp)
    80003a8e:	e4a6                	sd	s1,72(sp)
    80003a90:	e0ca                	sd	s2,64(sp)
    80003a92:	fc4e                	sd	s3,56(sp)
    80003a94:	f852                	sd	s4,48(sp)
    80003a96:	f456                	sd	s5,40(sp)
    80003a98:	f05a                	sd	s6,32(sp)
    80003a9a:	ec5e                	sd	s7,24(sp)
    80003a9c:	e862                	sd	s8,16(sp)
    80003a9e:	e466                	sd	s9,8(sp)
    80003aa0:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003aa2:	0001c797          	auipc	a5,0x1c
    80003aa6:	4927a783          	lw	a5,1170(a5) # 8001ff34 <sb+0x4>
    80003aaa:	cbc1                	beqz	a5,80003b3a <balloc+0xb2>
    80003aac:	8baa                	mv	s7,a0
    80003aae:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003ab0:	0001cb17          	auipc	s6,0x1c
    80003ab4:	480b0b13          	addi	s6,s6,1152 # 8001ff30 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003ab8:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003aba:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003abc:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003abe:	6c89                	lui	s9,0x2
    80003ac0:	a831                	j	80003adc <balloc+0x54>
    brelse(bp);
    80003ac2:	854a                	mv	a0,s2
    80003ac4:	00000097          	auipc	ra,0x0
    80003ac8:	e32080e7          	jalr	-462(ra) # 800038f6 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003acc:	015c87bb          	addw	a5,s9,s5
    80003ad0:	00078a9b          	sext.w	s5,a5
    80003ad4:	004b2703          	lw	a4,4(s6)
    80003ad8:	06eaf163          	bgeu	s5,a4,80003b3a <balloc+0xb2>
    bp = bread(dev, BBLOCK(b, sb));
    80003adc:	41fad79b          	sraiw	a5,s5,0x1f
    80003ae0:	0137d79b          	srliw	a5,a5,0x13
    80003ae4:	015787bb          	addw	a5,a5,s5
    80003ae8:	40d7d79b          	sraiw	a5,a5,0xd
    80003aec:	01cb2583          	lw	a1,28(s6)
    80003af0:	9dbd                	addw	a1,a1,a5
    80003af2:	855e                	mv	a0,s7
    80003af4:	00000097          	auipc	ra,0x0
    80003af8:	cd2080e7          	jalr	-814(ra) # 800037c6 <bread>
    80003afc:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003afe:	004b2503          	lw	a0,4(s6)
    80003b02:	000a849b          	sext.w	s1,s5
    80003b06:	8762                	mv	a4,s8
    80003b08:	faa4fde3          	bgeu	s1,a0,80003ac2 <balloc+0x3a>
      m = 1 << (bi % 8);
    80003b0c:	00777693          	andi	a3,a4,7
    80003b10:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003b14:	41f7579b          	sraiw	a5,a4,0x1f
    80003b18:	01d7d79b          	srliw	a5,a5,0x1d
    80003b1c:	9fb9                	addw	a5,a5,a4
    80003b1e:	4037d79b          	sraiw	a5,a5,0x3
    80003b22:	00f90633          	add	a2,s2,a5
    80003b26:	05864603          	lbu	a2,88(a2)
    80003b2a:	00c6f5b3          	and	a1,a3,a2
    80003b2e:	cd91                	beqz	a1,80003b4a <balloc+0xc2>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b30:	2705                	addiw	a4,a4,1
    80003b32:	2485                	addiw	s1,s1,1
    80003b34:	fd471ae3          	bne	a4,s4,80003b08 <balloc+0x80>
    80003b38:	b769                	j	80003ac2 <balloc+0x3a>
  panic("balloc: out of blocks");
    80003b3a:	00005517          	auipc	a0,0x5
    80003b3e:	b2650513          	addi	a0,a0,-1242 # 80008660 <syscalls+0x128>
    80003b42:	ffffd097          	auipc	ra,0xffffd
    80003b46:	9f8080e7          	jalr	-1544(ra) # 8000053a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003b4a:	97ca                	add	a5,a5,s2
    80003b4c:	8e55                	or	a2,a2,a3
    80003b4e:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003b52:	854a                	mv	a0,s2
    80003b54:	00001097          	auipc	ra,0x1
    80003b58:	026080e7          	jalr	38(ra) # 80004b7a <log_write>
        brelse(bp);
    80003b5c:	854a                	mv	a0,s2
    80003b5e:	00000097          	auipc	ra,0x0
    80003b62:	d98080e7          	jalr	-616(ra) # 800038f6 <brelse>
  bp = bread(dev, bno);
    80003b66:	85a6                	mv	a1,s1
    80003b68:	855e                	mv	a0,s7
    80003b6a:	00000097          	auipc	ra,0x0
    80003b6e:	c5c080e7          	jalr	-932(ra) # 800037c6 <bread>
    80003b72:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003b74:	40000613          	li	a2,1024
    80003b78:	4581                	li	a1,0
    80003b7a:	05850513          	addi	a0,a0,88
    80003b7e:	ffffd097          	auipc	ra,0xffffd
    80003b82:	14e080e7          	jalr	334(ra) # 80000ccc <memset>
  log_write(bp);
    80003b86:	854a                	mv	a0,s2
    80003b88:	00001097          	auipc	ra,0x1
    80003b8c:	ff2080e7          	jalr	-14(ra) # 80004b7a <log_write>
  brelse(bp);
    80003b90:	854a                	mv	a0,s2
    80003b92:	00000097          	auipc	ra,0x0
    80003b96:	d64080e7          	jalr	-668(ra) # 800038f6 <brelse>
}
    80003b9a:	8526                	mv	a0,s1
    80003b9c:	60e6                	ld	ra,88(sp)
    80003b9e:	6446                	ld	s0,80(sp)
    80003ba0:	64a6                	ld	s1,72(sp)
    80003ba2:	6906                	ld	s2,64(sp)
    80003ba4:	79e2                	ld	s3,56(sp)
    80003ba6:	7a42                	ld	s4,48(sp)
    80003ba8:	7aa2                	ld	s5,40(sp)
    80003baa:	7b02                	ld	s6,32(sp)
    80003bac:	6be2                	ld	s7,24(sp)
    80003bae:	6c42                	ld	s8,16(sp)
    80003bb0:	6ca2                	ld	s9,8(sp)
    80003bb2:	6125                	addi	sp,sp,96
    80003bb4:	8082                	ret

0000000080003bb6 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003bb6:	7179                	addi	sp,sp,-48
    80003bb8:	f406                	sd	ra,40(sp)
    80003bba:	f022                	sd	s0,32(sp)
    80003bbc:	ec26                	sd	s1,24(sp)
    80003bbe:	e84a                	sd	s2,16(sp)
    80003bc0:	e44e                	sd	s3,8(sp)
    80003bc2:	e052                	sd	s4,0(sp)
    80003bc4:	1800                	addi	s0,sp,48
    80003bc6:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003bc8:	47ad                	li	a5,11
    80003bca:	04b7fe63          	bgeu	a5,a1,80003c26 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003bce:	ff45849b          	addiw	s1,a1,-12
    80003bd2:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003bd6:	0ff00793          	li	a5,255
    80003bda:	0ae7e463          	bltu	a5,a4,80003c82 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003bde:	08052583          	lw	a1,128(a0)
    80003be2:	c5b5                	beqz	a1,80003c4e <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003be4:	00092503          	lw	a0,0(s2)
    80003be8:	00000097          	auipc	ra,0x0
    80003bec:	bde080e7          	jalr	-1058(ra) # 800037c6 <bread>
    80003bf0:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003bf2:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003bf6:	02049713          	slli	a4,s1,0x20
    80003bfa:	01e75593          	srli	a1,a4,0x1e
    80003bfe:	00b784b3          	add	s1,a5,a1
    80003c02:	0004a983          	lw	s3,0(s1)
    80003c06:	04098e63          	beqz	s3,80003c62 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003c0a:	8552                	mv	a0,s4
    80003c0c:	00000097          	auipc	ra,0x0
    80003c10:	cea080e7          	jalr	-790(ra) # 800038f6 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003c14:	854e                	mv	a0,s3
    80003c16:	70a2                	ld	ra,40(sp)
    80003c18:	7402                	ld	s0,32(sp)
    80003c1a:	64e2                	ld	s1,24(sp)
    80003c1c:	6942                	ld	s2,16(sp)
    80003c1e:	69a2                	ld	s3,8(sp)
    80003c20:	6a02                	ld	s4,0(sp)
    80003c22:	6145                	addi	sp,sp,48
    80003c24:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003c26:	02059793          	slli	a5,a1,0x20
    80003c2a:	01e7d593          	srli	a1,a5,0x1e
    80003c2e:	00b504b3          	add	s1,a0,a1
    80003c32:	0504a983          	lw	s3,80(s1)
    80003c36:	fc099fe3          	bnez	s3,80003c14 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003c3a:	4108                	lw	a0,0(a0)
    80003c3c:	00000097          	auipc	ra,0x0
    80003c40:	e4c080e7          	jalr	-436(ra) # 80003a88 <balloc>
    80003c44:	0005099b          	sext.w	s3,a0
    80003c48:	0534a823          	sw	s3,80(s1)
    80003c4c:	b7e1                	j	80003c14 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003c4e:	4108                	lw	a0,0(a0)
    80003c50:	00000097          	auipc	ra,0x0
    80003c54:	e38080e7          	jalr	-456(ra) # 80003a88 <balloc>
    80003c58:	0005059b          	sext.w	a1,a0
    80003c5c:	08b92023          	sw	a1,128(s2)
    80003c60:	b751                	j	80003be4 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003c62:	00092503          	lw	a0,0(s2)
    80003c66:	00000097          	auipc	ra,0x0
    80003c6a:	e22080e7          	jalr	-478(ra) # 80003a88 <balloc>
    80003c6e:	0005099b          	sext.w	s3,a0
    80003c72:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003c76:	8552                	mv	a0,s4
    80003c78:	00001097          	auipc	ra,0x1
    80003c7c:	f02080e7          	jalr	-254(ra) # 80004b7a <log_write>
    80003c80:	b769                	j	80003c0a <bmap+0x54>
  panic("bmap: out of range");
    80003c82:	00005517          	auipc	a0,0x5
    80003c86:	9f650513          	addi	a0,a0,-1546 # 80008678 <syscalls+0x140>
    80003c8a:	ffffd097          	auipc	ra,0xffffd
    80003c8e:	8b0080e7          	jalr	-1872(ra) # 8000053a <panic>

0000000080003c92 <iget>:
{
    80003c92:	7179                	addi	sp,sp,-48
    80003c94:	f406                	sd	ra,40(sp)
    80003c96:	f022                	sd	s0,32(sp)
    80003c98:	ec26                	sd	s1,24(sp)
    80003c9a:	e84a                	sd	s2,16(sp)
    80003c9c:	e44e                	sd	s3,8(sp)
    80003c9e:	e052                	sd	s4,0(sp)
    80003ca0:	1800                	addi	s0,sp,48
    80003ca2:	89aa                	mv	s3,a0
    80003ca4:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003ca6:	0001c517          	auipc	a0,0x1c
    80003caa:	2aa50513          	addi	a0,a0,682 # 8001ff50 <itable>
    80003cae:	ffffd097          	auipc	ra,0xffffd
    80003cb2:	f22080e7          	jalr	-222(ra) # 80000bd0 <acquire>
  empty = 0;
    80003cb6:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003cb8:	0001c497          	auipc	s1,0x1c
    80003cbc:	2b048493          	addi	s1,s1,688 # 8001ff68 <itable+0x18>
    80003cc0:	0001e697          	auipc	a3,0x1e
    80003cc4:	d3868693          	addi	a3,a3,-712 # 800219f8 <log>
    80003cc8:	a039                	j	80003cd6 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003cca:	02090b63          	beqz	s2,80003d00 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003cce:	08848493          	addi	s1,s1,136
    80003cd2:	02d48a63          	beq	s1,a3,80003d06 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003cd6:	449c                	lw	a5,8(s1)
    80003cd8:	fef059e3          	blez	a5,80003cca <iget+0x38>
    80003cdc:	4098                	lw	a4,0(s1)
    80003cde:	ff3716e3          	bne	a4,s3,80003cca <iget+0x38>
    80003ce2:	40d8                	lw	a4,4(s1)
    80003ce4:	ff4713e3          	bne	a4,s4,80003cca <iget+0x38>
      ip->ref++;
    80003ce8:	2785                	addiw	a5,a5,1
    80003cea:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003cec:	0001c517          	auipc	a0,0x1c
    80003cf0:	26450513          	addi	a0,a0,612 # 8001ff50 <itable>
    80003cf4:	ffffd097          	auipc	ra,0xffffd
    80003cf8:	f90080e7          	jalr	-112(ra) # 80000c84 <release>
      return ip;
    80003cfc:	8926                	mv	s2,s1
    80003cfe:	a03d                	j	80003d2c <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003d00:	f7f9                	bnez	a5,80003cce <iget+0x3c>
    80003d02:	8926                	mv	s2,s1
    80003d04:	b7e9                	j	80003cce <iget+0x3c>
  if(empty == 0)
    80003d06:	02090c63          	beqz	s2,80003d3e <iget+0xac>
  ip->dev = dev;
    80003d0a:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003d0e:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003d12:	4785                	li	a5,1
    80003d14:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003d18:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003d1c:	0001c517          	auipc	a0,0x1c
    80003d20:	23450513          	addi	a0,a0,564 # 8001ff50 <itable>
    80003d24:	ffffd097          	auipc	ra,0xffffd
    80003d28:	f60080e7          	jalr	-160(ra) # 80000c84 <release>
}
    80003d2c:	854a                	mv	a0,s2
    80003d2e:	70a2                	ld	ra,40(sp)
    80003d30:	7402                	ld	s0,32(sp)
    80003d32:	64e2                	ld	s1,24(sp)
    80003d34:	6942                	ld	s2,16(sp)
    80003d36:	69a2                	ld	s3,8(sp)
    80003d38:	6a02                	ld	s4,0(sp)
    80003d3a:	6145                	addi	sp,sp,48
    80003d3c:	8082                	ret
    panic("iget: no inodes");
    80003d3e:	00005517          	auipc	a0,0x5
    80003d42:	95250513          	addi	a0,a0,-1710 # 80008690 <syscalls+0x158>
    80003d46:	ffffc097          	auipc	ra,0xffffc
    80003d4a:	7f4080e7          	jalr	2036(ra) # 8000053a <panic>

0000000080003d4e <fsinit>:
fsinit(int dev) {
    80003d4e:	7179                	addi	sp,sp,-48
    80003d50:	f406                	sd	ra,40(sp)
    80003d52:	f022                	sd	s0,32(sp)
    80003d54:	ec26                	sd	s1,24(sp)
    80003d56:	e84a                	sd	s2,16(sp)
    80003d58:	e44e                	sd	s3,8(sp)
    80003d5a:	1800                	addi	s0,sp,48
    80003d5c:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003d5e:	4585                	li	a1,1
    80003d60:	00000097          	auipc	ra,0x0
    80003d64:	a66080e7          	jalr	-1434(ra) # 800037c6 <bread>
    80003d68:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003d6a:	0001c997          	auipc	s3,0x1c
    80003d6e:	1c698993          	addi	s3,s3,454 # 8001ff30 <sb>
    80003d72:	02000613          	li	a2,32
    80003d76:	05850593          	addi	a1,a0,88
    80003d7a:	854e                	mv	a0,s3
    80003d7c:	ffffd097          	auipc	ra,0xffffd
    80003d80:	fac080e7          	jalr	-84(ra) # 80000d28 <memmove>
  brelse(bp);
    80003d84:	8526                	mv	a0,s1
    80003d86:	00000097          	auipc	ra,0x0
    80003d8a:	b70080e7          	jalr	-1168(ra) # 800038f6 <brelse>
  if(sb.magic != FSMAGIC)
    80003d8e:	0009a703          	lw	a4,0(s3)
    80003d92:	102037b7          	lui	a5,0x10203
    80003d96:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003d9a:	02f71263          	bne	a4,a5,80003dbe <fsinit+0x70>
  initlog(dev, &sb);
    80003d9e:	0001c597          	auipc	a1,0x1c
    80003da2:	19258593          	addi	a1,a1,402 # 8001ff30 <sb>
    80003da6:	854a                	mv	a0,s2
    80003da8:	00001097          	auipc	ra,0x1
    80003dac:	b56080e7          	jalr	-1194(ra) # 800048fe <initlog>
}
    80003db0:	70a2                	ld	ra,40(sp)
    80003db2:	7402                	ld	s0,32(sp)
    80003db4:	64e2                	ld	s1,24(sp)
    80003db6:	6942                	ld	s2,16(sp)
    80003db8:	69a2                	ld	s3,8(sp)
    80003dba:	6145                	addi	sp,sp,48
    80003dbc:	8082                	ret
    panic("invalid file system");
    80003dbe:	00005517          	auipc	a0,0x5
    80003dc2:	8e250513          	addi	a0,a0,-1822 # 800086a0 <syscalls+0x168>
    80003dc6:	ffffc097          	auipc	ra,0xffffc
    80003dca:	774080e7          	jalr	1908(ra) # 8000053a <panic>

0000000080003dce <iinit>:
{
    80003dce:	7179                	addi	sp,sp,-48
    80003dd0:	f406                	sd	ra,40(sp)
    80003dd2:	f022                	sd	s0,32(sp)
    80003dd4:	ec26                	sd	s1,24(sp)
    80003dd6:	e84a                	sd	s2,16(sp)
    80003dd8:	e44e                	sd	s3,8(sp)
    80003dda:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003ddc:	00005597          	auipc	a1,0x5
    80003de0:	8dc58593          	addi	a1,a1,-1828 # 800086b8 <syscalls+0x180>
    80003de4:	0001c517          	auipc	a0,0x1c
    80003de8:	16c50513          	addi	a0,a0,364 # 8001ff50 <itable>
    80003dec:	ffffd097          	auipc	ra,0xffffd
    80003df0:	d54080e7          	jalr	-684(ra) # 80000b40 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003df4:	0001c497          	auipc	s1,0x1c
    80003df8:	18448493          	addi	s1,s1,388 # 8001ff78 <itable+0x28>
    80003dfc:	0001e997          	auipc	s3,0x1e
    80003e00:	c0c98993          	addi	s3,s3,-1012 # 80021a08 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003e04:	00005917          	auipc	s2,0x5
    80003e08:	8bc90913          	addi	s2,s2,-1860 # 800086c0 <syscalls+0x188>
    80003e0c:	85ca                	mv	a1,s2
    80003e0e:	8526                	mv	a0,s1
    80003e10:	00001097          	auipc	ra,0x1
    80003e14:	e4e080e7          	jalr	-434(ra) # 80004c5e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003e18:	08848493          	addi	s1,s1,136
    80003e1c:	ff3498e3          	bne	s1,s3,80003e0c <iinit+0x3e>
}
    80003e20:	70a2                	ld	ra,40(sp)
    80003e22:	7402                	ld	s0,32(sp)
    80003e24:	64e2                	ld	s1,24(sp)
    80003e26:	6942                	ld	s2,16(sp)
    80003e28:	69a2                	ld	s3,8(sp)
    80003e2a:	6145                	addi	sp,sp,48
    80003e2c:	8082                	ret

0000000080003e2e <ialloc>:
{
    80003e2e:	715d                	addi	sp,sp,-80
    80003e30:	e486                	sd	ra,72(sp)
    80003e32:	e0a2                	sd	s0,64(sp)
    80003e34:	fc26                	sd	s1,56(sp)
    80003e36:	f84a                	sd	s2,48(sp)
    80003e38:	f44e                	sd	s3,40(sp)
    80003e3a:	f052                	sd	s4,32(sp)
    80003e3c:	ec56                	sd	s5,24(sp)
    80003e3e:	e85a                	sd	s6,16(sp)
    80003e40:	e45e                	sd	s7,8(sp)
    80003e42:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003e44:	0001c717          	auipc	a4,0x1c
    80003e48:	0f872703          	lw	a4,248(a4) # 8001ff3c <sb+0xc>
    80003e4c:	4785                	li	a5,1
    80003e4e:	04e7fa63          	bgeu	a5,a4,80003ea2 <ialloc+0x74>
    80003e52:	8aaa                	mv	s5,a0
    80003e54:	8bae                	mv	s7,a1
    80003e56:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003e58:	0001ca17          	auipc	s4,0x1c
    80003e5c:	0d8a0a13          	addi	s4,s4,216 # 8001ff30 <sb>
    80003e60:	00048b1b          	sext.w	s6,s1
    80003e64:	0044d593          	srli	a1,s1,0x4
    80003e68:	018a2783          	lw	a5,24(s4)
    80003e6c:	9dbd                	addw	a1,a1,a5
    80003e6e:	8556                	mv	a0,s5
    80003e70:	00000097          	auipc	ra,0x0
    80003e74:	956080e7          	jalr	-1706(ra) # 800037c6 <bread>
    80003e78:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003e7a:	05850993          	addi	s3,a0,88
    80003e7e:	00f4f793          	andi	a5,s1,15
    80003e82:	079a                	slli	a5,a5,0x6
    80003e84:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003e86:	00099783          	lh	a5,0(s3)
    80003e8a:	c785                	beqz	a5,80003eb2 <ialloc+0x84>
    brelse(bp);
    80003e8c:	00000097          	auipc	ra,0x0
    80003e90:	a6a080e7          	jalr	-1430(ra) # 800038f6 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003e94:	0485                	addi	s1,s1,1
    80003e96:	00ca2703          	lw	a4,12(s4)
    80003e9a:	0004879b          	sext.w	a5,s1
    80003e9e:	fce7e1e3          	bltu	a5,a4,80003e60 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003ea2:	00005517          	auipc	a0,0x5
    80003ea6:	82650513          	addi	a0,a0,-2010 # 800086c8 <syscalls+0x190>
    80003eaa:	ffffc097          	auipc	ra,0xffffc
    80003eae:	690080e7          	jalr	1680(ra) # 8000053a <panic>
      memset(dip, 0, sizeof(*dip));
    80003eb2:	04000613          	li	a2,64
    80003eb6:	4581                	li	a1,0
    80003eb8:	854e                	mv	a0,s3
    80003eba:	ffffd097          	auipc	ra,0xffffd
    80003ebe:	e12080e7          	jalr	-494(ra) # 80000ccc <memset>
      dip->type = type;
    80003ec2:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003ec6:	854a                	mv	a0,s2
    80003ec8:	00001097          	auipc	ra,0x1
    80003ecc:	cb2080e7          	jalr	-846(ra) # 80004b7a <log_write>
      brelse(bp);
    80003ed0:	854a                	mv	a0,s2
    80003ed2:	00000097          	auipc	ra,0x0
    80003ed6:	a24080e7          	jalr	-1500(ra) # 800038f6 <brelse>
      return iget(dev, inum);
    80003eda:	85da                	mv	a1,s6
    80003edc:	8556                	mv	a0,s5
    80003ede:	00000097          	auipc	ra,0x0
    80003ee2:	db4080e7          	jalr	-588(ra) # 80003c92 <iget>
}
    80003ee6:	60a6                	ld	ra,72(sp)
    80003ee8:	6406                	ld	s0,64(sp)
    80003eea:	74e2                	ld	s1,56(sp)
    80003eec:	7942                	ld	s2,48(sp)
    80003eee:	79a2                	ld	s3,40(sp)
    80003ef0:	7a02                	ld	s4,32(sp)
    80003ef2:	6ae2                	ld	s5,24(sp)
    80003ef4:	6b42                	ld	s6,16(sp)
    80003ef6:	6ba2                	ld	s7,8(sp)
    80003ef8:	6161                	addi	sp,sp,80
    80003efa:	8082                	ret

0000000080003efc <iupdate>:
{
    80003efc:	1101                	addi	sp,sp,-32
    80003efe:	ec06                	sd	ra,24(sp)
    80003f00:	e822                	sd	s0,16(sp)
    80003f02:	e426                	sd	s1,8(sp)
    80003f04:	e04a                	sd	s2,0(sp)
    80003f06:	1000                	addi	s0,sp,32
    80003f08:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003f0a:	415c                	lw	a5,4(a0)
    80003f0c:	0047d79b          	srliw	a5,a5,0x4
    80003f10:	0001c597          	auipc	a1,0x1c
    80003f14:	0385a583          	lw	a1,56(a1) # 8001ff48 <sb+0x18>
    80003f18:	9dbd                	addw	a1,a1,a5
    80003f1a:	4108                	lw	a0,0(a0)
    80003f1c:	00000097          	auipc	ra,0x0
    80003f20:	8aa080e7          	jalr	-1878(ra) # 800037c6 <bread>
    80003f24:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003f26:	05850793          	addi	a5,a0,88
    80003f2a:	40d8                	lw	a4,4(s1)
    80003f2c:	8b3d                	andi	a4,a4,15
    80003f2e:	071a                	slli	a4,a4,0x6
    80003f30:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003f32:	04449703          	lh	a4,68(s1)
    80003f36:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003f3a:	04649703          	lh	a4,70(s1)
    80003f3e:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003f42:	04849703          	lh	a4,72(s1)
    80003f46:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003f4a:	04a49703          	lh	a4,74(s1)
    80003f4e:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003f52:	44f8                	lw	a4,76(s1)
    80003f54:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003f56:	03400613          	li	a2,52
    80003f5a:	05048593          	addi	a1,s1,80
    80003f5e:	00c78513          	addi	a0,a5,12
    80003f62:	ffffd097          	auipc	ra,0xffffd
    80003f66:	dc6080e7          	jalr	-570(ra) # 80000d28 <memmove>
  log_write(bp);
    80003f6a:	854a                	mv	a0,s2
    80003f6c:	00001097          	auipc	ra,0x1
    80003f70:	c0e080e7          	jalr	-1010(ra) # 80004b7a <log_write>
  brelse(bp);
    80003f74:	854a                	mv	a0,s2
    80003f76:	00000097          	auipc	ra,0x0
    80003f7a:	980080e7          	jalr	-1664(ra) # 800038f6 <brelse>
}
    80003f7e:	60e2                	ld	ra,24(sp)
    80003f80:	6442                	ld	s0,16(sp)
    80003f82:	64a2                	ld	s1,8(sp)
    80003f84:	6902                	ld	s2,0(sp)
    80003f86:	6105                	addi	sp,sp,32
    80003f88:	8082                	ret

0000000080003f8a <idup>:
{
    80003f8a:	1101                	addi	sp,sp,-32
    80003f8c:	ec06                	sd	ra,24(sp)
    80003f8e:	e822                	sd	s0,16(sp)
    80003f90:	e426                	sd	s1,8(sp)
    80003f92:	1000                	addi	s0,sp,32
    80003f94:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003f96:	0001c517          	auipc	a0,0x1c
    80003f9a:	fba50513          	addi	a0,a0,-70 # 8001ff50 <itable>
    80003f9e:	ffffd097          	auipc	ra,0xffffd
    80003fa2:	c32080e7          	jalr	-974(ra) # 80000bd0 <acquire>
  ip->ref++;
    80003fa6:	449c                	lw	a5,8(s1)
    80003fa8:	2785                	addiw	a5,a5,1
    80003faa:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003fac:	0001c517          	auipc	a0,0x1c
    80003fb0:	fa450513          	addi	a0,a0,-92 # 8001ff50 <itable>
    80003fb4:	ffffd097          	auipc	ra,0xffffd
    80003fb8:	cd0080e7          	jalr	-816(ra) # 80000c84 <release>
}
    80003fbc:	8526                	mv	a0,s1
    80003fbe:	60e2                	ld	ra,24(sp)
    80003fc0:	6442                	ld	s0,16(sp)
    80003fc2:	64a2                	ld	s1,8(sp)
    80003fc4:	6105                	addi	sp,sp,32
    80003fc6:	8082                	ret

0000000080003fc8 <ilock>:
{
    80003fc8:	1101                	addi	sp,sp,-32
    80003fca:	ec06                	sd	ra,24(sp)
    80003fcc:	e822                	sd	s0,16(sp)
    80003fce:	e426                	sd	s1,8(sp)
    80003fd0:	e04a                	sd	s2,0(sp)
    80003fd2:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003fd4:	c115                	beqz	a0,80003ff8 <ilock+0x30>
    80003fd6:	84aa                	mv	s1,a0
    80003fd8:	451c                	lw	a5,8(a0)
    80003fda:	00f05f63          	blez	a5,80003ff8 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003fde:	0541                	addi	a0,a0,16
    80003fe0:	00001097          	auipc	ra,0x1
    80003fe4:	cb8080e7          	jalr	-840(ra) # 80004c98 <acquiresleep>
  if(ip->valid == 0){
    80003fe8:	40bc                	lw	a5,64(s1)
    80003fea:	cf99                	beqz	a5,80004008 <ilock+0x40>
}
    80003fec:	60e2                	ld	ra,24(sp)
    80003fee:	6442                	ld	s0,16(sp)
    80003ff0:	64a2                	ld	s1,8(sp)
    80003ff2:	6902                	ld	s2,0(sp)
    80003ff4:	6105                	addi	sp,sp,32
    80003ff6:	8082                	ret
    panic("ilock");
    80003ff8:	00004517          	auipc	a0,0x4
    80003ffc:	6e850513          	addi	a0,a0,1768 # 800086e0 <syscalls+0x1a8>
    80004000:	ffffc097          	auipc	ra,0xffffc
    80004004:	53a080e7          	jalr	1338(ra) # 8000053a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004008:	40dc                	lw	a5,4(s1)
    8000400a:	0047d79b          	srliw	a5,a5,0x4
    8000400e:	0001c597          	auipc	a1,0x1c
    80004012:	f3a5a583          	lw	a1,-198(a1) # 8001ff48 <sb+0x18>
    80004016:	9dbd                	addw	a1,a1,a5
    80004018:	4088                	lw	a0,0(s1)
    8000401a:	fffff097          	auipc	ra,0xfffff
    8000401e:	7ac080e7          	jalr	1964(ra) # 800037c6 <bread>
    80004022:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004024:	05850593          	addi	a1,a0,88
    80004028:	40dc                	lw	a5,4(s1)
    8000402a:	8bbd                	andi	a5,a5,15
    8000402c:	079a                	slli	a5,a5,0x6
    8000402e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80004030:	00059783          	lh	a5,0(a1)
    80004034:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80004038:	00259783          	lh	a5,2(a1)
    8000403c:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80004040:	00459783          	lh	a5,4(a1)
    80004044:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80004048:	00659783          	lh	a5,6(a1)
    8000404c:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80004050:	459c                	lw	a5,8(a1)
    80004052:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80004054:	03400613          	li	a2,52
    80004058:	05b1                	addi	a1,a1,12
    8000405a:	05048513          	addi	a0,s1,80
    8000405e:	ffffd097          	auipc	ra,0xffffd
    80004062:	cca080e7          	jalr	-822(ra) # 80000d28 <memmove>
    brelse(bp);
    80004066:	854a                	mv	a0,s2
    80004068:	00000097          	auipc	ra,0x0
    8000406c:	88e080e7          	jalr	-1906(ra) # 800038f6 <brelse>
    ip->valid = 1;
    80004070:	4785                	li	a5,1
    80004072:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80004074:	04449783          	lh	a5,68(s1)
    80004078:	fbb5                	bnez	a5,80003fec <ilock+0x24>
      panic("ilock: no type");
    8000407a:	00004517          	auipc	a0,0x4
    8000407e:	66e50513          	addi	a0,a0,1646 # 800086e8 <syscalls+0x1b0>
    80004082:	ffffc097          	auipc	ra,0xffffc
    80004086:	4b8080e7          	jalr	1208(ra) # 8000053a <panic>

000000008000408a <iunlock>:
{
    8000408a:	1101                	addi	sp,sp,-32
    8000408c:	ec06                	sd	ra,24(sp)
    8000408e:	e822                	sd	s0,16(sp)
    80004090:	e426                	sd	s1,8(sp)
    80004092:	e04a                	sd	s2,0(sp)
    80004094:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80004096:	c905                	beqz	a0,800040c6 <iunlock+0x3c>
    80004098:	84aa                	mv	s1,a0
    8000409a:	01050913          	addi	s2,a0,16
    8000409e:	854a                	mv	a0,s2
    800040a0:	00001097          	auipc	ra,0x1
    800040a4:	c92080e7          	jalr	-878(ra) # 80004d32 <holdingsleep>
    800040a8:	cd19                	beqz	a0,800040c6 <iunlock+0x3c>
    800040aa:	449c                	lw	a5,8(s1)
    800040ac:	00f05d63          	blez	a5,800040c6 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800040b0:	854a                	mv	a0,s2
    800040b2:	00001097          	auipc	ra,0x1
    800040b6:	c3c080e7          	jalr	-964(ra) # 80004cee <releasesleep>
}
    800040ba:	60e2                	ld	ra,24(sp)
    800040bc:	6442                	ld	s0,16(sp)
    800040be:	64a2                	ld	s1,8(sp)
    800040c0:	6902                	ld	s2,0(sp)
    800040c2:	6105                	addi	sp,sp,32
    800040c4:	8082                	ret
    panic("iunlock");
    800040c6:	00004517          	auipc	a0,0x4
    800040ca:	63250513          	addi	a0,a0,1586 # 800086f8 <syscalls+0x1c0>
    800040ce:	ffffc097          	auipc	ra,0xffffc
    800040d2:	46c080e7          	jalr	1132(ra) # 8000053a <panic>

00000000800040d6 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800040d6:	7179                	addi	sp,sp,-48
    800040d8:	f406                	sd	ra,40(sp)
    800040da:	f022                	sd	s0,32(sp)
    800040dc:	ec26                	sd	s1,24(sp)
    800040de:	e84a                	sd	s2,16(sp)
    800040e0:	e44e                	sd	s3,8(sp)
    800040e2:	e052                	sd	s4,0(sp)
    800040e4:	1800                	addi	s0,sp,48
    800040e6:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800040e8:	05050493          	addi	s1,a0,80
    800040ec:	08050913          	addi	s2,a0,128
    800040f0:	a021                	j	800040f8 <itrunc+0x22>
    800040f2:	0491                	addi	s1,s1,4
    800040f4:	01248d63          	beq	s1,s2,8000410e <itrunc+0x38>
    if(ip->addrs[i]){
    800040f8:	408c                	lw	a1,0(s1)
    800040fa:	dde5                	beqz	a1,800040f2 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800040fc:	0009a503          	lw	a0,0(s3)
    80004100:	00000097          	auipc	ra,0x0
    80004104:	90c080e7          	jalr	-1780(ra) # 80003a0c <bfree>
      ip->addrs[i] = 0;
    80004108:	0004a023          	sw	zero,0(s1)
    8000410c:	b7dd                	j	800040f2 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000410e:	0809a583          	lw	a1,128(s3)
    80004112:	e185                	bnez	a1,80004132 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80004114:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80004118:	854e                	mv	a0,s3
    8000411a:	00000097          	auipc	ra,0x0
    8000411e:	de2080e7          	jalr	-542(ra) # 80003efc <iupdate>
}
    80004122:	70a2                	ld	ra,40(sp)
    80004124:	7402                	ld	s0,32(sp)
    80004126:	64e2                	ld	s1,24(sp)
    80004128:	6942                	ld	s2,16(sp)
    8000412a:	69a2                	ld	s3,8(sp)
    8000412c:	6a02                	ld	s4,0(sp)
    8000412e:	6145                	addi	sp,sp,48
    80004130:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80004132:	0009a503          	lw	a0,0(s3)
    80004136:	fffff097          	auipc	ra,0xfffff
    8000413a:	690080e7          	jalr	1680(ra) # 800037c6 <bread>
    8000413e:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80004140:	05850493          	addi	s1,a0,88
    80004144:	45850913          	addi	s2,a0,1112
    80004148:	a021                	j	80004150 <itrunc+0x7a>
    8000414a:	0491                	addi	s1,s1,4
    8000414c:	01248b63          	beq	s1,s2,80004162 <itrunc+0x8c>
      if(a[j])
    80004150:	408c                	lw	a1,0(s1)
    80004152:	dde5                	beqz	a1,8000414a <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80004154:	0009a503          	lw	a0,0(s3)
    80004158:	00000097          	auipc	ra,0x0
    8000415c:	8b4080e7          	jalr	-1868(ra) # 80003a0c <bfree>
    80004160:	b7ed                	j	8000414a <itrunc+0x74>
    brelse(bp);
    80004162:	8552                	mv	a0,s4
    80004164:	fffff097          	auipc	ra,0xfffff
    80004168:	792080e7          	jalr	1938(ra) # 800038f6 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000416c:	0809a583          	lw	a1,128(s3)
    80004170:	0009a503          	lw	a0,0(s3)
    80004174:	00000097          	auipc	ra,0x0
    80004178:	898080e7          	jalr	-1896(ra) # 80003a0c <bfree>
    ip->addrs[NDIRECT] = 0;
    8000417c:	0809a023          	sw	zero,128(s3)
    80004180:	bf51                	j	80004114 <itrunc+0x3e>

0000000080004182 <iput>:
{
    80004182:	1101                	addi	sp,sp,-32
    80004184:	ec06                	sd	ra,24(sp)
    80004186:	e822                	sd	s0,16(sp)
    80004188:	e426                	sd	s1,8(sp)
    8000418a:	e04a                	sd	s2,0(sp)
    8000418c:	1000                	addi	s0,sp,32
    8000418e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004190:	0001c517          	auipc	a0,0x1c
    80004194:	dc050513          	addi	a0,a0,-576 # 8001ff50 <itable>
    80004198:	ffffd097          	auipc	ra,0xffffd
    8000419c:	a38080e7          	jalr	-1480(ra) # 80000bd0 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800041a0:	4498                	lw	a4,8(s1)
    800041a2:	4785                	li	a5,1
    800041a4:	02f70363          	beq	a4,a5,800041ca <iput+0x48>
  ip->ref--;
    800041a8:	449c                	lw	a5,8(s1)
    800041aa:	37fd                	addiw	a5,a5,-1
    800041ac:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800041ae:	0001c517          	auipc	a0,0x1c
    800041b2:	da250513          	addi	a0,a0,-606 # 8001ff50 <itable>
    800041b6:	ffffd097          	auipc	ra,0xffffd
    800041ba:	ace080e7          	jalr	-1330(ra) # 80000c84 <release>
}
    800041be:	60e2                	ld	ra,24(sp)
    800041c0:	6442                	ld	s0,16(sp)
    800041c2:	64a2                	ld	s1,8(sp)
    800041c4:	6902                	ld	s2,0(sp)
    800041c6:	6105                	addi	sp,sp,32
    800041c8:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800041ca:	40bc                	lw	a5,64(s1)
    800041cc:	dff1                	beqz	a5,800041a8 <iput+0x26>
    800041ce:	04a49783          	lh	a5,74(s1)
    800041d2:	fbf9                	bnez	a5,800041a8 <iput+0x26>
    acquiresleep(&ip->lock);
    800041d4:	01048913          	addi	s2,s1,16
    800041d8:	854a                	mv	a0,s2
    800041da:	00001097          	auipc	ra,0x1
    800041de:	abe080e7          	jalr	-1346(ra) # 80004c98 <acquiresleep>
    release(&itable.lock);
    800041e2:	0001c517          	auipc	a0,0x1c
    800041e6:	d6e50513          	addi	a0,a0,-658 # 8001ff50 <itable>
    800041ea:	ffffd097          	auipc	ra,0xffffd
    800041ee:	a9a080e7          	jalr	-1382(ra) # 80000c84 <release>
    itrunc(ip);
    800041f2:	8526                	mv	a0,s1
    800041f4:	00000097          	auipc	ra,0x0
    800041f8:	ee2080e7          	jalr	-286(ra) # 800040d6 <itrunc>
    ip->type = 0;
    800041fc:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80004200:	8526                	mv	a0,s1
    80004202:	00000097          	auipc	ra,0x0
    80004206:	cfa080e7          	jalr	-774(ra) # 80003efc <iupdate>
    ip->valid = 0;
    8000420a:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000420e:	854a                	mv	a0,s2
    80004210:	00001097          	auipc	ra,0x1
    80004214:	ade080e7          	jalr	-1314(ra) # 80004cee <releasesleep>
    acquire(&itable.lock);
    80004218:	0001c517          	auipc	a0,0x1c
    8000421c:	d3850513          	addi	a0,a0,-712 # 8001ff50 <itable>
    80004220:	ffffd097          	auipc	ra,0xffffd
    80004224:	9b0080e7          	jalr	-1616(ra) # 80000bd0 <acquire>
    80004228:	b741                	j	800041a8 <iput+0x26>

000000008000422a <iunlockput>:
{
    8000422a:	1101                	addi	sp,sp,-32
    8000422c:	ec06                	sd	ra,24(sp)
    8000422e:	e822                	sd	s0,16(sp)
    80004230:	e426                	sd	s1,8(sp)
    80004232:	1000                	addi	s0,sp,32
    80004234:	84aa                	mv	s1,a0
  iunlock(ip);
    80004236:	00000097          	auipc	ra,0x0
    8000423a:	e54080e7          	jalr	-428(ra) # 8000408a <iunlock>
  iput(ip);
    8000423e:	8526                	mv	a0,s1
    80004240:	00000097          	auipc	ra,0x0
    80004244:	f42080e7          	jalr	-190(ra) # 80004182 <iput>
}
    80004248:	60e2                	ld	ra,24(sp)
    8000424a:	6442                	ld	s0,16(sp)
    8000424c:	64a2                	ld	s1,8(sp)
    8000424e:	6105                	addi	sp,sp,32
    80004250:	8082                	ret

0000000080004252 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80004252:	1141                	addi	sp,sp,-16
    80004254:	e422                	sd	s0,8(sp)
    80004256:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004258:	411c                	lw	a5,0(a0)
    8000425a:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000425c:	415c                	lw	a5,4(a0)
    8000425e:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80004260:	04451783          	lh	a5,68(a0)
    80004264:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004268:	04a51783          	lh	a5,74(a0)
    8000426c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80004270:	04c56783          	lwu	a5,76(a0)
    80004274:	e99c                	sd	a5,16(a1)
}
    80004276:	6422                	ld	s0,8(sp)
    80004278:	0141                	addi	sp,sp,16
    8000427a:	8082                	ret

000000008000427c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000427c:	457c                	lw	a5,76(a0)
    8000427e:	0ed7e963          	bltu	a5,a3,80004370 <readi+0xf4>
{
    80004282:	7159                	addi	sp,sp,-112
    80004284:	f486                	sd	ra,104(sp)
    80004286:	f0a2                	sd	s0,96(sp)
    80004288:	eca6                	sd	s1,88(sp)
    8000428a:	e8ca                	sd	s2,80(sp)
    8000428c:	e4ce                	sd	s3,72(sp)
    8000428e:	e0d2                	sd	s4,64(sp)
    80004290:	fc56                	sd	s5,56(sp)
    80004292:	f85a                	sd	s6,48(sp)
    80004294:	f45e                	sd	s7,40(sp)
    80004296:	f062                	sd	s8,32(sp)
    80004298:	ec66                	sd	s9,24(sp)
    8000429a:	e86a                	sd	s10,16(sp)
    8000429c:	e46e                	sd	s11,8(sp)
    8000429e:	1880                	addi	s0,sp,112
    800042a0:	8baa                	mv	s7,a0
    800042a2:	8c2e                	mv	s8,a1
    800042a4:	8ab2                	mv	s5,a2
    800042a6:	84b6                	mv	s1,a3
    800042a8:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800042aa:	9f35                	addw	a4,a4,a3
    return 0;
    800042ac:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800042ae:	0ad76063          	bltu	a4,a3,8000434e <readi+0xd2>
  if(off + n > ip->size)
    800042b2:	00e7f463          	bgeu	a5,a4,800042ba <readi+0x3e>
    n = ip->size - off;
    800042b6:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800042ba:	0a0b0963          	beqz	s6,8000436c <readi+0xf0>
    800042be:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800042c0:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800042c4:	5cfd                	li	s9,-1
    800042c6:	a82d                	j	80004300 <readi+0x84>
    800042c8:	020a1d93          	slli	s11,s4,0x20
    800042cc:	020ddd93          	srli	s11,s11,0x20
    800042d0:	05890613          	addi	a2,s2,88
    800042d4:	86ee                	mv	a3,s11
    800042d6:	963a                	add	a2,a2,a4
    800042d8:	85d6                	mv	a1,s5
    800042da:	8562                	mv	a0,s8
    800042dc:	fffff097          	auipc	ra,0xfffff
    800042e0:	998080e7          	jalr	-1640(ra) # 80002c74 <either_copyout>
    800042e4:	05950d63          	beq	a0,s9,8000433e <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800042e8:	854a                	mv	a0,s2
    800042ea:	fffff097          	auipc	ra,0xfffff
    800042ee:	60c080e7          	jalr	1548(ra) # 800038f6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800042f2:	013a09bb          	addw	s3,s4,s3
    800042f6:	009a04bb          	addw	s1,s4,s1
    800042fa:	9aee                	add	s5,s5,s11
    800042fc:	0569f763          	bgeu	s3,s6,8000434a <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004300:	000ba903          	lw	s2,0(s7)
    80004304:	00a4d59b          	srliw	a1,s1,0xa
    80004308:	855e                	mv	a0,s7
    8000430a:	00000097          	auipc	ra,0x0
    8000430e:	8ac080e7          	jalr	-1876(ra) # 80003bb6 <bmap>
    80004312:	0005059b          	sext.w	a1,a0
    80004316:	854a                	mv	a0,s2
    80004318:	fffff097          	auipc	ra,0xfffff
    8000431c:	4ae080e7          	jalr	1198(ra) # 800037c6 <bread>
    80004320:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004322:	3ff4f713          	andi	a4,s1,1023
    80004326:	40ed07bb          	subw	a5,s10,a4
    8000432a:	413b06bb          	subw	a3,s6,s3
    8000432e:	8a3e                	mv	s4,a5
    80004330:	2781                	sext.w	a5,a5
    80004332:	0006861b          	sext.w	a2,a3
    80004336:	f8f679e3          	bgeu	a2,a5,800042c8 <readi+0x4c>
    8000433a:	8a36                	mv	s4,a3
    8000433c:	b771                	j	800042c8 <readi+0x4c>
      brelse(bp);
    8000433e:	854a                	mv	a0,s2
    80004340:	fffff097          	auipc	ra,0xfffff
    80004344:	5b6080e7          	jalr	1462(ra) # 800038f6 <brelse>
      tot = -1;
    80004348:	59fd                	li	s3,-1
  }
  return tot;
    8000434a:	0009851b          	sext.w	a0,s3
}
    8000434e:	70a6                	ld	ra,104(sp)
    80004350:	7406                	ld	s0,96(sp)
    80004352:	64e6                	ld	s1,88(sp)
    80004354:	6946                	ld	s2,80(sp)
    80004356:	69a6                	ld	s3,72(sp)
    80004358:	6a06                	ld	s4,64(sp)
    8000435a:	7ae2                	ld	s5,56(sp)
    8000435c:	7b42                	ld	s6,48(sp)
    8000435e:	7ba2                	ld	s7,40(sp)
    80004360:	7c02                	ld	s8,32(sp)
    80004362:	6ce2                	ld	s9,24(sp)
    80004364:	6d42                	ld	s10,16(sp)
    80004366:	6da2                	ld	s11,8(sp)
    80004368:	6165                	addi	sp,sp,112
    8000436a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000436c:	89da                	mv	s3,s6
    8000436e:	bff1                	j	8000434a <readi+0xce>
    return 0;
    80004370:	4501                	li	a0,0
}
    80004372:	8082                	ret

0000000080004374 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004374:	457c                	lw	a5,76(a0)
    80004376:	10d7e863          	bltu	a5,a3,80004486 <writei+0x112>
{
    8000437a:	7159                	addi	sp,sp,-112
    8000437c:	f486                	sd	ra,104(sp)
    8000437e:	f0a2                	sd	s0,96(sp)
    80004380:	eca6                	sd	s1,88(sp)
    80004382:	e8ca                	sd	s2,80(sp)
    80004384:	e4ce                	sd	s3,72(sp)
    80004386:	e0d2                	sd	s4,64(sp)
    80004388:	fc56                	sd	s5,56(sp)
    8000438a:	f85a                	sd	s6,48(sp)
    8000438c:	f45e                	sd	s7,40(sp)
    8000438e:	f062                	sd	s8,32(sp)
    80004390:	ec66                	sd	s9,24(sp)
    80004392:	e86a                	sd	s10,16(sp)
    80004394:	e46e                	sd	s11,8(sp)
    80004396:	1880                	addi	s0,sp,112
    80004398:	8b2a                	mv	s6,a0
    8000439a:	8c2e                	mv	s8,a1
    8000439c:	8ab2                	mv	s5,a2
    8000439e:	8936                	mv	s2,a3
    800043a0:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    800043a2:	00e687bb          	addw	a5,a3,a4
    800043a6:	0ed7e263          	bltu	a5,a3,8000448a <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800043aa:	00043737          	lui	a4,0x43
    800043ae:	0ef76063          	bltu	a4,a5,8000448e <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800043b2:	0c0b8863          	beqz	s7,80004482 <writei+0x10e>
    800043b6:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800043b8:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800043bc:	5cfd                	li	s9,-1
    800043be:	a091                	j	80004402 <writei+0x8e>
    800043c0:	02099d93          	slli	s11,s3,0x20
    800043c4:	020ddd93          	srli	s11,s11,0x20
    800043c8:	05848513          	addi	a0,s1,88
    800043cc:	86ee                	mv	a3,s11
    800043ce:	8656                	mv	a2,s5
    800043d0:	85e2                	mv	a1,s8
    800043d2:	953a                	add	a0,a0,a4
    800043d4:	fffff097          	auipc	ra,0xfffff
    800043d8:	8f6080e7          	jalr	-1802(ra) # 80002cca <either_copyin>
    800043dc:	07950263          	beq	a0,s9,80004440 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    800043e0:	8526                	mv	a0,s1
    800043e2:	00000097          	auipc	ra,0x0
    800043e6:	798080e7          	jalr	1944(ra) # 80004b7a <log_write>
    brelse(bp);
    800043ea:	8526                	mv	a0,s1
    800043ec:	fffff097          	auipc	ra,0xfffff
    800043f0:	50a080e7          	jalr	1290(ra) # 800038f6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800043f4:	01498a3b          	addw	s4,s3,s4
    800043f8:	0129893b          	addw	s2,s3,s2
    800043fc:	9aee                	add	s5,s5,s11
    800043fe:	057a7663          	bgeu	s4,s7,8000444a <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004402:	000b2483          	lw	s1,0(s6)
    80004406:	00a9559b          	srliw	a1,s2,0xa
    8000440a:	855a                	mv	a0,s6
    8000440c:	fffff097          	auipc	ra,0xfffff
    80004410:	7aa080e7          	jalr	1962(ra) # 80003bb6 <bmap>
    80004414:	0005059b          	sext.w	a1,a0
    80004418:	8526                	mv	a0,s1
    8000441a:	fffff097          	auipc	ra,0xfffff
    8000441e:	3ac080e7          	jalr	940(ra) # 800037c6 <bread>
    80004422:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004424:	3ff97713          	andi	a4,s2,1023
    80004428:	40ed07bb          	subw	a5,s10,a4
    8000442c:	414b86bb          	subw	a3,s7,s4
    80004430:	89be                	mv	s3,a5
    80004432:	2781                	sext.w	a5,a5
    80004434:	0006861b          	sext.w	a2,a3
    80004438:	f8f674e3          	bgeu	a2,a5,800043c0 <writei+0x4c>
    8000443c:	89b6                	mv	s3,a3
    8000443e:	b749                	j	800043c0 <writei+0x4c>
      brelse(bp);
    80004440:	8526                	mv	a0,s1
    80004442:	fffff097          	auipc	ra,0xfffff
    80004446:	4b4080e7          	jalr	1204(ra) # 800038f6 <brelse>
  }

  if(off > ip->size)
    8000444a:	04cb2783          	lw	a5,76(s6)
    8000444e:	0127f463          	bgeu	a5,s2,80004456 <writei+0xe2>
    ip->size = off;
    80004452:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004456:	855a                	mv	a0,s6
    80004458:	00000097          	auipc	ra,0x0
    8000445c:	aa4080e7          	jalr	-1372(ra) # 80003efc <iupdate>

  return tot;
    80004460:	000a051b          	sext.w	a0,s4
}
    80004464:	70a6                	ld	ra,104(sp)
    80004466:	7406                	ld	s0,96(sp)
    80004468:	64e6                	ld	s1,88(sp)
    8000446a:	6946                	ld	s2,80(sp)
    8000446c:	69a6                	ld	s3,72(sp)
    8000446e:	6a06                	ld	s4,64(sp)
    80004470:	7ae2                	ld	s5,56(sp)
    80004472:	7b42                	ld	s6,48(sp)
    80004474:	7ba2                	ld	s7,40(sp)
    80004476:	7c02                	ld	s8,32(sp)
    80004478:	6ce2                	ld	s9,24(sp)
    8000447a:	6d42                	ld	s10,16(sp)
    8000447c:	6da2                	ld	s11,8(sp)
    8000447e:	6165                	addi	sp,sp,112
    80004480:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004482:	8a5e                	mv	s4,s7
    80004484:	bfc9                	j	80004456 <writei+0xe2>
    return -1;
    80004486:	557d                	li	a0,-1
}
    80004488:	8082                	ret
    return -1;
    8000448a:	557d                	li	a0,-1
    8000448c:	bfe1                	j	80004464 <writei+0xf0>
    return -1;
    8000448e:	557d                	li	a0,-1
    80004490:	bfd1                	j	80004464 <writei+0xf0>

0000000080004492 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004492:	1141                	addi	sp,sp,-16
    80004494:	e406                	sd	ra,8(sp)
    80004496:	e022                	sd	s0,0(sp)
    80004498:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000449a:	4639                	li	a2,14
    8000449c:	ffffd097          	auipc	ra,0xffffd
    800044a0:	900080e7          	jalr	-1792(ra) # 80000d9c <strncmp>
}
    800044a4:	60a2                	ld	ra,8(sp)
    800044a6:	6402                	ld	s0,0(sp)
    800044a8:	0141                	addi	sp,sp,16
    800044aa:	8082                	ret

00000000800044ac <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800044ac:	7139                	addi	sp,sp,-64
    800044ae:	fc06                	sd	ra,56(sp)
    800044b0:	f822                	sd	s0,48(sp)
    800044b2:	f426                	sd	s1,40(sp)
    800044b4:	f04a                	sd	s2,32(sp)
    800044b6:	ec4e                	sd	s3,24(sp)
    800044b8:	e852                	sd	s4,16(sp)
    800044ba:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800044bc:	04451703          	lh	a4,68(a0)
    800044c0:	4785                	li	a5,1
    800044c2:	00f71a63          	bne	a4,a5,800044d6 <dirlookup+0x2a>
    800044c6:	892a                	mv	s2,a0
    800044c8:	89ae                	mv	s3,a1
    800044ca:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800044cc:	457c                	lw	a5,76(a0)
    800044ce:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800044d0:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800044d2:	e79d                	bnez	a5,80004500 <dirlookup+0x54>
    800044d4:	a8a5                	j	8000454c <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800044d6:	00004517          	auipc	a0,0x4
    800044da:	22a50513          	addi	a0,a0,554 # 80008700 <syscalls+0x1c8>
    800044de:	ffffc097          	auipc	ra,0xffffc
    800044e2:	05c080e7          	jalr	92(ra) # 8000053a <panic>
      panic("dirlookup read");
    800044e6:	00004517          	auipc	a0,0x4
    800044ea:	23250513          	addi	a0,a0,562 # 80008718 <syscalls+0x1e0>
    800044ee:	ffffc097          	auipc	ra,0xffffc
    800044f2:	04c080e7          	jalr	76(ra) # 8000053a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800044f6:	24c1                	addiw	s1,s1,16
    800044f8:	04c92783          	lw	a5,76(s2)
    800044fc:	04f4f763          	bgeu	s1,a5,8000454a <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004500:	4741                	li	a4,16
    80004502:	86a6                	mv	a3,s1
    80004504:	fc040613          	addi	a2,s0,-64
    80004508:	4581                	li	a1,0
    8000450a:	854a                	mv	a0,s2
    8000450c:	00000097          	auipc	ra,0x0
    80004510:	d70080e7          	jalr	-656(ra) # 8000427c <readi>
    80004514:	47c1                	li	a5,16
    80004516:	fcf518e3          	bne	a0,a5,800044e6 <dirlookup+0x3a>
    if(de.inum == 0)
    8000451a:	fc045783          	lhu	a5,-64(s0)
    8000451e:	dfe1                	beqz	a5,800044f6 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004520:	fc240593          	addi	a1,s0,-62
    80004524:	854e                	mv	a0,s3
    80004526:	00000097          	auipc	ra,0x0
    8000452a:	f6c080e7          	jalr	-148(ra) # 80004492 <namecmp>
    8000452e:	f561                	bnez	a0,800044f6 <dirlookup+0x4a>
      if(poff)
    80004530:	000a0463          	beqz	s4,80004538 <dirlookup+0x8c>
        *poff = off;
    80004534:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004538:	fc045583          	lhu	a1,-64(s0)
    8000453c:	00092503          	lw	a0,0(s2)
    80004540:	fffff097          	auipc	ra,0xfffff
    80004544:	752080e7          	jalr	1874(ra) # 80003c92 <iget>
    80004548:	a011                	j	8000454c <dirlookup+0xa0>
  return 0;
    8000454a:	4501                	li	a0,0
}
    8000454c:	70e2                	ld	ra,56(sp)
    8000454e:	7442                	ld	s0,48(sp)
    80004550:	74a2                	ld	s1,40(sp)
    80004552:	7902                	ld	s2,32(sp)
    80004554:	69e2                	ld	s3,24(sp)
    80004556:	6a42                	ld	s4,16(sp)
    80004558:	6121                	addi	sp,sp,64
    8000455a:	8082                	ret

000000008000455c <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000455c:	711d                	addi	sp,sp,-96
    8000455e:	ec86                	sd	ra,88(sp)
    80004560:	e8a2                	sd	s0,80(sp)
    80004562:	e4a6                	sd	s1,72(sp)
    80004564:	e0ca                	sd	s2,64(sp)
    80004566:	fc4e                	sd	s3,56(sp)
    80004568:	f852                	sd	s4,48(sp)
    8000456a:	f456                	sd	s5,40(sp)
    8000456c:	f05a                	sd	s6,32(sp)
    8000456e:	ec5e                	sd	s7,24(sp)
    80004570:	e862                	sd	s8,16(sp)
    80004572:	e466                	sd	s9,8(sp)
    80004574:	e06a                	sd	s10,0(sp)
    80004576:	1080                	addi	s0,sp,96
    80004578:	84aa                	mv	s1,a0
    8000457a:	8b2e                	mv	s6,a1
    8000457c:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000457e:	00054703          	lbu	a4,0(a0)
    80004582:	02f00793          	li	a5,47
    80004586:	02f70363          	beq	a4,a5,800045ac <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000458a:	ffffd097          	auipc	ra,0xffffd
    8000458e:	494080e7          	jalr	1172(ra) # 80001a1e <myproc>
    80004592:	16053503          	ld	a0,352(a0)
    80004596:	00000097          	auipc	ra,0x0
    8000459a:	9f4080e7          	jalr	-1548(ra) # 80003f8a <idup>
    8000459e:	8a2a                	mv	s4,a0
  while(*path == '/')
    800045a0:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800045a4:	4cb5                	li	s9,13
  len = path - s;
    800045a6:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800045a8:	4c05                	li	s8,1
    800045aa:	a87d                	j	80004668 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    800045ac:	4585                	li	a1,1
    800045ae:	4505                	li	a0,1
    800045b0:	fffff097          	auipc	ra,0xfffff
    800045b4:	6e2080e7          	jalr	1762(ra) # 80003c92 <iget>
    800045b8:	8a2a                	mv	s4,a0
    800045ba:	b7dd                	j	800045a0 <namex+0x44>
      iunlockput(ip);
    800045bc:	8552                	mv	a0,s4
    800045be:	00000097          	auipc	ra,0x0
    800045c2:	c6c080e7          	jalr	-916(ra) # 8000422a <iunlockput>
      return 0;
    800045c6:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800045c8:	8552                	mv	a0,s4
    800045ca:	60e6                	ld	ra,88(sp)
    800045cc:	6446                	ld	s0,80(sp)
    800045ce:	64a6                	ld	s1,72(sp)
    800045d0:	6906                	ld	s2,64(sp)
    800045d2:	79e2                	ld	s3,56(sp)
    800045d4:	7a42                	ld	s4,48(sp)
    800045d6:	7aa2                	ld	s5,40(sp)
    800045d8:	7b02                	ld	s6,32(sp)
    800045da:	6be2                	ld	s7,24(sp)
    800045dc:	6c42                	ld	s8,16(sp)
    800045de:	6ca2                	ld	s9,8(sp)
    800045e0:	6d02                	ld	s10,0(sp)
    800045e2:	6125                	addi	sp,sp,96
    800045e4:	8082                	ret
      iunlock(ip);
    800045e6:	8552                	mv	a0,s4
    800045e8:	00000097          	auipc	ra,0x0
    800045ec:	aa2080e7          	jalr	-1374(ra) # 8000408a <iunlock>
      return ip;
    800045f0:	bfe1                	j	800045c8 <namex+0x6c>
      iunlockput(ip);
    800045f2:	8552                	mv	a0,s4
    800045f4:	00000097          	auipc	ra,0x0
    800045f8:	c36080e7          	jalr	-970(ra) # 8000422a <iunlockput>
      return 0;
    800045fc:	8a4e                	mv	s4,s3
    800045fe:	b7e9                	j	800045c8 <namex+0x6c>
  len = path - s;
    80004600:	40998633          	sub	a2,s3,s1
    80004604:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80004608:	09acd863          	bge	s9,s10,80004698 <namex+0x13c>
    memmove(name, s, DIRSIZ);
    8000460c:	4639                	li	a2,14
    8000460e:	85a6                	mv	a1,s1
    80004610:	8556                	mv	a0,s5
    80004612:	ffffc097          	auipc	ra,0xffffc
    80004616:	716080e7          	jalr	1814(ra) # 80000d28 <memmove>
    8000461a:	84ce                	mv	s1,s3
  while(*path == '/')
    8000461c:	0004c783          	lbu	a5,0(s1)
    80004620:	01279763          	bne	a5,s2,8000462e <namex+0xd2>
    path++;
    80004624:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004626:	0004c783          	lbu	a5,0(s1)
    8000462a:	ff278de3          	beq	a5,s2,80004624 <namex+0xc8>
    ilock(ip);
    8000462e:	8552                	mv	a0,s4
    80004630:	00000097          	auipc	ra,0x0
    80004634:	998080e7          	jalr	-1640(ra) # 80003fc8 <ilock>
    if(ip->type != T_DIR){
    80004638:	044a1783          	lh	a5,68(s4)
    8000463c:	f98790e3          	bne	a5,s8,800045bc <namex+0x60>
    if(nameiparent && *path == '\0'){
    80004640:	000b0563          	beqz	s6,8000464a <namex+0xee>
    80004644:	0004c783          	lbu	a5,0(s1)
    80004648:	dfd9                	beqz	a5,800045e6 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000464a:	865e                	mv	a2,s7
    8000464c:	85d6                	mv	a1,s5
    8000464e:	8552                	mv	a0,s4
    80004650:	00000097          	auipc	ra,0x0
    80004654:	e5c080e7          	jalr	-420(ra) # 800044ac <dirlookup>
    80004658:	89aa                	mv	s3,a0
    8000465a:	dd41                	beqz	a0,800045f2 <namex+0x96>
    iunlockput(ip);
    8000465c:	8552                	mv	a0,s4
    8000465e:	00000097          	auipc	ra,0x0
    80004662:	bcc080e7          	jalr	-1076(ra) # 8000422a <iunlockput>
    ip = next;
    80004666:	8a4e                	mv	s4,s3
  while(*path == '/')
    80004668:	0004c783          	lbu	a5,0(s1)
    8000466c:	01279763          	bne	a5,s2,8000467a <namex+0x11e>
    path++;
    80004670:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004672:	0004c783          	lbu	a5,0(s1)
    80004676:	ff278de3          	beq	a5,s2,80004670 <namex+0x114>
  if(*path == 0)
    8000467a:	cb9d                	beqz	a5,800046b0 <namex+0x154>
  while(*path != '/' && *path != 0)
    8000467c:	0004c783          	lbu	a5,0(s1)
    80004680:	89a6                	mv	s3,s1
  len = path - s;
    80004682:	8d5e                	mv	s10,s7
    80004684:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80004686:	01278963          	beq	a5,s2,80004698 <namex+0x13c>
    8000468a:	dbbd                	beqz	a5,80004600 <namex+0xa4>
    path++;
    8000468c:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    8000468e:	0009c783          	lbu	a5,0(s3)
    80004692:	ff279ce3          	bne	a5,s2,8000468a <namex+0x12e>
    80004696:	b7ad                	j	80004600 <namex+0xa4>
    memmove(name, s, len);
    80004698:	2601                	sext.w	a2,a2
    8000469a:	85a6                	mv	a1,s1
    8000469c:	8556                	mv	a0,s5
    8000469e:	ffffc097          	auipc	ra,0xffffc
    800046a2:	68a080e7          	jalr	1674(ra) # 80000d28 <memmove>
    name[len] = 0;
    800046a6:	9d56                	add	s10,s10,s5
    800046a8:	000d0023          	sb	zero,0(s10)
    800046ac:	84ce                	mv	s1,s3
    800046ae:	b7bd                	j	8000461c <namex+0xc0>
  if(nameiparent){
    800046b0:	f00b0ce3          	beqz	s6,800045c8 <namex+0x6c>
    iput(ip);
    800046b4:	8552                	mv	a0,s4
    800046b6:	00000097          	auipc	ra,0x0
    800046ba:	acc080e7          	jalr	-1332(ra) # 80004182 <iput>
    return 0;
    800046be:	4a01                	li	s4,0
    800046c0:	b721                	j	800045c8 <namex+0x6c>

00000000800046c2 <dirlink>:
{
    800046c2:	7139                	addi	sp,sp,-64
    800046c4:	fc06                	sd	ra,56(sp)
    800046c6:	f822                	sd	s0,48(sp)
    800046c8:	f426                	sd	s1,40(sp)
    800046ca:	f04a                	sd	s2,32(sp)
    800046cc:	ec4e                	sd	s3,24(sp)
    800046ce:	e852                	sd	s4,16(sp)
    800046d0:	0080                	addi	s0,sp,64
    800046d2:	892a                	mv	s2,a0
    800046d4:	8a2e                	mv	s4,a1
    800046d6:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800046d8:	4601                	li	a2,0
    800046da:	00000097          	auipc	ra,0x0
    800046de:	dd2080e7          	jalr	-558(ra) # 800044ac <dirlookup>
    800046e2:	e93d                	bnez	a0,80004758 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800046e4:	04c92483          	lw	s1,76(s2)
    800046e8:	c49d                	beqz	s1,80004716 <dirlink+0x54>
    800046ea:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800046ec:	4741                	li	a4,16
    800046ee:	86a6                	mv	a3,s1
    800046f0:	fc040613          	addi	a2,s0,-64
    800046f4:	4581                	li	a1,0
    800046f6:	854a                	mv	a0,s2
    800046f8:	00000097          	auipc	ra,0x0
    800046fc:	b84080e7          	jalr	-1148(ra) # 8000427c <readi>
    80004700:	47c1                	li	a5,16
    80004702:	06f51163          	bne	a0,a5,80004764 <dirlink+0xa2>
    if(de.inum == 0)
    80004706:	fc045783          	lhu	a5,-64(s0)
    8000470a:	c791                	beqz	a5,80004716 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000470c:	24c1                	addiw	s1,s1,16
    8000470e:	04c92783          	lw	a5,76(s2)
    80004712:	fcf4ede3          	bltu	s1,a5,800046ec <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004716:	4639                	li	a2,14
    80004718:	85d2                	mv	a1,s4
    8000471a:	fc240513          	addi	a0,s0,-62
    8000471e:	ffffc097          	auipc	ra,0xffffc
    80004722:	6ba080e7          	jalr	1722(ra) # 80000dd8 <strncpy>
  de.inum = inum;
    80004726:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000472a:	4741                	li	a4,16
    8000472c:	86a6                	mv	a3,s1
    8000472e:	fc040613          	addi	a2,s0,-64
    80004732:	4581                	li	a1,0
    80004734:	854a                	mv	a0,s2
    80004736:	00000097          	auipc	ra,0x0
    8000473a:	c3e080e7          	jalr	-962(ra) # 80004374 <writei>
    8000473e:	872a                	mv	a4,a0
    80004740:	47c1                	li	a5,16
  return 0;
    80004742:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004744:	02f71863          	bne	a4,a5,80004774 <dirlink+0xb2>
}
    80004748:	70e2                	ld	ra,56(sp)
    8000474a:	7442                	ld	s0,48(sp)
    8000474c:	74a2                	ld	s1,40(sp)
    8000474e:	7902                	ld	s2,32(sp)
    80004750:	69e2                	ld	s3,24(sp)
    80004752:	6a42                	ld	s4,16(sp)
    80004754:	6121                	addi	sp,sp,64
    80004756:	8082                	ret
    iput(ip);
    80004758:	00000097          	auipc	ra,0x0
    8000475c:	a2a080e7          	jalr	-1494(ra) # 80004182 <iput>
    return -1;
    80004760:	557d                	li	a0,-1
    80004762:	b7dd                	j	80004748 <dirlink+0x86>
      panic("dirlink read");
    80004764:	00004517          	auipc	a0,0x4
    80004768:	fc450513          	addi	a0,a0,-60 # 80008728 <syscalls+0x1f0>
    8000476c:	ffffc097          	auipc	ra,0xffffc
    80004770:	dce080e7          	jalr	-562(ra) # 8000053a <panic>
    panic("dirlink");
    80004774:	00004517          	auipc	a0,0x4
    80004778:	0c450513          	addi	a0,a0,196 # 80008838 <syscalls+0x300>
    8000477c:	ffffc097          	auipc	ra,0xffffc
    80004780:	dbe080e7          	jalr	-578(ra) # 8000053a <panic>

0000000080004784 <namei>:

struct inode*
namei(char *path)
{
    80004784:	1101                	addi	sp,sp,-32
    80004786:	ec06                	sd	ra,24(sp)
    80004788:	e822                	sd	s0,16(sp)
    8000478a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000478c:	fe040613          	addi	a2,s0,-32
    80004790:	4581                	li	a1,0
    80004792:	00000097          	auipc	ra,0x0
    80004796:	dca080e7          	jalr	-566(ra) # 8000455c <namex>
}
    8000479a:	60e2                	ld	ra,24(sp)
    8000479c:	6442                	ld	s0,16(sp)
    8000479e:	6105                	addi	sp,sp,32
    800047a0:	8082                	ret

00000000800047a2 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800047a2:	1141                	addi	sp,sp,-16
    800047a4:	e406                	sd	ra,8(sp)
    800047a6:	e022                	sd	s0,0(sp)
    800047a8:	0800                	addi	s0,sp,16
    800047aa:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800047ac:	4585                	li	a1,1
    800047ae:	00000097          	auipc	ra,0x0
    800047b2:	dae080e7          	jalr	-594(ra) # 8000455c <namex>
}
    800047b6:	60a2                	ld	ra,8(sp)
    800047b8:	6402                	ld	s0,0(sp)
    800047ba:	0141                	addi	sp,sp,16
    800047bc:	8082                	ret

00000000800047be <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800047be:	1101                	addi	sp,sp,-32
    800047c0:	ec06                	sd	ra,24(sp)
    800047c2:	e822                	sd	s0,16(sp)
    800047c4:	e426                	sd	s1,8(sp)
    800047c6:	e04a                	sd	s2,0(sp)
    800047c8:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800047ca:	0001d917          	auipc	s2,0x1d
    800047ce:	22e90913          	addi	s2,s2,558 # 800219f8 <log>
    800047d2:	01892583          	lw	a1,24(s2)
    800047d6:	02892503          	lw	a0,40(s2)
    800047da:	fffff097          	auipc	ra,0xfffff
    800047de:	fec080e7          	jalr	-20(ra) # 800037c6 <bread>
    800047e2:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800047e4:	02c92683          	lw	a3,44(s2)
    800047e8:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800047ea:	02d05863          	blez	a3,8000481a <write_head+0x5c>
    800047ee:	0001d797          	auipc	a5,0x1d
    800047f2:	23a78793          	addi	a5,a5,570 # 80021a28 <log+0x30>
    800047f6:	05c50713          	addi	a4,a0,92
    800047fa:	36fd                	addiw	a3,a3,-1
    800047fc:	02069613          	slli	a2,a3,0x20
    80004800:	01e65693          	srli	a3,a2,0x1e
    80004804:	0001d617          	auipc	a2,0x1d
    80004808:	22860613          	addi	a2,a2,552 # 80021a2c <log+0x34>
    8000480c:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    8000480e:	4390                	lw	a2,0(a5)
    80004810:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004812:	0791                	addi	a5,a5,4
    80004814:	0711                	addi	a4,a4,4
    80004816:	fed79ce3          	bne	a5,a3,8000480e <write_head+0x50>
  }
  bwrite(buf);
    8000481a:	8526                	mv	a0,s1
    8000481c:	fffff097          	auipc	ra,0xfffff
    80004820:	09c080e7          	jalr	156(ra) # 800038b8 <bwrite>
  brelse(buf);
    80004824:	8526                	mv	a0,s1
    80004826:	fffff097          	auipc	ra,0xfffff
    8000482a:	0d0080e7          	jalr	208(ra) # 800038f6 <brelse>
}
    8000482e:	60e2                	ld	ra,24(sp)
    80004830:	6442                	ld	s0,16(sp)
    80004832:	64a2                	ld	s1,8(sp)
    80004834:	6902                	ld	s2,0(sp)
    80004836:	6105                	addi	sp,sp,32
    80004838:	8082                	ret

000000008000483a <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000483a:	0001d797          	auipc	a5,0x1d
    8000483e:	1ea7a783          	lw	a5,490(a5) # 80021a24 <log+0x2c>
    80004842:	0af05d63          	blez	a5,800048fc <install_trans+0xc2>
{
    80004846:	7139                	addi	sp,sp,-64
    80004848:	fc06                	sd	ra,56(sp)
    8000484a:	f822                	sd	s0,48(sp)
    8000484c:	f426                	sd	s1,40(sp)
    8000484e:	f04a                	sd	s2,32(sp)
    80004850:	ec4e                	sd	s3,24(sp)
    80004852:	e852                	sd	s4,16(sp)
    80004854:	e456                	sd	s5,8(sp)
    80004856:	e05a                	sd	s6,0(sp)
    80004858:	0080                	addi	s0,sp,64
    8000485a:	8b2a                	mv	s6,a0
    8000485c:	0001da97          	auipc	s5,0x1d
    80004860:	1cca8a93          	addi	s5,s5,460 # 80021a28 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004864:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004866:	0001d997          	auipc	s3,0x1d
    8000486a:	19298993          	addi	s3,s3,402 # 800219f8 <log>
    8000486e:	a00d                	j	80004890 <install_trans+0x56>
    brelse(lbuf);
    80004870:	854a                	mv	a0,s2
    80004872:	fffff097          	auipc	ra,0xfffff
    80004876:	084080e7          	jalr	132(ra) # 800038f6 <brelse>
    brelse(dbuf);
    8000487a:	8526                	mv	a0,s1
    8000487c:	fffff097          	auipc	ra,0xfffff
    80004880:	07a080e7          	jalr	122(ra) # 800038f6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004884:	2a05                	addiw	s4,s4,1
    80004886:	0a91                	addi	s5,s5,4
    80004888:	02c9a783          	lw	a5,44(s3)
    8000488c:	04fa5e63          	bge	s4,a5,800048e8 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004890:	0189a583          	lw	a1,24(s3)
    80004894:	014585bb          	addw	a1,a1,s4
    80004898:	2585                	addiw	a1,a1,1
    8000489a:	0289a503          	lw	a0,40(s3)
    8000489e:	fffff097          	auipc	ra,0xfffff
    800048a2:	f28080e7          	jalr	-216(ra) # 800037c6 <bread>
    800048a6:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800048a8:	000aa583          	lw	a1,0(s5)
    800048ac:	0289a503          	lw	a0,40(s3)
    800048b0:	fffff097          	auipc	ra,0xfffff
    800048b4:	f16080e7          	jalr	-234(ra) # 800037c6 <bread>
    800048b8:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800048ba:	40000613          	li	a2,1024
    800048be:	05890593          	addi	a1,s2,88
    800048c2:	05850513          	addi	a0,a0,88
    800048c6:	ffffc097          	auipc	ra,0xffffc
    800048ca:	462080e7          	jalr	1122(ra) # 80000d28 <memmove>
    bwrite(dbuf);  // write dst to disk
    800048ce:	8526                	mv	a0,s1
    800048d0:	fffff097          	auipc	ra,0xfffff
    800048d4:	fe8080e7          	jalr	-24(ra) # 800038b8 <bwrite>
    if(recovering == 0)
    800048d8:	f80b1ce3          	bnez	s6,80004870 <install_trans+0x36>
      bunpin(dbuf);
    800048dc:	8526                	mv	a0,s1
    800048de:	fffff097          	auipc	ra,0xfffff
    800048e2:	0f2080e7          	jalr	242(ra) # 800039d0 <bunpin>
    800048e6:	b769                	j	80004870 <install_trans+0x36>
}
    800048e8:	70e2                	ld	ra,56(sp)
    800048ea:	7442                	ld	s0,48(sp)
    800048ec:	74a2                	ld	s1,40(sp)
    800048ee:	7902                	ld	s2,32(sp)
    800048f0:	69e2                	ld	s3,24(sp)
    800048f2:	6a42                	ld	s4,16(sp)
    800048f4:	6aa2                	ld	s5,8(sp)
    800048f6:	6b02                	ld	s6,0(sp)
    800048f8:	6121                	addi	sp,sp,64
    800048fa:	8082                	ret
    800048fc:	8082                	ret

00000000800048fe <initlog>:
{
    800048fe:	7179                	addi	sp,sp,-48
    80004900:	f406                	sd	ra,40(sp)
    80004902:	f022                	sd	s0,32(sp)
    80004904:	ec26                	sd	s1,24(sp)
    80004906:	e84a                	sd	s2,16(sp)
    80004908:	e44e                	sd	s3,8(sp)
    8000490a:	1800                	addi	s0,sp,48
    8000490c:	892a                	mv	s2,a0
    8000490e:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004910:	0001d497          	auipc	s1,0x1d
    80004914:	0e848493          	addi	s1,s1,232 # 800219f8 <log>
    80004918:	00004597          	auipc	a1,0x4
    8000491c:	e2058593          	addi	a1,a1,-480 # 80008738 <syscalls+0x200>
    80004920:	8526                	mv	a0,s1
    80004922:	ffffc097          	auipc	ra,0xffffc
    80004926:	21e080e7          	jalr	542(ra) # 80000b40 <initlock>
  log.start = sb->logstart;
    8000492a:	0149a583          	lw	a1,20(s3)
    8000492e:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004930:	0109a783          	lw	a5,16(s3)
    80004934:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004936:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000493a:	854a                	mv	a0,s2
    8000493c:	fffff097          	auipc	ra,0xfffff
    80004940:	e8a080e7          	jalr	-374(ra) # 800037c6 <bread>
  log.lh.n = lh->n;
    80004944:	4d34                	lw	a3,88(a0)
    80004946:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004948:	02d05663          	blez	a3,80004974 <initlog+0x76>
    8000494c:	05c50793          	addi	a5,a0,92
    80004950:	0001d717          	auipc	a4,0x1d
    80004954:	0d870713          	addi	a4,a4,216 # 80021a28 <log+0x30>
    80004958:	36fd                	addiw	a3,a3,-1
    8000495a:	02069613          	slli	a2,a3,0x20
    8000495e:	01e65693          	srli	a3,a2,0x1e
    80004962:	06050613          	addi	a2,a0,96
    80004966:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004968:	4390                	lw	a2,0(a5)
    8000496a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000496c:	0791                	addi	a5,a5,4
    8000496e:	0711                	addi	a4,a4,4
    80004970:	fed79ce3          	bne	a5,a3,80004968 <initlog+0x6a>
  brelse(buf);
    80004974:	fffff097          	auipc	ra,0xfffff
    80004978:	f82080e7          	jalr	-126(ra) # 800038f6 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000497c:	4505                	li	a0,1
    8000497e:	00000097          	auipc	ra,0x0
    80004982:	ebc080e7          	jalr	-324(ra) # 8000483a <install_trans>
  log.lh.n = 0;
    80004986:	0001d797          	auipc	a5,0x1d
    8000498a:	0807af23          	sw	zero,158(a5) # 80021a24 <log+0x2c>
  write_head(); // clear the log
    8000498e:	00000097          	auipc	ra,0x0
    80004992:	e30080e7          	jalr	-464(ra) # 800047be <write_head>
}
    80004996:	70a2                	ld	ra,40(sp)
    80004998:	7402                	ld	s0,32(sp)
    8000499a:	64e2                	ld	s1,24(sp)
    8000499c:	6942                	ld	s2,16(sp)
    8000499e:	69a2                	ld	s3,8(sp)
    800049a0:	6145                	addi	sp,sp,48
    800049a2:	8082                	ret

00000000800049a4 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800049a4:	1101                	addi	sp,sp,-32
    800049a6:	ec06                	sd	ra,24(sp)
    800049a8:	e822                	sd	s0,16(sp)
    800049aa:	e426                	sd	s1,8(sp)
    800049ac:	e04a                	sd	s2,0(sp)
    800049ae:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800049b0:	0001d517          	auipc	a0,0x1d
    800049b4:	04850513          	addi	a0,a0,72 # 800219f8 <log>
    800049b8:	ffffc097          	auipc	ra,0xffffc
    800049bc:	218080e7          	jalr	536(ra) # 80000bd0 <acquire>
  while(1){
    if(log.committing){
    800049c0:	0001d497          	auipc	s1,0x1d
    800049c4:	03848493          	addi	s1,s1,56 # 800219f8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800049c8:	4979                	li	s2,30
    800049ca:	a039                	j	800049d8 <begin_op+0x34>
      sleep(&log, &log.lock);
    800049cc:	85a6                	mv	a1,s1
    800049ce:	8526                	mv	a0,s1
    800049d0:	ffffe097          	auipc	ra,0xffffe
    800049d4:	aae080e7          	jalr	-1362(ra) # 8000247e <sleep>
    if(log.committing){
    800049d8:	50dc                	lw	a5,36(s1)
    800049da:	fbed                	bnez	a5,800049cc <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800049dc:	5098                	lw	a4,32(s1)
    800049de:	2705                	addiw	a4,a4,1
    800049e0:	0007069b          	sext.w	a3,a4
    800049e4:	0027179b          	slliw	a5,a4,0x2
    800049e8:	9fb9                	addw	a5,a5,a4
    800049ea:	0017979b          	slliw	a5,a5,0x1
    800049ee:	54d8                	lw	a4,44(s1)
    800049f0:	9fb9                	addw	a5,a5,a4
    800049f2:	00f95963          	bge	s2,a5,80004a04 <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800049f6:	85a6                	mv	a1,s1
    800049f8:	8526                	mv	a0,s1
    800049fa:	ffffe097          	auipc	ra,0xffffe
    800049fe:	a84080e7          	jalr	-1404(ra) # 8000247e <sleep>
    80004a02:	bfd9                	j	800049d8 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004a04:	0001d517          	auipc	a0,0x1d
    80004a08:	ff450513          	addi	a0,a0,-12 # 800219f8 <log>
    80004a0c:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004a0e:	ffffc097          	auipc	ra,0xffffc
    80004a12:	276080e7          	jalr	630(ra) # 80000c84 <release>
      break;
    }
  }
}
    80004a16:	60e2                	ld	ra,24(sp)
    80004a18:	6442                	ld	s0,16(sp)
    80004a1a:	64a2                	ld	s1,8(sp)
    80004a1c:	6902                	ld	s2,0(sp)
    80004a1e:	6105                	addi	sp,sp,32
    80004a20:	8082                	ret

0000000080004a22 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004a22:	7139                	addi	sp,sp,-64
    80004a24:	fc06                	sd	ra,56(sp)
    80004a26:	f822                	sd	s0,48(sp)
    80004a28:	f426                	sd	s1,40(sp)
    80004a2a:	f04a                	sd	s2,32(sp)
    80004a2c:	ec4e                	sd	s3,24(sp)
    80004a2e:	e852                	sd	s4,16(sp)
    80004a30:	e456                	sd	s5,8(sp)
    80004a32:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004a34:	0001d497          	auipc	s1,0x1d
    80004a38:	fc448493          	addi	s1,s1,-60 # 800219f8 <log>
    80004a3c:	8526                	mv	a0,s1
    80004a3e:	ffffc097          	auipc	ra,0xffffc
    80004a42:	192080e7          	jalr	402(ra) # 80000bd0 <acquire>
  log.outstanding -= 1;
    80004a46:	509c                	lw	a5,32(s1)
    80004a48:	37fd                	addiw	a5,a5,-1
    80004a4a:	0007891b          	sext.w	s2,a5
    80004a4e:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004a50:	50dc                	lw	a5,36(s1)
    80004a52:	e7b9                	bnez	a5,80004aa0 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004a54:	04091e63          	bnez	s2,80004ab0 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004a58:	0001d497          	auipc	s1,0x1d
    80004a5c:	fa048493          	addi	s1,s1,-96 # 800219f8 <log>
    80004a60:	4785                	li	a5,1
    80004a62:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004a64:	8526                	mv	a0,s1
    80004a66:	ffffc097          	auipc	ra,0xffffc
    80004a6a:	21e080e7          	jalr	542(ra) # 80000c84 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004a6e:	54dc                	lw	a5,44(s1)
    80004a70:	06f04763          	bgtz	a5,80004ade <end_op+0xbc>
    acquire(&log.lock);
    80004a74:	0001d497          	auipc	s1,0x1d
    80004a78:	f8448493          	addi	s1,s1,-124 # 800219f8 <log>
    80004a7c:	8526                	mv	a0,s1
    80004a7e:	ffffc097          	auipc	ra,0xffffc
    80004a82:	152080e7          	jalr	338(ra) # 80000bd0 <acquire>
    log.committing = 0;
    80004a86:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004a8a:	8526                	mv	a0,s1
    80004a8c:	ffffe097          	auipc	ra,0xffffe
    80004a90:	eda080e7          	jalr	-294(ra) # 80002966 <wakeup>
    release(&log.lock);
    80004a94:	8526                	mv	a0,s1
    80004a96:	ffffc097          	auipc	ra,0xffffc
    80004a9a:	1ee080e7          	jalr	494(ra) # 80000c84 <release>
}
    80004a9e:	a03d                	j	80004acc <end_op+0xaa>
    panic("log.committing");
    80004aa0:	00004517          	auipc	a0,0x4
    80004aa4:	ca050513          	addi	a0,a0,-864 # 80008740 <syscalls+0x208>
    80004aa8:	ffffc097          	auipc	ra,0xffffc
    80004aac:	a92080e7          	jalr	-1390(ra) # 8000053a <panic>
    wakeup(&log);
    80004ab0:	0001d497          	auipc	s1,0x1d
    80004ab4:	f4848493          	addi	s1,s1,-184 # 800219f8 <log>
    80004ab8:	8526                	mv	a0,s1
    80004aba:	ffffe097          	auipc	ra,0xffffe
    80004abe:	eac080e7          	jalr	-340(ra) # 80002966 <wakeup>
  release(&log.lock);
    80004ac2:	8526                	mv	a0,s1
    80004ac4:	ffffc097          	auipc	ra,0xffffc
    80004ac8:	1c0080e7          	jalr	448(ra) # 80000c84 <release>
}
    80004acc:	70e2                	ld	ra,56(sp)
    80004ace:	7442                	ld	s0,48(sp)
    80004ad0:	74a2                	ld	s1,40(sp)
    80004ad2:	7902                	ld	s2,32(sp)
    80004ad4:	69e2                	ld	s3,24(sp)
    80004ad6:	6a42                	ld	s4,16(sp)
    80004ad8:	6aa2                	ld	s5,8(sp)
    80004ada:	6121                	addi	sp,sp,64
    80004adc:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004ade:	0001da97          	auipc	s5,0x1d
    80004ae2:	f4aa8a93          	addi	s5,s5,-182 # 80021a28 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004ae6:	0001da17          	auipc	s4,0x1d
    80004aea:	f12a0a13          	addi	s4,s4,-238 # 800219f8 <log>
    80004aee:	018a2583          	lw	a1,24(s4)
    80004af2:	012585bb          	addw	a1,a1,s2
    80004af6:	2585                	addiw	a1,a1,1
    80004af8:	028a2503          	lw	a0,40(s4)
    80004afc:	fffff097          	auipc	ra,0xfffff
    80004b00:	cca080e7          	jalr	-822(ra) # 800037c6 <bread>
    80004b04:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004b06:	000aa583          	lw	a1,0(s5)
    80004b0a:	028a2503          	lw	a0,40(s4)
    80004b0e:	fffff097          	auipc	ra,0xfffff
    80004b12:	cb8080e7          	jalr	-840(ra) # 800037c6 <bread>
    80004b16:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004b18:	40000613          	li	a2,1024
    80004b1c:	05850593          	addi	a1,a0,88
    80004b20:	05848513          	addi	a0,s1,88
    80004b24:	ffffc097          	auipc	ra,0xffffc
    80004b28:	204080e7          	jalr	516(ra) # 80000d28 <memmove>
    bwrite(to);  // write the log
    80004b2c:	8526                	mv	a0,s1
    80004b2e:	fffff097          	auipc	ra,0xfffff
    80004b32:	d8a080e7          	jalr	-630(ra) # 800038b8 <bwrite>
    brelse(from);
    80004b36:	854e                	mv	a0,s3
    80004b38:	fffff097          	auipc	ra,0xfffff
    80004b3c:	dbe080e7          	jalr	-578(ra) # 800038f6 <brelse>
    brelse(to);
    80004b40:	8526                	mv	a0,s1
    80004b42:	fffff097          	auipc	ra,0xfffff
    80004b46:	db4080e7          	jalr	-588(ra) # 800038f6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004b4a:	2905                	addiw	s2,s2,1
    80004b4c:	0a91                	addi	s5,s5,4
    80004b4e:	02ca2783          	lw	a5,44(s4)
    80004b52:	f8f94ee3          	blt	s2,a5,80004aee <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004b56:	00000097          	auipc	ra,0x0
    80004b5a:	c68080e7          	jalr	-920(ra) # 800047be <write_head>
    install_trans(0); // Now install writes to home locations
    80004b5e:	4501                	li	a0,0
    80004b60:	00000097          	auipc	ra,0x0
    80004b64:	cda080e7          	jalr	-806(ra) # 8000483a <install_trans>
    log.lh.n = 0;
    80004b68:	0001d797          	auipc	a5,0x1d
    80004b6c:	ea07ae23          	sw	zero,-324(a5) # 80021a24 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004b70:	00000097          	auipc	ra,0x0
    80004b74:	c4e080e7          	jalr	-946(ra) # 800047be <write_head>
    80004b78:	bdf5                	j	80004a74 <end_op+0x52>

0000000080004b7a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004b7a:	1101                	addi	sp,sp,-32
    80004b7c:	ec06                	sd	ra,24(sp)
    80004b7e:	e822                	sd	s0,16(sp)
    80004b80:	e426                	sd	s1,8(sp)
    80004b82:	e04a                	sd	s2,0(sp)
    80004b84:	1000                	addi	s0,sp,32
    80004b86:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004b88:	0001d917          	auipc	s2,0x1d
    80004b8c:	e7090913          	addi	s2,s2,-400 # 800219f8 <log>
    80004b90:	854a                	mv	a0,s2
    80004b92:	ffffc097          	auipc	ra,0xffffc
    80004b96:	03e080e7          	jalr	62(ra) # 80000bd0 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004b9a:	02c92603          	lw	a2,44(s2)
    80004b9e:	47f5                	li	a5,29
    80004ba0:	06c7c563          	blt	a5,a2,80004c0a <log_write+0x90>
    80004ba4:	0001d797          	auipc	a5,0x1d
    80004ba8:	e707a783          	lw	a5,-400(a5) # 80021a14 <log+0x1c>
    80004bac:	37fd                	addiw	a5,a5,-1
    80004bae:	04f65e63          	bge	a2,a5,80004c0a <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004bb2:	0001d797          	auipc	a5,0x1d
    80004bb6:	e667a783          	lw	a5,-410(a5) # 80021a18 <log+0x20>
    80004bba:	06f05063          	blez	a5,80004c1a <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004bbe:	4781                	li	a5,0
    80004bc0:	06c05563          	blez	a2,80004c2a <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004bc4:	44cc                	lw	a1,12(s1)
    80004bc6:	0001d717          	auipc	a4,0x1d
    80004bca:	e6270713          	addi	a4,a4,-414 # 80021a28 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004bce:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004bd0:	4314                	lw	a3,0(a4)
    80004bd2:	04b68c63          	beq	a3,a1,80004c2a <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004bd6:	2785                	addiw	a5,a5,1
    80004bd8:	0711                	addi	a4,a4,4
    80004bda:	fef61be3          	bne	a2,a5,80004bd0 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004bde:	0621                	addi	a2,a2,8
    80004be0:	060a                	slli	a2,a2,0x2
    80004be2:	0001d797          	auipc	a5,0x1d
    80004be6:	e1678793          	addi	a5,a5,-490 # 800219f8 <log>
    80004bea:	97b2                	add	a5,a5,a2
    80004bec:	44d8                	lw	a4,12(s1)
    80004bee:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004bf0:	8526                	mv	a0,s1
    80004bf2:	fffff097          	auipc	ra,0xfffff
    80004bf6:	da2080e7          	jalr	-606(ra) # 80003994 <bpin>
    log.lh.n++;
    80004bfa:	0001d717          	auipc	a4,0x1d
    80004bfe:	dfe70713          	addi	a4,a4,-514 # 800219f8 <log>
    80004c02:	575c                	lw	a5,44(a4)
    80004c04:	2785                	addiw	a5,a5,1
    80004c06:	d75c                	sw	a5,44(a4)
    80004c08:	a82d                	j	80004c42 <log_write+0xc8>
    panic("too big a transaction");
    80004c0a:	00004517          	auipc	a0,0x4
    80004c0e:	b4650513          	addi	a0,a0,-1210 # 80008750 <syscalls+0x218>
    80004c12:	ffffc097          	auipc	ra,0xffffc
    80004c16:	928080e7          	jalr	-1752(ra) # 8000053a <panic>
    panic("log_write outside of trans");
    80004c1a:	00004517          	auipc	a0,0x4
    80004c1e:	b4e50513          	addi	a0,a0,-1202 # 80008768 <syscalls+0x230>
    80004c22:	ffffc097          	auipc	ra,0xffffc
    80004c26:	918080e7          	jalr	-1768(ra) # 8000053a <panic>
  log.lh.block[i] = b->blockno;
    80004c2a:	00878693          	addi	a3,a5,8
    80004c2e:	068a                	slli	a3,a3,0x2
    80004c30:	0001d717          	auipc	a4,0x1d
    80004c34:	dc870713          	addi	a4,a4,-568 # 800219f8 <log>
    80004c38:	9736                	add	a4,a4,a3
    80004c3a:	44d4                	lw	a3,12(s1)
    80004c3c:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004c3e:	faf609e3          	beq	a2,a5,80004bf0 <log_write+0x76>
  }
  release(&log.lock);
    80004c42:	0001d517          	auipc	a0,0x1d
    80004c46:	db650513          	addi	a0,a0,-586 # 800219f8 <log>
    80004c4a:	ffffc097          	auipc	ra,0xffffc
    80004c4e:	03a080e7          	jalr	58(ra) # 80000c84 <release>
}
    80004c52:	60e2                	ld	ra,24(sp)
    80004c54:	6442                	ld	s0,16(sp)
    80004c56:	64a2                	ld	s1,8(sp)
    80004c58:	6902                	ld	s2,0(sp)
    80004c5a:	6105                	addi	sp,sp,32
    80004c5c:	8082                	ret

0000000080004c5e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004c5e:	1101                	addi	sp,sp,-32
    80004c60:	ec06                	sd	ra,24(sp)
    80004c62:	e822                	sd	s0,16(sp)
    80004c64:	e426                	sd	s1,8(sp)
    80004c66:	e04a                	sd	s2,0(sp)
    80004c68:	1000                	addi	s0,sp,32
    80004c6a:	84aa                	mv	s1,a0
    80004c6c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004c6e:	00004597          	auipc	a1,0x4
    80004c72:	b1a58593          	addi	a1,a1,-1254 # 80008788 <syscalls+0x250>
    80004c76:	0521                	addi	a0,a0,8
    80004c78:	ffffc097          	auipc	ra,0xffffc
    80004c7c:	ec8080e7          	jalr	-312(ra) # 80000b40 <initlock>
  lk->name = name;
    80004c80:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004c84:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004c88:	0204a423          	sw	zero,40(s1)
}
    80004c8c:	60e2                	ld	ra,24(sp)
    80004c8e:	6442                	ld	s0,16(sp)
    80004c90:	64a2                	ld	s1,8(sp)
    80004c92:	6902                	ld	s2,0(sp)
    80004c94:	6105                	addi	sp,sp,32
    80004c96:	8082                	ret

0000000080004c98 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004c98:	1101                	addi	sp,sp,-32
    80004c9a:	ec06                	sd	ra,24(sp)
    80004c9c:	e822                	sd	s0,16(sp)
    80004c9e:	e426                	sd	s1,8(sp)
    80004ca0:	e04a                	sd	s2,0(sp)
    80004ca2:	1000                	addi	s0,sp,32
    80004ca4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004ca6:	00850913          	addi	s2,a0,8
    80004caa:	854a                	mv	a0,s2
    80004cac:	ffffc097          	auipc	ra,0xffffc
    80004cb0:	f24080e7          	jalr	-220(ra) # 80000bd0 <acquire>
  while (lk->locked) {
    80004cb4:	409c                	lw	a5,0(s1)
    80004cb6:	cb89                	beqz	a5,80004cc8 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004cb8:	85ca                	mv	a1,s2
    80004cba:	8526                	mv	a0,s1
    80004cbc:	ffffd097          	auipc	ra,0xffffd
    80004cc0:	7c2080e7          	jalr	1986(ra) # 8000247e <sleep>
  while (lk->locked) {
    80004cc4:	409c                	lw	a5,0(s1)
    80004cc6:	fbed                	bnez	a5,80004cb8 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004cc8:	4785                	li	a5,1
    80004cca:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004ccc:	ffffd097          	auipc	ra,0xffffd
    80004cd0:	d52080e7          	jalr	-686(ra) # 80001a1e <myproc>
    80004cd4:	591c                	lw	a5,48(a0)
    80004cd6:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004cd8:	854a                	mv	a0,s2
    80004cda:	ffffc097          	auipc	ra,0xffffc
    80004cde:	faa080e7          	jalr	-86(ra) # 80000c84 <release>
}
    80004ce2:	60e2                	ld	ra,24(sp)
    80004ce4:	6442                	ld	s0,16(sp)
    80004ce6:	64a2                	ld	s1,8(sp)
    80004ce8:	6902                	ld	s2,0(sp)
    80004cea:	6105                	addi	sp,sp,32
    80004cec:	8082                	ret

0000000080004cee <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004cee:	1101                	addi	sp,sp,-32
    80004cf0:	ec06                	sd	ra,24(sp)
    80004cf2:	e822                	sd	s0,16(sp)
    80004cf4:	e426                	sd	s1,8(sp)
    80004cf6:	e04a                	sd	s2,0(sp)
    80004cf8:	1000                	addi	s0,sp,32
    80004cfa:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004cfc:	00850913          	addi	s2,a0,8
    80004d00:	854a                	mv	a0,s2
    80004d02:	ffffc097          	auipc	ra,0xffffc
    80004d06:	ece080e7          	jalr	-306(ra) # 80000bd0 <acquire>
  lk->locked = 0;
    80004d0a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004d0e:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004d12:	8526                	mv	a0,s1
    80004d14:	ffffe097          	auipc	ra,0xffffe
    80004d18:	c52080e7          	jalr	-942(ra) # 80002966 <wakeup>
  release(&lk->lk);
    80004d1c:	854a                	mv	a0,s2
    80004d1e:	ffffc097          	auipc	ra,0xffffc
    80004d22:	f66080e7          	jalr	-154(ra) # 80000c84 <release>
}
    80004d26:	60e2                	ld	ra,24(sp)
    80004d28:	6442                	ld	s0,16(sp)
    80004d2a:	64a2                	ld	s1,8(sp)
    80004d2c:	6902                	ld	s2,0(sp)
    80004d2e:	6105                	addi	sp,sp,32
    80004d30:	8082                	ret

0000000080004d32 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004d32:	7179                	addi	sp,sp,-48
    80004d34:	f406                	sd	ra,40(sp)
    80004d36:	f022                	sd	s0,32(sp)
    80004d38:	ec26                	sd	s1,24(sp)
    80004d3a:	e84a                	sd	s2,16(sp)
    80004d3c:	e44e                	sd	s3,8(sp)
    80004d3e:	1800                	addi	s0,sp,48
    80004d40:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004d42:	00850913          	addi	s2,a0,8
    80004d46:	854a                	mv	a0,s2
    80004d48:	ffffc097          	auipc	ra,0xffffc
    80004d4c:	e88080e7          	jalr	-376(ra) # 80000bd0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004d50:	409c                	lw	a5,0(s1)
    80004d52:	ef99                	bnez	a5,80004d70 <holdingsleep+0x3e>
    80004d54:	4481                	li	s1,0
  release(&lk->lk);
    80004d56:	854a                	mv	a0,s2
    80004d58:	ffffc097          	auipc	ra,0xffffc
    80004d5c:	f2c080e7          	jalr	-212(ra) # 80000c84 <release>
  return r;
}
    80004d60:	8526                	mv	a0,s1
    80004d62:	70a2                	ld	ra,40(sp)
    80004d64:	7402                	ld	s0,32(sp)
    80004d66:	64e2                	ld	s1,24(sp)
    80004d68:	6942                	ld	s2,16(sp)
    80004d6a:	69a2                	ld	s3,8(sp)
    80004d6c:	6145                	addi	sp,sp,48
    80004d6e:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004d70:	0284a983          	lw	s3,40(s1)
    80004d74:	ffffd097          	auipc	ra,0xffffd
    80004d78:	caa080e7          	jalr	-854(ra) # 80001a1e <myproc>
    80004d7c:	5904                	lw	s1,48(a0)
    80004d7e:	413484b3          	sub	s1,s1,s3
    80004d82:	0014b493          	seqz	s1,s1
    80004d86:	bfc1                	j	80004d56 <holdingsleep+0x24>

0000000080004d88 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004d88:	1141                	addi	sp,sp,-16
    80004d8a:	e406                	sd	ra,8(sp)
    80004d8c:	e022                	sd	s0,0(sp)
    80004d8e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004d90:	00004597          	auipc	a1,0x4
    80004d94:	a0858593          	addi	a1,a1,-1528 # 80008798 <syscalls+0x260>
    80004d98:	0001d517          	auipc	a0,0x1d
    80004d9c:	da850513          	addi	a0,a0,-600 # 80021b40 <ftable>
    80004da0:	ffffc097          	auipc	ra,0xffffc
    80004da4:	da0080e7          	jalr	-608(ra) # 80000b40 <initlock>
}
    80004da8:	60a2                	ld	ra,8(sp)
    80004daa:	6402                	ld	s0,0(sp)
    80004dac:	0141                	addi	sp,sp,16
    80004dae:	8082                	ret

0000000080004db0 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004db0:	1101                	addi	sp,sp,-32
    80004db2:	ec06                	sd	ra,24(sp)
    80004db4:	e822                	sd	s0,16(sp)
    80004db6:	e426                	sd	s1,8(sp)
    80004db8:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004dba:	0001d517          	auipc	a0,0x1d
    80004dbe:	d8650513          	addi	a0,a0,-634 # 80021b40 <ftable>
    80004dc2:	ffffc097          	auipc	ra,0xffffc
    80004dc6:	e0e080e7          	jalr	-498(ra) # 80000bd0 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004dca:	0001d497          	auipc	s1,0x1d
    80004dce:	d8e48493          	addi	s1,s1,-626 # 80021b58 <ftable+0x18>
    80004dd2:	0001e717          	auipc	a4,0x1e
    80004dd6:	d2670713          	addi	a4,a4,-730 # 80022af8 <ftable+0xfb8>
    if(f->ref == 0){
    80004dda:	40dc                	lw	a5,4(s1)
    80004ddc:	cf99                	beqz	a5,80004dfa <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004dde:	02848493          	addi	s1,s1,40
    80004de2:	fee49ce3          	bne	s1,a4,80004dda <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004de6:	0001d517          	auipc	a0,0x1d
    80004dea:	d5a50513          	addi	a0,a0,-678 # 80021b40 <ftable>
    80004dee:	ffffc097          	auipc	ra,0xffffc
    80004df2:	e96080e7          	jalr	-362(ra) # 80000c84 <release>
  return 0;
    80004df6:	4481                	li	s1,0
    80004df8:	a819                	j	80004e0e <filealloc+0x5e>
      f->ref = 1;
    80004dfa:	4785                	li	a5,1
    80004dfc:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004dfe:	0001d517          	auipc	a0,0x1d
    80004e02:	d4250513          	addi	a0,a0,-702 # 80021b40 <ftable>
    80004e06:	ffffc097          	auipc	ra,0xffffc
    80004e0a:	e7e080e7          	jalr	-386(ra) # 80000c84 <release>
}
    80004e0e:	8526                	mv	a0,s1
    80004e10:	60e2                	ld	ra,24(sp)
    80004e12:	6442                	ld	s0,16(sp)
    80004e14:	64a2                	ld	s1,8(sp)
    80004e16:	6105                	addi	sp,sp,32
    80004e18:	8082                	ret

0000000080004e1a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004e1a:	1101                	addi	sp,sp,-32
    80004e1c:	ec06                	sd	ra,24(sp)
    80004e1e:	e822                	sd	s0,16(sp)
    80004e20:	e426                	sd	s1,8(sp)
    80004e22:	1000                	addi	s0,sp,32
    80004e24:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004e26:	0001d517          	auipc	a0,0x1d
    80004e2a:	d1a50513          	addi	a0,a0,-742 # 80021b40 <ftable>
    80004e2e:	ffffc097          	auipc	ra,0xffffc
    80004e32:	da2080e7          	jalr	-606(ra) # 80000bd0 <acquire>
  if(f->ref < 1)
    80004e36:	40dc                	lw	a5,4(s1)
    80004e38:	02f05263          	blez	a5,80004e5c <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004e3c:	2785                	addiw	a5,a5,1
    80004e3e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004e40:	0001d517          	auipc	a0,0x1d
    80004e44:	d0050513          	addi	a0,a0,-768 # 80021b40 <ftable>
    80004e48:	ffffc097          	auipc	ra,0xffffc
    80004e4c:	e3c080e7          	jalr	-452(ra) # 80000c84 <release>
  return f;
}
    80004e50:	8526                	mv	a0,s1
    80004e52:	60e2                	ld	ra,24(sp)
    80004e54:	6442                	ld	s0,16(sp)
    80004e56:	64a2                	ld	s1,8(sp)
    80004e58:	6105                	addi	sp,sp,32
    80004e5a:	8082                	ret
    panic("filedup");
    80004e5c:	00004517          	auipc	a0,0x4
    80004e60:	94450513          	addi	a0,a0,-1724 # 800087a0 <syscalls+0x268>
    80004e64:	ffffb097          	auipc	ra,0xffffb
    80004e68:	6d6080e7          	jalr	1750(ra) # 8000053a <panic>

0000000080004e6c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004e6c:	7139                	addi	sp,sp,-64
    80004e6e:	fc06                	sd	ra,56(sp)
    80004e70:	f822                	sd	s0,48(sp)
    80004e72:	f426                	sd	s1,40(sp)
    80004e74:	f04a                	sd	s2,32(sp)
    80004e76:	ec4e                	sd	s3,24(sp)
    80004e78:	e852                	sd	s4,16(sp)
    80004e7a:	e456                	sd	s5,8(sp)
    80004e7c:	0080                	addi	s0,sp,64
    80004e7e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004e80:	0001d517          	auipc	a0,0x1d
    80004e84:	cc050513          	addi	a0,a0,-832 # 80021b40 <ftable>
    80004e88:	ffffc097          	auipc	ra,0xffffc
    80004e8c:	d48080e7          	jalr	-696(ra) # 80000bd0 <acquire>
  if(f->ref < 1)
    80004e90:	40dc                	lw	a5,4(s1)
    80004e92:	06f05163          	blez	a5,80004ef4 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004e96:	37fd                	addiw	a5,a5,-1
    80004e98:	0007871b          	sext.w	a4,a5
    80004e9c:	c0dc                	sw	a5,4(s1)
    80004e9e:	06e04363          	bgtz	a4,80004f04 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004ea2:	0004a903          	lw	s2,0(s1)
    80004ea6:	0094ca83          	lbu	s5,9(s1)
    80004eaa:	0104ba03          	ld	s4,16(s1)
    80004eae:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004eb2:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004eb6:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004eba:	0001d517          	auipc	a0,0x1d
    80004ebe:	c8650513          	addi	a0,a0,-890 # 80021b40 <ftable>
    80004ec2:	ffffc097          	auipc	ra,0xffffc
    80004ec6:	dc2080e7          	jalr	-574(ra) # 80000c84 <release>

  if(ff.type == FD_PIPE){
    80004eca:	4785                	li	a5,1
    80004ecc:	04f90d63          	beq	s2,a5,80004f26 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004ed0:	3979                	addiw	s2,s2,-2
    80004ed2:	4785                	li	a5,1
    80004ed4:	0527e063          	bltu	a5,s2,80004f14 <fileclose+0xa8>
    begin_op();
    80004ed8:	00000097          	auipc	ra,0x0
    80004edc:	acc080e7          	jalr	-1332(ra) # 800049a4 <begin_op>
    iput(ff.ip);
    80004ee0:	854e                	mv	a0,s3
    80004ee2:	fffff097          	auipc	ra,0xfffff
    80004ee6:	2a0080e7          	jalr	672(ra) # 80004182 <iput>
    end_op();
    80004eea:	00000097          	auipc	ra,0x0
    80004eee:	b38080e7          	jalr	-1224(ra) # 80004a22 <end_op>
    80004ef2:	a00d                	j	80004f14 <fileclose+0xa8>
    panic("fileclose");
    80004ef4:	00004517          	auipc	a0,0x4
    80004ef8:	8b450513          	addi	a0,a0,-1868 # 800087a8 <syscalls+0x270>
    80004efc:	ffffb097          	auipc	ra,0xffffb
    80004f00:	63e080e7          	jalr	1598(ra) # 8000053a <panic>
    release(&ftable.lock);
    80004f04:	0001d517          	auipc	a0,0x1d
    80004f08:	c3c50513          	addi	a0,a0,-964 # 80021b40 <ftable>
    80004f0c:	ffffc097          	auipc	ra,0xffffc
    80004f10:	d78080e7          	jalr	-648(ra) # 80000c84 <release>
  }
}
    80004f14:	70e2                	ld	ra,56(sp)
    80004f16:	7442                	ld	s0,48(sp)
    80004f18:	74a2                	ld	s1,40(sp)
    80004f1a:	7902                	ld	s2,32(sp)
    80004f1c:	69e2                	ld	s3,24(sp)
    80004f1e:	6a42                	ld	s4,16(sp)
    80004f20:	6aa2                	ld	s5,8(sp)
    80004f22:	6121                	addi	sp,sp,64
    80004f24:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004f26:	85d6                	mv	a1,s5
    80004f28:	8552                	mv	a0,s4
    80004f2a:	00000097          	auipc	ra,0x0
    80004f2e:	34c080e7          	jalr	844(ra) # 80005276 <pipeclose>
    80004f32:	b7cd                	j	80004f14 <fileclose+0xa8>

0000000080004f34 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004f34:	715d                	addi	sp,sp,-80
    80004f36:	e486                	sd	ra,72(sp)
    80004f38:	e0a2                	sd	s0,64(sp)
    80004f3a:	fc26                	sd	s1,56(sp)
    80004f3c:	f84a                	sd	s2,48(sp)
    80004f3e:	f44e                	sd	s3,40(sp)
    80004f40:	0880                	addi	s0,sp,80
    80004f42:	84aa                	mv	s1,a0
    80004f44:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004f46:	ffffd097          	auipc	ra,0xffffd
    80004f4a:	ad8080e7          	jalr	-1320(ra) # 80001a1e <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004f4e:	409c                	lw	a5,0(s1)
    80004f50:	37f9                	addiw	a5,a5,-2
    80004f52:	4705                	li	a4,1
    80004f54:	04f76763          	bltu	a4,a5,80004fa2 <filestat+0x6e>
    80004f58:	892a                	mv	s2,a0
    ilock(f->ip);
    80004f5a:	6c88                	ld	a0,24(s1)
    80004f5c:	fffff097          	auipc	ra,0xfffff
    80004f60:	06c080e7          	jalr	108(ra) # 80003fc8 <ilock>
    stati(f->ip, &st);
    80004f64:	fb840593          	addi	a1,s0,-72
    80004f68:	6c88                	ld	a0,24(s1)
    80004f6a:	fffff097          	auipc	ra,0xfffff
    80004f6e:	2e8080e7          	jalr	744(ra) # 80004252 <stati>
    iunlock(f->ip);
    80004f72:	6c88                	ld	a0,24(s1)
    80004f74:	fffff097          	auipc	ra,0xfffff
    80004f78:	116080e7          	jalr	278(ra) # 8000408a <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004f7c:	46e1                	li	a3,24
    80004f7e:	fb840613          	addi	a2,s0,-72
    80004f82:	85ce                	mv	a1,s3
    80004f84:	06093503          	ld	a0,96(s2)
    80004f88:	ffffc097          	auipc	ra,0xffffc
    80004f8c:	6da080e7          	jalr	1754(ra) # 80001662 <copyout>
    80004f90:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004f94:	60a6                	ld	ra,72(sp)
    80004f96:	6406                	ld	s0,64(sp)
    80004f98:	74e2                	ld	s1,56(sp)
    80004f9a:	7942                	ld	s2,48(sp)
    80004f9c:	79a2                	ld	s3,40(sp)
    80004f9e:	6161                	addi	sp,sp,80
    80004fa0:	8082                	ret
  return -1;
    80004fa2:	557d                	li	a0,-1
    80004fa4:	bfc5                	j	80004f94 <filestat+0x60>

0000000080004fa6 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004fa6:	7179                	addi	sp,sp,-48
    80004fa8:	f406                	sd	ra,40(sp)
    80004faa:	f022                	sd	s0,32(sp)
    80004fac:	ec26                	sd	s1,24(sp)
    80004fae:	e84a                	sd	s2,16(sp)
    80004fb0:	e44e                	sd	s3,8(sp)
    80004fb2:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004fb4:	00854783          	lbu	a5,8(a0)
    80004fb8:	c3d5                	beqz	a5,8000505c <fileread+0xb6>
    80004fba:	84aa                	mv	s1,a0
    80004fbc:	89ae                	mv	s3,a1
    80004fbe:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004fc0:	411c                	lw	a5,0(a0)
    80004fc2:	4705                	li	a4,1
    80004fc4:	04e78963          	beq	a5,a4,80005016 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004fc8:	470d                	li	a4,3
    80004fca:	04e78d63          	beq	a5,a4,80005024 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004fce:	4709                	li	a4,2
    80004fd0:	06e79e63          	bne	a5,a4,8000504c <fileread+0xa6>
    ilock(f->ip);
    80004fd4:	6d08                	ld	a0,24(a0)
    80004fd6:	fffff097          	auipc	ra,0xfffff
    80004fda:	ff2080e7          	jalr	-14(ra) # 80003fc8 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004fde:	874a                	mv	a4,s2
    80004fe0:	5094                	lw	a3,32(s1)
    80004fe2:	864e                	mv	a2,s3
    80004fe4:	4585                	li	a1,1
    80004fe6:	6c88                	ld	a0,24(s1)
    80004fe8:	fffff097          	auipc	ra,0xfffff
    80004fec:	294080e7          	jalr	660(ra) # 8000427c <readi>
    80004ff0:	892a                	mv	s2,a0
    80004ff2:	00a05563          	blez	a0,80004ffc <fileread+0x56>
      f->off += r;
    80004ff6:	509c                	lw	a5,32(s1)
    80004ff8:	9fa9                	addw	a5,a5,a0
    80004ffa:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004ffc:	6c88                	ld	a0,24(s1)
    80004ffe:	fffff097          	auipc	ra,0xfffff
    80005002:	08c080e7          	jalr	140(ra) # 8000408a <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80005006:	854a                	mv	a0,s2
    80005008:	70a2                	ld	ra,40(sp)
    8000500a:	7402                	ld	s0,32(sp)
    8000500c:	64e2                	ld	s1,24(sp)
    8000500e:	6942                	ld	s2,16(sp)
    80005010:	69a2                	ld	s3,8(sp)
    80005012:	6145                	addi	sp,sp,48
    80005014:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80005016:	6908                	ld	a0,16(a0)
    80005018:	00000097          	auipc	ra,0x0
    8000501c:	3c0080e7          	jalr	960(ra) # 800053d8 <piperead>
    80005020:	892a                	mv	s2,a0
    80005022:	b7d5                	j	80005006 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80005024:	02451783          	lh	a5,36(a0)
    80005028:	03079693          	slli	a3,a5,0x30
    8000502c:	92c1                	srli	a3,a3,0x30
    8000502e:	4725                	li	a4,9
    80005030:	02d76863          	bltu	a4,a3,80005060 <fileread+0xba>
    80005034:	0792                	slli	a5,a5,0x4
    80005036:	0001d717          	auipc	a4,0x1d
    8000503a:	a6a70713          	addi	a4,a4,-1430 # 80021aa0 <devsw>
    8000503e:	97ba                	add	a5,a5,a4
    80005040:	639c                	ld	a5,0(a5)
    80005042:	c38d                	beqz	a5,80005064 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80005044:	4505                	li	a0,1
    80005046:	9782                	jalr	a5
    80005048:	892a                	mv	s2,a0
    8000504a:	bf75                	j	80005006 <fileread+0x60>
    panic("fileread");
    8000504c:	00003517          	auipc	a0,0x3
    80005050:	76c50513          	addi	a0,a0,1900 # 800087b8 <syscalls+0x280>
    80005054:	ffffb097          	auipc	ra,0xffffb
    80005058:	4e6080e7          	jalr	1254(ra) # 8000053a <panic>
    return -1;
    8000505c:	597d                	li	s2,-1
    8000505e:	b765                	j	80005006 <fileread+0x60>
      return -1;
    80005060:	597d                	li	s2,-1
    80005062:	b755                	j	80005006 <fileread+0x60>
    80005064:	597d                	li	s2,-1
    80005066:	b745                	j	80005006 <fileread+0x60>

0000000080005068 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80005068:	715d                	addi	sp,sp,-80
    8000506a:	e486                	sd	ra,72(sp)
    8000506c:	e0a2                	sd	s0,64(sp)
    8000506e:	fc26                	sd	s1,56(sp)
    80005070:	f84a                	sd	s2,48(sp)
    80005072:	f44e                	sd	s3,40(sp)
    80005074:	f052                	sd	s4,32(sp)
    80005076:	ec56                	sd	s5,24(sp)
    80005078:	e85a                	sd	s6,16(sp)
    8000507a:	e45e                	sd	s7,8(sp)
    8000507c:	e062                	sd	s8,0(sp)
    8000507e:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80005080:	00954783          	lbu	a5,9(a0)
    80005084:	10078663          	beqz	a5,80005190 <filewrite+0x128>
    80005088:	892a                	mv	s2,a0
    8000508a:	8b2e                	mv	s6,a1
    8000508c:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000508e:	411c                	lw	a5,0(a0)
    80005090:	4705                	li	a4,1
    80005092:	02e78263          	beq	a5,a4,800050b6 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005096:	470d                	li	a4,3
    80005098:	02e78663          	beq	a5,a4,800050c4 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000509c:	4709                	li	a4,2
    8000509e:	0ee79163          	bne	a5,a4,80005180 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800050a2:	0ac05d63          	blez	a2,8000515c <filewrite+0xf4>
    int i = 0;
    800050a6:	4981                	li	s3,0
    800050a8:	6b85                	lui	s7,0x1
    800050aa:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800050ae:	6c05                	lui	s8,0x1
    800050b0:	c00c0c1b          	addiw	s8,s8,-1024
    800050b4:	a861                	j	8000514c <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800050b6:	6908                	ld	a0,16(a0)
    800050b8:	00000097          	auipc	ra,0x0
    800050bc:	22e080e7          	jalr	558(ra) # 800052e6 <pipewrite>
    800050c0:	8a2a                	mv	s4,a0
    800050c2:	a045                	j	80005162 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800050c4:	02451783          	lh	a5,36(a0)
    800050c8:	03079693          	slli	a3,a5,0x30
    800050cc:	92c1                	srli	a3,a3,0x30
    800050ce:	4725                	li	a4,9
    800050d0:	0cd76263          	bltu	a4,a3,80005194 <filewrite+0x12c>
    800050d4:	0792                	slli	a5,a5,0x4
    800050d6:	0001d717          	auipc	a4,0x1d
    800050da:	9ca70713          	addi	a4,a4,-1590 # 80021aa0 <devsw>
    800050de:	97ba                	add	a5,a5,a4
    800050e0:	679c                	ld	a5,8(a5)
    800050e2:	cbdd                	beqz	a5,80005198 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    800050e4:	4505                	li	a0,1
    800050e6:	9782                	jalr	a5
    800050e8:	8a2a                	mv	s4,a0
    800050ea:	a8a5                	j	80005162 <filewrite+0xfa>
    800050ec:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800050f0:	00000097          	auipc	ra,0x0
    800050f4:	8b4080e7          	jalr	-1868(ra) # 800049a4 <begin_op>
      ilock(f->ip);
    800050f8:	01893503          	ld	a0,24(s2)
    800050fc:	fffff097          	auipc	ra,0xfffff
    80005100:	ecc080e7          	jalr	-308(ra) # 80003fc8 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80005104:	8756                	mv	a4,s5
    80005106:	02092683          	lw	a3,32(s2)
    8000510a:	01698633          	add	a2,s3,s6
    8000510e:	4585                	li	a1,1
    80005110:	01893503          	ld	a0,24(s2)
    80005114:	fffff097          	auipc	ra,0xfffff
    80005118:	260080e7          	jalr	608(ra) # 80004374 <writei>
    8000511c:	84aa                	mv	s1,a0
    8000511e:	00a05763          	blez	a0,8000512c <filewrite+0xc4>
        f->off += r;
    80005122:	02092783          	lw	a5,32(s2)
    80005126:	9fa9                	addw	a5,a5,a0
    80005128:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000512c:	01893503          	ld	a0,24(s2)
    80005130:	fffff097          	auipc	ra,0xfffff
    80005134:	f5a080e7          	jalr	-166(ra) # 8000408a <iunlock>
      end_op();
    80005138:	00000097          	auipc	ra,0x0
    8000513c:	8ea080e7          	jalr	-1814(ra) # 80004a22 <end_op>

      if(r != n1){
    80005140:	009a9f63          	bne	s5,s1,8000515e <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80005144:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80005148:	0149db63          	bge	s3,s4,8000515e <filewrite+0xf6>
      int n1 = n - i;
    8000514c:	413a04bb          	subw	s1,s4,s3
    80005150:	0004879b          	sext.w	a5,s1
    80005154:	f8fbdce3          	bge	s7,a5,800050ec <filewrite+0x84>
    80005158:	84e2                	mv	s1,s8
    8000515a:	bf49                	j	800050ec <filewrite+0x84>
    int i = 0;
    8000515c:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    8000515e:	013a1f63          	bne	s4,s3,8000517c <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80005162:	8552                	mv	a0,s4
    80005164:	60a6                	ld	ra,72(sp)
    80005166:	6406                	ld	s0,64(sp)
    80005168:	74e2                	ld	s1,56(sp)
    8000516a:	7942                	ld	s2,48(sp)
    8000516c:	79a2                	ld	s3,40(sp)
    8000516e:	7a02                	ld	s4,32(sp)
    80005170:	6ae2                	ld	s5,24(sp)
    80005172:	6b42                	ld	s6,16(sp)
    80005174:	6ba2                	ld	s7,8(sp)
    80005176:	6c02                	ld	s8,0(sp)
    80005178:	6161                	addi	sp,sp,80
    8000517a:	8082                	ret
    ret = (i == n ? n : -1);
    8000517c:	5a7d                	li	s4,-1
    8000517e:	b7d5                	j	80005162 <filewrite+0xfa>
    panic("filewrite");
    80005180:	00003517          	auipc	a0,0x3
    80005184:	64850513          	addi	a0,a0,1608 # 800087c8 <syscalls+0x290>
    80005188:	ffffb097          	auipc	ra,0xffffb
    8000518c:	3b2080e7          	jalr	946(ra) # 8000053a <panic>
    return -1;
    80005190:	5a7d                	li	s4,-1
    80005192:	bfc1                	j	80005162 <filewrite+0xfa>
      return -1;
    80005194:	5a7d                	li	s4,-1
    80005196:	b7f1                	j	80005162 <filewrite+0xfa>
    80005198:	5a7d                	li	s4,-1
    8000519a:	b7e1                	j	80005162 <filewrite+0xfa>

000000008000519c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000519c:	7179                	addi	sp,sp,-48
    8000519e:	f406                	sd	ra,40(sp)
    800051a0:	f022                	sd	s0,32(sp)
    800051a2:	ec26                	sd	s1,24(sp)
    800051a4:	e84a                	sd	s2,16(sp)
    800051a6:	e44e                	sd	s3,8(sp)
    800051a8:	e052                	sd	s4,0(sp)
    800051aa:	1800                	addi	s0,sp,48
    800051ac:	84aa                	mv	s1,a0
    800051ae:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800051b0:	0005b023          	sd	zero,0(a1)
    800051b4:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800051b8:	00000097          	auipc	ra,0x0
    800051bc:	bf8080e7          	jalr	-1032(ra) # 80004db0 <filealloc>
    800051c0:	e088                	sd	a0,0(s1)
    800051c2:	c551                	beqz	a0,8000524e <pipealloc+0xb2>
    800051c4:	00000097          	auipc	ra,0x0
    800051c8:	bec080e7          	jalr	-1044(ra) # 80004db0 <filealloc>
    800051cc:	00aa3023          	sd	a0,0(s4)
    800051d0:	c92d                	beqz	a0,80005242 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800051d2:	ffffc097          	auipc	ra,0xffffc
    800051d6:	90e080e7          	jalr	-1778(ra) # 80000ae0 <kalloc>
    800051da:	892a                	mv	s2,a0
    800051dc:	c125                	beqz	a0,8000523c <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800051de:	4985                	li	s3,1
    800051e0:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800051e4:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800051e8:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800051ec:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800051f0:	00003597          	auipc	a1,0x3
    800051f4:	5e858593          	addi	a1,a1,1512 # 800087d8 <syscalls+0x2a0>
    800051f8:	ffffc097          	auipc	ra,0xffffc
    800051fc:	948080e7          	jalr	-1720(ra) # 80000b40 <initlock>
  (*f0)->type = FD_PIPE;
    80005200:	609c                	ld	a5,0(s1)
    80005202:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80005206:	609c                	ld	a5,0(s1)
    80005208:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000520c:	609c                	ld	a5,0(s1)
    8000520e:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80005212:	609c                	ld	a5,0(s1)
    80005214:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80005218:	000a3783          	ld	a5,0(s4)
    8000521c:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005220:	000a3783          	ld	a5,0(s4)
    80005224:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80005228:	000a3783          	ld	a5,0(s4)
    8000522c:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005230:	000a3783          	ld	a5,0(s4)
    80005234:	0127b823          	sd	s2,16(a5)
  return 0;
    80005238:	4501                	li	a0,0
    8000523a:	a025                	j	80005262 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000523c:	6088                	ld	a0,0(s1)
    8000523e:	e501                	bnez	a0,80005246 <pipealloc+0xaa>
    80005240:	a039                	j	8000524e <pipealloc+0xb2>
    80005242:	6088                	ld	a0,0(s1)
    80005244:	c51d                	beqz	a0,80005272 <pipealloc+0xd6>
    fileclose(*f0);
    80005246:	00000097          	auipc	ra,0x0
    8000524a:	c26080e7          	jalr	-986(ra) # 80004e6c <fileclose>
  if(*f1)
    8000524e:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005252:	557d                	li	a0,-1
  if(*f1)
    80005254:	c799                	beqz	a5,80005262 <pipealloc+0xc6>
    fileclose(*f1);
    80005256:	853e                	mv	a0,a5
    80005258:	00000097          	auipc	ra,0x0
    8000525c:	c14080e7          	jalr	-1004(ra) # 80004e6c <fileclose>
  return -1;
    80005260:	557d                	li	a0,-1
}
    80005262:	70a2                	ld	ra,40(sp)
    80005264:	7402                	ld	s0,32(sp)
    80005266:	64e2                	ld	s1,24(sp)
    80005268:	6942                	ld	s2,16(sp)
    8000526a:	69a2                	ld	s3,8(sp)
    8000526c:	6a02                	ld	s4,0(sp)
    8000526e:	6145                	addi	sp,sp,48
    80005270:	8082                	ret
  return -1;
    80005272:	557d                	li	a0,-1
    80005274:	b7fd                	j	80005262 <pipealloc+0xc6>

0000000080005276 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80005276:	1101                	addi	sp,sp,-32
    80005278:	ec06                	sd	ra,24(sp)
    8000527a:	e822                	sd	s0,16(sp)
    8000527c:	e426                	sd	s1,8(sp)
    8000527e:	e04a                	sd	s2,0(sp)
    80005280:	1000                	addi	s0,sp,32
    80005282:	84aa                	mv	s1,a0
    80005284:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005286:	ffffc097          	auipc	ra,0xffffc
    8000528a:	94a080e7          	jalr	-1718(ra) # 80000bd0 <acquire>
  if(writable){
    8000528e:	02090d63          	beqz	s2,800052c8 <pipeclose+0x52>
    pi->writeopen = 0;
    80005292:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80005296:	21848513          	addi	a0,s1,536
    8000529a:	ffffd097          	auipc	ra,0xffffd
    8000529e:	6cc080e7          	jalr	1740(ra) # 80002966 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800052a2:	2204b783          	ld	a5,544(s1)
    800052a6:	eb95                	bnez	a5,800052da <pipeclose+0x64>
    release(&pi->lock);
    800052a8:	8526                	mv	a0,s1
    800052aa:	ffffc097          	auipc	ra,0xffffc
    800052ae:	9da080e7          	jalr	-1574(ra) # 80000c84 <release>
    kfree((char*)pi);
    800052b2:	8526                	mv	a0,s1
    800052b4:	ffffb097          	auipc	ra,0xffffb
    800052b8:	72e080e7          	jalr	1838(ra) # 800009e2 <kfree>
  } else
    release(&pi->lock);
}
    800052bc:	60e2                	ld	ra,24(sp)
    800052be:	6442                	ld	s0,16(sp)
    800052c0:	64a2                	ld	s1,8(sp)
    800052c2:	6902                	ld	s2,0(sp)
    800052c4:	6105                	addi	sp,sp,32
    800052c6:	8082                	ret
    pi->readopen = 0;
    800052c8:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800052cc:	21c48513          	addi	a0,s1,540
    800052d0:	ffffd097          	auipc	ra,0xffffd
    800052d4:	696080e7          	jalr	1686(ra) # 80002966 <wakeup>
    800052d8:	b7e9                	j	800052a2 <pipeclose+0x2c>
    release(&pi->lock);
    800052da:	8526                	mv	a0,s1
    800052dc:	ffffc097          	auipc	ra,0xffffc
    800052e0:	9a8080e7          	jalr	-1624(ra) # 80000c84 <release>
}
    800052e4:	bfe1                	j	800052bc <pipeclose+0x46>

00000000800052e6 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800052e6:	711d                	addi	sp,sp,-96
    800052e8:	ec86                	sd	ra,88(sp)
    800052ea:	e8a2                	sd	s0,80(sp)
    800052ec:	e4a6                	sd	s1,72(sp)
    800052ee:	e0ca                	sd	s2,64(sp)
    800052f0:	fc4e                	sd	s3,56(sp)
    800052f2:	f852                	sd	s4,48(sp)
    800052f4:	f456                	sd	s5,40(sp)
    800052f6:	f05a                	sd	s6,32(sp)
    800052f8:	ec5e                	sd	s7,24(sp)
    800052fa:	e862                	sd	s8,16(sp)
    800052fc:	1080                	addi	s0,sp,96
    800052fe:	84aa                	mv	s1,a0
    80005300:	8aae                	mv	s5,a1
    80005302:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80005304:	ffffc097          	auipc	ra,0xffffc
    80005308:	71a080e7          	jalr	1818(ra) # 80001a1e <myproc>
    8000530c:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000530e:	8526                	mv	a0,s1
    80005310:	ffffc097          	auipc	ra,0xffffc
    80005314:	8c0080e7          	jalr	-1856(ra) # 80000bd0 <acquire>
  while(i < n){
    80005318:	0b405363          	blez	s4,800053be <pipewrite+0xd8>
  int i = 0;
    8000531c:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000531e:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80005320:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005324:	21c48b93          	addi	s7,s1,540
    80005328:	a089                	j	8000536a <pipewrite+0x84>
      release(&pi->lock);
    8000532a:	8526                	mv	a0,s1
    8000532c:	ffffc097          	auipc	ra,0xffffc
    80005330:	958080e7          	jalr	-1704(ra) # 80000c84 <release>
      return -1;
    80005334:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005336:	854a                	mv	a0,s2
    80005338:	60e6                	ld	ra,88(sp)
    8000533a:	6446                	ld	s0,80(sp)
    8000533c:	64a6                	ld	s1,72(sp)
    8000533e:	6906                	ld	s2,64(sp)
    80005340:	79e2                	ld	s3,56(sp)
    80005342:	7a42                	ld	s4,48(sp)
    80005344:	7aa2                	ld	s5,40(sp)
    80005346:	7b02                	ld	s6,32(sp)
    80005348:	6be2                	ld	s7,24(sp)
    8000534a:	6c42                	ld	s8,16(sp)
    8000534c:	6125                	addi	sp,sp,96
    8000534e:	8082                	ret
      wakeup(&pi->nread);
    80005350:	8562                	mv	a0,s8
    80005352:	ffffd097          	auipc	ra,0xffffd
    80005356:	614080e7          	jalr	1556(ra) # 80002966 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000535a:	85a6                	mv	a1,s1
    8000535c:	855e                	mv	a0,s7
    8000535e:	ffffd097          	auipc	ra,0xffffd
    80005362:	120080e7          	jalr	288(ra) # 8000247e <sleep>
  while(i < n){
    80005366:	05495d63          	bge	s2,s4,800053c0 <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    8000536a:	2204a783          	lw	a5,544(s1)
    8000536e:	dfd5                	beqz	a5,8000532a <pipewrite+0x44>
    80005370:	0289a783          	lw	a5,40(s3)
    80005374:	fbdd                	bnez	a5,8000532a <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005376:	2184a783          	lw	a5,536(s1)
    8000537a:	21c4a703          	lw	a4,540(s1)
    8000537e:	2007879b          	addiw	a5,a5,512
    80005382:	fcf707e3          	beq	a4,a5,80005350 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005386:	4685                	li	a3,1
    80005388:	01590633          	add	a2,s2,s5
    8000538c:	faf40593          	addi	a1,s0,-81
    80005390:	0609b503          	ld	a0,96(s3)
    80005394:	ffffc097          	auipc	ra,0xffffc
    80005398:	35a080e7          	jalr	858(ra) # 800016ee <copyin>
    8000539c:	03650263          	beq	a0,s6,800053c0 <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800053a0:	21c4a783          	lw	a5,540(s1)
    800053a4:	0017871b          	addiw	a4,a5,1
    800053a8:	20e4ae23          	sw	a4,540(s1)
    800053ac:	1ff7f793          	andi	a5,a5,511
    800053b0:	97a6                	add	a5,a5,s1
    800053b2:	faf44703          	lbu	a4,-81(s0)
    800053b6:	00e78c23          	sb	a4,24(a5)
      i++;
    800053ba:	2905                	addiw	s2,s2,1
    800053bc:	b76d                	j	80005366 <pipewrite+0x80>
  int i = 0;
    800053be:	4901                	li	s2,0
  wakeup(&pi->nread);
    800053c0:	21848513          	addi	a0,s1,536
    800053c4:	ffffd097          	auipc	ra,0xffffd
    800053c8:	5a2080e7          	jalr	1442(ra) # 80002966 <wakeup>
  release(&pi->lock);
    800053cc:	8526                	mv	a0,s1
    800053ce:	ffffc097          	auipc	ra,0xffffc
    800053d2:	8b6080e7          	jalr	-1866(ra) # 80000c84 <release>
  return i;
    800053d6:	b785                	j	80005336 <pipewrite+0x50>

00000000800053d8 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800053d8:	715d                	addi	sp,sp,-80
    800053da:	e486                	sd	ra,72(sp)
    800053dc:	e0a2                	sd	s0,64(sp)
    800053de:	fc26                	sd	s1,56(sp)
    800053e0:	f84a                	sd	s2,48(sp)
    800053e2:	f44e                	sd	s3,40(sp)
    800053e4:	f052                	sd	s4,32(sp)
    800053e6:	ec56                	sd	s5,24(sp)
    800053e8:	e85a                	sd	s6,16(sp)
    800053ea:	0880                	addi	s0,sp,80
    800053ec:	84aa                	mv	s1,a0
    800053ee:	892e                	mv	s2,a1
    800053f0:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800053f2:	ffffc097          	auipc	ra,0xffffc
    800053f6:	62c080e7          	jalr	1580(ra) # 80001a1e <myproc>
    800053fa:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800053fc:	8526                	mv	a0,s1
    800053fe:	ffffb097          	auipc	ra,0xffffb
    80005402:	7d2080e7          	jalr	2002(ra) # 80000bd0 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005406:	2184a703          	lw	a4,536(s1)
    8000540a:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000540e:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005412:	02f71463          	bne	a4,a5,8000543a <piperead+0x62>
    80005416:	2244a783          	lw	a5,548(s1)
    8000541a:	c385                	beqz	a5,8000543a <piperead+0x62>
    if(pr->killed){
    8000541c:	028a2783          	lw	a5,40(s4)
    80005420:	ebc9                	bnez	a5,800054b2 <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005422:	85a6                	mv	a1,s1
    80005424:	854e                	mv	a0,s3
    80005426:	ffffd097          	auipc	ra,0xffffd
    8000542a:	058080e7          	jalr	88(ra) # 8000247e <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000542e:	2184a703          	lw	a4,536(s1)
    80005432:	21c4a783          	lw	a5,540(s1)
    80005436:	fef700e3          	beq	a4,a5,80005416 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000543a:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000543c:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000543e:	05505463          	blez	s5,80005486 <piperead+0xae>
    if(pi->nread == pi->nwrite)
    80005442:	2184a783          	lw	a5,536(s1)
    80005446:	21c4a703          	lw	a4,540(s1)
    8000544a:	02f70e63          	beq	a4,a5,80005486 <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000544e:	0017871b          	addiw	a4,a5,1
    80005452:	20e4ac23          	sw	a4,536(s1)
    80005456:	1ff7f793          	andi	a5,a5,511
    8000545a:	97a6                	add	a5,a5,s1
    8000545c:	0187c783          	lbu	a5,24(a5)
    80005460:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005464:	4685                	li	a3,1
    80005466:	fbf40613          	addi	a2,s0,-65
    8000546a:	85ca                	mv	a1,s2
    8000546c:	060a3503          	ld	a0,96(s4)
    80005470:	ffffc097          	auipc	ra,0xffffc
    80005474:	1f2080e7          	jalr	498(ra) # 80001662 <copyout>
    80005478:	01650763          	beq	a0,s6,80005486 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000547c:	2985                	addiw	s3,s3,1
    8000547e:	0905                	addi	s2,s2,1
    80005480:	fd3a91e3          	bne	s5,s3,80005442 <piperead+0x6a>
    80005484:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005486:	21c48513          	addi	a0,s1,540
    8000548a:	ffffd097          	auipc	ra,0xffffd
    8000548e:	4dc080e7          	jalr	1244(ra) # 80002966 <wakeup>
  release(&pi->lock);
    80005492:	8526                	mv	a0,s1
    80005494:	ffffb097          	auipc	ra,0xffffb
    80005498:	7f0080e7          	jalr	2032(ra) # 80000c84 <release>
  return i;
}
    8000549c:	854e                	mv	a0,s3
    8000549e:	60a6                	ld	ra,72(sp)
    800054a0:	6406                	ld	s0,64(sp)
    800054a2:	74e2                	ld	s1,56(sp)
    800054a4:	7942                	ld	s2,48(sp)
    800054a6:	79a2                	ld	s3,40(sp)
    800054a8:	7a02                	ld	s4,32(sp)
    800054aa:	6ae2                	ld	s5,24(sp)
    800054ac:	6b42                	ld	s6,16(sp)
    800054ae:	6161                	addi	sp,sp,80
    800054b0:	8082                	ret
      release(&pi->lock);
    800054b2:	8526                	mv	a0,s1
    800054b4:	ffffb097          	auipc	ra,0xffffb
    800054b8:	7d0080e7          	jalr	2000(ra) # 80000c84 <release>
      return -1;
    800054bc:	59fd                	li	s3,-1
    800054be:	bff9                	j	8000549c <piperead+0xc4>

00000000800054c0 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    800054c0:	de010113          	addi	sp,sp,-544
    800054c4:	20113c23          	sd	ra,536(sp)
    800054c8:	20813823          	sd	s0,528(sp)
    800054cc:	20913423          	sd	s1,520(sp)
    800054d0:	21213023          	sd	s2,512(sp)
    800054d4:	ffce                	sd	s3,504(sp)
    800054d6:	fbd2                	sd	s4,496(sp)
    800054d8:	f7d6                	sd	s5,488(sp)
    800054da:	f3da                	sd	s6,480(sp)
    800054dc:	efde                	sd	s7,472(sp)
    800054de:	ebe2                	sd	s8,464(sp)
    800054e0:	e7e6                	sd	s9,456(sp)
    800054e2:	e3ea                	sd	s10,448(sp)
    800054e4:	ff6e                	sd	s11,440(sp)
    800054e6:	1400                	addi	s0,sp,544
    800054e8:	892a                	mv	s2,a0
    800054ea:	dea43423          	sd	a0,-536(s0)
    800054ee:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800054f2:	ffffc097          	auipc	ra,0xffffc
    800054f6:	52c080e7          	jalr	1324(ra) # 80001a1e <myproc>
    800054fa:	84aa                	mv	s1,a0

  begin_op();
    800054fc:	fffff097          	auipc	ra,0xfffff
    80005500:	4a8080e7          	jalr	1192(ra) # 800049a4 <begin_op>

  if((ip = namei(path)) == 0){
    80005504:	854a                	mv	a0,s2
    80005506:	fffff097          	auipc	ra,0xfffff
    8000550a:	27e080e7          	jalr	638(ra) # 80004784 <namei>
    8000550e:	c93d                	beqz	a0,80005584 <exec+0xc4>
    80005510:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005512:	fffff097          	auipc	ra,0xfffff
    80005516:	ab6080e7          	jalr	-1354(ra) # 80003fc8 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000551a:	04000713          	li	a4,64
    8000551e:	4681                	li	a3,0
    80005520:	e5040613          	addi	a2,s0,-432
    80005524:	4581                	li	a1,0
    80005526:	8556                	mv	a0,s5
    80005528:	fffff097          	auipc	ra,0xfffff
    8000552c:	d54080e7          	jalr	-684(ra) # 8000427c <readi>
    80005530:	04000793          	li	a5,64
    80005534:	00f51a63          	bne	a0,a5,80005548 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80005538:	e5042703          	lw	a4,-432(s0)
    8000553c:	464c47b7          	lui	a5,0x464c4
    80005540:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005544:	04f70663          	beq	a4,a5,80005590 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005548:	8556                	mv	a0,s5
    8000554a:	fffff097          	auipc	ra,0xfffff
    8000554e:	ce0080e7          	jalr	-800(ra) # 8000422a <iunlockput>
    end_op();
    80005552:	fffff097          	auipc	ra,0xfffff
    80005556:	4d0080e7          	jalr	1232(ra) # 80004a22 <end_op>
  }
  return -1;
    8000555a:	557d                	li	a0,-1
}
    8000555c:	21813083          	ld	ra,536(sp)
    80005560:	21013403          	ld	s0,528(sp)
    80005564:	20813483          	ld	s1,520(sp)
    80005568:	20013903          	ld	s2,512(sp)
    8000556c:	79fe                	ld	s3,504(sp)
    8000556e:	7a5e                	ld	s4,496(sp)
    80005570:	7abe                	ld	s5,488(sp)
    80005572:	7b1e                	ld	s6,480(sp)
    80005574:	6bfe                	ld	s7,472(sp)
    80005576:	6c5e                	ld	s8,464(sp)
    80005578:	6cbe                	ld	s9,456(sp)
    8000557a:	6d1e                	ld	s10,448(sp)
    8000557c:	7dfa                	ld	s11,440(sp)
    8000557e:	22010113          	addi	sp,sp,544
    80005582:	8082                	ret
    end_op();
    80005584:	fffff097          	auipc	ra,0xfffff
    80005588:	49e080e7          	jalr	1182(ra) # 80004a22 <end_op>
    return -1;
    8000558c:	557d                	li	a0,-1
    8000558e:	b7f9                	j	8000555c <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80005590:	8526                	mv	a0,s1
    80005592:	ffffc097          	auipc	ra,0xffffc
    80005596:	798080e7          	jalr	1944(ra) # 80001d2a <proc_pagetable>
    8000559a:	8b2a                	mv	s6,a0
    8000559c:	d555                	beqz	a0,80005548 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000559e:	e7042783          	lw	a5,-400(s0)
    800055a2:	e8845703          	lhu	a4,-376(s0)
    800055a6:	c735                	beqz	a4,80005612 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800055a8:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800055aa:	e0043423          	sd	zero,-504(s0)
    if((ph.vaddr % PGSIZE) != 0)
    800055ae:	6a05                	lui	s4,0x1
    800055b0:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    800055b4:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    800055b8:	6d85                	lui	s11,0x1
    800055ba:	7d7d                	lui	s10,0xfffff
    800055bc:	ac1d                	j	800057f2 <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800055be:	00003517          	auipc	a0,0x3
    800055c2:	22250513          	addi	a0,a0,546 # 800087e0 <syscalls+0x2a8>
    800055c6:	ffffb097          	auipc	ra,0xffffb
    800055ca:	f74080e7          	jalr	-140(ra) # 8000053a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800055ce:	874a                	mv	a4,s2
    800055d0:	009c86bb          	addw	a3,s9,s1
    800055d4:	4581                	li	a1,0
    800055d6:	8556                	mv	a0,s5
    800055d8:	fffff097          	auipc	ra,0xfffff
    800055dc:	ca4080e7          	jalr	-860(ra) # 8000427c <readi>
    800055e0:	2501                	sext.w	a0,a0
    800055e2:	1aa91863          	bne	s2,a0,80005792 <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    800055e6:	009d84bb          	addw	s1,s11,s1
    800055ea:	013d09bb          	addw	s3,s10,s3
    800055ee:	1f74f263          	bgeu	s1,s7,800057d2 <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    800055f2:	02049593          	slli	a1,s1,0x20
    800055f6:	9181                	srli	a1,a1,0x20
    800055f8:	95e2                	add	a1,a1,s8
    800055fa:	855a                	mv	a0,s6
    800055fc:	ffffc097          	auipc	ra,0xffffc
    80005600:	a5e080e7          	jalr	-1442(ra) # 8000105a <walkaddr>
    80005604:	862a                	mv	a2,a0
    if(pa == 0)
    80005606:	dd45                	beqz	a0,800055be <exec+0xfe>
      n = PGSIZE;
    80005608:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    8000560a:	fd49f2e3          	bgeu	s3,s4,800055ce <exec+0x10e>
      n = sz - i;
    8000560e:	894e                	mv	s2,s3
    80005610:	bf7d                	j	800055ce <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005612:	4481                	li	s1,0
  iunlockput(ip);
    80005614:	8556                	mv	a0,s5
    80005616:	fffff097          	auipc	ra,0xfffff
    8000561a:	c14080e7          	jalr	-1004(ra) # 8000422a <iunlockput>
  end_op();
    8000561e:	fffff097          	auipc	ra,0xfffff
    80005622:	404080e7          	jalr	1028(ra) # 80004a22 <end_op>
  p = myproc();
    80005626:	ffffc097          	auipc	ra,0xffffc
    8000562a:	3f8080e7          	jalr	1016(ra) # 80001a1e <myproc>
    8000562e:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005630:	05853d03          	ld	s10,88(a0)
  sz = PGROUNDUP(sz);
    80005634:	6785                	lui	a5,0x1
    80005636:	17fd                	addi	a5,a5,-1
    80005638:	97a6                	add	a5,a5,s1
    8000563a:	777d                	lui	a4,0xfffff
    8000563c:	8ff9                	and	a5,a5,a4
    8000563e:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005642:	6609                	lui	a2,0x2
    80005644:	963e                	add	a2,a2,a5
    80005646:	85be                	mv	a1,a5
    80005648:	855a                	mv	a0,s6
    8000564a:	ffffc097          	auipc	ra,0xffffc
    8000564e:	dc4080e7          	jalr	-572(ra) # 8000140e <uvmalloc>
    80005652:	8c2a                	mv	s8,a0
  ip = 0;
    80005654:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005656:	12050e63          	beqz	a0,80005792 <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000565a:	75f9                	lui	a1,0xffffe
    8000565c:	95aa                	add	a1,a1,a0
    8000565e:	855a                	mv	a0,s6
    80005660:	ffffc097          	auipc	ra,0xffffc
    80005664:	fd0080e7          	jalr	-48(ra) # 80001630 <uvmclear>
  stackbase = sp - PGSIZE;
    80005668:	7afd                	lui	s5,0xfffff
    8000566a:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    8000566c:	df043783          	ld	a5,-528(s0)
    80005670:	6388                	ld	a0,0(a5)
    80005672:	c925                	beqz	a0,800056e2 <exec+0x222>
    80005674:	e9040993          	addi	s3,s0,-368
    80005678:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    8000567c:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000567e:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005680:	ffffb097          	auipc	ra,0xffffb
    80005684:	7c8080e7          	jalr	1992(ra) # 80000e48 <strlen>
    80005688:	0015079b          	addiw	a5,a0,1
    8000568c:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005690:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80005694:	13596363          	bltu	s2,s5,800057ba <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005698:	df043d83          	ld	s11,-528(s0)
    8000569c:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800056a0:	8552                	mv	a0,s4
    800056a2:	ffffb097          	auipc	ra,0xffffb
    800056a6:	7a6080e7          	jalr	1958(ra) # 80000e48 <strlen>
    800056aa:	0015069b          	addiw	a3,a0,1
    800056ae:	8652                	mv	a2,s4
    800056b0:	85ca                	mv	a1,s2
    800056b2:	855a                	mv	a0,s6
    800056b4:	ffffc097          	auipc	ra,0xffffc
    800056b8:	fae080e7          	jalr	-82(ra) # 80001662 <copyout>
    800056bc:	10054363          	bltz	a0,800057c2 <exec+0x302>
    ustack[argc] = sp;
    800056c0:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800056c4:	0485                	addi	s1,s1,1
    800056c6:	008d8793          	addi	a5,s11,8
    800056ca:	def43823          	sd	a5,-528(s0)
    800056ce:	008db503          	ld	a0,8(s11)
    800056d2:	c911                	beqz	a0,800056e6 <exec+0x226>
    if(argc >= MAXARG)
    800056d4:	09a1                	addi	s3,s3,8
    800056d6:	fb3c95e3          	bne	s9,s3,80005680 <exec+0x1c0>
  sz = sz1;
    800056da:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800056de:	4a81                	li	s5,0
    800056e0:	a84d                	j	80005792 <exec+0x2d2>
  sp = sz;
    800056e2:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800056e4:	4481                	li	s1,0
  ustack[argc] = 0;
    800056e6:	00349793          	slli	a5,s1,0x3
    800056ea:	f9078793          	addi	a5,a5,-112 # f90 <_entry-0x7ffff070>
    800056ee:	97a2                	add	a5,a5,s0
    800056f0:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800056f4:	00148693          	addi	a3,s1,1
    800056f8:	068e                	slli	a3,a3,0x3
    800056fa:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800056fe:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005702:	01597663          	bgeu	s2,s5,8000570e <exec+0x24e>
  sz = sz1;
    80005706:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000570a:	4a81                	li	s5,0
    8000570c:	a059                	j	80005792 <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000570e:	e9040613          	addi	a2,s0,-368
    80005712:	85ca                	mv	a1,s2
    80005714:	855a                	mv	a0,s6
    80005716:	ffffc097          	auipc	ra,0xffffc
    8000571a:	f4c080e7          	jalr	-180(ra) # 80001662 <copyout>
    8000571e:	0a054663          	bltz	a0,800057ca <exec+0x30a>
  p->trapframe->a1 = sp;
    80005722:	068bb783          	ld	a5,104(s7)
    80005726:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000572a:	de843783          	ld	a5,-536(s0)
    8000572e:	0007c703          	lbu	a4,0(a5)
    80005732:	cf11                	beqz	a4,8000574e <exec+0x28e>
    80005734:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005736:	02f00693          	li	a3,47
    8000573a:	a039                	j	80005748 <exec+0x288>
      last = s+1;
    8000573c:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005740:	0785                	addi	a5,a5,1
    80005742:	fff7c703          	lbu	a4,-1(a5)
    80005746:	c701                	beqz	a4,8000574e <exec+0x28e>
    if(*s == '/')
    80005748:	fed71ce3          	bne	a4,a3,80005740 <exec+0x280>
    8000574c:	bfc5                	j	8000573c <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    8000574e:	4641                	li	a2,16
    80005750:	de843583          	ld	a1,-536(s0)
    80005754:	168b8513          	addi	a0,s7,360
    80005758:	ffffb097          	auipc	ra,0xffffb
    8000575c:	6be080e7          	jalr	1726(ra) # 80000e16 <safestrcpy>
  oldpagetable = p->pagetable;
    80005760:	060bb503          	ld	a0,96(s7)
  p->pagetable = pagetable;
    80005764:	076bb023          	sd	s6,96(s7)
  p->sz = sz;
    80005768:	058bbc23          	sd	s8,88(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000576c:	068bb783          	ld	a5,104(s7)
    80005770:	e6843703          	ld	a4,-408(s0)
    80005774:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005776:	068bb783          	ld	a5,104(s7)
    8000577a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000577e:	85ea                	mv	a1,s10
    80005780:	ffffc097          	auipc	ra,0xffffc
    80005784:	646080e7          	jalr	1606(ra) # 80001dc6 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005788:	0004851b          	sext.w	a0,s1
    8000578c:	bbc1                	j	8000555c <exec+0x9c>
    8000578e:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005792:	df843583          	ld	a1,-520(s0)
    80005796:	855a                	mv	a0,s6
    80005798:	ffffc097          	auipc	ra,0xffffc
    8000579c:	62e080e7          	jalr	1582(ra) # 80001dc6 <proc_freepagetable>
  if(ip){
    800057a0:	da0a94e3          	bnez	s5,80005548 <exec+0x88>
  return -1;
    800057a4:	557d                	li	a0,-1
    800057a6:	bb5d                	j	8000555c <exec+0x9c>
    800057a8:	de943c23          	sd	s1,-520(s0)
    800057ac:	b7dd                	j	80005792 <exec+0x2d2>
    800057ae:	de943c23          	sd	s1,-520(s0)
    800057b2:	b7c5                	j	80005792 <exec+0x2d2>
    800057b4:	de943c23          	sd	s1,-520(s0)
    800057b8:	bfe9                	j	80005792 <exec+0x2d2>
  sz = sz1;
    800057ba:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800057be:	4a81                	li	s5,0
    800057c0:	bfc9                	j	80005792 <exec+0x2d2>
  sz = sz1;
    800057c2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800057c6:	4a81                	li	s5,0
    800057c8:	b7e9                	j	80005792 <exec+0x2d2>
  sz = sz1;
    800057ca:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800057ce:	4a81                	li	s5,0
    800057d0:	b7c9                	j	80005792 <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800057d2:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800057d6:	e0843783          	ld	a5,-504(s0)
    800057da:	0017869b          	addiw	a3,a5,1
    800057de:	e0d43423          	sd	a3,-504(s0)
    800057e2:	e0043783          	ld	a5,-512(s0)
    800057e6:	0387879b          	addiw	a5,a5,56
    800057ea:	e8845703          	lhu	a4,-376(s0)
    800057ee:	e2e6d3e3          	bge	a3,a4,80005614 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800057f2:	2781                	sext.w	a5,a5
    800057f4:	e0f43023          	sd	a5,-512(s0)
    800057f8:	03800713          	li	a4,56
    800057fc:	86be                	mv	a3,a5
    800057fe:	e1840613          	addi	a2,s0,-488
    80005802:	4581                	li	a1,0
    80005804:	8556                	mv	a0,s5
    80005806:	fffff097          	auipc	ra,0xfffff
    8000580a:	a76080e7          	jalr	-1418(ra) # 8000427c <readi>
    8000580e:	03800793          	li	a5,56
    80005812:	f6f51ee3          	bne	a0,a5,8000578e <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    80005816:	e1842783          	lw	a5,-488(s0)
    8000581a:	4705                	li	a4,1
    8000581c:	fae79de3          	bne	a5,a4,800057d6 <exec+0x316>
    if(ph.memsz < ph.filesz)
    80005820:	e4043603          	ld	a2,-448(s0)
    80005824:	e3843783          	ld	a5,-456(s0)
    80005828:	f8f660e3          	bltu	a2,a5,800057a8 <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000582c:	e2843783          	ld	a5,-472(s0)
    80005830:	963e                	add	a2,a2,a5
    80005832:	f6f66ee3          	bltu	a2,a5,800057ae <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005836:	85a6                	mv	a1,s1
    80005838:	855a                	mv	a0,s6
    8000583a:	ffffc097          	auipc	ra,0xffffc
    8000583e:	bd4080e7          	jalr	-1068(ra) # 8000140e <uvmalloc>
    80005842:	dea43c23          	sd	a0,-520(s0)
    80005846:	d53d                	beqz	a0,800057b4 <exec+0x2f4>
    if((ph.vaddr % PGSIZE) != 0)
    80005848:	e2843c03          	ld	s8,-472(s0)
    8000584c:	de043783          	ld	a5,-544(s0)
    80005850:	00fc77b3          	and	a5,s8,a5
    80005854:	ff9d                	bnez	a5,80005792 <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005856:	e2042c83          	lw	s9,-480(s0)
    8000585a:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000585e:	f60b8ae3          	beqz	s7,800057d2 <exec+0x312>
    80005862:	89de                	mv	s3,s7
    80005864:	4481                	li	s1,0
    80005866:	b371                	j	800055f2 <exec+0x132>

0000000080005868 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005868:	7179                	addi	sp,sp,-48
    8000586a:	f406                	sd	ra,40(sp)
    8000586c:	f022                	sd	s0,32(sp)
    8000586e:	ec26                	sd	s1,24(sp)
    80005870:	e84a                	sd	s2,16(sp)
    80005872:	1800                	addi	s0,sp,48
    80005874:	892e                	mv	s2,a1
    80005876:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005878:	fdc40593          	addi	a1,s0,-36
    8000587c:	ffffe097          	auipc	ra,0xffffe
    80005880:	a46080e7          	jalr	-1466(ra) # 800032c2 <argint>
    80005884:	04054063          	bltz	a0,800058c4 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005888:	fdc42703          	lw	a4,-36(s0)
    8000588c:	47bd                	li	a5,15
    8000588e:	02e7ed63          	bltu	a5,a4,800058c8 <argfd+0x60>
    80005892:	ffffc097          	auipc	ra,0xffffc
    80005896:	18c080e7          	jalr	396(ra) # 80001a1e <myproc>
    8000589a:	fdc42703          	lw	a4,-36(s0)
    8000589e:	01c70793          	addi	a5,a4,28 # fffffffffffff01c <end+0xffffffff7ffd901c>
    800058a2:	078e                	slli	a5,a5,0x3
    800058a4:	953e                	add	a0,a0,a5
    800058a6:	611c                	ld	a5,0(a0)
    800058a8:	c395                	beqz	a5,800058cc <argfd+0x64>
    return -1;
  if(pfd)
    800058aa:	00090463          	beqz	s2,800058b2 <argfd+0x4a>
    *pfd = fd;
    800058ae:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800058b2:	4501                	li	a0,0
  if(pf)
    800058b4:	c091                	beqz	s1,800058b8 <argfd+0x50>
    *pf = f;
    800058b6:	e09c                	sd	a5,0(s1)
}
    800058b8:	70a2                	ld	ra,40(sp)
    800058ba:	7402                	ld	s0,32(sp)
    800058bc:	64e2                	ld	s1,24(sp)
    800058be:	6942                	ld	s2,16(sp)
    800058c0:	6145                	addi	sp,sp,48
    800058c2:	8082                	ret
    return -1;
    800058c4:	557d                	li	a0,-1
    800058c6:	bfcd                	j	800058b8 <argfd+0x50>
    return -1;
    800058c8:	557d                	li	a0,-1
    800058ca:	b7fd                	j	800058b8 <argfd+0x50>
    800058cc:	557d                	li	a0,-1
    800058ce:	b7ed                	j	800058b8 <argfd+0x50>

00000000800058d0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800058d0:	1101                	addi	sp,sp,-32
    800058d2:	ec06                	sd	ra,24(sp)
    800058d4:	e822                	sd	s0,16(sp)
    800058d6:	e426                	sd	s1,8(sp)
    800058d8:	1000                	addi	s0,sp,32
    800058da:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800058dc:	ffffc097          	auipc	ra,0xffffc
    800058e0:	142080e7          	jalr	322(ra) # 80001a1e <myproc>
    800058e4:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800058e6:	0e050793          	addi	a5,a0,224
    800058ea:	4501                	li	a0,0
    800058ec:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800058ee:	6398                	ld	a4,0(a5)
    800058f0:	cb19                	beqz	a4,80005906 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800058f2:	2505                	addiw	a0,a0,1
    800058f4:	07a1                	addi	a5,a5,8
    800058f6:	fed51ce3          	bne	a0,a3,800058ee <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800058fa:	557d                	li	a0,-1
}
    800058fc:	60e2                	ld	ra,24(sp)
    800058fe:	6442                	ld	s0,16(sp)
    80005900:	64a2                	ld	s1,8(sp)
    80005902:	6105                	addi	sp,sp,32
    80005904:	8082                	ret
      p->ofile[fd] = f;
    80005906:	01c50793          	addi	a5,a0,28
    8000590a:	078e                	slli	a5,a5,0x3
    8000590c:	963e                	add	a2,a2,a5
    8000590e:	e204                	sd	s1,0(a2)
      return fd;
    80005910:	b7f5                	j	800058fc <fdalloc+0x2c>

0000000080005912 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005912:	715d                	addi	sp,sp,-80
    80005914:	e486                	sd	ra,72(sp)
    80005916:	e0a2                	sd	s0,64(sp)
    80005918:	fc26                	sd	s1,56(sp)
    8000591a:	f84a                	sd	s2,48(sp)
    8000591c:	f44e                	sd	s3,40(sp)
    8000591e:	f052                	sd	s4,32(sp)
    80005920:	ec56                	sd	s5,24(sp)
    80005922:	0880                	addi	s0,sp,80
    80005924:	89ae                	mv	s3,a1
    80005926:	8ab2                	mv	s5,a2
    80005928:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000592a:	fb040593          	addi	a1,s0,-80
    8000592e:	fffff097          	auipc	ra,0xfffff
    80005932:	e74080e7          	jalr	-396(ra) # 800047a2 <nameiparent>
    80005936:	892a                	mv	s2,a0
    80005938:	12050e63          	beqz	a0,80005a74 <create+0x162>
    return 0;

  ilock(dp);
    8000593c:	ffffe097          	auipc	ra,0xffffe
    80005940:	68c080e7          	jalr	1676(ra) # 80003fc8 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005944:	4601                	li	a2,0
    80005946:	fb040593          	addi	a1,s0,-80
    8000594a:	854a                	mv	a0,s2
    8000594c:	fffff097          	auipc	ra,0xfffff
    80005950:	b60080e7          	jalr	-1184(ra) # 800044ac <dirlookup>
    80005954:	84aa                	mv	s1,a0
    80005956:	c921                	beqz	a0,800059a6 <create+0x94>
    iunlockput(dp);
    80005958:	854a                	mv	a0,s2
    8000595a:	fffff097          	auipc	ra,0xfffff
    8000595e:	8d0080e7          	jalr	-1840(ra) # 8000422a <iunlockput>
    ilock(ip);
    80005962:	8526                	mv	a0,s1
    80005964:	ffffe097          	auipc	ra,0xffffe
    80005968:	664080e7          	jalr	1636(ra) # 80003fc8 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000596c:	2981                	sext.w	s3,s3
    8000596e:	4789                	li	a5,2
    80005970:	02f99463          	bne	s3,a5,80005998 <create+0x86>
    80005974:	0444d783          	lhu	a5,68(s1)
    80005978:	37f9                	addiw	a5,a5,-2
    8000597a:	17c2                	slli	a5,a5,0x30
    8000597c:	93c1                	srli	a5,a5,0x30
    8000597e:	4705                	li	a4,1
    80005980:	00f76c63          	bltu	a4,a5,80005998 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005984:	8526                	mv	a0,s1
    80005986:	60a6                	ld	ra,72(sp)
    80005988:	6406                	ld	s0,64(sp)
    8000598a:	74e2                	ld	s1,56(sp)
    8000598c:	7942                	ld	s2,48(sp)
    8000598e:	79a2                	ld	s3,40(sp)
    80005990:	7a02                	ld	s4,32(sp)
    80005992:	6ae2                	ld	s5,24(sp)
    80005994:	6161                	addi	sp,sp,80
    80005996:	8082                	ret
    iunlockput(ip);
    80005998:	8526                	mv	a0,s1
    8000599a:	fffff097          	auipc	ra,0xfffff
    8000599e:	890080e7          	jalr	-1904(ra) # 8000422a <iunlockput>
    return 0;
    800059a2:	4481                	li	s1,0
    800059a4:	b7c5                	j	80005984 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800059a6:	85ce                	mv	a1,s3
    800059a8:	00092503          	lw	a0,0(s2)
    800059ac:	ffffe097          	auipc	ra,0xffffe
    800059b0:	482080e7          	jalr	1154(ra) # 80003e2e <ialloc>
    800059b4:	84aa                	mv	s1,a0
    800059b6:	c521                	beqz	a0,800059fe <create+0xec>
  ilock(ip);
    800059b8:	ffffe097          	auipc	ra,0xffffe
    800059bc:	610080e7          	jalr	1552(ra) # 80003fc8 <ilock>
  ip->major = major;
    800059c0:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800059c4:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800059c8:	4a05                	li	s4,1
    800059ca:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    800059ce:	8526                	mv	a0,s1
    800059d0:	ffffe097          	auipc	ra,0xffffe
    800059d4:	52c080e7          	jalr	1324(ra) # 80003efc <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800059d8:	2981                	sext.w	s3,s3
    800059da:	03498a63          	beq	s3,s4,80005a0e <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800059de:	40d0                	lw	a2,4(s1)
    800059e0:	fb040593          	addi	a1,s0,-80
    800059e4:	854a                	mv	a0,s2
    800059e6:	fffff097          	auipc	ra,0xfffff
    800059ea:	cdc080e7          	jalr	-804(ra) # 800046c2 <dirlink>
    800059ee:	06054b63          	bltz	a0,80005a64 <create+0x152>
  iunlockput(dp);
    800059f2:	854a                	mv	a0,s2
    800059f4:	fffff097          	auipc	ra,0xfffff
    800059f8:	836080e7          	jalr	-1994(ra) # 8000422a <iunlockput>
  return ip;
    800059fc:	b761                	j	80005984 <create+0x72>
    panic("create: ialloc");
    800059fe:	00003517          	auipc	a0,0x3
    80005a02:	e0250513          	addi	a0,a0,-510 # 80008800 <syscalls+0x2c8>
    80005a06:	ffffb097          	auipc	ra,0xffffb
    80005a0a:	b34080e7          	jalr	-1228(ra) # 8000053a <panic>
    dp->nlink++;  // for ".."
    80005a0e:	04a95783          	lhu	a5,74(s2)
    80005a12:	2785                	addiw	a5,a5,1
    80005a14:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005a18:	854a                	mv	a0,s2
    80005a1a:	ffffe097          	auipc	ra,0xffffe
    80005a1e:	4e2080e7          	jalr	1250(ra) # 80003efc <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005a22:	40d0                	lw	a2,4(s1)
    80005a24:	00003597          	auipc	a1,0x3
    80005a28:	dec58593          	addi	a1,a1,-532 # 80008810 <syscalls+0x2d8>
    80005a2c:	8526                	mv	a0,s1
    80005a2e:	fffff097          	auipc	ra,0xfffff
    80005a32:	c94080e7          	jalr	-876(ra) # 800046c2 <dirlink>
    80005a36:	00054f63          	bltz	a0,80005a54 <create+0x142>
    80005a3a:	00492603          	lw	a2,4(s2)
    80005a3e:	00003597          	auipc	a1,0x3
    80005a42:	dda58593          	addi	a1,a1,-550 # 80008818 <syscalls+0x2e0>
    80005a46:	8526                	mv	a0,s1
    80005a48:	fffff097          	auipc	ra,0xfffff
    80005a4c:	c7a080e7          	jalr	-902(ra) # 800046c2 <dirlink>
    80005a50:	f80557e3          	bgez	a0,800059de <create+0xcc>
      panic("create dots");
    80005a54:	00003517          	auipc	a0,0x3
    80005a58:	dcc50513          	addi	a0,a0,-564 # 80008820 <syscalls+0x2e8>
    80005a5c:	ffffb097          	auipc	ra,0xffffb
    80005a60:	ade080e7          	jalr	-1314(ra) # 8000053a <panic>
    panic("create: dirlink");
    80005a64:	00003517          	auipc	a0,0x3
    80005a68:	dcc50513          	addi	a0,a0,-564 # 80008830 <syscalls+0x2f8>
    80005a6c:	ffffb097          	auipc	ra,0xffffb
    80005a70:	ace080e7          	jalr	-1330(ra) # 8000053a <panic>
    return 0;
    80005a74:	84aa                	mv	s1,a0
    80005a76:	b739                	j	80005984 <create+0x72>

0000000080005a78 <sys_dup>:
{
    80005a78:	7179                	addi	sp,sp,-48
    80005a7a:	f406                	sd	ra,40(sp)
    80005a7c:	f022                	sd	s0,32(sp)
    80005a7e:	ec26                	sd	s1,24(sp)
    80005a80:	e84a                	sd	s2,16(sp)
    80005a82:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005a84:	fd840613          	addi	a2,s0,-40
    80005a88:	4581                	li	a1,0
    80005a8a:	4501                	li	a0,0
    80005a8c:	00000097          	auipc	ra,0x0
    80005a90:	ddc080e7          	jalr	-548(ra) # 80005868 <argfd>
    return -1;
    80005a94:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005a96:	02054363          	bltz	a0,80005abc <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    80005a9a:	fd843903          	ld	s2,-40(s0)
    80005a9e:	854a                	mv	a0,s2
    80005aa0:	00000097          	auipc	ra,0x0
    80005aa4:	e30080e7          	jalr	-464(ra) # 800058d0 <fdalloc>
    80005aa8:	84aa                	mv	s1,a0
    return -1;
    80005aaa:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005aac:	00054863          	bltz	a0,80005abc <sys_dup+0x44>
  filedup(f);
    80005ab0:	854a                	mv	a0,s2
    80005ab2:	fffff097          	auipc	ra,0xfffff
    80005ab6:	368080e7          	jalr	872(ra) # 80004e1a <filedup>
  return fd;
    80005aba:	87a6                	mv	a5,s1
}
    80005abc:	853e                	mv	a0,a5
    80005abe:	70a2                	ld	ra,40(sp)
    80005ac0:	7402                	ld	s0,32(sp)
    80005ac2:	64e2                	ld	s1,24(sp)
    80005ac4:	6942                	ld	s2,16(sp)
    80005ac6:	6145                	addi	sp,sp,48
    80005ac8:	8082                	ret

0000000080005aca <sys_read>:
{
    80005aca:	7179                	addi	sp,sp,-48
    80005acc:	f406                	sd	ra,40(sp)
    80005ace:	f022                	sd	s0,32(sp)
    80005ad0:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005ad2:	fe840613          	addi	a2,s0,-24
    80005ad6:	4581                	li	a1,0
    80005ad8:	4501                	li	a0,0
    80005ada:	00000097          	auipc	ra,0x0
    80005ade:	d8e080e7          	jalr	-626(ra) # 80005868 <argfd>
    return -1;
    80005ae2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005ae4:	04054163          	bltz	a0,80005b26 <sys_read+0x5c>
    80005ae8:	fe440593          	addi	a1,s0,-28
    80005aec:	4509                	li	a0,2
    80005aee:	ffffd097          	auipc	ra,0xffffd
    80005af2:	7d4080e7          	jalr	2004(ra) # 800032c2 <argint>
    return -1;
    80005af6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005af8:	02054763          	bltz	a0,80005b26 <sys_read+0x5c>
    80005afc:	fd840593          	addi	a1,s0,-40
    80005b00:	4505                	li	a0,1
    80005b02:	ffffd097          	auipc	ra,0xffffd
    80005b06:	7e2080e7          	jalr	2018(ra) # 800032e4 <argaddr>
    return -1;
    80005b0a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005b0c:	00054d63          	bltz	a0,80005b26 <sys_read+0x5c>
  return fileread(f, p, n);
    80005b10:	fe442603          	lw	a2,-28(s0)
    80005b14:	fd843583          	ld	a1,-40(s0)
    80005b18:	fe843503          	ld	a0,-24(s0)
    80005b1c:	fffff097          	auipc	ra,0xfffff
    80005b20:	48a080e7          	jalr	1162(ra) # 80004fa6 <fileread>
    80005b24:	87aa                	mv	a5,a0
}
    80005b26:	853e                	mv	a0,a5
    80005b28:	70a2                	ld	ra,40(sp)
    80005b2a:	7402                	ld	s0,32(sp)
    80005b2c:	6145                	addi	sp,sp,48
    80005b2e:	8082                	ret

0000000080005b30 <sys_write>:
{
    80005b30:	7179                	addi	sp,sp,-48
    80005b32:	f406                	sd	ra,40(sp)
    80005b34:	f022                	sd	s0,32(sp)
    80005b36:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005b38:	fe840613          	addi	a2,s0,-24
    80005b3c:	4581                	li	a1,0
    80005b3e:	4501                	li	a0,0
    80005b40:	00000097          	auipc	ra,0x0
    80005b44:	d28080e7          	jalr	-728(ra) # 80005868 <argfd>
    return -1;
    80005b48:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005b4a:	04054163          	bltz	a0,80005b8c <sys_write+0x5c>
    80005b4e:	fe440593          	addi	a1,s0,-28
    80005b52:	4509                	li	a0,2
    80005b54:	ffffd097          	auipc	ra,0xffffd
    80005b58:	76e080e7          	jalr	1902(ra) # 800032c2 <argint>
    return -1;
    80005b5c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005b5e:	02054763          	bltz	a0,80005b8c <sys_write+0x5c>
    80005b62:	fd840593          	addi	a1,s0,-40
    80005b66:	4505                	li	a0,1
    80005b68:	ffffd097          	auipc	ra,0xffffd
    80005b6c:	77c080e7          	jalr	1916(ra) # 800032e4 <argaddr>
    return -1;
    80005b70:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005b72:	00054d63          	bltz	a0,80005b8c <sys_write+0x5c>
  return filewrite(f, p, n);
    80005b76:	fe442603          	lw	a2,-28(s0)
    80005b7a:	fd843583          	ld	a1,-40(s0)
    80005b7e:	fe843503          	ld	a0,-24(s0)
    80005b82:	fffff097          	auipc	ra,0xfffff
    80005b86:	4e6080e7          	jalr	1254(ra) # 80005068 <filewrite>
    80005b8a:	87aa                	mv	a5,a0
}
    80005b8c:	853e                	mv	a0,a5
    80005b8e:	70a2                	ld	ra,40(sp)
    80005b90:	7402                	ld	s0,32(sp)
    80005b92:	6145                	addi	sp,sp,48
    80005b94:	8082                	ret

0000000080005b96 <sys_close>:
{
    80005b96:	1101                	addi	sp,sp,-32
    80005b98:	ec06                	sd	ra,24(sp)
    80005b9a:	e822                	sd	s0,16(sp)
    80005b9c:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005b9e:	fe040613          	addi	a2,s0,-32
    80005ba2:	fec40593          	addi	a1,s0,-20
    80005ba6:	4501                	li	a0,0
    80005ba8:	00000097          	auipc	ra,0x0
    80005bac:	cc0080e7          	jalr	-832(ra) # 80005868 <argfd>
    return -1;
    80005bb0:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005bb2:	02054463          	bltz	a0,80005bda <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005bb6:	ffffc097          	auipc	ra,0xffffc
    80005bba:	e68080e7          	jalr	-408(ra) # 80001a1e <myproc>
    80005bbe:	fec42783          	lw	a5,-20(s0)
    80005bc2:	07f1                	addi	a5,a5,28
    80005bc4:	078e                	slli	a5,a5,0x3
    80005bc6:	953e                	add	a0,a0,a5
    80005bc8:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005bcc:	fe043503          	ld	a0,-32(s0)
    80005bd0:	fffff097          	auipc	ra,0xfffff
    80005bd4:	29c080e7          	jalr	668(ra) # 80004e6c <fileclose>
  return 0;
    80005bd8:	4781                	li	a5,0
}
    80005bda:	853e                	mv	a0,a5
    80005bdc:	60e2                	ld	ra,24(sp)
    80005bde:	6442                	ld	s0,16(sp)
    80005be0:	6105                	addi	sp,sp,32
    80005be2:	8082                	ret

0000000080005be4 <sys_fstat>:
{
    80005be4:	1101                	addi	sp,sp,-32
    80005be6:	ec06                	sd	ra,24(sp)
    80005be8:	e822                	sd	s0,16(sp)
    80005bea:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005bec:	fe840613          	addi	a2,s0,-24
    80005bf0:	4581                	li	a1,0
    80005bf2:	4501                	li	a0,0
    80005bf4:	00000097          	auipc	ra,0x0
    80005bf8:	c74080e7          	jalr	-908(ra) # 80005868 <argfd>
    return -1;
    80005bfc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005bfe:	02054563          	bltz	a0,80005c28 <sys_fstat+0x44>
    80005c02:	fe040593          	addi	a1,s0,-32
    80005c06:	4505                	li	a0,1
    80005c08:	ffffd097          	auipc	ra,0xffffd
    80005c0c:	6dc080e7          	jalr	1756(ra) # 800032e4 <argaddr>
    return -1;
    80005c10:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005c12:	00054b63          	bltz	a0,80005c28 <sys_fstat+0x44>
  return filestat(f, st);
    80005c16:	fe043583          	ld	a1,-32(s0)
    80005c1a:	fe843503          	ld	a0,-24(s0)
    80005c1e:	fffff097          	auipc	ra,0xfffff
    80005c22:	316080e7          	jalr	790(ra) # 80004f34 <filestat>
    80005c26:	87aa                	mv	a5,a0
}
    80005c28:	853e                	mv	a0,a5
    80005c2a:	60e2                	ld	ra,24(sp)
    80005c2c:	6442                	ld	s0,16(sp)
    80005c2e:	6105                	addi	sp,sp,32
    80005c30:	8082                	ret

0000000080005c32 <sys_link>:
{
    80005c32:	7169                	addi	sp,sp,-304
    80005c34:	f606                	sd	ra,296(sp)
    80005c36:	f222                	sd	s0,288(sp)
    80005c38:	ee26                	sd	s1,280(sp)
    80005c3a:	ea4a                	sd	s2,272(sp)
    80005c3c:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005c3e:	08000613          	li	a2,128
    80005c42:	ed040593          	addi	a1,s0,-304
    80005c46:	4501                	li	a0,0
    80005c48:	ffffd097          	auipc	ra,0xffffd
    80005c4c:	6be080e7          	jalr	1726(ra) # 80003306 <argstr>
    return -1;
    80005c50:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005c52:	10054e63          	bltz	a0,80005d6e <sys_link+0x13c>
    80005c56:	08000613          	li	a2,128
    80005c5a:	f5040593          	addi	a1,s0,-176
    80005c5e:	4505                	li	a0,1
    80005c60:	ffffd097          	auipc	ra,0xffffd
    80005c64:	6a6080e7          	jalr	1702(ra) # 80003306 <argstr>
    return -1;
    80005c68:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005c6a:	10054263          	bltz	a0,80005d6e <sys_link+0x13c>
  begin_op();
    80005c6e:	fffff097          	auipc	ra,0xfffff
    80005c72:	d36080e7          	jalr	-714(ra) # 800049a4 <begin_op>
  if((ip = namei(old)) == 0){
    80005c76:	ed040513          	addi	a0,s0,-304
    80005c7a:	fffff097          	auipc	ra,0xfffff
    80005c7e:	b0a080e7          	jalr	-1270(ra) # 80004784 <namei>
    80005c82:	84aa                	mv	s1,a0
    80005c84:	c551                	beqz	a0,80005d10 <sys_link+0xde>
  ilock(ip);
    80005c86:	ffffe097          	auipc	ra,0xffffe
    80005c8a:	342080e7          	jalr	834(ra) # 80003fc8 <ilock>
  if(ip->type == T_DIR){
    80005c8e:	04449703          	lh	a4,68(s1)
    80005c92:	4785                	li	a5,1
    80005c94:	08f70463          	beq	a4,a5,80005d1c <sys_link+0xea>
  ip->nlink++;
    80005c98:	04a4d783          	lhu	a5,74(s1)
    80005c9c:	2785                	addiw	a5,a5,1
    80005c9e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005ca2:	8526                	mv	a0,s1
    80005ca4:	ffffe097          	auipc	ra,0xffffe
    80005ca8:	258080e7          	jalr	600(ra) # 80003efc <iupdate>
  iunlock(ip);
    80005cac:	8526                	mv	a0,s1
    80005cae:	ffffe097          	auipc	ra,0xffffe
    80005cb2:	3dc080e7          	jalr	988(ra) # 8000408a <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005cb6:	fd040593          	addi	a1,s0,-48
    80005cba:	f5040513          	addi	a0,s0,-176
    80005cbe:	fffff097          	auipc	ra,0xfffff
    80005cc2:	ae4080e7          	jalr	-1308(ra) # 800047a2 <nameiparent>
    80005cc6:	892a                	mv	s2,a0
    80005cc8:	c935                	beqz	a0,80005d3c <sys_link+0x10a>
  ilock(dp);
    80005cca:	ffffe097          	auipc	ra,0xffffe
    80005cce:	2fe080e7          	jalr	766(ra) # 80003fc8 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005cd2:	00092703          	lw	a4,0(s2)
    80005cd6:	409c                	lw	a5,0(s1)
    80005cd8:	04f71d63          	bne	a4,a5,80005d32 <sys_link+0x100>
    80005cdc:	40d0                	lw	a2,4(s1)
    80005cde:	fd040593          	addi	a1,s0,-48
    80005ce2:	854a                	mv	a0,s2
    80005ce4:	fffff097          	auipc	ra,0xfffff
    80005ce8:	9de080e7          	jalr	-1570(ra) # 800046c2 <dirlink>
    80005cec:	04054363          	bltz	a0,80005d32 <sys_link+0x100>
  iunlockput(dp);
    80005cf0:	854a                	mv	a0,s2
    80005cf2:	ffffe097          	auipc	ra,0xffffe
    80005cf6:	538080e7          	jalr	1336(ra) # 8000422a <iunlockput>
  iput(ip);
    80005cfa:	8526                	mv	a0,s1
    80005cfc:	ffffe097          	auipc	ra,0xffffe
    80005d00:	486080e7          	jalr	1158(ra) # 80004182 <iput>
  end_op();
    80005d04:	fffff097          	auipc	ra,0xfffff
    80005d08:	d1e080e7          	jalr	-738(ra) # 80004a22 <end_op>
  return 0;
    80005d0c:	4781                	li	a5,0
    80005d0e:	a085                	j	80005d6e <sys_link+0x13c>
    end_op();
    80005d10:	fffff097          	auipc	ra,0xfffff
    80005d14:	d12080e7          	jalr	-750(ra) # 80004a22 <end_op>
    return -1;
    80005d18:	57fd                	li	a5,-1
    80005d1a:	a891                	j	80005d6e <sys_link+0x13c>
    iunlockput(ip);
    80005d1c:	8526                	mv	a0,s1
    80005d1e:	ffffe097          	auipc	ra,0xffffe
    80005d22:	50c080e7          	jalr	1292(ra) # 8000422a <iunlockput>
    end_op();
    80005d26:	fffff097          	auipc	ra,0xfffff
    80005d2a:	cfc080e7          	jalr	-772(ra) # 80004a22 <end_op>
    return -1;
    80005d2e:	57fd                	li	a5,-1
    80005d30:	a83d                	j	80005d6e <sys_link+0x13c>
    iunlockput(dp);
    80005d32:	854a                	mv	a0,s2
    80005d34:	ffffe097          	auipc	ra,0xffffe
    80005d38:	4f6080e7          	jalr	1270(ra) # 8000422a <iunlockput>
  ilock(ip);
    80005d3c:	8526                	mv	a0,s1
    80005d3e:	ffffe097          	auipc	ra,0xffffe
    80005d42:	28a080e7          	jalr	650(ra) # 80003fc8 <ilock>
  ip->nlink--;
    80005d46:	04a4d783          	lhu	a5,74(s1)
    80005d4a:	37fd                	addiw	a5,a5,-1
    80005d4c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005d50:	8526                	mv	a0,s1
    80005d52:	ffffe097          	auipc	ra,0xffffe
    80005d56:	1aa080e7          	jalr	426(ra) # 80003efc <iupdate>
  iunlockput(ip);
    80005d5a:	8526                	mv	a0,s1
    80005d5c:	ffffe097          	auipc	ra,0xffffe
    80005d60:	4ce080e7          	jalr	1230(ra) # 8000422a <iunlockput>
  end_op();
    80005d64:	fffff097          	auipc	ra,0xfffff
    80005d68:	cbe080e7          	jalr	-834(ra) # 80004a22 <end_op>
  return -1;
    80005d6c:	57fd                	li	a5,-1
}
    80005d6e:	853e                	mv	a0,a5
    80005d70:	70b2                	ld	ra,296(sp)
    80005d72:	7412                	ld	s0,288(sp)
    80005d74:	64f2                	ld	s1,280(sp)
    80005d76:	6952                	ld	s2,272(sp)
    80005d78:	6155                	addi	sp,sp,304
    80005d7a:	8082                	ret

0000000080005d7c <sys_unlink>:
{
    80005d7c:	7151                	addi	sp,sp,-240
    80005d7e:	f586                	sd	ra,232(sp)
    80005d80:	f1a2                	sd	s0,224(sp)
    80005d82:	eda6                	sd	s1,216(sp)
    80005d84:	e9ca                	sd	s2,208(sp)
    80005d86:	e5ce                	sd	s3,200(sp)
    80005d88:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005d8a:	08000613          	li	a2,128
    80005d8e:	f3040593          	addi	a1,s0,-208
    80005d92:	4501                	li	a0,0
    80005d94:	ffffd097          	auipc	ra,0xffffd
    80005d98:	572080e7          	jalr	1394(ra) # 80003306 <argstr>
    80005d9c:	18054163          	bltz	a0,80005f1e <sys_unlink+0x1a2>
  begin_op();
    80005da0:	fffff097          	auipc	ra,0xfffff
    80005da4:	c04080e7          	jalr	-1020(ra) # 800049a4 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005da8:	fb040593          	addi	a1,s0,-80
    80005dac:	f3040513          	addi	a0,s0,-208
    80005db0:	fffff097          	auipc	ra,0xfffff
    80005db4:	9f2080e7          	jalr	-1550(ra) # 800047a2 <nameiparent>
    80005db8:	84aa                	mv	s1,a0
    80005dba:	c979                	beqz	a0,80005e90 <sys_unlink+0x114>
  ilock(dp);
    80005dbc:	ffffe097          	auipc	ra,0xffffe
    80005dc0:	20c080e7          	jalr	524(ra) # 80003fc8 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005dc4:	00003597          	auipc	a1,0x3
    80005dc8:	a4c58593          	addi	a1,a1,-1460 # 80008810 <syscalls+0x2d8>
    80005dcc:	fb040513          	addi	a0,s0,-80
    80005dd0:	ffffe097          	auipc	ra,0xffffe
    80005dd4:	6c2080e7          	jalr	1730(ra) # 80004492 <namecmp>
    80005dd8:	14050a63          	beqz	a0,80005f2c <sys_unlink+0x1b0>
    80005ddc:	00003597          	auipc	a1,0x3
    80005de0:	a3c58593          	addi	a1,a1,-1476 # 80008818 <syscalls+0x2e0>
    80005de4:	fb040513          	addi	a0,s0,-80
    80005de8:	ffffe097          	auipc	ra,0xffffe
    80005dec:	6aa080e7          	jalr	1706(ra) # 80004492 <namecmp>
    80005df0:	12050e63          	beqz	a0,80005f2c <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005df4:	f2c40613          	addi	a2,s0,-212
    80005df8:	fb040593          	addi	a1,s0,-80
    80005dfc:	8526                	mv	a0,s1
    80005dfe:	ffffe097          	auipc	ra,0xffffe
    80005e02:	6ae080e7          	jalr	1710(ra) # 800044ac <dirlookup>
    80005e06:	892a                	mv	s2,a0
    80005e08:	12050263          	beqz	a0,80005f2c <sys_unlink+0x1b0>
  ilock(ip);
    80005e0c:	ffffe097          	auipc	ra,0xffffe
    80005e10:	1bc080e7          	jalr	444(ra) # 80003fc8 <ilock>
  if(ip->nlink < 1)
    80005e14:	04a91783          	lh	a5,74(s2)
    80005e18:	08f05263          	blez	a5,80005e9c <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005e1c:	04491703          	lh	a4,68(s2)
    80005e20:	4785                	li	a5,1
    80005e22:	08f70563          	beq	a4,a5,80005eac <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005e26:	4641                	li	a2,16
    80005e28:	4581                	li	a1,0
    80005e2a:	fc040513          	addi	a0,s0,-64
    80005e2e:	ffffb097          	auipc	ra,0xffffb
    80005e32:	e9e080e7          	jalr	-354(ra) # 80000ccc <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005e36:	4741                	li	a4,16
    80005e38:	f2c42683          	lw	a3,-212(s0)
    80005e3c:	fc040613          	addi	a2,s0,-64
    80005e40:	4581                	li	a1,0
    80005e42:	8526                	mv	a0,s1
    80005e44:	ffffe097          	auipc	ra,0xffffe
    80005e48:	530080e7          	jalr	1328(ra) # 80004374 <writei>
    80005e4c:	47c1                	li	a5,16
    80005e4e:	0af51563          	bne	a0,a5,80005ef8 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005e52:	04491703          	lh	a4,68(s2)
    80005e56:	4785                	li	a5,1
    80005e58:	0af70863          	beq	a4,a5,80005f08 <sys_unlink+0x18c>
  iunlockput(dp);
    80005e5c:	8526                	mv	a0,s1
    80005e5e:	ffffe097          	auipc	ra,0xffffe
    80005e62:	3cc080e7          	jalr	972(ra) # 8000422a <iunlockput>
  ip->nlink--;
    80005e66:	04a95783          	lhu	a5,74(s2)
    80005e6a:	37fd                	addiw	a5,a5,-1
    80005e6c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005e70:	854a                	mv	a0,s2
    80005e72:	ffffe097          	auipc	ra,0xffffe
    80005e76:	08a080e7          	jalr	138(ra) # 80003efc <iupdate>
  iunlockput(ip);
    80005e7a:	854a                	mv	a0,s2
    80005e7c:	ffffe097          	auipc	ra,0xffffe
    80005e80:	3ae080e7          	jalr	942(ra) # 8000422a <iunlockput>
  end_op();
    80005e84:	fffff097          	auipc	ra,0xfffff
    80005e88:	b9e080e7          	jalr	-1122(ra) # 80004a22 <end_op>
  return 0;
    80005e8c:	4501                	li	a0,0
    80005e8e:	a84d                	j	80005f40 <sys_unlink+0x1c4>
    end_op();
    80005e90:	fffff097          	auipc	ra,0xfffff
    80005e94:	b92080e7          	jalr	-1134(ra) # 80004a22 <end_op>
    return -1;
    80005e98:	557d                	li	a0,-1
    80005e9a:	a05d                	j	80005f40 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005e9c:	00003517          	auipc	a0,0x3
    80005ea0:	9a450513          	addi	a0,a0,-1628 # 80008840 <syscalls+0x308>
    80005ea4:	ffffa097          	auipc	ra,0xffffa
    80005ea8:	696080e7          	jalr	1686(ra) # 8000053a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005eac:	04c92703          	lw	a4,76(s2)
    80005eb0:	02000793          	li	a5,32
    80005eb4:	f6e7f9e3          	bgeu	a5,a4,80005e26 <sys_unlink+0xaa>
    80005eb8:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005ebc:	4741                	li	a4,16
    80005ebe:	86ce                	mv	a3,s3
    80005ec0:	f1840613          	addi	a2,s0,-232
    80005ec4:	4581                	li	a1,0
    80005ec6:	854a                	mv	a0,s2
    80005ec8:	ffffe097          	auipc	ra,0xffffe
    80005ecc:	3b4080e7          	jalr	948(ra) # 8000427c <readi>
    80005ed0:	47c1                	li	a5,16
    80005ed2:	00f51b63          	bne	a0,a5,80005ee8 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005ed6:	f1845783          	lhu	a5,-232(s0)
    80005eda:	e7a1                	bnez	a5,80005f22 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005edc:	29c1                	addiw	s3,s3,16
    80005ede:	04c92783          	lw	a5,76(s2)
    80005ee2:	fcf9ede3          	bltu	s3,a5,80005ebc <sys_unlink+0x140>
    80005ee6:	b781                	j	80005e26 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005ee8:	00003517          	auipc	a0,0x3
    80005eec:	97050513          	addi	a0,a0,-1680 # 80008858 <syscalls+0x320>
    80005ef0:	ffffa097          	auipc	ra,0xffffa
    80005ef4:	64a080e7          	jalr	1610(ra) # 8000053a <panic>
    panic("unlink: writei");
    80005ef8:	00003517          	auipc	a0,0x3
    80005efc:	97850513          	addi	a0,a0,-1672 # 80008870 <syscalls+0x338>
    80005f00:	ffffa097          	auipc	ra,0xffffa
    80005f04:	63a080e7          	jalr	1594(ra) # 8000053a <panic>
    dp->nlink--;
    80005f08:	04a4d783          	lhu	a5,74(s1)
    80005f0c:	37fd                	addiw	a5,a5,-1
    80005f0e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005f12:	8526                	mv	a0,s1
    80005f14:	ffffe097          	auipc	ra,0xffffe
    80005f18:	fe8080e7          	jalr	-24(ra) # 80003efc <iupdate>
    80005f1c:	b781                	j	80005e5c <sys_unlink+0xe0>
    return -1;
    80005f1e:	557d                	li	a0,-1
    80005f20:	a005                	j	80005f40 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005f22:	854a                	mv	a0,s2
    80005f24:	ffffe097          	auipc	ra,0xffffe
    80005f28:	306080e7          	jalr	774(ra) # 8000422a <iunlockput>
  iunlockput(dp);
    80005f2c:	8526                	mv	a0,s1
    80005f2e:	ffffe097          	auipc	ra,0xffffe
    80005f32:	2fc080e7          	jalr	764(ra) # 8000422a <iunlockput>
  end_op();
    80005f36:	fffff097          	auipc	ra,0xfffff
    80005f3a:	aec080e7          	jalr	-1300(ra) # 80004a22 <end_op>
  return -1;
    80005f3e:	557d                	li	a0,-1
}
    80005f40:	70ae                	ld	ra,232(sp)
    80005f42:	740e                	ld	s0,224(sp)
    80005f44:	64ee                	ld	s1,216(sp)
    80005f46:	694e                	ld	s2,208(sp)
    80005f48:	69ae                	ld	s3,200(sp)
    80005f4a:	616d                	addi	sp,sp,240
    80005f4c:	8082                	ret

0000000080005f4e <sys_open>:

uint64
sys_open(void)
{
    80005f4e:	7131                	addi	sp,sp,-192
    80005f50:	fd06                	sd	ra,184(sp)
    80005f52:	f922                	sd	s0,176(sp)
    80005f54:	f526                	sd	s1,168(sp)
    80005f56:	f14a                	sd	s2,160(sp)
    80005f58:	ed4e                	sd	s3,152(sp)
    80005f5a:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005f5c:	08000613          	li	a2,128
    80005f60:	f5040593          	addi	a1,s0,-176
    80005f64:	4501                	li	a0,0
    80005f66:	ffffd097          	auipc	ra,0xffffd
    80005f6a:	3a0080e7          	jalr	928(ra) # 80003306 <argstr>
    return -1;
    80005f6e:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005f70:	0c054163          	bltz	a0,80006032 <sys_open+0xe4>
    80005f74:	f4c40593          	addi	a1,s0,-180
    80005f78:	4505                	li	a0,1
    80005f7a:	ffffd097          	auipc	ra,0xffffd
    80005f7e:	348080e7          	jalr	840(ra) # 800032c2 <argint>
    80005f82:	0a054863          	bltz	a0,80006032 <sys_open+0xe4>

  begin_op();
    80005f86:	fffff097          	auipc	ra,0xfffff
    80005f8a:	a1e080e7          	jalr	-1506(ra) # 800049a4 <begin_op>

  if(omode & O_CREATE){
    80005f8e:	f4c42783          	lw	a5,-180(s0)
    80005f92:	2007f793          	andi	a5,a5,512
    80005f96:	cbdd                	beqz	a5,8000604c <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005f98:	4681                	li	a3,0
    80005f9a:	4601                	li	a2,0
    80005f9c:	4589                	li	a1,2
    80005f9e:	f5040513          	addi	a0,s0,-176
    80005fa2:	00000097          	auipc	ra,0x0
    80005fa6:	970080e7          	jalr	-1680(ra) # 80005912 <create>
    80005faa:	892a                	mv	s2,a0
    if(ip == 0){
    80005fac:	c959                	beqz	a0,80006042 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005fae:	04491703          	lh	a4,68(s2)
    80005fb2:	478d                	li	a5,3
    80005fb4:	00f71763          	bne	a4,a5,80005fc2 <sys_open+0x74>
    80005fb8:	04695703          	lhu	a4,70(s2)
    80005fbc:	47a5                	li	a5,9
    80005fbe:	0ce7ec63          	bltu	a5,a4,80006096 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005fc2:	fffff097          	auipc	ra,0xfffff
    80005fc6:	dee080e7          	jalr	-530(ra) # 80004db0 <filealloc>
    80005fca:	89aa                	mv	s3,a0
    80005fcc:	10050263          	beqz	a0,800060d0 <sys_open+0x182>
    80005fd0:	00000097          	auipc	ra,0x0
    80005fd4:	900080e7          	jalr	-1792(ra) # 800058d0 <fdalloc>
    80005fd8:	84aa                	mv	s1,a0
    80005fda:	0e054663          	bltz	a0,800060c6 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005fde:	04491703          	lh	a4,68(s2)
    80005fe2:	478d                	li	a5,3
    80005fe4:	0cf70463          	beq	a4,a5,800060ac <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005fe8:	4789                	li	a5,2
    80005fea:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005fee:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005ff2:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005ff6:	f4c42783          	lw	a5,-180(s0)
    80005ffa:	0017c713          	xori	a4,a5,1
    80005ffe:	8b05                	andi	a4,a4,1
    80006000:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80006004:	0037f713          	andi	a4,a5,3
    80006008:	00e03733          	snez	a4,a4
    8000600c:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80006010:	4007f793          	andi	a5,a5,1024
    80006014:	c791                	beqz	a5,80006020 <sys_open+0xd2>
    80006016:	04491703          	lh	a4,68(s2)
    8000601a:	4789                	li	a5,2
    8000601c:	08f70f63          	beq	a4,a5,800060ba <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80006020:	854a                	mv	a0,s2
    80006022:	ffffe097          	auipc	ra,0xffffe
    80006026:	068080e7          	jalr	104(ra) # 8000408a <iunlock>
  end_op();
    8000602a:	fffff097          	auipc	ra,0xfffff
    8000602e:	9f8080e7          	jalr	-1544(ra) # 80004a22 <end_op>

  return fd;
}
    80006032:	8526                	mv	a0,s1
    80006034:	70ea                	ld	ra,184(sp)
    80006036:	744a                	ld	s0,176(sp)
    80006038:	74aa                	ld	s1,168(sp)
    8000603a:	790a                	ld	s2,160(sp)
    8000603c:	69ea                	ld	s3,152(sp)
    8000603e:	6129                	addi	sp,sp,192
    80006040:	8082                	ret
      end_op();
    80006042:	fffff097          	auipc	ra,0xfffff
    80006046:	9e0080e7          	jalr	-1568(ra) # 80004a22 <end_op>
      return -1;
    8000604a:	b7e5                	j	80006032 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    8000604c:	f5040513          	addi	a0,s0,-176
    80006050:	ffffe097          	auipc	ra,0xffffe
    80006054:	734080e7          	jalr	1844(ra) # 80004784 <namei>
    80006058:	892a                	mv	s2,a0
    8000605a:	c905                	beqz	a0,8000608a <sys_open+0x13c>
    ilock(ip);
    8000605c:	ffffe097          	auipc	ra,0xffffe
    80006060:	f6c080e7          	jalr	-148(ra) # 80003fc8 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80006064:	04491703          	lh	a4,68(s2)
    80006068:	4785                	li	a5,1
    8000606a:	f4f712e3          	bne	a4,a5,80005fae <sys_open+0x60>
    8000606e:	f4c42783          	lw	a5,-180(s0)
    80006072:	dba1                	beqz	a5,80005fc2 <sys_open+0x74>
      iunlockput(ip);
    80006074:	854a                	mv	a0,s2
    80006076:	ffffe097          	auipc	ra,0xffffe
    8000607a:	1b4080e7          	jalr	436(ra) # 8000422a <iunlockput>
      end_op();
    8000607e:	fffff097          	auipc	ra,0xfffff
    80006082:	9a4080e7          	jalr	-1628(ra) # 80004a22 <end_op>
      return -1;
    80006086:	54fd                	li	s1,-1
    80006088:	b76d                	j	80006032 <sys_open+0xe4>
      end_op();
    8000608a:	fffff097          	auipc	ra,0xfffff
    8000608e:	998080e7          	jalr	-1640(ra) # 80004a22 <end_op>
      return -1;
    80006092:	54fd                	li	s1,-1
    80006094:	bf79                	j	80006032 <sys_open+0xe4>
    iunlockput(ip);
    80006096:	854a                	mv	a0,s2
    80006098:	ffffe097          	auipc	ra,0xffffe
    8000609c:	192080e7          	jalr	402(ra) # 8000422a <iunlockput>
    end_op();
    800060a0:	fffff097          	auipc	ra,0xfffff
    800060a4:	982080e7          	jalr	-1662(ra) # 80004a22 <end_op>
    return -1;
    800060a8:	54fd                	li	s1,-1
    800060aa:	b761                	j	80006032 <sys_open+0xe4>
    f->type = FD_DEVICE;
    800060ac:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800060b0:	04691783          	lh	a5,70(s2)
    800060b4:	02f99223          	sh	a5,36(s3)
    800060b8:	bf2d                	j	80005ff2 <sys_open+0xa4>
    itrunc(ip);
    800060ba:	854a                	mv	a0,s2
    800060bc:	ffffe097          	auipc	ra,0xffffe
    800060c0:	01a080e7          	jalr	26(ra) # 800040d6 <itrunc>
    800060c4:	bfb1                	j	80006020 <sys_open+0xd2>
      fileclose(f);
    800060c6:	854e                	mv	a0,s3
    800060c8:	fffff097          	auipc	ra,0xfffff
    800060cc:	da4080e7          	jalr	-604(ra) # 80004e6c <fileclose>
    iunlockput(ip);
    800060d0:	854a                	mv	a0,s2
    800060d2:	ffffe097          	auipc	ra,0xffffe
    800060d6:	158080e7          	jalr	344(ra) # 8000422a <iunlockput>
    end_op();
    800060da:	fffff097          	auipc	ra,0xfffff
    800060de:	948080e7          	jalr	-1720(ra) # 80004a22 <end_op>
    return -1;
    800060e2:	54fd                	li	s1,-1
    800060e4:	b7b9                	j	80006032 <sys_open+0xe4>

00000000800060e6 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800060e6:	7175                	addi	sp,sp,-144
    800060e8:	e506                	sd	ra,136(sp)
    800060ea:	e122                	sd	s0,128(sp)
    800060ec:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800060ee:	fffff097          	auipc	ra,0xfffff
    800060f2:	8b6080e7          	jalr	-1866(ra) # 800049a4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800060f6:	08000613          	li	a2,128
    800060fa:	f7040593          	addi	a1,s0,-144
    800060fe:	4501                	li	a0,0
    80006100:	ffffd097          	auipc	ra,0xffffd
    80006104:	206080e7          	jalr	518(ra) # 80003306 <argstr>
    80006108:	02054963          	bltz	a0,8000613a <sys_mkdir+0x54>
    8000610c:	4681                	li	a3,0
    8000610e:	4601                	li	a2,0
    80006110:	4585                	li	a1,1
    80006112:	f7040513          	addi	a0,s0,-144
    80006116:	fffff097          	auipc	ra,0xfffff
    8000611a:	7fc080e7          	jalr	2044(ra) # 80005912 <create>
    8000611e:	cd11                	beqz	a0,8000613a <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006120:	ffffe097          	auipc	ra,0xffffe
    80006124:	10a080e7          	jalr	266(ra) # 8000422a <iunlockput>
  end_op();
    80006128:	fffff097          	auipc	ra,0xfffff
    8000612c:	8fa080e7          	jalr	-1798(ra) # 80004a22 <end_op>
  return 0;
    80006130:	4501                	li	a0,0
}
    80006132:	60aa                	ld	ra,136(sp)
    80006134:	640a                	ld	s0,128(sp)
    80006136:	6149                	addi	sp,sp,144
    80006138:	8082                	ret
    end_op();
    8000613a:	fffff097          	auipc	ra,0xfffff
    8000613e:	8e8080e7          	jalr	-1816(ra) # 80004a22 <end_op>
    return -1;
    80006142:	557d                	li	a0,-1
    80006144:	b7fd                	j	80006132 <sys_mkdir+0x4c>

0000000080006146 <sys_mknod>:

uint64
sys_mknod(void)
{
    80006146:	7135                	addi	sp,sp,-160
    80006148:	ed06                	sd	ra,152(sp)
    8000614a:	e922                	sd	s0,144(sp)
    8000614c:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000614e:	fffff097          	auipc	ra,0xfffff
    80006152:	856080e7          	jalr	-1962(ra) # 800049a4 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006156:	08000613          	li	a2,128
    8000615a:	f7040593          	addi	a1,s0,-144
    8000615e:	4501                	li	a0,0
    80006160:	ffffd097          	auipc	ra,0xffffd
    80006164:	1a6080e7          	jalr	422(ra) # 80003306 <argstr>
    80006168:	04054a63          	bltz	a0,800061bc <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    8000616c:	f6c40593          	addi	a1,s0,-148
    80006170:	4505                	li	a0,1
    80006172:	ffffd097          	auipc	ra,0xffffd
    80006176:	150080e7          	jalr	336(ra) # 800032c2 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000617a:	04054163          	bltz	a0,800061bc <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    8000617e:	f6840593          	addi	a1,s0,-152
    80006182:	4509                	li	a0,2
    80006184:	ffffd097          	auipc	ra,0xffffd
    80006188:	13e080e7          	jalr	318(ra) # 800032c2 <argint>
     argint(1, &major) < 0 ||
    8000618c:	02054863          	bltz	a0,800061bc <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80006190:	f6841683          	lh	a3,-152(s0)
    80006194:	f6c41603          	lh	a2,-148(s0)
    80006198:	458d                	li	a1,3
    8000619a:	f7040513          	addi	a0,s0,-144
    8000619e:	fffff097          	auipc	ra,0xfffff
    800061a2:	774080e7          	jalr	1908(ra) # 80005912 <create>
     argint(2, &minor) < 0 ||
    800061a6:	c919                	beqz	a0,800061bc <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800061a8:	ffffe097          	auipc	ra,0xffffe
    800061ac:	082080e7          	jalr	130(ra) # 8000422a <iunlockput>
  end_op();
    800061b0:	fffff097          	auipc	ra,0xfffff
    800061b4:	872080e7          	jalr	-1934(ra) # 80004a22 <end_op>
  return 0;
    800061b8:	4501                	li	a0,0
    800061ba:	a031                	j	800061c6 <sys_mknod+0x80>
    end_op();
    800061bc:	fffff097          	auipc	ra,0xfffff
    800061c0:	866080e7          	jalr	-1946(ra) # 80004a22 <end_op>
    return -1;
    800061c4:	557d                	li	a0,-1
}
    800061c6:	60ea                	ld	ra,152(sp)
    800061c8:	644a                	ld	s0,144(sp)
    800061ca:	610d                	addi	sp,sp,160
    800061cc:	8082                	ret

00000000800061ce <sys_chdir>:

uint64
sys_chdir(void)
{
    800061ce:	7135                	addi	sp,sp,-160
    800061d0:	ed06                	sd	ra,152(sp)
    800061d2:	e922                	sd	s0,144(sp)
    800061d4:	e526                	sd	s1,136(sp)
    800061d6:	e14a                	sd	s2,128(sp)
    800061d8:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800061da:	ffffc097          	auipc	ra,0xffffc
    800061de:	844080e7          	jalr	-1980(ra) # 80001a1e <myproc>
    800061e2:	892a                	mv	s2,a0
  
  begin_op();
    800061e4:	ffffe097          	auipc	ra,0xffffe
    800061e8:	7c0080e7          	jalr	1984(ra) # 800049a4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800061ec:	08000613          	li	a2,128
    800061f0:	f6040593          	addi	a1,s0,-160
    800061f4:	4501                	li	a0,0
    800061f6:	ffffd097          	auipc	ra,0xffffd
    800061fa:	110080e7          	jalr	272(ra) # 80003306 <argstr>
    800061fe:	04054b63          	bltz	a0,80006254 <sys_chdir+0x86>
    80006202:	f6040513          	addi	a0,s0,-160
    80006206:	ffffe097          	auipc	ra,0xffffe
    8000620a:	57e080e7          	jalr	1406(ra) # 80004784 <namei>
    8000620e:	84aa                	mv	s1,a0
    80006210:	c131                	beqz	a0,80006254 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80006212:	ffffe097          	auipc	ra,0xffffe
    80006216:	db6080e7          	jalr	-586(ra) # 80003fc8 <ilock>
  if(ip->type != T_DIR){
    8000621a:	04449703          	lh	a4,68(s1)
    8000621e:	4785                	li	a5,1
    80006220:	04f71063          	bne	a4,a5,80006260 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006224:	8526                	mv	a0,s1
    80006226:	ffffe097          	auipc	ra,0xffffe
    8000622a:	e64080e7          	jalr	-412(ra) # 8000408a <iunlock>
  iput(p->cwd);
    8000622e:	16093503          	ld	a0,352(s2)
    80006232:	ffffe097          	auipc	ra,0xffffe
    80006236:	f50080e7          	jalr	-176(ra) # 80004182 <iput>
  end_op();
    8000623a:	ffffe097          	auipc	ra,0xffffe
    8000623e:	7e8080e7          	jalr	2024(ra) # 80004a22 <end_op>
  p->cwd = ip;
    80006242:	16993023          	sd	s1,352(s2)
  return 0;
    80006246:	4501                	li	a0,0
}
    80006248:	60ea                	ld	ra,152(sp)
    8000624a:	644a                	ld	s0,144(sp)
    8000624c:	64aa                	ld	s1,136(sp)
    8000624e:	690a                	ld	s2,128(sp)
    80006250:	610d                	addi	sp,sp,160
    80006252:	8082                	ret
    end_op();
    80006254:	ffffe097          	auipc	ra,0xffffe
    80006258:	7ce080e7          	jalr	1998(ra) # 80004a22 <end_op>
    return -1;
    8000625c:	557d                	li	a0,-1
    8000625e:	b7ed                	j	80006248 <sys_chdir+0x7a>
    iunlockput(ip);
    80006260:	8526                	mv	a0,s1
    80006262:	ffffe097          	auipc	ra,0xffffe
    80006266:	fc8080e7          	jalr	-56(ra) # 8000422a <iunlockput>
    end_op();
    8000626a:	ffffe097          	auipc	ra,0xffffe
    8000626e:	7b8080e7          	jalr	1976(ra) # 80004a22 <end_op>
    return -1;
    80006272:	557d                	li	a0,-1
    80006274:	bfd1                	j	80006248 <sys_chdir+0x7a>

0000000080006276 <sys_exec>:

uint64
sys_exec(void)
{
    80006276:	7145                	addi	sp,sp,-464
    80006278:	e786                	sd	ra,456(sp)
    8000627a:	e3a2                	sd	s0,448(sp)
    8000627c:	ff26                	sd	s1,440(sp)
    8000627e:	fb4a                	sd	s2,432(sp)
    80006280:	f74e                	sd	s3,424(sp)
    80006282:	f352                	sd	s4,416(sp)
    80006284:	ef56                	sd	s5,408(sp)
    80006286:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006288:	08000613          	li	a2,128
    8000628c:	f4040593          	addi	a1,s0,-192
    80006290:	4501                	li	a0,0
    80006292:	ffffd097          	auipc	ra,0xffffd
    80006296:	074080e7          	jalr	116(ra) # 80003306 <argstr>
    return -1;
    8000629a:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    8000629c:	0c054b63          	bltz	a0,80006372 <sys_exec+0xfc>
    800062a0:	e3840593          	addi	a1,s0,-456
    800062a4:	4505                	li	a0,1
    800062a6:	ffffd097          	auipc	ra,0xffffd
    800062aa:	03e080e7          	jalr	62(ra) # 800032e4 <argaddr>
    800062ae:	0c054263          	bltz	a0,80006372 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    800062b2:	10000613          	li	a2,256
    800062b6:	4581                	li	a1,0
    800062b8:	e4040513          	addi	a0,s0,-448
    800062bc:	ffffb097          	auipc	ra,0xffffb
    800062c0:	a10080e7          	jalr	-1520(ra) # 80000ccc <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800062c4:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800062c8:	89a6                	mv	s3,s1
    800062ca:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800062cc:	02000a13          	li	s4,32
    800062d0:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800062d4:	00391513          	slli	a0,s2,0x3
    800062d8:	e3040593          	addi	a1,s0,-464
    800062dc:	e3843783          	ld	a5,-456(s0)
    800062e0:	953e                	add	a0,a0,a5
    800062e2:	ffffd097          	auipc	ra,0xffffd
    800062e6:	f46080e7          	jalr	-186(ra) # 80003228 <fetchaddr>
    800062ea:	02054a63          	bltz	a0,8000631e <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    800062ee:	e3043783          	ld	a5,-464(s0)
    800062f2:	c3b9                	beqz	a5,80006338 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800062f4:	ffffa097          	auipc	ra,0xffffa
    800062f8:	7ec080e7          	jalr	2028(ra) # 80000ae0 <kalloc>
    800062fc:	85aa                	mv	a1,a0
    800062fe:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006302:	cd11                	beqz	a0,8000631e <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006304:	6605                	lui	a2,0x1
    80006306:	e3043503          	ld	a0,-464(s0)
    8000630a:	ffffd097          	auipc	ra,0xffffd
    8000630e:	f70080e7          	jalr	-144(ra) # 8000327a <fetchstr>
    80006312:	00054663          	bltz	a0,8000631e <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80006316:	0905                	addi	s2,s2,1
    80006318:	09a1                	addi	s3,s3,8
    8000631a:	fb491be3          	bne	s2,s4,800062d0 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000631e:	f4040913          	addi	s2,s0,-192
    80006322:	6088                	ld	a0,0(s1)
    80006324:	c531                	beqz	a0,80006370 <sys_exec+0xfa>
    kfree(argv[i]);
    80006326:	ffffa097          	auipc	ra,0xffffa
    8000632a:	6bc080e7          	jalr	1724(ra) # 800009e2 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000632e:	04a1                	addi	s1,s1,8
    80006330:	ff2499e3          	bne	s1,s2,80006322 <sys_exec+0xac>
  return -1;
    80006334:	597d                	li	s2,-1
    80006336:	a835                	j	80006372 <sys_exec+0xfc>
      argv[i] = 0;
    80006338:	0a8e                	slli	s5,s5,0x3
    8000633a:	fc0a8793          	addi	a5,s5,-64 # ffffffffffffefc0 <end+0xffffffff7ffd8fc0>
    8000633e:	00878ab3          	add	s5,a5,s0
    80006342:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80006346:	e4040593          	addi	a1,s0,-448
    8000634a:	f4040513          	addi	a0,s0,-192
    8000634e:	fffff097          	auipc	ra,0xfffff
    80006352:	172080e7          	jalr	370(ra) # 800054c0 <exec>
    80006356:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006358:	f4040993          	addi	s3,s0,-192
    8000635c:	6088                	ld	a0,0(s1)
    8000635e:	c911                	beqz	a0,80006372 <sys_exec+0xfc>
    kfree(argv[i]);
    80006360:	ffffa097          	auipc	ra,0xffffa
    80006364:	682080e7          	jalr	1666(ra) # 800009e2 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006368:	04a1                	addi	s1,s1,8
    8000636a:	ff3499e3          	bne	s1,s3,8000635c <sys_exec+0xe6>
    8000636e:	a011                	j	80006372 <sys_exec+0xfc>
  return -1;
    80006370:	597d                	li	s2,-1
}
    80006372:	854a                	mv	a0,s2
    80006374:	60be                	ld	ra,456(sp)
    80006376:	641e                	ld	s0,448(sp)
    80006378:	74fa                	ld	s1,440(sp)
    8000637a:	795a                	ld	s2,432(sp)
    8000637c:	79ba                	ld	s3,424(sp)
    8000637e:	7a1a                	ld	s4,416(sp)
    80006380:	6afa                	ld	s5,408(sp)
    80006382:	6179                	addi	sp,sp,464
    80006384:	8082                	ret

0000000080006386 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006386:	7139                	addi	sp,sp,-64
    80006388:	fc06                	sd	ra,56(sp)
    8000638a:	f822                	sd	s0,48(sp)
    8000638c:	f426                	sd	s1,40(sp)
    8000638e:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006390:	ffffb097          	auipc	ra,0xffffb
    80006394:	68e080e7          	jalr	1678(ra) # 80001a1e <myproc>
    80006398:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    8000639a:	fd840593          	addi	a1,s0,-40
    8000639e:	4501                	li	a0,0
    800063a0:	ffffd097          	auipc	ra,0xffffd
    800063a4:	f44080e7          	jalr	-188(ra) # 800032e4 <argaddr>
    return -1;
    800063a8:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    800063aa:	0e054063          	bltz	a0,8000648a <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    800063ae:	fc840593          	addi	a1,s0,-56
    800063b2:	fd040513          	addi	a0,s0,-48
    800063b6:	fffff097          	auipc	ra,0xfffff
    800063ba:	de6080e7          	jalr	-538(ra) # 8000519c <pipealloc>
    return -1;
    800063be:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800063c0:	0c054563          	bltz	a0,8000648a <sys_pipe+0x104>
  fd0 = -1;
    800063c4:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800063c8:	fd043503          	ld	a0,-48(s0)
    800063cc:	fffff097          	auipc	ra,0xfffff
    800063d0:	504080e7          	jalr	1284(ra) # 800058d0 <fdalloc>
    800063d4:	fca42223          	sw	a0,-60(s0)
    800063d8:	08054c63          	bltz	a0,80006470 <sys_pipe+0xea>
    800063dc:	fc843503          	ld	a0,-56(s0)
    800063e0:	fffff097          	auipc	ra,0xfffff
    800063e4:	4f0080e7          	jalr	1264(ra) # 800058d0 <fdalloc>
    800063e8:	fca42023          	sw	a0,-64(s0)
    800063ec:	06054963          	bltz	a0,8000645e <sys_pipe+0xd8>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800063f0:	4691                	li	a3,4
    800063f2:	fc440613          	addi	a2,s0,-60
    800063f6:	fd843583          	ld	a1,-40(s0)
    800063fa:	70a8                	ld	a0,96(s1)
    800063fc:	ffffb097          	auipc	ra,0xffffb
    80006400:	266080e7          	jalr	614(ra) # 80001662 <copyout>
    80006404:	02054063          	bltz	a0,80006424 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006408:	4691                	li	a3,4
    8000640a:	fc040613          	addi	a2,s0,-64
    8000640e:	fd843583          	ld	a1,-40(s0)
    80006412:	0591                	addi	a1,a1,4
    80006414:	70a8                	ld	a0,96(s1)
    80006416:	ffffb097          	auipc	ra,0xffffb
    8000641a:	24c080e7          	jalr	588(ra) # 80001662 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000641e:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006420:	06055563          	bgez	a0,8000648a <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80006424:	fc442783          	lw	a5,-60(s0)
    80006428:	07f1                	addi	a5,a5,28
    8000642a:	078e                	slli	a5,a5,0x3
    8000642c:	97a6                	add	a5,a5,s1
    8000642e:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006432:	fc042783          	lw	a5,-64(s0)
    80006436:	07f1                	addi	a5,a5,28
    80006438:	078e                	slli	a5,a5,0x3
    8000643a:	00f48533          	add	a0,s1,a5
    8000643e:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006442:	fd043503          	ld	a0,-48(s0)
    80006446:	fffff097          	auipc	ra,0xfffff
    8000644a:	a26080e7          	jalr	-1498(ra) # 80004e6c <fileclose>
    fileclose(wf);
    8000644e:	fc843503          	ld	a0,-56(s0)
    80006452:	fffff097          	auipc	ra,0xfffff
    80006456:	a1a080e7          	jalr	-1510(ra) # 80004e6c <fileclose>
    return -1;
    8000645a:	57fd                	li	a5,-1
    8000645c:	a03d                	j	8000648a <sys_pipe+0x104>
    if(fd0 >= 0)
    8000645e:	fc442783          	lw	a5,-60(s0)
    80006462:	0007c763          	bltz	a5,80006470 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80006466:	07f1                	addi	a5,a5,28
    80006468:	078e                	slli	a5,a5,0x3
    8000646a:	97a6                	add	a5,a5,s1
    8000646c:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80006470:	fd043503          	ld	a0,-48(s0)
    80006474:	fffff097          	auipc	ra,0xfffff
    80006478:	9f8080e7          	jalr	-1544(ra) # 80004e6c <fileclose>
    fileclose(wf);
    8000647c:	fc843503          	ld	a0,-56(s0)
    80006480:	fffff097          	auipc	ra,0xfffff
    80006484:	9ec080e7          	jalr	-1556(ra) # 80004e6c <fileclose>
    return -1;
    80006488:	57fd                	li	a5,-1
}
    8000648a:	853e                	mv	a0,a5
    8000648c:	70e2                	ld	ra,56(sp)
    8000648e:	7442                	ld	s0,48(sp)
    80006490:	74a2                	ld	s1,40(sp)
    80006492:	6121                	addi	sp,sp,64
    80006494:	8082                	ret
	...

00000000800064a0 <kernelvec>:
    800064a0:	7111                	addi	sp,sp,-256
    800064a2:	e006                	sd	ra,0(sp)
    800064a4:	e40a                	sd	sp,8(sp)
    800064a6:	e80e                	sd	gp,16(sp)
    800064a8:	ec12                	sd	tp,24(sp)
    800064aa:	f016                	sd	t0,32(sp)
    800064ac:	f41a                	sd	t1,40(sp)
    800064ae:	f81e                	sd	t2,48(sp)
    800064b0:	fc22                	sd	s0,56(sp)
    800064b2:	e0a6                	sd	s1,64(sp)
    800064b4:	e4aa                	sd	a0,72(sp)
    800064b6:	e8ae                	sd	a1,80(sp)
    800064b8:	ecb2                	sd	a2,88(sp)
    800064ba:	f0b6                	sd	a3,96(sp)
    800064bc:	f4ba                	sd	a4,104(sp)
    800064be:	f8be                	sd	a5,112(sp)
    800064c0:	fcc2                	sd	a6,120(sp)
    800064c2:	e146                	sd	a7,128(sp)
    800064c4:	e54a                	sd	s2,136(sp)
    800064c6:	e94e                	sd	s3,144(sp)
    800064c8:	ed52                	sd	s4,152(sp)
    800064ca:	f156                	sd	s5,160(sp)
    800064cc:	f55a                	sd	s6,168(sp)
    800064ce:	f95e                	sd	s7,176(sp)
    800064d0:	fd62                	sd	s8,184(sp)
    800064d2:	e1e6                	sd	s9,192(sp)
    800064d4:	e5ea                	sd	s10,200(sp)
    800064d6:	e9ee                	sd	s11,208(sp)
    800064d8:	edf2                	sd	t3,216(sp)
    800064da:	f1f6                	sd	t4,224(sp)
    800064dc:	f5fa                	sd	t5,232(sp)
    800064de:	f9fe                	sd	t6,240(sp)
    800064e0:	c15fc0ef          	jal	ra,800030f4 <kerneltrap>
    800064e4:	6082                	ld	ra,0(sp)
    800064e6:	6122                	ld	sp,8(sp)
    800064e8:	61c2                	ld	gp,16(sp)
    800064ea:	7282                	ld	t0,32(sp)
    800064ec:	7322                	ld	t1,40(sp)
    800064ee:	73c2                	ld	t2,48(sp)
    800064f0:	7462                	ld	s0,56(sp)
    800064f2:	6486                	ld	s1,64(sp)
    800064f4:	6526                	ld	a0,72(sp)
    800064f6:	65c6                	ld	a1,80(sp)
    800064f8:	6666                	ld	a2,88(sp)
    800064fa:	7686                	ld	a3,96(sp)
    800064fc:	7726                	ld	a4,104(sp)
    800064fe:	77c6                	ld	a5,112(sp)
    80006500:	7866                	ld	a6,120(sp)
    80006502:	688a                	ld	a7,128(sp)
    80006504:	692a                	ld	s2,136(sp)
    80006506:	69ca                	ld	s3,144(sp)
    80006508:	6a6a                	ld	s4,152(sp)
    8000650a:	7a8a                	ld	s5,160(sp)
    8000650c:	7b2a                	ld	s6,168(sp)
    8000650e:	7bca                	ld	s7,176(sp)
    80006510:	7c6a                	ld	s8,184(sp)
    80006512:	6c8e                	ld	s9,192(sp)
    80006514:	6d2e                	ld	s10,200(sp)
    80006516:	6dce                	ld	s11,208(sp)
    80006518:	6e6e                	ld	t3,216(sp)
    8000651a:	7e8e                	ld	t4,224(sp)
    8000651c:	7f2e                	ld	t5,232(sp)
    8000651e:	7fce                	ld	t6,240(sp)
    80006520:	6111                	addi	sp,sp,256
    80006522:	10200073          	sret
    80006526:	00000013          	nop
    8000652a:	00000013          	nop
    8000652e:	0001                	nop

0000000080006530 <timervec>:
    80006530:	34051573          	csrrw	a0,mscratch,a0
    80006534:	e10c                	sd	a1,0(a0)
    80006536:	e510                	sd	a2,8(a0)
    80006538:	e914                	sd	a3,16(a0)
    8000653a:	6d0c                	ld	a1,24(a0)
    8000653c:	7110                	ld	a2,32(a0)
    8000653e:	6194                	ld	a3,0(a1)
    80006540:	96b2                	add	a3,a3,a2
    80006542:	e194                	sd	a3,0(a1)
    80006544:	4589                	li	a1,2
    80006546:	14459073          	csrw	sip,a1
    8000654a:	6914                	ld	a3,16(a0)
    8000654c:	6510                	ld	a2,8(a0)
    8000654e:	610c                	ld	a1,0(a0)
    80006550:	34051573          	csrrw	a0,mscratch,a0
    80006554:	30200073          	mret
	...

000000008000655a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000655a:	1141                	addi	sp,sp,-16
    8000655c:	e422                	sd	s0,8(sp)
    8000655e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006560:	0c0007b7          	lui	a5,0xc000
    80006564:	4705                	li	a4,1
    80006566:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006568:	c3d8                	sw	a4,4(a5)
}
    8000656a:	6422                	ld	s0,8(sp)
    8000656c:	0141                	addi	sp,sp,16
    8000656e:	8082                	ret

0000000080006570 <plicinithart>:

void
plicinithart(void)
{
    80006570:	1141                	addi	sp,sp,-16
    80006572:	e406                	sd	ra,8(sp)
    80006574:	e022                	sd	s0,0(sp)
    80006576:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006578:	ffffb097          	auipc	ra,0xffffb
    8000657c:	47a080e7          	jalr	1146(ra) # 800019f2 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006580:	0085171b          	slliw	a4,a0,0x8
    80006584:	0c0027b7          	lui	a5,0xc002
    80006588:	97ba                	add	a5,a5,a4
    8000658a:	40200713          	li	a4,1026
    8000658e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006592:	00d5151b          	slliw	a0,a0,0xd
    80006596:	0c2017b7          	lui	a5,0xc201
    8000659a:	97aa                	add	a5,a5,a0
    8000659c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800065a0:	60a2                	ld	ra,8(sp)
    800065a2:	6402                	ld	s0,0(sp)
    800065a4:	0141                	addi	sp,sp,16
    800065a6:	8082                	ret

00000000800065a8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800065a8:	1141                	addi	sp,sp,-16
    800065aa:	e406                	sd	ra,8(sp)
    800065ac:	e022                	sd	s0,0(sp)
    800065ae:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800065b0:	ffffb097          	auipc	ra,0xffffb
    800065b4:	442080e7          	jalr	1090(ra) # 800019f2 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800065b8:	00d5151b          	slliw	a0,a0,0xd
    800065bc:	0c2017b7          	lui	a5,0xc201
    800065c0:	97aa                	add	a5,a5,a0
  return irq;
}
    800065c2:	43c8                	lw	a0,4(a5)
    800065c4:	60a2                	ld	ra,8(sp)
    800065c6:	6402                	ld	s0,0(sp)
    800065c8:	0141                	addi	sp,sp,16
    800065ca:	8082                	ret

00000000800065cc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800065cc:	1101                	addi	sp,sp,-32
    800065ce:	ec06                	sd	ra,24(sp)
    800065d0:	e822                	sd	s0,16(sp)
    800065d2:	e426                	sd	s1,8(sp)
    800065d4:	1000                	addi	s0,sp,32
    800065d6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800065d8:	ffffb097          	auipc	ra,0xffffb
    800065dc:	41a080e7          	jalr	1050(ra) # 800019f2 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800065e0:	00d5151b          	slliw	a0,a0,0xd
    800065e4:	0c2017b7          	lui	a5,0xc201
    800065e8:	97aa                	add	a5,a5,a0
    800065ea:	c3c4                	sw	s1,4(a5)
}
    800065ec:	60e2                	ld	ra,24(sp)
    800065ee:	6442                	ld	s0,16(sp)
    800065f0:	64a2                	ld	s1,8(sp)
    800065f2:	6105                	addi	sp,sp,32
    800065f4:	8082                	ret

00000000800065f6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800065f6:	1141                	addi	sp,sp,-16
    800065f8:	e406                	sd	ra,8(sp)
    800065fa:	e022                	sd	s0,0(sp)
    800065fc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800065fe:	479d                	li	a5,7
    80006600:	06a7c863          	blt	a5,a0,80006670 <free_desc+0x7a>
    panic("free_desc 1");
  if(disk.free[i])
    80006604:	0001d717          	auipc	a4,0x1d
    80006608:	9fc70713          	addi	a4,a4,-1540 # 80023000 <disk>
    8000660c:	972a                	add	a4,a4,a0
    8000660e:	6789                	lui	a5,0x2
    80006610:	97ba                	add	a5,a5,a4
    80006612:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006616:	e7ad                	bnez	a5,80006680 <free_desc+0x8a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006618:	00451793          	slli	a5,a0,0x4
    8000661c:	0001f717          	auipc	a4,0x1f
    80006620:	9e470713          	addi	a4,a4,-1564 # 80025000 <disk+0x2000>
    80006624:	6314                	ld	a3,0(a4)
    80006626:	96be                	add	a3,a3,a5
    80006628:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    8000662c:	6314                	ld	a3,0(a4)
    8000662e:	96be                	add	a3,a3,a5
    80006630:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006634:	6314                	ld	a3,0(a4)
    80006636:	96be                	add	a3,a3,a5
    80006638:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    8000663c:	6318                	ld	a4,0(a4)
    8000663e:	97ba                	add	a5,a5,a4
    80006640:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006644:	0001d717          	auipc	a4,0x1d
    80006648:	9bc70713          	addi	a4,a4,-1604 # 80023000 <disk>
    8000664c:	972a                	add	a4,a4,a0
    8000664e:	6789                	lui	a5,0x2
    80006650:	97ba                	add	a5,a5,a4
    80006652:	4705                	li	a4,1
    80006654:	00e78c23          	sb	a4,24(a5) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80006658:	0001f517          	auipc	a0,0x1f
    8000665c:	9c050513          	addi	a0,a0,-1600 # 80025018 <disk+0x2018>
    80006660:	ffffc097          	auipc	ra,0xffffc
    80006664:	306080e7          	jalr	774(ra) # 80002966 <wakeup>
}
    80006668:	60a2                	ld	ra,8(sp)
    8000666a:	6402                	ld	s0,0(sp)
    8000666c:	0141                	addi	sp,sp,16
    8000666e:	8082                	ret
    panic("free_desc 1");
    80006670:	00002517          	auipc	a0,0x2
    80006674:	21050513          	addi	a0,a0,528 # 80008880 <syscalls+0x348>
    80006678:	ffffa097          	auipc	ra,0xffffa
    8000667c:	ec2080e7          	jalr	-318(ra) # 8000053a <panic>
    panic("free_desc 2");
    80006680:	00002517          	auipc	a0,0x2
    80006684:	21050513          	addi	a0,a0,528 # 80008890 <syscalls+0x358>
    80006688:	ffffa097          	auipc	ra,0xffffa
    8000668c:	eb2080e7          	jalr	-334(ra) # 8000053a <panic>

0000000080006690 <virtio_disk_init>:
{
    80006690:	1101                	addi	sp,sp,-32
    80006692:	ec06                	sd	ra,24(sp)
    80006694:	e822                	sd	s0,16(sp)
    80006696:	e426                	sd	s1,8(sp)
    80006698:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000669a:	00002597          	auipc	a1,0x2
    8000669e:	20658593          	addi	a1,a1,518 # 800088a0 <syscalls+0x368>
    800066a2:	0001f517          	auipc	a0,0x1f
    800066a6:	a8650513          	addi	a0,a0,-1402 # 80025128 <disk+0x2128>
    800066aa:	ffffa097          	auipc	ra,0xffffa
    800066ae:	496080e7          	jalr	1174(ra) # 80000b40 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800066b2:	100017b7          	lui	a5,0x10001
    800066b6:	4398                	lw	a4,0(a5)
    800066b8:	2701                	sext.w	a4,a4
    800066ba:	747277b7          	lui	a5,0x74727
    800066be:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800066c2:	0ef71063          	bne	a4,a5,800067a2 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800066c6:	100017b7          	lui	a5,0x10001
    800066ca:	43dc                	lw	a5,4(a5)
    800066cc:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800066ce:	4705                	li	a4,1
    800066d0:	0ce79963          	bne	a5,a4,800067a2 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800066d4:	100017b7          	lui	a5,0x10001
    800066d8:	479c                	lw	a5,8(a5)
    800066da:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800066dc:	4709                	li	a4,2
    800066de:	0ce79263          	bne	a5,a4,800067a2 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800066e2:	100017b7          	lui	a5,0x10001
    800066e6:	47d8                	lw	a4,12(a5)
    800066e8:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800066ea:	554d47b7          	lui	a5,0x554d4
    800066ee:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800066f2:	0af71863          	bne	a4,a5,800067a2 <virtio_disk_init+0x112>
  *R(VIRTIO_MMIO_STATUS) = status;
    800066f6:	100017b7          	lui	a5,0x10001
    800066fa:	4705                	li	a4,1
    800066fc:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800066fe:	470d                	li	a4,3
    80006700:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006702:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006704:	c7ffe6b7          	lui	a3,0xc7ffe
    80006708:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    8000670c:	8f75                	and	a4,a4,a3
    8000670e:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006710:	472d                	li	a4,11
    80006712:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006714:	473d                	li	a4,15
    80006716:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006718:	6705                	lui	a4,0x1
    8000671a:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000671c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006720:	5bdc                	lw	a5,52(a5)
    80006722:	2781                	sext.w	a5,a5
  if(max == 0)
    80006724:	c7d9                	beqz	a5,800067b2 <virtio_disk_init+0x122>
  if(max < NUM)
    80006726:	471d                	li	a4,7
    80006728:	08f77d63          	bgeu	a4,a5,800067c2 <virtio_disk_init+0x132>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000672c:	100014b7          	lui	s1,0x10001
    80006730:	47a1                	li	a5,8
    80006732:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006734:	6609                	lui	a2,0x2
    80006736:	4581                	li	a1,0
    80006738:	0001d517          	auipc	a0,0x1d
    8000673c:	8c850513          	addi	a0,a0,-1848 # 80023000 <disk>
    80006740:	ffffa097          	auipc	ra,0xffffa
    80006744:	58c080e7          	jalr	1420(ra) # 80000ccc <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006748:	0001d717          	auipc	a4,0x1d
    8000674c:	8b870713          	addi	a4,a4,-1864 # 80023000 <disk>
    80006750:	00c75793          	srli	a5,a4,0xc
    80006754:	2781                	sext.w	a5,a5
    80006756:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80006758:	0001f797          	auipc	a5,0x1f
    8000675c:	8a878793          	addi	a5,a5,-1880 # 80025000 <disk+0x2000>
    80006760:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006762:	0001d717          	auipc	a4,0x1d
    80006766:	91e70713          	addi	a4,a4,-1762 # 80023080 <disk+0x80>
    8000676a:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    8000676c:	0001e717          	auipc	a4,0x1e
    80006770:	89470713          	addi	a4,a4,-1900 # 80024000 <disk+0x1000>
    80006774:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80006776:	4705                	li	a4,1
    80006778:	00e78c23          	sb	a4,24(a5)
    8000677c:	00e78ca3          	sb	a4,25(a5)
    80006780:	00e78d23          	sb	a4,26(a5)
    80006784:	00e78da3          	sb	a4,27(a5)
    80006788:	00e78e23          	sb	a4,28(a5)
    8000678c:	00e78ea3          	sb	a4,29(a5)
    80006790:	00e78f23          	sb	a4,30(a5)
    80006794:	00e78fa3          	sb	a4,31(a5)
}
    80006798:	60e2                	ld	ra,24(sp)
    8000679a:	6442                	ld	s0,16(sp)
    8000679c:	64a2                	ld	s1,8(sp)
    8000679e:	6105                	addi	sp,sp,32
    800067a0:	8082                	ret
    panic("could not find virtio disk");
    800067a2:	00002517          	auipc	a0,0x2
    800067a6:	10e50513          	addi	a0,a0,270 # 800088b0 <syscalls+0x378>
    800067aa:	ffffa097          	auipc	ra,0xffffa
    800067ae:	d90080e7          	jalr	-624(ra) # 8000053a <panic>
    panic("virtio disk has no queue 0");
    800067b2:	00002517          	auipc	a0,0x2
    800067b6:	11e50513          	addi	a0,a0,286 # 800088d0 <syscalls+0x398>
    800067ba:	ffffa097          	auipc	ra,0xffffa
    800067be:	d80080e7          	jalr	-640(ra) # 8000053a <panic>
    panic("virtio disk max queue too short");
    800067c2:	00002517          	auipc	a0,0x2
    800067c6:	12e50513          	addi	a0,a0,302 # 800088f0 <syscalls+0x3b8>
    800067ca:	ffffa097          	auipc	ra,0xffffa
    800067ce:	d70080e7          	jalr	-656(ra) # 8000053a <panic>

00000000800067d2 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800067d2:	7119                	addi	sp,sp,-128
    800067d4:	fc86                	sd	ra,120(sp)
    800067d6:	f8a2                	sd	s0,112(sp)
    800067d8:	f4a6                	sd	s1,104(sp)
    800067da:	f0ca                	sd	s2,96(sp)
    800067dc:	ecce                	sd	s3,88(sp)
    800067de:	e8d2                	sd	s4,80(sp)
    800067e0:	e4d6                	sd	s5,72(sp)
    800067e2:	e0da                	sd	s6,64(sp)
    800067e4:	fc5e                	sd	s7,56(sp)
    800067e6:	f862                	sd	s8,48(sp)
    800067e8:	f466                	sd	s9,40(sp)
    800067ea:	f06a                	sd	s10,32(sp)
    800067ec:	ec6e                	sd	s11,24(sp)
    800067ee:	0100                	addi	s0,sp,128
    800067f0:	8aaa                	mv	s5,a0
    800067f2:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800067f4:	00c52c83          	lw	s9,12(a0)
    800067f8:	001c9c9b          	slliw	s9,s9,0x1
    800067fc:	1c82                	slli	s9,s9,0x20
    800067fe:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006802:	0001f517          	auipc	a0,0x1f
    80006806:	92650513          	addi	a0,a0,-1754 # 80025128 <disk+0x2128>
    8000680a:	ffffa097          	auipc	ra,0xffffa
    8000680e:	3c6080e7          	jalr	966(ra) # 80000bd0 <acquire>
  for(int i = 0; i < 3; i++){
    80006812:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006814:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006816:	0001cc17          	auipc	s8,0x1c
    8000681a:	7eac0c13          	addi	s8,s8,2026 # 80023000 <disk>
    8000681e:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80006820:	4b0d                	li	s6,3
    80006822:	a0ad                	j	8000688c <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80006824:	00fc0733          	add	a4,s8,a5
    80006828:	975e                	add	a4,a4,s7
    8000682a:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    8000682e:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006830:	0207c563          	bltz	a5,8000685a <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006834:	2905                	addiw	s2,s2,1
    80006836:	0611                	addi	a2,a2,4
    80006838:	19690c63          	beq	s2,s6,800069d0 <virtio_disk_rw+0x1fe>
    idx[i] = alloc_desc();
    8000683c:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    8000683e:	0001e717          	auipc	a4,0x1e
    80006842:	7da70713          	addi	a4,a4,2010 # 80025018 <disk+0x2018>
    80006846:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006848:	00074683          	lbu	a3,0(a4)
    8000684c:	fee1                	bnez	a3,80006824 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    8000684e:	2785                	addiw	a5,a5,1
    80006850:	0705                	addi	a4,a4,1
    80006852:	fe979be3          	bne	a5,s1,80006848 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006856:	57fd                	li	a5,-1
    80006858:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000685a:	01205d63          	blez	s2,80006874 <virtio_disk_rw+0xa2>
    8000685e:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006860:	000a2503          	lw	a0,0(s4)
    80006864:	00000097          	auipc	ra,0x0
    80006868:	d92080e7          	jalr	-622(ra) # 800065f6 <free_desc>
      for(int j = 0; j < i; j++)
    8000686c:	2d85                	addiw	s11,s11,1
    8000686e:	0a11                	addi	s4,s4,4
    80006870:	ff2d98e3          	bne	s11,s2,80006860 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006874:	0001f597          	auipc	a1,0x1f
    80006878:	8b458593          	addi	a1,a1,-1868 # 80025128 <disk+0x2128>
    8000687c:	0001e517          	auipc	a0,0x1e
    80006880:	79c50513          	addi	a0,a0,1948 # 80025018 <disk+0x2018>
    80006884:	ffffc097          	auipc	ra,0xffffc
    80006888:	bfa080e7          	jalr	-1030(ra) # 8000247e <sleep>
  for(int i = 0; i < 3; i++){
    8000688c:	f8040a13          	addi	s4,s0,-128
{
    80006890:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006892:	894e                	mv	s2,s3
    80006894:	b765                	j	8000683c <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006896:	0001e697          	auipc	a3,0x1e
    8000689a:	76a6b683          	ld	a3,1898(a3) # 80025000 <disk+0x2000>
    8000689e:	96ba                	add	a3,a3,a4
    800068a0:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800068a4:	0001c817          	auipc	a6,0x1c
    800068a8:	75c80813          	addi	a6,a6,1884 # 80023000 <disk>
    800068ac:	0001e697          	auipc	a3,0x1e
    800068b0:	75468693          	addi	a3,a3,1876 # 80025000 <disk+0x2000>
    800068b4:	6290                	ld	a2,0(a3)
    800068b6:	963a                	add	a2,a2,a4
    800068b8:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    800068bc:	0015e593          	ori	a1,a1,1
    800068c0:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    800068c4:	f8842603          	lw	a2,-120(s0)
    800068c8:	628c                	ld	a1,0(a3)
    800068ca:	972e                	add	a4,a4,a1
    800068cc:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800068d0:	20050593          	addi	a1,a0,512
    800068d4:	0592                	slli	a1,a1,0x4
    800068d6:	95c2                	add	a1,a1,a6
    800068d8:	577d                	li	a4,-1
    800068da:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800068de:	00461713          	slli	a4,a2,0x4
    800068e2:	6290                	ld	a2,0(a3)
    800068e4:	963a                	add	a2,a2,a4
    800068e6:	03078793          	addi	a5,a5,48
    800068ea:	97c2                	add	a5,a5,a6
    800068ec:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    800068ee:	629c                	ld	a5,0(a3)
    800068f0:	97ba                	add	a5,a5,a4
    800068f2:	4605                	li	a2,1
    800068f4:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800068f6:	629c                	ld	a5,0(a3)
    800068f8:	97ba                	add	a5,a5,a4
    800068fa:	4809                	li	a6,2
    800068fc:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80006900:	629c                	ld	a5,0(a3)
    80006902:	97ba                	add	a5,a5,a4
    80006904:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006908:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    8000690c:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006910:	6698                	ld	a4,8(a3)
    80006912:	00275783          	lhu	a5,2(a4)
    80006916:	8b9d                	andi	a5,a5,7
    80006918:	0786                	slli	a5,a5,0x1
    8000691a:	973e                	add	a4,a4,a5
    8000691c:	00a71223          	sh	a0,4(a4)

  __sync_synchronize();
    80006920:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006924:	6698                	ld	a4,8(a3)
    80006926:	00275783          	lhu	a5,2(a4)
    8000692a:	2785                	addiw	a5,a5,1
    8000692c:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006930:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006934:	100017b7          	lui	a5,0x10001
    80006938:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000693c:	004aa783          	lw	a5,4(s5)
    80006940:	02c79163          	bne	a5,a2,80006962 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80006944:	0001e917          	auipc	s2,0x1e
    80006948:	7e490913          	addi	s2,s2,2020 # 80025128 <disk+0x2128>
  while(b->disk == 1) {
    8000694c:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    8000694e:	85ca                	mv	a1,s2
    80006950:	8556                	mv	a0,s5
    80006952:	ffffc097          	auipc	ra,0xffffc
    80006956:	b2c080e7          	jalr	-1236(ra) # 8000247e <sleep>
  while(b->disk == 1) {
    8000695a:	004aa783          	lw	a5,4(s5)
    8000695e:	fe9788e3          	beq	a5,s1,8000694e <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80006962:	f8042903          	lw	s2,-128(s0)
    80006966:	20090713          	addi	a4,s2,512
    8000696a:	0712                	slli	a4,a4,0x4
    8000696c:	0001c797          	auipc	a5,0x1c
    80006970:	69478793          	addi	a5,a5,1684 # 80023000 <disk>
    80006974:	97ba                	add	a5,a5,a4
    80006976:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    8000697a:	0001e997          	auipc	s3,0x1e
    8000697e:	68698993          	addi	s3,s3,1670 # 80025000 <disk+0x2000>
    80006982:	00491713          	slli	a4,s2,0x4
    80006986:	0009b783          	ld	a5,0(s3)
    8000698a:	97ba                	add	a5,a5,a4
    8000698c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006990:	854a                	mv	a0,s2
    80006992:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006996:	00000097          	auipc	ra,0x0
    8000699a:	c60080e7          	jalr	-928(ra) # 800065f6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000699e:	8885                	andi	s1,s1,1
    800069a0:	f0ed                	bnez	s1,80006982 <virtio_disk_rw+0x1b0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800069a2:	0001e517          	auipc	a0,0x1e
    800069a6:	78650513          	addi	a0,a0,1926 # 80025128 <disk+0x2128>
    800069aa:	ffffa097          	auipc	ra,0xffffa
    800069ae:	2da080e7          	jalr	730(ra) # 80000c84 <release>
}
    800069b2:	70e6                	ld	ra,120(sp)
    800069b4:	7446                	ld	s0,112(sp)
    800069b6:	74a6                	ld	s1,104(sp)
    800069b8:	7906                	ld	s2,96(sp)
    800069ba:	69e6                	ld	s3,88(sp)
    800069bc:	6a46                	ld	s4,80(sp)
    800069be:	6aa6                	ld	s5,72(sp)
    800069c0:	6b06                	ld	s6,64(sp)
    800069c2:	7be2                	ld	s7,56(sp)
    800069c4:	7c42                	ld	s8,48(sp)
    800069c6:	7ca2                	ld	s9,40(sp)
    800069c8:	7d02                	ld	s10,32(sp)
    800069ca:	6de2                	ld	s11,24(sp)
    800069cc:	6109                	addi	sp,sp,128
    800069ce:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800069d0:	f8042503          	lw	a0,-128(s0)
    800069d4:	20050793          	addi	a5,a0,512
    800069d8:	0792                	slli	a5,a5,0x4
  if(write)
    800069da:	0001c817          	auipc	a6,0x1c
    800069de:	62680813          	addi	a6,a6,1574 # 80023000 <disk>
    800069e2:	00f80733          	add	a4,a6,a5
    800069e6:	01a036b3          	snez	a3,s10
    800069ea:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    800069ee:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    800069f2:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    800069f6:	7679                	lui	a2,0xffffe
    800069f8:	963e                	add	a2,a2,a5
    800069fa:	0001e697          	auipc	a3,0x1e
    800069fe:	60668693          	addi	a3,a3,1542 # 80025000 <disk+0x2000>
    80006a02:	6298                	ld	a4,0(a3)
    80006a04:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006a06:	0a878593          	addi	a1,a5,168
    80006a0a:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006a0c:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006a0e:	6298                	ld	a4,0(a3)
    80006a10:	9732                	add	a4,a4,a2
    80006a12:	45c1                	li	a1,16
    80006a14:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006a16:	6298                	ld	a4,0(a3)
    80006a18:	9732                	add	a4,a4,a2
    80006a1a:	4585                	li	a1,1
    80006a1c:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80006a20:	f8442703          	lw	a4,-124(s0)
    80006a24:	628c                	ld	a1,0(a3)
    80006a26:	962e                	add	a2,a2,a1
    80006a28:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd800e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    80006a2c:	0712                	slli	a4,a4,0x4
    80006a2e:	6290                	ld	a2,0(a3)
    80006a30:	963a                	add	a2,a2,a4
    80006a32:	058a8593          	addi	a1,s5,88
    80006a36:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006a38:	6294                	ld	a3,0(a3)
    80006a3a:	96ba                	add	a3,a3,a4
    80006a3c:	40000613          	li	a2,1024
    80006a40:	c690                	sw	a2,8(a3)
  if(write)
    80006a42:	e40d1ae3          	bnez	s10,80006896 <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006a46:	0001e697          	auipc	a3,0x1e
    80006a4a:	5ba6b683          	ld	a3,1466(a3) # 80025000 <disk+0x2000>
    80006a4e:	96ba                	add	a3,a3,a4
    80006a50:	4609                	li	a2,2
    80006a52:	00c69623          	sh	a2,12(a3)
    80006a56:	b5b9                	j	800068a4 <virtio_disk_rw+0xd2>

0000000080006a58 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006a58:	1101                	addi	sp,sp,-32
    80006a5a:	ec06                	sd	ra,24(sp)
    80006a5c:	e822                	sd	s0,16(sp)
    80006a5e:	e426                	sd	s1,8(sp)
    80006a60:	e04a                	sd	s2,0(sp)
    80006a62:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006a64:	0001e517          	auipc	a0,0x1e
    80006a68:	6c450513          	addi	a0,a0,1732 # 80025128 <disk+0x2128>
    80006a6c:	ffffa097          	auipc	ra,0xffffa
    80006a70:	164080e7          	jalr	356(ra) # 80000bd0 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006a74:	10001737          	lui	a4,0x10001
    80006a78:	533c                	lw	a5,96(a4)
    80006a7a:	8b8d                	andi	a5,a5,3
    80006a7c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006a7e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006a82:	0001e797          	auipc	a5,0x1e
    80006a86:	57e78793          	addi	a5,a5,1406 # 80025000 <disk+0x2000>
    80006a8a:	6b94                	ld	a3,16(a5)
    80006a8c:	0207d703          	lhu	a4,32(a5)
    80006a90:	0026d783          	lhu	a5,2(a3)
    80006a94:	06f70163          	beq	a4,a5,80006af6 <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006a98:	0001c917          	auipc	s2,0x1c
    80006a9c:	56890913          	addi	s2,s2,1384 # 80023000 <disk>
    80006aa0:	0001e497          	auipc	s1,0x1e
    80006aa4:	56048493          	addi	s1,s1,1376 # 80025000 <disk+0x2000>
    __sync_synchronize();
    80006aa8:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006aac:	6898                	ld	a4,16(s1)
    80006aae:	0204d783          	lhu	a5,32(s1)
    80006ab2:	8b9d                	andi	a5,a5,7
    80006ab4:	078e                	slli	a5,a5,0x3
    80006ab6:	97ba                	add	a5,a5,a4
    80006ab8:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006aba:	20078713          	addi	a4,a5,512
    80006abe:	0712                	slli	a4,a4,0x4
    80006ac0:	974a                	add	a4,a4,s2
    80006ac2:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    80006ac6:	e731                	bnez	a4,80006b12 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006ac8:	20078793          	addi	a5,a5,512
    80006acc:	0792                	slli	a5,a5,0x4
    80006ace:	97ca                	add	a5,a5,s2
    80006ad0:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80006ad2:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006ad6:	ffffc097          	auipc	ra,0xffffc
    80006ada:	e90080e7          	jalr	-368(ra) # 80002966 <wakeup>

    disk.used_idx += 1;
    80006ade:	0204d783          	lhu	a5,32(s1)
    80006ae2:	2785                	addiw	a5,a5,1
    80006ae4:	17c2                	slli	a5,a5,0x30
    80006ae6:	93c1                	srli	a5,a5,0x30
    80006ae8:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006aec:	6898                	ld	a4,16(s1)
    80006aee:	00275703          	lhu	a4,2(a4)
    80006af2:	faf71be3          	bne	a4,a5,80006aa8 <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    80006af6:	0001e517          	auipc	a0,0x1e
    80006afa:	63250513          	addi	a0,a0,1586 # 80025128 <disk+0x2128>
    80006afe:	ffffa097          	auipc	ra,0xffffa
    80006b02:	186080e7          	jalr	390(ra) # 80000c84 <release>
}
    80006b06:	60e2                	ld	ra,24(sp)
    80006b08:	6442                	ld	s0,16(sp)
    80006b0a:	64a2                	ld	s1,8(sp)
    80006b0c:	6902                	ld	s2,0(sp)
    80006b0e:	6105                	addi	sp,sp,32
    80006b10:	8082                	ret
      panic("virtio_disk_intr status");
    80006b12:	00002517          	auipc	a0,0x2
    80006b16:	dfe50513          	addi	a0,a0,-514 # 80008910 <syscalls+0x3d8>
    80006b1a:	ffffa097          	auipc	ra,0xffffa
    80006b1e:	a20080e7          	jalr	-1504(ra) # 8000053a <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
