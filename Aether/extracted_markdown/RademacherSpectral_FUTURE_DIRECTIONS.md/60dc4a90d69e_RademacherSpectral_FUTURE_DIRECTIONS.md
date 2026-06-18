# Future Directions — Rademacher Complexity of Neural Networks

These directions extend `Catalog/MachineLearning/RademacherSpectral.lean`, which
formalizes the *empirical* Rademacher complexity as an honest uniform average over
the `2^n` sign patterns `s : Fin n → Bool` (`signAvg`), proves the discrete
second-moment identity `expected_sq_norm_rademacher_sum`
(`E_σ ‖∑ᵢ σᵢ xᵢ‖² = ∑ᵢ ‖xᵢ‖²`), the linear/kernel base case
`linear_rademacher_bound` (`empRademacher ≤ C·B/√n`), and the spectral depth bound
`netComp_lipschitz_pow` (an `L`-layer network of `C`-Lipschitz layers is
`C^L`-Lipschitz). Together these isolate exactly the two ingredients — a base-case
rate and a Lipschitz contraction — whose product yields neural-network bounds.
They also connect to the catalog's algebraic abstraction in
`Catalog/MachineLearning/Foundations.lean` (`spectralComplexityBound`,
`spectral_complexity_le_card_spectrum`) and the Lipschitz machinery in
`Catalog/MachineLearning/ResNetLipschitz.lean`.

## 1. The Talagrand contraction lemma for `signAvg`

The missing link between `netComp_lipschitz_pow` and a genuine network bound is the
contraction (comparison) principle: if `φ` is `ρ`-Lipschitz with `φ 0 = 0`, then
`signAvg n (fun s => sup_f (1/n) ∑ᵢ σᵢ φ(f xᵢ)) ≤ ρ · signAvg n (fun s => sup_f (1/n) ∑ᵢ σᵢ f xᵢ)`.
Chaining this `L` times over `netComp` and feeding in `linear_rademacher_bound`
gives `empRademacher(network) ≤ C^L · B / √n`.

The key insight is that contraction need not invoke any measure theory in this
discrete model: the sign average is a finite sum, so the classical proof reduces to
a *one-coordinate* comparison (peel coordinate `i`, bound the two sign branches
using Lipschitzness, recombine) that is amenable to `Finset` induction — exactly the
same flip-a-coordinate technology already used to prove `signAvg_sgn_mul`.

Why now? We already have the two endpoints in Lean (`linear_rademacher_bound` and
`netComp_lipschitz_pow`); the contraction lemma is the only intermediate object
needed, and its discrete proof reuses an involution argument we have shown compiles.

## 2. The depth-improved `O(C·√L/√n)` bound (Golowich–Rakhlin–Shamir)

`netComp_lipschitz_pow` gives the *exponential-in-depth* constant `C^L`. The sharper
modern result replaces `C^L` by something scaling like `√L` (after Frobenius/spectral
normalization), giving the target rate `O(C·√L/√n)`.

The key insight is that the `√L` arises from a *Jensen-on-the-MGF* step
(`log E exp` is concave in depth) rather than from iterating the crude product bound;
formalizing it amounts to proving a one-dimensional convexity inequality on top of
the already-formalized second-moment identity `expected_sq_norm_rademacher_sum`.

Why now? The hard analytic core (the `√(∑‖xᵢ‖²)` second moment and the
`(E Y)² ≤ E Y²` power-mean step `signAvg_le_sqrt_signAvg_sq`) is already in the file;
the refinement is a convexity argument layered on these, not a new foundation.

## 3. Massart's finite-class lemma in the `signAvg` model

For a finite class of `m` hypotheses bounded by `B`, conjecture
`empRademacher n m hm f ≤ B · √(2 · Real.log m) / √n`. This is the discrete Massart
lemma and is the bridge from the linear base case to *covering-number* bounds for
infinite classes.

The key insight is that the maximal-inequality proof becomes purely combinatorial
here: the sub-Gaussian MGF `signAvg n (fun s => exp(λ ∑ᵢ σᵢ f j i)) ≤ exp(λ²B²n/2)`
factorizes over coordinates because the `2^n` average factors as a product over the
`n` independent Boolean coordinates — a `Finset.prod`/`Fintype.piFinset` identity.

Why now? `signAvg` is literally a normalized `Finset` sum over a `Pi` type, so the
coordinatewise factorization is a structural `simp`-level fact rather than a
probabilistic theorem; the per-coordinate Hoeffding bound is a finite `cosh ≤ exp`
inequality.

## 4. From Rademacher to a PAC-Bayes / uniform-generalization guarantee

Conjecture a symmetrization inequality stating that the worst-case gap between the
empirical mean and the population mean over the class is controlled by
`2 · empRademacher`, and combine it with `linear_rademacher_bound` to get an explicit
`O(C·B/√n)` generalization certificate for spectrally normalized linear predictors,
and (via Direction 1) for `netComp` networks.

The key insight is that in the finite/discrete sample model the "ghost sample"
symmetrization is a *reindexing* of one finite sum by another, so the inequality is a
`Finset.sum` manipulation rather than a statement about independent copies of a
random variable.

Why now? `netComp_nonexpansive_of_le_one` already certifies that spectrally
normalized networks are `1`-Lipschitz at every depth, so the generalization
certificate would immediately specialize to a depth-*independent* guarantee, which is
the practically important regime.

## 5. Tightness: a matching lower bound via Khintchine

Conjecture that `linear_rademacher_bound` is tight up to an absolute constant:
for the single hypothesis `w` with `‖w‖ = C` and an orthonormal sample with
`‖xᵢ‖ = B`, `empRademacher ≥ c · C·B/√n` for an absolute `c > 0`.

The key insight is that the lower bound is the *reverse* Khintchine inequality
`E|∑ᵢ σᵢ aᵢ| ≥ (1/√2)·√(∑ aᵢ²)`, and in the orthonormal case the second moment we
already computed (`expected_sq_norm_rademacher_sum`) pins down `√(∑‖xᵢ‖²) = B√n`
exactly, so only the constant-factor lower Khintchine bound remains.

Why now? The exact second moment is already a theorem in this file, so a tightness
result needs only the lower Khintchine constant — turning our upper bound into a
*characterization* of the linear Rademacher rate, the strongest possible statement.
