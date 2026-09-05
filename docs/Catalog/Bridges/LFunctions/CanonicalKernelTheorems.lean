import Mathlib
import Logic.GraphTheory.Defs

/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Canonical Tropical Kernel — Definitions and Theorems

This file introduces the foundational definitions and proves the structural
theorems connecting canonical tropical kernel generators to chip-firing
equivalence and the restricted critical group structure. The central result
establishes that the separation hypothesis forces harmonic uniqueness modulo
constants, which in turn controls chip-firing normal forms.

## Main Definitions

* `graphLap'` — the combinatorial graph Laplacian
* `IsHarmonicOn` — discrete harmonicity on a subset
* `NormalizedOn` — mean-zero normalization on a subset
* `SeparatedOn` — restriction-faithfulness separation hypothesis
* `FiringEquivalentOn` — chip-firing equivalence on a subset
* `IsTreeAttachmentAlong` — tree attachment structure
* `RestrictedLaplacianImage` — image of restricted Laplacian
* `harmonicKernel` — set of harmonic functions on S
* `IsConstant` / `EquivModConst` — constant and modular equivalence

## Main Results

* `constant_isHarmonicOn` — constant functions are harmonic on any subset
* `zero_isHarmonicOn` — the zero function is harmonic
* `isHarmonicOn_add` — sum of harmonic functions is harmonic
* `isHarmonicOn_neg` — negation of harmonic function is harmonic
* `isHarmonicOn_sub` — difference of harmonic functions is harmonic
* `normalizedOn_zero` — the zero function is normalized
* `firingEquiv_refl` — firing equivalence is reflexive
* `firingEquiv_symm` — firing equivalence is symmetric
* `firingEquiv_trans` — firing equivalence is transitive
* `harmonic_constant_shift` — shifting by constant preserves harmonicity
* `harmonic_normalized_unique` — the core uniqueness theorem under separation
* `harmonic_at_leaf_eq_neighbor` — leaf rigidity for harmonic functions
* `laplacian_image_complement_at_S` — Laplacian image splits by support
* `restrictedLaplacianImage_zero/add/neg` — restricted image is a subgroup
* `harmonic_tree_attachment_forces_unique_firing` — tropical rigidity gives
    chip-firing uniqueness on tree attachments

## References

* Baker, M. and Norine, S. "Riemann–Roch and Abel–Jacobi theory on a
  finite graph" (2007)
-/


open Finset BigOperators

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ### Graph Laplacian -/

/-- The combinatorial graph Laplacian matrix `L(G)` with entries:
    `L(v,v) = deg(v)`, `L(v,w) = -1` if `v ~ w`, `L(v,w) = 0` otherwise. -/
def graphLap'
    (G : SimpleGraph V) [DecidableRel G.Adj] : Matrix V V ℤ :=
  fun i j =>
    if i = j then (G.degree i : ℤ)
    else if G.Adj i j then -1
    else 0

/-
Row-sum-zero property of the graph Laplacian.
-/
theorem graphLap'_row_sum_zero
    (G : SimpleGraph V) [DecidableRel G.Adj] (i : V) :
    ∑ j : V, graphLap' G i j = 0 := by
  simp +decide only [graphLap', sum_ite];
  simp +decide [ Finset.filter_ne, Finset.filter_and, SimpleGraph.degree, SimpleGraph.neighborFinset_def ];
  simp +decide [ Finset.filter_eq, Finset.filter_erase ]

/-
Symmetry of the graph Laplacian.
-/
theorem graphLap'_symmetric
    (G : SimpleGraph V) [DecidableRel G.Adj] (i j : V) :
    graphLap' G i j = graphLap' G j i := by
  unfold graphLap';
  by_cases hij : i = j <;> simp +decide [ hij, SimpleGraph.adj_comm ];
  · rw [ hij ];
  · grind +splitImp

/-! ### Core Definitions -/

/-- A function `f : V → ℤ` is **harmonic on** a subset `S` with respect to graph `G`
    if for every vertex `v ∈ S`, the Laplacian of `f` at `v` vanishes. -/
def IsHarmonicOn
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) (f : V → ℤ) : Prop :=
  ∀ v ∈ S, ∑ w : V, graphLap' G v w * f w = 0

/-- A function is **normalized on** `S` if its values sum to zero over `S`. -/
def NormalizedOn (S : Finset V) (f : V → ℤ) : Prop :=
  ∑ v ∈ S, f v = 0

/-- The **separation hypothesis**: if two harmonic functions on `S` are both
    normalized and agree on every vertex of `S`, they are equal everywhere. -/
def SeparatedOn
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) : Prop :=
  ∀ ⦃f g : V → ℤ⦄,
    IsHarmonicOn G S f →
    IsHarmonicOn G S g →
    NormalizedOn S f →
    NormalizedOn S g →
    (∀ v ∈ S, f v = g v) →
    f = g

/-- Two functions are **firing-equivalent on** `S` if they differ by a
    Laplacian image of a function supported on `S`. -/
def FiringEquivalentOn
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (S : Finset V) (f g : V → ℤ) : Prop :=
  ∃ c : V → ℤ, (∀ v, v ∉ S → c v = 0) ∧
    ∀ v, g v = f v + ∑ w : V, graphLap' G v w * c w

/-- A subset `T` is a **tree attachment along** `S` in `G`. -/
structure IsTreeAttachmentAlong
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (S T : Finset V) : Prop where
  disjoint : Disjoint S T
  single_attachment : ∀ v ∈ T,
    ((S.filter (G.Adj v)).card ≤ 1)
  acyclic : ∀ v ∈ T, ∀ w ∈ T, v ≠ w →
    G.Adj v w →
    ¬∃ p : G.Walk v w, p.support.tail.toFinset ⊆ ↑T ∧ p.support.length > 2

/-- The **restricted Laplacian image** on `S`. -/
def RestrictedLaplacianImage
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (S : Finset V) : Set (V → ℤ) :=
  {h | ∃ c : V → ℤ, (∀ v, v ∉ S → c v = 0) ∧
    ∀ v, h v = ∑ w : V, graphLap' G v w * c w}

/-- The **harmonic kernel** on `S`. -/
def harmonicKernel
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (S : Finset V) : Set (V → ℤ) :=
  {f | IsHarmonicOn G S f}

/-- A function is **constant**. -/
def IsConstant' (f : V → ℤ) : Prop :=
  ∀ v w : V, f v = f w

/-- Two functions are **equivalent modulo constants**. -/
def EquivModConst (f g : V → ℤ) : Prop :=
  ∃ c : ℤ, ∀ v, f v = g v + c

/-! ## Laplacian Properties -/

theorem graphLap'_row_sum_zero'
    (G : SimpleGraph V) [DecidableRel G.Adj] (i : V) :
    ∑ j : V, graphLap' G i j = 0 := by
  convert graphLap'_row_sum_zero G i

/-! ## Basic Harmonic Function Properties -/

/-
**Constant functions are harmonic on any subset.**
-/
theorem constant_isHarmonicOn
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (S : Finset V) (c : ℤ) :
    IsHarmonicOn G S (fun _ => c) := by
  -- By definition of harmonic, we need to show that for every vertex v in S, the Laplacian of f at v is zero.
  unfold IsHarmonicOn
  intro v hv
  simp [graphLap'];
  simp +decide [ Finset.sum_ite, Finset.filter_eq, Finset.filter_ne, SimpleGraph.degree, SimpleGraph.neighborFinset_def ];
  simp +decide [ Finset.filter_erase, SimpleGraph.adj_comm ]

/-
**The zero function is harmonic on any subset.**
-/
theorem zero_isHarmonicOn
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (S : Finset V) :
    IsHarmonicOn G S (fun _ => 0) := by
  exact fun v _ => by simp +decide [ IsHarmonicOn ] ;

/-
**Sum of harmonic functions is harmonic.**
-/
theorem isHarmonicOn_add
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (S : Finset V) {f g : V → ℤ}
    (hf : IsHarmonicOn G S f) (hg : IsHarmonicOn G S g) :
    IsHarmonicOn G S (fun v => f v + g v) := by
  intro v hv; convert congr_arg₂ ( · + · ) ( hf v hv ) ( hg v hv ) using 1; simp +decide [ mul_add, Finset.sum_add_distrib ] ;

/-
**Negation of a harmonic function is harmonic.**
-/
theorem isHarmonicOn_neg
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (S : Finset V) {f : V → ℤ}
    (hf : IsHarmonicOn G S f) :
    IsHarmonicOn G S (fun v => -f v) := by
  exact fun v hv => by simpa [ mul_neg, Finset.sum_neg_distrib ] using hf v hv

/-
**Difference of harmonic functions is harmonic.**
-/
theorem isHarmonicOn_sub
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (S : Finset V) {f g : V → ℤ}
    (hf : IsHarmonicOn G S f) (hg : IsHarmonicOn G S g) :
    IsHarmonicOn G S (fun v => f v - g v) := by
  intro v hv; have := hf v hv; have := hg v hv; simp_all +decide [ mul_sub, Finset.sum_sub_distrib ] ;

/-
**Scalar multiples of harmonic functions are harmonic.**
-/
theorem isHarmonicOn_smul
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (S : Finset V) {f : V → ℤ} (k : ℤ)
    (hf : IsHarmonicOn G S f) :
    IsHarmonicOn G S (fun v => k * f v) := by
  intro v hv; specialize hf v hv; simp_all +decide [ ← mul_sum, ← Finset.mul_sum _ _ _, ← Finset.sum_mul, graphLap'_row_sum_zero' ] ;
  convert congr_arg ( fun x : ℤ => k * x ) hf using 1 ; ring;
  · simp +decide only [mul_assoc, mul_left_comm, Finset.mul_sum _ _ _];
  · ring

/-! ## Normalization Properties -/

/-
**The zero function is normalized on any subset.**
-/
theorem normalizedOn_zero (S : Finset V) :
    NormalizedOn S (fun _ : V => (0 : ℤ)) := by
  unfold NormalizedOn; simp +decide ;

/-
**Normalized addition.**
-/
theorem normalizedOn_add (S : Finset V) {f g : V → ℤ}
    (hf : NormalizedOn S f) (hg : NormalizedOn S g) :
    NormalizedOn S (fun v => f v + g v) := by
  unfold NormalizedOn at *; simp_all +decide [ Finset.sum_add_distrib ] ;

/-
**Normalized negation.**
-/
theorem normalizedOn_neg (S : Finset V) {f : V → ℤ}
    (hf : NormalizedOn S f) :
    NormalizedOn S (fun v => -f v) := by
  convert neg_eq_zero.mpr hf using 1;
  simp +decide [ NormalizedOn ]

/-! ## Equivalence Modulo Constants -/

/-
**Mod-const equivalence is reflexive.**
-/
theorem equivModConst_refl (f : V → ℤ) :
    EquivModConst f f := by
  exact ⟨ 0, fun _ => by simp +decide ⟩

/-
**Mod-const equivalence is symmetric.**
-/
theorem equivModConst_symm {f g : V → ℤ}
    (h : EquivModConst f g) :
    EquivModConst g f := by
  obtain ⟨ c, hc ⟩ := h; exact ⟨ -c, fun v => by simp +decide [ hc v ] ⟩ ;

/-
**Mod-const equivalence is transitive.**
-/
theorem equivModConst_trans {f g h : V → ℤ}
    (hfg : EquivModConst f g) (hgh : EquivModConst g h) :
    EquivModConst f h := by
  obtain ⟨ c₁, hc₁ ⟩ := hfg
  obtain ⟨ c₂, hc₂ ⟩ := hgh
  use c₁ + c₂
  intro v
  simp [hc₁, hc₂];
  ring

/-
**Every constant function is mod-const equivalent to zero.**
-/
theorem equivModConst_of_constant {f : V → ℤ}
    (hf : IsConstant' f) [Nonempty V] :
    EquivModConst f (fun _ => 0) := by
  exact ⟨ f ( Classical.arbitrary V ), fun v => by simp +decide [ hf v ( Classical.arbitrary V ) ] ⟩

/-! ## Harmonic Functions and Constants -/

/-
**Shifting a harmonic function by a constant preserves harmonicity.**
-/
theorem harmonic_constant_shift
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (S : Finset V) {f : V → ℤ} (c : ℤ)
    (hf : IsHarmonicOn G S f) :
    IsHarmonicOn G S (fun v => f v + c) := by
  convert isHarmonicOn_add G S hf ( constant_isHarmonicOn G S c ) using 1

/-! ## Firing Equivalence Structure -/

/-
**Firing equivalence is reflexive.**
-/
theorem firingEquiv_refl
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (S : Finset V) (f : V → ℤ) :
    FiringEquivalentOn G S f f := by
  exact ⟨ fun _ => 0, fun _ _ => rfl, fun _ => by simp +decide ⟩

/-
**Firing equivalence is symmetric.**
-/
theorem firingEquiv_symm
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (S : Finset V) {f g : V → ℤ}
    (h : FiringEquivalentOn G S f g) :
    FiringEquivalentOn G S g f := by
  obtain ⟨ c, hc₁, hc₂ ⟩ := h;
  refine' ⟨ fun v => -c v, _, _ ⟩ <;> simp_all +decide

/-
**Firing equivalence is transitive.**
-/
theorem firingEquiv_trans
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (S : Finset V) {f g h : V → ℤ}
    (hfg : FiringEquivalentOn G S f g)
    (hgh : FiringEquivalentOn G S g h) :
    FiringEquivalentOn G S f h := by
  -- By definition of firing equivalence, there exist vectors $c1$ and $c2$ such that $g = f + L \cdot c1$ and $h = g + L \cdot c2$.
  obtain ⟨c1, hc1⟩ := hfg
  obtain ⟨c2, hc2⟩ := hgh;
  refine' ⟨ c1 + c2, fun v hv => _, fun v => _ ⟩ <;> simp_all +decide [ Finset.sum_add_distrib, mul_add ];
  ring

/-! ## The Core Uniqueness Theorem -/

/-- **The core harmonic uniqueness theorem under separation.**
    If `G` satisfies the separation hypothesis on `S`, and two harmonic
    functions are both normalized and agree on `S`, then they are globally equal. -/
theorem harmonic_normalized_unique
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (S : Finset V)
    (hsep : SeparatedOn G S)
    {f g : V → ℤ}
    (hf : IsHarmonicOn G S f)
    (hg : IsHarmonicOn G S g)
    (hnf : NormalizedOn S f)
    (hng : NormalizedOn S g)
    (heq : ∀ v ∈ S, f v = g v) :
    f = g :=
  hsep hf hg hnf hng heq

/-! ## Harmonic Leaf Rigidity -/

/-
**Leaf vertex harmonicity forces value.**
    If `v` is a leaf (degree 1) in `G` with unique neighbor `w`, and `f` is
    harmonic at `v`, then `f v = f w`.
-/
theorem harmonic_at_leaf_eq_neighbor
    (G : SimpleGraph V) [DecidableRel G.Adj]
    {v w : V} (f : V → ℤ)
    (hdeg : G.degree v = 1)
    (hadj : G.Adj v w)
    (hharm : ∑ u : V, graphLap' G v u * f u = 0) :
    f v = f w := by
  -- Since $v$ is a leaf, $v$ has only one neighbor, which is $w$. Therefore, we can simplify the sum.
  have h_sum_simplify : ∑ u ∈ (G.neighborFinset v), graphLap' G v u * f u = -f w := by
    rw [ Finset.sum_eq_single_of_mem w ];
    · unfold graphLap'; aesop;
    · aesop;
    · intro b hb hb'; have := Finset.card_eq_one.mp hdeg; obtain ⟨ x, hx ⟩ := this; simp_all +decide [ SimpleGraph.neighborFinset ] ;
      rw [ Finset.eq_singleton_iff_unique_mem ] at hx ; aesop;
  simp_all +decide [ Finset.sum_ite, SimpleGraph.degree, SimpleGraph.neighborFinset ];
  simp_all +decide [ Finset.sum_subset, SimpleGraph.neighborSet ];
  simp_all +decide [ Finset.sum_ite, Finset.filter_ne', Finset.filter_eq', graphLap' ];
  simp_all +decide [ Finset.filter_filter, Finset.filter_eq, Finset.filter_ne, SimpleGraph.degree, SimpleGraph.neighborFinset ];
  simp_all +decide [ Finset.filter_and, Finset.filter_eq, Finset.filter_ne, SimpleGraph.adj_comm ];
  simp_all +decide [ Finset.filter_erase, SimpleGraph.adj_comm ];
  lia

/-! ## Laplacian Support Splitting -/

/-
**Laplacian image splits by support.**
    If `c` vanishes on `S`, then the Laplacian image at a vertex `v ∈ S`
    only depends on the complement.
-/
theorem laplacian_image_complement_at_S
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (S : Finset V) (c : V → ℤ)
    (hsupp : ∀ v, v ∈ S → c v = 0) (v : V) (_hv : v ∈ S) :
    ∑ w : V, graphLap' G v w * c w =
    ∑ w ∈ Finset.univ.filter (· ∉ S), graphLap' G v w * c w := by
  rw [ ← Finset.sum_subset ( Finset.subset_univ ( Finset.filter ( fun w => w∉S ) Finset.univ ) ) ] ; aesop

/-! ## Restricted Laplacian Image Structure -/

/-
**The restricted Laplacian image contains zero.**
-/
theorem restrictedLaplacianImage_zero
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (S : Finset V) :
    (fun _ => (0 : ℤ)) ∈ RestrictedLaplacianImage G S := by
  exact ⟨ fun _ => 0, fun _ _ => rfl, fun _ => by simp +decide ⟩

/-
**The restricted Laplacian image is closed under addition.**
-/
theorem restrictedLaplacianImage_add
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (S : Finset V) {f g : V → ℤ}
    (hf : f ∈ RestrictedLaplacianImage G S)
    (hg : g ∈ RestrictedLaplacianImage G S) :
    (fun v => f v + g v) ∈ RestrictedLaplacianImage G S := by
  obtain ⟨ c1, hc1, hf ⟩ := hf
  obtain ⟨ c2, hc2, hg ⟩ := hg
  use fun v => c1 v + c2 v;
  simp +decide [ *, mul_add, Finset.sum_add_distrib ];
  exact fun v hv => by rw [ hc1 v hv, hc2 v hv, add_zero ] ;

/-
**The restricted Laplacian image is closed under negation.**
-/
theorem restrictedLaplacianImage_neg
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (S : Finset V) {f : V → ℤ}
    (hf : f ∈ RestrictedLaplacianImage G S) :
    (fun v => -f v) ∈ RestrictedLaplacianImage G S := by
  obtain ⟨ c, hc₁, hc₂ ⟩ := hf;
  refine' ⟨ fun w => -c w, _, _ ⟩ <;> simp_all +decide

/-! ## Cross-Domain: Tropical Rigidity Gives Chip-Firing Uniqueness -/

/-
**Harmonic rigidity implies chip-firing uniqueness on tree attachments.**
    Under the separation hypothesis, if `f` and `g` are harmonic on `S ∪ T`,
    agree on `S`, and `T` is a tree attachment along `S`, then `f` and `g`
    are firing-equivalent on `S ∪ T`.

    This bridges tropical rigidity to chip-firing propagation.
-/
theorem harmonic_tree_attachment_forces_unique_firing
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (S T : Finset V)
    (_hconn : G.Connected)
    (hsep : SeparatedOn G S)
    (_htree : IsTreeAttachmentAlong G S T)
    (f g : V → ℤ)
    (hf : IsHarmonicOn G (S ∪ T) f)
    (hg : IsHarmonicOn G (S ∪ T) g)
    (heq : ∀ v ∈ S, f v = g v) :
    FiringEquivalentOn G (S ∪ T) f g := by
  -- Use the zero firing vector c = 0. We need to show f = g on S ∪ T.
  use 0;
  contrapose! hsep;
  simp_all +decide [ SeparatedOn ];
  refine' ⟨ fun v => f v - g v - ( ∑ v ∈ S, ( f v - g v ) ) / S.card, _, fun v => 0, _, _, _, _ ⟩ <;> simp_all +decide [ IsHarmonicOn, NormalizedOn ];
  · simp_all +decide [ mul_sub ];
  · exact fun h => hsep.elim fun v hv => hv <| by have := congr_fun h v; norm_num at this; linarith;


-- NOTE: the auto-merged block below was syntactically broken: the merge kept the
-- doc-comments of `CanonicalKernelDefs.lean` but dropped the declaration headers and
-- bodies they belong to, so the text was not parseable Lean.  It is preserved verbatim
-- as comments; the intact definitions live in `Bridges/PosetTheory/CanonicalKernelDefs.lean`.
-- -- !-- Merged from CanonicalKernelDefs.lean (auto-dedup) -- !--
--
-- This file introduces the foundational definitions for the canonical tropical
-- kernel theory, connecting harmonic functions on graph subsets to chip-firing
-- equivalence classes and the restricted critical group.
-- * `IsHarmonicOn` — a function satisfies the discrete Laplace equation on a subset
-- * `NormalizedOn` — a function sums to zero on a subset (mean-zero normalization)
-- * `SeparatedOn` — the restriction-faithfulness separation hypothesis
-- * `FiringEquivalentOn` — two functions differ by a Laplacian image supported on a subset
-- * `IsTreeAttachmentAlong` — a set T is attached to S as a tree
-- * `RestrictedLaplacianImage` — the image of the restricted Laplacian on S
-- * `harmonicKernel` — the set of harmonic functions on S
-- * Baker, M. and Norine, S. "Riemann–Roch and Abel–Jacobi theory on a finite graph" (2007)
-- /-! ### Harmonic Functions on Subsets -/
--     if for every vertex `v ∈ S`, the Laplacian of `f` at `v` vanishes:
--     `∑ w, L(v,w) · f(w) = 0`.
--     This is the discrete analogue of harmonicity in potential theory. -/
--   ∀ v ∈ S, ∑ w : V, graphLaplacian G v w * f w = 0
--
-- /-- A function is **normalized on** `S` if its values sum to zero over `S`:
--     `∑ v ∈ S, f(v) = 0`. This removes the constant-function ambiguity
--     from the harmonic kernel. -/
--
-- /-- The **separation hypothesis** for `S` in `G`: if two harmonic functions on `S`
--     are both normalized on `S` and agree on every vertex of `S`, then they are
--     equal everywhere. This ensures that harmonic extensions from `S` are unique
--     and encodes the geometric idea that `S` "sees" enough of the graph. -/
--     Laplacian image of a function supported on `S`. This is the algebraic
--     expression of chip-firing: `g = f + L · c` where `c` is supported on `S`. -/
--     ∀ v, g v = f v + ∑ w : V, graphLaplacian G v w * c w
--
-- /-- A subset `T` is a **tree attachment along** `S` in `G` if:
--     1. `S` and `T` are disjoint,
--     2. Every vertex in `T` has at most one neighbor in `S`,
--     3. The induced subgraph on `T` is acyclic (forest),
--     4. Every vertex in `T` has a path to `S` through `T`. -/
--
-- /-- The **restricted Laplacian image** on `S`: the set of functions that arise
--     as `L · c` for some `c` supported on `S`. This is the chip-firing lattice
--     restricted to `S`. -/
--     ∀ v, h v = ∑ w : V, graphLaplacian G v w * c w}
--
-- /-- The **harmonic kernel** on `S`: the set of all functions harmonic on `S`. -/
--
-- /-- A function is **constant** if it takes a single value everywhere. -/
-- def IsConstant (f : V → ℤ) : Prop :=
--
-- /-- Two functions are **equivalent modulo constants** if they differ by
--     a constant function. -/
--
--
--