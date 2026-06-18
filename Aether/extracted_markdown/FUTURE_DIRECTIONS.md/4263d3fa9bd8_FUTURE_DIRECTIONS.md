# Future Directions — Neural Network Training as Renormalization Group Flow

## Synthesis

This cycle made the slogan *"one SGD step ≈ one RG coarse-graining step"* into
literal, machine-checked mathematics, split across two self-contained Lean files.

`Flow.lean` treats the **flow** half of the analogy. We model gradient training
abstractly through a gradient field `g` and the step map `sgdStep g η x = x − η • g x`.
We prove that its equilibria are *exactly* the critical points of the loss
(`sgd_fixed_iff_critical`) — the formal content of "SGD fixed points are RG fixed
points". For a linear network (quadratic loss `g x = A x − b`) we identify the
linearized RG **beta function** with the operator `M = I − ηA`, prove the exact error
recursion `T x − x* = M (x − x*)` (`quadratic_error_recursion`), the geometric decay
`‖Tⁿx − x*‖ ≤ ‖M‖ⁿ‖x − x*‖` (`quadratic_geometric_decay`), and convergence to the
**Gaussian fixed point** under the criticality criterion `‖M‖ < 1`
(`quadratic_tendsto_fixedPoint`).

`CoarseGraining.lean` treats the **coarse-graining** half. The RG block-spin operator
is an idempotent projection `P` (`P ∘ P = P`). We prove its fixed-point manifold is the
subspace `range P` (`coarseGraining_fixed_eq_range`), that the RG flow stabilizes after a
single step `P^[n+1] = P` (`coarseGraining_iterate_eq`), that SGD commutes with `P` under
RG covariance `P ∘ g = g ∘ P` (`sgd_rg_covariant`), and — the payoff — that two
configurations in the same **universality class** (`P x = P y`) stay coarse-grained-equal
along the *entire* training trajectory (`universality_class_preserved`). This is exactly
"same universality class ⇒ same fixed point", with universality realized as the descent
of the dynamics to the quotient `E / ker P`.

## Results Summary

| Theorem | File | Statement |
|---|---|---|
| `sgd_fixed_iff_critical` | Flow | SGD fixed point ⇔ critical point of the loss |
| `quadratic_error_recursion` | Flow | `T x − x* = (I − ηA)(x − x*)` (the beta function) |
| `quadratic_geometric_decay` | Flow | `‖Tⁿx − x*‖ ≤ ‖I − ηA‖ⁿ ‖x − x*‖` |
| `quadratic_tendsto_fixedPoint` | Flow | `‖I − ηA‖ < 1 ⇒ Tⁿx → x*` (Gaussian fixed point) |
| `coarseGraining_fixed_eq_range` | CoarseGraining | fixed-point manifold of `P` = `range P` |
| `coarseGraining_iterate_eq` | CoarseGraining | `P^[n+1] = P` (RG flow is a projection) |
| `sgd_rg_covariant` | CoarseGraining | `P (T x) = T (P x)` under RG covariance |
| `universality_class_preserved` | CoarseGraining | `P x = P y ⇒ P(Tⁿx) = P(Tⁿy)` for all `n` |

All eight theorems are proved with `sorry = 0` and depend only on the standard axioms
`propext`, `Classical.choice`, `Quot.sound`.

---

## Direction 1 — Derive RG covariance for isotropic data instead of assuming it

`universality_class_preserved` currently *assumes* `P ∘ g = g ∘ P`. The next milestone is
to *derive* it: for a 2-layer network on rotationally-invariant (isotropic) data, take `P`
to be averaging over the orthogonal group `O(d)` acting on the input layer, and show the
population-gradient field `g = ∇L` is equivariant, hence commutes with the averaging
projector.

**The key insight is** that isotropy of the data distribution is precisely a symmetry of
the loss functional, and Noether-style equivariance of the gradient under that symmetry is
exactly the RG-covariance hypothesis our universality theorem needs — so universality is
not an extra assumption but a *consequence* of data symmetry.

**Why now?** Mathlib has Haar measure, compact-group averaging, and the orthogonal group;
the equivariance reduces to differentiating an `O(d)`-invariant integral, which is in
reach. The catalog's symmetry-transfer work (`MachineLearning.SymmetryTransfer`) provides a
template for pushing group actions through learning maps.

## Direction 2 — A genuinely non-Gaussian (Wilson–Fisher-type) fixed point

`Flow.lean` only reaches the *Gaussian* fixed point (linear `g`, contraction `‖M‖ < 1`).
The bold conjecture is a *nontrivial* fixed point for a quadratic-plus-cubic beta function
`β(u) = −ε u + c u²` (the canonical Wilson–Fisher form), whose nonzero root `u* = ε/c`
is attracting for small `ε > 0`.

**The key insight is** that the ReLU nonlinearity contributes a quadratic term to the
effective beta function of the variance order-parameter, so the d = 2 "ε-expansion"
becomes an honest 1-D ODE whose interior fixed point and its stability exponent
`β'(u*) = ε` can be proved rigorously without any field theory.

**Why now?** This is a self-contained real-analysis problem (existence/stability of a
fixed point of an explicit polynomial map) that Mathlib's `Polynomial` and dynamical-systems
API can handle, and it would upgrade our "Gaussian-only" result to a falsifiable claim
about critical exponents.

## Direction 3 — Quotient dynamics: SGD descends to `E / ker P`

We proved RG covariance pointwise; the structural statement is that an RG-covariant SGD map
induces a well-defined map on the quotient module `E / ker P`, and the original trajectory's
coarse-graining equals the quotient trajectory.

**The key insight is** that universality is a *functoriality* statement — coarse-graining is
a quotient functor and RG-covariant training is a natural transformation — so the "same
fixed point per universality class" phenomenon is the uniqueness of limits in the quotient
category, not a coincidence of dynamics.

**Why now?** Mathlib's `Submodule.Quotient` and `LinearMap.lifting` give the exact tools to
state and prove "the induced map is well defined and commutes with the projection", turning
our covariance lemma into a clean categorical bridge to the catalog's algebra line
(`Algebra.IdempotentHilbertBasis`).

## Direction 4 — Rate-of-convergence ↔ critical exponent dictionary

`quadratic_geometric_decay` gives rate `‖M‖ = ‖I − ηA‖`, governed by the spectrum of `A`.
Conjecture: the slowest mode (largest `|1 − ηλ|`) controls the asymptotic decay, and its
exponent `−log‖M‖` is the RG correlation-length exponent `1/ν`.

**The key insight is** that the spectral gap of the Hessian/data covariance is literally the
leading RG eigenvalue, so the optimization "condition number" and the physics "critical
exponent `ν`" are the same quantity viewed through two languages.

**Why now?** Mathlib's spectral theory for self-adjoint compact operators (eigenvalues,
`IsSelfAdjoint`) lets us replace the crude operator-norm bound by a sharp per-eigenmode rate
and prove the optimal `η = 2/(λ_min + λ_max)` minimizes `‖M‖`, making the exponent explicit.

## Direction 5 — Stochastic coarse-graining and a fixed-point measure

Replace the deterministic projection `P` by a Markov coarse-graining kernel (averaging over
*random* parameter subsets), and conjecture that the training-induced flow on probability
measures has a unique stationary measure concentrated on the critical manifold.

**The key insight is** that mini-batch SGD noise is itself a coarse-graining over data
subsets, so the *same* projection formalism, lifted to the space of measures, unifies
"averaging over parameters" and "averaging over data" into one RG semigroup with a single
fixed-point measure.

**Why now?** Mathlib's `MeasureTheory` and Markov-kernel API (`ProbabilityTheory.Kernel`)
make it feasible to state the push-forward dynamics and invoke a Krylov–Bogolyubov-style
existence argument for the stationary measure, connecting this line to the catalog's
`MachineLearning.BernoulliMeasure` work.
