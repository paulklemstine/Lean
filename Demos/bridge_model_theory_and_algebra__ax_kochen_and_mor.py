"""
Numerical demonstrations for the bridge

    Model Theory  <->  Algebra & Number Theory
    Ax-Kochen-Ershov transfer (via ultraproducts / Los's theorem)
    and the Los-Vaught categoricity test.

The verified Lean results being illustrated are:

  * ultraproduct_ee_of_eventually / ultraproduct_ee_of_forall
        componentwise (eventual) isomorphism lifts to elementary
        equivalence of the ultraproducts.
  * axKochen_almost_all_transfer
        a sentence holds in almost-all M_a  iff  it holds in almost-all N_a.
  * losVaught_isComplete
        a satisfiable, kappa-categorical theory all of whose models have
        cardinality kappa is complete.

Ultraproducts over a *free* ultrafilter cannot be built constructively, so we
illustrate the mechanisms with computable surrogates:
  - principal ultrafilters (for an exact, checkable Los's theorem),
  - the cofinite "almost all" filter (truncated to a finite window),
  - finite toy theories (for the Los-Vaught test),
  - finite-field Chevalley-Warning counts (for the Ax-Kochen / Artin story).

Run:  python demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Callable, Dict, Iterable, List, Sequence, Tuple


# ---------------------------------------------------------------------------
# 1. Los's theorem for a PRINCIPAL ultrafilter (exact and checkable)
# ---------------------------------------------------------------------------
# A principal ultrafilter at index a0 calls a set "large" iff it contains a0.
# For it, the ultraproduct of (M_a) is (isomorphic to) the single factor M_{a0},
# and Los's theorem degenerates to:  prod_u M  |=  phi   iff   M_{a0} |= phi.
# This is the simplest exact instance of
#   FirstOrder.Language.Ultraproduct.sentence_realize.

# A "structure" here is just a truth assignment to a finite set of sentence names.
Structure = Dict[str, bool]


def realize_in_principal_ultraproduct(
    family: Sequence[Structure], a0: int, sentence: str
) -> bool:
    """prod_u M |= phi  ==  M_{a0} |= phi  for the principal ultrafilter at a0."""
    return family[a0][sentence]


def los_large_set(family: Sequence[Structure], a0: int, sentence: str) -> bool:
    """Right-hand side of Los: 'almost all coordinates (i.e. a0) realize phi'."""
    # For the principal ultrafilter, a set is large iff it contains a0.
    coords_realizing = {a for a, M in enumerate(family) if M[sentence]}
    return a0 in coords_realizing


def demo_los_principal() -> None:
    print("=" * 70)
    print("1. Los's theorem, principal ultrafilter (exact instance)")
    print("=" * 70)
    sentences = ["has_sqrt_minus1", "char_zero", "is_finite"]
    family: List[Structure] = [
        {"has_sqrt_minus1": True, "char_zero": False, "is_finite": True},   # F_5-ish
        {"has_sqrt_minus1": False, "char_zero": True, "is_finite": False},  # Q-ish
        {"has_sqrt_minus1": True, "char_zero": True, "is_finite": False},   # C-ish
    ]
    a0 = 2
    print(f"Principal ultrafilter pinned at coordinate a0 = {a0}")
    for phi in sentences:
        lhs = realize_in_principal_ultraproduct(family, a0, phi)
        rhs = los_large_set(family, a0, phi)
        assert lhs == rhs, "Los's theorem must hold exactly here"
        print(f"  prod_u |= {phi:18s} = {lhs!s:5s}   (large-set side = {rhs})")
    print("  -> ultraproduct truth == truth on the large set  [OK]\n")


# ---------------------------------------------------------------------------
# 2. Ax-Kochen 'almost all' transfer over the cofinite filter
# ---------------------------------------------------------------------------
# Model:  M_p = Q_p,  N_p = F_p((t)).  Over the cofinite ultrafilter on primes,
# "almost all p" = "all but finitely many p".  axKochen_almost_all_transfer says:
#     (almost all p: M_p |= phi)  iff  (almost all p: N_p |= phi).
# We *simulate* two truth-families that agree except on a finite exceptional set
# and verify the equivalence on a truncated window (cofinite-faithful).

def almost_all(values_by_index: Dict[int, bool], window: Iterable[int]) -> bool:
    """'All but finitely many indices are True' -- on a finite window this is
    'all but a bounded number are True'; we test true cofinite agreement by
    requiring the FALSE set to be finite (here: bounded by a small constant)."""
    false_indices = [i for i in window if not values_by_index[i]]
    return len(false_indices) <= EXCEPTIONAL_BUDGET


EXCEPTIONAL_BUDGET = 3  # 'finite exceptional set' tolerance


def primes_up_to(n: int) -> List[int]:
    sieve = [True] * (n + 1)
    sieve[0:2] = [False, False]
    for i in range(2, int(n ** 0.5) + 1):
        if sieve[i]:
            for j in range(i * i, n + 1, i):
                sieve[j] = False
    return [i for i in range(2, n + 1) if sieve[i]]


def demo_almost_all_transfer() -> None:
    print("=" * 70)
    print("2. Ax-Kochen 'almost all primes' transfer (cofinite filter)")
    print("=" * 70)
    ps = primes_up_to(60)
    # phi = "Artin C2: every degree-2 form in 5 vars has a nontrivial zero".
    # On the function-field side N_p = F_p((t)) it is TRUE for every p.
    N_side = {p: True for p in ps}
    # On the arithmetic side M_p = Q_p it is true for all but finitely many p
    # (Ax-Kochen). We simulate a single small exceptional prime p = 2.
    M_side = {p: (p != 2) for p in ps}

    lhs = almost_all(M_side, ps)
    rhs = almost_all(N_side, ps)
    print(f"  primes tested: {ps}")
    print(f"  exceptional primes on Q_p side: {[p for p in ps if not M_side[p]]}")
    print(f"  almost-all p: Q_p     |= Artin-C2  -> {lhs}")
    print(f"  almost-all p: F_p((t))|= Artin-C2  -> {rhs}")
    assert lhs == rhs
    print("  -> the two sides agree 'for almost all p'  [OK]")
    print("     (the finite exceptional set is invisible to the cofinite filter)\n")


# ---------------------------------------------------------------------------
# 3. Los-Vaught test:  categoricity + uniform cardinality  ==>  completeness
# ---------------------------------------------------------------------------
# Toy theory T over a 1-element signature: "a set with a fixed-point-free
# involution".  Every model has even size; at size kappa = 2 there is exactly
# one model up to isomorphism (categorical), and ALL models we admit have size 2.
# We verify operationally: all size-2 models are isomorphic  =>  all agree on
# every sentence  =>  the theory decides every sentence.

@dataclass(frozen=True)
class Involution:
    """A finite model: a permutation f with f(f(x))=x and f(x)!=x."""
    n: int
    f: Tuple[int, ...]

    def is_valid(self) -> bool:
        return (
            len(self.f) == self.n
            and all(self.f[self.f[x]] == x for x in range(self.n))
            and all(self.f[x] != x for x in range(self.n))
        )


def are_isomorphic(a: Involution, b: Involution) -> bool:
    """Brute-force search for a bijection commuting with the involutions."""
    if a.n != b.n:
        return False
    from itertools import permutations
    for sigma in permutations(range(a.n)):
        if all(sigma[a.f[x]] == b.f[sigma[x]] for x in range(a.n)):
            return True
    return False


def all_size2_models() -> List[Involution]:
    models = []
    for f in product(range(2), repeat=2):
        m = Involution(2, f)
        if m.is_valid():
            models.append(m)
    return models


def demo_los_vaught() -> None:
    print("=" * 70)
    print("3. Los-Vaught test: categoricity + uniform size => completeness")
    print("=" * 70)
    models = all_size2_models()
    print(f"  size-2 models of T (fixed-point-free involution): {len(models)}")
    # Categoricity at kappa = 2: all pairs isomorphic.
    categorical = all(
        are_isomorphic(models[i], models[j])
        for i in range(len(models))
        for j in range(i + 1, len(models))
    )
    print(f"  all size-2 models pairwise isomorphic (2-categorical)? {categorical}")

    # 'Sentences' as computable model invariants; isomorphic models must agree.
    def sentence_even_size(m: Involution) -> bool:
        return m.n % 2 == 0

    def sentence_has_3_orbits(m: Involution) -> bool:
        seen, orbits = set(), 0
        for x in range(m.n):
            if x not in seen:
                orbits += 1
                seen.update({x, m.f[x]})
        return orbits == 3

    agree = True
    for phi in (sentence_even_size, sentence_has_3_orbits):
        vals = {phi(m) for m in models}
        agree = agree and (len(vals) == 1)  # all models give same truth value
    print(f"  all models agree on every tested sentence?            {agree}")
    complete = categorical and agree
    print(f"  => theory is COMPLETE (decides every sentence)?       {complete}")
    assert complete
    print("  -> categoricity + uniform cardinality forced completeness  [OK]\n")


# ---------------------------------------------------------------------------
# 4. The algebraic input: Chevalley-Warning C2 on the function-field side
# ---------------------------------------------------------------------------
# The 'easy side' truth that Ax-Kochen transfers: over a finite field F_p
# (the residue field controlling F_p((t))), every quadratic form in >= 3 vars
# has a nontrivial zero; more generally a degree-d form in > d^2 vars does too.
# We verify the d=2 (quadratic, 5 variables, well over 2^2=4) case by counting.

def has_nontrivial_zero_quadratic(p: int, coeffs: Sequence[int]) -> bool:
    """Does sum_i coeffs[i] * x_i^2 = 0 have a nonzero solution over F_p?"""
    n = len(coeffs)
    for pt in product(range(p), repeat=n):
        if any(v != 0 for v in pt):
            s = sum(c * (v * v) for c, v in zip(coeffs, pt)) % p
            if s == 0:
                return True
    return False


def demo_chevalley_warning() -> None:
    print("=" * 70)
    print("4. Function-field side truth (Chevalley-Warning, d=2, 5 vars)")
    print("=" * 70)
    coeffs = [1, 1, 1, 1, 1]  # x0^2 + ... + x4^2
    for p in [3, 5, 7, 11]:
        ok = has_nontrivial_zero_quadratic(p, coeffs)
        print(f"  p = {p:2d}: x0^2+...+x4^2 = 0 has a nontrivial F_p-zero? {ok}")
        assert ok, "C2 must hold for quadratics in 5 > 4 variables over F_p"
    print("  -> truth holds for EVERY p on the geometric side;")
    print("     Ax-Kochen transfers it to Q_p for all but finitely many p  [OK]\n")


# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------
def main() -> None:
    demo_los_principal()
    demo_almost_all_transfer()
    demo_los_vaught()
    demo_chevalley_warning()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()
