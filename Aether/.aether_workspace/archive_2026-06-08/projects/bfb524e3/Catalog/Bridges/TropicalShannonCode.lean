/-
Copyright (c) 2025 Tropical Information Theory Project. All rights reserved.

# Tropical Shannon Code: Near-Optimal Min-Plus Compression

This file establishes the core bridge between tropical (min-plus) algebra
and Shannon source coding theory. The main results are:

1. **Theorem A** (`tropical_shannon_code_near_optimal`):
   The rounded tropical self-information code ⌈-log μ(a)⌉ has expected length
   sandwiched between entropy H(μ) and H(μ)+1.

2. **Theorem B** (`tropical_code_expected_length_sandwich`):
   There exists a Kraft-feasible integer code achieving the sandwich bound.

3. **Theorem C** (`minPlusConv_eq_sInf`, `kraft_product_is_tropical_convolution`):
   Min-plus convolution equals the infimum characterization, and product
   Kraft sums decompose as tropical convolution.

4. **Theorem D** (`ceil_neglog_is_least_feasible_majorant`):
   The ceiling of negative log-probability is the least integer code length
   among all feasible majorants of information content.
-/

import Mathlib

open Finset Real BigOperators

namespace TropicalShannonCode

/-! ## Probability Distributions -/

/-- A finitely-supported probability distribution. -/
structure FinProbDist (α : Type*) [Fintype α] where
  mass : α → ℝ
  mass_nonneg : ∀ x, 0 ≤ mass x
  mass_sum_one : ∑ x : α, mass x = 1

variable {α : Type*} [Fintype α] [Nonempty α]

/-- Any probability mass is at most 1. -/
theorem FinProbDist.mass_le_one (μ : FinProbDist α) (x : α) : μ.mass x ≤ 1 := by
  calc μ.mass x ≤ ∑ y : α, μ.mass y :=
    Finset.single_le_sum (fun y _ => μ.mass_nonneg y) (Finset.mem_univ x)
  _ = 1 := μ.mass_sum_one

/-! ## Shannon Entropy (for positive distributions) -/

/-- Shannon entropy H(μ) = -∑ p(x) · log(p(x)), using natural logarithm. -/
noncomputable def shannonEntropy (μ : FinProbDist α) : ℝ :=
  -∑ a : α, μ.mass a * Real.log (μ.mass a)

/-! ## Kraft Admissibility -/

/-- A code length ℓ : α → ℝ is Kraft-admissible if ∑ exp(-ℓ(a)) ≤ 1. -/
def KraftAdmissible (ℓ : α → ℝ) : Prop :=
  ∑ a : α, Real.exp (-ℓ a) ≤ 1

/-- Kraft feasibility for integer code lengths. -/
def TropicalPrefixCode (L : α → ℕ) : Prop :=
  KraftAdmissible (fun a => (L a : ℝ))

/-! ## Core Definitions -/

/-- Tropical self-information: the ideal real-valued code length -log(p). -/
noncomputable def tropInfo (μ : FinProbDist α) (a : α) : ℝ :=
  -Real.log (μ.mass a)

/-- Shannon code length: the rounded-up tropical self-information. -/
noncomputable def shannonLen (μ : FinProbDist α) (a : α) : ℕ :=
  Nat.ceil (tropInfo μ a)

/-- Expected code length under distribution μ. -/
noncomputable def expectedLen (μ : FinProbDist α) (L : α → ℕ) : ℝ :=
  ∑ a, μ.mass a * (L a : ℝ)

/-! ## Helper Lemmas -/

/-
Tropical self-information is nonneg for probability distributions.
-/
lemma tropInfo_nonneg (μ : FinProbDist α) (hpos : ∀ a, 0 < μ.mass a) (a : α) :
    0 ≤ tropInfo μ a := by
  exact neg_nonneg_of_nonpos ( Real.log_nonpos ( le_of_lt ( hpos a ) ) ( μ.mass_le_one a ) )

/-
The ceiling is at least the value.
-/
lemma le_shannonLen (μ : FinProbDist α) (hpos : ∀ a, 0 < μ.mass a) (a : α) :
    tropInfo μ a ≤ (shannonLen μ a : ℝ) := by
  exact Nat.le_ceil _

/-
The ceiling is strictly less than value + 1.
-/
lemma shannonLen_lt_add_one (μ : FinProbDist α) (hpos : ∀ a, 0 < μ.mass a) (a : α) :
    (shannonLen μ a : ℝ) < tropInfo μ a + 1 := by
  convert Nat.ceil_lt_add_one _;
  · infer_instance;
  · exact tropInfo_nonneg μ hpos a

/-! ## Shannon Code Satisfies Kraft Inequality -/

/-
The Shannon code lengths satisfy the Kraft inequality:
    ∑ exp(-⌈-log p(a)⌉) ≤ 1.
    Proof: exp(-⌈x⌉) ≤ exp(-x) since ⌈x⌉ ≥ x, and ∑ exp(log p(a)) = ∑ p(a) = 1.
-/
theorem shannonLen_kraft (μ : FinProbDist α) (hpos : ∀ a, 0 < μ.mass a) :
    TropicalPrefixCode (shannonLen μ) := by
  have h_sum_le : ∑ a, Real.exp (-shannonLen μ a) ≤ ∑ a, Real.exp (-(-Real.log (μ.mass a))) := by
    exact Finset.sum_le_sum fun a _ => Real.exp_le_exp.mpr ( neg_le_neg ( le_shannonLen μ hpos a ) );
  exact h_sum_le.trans ( by simp [ Real.exp_log ( hpos _ ), μ.mass_sum_one ] )

/-! ## Gibbs Inequality (Lower Bound) -/

/-
**Gibbs inequality / Shannon lower bound**: For any Kraft-admissible code
    lengths ℓ, the expected code length is at least the Shannon entropy.
    H(μ) ≤ E_μ[ℓ].
-/
theorem shannon_lower_bound
    (μ : FinProbDist α) (ℓ : α → ℝ)
    (hpos : ∀ a, 0 < μ.mass a)
    (hKraft : KraftAdmissible ℓ) :
    shannonEntropy μ ≤ ∑ a, μ.mass a * ℓ a := by
  -- Applying the inequality $\log(x) \leq x - 1$ to each term in the sum, we get:
  have h_ineq : ∑ a, (μ.mass a) * (ℓ a + Real.log (μ.mass a)) ≥ ∑ a, (μ.mass a) * Real.log (Real.exp (-ℓ a) / (μ.mass a)) := by
    have h_ineq : ∑ a, (μ.mass a) * (Real.exp (-ℓ a) / (μ.mass a) - 1) ≥ ∑ a, (μ.mass a) * Real.log (Real.exp (-ℓ a) / (μ.mass a)) := by
      exact Finset.sum_le_sum fun a _ => mul_le_mul_of_nonneg_left ( by linarith [ Real.log_le_sub_one_of_pos ( div_pos ( Real.exp_pos ( -ℓ a ) ) ( hpos a ) ) ] ) ( le_of_lt ( hpos a ) );
    simp_all +decide [ mul_sub, mul_add, mul_div_cancel₀ _ ( ne_of_gt ( hpos _ ) ) ];
    simp_all +decide [ Real.log_div ( ne_of_gt ( Real.exp_pos _ ) ) ( ne_of_gt ( hpos _ ) ), Real.log_exp, Finset.sum_add_distrib, mul_add, mul_sub, Finset.sum_sub_distrib ];
    linarith [ μ.mass_sum_one, show ∑ x, Real.exp ( -ℓ x ) ≤ 1 from hKraft ];
  -- Using the properties of logarithms, we can simplify the right-hand side of the inequality.
  have h_simplify : ∑ a, (μ.mass a) * Real.log (Real.exp (-ℓ a) / (μ.mass a)) = ∑ a, (μ.mass a) * (-ℓ a - Real.log (μ.mass a)) := by
    exact Finset.sum_congr rfl fun x _ => by rw [ Real.log_div ( by positivity ) ( by linarith [ hpos x ] ), Real.log_exp ] ;
  simp_all +decide [ mul_add, mul_sub, Finset.sum_add_distrib, Finset.sum_sub_distrib ];
  unfold shannonEntropy; linarith;

/-! ## Theorem A: Tropical Shannon Code Near-Optimality -/

/-
**Upper bound**: Expected Shannon code length < entropy + 1.
    Uses ⌈x⌉ < x + 1 pointwise, then sums with positive weights.
-/
theorem expected_shannonLen_lt_entropy_add_one
    (μ : FinProbDist α) (hpos : ∀ a, 0 < μ.mass a) :
    expectedLen μ (shannonLen μ) < shannonEntropy μ + 1 := by
  -- By definition of $shannonLen$, we know that $shannonLen μ a < -Real.log (μ.mass a) + 1$ for all $a$.
  have h_shannon_len_lt_add_one : ∀ a, (shannonLen μ a : ℝ) < -Real.log (μ.mass a) + 1 := by
    -- By definition of `shannonLen`, we know that `shannonLen μ a < -Real.log (μ.mass a) + 1` for all `a` because `shannonLen μ a` is the ceiling of `-Real.log (μ.mass a)`.
    intros a
    apply shannonLen_lt_add_one μ hpos a;
  convert Finset.sum_lt_sum_of_nonempty Finset.univ_nonempty fun a _ => mul_lt_mul_of_pos_left ( h_shannon_len_lt_add_one a ) ( hpos a ) using 1;
  simp +decide [ shannonEntropy, mul_add, Finset.sum_add_distrib, μ.mass_sum_one ]

/-- **Theorem A**: The rounded tropical self-information code has expected length
    sandwiched between Shannon entropy and Shannon entropy + 1:
      H(μ) ≤ E[L] < H(μ) + 1
    This is the irreducible bridge: the tropical code-length obtained from
    min-plus geometry is Shannon-optimal up to the unavoidable integrality gap. -/
theorem tropical_shannon_code_near_optimal
    (μ : FinProbDist α) (hpos : ∀ a, 0 < μ.mass a) :
    shannonEntropy μ ≤ expectedLen μ (shannonLen μ) ∧
    expectedLen μ (shannonLen μ) < shannonEntropy μ + 1 := by
  exact ⟨shannon_lower_bound μ _ hpos (shannonLen_kraft μ hpos),
         expected_shannonLen_lt_entropy_add_one μ hpos⟩

/-! ## Theorem B: Tropical Code Expected Length Sandwich -/

/-- **Theorem B**: There exists a Kraft-feasible integer code achieving the
    Shannon entropy sandwich. The Shannon code ⌈-log μ(a)⌉ is the witness. -/
theorem tropical_code_expected_length_sandwich
    (μ : FinProbDist α) (hpos : ∀ a, 0 < μ.mass a) :
    ∃ L : α → ℕ,
      TropicalPrefixCode L ∧
      shannonEntropy μ ≤ expectedLen μ L ∧
      expectedLen μ L < shannonEntropy μ + 1 := by
  exact ⟨shannonLen μ, shannonLen_kraft μ hpos, tropical_shannon_code_near_optimal μ hpos⟩

/-! ## Theorem C: Min-Plus Convolution -/

/-- Min-plus convolution of two functions on ℕ. -/
noncomputable def minPlusConv (f g : ℕ → ℝ) (n : ℕ) : ℝ :=
  ⨅ (p : Fin (n + 1)), f p.val + g (n - p.val)

/-
**Theorem C (part 1)**: Min-plus convolution equals the set-theoretic infimum
    characterization {c | ∃ i j, i+j=n ∧ c = f(i)+g(j)}.
-/
theorem minPlusConv_eq_sInf (f g : ℕ → ℝ) (n : ℕ) :
    minPlusConv f g n = sInf {c | ∃ i j : ℕ, i + j = n ∧ c = f i + g j} := by
  unfold minPlusConv;
  rw [ IsGLB.ciInf_eq ];
  constructor;
  · rintro _ ⟨ p, rfl ⟩;
    exact csInf_le ⟨ - ( ∑ i ∈ Finset.range ( n + 1 ), |f i| + ∑ i ∈ Finset.range ( n + 1 ), |g i| ), by rintro x ⟨ i, j, hij, rfl ⟩ ; cases abs_cases ( f i ) <;> cases abs_cases ( g j ) <;> linarith [ Finset.single_le_sum ( fun i _ => abs_nonneg ( f i ) ) ( Finset.mem_range.mpr ( show i < n + 1 from by linarith ) ), Finset.single_le_sum ( fun i _ => abs_nonneg ( g i ) ) ( Finset.mem_range.mpr ( show j < n + 1 from by linarith ) ) ] ⟩ ⟨ p, n - p, by rw [ add_tsub_cancel_of_le ( by linarith [ Fin.is_lt p ] ) ], rfl ⟩;
  · rintro x hx;
    refine' le_csInf _ _;
    · exact ⟨ _, ⟨ 0, n, zero_add _, rfl ⟩ ⟩;
    · rintro _ ⟨ i, j, hij, rfl ⟩ ; exact hx ⟨ ⟨ i, by linarith ⟩, by simp +decide [ ← hij ] ⟩ ;

/-
Min-plus convolution is commutative.
-/
theorem minPlusConv_comm (f g : ℕ → ℝ) (n : ℕ) :
    minPlusConv f g n = minPlusConv g f n := by
  convert minPlusConv_eq_sInf f g n using 1;
  convert minPlusConv_eq_sInf g f n using 1;
  grind +revert

/-
Min-plus convolution is bounded above by any valid decomposition.
-/
theorem minPlusConv_le (f g : ℕ → ℝ) {i : ℕ} (hi : i ≤ n) :
    minPlusConv f g n ≤ f i + g (n - i) := by
  exact ciInf_le_of_le ( Finite.bddBelow_range fun p : Fin ( n + 1 ) => f p + g ( n - p ) ) ⟨ i, by linarith ⟩ rfl.le

/-
**Theorem C (part 2)**: Product source Kraft sums decompose multiplicatively,
    which in log space becomes min-plus additive — the tropical convolution principle.
    This proves that code combination for independent sources is literally
    tropical algebra.
-/
theorem kraft_product_is_tropical_convolution
    {β : Type*} [Fintype β] [DecidableEq β] [Nonempty β]
    (L₁ : α → ℕ) (L₂ : β → ℕ) :
    (∑ p : α × β, Real.exp (-(↑(L₁ p.1) + ↑(L₂ p.2)))) =
    (∑ a, Real.exp (-(L₁ a : ℝ))) * (∑ b, Real.exp (-(L₂ b : ℝ))) := by
  simp +decide only [neg_add, exp_add, Fintype.sum_prod_type, Finset.sum_mul _ _ _];
  simp +decide only [Finset.mul_sum _ _ _]

/-! ## Theorem D: Least Feasible Majorant -/

/-
**Theorem D**: The ceiling of negative log-probability is the least
    feasible integer majorant. Among all integer code lengths that pointwise
    dominate the information content, ⌈-log μ(a)⌉ is pointwise minimal.
    This is the tropical envelope theorem.
-/
theorem ceil_neglog_is_least_feasible_majorant
    (μ : FinProbDist α) (hpos : ∀ a, 0 < μ.mass a) :
    TropicalPrefixCode (shannonLen μ) ∧
    ∀ ℓ : α → ℕ,
      (∀ a, tropInfo μ a ≤ (ℓ a : ℝ)) →
      ∀ a, shannonLen μ a ≤ ℓ a := by
  exact ⟨ shannonLen_kraft μ hpos, fun ℓ hℓ a => Nat.ceil_le.mpr ( hℓ a ) ⟩

/-! ## Bridge Theorem -/

/-- The Shannon code provides an explicit witness for the abstract
    source coding lower bound, instantiating abstract inequalities
    with a concrete optimizer. -/
theorem shannon_code_instantiates_lower_bound
    (μ : FinProbDist α) (hpos : ∀ a, 0 < μ.mass a) :
    KraftAdmissible (fun a => (shannonLen μ a : ℝ)) ∧
    shannonEntropy μ ≤ ∑ a, μ.mass a * (shannonLen μ a : ℝ) := by
  exact ⟨shannonLen_kraft μ hpos, (tropical_shannon_code_near_optimal μ hpos).1⟩

end TropicalShannonCode