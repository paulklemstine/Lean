# Computational Evidence — Mixed-Radix Carry-Free Additivity & Normal Form

Setup (`b : ℕ → ℕ` a base sequence):

- `radixProd b k = ∏_{i<k} b i` (running product / capacity),
- `value b c k = ∑_{i<k} c i · radixProd b i` (Horner value of a digit function),
- `digit b n i = (n / radixProd b i) % b i` (explicit digit extraction).

Bases tested: factoradic `bfac i = i+2`, base-ten `b10 i = 10`, and an
irregular mixed base `bmix = [3,5,2,7,4,1,1,…]`.

## Conjecture 4 — length-independent normal form

**Truncation commutes with extraction.** For the irregular base `bmix`, over all
`n < 60`, digit positions `i < 4`, and lengths `k < 6` with `i < k`:

```
∀ n i k, i < k → digit bmix (n % radixProd bmix k) i = digit bmix n i     ⟹ true
```

So truncating `n` to its first `k` place-values never changes any digit at a
position below `k`: the digit stream `fun i => digit b n i` is canonical.

**Master reconstruction law.** Over all `n < 80`, `k < 5`:

```
∀ n k, value bmix (digit bmix n) k = n % radixProd bmix k                  ⟹ true
```

Factoradic sanity check: `digit bfac 100 = [0,2,0,4,0,…]` and
`value bfac (digit bfac 100) 5 = 100` (indeed `100 = 2·2! + 4·4!`).

## Conjecture 2 — carry-free additivity

Take factoradic digits `c = [1,2,0,1]`, `d = [0,0,3,2]`.  At every position
`c i + d i < b i = i+2` (sums `1,2,3,3` vs bases `2,3,4,5`), so addition is
carry-free.  Extracting the digits of the sum reproduces the pointwise sums
exactly:

```
i : (digit of sum, c i + d i)  =  [(1,1), (2,2), (3,3), (3,3)]              ✓
```

Every position matches, confirming `digit_add_carryFree`.

## Counterexample hunt

- The "master law" was tested unconditionally, *including* bases with `b i = 0`
  (where `radixProd` collapses to `0` and `%0` acts as identity); no
  counterexample arose — matching the theorem, which is proved with no positivity
  hypothesis.
- Carry-free additivity necessarily requires the local hypothesis
  `c i + d i < b i`; when it fails, the pointwise sum is not a valid digit
  (`not_valid_of_carry`), and the extracted digit of the sum genuinely differs —
  as expected, the carry appears.

All checks were executed in Lean via `decide`/`#eval`; the formal theorems in
`MixedRadixCarryNormalForm.lean` prove these facts for *all* inputs.
