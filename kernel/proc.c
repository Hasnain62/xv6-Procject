#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

/* A structure for the tweets which have some memory space for the message 
and a reference to the next node */


typedef struct tweet_t {

  char data[140];
  struct tweet_t *next;
  topic_t tag;

} tweet_t;

struct cpu cpus[NCPU];

struct proc proc[NPROC];

struct proc *initproc;

/* data structure to keep all the tweet nodes */
tweet_t free_list [maxtweettotal];
tweet_t *topics_array[numtweettopics];
tweet_t *head_available;
tweet_t *foot_available;
tweet_t *t = &free_list[maxtweettotal-1];

// Lock for head pointer
struct spinlock free_lock;
int unlock = 4744;

// Locks for topics free list
struct spinlock tweet_lock;

int nextpid = 1;

struct spinlock pid_lock;

extern void forkret(void);
static void freeproc(struct proc *p);

extern char trampoline[]; // trampoline.S

// helps ensure that wakeups of wait()ing
// parents are not lost. helps obey the
// memory model when using p->parent.
// must be acquired before any p->lock.

struct spinlock wait_lock;

/*Initialize freelist */
 int init_freelist(){
  
  for(int i=0 ; i < maxtweettotal ; i++){


    if(i == maxtweettotal -1){
      free_list[i].next = 0 ;
    }

    else{
      free_list[i].next = &free_list[i+1];
    }
  }

  head_available = &free_list[0];
   return 0;
 }


/* Tweet a mesage */
int btput(topic_t tag, uint64 message){
  
  
  // wait if maxtweettoal tweets have been sent
  int all_Notoccupied=1;
  for (int all =0 ; all<maxtweettotal ; all++){
     
    if(free_list[all].tag==0){
      all_Notoccupied = 0;
      break;
    }
  }
  
  acquire(&free_lock);


  if (all_Notoccupied != 0){
    printf("sleeping... Till I find a wake up call\n");
    while(head_available!=0){
      sleep(&head_available,&free_lock);
    }
  }

  // copy the data 
  copyin(myproc()->pagetable,head_available->data,message,140);
  
  release(&free_lock);

  // Keep the reference of the head of a tag in the topics array
  if (topics_array[tag]==0){
      topics_array[tag] = head_available;
      // --------------- Refrence to 
      /*
      wakeup(topics_array[tag]);
      */
  }
  

  
 // if ()
  for (int i = 0; i < maxtweettotal ; i++){

    // head_available pointer points to the next free node
    if (strncmp(free_list[i].data,head_available->data,140)==0){
        
        head_available = free_list[i].next; // 
        free_list[i].tag = tag; // set the tag for the particular tweet
        if (i!=0){       

          // disconnect the nodes if tags are different  
          if (free_list[i-1].tag!=free_list[i].tag){
              free_list[i-1].next = 0;
          }
        }
         
         // Connect all the nodes under the same tag

         tweet_t * temp = topics_array[tag];
         while(temp->tag == tag ){
          

            if(temp->next ==0){

              //  printf("It GOT IN\n");
                temp->next = &free_list[i];
                break;
            }  
            temp = temp->next;
          }          
          
        break;
    }

  }

 /* TEST all the nodes of the same tag are connected */

  tweet_t * dup_temp = topics_array[tag];
         // int itr = 1;
          while(dup_temp->tag == tag ){
            
             
            printf(" TEST : MESSAGE : %s\n next:: %s\n", dup_temp , dup_temp->next );

            if(dup_temp->next ==0){

            //    printf(" TEST :It GOT IN");
                break;
            }
            //   itr++;
            
            dup_temp = dup_temp->next;
       }


  return 0;

}

/* 
 Remove the tweet from the system */
 int btget(topic_t tag , uint64 buf){

   // struct proc* p = myproc(); 
    acquire(&tweet_lock);
// -----------------------------------
   
   /* Attempting blockade on btget */
   
  //  while( topics_array[tag]==0 ){
  //     printf("No tweets with tag... waiting for tweet to be sent");
  //     sleep(topics_array[tag],&tweet_lock) ; 
      
  //  }  

 // ----------------------------------- 
    
    copyout(myproc()->pagetable, buf , topics_array[tag]->data,140);

    // Change the node removed as the last node of freelist ()
    head_available = topics_array[tag];
    
    // printf("10th node: %s\n",free_list[9].next );
    topics_array[tag] = topics_array[tag]->next;

    head_available->next = 0;

    wakeup(&head_available);

    release(&tweet_lock);

    printf(" BTGET :First tag node : %s\n",topics_array[tag]);
    
  return 0;

  }

 int tget (topic_t tag , uint64 buf){
   
   // struct proc* p = myproc(); 
    acquire(&free_lock);
    copyout(myproc()->pagetable, buf , topics_array[tag]->data,140);
  
    // Change the node removed as the last node of freelist ()
    head_available = topics_array[tag];
  
    // printf("10th node: %s\n",free_list[9].next );
    topics_array[tag] = topics_array[tag]->next;

    head_available->next = 0;

   // wakeup(&head_available);

    release(&free_lock);

    printf(" BTGET :First tag node : %s\n",topics_array[tag]);

  return 0;
 
   }

 int tput(topic_t tag , uint64 message){
 // wait if maxtweettoal tweets have been sent
  int all_Notoccupied=1;
  for (int all =0 ; all<maxtweettotal ; all++){
     
    if(free_list[all].tag==0){
      all_Notoccupied = 0;
      break;
    }
  }
  
  //acquire(&free_lock);


  if (all_Notoccupied != 0){
    printf("tput failed : maxtweettotal tweeets already sent");
    return -1;
  }

  // copy the data 
  copyin(myproc()->pagetable,head_available->data,message,140);
  
  release(&free_lock);

  // Keep the reference of the head of a tag in the topics array
  if (topics_array[tag]==0){
      topics_array[tag] = head_available;
   //   printf("Yes, Topics Array It was once Zero\n");
  }

  
 // if ()
  for (int i = 0; i < maxtweettotal ; i++){

    // head_available pointer points to the next free node
    if (strncmp(free_list[i].data,head_available->data,140)==0){
        
        head_available = free_list[i].next; // 
        free_list[i].tag = tag; // set the tag for the particular tweet
        if (i!=0){       

          // disconnect the nodes if tags are different  
          if (free_list[i-1].tag!=free_list[i].tag){
              free_list[i-1].next = 0;
          }
        }
         
         // Connect all the nodes under the same tag

         tweet_t * temp = topics_array[tag];
         while(temp->tag == tag ){
          

            if(temp->next ==0){

              //  printf("It GOT IN\n");
                temp->next = &free_list[i];
                break;
            }  
            temp = temp->next;
          }          
          
        break;
    }

  }

 /* TEST all the nodes of the same tag are connected */

  tweet_t * dup_temp = topics_array[tag];
         // int itr = 1;
          while(dup_temp->tag == tag ){
            
             
            printf(" TEST tput : MESSAGE : %s\n next:: %s\n", dup_temp , dup_temp->next );

            if(dup_temp->next ==0){

            //    printf(" TEST :It GOT IN");
                break;
            }
            //   itr++;
            
            dup_temp = dup_temp->next;
       }


  return 0;
 
}


// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page. 

void
proc_mapstacks(pagetable_t kpgtbl) {
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
  }

}

// initialize the proc table at boot time.

void
procinit(void)
{
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
  initlock(&wait_lock, "wait_lock");
  initlock(&tweet_lock, "tweet_lock");
  initlock(&free_lock , "free_lock");

  for(p = proc; p < &proc[NPROC]; p++) {
      initlock(&p->lock, "proc");
      p->kstack = KSTACK((int) (p - proc));

    }

 }

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.

int
cpuid()

{

  int id = r_tp();
  return id;

}

// Return this CPU's cpu struct.
// Interrupts must be disabled.

struct cpu*
mycpu(void) {

  int id = cpuid();
  struct cpu *c = &cpus[id];
  return c;

}

// Return the current struct proc *, or zero if none.

struct proc*
myproc(void) {

  push_off();
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
  pop_off();
  return p;
}

int
allocpid() {
  int pid;
  
  acquire(&pid_lock);
  pid = nextpid;
  nextpid = nextpid + 1;
  release(&pid_lock);

  return pid;
}

// Look in the process table for an UNUSED proc.
// If found, initialize state required to run in the kernel,
// and return with p->lock held.
// If there are no free procs, or a memory allocation fails, return 0.

static struct proc*
allocproc(void)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    acquire(&p->lock);
    if(p->state == UNUSED) {
      goto found;
    } else {
      release(&p->lock);
    }
  }
  return 0;

found:
  p->pid = allocpid();

  p->state = USED;
  acquire(&tickslock);
  p->created = ticks;
  release(&tickslock);

  // Allocate a trapframe page.
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  // An empty user page table.
  p->pagetable = proc_pagetable(p);
  if(p->pagetable == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  // Set up new context to start executing at forkret,
  // which returns to user space.
  memset(&p->context, 0, sizeof(p->context));
  p->context.ra = (uint64)forkret;
  p->context.sp = p->kstack + PGSIZE;

  return p;
}

// free a proc structure and the data hanging from it,
// including user pages.
// p->lock must be held.

static void
freeproc(struct proc *p)
{
  if(p->trapframe)
    kfree((void*)p->trapframe);
  p->trapframe = 0;
  if(p->pagetable)
    proc_freepagetable(p->pagetable, p->sz);
  p->pagetable = 0;
  p->sz = 0;
  p->pid = 0;
  p->parent = 0;
  p->name[0] = 0;
  p->chan = 0;
  p->killed = 0;
  p->xstate = 0;
  p->state = UNUSED;
}

// Create a user page table for a given process,
// with no user memory, but with trampoline pages.
pagetable_t
proc_pagetable(struct proc *p)
{
  pagetable_t pagetable;

  // An empty page table.
  pagetable = uvmcreate();
  if(pagetable == 0)
    return 0;

  // map the trampoline code (for system call return)
  // at the highest user virtual address.
  // only the supervisor uses it, on the way
  // to/from user space, so not PTE_U.
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
              (uint64)trampoline, PTE_R | PTE_X) < 0){
    uvmfree(pagetable, 0);
    return 0;
  }

  // map the trapframe just below TRAMPOLINE, for trampoline.S.
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
              (uint64)(p->trapframe), PTE_R | PTE_W) < 0){
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    uvmfree(pagetable, 0);
    return 0;
  }

  return pagetable;
}

// Free a process's page table, and free the
// physical memory it refers to.

void
proc_freepagetable(pagetable_t pagetable, uint64 sz)
{
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
  uvmfree(pagetable, sz);
}

// a user program that calls exec("/init")
// od -t xC initcode
uchar initcode[] = {
  0x17, 0x05, 0x00, 0x00, 0x13, 0x05, 0x45, 0x02,
  0x97, 0x05, 0x00, 0x00, 0x93, 0x85, 0x35, 0x02,
  0x93, 0x08, 0x70, 0x00, 0x73, 0x00, 0x00, 0x00,
  0x93, 0x08, 0x20, 0x00, 0x73, 0x00, 0x00, 0x00,
  0xef, 0xf0, 0x9f, 0xff, 0x2f, 0x69, 0x6e, 0x69,
  0x74, 0x00, 0x00, 0x24, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00
};

// Set up first user process.
void
userinit(void)
{
  struct proc *p;

  p = allocproc();
  initproc = p;
  
  // allocate one user page and copy init's instructions
  // and data into it.
  uvminit(p->pagetable, initcode, sizeof(initcode));
  p->sz = PGSIZE;

  // prepare for the very first "return" from kernel to user.
  p->trapframe->epc = 0;      // user program counter
  p->trapframe->sp = PGSIZE;  // user stack pointer

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  p->state = RUNNABLE;

  // record the time when process was created
  // acquire(&tickslock);
  // p->created = ticks;
  // //p->timesRun = 0;
  // release(&tickslock);

  release(&p->lock);

}

// Grow or shrink user memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)

{
  uint sz;
  struct proc *p = myproc();

  sz = p->sz;
  if(n > 0){
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
      return -1;
    }
  } else if(n < 0){
    sz = uvmdealloc(p->pagetable, sz, sz + n);
  }
  p->sz = sz;
  return 0;
}

// Create a new process, copying the parent.
// Sets up child kernel stack to return as if from fork() system call.
int
fork(void)
{
  int i, pid;
  struct proc *np;
  struct proc *p = myproc();

  // Allocate process.
  if((np = allocproc()) == 0){
    return -1;
  }

  // Copy user memory from parent to child.
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    freeproc(np);
    release(&np->lock);
    return -1;
  }
  np->sz = p->sz;

  // copy saved user registers.
  *(np->trapframe) = *(p->trapframe);

  // Cause fork to return 0 in the child.
  np->trapframe->a0 = 0;

  // increment reference counts on open file descriptors.
  for(i = 0; i < NOFILE; i++)
    if(p->ofile[i])
      np->ofile[i] = filedup(p->ofile[i]);
  np->cwd = idup(p->cwd);

  safestrcpy(np->name, p->name, sizeof(p->name));

  pid = np->pid;

  release(&np->lock);

  acquire(&wait_lock); 
  np->parent = p;
  release(&wait_lock);

  acquire(&np->lock);
  
  np->state = RUNNABLE;
  
  // acquire(&tickslock);  // record the ticks when creating a process through fork
  // np->created = ticks;
  // release(&tickslock);

  release(&np->lock);

  return pid;
}

// Pass p's abandoned children to init.
// Caller must hold wait_lock.
void
reparent(struct proc *p)
{
  struct proc *pp;

  for(pp = proc; pp < &proc[NPROC]; pp++){
    if(pp->parent == p){
      pp->parent = initproc;
      wakeup(initproc);
    }
  }
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait().
void
exit(int status)

{
  struct proc *p = myproc();

  if(p == initproc)
    panic("init exiting");

  // Close all open files.
  for(int fd = 0; fd < NOFILE; fd++){
    if(p->ofile[fd]){
      struct file *f = p->ofile[fd];
      fileclose(f);
      p->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(p->cwd);
  end_op();
  p->cwd = 0;

  acquire(&wait_lock);

  // Give any children to init.
  reparent(p);

  // Parent might be sleeping in wait().
  wakeup(p->parent);

  
  acquire(&p->lock);

  p->xstate = status;
  p->state = ZOMBIE;

  acquire(&tickslock);
  p->ended = ticks; // Note the time when the process ended. 
  release(&tickslock);

  release(&wait_lock);

  // Jump into the scheduler, never to return.
  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(uint64 addr)
{
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();

  acquire(&wait_lock);

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(np = proc; np < &proc[NPROC]; np++){
      if(np->parent == p){

        // make sure the child isn't still in exit() or swtch(). 
        acquire(&np->lock);

        havekids = 1;
        if(np->state == ZOMBIE){
          // Found one.
          pid = np->pid;
          
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
                                  sizeof(np->xstate)) < 0) {

            release(&np->lock);
            release(&wait_lock);
            return -1;

          }
          freeproc(np);
          release(&np->lock);
          release(&wait_lock);
          return pid;

        }

        release(&np->lock);

      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || p->killed){
      release(&wait_lock);
      return -1;
    }
    
    // Wait for a child to exit.
    sleep(p, &wait_lock);  //DOC: wait-sleep
  }
}

// Does the same work as wait but with additional functionality

int
waitstat(uint64 addr, uint64 turnaround_time , uint64 running )

{
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();

  acquire(&wait_lock);

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(np = proc; np < &proc[NPROC]; np++){
      if(np->parent == p){
        // make sure the child isn't still in exit() or swtch(). 
        acquire(&np->lock);

        havekids = 1;
        if(np->state == ZOMBIE){
          // Found one.
          pid = np->pid;
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
                                  sizeof(np->xstate)) < 0) {

            
          //  uint* createdTime = &(np-> created);
          //  uint* endedTime = &(np-> ended);
           
            release(&np->lock);
            release(&wait_lock);
            return -1;
          }
          uint calc = np-> ended - np-> created;
          // printf("Ended : %d\n ", np->ended);
          // printf("created : %d\n ", np->created);
          // printf("calc : %d\n ", calc);

          copyout(p->pagetable, turnaround_time , (char *) &calc , sizeof(calc));
         // printf("Turn around time :%d\n",turnaround_time);
          
          //printf("Address : %d \n", addr);
          uint RunTime = np-> running;
          copyout(p->pagetable, running, (char *) &RunTime, sizeof(RunTime));

          freeproc(np);
          release(&np->lock);
          release(&wait_lock);
          return pid;

        }
        release(&np->lock);
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || p->killed){
      release(&wait_lock);
      return -1;
    }
    
    // Wait for a child to exit.
    sleep(p, &wait_lock);  //DOC: wait-sleep
  }
}



// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run.
//  - swtch to start running that process.
//  - eventually that process transfers control
//    via swtch back to the scheduler.

/* Original Scheduler */

// void
// scheduler(void)
// {
//   struct proc *p;
//   struct cpu *c = mycpu();
  
//   c->proc = 0;
//   for(;;){
//     // Avoid deadlock by ensuring that devices can interrupt.
//     intr_on();

//     for(p = proc; p < &proc[NPROC]; p++) {
//       acquire(&p->lock);
//       if(p->state == RUNNABLE) {
//         // Switch to chosen process.  It is the process's job
//         // to release its lock and then reacquire it
//         // before jumping back to us.
//         p->state = RUNNING;
//         c->proc = p;
//         swtch(&c->context, &p->context);
//         p->running++;

//         // Process is done running for now.
//         // It should have changed its p->state before coming back.
//         c->proc = 0;
//       }
//       release(&p->lock);
//     }
//   }
// }

 // Per-CPU process scheduler.
 // Each CPU calls scheduler() after setting itself up.
 // Scheduler never returns.  It loops, doing:
 //  - choose a process to run.
 //  - swtch to start running that process.
 //  - eventually that process transfers control
 //    via swtch back to the scheduler.

void
scheduler(void)

{
  struct proc *p;
  struct cpu *c = mycpu();

  //counter for scheduling decisions
  int scheduling_decisionM=0;
  int scheduling_decisionL=0;

  c->proc = 0;
  for(;;){
    // Avoid deadlock by ensuring that devices can interrupt.
    intr_on();
    
    int foundhigh = 0;
    int foundmedium = 0;

    for(p = proc; p < &proc[NPROC]; p++) { // HIGH PRIORITY
      acquire(&p->lock);
      if(p->state == RUNNABLE && p->priority==2) { 
        // Switch to chosen process.  It is the process's job
        // to release its lock and then reacquire it
        // before jumping back to us.
        foundhigh = 1;
        p->state = RUNNING;
        
        c->proc = p;
        p->priority = 1 ; // set the prioroty to medium
        
        swtch(&c->context, &p->context);
        p->running++;

        // Process is done running for now.
        // It should have changed its p->state before coming back.
        c->proc = 0;
        
      }
      
      release(&p->lock);
    }

    if (foundhigh != 1){
      for(p = proc; p < &proc[NPROC]; p++) { // MEDIUM PRIORITY
        acquire(&p->lock);

        if(p->state == RUNNABLE && p->priority==1) {
          // Switch to chosen process.  It is the process's job
          // to release its lock and then reacquire it
          // before jumping back to us.
          if(scheduling_decisionM == moveup){ // set priority high if mtimes scheduling decisions have been made

            p->priority = 2; 
            scheduling_decisionM=0;
          }


          foundmedium = 1;
          p->state = RUNNING;
          
        //  p->timesRun++;
          c->proc = p;
          if(p->timesRun == mtimes){
            p->priority = 0 ; // set the priority to low
          }
          p->timesRun++;
          swtch(&c->context, &p->context);
          p->running++;

          // Process is done running for now.
          // It should have changed its p->state before coming back.
          c->proc = 0;
          }
        
        release(&p->lock);
        }  
    }

    if(foundmedium!=1 && foundhigh !=1){ 
      for(p = proc; p < &proc[NPROC]; p++) { // LOW PRIORITY
          acquire(&p->lock);
          if(p->state == RUNNABLE && p->priority==0) {
            // Switch to chosen process.  It is the process's job
            // to release its lock and then reacquire it
            // before jumping back to us.
          
           if(scheduling_decisionL == moveup){ // set priority high if mtimes scheduling decisions have been made

            p->priority = 2; 
            scheduling_decisionL= 0;
          }

            p->state = RUNNING;
            c->proc = p;

            p->timesRun = 0; /// change the m times counter to 0
            swtch(&c->context, &p->context);
            p-> running++;

            // Process is done running for now.
            // It should have changed its p->state before coming back.
            c->proc = 0;
            }
          
          release(&p->lock);
         }
      }
      scheduling_decisionM++;  
      scheduling_decisionL++;  

   }
}

// Switch to scheduler.  Must hold only p->lock
// and have changed proc->state. Saves and restores

// intena because intena is a property of this
// kernel thread, not this CPU. It should
// be proc->intena and proc->noff, but that would
// break in the few places where a lock is held but
// there's no process.

void
sched(void)

{
  int intena;
  struct proc *p = myproc();

  if(!holding(&p->lock))
    panic("sched p->lock");
  if(mycpu()->noff != 1)
    panic("sched locks");
  if(p->state == RUNNING)
    panic("sched running");
  if(intr_get())
    panic("sched interruptible");

  intena = mycpu()->intena;
  swtch(&p->context, &mycpu()->context);
  mycpu()->intena = intena;

}

// Give up the CPU for one scheduling round.
void
yield(void)

{

  struct proc *p = myproc();
  acquire(&p->lock);
  p->state = RUNNABLE;
  sched();
  release(&p->lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.

void
forkret(void)
{
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);

  if (first) {
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  struct proc *p = myproc();
  
  // Must acquire p->lock in order to
  // change p->state and then call sched.
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
  release(lk);

  // Go to sleep.
  p->chan = chan;
  p->state = SLEEPING;

  sched();

  // Tidy up.
  p->chan = 0;

  // Reacquire original lock.
  release(&p->lock);
  acquire(lk);
}

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
        p->state = RUNNABLE;
      }
      release(&p->lock);
    }
  }
}

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    acquire(&p->lock);
    if(p->pid == pid){
      p->killed = 1;

      acquire(&tickslock); // not ethe time for exiting
      p->ended = ticks;
      release(&tickslock);

      if(p->state == SLEEPING){
        // Wake process from sleep().
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
  }
  return -1;
}

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
  struct proc *p = myproc();
  if(user_dst){
    return copyout(p->pagetable, dst, src, len);
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
  struct proc *p = myproc();
  if(user_src){
    return copyin(p->pagetable, dst, src, len);
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  static char *states[] = {
  [UNUSED]    "unused",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
  for(p = proc; p < &proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    printf("%d %s %s", p->pid, state, p->name);
    printf("\n");
  }
}

