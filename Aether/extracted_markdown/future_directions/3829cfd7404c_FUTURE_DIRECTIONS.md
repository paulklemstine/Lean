# Future Directions: Stereographic Capacity Theory

The file `Geometry/StereographicCapacity.lean` establishes the metric backbone of
stereographic capacity theory: the exact chordal-distance formula

  ‖σ(x) − σ(y)‖² = 4‖x − y‖² / ((1 + ‖x‖²)(1 + ‖y‖²))

for inverse stereographic projection `σ`, together with its 2-Lipschitz upper
bound, its windowed bi-Lipschitz lower bound, and the two-way **packing transfer
theorems** that turn plane codes into spherical codes and back. These results
unify the catalog's `InverseStereo*` circle identities with the conformal-distortion
viewpoint of `HyperbolicPacking/Defs.lean`. The directions below are concrete,
falsifiable extensions that the next cycle can attack.

## 1. The dimension-free chordal formula

The circle (`ℝ → S¹`) and sphere (`ℝ² → S²`) cases are fully proved; the file
already records the general `n`-dimensional 2-Lipschitz statement
(`stereo_two_lipschitz_general`) under an abstract conformal hypothesis. The next
step is to discharge that hypothesis: define `σ : EuclideanSpace ℝ (Fin n) →
EuclideanSpace ℝ (Fin (n+1))` explicitly and prove
`dist (σ x) (σ y)² = 4 dist x y² / ((1+‖x‖²)(1+‖y‖²))` by reducing to the
coordinatewise sum-of-squares identity already used in dimensions 1 and 2.

**The key insight is** that the chordal formula is *purely algebraic* — it never
uses the dimension beyond expanding `‖·‖²` as a finite sum, so the `n = 1, 2`
`field_simp; ring` proofs are templates that lift through `Finset.sum`.
**Why now?** Mathlib's `EuclideanSpace` and `PiLp` norm-squared lemmas make the
sum manipulation routine, and the abstract `n`-dimensional shell is already in
place and compiling, so only the conformal identity remains.

## 2. A quantitative spherical-cap packing (Hamming-type) bound

Combine the packing transfer theorem with a volume/counting argument to bound the
number of points on `Sⁿ` whose pairwise chordal distance exceeds a threshold `ρ`.
Concretely: a chordal `ρ`-code pulls back (via `stereo_packing_pullback`) to a
`ρ/2`-separated plane code, whose cardinality inside `[−A,A]ⁿ` is bounded by a
volume ratio `(2A/(ρ/2) + 1)ⁿ`. Formalize this as
`(spherical code in a stereographic window).card ≤ (4A/ρ + 1)^n`.

**The key insight is** that separation lower bounds turn packing into a
*pigeonhole over a grid*: disjoint balls of radius `ρ/4` inside a box of side
`2A + ρ/2` can be counted by volume, no curvature integral required.
**Why now?** The pullback theorem already converts the spherical separation into a
clean Euclidean separation, and Mathlib has the box-counting / `Finset.card` and
measure-of-ball lemmas needed for the volume step.

## 3. Möbius-invariance of the capacity functional

Stereographic projection conjugates rigid rotations of `Sⁿ` to Möbius
transformations of `ℝⁿ ∪ {∞}`. Define the **stereographic capacity** of a finite
plane configuration as its minimum pairwise chordal distance, and prove it is
invariant under the subgroup of Möbius maps coming from sphere rotations, while
ordinary plane similarities only *rescale* it by a controlled factor.

**The key insight is** that the conformal weight `(1+‖x‖²)⁻¹` is exactly the
Jacobian density that makes chordal distance — not Euclidean distance — the
rotation-invariant metric; capacity must therefore be phrased in the chordal
metric to be a genuine sphere invariant.
**Why now?** The catalog's `InverseStereoMobiusNext.lean` already formalizes the
Möbius side of the dictionary, so this direction is a *bridge* connecting two
existing catalog modules through the new chordal formula.

## 4. Hyperbolic ↔ spherical capacity duality

The conformal factor here, `(1+‖x‖²)⁻¹`, is the formal `±` mirror of the Poincaré
factor `(1−‖x‖²)⁻¹` in `HyperbolicPacking/Defs.lean`. Prove a duality: a packing
bound in the spherical (positively curved) model maps, under `‖x‖ ↦ i‖x‖`
analytic continuation of the weight, to the hyperbolic `radialDistortion` bound,
giving a single curvature-parametrized inequality with `κ = +1, 0, −1` as special
cases.

**The key insight is** that all three constant-curvature packing distortions are
the *same rational function* `1/(1 − κ‖x‖²)` evaluated at `κ ∈ {−1,0,+1}`, so one
parametrized lemma subsumes the spherical theorem above and the hyperbolic
`radialDistortion` definition.
**Why now?** Both endpoint frameworks now exist in the catalog (spherical here,
hyperbolic in `HyperbolicPacking`), so the unifying `κ`-family is the immediate
synthesis target rather than new foundational work.

## 5. Sharpness: where the bi-Lipschitz lower bound degenerates

The windowed lower bound `chordSq_invStereo_ge` carries the factor `(1+A²)⁻²`,
which → 0 as the window `A → ∞`. Prove this degeneration is *unavoidable*:
exhibit sequences `sₖ, tₖ → ∞` with `|sₖ − tₖ| = 1` but `chordSq(σ sₖ, σ tₖ) → 0`,
establishing that no global (window-free) bi-Lipschitz lower bound exists, and
quantify the optimal exponent of `A`.

**The key insight is** that the point at infinity is a genuine metric singularity:
two unit-separated plane points become chordally indistinguishable near the north
pole, so the `(1+A²)⁻²` loss is the true rate, not an artifact of the proof.
**Why now?** The exact formula `chordSq_invStereo` makes the limit computation a
direct `Filter.Tendsto` calculation, turning a "sharpness" claim into a concrete
provable limit rather than a heuristic remark.
