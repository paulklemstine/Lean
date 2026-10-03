"""Binary quadratic form arithmetic for imaginary quadratic fields.

A form is the triple (a,b,c) meaning a*x^2 + b*x*y + c*y^2, discriminant
D = b^2 - 4*a*c < 0.  Reduced positive definite:
    |b| <= a <= c,  and b >= 0 if (|b| == a or a == c).
Principal form: [1, b0, (b0^2-D)/4], b0 = 0 if D=0 mod 4, b0 = 1 if D=1 mod 4.

Composition is delegated to PARI's qfbcompraw, but this module carries its
OWN reduction and enumeration so that (a) the class number can be cross-checked
against PARI qfbclassno, and (b) composition results can be cross-checked
against an independent brute-force Dirichlet composition.  Do not trust
composition until test_clforms.py passes.
"""
from math import gcd, isqrt

_P = None


def pari():
    global _P
    if _P is None:
        import cypari2
        _P = cypari2.Pari()
    return _P


# ---------------------------------------------------------------- reduction

def reduce(f):
    """Reduce positive definite (a,b,c). D = b^2-4ac is invariant and is
    computed ONCE from the input; every subsequent update derives c from D,
    never from the current b.  (Getting this wrong was bug #1.)"""
    a, b, c = f
    if a < 0:
        a, b, c = -a, -b, -c
    D = b * b - 4 * a * c
    while True:
        if b > a or b <= -a:
            # push b into (-a, a]
            if b > a:
                k = (b + a) // (2 * a)
            else:
                k = -((-b + a) // (2 * a))
            b -= 2 * a * k
            num = b * b - D
            assert num % (4 * a) == 0, (f, a, b, D)
            c = num // (4 * a)
        if a > c:
            a, c = c, a
            b = -b
            continue
        break
    # Final canonicalization (Cox): b >= 0 whenever |b| == a or a == c.
    # This is the "ambiguous-form b-parity normalization" -- without it a
    # principal form comes back as (1,-1,167) instead of (1,1,167), which
    # silently breaks every identity/inverse test.  (Bug #3.)
    if (abs(b) == a or a == c) and b < 0:
        b = -b
    return (a, b, c)


def is_reduced(f):
    a, b, c = f
    if not (abs(b) <= a <= c):
        return False
    if (abs(b) == a or a == c) and b < 0:
        return False
    return True


def principal(D):
    b0 = 0 if D % 4 == 0 else 1
    return (1, b0, (b0 * b0 - D) // 4)


def inverse(f):
    return (f[0], -f[1], f[2])


def is_principal(f):
    return f[0] == 1


# -------------------------------------------------------------- enumeration

def all_reduced(D, primitive_only=True):
    """All canonically-reduced positive definite forms of discriminant D.

    Canonical form convention (Cox):  -a < b <= a,  a <= c,  and b >= 0
    whenever |b| == a or a == c.  So b runs over BOTH signs for |b| < a < c;
    scanning only non-negative b silently drops half the class group, which
    was bug #2.

    primitive_only: for a NON-FUNDAMENTAL D, reduced forms with
    gcd(a,b,c) > 1 also exist, but they are not classes of the order's ideal
    class group; they correspond to lower-order discriminants.  The class
    number is the count of PRIMITIVE forms only.  Ignoring this gave 20 vs
    the correct 15 at D = -2476 (bug #4).  For fundamental D every form is
    primitive, so this flag is a no-op there.
    """
    b0 = 0 if D % 4 == 0 else 1
    seen = set()
    out = []
    lim = isqrt(abs(D) // 3) + 2
    for a in range(1, lim + 1):
        # b with b == D (mod 2), in the canonical window -a < b <= a
        bstart = -a + 1 + ((b0 - (-a + 1)) % 2)
        for b in range(bstart, a + 1, 2):
            num = b * b - D
            if num % (4 * a) != 0:
                continue
            c = num // (4 * a)
            if a <= c:
                g = reduce((a, b, c))
                if primitive_only and gcd(gcd(a, b), c) > 1:
                    continue
                if is_reduced(g) and g not in seen:
                    seen.add(g)
                    out.append(g)
    out.sort()
    return out


def class_number(D):
    return len(all_reduced(D))


# --------------------------------------------------------------- composition

def compose(f, g, D):
    """Compose two reduced forms of discriminant D, return reduced form."""
    p = pari()
    r = p.qfbcompraw(p.Qfb(*f), p.Qfb(*g))
    a, b, c = int(r[0]), int(r[1]), int(r[2])
    return reduce((a, b, c))


def compose_bruteforce(f, g, D):
    """Independent Dirichlet composition, no PARI. Used as an oracle.

    Handles gcd(a1,a2)=1 with a1,a2 odd (the classical CRT formula); raises
    NotImplementedError otherwise so the caller can compare only where the
    oracle applies.
    """
    a1, b1, _ = reduce(f)
    a2, b2, _ = reduce(g)
    if a1 % 2 == 0 or a2 % 2 == 0:
        raise NotImplementedError("even leading coefficient")
    d = gcd(a1, a2)
    if d != 1:
        raise NotImplementedError("non-coprime leading coefficients")
    # find b: b = b1 (mod 2a1), b = b2 (mod 2a2), b^2 = D (mod 4 a1 a2)
    m1, m2 = 2 * a1, 2 * a2
    b = b1 % m1
    # CRT step
    while b % m2 != b2 % m2:
        b += m1
        if b > 8 * a1 * a2:
            raise NotImplementedError("CRT failed")
    mod = 4 * a1 * a2
    # adjust by multiples of 2*a1*a2 to fix b^2 = D (mod mod)
    step = 2 * a1 * a2
    bb = b
    for k in range(0, 2 * a1):
        bb = b + k * step
        if (bb * bb - D) % mod == 0:
            break
    else:
        raise NotImplementedError("no lift")
    s = a1 * a2
    c = (bb * bb - D) // (4 * s)
    return reduce((s, bb, c))
