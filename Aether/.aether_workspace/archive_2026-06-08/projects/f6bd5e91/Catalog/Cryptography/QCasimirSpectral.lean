import Mathlib

noncomputable section

open Finset BigOperators

/-!
# q-Casimir Spectral Theory: Algebraic Foundations

This module develops the algebraic foundations of q-Casimir spectral theory,
establishing key properties of q-integers, q-Casimir eigenvalues, and spectral gaps.

The central results are:
1. A closed-form expression for spectral gaps
2. A recurrence relation revealing the spectrum as a discrete dynamical system
3. The q-integer multiplication formula establishing a structural parallel
   with the Euler product of the Riemann zeta function
-/

/-- The q-integer `[n]_q = 1 + q + q^2 + ... + q^{n-1}`.
    Uses the polynomial (sum) form rather than the rational form `(1-q^n)/(1-q)`
    to avoid division. -/
def qInt (q : ℝ) (n : ℕ) : ℝ := ∑ i ∈ Finset.range n, q ^ i

/-- The q-Casimir eigenvalue `λ_n(q) = [n]_q * [n+1]_q`. -/
def qCasimirEigenvalue (q : ℝ) (n : ℕ) : ℝ := qInt q n * qInt q (n + 1)

/-- The spectral gap `Δ_n = λ_{n+1}(q) - λ_n(q)`. -/
def spectralGap (q : ℝ) (n : ℕ) : ℝ :=
  qCasimirEigenvalue q (n + 1) - qCasimirEigenvalue q n

/-- State of the spectral gap dynamical system: tracks the current gap
    value and the running power `q^n`. This 2D system generates the
    entire q-Casimir spectral gap sequence from a single initial condition. -/
structure SpectralGapDynState where
  gap : ℝ
  power : ℝ

/-- One step of the spectral gap dynamical system. -/
def spectralGapStep (q : ℝ) (s : SpectralGapDynState) : SpectralGapDynState :=
  { gap := q ^ 2 * s.gap + s.power * q * (1 + q),
    power := s.power * q }

-- ============================================================
-- Section 1: Basic q-integer identities
-- ============================================================

@[simp] theorem qInt_zero (q : ℝ) : qInt q 0 = 0 := by
  unfold qInt; simp

@[simp] theorem qInt_one (q : ℝ) : qInt q 1 = 1 := by
  unfold qInt; simp

/-- The fundamental recurrence: `[n+1]_q = [n]_q + q^n` -/
theorem qInt_succ (q : ℝ) (n : ℕ) : qInt q (n + 1) = qInt q n + q ^ n := by
  unfold qInt; rw [Finset.sum_range_succ]

/-
Alternative recurrence: `[n+1]_q = 1 + q * [n]_q`.
    Connects to evaluation of a geometric polynomial at q.
-/
theorem qInt_succ_alt (q : ℝ) (n : ℕ) : qInt q (n + 1) = 1 + q * qInt q n := by
  unfold qInt; simp +decide [ Finset.sum_range_succ' ] ; ring;
  rw [ Finset.mul_sum _ _ _ ]

/-
============================================================
Section 2: Positivity
============================================================

q-integers are positive for positive q and `n ≥ 1`.
-/
theorem qInt_pos {q : ℝ} (hq : q > 0) {n : ℕ} (hn : n ≥ 1) : qInt q n > 0 := by
  exact Finset.sum_pos ( fun _ _ => pow_pos hq _ ) ⟨ _, Finset.mem_range.mpr hn ⟩

/-
q-Casimir eigenvalues are nonneg for nonneg q.
-/
theorem qCasimir_nonneg {q : ℝ} (hq : q ≥ 0) (n : ℕ) :
    qCasimirEigenvalue q n ≥ 0 := by
  exact mul_nonneg ( Finset.sum_nonneg fun _ _ => pow_nonneg hq _ ) ( Finset.sum_nonneg fun _ _ => pow_nonneg hq _ )

/-
============================================================
Section 3: The shift identity (algebraic heart)
============================================================

The telescoping shift identity: `[n+2]_q - [n]_q = q^n * (1 + q)`.
    This is the algebraic key to the entire spectral gap theory.
-/
theorem qInt_shift (q : ℝ) (n : ℕ) :
    qInt q (n + 2) - qInt q n = q ^ n * (1 + q) := by
  unfold qInt; norm_num [ Finset.sum_range_succ ] ; ring;

/-
============================================================
Section 4: Spectral gap closed form and recurrence
============================================================

**Spectral gap closed form**: `Δ_n = [n+1]_q * q^n * (1+q)`.

    The spectral gap factorizes into the q-integer `[n+1]_q`,
    the geometric factor `q^n`, and the universal factor `(1+q)`.

    Proof: Factor `Δ_n = [n+1]_q * ([n+2]_q - [n]_q)`, then apply `qInt_shift`.
-/
theorem spectral_gap_closed_form (q : ℝ) (n : ℕ) :
    spectralGap q n = qInt q (n + 1) * (q ^ n * (1 + q)) := by
  unfold spectralGap qCasimirEigenvalue;
  rw [ ← qInt_shift ] ; ring

/-
**Spectral gap recurrence**: `Δ_{n+1} = q^2 * Δ_n + q^{n+1} * (1+q)`.

    The spectral gap sequence satisfies a first-order linear recurrence
    with a geometric forcing term.
-/
theorem spectral_gap_recurrence (q : ℝ) (n : ℕ) :
    spectralGap q (n + 1) = q ^ 2 * spectralGap q n + q ^ (n + 1) * (1 + q) := by
  convert spectral_gap_closed_form q ( n + 1 ) using 1 ; ring;
  rw [ spectral_gap_closed_form, qInt_succ_alt ] ; ring;
  rw [ show 2 + n = n + 2 by ring ] ; rw [ qInt_succ_alt, qInt_succ_alt ] ; ring;

/-
============================================================
Section 5: Monotonicity of eigenvalues
============================================================

Spectral gaps are strictly positive for positive q.
-/
theorem spectral_gap_pos {q : ℝ} (hq : q > 0) (n : ℕ) :
    spectralGap q n > 0 := by
  rw [ spectral_gap_closed_form ] ; exact mul_pos ( qInt_pos hq ( by linarith ) ) ( by positivity ) ;

/-
**Strict monotonicity** of q-Casimir eigenvalues for q > 0.
-/
theorem qCasimir_strict_mono {q : ℝ} (hq : q > 0) (n : ℕ) :
    qCasimirEigenvalue q (n + 1) > qCasimirEigenvalue q n := by
  exact lt_of_sub_pos ( spectral_gap_pos hq n )

/-
============================================================
Section 6: q-integer multiplication formula
============================================================

Additive splitting of q-integers: `[a+b]_q = [a]_q + q^a * [b]_q`.
-/
theorem qInt_add (q : ℝ) (a b : ℕ) :
    qInt q (a + b) = qInt q a + q ^ a * qInt q b := by
  -- We proceed by induction on $b$.
  induction' b with b ih generalizing a;
  · norm_num [ qInt ];
  · rw [ Nat.add_succ, qInt_succ, ih, qInt_succ ] ; ring

/-
**q-integer multiplication formula**: `[n*m]_q = [n]_q * [m]_{q^n}`.

    This deep algebraic identity shows q-integers respect a
    "twisted multiplication" where the deformation parameter is raised
    to a power. It parallels the Euler product of the Riemann zeta function.
-/
theorem qInt_mul_formula (q : ℝ) (n m : ℕ) :
    qInt q (n * m) = qInt q n * qInt (q ^ n) m := by
  induction' m with m ih;
  · simp +decide [ qInt ];
  · rw [ Nat.mul_succ, qInt_add ];
    rw [ ih, qInt_succ ] ; ring

-- ============================================================
-- Section 7: Dynamical systems bridge
-- ============================================================

/-- Iterate the spectral gap step function n times from initial state. -/
def spectralGapIterate (q : ℝ) (n : ℕ) : SpectralGapDynState :=
  (spectralGapStep q)^[n] ⟨1 + q, 1⟩

/-
The spectral gap dynamical system faithfully generates the spectral gaps:
    after n iterations from initial state `(1+q, 1)`, the gap component
    equals `Δ_n` and the power component equals `q^n`.
-/
theorem spectral_dynamics_faithful (q : ℝ) (n : ℕ) :
    (spectralGapIterate q n).gap = spectralGap q n ∧
    (spectralGapIterate q n).power = q ^ n := by
  induction n <;> simp_all +decide [ spectralGapIterate, Function.iterate_succ_apply' ];
  · unfold spectralGap qCasimirEigenvalue qInt; norm_num; ring;
  · simp_all +decide [ spectralGapStep, pow_succ, spectral_gap_recurrence ]

/-
============================================================
Section 8: Classical limit
============================================================

At q = 1 (classical limit), the q-integer reduces to n.
-/
theorem qInt_classical (n : ℕ) : qInt 1 n = ↑n := by
  unfold qInt; norm_num;

/-
At q = 1, the q-Casimir eigenvalue reduces to `n*(n+1)`,
    the classical SU(2) Casimir eigenvalue.
-/
theorem qCasimir_classical (n : ℕ) :
    qCasimirEigenvalue 1 n = ↑n * (↑n + 1) := by
  unfold qCasimirEigenvalue;
  norm_num [ qInt ]

/-
============================================================
Section 9: Spectral gap ratio
============================================================

The spectral gap ratio expressed in terms of q-integer ratios.
-/
theorem spectral_gap_ratio_formula (q : ℝ) (n : ℕ)
    (hn : qInt q (n + 1) ≠ 0) :
    spectralGap q (n + 1) / spectralGap q n =
    q * (qInt q (n + 2) / qInt q (n + 1)) := by
  by_cases hq : q = 0 <;> simp_all +decide [ spectral_gap_closed_form, mul_assoc, mul_comm, mul_left_comm, div_eq_mul_inv ];
  by_cases h : 1 + q = 0 <;> simp_all +decide [ pow_succ', mul_assoc, mul_left_comm ];
  · norm_num [ show q = -1 by linarith, qInt ] at *;
    grind;
  · ring

end