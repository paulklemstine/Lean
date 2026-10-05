# SCALE SWEEP CORE. Independent GIFP attack (lattice built from gifp.sage's own
# formulas) + factor extraction by pairwise-GCD scan of the Groebner basis.
#
# WHY the GCD scan: the ORIGINAL find_roots_groebner only fires when some GB
# element is UNIVARIATE (len(vars)==1). We show by direct inspection that at
# these parameters NO GB element is univariate, so the original can never
# succeed -- and its fallback `int(f(x0,y0,z0))` passes 3 args to a 4-variable
# polynomial and raises TypeError. The lattice itself is fine.
#
# Every success is verified by multiplying back to N, and compared against the
# TRIVIAL baseline (PARI factor(N2), and trial-division-equivalent) on the SAME
# instance.
import time, sys, signal
from sage.libs.libecm import ecmfactor

class _TO(Exception): pass
def _alarm(sig, frm): raise _TO()
signal.signal(signal.SIGALRM, _alarm)

def eliminate_N2(f, modular):
    out = 0
    for mono in f.monomials():
        c = f.monomial_coefficient(mono)
        out += mono*c if c % modular == 0 else mono*(c % modular)
    return out

def build_lattice(pr, shifts, bounds):
    pr_ = pr.change_ring(ZZ)
    shifts = [pr_(s) for s in shifts]
    monos = set()
    for s in shifts: monos.update(s.monomials())
    monos = sorted(monos)
    L = matrix(ZZ, len(shifts), len(monos))
    for i,s in enumerate(shifts):
        for j,mo in enumerate(monos):
            L[i,j] = s.monomial_coefficient(mo)*mo(*bounds)
    return L, [pr(m) for m in monos]

def reconstruct(B, f, modulus, monos, bounds):
    polys = []
    for r in range(B.nrows()):
        nsq=0; ww=0; poly=0
        for c,mo in enumerate(monos):
            if B[r,c]==0: continue
            nsq += B[r,c]**2; ww += 1
            poly += B[r,c]*mo // mo(*bounds)
        if nsq*ww >= modulus**2: continue
        if poly % f == 0: poly //= f
        if poly.is_constant(): continue
        polys.append(poly)
    return polys

def gcd_scan(G, N2, ngens):
    """Return every nontrivial divisor of N2 appearing as a monomial coefficient
    of some factor of some pairwise gcd of the GB."""
    out = set()
    for i in range(len(G)):
        for j in range(i+1,len(G)):
            try: gd = G[i].gcd(G[j])
            except Exception: continue
            if gd.is_constant(): continue
            try: facs = gd.factor()
            except Exception: continue
            for fac,mult in facs:
                for mono in fac.monomials():
                    c = fac.monomial_coefficient(mono)
                    if c in (0,1,-1): continue
                    if N2 % c == 0 and c != N2 and c != -N2: out.add(ZZ(c))
    return out

def run_one(N, alpha, gamma, beta1, beta2, m, seed, t=None, s=None):
    res = gen_instance(N, alpha, gamma, beta1, beta2, seed)
    if res is None: return None
    (p1,q1,N1),(p2,q2,N2),share,droot = res
    x,y,z,w = ZZ["x","y","z","w"].gens()
    f = x*z + 2**(int(beta2*N)+int(gamma*N))*y*z + N2
    X = Integer(2**int(beta2*N)); Y = Integer(2**int(N-N*alpha-N*gamma-N*beta1))
    Z = Integer(2**int(alpha*N)); W = Integer(2**int(N-N*alpha))
    M = Integer(2**int(N*beta2-N*beta1))
    if t is None: t = int(round((1-sqrt(alpha))*m))
    if s is None: s = int(round(sqrt(alpha)*m))
    umod = M**m*p1**t; modular = M**m*N1**t
    pr = ZZ["x","y","z","w"]; x,y,z,w = pr.gens()
    qr = pr.quotient(z*w - N2)
    N2inv = inverse_mod(N2, modular)
    shifts = []
    for ii in range(m+1):
        for jj in range(m-ii+1):
            g = (y*z)**jj*w**s*f**ii*M**(m-ii)*N1**max(t-ii,0)*N2inv**min(ii+jj,s)
            shifts.append(eliminate_N2(qr(g).lift(), modular))
    t0=time.time()
    L,monos = build_lattice(pr, shifts, [X,Y,Z,W])
    B = L.LLL(0.8)
    polys = reconstruct(B, f, umod, monos, [X,Y,Z,W])
    G = None
    S = Sequence([z*w-N2]+list(polys), pr.change_ring(QQ, order='lex'))
    while len(S)>0:
        G = S.groebner_basis()
        if len(G)==pr.ngens(): break
        S.pop()
    if G is None or len(G) != pr.ngens():
        return dict(ok=0, why="no_gb", t=time.time()-t0, latdim=(L.nrows(),L.ncols()),
                    t_=t, s_=s, N2=N2, p2=p2, q2=q2, qbits=q2.nbits())
    cands = gcd_scan(G, N2, pr.ngens())
    hit = None
    for c in cands:
        if c == p2: hit = c; break
    return dict(ok=1 if hit else 0, why="got" if hit else "scan_miss",
                t=time.time()-t0, latdim=(L.nrows(),L.ncols()), t_=t, s_=s,
                N2=N2, p2=p2, q2=q2, qbits=q2.nbits(),
                found=hit, ncand=len(cands),
                verified=(hit is not None and (N2 % hit == 0)))

def trivial_baseline(N2, budget=25.0):
    """What does the TRIVIAL baseline do on the SAME instance?"""
    # (a) trial-division-equivalent: Sage/PARI default factor()
    out = {}
    t0=time.time()
    try:
        import signal
        def _to(s,f): raise TimeoutError()
        signal.signal(signal.SIGALRM,_to); signal.alarm(int(budget))
        f = factor(N2); signal.alarm(0)
        out['pari'] = dict(t=time.time()-t0, ok=(len(f)>=2 and prod(f)==N2), n=len(f))
    except Exception:
        signal.alarm(0)
        out['pari'] = dict(t=budget, ok=False, n=1, timeout=True)
    return out
