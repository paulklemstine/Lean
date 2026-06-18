# Future Directions: Tropical Universality Theory for Computation DAGs

## Overview

The present work establishes that the *tropical profile* of a computation DAG — the finite set of affine forms whose pointwise maximum defines its envelope — yields computable invariants of asymptotic scaling behavior. We proved that tropical equivalence preserves the asymptotic slope, the essential dominant bias, and that parallel (residual) composition obeys a "fastest branch wins" principle.

Below are five falsifiable scientific hypotheses that extend this framework. Each is stated precisely, with an explicit observable, a proposed test, and a clear refutation criterion.

---

## Hypothesis 1: Coarse-Graining Invariance

**Conjecture.** Let `G` be a computation DAG with tropical profile `P(G)`. Define a *coarse-graining operator* `CG_k` that contracts every chain of `k` consecutive serial edges into a single edge whose affine form is the composition (i.e., slope product and bias accumulation) of the original forms. Then the asymptotic slope of `P(CG_k(G))` equals the asymptotic slope of `P(G)` for all `k ≥ 1`.

**Observable.** The maximum slope `maxSlope(P(CG_k(G)))` as a function of `k`.

**Test.** Formalize `CG_k` as a graph transformation on DAGs equipped with affine edge weights. Compute `maxSlope(P(CG_k(G)))` for several DAG families (chains, trees, diamond graphs) across `k = 1, 2, ..., 10`. Verify algebraically that the max-slope path in the coarse-grained DAG corresponds to the max-slope path in the original.

**Refutation criterion.** Exhibit a DAG `G` and a coarse-graining level `k` such that `maxSlope(P(CG_k(G))) ≠ maxSlope(P(G))`. This would occur if coarse-graining creates new dominant paths by composing non-dominant edges in a way that produces a steeper combined slope than any original source-to-sink path.

---

## Hypothesis 2: Depth-Width Duality under Tropical Equivalence

**Conjecture.** For the class of layered DAGs (where edges only connect consecutive layers), there exist families `{D_n}` (deep, narrow) and `{W_n}` (shallow, wide) such that `P(D_n)` and `P(W_n)` are tropically equivalent for all `n`. Specifically, a depth-`L` width-`W` DAG with uniform affine weights has the same tropical profile as a depth-`1` width-`L·W` DAG whose forms are all source-to-sink path compositions.

**Observable.** The pointwise envelope function `evalMax(P(D_n), x)` versus `evalMax(P(W_n), x)`.

**Test.** Construct explicit layered DAGs with `L` layers of width `W` and uniform edge weights `(a, b)`. Enumerate all `W^L` source-to-sink paths to compute the tropical profile. Compare with a single-layer DAG whose forms are the path compositions. Verify `evalMax` equality numerically for `x ∈ [-100, 100]` and symbolically via slope/bias analysis.

**Refutation criterion.** Find a layered DAG family where the deep and wide versions produce different envelopes. This would happen if path interactions in the deep DAG create cancellations or dominance patterns not reproducible by a flat union of path forms.

---

## Hypothesis 3: Dominant Multiplicity Predicts Initialization Variance

**Conjecture.** For a tropical profile `P` with dominant multiplicity `m` (number of forms achieving the max slope), the variance of the loss across random initializations scales as `Θ(1/m)` in the large-width limit. Profiles with higher multiplicity exhibit lower variance because more independent "paths to optimality" exist.

**Observable.** The ratio `Var(L_N) / (1/m)` across random seeds, where `L_N` is the loss at parameter count `N` and `m` is the dominant multiplicity of the architecture's tropical profile.

**Test.**
1. Choose three architecture families with known tropical profiles having multiplicities `m = 1, 2, 4`.
2. Train each at parameter counts `N = 10^4, 10^5, 10^6` with 100 random seeds.
3. Compute the variance of final loss across seeds.
4. Fit `Var ~ C/m` and test goodness of fit.

**Refutation criterion.** If the variance ratio `Var(L_N) · m` is not approximately constant across architectures (i.e., varies by more than a factor of 3), the hypothesis is refuted. Alternative: if variance scales with a different function of `m` (e.g., `1/m^2` or `log(m)/m`), the specific prediction fails but a modified version may hold.

---

## Hypothesis 4: Optimizer Invariance of the Tropical Exponent

**Conjecture.** For any two first-order optimizers `O_1, O_2` (SGD, Adam, AdaGrad, etc.) that converge to a global minimum of the empirical risk, the scaling exponent `α` extracted from the loss curve `L(N)` is identical, provided the tropical profile of the architecture is fixed. That is, the optimizer affects only the prefactor and transient behavior, not the asymptotic exponent.

**Observable.** The exponent `α` in `L(N) ~ C · N^{-α}`, estimated by linear regression on `(log N, log L)` for large `N`.

**Test.**
1. Fix an architecture (e.g., a 6-layer transformer with known tropical profile).
2. Train with SGD, Adam, AdaGrad, and LAMB at parameter counts `N = 10^5` to `10^8`.
3. Extract `α` from each optimizer's scaling curve via log-log regression on the last decade of `N`.
4. Compare `α` values across optimizers.

**Refutation criterion.** If `α` values differ by more than 10% across optimizers for the same architecture, the hypothesis is falsified. A softer refutation: if the ordering of `α` across optimizers is architecture-dependent (i.e., Adam gives steeper exponents than SGD for one architecture but not another), then the tropical exponent is not optimizer-invariant even qualitatively.

---

## Hypothesis 5: Phase Transitions at Exposed-Face Transitions

**Conjecture.** When a tropical profile `P(θ)` depends on a continuous parameter `θ` (e.g., a depth/width ratio), the scaling exponent `α(θ)` is piecewise constant, changing only at values `θ*` where the exposed-face structure of the profile's Newton polytope changes. These transitions correspond to measurable scaling-law regime shifts in training curves.

**Observable.** The exponent function `α(θ)` and the breakpoints `{θ*}` where it changes.

**Test.**
1. Define a parametric DAG family where edge weights depend linearly on `θ ∈ [0, 1]`.
2. Compute the tropical profile `P(θ)` symbolically as a function of `θ`.
3. Identify the values `θ*` where the set of dominant forms changes (i.e., where a new affine form becomes the steepest).
4. Train the corresponding architectures at `θ = 0, 0.1, 0.2, ..., 1.0` and extract empirical `α(θ)`.
5. Check that empirical `α(θ)` is approximately constant between consecutive `θ*` values and jumps at `θ*`.

**Refutation criterion.** If empirical `α(θ)` varies smoothly and continuously through predicted breakpoints `θ*`, or if jumps occur at values not predicted by the tropical analysis, the hypothesis is refuted. A partial refutation: if the predicted breakpoints are correct but the exponent values between breakpoints are wrong, the phase-transition structure is confirmed but the quantitative theory needs refinement.

---

## Summary

| # | Hypothesis | Key Prediction | Strongest Test |
|---|-----------|---------------|---------------|
| 1 | Coarse-graining invariance | `maxSlope` unchanged under edge contraction | Algebraic proof or counterexample |
| 2 | Depth-width duality | Deep-narrow ≡ shallow-wide tropically | Envelope comparison |
| 3 | Multiplicity → variance | `Var ∝ 1/m` | Multi-seed training experiments |
| 4 | Optimizer invariance | Same `α` across SGD/Adam/etc. | Cross-optimizer scaling curves |
| 5 | Exposed-face phase transitions | `α(θ)` piecewise constant | Parametric architecture sweep |

Each hypothesis, if confirmed, would significantly advance the tropical universality program. If refuted, the failure mode itself would be informative — revealing where the tropical abstraction breaks down and what additional structure is needed.
