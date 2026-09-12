# Computational Evidence — separated principal filtrations

All numbers below were produced with `#eval` inside the project's Lean toolchain (the
snippets were run in a scratch module and then removed; they are reproduced here so the
reader can re-run them).  They are *exploratory* data, not proofs: every claim that is
asserted in the deliverable is proved in the `.lean` files with zero `sorry`s.

## 1. The height function on `ℤ` at `a = 2`

```lean
#eval (List.range 20).map (fun n => padicValNat 2 (n+1))
-- [0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0, 4, 0, 1, 0, 2]
```

This is the ruler sequence (OEIS **A007814**, the 2-adic valuation of `n`).  It is
finite at every nonzero integer, which is exactly the statement
`isSeparated_iff_finiteMultiplicity` specialised to `ℤ` at `2`.

## 2. Counterexample hunt inside `ℤ`

Elements of `ℤ` divisible by *many* powers of `2`:

```lean
#eval (List.range 10000).filter (fun m => m ≠ 0 ∧ (List.range 14).all (fun n => 2^n ∣ m))
-- [8192]                                   (only 2^13 survives 14 conditions)
#eval (List.range 10000).filter (fun m => m ≠ 0 ∧ (List.range 21).all (fun n => 2^n ∣ m))
-- []                                       (no survivor at all)
```

The survivor set collapses as the number of conditions grows: no nonzero integer is
infinitely `2`-divisible.  Formalised as `int_two_isSeparated`.

## 3. Where separation must fail: `ℤ + X·ℚ[X]`

The obstruction is the family `X / 2ⁿ`; its coefficient pairs `(constant, linear)` are

```lean
#eval (List.range 6).map (fun n => ((0:ℚ), ((2:ℚ)^n)⁻¹))
-- [(0, 1), (0, 1/2), (0, 1/4), (0, 1/8), (0, 1/16), (0, 1/32)]
#eval (List.range 12).all (fun n => (2:ℚ)^n * ((2:ℚ)^n)⁻¹ = 1)
-- true
```

Every one of these polynomials has constant coefficient `0 ∈ ℤ`, hence lies in
`ℤ + X·ℚ[X]`, and `2ⁿ · (X/2ⁿ) = X`.  So `X` is infinitely `2`-divisible there:
the height function of §1 has no analogue in this ring.  Formalised as
`two_pow_dvd_Xs`, `not_isSeparated_two`, `no_height_function`.

## 4. Pattern extracted from the data

In §1 the survivor set shrinks because each divisibility condition *costs* one unit of a
bounded `ℕ`-valued quantity.  In §3 the "cost" is paid in a direction (the coefficient
denominators) that is invisible to any `ℕ`-valued quantity attached to `X`.  This is the
observation that became the equivalence

  `IsSeparated a ↔ ∃ v : R → ℕ, ∀ x ≠ 0, v x < v (a * x)`   (`isSeparated_iff_exists_height`)

and its refinement `ord_le_of_height`: the `a`-adic order is the minimal such `v`.
