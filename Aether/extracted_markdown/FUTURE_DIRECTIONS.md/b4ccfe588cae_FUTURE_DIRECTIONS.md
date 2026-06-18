# Future Directions: Valuation-Depth Ultrametric Geometry on Simulation Degrees

## Synthesis

This cycle bridged three previously separate strands of the catalog — the order-theoretic
Cook–Reckhow p-simulation preorder (`Catalog/Logic/ProofComplexity/SimulationPreorder.lean`,
`SimulationDegrees.lean`), the non-archimedean valuation-depth machinery
(`Catalog/Computation/PadicValuationDepth.lean`), and the tropical-to-ultrametric pipeline
(`Catalog/Bridges/CategoricalTropicalUltrametric.lean`) — into a single quantitative object:
an honest ultrametric geometry sitting on top of the simulation preorder
(`Catalog/Bridges/ProofComplexityUltrametric.lean`).

The central scientific result of the cycle is *negative-then-positive*, and it is exactly the
falsifiable fork the original proposal anticipated. We first tried to define the separation
invariant from the **polynomial blow-up exponent** carried by a simulation witness. We then
proved (`depth_not_idempotent`, with `compWitness_exp`) that this exponent composes
*multiplicatively*: composing two identity witnesses of exponent `1` produces a witness of
exponent `2 > max(1,1)`. Multiplicative composition can never satisfy the idempotent `max`
law an ultrametric demands, so the naive exponent valuation is *not* an ultrametric. This is
a genuine, machine-checked refutation of the most obvious encoding.

The positive half rescues the program by relocating the geometry. Instead of measuring the
exponent, we measure the **size profile** of a system (`sizeProfile`) with a first-difference
valuation `firstDiff : (ℕ→ℕ) → (ℕ→ℕ) → ℕ∞` — a Krull-style valuation whose strong triangle
inequality (`firstDiff_min_le`) is genuinely idempotent. Pushing this through the antitone
weight `edval` yields a real ultrametric `udist` with the sharp laws
`udist_strong_triangle` and `udist_eq_zero_iff`. We then proved that the catalog's own
separated pair `linSystem`/`fibSystem` sits at strictly positive ultrametric distance
(`udist_lin_fib_pos`), upgrading the qualitative separation `exists_separated_pair` to
quantitative geometry, and recorded the coarse degree distance `simSep` whose zero-set is
exactly mutual simulation.

## Results Summary

- `firstDiff` / `firstDiff_min_le`: a non-archimedean (Krull) valuation on size profiles
  with the genuine ultrametric inequality `min(d(a,b), d(b,c)) ≤ d(a,c)`.
- `udist` / `udist_strong_triangle` / `udist_eq_zero_iff` / `udist_comm`: a real ultrametric
  on size profiles, with `d = 0 ↔` equality of profiles.
- `SimWitness` / `idWitness` / `compWitness` / `compWitness_exp`: quantitative simulation
  witnesses carrying their `PolyBounded` growth certificate, with composition built on the
  catalog's `polyBounded_comp`.
- `depth_not_idempotent`: the explicit counterexample showing exponent-depth is *not*
  max-subadditive, isolating why the ultrametric must live on the profile, not the exponent.
- `udist_lin_fib_pos`: geometric (positive-distance) separation of the catalog's
  `linSystem` and `fibSystem`.
- `simSep` / `simSep_strong_triangle` / `simSep_eq_zero_iff`: the coarse discrete
  ultrametric descending to p-degree classes (its kernel is `PEquiv`).

All main results are `sorry`-free and use only the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`).

## Research Directions

### 1. A canonical, witness-independent profile distance that is simulation-invariant

The current `udist` is defined on *profiles*, and `sizeProfile` depends on a choice of proof
selector. The natural next object is a distance `D([P],[Q])` on p-degree classes obtained by
taking the infimum of `udist` over admissible selectors / witnesses, and proving it is
well-defined on `PEquiv`-classes and still ultrametric. **The key insight is that mutual
simulation should collapse exactly the *tail* of the size profile, so the first-difference
valuation should descend to degree classes up to a bounded, polynomially-controlled shift of
indices** — making the quotient distance a genuine invariant rather than a representative
artifact. This is falsifiable: if two p-equivalent systems can be built whose every size
profile disagrees at index `0`, the infimum distance is `1` and no nontrivial descent exists.
**Why now?** We already have `simSep` (the coarse `{0,1}` descent) and `udist` (the fine,
non-invariant one) proved in the same file; the only missing ingredient is the
quotient-compatibility lemma, and `pEquiv_iff_antisymmRel` from `SimulationDegrees.lean`
gives the exact `Antisymmetrization` target to descend onto.

### 2. The correct "witness semiring": min-plus exponents instead of multiplicative degree

`depth_not_idempotent` shows multiplicative exponents fail. The conjecture is that replacing
the exponent by its **iterated logarithm** (or, equivalently, working in the min-plus/tropical
semiring of growth *rates* rather than degrees) restores an exact ultrametric on witnesses,
because within the polynomial class all witnesses share one tropical growth level.
**The key insight is that polynomial composition multiplies degrees but *adds* log-degrees and
*fixes* iterated-log levels, so the unique idempotent invariant of the polynomial blow-up is
its tropical growth class, which is constant on the whole polynomial class** — predicting a
*degenerate-but-exact* ultrametric on witnesses that becomes nontrivial only across
super-polynomial classes. It is falsifiable: exhibit two polynomial witnesses with distinct
iterated-log levels and the conjecture dies. **Why now?** `CategoricalTropicalUltrametric.lean`
already supplies the `TropicalValuationObject` API (`add_eq_max'`, `max_idem`) into which such
a tropical growth invariant would be packaged, and our `compWitness_exp` pins down the exact
multiplicative law to be tropicalized.

### 3. Ultrametric separation forces super-polynomial lower bounds (a geometric Cook–Reckhow)

We proved `udist_lin_fib_pos` from a Fibonacci (super-polynomial) lower bound. The structural
conjecture reverses this: *any* pair of proof systems at positive **degree** distance
(direction 1) must be separated by a super-polynomial size lower bound on some theorem family,
and conversely. **The key insight is that the zero-set of the descended ultrametric is exactly
the polynomial-simulation kernel, so positive distance is logically equivalent to the
non-existence of a polynomial blow-up — i.e. to a super-polynomial separation witness in the
sense of `no_simulation_of_hard`.** This is sharply falsifiable: a positive-distance pair with
only polynomial gaps would break it. **Why now?** `SimulationDegrees.lean` already isolated
`no_simulation_of_hard` as the single growth-theoretic engine behind every separation, and our
`simSep_eq_zero_iff` ties the distance's kernel to `PEquiv`; chaining the two would yield a
geometric reformulation of the Cook–Reckhow separation program.

### 4. Completeness and the space of p-degrees as an ultrametric (Polish?) space

Equip the set of p-degrees with the descended ultrametric of direction 1 and ask whether it is
**complete**, and whether the Fibonacci/super-polynomial hierarchy embeds as a discrete
sequence converging to a limit degree. **The key insight is that first-difference ultrametrics
on `ℕ → ℕ` are always complete (Cauchy sequences stabilize on every coordinate), so the only
obstruction to completeness of the degree space is whether the *quotient* preserves limits —
which reduces to a closedness property of `PEquiv` under coordinatewise profile limits.** It is
falsifiable by producing a profile-Cauchy sequence of degrees whose coordinatewise limit is not
itself realized by any proof system. **Why now?** Mathlib's `UniformSpace`/`CompleteSpace`
and ultrametric (`IsUltrametricDist`) infrastructure is available under the same `import
Mathlib`, and our `firstDiff`/`udist` are already in the exact shape those typeclasses expect.

### 5. Functorial transfer into the certified tropical–ultrametric pipeline

Package a simulation degree (with its descended profile distance) as an object of
`TropicalValuationObject` / build a structure-preserving map into the `UltraNormObj` world of
`CategoricalTropicalUltrametric.lean`, so that quantitative simulation bounds become certified
ultrametric/robustness bounds in that file's sense. **The key insight is that the proposal's
'valuation reconstruction is a quantitative functor' principle applies verbatim here: the
first-difference valuation *is* tropical (min = idempotent add), so the reconstruction
functor should carry `udist_strong_triangle` to an `UltraNormObj` seminorm with no new
arithmetic.** It is falsifiable: if the reconstruction fails to preserve the strong triangle
(e.g. because profile composition is not monotone for the relevant maps), the functor does not
exist. **Why now?** Both endpoints now live in `Catalog/Bridges/`: the source object
(`udist` + `firstDiff`) was built this cycle, and the target API
(`TropicalValuationObject`, `add_eq_max'`, `max_idem`, `max_assoc`) is already proven, so the
bridge is a matter of constructing one functor and checking the axioms it already exposes.
