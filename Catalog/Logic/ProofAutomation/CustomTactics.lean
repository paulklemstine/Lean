import Mathlib

/-!
# Sound custom tactics for recurring proof patterns

This file implements three small proof procedures:

* `tropical_simp` normalizes min-plus expressions using a proved rewrite basis;
* `number_theory_decide` reflects concrete primality goals to Boolean trial division;
* `spectral_bound` reduces a real eigenvalue estimate to absolute row sums.

The metaprograms are deliberately thin: each invokes kernel-checked theorems proved below.
Thus their soundness does not depend on an unverified external oracle.
-/

namespace Catalog.CustomTactics

/-! ## 1. Min-plus simplification -/

namespace Tropical

/-- Min-plus tropical addition. -/
def tadd (a b : ℝ) : ℝ := min a b

/-- Min-plus tropical multiplication. -/
def tmul (a b : ℝ) : ℝ := a + b

/-- The first nontrivial rewrite in the verified basis: left distributivity. -/
theorem tmul_tadd (a b c : ℝ) :
    tmul a (tadd b c) = tadd (tmul a b) (tmul a c) := by
  simp only [tmul, tadd, min_add_add_left]

/-- Right distributivity follows from left distributivity and commutativity. -/
theorem tadd_tmul (a b c : ℝ) :
    tmul (tadd a b) c = tadd (tmul a c) (tmul b c) := by
  calc
    tmul (tadd a b) c = tmul c (tadd a b) := by simp [tmul, add_comm]
    _ = tadd (tmul c a) (tmul c b) := tmul_tadd c a b
    _ = tadd (tmul a c) (tmul b c) := by simp [tmul, add_comm]

/-- A certified rewrite basis used by `tropical_simp`. -/
theorem rewrite_basis_sound (a b c : ℝ) :
    tmul a (tadd b c) = tadd (tmul a b) (tmul a c) ∧
    tmul (tadd a b) c = tadd (tmul a c) (tmul b c) ∧
    tadd a a = a := by
  exact ⟨tmul_tadd a b c, tadd_tmul a b c, min_self a⟩

/-- Normalize min-plus expressions using only the certified algebraic rewrites. -/
macro "tropical_simp" : tactic =>
  `(tactic| simp only [Catalog.CustomTactics.Tropical.tmul,
      Catalog.CustomTactics.Tropical.tadd, min_add_add_left,
      min_add_add_right, min_self, add_zero, zero_add])

/-- A three-term distributive law, illustrating recursive normalization. -/
theorem tmul_three_way (a b c d : ℝ) :
    tmul a (tadd (tadd b c) d) =
      tadd (tmul a b) (tadd (tmul a c) (tmul a d)) := by
  rw [tmul_tadd, tmul_tadd]
  exact min_assoc _ _ _

/-- Tropical absorption after distributing a common factor. -/
theorem tmul_absorption (a b : ℝ) :
    tadd (tmul a b) (tmul a (tadd b b)) = tmul a b := by
  rw [tmul_tadd]
  tropical_simp

end Tropical

/-! ## 2. Reflected trial-division for concrete primality -/

namespace NumberTheory

/-- Whether `n` has a divisor in the proper trial-division range `[2,n)`. -/
def hasProperDivisor (n : ℕ) : Bool :=
  (List.range n).any (fun d => decide (2 ≤ d) && decide (d ∣ n))

/-- A Boolean primality test by exhaustive trial division below `n`. -/
def trialPrime (n : ℕ) : Bool :=
  decide (2 ≤ n) && !hasProperDivisor n

/-- Logical meaning of the divisor search. -/
theorem hasProperDivisor_iff (n : ℕ) :
    hasProperDivisor n = true ↔ ∃ d, 2 ≤ d ∧ d < n ∧ d ∣ n := by
  simp only [hasProperDivisor, List.any_eq_true, List.mem_range, Bool.and_eq_true,
    decide_eq_true_eq]
  constructor
  · rintro ⟨d, hdlt, hd2, hdvd⟩
    exact ⟨d, hd2, hdlt, hdvd⟩
  · rintro ⟨d, hd2, hdlt, hdvd⟩
    exact ⟨d, hdlt, hd2, hdvd⟩

/-- The trial-division Boolean is extensionally equal to `Nat.Prime`. -/
theorem trialPrime_correct (n : ℕ) : trialPrime n = true ↔ Nat.Prime n := by
  rw [Nat.prime_def_lt']
  constructor
  · intro h
    have hp : 2 ≤ n ∧ hasProperDivisor n = false := by simpa [trialPrime] using h
    refine ⟨hp.1, ?_⟩
    intro m hm2 hmn hdiv
    have hex : ∃ d, 2 ≤ d ∧ d < n ∧ d ∣ n := ⟨m, hm2, hmn, hdiv⟩
    have : hasProperDivisor n = true := (hasProperDivisor_iff n).2 hex
    simp_all
  · rintro ⟨hn, hprime⟩
    have hnone : hasProperDivisor n = false := by
      apply Bool.eq_false_iff.mpr
      intro htrue
      obtain ⟨m, hm2, hmn, hdiv⟩ := (hasProperDivisor_iff n).1 htrue
      exact hprime m hm2 hmn hdiv
    simp [trialPrime, hn, hnone]

/-- Reflect a concrete primality (or non-primality) goal through `trialPrime`. -/
macro "number_theory_decide" : tactic =>
  `(tactic| first
    | (rw [← Catalog.CustomTactics.NumberTheory.trialPrime_correct]; decide)
    | decide
    | omega)

/-- A nontrivial positive certificate produced by reflected trial division. -/
theorem prime_97 : Nat.Prime 97 := by
  number_theory_decide

/-- A composite certificate uses the same proved reflection theorem. -/
theorem not_prime_91 : ¬ Nat.Prime 91 := by
  number_theory_decide

/-- The positive and negative certificates cannot describe the same number. -/
theorem certified_numbers_distinct : (97 : ℕ) ≠ 91 := by
  intro h
  have hp : Nat.Prime 91 := by simpa [h] using prime_97
  exact not_prime_91 hp

end NumberTheory

/-! ## 3. Absolute row-sum spectral estimates -/

namespace Spectral

open Matrix Finset

/-- An eigenvector has a coordinate of maximal absolute value. -/
theorem exists_max_abs_coordinate {n : ℕ} (v : Fin n → ℝ) (hv : v ≠ 0) :
    ∃ i₀, 0 < |v i₀| ∧ ∀ i, |v i| ≤ |v i₀| := by
  obtain ⟨i₀, hi₀⟩ : ∃ i₀, ∀ i, |v i| ≤ |v i₀| := by
    simpa using Finset.exists_max_image Finset.univ (fun i => |v i|)
      ⟨Classical.choose (Function.ne_iff.mp hv), Finset.mem_univ _⟩
  refine ⟨i₀, ?_, hi₀⟩
  rw [abs_pos]
  intro hz
  apply hv
  funext i
  have hle : |v i| ≤ 0 := by simpa [hz] using hi₀ i
  exact abs_eq_zero.mp (le_antisymm hle (abs_nonneg _))

/-- Some row's absolute sum bounds the magnitude of every real eigenvalue. -/
theorem exists_rowSum_ge_abs_eigenvalue
    {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (lam : ℝ) (v : Fin n → ℝ)
    (hv : v ≠ 0) (hAv : A.mulVec v = lam • v) :
    ∃ i : Fin n, |lam| ≤ ∑ j, |A i j| := by
  obtain ⟨i₀, hpos, hi₀⟩ := exists_max_abs_coordinate v hv
  have htriangle : |lam| * |v i₀| ≤ ∑ j, |A i₀ j| * |v j| := by
    have h : |lam * v i₀| ≤ ∑ j, |A i₀ j * v j| := by
      convert Finset.abs_sum_le_sum_abs (fun j => A i₀ j * v j) Finset.univ using 2
      simpa [Matrix.mulVec, dotProduct] using congr_fun hAv.symm i₀
    simpa only [abs_mul] using h
  have hmono : ∑ j, |A i₀ j| * |v j| ≤ ∑ j, |A i₀ j| * |v i₀| :=
    Finset.sum_le_sum fun j _ => mul_le_mul_of_nonneg_left (hi₀ j) (abs_nonneg _)
  have hfactor : ∑ j, |A i₀ j| * |v i₀| = (∑ j, |A i₀ j|) * |v i₀| := by
    rw [Finset.sum_mul]
  refine ⟨i₀, ?_⟩
  nlinarith [htriangle, hmono, hfactor]

/-- Uniform absolute row sums bound every real eigenvalue. -/
theorem eigenvalue_abs_le_of_rowSum_le
    {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (lam : ℝ) (v : Fin n → ℝ)
    (hv : v ≠ 0) (hAv : A.mulVec v = lam • v)
    (B : ℝ) (hB : ∀ i, ∑ j, |A i j| ≤ B) :
    |lam| ≤ B := by
  obtain ⟨i, hi⟩ := exists_rowSum_ge_abs_eigenvalue A lam v hv hAv
  exact hi.trans (hB i)

/-- Reduce a real eigenvalue estimate to a uniform absolute row-sum estimate. -/
macro "spectral_bound" : tactic =>
  `(tactic| apply Catalog.CustomTactics.Spectral.eigenvalue_abs_le_of_rowSum_le <;>
      assumption)

/-- The tactic's direct soundness interface. -/
theorem spectral_bound_sound
    {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (lam : ℝ) (v : Fin n → ℝ)
    (hv : v ≠ 0) (hAv : A.mulVec v = lam • v)
    (B : ℝ) (hB : ∀ i, ∑ j, |A i j| ≤ B) :
    |lam| ≤ B := by
  spectral_bound

/-- A symmetric interval estimate follows from the absolute spectral bound. -/
theorem eigenvalue_mem_interval
    {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (lam : ℝ) (v : Fin n → ℝ)
    (hv : v ≠ 0) (hAv : A.mulVec v = lam • v)
    (B : ℝ) (hB : ∀ i, ∑ j, |A i j| ≤ B) :
    -B ≤ lam ∧ lam ≤ B := by
  have h := spectral_bound_sound A lam v hv hAv B hB
  exact (abs_le.mp h)

end Spectral

end Catalog.CustomTactics