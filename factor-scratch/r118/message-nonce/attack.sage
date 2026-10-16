# HYPOTHESIS: MESSAGE-DEPENDENT nonces are the cleanest structural case -- and repeated
# messages are a sharp failure mode.
#
# k_i = sum_j a_j g_j(z_i) + Delta, with the signals being functions of the MESSAGE HASH z_i
# (public, known before the signature is made).  Unlike the chained case there is no seed
# nonce outside the family, so the threshold is exactly D+2 -- the structural minimum.
#
# This is the plausible bug: an RNG that mixes the message into the nonce (a "domain
# separated" design that is not actually keyed), e.g. k = a*H(m) + salt.
#
# PREDICTIONS:
#   (a) with distinct messages, t* = D+2 exactly (12/12 at D+2, 0/12 at D+1);
#   (b) with REPEATED messages the signal rows coincide, the (D+2)x(D+2) matrix becomes
#       singular, and the attack fails -- and the failure is detectable (rank drop), not
#       silent.  So the attacker needs D+2 signatures on DISTINCT messages.

import time

PK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F)
NK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141)
F = GF(PK); E = EllipticCurve(F, [ZZ(0), ZZ(7)])
G = E(ZZ(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798),
      ZZ(0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8))

def attack(D, zs, seed, trials=12):
    hits = 0; ranks = []
    for tr in range(trials):
        set_random_seed(seed + tr)
        d = ZZ(randint(1, NK - 1)); Q = d * G
        coeffs = [ZZ(randint(1, 1 << 60)) for _ in range(D)]
        delta = ZZ(randint(1, NK - 1))
        rows, rhs = [], []
        for zi in zs:
            g = [ZZ(ZZ(zi) ^ (j + 1)) for j in range(D)]      # public signals from z
            ki = (sum(coeffs[j] * g[j] for j in range(D)) + delta) % NK
            ri = ZZ(randint(1, NK - 1))
            si = (zi + ri * d) * inverse_mod(ki, NK) % NK
            row = [si * gg for gg in g] + [si % NK]
            row.append((-ri) % NK)
            rows.append(row); rhs.append(zi)
        nunk = D + 2
        A = matrix(Zmod(NK), rows); b = vector(Zmod(NK), rhs)
        ranks.append(A.rank())
        if A.rank() < nunk:
            continue                                  # singular: detectable failure
        sol = A.solve_right(b)
        hits += ((ZZ(sol[nunk - 1]) % NK * G) == Q)
    return hits, trials, ranks

print("MESSAGE-DEPENDENT nonces: k_i = sum_j a_j g_j(z_i) + Delta", flush=True)
print(f"{'D':>3} {'t':>4} {'pred t*':>8} | {'d recovered':>12} {'rank':>6}", flush=True)
for D in [1, 2, 3]:
    for t in [D + 1, D + 2]:
        zs = [ZZ(randint(0, NK - 1)) for _ in range(t)]
        h, tot, rk = attack(D, zs, seed=7000)
        print(f"{D:>3} {t:>4} {D+2:>8} | {h:>5}/{tot}   {str(set(rk)):>6}", flush=True)

print()
print("REPEATED messages: the signal rows coincide -> singular system", flush=True)
D = 1
zs = [ZZ(0xdeadbeef)] * 4                          # four signatures, ONE message
h, tot, rk = attack(D, zs, seed=7000)
print(f"  4 signatures on 1 message: {h}/{tot} recovered, matrix ranks {set(rk)} "
      f"(full rank would be {D+2})", flush=True)
zs2 = [ZZ(0xdeadbeef)] * 2 + [ZZ(0xcafebabe)] * 2   # two messages, twice each
h2, tot2, rk2 = attack(D, zs2, seed=7000)
print(f"  2 messages x 2 signatures: {h2}/{tot2} recovered, ranks {set(rk2)}", flush=True)
zs3 = [ZZ(0x1111), ZZ(0x2222), ZZ(0x3333)]          # three distinct messages
h3, tot3, rk3 = attack(D, zs3, seed=7000)
print(f"  3 distinct messages (t=D+2=3): {h3}/{tot3} recovered, ranks {set(rk3)}", flush=True)
print()
print("=> the structural minimum t = D+2 is achieved, and repeated messages are a", flush=True)
print("   DETECTABLE failure (rank drop), not a silent one: the attacker needs D+2", flush=True)
print("   signatures on DISTINCT messages.", flush=True)
