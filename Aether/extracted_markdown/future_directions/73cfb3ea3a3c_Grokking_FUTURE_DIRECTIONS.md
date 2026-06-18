# Future Directions — Grokking: Phase Transitions in Learning

## Synthesis

`MachineLearning/Grokking.lean` formalizes the rigorous analytic core of *grokking*
(delayed generalization) and welds it to the theory of saddle-node bifurcations.
Three pillars were established and machine-checked (sorry-free, only the standard
`propext`/`Classical.choice`/`Quot.sound` axioms):

1. **A delay invariant for generalization.** Modelling the train and test error
   curves as the same exponential relaxation `exp(-α·)` separated by a fixed
   *delay* `T`, we proved (`grokking_window`, `grokking_window_width`,
   `train_fits_at_fitTime`, `test_groks_at_grokTime`) that there is a genuine
   window `[fitTime, grokTime)` of width **exactly `T`, independent of the target
   threshold `ε`**, during which the train error is already `≤ ε` while the test
   error is still `> ε`. This is the precise sense of "fit but not yet grokked."

2. **The full saddle-node bifurcation diagram.** For the normal form `ẋ = r - x²`
   we proved the complete equilibrium count — `{√r, -√r}` for `r>0`
   (`saddleNode_pos`), `{0}` for `r=0` (`saddleNode_zero`), `∅` for `r<0`
   (`saddleNode_neg`) — together with linear-stability signs
   (`saddleNode_deriv`, `saddleNode_stable`, `saddleNode_unstable`): the upper
   branch `√r` is a stable node (the "generalizing" fixed point), the lower branch
   `-√r` a saddle.

3. **The bridge — critical slowing down.** The capstone
   `grokking_delay_diverges` proves that the saddle-passage time `c/√r` **diverges
   to `+∞` as `r → 0⁺`**. This *derives* arbitrarily long grokking plateaus from
   the geometry of the bifurcation, connecting Pillar 1's delay `T` to Pillar 2's
   control parameter `r` via `T(r) ≍ c/√r`.

### Catalog connections

The delay/threshold analysis is in the spirit of `MachineLearning/AsymptoticRate.lean`
and the generalization-gap theme of `MachineLearning/PerturbedGeneralization.lean`
and `MachineLearning/Stability.lean`. The linear-stability computation
(`saddleNode_deriv`) is the continuous-time cousin of the orbit-derivative
linearization in `Physics/LyapunovChaos.lean` (`deriv_iterate_eq_prod`).

## Results Summary

| Theorem | Statement | Role |
|---|---|---|
| `grokking_window_width` | window width `= T` for all `ε` | delay invariant |
| `train_fits_at_fitTime` | train error `= ε` at `fitTime` | crossing time |
| `test_groks_at_grokTime` | test error `= ε` at `grokTime` | crossing time |
| `grokking_window` | train `≤ ε < ` test on the window | delayed generalization |
| `saddleNode_pos/zero/neg` | 2 / 1 / 0 equilibria | bifurcation diagram |
| `saddleNode_deriv` | `d/dx(r-x²) = -2x` | linearization |
| `saddleNode_stable/unstable` | sign of linearization at `±√r` | stability |
| `grokking_delay_diverges` | `c/√r → ∞` as `r → 0⁺` | the bridge |

## Bold, falsifiable research directions

### 1. The grokking delay is exactly the saddle-passage integral
Replace the *posited* scaling `T ≍ c/√r` by a *derived* one. For the 1-D reduced
flow `ẋ = r - x²` started just below the saddle, the time to traverse a fixed
neighbourhood `[-δ, δ]` is the explicit quadrature `∫_{-δ}^{δ} dx/(r - x²)`, which
evaluates (for `r>0`) to `(1/√r)·(artanh(δ/√r) - artanh(-δ/√r))` and to a
divergent integral at `r=0`. **Conjecture (falsifiable):** the formalized passage
time `passageTime r δ := ∫_{-δ}^{δ} (r - x²)⁻¹ dx` satisfies
`passageTime r δ = (2/√r)·artanh(δ/√r)` for `0 < δ < √r`, and
`Tendsto (passageTime · δ) (𝓝[>] 0) atTop`. *The key insight is* that the grokking
delay is not an independent modelling parameter at all but the **integral of the
inverse vector field across the bottleneck**, so Pillars 1 and 2 collapse into a
single object. *Why now?* We already have the bifurcation diagram and the
divergence skeleton; Mathlib's `MeasureTheory`/`intervalIntegral` and `Real.artanh`
make the quadrature directly attackable, turning the heuristic `c/√r` into a theorem.

### 2. A two-timescale (slow–fast) grokking theorem
Couple a fast "memorization" variable `m` to a slow "feature/weight-norm"
variable `w` whose drift passes through a saddle-node as a regularization knob
crosses threshold: `ṁ = -α m`, `ẇ = ρ - w²` with `ρ = ρ(t)` slowly increasing.
**Conjecture:** train error (controlled by `m`) decays on timescale `1/α`, while
test error (controlled by the slow approach of `w` to the stable branch `√ρ`)
stays `O(1)` until `t* = Θ(1/√ρ)` and then collapses, giving a provable separation
`t*/t_fit → ∞` as `ρ → 0⁺`. *The key insight is* that grokking is a **singular
perturbation**: fast fitting on the stable fast-fibre, slow generalization along
the centre/slow manifold. *Why now?* The present file isolates both timescales
separately; the missing step is one Tikhonov-style slow-manifold estimate, for
which the linear-stability signs proved here (`saddleNode_stable`) are exactly the
hypothesis needed.

### 3. Weight decay as the bifurcation parameter: a threshold theorem
Empirically, grokking appears only within a window of weight-decay strength `λ`.
Model the effective control parameter as `r(λ) = λ_c - (λ - λ₀)²` (an inverted
parabola peaking at `λ₀`), so that `r(λ) > 0` exactly on an interval `(λ⁻, λ⁺)`.
**Conjecture (falsifiable):** generalization (existence of a stable equilibrium of
the slow flow) holds **iff** `λ ∈ (λ⁻, λ⁺)`, and the delay `c/√r(λ)` diverges at
both endpoints — predicting two grokking "edges," not one. *The key insight is*
that the observed "sweet spot" for weight decay is the **pre-image of the
saddle-node existence region `r>0`** under a quadratic response, so non-grokking at
small *and* large `λ` share one mechanism. *Why now?* `saddleNode_pos/neg` already
characterize the `r>0` vs `r<0` dichotomy; composing with a quadratic `r(λ)` is
elementary and yields a sharp, testable iff.

### 4. Sharpness of the transition: a power-law for the test-error derivative
Beyond *when* generalization happens, quantify *how sharp* it is. **Conjecture:**
for the delayed model the maximal slope of the test-error curve scales like `α`
(threshold-independent), while in the bifurcation-driven model the slope at the
collapse scales like `√r` — so the transition sharpens as one moves away from the
bifurcation. Formally: `sSup_t |d/dt testError| ` and the analogous slow-flow
quantity admit closed-form bounds `≤ α` and `≍ √r`. *The key insight is* that
delay and sharpness are **independent observables** of the same transition, both
computable from the linearization eigenvalue. *Why now?* `saddleNode_deriv` already
delivers the eigenvalue `-2x`; differentiating the proven error curves is routine
calculus that Mathlib's `deriv` API handles.

### 5. Higher codimension: cusp catastrophe and "double descent" unification
Promote the normal form from saddle-node (`ẋ = r - x²`, codimension 1) to the cusp
(`ẋ = a + b x - x³`, codimension 2). **Conjecture:** the cusp's two-parameter
bifurcation set (`4b³ = 27a²`) organizes grokking *and* epoch-wise double descent
as **two slices of one catastrophe surface**: crossing a fold gives a single
delayed jump (grokking), while a path that loops the cusp point gives a
non-monotone test curve (double descent). A first formal target is the cusp
discriminant: the number of real roots of `a + b x - x³` is `3` iff
`4b³ > 27a²` and `1` otherwise. *The key insight is* that the disparate empirical
zoo of training-curve anomalies may be **a low-codimension catastrophe in
disguise**, with grokking the simplest (fold) member. *Why now?* The cubic
discriminant is a self-contained algebra problem of the same flavour as the proven
quadratic `saddleNode_pos`, giving an immediate, falsifiable next milestone toward
a catastrophe-theoretic taxonomy of learning dynamics.
