###############################################################################
# H1 — POSITIVE CONTROL for the omega / lambda endomorphism relation
#
# Two things are kept strictly apart, because conflating them is the trap:
#
#   (P) FIELD identity:  x( phi(P) ) == omega * x(P)  in F_p
#       where phi(x,y) = (omega*x, y).  This is the r117-verified automorphism.
#   (R) SIGNATURE identity:  x( [lambda] k G ) mod n == (omega * x(kG)) mod n
#       i.e. r_{lambda k} == omega * r_k (mod n).
#
# The brainstorm claims (R) is computable from the signature alone, via
# "x(kG) = r + m*n and the m-bit drops out mod n".
#
# The mod-n step is where it can break: the *field* product omega*x(P) is
# reduced mod p BEFORE the mod-n reduction, and p mod n != 0.
# So (R) is (omega*X mod p) mod n, and the integer identity
# (omega*X) mod n == (omega*r) mod n is only about the *unreduced* product.
#
# This script verifies, with full ground truth, which of (P) / (R) holds.
###############################################################################
print("=" * 78)
print("H1  positive control:  phi = [lambda]  on  E(F_p),  and the r-relation")
print("=" * 78)

# ---------------------------------------------------------------- curve setup
p  = Integer(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F)
a6 = Integer(7)
n  = Integer(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141)
Gx = Integer(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798)
Gy = Integer(0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8)

E = EllipticCurve(GF(p), [0, 0, 0, 0, a6])
G = E(Gx, Gy)

print("curve  y^2 = x^3 + 7   over F_p")
print("  #E(F_p) == n ?               ", E.count_points() == n, "  (cofactor 1, cyclic of prime order n)")
print("  n prime ?                    ", is_prime(n))
print("  p / n = 1 + eps,  p - n      =", p - n, " (~2^%.1f)" % RR(p - n).log(2))
print("  p < 2n ?                     ", p < 2 * n)
print("  n mod 3                      =", n % 3, " -> 3 | n-1 :", (n - 1) % 3 == 0)

# ------------------------------------------------- omega in F_p (cube root 1)
w3 = Mod(1, p)
while True:
    cand = ZZ(Mod(GF(p).random_element(), p))
    if cand == 0:
        continue
    c = Integer(Mod(cand, p)^Integer((p - 1) // 3))   # candidate cube root of unity
    if c != 1 and (c^3) % p == 1:
        omega = Integer(c)
        break
assert omega != 0 and (omega^3) % p == 1 and omega != 1, "omega broken"
print("\nomega in F_p:  omega^3 == 1 (mod p), omega != 1 :  OK")
print("  omega =", hex(omega))
print("  omega^2 + omega + 1 == 0 (mod p) :", (omega^2 + omega + 1) % p == 0)
print("  (omega^2 == omega+1 style)  omega^2 % p ==", hex((omega^2) % p))

# --------------------------------- lambda in Z/n : nontrivial cube root of 1
# lambda^2 + lambda + 1 = 0  <=>  (2 lambda + 1)^2 = -3
assert Mod(-3, n).is_square(), "need (-3|n) = 1"
w = ZZ(Mod(-3, n).sqrt())
lam_a = Integer(Mod(-1 + w, n) * Mod(2, n).inverse())
lam_b = Integer(Mod(-1 - w, n) * Mod(2, n).inverse())
print("\nnontrivial cube roots of unity mod n (2 of them; n prime, 3 | n-1):")
for nm, L in [("lam_a", lam_a), ("lam_b", lam_b)]:
    ok = (L != 1) and (L^3) % n == 1 and (L^2 + L + 1) % n == 0
    print("  %s = %s   lambda^2+lambda+1==0 mod n: %s   (lambda != 1: %s)"
          % (nm, hex(L), ok, L != 1))
assert (lam_a^2 + lam_a + 1) % n == 0 and (lam_b^2 + lam_b + 1) % n == 0
assert lam_b % n == (lam_a^2) % n, "the two roots should be conjugate (lam^2 = -1-lam)"

# ------------------------------------------------------------- the map phi
def phi_pt(P):
    """the group automorphism  (x,y) -> (omega*x, y)"""
    if P == E(0):
        return P
    return E(Integer(omega) * Integer(P[0]) % p, Integer(P[1]))

print("\n(P) field-level checks on phi = (x,y) -> (omega*x, y):")
ok_hom = ok_ord3 = ok_img = True
cnt = 0
for _ in range(40):
    k = ZZ.random_element(1, n - 1)
    P = k * G
    ok_img &= phi_pt(P) in E and (phi_pt(P)[1] == P[1])
    ok_hom &= (phi_pt(2 * P) == 2 * phi_pt(P)) and (phi_pt(3 * P) == 3 * phi_pt(P))
    ok_ord3 &= (phi_pt(phi_pt(phi_pt(P))) == P)
    ok_img &= (Integer(phi_pt(P)[0]) == Integer(omega) * Integer(P[0]) % p)
    cnt += 1
print("   phi(E) subset E and x(phi(P)) == omega*x(P) (mod p) :  %s   [%d points]"
      % (ok_img, cnt))
print("   phi is a group homomorphism                        :  %s" % ok_hom)
print("   phi^3 == id (order 3 automorphism)                 :  %s" % ok_ord3)

# --------------------------------- which lambda realises phi on E(F_p)?
# E(F_p) is cyclic of prime order n, so every automorphism is [lambda].
match_a = match_b = True
for _ in range(6):
    k = ZZ.random_element(1, n - 1)
    P = k * G
    match_a &= (Integer(lam_a) * P == phi_pt(P))
    match_b &= (Integer(lam_b) * P == phi_pt(P))
print("\n(P) phi == [lambda] on E(F_p):")
print("   phi == [lam_a]   :", match_a)
print("   phi == [lam_b]   :", match_b)
assert match_a or match_b, "phi must be a scalar mult on the cyclic prime-order group"
LAMBDA = lam_a if match_a else lam_b
OMEGA_SQ = lam_b if match_a else lam_a     # the other automorphism, (x,y)->(omega^2 x,y)
print("   => LAMBDA (for phi:(omega*x,y)) =", hex(LAMBDA))
print("   => conjugate  (for (omega^2*x,y)) =", hex(OMEGA_SQ))
print("   cross-check: [LAMBDA]*kG == phi(kG) on 25 fresh random k :",
      all((Integer(LAMBDA) * (kk := ZZ.random_element(1, n - 1)) * G) == phi_pt(kk * G)
          for _ in range(25)))

# =========================================================================
# (R) THE CLAIMED SIGNATURE-SIDE IDENTITY
# =========================================================================
print("\n" + "=" * 78)
print("(R) CLAIM:   r_{lambda*k} == (omega * x(kG)) mod n == (omega * r_k) mod n")
print("=" * 78)

trials = 300
hit_field = 0     # x([lam]kG) == (omega*x(kG)) mod p        -- should be ALL
hit_int   = 0     # (omega*x(kG)) mod n == (omega * r_k) mod n (integer product)
hit_claim = 0     # x([lam]kG) mod n == (omega * r_k) mod n -- the claim
hit_exact = 0     # x([lam]kG) mod n == (omega * x(kG)) mod n (unreduced integer)
mzero = 0
first = None
for _ in range(trials):
    k = ZZ.random_element(1, n - 1)
    P = k * G
    X = Integer(P[0])                       # x(kG) as an integer in [0,p)
    r = X % n                               # the signature r
    m = X // n                              # the "m-bit"   (must be in {0,1})
    assert m in (0, 1), "p < 2n must hold"
    mzero += (1 - m)

    Pl = Integer(LAMBDA) * P                # == [lambda*k] G  (ground truth)
    XL = Integer(Pl[0])
    rL = XL % n

    if XL == Integer(omega) * X % p:                       # (P), field identity
        hit_field += 1
    if Integer(omega) * X % n == Integer(omega) * r % n:   # m-bit drops out (TRUE arith)
        hit_int += 1
    if rL == Integer(omega) * r % n:                       # (R) as stated
        hit_claim += 1
        if first is None:
            first = (hex(r), hex(rL))
    if rL == Integer(omega) * X % n:                       # (R) with unreduced product
        hit_exact += 1

print(" trials                                                   : %d" % trials)
print(" (P) x([lam]kG) == (omega*x(kG)) mod p                    : %d/%d" % (hit_field, trials))
print("     m-bit identity (omega*X) mod n == (omega*r) mod n    : %d/%d  <-- TRUE integer arithmetic"
      % (hit_int, trials))
print("     m == 0 in %d/%d  (m in {0,1} always, checked)" % (mzero, trials))
print(" (R) x([lam]kG) mod n == (omega*r) mod n  [THE CLAIM]     : %d/%d" % (hit_claim, trials))
print("     x([lam]kG) mod n == (omega*X) mod n (unreduced)      : %d/%d" % (hit_exact, trials))
print(" expected under a uniform-random failure                  : %.4f" % (1.0 / float(n)))

# ------------------------------------------------------------ anatomy of why
# x([lam]kG) = (omega*X) mod p = omega*X - c*p  with c = floor(omega*X/p)
# so  rL = (omega*r - c*p) mod n,  and  p mod n = p - n != 0.  The c*p term
# does NOT drop out mod n.
print("\n anatomy:  x([lam]kG) = (omega*X) mod p = omega*X - c*p,   c = floor(omega*X/p)")
print("   => rL == (omega*r - c*(p-n)) mod n.  The 'm-bit' drops out; the 'c*p' term does not.")
print("   p - n (mod n) =", hex(p - n), " nonzero:", (p - n) % n != 0)
print("   demonstrated on 3 examples (all arithmetic exact):")
for _ in range(3):
    k = ZZ.random_element(1, n - 1)
    P = k * G
    X = Integer(P[0]); r = X % n
    XL = Integer((Integer(LAMBDA) * P)[0]); rL = XL % n
    W = Integer(omega) * X
    c = W // p
    lhs = rL
    rhs = (Integer(omega) * r - c * (p - n)) % n
    print("     X=0x%064x.. c=%d  rL=0x%064x..  rhs=0x%064x..  equal=%s"
          % (X, c, lhs, rhs, lhs == rhs))
print("\n   => rL is determined by X (not by r).  r leaves a 2-CANDIDATE ambiguity,")
print("      x = r or x = r+n, so from the signature alone you get 2 candidates, not a value:")
for _ in range(3):
    k = ZZ.random_element(1, n - 1)
    P = k * G
    X = Integer(P[0]); r = X % n; m = X // n
    XL = Integer((Integer(LAMBDA) * P)[0]); rL = XL % n
    cands = [(Integer(omega) * (r + j * n)) % p % n for j in (0, 1)]
    print("     m=%d  rL=0x%064x..  candidates={0x%064x.., 0x%064x..}  contains rL: %s"
          % (m, rL, cands[0], cands[1], rL in cands))

print("\nVERDICT on H1:")
print("  * phi:(x,y)->(omega*x,y) is an order-3 automorphism and phi == [%s] on E(F_p)  --  FIRES"
      % hex(LAMBDA)[:20] + "...")
print("  * x([lambda]kG) == (omega*x(kG)) mod p (field identity)  --  FIRES %d/%d" % (hit_field, trials))
print("  * the r-level identity  r_{lam k} == (omega*r) mod n  --  FIRES %d/%d  (chance: %.4f)"
      % (hit_claim, trials, 1.0 / float(n)))
print("  The mod-p reduction is what kills it: changing r -> r+n changes x(kG) by n,")
print("  and omega*(x+n) mod p != omega*x + omega*n (mod p).")
