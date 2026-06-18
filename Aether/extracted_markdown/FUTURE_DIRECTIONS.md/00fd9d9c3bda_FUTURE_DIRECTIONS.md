# Future Directions: Stereographic Capacity Theory

## Synthesis

This cycle built the **algebraic and order-theoretic backbone** of stereographic capacity
theory, in `Catalog/Geometry/StereographicCapacity/Theorems.lean`. The previous cycle
(`InverseStereoResearch.lean`) established *pointwise* facts about the chart
`invStereo t = (2t/(1+t²), (1-t²)/(1+t²))` — that it lands on `S¹`, is injective, and sends
`1/2` to the `(3,4,5)` triple. We upgraded those isolated facts to a **structure**: the
seemingly geometric act of *rotating a point on the circle* is, in the stereographic
coordinate, exactly the single rational binary law `stereoAdd t s = (t+s)/(1-ts)` — the
tangent half-angle / `arctan` formal group law. The central result `stereo_addition_law`
proves this is the sine/cosine angle-addition formula written rationally, and `stereoRot_mul`
realizes it as honest `2×2` rotation-matrix multiplication, the real-analytic shadow of the
catalog's integer `gaussian_matrix_compose` and `gaussian_det_multiplicative`.

The key structural insight is that one algebraic identity does all the work: the combined
denominator `(1-ts)² + (t+s)²` factors as `(1+t²)(1+s²)`. This single factorization is *why*
the half-angle substitution rationalizes trigonometry, why `stereoAdd` is associative
(`stereoAdd_assoc` — which, surprisingly, needs only the two inner denominators nonzero,
because after clearing them the identity is purely polynomial), and why `(ℝ, stereoAdd)` is a
partial abelian group with identity `0`. On the order side, `stereoAngle t = 2·arctan t` is a
strictly monotone order embedding (`stereoAngle_strictMono`) that intertwines `stereoAdd` with
ordinary `+` on the branch `t·s < 1` (`stereoAngle_stereoAdd`); we then pushed this to a
genuine *convexity* backbone, `stereoAngle_concaveOn_Ici`.

What failed / what the critique exposed: the convexity statement is **half-line local**, not
global. `stereoAngle` has an inflection point at `t = 0` (it is convex on `(-∞,0]` and concave
on `[0,∞)`), so a global `ConcaveOn ℝ` statement is false — the restriction to `Set.Ici 0` is
essential, not cosmetic. Likewise every multiplicative result carries the branch hypothesis
`1 - t·s ≠ 0` (resp. `t·s < 1`): these encode the single missing point `∞` of the one-point
compactification where the partial group law is undefined. The directions below are organized
around *removing these blemishes* (compactify to a total group) and *exporting the backbone*
to higher dimensions and to the catalog's number-theoretic constructions.

## Results Summary

- `invStereo_on_circle`: proved — the chart lands on the unit circle (local re-derivation of the catalog fact).
- `stereo_addition_law`: proved — **main result**: circle rotation equals the rational addition law in stereographic coordinates.
- `stereoRot_mul`: proved — the addition law is `2×2` rotation-matrix multiplication; cross-domain bridge to the catalog's Gaussian matrices.
- `stereoRot_det_one`: proved — the stereographic rotation matrix lies in `SO(2)` (`det = 1`).
- `stereoAdd_assoc`: proved — associativity of the addition law (needs only the inner denominators nonzero).
- `stereoAdd_comm`: proved — commutativity of the addition law.
- `stereoAdd_zero`: proved — `0` is the identity element.
- `stereoAngle_stereoAdd`: proved — `2·arctan` intertwines `stereoAdd` with ordinary `+` on the branch `t·s < 1`.
- `stereoAngle_strictMono`: proved — order-theoretic backbone: `stereoAngle` is a strictly monotone order embedding.
- `stereo_capacity_le_one`: proved — the horizontal capacity `2t/(1+t²)` is at most `1`.
- `stereo_capacity_eq_one_iff`: proved — the capacity equals `1` exactly at `t = 1`.
- `stereoAngle_concaveOn_Ici`: proved — convexity backbone: `stereoAngle` is concave on `[0,∞)` (and the global version is false).

## Research Directions

### Direction 1: Total group structure on the one-point compactification
**Hypothesis**: Defining `stereoAdd` on `ℝ ∪ {∞}` (the real projective line / one-point
compactification) with `stereoAdd t (1/t) = ∞` and `stereoAdd ∞ s = -1/s` yields a *total*
abelian group isomorphic to `SO(2,ℝ)` (equivalently the circle group), with `stereoAngle`
becoming a group isomorphism onto `ℝ / 2πℤ`.
**Test**: Define `StereoLine := Option ℝ`, extend `stereoAdd`, and prove the `AddCommGroup`
(or `CommGroup`) axioms, then build an explicit `MulEquiv`/`AddEquiv` to `Circle` or
`Real.Angle`. The partial results `stereoAdd_assoc`, `stereoAdd_comm`, `stereoAdd_zero` are
the affine-chart fragments; the work is the chart at `∞`.
**Why now**: This cycle proved associativity holds whenever the *inner* denominators are
nonzero — strong evidence the only obstruction is the single point `∞`, exactly what
compactification removes.
**If true**: It packages all the branch hypotheses (`1-t·s ≠ 0`, `t·s < 1`) into a clean,
hypothesis-free group isomorphism, and connects directly to Mathlib's `Real.Angle`.
**If false**: The failure would localize a genuine cocycle/`±π` obstruction, telling us the
half-angle law is only a *local* group law (a formal group that does not integrate globally).

### Direction 2: The capacity as a metric/Jensen functional
**Hypothesis**: For weights `wᵢ ≥ 0` summing to `1` and coordinates `tᵢ ≥ 0`, the averaged
stereographic angle satisfies `stereoAngle (∑ wᵢ tᵢ) ≥ ∑ wᵢ · stereoAngle tᵢ`, with equality
iff all `tᵢ` are equal — a Jensen inequality for stereographic capacity.
**Test**: Apply `ConcaveOn.le_sum`/`ConcaveOn.inner_smul_le_map_sum` (or the finite Jensen
lemma) to `stereoAngle_concaveOn_Ici`. The hard part is the equality case, which needs
*strict* concavity on `(0,∞)`.
**Why now**: `stereoAngle_concaveOn_Ici` was proved this cycle and is precisely the hypothesis
such a Jensen statement consumes.
**If true**: It gives a clean "capacity is super-additive under averaging" principle, a
quantitative companion to the qualitative order embedding.
**If false (no equality case)**: It would show concavity is non-strict somewhere on `[0,∞)`,
pinpointing where the second derivative `-4t/(1+t²)²` degenerates (only at `t=0`).

### Direction 3: Higher-dimensional addition law and the Hopf/parallelizability barrier
**Hypothesis**: The `n`-dimensional inverse stereographic chart `ℝⁿ → Sⁿ` admits a *bilinear-
denominator* rational addition law making `Sⁿ ∖ {pt}` a (partial) topological group **iff**
`n ∈ {0, 1, 3}` (degenerate, circle, and the unit quaternions), and the `n=3` law is exactly
quaternion multiplication transported through the chart.
**Test**: Formalize the `n=3` case first: define `invStereo₃ : ℝ³ → ℝ⁴` and a quaternionic
`stereoAdd₃`, and prove the analogue of `stereoRot_mul` using Mathlib's `Quaternion` API and
`Quaternion.normSq_mul`. Then state the non-existence for `n=2` as a falsifiable obstruction.
**Why now**: `stereoRot_mul` already exhibits the `n=1` law as norm-`1` complex multiplication;
the quaternion API mirrors the Gaussian-integer API the catalog already uses.
**If true**: A clean Lean witness that the circle and the `3`-sphere are *group* spheres while
`S²` is not — a formalized shadow of the Hopf-invariant / parallelizable-spheres theorem.
**If false**: A working `S²` law would be a genuine surprise demanding scrutiny of bilinearity.

### Direction 4: Rational points, the capacity, and sums of two squares
**Hypothesis**: `stereoAdd` restricts to a group operation on the *rational* coordinates
`t ∈ ℚ`, and under `invStereo` this is exactly the Brahmagupta–Fibonacci composition of
Pythagorean triples; consequently the subgroup generated by `t = 1/2` (the `(3,4,5)` point)
is infinite and its `invStereo`-images enumerate a Zariski-dense set of rational points on `S¹`.
**Test**: Show `t,s ∈ ℚ ⇒ stereoAdd t s ∈ ℚ` (immediate from the formula), then prove the
order of `invStereo (1/2)` in the rational circle group is infinite using
`stereoAngle_stereoAdd` plus irrationality of `arctan(1/2)/π` (a Niven-type result).
**Why now**: `stereo_addition_law` makes triple-composition a *theorem about one rational
function*, and `stereo_critical_line` from the previous cycle already pins `1/2 ↦ (4/5,3/5)`.
**If true**: It links the catalog's `euclid_pythagorean_from_stereo` and
`gaussian_det_multiplicative` into a single statement about a finitely-generated rational
rotation group.
**If false**: A finite orbit would force `arctan(1/2)` to be a rational multiple of `π`,
contradicting Niven's theorem — so the falsification route is itself a sharp test.

### Direction 5: Strict concavity and a sharp capacity modulus
**Hypothesis**: `stereoAngle` is *strictly* concave on `(0,∞)` with an explicit second-order
modulus: for `0 < a < b`, `stereoAngle((a+b)/2) - (stereoAngle a + stereoAngle b)/2 ≥ c·(b-a)²`
for a constant `c` depending on `b`, quantifying how fast capacity saturates.
**Test**: Strengthen `stereoAngle_concaveOn_Ici` to `StrictConcaveOn` via
`StrictConcaveOn`-from-`deriv2 < 0` on the *open* interval, then integrate the second-derivative
bound `|stereoAngle''(t)| = 4t/(1+t²)²` to extract `c`.
**Why now**: The proof of `stereoAngle_concaveOn_Ici` already computed the sign of the second
derivative; recovering its *magnitude* is a small additional step.
**If true**: It converts the qualitative convexity backbone into a quantitative one, enabling
error bounds for stereographic capacity approximations.
**If false at `t=0`**: The degeneration of strictness at the inflection point is itself the
content, sharpening Direction 2's equality analysis.
