# Computational evidence: is the subset spectrum of a finite action log-concave?

All numbers below were produced with the **executable** model
`SubsetSpectrum.spec G X r` (number of `G`-orbits on `r`-element subsets of `X`) defined in
`Catalog/Applications/ActionSpectrum/Basic.lean`.  The experiments themselves live in
`Catalog/Applications/ActionSpectrum/Experiments.lean` and are re-run by compiling that file
(`#eval`, no `native_decide`).  The small-case facts that carry mathematical weight are
additionally proved in Lean (`by decide`) in
`Catalog/Applications/ActionSpectrum/LogConcavity.lean`.

## 1. Small-case calculations

Spectra `t_0, t_1, …, t_n` of the regular action of the cyclic group `C_n` on `n` points:

| n  | spectrum |
|----|----------|
| 3  | 1 1 1 1 |
| 4  | 1 1 2 1 1 |
| 5  | 1 1 2 2 1 1 |
| 6  | 1 1 3 4 3 1 1 |
| 7  | 1 1 3 5 5 3 1 1 |
| 8  | 1 1 4 7 10 7 4 1 1 |
| 9  | 1 1 4 10 14 14 10 4 1 1 |
| 10 | 1 1 5 12 22 26 22 12 5 1 1 |

Other actions on small sets:

| action | spectrum |
|--------|----------|
| trivial group on 4 points | 1 4 6 4 1 |
| `A₄` on 4 points | 1 1 1 1 1 |
| `S₄` on 4 points | 1 1 1 1 1 |
| `A₅` on 5 points | 1 1 1 1 1 1 |

## 2. OEIS

The rows for `C_n` are the counts of binary **necklaces** of length `n` with `r` ones,
i.e. the triangle **A037306** (row sums **A000031**).  This is expected: an orbit of the
cyclic translation action on `r`-subsets of `Z/n` *is* a binary necklace of weight `r`.
The trivial-group row is Pascal's triangle **A007318**, in agreement with the theorem
`SubsetSpectrum.spec_of_trivial_action`.

## 3. Counterexample hunt

Log-concavity defect `d_r := t_{r-1}·t_{r+1} − t_r²` for `1 ≤ r ≤ n−1` (positive = violation):

| n  | defects `d_1 … d_{n-1}` |
|----|--------------------------|
| 6  | 2, −5, −7, −5, 2 |
| 8  | 3, −9, −9, −51, −9, −9, 3 |
| 10 | 4, −13, −34, −172, −192, −172, −34, −13, 4 |

**A counterexample was found immediately**, and the pattern is systematic: for the regular
action of `C_n` the defect is positive exactly at the two boundary indices `r = 1` and
`r = n−1`, where `d_1 = t_2 − 1 = ⌊n/2⌋ − 1 > 0` for `n ≥ 4`.  The smallest instance is
`C₄` on `4` points, spectrum `(1,1,2,1,1)`, with `t_1² = 1 < 2 = t_0·t_2`; this is the
counterexample formalised as `SubsetSpectrum.C4.not_logConcaveSpectrum` and generalised to
all `n ≥ 4` as `SubsetSpectrum.Cyc.not_logConcaveSpectrum`.

The mechanism is transparent and led to the rigidity theorem of the formal development:
for any **transitive** action `t_0 = t_1 = 1`, so log-concavity at `r = 1` forces `t_2 ≤ 1`,
i.e. 2-homogeneity; iterating, it forces `t_r = 1` for *every* `r`
(`SubsetSpectrum.logConcave_iff_setTransitive`).

## 4. Slack in the repaired inequality

The group-free repair proved in `Shadow.lean` is `t_{r-1}·t_{r+1} ≤ r(n−r)·t_r²`.
Measured slack `r(n−r)·t_r² − t_{r-1}·t_{r+1}`:

| n  | slack at `r = 1 … n−1` |
|----|-------------------------|
| 6  | 2, 68, 135, 68, 2 |
| 8  | 3, 185, 695, 1551, 695, 185, 3 |
| 10 | 4, 388, 2914, 11304, 16416, 11304, 2914, 388, 4 |

Non-negative everywhere, as the theorem predicts; it is tightest at the boundary (`r = 1`),
which is exactly where the unrepaired conjecture fails.  Since at `r = 1` the bound reads
`t_2 ≤ (n−1)·t_1²` while the true value for `C_n` is `t_2 = ⌊n/2⌋`, the constant `r(n−r)`
is within a factor `≈ 2` of optimal in this family.

## 5. Burnside cross-check

For `C₄` and `r = 2`: `t_2 · |G| = 2 · 4 = 8`, and
`Σ_{g∈G} #{2-subsets fixed by g} = 6 + 0 + 2 + 0 = 8`.  This agrees with the formally proved
mass formula `SubsetSpectrum.spec_mul_card_eq_sum_fixed`.
