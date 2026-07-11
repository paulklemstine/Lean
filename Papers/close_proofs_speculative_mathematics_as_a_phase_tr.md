# Computational Evidence

## Bridge results (factorial ⊂ mixed-radix)

The three closed placeholders assert that the factorial number system is the
mixed-radix system with bases `b i = i + 1`. Small-case checks of the running
product `∏_{i<k}(i+1)` against `k!`:

| k | ∏_{i<k}(i+1) | k! |
|---|--------------|----|
| 0 | 1            | 1  |
| 1 | 1            | 1  |
| 2 | 2            | 2  |
| 3 | 6            | 6  |
| 4 | 24           | 24 |
| 5 | 120          | 120|

These agree, confirming the place-value identity `value_eq`. Validity: a digit is
factoradic-valid at position `i` iff `c i ≤ i`, i.e. `c i < i + 1`, matching
mixed-radix validity for base `i + 1` (`valid_iff`). Uniqueness then transports
verbatim (`factorial_value_unique_via_mixed`).

## Sharp-threshold capacity

For bases `b i = 2` (binary) the capacity is `radixProd b k = 2^k`. Critical
length to reach a target `T` (least `k` with `2^k ≥ T`):

| T   | critical length τ | 2^(τ-1) | 2^τ |
|-----|-------------------|---------|-----|
| 1   | 0                 | —       | 1   |
| 2   | 1                 | 1       | 2   |
| 5   | 3                 | 4       | 8   |
| 100 | 7                 | 64      | 128 |
| 1000| 10                | 512     | 1024|

In every row the capacity is strictly below `T` for all lengths `< τ` and at least
`T` for all lengths `≥ τ`: a single sharp jump, matching
`capacity_sharp_threshold`.

## Counterexample hunt

- Monotonicity is necessary for `active_eq_Ici`: the non-monotone predicate
  `P n := (n = 1)` has active set `{1}`, which is not an up-set, so no threshold
  description holds. This is why monotonicity is retained as an explicit
  hypothesis rather than dropped.
- Degenerate transition: `P 0` true gives threshold `0` with an empty subcritical
  phase; the theorems remain correct (they quantify over `k < 0`, vacuously).

No counterexample was found to any stated theorem; all are proved unconditionally
under their hypotheses.
