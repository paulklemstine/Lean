from sage.all_cmdline import *   # noqa
import time
# Why did small_roots fail? Sage sets m=ceil(beta^2/(delta*eps)), eps=beta/8 default.
# At beta=0.5,delta=1 -> m=4,t=4,dim=8. Far too small to reach X=N^(1/4).
# Hypothesis: with larger X relative to what the lattice supports, it fails.
# Test: sweep epsilon (smaller eps => bigger lattice => closer to X=N^beta^2).

def prime_with_bits(b, seed):
    lo = 2^(b-1); hi = 2^b - 1; st = seed
    for _ in range(300):
        st = (st*1103515245 + 12345) % (2^31)
        cand = previous_prime(lo + (st % (hi-lo)))
        if cand.bit_length() == b: return cand
    raise RuntimeError

def make_semiprime(nb, pb, seed):
    p = prime_with_bits(pb, seed); q = prime_with_bits(nb-pb, seed+7919)
    N = p*q
    if N.bit_length() != nb:
        q = previous_prime(q + 2^(nb-pb)); N = p*q
    assert N.bit_length()==nb and p*q==N and is_prime(p) and is_prime(q)
    return p,q,N

def attempt(N,p,unk,beta,eps):
    a = (p >> unk) << unk
    assert 0 <= p-a < 2^unk
    Rb = PolynomialRing(Zmod(N),'y',implementation='NTL')
    f = Rb([a % N, 1])
    t0=time.time()
    rts = f.small_roots(X=Integer(2)^unk, beta=beta, epsilon=eps)
    sec=time.time()-t0
    found=None
    for r in rts:
        c=a+r
        if c>1 and N % c == 0: found=c; break
    return found is not None, round(sec,1), len(rts)

print("=== CONTROL nb=128 balanced: closed axis says 31 unk works, 32 fails ===", flush=True)
p,q,N = make_semiprime(128,64,4242)
beta=0.5
for eps in (0.0625, 0.02, 0.01, 0.005):
    m_expected = max(beta**2/eps, 7*beta).ceil()
    for unk in (28,30,31,32):
        ok,sec,nr = attempt(N,p,unk,beta,eps)
        print("  eps=%.4f (m~%d) unk=%2d -> ok=%s %.1fs nroots=%d" % (eps,m_expected,unk,ok,sec,nr), flush=True)
