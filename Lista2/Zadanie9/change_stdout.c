#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/ptrace.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/user.h>
#include <fcntl.h>
#include <string.h>

void change_stdout(pid_t target_pid, const char *new_file) {
    // Otwórz plik, do którego ma być przekierowane wyjście
    int new_fd = open(new_file, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (new_fd < 0) {
        perror("open");
        exit(EXIT_FAILURE);
    }

    // Dołącz do procesu
    if (ptrace(PTRACE_ATTACH, target_pid, NULL, NULL) == -1) {
        perror("ptrace attach");
        exit(EXIT_FAILURE);
    }

    // Czekaj na zatrzymanie procesu
    waitpid(target_pid, NULL, 0);

    // Zmiana deskryptora pliku 1 (stdout)
    // Odczytujemy wartość deskryptora stdout
    long old_fd = ptrace(PTRACE_PEEKDATA, target_pid, (void *)(sizeof(long) * 2), NULL);
    if (old_fd == -1) {
        perror("ptrace peekdata");
        ptrace(PTRACE_DETACH, target_pid, NULL, NULL);
        exit(EXIT_FAILURE);
    }

    // Zapisz nowy fd na miejsce starego fd
    if (ptrace(PTRACE_POKEDATA, target_pid, (void *)(sizeof(long) * 2), new_fd) == -1) {
        perror("ptrace pokedata");
        ptrace(PTRACE_DETACH, target_pid, NULL, NULL);
        exit(EXIT_FAILURE);
    }

    // Odłącz od procesu
    ptrace(PTRACE_DETACH, target_pid, NULL, NULL);
    printf("Changed stdout of process %d to %s\n", target_pid, new_file);
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s <pid> <new_file>\n", argv[0]);
        return EXIT_FAILURE;
    }

    pid_t target_pid = atoi(argv[1]);
    const char *new_file = argv[2];

    change_stdout(target_pid, new_file);
    return EXIT_SUCCESS;
}
