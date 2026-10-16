# HYPOTHESIS: the structural attack is robust to STRUCTURAL noise and fragile to
# PER-SIGNATURE noise.
#
# The exactness of the structural attack is its strength and its weakness: the unknowns
# (a_j, Delta, d) are pinned by linear algebra *provided the nonce is exactly* in the affine
# span.  Two kinds of imperfection, two very different outcomes:
#
# (a) SHARED noise: k_s = sum_j a_j g_j(s) + Delta + E, with E one more unknown constant.
#     Then the unknowns are (a, Delta, E, d) -- the noise is absorbed, and the threshold is
#     simply D+3 signatures.  PREDICTION: works.
#
# (b) PER-SIGNATURE noise: k_s = sum_j a_j g_j(s) + Delta + e_s with e_s unknown per
#     signature.  With t = D+2 equations the system is exactly determined but INCONSISTENT:
#     the solve returns values that fit the noised nonces, not the true ones.  PREDICTION:
#     recovery rate collapses to ~0 for any nonzero noise, however small.
#
# This is the practical question: a real leak is noisy, and the answer decides whether the
# structural attack survives contact with reality.

import time

PK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
)
NK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141)
F = GF(PK); E = EllipticCurve(F, [ZZ(0), ZZ(7)])
G = E(ZZ(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798),
      ZZ(0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8))

def run(D, t, shared_noise, noise_bits, seed, trials=12):
    hits = 0
    for tr in range(trials):
        set_random_seed(seed + tr)
        d = ZZ(randint(1, NK - 1)); Q = d * G
        coeffs = [ZZ(randint(1, 1 << 60)) for _ in range(D)]
        delta = ZZ(randint(1, NK - 1))
        bigE = ZZ(randint(1, (1 << noise_bits) - 1)) if shared_noise else ZZ(0)
        nunk = D + 2 + (1 if shared_noise else 0)   # [D signals][Delta][E][d]
        rows, rhs = [], []
        for s in range(t):
            g = [ZZ(ZZ(1000003 + 97 * s) ^ (j + 1)) for j in range(D)]
            e = (ZZ(randint(0, (1 << noise_bits) - 1)) if not shared_noise else ZZ(0))
            ki = (sum(coeffs[j] * g[j] for j in range(D)) + delta + bigE + e) % NK
            zi = ZZ(randint(0, NK - 1)); ri = ZZ(randint(1, NK - 1))
            si = (zi + ri * d) * inverse_mod(ki, NK) % NK
            row = [si * gg for gg in g] + [si % NK]
            if shared_noise:
                row.append(si % NK)                    # the shared-noise slot
            row.append((-ri) % NK)                     # the key slot (always last)
            rows.append(row); rhs.append(zi)
        A = matrix(Zmod(NK), rows); b = vector(Zmod(NK), rhs)
        try:
            sol = A.solve_right(b)
        except Exception:
            continue
        drec = ZZ(sol[nunk - 1]) % NK
        hits += ((drec * G) == Q)
    return hits, trials

print(f"n = NK (256-bit); recovery of d as a function of noise, D=1", flush=True)
print(f"{'noise model':>22} {'|noise|':>10} {'t used':>7} {'pred t*':>7} | {'d recovered':>12}", flush=True)
# (a) SHARED noise, absorbed as one more unknown: threshold D+3 = 4
for bits in [8, 32, 64, 128]:
    h, tot = run(1, 4, True, bits, seed=300 + bits)
    h2, tot2 = run(1, 3, True, bits, seed=300 + bits)
    print(f"{'shared (absorbed)':>22} {'2^' + str(bits):>10} {4:>7} {4:>7} | {h:>5}/{tot}", flush=True)
# (b) PER-SIGNATURE noise: the system is inconsistent; t = D+2 = 3
for bits in [4, 8, 16, 32, 64, 128]:
    h, tot = run(1, 3, False, bits, seed=400 + bits)
    print(f"{'per-signature':>22} {'2^' + str(bits):>10} {3:>7} {3:>7} | {h:>5}/{tot}", flush=True)
# overdetermined per-signature noise: t = D+3 = 4 (inconsistent system -> solve raises)
for bits in [8, 32, 128]:
    h, tot = run(1, 4, False, bits, seed=500 + bits)
    print(f"{'per-signature':>22} {'2^' + str(bits):>10} {4:>7} {3:>7} | {h:>5}/{tot}", flush=True)
print()
print("prediction: shared noise is ABSORBED (works at t=D+3), per-signature noise BREAKS", flush=True)
print("the exactness (recovery ~0 at any size) -- the structural attack is exact, not", flush=True)
print("approximate.", flush=True)
