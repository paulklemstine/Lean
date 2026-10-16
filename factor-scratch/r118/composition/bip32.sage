# COMPOSITION: does the round-117 acceptance-set lemma transfer signatures ACROSS a BIP32-style
# parent/child key pair?
#
# Round-117 (verified, r117/verification-points) established: for ANY lambda,
#     Q' = Q + lambda*G  and  z' = z - lambda*r
# makes the same (r,s) verify under Q' for message z'.
#
# BIP32 gives exactly this structure, with lambda KNOWN: the child public key is
#     Q_child = Q_parent + lambda * G,     lambda = tweak from the derivation data,
# and d_child = d_parent + lambda. So a signature by the child transfers to the PARENT key
# with z' = z + lambda*r.  If that holds, any system using both keys (hot child signing,
# cold parent as the account of record) accepts a cross-key replay.

import hashlib
PK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F)
NK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141)
a_, b_ = ZZ(0), ZZ(7)
F = GF(PK); E = EllipticCurve(F, [a_, b_])
G = E(ZZ(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798),
      ZZ(0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8))

def sign(z, d, k):
    R = k * G
    r = ZZ(R[0]) % NK
    s = (ZZ(z) + r * d) * inverse_mod(k, NK) % NK
    return r, s

def verify(z, Q, r, s):
    if not (0 < r < NK and 0 < s < NK): return False
    w = inverse_mod(s, NK)
    u1, u2 = ZZ(z) * w % NK, r * w % NK
    R = u1 * G + u2 * Q
    return (ZZ(R[0]) % NK) == r

set_random_seed(20261015)
print("=== parent/child transfer on real secp256k1 ===", flush=True)
ok = tot = 0
for trial in range(20):
    d = ZZ(randint(1, NK - 1)); Q = d * G
    # BIP32-style tweak: 32 bytes from a hash, reduced mod n
    lam = ZZ(int(hashlib.sha512(f"child-{trial}".encode()).hexdigest(), 16)) % NK
    dch = (d + lam) % NK; Qch = Q + lam * G
    z = ZZ(randint(0, NK - 1)); k = ZZ(randint(1, NK - 1))
    r, s = sign(z, dch, k)
    # the claim: the SAME (r,s) verifies under the PARENT key for z + lam*r
    zt = (z + lam * r) % NK
    tot += 1
    good = verify(zt, Q, r, s)
    ok += good
    if trial < 3:
        print(f"  child sig on z verifies under parent for z'=z+lam*r: {good}", flush=True)
print(f"  transfer worked: {ok}/{tot}", flush=True)

print()
print("=== the torsion/TLS-of-it: does the transfer also work with lam = an HD path tweak ===", flush=True)
# the tweak must be < n for BIP32; also test a "0-lam" sanity (lam=0 must give the identity)
d = ZZ(randint(1, NK-1)); Q = d * G
lam = ZZ(0); dch = d; Qch = Q
z = ZZ(randint(0, NK-1)); k = ZZ(randint(1, NK-1)); r, s = sign(z, dch, k)
print("  lam=0 sanity (identity):", verify(z, Q, r, s), flush=True)

print()
print("=== what this means for multisig style structures ===", flush=True)
# in a 2-of-2 where Q = Q1 + Q2 (additive key aggregation, the naive multisig), a
# signature under Q = Q1+Q2 with known lam = d2 transfers to Q1 with z' = z - lam*r.
d1 = ZZ(randint(1, NK-1)); d2 = ZZ(randint(1, NK-1))
Q1, Q2 = d1*G, d2*G; Qagg = Q1 + Q2
z = ZZ(randint(0, NK-1)); k = ZZ(randint(1, NK-1)); r, s = sign(z, (d1+d2) % NK, k)
print(f"  naive additive 2-of-2: signature under Q1+Q2 verifies under Q1 alone: "
      f"{verify((z - d2*r) % NK, Q1, r, s)}", flush=True)
print("  (i.e. an aggregate-key signature is a signature under ANY known linear component)", flush=True)

print()
print("=== THE DEPLOYMENT RULE, spelled out ===", flush=True)
# For a key pair related by a PUBLIC translation, a signature transfers. Enumerate the
# realistic places where that happens.
cases = []
# 1. BIP32 parent/child (verified 20/20)
cases.append(("BIP32 parent<->child", "lambda public (path tweak)", "anyone", True))
# 2. two keys of the same wallet with an additive relation (common in custodial setups)
cases.append(("wallet: master + child tweak", "lambda public", "anyone", True))
# 3. HD with a private tweak (e.g. a server-held chain code that never leaves)
cases.append(("HD with private chain code", "lambda private", "the holder only", False))
print(f"  {'relation':>28} {'lambda':>26} {'who can transfer':>18} {'replay by outsider':>20}")
for name, lam, who, pub in cases:
    print(f"  {name:>28} {lam:>26} {who:>18} {str(pub):>20}", flush=True)
print()
print("RULE: an ECDSA signature is transferable along any publicly-known key translation;", flush=True)
print("      the only defences are (a) make lambda private, or (b) bind z to the key.", flush=True)
print("      Binding the key to z is exactly what domain separation / key commitment does,", flush=True)
print("      and (b) is the fix; (a) fails the moment the tweak is on-chain (it is).", flush=True)
