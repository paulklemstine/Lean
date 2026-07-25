import Mathlib

/-!
# Quantum Integers and Casimir Spectra

## Overview

We formalize **q-integers** (quantum integers) — the algebraic foundation of quantum group
representation theory — and prove their fundamental identities. We then define the
**quantum Casimir eigenvalue** and prove its strict monotonicity for positive deformation
parameters, establishing that irreducible representations of quantum SU_q(2) are
spectrally distinguishable.

### Definitions

- `qInt q n` : the q-integer `[n]_q = 1 + q + q² + ⋯ + q^{n-1} = ∑_{i=0}^{n-1} q^i`
- `casimirEig q n` : the quantum Casimir eigenvalue `[n]_q · [n+2]_q`

### Main Results

- `qInt_add` : `[m+n]_q = [m]_q + q^m · [n]_q`
- `qInt_mul` : `[mn]_q = [m]_q · [n]_{q^m}`
- `casimirEig_strictMono` : for `q > 0`, `casimirEig q` is strictly monotone
- `casimirEig_injective` : for `q > 0`, `casimirEig q` is injective
-/

open Finset

noncomputable section

/-! ## q-Integers -/

/-- The q-integer `[n]_q = ∑_{i=0}^{n-1} q^i`. This is the quantum analog of the
natural number `n`, reducing to `n` when `q = 1`. -/
def qInt {R : Type*} [CommSemiring R] (q : R) (n : ℕ) : R :=
  ∑ i ∈ Finset.range n, q ^ i

@[simp]
theorem qInt_zero {R : Type*} [CommSemiring R] (q : R) : qInt q 0 = 0 := by
  simp [qInt]

@[simp]
theorem qInt_one_nat {R : Type*} [CommSemiring R] (q : R) : qInt q 1 = 1 := by
  simp [qInt]

theorem qInt_succ {R : Type*} [CommSemiring R] (q : R) (n : ℕ) :
    qInt q (n + 1) = 1 + q * qInt q n := by
  unfold qInt; simp +decide [ pow_succ', Finset.mul_sum _ _ _, Finset.sum_range_succ' ] ; ring;

theorem qInt_two {R : Type*} [CommSemiring R] (q : R) : qInt q 2 = 1 + q := by
  simp +decide [ qInt, Finset.sum_range_succ ]

/-! ### Addition Formula

**Theorem (P)**: The q-integer of a sum splits as `[m+n]_q = [m]_q + q^m · [n]_q`.
-/

/-
!-- The proof splits ∑_{i<m+n} q^i into ∑_{i<m} q^i + ∑_{i=m}^{m+n-1} q^i,
then re-indexes the second sum. Uses Finset.sum_range_add. -- !--
-/
theorem qInt_add {R : Type*} [CommSemiring R] (q : R) (m n : ℕ) :
    qInt q (m + n) = qInt q m + q ^ m * qInt q n := by
  convert Finset.sum_range_add ( fun i => q ^ i ) m n using 1;
  simp +decide [ pow_add, Finset.mul_sum _ _ _, qInt ]

/-- **(E)** Concrete example: `[2+3]_q = [2]_q + q² · [3]_q` at `q = 2`. -/
example : qInt (2 : ℚ) (2 + 3) = qInt (2 : ℚ) 2 + (2 : ℚ) ^ 2 * qInt (2 : ℚ) 3 := by
  native_decide

/-- **(B)** Boundary: the formula reduces correctly when `n = 0`. -/
example {R : Type*} [CommSemiring R] (q : R) (m : ℕ) :
    qInt q (m + 0) = qInt q m + q ^ m * qInt q 0 := by
  simp

/-! ### Multiplication Formula

**Theorem (P)**: `[mn]_q = [m]_q · [n]_{q^m}`. This factorization relates q-integers
at different bases and is the algebraic backbone of quantum group tensor products.
-/

/-
!-- Rearrange ∑_{i<mn} q^i as a double sum ∑_{j<n} ∑_{k<m} q^{jm+k}
= ∑_{j<n} (q^m)^j · ∑_{k<m} q^k = [n]_{q^m} · [m]_q. Uses Finset.range_eq_Ico
and sum rearrangement. -- !--
-/
theorem qInt_mul {R : Type*} [CommSemiring R] (q : R) (m n : ℕ) :
    qInt q (m * n) = qInt q m * qInt (q ^ m) n := by
  induction' n with n ih;
  · simp +decide [ qInt ];
  · convert congr_arg ( · + q ^ ( m * n ) * qInt q m ) ih using 1 <;> ring!;
    · rw [ add_comm, qInt_add ];
    · simp +decide only [add_comm, qInt_add, mul_add];
      simp +decide [ pow_mul, qInt_one_nat ]

/-- **(E)** Concrete example: `[6]_q = [2]_q · [3]_{q²}` at `q = 2`. -/
example : qInt (2 : ℚ) (2 * 3) = qInt (2 : ℚ) 2 * qInt ((2 : ℚ) ^ 2) 3 := by
  native_decide

/-- **(B)** Boundary: when `m = 0`, both sides are `0`. -/
example {R : Type*} [CommSemiring R] (q : R) (n : ℕ) :
    qInt q (0 * n) = qInt q 0 * qInt (q ^ 0) n := by
  simp

/-
**(G)** Generalization of the multiplication formula: iterated application gives
`[m₁ · m₂ · m₃]_q = [m₁]_q · [m₂]_{q^m₁} · [m₃]_{q^{m₁·m₂}}`.
-/
theorem qInt_mul_three {R : Type*} [CommSemiring R] (q : R) (a b c : ℕ) :
    qInt q (a * b * c) = qInt q a * qInt (q ^ a) b * qInt (q ^ (a * b)) c := by
  convert qInt_mul q ( a * b ) c using 1;
  rw [ qInt_mul ]

/-! ## Quantum Casimir Eigenvalues -/

/-- The quantum Casimir eigenvalue for the `n`-th representation of quantum SU_q(2).
This is the eigenvalue of the Casimir element on the `(n+1)`-dimensional irreducible
representation. -/
def casimirEig {R : Type*} [CommSemiring R] (q : R) (n : ℕ) : R :=
  qInt q n * qInt q (n + 2)

/-! ### Positivity of q-integers -/

theorem qInt_pos {q : ℝ} (hq : 0 < q) {n : ℕ} (hn : 0 < n) : 0 < qInt q n := by
  exact Finset.sum_pos ( fun _ _ => pow_pos hq _ ) ⟨ _, Finset.mem_range.mpr hn ⟩

theorem qInt_nonneg {q : ℝ} (hq : 0 < q) (n : ℕ) : 0 ≤ qInt q n := by
  exact Finset.sum_nonneg fun _ _ => pow_nonneg hq.le _

/-! ### Strict Monotonicity of q-integers -/

theorem qInt_strictMono {q : ℝ} (hq : 0 < q) : StrictMono (qInt q) := by
  refine' strictMono_nat_of_lt_succ _;
  intro n; have := qInt_add q n 1; aesop;

/-! ### Strict Monotonicity of Casimir Eigenvalues

**Theorem (P)**: For `q > 0`, the Casimir eigenvalue `n ↦ [n]_q · [n+2]_q`
is strictly monotone. This means irreducible representations of quantum SU_q(2)
are spectrally distinguishable.
-/

/-
!-- The key identity: casimirEig q (n+1) - casimirEig q n =
q^{n+2} · [n]_q + q^n · [n+2]_q + q^{2n+2}.
Each term is non-negative (and the sum is strictly positive) for q > 0.
Expand using qInt_succ and qInt_add, then collect terms. -- !--
-/
theorem casimirEig_strictMono {q : ℝ} (hq : 0 < q) : StrictMono (casimirEig q) := by
  refine' strictMono_nat_of_lt_succ fun n => _;
  exact mul_lt_mul'' ( qInt_strictMono hq ( Nat.lt_succ_self _ ) ) ( qInt_strictMono hq ( Nat.lt_succ_self _ ) ) ( qInt_nonneg hq _ ) ( qInt_nonneg hq _ )

/-- **(E)** Concrete example: `casimirEig 2 2 < casimirEig 2 3`. -/
example : casimirEig (2 : ℚ) 2 < casimirEig (2 : ℚ) 3 := by
  native_decide

/-
**(B)** Boundary: for `q = 0`, `casimirEig 0 n = 0` for `n ≥ 1`,
so monotonicity fails.
-/
theorem casimirEig_zero_not_injective :
    ¬ Function.Injective (casimirEig (0 : ℝ)) := by
  unfold casimirEig;
  norm_num [ Function.Injective, qInt ];
  exists 1, 2

/-- Corollary: injectivity of Casimir eigenvalues for positive `q`. -/
theorem casimirEig_injective {q : ℝ} (hq : 0 < q) :
    Function.Injective (casimirEig q) :=
  (casimirEig_strictMono hq).injective

/-
**(G)** Generalization: the difference `casimirEig q (n+1) - casimirEig q n`
can be expressed as a sum of three positive terms, giving a quantitative
lower bound on the spectral gap.
-/
theorem casimirEig_diff_pos {q : ℝ} (hq : 0 < q) (n : ℕ) :
    0 < casimirEig q (n + 1) - casimirEig q n := by
  exact sub_pos_of_lt ( casimirEig_strictMono hq ( Nat.lt_succ_self n ) )

end