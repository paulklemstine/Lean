# Future Directions: Compression-Based Generalization Bounds

The file `MachineLearning/CompressionGeneralization.lean` establishes the analytic
backbone of compression / minimum-description-length generalization theory: the
Occam bound `occamBound R C n δ = R + sqrt((C + log(1/δ))/(2n))`, its sample-complexity
inversion (`occam_sample_complexity`), the linear-in-bit-length compression law
(`compression_sample_complexity`), parameter-count invariance
(`overparam_invariance`, `overparam_can_beat_small`), statistical consistency
(`occam_gap_tendsto_zero`), and the memorization boundary (`memorization_gap_limit`).
These results sit alongside the catalog's PAC-Bayes development
(`MachineLearning/PACBayes/Bounds.lean`, `mcAllesterBound`, `pac_bayes_mcallester_bound`)
and the empirical Rademacher theory (`MachineLearning/RademacherComplexity.lean`).
The directions below are concrete, falsifiable next steps.

## 1. Derive the Occam bound from a finite-class union bound, not as an axiom

Right now `occamBound` is a *defined functional* whose monotonicity and limits we
prove; we do not derive the probabilistic guarantee that the true risk actually
lies below it. The next cycle should connect it to a genuine measure-theoretic
union bound: model a finite hypothesis class `H : Finset ι`, an i.i.d. sample, and
prove `Measure {ω | ∃ h ∈ H, trueRisk h > occamBound (empRisk h ω) (log |H|) n δ} ≤ δ`
via `measure_biUnion_finset_le` plus a Hoeffding tail (which can first be stated as
a hypothesis `hoeffding_tail` and discharged later).
**The key insight is** that the `log(1/δ)` term in our `occamBound` is *exactly* the
budget consumed by a Boole/union step over the description-length-weighted prior, so
the analytic object we already control is the deterministic shadow of one inequality.
**Why now?** Mathlib's `MeasureTheory` and `measure_biUnion_finset_le` are mature, and
our deterministic layer removes all the algebra from the probabilistic proof, leaving
only the tail bound to formalize.

## 2. Prove the compression bound is strictly tighter than any VC/parameter bound on overparameterized nets

`overparam_can_beat_small` shows the compression bound is governed by `bits`, not
`params`. The sharper claim is a *separation theorem*: exhibit a family of networks
`netₖ` with `params k → ∞` but `bits k` constant, and a parameter-count bound
`vcBound R params n δ` (monotone increasing in `params`), and prove
`∀ N, ∃ k, netₖ.params ≥ N ∧ netₖ.bound n δ < vcBound netₖ.empRisk netₖ.params n δ`,
with the gap diverging.
**The key insight is** that overparameterization is not a failure of capacity control
but a *change of the correct capacity measure*: description length stays bounded while
parameter count is unbounded, so any bound monotone in `params` must eventually be
beaten.
**Why now?** Both bound functionals are already monotone in their arguments in the
catalog, so the separation reduces to a clean asymptotic comparison provable with
`Filter.Tendsto` machinery already exercised in `occam_gap_tendsto_zero`.

## 3. Establish a phase transition in the consistency/memorization dichotomy

We proved two extremes: fixed complexity gives gap `→ 0` (`occam_gap_tendsto_zero`),
linear complexity `C n = c·n` gives gap `→ sqrt(c/2)` (`memorization_gap_limit`). The
unifying conjecture is a sharp threshold at sublinear growth: for `C n = n^α · L`,
the gap tends to `0` iff `α < 1`, to `sqrt(L/2)·[α=1]` at `α = 1`, and to `+∞` for
`α > 1`. Formalize `complexity_growth_phase_transition` as three `Tendsto` statements
parameterized by `α : ℝ`.
**The key insight is** that the generalization phase boundary is precisely the line
where description length grows at the same rate as the data, i.e. the learner stores
one fresh bit per example — a crisp information-theoretic order parameter.
**Why now?** The `α = 0` and `α = 1` cases are already theorems in the file; the
general case is the same `sqrt`-of-a-ratio limit with `tendsto_rpow_atTop`, which the
catalog already invokes.

## 4. Unify the Occam bound with the catalog McAllester PAC-Bayes bound

The catalog's `mcAllesterBound empRisk kl n δ` and our `occamBound R C n δ` share the
square-root structure. Prove `occam_is_pacbayes_point_mass`: a deterministic
hypothesis with prior weight `p` is the point-mass posterior whose KL divergence to
the prior equals `log(1/p) = C`, and under the matching of the confidence terms the
two bounds *coincide*. Then prove `compression_refines_pacbayes`: for any posterior,
`mcAllesterBound` dominates the compression bound of its MAP hypothesis.
**The key insight is** that compression bounds are the zero-temperature / point-mass
limit of PAC-Bayes, so MDL and PAC-Bayes are two coordinates on one variational
family rather than competing frameworks.
**Why now?** Both functionals live in the same library with proven monotonicity
lemmas (`mcAllester_mono_kl`, `occam_mono_complexity`), so the bridge is an algebraic
identity plus one inequality.

## 5. Make the bound *data-dependent* by replacing description length with empirical Rademacher complexity

The file `MachineLearning/RademacherComplexity.lean` defines an *exact* empirical
Rademacher complexity `empRad` for finite function classes. Conjecture
`rademacher_dominates_occam`: for a finite class, the data-dependent bound
`empRisk + 2·empRad + sqrt(log(1/δ)/(2n))` is never looser than the worst-case Occam
bound `occamBound empRisk (log |H|) n δ`, with strict improvement when the class is
correlated on the realized sample. Prove the comparison using `empRad_mono` and
`empRad_singleton`.
**The key insight is** that description length is a data-*independent* surrogate for
the genuinely data-*dependent* Rademacher capacity, so replacing the former by the
latter can only tighten the certificate while preserving the same `1/δ` confidence
budget.
**Why now?** `empRad` already has monotonicity and exact singleton/pair formulas in
the catalog, giving the two endpoints needed to sandwich the comparison.
