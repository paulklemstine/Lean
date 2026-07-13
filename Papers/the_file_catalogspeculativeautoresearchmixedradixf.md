# Computational Evidence — Mixed-Radix Bijection

All checks were run in Lean 4 (`#eval` / `decide`) against the same definitions
used in the formal file `Catalog/Computation/MixedRadixNumberSystem.lean`:

```
radixProd b k = ∏_{i<k} b i
value b c k   = ∑_{i<k} c i * radixProd b i
digit  b n i  = (n / radixProd b i) % (b i)
```

## 1. Running products

Factoradic bases `b i = i+1`:

| k              | 0 | 1 | 2 | 3 | 4  | 5   |
|----------------|---|---|---|---|----|-----|
| `radixProd`    | 1 | 1 | 2 | 6 | 24 | 120 |

These are exactly `k!` (OEIS A000142), confirming `factorial_radixProd`.

Base-`N` bases `b i = N`: `radixProd (fun _ => N) k = N^k` (checked `baseN_radixProd`).

## 2. Round-trip (bijection) checks

* **Factoradic, k = 4** (`4! = 24`):
  `∀ n < 24, value (·+1) (digit (·+1) n) 4 = n`  →  **true**.
* **Base-3, k = 4** (`3^4 = 81`):
  `∀ n < 81, value (fun _=>3) (digit (fun _=>3) n) 4 = n`  →  **true**.

These are the `value_digit` (existence) direction of the bijection
`equivFinPi`; combined with `value_unique` (injectivity, already in the
project) they establish the `Equiv`.

## 3. Counting

The number of valid length-`k` factoradic tuples is
`∏_{i<k}(i+1) = k!` (e.g. `k = 4` gives `24`), matching `card_factorial_tuples`.
Generally `card_valid_tuples : Fintype.card (∀ i : Fin k, Fin (b i)) = radixProd b k`.

## Counterexample hunt

No counterexamples to the round-trip identity were found within the tested
ranges. Since the formal statements are proved for *all* `n`/`k` (not only the
tested finite ranges), the `decide` checks serve only as sanity confirmation of
the definitions, not as the proof.
