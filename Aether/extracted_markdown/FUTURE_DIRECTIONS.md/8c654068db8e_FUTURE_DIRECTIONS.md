# Future Directions: Spectral Universality of Transformer Attention

## Synthesis

This cycle attacked the conjecture of *spectral universality of transformer attention* —
the claim that the empirical eigenvalue distribution (ESD) of the symmetric attention Gram
matrix `G = A Aᵀ`, built from pre-softmax scores `A = Q Kᵀ / √d`, converges to a universal
law determined only by the aspect ratio and entry variance, invariant under any change of
entry distribution that preserves the first two moments. Rather than chasing the full
asymptotic theorem (which needs the entire free-probability / moment-method apparatus that
Mathlib does not yet contain), we isolated the *exact, finite-size algebraic skeleton* on
which the asymptotic statement rests, and proved the first genuinely distribution-free
instance of universality.

Two files were produced and fully verified (no `sorry`, only standard axioms):

- `Catalog/Geometry/AttentionSpectralGram.lean` — the deterministic backbone: the Gram
  matrix is Hermitian and positive semidefinite; the **moment-method identity**
  `trace(Mᵖ) = ∑ᵢ λᵢᵖ` for every Hermitian `M` (so each ESD moment is a normalized trace
  power); the first-moment identity `∑ᵢ λᵢ = ∑_{i,j} (A i j)²`; and the explicit effect of
  the `1/√d` scaling, which divides the mean spectrum by `d`.
- `Catalog/Geometry/AttentionSpectralUniversality.lean` — the probabilistic upgrade:
  `E[trace(M Mᵀ)] = (card m · card n)·σ²`, depending on the entry distribution *only*
  through the variance `σ²`; the normalized "mean eigenvalue = (latent width)·σ²"; and the
  **moment-class-invariance** corollary — two models with the same per-entry second moment
  have identical expected Gram trace, whatever their distributions.

These cross-domain results connect three catalog threads: the spectral/PSD machinery of
`MachineLearning.NTKSpectral` (`ntkGram_posSemidef`, `ntk_quadratic_form`), the algebraic
view of attention in `MachineLearning.Attention`, and the geometric study of spectra. The
common idea is that *the spectrum is a geometric invariant accessed through trace
polynomials*, and that linearity of expectation already erases everything but the variance
at first order.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `attentionGram_posSemidef` | `A Aᵀ ⪰ 0` (real nonnegative spectrum) | proved |
| `spectral_moment_eq_trace` | `trace(Mᵖ) = ∑ᵢ λᵢᵖ` for Hermitian `M` | proved |
| `attentionGram_first_spectral_moment` | `∑ᵢ λᵢ = ∑_{i,j} (A i j)²` | proved |
| `attentionScores_gram_trace` | `1/√d` scaling divides mean spectrum by `d` | proved |
| `expected_gram_trace_eq` | `E[trace(M Mᵀ)] = (card m · card n)·σ²` | proved |
| `gram_trace_universal` | same variance ⇒ same expected trace | proved |

## Research Directions

### 1. Second-moment universality and the Marchenko–Pastur edge

The natural next target is the *second* ESD moment, `E[(1/m)·trace((M Mᵀ)²)]`. Expanding via
`spectral_moment_eq_trace` at `p = 2` gives a sum over index quadruples `(i,j,k,ℓ)`. The
leading contribution, where indices pair up, is again variance-only and reproduces the
second Marchenko–Pastur moment; the off-diagonal "fourth-moment" terms are subleading and
must vanish in the joint width/length limit. **The key insight is** that the exact
finite-size second moment is a *two-term* polynomial `α·σ⁴ + β·κ₄` in the variance `σ²` and
the fourth cumulant `κ₄`, and universality is precisely the statement that `β → 0` under the
`1/d` scaling — a quantitative, falsifiable claim about the ratio `β/α`. **Why now?** We
already have the exact `p = 1` identity and the trace-power machinery; pushing to `p = 2`
only requires combinatorial bookkeeping of index collisions, no new analytic theory, so it
is the cheapest possible extension that exhibits the *mechanism* of universality (not just
its base case).

### 2. The Marchenko–Pastur self-consistency equation as a pure algebraic identity

Formalize the Stieltjes/Cauchy transform `m(z)` of the conjectured limit and prove it
satisfies the defining quadratic `λ z m² − (1 − λ − z) m + 1 = 0`, the fixed-point equation
of free multiplicative convolution. **The key insight is** that the entire limiting law is
encoded, distribution-freely, in a *single quadratic with coefficients built only from the
aspect ratio `λ` and `z`* — so universality becomes the algebraic statement "the
self-consistency polynomial has coefficients independent of all entry moments beyond the
second." **Why now?** This sidesteps measure theory entirely: it is a calculus/algebra
identity (verify a closed-form root, or characterize `m` as the unique root with the correct
sign of imaginary part), squarely inside current Mathlib capabilities, and it gives the next
cycle a concrete analytic object to connect to the moment recursion of Direction 1.

### 3. Free cumulants of attention as the obstruction to universality

Define the free cumulants `κₙ` of the attention spectral law via the moment–cumulant
(non-crossing-partition) relation and conjecture that for the universal limit *all* free
cumulants are determined by `(λ, σ²)`, with `κₙ = λ σ^{2n}` (the free-Poisson signature).
**The key insight is** that universality is equivalent to the vanishing of every "anomalous"
free cumulant sourced by higher classical moments — recasting an analytic limit theorem as a
discrete statement about non-crossing partitions, which is exactly the kind of combinatorics
Lean handles well. **Why now?** Mathlib has strong `Finset`/partition infrastructure but no
free-probability layer; building even the moment–cumulant inversion for this one law would
seed an entire new formal theory, with immediate payoff as the structural explanation of why
Directions 1 and 2 must agree.

### 4. Quantitative non-universality: heavy tails break the law

State the *falsifier* sharply: if the entry distribution has *infinite* fourth moment
(truncated-variance heavy tails), the second ESD moment diverges and the limit leaves the
Marchenko–Pastur class. Formalize, as a contrapositive to Direction 1, that
`E[trace((M Mᵀ)²)]` is finite **iff** the entry fourth moment is finite, and exhibit an
explicit heavy-tailed family where it blows up. **The key insight is** that the universality
class has a crisp *boundary* — finiteness of the fourth moment — and that boundary is itself
an exact, checkable inequality on `E[(M i j)⁴]`, not an asymptotic. **Why now?** Our
expected-trace identities already reduce these questions to finiteness of per-entry moment
integrals; the heavy-tailed counterexample is a direct integrability computation, giving the
next cycle a rigorous *refutation* witness to complement the confirmations.

### 5. Softmax-warped spectra: universality survives a Lipschitz nonlinearity

Replace the linear scores `A` by the actual softmax-normalized attention
`P = softmax(A)` (rows summing to one) and conjecture that the *bulk* of the ESD of
`P Pᵀ` still lies in a universality class, controlled to leading order by the same `(λ, σ²)`
data plus an explicit deterministic shift from the row-stochastic constraint. **The key
insight is** that softmax is a smooth, row-normalizing perturbation whose Jacobian is
controlled, so the trace-power moments of `P Pᵀ` differ from those of `A Aᵀ` by terms one
can bound via a Lipschitz/Frobenius estimate — making "universality is robust to the
nonlinearity" a concrete perturbation inequality. **Why now?** This is the step that carries
the theory from a toy linear model to *deployed* attention; with the linear first-moment
identity in hand, the softmax correction is the single remaining gap between the mathematics
and the architecture practitioners actually run, and it is reachable via standard analytic
bounds rather than new random-matrix theory.
