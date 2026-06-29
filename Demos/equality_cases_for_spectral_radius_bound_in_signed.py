import json, pathlib

base = pathlib.Path(__file__).resolve().parent.parent   # package dir
assets = base / "_assets"

def read(p):
    return (base / p).read_text()
def reada(p):
    return (assets / p).read_text()

future_directions = """# FUTURE DIRECTIONS — Spectral radius bounds for signed graphs

Building on `Catalog/Novelty/SignedGraphSpectralEquality.lean`, which establishes
the Δ-bound `|μ| ≤ Δ` for signed adjacency matrices together with its *local*
equality cases (degree saturation and magnitude propagation at the eigenvector's
peak vertices) and a sharp realiser `K_n^+`.

The following conjectures are bold but testable, each phrased so it can be turned
into a `by sorry` Lean target in a later cycle.

## C1. Global regularity from equality (connected case)

**Conjecture.** Let `A` be a signed adjacency matrix that is *connected* (the
underlying unsigned graph is connected) with eigenpair `A *ᵥ v = μ • v`, `v ≠ 0`,
and suppose `|μ| = Δ` (the maximum degree). Then the graph is **Δ-regular**: every
vertex has degree exactly `Δ`, and `|v|` is constant.

*Why plausible.* `eq_case_neighbors_attain_max` propagates the peak magnitude one
edge at a time; connectivity should propagate it to all vertices, and then
`eq_case_degree_saturated` applies at every vertex. Lean target: an induction over
a walk / `SimpleGraph.Connected.exists_walk`-style argument turning local
saturation into global regularity.

## C2. Balance characterization at equality (λ_max = Δ vs λ_min = -Δ)

**Conjecture.** For a connected Δ-regular signed graph, `λ_max = Δ` iff the graph
is **balanced** (switching-equivalent to all-positive), and `λ_min = -Δ` iff it is
**antibalanced** (switching-equivalent to all-negative). Equivalently, the
*largest* eigenvalue meets the upper Δ-bound exactly for balanced graphs.

*Why plausible.* A balanced graph switches to all-positive, whose Perron vector is
flat with eigenvalue Δ; switching is an orthogonal conjugation preserving spectrum.
Lean target: define switching by a `±1` diagonal `S`, prove `S A S` is similar to
`A`, and show `K_n^+` / `K_n^-` realise the two extremes.

## C3. Edge-count (Hong-type) bound and its equality cases

**Conjecture.** For a signed graph with `m` edges (counted with the absolute
adjacency) on `n` vertices, the spectral radius obeys
`ρ(A) ≤ √(2m - n + 1)`, with equality iff `A` is (the switching class of) a
star `K_{1,n-1}` or a complete graph `K_n`.

*Why plausible.* This is the signed analogue of Hong's bound; the absolute-value
reduction used throughout this file (only `|A i j|` matters for the bound) suggests
the unsigned proof transfers, with balance fixing the equality side. Lean target:
state the bound for symmetric `{-1,0,1}` matrices and prove the easy direction
(`ρ ≤ √(2m-n+1)`) first.

## C4. Strengthened bound via the second-largest degree (Lan et al. flavour)

**Conjecture.** Let `d₁ ≥ d₂` be the two largest degrees of a signed graph. Then
`ρ(A) ≤ (d₁ - 1 + √((d₁+1)² + 4(d₂ - 1)·something))/2`-type refinements hold,
strictly improving `ρ ≤ Δ` unless the graph is regular.

*Why plausible.* Refined Rayleigh bounds use the top two rows rather than a single
peak vertex. Lean target: a two-vertex version of the peak argument in
`eigenvalue_abs_le_maxDeg`."""

pkg = {
    "title": "Equality Cases for the Maximum-Degree Spectral Bound of Signed Graphs",
    "domain": "Novelty",
    "description": ("A self-contained, machine-checked development of the "
                    "maximum-degree spectral bound |mu| <= Delta for signed "
                    "adjacency matrices, together with a complete description of "
                    "its equality cases (degree saturation and magnitude "
                    "propagation at the eigenvector's peak) and the sharp "
                    "realiser K_n^+."),
    "authors": ["Aristotle"],
    "date": "2026-06-28",
    "key_results": [
        "eigenvalue_abs_le_maxDeg: every eigenvalue mu of a signed adjacency matrix obeys |mu| <= Delta, the maximum degree",
        "eq_case_degree_saturated: at equality |mu| = Delta, any peak-magnitude vertex has degree exactly Delta",
        "eq_case_neighbors_attain_max: at equality, every neighbour of a peak vertex also attains the peak eigenvector magnitude",
        "completePositive_realizes_equality: the all-positive complete graph K_n^+ has the all-ones eigenvector with eigenvalue n-1 = Delta, realising equality",
    ],
    "keywords": ["signed graph", "signed adjacency matrix", "spectral radius",
                 "maximum degree", "eigenvalue bound", "equality case",
                 "complete graph", "Rayleigh quotient"],
    "article": read("ARTICLE.md"),
    "research_paper": read("RESEARCH_PAPER.md"),
    "research_paper_tex": read("RESEARCH_PAPER.tex"),
    "demo": read("demo.py"),
    "demos": [
        {
            "name": "Sharpness Verification on the All-Positive Complete Graph K_n^+",
            "description": ("Constructs K_n^+ for several n and verifies Theorem 4 "
                            "(completePositive_realizes_equality): the all-ones "
                            "vector is an eigenvector with eigenvalue n-1, every "
                            "degree equals n-1, and hence the Delta-bound is met "
                            "with exact equality |mu| = Delta = n-1."),
            "code": read("demo.py"),
        },
        {
            "name": "Equality-Structure Audit on Complete Graphs (Theorems 1-3)",
            "description": ("Computes the dominant eigenpair of K_3^+ and K_5^+, "
                            "confirms |mu| = Delta (Theorem 1 at equality), and "
                            "verifies degree saturation (Theorem 2) at every peak "
                            "vertex and magnitude propagation (Theorem 3) to all "
                            "neighbours of each peak vertex."),
            "code": reada("algorithm_certificate.py"),
        },
        {
            "name": "Randomised Stress Test of the Maximum-Degree Spectral Bound",
            "description": ("Generates thousands of random signed graphs with "
                            "random densities and signs and checks Theorem 1 "
                            "(eigenvalue_abs_le_maxDeg) on every one, reporting "
                            "zero violations and the largest observed rho/Delta "
                            "ratio (bounded by 1)."),
            "code": read("demo.py"),
        },
    ],
    "algorithms": [
        {
            "name": "Peak-Vertex Equality Certificate for the Signed-Graph Delta-Bound",
            "description": ("Given a signed adjacency matrix A and a candidate "
                            "eigenpair (mu, v), certifies the Delta-bound "
                            "|mu| <= Delta and, when equality holds, the two local "
                            "equality theorems. It computes the degree sequence "
                            "(absolute row sums) and Delta, locates the peak set "
                            "P = argmax |v_i|, checks the bound, and at equality "
                            "verifies that each peak vertex has degree Delta "
                            "(degree saturation, eq_case_degree_saturated) and that "
                            "every neighbour of a peak vertex is itself a peak "
                            "vertex (magnitude propagation, "
                            "eq_case_neighbors_attain_max). Runs in O(n^2) time and "
                            "O(n^2) space, dominated by the absolute row sums; it "
                            "produces an exact, auditable certificate of the "
                            "equality structure."),
            "pseudocode": (
                "Input: signed adjacency matrix A (n x n), eigenvalue mu, eigenvector v\n"
                "1. for i in 0..n-1: deg[i] <- sum_j |A[i][j]|\n"
                "2. Delta <- max_i deg[i]\n"
                "3. bound_holds <- (|mu| <= Delta)\n"
                "4. M <- max_j |v[j]|;  P <- { i : |v[i]| = M }\n"
                "5. if |mu| = Delta then            // equality branch\n"
                "6.     degree_saturation <- for all i in P: deg[i] = Delta\n"
                "7.     magnitude_propagation <- for all i in P, for all j: "
                "A[i][j] != 0 implies |v[j]| = M\n"
                "8. return (Delta, bound_holds, equality=(|mu|=Delta), P,\n"
                "          degree_saturation, magnitude_propagation)"),
            "code": reada("algorithm_certificate.py"),
        },
    ],
    "visualizations": [
        {
            "name": "Spectral Radius Versus Maximum Degree Scatter With Equality Ceiling",
            "description": ("Scatter plot of (Delta, rho) pairs for many random "
                            "signed graphs alongside the complete graphs K_n^+. "
                            "The diagonal rho = Delta is the Delta-bound ceiling; "
                            "random graphs fall strictly below it while the K_n^+ "
                            "realisers sit exactly on the line, visually confirming "
                            "Theorems 1 and 4."),
            "code": reada("visualization.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "Signed-Graph Spectral Ceiling Explorer",
            "description": ("An interactive widget where the user toggles each edge "
                            "of a small signed graph between 0, +1, and -1 and "
                            "watches, in real time, the spectral radius rho stay "
                            "under the maximum-degree ceiling Delta. Built-in "
                            "presets (complete graph K_n^+, star K_{1,n-1}, empty) "
                            "let users reach equality and see the degree-saturation "
                            "and magnitude-propagation theorems light up at the "
                            "peak vertices. Eigenvalues are computed in-browser via "
                            "a Jacobi rotation routine."),
            "html": reada("interactive.html"),
        },
    ],
    "lean_proofs": reada("lean_source.txt"),
    "future_directions": future_directions,
    "modules": {"demo": read("demo.py")},
    "lean_files": ["Catalog/Novelty/SignedGraphSpectralEquality.lean"],
}

out = base / "PACKAGE.json"
out.write_text(json.dumps(pkg, indent=2, ensure_ascii=False))
print("wrote", out, "bytes:", out.stat().st_size)


"""Visualisation: spectral radius versus maximum degree across signed graphs.

Generates a scatter plot of (Delta, rho) pairs for a family of signed graphs,
with the diagonal rho = Delta marking the Delta-bound ceiling.  Equality realisers
(complete graphs K_n^+) sit exactly on the line; generic random signed graphs lie
strictly below it.  Requires numpy and matplotlib.
"""

from __future__ import annotations

import numpy as np
import matplotlib.pyplot as plt


def spectral_radius(A: np.ndarray) -> float:
    return float(np.max(np.abs(np.linalg.eigvalsh(A))))


def max_degree(A: np.ndarray) -> float:
    return float(np.abs(A).sum(axis=1).max())


def complete_positive(n: int) -> np.ndarray:
    return np.ones((n, n)) - np.eye(n)


def random_signed_graph(n: int, density: float, rng: np.random.Generator) -> np.ndarray:
    A = np.zeros((n, n))
    for i in range(n):
        for j in range(i + 1, n):
            if rng.random() < density:
                A[i, j] = A[j, i] = 1.0 if rng.random() < 0.5 else -1.0
    return A


def main() -> None:
    rng = np.random.default_rng(7)
    rand_d, rand_rho = [], []
    for _ in range(600):
        n = int(rng.integers(3, 14))
        A = random_signed_graph(n, float(rng.uniform(0.2, 1.0)), rng)
        D = max_degree(A)
        if D == 0:
            continue
        rand_d.append(D)
        rand_rho.append(spectral_radius(A))

    comp_d, comp_rho = [], []
    for n in range(2, 14):
        A = complete_positive(n)
        comp_d.append(max_degree(A))
        comp_rho.append(spectral_radius(A))

    lim = max(rand_d + comp_d) + 1
    plt.figure(figsize=(7, 7))
    plt.plot([0, lim], [0, lim], "k--", label=r"ceiling $\rho=\Delta$")
    plt.scatter(rand_d, rand_rho, s=18, alpha=0.5, label="random signed graphs")
    plt.scatter(comp_d, comp_rho, s=70, marker="*", color="crimson",
                label=r"$K_n^+$ (equality realisers)")
    plt.xlabel(r"maximum degree $\Delta$")
    plt.ylabel(r"spectral radius $\rho(A)$")
    plt.title("Spectral radius respects the maximum-degree ceiling")
    plt.legend()
    plt.tight_layout()
    plt.savefig("spectral_vs_degree.png", dpi=150)
    print("saved spectral_vs_degree.png")


if __name__ == "__main__":
    main()


"""Numerical demonstrations for the maximum-degree spectral bound of signed graphs.

This module illustrates, with exact small examples and random stress tests, the
four formalised results:

  * Theorem 1 (Delta-bound):        |mu| <= Delta  for every eigenvalue mu.
  * Theorem 2 (degree saturation):  at equality, a peak vertex has degree Delta.
  * Theorem 3 (magnitude propagation): at equality, peak magnitude spreads to
                                       every neighbour of a peak vertex.
  * Theorem 4 (sharpness):          K_n^+ attains equality with eigenvalue n-1.

A *signed adjacency matrix* is a real symmetric matrix with entries in {-1,0,1}
and zero diagonal.  The (unsigned) degree of vertex i is sum_j |A[i][j]|.

The code is self-contained: it uses only the Python standard library plus
``numpy`` for eigen-decomposition.
"""

from __future__ import annotations

import numpy as np


# --------------------------------------------------------------------------- #
#  Core primitives                                                            #
# --------------------------------------------------------------------------- #
def degrees(A: np.ndarray) -> np.ndarray:
    """Unsigned degree of each vertex: the absolute row sums sum_j |A[i][j]|."""
    return np.abs(A).sum(axis=1)


def max_degree(A: np.ndarray) -> float:
    """Maximum (unsigned) degree Delta = max_i sum_j |A[i][j]|."""
    return float(degrees(A).max())


def is_signed_adjacency(A: np.ndarray, tol: float = 1e-9) -> bool:
    """Check A is symmetric, has zero diagonal, and entries in {-1, 0, 1}."""
    n = A.shape[0]
    if A.shape != (n, n):
        return False
    if not np.allclose(A, A.T, atol=tol):
        return False
    if not np.allclose(np.diag(A), 0.0, atol=tol):
        return False
    return bool(np.all(np.isin(np.round(A).astype(int), (-1, 0, 1))))


def spectral_radius(A: np.ndarray) -> float:
    """Largest eigenvalue in absolute value of the symmetric matrix A."""
    return float(np.max(np.abs(np.linalg.eigvalsh(A))))


def peak_vertices(v: np.ndarray, tol: float = 1e-9) -> list[int]:
    """Indices attaining the maximal eigenvector magnitude max_j |v[j]|."""
    M = float(np.abs(v).max())
    return [i for i in range(len(v)) if abs(abs(v[i]) - M) <= tol]


# --------------------------------------------------------------------------- #
#  Graph constructors                                                         #
# --------------------------------------------------------------------------- #
def complete_positive(n: int) -> np.ndarray:
    """The all-positive complete graph K_n^+ : 0 on the diagonal, 1 elsewhere."""
    A = np.ones((n, n), dtype=float) - np.eye(n)
    return A


def signed_star(n: int) -> np.ndarray:
    """A signed star K_{1,n-1} with centre vertex 0 (all leaf edges +1)."""
    A = np.zeros((n, n), dtype=float)
    for j in range(1, n):
        A[0, j] = A[j, 0] = 1.0
    return A


def random_signed_graph(n: int, density: float, rng: np.random.Generator) -> np.ndarray:
    """A random signed adjacency matrix: each off-diagonal pair is an edge with
    probability ``density`` and then receives a uniformly random sign +/-1."""
    A = np.zeros((n, n), dtype=float)
    for i in range(n):
        for j in range(i + 1, n):
            if rng.random() < density:
                s = 1.0 if rng.random() < 0.5 else -1.0
                A[i, j] = A[j, i] = s
    return A


# --------------------------------------------------------------------------- #
#  Theorem checkers                                                           #
# --------------------------------------------------------------------------- #
def check_delta_bound(A: np.ndarray, tol: float = 1e-9) -> bool:
    """Theorem 1: every eigenvalue satisfies |mu| <= Delta."""
    Delta = max_degree(A)
    eigs = np.linalg.eigvalsh(A)
    return bool(np.all(np.abs(eigs) <= Delta + tol))


def check_equality_structure(A: np.ndarray, tol: float = 1e-7) -> dict:
    """Inspect the dominant eigenpair and verify Theorems 2 and 3 whenever the
    Delta-bound is met with equality (|mu| = Delta)."""
    Delta = max_degree(A)
    eigvals, eigvecs = np.linalg.eigh(A)
    k = int(np.argmax(np.abs(eigvals)))           # dominant eigenpair
    mu = float(eigvals[k])
    v = eigvecs[:, k]
    deg = degrees(A)

    report = {
        "Delta": Delta,
        "dominant_eigenvalue": mu,
        "abs_eigenvalue": abs(mu),
        "equality": abs(abs(mu) - Delta) <= tol,
        "peak_vertices": peak_vertices(v, tol),
    }

    if report["equality"]:
        peaks = report["peak_vertices"]
        # Theorem 2: every peak vertex has degree exactly Delta.
        report["degree_saturation"] = all(abs(deg[i] - Delta) <= tol for i in peaks)
        # Theorem 3: every neighbour of a peak vertex is itself a peak vertex.
        M = float(np.abs(v).max())
        prop_ok = True
        for i in peaks:
            for j in range(A.shape[0]):
                if abs(A[i, j]) > tol and abs(abs(v[j]) - M) > tol:
                    prop_ok = False
        report["magnitude_propagation"] = prop_ok
    return report


# --------------------------------------------------------------------------- #
#  Demonstrations                                                             #
# --------------------------------------------------------------------------- #
def demo_complete_graph_sharpness(n_values: tuple[int, ...] = (2, 3, 4, 5, 8)) -> None:
    """Theorem 4: K_n^+ attains equality with eigenvalue n-1 and degree n-1."""
    print("=" * 68)
    print("Theorem 4 - Sharpness via the all-positive complete graph K_n^+")
    print("=" * 68)
    for n in n_values:
        A = complete_positive(n)
        ones = np.ones(n)
        image = A @ ones
        Delta = max_degree(A)
        mu = float(image[0])                       # all entries equal
        flat = np.allclose(image, (n - 1) * ones)
        print(f"  n={n:2d}:  A*1 = (n-1)*1 ? {str(flat):5s}   "
              f"mu = {mu:.1f}   Delta = {Delta:.1f}   "
              f"|mu|=Delta ? {abs(mu) == Delta}")
    print()


def demo_equality_examples() -> None:
    """Theorems 1-3 on exact small graphs that attain equality."""
    print("=" * 68)
    print("Theorems 1-3 - Equality structure on exact examples")
    print("=" * 68)
    examples = {
        "Triangle K_3^+": complete_positive(3),
        "K_5^+": complete_positive(5),
    }
    for name, A in examples.items():
        assert is_signed_adjacency(A), f"{name} is not a signed adjacency matrix"
        rep = check_equality_structure(A)
        print(f"  {name}:")
        print(f"     Delta = {rep['Delta']:.1f}, dominant |mu| = "
              f"{rep['abs_eigenvalue']:.4f}, equality = {rep['equality']}")
        print(f"     peak vertices = {rep['peak_vertices']}")
        if rep["equality"]:
            print(f"     degree saturation (Thm 2)   = {rep['degree_saturation']}")
            print(f"     magnitude propagation (Thm 3) = {rep['magnitude_propagation']}")
    print()


def demo_strict_inequality() -> None:
    """A graph strictly below the ceiling: the signed star K_{1,4}."""
    print("=" * 68)
    print("Theorem 1 - A strict case (signed star K_{1,4})")
    print("=" * 68)
    A = signed_star(5)
    Delta = max_degree(A)
    rho = spectral_radius(A)
    print(f"  Delta = {Delta:.1f}   spectral radius rho = {rho:.4f}   "
          f"rho < Delta ? {rho < Delta - 1e-9}")
    print(f"  (The star's centre has degree 4, but rho = sqrt(4) = 2 < 4.)")
    print()


def demo_random_stress_test(trials: int = 2000, seed: int = 2026) -> None:
    """Theorem 1 over many random signed graphs: the bound must never fail."""
    print("=" * 68)
    print(f"Theorem 1 - Random stress test ({trials} signed graphs)")
    print("=" * 68)
    rng = np.random.default_rng(seed)
    failures = 0
    max_ratio = 0.0
    for _ in range(trials):
        n = int(rng.integers(2, 12))
        density = float(rng.uniform(0.2, 1.0))
        A = random_signed_graph(n, density, rng)
        if not is_signed_adjacency(A):
            failures += 1
            continue
        Delta = max_degree(A)
        if Delta == 0:
            continue
        rho = spectral_radius(A)
        max_ratio = max(max_ratio, rho / Delta)
        if not check_delta_bound(A):
            failures += 1
    print(f"  bound violations: {failures}")
    print(f"  largest observed rho/Delta ratio: {max_ratio:.6f}  (must be <= 1)")
    print()


def main() -> None:
    demo_complete_graph_sharpness()
    demo_equality_examples()
    demo_strict_inequality()
    demo_random_stress_test()
    print("All demonstrations completed: the Delta-bound and its equality")
    print("structure hold across exact and randomised examples.")


if __name__ == "__main__":
    main()
