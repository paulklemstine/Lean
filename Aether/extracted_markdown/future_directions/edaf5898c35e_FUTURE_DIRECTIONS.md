# Future Directions — Spectral Universality of Gradient Descent

## Synthesis

This cycle formalized the **rigorous, provable core** of the "spectral universality of
gradient descent" picture and cleanly separated it into two halves: *what is invariant* and
*what is dynamical*.

On the invariant side, the characteristic polynomial of the Hessian — our stand-in for the
"universality-class label", the role that local monodromy data plays on a moduli boundary —
is a strict reparametrization invariant (`hessian_charpoly_reparam_invariant`), and along any
Hessian field everywhere conjugate to a fixed model the spectral label is literally constant
in position (`spectral_law_along_conjugate_field`). The label therefore lives on the
similarity class, not on the matrix: "architecture independence" of the label is exactly
GL-conjugation invariance.

On the dynamical side, once an eigenmode is fixed the convergence story is *exactly* geometric
and *entirely* spectral. Writing one gradient-descent step in the error coordinate as
`gdError H η e = e - η • H e`, the eigenline `ℝ • e` is invariant (`gdError_smul_eigen`), the
`k`-step error is `(1 - η·λ)^k • e` on the nose (`gd_eigenmode_decay`), and the error norm
collapses to the universal law `|1 - η·λ|^k · ‖e‖` (`gd_eigenmode_norm_law`). The stable region
is the explicit band `0 < η·λ < 2` (`gd_stable_iff`); inside it the error tends to `0`
(`gd_eigenmode_converges`); and on `|1 - η·λ| ≥ 1` it *never* contracts
(`gd_eigenmode_no_contraction`) — the spectral-edge / flat-direction failure mode. We also
proved a basis-free contraction-rate law `iterate_norm_le`: any error map with one-step
operator bound `ρ` contracts as `ρ^k`, which combined with the eigenmode law shows the rate is
*attained* on the extreme mode. Finally, the signature theorem
`gd_common_stable_iff_posdef` shows a single step size contracts every mode **iff** every
eigenvalue is positive — a single flat or saddle direction empties the stable set.

What did **not** work, and is informative: a first attempt to state the limiting universality
law as `Tendsto (charpoly ∘ trajectory) (𝓝 H∞.charpoly)` is unstateable because
`Polynomial ℝ` carries no topology in Mathlib. We therefore phrased the laws through objects
that *do* live in ℝ (norms) or as exact equalities along a conjugate field. That obstruction,
and the missing `‖I - ηH‖ = max_λ |1 - η·λ|` identity, are precisely what the directions below
target.

## Results Summary

- `hessian_charpoly_reparam_invariant` — proved; the spectral label is conjugation-invariant.
- `spectral_law_along_conjugate_field` — proved; the label is constant along a conjugate field.
- `gdMap_eigen` / `gdError_smul_eigen` — proved; one step is scalar `(1 - η·λ)` on each eigenline.
- `gd_eigenmode_decay` — proved; exact `k`-step error `(1 - η·λ)^k • e`.
- `gd_eigenmode_norm_law` — proved; norm law `|1 - η·λ|^k · ‖e‖`.
- `gd_stable_iff` — proved; stability band `0 < η·λ < 2`.
- `gd_eigenmode_converges` — proved; convergence inside the band.
- `gd_eigenmode_no_contraction` — proved; no contraction on `|1 - η·λ| ≥ 1`.
- `iterate_norm_le` — proved; basis-free contraction-rate law `ρ^k`.
- `gd_common_stable_iff_posdef` — proved; common stable step ⇔ positive definiteness.

## Research Directions

### Direction 1: Spectral-radius rate law for the full (non-modal) trajectory
For a symmetric positive-definite Hessian `H` with spectrum in `[m, L]` and step `0 < η < 2/L`,
the *full* error vector (arbitrary initial condition, not eigen-aligned) should satisfy
`‖errorₖ‖ ≤ ρ^k ‖error₀‖` with `ρ = max(|1 - η·m|, |1 - η·L|)`, and `ρ` should be attained, so
the asymptotic rate depends on `H` only through its spectral edge `{m, L}`. The test:
decompose `error₀` in an orthonormal eigenbasis via Mathlib's
`Matrix.IsHermitian.spectral_theorem`, apply `gd_eigenmode_decay` coordinatewise, and bound the
Euclidean norm by the worst mode; the matching lower bound comes from initializing on the
extreme eigenvector. **Why now?** We already have the exact per-mode law (`gd_eigenmode_decay`,
`gd_eigenmode_norm_law`) and the abstract rate skeleton (`iterate_norm_le`); the only missing
ingredient is summing modes, which the spectral theorem supplies, and the operator-norm bound
`‖I - ηH‖ = ρ`. The key insight is that *universality is an edge phenomenon* — only the extreme
eigenvalues survive in the rate, so the entire interior of the spectrum is irrelevant to
convergence speed. If true, it upgrades per-mode universality to a genuine
architecture-independent rate theorem and gives the optimal step `η⋆ = 2/(m+L)` a fully formal
proof; if false, eigenvector geometry leaks into the rate, refuting the simplest universality
claim.

### Direction 2: Stability of universality under non-conjugate perturbations
If `H' = P⁻¹ H P + E` with `‖E‖ ≤ ε` (a perturbation that is *not* an exact reparametrization —
modeling architecture or quantization noise), then each eigenvalue of `H'` should lie within
`ε` of an eigenvalue of `H`, so the per-mode rates `|1 - η·λ'|` deviate from the universal
values by `O(η·ε)`; universality is robust, not brittle. The test: formalize Weyl's inequality
/ Bauer–Fike for Hermitian matrices (`Matrix.IsHermitian` eigenvalue perturbation in Mathlib)
and propagate through `gd_stable_iff`. **Why now?** `hessian_charpoly_reparam_invariant` gives
the exact `ε = 0` case; the natural next question is its `ε`-neighborhood, and Hermitian
eigenvalue perturbation already exists in Mathlib. The key insight is that the conjecture's
empirical content is really a *continuity* statement: spectra move continuously, so
"approximately conjugate" Hessians have "approximately universal" dynamics. If true, it
converts exact algebraic invariance into the quantitative, testable "spectral collapse up to
`O(ε)`" that experiments actually measure; if false, there exist near-conjugate Hessians with
wildly different dynamics, locating the precise non-normality that breaks universality.

### Direction 3: The negative/flat spectral edge as the monodromy obstruction (sharpening)
We proved `gd_common_stable_iff_posdef`: a common stable step exists iff the spectrum is
positive. The next step is to make this a *signature-indexed classification*: tie the boundary
case `λ = 0` (a flat direction) to the exact failure mode `gd_eigenmode_no_contraction`, and
connect the count of nonpositive eigenvalues to a discrete "universality class". The test: a
direct argument over the spectrum building on `gd_stable_iff` and `gd_eigenmode_no_contraction`,
then a bridge to `Catalog/Pythagorean/HessianDescent.lean`'s `HasLorentzianSignature`, where
"at most one positive eigenvalue" is the dual edge condition. **Why now?** The iff and the
boundary theorem are both in hand; only the classification statement is missing. The key
insight is that the *signature* of the Hessian — not its fine spectrum — decides whether
contractive universality holds at all, mirroring how the monodromy type at a moduli boundary
(unipotent vs. quasi-unipotent) decides the qualitative asymptotics. If true, it gives the
discrete shadow of monodromy-indexed universality; if false, contraction could survive an
indefinite Hessian, revealing a subtler step-size mechanism.

### Direction 4: Emergence of the limiting conjugacy (the genuinely open core)
For a smooth nonconvex loss whose Hessian degenerates as the trajectory approaches a boundary
stratum, conjecture that there exists a moving frame `Q : ℕ → GLₙ` with
`Qₖ⁻¹ (Hess f)(xₖ) Qₖ → H∞`, where `H∞` is determined *only* by the local monodromy type of the
stratum — at which point `spectral_law_along_conjugate_field` plus an eventual-conjugacy
argument immediately yields a universal limiting spectrum. The test: start with the exactly
solvable model `f(z) = |∫_γ ω(z)|²` from a period integral with known monodromy (e.g. the
Legendre family near a nodal degeneration), compute `Hess f` asymptotically, and exhibit `Qₖ`.
**Why now?** This cycle proved that conjugacy *implies* the universal law, reducing the entire
conjecture to a single tractable analytic statement: we no longer need to reason about spectra
at all, only about the existence of `Qₖ`. The key insight is that **the hard part of
universality is geometric (the frame), not spectral (the consequence)** — the cycle cleanly
factored the problem. If true, it is the first rigorous instance of monodromy-determined
optimization dynamics; if false, the limiting spectrum depends on the loss beyond its monodromy
class, showing universality needs additional (Hodge- or height-theoretic) invariants.

### Direction 5: A topology for `charpoly`-convergence to make the limit law first-class
Equip the monic degree-`n` slice of `Polynomial ℝ` with the coefficient (equivalently,
root-multiset) topology, identifying it with `ℝⁿ`; then the map `H ↦ H.charpoly` should be
continuous, so entrywise `Hₖ → H∞` implies `charpoly Hₖ → charpoly H∞`, upgrading the
eventual-equality laws of this cycle to true limit statements. The test: transport the product
topology of `ℝⁿ` along the coefficient identification and prove continuity of each coefficient
map of `charpoly` using `Matrix.charpoly_coeff`; the delicate point is matrices with repeated
eigenvalues. **Why now?** The `Polynomial ℝ`-has-no-topology obstruction is precisely what
*blocked* this cycle's limit formulation and forced the norm-based and exact-equality
workarounds; removing it is a concrete, self-contained infrastructure task. The key insight is
that the empirical "spectral collapse" of the conjecture is a *convergence* statement, and
convergence needs a topology — the missing topology is itself the reason the strongest form
could not yet be stated. If true, every downstream universality result becomes honest
convergence of spectra; if false (the coefficient topology is pathological), it would reveal
that root-multiset convergence is the correct notion, sharpening what "spectral collapse" even
means.
