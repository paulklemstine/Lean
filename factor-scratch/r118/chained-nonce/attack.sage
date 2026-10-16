# NEW ATTACK ANGLE: nonces that depend on the SIGNATURE STREAM ITSELF.
#
# Every axis so far assumed an external leak (a side channel, a bias, a shared RNG). But the
# nonce generator has access to public data too -- and if it *feeds any of it back*, the leak
# is inside the signature stream and no side channel is needed.
#
# Model: the nonce is a linear function of previous PUBLIC values,
#       k_{i+1} = sum_j a_j g_j(r_i, s_i, z_i) + Delta
# e.g.  k_{i+1} = a * r_i + b   (a linear feedback from the previous signature's r)
#
# The unknowns are (a_1..a_D, Delta, d) -- exactly the structural family of
# r118/polynomial-nonce -- but the SIGNALS are the previous signature's public values, so
# the threshold is D+2 signatures and NO side channel of any kind is required.
#
# This is the plausible bug: an RNG that mixes in the previous signature value (a "chained"
# or "self-feeding" entropy design), or that uses a previous output as its state.
#
# PREDICTION: with k_{i+1} = a*r_i + b the key falls in D+2 = 3 signatures, using only the
# published signatures, with d*G = Q verified.

import time

PK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F)
NK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141)
F = GF(PK); E = EllipticCurve(F, [ZZ(0), ZZ(7)])
G = E(ZZ(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798),
      ZZ(0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8))

def trial(D, t, seed, trials=12):
    """nonce i+1 is a linear function of D public values from signature i."""
    hits = 0
    for tr in range(trials):
        set_random_seed(seed + tr)
        d = ZZ(randint(1, NK - 1)); Q = d * G
        coeffs = [ZZ(randint(1, 1 << 60)) for _ in range(D)]
        delta = ZZ(randint(1, NK - 1))
        k = ZZ(randint(1, NK - 1))            # the first nonce: NOT in the family
        rows, rhs = [], []
        prev = None
        for step in range(t):
            zi = ZZ(randint(0, NK - 1))
            ri = ZZ((k * G)[0]) % NK
            si = (zi + ri * d) * inverse_mod(k, NK) % NK
            if prev is not None:
                # the nonce for THIS signature came from the PREVIOUS signature's signals
                g = prev
                row = [si * gg for gg in g] + [si % NK]
                row.append((-ri) % NK)
                rows.append(row); rhs.append(zi)
            # the next nonce is a linear function of D public values from THIS signature
            gnext = []
            for j in range(D):
                if j % 3 == 0:   gnext.append(ri)
                elif j % 3 == 1: gnext.append(si)
                else:            gnext.append(zi)
            prev = gnext
            k = (sum(coeffs[j] * gnext[j] for j in range(D)) + delta) % NK
        nunk = D + 2
        if len(rows) < nunk:
            continue
        A = matrix(Zmod(NK), rows); b = vector(Zmod(NK), rhs)
        sol = A.solve_right(b)
        drec = ZZ(sol[nunk - 1]) % NK
        hits += ((drec * G) == Q)
    return hits, trials

print("nonces chained from public signature values -- NO side channel needed", flush=True)
print(f"{'D (public signals)':>20} {'t = D+3':>8} | {'d recovered':>12}", flush=True)
for D in [1, 2, 3, 4]:
    h, tot = trial(D, D + 3, seed=9000)
    print(f"{D:>20} {D+3:>8} | {h:>5}/{tot}", flush=True)
print()
print("one fewer signature than needed (t = D+2):", flush=True)
for D in [1, 2, 3]:
    h, tot = trial(D, D + 2, seed=9000)
    print(f"{D:>20} {D+2:>8} | {h:>5}/{tot}", flush=True)
print()
print("=> an RNG that feeds public data back into the nonce is broken from the published", flush=True)
print("   signatures alone.  The 'leak' is the signature stream itself.", flush=True)
