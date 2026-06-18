

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

## Categorified Shannon Theory: Entropy as Natural Transformation, Functorial Data Processing, and Yoneda KL-Divergence

### I. FOUNDATIONAL DEFINITIONS

Define the following structures, each bridging category theory and information theory:

```lean
/-- A finite probability space: a probability distribution on a finite type.
    Bridge: connects measure theory to category theory via FinProbCat. -/
structure FinProbSpace (n : ℕ) where
  prob : Fin n → ℝ≥0
  sum_one : ∑ i, prob i = 1
  nonneg' : ∀ i, 0 ≤ prob i := by omega

/-- A stochastic map (conditional probability kernel) between finite spaces.
    This is the morphism in FinProbCat — the categorical avatar of a channel.
    Bridge: connects Markov kernels to functor morphisms. -/
structure StochasticMap (n m : ℕ) where
  kernel : Fin m → Fin n → ℝ≥0
  row_sum : ∀ j, ∑ i, kernel j i = 1
  nonneg'' : ∀ j i, 0 ≤ kernel j i := by omega

/-- Pushforward of a distribution along a stochastic map.
    This is the functorial action on morphisms. -/
def pushforward {n m : ℕ} (p : FinProbSpace n) (f : StochasticMap n m) : FinProbSpace m where
  prob := fun j => ∑ i, p.prob i * f.kernel j i
  sum_one := by
    simp [Finset.sum_mul]
    rw [Finset.sum_comm]
    exact Finset.sum_congr rfl (fun i _ => (f.row_sum _).symm)
    ... -- requires Finset.sum_comm and rearrangement

/-- Shannon entropy as a functional on FinProbSpace.
    Bridge: connects information theory to additive monoid homomorphisms. -/
def shannonEntropy {n : ℕ} (p : FinProbSpace n) : ℝ :=
  -∑ i, p.prob i * Real.log (p.prob i)

/-- Mutual information arising as adjunction counit.
    Bridge: connects joint distributions to categorical adjunctions. -/
def mutualInformation {n m : ℕ} (p : FinProbSpace (n * m)) : ℝ :=
  shannonEntropy (marginalX p) + shannonEntropy (marginalY p) - shannonEntropy p

/-- KL-divergence as a representable functor evaluation.
    Bridge: connects information geometry to Yoneda lemma. -/
def klDivergence {n : ℕ} (p q : FinProbSpace n) : ℝ :=
  ∑ i, p.prob i * Real.log (p.prob i / q.prob i)
```

### II. THE ENTROPY NATURALITY LAW (Data Processing Inequality as Naturality)

**The Core Theorem**: The data processing inequality IS the naturality condition for Shannon entropy as a natural transformation from the forgetful functor on FinProbCat to the additive monoid `[0,∞]`.

```lean
/-- DATA PROCESSING INEQUALITY = NATURALITY SQUARE
    Entropy never increases under stochastic processing.
    This is the foundational law: it says H is a natural transformation.
    The explicit Lipschitz constant log(n) bounds the entropy loss.
    
    Bridge: connects information theory to category theory naturality.
    Impact: cryptographic_security_channel -- entropy loss bounds key leakage. -/
theorem entropy_data_processing_naturality {n m : ℕ} 
    (p : FinProbSpace n) (f : StochasticMap n m) :
    shannonEntropy (pushforward p f) ≤ shannonEntropy p := by
  sorry -- STRATEGY BELOW
```

**Proof Strategy A (Log-Sum Inequality — Most Direct)**:
1. Prove `log_sum_inequality`: For nonneg aᵢ,bᵢ, `∑ aᵢ log(aᵢ/bᵢ) ≥ (∑ aᵢ) log(∑ aᵢ / ∑ bᵢ)`
2. Apply with `aⱼ = ∑ᵢ pᵢfⱼᵢ` and `bⱼ = ∑ᵢ pᵢ` (row sums)
3. Rearrange to get `H(f_* P) ≤ H(P)`

**Proof Strategy B (Convexity of Negentropy)**:
1. Prove `negentropy_convex`: The map `p ↦ -H(p) = ∑ pᵢ log pᵢ` is convex
2. Prove `pushforward_convex_combination`: Pushforward is a convex combination of conditionals
3. Apply Jensen: `H(f_* P) = H(∑ᵢ pᵢ · δ_{f(i)}) ≤ ∑ᵢ pᵢ H(δ_{f(i)}) ≤ H(P)`

**Proof Strategy C (Factorization via Conditional Entropy — Most Structural)**:
1. Define `conditionalEntropy (p : FinProbSpace (n*m)) : ℝ := H(joint) - H(marginalY)`
2. Prove `conditional_entropy_nonneg`: `H(X|Y) ≥ 0`
3. Prove `entropy_chain_rule`: `H(X,Y) = H(X) + H(Y|X)`
4. Apply: `H(f_* P) = H(Y) = H(X,Y) - H(X|Y) ≤ H(X,Y) = H(P)`

**Strategy C is most promising** because it builds reusable infrastructure (conditional entropy, chain rule) needed for mutual information theorems.

**Strong Data Processing Inequality with Explicit Constant**:
```lean
/-- STRONG DATA PROCESSING: explicit entropy loss bound.
    For a stochastic map with min column sum σ_min,
    entropy loss is at least σ_min · H(P).
    
    Impact: post_quantum_security -- bounds information leakage in lattice-based
    key exchange channels with noise parameter σ_min. -/
theorem entropy_strong_data_processing {n m : ℕ} (p : FinProbSpace n) 
    (f : StochasticMap n m) (hmin : ∀ j, σMin f j > 0) :
    shannonEntropy p - shannonEntropy (pushforward p f) ≥ 
      (∑ j, σMin f j) * shannonEntropy p / m := by
  sorry
```

### III. ENTROPY UNIQUENESS (Characterization Theorem)

**The Deep Result**: Shannon entropy is the UNIQUE natural transformation satisfying three axioms: continuity, permutation symmetry, and the recursion `H(p₁,...,pₙ) = H(p₁+p₂,p₃,...,pₙ) + (p₁+p₂)·H(p₁/(p₁+p₂), p₂/(p₁+p₂))`.

```lean
/-- ENTROPY CHARACTERIZATION: H is the unique natural transformation
    from FinProbCat to ℝ≥0-additive satisfying continuity, symmetry, recursivity.
    This is the categorification of Shannon's theorem.
    
    Bridge: connects universal property (category theory) to entropy axiomatization (info theory).
    Impact: certified_robustness -- uniqueness justifies entropy as THE measure for 
    certified neural network verification. -/
theorem entropy_uniqueness_natural_transformation 
    (η : ∀ {n : ℕ}, FinProbSpace n → ℝ) 
    (h_cont : ContinuousOn (fun p : Fin n → ℝ≥0 => η ⟨p, sorry, sorry⟩) 
        {p | ∀ i, (p i : ℝ) ≥ 0 ∧ ∑ i, p i = 1})
    (h_symm : ∀ {n : ℕ} (p : FinProbSpace n) (σ : Fin n ≃ Fin n), 
        η p = η (permute p σ))
    (h_recur : ∀ {n : ℕ} (p : FinProbSpace (n+2)) (i j : Fin (n+2)) (hne : i ≠ j),
        η p = η (merge p i j) + (p.prob i + p.prob j) * η (conditional p i j))
    (h_nat : ∀ {n m : ℕ} (p : FinProbSpace n) (f : StochasticMap n m),
        η (pushforward p f) ≤ η p) :
    ∃ (c : ℝ≥0), ∀ {n : ℕ} (p : FinProbSpace n), η p = c * shannonEntropy p := by
  sorry -- Key step: prove for dyadic rationals, then extend by continuity
```

**Proof Strategy**:
1. **Dyadic Base Case**: Prove `η(uniform(2^n)) = n · η(uniform(2))` by induction using recursivity
2. **General Rational Case**: For `p` with rational probabilities `pᵢ = kᵢ/N`, embed into uniform(N) and use recursivity to show `η(p) = η(uniform(N)) - ∑ᵢ kᵢ · η(uniform(kᵢ))/N`
3. **Continuity Extension**: Use `h_cont` to extend from rational distributions to all distributions
4. **Normalization**: Set `c = η(uniform(2))` and verify `η = c · H`

### IV. MUTUAL INFORMATION AS ADJUNCTION COUNIT

**The Structural Insight**: Mutual information `I(X;Y) = H(X) + H(Y) - H(X,Y)` is the counit `ε` of an adjunction between marginalization functors.

```lean
/-- Mutual information as adjunction counit.
    The left adjoint marginalizes Y, the right adjoint marginalizes X.
    The counit ε: margX ∘ margY^* ⇒ Id gives I(X;Y).
    
    Bridge: connects adjunction triangle identities to information-theoretic chain rules.
    Impact: quantum_entanglement_verification -- mutual information bounds entanglement
    in quantum key distribution protocols. -/
def mutualInformation_counit {n m : ℕ} (p : FinProbSpace (n * m)) : ℝ :=
  shannonEntropy (marginalX p) + shannonEntropy (marginalY p) - shannonEntropy p

/-- CHAIN RULE FROM TRIANGLE IDENTITY
    The information chain rule I(X;Y,Z) = I(X;Y) + I(X;Z|Y)
    follows from the adjunction triangle identity for the marginalization adjunction.
    
    This is the categorical reason the chain rule holds. -/
theorem mutual_information_chain_rule_triangle {n m k : ℕ} 
    (p : FinProbSpace (n * m * k)) :
    mutualInformation_counit (assocXYZ p) = 
      mutualInformation_counit (projXY p) + 
      conditionalMutualInformation (projXZ_given_Y p) := by
  sorry -- Expand definitions, apply chain rule for entropy, rearrange
```

**Proof Strategy**:
1. Prove `entropy_chain_rule_joint`: `H(X,Y,Z) = H(X) + H(Y|X) + H(Z|X,Y)`
2. Prove `mutual_information_expansion`: `I(X;Y,Z) = H(X) + H(Y,Z) - H(X,Y,Z)`
3. Prove `conditional_mutual_information_def`: `I(X;Z|Y) = H(X|Y) - H(X|Y,Z)`
4. Substitute and rearrange: `I(X;Y,Z) = I(X;Y) + I(X;Z|Y)` follows algebraically
5. Verify the triangle identity: `ε_XY ∘ (F ε_X) = ε_{XYZ}` in the adjunction picture

### V. KL-DIVERGENCE YONEDA LAW

**The Deep Connection**: KL-divergence is representable via the Donsker-Varadhan variational formula: `KL(P‖Q) = sup_f [E_P[f] - log E_Q[e^f]]`. Non-negativity follows by evaluating at `f = 0`.

```lean
/-- Donsker-Varadhan variational formula (Yoneda representation).
    KL(P‖Q) is the supremum over all "test functions" f of E_P[f] - log E_Q[e^f].
    This is the Yoneda lemma: KL is representable by the exponential family.
    
    Bridge: connects information geometry to Yoneda lemma (category theory).
    Impact: differential_privacy_verification -- KL bounds compose multiplicatively
    via this variational formula, enabling certified privacy budgets. -/
theorem kl_divergence_yoneda_representation {n : ℕ} (p q : FinProbSpace n)
    (hq : ∀ i, q.prob i > 0) :
    klDivergence p q = 
      sSup {f : Fin n → ℝ | 
        ∑ i, p.prob i * f i - Real.log (∑ i, q.prob i * Real.exp (f i))} := by
  sorry -- Key: prove ≥ by choosing f = log(p/q), prove ≤ by Gibbs inequality

/-- KL-DIVERGENCE NON-NEGATIVITY VIA YONEDA
    Evaluating the Yoneda representation at f = 0 gives 0,
    so KL(P‖Q) ≥ 0. This is the Yoneda lemma at the identity morphism.
    
    Bridge: connects Yoneda lemma to information inequality.
    Impact: cryptographic_distinguishing_advantage -- KL ≥ 0 bounds the
    advantage of any distinguisher between distributions P and Q. -/
theorem kl_divergence_yoneda_nonneg {n : ℕ} (p q : FinProbSpace n)
    (hq : ∀ i, q.prob i > 0) :
    klDivergence p q ≥ 0 := by
  sorry -- Evaluate Yoneda representation at f = 0, get 0 ≤ sup
```

**Proof Strategy for Yoneda Representation**:
1. **Lower bound (≥)**: Choose `f i = log(p.prob i / q.prob i)`. Then `E_P[f] = KL(P‖Q)` and `E_Q[e^f] = E_Q[p/q] = 1`, so `log E_Q[e^f] = 0`. Hence `f` achieves value `KL(P‖Q)`.
2. **Upper bound (≤)**: For any `f`, apply `log-sum inequality` or `Jensen's inequality` to show `E_P[f] - log E_Q[e^f] ≤ KL(P‖Q)`.
3. **Key lemma**: `E_P[f] ≤ KL(P‖Q) + log E_Q[e^f]` — this is equivalent to `∑ pᵢ(fᵢ - log(qᵢ/pᵢ) · e^{fᵢ} · qᵢ/pᵢ)` which follows from `log(x) ≤ x - 1` applied pointwise.

### VI. PINSKER'S INEQUALITY (Explicit KL → TV Bound)

```lean
/-- PINSKER'S INEQUALITY: Explicit bound on total variation from KL-divergence.
    d_TV(P,Q) ≤ √(KL(P‖Q)/2)
    
    This gives a Lipschitz_certified_robustness bound: if KL(P‖Q) < ε,
    then no test can distinguish P from Q with advantage > √(ε/2).
    
    Bridge: connects information geometry to metric geometry.
    Impact: lipschitz_certified_robustness -- Pinsker bounds certify neural network
    robustness via distributional stability. -/
theorem pinsker_inequality {n : ℕ} (p q : FinProbSpace n)
    (hq : ∀ i, q.prob i > 0) :
    totalVariation p q ≤ Real.sqrt (klDivergence p q / 2) := by
  sorry -- Classic proof: reduce to binary case, then direct calculus
```

### VII. ENTROPY LIPSCHITZ BOUND (Certified Robustness Application)

```lean
/-- ENTROPY LIPSCHITZ BOUND: Shannon entropy is log(n)-Lipschitz 
    in total variation distance on n-outcome distributions.
    
    |H(P) - H(Q)| ≤ log(n) · d_TV(P,Q)
    
    Bridge: connects information theory to Lipschitz analysis.
    Impact: certified_robustness_neural -- entropy Lipschitz constant enables
    certified robustness bounds for neural network classifiers via entropy 
    regularization with explicit O(log n) Lipschitz constant. -/
theorem entropy_lipschitz_certified_bound {n : ℕ} (p q : FinProbSpace n) :
    |shannonEntropy p - shannonEntropy q| ≤ Real.log n * totalVariation p q := by
  sorry -- Proof: entropy gradient has ℓ∞-norm ≤ log(n), apply mean value theorem
```

### VIII. QUANTUM EXTENSION (Von Neumann Entropy Natural Transformation)

```lean
/-- Von Neumann entropy as natural transformation on quantum channels.
    H(ρ) = -Tr(ρ log ρ) is the quantum analogue.
    
    Bridge: connects quantum information to categorical naturality.
    Impact: quantum_entropy_certification -- quantum data processing inequality
    certifies quantum key distribution security bounds. -/
def vonNeumannEntropy (ρ : Matrix (Fin n) (Fin n) ℂ) 
    (h_pos : Matrix.PosSemidef ρ) (h_tr : Matrix.trace ρ = 1) : ℝ := sorry

/-- QUANTUM DATA PROCESSING = NATURALITY
    For CPTP map Φ (completely positive trace-preserving):
    H(Φ(ρ)) ≤ H(ρ)
    
    This is naturality of von Neumann entropy on the category of
    quantum channels (CPTP maps). -/
theorem quantum_data_processing_naturality {n m : ℕ}
    (ρ : Matrix (Fin n) (Fin n) ℂ)
    (h_pos : Matrix.PosSemidef ρ) (h_tr : Matrix.trace ρ = 1)
    (Φ : QuantumChannel n m) :
    vonNeumannEntropy (Φ.apply ρ) ≤ vonNeumannEntropy ρ := by
  sorry -- Requires Lieb's concavity theorem
```

### IX. FANO'S INEQUALITY (Information-Theoretic Error Bound)

```lean
/-- FANO'S INEQUALITY: Explicit bound on estimation error from conditional entropy.
    If X → Y → X̂ is a Markov chain, then:
    P(X̂ ≠ X) ≥ (H(X|Y) - 1) / log(|X|)
    
    Bridge: connects information theory to estimation theory.
    Impact: post_quantum_security -- Fano bounds the probability that a quantum
    adversary correctly guesses a lattice-based key, giving explicit security
    parameters for NIST post-quantum standards. -/
theorem fano_information_bound {n m : ℕ} 
    (p : FinProbSpace (n * m)) (h_nz : n ≥ 2) :
    let condEnt := conditionalEntropy p
    let errorProb := estimationError p
    errorProb ≥ (condEnt - 1) / Real.log n := by
  sorry -- Proof: reduce to binary case via data processing, then direct computation
```

### X. REQUIRED LEMMAS AND INFRASTRUCTURE

Build these supporting results with diverse proof tactics:

```lean
/-- Log-sum inequality: foundational for all KL results.
    Proved via convexity of x·log(x/y). -/
theorem log_sum_inequality {n : ℕ} (a b : Fin n → ℝ≥0)
    (ha : ∑ i, a i > 0) (hb : ∑ i, b i > 0) :
    ∑ i, a i * Real.log (a i / b i) ≥ 
      (∑ i, a i) * Real.log ((∑ i, a i) / (∑ i, b i)) := by
  sorry -- Convexity of f(x,y) = x·log(x/y) via Jensen

/-- Gibbs inequality: KL(P‖Q) ≥ 0 is equivalent to ∑ pᵢ log(pᵢ/qᵢ) ≥ 0. -/
theorem gibbs_inequality {n : ℕ} (p q : FinProbSpace n)
    (hq : ∀ i, q.prob i > 0) :
    ∑ i, p.prob i * Real.log (p.prob i / q.prob i) ≥ 0 := by
  sorry -- Apply log(x) ≤ x - 1 pointwise, sum

/-- Subadditivity of entropy: H(X,Y) ≤ H(X) + H(Y). -/
theorem entropy_subadditivity {n m : ℕ} (p : FinProbSpace (n * m)) :
    shannonEntropy p ≤ shannonEntropy (marginalX p) + shannonEntropy (marginalY p) := by
  sorry -- Equivalent to non-negativity of mutual information

/-- Conditional entropy monotonicity: H(X|Y,Z) ≤ H(X|Y). -/
theorem conditional_entropy_monotonicity {n m k : ℕ} 
    (p : FinProbSpace (n * m * k)) :
    conditionalEntropy (projXZ_given_Y p) ≤ conditionalEntropy (projXY p) := by
  sorry -- Data processing: conditioning reduces entropy
```

### XI. COMPUTATIONAL BOUNDS AND ALGORITHMIC CONTENT

Every theorem must have explicit computational content:

- **Entropy computation**: `shannonEntropy p` computable in `O(n)` time for `n` outcomes
- **Mutual information**: `mutualInformation p` computable in `O(nm)` for `n×m` joint distribution
- **KL-divergence**: `klDivergence p q` computable in `O(n)` 
- **Pinsker bound**: `d_TV(P,Q) ≤ √(KL(P‖Q)/2)` — `O(1)` given KL value
- **Entropy Lipschitz**: `|H(P) - H(Q)| ≤ log(n) · d_TV(P,Q)` — `O(n)` verification
- **Strong data processing gap**: `H(P) - H(f_* P) ≥ σ_min · H(P)` where `σ_min = min_j ∑ᵢ f_kernel j i · min(pᵢ/∑ₖ pₖ)` — explicit lower bound on entropy loss

### XII. SIGNIFICANCE AND FUTURE DIRECTIONS

This formalization opens the field of **categorified information theory**. The three laws proven here — Entropy Naturality, Mutual Information Adjunction, KL Yoneda — demonstrate that Shannon's framework emerges entirely from categorical first principles:

1. **Data processing inequality** is not an ad hoc fact but the **naturality condition** for the unique entropy natural transformation
2. **Chain rule** is not a computational identity but the **triangle identity** of an adjunction  
3. **Information inequality** (KL ≥ 0) is not a convexity fact but the **Yoneda lemma** evaluated at the identity

**Applications unlocked**:
- **Post-quantum cryptography**: Pinsker + strong data processing give explicit bounds on distinguishing advantage for lattice-based schemes (Kyber, Dilithium)
- **Certified robustness in ML**: Entropy Lipschitz bound `log(n) · d_TV` certifies neural network stability under distribution shift
- **Quantum key distribution**: Quantum data processing naturality certifies entanglement-based security with explicit entropy loss bounds

**Request**: Produce a `FUTURE_DIRECTIONS.md` with 3-5 concrete next steps, including:
1. Relative entropy category: Formalize the category `ProbMor` where objects are probability spaces and morphisms are pairs `(P,Q)` with KL-divergence as a functor to `[0,∞]`
2. Tropical information theory: Develop tropical Shannon entropy `H_trop(p) = -max_i log(pᵢ)` and prove it satisfies tropical data processing
3. Categorified capacity: Define channel capacity categorically as a Kan extension and prove the noisy channel coding theorem
4. Quantum adjunction: Formalize the Stinespring dilation as an adjunction and derive quantum mutual information from the counit
5. Differential privacy composition: Prove that the privacy loss random variable composes via the Yoneda representation, giving certified privacy budgets

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
            Open the field of categorified information theory by proving three foundational laws that rederive Shannon's framework entirely from category-theoretic first principles. (1) ENTROPY NATURALITY LAW: Shannon entropy H constitutes the unique natural transformation from the forgetful functor on FinProb (finite probability spaces with stochastic maps) to the additive monoid functor satisfying continuity, symmetry, and recursivity — the data processing inequality is the naturality condition. (2) MUTUAL INFORMATION ADJUNCTION LAW: Mutual information I(X;Y) is the counit of a relative adjunction between marginalization functors on FinJointProb, and the chain rule I(X;Y,Z) = I(X;Y) + I(X;Z|Y) follows from the adjunction triangle identity. (3) KL-DIVERGENCE YONEDA LAW: KL-divergence is a representable functor on ProbMor represented by the exponential family, and the information inequality KL(P‖Q) ≥ 0 is the Yoneda lemma applied at the identity morphism.

            ### Precise Mathematical Framing
            Define the category FinProb whose objects are finite probability spaces (Ω, p) and whose morphisms are stochastic maps (Markov kernels). Define U: FinProb → FinSet as the forgetful functor and H: FinProb → ℝ₊-Mod as the entropy functor. THEOREM 1 (Entropy Naturality): There exists a unique natural transformation η: U ⇒ Δ ∘ H satisfying (a) continuity in p, (b) invariance under Sym(Ω), (c) recursivity H(p₁,...,pₙ) = H(p₁+...+pₖ, pₖ₊₁,...,pₙ) + S·H(p₁/S,...,pₖ/S) where S = p₁+...+pₖ. For any stochastic map f: (Ω₁,p₁) → (Ω₂,p₂), the naturality square H(p₂) ≤ H(p₁) is exactly the data processing inequality. THEOREM 2 (Mutual Information Adjunction): Define FinJointProb with marginalization functors M₁,M₂: FinJointProb → FinProb. These form a relative adjunction M₁ ⊣_{Δ} M₂. The counit ε_{X,Y} = H(M₁(P_{X,Y})) + H(M₂(P_{X,Y})) - H(P_{X,Y}) = I(X;Y). The triangle identity yields the chain rule. THEOREM 3 (KL Yoneda): Define ProbMor_Q as the slice category over Q. The functor KL(·‖Q): ProbMor_Q → ℝ₊ is representable: KL(P‖Q) = Hom(Exp(Q), P) where Exp(Q) is the exponential family generated by Q. The information inequality is Yoneda: id_Q ↦ 0 and all other morphisms give positive values.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `leech_from_three_e8` : theorem leech_from_three_e8 : 3 * (8 : ℕ) = 24 := by norm_num
     (file: Bridges/Moonshine/MoonshineCodingTheory.lean)
  2. `kraft_inequality_binary_nat` : theorem kraft_inequality_binary_nat
     (file: Bridges/LawvereCodingTheorem.lean)
  3. `certified_robust_from_margin_bound` : lemma certified_robust_from_margin_bound {n m : ℕ}
     (file: Bridges/MaslovDequantizationRobustness.lean)
  4. `purity_lower_bound_from_spectrum` : theorem purity_lower_bound_from_spectrum (k : ℕ) (hk : k > 0)
     (file: Bridges/QuantumIdempotent.lean)
  5. `chain_strength_bound` : theorem chain_strength_bound (L : ℕ) (J_max : ℝ) (hL : 1 ≤ L) (hJ : 0 < J_max) :
     (file: Bridges/ThreeNewFrontiers.lean)

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



Recent successful concepts: EML Cryptographic Primitives: Closure One-Way Functions, Idempotent Sigma Protocols, and Fixed-Point Key Exchange, Toric Code as a Chain Complex: Verified Topological Quantum Error Correction via Homological Distance Bounds, algebra_breakthrough_discovery


            ### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.

            ### Required Deliverables

            You are a world-class mathematician and software engineer. Create:

            1. **Lean 4 files** — formally verified theorems with complete proofs
               - Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
               - Build on the existing catalog theorems listed above
               - Minimize `sorry` — isolate hard steps rather than leaving gaps
               - Use doc comments to explain the significance of key results

            2. **RESEARCH_REPORT.md** — paper explaining the discovery
               - Mathematical significance and connections to existing work
               - Detailed proofs and explanations

            3. **DISCUSSION.md** — MANDATORY Scientific American-style popular science article
               - Written for a mathematically literate but non-specialist audience
               - Use analogies, examples, and narrative to explain WHY this matters
               - Include at least one surprising connection to everyday life or another field
               - 1000-2000 words, accessible but not dumbed-down
               - This makes your research accessible to a broad audience

            4. **FUTURE_DIRECTIONS.md** — MANDATORY breakthrough research roadmap
               This is the MOST IMPORTANT deliverable because it drives the next
               research cycle. Structure it as:

               ## Breakthrough Opportunities (ranked by impact)
               For each opportunity:
               - **Theorem Statement**: Precise, formalizable statement with quantifiers
               - **Proof Strategy**: 2-3 concrete approaches with key lemmas identified
               - **Why This Is Revolutionary**: What field it opens, what applications it enables,
                 what unexpected connections it reveals
               - **Catalog Leverage**: Which existing catalog theorems to build on (by name)
               - **Research Mode**: prove | formalize | discover | counterexample
               - **Estimated Depth**: 1-5 scale (1 = one clever lemma, 5 = multi-theorem development)

               ## Under-explored Territory
               - Domains with many definitions but few deep theorems
               - Unexpected structural similarities across domains
               - "Orphan" results that could seed new research programs

               ## Cross-Domain Bridges
               - Specific, precise connections between domains
               - Conjectured functorial correspondences or isomorphisms
               - Algorithmic pipelines combining results from multiple domains

               ## Open Problems Encountered
               - Problems you couldn't solve but identified as important
               - Conjectures you can state precisely but not yet prove
               - Connections that seem to exist but need more catalog infrastructure

            5. **demo.py** — Python demo with concrete numerical examples
               - Working code that brings the math to life
               - Visualizations where they add insight

            6. **diagram.svg** — visualization of key mathematical structures

            Produce novel, non-trivial theorems with complete Lean 4 proofs. Think big — aim for results that would appear in JAMS, Annals, or FOCS.

            ### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### WHAT WE NEED FROM YOU

You are a world-class mathematician and software engineer. Use your judgment
on the best way to organize and present your work. We need:

1. **Formally verified mathematics** in Lean 4
   - Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
   - Organize the Lean code however makes sense — one file or several,
     whatever serves the mathematics best
   - Use doc comments to explain the significance of key results

2. **Python demos** that bring the mathematics to life
   - Create working Python code that demonstrates the theorems with
     concrete numerical examples
   - Visualizations (matplotlib, etc.) where they add insight
   - Show the math in action — make it tangible and understandable
   - Name and organize the demos however you see fit

3. **A research paper** that explains the discovery
   - Write this as a proper mathematical paper
   - Include a Scientific American style discussion section that makes
     the result accessible to a broad audience — use analogies,
     intuition, and historical context
   - Explain connections to existing work and future directions

4. **Useful applications** — show how this math matters in practice
   - What can people DO with this result?
   - Where does it apply in the real world?
   - Include code, examples, or demonstrations of applications

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real and useful.

Research domain: Bridges
Research mode: formalize
