# ============================================================================
# r119 / adaptive-message / toycurve.sage
#
# EXHAUSTIVE ACCOUNTING of (P2) on a small prime-order curve, where the entire
# solution coset of a 2-signature (D=1) system can be enumerated.
#
# For every t in Z_n the coset element is a complete hypothesis
# (a, Delta, d) that reproduces BOTH observed signatures algebraically.  We
# count, over the whole coset of n elements:
#     (1) how many give the right key   d*G == Q        -> expect exactly 1
#     (2) how many also satisfy the r-consistency of signature 1 alone,
#         x(k_1 G) == r_1  (k_1 = a z_1 + Delta)        -> expect exactly 2
#     (3) how many satisfy it for BOTH signatures       -> expect 1 (rarely 2)
# and we measure the cost of doing so (n EC additions = a full scan).
#
# Then we measure the two KNOWN ways to use those 2 signatures:
#     (A) coset scan                 : n EC additions
#     (B) discrete log of the 2 points with x-coordinate r_1 : 2*sqrt(n)
# and compare with the cost of simply breaking the key from Q: sqrt(n).
# (B) is the ECDLP itself, so 2 signatures buy nothing over attacking Q.
#
# Three schedules per trial, including an ADAPTIVE z_2 chosen from (r_1,s_1),
# so "does an adaptive choice help at t=2?" is answered exhaustively.
# ============================================================================

import time
from sage.groups.generic import discrete_log

# ---------------------------------------------------------------- toy curve
def find_curve(Nmin, Nmax):
    """prime-order curve with p < N (so x -> r mod N is injective)"""
    p = Integer(Nmin)
    while p <= Nmax:
        p = next_prime(p)
        if p > Nmax:
            return None
        for b in [7, 1, 2, 3, 5, 6, 11]:
            try:
                E = EllipticCurve(GF(p), [0, b])
            except Exception:
                continue
            N = E.order()
            if N.is_prime() and N > p and Nmin <= N <= Nmax:
                G = E.gens()[0]
                if G != E(0):
                    return p, b, N, E, G


def pr(fmt, *args):
    print(fmt % tuple(args))


res = find_curve(2 ** 20, 2 ** 22)
p, b, N, E, G = res
Fk = GF(p)
pr("toy curve: y^2 = x^3 + %s over GF(%s)", b, p)
pr("group order N = %s  (%s bits, prime: %s),  p < N: %s", N, N.nbits(),
   N.is_prime(), p < N)
pr("=> x -> r mod N is the identity on [0,p-1]: 'same r' is unambiguous")


def toy_sign(d, a, delta, z):
    """faithful toy ECDSA signature on hash z: r = x(k*G) mod N"""
    z = ZZ(z) % N
    k = (a * z + delta) % N
    if k == 0:
        return None
    R = k * G
    r = ZZ(R.x()) % N
    s = (z + r * d) * inverse_mod(k, N) % N
    if r == 0 or s == 0:
        return None
    return k, r, s


def toy_system(D, sigs):
    rows, rhs = [], []
    for (z, r, s) in sigs:
        g = [ZZ(z) ** (j + 1) % N for j in range(D)]
        rows.append([(s * gg) % N for gg in g] + [s % N, (-r) % N])
        rhs.append(ZZ(z) % N)
    return matrix(Zmod(N), rows), vector(Zmod(N), rhs)


def toy_solve_check(D, sigs, Q, a, delta, d):
    A, bv = toy_system(D, sigs)
    rk = A.rank()
    if rk < D + 2:
        return False, rk
    sol = A.solve_right(bv)
    dd = ZZ(sol[D + 1]) % N
    return (dd * G) == Q, rk


# ------------------------------------------------- sanity: same harness works
print()
print("=" * 78)
print("SANITY: the SAME harness on the toy curve gives the r118 threshold")
print("=" * 78)


def toy_sign_D(D, d, a, delta, z):
    """faithful toy ECDSA with k = sum_j a_j z^(j+1) + Delta"""
    z = ZZ(z) % N
    k = (sum(a[j] * (z ** (j + 1)) for j in range(D)) + delta) % N
    if k == 0:
        return None
    R = k * G
    r = ZZ(R.x()) % N
    s = (z + r * d) * inverse_mod(k, N) % N
    if r == 0 or s == 0:
        return None
    return r, s


for D in [1, 2]:
    for t in [D + 1, D + 2]:
        ok = 0; done = 0
        for tr in range(12):
            set_random_seed(50000 + tr)
            d = ZZ(randint(1, N - 1)); Q = d * G
            a = [ZZ(randint(1, N - 1)) for _ in range(D)]
            delta = ZZ(randint(1, N - 1))
            zs = [ZZ(randint(0, N - 1)) for _ in range(t)]
            sigs = []
            good = True
            for z in zs:
                sg = toy_sign_D(D, d, a, delta, z)
                if sg is None:
                    good = False
                    break
                sigs.append((z, sg[0], sg[1]))
            if not good:
                continue
            hit, rk = toy_solve_check(D, sigs, Q, a, delta, d)
            ok += hit
            done += 1
        pr("D=%s t=%s : recovered %s/%s", D, t, ok, done)

# ------------------------------------------- exhaustive coset enumeration
print()
print("=" * 78)
print("EXHAUSTIVE ENUMERATION: the whole 2-signature coset (D=1), 3 schedules")
print("=" * 78)
print("For each trial the coset has n elements; every one of them is a full")
print("hypothesis (a, Delta, d) consistent with BOTH signatures algebraically.")
print()
pr("%-18s | %10s %10s %10s | %14s %14s", "schedule", "n (coset)",
   "d*G==Q", "r-check s1", "r-check both", "scan time")
NSCHED = 3
scan_cost = 0
for tr in range(NSCHED):
    set_random_seed(70000 + tr)
    d = ZZ(randint(1, N - 1)); Q = d * G
    a = ZZ(randint(1, N - 1)); delta = ZZ(randint(1, N - 1))
    scheds = []
    # (i) random distinct messages
    z1 = ZZ(randint(0, N - 1)); z2 = (z1 + 1 + ZZ(randint(0, N - 2))) % N
    scheds.append(("random", z1, z2))
    # (ii) zero first
    scheds.append(("zero-first", ZZ(0), ZZ(randint(1, N - 1))))
    # (iii) ADAPTIVE: z_2 chosen from the observed (r_1, s_1)
    za = ZZ(randint(1, N - 1))
    ka, ra, sa = toy_sign(d, a, delta, za)
    zb = (za + ra) % N
    scheds.append(("adaptive z+=r", za, zb))

    for (lab, z1, z2) in scheds:
        s1 = toy_sign(d, a, delta, z1)
        s2 = toy_sign(d, a, delta, z2)
        if s1 is None or s2 is None:
            continue
        k1, r1, sv1 = s1
        k2, r2, sv2 = s2
        sigs = [(z1, r1, sv1), (z2, r2, sv2)]
        A, bv = toy_system(1, sigs)
        rk = A.rank()
        v = A.right_kernel_matrix().row(0)
        pv = A.solve_right(bv)
        v0 = ZZ(v[0]) % N; v1 = ZZ(v[1]) % N; v2 = ZZ(v[2]) % N
        p0 = ZZ(pv[0]) % N; p1 = ZZ(pv[1]) % N; p2 = ZZ(pv[2]) % N
        assert rk == 2 and v2 != 0, "unexpected rank / degenerate kernel"
        # incremental walks over the coset (t = 0..N-1), 1 EC add per step
        step_d = v2 * G
        step_k1 = ((v0 * z1 + v1) % N) * G
        step_k2 = ((v0 * z2 + v1) % N) * G
        Pd = p2 * G
        Pk1 = ((p0 * z1 + p1) % N) * G
        Pk2 = ((p0 * z2 + p1) % N) * G
        rx1 = Fk(r1); rx2 = Fk(r2)
        cnt_d = 0; cnt_r1 = 0; cnt_both = 0
        t_found = None; t_ghost = None
        t0 = time.time()
        for t in range(N):
            if Pd == Q:
                cnt_d += 1; t_found = t
            # k_i = 0 mod N has no x-coordinate at all (the signer would abort),
            # so such a coset element cannot be r-consistent
            h1 = (not Pk1.is_zero()) and (Pk1.x() == rx1)
            h2 = (not Pk2.is_zero()) and (Pk2.x() == rx2)
            if h1:
                cnt_r1 += 1
                if t != t_found:
                    t_ghost = t
            if h1 and h2:
                cnt_both += 1
            Pd = Pd + step_d
            Pk1 = Pk1 + step_k1
            Pk2 = Pk2 + step_k2
        t1 = time.time()
        scan_cost = t1 - t0
        # verify the found truth and the ghost
        d_found = (p2 + t_found * v2) % N
        assert d_found * G == Q
        ghost_note = ""
        if t_ghost is not None:
            dg = (p2 + t_ghost * v2) % N
            assert dg * G != Q
            ghost_note = "ghost d*G!=Q"
        pr("%-18s | %10s %10s %10s | %14s %14s", lab, N, cnt_d, cnt_r1,
           cnt_both, "%.1f s" % scan_cost)
        pr("   rank=%s kernel=1-dim v_d!=0  true key = 1 of %s ; %s",
           rk, N, ghost_note)

print()
print("=> over the ENTIRE coset (every element enumerated):")
print("   exactly ONE element is the true key, and the r-consistency constraint")
print("   leaves at most a couple of candidates -- but only after a full scan")
print("   of n EC additions, i.e. the cost of brute force itself.")

# --------------------------------------------- cost of the known routes
print()
print("=" * 78)
print("COST OF THE ONLY KNOWN WAYS TO USE 2 SIGNATURES (toy curve)")
print("=" * 78)
set_random_seed(70000)
d = ZZ(randint(1, N - 1)); Q = d * G
a = ZZ(randint(1, N - 1)); delta = ZZ(randint(1, N - 1))
z1 = ZZ(randint(0, N - 1)); z2 = (z1 + 1 + ZZ(randint(0, N - 2))) % N
k1, r1, sv1 = toy_sign(d, a, delta, z1)
k2, r2, sv2 = toy_sign(d, a, delta, z2)
sigs = [(z1, r1, sv1), (z2, r2, sv2)]
A, bv = toy_system(1, sigs)
v = A.right_kernel_matrix().row(0)
pv = A.solve_right(bv)

# route A: full coset scan (measured above), ~ n additions
# route B: ECDLP -- the two curve points with x-coordinate r_1, then dlog
t0 = time.time()
ysq = Fk(r1) ** 3 + Fk(b)
sq = ysq.sqrt()
cands = []
for sgn in [1, -1]:
    Pc = E(Fk(r1), sgn * sq)
    tA = time.time()
    lam = discrete_log(Pc, G, ord=N, operation='+')
    tB = time.time()
    d_cand = (lam * sv1 - ZZ(z1)) * inverse_mod(r1, N) % N
    ok = (d_cand * G) == Q
    cands.append((ok, tB - tA))
t1 = time.time()
pr("route B (2-signature + ECDLP): %s dlog(s) of sqrt(n)=%s, %.4f s, "
   "right key found: %s", len(cands), N.sqrt().n(), t1 - t0,
   any(c[0] for c in cands))

# baseline: break the key directly from the public key Q
t0 = time.time()
dl = discrete_log(Q, G, ord=N, operation='+')
t1 = time.time()
pr("baseline (dlog of Q alone) : 1 dlog, %.4f s, correct: %s", t1 - t0, dl == d)

# baseline: the honest D+2 linear attack
t0 = time.time()
z3 = (z2 + 1 + ZZ(randint(0, N - 2))) % N
k3, r3, sv3 = toy_sign(d, a, delta, z3)
A3, b3 = toy_system(1, sigs + [(z3, r3, sv3)])
sol = A3.solve_right(b3)
t1 = time.time()
pr("honest D+2 linear attack   : rank %s, %.6f s, d*G==Q: %s  (no EC work)",
   A3.rank(), t1 - t0, (ZZ(sol[2]) % N * G) == Q)

print()
pr("cost ratio scan/(ECDLP) ~ n / sqrt(n) = %s", (N / N.sqrt().n()).n())
print()
print("CONCLUSION: with 2 signatures the attacker's best option is an ECDLP of")
print("the same size as the one that protects the public key Q.  Adding the")
print("r-consistency constraint does not help; it only re-expresses ECDLP.")
print("The D+2 linear solve needs no EC work at all -- which is exactly why it")
print("is the threshold, and why 2 signatures cannot be made to work.")
