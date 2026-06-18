# Future Directions: Quantum Surreal Numbers

The module `Geometry/QuantumSurreal.lean` establishes a rigorous, machine-checked
core of the "quantum surreal" program. Quantum states carry amplitudes in a
non-Archimedean ordered field (`ℝ*`, the hyperreals, a Mathlib-available stand-in
for the surreal field's infinitesimal structure), and *measurement* is modeled by
the **standard part** of the Born weight. The headline result is the rigorous proof
that an outcome carrying a nonzero but infinitesimal amplitude is *unobservable*:
the ε-qubit `(1/√2)|0⟩ + (ε/√2)|ε⟩` measures to `0` with probability `1/2` and to the
infinitesimal branch with probability `0` (`epsilonQubit_prob_zero`,
`epsilonQubit_prob_eps`, `epsilonQubit_phantom`). Supporting this are Born positivity
(`observedProb_nonneg`), additivity of the standard-part Born rule
(`st_normSq_eq_sum_observedProb`), the "dark state" generalization (`darkState`), and
the information-loss boundary phenomenon (`observedProb_not_injective`). The following
directions extend this frontier.

## Direction 1: The standard-part decoherence functor

The map `st : ℝ* → ℝ` is a ring-bounded "forgetful" map from the non-Archimedean
world to the tame reals; `observedProb_not_injective` shows it collapses
infinitesimally-separated states. Conjecture: assigning to each `QState n` the real
vector `i ↦ observedProb ψ i` defines a *functor* from the category of quantum
surreal states (with norm-non-increasing, finite hyperreal-linear maps as morphisms)
to the category of finite real subprobability vectors, and this functor is the
universal Archimedean quotient — every probability-preserving map to a real model
factors through it. **The key insight is** that quantum decoherence is not an
analytic limit but an *algebraic quotient*: throwing away the infinitesimal monad of
`ℝ*` is precisely the categorical collapse to classical observable statistics.
**Why now?** We already have `observedProb` proven additive and positivity-preserving
in Lean, so the object map and the two functor laws are within reach of the existing
API; only the morphism layer needs to be added.

## Direction 2: Normalization and the conditional Born rule

For the ε-qubit, the total observed weight is `st(normSq) = 1/2`, so the *conditional*
probability of the classical outcome given a successful observation is `1`. Conjecture:
for every state whose Born weights are finite and whose `st(normSq) ≠ 0`, the
normalized observed distribution `observedProb ψ i / st(normSq ψ)` is a genuine
probability vector summing to `1`, and it is invariant under multiplying the whole
state by any *appreciable* (non-infinitesimal, non-infinite) hyperreal scalar. **The
key insight is** that gauge freedom in quantum mechanics (overall amplitude scaling)
becomes, in the surreal setting, exactly the group of appreciable units of `ℝ*`, whose
standard part is a nonzero real. **Why now?** `st_normSq_eq_sum_observedProb` already
reduces the total to a finite real sum; combining it with `Hyperreal.st_mul` for
appreciable scalars makes the invariance statement a short formalization away.

## Direction 3: Surreal-valued spectral decomposition for 2×2 self-adjoint operators

The original conjecture asks for a spectral theorem on quantum surreal Hilbert space.
A tractable, fully formalizable first case: every symmetric `2×2` matrix over `ℝ*`
has two hyperreal eigenvalues `λ₁ ≤ λ₂` and an orthonormal eigenbasis, and the
*observed spectrum* `(st λ₁, st λ₂)` is the spectrum of the standard-part matrix.
Conjecture: when the eigenvalue gap `λ₂ − λ₁` is infinitesimal but nonzero, the two
levels are *spectrally degenerate to observation* even though they are algebraically
distinct — a rigorous model of a quasi-degenerate quantum level. **The key insight is**
that the surreal birthday/order structure resolves degeneracies that the real spectrum
cannot see, so "accidental degeneracy" becomes a measurable infinitesimal gap.
**Why now?** The discriminant of a `2×2` symmetric matrix is an explicit polynomial, so
`Real.sqrt`/hyperreal square roots give the eigenvalues constructively; the
unobservability machinery (`observedProb_eq_zero_of_infinitesimal`) transfers directly
to the gap.

## Direction 4: A hyperreal entropy that detects phantom branches

Define a regularized entropy `S(ψ) = −∑ᵢ pᵢ log pᵢ` on the *observed* distribution and
compare it to a hyperreal entropy computed before taking standard parts. Conjecture:
the real entropy `S` is continuous in the appreciable part of the amplitudes but is
*blind* to phantom branches, whereas the hyperreal entropy strictly decreases when a
phantom branch is deleted — giving an entropy gap whose standard part is `0` but whose
sign is well-defined. **The key insight is** that infinitesimal probabilities carry
*orderable* but *unmeasurable* information, so the surreal order recovers a strict
information ordering that the Shannon entropy of the real distribution erases.
**Why now?** `observedProb_not_injective` already exhibits two states with identical
observed data; quantifying their difference by an infinitesimal entropy gap is the
natural next invariant, and Mathlib's `Real.log` plus the existing standard-part
lemmas supply the analytic tools.

## Direction 5: Non-Archimedean Born rule on countably-infinite outcome spaces

`st_sum_not_infinite` is proven for finite outcome sets. Conjecture: for a state on
`ℕ` outcomes whose Born weights are summable in `ℝ*` to an appreciable total, the
observed probabilities `observedProb ψ n` are summable in `ℝ` and their sum equals the
standard part of the hyperreal total — but there exist states whose hyperreal series
converges while the standard-part series *loses* an infinitesimal "tail mass" that is
nonetheless detectable by overspill. **The key insight is** that the order-theoretic
overspill principle of `ℝ*` provides a non-Archimedean replacement for dominated
convergence, letting infinitesimal tails be summed coherently even when their standard
parts all vanish individually. **Why now?** The finite additivity result is already in
place; extending it to `tsum` requires only the interplay of `Hyperreal.IsSt` with
`Filter.Tendsto`, an interface that Mathlib's hyperreal development partially exposes.
