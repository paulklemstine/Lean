/-
Copyright (c) 2025. All rights reserved.

# Quantitative ABC Threshold for Beal Impossibility

## Main Results

This file formalizes the **ABC threshold calculus** for Beal's conjecture:
given an integer-ABC hypothesis at strength `K` (i.e., `c ≤ rad(abc)^K`
for all coprime `a + b = c`), we derive explicit regions in exponent space
where no primitive Beal solution can exist.

The central theorem `abc_int_implies_no_primitive_beal_of_uniform_exponent_bound`
shows that `IntAbcBound K` and `3 * K < n` together imply no primitive
solution with all exponents `≥ n`.

## Key Results

1. `IntAbcBound` — the integer ABC hypothesis parameterized by K
2. `rad_of_pow_product` — radical of A^x · B^y · C^z = radical(A·B·C)
3. `abc_int_gives_product_bound_general` — C^z ≤ (A·B·C)^K under IntAbcBound K
4. `abc_int_implies_no_primitive_beal_of_uniform_exponent_bound` — the threshold theorem
5. Concrete corollaries for K=2 and K=3
-/
import Mathlib

open Nat UniqueFactorizationMonoid

/-! ## Definitions -/

/-- The **integer ABC bound** at strength `K`:
for all coprime positive `a, b` with `a + b = c`,
we have `c ≤ rad(abc)^K`. -/
def IntAbcBound (K : ℕ) : Prop :=
  ∀ a b c : ℕ,
    0 < a → 0 < b → 0 < c →
    Nat.Coprime a b →
    a + b = c →
    c ≤ (radical (a * b * c)) ^ K

/-! ## Radical Lemmas -/

/-- Radical is invariant under positive powers. -/
theorem radical_pow_eq' (n : ℕ) {k : ℕ} (hk : k ≠ 0) :
    radical (n ^ k) = radical n :=
  UniqueFactorizationMonoid.radical_pow n hk

/-- Radical is multiplicative on coprime arguments. -/
theorem radical_mul_coprime' {a b : ℕ} (hab : Nat.Coprime a b) :
    radical (a * b) = radical a * radical b :=
  UniqueFactorizationMonoid.radical_mul (Nat.coprime_iff_isRelPrime.mp hab)

/-- Radical divides its argument. -/
theorem radical_dvd_self' (n : ℕ) : radical n ∣ n :=
  UniqueFactorizationMonoid.radical_dvd_self

/-
For pairwise coprime A, B, C with positive exponents,
`rad(A^x · B^y · C^z) = rad(A · B · C)`.
-/
theorem rad_of_pow_product
    {A B C x y z : ℕ}
    (hAB : Nat.Coprime A B) (hAC : Nat.Coprime A C) (hBC : Nat.Coprime B C)
    (hx : x ≠ 0) (hy : y ≠ 0) (hz : z ≠ 0) :
    radical (A ^ x * B ^ y * C ^ z) = radical (A * B * C) := by
  -- Expand using radical_mul_coprime' and radical_pow_eq'.
  have h_rad_expansion : radical (A^x * B^y * C^z) = radical (A^x * B^y) * radical (C^z) ∧ radical (A * B * C) = radical (A * B) * radical C := by
    apply And.intro;
    · grind +suggestions;
    · apply radical_mul_coprime';
      apply_rules [ Nat.Coprime.mul_left, Nat.Coprime.symm ];
  have h_rad_expansion' : radical (A^x * B^y) = radical (A^x) * radical (B^y) ∧ radical (A * B) = radical A * radical B := by
    apply And.intro;
    · apply radical_mul_coprime';
      exact hAB.pow _ _;
    · exact?;
  rw [ h_rad_expansion.1, h_rad_expansion.2, h_rad_expansion'.1, h_rad_expansion'.2, radical_pow_eq' A hx, radical_pow_eq' B hy, radical_pow_eq' C hz ]

/-! ## ABC to Product Bound -/

/-
Under `IntAbcBound K`, a pairwise coprime Beal solution satisfies
`C^z ≤ (A·B·C)^K`.
-/
theorem abc_int_gives_product_bound_general
    (K : ℕ)
    (hABC : IntAbcBound K)
    {A B C x y z : ℕ}
    (hA : 0 < A) (hB : 0 < B) (hC : 0 < C)
    (hx : 0 < x) (hy : 0 < y) (hz : 0 < z)
    (hAB : Nat.Coprime A B) (hAC : Nat.Coprime A C) (hBC : Nat.Coprime B C)
    (hEq : A ^ x + B ^ y = C ^ z) :
    C ^ z ≤ (A * B * C) ^ K := by
  have := hABC ( A^x ) ( B^y ) ( C^z ) ?_ ?_ ?_ ?_ ?_ <;> simp_all +decide [ pow_succ' ];
  · refine le_trans this ?_;
    gcongr;
    have h_rad_le : radical (A ^ x * B ^ y * C ^ z) ∣ A * B * C := by
      have h_rad_le : radical (A ^ x * B ^ y * C ^ z) = radical (A * B * C) := by
        apply rad_of_pow_product hAB hAC hBC hx.ne' hy.ne' hz.ne';
      exact h_rad_le.symm ▸ radical_dvd_self' _;
    exact Nat.le_of_dvd ( by positivity ) h_rad_le;
  · assumption

/-! ## Base Size Bounds -/

/-
In `A^x + B^y = C^z`, we have `A^x < C^z`.
-/
theorem beal_Ax_lt' {A B C x y z : ℕ}
    (hB : 0 < B) (hy : 0 < y)
    (hEq : A ^ x + B ^ y = C ^ z) :
    A ^ x < C ^ z := by
  linarith [ pow_pos hB y ]

/-
In `A^x + B^y = C^z`, we have `B^y < C^z`.
-/
theorem beal_By_lt' {A B C x y z : ℕ}
    (hA : 0 < A) (hx : 0 < x)
    (hEq : A ^ x + B ^ y = C ^ z) :
    B ^ y < C ^ z := by
  exact hEq ▸ Nat.lt_add_of_pos_left ( pow_pos hA _ )

/-- `C ≤ C^z` for `z ≠ 0`. -/
theorem base_le_pow' {C z : ℕ} (hz : z ≠ 0) :
    C ≤ C ^ z :=
  Nat.le_self_pow hz _

/-
`A * B * C < C ^ (3 * z)` in a Beal equation.
-/
theorem beal_product_lt_cube' {A B C x y z : ℕ}
    (hA : 0 < A) (hB : 0 < B) (hC : 0 < C)
    (hx : 0 < x) (hy : 0 < y) (hz : 0 < z)
    (hEq : A ^ x + B ^ y = C ^ z) :
    A * B * C < C ^ (3 * z) := by
  -- Since $A$ and $B$ are positive integers, we have $A < C^z$ and $B < C^z$.
  have hA_lt_Cz : A < C ^ z := by
    exact lt_of_le_of_lt ( Nat.le_self_pow hx.ne' _ ) ( hEq ▸ Nat.lt_add_of_pos_right ( pow_pos hB _ ) )
  have hB_lt_Cz : B < C ^ z := by
    exact lt_of_le_of_lt ( Nat.le_self_pow hy.ne' _ ) ( hEq ▸ Nat.lt_add_of_pos_left ( pow_pos hA _ ) );
  -- Since $C$ is a positive integer, we have $C \le C^z$.
  have hC_le_Cz : C ≤ C ^ z := by
    exact Nat.le_self_pow hz.ne' _;
  rw [ show 3 * z = z + z + z by ring, pow_add, pow_add ] ; nlinarith [ mul_lt_mul_of_pos_left hA_lt_Cz hB, mul_lt_mul_of_pos_left hB_lt_Cz hC ]

/-
**C ≥ 2 is automatic** in any Beal equation with positive bases.
-/
theorem beal_C_ge_2' {A B C x y z : ℕ}
    (hA : 0 < A) (hB : 0 < B)
    (hx : 0 < x) (hy : 0 < y) (hz : 0 < z)
    (hEq : A ^ x + B ^ y = C ^ z) :
    2 ≤ C := by
  exact le_of_not_gt fun h => by interval_cases C <;> cases z <;> norm_num at * <;> linarith [ pow_pos hA x, pow_pos hB y ] ;

/-
`(ABC)^n < C^(3z)` when each base is smaller than `C^z`.
-/
theorem beal_product_pow_bound {A B C x y z n : ℕ}
    (hA : 0 < A) (hB : 0 < B) (hC : 0 < C)
    (hx : n ≤ x) (hy : n ≤ y) (hz : n ≤ z)
    (hn : 0 < n)
    (hEq : A ^ x + B ^ y = C ^ z) :
    (A * B * C) ^ n < C ^ (3 * z) := by
  -- Since $n \leq x$, $n \leq y$, and $n \leq z$, we have $A^n \leq A^x$, $B^n \leq B^y$, and $C^n \leq C^z$.
  have h_le : A ^ n ≤ A ^ x ∧ B ^ n ≤ B ^ y ∧ C ^ n ≤ C ^ z := by
    exact ⟨ Nat.pow_le_pow_right hA hx, Nat.pow_le_pow_right hB hy, Nat.pow_le_pow_right hC hz ⟩;
  -- Using the inequalities $A^n \leq A^x$, $B^n \leq B^y$, and $C^n \leq C^z$, we can bound $(ABC)^n$.
  have h_bound : (A * B * C) ^ n ≤ A ^ x * B ^ y * C ^ z := by
    simpa only [ mul_pow ] using Nat.mul_le_mul ( Nat.mul_le_mul h_le.1 h_le.2.1 ) h_le.2.2;
  rw [ pow_mul' ];
  exact h_bound.trans_lt ( by nlinarith [ pow_pos hA x, pow_pos hB y, pow_pos hC z, mul_pos ( pow_pos hA x ) ( pow_pos hB y ), mul_pos ( pow_pos hA x ) ( pow_pos hC z ), mul_pos ( pow_pos hB y ) ( pow_pos hC z ), pow_succ' ( C ^ z ) 2 ] )

/-! ## The Threshold Theorem -/

/-
**ABC Threshold Theorem (Uniform Exponent Bound).**

If `IntAbcBound K` holds and `3 * K < n`, then no pairwise coprime
positive integer solution to `A^x + B^y = C^z` exists with
`n ≤ x`, `n ≤ y`, `n ≤ z`.

**Proof sketch:** The ABC bound gives `C^z ≤ (ABC)^K`.
Since `n ≤ x`, `n ≤ y`, `n ≤ z`, we have
`A^n ≤ A^x < C^z`, `B^n ≤ B^y < C^z`, `C^n ≤ C^z`.
Hence `(ABC)^n < C^(3z)`.
Raising the ABC bound to the n-th power: `C^(nz) ≤ (ABC)^(Kn)`.
But `(ABC)^(Kn) = ((ABC)^n)^K < (C^(3z))^K = C^(3Kz)`.
So `C^(nz) < C^(3Kz)`.
Since C ≥ 2 (automatic), this requires `nz < 3Kz`, i.e. `n < 3K`.
But `3K < n` by hypothesis. Contradiction.
-/
theorem abc_int_implies_no_primitive_beal_of_uniform_exponent_bound
    (K n : ℕ)
    (hK : 0 < K)
    (hABC : IntAbcBound K)
    (hn : 3 * K < n) :
    ¬ ∃ A B C x y z : ℕ,
        0 < A ∧ 0 < B ∧ 0 < C ∧
        n ≤ x ∧ n ≤ y ∧ n ≤ z ∧
        Nat.Coprime A B ∧ Nat.Coprime B C ∧ Nat.Coprime A C ∧
        A ^ x + B ^ y = C ^ z := by
  intro ⟨ A, B, C, x, y, z, hA, hB, hC, hx, hy, hz, hAB, hBC, hAC, hEq ⟩;
  have h_ineq : C ^ (n * z) < C ^ (3 * K * z) := by
    have h_ineq : (A * B * C) ^ (K * n) < C ^ (3 * K * z) := by
      convert Nat.pow_lt_pow_left ( beal_product_pow_bound hA hB hC hx hy hz ( by linarith ) hEq ) ( by linarith : K ≠ 0 ) using 1 ; ring;
      ring;
    have h_ineq : C ^ (n * z) ≤ (A * B * C) ^ (K * n) := by
      have h_ineq : C ^ z ≤ (A * B * C) ^ K := by
        apply abc_int_gives_product_bound_general K hABC hA hB hC (by linarith) (by linarith) (by linarith) hAB hAC hBC hEq;
      convert Nat.pow_le_pow_left h_ineq n using 1 <;> ring;
    grind +splitIndPred;
  contrapose! h_ineq;
  exact Nat.pow_le_pow_right hC ( by nlinarith )

/-! ## Concrete Corollaries -/

/-- **Corollary for K=2**: Under `IntAbcBound 2`, no primitive Beal solution
exists with all exponents ≥ 7. -/
theorem abc_K2_no_primitive_beal_exp_ge_7
    (hABC : IntAbcBound 2) :
    ¬ ∃ A B C x y z : ℕ,
        0 < A ∧ 0 < B ∧ 0 < C ∧
        7 ≤ x ∧ 7 ≤ y ∧ 7 ≤ z ∧
        Nat.Coprime A B ∧ Nat.Coprime B C ∧ Nat.Coprime A C ∧
        A ^ x + B ^ y = C ^ z :=
  abc_int_implies_no_primitive_beal_of_uniform_exponent_bound 2 7 (by omega) hABC (by omega)

/-- **Corollary for K=3**: Under `IntAbcBound 3`, no primitive Beal solution
exists with all exponents ≥ 10. -/
theorem abc_K3_no_primitive_beal_exp_ge_10
    (hABC : IntAbcBound 3) :
    ¬ ∃ A B C x y z : ℕ,
        0 < A ∧ 0 < B ∧ 0 < C ∧
        10 ≤ x ∧ 10 ≤ y ∧ 10 ≤ z ∧
        Nat.Coprime A B ∧ Nat.Coprime B C ∧ Nat.Coprime A C ∧
        A ^ x + B ^ y = C ^ z :=
  abc_int_implies_no_primitive_beal_of_uniform_exponent_bound 3 10 (by omega) hABC (by omega)

/-- **Corollary for K=1**: Under `IntAbcBound 1`, no primitive Beal solution
exists with all exponents ≥ 4. -/
theorem abc_K1_no_primitive_beal_exp_ge_4
    (hABC : IntAbcBound 1) :
    ¬ ∃ A B C x y z : ℕ,
        0 < A ∧ 0 < B ∧ 0 < C ∧
        4 ≤ x ∧ 4 ≤ y ∧ 4 ≤ z ∧
        Nat.Coprime A B ∧ Nat.Coprime B C ∧ Nat.Coprime A C ∧
        A ^ x + B ^ y = C ^ z :=
  abc_int_implies_no_primitive_beal_of_uniform_exponent_bound 1 4 (by omega) hABC (by omega)