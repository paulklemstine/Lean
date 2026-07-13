"""Numerical demonstrations of the Cone Colorful Carathéodory results.

This module illustrates, with concrete numerical examples, the three central
results of the accompanying paper:

  1. The Homogeneity Bridge: at the origin, a nontrivial conical combination can
     be rescaled to a convex combination and vice versa.
  2. The one-dimensional Cone Colorful Carathéodory Theorem: from r >= 2 color
     classes of reals, each capturing the origin conically, a colorful transversal
     capturing the origin can always be selected.
  3. The Conic Carathéodory Bound: capturing the origin conically in dimension d
     needs at most d + 1 vectors; a pruning procedure extracts such a subfamily.

All routines are self-contained and depend only on the Python standard library
plus NumPy for linear algebra.
"""

from __future__ import annotations

from typing import List, Optional, Sequence, Tuple

import numpy as np


# --------------------------------------------------------------------------- #
# 1. Homogeneity bridge                                                       #
# --------------------------------------------------------------------------- #
def conical_to_convex(weights: Sequence[float]) -> List[float]:
    """Rescale nonnegative weights (not all zero) to sum to one.

    Given a nontrivial conical witness ``weights`` (all >= 0, at least one > 0),
    return the convex witness ``weights / sum(weights)``. This is the constructive
    content of the forward direction of the Homogeneity Bridge.
    """
    total = float(sum(weights))
    if total <= 0:
        raise ValueError("weights must be nonnegative with a strictly positive entry")
    return [w / total for w in weights]


def captures_origin_conically(
    vectors: Sequence[Sequence[float]], weights: Sequence[float], tol: float = 1e-9
) -> bool:
    """Check that ``weights`` is a nontrivial conical witness for the origin."""
    w = np.asarray(weights, dtype=float)
    V = np.asarray(vectors, dtype=float)
    nonneg = bool(np.all(w >= -tol))
    nontrivial = bool(np.any(w > tol))
    balanced = bool(np.allclose(w @ V, 0.0, atol=1e-7))
    return nonneg and nontrivial and balanced


def demo_homogeneity_bridge() -> None:
    print("=" * 70)
    print("1. HOMOGENEITY BRIDGE")
    print("=" * 70)
    # Three planar vectors that balance with unequal conical weights.
    vectors = [(1.0, 0.0), (-1.0, 2.0), (-1.0, -2.0)]
    conical = [4.0, 2.0, 2.0]  # 4*(1,0) + 2*(-1,2) + 2*(-1,-2) = (0,0)
    print(f"vectors          = {vectors}")
    print(f"conical weights  = {conical}  (sum = {sum(conical)})")
    print(f"balanced?          {captures_origin_conically(vectors, conical)}")
    convex = conical_to_convex(conical)
    print(f"convex weights   = {convex}  (sum = {sum(convex):.6f})")
    print(f"still balanced?    {captures_origin_conically(vectors, convex)}")
    print()


# --------------------------------------------------------------------------- #
# 2. One-dimensional colorful transversal                                     #
# --------------------------------------------------------------------------- #
def class_captures_origin(cls: Sequence[float], tol: float = 1e-12) -> bool:
    """A finite set of reals captures the origin conically iff it contains 0 or
    straddles the origin (has both a strictly positive and a strictly negative
    element)."""
    has_zero = any(abs(x) <= tol for x in cls)
    has_pos = any(x > tol for x in cls)
    has_neg = any(x < -tol for x in cls)
    return has_zero or (has_pos and has_neg)


def colorful_transversal_1d(
    classes: Sequence[Sequence[float]], tol: float = 1e-12
) -> Tuple[List[float], List[float]]:
    """Construct a colorful transversal of real color classes capturing the origin.

    Requires r = len(classes) >= 2 and each class to capture the origin conically.
    Returns ``(transversal, weights)`` where ``transversal[i] in classes[i]`` and
    ``weights`` is a nontrivial conical witness for the transversal.
    """
    r = len(classes)
    if r < 2:
        raise ValueError("need at least 2 color classes (threshold r >= d + 1 = 2)")
    for cls in classes:
        if not class_captures_origin(cls, tol):
            raise ValueError("every color class must capture the origin conically")

    # Case 1: some class contains 0.
    for i, cls in enumerate(classes):
        zeros = [x for x in cls if abs(x) <= tol]
        if zeros:
            transversal = [zeros[0] if j == i else classes[j][0] for j in range(r)]
            weights = [1.0 if j == i else 0.0 for j in range(r)]
            return transversal, weights

    # Case 2: no class contains 0 -> every class straddles the origin.
    transversal = []
    for j, cls in enumerate(classes):
        if j == 0:
            transversal.append(next(x for x in cls if x > tol))   # positive a
        elif j == 1:
            transversal.append(next(x for x in cls if x < -tol))  # negative b
        else:
            transversal.append(cls[0])
    a, b = transversal[0], transversal[1]
    weights = [0.0] * r
    weights[0] = -b   # > 0
    weights[1] = a    # > 0
    # (-b) * a + a * b = 0
    return transversal, weights


def demo_colorful_1d() -> None:
    print("=" * 70)
    print("2. ONE-DIMENSIONAL CONE COLORFUL CARATHÉODORY")
    print("=" * 70)
    classes = [[3.0, -5.0, 7.0], [2.0, -1.0], [-4.0, 6.0, -2.0]]
    print(f"color classes            = {classes}")
    for i, cls in enumerate(classes):
        print(f"  class {i} captures origin? {class_captures_origin(cls)}")
    t, w = colorful_transversal_1d(classes)
    balance = sum(wi * ti for wi, ti in zip(w, t))
    print(f"transversal (one per color) = {t}")
    print(f"conical weights             = {w}")
    print(f"weighted balance            = {balance:.6f}  (should be 0)")
    print()
    print("Sharpness: a single class {1, -1} captures the origin, but no single")
    print("chosen element does -> the threshold r >= 2 cannot be lowered.")
    single = [1.0, -1.0]
    print(f"  single class {single} captures origin? {class_captures_origin(single)}")
    print(f"  any lone element captures origin?      "
          f"{any(class_captures_origin([x]) for x in single)}")
    print()


# --------------------------------------------------------------------------- #
# 3. Conic Carathéodory bound (pruning)                                       #
# --------------------------------------------------------------------------- #
def find_affine_dependence(
    vectors: np.ndarray, support: List[int], tol: float = 1e-9
) -> Optional[np.ndarray]:
    """Find u (supported on ``support``) with sum u_i v_i = 0, sum u_i = 0,
    u nonzero. Returns None if the lifted vectors are independent."""
    cols = np.array([np.append(vectors[i], 1.0) for i in support]).T  # (d+1) x k
    ns = _null_space(cols, tol)
    if ns.shape[1] == 0:
        return None
    coeffs = ns[:, 0]
    u = np.zeros(len(vectors))
    for local, i in enumerate(support):
        u[i] = coeffs[local]
    return u


def _null_space(a: np.ndarray, tol: float = 1e-9) -> np.ndarray:
    """Orthonormal basis of the null space of ``a`` via the SVD."""
    _, s, vh = np.linalg.svd(a)
    rank = int((s > tol).sum())
    return vh[rank:].conj().T


def conic_caratheodory_prune(
    vectors: Sequence[Sequence[float]], weights: Sequence[float], tol: float = 1e-9
) -> Tuple[List[int], np.ndarray]:
    """Reduce a convex witness for the origin to support size <= d + 1.

    ``weights`` must be a convex witness (nonnegative, summing to 1, balancing the
    ``vectors``). Returns the surviving support indices and the reduced weights.
    """
    V = np.asarray(vectors, dtype=float)
    w = np.asarray(weights, dtype=float).copy()
    d = V.shape[1]
    support = [i for i in range(len(w)) if w[i] > tol]

    while len(support) > d + 1:
        u = find_affine_dependence(V, support, tol)
        if u is None:
            break
        # Ratio test: largest theta keeping all weights >= 0.
        thetas = [w[i] / (-u[i]) for i in support if u[i] < -tol]
        if not thetas:
            u = -u
            thetas = [w[i] / (-u[i]) for i in support if u[i] < -tol]
        theta = min(thetas)
        w = w + theta * u
        w[w < tol] = 0.0
        support = [i for i in range(len(w)) if w[i] > tol]
    return support, w


def demo_conic_caratheodory() -> None:
    print("=" * 70)
    print("3. CONIC CARATHÉODORY BOUND (d = 2, so at most d + 1 = 3 vectors)")
    print("=" * 70)
    # Five unit-ish vectors around the origin in the plane; origin is inside.
    vectors = [
        (1.0, 0.0),
        (0.3, 1.0),
        (-1.0, 0.6),
        (-0.7, -0.9),
        (0.5, -1.1),
    ]
    # A convex witness using all five (uniform-ish weights that balance).
    V = np.array(vectors)
    # Solve for nonnegative weights summing to 1 balancing V: use a feasible combo.
    # Here we just search a simple balanced convex combination numerically.
    w0 = _balanced_convex_weights(V)
    print(f"vectors            = {vectors}")
    print(f"initial support    = {list(range(len(vectors)))}  (size {len(vectors)})")
    print(f"initial weights    = {np.round(w0, 4).tolist()}")
    print(f"balanced?            {np.allclose(w0 @ V, 0, atol=1e-6)}, "
          f"sum = {w0.sum():.4f}")
    support, w = conic_caratheodory_prune(vectors, w0)
    print(f"pruned support     = {support}  (size {len(support)} <= 3)")
    print(f"pruned weights     = {np.round(w[w > 0], 4).tolist()}")
    print(f"still balanced?      {np.allclose(w @ V, 0, atol=1e-6)}, "
          f"sum = {w.sum():.4f}")
    print()


def _balanced_convex_weights(V: np.ndarray, tol: float = 1e-9) -> np.ndarray:
    """Find nonnegative weights summing to 1 with w @ V = 0 (origin in hull).

    Solves the small linear feasibility problem by projecting the uniform vector
    onto the affine solution set and, if needed, nudging toward feasibility. For
    the well-conditioned demo data the projected solution is already nonnegative.
    """
    n = V.shape[0]
    # Constraints: V^T w = 0 (d eqns) and 1^T w = 1.
    A = np.vstack([V.T, np.ones(n)])
    b = np.append(np.zeros(V.shape[1]), 1.0)
    # Minimum-norm-ish solution via least squares, then clip and renormalize.
    w, *_ = np.linalg.lstsq(A, b, rcond=None)
    w = np.clip(w, 0.0, None)
    s = w.sum()
    if s <= tol:
        w = np.ones(n) / n
        s = 1.0
    w = w / s
    return w


# --------------------------------------------------------------------------- #
def main() -> None:
    demo_homogeneity_bridge()
    demo_colorful_1d()
    demo_conic_caratheodory()


if __name__ == "__main__":
    main()
