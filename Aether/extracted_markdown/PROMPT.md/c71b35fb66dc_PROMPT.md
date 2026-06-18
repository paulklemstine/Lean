

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

## Pythagorean Holographic Duality: Discrete Bekenstein Bound, Ryu-Takayanagi Geodesic-Entropy Correspondence, and Primality Error-Correcting Tree Codes

### I. The Vision: Number-Theoretic Holography

The Berggren tree of primitive Pythagorean triples is a discrete hyperbolic space — a ternary Cayley tree with exponential volume growth and a Cantor-set boundary at infinity. This single fact unlocks a deep trifold correspondence:

**Number Theory ↔ AdS/CFT Holography ↔ Error-Correcting Codes**

The Berggren tree obeys an *exact* discrete Bekenstein bound (area = 2·volume + 1), supports a discrete Ryu-Takayanagi formula linking entanglement entropy to geodesic length, and its Hopf-algebraic structure yields a tree code with exponentially growing minimum distance — a candidate for post-quantum cryptographic primitives. Formalize and prove the foundational theorems establishing this correspondence.

---

### II. Definitions to Formalize (5+ Required)

```lean
-- 1. Finite connected subtree of the Berggren tree containing the root
structure BerggrenFiniteSubtree where
  carrier : Finset (BerggrenTree)
  root_mem : BerggrenTree.root ∈ carrier
  connected : ∀ {u v : BerggrenTree}, u ∈ carrier → v ∈ carrier → 
    ∃ path : List BerggrenTree, path.head? = some u ∧ path.getLast? = some v ∧
    ∀ w ∈ path, w ∈ carrier
  downward_closed : ∀ {u : BerggrenTree}, u ∈ carrier → 
    u ≠ BerggrenTree.root → BerggrenTree.parent u ∈ carrier

-- 2. Edge boundary (holographic screen)
def edgeBoundary (S : BerggrenFiniteSubtree) : Finset (BerggrenTree × BerggrenTree) :=
  S.carrier.biUnion fun u => 
    (Finset.univ : Finset (Fin 3)).image fun j => 
      (u, BerggrenTree.child u j) |>.filter fun (u,v) => v ∉ S.carrier

-- 3. Boundary at depth n (conformal boundary of discrete AdS)
def conformalBoundary (n : ℕ) : Finset BerggrenTree :=
  (Finset.univ : Finset (Fin n × Fin 3)).image fun p => 
    BerggrenTree.fromPath p

-- 4. Steiner tree (bulk minimal surface / geodesic)
def steinerTree (A : Finset BerggrenTree) : BerggrenFiniteSubtree :=
  -- Minimal connected subtree containing root and all vertices in A
  BerggrenFiniteSubtree.ofSet (A ∪ BerggrenTree.ancestors A)

-- 5. Berggren tree code (post-quantum error-correcting code)
structure BerggrenTreeCode (n : ℕ) where
  message : Fin n → Fin 3  -- path through tree
  codeword : Fin (n + 1) → (ℤ × ℤ × ℤ)  -- sequence of Pythagorean triples
  codeword_spec : ∀ k ≤ n, codeword k = 
    (List.range k).foldl (fun triple j => 
      berggren_matrix (message j) *ᵥ triple) (3, 4, 5)

-- 6. Shannon entropy on the conformal boundary
def shannonEntropy (n : ℕ) (A : Finset BerggrenTree) (hA : A ⊆ conformalBoundary n) : ℝ :=
  -(|A| : ℝ) / (3^n : ℝ) * Real.log (|A| : ℝ / (3^n : ℝ))
  - ((3^n - |A| : ℕ) : ℝ) / (3^n : ℝ) * Real.log (((3^n - |A| : ℕ) : ℝ) / (3^n : ℝ))

-- 7. Geodesic length (Ryu-Takayanagi bulk minimal surface area)
def geodesicLength (n : ℕ) (A : Finset BerggrenTree) : ℕ :=
  (steinerTree A).carrier.card - 1  -- number of edges in Steiner tree
```

---

### III. Theorems to Prove (10+ Required)

#### A. Discrete Bekenstein Bound — The Holographic Identity

**Theorem 1** (`berggren_holographic_identity`): *The exact area-volume relation for Berggren subtrees.*

```lean
theorem berggren_holographic_identity (S : BerggrenFiniteSubtree) :
    (edgeBoundary S).card = 2 * S.carrier.card + 1 := by
  -- Proof strategy: degree-sum argument. Each node in S has degree
  -- 4 in the infinite tree (except root with degree 3). Internal 
  -- edges contribute 2 to degree sum, boundary edges contribute 1.
  -- Σ deg(v) = 3 + 4(|S|-1) = 4|S|-1 = 2(|S|-1) + |∂S|
  -- Therefore |∂S| = 2|S| + 1. QED.
```

**Proof Strategy A (Degree-Sum)**: Sum degrees over all vertices in S. Root contributes 3, all others contribute 4. Total = 4|S| - 1. Internal edges counted twice, boundary edges once. So 2(|S|-1) + |∂S| = 4|S| - 1, giving |∂S| = 2|S| + 1.

**Proof Strategy B (Induction on |S|)**: Base case S = {root}: |∂S| = 3 = 2·1 + 1. ✓. Inductive step: add a leaf to S, increasing |S| by 1 and |∂S| by 2 (one boundary edge becomes internal, three new boundary edges appear, net change +2). Strategy A is cleaner — use it.

**Theorem 2** (`berggren_volume_from_area`): *Volume is determined by area — the holographic reconstruction principle.*

```lean
theorem berggren_volume_from_area (S : BerggrenFiniteSubtree) :
    S.carrier.card = ((edgeBoundary S).card - 1) / 2 := by
  -- Direct corollary of berggren_holographic_identity
  linarith [berggren_holographic_identity S]
```

**Theorem 3** (`berggren_hyperbolic_area_volume_ratio`): *The Berggren tree is hyperbolic: area/volume → 2.*

```lean
theorem berggren_hyperbolic_area_volume_ratio :
    ∀ ε > 0, ∃ N, ∀ n ≥ N, 
      let ball := BerggrenFiniteSubtree.ball n
      (edgeBoundary ball).card / ball.carrier.card < 2 + ε ∧
      (edgeBoundary ball).card / ball.carrier.card > 2 - ε := by
  -- |B_n| = (3^{n+1}-1)/2, |∂B_n| = 3^{n+1}
  -- Ratio = 3^{n+1} / ((3^{n+1}-1)/2) → 2
```

**Theorem 4** (`berggren_ball_volume_exact`): *Exact volume of geodesic balls.*

```lean
theorem berggren_ball_volume_exact (n : ℕ) :
    (BerggrenFiniteSubtree.ball n).carrier.card = (3^(n+1) - 1) / 2 := by
  -- Induction on n. Base: n=0, |{root}| = 1 = (3-1)/2. ✓
  -- Step: |B_{n+1}| = |B_n| + 3^{n+1} = (3^{n+1}-1)/2 + 3^{n+1} = (3^{n+2}-1)/2.
```

**Theorem 5** (`berggren_ball_boundary_exact`): *Exact boundary area of geodesic balls.*

```lean
theorem berggren_ball_boundary_exact (n : ℕ) :
    (edgeBoundary (BerggrenFiniteSubtree.ball n)).card = 3^(n+1) := by
  -- Each leaf at depth n has 3 children outside the ball.
  -- Number of leaves = 3^n. Boundary edges = 3 · 3^n = 3^{n+1}.
  -- Alternatively: 2|B_n| + 1 = 2·(3^{n+1}-1)/2 + 1 = 3^{n+1}.
```

#### B. Discrete Ryu-Takayanagi Formula — Geodesic-Entropy Correspondence

**Theorem 6** (`berggren_rt_geodesic_entropy_bound`): *Entanglement entropy is bounded by geodesic length — the discrete RT inequality.*

```lean
theorem berggren_rt_geodesic_entropy_bound (n : ℕ) (A : Finset BerggrenTree)
    (hA : A ⊆ conformalBoundary n) (hA_nonempty : A.Nonempty) :
    shannonEntropy n A hA ≤ (1 / Real.log 3) * (geodesicLength n A) * Real.log 2 := by
  -- Key insight: The Steiner tree γ(A) has |E(γ(A))| edges. Each edge in the
  -- ternary tree "covers" at most 3^k boundary vertices at depth k below it.
  -- So |A| ≤ 3^{depth(γ(A))} ≤ 3^{|E(γ(A))|+1}.
  -- Therefore log₃(|A|) ≤ |E(γ(A))| + 1.
  -- Shannon entropy H(A) ≤ log₂(|A|) + log₂(3^n / |A|) ≤ n · log₂(3).
  -- Combining: H(A) ≤ (log₂(3)) · |E(γ(A))| = (1/log(3)) · |E(γ)| · log(2).
```

**Theorem 7** (`berggren_rt_geodesic_entropy_lower_bound`): *RT lower bound — entropy requires geodesic length.*

```lean
theorem berggren_rt_geodesic_entropy_lower_bound (n : ℕ) (A : Finset BerggrenTree)
    (hA : A ⊆ conformalBoundary n) (hA_nonempty : A.Nonempty) :
    geodesicLength n A ≥ Real.log (|A| : ℝ) / Real.log 3 - 1 := by
  -- The Steiner tree must reach at least ⌈log₃(|A|)⌉ branching levels.
  -- Each branching level requires at least 1 edge.
  -- Therefore |E(γ(A))| ≥ ⌈log₃(|A|)⌉ ≥ log₃(|A|) - 1.
```

**Theorem 8** (`berggren_rt_single_path_equality`): *RT equality for single boundary vertex — the geodesic is a pure state.*

```lean
theorem berggren_rt_single_path_equality (n : ℕ) (v : BerggrenTree)
    (hv : v ∈ conformalBoundary n) :
    geodesicLength n {v} = n ∧ 
    shannonEntropy n {v} (singleton_subset_iff.mpr hv) = 
      (1/(3^n : ℝ)) * Real.log((3^n : ℝ)) := by
  -- For a single vertex, γ({v}) is the unique path from root to v.
  -- |E(γ({v}))| = n (depth of v).
  -- Entropy = (1/3^n) · log(3^n) = n · log(3) / 3^n.
```

#### C. Berggren Tree Code — Post-Quantum Error-Correcting Code

**Theorem 9** (`berggren_code_exponential_distance`): *Exponential minimum distance — the key cryptographic property.*

```lean
theorem berggren_code_exponential_distance (n : ℕ) (m₁ m₂ : Fin n → Fin 3)
    (h_ne : m₁ ≠ m₂) (k : ℕ) (hk : ∀ j < k, m₁ j = m₂ j) 
    (hk_div : m₁ k ≠ m₂ k) :
    ‖(BerggrenTreeCode.codeword_final n m₁).1 - (BerggrenTreeCode.codeword_final n m₂).1‖ ≥ 
      2^(n - k - 1) := by
  -- Two paths diverging at step k produce triples that differ by an 
  -- exponentially growing factor. The Berggren matrices have spectral 
  -- radius ρ ≥ 2+√3 ≈ 3.73 (for A₂). After n-k-1 further multiplications,
  -- the difference grows by at least ρ^{n-k-1} ≥ 2^{n-k-1}.
  -- Use induction on (n-k) with base case n-k=1 (adjacent triples differ).
```

**Theorem 10** (`berggren_code_rate_bound`): *Code rate is at least 1/3.*

```lean
theorem berggren_code_rate_bound (n : ℕ) :
    (n : ℝ) * Real.log 3 / ((n + 1) * 3 * Real.log (2 * 5^(n+1))) ≥ 1/3 := by
  -- Message space: {1,2,3}^n, so log₃(|messages|) = n.
  -- Codeword: sequence of n+1 triples, each triple (a,b,c) with c ≤ 5^{n+1}.
  -- Bits per triple: ≤ 3 · log₂(5^{n+1}) = 3(n+1)log₂(5).
  -- Rate ≥ n·log₂(3) / ((n+1)·3·log₂(5^{n+1})) → 1/3 as n → ∞.
  -- For finite n, use omega/linarith with explicit bounds.
```

**Theorem 11** (`berggren_hopf_antipode_decoding`): *The Hopf antipode provides certified decoding.*

```lean
theorem berggren_hopf_antipode_decoding (n : ℕ) (m : Fin n → Fin 3) :
    BerggrenHopfAlgebra.antipode (BerggrenTreeCode.encode n m) = 
    BerggrenTreeCode.syndrome n m := by
  -- The antipode S of the Berggren Hopf algebra satisfies S² = id.
  -- Encoding via comultiplication Δ, decoding via antipode S.
  -- S ∘ Δ = ε ⊗ id (the counit axiom), giving perfect syndrome extraction.
  -- Prove by induction on n using the coalgebra axioms.
```

**Theorem 12** (`berggren_lipschitz_certified_robustness`): *Certified robustness for classification via Berggren code distance — the ML connection.*

```lean
theorem berggren_lipschitz_certified_robustness (n : ℕ) (ε : ℝ) (hε : ε > 0) :
    ∃ δ > 0, ∀ m₁ m₂ : Fin n → Fin 3,
      ‖(BerggrenTreeCode.codeword_final n m₁).2.2 - 
       (BerggrenTreeCode.codeword_final n m₂).2.2‖ ≥ δ →
      HammingDist m₁ m₂ ≥ ⌈ε * (3^n : ℝ)⌉₊ := by
  -- Bridge: connects Pythagorean number theory to certified robustness in ML.
  -- If the hypotenuses differ by ≥ δ, the messages differ in ≥ ⌈ε·3^n⌉ positions.
  -- Use berggren_code_exponential_distance with δ = 2^{⌈ε·3^n⌉/3}.
```

---

### IV. Proof Architecture — Three Strategic Paths

**Strategy A (Degree-Sum + Induction)**: Prove the holographic identity by degree-sum (Theorem 1), then derive all volume/area results as corollaries. For the RT bound, use the Steiner tree branching factor (each node has ≥ 3 descendants at next level) to bound |A| ≤ 3^{|E(γ(A))|+1}. This is the most direct path — recommended for Theorems 1-5.

**Strategy B (Spectral Analysis of Berggren Matrices)**: For the code distance (Theorem 9), analyze the eigenvalues of A₁, A₂, A₃. The characteristic polynomial of A₂ is λ³ - 5λ² - 5λ + 1 = (λ+1)(λ² - 6λ + 1), giving spectral radius ρ₂ = 3 + 2√2 ≈ 5.83. For A₁ and A₃, similar analysis gives ρ₁, ρ₃ > 2. The minimum expansion factor after k steps is ≥ 2^k, giving exponential distance. Use `Eigenvalue` and `Matrix.spectralRadius` from Mathlib.

**Strategy C (Hopf Algebra Reconstruction)**: For Theorem 11, use the BerggrenHopfAlgebra structure from the catalog. The key identity is S(Δ(x)) = ε(x)·1 ⊗ 1 + (S ⊗ S)(Δ(x)), which follows from the antipode axiom. This gives perfect syndrome extraction for the tree code, analogous to how the antipode in the group algebra gives Fourier inversion for group codes.

---

### V. Cross-Domain Significance

**Physics (AdS/CFT)**: The identity |∂S| = 2|S| + 1 is the *first exact discrete Bekenstein bound* proven for a number-theoretic structure. It establishes the Berggren tree as a discrete AdS₃ spacetime where bulk volume is holographically encoded on the boundary — a precise mathematical realization of 't Hooft's holographic principle using only Pythagorean triples.

**Cryptography (Post-Quantum)**: The exponential code distance (Theorem 9) makes the Berggren tree code a candidate for post-quantum secure error correction. Unlike lattice-based codes (vulnerable to subexponential quantum attacks), the Berggren code's distance grows as 2^{n/3}, and the decoding problem (finding the correct path given a noisy triple) reduces to the Closest Vector Problem in a non-Archimedean norm — potentially harder than standard CVP.

**Machine Learning (Certified Robustness)**: Theorem 12 provides *certified robustness bounds* for classifiers operating on Berggren-encoded data. If two inputs produce hypotenuses differing by ≥ δ, the inputs differ in ≥ ⌈ε·3^n⌉ path positions — a Lipschitz certificate for the Berggren embedding. This bridges Pythagorean number theory to the certified robustness literature (Cohen et al. 2019).

---

### VI. Explicit Computational Bounds

| Quantity | Exact Formula | Asymptotic |
|---|---|---|
| Ball volume |B_n| | (3^{n+1} - 1)/2 | Θ(3^n) |
| Ball boundary |∂B_n| | 3^{n+1} | Θ(3^n) |
| Area/Volume ratio | ∂S\|/\|S| | 2 + 1/\|S| | → 2 |
| Code distance (min) | d_min(n) | ≥ 2^{⌊n/3⌋} | Ω(2^{n/3}) |
| Code rate | R(n) | ≥ (n log 3)/(3(n+1) log(5^{n+1})) | → 1/3 |
| RT constant | H(A)/\|E(γ(A))\| | ≤ log₂(3) | O(1) |
| Spectral radius (A₂) | ρ(A₂) | 3 + 2√2 | ≈ 5.83 |

---

### VII. Required: FUTURE_DIRECTIONS.md

After proving the above theorems, produce a structured FUTURE_DIRECTIONS.md with 3-5 concrete breakthrough-level next steps:

1. **Berggren Tensor Network**: Formalize the Berggren tree as a tensor network (MERA) and prove that the holographic identity implies an area-law for entanglement — connecting Pythagorean triples to quantum circuit complexity.

2. **Post-Quantum Berggren Lattice Crypto**: Construct a lattice-based cryptosystem where the secret key is a Berggren path and the public key is the final triple. Prove that breaking the system reduces to the Shortest Vector Problem in the Berggren lattice, with approximation factor 2^{n/3}.

3. **Tropical Ryu-Takayanagi**: Extend the geodesic-entropy correspondence to the tropical semiring (min-plus algebra), where the "geodesic" is the min-plus shortest path and "entropy" is tropical Shannon entropy. Prove a tropical RT formula: H_⊙(A) = min_{γ} |E(γ)|_⊙ where the minimization is over Steiner trees.

4. **Berggren Quantum Error Correction**: Construct a quantum stabilizer code from the Berggren Hopf algebra where logical qubits are encoded as superpositions over Berggren paths. Prove that the code distance equals the tree code distance ≥ 2^{n/3}.

5. **Certified Adversarial Robustness via Pythagorean Embeddings**: For neural networks with Berggren-encoded inputs, prove that any ℓ∞-perturbation of radius ε in the input space maps to a perturbation of radius ≥ ε·2^{n/3} in the Berggren embedding — giving exponential certified robustness.

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
            Open the field of number-theoretic holography by proving three foundational theorems that establish the Berggren tree of Pythagorean triples as a discrete hyperbolic space obeying the holographic principle. Theorem 1 (Holographic Bound): For the Berggren tree B with boundary ∂ₙB at depth n, any connected subtree S satisfies |∂ₙB ∩ S| ≤ 3^|∂S|, a discrete Bekenstein bound where boundary information is exponentially bounded by bulk surface area. Theorem 2 (Geodesic-Entropy Correspondence): For any subset A ⊆ ∂ₙB with minimal Steiner tree γ(A) connecting A through the bulk, the Shannon entropy H(A) equals (1/ln 3)·|E(γ(A))|, establishing a discrete Ryu-Takayanagi formula linking entanglement entropy to geodesic length. Theorem 3 (Primality Code): The Berggren tree defines a tree code Cₙ encoding messages as root-to-leaf paths with minimum distance d ≥ ⌈n/3⌉ and rate R ≥ 1/3, where the Berggren-Hopf coproduct provides the encoding map and the antipode provides certified decoding. This establishes that Pythagorean triple structure carries intrinsic error-correcting and holographic properties, bridging number theory, quantum gravity, and information theory.

            ### Precise Mathematical Framing
            Let B denote the Berggren tree: an infinite 3-regular rooted tree with root (3,4,5) and edges given by the Berggren matrices A₁,A₂,A₃ ∈ SL(3,ℤ). The boundary at depth n is ∂ₙB = {triple reachable by n Berggren steps from root}, with |∂ₙB| = 3ⁿ. The holographic bound |∂ₙB ∩ S| ≤ 3^|∂S| follows from the tree structure: any subtree with k boundary edges can contain at most 3^k depth-n nodes, since each boundary edge subtends at most 3^(n-d) nodes at depth n. The geodesic-entropy correspondence H(A) = (1/ln 3)·|E(γ(A))| arises because the Steiner tree on k uniformly random boundary nodes has expected size (ln 3)·H(A), by the tree entropy formula. The tree code Cₙ encodes k = ⌊n/3⌋ message symbols into length-n paths, achieving distance ⌈n/3⌉ by the Berggren tree's 3-ary branching structure, with the Hopf coproduct Δ: H → H⊗H providing systematic encoding and antipode S: H → H providing syndrome computation for decoding.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `root_triple_pythagorean` : theorem root_triple_pythagorean :
     (file: Pythagorean/Berggren/TropicalPAdicBerggren.lean)
  2. `post_quantum_tree_depth_bound` : theorem post_quantum_tree_depth_bound (d : ℕ) : 3 ^ d ≥ 2 ^ d :=
     (file: Tropical/MaxPlusLightCone.lean)
  3. `berggren_entry_growth_bound` : theorem berggren_entry_growth_bound (w : BerggrenWord) (i j : Fin 2) :
     (file: Pythagorean/BerggrenFareyCorrespondence.lean)
  4. `farey_bounded_away_from_boundary` : theorem farey_bounded_away_from_boundary :
     (file: Pythagorean/BerggrenModularCorrespondence/BerggrenCrossDomain.lean)
  5. `consecutive_depth_bound` : theorem consecutive_depth_bound (m : ℕ) (hm : 2 ≤ m) :
     (file: Pythagorean/Core/BerggrenLorentzComplexity.lean)

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



Recent successful concepts: Berggren-Hopf Algebra: Graded Coproduct Decomposition, Antipode-Factoring Correspondence, and Birkhoff Renormalization of Pythagorean Triples, Ultrametric Deep Learning: p-Adic Saddle Elimination, Valuation Generalization Bounds, and Hensel Pruning Certification, Algebraic Spacetime: Prime Spectrum Causal Structure, Zariski Holographic Reconstruction, and Ideal-Theoretic Conservation Laws


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

Research domain: Pythagorean
Research mode: prove
