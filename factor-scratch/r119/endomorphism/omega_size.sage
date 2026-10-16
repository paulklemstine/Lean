###############################################################################
# omega_size.sage -- the EXACT condition under which the claimed identity holds,
# and why a tiny curve can "confirm" the brainstorm while secp256k1 refutes it.
#
# EXACT derivation (verified exhaustively below, identity by identity):
#
#   X      = x(kG)                       in [0, p)
#   r      = X mod n                     (the signature's r)
#   x(lam*kG) = (omega*X) mod p = omega*X - c*p,   c = floor(omega*X/p) in [0, omega)
#   r(lam*k)  = x(lam*kG) mod n
#
#   claim:  r(lam*k) == (omega*r) mod n
#    <=>   (omega*X - c*p) == omega*X   (mod n)
#    <=>   c*p == 0 (mod n)
#    <=>   c == 0 (mod n)                        [p is a unit mod n]
#
# So the claim holds exactly for those nonces k with floor(omega*X/p) a multiple
# of n.  Since c is spread over [0, omega):
#     * omega >> n  (secp256k1: both 256-bit)   rate ~ (omega/n)/omega = 1/n ~ 2^-256
#     * omega << n  or  p == n  (tiny curve)     rate can be 1/omega or even 1
#
# A tiny curve with a small omega, or with p == n, can therefore make the claim
# hold for a large fraction of nonces.  That is a parameter artifact, NOT a
# property of the endomorphism, and it is the trap a small-curve "check" of
# this brainstorm would fall into.
###############################################################################
print("=" * 78)
print("omega_size.sage  exact condition for the claimed r-identity")
print("=" * 78)
load("ecutil.sage")

def exhaustive(E, G, n, p, omega, La, limit=None):
    tot = 0
    claims = 0
    cmult = 0
    P = E(0)
    kmax = int(n) if limit is None else int(limit)
    for k in range(1, min(kmax, int(n))):
        P = P + G
        X = xint(P, p)
        r = X % n
        XL = xint(La * P, p)
        c = (omega * X) // p
        tot += 1
        if XL % n == (omega * r) % n:
            claims += 1
        if (c * p) % n == 0:
            cmult += 1
    return tot, claims, cmult

print("\nscanning small prime-order j=0 curves (prime n, 3 | n-1, p = 1 mod 3)\n")
print("    %-7s %-9s %-9s %-8s %-7s %-9s %-9s %-9s %s"
      % ("n", "p", "p-n", "omega", "om/n", "1/omega", "1/n", "CLAIM rate",
         "c*p==0 rate (the exact rule)"))
print("    " + "-" * 100)
seen = 0
tries = 0
curves = []
while seen < 8 and tries < 40:
    tries += 1
    nb = 12 if seen % 2 == 0 else 15
    E, G, n, p, b = find_j0_curve(nb)
    omega = j0_omega(p)
    La, Lb = lam_of(n)
    if (La * G)[0] != (omega * Integer(G[0])) % p:
        La, Lb = Lb, La
    if (La * G)[0] != (omega * Integer(G[0])) % p:
        continue
    tot, claims, cmult = exhaustive(E, G, n, p, omega, La)
    curves.append((n, p, omega, tot, claims, cmult))
    print("    %-7d %-9d %-9d %-8d %-7.3f %-9.4f %-9.5f %-9.5f %d/%d  %s"
          % (n, p, p - n, omega, float(omega) / float(n), 1.0 / float(omega),
             1.0 / float(n), claims / float(tot), cmult, tot,
             "EXACT MATCH" if claims == cmult else "MISMATCH"))
    seen += 1

print("\n  CLAIM rate == (c*p == 0 mod n) rate on every curve tested:",
      all(c == cm for (_, _, _, _, c, cm) in curves))
print("  i.e. the derived condition is verified exhaustively, curve by curve.")

# ---------------------------------------------------------------- the extremes
print("\n--- a curve where the claim holds trivially (found by scanning) ---")
print("    y^2 = x^3 + 39 over F_2791 with n = 2791 (== p, an ANOMALOUS curve)")
print("    and omega = 91.  Exhaustively over all 2790 nonces the earlier scan gave")
print("      CLAIM holds 2790/2790 = 100%,  c*p == 0 (mod n) holds 2790/2790,")
print("    while 1/n = 0.000358 and 1/omega = 0.011.")
print("    With p == n every x(kG) is already < n and the whole computation reduces")
print("    mod p, so the claim becomes an identity.  Such a curve 'confirms' the")
print("    brainstorm.  It is not a model of secp256k1, where omega and n are BOTH")
print("    256-bit integers and p - n = 2^128.3.")

# ---------------------------------------------------------------- secp256k1
print("\n--- secp256k1 (the real target) ---")
n256 = Integer(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141)
p256 = Integer(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F)
om256 = j0_omega(p256)
print("    omega has %d bits, n has %d bits, so omega/n ~ 2^%.1f"
      % (om256.nbits(), n256.nbits(),
         float(RR(om256).log(2)) - float(RR(n256).log(2))))
print("    c = floor(omega*X/p) ranges over ~2^%d values, of which those divisible"
      % om256.nbits())
print("    by n number about omega/n ~ 2^%.1f, each with probability ~1/omega"
      % (float(RR(om256).log(2)) - float(RR(n256).log(2))))
print("    => P(claim holds) ~ 1/n ~ 2^-256.  h1 measured 0/300 on real secp256k1.")
print("\nVERDICT: the brainstorm's step '(omega*x(kG)) mod n == (omega*r) mod n'")
print("silently replaced (omega*X mod p) with omega*X.  The difference is exactly")
print("c*p with c = floor(omega*X/p), and it vanishes mod n only when c*p == 0")
print("(mod n) -- a 1/n event on secp256k1.")
