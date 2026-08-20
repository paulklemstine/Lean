# Computational Evidence

All numbers below were produced by `#eval` inside the Lean project
(`Catalog/Cryptography/GoodSeeds/Evidence.lean`), which compiles as part of the
`Cryptography` library.  They are exploratory data used to *choose* the theorem
statements; the statements themselves are proved in the accompanying `.lean`
files with no `sorry` and no `native_decide`.

## 1. Compromised fraction of a sampled-monitoring run

Window `(0, N]`, monitoring period `k`, constant-attack adversary.  The number of
checkpoints in the window is the *integer* quotient `N / k`, so the compromised
fraction is `(N - N/k)/N`.

`k = 3` (columns: `N`, checkpoints `N/3`, compromised fraction):

| N | N/3 | fraction |
|---|-----|----------|
| 1 | 0 | 1 |
| 2 | 0 | 1 |
| 3 | 1 | 2/3 |
| 4 | 1 | 3/4 |
| 5 | 1 | 4/5 |
| 6 | 2 | 2/3 |
| 7 | 2 | 5/7 |
| 8 | 2 | 3/4 |
| 9 | 3 | 2/3 |

`k = 2`: `1, 1/2, 2/3, 1/2, 3/5, 1/2, 4/7, 1/2, 5/9` for `N = 1..9`.

`k = 4`: `1, 1, 1, 3/4, 4/5, 5/6, 6/7, 3/4, 7/9` for `N = 1..9`.

**Reading.**  The value `(k-1)/k` asserted informally in the catalog's
`ImmuneSampling` docstring is attained **exactly** on period-aligned windows
(`k ∣ N`) and is a strict *lower* bound otherwise.  This is what
`frac_compromised` (exact integer-division formula), `frac_compromised_eq`
(`N = k*m`) and `frac_compromised_ge` / `frac_compromised_lt_one` (two-sided
bounds off alignment) formalise.  No counterexample to the lower bound was found
in the sample.

## 2. Residue level sets of a window

`N = 10`, `k = 3`; fractions of the level sets `{n : n % 3 = i}` of the window
`(0, 10]`:

`i = 0 : 3/10`, `i = 1 : 2/5`, `i = 2 : 3/10`.  Sum `= 3/10 + 4/10 + 3/10 = 1` ✔

This is the instance of `sum_frac_levelSet` proved as
`SampledMonitoring.sum_frac_residue_levelSet`.

## 3. Exact amplification `1 - (1-ε)^k`, `ε = 1/4`

| k | success fraction |
|---|------------------|
| 0 | 0 |
| 1 | 1/4 |
| 2 | 7/16 |
| 3 | 37/64 |
| 4 | 175/256 |
| 5 | 781/1024 |
| 6 | 3367/4096 |
| 7 | 14197/16384 |

Monotone and strictly increasing for `ε > 0`, matching
`frac_exists_success_repetition` (an *equality*, not a bound) and
`repetition_frac_ge_of_pos`.

## 4. Counterexample hunt for the heavy-row lemma

Exhaustive search over **all 512** accepting sets `A ⊆ {0,1,2} × {0,1,2}`
(a `3 × 3` challenge/randomness grid).  For each `A` we computed
`e = |A|/9`, the set `H` of rows whose own accepting fraction is `≥ e/2`, and
tested whether `e/2 ≤ |H|/3` fails.

**Counterexamples found: 0.**  (Consistent with `heavy_row_lemma`.)

## 5. Sharpness of the rewinding threshold

Same `3 × 3` grid.

* Accepting sets with fraction **strictly greater than** `1/3 = 1/|C|` and with
  no row containing two accepting challenges: **0**.
  (Consistent with `exists_two_accepting_challenges`.)
* Accepting sets with fraction **exactly** `1/3` and no row containing two
  accepting challenges: **27 = 3³**, i.e. exactly the maps `φ : R → C` picking
  one accepting challenge per row.
  (Consistent with `frac_eq_one_div_card_of_unique`; this is why the strict
  inequality in the rewinding theorem cannot be weakened to `≤`.)

## 6. OEIS

No new integer sequence is introduced.  The checkpoint counts `N ↦ N/k` are the
ordinary integer-quotient sequences (e.g. `A004526` for `k = 2`,
`A002264` for `k = 3`), and the amplification numerators/denominators are those
of `1 - (3/4)^k`; nothing here required an OEIS lookup beyond confirming that the
data are the expected elementary quotients.
