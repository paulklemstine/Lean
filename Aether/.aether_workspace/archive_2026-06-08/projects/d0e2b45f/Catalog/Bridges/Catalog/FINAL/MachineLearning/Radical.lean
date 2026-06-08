/-
Copyright (c) 2025. All rights reserved.

# Radical Properties for Beal Obstruction Theory

This file proves key properties of the radical function relevant
to the Beal-abc bridge:
- `radical_pow`: invariance under powers
- `radical_mul_of_coprime`: multiplicativity on coprime arguments
- The "primitive radical identity": for pairwise coprime A,B,C,
  `rad(A^x · B^y · C^z) = rad(A · B · C) = rad(A) · rad(B) · rad(C)`

These results formally connect Beal solutions to abc-style triples.
-/
import Mathlib
import Speculative.Beal.Defs

open Nat UniqueFactorizationMonoid

/-! ## Radical of powers and coprime products (wrappers around Mathlib) -/

/-- The radical is invariant under positive powers: `rad(n^k) = rad(n)` for `k ≠ 0`.
This is `UniqueFactorizationMonoid.radical_pow` specialized for readability. -/
theorem radical_pow_eq (n : ℕ) {k : ℕ} (hk : 0 < k) :
    radical (n ^ k) = radical n :=
  UniqueFactorizationMonoid.radical_pow n (by omega)

/-- The radical is multiplicative on coprime arguments. -/
theorem radical_mul_coprime {a b : ℕ} (hab : Nat.Coprime a b) :
    radical (a * b) = radical a * radical b :=
  UniqueFactorizationMonoid.radical_mul (Nat.coprime_iff_isRelPrime.mp hab)

/-! ## Primitive radical identity -/

/-
**Primitive radical identity for Beal triples.**
For pairwise coprime positive integers `A, B, C` with positive exponents,
`rad(A^x · B^y · C^z) = rad(A) · rad(B) · rad(C)`.

This is the formal gateway from Beal to abc: it shows that the radical
of the product of powers collapses to the radical of the product of bases.
-/
theorem beal_primitive_radical_identity
    {A B C x y z : ℕ}
    (hAB : Nat.Coprime A B) (hAC : Nat.Coprime A C) (hBC : Nat.Coprime B C)
    (hx : 0 < x) (hy : 0 < y) (hz : 0 < z) :
    radical (A ^ x * B ^ y * C ^ z) = radical A * radical B * radical C := by
  -- Use `radical_mul` to expand the product of radicals.
  have h1 : radical (A ^ x * B ^ y * C ^ z) = radical (A ^ x * B ^ y) * radical (C ^ z) := by
    convert radical_mul_coprime _ using 1;
    apply_rules [ Nat.Coprime.mul_left, Nat.Coprime.pow ];
  rw [ h1, radical_mul_coprime, radical_pow_eq, radical_pow_eq, radical_pow_eq ];
  · assumption;
  · positivity;
  · positivity;
  · exact hAB.pow _ _

/-
**Bundled form**: `rad(A^x · B^y · C^z) = rad(A · B · C)` for pairwise coprime inputs.
-/
theorem beal_primitive_radical_eq_rad_ABC
    {A B C x y z : ℕ}
    (hAB : Nat.Coprime A B) (hAC : Nat.Coprime A C) (hBC : Nat.Coprime B C)
    (hx : 0 < x) (hy : 0 < y) (hz : 0 < z) :
    radical (A ^ x * B ^ y * C ^ z) = radical (A * B * C) := by
  convert beal_primitive_radical_identity hAB hAC hBC hx hy hz using 1;
  rw [ radical_mul_coprime, radical_mul_coprime ];
  · assumption;
  · apply_rules [ Nat.Coprime.mul_left ]

/-! ## Radical divides the base and is bounded -/

/-- `rad(n)` divides `n` (from Mathlib). -/
theorem radical_dvd_self (n : ℕ) : radical n ∣ n :=
  UniqueFactorizationMonoid.radical_dvd_self