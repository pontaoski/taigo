#include <sys/stat.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <ctype.h>
#include <sys/ptrace.h>
#include <sys/wait.h>
#include <signal.h>
#include <stdlib.h>
#include <stdio.h>

void seg() {
    raise(SIGSEGV);
}
int
gdb_check()
{
  int pid = fork();
  int status;
  int res;

  if (pid == -1)
    {
      perror("fork");
      return -1;
    }

  if (pid == 0)
    {
      int ppid = getppid();

      /* Child */
      if (ptrace(PTRACE_ATTACH, ppid, NULL, NULL) == 0)
        {
          /* Wait for the parent to stop and continue it */
          waitpid(ppid, NULL, 0);
          ptrace(PTRACE_CONT, NULL, NULL);

          /* Detach */
          ptrace(PTRACE_DETACH, getppid(), NULL, NULL);

          /* We were the tracers, so gdb is not present */
          res = 0;
        }
      else
        {
          /* Trace failed so gdb is present */
          res = 1;
        }
      exit(res);
    }
  else
    {
      waitpid(pid, &status, 0);
      res = WEXITSTATUS(status);
    }
  return res;
}
