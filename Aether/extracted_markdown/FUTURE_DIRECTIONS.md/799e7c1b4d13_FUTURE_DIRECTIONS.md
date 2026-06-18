# Future Directions: Chaos, Lyapunov Exponents, and the Three-Body Problem

The file `Catalog/Physics/LyapunovChaos.lean` establishes the rigorous analytic
core of deterministic chaos for smooth iterated maps: the multiplicative cocycle
structure of the derivative of an iterate (`deriv_iterate_eq_prod`), its Birkhoff-sum
logarithm (`log_abs_deriv_iterate_eq_sum`), exponential orbit divergence
(`abs_deriv_iterate_ge`), strict positivity of the finite-time maximal Lyapunov
exponent (`ftle_ge_log`, `ftle_pos`), and the Pesin/variational bridge between
entropy and the Lyapunov exponent for the canonical uniformly expanding model
(`entropy_periodic_growth`, `pesin_identity_uniform_model`). The directions below
push from these single-map results toward the full multidimensional, Hamiltonian,
and three-body settings.

## 1. Asymptotic Lyapunov exponent as a genuine limit (not just finite-time)

Our `ftle` is the finite-time exponent; the true maximal Lyapunov exponent is its
`limsup`. Define `lyapunov f x := Filter.limsup (ftle f x ·) atTop` and prove that
under uniform expansion `Real.log c ≤ lyapunov f x`, and that for constant-stretch
maps the `limsup` is an honest `Tendsto` limit equal to `log c`. Then prove
subadditivity of the Birkhoff sums and derive a Kingman-type existence statement
for the limit along ergodic orbits.

**The key insight is** that `log_abs_deriv_iterate_eq_sum` already exhibits the
log-stretching as an *additive cocycle*, so the existence of the Lyapunov limit is
exactly Birkhoff's ergodic theorem applied to the observable `log|f'|` — no new
geometry is required, only the ergodic-averaging layer on top of the cocycle we
have proved. **Why now?** Mathlib's `MeasureTheory.ergodic` and Birkhoff average
API are mature enough that the additive-cocycle reduction we have isolated makes
the limit statement a packaging exercise rather than a research problem.

## 2. Multidimensional Lyapunov exponents via the operator norm of the Jacobian cocycle

Replace `deriv` with the Fréchet derivative `fderiv ℝ f` and prove the matrix-cocycle
chain rule `fderiv (f^[n]) x = (fderiv f (f^[n-1] x)) ∘ ... ∘ (fderiv f x)` together
with the subadditive bound `log‖D(f^[n])(x)‖ ≤ Σ log‖Df(f^[i] x)‖`. Conclude
positivity of the top exponent whenever the Jacobian is uniformly bounded below in
operator norm by `c > 1`. This is the genuine setting of the three-body phase space
(dimension 12, or 6 after reduction).

**The key insight is** that operator-norm submultiplicativity `‖AB‖ ≤ ‖A‖‖B‖` turns
the *exact* product identity of the 1-D case into a *subadditive inequality* in the
multidimensional case, which is precisely the hypothesis of Kingman's subadditive
ergodic theorem — so the 1-D scalar product `deriv_iterate_eq_prod` is the linear
shadow of the matrix story. **Why now?** Mathlib has `ContinuousLinearMap.opNorm`,
`fderiv_comp`, and the submultiplicativity lemma already; the scalar proof we wrote
transfers almost line-for-line with `prod` replaced by `List.prod` of operators.

## 3. Sensitive dependence on initial conditions via the mean value inequality

Upgrade the linearized estimate `abs_deriv_iterate_ge` to a genuine separation of
*distinct* nearby trajectories: prove that for a uniformly expanding `f` with
`|f'| ≥ c > 1`, there is `δ > 0` such that for all `x ≠ y` with `|x - y| < δ`, some
iterate satisfies `|f^[n] x - f^[n] y| ≥ δ`. This is the topological definition of
sensitive dependence (the Devaney chaos condition), promoted from the infinitesimal
to the finite scale.

**The key insight is** that the mean value theorem converts the pointwise derivative
bound we proved into a finite-difference bound `|f^[n] x - f^[n] y| ≥ c^n |x - y|`
*until the orbit leaves a fixed scale*, so sensitivity is a quantitative corollary
of `abs_deriv_iterate_ge` plus `exists_deriv_eq_of_...` (Lagrange MVT). **Why now?**
Mathlib's `Convex.norm_image_sub_le_of_norm_deriv_le` and the MVT family give the
two-sided control needed, and the expansion exponent `c^n` is already in hand.

## 4. The Ruelle inequality: entropy is bounded by the sum of positive Lyapunov exponents

`pesin_identity_uniform_model` proves *equality* for the uniformly expanding model.
The general Margulis–Ruelle inequality states `h_μ(f) ≤ Σ λ_i^+` for any invariant
measure, with Pesin equality only for SRB measures. Formalize the inequality for
piecewise-affine expanding maps of the interval by defining metric entropy through
the growth of `(n,ε)`-separated sets and bounding it by the integrated log-Jacobian
using the cocycle identity.

**The key insight is** that the number of distinguishable length-`n` itineraries is
controlled by the total stretching `∏|f'|` along orbits, which is exactly the
quantity `entropy_periodic_growth` computes for the constant-stretch case — so the
inequality is the statement that *variable* stretching can only do worse than the
uniform optimum we already pinned down. **Why now?** The constant case is solved,
giving a concrete target value `log d`; the remaining work is a covering/counting
argument over `Finset` partitions, which is combinatorial rather than analytic.

## 5. From maps to the three-body flow: a positive exponent for the planar restricted problem

Bridge from discrete maps to continuous Hamiltonian flow by formalizing the
time-`T` Poincaré return map `P` of the planar circular restricted three-body
problem near a homoclinic tangle, and proving that `P` contains a Smale horseshoe,
hence has a positive topological entropy and a positive Lyapunov exponent. This is
the rigorous route to "the three-body problem is chaotic" and directly reuses the
symbolic-dynamics catalog (`Catalog/Shared/SymbolicDynamics`,
`Catalog/Shared/HorseshoeComputation`).

**The key insight is** that a transverse homoclinic point produces a horseshoe
(Smale–Birkhoff), and on a horseshoe the return map is uniformly hyperbolic, so the
positivity machinery of `ftle_ge_log` applies *on the horseshoe's invariant set*
even though the global flow is far from uniformly expanding. **Why now?** The
symbolic horseshoe is already formalized in the catalog with its entropy `log 2`;
coupling it to `pesin_identity_uniform_model` would yield the first end-to-end Lean
statement linking three-body geometry, symbolic entropy, and analytic Lyapunov
positivity, using only pieces that now individually exist in this repository.
