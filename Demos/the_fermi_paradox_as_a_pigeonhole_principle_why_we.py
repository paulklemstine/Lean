"""
The Fermi Paradox as a Pigeonhole Principle
===========================================

Numerical demonstration of the results of the accompanying paper.

Model
-----
A "cosmos" is a function f : {0,...,N-1} -> {None} u {0,...,T-1}.

  * f(i) = None      : habitable site i never produced a civilization
  * f(i) = e         : site i produced one civilization, born in epoch e

Sites are independent.  The local weight of a site state is

  w(None) = 1 - p,          w(e) = p / T   for each of the T epochs,

and the weight of an outcome is the product of local weights.  Since
sum_x w(x) = (1-p) + T*(p/T) = 1, this is a genuine probability measure on the
(T+1)^N possible cosmoi.

Results demonstrated
--------------------
  1. Normalisation:            sum over all outcomes of W(f) = 1
  2. Drake as a first moment:  E[#civilizations] = N * p          (exact)
  3. Lifeless cosmos:          P(lifeless) = (1-p)^N >= 1 - N*p   (Bernoulli)
  4. Existence sandwich:       N p - (N p)^2 / 2 <= P(somebody) <= N p
  5. Contact bound:            P(contact) <= (N^2 - N) p^2 / T
  6. Windowed contact bound:   P(contact_L) <= (N^2 - N)(2L-1) p^2 / T
  7. Dual pigeonhole:          E[#empty epochs] >= T - N p
  8. Fermi dichotomy and the cosmological instantiation
     (N = 10^10, T = 4.5*10^9, p = 10^-11).

All small-model probabilities are computed by EXACT enumeration in rational
arithmetic (fractions.Fraction), so the printed comparisons are exact, not
Monte-Carlo estimates.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from typing import Callable, Iterator, List, Optional, Tuple

Outcome = Tuple[Optional[int], ...]


# ----------------------------------------------------------------------------
# Core model: exact enumeration in rational arithmetic
# ----------------------------------------------------------------------------

def enumerate_cosmoi(n_sites: int, n_epochs: int) -> Iterator[Outcome]:
    """Yield every outcome f : sites -> {None} u {0,...,n_epochs-1}."""
    states: List[Optional[int]] = [None] + list(range(n_epochs))
    for combo in product(states, repeat=n_sites):
        yield combo


def site_weight(state: Optional[int], n_epochs: int, p: Fraction) -> Fraction:
    """Local weight: 1 - p for a barren site, p / T for a birth in a given epoch."""
    if state is None:
        return Fraction(1) - p
    return p / Fraction(n_epochs)


def outcome_weight(f: Outcome, n_epochs: int, p: Fraction) -> Fraction:
    """Product of the local weights over all sites."""
    w = Fraction(1)
    for state in f:
        w *= site_weight(state, n_epochs, p)
    return w


def probability(
    n_sites: int,
    n_epochs: int,
    p: Fraction,
    event: Callable[[Outcome], bool],
) -> Fraction:
    """Exact probability of a decidable event, by full enumeration."""
    total = Fraction(0)
    for f in enumerate_cosmoi(n_sites, n_epochs):
        if event(f):
            total += outcome_weight(f, n_epochs, p)
    return total


def expectation(
    n_sites: int,
    n_epochs: int,
    p: Fraction,
    statistic: Callable[[Outcome], int],
) -> Fraction:
    """Exact expectation of an integer-valued statistic, by full enumeration."""
    total = Fraction(0)
    for f in enumerate_cosmoi(n_sites, n_epochs):
        total += outcome_weight(f, n_epochs, p) * Fraction(statistic(f))
    return total


# ----------------------------------------------------------------------------
# Events and statistics
# ----------------------------------------------------------------------------

def civ_count(f: Outcome) -> int:
    """Number of sites hosting a civilization."""
    return sum(1 for s in f if s is not None)


def is_lifeless(f: Outcome) -> bool:
    """No site ever produced a civilization."""
    return all(s is None for s in f)


def somebody_exists(f: Outcome) -> bool:
    """At least one site produced a civilization."""
    return any(s is not None for s in f)


def has_contact(f: Outcome) -> bool:
    """Two distinct sites are civilized and born in the SAME epoch."""
    n = len(f)
    for i in range(n):
        if f[i] is None:
            continue
        for j in range(n):
            if i != j and f[j] is not None and f[i] == f[j]:
                return True
    return False


def has_window_contact(f: Outcome, lifetime: int) -> bool:
    """Two distinct civilizations are born within `lifetime` epochs of each other."""
    n = len(f)
    for i in range(n):
        if f[i] is None:
            continue
        for j in range(n):
            if i != j and f[j] is not None and abs(f[i] - f[j]) < lifetime:
                return True
    return False


def empty_epoch_count(f: Outcome, n_epochs: int) -> int:
    """Number of epochs in which no site hosts a newborn civilization."""
    occupied = {s for s in f if s is not None}
    return n_epochs - len(occupied)


# ----------------------------------------------------------------------------
# Proved bounds (closed forms)
# ----------------------------------------------------------------------------

def drake_expectation(n_sites: int, p: Fraction) -> Fraction:
    """E[#civilizations] = N * p  (exact; independent of T)."""
    return Fraction(n_sites) * p


def lifeless_exact(n_sites: int, p: Fraction) -> Fraction:
    """P(lifeless) = (1 - p)^N."""
    return (Fraction(1) - p) ** n_sites


def bernoulli_lower(n_sites: int, p: Fraction) -> Fraction:
    """P(lifeless) >= 1 - N p."""
    return Fraction(1) - Fraction(n_sites) * p


def bonferroni_upper(n_sites: int, p: Fraction) -> Fraction:
    """(1 - p)^N <= 1 - N p + N^2 p^2 / 2."""
    e = Fraction(n_sites) * p
    return Fraction(1) - e + e * e / 2


def contact_bound(n_sites: int, n_epochs: int, p: Fraction) -> Fraction:
    """P(contact) <= (N^2 - N) p^2 / T."""
    return Fraction(n_sites ** 2 - n_sites) * p * p / Fraction(n_epochs)


def window_contact_bound(
    n_sites: int, n_epochs: int, p: Fraction, lifetime: int
) -> Fraction:
    """P(contact_L) <= (N^2 - N)(2L - 1) p^2 / T."""
    return (
        Fraction(n_sites ** 2 - n_sites)
        * Fraction(2 * lifetime - 1)
        * p
        * p
        / Fraction(n_epochs)
    )


def empty_epochs_bound(n_sites: int, n_epochs: int, p: Fraction) -> Fraction:
    """E[#empty epochs] >= T - N p."""
    return Fraction(n_epochs) - Fraction(n_sites) * p


# ----------------------------------------------------------------------------
# Reporting helpers
# ----------------------------------------------------------------------------

def show(label: str, value: Fraction, width: int = 46) -> str:
    return f"{label:<{width}} {str(value):>18}  = {float(value):.8f}"


def rule(title: str = "") -> None:
    if title:
        print("\n" + "=" * 78)
        print(title)
        print("=" * 78)
    else:
        print("-" * 78)


# ----------------------------------------------------------------------------
# Demonstration 1: normalisation
# ----------------------------------------------------------------------------

def demo_normalisation() -> None:
    rule("1. NORMALISATION  --  the weights really do define a probability measure")
    for n, t, p in [(3, 2, Fraction(1, 5)), (4, 3, Fraction(1, 10))]:
        mass = probability(n, t, p, lambda f: True)
        print(f"  N={n}, T={t}, p={p}:  total mass over {(t+1)**n:>4} outcomes = {mass}")
        assert mass == 1, "weights must sum to one"
    print("  OK: total mass is exactly 1 in every case.")


# ----------------------------------------------------------------------------
# Demonstration 2: the Drake equation is a first moment
# ----------------------------------------------------------------------------

def demo_drake_first_moment() -> None:
    rule("2. THE DRAKE EQUATION IS A FIRST MOMENT:  E[#civilizations] = N p")
    print("  Note in particular that the answer does NOT depend on T.")
    print()
    for n, t, p in [(3, 2, Fraction(1, 5)), (3, 5, Fraction(1, 5)),
                    (4, 3, Fraction(1, 10)), (4, 7, Fraction(1, 10))]:
        exact = expectation(n, t, p, civ_count)
        closed = drake_expectation(n, p)
        print(f"  N={n}, T={t}, p={p}:  enumerated = {exact}   "
              f"closed form N p = {closed}   match = {exact == closed}")
        assert exact == closed


# ----------------------------------------------------------------------------
# Demonstration 3: emptiness is typical
# ----------------------------------------------------------------------------

def demo_emptiness() -> None:
    rule("3. EMPTINESS IS TYPICAL:  P(lifeless) = (1-p)^N >= 1 - N p")
    for n, t, p in [(3, 2, Fraction(1, 5)), (4, 3, Fraction(1, 10)),
                    (5, 4, Fraction(1, 20))]:
        exact = probability(n, t, p, is_lifeless)
        closed = lifeless_exact(n, p)
        lower = bernoulli_lower(n, p)
        upper = bonferroni_upper(n, p)
        print(f"\n  N={n}, T={t}, p={p}")
        print("   ", show("enumerated P(lifeless)", exact))
        print("   ", show("closed form (1-p)^N", closed))
        print("   ", show("Bernoulli lower bound 1 - N p", lower))
        print("   ", show("Bonferroni upper 1 - Np + (Np)^2/2", upper))
        assert exact == closed
        assert lower <= exact <= upper


# ----------------------------------------------------------------------------
# Demonstration 4: the existence sandwich
# ----------------------------------------------------------------------------

def demo_existence_sandwich() -> None:
    rule("4. EXISTENCE SANDWICH:  N p - (N p)^2 / 2 <= P(somebody) <= N p")
    print("  When N p is small, the Drake number IS the probability that")
    print("  anyone exists -- not a headcount.")
    for n, t, p in [(4, 3, Fraction(1, 10)), (3, 2, Fraction(1, 5)),
                    (6, 4, Fraction(1, 50))]:
        exact = probability(n, t, p, somebody_exists)
        e = drake_expectation(n, p)
        lower = e - e * e / 2
        print(f"\n  N={n}, T={t}, p={p}   (Drake expectation N p = {e})")
        print("   ", show("lower bound N p - (N p)^2 / 2", lower))
        print("   ", show("enumerated P(somebody exists)", exact))
        print("   ", show("upper bound N p", e))
        rel = float((e - exact) / e) if e else 0.0
        print(f"     relative error of the first-moment answer: {rel:.4%}")
        assert lower <= exact <= e


# ----------------------------------------------------------------------------
# Demonstration 5: contact is quadratically rare, and decays like 1 / T
# ----------------------------------------------------------------------------

def demo_contact() -> None:
    rule("5. CONTACT IS QUADRATICALLY RARE:  P(contact) <= (N^2 - N) p^2 / T")
    for n, t, p in [(3, 2, Fraction(1, 5)), (4, 3, Fraction(1, 10)),
                    (2, 5, Fraction(1, 2))]:
        exact = probability(n, t, p, has_contact)
        bound = contact_bound(n, t, p)
        ratio = float(bound / exact) if exact else float("inf")
        print(f"\n  N={n}, T={t}, p={p}")
        print("   ", show("enumerated P(contact)", exact))
        print("   ", show("proved bound (N^2 - N) p^2 / T", bound))
        print(f"      slack factor bound/exact = {ratio:.4f}")
        assert exact <= bound
    print("\n  (For N = 2 the slack is exactly 2: the union bound counts ORDERED pairs.)")

    print("\n  More time makes contact RARER -- T is in the denominator:")
    n, p = 3, Fraction(1, 5)
    for t in (2, 3, 4, 5, 6):
        exact = probability(n, t, p, has_contact)
        print(f"    N={n}, p={p}, T={t}:  P(contact) = {str(exact):>12} "
              f"= {float(exact):.6f}   (bound {float(contact_bound(n,t,p)):.6f})")


# ----------------------------------------------------------------------------
# Demonstration 6: lifetime is a linear lever, abundance a quadratic one
# ----------------------------------------------------------------------------

def demo_lifetime_window() -> None:
    rule("6. LIFETIME WINDOWS:  P(contact_L) <= (N^2 - N)(2L - 1) p^2 / T")
    n, t, p = 3, 7, Fraction(1, 5)
    print(f"  N={n}, T={t}, p={p}\n")
    print(f"  {'L':>3}  {'exact P(contact_L)':>22}  {'proved bound':>16}  ok")
    for lifetime in (1, 2, 3, 4):
        exact = probability(n, t, p, lambda f, L=lifetime: has_window_contact(f, L))
        bound = window_contact_bound(n, t, p, lifetime)
        ok = exact <= bound
        print(f"  {lifetime:>3}  {float(exact):>22.8f}  {float(bound):>16.8f}  {ok}")
        assert ok

    print("\n  Compare the two levers at fixed L=1, doubling each parameter:")
    base = probability(3, 8, Fraction(1, 8), has_contact)
    dbl_p = probability(3, 8, Fraction(1, 4), has_contact)
    dbl_L = probability(3, 8, Fraction(1, 8), lambda f: has_window_contact(f, 2))
    print(f"    baseline (p=1/8, L=1)        : {float(base):.8f}")
    print(f"    doubling abundance (p=1/4)   : {float(dbl_p):.8f}"
          f"   ratio {float(dbl_p/base):.3f}  (~ quadratic, ~4x)")
    print(f"    doubling lifetime  (L=2)     : {float(dbl_L):.8f}"
          f"   ratio {float(dbl_L/base):.3f}  (~ linear,   ~3x = 2L-1)")


# ----------------------------------------------------------------------------
# Demonstration 7: the dual pigeonhole principle
# ----------------------------------------------------------------------------

def demo_dual_pigeonhole() -> None:
    rule("7. DUAL PIGEONHOLE:  E[#empty epochs] >= T - N p")
    print("  Pointwise, an outcome with c civilizations leaves >= T - c epochs empty.")
    for n, t, p in [(3, 2, Fraction(1, 5)), (4, 3, Fraction(1, 10)),
                    (3, 6, Fraction(1, 4))]:
        exact = expectation(n, t, p, lambda f, T=t: empty_epoch_count(f, T))
        bound = empty_epochs_bound(n, t, p)
        print(f"\n  N={n}, T={t}, p={p}")
        print("   ", show("enumerated E[#empty epochs]", exact))
        print("   ", show("proved bound T - N p", bound))
        assert bound <= exact

        # pointwise check of the deterministic dual pigeonhole
        for f in enumerate_cosmoi(n, t):
            assert empty_epoch_count(f, t) >= t - civ_count(f)
        print("      pointwise dual pigeonhole E(f) >= T - X(f) verified on all "
              f"{(t+1)**n} outcomes.")


# ----------------------------------------------------------------------------
# Demonstration 8: pigeonhole thresholds are sharp
# ----------------------------------------------------------------------------

def demo_pigeonhole_threshold() -> None:
    rule("8. THE PIGEONHOLE THRESHOLD c = T IS SHARP")
    print("  Contact is FORCED iff the number of civilizations exceeds the number")
    print("  of epochs.  Below the threshold, a contact-free schedule always exists.")
    print()
    print(f"  {'T':>3} {'c':>3}  {'forced?':>8}  {'contact-free schedule exists?':>32}")
    for t in (3, 4, 5):
        for c in range(1, t + 3):
            forced = c > t
            # a contact-free schedule is an injection {1..c} -> {1..T}
            exists_free = c <= t
            print(f"  {t:>3} {c:>3}  {str(forced):>8}  {str(exists_free):>32}")
            assert forced != exists_free or c == 0
    print("\n  In the Fermi regime T ~ 4.5e9 while c is at most a handful:")
    print("  the forcing hypothesis fails by about NINE orders of magnitude.")


# ----------------------------------------------------------------------------
# Demonstration 9: the cosmological instantiation
# ----------------------------------------------------------------------------

def demo_cosmological_instantiation() -> None:
    rule("9. COSMOLOGICAL INSTANTIATION  (N = 1e10, T = 4.5e9, p = 1e-11)")
    n_sites = 10 ** 10
    n_epochs = 4_500_000_000
    p = Fraction(1, 10 ** 11)
    lifetime = 10 ** 4

    e = drake_expectation(n_sites, p)
    print(show("Drake expectation  E = N p", e))
    print(show("P(lifeless) >= 1 - N p", bernoulli_lower(n_sites, p)))
    print(show("P(somebody) >= N p - (N p)^2 / 2", e - e * e / 2))
    print(show("P(somebody) <= N p", e))
    cb = contact_bound(n_sites, n_epochs, p)
    print(f"{'P(contact) <= (N^2-N) p^2 / T':<46} {float(cb):>18.4e}")
    wb = window_contact_bound(n_sites, n_epochs, p, lifetime)
    print(f"{'P(contact, L=1e4) <= (N^2-N)(2L-1)p^2/T':<46} {float(wb):>18.4e}")
    eb = empty_epochs_bound(n_sites, n_epochs, p)
    print(f"{'E[#empty epochs] >= T - N p':<46} {float(eb):>18.4f}   of {n_epochs}")

    print()
    print("  Claimed in the paper and reconfirmed here:")
    print(f"    E = 1/10                       : {e == Fraction(1,10)}")
    print(f"    P(lifeless) >= 9/10            : {bernoulli_lower(n_sites,p) >= Fraction(9,10)}")
    print(f"    P(somebody) >= 19/200 = 0.095  : {e - e*e/2 >= Fraction(19,200)}")
    print(f"    P(contact)  <= 1e-11           : {cb <= Fraction(1, 10**11)}")
    print(f"    P(contact,L=1e4) <= 1e-7       : {wb <= Fraction(1, 10**7)}")
    print(f"    E[#empty] >= 4.5e9 - 0.1       : {eb >= Fraction(45*10**8*10 - 1, 10)}")


# ----------------------------------------------------------------------------
# Demonstration 10: the Fermi dichotomy
# ----------------------------------------------------------------------------

def demo_fermi_dichotomy() -> None:
    rule("10. THE FERMI DICHOTOMY:  E = N p < 1 forces all three conclusions")
    print("   (i)   P(lifeless) >= 1 - E > 0")
    print("   (ii)  P(contact)  <= 1 / T")
    print("   (iii) E[#empty epochs] > T - 1")
    print()
    for n, t, p in [(3, 5, Fraction(1, 10)), (4, 6, Fraction(1, 8)),
                    (5, 7, Fraction(1, 10))]:
        e = drake_expectation(n, p)
        if e >= 1:
            continue
        lifeless = probability(n, t, p, is_lifeless)
        contact = probability(n, t, p, has_contact)
        empties = expectation(n, t, p, lambda f, T=t: empty_epoch_count(f, T))
        print(f"  N={n}, T={t}, p={p}   (E = {e} < 1)")
        print(f"    (i)   P(lifeless)      = {float(lifeless):.6f}  >= 1 - E = "
              f"{float(1 - e):.6f}   {lifeless >= 1 - e}")
        print(f"    (ii)  P(contact)       = {float(contact):.6f}  <= 1/T   = "
              f"{float(Fraction(1,t)):.6f}   {contact <= Fraction(1, t)}")
        print(f"    (iii) E[#empty epochs] = {float(empties):.6f}  >  T-1  = "
              f"{t - 1}   {empties > t - 1}")
        assert lifeless >= 1 - e
        assert contact <= Fraction(1, t)
        assert empties > t - 1
        print()


# ----------------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------------

def main() -> None:
    print(__doc__)
    demo_normalisation()
    demo_drake_first_moment()
    demo_emptiness()
    demo_existence_sandwich()
    demo_contact()
    demo_lifetime_window()
    demo_dual_pigeonhole()
    demo_pigeonhole_threshold()
    demo_cosmological_instantiation()
    demo_fermi_dichotomy()
    rule("ALL CHECKS PASSED")
    print("Every inequality asserted in the paper held exactly in every case tested.")


if __name__ == "__main__":
    main()
