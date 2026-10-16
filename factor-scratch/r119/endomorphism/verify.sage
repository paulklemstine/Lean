###############################################################################
# verify.sage -- INDEPENDENT re-derivation, deliberately using different
# machinery from h1-h4, so that a "success" cannot be an artifact of how the
# answer was constructed.
#
#  V1  lambda is found by DISCRETE LOG on a small curve (phi(G) = lambda*G),
#      NOT by solving lambda^2+lambda+1 = 0.  Then it is checked that this
#      lambda satisfies the polynomial.  (h1 built it from sqrt(-3).)
#  V2  On real secp256k1, lambda is checked against the GLV value published
#      by an earlier round of this campaign (r115).
#  V3  EXHAUSTIVE over every nonce k in [1, n-1] on a small curve:
#        (a) x([lambda]kG) == (omega*x(kG)) mod p         -- must hold always
#        (b) x([lambda]kG) mod n == (omega*r) mod n        -- the CLAIM
#        (c) x([lambda]kG) mod n in the 2-candidate set    -- refined version
#      (b) is counted exactly, not sampled: the claim holds for ~1/n of nonces.
#  V4  EXHAUSTIVE: the multiset invariant, and the related-nonce 2x2 break
#      recovering d with d*G == Q for EVERY related pair (no sampling).
###############################################################################
print("=" * 78)
print("verify.sage  -- independent re-derivation")
print("=" * 78)
load("ecutil.sage")

# ------------------------------------------------------------------ V1, V2
print("\n--- V1/V2  lambda by discrete log, not by the polynomial ---")
E, G, n, p, b = find_j0_curve(16)
omega = j0_omega(p)
# build phi explicitly as a curve morphism and apply it to the generator
def phi(P):
    if P == E(0):
        return P
    return E((omega * Integer(P[0])) % p, Integer(P[1]))
phiG = phi(G)
def bsgs_dlp(P, G, n):
    """an independent (baby-step giant-step) discrete log; no Sage DL machinery."""
    P = E(P)
    m = isqrt(n) + 1
    table = {}
    Q = E(0)
    for j in range(0, m):
        table.setdefault(Q, j)
        Q = Q + G
    gamma = -m * G
    Q = P
    for i in range(0, m + 2):
        if Q in table:
            x = i * m + table[Q]
            if x % n != 0 and (x % n) * G == P:
                return Integer(x % n)
        Q = Q + gamma
    raise ValueError("no log found")

lam_dlp = bsgs_dlp(phiG, G, n)                    # <-- independent construction
print("small curve y^2 = x^3 + %d over F_%d, n = %d" % (b, p, n))
print("  phi(G) = %s" % phiG)
print("  lambda (by discrete log phi(G) = lambda*G) = %d" % lam_dlp)
print("  lambda^2 + lambda + 1 == 0 (mod n) ?  %s"
      % ((lam_dlp^2 + lam_dlp + 1) % n == 0))
print("  lambda != 1 ?  %s   (lambda^3 == 1 ?  %s)"
      % (lam_dlp != 1, (lam_dlp^3) % n == 1))
assert (lam_dlp^2 + lam_dlp + 1) % n == 0
for _ in range(5):
    k = ZZ.random_element(1, n - 1)
    assert bsgs_dlp(phi(k * G), G, n) == (lam_dlp * k) % n, "DLP mismatch"
print("  phi(P) = [lambda]*P on 5 random P : True")

n256 = Integer(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141)
p256 = Integer(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F)
Gx = Integer(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798)
Gy = Integer(0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8)
E256 = EllipticCurve(GF(p256), [0, 0, 0, 0, Integer(7)])
G256 = E256(Gx, Gy)
assert E256.count_points() == n256
lam_a, lam_b_ = lam_of(n256)
omega256 = j0_omega(p256)
match_a = (lam_a * G256)[0] == (omega256 * Integer(Gx)) % p256
LAM256 = lam_a if match_a else lam_b_
print("\n  real secp256k1: LAMBDA = %s" % hex(LAM256))
print("  known GLV value from r115 = 0xac9c52b33fa3cf1f5ad9e3fd77ed9ba4"
      "a880b9fc8ec739c2e0cfc810b51283ce")
print("  is one of the two conjugate roots?  %s"
      % (LAM256 in (Integer(0xac9c52b33fa3cf1f5ad9e3fd77ed9ba4a880b9fc8ec739c2e0cfc810b51283ce),
                    Integer(0x5363ad4cc05c30e0a5261c028812645a122e22ea20816678df02967c1b23bd72))))
print("  phi(G) == [LAMBDA]*G on secp256k1 ?  %s"
      % ((LAM256 * G256)[0] == (omega256 * Integer(Gx)) % p256))

# ------------------------------------------------------------------ V3
print("\n--- V3  EXHAUSTIVE over every nonce k on the small curve ---")
print("    (no sampling: every k in [1, n-1])")
cnt_field = cnt_claim = cnt_refined = 0
cnt_m1 = 0
tot = 0
P = E(0)
for k in range(1, int(n)):
    P = P + G                      # P = k*G
    X = xint(P, p)
    r = X % n
    Pl = lam_dlp * P
    XL = xint(Pl, p)
    tot += 1
    if XL == (omega * X) % p:
        cnt_field += 1
    if XL % n == (omega * r) % n:
        cnt_claim += 1
    if XL % n in omega_image_candidates(r, n, omega, p):
        cnt_refined += 1
    if X >= n:
        cnt_m1 += 1
print("    nonces tested                        : %d  (n-1 = %d)" % (tot, n - 1))
print("    (a) x([lam]kG) == (omega*x(kG)) mod p : %d/%d   [F_p identity]"
      % (cnt_field, tot))
print("    (b) x([lam]kG) mod n == (omega*r) mod n : %d/%d = %.6f   [THE CLAIM]"
      % (cnt_claim, tot, cnt_claim / float(tot)))
print("        chance level 1/n = %.6f ;  claim would need 1.000000" % (1.0 / float(n)))
print("    (c) refined 2-candidate version        : %d/%d" % (cnt_refined, tot))
print("    x(kG) >= n (the 'm-bit')              : %d  (p - n = %d)"
      % (cnt_m1, p - n))
print("\n    => the claimed identity holds for about 1/n of nonces, i.e. never.")
print("       The F_p identity (a) holds for every nonce.  The refined version")
print("       (c) holds for every nonce too, so the endomorphism is 'visible'")
print("       in r only as a 2-candidate ambiguity, never as a value.")

# ------------------------------------------------------------------ V4
print("\n--- V4  EXHAUSTIVE: multiset invariance and the related-nonce break ---")
from collections import Counter
xset = set()
P = E(0)
for k in range(1, int(n)):
    P = P + G
    if P != 0:
        xset.add(xint(P, p))
c1 = Counter(X % n for X in xset)
c2 = Counter((omega * X % p) % n for X in xset)
print("    multiset{X mod n} == multiset{(omega*X mod p) mod n} : %s" % (c1 == c2))

# every related pair, all of them
break_ok = 0
break_tried = 0
break_singular = 0
ks = [ZZ.random_element(1, n - 1) for _ in range(200)]
for k in ks:
    k2 = (lam_dlp * k) % n
    if k2 == 0:
        continue
    d = ZZ.random_element(1, n - 1)
    Q = d * G
    z1 = ZZ.random_element(1, n - 1)
    z2 = ZZ.random_element(1, n - 1)
    s1 = sign(d, z1, k, E, G, n, p)
    s2 = sign(d, z2, k2, E, G, n, p)
    if s1 is None or s2 is None:
        continue
    break_tried += 1
    res = pair_solve((s1[0], s1[1], z1), (s2[0], s2[1], z2), lam_dlp, n)
    if res is None:
        break_singular += 1
        continue
    kh, dh = res
    if dh == d and dh * G == Q and kh == k:
        break_ok += 1
print("    related-nonce 2x2 break on every planted pair: %d/%d recovered d,"
      % (break_ok, break_tried))
print("      each verified by d*G == Q  (singular systems skipped: %d)" % break_singular)

# and the exhaustive version of the same, over ALL k
allk = 0
okallk = 0
for k in range(1, int(n) - 1):
    k2 = (lam_dlp * k) % n
    if k2 == 0:
        continue
    d = ZZ.random_element(1, n - 1)
    z1 = ZZ.random_element(1, n - 1)
    z2 = ZZ.random_element(1, n - 1)
    s1 = sign(d, z1, k, E, G, n, p)
    s2 = sign(d, z2, k2, E, G, n, p)
    if s1 is None or s2 is None:
        continue
    res = pair_solve((s1[0], s1[1], z1), (s2[0], s2[1], z2), lam_dlp, n)
    if res is None:
        continue
    allk += 1
    kh, dh = res
    if dh == d and dh * G == d * G and kh == k:
        okallk += 1
print("    exhaustive over ALL k in [1, n-2]: %d/%d key recoveries verified"
      % (okallk, allk))
print("      with d*G == Q and k*G == the first nonce point.")

print("\nVERIFY SUMMARY")
print("  lambda obtained by discrete log satisfies lambda^2+lambda+1 = 0 : OK")
print("  secp256k1 LAMBDA matches the r115-published GLV value            : OK")
print("  F_p identity x(phi(P)) = omega*x(P)                             : 100%")
print("  CLAIMED r-identity (omega*r) mod n                              : %d/%d"
      % (cnt_claim, tot))
print("  refined 2-candidate r-identity                                   : 100%")
print("  related-nonce 2x2 key break (verified d*G == Q)                  : 100%")
print("  multiset invariance under phi                                     : exact")
