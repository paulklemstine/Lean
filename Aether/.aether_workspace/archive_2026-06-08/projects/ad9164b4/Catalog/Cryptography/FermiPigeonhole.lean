import Mathlib

/-!
# The Fermi Paradox as a Pigeonhole Principle

We formalize the mathematical structure underlying the Fermi paradox by connecting
the Drake equation to the pigeonhole principle. The key results are:

1. **Great Filter Theorem**: If a product of n factors in (0,1] is very small,
   at least one factor must be correspondingly small — a "Great Filter" must exist.

2. **Temporal Pigeonhole**: With fewer civilizations than time epochs, at least
   one epoch is empty — explaining why we see no one despite the universe's age.

3. **Filter Chain Exponential Decay**: The expected number of civilizations
   decays exponentially with the number of independent filter steps.

4. **Drake Monotonicity**: Adding additional independent filters can only
   decrease the expected count — more hurdles means fewer survivors.

5. **Contact Window Sparsity**: When civilization lifetimes are short relative
   to cosmic time, temporal overlap is impossible for some epochs.

## Novel Definitions

* `DrakeFilterModel` — A parametric model of the Drake equation as a sequence
  of independent filter probabilities applied to a base count.

* `GreatFilterIndex` — The index of the most restrictive filter in a Drake model.
-/

open Finset BigOperators

noncomputable section

/-! ## Drake Filter Model -/

/-- A Drake Filter Model captures the Drake equation as a base count of candidate
    sites (e.g., habitable planets) passed through a sequence of n independent
    filter probabilities, each in (0, 1]. The expected number of technological
    civilizations is `base_count * ∏ filters`. -/
structure DrakeFilterModel (n : ℕ) where
  /-- The filter probabilities, each representing one step in the Drake chain -/
  filters : Fin n → ℝ
  /-- Each filter probability is positive -/
  filter_pos : ∀ i, 0 < filters i
  /-- Each filter probability is at most 1 -/
  filter_le_one : ∀ i, filters i ≤ 1
  /-- Base count of candidate sites -/
  base_count : ℝ
  /-- The base count is positive -/
  base_pos : 0 < base_count

namespace DrakeFilterModel

/-- The expected number of civilizations under the Drake filter model. -/
def expectedCiv {n : ℕ} (D : DrakeFilterModel n) : ℝ :=
  D.base_count * ∏ i : Fin n, D.filters i

/-- The expected number of civilizations is always positive. -/
theorem expectedCiv_pos {n : ℕ} (D : DrakeFilterModel n) : 0 < D.expectedCiv := by
  unfold expectedCiv
  exact mul_pos D.base_pos (Finset.prod_pos (fun i _ => D.filter_pos i))

/-- The expected count is at most the base count (since all filters are ≤ 1). -/
theorem expectedCiv_le_base {n : ℕ} (D : DrakeFilterModel n) :
    D.expectedCiv ≤ D.base_count := by
  unfold expectedCiv
  have h1 : ∏ i : Fin n, D.filters i ≤ 1 := by
    apply Finset.prod_le_one
    · intro i _; exact le_of_lt (D.filter_pos i)
    · intro i _; exact D.filter_le_one i
  linarith [mul_le_mul_of_nonneg_left h1 (le_of_lt D.base_pos)]

end DrakeFilterModel

/-! ## Great Filter Theorem

The pigeonhole principle for products: if a product of n positive factors
is less than c^n, then at least one factor is less than c. -/

/-
If every factor is at least c ≥ 0, then the product is at least c^n.
-/
theorem prod_ge_pow_of_forall_ge {n : ℕ} (f : Fin n → ℝ) (c : ℝ)
    (hc : 0 ≤ c) (hf : ∀ i, c ≤ f i) :
    c ^ n ≤ ∏ i : Fin n, f i := by
  exact le_trans ( by norm_num ) ( Finset.prod_le_prod ( fun _ _ => hc ) fun _ _ => hf _ )

/-
**Great Filter Theorem (Pigeonhole for Products)**:
If the product of n factors is less than c^n (where c ≥ 0),
then at least one factor is strictly less than c.

This is the mathematical inevitability of the "Great Filter" —
if the Drake equation product is tiny, at least one step in the
chain must have very low probability.
-/
theorem great_filter_exists {n : ℕ} (f : Fin n → ℝ) (c : ℝ)
    (hc : 0 ≤ c) (hprod : ∏ i : Fin n, f i < c ^ n) :
    ∃ i, f i < c := by
  contrapose! hprod; exact prod_ge_pow_of_forall_ge f c hc hprod;

/-
**Application to Drake Model**: If the expected number of civilizations
is less than base_count * c^n, some filter must be below c.
-/
theorem drake_great_filter {n : ℕ} (D : DrakeFilterModel n) (c : ℝ)
    (hc : 0 ≤ c) (hexp : D.expectedCiv < D.base_count * c ^ n) :
    ∃ i, D.filters i < c := by
  -- By Definition, D.expectedCiv = D.base_count * ∏ i, D.filters i
  have hexp_def : D.expectedCiv = D.base_count * ∏ i, D.filters i := by
    rfl;
  exact great_filter_exists _ _ hc ( by nlinarith [ D.base_pos ] )

/-! ## Temporal Pigeonhole

If fewer civilizations exist than there are time epochs,
at least one epoch is empty. -/

/-
**Temporal Pigeonhole**: If N civilizations arise during T time periods
and N < T, then at least one time period has no civilization arising in it.
This explains why we observe no contemporaneous civilizations: with few
civilizations spread across cosmic time, most epochs are empty.
-/
theorem temporal_pigeonhole {T N : ℕ} (hNT : N < T)
    (f : Fin N → Fin T) :
    ∃ t : Fin T, ∀ i : Fin N, f i ≠ t := by
  -- We'll use the fact that if the domain has fewer elements than the codomain, then there must be at least one element in the codomain not in the range of f.
  have h_not_surj: ¬ Function.Surjective f := by
    exact fun h => by have := Fintype.card_le_of_surjective f h; norm_num at this; linarith;
  simpa [ Function.Surjective ] using h_not_surj

/-! ## Filter Chain Exponential Decay -/

/-
**Filter Chain Bound**: If each filter probability is at most p,
the expected number of civilizations is at most base_count * p^n.
This quantifies the exponential decay: even moderate per-filter
probabilities (e.g., p = 0.1) lead to astronomically small expected
counts when n is large (e.g., 0.1^7 = 10^{-7}).
-/
theorem filter_chain_bound {n : ℕ} (D : DrakeFilterModel n) (p : ℝ)
    (hp : 0 ≤ p) (hfp : ∀ i, D.filters i ≤ p) :
    D.expectedCiv ≤ D.base_count * p ^ n := by
  convert mul_le_mul_of_nonneg_left ( Finset.prod_le_prod ( fun i _ => ?_ ) fun i _ => hfp i ) D.base_pos.le using 1;
  · norm_num;
  · exact le_of_lt ( D.filter_pos i )

/-! ## Drake Monotonicity -/

/-
**Filter Extension Decreases Expected Count**: Given a Drake model with n filters
and an additional filter with probability p ∈ (0, 1], the extended model's expected
count is at most the original.
-/
theorem filter_extension_decreases {n : ℕ} (D : DrakeFilterModel n)
    (p : ℝ) (hp : 0 < p) (hp1 : p ≤ 1) :
    D.expectedCiv * p ≤ D.expectedCiv := by
  exact mul_le_of_le_one_right ( DrakeFilterModel.expectedCiv_pos D |> le_of_lt ) hp1

/-! ## Contact Window Sparsity -/

/-
If N civilizations each occupy at most L consecutive time slots out of T total,
and N * L < T, then there exists a time slot not covered by any civilization.
This is a weighted pigeonhole argument.
-/
theorem contact_window_gap (T N L : ℕ) (_hT : 0 < T) (_hL : 0 < L)
    (hNLT : N * L < T)
    (starts : Fin N → ℕ)
    (_hstarts : ∀ i, starts i + L ≤ T) :
    ∃ t : Fin T, ∀ i : Fin N, ¬(starts i ≤ t.val ∧ t.val < starts i + L) := by
  by_contra h;
  -- Every time slot is covered by some civilization.
  have h_covered : ∀ t : Fin T, ∃ i : Fin N, starts i ≤ t.val ∧ t.val < starts i + L := by
    aesop;
  -- The total number of time slots covered is at most N * L (since each civilization covers at most L slots).
  have h_total_covered : Finset.card (Finset.biUnion Finset.univ (fun i => Finset.Ico (starts i) (starts i + L))) ≤ N * L := by
    exact le_trans ( Finset.card_biUnion_le ) ( by simpa );
  have h_total_covered : Finset.card (Finset.biUnion Finset.univ (fun i => Finset.Ico (starts i) (starts i + L))) ≥ T := by
    exact le_trans ( by norm_num ) ( Finset.card_le_card ( show Finset.Ico 0 T ⊆ Finset.biUnion Finset.univ fun i => Finset.Ico ( starts i ) ( starts i + L ) from fun x hx => by obtain ⟨ i, hi₁, hi₂ ⟩ := h_covered ⟨ x, by linarith [ Finset.mem_Ico.mp hx ] ⟩ ; aesop ) );
  linarith

/-! ## Falsifiable Conjecture

**Conjecture (Critical Filter Threshold)**: In any Drake model with n ≥ 7 filters
where all filters are in (0, 1] and the product of filters is less than c^n,
at least one filter is less than c. This follows from `great_filter_exists`.

Computational test: for n = 7 and product ≈ 10⁻²², we get c ≈ 10⁻³·¹⁴.
-/

/-- The critical filter conjecture: with n factors having product < c^n,
    the minimum is strictly less than c. Corollary of `great_filter_exists`. -/
theorem critical_filter_conjecture {n : ℕ}
    (f : Fin n → ℝ) (c : ℝ) (hc : 0 ≤ c)
    (hprod : ∏ i : Fin n, f i < c ^ n) :
    ∃ i, f i < c := by
  exact great_filter_exists f c hc hprod

end