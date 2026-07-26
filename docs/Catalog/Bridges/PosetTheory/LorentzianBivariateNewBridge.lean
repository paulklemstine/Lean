/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Lorentzian-to-Coefficient Bridge via Bivariate Specialization

This file establishes a new bridge connecting the Lorentzian geometry of homogeneous
multivariate polynomials to higher-order log-concavity of coefficient sequences
produced by bivariate specialization.

## Mathematical Overview

Given a homogeneous polynomial `P` with nonnegative coefficients that is recursively
Lorentzian, any "admissible" bivariate specialization `Q(x,y) = ∑ aₘ xᵐ yᵈ⁻ᵐ`
produces a coefficient sequence `a₀, a₁, …, aₐ` that inherits strong shape constraints.

The key mechanism is:
1. Lorentzian Hessian signature → reversed Cauchy–Schwarz on the positive cone
2. Applied to standard basis vectors of the bivariate slice → Newton's inequality
   `aₘ² ≥ aₘ₋₁ · aₘ₊₁`
3. Recursive Lorentzian depth `k` → the same inequality propagates through `k`
   levels of ratio transforms → `k`-fold log-concavity

## Main Definitions

* `BivariateSpecCoeffs` — coefficient sequence from a bivariate specialization
* `HessianLorentzianCoeffSeq` — predicate that the associated 2×2 Hessians all
  have Lorentzian signature
* `RecHessLor` — recursive version capturing depth

## Main Results

* `lorentzian_2x2_newton_inequality` — 2×2 Lorentzian signature implies Newton
* `hessianLorentzian_implies_newton` — Newton inequality for coefficient sequences
* `recursiveHessianLorentzian_implies_kFoldLogConcave` — flagship bridge theorem
* `recursiveLorentzian_step_propagation` — one level of recursion → one level
* `uniform_matroid_binomial_1fold_logConcave` — cross-domain matroid application

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Anari–Liu–Oveis Gharan–Vinzant, "Log-Concave Polynomials", 2019
-/

open Finset BigOperators Matrix

noncomputable section

namespace LorentzianBivariateNewBridge

/-! ## Part 1: Linear Algebra of 2×2 Lorentzian Forms -/

/-- Quadratic form Q_A(x) = ∑ᵢ ∑ⱼ A(i,j)·x(i)·x(j) for Fin 2 matrices. -/
def QF2 (A : Matrix (Fin 2) (Fin 2) ℝ) (x : Fin 2 → ℝ) : ℝ :=
  ∑ i, ∑ j, A i j * x i * x j

/-- Bilinear form B_A(x,y) = ∑ᵢ ∑ⱼ A(i,j)·x(i)·y(j) for Fin 2. -/
def BF2 (A : Matrix (Fin 2) (Fin 2) ℝ) (x y : Fin 2 → ℝ) : ℝ :=
  ∑ i, ∑ j, A i j * x i * y j

/-- A 2×2 matrix has Lorentzian signature: ∃ w, ∀ v ⊥ w, Q(v) ≤ 0. -/
def HasLorentzianSig2 (A : Matrix (Fin 2) (Fin 2) ℝ) : Prop :=
  ∃ w : Fin 2 → ℝ, ∀ v : Fin 2 → ℝ,
    (∑ i, w i * v i = 0) → QF2 A v ≤ 0

/-- Symmetry for 2×2 matrices. -/
def IsSymm2 (A : Matrix (Fin 2) (Fin 2) ℝ) : Prop :=
  A 0 1 = A 1 0

/-- Standard basis vector e₀ = (1, 0). -/
def e2_0 : Fin 2 → ℝ := ![1, 0]

/-- Standard basis vector e₁ = (0, 1). -/
def e2_1 : Fin 2 → ℝ := ![0, 1]

theorem qf2_e0 (A : Matrix (Fin 2) (Fin 2) ℝ) :
    QF2 A e2_0 = A 0 0 := by
  simp [QF2, e2_0, Fin.sum_univ_two, Fin.isValue]

theorem qf2_e1 (A : Matrix (Fin 2) (Fin 2) ℝ) :
    QF2 A e2_1 = A 1 1 := by
  simp [QF2, e2_1, Fin.sum_univ_two, Fin.isValue]

theorem bf2_e01 (A : Matrix (Fin 2) (Fin 2) ℝ) :
    BF2 A e2_0 e2_1 = A 0 1 := by
  simp [BF2, e2_0, e2_1, Fin.sum_univ_two, Fin.isValue]

/-! ### Reversed Cauchy–Schwarz for 2×2 Matrices -/

/-
**Reversed Cauchy–Schwarz for 2×2 symmetric Lorentzian matrices.**
-/
theorem reversed_cauchy_schwarz_2x2
    (A : Matrix (Fin 2) (Fin 2) ℝ)
    (hA : IsSymm2 A) (hL : HasLorentzianSig2 A)
    (x y : Fin 2 → ℝ) (hx : QF2 A x > 0) (hy : QF2 A y > 0) :
    BF2 A x y ^ 2 ≥ QF2 A x * QF2 A y := by
  -- Set s = ∑ i, w i * y i and t = -(∑ i, w i * x i). Then u = s•x + t•y satisfies ⟨w, u⟩ = 0 (by construction), so QF2 A u ≤ 0.
  obtain ⟨w, hw⟩ := hL
  set s := ∑ i, w i * y i
  set t := -(∑ i, w i * x i)
  have hu : QF2 A (s • x + t • y) ≤ 0 := by
    refine' hw _ _ ; ring!;
    simpa [ Fin.sum_univ_two ] using by ring;
  -- Expanding QF2 A (s • x + t • y) using bilinearity (over Fin 2): QF2 A (s • x + t • y) = s² · QF2 A x + 2·s·t · BF2 A x y + t² · QF2 A y.
  have h_expand : QF2 A (s • x + t • y) = s^2 * QF2 A x + 2 * s * t * BF2 A x y + t^2 * QF2 A y := by
    unfold QF2 BF2; norm_num [ Fin.sum_univ_two ] ; ring;
    rw [ show A 1 0 = A 0 1 by exact hA.symm ] ; ring;
  by_cases hs : s = 0;
  · exact absurd ( hw y hs ) ( by linarith );
  · nlinarith [ sq_nonneg ( s * BF2 A x y + t * QF2 A y ), mul_self_pos.2 hs ]

/-! ### Newton's Inequality from 2×2 Lorentzian Signature -/

/-- **The Newton inequality engine**: For a 2×2 symmetric matrix with Lorentzian
    signature, if the diagonal entries are positive, then A(0,1)² ≥ A(0,0)·A(1,1).

    This follows from reversed Cauchy–Schwarz applied at the standard basis. -/
theorem lorentzian_2x2_newton_inequality
    (A : Matrix (Fin 2) (Fin 2) ℝ)
    (hA : IsSymm2 A) (hL : HasLorentzianSig2 A)
    (h00 : A 0 0 > 0) (h11 : A 1 1 > 0) :
    A 0 1 ^ 2 ≥ A 0 0 * A 1 1 := by
  have hx : QF2 A e2_0 > 0 := by rw [qf2_e0]; exact h00
  have hy : QF2 A e2_1 > 0 := by rw [qf2_e1]; exact h11
  have hcs := reversed_cauchy_schwarz_2x2 A hA hL e2_0 e2_1 hx hy
  rw [bf2_e01, qf2_e0, qf2_e1] at hcs
  exact hcs

/-! ## Part 2: Bivariate Specialization Coefficients -/

/-- **Bivariate specialization coefficient sequence** of degree `d`.
    Encodes coefficients `a₀, a₁, …, aₐ` of a bivariate polynomial
    `Q(x,y) = ∑ₘ aₘ xᵐ yᵈ⁻ᵐ` from a 2-dimensional slice. -/
structure BivariateSpecCoeffs (d : ℕ) where
  a : ℕ → ℝ
  pos : ∀ m, m ≤ d → 0 < a m
  vanish : ∀ m, d < m → a m = 0

/-- The 2×2 coefficient matrix at index `m`:
    `M = [[a(m+1), a(m)], [a(m), a(m-1)]]` -/
def coeffMatrix2 (a : ℕ → ℝ) (m : ℕ) : Matrix (Fin 2) (Fin 2) ℝ :=
  !![a (m + 1), a m; a m, a (m - 1)]

theorem coeffMatrix2_symm (a : ℕ → ℝ) (m : ℕ) :
    IsSymm2 (coeffMatrix2 a m) := by
  simp [IsSymm2, coeffMatrix2]

/-- A coefficient sequence has **Lorentzian Hessian profile** at every
    interior index. -/
def HessianLorentzianCoeffSeq (a : ℕ → ℝ) (d : ℕ) : Prop :=
  ∀ m, 1 ≤ m → m + 1 ≤ d →
    HasLorentzianSig2 (coeffMatrix2 a m)

/-! ## Part 3: One-Step Newton Inequality -/

/-- **One-step Lorentzian-to-Newton inequality.**
    If a positive coefficient sequence on [0, d] has Lorentzian Hessian profile,
    then Newton's inequality holds at every interior index. -/
theorem hessianLorentzian_implies_newton
    {a : ℕ → ℝ} {d : ℕ}
    (hpos : ∀ m, m ≤ d → 0 < a m)
    (hL : HessianLorentzianCoeffSeq a d) :
    ∀ m, 1 ≤ m → m + 1 ≤ d →
      a m ^ 2 ≥ a (m - 1) * a (m + 1) := by
  intro m hm1 hm2
  have hLm := hL m hm1 hm2
  have hsymm := coeffMatrix2_symm a m
  have h00 : (coeffMatrix2 a m) 0 0 = a (m + 1) := by simp [coeffMatrix2]
  have h11 : (coeffMatrix2 a m) 1 1 = a (m - 1) := by simp [coeffMatrix2]
  have h01 : (coeffMatrix2 a m) 0 1 = a m := by simp [coeffMatrix2]
  have hd00 : (coeffMatrix2 a m) 0 0 > 0 := by rw [h00]; exact hpos _ (by omega)
  have hd11 : (coeffMatrix2 a m) 1 1 > 0 := by rw [h11]; exact hpos _ (by omega)
  have key := lorentzian_2x2_newton_inequality (coeffMatrix2 a m) hsymm hLm hd00 hd11
  rw [h01, h00, h11] at key
  linarith

/-- Corollary: Lorentzian coefficient sequences are log-concave. -/
theorem hessianLorentzian_implies_logConcave
    {d : ℕ} (spec : BivariateSpecCoeffs d)
    (hL : HessianLorentzianCoeffSeq spec.a d) :
    ∀ m, 1 ≤ m → m + 1 ≤ d →
      spec.a m ^ 2 ≥ spec.a (m - 1) * spec.a (m + 1) :=
  hessianLorentzian_implies_newton spec.pos hL

/-! ## Part 4: Finite Log-Concavity Hierarchy -/

def FPos (a : ℕ → ℝ) (d : ℕ) : Prop := ∀ m, m ≤ d → 0 < a m

def FLC (a : ℕ → ℝ) (d : ℕ) : Prop :=
  ∀ m, 1 ≤ m → m + 1 ≤ d → a m ^ 2 ≥ a (m - 1) * a (m + 1)

def RatioT (a : ℕ → ℝ) : ℕ → ℝ := fun m => a (m + 1) / a m

/-- **k-fold log-concavity for finite sequences.**
    0-fold = positive; (k+1)-fold = positive + log-concave + ratio is k-fold. -/
def FKLC : ℕ → (ℕ → ℝ) → ℕ → Prop
  | 0, a, d => FPos a d
  | k + 1, a, d => FPos a d ∧ FLC a d ∧ (1 ≤ d → FKLC k (RatioT a) (d - 1))

theorem fklc_mono {j k : ℕ} {a : ℕ → ℝ} {d : ℕ}
    (hk : FKLC k a d) (hjk : j ≤ k) : FKLC j a d := by
  induction k generalizing j a d with
  | zero => simp_all [FKLC]
  | succ k ih =>
    rcases j with _ | j
    · simp [FKLC]; exact hk.1
    · simp only [FKLC] at hk ⊢
      exact ⟨hk.1, hk.2.1, fun hd => ih (hk.2.2 hd) (by omega)⟩

theorem fklc_pos {k : ℕ} {a : ℕ → ℝ} {d : ℕ} (hk : FKLC k a d) : FPos a d := by
  cases k with
  | zero => exact hk
  | succ k => exact hk.1

theorem ratioT_pos {a : ℕ → ℝ} {d : ℕ} (hp : FPos a d) (hd : 1 ≤ d) :
    FPos (RatioT a) (d - 1) := by
  intro m hm
  exact div_pos (hp (m + 1) (by omega)) (hp m (by omega))

/-! ## Part 5: Recursive Hessian-Lorentzian Depth -/

/-- **Recursive Hessian-Lorentzian coefficient sequence of depth `k`.**
    This is the coefficient-level shadow of recursive Lorentzianity. -/
def RecHessLor : ℕ → (ℕ → ℝ) → ℕ → Prop
  | 0, a, d => FPos a d
  | k + 1, a, d => FPos a d ∧ HessianLorentzianCoeffSeq a d ∧
      (2 ≤ d → RecHessLor k (RatioT a) (d - 1))

theorem recHessLor_pos {k : ℕ} {a : ℕ → ℝ} {d : ℕ}
    (h : RecHessLor k a d) : FPos a d := by
  cases k with
  | zero => exact h
  | succ k => exact h.1

/-! ## Part 6: The Flagship Bridge Theorem -/

/-- **One level of recursive Lorentzianity gives one level of log-concavity.**

    If a coefficient sequence is recursively Hessian-Lorentzian at depth `k+1`,
    then it is `(k+1)`-fold log-concave on [0, d]. -/
theorem recursiveLorentzian_step_propagation
    {k : ℕ} {a : ℕ → ℝ} {d : ℕ}
    (hR : RecHessLor (k + 1) a d) :
    FKLC (k + 1) a d := by
  induction k generalizing a d with
  | zero =>
    simp only [FKLC]
    exact ⟨hR.1, hessianLorentzian_implies_newton hR.1 hR.2.1,
           fun hd => ratioT_pos hR.1 hd⟩
  | succ k ih =>
    simp only [FKLC]
    refine ⟨hR.1, hessianLorentzian_implies_newton hR.1 hR.2.1, fun hd => ?_⟩
    by_cases hd2 : 2 ≤ d
    · exact ih (hR.2.2 hd2)
    · -- d = 1, ratio transform has degree 0, need FKLC (k+1) _ 0
      have hd1 : d = 1 := by omega
      subst hd1
      simp only [Nat.sub_self]
      show FKLC (k + 1) (RatioT a) 0
      have hrt_pos : FPos (RatioT a) 0 := ratioT_pos hR.1 (by omega)
      clear ih hd hd2 hR
      induction k with
      | zero => exact ⟨hrt_pos, fun _ h1 h2 => absurd h2 (by omega), fun h => absurd h (by omega)⟩
      | succ k ih => exact ⟨hrt_pos, fun _ h1 h2 => absurd h2 (by omega), fun h => absurd h (by omega)⟩

/-- **Flagship theorem: Recursive Hessian-Lorentzian depth `k` implies
    `k` levels of log-concavity.** -/
theorem recursiveHessianLorentzian_implies_kFoldLogConcave
    {k : ℕ} {a : ℕ → ℝ} {d : ℕ}
    (hR : RecHessLor k a d) :
    FKLC k a d := by
  cases k with
  | zero => exact hR
  | succ k => exact recursiveLorentzian_step_propagation hR

/-- The bivariate specialization bridge in bundled form. -/
theorem bivariateSpec_kFoldLogConcave
    {d k : ℕ} (spec : BivariateSpecCoeffs d)
    (hR : RecHessLor k spec.a d) :
    FKLC k spec.a d :=
  recursiveHessianLorentzian_implies_kFoldLogConcave hR

/-! ## Part 7: Cross-Domain — Uniform Matroid Application -/

def binomSeq (d : ℕ) : ℕ → ℝ := fun m => (Nat.choose d m : ℝ)

theorem binomSeq_pos (d : ℕ) : FPos (binomSeq d) d := by
  intro m hm
  simp [binomSeq]
  exact Nat.cast_pos.mpr (Nat.choose_pos hm)

/-
**Binomial coefficients are log-concave.**
    C(d,m)² ≥ C(d,m-1)·C(d,m+1) for 1 ≤ m ≤ d-1.
-/
theorem binomSeq_logConcave (d : ℕ) (hd : 2 ≤ d) :
    FLC (binomSeq d) d := by
  intro m hm₁ hm₂;
  rcases m <;> simp_all +decide [ binomSeq ];
  norm_cast;
  have := Nat.choose_succ_right_eq d ‹_›;
  have := Nat.choose_succ_right_eq d ( Nat.succ ‹_› );
  nlinarith [ Nat.sub_add_cancel ( by linarith : ‹_› ≤ d ), Nat.sub_add_cancel ( by linarith : ‹_› + 1 ≤ d ) ]

/-- **Uniform matroid basis counts are 1-fold log-concave.** -/
theorem uniform_matroid_binomial_1fold_logConcave (d : ℕ) (hd : 2 ≤ d) :
    FKLC 1 (binomSeq d) d := by
  exact ⟨binomSeq_pos d, binomSeq_logConcave d hd,
         fun hd1 => ratioT_pos (binomSeq_pos d) hd1⟩

/-! ## Part 8: Computational Certification -/

def checkNewtonAt (a : ℕ → ℚ) (m : ℕ) : Bool :=
  a m * a m ≥ a (m - 1) * a (m + 1)

def checkLogConcave (a : ℕ → ℚ) (d : ℕ) : Bool :=
  (List.range (d - 1)).all fun m => checkNewtonAt a (m + 1)

def ratioTQ (a : ℕ → ℚ) : ℕ → ℚ :=
  fun m => a (m + 1) / a m

def checkKFoldLC : ℕ → (ℕ → ℚ) → ℕ → Bool
  | 0, a, d => (List.range (d + 1)).all fun m => a m > 0
  | k + 1, a, d =>
    (List.range (d + 1)).all (fun m => a m > 0) &&
    checkLogConcave a d &&
    (if d ≥ 1 then checkKFoldLC k (ratioTQ a) (d - 1) else true)

structure NewtonViolation (a : ℕ → ℝ) (d : ℕ) where
  idx : ℕ
  hrange : 1 ≤ idx ∧ idx + 1 ≤ d
  hviolation : a idx ^ 2 < a (idx - 1) * a (idx + 1)

theorem logConcave_or_violation (a : ℕ → ℝ) (d : ℕ) :
    FLC a d ∨ ∃ _ : NewtonViolation a d, True := by
  by_cases h : FLC a d
  · exact Or.inl h
  · right
    simp only [FLC, ge_iff_le, not_forall] at h
    obtain ⟨m, hm1, hm2, hm3⟩ := h
    push_neg at hm3
    exact ⟨⟨m, ⟨hm1, hm2⟩, by linarith⟩, trivial⟩

/-! ## Part 9: Conjecture -/

/-- **Conjecture**: Every positive bivariate specialization of a degree-d
    Lorentzian polynomial (even without recursive depth) has a coefficient
    sequence that is (d-2)-fold log-concave. -/
def InfiniteRatioLogConcavityConjecture : Prop :=
  ∀ (d : ℕ) (a : ℕ → ℝ),
    2 ≤ d → FPos a d → HessianLorentzianCoeffSeq a d →
    FKLC (d - 2) a d

/-! ## Part 10: Ultra-Log-Concavity -/

/-- Ultra-log-concavity: the sequence normalized by binomial coefficients
    is log-concave. -/
def UltraLC (a : ℕ → ℝ) (d : ℕ) : Prop :=
  ∀ m, 1 ≤ m → m + 1 ≤ d →
    (a m / (Nat.choose d m : ℝ)) ^ 2 ≥
    (a (m - 1) / (Nat.choose d (m - 1) : ℝ)) *
    (a (m + 1) / (Nat.choose d (m + 1) : ℝ))

/-
Ultra-log-concavity implies ordinary log-concavity for positive sequences,
    given that binomial coefficients are themselves log-concave.
-/
theorem ultraLC_implies_LC {a : ℕ → ℝ} {d : ℕ}
    (hpos : FPos a d) (_hd : 2 ≤ d)
    (hU : UltraLC a d) :
    FLC a d := by
  intro m hm₁ hm₂;
  -- By multiplying both sides of the ultra-log-concavity inequality by $(Nat.choose d m)^2$, we get:
  have h_mul : (a m ^ 2) ≥ (a (m - 1)) * (a (m + 1)) * ((Nat.choose d m) ^ 2) / ((Nat.choose d (m - 1)) * (Nat.choose d (m + 1))) := by
    have := hU m hm₁ hm₂;
    field_simp at this;
    rw [ ge_iff_le, div_le_iff₀ ] at * <;> norm_cast at * <;> simp_all +decide [ Nat.choose_eq_zero_iff ];
    · rwa [ div_mul_eq_mul_div, le_div_iff₀ ( by norm_cast; exact pow_pos ( Nat.choose_pos ( by linarith ) ) 2 ) ] at this;
    · exact ⟨ Nat.choose_pos ( by omega ), Nat.choose_pos ( by omega ) ⟩;
    · exact ⟨ Nat.choose_pos ( by omega ), Nat.choose_pos ( by omega ) ⟩;
  -- By the properties of binomial coefficients, we know that $(Nat.choose d m)^2 \geq (Nat.choose d (m - 1)) * (Nat.choose d (m + 1))$.
  have h_binom : (Nat.choose d m : ℝ) ^ 2 ≥ (Nat.choose d (m - 1)) * (Nat.choose d (m + 1)) := by
    rcases m <;> simp_all +decide [ Nat.choose ];
    norm_cast;
    have := Nat.add_one_mul_choose_eq d ‹_›; have := Nat.add_one_mul_choose_eq d ( ‹_› + 1 ) ; norm_num [ Nat.choose_succ_succ ] at * ; nlinarith;
  refine le_trans ?_ h_mul;
  rw [ le_div_iff₀ ] <;> nlinarith [ show 0 < ( d.choose ( m - 1 ) : ℝ ) * d.choose ( m + 1 ) from mul_pos ( Nat.cast_pos.mpr ( Nat.choose_pos ( by omega ) ) ) ( Nat.cast_pos.mpr ( Nat.choose_pos ( by omega ) ) ), show 0 < a ( m - 1 ) * a ( m + 1 ) from mul_pos ( hpos _ ( by omega ) ) ( hpos _ ( by omega ) ) ]

end LorentzianBivariateNewBridge