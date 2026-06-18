# FUTURE_DIRECTIONS — Neural Scaling Spectra as RG Fixed-Point Invariants

## Synthesis

This cycle isolated a rigorous mathematical core for the conjecture that neural
scaling spectra are governed by *renormalization-group (RG) fixed-point invariants*.
The empirical conjecture — that Hessian eigenvalue exponents collapse onto a
model-class-independent universal curve — is, in its informal form, a statement
about measured spectra of real architectures and is not directly provable. The
structural move that made it tractable was to separate the two data carried by a
power-law spectrum `λ(x) = C·x^(-α)`: the **amplitude** `C`, which we identify with
the architecture-specific coupling, and the **exponent** `α`, which we identify with
the universal critical datum. Once this split is made, "universality" becomes the
precise claim that the exponent is the RG invariant and the amplitude is a running
coupling that normalization removes.

Six theorems make this precise and all compile with only the standard axioms.
Power laws are exactly scale-covariant (`powerLaw_selfSimilar`) and are exact fixed
points of an exponent-compensated RG operator (`rgFixedOp_fixes_powerLaw`); pure
coarse-graining preserves the exponent while flowing only the amplitude
(`coarseGrain_powerLaw`); normalized spectra collapse onto a single amplitude-free
universal curve `(x/x₀)^(-α)` (`powerLaw_collapse_universal`); the functional
equation conversely *forces* the power-law form (`selfSimilar_rigidity`); and
steeper sub-leading corrections are RG-irrelevant, washing out under coarse-graining
(`subleading_irrelevant`). The rigidity and irrelevance results are the conceptual
payload: together they say that, within a fixed exponent class, every profile
satisfying scale covariance is the same universal curve, and that finite-size
corrections cannot survive the flow.

What this cycle did *not* establish, and what bounds its scope, is any link from a
genuine optimization process or a concrete architecture to the exponent `α`. The
exponent is a free parameter here; we proved the universality *given* the exponent,
not a prediction *of* the exponent from a symmetry/noise class. The structural
insight that emerged — power laws are the unique scale-covariant profiles and their
exponent is the only RG-invariant datum — tells us exactly where the next cycle must
push: deriving `α` from an architecture-independent invariant (a symmetry group or a
noise universality class), and upgrading rigidity from "exponent-matched covariance"
to "arbitrary continuous self-similarity."

## Results Summary

- `powerLaw_selfSimilar`: proved — power-law spectra obey the scale-covariance functional equation `λ(bx) = b^(-α)λ(x)`.
- `rgFixedOp_fixes_powerLaw`: proved — power laws are exact fixed points of the exponent-compensated RG operator, so the exponent is the fixed-point invariant.
- `coarseGrain_powerLaw`: proved — coarse-graining preserves the exponent and rescales only the amplitude (exponent invariant, amplitude is the running coupling).
- `powerLaw_collapse_universal`: proved — normalized spectra collapse onto the amplitude-independent universal curve `(x/x₀)^(-α)`, formalizing architecture independence.
- `selfSimilar_rigidity`: proved — any profile obeying scale covariance with exponent `α` is forced to be a power law, the converse characterization.
- `subleading_irrelevant`: proved — sub-leading corrections with steeper exponent `β > α` are RG-irrelevant; their relative size vanishes under coarse-graining.

## Research Directions

### Direction 1: Cauchy rigidity — continuous self-similarity forces a power law
**Hypothesis**: If `f : ℝ → ℝ` is positive and continuous on `(0, ∞)` and satisfies
`f(b·x)·f(1) = f(b)·f(x)` for all positive `b, x` (multiplicative self-similarity
*without* a pre-specified exponent), then there exists `α` with `f(x) = f(1)·x^(-α)`.
**Test**: Reduce to the additive Cauchy equation via `g = log ∘ f ∘ exp`, then invoke
Mathlib's `MonotoneOn`/continuous additive-Cauchy machinery to force linearity of `g`;
prove or disprove in Lean.
**Why now**: `selfSimilar_rigidity` already proves the *exponent-matched* case by a
one-line specialization; the missing step is solving for the exponent, which is a
clean classical Cauchy argument rather than new mathematics.
**If true**: Universality becomes unconditional — every continuous self-similar
spectrum, with no exponent assumed, is a member of exactly one universal class.
**If false**: A pathological (non-measurable) self-similar profile would show
universality genuinely requires a regularity hypothesis, sharpening the conjecture.

### Direction 2: Spectral collapse as a metric limit, not just a pointwise ratio
**Hypothesis**: For spectra `λ_i(x) = C_i·x^(-α) + D_i·x^(-β_i)` with `β_i > α`, the
coarse-grained, normalized profiles converge to the common curve `(x/x₀)^(-α)` in the
sup norm on any compact `[x₀, X]`, uniformly over the architecture index `i` drawn
from a bounded family.
**Test**: Strengthen `subleading_irrelevant` from a pointwise `Tendsto` to uniform
convergence using `TendstoUniformlyOn`, with the bounded family controlled by a single
modulus.
**Why now**: `subleading_irrelevant` already gives the pointwise vanishing for each
fixed `x`; the key insight is that the rate `(bx)^(-(β-α))` is monotone in `x`, so a
single tail bound controls the whole compact window at once.
**If true**: "Data collapse" acquires a precise topological meaning (uniform limit),
the form actually used when fitting measured spectra.
**If false**: Collapse would be only pointwise, predicting an irreducible spread at the
spectral edge even after infinite coarse-graining — a testable experimental signature.

### Direction 3: A two-parameter RG flow and classification of its fixed points
**Hypothesis**: The flow `R_{a,b} λ = (x ↦ a·λ(b·x))` on positive profiles has, modulo
overall scale, exactly the one-parameter family of power laws as fixed points, with `a`
and `b` constrained by `a = b^α`; no non-power-law fixed point exists under continuity.
**Test**: Define `R_{a,b}` in Lean, characterize its fixed-point set, and prove the
classification by combining `rgFixedOp_fixes_powerLaw` (existence) with Direction 1
(uniqueness).
**Why now**: The key insight is that this cycle already proved both halves separately —
power laws are fixed points and self-similarity forces power laws — so the
classification is the synthesis of two finished results.
**If true**: The universal classes are *enumerated*, indexed by the single exponent `α`,
giving the conjectured "list of universality classes" a rigorous backbone.
**If false**: A second fixed-point branch would predict a distinct, non-power-law
scaling regime — a genuinely new phase of learning dynamics to look for.

### Direction 4: Relevant vs. irrelevant directions and a crossover scale
**Hypothesis**: A correction with *shallower* exponent `β < α` is RG-*relevant*: under
coarse-graining its relative size diverges, and there is a finite crossover scale
`b* = (|D/C|)^{1/(β-α)} / x` past which the correction dominates the leading term.
**Test**: Prove the `Tendsto … atTop` (divergence) companion to `subleading_irrelevant`
for `β < α`, and exhibit `b*` explicitly as the unique solution of `|D|(bx)^(-β) =
|C|(bx)^(-α)`.
**Why now**: `subleading_irrelevant` handled `β > α` by sign of `β - α`; flipping the
inequality reuses the identical `rpow` machinery, so the relevant case is immediately
in reach. The key insight is that the same exponent difference that guarantees collapse,
when negated, guarantees a phase transition.
**If true**: We obtain a phase-transition-aware picture: every spectrum has a measurable
crossover scale separating the universal regime from a correction-dominated regime.
**If false**: Absence of a crossover would mean relevant corrections never overtake the
leading term, contradicting the RG dichotomy and demanding a new mechanism.

### Direction 5: Deriving the exponent from a symmetry/noise invariant
**Hypothesis**: For kernel-limit (NTK) models on a task with a fixed eigenvalue decay
`μ_k ∼ k^(-s)` and label-noise regularity index `r`, the Hessian spectral exponent is a
fixed affine function `α = φ(s, r)` independent of width and depth.
**Test**: Formalize an idealized kernel spectrum, compute its induced Hessian-analogue
spectrum symbolically, and prove the exponent depends only on `(s, r)` — not on the
finite truncation level standing in for width/depth.
**Why now**: The amplitude/exponent split proved here (`coarseGrain_powerLaw`,
`powerLaw_collapse_universal`) isolates the exponent as the *only* width/depth-invariant
datum; the key insight is that this reduces "predict the universal class" to "compute one
scalar from `(s, r)`," a finite symbolic task rather than an empirical one.
**If true**: The conjecture's central claim — exponent determined solely by task symmetry
and noise class — would hold rigorously in the kernel limit, the first regime where it is
checkable.
**If false**: A residual architecture dependence in the kernel limit would refute the
strongest form of the conjecture and pinpoint exactly which structural assumption
(e.g. depth-independence) fails.
