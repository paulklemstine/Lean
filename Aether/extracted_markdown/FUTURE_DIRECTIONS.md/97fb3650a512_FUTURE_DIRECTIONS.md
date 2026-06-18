# Future Directions: Descent Basin Theory

## Synthesis

This cycle built the `DescentSystem` abstraction from scratch (the catalog had no
prior basin/descent infrastructure, so this was a cold start) and proved the
**Basin Fixed Point Theorem**: for a finite state space equipped with a discrete
dynamics `step` and a `ℕ`-valued Lyapunov ("energy") function that strictly
decreases away from fixed points, the number of basins of attraction equals the
number of fixed points. The structural engine is a single induction
(`step_iterate_isFix`): the energy value bounds the worst-case length of a descent
path, so `step^[energy s] s` always lands on a fixed point. From this one lemma the
whole edifice follows — the limit map `limitPoint` is well defined, its range is
*exactly* the fixed-point set (`range_limitPoint_eq_fixedPoints`), its fibers are the
basins, and these basins partition the space (`iUnion_basin_eq_univ`,
`basin_disjoint`).

The cleanest structural insight is that **basins are literally the fibers of the
limit map**, so "counting basins" is a pure image/fiber computation rather than a
dynamical one. This made two extensions almost syntactic: basin counts are
*multiplicative* across independent subsystems (`prod_fixedPoint_count`), and they
are *equivariant* under any energy-preserving symmetry of the dynamics
(`limitPoint_equivariant`, `isFix_equiv`). The multiplicativity result is exactly
the classical (`q = 1`) shadow of the conjectured "quantum" deformation of basin
counting, and the equivariance result is exactly the group action one needs to feed
into a Burnside-style count of basins modulo symmetry.

What did *not* make it into this cycle: a real-valued (rather than `ℕ`-valued)
Lyapunov function, and the Burnside count itself. The `ℕ`-valued energy was a
deliberate simplification — it gives a concrete iteration bound `energy s` and
sidesteps well-foundedness subtleties. The boundary where the current proof breaks
is precisely the move to `ℝ`-valued energy with only a *strict* (not quantized)
decrease: there the bound "`energy s` steps suffice" fails, and one needs either a
discreteness/Łojasiewicz-type hypothesis or a well-founded-recursion argument. That
boundary is the seed for Directions 1 and 5 below.

## Results Summary

- `DescentSystem.step_iterate_isFix`: proved — the key descent lemma; `energy s`
  iterations always reach a fixed point, giving the well-definedness of the limit map.
- `DescentSystem.limitPoint_isFixedPt`: proved — every state flows to a fixed point.
- `DescentSystem.limitPoint_eq_self`: proved — fixed points are their own limit.
- `DescentSystem.range_limitPoint_eq_fixedPoints`: proved — the basin–fixed-point
  correspondence (image of the limit map = fixed-point set).
- `DescentSystem.basin_count_eq_fixedPoint_count`: proved — **the Basin Fixed Point
  Theorem** in cardinality form (#basins = #fixed points).
- `DescentSystem.mem_basin_self`, `basin_disjoint`, `iUnion_basin_eq_univ`: proved —
  the basins form a partition of the state space indexed by fixed points.
- `DescentSystem.prod`, `prod_isFix_iff`, `prod_fixedPoint_count`: proved —
  multiplicativity of basin counts across independent (product) subsystems.
- `DescentSystem.isFix_equiv`, `limitPoint_equivariant`: proved — symmetries of the
  dynamics permute fixed points and intertwine the basin map (equivariance of basins).

## Research Directions

### Direction 1: Discrete Morse inequalities from descent decomposition
**Hypothesis**: Extend `DescentSystem` to track critical cells of every index (not
only minima) on a finite CW/simplicial complex, and prove the weak Morse
inequality `b_k ≤ c_k` (the k-th Betti number is bounded by the number of critical
k-cells), together with the Euler identity `Σ (−1)^k c_k = χ`.
The key insight is that the orbit-injectivity / fiber structure of `limitPoint`
already gives the alternating-sum bookkeeping needed for the Euler characteristic;
each basin is a "descending cell" and the partition `iUnion_basin_eq_univ` is the
cell decomposition. **Test**: build a `DescentSystem` whose energy is a discrete
Morse function on a small complex (e.g. a triangulated circle/torus), define
`criticalCells k`, and prove `c_k ≥ b_k` against the catalog's
`Geometry.DiscreteMorseInequalities` (`homology_finrank_le`, `euler_char_eq`).
**Why now?** The Lyapunov/non-cycling machinery (`step_iterate_isFix`) makes
discrete gradient flow well defined, and `basin_count_eq_fixedPoint_count` is the
index-0 case of the inequality. **If true**: connects our geometry result to the
catalog's homological-algebra Morse file, a genuine cross-domain bridge.
**If false**: pinpoints which non-cycling hypothesis is too weak to control
higher-index cells.

### Direction 2: Equivariant basin counting via Burnside's lemma
**Hypothesis**: For a finite group `G` acting on `S` by energy-preserving symmetries
that commute with `step`, the number of basins modulo `G` equals
`(1/|G|) Σ_{g∈G} #{basins fixed by g}`, and a basin is fixed by `g` iff its limit
point is a `g`-symmetric critical point.
The key insight is that `limitPoint_equivariant` already shows `G` acts on the set
of basins (= fibers of `limitPoint`), so Burnside applies verbatim to that action.
**Test**: package the `G`-action as a `MulAction` on `Set.range D.limitPoint` and
invoke Mathlib's `MulAction.sum_card_fixedBy_eq_card_orbits` (verify exact name in
the project's Mathlib). **Why now?** `isFix_equiv` + `limitPoint_equivariant` give
the action and its compatibility with fixed points; only the orbit-counting wrapper
is missing. **If true**: yields a closed-form count of *essentially distinct*
minima found by symmetric descent (e.g. neural-net neuron-permutation symmetry).
**If false**: reveals that energy-invariance alone does not make the action
well defined on basins, isolating the missing hypothesis.

### Direction 3: Quantum deformation of basin counting (WDVV test)
**Hypothesis**: Define `Q(q) = Σ_paths q^{length}` over descent paths and a
`q`-deformed product on basins; then `prod_fixedPoint_count` is the `q→1` limit, and
the deformed product satisfies an associativity (WDVV) relation iff the basin
structure carries a quantum-cohomology ring.
The key insight is that multiplicativity of classical basin counts
(`prod_fixedPoint_count`) is precisely the classical limit of quantum
multiplicativity, so deforming the product is the natural next algebraic step.
**Test**: compute `Q(q)` symbolically for a handful of explicit small `DescentSystem`s
and check the WDVV relation by `decide`/`norm_num` on rationals. **Why now?** We now
have a rigorous, computable classical count to deform. **If true**: strong evidence
for the Gromov–Witten analogy motivating the whole program. **If false** (WDVV fails
generically): the strong GW conjecture is refuted, which is itself a clean negative
result.

### Direction 4: Real-valued / Łojasiewicz Lyapunov functions
**Hypothesis**: Replace `energy : S → ℕ` with `energy : S → ℝ` plus a *uniform* gap
`∃ δ > 0, step s ≠ s → energy s − energy (step s) ≥ δ`; then descent still reaches a
fixed point in at most `⌈(energy s − min energy)/δ⌉` steps and the Basin Fixed Point
Theorem survives unchanged.
The key insight is that the integer iteration bound used in `step_iterate_isFix`
generalizes to any *quantized* strict decrease, and a uniform gap is the minimal
hypothesis that restores quantization over `ℝ`. **Test**: re-prove
`step_iterate_isFix` with the `ℝ`+gap hypothesis using a `Nat.ceil` bound. **Why
now?** The current proof's only use of `ℕ` is the discreteness of the decrease; the
gap hypothesis isolates exactly that dependence. **If true**: bridges to continuous
optimization. **If false**: shows the discreteness is essential, not cosmetic.

### Direction 5: Continuous basin theory via Łojasiewicz gradient flow
**Hypothesis**: For a real-analytic loss on `ℝⁿ`, the Łojasiewicz inequality
`|∇L(θ)|² ≥ c |L(θ) − L(θ*)|^α` forces gradient-flow trajectories to have finite
length and converge, yielding a continuous basin map whose fibers partition a
neighborhood of the critical set — the continuous Basin Fixed Point Theorem.
The key insight is that the Łojasiewicz inequality is the continuous analogue of our
`strict_descent`/uniform-gap axiom: both forbid stalling at non-critical points, so
"bounded orbit length → Cauchy → convergence" mirrors our discrete
"iterate count bounded → fixed point". **Test**: state the Łojasiewicz–Simon
inequality in Mathlib's analysis API and prove finite trajectory length implies
convergence. **Why now?** Direction 4 produces the exact intermediate abstraction
(quantized-decrease descent) whose continuous limit this is. **If true**: extends
the theory to the setting of actual neural-network training. **If false**: identifies
which regularity (analyticity vs. smoothness) the convergence genuinely requires.
