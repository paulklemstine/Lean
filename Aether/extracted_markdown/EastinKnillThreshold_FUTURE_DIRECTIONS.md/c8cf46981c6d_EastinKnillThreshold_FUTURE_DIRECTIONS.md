# Future Directions: Eastin–Knill and the Fault-Tolerance Threshold

The file `Catalog/Physics/EastinKnillThreshold.lean` formalizes two cornerstones
of fault-tolerant quantum computing as clean mathematical objects: the
doubly-exponential concatenation recursion `q_{n+1} = q_n²` (with its sharp
threshold trichotomy at `c·p = 1`, i.e. `p_th = 1/c ≈ 1%` for `c ≈ 100`), and an
abstract group-theoretic core of the Eastin–Knill no-go theorem
(`eastin_knill_not_universal`: a finite transversal-gate group cannot exhaust an
infinite logical unitary group). It synthesizes naturally with the catalog's QEC
ecosystem — `StabilizerBounds.lean` (Hamming/Singleton parameter bounds),
`GaugeCodeDistance.lean` (distance from spectral gaps), and `ToricCode.lean`
(CSS codes). Below are five testable extensions.

## 1. Higher-distance codes give super-quadratic suppression

For a distance-`d` code each fault-tolerant gadget needs `t+1 = ⌊(d-1)/2⌋+1`
faults to fail, so the recursion generalizes to `p_{n+1} = c · p_n^{t+1}`, and the
rescaled rate obeys `q_n = q_0^{(t+1)^n}` — the exponent base is the code's
error-correcting radius plus one, directly linking `CodeParams.t` from
`StabilizerBounds.lean` to the convergence speed. The conjecture: below threshold,
`errorRateD c p (t+1) n ≤ (1/c) · (c·p)^{(t+1)^n}`, with the threshold value
`p_th = c^{-1/t}` strictly increasing in `d`.

**The key insight is** that distance enters the threshold *exponent*, not just the
prefactor, so even modest increases in `d` widen the basin of convergence
multiplicatively. **Why now?** The present `errorRate_rescaled` proof is a clean
induction over `q_n = q_0^{2^n}`; replacing `pow_mul` with the general
`(t+1)^n` exponent is a direct, low-risk generalization that immediately couples
to the already-formalized `CodeParams.t`.

## 2. Quantitative resource overhead: the polylog(1/ε) law

Inverting the doubly-exponential law gives the number of concatenation levels
needed to reach target logical error `ε`: `L(ε) = ⌈log₂ log_q(1/ε)⌉`, and hence a
physical-qubit overhead that is *polylogarithmic* in `1/ε`. Formalize
`levels_for_target c p ε` and prove `errorRate c p (levels_for_target c p ε) ≤ ε`
whenever `c·p < 1`, then bound the overhead `N(ε) ≤ poly(log(1/ε))`.

**The key insight is** that the inverse of a tower of exponentials is a tower of
logarithms, converting the convergence theorem into an explicit, certified
resource estimate. **Why now?** We already have `errorRate_closed_form` in closed
form, so the inversion is pure real-analysis bookkeeping (monotonicity of `log`)
with no new quantum input required.

## 3. Eastin–Knill made quantitative: continuity-bound approximate gates

The exact no-go (`eastin_knill_not_universal`) admits a quantitative refinement:
transversal gates can approximate a target unitary `U` only to accuracy bounded
below by the code distance, `‖U_transversal − U‖ ≥ f(d)`. Formalize a metric/normed
group `G`, a finite subgroup `T`, and prove a positive covering radius
`∃ ε>0, ∀ t∈T, dist t g ≥ ε` for some `g`, recovering "no dense finite subgroup"
as the limiting `ε→0` statement.

**The key insight is** that finiteness forces a strictly positive covering radius
in any nondiscrete topological group, turning a Boolean impossibility into a
continuous obstruction that quantifies *how far* transversal gates miss
universality. **Why now?** Mathlib's `Metric`/`Subgroup` API and the existing
`eastin_knill_proper` (proper-subset) result give exactly the topological scaffold
needed to state and attack the covering-radius bound.

## 4. Threshold from the gauge spectral gap

`GaugeCodeDistance.lean` proves code distance `d ≥ Δ·L` from the spectral gap `Δ`.
Combining with Direction 1's `p_th = c^{-1/t}` and `t = ⌊(d-1)/2⌋` yields a
*gap-controlled threshold*: `p_th(L) → 1` as `Δ·L → ∞`. Conjecture and formalize
`Tendsto (fun L => thresholdOfDistance (gap_distance Δ L)) atTop (𝓝 1)` for fixed
`Δ > 0`.

**The key insight is** that the spectral gap of the parent gauge Hamiltonian
directly sets the asymptotic fault-tolerance threshold, bridging condensed-matter
physics (gaps) and computer science (thresholds) inside one Lean statement.
**Why now?** Both endpoints already exist in the catalog (`spectral_gap → distance`
in `GaugeCodeDistance.lean`, and `distance → threshold` here), so the bridge is a
composition of two proven monotonicities.

## 5. Two-sided sharpness: the threshold as an exact phase boundary

Strengthen the trichotomy into an `iff`: `c·p < 1 ↔ Tendsto (errorRate c p) atTop (𝓝 0)`
(for `0 ≤ p`, `0 < c`), establishing `p_th = 1/c` as the *exact* phase boundary
with no gap between the convergent and divergent regimes. The forward direction is
`errorRate_subthreshold_tendsto_zero`; the converse follows because at/above
threshold the sequence is bounded below by `1/c > 0` (from `errorRate_at_threshold_const`
and `errorRate_superthreshold_tendsto_top`).

**The key insight is** that the linearized recursion `q_{n+1} = q_n²` has a single
unstable fixed point at `q = 1`, so the dynamical-systems dichotomy is exact —
there is no critical slowing-down window. **Why now?** All three regimes are
already formalized in this file; assembling them into a biconditional is a finite
case-split that certifies sharpness with zero new analytic machinery.
