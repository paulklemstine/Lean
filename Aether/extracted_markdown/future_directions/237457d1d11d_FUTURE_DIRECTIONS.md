# Future Directions — The Extended Interleaving Metric (Boltzmann Bridge V)

## Synthesis

`Applications/BoltzmannBridge/InterleavingMetric.lean` completes the catalog's
persistent-homology arc. Boltzmann Bridge II–IV built the filtration calculus
(`HigherPersistence`), the structural stability lemmas (`PersistenceStability`),
and a real-valued interleaving pre-distance (`BottleneckStability`). The fourth
file proved that pre-distance symmetric, grounded, and `1`-Lipschitz in the data,
but its own *Failure analysis* flagged a genuine defect: with `sInf ∅ = 0` the
real-valued `interleavingDist` violates the triangle inequality, because two
never-interleaved filtrations are dishonestly reported at distance `0`.

This cycle resolves that defect at the root. By moving the codomain to the
extended nonnegative reals `ℝ≥0∞` — where `sInf ∅ = ⊤` faithfully records "no
interleaving" — the interleaving distance `einterleavingDist` becomes a true
**extended pseudo-metric**: `einterleavingDist_self`, `einterleavingDist_comm`,
and the now *unconditional* `einterleavingDist_triangle`. The Cohen-Steiner–
Edelsbrunner–Harer `1`-Lipschitz stability theorem and the entire Vietoris–Rips
layer lift verbatim (`einterleavingDist_le_supDist`, `vr_einterleavingDist_le`,
`cloud_einterleavingDist_le`), and `einterleavingDist_eq_ofReal_of_nonempty`
pinpoints exactly where the old and new theories agree.

The conceptual payload: the triangle inequality factors into the *relational*
additivity of interleavings (`Interleaved_trans`) and the *order-theoretic*
identity `sInf (A + B) = sInf A + sInf B` in `ℝ≥0∞` (`sInf_le_sInf_add_sInf`).
Interleaving distance is, at bottom, a graded-monoid infimum, and `ℝ≥0∞` is its
natural value object precisely because addition distributes over arbitrary
infima there — the same reason `edist` lives in `ℝ≥0∞`.

## Results Summary

- `einterleavingDist_self` / `einterleavingDist_comm` — diagonal vanishing and symmetry.
- `einterleavingDist_triangle` — the unconditional triangle inequality (closes BB-IV Future Direction 1).
- `sInf_le_sInf_add_sInf` — reusable `ℝ≥0∞` infimum-of-sumset lemma powering the triangle inequality.
- `einterleavingDist_le_supDist` — CESH `1`-Lipschitz stability in the extended metric.
- `vr_einterleavingDist_le` / `cloud_einterleavingDist_le` — Vietoris–Rips stability and a concrete certificate.
- `einterleavingDist_eq_ofReal_of_nonempty` — bridge to the catalog's real-valued distance.

## Research Directions

### 1. Package `einterleavingDist` as a `PseudoEMetricSpace` instance.
We have all three extended-metric axioms as standalone lemmas; the missing step
is to assemble a `PseudoEMetricSpace (Filtration α)` (or a quotient on which it is
a genuine `EMetricSpace`). The key insight is that `einterleavingDist` already
satisfies `edist`'s defining inequalities verbatim, so the instance is pure
bookkeeping — the only real choice is the equivalence "`einterleavingDist F G = 0`"
under which to quotient. Why now? Once it is a Mathlib `PseudoEMetricSpace`, the
entire `Metric`/`EMetric` toolbox (balls, completeness, uniform continuity,
Hausdorff distance) applies to persistence diagrams for free, turning scattered
TDA lemmas into instances of general topology.

### 2. Prove `einterleavingDist = 0 ⇔` filtrations agree on all sublevel sets.
The pseudo-metric is not yet separated: we should characterize its kernel exactly,
conjecturally `einterleavingDist F G = 0 ↔ ∀ t, F.sublevelFaces t = G.sublevelFaces t`
(equivalently, equal weight functions). The key insight is that a vanishing
infimum of admissible shifts forces arbitrarily small interleavings, and an
Archimedean/limit argument should collapse these to a strict `0`-interleaving.
Why now? This is the precise statement needed to upgrade Direction 1 from a
*pseudo*-metric to a metric on the natural quotient, and it isolates the only
genuinely analytic (as opposed to order-theoretic) content of the theory.

### 3. Establish a converse stability ("inverse Lipschitz") bound.
CESH stability is one-sided: closeness of data implies closeness of diagrams.
Conjecture a partial converse — `einterleavingDist (diamFiltrationOf d₁)
(diamFiltrationOf d₂)` *bounds below* a suitable functional of `d₁ - d₂` on the
simplices that actually realize the diameters. The key insight is that the
diameter map factors through a finite `sup'`, so the interleaving distance sees
exactly the *active* (diameter-realizing) pairs and nothing else. Why now? A
two-sided bound turns the `1`-Lipschitz inequality into a bi-Lipschitz
*equivalence* on a quotient of distance matrices, the first step toward an
isometry-type rigidity theorem for Vietoris–Rips filtrations.

### 4. Generalize from `ℝ≥0∞` weights to an ordered-semiring value object.
Both `sInf_le_sInf_add_sInf` and `Interleaved_trans` used only that the value
object is a complete lattice in which `+` distributes over `iInf`. The key
insight is that the whole interleaving-metric construction is parametric in such
a "complete ordered additive value object," so it should be reproved once over an
abstract `[CompleteLattice V] [OrderedAddCommMonoid V]` with `add_iInf`, recovering
`ℝ≥0∞`, lexicographic/tropical, and multi-parameter codomains as instances. Why
now? Multi-parameter persistence (where no single real-valued bottleneck distance
exists) is the central open frontier of TDA; an abstract value object is the
cleanest route to a *provably stable* multi-parameter interleaving distance.

### 5. Connect `einterleavingDist` to the Gromov–Hausdorff distance of the inputs.
The VR layer rests on the sup-norm distortion of distance matrices; the deeper
invariant is the Gromov–Hausdorff distance, which optimizes over correspondences.
Conjecture `einterleavingDist (diamFiltrationOf d₁) (diamFiltrationOf d₂) ≤ 2 ·
ENNReal.ofReal (d_GH ...)`. The key insight is that a correspondence with
distortion `ε` is exactly a relabeling under which the two matrices are `ε`-close
on matched pairs, so `vr_einterleavingDist_le` should compose with a quotient over
correspondences. Why now? This is the textbook CESH/Chazal–de Silva–Oudot
theorem; with the extended metric now in place, it is the natural capstone tying
the catalog's combinatorial persistence theory to honest metric geometry.
