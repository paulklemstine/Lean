// Parallel ECM via fork() — direct C API calls, no subprocess overhead
// Catalog: MetaOracle.crystallize — ECM schedule is frozen crystal of optimal queries
// Catalog: factoring_semiprime, gcdSpectralOracle, query_strategy_output_bound

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <sys/wait.h>
#include <signal.h>
#include <gmp.h>

extern int ecm_factor(mpz_t, mpz_t, double, void*);

// Shared result via temp file (simple IPC)
#define RESULT_FILE "/tmp/ecm_result"

typedef struct {
    double B1;
    int ncurves;
} ScheduleEntry;

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <number> [timeout_sec]\n", argv[0]);
        return 1;
    }
    
    mpz_t n;
    mpz_init(n);
    mpz_set_str(n, argv[1], 10);
    int bits = mpz_sizeinbase(n, 2);
    double timeout = 2.8;
    if (argc > 2) timeout = atof(argv[2]);
    
    // ECM schedule: spread B1 values (from Catalog: oracle information rate analysis)
    // B1=250K has highest info/sec for 28-digit factors
    ScheduleEntry schedule[] = {
        {50000, 1000},
        {110000, 1000},
        {250000, 1000},
        {1000000, 2000},
        {1000000, 2000},
        {3000000, 1000},
        {3000000, 1000},
        {11000000, 200},
        {250000, 1000},
        {250000, 1000},
    };
    int n_procs = 10;
    
    // Remove old result file
    unlink(RESULT_FILE);
    
    struct timespec t0, t1;
    clock_gettime(CLOCK_MONOTONIC, &t0);
    
    pid_t pids[10];
    for (int i = 0; i < n_procs; i++) {
        pid_t pid = fork();
        if (pid == 0) {
            // Child process
            mpz_t f;
            mpz_init(f);
            
            for (int c = 0; c < schedule[i].ncurves; c++) {
                int result = ecm_factor(f, n, schedule[i].B1, NULL);
                if (result > 0 && mpz_cmp_ui(f, 1) > 0 && mpz_cmp(f, n) < 0) {
                    // Write factor to result file
                    FILE *fp = fopen(RESULT_FILE, "w");
                    if (fp) {
                        gmp_fprintf(fp, "%Zd\n", f);
                        fclose(fp);
                    }
                    mpz_clear(f);
                    _exit(0);
                }
                // Check timeout
                struct timespec now;
                clock_gettime(CLOCK_MONOTONIC, &now);
                double elapsed = (now.tv_sec - t0.tv_sec) + (now.tv_nsec - t0.tv_nsec) / 1e9;
                if (elapsed > timeout) break;
            }
            
            mpz_clear(f);
            _exit(1);
        }
        pids[i] = pid;
    }
    
    // Parent: poll for result file
    int found = 0;
    while (!found) {
        struct timespec now;
        clock_gettime(CLOCK_MONOTONIC, &now);
        double elapsed = (now.tv_sec - t0.tv_sec) + (now.tv_nsec - t0.tv_nsec) / 1e9;
        if (elapsed > timeout) break;
        
        FILE *fp = fopen(RESULT_FILE, "r");
        if (fp) {
            char buf[1024];
            if (fgets(buf, sizeof(buf), fp)) {
                mpz_t f;
                mpz_init(f);
                mpz_set_str(f, buf, 10);
                if (mpz_cmp_ui(f, 1) > 0 && mpz_cmp(f, n) < 0) {
                    clock_gettime(CLOCK_MONOTONIC, &t1);
                    double total = (t1.tv_sec - t0.tv_sec) + (t1.tv_nsec - t0.tv_nsec) / 1e9;
                    gmp_printf("FACTOR %Zd TIME %.6f\n", f, total);
                    found = 1;
                }
                mpz_clear(f);
            }
            fclose(fp);
        }
        usleep(5000); // 5ms poll
    }
    
    // Kill all children
    for (int i = 0; i < n_procs; i++) {
        kill(pids[i], SIGKILL);
    }
    for (int i = 0; i < n_procs; i++) {
        waitpid(pids[i], NULL, 0);
    }
    
    unlink(RESULT_FILE);
    mpz_clear(n);
    
    if (!found) {
        printf("NO_FACTOR\n");
        return 1;
    }
    return 0;
}
