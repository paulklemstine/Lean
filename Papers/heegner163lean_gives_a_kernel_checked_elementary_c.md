# Computational Evidence — Rabinowitsch runs, twin primes, and prime packing

## 1. Small-case calculations of `f_p(n) = n² + n + p`

For the three Heegner-relevant primes `p = 11, 17, 41` (discriminants 43, 67, 163):

| p  | run length p-1 | first values f_p(0..4)     | (p, p+2) | p+2 prime? |
|----|----------------|-----------------------------|----------|------------|
| 11 | 10             | 11, 13, 17, 23, 31          | (11,13)  | yes        |
| 17 | 16             | 17, 19, 23, 29, 37          | (17,19)  | yes        |
| 41 | 40             | 41, 43, 47, 53, 61          | (41,43)  | yes        |

All listed values are prime; each `(p, p+2)` is a twin-prime pair. This is the
computational seed for `rabinowitsch_gives_twin_prime`.

## 2. Boundary check `f_p(p-1) = p²`

- f_11(10) = 121 = 11²  (composite)
- f_17(16) = 289 = 17²  (composite)
- f_41(40) = 1681 = 41² (composite)

Confirms the run always stops exactly at the square boundary — the upper edge of
the interval `[p, p²)` used in the packing theorem, and never itself prime.

## 3. Packing count

For `p = 41` the run `f_41(0..39)` yields exactly 40 distinct values, all prime,
all in `[41, 1681)`. Distinctness follows from strict monotonicity
(`f_p` increasing), verified directly for the 40 values and proved in general via
`eulerPoly_strictMono`.

## 4. Counterexample hunt (twin conclusion boundary)

- p = 2: `p - 1 = 1`, so the index `n = 1` is NOT `< p - 1`; the run hypothesis
  says nothing about `f_2(1) = 4`. Hence the twin conclusion cannot be claimed at
  `p = 2`. This pins the hypothesis `3 ≤ p` in `rabinowitsch_gives_twin_prime`.
- The *converse* (primality of the run implies class number one) has no elementary
  counterexample small-case test; it is genuine deep theory (Rabinowitsch) and is
  explicitly NOT asserted.

## 5. OEIS pointers

- Rabinowitsch/lucky numbers of Euler `2, 3, 5, 11, 17, 41` — OEIS A014556.
- Values `n² + n + 41` — OEIS A005846 (first terms 41, 43, 47, 53, 61, 71, …).

All numeric claims above are re-checked inside the Lean file (`example`s via
`native_decide`) and the general statements are proved without `decide`.
