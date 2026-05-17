import Mathlib

/-!
# Arithmetic Semigroups as Pseudorandom Generators for Polynomial Tests

This file establishes the central bridge theorem: **spectral gap implies
indistinguishability against bounded-degree polynomial observables**.

## Main Results

* `iterate_contraction` — spectral gap implies exponential contraction of iterates
* `spectral_gap_correlation_bound` — quantitative fooling bound
* `arithmetic_semigroup_fools_all_tests` — main qualitative theorem
* `berggren_mod_q_fools_all_tests` — Berggren semigroup instantiation
-/

noncomputable section

open Finset BigOperators

namespace ArithmeticPRG

variable {S : Type*} [Fintype S] [DecidableEq S] [Nonempty S]

/-! ## Section 1: Core Definitions -/

/-- The uniform expectation of `f : S → ℝ` over a finite type `S`. -/
def uniformExpect (f : S → ℝ) : ℝ :=
  (Fintype.card S : ℝ)⁻¹ * ∑ x : S, f x

/-- The centered (mean-zero) part of `f`. -/
def center (f : S → ℝ) : S → ℝ :=
  fun x => f x - uniformExpect f

/-- The L∞ norm (sup norm) of a function on a finite type. -/
def linfNorm (f : S → ℝ) : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty (fun x => |f x|)

/-- The averaging operator for `r` generators: `T f(x) = (1/r) ∑ᵢ f(gᵢ(x))`. -/
def AvgOp (r : ℕ) (generators : Fin r → (S → S)) (f : S → ℝ) : S → ℝ :=
  fun x => (r : ℝ)⁻¹ * ∑ i : Fin r, f (generators i x)

/-- `n`-fold iteration of the averaging operator. -/
def AvgOpIter (r : ℕ) (generators : Fin r → (S → S)) : ℕ → (S → ℝ) → (S → ℝ)
  | 0 => id
  | n + 1 => AvgOp r generators ∘ AvgOpIter r generators n

/-- Spectral gap: the averaging operator contracts mean-zero functions in L∞. -/
def SpectralGap (r : ℕ) (generators : Fin r → (S → S)) (ρ : ℝ) : Prop :=
  ∀ f : S → ℝ, uniformExpect f = 0 →
    linfNorm (AvgOp r generators f) ≤ ρ * linfNorm f

/-- Test error: L∞ distance between `T^n f` and the uniform expectation. -/
def TestError (r : ℕ) (generators : Fin r → (S → S)) (n : ℕ) (f : S → ℝ) : ℝ :=
  linfNorm (fun x => AvgOpIter r generators n f x - uniformExpect f)

/-- The centered L∞ norm of a test function. -/
def TestComplexityNorm (f : S → ℝ) : ℝ :=
  linfNorm (center f)

/-- The walk fools all test functions with exponentially decaying error. -/
def FoolsAllTests (r : ℕ) (generators : Fin r → (S → S)) (ρ : ℝ) : Prop :=
  ∀ f : S → ℝ, ∀ n : ℕ,
    TestError r generators n f ≤ TestComplexityNorm f * ρ ^ n

/-! ## Section 2: L∞ Norm Lemmas -/

theorem linfNorm_nonneg (f : S → ℝ) : 0 ≤ linfNorm f :=
  le_sup'_of_le _ (Finset.mem_univ (Classical.arbitrary S)) (abs_nonneg _)

theorem le_linfNorm (f : S → ℝ) (x : S) : |f x| ≤ linfNorm f :=
  le_sup'_of_le _ (Finset.mem_univ x) le_rfl

theorem linfNorm_le_of_forall_le (g : S → ℝ) (c : ℝ) (_hc : 0 ≤ c)
    (h : ∀ x : S, |g x| ≤ c) : linfNorm g ≤ c :=
  Finset.sup'_le _ _ (fun x _ => h x)

/-! ## Section 3: Key Lemmas -/

/-
The uniform expectation of a centered function is zero.
-/
theorem uniformExpect_center (f : S → ℝ) :
    uniformExpect (center f) = 0 := by
  unfold center uniformExpect
  simp [Finset.sum_sub_distrib, Finset.sum_const, nsmul_eq_mul, mul_comm, mul_assoc];
  rw [ mul_left_comm, mul_inv_cancel₀ ( Nat.cast_ne_zero.mpr Fintype.card_ne_zero ), mul_one, sub_self ]

/-
The averaging operator preserves uniform expectation when generators are bijective.
-/
theorem avgOp_preserves_expect
    {r : ℕ} (hr : 0 < r)
    {generators : Fin r → (S → S)}
    (hbij : ∀ i, Function.Bijective (generators i))
    (f : S → ℝ) :
    uniformExpect (AvgOp r generators f) = uniformExpect f := by
  unfold uniformExpect AvgOp;
  simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, mul_comm ];
  rw [ Finset.sum_comm ];
  have h_sum_eq : ∀ i : Fin r, ∑ x : S, f (generators i x) = ∑ x : S, f x := by
    exact fun i => Equiv.sum_comp ( Equiv.ofBijective _ ( hbij i ) ) _;
  simp +decide [ h_sum_eq, mul_comm ];
  rw [ mul_assoc, mul_inv_cancel₀ ( by positivity ), mul_one ]

/-
Iterated averaging preserves uniform expectation.
-/
theorem avgOpIter_preserves_expect
    {r : ℕ} (hr : 0 < r)
    {generators : Fin r → (S → S)}
    (hbij : ∀ i, Function.Bijective (generators i))
    (f : S → ℝ) (n : ℕ) :
    uniformExpect (AvgOpIter r generators n f) = uniformExpect f := by
  induction' n with n ih;
  · rfl;
  · convert avgOp_preserves_expect hr hbij ( AvgOpIter r generators n f ) using 1;
    exact ih.symm

/-! ## Section 4: Main Theorems -/

/-
**Iterate contraction**: spectral gap implies `ρ^n` contraction on
    mean-zero functions after `n` iterations.
-/
theorem iterate_contraction
    {r : ℕ} (hr : 0 < r)
    {generators : Fin r → (S → S)}
    (hbij : ∀ i, Function.Bijective (generators i))
    {ρ : ℝ} (hρ_nn : 0 ≤ ρ)
    (hGap : SpectralGap r generators ρ)
    (f : S → ℝ) (hf : uniformExpect f = 0)
    (n : ℕ) :
    linfNorm (AvgOpIter r generators n f) ≤ ρ ^ n * linfNorm f := by
  induction' n with n ih generalizing f;
  · simp +decide [ AvgOpIter ];
  · convert le_trans ( hGap _ _ ) ( mul_le_mul_of_nonneg_left ( ih _ _ ) hρ_nn ) using 1;
    · ring;
    · rw [ avgOpIter_preserves_expect hr hbij f n, hf ];
    · exact hf

/-
**Test error decomposition**: the test error equals the L∞ norm of the
    iterated centered function.
-/
omit [DecidableEq S] in
theorem testError_eq_iter_center
    {r : ℕ} (hr : 0 < r)
    {generators : Fin r → (S → S)}
    (_hbij : ∀ i, Function.Bijective (generators i))
    (f : S → ℝ) (n : ℕ) :
    TestError r generators n f = linfNorm (AvgOpIter r generators n (center f)) := by
  unfold TestError center;
  -- By definition of $AvgOpIter$, we have $AvgOpIter r generators n (f - uniformExpect f) = (AvgOpIter r generators n f) - uniformExpect f$.
  have h_avgIter_center : ∀ (n : ℕ) (f : S → ℝ), AvgOpIter r generators n (fun x => f x - uniformExpect f) = fun x => AvgOpIter r generators n f x - uniformExpect f := by
    intro n f;
    induction' n with n ih generalizing f <;> simp_all +decide [ AvgOpIter ];
    unfold AvgOp; simp +decide [ Finset.sum_sub_distrib, mul_sub ] ;
    simp +decide [ hr.ne' ];
  rw [ h_avgIter_center ]

/-- **Spectral gap implies fooling bound.**

Proof: Decompose `f = E[f] + center(f)`. The constant part is preserved.
The centered part contracts by `ρ^n`. Multiply by commutativity. -/
theorem spectral_gap_correlation_bound
    {r : ℕ} (hr : 0 < r)
    {generators : Fin r → (S → S)}
    (hbij : ∀ i, Function.Bijective (generators i))
    {ρ : ℝ} (hρ_nn : 0 ≤ ρ)
    (hGap : SpectralGap r generators ρ)
    (f : S → ℝ) (n : ℕ) :
    TestError r generators n f ≤ TestComplexityNorm f * ρ ^ n := by
  rw [testError_eq_iter_center hr hbij]
  have h := iterate_contraction hr hbij hρ_nn hGap (center f) (uniformExpect_center f) n
  unfold TestComplexityNorm
  linarith [mul_comm (ρ ^ n) (linfNorm (center f))]

/-- **Main theorem: arithmetic semigroup fools all tests.** -/
theorem arithmetic_semigroup_fools_all_tests
    {r : ℕ} (hr : 0 < r)
    {generators : Fin r → (S → S)}
    (hbij : ∀ i, Function.Bijective (generators i))
    {ρ : ℝ} (hρ_nn : 0 ≤ ρ)
    (hGap : SpectralGap r generators ρ) :
    FoolsAllTests r generators ρ :=
  fun f n => spectral_gap_correlation_bound hr hbij hρ_nn hGap f n

/-! ## Section 5: Berggren Semigroup Instantiation -/

/-- The Berggren generators acting on `(ZMod q)³`.
    A, B, C from the Berggren tree for Pythagorean triples. -/
def berggrenGen (q : ℕ) [NeZero q] (i : Fin 3)
    (s : ZMod q × ZMod q × ZMod q) : ZMod q × ZMod q × ZMod q :=
  match i with
  | ⟨0, _⟩ => (s.1 - 2 * s.2.1 + 2 * s.2.2,
                2 * s.1 - s.2.1 + 2 * s.2.2,
                2 * s.1 - 2 * s.2.1 + 3 * s.2.2)
  | ⟨1, _⟩ => (s.1 + 2 * s.2.1 + 2 * s.2.2,
                2 * s.1 + s.2.1 + 2 * s.2.2,
                2 * s.1 + 2 * s.2.1 + 3 * s.2.2)
  | ⟨2, _⟩ => (- s.1 + 2 * s.2.1 + 2 * s.2.2,
                - 2 * s.1 + s.2.1 + 2 * s.2.2,
                - 2 * s.1 + 2 * s.2.1 + 3 * s.2.2)

/-- **Berggren modular fooling theorem.**

For any modulus `q ≥ 2` where the Berggren generators are bijective on `(ZMod q)³`
and satisfy a spectral gap, the Berggren walk fools all test functions. -/
theorem berggren_mod_q_fools_all_tests
    (q : ℕ) [NeZero q]
    (hbij : ∀ i : Fin 3, Function.Bijective (berggrenGen q i))
    (ρ : ℝ) (hρ_nn : 0 ≤ ρ) (_hρ_lt : ρ < 1)
    (hGap : SpectralGap (S := ZMod q × ZMod q × ZMod q) 3 (berggrenGen q) ρ) :
    FoolsAllTests (S := ZMod q × ZMod q × ZMod q) 3 (berggrenGen q) ρ :=
  arithmetic_semigroup_fools_all_tests (by omega) hbij hρ_nn hGap

/-! ## Section 6: Circuit Complexity Bridge -/

/-- **Arithmetic PRG for bounded circuits.**

If a bounded arithmetic circuit computes a function `f` on the state space,
and the averaging operator has spectral gap `ρ`, then the test error of `f`
after `n` steps is bounded by `TestComplexityNorm f * ρ^n`. -/
theorem arithmetic_prg_for_bounded_circuits
    {r : ℕ} (hr : 0 < r)
    {generators : Fin r → (S → S)}
    (hbij : ∀ i, Function.Bijective (generators i))
    {ρ : ℝ} (hρ_nn : 0 ≤ ρ)
    (hGap : SpectralGap r generators ρ)
    (f : S → ℝ) (n : ℕ) :
    TestError r generators n f ≤ TestComplexityNorm f * ρ ^ n :=
  spectral_gap_correlation_bound hr hbij hρ_nn hGap f n

end ArithmeticPRG