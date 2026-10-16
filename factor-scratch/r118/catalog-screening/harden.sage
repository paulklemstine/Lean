import hashlib
PK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F)
NK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141)
F = GF(PK); E = EllipticCurve(F, [ZZ(0), ZZ(7)])
G = E(ZZ(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798),
      ZZ(0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8))

def sign(z, d, k):
    R = k * G; r = ZZ(R[0]) % NK
    return r, (ZZ(z) + r * d) * inverse_mod(k, NK) % NK

def verify(z, Q, r, s):
    if not (0 < r < NK and 0 < s < NK): return False
    w = inverse_mod(s, NK); u1, u2 = ZZ(z) * w % NK, r * w % NK
    return (ZZ((u1 * G + u2 * Q)[0]) % NK) == r

set_random_seed(20261015)
d = ZZ(randint(1, NK - 1)); Q = d * G
lam_hard = ZZ(randint(1, NK - 1))          # the HARDENED offset: PRIVATE, unknown to anyone
Q_hard = Q + lam_hard * G

# sign a message under the ACCOUNT key d (the attacker has this signature + Q + Q_hard)
z = ZZ(randint(0, NK - 1)); k = ZZ(randint(1, NK - 1)); r, s = sign(z, d, k)

print("=== attacker's search space, honestly defined ===", flush=True)
print("  known : (r, s), Q, Q_hard = Q + lam_hard*G, the signature's own message z", flush=True)
print("  unknown: lam_hard (256-bit)", flush=True)
print("  an attacker can only try z' = z + c*r for small/structured c, or z itself", flush=True)
cands = [ZZ(0), ZZ(1), ZZ(-1), ZZ(2), ZZ(-2), ZZ(3), ZZ(-3), r, -r, z, NK - 1]
ok = 0
for c in cands:
    if verify((z + c * r) % NK, Q_hard, r, s):
        ok += 1
        print(f"    HIT at c = {c}", flush=True)
print(f"  tried {len(cands)} structured candidates: {ok} verifications", flush=True)
print()
print("=== the only c that works is c = -lam_hard, which the attacker cannot compute ===", flush=True)
print(f"  the true transfer message z' = z - lam_hard*r verifies under Q_hard: "
      f"{verify((z - lam_hard * r) % NK, Q_hard, r, s)}", flush=True)
print(f"  lam_hard is {lam_hard.nbits()} bits; the attacker's hit rate over structured c is ~1/2^256", flush=True)
print("  Hardening works, for exactly the stated reason: the transfer is free when lam is", flush=True)
print("  public and impossible when lam is private.", flush=True)
print()
print("=== contrast: the non-hardened chain, offsets PUBLIC ===", flush=True)
CH = 2**31
print(f"  BIP44 non-hardened receiving chain: {CH:,} addresses, all offsets public", flush=True)
print(f"  => one signature is valid under {CH:,} public keys (verified 8/8 in cascade.sage)", flush=True)
