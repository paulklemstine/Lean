import Mathlib

/-!
# An explicit Möbius-ladder symmetry certificate for a cubic edge-transitive graph

The *Möbius ladder* `Mₙ` is the cubic graph on `2n` vertices obtained from the
cycle `C₂ₙ` (the "rim", edges `i ∼ i±1`) by adding the `n` "rungs" `i ∼ i+n`.
The whole family is vertex-transitive, but it is **not** edge-transitive in
general: for `n ≥ 4` the rim edges and the rung edges lie in distinct orbits of
the automorphism group.  The small Möbius ladders that *are* edge-transitive are
`M₂ ≅ K₄` and `M₃ ≅ K₃,₃`.

This file gives a fully verified, **explicit symmetry certificate** for the
edge-transitive Möbius ladder `M₃` on the six vertices `ZMod 6`:

* `MobiusLadder3`  — the Möbius ladder `M₃`, defined faithfully from its rim
  edges `i ∼ i+1` and rungs `i ∼ i+3`.
* `MobiusLadder3.cubic`  — every vertex has degree `3` (the graph is cubic).
* `MobiusLadder3.adj_iff_parity`  — the computational identification
  `M₃ ≅ K₃,₃`: two vertices are adjacent iff they have opposite parity.
* `edge_transitive`  — the graph is edge-transitive: any edge can be carried to
  any other edge by a vertex permutation preserving adjacency.
* `vertex_transitive`  — the graph is vertex-transitive (via rotations).

## Resolving circular dependencies by direct computation

Edge-transitivity is often argued through the structure theory of the
automorphism group, which on a small graph is circular (the group is defined
via the very symmetries one is trying to exhibit).  Here we sidestep that by a
*certificate*: a concrete finite list `MobiusLadder3.cert` of vertex
permutations, each **checked by `decide` to preserve adjacency**
(`cert_isSym`), whose orbit of a single base edge **provably exhausts every
edge** (`cert_covers`).  General edge-transitivity then follows from the fact
that adjacency-preserving permutations form a group (`isSym_one`, `isSym_mul`,
`isSym_inv`).  All finite facts are discharged by kernel computation.
-/

namespace MobiusLadderCertificate

open SimpleGraph

/-- Vertex adjacency of the Möbius ladder `M₃` on `ZMod 6`: the rim edges
`i ∼ i+1` of the `6`-cycle together with the three rungs `i ∼ i+3`. -/
def adj3 (i j : ZMod 6) : Prop := j = i + 1 ∨ i = j + 1 ∨ j = i + 3

instance : DecidableRel adj3 :=
  fun i j => inferInstanceAs (Decidable (j = i + 1 ∨ i = j + 1 ∨ j = i + 3))

theorem adj3_symm : Symmetric adj3 := by intro x y; revert x y; decide

/-- The Möbius ladder `M₃`, a cubic graph on the six vertices `ZMod 6`. -/
def MobiusLadder3 : SimpleGraph (ZMod 6) where
  Adj := adj3
  symm := adj3_symm
  loopless := ⟨by decide⟩

instance : DecidableRel MobiusLadder3.Adj := inferInstanceAs (DecidableRel adj3)

/-- The Möbius ladder `M₃` is **cubic**: every vertex has degree `3`. -/
theorem MobiusLadder3.cubic : ∀ v : ZMod 6, MobiusLadder3.degree v = 3 := by decide

/-- `M₃` has nine edges. -/
theorem MobiusLadder3.card_edges : MobiusLadder3.edgeFinset.card = 9 := by decide

/-- **Identification `M₃ ≅ K₃,₃`.**  Two vertices of the Möbius ladder `M₃` are
adjacent precisely when they have opposite parity; i.e. `M₃` is the complete
bipartite graph on the even and odd residues, verified by direct computation. -/
theorem MobiusLadder3.adj_iff_parity (i j : ZMod 6) :
    MobiusLadder3.Adj i j ↔ i.val % 2 ≠ j.val % 2 := by
  revert i j; decide

/-- A vertex permutation is a **symmetry** of `M₃` iff it preserves adjacency in
both directions (equivalently, is an automorphism of the graph). -/
def IsSym (σ : Equiv.Perm (ZMod 6)) : Prop :=
  ∀ i j, MobiusLadder3.Adj (σ i) (σ j) ↔ MobiusLadder3.Adj i j

instance (σ : Equiv.Perm (ZMod 6)) : Decidable (IsSym σ) := by
  unfold IsSym; infer_instance

/-- The identity is a symmetry. -/
theorem isSym_one : IsSym 1 := by intro i j; simp

/-- Symmetries are closed under composition. -/
theorem isSym_mul {σ τ} (hσ : IsSym σ) (hτ : IsSym τ) : IsSym (σ * τ) := by
  intro i j; rw [Equiv.Perm.mul_apply, Equiv.Perm.mul_apply, hσ, hτ]

/-- Symmetries are closed under inverses. -/
theorem isSym_inv {σ} (hσ : IsSym σ) : IsSym σ⁻¹ := by
  intro i j
  have := hσ (σ⁻¹ i) (σ⁻¹ j)
  simpa using this.symm

/-! ### The explicit symmetry certificate -/

/-- A fixed base edge of `M₃`. -/
def baseEdge : Sym2 (ZMod 6) := s(0, 1)

/-- The explicit symmetry certificate: nine adjacency-preserving permutations
whose images of `baseEdge` run over all nine edges of `M₃`.  Each permutation is
a product of transpositions that move only even vertices among themselves and
only odd vertices among themselves, hence preserves the bipartition. -/
def cert : List (Equiv.Perm (ZMod 6)) :=
  [1,
   Equiv.swap 1 3, Equiv.swap 1 5,
   Equiv.swap 0 2, Equiv.swap 0 2 * Equiv.swap 1 3, Equiv.swap 0 2 * Equiv.swap 1 5,
   Equiv.swap 0 4, Equiv.swap 0 4 * Equiv.swap 1 3, Equiv.swap 0 4 * Equiv.swap 1 5]

/-- **Certificate, part 1.**  Every permutation in `cert` is a symmetry of `M₃`,
checked by direct computation. -/
theorem cert_isSym : ∀ σ ∈ cert, IsSym σ := by
  set_option maxRecDepth 4000 in decide

/-- **Certificate, part 2.**  The images of `baseEdge` under `cert` exhaust every
edge of `M₃`, checked by direct computation. -/
theorem cert_covers :
    ∀ e ∈ MobiusLadder3.edgeFinset, ∃ σ ∈ cert, Sym2.map σ baseEdge = e := by
  set_option maxRecDepth 4000 in decide

/-! ### Main symmetry theorems -/

/-- **Edge-transitivity of `M₃`.**  For any two edges there is a vertex
permutation preserving adjacency (a symmetry of the Möbius ladder) carrying the
first edge onto the second.  This is assembled, with no circular appeal to the
automorphism group, from the explicit certificate `cert` together with the group
structure of the symmetries. -/
theorem edge_transitive {e₁ e₂ : Sym2 (ZMod 6)}
    (h₁ : e₁ ∈ MobiusLadder3.edgeSet) (h₂ : e₂ ∈ MobiusLadder3.edgeSet) :
    ∃ σ : Equiv.Perm (ZMod 6), IsSym σ ∧ Sym2.map σ e₁ = e₂ := by
  rw [← SimpleGraph.mem_edgeFinset] at h₁ h₂
  obtain ⟨σ₁, hm₁, he₁⟩ := cert_covers e₁ h₁
  obtain ⟨σ₂, hm₂, he₂⟩ := cert_covers e₂ h₂
  refine ⟨σ₂ * σ₁⁻¹, isSym_mul (cert_isSym _ hm₂) (isSym_inv (cert_isSym _ hm₁)), ?_⟩
  rw [Equiv.Perm.coe_mul, ← he₁, Sym2.map_map]
  have hcomp : (⇑σ₂ ∘ ⇑σ₁⁻¹) ∘ ⇑σ₁ = ⇑σ₂ := by funext x; simp
  rw [hcomp, he₂]

/-- Translation by a constant is a symmetry of `M₃`, checked by direct
computation. -/
theorem isSym_addRight : ∀ c : ZMod 6, IsSym (Equiv.addRight c) := by decide

/-- **Vertex-transitivity of `M₃`** via the rotation (translation) symmetries. -/
theorem vertex_transitive (u v : ZMod 6) :
    ∃ σ : Equiv.Perm (ZMod 6), IsSym σ ∧ σ u = v := by
  refine ⟨Equiv.addRight (v - u), isSym_addRight _, ?_⟩
  simp

end MobiusLadderCertificate