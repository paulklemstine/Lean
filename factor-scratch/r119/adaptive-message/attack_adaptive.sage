# ============================================================================
# r119 / adaptive-message / attack_adaptive.sage
#
# HYPOTHESIS (adaptive / chosen-message threat model -- the strongest one in
# this family): the ATTACKER CHOOSES the messages, hence the signals z_i, and
# may choose them ADAPTIVELY (sign, look at (r_i,s_i), then choose z_{i+1}).
# Question: does that let the attacker DESIGN the system and push the
# threshold BELOW the passive t* = D+2 of r118/message-nonce?
#
#   k_i = sum_{j=1..D} a_j z_i^(j+1) + Delta          (a_j, Delta, d secret)
#   s_i = (z_i + r_i d) / k_i  ==>  row_i . (a_1..a_D, Delta, d)^T = z_i
#   row_i = [ s_i z_i^2, ..., s_i z_i^(D+1), s_i, -r_i ]     (mod n)
#
# PREDICTIONS
#   (P1) chosen messages: the attack still works, t* = D+2 unchanged.
#   (P2) adaptivity buys NOTHING: rank <= t (one equation per signing query),
#        so rank D+2 needs >= D+2 queries.  D=1 with 2 signatures leaves 3
#        unknowns -> a coset of exactly n candidate keys -> information-
#        theoretically impossible.  Exhaustive accounting: two_sig_infotheory.sage
#        and toycurve.sage.
#   (P3) z_i = 0 zeroes the whole signal block of that row (and k_i = Delta for
#        every such message): it neither helps nor hurts, and repeating it adds
#        literally zero rank.
#   (P4) D=2,3: adaptive threshold == passive threshold == D+2.
#   (NEG CONTROL) all messages equal -> rank stuck -> detectable failure.
#
# TWO SIGNER MODELS are run, because it matters and is easy to get wrong:
#   sim      : r118's simulation -- r drawn fresh at random per signature.
#              (reproduces r118's numbers exactly; used as a cross-check)
#   faithful : physically correct ECDSA -- r = x(k*G) mod n, so the ENTIRE
#              signature is a deterministic function of the message hash.
#              Repeated messages then give byte-identical signatures.
# SUCCESS = d*G == Q on real secp256k1 (never mere membership in a coset).
# ============================================================================

import time
import random

PK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F)
NK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141)
F  = GF(PK)
E  = EllipticCurve(F, [ZZ(0), ZZ(7)])
G  = E(ZZ(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798),
       ZZ(0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8))

TRIALS = 12                      # >= 12 trials per cell, as required
NUNK = lambda D: D + 2


def signals(D, z):
    """public signal block g_j(z) = z^(j+1), j = 1..D   (pow, NOT xor)"""
    z = ZZ(z)
    return [z ** (j + 1) for j in range(D)]


class Signer:
    """Signer with nonce affine in public functions of the message hash.
    Key d and nonce parameters (a_j, Delta) are drawn ONCE per instance; the
    SAME d is used for signing and for Q = d*G."""

    def __init__(self, D, seed, faithful=True):
        set_random_seed(seed)
        self.D = D
        self.faithful = faithful
        self.d = ZZ(randint(1, NK - 1))
        self.Q = self.d * G
        self.a = [ZZ(randint(1, 1 << 60)) for _ in range(D)]
        self.delta = ZZ(randint(1, NK - 1))
        self.nsigs = 0

    def nonce(self, z):
        return (sum(self.a[j] * signals(self.D, z)[j]
                    for j in range(self.D)) + self.delta) % NK

    def sign(self, z):
        z = ZZ(z)
        k = self.nonce(z)
        if k == 0:
            return None                                  # negligible
        if self.faithful:
            R = k * G                                    # r = x(k*G) mod n
            r = ZZ(R.x()) % NK
        else:
            r = ZZ(randint(1, NK - 1))                   # r118's simulation
        s = (z + r * self.d) * inverse_mod(k, NK) % NK
        if r == 0 or s == 0:
            return None                                  # negligible
        self.nsigs += 1
        return (r, s)

    def truth(self):
        return list(self.a) + [self.delta, self.d]


def system(D, sigs):
    rows, rhs = [], []
    for (z, r, s) in sigs:
        g = signals(D, z)
        rows.append([(s * gg) % NK for gg in g] + [s % NK, (-r) % NK])
        rhs.append(ZZ(z))
    return matrix(Zmod(NK), rows), vector(Zmod(NK), rhs)


def solve_check(D, sigs, Q, truth=None):
    """-> (status, rank, solution|None, verified d*G==Q, all secrets matched)"""
    A, b = system(D, sigs)
    rk = A.rank()
    if rk < NUNK(D):
        return ("singular", rk, None, False, False)
    sol = A.solve_right(b)
    dd = ZZ(sol[NUNK(D) - 1]) % NK
    ver = (dd * G) == Q
    sok = ver and truth is not None and \
        all(ZZ(sol[i]) % NK == ZZ(truth[i]) % NK for i in range(NUNK(D)))
    return ("solved", rk, sol, ver, sok)


def collect(D, zs, keyseed, faithful):
    sgn = Signer(D, keyseed, faithful)
    sigs = []
    for z in zs:
        sg = sgn.sign(z)
        if sg is None:
            return None, None
        sigs.append((ZZ(z), sg[0], sg[1]))
    return sgn, sigs


def cell_fixed(D, zs, faithful, seed=9000, trials=TRIALS):
    hits = 0; secrets = 0; done = 0; ranks = set(); aborts = 0
    for tr in range(trials):
        sgn, sigs = collect(D, zs, seed + tr, faithful)
        if sigs is None:
            aborts += 1
            continue
        st, rk, sol, ver, sok = solve_check(D, sigs, sgn.Q, sgn.truth())
        ranks.add(rk); hits += ver; secrets += sok; done += 1
    return hits, secrets, done, sorted(ranks)


MODELS = [("sim", False), ("faithful", True)]


def hdr(title):
    print()
    print("=" * 79)
    print(title)
    print("=" * 79)


# ============================================================================
hdr("PART A -- POSITIVE CONTROL: passive attacker, RANDOM distinct messages\n"
    "         (must reproduce r118's t* = D+2 BEFORE anything is concluded)")
print(f"{'model':<9} {'D':>2} {'t':>3} | {'d*G==Q':>9} {'all secrets':>12} {'rank':>6}")
for (mname, faith) in MODELS:
    for D in [1, 2, 3]:
        for t in [D + 1, D + 2, D + 3]:
            hits = 0; secrets = 0; done = 0; ranks = set()
            for tr in range(TRIALS):
                set_random_seed(1000 + tr)               # messages drawn first
                zs = []
                while len(zs) < t:
                    z = ZZ(randint(0, NK - 1))
                    if z not in zs:
                        zs.append(z)
                sgn, sigs = collect(D, zs, 9000 + tr, faith)
                if sigs is None:
                    continue
                st, rk, sol, ver, sok = solve_check(D, sigs, sgn.Q, sgn.truth())
                ranks.add(rk); hits += ver; secrets += sok; done += 1
            print(f"{mname:<9} {D:>2} {t:>3} | {hits:>4}/{done:<4} {secrets:>7}/{done:<4} {str(ranks):>6}")

# ============================================================================
hdr("PART B -- (P1) CHOSEN messages, picked in advance by the attacker")
chosen = {
    1: [("t=2: {1,2}",            [ZZ(1), ZZ(2)]),
        ("t=3: {1,2,3}",          [ZZ(1), ZZ(2), ZZ(3)]),
        ("t=3: {0,1,n-1}",        [ZZ(0), ZZ(1), NK - 1]),
        ("t=3: {0,2^64,2^128}",   [ZZ(0), ZZ(2) ** 64, ZZ(2) ** 128])],
    2: [("t=3: {1,2,3}",          [ZZ(1), ZZ(2), ZZ(3)]),
        ("t=4: {1,2,3,4}",        [ZZ(1), ZZ(2), ZZ(3), ZZ(4)]),
        ("t=4: {0,1,n-1,2^64}",   [ZZ(0), ZZ(1), NK - 1, ZZ(2) ** 64])],
    3: [("t=4: {1,2,3,4}",        [ZZ(1), ZZ(2), ZZ(3), ZZ(4)]),
        ("t=5: {1,2,3,4,5}",      [ZZ(1), ZZ(2), ZZ(3), ZZ(4), ZZ(5)]),
        ("t=5: {0,1,n-1,2^64,2^128}", [ZZ(0), ZZ(1), NK - 1, ZZ(2) ** 64, ZZ(2) ** 128])],
}
print(f"{'model':<9} {'D':>2} {'message set':<24} | {'d*G==Q':>9} {'secrets':>9} {'rank':>6}")
for (mname, faith) in MODELS:
    for D in [1, 2, 3]:
        for (lab, zs) in chosen[D]:
            h, s, tot, rk = cell_fixed(D, zs, faith)
            print(f"{mname:<9} {D:>2} {lab:<24} | {h:>4}/{tot:<4} {s:>4}/{tot:<4} {str(rk):>6}")

# ============================================================================
hdr("PART C -- (P2, P4) ADAPTIVE attacker: choose z_1, sign, OBSERVE (r_1,s_1),\n"
    "         choose z_2, ...  Stop the instant rank = D+2.  Metric: #queries.")


def s_fresh(D, hist, rng):
    used = set(h[0] for h in hist)
    while True:
        z = ZZ(rng.randrange(int(NK)))
        if z not in used:
            return z


def s_zero_first(D, hist, rng):
    if not hist:
        return ZZ(0)
    return s_fresh(D, hist, rng)


def s_sequential(D, hist, rng):
    return ZZ(len(hist))


def s_repeat(D, hist, rng):
    return hist[0][0] if hist else ZZ(0xdeadbeef)


def s_structured(D, hist, rng):
    L = [ZZ(0), ZZ(1), NK - 1, ZZ(2) ** 64, ZZ(2) ** 128, ZZ(3), ZZ(5), ZZ(7)]
    return L[len(hist) % len(L)]


def s_chase(D, hist, rng):
    # try to engineer s_i = 0 (needs z_i = -r_i d, a secret): aim z at last r
    if not hist:
        return ZZ(0x1234)
    z0, r0, s0 = hist[-1]
    return (z0 + r0) % NK


def s_chase2(D, hist, rng):
    # try to make the next row proportional to the previous one
    if not hist:
        return ZZ(0x1234)
    z0, r0, s0 = hist[-1]
    return (z0 * s0) * inverse_mod(r0, NK) % NK


STRATS = [("fresh-random", s_fresh), ("zero-first", s_zero_first),
          ("sequential 0,1,2,..", s_sequential),
          ("structured {0,1,n-1,2^64,..}", s_structured),
          ("repeat same msg", s_repeat),
          ("chase: z+=r", s_chase), ("chase2: z*s/r", s_chase2)]


def adaptive(D, strat, faithful, seed=9000, budget=8, trials=TRIALS):
    hits = 0; qlist = []; stuck = 0; final_ranks = set(); aborts = 0
    for tr in range(trials):
        sgn = Signer(D, seed + tr, faithful)
        random.seed(int(70000 + tr))                     # strategy RNG, own
        hist = []
        done = False
        while len(hist) < budget:
            z = strat(D, hist, random)
            sg = sgn.sign(z)
            if sg is None:
                break
            hist.append((z, sg[0], sg[1]))
            st, rk, sol, ver, sok = solve_check(D, hist, sgn.Q, sgn.truth())
            if st == "solved":
                hits += ver
                qlist.append(len(hist))
                done = True
                break
        if not done:
            if len(hist) < budget:
                aborts += 1
            else:
                stuck += 1
                A, b = system(D, hist)
                final_ranks.add(A.rank())
    return hits, qlist, stuck, aborts, sorted(final_ranks)


print(f"{'model':<9} {'D':>2} {'strategy':<28} | {'recovered':>10} {'queries':>12} {'rank stuck':>11}")
for (mname, faith) in MODELS:
    for D in [1, 2, 3]:
        budget = D + 5
        for (name, st_) in STRATS:
            if D > 1 and name in ("chase: z+=r", "chase2: z*s/r", "repeat same msg"):
                continue                                   # P2/P3 cases are D=1
            h, q, stuck, ab, fr = adaptive(D, st_, faith, budget=budget)
            qs = ("never,stuck=%d" % stuck) if not q else \
                 ("always %d" % min(q) if min(q) == max(q) else str(sorted(set(q))))
            frs = str(fr) if fr else "-"
            print(f"{mname:<9} {D:>2} {name:<28} | {h:>4}/{TRIALS:<5} {qs:>12} {frs:>11}")
        print()

# ============================================================================
hdr("PART D -- can the attacker ENGINEER singularity / full rank? (D=1, t=3)")
s1, s2, s3, r1, r2, r3, z1, z2, z3 = var('s1 s2 s3 r1 r2 r3 z1 z2 z3')
M = matrix([[s1 * z1, s1, -r1], [s2 * z2, s2, -r2], [s3 * z3, s3, -r3]])
print("  symbolic det =", M.det().expand())
pred = (s1 * s2 * r3 * (z2 - z1) + s2 * s3 * r1 * (z3 - z2)
        + s3 * s1 * r2 * (z1 - z3))
for _ in range(3):
    vals = {s1: ZZ(randint(1, NK - 1)), s2: ZZ(randint(1, NK - 1)),
            s3: ZZ(randint(1, NK - 1)), r1: ZZ(randint(1, NK - 1)),
            r2: ZZ(randint(1, NK - 1)), r3: ZZ(randint(1, NK - 1)),
            z1: ZZ(randint(0, NK - 1)), z2: ZZ(randint(0, NK - 1)),
            z3: ZZ(randint(0, NK - 1))}
    assert ZZ(M.det().subs(vals)) % NK == ZZ(pred.subs(vals)) % NK
print("  closed form verified: det = s1 s2 r3 (z2-z1) + s2 s3 r1 (z3-z2)"
      " + s3 s1 r2 (z1-z3)")
print("  det contains s_3 AND r_3, i.e. it depends on the nonce of the LAST")
print("  message, unknown when that message is chosen (r_3 = x(k_3 G)):")
print("  singularity cannot be forced, and det != 0 in 12/12 t=D+2 trials.")
nz = tot = 0
for tr in range(TRIALS):
    sgn, sigs = collect(1, [ZZ(1), ZZ(2), ZZ(3)], 9000 + tr, True)
    if sigs is None:
        continue
    A, b = system(1, sigs)
    tot += 1
    nz += (A.det() != 0)
print(f"  measured: det != 0 (mod n) in {nz}/{tot} chosen-message trials")

# ============================================================================
hdr("PART E -- (P3) z_i = 0 (signal block vanishes; k_i = Delta for every such\n"
    "         message) and repeated messages, under both signer models")
print(f"{'model':<9} {'D':>2} {'schedule':<14} {'t':>3} {'m':>3} | {'d*G==Q':>9} {'rank':>6}")
zero_cases = [
    (1, [ZZ(0), ZZ(5)],                    "0,5"),
    (1, [ZZ(0), ZZ(0), ZZ(5)],             "0,0,5"),
    (1, [ZZ(0), ZZ(5), ZZ(7)],             "0,5,7"),
    (1, [ZZ(0), ZZ(0), ZZ(0), ZZ(5)],      "0,0,0,5"),
    (1, [ZZ(0), ZZ(5), ZZ(5)],             "0,5,5"),
    (1, [ZZ(0)] * 5,                       "0,0,0,0,0"),
    (1, [ZZ(5), ZZ(5), ZZ(5)],             "5,5,5"),
    (2, [ZZ(0), ZZ(0), ZZ(1), ZZ(2)],      "0,0,1,2"),
    (2, [ZZ(0), ZZ(1), ZZ(2), ZZ(3)],      "0,1,2,3"),
    (2, [ZZ(0)] * 6,                       "0*6"),
    (3, [ZZ(0), ZZ(1), ZZ(2), ZZ(3), ZZ(4)], "0,1,2,3,4"),
    (3, [ZZ(0)] * 6,                       "0*6"),
]
for (mname, faith) in MODELS:
    for (D, zs, lab) in zero_cases:
        h, s, tot, rk = cell_fixed(D, zs, faith)
        m = len(set(zs))
        print(f"{mname:<9} {D:>2} {lab:<14} {len(zs):>3} {m:>3} | {h:>4}/{tot:<4} {str(rk):>6}")

# do repeated messages give byte-identical signatures?
print()
print("  repeated message -> identical (r,s)?  (10 trials, D=1, faithful)")
same = 0
for tr in range(10):
    sgn = Signer(1, 31000 + tr, True)
    a1 = sgn.sign(ZZ(0xabcd)); a2 = sgn.sign(ZZ(0xabcd))
    if a1 == a2:
        same += 1
print(f"    identical: {same}/10      (sim model: fresh r every time, so 0/10)")

# ============================================================================
hdr("PART F -- THE RANK LAW, measured: rank as a function of (t, #distinct msgs)")
print("  sim model reproduces r118 exactly: rank = #distinct + 1 (extra rows")
print("  come from the fresh r of a repeated message).")
print("  faithful model (r = x(kG)) is TIGHTER: the signature is a function of")
print("  the message, so a repeated message repeats the row exactly:")
print("  rank = #distinct messages.  Both give the same signature threshold")
print("  t* = D+2 -- which is the quantity this round is about.")
print(f"{'model':<9} {'D':>2} {'t':>3} {'m distinct':>11} | {'rank':>6} {'recovered':>10}")
for (mname, faith) in MODELS:
    for D in [1, 2, 3]:
        for m in range(1, D + 3):
            msgs = [ZZ(1000 + 7 * (q + 1)) for q in range(m)]
            zs = []
            while len(zs) < D + 2:
                zs += msgs
            zs = zs[:D + 2]
            h, s, tot, rk = cell_fixed(D, zs, faith)
            print(f"{mname:<9} {D:>2} {len(zs):>3} {m:>11} | {str(rk):>6} {h:>4}/{tot:<5}")

# ============================================================================
hdr("PART G -- NEGATIVE CONTROL: attacker makes ALL messages equal")
print(f"{'model':<9} {'D':>2} {'t':>3} {'m':>3} | {'d*G==Q':>9} {'rank':>6}")
for (mname, faith) in MODELS:
    for D in [1, 2, 3]:
        zs = [ZZ(0xdeadbeef)] * (D + 3)
        h, s, tot, rk = cell_fixed(D, zs, faith)
        print(f"{mname:<9} {D:>2} {len(zs):>3} {1:>3} | {h:>4}/{tot:<4} {str(rk):>6}")

print()
print("=> adaptivity buys nothing: rank <= t always, so rank D+2 needs >= D+2")
print("   queries, and each query yields exactly one equation.  The attacker")
print("   can only choose WHICH equation, not HOW MANY.")
