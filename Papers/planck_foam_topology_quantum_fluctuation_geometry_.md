# Computational Evidence — Planck Foam Topology

All numbers below were produced by executable Lean 4 evaluations (exact `ℚ`
arithmetic where possible, `Float` for logarithms) *before* the corresponding
theorems were proved.  Every identity checked here is now a theorem with a
complete Lean proof; the tables are kept as a record of the exploratory stage.

## 1. Bernoulli cell measure: normalisation

`w p A = ∏ i (if i ∈ A then p else 1 - p)`, summed over `A ⊆ Fin n`.

| `n` | 0 | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|---|
| `∑_A w(1/3, A)` | 1 | 1 | 1 | 1 | 1 | 1 |

Formalised as `sum_weightOn` (probability measure).

## 2. Mean branch number

| `(p, n)` | measured `∑ w·|A|` | predicted `n·p` |
|---|---|---|
| `(1/3, 1)` | `1/3` | `1/3` |
| `(1/3, 4)` | `4/3` | `4/3` |
| `(2/5, 6)` | `12/5` | `12/5` |

Formalised as `sum_weightOn_mul_card` / `expected_branch_count`.

## 3. Second moment and variance

| `(p, n)` | measured `∑ w·|A|²` | predicted `np(1-p) + (np)²` |
|---|---|---|
| `(1/3, 3)` | `5/3` | `5/3` |
| `(2/5, 4)` | `88/25` | `88/25` |

| `(p, n)` | measured `∑ w·(|A| - np)²` | predicted `np(1-p)` |
|---|---|---|
| `(1/3, 5)` | `10/9` | `10/9` |
| `(2/5, 6)` | `36/25` | `36/25` |

Formalised as `sum_weightOn_mul_card_sq` and `variance_branch_count`; used for
the Chebyshev bound `chebyshev_branch_count`.

## 4. Probability that the foam is Hausdorff

Only the empty configuration gives a Hausdorff foam (a nonempty finite set of
Planck sites is never open in `ℝ`), so the Hausdorff weight is `w(∅) = (1-p)^N`.

| `(p, N)` | measured | predicted `(1-p)^N` |
|---|---|---|
| `(1/2, 5)` | `1/32` | `1/32` |
| `(1/3, 4)` | `16/81` | `16/81` |

Formalised as `lineFoam_t2Space_iff` + `hausdorffWeight_eq`, with the decay
bound `hausdorffWeight_le_exp : (1-p)^N ≤ exp(-pN)`.

## 5. Shannon entropy of the foam measure

`E(p, n) = -∑_A w(A) log w(A)` compared with `n · H(p)`,
`H(p) = -p log p - (1-p) log(1-p)` (Float evaluation).

| `(p, n)` | measured `E` | predicted `n·H(p)` |
|---|---|---|
| `(0.5, 4)` | `2.772589` | `2.772589` |
| `(0.3, 5)` | `3.054322` | `3.054322` |
| `(0.7, 3)` | `1.832593` | `1.832593` |
| `(0.25, 6)` | `3.374011` | `3.374011` |

Also `H(0.5) = 0.693147 = log 2`, `H(0.3) = 0.610864`, `H(0.1) = 0.325083`,
consistent with the proved bound `H(p) ≤ log 2` with equality only at `p = 1/2`.
Formalised as `foamEntropy_eq`, `foamEntropy_le_card_mul_log_two`,
`foamEntropy_eq_card_mul_log_two_iff`.

## 6. Counterexample hunt

* *Is every non-Hausdorff foam produced by a nonempty branch locus?*  No: with a
  **open** branch locus the foam stays Hausdorff.  The search for a
  counterexample to "nonempty branch locus ⇒ non-Hausdorff" succeeded with
  `X = ℝ`, `S = (0,1)`, which is why the final theorem
  `t2Space_foam_iff` is stated with the *openness* of `S`, not its emptiness.
* *Is the failure repairable by a single-sheet degeneration?*  Yes, and this is
  the guarded corner case `homeomorphOfSubsingleton`: with `Subsingleton ι` the
  foam is homeomorphic to `X`, which is why the Hausdorff characterisation
  carries the hypothesis `[Nontrivial ι]`.
* *Does the projection admit no continuous section (a "gauge anomaly")?*  The
  hunt refuted this: each sheet inclusion is a continuous section.  The genuine
  obstruction found instead is that the projection is not a covering map
  (`not_isCoveringMap_proj`), although it is a local homeomorphism
  (`isLocalHomeomorph_proj`).
* *Does the foam fail T1 as well?*  No — `t1Space_foam_iff` shows T1 is
  inherited from the base; the foam sits strictly between T1 and R1
  (`not_r1Space_foam`).

# Cycle 2 — evidence for the covering, defect and RG results

All numbers below are exact computations run inside Lean (`#eval` blocks in
`Catalog/Physics/PlanckFoamLabNotes.lean`), and each is matched by a proved
theorem in the files cited.

## 7. Renormalisation flow: lattice sites in a fixed window

Number of sites of spacing `ℓ` inside `[-16, 16]`:

| spacing `ℓ` | `1` | `2` | `4` | `8` | `16` |
|---|---|---|---|---|---|
| measured site count | `33` | `17` | `9` | `5` | `3` |

The count halves (up to the endpoint correction `+1`) at each scale-halving
step, and never reaches `0`: the origin is a site of every rescaled lattice.
This is the computational shadow of `iInter_latticeSet_eq_singleton_zero`
(`Catalog/Physics/PlanckFoamRGFixedPoints.lean`), which proves the intersection
of all rescalings of a nonzero lattice is exactly `{0}`, and hence of the
refutation of the cycle-1 conjecture that the flow terminates at the smooth
foam.

## 8. Excess cardinality

Foam excess `|S| · (|ι| − 1)` for `|S| = 3` branch points:

| sheets `|ι|` | `2` | `3` | `4` |
|---|---|---|---|
| measured excess | `3` | `6` | `9` |

Matched by `card_foam_eq_card_add_excess` and `foamExcess_eq`
(`Catalog/Physics/PlanckFoamCounting.lean`), and, at `p = 1/2`, by the entropy
identity `foamEntropy_eq_log_two_pow_excess`: entropy `= log (2 ^ excess)`.

## 9. Metric defect

Number of non-separated ordered pairs, `|∂S| · (|ι|² − |ι|)`:

| boundary points `|∂S|` (with `|ι| = 2`) | `1` | `2` | `3` |
|---|---|---|---|
| measured defect | `2` | `4` | `6` |

| sheets `|ι|` (with `|∂S| = 2`) | `3` | `4` |
|---|---|---|
| measured defect | `12` | `24` |

Matched by `card_defectSet` and `card_defectSet_bool`
(`Catalog/Physics/PlanckFoamDefect.lean`); the instances `defect_one_site` and
`defect_two_sites` in the lab notes prove the two-sheeted line values `2` and
`4` directly.

## 10. Counterexample hunt, cycle 2

* *Is the projection a covering map whenever the branch locus is closed?*  No —
  the hunt found `S = {0} ⊂ ℝ` (closed, empty interior) where local homeomorphy
  holds but the fibre jumps from `2` to `1`.  The exact boundary of the
  phenomenon is now proved: `isCoveringMap_proj_iff_isClopen`, i.e. covering
  ⇔ clopen branch locus, and on a connected base ⇔ `S = ∅` or `S = univ`.
* *Are the only scale-invariant lattice foams the empty and the full one?*  No —
  the spacing-`0` lattice `{0}` is invariant, and it is a *non-Hausdorff* foam
  with defect `2`.  This refutes cycle-1 Conjecture 4;
  `latticeSet_two_mul_eq_iff` proves the fixed points are exactly the
  spacing-`0` foams.
* *Can the entropy bound be strict for the maximally foamy state?*  No — the
  measured entropies of §5 coincide with `log (2 ^ excess)` exactly, which is
  now the theorem `foamEntropy_eq_log_two_pow_excess`; the conjectured `o(|X|)`
  slack does not exist.
