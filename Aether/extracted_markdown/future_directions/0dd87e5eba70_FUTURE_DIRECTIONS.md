# Future Directions: Prime-Spectral Online Mirror Descent

## Breakthrough Opportunities (ranked by impact)

### 1. Finite-Horizon Regret Bound with Explicit Constants

**Theorem Statement:**
```
∀ (μ₀ : SpectralDistribution) (η > 0) (qs : List Query) (p⋆ : SpectralPoint),
  pointwiseOnlineRegret μ₀ η qs p⋆ ≤ (-log(μ₀ p⋆)) / η + (η / 2) * |qs|
```

**Proof Strategy:**
1. Define the unnormalized cumulative weight `W_T(p) = μ₀(p) · exp(-η · Σ ℓ_t(p))`.
2. Show by induction on `qs` that `W_T(p) = μ₀(p) · exp(-η · cumulativePointDefect qs p)`.
3. Show that the product of partition functions equals `Σ_p W_T(p)` divided by the product of normalizations.
4. Use the one-step upper variational bound `η·E[ℓ] ≤ -log Z + η²/2` (requires proving `exp(-x) ≤ 1 - x + x²/2` for `x ∈ [0,1]`).
5. Telescope over rounds and rearrange.

**Why This Is Revolutionary:** Gives the first machine-verified finite-horizon regret bound for online learning on proof spectra. The explicit constant `O(√(log|Spec| · T))` with balanced η connects to PAC-Bayes and provides computational complexity guarantees.

**Catalog Leverage:** `online_variational_step_lower`, `onlinePosterior_isDistribution`, `gibbsPartition_pos`

**Research Mode:** prove

**Estimated Depth:** 4/5

---

### 2. Infinite-Horizon Martingale Extension

**Theorem Statement:**
```
∀ (μ₀ : SpectralDistribution) (η > 0),
  ∃ M : ℕ → ℝ, IsMartingale M ∧
  ∀ n, |M n - expectedLoss n| ≤ C · √(log n / n)
```

**Proof Strategy:**
1. Define `M_n = -log(Π_{t<n} Z_t) + η · Σ_{t<n} E_t[ℓ_t]` as the free-energy martingale.
2. Show the martingale property using the tower property of conditional expectation.
3. Apply Azuma-Hoeffding for bounded differences.
4. Extract almost-sure convergence via Borel-Cantelli.

**Why This Is Revolutionary:** Extends the finite-list framework to infinite sequences, enabling connections to ergodic theory and Birkhoff's theorem. Creates a bridge to measure-theoretic probability on proof spectra.

**Catalog Leverage:** `thermodynamicDissipation_nonneg`, `spectralFreeEnergy_nonneg`

**Research Mode:** formalize

**Estimated Depth:** 5/5

---

### 3. Schrödinger-Bridge Entropic Transport on Proof Spectra

**Theorem Statement:**
```
∀ (μ ν : SpectralDistribution),
  ∃! γ : JointDistribution, entropic_transport_cost γ = inf over all couplings
```

**Proof Strategy:**
1. Define entropic optimal transport cost with KL penalty on the finite spectrum.
2. Show that the Sinkhorn algorithm converges to the Schrödinger bridge.
3. Connect the bridge to the online posterior: the time-averaged posterior is an approximate Schrödinger bridge between μ₀ and the "target" distribution.

**Why This Is Revolutionary:** Connects online proof search to optimal transport theory, enabling interpolation between proof strategies and thermodynamic states.

**Catalog Leverage:** `mirrorPotential`, `normalizedGibbsUpdate_isDistribution`

**Research Mode:** formalize

**Estimated Depth:** 4/5

---

### 4. Lattice/Post-Quantum Cryptographic Interpretation

**Theorem Statement:**
```
∀ (lattice_dimension : ℕ) (security_parameter : ℕ),
  spectral_distinguishing_advantage ≤ exp(-Ω(security_parameter))
  ↔ regret_per_round ≤ O(1/√T)
```

**Proof Strategy:**
1. Formalize a lattice-based closure proof semiring where `cl` is defined via lattice reductions.
2. Show that countermodel defect corresponds to the distinguishing advantage.
3. Connect regret bounds to security reductions via the chain rule of divergences.

**Why This Is Revolutionary:** Creates a formal bridge between online learning regret and post-quantum cryptographic security. Low regret implies high security, and vice versa.

**Catalog Leverage:** `log_inverse_uniform_cardinality`, `post_quantum_uniform_expectedDefect_bound`

**Research Mode:** formalize

**Estimated Depth:** 5/5

---

### 5. Certified Robustness for Neural/Tropical Classifiers

**Theorem Statement:**
```
∀ (classifier : X → Y) (x : X) (radius : ℝ),
  lipschitzCertifiedRadius μ₀ x y n ≥ radius →
  ∀ x' ∈ Ball(x, radius), classifier x' = classifier x
```

**Proof Strategy:**
1. Instantiate the spectral framework with tropical semiring classifiers.
2. Show that the defect loss corresponds to the classification margin.
3. Use the online posterior to compute certified radii.
4. Connect to Lipschitz bounds via the tropical structure.

**Why This Is Revolutionary:** Provides machine-verified certified robustness guarantees for neural network classifiers via the proof-spectral framework, unifying certified ML with proof theory.

**Catalog Leverage:** `lipschitzCertifiedRadius`, `thermodynamic_certified_robustness_radius`

**Research Mode:** formalize

**Estimated Depth:** 4/5

---

## Under-explored Territory

### Finite KL Divergence on Spectral Distributions
The file defines `mirrorPotential` (negative entropy) but does not yet formalize the full KL divergence `KL(ν ‖ μ) = Σ ν(p) · log(ν(p)/μ(p))`. Adding this would enable:
- Donsker-Varadhan variational principle on spectra
- Exact Gibbs free energy minimization characterization
- Pinsker's inequality for total variation bounds

### List Scanning vs Recursion
The `onlinePosterior` is defined recursively on `List`. An alternative `List.scanl`-based definition would be more natural for proving telescoping identities. Proving equivalence would unlock more efficient induction patterns.

### Computational Complexity Bounds
The current development proves mathematical bounds but does not formalize computational complexity. Adding `O(|Spec| · T)` time complexity and `O(|Spec|)` space complexity bounds would strengthen the algorithmic content.

---

## Cross-Domain Bridges

1. **Proof Theory → Ergodic Theory:** The time-averaged posterior converges (Cesàro) to a limit distribution. In the ergodic-theoretic sense, this should correspond to the unique invariant measure of the Gibbs Markov chain on the spectrum.

2. **Online Learning → Quantum Computing:** The Gibbs update `μ · exp(-η·H)` resembles imaginary-time evolution `e^{-βH}` in quantum mechanics. A quantum spectral point formalization could connect to quantum error correction codes.

3. **Thermodynamics → Category Theory:** The free energy functional defines a functor from the category of spectral distributions to ℝ. The variational inequality is a natural transformation. This could be formalized as a categorical semantics for online proof search.

---

## Open Problems Encountered

1. **Upper variational bound:** We proved the lower bound `-log Z ≤ η·E[ℓ]` but the matching upper bound `η·E[ℓ] ≤ -log Z + η²/2` requires the Hoeffding-type inequality `exp(-x) ≤ 1 - x + x²/2` for `x ∈ [0,1]`, which is in Mathlib but requires careful application.

2. **Full regret theorem:** The regret bound `O(√T)` requires both the upper and lower variational bounds plus telescoping. The key difficulty is managing the product-of-partition-functions identity across the recursive posterior.

3. **Balanced η corollary:** Setting `η = √(2·log|Spec|/T)` requires `Real.sqrt` properties and careful casting between ℕ and ℝ.

4. **Infinite spectra:** All results assume `[Fintype (SpectralPoint S)]`. Extending to countable or continuous spectra requires measure theory infrastructure.
