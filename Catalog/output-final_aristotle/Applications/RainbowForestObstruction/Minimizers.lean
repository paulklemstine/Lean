/-
# The Rainbow Forest Inequality and the structure of minimal obstructions

An edge–coloured graph admits a *total rainbow forest* of size `t` exactly when the
graphic matroid `M₁` and the "one edge per colour" partition matroid `M₂` share a
common independent set of size `t`.  Matroid intersection duality says that no such
common independent set exists precisely when some subset `A ⊆ E` witnesses the
**Rainbow Forest Inequality failure**
`r₁(A) + r₂(E \ A) < t`,
where `rᵢ` is the rank function of `Mᵢ`.

The *original conjecture* of this research direction claimed that for a minimal
obstruction the witnessing subset `A` is **unique**, i.e. the failure is strict for no
other subset.  We investigate this claim abstractly, at the level of matroid rank
functions.  The main outcomes:

* `rainbow_forest_inequality`  — the weak-duality inequality itself (always true):
  every common independent set `I` has `|I| ≤ r₁(A) + r₂(E \ A)`.
* `obstruction_blocks`         — a single failing subset already forbids all rainbow
  forests of size `t`.
* `g_submodular`               — the objective `A ↦ r₁(A)+r₂(E\A)` is submodular.
* `minimizer_inf`, `minimizer_sup` — the minimizers of that objective are closed under
  intersection and union: they form a lattice.
* `exists_least_minimizer`, `exists_greatest_minimizer` — hence a *unique smallest*
  and *unique largest* witnessing set exist (the correct, provable version of the
  conjecture).
* `uniqueness_fails`, `minimizer_not_unique` — an explicit two–element counterexample
  (both matroids equal to `U₁,₂`) showing the *original* uniqueness claim is **false**:
  there genuinely are two distinct minimizing subsets.

Everything is developed from the four matroid rank axioms, with no external
matroid library.
-/
import Mathlib

open Finset

namespace RainbowForestObstruction

variable {α : Type*} [DecidableEq α]

/-- The four rank axioms of a (finite) matroid, stated for a rank function defined on
all finsets of `α`.  Elements outside the ground set play the role of loops. -/
structure IsMatroidRank (r : Finset α → ℕ) : Prop where
  empty : r ∅ = 0
  mono : ∀ ⦃X Y : Finset α⦄, X ⊆ Y → r X ≤ r Y
  unit : ∀ (X : Finset α) (e : α), r (insert e X) ≤ r X + 1
  submod : ∀ X Y : Finset α, r (X ∪ Y) + r (X ∩ Y) ≤ r X + r Y

/-
Rank never exceeds cardinality (a consequence of `empty` and `unit`).
-/
lemma IsMatroidRank.card_bound {r : Finset α → ℕ} (h : IsMatroidRank r) (X : Finset α) :
    r X ≤ X.card := by
  induction' X using Finset.induction with x X hx ih;
  · exact h.empty.le;
  · simpa [ Finset.card_insert_of_notMem hx ] using le_trans ( h.unit _ _ ) ( Nat.add_le_add_right ih 1 )

/-- A set is independent when its rank equals its cardinality. -/
def Indep (r : Finset α → ℕ) (I : Finset α) : Prop := r I = I.card

/-
A subset of an independent set is independent.
-/
lemma IsMatroidRank.indep_subset {r : Finset α → ℕ} (h : IsMatroidRank r)
    {I J : Finset α} (hI : Indep r I) (hJI : J ⊆ I) : Indep r J := by
  obtain ⟨hI_empty, hI_mono, hI_unit, hI_submod⟩ := h;
  have h_card_le : ∀ X Y, X ⊆ Y → r Y ≤ r X + (Y \ X).card := by
    intro X Y hXY
    induction' h : (Y \ X).card with k hk generalizing X Y;
    · simp_all +decide [ Finset.sdiff_eq_empty_iff_subset ];
    · obtain ⟨ e, he ⟩ := Finset.card_pos.mp ( by linarith );
      specialize hk ( Insert.insert e X ) Y ; simp_all +decide [ Finset.subset_iff ];
      grind;
  exact le_antisymm ( IsMatroidRank.card_bound { empty := hI_empty, mono := hI_mono, unit := hI_unit, submod := hI_submod } J ) ( by have := h_card_le J I hJI; have := Finset.card_sdiff_add_card_eq_card hJI; linarith [ hI.symm ] )

/-- The matroid–intersection objective: `g A = r₁ A + r₂ (E \ A)`. -/
def g (E : Finset α) (r₁ r₂ : Finset α → ℕ) (A : Finset α) : ℕ := r₁ A + r₂ (E \ A)

/-
**Rainbow Forest Inequality (weak duality).**  Any common independent set `I ⊆ E`
of the two matroids has size at most `r₁(A) + r₂(E \ A)` for every subset `A`.
(The bound needs no hypothesis on `A`.)
-/
theorem rainbow_forest_inequality {r₁ r₂ : Finset α → ℕ}
    (h₁ : IsMatroidRank r₁) (h₂ : IsMatroidRank r₂)
    {E I : Finset α} (hIE : I ⊆ E) (hI1 : Indep r₁ I) (hI2 : Indep r₂ I)
    {A : Finset α} :
    I.card ≤ g E r₁ r₂ A := by
  have h_bound : r₁ (I ∩ A) + r₂ (I \ A) ≤ r₁ A + r₂ (E \ A) := by
    exact add_le_add ( h₁.mono ( Finset.inter_subset_right ) ) ( h₂.mono ( Finset.sdiff_subset_sdiff hIE ( Finset.Subset.refl _ ) ) );
  convert h_bound using 1;
  rw [ h₁.indep_subset hI1 ( Finset.inter_subset_left ), h₂.indep_subset hI2 ( Finset.sdiff_subset ) ];
  rw [ Finset.card_inter_add_card_sdiff ]

/-
A single subset failing the inequality already blocks every rainbow forest of size
`t`: there is no common independent set `I ⊆ E` with `t ≤ |I|`.
-/
theorem obstruction_blocks {r₁ r₂ : Finset α → ℕ}
    (h₁ : IsMatroidRank r₁) (h₂ : IsMatroidRank r₂)
    {E : Finset α} {t : ℕ} {A : Finset α} (hlt : g E r₁ r₂ A < t) :
    ¬ ∃ I : Finset α, I ⊆ E ∧ Indep r₁ I ∧ Indep r₂ I ∧ t ≤ I.card := by
  exact fun h => hlt.not_ge ( rainbow_forest_inequality h₁ h₂ h.choose_spec.1 h.choose_spec.2.1 h.choose_spec.2.2.1 |> le_trans ( mod_cast h.choose_spec.2.2.2 ) )

/-
The objective `g` is submodular on subsets of the ground set.
-/
theorem g_submodular {r₁ r₂ : Finset α → ℕ}
    (h₁ : IsMatroidRank r₁) (h₂ : IsMatroidRank r₂)
    {E A B : Finset α} :
    g E r₁ r₂ (A ∪ B) + g E r₁ r₂ (A ∩ B) ≤ g E r₁ r₂ A + g E r₁ r₂ B := by
  have h_submod_1 : r₁ (A ∪ B) + r₁ (A ∩ B) ≤ r₁ A + r₁ B := by
    exact h₁.submod A B
  have h_submod_2 : r₂ ((E \ A) ∪ (E \ B)) + r₂ ((E \ A) ∩ (E \ B)) ≤ r₂ (E \ A) + r₂ (E \ B) := by
    exact h₂.submod _ _;
  unfold g;
  rw [ show E \ ( A ∪ B ) = ( E \ A ) ∩ ( E \ B ) by ext x; simp +decide [ Finset.mem_sdiff, Finset.mem_union, Finset.mem_inter ] ; tauto, show E \ ( A ∩ B ) = ( E \ A ) ∪ ( E \ B ) by ext x; simp +decide [ Finset.mem_sdiff, Finset.mem_union, Finset.mem_inter ] ; tauto ] ; linarith

/-- `A` minimizes the objective `g` over all subsets of `E`. -/
def IsMinimizer (E : Finset α) (r₁ r₂ : Finset α → ℕ) (A : Finset α) : Prop :=
  A ⊆ E ∧ ∀ B : Finset α, B ⊆ E → g E r₁ r₂ A ≤ g E r₁ r₂ B

/-
A minimizer always exists (the objective attains a minimum over the finite
powerset of `E`).
-/
theorem exists_minimizer {r₁ r₂ : Finset α → ℕ} (E : Finset α) :
    ∃ A, IsMinimizer E r₁ r₂ A := by
  have h_exists_min : ∃ A ∈ Finset.powerset E, ∀ B ∈ Finset.powerset E, g E r₁ r₂ A ≤ g E r₁ r₂ B := by
    exact Finset.exists_min_image _ _ ⟨ ∅, Finset.mem_powerset.2 <| Finset.empty_subset _ ⟩;
  exact ⟨ h_exists_min.choose, Finset.mem_powerset.mp h_exists_min.choose_spec.1, fun B hB => h_exists_min.choose_spec.2 B ( Finset.mem_powerset.mpr hB ) ⟩

/-
The minimizers are closed under intersection.
-/
theorem minimizer_inf {r₁ r₂ : Finset α → ℕ}
    (h₁ : IsMatroidRank r₁) (h₂ : IsMatroidRank r₂)
    {E A B : Finset α} (hA : IsMinimizer E r₁ r₂ A) (hB : IsMinimizer E r₁ r₂ B) :
    IsMinimizer E r₁ r₂ (A ∩ B) := by
  -- Let m := g E r₁ r₂ A. Since A is a minimizer over E, ∀ C ⊆ E, g C ≥ g A = m.
  set m := g E r₁ r₂ A
  have hm : ∀ C, C ⊆ E → g E r₁ r₂ C ≥ m := by
    exact hA.2;
  -- By `g_submodular h₁ h₂ hA.1 hB.1`: g (A∪B) + g (A∩B) ≤ g A + g B.
  have h_submod : g E r₁ r₂ (A ∪ B) + g E r₁ r₂ (A ∩ B) ≤ g E r₁ r₂ A + g E r₁ r₂ B := by
    exact g_submodular h₁ h₂;
  refine' ⟨ Finset.inter_subset_left.trans hA.1, fun C hC => _ ⟩;
  linarith [ hm ( A ∪ B ) ( Finset.union_subset hA.1 hB.1 ), hm ( A ∩ B ) ( Finset.inter_subset_left.trans hA.1 ), hm C hC, hA.2 B hB.1, hB.2 A hA.1 ]

/-
The minimizers are closed under union.
-/
theorem minimizer_sup {r₁ r₂ : Finset α → ℕ}
    (h₁ : IsMatroidRank r₁) (h₂ : IsMatroidRank r₂)
    {E A B : Finset α} (hA : IsMinimizer E r₁ r₂ A) (hB : IsMinimizer E r₁ r₂ B) :
    IsMinimizer E r₁ r₂ (A ∪ B) := by
  refine' ⟨ Finset.union_subset hA.1 hB.1, fun C hC => _ ⟩;
  -- By g_submodular h₁ h₂ hAE hBE: g(A∪B) + g(A∩B) ≤ g A + g B.
  have h_submod : g E r₁ r₂ (A ∪ B) + g E r₁ r₂ (A ∩ B) ≤ g E r₁ r₂ A + g E r₁ r₂ B := by
    exact g_submodular h₁ h₂;
  linarith [ hA.2 C hC, hB.2 C hC, hA.2 ( A ∩ B ) ( Finset.inter_subset_left.trans hA.1 ), hB.2 ( A ∩ B ) ( Finset.inter_subset_right.trans hB.1 ) ]

/-
**Corrected conjecture (least witness).**  There is a *unique smallest* minimizing
subset: a minimizer contained in every other minimizer.
-/
theorem exists_least_minimizer {r₁ r₂ : Finset α → ℕ}
    (h₁ : IsMatroidRank r₁) (h₂ : IsMatroidRank r₂) (E : Finset α) :
    ∃ A₀, IsMinimizer E r₁ r₂ A₀ ∧ ∀ A, IsMinimizer E r₁ r₂ A → A₀ ⊆ A := by
  -- By `exists_minimizer`, there exists a minimizer $A'$.
  obtain ⟨A', hA'⟩ : ∃ A' : Finset α, IsMinimizer E r₁ r₂ A' := exists_minimizer E;
  -- Since S is finite and nonempty, there exists a minimal element A₀ in S.
  obtain ⟨A₀, hA₀S, hA₀min⟩ : ∃ A₀ ∈ {A | IsMinimizer E r₁ r₂ A}, ∀ A ∈ {A | IsMinimizer E r₁ r₂ A}, A₀.card ≤ A.card := by
    apply Set.exists_min_image;
    · exact Set.finite_iff_bddAbove.mpr ⟨ E, fun A hA => hA.1 ⟩;
    · exact ⟨ A', hA' ⟩;
  refine' ⟨ A₀, hA₀S, fun A hA => _ ⟩;
  have hA₀A : IsMinimizer E r₁ r₂ (A₀ ∩ A) := by
    exact minimizer_inf h₁ h₂ hA₀S hA;
  have := hA₀min _ hA₀A;
  exact Finset.eq_of_subset_of_card_le ( Finset.inter_subset_left : A₀ ∩ A ⊆ A₀ ) ( by linarith ) ▸ Finset.inter_subset_right

/-
**Corrected conjecture (greatest witness).**  There is a *unique largest*
minimizing subset: a minimizer containing every other minimizer.
-/
theorem exists_greatest_minimizer {r₁ r₂ : Finset α → ℕ}
    (h₁ : IsMatroidRank r₁) (h₂ : IsMatroidRank r₂) (E : Finset α) :
    ∃ A₁, IsMinimizer E r₁ r₂ A₁ ∧ ∀ A, IsMinimizer E r₁ r₂ A → A ⊆ A₁ := by
  have h_exists_minimizer : ∃ (A₀ : Finset α), IsMinimizer E r₁ r₂ A₀ := exists_minimizer E
  obtain ⟨A₀, hA₀⟩ : ∃ (A₀ : Finset α), IsMinimizer E r₁ r₂ A₀ ∧ ∀ (A : Finset α), IsMinimizer E r₁ r₂ A → A.card ≤ A₀.card := by
    apply_rules [ Set.exists_max_image ];
    exact Set.finite_iff_bddAbove.mpr ⟨ E, fun A hA => hA.1 ⟩;
  refine' ⟨ A₀, hA₀.1, fun A hA => _ ⟩;
  have := hA₀.2 ( A ∪ A₀ ) ( minimizer_sup h₁ h₂ hA hA₀.1 );
  contrapose! this;
  exact Finset.card_lt_card ( Finset.ssubset_iff_subset_ne.mpr ⟨ Finset.subset_union_right, fun h => this <| h.symm ▸ Finset.subset_union_left ⟩ )

/-! ## A concrete counterexample refuting the uniqueness conjecture

We use the rank function of the uniform matroid `U₁,₂` (indicator of non-emptiness),
which is a genuine matroid, on the ground set `E = {0,1} ⊆ ℕ`, for *both* colour classes.
Then `g ∅ = g {0,1} = 1` while `g {0} = g {1} = 2`, so the minimum value `1` is
attained by two distinct subsets. -/

/-- Rank function of the uniform matroid `U₁,ₙ`: `0` on `∅`, `1` otherwise. -/
def indicatorRank (A : Finset α) : ℕ := if A = ∅ then 0 else 1

lemma indicatorRank_isMatroid : IsMatroidRank (indicatorRank (α := α)) := by
  refine' { .. };
  · exact if_pos rfl;
  · unfold indicatorRank;
    grind;
  · unfold indicatorRank; aesop;
  · unfold indicatorRank; aesop;

/-
**Disproof of the uniqueness conjecture.**  There is an obstruction (a subset with
`g A < t`) admitting two *distinct* subsets both strictly failing the Rainbow Forest
Inequality — so the witnessing set is not unique.
-/
theorem uniqueness_fails :
    ∃ (E : Finset ℕ) (r₁ r₂ : Finset ℕ → ℕ) (t : ℕ) (A B : Finset ℕ),
      IsMatroidRank r₁ ∧ IsMatroidRank r₂ ∧
      A ⊆ E ∧ B ⊆ E ∧ A ≠ B ∧
      g E r₁ r₂ A < t ∧ g E r₁ r₂ B < t := by
  -- Let's choose the ground set `E = {0, 1}`. We'll use the indicatorRank function for both fateRealisers.
  use {0, 1}, indicatorRank (α := ℕ), indicatorRank (α := ℕ), 2, ∅, {0, 1};
  simp +decide;
  apply indicatorRank_isMatroid

/-
**Disproof, sharpened.**  The two failing subsets are in fact both *minimizers* of
the objective, so uniqueness fails even at the exact minimum value.
-/
theorem minimizer_not_unique :
    ∃ (E : Finset ℕ) (r₁ r₂ : Finset ℕ → ℕ) (A B : Finset ℕ),
      IsMatroidRank r₁ ∧ IsMatroidRank r₂ ∧
      IsMinimizer E r₁ r₂ A ∧ IsMinimizer E r₁ r₂ B ∧ A ≠ B := by
  use { 0, 1 };
  use indicatorRank, indicatorRank, ∅, {0, 1};
  refine' ⟨ indicatorRank_isMatroid, indicatorRank_isMatroid, _, _, _ ⟩ <;> simp +decide [ IsMinimizer ]

end RainbowForestObstruction