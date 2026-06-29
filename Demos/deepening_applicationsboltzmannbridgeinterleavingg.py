"""
The Path Space of Filtrations — numerical demonstrations.

This self-contained script illustrates the main results of the Boltzmann Bridge X
development on the geodesic structure of the interleaving metric on filtrations.

Mathematical setup (all inlined, no external dependencies):

  * A *filtration* on a finite vertex set is a function `weight : simplex -> float`
    that is grounded (weight(empty) <= 0) and monotone (sigma subset of tau implies
    weight(sigma) <= weight(tau)).

  * Isometry theorem:
        eInterleavingDist(F, G) = max_sigma |F.weight(sigma) - G.weight(sigma)|.
    We therefore implement the interleaving distance as the supremum (max) distance.

  * Geodesic interpolation (`lerp`):
        lerp(F, G, t).weight(sigma) = (1 - t) * F.weight(sigma) + t * G.weight(sigma),
    valid for 0 <= t <= 1.

The script verifies, numerically:

  * lerp_self                          : lerp(F, F, t) == F
  * lerp_lerp                          : reparametrisation closure
  * eInterleavingDist_lerp             : constant-speed geodesic identity
  * eInterleavingDist_lerp_betweenness : geodesic-segment additivity
  * eInterleavingDist_convex           : Busemann convexity (and its defect)
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, FrozenSet, Iterable, List, Tuple

# A simplex is a frozenset of vertices; a filtration is a dict simplex -> birth scale.
Simplex = FrozenSet[int]
Filtration = Dict[Simplex, float]


# --------------------------------------------------------------------------- #
# Construction of valid (grounded, monotone) filtrations
# --------------------------------------------------------------------------- #

def all_simplices(vertices: Iterable[int]) -> List[Simplex]:
    """Every nonempty subset of `vertices`, plus the empty simplex."""
    verts = list(vertices)
    result: List[Simplex] = [frozenset()]
    for k in range(1, len(verts) + 1):
        for combo in combinations(verts, k):
            result.append(frozenset(combo))
    return result


def filtration_from_vertex_weights(vertex_weights: Dict[int, float]) -> Filtration:
    """Build a monotone, grounded filtration: a simplex is born when its *last*
    vertex appears, i.e. weight(sigma) = max over v in sigma of vertex_weights[v]
    (and weight(empty) = 0). This is automatically monotone and grounded."""
    verts = list(vertex_weights)
    fil: Filtration = {}
    for sigma in all_simplices(verts):
        fil[sigma] = 0.0 if len(sigma) == 0 else max(vertex_weights[v] for v in sigma)
    return fil


def is_valid(fil: Filtration) -> bool:
    """Check grounding and monotonicity explicitly."""
    if fil.get(frozenset(), 0.0) > 1e-12:
        return False
    simplices = list(fil)
    for s in simplices:
        for t in simplices:
            if s <= t and fil[s] > fil[t] + 1e-12:
                return False
    return True


# --------------------------------------------------------------------------- #
# Core operations: distance and geodesic interpolation
# --------------------------------------------------------------------------- #

def interleaving_distance(F: Filtration, G: Filtration) -> float:
    """eInterleavingDist via the isometry theorem: the sup distance of weights."""
    keys = set(F) | set(G)
    return max(abs(F.get(s, 0.0) - G.get(s, 0.0)) for s in keys)


def lerp(F: Filtration, G: Filtration, t: float) -> Filtration:
    """Convex-interpolation geodesic, valid for 0 <= t <= 1."""
    assert -1e-12 <= t <= 1 + 1e-12, "lerp parameter must lie in [0, 1]"
    keys = set(F) | set(G)
    return {s: (1 - t) * F.get(s, 0.0) + t * G.get(s, 0.0) for s in keys}


def filtrations_equal(F: Filtration, G: Filtration, tol: float = 1e-9) -> bool:
    keys = set(F) | set(G)
    return all(abs(F.get(s, 0.0) - G.get(s, 0.0)) <= tol for s in keys)


# --------------------------------------------------------------------------- #
# Demonstrations of the five main results
# --------------------------------------------------------------------------- #

def demo_lerp_self(F: Filtration) -> None:
    print("== lerp_self : lerp(F, F, t) == F ==")
    for t in (0.0, 0.3, 0.5, 0.8, 1.0):
        ok = filtrations_equal(lerp(F, F, t), F)
        print(f"  t = {t:.1f} : lerp(F,F,t) == F  ->  {ok}")
    print()


def demo_lerp_lerp(F: Filtration, G: Filtration) -> None:
    print("== lerp_lerp : reparametrisation closure ==")
    print("  lerp(lerp(F,G,a), lerp(F,G,b), t) == lerp(F, G, (1-t)a + t b)")
    for a, b, t in [(0.2, 0.8, 0.5), (0.1, 0.9, 0.25), (0.4, 0.6, 0.7)]:
        lhs = lerp(lerp(F, G, a), lerp(F, G, b), t)
        c = (1 - t) * a + t * b
        rhs = lerp(F, G, c)
        ok = filtrations_equal(lhs, rhs)
        print(f"  a={a}, b={b}, t={t} -> new param c={c:.3f} ; equal? {ok}")
    print()


def demo_constant_speed(F: Filtration, G: Filtration) -> None:
    print("== eInterleavingDist_lerp : constant-speed geodesic identity ==")
    d = interleaving_distance(F, G)
    print(f"  total distance d(F,G) = {d:.4f}")
    for s, t in [(0.0, 0.5), (0.2, 0.7), (0.3, 1.0), (0.1, 0.9)]:
        lhs = interleaving_distance(lerp(F, G, s), lerp(F, G, t))
        rhs = abs(s - t) * d
        print(f"  d(lerp {s}, lerp {t}) = {lhs:.4f}   |s-t|*d = {rhs:.4f}   "
              f"match? {abs(lhs - rhs) < 1e-9}")
    print()


def demo_betweenness(F: Filtration, G: Filtration) -> None:
    print("== eInterleavingDist_lerp_betweenness : geodesic-segment law ==")
    print("  for s <= u <= t :  d(s,u) + d(u,t) = d(s,t)")
    for s, u, t in [(0.0, 0.5, 1.0), (0.1, 0.4, 0.9), (0.2, 0.6, 0.8)]:
        d_su = interleaving_distance(lerp(F, G, s), lerp(F, G, u))
        d_ut = interleaving_distance(lerp(F, G, u), lerp(F, G, t))
        d_st = interleaving_distance(lerp(F, G, s), lerp(F, G, t))
        print(f"  s={s}, u={u}, t={t}:  {d_su:.4f} + {d_ut:.4f} = {d_su + d_ut:.4f}"
              f"   vs d(s,t)={d_st:.4f}   additive? {abs(d_su + d_ut - d_st) < 1e-9}")
    print()


def demo_convexity(F: Filtration, G: Filtration, H: Filtration) -> None:
    print("== eInterleavingDist_convex : Busemann convexity + defect ==")
    print("  d(H, lerp(F,G,t)) <= (1-t) d(H,F) + t d(H,G)")
    dHF = interleaving_distance(H, F)
    dHG = interleaving_distance(H, G)
    for t in (0.0, 0.25, 0.5, 0.75, 1.0):
        lhs = interleaving_distance(H, lerp(F, G, t))
        rhs = (1 - t) * dHF + t * dHG
        defect = rhs - lhs
        print(f"  t={t:.2f}:  d(H,lerp)={lhs:.4f}  <=  bound={rhs:.4f}   "
              f"convex? {lhs <= rhs + 1e-9}   defect={defect:.4f}")
    print()


def demo_geodesy_is_sharp_face_of_convexity(F: Filtration, G: Filtration) -> None:
    print("== The unifying principle: geodesy is the sharp (equality) face of convexity ==")
    print("  EQUALITY regime  : points on one line -> exact constant-speed law (defect 0).")
    print("  INEQUALITY regime: an external observer -> generically positive defect.")
    d = interleaving_distance(F, G)
    print("  -- collinear comparison (shared worst-case simplex, exact equality) --")
    for s, t in [(0.2, 0.5), (0.3, 0.9), (0.0, 1.0)]:
        lhs = interleaving_distance(lerp(F, G, s), lerp(F, G, t))
        rhs = abs(s - t) * d
        print(f"     s={s}, t={t}: d={lhs:.4f}, |s-t|*d(F,G)={rhs:.4f}, defect={rhs - lhs:.6f}")
    H = filtration_from_vertex_weights({0: 2.0, 1: 1.7, 2: 0.4, 3: 1.1})
    dHF = interleaving_distance(H, F)
    dHG = interleaving_distance(H, G)
    print("  -- external observer H (competing worst-case simplices, strict) --")
    for t in (0.25, 0.5, 0.75):
        lhs = interleaving_distance(H, lerp(F, G, t))
        rhs = (1 - t) * dHF + t * dHG
        print(f"     t={t}: d(H,lerp)={lhs:.4f} <= bound={rhs:.4f}, defect={rhs - lhs:.6f} (>= 0)")
    print()


def main() -> None:
    # Two filtrations on 4 vertices, built to be valid by construction.
    F = filtration_from_vertex_weights({0: 0.5, 1: 1.0, 2: 1.5, 3: 2.0})
    G = filtration_from_vertex_weights({0: 1.2, 1: 0.3, 2: 2.4, 3: 0.9})
    H = filtration_from_vertex_weights({0: 2.0, 1: 1.7, 2: 0.4, 3: 1.1})

    print("Filtrations valid?  F:", is_valid(F), " G:", is_valid(G), " H:", is_valid(H))
    print(f"Number of simplices tracked: {len(F)}\n")

    demo_lerp_self(F)
    demo_lerp_lerp(F, G)
    demo_constant_speed(F, G)
    demo_betweenness(F, G)
    demo_convexity(F, G, H)
    demo_geodesy_is_sharp_face_of_convexity(F, G)


if __name__ == "__main__":
    main()


"""
Visualization for the Path Space of Filtrations.

Produces a figure with two panels:
  (left)  the constant-speed geodesic identity: interleaving distance grows
          exactly linearly along the lerp path (a perfectly straight line);
  (right) Busemann convexity: distance from an external observer H to the
          moving point lerp(F,G,t) stays under the straight-line chord,
          with the shaded convexity defect.

Self-contained; requires only matplotlib + numpy.
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, FrozenSet, List

import numpy as np
import matplotlib.pyplot as plt

Simplex = FrozenSet[int]
Filtration = Dict[Simplex, float]


def all_simplices(vertices: List[int]) -> List[Simplex]:
    out: List[Simplex] = [frozenset()]
    for k in range(1, len(vertices) + 1):
        out += [frozenset(c) for c in combinations(vertices, k)]
    return out


def fil(vertex_weights: Dict[int, float]) -> Filtration:
    verts = list(vertex_weights)
    return {s: (0.0 if not s else max(vertex_weights[v] for v in s))
            for s in all_simplices(verts)}


def dist(F: Filtration, G: Filtration) -> float:
    keys = set(F) | set(G)
    return max(abs(F.get(s, 0.0) - G.get(s, 0.0)) for s in keys)


def lerp(F: Filtration, G: Filtration, t: float) -> Filtration:
    keys = set(F) | set(G)
    return {s: (1 - t) * F.get(s, 0.0) + t * G.get(s, 0.0) for s in keys}


def main() -> None:
    F = fil({0: 0.5, 1: 1.0, 2: 1.5, 3: 2.0})
    G = fil({0: 1.2, 1: 0.3, 2: 2.4, 3: 0.9})
    H = fil({0: 2.0, 1: 1.7, 2: 0.4, 3: 1.1})

    ts = np.linspace(0.0, 1.0, 101)
    d_FG = dist(F, G)

    # Panel 1: constant speed (distance from F along the path)
    dF = [dist(F, lerp(F, G, t)) for t in ts]

    # Panel 2: convexity
    dHlerp = [dist(H, lerp(F, G, t)) for t in ts]
    dHF, dHG = dist(H, F), dist(H, G)
    chord = [(1 - t) * dHF + t * dHG for t in ts]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    ax1.plot(ts, dF, lw=2.5, color="#2c7fb8")
    ax1.plot([0, 1], [0, d_FG], "--", color="gray", lw=1)
    ax1.set_title("Constant-speed geodesic\n d(F, lerp(F,G,t)) = t · d(F,G)")
    ax1.set_xlabel("parameter t")
    ax1.set_ylabel("interleaving distance from F")
    ax1.grid(alpha=0.3)

    ax2.plot(ts, dHlerp, lw=2.5, color="#d95f0e", label="d(H, lerp(F,G,t))")
    ax2.plot(ts, chord, "--", color="black", lw=1.5,
             label="(1−t)·d(H,F) + t·d(H,G)")
    ax2.fill_between(ts, dHlerp, chord, color="#fec44f", alpha=0.4,
                     label="convexity defect")
    ax2.set_title("Busemann convexity\n distance to an external observer H")
    ax2.set_xlabel("parameter t")
    ax2.set_ylabel("interleaving distance from H")
    ax2.legend(loc="upper center")
    ax2.grid(alpha=0.3)

    fig.suptitle("The Path Space of Filtrations", fontsize=14)
    fig.tight_layout()
    fig.savefig("path_space_filtrations.png", dpi=150)
    print("Saved path_space_filtrations.png")


if __name__ == "__main__":
    main()
