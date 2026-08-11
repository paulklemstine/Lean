# Computational evidence — Quantitative Copycat stability

All claims marked **[Lean]** are machine-checked in `Catalog/Probability/`
(`QuantitativeCopycat.lean`, `CopycatGroupoid.lean`, `ModalResolution.lean`).
Claims marked **[exploratory]** come from floating-point scratch computations and
are *not* verified; they only guided the choice of statements.

## 1. The question

For probabilistic transition systems `M`, `N` related by a bijection `f` of worlds
that preserves atoms and has one-step overlap defect
`ε ≥ 1 − ∑_t min(M.step s t, N.step (f s) (f t))` (= total variation distance,
**[Lean]** `overlapDefect_eq_half_l1`), how far apart can the truth probabilities of a
modal formula of depth `d` be?

The conjecture proposed the linear modulus `d·ε`.

## 2. Small-case calculation: the extremal two-state family

Worlds `{good, bad}`, atom true at `good`, false at `bad`.
`M`: both worlds absorbing. `N`: from `good`, mass `ε` leaks into `bad`.
The overlap defect is exactly `ε`, and the depth-`d` formula `nextᵈ p` gives

| ε | d | exact error `1−(1−ε)^d` | linear bound `d·ε` |
|---|---|---|---|
| 0.5 | 1 | 0.500 | 0.5 |
| 0.5 | 2 | 0.750 | 1.0 |
| 0.5 | 3 | 0.875 | 1.5 |
| 0.5 | 10 | 0.99902 | 5.0 |
| 0.2 | 2 | 0.360 | 0.4 |
| 0.2 | 5 | 0.67232 | 1.0 |
| 0.05 | 5 | 0.226219 | 0.25 |
| 0.01 | 10 | 0.0956179 | 0.1 |

Two things are visible: the error saturates below `1`, and it is *always strictly
below* `d·ε` once `d ≥ 2`. Both are now theorems: **[Lean]** `Sharp.transport_eq`
(the value `1−(1−ε)^d` is attained) and **[Lean]** `linear_bound_not_attained`
(strict inequality for `d ≥ 2`, `0 < ε < 1`). The table also shows the linear bound
becoming accurate as `ε → 0`, quantified by **[Lean]**
`linear_bound_first_order_sharp`: `d·ε − (1−(1−ε)^d) ≤ (d(d−1)/2)·ε²`
(e.g. `d = 10, ε = 0.01`: gap `0.00438 ≤ 0.0045`).

## 3. Counterexample hunt for the geometric bound **[exploratory]**

Random search over pairs of row-stochastic kernels on `n = 3` and `n = 4` states
(uniform Dirichlet-like rows, `ε := maxₛ TV(P(s,·), Q(s,·))`), all `2ⁿ−2`
indicator observables, depths `1..6`:

* `n = 3`, 3000 pairs (≈ 108 000 (observable, depth) tests);
* `n = 4`, 1500 pairs (≈ 126 000 tests).

Maximum observed ratio `error / (1−(1−ε)^d)`: `1.0000000000000009` (i.e. `1` up to
double-precision rounding), attained only at depth `d = 1`. No sample exceeded the
bound, and at depths `d ≥ 2` the ratio stayed strictly below `1`, matching the
proved statements: the bound is tight at every depth only for the specially built
leaking family, and depth-1 saturation is common.

## 4. What the search suggested, and what was then proved

* Errors accumulate *geometrically*, not linearly — the surviving-mass factor
  `(1−ε)` multiplies the previous defect, giving the recursion `δ_{d+1} = δ_d + ε(1−δ_d)`.
  Proved via a pointwise-minimum (coupling-free) decomposition of the two one-step
  expectations: **[Lean]** `one_step_bound`, then **[Lean]** `transport_le`.
* Defects add along composites of analogies (triangle inequality for total
  variation): **[Lean]** `ApproxAnalogy.comp`, giving the loop/holonomy estimate
  **[Lean]** `holonomy_bound`.
* No sequence lookup was relevant: the quantities involved are the elementary
  family `1−(1−ε)^d`, not an integer sequence, so no OEIS search was performed.

## 5. This cycle: networks and the dimension factor of nominal recovery

### 5.1 Chains and cycles

For a chain of `k` analogies with local defects `ε_i` the composite defect is
`∑_{i<k} ε_i` (**[Lean]** `Network.chainAnalogy`), so the depth-`d` transport error
is at most `1 − (1 − ∑ ε_i)^d` (**[Lean]** `Network.network_transport_le`).  Sample
values of that bound for a `k`-cycle with equal local defects `ε`:

| k | ε | Σ ε | d = 1 | d = 2 | d = 3 |
|---|---|-----|-------|-------|-------|
| 2 | 0.1 | 0.2 | 0.200 | 0.360 | 0.488 |
| 3 | 0.1 | 0.3 | 0.300 | 0.510 | 0.657 |
| 4 | 0.25 | 1.0 | 1.000 | 1.000 | 1.000 |
| 5 | 0.05 | 0.25 | 0.250 | 0.4375 | 0.578 |

The last-but-one row is the saturation regime: at total defect `1` the loop can
destroy all information, and this is realized exactly (**[Lean]**
`Network.maximal_holonomy`: two structures on `Bool`, one sending all mass to
`true` and one to `false`, have depth-one observations `1` and `0`).

### 5.2 The `ℓ^∞ → `total-variation dimension factor

For nominal structures, depth-one observations are the kernel entries.  If two
kernels differ entrywise by at most `η` on `n` worlds then the row total variation
distance is at most `nη/2`, and equality needs the perturbation to be `+η` on half
the worlds and `−η` on the other half:

| n = 2m | η | worst-case entrywise gap | TV defect `mη = nη/2` |
|--------|---|--------------------------|-----------------------|
| 2 | 0.10 | 0.10 | 0.10 |
| 4 | 0.10 | 0.10 | 0.20 |
| 6 | 0.05 | 0.05 | 0.15 |
| 10 | 0.02 | 0.02 | 0.10 |

The right-hand column is exactly what the tilted family achieves: **[Lean]**
`Resolution.HMSharp.overlap_defect_eq` computes the defect of the pair
(uniform kernel, tilted kernel) as `m·η`, and **[Lean]**
`Resolution.HMSharp.hm_sharp` shows no ε-approximate analogy with `ε < nη/2` exists
between them, because in nominal structures the bijection is forced (**[Lean]**
`Resolution.nominal_analogy_eq`).  So the dimension factor in the approximate
Hennessy–Milner theorem is not an artifact of the proof.

## 6. This cycle: the analogy distance and the blindness of grading

### 6.1 The distance on the extremal two-state family

`analogyDist` is a minimum over the atom-preserving renamings of the worst-case row
overlap defect `1 − ∑_t min(P_t, Q_t)`.  On the leaking family
(`exactSys` versus `leakySys ε`) the atoms force the renaming to be the identity, and
the two rows are `(1, 0)` versus `(1−ε, ε)` at the world `true` and `(0,1)` versus
`(0,1)` at `false`, giving worst-case defect `ε`:

| ε | defect at `true` | defect at `false` | `analogyDist` |
|---|------------------|-------------------|---------------|
| 0.00 | 0.00 | 0 | 0.00 |
| 0.10 | 0.10 | 0 | 0.10 |
| 0.50 | 0.50 | 0 | 0.50 |
| 1.00 | 1.00 | 0 | 1.00 |

**[Lean]** `Sharp.dist_eq` proves `analogyDist (exactSys ι) (leakySys ι ε) = ε` for
all `ε ∈ [0,1]`, and `Sharp.transport_eq` shows the depth-`d` observation gap is
exactly `1 − (1−ε)^d`, so the modulus of `optimal_transport_le` is attained:

| ε | d = 1 | d = 2 | d = 3 | d = 4 |
|---|-------|-------|-------|-------|
| 0.10 | 0.100 | 0.190 | 0.271 | 0.344 |
| 0.25 | 0.250 | 0.438 | 0.578 | 0.684 |
| 0.50 | 0.500 | 0.750 | 0.875 | 0.938 |

### 6.2 Counterexample hunt: can counting separate deterministic systems?

We enumerated all `5374` graded formulas of size at most `6` nodes over one atom with
grades `k ≤ 3`, and evaluated each of them at every world of all `288` deterministic
constant-atom systems on `n ≤ 4` worlds (all `n^n` successor functions: `1 + 4 + 27 +
256`).  Result: **`0` separating formulas** — every one of the `5374` formulas takes
the same truth value at every world of every one of the `288` systems.  *(This
enumeration was run as an exploratory script, not as a machine-checked Lean
artifact.)*

The exploratory search was then turned into a theorem: **[Lean]** `det_graded_iff`
proves the blindness for *all* pairs of deterministic constant-atom systems, on
arbitrary finite world sets and for arbitrary successor functions and grades, by
induction on graded formulas.  The reason the search could not have succeeded is
visible in the induction: in a deterministic system the set of successors satisfying
`φ` is either a singleton or empty (**[Lean]** `det_filter_card`), so the only
information a grade can extract is the truth value of `φ` at the successor — and by
induction that value is already world- and system-independent.

### 6.3 What does separate them

The pair `succ = id` (two self-loops) and `succ = not` (one 2-cycle) is separated by
the single observation "the current world is one of its own successors":

| system | `0 < step s s` at `s = true` | at `s = false` |
|--------|------------------------------|----------------|
| `detSys id` | true | true |
| `detSys not` | false | false |

**[Lean]** `loop_separates` proves this, and `loopObs_transport` shows the
observation is invariant under exact structural analogies, so it is a legitimate
structural observation rather than a coordinate artifact.
