###############################################################################
# ecutil.sage -- shared primitives for the omega/lambda endomorphism study
#
# Everything here is deliberately "integer-level": points are always reduced
# back to explicit Integers before comparisons, so no comparison is ever made
# between a GF(p) element and an integer (that trap silently succeeds).
###############################################################################

def j0_omega(p):
    """a nontrivial cube root of unity in F_p (requires p = 1 mod 3)."""
    assert p % 3 == 1
    v = GF(p).multiplicative_generator()
    c = Integer(Mod(v, p)^Integer((p - 1) // 3))
    assert c != 1 and (c^3) % p == 1
    return c

def lam_of(n):
    """the two nontrivial cube roots of unity mod n; needs 3 | n-1 and (-3|n)=1."""
    assert (n - 1) % 3 == 0 and is_prime(n)
    assert Mod(-3, n).is_square()
    w = ZZ(Mod(-3, n).sqrt())
    inv2 = Integer(Mod(2, n).inverse())
    a = Integer(Mod(Integer(-1) + w, n) * inv2)
    b = Integer(Mod(Integer(-1) - w, n) * inv2)
    for L in (a, b):
        assert L != 1 and (L^3) % n == 1 and (L^2 + L + 1) % n == 0
    assert (a + b) % n == n - 1          # the two roots are conjugate
    return a, b

def find_j0_curve(nbits, tries=6000):
    """secp256k1-style curve y^2 = x^3 + b, p = 1 mod 3, order n prime, 3 | n-1."""
    for _ in range(tries):
        p = random_prime(2^nbits, lbound=2^(nbits - 10))
        if p % 3 != 1:
            continue
        for b in range(3, 60):
            if b >= p:
                break
            E = EllipticCurve(GF(p), [0, 0, 0, 0, Integer(b)])
            n = E.count_points()
            if not is_prime(n):
                continue
            if (n - 1) % 3 != 0 or not Mod(-3, n).is_square():
                continue
            g = E.gens()[0]
            assert n * g == 0 and g != 0
            return E, g, Integer(n), Integer(p), Integer(b)
    raise RuntimeError("no curve found")

def xint(P, p):
    """x-coordinate of a curve point (not infinity) as a plain Integer in [0,p)."""
    assert P != 0
    return Integer(Integer(P[0])) % Integer(p)

def phi_x(P, omega, p):
    """x-coord of the automorphism (x,y) -> (omega*x, y), as an Integer in [0,p)."""
    assert P != 0
    return (Integer(omega) * xint(P, p)) % Integer(p)

def sign(d, z, k, E, G, n, p):
    """ECDSA signature with nonce k.  Returns (r, s) or None if degenerate."""
    P = k * G
    if P == 0:
        return None
    r = xint(P, p) % n
    if r == 0:
        return None
    kinv = Integer(Mod(k, n).inverse())
    s = Integer(Mod(kinv * (z + r * d), n))
    if s == 0:
        return None
    return (r, s)

def pair_solve(sig1, sig2, LAM, n):
    """
    Recover (k1, d) from two signatures with nonces related by k2 = LAM*k1 mod n.

        s1*k1 = z1 + r1*d ;  s2*LAM*k1 = z2 + r2*d
    Two linear equations in the two unknowns (k1, d).  Returns None if det = 0.
    """
    (r1, s1, z1) = sig1
    (r2, s2, z2) = sig2
    det = (-s1 * r2 + r1 * LAM * s2) % n
    if det == 0:
        return None
    di = Integer(Mod(det, n).inverse())
    k = Integer(Mod((-z1 * r2 + r1 * z2) * di, n))
    d = Integer(Mod((s1 * z2 - LAM * s2 * z1) * di, n))
    return k, d

def omega_image_candidates(r, n, omega, p):
    """
    The two candidates for  x([lambda]kG) mod n  computable from r alone:
      x(kG) = r + j*n for j in {0,1}  (p < 2n), then reduce mod p.
    Returns a list of 1 or 2 residues.
    """
    out = []
    for j in (0, 1):
        X = r + j * n
        if X >= p:
            continue
        out.append((Integer(omega) * X) % p % n)
    return out
