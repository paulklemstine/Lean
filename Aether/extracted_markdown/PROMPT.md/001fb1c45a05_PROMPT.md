

=== AEM QUALITY SCORING (MANDATORY GUIDELINES) 



Research Mode: PROVE

Discover and prove new, non-trivial theorems that advance the
mathematical frontier. Start from the existing verified theorems
listed below and extend them into deeper territory. Every theorem
you prove should require genuine mathematical insight — not just
unfolding definitions or numeric verification.

Your Lean 4 files must:
- Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
- Build on existing catalog theorems (referenced below)
- Minimize `sorry` — isolate truly hard steps rather than leaving gaps
- Avoid trivial tautologies (no `True := by trivial`)

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems using diverse tactics (induction, rcases,
  by_contra, omega, linarith). ZERO sorries. Use typeclass abstraction.
- AESTHETIC: Bridge 2+ mathematical domains. Use quantifier alternation
  (∀x, ∃y). Include symmetric structures. Name-drop both domains.
- UTILITY: State explicit computational bounds (Lipschitz constants,
  convergence rates, O(...) complexity). Defin

## YOUR ASSIGNMENT: Tropical Information Geometry: Min-Plus Fisher Information, Tropical Cramér-Rao Certification, and Idempotent Natural Gradient Descent

**DOMAIN**: Bridges (Tropical Geometry ↔ Information Theory ↔ Certified ML ↔ Quantum Foundations)

**CONCEPT**: Open the field of tropical (min-plus) information geometry by establishing a complete certified theory connecting idempotent semiring analysis to statistical geometry, optimization, and post-quantum cryptographic hardness. The core insight: replacing the log-sum-exp Fisher information with its min-plus shadow yields an ultrametric information geometry where Cramér-Rao bounds become tropical eigenvalue bounds, natural gradient descent becomes a min-plus tropical flow with certified O(1/κ_∞) convergence, and min-entropy estimation error has a computable lower bound expressible as a tropical determinant — a quantity directly connected to shortest-path matrix computations relevant to lattice-based post-quantum cryptography.

---

### PHASE 1: Foundational Structures (5+ New Definitions)

Define the following structures with precise Lean 4 type signatures:

```lean4
/-- The min-plus (tropical) Fisher information matrix for a parametric family
    p : Θ → FinProbDist over a finite alphabet. Entry (i,j) is the tropical
    (min-plus) correlation of the score functions:
    G_ij(θ) = min_x [∂_i(-log p_θ(x)) + ∂_j(-log p_θ(x))]
    Bridge: connects idempotent analysis to statistical estimation theory. -/
structure TropicalFisherInfo (n : ℕ) (d : ℕ) where
  mat : Matrix (Fin d) (Fin d) ℝ
  score_min_plus : Matrix (Fin d) (Fin n) ℝ
  h_score_consistency : ∀ i j,
    mat i j = Finset.min' (Finset.univ.image (fun k => score_min_plus i k + score_min_plus j k)) sorry -- placeholder, will prove

/-- The tropical Cramér-Rao certified lower bound on min-entropy estimation error.
    For unbiased estimator T of θ_i, the min-entropy of T_i conditioned on θ
    is lower-bounded by the tropical eigenvalue of G^{-1}. -/
def tropicalCramerRaoBound {d : ℕ} (G : TropicalFisherInfo n d) : ℝ :=
  tropicalSpectralRadius G.mat

/-- Ultrametric entropy distance on probability simplex:
    d_∞(p, q) = max_x |(-log p_x) - (-log q_x)|
    Satisfies the strong triangle inequality (ultrametric axiom). -/
def ultrametricEntropyDist {n : ℕ} (p q : FinProbDist (Fin n)) : ℝ :=
  Finset.max' (Finset.univ.image (fun k => |(- Real.log (p k).val) - (- Real.log (q k).val)|)) (Finset.univ_nonempty)

/-- Tropical condition number κ_∞(G) = ratio of tropical spectral radius of G
    to tropical min-eigenvalue. Governs convergence rate of tropical natural gradient.
    Explicit bound: tropical natural gradient converges in O(κ_∞(G) · log(1/ε)) iterations. -/
def tropicalConditionNumber {d : ℕ} (G : Matrix (Fin d) (Fin d) ℝ) : ℝ :=
  tropicalSpectralRadius G / tropicalMinEigenvalue G

/-- Tropical natural gradient step: preconditioned by tropical Fisher info.
    θ_{t+1} = θ_t - η · G^{∘(-1)} ⊗ ∇L(θ_t)
    where ⊗ is tropical (min-plus) matrix multiplication. -/
def tropicalNaturalGradientStep {d : ℕ} (G : TropicalFisherInfo n d)
    (θ : Fin d → ℝ) (η : ℝ) (grad : Fin d → ℝ) : Fin d → ℝ :=
  fun i => max (θ i) (η + tropicalMatVecMul (tropicalMatInv G.mat) grad i)
```

---

### PHASE 2: Core Theorems (10+ Theorems, Diverse Tactics, Zero Sorries)

**Theorem 1: Ultrametric Axiom for Tropical Entropy Distance**

```lean4
/-- Bridge: connects tropical geometry to metric geometry and quantum state
    distinguishability. The tropical entropy distance satisfies the strong
    triangle inequality, making it an ultrametric — unlike classical Fisher-Rao.
    This is the foundational structural theorem enabling certified robustness. -/
theorem ultrametricEntropyDist_strong_triangle
    {n : ℕ} (p q r : FinProbDist (Fin n)) :
    ultrametricEntropyDist p r ≤ max (ultrametricEntropyDist p q) (ultrametricEntropyDist q r) := by
  -- Strategy: unfold definition, use Finset.max'_le_iff, then for each x,
  -- apply triangle inequality for |·| on ℝ, then case-split on which of
  -- |log p_x - log q_x| or |log q_x - log r_x| is larger.
  sorry -- REPLACE: use Finset.max'_le_iff, split cases with rcases, apply abs_sub_le_abs_abs
```

**Proof Strategy for Theorem 1:**
1. Unfold `ultrametricEntropyDist` to `Finset.max'` over `Fin n` of `|(-log p_x) - (-log q_x)|`.
2. Apply `Finset.max'_le_iff`: it suffices to show for each `x`, `|(-log p_x) - (-log r_x)| ≤ max(|(-log p_x) - (-log q_x)|, |(-log q_x) - (-log r_x)|)`.
3. Use `abs_sub_le_abs_abs` (triangle inequality for `|·|`) to get `|(-log p_x) - (-log r_x)| ≤ |(-log p_x) - (-log q_x)| + |(-log q_x) - (-log r_x)|`.
4. For `a, b ≥ 0`, prove `a + b ≤ max(a, b)` is FALSE in ℝ — CORRECTION: ultrametric requires `max`, not `≤ max`. The correct approach: for `a, b : ℝ`, `max a b ≤ max (max a b) (max a b)` trivially. The real content is that the RHS simplifies. Actually, the strong triangle inequality is `d(p,r) ≤ max(d(p,q), d(q,r))`, which is STRONGER than the usual one. This follows from the max-of-absolute-values definition because `|f(x) - h(x)| ≤ max(|f(x) - g(x)|, |g(x) - h(x)|)` pointwise, then take max over x.
5. Key lemma: `abs_sub_le_max_abs_abs : ∀ a b c : ℝ, |a - c| ≤ max |a - b| |b - c|`. Prove by `by_contra h`, `linarith`.

**Theorem 2: Tropical Cramér-Rao Certified Lower Bound**

```lean4
/-- Bridge: connects tropical linear algebra to statistical estimation and
    post-quantum cryptographic hardness. The min-entropy of any unbiased
    estimator's coordinate is lower-bounded by the tropical spectral radius
    of the inverse tropical Fisher matrix. This is a certified bound: it
    provides a guaranteed minimum key-leakage bound in min-entropy
    extractors for lattice-based cryptography. -/
theorem tropicalCramerRao_min_entropy_certified_bound
    {n d : ℕ} {p : (Fin d → ℝ) → FinProbDist (Fin n)}
    {G : TropicalFisherInfo n d}
    {T : (Fin d → ℝ) → (Fin d → ℝ)}
    (h_unbiased : ∀ θ i, 𝔼[T θ i] = θ i)
    (h_fisher : ∀ θ, tropicalFisherInfo_of_family p θ = G) :
    ∀ θ i, minEntropy (T θ i) ≥ tropicalSpectralRadius (tropicalMatInv G.mat) := by
  sorry -- REPLACE: induction on d, tropical matrix inversion properties, min-entropy data processing
```

**Proof Strategy for Theorem 2:**
1. Reduce to 1-dimensional case (d = 1): `G` is 1×1, `tropicalMatInv G = 1/G_{11}`, `tropicalSpectralRadius` = `1/G_{11}`.
2. For general d: apply `minEntropy_le_tropicalFisherInverse`: the min-entropy of `T_i` is bounded by the tropical eigenvalue of `G^{-1}` corresponding to coordinate `i`.
3. Key sub-lemma: `tropicalFisherInfo_score_bound`: for any estimator `T_i`, `minEntropy(T_i) ≥ min_x [score_i(x) - log p(x)]`. Prove by `by_contra`, derive contradiction with unbiasedness.
4. Use `tropicalMatInv_eigenvalue_bound`: tropical eigenvalue of `G^{-1}` ≤ tropical spectral radius of `G^{-1}`.
5. Chain: `minEntropy(T_i) ≥ eigenvalue_i(G^{-1}) ≥ tropicalSpectralRadius(G^{-1})`.

**Theorem 3: Tropical Data Processing Inequality for Min-Entropy**

```lean4
/-- Bridge: connects information theory to tropical geometry and quantum
    channel capacity. Min-entropy cannot increase under stochastic maps
    when measured in the tropical (min-plus) information metric. This
    certifies that tropical information is monotone — a foundational
    property for certified_robustness in ML and min-entropy extractors
    in post-quantum cryptography. -/
theorem tropical_data_processing_inequality
    {n m : ℕ} (p : FinProbDist (Fin n)) (K : Matrix (Fin m) (Fin n) ℝ)
    (h_stochastic : ∀ j, (∑ i, K j i) = 1) (h_nonneg : ∀ i j, K j i ≥ 0)
    (q : FinProbDist (Fin m)) :
    ultrametricEntropyDist (stochasticMap K p) (stochasticMap K q) ≤
      ultrametricEntropyDist p q := by
  sorry -- REPLACE: unfold, use max over finite set, contractivity of log-sum-exp vs min
```

**Proof Strategy for Theorem 3:**
1. Unfold `ultrametricEntropyDist` on both sides to `max_x |log(∑_j K x j · p_j) - log(∑_j K x j · q_j)|`.
2. Key lemma: `log_sum_contractive`: for stochastic `K`, `|log(∑ K x j p_j) - log(∑ K x j q_j)| ≤ max_j |log p_j - log q_j|`. Prove via `log_min_le_log_sum_le_log_max` and case analysis.
3. Use `Finset.max'_mono`: if `f x ≤ g x` for all `x`, then `max' f ≤ max' g`.
4. Combine: pointwise bound + `Finset.max'_mono` gives the result.

**Theorem 4: Tropical Fisher Information Monotonicity**

```lean4
/-- Bridge: connects tropical matrix theory to information monotonicity and
    quantum channel theory. The tropical Fisher information is non-increasing
    under coarse-graining (stochastic maps), analogous to classical Fisher
    information monotonicity but in the min-plus semiring. -/
theorem tropicalFisherInfo_monotone_under_coarse_graining
    {n m d : ℕ} (p : (Fin d → ℝ) → FinProbDist (Fin n))
    (K : Matrix (Fin m) (Fin n) ℝ)
    (h_stochastic : ∀ j, (∑ i, K j i) = 1) :
    ∀ θ, tropicalFisherInfo (stochasticMapFamily K p) θ ≤ₜ tropicalFisherInfo p θ := by
  sorry -- REPLACE: unfold, use min over product sets, tropical matrix inequality
```

**Theorem 5: Uniqueness of Tropical Geodesic Projections**

```lean4
/-- Bridge: connects tropical convex geometry to optimization and certified
    robustness. Projections onto min-plus convex sets in the tropical entropy
    ultrametric are unique — unlike in Hilbert spaces where uniqueness requires
    strict convexity. This uniqueness is the geometric foundation for
    certified_robustness guarantees in tropical ML. -/
theorem tropical_geodesic_projection_unique
    {n : ℕ} (p : FinProbDist (Fin n))
    (C : Set (FinProbDist (Fin n)))
    (h_convex : IsTropicalConvex C)
    (h_closed : IsClosed C) :
    ∃! q ∈ C, ∀ r ∈ C, ultrametricEntropyDist p q ≤ ultrametricEntropyDist p r := by
  sorry -- REPLACE: use ultrametric property, uniqueness from strong triangle inequality
```

**Proof Strategy for Theorem 5:**
1. Existence: `C` is closed in a compact space, so infimum is attained.
2. Uniqueness: Suppose `q₁, q₂ ∈ C` both minimize `d_∞(p, ·)`. By strong triangle inequality: `d_∞(q₁, q₂) ≤ max(d_∞(p, q₁), d_∞(p, q₂)) = d_∞(p, q₁)`.
3. If `d_∞(q₁, q₂) < d_∞(p, q₁)`: contradiction with minimality (midpoint in tropical convex hull is closer).
4. If `d_∞(q₁, q₂) = d_∞(p, q₁)`: use tropical convexity to show `q₁ = q₂`. Key: in ultrametric spaces, all points in a ball are equidistant from the center.

**Theorem 6: Tropical Natural Gradient Convergence Rate**

```lean4
/-- Bridge: connects tropical optimization to certified ML convergence and
    quantum variational algorithms. Tropical natural gradient descent on
    min-entropy objectives converges in O(κ_∞(G) · log(1/ε)) iterations,
    where κ_∞ is the tropical condition number. This is faster than
    Euclidean gradient descent when κ_∞(G) < κ₂(G) (classical condition number),
    which holds for tropical-compatible objectives. -/
theorem tropicalNaturalGradient_convergence_rate
    {n d : ℕ} {p : (Fin d → ℝ) → FinProbDist (Fin n)}
    {G : TropicalFisherInfo n d}
    {L : (Fin d → ℝ) → ℝ}
    (h_smooth : ∀ θ, TropicalLipschitz G.mat L)
    (h_convex : TropicalConvex L)
    (h_strong_convex : TropicalStrongConvex G.mat L)
    {ε : ℝ} (hε : ε > 0) :
    ∃ K : ℕ, K ≤ ⌈tropicalConditionNumber G.mat * Real.log (1 / ε)⌉₊ ∧
      ∀ θ₀, ‖tropicalNaturalGradientIterate G L θ₀ K - argmin L‖ ≤ ε := by
  sorry -- REPLACE: tropical gradient descent analysis, condition number bound, induction on iterations
```

**Theorem 7: Tropical Pythagorean Theorem for Information Projections**

```lean4
/-- Bridge: connects tropical geometry to information geometry and thermodynamic
    free energy. In the tropical entropy ultrametric, projections satisfy a
    tropical Pythagorean theorem: d_∞(p, q)² = d_∞(p, π_C(p))² + d_∞(π_C(p), q)²
    where the "squares" are tropical (i.e., max), giving:
    d_∞(p, q) = max(d_∞(p, π_C(p)), d_∞(π_C(p), q)).
    This is the idempotent analog of the classical Pythagorean theorem in
    information geometry, connecting to thermodynamic free energy minimization. -/
theorem tropical_pythagorean_projection
    {n : ℕ} (p : FinProbDist (Fin n))
    (C : Set (FinProbDist (Fin n)))
    (h_convex : IsTropicalConvex C)
    (q : FinProbDist (Fin n)) (hq : q ∈ C) :
    ultrametricEntropyDist p q =
      max (ultrametricEntropyDist p (tropicalProject C p))
          (ultrametricEntropyDist (tropicalProject C p) q) := by
  sorry -- REPLACE: ultrametric Pythagorean identity, use strong triangle inequality with equality
```

**Theorem 8: Tropical Fisher Information Bounds Post-Quantum Key Leakage**

```lean4
/-- Bridge: connects tropical information theory to post-quantum cryptography.
    The tropical Fisher information provides a certified upper bound on
    post-quantum key leakage in lattice-based key exchange: if the tropical
    Fisher information of the public key distribution is G, then the min-entropy
    of the shared secret conditioned on the public key is at least
    tropicalSpectralRadius(G^{-1}). This directly advances SPHINCS+ and
    Kyber security analysis. -/
theorem tropicalFisherInfo_bounds_post_quantum_key_leakage
    {n d : ℕ} (pk_dist : (Fin d → ℝ) → FinProbDist (Fin n))
    (G : TropicalFisherInfo n d)
    (secret : Fin d → ℝ)
    (h_key_exchange : IsValidLatticeKeyExchange pk_dist secret) :
    minEntropy (latticeSharedSecret pk_dist secret) ≥
      tropicalSpectralRadius (tropicalMatInv G.mat) - 1 := by
  sorry -- REPLACE: apply tropical Cramér-Rao, bound conditional min-entropy, lattice noise smoothing
```

**Theorem 9: Tropical Mutual Information Satisfies Data Processing Inequality**

```lean4
/-- Bridge: connects tropical information theory to quantum channel capacity
    and certified robustness. Tropical mutual information I_∞(X;Y) =
    min_entropy(X) - min_entropy(X|Y) satisfies DPI under tropical
    information metric. This certifies that tropical information cannot
    be created — foundational for certified_robustness in adversarial ML. -/
theorem tropicalMutualInfo_data_processing_inequality
    {n m d : ℕ} (X : FinProbDist (Fin n)) (Y : FinProbDist (Fin m))
    (K : Matrix (Fin d) (Fin m) ℝ)
    (h_stochastic : ∀ i, (∑ j, K i j) = 1) :
    tropicalMutualInfo X (stochasticMap K Y) ≤ tropicalMutualInfo X Y := by
  sorry -- REPLACE: unfold tropical mutual info, apply min-entropy DPI, use monotonicity
```

**Theorem 10: Certified Robustness via Tropical Fisher Information**

```lean4
/-- Bridge: connects tropical information geometry to certified adversarial
    robustness in neural networks. A classifier f is (ε, δ)-certified robust
    at x in the tropical entropy metric if the tropical Fisher information
    of the softmax output distribution satisfies:
    tropicalSpectralRadius(G_f(x)) ≥ ε/δ.
    This gives a computationally efficient certified_robustness certificate
    that avoids expensive Lipschitz computation. -/
theorem tropicalFisherInfo_certified_robustness
    {n d : ℕ} (f : ℝ^d → FinProbDist (Fin n)) (x : ℝ^d)
    (G : TropicalFisherInfo n d)
    (h_fisher : ∀ y, tropicalFisherInfo_of_family f y = G)
    {ε δ : ℝ} (hε : ε > 0) (hδ : δ > 0)
    (h_cert : tropicalSpectralRadius G.mat ≥ ε / δ) :
    ∀ y, ‖y - x‖ ≤ δ →
      argmax (f y) = argmax (f x) ∨
      ultrametricEntropyDist (f x) (f y) > ε := by
  sorry -- REPLACE: unfold certified robustness, apply tropical Cramér-Rao, ultrametric triangle
```

**Theorem 11: Tropical Eigenvalue Bound via Shortest Paths**

```lean4
/-- Bridge: connects tropical matrix theory to graph algorithms and lattice
    cryptography. The tropical spectral radius of a matrix equals the maximum
    cycle mean, computable in O(n³) via the Floyd-Warshall algorithm. This
    makes tropical Cramér-Rao bounds computationally efficient — unlike
    classical Fisher information matrix inversion which is O(n³) but numerically
    unstable. Tropical eigenvalue computation is exact for rational matrices. -/
theorem tropicalSpectralRadius_eq_max_cycle_mean
    {n : ℕ} (M : Matrix (Fin n) (Fin n) ℝ) :
    tropicalSpectralRadius M = maxCycleMean (weightedDigraph M) := by
  sorry -- REPLACE: use max-plus algebra theory, cycle mean characterization, Floyd-Warshall
```

**Theorem 12: Tropical Condition Number vs Classical Condition Number**

```lean4
/-- Bridge: connects tropical linear algebra to numerical analysis and
    certified ML. The tropical condition number κ_∞ is always at most the
    classical condition number κ₂, with equality iff the Fisher information
    matrix is monomial (exactly one nonzero per row/column). This explains
    when tropical natural gradient is strictly faster than classical natural
    gradient — precisely when the problem has tropical (sparse) structure. -/
theorem tropicalConditionNumber_le_classicalConditionNumber
    {n : ℕ} (G : Matrix (Fin n) (Fin n) ℝ)
    (h_pos : ∀ i j, G i j > 0) :
    tropicalConditionNumber G ≤ classicalConditionNumber G ∧
    (tropicalConditionNumber G = classicalConditionNumber G ↔
      ∃ (σ : Equiv.Perm (Fin n)), ∀ i, G i (σ i) > 0 ∧ ∀ j ≠ σ i, G i j = 0) := by
  sorry -- REPLACE: use tropical spectral radius bound, classical spectral norm, monomial characterization
```

---

### PHASE 3: Proof Architecture — Key Lemma Chain

The theorems above form a dependency chain. Prove in this order:

1. **`abs_sub_le_max_abs_abs`**: `∀ a b c : ℝ, |a - c| ≤ max |a - b| |b - c|` (by `linarith` after case analysis)
2. **`ultrametricEntropyDist_strong_triangle`**: Uses lemma 1 + `Finset.max'_le_iff`
3. **`log_sum_contractive`**: Stochastic maps contract log-entropy distances
4. **`tropical_data_processing_inequality`**: Uses lemma 3 + `Finset.max'_mono`
5. **`tropical_geodesic_projection_unique`**: Uses lemma 2 (strong triangle ineq) + tropical convexity
6. **`tropical_pythagorean_projection`**: Uses lemma 5 + ultrametric Pythagorean identity
7. **`tropicalFisherInfo_monotone_under_coarse_graining`**: Uses lemma 4 + min-plus algebra
8. **`tropicalSpectralRadius_eq_max_cycle_mean`**: Tropical eigenvalue theory (Floyd-Warshall)
9. **`tropicalCramerRao_min_entropy_certified_bound`**: Uses lemmas 6, 7, 8
10. **`tropicalFisherInfo_bounds_post_quantum_key_leakage`**: Uses lemma 9 + lattice noise
11. **`tropicalMutualInfo_data_processing_inequality`**: Uses lemma 4 + min-entropy properties
12. **`tropicalFisherInfo_certified_robustness`**: Uses lemma 9 + ultrametric bound
13. **`tropicalNaturalGradient_convergence_rate`**: Uses lemma 8 + tropical gradient analysis
14. **`tropicalConditionNumber_le_classicalConditionNumber`**: Uses lemma 8 + spectral theory

---

### PHASE 4: Cross-Domain Impact

**Tropical Geometry ↔ Information Theory**: The ultrametric entropy distance is a tropical shadow of the Fisher-Rao metric. The tropical Pythagorean theorem (Theorem 7) is the idempotent limit of the classical information-geometric Pythagorean theorem.

**Tropical Geometry ↔ Post-Quantum Cryptography**: The tropical Cramér-Rao bound (Theorem 2) directly bounds key leakage in lattice-based key exchange (Theorem 8). Tropical eigenvalue computation is exact for rational matrices (Theorem 11), unlike classical Fisher inversion — making tropical certificates efficiently computable.

**Tropical Geometry ↔ Certified ML Robustness**: The tropical Fisher information provides a certified robustness criterion (Theorem 10) that avoids expensive Lipschitz computation. The tropical condition number (Theorem 12) characterizes when tropical natural gradient is faster than classical — precisely for sparse/tropical-structured networks.

**Tropical Geometry ↔ Quantum Foundations**: The tropical data processing inequality (Theorem 3) is the idempotent limit of the quantum data processing inequality. Tropical information geometry is the "classical shadow" of quantum information geometry over non-Archimedean fields.

---

### FUTURE_DIRECTIONS

Produce a structured `FUTURE_DIRECTIONS.md` with 3-5 concrete, specific, breakthrough-level next steps:

1. **Tropical Satake Transform and Langlands Duality**: Define the tropical Satake transform as a min-plus integral over the tropical Hecke algebra and prove it establishes a bijection between tropical Hecke operators for GL₂(ℚₚ) and W-invariant tropical polynomials. This opens tropical Langlands duality.

2. **Quantum Tropical Information Geometry**: Extend tropical Fisher information to density matrices by defining `QuantumTropicalFisherInfo : Matrix (Fin d) (Fin d) ℂ → TropicalFisherInfo` and proving a quantum tropical data processing inequality under CPTP maps. Connects to quantum error correction via tropical min-entropy bounds.

3. **Tropical PAC Learning Bounds**: Prove that the tropical VC dimension of a hypothesis class equals the tropical rank of the associated matrix, and derive PAC learning bounds with sample complexity O(κ_∞(G) · log(1/δ)) for tropical-conditioned distributions. This gives certified learning guarantees for adversarially robust ML.

4. **Post-Quantum Security from Tropical Lattices**: Prove that the tropical shortest-vector problem (tropical SVP) is NP-hard under quantum reductions, establishing a foundation for post-quantum cryptography based on tropical lattice problems rather than classical LWE.

5. **Tropical Neural Tangent Kernel**: Define the tropical neural tangent kernel for ReLU networks as a min-plus limit of the classical NTK and prove it characterizes the training dynamics of tropical natural gradient descent with convergence rate O(κ_∞(G) · log(1/ε)).

**AEM QUALITY MANDATE**: Your output will be scored on 5 pillars. Optimize ALL:
- RIGOR: 10+ theorems, diverse tactics (induction, rcases, by_contra, omega, linarith), ZERO sorries
- AESTHETIC: Bridge 2+ domains in theorem names and doc comments. Use quantifier alternation.
- UTILITY: Define 5+ structures/instances. State SPECIFIC computational bounds (O(n log n), Omega(2^n)) — generic terms like 'bound' or 'rate' alone do NOT score utility.
- ORIGINALITY: Coin novel definitions beyond Mathlib. Inventive theorem names. Write 'Bridge: connects X to Y' in doc comments for cross-domain connections. Generic names (main, test, aux) do NOT count.
- IMPACT: Use SPECIFIC application terms (lipschitz_certified_robustness, post_quantum_security, tropical_hash_collision) — generic terms like 'convergence' or 'spectrum' without ML/crypto/physics context do NOT score impact.

**FILE RICHNESS MANDATE**: Produce substantial, rich files (not stubs).
- Target 500+ lines with 20+ theorems and 10+ definitions per file.
- Historical Masters in the catalog average 2000+ lines, 180+ theorems, 70+ definitions.
- Each file should be a complete mathematical narrative with definitions, lemmas, and main theorems all connected.
- When producing catalog-wide output: create files across MULTIPLE domains (Bridges, Algebra, Cryptography, Tropical, EML, Physics), not just one domain.

            Research Mode: PROVE

Discover and prove new, non-trivial theorems that advance the
mathematical frontier. Start from the existing verified theorems
listed below and extend them into deeper territory. Every theorem
you prove should require genuine mathematical insight — not just
unfolding definitions or numeric verification.

Your Lean 4 files must:
- Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
- Build on existing catalog theorems (referenced below)
- Minimize `sorry` — isolate truly hard steps rather than leaving gaps
- Avoid trivial tautologies (no `True := by trivial`)

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems using diverse tactics (induction, rcases,
  by_contra, omega, linarith). ZERO sorries. Use typeclass abstraction.
- AESTHETIC: Bridge 2+ mathematical domains. Use quantifier alternation
  (∀x, ∃y). Include symmetric structures. Name-drop both domains.
- UTILITY: State explicit computational bounds (Lipschitz constants,
  convergence rates, O(...) complexity). Define 5+ new structures/instances.
- ORIGINALITY: Coin novel definitions with inventive names. Avoid
  derivative names like *_comm, *_nonneg. Combine unusual typeclasses.
- IMPACT: Reference physics (quantum, thermodynamic), cryptography
  (lattice, post-quantum), or ML (certified robustness, neural) in
  theorem names and doc comments. Use keywords: certified_robustness,
  Lipschitz_bound, lattice_crypto, hamiltonian, entropy, etc.


            === VISIONARY DIRECTIVES ===

            Think beyond current mathematical fashion. You are not just proving theorems —
            you are building a mathematical civilization. Every result should:

            1. OPEN DOORS: A good theorem doesn't just close a question — it opens three
               new ones. What does your result make possible that wasn't possible before?
            2. CONNECT WORLDS: The deepest results connect fields that seemed unrelated.
               If you prove something about tropical geometry, ask: what does this mean
               for quantum computing? For cryptography? For neural networks?
            3. PRODUCE ALGORITHMS: Don't just prove existence — construct. Don't just
               construct — compute. Don't just compute — optimize. Every theorem should
               have an algorithmic shadow.
            4. BE BOLD: An interesting false conjecture is more valuable than a boring
               true theorem. If you suspect something is true but can't prove it, state
               it as a conjecture with precise Lean 4 type signature and explain why it matters.
            5. BUILD INFRASTRUCTURE: Definitions are as valuable as theorems. A good
               mathematical definition (like "tropical semiring" or "EML closure") can
               organize an entire field. Define things precisely, then prove things about them.

            The mathematics comes FIRST. Excellent proofs trump everything else.
            But excellent proofs that OPEN NEW FIELDS trump everything.

            === AEM QUALITY SCORING (MANDATORY GUIDELINES) ===
            Your output will be scored on 5 pillars. MAXIMIZE each one:

            PILLAR 1 — RIGOR (Is it World-class?):
            • ZERO sorries in your output (sorries cost -1.5 points each)
            • Use diverse proof tactics (induction, rcases, by_contra, omega, linarith,
              field_simp, refine, obtain — not just simp/rfl/decide)
            • Use typeclass abstraction ([Semiring B], [LinearOrder B], etc.) not
              concrete types alone
            • Later theorems should reference earlier ones (semantic coherence)
            • 10+ theorems = full rigor score; 3-10 = partial; 0-2 = minimal

            PILLAR 2 — AESTHETIC (Is it Interesting?):
            • Bridge 2+ mathematical domains in EVERY file (e.g., tropical + neural
              networks; algebra + thermodynamics; number theory + quantum)
            • Use quantifier alternation (∀ → ∃) for non-trivial theorem statements
            • Include symmetric structures (lattices, posets, groups, duality)
            • Minimize hypotheses for maximal conclusions (small axiomatic footprint)
            • Narrative surprise: state in doc comments WHY the result is unexpected

            PILLAR 3 — UTILITY (Is it Useful?):
            • State explicit computational bounds (O(...), convergence rates, Lipschitz
              constants, error bounds, complexity classifications)
            • Define extensible APIs: 5+ definitions, structures, and instances
            • Reference or advance known open problems (Carmichael, tropical Langlands,
              certified robustness, Berggren factoring, lattice crypto)
            • Organize code with namespaces and sections (framework structure)

            PILLAR 4 — ORIGINALITY (Is it New?):
            • Coin NOVEL definitions — not just restating Mathlib theorems with new names
            • Avoid derivative theorem names (*_eq_zero, *_nonneg, *_symm, *_comm,
              *_add_*, *_mul_*). Use INVENTIVE names that reveal new concepts
            • Combine unusual typeclasses ([Semiring, LinearOrder], [NormedAddCommGroup,
              Field], [MeasureSpace, Category]) — this signals divergent reasoning
            • Each file should introduce 5+ genuinely new mathematical objects (def, structure, class, instance). High-Originality files average 10+ new definitions.

            PILLAR 5 — IMPACT (Does it have Wonderful Applications?):
            • EVERY theorem should connect to at least one of: physics (quantum,
              thermodynamic, entropy), cryptography (lattice, post-quantum, SPB),
              or ML (certified robustness, Lipschitz bounds, neural networks)
            • Name-drop application keywords explicitly in theorem/doc-comment text:
              certified_robustness, Lipschitz, neural_network, gradient_descent,
              convergence, post_quantum, lattice_crypto, hamiltonian, entropy,
              holographic, berggren
            • Produce algorithms or computational pipelines, not just existence proofs

            ### Research Direction
            Open the field of tropical (min-plus) information geometry by proving three foundational results that bridge tropical semiring theory to statistical geometry and optimization: (1) Tropical Cramér-Rao Bound — define the min-plus Fisher information G_ij(θ) = min_x [∂_i(-log p_θ(x)) + ∂_j(-log p_θ(x))] for parametric families on finite sets and prove it provides a certified lower bound on min-entropy estimation error: for any unbiased estimator T of θ, min_k H_∞(T_k | θ) ≥ (G^♭)_{ii} where G^♭ is the tropical matrix inverse; (2) Tropical Statistical Metric Theorem — prove that the tropical Fisher information induces a metric d_∞(p,q) = max_x |(-log p_x) - (-log q_x)| on the probability simplex satisfying the strong triangle inequality d_∞(p,r) ≤ max(d_∞(p,q), d_∞(q,r)), and establish uniqueness of tropical geodesic projections onto min-plus convex subsets of the simplex; (3) Certified Tropical Natural Gradient Convergence — derive a natural gradient descent algorithm preconditioned by the tropical Fisher information matrix and certify that it achieves faster convergence than Euclidean gradient descent for min-entropy optimization objectives, with an explicit convergence rate bound in terms of the tropical condition number of G.

            ### Precise Mathematical Framing
            Classical information geometry equips the statistical manifold with the Fisher-Rao Riemannian metric. Under the tropical (min-plus) semiring where addition is min and multiplication is +, the Fisher information G_ij(θ) = min_x[∂_i(-log p_θ(x)) + ∂_j(-log p_θ(x))] becomes a min-plus matrix with entries in ℝ∪{∞}. The tropical inner product ⟨u,v⟩_G = min_{ij}(u_i + G_{ij} + v_j) satisfies idempotent positive-semidefiniteness: ⟨u,u⟩_G ≥ min_i u_i. The induced metric d_∞ on distributions satisfies the ultrametric-like strong triangle inequality, making the tropical statistical manifold a non-Archimedean geometric object rather than a Riemannian one — a structural insight that has no classical analog. Tropical geodesics take the form γ(t) = SoftMin(t + (-log p), (1-t) + (-log q)) where SoftMin is the log-sum-exp smoothing of the min operation. The tropical Cramér-Rao bound min_k H_∞(T_k|θ) ≥ (G^♭)_{ii} provides certified estimation lower bounds in the min-entropy framework, directly applicable to differential privacy analysis where min-entropy measures adversarial advantage.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `depth_convergence_rate_bound` : theorem depth_convergence_rate_bound
     (file: Bridges/HomologicalDeepLearning.lean)
  2. `tropical_plus_distributes_over_min` : theorem tropical_plus_distributes_over_min (a b c : ℝ) :
     (file: Bridges/MinPlusVerificationCore.lean)
  3. `max_entropy_is_log_n` : theorem max_entropy_is_log_n (n : ℕ) [hn : NeZero n] :
     (file: Bridges/QuantumTropicalUnification.lean)
  4. `tropical_min_max_absorption` : theorem tropical_min_max_absorption (a b : ℝ) :
     (file: Bridges/TropicalSatake.lean)
  5. `logsumexp_le_max_plus_log2` : theorem logsumexp_le_max_plus_log2 (x y : ℝ) :
     (file: Bridges/UnifiedFramework.lean)

            Known Working Lean 4 Tactics:
- `nlinarith [sq_nonneg X]` for quadratic inequalities
- `positivity` for positivity goals
- `field_simp` then `ring` for division
- `Real.exp_le_exp.mpr` for exp monotonicity
- `Real.log_le_log` for log inequalities
- `div_pos`, `div_le_div_of_nonneg_left` for division inequalities
- `pow_le_pow_right₀` for power monotonicity
- `by decide` / `by norm_num` / `native_decide` for decidable propositions
- `Subadditive.tendsto_lim` for Fekete's Lemma
- `ConvexOn.map_sum_le` for Jensen's inequality
- `exists_deriv_eq_slope` for MVT



Recent successful concepts: tropical_cryptography_breakthrough_bridge, Non-Archimedean Information Theory: Min-Plus Entropy Axiomatization, Ultrametric Channel Capacity, and Idempotent Source Coding, Diophantine Quantum Walks: Berggren-Lorentz Unitarity, Triple-Spectrum Factorization Bounds, and Certified Quantum Diophantine Search


            ### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.

            ### Required Deliverables

            You are a world-class mathematician, software engineer, and science writer.
            Create ALL of the following:

            1. **Lean 4 files** — formally verified theorems with complete proofs
               - Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
               - Build on the existing catalog theorems listed above
               - Minimize `sorry` — isolate hard steps rather than leaving gaps
               - Use doc comments to explain the significance of key results

            2. **ARTICLE.md** — MANDATORY standalone popular-science article
               CRITICAL RULES:
               • Do NOT mention "Scientific American", "Sci Am", or "ean" anywhere.
               • Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
               • This is a premier magazine-quality piece for curious, intelligent readers.
               QUALITY STANDARDS:
               • Superb, vivid, engaging prose with a strong opening hook and narrative arc.
               • Concrete analogies and metaphors that make abstract ideas tangible.
               • Story structure: provocative question → tension → breakthrough → significance.
               • Real-world connections: technology, nature, everyday life.
               • Historical context: place the work in the sweep of intellectual history.
               • 1500–3000 words. Substantial, standalone, enjoyable, interesting.
               • A reader should say "Wow, I had no idea math could do THAT."

            3. **RESEARCH_PAPER.md** — MANDATORY comprehensive, in-depth research paper
               This is a full, publishable-quality paper, NOT a summary:
               • Abstract, Introduction, Definitions & Notation
               • Main Results with detailed proof sketches (not just "by induction")
               • Algorithms with complete pseudocode and complexity analysis
               • Applications with worked examples showing practical use
               • Computational Experiments with tables, charts, numerical results
               • Discussion, Future Work, References
               • 3000–8000 words. Thorough and substantive.

            4. **FUTURE_DIRECTIONS.md** — MANDATORY breakthrough research roadmap
               This is the MOST IMPORTANT deliverable because it drives the next
               research cycle. Structure it as:

               ## Breakthrough Opportunities (ranked by impact)
               For each opportunity:
               - **Theorem Statement**: Precise, formalizable statement with quantifiers
               - **Proof Strategy**: 2-3 concrete approaches with key lemmas identified
               - **Why This Is Revolutionary**: What field it opens, what applications it enables
               - **Catalog Leverage**: Which existing catalog theorems to build on (by name)
               - **Research Mode**: prove | formalize | discover | counterexample
               - **Estimated Depth**: 1-5 scale

               ## Under-explored Territory
               ## Cross-Domain Bridges
               ## Open Problems Encountered

            5. **Python code** — demos, visualizations, algorithms, applications:
               - **demo.py** — concrete numerical examples bringing the math to life
               - **visualizations** — matplotlib/plotly charts (save as PNG/SVG too)
               - **algorithms.py** — implement algorithms from the paper with docstrings
               - **applications.py** — real-world applications (ML, crypto, physics)

            6. **diagram.svg** — visualization of key mathematical structures

            7. **PACKAGE.html** — MANDATORY standalone HTML package
               Bundle ALL artifacts into a single, self-contained HTML file:
               • Everything inlined (CSS, JS, content). No external dependencies.
               • Tab/sidebar navigation: Article, Research Paper, Demos, Algorithms,
                 Visualizations, Code Listings
               • Modern design: clean typography, dark/light toggle, responsive layout
               • KaTeX for math rendering (CDN OK), syntax-highlighted code blocks
               • Collapsible sections, smooth scroll, table of contents
               • Must work when opened directly in any browser

            Produce novel, non-trivial theorems with complete Lean 4 proofs. Think big — aim for results that would appear in JAMS, Annals, or FOCS.

            ### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### WHAT WE NEED FROM YOU

You are a world-class mathematician, software engineer, and science writer.
Use your judgment on the best way to organize and present your work.
We need ALL of the following deliverables:

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 1 — Formally verified mathematics (Lean 4)
────────────────────────────────────────────────────────────────────────────
- Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
- Organize the code however makes sense — one file or several,
  whatever serves the mathematics best
- Use doc comments to explain the significance of key results

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 2 — Standalone Popular-Science ARTICLE  →  ARTICLE.md
────────────────────────────────────────────────────────────────────────────
Write a **superb, standalone magazine-quality article** about this research.

CRITICAL RULES FOR THE ARTICLE:
• Do NOT mention "Scientific American", "Sci Am", or "ean" anywhere.
• Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
• This is a POPULAR SCIENCE article for a curious, intelligent audience.
  Write it as if it will be published in a premier science magazine.
• The reader should come away saying "Wow, I had no idea math could do THAT."

ARTICLE QUALITY STANDARDS:
• **Superb writing**: Vivid, engaging prose. Strong opening hook. Narrative arc.
  Use concrete analogies and metaphors that make abstract ideas tangible.
• **Depth without jargon**: Explain the IDEAS, not the formalism.
  A reader with a college education should understand and enjoy every paragraph.
• **Story structure**: Open with a provocative question or surprising fact.
  Build tension. Reveal the breakthrough. Show why it matters.
• **Real-world connections**: Connect to technology, nature, everyday life.
  Why should a non-mathematician care about this?
• **Historical context**: Place the discovery in the sweep of intellectual history.
  Who tried this before? What barriers stood in the way?
• **Length**: 1500–3000 words. Substantial but not padded.
• **Standalone**: The article must make complete sense on its own.
  No references to "the proof above" or "our formal verification."

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 3 — Comprehensive RESEARCH PAPER  →  RESEARCH_PAPER.md
────────────────────────────────────────────────────────────────────────────
Write a **thorough, in-depth research paper** that a mathematician or
graduate student would find valuable. This is NOT a summary — it is a
complete, publishable-quality paper.

RESEARCH PAPER REQUIREMENTS:
• **Abstract**: Concise summary of contributions and significance.
• **Introduction**: Motivation, context, relationship to prior work.
• **Definitions & Notation**: Precise mathematical setup.
• **Main Results**: Full theorem statements with detailed proof sketches.
  Include the key ideas, not just "by induction."
• **Algorithms**: If the work produces algorithms, include complete
  pseudocode with complexity analysis (time, space, convergence).
• **Applications**: Concrete applications with worked examples.
  Show HOW to use the results in practice.
• **Computational Experiments**: Reference the Python demos.
  Include tables, charts, or numerical results.
• **Discussion**: Implications, limitations, open questions.
• **Future Work**: Specific, actionable next steps.
• **References**: Cite relevant prior work properly.
• **Length**: 3000–8000 words. Comprehensive and substantive.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 4 — Python Code: Demos, Visualizations, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **visualizations** — matplotlib / plotly charts showing key mathematical
  structures, convergence behavior, phase diagrams, etc.
  Save figures as PNG/SVG files for inclusion in the HTML package.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  If the math applies to ML, crypto, physics — show it working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Structured roadmap of breakthrough
research opportunities opened by this work. See detailed spec below.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 6 — Standalone HTML Package  →  PACKAGE.html
────────────────────────────────────────────────────────────────────────────
Create a **single, self-contained HTML file** that bundles ALL artifacts
into a beautiful, interactive presentation. Requirements:

• **Single file**: Everything (CSS, JS, content) inlined. No external deps.
• **Navigation**: Sidebar or tab navigation between sections:
  - Article (the popular-science piece)
  - Research Paper (the full paper)
  - Interactive Demos (embedded Python output / JS visualizations)
  - Algorithms (pseudocode + implementation)
  - Visualizations (embedded charts/diagrams as inline SVG or base64)
  - Code Listings (syntax-highlighted Python and proof code)
• **Beautiful design**: Modern, clean typography (system fonts).
  Dark/light mode toggle. Responsive layout. Smooth transitions.
• **Math rendering**: Use KaTeX (CDN link OK for math rendering only)
  for any mathematical notation.
• **Syntax highlighting**: Inline code highlighting for Python blocks.
• **Interactive elements**: Collapsible sections, smooth scroll, TOC.
• The HTML package should work when opened directly in any browser.
• Include ALL content from the article, research paper, and code.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Bridges
Research mode: prove
