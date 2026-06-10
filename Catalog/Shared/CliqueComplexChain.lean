/-
# The Simplicial Chain Complex of a Clique Complex over ℤ

The clique complex `Δ(G)` of a simple graph `G` is the abstract simplicial complex
whose `k`-faces are the `(k+1)`-cliques of `G`.  Choosing a linear order on the
vertex set turns the set of finite cliques into an *ordered* simplicial complex,
and the standard alternating-sum boundary operator

  ∂(s) = Σ_{x ∈ s} (-1)^{rank of x in s} · (s \ {x})

makes the free ℤ-modules on faces into a chain complex.

This file develops that chain complex purely combinatorially on `Finset V →₀ ℤ`
(the free ℤ-module on all finite subsets, of which the clique complex is a
downward-closed sub-object) and proves the defining identity `∂ ∘ ∂ = 0`.
We then connect it back to graphs: cliques are downward closed, and the boundary
of a clique-face is supported on clique-faces, so the construction restricts to a
genuine chain complex of `Δ(G)`.

The novelty here is a fully self-contained, order-theoretic proof of `∂² = 0`
via a sign-reversing involution on ordered pairs of vertices, packaged so that it
applies verbatim to the clique complex of an arbitrary simple graph.
-/
import Mathlib

open Finset SimpleGraph

namespace CliqueComplexChain

variable {V : Type*} [LinearOrder V]

/-- The orientation sign of vertex `x` inside the ordered simplex `s`: it is
`(-1)` raised to the number of vertices of `s` strictly below `x`, i.e. the rank
(position) of `x` in the increasing enumeration of `s`. -/
def sgn (x : V) (s : Finset V) : ℤ := (-1) ^ (s.filter (· < x)).card

/-- The boundary of a single oriented simplex `s`, as a ℤ-linear combination of
its codimension-1 faces. -/
noncomputable def bdSingle (s : Finset V) : Finset V →₀ ℤ :=
  ∑ x ∈ s, Finsupp.single (s.erase x) (sgn x s)

/-- The boundary operator on the free ℤ-module of chains, extended linearly. -/
noncomputable def bd : (Finset V →₀ ℤ) →ₗ[ℤ] (Finset V →₀ ℤ) :=
  Finsupp.linearCombination ℤ bdSingle

-- !-- Evaluating the linear boundary on a basis chain just scales `bdSingle`. -- !--
lemma bd_single (s : Finset V) (c : ℤ) :
    bd (Finsupp.single s c) = c • bdSingle s := by
  simp [bd, Finsupp.linearCombination_single]

/-
!-- If `x ∉ s` is not below `y`, erasing `x` does not change the rank of `y`,
so the sign is unchanged.  Uses `Finset.filter_erase`. -- !--
-/
lemma sgn_erase_not_lt {s : Finset V} {x y : V} (h : ¬ x < y) :
    sgn y (s.erase x) = sgn y s := by
  unfold sgn;
  rw [ Finset.filter_erase ] ; aesop

/-
!-- If `x ∈ s` lies below `y`, erasing `x` drops the rank of `y` by one, so the
sign flips.  Uses `Finset.filter_erase` and `(-1)^(n+1) = -(-1)^n`. -- !--
-/
lemma sgn_erase_lt {s : Finset V} {x y : V} (hx : x ∈ s) (h : x < y) :
    sgn y (s.erase x) = - sgn y s := by
  unfold sgn; simp +decide [ *, Finset.filter_erase ] ;
  rw [ ← Nat.sub_add_cancel ( show 1 ≤ # ( { x ∈ s | x < y } ) from Finset.card_pos.mpr ⟨ x, by aesop ⟩ ), pow_succ' ] ; ring!;

/-
!-- Core sign-cancellation: the two ways of removing an unordered pair `{x,y}`
from `s` carry opposite signs.  Case split on the trichotomy of `x` and `y`,
using `sgn_erase_lt` / `sgn_erase_not_lt`. -- !--
-/
lemma sgn_swap {s : Finset V} {x y : V} (hx : x ∈ s) (hy : y ∈ s) (hxy : x ≠ y) :
    sgn x s * sgn y (s.erase x) = - (sgn y s * sgn x (s.erase y)) := by
  cases lt_or_gt_of_ne hxy <;> simp_all +decide [ sgn_erase_lt ];
  · grind +suggestions;
  · rw [ sgn_erase_not_lt ];
    · ring;
    · exact not_lt_of_gt ‹_›

/-
!-- The boundary of a boundary of one simplex vanishes.  Expand into a double
sum over ordered pairs `(x,y)`, reindex over `s.sigma (fun x => s.erase x)`,
and kill it with `Finset.sum_involution` using the swap `(x,y) ↦ (y,x)`:
paired terms hit the same face `(s.erase x).erase y = (s.erase y).erase x`
(`Finset.erase_right_comm`) with opposite signs by `sgn_swap`. -- !--
-/
lemma bd_bdSingle (s : Finset V) : bd (bdSingle s) = 0 := by
  unfold bd bdSingle;
  simp +decide [ Finset.smul_sum ];
  -- By pairing each term with its negative counterpart, we can show that the sum is zero.
  have h_pair : ∀ x ∈ s, ∀ y ∈ s.erase x, (Finsupp.single ((s.erase x).erase y) (sgn x s)) * (Finsupp.single ((s.erase x).erase y) (sgn y (s.erase x))) + (Finsupp.single ((s.erase y).erase x) (sgn y s)) * (Finsupp.single ((s.erase y).erase x) (sgn x (s.erase y))) = 0 := by
    intro x hx y hy; ext z; simp +decide [ Finsupp.single_apply, Finset.erase_right_comm ] ;
    split_ifs <;> simp_all +decide [ sgn_swap ];
  have h_sum_zero : ∑ x ∈ s, ∑ y ∈ s.erase x, (Finsupp.single ((s.erase x).erase y) (sgn x s)) * (Finsupp.single ((s.erase x).erase y) (sgn y (s.erase x))) = ∑ x ∈ s, ∑ y ∈ s.erase x, (Finsupp.single ((s.erase y).erase x) (sgn y s)) * (Finsupp.single ((s.erase y).erase x) (sgn x (s.erase y))) := by
    rw [ Finset.sum_sigma', Finset.sum_sigma' ];
    apply Finset.sum_bij (fun x _ => ⟨x.snd, x.fst⟩);
    · aesop;
    · aesop;
    · aesop;
    · grind;
  have h_sum_zero : ∑ x ∈ s, ∑ y ∈ s.erase x, (Finsupp.single ((s.erase x).erase y) (sgn x s)) * (Finsupp.single ((s.erase x).erase y) (sgn y (s.erase x))) + ∑ x ∈ s, ∑ y ∈ s.erase x, (Finsupp.single ((s.erase y).erase x) (sgn y s)) * (Finsupp.single ((s.erase y).erase x) (sgn x (s.erase y))) = 0 := by
    simpa only [ ← Finset.sum_add_distrib ] using Finset.sum_eq_zero fun x hx => Finset.sum_eq_zero fun y hy => h_pair x hx y hy;
  simp_all +decide [ ← two_smul ℤ ]

/-
!-- `∂² = 0` on every chain, by `Finsupp.induction` reducing to `bd_bdSingle`. -- !--
-/
theorem boundary_sq_zero (z : Finset V →₀ ℤ) : bd (bd z) = 0 := by
  induction' z using Finsupp.induction with a b f ha h_ind;
  · simp +decide [ bd ];
  · simp_all +decide [ bd_single, bd_bdSingle, map_add ]

-- !-- The chain-complex identity `∂ ∘ ∂ = 0` as linear maps. -- !--
theorem boundary_comp_self : (bd : (Finset V →₀ ℤ) →ₗ[ℤ] _).comp bd = 0 := by
  refine LinearMap.ext (fun z => ?_)
  simpa using boundary_sq_zero z

/-! ## Connection to the clique complex of a graph -/

/-- A finite set of vertices is a face of the clique complex of `G` iff it is a
clique. -/
def IsFace (G : SimpleGraph V) (s : Finset V) : Prop := G.IsClique (s : Set V)

-- !-- Faces are downward closed: a subset of a clique is a clique
-- (`SimpleGraph.IsClique.subset`). -- !--
omit [LinearOrder V] in
theorem isFace_downward_closed (G : SimpleGraph V) {s t : Finset V}
    (h : t ⊆ s) (hs : IsFace G s) : IsFace G t := by
  exact hs.subset (by exact_mod_cast Finset.coe_subset.mpr h)

-- !-- The empty face is always present. -- !--
omit [LinearOrder V] in
theorem empty_isFace (G : SimpleGraph V) : IsFace G (∅ : Finset V) := by
  simp [IsFace]

-- !-- Every vertex is a `0`-face. -- !--
omit [LinearOrder V] in
theorem singleton_isFace (G : SimpleGraph V) (v : V) : IsFace G ({v} : Finset V) := by
  simp [IsFace]

/-
!-- The boundary of a clique-face is supported on clique-faces, so `∂` really
maps clique-chains to clique-chains.  Each support element is some `s.erase x`,
a subset of `s`, hence a face by `isFace_downward_closed`. -- !--
-/
theorem bdSingle_support_isFace (G : SimpleGraph V) {s : Finset V}
    (hs : IsFace G s) {t : Finset V} (ht : t ∈ (bdSingle s).support) :
    IsFace G t := by
  -- Every element in the support of `bdSingle s` is of the form `s.erase x` for some `x ∈ s`.
  obtain ⟨x, hx⟩ : ∃ x ∈ s, t = s.erase x := by
    simp [bdSingle] at ht;
    contrapose! ht; simp_all +decide ;
  exact isFace_downward_closed _ ( Finset.erase_subset _ _ ) hs |> fun h => by aesop;

end CliqueComplexChain