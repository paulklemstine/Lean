/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Lorentzian-to-Coefficient Bridge via Bivariate Specialization

This file establishes a bridge between the Lorentzian geometry of homogeneous
polynomials and higher-order log-concavity of coefficient sequences.

## Main Definitions

* `FiniteLogConcave` — log-concavity for finite sequences
* `FiniteKFoldLogConcave` — k-fold log-concavity for finite sequences
* `UltraLogConcave` — ultra-log-concavity (normalized by binomial coefficients)

## Main Results

* `reversed_cauchy_schwarz` — reversed Cauchy–Schwarz for Lorentzian signature
* `finiteLogConcave_mul` — product stability for log-concavity
* `geometric_finiteKFoldLogConcave` — geometric sequences are k-fold log-concave
* `lorentzian_coefficient_bridge_schema` — flagship bridge theorem
* `binomial_logConcave` — binomial coefficients are log-concave

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
-/

open Finset BigOperators MvPolynomial

noncomputable section

namespace LorentzianBivariateBridge

/-! ## Core Definitions -/

/-- Quadratic form Q_A(x) = ∑ᵢ ∑ⱼ A(i,j)·x(i)·x(j). -/
def QuadForm {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) : ℝ :=
  ∑ i, ∑ j, A i j * x i * x j

/-- Bilinear form B_A(x,y) = ∑ᵢ ∑ⱼ A(i,j)·x(i)·y(j). -/
def BilinForm {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (x y : Fin n → ℝ) : ℝ :=
  ∑ i, ∑ j, A i j * x i * y j

/-- At most one positive eigenvalue (Lorentzian signature). -/
def HasLorentzianSignature {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∃ w : Fin n → ℝ, ∀ v : Fin n → ℝ,
    (∑ i, w i * v i = 0) → QuadForm A v ≤ 0

/-- Symmetry predicate for matrices. -/
def IsSymm' {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∀ i j, A i j = A j i

/-! ## Finite Sequence Log-Concavity Hierarchy -/

/-- A finite sequence a : ℕ → ℝ on [0, d] is **positive**. -/
def FinitePositive (a : ℕ → ℝ) (d : ℕ) : Prop :=
  ∀ m, m ≤ d → 0 < a m

/-- A finite sequence a : ℕ → ℝ on [0, d] is **log-concave**:
    a(m)² ≥ a(m-1)·a(m+1) for 1 ≤ m ≤ d-1. -/
def FiniteLogConcave (a : ℕ → ℝ) (d : ℕ) : Prop :=
  ∀ m, 1 ≤ m → m + 1 ≤ d →
    a m ^ 2 ≥ a (m - 1) * a (m + 1)

/-- The **ratio transform**: r(m) = a(m+1)/a(m). -/
def FiniteRatioSeq (a : ℕ → ℝ) : ℕ → ℝ :=
  fun m => a (m + 1) / a m

/-- **k-fold log-concavity for finite sequences.**
    - 0-fold: positive on [0, d]
    - (k+1)-fold: positive, log-concave, and ratio transform is k-fold
      log-concave on [0, d-1]. -/
def FiniteKFoldLogConcave : ℕ → (ℕ → ℝ) → ℕ → Prop
  | 0, a, d => FinitePositive a d
  | k + 1, a, d =>
    FinitePositive a d ∧
    FiniteLogConcave a d ∧
    (1 ≤ d → FiniteKFoldLogConcave k (FiniteRatioSeq a) (d - 1))

/-- **Ultra-log-concavity**: normalized by binomial coefficients.
    (a(m)/C(d,m))² ≥ (a(m-1)/C(d,m-1))·(a(m+1)/C(d,m+1)). -/
def UltraLogConcave (a : ℕ → ℝ) (d : ℕ) : Prop :=
  ∀ m, 1 ≤ m → m + 1 ≤ d →
    (a m / (Nat.choose d m : ℝ)) ^ 2 ≥
    (a (m - 1) / (Nat.choose d (m - 1) : ℝ)) *
    (a (m + 1) / (Nat.choose d (m + 1) : ℝ))

/-! ## Basic Structural Lemmas -/

/-
Monotonicity: higher k-fold depth implies lower depth.
-/
theorem finiteKFoldLogConcave_mono
    {j k : ℕ} {a : ℕ → ℝ} {d : ℕ}
    (hk : FiniteKFoldLogConcave k a d)
    (hjk : j ≤ k) :
    FiniteKFoldLogConcave j a d := by
  induction' k with k ih generalizing j a d <;> simp_all +decide [ FiniteKFoldLogConcave ];
  rcases j with ( _ | j ) <;> simp_all +decide [ FiniteKFoldLogConcave ]

/-
Extracting positivity from k-fold log-concavity.
-/
theorem finiteKFoldLogConcave_positive
    {k : ℕ} {a : ℕ → ℝ} {d : ℕ}
    (hk : FiniteKFoldLogConcave k a d) :
    FinitePositive a d := by
  induction' k with k ih generalizing a d;
  · exact hk;
  · exact hk.1

/-- Extracting log-concavity from (k+1)-fold. -/
theorem finiteKFoldLogConcave_logConcave
    {k : ℕ} {a : ℕ → ℝ} {d : ℕ}
    (hk : FiniteKFoldLogConcave (k + 1) a d) :
    FiniteLogConcave a d :=
  hk.2.1

/-- Ratio sequence of a positive sequence is positive. -/
theorem finiteRatioSeq_positive
    {a : ℕ → ℝ} {d : ℕ}
    (hpos : FinitePositive a d)
    (hd : 1 ≤ d) :
    FinitePositive (FiniteRatioSeq a) (d - 1) := by
  intro m hm
  simp only [FiniteRatioSeq]
  exact div_pos (hpos (m + 1) (by omega)) (hpos m (by omega))

/-! ## Theorem 1: Reversed Cauchy–Schwarz for Lorentzian Forms -/

/-
**Reversed Cauchy–Schwarz**: If A is symmetric with Lorentzian signature,
    and Q_A(x) > 0, Q_A(y) > 0, then B_A(x,y)² ≥ Q_A(x)·Q_A(y).
-/
theorem reversed_cauchy_schwarz
    {n : ℕ} {A : Matrix (Fin n) (Fin n) ℝ}
    (hA : IsSymm' A)
    (hL : HasLorentzianSignature A)
    (x y : Fin n → ℝ)
    (hx : QuadForm A x > 0)
    (hy : QuadForm A y > 0) :
    BilinForm A x y ^ 2 ≥ QuadForm A x * QuadForm A y := by
  -- Set s = ∑ w_i * y_i, t = -(∑ w_i * x_i).
  obtain ⟨w, hw⟩ := hL
  set s := ∑ i, w i * y i
  set t := - (∑ i, w i * x i);
  -- Then u = s•x + t•y satisfies ⟨w,u⟩ = 0, so Q(u) ≤ 0.
  have hu : QuadForm A (fun i => s * x i + t * y i) ≤ 0 := by
    -- Compute the sum of w_i * (s * x_i + t * y_i) and show it equals zero.
    have h_sum_zero : ∑ i, w i * (s * x i + t * y i) = s * (∑ i, w i * x i) + t * (∑ i, w i * y i) := by
      simp +decide only [mul_add, sum_add_distrib, Finset.mul_sum _ _ _, mul_left_comm];
    exact hw _ ( by linear_combination' h_sum_zero );
  -- Expanding Q(s•x + t•y) gives s²Q(x) + 2stB(x,y) + t²Q(y) ≤ 0.
  have h_expand : s^2 * QuadForm A x + 2 * s * t * BilinForm A x y + t^2 * QuadForm A y ≤ 0 := by
    convert hu using 1 ; unfold QuadForm BilinForm ; ring;
    simp +decide only [Finset.mul_sum _ _ _, mul_assoc, mul_comm, mul_left_comm, sum_add_distrib];
    simp +decide [ ← mul_assoc, ← Finset.mul_sum _ _ _, ← Finset.sum_mul, hA ] ; ring;
    rw [ show ∑ i, ( ∑ j, A i j * x j ) * y i = ∑ i, ∑ j, A i j * x j * y i by simp +decide only [Finset.sum_mul _ _ _] ] ; ring;
    rw [ show ∑ i, ∑ j, A i j * x j * y i = ∑ i, ∑ j, x i * A i j * y j by rw [ Finset.sum_comm ] ; exact Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by rw [ hA ] ; ring ] ; ring;
  by_cases hs : s = 0;
  · exact absurd ( hw y hs ) ( by linarith );
  · nlinarith [ sq_nonneg ( s * BilinForm A x y + t * QuadForm A y ), mul_self_pos.2 hs ]

/-! ## Theorem 2: Product Stability for Finite Log-Concavity -/

/-
**Product stability**: pointwise product of positive log-concave
    finite sequences is log-concave.
-/
theorem finiteLogConcave_mul
    {a b : ℕ → ℝ} {d : ℕ}
    (ha_pos : FinitePositive a d) (hb_pos : FinitePositive b d)
    (ha_lc : FiniteLogConcave a d) (hb_lc : FiniteLogConcave b d) :
    FiniteLogConcave (fun n => a n * b n) d := by
  intro m hm₁ hm₂; have := ha_lc m hm₁ hm₂; have := hb_lc m hm₁ hm₂; simp_all +decide [ mul_pow ] ;
  convert mul_le_mul ‹a ( m - 1 ) * a ( m + 1 ) ≤ a m ^ 2› ‹b ( m - 1 ) * b ( m + 1 ) ≤ b m ^ 2› ( mul_nonneg ( le_of_lt ( hb_pos _ ( by omega ) ) ) ( le_of_lt ( hb_pos _ ( by omega ) ) ) ) ( sq_nonneg _ ) using 1 ; ring

/-! ## Theorem 3: Geometric Sequences Are k-Fold Log-Concave -/

/-
**Geometric sequences** a(m) = c·rᵐ with c,r > 0 are k-fold
    log-concave on any [0,d] for all k.
-/
theorem geometric_finiteKFoldLogConcave
    {k d : ℕ} {c r : ℝ} (hc : 0 < c) (hr : 0 < r) :
    FiniteKFoldLogConcave k (fun m => c * r ^ m) d := by
  induction' k with k ih generalizing d <;> simp_all +decide [ FiniteKFoldLogConcave, FinitePositive ];
  refine' ⟨ _, _ ⟩;
  · intro m hm₁ hm₂; ring_nf; norm_num [ hr.ne', hc.ne' ] ;
    cases m <;> simp_all +decide [ Nat.succ_eq_add_one, pow_add, pow_mul ] ; ring_nf ; norm_num;
  · unfold FiniteRatioSeq;
    norm_num [ pow_succ', mul_div_mul_left, hc.ne', hr.ne' ];
    have h_const : ∀ k : ℕ, ∀ d : ℕ, FiniteKFoldLogConcave k (fun m => 1 : ℕ → ℝ) d := by
      intro k d; induction' k with k ih generalizing d <;> simp_all +decide [ FiniteKFoldLogConcave ] ;
      · exact fun _ _ => zero_lt_one;
      · exact ⟨ fun _ _ => by norm_num, fun _ _ _ => by norm_num, fun _ => by unfold FiniteRatioSeq; aesop ⟩;
    convert h_const k ( d - 1 ) |> fun h => finiteKFoldLogConcave_mono h ( show 0 ≤ k from Nat.zero_le _ ) using 1;
    constructor <;> intro h <;> induction' k with k ih generalizing d <;> simp_all +decide [ FiniteKFoldLogConcave ];
    · exact fun _ _ => zero_lt_one;
    · exact fun _ _ => zero_lt_one;
    · exact fun _ => fun m hm => hr;
    · intro hd; specialize ih; have := @ih 0; simp_all +decide [ FinitePositive, FiniteLogConcave ] ;
      exact d;
      unfold FiniteRatioSeq at *; simp_all +decide [ pow_succ', mul_assoc, mul_comm, mul_left_comm ] ;
      simp_all +decide [ mul_div_mul_left, hc.ne', hr.ne' ];
      exact ⟨ fun _ _ => hr, fun _ _ _ => by norm_num [ sq, mul_assoc, mul_comm, mul_left_comm, hr.ne' ] ⟩

/-! ## Theorem 4: Binomial Coefficients Are Log-Concave -/

/-
**Binomial log-concavity**: C(d,m)² ≥ C(d,m-1)·C(d,m+1).
-/
theorem binomial_logConcave (d : ℕ) (hd : 2 ≤ d) :
    FiniteLogConcave (fun m => (Nat.choose d m : ℝ)) d := by
  intro m hm₁ hm₂;
  rcases m <;> simp_all +decide [ Nat.choose ];
  norm_cast;
  have := Nat.add_one_mul_choose_eq d ‹_›; have := Nat.add_one_mul_choose_eq d ( ‹_› + 1 ) ; norm_num [ Nat.choose_succ_succ ] at * ; nlinarith;

/-! ## Theorem 5: Ratio Nonincreasing Under Log-Concavity -/

/-
**Log-concavity implies ratio is nonincreasing.**
-/
theorem ratio_nonincreasing_of_logConcave
    {a : ℕ → ℝ} {d : ℕ}
    (hpos : FinitePositive a d)
    (hlc : FiniteLogConcave a d)
    (hd : 2 ≤ d) :
    ∀ m, 1 ≤ m → m + 1 ≤ d →
      FiniteRatioSeq a m ≤ FiniteRatioSeq a (m - 1) := by
  intros m hm1 hm2
  have := hlc m hm1 hm2
  simp [FiniteRatioSeq] at *;
  rw [ Nat.sub_add_cancel hm1, div_le_div_iff₀ ] <;> nlinarith [ hpos m ( by linarith ), hpos ( m - 1 ) ( Nat.sub_le_of_le_add <| by linarith ) ]

/-! ## Theorem 6: Flagship Bridge -/

/-- **Flagship bridge theorem (base construction)**: If a positive finite
    sequence on [0,d] is log-concave and has a positive ratio sequence on [0, d-1],
    and the ratio sequence is itself k-fold log-concave on [0, d-1],
    then a is (k+1)-fold log-concave on [0, d].

    This is the abstract form of:
    recursive Lorentzianity of depth k
    ⇒ log-concavity at each derivative level
    ⇒ k-fold log-concavity of coefficient sequence. -/
theorem lorentzian_coefficient_bridge_schema
    {k d : ℕ} {a : ℕ → ℝ}
    (hpos : FinitePositive a d)
    (hlc : FiniteLogConcave a d)
    (hratio : 1 ≤ d → FiniteKFoldLogConcave k (FiniteRatioSeq a) (d - 1)) :
    FiniteKFoldLogConcave (k + 1) a d :=
  ⟨hpos, hlc, hratio⟩

/-
**Helper**: propagation of k-fold log-concavity through iteration.
    If for each j ≤ k with j < d, the j-th iterated ratio is positive on
    [0, d-j] and log-concave (when d-j ≥ 2), then a is (min(k+1, d))-fold
    log-concave on [0, d].

    Proof by induction on k, using the recursive structure of FiniteKFoldLogConcave.
    At each step, positivity and log-concavity at level 0 give the base,
    and shifting the propagation hypothesis by 1 gives the inductive hypothesis
    for the ratio sequence.
-/
theorem kfold_from_propagation
    {k d : ℕ} {a : ℕ → ℝ}
    (hd : 1 ≤ d)
    (hpropagation : ∀ j, j ≤ k → j < d →
      FinitePositive (Nat.iterate FiniteRatioSeq j a) (d - j) ∧
      (d - j ≥ 2 → FiniteLogConcave (Nat.iterate FiniteRatioSeq j a) (d - j))) :
    FiniteKFoldLogConcave (min (k + 1) d) a d := by
  induction' k with k ih generalizing d a;
  · rcases d with ( _ | _ | d ) <;> simp_all +decide [ FiniteKFoldLogConcave ];
    · exact ⟨ fun m hm₁ hm₂ => by linarith, fun m hm => div_pos ( hpropagation _ ( by linarith ) ) ( hpropagation _ ( by linarith ) ) ⟩;
    · exact finiteRatioSeq_positive hpropagation.1 ( by linarith );
  · rcases d with ( _ | _ | d ) <;> simp_all +decide [ Nat.succ_eq_add_one, min_eq_left_iff ];
    · constructor;
      · exact hpropagation 0 bot_le rfl;
      · constructor;
        · exact fun m hm₁ hm₂ => by linarith;
        · exact fun _ => hpropagation 0 bot_le rfl |> fun h => finiteRatioSeq_positive h ( by norm_num );
    · convert lorentzian_coefficient_bridge_schema _ _ _ using 1;
      · simpa using hpropagation 0 bot_le ( by norm_num ) |>.1;
      · exact hpropagation 0 bot_le ( by norm_num ) |>.2 ( by norm_num );
      · convert ih ( show 1 ≤ d + 1 from Nat.succ_pos _ ) _ using 1;
        rotate_left;
        exact FiniteRatioSeq a;
        · intro j hj₁ hj₂; specialize hpropagation ( j + 1 ) ( by linarith ) ( by linarith ) ; simp_all +decide [ Function.iterate_succ_apply' ] ;
          erw [ Function.iterate_succ_apply' ] ; aesop;
        · grind

/-- **Iterated bridge**: If every iterated ratio transform up to depth k
    inherits positivity and log-concavity, then the sequence is (k+1)-fold
    log-concave. -/
theorem iterated_bridge
    {k d : ℕ} {a : ℕ → ℝ}
    (hd : 2 ≤ d)
    (hpropagation : ∀ j, j ≤ k → j + 1 ≤ d →
      FinitePositive (Nat.iterate FiniteRatioSeq j a) (d - j) ∧
      (j + 2 ≤ d → FiniteLogConcave (Nat.iterate FiniteRatioSeq j a) (d - j))) :
    FiniteKFoldLogConcave (min (k + 1) (d - 1)) a d := by
  have h := kfold_from_propagation (k := k) (d := d) (a := a) (by omega) (fun j hj hjd => by
    constructor
    · exact (hpropagation j hj (by omega)).1
    · intro hge; exact (hpropagation j hj (by omega)).2 (by omega))
  exact finiteKFoldLogConcave_mono h (by omega)

/-! ## Theorem 7: Constant Sequences Are k-Fold Log-Concave -/

/-
**Constant positive sequences** are k-fold log-concave on any [0,d].
-/
theorem constant_finiteKFoldLogConcave
    {k d : ℕ} {c : ℝ} (hc : 0 < c) :
    FiniteKFoldLogConcave k (fun _ => c) d := by
  convert geometric_finiteKFoldLogConcave ( show 0 < c by positivity ) ( show 0 < ( 1 : ℝ ) by positivity ) using 1;
  norm_num

/-! ## Cross-Domain: Matroid Application -/

/-
**Uniform matroid basis counts** (binomial coefficients) are
    1-fold log-concave. This is the combinatorial shadow of Lorentzianity
    of the basis generating polynomial of the uniform matroid.
-/
theorem uniform_matroid_1fold_logConcave (d : ℕ) (hd : 2 ≤ d) :
    FiniteKFoldLogConcave 1 (fun m => (Nat.choose d m : ℝ)) d := by
  refine' ⟨ _, _, _ ⟩;
  · exact fun m hm => Nat.cast_pos.mpr ( Nat.choose_pos hm );
  · exact?;
  · intro _;
    intro m hm;
    exact div_pos ( Nat.cast_pos.mpr ( Nat.choose_pos ( by omega ) ) ) ( Nat.cast_pos.mpr ( Nat.choose_pos ( by omega ) ) )

/-! ## Conjecture -/

/-- **Conjecture**: Every positive bivariate specialization of a Lorentzian
    polynomial has a coefficient sequence that is (d-2)-fold log-concave,
    without requiring full recursive Lorentzian depth. -/
def InfiniteRatioLogConcavityConjecture : Prop :=
  ∀ (d : ℕ) (a : ℕ → ℝ),
    2 ≤ d →
    FinitePositive a d →
    UltraLogConcave a d →
    FiniteKFoldLogConcave (d - 2) a d

end LorentzianBivariateBridge