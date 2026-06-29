# Computational Evidence — Alien Mathematics: Non-Standard (Lunar) Arithmetic

All claims below are *also* discharged formally in the Lean files in this directory; this note
records the small-case evidence that motivated the formalization.

## 1. Single-digit chain arithmetic (base 10, `Chain (Fin 10)`)

`+` is `max`, `*` is `min`:

| a | b | a + b (max) | a * b (min) |
|---|---|-------------|-------------|
| 5 | 7 | 7           | 5           |
| 3 | 3 | 3 (idem)    | 3 (idem)    |
| 9 | k | 9           | k           |
| 0 | k | k           | 0           |

Formal: `Chain.digit_add`, `Chain.digit_mul`, `Chain.add_idem`, `Chain.mul_idem`,
`Chain.digit_nine_absorbs`, `Chain.digit_zero_absorbs`.

## 2. Multi-digit lunar (dismal) arithmetic — Sloane's rule

Lunar product coefficient = max over the antidiagonal of digitwise mins (no carries):
`(p*q).coeff n = max_{i+j=n} min(p_i, q_j)`. Worked example `35 * 2`:

- units: `min(5,2) = 2`
- tens:  `min(3,2) = 2`
- ⇒ `35 * 2 = 22`.

Formal: `Lunar.coeff_mul`, `Lunar.example_35_times_2`.

OEIS context: lunar/dismal arithmetic is Neil Sloane's; lunar multiplication table is
**A087062**, lunar primes **A087097** (not formalized here, candidate for future cycles).

## 3. Counterexample hunt — what *fails*

- **Multiplicative idempotency fails at the place-value layer.** Single digits satisfy
  `a*a = a`, but `X * X ≠ X` (the base squared is "9 0 0", degree shifts). So idempotency of `*`
  is strictly a single-digit phenomenon. Formal: `Lunar.mul_not_idem`.
- **No subtraction.** `9 + x = 9 ≠ 0` for every digit `x`, so the top digit has no additive
  inverse; chain/lunar arithmetic is a semiring but never a ring. Formal:
  `Chain.one_add_no_inverse`.

## 4. De Morgan duality (checked exhaustively over `Fin 10` by `decide`)

Complement `d ↦ 9 - d` swaps `+`↔`*`: `flip(a+b) = flip a * flip b` and
`flip(a*b) = flip a + flip b`, and is an involution. Formal: `Chain.flipDigit_add`,
`Chain.flipDigit_mul`, `Chain.flipDigit_involutive`.
