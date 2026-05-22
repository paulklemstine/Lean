/-
Copyright (c) 2025. All rights reserved.

# Conditional Beal from ABC: The Formal Bridge

This file proves that an explicit ABC-style hypothesis implies structural
constraints on primitive Beal solutions.

## Main results

1. `abc_gives_radical_bound_on_beal`: The real-valued ABC hypothesis directly
   bounds `C^z` by `rad(ABC)^(1+ε)`.

2. `abc_int_gives_product_bound`: An integer-exponent ABC hypothesis gives
   `C^z ≤ (ABC)^K`.

3. `abc_int_implies_no_primitive_beal`: Under the integer ABC hypothesis at
   exponent `K = 2`, no primitive Beal solution exists with all exponents `> 6`.

These theorems create a formal dependency bridge:
  ABC hypothesis ⟹ no primitive Beal solutions in a specified exponent regime.
-/
import Mathlib
import Speculative.Beal.Defs
import Speculative.Beal.Radical

open Nat UniqueFactorizationMonoid

/-! ## ABC implies radical bound on Beal triples (real-valued) -/

/-- For a pairwise coprime Beal solution `A^x + B^y = C^z`, the ABC hypothesis
gives `C^z ≤ rad(A·B·C)^(1+ε)`. -/
theorem abc_gives_radical_bound_on_beal
    (ε : ℝ) (hε : 0 < ε)
    (hABC : ABCStatement ε)
    {A B C x y z : ℕ}
    (hA : 0 < A) (hB : 0 < B) (hC : 0 < C)
    (hx : 0 < x) (hy : 0 < y) (hz : 0 < z)
    (hAB : Nat.Coprime A B) (hAC : Nat.Coprime A C) (hBC : Nat.Coprime B C)
    (hEq : A ^ x + B ^ y = C ^ z)
    (hCopPow : Nat.Coprime (A ^ x) (B ^ y)) :
    (C ^ z : ℝ) ≤ ((radical (A * B * C) : ℕ) : ℝ) ^ (1 + ε) := by
  convert hABC ( A^x ) ( B^y ) ( C^z ) ( pow_pos hA _ ) ( pow_pos hB _ ) ( pow_pos hC _ ) ( by aesop ) ( by aesop ) using 1;
  · norm_cast;
  · rw [ beal_primitive_radical_eq_rad_ABC ] <;> aesop

/-! ## Integer-exponent ABC hypothesis -/

/-- An **integer-exponent ABC hypothesis** at strength `K`:
For all coprime positive `a, b, c` with `a + b = c`,
we have `c ≤ rad(abc)^K`. This is a tractable substitute for the
real-valued ABC conjecture. -/
def ABCIntStatement (K : ℕ) : Prop :=
  ∀ a b c : ℕ,
    0 < a → 0 < b → 0 < c →
    Nat.Coprime a b →
    a + b = c →
    c ≤ (radical (a * b * c)) ^ K

/-! ## Base bounds in primitive Beal solutions -/

/-- In `A^x + B^y = C^z` with positive values, `A^x < C^z`. -/
theorem beal_Ax_lt_Cz
    {A B C x y z : ℕ}
    (hB : 0 < B) (hy : 0 < y)
    (hEq : A ^ x + B ^ y = C ^ z) :
    A ^ x < C ^ z := by
  exact hEq ▸ Nat.lt_add_of_pos_right ( pow_pos hB _ )

/-- In `A^x + B^y = C^z` with positive values, `B^y < C^z`. -/
theorem beal_By_lt_Cz
    {A B C x y z : ℕ}
    (hA : 0 < A) (hx : 0 < x)
    (hEq : A ^ x + B ^ y = C ^ z) :
    B ^ y < C ^ z := by
  linarith [ pow_pos hA x ]

/-- In a Beal equation, `A < C^z`. -/
theorem beal_A_lt_Cz
    {A B C x y z : ℕ}
    (hA : 0 < A) (hB : 0 < B)
    (hx : 0 < x) (hy : 0 < y)
    (hEq : A ^ x + B ^ y = C ^ z) :
    A < C ^ z := by
  exact hEq ▸ lt_add_of_le_of_pos ( Nat.le_self_pow hx.ne' _ ) ( pow_pos hB _ )

/-- In a Beal equation, `B < C^z`. -/
theorem beal_B_lt_Cz
    {A B C x y z : ℕ}
    (hA : 0 < A) (hB : 0 < B)
    (hx : 0 < x) (hy : 0 < y)
    (hEq : A ^ x + B ^ y = C ^ z) :
    B < C ^ z := by
  exact hEq ▸ lt_add_of_pos_of_le ( pow_pos hA _ ) ( Nat.le_self_pow hy.ne' _ )

/-- `C ≤ C^z` for positive `C` and `z`. -/
theorem beal_C_le_Cz {C z : ℕ} (hC : 0 < C) (hz : 0 < z) :
    C ≤ C ^ z :=
  Nat.le_self_pow hz.ne' _

/-
`A * B * C < C ^ (3 * z)` in a Beal equation.
-/
theorem beal_product_lt_C_pow_3z
    {A B C x y z : ℕ}
    (hA : 0 < A) (hB : 0 < B) (hC : 0 < C)
    (hx : 0 < x) (hy : 0 < y) (hz : 0 < z)
    (hEq : A ^ x + B ^ y = C ^ z) :
    A * B * C < C ^ (3 * z) := by
  -- By multiplying the inequalities $A < C^z$, $B < C^z$, and $C \leq C^z$, we get $A * B * C < C^z * C^z * C^z$.
  have h_prod : A * B * C < C^z * C^z * C^z := by
    apply_rules [ mul_lt_mul ];
    · exact?;
    · exact le_trans ( Nat.le_self_pow hy.ne' _ ) ( hEq ▸ Nat.le_add_left _ _ );
    · positivity;
    · exact Nat.le_self_pow hz.ne' _;
    · positivity;
  convert h_prod using 1 ; ring

/-! ## Integer ABC bridge -/

/-
Under `ABCIntStatement K`, a pairwise coprime Beal solution satisfies
`C^z ≤ (A*B*C)^K`.
-/
theorem abc_int_gives_product_bound
    (K : ℕ)
    (hABCInt : ABCIntStatement K)
    {A B C x y z : ℕ}
    (hA : 0 < A) (hB : 0 < B) (hC : 0 < C)
    (hx : 0 < x) (hy : 0 < y) (hz : 0 < z)
    (hAB : Nat.Coprime A B) (hAC : Nat.Coprime A C) (hBC : Nat.Coprime B C)
    (hEq : A ^ x + B ^ y = C ^ z) :
    C ^ z ≤ (A * B * C) ^ K := by
  -- Apply the ABC hypothesis to $a = A^x$, $b = B^y$, and $c = C^z$.
  have hABC : C ^ z ≤ (radical (A ^ x * B ^ y * C ^ z)) ^ K := by
    convert hABCInt ( A ^ x ) ( B ^ y ) ( C ^ z ) ( pow_pos hA _ ) ( pow_pos hB _ ) ( pow_pos hC _ ) _ _ using 1;
    · exact hAB.pow _ _;
    · exact hEq;
  refine le_trans hABC ?_;
  gcongr;
  rw [ beal_primitive_radical_eq_rad_ABC hAB hAC hBC hx hy hz ];
  exact Nat.le_of_dvd ( by positivity ) ( radical_dvd_self _ )

/-
`A^7 ≤ A^x` when `x ≥ 7` and `A ≥ 1`.
-/
theorem pow_le_pow_of_le_exp {A x : ℕ} (hA : 0 < A) (hx : 7 ≤ x) :
    A ^ 7 ≤ A ^ x := by
  exact Nat.pow_le_pow_right hA hx

/-
In a Beal equation with `x > 6`, `A^14 < C^(2*z)`.
-/
theorem beal_A14_lt_C2z
    {A B C x y z : ℕ}
    (hA : 0 < A) (hB : 0 < B)
    (hx : 6 < x) (hy : 0 < y)
    (hEq : A ^ x + B ^ y = C ^ z) :
    A ^ 14 < C ^ (2 * z) := by
  -- Squaring both sides: $(A^7)^2 < (C^z)^2$, i.e., $A^{14} < C^{2z}$.
  have h_sq : (A ^ 7) ^ 2 < (C ^ z) ^ 2 := by
    gcongr;
    exact lt_of_le_of_lt ( pow_le_pow_right₀ hA ( by linarith ) ) ( hEq ▸ Nat.lt_add_of_pos_right ( pow_pos hB _ ) );
  convert h_sq using 1 <;> ring

/-
In a Beal equation with `y > 6`, `B^14 < C^(2*z)`.
-/
theorem beal_B14_lt_C2z
    {A B C x y z : ℕ}
    (hA : 0 < A) (hB : 0 < B)
    (hx : 0 < x) (hy : 6 < y)
    (hEq : A ^ x + B ^ y = C ^ z) :
    B ^ 14 < C ^ (2 * z) := by
  -- Since y ≥ 7, B^7 ≤ B^y. And B^y < C^z (by beal_By_lt_Cz). So B^7 < C^z.
  have hB7_lt_Cz : B ^ 7 < C ^ z := by
    -- Since $y > 6$, we have $7 \leq y$. Therefore, $B^7 \leq B^y$.
    have hB7_le_By : B ^ 7 ≤ B ^ y := by
      exact Nat.pow_le_pow_right hB hy;
    linarith [ pow_pos hA x, pow_pos hB y ];
  convert Nat.pow_lt_pow_left hB7_lt_Cz two_ne_zero using 1 <;> ring

/-
`(ABC)^14 < C^(6*z)` when `A^14 < C^(2z)`, `B^14 < C^(2z)`, `C^14 ≤ C^(2z)`.
-/
theorem beal_ABC_14_lt_C_6z
    {A B C x y z : ℕ}
    (hA : 0 < A) (hB : 0 < B) (hC : 0 < C)
    (hx : 6 < x) (hy : 6 < y) (hz : 6 < z)
    (hEq : A ^ x + B ^ y = C ^ z) :
    (A * B * C) ^ 14 < C ^ (6 * z) := by
  -- We have (ABC)^14 = A^14 * B^14 * C^14 (by Nat.mul_pow).
  have h1 : (A * B * C) ^ 14 = A ^ 14 * B ^ 14 * C ^ 14 := by
    ring;
  -- From beal_A14_lt_C2z, A^14 < C^(2z).
  have h2 : A ^ 14 < C ^ (2 * z) := by
    convert beal_A14_lt_C2z hA hB hx ( by linarith ) hEq using 1
  generalize_proofs at *; (
  have h3 : B ^ 14 < C ^ (2 * z) := by
    convert beal_B14_lt_C2z hA hB ( by linarith ) hy hEq using 1
  have h4 : C ^ 14 ≤ C ^ (2 * z) := by
    exact Nat.pow_le_pow_right hC ( by linarith )
  rw [h1];
  refine' lt_of_lt_of_le ( Nat.mul_lt_mul_of_pos_right ( Nat.mul_lt_mul_of_pos_right h2 ( pow_pos hB _ ) ) ( pow_pos hC _ ) ) _;
  convert Nat.mul_le_mul_left ( C ^ ( 2 * z ) ) ( Nat.mul_le_mul h3.le h4 ) using 1 ; ring;
  ring)

/-
**Conditional Beal impossibility from integer ABC at exponent `K = 2`.**

If `c ≤ rad(abc)^2` for all coprime `a + b = c`, then no pairwise coprime
solution to `A^x + B^y = C^z` exists with all exponents `> 6` and `C ≥ 2`.

Proof: The ABC bound gives `C^z ≤ (ABC)^2`, hence `C^(7z) ≤ (ABC)^14`.
Meanwhile, since `x,y ≥ 7`, we have `A^7 < C^z` and `B^7 < C^z`, giving
`A^14 < C^(2z)` and `B^14 < C^(2z)`. Since `z ≥ 7`, also `C^14 ≤ C^(2z)`.
Thus `(ABC)^14 < C^(6z)`. Combining: `C^(7z) < C^(6z)`, which contradicts
`C ≥ 2` since `7z > 6z`.
-/
theorem abc_int_implies_no_primitive_beal_K2
    (hABCInt : ABCIntStatement 2)
    {A B C x y z : ℕ}
    (hA : 0 < A) (hB : 0 < B) (hC : 0 < C)
    (hx : 6 < x) (hy : 6 < y) (hz : 6 < z)
    (hAB : Nat.Coprime A B) (hAC : Nat.Coprime A C) (hBC : Nat.Coprime B C)
    (hEq : A ^ x + B ^ y = C ^ z)
    (hC2 : 2 ≤ C) :
    False := by
  -- Use the ABC bound to get $C^{7z} ≤ (ABC)^{14}$.
  have hC7z_le_ABC14 : C ^ (7 * z) ≤ (A * B * C) ^ 14 := by
    convert Nat.pow_le_pow_left ( abc_int_gives_product_bound 2 hABCInt hA hB hC ( by linarith ) ( by linarith ) ( by linarith ) hAB hAC hBC hEq ) 7 using 1 ; ring;
    ring;
  exact not_lt_of_ge hC7z_le_ABC14 ( by linarith [ beal_ABC_14_lt_C_6z hA hB hC hx hy hz hEq, pow_lt_pow_right₀ ( show 1 < C by linarith ) ( show 7 * z > 6 * z by linarith ) ] )