# Computational Evidence

## Target

Close-proofs mission. The concrete, provable content closed in this pass is the
bridge between the **factorial (factoradic) number system** and the general
**mixed-radix number system** (`Catalog/Speculative/AutoResearch/MixedRadixFactorialBridge.lean`),
which is a genuine cross-domain "connector": it exhibits the factorial system as
the single instance `b i = i + 1` of the general positional-numeral family, and
re-derives factoradic uniqueness as a corollary of the general uniqueness theorem.

The three theorems closed were:

* `value_eq`   — the mixed-radix place values for `b i = i+1` are exactly the
  factorials, so the two `value` functions agree.
* `valid_iff`  — mixed-radix digit-validity for `b i = i+1` coincides with
  factoradic validity (`c i ≤ i`).
* `factorial_value_unique_via_mixed` — factoradic uniqueness re-derived from
  `MixedRadix.value_unique` via the two bridge lemmas.

## Small-case calculations

Let `b i = i + 1`. Then the running product `∏_{j<i} b j` should equal `i!`:

| i            | 0 | 1 | 2 | 3 | 4  | 5   | 6   |
|--------------|---|---|---|---|----|-----|-----|
| `radixProd`  | 1 | 1 | 2 | 6 | 24 | 120 | 720 |
| `i!`         | 1 | 1 | 2 | 6 | 24 | 120 | 720 |

Verified by `#eval` (identical rows), which is the content of
`MixedRadix.factorial_radixProd`.

For the digit sequence `c = [0,1,0,2,1,3]`, the mixed-radix value (base
`b i = i+1`) and the factoradic value agree at every prefix length `k`:

| k                        | 0 | 1 | 2 | 3 | 4  | 5  | 6   |
|--------------------------|---|---|---|---|----|----|-----|
| `MixedRadix.value` (b=i+1)| 0 | 0 | 1 | 1 | 13 | 37 | 397 |
| `FactorialNumberSystem.value` | 0 | 0 | 1 | 1 | 13 | 37 | 397 |
| equal?                   | ✓ | ✓ | ✓ | ✓ | ✓  | ✓  | ✓   |

(E.g. `397 = 0·0! + 1·1! + 0·2! + 2·3! + 1·4! + 3·5! = 0+1+0+12+24+360 = 397`.)

These `#eval` checks were run against Mathlib and match exactly, giving direct
computational evidence for `value_eq` before the formal proof.

## Counterexample hunt

The universal claims (`value_eq`, `valid_iff`) hold definitionally after rewriting
by `factorial_radixProd`; no counterexample is possible and none was found across
the sampled digit sequences and lengths above.

## Note on the remaining project `sorry`

The only other genuine `sorry` in the catalog is the infinite composite tail of
Carmichael's Fibonacci primitive-divisor theorem
(`Catalog/Shared/CarmichaelProof.lean`, case "composite `n > 10000`"). That case
is the full classical Carmichael theorem for an infinite range and is not
reachable by bounded computation (`native_decide` only settles `13 ≤ n ≤ 10000`);
see `FUTURE_DIRECTIONS.md`.
