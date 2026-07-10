# Computational Evidence: Dyadic Surreals and Finite Birthdays

This note records the small-case evidence underlying the theorems in
`SurrealDyadicBirthday.lean`.

## 1. Birthdays of the powers of one half

Conway's `powHalf n` is defined recursively by `powHalf 0 = 1` and
`powHalf (n+1) = { 0 | powHalf n }`. The birthday of a pre-game is the least ordinal
strictly above the birthdays of all its options.

| n | powHalf n         | value  | birthday |
|---|-------------------|--------|----------|
| 0 | `1`               | 1      | 1        |
| 1 | `{0 \| 1}`        | 1/2    | 2        |
| 2 | `{0 \| 1/2}`      | 1/4    | 3        |
| 3 | `{0 \| 1/4}`      | 1/8    | 4        |
| n | `{0 \| 2^{-(n-1)}}` | 2^{-n} | n + 1  |

The pattern `birthday (powHalf n) = n + 1` matches Mathlib's single computed case
`birthday_half : (powHalf 1).birthday = 2`. This is the content of `birthday_powHalf`.
Since `n + 1 < ω` for every `n`, all powers of one half are born before day `ω`
(`birthday_powHalf_lt_omega0`), i.e. they lie in `No_ω`.

## 2. Distinctness / monotonicity

Numerically `2^{-(n+1)} < 2^{-n}`, so the values strictly decrease and are pairwise
distinct. This is `powHalf_succ_lt`, `powHalf_strictAnti`, `powHalf_injective`.
The identity `2^n · 2^{-n} = 1` becomes `two_pow_mul_powHalf`.

## 3. Injectivity of the dyadic embedding — kernel check

`dyadicMap` sends the dyadic rational `m / 2^n` to `m · powHalf n` in `Surreal`.
Testing the kernel on samples:

| dyadic input | image `m · powHalf n` | zero? |
|--------------|-----------------------|-------|
| `0/1`        | `0`                   | yes   |
| `1/1`        | `powHalf 0 = 1`       | no    |
| `3/4`        | `3 · powHalf 2`       | no    |
| `-5/8`       | `-5 · powHalf 3`      | no    |

Every nonzero dyadic maps to a nonzero surreal because `powHalf n > 0` and `Surreal`
is an integral domain. No counterexample to injectivity exists; this is the general
fact `dyadicMap_injective`, which resolves the `TODO` in
`Mathlib/SetTheory/Surreal/Dyadic.lean`.

## 4. Counterexample hunt

The literal grand conjecture "`No_ω` = ℚ extended with dyadic rationals" is *false* as
stated: `No_ω` is exactly the dyadic rationals `ℤ[1/2]`, a proper subring of ℚ (e.g.
`1/3 ∉ No_ω`). Our formalized statements avoid this overclaim: we prove the correct,
provable core — that `ℤ[1/2]` embeds injectively into `Surreal`, that its image is an
additive subgroup, and that every generator `2^{-n}` sits in `No_ω` with birthday
`n + 1`.
