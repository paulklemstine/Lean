# SHARP RANK LAW: row_i = s_i*(lam*g_i, 1, 0) + r_i*(0,0,-1), so the row space is spanned by
# (the distinct-signal directions) + (the r direction):  rank <= (distinct messages) + 1.
# Hence the attack needs  t >= D+2 signatures AND m >= D+1 DISTINCT messages.
# Prediction: for D=2, m=2 distinct messages -> rank <= 3 < 4 -> FAILS;
#             m=3 distinct messages -> rank 4 -> WORKS.
import time
PK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F)
NK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141)
F = GF(PK); E = EllipticCurve(F, [ZZ(0), ZZ(7)])
G = E(ZZ(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798),
      ZZ(0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8))
def run(D, zs, seed, trials=12):
    hits = 0; ranks = set()
    for tr in range(trials):
        set_random_seed(seed + tr)
        d = ZZ(randint(1, NK - 1)); Q = d * G
        coeffs = [ZZ(randint(1, 1 << 60)) for _ in range(D)]
        delta = ZZ(randint(1, NK - 1))
        rows, rhs = [], []
        for zi in zs:
            g = [ZZ(ZZ(zi) ^ (j + 1)) for j in range(D)]
            ki = (sum(coeffs[j] * g[j] for j in range(D)) + delta) % NK
            ri = ZZ(randint(1, NK - 1))
            si = (zi + ri * d) * inverse_mod(ki, NK) % NK
            row = [si * gg for gg in g] + [si % NK] + [(-ri) % NK]
            rows.append(row); rhs.append(zi)
        A = matrix(Zmod(NK), rows)
        rk = A.rank(); ranks.add(rk)
        if rk < D + 2: continue
        sol = A.solve_right(vector(Zmod(NK), rhs))
        hits += ((ZZ(sol[D + 1]) % NK * G) == Q)
    return hits, trials, sorted(ranks)
print("rank law: rank <= distinct messages + 1; need rank D+2 => m >= D+1", flush=True)
print(f"{'D':>3} {'#signatures':>12} {'#distinct msgs':>15} | {'recovered':>10} {'ranks':>8}", flush=True)
for D in [1, 2, 3]:
    for m in range(1, D + 3):
        # build a signature list with exactly m distinct messages, total D+2 signatures
        msgs = [ZZ(1000 + 7 * (k + 1)) for k in range(m)]
        zs = []
        while len(zs) < D + 2:
            zs += msgs
        zs = zs[:D + 2]
        h, tot, rk = run(D, zs, seed=7100)
        print(f"{D:>3} {len(zs):>12} {m:>15} | {h:>5}/{tot}   {str(rk):>8}", flush=True)
