import time
def show(N, label):
    for flag in (0,1,2,3):
        t0=time.time()
        M = matrix(ZZ, pari(N).factor(flag)); dt=time.time()-t0
        triv = (M.nrows()==1 and ZZ(M[0][0])==N)
        print("%-14s flag=%d  %.4f s  rows=%d  TRIVIAL(pari returned N itself)=%s" % (label, flag, dt, M.nrows(), triv))
    # ground truth
    print("   true small factor bits: %d ; N bits %d" % (min(ZZ(N//p).nbits() if False else 0 for p in [1]) if False else 0, N.nbits()))

# small: pari surely can
a=next_prime(2^40); b=next_prime(2^38); show(a*b, "79-bit semiprime")
print()
a=next_prime(2^60); b=next_prime(2^58); show(a*b, "119-bit semiprime")
print()
a=next_prime(2^80); b=next_prime(2^78); show(a*b, "159-bit semiprime")
