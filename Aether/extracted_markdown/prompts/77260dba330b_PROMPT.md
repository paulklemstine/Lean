

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

## TASK: Tropical Post-Quantum Cryptography — Min-Plus One-Way Functions and Lattice-Free Hardness

### Visionary Context

The central insight: tropical (min-plus) semiring algebra yields computationally asymmetric problems — evaluation is O(n³) but inversion requires solving tropical polynomial systems whose complexity grows super-polynomially. This is NOT lattice-based cryptography; it is an entirely different hardness source: the geometry of tropical hypersurfaces creates combinatorial explosion without any lattice structure. By formalizing the algebraic foundations and proving concrete Lipschitz/collision bounds, we establish the mathematical infrastructure for post-quantum key exchange that resists both Shor's algorithm and known quantum attacks on lattices.

Bridge: connects Tropical Geometry to Post-Quantum Cryptography via Optimization Theory and Certified Robustness in ML.

---

### Part 1: Core Tropical Cryptographic Algebra

Define the min-plus semiring over integers with infinity, then build the matrix algebra that underpins all cryptographic constructions.

**Definition 1: `TropicalSemiring`** — The min-plus semiring (ℤ ∪ {∞}, min, +). Define as a typeclass instance with carrier `WithTop ℤ`, addition `min`, multiplication `+`. Prove it satisfies the Semiring axioms (note: without multiplicative zero being absorbing in the standard sense — this is a *semiring*, not a ring).

**Definition 2: `TropicalMatrix`** — Type alias `TropicalMat (n : ℕ) := Matrix (Fin n) (Fin n) (WithTop ℤ)` with the tropical matrix product:
```
def tropical_mul {n : ℕ} (A B : TropicalMat n) : TropicalMat n :=
  fun i j => Finset.min' (Finset.univ.map (fun k => A i k + B k j)) (by sorry) -- replaced with proper instance
```
Actually, define it properly using `Finset.fold` or direct `inf` computation.

**Definition 3: `TropicalDet`** — The tropical determinant as minimum-weight assignment:
```
def tropical_det {n : ℕ} (A : TropicalMat n) : WithTop ℤ :=
  Finset.min' (Finset.univ.permutations.map (fun σ => Finset.univ.sum fun i : Fin n => A i (σ i))) (by ...)
```

**Definition 4: `TropicalKleeneStar`** — The Kleene star A* = I ⊕ A ⊕ A² ⊕ A³ ⊕ ... (terminates because paths in a complete digraph on n vertices have at most n-1 edges achieving minimum weight):
```
def tropical_kleene_star {n : ℕ} (A : TropicalMat n) : TropicalMat n
```

**Definition 5: `TropicalOneWayCandidate`** — A structure bundling a tropical matrix with the claim that powering is easy but discrete logarithm extraction is hard:
```
structure TropicalOneWayCandidate (n : ℕ) where
  base : TropicalMat n
  power : ℕ → TropicalMat n  -- fast via repeated squaring
  -- The "hard direction": given base^k, find k
  hardness_param : ℕ  -- security parameter
```

---

### Part 2: Foundational Theorems (10+ required, ZERO sorries)

Prove these in order — each builds on the previous:

**Theorem 1: `tropical_mul_assoc`**
```
theorem tropical_mul_assoc {n : ℕ} (A B C : TropicalMat n) :
    tropical_mul A (tropical_mul B C) = tropical_mul (tropical_mul A B) C := by
```
*Proof strategy*: Unfold definition, use associativity of addition over ℤ, and the key combinatorial identity: `min_k (min_j (a_{ik} + b_{kj}) + c_{jl}) = min_j (a_{ik} + min_k (b_{kj} + c_{jl}))`. This follows from `min` distributing over `+` in a suitable sense. Use `Finset.fold_assoc` or direct `ext` + `Finset.min'_eq_fold`.

**Theorem 2: `tropical_mul_distrib_left`**
```
theorem tropical_mul_distrib_left {n : ℕ} (A B C : TropicalMat n) :
    tropical_mul A (tropical_add B C) = tropical_add (tropical_mul A B) (tropical_mul A C) := by
```
*Proof strategy*: The key identity is `min_k (a_{ik} + min(b_{kj}, c_{kj})) = min(min_k (a_{ik} + b_{kj}), min_k (a_{ik} + c_{kj}))`. Prove this via `Finset.min'_add_min'_eq_min` lemma, which itself follows from `min (a + b) (a + c) = a + min b c`.

**Theorem 3: `tropical_det_permutation_characterization`**
```
theorem tropical_det_permutation_characterization {n : ℕ} (A : TropicalMat n) :
    tropical_det A = Finset.min' (Finset.univ.map fun σ : Fin n → Fin n =>
      if Bijective σ then (Finset.univ.sum fun i => A i (σ i)) else ⊤) (by ...) := by
```
*Proof strategy*: The tropical determinant minimizes over all permutations. Prove that non-permutation terms are dominated. Uses the fact that any non-bijective assignment has a transposition that doesn't increase the cost (a tropical version of the optimality condition for assignments).

**Theorem 4: `kleene_star_bellman_equation`**
```
theorem kleene_star_bellman_equation {n : ℕ} (A : TropicalMat n) :
    tropical_add (tropical_id n) (tropical_mul A (tropical_kleene_star A)) = tropical_kleene_star A := by
```
*Proof strategy*: The Kleene star A* satisfies A* = I ⊕ A⊗A*. This is the tropical Bellman equation. Prove by showing both directions: A* ≥ I ⊕ A⊗A* (since A* includes all paths of length 0 and paths of length ≥ 1 = A ⊗ (paths of length ≥ 0)), and A* ≤ I ⊕ A⊗A* (since any path of length k ≥ 1 decomposes as first edge ⊗ remaining path). Uses induction on path length.

**Theorem 5: `kleene_star_shortest_path`**
Bridge: connects Tropical Algebra to Graph Theory/Optimization.
```
theorem kleene_star_shortest_path {n : ℕ} (A : TropicalMat n) (i j : Fin n) :
    (tropical_kleene_star A) i j = Finset.min' (Finset.univ.map fun p : List (Fin n) =>
      if p.IsPath i j then path_weight A p else (⊤ : WithTop ℤ)) (by ...) := by
```
*Proof strategy*: Show the Kleene star computes shortest paths by induction on path length. The key lemma: `path_weight_decomposition` showing any path of length ≥ 2 decomposes.

**Theorem 6: `tropical_power_repeated_squaring_complexity`**
```
theorem tropical_power_repeated_squaring_complexity (n k : ℕ) (A : TropicalMat n) :
    ∃ f : ℕ → TropicalMat n,
      f 0 = tropical_id n ∧
      f k = tropical_pow A k ∧
      -- The number of tropical multiplications is O(log k)
      (∃ m : ℕ, m ≤ 2 * Nat.log2 k + 2 ∧ 
        ComputableIn m tropical_mul f) := by
```
*Proof strategy*: Construct the repeated squaring algorithm explicitly. Prove correctness by strong induction on k. The complexity bound follows from `Nat.log2` properties. This establishes the "easy direction" of the one-way function.

**Theorem 7: `tropical_hash_collision_resistance`**
Bridge: connects Tropical Geometry to Cryptographic Hash Functions.
```
theorem tropical_hash_collision_resistance (n : ℕ) (h_n : n ≥ 3) 
    (A : TropicalMat n) (h_det : tropical_det A < ⊤) :
    ∀ x y : Fin n → WithTop ℤ,
      x ≠ y → (tropical_det (tropical_mul A (diagonal x))) ≠ 
              (tropical_det (tropical_mul A (diagonal y))) ∨
      -- Collision requires solving a tropical polynomial equation
      ∃ i j : Fin n, i ≠ j ∧ A i j = A j i := by
```
*Proof strategy*: Show that if two different diagonal perturbations yield the same tropical determinant, then the matrix A has a specific symmetric substructure. This is a tropical analogue of the Vandermonde determinant argument. Uses `tropical_det_permutation_characterization` and case analysis on which permutation achieves the minimum.

**Theorem 8: `tropical_lipschitz_certified_robustness`**
Bridge: connects Tropical Polynomials to Certified Robustness in ML.
```
theorem tropical_lipschitz_certified_robustness {n : ℕ} (f : (Fin n → ℤ) → ℤ)
    (h_trop : IsTropicalPolynomial f) :
    ∃ L : ℕ, L = 1 ∧
    ∀ x y : Fin n → ℤ,
      ‖f x - f y‖ ≤ L * Finset.univ.sum (fun i => ‖x i - y i‖) := by
```
*Proof strategy*: Tropical polynomials are 1-Lipschitz with respect to the ℓ¹ norm (in the tropical sense, this means |f(x) - f(y)| ≤ max_i |x_i - y_i|). Prove by induction on the structure of tropical polynomials: tropical monomials are 1-Lipschitz (the max of sums), and the min/max operations preserve the Lipschitz property. The Lipschitz constant 1 is tight — achieved by tropical linear forms.

**Theorem 9: `tropical_subdeterminant_growth_bound`**
```
theorem tropical_subdeterminant_growth_bound (n : ℕ) (A : TropicalMat n)
    (h_pos : ∀ i j, (0 : WithTop ℤ) < A i j) :
    ∀ k : Fin (n + 1),
      tropical_det (A.submatrix Finset.univ (Finset.univ.erase k)) ≤
      tropical_det A + (Finset.univ.sum fun i : Fin n => A i k) := by
```
*Proof strategy*: The tropical subdeterminant is bounded by the full determinant plus a correction. This follows from the assignment characterization: the optimal assignment for the (n-1)×(n-1) submatrix can be extended to an n×n assignment at additional cost. Uses `tropical_det_permutation_characterization`.

**Theorem 10: `tropical_diffie_hellman_correctness`**
Bridge: connects Tropical Algebra to Post-Quantum Key Exchange.
```
theorem tropical_diffie_hellman_correctness (n : ℕ) (A : TropicalMat n)
    (a b : ℕ) (h_comm : tropical_mul (tropical_pow A a) (tropical_pow A b) = 
                              tropical_mul (tropical_pow A b) (tropical_pow A a)) :
    tropical_mul (tropical_pow (tropical_mul A (tropical_pow A (a - 1))) b)
                 (tropical_pow A 1) =
    tropical_mul (tropical_pow (tropical_mul A (tropical_pow A (b - 1))) a)
                 (tropical_pow A 1) := by
```
*Proof strategy*: This is the correctness of tropical Diffie-Hellman: both parties compute the same shared key. The commutativity hypothesis is needed because tropical matrix multiplication is NOT commutative in general. Prove that for commuting tropical matrices, (A^a)(A^b) = (A^b)(A^a) = A^{a+b}. Uses `tropical_mul_assoc` and the commutativity assumption.

**Theorem 11: `tropical_matrix_noncommutativity_witness`**
```
theorem tropical_matrix_noncommutativity_witness :
    ∃ (A B : TropicalMat 2),
      tropical_mul A B ≠ tropical_mul B A := by
```
*Proof strategy*: Construct explicit 2×2 matrices. Take A = [[0,1],[1,0]] and B = [[0,2],[3,0]]. Compute both products and show they differ at some entry. Uses `Finset.min'_eq_fold` or direct computation.

**Theorem 12: `tropical_eigenvalue_existence_bounded`**
Bridge: connects Tropical Eigenvalues to Quantum Hamiltonian Spectra.
```
theorem tropical_eigenvalue_existence_bounded (n : ℕ) (A : TropicalMat n)
    (h_fin : ∀ i j, A i j < ⊤) :
    ∃ λ : WithTop ℤ, λ < ⊤ ∧
    ∃ v : Fin n → WithTop ℤ, v ≠ 0 ∧
    tropical_mul A v = fun i => λ + v i := by
```
*Proof strategy*: The tropical eigenvalue is the minimum cycle mean in the weighted digraph defined by A. This is the tropical analogue of the Perron-Frobenius theorem. The eigenvector is the vector of shortest path distances. Prove using the Karp's algorithm characterization: λ = min_j max_k ((A^k)_{0j} - (A^{k-1})_{0j}) / ... but in tropical setting, λ = min over cycles of (cycle mean weight). Uses `kleene_star_bellman_equation` and cycle decomposition.

---

### Part 3: Cryptographic Application Theorems

**Theorem 13: `tropical_preimage_lower_bound`**
```
theorem tropical_preimage_lower_bound (n : ℕ) (h_n : n ≥ 2) (A : TropicalMat n)
    (h_det : tropical_det A < ⊤) (t : WithTop ℤ) :
    {x : Fin n → WithTop ℤ // tropical_eval A x = t}.ncard ≤ 1 ∨
    ∃ i j : Fin n, i ≠ j ∧ A i 0 + A i 1 = A j 0 + A j 1 := by
```
*Proof strategy*: Show that tropical polynomial evaluation is almost injective: preimages have size ≤ 1 unless specific degeneracies occur. This is the algebraic foundation for collision resistance. The disjunction captures that either the function is injective (ideal for crypto) or there is a specific algebraic obstruction.

**Theorem 14: `tropical_entropy_preservation`**
Bridge: connects Tropical Information Theory to Cryptographic Security.
```
theorem tropical_entropy_preservation (n : ℕ) (A : TropicalMat n)
    (h_mixing : ∀ i j, A i j < A i i + A j j) :
    ∀ S : Finset (Fin n → WithTop ℤ),
      Finset.card (S.image (tropical_eval A)) ≥ 
      Finset.card S - (n * n) := by
```
*Proof strategy*: Under the "mixing" condition (off-diagonal entries are smaller than diagonal sums — a tropical version of diagonal dominance), tropical evaluation nearly preserves cardinality. The deficit of at most n² accounts for the finitely many degeneracy points. Uses pigeonhole argument and the fact that each fiber of `tropical_eval A` has bounded size under the mixing condition.

**Theorem 15: `post_quantum_security_parameter_bound`**
```
theorem post_quantum_security_parameter_bound (n : ℕ) (h_n : n ≥ 64) :
    ∀ A : TropicalMat n,
      ∀ k : ℕ, k ≥ 2^(n/2) →
        -- Tropical discrete log: finding k from A^k requires ≥ 2^(n/4) operations
        -- (stated as: the decision tree complexity is exponential)
        DecisionTreeComplexity (tropical_discrete_log A k) ≥ 2^(n/4) := by
```
*Note*: This should be stated as a *conjecture* with partial progress. Prove the weaker statement that the naive brute-force algorithm requires ≥ 2^(n/4) steps, which gives a baseline security parameter.

---

### Part 4: Concrete Security Bounds

**Theorem 16: `tropical_key_space_cardinality`**
```
theorem tropical_key_space_cardinality (n : ℕ) (B : ℕ) :
    Finset.card {A : TropicalMat n // ∀ i j, (0 : ℤ) ≤ A i j ∧ A i j ≤ B} ≥ (B + 1)^(n*n) := by
```
*Proof strategy*: Direct counting. Each entry has B+1 choices. The bound is tight (equality holds). This establishes the key space size for parameter selection.

**Theorem 17: `tropical_collision_probability_upper_bound`**
```
theorem tropical_collision_probability_upper_bound (n : ℕ) (B : ℕ) (h_B : B ≥ 2) :
    ∀ f : TropicalMat n → (Fin n → WithTop ℤ),
      IsTropicalLinear f →
      -- Birthday bound for tropical hash collision
      ∀ k : ℕ, k ≤ B^(n/2) →
        (Finset.card {A : TropicalMat n // ∀ i j, (0 : ℤ) ≤ A i j ∧ (A i j : ℤ) ≤ B ∧ 
          f A = f A} : ℕ) ≤ k^2 / (2 * (B+1)^n) := by
```
*Proof strategy*: Adapt the birthday paradox to tropical hash functions. The collision probability is at most k²/(2|Range|). The range size for tropical linear maps is at least (B+1)^n. Uses `tropical_key_space_cardinality` and the birthday bound.

---

### Part 5: Certified Robustness Bridge to ML

**Theorem 18: `tropical_network_certified_radius`**
Bridge: connects Tropical Neural Networks to Certified Adversarial Robustness.
```
theorem tropical_network_certified_radius {n m : ℕ} 
    (W : TropicalMat n) (v : Fin n → ℤ) (x : Fin n → ℤ)
    (h_robust : IsTropicalClassifier W v x) :
    ∀ y : Fin n → ℤ,
      (∀ i : Fin n, |y i - x i| ≤ certified_radius W v x) →
      tropical_classify W v y = tropical_classify W v x := by
```
where `certified_radius` is explicitly:
```
def certified_radius {n : ℕ} (W : TropicalMat n) (v : Fin n → ℤ) (x : Fin n → ℤ) : ℕ :=
  min over i j with v i ≠ v j of (|(tropical_eval W x) i - (tropical_eval W x) j|) / 2
```
*Proof strategy*: The certified radius is half the minimum margin between any two classes. By the 1-Lipschitz property (Theorem 8), a perturbation of radius r changes the output by at most r, so if r < margin/2, the classification is preserved. Uses `tropical_lipschitz_certified_robustness`.

---

### Proof Strategy Summary

1. **Start with algebraic foundations** (Theorems 1-3): Prove tropical matrix algebra is well-defined. Key tactic: `Finset.min'_eq_fold` + `ext` + direct computation.

2. **Build Kleene star theory** (Theorems 4-5): The Bellman equation and shortest-path characterization. Key tactic: induction on path length + `kleene_star_bellman_equation`.

3. **Establish cryptographic hardness intuition** (Theorems 6, 11, 12): Show the easy direction (repeated squaring) and the hard direction (non-commutativity, eigenvalue extraction). Key tactics: `omega`, `decide` for small cases, `by_contra` for uniqueness.

4. **Prove security bounds** (Theorems 7, 13-14, 16-17): Collision resistance, preimage bounds, birthday bound. Key tactics: `Finset.card` computations, pigeonhole arguments via `Finset.card_image_le`.

5. **Bridge to ML** (Theorems 8, 18): Lipschitz bounds and certified radii. Key tactics: induction on polynomial structure + `linarith` + `omega` for concrete bounds.

6. **Conjecture the hard open problem** (Theorem 15): State the exponential lower bound as a conjecture with the brute-force baseline proved.

### Revolutionary Significance

This work establishes the *algebraic foundations* of tropical cryptography — a field that doesn't yet exist in formal mathematics. The key insight is that tropical (min-plus) algebra provides hardness WITHOUT lattices: the combinatorial explosion comes from tropical hypersurface geometry, not Euclidean lattice problems. This means:

1. **Post-quantum security**: Tropical problems resist Shor's algorithm (no group structure to exploit) and Grover's algorithm (super-polynomial search space)
2. **Certified robustness**: The Lipschitz bound (Theorem 8) gives *exact* certified radii for tropical neural networks — no approximation needed
3. **New hardness assumption**: The Tropical Discrete Logarithm Problem (finding k from A^k) is a novel computational assumption requiring no number-theoretic structure

### FUTURE_DIRECTIONS.md

Aristotle MUST produce a structured FUTURE_DIRECTIONS.md containing:

1. **Tropical NTRU**: Construct a tropical analogue of the NTRU cryptosystem using tropical polynomial rings. Formalize the key generation, encryption, and decryption, prove correctness.

2. **Quantum Query Lower Bounds**: Prove that any quantum algorithm querying a tropical oracle requires Ω(n^{1/3}) queries to invert tropical matrix powers, establishing quantum resistance formally.

3. **Tropical Zero-Knowledge**: Construct a zero-knowledge proof system for the Tropical Discrete Logarithm Problem using the Kleene star as a commitment scheme.

4. **Certified Robustness for Tropical ReLU Networks**: Extend Theorem 18 to multi-layer tropical ReLU networks, proving that the certified radius composes multiplicatively across layers with explicit Lipschitz bounds.

5. **Tropical Isogeny Cryptography**: Develop a key exchange based on tropical isogenies (tropical endomorphisms preserving the tropical determinant), analogous to SIDH but with tropical elliptic curves.

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
            Visionary bridge between Tropical and Cryptography: Tropical one-way functions and min-plus cryptographic primitives. The hardness of tropical matrix inversion is a candidate computational assumption for post-quantum cryptography.

            ### Precise Mathematical Framing
            Establish a precise, provable connection between Tropical and Cryptography mathematics. Tropical one-way functions and min-plus cryptographic primitives. The hardness of tropical matrix inversion is a candidate computational assumption for post-quantum cryptography. Formalize the connection as a theorem with a specific, precise statement.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `universal_bridge_density_one` : theorem universal_bridge_density_one :
     (file: Cryptography/RosettaStone/MasterFormula.lean)
  2. `tropical_owf_quantum_resistance` : theorem tropical_owf_quantum_resistance {S : Type*} [AddCommMonoid S]
     (file: Cryptography/TropicalCryptoBridge.lean)
  3. `quantum_singleton_bound` : theorem quantum_singleton_bound (n k d : ℕ) (hk : k ≤ n)
     (file: Cryptography/BerggrenSymplecticCodes.lean)
  4. `tropical_owf_collision_bound` : theorem tropical_owf_collision_bound (m n B : ℕ) (hlt : m < n) (hB : 0 < B) :
     (file: Cryptography/PostIdempotentCrypto.lean)
  5. `post_quantum_estimation_hardness` : theorem post_quantum_estimation_hardness (k : ℕ)
     (file: MachineLearning/PadicInfoGeom/PadicCramerRao.lean)

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



Recent successful concepts: Quantum Group Cryptography: Drinfeld Double Key Exchange, R-Matrix Commitment Schemes, and Hopf-Galois Zero-Knowledge Protocols, Proof-Theoretic Cryptography: Cut-Elimination One-Way Functions, Normalization Commitment Schemes, and Proof-Object Zero-Knowledge Protocols, Neural Birkhoff Decomposition: Compositional Hopf Algebra, Backpropagation-Antipode Correspondence, and Residual Counterterm Structure


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
            @Algebra/Other/OctonionicTropicalApplications.lean
```lean
import Mathlib

/-! # CatalogBuild.Speculative.Other.OctonionicTropicalApplications

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 15
-/

noncomputable section

/-- [Section: # CatalogBuild.Speculative.Other.OctonionicTropicalApplications
Auto-generated from theorem catalog database.
Declarations: 15] -/
def associator {α : Type*} [AddGroup α] (mul : α → α → α) (a b c : α) : α :=
  mul (mul a b) c - mul a (mul b c)

-- For real numbers (associative), the associator is zero

/-- [Section: # CatalogBuild.Speculative.Other.OctonionicTropicalApplications
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 15] -/
theorem real_associator_zero (a b c : ℝ) :
    associator (· * ·) a b c = 0 := by
  simp [associator, mul_assoc]

-- Tropical max-plus is associative

theorem tropical_associator_zero (a b c : ℝ) :
    max (max a b) c = max a (max b c) :=
  max_assoc a b c

-- Error detection: nonzero associator means non-associative path

theorem error_detection_principle {α : Type*} [AddGroup α]
    (mul : α → α → α) (a b c : α)
    (h : associator mul a b c ≠ 0) :
    mul (mul a b) c ≠ mul a (mul b c) := by
  intro heq
  apply h
  simp [associator, heq]

def unitSphere (n : ℕ) : Set (Fin n → ℝ) :=
  {v | ∑ i, (v i) ^ 2 = 1}

-- The real Hopf map: (x, y) on S¹ ↦ x² - y²

def realHopfMap (v : Fin 2 → ℝ) : ℝ := (v 0) ^ 2 - (v 1) ^ 2

-- The Hopf map sends S¹ to [-1, 1]

theorem hopf_bounded (v : Fin 2 → ℝ) (hv : v ∈ unitSphere 2) :
    |realHopfMap v| ≤ 1 := by
  have h1 : (v 0) ^ 2 + (v 1) ^ 2 = 1 := by
    have := hv; simp [unitSphere, Fin.sum_univ_two] at this; exact this
  rw [realHopfMap, abs_le]
  constructor <;> nlinarith [sq_nonneg (v 0), sq_nonneg (v 1)]

-- The Hopf map is not constant on S¹

theorem hopf_nonconstant :
    ∃ v w : Fin 2 → ℝ, v ∈ unitSphere 2 ∧ w ∈ unitSphere 2 ∧
    realHopfMap v ≠ realHopfMap w := by
  refine ⟨![1, 0], ![0, 1], ?_, ?_, ?_⟩
  · simp [unitSphere, Fin.sum_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one]
  · simp [unitSphere, Fin.sum_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one]
  · simp [realHopfMap, Matrix.cons_val_zero, Matrix.cons_val_one]
    norm_num

theorem fano_line_count : fanoLines.length = 7 := by native_decide

-- Each point appears in exactly 3 lines

theorem fano_regularity_0 :
    (fanoLines.filter (fun t => t.1 = 0 ∨ t.2.1 = 0 ∨ t.2.2 = 0)).length = 3 := by
  native_decide

-- Fano plane diameter is at most 2

theorem fano_diameter_le_2 :
    ∀ (p q : Fin 7), p ≠ q →
    ∃ r : Fin 7, ∃ L₁ ∈ fanoLines, ∃ L₂ ∈ fanoLines,
      (L₁.1 = p ∨ L₁.2.1 = p ∨ L₁.2.2 = p) ∧
      (L₁.1 = r ∨ L₁.2.1 = r ∨ L₁.2.2 = r) ∧
      (L₂.1 = q ∨ L₂.2.1 = q ∨ L₂.2.2 = q) ∧
      (L₂.1 = r ∨ L₂.2.1 = r ∨ L₂.2.2 = r) := by
  native_decide

theorem triality_triple_gap (g₁ g₂ g₃ : ℝ) (h₁ : g₁ = 1) (h₂ : g₂ = 1) (h₃ : g₃ = 1) :
    g₁ + g₂ + g₃ = 3 := by linarith

theorem tropical_moufang (a b c : ℝ) :
    max (max a b) (max c a) = max a (max (max b c) a) := by
  simp [max_comm, max_left_comm]

-- One-way function: max preimage is not unique

theorem max_preimage_nonunique (c : ℝ) :
    ∃ a b a' b' : ℝ, max a b = c ∧ max a' b' = c ∧ (a ≠ a' ∨ b ≠ b') := by
  refine ⟨c, c - 1, c - 1, c, ?_, ?_, ?_⟩
  · exact max_eq_left (by linarith)
  · exact max_eq_right (by linarith)
  · left; linarith

-- Catalan number C₃ = 5 (number of bracketings of 4 elements)

theorem five_applications_summary :
    -- 1. Error correction: associator detects errors in non-associative algebras
    (∀ a b c : ℝ, max (max a b) c = max a (max b c)) ∧
    -- 2. Hopf fibration: dimension reduction preserves structure
    (∀ v : Fin 2 → ℝ, v ∈ OctonionicHopf.unitSphere 2 →
      |OctonionicHopf.realHopfMap v| ≤ 1) ∧
    -- 3. Fano routing: 7 lines
    (TropicalFanoRouting.fanoLines.length = 7) ∧
    -- 4. Spectral gap: projection eigenvalues are 0 or 1
    ((1 : ℝ) - 0 = 1) ∧
    -- 5. Moufang crypto: max preimage is non-unique
    (∀ c : ℝ, ∃ a b a' b' : ℝ, max a b = c ∧ max a' b' = c ∧ (a ≠ a' ∨ b ≠ b')) :=
  ⟨fun a b c => max_assoc a b c,
   fun v hv => OctonionicHopf.hopf_bounded v hv,
   TropicalFanoRouting.fano_line_count,
   by norm_num,
   TropicalMoufangCrypto.max_preimage_nonunique⟩

end
```

@Algebra/Tropical_p_adic_Valuation_Bounds_and_Lifting_the_Exponent_for_Fibonacci_Primitive_Divisors.lean
```lean
/-
# Fibonacci Primitive Divisors and Lifting-the-Exponent

This file formalizes key results about primitive prime divisors of Fibonacci numbers,
including:
- The Fibonacci entry point (rank of apparition) z(p)
- The characterization: p | F_n ↔ z(p) | n
- Growth bounds for Fibonacci numbers
- The Lifting-the-Exponent (LTE) framework for Fibonacci sequences
- Carmichael's theorem: F_n has a primitive prime divisor for n ∉ {1, 2, 6, 12}

## References
- Carmichael, R.D. "On the numerical factors of the arithmetic forms αⁿ ± βⁿ" (1913)
- Yabuta, M. "A simple proof of Carmichael's theorem on primitive divisors" (2001)
-/

import Mathlib

open scoped BigOperators Nat
open Nat

set_option maxHeartbeats 8000000
set_option maxRecDepth 4000

/-! ## Section 1: Basic Fibonacci Properties -/

/-
Fibonacci numbers are strictly monotone for indices ≥ 2.
-/
theorem fib_strict_mono_of_ge_two {m n : ℕ} (hm : 2 ≤ m) (hmn : m < n) :
    Nat.fib m < Nat.fib n := by
  exact?

/-
F_n ≥ n for n ≥ 5.
-/
theorem fib_ge_index (n : ℕ) (hn : 5 ≤ n) : n ≤ Nat.fib n := by
  -- We can prove this by induction on $n$.
  induction' n using Nat.strong_induction_on with n ih;
  rcases hn with ( _ | _ | _ | _ | _ | n ) <;> simp +arith +decide [ Nat.fib_add_two ] at *;
  grind

/-- F_n > 0 for n > 0. -/
theorem fib_pos_of_pos {n : ℕ} (hn : 0 < n) : 0 < Nat.fib n :=
  Nat.fib_pos.mpr hn

/-! ## Section 2: The Fibonacci Entry Point (Rank of Apparition)

For a prime p, the entry point z(p) is the smallest positive integer k
such that p | F_k. This exists because p | F_{p - (p/5)} by quadratic
reciprocity properties of Fibonacci numbers.
-/

open Classical in
/-- The Fibonacci entry point: the smallest positive k such that p | F_k.
    Returns 0 if no such k exists (which doesn't happen for primes ≥ 2). -/
noncomputable def fibEntryPoint (p : ℕ) : ℕ :=
  if h : ∃ k : ℕ, 0 < k ∧ p ∣ Nat.fib k then
    Nat.find h
  else
    0

/-
If the entry point is positive, then p divides F_{z(p)}.
-/
theorem fib_entry_point_dvd (p : ℕ) (h : ∃ k : ℕ, 0 < k ∧ p ∣ Nat.fib k) :
    p ∣ Nat.fib (fibEntryPoint p) := by
  unfold fibEntryPoint;
  split_ifs ; exact Nat.find_spec h |>.2

/-
The entry point is positive when a divisibility witness exists.
-/
theorem fib_entry_point_pos (p : ℕ) (h : ∃ k : ℕ, 0 < k ∧ p ∣ Nat.fib k) :
    0 < fibEntryPoint p := by
  unfold fibEntryPoint; aesop;

/-
The entry point is minimal: if p | F_k and k > 0, then z(p) ≤ k.
-/
theorem fib_entry_point_le (p k : ℕ) (hk : 0 < k) (hpk : p ∣ Nat.fib k)
    (h : ∃ k : ℕ, 0 < k ∧ p ∣ Nat.fib k) :
    fibEntryPoint p ≤ k := by
  unfold fibEntryPoint;
  split_ifs ; aesop

/-! ## Section 3: Entry Point Divides Index

The key characterization: p | F_n if and only if z(p) | n.
This follows from the strong divisibility property gcd(F_m, F_n) = F_{gcd(m,n)}.
-/

/-
**Entry point divisibility**: For a prime p with p | F_m for some m > 0,
    we have p | F_n ↔ z(p) | n (assuming n > 0).
-/
theorem fib_dvd_iff_entry_dvd (p n : ℕ) (hp : Nat.Prime p) (hn : 0 < n)
    (hex : ∃ k : ℕ, 0 < k ∧ p ∣ Nat.fib k) :
    p ∣ Nat.fib n ↔ fibEntryPoint p ∣ n := by
  -- By definition of z(p), we know that p | F_{z(p)} and z(p) is the smallest such positive integer.
  have hz : p ∣ Nat.fib (fibEntryPoint p) ∧ ∀ k : ℕ, 0 < k → p ∣ Nat.fib k → fibEntryPoint p ≤ k := by
    exact ⟨ fib_entry_point_dvd p hex, fun k hk hk' => fib_entry_point_le p k hk hk' hex ⟩;
  have h_div : ∀ k : ℕ, 0 < k → p ∣ Nat.fib k → fibEntryPoint p ∣ k := by
    intros k hk_pos hk_div
    have h_gcd : Nat.gcd (fibEntryPoint p) k = fibEntryPoint p := by
      refine' Nat.le_antisymm _ _;
      · exact Nat.le_of_dvd ( fib_entry_point_pos p hex ) ( Nat.gcd_dvd_left _ _ );
      · refine' hz.2 _ ( Nat.gcd_pos_of_pos_right _ hk_pos ) _;
        have h_gcd : Nat.gcd (Nat.fib (fibEntryPoint p)) (Nat.fib k) = Nat.fib (Nat.gcd (fibEntryPoint p) k) := by
          exact?;
        exact h_gcd ▸ Nat.dvd_gcd hz.1 hk_div;
    exact h_gcd ▸ Nat.gcd_dvd_right _ _;
  exact ⟨ h_div n hn, fun h => dvd_trans hz.1 ( Nat.fib_dvd _ _ h ) ⟩

/-! ## Section 4: Primitive Prime Divisors -/

/-- A prime p is a **primitive prime divisor** of F_n if p | F_n and
    p does not divide F_k for any 0 < k < n. Equivalently, z(p) = n. -/
def IsPrimitivePrimeDivisor (p n : ℕ) : Prop :=
  Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k : ℕ, 0 < k → k < n → ¬(p ∣ Nat.fib k)

/-- F_n **has a primitive prime divisor** if there exists a prime p with z(p) = n. -/
def HasPrimitivePrimeDivisor (n : ℕ) : Prop :=
  ∃ p : ℕ, IsPrimitivePrimeDivisor p n

/-
A prime is a primitive divisor of F_n iff its entry point equals n.
-/
theorem isPrimitivePrimeDivisor_iff_entry_eq (p n : ℕ) (hp : Nat.Prime p) (hn : 0 < n)
    (hex : ∃ k : ℕ, 0 < k ∧ p ∣ Nat.fib k) :
    IsPrimitivePrimeDivisor p n ↔ (p ∣ Nat.fib n ∧ fibEntryPoint p = n) := by
  constructor <;> intro h;
  · exact ⟨ h.2.1, le_antisymm ( fib_entry_point_le p n hn h.2.1 hex ) ( Nat.le_of_not_gt fun hlt => h.2.2 _ ( fib_entry_point_pos p hex ) hlt ( fib_entry_point_dvd p hex ) ) ⟩;
  · exact ⟨ hp, h.1, fun k hk₁ hk₂ hk₃ => by have := fib_entry_point_le p k hk₁ hk₃ hex; linarith ⟩

/-! ## Section 5: Growth Bounds for Fibonacci Numbers

These bounds are essential for proving that F_n has prime factors beyond
those of F_d for proper divisors d of n.
-/

/-
Exponential lower bound: F_n ≥ 2^((n-2)/2) for n ≥ 2.
-/
theorem fib_exponential_lower_bound (n : ℕ) (hn : 2 ≤ n) :
    2 ^ ((n - 2) / 2) ≤ Nat.fib n := by
  rcases Nat.even_or_odd' n with ⟨ k, rfl | rfl ⟩;
  · induction' k with k ih <;> norm_num [ Nat.fib_add_two, Nat.mul_succ ] at *;
    rcases k with ( _ | _ | k ) <;> simp_all +arith +decide [ Nat.fib_add_two, Nat.mul_succ ];
    grind;
-- ... (truncated, full file has 493 lines)
```

@AutoResearch/CompactTropicalChoquetRadon.lean
```lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Compact Tropical Choquet–Radon Representation

This file formalizes a Choquet–Radon representation theorem for upper-continuous
max-plus linear functionals on continuous real-valued functions over a compact
Hausdorff space.

## Main definitions

* `UCTropicalFunctional` — A structure encoding an upper-continuous, max-plus linear
  functional on `C(X, ℝ)` with values in `EReal`.
* `compactCapacity` — The compact-set capacity extracted from a functional.
* `infOnCompact` — The infimum of a continuous function on a compact set.
* `tropSupport` — The support of a tropical functional (smallest closed carrier).
* `supportedOn` — Predicate for a functional being supported on a set.
* `pushforwardFunctional` — Pushforward of a tropical functional along a continuous map.

## Main results

* `compactCapacity_empty` — Capacity of the empty compact set is ⊥.
* `compactCapacity_mono` — Capacity is monotone (larger sets, larger capacity).
* `compactCapacity_union` — Capacity is maxitive: `μ(K ∪ L) = max(μ(K), μ(L))`.
* `infOnCompact_le_eval` — The infimum on a compact set is bounded by point evaluation.
* `tropical_choquet_radon_le` — One direction of the representation:
    `⊔_K (μ(K) + inf_K f) ≤ Λ(f)`.
* `isClosed_tropSupport` — The tropical support is closed.
* `tropSupport_supported` — The functional is supported on its tropical support.
* `tropSupport_minimal` — The tropical support is the smallest closed carrier.
* `compactCapacity_pushforward_le` — Capacity is functorial under pushforward.

## Mathematical overview

In max-plus (tropical) algebra, addition is `max` and multiplication is `+`.
A max-plus linear functional Λ on continuous functions satisfies:
- `Λ(f ⊔ g) = Λ(f) ⊔ Λ(g)` (preserves tropical addition = max)
- `Λ(f + c) = Λ(f) + c` (equivariant under tropical scalar action = real translation)

The Choquet–Radon representation expresses such a functional as a "max-plus integral":
  `Λ(f) = ⊔_K (μ(K) + inf_K f)`
where `μ` is a maxitive capacity on compact sets.
-/

noncomputable section

open TopologicalSpace Set EReal

/-! ### The functional structure -/

/-- An upper-continuous tropical (max-plus linear) functional on `C(X, ℝ)`,
taking values in `EReal` (extended reals with ±∞).

The axioms encode:
- `monotone'`: monotonicity with respect to pointwise order
- `sup_preserving'`: max-plus additivity `Λ(f ⊔ g) = max(Λ(f), Λ(g))`
- `shift_equivariant'`: tropical scalar action `Λ(f + c) = Λ(f) + c`
- `normalized'`: normalization `Λ(0) = 0`

The upper-continuity axiom (`top_continuous'`) states that Λ commutes with
directed suprema of continuous functions, provided the supremum is itself continuous.
-/
structure UCTropicalFunctional (X : Type*) [TopologicalSpace X]
    [CompactSpace X] [T2Space X] where
  /-- The underlying function from continuous maps to extended reals. -/
  toFun : C(X, ℝ) → EReal
  /-- The functional is monotone. -/
  monotone' : Monotone toFun
  /-- The functional preserves binary suprema (max-plus additivity). -/
  sup_preserving' : ∀ f g : C(X, ℝ), toFun (f ⊔ g) = toFun f ⊔ toFun g
  /-- The functional is equivariant under translation by real constants. -/
  shift_equivariant' : ∀ (c : ℝ) (f : C(X, ℝ)),
    toFun (f + ContinuousMap.const X c) = toFun f + (c : EReal)
  /-- Upper continuity: Λ commutes with monotone suprema of continuous functions,
      provided the supremum is itself continuous. -/
  top_continuous' : ∀ {ι : Type*} [Nonempty ι] [Preorder ι] (s : ι → C(X, ℝ))
    (f : C(X, ℝ)),
    (∀ x, f x = ⨆ i, (s i x : EReal)) →
    Monotone s →
    toFun f = ⨆ i, toFun (s i)
  /-- Normalization: the zero function maps to zero. -/
  normalized' : toFun 0 = 0

variable {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]

namespace UCTropicalFunctional

instance : CoeFun (UCTropicalFunctional X) (fun _ => C(X, ℝ) → EReal) :=
  ⟨toFun⟩

@[simp]
theorem coe_toFun (Λ : UCTropicalFunctional X) (f : C(X, ℝ)) :
    Λ f = Λ.toFun f := rfl

theorem monotone (Λ : UCTropicalFunctional X) : Monotone Λ.toFun :=
  Λ.monotone'

theorem sup_preserving (Λ : UCTropicalFunctional X) (f g : C(X, ℝ)) :
    Λ (f ⊔ g) = Λ f ⊔ Λ g :=
  Λ.sup_preserving' f g

theorem shift_equivariant (Λ : UCTropicalFunctional X) (c : ℝ) (f : C(X, ℝ)) :
    Λ (f + ContinuousMap.const X c) = Λ f + (c : EReal) :=
  Λ.shift_equivariant' c f

theorem normalized (Λ : UCTropicalFunctional X) :
    Λ 0 = 0 := Λ.normalized'

/-- The functional maps constant functions to the constant. -/
theorem map_const (Λ : UCTropicalFunctional X) (c : ℝ) :
    Λ (ContinuousMap.const X c) = (c : EReal) := by
  have h := Λ.shift_equivariant c 0
  simp [Λ.normalized] at h
  exact h

/-- As constants decrease to -∞, the functional value goes to ⊥. -/
theorem map_const_neg_iInf (Λ : UCTropicalFunctional X) :
    ⨅ (n : ℕ), Λ (ContinuousMap.const X (-(n : ℝ))) = ⊥ := by
  simp [map_const]
  rw [iInf_eq_bot]
  intro b hb
  induction b with
    | bot => exact absurd rfl (ne_of_gt hb)
    | top => exact ⟨0, by simp⟩
    | coe r =>
      obtain ⟨n, hn⟩ := exists_nat_gt (-r)
      exact ⟨n, EReal.coe_lt_coe_iff.mpr (by linarith)⟩

end UCTropicalFunctional

/-! ### Compact-set capacity -/

/-- The compact-set capacity extracted from a tropical functional.
    `compactCapacity Λ K` is the infimum of `Λ(f)` over all continuous functions `f`
    that are nonneg (≥ 0) on `K`. -/
def compactCapacity (Λ : UCTropicalFunctional X) (K : Compacts X) : EReal :=
  sInf {a : EReal | ∃ f : C(X, ℝ), (∀ x ∈ (K : Set X), (0 : ℝ) ≤ f x) ∧ a = Λ.toFun f}

/-- The infimum of a continuous function over a compact set.
    When `K` is empty, this is `⊤` by convention (infimum of empty set). -/
def infOnCompact (f : C(X, ℝ)) (K : Compacts X) : EReal :=
  ⨅ x ∈ (K : Set X), (f x : EReal)

/-! ### Basic capacity properties -/

/-- Helper: the defining set for compactCapacity is nonempty. -/
-- ... (truncated, full file has 459 lines)
```

@Bridges/CupProductCryptography.lean
```lean
import Mathlib

/-!
# Cup-Product Pairing Cryptography

Algebraic foundations of topological pairing-based cryptography, where bilinear
pairings with graded commutativity serve as cryptographic primitives.

## Bridge: Algebraic Topology × Cryptography × Quantum Information

The cup product on simplicial cohomology is a bilinear map
`⌣ : Hᵖ(K; 𝔽_q) × Hʳ(K; 𝔽_q) → Hᵖ⁺ʳ(K; 𝔽_q)` satisfying graded
commutativity `a ⌣ b = (-1)^{pr} b ⌣ a`. This gives both symmetric (type-1)
and alternating (type-3) pairings from a single topological space depending
on degree parity — a property impossible for elliptic curve pairings.

## Main Results

* `BilinearCupPairing` — bilinear map abstraction for cup products
* `GradedCommPairing` — self-pairing with graded commutativity
* `cupPairingType` — classification by degree parity
* `neg_one_pow_even_eq_one` / `neg_one_pow_odd_eq_neg_one` — sign computation
* `cup_comm_of_sign_one` / `cup_anti_of_sign_neg_one` — type classification
* `CohomologicalIBEScheme` — identity-based encryption from cup products
* `ibe_decrypt_correct` — decryption correctness from bilinearity
* `BettiSecurityParams` — Betti number security parameter theorem
* `quantum_grover_security_degradation` — post-quantum security analysis
-/

open Finset BigOperators

noncomputable section

/-! ## Part I: Bilinear Pairings and Graded Commutativity -/

/-- A bilinear pairing between three modules over a commutative ring.
    Bridge: connects algebraic topology (cup product) to cryptography (bilinear maps). -/
structure BilinearCupPairing (R : Type*) [CommRing R]
    (M₁ M₂ M₃ : Type*)
    [AddCommGroup M₁] [Module R M₁]
    [AddCommGroup M₂] [Module R M₂]
    [AddCommGroup M₃] [Module R M₃] where
  cup : M₁ → M₂ → M₃
  map_add_left : ∀ (a b : M₁) (c : M₂), cup (a + b) c = cup a c + cup b c
  map_add_right : ∀ (a : M₁) (b c : M₂), cup a (b + c) = cup a b + cup a c
  map_smul_left : ∀ (r : R) (a : M₁) (b : M₂), cup (r • a) b = r • cup a b
  map_smul_right : ∀ (r : R) (a : M₁) (b : M₂), cup a (r • b) = r • cup a b

namespace BilinearCupPairing

variable {R : Type*} [CommRing R]
  {M₁ M₂ M₃ : Type*}
  [AddCommGroup M₁] [Module R M₁]
  [AddCommGroup M₂] [Module R M₂]
  [AddCommGroup M₃] [Module R M₃]
  (P : BilinearCupPairing R M₁ M₂ M₃)

/-- The cup product of zero on the left is zero.
    Derived from bilinearity — foundational for certified_robustness of pairing computations. -/
theorem cup_zero_left (b : M₂) : P.cup 0 b = 0 := by
  simpa using P.map_add_left 0 0 b

/-- The cup product of zero on the right is zero. -/
theorem cup_zero_right (a : M₁) : P.cup a 0 = 0 := by
  simpa using P.map_add_right a 0 0

/-- Negation passes through the left argument of the cup product. -/
theorem cup_neg_left (a : M₁) (b : M₂) : P.cup (-a) b = -P.cup a b := by
  have := P.map_smul_left (-1) a b; simp_all +decide [neg_smul]

/-- Negation passes through the right argument. -/
theorem cup_neg_right (a : M₁) (b : M₂) : P.cup a (-b) = -P.cup a b := by
  have := P.map_smul_right (-1) a b; aesop

/-- Subtraction in the left argument distributes.
    Bridge: connects homological algebra (chain complex maps) to lattice_crypto (error distribution). -/
theorem cup_sub_left (a₁ a₂ : M₁) (b : M₂) :
    P.cup (a₁ - a₂) b = P.cup a₁ b - P.cup a₂ b := by
  have := P.map_add_left (a₁ - a₂) a₂ b; simp_all +decide [sub_eq_add_neg]

/-- Subtraction in the right argument distributes. -/
theorem cup_sub_right (a : M₁) (b₁ b₂ : M₂) :
    P.cup a (b₁ - b₂) = P.cup a b₁ - P.cup a b₂ := by
  convert P.map_add_right a b₁ (-b₂) using 1 <;> simp +decide [sub_eq_add_neg]
  exact P.cup_neg_right a b₂ ▸ rfl

/-- Double scaling: (r * s) • cup = r • s • cup.
    Bridge: this multiplicative homomorphism property is what enables
    cryptographic key exchange via bilinear maps. -/
theorem cup_smul_smul_left (r s : R) (a : M₁) (b : M₂) :
    P.cup ((r * s) • a) b = r • P.cup (s • a) b := by
  rw [← P.map_smul_left, ← smul_smul]

/-- Iterated cup product with integer scaling for post_quantum_security analysis. -/
theorem cup_nsmul_left (n : ℕ) (a : M₁) (b : M₂) :
    P.cup (n • a) b = n • P.cup a b := by
  induction' n with n ih
  · simpa using P.cup_zero_left b
  · simp +decide [add_smul, ih, P.map_add_left]

end BilinearCupPairing

/-! ## Part II: Pairing Type Classification -/

/-- Classification of cup-product pairings by degree parity.
    Bridge: connects topology (degree of cohomology class) to cryptography (pairing type).
    Type-1 (symmetric) pairings enable efficient key agreement.
    Type-3 (alternating) pairings enable short signatures. -/
inductive PairingType where
  | symmetric   : PairingType  -- type-1: (-1)^{p·r} = 1
  | alternating : PairingType  -- type-3: (-1)^{p·r} = -1
  | mixed       : PairingType  -- one even, one odd degree
  deriving DecidableEq, Repr

/-- Classify the cup-product pairing type from degree parity.
    When both degrees are even, p·r is even so (-1)^{pr} = 1 → symmetric.
    When both are odd, p·r is odd so (-1)^{pr} = -1 → alternating. -/
def cupPairingType (p r : ℕ) : PairingType :=
  if p % 2 = 0 ∧ r % 2 = 0 then PairingType.symmetric
  else if p % 2 = 1 ∧ r % 2 = 1 then PairingType.alternating
  else PairingType.mixed

/-- Even-even degrees give symmetric (type-1) pairings. -/
theorem cupPairingType_even_even {p r : ℕ} (hp : p % 2 = 0) (hr : r % 2 = 0) :
    cupPairingType p r = PairingType.symmetric := by
  exact if_pos ⟨hp, hr⟩

/-- Odd-odd degrees give alternating (type-3) pairings. -/
theorem cupPairingType_odd_odd {p r : ℕ} (hp : p % 2 = 1) (hr : r % 2 = 1) :
    cupPairingType p r = PairingType.alternating := by
  unfold cupPairingType; aesop

/-- Mixed parity gives mixed type. -/
theorem cupPairingType_mixed {p r : ℕ} (hp : p % 2 = 0) (hr : r % 2 = 1) :
    cupPairingType p r = PairingType.mixed := by
  unfold cupPairingType; aesop

/-- The pairing type is symmetric in the degree arguments.
    This reflects that the cup product pairing H^p × H^r and H^r × H^p
    have the same type — crucial for bidirectional cryptographic protocols. -/
theorem cupPairingType_comm (p r : ℕ) : cupPairingType p r = cupPairingType r p := by
  unfold cupPairingType; aesop

/-! ## Part III: Sign Computations for Graded Commutativity -/

/-- When n is even, (-1)^n = 1 in any ring. This is the algebraic core of
    why even-degree cup products are symmetric. -/
theorem neg_one_pow_even_eq_one {R : Type*} [Ring R] {n : ℕ} (hn : Even n) :
    (-1 : R) ^ n = 1 := by
  exact Even.neg_one_pow hn
-- ... (truncated, full file has 684 lines)
```

@Cryptography/BerggrenAntiRigidity.lean
```lean
import Mathlib

/-!
# Berggren Semigroup: Anti-Involution Rigidity

We prove that the Berggren free semigroup inside GL₂(ℤ) is **completely disjoint from its
image under the adjugate anti-involution**, except at the identity. The adjugate of a 2×2
matrix M = !![a,b;c,d] is adj(M) = !![d,-b;-c,a], satisfying M * adj(M) = det(M) • I.
For invertible matrices (det = ±1), this equals ±M⁻¹, making it the natural matrix-level
"inverse" anti-involution.

## Main Results

* `evalBergWord_entry_00_pos` — top-left entry is always ≥ 1
* `evalBergWord_entry_10_nonneg` — bottom-left entry is always ≥ 0
* `evalBergWord_entry_00_ge_10` — top-left ≥ bottom-left (diagonal dominance)
* `adjugate2_anti_hom` — adjugate reverses multiplication
* `adjugate2_not_in_BergSemigroup` — **main theorem**: adjugate is never in the semigroup
* `berggren_inverse_rigidity` — no non-identity semigroup element has its inverse in the semigroup

## Mathematical Significance

This result upgrades the Berggren free-monoid injectivity theorem to a much stronger
structural statement: the semigroup occupies an "orientation-rigid" region of GL₂(ℤ) that
is completely separated from its image under the adjugate/inverse anti-involution. In
cryptographic applications, this means that reversing a Berggren-encoded transcript (taking
adjoints/inverses) can never accidentally produce a valid semigroup element, providing
anti-automorphism resistance for protocol canonicalization.

## References

The Berggren generators arise from the classical tree of primitive Pythagorean triples,
lifted to 2×2 integer matrices via the spin covering SL₂ → SO₂₁.
-/

set_option linter.unusedVariables false

/-! ## Generator Type and Word Evaluation -/

/-- The three Berggren generators. -/
inductive BergGen : Type
  | A | B | C
  deriving DecidableEq, Repr

/-- A Berggren word is a list of generators. -/
abbrev BergWord := List BergGen

/-- Action of each generator on the pair space (m, n). -/
def actGen (g : BergGen) (p : ℤ × ℤ) : ℤ × ℤ :=
  match g with
  | .A => (2 * p.1 - p.2, p.1)
  | .B => (2 * p.1 + p.2, p.1)
  | .C => (p.1 + 2 * p.2, p.2)

/-- The root pair (2, 1), corresponding to the identity matrix. -/
def rootPair : ℤ × ℤ := (2, 1)

/-- Pair-based evaluation of a Berggren word. -/
def evalPair : BergWord → ℤ × ℤ
  | [] => rootPair
  | g :: rest => actGen g (evalPair rest)

/-- A valid pair satisfies 0 < n < m. -/
def ValidPair (p : ℤ × ℤ) : Prop := 0 < p.2 ∧ p.2 < p.1

theorem rootPair_valid : ValidPair rootPair := ⟨by norm_num [rootPair], by norm_num [rootPair]⟩

theorem actGen_preserves_valid (g : BergGen) {p : ℤ × ℤ} (hp : ValidPair p) :
    ValidPair (actGen g p) := by
  obtain ⟨hn, hmn⟩ := hp
  cases g <;> constructor <;> simp only [actGen] <;> linarith

theorem evalPair_valid (w : BergWord) : ValidPair (evalPair w) := by
  induction w with
  | nil => exact rootPair_valid
  | cons g rest ih => exact actGen_preserves_valid g ih

theorem m_ge_three_after_gen (g : BergGen) {p : ℤ × ℤ} (hp : ValidPair p) :
    3 ≤ (actGen g p).1 := by
  obtain ⟨hn, hmn⟩ := hp; cases g <;> simp only [actGen] <;> linarith

theorem actGen_ne_root (g : BergGen) {p : ℤ × ℤ} (hp : ValidPair p) :
    actGen g p ≠ rootPair := by
  intro h; linarith [m_ge_three_after_gen g hp, show (actGen g p).1 = 2 from congr_arg Prod.fst h]

theorem actGen_injective (g : BergGen) : Function.Injective (actGen g) := by
  intro ⟨m₁, n₁⟩ ⟨m₂, n₂⟩ h
  cases g <;> simp only [actGen, Prod.mk.injEq] at h <;>
    exact Prod.ext (by linarith [h.1, h.2]) (by linarith [h.1, h.2])

theorem actGen_generator_determined {g₁ g₂ : BergGen} {p₁ p₂ : ℤ × ℤ}
    (hp₁ : ValidPair p₁) (hp₂ : ValidPair p₂)
    (h : actGen g₁ p₁ = actGen g₂ p₂) : g₁ = g₂ := by
  obtain ⟨hn₁, hmn₁⟩ := hp₁; obtain ⟨hn₂, hmn₂⟩ := hp₂
  have hf := congr_arg Prod.fst h; have hs := congr_arg Prod.snd h
  rcases g₁ with _ | _ | _ <;> rcases g₂ with _ | _ | _ <;>
    simp only [actGen] at hf hs <;> (first | rfl | linarith)

theorem actGen_unique_parent {g₁ g₂ : BergGen} {p₁ p₂ : ℤ × ℤ}
    (hp₁ : ValidPair p₁) (hp₂ : ValidPair p₂)
    (h : actGen g₁ p₁ = actGen g₂ p₂) : g₁ = g₂ ∧ p₁ = p₂ :=
  ⟨actGen_generator_determined hp₁ hp₂ h,
   actGen_injective g₁ (actGen_generator_determined hp₁ hp₂ h ▸ h)⟩

/-- **Freeness via pairs**: the pair evaluation is injective. -/
theorem evalPair_injective : Function.Injective evalPair := by
  intro w₁
  induction w₁ with
  | nil =>
    intro w₂ h; match w₂ with
    | [] => rfl
    | g :: rest => exact absurd h.symm (actGen_ne_root g (evalPair_valid rest))
  | cons g₁ rest₁ ih =>
    intro w₂ h; match w₂ with
    | [] => exact absurd h (actGen_ne_root g₁ (evalPair_valid rest₁))
    | g₂ :: rest₂ =>
      have ⟨hg, hp⟩ := actGen_unique_parent (evalPair_valid rest₁) (evalPair_valid rest₂) h
      subst hg; exact congrArg (g₁ :: ·) (ih hp)

/-! ## Matrix Formulation -/

/-- The 2×2 matrix for each Berggren generator. -/
def bergMat : BergGen → Matrix (Fin 2) (Fin 2) ℤ
  | .A => !![2, -1; 1, 0]
  | .B => !![2, 1; 1, 0]
  | .C => !![1, 2; 0, 1]

/-- Matrix evaluation of a Berggren word (left-multiplication). -/
def evalBergWord : BergWord → Matrix (Fin 2) (Fin 2) ℤ
  | [] => 1
  | g :: rest => bergMat g * evalBergWord rest

@[simp] theorem evalBergWord_nil : evalBergWord [] = 1 := rfl
@[simp] theorem evalBergWord_cons (g : BergGen) (w : BergWord) :
    evalBergWord (g :: w) = bergMat g * evalBergWord w := rfl

theorem evalBergWord_append (u v : BergWord) :
    evalBergWord (u ++ v) = evalBergWord u * evalBergWord v := by
  induction u with
  | nil => simp
  | cons g rest ih => simp [ih, Matrix.mul_assoc]

/-- Extract the pair invariant from a 2×2 matrix. -/
def pairOfMat (M : Matrix (Fin 2) (Fin 2) ℤ) : ℤ × ℤ :=
  (2 * M 0 0 + M 0 1, 2 * M 1 0 + M 1 1)

theorem pairOfMat_evalBergWord (w : BergWord) :
    pairOfMat (evalBergWord w) = evalPair w := by
  induction w with
  | nil => simp [pairOfMat, evalBergWord, evalPair, rootPair]
-- ... (truncated, full file has 404 lines)
```


### Catalog Reference Files
            @Algebra/Other/OctonionicTropicalApplications.lean
```lean
import Mathlib

/-! # CatalogBuild.Speculative.Other.OctonionicTropicalApplications

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 15
-/

noncomputable section

/-- [Section: # CatalogBuild.Speculative.Other.OctonionicTropicalApplications
Auto-generated from theorem catalog database.
Declarations: 15] -/
def associator {α : Type*} [AddGroup α] (mul : α → α → α) (a b c : α) : α :=
  mul (mul a b) c - mul a (mul b c)

-- For real numbers (associative), the associator is zero

/-- [Section: # CatalogBuild.Speculative.Other.OctonionicTropicalApplications
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 15] -/
theorem real_associator_zero (a b c : ℝ) :
    associator (· * ·) a b c = 0 := by
  simp [associator, mul_assoc]

-- Tropical max-plus is associative

theorem tropical_associator_zero (a b c : ℝ) :
    max (max a b) c = max a (max b c) :=
  max_assoc a b c

-- Error detection: nonzero associator means non-associative path

theorem error_detection_principle {α : Type*} [AddGroup α]
    (mul : α → α → α) (a b c : α)
    (h : associator mul a b c ≠ 0) :
    mul (mul a b) c ≠ mul a (mul b c) := by
  intro heq
  apply h
  simp [associator, heq]

def unitSphere (n : ℕ) : Set (Fin n → ℝ) :=
  {v | ∑ i, (v i) ^ 2 = 1}

-- The real Hopf map: (x, y) on S¹ ↦ x² - y²

def realHopfMap (v : Fin 2 → ℝ) : ℝ := (v 0) ^ 2 - (v 1) ^ 2

-- The Hopf map sends S¹ to [-1, 1]

theorem hopf_bounded (v : Fin 2 → ℝ) (hv : v ∈ unitSphere 2) :
    |realHopfMap v| ≤ 1 := by
  have h1 : (v 0) ^ 2 + (v 1) ^ 2 = 1 := by
    have := hv; simp [unitSphere, Fin.sum_univ_two] at this; exact this
  rw [realHopfMap, abs_le]
  constructor <;> nlinarith [sq_nonneg (v 0), sq_nonneg (v 1)]

-- The Hopf map is not constant on S¹

theorem hopf_nonconstant :
    ∃ v w : Fin 2 → ℝ, v ∈ unitSphere 2 ∧ w ∈ unitSphere 2 ∧
    realHopfMap v ≠ realHopfMap w := by
  refine ⟨![1, 0], ![0, 1], ?_, ?_, ?_⟩
  · simp [unitSphere, Fin.sum_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one]
  · simp [unitSphere, Fin.sum_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one]
  · simp [realHopfMap, Matrix.cons_val_zero, Matrix.cons_val_one]
    norm_num

theorem fano_line_count : fanoLines.length = 7 := by native_decide

-- Each point appears in exactly 3 lines

theorem fano_regularity_0 :
    (fanoLines.filter (fun t => t.1 = 0 ∨ t.2.1 = 0 ∨ t.2.2 = 0)).length = 3 := by
  native_decide

-- Fano plane diameter is at most 2

theorem fano_diameter_le_2 :
    ∀ (p q : Fin 7), p ≠ q →
    ∃ r : Fin 7, ∃ L₁ ∈ fanoLines, ∃ L₂ ∈ fanoLines,
      (L₁.1 = p ∨ L₁.2.1 = p ∨ L₁.2.2 = p) ∧
      (L₁.1 = r ∨ L₁.2.1 = r ∨ L₁.2.2 = r) ∧
      (L₂.1 = q ∨ L₂.2.1 = q ∨ L₂.2.2 = q) ∧
      (L₂.1 = r ∨ L₂.2.1 = r ∨ L₂.2.2 = r) := by
  native_decide

theorem triality_triple_gap (g₁ g₂ g₃ : ℝ) (h₁ : g₁ = 1) (h₂ : g₂ = 1) (h₃ : g₃ = 1) :
    g₁ + g₂ + g₃ = 3 := by linarith

theorem tropical_moufang (a b c : ℝ) :
    max (max a b) (max c a) = max a (max (max b c) a) := by
  simp [max_comm, max_left_comm]

-- One-way function: max preimage is not unique

theorem max_preimage_nonunique (c : ℝ) :
    ∃ a b a' b' : ℝ, max a b = c ∧ max a' b' = c ∧ (a ≠ a' ∨ b ≠ b') := by
  refine ⟨c, c - 1, c - 1, c, ?_, ?_, ?_⟩
  · exact max_eq_left (by linarith)
  · exact max_eq_right (by linarith)
  · left; linarith

-- Catalan number C₃ = 5 (number of bracketings of 4 elements)

theorem five_applications_summary :
    -- 1. Error correction: associator detects errors in non-associative algebras
    (∀ a b c : ℝ, max (max a b) c = max a (max b c)) ∧
    -- 2. Hopf fibration: dimension reduction preserves structure
    (∀ v : Fin 2 → ℝ, v ∈ OctonionicHopf.unitSphere 2 →
      |OctonionicHopf.realHopfMap v| ≤ 1) ∧
    -- 3. Fano routing: 7 lines
    (TropicalFanoRouting.fanoLines.length = 7) ∧
    -- 4. Spectral gap: projection eigenvalues are 0 or 1
    ((1 : ℝ) - 0 = 1) ∧
    -- 5. Moufang crypto: max preimage is non-unique
    (∀ c : ℝ, ∃ a b a' b' : ℝ, max a b = c ∧ max a' b' = c ∧ (a ≠ a' ∨ b ≠ b')) :=
  ⟨fun a b c => max_assoc a b c,
   fun v hv => OctonionicHopf.hopf_bounded v hv,
   TropicalFanoRouting.fano_line_count,
   by norm_num,
   TropicalMoufangCrypto.max_preimage_nonunique⟩

end
```

@Algebra/Tropical_p_adic_Valuation_Bounds_and_Lifting_the_Exponent_for_Fibonacci_Primitive_Divisors.lean
```lean
/-
# Fibonacci Primitive Divisors and Lifting-the-Exponent

This file formalizes key results about primitive prime divisors of Fibonacci numbers,
including:
- The Fibonacci entry point (rank of apparition) z(p)
- The characterization: p | F_n ↔ z(p) | n
- Growth bounds for Fibonacci numbers
- The Lifting-the-Exponent (LTE) framework for Fibonacci sequences
- Carmichael's theorem: F_n has a primitive prime divisor for n ∉ {1, 2, 6, 12}

## References
- Carmichael, R.D. "On the numerical factors of the arithmetic forms αⁿ ± βⁿ" (1913)
- Yabuta, M. "A simple proof of Carmichael's theorem on primitive divisors" (2001)
-/

import Mathlib

open scoped BigOperators Nat
open Nat

set_option maxHeartbeats 8000000
set_option maxRecDepth 4000

/-! ## Section 1: Basic Fibonacci Properties -/

/-
Fibonacci numbers are strictly monotone for indices ≥ 2.
-/
theorem fib_strict_mono_of_ge_two {m n : ℕ} (hm : 2 ≤ m) (hmn : m < n) :
    Nat.fib m < Nat.fib n := by
  exact?

/-
F_n ≥ n for n ≥ 5.
-/
theorem fib_ge_index (n : ℕ) (hn : 5 ≤ n) : n ≤ Nat.fib n := by
  -- We can prove this by induction on $n$.
  induction' n using Nat.strong_induction_on with n ih;
  rcases hn with ( _ | _ | _ | _ | _ | n ) <;> simp +arith +decide [ Nat.fib_add_two ] at *;
  grind

/-- F_n > 0 for n > 0. -/
theorem fib_pos_of_pos {n : ℕ} (hn : 0 < n) : 0 < Nat.fib n :=
  Nat.fib_pos.mpr hn

/-! ## Section 2: The Fibonacci Entry Point (Rank of Apparition)

For a prime p, the entry point z(p) is the smallest positive integer k
such that p | F_k. This exists because p | F_{p - (p/5)} by quadratic
reciprocity properties of Fibonacci numbers.
-/

open Classical in
/-- The Fibonacci entry point: the smallest positive k such that p | F_k.
    Returns 0 if no such k exists (which doesn't happen for primes ≥ 2). -/
noncomputable def fibEntryPoint (p : ℕ) : ℕ :=
  if h : ∃ k : ℕ, 0 < k ∧ p ∣ Nat.fib k then
    Nat.find h
  else
    0

/-
If the entry point is positive, then p divides F_{z(p)}.
-/
theorem fib_entry_point_dvd (p : ℕ) (h : ∃ k : ℕ, 0 < k ∧ p ∣ Nat.fib k) :
    p ∣ Nat.fib (fibEntryPoint p) := by
  unfold fibEntryPoint;
  split_ifs ; exact Nat.find_spec h |>.2

/-
The entry point is positive when a divisibility witness exists.
-/
theorem fib_entry_point_pos (p : ℕ) (h : ∃ k : ℕ, 0 < k ∧ p ∣ Nat.fib k) :
    0 < fibEntryPoint p := by
  unfold fibEntryPoint; aesop;

/-
The entry point is minimal: if p | F_k and k > 0, then z(p) ≤ k.
-/
theorem fib_entry_point_le (p k : ℕ) (hk : 0 < k) (hpk : p ∣ Nat.fib k)
    (h : ∃ k : ℕ, 0 < k ∧ p ∣ Nat.fib k) :
    fibEntryPoint p ≤ k := by
  unfold fibEntryPoint;
  split_ifs ; aesop

/-! ## Section 3: Entry Point Divides Index

The key characterization: p | F_n if and only if z(p) | n.
This follows from the strong divisibility property gcd(F_m, F_n) = F_{gcd(m,n)}.
-/

/-
**Entry point divisibility**: For a prime p with p | F_m for some m > 0,
    we have p | F_n ↔ z(p) | n (assuming n > 0).
-/
theorem fib_dvd_iff_entry_dvd (p n : ℕ) (hp : Nat.Prime p) (hn : 0 < n)
    (hex : ∃ k : ℕ, 0 < k ∧ p ∣ Nat.fib k) :
    p ∣ Nat.fib n ↔ fibEntryPoint p ∣ n := by
  -- By definition of z(p), we know that p | F_{z(p)} and z(p) is the smallest such positive integer.
  have hz : p ∣ Nat.fib (fibEntryPoint p) ∧ ∀ k : ℕ, 0 < k → p ∣ Nat.fib k → fibEntryPoint p ≤ k := by
    exact ⟨ fib_entry_point_dvd p hex, fun k hk hk' => fib_entry_point_le p k hk hk' hex ⟩;
  have h_div : ∀ k : ℕ, 0 < k → p ∣ Nat.fib k → fibEntryPoint p ∣ k := by
    intros k hk_pos hk_div
    have h_gcd : Nat.gcd (fibEntryPoint p) k = fibEntryPoint p := by
      refine' Nat.le_antisymm _ _;
      · exact Nat.le_of_dvd ( fib_entry_point_pos p hex ) ( Nat.gcd_dvd_left _ _ );
      · refine' hz.2 _ ( Nat.gcd_pos_of_pos_right _ hk_pos ) _;
        have h_gcd : Nat.gcd (Nat.fib (fibEntryPoint p)) (Nat.fib k) = Nat.fib (Nat.gcd (fibEntryPoint p) k) := by
          exact?;
        exact h_gcd ▸ Nat.dvd_gcd hz.1 hk_div;
    exact h_gcd ▸ Nat.gcd_dvd_right _ _;
  exact ⟨ h_div n hn, fun h => dvd_trans hz.1 ( Nat.fib_dvd _ _ h ) ⟩

/-! ## Section 4: Primitive Prime Divisors -/

/-- A prime p is a **primitive prime divisor** of F_n if p | F_n and
    p does not divide F_k for any 0 < k < n. Equivalently, z(p) = n. -/
def IsPrimitivePrimeDivisor (p n : ℕ) : Prop :=
  Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k : ℕ, 0 < k → k < n → ¬(p ∣ Nat.fib k)

/-- F_n **has a primitive prime divisor** if there exists a prime p with z(p) = n. -/
def HasPrimitivePrimeDivisor (n : ℕ) : Prop :=
  ∃ p : ℕ, IsPrimitivePrimeDivisor p n

/-
A prime is a primitive divisor of F_n iff its entry point equals n.
-/
theorem isPrimitivePrimeDivisor_iff_entry_eq (p n : ℕ) (hp : Nat.Prime p) (hn : 0 < n)
    (hex : ∃ k : ℕ, 0 < k ∧ p ∣ Nat.fib k) :
    IsPrimitivePrimeDivisor p n ↔ (p ∣ Nat.fib n ∧ fibEntryPoint p = n) := by
  constructor <;> intro h;
  · exact ⟨ h.2.1, le_antisymm ( fib_entry_point_le p n hn h.2.1 hex ) ( Nat.le_of_not_gt fun hlt => h.2.2 _ ( fib_entry_point_pos p hex ) hlt ( fib_entry_point_dvd p hex ) ) ⟩;
  · exact ⟨ hp, h.1, fun k hk₁ hk₂ hk₃ => by have := fib_entry_point_le p k hk₁ hk₃ hex; linarith ⟩

/-! ## Section 5: Growth Bounds for Fibonacci Numbers

These bounds are essential for proving that F_n has prime factors beyond
those of F_d for proper divisors d of n.
-/

/-
Exponential lower bound: F_n ≥ 2^((n-2)/2) for n ≥ 2.
-/
theorem fib_exponential_lower_bound (n : ℕ) (hn : 2 ≤ n) :
    2 ^ ((n - 2) / 2) ≤ Nat.fib n := by
  rcases Nat.even_or_odd' n with ⟨ k, rfl | rfl ⟩;
  · induction' k with k ih <;> norm_num [ Nat.fib_add_two, Nat.mul_succ ] at *;
    rcases k with ( _ | _ | k ) <;> simp_all +arith +decide [ Nat.fib_add_two, Nat.mul_succ ];
    grind;
-- ... (truncated, full file has 493 lines)
```

@AutoResearch/CompactTropicalChoquetRadon.lean
```lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Compact Tropical Choquet–Radon Representation

This file formalizes a Choquet–Radon representation theorem for upper-continuous
max-plus linear functionals on continuous real-valued functions over a compact
Hausdorff space.

## Main definitions

* `UCTropicalFunctional` — A structure encoding an upper-continuous, max-plus linear
  functional on `C(X, ℝ)` with values in `EReal`.
* `compactCapacity` — The compact-set capacity extracted from a functional.
* `infOnCompact` — The infimum of a continuous function on a compact set.
* `tropSupport` — The support of a tropical functional (smallest closed carrier).
* `supportedOn` — Predicate for a functional being supported on a set.
* `pushforwardFunctional` — Pushforward of a tropical functional along a continuous map.

## Main results

* `compactCapacity_empty` — Capacity of the empty compact set is ⊥.
* `compactCapacity_mono` — Capacity is monotone (larger sets, larger capacity).
* `compactCapacity_union` — Capacity is maxitive: `μ(K ∪ L) = max(μ(K), μ(L))`.
* `infOnCompact_le_eval` — The infimum on a compact set is bounded by point evaluation.
* `tropical_choquet_radon_le` — One direction of the representation:
    `⊔_K (μ(K) + inf_K f) ≤ Λ(f)`.
* `isClosed_tropSupport` — The tropical support is closed.
* `tropSupport_supported` — The functional is supported on its tropical support.
* `tropSupport_minimal` — The tropical support is the smallest closed carrier.
* `compactCapacity_pushforward_le` — Capacity is functorial under pushforward.

## Mathematical overview

In max-plus (tropical) algebra, addition is `max` and multiplication is `+`.
A max-plus linear functional Λ on continuous functions satisfies:
- `Λ(f ⊔ g) = Λ(f) ⊔ Λ(g)` (preserves tropical addition = max)
- `Λ(f + c) = Λ(f) + c` (equivariant under tropical scalar action = real translation)

The Choquet–Radon representation expresses such a functional as a "max-plus integral":
  `Λ(f) = ⊔_K (μ(K) + inf_K f)`
where `μ` is a maxitive capacity on compact sets.
-/

noncomputable section

open TopologicalSpace Set EReal

/-! ### The functional structure -/

/-- An upper-continuous tropical (max-plus linear) functional on `C(X, ℝ)`,
taking values in `EReal` (extended reals with ±∞).

The axioms encode:
- `monotone'`: monotonicity with respect to pointwise order
- `sup_preserving'`: max-plus additivity `Λ(f ⊔ g) = max(Λ(f), Λ(g))`
- `shift_equivariant'`: tropical scalar action `Λ(f + c) = Λ(f) + c`
- `normalized'`: normalization `Λ(0) = 0`

The upper-continuity axiom (`top_continuous'`) states that Λ commutes with
directed suprema of continuous functions, provided the supremum is itself continuous.
-/
structure UCTropicalFunctional (X : Type*) [TopologicalSpace X]
    [CompactSpace X] [T2Space X] where
  /-- The underlying function from continuous maps to extended reals. -/
  toFun : C(X, ℝ) → EReal
  /-- The functional is monotone. -/
  monotone' : Monotone toFun
  /-- The functional preserves binary suprema (max-plus additivity). -/
  sup_preserving' : ∀ f g : C(X, ℝ), toFun (f ⊔ g) = toFun f ⊔ toFun g
  /-- The functional is equivariant under translation by real constants. -/
  shift_equivariant' : ∀ (c : ℝ) (f : C(X, ℝ)),
    toFun (f + ContinuousMap.const X c) = toFun f + (c : EReal)
  /-- Upper continuity: Λ commutes with monotone suprema of continuous functions,
      provided the supremum is itself continuous. -/
  top_continuous' : ∀ {ι : Type*} [Nonempty ι] [Preorder ι] (s : ι → C(X, ℝ))
    (f : C(X, ℝ)),
    (∀ x, f x = ⨆ i, (s i x : EReal)) →
    Monotone s →
    toFun f = ⨆ i, toFun (s i)
  /-- Normalization: the zero function maps to zero. -/
  normalized' : toFun 0 = 0

variable {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]

namespace UCTropicalFunctional

instance : CoeFun (UCTropicalFunctional X) (fun _ => C(X, ℝ) → EReal) :=
  ⟨toFun⟩

@[simp]
theorem coe_toFun (Λ : UCTropicalFunctional X) (f : C(X, ℝ)) :
    Λ f = Λ.toFun f := rfl

theorem monotone (Λ : UCTropicalFunctional X) : Monotone Λ.toFun :=
  Λ.monotone'

theorem sup_preserving (Λ : UCTropicalFunctional X) (f g : C(X, ℝ)) :
    Λ (f ⊔ g) = Λ f ⊔ Λ g :=
  Λ.sup_preserving' f g

theorem shift_equivariant (Λ : UCTropicalFunctional X) (c : ℝ) (f : C(X, ℝ)) :
    Λ (f + ContinuousMap.const X c) = Λ f + (c : EReal) :=
  Λ.shift_equivariant' c f

theorem normalized (Λ : UCTropicalFunctional X) :
    Λ 0 = 0 := Λ.normalized'

/-- The functional maps constant functions to the constant. -/
theorem map_const (Λ : UCTropicalFunctional X) (c : ℝ) :
    Λ (ContinuousMap.const X c) = (c : EReal) := by
  have h := Λ.shift_equivariant c 0
  simp [Λ.normalized] at h
  exact h

/-- As constants decrease to -∞, the functional value goes to ⊥. -/
theorem map_const_neg_iInf (Λ : UCTropicalFunctional X) :
    ⨅ (n : ℕ), Λ (ContinuousMap.const X (-(n : ℝ))) = ⊥ := by
  simp [map_const]
  rw [iInf_eq_bot]
  intro b hb
  induction b with
    | bot => exact absurd rfl (ne_of_gt hb)
    | top => exact ⟨0, by simp⟩
    | coe r =>
      obtain ⟨n, hn⟩ := exists_nat_gt (-r)
      exact ⟨n, EReal.coe_lt_coe_iff.mpr (by linarith)⟩

end UCTropicalFunctional

/-! ### Compact-set capacity -/

/-- The compact-set capacity extracted from a tropical functional.
    `compactCapacity Λ K` is the infimum of `Λ(f)` over all continuous functions `f`
    that are nonneg (≥ 0) on `K`. -/
def compactCapacity (Λ : UCTropicalFunctional X) (K : Compacts X) : EReal :=
  sInf {a : EReal | ∃ f : C(X, ℝ), (∀ x ∈ (K : Set X), (0 : ℝ) ≤ f x) ∧ a = Λ.toFun f}

/-- The infimum of a continuous function over a compact set.
    When `K` is empty, this is `⊤` by convention (infimum of empty set). -/
def infOnCompact (f : C(X, ℝ)) (K : Compacts X) : EReal :=
  ⨅ x ∈ (K : Set X), (f x : EReal)

/-! ### Basic capacity properties -/

/-- Helper: the defining set for compactCapacity is nonempty. -/
-- ... (truncated, full file has 459 lines)
```

@Bridges/CupProductCryptography.lean
```lean
import Mathlib

/-!
# Cup-Product Pairing Cryptography

Algebraic foundations of topological pairing-based cryptography, where bilinear
pairings with graded commutativity serve as cryptographic primitives.

## Bridge: Algebraic Topology × Cryptography × Quantum Information

The cup product on simplicial cohomology is a bilinear map
`⌣ : Hᵖ(K; 𝔽_q) × Hʳ(K; 𝔽_q) → Hᵖ⁺ʳ(K; 𝔽_q)` satisfying graded
commutativity `a ⌣ b = (-1)^{pr} b ⌣ a`. This gives both symmetric (type-1)
and alternating (type-3) pairings from a single topological space depending
on degree parity — a property impossible for elliptic curve pairings.

## Main Results

* `BilinearCupPairing` — bilinear map abstraction for cup products
* `GradedCommPairing` — self-pairing with graded commutativity
* `cupPairingType` — classification by degree parity
* `neg_one_pow_even_eq_one` / `neg_one_pow_odd_eq_neg_one` — sign computation
* `cup_comm_of_sign_one` / `cup_anti_of_sign_neg_one` — type classification
* `CohomologicalIBEScheme` — identity-based encryption from cup products
* `ibe_decrypt_correct` — decryption correctness from bilinearity
* `BettiSecurityParams` — Betti number security parameter theorem
* `quantum_grover_security_degradation` — post-quantum security analysis
-/

open Finset BigOperators

noncomputable section

/-! ## Part I: Bilinear Pairings and Graded Commutativity -/

/-- A bilinear pairing between three modules over a commutative ring.
    Bridge: connects algebraic topology (cup product) to cryptography (bilinear maps). -/
structure BilinearCupPairing (R : Type*) [CommRing R]
    (M₁ M₂ M₃ : Type*)
    [AddCommGroup M₁] [Module R M₁]
    [AddCommGroup M₂] [Module R M₂]
    [AddCommGroup M₃] [Module R M₃] where
  cup : M₁ → M₂ → M₃
  map_add_left : ∀ (a b : M₁) (c : M₂), cup (a + b) c = cup a c + cup b c
  map_add_right : ∀ (a : M₁) (b c : M₂), cup a (b + c) = cup a b + cup a c
  map_smul_left : ∀ (r : R) (a : M₁) (b : M₂), cup (r • a) b = r • cup a b
  map_smul_right : ∀ (r : R) (a : M₁) (b : M₂), cup a (r • b) = r • cup a b

namespace BilinearCupPairing

variable {R : Type*} [CommRing R]
  {M₁ M₂ M₃ : Type*}
  [AddCommGroup M₁] [Module R M₁]
  [AddCommGroup M₂] [Module R M₂]
  [AddCommGroup M₃] [Module R M₃]
  (P : BilinearCupPairing R M₁ M₂ M₃)

/-- The cup product of zero on the left is zero.
    Derived from bilinearity — foundational for certified_robustness of pairing computations. -/
theorem cup_zero_left (b : M₂) : P.cup 0 b = 0 := by
  simpa using P.map_add_left 0 0 b

/-- The cup product of zero on the right is zero. -/
theorem cup_zero_right (a : M₁) : P.cup a 0 = 0 := by
  simpa using P.map_add_right a 0 0

/-- Negation passes through the left argument of the cup product. -/
theorem cup_neg_left (a : M₁) (b : M₂) : P.cup (-a) b = -P.cup a b := by
  have := P.map_smul_left (-1) a b; simp_all +decide [neg_smul]

/-- Negation passes through the right argument. -/
theorem cup_neg_right (a : M₁) (b : M₂) : P.cup a (-b) = -P.cup a b := by
  have := P.map_smul_right (-1) a b; aesop

/-- Subtraction in the left argument distributes.
    Bridge: connects homological algebra (chain complex maps) to lattice_crypto (error distribution). -/
theorem cup_sub_left (a₁ a₂ : M₁) (b : M₂) :
    P.cup (a₁ - a₂) b = P.cup a₁ b - P.cup a₂ b := by
  have := P.map_add_left (a₁ - a₂) a₂ b; simp_all +decide [sub_eq_add_neg]

/-- Subtraction in the right argument distributes. -/
theorem cup_sub_right (a : M₁) (b₁ b₂ : M₂) :
    P.cup a (b₁ - b₂) = P.cup a b₁ - P.cup a b₂ := by
  convert P.map_add_right a b₁ (-b₂) using 1 <;> simp +decide [sub_eq_add_neg]
  exact P.cup_neg_right a b₂ ▸ rfl

/-- Double scaling: (r * s) • cup = r • s • cup.
    Bridge: this multiplicative homomorphism property is what enables
    cryptographic key exchange via bilinear maps. -/
theorem cup_smul_smul_left (r s : R) (a : M₁) (b : M₂) :
    P.cup ((r * s) • a) b = r • P.cup (s • a) b := by
  rw [← P.map_smul_left, ← smul_smul]

/-- Iterated cup product with integer scaling for post_quantum_security analysis. -/
theorem cup_nsmul_left (n : ℕ) (a : M₁) (b : M₂) :
    P.cup (n • a) b = n • P.cup a b := by
  induction' n with n ih
  · simpa using P.cup_zero_left b
  · simp +decide [add_smul, ih, P.map_add_left]

end BilinearCupPairing

/-! ## Part II: Pairing Type Classification -/

/-- Classification of cup-product pairings by degree parity.
    Bridge: connects topology (degree of cohomology class) to cryptography (pairing type).
    Type-1 (symmetric) pairings enable efficient key agreement.
    Type-3 (alternating) pairings enable short signatures. -/
inductive PairingType where
  | symmetric   : PairingType  -- type-1: (-1)^{p·r} = 1
  | alternating : PairingType  -- type-3: (-1)^{p·r} = -1
  | mixed       : PairingType  -- one even, one odd degree
  deriving DecidableEq, Repr

/-- Classify the cup-product pairing type from degree parity.
    When both degrees are even, p·r is even so (-1)^{pr} = 1 → symmetric.
    When both are odd, p·r is odd so (-1)^{pr} = -1 → alternating. -/
def cupPairingType (p r : ℕ) : PairingType :=
  if p % 2 = 0 ∧ r % 2 = 0 then PairingType.symmetric
  else if p % 2 = 1 ∧ r % 2 = 1 then PairingType.alternating
  else PairingType.mixed

/-- Even-even degrees give symmetric (type-1) pairings. -/
theorem cupPairingType_even_even {p r : ℕ} (hp : p % 2 = 0) (hr : r % 2 = 0) :
    cupPairingType p r = PairingType.symmetric := by
  exact if_pos ⟨hp, hr⟩

/-- Odd-odd degrees give alternating (type-3) pairings. -/
theorem cupPairingType_odd_odd {p r : ℕ} (hp : p % 2 = 1) (hr : r % 2 = 1) :
    cupPairingType p r = PairingType.alternating := by
  unfold cupPairingType; aesop

/-- Mixed parity gives mixed type. -/
theorem cupPairingType_mixed {p r : ℕ} (hp : p % 2 = 0) (hr : r % 2 = 1) :
    cupPairingType p r = PairingType.mixed := by
  unfold cupPairingType; aesop

/-- The pairing type is symmetric in the degree arguments.
    This reflects that the cup product pairing H^p × H^r and H^r × H^p
    have the same type — crucial for bidirectional cryptographic protocols. -/
theorem cupPairingType_comm (p r : ℕ) : cupPairingType p r = cupPairingType r p := by
  unfold cupPairingType; aesop

/-! ## Part III: Sign Computations for Graded Commutativity -/

/-- When n is even, (-1)^n = 1 in any ring. This is the algebraic core of
    why even-degree cup products are symmetric. -/
theorem neg_one_pow_even_eq_one {R : Type*} [Ring R] {n : ℕ} (hn : Even n) :
    (-1 : R) ^ n = 1 := by
  exact Even.neg_one_pow hn
-- ... (truncated, full file has 684 lines)
```

@Cryptography/BerggrenAntiRigidity.lean
```lean
import Mathlib

/-!
# Berggren Semigroup: Anti-Involution Rigidity

We prove that the Berggren free semigroup inside GL₂(ℤ) is **completely disjoint from its
image under the adjugate anti-involution**, except at the identity. The adjugate of a 2×2
matrix M = !![a,b;c,d] is adj(M) = !![d,-b;-c,a], satisfying M * adj(M) = det(M) • I.
For invertible matrices (det = ±1), this equals ±M⁻¹, making it the natural matrix-level
"inverse" anti-involution.

## Main Results

* `evalBergWord_entry_00_pos` — top-left entry is always ≥ 1
* `evalBergWord_entry_10_nonneg` — bottom-left entry is always ≥ 0
* `evalBergWord_entry_00_ge_10` — top-left ≥ bottom-left (diagonal dominance)
* `adjugate2_anti_hom` — adjugate reverses multiplication
* `adjugate2_not_in_BergSemigroup` — **main theorem**: adjugate is never in the semigroup
* `berggren_inverse_rigidity` — no non-identity semigroup element has its inverse in the semigroup

## Mathematical Significance

This result upgrades the Berggren free-monoid injectivity theorem to a much stronger
structural statement: the semigroup occupies an "orientation-rigid" region of GL₂(ℤ) that
is completely separated from its image under the adjugate/inverse anti-involution. In
cryptographic applications, this means that reversing a Berggren-encoded transcript (taking
adjoints/inverses) can never accidentally produce a valid semigroup element, providing
anti-automorphism resistance for protocol canonicalization.

## References

The Berggren generators arise from the classical tree of primitive Pythagorean triples,
lifted to 2×2 integer matrices via the spin covering SL₂ → SO₂₁.
-/

set_option linter.unusedVariables false

/-! ## Generator Type and Word Evaluation -/

/-- The three Berggren generators. -/
inductive BergGen : Type
  | A | B | C
  deriving DecidableEq, Repr

/-- A Berggren word is a list of generators. -/
abbrev BergWord := List BergGen

/-- Action of each generator on the pair space (m, n). -/
def actGen (g : BergGen) (p : ℤ × ℤ) : ℤ × ℤ :=
  match g with
  | .A => (2 * p.1 - p.2, p.1)
  | .B => (2 * p.1 + p.2, p.1)
  | .C => (p.1 + 2 * p.2, p.2)

/-- The root pair (2, 1), corresponding to the identity matrix. -/
def rootPair : ℤ × ℤ := (2, 1)

/-- Pair-based evaluation of a Berggren word. -/
def evalPair : BergWord → ℤ × ℤ
  | [] => rootPair
  | g :: rest => actGen g (evalPair rest)

/-- A valid pair satisfies 0 < n < m. -/
def ValidPair (p : ℤ × ℤ) : Prop := 0 < p.2 ∧ p.2 < p.1

theorem rootPair_valid : ValidPair rootPair := ⟨by norm_num [rootPair], by norm_num [rootPair]⟩

theorem actGen_preserves_valid (g : BergGen) {p : ℤ × ℤ} (hp : ValidPair p) :
    ValidPair (actGen g p) := by
  obtain ⟨hn, hmn⟩ := hp
  cases g <;> constructor <;> simp only [actGen] <;> linarith

theorem evalPair_valid (w : BergWord) : ValidPair (evalPair w) := by
  induction w with
  | nil => exact rootPair_valid
  | cons g rest ih => exact actGen_preserves_valid g ih

theorem m_ge_three_after_gen (g : BergGen) {p : ℤ × ℤ} (hp : ValidPair p) :
    3 ≤ (actGen g p).1 := by
  obtain ⟨hn, hmn⟩ := hp; cases g <;> simp only [actGen] <;> linarith

theorem actGen_ne_root (g : BergGen) {p : ℤ × ℤ} (hp : ValidPair p) :
    actGen g p ≠ rootPair := by
  intro h; linarith [m_ge_three_after_gen g hp, show (actGen g p).1 = 2 from congr_arg Prod.fst h]

theorem actGen_injective (g : BergGen) : Function.Injective (actGen g) := by
  intro ⟨m₁, n₁⟩ ⟨m₂, n₂⟩ h
  cases g <;> simp only [actGen, Prod.mk.injEq] at h <;>
    exact Prod.ext (by linarith [h.1, h.2]) (by linarith [h.1, h.2])

theorem actGen_generator_determined {g₁ g₂ : BergGen} {p₁ p₂ : ℤ × ℤ}
    (hp₁ : ValidPair p₁) (hp₂ : ValidPair p₂)
    (h : actGen g₁ p₁ = actGen g₂ p₂) : g₁ = g₂ := by
  obtain ⟨hn₁, hmn₁⟩ := hp₁; obtain ⟨hn₂, hmn₂⟩ := hp₂
  have hf := congr_arg Prod.fst h; have hs := congr_arg Prod.snd h
  rcases g₁ with _ | _ | _ <;> rcases g₂ with _ | _ | _ <;>
    simp only [actGen] at hf hs <;> (first | rfl | linarith)

theorem actGen_unique_parent {g₁ g₂ : BergGen} {p₁ p₂ : ℤ × ℤ}
    (hp₁ : ValidPair p₁) (hp₂ : ValidPair p₂)
    (h : actGen g₁ p₁ = actGen g₂ p₂) : g₁ = g₂ ∧ p₁ = p₂ :=
  ⟨actGen_generator_determined hp₁ hp₂ h,
   actGen_injective g₁ (actGen_generator_determined hp₁ hp₂ h ▸ h)⟩

/-- **Freeness via pairs**: the pair evaluation is injective. -/
theorem evalPair_injective : Function.Injective evalPair := by
  intro w₁
  induction w₁ with
  | nil =>
    intro w₂ h; match w₂ with
    | [] => rfl
    | g :: rest => exact absurd h.symm (actGen_ne_root g (evalPair_valid rest))
  | cons g₁ rest₁ ih =>
    intro w₂ h; match w₂ with
    | [] => exact absurd h (actGen_ne_root g₁ (evalPair_valid rest₁))
    | g₂ :: rest₂ =>
      have ⟨hg, hp⟩ := actGen_unique_parent (evalPair_valid rest₁) (evalPair_valid rest₂) h
      subst hg; exact congrArg (g₁ :: ·) (ih hp)

/-! ## Matrix Formulation -/

/-- The 2×2 matrix for each Berggren generator. -/
def bergMat : BergGen → Matrix (Fin 2) (Fin 2) ℤ
  | .A => !![2, -1; 1, 0]
  | .B => !![2, 1; 1, 0]
  | .C => !![1, 2; 0, 1]

/-- Matrix evaluation of a Berggren word (left-multiplication). -/
def evalBergWord : BergWord → Matrix (Fin 2) (Fin 2) ℤ
  | [] => 1
  | g :: rest => bergMat g * evalBergWord rest

@[simp] theorem evalBergWord_nil : evalBergWord [] = 1 := rfl
@[simp] theorem evalBergWord_cons (g : BergGen) (w : BergWord) :
    evalBergWord (g :: w) = bergMat g * evalBergWord w := rfl

theorem evalBergWord_append (u v : BergWord) :
    evalBergWord (u ++ v) = evalBergWord u * evalBergWord v := by
  induction u with
  | nil => simp
  | cons g rest ih => simp [ih, Matrix.mul_assoc]

/-- Extract the pair invariant from a 2×2 matrix. -/
def pairOfMat (M : Matrix (Fin 2) (Fin 2) ℤ) : ℤ × ℤ :=
  (2 * M 0 0 + M 0 1, 2 * M 1 0 + M 1 1)

theorem pairOfMat_evalBergWord (w : BergWord) :
    pairOfMat (evalBergWord w) = evalPair w := by
  induction w with
  | nil => simp [pairOfMat, evalBergWord, evalPair, rootPair]
-- ... (truncated, full file has 404 lines)
```


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

Research domain: Cryptography
Research mode: prove
