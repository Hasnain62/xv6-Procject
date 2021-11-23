
user/_userspace3:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int main(){
   0:	bf010113          	addi	sp,sp,-1040
   4:	40113423          	sd	ra,1032(sp)
   8:	40813023          	sd	s0,1024(sp)
   c:	3e913c23          	sd	s1,1016(sp)
  10:	3f213823          	sd	s2,1008(sp)
  14:	41010413          	addi	s0,sp,1040

topic_t mytag3 = tag3;
//topic_t mytag2 = tag2;
char message1[140] = " 1 Dil mai ata hun Samaj mei nahi";
  18:	02200613          	li	a2,34
  1c:	00001597          	auipc	a1,0x1
  20:	98c58593          	addi	a1,a1,-1652 # 9a8 <malloc+0xea>
  24:	f5040513          	addi	a0,s0,-176
  28:	00000097          	auipc	ra,0x0
  2c:	41c080e7          	jalr	1052(ra) # 444 <memcpy>
  30:	06a00613          	li	a2,106
  34:	4581                	li	a1,0
  36:	f7240513          	addi	a0,s0,-142
  3a:	00000097          	auipc	ra,0x0
  3e:	230080e7          	jalr	560(ra) # 26a <memset>
topic_t mytag4 = tag4;
char message2[140] = "2 Zamana Humse hai Hum Zamane Se Nahin";
  42:	02700613          	li	a2,39
  46:	00001597          	auipc	a1,0x1
  4a:	98a58593          	addi	a1,a1,-1654 # 9d0 <malloc+0x112>
  4e:	ec040513          	addi	a0,s0,-320
  52:	00000097          	auipc	ra,0x0
  56:	3f2080e7          	jalr	1010(ra) # 444 <memcpy>
  5a:	06500613          	li	a2,101
  5e:	4581                	li	a1,0
  60:	ee740513          	addi	a0,s0,-281
  64:	00000097          	auipc	ra,0x0
  68:	206080e7          	jalr	518(ra) # 26a <memset>
char message3[140] = "3 Sonna Zara Neede tou hona";
  6c:	4671                	li	a2,28
  6e:	00001597          	auipc	a1,0x1
  72:	98a58593          	addi	a1,a1,-1654 # 9f8 <malloc+0x13a>
  76:	e3040513          	addi	a0,s0,-464
  7a:	00000097          	auipc	ra,0x0
  7e:	3ca080e7          	jalr	970(ra) # 444 <memcpy>
  82:	07000613          	li	a2,112
  86:	4581                	li	a1,0
  88:	e4c40513          	addi	a0,s0,-436
  8c:	00000097          	auipc	ra,0x0
  90:	1de080e7          	jalr	478(ra) # 26a <memset>
char message4[140] = "4 Dil mera muft ka";
  94:	464d                	li	a2,19
  96:	00001597          	auipc	a1,0x1
  9a:	98258593          	addi	a1,a1,-1662 # a18 <malloc+0x15a>
  9e:	da040513          	addi	a0,s0,-608
  a2:	00000097          	auipc	ra,0x0
  a6:	3a2080e7          	jalr	930(ra) # 444 <memcpy>
  aa:	07900613          	li	a2,121
  ae:	4581                	li	a1,0
  b0:	db340513          	addi	a0,s0,-589
  b4:	00000097          	auipc	ra,0x0
  b8:	1b6080e7          	jalr	438(ra) # 26a <memset>
char message5[140] = "5 Are aao na Ki jaan gayi , Sojao";
  bc:	02200613          	li	a2,34
  c0:	00001597          	auipc	a1,0x1
  c4:	97058593          	addi	a1,a1,-1680 # a30 <malloc+0x172>
  c8:	d1040513          	addi	a0,s0,-752
  cc:	00000097          	auipc	ra,0x0
  d0:	378080e7          	jalr	888(ra) # 444 <memcpy>
  d4:	06a00613          	li	a2,106
  d8:	4581                	li	a1,0
  da:	d3240513          	addi	a0,s0,-718
  de:	00000097          	auipc	ra,0x0
  e2:	18c080e7          	jalr	396(ra) # 26a <memset>
char message6[140] = "6 Ye Zindagi kisi muflis ki bad dua he sahi";
  e6:	02c00613          	li	a2,44
  ea:	00001597          	auipc	a1,0x1
  ee:	96e58593          	addi	a1,a1,-1682 # a58 <malloc+0x19a>
  f2:	c8040513          	addi	a0,s0,-896
  f6:	00000097          	auipc	ra,0x0
  fa:	34e080e7          	jalr	846(ra) # 444 <memcpy>
  fe:	06000613          	li	a2,96
 102:	4581                	li	a1,0
 104:	cac40513          	addi	a0,s0,-852
 108:	00000097          	auipc	ra,0x0
 10c:	162080e7          	jalr	354(ra) # 26a <memset>
char message7[140] = "7 Yun he chala chal rahi";
 110:	4665                	li	a2,25
 112:	00001597          	auipc	a1,0x1
 116:	97658593          	addi	a1,a1,-1674 # a88 <malloc+0x1ca>
 11a:	bf040513          	addi	a0,s0,-1040
 11e:	00000097          	auipc	ra,0x0
 122:	326080e7          	jalr	806(ra) # 444 <memcpy>
 126:	07300613          	li	a2,115
 12a:	4581                	li	a1,0
 12c:	c0940513          	addi	a0,s0,-1015
 130:	00000097          	auipc	ra,0x0
 134:	13a080e7          	jalr	314(ra) # 26a <memset>
//char message8[140] = "8 All is Well";

char *buf = malloc(140);
 138:	08c00513          	li	a0,140
 13c:	00000097          	auipc	ra,0x0
 140:	782080e7          	jalr	1922(ra) # 8be <malloc>
 144:	892a                	mv	s2,a0
char *buf2 = malloc(140);
 146:	08c00513          	li	a0,140
 14a:	00000097          	auipc	ra,0x0
 14e:	774080e7          	jalr	1908(ra) # 8be <malloc>
 152:	84aa                	mv	s1,a0

    // 
    // btget(mytag,buf);

    // Testing if it waits when maxtweettotal hits
btput(mytag3, message1);
 154:	f5040593          	addi	a1,s0,-176
 158:	4509                	li	a0,2
 15a:	00000097          	auipc	ra,0x0
 15e:	3b2080e7          	jalr	946(ra) # 50c <btput>
btput(mytag4,message2);
 162:	ec040593          	addi	a1,s0,-320
 166:	450d                	li	a0,3
 168:	00000097          	auipc	ra,0x0
 16c:	3a4080e7          	jalr	932(ra) # 50c <btput>
btput(mytag3,message3);
 170:	e3040593          	addi	a1,s0,-464
 174:	4509                	li	a0,2
 176:	00000097          	auipc	ra,0x0
 17a:	396080e7          	jalr	918(ra) # 50c <btput>
btput(mytag4,message4);
 17e:	da040593          	addi	a1,s0,-608
 182:	450d                	li	a0,3
 184:	00000097          	auipc	ra,0x0
 188:	388080e7          	jalr	904(ra) # 50c <btput>
btput(mytag3,message5);
 18c:	d1040593          	addi	a1,s0,-752
 190:	4509                	li	a0,2
 192:	00000097          	auipc	ra,0x0
 196:	37a080e7          	jalr	890(ra) # 50c <btput>



int rc = fork();
 19a:	00000097          	auipc	ra,0x0
 19e:	2c2080e7          	jalr	706(ra) # 45c <fork>

if (rc==0){
 1a2:	cd05                	beqz	a0,1da <main+0x1da>
  btput(mytag4,message6);
  btput(mytag4,message7);

}

  btget(mytag3,buf);
 1a4:	85ca                	mv	a1,s2
 1a6:	4509                	li	a0,2
 1a8:	00000097          	auipc	ra,0x0
 1ac:	374080e7          	jalr	884(ra) # 51c <btget>
  btget(mytag3,buf2);
 1b0:	85a6                	mv	a1,s1
 1b2:	4509                	li	a0,2
 1b4:	00000097          	auipc	ra,0x0
 1b8:	368080e7          	jalr	872(ra) # 51c <btget>
  // btput(mytag2,message8);




    free(buf);
 1bc:	854a                	mv	a0,s2
 1be:	00000097          	auipc	ra,0x0
 1c2:	67e080e7          	jalr	1662(ra) # 83c <free>
    free(buf2);
 1c6:	8526                	mv	a0,s1
 1c8:	00000097          	auipc	ra,0x0
 1cc:	674080e7          	jalr	1652(ra) # 83c <free>
    exit(0);
 1d0:	4501                	li	a0,0
 1d2:	00000097          	auipc	ra,0x0
 1d6:	292080e7          	jalr	658(ra) # 464 <exit>
  btput(mytag4,message6);
 1da:	c8040593          	addi	a1,s0,-896
 1de:	450d                	li	a0,3
 1e0:	00000097          	auipc	ra,0x0
 1e4:	32c080e7          	jalr	812(ra) # 50c <btput>
  btput(mytag4,message7);
 1e8:	bf040593          	addi	a1,s0,-1040
 1ec:	450d                	li	a0,3
 1ee:	00000097          	auipc	ra,0x0
 1f2:	31e080e7          	jalr	798(ra) # 50c <btput>
 1f6:	b77d                	j	1a4 <main+0x1a4>

00000000000001f8 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 1f8:	1141                	addi	sp,sp,-16
 1fa:	e422                	sd	s0,8(sp)
 1fc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1fe:	87aa                	mv	a5,a0
 200:	0585                	addi	a1,a1,1
 202:	0785                	addi	a5,a5,1
 204:	fff5c703          	lbu	a4,-1(a1)
 208:	fee78fa3          	sb	a4,-1(a5)
 20c:	fb75                	bnez	a4,200 <strcpy+0x8>
    ;
  return os;
}
 20e:	6422                	ld	s0,8(sp)
 210:	0141                	addi	sp,sp,16
 212:	8082                	ret

0000000000000214 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 214:	1141                	addi	sp,sp,-16
 216:	e422                	sd	s0,8(sp)
 218:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 21a:	00054783          	lbu	a5,0(a0)
 21e:	cb91                	beqz	a5,232 <strcmp+0x1e>
 220:	0005c703          	lbu	a4,0(a1)
 224:	00f71763          	bne	a4,a5,232 <strcmp+0x1e>
    p++, q++;
 228:	0505                	addi	a0,a0,1
 22a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 22c:	00054783          	lbu	a5,0(a0)
 230:	fbe5                	bnez	a5,220 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 232:	0005c503          	lbu	a0,0(a1)
}
 236:	40a7853b          	subw	a0,a5,a0
 23a:	6422                	ld	s0,8(sp)
 23c:	0141                	addi	sp,sp,16
 23e:	8082                	ret

0000000000000240 <strlen>:

uint
strlen(const char *s)
{
 240:	1141                	addi	sp,sp,-16
 242:	e422                	sd	s0,8(sp)
 244:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 246:	00054783          	lbu	a5,0(a0)
 24a:	cf91                	beqz	a5,266 <strlen+0x26>
 24c:	0505                	addi	a0,a0,1
 24e:	87aa                	mv	a5,a0
 250:	4685                	li	a3,1
 252:	9e89                	subw	a3,a3,a0
 254:	00f6853b          	addw	a0,a3,a5
 258:	0785                	addi	a5,a5,1
 25a:	fff7c703          	lbu	a4,-1(a5)
 25e:	fb7d                	bnez	a4,254 <strlen+0x14>
    ;
  return n;
}
 260:	6422                	ld	s0,8(sp)
 262:	0141                	addi	sp,sp,16
 264:	8082                	ret
  for(n = 0; s[n]; n++)
 266:	4501                	li	a0,0
 268:	bfe5                	j	260 <strlen+0x20>

000000000000026a <memset>:

void*
memset(void *dst, int c, uint n)
{
 26a:	1141                	addi	sp,sp,-16
 26c:	e422                	sd	s0,8(sp)
 26e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 270:	ca19                	beqz	a2,286 <memset+0x1c>
 272:	87aa                	mv	a5,a0
 274:	1602                	slli	a2,a2,0x20
 276:	9201                	srli	a2,a2,0x20
 278:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 27c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 280:	0785                	addi	a5,a5,1
 282:	fee79de3          	bne	a5,a4,27c <memset+0x12>
  }
  return dst;
}
 286:	6422                	ld	s0,8(sp)
 288:	0141                	addi	sp,sp,16
 28a:	8082                	ret

000000000000028c <strchr>:

char*
strchr(const char *s, char c)
{
 28c:	1141                	addi	sp,sp,-16
 28e:	e422                	sd	s0,8(sp)
 290:	0800                	addi	s0,sp,16
  for(; *s; s++)
 292:	00054783          	lbu	a5,0(a0)
 296:	cb99                	beqz	a5,2ac <strchr+0x20>
    if(*s == c)
 298:	00f58763          	beq	a1,a5,2a6 <strchr+0x1a>
  for(; *s; s++)
 29c:	0505                	addi	a0,a0,1
 29e:	00054783          	lbu	a5,0(a0)
 2a2:	fbfd                	bnez	a5,298 <strchr+0xc>
      return (char*)s;
  return 0;
 2a4:	4501                	li	a0,0
}
 2a6:	6422                	ld	s0,8(sp)
 2a8:	0141                	addi	sp,sp,16
 2aa:	8082                	ret
  return 0;
 2ac:	4501                	li	a0,0
 2ae:	bfe5                	j	2a6 <strchr+0x1a>

00000000000002b0 <gets>:

char*
gets(char *buf, int max)
{
 2b0:	711d                	addi	sp,sp,-96
 2b2:	ec86                	sd	ra,88(sp)
 2b4:	e8a2                	sd	s0,80(sp)
 2b6:	e4a6                	sd	s1,72(sp)
 2b8:	e0ca                	sd	s2,64(sp)
 2ba:	fc4e                	sd	s3,56(sp)
 2bc:	f852                	sd	s4,48(sp)
 2be:	f456                	sd	s5,40(sp)
 2c0:	f05a                	sd	s6,32(sp)
 2c2:	ec5e                	sd	s7,24(sp)
 2c4:	1080                	addi	s0,sp,96
 2c6:	8baa                	mv	s7,a0
 2c8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2ca:	892a                	mv	s2,a0
 2cc:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2ce:	4aa9                	li	s5,10
 2d0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2d2:	89a6                	mv	s3,s1
 2d4:	2485                	addiw	s1,s1,1
 2d6:	0344d863          	bge	s1,s4,306 <gets+0x56>
    cc = read(0, &c, 1);
 2da:	4605                	li	a2,1
 2dc:	faf40593          	addi	a1,s0,-81
 2e0:	4501                	li	a0,0
 2e2:	00000097          	auipc	ra,0x0
 2e6:	19a080e7          	jalr	410(ra) # 47c <read>
    if(cc < 1)
 2ea:	00a05e63          	blez	a0,306 <gets+0x56>
    buf[i++] = c;
 2ee:	faf44783          	lbu	a5,-81(s0)
 2f2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2f6:	01578763          	beq	a5,s5,304 <gets+0x54>
 2fa:	0905                	addi	s2,s2,1
 2fc:	fd679be3          	bne	a5,s6,2d2 <gets+0x22>
  for(i=0; i+1 < max; ){
 300:	89a6                	mv	s3,s1
 302:	a011                	j	306 <gets+0x56>
 304:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 306:	99de                	add	s3,s3,s7
 308:	00098023          	sb	zero,0(s3)
  return buf;
}
 30c:	855e                	mv	a0,s7
 30e:	60e6                	ld	ra,88(sp)
 310:	6446                	ld	s0,80(sp)
 312:	64a6                	ld	s1,72(sp)
 314:	6906                	ld	s2,64(sp)
 316:	79e2                	ld	s3,56(sp)
 318:	7a42                	ld	s4,48(sp)
 31a:	7aa2                	ld	s5,40(sp)
 31c:	7b02                	ld	s6,32(sp)
 31e:	6be2                	ld	s7,24(sp)
 320:	6125                	addi	sp,sp,96
 322:	8082                	ret

0000000000000324 <stat>:

int
stat(const char *n, struct stat *st)
{
 324:	1101                	addi	sp,sp,-32
 326:	ec06                	sd	ra,24(sp)
 328:	e822                	sd	s0,16(sp)
 32a:	e426                	sd	s1,8(sp)
 32c:	e04a                	sd	s2,0(sp)
 32e:	1000                	addi	s0,sp,32
 330:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 332:	4581                	li	a1,0
 334:	00000097          	auipc	ra,0x0
 338:	170080e7          	jalr	368(ra) # 4a4 <open>
  if(fd < 0)
 33c:	02054563          	bltz	a0,366 <stat+0x42>
 340:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 342:	85ca                	mv	a1,s2
 344:	00000097          	auipc	ra,0x0
 348:	178080e7          	jalr	376(ra) # 4bc <fstat>
 34c:	892a                	mv	s2,a0
  close(fd);
 34e:	8526                	mv	a0,s1
 350:	00000097          	auipc	ra,0x0
 354:	13c080e7          	jalr	316(ra) # 48c <close>
  return r;
}
 358:	854a                	mv	a0,s2
 35a:	60e2                	ld	ra,24(sp)
 35c:	6442                	ld	s0,16(sp)
 35e:	64a2                	ld	s1,8(sp)
 360:	6902                	ld	s2,0(sp)
 362:	6105                	addi	sp,sp,32
 364:	8082                	ret
    return -1;
 366:	597d                	li	s2,-1
 368:	bfc5                	j	358 <stat+0x34>

000000000000036a <atoi>:

int
atoi(const char *s)
{
 36a:	1141                	addi	sp,sp,-16
 36c:	e422                	sd	s0,8(sp)
 36e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 370:	00054683          	lbu	a3,0(a0)
 374:	fd06879b          	addiw	a5,a3,-48
 378:	0ff7f793          	zext.b	a5,a5
 37c:	4625                	li	a2,9
 37e:	02f66863          	bltu	a2,a5,3ae <atoi+0x44>
 382:	872a                	mv	a4,a0
  n = 0;
 384:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 386:	0705                	addi	a4,a4,1
 388:	0025179b          	slliw	a5,a0,0x2
 38c:	9fa9                	addw	a5,a5,a0
 38e:	0017979b          	slliw	a5,a5,0x1
 392:	9fb5                	addw	a5,a5,a3
 394:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 398:	00074683          	lbu	a3,0(a4)
 39c:	fd06879b          	addiw	a5,a3,-48
 3a0:	0ff7f793          	zext.b	a5,a5
 3a4:	fef671e3          	bgeu	a2,a5,386 <atoi+0x1c>
  return n;
}
 3a8:	6422                	ld	s0,8(sp)
 3aa:	0141                	addi	sp,sp,16
 3ac:	8082                	ret
  n = 0;
 3ae:	4501                	li	a0,0
 3b0:	bfe5                	j	3a8 <atoi+0x3e>

00000000000003b2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3b2:	1141                	addi	sp,sp,-16
 3b4:	e422                	sd	s0,8(sp)
 3b6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3b8:	02b57463          	bgeu	a0,a1,3e0 <memmove+0x2e>
    while(n-- > 0)
 3bc:	00c05f63          	blez	a2,3da <memmove+0x28>
 3c0:	1602                	slli	a2,a2,0x20
 3c2:	9201                	srli	a2,a2,0x20
 3c4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3c8:	872a                	mv	a4,a0
      *dst++ = *src++;
 3ca:	0585                	addi	a1,a1,1
 3cc:	0705                	addi	a4,a4,1
 3ce:	fff5c683          	lbu	a3,-1(a1)
 3d2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3d6:	fee79ae3          	bne	a5,a4,3ca <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3da:	6422                	ld	s0,8(sp)
 3dc:	0141                	addi	sp,sp,16
 3de:	8082                	ret
    dst += n;
 3e0:	00c50733          	add	a4,a0,a2
    src += n;
 3e4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3e6:	fec05ae3          	blez	a2,3da <memmove+0x28>
 3ea:	fff6079b          	addiw	a5,a2,-1
 3ee:	1782                	slli	a5,a5,0x20
 3f0:	9381                	srli	a5,a5,0x20
 3f2:	fff7c793          	not	a5,a5
 3f6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3f8:	15fd                	addi	a1,a1,-1
 3fa:	177d                	addi	a4,a4,-1
 3fc:	0005c683          	lbu	a3,0(a1)
 400:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 404:	fee79ae3          	bne	a5,a4,3f8 <memmove+0x46>
 408:	bfc9                	j	3da <memmove+0x28>

000000000000040a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 40a:	1141                	addi	sp,sp,-16
 40c:	e422                	sd	s0,8(sp)
 40e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 410:	ca05                	beqz	a2,440 <memcmp+0x36>
 412:	fff6069b          	addiw	a3,a2,-1
 416:	1682                	slli	a3,a3,0x20
 418:	9281                	srli	a3,a3,0x20
 41a:	0685                	addi	a3,a3,1
 41c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 41e:	00054783          	lbu	a5,0(a0)
 422:	0005c703          	lbu	a4,0(a1)
 426:	00e79863          	bne	a5,a4,436 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 42a:	0505                	addi	a0,a0,1
    p2++;
 42c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 42e:	fed518e3          	bne	a0,a3,41e <memcmp+0x14>
  }
  return 0;
 432:	4501                	li	a0,0
 434:	a019                	j	43a <memcmp+0x30>
      return *p1 - *p2;
 436:	40e7853b          	subw	a0,a5,a4
}
 43a:	6422                	ld	s0,8(sp)
 43c:	0141                	addi	sp,sp,16
 43e:	8082                	ret
  return 0;
 440:	4501                	li	a0,0
 442:	bfe5                	j	43a <memcmp+0x30>

0000000000000444 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 444:	1141                	addi	sp,sp,-16
 446:	e406                	sd	ra,8(sp)
 448:	e022                	sd	s0,0(sp)
 44a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 44c:	00000097          	auipc	ra,0x0
 450:	f66080e7          	jalr	-154(ra) # 3b2 <memmove>
}
 454:	60a2                	ld	ra,8(sp)
 456:	6402                	ld	s0,0(sp)
 458:	0141                	addi	sp,sp,16
 45a:	8082                	ret

000000000000045c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 45c:	4885                	li	a7,1
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <exit>:
.global exit
exit:
 li a7, SYS_exit
 464:	4889                	li	a7,2
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <wait>:
.global wait
wait:
 li a7, SYS_wait
 46c:	488d                	li	a7,3
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 474:	4891                	li	a7,4
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <read>:
.global read
read:
 li a7, SYS_read
 47c:	4895                	li	a7,5
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <write>:
.global write
write:
 li a7, SYS_write
 484:	48c1                	li	a7,16
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <close>:
.global close
close:
 li a7, SYS_close
 48c:	48d5                	li	a7,21
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <kill>:
.global kill
kill:
 li a7, SYS_kill
 494:	4899                	li	a7,6
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <exec>:
.global exec
exec:
 li a7, SYS_exec
 49c:	489d                	li	a7,7
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <open>:
.global open
open:
 li a7, SYS_open
 4a4:	48bd                	li	a7,15
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4ac:	48c5                	li	a7,17
 ecall
 4ae:	00000073          	ecall
 ret
 4b2:	8082                	ret

00000000000004b4 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4b4:	48c9                	li	a7,18
 ecall
 4b6:	00000073          	ecall
 ret
 4ba:	8082                	ret

00000000000004bc <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4bc:	48a1                	li	a7,8
 ecall
 4be:	00000073          	ecall
 ret
 4c2:	8082                	ret

00000000000004c4 <link>:
.global link
link:
 li a7, SYS_link
 4c4:	48cd                	li	a7,19
 ecall
 4c6:	00000073          	ecall
 ret
 4ca:	8082                	ret

00000000000004cc <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4cc:	48d1                	li	a7,20
 ecall
 4ce:	00000073          	ecall
 ret
 4d2:	8082                	ret

00000000000004d4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4d4:	48a5                	li	a7,9
 ecall
 4d6:	00000073          	ecall
 ret
 4da:	8082                	ret

00000000000004dc <dup>:
.global dup
dup:
 li a7, SYS_dup
 4dc:	48a9                	li	a7,10
 ecall
 4de:	00000073          	ecall
 ret
 4e2:	8082                	ret

00000000000004e4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4e4:	48ad                	li	a7,11
 ecall
 4e6:	00000073          	ecall
 ret
 4ea:	8082                	ret

00000000000004ec <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4ec:	48b1                	li	a7,12
 ecall
 4ee:	00000073          	ecall
 ret
 4f2:	8082                	ret

00000000000004f4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4f4:	48b5                	li	a7,13
 ecall
 4f6:	00000073          	ecall
 ret
 4fa:	8082                	ret

00000000000004fc <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4fc:	48b9                	li	a7,14
 ecall
 4fe:	00000073          	ecall
 ret
 502:	8082                	ret

0000000000000504 <waitstat>:
.global waitstat
waitstat:
 li a7, SYS_waitstat
 504:	48d9                	li	a7,22
 ecall
 506:	00000073          	ecall
 ret
 50a:	8082                	ret

000000000000050c <btput>:
.global btput
btput:
 li a7, SYS_btput
 50c:	48dd                	li	a7,23
 ecall
 50e:	00000073          	ecall
 ret
 512:	8082                	ret

0000000000000514 <tput>:
.global tput
tput:
 li a7, SYS_tput
 514:	48e1                	li	a7,24
 ecall
 516:	00000073          	ecall
 ret
 51a:	8082                	ret

000000000000051c <btget>:
.global btget
btget:
 li a7, SYS_btget
 51c:	48e5                	li	a7,25
 ecall
 51e:	00000073          	ecall
 ret
 522:	8082                	ret

0000000000000524 <tget>:
.global tget
tget:
 li a7, SYS_tget
 524:	48e9                	li	a7,26
 ecall
 526:	00000073          	ecall
 ret
 52a:	8082                	ret

000000000000052c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 52c:	1101                	addi	sp,sp,-32
 52e:	ec06                	sd	ra,24(sp)
 530:	e822                	sd	s0,16(sp)
 532:	1000                	addi	s0,sp,32
 534:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 538:	4605                	li	a2,1
 53a:	fef40593          	addi	a1,s0,-17
 53e:	00000097          	auipc	ra,0x0
 542:	f46080e7          	jalr	-186(ra) # 484 <write>
}
 546:	60e2                	ld	ra,24(sp)
 548:	6442                	ld	s0,16(sp)
 54a:	6105                	addi	sp,sp,32
 54c:	8082                	ret

000000000000054e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 54e:	7139                	addi	sp,sp,-64
 550:	fc06                	sd	ra,56(sp)
 552:	f822                	sd	s0,48(sp)
 554:	f426                	sd	s1,40(sp)
 556:	f04a                	sd	s2,32(sp)
 558:	ec4e                	sd	s3,24(sp)
 55a:	0080                	addi	s0,sp,64
 55c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 55e:	c299                	beqz	a3,564 <printint+0x16>
 560:	0805c963          	bltz	a1,5f2 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 564:	2581                	sext.w	a1,a1
  neg = 0;
 566:	4881                	li	a7,0
 568:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 56c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 56e:	2601                	sext.w	a2,a2
 570:	00000517          	auipc	a0,0x0
 574:	59850513          	addi	a0,a0,1432 # b08 <digits>
 578:	883a                	mv	a6,a4
 57a:	2705                	addiw	a4,a4,1
 57c:	02c5f7bb          	remuw	a5,a1,a2
 580:	1782                	slli	a5,a5,0x20
 582:	9381                	srli	a5,a5,0x20
 584:	97aa                	add	a5,a5,a0
 586:	0007c783          	lbu	a5,0(a5)
 58a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 58e:	0005879b          	sext.w	a5,a1
 592:	02c5d5bb          	divuw	a1,a1,a2
 596:	0685                	addi	a3,a3,1
 598:	fec7f0e3          	bgeu	a5,a2,578 <printint+0x2a>
  if(neg)
 59c:	00088c63          	beqz	a7,5b4 <printint+0x66>
    buf[i++] = '-';
 5a0:	fd070793          	addi	a5,a4,-48
 5a4:	00878733          	add	a4,a5,s0
 5a8:	02d00793          	li	a5,45
 5ac:	fef70823          	sb	a5,-16(a4)
 5b0:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5b4:	02e05863          	blez	a4,5e4 <printint+0x96>
 5b8:	fc040793          	addi	a5,s0,-64
 5bc:	00e78933          	add	s2,a5,a4
 5c0:	fff78993          	addi	s3,a5,-1
 5c4:	99ba                	add	s3,s3,a4
 5c6:	377d                	addiw	a4,a4,-1
 5c8:	1702                	slli	a4,a4,0x20
 5ca:	9301                	srli	a4,a4,0x20
 5cc:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5d0:	fff94583          	lbu	a1,-1(s2)
 5d4:	8526                	mv	a0,s1
 5d6:	00000097          	auipc	ra,0x0
 5da:	f56080e7          	jalr	-170(ra) # 52c <putc>
  while(--i >= 0)
 5de:	197d                	addi	s2,s2,-1
 5e0:	ff3918e3          	bne	s2,s3,5d0 <printint+0x82>
}
 5e4:	70e2                	ld	ra,56(sp)
 5e6:	7442                	ld	s0,48(sp)
 5e8:	74a2                	ld	s1,40(sp)
 5ea:	7902                	ld	s2,32(sp)
 5ec:	69e2                	ld	s3,24(sp)
 5ee:	6121                	addi	sp,sp,64
 5f0:	8082                	ret
    x = -xx;
 5f2:	40b005bb          	negw	a1,a1
    neg = 1;
 5f6:	4885                	li	a7,1
    x = -xx;
 5f8:	bf85                	j	568 <printint+0x1a>

00000000000005fa <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5fa:	7119                	addi	sp,sp,-128
 5fc:	fc86                	sd	ra,120(sp)
 5fe:	f8a2                	sd	s0,112(sp)
 600:	f4a6                	sd	s1,104(sp)
 602:	f0ca                	sd	s2,96(sp)
 604:	ecce                	sd	s3,88(sp)
 606:	e8d2                	sd	s4,80(sp)
 608:	e4d6                	sd	s5,72(sp)
 60a:	e0da                	sd	s6,64(sp)
 60c:	fc5e                	sd	s7,56(sp)
 60e:	f862                	sd	s8,48(sp)
 610:	f466                	sd	s9,40(sp)
 612:	f06a                	sd	s10,32(sp)
 614:	ec6e                	sd	s11,24(sp)
 616:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 618:	0005c903          	lbu	s2,0(a1)
 61c:	18090f63          	beqz	s2,7ba <vprintf+0x1c0>
 620:	8aaa                	mv	s5,a0
 622:	8b32                	mv	s6,a2
 624:	00158493          	addi	s1,a1,1
  state = 0;
 628:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 62a:	02500a13          	li	s4,37
 62e:	4c55                	li	s8,21
 630:	00000c97          	auipc	s9,0x0
 634:	480c8c93          	addi	s9,s9,1152 # ab0 <malloc+0x1f2>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 638:	02800d93          	li	s11,40
  putc(fd, 'x');
 63c:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 63e:	00000b97          	auipc	s7,0x0
 642:	4cab8b93          	addi	s7,s7,1226 # b08 <digits>
 646:	a839                	j	664 <vprintf+0x6a>
        putc(fd, c);
 648:	85ca                	mv	a1,s2
 64a:	8556                	mv	a0,s5
 64c:	00000097          	auipc	ra,0x0
 650:	ee0080e7          	jalr	-288(ra) # 52c <putc>
 654:	a019                	j	65a <vprintf+0x60>
    } else if(state == '%'){
 656:	01498d63          	beq	s3,s4,670 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 65a:	0485                	addi	s1,s1,1
 65c:	fff4c903          	lbu	s2,-1(s1)
 660:	14090d63          	beqz	s2,7ba <vprintf+0x1c0>
    if(state == 0){
 664:	fe0999e3          	bnez	s3,656 <vprintf+0x5c>
      if(c == '%'){
 668:	ff4910e3          	bne	s2,s4,648 <vprintf+0x4e>
        state = '%';
 66c:	89d2                	mv	s3,s4
 66e:	b7f5                	j	65a <vprintf+0x60>
      if(c == 'd'){
 670:	11490c63          	beq	s2,s4,788 <vprintf+0x18e>
 674:	f9d9079b          	addiw	a5,s2,-99
 678:	0ff7f793          	zext.b	a5,a5
 67c:	10fc6e63          	bltu	s8,a5,798 <vprintf+0x19e>
 680:	f9d9079b          	addiw	a5,s2,-99
 684:	0ff7f713          	zext.b	a4,a5
 688:	10ec6863          	bltu	s8,a4,798 <vprintf+0x19e>
 68c:	00271793          	slli	a5,a4,0x2
 690:	97e6                	add	a5,a5,s9
 692:	439c                	lw	a5,0(a5)
 694:	97e6                	add	a5,a5,s9
 696:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 698:	008b0913          	addi	s2,s6,8
 69c:	4685                	li	a3,1
 69e:	4629                	li	a2,10
 6a0:	000b2583          	lw	a1,0(s6)
 6a4:	8556                	mv	a0,s5
 6a6:	00000097          	auipc	ra,0x0
 6aa:	ea8080e7          	jalr	-344(ra) # 54e <printint>
 6ae:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 6b0:	4981                	li	s3,0
 6b2:	b765                	j	65a <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6b4:	008b0913          	addi	s2,s6,8
 6b8:	4681                	li	a3,0
 6ba:	4629                	li	a2,10
 6bc:	000b2583          	lw	a1,0(s6)
 6c0:	8556                	mv	a0,s5
 6c2:	00000097          	auipc	ra,0x0
 6c6:	e8c080e7          	jalr	-372(ra) # 54e <printint>
 6ca:	8b4a                	mv	s6,s2
      state = 0;
 6cc:	4981                	li	s3,0
 6ce:	b771                	j	65a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6d0:	008b0913          	addi	s2,s6,8
 6d4:	4681                	li	a3,0
 6d6:	866a                	mv	a2,s10
 6d8:	000b2583          	lw	a1,0(s6)
 6dc:	8556                	mv	a0,s5
 6de:	00000097          	auipc	ra,0x0
 6e2:	e70080e7          	jalr	-400(ra) # 54e <printint>
 6e6:	8b4a                	mv	s6,s2
      state = 0;
 6e8:	4981                	li	s3,0
 6ea:	bf85                	j	65a <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6ec:	008b0793          	addi	a5,s6,8
 6f0:	f8f43423          	sd	a5,-120(s0)
 6f4:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6f8:	03000593          	li	a1,48
 6fc:	8556                	mv	a0,s5
 6fe:	00000097          	auipc	ra,0x0
 702:	e2e080e7          	jalr	-466(ra) # 52c <putc>
  putc(fd, 'x');
 706:	07800593          	li	a1,120
 70a:	8556                	mv	a0,s5
 70c:	00000097          	auipc	ra,0x0
 710:	e20080e7          	jalr	-480(ra) # 52c <putc>
 714:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 716:	03c9d793          	srli	a5,s3,0x3c
 71a:	97de                	add	a5,a5,s7
 71c:	0007c583          	lbu	a1,0(a5)
 720:	8556                	mv	a0,s5
 722:	00000097          	auipc	ra,0x0
 726:	e0a080e7          	jalr	-502(ra) # 52c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 72a:	0992                	slli	s3,s3,0x4
 72c:	397d                	addiw	s2,s2,-1
 72e:	fe0914e3          	bnez	s2,716 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 732:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 736:	4981                	li	s3,0
 738:	b70d                	j	65a <vprintf+0x60>
        s = va_arg(ap, char*);
 73a:	008b0913          	addi	s2,s6,8
 73e:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 742:	02098163          	beqz	s3,764 <vprintf+0x16a>
        while(*s != 0){
 746:	0009c583          	lbu	a1,0(s3)
 74a:	c5ad                	beqz	a1,7b4 <vprintf+0x1ba>
          putc(fd, *s);
 74c:	8556                	mv	a0,s5
 74e:	00000097          	auipc	ra,0x0
 752:	dde080e7          	jalr	-546(ra) # 52c <putc>
          s++;
 756:	0985                	addi	s3,s3,1
        while(*s != 0){
 758:	0009c583          	lbu	a1,0(s3)
 75c:	f9e5                	bnez	a1,74c <vprintf+0x152>
        s = va_arg(ap, char*);
 75e:	8b4a                	mv	s6,s2
      state = 0;
 760:	4981                	li	s3,0
 762:	bde5                	j	65a <vprintf+0x60>
          s = "(null)";
 764:	00000997          	auipc	s3,0x0
 768:	34498993          	addi	s3,s3,836 # aa8 <malloc+0x1ea>
        while(*s != 0){
 76c:	85ee                	mv	a1,s11
 76e:	bff9                	j	74c <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 770:	008b0913          	addi	s2,s6,8
 774:	000b4583          	lbu	a1,0(s6)
 778:	8556                	mv	a0,s5
 77a:	00000097          	auipc	ra,0x0
 77e:	db2080e7          	jalr	-590(ra) # 52c <putc>
 782:	8b4a                	mv	s6,s2
      state = 0;
 784:	4981                	li	s3,0
 786:	bdd1                	j	65a <vprintf+0x60>
        putc(fd, c);
 788:	85d2                	mv	a1,s4
 78a:	8556                	mv	a0,s5
 78c:	00000097          	auipc	ra,0x0
 790:	da0080e7          	jalr	-608(ra) # 52c <putc>
      state = 0;
 794:	4981                	li	s3,0
 796:	b5d1                	j	65a <vprintf+0x60>
        putc(fd, '%');
 798:	85d2                	mv	a1,s4
 79a:	8556                	mv	a0,s5
 79c:	00000097          	auipc	ra,0x0
 7a0:	d90080e7          	jalr	-624(ra) # 52c <putc>
        putc(fd, c);
 7a4:	85ca                	mv	a1,s2
 7a6:	8556                	mv	a0,s5
 7a8:	00000097          	auipc	ra,0x0
 7ac:	d84080e7          	jalr	-636(ra) # 52c <putc>
      state = 0;
 7b0:	4981                	li	s3,0
 7b2:	b565                	j	65a <vprintf+0x60>
        s = va_arg(ap, char*);
 7b4:	8b4a                	mv	s6,s2
      state = 0;
 7b6:	4981                	li	s3,0
 7b8:	b54d                	j	65a <vprintf+0x60>
    }
  }
}
 7ba:	70e6                	ld	ra,120(sp)
 7bc:	7446                	ld	s0,112(sp)
 7be:	74a6                	ld	s1,104(sp)
 7c0:	7906                	ld	s2,96(sp)
 7c2:	69e6                	ld	s3,88(sp)
 7c4:	6a46                	ld	s4,80(sp)
 7c6:	6aa6                	ld	s5,72(sp)
 7c8:	6b06                	ld	s6,64(sp)
 7ca:	7be2                	ld	s7,56(sp)
 7cc:	7c42                	ld	s8,48(sp)
 7ce:	7ca2                	ld	s9,40(sp)
 7d0:	7d02                	ld	s10,32(sp)
 7d2:	6de2                	ld	s11,24(sp)
 7d4:	6109                	addi	sp,sp,128
 7d6:	8082                	ret

00000000000007d8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7d8:	715d                	addi	sp,sp,-80
 7da:	ec06                	sd	ra,24(sp)
 7dc:	e822                	sd	s0,16(sp)
 7de:	1000                	addi	s0,sp,32
 7e0:	e010                	sd	a2,0(s0)
 7e2:	e414                	sd	a3,8(s0)
 7e4:	e818                	sd	a4,16(s0)
 7e6:	ec1c                	sd	a5,24(s0)
 7e8:	03043023          	sd	a6,32(s0)
 7ec:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7f0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7f4:	8622                	mv	a2,s0
 7f6:	00000097          	auipc	ra,0x0
 7fa:	e04080e7          	jalr	-508(ra) # 5fa <vprintf>
}
 7fe:	60e2                	ld	ra,24(sp)
 800:	6442                	ld	s0,16(sp)
 802:	6161                	addi	sp,sp,80
 804:	8082                	ret

0000000000000806 <printf>:

void
printf(const char *fmt, ...)
{
 806:	711d                	addi	sp,sp,-96
 808:	ec06                	sd	ra,24(sp)
 80a:	e822                	sd	s0,16(sp)
 80c:	1000                	addi	s0,sp,32
 80e:	e40c                	sd	a1,8(s0)
 810:	e810                	sd	a2,16(s0)
 812:	ec14                	sd	a3,24(s0)
 814:	f018                	sd	a4,32(s0)
 816:	f41c                	sd	a5,40(s0)
 818:	03043823          	sd	a6,48(s0)
 81c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 820:	00840613          	addi	a2,s0,8
 824:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 828:	85aa                	mv	a1,a0
 82a:	4505                	li	a0,1
 82c:	00000097          	auipc	ra,0x0
 830:	dce080e7          	jalr	-562(ra) # 5fa <vprintf>
}
 834:	60e2                	ld	ra,24(sp)
 836:	6442                	ld	s0,16(sp)
 838:	6125                	addi	sp,sp,96
 83a:	8082                	ret

000000000000083c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 83c:	1141                	addi	sp,sp,-16
 83e:	e422                	sd	s0,8(sp)
 840:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 842:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 846:	00000797          	auipc	a5,0x0
 84a:	2da7b783          	ld	a5,730(a5) # b20 <freep>
 84e:	a02d                	j	878 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 850:	4618                	lw	a4,8(a2)
 852:	9f2d                	addw	a4,a4,a1
 854:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 858:	6398                	ld	a4,0(a5)
 85a:	6310                	ld	a2,0(a4)
 85c:	a83d                	j	89a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 85e:	ff852703          	lw	a4,-8(a0)
 862:	9f31                	addw	a4,a4,a2
 864:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 866:	ff053683          	ld	a3,-16(a0)
 86a:	a091                	j	8ae <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 86c:	6398                	ld	a4,0(a5)
 86e:	00e7e463          	bltu	a5,a4,876 <free+0x3a>
 872:	00e6ea63          	bltu	a3,a4,886 <free+0x4a>
{
 876:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 878:	fed7fae3          	bgeu	a5,a3,86c <free+0x30>
 87c:	6398                	ld	a4,0(a5)
 87e:	00e6e463          	bltu	a3,a4,886 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 882:	fee7eae3          	bltu	a5,a4,876 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 886:	ff852583          	lw	a1,-8(a0)
 88a:	6390                	ld	a2,0(a5)
 88c:	02059813          	slli	a6,a1,0x20
 890:	01c85713          	srli	a4,a6,0x1c
 894:	9736                	add	a4,a4,a3
 896:	fae60de3          	beq	a2,a4,850 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 89a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 89e:	4790                	lw	a2,8(a5)
 8a0:	02061593          	slli	a1,a2,0x20
 8a4:	01c5d713          	srli	a4,a1,0x1c
 8a8:	973e                	add	a4,a4,a5
 8aa:	fae68ae3          	beq	a3,a4,85e <free+0x22>
    p->s.ptr = bp->s.ptr;
 8ae:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8b0:	00000717          	auipc	a4,0x0
 8b4:	26f73823          	sd	a5,624(a4) # b20 <freep>
}
 8b8:	6422                	ld	s0,8(sp)
 8ba:	0141                	addi	sp,sp,16
 8bc:	8082                	ret

00000000000008be <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8be:	7139                	addi	sp,sp,-64
 8c0:	fc06                	sd	ra,56(sp)
 8c2:	f822                	sd	s0,48(sp)
 8c4:	f426                	sd	s1,40(sp)
 8c6:	f04a                	sd	s2,32(sp)
 8c8:	ec4e                	sd	s3,24(sp)
 8ca:	e852                	sd	s4,16(sp)
 8cc:	e456                	sd	s5,8(sp)
 8ce:	e05a                	sd	s6,0(sp)
 8d0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8d2:	02051493          	slli	s1,a0,0x20
 8d6:	9081                	srli	s1,s1,0x20
 8d8:	04bd                	addi	s1,s1,15
 8da:	8091                	srli	s1,s1,0x4
 8dc:	0014899b          	addiw	s3,s1,1
 8e0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8e2:	00000517          	auipc	a0,0x0
 8e6:	23e53503          	ld	a0,574(a0) # b20 <freep>
 8ea:	c515                	beqz	a0,916 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ec:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8ee:	4798                	lw	a4,8(a5)
 8f0:	02977f63          	bgeu	a4,s1,92e <malloc+0x70>
 8f4:	8a4e                	mv	s4,s3
 8f6:	0009871b          	sext.w	a4,s3
 8fa:	6685                	lui	a3,0x1
 8fc:	00d77363          	bgeu	a4,a3,902 <malloc+0x44>
 900:	6a05                	lui	s4,0x1
 902:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 906:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 90a:	00000917          	auipc	s2,0x0
 90e:	21690913          	addi	s2,s2,534 # b20 <freep>
  if(p == (char*)-1)
 912:	5afd                	li	s5,-1
 914:	a895                	j	988 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 916:	00000797          	auipc	a5,0x0
 91a:	21278793          	addi	a5,a5,530 # b28 <base>
 91e:	00000717          	auipc	a4,0x0
 922:	20f73123          	sd	a5,514(a4) # b20 <freep>
 926:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 928:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 92c:	b7e1                	j	8f4 <malloc+0x36>
      if(p->s.size == nunits)
 92e:	02e48c63          	beq	s1,a4,966 <malloc+0xa8>
        p->s.size -= nunits;
 932:	4137073b          	subw	a4,a4,s3
 936:	c798                	sw	a4,8(a5)
        p += p->s.size;
 938:	02071693          	slli	a3,a4,0x20
 93c:	01c6d713          	srli	a4,a3,0x1c
 940:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 942:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 946:	00000717          	auipc	a4,0x0
 94a:	1ca73d23          	sd	a0,474(a4) # b20 <freep>
      return (void*)(p + 1);
 94e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 952:	70e2                	ld	ra,56(sp)
 954:	7442                	ld	s0,48(sp)
 956:	74a2                	ld	s1,40(sp)
 958:	7902                	ld	s2,32(sp)
 95a:	69e2                	ld	s3,24(sp)
 95c:	6a42                	ld	s4,16(sp)
 95e:	6aa2                	ld	s5,8(sp)
 960:	6b02                	ld	s6,0(sp)
 962:	6121                	addi	sp,sp,64
 964:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 966:	6398                	ld	a4,0(a5)
 968:	e118                	sd	a4,0(a0)
 96a:	bff1                	j	946 <malloc+0x88>
  hp->s.size = nu;
 96c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 970:	0541                	addi	a0,a0,16
 972:	00000097          	auipc	ra,0x0
 976:	eca080e7          	jalr	-310(ra) # 83c <free>
  return freep;
 97a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 97e:	d971                	beqz	a0,952 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 980:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 982:	4798                	lw	a4,8(a5)
 984:	fa9775e3          	bgeu	a4,s1,92e <malloc+0x70>
    if(p == freep)
 988:	00093703          	ld	a4,0(s2)
 98c:	853e                	mv	a0,a5
 98e:	fef719e3          	bne	a4,a5,980 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 992:	8552                	mv	a0,s4
 994:	00000097          	auipc	ra,0x0
 998:	b58080e7          	jalr	-1192(ra) # 4ec <sbrk>
  if(p == (char*)-1)
 99c:	fd5518e3          	bne	a0,s5,96c <malloc+0xae>
        return 0;
 9a0:	4501                	li	a0,0
 9a2:	bf45                	j	952 <malloc+0x94>
