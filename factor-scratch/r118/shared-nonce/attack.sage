# HYPOTHESIS: a nonce structure SHARED ACROSS KEYS breaks all of them with ~1 signature each.
#
# If L keys are signed from one nonce stream -- k_i = sum_j a_j g_j(i) + Delta, with the SAME
# (a_j, Delta) for every key (one badly-seeded RNG, a restored VM snapshot, a shared
# hardware state) -- then the signature equations are linear in
#       unknowns (a_1..a_D, Delta, d_1..d_L)     = D + 1 + L
# with one equation per available signature.  So
#       sum_i t_i >= D + 1 + L
# i.e. the AVERAGE cost per key is (D+1+L)/L = 1 + (D+1)/L, which tends to ONE SIGNATURE
# PER KEY as L grows.
#
# Contrast a single key alone: D+2 signatures.  So sharing the structure does not cost L
# times more -- it costs L times more *unknows* but only L times more *cheap* unknowns,
# and the shared (a_j, Delta) are amortised across all of them.
#
# PREDICTION: with L keys and a shared D=1 structure, both keys fall once
# sum t_i >= D+1+L = L+2; verified against the public keys d_i * G = Q_i.

import time

PK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F)
NK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141)
F = GF(PK); E = EllipticCurve(F, [ZZ(0), ZZ(7)])
G = E(ZZ(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798),
      ZZ(0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8))

def trial(L, per_key_sigs, D=1, seed=7):
    """L keys sharing ONE nonce stream; each key supplies per_key_sigs signatures."""
    set_random_seed(seed)
    # draw each private key ONCE and use it for both the signing and the public key
    ds = [ZZ(randint(1, NK - 1)) for _ in range(L)]
    Qs = [d * G for d in ds]
    coeffs = [ZZ(randint(1, 1 << 60)) for _ in range(D)]
    delta = ZZ(randint(1, NK - 1))
    # the shared nonce stream, one nonce per (key, signature) slot
    nslots = L * per_key_sigs
    signals = []
    for s in range(nslots):
        g = [ZZ(ZZ(1000003 + 97 * s) ^ (j + 1)) for j in range(D)]
        signals.append(g)
    nonces = [(sum(coeffs[j] * signals[s][j] for j in range(D)) + delta) % NK
              for s in range(nslots)]
    # unknowns order: a_1..a_D, delta, d_1..d_L
    rows = []; rhs = []
    for k in range(L):
        for t in range(per_key_sigs):
            s_slot = k * per_key_sigs + t
            ki = nonces[s_slot]
            zi = ZZ(randint(0, NK - 1)); ri = ZZ(randint(1, NK - 1))
            si = (zi + ri * ds[k]) * inverse_mod(ki, NK) % NK
            row = [si * g for g in signals[s_slot]] + [si % NK]
            row += [ZZ(0)] * L
            row[D + 1 + k] = (-ri) % NK
            rows.append(row); rhs.append(zi)
    nunk = D + 1 + L
    A = matrix(Zmod(NK), rows); b = vector(Zmod(NK), rhs)
    sol = A.solve_right(b)
    got_d = [ZZ(sol[D + 1 + k]) % NK for k in range(L)]
    ok_keys = sum(1 for k in range(L) if (got_d[k] * G) == Qs[k])
    got_a = [ZZ(sol[j]) % NK for j in range(D)]
    return ok_keys, L, (got_a == [c % NK for c in coeffs]), (ZZ(sol[D]) % NK == delta % NK)

print("shared nonce structure across L keys", flush=True)
print(f"{'L':>4} {'sig/key':>8} {'sum t':>6} {'pred sum':>9} | {'keys broken':>12} "
      f"{'a recovered':>12} {'delta':>7}", flush=True)
for L in [2, 3, 5, 10]:
    for per_key in [1, 2, 3]:
        ok, n, oka, okd = trial(L, per_key, D=1, seed=7)
        pred = 1 + 1 + L                       # D=1: D+1+L
        print(f"{L:>4} {per_key:>8} {L*per_key:>6} {pred:>9} | {str(ok):>5}/L={n:<4d} "
              f"{str(oka):>12} {str(okd):>7}", flush=True)
print()
print("prediction: all L keys fall once sum t >= D+1+L = L+2 (D=1), i.e. ~1 signature", flush=True)
print("per key -- versus D+2 = 3 signatures for ONE key alone.", flush=True)
