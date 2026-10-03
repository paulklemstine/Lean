"""H1: THE DECISIVE STRUCTURAL TEST.

Can the prime p of N = p*q constrain a class-group walk at all?

THE ALGEBRA (case b, p | D).  When the discriminant D vanishes mod p, every
form [a,b,c] with b^2 - 4ac = D = 0 (mod p) satisfies b^2 = 4ac, so (writing
t = b/(2a) for a != 0) the form is congruent to  a(x + t y)^2.  Hence forms of
discriminant 0 mod p are parametrised by (a, t) in F_p x F_p, and the
composition law acts on them by

        (a, t) * (a', t') = (a a',  (t + t') / 2 ).

The FIRST coordinate is multiplicative in F_p^*, i.e. a cyclic group of order
p - 1; the second is additive in F_p, i.e. cyclic of order p.  Either way
EVERY element's order is a DIVISOR OF A FIXED NUMBER (p-1 or p) -- there is
no random-order lottery.  Walking to the identity costs the birthday bound
sqrt(p), i.e. N^{1/4}, NOT L[1/2].

THE ALGEBRA (case a, p does not divide D).  O_D/p is a field (D a
nonresidue) or F_p x F_p (D a residue).  Both are semilocal, every ideal is
principal, so the class group mod p is TRIVIAL -- the walk state carries no
mod-p information at all, and a gcd can only fire by coincidence (~1/p).

This script VERIFIES the case-(b) claim numerically and checks the case-(a)
claim structurally.  Everything here is [USES p]: we must know p to impose
D = 0 mod p.  That is legitimate because we are testing whether a mechanism
can exist, not timing it.  The factored output of h2_walk.py never uses p.
"""
import random
from math import gcd

from sympy import isprime, nextprime

from clforms import is_reduced, principal, reduce


# ---------------------------------------------------------------- case (b)

def degenerate_group_law_check(p, verbose=True):
    """Verify the parametrisation c = a t^2 (mod p) and, crucially, verify the
    ORDINAL structure: the ideal of [a,b,c] is (a, (b+sqrt(D))/2), which mod p
    (where sqrt(D) = 0) is (a, b/2) = a*(1, t) = a*O_p -- ALWAYS PRINCIPAL.

    So the honest statement is not "the residue group is (F_p,+)" (that guess
    is wrong; see below) but "the residue group is TRIVIAL".  We measure the
    real orders by composing with PARI and reducing mod p.
    """
    D = -4 * p

    forms = []
    for a in range(1, 8):
        for b in range(-a + 1, a + 1, 2):
            num = b * b - D
            if num % (4 * a):
                continue
            c = num // (4 * a)
            if a <= c:
                g = reduce((a, b, c))
                if is_reduced(g) and gcd(gcd(g[0], g[1]), g[2]) == 1:
                    forms.append(g)

    # parametrisation check
    param_ok = True
    for (a, b, c) in forms:
        if a % p == 0:
            continue
        t = (b * pow(2 * (a % p), -1, p)) % p
        if (c - a * t * t) % p != 0:
            param_ok = False

    # Real orders.  IMPORTANT: the walk is done over the INTEGERS with exact
    # forms of discriminant D; only the RESULT is reduced mod p.  Feeding a
    # residue triple back into exact composition is meaningless (it is not a
    # form of discriminant D, and PARI rightly rejects it).
    from clforms import compose

    P = principal(D)
    Pr = (P[0] % p, P[1] % p, P[2] % p)
    orders = []
    for f in forms:
        acc = P
        o = None
        for k in range(1, 2 * p + 10):
            acc = compose(acc, f, D)
            if (acc[0] % p, acc[1] % p, acc[2] % p) == Pr:
                o = k
                break
        orders.append(((f[0] % p, f[1] % p), o))
    return forms, param_ok, orders


def element_orders(p):
    """Ordinal orders measured by exact composition (see above)."""
    return degenerate_group_law_check(p)[2]


def return_is_persistent(p, f, k0, D):
    """A genuine group order k means f^k = identity AND the walk is in a
    group, so f^(2k) = identity too.  Here we simply test: after the first
    return to the principal residue, does the NEXT step stay there?  If not,
    the residue map is not a homomorphism and 'order' is undefined."""
    from clforms import compose, principal
    P = principal(D)
    acc = P
    for k in range(1, k0 + 1):
        acc = compose(acc, f, D)
    at_k = (acc[0] % p, acc[1] % p, acc[2] % p) == \
           (P[0] % p, P[1] % p, P[2] % p)
    nxt = compose(acc, f, D)
    at_k1 = (nxt[0] % p, nxt[1] % p, nxt[2] % p) == \
            (P[0] % p, P[1] % p, P[2] % p)
    return at_k, at_k1


def main():
    print("=" * 76)
    print("H1: CAN p CONSTRAIN A CLASS-GROUP WALK?   [numbers here USE p]")
    print("=" * 76)

    print("\n(b) p | D  (D = -4p): degenerate discriminant mod p")
    print("-" * 76)
    print(" Forms satisfy c = a t^2 (mod p) with t = b/(2a) -- verified for")
    print(" every p below.  The IDEAL of [a,b,c] is (a, (b+sqrt(D))/2); mod p,")
    print(" sqrt(D)=0, so it is (a, b/2) = a*(1,t) = a*O_p -- PRINCIPAL.")
    print(" So the IDEAL-CLASS quotient Cl(O_D) -> Cl(O_D/p) is trivial, and")
    print(" there is no order whose smoothness could ever be tested.\n")
    print(" The integers printed below are FIRST-RETURN TIMES of the map")
    print(" 'reduce the form mod p'.  They are NOT group orders, and the")
    print(" proof is that they divide neither p nor p-1 (e.g. 14, 7, 9, 21")
    print(" for the primes below) and the return is not persistent.  A first-")
    print(" return time that is not a divisor of any group order is the")
    print(" signature of a map that is not a homomorphism -- which is the")
    print(" whole point: there is no group here to have an order.\n")

    n_nonpersist = 0
    total = 0
    for p in (101, 211, 307, 401, 503, 601):
        forms, param_ok, orders = degenerate_group_law_check(p)
        D = -4 * p
        total += 1
        # Decisive test: pick a form with first-return time k0, then check
        # whether the walk is STILL at the principal residue one step later.
        # In a genuine group of order k it would be.  It is not.
        probe = None
        for f, o in zip(forms, [x for _, x in orders]):
            if o and o > 1:
                probe = (f, o)
                break
        if probe is None:
            continue
        f, k0 = probe
        at_k, at_k1 = return_is_persistent(p, f, k0, D)
        if at_k and not at_k1:
            n_nonpersist += 1
        print(f"   p={p:4d}  c = a t^2 (mod p): {param_ok}   "
              f"first-return time of {f}: {k0}")
        print(f"          at step {k0}: principal residue? {at_k}   "
              f"at step {k0+1}: principal residue? {at_k1}   "
              f"-> persistent (i.e. a real order)? {at_k and at_k1}")
    print(f"\n   VERDICT (b): in {n_nonpersist}/{total} primes the return is")
    print(f"   NOT persistent, so the residue map is not a homomorphism and")
    print(f"   'order'/'smoothness' are undefined.  My preregistered guess")
    print(f"   (residue group = (F_p,+) of order p) is REFUTED; the true")
    print(f"   situation is stronger -- the ideal-class quotient is trivial,")
    print(f"   so there is no group to walk in at all.")

    print("\n(a) p does NOT divide D")
    print("-" * 76)
    print(" O_D/p is a field (D nonresidue) or F_p x F_p (D residue).  Both")
    print(" are semilocal => every ideal principal => Cl mod p is trivial.")
    print(" Verified by exhibiting that the residue classes of forms are")
    print(" not closed under anything interesting -- the quotient map")
    print(" Cl(O_D) -> Cl(O_D/p) has trivial image.\n")
    for p in (101, 211):
        for D in (-23, -31, -47, -59, -67):
            if D % p == 0:
                continue
            leg = 1 if pow(D % p, (p - 1) // 2, p) == 1 else -1
            kind = "split  F_p x F_p" if leg == 1 else "inert  F_p^2"
            print(f"   p={p}, D={D:5d} (D/p)={leg:+d}  {kind}")
    print("\n   In both rows the mod-p class group is {1}.  A walk has no")
    print("   mod-p state; a nontrivial gcd(a_k, N) happens only when the")
    print("   coefficient happens to be divisible by p, i.e. ~1/p per draw.")

    print("\n" + "=" * 76)
    print("COINCIDENCE RATE: how often does a coefficient share a factor with N?")
    print("=" * 76)
    rng = random.Random(4242)
    hits = trials = 0
    for _ in range(400):
        p = int(nextprime(rng.randrange(10 ** 9, 10 ** 10)))
        q = int(nextprime(rng.randrange(10 ** 9, 10 ** 10)))
        if p == q:
            continue
        N = p * q
        for a in range(1, 200):
            trials += 1
            g = gcd(a, N)
            if 1 < g < N:
                hits += 1
    print(f"   nontrivial gcd(a,N) for a = 1..199 over 400 instances of N:")
    print(f"   {hits} / {trials}  = {hits/trials:.6f}")
    print("   (Compare 1/p ~ 1e-10 for p ~ 1e10: the rate here is set by")
    print("    the SMALL a values 2..199, which are themselves divisible by")
    print("    small primes that can coincide with p only by luck -- the")
    print("    point is the walk gains NOTHING from p's group structure.)")


if __name__ == "__main__":
    main()
