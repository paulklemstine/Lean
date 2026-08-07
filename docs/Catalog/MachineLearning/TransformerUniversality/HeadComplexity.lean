import Mathlib

/-!
# Exact head complexity of the attention lookup architecture

The catalog file `Catalog/MachineLearning/TransformerArchitecture.lean` realizes an arbitrary
function on a finite domain using **one head per possible input**, and explicitly flags the
resulting head count as a defect.  This file settles the question exactly.

A *value-sum architecture with `H` heads* computes
`model x = ∑ h : Fin H, c h x • v h`,
where the scalar gates `c h : X → ℝ` may be arbitrary (this is more general than attention:
softmax gates, bilinear gates, or any nonlinear gate are all special cases) and the `H` value
vectors `v h` are input-independent.  The catalog architecture is the special case
`c a x = ⟦x = a⟧`, `v a = f a`, with `H = |X|`.

Main results:

* `Representable.finrank_le` — a lower bound: any `H`-head model of `f` forces
  `finrank (span (range f)) ≤ H`;
* `representable_finrank` — a matching constructive upper bound: `finrank (span (range f))`
  heads always suffice;
* `minHeads_eq_finrank` — hence the minimal head count is *exactly* the rank of the value
  table, an exact resource characterization;
* `minHeads_eq_card_of_linearIndependent` — the catalog's `|X|` heads are necessary precisely
  when the value tables are linearly independent, and
* `minHeads_le_one_of_rank_one` — a family of tasks where a single head replaces `|X|` of
  them, so the exponential head count of exact finite lookup is an artifact of worst-case
  rank, not of the architecture.
-/

open scoped BigOperators
open Submodule Set Module

namespace HeadComplexity

variable {X Y : Type*} [Fintype X]

/-- A value-sum architecture with `H` heads: input-dependent scalar gates times
input-independent value vectors. -/
def Representable (f : X → Y → ℝ) (H : ℕ) : Prop :=
  ∃ (c : Fin H → X → ℝ) (v : Fin H → (Y → ℝ)), ∀ x, f x = ∑ h, c h x • v h

/-- The rank of the value table: the dimension of the span of all outputs. -/
noncomputable def rankOf (f : X → Y → ℝ) : ℕ := finrank ℝ (span ℝ (Set.range f))

instance finiteSpanRange (f : X → Y → ℝ) : Module.Finite ℝ (span ℝ (Set.range f)) :=
  Module.Finite.span_of_finite ℝ (Set.finite_range f)

omit [Fintype X] in
/-- **Head lower bound.**  Any `H`-head value-sum model of `f` has all its outputs inside an
`H`-dimensional subspace, so the rank of the value table is at most `H`. -/
theorem Representable.finrank_le {f : X → Y → ℝ} {H : ℕ} (hf : Representable f H) :
    rankOf f ≤ H := by
  classical
  obtain ⟨c, v, hcv⟩ := hf
  have hsub : span ℝ (Set.range f) ≤ span ℝ (Set.range v) := by
    rw [Submodule.span_le]
    rintro _ ⟨x, rfl⟩
    rw [hcv x]
    exact Submodule.sum_mem _ fun h _ =>
      Submodule.smul_mem _ _ (Submodule.subset_span ⟨h, rfl⟩)
  have hfin : Module.Finite ℝ (span ℝ (Set.range v)) :=
    Module.Finite.span_of_finite ℝ (Set.finite_range v)
  have hmono : finrank ℝ (span ℝ (Set.range f)) ≤ finrank ℝ (span ℝ (Set.range v)) :=
    Submodule.finrank_mono hsub
  have hcard : finrank ℝ (span ℝ (Set.range v)) ≤ H := by
    have h1 := finrank_span_le_card (R := ℝ) (Set.range v)
    have h2 : (Set.range v).toFinset.card ≤ H := by
      rw [Set.toFinset_range]
      exact le_trans Finset.card_image_le (by simp)
    exact le_trans h1 h2
  exact le_trans hmono hcard

/-- **Matching constructive upper bound.**  A basis of the span of the outputs yields a
value-sum model with exactly `rankOf f` heads. -/
theorem representable_finrank (f : X → Y → ℝ) : Representable f (rankOf f) := by
  classical
  set W : Submodule ℝ (Y → ℝ) := span ℝ (Set.range f) with hW
  set b : Basis (Fin (finrank ℝ W)) ℝ W := Module.finBasis ℝ W with hb
  set v : Fin (rankOf f) → (Y → ℝ) := fun i => (b i : Y → ℝ) with hv
  have hspan : span ℝ (Set.range v) = W := by
    have h : Set.range v = W.subtype '' (Set.range b) := by
      rw [← Set.range_comp]; rfl
    rw [hv] at h ⊢
    rw [h, ← Submodule.map_span, b.span_eq, Submodule.map_top, Submodule.range_subtype]
  have hmem : ∀ x, ∃ c : Fin (rankOf f) → ℝ, ∑ i, c i • v i = f x := by
    intro x
    have hx : f x ∈ span ℝ (Set.range v) := by
      rw [hspan, hW]
      exact Submodule.subset_span ⟨x, rfl⟩
    exact (mem_span_range_iff_exists_fun ℝ).mp hx
  choose c hc using hmem
  exact ⟨fun i x => c x i, v, fun x => (hc x).symm⟩

/-- The minimal number of heads of a value-sum architecture computing `f`. -/
noncomputable def minHeads (f : X → Y → ℝ) : ℕ := sInf {H | Representable f H}

/-- **Exact head complexity.**  The minimal number of heads equals the rank of the value
table.  Both a lower bound and a matching construction are contained in this statement. -/
theorem minHeads_eq_finrank (f : X → Y → ℝ) : minHeads f = rankOf f := by
  have hmem : rankOf f ∈ {H | Representable f H} := representable_finrank f
  have hne : {H | Representable f H}.Nonempty := ⟨rankOf f, hmem⟩
  refine le_antisymm (Nat.sInf_le hmem) ?_
  exact (Nat.sInf_mem hne : Representable f (minHeads f)).finrank_le

/-- **One head per input is necessary exactly in the linearly independent case.**  This is a
sharp lower bound for the catalog construction. -/
theorem minHeads_eq_card_of_linearIndependent (f : X → Y → ℝ)
    (hf : LinearIndependent ℝ f) : minHeads f = Fintype.card X := by
  rw [minHeads_eq_finrank, rankOf, finrank_span_eq_card hf]

omit [Fintype X] in
/-- **Exponentially many heads are not always needed.**  Whenever all value tables are
multiples of one fixed vector, a single head suffices, however large the domain is. -/
theorem minHeads_le_one_of_rank_one (g : Y → ℝ) (a : X → ℝ) :
    minHeads (fun x => a x • g) ≤ 1 := by
  have hrep : Representable (fun x => a x • g) 1 :=
    ⟨fun _ => a, fun _ => g, fun x => by simp⟩
  exact Nat.sInf_le hrep

/-- The catalog's exact lookup construction is itself a value-sum model with `|X|` heads,
so the head complexity never exceeds the size of the domain. -/
theorem minHeads_le_card [DecidableEq X] (f : X → Y → ℝ) :
    minHeads f ≤ Fintype.card X := by
  classical
  have hrep : Representable f (Fintype.card X) := by
    obtain ⟨e⟩ : Nonempty (Fin (Fintype.card X) ≃ X) := ⟨(Fintype.equivFin X).symm⟩
    refine ⟨fun h x => if x = e h then 1 else 0, fun h => f (e h), fun x => ?_⟩
    rw [Finset.sum_eq_single (e.symm x)]
    · simp
    · intro h _ hne
      have : x ≠ e h := by
        intro hx
        exact hne (by rw [hx, Equiv.symm_apply_apply])
      simp [this]
    · intro hx
      exact absurd (Finset.mem_univ _) hx
  exact Nat.sInf_le hrep

/-- **The exact-lookup architecture is rank-optimal only up to rank.**  Combining the two
bounds: head complexity is squeezed between the rank and the domain size, and the gap is
exactly the rank deficiency of the value table. -/
theorem rank_le_minHeads_le_card [DecidableEq X] (f : X → Y → ℝ) :
    rankOf f ≤ minHeads f ∧ minHeads f ≤ Fintype.card X :=
  ⟨le_of_eq (minHeads_eq_finrank f).symm, minHeads_le_card f⟩

end HeadComplexity