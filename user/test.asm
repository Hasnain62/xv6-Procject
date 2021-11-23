
user/_test:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
//#include "kernel/stat.h"
//#include "errno.h" 
uint turntime = 0 ;
uint running = 0;

int main(int argc, char *argv[]) {
   0:	7119                	addi	sp,sp,-128
   2:	fc86                	sd	ra,120(sp)
   4:	f8a2                	sd	s0,112(sp)
   6:	f4a6                	sd	s1,104(sp)
   8:	f0ca                	sd	s2,96(sp)
   a:	ecce                	sd	s3,88(sp)
   c:	e8d2                	sd	s4,80(sp)
   e:	e4d6                	sd	s5,72(sp)
  10:	e0da                	sd	s6,64(sp)
  12:	fc5e                	sd	s7,56(sp)
  14:	f862                	sd	s8,48(sp)
  16:	f466                	sd	s9,40(sp)
  18:	f06a                	sd	s10,32(sp)
  1a:	ec6e                	sd	s11,24(sp)
  1c:	0100                	addi	s0,sp,128
  1e:	84ae                	mv	s1,a1

    int K = atoi(argv[1]); // Take the arguments from the command Line
  20:	6588                	ld	a0,8(a1)
  22:	00000097          	auipc	ra,0x0
  26:	3d2080e7          	jalr	978(ra) # 3f4 <atoi>
  2a:	8baa                	mv	s7,a0
    int L = atoi(argv[2]);
  2c:	6888                	ld	a0,16(s1)
  2e:	00000097          	auipc	ra,0x0
  32:	3c6080e7          	jalr	966(ra) # 3f4 <atoi>
  36:	f8a43423          	sd	a0,-120(s0)
    int M = atoi(argv[3]);
  3a:	6c88                	ld	a0,24(s1)
  3c:	00000097          	auipc	ra,0x0
  40:	3b8080e7          	jalr	952(ra) # 3f4 <atoi>
  44:	8daa                	mv	s11,a0
    int N = atoi(argv[4]);
  46:	7088                	ld	a0,32(s1)
  48:	00000097          	auipc	ra,0x0
  4c:	3ac080e7          	jalr	940(ra) # 3f4 <atoi>
  50:	8c2a                	mv	s8,a0
 
printf("%d\n",K);
  52:	85de                	mv	a1,s7
  54:	00001517          	auipc	a0,0x1
  58:	9dc50513          	addi	a0,a0,-1572 # a30 <malloc+0xe8>
  5c:	00001097          	auipc	ra,0x1
  60:	834080e7          	jalr	-1996(ra) # 890 <printf>
printf("%d\n",N);
  64:	85e2                	mv	a1,s8
  66:	00001517          	auipc	a0,0x1
  6a:	9ca50513          	addi	a0,a0,-1590 # a30 <malloc+0xe8>
  6e:	00001097          	auipc	ra,0x1
  72:	822080e7          	jalr	-2014(ra) # 890 <printf>
int iter2 = 0; 
int Diff = 0;
int pid1 = -1 ;
int pid2 = -1;
int pid3 = -1; 
int *ParentID1 = malloc (sizeof (int)* 45) ;
  76:	0b400513          	li	a0,180
  7a:	00001097          	auipc	ra,0x1
  7e:	8ce080e7          	jalr	-1842(ra) # 948 <malloc>
  82:	8caa                	mv	s9,a0
  84:	892a                	mv	s2,a0
  86:	4485                	li	s1,1
int pid1 = -1 ;
  88:	59fd                	li	s3,-1

while (iter1 < 45){

// if (pid1 != 0){	
if (iter1 <= 15){
  8a:	4abd                	li	s5,15
       //printf("(i - j) = %d\n",Diff );
       exit(1);
      }

    }
else if (iter1 > 15 && iter1 <= 30){
  8c:	4a39                	li	s4,14
while (iter1 < 45){
  8e:	02c00b13          	li	s6,44
   
    ParentID1[iter1] = pid1;
  }
    //}
  if(pid3 < 0){
      printf("Didnt fork successfully ");
  92:	00001d17          	auipc	s10,0x1
  96:	9a6d0d13          	addi	s10,s10,-1626 # a38 <malloc+0xf0>
  9a:	a829                	j	b4 <main+0xb4>
  pid1 = fork();
  9c:	00000097          	auipc	ra,0x0
  a0:	44a080e7          	jalr	1098(ra) # 4e6 <fork>
  a4:	89aa                	mv	s3,a0
  if(pid1 != 0){
  a6:	c525                	beqz	a0,10e <main+0x10e>
    ParentID1[iter1] = pid1;
  a8:	00a92023          	sw	a0,0(s2)
  if(pid1 < 0){
  ac:	04054b63          	bltz	a0,102 <main+0x102>
  b0:	2485                	addiw	s1,s1,1
  b2:	0911                	addi	s2,s2,4
if (iter1 <= 15){
  b4:	fff4879b          	addiw	a5,s1,-1
  b8:	fefad2e3          	bge	s5,a5,9c <main+0x9c>
else if (iter1 > 15 && iter1 <= 30){
  bc:	fef4879b          	addiw	a5,s1,-17
  c0:	06fa7e63          	bgeu	s4,a5,13c <main+0x13c>
else if(iter1 > 30 && iter1 <= 45){
  c4:	fe04879b          	addiw	a5,s1,-32
  c8:	0afa7c63          	bgeu	s4,a5,180 <main+0x180>
while (iter1 < 45){
  cc:	0004879b          	sext.w	a5,s1
  d0:	fefb50e3          	bge	s6,a5,b0 <main+0xb0>
  d4:	02d00b13          	li	s6,45
int sum1 = 0;
int sum2 = 0;
int sum3 = 0;
int sum4 = 0;
int sum5 = 0;
int sum6 = 0;
  d8:	f8043023          	sd	zero,-128(s0)
int sum5 = 0;
  dc:	4d81                	li	s11,0
int sum4 = 0;
  de:	4a81                	li	s5,0
int sum3 = 0;
  e0:	f8043423          	sd	zero,-120(s0)
int sum2 = 0;
  e4:	4d01                	li	s10,0
int sum1 = 0;
  e6:	4a01                	li	s4,0

int returnpid = 0;
while(iter2 < 45){

returnpid = waitstat(0,&turntime,&running);
  e8:	00001c17          	auipc	s8,0x1
  ec:	ad8c0c13          	addi	s8,s8,-1320 # bc0 <running>
  f0:	00001b97          	auipc	s7,0x1
  f4:	ad4b8b93          	addi	s7,s7,-1324 # bc4 <turntime>
// printf ("Outer loop : %d\n", returnpid);
  int iter3 = 0;

  while (iter3 < 45){
  f8:	02c00493          	li	s1,44
 

  if (returnpid == ParentID1[iter3]) {


    if (iter3 <= 15){
  fc:	49bd                	li	s3,15
      sum1 = sum1 + turntime;
      sum4 = sum4 + running;

    }

    else if (iter3 > 15 && iter3 <= 30){
  fe:	4939                	li	s2,14
 100:	aa31                	j	21c <main+0x21c>
      printf("Didnt fork successfully ");
 102:	856a                	mv	a0,s10
 104:	00000097          	auipc	ra,0x0
 108:	78c080e7          	jalr	1932(ra) # 890 <printf>
 10c:	b755                	j	b0 <main+0xb0>
       while (i<=K){
 10e:	03705263          	blez	s7,132 <main+0x132>
 112:	2b85                	addiw	s7,s7,1
       int i = 1;
 114:	4685                	li	a3,1
 116:	001c071b          	addiw	a4,s8,1
          int j = 1;
 11a:	4605                	li	a2,1
 11c:	a021                	j	124 <main+0x124>
           i++;
 11e:	2685                	addiw	a3,a3,1
       while (i<=K){
 120:	01768963          	beq	a3,s7,132 <main+0x132>
          int j = 1;
 124:	87b2                	mv	a5,a2
           while (j<=N)
 126:	ff805ce3          	blez	s8,11e <main+0x11e>
		         j++;
 12a:	2785                	addiw	a5,a5,1
           while (j<=N)
 12c:	fee79fe3          	bne	a5,a4,12a <main+0x12a>
 130:	b7fd                	j	11e <main+0x11e>
       exit(1);
 132:	4505                	li	a0,1
 134:	00000097          	auipc	ra,0x0
 138:	3ba080e7          	jalr	954(ra) # 4ee <exit>
  pid2 = fork();
 13c:	00000097          	auipc	ra,0x0
 140:	3aa080e7          	jalr	938(ra) # 4e6 <fork>
  if(pid2 != 0){
 144:	c919                	beqz	a0,15a <main+0x15a>
    ParentID1[iter1] = pid1;
 146:	01392023          	sw	s3,0(s2)
  if(pid2 < 0){
 14a:	f60553e3          	bgez	a0,b0 <main+0xb0>
      printf("Didnt fork successfully ");
 14e:	856a                	mv	a0,s10
 150:	00000097          	auipc	ra,0x0
 154:	740080e7          	jalr	1856(ra) # 890 <printf>
 158:	bfa1                	j	b0 <main+0xb0>
  if(pid2 < 0){
 15a:	fe054ae3          	bltz	a0,14e <main+0x14e>
  else if(pid2==0) // child process 
 15e:	f929                	bnez	a0,b0 <main+0xb0>
       int i = 1;
 160:	4785                	li	a5,1
          int j = 1;
 162:	4685                	li	a3,1
 164:	a029                	j	16e <main+0x16e>
		         j++;
 166:	2705                	addiw	a4,a4,1
           while (j<=M)
 168:	feeddfe3          	bge	s11,a4,166 <main+0x166>
           i++;
 16c:	2785                	addiw	a5,a5,1
       while (i<=K){
 16e:	00fbd763          	bge	s7,a5,17c <main+0x17c>
       exit(1);
 172:	4505                	li	a0,1
 174:	00000097          	auipc	ra,0x0
 178:	37a080e7          	jalr	890(ra) # 4ee <exit>
          int j = 1;
 17c:	8736                	mv	a4,a3
 17e:	b7ed                	j	168 <main+0x168>
pid3 = fork();
 180:	00000097          	auipc	ra,0x0
 184:	366080e7          	jalr	870(ra) # 4e6 <fork>
  if(pid3 != 0){
 188:	c915                	beqz	a0,1bc <main+0x1bc>
    ParentID1[iter1] = pid1;
 18a:	01392023          	sw	s3,0(s2)
  if(pid3 < 0){
 18e:	f2055fe3          	bgez	a0,cc <main+0xcc>
      printf("Didnt fork successfully ");
 192:	856a                	mv	a0,s10
 194:	00000097          	auipc	ra,0x0
 198:	6fc080e7          	jalr	1788(ra) # 890 <printf>
 19c:	bf05                	j	cc <main+0xcc>
		         j++;
 19e:	2705                	addiw	a4,a4,1
           while (j<=L)
 1a0:	f8843603          	ld	a2,-120(s0)
 1a4:	fee65de3          	bge	a2,a4,19e <main+0x19e>
           i++;
 1a8:	2785                	addiw	a5,a5,1
       while (i<=K){
 1aa:	00fbd763          	bge	s7,a5,1b8 <main+0x1b8>
       exit(1);
 1ae:	4505                	li	a0,1
 1b0:	00000097          	auipc	ra,0x0
 1b4:	33e080e7          	jalr	830(ra) # 4ee <exit>
          int j = 1;
 1b8:	8736                	mv	a4,a3
 1ba:	b7dd                	j	1a0 <main+0x1a0>
       int i = 1;
 1bc:	4785                	li	a5,1
          int j = 1;
 1be:	4685                	li	a3,1
 1c0:	b7ed                	j	1aa <main+0x1aa>
    else if (iter3 > 15 && iter3 <= 30){
 1c2:	fef7869b          	addiw	a3,a5,-17
 1c6:	02d97863          	bgeu	s2,a3,1f6 <main+0x1f6>
      sum2 = sum2 + turntime;
      sum5 = sum5 + running;

           }

    else if(iter3 > 30 && iter3 <= 45){
 1ca:	fe07869b          	addiw	a3,a5,-32
 1ce:	02d97963          	bgeu	s2,a3,200 <main+0x200>
  while (iter3 < 45){
 1d2:	0007869b          	sext.w	a3,a5
 1d6:	04d4c063          	blt	s1,a3,216 <main+0x216>
 1da:	0711                	addi	a4,a4,4
 1dc:	2785                	addiw	a5,a5,1
  if (returnpid == ParentID1[iter3]) {
 1de:	4314                	lw	a3,0(a4)
 1e0:	fea699e3          	bne	a3,a0,1d2 <main+0x1d2>
    if (iter3 <= 15){
 1e4:	fff7869b          	addiw	a3,a5,-1
 1e8:	fcd9cde3          	blt	s3,a3,1c2 <main+0x1c2>
      sum1 = sum1 + turntime;
 1ec:	00ba0a3b          	addw	s4,s4,a1
      sum4 = sum4 + running;
 1f0:	00ca8abb          	addw	s5,s5,a2
 1f4:	b7dd                	j	1da <main+0x1da>
      sum2 = sum2 + turntime;
 1f6:	00bd0d3b          	addw	s10,s10,a1
      sum5 = sum5 + running;
 1fa:	00cd8dbb          	addw	s11,s11,a2
 1fe:	bff1                	j	1da <main+0x1da>

      sum3 = sum3 + turntime;
 200:	f8843683          	ld	a3,-120(s0)
 204:	9ead                	addw	a3,a3,a1
 206:	f8d43423          	sd	a3,-120(s0)
      sum6 = sum6 + running;
 20a:	f8043683          	ld	a3,-128(s0)
 20e:	9eb1                	addw	a3,a3,a2
 210:	f8d43023          	sd	a3,-128(s0)
 214:	bf7d                	j	1d2 <main+0x1d2>
while(iter2 < 45){
 216:	3b7d                	addiw	s6,s6,-1
 218:	020b0063          	beqz	s6,238 <main+0x238>
returnpid = waitstat(0,&turntime,&running);
 21c:	8662                	mv	a2,s8
 21e:	85de                	mv	a1,s7
 220:	4501                	li	a0,0
 222:	00000097          	auipc	ra,0x0
 226:	36c080e7          	jalr	876(ra) # 58e <waitstat>
      sum3 = sum3 + turntime;
 22a:	000ba583          	lw	a1,0(s7)
      sum6 = sum6 + running;
 22e:	000c2603          	lw	a2,0(s8)
 232:	8766                	mv	a4,s9
 234:	4785                	li	a5,1
 236:	b765                	j	1de <main+0x1de>
    }
  iter2++;
  
  }

  printf("Sum of turnaround time for 1st group  : %d   and Sum of running time : %d \n", sum1,sum4);
 238:	8656                	mv	a2,s5
 23a:	85d2                	mv	a1,s4
 23c:	00001517          	auipc	a0,0x1
 240:	81c50513          	addi	a0,a0,-2020 # a58 <malloc+0x110>
 244:	00000097          	auipc	ra,0x0
 248:	64c080e7          	jalr	1612(ra) # 890 <printf>
  printf("Sum of turnaround time for 2nd group : %d   and Sum of running time : %d \n", sum2,sum5);
 24c:	866e                	mv	a2,s11
 24e:	85ea                	mv	a1,s10
 250:	00001517          	auipc	a0,0x1
 254:	85850513          	addi	a0,a0,-1960 # aa8 <malloc+0x160>
 258:	00000097          	auipc	ra,0x0
 25c:	638080e7          	jalr	1592(ra) # 890 <printf>
  printf("Sum of turnaround time for 3rd group : %d   and Sum of running time : %d \n", sum3,sum6);
 260:	f8043603          	ld	a2,-128(s0)
 264:	f8843583          	ld	a1,-120(s0)
 268:	00001517          	auipc	a0,0x1
 26c:	89050513          	addi	a0,a0,-1904 # af8 <malloc+0x1b0>
 270:	00000097          	auipc	ra,0x0
 274:	620080e7          	jalr	1568(ra) # 890 <printf>
 


exit(0);
 278:	4501                	li	a0,0
 27a:	00000097          	auipc	ra,0x0
 27e:	274080e7          	jalr	628(ra) # 4ee <exit>

0000000000000282 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 282:	1141                	addi	sp,sp,-16
 284:	e422                	sd	s0,8(sp)
 286:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 288:	87aa                	mv	a5,a0
 28a:	0585                	addi	a1,a1,1
 28c:	0785                	addi	a5,a5,1
 28e:	fff5c703          	lbu	a4,-1(a1)
 292:	fee78fa3          	sb	a4,-1(a5)
 296:	fb75                	bnez	a4,28a <strcpy+0x8>
    ;
  return os;
}
 298:	6422                	ld	s0,8(sp)
 29a:	0141                	addi	sp,sp,16
 29c:	8082                	ret

000000000000029e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 29e:	1141                	addi	sp,sp,-16
 2a0:	e422                	sd	s0,8(sp)
 2a2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 2a4:	00054783          	lbu	a5,0(a0)
 2a8:	cb91                	beqz	a5,2bc <strcmp+0x1e>
 2aa:	0005c703          	lbu	a4,0(a1)
 2ae:	00f71763          	bne	a4,a5,2bc <strcmp+0x1e>
    p++, q++;
 2b2:	0505                	addi	a0,a0,1
 2b4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2b6:	00054783          	lbu	a5,0(a0)
 2ba:	fbe5                	bnez	a5,2aa <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2bc:	0005c503          	lbu	a0,0(a1)
}
 2c0:	40a7853b          	subw	a0,a5,a0
 2c4:	6422                	ld	s0,8(sp)
 2c6:	0141                	addi	sp,sp,16
 2c8:	8082                	ret

00000000000002ca <strlen>:

uint
strlen(const char *s)
{
 2ca:	1141                	addi	sp,sp,-16
 2cc:	e422                	sd	s0,8(sp)
 2ce:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2d0:	00054783          	lbu	a5,0(a0)
 2d4:	cf91                	beqz	a5,2f0 <strlen+0x26>
 2d6:	0505                	addi	a0,a0,1
 2d8:	87aa                	mv	a5,a0
 2da:	4685                	li	a3,1
 2dc:	9e89                	subw	a3,a3,a0
 2de:	00f6853b          	addw	a0,a3,a5
 2e2:	0785                	addi	a5,a5,1
 2e4:	fff7c703          	lbu	a4,-1(a5)
 2e8:	fb7d                	bnez	a4,2de <strlen+0x14>
    ;
  return n;
}
 2ea:	6422                	ld	s0,8(sp)
 2ec:	0141                	addi	sp,sp,16
 2ee:	8082                	ret
  for(n = 0; s[n]; n++)
 2f0:	4501                	li	a0,0
 2f2:	bfe5                	j	2ea <strlen+0x20>

00000000000002f4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2f4:	1141                	addi	sp,sp,-16
 2f6:	e422                	sd	s0,8(sp)
 2f8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2fa:	ca19                	beqz	a2,310 <memset+0x1c>
 2fc:	87aa                	mv	a5,a0
 2fe:	1602                	slli	a2,a2,0x20
 300:	9201                	srli	a2,a2,0x20
 302:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 306:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 30a:	0785                	addi	a5,a5,1
 30c:	fee79de3          	bne	a5,a4,306 <memset+0x12>
  }
  return dst;
}
 310:	6422                	ld	s0,8(sp)
 312:	0141                	addi	sp,sp,16
 314:	8082                	ret

0000000000000316 <strchr>:

char*
strchr(const char *s, char c)
{
 316:	1141                	addi	sp,sp,-16
 318:	e422                	sd	s0,8(sp)
 31a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 31c:	00054783          	lbu	a5,0(a0)
 320:	cb99                	beqz	a5,336 <strchr+0x20>
    if(*s == c)
 322:	00f58763          	beq	a1,a5,330 <strchr+0x1a>
  for(; *s; s++)
 326:	0505                	addi	a0,a0,1
 328:	00054783          	lbu	a5,0(a0)
 32c:	fbfd                	bnez	a5,322 <strchr+0xc>
      return (char*)s;
  return 0;
 32e:	4501                	li	a0,0
}
 330:	6422                	ld	s0,8(sp)
 332:	0141                	addi	sp,sp,16
 334:	8082                	ret
  return 0;
 336:	4501                	li	a0,0
 338:	bfe5                	j	330 <strchr+0x1a>

000000000000033a <gets>:

char*
gets(char *buf, int max)
{
 33a:	711d                	addi	sp,sp,-96
 33c:	ec86                	sd	ra,88(sp)
 33e:	e8a2                	sd	s0,80(sp)
 340:	e4a6                	sd	s1,72(sp)
 342:	e0ca                	sd	s2,64(sp)
 344:	fc4e                	sd	s3,56(sp)
 346:	f852                	sd	s4,48(sp)
 348:	f456                	sd	s5,40(sp)
 34a:	f05a                	sd	s6,32(sp)
 34c:	ec5e                	sd	s7,24(sp)
 34e:	1080                	addi	s0,sp,96
 350:	8baa                	mv	s7,a0
 352:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 354:	892a                	mv	s2,a0
 356:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 358:	4aa9                	li	s5,10
 35a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 35c:	89a6                	mv	s3,s1
 35e:	2485                	addiw	s1,s1,1
 360:	0344d863          	bge	s1,s4,390 <gets+0x56>
    cc = read(0, &c, 1);
 364:	4605                	li	a2,1
 366:	faf40593          	addi	a1,s0,-81
 36a:	4501                	li	a0,0
 36c:	00000097          	auipc	ra,0x0
 370:	19a080e7          	jalr	410(ra) # 506 <read>
    if(cc < 1)
 374:	00a05e63          	blez	a0,390 <gets+0x56>
    buf[i++] = c;
 378:	faf44783          	lbu	a5,-81(s0)
 37c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 380:	01578763          	beq	a5,s5,38e <gets+0x54>
 384:	0905                	addi	s2,s2,1
 386:	fd679be3          	bne	a5,s6,35c <gets+0x22>
  for(i=0; i+1 < max; ){
 38a:	89a6                	mv	s3,s1
 38c:	a011                	j	390 <gets+0x56>
 38e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 390:	99de                	add	s3,s3,s7
 392:	00098023          	sb	zero,0(s3)
  return buf;
}
 396:	855e                	mv	a0,s7
 398:	60e6                	ld	ra,88(sp)
 39a:	6446                	ld	s0,80(sp)
 39c:	64a6                	ld	s1,72(sp)
 39e:	6906                	ld	s2,64(sp)
 3a0:	79e2                	ld	s3,56(sp)
 3a2:	7a42                	ld	s4,48(sp)
 3a4:	7aa2                	ld	s5,40(sp)
 3a6:	7b02                	ld	s6,32(sp)
 3a8:	6be2                	ld	s7,24(sp)
 3aa:	6125                	addi	sp,sp,96
 3ac:	8082                	ret

00000000000003ae <stat>:

int
stat(const char *n, struct stat *st)
{
 3ae:	1101                	addi	sp,sp,-32
 3b0:	ec06                	sd	ra,24(sp)
 3b2:	e822                	sd	s0,16(sp)
 3b4:	e426                	sd	s1,8(sp)
 3b6:	e04a                	sd	s2,0(sp)
 3b8:	1000                	addi	s0,sp,32
 3ba:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3bc:	4581                	li	a1,0
 3be:	00000097          	auipc	ra,0x0
 3c2:	170080e7          	jalr	368(ra) # 52e <open>
  if(fd < 0)
 3c6:	02054563          	bltz	a0,3f0 <stat+0x42>
 3ca:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3cc:	85ca                	mv	a1,s2
 3ce:	00000097          	auipc	ra,0x0
 3d2:	178080e7          	jalr	376(ra) # 546 <fstat>
 3d6:	892a                	mv	s2,a0
  close(fd);
 3d8:	8526                	mv	a0,s1
 3da:	00000097          	auipc	ra,0x0
 3de:	13c080e7          	jalr	316(ra) # 516 <close>
  return r;
}
 3e2:	854a                	mv	a0,s2
 3e4:	60e2                	ld	ra,24(sp)
 3e6:	6442                	ld	s0,16(sp)
 3e8:	64a2                	ld	s1,8(sp)
 3ea:	6902                	ld	s2,0(sp)
 3ec:	6105                	addi	sp,sp,32
 3ee:	8082                	ret
    return -1;
 3f0:	597d                	li	s2,-1
 3f2:	bfc5                	j	3e2 <stat+0x34>

00000000000003f4 <atoi>:

int
atoi(const char *s)
{
 3f4:	1141                	addi	sp,sp,-16
 3f6:	e422                	sd	s0,8(sp)
 3f8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3fa:	00054683          	lbu	a3,0(a0)
 3fe:	fd06879b          	addiw	a5,a3,-48
 402:	0ff7f793          	zext.b	a5,a5
 406:	4625                	li	a2,9
 408:	02f66863          	bltu	a2,a5,438 <atoi+0x44>
 40c:	872a                	mv	a4,a0
  n = 0;
 40e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 410:	0705                	addi	a4,a4,1
 412:	0025179b          	slliw	a5,a0,0x2
 416:	9fa9                	addw	a5,a5,a0
 418:	0017979b          	slliw	a5,a5,0x1
 41c:	9fb5                	addw	a5,a5,a3
 41e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 422:	00074683          	lbu	a3,0(a4)
 426:	fd06879b          	addiw	a5,a3,-48
 42a:	0ff7f793          	zext.b	a5,a5
 42e:	fef671e3          	bgeu	a2,a5,410 <atoi+0x1c>
  return n;
}
 432:	6422                	ld	s0,8(sp)
 434:	0141                	addi	sp,sp,16
 436:	8082                	ret
  n = 0;
 438:	4501                	li	a0,0
 43a:	bfe5                	j	432 <atoi+0x3e>

000000000000043c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 43c:	1141                	addi	sp,sp,-16
 43e:	e422                	sd	s0,8(sp)
 440:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 442:	02b57463          	bgeu	a0,a1,46a <memmove+0x2e>
    while(n-- > 0)
 446:	00c05f63          	blez	a2,464 <memmove+0x28>
 44a:	1602                	slli	a2,a2,0x20
 44c:	9201                	srli	a2,a2,0x20
 44e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 452:	872a                	mv	a4,a0
      *dst++ = *src++;
 454:	0585                	addi	a1,a1,1
 456:	0705                	addi	a4,a4,1
 458:	fff5c683          	lbu	a3,-1(a1)
 45c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 460:	fee79ae3          	bne	a5,a4,454 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 464:	6422                	ld	s0,8(sp)
 466:	0141                	addi	sp,sp,16
 468:	8082                	ret
    dst += n;
 46a:	00c50733          	add	a4,a0,a2
    src += n;
 46e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 470:	fec05ae3          	blez	a2,464 <memmove+0x28>
 474:	fff6079b          	addiw	a5,a2,-1
 478:	1782                	slli	a5,a5,0x20
 47a:	9381                	srli	a5,a5,0x20
 47c:	fff7c793          	not	a5,a5
 480:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 482:	15fd                	addi	a1,a1,-1
 484:	177d                	addi	a4,a4,-1
 486:	0005c683          	lbu	a3,0(a1)
 48a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 48e:	fee79ae3          	bne	a5,a4,482 <memmove+0x46>
 492:	bfc9                	j	464 <memmove+0x28>

0000000000000494 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 494:	1141                	addi	sp,sp,-16
 496:	e422                	sd	s0,8(sp)
 498:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 49a:	ca05                	beqz	a2,4ca <memcmp+0x36>
 49c:	fff6069b          	addiw	a3,a2,-1
 4a0:	1682                	slli	a3,a3,0x20
 4a2:	9281                	srli	a3,a3,0x20
 4a4:	0685                	addi	a3,a3,1
 4a6:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 4a8:	00054783          	lbu	a5,0(a0)
 4ac:	0005c703          	lbu	a4,0(a1)
 4b0:	00e79863          	bne	a5,a4,4c0 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 4b4:	0505                	addi	a0,a0,1
    p2++;
 4b6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4b8:	fed518e3          	bne	a0,a3,4a8 <memcmp+0x14>
  }
  return 0;
 4bc:	4501                	li	a0,0
 4be:	a019                	j	4c4 <memcmp+0x30>
      return *p1 - *p2;
 4c0:	40e7853b          	subw	a0,a5,a4
}
 4c4:	6422                	ld	s0,8(sp)
 4c6:	0141                	addi	sp,sp,16
 4c8:	8082                	ret
  return 0;
 4ca:	4501                	li	a0,0
 4cc:	bfe5                	j	4c4 <memcmp+0x30>

00000000000004ce <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4ce:	1141                	addi	sp,sp,-16
 4d0:	e406                	sd	ra,8(sp)
 4d2:	e022                	sd	s0,0(sp)
 4d4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4d6:	00000097          	auipc	ra,0x0
 4da:	f66080e7          	jalr	-154(ra) # 43c <memmove>
}
 4de:	60a2                	ld	ra,8(sp)
 4e0:	6402                	ld	s0,0(sp)
 4e2:	0141                	addi	sp,sp,16
 4e4:	8082                	ret

00000000000004e6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4e6:	4885                	li	a7,1
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <exit>:
.global exit
exit:
 li a7, SYS_exit
 4ee:	4889                	li	a7,2
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 4f6:	488d                	li	a7,3
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4fe:	4891                	li	a7,4
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <read>:
.global read
read:
 li a7, SYS_read
 506:	4895                	li	a7,5
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <write>:
.global write
write:
 li a7, SYS_write
 50e:	48c1                	li	a7,16
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <close>:
.global close
close:
 li a7, SYS_close
 516:	48d5                	li	a7,21
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <kill>:
.global kill
kill:
 li a7, SYS_kill
 51e:	4899                	li	a7,6
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <exec>:
.global exec
exec:
 li a7, SYS_exec
 526:	489d                	li	a7,7
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <open>:
.global open
open:
 li a7, SYS_open
 52e:	48bd                	li	a7,15
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 536:	48c5                	li	a7,17
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 53e:	48c9                	li	a7,18
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 546:	48a1                	li	a7,8
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <link>:
.global link
link:
 li a7, SYS_link
 54e:	48cd                	li	a7,19
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 556:	48d1                	li	a7,20
 ecall
 558:	00000073          	ecall
 ret
 55c:	8082                	ret

000000000000055e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 55e:	48a5                	li	a7,9
 ecall
 560:	00000073          	ecall
 ret
 564:	8082                	ret

0000000000000566 <dup>:
.global dup
dup:
 li a7, SYS_dup
 566:	48a9                	li	a7,10
 ecall
 568:	00000073          	ecall
 ret
 56c:	8082                	ret

000000000000056e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 56e:	48ad                	li	a7,11
 ecall
 570:	00000073          	ecall
 ret
 574:	8082                	ret

0000000000000576 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 576:	48b1                	li	a7,12
 ecall
 578:	00000073          	ecall
 ret
 57c:	8082                	ret

000000000000057e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 57e:	48b5                	li	a7,13
 ecall
 580:	00000073          	ecall
 ret
 584:	8082                	ret

0000000000000586 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 586:	48b9                	li	a7,14
 ecall
 588:	00000073          	ecall
 ret
 58c:	8082                	ret

000000000000058e <waitstat>:
.global waitstat
waitstat:
 li a7, SYS_waitstat
 58e:	48d9                	li	a7,22
 ecall
 590:	00000073          	ecall
 ret
 594:	8082                	ret

0000000000000596 <btput>:
.global btput
btput:
 li a7, SYS_btput
 596:	48dd                	li	a7,23
 ecall
 598:	00000073          	ecall
 ret
 59c:	8082                	ret

000000000000059e <tput>:
.global tput
tput:
 li a7, SYS_tput
 59e:	48e1                	li	a7,24
 ecall
 5a0:	00000073          	ecall
 ret
 5a4:	8082                	ret

00000000000005a6 <btget>:
.global btget
btget:
 li a7, SYS_btget
 5a6:	48e5                	li	a7,25
 ecall
 5a8:	00000073          	ecall
 ret
 5ac:	8082                	ret

00000000000005ae <tget>:
.global tget
tget:
 li a7, SYS_tget
 5ae:	48e9                	li	a7,26
 ecall
 5b0:	00000073          	ecall
 ret
 5b4:	8082                	ret

00000000000005b6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5b6:	1101                	addi	sp,sp,-32
 5b8:	ec06                	sd	ra,24(sp)
 5ba:	e822                	sd	s0,16(sp)
 5bc:	1000                	addi	s0,sp,32
 5be:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5c2:	4605                	li	a2,1
 5c4:	fef40593          	addi	a1,s0,-17
 5c8:	00000097          	auipc	ra,0x0
 5cc:	f46080e7          	jalr	-186(ra) # 50e <write>
}
 5d0:	60e2                	ld	ra,24(sp)
 5d2:	6442                	ld	s0,16(sp)
 5d4:	6105                	addi	sp,sp,32
 5d6:	8082                	ret

00000000000005d8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5d8:	7139                	addi	sp,sp,-64
 5da:	fc06                	sd	ra,56(sp)
 5dc:	f822                	sd	s0,48(sp)
 5de:	f426                	sd	s1,40(sp)
 5e0:	f04a                	sd	s2,32(sp)
 5e2:	ec4e                	sd	s3,24(sp)
 5e4:	0080                	addi	s0,sp,64
 5e6:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5e8:	c299                	beqz	a3,5ee <printint+0x16>
 5ea:	0805c963          	bltz	a1,67c <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 5ee:	2581                	sext.w	a1,a1
  neg = 0;
 5f0:	4881                	li	a7,0
 5f2:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 5f6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5f8:	2601                	sext.w	a2,a2
 5fa:	00000517          	auipc	a0,0x0
 5fe:	5ae50513          	addi	a0,a0,1454 # ba8 <digits>
 602:	883a                	mv	a6,a4
 604:	2705                	addiw	a4,a4,1
 606:	02c5f7bb          	remuw	a5,a1,a2
 60a:	1782                	slli	a5,a5,0x20
 60c:	9381                	srli	a5,a5,0x20
 60e:	97aa                	add	a5,a5,a0
 610:	0007c783          	lbu	a5,0(a5)
 614:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 618:	0005879b          	sext.w	a5,a1
 61c:	02c5d5bb          	divuw	a1,a1,a2
 620:	0685                	addi	a3,a3,1
 622:	fec7f0e3          	bgeu	a5,a2,602 <printint+0x2a>
  if(neg)
 626:	00088c63          	beqz	a7,63e <printint+0x66>
    buf[i++] = '-';
 62a:	fd070793          	addi	a5,a4,-48
 62e:	00878733          	add	a4,a5,s0
 632:	02d00793          	li	a5,45
 636:	fef70823          	sb	a5,-16(a4)
 63a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 63e:	02e05863          	blez	a4,66e <printint+0x96>
 642:	fc040793          	addi	a5,s0,-64
 646:	00e78933          	add	s2,a5,a4
 64a:	fff78993          	addi	s3,a5,-1
 64e:	99ba                	add	s3,s3,a4
 650:	377d                	addiw	a4,a4,-1
 652:	1702                	slli	a4,a4,0x20
 654:	9301                	srli	a4,a4,0x20
 656:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 65a:	fff94583          	lbu	a1,-1(s2)
 65e:	8526                	mv	a0,s1
 660:	00000097          	auipc	ra,0x0
 664:	f56080e7          	jalr	-170(ra) # 5b6 <putc>
  while(--i >= 0)
 668:	197d                	addi	s2,s2,-1
 66a:	ff3918e3          	bne	s2,s3,65a <printint+0x82>
}
 66e:	70e2                	ld	ra,56(sp)
 670:	7442                	ld	s0,48(sp)
 672:	74a2                	ld	s1,40(sp)
 674:	7902                	ld	s2,32(sp)
 676:	69e2                	ld	s3,24(sp)
 678:	6121                	addi	sp,sp,64
 67a:	8082                	ret
    x = -xx;
 67c:	40b005bb          	negw	a1,a1
    neg = 1;
 680:	4885                	li	a7,1
    x = -xx;
 682:	bf85                	j	5f2 <printint+0x1a>

0000000000000684 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 684:	7119                	addi	sp,sp,-128
 686:	fc86                	sd	ra,120(sp)
 688:	f8a2                	sd	s0,112(sp)
 68a:	f4a6                	sd	s1,104(sp)
 68c:	f0ca                	sd	s2,96(sp)
 68e:	ecce                	sd	s3,88(sp)
 690:	e8d2                	sd	s4,80(sp)
 692:	e4d6                	sd	s5,72(sp)
 694:	e0da                	sd	s6,64(sp)
 696:	fc5e                	sd	s7,56(sp)
 698:	f862                	sd	s8,48(sp)
 69a:	f466                	sd	s9,40(sp)
 69c:	f06a                	sd	s10,32(sp)
 69e:	ec6e                	sd	s11,24(sp)
 6a0:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 6a2:	0005c903          	lbu	s2,0(a1)
 6a6:	18090f63          	beqz	s2,844 <vprintf+0x1c0>
 6aa:	8aaa                	mv	s5,a0
 6ac:	8b32                	mv	s6,a2
 6ae:	00158493          	addi	s1,a1,1
  state = 0;
 6b2:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 6b4:	02500a13          	li	s4,37
 6b8:	4c55                	li	s8,21
 6ba:	00000c97          	auipc	s9,0x0
 6be:	496c8c93          	addi	s9,s9,1174 # b50 <malloc+0x208>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 6c2:	02800d93          	li	s11,40
  putc(fd, 'x');
 6c6:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6c8:	00000b97          	auipc	s7,0x0
 6cc:	4e0b8b93          	addi	s7,s7,1248 # ba8 <digits>
 6d0:	a839                	j	6ee <vprintf+0x6a>
        putc(fd, c);
 6d2:	85ca                	mv	a1,s2
 6d4:	8556                	mv	a0,s5
 6d6:	00000097          	auipc	ra,0x0
 6da:	ee0080e7          	jalr	-288(ra) # 5b6 <putc>
 6de:	a019                	j	6e4 <vprintf+0x60>
    } else if(state == '%'){
 6e0:	01498d63          	beq	s3,s4,6fa <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 6e4:	0485                	addi	s1,s1,1
 6e6:	fff4c903          	lbu	s2,-1(s1)
 6ea:	14090d63          	beqz	s2,844 <vprintf+0x1c0>
    if(state == 0){
 6ee:	fe0999e3          	bnez	s3,6e0 <vprintf+0x5c>
      if(c == '%'){
 6f2:	ff4910e3          	bne	s2,s4,6d2 <vprintf+0x4e>
        state = '%';
 6f6:	89d2                	mv	s3,s4
 6f8:	b7f5                	j	6e4 <vprintf+0x60>
      if(c == 'd'){
 6fa:	11490c63          	beq	s2,s4,812 <vprintf+0x18e>
 6fe:	f9d9079b          	addiw	a5,s2,-99
 702:	0ff7f793          	zext.b	a5,a5
 706:	10fc6e63          	bltu	s8,a5,822 <vprintf+0x19e>
 70a:	f9d9079b          	addiw	a5,s2,-99
 70e:	0ff7f713          	zext.b	a4,a5
 712:	10ec6863          	bltu	s8,a4,822 <vprintf+0x19e>
 716:	00271793          	slli	a5,a4,0x2
 71a:	97e6                	add	a5,a5,s9
 71c:	439c                	lw	a5,0(a5)
 71e:	97e6                	add	a5,a5,s9
 720:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 722:	008b0913          	addi	s2,s6,8
 726:	4685                	li	a3,1
 728:	4629                	li	a2,10
 72a:	000b2583          	lw	a1,0(s6)
 72e:	8556                	mv	a0,s5
 730:	00000097          	auipc	ra,0x0
 734:	ea8080e7          	jalr	-344(ra) # 5d8 <printint>
 738:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 73a:	4981                	li	s3,0
 73c:	b765                	j	6e4 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 73e:	008b0913          	addi	s2,s6,8
 742:	4681                	li	a3,0
 744:	4629                	li	a2,10
 746:	000b2583          	lw	a1,0(s6)
 74a:	8556                	mv	a0,s5
 74c:	00000097          	auipc	ra,0x0
 750:	e8c080e7          	jalr	-372(ra) # 5d8 <printint>
 754:	8b4a                	mv	s6,s2
      state = 0;
 756:	4981                	li	s3,0
 758:	b771                	j	6e4 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 75a:	008b0913          	addi	s2,s6,8
 75e:	4681                	li	a3,0
 760:	866a                	mv	a2,s10
 762:	000b2583          	lw	a1,0(s6)
 766:	8556                	mv	a0,s5
 768:	00000097          	auipc	ra,0x0
 76c:	e70080e7          	jalr	-400(ra) # 5d8 <printint>
 770:	8b4a                	mv	s6,s2
      state = 0;
 772:	4981                	li	s3,0
 774:	bf85                	j	6e4 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 776:	008b0793          	addi	a5,s6,8
 77a:	f8f43423          	sd	a5,-120(s0)
 77e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 782:	03000593          	li	a1,48
 786:	8556                	mv	a0,s5
 788:	00000097          	auipc	ra,0x0
 78c:	e2e080e7          	jalr	-466(ra) # 5b6 <putc>
  putc(fd, 'x');
 790:	07800593          	li	a1,120
 794:	8556                	mv	a0,s5
 796:	00000097          	auipc	ra,0x0
 79a:	e20080e7          	jalr	-480(ra) # 5b6 <putc>
 79e:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7a0:	03c9d793          	srli	a5,s3,0x3c
 7a4:	97de                	add	a5,a5,s7
 7a6:	0007c583          	lbu	a1,0(a5)
 7aa:	8556                	mv	a0,s5
 7ac:	00000097          	auipc	ra,0x0
 7b0:	e0a080e7          	jalr	-502(ra) # 5b6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7b4:	0992                	slli	s3,s3,0x4
 7b6:	397d                	addiw	s2,s2,-1
 7b8:	fe0914e3          	bnez	s2,7a0 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 7bc:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 7c0:	4981                	li	s3,0
 7c2:	b70d                	j	6e4 <vprintf+0x60>
        s = va_arg(ap, char*);
 7c4:	008b0913          	addi	s2,s6,8
 7c8:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 7cc:	02098163          	beqz	s3,7ee <vprintf+0x16a>
        while(*s != 0){
 7d0:	0009c583          	lbu	a1,0(s3)
 7d4:	c5ad                	beqz	a1,83e <vprintf+0x1ba>
          putc(fd, *s);
 7d6:	8556                	mv	a0,s5
 7d8:	00000097          	auipc	ra,0x0
 7dc:	dde080e7          	jalr	-546(ra) # 5b6 <putc>
          s++;
 7e0:	0985                	addi	s3,s3,1
        while(*s != 0){
 7e2:	0009c583          	lbu	a1,0(s3)
 7e6:	f9e5                	bnez	a1,7d6 <vprintf+0x152>
        s = va_arg(ap, char*);
 7e8:	8b4a                	mv	s6,s2
      state = 0;
 7ea:	4981                	li	s3,0
 7ec:	bde5                	j	6e4 <vprintf+0x60>
          s = "(null)";
 7ee:	00000997          	auipc	s3,0x0
 7f2:	35a98993          	addi	s3,s3,858 # b48 <malloc+0x200>
        while(*s != 0){
 7f6:	85ee                	mv	a1,s11
 7f8:	bff9                	j	7d6 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 7fa:	008b0913          	addi	s2,s6,8
 7fe:	000b4583          	lbu	a1,0(s6)
 802:	8556                	mv	a0,s5
 804:	00000097          	auipc	ra,0x0
 808:	db2080e7          	jalr	-590(ra) # 5b6 <putc>
 80c:	8b4a                	mv	s6,s2
      state = 0;
 80e:	4981                	li	s3,0
 810:	bdd1                	j	6e4 <vprintf+0x60>
        putc(fd, c);
 812:	85d2                	mv	a1,s4
 814:	8556                	mv	a0,s5
 816:	00000097          	auipc	ra,0x0
 81a:	da0080e7          	jalr	-608(ra) # 5b6 <putc>
      state = 0;
 81e:	4981                	li	s3,0
 820:	b5d1                	j	6e4 <vprintf+0x60>
        putc(fd, '%');
 822:	85d2                	mv	a1,s4
 824:	8556                	mv	a0,s5
 826:	00000097          	auipc	ra,0x0
 82a:	d90080e7          	jalr	-624(ra) # 5b6 <putc>
        putc(fd, c);
 82e:	85ca                	mv	a1,s2
 830:	8556                	mv	a0,s5
 832:	00000097          	auipc	ra,0x0
 836:	d84080e7          	jalr	-636(ra) # 5b6 <putc>
      state = 0;
 83a:	4981                	li	s3,0
 83c:	b565                	j	6e4 <vprintf+0x60>
        s = va_arg(ap, char*);
 83e:	8b4a                	mv	s6,s2
      state = 0;
 840:	4981                	li	s3,0
 842:	b54d                	j	6e4 <vprintf+0x60>
    }
  }
}
 844:	70e6                	ld	ra,120(sp)
 846:	7446                	ld	s0,112(sp)
 848:	74a6                	ld	s1,104(sp)
 84a:	7906                	ld	s2,96(sp)
 84c:	69e6                	ld	s3,88(sp)
 84e:	6a46                	ld	s4,80(sp)
 850:	6aa6                	ld	s5,72(sp)
 852:	6b06                	ld	s6,64(sp)
 854:	7be2                	ld	s7,56(sp)
 856:	7c42                	ld	s8,48(sp)
 858:	7ca2                	ld	s9,40(sp)
 85a:	7d02                	ld	s10,32(sp)
 85c:	6de2                	ld	s11,24(sp)
 85e:	6109                	addi	sp,sp,128
 860:	8082                	ret

0000000000000862 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 862:	715d                	addi	sp,sp,-80
 864:	ec06                	sd	ra,24(sp)
 866:	e822                	sd	s0,16(sp)
 868:	1000                	addi	s0,sp,32
 86a:	e010                	sd	a2,0(s0)
 86c:	e414                	sd	a3,8(s0)
 86e:	e818                	sd	a4,16(s0)
 870:	ec1c                	sd	a5,24(s0)
 872:	03043023          	sd	a6,32(s0)
 876:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 87a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 87e:	8622                	mv	a2,s0
 880:	00000097          	auipc	ra,0x0
 884:	e04080e7          	jalr	-508(ra) # 684 <vprintf>
}
 888:	60e2                	ld	ra,24(sp)
 88a:	6442                	ld	s0,16(sp)
 88c:	6161                	addi	sp,sp,80
 88e:	8082                	ret

0000000000000890 <printf>:

void
printf(const char *fmt, ...)
{
 890:	711d                	addi	sp,sp,-96
 892:	ec06                	sd	ra,24(sp)
 894:	e822                	sd	s0,16(sp)
 896:	1000                	addi	s0,sp,32
 898:	e40c                	sd	a1,8(s0)
 89a:	e810                	sd	a2,16(s0)
 89c:	ec14                	sd	a3,24(s0)
 89e:	f018                	sd	a4,32(s0)
 8a0:	f41c                	sd	a5,40(s0)
 8a2:	03043823          	sd	a6,48(s0)
 8a6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8aa:	00840613          	addi	a2,s0,8
 8ae:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8b2:	85aa                	mv	a1,a0
 8b4:	4505                	li	a0,1
 8b6:	00000097          	auipc	ra,0x0
 8ba:	dce080e7          	jalr	-562(ra) # 684 <vprintf>
}
 8be:	60e2                	ld	ra,24(sp)
 8c0:	6442                	ld	s0,16(sp)
 8c2:	6125                	addi	sp,sp,96
 8c4:	8082                	ret

00000000000008c6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8c6:	1141                	addi	sp,sp,-16
 8c8:	e422                	sd	s0,8(sp)
 8ca:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8cc:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8d0:	00000797          	auipc	a5,0x0
 8d4:	2f87b783          	ld	a5,760(a5) # bc8 <freep>
 8d8:	a02d                	j	902 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8da:	4618                	lw	a4,8(a2)
 8dc:	9f2d                	addw	a4,a4,a1
 8de:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8e2:	6398                	ld	a4,0(a5)
 8e4:	6310                	ld	a2,0(a4)
 8e6:	a83d                	j	924 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8e8:	ff852703          	lw	a4,-8(a0)
 8ec:	9f31                	addw	a4,a4,a2
 8ee:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8f0:	ff053683          	ld	a3,-16(a0)
 8f4:	a091                	j	938 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8f6:	6398                	ld	a4,0(a5)
 8f8:	00e7e463          	bltu	a5,a4,900 <free+0x3a>
 8fc:	00e6ea63          	bltu	a3,a4,910 <free+0x4a>
{
 900:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 902:	fed7fae3          	bgeu	a5,a3,8f6 <free+0x30>
 906:	6398                	ld	a4,0(a5)
 908:	00e6e463          	bltu	a3,a4,910 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 90c:	fee7eae3          	bltu	a5,a4,900 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 910:	ff852583          	lw	a1,-8(a0)
 914:	6390                	ld	a2,0(a5)
 916:	02059813          	slli	a6,a1,0x20
 91a:	01c85713          	srli	a4,a6,0x1c
 91e:	9736                	add	a4,a4,a3
 920:	fae60de3          	beq	a2,a4,8da <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 924:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 928:	4790                	lw	a2,8(a5)
 92a:	02061593          	slli	a1,a2,0x20
 92e:	01c5d713          	srli	a4,a1,0x1c
 932:	973e                	add	a4,a4,a5
 934:	fae68ae3          	beq	a3,a4,8e8 <free+0x22>
    p->s.ptr = bp->s.ptr;
 938:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 93a:	00000717          	auipc	a4,0x0
 93e:	28f73723          	sd	a5,654(a4) # bc8 <freep>
}
 942:	6422                	ld	s0,8(sp)
 944:	0141                	addi	sp,sp,16
 946:	8082                	ret

0000000000000948 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 948:	7139                	addi	sp,sp,-64
 94a:	fc06                	sd	ra,56(sp)
 94c:	f822                	sd	s0,48(sp)
 94e:	f426                	sd	s1,40(sp)
 950:	f04a                	sd	s2,32(sp)
 952:	ec4e                	sd	s3,24(sp)
 954:	e852                	sd	s4,16(sp)
 956:	e456                	sd	s5,8(sp)
 958:	e05a                	sd	s6,0(sp)
 95a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 95c:	02051493          	slli	s1,a0,0x20
 960:	9081                	srli	s1,s1,0x20
 962:	04bd                	addi	s1,s1,15
 964:	8091                	srli	s1,s1,0x4
 966:	0014899b          	addiw	s3,s1,1
 96a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 96c:	00000517          	auipc	a0,0x0
 970:	25c53503          	ld	a0,604(a0) # bc8 <freep>
 974:	c515                	beqz	a0,9a0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 976:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 978:	4798                	lw	a4,8(a5)
 97a:	02977f63          	bgeu	a4,s1,9b8 <malloc+0x70>
 97e:	8a4e                	mv	s4,s3
 980:	0009871b          	sext.w	a4,s3
 984:	6685                	lui	a3,0x1
 986:	00d77363          	bgeu	a4,a3,98c <malloc+0x44>
 98a:	6a05                	lui	s4,0x1
 98c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 990:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 994:	00000917          	auipc	s2,0x0
 998:	23490913          	addi	s2,s2,564 # bc8 <freep>
  if(p == (char*)-1)
 99c:	5afd                	li	s5,-1
 99e:	a895                	j	a12 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 9a0:	00000797          	auipc	a5,0x0
 9a4:	23078793          	addi	a5,a5,560 # bd0 <base>
 9a8:	00000717          	auipc	a4,0x0
 9ac:	22f73023          	sd	a5,544(a4) # bc8 <freep>
 9b0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9b2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9b6:	b7e1                	j	97e <malloc+0x36>
      if(p->s.size == nunits)
 9b8:	02e48c63          	beq	s1,a4,9f0 <malloc+0xa8>
        p->s.size -= nunits;
 9bc:	4137073b          	subw	a4,a4,s3
 9c0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9c2:	02071693          	slli	a3,a4,0x20
 9c6:	01c6d713          	srli	a4,a3,0x1c
 9ca:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9cc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9d0:	00000717          	auipc	a4,0x0
 9d4:	1ea73c23          	sd	a0,504(a4) # bc8 <freep>
      return (void*)(p + 1);
 9d8:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 9dc:	70e2                	ld	ra,56(sp)
 9de:	7442                	ld	s0,48(sp)
 9e0:	74a2                	ld	s1,40(sp)
 9e2:	7902                	ld	s2,32(sp)
 9e4:	69e2                	ld	s3,24(sp)
 9e6:	6a42                	ld	s4,16(sp)
 9e8:	6aa2                	ld	s5,8(sp)
 9ea:	6b02                	ld	s6,0(sp)
 9ec:	6121                	addi	sp,sp,64
 9ee:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 9f0:	6398                	ld	a4,0(a5)
 9f2:	e118                	sd	a4,0(a0)
 9f4:	bff1                	j	9d0 <malloc+0x88>
  hp->s.size = nu;
 9f6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9fa:	0541                	addi	a0,a0,16
 9fc:	00000097          	auipc	ra,0x0
 a00:	eca080e7          	jalr	-310(ra) # 8c6 <free>
  return freep;
 a04:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a08:	d971                	beqz	a0,9dc <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a0a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a0c:	4798                	lw	a4,8(a5)
 a0e:	fa9775e3          	bgeu	a4,s1,9b8 <malloc+0x70>
    if(p == freep)
 a12:	00093703          	ld	a4,0(s2)
 a16:	853e                	mv	a0,a5
 a18:	fef719e3          	bne	a4,a5,a0a <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 a1c:	8552                	mv	a0,s4
 a1e:	00000097          	auipc	ra,0x0
 a22:	b58080e7          	jalr	-1192(ra) # 576 <sbrk>
  if(p == (char*)-1)
 a26:	fd5518e3          	bne	a0,s5,9f6 <malloc+0xae>
        return 0;
 a2a:	4501                	li	a0,0
 a2c:	bf45                	j	9dc <malloc+0x94>
