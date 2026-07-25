import Mathlib

/-!
# Minimal absolute value of sums of powers of the fifth root of unity

Let `ζ₅ = exp(2πi/5)` be the standard primitive fifth root of unity.  A *sum of `n`
powers of `ζ₅`* is any complex number of the form

  `∑_{j < n} ζ₅ ^ (c j)`

for some choice of exponents `c : ℕ → ℕ`.  We define `σ₅ n` to be the infimum of the
absolute values of all such sums:

  `σ₅ n = inf { ‖∑_{j < n} ζ₅ ^ (c j)‖ : c : ℕ → ℕ }`.

Because only the residues of the exponents modulo `5` matter (as `ζ₅ ^ 5 = 1`), the sum
is really a nonnegative-integer combination `∑_{r} a_r ζ₅ ^ r` with `∑_r a_r = n`, and
`σ₅ n` is the least absolute value of such a combination.

The fundamental structural fact used throughout is that the five roots sum to zero,
`∑_{i < 5} ζ₅ ^ i = 0`, which lets one insert a full "zero-summing block" of five roots
without changing the value of a sum — the engine behind the monotonicity results in
`Catalog.FINAL.Novelty.FifthRootSumMonotonicity`.

This file provides the definition `σ₅` (`sigma5`) together with the basic facts:

* `zeta5_primRoot`  : `ζ₅` is a primitive fifth root of unity;
* `zeta5_pow_five`  : `ζ₅ ^ 5 = 1`;
* `zeta5_geom_sum`  : `∑_{i < 5} ζ₅ ^ i = 0`;
* `zeta5_pow_mod`   : `ζ₅ ^ n = ζ₅ ^ (n % 5)` (the multiplicative order-5 reduction);
* `sigma5_nonneg`, `sigma5_bddBelow`, `sigma5_set_nonempty`.
-/

open scoped BigOperators

namespace FifthRootSumMinimal

/-- The standard primitive fifth root of unity `ζ₅ = exp(2πi/5)`. -/
noncomputable def zeta5 : ℂ := Complex.exp (2 * Real.pi * Complex.I / (5 : ℕ))

/-- `ζ₅` is a primitive fifth root of unity. -/
theorem zeta5_primRoot : IsPrimitiveRoot zeta5 5 :=
  Complex.isPrimitiveRoot_exp 5 (by norm_num)

/-- `ζ₅ ^ 5 = 1`. -/
theorem zeta5_pow_five : zeta5 ^ 5 = 1 := zeta5_primRoot.pow_eq_one

/-- The five distinct powers of `ζ₅` sum to zero. -/
theorem zeta5_geom_sum : ∑ i ∈ Finset.range 5, zeta5 ^ i = 0 :=
  zeta5_primRoot.geom_sum_eq_zero (by norm_num)

/-- Since `ζ₅` has multiplicative order `5`, exponents reduce modulo `5`.  This is the
multiplicative order-`5` reduction that plays, for powers of `ζ₅`, the role that the
Fermat-little-theorem congruence `a ^ 5 ≡ a (mod 5)` plays in the integers. -/
theorem zeta5_pow_mod (n : ℕ) : zeta5 ^ n = zeta5 ^ (n % 5) := by
  conv_lhs => rw [← Nat.div_add_mod n 5, pow_add, pow_mul, zeta5_pow_five, one_pow, one_mul]

/-- The set of absolute values of all sums of `n` powers of `ζ₅`. -/
noncomputable def sumAbsSet (n : ℕ) : Set ℝ :=
  Set.range (fun c : ℕ → ℕ => ‖∑ j ∈ Finset.range n, zeta5 ^ c j‖)

/-- `σ₅ n`: the (infimum of the) minimal absolute value of a sum of `n` powers of the
primitive fifth root of unity `ζ₅`. -/
noncomputable def sigma5 (n : ℕ) : ℝ := sInf (sumAbsSet n)

/-- Every element of `sumAbsSet n` is nonnegative. -/
theorem sumAbsSet_nonneg {n : ℕ} {x : ℝ} (hx : x ∈ sumAbsSet n) : 0 ≤ x := by
  obtain ⟨c, rfl⟩ := hx
  positivity

/-- `sumAbsSet n` is bounded below (by `0`). -/
theorem sigma5_bddBelow (n : ℕ) : BddBelow (sumAbsSet n) :=
  ⟨0, fun _ hx => sumAbsSet_nonneg hx⟩

/-- `sumAbsSet n` is nonempty (take all exponents `0`). -/
theorem sigma5_set_nonempty (n : ℕ) : (sumAbsSet n).Nonempty :=
  ⟨_, Set.mem_range_self (fun _ => 0)⟩

/-- `σ₅ n` is nonnegative. -/
theorem sigma5_nonneg (n : ℕ) : 0 ≤ sigma5 n :=
  le_csInf (sigma5_set_nonempty n) (fun _ hx => sumAbsSet_nonneg hx)

end FifthRootSumMinimal