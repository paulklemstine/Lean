# Computational Evidence — Standard-part projection-valued measures

All numbers below were produced by `#eval` inside Lean 4 (Mathlib v4.28.0) on rational models
in which a rational parameter `t > 0` plays the role of the hyperreal infinitesimal `ε`
(and `1/t` the role of the infinite `ω`).  These computations are *exploratory*: the theorems
they motivated are proved over the genuine hyperreals `ℝ*` in
`Catalog/Algebra/StandardPartPVM.lean`, `…Functional.lean` and `…Lifting.lean`, without any
appeal to numerics.

## 1. The infinitesimally-perturbed two-channel family

Model of the witness used in `exists_approxPVM_not_exact`:

```
P₀(t) = !![1, t; 0, 0]      P₁ = !![0, 0; 0, 1]
```

| `t`      | `(P₀(t)·P₁)₀₁` | `(P₀(t)+P₁−1)₀₁` |
|----------|----------------|------------------|
| 1/10     | 1/10           | 1/10             |
| 1/100    | 1/100          | 1/100            |
| 1/1000   | 1/1000         | 1/1000           |
| 1/10⁶    | 1/10⁶          | 1/10⁶            |

Both defects are exactly `t`, never `0`: the family is **never** an exact PVM for `t ≠ 0`, yet
both defects tend to `0`.  Over `ℝ*` with `t = ε` both defects are infinitesimal but nonzero,
which is precisely the content of `exists_approxPVM_not_exact` (the approximate class is strictly
larger than the exact one) — and the descent theorem still applies, giving the sharp PVM
`(!![1,0;0,0], !![0,0;0,1])`.

## 2. Infinite entries: the obstruction to descent

Model of `badProj = !![2, ω; −2ω⁻¹, −1]`, namely `B(t) = !![2, 1/t; −2t, −1]`:

| `t`      | `B(t)·B(t) = B(t)` ? | `B(t)₀₁` |
|----------|----------------------|----------|
| 1/10     | true                 | 10       |
| 1/100    | true                 | 100      |
| 1/1000   | true                 | 1000     |

`B(t)` is an **exact idempotent for every `t ≠ 0`**, while its `(0,1)` entry blows up.  Deleting
the blown-up entry (what the standard part does with an infinite hyperreal, `st x = 0` for
infinite `x`) gives `!![2,0;0,−1]`, and

```
(!![2,0;0,-1])² = !![4,0;0,1] ≠ !![2,0;0,-1]        (computed: (false, 4, 1))
```

so idempotency is destroyed.  This is the counterexample formalized as
`exists_exact_pvm_infinite_entries_not_descending`: finiteness of the entries is not a technical
convenience but the exact boundary of the descent theorem.

## 3. Quantization sanity check

For the sharp PVM `Q₀ = !![1,0;0,0]`, `Q₁ = !![0,0;0,1]`:

```
Q₀² = Q₀ : true      Q₀·Q₁ = 0 : true      Q₀ + Q₁ = 1 : true      tr Q₀ + tr Q₁ = 2
```

The traces sum to `2 = Fintype.card (Fin 2)`, matching the proved theorem
`sum_rank_eq_card` (ranks of the observed channels sum to the dimension) and
`exists_nat_st_trace` (each observed trace is a natural number ≤ dimension).

## 4. Counterexample hunt

We searched for a family with **finite** entries satisfying approximate orthogonality and
approximate completeness whose standard part fails to be a PVM.  None exists: the descent theorem
(`isPVM_stMat_iff`) proves that this is impossible.  Conversely, all counterexamples we found —
in dimensions 1 and 2 — require an entry growing without bound (`1/t` above), consistent with the
proved sharpness statements.

## 5. OEIS

No integer sequence arises in this project (the only integers occurring are ranks bounded by the
dimension), so no OEIS lookup applies.

## 6. Second-cycle evidence: rigidity and entropy

**Rigidity.** For the `ε`-channel `P₀ = !![1, ε; 0, 0]`, `P₁ = !![0, 0; 0, 1]` the candidate exact
model `hyperMat (stMat P)` is `!![1,0;0,0]`, `!![0,0;0,1]`: an exact PVM at entrywise distance
exactly `ε` from `P`.  No symmetry of `P` is used anywhere in the computation, which is why the
formal theorem `exists_exactPVMH_approx` needs no symmetry hypothesis (symmetry re-enters only in
`exists_symm_exactPVMH_approx`, where the exact model is required to be symmetric).

**Entropy.** Two channels with observed Born weights `(t, 1 - t)` merged into one channel give

| t     | H_fine = negMulLog t + negMulLog (1-t) | H_coarse = negMulLog 1 |
|-------|----------------------------------------|------------------------|
| 0     | 0                                      | 0                      |
| 1/4   | 0.5623…                                | 0                      |
| 1/2   | 0.6931… (= log 2)                      | 0                      |
| 1     | 0                                      | 0                      |

so the merge is entropy-neutral exactly at `t ∈ {0, 1}` — precisely the case where at most one
channel in the fibre carries nonzero weight.  This is the boundary formalized by
`observedEntropy_coarse_eq_iff` (equality iff no two distinct nonzero-weight channels are merged),
with the strict case proved as `observedEntropy_coarse_lt`.

These numbers are ordinary real-analytic evaluations recorded for orientation; the mathematical
content is carried by the Lean theorems, which are proved for arbitrary weights, dimensions and
merging maps.
