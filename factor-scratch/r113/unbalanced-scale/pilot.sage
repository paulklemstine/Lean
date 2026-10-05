# PILOT (not a result): does Sage's small_roots fire at a KNOWN-GOOD point,
# and what does it cost at nb=256/512/1024?
import time
from sage.all_cmdline import *   # noqa

def prime_with_bits(b, seed):
    """A prime with EXACTLY b bits, deterministic given seed."""
    lo = 2^(b-1)
    hi = 2^b - 1
    # deterministic offset stream from seed
    st = seed
    off = 0
    for _ in range(200):
        st = (st*1103515245 + 12345) % (2^31)
        cand = lo + (st % (hi-lo))
        cand = previous_prime(cand)
        if cand.bit_length() == b:
            return cand
    raise RuntimeError("no prime of %d bits" % b)

def make_semiprime(nb, pb, seed):
    p = prime_with_bits(pb, seed)
    q = prime_with_bits(nb-pb, seed+7919)
    N = p*q
    if N.bit_length() != nb:
        q = previous_prime(q + 2^(nb-pb)); N = p*q
    assert N.bit_length() == nb and p*q == N
    assert is_prime(p) and is_prime(q)
    return p, q, N

def attempt(N, p, unk, beta):
    a = (p >> unk) << unk
    x0 = p - a
    assert 0 <= x0 < 2^unk
    Rb = PolynomialRing(Zmod(N), 'y', implementation='NTL')
    f = Rb([a % N, 1])
    t0 = time.time()
    try:
        rts = f.small_roots(X=Integer(2)^unk, beta=beta)
    except Exception as e:
        return dict(unk=unk, ok=False, err=str(e)[:90], sec=round(time.time()-t0,1))
    sec = time.time()-t0
    found = None
    for r in rts:
        cand = a + r
        if cand > 1 and N % cand == 0:
            found = cand; break
    return dict(unk=unk, ok=(found is not None), sec=round(sec,1), nroots=len(rts),
                verified=(found is not None and found*(N//found) == N))

print("=== POSITIVE CONTROL: balanced nb=128 (closed axis: 31 works / 32 fails) ===", flush=True)
for unk in (30, 31, 32, 33):
    p,q,N = make_semiprime(128, 64, 1234+unk)
    beta = 64/128.0
    print("  unk=%2d beta=%.3f predA=%.1f -> %s" % (unk, beta, beta**2*128, attempt(N,p,unk,beta)), flush=True)

print("=== TIMING at scale, balanced beta=0.5 ===", flush=True)
for nb in (256, 512, 1024):
    beta = 0.5; unk = int(beta**2*nb) - 2
    p,q,N = make_semiprime(nb, nb//2, 999+nb)
    t0=time.time()
    print("  nb=%4d unk=%3d predA=%.1f -> %s  (total %.1fs)" % (nb, unk, beta**2*nb, attempt(N,p,unk,beta), time.time()-t0), flush=True)
