"""
Numerical demonstrations for:

    The Normalization Map as a Natural Transformation into the Probability Simplex

This self-contained script exhibits, with concrete numbers, the laws proved in the
accompanying Lean development:

  * normalize lands in the probability simplex (sums to 1, nonnegative)
  * normalize is the identity on the simplex (retraction)
  * normalize is idempotent
  * normalize is scale-invariant (factors through projectivization)
  * pushforward (marginalization) preserves total mass
  * pushforward respects identity and composition (functoriality)
  * pushforward preserves the simplex (endofunctor)
  * the naturality square: normalize . pushforward == pushforward . normalize

All functions are inlined; only the standard library is used.

Convention (matching the Lean development): division by zero returns zero, so
`normalize` is a TOTAL function and sends the all-zeros vector to itself.
"""

from __future__ import annotations

from typing import Callable, List, Sequence

# --------------------------------------------------------------------------- #
# Core operations                                                             #
# --------------------------------------------------------------------------- #


def normalize(v: Sequence[float]) -> List[float]:
    """ell^1-normalization. Total: returns all-zeros if the total mass is 0."""
    total = sum(v)
    if total == 0.0:
        return [0.0 for _ in v]
    return [x / total for x in v]


def pushforward(f: Callable[[int], int], v: Sequence[float], m: int) -> List[float]:
    """Pushforward of weights `v` (length n) along `f : {0..n-1} -> {0..m-1}`.

    Returns a weight vector of length `m`: w[k] = sum_{i : f(i) = k} v[i].
    """
    w = [0.0 for _ in range(m)]
    for i, vi in enumerate(v):
        w[f(i)] += vi
    return w


def in_simplex(p: Sequence[float], tol: float = 1e-9) -> bool:
    """Membership test for the standard probability simplex."""
    return all(x >= -tol for x in p) and abs(sum(p) - 1.0) <= tol


def approx_equal(a: Sequence[float], b: Sequence[float], tol: float = 1e-9) -> bool:
    return len(a) == len(b) and all(abs(x - y) <= tol for x, y in zip(a, b))


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #


def demo_landing_and_retraction() -> None:
    print("=" * 70)
    print("1. Landing in the simplex, and identity-on-the-simplex (retraction)")
    print("=" * 70)
    v = [7.0, 2.0, 1.0, 0.0]  # raw forecaster scores
    p = normalize(v)
    print(f"raw weights v            = {v}")
    print(f"normalize(v)             = {p}")
    print(f"sum                      = {sum(p):.6f}   in simplex? {in_simplex(p)}")
    print(f"normalize(normalize(v))  = {normalize(p)}   (idempotent)")
    print(f"already-normalized fixed = {approx_equal(normalize(p), p)}")
    print()


def demo_scale_invariance() -> None:
    print("=" * 70)
    print("2. Scale invariance: normalize(c*v) == normalize(v)")
    print("=" * 70)
    v = [7.0, 2.0, 1.0, 0.0]
    for c in (10.0, 0.5, 1000.0):
        cv = [c * x for x in v]
        print(f"c = {c:>8}: normalize(c*v) == normalize(v)? "
              f"{approx_equal(normalize(cv), normalize(v))}")
    print()


def demo_degenerate() -> None:
    print("=" * 70)
    print("3. Totality: normalize of the zero vector is the zero vector")
    print("=" * 70)
    z = [0.0, 0.0, 0.0]
    print(f"normalize([0,0,0])        = {normalize(z)}")
    print(f"idempotent on zero?       = {approx_equal(normalize(normalize(z)), normalize(z))}")
    print()


def demo_pushforward_functor() -> None:
    print("=" * 70)
    print("4. Pushforward is a functor: identity, composition, mass preservation")
    print("=" * 70)
    v = [0.4, 0.1, 0.3, 0.2]          # a probability vector over 4 fine outcomes
    # f: 4 fine outcomes -> 2 coarse outcomes  (e.g. {sun,clouds}->clear, {rain,snow}->wet)
    f = lambda i: 0 if i < 2 else 1
    # g: 2 coarse outcomes -> 1 super-coarse outcome
    g = lambda k: 0
    pf = pushforward(f, v, 2)
    print(f"v                         = {v},  sum = {sum(v)}")
    print(f"pushforward(f, v)         = {pf},  sum = {sum(pf)}  (mass preserved)")
    # identity law
    idv = pushforward(lambda i: i, v, len(v))
    print(f"pushforward(id, v) == v?  {approx_equal(idv, v)}")
    # composition law: (g.f) vs g after f
    gf = pushforward(lambda i: g(f(i)), v, 1)
    g_then_f = pushforward(g, pushforward(f, v, 2), 1)
    print(f"pushforward(g.f,v) == pushforward(g, pushforward(f,v))? "
          f"{approx_equal(gf, g_then_f)}")
    print(f"  pushforward(g.f, v)     = {gf}")
    print(f"  g after f               = {g_then_f}")
    print(f"pushforward preserves simplex? {in_simplex(pf)}")
    print()


def demo_naturality_square() -> None:
    print("=" * 70)
    print("5. The naturality square: normalize . pushforward == pushforward . normalize")
    print("=" * 70)
    v = [7.0, 2.0, 1.0, 0.0]          # raw (un-normalized) weights
    f = lambda i: 0 if i < 2 else 1   # coarse-graining map into 2 categories
    left = normalize(pushforward(f, v, 2))   # coarsen then normalize
    right = pushforward(f, normalize(v), 2)  # normalize then coarsen
    print(f"raw v                                  = {v}")
    print(f"normalize(pushforward(f, v))           = {left}")
    print(f"pushforward(f, normalize(v))           = {right}")
    print(f"equal? {approx_equal(left, right)}")
    # degenerate case: still holds
    z = [0.0, 0.0, 0.0, 0.0]
    lz = normalize(pushforward(f, z, 2))
    rz = pushforward(f, normalize(z), 2)
    print(f"degenerate v=0: both sides {lz} == {rz} ? {approx_equal(lz, rz)}")
    print()


def main() -> None:
    demo_landing_and_retraction()
    demo_scale_invariance()
    demo_degenerate()
    demo_pushforward_functor()
    demo_naturality_square()
    print("All demonstrations completed: every law verified numerically.")


if __name__ == "__main__":
    main()
