# Computational Evidence: Periodic Orbits of the Tent and Logistic Maps

## 1. Counting fixed points of the `n`-fold iterate

The tent map `T(t) = 1 - |2t - 1|` has `n`-fold iterate `Tⁿ` equal to a sawtooth
of `2ⁿ` linear ramps, each spanning `[0,1]`. Counting diagonal crossings:

| n | fixed points of Tⁿ in [0,1] | 2ⁿ |
|---|-----------------------------|----|
| 1 | {0, 2/3}                    | 2  |
| 2 | {0, 2/5, 2/3, 4/5}          | 4  |
| 3 | {0, 2/9, 2/7, 6/13, 2/3, 6/11, 6/7, 8/9} | 8 |

The counts follow the sequence `2, 4, 8, 16, … = 2ⁿ` (OEIS A000079, powers of two).

Through the conjugacy `x = h(t) = sin²(πt/2)` these map bijectively to the fixed
points of `fⁿ` for the logistic map `f(x) = 4x(1-x)`:

- `n = 1`: `T`-fixed `{0, 2/3} → f`-fixed `{0, 3/4}` (verified: `h(2/3) = 3/4`).
- `n = 2`: the tent 2-cycle `2/5 ↔ 4/5` maps to the logistic 2-cycle
  `(5∓√5)/8`, giving the 4 logistic period-2 points `{0, 3/4, (5-√5)/8, (5+√5)/8}`.

## 2. The period-three orbit

Tent 3-cycle: `T(2/7) = 4/7`, `T(4/7) = 6/7`, `T(6/7) = 2/7`. All three values are
distinct and lie in `[0,1]`, so the seed has exact period three. Applying `h`
transports this to a logistic period-three orbit; distinctness is preserved because
`h` is injective on `[0,1]`.

## 3. Counterexample hunt for the counting reduction

The theorem `periodic_ncard_eq` asserts equal cardinalities of the two period-`n`
sets. This is not a universal numeric claim that can fail on a sample: it is a
bijection built from the exact conjugacy, and the small-`n` tables above are
consistent with it (2↔2, 4↔4, 8↔8). No counterexample exists because `h` is a
genuine bijection of `[0,1]`.

## Notes

The evidence above is combinatorial and closed-form; the fixed-point counts and the
period-three cycle are exact rational computations rather than floating-point
experiments, so no numerical sampling was needed.
