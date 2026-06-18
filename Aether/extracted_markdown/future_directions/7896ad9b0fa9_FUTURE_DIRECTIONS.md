# Future Directions — Spectral Universality of Gradient Descent on Arithmetic Moduli

## Synthesis

This cycle isolated the **rigorous, provable core** of the "spectral universality"
conjecture: the part of the claim that survives even in the simplest setting — a
quadratic loss with constant Hessian — and that any honest formalization of the full
conjecture must contain as a special case. The organizing principle that emerged is a
clean separation between *what is invariant* and *what is dynamical*. The characteristic
polynomial of the Hessian (our stand-in for the "universality-class label", playing the
role that local monodromy data plays on a moduli boundary) is a **strict reparametrization
invariant**: conjugating `H ↦ P⁻¹ H P` changes nothing about the spectrum
(`hessian_charpoly_reparam_invariant`), and along any Hessian field that is everywhere
conjugate to a fixed model the spectrum is literally constant in position
(`spectral_law_along_conjugate_field`). Meanwhile the *dynamics* are not merely
spectrally equivalent but **exactly intertwined**: a linear change of coordinates
conjugates the entire gradient-descent map, provided the minimizer is transported along
with the chart (`gd_reparam_conjugacy`). This is a stronger statement than spectral
universality — it says the two trajectories are the same dynamical system viewed in two
charts — and it is the structural reason a spectral law can be architecture-independent at
all.

The second discovery is that, once an eigenmode is fixed, the convergence story is
*exactly* geometric and *entirely* spectral: the `k`-step error along an eigenvector is
`(1 - ηλ)^k · e` on the nose (`gd_eigenmode_decay`), so the error norm collapses to the
universal law `|1 - ηλ|^k · ‖e‖` (`gd_eigenmode_norm_law`) and the stable region is the
explicit band `0 < ηλ < 2` (`gd_stable_iff`). The **critique** built into this cycle is
the boundary analysis: on `|1 - ηλ| ≥ 1` — too-large a step, or a flat/saddle direction
`λ ≤ 0` of the kind one actually meets near a degenerating moduli boundary — the error
*never* contracts (`gd_eigenmode_no_contraction`). This is exactly where naive GD, and
hence the simplest version of the universality story, breaks down, and it pinpoints what a
genuine theorem must control: the *smallest* and *most negative* eigenvalues, i.e. the
spectral edge.

What did **not** work, and is informative: a first attempt to state the limiting
universality law as `Tendsto (charpoly ∘ trajectory) (nhds H∞.charpoly)` failed because
`Polynomial ℝ` carries no topology in Mathlib. The fix — `spectral_universality_eventual`,
phrased with eventual exact conjugacy `∀ᶠ` — is honest but reveals the real gap: the open
content is not the *consequence* of asymptotic conjugacy (that is one line) but its
*emergence* from geometry. That observation directly seeds the directions below.

## Results Summary

- `hessian_charpoly_reparam_invariant`: proved — the Hessian spectrum is invariant under any invertible reparametrization; the universality-class label is well-defined.
- `spectral_law_along_conjugate_field`: proved — a Hessian field conjugate to a fixed model has a position-independent spectrum (the spectral law is constant along the trajectory).
- `gd_reparam_conjugacy`: proved — gradient descent in two linear parametrizations is exactly conjugate, given the transported minimizer; architecture-independence of the dynamics, not just the spectrum.
- `gdMap_eigen`: proved — one GD step scales the error along an eigenmode by `(1 - ηλ)`.
- `gd_eigenmode_decay`: proved — the exact `k`-step eigenmode error is `(1 - ηλ)^k · e`; per-mode rate is a pure function of the eigenvalue.
- `gd_eigenmode_norm_law`: proved — the error norm obeys the universal law `|1 - ηλ|^k · ‖e‖` (rescaled spectral collapse).
- `gd_stable_iff`: proved — the stability boundary is the explicit spectral band `0 < ηλ < 2`.
- `gd_eigenmode_converges`: proved — inside the stable band the eigenmode error tends to `0`.
- `gd_eigenmode_no_contraction`: proved (critique/boundary) — on `|1 - ηλ| ≥ 1` the error never contracts; the spectral-edge failure mode.
- `spectral_universality_eventual`: proved — eventual conjugacy to a limiting model `H∞` forces eventual equality of spectra; the exact-conjugacy regime of the conjecture.
- `nonlinearSpectralUniversalityConjecture`: (conjecture, recorded narratively below) — emergence of the limiting conjugacy from monodromy data; not formalized this cycle.

## Research Directions

### Direction 1: Spectral-radius rate law for the full (non-modal) GD trajectory
**Hypothesis**: For a symmetric positive-definite Hessian `H` with spectrum in `[m, L]` and
step `0 < η < 2/L`, the *full* error vector (arbitrary initial condition, not eigen-aligned)
satisfies `‖errorₖ‖ ≤ ρ^k ‖error₀‖` with `ρ = max(|1 - ηm|, |1 - ηL|)`, and `ρ` is attained,
so the asymptotic rate depends on `H` **only** through its spectral edge `{m, L}`.
**Test**: Decompose `error₀` in an orthonormal eigenbasis (Mathlib `Matrix.IsHermitian.spectral_theorem`),
apply `gd_eigenmode_decay` coordinatewise, and bound the Euclidean norm by the worst mode;
disproof would be any PD example whose rate beats `ρ` or depends on eigenvectors.
**Why now**: We already have the exact per-mode law `gd_eigenmode_decay`/`gd_eigenmode_norm_law`;
the only missing ingredient is summing modes, which the spectral theorem supplies.
The key insight is that *universality is an edge phenomenon* — only the extreme eigenvalues
survive in the rate, so the whole interior of the spectrum is irrelevant to convergence speed.
**If true**: It upgrades per-mode universality to a genuine architecture-independent rate
theorem and gives the optimal step `η⋆ = 2/(m+L)` a fully formal proof.
**If false**: It would mean eigenvector geometry leaks into the rate, refuting the simplest
universality claim and forcing a basis-dependent refinement.

### Direction 2: Stability of universality under non-conjugate perturbations
**Hypothesis**: If `H' = P⁻¹ H P + E` with `‖E‖ ≤ ε` (a perturbation that is *not* an exact
reparametrization — modeling architecture/quantization noise), then each eigenvalue of `H'`
lies within `ε` of an eigenvalue of `H`, so the per-mode rates `|1 - ηλ'|` deviate from the
universal values by `O(ηε)`; universality is therefore robust, not brittle.
**Test**: Formalize via Weyl's inequality / Bauer–Fike for Hermitian matrices in Mathlib
(`Matrix.IsHermitian` eigenvalue perturbation), then propagate through `gd_stable_iff`.
A counterexample at `ε → 0` with `O(1)` rate change would refute robustness.
**Why now**: `hessian_charpoly_reparam_invariant` gives the `ε = 0` exact case; the natural
next question is its `ε`-neighborhood, and Hermitian eigenvalue perturbation is in Mathlib.
The key insight is that the conjecture's empirical content is really a *continuity* statement:
spectra move continuously, so "approximately conjugate" Hessians have "approximately universal"
dynamics.
**If true**: It converts the exact algebraic invariance into the quantitative, testable
"spectral collapse up to `O(ε)`" that experiments would actually measure.
**If false**: There exist near-conjugate Hessians with wildly different dynamics, locating
the precise non-normality that breaks universality.

### Direction 3: The negative/flat spectral edge as the monodromy obstruction
**Hypothesis**: The set of step sizes for which *all* modes contract, `⋂_λ {η : 0 < ηλ < 2}`,
is nonempty iff every eigenvalue is positive (`H ≻ 0`); a single `λ ≤ 0` makes it empty,
and the offending mode is exactly the `gd_eigenmode_no_contraction` direction.
**Test**: A direct intersection argument over the spectrum building on `gd_stable_iff` and
`gd_eigenmode_no_contraction`; the boundary case `λ = 0` (flat direction) is the sharp edge.
**Why now**: The boundary theorem `gd_eigenmode_no_contraction` already identifies the failure
mode; this direction makes it a clean iff and ties it to definiteness.
The key insight is that the *signature* of the Hessian — not its fine spectrum — decides
whether universality (in the contractive sense) holds at all, mirroring how the **monodromy
type** at a moduli boundary (unipotent vs. quasi-unipotent, etc.) decides the qualitative
asymptotics. This is precisely the bridge to `Catalog/Pythagorean/HessianDescent.lean`'s
`HasLorentzianSignature`, where "at most one positive eigenvalue" is the dual edge condition.
**If true**: It gives a signature-indexed classification of GD-universality classes, the
discrete shadow of monodromy-indexed universality.
**If false**: Contraction could survive an indefinite Hessian, revealing a subtler
step-size mechanism than the per-mode band predicts.

### Direction 4: Emergence of the limiting conjugacy (the genuinely open core)
**Hypothesis**: For a smooth nonconvex loss whose Hessian degenerates as the trajectory
approaches a boundary stratum, there exists a moving frame `Q : ℕ → GLₙ` such that
`Qₖ⁻¹ (Hess f)(xₖ) Qₖ → H∞`, where `H∞` is determined *only* by the local monodromy type of
the stratum — at which point `spectral_universality_eventual` immediately yields a universal
limiting spectrum.
**Test**: Begin with the exactly solvable model `f(z) = |∫_γ ω(z)|²` built from a period
integral with known monodromy (e.g. the Legendre family of elliptic curves near a nodal
degeneration), compute `Hess f` asymptotically, and exhibit `Qₖ`. Failure of any frame to
converge, or `H∞` depending on the chosen `f` rather than the monodromy, refutes the core
conjecture.
**Why now**: This cycle proved that emergence of conjugacy *implies* the universal law
(`spectral_universality_eventual`), reducing the entire conjecture to a single tractable
analytic statement; we no longer need to reason about spectra at all, only about the
existence of `Qₖ`. The key insight is that **the hard part of universality is geometric
(the frame), not spectral (the consequence)** — the cycle cleanly factored the problem.
**If true**: It is the first rigorous instance of monodromy-determined optimization dynamics,
opening principled, geometry-driven architecture design.
**If false**: The limiting spectrum would depend on the loss beyond its monodromy class,
showing universality is finer-grained than the boundary type and needs additional invariants
(Hodge-theoretic, height-theoretic) to index it.

### Direction 5: A topology for `charpoly`-convergence to make the limit law first-class
**Hypothesis**: Equipping `Polynomial ℝ` (degree-`n` monic slice) with the coefficient
(equivalently, root-multiset) topology, the map `H ↦ H.charpoly` is continuous, so
entrywise `Hₖ → H∞` implies `charpoly Hₖ → charpoly H∞`; the eventual-equality form
`spectral_universality_eventual` then upgrades to a true limit statement.
**Test**: Identify monic degree-`n` real polynomials with `ℝ^n` (coefficient vector),
transport the product topology, and prove continuity of the (polynomial) coefficient maps of
`charpoly` using `Matrix.charpoly_coeff` formulas. A failure would be a discontinuity at a
matrix with repeated eigenvalues.
**Why now**: The `Polynomial ℝ`-has-no-topology obstruction *blocked* this cycle's limit
formulation and forced the `∀ᶠ` workaround; removing it is a concrete, self-contained
infrastructure task.
The key insight is that the empirical "spectral collapse" of the conjecture is a *convergence*
statement, and convergence needs a topology — the missing topology is itself the reason the
strongest form could not yet be stated, let alone proved.
**If true**: Every downstream universality result can be phrased as honest convergence of
spectra, matching the experimental protocol of "rescaled spectra collapse".
**If false (i.e. the natural topology is pathological)**: It would reveal that root-multiset
convergence, not coefficientwise, is the correct notion, sharpening what "spectral collapse"
should even mean.
