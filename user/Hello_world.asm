
user/_Hello_world:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"
int main(int argc, char *argv[]) {
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
printf("Hello world!\n");
   8:	00000517          	auipc	a0,0x0
   c:	7c850513          	addi	a0,a0,1992 # 7d0 <malloc+0xe8>
  10:	00000097          	auipc	ra,0x0
  14:	620080e7          	jalr	1568(ra) # 630 <printf>
exit(0);
  18:	4501                	li	a0,0
  1a:	00000097          	auipc	ra,0x0
  1e:	274080e7          	jalr	628(ra) # 28e <exit>

0000000000000022 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  22:	1141                	addi	sp,sp,-16
  24:	e422                	sd	s0,8(sp)
  26:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  28:	87aa                	mv	a5,a0
  2a:	0585                	addi	a1,a1,1
  2c:	0785                	addi	a5,a5,1
  2e:	fff5c703          	lbu	a4,-1(a1)
  32:	fee78fa3          	sb	a4,-1(a5)
  36:	fb75                	bnez	a4,2a <strcpy+0x8>
    ;
  return os;
}
  38:	6422                	ld	s0,8(sp)
  3a:	0141                	addi	sp,sp,16
  3c:	8082                	ret

000000000000003e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  3e:	1141                	addi	sp,sp,-16
  40:	e422                	sd	s0,8(sp)
  42:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  44:	00054783          	lbu	a5,0(a0)
  48:	cb91                	beqz	a5,5c <strcmp+0x1e>
  4a:	0005c703          	lbu	a4,0(a1)
  4e:	00f71763          	bne	a4,a5,5c <strcmp+0x1e>
    p++, q++;
  52:	0505                	addi	a0,a0,1
  54:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  56:	00054783          	lbu	a5,0(a0)
  5a:	fbe5                	bnez	a5,4a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  5c:	0005c503          	lbu	a0,0(a1)
}
  60:	40a7853b          	subw	a0,a5,a0
  64:	6422                	ld	s0,8(sp)
  66:	0141                	addi	sp,sp,16
  68:	8082                	ret

000000000000006a <strlen>:

uint
strlen(const char *s)
{
  6a:	1141                	addi	sp,sp,-16
  6c:	e422                	sd	s0,8(sp)
  6e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  70:	00054783          	lbu	a5,0(a0)
  74:	cf91                	beqz	a5,90 <strlen+0x26>
  76:	0505                	addi	a0,a0,1
  78:	87aa                	mv	a5,a0
  7a:	4685                	li	a3,1
  7c:	9e89                	subw	a3,a3,a0
  7e:	00f6853b          	addw	a0,a3,a5
  82:	0785                	addi	a5,a5,1
  84:	fff7c703          	lbu	a4,-1(a5)
  88:	fb7d                	bnez	a4,7e <strlen+0x14>
    ;
  return n;
}
  8a:	6422                	ld	s0,8(sp)
  8c:	0141                	addi	sp,sp,16
  8e:	8082                	ret
  for(n = 0; s[n]; n++)
  90:	4501                	li	a0,0
  92:	bfe5                	j	8a <strlen+0x20>

0000000000000094 <memset>:

void*
memset(void *dst, int c, uint n)
{
  94:	1141                	addi	sp,sp,-16
  96:	e422                	sd	s0,8(sp)
  98:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  9a:	ca19                	beqz	a2,b0 <memset+0x1c>
  9c:	87aa                	mv	a5,a0
  9e:	1602                	slli	a2,a2,0x20
  a0:	9201                	srli	a2,a2,0x20
  a2:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  a6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  aa:	0785                	addi	a5,a5,1
  ac:	fee79de3          	bne	a5,a4,a6 <memset+0x12>
  }
  return dst;
}
  b0:	6422                	ld	s0,8(sp)
  b2:	0141                	addi	sp,sp,16
  b4:	8082                	ret

00000000000000b6 <strchr>:

char*
strchr(const char *s, char c)
{
  b6:	1141                	addi	sp,sp,-16
  b8:	e422                	sd	s0,8(sp)
  ba:	0800                	addi	s0,sp,16
  for(; *s; s++)
  bc:	00054783          	lbu	a5,0(a0)
  c0:	cb99                	beqz	a5,d6 <strchr+0x20>
    if(*s == c)
  c2:	00f58763          	beq	a1,a5,d0 <strchr+0x1a>
  for(; *s; s++)
  c6:	0505                	addi	a0,a0,1
  c8:	00054783          	lbu	a5,0(a0)
  cc:	fbfd                	bnez	a5,c2 <strchr+0xc>
      return (char*)s;
  return 0;
  ce:	4501                	li	a0,0
}
  d0:	6422                	ld	s0,8(sp)
  d2:	0141                	addi	sp,sp,16
  d4:	8082                	ret
  return 0;
  d6:	4501                	li	a0,0
  d8:	bfe5                	j	d0 <strchr+0x1a>

00000000000000da <gets>:

char*
gets(char *buf, int max)
{
  da:	711d                	addi	sp,sp,-96
  dc:	ec86                	sd	ra,88(sp)
  de:	e8a2                	sd	s0,80(sp)
  e0:	e4a6                	sd	s1,72(sp)
  e2:	e0ca                	sd	s2,64(sp)
  e4:	fc4e                	sd	s3,56(sp)
  e6:	f852                	sd	s4,48(sp)
  e8:	f456                	sd	s5,40(sp)
  ea:	f05a                	sd	s6,32(sp)
  ec:	ec5e                	sd	s7,24(sp)
  ee:	1080                	addi	s0,sp,96
  f0:	8baa                	mv	s7,a0
  f2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
  f4:	892a                	mv	s2,a0
  f6:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
  f8:	4aa9                	li	s5,10
  fa:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
  fc:	89a6                	mv	s3,s1
  fe:	2485                	addiw	s1,s1,1
 100:	0344d863          	bge	s1,s4,130 <gets+0x56>
    cc = read(0, &c, 1);
 104:	4605                	li	a2,1
 106:	faf40593          	addi	a1,s0,-81
 10a:	4501                	li	a0,0
 10c:	00000097          	auipc	ra,0x0
 110:	19a080e7          	jalr	410(ra) # 2a6 <read>
    if(cc < 1)
 114:	00a05e63          	blez	a0,130 <gets+0x56>
    buf[i++] = c;
 118:	faf44783          	lbu	a5,-81(s0)
 11c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 120:	01578763          	beq	a5,s5,12e <gets+0x54>
 124:	0905                	addi	s2,s2,1
 126:	fd679be3          	bne	a5,s6,fc <gets+0x22>
  for(i=0; i+1 < max; ){
 12a:	89a6                	mv	s3,s1
 12c:	a011                	j	130 <gets+0x56>
 12e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 130:	99de                	add	s3,s3,s7
 132:	00098023          	sb	zero,0(s3)
  return buf;
}
 136:	855e                	mv	a0,s7
 138:	60e6                	ld	ra,88(sp)
 13a:	6446                	ld	s0,80(sp)
 13c:	64a6                	ld	s1,72(sp)
 13e:	6906                	ld	s2,64(sp)
 140:	79e2                	ld	s3,56(sp)
 142:	7a42                	ld	s4,48(sp)
 144:	7aa2                	ld	s5,40(sp)
 146:	7b02                	ld	s6,32(sp)
 148:	6be2                	ld	s7,24(sp)
 14a:	6125                	addi	sp,sp,96
 14c:	8082                	ret

000000000000014e <stat>:

int
stat(const char *n, struct stat *st)
{
 14e:	1101                	addi	sp,sp,-32
 150:	ec06                	sd	ra,24(sp)
 152:	e822                	sd	s0,16(sp)
 154:	e426                	sd	s1,8(sp)
 156:	e04a                	sd	s2,0(sp)
 158:	1000                	addi	s0,sp,32
 15a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 15c:	4581                	li	a1,0
 15e:	00000097          	auipc	ra,0x0
 162:	170080e7          	jalr	368(ra) # 2ce <open>
  if(fd < 0)
 166:	02054563          	bltz	a0,190 <stat+0x42>
 16a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 16c:	85ca                	mv	a1,s2
 16e:	00000097          	auipc	ra,0x0
 172:	178080e7          	jalr	376(ra) # 2e6 <fstat>
 176:	892a                	mv	s2,a0
  close(fd);
 178:	8526                	mv	a0,s1
 17a:	00000097          	auipc	ra,0x0
 17e:	13c080e7          	jalr	316(ra) # 2b6 <close>
  return r;
}
 182:	854a                	mv	a0,s2
 184:	60e2                	ld	ra,24(sp)
 186:	6442                	ld	s0,16(sp)
 188:	64a2                	ld	s1,8(sp)
 18a:	6902                	ld	s2,0(sp)
 18c:	6105                	addi	sp,sp,32
 18e:	8082                	ret
    return -1;
 190:	597d                	li	s2,-1
 192:	bfc5                	j	182 <stat+0x34>

0000000000000194 <atoi>:

int
atoi(const char *s)
{
 194:	1141                	addi	sp,sp,-16
 196:	e422                	sd	s0,8(sp)
 198:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 19a:	00054683          	lbu	a3,0(a0)
 19e:	fd06879b          	addiw	a5,a3,-48
 1a2:	0ff7f793          	zext.b	a5,a5
 1a6:	4625                	li	a2,9
 1a8:	02f66863          	bltu	a2,a5,1d8 <atoi+0x44>
 1ac:	872a                	mv	a4,a0
  n = 0;
 1ae:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1b0:	0705                	addi	a4,a4,1
 1b2:	0025179b          	slliw	a5,a0,0x2
 1b6:	9fa9                	addw	a5,a5,a0
 1b8:	0017979b          	slliw	a5,a5,0x1
 1bc:	9fb5                	addw	a5,a5,a3
 1be:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1c2:	00074683          	lbu	a3,0(a4)
 1c6:	fd06879b          	addiw	a5,a3,-48
 1ca:	0ff7f793          	zext.b	a5,a5
 1ce:	fef671e3          	bgeu	a2,a5,1b0 <atoi+0x1c>
  return n;
}
 1d2:	6422                	ld	s0,8(sp)
 1d4:	0141                	addi	sp,sp,16
 1d6:	8082                	ret
  n = 0;
 1d8:	4501                	li	a0,0
 1da:	bfe5                	j	1d2 <atoi+0x3e>

00000000000001dc <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1dc:	1141                	addi	sp,sp,-16
 1de:	e422                	sd	s0,8(sp)
 1e0:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1e2:	02b57463          	bgeu	a0,a1,20a <memmove+0x2e>
    while(n-- > 0)
 1e6:	00c05f63          	blez	a2,204 <memmove+0x28>
 1ea:	1602                	slli	a2,a2,0x20
 1ec:	9201                	srli	a2,a2,0x20
 1ee:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 1f2:	872a                	mv	a4,a0
      *dst++ = *src++;
 1f4:	0585                	addi	a1,a1,1
 1f6:	0705                	addi	a4,a4,1
 1f8:	fff5c683          	lbu	a3,-1(a1)
 1fc:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 200:	fee79ae3          	bne	a5,a4,1f4 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 204:	6422                	ld	s0,8(sp)
 206:	0141                	addi	sp,sp,16
 208:	8082                	ret
    dst += n;
 20a:	00c50733          	add	a4,a0,a2
    src += n;
 20e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 210:	fec05ae3          	blez	a2,204 <memmove+0x28>
 214:	fff6079b          	addiw	a5,a2,-1
 218:	1782                	slli	a5,a5,0x20
 21a:	9381                	srli	a5,a5,0x20
 21c:	fff7c793          	not	a5,a5
 220:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 222:	15fd                	addi	a1,a1,-1
 224:	177d                	addi	a4,a4,-1
 226:	0005c683          	lbu	a3,0(a1)
 22a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 22e:	fee79ae3          	bne	a5,a4,222 <memmove+0x46>
 232:	bfc9                	j	204 <memmove+0x28>

0000000000000234 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 234:	1141                	addi	sp,sp,-16
 236:	e422                	sd	s0,8(sp)
 238:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 23a:	ca05                	beqz	a2,26a <memcmp+0x36>
 23c:	fff6069b          	addiw	a3,a2,-1
 240:	1682                	slli	a3,a3,0x20
 242:	9281                	srli	a3,a3,0x20
 244:	0685                	addi	a3,a3,1
 246:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 248:	00054783          	lbu	a5,0(a0)
 24c:	0005c703          	lbu	a4,0(a1)
 250:	00e79863          	bne	a5,a4,260 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 254:	0505                	addi	a0,a0,1
    p2++;
 256:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 258:	fed518e3          	bne	a0,a3,248 <memcmp+0x14>
  }
  return 0;
 25c:	4501                	li	a0,0
 25e:	a019                	j	264 <memcmp+0x30>
      return *p1 - *p2;
 260:	40e7853b          	subw	a0,a5,a4
}
 264:	6422                	ld	s0,8(sp)
 266:	0141                	addi	sp,sp,16
 268:	8082                	ret
  return 0;
 26a:	4501                	li	a0,0
 26c:	bfe5                	j	264 <memcmp+0x30>

000000000000026e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 26e:	1141                	addi	sp,sp,-16
 270:	e406                	sd	ra,8(sp)
 272:	e022                	sd	s0,0(sp)
 274:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 276:	00000097          	auipc	ra,0x0
 27a:	f66080e7          	jalr	-154(ra) # 1dc <memmove>
}
 27e:	60a2                	ld	ra,8(sp)
 280:	6402                	ld	s0,0(sp)
 282:	0141                	addi	sp,sp,16
 284:	8082                	ret

0000000000000286 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 286:	4885                	li	a7,1
 ecall
 288:	00000073          	ecall
 ret
 28c:	8082                	ret

000000000000028e <exit>:
.global exit
exit:
 li a7, SYS_exit
 28e:	4889                	li	a7,2
 ecall
 290:	00000073          	ecall
 ret
 294:	8082                	ret

0000000000000296 <wait>:
.global wait
wait:
 li a7, SYS_wait
 296:	488d                	li	a7,3
 ecall
 298:	00000073          	ecall
 ret
 29c:	8082                	ret

000000000000029e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 29e:	4891                	li	a7,4
 ecall
 2a0:	00000073          	ecall
 ret
 2a4:	8082                	ret

00000000000002a6 <read>:
.global read
read:
 li a7, SYS_read
 2a6:	4895                	li	a7,5
 ecall
 2a8:	00000073          	ecall
 ret
 2ac:	8082                	ret

00000000000002ae <write>:
.global write
write:
 li a7, SYS_write
 2ae:	48c1                	li	a7,16
 ecall
 2b0:	00000073          	ecall
 ret
 2b4:	8082                	ret

00000000000002b6 <close>:
.global close
close:
 li a7, SYS_close
 2b6:	48d5                	li	a7,21
 ecall
 2b8:	00000073          	ecall
 ret
 2bc:	8082                	ret

00000000000002be <kill>:
.global kill
kill:
 li a7, SYS_kill
 2be:	4899                	li	a7,6
 ecall
 2c0:	00000073          	ecall
 ret
 2c4:	8082                	ret

00000000000002c6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 2c6:	489d                	li	a7,7
 ecall
 2c8:	00000073          	ecall
 ret
 2cc:	8082                	ret

00000000000002ce <open>:
.global open
open:
 li a7, SYS_open
 2ce:	48bd                	li	a7,15
 ecall
 2d0:	00000073          	ecall
 ret
 2d4:	8082                	ret

00000000000002d6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2d6:	48c5                	li	a7,17
 ecall
 2d8:	00000073          	ecall
 ret
 2dc:	8082                	ret

00000000000002de <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 2de:	48c9                	li	a7,18
 ecall
 2e0:	00000073          	ecall
 ret
 2e4:	8082                	ret

00000000000002e6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 2e6:	48a1                	li	a7,8
 ecall
 2e8:	00000073          	ecall
 ret
 2ec:	8082                	ret

00000000000002ee <link>:
.global link
link:
 li a7, SYS_link
 2ee:	48cd                	li	a7,19
 ecall
 2f0:	00000073          	ecall
 ret
 2f4:	8082                	ret

00000000000002f6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 2f6:	48d1                	li	a7,20
 ecall
 2f8:	00000073          	ecall
 ret
 2fc:	8082                	ret

00000000000002fe <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 2fe:	48a5                	li	a7,9
 ecall
 300:	00000073          	ecall
 ret
 304:	8082                	ret

0000000000000306 <dup>:
.global dup
dup:
 li a7, SYS_dup
 306:	48a9                	li	a7,10
 ecall
 308:	00000073          	ecall
 ret
 30c:	8082                	ret

000000000000030e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 30e:	48ad                	li	a7,11
 ecall
 310:	00000073          	ecall
 ret
 314:	8082                	ret

0000000000000316 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 316:	48b1                	li	a7,12
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 31e:	48b5                	li	a7,13
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 326:	48b9                	li	a7,14
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <waitstat>:
.global waitstat
waitstat:
 li a7, SYS_waitstat
 32e:	48d9                	li	a7,22
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <btput>:
.global btput
btput:
 li a7, SYS_btput
 336:	48dd                	li	a7,23
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <tput>:
.global tput
tput:
 li a7, SYS_tput
 33e:	48e1                	li	a7,24
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <btget>:
.global btget
btget:
 li a7, SYS_btget
 346:	48e5                	li	a7,25
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <tget>:
.global tget
tget:
 li a7, SYS_tget
 34e:	48e9                	li	a7,26
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 356:	1101                	addi	sp,sp,-32
 358:	ec06                	sd	ra,24(sp)
 35a:	e822                	sd	s0,16(sp)
 35c:	1000                	addi	s0,sp,32
 35e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 362:	4605                	li	a2,1
 364:	fef40593          	addi	a1,s0,-17
 368:	00000097          	auipc	ra,0x0
 36c:	f46080e7          	jalr	-186(ra) # 2ae <write>
}
 370:	60e2                	ld	ra,24(sp)
 372:	6442                	ld	s0,16(sp)
 374:	6105                	addi	sp,sp,32
 376:	8082                	ret

0000000000000378 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 378:	7139                	addi	sp,sp,-64
 37a:	fc06                	sd	ra,56(sp)
 37c:	f822                	sd	s0,48(sp)
 37e:	f426                	sd	s1,40(sp)
 380:	f04a                	sd	s2,32(sp)
 382:	ec4e                	sd	s3,24(sp)
 384:	0080                	addi	s0,sp,64
 386:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 388:	c299                	beqz	a3,38e <printint+0x16>
 38a:	0805c963          	bltz	a1,41c <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 38e:	2581                	sext.w	a1,a1
  neg = 0;
 390:	4881                	li	a7,0
 392:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 396:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 398:	2601                	sext.w	a2,a2
 39a:	00000517          	auipc	a0,0x0
 39e:	4a650513          	addi	a0,a0,1190 # 840 <digits>
 3a2:	883a                	mv	a6,a4
 3a4:	2705                	addiw	a4,a4,1
 3a6:	02c5f7bb          	remuw	a5,a1,a2
 3aa:	1782                	slli	a5,a5,0x20
 3ac:	9381                	srli	a5,a5,0x20
 3ae:	97aa                	add	a5,a5,a0
 3b0:	0007c783          	lbu	a5,0(a5)
 3b4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3b8:	0005879b          	sext.w	a5,a1
 3bc:	02c5d5bb          	divuw	a1,a1,a2
 3c0:	0685                	addi	a3,a3,1
 3c2:	fec7f0e3          	bgeu	a5,a2,3a2 <printint+0x2a>
  if(neg)
 3c6:	00088c63          	beqz	a7,3de <printint+0x66>
    buf[i++] = '-';
 3ca:	fd070793          	addi	a5,a4,-48
 3ce:	00878733          	add	a4,a5,s0
 3d2:	02d00793          	li	a5,45
 3d6:	fef70823          	sb	a5,-16(a4)
 3da:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 3de:	02e05863          	blez	a4,40e <printint+0x96>
 3e2:	fc040793          	addi	a5,s0,-64
 3e6:	00e78933          	add	s2,a5,a4
 3ea:	fff78993          	addi	s3,a5,-1
 3ee:	99ba                	add	s3,s3,a4
 3f0:	377d                	addiw	a4,a4,-1
 3f2:	1702                	slli	a4,a4,0x20
 3f4:	9301                	srli	a4,a4,0x20
 3f6:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 3fa:	fff94583          	lbu	a1,-1(s2)
 3fe:	8526                	mv	a0,s1
 400:	00000097          	auipc	ra,0x0
 404:	f56080e7          	jalr	-170(ra) # 356 <putc>
  while(--i >= 0)
 408:	197d                	addi	s2,s2,-1
 40a:	ff3918e3          	bne	s2,s3,3fa <printint+0x82>
}
 40e:	70e2                	ld	ra,56(sp)
 410:	7442                	ld	s0,48(sp)
 412:	74a2                	ld	s1,40(sp)
 414:	7902                	ld	s2,32(sp)
 416:	69e2                	ld	s3,24(sp)
 418:	6121                	addi	sp,sp,64
 41a:	8082                	ret
    x = -xx;
 41c:	40b005bb          	negw	a1,a1
    neg = 1;
 420:	4885                	li	a7,1
    x = -xx;
 422:	bf85                	j	392 <printint+0x1a>

0000000000000424 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 424:	7119                	addi	sp,sp,-128
 426:	fc86                	sd	ra,120(sp)
 428:	f8a2                	sd	s0,112(sp)
 42a:	f4a6                	sd	s1,104(sp)
 42c:	f0ca                	sd	s2,96(sp)
 42e:	ecce                	sd	s3,88(sp)
 430:	e8d2                	sd	s4,80(sp)
 432:	e4d6                	sd	s5,72(sp)
 434:	e0da                	sd	s6,64(sp)
 436:	fc5e                	sd	s7,56(sp)
 438:	f862                	sd	s8,48(sp)
 43a:	f466                	sd	s9,40(sp)
 43c:	f06a                	sd	s10,32(sp)
 43e:	ec6e                	sd	s11,24(sp)
 440:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 442:	0005c903          	lbu	s2,0(a1)
 446:	18090f63          	beqz	s2,5e4 <vprintf+0x1c0>
 44a:	8aaa                	mv	s5,a0
 44c:	8b32                	mv	s6,a2
 44e:	00158493          	addi	s1,a1,1
  state = 0;
 452:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 454:	02500a13          	li	s4,37
 458:	4c55                	li	s8,21
 45a:	00000c97          	auipc	s9,0x0
 45e:	38ec8c93          	addi	s9,s9,910 # 7e8 <malloc+0x100>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 462:	02800d93          	li	s11,40
  putc(fd, 'x');
 466:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 468:	00000b97          	auipc	s7,0x0
 46c:	3d8b8b93          	addi	s7,s7,984 # 840 <digits>
 470:	a839                	j	48e <vprintf+0x6a>
        putc(fd, c);
 472:	85ca                	mv	a1,s2
 474:	8556                	mv	a0,s5
 476:	00000097          	auipc	ra,0x0
 47a:	ee0080e7          	jalr	-288(ra) # 356 <putc>
 47e:	a019                	j	484 <vprintf+0x60>
    } else if(state == '%'){
 480:	01498d63          	beq	s3,s4,49a <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 484:	0485                	addi	s1,s1,1
 486:	fff4c903          	lbu	s2,-1(s1)
 48a:	14090d63          	beqz	s2,5e4 <vprintf+0x1c0>
    if(state == 0){
 48e:	fe0999e3          	bnez	s3,480 <vprintf+0x5c>
      if(c == '%'){
 492:	ff4910e3          	bne	s2,s4,472 <vprintf+0x4e>
        state = '%';
 496:	89d2                	mv	s3,s4
 498:	b7f5                	j	484 <vprintf+0x60>
      if(c == 'd'){
 49a:	11490c63          	beq	s2,s4,5b2 <vprintf+0x18e>
 49e:	f9d9079b          	addiw	a5,s2,-99
 4a2:	0ff7f793          	zext.b	a5,a5
 4a6:	10fc6e63          	bltu	s8,a5,5c2 <vprintf+0x19e>
 4aa:	f9d9079b          	addiw	a5,s2,-99
 4ae:	0ff7f713          	zext.b	a4,a5
 4b2:	10ec6863          	bltu	s8,a4,5c2 <vprintf+0x19e>
 4b6:	00271793          	slli	a5,a4,0x2
 4ba:	97e6                	add	a5,a5,s9
 4bc:	439c                	lw	a5,0(a5)
 4be:	97e6                	add	a5,a5,s9
 4c0:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 4c2:	008b0913          	addi	s2,s6,8
 4c6:	4685                	li	a3,1
 4c8:	4629                	li	a2,10
 4ca:	000b2583          	lw	a1,0(s6)
 4ce:	8556                	mv	a0,s5
 4d0:	00000097          	auipc	ra,0x0
 4d4:	ea8080e7          	jalr	-344(ra) # 378 <printint>
 4d8:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 4da:	4981                	li	s3,0
 4dc:	b765                	j	484 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 4de:	008b0913          	addi	s2,s6,8
 4e2:	4681                	li	a3,0
 4e4:	4629                	li	a2,10
 4e6:	000b2583          	lw	a1,0(s6)
 4ea:	8556                	mv	a0,s5
 4ec:	00000097          	auipc	ra,0x0
 4f0:	e8c080e7          	jalr	-372(ra) # 378 <printint>
 4f4:	8b4a                	mv	s6,s2
      state = 0;
 4f6:	4981                	li	s3,0
 4f8:	b771                	j	484 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 4fa:	008b0913          	addi	s2,s6,8
 4fe:	4681                	li	a3,0
 500:	866a                	mv	a2,s10
 502:	000b2583          	lw	a1,0(s6)
 506:	8556                	mv	a0,s5
 508:	00000097          	auipc	ra,0x0
 50c:	e70080e7          	jalr	-400(ra) # 378 <printint>
 510:	8b4a                	mv	s6,s2
      state = 0;
 512:	4981                	li	s3,0
 514:	bf85                	j	484 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 516:	008b0793          	addi	a5,s6,8
 51a:	f8f43423          	sd	a5,-120(s0)
 51e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 522:	03000593          	li	a1,48
 526:	8556                	mv	a0,s5
 528:	00000097          	auipc	ra,0x0
 52c:	e2e080e7          	jalr	-466(ra) # 356 <putc>
  putc(fd, 'x');
 530:	07800593          	li	a1,120
 534:	8556                	mv	a0,s5
 536:	00000097          	auipc	ra,0x0
 53a:	e20080e7          	jalr	-480(ra) # 356 <putc>
 53e:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 540:	03c9d793          	srli	a5,s3,0x3c
 544:	97de                	add	a5,a5,s7
 546:	0007c583          	lbu	a1,0(a5)
 54a:	8556                	mv	a0,s5
 54c:	00000097          	auipc	ra,0x0
 550:	e0a080e7          	jalr	-502(ra) # 356 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 554:	0992                	slli	s3,s3,0x4
 556:	397d                	addiw	s2,s2,-1
 558:	fe0914e3          	bnez	s2,540 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 55c:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 560:	4981                	li	s3,0
 562:	b70d                	j	484 <vprintf+0x60>
        s = va_arg(ap, char*);
 564:	008b0913          	addi	s2,s6,8
 568:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 56c:	02098163          	beqz	s3,58e <vprintf+0x16a>
        while(*s != 0){
 570:	0009c583          	lbu	a1,0(s3)
 574:	c5ad                	beqz	a1,5de <vprintf+0x1ba>
          putc(fd, *s);
 576:	8556                	mv	a0,s5
 578:	00000097          	auipc	ra,0x0
 57c:	dde080e7          	jalr	-546(ra) # 356 <putc>
          s++;
 580:	0985                	addi	s3,s3,1
        while(*s != 0){
 582:	0009c583          	lbu	a1,0(s3)
 586:	f9e5                	bnez	a1,576 <vprintf+0x152>
        s = va_arg(ap, char*);
 588:	8b4a                	mv	s6,s2
      state = 0;
 58a:	4981                	li	s3,0
 58c:	bde5                	j	484 <vprintf+0x60>
          s = "(null)";
 58e:	00000997          	auipc	s3,0x0
 592:	25298993          	addi	s3,s3,594 # 7e0 <malloc+0xf8>
        while(*s != 0){
 596:	85ee                	mv	a1,s11
 598:	bff9                	j	576 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 59a:	008b0913          	addi	s2,s6,8
 59e:	000b4583          	lbu	a1,0(s6)
 5a2:	8556                	mv	a0,s5
 5a4:	00000097          	auipc	ra,0x0
 5a8:	db2080e7          	jalr	-590(ra) # 356 <putc>
 5ac:	8b4a                	mv	s6,s2
      state = 0;
 5ae:	4981                	li	s3,0
 5b0:	bdd1                	j	484 <vprintf+0x60>
        putc(fd, c);
 5b2:	85d2                	mv	a1,s4
 5b4:	8556                	mv	a0,s5
 5b6:	00000097          	auipc	ra,0x0
 5ba:	da0080e7          	jalr	-608(ra) # 356 <putc>
      state = 0;
 5be:	4981                	li	s3,0
 5c0:	b5d1                	j	484 <vprintf+0x60>
        putc(fd, '%');
 5c2:	85d2                	mv	a1,s4
 5c4:	8556                	mv	a0,s5
 5c6:	00000097          	auipc	ra,0x0
 5ca:	d90080e7          	jalr	-624(ra) # 356 <putc>
        putc(fd, c);
 5ce:	85ca                	mv	a1,s2
 5d0:	8556                	mv	a0,s5
 5d2:	00000097          	auipc	ra,0x0
 5d6:	d84080e7          	jalr	-636(ra) # 356 <putc>
      state = 0;
 5da:	4981                	li	s3,0
 5dc:	b565                	j	484 <vprintf+0x60>
        s = va_arg(ap, char*);
 5de:	8b4a                	mv	s6,s2
      state = 0;
 5e0:	4981                	li	s3,0
 5e2:	b54d                	j	484 <vprintf+0x60>
    }
  }
}
 5e4:	70e6                	ld	ra,120(sp)
 5e6:	7446                	ld	s0,112(sp)
 5e8:	74a6                	ld	s1,104(sp)
 5ea:	7906                	ld	s2,96(sp)
 5ec:	69e6                	ld	s3,88(sp)
 5ee:	6a46                	ld	s4,80(sp)
 5f0:	6aa6                	ld	s5,72(sp)
 5f2:	6b06                	ld	s6,64(sp)
 5f4:	7be2                	ld	s7,56(sp)
 5f6:	7c42                	ld	s8,48(sp)
 5f8:	7ca2                	ld	s9,40(sp)
 5fa:	7d02                	ld	s10,32(sp)
 5fc:	6de2                	ld	s11,24(sp)
 5fe:	6109                	addi	sp,sp,128
 600:	8082                	ret

0000000000000602 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 602:	715d                	addi	sp,sp,-80
 604:	ec06                	sd	ra,24(sp)
 606:	e822                	sd	s0,16(sp)
 608:	1000                	addi	s0,sp,32
 60a:	e010                	sd	a2,0(s0)
 60c:	e414                	sd	a3,8(s0)
 60e:	e818                	sd	a4,16(s0)
 610:	ec1c                	sd	a5,24(s0)
 612:	03043023          	sd	a6,32(s0)
 616:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 61a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 61e:	8622                	mv	a2,s0
 620:	00000097          	auipc	ra,0x0
 624:	e04080e7          	jalr	-508(ra) # 424 <vprintf>
}
 628:	60e2                	ld	ra,24(sp)
 62a:	6442                	ld	s0,16(sp)
 62c:	6161                	addi	sp,sp,80
 62e:	8082                	ret

0000000000000630 <printf>:

void
printf(const char *fmt, ...)
{
 630:	711d                	addi	sp,sp,-96
 632:	ec06                	sd	ra,24(sp)
 634:	e822                	sd	s0,16(sp)
 636:	1000                	addi	s0,sp,32
 638:	e40c                	sd	a1,8(s0)
 63a:	e810                	sd	a2,16(s0)
 63c:	ec14                	sd	a3,24(s0)
 63e:	f018                	sd	a4,32(s0)
 640:	f41c                	sd	a5,40(s0)
 642:	03043823          	sd	a6,48(s0)
 646:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 64a:	00840613          	addi	a2,s0,8
 64e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 652:	85aa                	mv	a1,a0
 654:	4505                	li	a0,1
 656:	00000097          	auipc	ra,0x0
 65a:	dce080e7          	jalr	-562(ra) # 424 <vprintf>
}
 65e:	60e2                	ld	ra,24(sp)
 660:	6442                	ld	s0,16(sp)
 662:	6125                	addi	sp,sp,96
 664:	8082                	ret

0000000000000666 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 666:	1141                	addi	sp,sp,-16
 668:	e422                	sd	s0,8(sp)
 66a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 66c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 670:	00000797          	auipc	a5,0x0
 674:	1e87b783          	ld	a5,488(a5) # 858 <freep>
 678:	a02d                	j	6a2 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 67a:	4618                	lw	a4,8(a2)
 67c:	9f2d                	addw	a4,a4,a1
 67e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 682:	6398                	ld	a4,0(a5)
 684:	6310                	ld	a2,0(a4)
 686:	a83d                	j	6c4 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 688:	ff852703          	lw	a4,-8(a0)
 68c:	9f31                	addw	a4,a4,a2
 68e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 690:	ff053683          	ld	a3,-16(a0)
 694:	a091                	j	6d8 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 696:	6398                	ld	a4,0(a5)
 698:	00e7e463          	bltu	a5,a4,6a0 <free+0x3a>
 69c:	00e6ea63          	bltu	a3,a4,6b0 <free+0x4a>
{
 6a0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6a2:	fed7fae3          	bgeu	a5,a3,696 <free+0x30>
 6a6:	6398                	ld	a4,0(a5)
 6a8:	00e6e463          	bltu	a3,a4,6b0 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6ac:	fee7eae3          	bltu	a5,a4,6a0 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 6b0:	ff852583          	lw	a1,-8(a0)
 6b4:	6390                	ld	a2,0(a5)
 6b6:	02059813          	slli	a6,a1,0x20
 6ba:	01c85713          	srli	a4,a6,0x1c
 6be:	9736                	add	a4,a4,a3
 6c0:	fae60de3          	beq	a2,a4,67a <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 6c4:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6c8:	4790                	lw	a2,8(a5)
 6ca:	02061593          	slli	a1,a2,0x20
 6ce:	01c5d713          	srli	a4,a1,0x1c
 6d2:	973e                	add	a4,a4,a5
 6d4:	fae68ae3          	beq	a3,a4,688 <free+0x22>
    p->s.ptr = bp->s.ptr;
 6d8:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 6da:	00000717          	auipc	a4,0x0
 6de:	16f73f23          	sd	a5,382(a4) # 858 <freep>
}
 6e2:	6422                	ld	s0,8(sp)
 6e4:	0141                	addi	sp,sp,16
 6e6:	8082                	ret

00000000000006e8 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 6e8:	7139                	addi	sp,sp,-64
 6ea:	fc06                	sd	ra,56(sp)
 6ec:	f822                	sd	s0,48(sp)
 6ee:	f426                	sd	s1,40(sp)
 6f0:	f04a                	sd	s2,32(sp)
 6f2:	ec4e                	sd	s3,24(sp)
 6f4:	e852                	sd	s4,16(sp)
 6f6:	e456                	sd	s5,8(sp)
 6f8:	e05a                	sd	s6,0(sp)
 6fa:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6fc:	02051493          	slli	s1,a0,0x20
 700:	9081                	srli	s1,s1,0x20
 702:	04bd                	addi	s1,s1,15
 704:	8091                	srli	s1,s1,0x4
 706:	0014899b          	addiw	s3,s1,1
 70a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 70c:	00000517          	auipc	a0,0x0
 710:	14c53503          	ld	a0,332(a0) # 858 <freep>
 714:	c515                	beqz	a0,740 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 716:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 718:	4798                	lw	a4,8(a5)
 71a:	02977f63          	bgeu	a4,s1,758 <malloc+0x70>
 71e:	8a4e                	mv	s4,s3
 720:	0009871b          	sext.w	a4,s3
 724:	6685                	lui	a3,0x1
 726:	00d77363          	bgeu	a4,a3,72c <malloc+0x44>
 72a:	6a05                	lui	s4,0x1
 72c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 730:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 734:	00000917          	auipc	s2,0x0
 738:	12490913          	addi	s2,s2,292 # 858 <freep>
  if(p == (char*)-1)
 73c:	5afd                	li	s5,-1
 73e:	a895                	j	7b2 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 740:	00000797          	auipc	a5,0x0
 744:	12078793          	addi	a5,a5,288 # 860 <base>
 748:	00000717          	auipc	a4,0x0
 74c:	10f73823          	sd	a5,272(a4) # 858 <freep>
 750:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 752:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 756:	b7e1                	j	71e <malloc+0x36>
      if(p->s.size == nunits)
 758:	02e48c63          	beq	s1,a4,790 <malloc+0xa8>
        p->s.size -= nunits;
 75c:	4137073b          	subw	a4,a4,s3
 760:	c798                	sw	a4,8(a5)
        p += p->s.size;
 762:	02071693          	slli	a3,a4,0x20
 766:	01c6d713          	srli	a4,a3,0x1c
 76a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 76c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 770:	00000717          	auipc	a4,0x0
 774:	0ea73423          	sd	a0,232(a4) # 858 <freep>
      return (void*)(p + 1);
 778:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 77c:	70e2                	ld	ra,56(sp)
 77e:	7442                	ld	s0,48(sp)
 780:	74a2                	ld	s1,40(sp)
 782:	7902                	ld	s2,32(sp)
 784:	69e2                	ld	s3,24(sp)
 786:	6a42                	ld	s4,16(sp)
 788:	6aa2                	ld	s5,8(sp)
 78a:	6b02                	ld	s6,0(sp)
 78c:	6121                	addi	sp,sp,64
 78e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 790:	6398                	ld	a4,0(a5)
 792:	e118                	sd	a4,0(a0)
 794:	bff1                	j	770 <malloc+0x88>
  hp->s.size = nu;
 796:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 79a:	0541                	addi	a0,a0,16
 79c:	00000097          	auipc	ra,0x0
 7a0:	eca080e7          	jalr	-310(ra) # 666 <free>
  return freep;
 7a4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7a8:	d971                	beqz	a0,77c <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7aa:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7ac:	4798                	lw	a4,8(a5)
 7ae:	fa9775e3          	bgeu	a4,s1,758 <malloc+0x70>
    if(p == freep)
 7b2:	00093703          	ld	a4,0(s2)
 7b6:	853e                	mv	a0,a5
 7b8:	fef719e3          	bne	a4,a5,7aa <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 7bc:	8552                	mv	a0,s4
 7be:	00000097          	auipc	ra,0x0
 7c2:	b58080e7          	jalr	-1192(ra) # 316 <sbrk>
  if(p == (char*)-1)
 7c6:	fd5518e3          	bne	a0,s5,796 <malloc+0xae>
        return 0;
 7ca:	4501                	li	a0,0
 7cc:	bf45                	j	77c <malloc+0x94>