# Future Directions: Descent Basin Theory

## Synthesis

This cycle built the `DescentSystem` abstraction from scratch (the catalog had no
prior basin/descent infrastructure, so this was a cold start) and proved the
**Basin Fixed Point Theorem**: for a state space equipped with a discrete dynamics
`step` and a `ℕ`-valued Lyapunov ("energy") function that strictly decreases away
from fixed points, the number of basins of attraction equals the number of fixed
points. The structural engine is a single induction (`isFix_of_iterate`): the
energy value is a literal upper bound on the worst-case length of a descent path,
so `step^[energy s] s` always lands on a fixed point. The key proof move was to
*generalize the step budget* — instead of inducting on the state `s`, we prove the
stronger statement "any budget `n ≥ energy s` reaches a fixed point" and induct on
`n`, which makes both the base case (`energy = 0 ⇒ fixed`) and the inductive step
(energy drops, so a smaller budget suffices on `step s`) immediate.

From this one lemma the whole edifice follows. The limit map `limitPoint` is well
defined (`limitPoint_isFix`), it is a retraction onto the fixed set
(`limitPoint_eq_self`, `limitPoint_limitPoint`), its range is *exactly* the
fixed-point set (`range_limitPoint_eq_fixedPoints` /
`image_limitPoint_eq_fixedPoints`), its fibers are the basins, and these basins
partition the space (`biUnion_basin_eq_univ`, `basin_disjoint`). The cleanest
structural insight is that **basins are literally the fibers of the limit map**, so
"counting basins" is a pure image/fiber computation rather than a dynamical one.

That fiber viewpoint made two extensions almost syntactic. Basin counts are
*multiplicative* across independent (synchronous product) subsystems
(`prod_fixedPoint_count`, via `fixedPoints (D₁ × D₂) = fixedPoints D₁ ×ˢ
fixedPoints D₂`), and they are *equivariant* under any energy-preserving symmetry
that commutes with the dynamics (`isFix_equiv`, `limitPoint_equivariant`). The
multiplicativity result is exactly the classical (`q = 1`) shadow of a conjectured
"quantum" deformation of basin counting, and the equivariance result supplies the
group action one needs to feed into a Burnside-style count of basins modulo
symmetry. What did *not* make it into this cycle: a real-valued (rather than
`ℕ`-valued) Lyapunov function, the Burnside count itself, and any higher-index
("Morse") critical-cell bookkeeping. The boundary where the current proof breaks is
precisely the move to `ℝ`-valued energy with only a *strict* (not quantized)
decrease — there the bound "`energy s` steps suffice" fails, and one needs a uniform
gap or a well-founded-recursion argument. That boundary seeds Directions 4 and 5.

## Results Summary

- `DescentSystem.isFix_of_energy_zero`: proved — energy-zero states are fixed (the descent base case).
- `DescentSystem.isFix_of_iterate`: proved — the descent engine; budget `n ≥ energy s` reaches a fixed point.
- `DescentSystem.limitPoint_isFix`: proved — every state flows to a fixed point.
- `DescentSystem.limitPoint_eq_self`: proved — fixed points are their own limit.
- `DescentSystem.limitPoint_limitPoint`: proved — the limit map is idempotent (a retraction).
- `DescentSystem.range_limitPoint_eq_fixedPoints`: proved — the basin↔fixed-point correspondence (set form).
- `DescentSystem.image_limitPoint_eq_fixedPoints`: proved — Finset form of the correspondence.
- `DescentSystem.basin_count_eq_fixedPoint_count`: proved — **the Basin Fixed Point Theorem** (#basins = #fixed points).
- `DescentSystem.mem_basin_self`, `basin_disjoint`, `biUnion_basin_eq_univ`: proved — basins partition the state space.
- `DescentSystem.prod_strict_descent`, `prod_isFix_iff`, `prod_fixedPoint_count`: proved — multiplicativity of basin counts across product subsystems.
- `DescentSystem.isFix_equiv`, `iterate_step_equiv`, `limitPoint_equivariant`: proved — energy-preserving symmetries permute fixed points and intertwine the basin map.

## Research Directions

### Direction 1: Equivariant basin counting via Burnside's lemma
**Hypothesis**: For a finite group `G` acting on `S` by energy-preserving symmetries
that commute with `step`, the number of basins modulo `G` equals
`(1/|G|) Σ_{g∈G} #{basins fixed by g}`, and a basin (fiber of `limitPoint`) is fixed
by `g` iff its limit point is a `g`-symmetric fixed point.
**Test**: package the `G`-action as a `MulAction` on `Set.range D.limitPoint` (built
from `limitPoint_equivariant` and `isFix_equiv`), then invoke Mathlib's orbit-counting
lemma (verify the exact name `MulAction.sum_card_fixedBy_eq_card_orbits` against the
project's Mathlib) for a closed-form count.
**Why now**: `isFix_equiv` + `limitPoint_equivariant` already give the action and its
compatibility with the fixed set; only the orbit-counting wrapper is missing. The key
insight is that equivariance of `limitPoint` *is* the statement that `G` acts on the
set of basins, so Burnside applies verbatim.
**If true**: yields a count of *essentially distinct* minima found by symmetric descent
(e.g. neuron-permutation symmetry in neural-net loss landscapes).
**If false**: reveals that energy-invariance + commutation alone do not make the
`G`-action well defined on basins, isolating the missing hypothesis.

### Direction 2: Quantum deformation of basin counting (WDVV test)
**Hypothesis**: Define `Q(q) = Σ_paths q^{length}` over descent paths and a `q`-deformed
product on basins; then `prod_fixedPoint_count` is the `q → 1` limit, and the deformed
product satisfies a WDVV-type associativity relation iff the basin structure carries a
quantum-cohomology-like ring.
**Test**: compute `Q(q)` symbolically for a handful of explicit small `DescentSystem`s
(e.g. on `Fin 3`, `Fin 4`) and check the WDVV relation by `decide`/`norm_num` over `ℚ`.
**Why now**: we now have a rigorous, computable classical count (`prod_fixedPoint_count`)
to deform. The key insight is that multiplicativity of classical basin counts is exactly
the classical limit of quantum multiplicativity, so deforming the product is the natural
next algebraic step.
**If true**: strong evidence for a Gromov–Witten-style analogy of descent landscapes.
**If false** (WDVV fails generically): a clean negative result refuting the strong analogy.

### Direction 3: Discrete Morse inequalities from descent decomposition
**Hypothesis**: Extend `DescentSystem` to track critical cells of *every* index (not just
minima) on a finite CW/simplicial complex, and prove the weak Morse inequality `b_k ≤ c_k`
(the k-th Betti number is bounded by the number of critical k-cells), together with the
Euler identity `Σ (−1)^k c_k = χ`.
**Test**: build a `DescentSystem` whose energy is a discrete Morse function on a small
complex (triangulated circle/torus), define `criticalCells k`, and prove `c_k ≥ b_k`.
**Why now**: `isFix_of_iterate` makes discrete gradient flow well defined and non-cycling,
and `basin_count_eq_fixedPoint_count` is precisely the index-0 case (`b_0 ≤ c_0`) of the
inequality. The key insight is that the fiber/partition structure of `limitPoint`
(`biUnion_basin_eq_univ`) is exactly the descending-cell decomposition whose alternating
sum computes the Euler characteristic.
**If true**: a genuine cross-domain bridge from this dynamics file to homological algebra.
**If false**: pinpoints which non-cycling hypothesis is too weak to control higher-index cells.

### Direction 4: Real-valued / uniform-gap Lyapunov functions
**Hypothesis**: Replace `energy : S → ℕ` with `energy : S → ℝ` plus a *uniform gap*
`∃ δ > 0, ∀ s, step s ≠ s → energy s − energy (step s) ≥ δ` and a lower bound
`∃ m, ∀ s, m ≤ energy s`; then descent still reaches a fixed point in at most
`⌈(energy s − m)/δ⌉` steps and the Basin Fixed Point Theorem survives unchanged.
**Test**: re-prove `isFix_of_iterate` with the `ℝ`+gap hypotheses using a `Nat.ceil`
bound in place of the literal `energy s`.
**Why now**: the current proof's *only* use of `ℕ` is the discreteness of the decrease;
the gap hypothesis isolates exactly that dependence. The key insight is that the integer
iteration bound generalizes to any *quantized* strict decrease, and a uniform gap is the
minimal hypothesis that restores quantization over `ℝ`.
**If true**: bridges the abstraction toward continuous optimization.
**If false**: shows the discreteness of `ℕ`-energy is essential, not cosmetic.

### Direction 5: Continuous basin theory via Łojasiewicz gradient flow
**Hypothesis**: For a real-analytic loss on `ℝⁿ`, the Łojasiewicz inequality
`|∇L(θ)|² ≥ c |L(θ) − L(θ*)|^α` forces gradient-flow trajectories to have finite length
and converge, yielding a continuous limit map whose fibers partition a neighborhood of the
critical set — the continuous Basin Fixed Point Theorem.
**Test**: state the Łojasiewicz–Simon inequality in Mathlib's analysis API and prove that
finite trajectory length implies convergence of the flow.
**Why now**: Direction 4 produces the exact intermediate abstraction (quantized-decrease
descent) whose continuous limit this is. The key insight is that the Łojasiewicz inequality
is the continuous analogue of our uniform-gap axiom: both forbid stalling at non-critical
points, so "bounded orbit length → Cauchy → convergence" mirrors our discrete "bounded
iterate count → fixed point".
**If true**: extends the theory to the setting of actual neural-network training.
**If false**: identifies which regularity (analyticity vs. mere smoothness) the convergence
genuinely requires.
