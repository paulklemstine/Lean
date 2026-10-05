# INDEPENDENT reimplementation of gifp.sage (Feng-Nitaj-Pan, "Generalized Implicit
# Factorization Problem"). Written from the primary source only; NO r112 harness
# imported. Self-contained: run via a driver that does load(...) -- the Sage
# preparser is REQUIRED and is applied by load().
#
# Instance model, transcribed literally from generate_gifp_instance:
#   share  = gamma*N bits, the SAME block inside p1 and p2 at a KNOWN position.
#   p1 = MSB4p1 * 2^(gN+b1N) + share*2^(b1N) + [b1N-bit tail]
#   p2 = MSB4p2 * 2^(gN+b2N) + share*2^(b2N) + [b2N-bit tail]
#   |q1| = |q2| = alpha*N.   N1 = p1*q1, N2 = p2*q2, both exactly N bits.
# Attacker knows (N, alpha, gamma, beta1, beta2, m) but NOT p1,p2,q1,q2,share.
import time, sys
from sage.crypto.util import random_blum_prime

def gen_instance(N, alpha, gamma, beta1, beta2, seed, max_attempts=40):
    """Literal transcription of the generator, made DETERMINISTIC in `seed`.
    The original reseeds from wall-clock when the product misses the target bit
    length, which makes counts irreproducible. Here the retry is seed+1, seed+2,
    ... so every count below is replayable. Returns None only if all attempts
    fail (which would itself be a finding)."""
    for _att in range(max_attempts):
        r = _gen_once(N, alpha, gamma, beta1, beta2, seed + _att)
        if r is not None: return r
    return None

def _gen_once(N, alpha, gamma, beta1, beta2, seed):
    if beta2 < beta1: beta1, beta2 = beta2, beta1
    set_random_seed(seed)
    share_bit_length = int(N*gamma)
    beta1_bit_length = int(N*beta1)
    beta2_bit_length = int(N*beta2)
    q_bit_length     = int(N*alpha)
    if min(share_bit_length, q_bit_length, beta1_bit_length, beta2_bit_length) < 4:
        return None
    share_bit = ZZ(randint(2**(share_bit_length-1)+1, 2**share_bit_length - 1))
    n1 = int(N - N*alpha - N*gamma - N*beta1)
    n2 = int(N - N*alpha - N*gamma - N*beta2)
    if min(n1, n2) < 4: return None
    MSB4p1 = ZZ(randint(2**(n1-1)+1, 2**n1 - 1))
    MSB4p2 = ZZ(randint(2**(n2-1)+1, 2**n2 - 1))
    p1 = random_blum_prime(MSB4p1*2**int(N*gamma+N*beta1) + share_bit*2**beta1_bit_length + 2**(beta1_bit_length-1),
                          MSB4p1*2**int(N*gamma+N*beta1) + share_bit*2**beta1_bit_length + 2**beta1_bit_length - 1)
    p2 = random_blum_prime(MSB4p2*2**int(N*gamma+N*beta2) + share_bit*2**beta2_bit_length + 2**(beta2_bit_length-1),
                          MSB4p2*2**int(N*gamma+N*beta2) + share_bit*2**beta2_bit_length + 2**beta2_bit_length - 1)
    q1 = random_blum_prime(2**(q_bit_length-1), 2**q_bit_length - 1)
    q2 = random_blum_prime(2**(q_bit_length-1), 2**q_bit_length - 1)
    N1 = p1*q1; N2 = p2*q2
    if N1.nbits() != N or N2.nbits() != N: return None
    lsb1 = int(bin(p1)[2+int(N-N*alpha-N*beta1):], 2)
    lsb2 = int(bin(p2)[2+int(N-N*alpha-N*beta2):], 2)
    desired = (lsb1*2**int(beta2*N-beta1*N) - lsb2, int(MSB4p1)-int(MSB4p2), q2, p2)
    return [p1,q1,N1],[p2,q2,N2],share_bit,desired

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
            L[i,j] = s.monomial_coefficient(mo) * mo(*bounds)
    return L, [pr(m) for m in monos]

def reconstruct(B, f, modulus, monos, bounds):
    polys = []
    for r in range(B.nrows()):
        nsq = 0; ww = 0; poly = 0
        for c,mo in enumerate(monos):
            if B[r,c] == 0: continue
            nsq += B[r,c]**2; ww += 1
            assert B[r,c] % mo(*bounds) == 0
            poly += B[r,c]*mo // mo(*bounds)
        if modulus is not None and nsq*ww >= modulus**2: continue
        if f is not None and poly % f == 0: poly //= f
        if poly.is_constant(): continue
        polys.append(poly)
    return polys

def groebner_roots(pr, polys, N2):
    x,y,z,w = pr.gens()
    # ORDER MATTERS: the original does polynomials.insert(0, z*w-N2) and the
    # recovery loop pops the LAST element when the GB is too long. Appending
    # would delete the quotient relation first.
    s = Sequence([z*w - N2] + list(polys), pr.change_ring(QQ, order='lex'))
    while len(s) > 0:
        G = s.groebner_basis()
        if len(G) == pr.ngens():
            roots = {}
            for poly in G:
                vs = poly.variables()
                if len(vs) == 1:
                    for rt in poly.univariate_polynomial().roots(multiplicities=False):
                        if rt != 0: roots |= {vs[0]: int(rt)}
            if len(roots) == pr.ngens(): yield roots[x], roots[y], roots[z], roots[w]
            return
        s.pop()

def attack(N, alpha, gamma, beta1, beta2, m, seed, t=None, s=None):
    r = gen_instance(N, alpha, gamma, beta1, beta2, seed)
    if r is None: return None
    (p1,q1,N1),(p2,q2,N2),share,desired = r
    x,y,z,w = ZZ["x","y","z","w"].gens()
    f = x*z + 2**(int(beta2*N)+int(gamma*N))*y*z + N2
    X = Integer(2**int(beta2*N))
    Y = Integer(2**int(N-N*alpha-N*gamma-N*beta1))
    Z = Integer(2**int(alpha*N))
    W = Integer(2**int(N-N*alpha))
    M = Integer(2**int(N*beta2-N*beta1))
    if t is None: t = int(round((1-sqrt(alpha))*m))
    if s is None: s = int(round(sqrt(alpha)*m))
    umod  = M**m * p1**t
    modular = M**m * N1**t
    pr = ZZ["x","y","z","w"]; x,y,z,w = pr.gens()
    qr = pr.quotient(z*w - N2)
    N2inv = inverse_mod(N2, modular)
    shifts = []
    for ii in range(m+1):
        for jj in range(m-ii+1):
            g = (y*z)**jj * w**s * f**ii * M**(m-ii) * N1**max(t-ii,0) * N2inv**min(ii+jj,s)
            g = qr(g).lift()
            g = eliminate_N2(g, modular)
            shifts.append(g)
    L, monos = build_lattice(pr, shifts, [X,Y,Z,W])
    B = L.LLL(0.8)
    polys = reconstruct(B, f, umod, monos, [X,Y,Z,W])
    out = {"N1":N1,"N2":N2,"true_p2":p2,"true_q2":q2,"latdim":(L.nrows(),L.ncols()),
           "npolys":len(polys),"p2":None}
    for x0,y0,z0,w0 in groebner_roots(pr, polys, N2):
        if int(f(x0,y0,z0)) != 0: continue
        p2f = w0; q2f = z0
        p1f = w0 + x0 + y0*(2**int(gamma*N+beta2*N))
        q1f = N1//p1f
        if p1f*q1f == N1 and p2f*q2f == N2:
            out.update({"ok":1,"p1":p1f,"q1":q1f,"p2":p2f,"q2":q2f}); break
    out.setdefault("ok",0)
    return out
