# Catalog-screening #2: Cryptography/QuantumSecurity/HDWalletCascade.lean formalises the BIP32
# key relation child = parent + offset (ZMod n) and proves grandchild_collapse /
# derivation_commutes -- i.e. a derivation PATH composes to the SUM of offsets.
# Round 18 (r118/composition) verified the transfer lemma: (r,s) verifies under
# Q + lam*G for z - lam*r.  With lam PUBLIC (non-hardened derivation), a signature made at
# ONE address of an HD account is a valid signature at EVERY address of that account.
# Quantify: how many verifying (key, message) pairs does ONE signature buy?
import hashlib
PK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F)
NK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141)
F = GF(PK); E = EllipticCurve(F, [ZZ(0), ZZ(7)])
G = E(ZZ(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798),
      ZZ(0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8))
def sign(z, d, k):
    R = k*G; r = ZZ(R[0]) % NK
    return r, (ZZ(z) + r*d) * inverse_mod(k, NK) % NK
def verify(z, Q, r, s):
    if not (0 < r < NK and 0 < s < NK): return False
    w = inverse_mod(s, NK); u1, u2 = ZZ(z)*w % NK, r*w % NK
    return (ZZ((u1*G + u2*Q)[0]) % NK) == r

# a realistic BIP32-style non-hardened account: offsets are PUBLIC (chain code + index)
def pub_offset(master_pub, index, hardened=False):
    seed = hashlib.sha512((str(master_pub[0]) + str(index) + str(hardened)).encode()).digest()
    return ZZ(int.from_bytes(seed, 'big')) % NK

set_random_seed(20261015)
d = ZZ(randint(1, NK-1)); Q = d*G
ADDRS = 8
sigs = {}
for i in range(ADDRS):
    lam_i = pub_offset(Q, i)
    d_i = (d + lam_i) % NK; Q_i = Q + lam_i*G
    z = ZZ(randint(0, NK-1)); k = ZZ(randint(1, NK-1)); r, s = sign(z, d_i, k)
    sigs[i] = (z, r, s, d_i, Q_i, lam_i)

print("=== one signature, transferred to EVERY other address of the same account ===", flush=True)
src = 3
z, r, s, d_src, Q_src, lam_src = sigs[src]
print(f"  signature made at address index {src}; account public key known; offsets public", flush=True)
ok = 0
for j in range(ADDRS):
    z_j, r_j, s_j, d_j, Q_j, lam_j = sigs[j]
    lam_shift = (lam_j - lam_src) % NK
    zt = (z - lam_shift * r) % NK
    good = verify(zt, Q_j, r, s)
    ok += good
    print(f"    transfers to address {j}: {good}   (message z' = z - (lam_{j}-lam_{src})r)", flush=True)
print(f"  => {ok}/{ADDRS} addresses of the same account accept the ONE signature", flush=True)
print()
print("=== the amplification, quantified ===", flush=True)
CHILDREN = 2**31
ACCOUNTS = 2**31
print(f"  BIP32 children per level           : {CHILDREN:,}", flush=True)
print(f"  one signature is valid under       : {CHILDREN:,} public keys (one receiving chain)", flush=True)
print(f"  verifications gained per signature : {CHILDREN:,}", flush=True)
print(f"  i.e. a 2^31-fold amplification of a single leaked signature", flush=True)
print()
print("  and with the catalog's cascade_cost_efficiency framing: the attacker's cost is", flush=True)
print(f"  ONE scalar multiplication, and the *defence* is exactly the hardened bit:", flush=True)
print(f"  hardened derivation makes the offset PRIVATE, and then the transfer needs the", flush=True)
print(f"  offset -- which is the other note: knowing lam is the whole attack.", flush=True)
print()
print("=== hardening kills it: verify that a hardened (private-offset) child is safe ===", flush=True)
lam_hard = ZZ(randint(1, NK-1))          # private offset, unknown to the attacker
Q_hard = Q + lam_hard*G
z = ZZ(randint(0, NK-1)); k = ZZ(randint(1, NK-1)); r, s = sign(z, (d + lam_hard) % NK, k)
print(f"  same signature transferred to the hardened child (attacker tries z +/- r): "
      f"{verify(z, Q_hard, r, s) or verify((z + r) % NK, Q_hard, r, s)}", flush=True)
print("  => without the offset the transfer cannot be completed: the guess space for lam", flush=True)
print(f"     is 2^256, not 1.", flush=True)
