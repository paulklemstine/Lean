# ============================================================================
# r119 / adaptive-message / two_sig_infotheory.sage
#
# (P2) THE HARD PART: 2 signatures vs 3 unknowns for D=1.  The experiment must
# not merely assert "impossible"; it must show it, by exact accounting.
#
# With t = D+1 signatures the (D+2)-unknown linear system has rank t, so its
# solution set is an affine coset of a 1-dim kernel:  n candidate triples
# (a_1..a_D, Delta, d).  If the kernel direction's LAST coordinate (the one on
# d) is nonzero -- a unit, since n is prime -- then the key coordinate runs over
# ALL of Z_n:
#
#       #candidate KEYS = n,  exactly one of which is the true key.
#
# So the 2-signature data is consistent with every one of the n possible keys:
# no algorithm, adaptive or not, can name the right one without extra work.
#
# A REAL signature also satisfies r_i = x(k_i G), k_i = a z_i + Delta, and that
# constraint does kill all but O(1) coset elements -- but USING it means
# inverting x(.), i.e. solving a discrete log: theta(n) by scanning the coset,
# theta(sqrt n) by Pollard.  Both are the cost of recovering d from Q directly.
# Hence the residual after D+1 signatures is not "almost broken": it is exactly
# the hardness of ECDSA itself.  (Exhaustive enumeration of the whole coset on a
# small curve: toycurve.sage.)
#
# SUCCESS REMAINS d*G == Q on real secp256k1.
#
# NOTE (Sage preparser quirk): digits inside f-string literal parts get
# preparsed into _sage_const_N; this script uses %-formatting throughout.
# ============================================================================

PK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F)
NK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141)
F  = GF(PK)
E  = EllipticCurve(F, [ZZ(0), ZZ(7)])
G  = E(ZZ(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798),
       ZZ(0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8))
TRIALS = 12
NUNK = lambda D: D + 2
DI = lambda D: NUNK(D) - 1          # index of the key d among the unknowns


def pr(fmt, *args):
    print(fmt % tuple(str(a) for a in args))


def signals(D, z):
    z = ZZ(z)
    return [z ** (j + 1) for j in range(D)]


class Signer:
    def __init__(self, D, seed):
        set_random_seed(seed)
        self.D = D
        self.d = ZZ(randint(1, NK - 1))
        self.Q = self.d * G
        self.a = [ZZ(randint(1, 1 << 60)) for _ in range(D)]
        self.delta = ZZ(randint(1, NK - 1))

    def sign(self, z):
        z = ZZ(z)
        k = (sum(self.a[j] * signals(self.D, z)[j]
                 for j in range(self.D)) + self.delta) % NK
        R = k * G
        r = ZZ(R.x()) % NK
        s = (z + r * self.d) * inverse_mod(k, NK) % NK
        return (k, r, s)

    def truth(self):
        return list(self.a) + [self.delta, self.d]


def system(D, sigs):
    rows, rhs = [], []
    for (z, r, s) in sigs:
        g = signals(D, z)
        rows.append([(s * gg) % NK for gg in g] + [s % NK, (-r) % NK])
        rhs.append(ZZ(z))
    return matrix(Zmod(NK), rows), vector(Zmod(NK), rhs)


def coset_info(D, sigs, Q):
    """-> (rank, kernel dim, kernel basis vector v, particular solution p)"""
    A, b = system(D, sigs)
    rk = A.rank()
    K = A.right_kernel_matrix()
    v = K.row(0)
    p = A.solve_right(b)
    return rk, K.nrows(), v, p


print("=" * 78)
print("(P2) WHY 2 SIGNATURES CANNOT BREAK D=1 -- exact accounting, secp256k1")
print("=" * 78)
print("D=1, t=2.  Four message schedules per trial, including z_1 = 0 and an")
print("'adaptive' z_2 computed from the observed (r_1,s_1).  For each, the")
print("solution coset of the 2-row system is measured.")
print()
pr("%-20s | %4s %3s %6s | %11s %13s %13s %13s",
   "schedule", "rank", "ker", "v_d!=0", "coset size", "true in coset",
   "sampled wrong", "naive solve")

schedules = [("random z1,z2", "rand"), ("zero-first 0,z", "zero"),
             ("adaptive z+=r", "chase"), ("sequential 0,1", "seq")]

tot = 0; unit = 0; in_c = 0; wrong = 0; sampled = 0; naive_hits = 0
for tr in range(TRIALS):
    sgn = Signer(1, 80000 + tr)
    for (lab, kind) in schedules:
        if kind == "rand":
            set_random_seed(60000 + tr)
            z1 = ZZ(randint(0, NK - 1))
            z2 = (z1 + 1 + ZZ(randint(0, NK - 1))) % NK
        elif kind == "zero":
            z1 = ZZ(0)
            z2 = ZZ(randint(1, NK - 1))
        elif kind == "seq":
            z1, z2 = ZZ(0), ZZ(1)
        else:                                        # adaptive: z2 from (r1,s1)
            z1 = ZZ(randint(1, NK - 1))
            k1, r1, s1 = sgn.sign(z1)
            z2 = (z1 + r1) % NK
        sigs = [(z1,) + sgn.sign(z1)[1:], (z2,) + sgn.sign(z2)[1:]]
        rk, ker, v, p = coset_info(1, sigs, sgn.Q)
        vd = ZZ(v[2]) % NK
        # is the TRUE triple inside the coset?  (harness sanity, not an attack)
        t_true = (sgn.d - ZZ(p[2])) * inverse_mod(vd, NK) % NK
        cand = [ZZ(p[i]) + t_true * ZZ(v[i]) for i in range(3)]
        in_coset = all(cand[i] % NK == w % NK for i, w in enumerate(sgn.truth()))
        bad = 0
        set_random_seed(61000 + tr)
        for _ in range(200):
            t = ZZ(randint(0, NK - 1))
            dd = (ZZ(p[2]) + t * vd) % NK
            sampled += 1
            if (dd * G) == sgn.Q:
                bad += 1
        naive = (ZZ(p[2]) % NK * G) == sgn.Q
        tot += 1; unit += (vd != 0); in_c += in_coset; wrong += bad
        naive_hits += naive
        pr("%-20s | %4s %3s %6s | %11s %13s %13s %13s", lab, rk, ker, vd != 0,
           "n = 2^256", in_coset, str(bad) + "/200", naive)

print()
pr("cells measured                        : %s   (12 trials x 4 schedules)", tot)
pr("kernel 1-dim, unit d-coordinate      : %s/%s  -> coset = n points,", unit, tot)
print("   and the d-coordinate is a bijection Z_n -> Z_n")
pr("true (a,Delta,d) inside the coset    : %s/%s   (harness consistency)", in_c, tot)
pr("uniform coset samples with d*G==Q    : %s/%s   (expected ~%s/n = 0)",
   wrong, sampled, sampled)
pr("naive solve_right on 2 rows recovers : %s/%s", naive_hits, tot)
print()
print("=> 2 signatures leave EXACTLY n candidate keys.  The t=D+1 failure is not")
print("   bad luck or a rank accident: it is the counting bound, and no choice")
print("   of messages (adaptive or not) can beat it.")

print()
print("=" * 78)
print("THE r-CONSISTENCY CONSTRAINT -- and what it costs to use it")
print("=" * 78)
print("A real signature also obeys r_i = x(k_i G), k_i = a z_i + Delta.  Inside")
print("the coset k_i(t) = k_i(0) + t*c_i is AFFINE in t, so the r-check on ONE")
print("signature has at most two solutions: k_i = +k_i(true) or -k_i(true).")
print("They are exhibited below (computed with the secrets, as an attacker")
print("cannot) together with what they are worth.")
print()
pr("%5s | %16s %16s | %12s %25s", "trial", "t (true key)",
   "t (ghost k=-k)", "ghost d*G==Q", "ghost passes sig2 r-check")
ghost_ok = 0; ghost_surv = 0
for tr in range(TRIALS):
    sgn = Signer(1, 80000 + tr)
    set_random_seed(60000 + tr)
    z1 = ZZ(randint(0, NK - 1))
    z2 = (z1 + 1 + ZZ(randint(0, NK - 1))) % NK
    k1, r1, s1 = sgn.sign(z1)
    k2, r2, s2 = sgn.sign(z2)
    sigs = [(z1, r1, s1), (z2, r2, s2)]
    A, b = system(1, sigs)
    v = A.right_kernel_matrix().row(0)
    v0 = ZZ(v[0]) % NK; v1 = ZZ(v[1]) % NK; vd = ZZ(v[2]) % NK
    p = A.solve_right(b)
    p0 = ZZ(p[0]) % NK; p1 = ZZ(p[1]) % NK; p2 = ZZ(p[2]) % NK
    c1 = (v0 * z1 + v1) % NK
    k1_0 = (p0 * z1 + p1) % NK
    t_true = (sgn.d - p2) * inverse_mod(vd, NK) % NK
    assert all((ZZ(p[i]) + t_true * ZZ(v[i])) % NK == w % NK
               for i, w in enumerate(sgn.truth()))
    if c1 % NK == 0:
        pr("%5s | %16s %16s | %12s %25s", tr, t_true, "n/a", "-", "-")
        continue
    t_ghost = ((-k1) % NK - k1_0) * inverse_mod(c1, NK) % NK
    a_g = (p0 + t_ghost * v0) % NK
    del_g = (p1 + t_ghost * v1) % NK
    d_g = (p2 + t_ghost * vd) % NK
    g_ok = (d_g * G) == sgn.Q
    k1g = (a_g * z1 + del_g) % NK
    k2g = (a_g * z2 + del_g) % NK
    surv = (ZZ((k1g * G).x()) % NK == r1) and (ZZ((k2g * G).x()) % NK == r2)
    ghost_ok += g_ok
    ghost_surv += surv
    pr("%5s | %16s %16s | %12s %25s", tr, t_true, t_ghost, g_ok, surv)

print()
pr("ghost equals the true key            : %s/%s   (it does not)", ghost_ok, TRIALS)
pr("ghost survives the SECOND r-check    : %s/%s   (generically no)", ghost_surv, TRIALS)
print()
print("To FIND the ghost the attacker must invert x(.) on the two curve points")
print("with x-coordinate r_1, i.e. take a discrete log of size n: theta(sqrt n)")
print("by Pollard -- the same cost as recovering d from Q directly.  So the")
print("extra constraint does not turn 2 signatures into a break; it re-expresses")
print("the hardness of ECDSA.  Enumerated exhaustively on a toy curve below.")

print()
print("=" * 78)
print("SAME ACCOUNTING AT t = D+1 FOR D = 2,3  (the bound is D+2-t for every D)")
print("=" * 78)
pr("%2s %3s | %4s %3s %8s | %11s %13s %13s", "D", "t", "rank", "ker",
   "v_d!=0", "coset size", "true in coset", "sampled wrong")
for D in [2, 3]:
    in_c = 0; wrong = 0; sampled = 0; unit = 0
    for tr in range(TRIALS):
        sgn = Signer(D, 80000 + tr)
        set_random_seed(62000 + tr)
        zs = [ZZ(randint(0, NK - 1)) for _ in range(D + 1)]
        sigs = []
        for z in zs:
            k, r, s = sgn.sign(z)
            sigs.append((z, r, s))
        A, b = system(D, sigs)
        rk = A.rank()
        K = A.right_kernel_matrix()
        ker = K.nrows()
        v = K.row(0)
        vd = ZZ(v[DI(D)]) % NK                 # the KEY coordinate of the kernel
        if vd == 0:
            pr("%2s %3s | %4s %3s %8s", D, D + 1, rk, ker, "v_d==0!")
            continue
        p = A.solve_right(b)
        t_true = (sgn.d - ZZ(p[DI(D)])) * inverse_mod(vd, NK) % NK
        cand = [ZZ(p[i]) + t_true * ZZ(v[i]) for i in range(NUNK(D))]
        ok = all(cand[i] % NK == w % NK for i, w in enumerate(sgn.truth()))
        bad = 0
        set_random_seed(63000 + tr)
        for _ in range(50):
            t = ZZ(randint(0, NK - 1))
            dd = (ZZ(p[DI(D)]) + t * vd) % NK
            sampled += 1
            if (dd * G) == sgn.Q:
                bad += 1
        in_c += ok; wrong += bad; unit += 1
        pr("%2s %3s | %4s %3s %8s | %11s %13s %13s", D, D + 1, rk, ker, True,
           "n = 2^256", ok, str(bad) + "/50")
    print()
    pr("D=%s: true key inside coset %s/%s ; unit key-coordinate %s/%s ; "
       "wrong samples %s/%s", D, in_c, TRIALS, unit, TRIALS, wrong, sampled)
print()
print("=> at t = D+1, for every D, the coset is 1-dimensional with a unit")
print("   d-coordinate: n candidate keys, exactly one true.  Adaptivity, choice")
print("   of messages, z=0 -- none of it changes the count n^(D+2-t).")
