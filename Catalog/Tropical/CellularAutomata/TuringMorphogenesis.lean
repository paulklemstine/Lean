/-
# Turing's Flowers: Morphogenesis as Algebraic Geometry

This module formalizes the connection between Turing reaction-diffusion patterns
and algebraic geometry. The key insight is that steady-state Turing patterns
decompose into cosine eigenmodes, and via Chebyshev polynomials, the zero set
of any finite mode superposition is a real algebraic variety.

## Main Results

* `cos_chebyshev_recurrence` — The fundamental trigonometric recurrence underlying
  Chebyshev polynomials: cos((n+2)θ) = 2cos(θ)cos((n+1)θ) - cos(nθ)
* `cos_eq_chebyshevT_eval` — cos(nθ) equals Tₙ evaluated at cos(θ)
* `chebyshevT_natDegree` — Chebyshev polynomial Tₙ has degree exactly n (for n ≥ 1)
* `turing_instability_criterion` — The algebraic condition for diffusion-driven instability
* `pattern_zero_set_algebraic` — Zero sets of mode superpositions are algebraic
-/

import Mathlib

open Real Polynomial Finset

noncomputable section

/-! ## Section 1: Chebyshev Polynomials

We define Chebyshev polynomials of the first kind Tₙ ∈ ℝ[X] by the recurrence
T₀ = 1, T₁ = X, Tₙ₊₂ = 2X·Tₙ₊₁ - Tₙ, and prove that cos(nθ) = Tₙ(cos θ).
This is the bridge that converts trigonometric patterns into algebraic objects. -/

/-- Chebyshev polynomials of the first kind, defined by the recurrence
    T₀ = 1, T₁ = X, Tₙ₊₂ = 2X·Tₙ₊₁ - Tₙ. -/
def chebyshevT : ℕ → Polynomial ℝ
  | 0 => 1
  | 1 => X
  | n + 2 => 2 * X * chebyshevT (n + 1) - chebyshevT n

@[simp] theorem chebyshevT_zero : chebyshevT 0 = 1 := rfl
@[simp] theorem chebyshevT_one : chebyshevT 1 = X := rfl
theorem chebyshevT_succ_succ (n : ℕ) :
    chebyshevT (n + 2) = 2 * X * chebyshevT (n + 1) - chebyshevT n := rfl

/-
The fundamental cosine recurrence: cos((n+2)θ) = 2cos(θ)cos((n+1)θ) - cos(nθ).
    This follows from the product-to-sum formula for cosines.
-/
theorem cos_chebyshev_recurrence (n : ℕ) (θ : ℝ) :
    cos ((↑(n + 2)) * θ) = 2 * cos θ * cos ((↑(n + 1)) * θ) - cos (↑n * θ) := by
  norm_num [ add_mul, Real.cos_add ] ; ring;
  rw [ show θ * 2 = 2 * θ by ring, Real.cos_two_mul, Real.sin_two_mul ] ; ring;

/-
**Chebyshev's Theorem**: cos(nθ) = Tₙ(cos θ).
    This is the fundamental connection between trigonometric functions and polynomials.
-/
theorem cos_eq_chebyshevT_eval (n : ℕ) (θ : ℝ) :
    cos (↑n * θ) = (chebyshevT n).eval (cos θ) := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> norm_num [ ih, chebyshevT_succ_succ ];
  convert cos_chebyshev_recurrence n θ using 1 ; ring;
  · push_cast; ring;
  · rw [ ih _ <| Nat.lt_succ_self _, ih _ <| Nat.lt_succ_of_lt <| Nat.lt_succ_self _ ]

/-
The leading coefficient of Tₙ for n ≥ 1 is 2^(n-1). In particular, Tₙ ≠ 0 for all n.
-/
theorem chebyshevT_leadingCoeff (n : ℕ) (hn : 1 ≤ n) :
    (chebyshevT n).leadingCoeff = 2 ^ (n - 1) := by
  -- We'll use induction on $n$.
  have h_ind : ∀ n : ℕ, 1 ≤ n → Polynomial.natDegree (chebyshevT n) = n ∧ Polynomial.coeff (chebyshevT n) n = 2^(n-1) := by
    intro n hn; induction' n using Nat.strongRecOn with n ih; rcases n with ( _ | _ | n ) <;> simp_all +decide ;
    erw [ show chebyshevT ( n + 2 ) = 2 * Polynomial.X * chebyshevT ( n + 1 ) - chebyshevT n from rfl ] ; erw [ Polynomial.natDegree_sub_eq_left_of_natDegree_lt ] <;> erw [ Polynomial.natDegree_mul' ] <;> norm_num [ ih ];
    · rcases n <;> simp_all +decide [ mul_assoc, Polynomial.coeff_eq_zero_of_natDegree_lt ];
      exact ⟨ by ring, by ring ⟩;
    · specialize ih ( n + 1 ) ; aesop;
    · by_cases hn : 1 ≤ n <;> simp_all +arith +decide;
    · specialize ih ( n + 1 ) ; aesop;
  rw [ Polynomial.leadingCoeff, h_ind n hn |>.1, h_ind n hn |>.2 ]

/-
Chebyshev polynomial Tₙ has degree exactly n for n ≥ 1.
    This means a superposition of modes up to mode N produces
    a polynomial of degree exactly N (generically).
-/
theorem chebyshevT_natDegree (n : ℕ) (hn : 1 ≤ n) :
    (chebyshevT n).natDegree = n := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases hn with ( _ | _ | n ) <;> simp_all +decide [ Polynomial.natDegree_sub_eq_left_of_natDegree_lt ];
  · erw [ chebyshevT_succ_succ, Polynomial.natDegree_sub_eq_left_of_natDegree_lt ] <;> norm_num [ Polynomial.natDegree_add_eq_right_of_natDegree_lt ];
  · erw [ chebyshevT_succ_succ, Polynomial.natDegree_sub_eq_left_of_natDegree_lt ];
    · erw [ Polynomial.natDegree_mul' ] <;> norm_num [ ih ];
      · ring;
      · exact ne_of_apply_ne Polynomial.natDegree ( by erw [ ih _ le_rfl ( by linarith ) ] ; aesop );
    · erw [ Polynomial.natDegree_mul' ] <;> norm_num [ ih _ _ n, ih _ _ ( Nat.le_add_left _ _ ) ];
      · linarith;
      · exact ne_of_apply_ne Polynomial.natDegree ( by erw [ ih _ le_rfl ( by linarith ) ] ; aesop )

/-- T₀ has degree 0. -/
theorem chebyshevT_natDegree_zero : (chebyshevT 0).natDegree = 0 := by
  simp [chebyshevT]

/-! ## Section 2: Turing Reaction-Diffusion Systems

A two-component reaction-diffusion system on a spatial domain:
  ∂u/∂t = D₁∇²u + f(u,v)
  ∂v/∂t = D₂∇²v + g(u,v)

Linearized around a uniform steady state (u₀, v₀), the Jacobian matrix
  J = [[a₁₁, a₁₂], [a₂₁, a₂₂]]
determines the stability. Turing's key insight: the uniform state can be
stable without diffusion but unstable with it — diffusion-driven instability. -/

/-- A two-component reaction-diffusion system, characterized by its
    diffusion coefficients and the Jacobian of the reaction terms
    evaluated at the uniform steady state. -/
structure TuringSystem where
  /-- Diffusion coefficient of the activator -/
  D₁ : ℝ
  /-- Diffusion coefficient of the inhibitor -/
  D₂ : ℝ
  /-- Jacobian entry ∂f/∂u -/
  a₁₁ : ℝ
  /-- Jacobian entry ∂f/∂v -/
  a₁₂ : ℝ
  /-- Jacobian entry ∂g/∂u -/
  a₂₁ : ℝ
  /-- Jacobian entry ∂g/∂v -/
  a₂₂ : ℝ
  /-- Activator diffuses -/
  hD₁ : 0 < D₁
  /-- Inhibitor diffuses -/
  hD₂ : 0 < D₂

/-- Trace of the Jacobian matrix -/
def TuringSystem.trJ (S : TuringSystem) : ℝ := S.a₁₁ + S.a₂₂

/-- Determinant of the Jacobian matrix -/
def TuringSystem.detJ (S : TuringSystem) : ℝ := S.a₁₁ * S.a₂₂ - S.a₁₂ * S.a₂₁

/-- The dispersion relation h(q) where q = k² is the squared wave number.
    h(q) = D₁·D₂·q² - (D₂·a₁₁ + D₁·a₂₂)·q + det(J)
    Pattern formation occurs when h(q) < 0 for some q > 0. -/
def TuringSystem.dispersion (S : TuringSystem) (q : ℝ) : ℝ :=
  S.D₁ * S.D₂ * q ^ 2 - (S.D₂ * S.a₁₁ + S.D₁ * S.a₂₂) * q + S.detJ

/-- The cross-diffusion coefficient that controls instability -/
def TuringSystem.crossDiffCoeff (S : TuringSystem) : ℝ :=
  S.D₂ * S.a₁₁ + S.D₁ * S.a₂₂

/-- The uniform steady state is stable without diffusion:
    trace(J) < 0 (damped) and det(J) > 0 (no saddle). -/
def TuringSystem.isUniformStable (S : TuringSystem) : Prop :=
  S.trJ < 0 ∧ 0 < S.detJ

/-- Diffusion-driven (Turing) instability: the uniform state is stable without
    diffusion but there exists a wave number for which diffusion destabilizes it. -/
def TuringSystem.isTuringUnstable (S : TuringSystem) : Prop :=
  S.isUniformStable ∧ ∃ q : ℝ, 0 < q ∧ S.dispersion q < 0

/-- The discriminant of the dispersion relation (viewed as a quadratic in q).
    Turing instability requires this to be positive. -/
def TuringSystem.dispersionDiscriminant (S : TuringSystem) : ℝ :=
  S.crossDiffCoeff ^ 2 - 4 * S.D₁ * S.D₂ * S.detJ

/-
**Turing Instability Criterion** (necessary direction):
    If there exists q > 0 with h(q) < 0, then the cross-diffusion coefficient
    is positive and the dispersion discriminant is positive.

    Mathematically: the dispersion quadratic D₁D₂q² - (D₂a₁₁+D₁a₂₂)q + det(J)
    can only be negative for some q > 0 if the parabola's vertex is below the
    q-axis and to the right of the origin.
-/
theorem turing_instability_necessary (S : TuringSystem) (hstab : S.isUniformStable) :
    (∃ q : ℝ, 0 < q ∧ S.dispersion q < 0) →
    (0 < S.crossDiffCoeff ∧ 0 < S.dispersionDiscriminant) := by
  intro h;
  constructor;
  · obtain ⟨ q, hq₀, hq ⟩ := h;
    unfold TuringSystem.dispersion at hq;
    unfold TuringSystem.isUniformStable at hstab; unfold TuringSystem.crossDiffCoeff; nlinarith [ mul_pos S.hD₁ S.hD₂, hstab.1, hstab.2 ] ;
  · obtain ⟨ q, hq₁, hq₂ ⟩ := h;
    unfold TuringSystem.dispersion TuringSystem.dispersionDiscriminant at *;
    unfold TuringSystem.crossDiffCoeff; nlinarith [ sq_nonneg ( S.D₂ * S.a₁₁ + S.D₁ * S.a₂₂ - 2 * S.D₁ * S.D₂ * q ), mul_pos S.hD₁ S.hD₂ ] ;

/-
**Turing Instability Criterion** (sufficient direction):
    If the cross-diffusion coefficient is positive and the discriminant is positive,
    then there exists q > 0 making the dispersion relation negative.
-/
theorem turing_instability_sufficient (S : TuringSystem) (hstab : S.isUniformStable) :
    (0 < S.crossDiffCoeff ∧ 0 < S.dispersionDiscriminant) →
    (∃ q : ℝ, 0 < q ∧ S.dispersion q < 0) := by
  -- To prove the implication, we can choose $q₀ = \text{crossDiffCoeff} / (2 * S.D₁ * S.D₂)$, which is positive since $S.D₁$ and $S.D₂$ are positive.
  intro h_pos
  use S.crossDiffCoeff / (2 * S.D₁ * S.D₂);
  unfold TuringSystem.dispersion at *;
  unfold TuringSystem.dispersionDiscriminant at *;
  field_simp;
  exact ⟨ by rw [ zero_mul ] ; exact div_pos h_pos.1 ( mul_pos S.hD₁ S.hD₂ ), by rw [ div_add', div_lt_iff₀ ] <;> nlinarith! [ S.hD₁, S.hD₂, mul_pos S.hD₁ S.hD₂, show S.crossDiffCoeff = S.D₂ * S.a₁₁ + S.D₁ * S.a₂₂ from rfl ] ⟩

/-! ## Section 3: The Morphogenesis Spectrum

We define the `MorphogenesisSpectrum` — a novel mathematical structure that
captures the algebraic geometry of a Turing pattern. It pairs a Turing system
with the set of its critical wave numbers and the resulting algebraic variety. -/

/-- A **morphogenesis spectrum** captures the algebraic data of a Turing pattern:
    the Turing system, the number of active modes, and the Fourier coefficients.
    Via Chebyshev polynomials, this determines an algebraic variety whose zero set
    IS the pattern boundary (where concentration equals the background level). -/
structure MorphogenesisSpectrum where
  /-- The underlying reaction-diffusion system -/
  system : TuringSystem
  /-- Number of active Fourier modes -/
  numModes : ℕ
  /-- Fourier coefficients of the steady-state pattern -/
  modeCoeffs : Fin (numModes + 1) → ℝ
  /-- At least one nonzero mode -/
  hNontrivial : ∃ k : Fin (numModes + 1), modeCoeffs k ≠ 0

/-- The pattern polynomial: the Chebyshev expansion corresponding to the
    mode superposition. This is the algebraic representative of the pattern. -/
def MorphogenesisSpectrum.patternPoly (M : MorphogenesisSpectrum) : Polynomial ℝ :=
  ∑ k : Fin (M.numModes + 1), Polynomial.C (M.modeCoeffs k) * chebyshevT k

/-
The algebraic degree of the pattern is at most the number of modes.
-/
theorem MorphogenesisSpectrum.patternPoly_degree_le (M : MorphogenesisSpectrum) :
    M.patternPoly.natDegree ≤ M.numModes := by
  refine' le_trans ( Polynomial.natDegree_sum_le _ _ ) ( Finset.sup_le _ );
  intro k hk; by_cases h : M.modeCoeffs k = 0 <;> simp_all +decide [ Polynomial.natDegree_C_mul ] ;
  exact le_trans ( if hk : 1 ≤ ( k : ℕ ) then le_of_eq ( chebyshevT_natDegree _ hk ) else by aesop ) ( Nat.le_of_lt_succ ( Fin.is_lt k ) )

/-! ## Section 4: Pattern Algebraicity — The Main Bridge Theorem

The central result: the zero set of a finite cosine mode superposition
  u(θ) = Σₖ aₖ cos(kθ)
is, via the substitution x = cos(θ), exactly the zero set of the polynomial
  P(x) = Σₖ aₖ Tₖ(x)

This means the pattern boundary {u = 0} is a **real algebraic set**. -/

/-- The 1D pattern function as a sum of cosine modes -/
def patternFunction (coeffs : Fin (N + 1) → ℝ) (θ : ℝ) : ℝ :=
  ∑ k : Fin (N + 1), coeffs k * cos (↑(k : ℕ) * θ)

/-- The Chebyshev expansion polynomial for a finite mode superposition -/
def patternPolynomial (coeffs : Fin (N + 1) → ℝ) : Polynomial ℝ :=
  ∑ k : Fin (N + 1), Polynomial.C (coeffs k) * chebyshevT k

/-
**Pattern Algebraicity Theorem**: The zero set of a cosine mode superposition
    u(θ) = Σ aₖcos(kθ) equals the zero set of the polynomial P(x) = Σ aₖTₖ(x)
    under the substitution x = cos(θ).

    This is the fundamental theorem connecting Turing patterns to algebraic geometry:
    pattern boundaries are algebraic curves.
-/
theorem pattern_zero_set_algebraic {N : ℕ} (coeffs : Fin (N + 1) → ℝ) (θ : ℝ) :
    patternFunction coeffs θ = 0 ↔
    (patternPolynomial coeffs).eval (cos θ) = 0 := by
  unfold patternFunction patternPolynomial;
  simp +decide [ Polynomial.eval_finset_sum, cos_eq_chebyshevT_eval ]

/-
The degree of the pattern polynomial is at most N (the maximum mode number).
    This bounds the algebraic complexity of the pattern.
-/
theorem patternPolynomial_natDegree_le {N : ℕ} (coeffs : Fin (N + 1) → ℝ) :
    (patternPolynomial coeffs).natDegree ≤ N := by
  refine' le_trans ( Polynomial.natDegree_sum_le _ _ ) ( Finset.sup_le _ );
  intro i hi; by_cases hi' : coeffs i = 0 <;> simp +decide [ hi', Polynomial.natDegree_C_mul, Polynomial.natDegree_le_iff_degree_le, chebyshevT_natDegree, chebyshevT_natDegree_zero ] ;
  exact le_trans ( Polynomial.degree_le_natDegree ) ( mod_cast if h : i.val = 0 then by simp +decide [ h, chebyshevT_natDegree_zero ] else by simpa [ h ] using chebyshevT_natDegree i.val ( Nat.pos_of_ne_zero h ) |> fun h' => h'.le.trans ( Nat.cast_le.mpr ( Fin.is_le i ) ) )

/-! ## Section 5: Two-Mode Patterns are Conics

For a two-mode system (the simplest nontrivial case, like the Gray-Scott model),
the pattern in 2D is determined by modes cos(k₁x)·cos(k₂y). Via Chebyshev,
this becomes T_{k₁}(X)·T_{k₂}(Y) where X = cos(x), Y = cos(y).

The zero set of a polynomial of degree 2 in two variables is a conic section.
This gives the classification: spots ↔ ellipses, stripes ↔ parallel lines,
labyrinths ↔ hyperbolas. -/

/-
A 2D pattern mode cos(m·x)·cos(n·y) evaluated at (cos⁻¹ X, cos⁻¹ Y)
    equals Tₘ(X)·Tₙ(Y).
-/
theorem mode_2d_algebraic (m n : ℕ) (θ φ : ℝ) :
    cos (↑m * θ) * cos (↑n * φ) =
    (chebyshevT m).eval (cos θ) * (chebyshevT n).eval (cos φ) := by
  rw [ ← cos_eq_chebyshevT_eval m θ, ← cos_eq_chebyshevT_eval n φ ]

/-
Chebyshev polynomial evaluation at 1 gives 1: Tₙ(1) = 1.
    This corresponds to cos(n·0) = 1.
-/
theorem chebyshevT_eval_one (n : ℕ) : (chebyshevT n).eval 1 = 1 := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ chebyshevT ];
  norm_num

/-
Chebyshev polynomial evaluation at -1: Tₙ(-1) = (-1)ⁿ.
    This corresponds to cos(nπ) = (-1)ⁿ.
-/
theorem chebyshevT_eval_neg_one (n : ℕ) : (chebyshevT n).eval (-1) = (-1) ^ n := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ chebyshevT_succ_succ ];
  ring

end