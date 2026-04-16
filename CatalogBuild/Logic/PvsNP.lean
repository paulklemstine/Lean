/-! # CatalogBuild.Logic.PvsNP

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 12
-/

import Mathlib

/-- The Subset Sum decision problem: given a list of integers and a target,
does some subset sum to the target? -/
def SubsetSum (weights : List ℤ) (target : ℤ) : Prop :=
  ∃ S : Finset (Fin weights.length),
    (∑ i ∈ S, weights.get i) = target



/-- [Section: # CatalogBuild.Logic.PvsNP
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 12] -/
instance SubsetSum.instDecidable (weights : List ℤ) (target : ℤ) :
    Decidable (SubsetSum weights target) :=
  inferInstanceAs (Decidable (∃ S : Finset (Fin weights.length), _))



/-- Given a candidate subset, we can verify the sum. -/
def verifySubsetSum (weights : List ℤ) (target : ℤ)
    (S : Finset (Fin weights.length)) : Prop :=
  (∑ i ∈ S, weights.get i) = target



/-- SubsetSum is equivalent to existence of a valid certificate. -/
theorem subsetSum_iff_exists_certificate (weights : List ℤ) (target : ℤ) :
    SubsetSum weights target ↔
    ∃ S : Finset (Fin weights.length), verifySubsetSum weights target S := by
  simp [SubsetSum, verifySubsetSum]



/-- The number of subsets of an n-element set is 2^n. -/
theorem num_subsets (n : ℕ) : Fintype.card (Finset (Fin n)) = 2 ^ n := by
  simp [Fintype.card_finset, Fintype.card_fin]



/-- Exponential growth: 2^n > n for all n. -/
theorem exponential_exceeds_linear (n : ℕ) : n < 2 ^ n :=
  Nat.lt_two_pow_self



/-- Berggren tree has at least one node at every depth. -/
theorem berggren_nodes_at_depth (d : ℕ) : 3 ^ d ≥ 1 :=
  Nat.one_le_pow d 3 (by omega)



theorem berggren_superpolynomial (k : ℕ) : ∃ N, ∀ d, N ≤ d → d ^ k < 3 ^ d := by
  -- We can use the fact that exponential functions grow faster than any polynomial function. Specifically, for any fixed $k$, $3^d$ will eventually outpace $d^k$ as $d$ increases.
  have h_exp_growth : Filter.Tendsto (fun d : ℕ => (d ^ k : ℝ) / 3 ^ d) Filter.atTop (nhds 0) := by
    -- We can convert this limit into a form that is easier to handle by substituting $x = d \log 3$.
    suffices h_subst : Filter.Tendsto (fun x : ℝ => (x / Real.log 3) ^ k / Real.exp x) Filter.atTop (nhds 0) by
      convert h_subst.comp ( tendsto_natCast_atTop_atTop.atTop_mul_const ( Real.log_pos ( show ( 3 : ℝ ) > 1 by norm_num ) ) ) using 2 ; norm_num [ Real.exp_nat_mul, Real.exp_log ];
    -- We can factor out $(1 / \ln 3)^k$ from the limit.
    suffices h_factor : Filter.Tendsto (fun x : ℝ => x ^ k / Real.exp x) Filter.atTop (nhds 0) by
      convert h_factor.div_const ( Real.log 3 ^ k ) using 2 <;> ring;
    simpa [ Real.exp_neg ] using Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero k;
  exact Filter.eventually_atTop.mp ( h_exp_growth.eventually ( gt_mem_nhds zero_lt_one ) ) |> fun ⟨ N, hN ⟩ ↦ ⟨ N, fun n hn ↦ by have := hN n hn; rw [ div_lt_one ( by positivity ) ] at this; exact_mod_cast this ⟩



/-- Any algorithm examining all subsets of an n-element set
must consider 2^n candidates. No tree structure changes this. -/
theorem subset_enumeration_exponential (n : ℕ) :
    Fintype.card (Finset (Fin n)) = 2 ^ n :=
  num_subsets n



theorem no_poly_covering (k : ℕ) :
    ∃ N, ∀ n, N ≤ n → n ^ k < 2 ^ n := by
  -- We can use the fact that exponential functions grow faster than polynomial functions.
  have h_exp_growth : Filter.Tendsto (fun n : ℕ => (n : ℝ)^k / 2^n) Filter.atTop (nhds 0) := by
    -- We can use the fact that $2^n$ grows exponentially faster than $n^k$.
    have h_exp_growth : Filter.Tendsto (fun n : ℕ => (n : ℝ)^k / Real.exp (n * Real.log 2)) Filter.atTop (nhds 0) := by
      -- Let $y = n \ln 2$, therefore the limit becomes $\lim_{y \to \infty} \frac{y^k}{e^y}$.
      suffices h_log : Filter.Tendsto (fun y : ℝ => y ^ k / Real.exp y) Filter.atTop (nhds 0) by
        have h_subst : Filter.Tendsto (fun n : ℕ => (n * Real.log 2) ^ k / Real.exp (n * Real.log 2)) Filter.atTop (nhds 0) := by
          exact h_log.comp <| tendsto_natCast_atTop_atTop.atTop_mul_const <| Real.log_pos one_lt_two;
        convert h_subst.div_const ( Real.log 2 ^ k ) using 2 <;> ring;
        norm_num [ mul_right_comm, mul_assoc, mul_left_comm, ne_of_gt, Real.log_pos ];
      simpa [ Real.exp_neg ] using Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero k;
    simpa [ Real.exp_nat_mul, Real.exp_log ] using h_exp_growth;
  exact Filter.eventually_atTop.mp ( h_exp_growth.eventually ( gt_mem_nhds zero_lt_one ) ) |> fun ⟨ N, hN ⟩ ↦ ⟨ N, fun n hn ↦ by have := hN n hn; rw [ div_lt_one ( by positivity ) ] at this; exact_mod_cast this ⟩



/-- The empty subset always sums to 0. -/
theorem empty_subset_sum (weights : List ℤ) : SubsetSum weights 0 :=
  ⟨∅, by simp⟩



/-- The full set sums to the total. -/
theorem full_subset_sum (weights : List ℤ) :
    SubsetSum weights (∑ i : Fin weights.length, weights.get i) :=
  ⟨Finset.univ, by simp⟩


