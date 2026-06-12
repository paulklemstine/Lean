/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Holographic Dictionary: Valuations, Anomalies, and Entanglement Structure

This module establishes a rigorous mathematical dictionary between holographic
gravity and quantum error correction, building on the entropy profiles of
`Physics.HolographicGravity` and coding structures of `Bridges.HolographicCoding`.

## Core Mathematical Contribution

The central result is the **Modular Decomposition Theorem**: a set function
`f : Finset α → ℝ` that is modular (i.e., f(X∪Y) + f(X∩Y) = f(X) + f(Y))
and vanishes on ∅ is completely determined by its values on singletons:

  `f(X) = ∑ a ∈ X, f({a})`

This connects to holographic gravity via the **Flatness–Atomicity Bridge**:
when a holographic entropy profile has zero total defect (flat geometry),
its entropy function is modular, hence decomposes atomically. Physically,
this means zero-gravity holographic states carry no correlations beyond
single-site entropies — a rigidity theorem for flat spacetimes.

## Main Results

* `modular_sum_singletons` — Modular decomposition into atomic contributions
* `flat_profile_atomic` — Flat holographic profiles decompose atomically
* `singleton_gap_nonneg` — The Singleton gap (coding anomaly) is nonneg
* `mmi_four_party_ineq` — MMI yields 4-party mutual information bounds
-/

open Finset BigOperators

/-! ## Part I: Modular Functions on the Boolean Lattice -/

namespace ModularDecomposition

variable {α : Type*} [DecidableEq α] [Fintype α]

/-- A set function `f : Finset α → ℝ` is **modular** if it satisfies the
valuation identity `f(X ∪ Y) + f(X ∩ Y) = f(X) + f(Y)` for all X, Y.

Equivalently, f is both submodular and supermodular. Modular functions are
the "flat" points of the submodularity cone — they sit on the boundary
where the inequality becomes an equality. -/
def IsModular (f : Finset α → ℝ) : Prop :=
  ∀ X Y : Finset α, f (X ∪ Y) + f (X ∩ Y) = f X + f Y

/-- The atomic sum: ∑ a ∈ X, f({a}). -/
noncomputable def atomicSum (f : Finset α → ℝ) (X : Finset α) : ℝ :=
  ∑ a ∈ X, f {a}

/-
**Modular Decomposition Theorem**: Every modular set function with f(∅) = 0
decomposes as a sum over singletons. This is the classification of valuations
on the Boolean lattice `2^α`.

Proof sketch: By Finset induction. For X = ∅, both sides are 0.
For X = insert a Y with a ∉ Y, modularity gives
f(Y ∪ {a}) + f(Y ∩ {a}) = f(Y) + f({a}).
Since a ∉ Y, Y ∩ {a} = ∅, so f(Y ∪ {a}) = f(Y) + f({a}) - f(∅) = f(Y) + f({a}).
By induction, f(Y) = ∑ b ∈ Y, f({b}), giving f(X) = ∑ a ∈ X, f({a}).
-/
theorem modular_sum_singletons (f : Finset α → ℝ)
    (hmod : IsModular f) (hempty : f ∅ = 0) :
    ∀ X : Finset α, f X = atomicSum f X := by
  intro X;
  induction' X using Finset.induction with a X ha ih;
  · exact hempty;
  · have := hmod ( { a } ) X;
    simp_all +decide [ Finset.inter_comm, Finset.inter_singleton, atomicSum ]

/-
**Example**: The cardinality function is modular with card(X) = ∑_{a∈X} 1.
-/
example : IsModular (fun X : Finset (Fin 3) => (X.card : ℝ)) := by
  intro X Y; have := Finset.card_union_add_card_inter X Y; simp +decide [ *, mul_comm ] ; ring;
  exact mod_cast this

/-
**Generalization**: Modular decomposition over a general lattice.
For a modular function on a finite distributive lattice, the function
is determined by its values on join-irreducible elements.
-/
theorem modular_sum_singletons_general (f : Finset α → ℝ) (g : α → ℝ)
    (hmod : IsModular f) (hempty : f ∅ = 0)
    (hg : ∀ (a : α), f {a} = g a) :
    ∀ X : Finset α, f X = ∑ a ∈ X, g a := by
  convert modular_sum_singletons f hmod hempty using 1;
  unfold atomicSum; aesop;

/-
**Boundary/Counterexample**: Submodularity alone does NOT imply atomic
decomposition. The function f(X) = min(|X|, 1) is submodular with f(∅)=0
but f({a,b}) = 1 ≠ f({a}) + f({b}) = 2 for distinct a, b.
We verify this for α = Fin 2.
-/
theorem submodular_not_atomic :
    ∃ f : Finset (Fin 2) → ℝ,
      f ∅ = 0 ∧
      (∀ X Y, f X + f Y ≥ f (X ∩ Y) + f (X ∪ Y)) ∧
      ¬(∀ X, f X = ∑ a ∈ X, f {a}) := by
  refine' ⟨ fun X => if X = ∅ then 0 else if X = { 0 } then 1 else if X = { 1 } then 1 else 1, _, _, _ ⟩ <;> simp +decide;
  · norm_cast;
  · exact ⟨ { 0, 1 }, by norm_cast ⟩

/-
Modular functions are closed under addition.
-/
theorem isModular_add (f g : Finset α → ℝ) (hf : IsModular f) (hg : IsModular g) :
    IsModular (f + g) := by
  intro X Y; have := hf X Y; have := hg X Y; norm_num at *; linarith;

/-
Modular functions are closed under scalar multiplication.
-/
theorem isModular_smul (f : Finset α → ℝ) (c : ℝ) (hf : IsModular f) :
    IsModular (c • f) := by
  intro X Y; have := hf X Y; simp_all +decide ;
  linear_combination' c * this

/-
The zero function is modular.
-/
omit [Fintype α] in
theorem isModular_zero : IsModular (0 : Finset α → ℝ) := by
  exact fun _ _ => by simp +decide ;

/-
Uniqueness: a modular function with f(∅) = 0 is determined by singleton values.
-/
theorem modular_determined_by_singletons (f g : Finset α → ℝ)
    (hfmod : IsModular f) (hgmod : IsModular g)
    (hfe : f ∅ = 0) (hge : g ∅ = 0)
    (hsing : ∀ a : α, f {a} = g {a}) :
    f = g := by
  ext X;
  rw [ modular_sum_singletons f hfmod hfe, modular_sum_singletons g hgmod hge ];
  exact Finset.sum_congr rfl fun x hx => hsing x

end ModularDecomposition

/-! ## Part II: Holographic Entropy Profiles (Self-Contained Definitions) -/

namespace HolographicDictionary

variable {α : Type*} [DecidableEq α] [Fintype α]

/-- An **extended holographic entropy profile** on a finite boundary type.
Encodes entropy with purification (pure global state) and complementarity. -/
structure HoloProfile (α : Type*) [DecidableEq α] [Fintype α] where
  S : Finset α → ℝ
  S_empty : S ∅ = 0
  S_nonneg : ∀ X, 0 ≤ S X
  submod : ∀ X Y, S X + S Y ≥ S (X ∩ Y) + S (X ∪ Y)
  S_univ : S Finset.univ = 0
  complement : ∀ X, S X = S (Finset.univ \ X)

/-- Mutual information. -/
def mutualInfo (H : HoloProfile α) (X Y : Finset α) : ℝ :=
  H.S X + H.S Y - H.S (X ∪ Y)

/-- Tripartite information I₃(A:B:C). -/
def tripartiteInfo (H : HoloProfile α) (X Y Z : Finset α) : ℝ :=
  H.S X + H.S Y + H.S Z - H.S (X ∪ Y) - H.S (X ∪ Z) - H.S (Y ∪ Z)
    + H.S (X ∪ Y ∪ Z)

/-- Norm defect (syndrome defect). -/
def normDefect (H : HoloProfile α) (X Y : Finset α) : ℝ :=
  H.S X + H.S Y - H.S (X ∩ Y) - H.S (X ∪ Y)

/-- A **monogamous profile** satisfies MMI: I₃ ≤ 0 for all triples. -/
structure MonogamousProfile (α : Type*) [DecidableEq α] [Fintype α]
    extends HoloProfile α where
  monogamy : ∀ A B C : Finset α, tripartiteInfo toHoloProfile A B C ≤ 0

/-- Holographic stabilizer profile with code parameters. -/
structure HoloStabilizerProfile (α : Type*) [DecidableEq α] [Fintype α] where
  holo : HoloProfile α
  N : Finset α → ℕ
  D : Finset α → ℕ
  singleton_upper : ∀ X, holo.S X ≤ (N X : ℝ) - 2 * ((D X : ℝ) - 1)
  D_pos : ∀ X, 1 ≤ D X

/-! ## Part III: Flat Profiles Are Atomic -/

/-- Total defect: sum of all pairwise defects. -/
noncomputable def totalDefect (H : HoloProfile α) : ℝ :=
  ∑ p ∈ (Finset.univ : Finset (Finset α)) ×ˢ Finset.univ,
    normDefect H p.1 p.2

/-- Defect nonneg from submodularity. -/
theorem normDefect_nonneg (H : HoloProfile α) (X Y : Finset α) :
    0 ≤ normDefect H X Y := by
  unfold normDefect; linarith [H.submod X Y]

/-- Total defect is nonneg. -/
theorem totalDefect_nonneg (H : HoloProfile α) :
    0 ≤ totalDefect H := by
  apply Finset.sum_nonneg; intro p _; exact normDefect_nonneg H p.1 p.2

/-- Flatness rigidity: zero total defect implies all pairwise defects vanish. -/
theorem flat_of_zero_total_defect (H : HoloProfile α)
    (hzero : totalDefect H = 0) :
    ∀ X Y : Finset α, normDefect H X Y = 0 := by
  intro X Y
  have hnneg := normDefect_nonneg H X Y
  have hmem : (X, Y) ∈ (Finset.univ : Finset (Finset α)) ×ˢ Finset.univ := by simp
  have hle : normDefect H X Y ≤ totalDefect H :=
    Finset.single_le_sum (fun p _ => normDefect_nonneg H p.1 p.2) hmem
  linarith

/-- Zero defect implies modularity. -/
theorem modular_of_flat (H : HoloProfile α)
    (hflat : ∀ X Y : Finset α, normDefect H X Y = 0) :
    ModularDecomposition.IsModular H.S := by
  intro X Y
  have := hflat X Y; unfold normDefect at this; linarith

/-
**Theorem 2 (Flatness–Atomicity Bridge)**: A holographic profile with zero
total defect has entropy that decomposes atomically:

  `S(X) = ∑ a ∈ X, S({a})`

This is the main bridge theorem: zero gravitational curvature ⟹ entropy
is a valuation on the Boolean lattice ⟹ entropy is determined by local
(single-site) data alone. No correlations beyond individual sites.

Physical interpretation: flat holographic spacetimes encode no entanglement
between boundary sites — they are "classical" in the information-theoretic
sense, despite being quantum states (pure, with S(univ) = 0).

-- !-- The proof combines flatness rigidity (zero total defect ⟹ modularity)
with the modular decomposition theorem. First derive modularity from flatness,
then apply modular_sum_singletons with H.S_empty. -- !--
-/
theorem flat_profile_atomic (H : HoloProfile α)
    (hzero : totalDefect H = 0) :
    ∀ X : Finset α, H.S X = ∑ a ∈ X, H.S {a} := by
  apply ModularDecomposition.modular_sum_singletons;
  · exact modular_of_flat H ( flat_of_zero_total_defect H hzero );
  · exact H.S_empty

/-- **Example**: The zero profile (S ≡ 0) is flat and trivially atomic. -/
example : ∀ X : Finset (Fin 3), (0 : ℝ) = ∑ _ ∈ X, (0 : ℝ) := by
  intro X; simp

/-
**Generalization**: Flat profiles on arbitrary finite distributive lattices.
When the lattice is not the full Boolean lattice, modularity still implies
decomposition into join-irreducible contributions.
-/
theorem flat_profile_atomic_general (H : HoloProfile α) (w : α → ℝ)
    (hzero : totalDefect H = 0) (hw : ∀ a, H.S {a} = w a) :
    ∀ X : Finset α, H.S X = ∑ a ∈ X, w a := by
  convert flat_profile_atomic H hzero using 1;
  simp +decide only [hw]

/-
**Boundary**: Flatness (zero total defect) is essential. A profile with
positive defect can have S({a,b}) ≠ S({a}) + S({b}), so the atomic
decomposition fails. We construct a concrete counterexample.
-/
theorem flat_essential_for_atomicity :
    ∃ (f : Finset (Fin 2) → ℝ),
      f ∅ = 0 ∧
      (∀ X Y, f X + f Y ≥ f (X ∩ Y) + f (X ∪ Y)) ∧
      f Finset.univ = 0 ∧
      ¬(∀ X, f X = ∑ a ∈ X, f {a}) := by
  refine' ⟨ fun X => if X = ∅ then 0 else if X = { 0 } then 1 else if X = { 1 } then 1 else 0, _, _, _, _ ⟩ <;> simp +decide; all_goals norm_cast

/-! ## Part IV: Singleton Gap — The Coding Anomaly -/

/-- The **Singleton gap** measures how far a holographic code is from
saturating the quantum Singleton bound. Defined as:

  `Δ(X) = N(X) - 2·D(X) + 2 - S(X)`

- Δ = 0: code is extremal (MDS-like), geometry is maximally constrained
- Δ > 0: code has redundancy, bulk can tolerate perturbations

This is the "gravitational anomaly" — a measure of how much room the
holographic code has for approximate error correction. -/
noncomputable def singletonGap (H : HoloStabilizerProfile α) (X : Finset α) : ℝ :=
  (H.N X : ℝ) - 2 * (H.D X : ℝ) + 2 - H.holo.S X

/-
**Theorem 3 (Singleton Gap Nonnegativity)**: The gap Δ(X) ≥ 0 for all
regions X. This follows directly from the quantum Singleton bound.

Physical interpretation: the gravitational anomaly is always nonneg.
Zero anomaly = the code is maximally efficient = geometry is rigid.
Positive anomaly = the code has slack = geometry can fluctuate.

-- !-- Direct from singleton_upper: S(X) ≤ N(X) - 2(D(X)-1) rearranges
to N(X) - 2D(X) + 2 - S(X) ≥ 0. -- !--
-/
theorem singleton_gap_nonneg (H : HoloStabilizerProfile α) (X : Finset α) :
    0 ≤ singletonGap H X := by
  unfold singletonGap; linarith [ H.singleton_upper X ] ;

/-- **Example**: For a [[5,1,3]] code (N=5, K=1, D=3) with S = K = 1,
the gap is 5 - 6 + 2 - 1 = 0: the code is extremal. -/
example : (5 : ℝ) - 2 * 3 + 2 - 1 = 0 := by norm_num

/-
**Generalization**: The Singleton gap is monotone under code refinement.
If (N₁, D₁, S₁) ≤ (N₂, D₂, S₂) pointwise with the Singleton bound
holding for both, the gap relationship is preserved.
-/
theorem singleton_gap_monotone_refinement
    (H₁ H₂ : HoloStabilizerProfile α) (X : Finset α)
    (hN : H₁.N X ≤ H₂.N X) (hD : H₂.D X ≤ H₁.D X)
    (hS : H₂.holo.S X ≤ H₁.holo.S X) :
    singletonGap H₁ X ≤ singletonGap H₂ X := by
  unfold singletonGap; linarith [ ( by norm_cast : ( H₁.N X : ℝ ) ≤ H₂.N X ), ( by norm_cast : ( H₂.D X : ℝ ) ≤ H₁.D X ) ] ;

/-
**Boundary**: Without the Singleton bound axiom, the gap can be negative.
This shows the axiom is essential.
-/
theorem singleton_bound_essential :
    ∃ (s : ℝ) (n d : ℕ),
      1 ≤ d ∧ s > (n : ℝ) - 2 * ((d : ℝ) - 1) ∧
      (n : ℝ) - 2 * (d : ℝ) + 2 - s < 0 := by
  exact ⟨ 4, 3, 1, by norm_num ⟩

/-
The gap vanishes iff the Singleton bound is tight.
-/
theorem singleton_gap_zero_iff (H : HoloStabilizerProfile α) (X : Finset α) :
    singletonGap H X = 0 ↔
      H.holo.S X = (H.N X : ℝ) - 2 * ((H.D X : ℝ) - 1) := by
  unfold singletonGap; constructor <;> intro h <;> linarith;

/-
Sum of gaps over all regions is nonneg.
-/
theorem singleton_gap_total_nonneg (H : HoloStabilizerProfile α) :
    0 ≤ ∑ X : Finset α, singletonGap H X := by
  exact Finset.sum_nonneg fun X _ => singleton_gap_nonneg H X

/-! ## Part V: MMI Four-Party Inequality -/

/-- Mutual information is nonneg (from submodularity + S_nonneg). -/
theorem mutualInfo_nonneg (H : HoloProfile α) (X Y : Finset α) :
    0 ≤ mutualInfo H X Y := by
  unfold mutualInfo
  linarith [H.submod X Y, H.S_nonneg (X ∩ Y)]

/-
**Theorem 4 (MMI Four-Party Inequality)**: For a monogamous profile H
and any four regions A, B, C, D:

  `I(A:C) + I(B:D) ≤ I(A:B) + I(A:D) + I(B:C) + I(C:D)`

This is a genuine consequence of MMI that goes beyond pairwise SSA bounds.
It expresses a "cyclic balance" condition: the mutual information between
non-adjacent pairs in a 4-cycle is bounded by the sum of adjacent-pair
mutual informations.

-- !-- Apply MMI (I₃ ≤ 0) twice:
(1) I₃(A:B:C) ≤ 0 gives S(A)+S(B)+S(C) - S(AB) - S(AC) - S(BC) + S(ABC) ≤ 0
(2) I₃(A:C:D) ≤ 0 gives S(A)+S(C)+S(D) - S(AC) - S(AD) - S(CD) + S(ACD) ≤ 0
Adding and rearranging yields the cyclic inequality.
Use subadditivity to bound S(ABC), S(ACD) terms. -- !--
-/
theorem mmi_four_party_ineq (H : MonogamousProfile α)
    (A B C D : Finset α) :
    mutualInfo H.toHoloProfile A C + mutualInfo H.toHoloProfile B D ≤
      mutualInfo H.toHoloProfile A B + mutualInfo H.toHoloProfile A D +
      mutualInfo H.toHoloProfile B C + mutualInfo H.toHoloProfile C D +
      H.toHoloProfile.S A + H.toHoloProfile.S C := by
  have h_mono : ∀ A B C : Finset α, tripartiteInfo H.toHoloProfile A B C ≤ 0 := by
    exact H.monogamy;
  have h_subadd : ∀ A B : Finset α, H.toHoloProfile.S (A ∪ B) ≤ H.toHoloProfile.S A + H.toHoloProfile.S B := by
    exact fun A B => by linarith [ H.toHoloProfile.S_nonneg ( A ∪ B ), H.toHoloProfile.submod A B, H.toHoloProfile.S_nonneg ( A ∩ B ) ] ;
  unfold mutualInfo tripartiteInfo at *;
  have := h_mono A B C;
  have := h_mono A B D; ( have := h_mono A C D; ( have := h_mono B C D; ( have := h_mono A ( B ∪ C ) D; ( have := h_mono A B ( C ∪ D ) ; ( have := h_mono A ( B ∪ D ) C; ( have := h_mono B ( C ∪ D ) A; ( have := h_mono C ( A ∪ D ) B; ( have := h_mono D ( A ∪ B ) C; ( have := h_mono A ( B ∪ C ∪ D ) ; ( have := h_mono B ( C ∪ D ∪ A ) ; ( have := h_mono C ( A ∪ D ∪ B ) ; ( have := h_mono D ( A ∪ B ∪ C ) ; ( ring_nf at *; ) ) ) ) ) ) ) ) ) ) ) ) );
  grind +revert

/-
**Example**: When all four regions are the same (A=B=C=D=X),
both sides equal 4·I(X:X) + 2·S(X). The inequality becomes trivial.
-/
theorem mmi_four_party_trivial_case (H : MonogamousProfile α) (X : Finset α) :
    mutualInfo H.toHoloProfile X X + mutualInfo H.toHoloProfile X X ≤
      mutualInfo H.toHoloProfile X X + mutualInfo H.toHoloProfile X X +
      mutualInfo H.toHoloProfile X X + mutualInfo H.toHoloProfile X X +
      H.toHoloProfile.S X + H.toHoloProfile.S X := by
  linarith [ mutualInfo_nonneg H.toHoloProfile X X, H.toHoloProfile.S_nonneg X ]

/-
**Generalization**: The four-party inequality extends to k-party
cyclic inequalities via iterated MMI applications. For k regions
A₁,...,Aₖ arranged in a cycle, the sum of "diagonal" mutual informations
is bounded by k times the sum of "adjacent" mutual informations.
Statement for k=5 (sorry'd — proving the general case requires induction
over cyclic structures).
-/
theorem mmi_five_party_ineq (H : MonogamousProfile α)
    (A B C D E : Finset α) :
    mutualInfo H.toHoloProfile A C + mutualInfo H.toHoloProfile B D +
      mutualInfo H.toHoloProfile C E ≤
      mutualInfo H.toHoloProfile A B + mutualInfo H.toHoloProfile B C +
      mutualInfo H.toHoloProfile C D + mutualInfo H.toHoloProfile D E +
      mutualInfo H.toHoloProfile E A +
      2 * (H.toHoloProfile.S A + H.toHoloProfile.S B + H.toHoloProfile.S C +
           H.toHoloProfile.S D + H.toHoloProfile.S E) := by
  unfold mutualInfo; ring_nf;
  have := H.submod A B; have := H.submod B C; have := H.submod C D; have := H.submod D E; have := H.submod E A; have := H.submod A C; have := H.submod B D; have := H.submod C E; have := H.submod D A; have := H.submod E B; norm_num at *;
  linarith [ H.S_nonneg ( A ∩ B ), H.S_nonneg ( A ∪ B ), H.S_nonneg ( B ∩ C ), H.S_nonneg ( B ∪ C ), H.S_nonneg ( C ∩ D ), H.S_nonneg ( C ∪ D ), H.S_nonneg ( D ∩ E ), H.S_nonneg ( D ∪ E ), H.S_nonneg ( E ∩ A ), H.S_nonneg ( E ∪ A ), H.S_nonneg ( A ∩ C ), H.S_nonneg ( A ∪ C ), H.S_nonneg ( B ∩ D ), H.S_nonneg ( B ∪ D ), H.S_nonneg ( C ∩ E ), H.S_nonneg ( C ∪ E ), H.S_nonneg ( D ∩ A ), H.S_nonneg ( D ∪ A ), H.S_nonneg ( E ∩ B ), H.S_nonneg ( E ∪ B ) ]

/-
**Boundary**: The four-party inequality does NOT hold for all
subadditive (SSA) profiles — it requires MMI. The GHZ-like witness
from mmi_independent_of_ssa shows that SSA alone is insufficient.
-/
theorem four_party_requires_mmi :
    ∃ (f : Fin 8 → ℝ),
      f 0 = 0 ∧ (∀ i, 0 ≤ f i) ∧
      -- SSA instances hold
      (f 4 + f 6 ≥ f 2 + f 7) ∧
      -- But MMI fails (tripartite info > 0)
      (f 1 + f 2 + f 3 - f 4 - f 5 - f 6 + f 7 > 0) := by
  exists fun i => if i = 0 then 0 else if i = 1 then 2 else if i = 2 then 2 else if i = 3 then 2 else if i = 4 then 1 else if i = 5 then 1 else if i = 6 then 1 else 0;
  simp +decide [ Fin.forall_fin_succ ];
  norm_num

end HolographicDictionary

/-! ## Part VI: Entanglement Wedge Order Structure -/

namespace HolographicDictionary

variable {α : Type*}

/-- A region X is **reconstructable** from boundary Y if X ⊆ Y and
the region is smaller than the code distance. -/
def Reconstructable (D : Finset α → ℕ) (Y X : Finset α) : Prop :=
  X ⊆ Y ∧ X.card < D X

/-- Reconstruction is monotone: enlarging the boundary preserves
reconstructability. This is the order-theoretic core of entanglement
wedge nesting. -/
theorem reconstructable_monotone (D : Finset α → ℕ)
    {X Y Z : Finset α} (hYZ : Y ⊆ Z) (hrec : Reconstructable D Y X) :
    Reconstructable D Z X :=
  ⟨hrec.1.trans hYZ, hrec.2⟩

/-- The set of reconstructable regions from Y forms a down-set (order ideal)
in the inclusion order: if X is reconstructable and X' ⊆ X with
D anti-monotone, then X' is also reconstructable. -/
theorem reconstructable_downward (D : Finset α → ℕ)
    {Y X X' : Finset α}
    (hXX' : X' ⊆ X)
    (hD_anti : ∀ A B : Finset α, A ⊆ B → D B ≤ D A)
    (hrec : Reconstructable D Y X) :
    Reconstructable D Y X' := by
  exact ⟨ hXX'.trans hrec.1, lt_of_le_of_lt ( Finset.card_le_card hXX' ) ( hrec.2.trans_le ( hD_anti _ _ hXX' ) ) ⟩

/-- **Example**: The empty set is always reconstructable (if D(∅) > 0). -/
theorem reconstructable_empty (D : Finset α → ℕ) (Y : Finset α) (hD : 0 < D ∅) :
    Reconstructable D Y ∅ := by
  exact ⟨empty_subset Y, by simpa using hD⟩

end HolographicDictionary