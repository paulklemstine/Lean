# Future Directions: Data Processing Inequality and Quotient Security

## Synthesis

The formal verification of the data processing inequality (DPI) for finite pushforward distributions establishes a foundational theorem schema: **deterministic channels are monotone for optimal binary statistical tests**. This opens five interconnected research directions that together form a program to build the formal infrastructure for information-theoretic security proofs in algebraic cryptography.

The key bridge is between (1) the abstract DPI, which is pure probability/information theory, and (2) the algebraic structure of quotient maps in module-LWE, which constrains the fiber geometry. Directions 1-2 extend the abstract theory (stronger divergences, stochastic channels). Directions 3-4 exploit algebraic structure (fiber analysis, kernel invariance). Direction 5 aims at the grand challenge of connecting to NIST-standardized schemes.

All five directions build directly on the verified theorems in `Cryptography/QuotientSecurity/DataProcessing.lean` and the catalog infrastructure in `Catalog/Cryptography/ModuleLWE/`.

---

## Direction 1: Total Variation Equals Decision Advantage

**Conjecture:** For finite types with `[Fintype α] [DecidableEq α]` and distributions `μ ν : PMF α`:

```
decisionAdvantage μ ν = tvd μ ν
```

where `tvd μ ν = (1/2) * ∑ a, |(μ a).toReal - (ν a).toReal|`.

**Test:** Compute both quantities for all PMF pairs on `Fin n` with `n ≤ 6` using rational arithmetic (exact). Verify equality to machine precision.

**Impact:** This bridges the Boolean-test formulation (used in cryptographic reductions) with the L¹-norm formulation (used in probability theory). It would allow importing all Mathlib results about L¹-norms into the cryptographic setting.

**Catalog References:** `Catalog/Cryptography/ModuleLWE/Defs.lean` (definition of `tvd`), `Cryptography/QuotientSecurity/DataProcessing.lean` (definition of `decisionAdvantage`).

**Proof Strategy:** Direction ≤: For any D, `testAdvantage μ ν D = |∑_a (μ(a) - ν(a)) · D(a)| ≤ ∑_a |μ(a) - ν(a)| · |D(a)| ≤ ∑_a |μ(a) - ν(a)|`. With the 1/2 factor, this gives `testAdvantage ≤ 2 * tvd`. Direction ≥: The Neyman-Pearson distinguisher `D*(a) = 1 iff μ(a) > ν(a)` achieves `testAdvantage = tvd`. Combine both directions.

**Domain Bridges:** Probability theory ↔ Cryptography ↔ Functional analysis (L¹ norms).

**Lineage:** Extends `decisionAdvantage_map_le` by providing an explicit formula for the quantity being contracted.

**Ambition:** Solid extension — well-understood mathematically, but non-trivial to formalize due to ENNReal/Real conversions.

---

## Direction 2: Stochastic Channel Extension (Markov Kernels)

**Conjecture:** The DPI extends from deterministic maps to stochastic channels. For a Markov kernel `K : M → PMF N` and the induced channel map `K_* : PMF M → PMF N`:

```
decisionAdvantage (K_* μ) (K_* ν) ≤ decisionAdvantage μ ν
```

**Test:** Implement randomized channels as stochastic matrices. Verify the inequality for all stochastic matrices of size up to 4×4 with randomly sampled entries and distributions.

**Impact:** This is the full data processing inequality. It would subsume the deterministic case (where K is a delta-kernel) and enable analysis of noisy channels, key agreement protocols, and privacy amplification by randomized response.

**Catalog References:** `Cryptography/QuotientSecurity/DataProcessing.lean` (the deterministic DPI).

**Proof Strategy:** Express `K_*μ` as a mixture: `(K_* μ)(b) = ∑_a μ(a) · K(a)(b)`. Then `acceptProb(K_* μ, D) = ∑_a μ(a) · acceptProb(K(a), D)`. The test advantage becomes `|∑_a (μ(a) - ν(a)) · acceptProb(K(a), D)|`. By the triangle inequality and the constraint that acceptProb(K(a), D) ∈ [0,1], this is ≤ `∑_a |μ(a) - ν(a)| = 2 · tvd(μ,ν) = 2 · decisionAdvantage(μ,ν)`. Actually, a tighter bound requires the coupling argument or convexity.

**Domain Bridges:** Information theory ↔ Markov chain theory ↔ Cryptographic security models.

**Lineage:** Generalizes `decisionAdvantage_map_le` from deterministic to stochastic maps.

**Ambition:** Grand challenge — requires formalizing Markov kernels and their interaction with PMFs, which is significant new infrastructure.

---

## Direction 3: Strict Contraction Characterization

**Conjecture:** For a non-injective surjective map `f : M → N` between finite types with `|M| > |N|`, there exist distributions `μ, ν` on `M` such that:

```
decisionAdvantage (PMF.map f μ) (PMF.map f ν) < decisionAdvantage μ ν
```

Moreover, equality holds in `decisionAdvantage_map_le` if and only if every optimal distinguisher for `(μ, ν)` is constant on fibers of `f`.

**Test:** For all maps `Fin 4 → Fin 2` and `Fin 4 → Fin 3`, enumerate optimal distinguishers (via Neyman-Pearson) and check fiber-constancy. Correlate with whether equality holds in the DPI.

**Impact:** This characterizes exactly when compression is lossless for distinguishing, answering the question: "When does quotient security achieve tight reduction?" The fiber-constancy criterion connects to kernel invariance in module-LWE.

**Catalog References:** `Cryptography/QuotientSecurity/DataProcessing.lean` (`decisionAdvantage_map_le`, `QuotientMonotone`), `Catalog/Cryptography/ModuleLWE/Defs.lean` (`KernelInvariantError`).

**Proof Strategy:** (Existence of strict contraction) Choose μ concentrated on one element within a fiber, ν concentrated on another element in the same fiber. Then f_*μ = f_*ν, giving post-compression advantage = 0 but pre-compression advantage > 0. (Equality characterization) If the optimal D* is fiber-constant, it factors through f as D* = D'∘f, and the pullback achieves the same advantage. Conversely, if D* is not fiber-constant, the compressed supremum misses it.

**Domain Bridges:** Combinatorics (fiber structure) ↔ Optimization (characterization of extremizers) ↔ Cryptography (tight reductions).

**Lineage:** Refines `decisionAdvantage_map_le` from inequality to equality characterization.

**Ambition:** Solid extension — the existence half is easy; the equality characterization is non-trivial but tractable.

---

## Direction 4: Kernel-Invariant Factorization Through Quotient

**Conjecture:** If `χ : PMF M` is kernel-invariant under a surjective linear map `f : M →ₗ[R] N`, then there exists a unique PMF `χ̄ : PMF N` such that `PMF.map f χ = χ̄`, and moreover, `χ` is completely determined by `χ̄` and the kernel `ker f`.

In other words, kernel-invariant distributions factor through the quotient:

```
∃ χ̄ : PMF N, PMF.map f χ = χ̄ ∧ ∀ m, χ m = χ̄ (f m) / (Fintype.card (ker f))
```

**Test:** For linear maps `(Z/qZ)^n → Z/qZ` with q ∈ {2,3,5}, construct kernel-invariant distributions and verify the factorization formula numerically.

**Impact:** This provides the algebraic mechanism behind quotient security: kernel-invariant distributions are exactly those for which compression is "invertible" in a statistical sense. It connects the DPI to the structure theory of modules.

**Catalog References:** `Catalog/Cryptography/ModuleLWE/Defs.lean` (`KernelInvariantError`), `Cryptography/QuotientSecurity/DataProcessing.lean` (`KernelInvariant`).

**Proof Strategy:** Kernel invariance means χ is constant on cosets m + ker(f). Each coset maps bijectively to a point in N. So χ(m) = χ(m') whenever f(m) = f(m'), giving a well-defined quotient PMF χ̄(n) = |ker f| · χ(m) for any m with f(m) = n. The pushforward PMF.map f χ then equals χ̄ by construction.

**Domain Bridges:** Module theory (kernels, quotients) ↔ Probability (factorization) ↔ Cryptography (structured noise).

**Lineage:** Builds on `KernelInvariant` definition in `DataProcessing.lean` and `KernelInvariantError` in catalog.

**Ambition:** Solid extension — clean algebraic result, but requires careful handling of Fintype.card and division.

---

## Direction 5: Instantiation for CRYSTALS-Kyber Compression

**Conjecture:** For the specific compression maps used in CRYSTALS-Kyber (rounding from Z/q to Z/d with d | q), the contraction ratio of the DPI can be bounded explicitly:

```
decisionAdvantage(compress_* χ, compress_* uniform) ≤ (d/q)^k · decisionAdvantage(χ, uniform)
```

for dimension-k compression, where `compress(x) = round(x · d/q) mod d`.

**Test:** Compute the contraction ratio for Kyber parameters (q=3329, d ∈ {2^10, 2^11}) on 1D distributions. Compare with the (d/q)^k bound.

**Impact:** This would give the first formally verified security bound for the compression step in a NIST-standardized post-quantum KEM. It would bridge abstract information theory with concrete cryptographic engineering.

**Catalog References:** `Catalog/Cryptography/ModuleLWE/Compression.lean` (compression correctness), `Cryptography/QuotientSecurity/DataProcessing.lean` (DPI).

**Proof Strategy:** The compression map is not linear but is a deterministic rounding function. The DPI gives the qualitative result (advantage doesn't increase). The quantitative bound requires analyzing the fiber structure of rounding: each output value has either ⌊q/d⌋ or ⌈q/d⌉ preimages, and the contraction depends on how the noise distribution aligns with these fibers.

**Domain Bridges:** Post-quantum cryptography ↔ Standards compliance (NIST) ↔ Number theory (modular rounding) ↔ Information theory (DPI).

**Lineage:** Connects `decisionAdvantage_map_le` to `decode_correct_of_linear_noise_bound` from the compression module.

**Ambition:** Grand challenge — requires instantiating abstract theory for concrete NIST parameters, crossing from pure math to applied cryptographic engineering.
