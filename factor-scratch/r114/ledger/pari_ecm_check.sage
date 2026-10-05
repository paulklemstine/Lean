import time, sys
# Does PARI 2.17 factor(1) include an ECM stage?
n = next_prime(2^120) * next_prime(2^118)
N = n
print("N bits:", N.nbits())
t0=time.time(); f = pari(N).factor(1); dt=time.time()-t0
print("flag=1 time %.3f s, rows %d" % (dt, len(list(f))))
t0=time.time(); f2 = pari(N).factor(0); dt2=time.time()-t0
print("flag=0 time %.3f s, rows %d" % (dt2, len(list(f2))))
# control: factor a 120-bit PRIME with flag=1 (ECM would burn time on it)
P = next_prime(2^120)
t0=time.time(); f3 = pari(P).factor(1); dt3=time.time()-t0
print("CONTROL factor(120-bit PRIME, flag=1): %.4f s rows=%d" % (dt3, len(list(f3))))
print("VERDICT: ECM stage present in factor(1) if prime control is SLOWER than composite")
