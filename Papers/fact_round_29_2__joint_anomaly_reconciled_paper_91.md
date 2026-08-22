# Computational evidence — FACT round-29 #2 (joint-label reconciliation)

All numbers below were produced by direct enumeration; the ones that matter for
the claims were then re-proved in Lean (see the "formalised as" column).  Numbers
quoted from the round-29 report itself (`4.6006`, `3.6073`, `2.1314`, `0.5830`)
are *inputs*: they are taken as reported and are not re-derived here.

## 1. Chained-frame label counts

For `pj = a·M + b` with `a < A`, `b < B`:

| A | B | M | distinct labels | `A·B` | `M(A−1)+B` |
|---|---|---|---|---|---|
| 4 | 9 | 9 | 36 | 36 | — (wide frame) |
| 4 | 9 | 10000 | 36 | 36 | — |
| 4 | 9 | 3 | **18** | 36 | **18** |
| 6 | 6 | 10 | 36 | 36 | — |
| 6 | 6 | 2 | 16 | 36 | 16 |
| 5 | 8 | 4 | 24 | 40 | 24 |

Exhaustive check over `1 ≤ A ≤ 7`, `1 ≤ B ≤ 11`, `1 ≤ M ≤ 11`:

* every narrow case (`M ≤ B`) realises exactly `M(A−1)+B` labels — no exceptions;
* every wide case (`B ≤ M`) realises exactly `A·B` labels — no exceptions.

*Formalised as* `ChainedLabelWidth.card_chain_image_of_narrow` and
`ChainedLabelWidth.card_chain_image_of_width` (proved for all `A, B, M`, not by
enumeration).

The `4 × 9` population with frame `3` is the smallest natural model of the
audited collapse: **36 genuine pairs, 18 reported labels, exactly a halving**,
matching the label counts in the round-29 table.  (`collapse_36_to_18`.)

## 2. Fiber profile of the narrow frame on the audited population

Fiber sizes of `(a,b) ↦ 3a + b` on `4 × 9`:

| fiber size | 1 | 2 | 3 |
|---|---|---|---|
| number of labels | 6 | 6 | 6 |

Maximum fiber size **3** (`audited_narrow_fiber_le_three`, proved by exhaustive
decision over `Fin 40`).

Uniform population (`p ≡ 1/36`):

* `H(genuine pairs) = log₂ 36 = 5.16993` bits;
* `H(narrow labels) = 4.04411` bits;
* loss `= 1.12581` bits `≤ log₂ 3 = 1.58496` — consistent with the ceiling
  `H_sub_H_push_le_logb`, and **not** with a `log₂ 2 = 1` ceiling, confirming
  that the collapse here is not purely pairwise.

*Formalised as* `JointLabelReconciliation.entropy_unif`,
`narrow_frame_strictly_loses` (explicit gap `≥ 1/18`), `wide_frame_preserves`,
`original_stands`.

## 3. Counterexample hunt

* **Can a collapse ever raise the measured information?**  20 000 random joint
  distributions on `|X| = 4`, `|Y| = 3`, each tested against all `3⁴ = 81`
  labellings `X → {0,1,2}` (1.62 M trials): zero instances of
  `I(f(X);Y) > I(X;Y)`; the most negative drop observed was `0`.  Proved
  impossible: `MI_pushFst_le`.
* **Can two width-valid encodings disagree?**  No: `MI_pushFst_eq_of_injective`
  (exact equality, any injective recoding).
* **Is Gibbs' inequality safe under the `log 0 = 0` convention?**  No.  The
  two-point pair `a = (½,½)`, `b = (0,1)` gives `∑ a(log₂a − log₂b) = −1 < 0`.
  The absolute-continuity hypothesis is therefore load-bearing; the
  counterexample is itself formalised as
  `LabelEntropy.kl_neg_without_absolute_continuity`.

## 4. Consistency test applied to the reported round-29 figures

The theorem `LabelCollapseCeiling.MI_drop_le_H_drop` says: for *any* coarsening
of the label variable of a fixed population,

```
I(true) − I(coarsened)  ≤  H(true labels) − H(coarsened labels).
```

Reported figures:

| quantity | paper 91 | rebuild | drop |
|---|---|---|---|
| H(labels) | 4.6006 | 3.6073 | **0.9933** |
| I(joint) | 2.1314 | 0.5830 | **1.5484** |

`1.5484 > 0.9933`, so — if both rows really describe the same population and the
rebuild differs from paper 91 only by merging labels — the pair violates the
inequality.  Two readings are possible, and the audit should distinguish them:

1. the rebuild differs from paper 91 by *more* than a label merge (a second
   defect in the rebuild pipeline), or
2. the two rows were not computed on the identical population/reference
   variable.

Either way the inequality is a cheap, hard test that the *width-valid* row
passes and the rebuild row does not, which is independent evidence for the
verdict "the original stands".  (No claim is made here about which of 1./2. is
the case; that requires the run data.)

## 5. OEIS

The narrow-frame count `M(A−1)+B` is an affine lattice count and matches no
distinctive OEIS entry beyond arithmetic progressions; no sequence lookup was
warranted.
