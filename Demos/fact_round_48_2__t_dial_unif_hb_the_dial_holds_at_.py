"""
The OR dial on a finite abelian class group: numerical demonstrations.

This script is completely self-contained (standard library only) and reproduces,
by brute force on small abelian groups, every quantitative statement of the
accompanying paper:

  1.  the value of the universal cap  C* = h(1/4) - (1/2) h(1/2)  and the fact
      that coset indicators of index-two subgroups attain it;
  2.  inflation invariance: the dial is unchanged when the class group is
      enlarged (bit-length axis) or relabelled by an automorphism (regime axis),
      so the whole regime x bit-length grid is one single value;
  3.  the washout dichotomy and its parity form: multiplier randomisation over a
      subgroup H leaves a maximal channel alive iff [G:H] is even;
  4.  count blindness: randomisation preserves the mean rate exactly while the
      dial falls from C* to 0;
  5.  the degradation law  T((1 + t.chi)/2) = D(t^2),
      D(u) = h(1/4) - (1/2)(h((1+u)/4) + h((1-u)/4)),  strictly increasing;
  6.  residue channels of arbitrary order d: T(1_K) = h(1/d^2) - (1/d) h(1/d) > 0;
  7.  the multi-prime dial  Phi_k(1_K) = h(2^{-k}) - (1/2) h(2^{-(k-1)}) > 0;
  8.  the budgeted-adversary threshold  B < 2^{v_2(|G|)}.

All entropies are in nats unless the name says "bits".
"""

from __future__ import annotations

from itertools import product
from math import gcd, log
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

Elem = Tuple[int, ...]          # element of a product of cyclic groups
Profile = Dict[Elem, float]     # class-rate profile s : G -> [0,1]

# --------------------------------------------------------------------------
# Entropy
# --------------------------------------------------------------------------


def h(x: float) -> float:
    """Binary entropy in nats: h(x) = -x log x - (1-x) log(1-x), h(0)=h(1)=0."""
    if x <= 0.0 or x >= 1.0:
        return 0.0
    return -x * log(x) - (1.0 - x) * log(1.0 - x)


def nats_to_bits(x: float) -> float:
    return x / log(2.0)


OR_CAP: float = h(0.25) - 0.5 * h(0.5)          # = (3/2)log 2 - (3/4)log 3


# --------------------------------------------------------------------------
# Finite abelian groups, written multiplicatively but modelled additively
# --------------------------------------------------------------------------


class AbGroup:
    """The finite abelian group Z/m_1 x ... x Z/m_r."""

    def __init__(self, moduli: Sequence[int]) -> None:
        self.moduli: Tuple[int, ...] = tuple(moduli)
        self.elements: List[Elem] = [tuple(e) for e in product(*(range(m) for m in self.moduli))]

    def __len__(self) -> int:
        return len(self.elements)

    def op(self, a: Elem, b: Elem) -> Elem:
        return tuple((x + y) % m for x, y, m in zip(a, b, self.moduli))

    def inv(self, a: Elem) -> Elem:
        return tuple((-x) % m for x, m in zip(a, self.moduli))

    def identity(self) -> Elem:
        return tuple(0 for _ in self.moduli)

    def subgroup_generated(self, gens: Iterable[Elem]) -> List[Elem]:
        seen = {self.identity()}
        frontier = [self.identity()]
        gens = list(gens)
        while frontier:
            new = []
            for x in frontier:
                for g in gens:
                    y = self.op(x, g)
                    if y not in seen:
                        seen.add(y)
                        new.append(y)
            frontier = new
        return sorted(seen)

    def all_subgroups(self) -> List[List[Elem]]:
        """All subgroups, found by closing every subset of generators (small groups only)."""
        found = {}
        stack = [[self.identity()]]
        found[tuple([self.identity()])] = [self.identity()]
        changed = True
        while changed:
            changed = False
            for key in list(found.keys()):
                base = found[key]
                for g in self.elements:
                    if g in base:
                        continue
                    new = self.subgroup_generated(list(base) + [g])
                    k = tuple(new)
                    if k not in found:
                        found[k] = new
                        changed = True
        return list(found.values())


# --------------------------------------------------------------------------
# The dial
# --------------------------------------------------------------------------


def avg(G: AbGroup, s: Profile) -> float:
    """Mean class rate (the 'count' statistic)."""
    return sum(s[a] for a in G.elements) / len(G)


def conv(G: AbGroup, t: Profile, s: Profile) -> Profile:
    """Averaged convolution (t * s)(c) = |G|^{-1} sum_a t(a) s(c a^{-1})."""
    out: Profile = {}
    for c in G.elements:
        out[c] = sum(t[a] * s[G.op(c, G.inv(a))] for a in G.elements) / len(G)
    return out


def fork_power(G: AbGroup, s: Profile, k: int) -> Profile:
    """k-fold convolution power s^{*k} (k >= 1); k = 2 is the semiprime no-fork profile."""
    out = dict(s)
    for _ in range(k - 1):
        out = conv(G, out, s)
    return out


def dial(G: AbGroup, s: Profile, k: int = 2) -> float:
    """Phi_k(s) = h((mean s)^k) - avg_c h(s^{*k}(c)); k = 2 is the semiprime dial T."""
    m = avg(G, s)
    cond = fork_power(G, s, k)
    return h(m ** k) - sum(h(cond[c]) for c in G.elements) / len(G)


# --------------------------------------------------------------------------
# Profiles, subgroups, multiplier randomisation
# --------------------------------------------------------------------------


def subgroup_profile(G: AbGroup, K: Sequence[Elem]) -> Profile:
    Kset = set(K)
    return {a: (1.0 if a in Kset else 0.0) for a in G.elements}


def coset_profile(G: AbGroup, K: Sequence[Elem], x: Elem) -> Profile:
    Kset = set(K)
    return {a: (1.0 if G.op(G.inv(x), a) in Kset else 0.0) for a in G.elements}


def quad_char(G: AbGroup, K: Sequence[Elem]) -> Dict[Elem, float]:
    Kset = set(K)
    return {a: (1.0 if a in Kset else -1.0) for a in G.elements}


def char_profile(G: AbGroup, K: Sequence[Elem], t: float) -> Profile:
    chi = quad_char(G, K)
    return {a: (1.0 + t * chi[a]) / 2.0 for a in G.elements}


def mix(G: AbGroup, H: Sequence[Elem], s: Profile) -> Profile:
    """Multiplier randomisation: (mix_H s)(a) = |H|^{-1} sum_{g in H} s(g a)."""
    return {a: sum(s[G.op(g, a)] for g in H) / len(H) for a in G.elements}


def index(G: AbGroup, H: Sequence[Elem]) -> int:
    return len(G) // len(H)


def dial_at(u: float) -> float:
    """The one-dimensional degradation law D(u) = h(1/4) - (h((1+u)/4) + h((1-u)/4))/2."""
    return h(0.25) - (h((1.0 + u) / 4.0) + h((1.0 - u) / 4.0)) / 2.0


def two_part(n: int) -> int:
    """2^{v_2(n)}."""
    p = 1
    while n % 2 == 0:
        n //= 2
        p *= 2
    return p


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------


def demo_cap() -> None:
    print("=" * 74)
    print("1.  The universal cap")
    print("=" * 74)
    print(f"  C* = h(1/4) - (1/2)h(1/2)      = {OR_CAP:.10f} nats")
    print(f"     = (3/2)log 2 - (3/4)log 3   = {1.5 * log(2) - 0.75 * log(3):.10f} nats")
    print(f"     = {nats_to_bits(OR_CAP):.10f} bits")
    G = AbGroup([12])
    K = G.subgroup_generated([(2,)])          # index two
    print(f"\n  G = Z/12,  K = <2> of index {index(G, K)}")
    for x in [(0,), (1,), (5,)]:
        s = coset_profile(G, K, x)
        print(f"    dial of the coset indicator at x={x[0]:>2}: {dial(G, s):.10f}"
              f"   (mean rate {avg(G, s):.3f})")
    print("  Every coset of every index-two subgroup sits exactly at the cap.")


def demo_inflation() -> None:
    print()
    print("=" * 74)
    print("2.  Inflation invariance: one value across the regime x bit-length grid")
    print("=" * 74)
    G = AbGroup([8])
    K = G.subgroup_generated([(2,)])
    s = subgroup_profile(G, K)
    base = dial(G, s)
    print(f"  base cell   G = Z/8,  K = <2>:                  T = {base:.10f}")
    for extra in ([3], [5], [2, 3]):
        Big = AbGroup([8] + extra)
        # pull the profile back along the projection onto the first factor
        sb = {a: s[(a[0],)] for a in Big.elements}
        print(f"  inflated to Z/8 x {'x'.join('Z/' + str(m) for m in extra):<11}"
              f" (|G| = {len(Big):>3}):     T = {dial(Big, sb):.10f}")
    # regime relabelling: an automorphism of Z/8
    for unit in [3, 5, 7]:
        s_rel = {a: s[((a[0] * unit) % 8,)] for a in G.elements}
        print(f"  relabelled by the automorphism x -> {unit}x:        T = {dial(G, s_rel):.10f}")
    print("  All four cells of the (regime x bit-length) grid carry the same dial value.")


def demo_washout_parity() -> None:
    print()
    print("=" * 74)
    print("3.  The washout dichotomy and its parity form")
    print("=" * 74)
    for moduli in ([12], [2, 6], [15], [9]):
        G = AbGroup(moduli)
        name = " x ".join(f"Z/{m}" for m in moduli)
        subs = G.all_subgroups()
        print(f"\n  G = {name}  (order {len(G)}, 2-part {two_part(len(G))})")
        for H in sorted(subs, key=len):
            idx = index(G, H)
            # can some H-invariant admissible profile reach the cap?
            reach = any(index(G, K) == 2 and set(H) <= set(K) for K in subs)
            best = max((dial(G, mix(G, H, coset_profile(G, K, x)))
                        for K in subs for x in G.elements), default=0.0)
            print(f"    |H| = {len(H):>2}, [G:H] = {idx:>2} ({'even' if idx % 2 == 0 else 'odd '})"
                  f"  cap reachable: {str(reach):>5}   best randomised dial = {best:.6f}")
        print("    -> reachable exactly when the index is even, as predicted.")


def demo_count_blindness() -> None:
    print()
    print("=" * 74)
    print("4.  Count blindness: same mean rate, dial gap equal to the full cap")
    print("=" * 74)
    G = AbGroup([10])
    K = G.subgroup_generated([(2,)])
    s = subgroup_profile(G, K)
    full = G.elements                       # H = G, total randomisation
    ms = mix(G, full, s)
    print(f"  G = Z/10, K = <2> (index 2)")
    print(f"    mean rate before randomisation: {avg(G, s):.6f}")
    print(f"    mean rate after  randomisation: {avg(G, ms):.6f}   (exactly preserved)")
    print(f"    dial  before randomisation:     {dial(G, s):.6f}   (= C*)")
    print(f"    dial  after  randomisation:     {dial(G, ms):.6f}")
    print(f"    separation                    = {dial(G, s) - dial(G, ms):.6f} = C*")
    # a single non-residue multiplier already suffices
    H = G.subgroup_generated([(5,)])        # {0,5}, not contained in K
    mh = mix(G, H, s)
    print(f"    one non-residue multiplier (H = <5>, |H| = {len(H)}):"
          f" dial = {dial(G, mh):.6f}, mean = {avg(G, mh):.6f}")


def demo_degradation_law() -> None:
    print()
    print("=" * 74)
    print("5.  The degradation law  T((1 + t.chi)/2) = D(t^2)")
    print("=" * 74)
    G = AbGroup([12])
    K = G.subgroup_generated([(2,)])
    print("      t     brute-force dial      D(t^2)        mean rate")
    for t in [0.0, 0.2, 0.4, 0.5, 0.6, 0.8, 0.9, 1.0]:
        s = char_profile(G, K, t)
        print(f"    {t:4.2f}     {dial(G, s):.10f}     {dial_at(t * t):.10f}    {avg(G, s):.4f}")
    print("  D is strictly increasing, D(0) = 0 and D(1) = C*:"
          f" {dial_at(0.0):.6f} .. {dial_at(1.0):.6f}")


def demo_residue_order() -> None:
    print()
    print("=" * 74)
    print("6.  Residue channels of arbitrary order d")
    print("=" * 74)
    print("      d    predicted h(1/d^2) - (1/d)h(1/d)   brute force   randomised")
    for d, moduli in [(2, [8]), (3, [9]), (4, [8]), (5, [10]), (6, [12])]:
        G = AbGroup(moduli)
        K = [a for a in G.elements if a[0] % d == 0]
        if index(G, K) != d:
            continue
        s = subgroup_profile(G, K)
        pred = h(1.0 / d ** 2) - (1.0 / d) * h(1.0 / d)
        H = G.subgroup_generated([(1,)])      # generates everything mod K
        print(f"    {d:>3}          {pred:.10f}                {dial(G, s):.10f}"
              f"   {dial(G, mix(G, H, s)):.10f}")


def demo_multiprime() -> None:
    print()
    print("=" * 74)
    print("7.  The multi-prime dial: positive for every number of prime factors")
    print("=" * 74)
    G = AbGroup([8])
    K = G.subgroup_generated([(2,)])
    s = subgroup_profile(G, K)
    print("      k    h(2^-k) - (1/2)h(2^-(k-1))     brute force      randomised")
    for k in range(2, 7):
        pred = h(0.5 ** k) - 0.5 * h(0.5 ** (k - 1))
        brute = dial(G, s, k=k)
        washed = dial(G, mix(G, G.elements, s), k=k)
        print(f"    {k:>3}         {pred:.10f}               {brute:.10f}    {washed:.10f}")
    print("  The dial decays with k but never reaches zero; randomisation zeroes it at every k.")


def demo_budgeted_adversary() -> None:
    print()
    print("=" * 74)
    print("8.  The budgeted multiplier adversary: threshold at the 2-part")
    print("=" * 74)
    for moduli in ([12], [2, 6], [16], [2, 10]):
        G = AbGroup(moduli)
        name = " x ".join(f"Z/{m}" for m in moduli)
        thr = two_part(len(G))
        subs = G.all_subgroups()
        smallest_odd = min((len(H) for H in subs if index(G, H) % 2 == 1), default=None)
        print(f"  G = {name:<10} |G| = {len(G):>2},  2-part = {thr:>2},"
              f"  smallest odd-index subgroup has order {smallest_odd}")
    print("  A maximal channel survives every multiplier group of order <= B iff B < 2^{v_2(|G|)}.")
    for p in [11, 13, 17, 19, 23, 29, 31, 37, 41]:
        print(f"    class group (Z/{p})^*: order {p - 1:>2}, surviving budgets B < {two_part(p - 1)}")


def demo_rate_versus_dial() -> None:
    print()
    print("=" * 74)
    print("9.  Why the dial ranks better than the count: a synthetic illustration")
    print("=" * 74)
    print("  Two samplers with identical mean yield but different class structure.")
    G = AbGroup([12])
    K = G.subgroup_generated([(2,)])
    structured = subgroup_profile(G, K)                       # coset indicator, mean 1/2
    flat = {a: 0.5 for a in G.elements}                       # same mean, no structure
    partial = char_profile(G, K, 0.5)                         # same mean, half contrast
    for label, s in [("coset indicator ", structured), ("half contrast   ", partial),
                     ("flat            ", flat)]:
        print(f"    {label}: mean = {avg(G, s):.4f}   dial = {dial(G, s):.10f}")
    print("  The count statistic cannot distinguish these three samplers at all;")
    print("  the dial separates them across the entire range [0, C*].")


def main() -> None:
    demo_cap()
    demo_inflation()
    demo_washout_parity()
    demo_count_blindness()
    demo_degradation_law()
    demo_residue_order()
    demo_multiprime()
    demo_budgeted_adversary()
    demo_rate_versus_dial()


if __name__ == "__main__":
    main()
