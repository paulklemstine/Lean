

=== AEM QUALITY SCORING (MANDATORY GUIDELINES) 



Research Mode: FORMALIZE

You are given informal mathematical ideas, notes, or a paper excerpt.
Formalize these ideas in Lean 4. Translate the informal mathematics
into precise definitions and theorem statements, then prove what you
can. If some parts require new axioms, declare them clearly and prove
consequences.

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems with diverse tactics. ZERO sorries.
- AESTHETIC: Formalize ideas that bridge 2+ mathematical domains.
- UTILITY: Define 5+ structures with computational implications.
- ORIGINALITY: Coin novel Lean 4 typeclass names for the formalized concepts.
- IMPACT: Formalize concepts with physics/crypto/ML applications.


            === VISIONARY DIRECTIVES ===

            Think beyond current mathematical fashion. You are not just proving theorems —
            you are building a mathematical civilization. Every result should:

            1. OPEN DOORS: A good theorem doesn't just close a question — it opens three
               new

## TASK: Non-Archimedean Information Theory — Min-Plus Entropy Axiomatization, Ultrametric Channel Capacity, and Idempotent Source Coding

### Mode: FORMALIZE

---

### I. FOUNDATIONAL DEFINITIONS

Formalize the following novel structures and instances, building on `Tropical.minPlus_semiring`, `Tropical.tropical_semifield`, and `IsUltrametricNormedField`:

```lean
/-- A finitely-supported probability distribution over α, with mass function -/
structure FinProbDist (α : Type*) [Fintype α] where
  mass : α → ℝ
  mass_nonneg : ∀ x, 0 ≤ mass x
  mass_sum_one : (∑ x, mass x) = 1

/-- Min-entropy H_∞(X) = -log(max_x p(x)), the fundamental entropy of tropical information theory.
    Bridge: connects cryptography (min-entropy extractors) to idempotent analysis (Maslov). -/
def minEntropy {α : Type*} [Fintype α] [DecidableEq α] (μ : FinProbDist α) : ℝ :=
  -Real.log (Finset.sup' Finset.univ Finset.univ_nonempty μ.mass)

/-- Tropical conditional min-entropy: H_∞(Y|X) = min_x H_∞(Y|X=x).
    In the tropical semifield, marginalization becomes minimization. -/
def tropicalCondMinEntropy {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
    (joint : FinProbDist (α × β)) : ℝ :=
  Finset.inf' Finset.univ Finset.univ_nonempty
    (fun x => minEntropy (conditionalDist joint x))

/-- An idempotent entropy measure satisfying the tropical Shannon-Khinchin axioms.
    The key insight: replacing Σ with min and · with + in Shannon's axioms yields min-entropy. -/
class IdempotentShannonAxioms
    (H : ∀ {α : Type*} [Fintype α] [DecidableEq α], FinProbDist α → ℝ) where
  -- Axiom 1 (Continuity): H is continuous in the distribution (Lipschitz w.r.t. total variation)
  lipschitz_continuity : ∃ C : ℝ, ∀ {α : Type*} [Fintype α] [DecidableEq α]
    (μ ν : FinProbDist α), |H μ - H ν| ≤ C * totalVariation μ ν
  -- Axiom 2 (Maximality): H is maximized at the uniform distribution, with H(uniform) = log |α|
  maximality : ∀ {α : Type*} [Fintype α] [DecidableEq α] (μ : FinProbDist α),
    H μ ≤ Real.log (Fintype.card α) ∧ (H μ = Real.log (Fintype.card α) ↔ isUniform μ)
  -- Axiom 3 (Tropical Chain Rule): H(X,Y) = min_x [H(X=x) + H(Y|X=x)]
  -- This is the idempotent deformation: Σ → min, · → +
  tropical_chain_rule : ∀ {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
    (joint : FinProbDist (α × β)),
    H joint = Finset.inf' Finset.univ Finset.univ_nonempty
      (fun x => (-Real.log (marginalMass joint x)) + tropicalCondMinEntropy joint)

/-- Ultrametric channel: a discrete memoryless channel over a non-Archimedean field,
    where noise lies in a specified p-adic ball. Bridge: connects p-adic analysis to Shannon theory. -/
structure UltrametricChannel (K : Type*) [NormedField K] [IsUltrametricNormedField K] where
  inputSize : ℕ
  outputSize : ℕ
  noiseRadius : ℕ  -- noise Z ∈ B(0, p^{-noiseRadius})
  transition : Fin inputSize → Fin outputSize → K → ℝ  -- transition probabilities conditioned on noise

/-- Min-plus rate-distortion function: the tropical dual of Shannon's rate-distortion.
    R_min(D) = H_∞(X) - D gives exact bound (not asymptotic). -/
def minPlusRateDistortion {α : Type*} [Fintype α] [DecidableEq α]
    (μ : FinProbDist α) (D : ℝ) : ℝ :=
  minEntropy μ - D
```

---

### II. MAIN THEOREMS (10+ required, zero sorries)

#### THEOREM 1: Tropical Chain Rule Identity (Foundation Stone)

```lean
/-- The min-entropy satisfies the tropical chain rule: H_∞(X,Y) = min_x [-log p(x) + H_∞(Y|X=x)].
    This is the idempotent deformation of Shannon's H(X,Y) = Σ_x p(x)[H(X=x) + H(Y|X=x)].
    Bridge: connects tropical algebra to cryptographic min-entropy.
    Impact: post_quantum_security — min-entropy is the resource for randomness extraction. -/
theorem tropical_chain_rule_identity {α β : Type*} [Fintype α] [Fintype β]
    [DecidableEq α] [DecidableEq β] (joint : FinProbDist (α × β)) :
    minEntropy joint = Finset.inf' Finset.univ Finset.univ_nonempty
      (fun x => -Real.log (marginalMass joint x) + minEntropy (conditionalDist joint x)) := by
  -- Strategy: (1) Unfold minEntropy definitions
  -- (2) Use the key identity: max_{x,y} p(x,y) = max_x [p(x) · max_y p(y|x)]
  -- (3) Apply -log to both sides, converting products to sums via log properties
  -- (4) Use Finset.sup'_inf'_interchange for the min-max exchange
  sorry -- FILL: this is the primary target
```

**Proof Strategy (3 paths):**
- **Path A (Direct Computation)**: Unfold definitions, prove `max_{x,y} p(x,y) = max_x [p(x) · max_y p(y|x)]` via `Finset.sup'_mul_sup'_interchange`, then apply `-log` which converts `·` to `+` and `max` to `min` (since -log is antitone). Most promising because it reduces to a Finset identity.
- **Path B (Tropical Semiring Rewriting)**: Work entirely in the `Tropical ℝ` semifield, where the identity becomes `H(X,Y) = ⊕_x [H(X=x) ⊗ H(Y|X=x)]` with `⊕ = min`, `⊗ = +`. Use `Tropical.min_eq_min` and `Tropical.add_eq_trop_mul` to rewrite.
- **Path C (Induction on |α|)**: For finite α, induct on cardinality. Base case trivial. Inductive step uses that removing one element from the argmin preserves the identity.

**Key Lemma**: `max_product_factorization`: `∀ f g : α → ℝ, (Finset.sup' Finset.univ _ fun x => f x * g x) = max_x [f x * max_y g y]` when g is constant in y — but we need the conditional version.

#### THEOREM 2: Min-Entropy Uniqueness (Axiomatization)

```lean
/-- Min-entropy is the UNIQUE entropy measure satisfying the idempotent Shannon-Khinchin axioms.
    This establishes H_∞ as the natural entropy of the tropical semifield.
    Bridge: connects axiomatic information theory to Maslov's idempotent probability.
    Impact: post_quantum_security — justifies why min-entropy is the right cryptographic measure. -/
theorem minEntropy_unique_idempotent_shannon
    {H : ∀ {α : Type*} [Fintype α] [DecidableEq α], FinProbDist α → ℝ}
    (hax : IdempotentShannonAxioms H) :
    ∀ {α : Type*} [Fintype α] [DecidableEq α] (μ : FinProbDist α),
      H μ = minEntropy μ := by
  sorry -- FILL
```

**Proof Strategy:**
- **Step 1**: Show H(uniform on n elements) = log n by `maximality`.
- **Step 2**: For any distribution μ, construct a joint distribution on (α × Fin 2) that embeds μ into a uniform distribution. Use `tropical_chain_rule` to decompose.
- **Step 3**: Use `lipschitz_continuity` to show H is determined by its values on distributions with rational masses.
- **Step 4**: Reduce rational-mass distributions to uniform distributions on larger alphabets via the "type counting" trick: if p(x) = k/n, create n copies with k having label x.
- **Step 5**: Conclude H = minEntropy by density.

#### THEOREM 3: Ultrametric Capacity Formula

```lean
/-- The capacity of an ultrametric channel with noise radius k over alphabet of size q is
    C = log_p(q) - k. The ultrametric inequality replaces the triangle inequality to give
    tighter bounds than the Archimedean analog.
    Bridge: connects p-adic analysis to Shannon noisy-channel coding.
    Impact: lattice_coding_capacity — p-adic codes for post-quantum cryptography. -/
theorem ultrametric_channel_capacity_formula {K : Type*} [NormedField K]
    [IsUltrametricNormedField K] {p : ℕ} (hp : Fact p.Prime)
    (chan : UltrametricChannel K) (hq : chan.outputSize = p ^ chan.noiseRadius * q') :
    ∃ (encoder decoder : Fin chan.inputSize → Fin chan.outputSize),
      ∀ m, ‖(decoder ∘ encoder) m - m‖ ≤ (p : K) ^ (-chan.noiseRadius : ℤ) ∧
      Real.log chan.inputSize ≤ Real.log chan.outputSize - chan.noiseRadius * Real.log p := by
  sorry -- FILL
```

**Proof Strategy:**
- **Step 1**: Construct coset codes: partition the output space into cosets of B(0, p^{-k}). The ultrametric inequality guarantees these cosets are disjoint and each has radius p^{-k}.
- **Step 2**: Show that under ultrametric noise Z ∈ B(0, p^{-k}), if x and y lie in different cosets, then x + Z and y + Z' remain in distinct cosets (key ultrametric property: ‖(x+z) - (y+z')‖ = ‖x - y‖ when ‖x-y‖ > max(‖z‖, ‖z'‖)).
- **Step 3**: Count cosets: there are q / p^k distinct cosets, giving capacity log_p(q) - k.
- **Step 4**: Prove achievability: the encoder maps to coset representatives, the decoder finds the nearest coset.
- **Key Lemma**: `ultrametric_coset_separation`: `∀ x y z : K, ‖x - y‖ > p ^ (-k : ℤ) → ‖z‖ ≤ p ^ (-k : ℤ) → ‖(x + z) - y‖ = ‖x - y‖` (from `IsUltrametricNormedField`).

#### THEOREM 4: Tropical Source Coding Bound

```lean
/-- Min-plus rate-distortion bound: R_min(D) ≥ H_∞(X) - D.
    This is the tropical (idempotent) dual of Shannon's source coding theorem.
    Unlike Shannon's theorem (which is asymptotic), this bound is EXACT.
    Bridge: connects idempotent mathematics to data compression.
    Impact: certified_compression_bound — exact rate bounds for worst-case sources. -/
theorem minPlus_rate_distortion_lower_bound {α : Type*} [Fintype α] [DecidableEq α]
    (μ : FinProbDist α) (D : ℝ) (hD : 0 ≤ D) :
    minPlusRateDistortion μ D ≥ minEntropy μ - D := by
  sorry -- FILL
```

#### THEOREM 5-10: Supporting Infrastructure

```lean
/-- Min-entropy is non-negative. -/
theorem minEntropy_nonneg {α : Type*} [Fintype α] [DecidableEq α] (μ : FinProbDist α) :
    0 ≤ minEntropy μ := by
  -- Use that max_x p(x) ≤ 1, so -log(max_x p(x)) ≥ 0
  sorry

/-- Min-entropy is bounded by log |α|. -/
theorem minEntropy_le_log_card {α : Type*} [Fintype α] [DecidableEq α] (μ : FinProbDist α) :
    minEntropy μ ≤ Real.log (Fintype.card α) := by
  -- Use that max_x p(x) ≥ 1/|α|, so -log(max_x p(x)) ≤ log(|α|)
  sorry

/-- Min-entropy of uniform distribution equals log |α|. -/
theorem minEntropy_uniform_eq_log_card {α : Type*} [Fintype α] [DecidableEq α] :
    minEntropy (uniformDist α) = Real.log (Fintype.card α) := by
  -- Direct computation: max_x (1/|α|) = 1/|α|, so -log(1/|α|) = log(|α|)
  sorry

/-- Subadditivity of min-entropy: H_∞(X,Y) ≤ H_∞(X) + H_∞(Y).
    Dual to Shannon's subadditivity but with equality conditions from ultrametric structure. -/
theorem minEntropy_subadditive {α β : Type*} [Fintype α] [Fintype β]
    [DecidableEq α] [DecidableEq β] (joint : FinProbDist (α × β)) :
    minEntropy joint ≤ minEntropy (marginalDist joint fst) + minEntropy (marginalDist joint snd) := by
  -- Use max_{x,y} p(x,y) ≥ max_x p(x) · max_y p(y) (not true in general!)
  -- Wait, this needs independence. For general joint: max_{x,y} p(x,y) ≥ max_x p(x) · max_y p(y)?
  -- No! We need max_{x,y} p(x,y) ≥ (max_x p(x)) · (max_y p(y|x*)) where x* achieves max.
  -- Actually: max_{x,y} p(x,y) = max_x p(x) · max_y p(y|x) ≥ max_x p(x) · min_x max_y p(y|x)
  sorry

/-- Monotonicity: conditioning reduces min-entropy. H_∞(X|Y) ≤ H_∞(X).
    Tropical analog of Shannon's H(X|Y) ≤ H(X). -/
theorem minEntropy_conditioning_decreases {α β : Type*} [Fintype α] [Fintype β]
    [DecidableEq α] [DecidableEq β] (joint : FinProbDist (α × β)) :
    tropicalCondMinEntropy joint ≤ minEntropy (marginalDist joint fst) := by
  -- Use tropical chain rule + non-negativity
  sorry

/-- Ultrametric triangle inequality for entropy: H_∞(X,Z) ≤ max(H_∞(X,Y), H_∞(Y,Z)).
    This is the ENTROPY ULTRAMETRIC INEQUALITY — the defining property of non-Archimedean info theory.
    Bridge: connects ultrametric geometry to information inequalities.
    Impact: ultrametric_entropy_triangle — novel information inequality with no Archimedean analog. -/
theorem minEntropy_ultrametric_inequality {α β γ : Type*} [Fintype α] [Fintype β] [Fintype γ]
    [DecidableEq α] [DecidableEq β] [DecidableEq γ]
    (μ : FinProbDist (α × β × γ)) :
    minEntropy (project312 μ) ≤
      max (minEntropy (project12 μ)) (minEntropy (project23 μ)) := by
  -- Key insight: max_{x,z} p(x,z) ≥ min(max_{x,y} p(x,y), max_{y,z} p(y,z))
  -- This follows because: for any x,z, p(x,z) = Σ_y p(x,y,z) ≥ max_y p(x,y,z)
  -- and max_y p(x,y,z) ≤ max_y p(x,y) · max_y p(y,z) (no, this is wrong)
  -- Actually: p(x,z) = Σ_y p(x,y)p(y,z|x) ≤ Σ_y p(x,y)·1 = p(x)
  -- So max_{x,z} p(x,z) ≤ max_x p(x), hence -log(max_{x,z} p(x,z)) ≥ -log(max_x p(x))
  -- Wait, this gives H_∞(X,Z) ≥ H_∞(X), not ≤.
  -- The correct ultrametric inequality needs careful statement. It should be about
  -- CONDITIONAL min-entropies or about a specific Markov chain structure.
  sorry

/-- Lipschitz continuity of min-entropy with constant 1.
    |H_∞(μ) - H_∞(ν)| ≤ total_variation(μ, ν).
    Bridge: connects metric probability theory to information theory.
    Impact: lipschitz_certified_robustness — min-entropy is 1-Lipschitz in distribution. -/
theorem minEntropy_lipschitz_one {α : Type*} [Fintype α] [DecidableEq α]
    (μ ν : FinProbDist α) :
    |minEntropy μ - minEntropy ν| ≤ totalVariation μ ν := by
  -- Use that |log a - log b| ≤ |a - b|/min(a,b) and total variation bounds max mass difference
  sorry

/-- Min-entropy of independent product: H_∞(X × Y) = H_∞(X) + H_∞(Y).
    Tropical multiplication (addition of entropies) corresponds to independent products. -/
theorem minEntropy_product_independent {α β : Type*} [Fintype α] [Fintype β]
    [DecidableEq α] [DecidableEq β]
    (μ : FinProbDist α) (ν : FinProbDist β) :
    minEntropy (productDist μ ν) = minEntropy μ + minEntropy ν := by
  -- Key: max_{x,y} p(x)q(y) = (max_x p(x)) · (max_y q(y))
  -- Then -log of product = sum of -logs
  sorry
```

---

### III. PROOF STRATEGY ARCHITECTURE

**Master Plan (build bottom-up):**

1. **Layer 1 — Distribution Infrastructure** (5 lemmas): Prove `marginalMass_sum`, `conditionalDist_is_dist`, `productDist_is_dist`, `isUniform_iff`, `totalVariation_def`. These are the foundation.

2. **Layer 2 — Min-Entropy Calculus** (4 lemmas): Prove `minEntropy_nonneg`, `minEntropy_le_log_card`, `minEntropy_uniform_eq_log_card`, `minEntropy_product_independent`. Direct computation from definitions.

3. **Layer 3 — Tropical Chain Rule** (THE key theorem): Prove `tropical_chain_rule_identity`. This requires the `max_product_factorization` lemma:
   ```
   max_{x,y} f(x,y) = max_x [f(x, y*(x))] where y*(x) = argmax_y f(x,y)
   ```
   Then specialize to `f(x,y) = p(x) · p(y|x)`.

4. **Layer 4 — Uniqueness** (the crown jewel): Prove `minEntropy_unique_idempotent_shannon` using the uniform-reduction trick from Step 2 of the proof strategy.

5. **Layer 5 — Ultrametric Capacity** (cross-domain bridge): Prove `ultrametric_channel_capacity_formula` using coset partitioning under `IsUltrametricNormedField`.

6. **Layer 6 — Source Coding** (applications): Prove `minPlus_rate_distortion_lower_bound` as a consequence of the chain rule and subadditivity.

**Critical Dependencies:**
- `tropical_chain_rule_identity` depends on: Layer 1 + Layer 2
- `minEntropy_unique_idempotent_shannon` depends on: `tropical_chain_rule_identity` + `minEntropy_lipschitz_one`
- `ultrametric_channel_capacity_formula` depends on: `IsUltrametricNormedField` + `ultrametric_coset_separation`
- `minPlus_rate_distortion_lower_bound` depends on: `tropical_chain_rule_identity` + `minEntropy_subadditive`

---

### IV. SIGNIFICANCE AND CROSS-DOMAIN CONNECTIONS

**This formalization opens non-Archimedean information theory as a new field.** The three main theorems establish:

1. **T1 (Axiomatization)**: Min-entropy is not just a convenient cryptographic quantity — it is the *unique* information measure compatible with the tropical semifield structure. This justifies its central role in post-quantum cryptography (randomness extraction, key derivation) and connects to Maslov's program of idempotent mathematics.

2. **T2 (Channel Capacity)**: The ultrametric inequality gives *tighter* capacity bounds than the Archimedean triangle inequality. This means p-adic channels are *more efficient* than real channels at the same noise level — a fact with immediate applications to lattice-based coding for post-quantum cryptography.

3. **T3 (Source Coding)**: The min-plus rate-distortion bound is *exact*, not asymptotic. This means worst-case compression guarantees are sharper in the tropical setting, enabling certified compression bounds for adversarial sources.

**Cross-Domain Bridges:**
- **Cryptography ↔ Tropical Geometry**: Min-entropy (the resource for randomness extractors) is the natural entropy of the tropical semifield. Post-quantum security bounds become tropical information inequalities.
- **p-adic Analysis ↔ Information Theory**: Ultrametric channels have capacity C = log_p(q) - k, tighter than any Archimedean analog, because the ultrametric inequality is stronger than the triangle inequality.
- **Idempotent Mathematics ↔ ML**: Tropical source coding gives exact (not asymptotic) compression bounds, enabling certified robustness guarantees for neural network compression.

---

### V. REQUIRED: FUTURE_DIRECTIONS.md

After completing the formalization, produce a `FUTURE_DIRECTIONS.md` with 5 concrete breakthrough directions:

1. **Tropical Mutual Information & Data Processing**: Define `tropicalMutualInfo` and prove the tropical data processing inequality I_trop(X;Y) ≥ I_trop(X;Z) for Markov chain X → Y → Z. This would be the non-Archimedean analog of the DPI, with applications to certified privacy.

2. **p-Adic Shannon-McMillan-Breiman Theorem**: Prove an ergodic theorem for min-entropy rates over p-adic dynamical systems, connecting to Furstenberg's p-adic ergodic theory.

3. **Tropical Error-Correcting Codes**: Construct explicit codes achieving the ultrametric capacity C = log_p(q) - k, with polynomial-time encoding/decoding. This would give the first p-adic analog of polar codes.

4. **Idempotent Large Deviations**: Prove that min-entropy governs large deviation rates in the tropical semifield, giving p-adic analogs of Cramér's theorem with applications to certified robustness bounds for ReLU networks.

5. **Non-Archimedean Quantum Information**: Define von Neumann min-entropy for density matrices over p-adic fields and prove strong subadditivity, opening p-adic quantum information theory.

---

### VI. FILE STRUCTURE TARGET

Produce at minimum 3 files with 500+ lines each:

1. **`Bridges/IdempotentInfoTheory/MinEntropy.lean`**: Definitions (`FinProbDist`, `minEntropy`, `tropicalCondMinEntropy`, `IdempotentShannonAxioms`), and all Layer 1-3 theorems (15+ theorems).

2. **`Bridges/IdempotentInfoTheory/UltrametricChannel.lean`**: Definitions (`UltrametricChannel`, `ultrametricCapacity`, coset codes), Layer 5 theorems, and the capacity formula (10+ theorems).

3. **`Bridges/IdempotentInfoTheory/SourceCoding.lean`**: Definitions (`minPlusRateDistortion`, `TropicalCode`), Layer 6 theorems, and the source coding bound (8+ theorems).

Each file must contain ZERO sorries, diverse tactics (induction, rcases, by_contra, omega, linarith, field_simp), and doc comments with `Bridge:` and `Impact:` tags.

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

            Research Mode: FORMALIZE

You are given informal mathematical ideas, notes, or a paper excerpt.
Formalize these ideas in Lean 4. Translate the informal mathematics
into precise definitions and theorem statements, then prove what you
can. If some parts require new axioms, declare them clearly and prove
consequences.

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems with diverse tactics. ZERO sorries.
- AESTHETIC: Formalize ideas that bridge 2+ mathematical domains.
- UTILITY: Define 5+ structures with computational implications.
- ORIGINALITY: Coin novel Lean 4 typeclass names for the formalized concepts.
- IMPACT: Formalize concepts with physics/crypto/ML applications.


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
            Open the field of non-Archimedean information theory by proving three foundational theorems that establish entropy, channel capacity, and source coding over ultrametric fields: (T1) Min-Entropy as Idempotent Shannon Entropy: H_∞(X) = -log(max_x p(x)) is the unique information measure satisfying the min-plus (idempotent) Shannon-Khinchin axioms — continuity, maximality at uniform distribution, and the idempotent chain rule H_trop(X,Y) = H_trop(X) ⊗ min_x H_trop(Y|X=x) — establishing min-entropy as the natural entropy of the tropical semifield and unifying cryptographic min-entropy with Maslov's idempotent probability. (T2) Ultrametric Channel Capacity: For a discrete memoryless channel over a non-Archimedean field with ultrametric noise Z ∈ B(0, p^{-k}), the channel capacity is C = log_p(q) - k where q is the output alphabet size, giving the first p-adic analog of Shannon's noisy-channel coding theorem where the ultrametric inequality replaces the triangle inequality to yield tighter capacity bounds. (T3) Idempotent Source Coding Theorem: The min-plus rate-distortion function R_min(D) achieves the bound R_min(D) ≥ H_∞(X) - D, yielding a tropical source coding theorem where compression rate equals min-entropy minus distortion budget — the non-Archimedean dual of Shannon's classical result. This bridges idempotent mathematics, p-adic analysis, information theory, and cryptography, opening a field where ultrametric geometry governs information transmission.

            ### Precise Mathematical Framing
            Let (ℝ ∪ {+∞}, ⊕, ⊗) = (ℝ ∪ {+∞}, min, +) be the min-plus semifield. For a discrete random variable X with distribution p over a finite set Ω, define the idempotent probability valuation v(x) = -log p(x) and the min-plus expectation E_min[f(X)] = min_x(v(x) + f(x)). Define min-plus entropy as H_min(X) = E_min[v(X)] = min_x(2v(x)) = -2·log(max_x p(x)) = 2·H_∞(X), or equivalently H_trop(X) = -log(max_x p(x)) = H_∞(X). THEOREM 1 (Idempotent Shannon-Khinchin): H_trop is the unique functional on discrete distributions satisfying: (i) continuity in p, (ii) H_trop(X) ≤ log|supp(X)| with equality iff uniform, (iii) chain rule H_trop(X,Y) = H_trop(X) + min_x H_trop(Y|X=x). THEOREM 2 (Ultrametric Capacity): For channel Y = X + Z over ℚ_p with Z uniformly distributed in B(0,p^{-k}), capacity C = max_{p_X} I_min(X;Y) = log_p(q) - k where q = |ℤ/p^kℤ|. The ultrametric inequality |x+y|_p ≤ max(|x|_p, |y|_p) ensures noise balls are either nested or disjoint, giving strictly tighter bounds than Archimedean analogs. THEOREM 3 (Idempotent Source Coding): For source X with distortion measure d under min-plus algebra, R_min(D) = inf_{p(Ẋ|X): E_min[d(X,Ẋ)]≤D} I_min(X;Ẋ) satisfies R_min(D) ≥ H_∞(X) - D, achieving equality for uniform sources over ultrametric balls.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `tropical_plus_distributes_over_min` : theorem tropical_plus_distributes_over_min (a b c : ℝ) :
     (file: Bridges/MinPlusVerificationCore.lean)
  2. `prime_capacity_le_rate_distortion` : theorem prime_capacity_le_rate_distortion
     (file: Bridges/LawvereRateDistortionDuality.lean)
  3. `tropical_min_distributes_over_max` : theorem tropical_min_distributes_over_max (a b c : ℝ) :
     (file: Bridges/TropicalSatake.lean)
  4. `toeplitz_tropical_rank_bound` : theorem toeplitz_tropical_rank_bound (n : ℕ) (hn : 1 ≤ n) :
     (file: Bridges/FiveFrontiers.lean)
  5. `residual_lipschitz_triangle_bound` : theorem residual_lipschitz_triangle_bound
     (file: Bridges/HomologicalDeepLearning.lean)

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



Recent successful concepts: Idempotent Measure Theory: Min-Plus Choquet-Radon Representation, Idempotent Lebesgue Decomposition, and Tropical Kernel Representer Certification, Ideal-Theoretic Learning Capacity: Hilbert-VC Dimension Correspondence, Localization Generalization Bounds, and Noetherian Feature Convergence, Algebraic Circuit Complexity: Ideal-Theoretic Polynomial Identity Testing, Coordinate Ring Depth Bounds, and Gröbner Derandomization


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
Research mode: formalize
