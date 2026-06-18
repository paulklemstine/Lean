# Future Directions: Perturbation-Stable Generalization Bounds

## Synthesis

This cycle built `MachineLearning/PerturbedGeneralization.lean`, a cross-domain
bridge connecting two previously disconnected threads of the catalog: the
compression / Occam generalization bound of `MachineLearning/CompressionGeneralization.lean`
(`occamBound R C n δ = R + sqrt((C + log(1/δ))/(2n))`) and the Lipschitz
perturbation-stability theme of `MachineLearning/Stability.lean`. The synthesis
is the *perturbation-stable Occam bound* `perturbedOccamBound R C L ρ n δ =
occamBound (R + L·ρ) C n δ`, which certifies the true risk of a model evaluated
on inputs perturbed by up to `ρ` against an `L`-Lipschitz loss.

The central structural discovery is that robustness and generalization compose
*additively and without coupling*: the only modification to the entire
compression bound is a single scalar `L·ρ` inserted into the empirical-risk slot.
Everything downstream — the capacity penalty, the sample-complexity inversion,
the consistency limit, and crucially the overparameterization invariance —
carries over verbatim. The bridge theorem `perturbed_certificate` makes this
operational: a robustness certificate computed entirely on *clean* training data
(via Lipschitz averaging in `robust_empRisk_valid`) dominates the Occam bound on
*any* `ρ`-perturbed dataset, lifted by monotonicity of the bound in its risk slot
(`occam_mono_risk`). The consistency theorem `perturbed_bound_tendsto` reduces to
the catalog's `occam_gap_tendsto_zero` and shows robustness shifts the *limit* of
the bound to `R + L·ρ` while leaving the *rate* of convergence in `n` untouched —
a clean separation of the statistical and adversarial axes that parallels the
catalog's `memorization_gap_limit`.

What did not happen: no result required reproving any catalog lemma, and the
attempt to depend on `Stability.lean` directly failed because that file imports a
missing module (`MachineLearning.TopKRobustness.Defs`) and does not compile in
this checkout. We therefore re-derived a self-contained Lipschitz-perturbation
core (`lipschitz_perturbation_le`) rather than coupling to a broken file. The
heterogeneous generalization `robust_empRisk_heterogeneous` turned out to be
provable in this same cycle (per-example constants `L i`, radii `ρ i`, summed),
rather than remaining a conjecture — its boundary behaviour seeds the directions
below.

## Results Summary

- `lipschitz_perturbation_le`: proved — an `L`-Lipschitz loss rises by at most `L·ρ` under any perturbation of radius `≤ ρ`.
- `robust_empRisk_valid`: proved — the worst-case perturbed empirical risk over a finite dataset is `≤ R + L·ρ`, validating the robust-risk definition.
- `perturbed_ge_clean`: proved — adding a nonnegative robustness budget `L·ρ` can only loosen the certificate.
- `perturbed_gap_decomposition`: proved — the excess of the perturbed bound over clean risk splits exactly into robustness `L·ρ` plus the capacity penalty.
- `perturbed_collapse`: proved — with `ρ = 0` or `L = 0` the clean Occam bound is recovered.
- `perturbed_bound_tendsto`: proved — consistency: the bound converges to the robustness floor `R + L·ρ` as `n → ∞`.
- `perturbed_sample_complexity`: proved — once `n ≥ (C+log(1/δ))/(2ε²)`, the bound is within `ε` of the floor `R + L·ρ`.
- `occam_mono_risk`: proved — the Occam bound is monotone in its empirical-risk argument.
- `perturbed_certificate`: proved — the bridge: a clean-data certificate plus margin dominates the true perturbed bound on any `ρ`-perturbation.
- `perturbed_overparam_invariance`: proved — robustness does not reintroduce dependence on raw parameter count.
- `robust_empRisk_heterogeneous`: proved — per-example constants/radii give a refined bound controlled by `∑ L i · ρ i`.

## Research Directions

### Direction 1: Margin-gated robustness certificate (the genuine Stability bridge)
**Hypothesis**: If a top-`k` classifier has, at every training point, a score
margin exceeding `2K·ρ` (the `Stability.lean` condition), then its 0/1
classification loss is perturbation-invariant on the radius-`ρ` ball, so its
*robust* empirical risk equals its *clean* empirical risk and
`perturbedOccamBound` collapses to `occamBound` with `L·ρ = 0` in the
classification loss.
**Test**: First repair or re-derive `MachineLearning.TopKRobustness.Defs`
(currently missing) so `StrictTopKSet` and `topkMargin'` are available, then prove
`margin > 2K·ρ → robustEmpRisk = R` for the indicator loss and feed it through
`perturbed_collapse`.
**Why now**: `perturbed_collapse` and `perturbed_certificate` already provide the
exact slot (`L·ρ = 0`) where a margin hypothesis discharges the robustness term;
only the missing top-`k` definitions block the connection.
**If true**: It unifies the geometric (margin) and statistical (compression)
robustness stories into one certificate, recovering Stability.lean's results as a
special case of the generalization bound.
**If false**: It would reveal that margin-stability of *predictions* does not
control the *loss* used in the bound, isolating the surrogate-loss gap.

### Direction 2: Tightness of the `L·ρ` robustness term
**Hypothesis**: The additive term `L·ρ` in `perturbed_gap_decomposition` is tight:
there exists an `L`-Lipschitz loss and a perturbation of radius exactly `ρ` for
which the perturbed empirical risk equals `R + L·ρ`.
**Test**: Construct the linear loss `ℓ(x) = L·x` on `ℝ` with `y = x + ρ`; prove
equality in `lipschitz_perturbation_le`, lifting it to equality in
`robust_empRisk_valid`.
**Why now**: `lipschitz_perturbation_le` is stated as an inequality; the witness
is a one-line linear function, so a matching lower bound is immediately in reach.
**If true**: It upgrades the certificate from an upper bound to an exact
worst-case characterization, closing the gap between guarantee and adversary.
**If false**: It would show the bound is loose and that a sharper, curvature-aware
robustness term (Direction 3) is necessary.

### Direction 3: Second-order (curvature) robustness refinement
**Hypothesis**: For a `C²` loss with Hessian bounded by `M`, the worst-case
perturbed risk obeys the sharper `R + ‖∇ℓ‖·ρ + (M/2)·ρ²`, strictly improving the
first-order `L·ρ` term when `ρ` is large relative to the gradient.
**Test**: Replace `LipschitzWith` by a Taylor/`HasDerivAt` hypothesis and prove a
second-order analogue of `lipschitz_perturbation_le`, then thread it through the
existing bound machinery.
**Why now**: The whole pipeline (`robust_empRisk_valid` → `occam_mono_risk` →
`perturbed_certificate`) depends on the per-point bound *only as a black box*, so
swapping in a tighter per-point estimate immediately upgrades every downstream
theorem.
**If true**: It yields the first curvature-aware compression-robustness bound and
quantifies when flat minima (small `M`) certifiably improve robust
generalization.
**If false**: It would indicate the linear `L·ρ` term already dominates the
curvature contribution in the relevant regime.

### Direction 4: Heterogeneous boundary — when the certificate becomes vacuous
**Hypothesis**: In the heterogeneous setting `robust_empRisk_heterogeneous`, if
some per-example budget `L i · ρ i` exceeds that example's margin, the
*classification* certificate becomes vacuous even though the *risk* bound remains
valid; the fraction of such examples upper-bounds the certified robust error.
**Test**: Define a per-example "certified" indicator and prove the robust 0/1
error is `≤ (#{i : L i · ρ i ≥ margin_i}) / card`, combining
`robust_empRisk_heterogeneous` with a counting argument.
**Why now**: `robust_empRisk_heterogeneous` already isolates the per-example terms
`L i · ρ i`; the boundary is exactly the comparison of each term against a margin.
**If true**: It produces a non-uniform, example-adaptive robustness certificate —
the natural data-dependent strengthening of the uniform bound.
**If false**: It would show the per-example decomposition does not localize the
failure set, forcing a global rather than example-wise robustness account.

### Direction 5: Robust PAC-Bayes via the same composition
**Hypothesis**: The additive-`L·ρ` composition is not special to the Occam bound;
applied to a PAC-Bayes KL bound it yields `robustKL = cleanKL + L·ρ` with all
monotonicity and consistency properties preserved.
**Test**: Locate the catalog's PAC-Bayes bound (`MachineLearning/PACBayes/Bounds.lean`),
abstract the "monotone in empirical risk" property that `occam_mono_risk`
encodes, and re-instantiate `perturbed_certificate` against it.
**Why now**: `perturbed_certificate` uses the underlying bound only through
`occam_mono_risk` (monotonicity in the risk slot), a property PAC-Bayes bounds
also satisfy, so the bridge should transfer mechanically.
**If true**: It establishes that perturbation-stability is a *generic* transform
on any risk-monotone generalization bound, not an artifact of compression.
**If false**: It would expose a structural feature of the Occam bound (e.g. the
specific sqrt penalty) that the composition secretly relied on.
