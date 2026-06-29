"""
demo.py -- The Hodge filtration as a complete invariant of a weight-two Hodge structure.

This script gives concrete, numerical demonstrations of the linear-algebra theorems
behind the filtration <-> bigrading duality, in the weight-two case:

    V_C = H20 (+) H11 (+) H02          (the Hodge bigrading)
    F0 = V_C  >=  F1 = H20 (+) H11  >=  F2 = H20    (the Hodge filtration)
    conj : V_C -> V_C                  (complex conjugation, a conjugate-linear involution)

It verifies, on explicit complex matrices:

    1. F is decreasing (F_antitone).
    2. conj acts on the filtration steps by Hodge symmetry
       (conj_H02, conjF1_eq, conjF2_eq).
    3. The opposition relations  F^p (+) conj F^{k-p+1} = V_C  (opposition).
    4. The reconstruction identity  H11 = F1 ∩ conj F1  (recover_H11).
    5. The complete-invariant theorem: same conj + same filtration => same bigrading
       (filtration_determines_decomposition).
    6. The "three lines in a plane" counterexample, showing pairwise-disjointness is
       strictly weaker than internal direct sum.

It depends only on `numpy`. Subspaces are represented by a matrix whose COLUMNS span them.
All subspace operations (sum, intersection, image, equality) are implemented inline via
rank / null-space computations, so the script is fully self-contained.
"""

from __future__ import annotations

import numpy as np

TOL: float = 1e-9


# --------------------------------------------------------------------------------------
# A tiny self-contained subspace library over C (subspaces of C^n, columns = generators)
# --------------------------------------------------------------------------------------

def rank(A: np.ndarray) -> int:
    """Numerical rank of a complex matrix via SVD."""
    if A.size == 0:
        return 0
    s = np.linalg.svd(A, compute_uv=False)
    return int(np.sum(s > TOL * max(1.0, s[0])))


def column_space_basis(A: np.ndarray) -> np.ndarray:
    """An orthonormal basis (as columns) of the column space of A."""
    if A.size == 0 or rank(A) == 0:
        return np.zeros((A.shape[0], 0), dtype=complex)
    U, s, _ = np.linalg.svd(A, full_matrices=False)
    r = int(np.sum(s > TOL * max(1.0, s[0])))
    return U[:, :r]


def null_space(A: np.ndarray) -> np.ndarray:
    """An orthonormal basis (as columns) of the (right) null space of A."""
    if A.shape[1] == 0:
        return np.zeros((A.shape[1], 0), dtype=complex)
    _, s, Vh = np.linalg.svd(A, full_matrices=True)
    smax = s[0] if s.size else 0.0
    tol = TOL * max(1.0, smax)
    null_dim = A.shape[1] - int(np.sum(s > tol))
    if null_dim == 0:
        return np.zeros((A.shape[1], 0), dtype=complex)
    return Vh.conj().T[:, A.shape[1] - null_dim:]


class Subspace:
    """A linear subspace of C^n, stored as an orthonormal column basis `basis`."""

    def __init__(self, generators: np.ndarray, ambient_dim: int) -> None:
        self.n: int = ambient_dim
        gens = np.asarray(generators, dtype=complex).reshape(ambient_dim, -1) \
            if generators.size else np.zeros((ambient_dim, 0), dtype=complex)
        self.basis: np.ndarray = column_space_basis(gens)

    @property
    def dim(self) -> int:
        return self.basis.shape[1]

    def contains(self, other: "Subspace") -> bool:
        """True iff `other` is a subspace of `self`."""
        if other.dim == 0:
            return True
        combined = np.hstack([self.basis, other.basis])
        return rank(combined) == self.dim

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Subspace):
            return NotImplemented
        return self.contains(other) and other.contains(self)

    def join(self, other: "Subspace") -> "Subspace":
        """The sum (join) self + other."""
        combined = np.hstack([self.basis, other.basis]) \
            if (self.dim or other.dim) else np.zeros((self.n, 0), dtype=complex)
        return Subspace(combined, self.n)

    def meet(self, other: "Subspace") -> "Subspace":
        """The intersection self ∩ other (Zassenhaus via null space of [A | -B])."""
        if self.dim == 0 or other.dim == 0:
            return Subspace(np.zeros((self.n, 0), dtype=complex), self.n)
        A, B = self.basis, other.basis
        M = np.hstack([A, -B])
        ns = null_space(M)  # vectors (a; b) with A a = B b
        if ns.shape[1] == 0:
            return Subspace(np.zeros((self.n, 0), dtype=complex), self.n)
        coeffs_a = ns[:A.shape[1], :]
        inter_vectors = A @ coeffs_a
        return Subspace(inter_vectors, self.n)

    def map_by(self, M: np.ndarray) -> "Subspace":
        """The image M(self)."""
        if self.dim == 0:
            return Subspace(np.zeros((self.n, 0), dtype=complex), self.n)
        return Subspace(M @ self.basis, self.n)

    def __repr__(self) -> str:
        return f"Subspace(dim={self.dim} in C^{self.n})"


def top(n: int) -> Subspace:
    """The whole space C^n = ⊤."""
    return Subspace(np.eye(n, dtype=complex), n)


def bot(n: int) -> Subspace:
    """The zero subspace = ⊥."""
    return Subspace(np.zeros((n, 0), dtype=complex), n)


# --------------------------------------------------------------------------------------
# Weight-two Hodge structure with conjugation
# --------------------------------------------------------------------------------------

class HodgeStructureWeightTwoConj:
    """A weight-two Hodge structure on C^n with conjugation.

    Conjugation `conj` is a conjugate-linear involution; we represent it by a complex
    matrix `Cmat` acting as  conj(x) = Cmat @ conj(x_entrywise).  For the standard real
    structure C^n = R^n (x) C, complex conjugation is just entrywise conjugation, i.e.
    Cmat = I.  We model H02 = conj(H20) and require conj to fix H11.
    """

    def __init__(self, H20: Subspace, H11: Subspace, H02: Subspace,
                 Cmat: np.ndarray, n: int) -> None:
        self.n = n
        self.H20 = H20
        self.H11 = H11
        self.H02 = H02
        self.Cmat = Cmat  # conj(x) = Cmat @ x.conj()

    # ----- conjugation as a map on subspaces (conjugate-linear, but maps C-subspaces) -
    def conjMap(self, S: Subspace) -> Subspace:
        if S.dim == 0:
            return bot(self.n)
        conj_basis = self.Cmat @ S.basis.conj()
        return Subspace(conj_basis, self.n)

    # ----- the Hodge filtration F : N -> Subspaces ------------------------------------
    def F(self, p: int) -> Subspace:
        if p <= 0:
            return top(self.n)
        if p == 1:
            return self.H20.join(self.H11)
        if p == 2:
            return self.H20
        return bot(self.n)

    # ----- structural axioms ----------------------------------------------------------
    def is_valid(self) -> bool:
        """Check span + the three internal-direct-sum axioms + Hodge symmetry."""
        T = top(self.n)
        span_ok = self.H20.join(self.H11).join(self.H02) == T
        dir20 = self.H20.meet(self.H11.join(self.H02)) == bot(self.n)
        dir11 = self.H11.meet(self.H20.join(self.H02)) == bot(self.n)
        dir02 = self.H02.meet(self.H20.join(self.H11)) == bot(self.n)
        sym1 = self.conjMap(self.H20) == self.H02
        sym2 = self.conjMap(self.H11) == self.H11
        return all([span_ok, dir20, dir11, dir02, sym1, sym2])


# --------------------------------------------------------------------------------------
# Builders for concrete examples
# --------------------------------------------------------------------------------------

def standard_example() -> HodgeStructureWeightTwoConj:
    """A genuine weight-two structure on C^4 with the standard real structure (Cmat=I).

    We pick H20 = span(e1 + i e2)-style complex line, H02 = its conjugate, and H11 the
    remaining conjugation-stable plane, so that Hodge symmetry holds exactly.
    """
    n = 4
    # H20 spanned by two vectors v1, v2; H02 = conj(H20); H11 = conjugation-stable.
    v1 = np.array([1, 1j, 0, 0], dtype=complex)
    H20 = Subspace(v1.reshape(n, 1), n)
    H02 = Subspace(v1.conj().reshape(n, 1), n)   # conj of H20 under Cmat = I
    # H11: a conjugation-stable plane independent of H20, H02.
    w1 = np.array([0, 0, 1, 0], dtype=complex)   # real => conjugation stable
    w2 = np.array([0, 0, 0, 1], dtype=complex)   # real => conjugation stable
    H11 = Subspace(np.column_stack([w1, w2]), n)
    Cmat = np.eye(n, dtype=complex)
    return HodgeStructureWeightTwoConj(H20, H11, H02, Cmat, n)


def reconstruct(HC: HodgeStructureWeightTwoConj) -> tuple[Subspace, Subspace, Subspace]:
    """RECONSTRUCT(F1, F2, conj) -> (H20, H11, H02), per the complete-invariant theorem."""
    F1 = HC.F(1)
    F2 = HC.F(2)
    H20 = F2                               # H20 = F2
    H11 = F1.meet(HC.conjMap(F1))          # H11 = F1 ∩ conj F1
    H02 = HC.conjMap(H20)                  # H02 = conj(H20)
    return H20, H11, H02


# --------------------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------------------

def demo_validity_and_filtration() -> None:
    print("=" * 78)
    print("DEMO 1.  A concrete weight-two Hodge structure and its filtration")
    print("=" * 78)
    HC = standard_example()
    print(f"  ambient dimension n            = {HC.n}")
    print(f"  dim H20, H11, H02              = {HC.H20.dim}, {HC.H11.dim}, {HC.H02.dim}")
    print(f"  structure satisfies all axioms = {HC.is_valid()}")
    print(f"  F0 = top  (dim {HC.F(0).dim}),  F1 (dim {HC.F(1).dim}),  "
          f"F2 (dim {HC.F(2).dim}),  F3 (dim {HC.F(3).dim})")
    # F_antitone:
    chain_ok = HC.F(0).contains(HC.F(1)) and HC.F(1).contains(HC.F(2)) \
        and HC.F(2).contains(HC.F(3))
    print(f"  F_antitone (F0 >= F1 >= F2 >= F3) = {chain_ok}")
    print()


def demo_conjugation_on_filtration() -> None:
    print("=" * 78)
    print("DEMO 2.  Conjugation acts on the filtration by Hodge symmetry")
    print("=" * 78)
    HC = standard_example()
    # conj_H02 : conj(H02) = H20
    print(f"  conj(H02) == H20            : {HC.conjMap(HC.H02) == HC.H20}")
    # conjF1_eq : conj(F1) = H02 (+) H11
    lhs = HC.conjMap(HC.F(1))
    rhs = HC.H02.join(HC.H11)
    print(f"  conj(F1) == H02 (+) H11     : {lhs == rhs}")
    # conjF2_eq : conj(F2) = H02
    print(f"  conj(F2) == H02             : {HC.conjMap(HC.F(2)) == HC.H02}")
    print()


def demo_opposition() -> None:
    print("=" * 78)
    print("DEMO 3.  The opposition relations   F^p (+) conj F^{k-p+1} = V_C  (k=2)")
    print("=" * 78)
    HC = standard_example()
    T, B = top(HC.n), bot(HC.n)

    # F2 (+) conj F1 = V_C
    inter1 = HC.F(2).meet(HC.conjMap(HC.F(1)))
    join1 = HC.F(2).join(HC.conjMap(HC.F(1)))
    print("  Opposition  F2 + conj F1 = V_C:")
    print(f"     F2 ∩ conj F1 == ⊥ : {inter1 == B}")
    print(f"     F2 ⊔ conj F1 == ⊤ : {join1 == T}")

    # F1 (+) conj F2 = V_C
    inter2 = HC.F(1).meet(HC.conjMap(HC.F(2)))
    join2 = HC.F(1).join(HC.conjMap(HC.F(2)))
    print("  Opposition  F1 + conj F2 = V_C:")
    print(f"     F1 ∩ conj F2 == ⊥ : {inter2 == B}")
    print(f"     F1 ⊔ conj F2 == ⊤ : {join2 == T}")
    print()


def demo_reconstruction() -> None:
    print("=" * 78)
    print("DEMO 4.  Reconstruction:  H11 = F1 ∩ conj F1,  and full bigrading recovery")
    print("=" * 78)
    HC = standard_example()
    H11_recovered = HC.F(1).meet(HC.conjMap(HC.F(1)))
    print(f"  H11 == F1 ∩ conj F1        : {H11_recovered == HC.H11}")
    H20r, H11r, H02r = reconstruct(HC)
    print(f"  reconstructed H20 == H20   : {H20r == HC.H20}")
    print(f"  reconstructed H11 == H11   : {H11r == HC.H11}")
    print(f"  reconstructed H02 == H02   : {H02r == HC.H02}")
    print()


def demo_complete_invariant() -> None:
    print("=" * 78)
    print("DEMO 5.  Complete invariant: same conj + same filtration => same bigrading")
    print("=" * 78)
    HC = standard_example()
    # Build a *second* structure with the SAME conj and SAME filtration but defined
    # via the reconstruction; it must coincide with HC on all three pieces.
    H20b, H11b, H02b = reconstruct(HC)
    HCb = HodgeStructureWeightTwoConj(H20b, H11b, H02b, HC.Cmat, HC.n)
    same_F = all(HC.F(p) == HCb.F(p) for p in range(4))
    same_conj = np.allclose(HC.Cmat, HCb.Cmat)
    same_grading = (HC.H20 == HCb.H20 and HC.H11 == HCb.H11 and HC.H02 == HCb.H02)
    print(f"  same filtration            : {same_F}")
    print(f"  same conjugation           : {same_conj}")
    print(f"  => forced same bigrading   : {same_grading}")
    print()


def demo_three_lines_pitfall() -> None:
    print("=" * 78)
    print("DEMO 6.  Why 'internal direct sum' > 'pairwise disjoint': 3 lines in a plane")
    print("=" * 78)
    n = 2
    L1 = Subspace(np.array([[1], [0]], dtype=complex), n)
    L2 = Subspace(np.array([[0], [1]], dtype=complex), n)
    L3 = Subspace(np.array([[1], [1]], dtype=complex), n)
    pairwise = (L1.meet(L2) == bot(n) and L1.meet(L3) == bot(n)
                and L2.meet(L3) == bot(n))
    # internal-direct-sum test for L1: L1 ∩ (L2 + L3) should be ⊥, but is NOT.
    internal_L1 = L1.meet(L2.join(L3)) == bot(n)
    print(f"  L1, L2, L3 pairwise disjoint (∩ = ⊥)        : {pairwise}")
    print(f"  L1 ∩ (L2 ⊔ L3) == ⊥  (internal direct sum) : {internal_L1}")
    print("  => pairwise disjointness does NOT imply independence;")
    print("     reconstruction genuinely needs the stronger internal-direct-sum axiom.")
    print()


def main() -> None:
    demo_validity_and_filtration()
    demo_conjugation_on_filtration()
    demo_opposition()
    demo_reconstruction()
    demo_complete_invariant()
    demo_three_lines_pitfall()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()


"""
visualize.py -- Pictures of the filtration <-> bigrading duality (weight two).

Produces a single figure with three panels:

  (A) The Hodge diamond / bigrading  V_C = H20 (+) H11 (+) H02.
  (B) The decreasing Hodge filtration tower  F0 >= F1 >= F2  with the cumulative pieces.
  (C) The reconstruction picture: F1 and its mirror conj(F1) overlap exactly in H11,
      illustrating  H11 = F1 ∩ conj F1.

Depends only on `matplotlib`. Saves `hodge_filtration_duality.png`.
"""

from __future__ import annotations

import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle, FancyArrowPatch


def panel_bigrading(ax: plt.Axes) -> None:
    ax.set_title("(A) Hodge bigrading  V_C = H20 + H11 + H02", fontsize=11)
    colors = {"H20": "#e74c3c", "H11": "#27ae60", "H02": "#2980b9"}
    # diamond layout: H20 top-left, H11 center, H02 bottom-right
    coords = {"H20": (0.25, 0.75), "H11": (0.5, 0.5), "H02": (0.75, 0.25)}
    for name, (x, y) in coords.items():
        ax.add_patch(plt.Circle((x, y), 0.12, color=colors[name], alpha=0.85))
        ax.text(x, y, name, ha="center", va="center", color="white",
                fontsize=11, fontweight="bold")
    ax.text(0.5, 0.06, "(p,q) with p+q = 2", ha="center", fontsize=9, color="#555")
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis("off")


def panel_filtration(ax: plt.Axes) -> None:
    ax.set_title("(B) Hodge filtration tower  F0 ⊇ F1 ⊇ F2", fontsize=11)
    # stacked cumulative bars
    ax.add_patch(Rectangle((0.1, 0.1), 0.8, 0.25, color="#e74c3c", alpha=0.85))
    ax.text(0.5, 0.225, "F2 = H20", ha="center", va="center",
            color="white", fontweight="bold")
    ax.add_patch(Rectangle((0.1, 0.35), 0.8, 0.25, color="#27ae60", alpha=0.85))
    ax.text(0.5, 0.475, "F1 = H20 + H11", ha="center", va="center",
            color="white", fontweight="bold")
    ax.add_patch(Rectangle((0.1, 0.60), 0.8, 0.25, color="#2980b9", alpha=0.85))
    ax.text(0.5, 0.725, "F0 = H20 + H11 + H02 = V_C", ha="center", va="center",
            color="white", fontweight="bold")
    ax.annotate("", xy=(0.05, 0.1), xytext=(0.05, 0.85),
                arrowprops=dict(arrowstyle="->", color="#333"))
    ax.text(0.02, 0.5, "p", rotation=90, va="center", fontsize=10)
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis("off")


def panel_reconstruction(ax: plt.Axes) -> None:
    ax.set_title("(C) Reconstruction:  H11 = F1 ∩ conj F1", fontsize=11)
    # two overlapping ellipses: F1 (H20+H11) and conj F1 (H02+H11); overlap = H11
    from matplotlib.patches import Ellipse
    ax.add_patch(Ellipse((0.40, 0.5), 0.5, 0.4, color="#27ae60", alpha=0.45))
    ax.add_patch(Ellipse((0.60, 0.5), 0.5, 0.4, color="#2980b9", alpha=0.45))
    ax.text(0.25, 0.5, "H20", ha="center", va="center", fontweight="bold")
    ax.text(0.75, 0.5, "H02", ha="center", va="center", fontweight="bold")
    ax.text(0.5, 0.5, "H11", ha="center", va="center", fontweight="bold",
            color="#145a32")
    ax.text(0.30, 0.83, "F1 = H20 + H11", ha="center", color="#196f3d", fontsize=9)
    ax.text(0.70, 0.17, "conj F1 = H02 + H11", ha="center", color="#1b4f72", fontsize=9)
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis("off")


def main() -> None:
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    panel_bigrading(axes[0])
    panel_filtration(axes[1])
    panel_reconstruction(axes[2])
    fig.suptitle("The Hodge filtration as a complete invariant (weight two)",
                 fontsize=13, fontweight="bold")
    fig.tight_layout(rect=(0, 0, 1, 0.95))
    fig.savefig("hodge_filtration_duality.png", dpi=150)
    print("Saved hodge_filtration_duality.png")


if __name__ == "__main__":
    main()
