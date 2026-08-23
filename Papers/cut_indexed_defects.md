# Computational Evidence — Cut-indexed defects

All numbers below were produced by `#eval` on the *same definitions* that the Lean
files use (`proj`, `cutRank`, `hammingDist`), transcribed here for the record.
Statements that are asserted as *theorems* in `Catalog/Novelty/CutIndexed*.lean`
are proved there; the tables in this file are exploratory data that guided the
formalisation, not a substitute for it.  Where a computation is turned into a
machine-checked claim, the corresponding Lean name is given.

## 1. Cut-rank profiles on `n = 3`, `q = 2`

For a codebook `C ⊆ (Fin 3 → Fin 2)` the cut data is the map
`S ↦ cutRank C S = #{ c|_S : c ∈ C }`.  Profiles (as sets of pairs
`(|S|, cutRank C S)`):

| code | words | profile `(|S|, rank)` | `d` | `k = 4 - d` |
|---|---|---|---|---|
| even weight `E` | 000, 011, 101, 110 | (0,1), (1,2), (2,4), (3,4) | 2 | 2 |
| repetition `R` | 000, 111 | (0,1), (1,2), (2,2), (3,2) | 3 | 1 |
| two-word `B` | 000, 100 | (0,1), (1,1) or (1,2), (2,1) or (2,2), (3,2) | 1 | 3 |

The even-weight code has the *staircase* profile `min(q^{|S|}, q^k)` predicted for
an MDS code (`cutRank_eq_pow_of_isMDS`), and the repetition code saturates at
`q^k = 2` immediately, as `cutRank_eq_card_of_minDist` requires.

## 2. Exhaustive check of the cut-wise Singleton inequality

For **all 256 codebooks** on 3 bits with at least two words, and **all 8 cuts**,
the inequality

`|C| ≤ q ^ (k - |S|) * cutRank C S`  (for `|S| ≤ k`, `d` = the true minimum distance)

was checked by exhaustive evaluation: **0 violations**.  This is the finite
shadow of the theorem `CutData.cutwise_singleton` / `cutwise_singleton_code`.

Related census: on 3 bits there are exactly **2** codes with `(|C|, d) = (4, 2)`
(the even- and odd-weight codes) and exactly **4** with `(|C|, d) = (2, 3)`; all
six are MDS, and all six have the staircase profile.

## 3. Counterexample hunt: is the cut rank submodular?

Shannon entropy is always submodular, so a natural conjecture is
`r(S) r(T) ≥ r(S ∪ T) r(S ∩ T)`.  Exhaustive search over all 256 codebooks on
3 bits found **24 violating codebooks**.  The smallest witness:

```
C = {000, 100, 010, 110, 001},  S = {0,2},  T = {1,2}
r(S) = 3,  r(T) = 3,  r(S∪T) = 5,  r(S∩T) = 2
3 * 3 = 9  <  10 = 5 * 2
```

This is now the machine-checked theorem
`CutIndexedSingleton.Examples.cutRank_not_submodular` (proved by `decide`), and it
is the reason the theory keeps *two* cut invariants: the rank (which obeys the
`CutData` axioms but not submodularity) and the entropy (which is monotone,
`cutEntropy_mono`, and yields the strictly sharper bound
`entropic_cutwise_singleton`).

## 4. Classical versus quantum profile of the `[3,2,2]` code

For the even-weight code `E`, dividing by `log 2`:

| `|S|` | classical `H(S)/log 2` | quantum `E(S)/log 2` |
|---|---|---|
| 0 | 0 | 0 |
| 1 | 1 | 1 (exactly; `entanglementEntropy_evenWeight_single`) |
| 2 | 2 | ≤ 1 (purity on the one-site complement) |
| 3 | 2 | 0 |

The classical profile is a monotone staircase; the quantum profile is a *tent*.
The strict gap at `|S| = 2` is the theorem
`Examples.entanglement_lt_cutEntropy_evenWeight`, and it is what forces the guard
`|S| < d` in `entanglementEntropy_codeState_of_isMDS`.

## 5. Sequence data

The MDS counts above (`2` codes at `(4,2)`, `4` codes at `(2,3)` on three bits)
are small and were not matched against OEIS; the profiles themselves are the
staircase `min(q^s, q^k)` and carry no new integer sequence.  No OEIS lookup is
claimed.
