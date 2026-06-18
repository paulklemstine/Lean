# Future Directions — Rademacher Complexity in the Sign-Average Model

These directions extend `Catalog/MachineLearning/RademacherSpectral.lean`, which now
contains a self-contained, measure-theory-free development of empirical Rademacher
complexity over the uniform average on the `2^n` sign patterns `s : Fin n → Bool`
(`signAvg`). The file proves:

- `signAvg_sgn_orthogonal` — orthogonality of Rademacher characters `E_σ[σ_iσ_j] = [i=j]`;
- `expected_sq_norm_rademacher_sum` — the scalar second-moment identity
  `E_σ(∑ᵢσᵢaᵢ)² = ∑ᵢaᵢ²`, and its inner-product-space generalization
  `expected_sq_norm_rademacher_sum_inner` (`E_σ‖∑ᵢσᵢxᵢ‖² = ∑ᵢ‖xᵢ‖²`);
- `signAvg_le_sqrt_signAvg_sq` — the power-mean/Jensen step `E Y ≤ √(E Y²)`;
- `linear_rademacher_bound` — the linear/kernel base-case rate `empRadLinear ≤ C·B/√n`;
- `netComp_lipschitz_pow` and `netComp_nonexpansive_of_le_one` — the spectral depth
  bound (`C^L`-Lipschitz) and depth-independent nonexpansiveness for `C ≤ 1`.

The single remaining research target inside the file is `linear_rademacher_lower_bound`,
the tightness companion to the base-case bound. Below are five testable, falsifiable
extensions, ordered roughly by readiness.

## 1. The Szarek sharp constant for `linear_rademacher_lower_bound`

The file states `B/√(2n) ≤ empRadLinear n 1 (fun _ => B)` as a `sorry`. The constant
`1/√2` is exactly Szarek's optimal lower Khintchine constant, attained at `n = 2`
(numerically: `n=1` gives `E|S|=1 ≥ 1/√2`, `n=2` gives equality `E|S|=1=√2/√2`,
`n=3` gives `1.5 ≥ √(3/2)`).

The key insight is that, in the constant-feature case, `empRadLinear` collapses to
`(B/n)·E_σ|∑σᵢ|`, and `∑σᵢ = (#true − #false)` is a one-dimensional symmetric
random walk; the whole question becomes a single sharp inequality
`E_σ|∑σᵢ| ≥ √(n/2)` about binomial absolute moments — a `Finset` statement with no
geometry left in it.

Why now? The exact second moment `expected_sq_norm_rademacher_sum` already pins the
`L²` norm of the walk at `√n`, so only the `L¹/L²` comparison constant is missing;
proving the (weaker but still useful) Paley–Zygmund constant `1/√3` is immediately in
reach via the fourth moment `E_σ(∑σᵢ)⁴ = 3n²−2n`, which is the same orthogonality
computation iterated twice.

## 2. The Talagrand contraction lemma for `signAvg`

The bridge from `netComp_lipschitz_pow` to a genuine network bound is the comparison
principle: if `φ` is `ρ`-Lipschitz with `φ 0 = 0`, then
`signAvg n (fun s => sup_f (1/n)∑ᵢσᵢφ(f xᵢ)) ≤ ρ·signAvg n (fun s => sup_f (1/n)∑ᵢσᵢ f xᵢ)`.
Chaining this `L` times and feeding in `linear_rademacher_bound` yields
`empRademacher(network) ≤ C^L·B/√n`.

The key insight is that contraction needs no measure theory here: `signAvg` is a
finite sum, so the classical proof reduces to a *one-coordinate* comparison — peel
coordinate `i`, bound the two sign branches using Lipschitzness, recombine — exactly
the flip-a-coordinate involution already used to prove `signAvg_sgn_orthogonal`.

Why now? Both endpoints are formalized (`linear_rademacher_bound`,
`netComp_lipschitz_pow`); the contraction lemma is the only missing intermediate, and
its discrete proof reuses the `Function.update _ i (¬·)` involution we have shown
compiles.

## 3. The depth-improved `O(C·√L/√n)` bound (Golowich–Rakhlin–Shamir)

`netComp_lipschitz_pow` gives the exponential-in-depth constant `C^L`. The sharper
modern bound replaces `C^L` by a factor scaling like `√L` after spectral
normalization, giving `O(C·√L/√n)`.

The key insight is that the `√L` arises from a Jensen-on-the-MGF step (`log E exp`
is concave in depth) rather than from iterating the crude product bound; formalizing
it amounts to a one-dimensional convexity inequality layered on top of the
already-formalized second moment and the power-mean step `signAvg_le_sqrt_signAvg_sq`.

Why now? The analytic core — the `√(∑‖xᵢ‖²)` second moment (now available in full
inner-product generality via `expected_sq_norm_rademacher_sum_inner`) and the
`(E Y)² ≤ E Y²` comparison — is already in the file; the refinement is a convexity
argument on these, not a new foundation.

## 4. Massart's finite-class lemma via coordinatewise factorization

For a finite class of `m` hypotheses bounded by `B`, conjecture
`empRademacher ≤ B·√(2·log m)/√n`. This is the discrete Massart lemma and is the
bridge from the linear base case to covering-number bounds.

The key insight is that the maximal-inequality proof becomes purely combinatorial:
the sub-Gaussian MGF `signAvg n (fun s => exp(λ∑ᵢσᵢ aᵢ)) ≤ exp(λ²‖a‖²/2)` factorizes
over coordinates because the `2^n` average is literally a `Finset.prod` over the `n`
independent Boolean coordinates — `signAvg n (fun s => ∏ i, f i (s i)) = ∏ i, (f i true + f i false)/2`.

Why now? `signAvg` is a normalized `Finset` sum over a `Pi` type, so the
coordinatewise factorization is a structural identity (provable as a standalone lemma
in the same file), and the per-coordinate Hoeffding bound reduces to the elementary
`cosh λ ≤ exp(λ²/2)`.

## 5. Symmetrization → a uniform generalization certificate

Conjecture a symmetrization inequality bounding the worst-case empirical/population
gap by `2·empRademacher`, then combine with `linear_rademacher_bound` and (via
Direction 2) `netComp` to obtain an explicit `O(C·B/√n)` generalization certificate;
for spectrally normalized networks (`C ≤ 1`) this becomes *depth-independent* by
`netComp_nonexpansive_of_le_one`.

The key insight is that in the finite/discrete sample model the "ghost sample"
symmetrization is a reindexing of one finite sum by another, so the inequality is a
`Finset.sum` manipulation (a second application of the coordinate involution) rather
than a statement about independent copies of a random variable.

Why now? `netComp_nonexpansive_of_le_one` already certifies depth-independent
`1`-Lipschitzness, so the certificate would immediately specialize to the
practically important regime where the bound does not blow up with depth.
