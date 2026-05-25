import Mathlib

/-!
# Krawtchouk Polynomials for Quantum Coding Theory

Krawtchouk polynomials K_j(x; n) are the fundamental discrete orthogonal
polynomials appearing in coding theory. They form the character table of the
binary Hamming association scheme H(n, 2) and are the kernel of the
MacWilliams transform relating a code's weight enumerator to its dual.

## Main Definitions

* `krawtchouk` — K_j(x; n) = Σ_{l=0}^{j} (-1)^l · C(x,l) · C(n-x, j-l)
* `krawtchoukReal` — real-valued version for weight enumerator analysis

## Main Results

* `krawtchouk_zero_index` — K_0(x; n) = 1
* `krawtchouk_at_zero` — K_j(0; n) = C(n, j)
* `krawtchouk_one` — K_1(x; n) = n - 2x
* `krawtchouk_at_n` — K_j(n; n) = (-1)^j · C(n, j)
* `krawtchouk_eigenvalue_hamming` — eigenvalue interpretation

## References

* MacWilliams, F.J. and Sloane, N.J.A. "The Theory of Error-Correcting Codes"
* Shor, P.W. and Laflamme, R. "Quantum Analog of the MacWilliams Identities"
-/

open Finset BigOperators Nat

/-! ## Section 1: Definition -/

/-- The Krawtchouk polynomial K_j(x; n) for binary codes of length n.
    K_j(x; n) = Σ_{l=0}^{j} (-1)^l · C(x, l) · C(n-x, j-l)

    This is the standard form from MacWilliams-Sloane. The polynomial gives
    the eigenvalue of the j-th distance matrix of the Hamming scheme on the
    eigenspace indexed by x. -/
def krawtchouk (n j x : ℕ) : ℤ :=
  ∑ l ∈ Finset.range (j + 1),
    (-1 : ℤ) ^ l * (x.choose l : ℤ) * ((n - x).choose (j - l) : ℤ)

/-- Real-valued Krawtchouk polynomial. -/
noncomputable def krawtchoukReal (n j x : ℕ) : ℝ := (krawtchouk n j x : ℝ)

/-! ## Section 2: Basic Evaluations -/

/-- **K_0(x; n) = 1**: The zeroth Krawtchouk polynomial is identically 1.
    This is because the sum has a single term with l=0. -/
theorem krawtchouk_zero_index (n x : ℕ) : krawtchouk n 0 x = 1 := by
  simp [krawtchouk]

/-
**K_j(0; n) = C(n, j)**: Evaluating at x=0 gives the binomial coefficient.
    When x=0, C(0, l) = 0 for l ≥ 1, so only the l=0 term survives.
-/
theorem krawtchouk_at_zero (n j : ℕ) : krawtchouk n j 0 = (n.choose j : ℤ) := by
  unfold krawtchouk;
  rw [ Finset.sum_range_succ' ] ; aesop

/-
**K_1(x; n) = n - 2x**: The first Krawtchouk polynomial is linear.
    Proof: K_1(x;n) = C(n-x, 1) - C(x, 1) · C(n-x, 0) = (n-x) - x = n - 2x.
-/
theorem krawtchouk_one (n x : ℕ) (hx : x ≤ n) :
    krawtchouk n 1 x = (n : ℤ) - 2 * (x : ℤ) := by
  unfold krawtchouk;
  norm_num [ Finset.sum_range_succ ] ; linarith [ Nat.sub_add_cancel hx ]

/-
**K_j(n; n) = (-1)^j · C(n, j)**: Evaluation at x = n.
    When x = n, C(n-n, j-l) = C(0, j-l) = δ_{l,j}, so only l = j survives.
-/
theorem krawtchouk_at_n (n j : ℕ) (hj : j ≤ n) :
    krawtchouk n j n = (-1 : ℤ) ^ j * (n.choose j : ℤ) := by
  unfold krawtchouk;
  simp +decide [ Finset.sum_range_succ, Nat.choose_eq_zero_of_lt ];
  exact Finset.sum_eq_zero fun x hx => by rw [ Nat.choose_eq_zero_of_lt ( Nat.sub_pos_of_lt ( Finset.mem_range.mp hx ) ) ] ; ring;

/-! ## Section 3: Algebraic Properties -/

/-
The Krawtchouk polynomial K_j(x; n) for j > n is zero.
    This is because C(n-x, j-l) = 0 when j - l > n - x for all valid l.
-/
theorem krawtchouk_eq_zero_of_gt (n j x : ℕ) (hj : n < j) (hx : x ≤ n) :
    krawtchouk n j x = 0 := by
  have h_zero : ∀ l, l ≤ j → (-1 : ℤ)^l * (x.choose l : ℤ) * ((n - x).choose (j - l) : ℤ) = 0 := by
    intro l hl; by_cases hl' : l ≤ x <;> simp_all +decide [ Nat.choose_eq_zero_of_lt ] ;
    exact Or.inr ( Nat.choose_eq_zero_of_lt ( by omega ) );
  exact Finset.sum_eq_zero fun l hl => h_zero l <| Finset.mem_range_succ_iff.mp hl

/-- The eigenvalue connection: K_1(j; n) = n - 2j.
    The first-distance matrix of H(n,2) has eigenvalue n - 2j on eigenspace j.
    This connects quantum weight analysis to spectral graph theory. -/
theorem krawtchouk_eigenvalue_hamming (n j : ℕ) (hj : j ≤ n) :
    krawtchouk n 1 j = (n : ℤ) - 2 * (j : ℤ) :=
  krawtchouk_one n j hj

/-! ## Section 4: Computational Verification

These verify our definition against known values. While proved by `native_decide`,
they serve as correctness checks for the definition. -/

/-- K_2(1; 5) = C(4,2) - C(1,1)·C(4,1) + C(1,2)·C(4,0) = 6 - 4 + 0 = 2 -/
example : krawtchouk 5 2 1 = 2 := by native_decide

/-- K_2(2; 5) = C(3,2) - C(2,1)·C(3,1) + C(2,2)·C(3,0) = 3 - 6 + 1 = -2 -/
example : krawtchouk 5 2 2 = -2 := by native_decide

/-- K_3(1; 7) = C(6,3) - C(1,1)·C(6,2) + C(1,2)·C(6,1) - C(1,3)·C(6,0)
    = 20 - 15 + 0 - 0 = 5 -/
example : krawtchouk 7 3 1 = 5 := by native_decide

/-- Verification: K_1(0; 5) = 5 = C(5,1) -/
example : krawtchouk 5 1 0 = 5 := by native_decide

/-- Verification: K_1(3; 7) = 7 - 6 = 1 -/
example : krawtchouk 7 1 3 = 1 := by native_decide