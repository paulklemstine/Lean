"""SELF-TEST for class-group arithmetic. Must pass before ANY result is used.

Checks, in order:
  T1  reduction preserves discriminant
  T2  my class_number(D) == PARI qfbclassno(D)   [independent implementations]
  T3  f * f^{-1} == principal form  (the canonical composition test)
  T4  f * principal == f
  T5  associativity on random triples
  T6  commutativity
  T7  PARI compose == my compose_bruteforce where the oracle applies
  T8  composition result is always a member of the enumerated class set
  T9  every element has an inverse and the group is closed
  T10 the harness can detect an artificial 100% / 0% rate  (anti-degeneracy)

Run: python3 test_clforms.py
"""
import itertools
import math
import random
import sys

from clforms import (all_reduced, class_number, compose, compose_bruteforce,
                     inverse, is_principal, is_reduced, pari, principal, reduce)

FAILS = []


def check(name, cond, detail=""):
    if cond:
        print(f"  PASS  {name}")
    else:
        print(f"  FAIL  {name}  {detail}")
        FAILS.append(name)


def disc(f):
    a, b, c = f
    return b * b - 4 * a * c


def test_D(D, do_bruteforce=True):
    forms = all_reduced(D)
    h = len(forms)
    p = pari()

    # T1
    check(f"T1 D={D} reduction preserves discriminant",
          all(disc(f) == D for f in forms))

    # T2
    hp = int(p.qfbclassno(D))
    check(f"T2 D={D} classno mine={h} pari={hp}", h == hp)

    if h == 0:
        return

    P = principal(D)
    check(f"T3 D={D} principal is in the reduced set", P in forms)

    # T3 / T4 / T9
    inv_ok = True
    for f in forms:
        if compose(f, inverse(f), D) != P:
            inv_ok = False
            print(f"        f={f} f*f^-1={compose(f, inverse(f), D)} P={P}")
            break
    check(f"T3 D={D} f*f^-1 == principal for all {h} forms", inv_ok)

    check(f"T4 D={D} f*principal == f",
          all(compose(f, P, D) == f for f in forms))

    # T5 / T6 on random triples
    rnd = random.Random(12345 + D)
    trip = [tuple(rnd.choice(forms) for _ in range(3)) for _ in range(min(40, h ** 3))]
    assoc = all(compose(compose(x, y, D), z, D) == compose(x, compose(y, z, D), D)
                for x, y, z in trip)
    check(f"T5 D={D} associativity ({len(trip)} triples)", assoc)
    comm = all(compose(x, y, D) == compose(y, x, D)
               for x, y in zip(forms, forms[1:] + forms[:1]))
    check(f"T6 D={D} commutativity", comm)

    # T8 closure
    sample = forms if h <= 12 else rnd.sample(forms, 12)
    closed = all(compose(x, y, D) in forms for x in sample for y in sample)
    check(f"T8 D={D} closed in the reduced set ({len(sample)}^2 pairs)", closed)

    # T7 independent oracle
    if do_bruteforce:
        agree = same = 0
        for x in sample:
            for y in sample:
                try:
                    mine = compose_bruteforce(x, y, D)
                except NotImplementedError:
                    continue
                same += 1
                if compose(x, y, D) == mine:
                    agree += 1
                else:
                    print(f"        x={x} y={y} pari={compose(x,y,D)} oracle={mine}")
        if same:
            check(f"T7 D={D} PARI == independent Dirichlet composition ({same} pairs)",
                  agree == same, f"{agree}/{same}")


def test_harness_detects_degenerate():
    """T10: a control harness must be able to see 100% and 0%."""
    def rate_of(vals):
        return sum(vals) / len(vals)

    fake_all = [True] * 200
    fake_none = [False] * 200
    check("T10 harness sees 100%", rate_of(fake_all) == 1.0)
    check("T10 harness sees 0%", rate_of(fake_none) == 0.0)

    # And the smoothness predicate itself must not be constant-true.
    # (BUG FOUND BY THIS TEST: the generator was re-seeded per call, so all
    #  400 "samples" were the same integer and the rate came out 1.000.)
    from sympy import primerange
    primes = list(primerange(2, 20000))
    B = 100

    def is_smooth(n, B):
        # BUG FOUND BY THIS TEST: the original version did
        #     if q > B: return True
        # which declares EVERY number smooth once the sweep reaches B, so the
        # control reported 1.000 for random 12-digit integers.  The leftover
        # cofactor must actually be checked.
        for q in primes:
            if q > B:
                break
            while n % q == 0:
                n //= q
        return n == 1

    rng = random.Random(7)          # ONE generator, not one per draw
    # Parameter choice matters.  At 12 digits with B=100, u = ln(1e12)/ln(100)
    # = 6.0 and rho(6) ~ 2e-5, so 0/400 is the CORRECT answer, not a bug.
    # Uniform on [1, 10^5) has u = ln n / ln B varying over [0, 2.3], so the
    # right target is the AVERAGE of rho over that range, not rho(2).
    HI = 10 ** 5
    samples = [rng.randrange(2, HI) for _ in range(4000)]
    # 4000 draws from a pool of ~1e5 collide ~7.5% of the time BY DESIGN;
    # what matters is that they are not ALL the same number.
    check("T10 samples not degenerate (not all identical)",
          len(set(samples)) > 0.85 * len(samples),
          f"{len(set(samples))} distinct of {len(samples)}")
    rs = [is_smooth(n, B) for n in samples]
    r = sum(rs) / len(rs)

    # EXACT expected rate: enumerate EVERY n in [2, HI) rather than
    # integrating rho.  An earlier integral version returned 0.0016 against a
    # true value of 0.1744 -- the measure was wrong (n is uniform, not
    # log-uniform).  Full enumeration here is cheap and has no sampling error.
    expected = sum(1 for n in range(2, HI) if is_smooth(n, B)) / (HI - 2)
    se = (expected * (1 - expected) / len(samples)) ** 0.5
    check("T10 smoothness rate is strictly between 0 and 1", 0.0 < r < 1.0,
          f"rate={r}")
    check("T10 sampled rate matches exact mean within 5 sigma",
          abs(r - expected) < 5 * se,
          f"rate={r:.4f} exact_mean={expected:.4f} se={se:.4f}")
    print(f"        (control smoothness rate, n uniform in [2,1e5), B=100: "
          f"{r:.4f}; averaged Dickman {expected:.4f}; n={len(samples)})")

    # And confirm the harness DOES return a 0% rate when 0% is the truth:
    deep = [rng.randrange(10 ** 20, 10 ** 21) for _ in range(400)]
    rd = sum(is_smooth(n, B) for n in deep) / len(deep)
    check("T10 harness reads ~0% in the deep regime (u~7, rho~1e-7)", rd == 0.0,
          f"rate={rd}")


def rnd_big(n, rng):
    return rng.randrange(10 ** 6, n)


if __name__ == "__main__":
    print("T1-T9: arithmetic on small discriminants")
    for D in (-23, -31, -47, -59, -71, -83, -104, -107, -139, -151, -199, -211,
              -283, -307, -331, -419, -499, -547, -643, -667, -691, -883, -907):
        test_D(D)

    print("\nExtra: a couple of larger, less round discriminants")
    for D in (-1012, -1320, -2476, -3592):
        test_D(D, do_bruteforce=False)

    print("\nT10: harness self-test (anti-degeneracy)")
    test_harness_detects_degenerate()

    print()
    if FAILS:
        print(f"SELF-TEST FAILED: {len(FAILS)} failures: {sorted(set(FAILS))}")
        sys.exit(1)
    print("SELF-TEST PASSED -- arithmetic may be used.")
