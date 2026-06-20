# Computational Evidence — Winning Probability Recurrence for the q-Game

We study `P(n,q)`, the probability the Random player wins the q-game, conjectured to satisfy

```
P(n,q) = 1/n + (1/n) * Σ_{k=q+1}^{n} P(n−k, q),   P(0,q) = 0.
```

Multiplying by `n` and reindexing `j = n − k` gives the equivalent forward form actually used as
the Lean definition:

```
n · P(n,q) = 1 + Σ_{j=0}^{n−q−1} P(j,q)        (truncated subtraction: empty sum when n ≤ q)
```

## 1. Small-case calculations

Using an exact rational evaluator (`Pvec` over `ℚ`):

| n | P(n,1) | P(n,2) | P(n,3) |
|---|--------|--------|--------|
| 0 | 0      | 0      | 0      |
| 1 | 1      | 1      | 1      |
| 2 | 1/2    | 1/2    | 1/2    |
| 3 | 2/3    | 1/3    | 1/3    |
| 4 | 5/8    | 1/2    | 1/4    |
| 5 | 19/30  | 1/2    | 2/5    |

Observation 1 (small-n closed form): for `1 ≤ n ≤ q`, `P(n,q) = 1/n` (the sum is empty).
This is verified as the theorem `P_small` in `Recurrence.lean`.

Observation 2 (base case): `P(0,q) = 0` for all q (theorem `P_zero`).

## 2. Probability bounds

For every `q ≥ 1` and every `n`, the exact rational values stay in `[0,1]`:
checked by `decide` for all `q ≤ 5`, `n ≤ 20`. The structural reason: there are exactly
`n − q` terms in the forward sum, each at most `1`, so `n·P(n,q) ≤ 1 + (n−q) ≤ n` precisely
because `q ≥ 1`. Formalized as `P_nonneg` and `P_le_one` in `Probability.lean`.

## 3. Asymptotics (heuristic, not formalized)

The exact rational evaluator gives, as floats:

```
P(80,1)  ≈ 0.632121   ≈ 1 − 1/e
P(120,2) ≈ 0.478268
P(150,3) ≈ 0.390582
P(150,4) ≈ 0.332929
```

The value `0.632121 ≈ 1 − e^{-1}` for `q = 1` strongly suggests an exponential-integral limit
tied to the cycle structure of uniform random permutations. This is recorded as a bold conjecture
in `FUTURE_DIRECTIONS.md`; it is *not* claimed as a theorem here.

## 4. Counterexample hunt

- `P(n,q) ∈ [0,1]`: no counterexample found for `q ≤ 5, n ≤ 20`.
- `P(n,q) = 1/n` for `n > q`: FALSE in general (e.g. `P(4,1) = 5/8 ≠ 1/4`), so the small-n
  closed form genuinely requires the hypothesis `n ≤ q`.
- Recurrence reindex identity `Σ_{k=q+1}^n P(n−k) = Σ_{j=0}^{n−q−1} P(j)`: holds for all tested
  `q, n` including `q = 0`, so the recurrence theorem is stated for all `q`.
