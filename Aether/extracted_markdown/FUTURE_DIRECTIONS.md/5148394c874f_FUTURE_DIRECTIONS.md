# Future Directions: Stereographic Capacity Theory — the Metric Backbone

## Synthesis

This cycle closed the **metric** half of stereographic capacity theory. Where the
existing module `Theorems.lean` linearized *rotation* of the circle into the rational
addition law `(t+s)/(1−ts)`, the new file `Metric.lean` linearizes *distance*. The
keystone is the exact chordal-distance formula for the inverse stereographic chart
`σ t = (2t/(1+t²), (1−t²)/(1+t²))`:

  ‖σ s − σ t‖² = 4 (s − t)² / ((1 + s²)(1 + t²)).

Everything else is a corollary of this one algebraic identity together with the sign of
the conformal weight `w(s,t) = ((1+s²)(1+t²))⁻¹`:

- `w ≤ 1` gives the **global 2-Lipschitz upper bound** (`chordSq_sigma_le`);
- `w ≥ (1+A²)⁻²` on `[−A,A]` gives the **windowed lower bound** (`chordSq_sigma_ge`);
- these two bounds become the **two-way packing transfer theorems**
  (`stereo_packing_pushforward`, `stereo_packing_pullback`), the dictionary that turns
  plane codes into spherical codes and back;
- the abstract `chordSq_conformal_le` proves the upper bound from the conformal identity
  *with no reference to dimension*, isolating the template that lifts to `Sⁿ`;
- and `chordSq_sigma_tendsto_zero` proves the windowed factor `(1+A²)⁻²` is unavoidable
  — two unit-separated plane points become chordally indistinguishable near the north
  pole.

This is exactly the dual-translation methodology of the engine: a *geometric* object
(distance on the sphere) is represented as a *rational algebraic* object (a weighted
square on the line), and packing — a hard combinatorial/geometric problem on the sphere
— is transported to a pigeonhole problem on the line.

## Results Summary (all proved, sorry-free, standard axioms only)

1. `chordSq_sigma` — exact chordal-distance formula (the metric backbone).
2. `chordSq_sigma_le` — global 2-Lipschitz upper bound.
3. `chordSq_sigma_ge` — windowed bi-Lipschitz lower bound on `[−A,A]`.
4. `chordSq_conformal_le` — dimension-free algebraic shadow of the upper bound.
5. `stereo_packing_pushforward` — plane code ⟹ spherical (chordal) code.
6. `stereo_packing_pullback` — spherical (chordal) code ⟹ plane code.
7. `chordSq_sigma_tendsto_zero` — sharpness: no global lower bound exists.

## Research Directions

### 1. The dimension-free chordal formula on `Sⁿ`

Define `σ : EuclideanSpace ℝ (Fin n) → EuclideanSpace ℝ (Fin (n+1))` explicitly and prove
`dist (σ x) (σ y)² = 4 ‖x − y‖² / ((1+‖x‖²)(1+‖y‖²))` by reducing the norm-squared to a
`Finset.sum` of coordinatewise squares. The Lipschitz half is *already done*:
`chordSq_conformal_le` discharges it the instant the conformal identity is in hand.
**The key insight is** that the chordal formula is purely algebraic — it never uses the
dimension beyond expanding `‖·‖²` as a finite sum, so the `n = 1` `field_simp; ring`
proof of `chordSq_sigma` is a template that lifts through `Finset.sum`.
**Why now?** Mathlib's `EuclideanSpace`/`PiLp` norm-squared lemmas make the sum
manipulation routine, and `chordSq_conformal_le` already encapsulates the only inequality
step, so the remaining work is a single sum-of-squares identity.

### 2. A quantitative spherical-cap packing bound (Hamming-type)

Combine `stereo_packing_pullback` with a grid/volume count to bound the cardinality of a
chordal `ρ`-code living in a stereographic window: a chordal `ρ`-code pulls back to a
`ρ/2`-separated plane code, whose size inside `[−A,A]` is `≤ 4A/ρ + 1` (and `(4A/ρ+1)ⁿ`
in dimension `n`). Formalize `(window code).card ≤ ⌊4A/ρ⌋ + 1`.
**The key insight is** that separation lower bounds turn packing into a pigeonhole over a
grid: disjoint intervals of length `ρ/2` inside `[−A,A]` are counted by length, no
curvature integral required.
**Why now?** `stereo_packing_pullback` already converts the spherical separation into a
clean Euclidean separation, and Mathlib has the `Finset.card`/interval-counting lemmas
needed for the volume step.

### 3. Möbius-invariance of the capacity functional

Define `capacity C = min over distinct pairs of chordSq (σ s) (σ t)` for a finite
`C ⊆ ℝ`, and prove it is invariant under the subgroup of Möbius maps of the line coming
from rigid rotations of `S¹` (the `stereoAdd`/`stereoRot` action from `Theorems.lean`),
while ordinary dilations only rescale it by a controlled factor.
**The key insight is** that the conformal weight `((1+s²)(1+t²))⁻¹` is exactly the
Jacobian density making chordal — not Euclidean — distance rotation-invariant; capacity
must be phrased chordally to be a genuine sphere invariant.
**Why now?** `Theorems.lean` already supplies the rotation action (`stereoRot_mul`,
`stereoAngle_stereoAdd`) and this file supplies the chordal metric, so the invariance is
a *bridge* connecting two existing modules through `chordSq_sigma`.

### 4. Hyperbolic ↔ spherical capacity duality (`κ`-family)

The weight `(1+‖x‖²)⁻¹` is the `κ = +1` member of the rational family
`1/(1 − κ‖x‖²)`; the Poincaré factor `(1−‖x‖²)⁻¹` is `κ = −1`. Generalize
`chordSq_conformal_le` to a single `κ`-parametrized inequality whose `κ = +1` instance is
the spherical Lipschitz bound and whose `κ = −1` instance is the hyperbolic
`radialDistortion` bound, with `κ = 0` the flat case.
**The key insight is** that all three constant-curvature packing distortions are the same
rational function evaluated at `κ ∈ {−1,0,+1}`, so one parametrized lemma subsumes the
spherical theorem here and the hyperbolic distortion in `HyperbolicDisk/Core.lean`.
**Why now?** Both endpoint frameworks now exist in the catalog (spherical in `Metric.lean`,
hyperbolic in `HyperbolicDisk`), so the unifying family is an immediate synthesis target
rather than new foundational work.

### 5. The optimal exponent of `A` in the windowed lower bound

`chordSq_sigma_ge` carries `(1+A²)⁻²` and `chordSq_sigma_tendsto_zero` shows it degenerates
to `0`. Sharpen this into a *rate*: prove `chordSq (σ (t+1)) (σ t)` is asymptotically
`4 t⁻⁴` (i.e. `lim t⁴ · chordSq = 4`), establishing that the exponent `2` on `(1+A²)` is
exactly optimal and quantifying the metric singularity at infinity.
**The key insight is** that the exact formula reduces a "sharpness" claim to a concrete
`Filter.Tendsto` computation of a rational function, so the optimal exponent is provable,
not heuristic.
**Why now?** `chordSq_sigma` already collapses the chordal distance to an explicit
rational expression, and the limit infrastructure used in `chordSq_sigma_tendsto_zero`
(`tendsto_pow_atTop`, `Tendsto.div_atTop`) extends directly to the weighted limit.
