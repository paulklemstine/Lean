# Computational evidence — THE-SUM-DIFFERENCE-SPLIT (round 29 #1, paper 99)

All numbers below were recomputed independently for this cycle (plug-in empirical mutual
information in bits, `I(T;X) = H(T) + H(X) - H(T,X)`, exact fibre counts, no sampling noise).
The scripts referenced in the assignment brief were not present in this environment, so the
routing table was rebuilt from its stated definition:

* population = a list of factor pairs `(p, q)` modulo `m`;
* views: `s = p+q`, `d = q-p`, `N = pq`, joint `(s,d)`, pair `(p,q)`;
* label `T` = a colouring of the population.

**Status of these numbers.** They are exploratory evidence produced outside Lean; they are
*not* claimed as verified. Every statement that this cycle asserts as a result is a Lean
theorem in `Catalog/Algebra/SumDiffSplit.lean`, `SumDiffHintValue.lean`, `SumDiffSynergy.lean`
and `SumDiffUniform.lean`, and the readings of the four witness batteries below are reproduced
there *exactly* (as rational numbers of bits) rather than numerically.

## 1. Three batteries modulo 31

| battery | product `I(T;N)` | sum `I(T;s)` | gap `I(T;d)` | joint `I(T;s,d)` | pair `I(T;p,q)` | `H(T)` | hint value |
|---|---|---|---|---|---|---|---|
| A: label built from `(s,d)` (all 900 pairs `p,q ≠ 0`) | 0.0749 | 1.3260 | 0.3304 | 1.9984 | 1.9984 | 1.9984 | **+1.9235** |
| B: label a function of `N` | 1.0000 | 0.0342 | 0.0342 | 1.0000 | 1.0000 | 1.0000 | **0.0000** |
| C: random binary labels, 120 sampled pairs | 0.2159 | 0.2657 | 0.1647 | 0.9928 | 0.9928 | 0.9928 | **+0.7768** |

Observations that became theorems:

* the joint column never falls below the product, sum or gap columns
  (`product_le_residue`, `sum_le_residue`, `gap_le_residue`);
* the joint column and the pair column are *identical* in every battery
  (`residue_eq_pair`: the sum/difference change of coordinates is a bijection when `2` is
  invertible);
* battery B — labels that are a function of `N` — has hint value exactly `0`
  (`hintValue_eq_zero_of_product_measurable`).

## 2. Counterexample hunt

2000 randomised trials, `m ∈ {5, 7, 11, 31}`, population sizes `2 … 12`, ternary labels:

* violations of `joint ≥ max(product, sum, gap)`: **0**;
* discrepancies between the joint residue view and the factor-pair view: **0**;
* negative hint values: **0**.

No counterexample was found to the ordering claims, consistent with their proofs.

## 3. The four exact witness batteries (all reproduced in Lean)

| witness | modulus | `P` | `Q` | labels | sum | gap | product | joint | hint |
|---|---|---|---|---|---|---|---|---|---|
| one-bit refutation (`SumDiffSplit.Witness`) | 5 | `1,1,2,2` | `1,2,3,1` | `0,0,1,1` | 0.5 | 0.5 | **0** | **1** | **+1** |
| ceiling (`SumDiffSynergy.CeilingWitness`) | 5 | `1,2,3,4` | `1,3,2,4` | `0,1,2,3` | 1.5 | 1.5 | **0** | **2** | **+2 = H(T)** |
| synergy (`SumDiffSynergy.SynergyWitness`) | 5 | `0,2,3,0` | `0,3,3,1` | `0,1,1,0` | **0** | **0** | 1 | **1** | 0 |
| degenerate (`SumDiffSynergy.Degenerate`) | 5 | `0,0` | `0,0` | `0,1` | 0 | 0 | 0 | 0 | 0, labels not product-measurable |

The one-bit witness is the formal refutation of `I(s,d) = I(N)`; the ceiling witness shows the
label-entropy bound is attained; the synergy witness shows the `3.9% / 3.9% / 152%` shape of
the reported table (two individually blind coordinates, jointly complete) is exactly
realisable; the degenerate witness shows product-measurability is *not* necessary for the
hint value to vanish.

## 4. The hyperbola ceiling, evaluated

For the uniform battery (all `q²` residue pairs, each once) over a field with `q` elements the
product view has one fibre of size `2q-1` (the degenerate conic `xy = 0`) and `q-1` fibres of
size `q-1` (`card_hyperbola_zero`, `card_hyperbola_ne_zero`). Hence:

| `q` | `H(s,d)` bits | `H(N)` bits | ceiling `H(s,d) - H(N)` |
|---|---|---|---|
| 5 | 4.6439 | 2.2227 | **2.4212** |
| 31 | 9.9084 | 4.9365 | **4.9719** |

The round-29 reading `+0.5189` bits is `10.4%` of the `q = 31` ceiling; the reported `10`-bit
hint size `log₂ 961 = 9.9084` is *not* the right yardstick, because half of it is already
visible in `N`. The Lean closed form is `SumDiffUniform.H_productView_uniform` and the bound
is `SumDiffUniform.hintValue_uniform_le`.

## 5. Sequence data

No new integer sequence arises; the only counting sequences involved are the classical finite
field point counts `q-1` (affine hyperbola) and `2q-1` (degenerate conic), which are standard
and are proved here rather than looked up.

## 6. The flagged anomaly

The brief flags a joint-battery product-view reading of `0.1353` against paper 91's `2.1314`
for a nominally identical quantity. Nothing in this cycle depends on that row. Moreover
`SumDiffSplit.residue_eq_pair` proves that any two faithful encodings of the same residue pair
must give identical readings, so a genuine discrepancy of that size can only come from the
labels or the encoding, not from the choice of sum/difference versus pair coordinates.
