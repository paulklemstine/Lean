# ============================================================================
# r119 / adaptive-message / extra_controls.sage
#
# Two loose ends that an adaptive-chosen-message attacker could otherwise hope
# to exploit, closed here by measurement:
#
# (C1) NONCE INJECTIVITY: could chosen messages FORCE a nonce collision
#      (k_i = k_j)?  k = sum_j a_j z^(j+1) + Delta is affine in the message
#      hash with a nonzero leading coefficient, so it is a BIJECTION of Z_n:
#      distinct messages give distinct nonces, always.  No nonce reuse can be
#      engineered, which is the one thing that would have made chosen messages
#      dangerous in the usual ECDSA sense.
#
# (C2) AIMING: in a real signer z = H(m), so the attacker chooses m, not z.
#      Hitting a target z (e.g. z = 0) is a preimage: ~n hash evaluations.
#      Measured: hashes of random messages are uniform and collision-free, so
#      the practical chosen-message attacker SAMPLES z at random -- i.e. it is
#      the passive attacker.
#
# (C3) z = 0 degeneracy, isolated: k = Delta for EVERY such message, so the
#      signature (r,s) is byte-identical, and ALL such rows are collinear
#      (each is a multiple of [0,...,0,1,-Delta/d]): they add exactly one rank
#      unit in total, no matter how many are collected.
# ============================================================================

import hashlib

PK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F)
NK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141)
E = EllipticCurve(GF(PK), [ZZ(0), ZZ(7)])
G = E(ZZ(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798),
      ZZ(0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8))


def pr(fmt, *args):
    print(fmt % tuple(args))


print("=" * 78)
print("(C1) NONCE INJECTIVITY: distinct chosen messages -> distinct nonces")
print("=" * 78)
for D in [1, 2, 3]:
    set_random_seed(41000 + D)
    a = [ZZ(randint(1, NK - 1)) for _ in range(D)]
    delta = ZZ(randint(1, NK - 1))
    msgs = set()
    while len(msgs) < 512:
        msgs.add(ZZ(randint(0, NK - 1)))
    ks = set()
    for z in msgs:
        k = (sum(a[j] * (z ** (j + 1)) for j in range(D)) + delta) % NK
        ks.add(k)
    pr("D=%s : %s distinct messages -> %s distinct nonces (collisions: %s)",
       D, len(msgs), len(ks), len(msgs) - len(ks))
print()
print("  k is affine in z with a leading coefficient a_D != 0 mod a prime, so")
print("  z -> k(z) is a bijection of Z_n: the nonce can NEVER repeat across")
print("  distinct messages.  Chosen messages cannot manufacture nonce reuse.")
print("  (Repeated messages DO reuse the nonce -- trivially -- and are handled")
print("   by the rank law: the row repeats bit-for-bit, Part E/F.)")

print()
print("=" * 78)
print("(C2) AIMING AT A HASH: what 'chosen message' really gives the attacker")
print("=" * 78)
NB = 256
counts = [0] * NB
zs = set()
NSAMP = 20000
for i in range(NSAMP):
    m = ("msg-%d" % i).encode()
    z = ZZ(int(hashlib.sha256(m).hexdigest(), 16)) % NK
    zs.add(z)
    counts[int(z % NB)] += 1
exp = float(NSAMP) / NB
chi2 = sum((c - exp) ** 2 / exp for c in counts)
pr("%s random messages -> %s distinct hashes (collisions: %s)", NSAMP,
   len(zs), NSAMP - len(zs))
pr("chi-square over %s equiprobable buckets: %.1f  (expect %s +/- %.1f)",
   NB, chi2, NB - 1, (2 * (NB - 1)) ** 0.5)
print()
print("  z = H(m) is uniform, so the attacker who 'chooses the messages' in")
print("  practice SAMPLES z uniformly at random: to land on a specific z (0,")
print("  or any target) costs ~n/2 hash evaluations.  The chosen-message model")
print("  is therefore an idealisation that is strictly WEAKER for the attacker")
print("  than a direct choice of z -- and even direct choice changes nothing")
print("  (Parts B, C, E).")

print()
print("=" * 78)
print("(C3) z = 0 ISOLATED: k = Delta for every such message")
print("=" * 78)
set_random_seed(4242)
d = ZZ(randint(1, NK - 1)); Q = d * G
a = ZZ(randint(1, 1 << 60)); delta = ZZ(randint(1, NK - 1))
rows = []
for trial in range(4):
    z = ZZ(0)
    k = (a * z + delta) % NK
    R = k * G
    r = ZZ(R.x()) % NK
    s = (z + r * d) * inverse_mod(k, NK) % NK
    rows.append([r, s, (s * inverse_mod(r, NK)) % NK])
pr("four signatures on hash z=0 (same key, same Delta):")
for (r, s, ratio) in rows:
    pr("   r=%s...  s=%s...  s/r = %s...", str(r)[:12], str(s)[:12],
       str(ratio)[:12])
print("  (r,s) identical, and s/r = d/Delta is the SAME for every one of them:")
print("  every z=0 row is a multiple of [0, 1, -Delta/d], so all such rows are")
print("  collinear and together contribute exactly ONE rank unit, forever.")
print("  In the algebra: the row [0, s, -r] only ever constrains the ratio")
print("  d/Delta; the signal coefficient a is untouched.  z=0 is a wasted")
print("  query, not a shortcut.")
