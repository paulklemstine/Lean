

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

## TROPICAL POST-QUANTUM CRYPTOGRAPHY: The Algebraic Foundations of Min-Plus Key Exchange

### VISION

The min-plus semiring (ℝ ∪ {∞}, min, +) is the forgotten algebraic structure of cryptography. While classical public-key crypto builds on field arithmetic vulnerable to Shor's algorithm, the tropical semiring operates on a fundamentally different computational geometry — one where multiplication is addition, addition is minimization, and the "discrete logarithm" problem becomes a tropical matrix decomposition that resists quantum speedup. No quantum algorithm is known to break tropical key exchange faster than the classical O(n³) bound from Karp's algorithm.

**Your mission**: Build the complete formal theory of tropical key exchange. Prove the Stickel protocol achieves key agreement. Derive explicit post-quantum security bounds from the tropical spectral gap. Bridge to certified ML robustness through the piecewise-linear structure of tropical polynomial maps. This is the first verified post-quantum cryptographic primitive in any algebraic setting.

**Domains bridged**: Commutative Algebra ↔ Post-Quantum Cryptography ↔ Certified Machine Learning ↔ Quantum Hamiltonian Spectra

---

### DEFINITIONS (7+ new structures)

```lean
/-- A tropical polynomial in n variables: a formal min-plus expression
    min_i (cᵢ + dᵢ₁x₁ + ... + dᵢₙxₙ). Bridge: connects tropical algebra to
    piecewise-linear ReLU network activations in ML. -/
structure TropicalPoly (n : ℕ) where
  coeffs : Fin n → ℕ → ℝ   -- coeff (var index) (degree) = tropical coefficient
  degree : Fin n → ℕ       -- max degree per variable
  nonzero : ∃ i j, coeffs i j ≠ 0

/-- Tropical polynomial evaluation at a point x : Fin n → ℝ.
    This IS a ReLU network evaluation (bridge to ML). -/
def tropicalPolyEvalFn {n : ℕ} (p : TropicalPoly n) (x : Fin n → ℝ) : ℝ

/-- Tropical polynomial evaluation at a matrix: substitute matrix for variable.
    Key algebraic operation for the Stickel protocol. -/
def tropicalPolyEvalMat {n : ℕ} (p : TropicalPoly n) 
    (A : Matrix (Fin n) (Fin n) ℝ) : Matrix (Fin n) (Fin n) ℝ

/-- A commuting pair of tropical matrices — the public parameter
    that enables key exchange. Bridge: commuting operators also arise
    in quantum Hamiltonian systems (simultaneous observables). -/
structure TropicalCommutingPair (n : ℕ) where
  A : Matrix (Fin n) (Fin n) ℝ
  B : Matrix (Fin n) (Fin n) ℝ
  commute : ∀ i j k, min (A i k + B k j) (Finset.univ) = 
                    min (B i k + A k j) (Finset.univ)

/-- The Tropical Stickel Key Exchange Protocol.
    Post-quantum key exchange based on tropical polynomial evaluation.
    Security: recovering secret polynomials from public evaluations
    requires solving the Tropical Matrix Decomposition Problem,
    which has no known quantum speedup. -/
structure TropicalStickelProtocol (n : ℕ) where
  public : TropicalCommutingPair n
  alicePoly : TropicalPoly n × TropicalPoly n   -- secret (p, q)
  bobPoly : TropicalPoly n × TropicalPoly n     -- secret (r, s)
  alicePublic : Matrix (Fin n) (Fin n) ℝ         -- p(A) ⊕ q(B)
  bobPublic : Matrix (Fin n) (Fin n) ℝ           -- r(A) ⊕ s(B)

/-- Tropical eigenvalue: the maximum cycle mean of the weighted digraph.
    Bridge: this equals the ground state energy of the quantum Hamiltonian
    H = Σ Aᵢⱼ|i⟩⟨j| defined by the matrix weights. -/
def tropicalEigenvalue {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : ℝ

/-- Tropical spectral gap: difference between largest and second-largest
    cycle means. Controls post-quantum security level and
    Lipschitz constants for certified ML robustness. -/
def tropicalSpectralGap {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : ℝ

/-- Post-quantum security parameter: minimum operations to solve
    the Tropical Matrix Decomposition Problem.
    Bridge: connects algebraic hardness to cryptographic security. -/
def postQuantumSecurityLevel {n : ℕ} (cp : TropicalCommutingPair n) : ℝ
```

---

### THEOREMS (15+ theorems, diverse tactics, ZERO sorries)

**I. Tropical Polynomial Algebra (tactics: induction, field_simp, omega)**

```lean
/-- Tropical polynomial evaluation is a tropical semiring homomorphism.
    Bridge: algebra → tropical geometry -/
theorem tropical_eval_hom_semiring {n : ℕ} (p q : TropicalPoly n) 
    (A : Matrix (Fin n) (Fin n) ℝ) :
    tropicalPolyEvalMat (tropicalPolyAdd p q) A = 
    min (tropicalPolyEvalMat p A) (tropicalPolyEvalMat q A) ∧
    tropicalPolyEvalMat (tropicalPolyMul p q) A = 
    tropicalPolyEvalMat p A + tropicalPolyEvalMat q A
```

```lean
/-- Tropical monomial evaluation commutes with commuting matrices.
    Key lemma proved by induction on degree. -/
theorem tropical_mono_eval_commute {n : ℕ} {A B : Matrix (Fin n) (Fin n) ℝ}
    (h : tropicalMul A B = tropicalMul B A) (k : ℕ) :
    tropicalMul (tropicalPow A k) B = tropicalMul B (tropicalPow A k)
```

```lean
/-- CRITICAL: If A and B commute, then p(A) and q(B) commute for ANY
    tropical polynomials p, q. This is the algebraic engine of the
    Stickel protocol. Bridge: commuting observables in quantum mechanics. -/
theorem tropical_commuting_eval_commute {n : ℕ} (cp : TropicalCommutingPair n)
    (p q : TropicalPoly n) :
    tropicalMul (tropicalPolyEvalMat p cp.A) (tropicalPolyEvalMat q cp.B) =
    tropicalMul (tropicalPolyEvalMat q cp.B) (tropicalPolyEvalMat p cp.A)
```

**II. Protocol Correctness (tactics: rcases, by_contra, exact)**

```lean
/-- The Stickel protocol achieves key agreement: Alice and Bob compute
    identical shared keys. This is the foundational correctness theorem
    for post-quantum key exchange. -/
theorem stickel_key_agreement {n : ℕ} (proto : TropicalStickelProtocol n) :
    let (p, q) := proto.alicePoly
    let (r, s) := proto.bobPoly
    tropicalMul (tropicalPolyEvalMat p proto.public.A) 
      (tropicalMul (tropicalPolyEvalMat q proto.public.B)
        (tropicalMul (tropicalPolyEvalMat r proto.public.A) 
          (tropicalPolyEvalMat s proto.public.B))) =
    tropicalMul (tropicalPolyEvalMat r proto.public.A) 
      (tropicalMul (tropicalPolyEvalMat s proto.public.B)
        (tropicalMul (tropicalPolyEvalMat p proto.public.A) 
          (tropicalPolyEvalMat q proto.public.B))
```

```lean
/-- The shared key equals both Alice's and Bob's local computations.
    Bridge: protocol correctness ↔ algebraic commutativity -/
theorem stickel_shared_key_bilateral {n : ℕ} (proto : TropicalStickelProtocol n) :
    let (p, q) := proto.alicePoly
    let (r, s) := proto.bobPoly
    -- Alice computes: (p(A) ⊕ q(B)) ⊕ (r(A) ⊕ s(B))
    tropicalMul proto.alicePublic proto.bobPublic =
    -- Bob computes: (r(A) ⊕ s(B)) ⊕ (p(A) ⊕ q(B))  
    tropicalMul proto.bobPublic proto.alicePublic
```

```lean
/-- Uniqueness: the shared key is uniquely determined by the protocol
    parameters, not by the order of computation. -/
theorem stickel_shared_key_unique {n : ℕ} (proto : TropicalStickelProtocol n) :
    ∀ (computeOrder : List (TropicalPoly n)),
    sharedKeyFromOrder proto computeOrder = 
    sharedKeyFromOrder proto computeOrder.reverse
```

**III. Security Bounds (tactics: linarith, omega, by_contra, field_simp)**

```lean
/-- Tropical eigenvalue equals the maximum cycle mean (Karp's formula).
    Bridge: algebraic graph theory → tropical spectral theory.
    Computational bound: O(n³) via Karp's algorithm. -/
theorem tropical_eigenvalue_karp {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    (hn : 0 < n) :
    tropicalEigenvalue A = 
    Finset.sup' (Finset.univ : Finset (Fin n)) (fun j =>
      Finset.sup' (Finset.range n) (fun k =>
        (tropicalPathWeight A (j, k) - k) / n))
```

```lean
/-- MAIN SECURITY THEOREM: The tropical matrix decomposition hardness
    grows exponentially with the spectral gap.
    Post-quantum security: O(Δ^n) where Δ = spectral gap.
    Bridge: algebraic number theory → lattice cryptography -/
theorem tropical_decomp_hardness_exponential {n : ℕ} 
    (cp : TropicalCommutingPair n) (hn : 2 ≤ n)
    (hgap : 0 < tropicalSpectralGap cp.A) :
    postQuantumSecurityLevel cp ≥ (tropicalSpectralGap cp.A) ^ (n - 1)
```

```lean
/-- The tropical spectral gap bounds the shortest vector in the
    associated lattice embedding. Bridge: tropical geometry →
    lattice-based cryptography (SVP hardness). -/
theorem tropical_spectral_gap_bounds_svp {n : ℕ} 
    (A : Matrix (Fin n) (Fin n) ℝ) (hn : 0 < n)
    (hgap : 0 < tropicalSpectralGap A) :
    ∃ v : Fin n → ℝ, v ≠ 0 ∧ 
    ‖v‖ ≤ n * (tropicalEigenvalue A) ∧
    tropicalSpectralGap A ≤ ‖v‖ / (n : ℝ)
```

```lean
/-- Post-quantum security level for the Stickel protocol with
    explicit NIST-level security parameter.
    128-bit security requires spectral gap ≥ 2 and n ≥ 129. -/
theorem stickel_nist_security {n : ℕ} (proto : TropicalStickelProtocol n)
    (hn : 129 ≤ n) (hgap : 2 ≤ tropicalSpectralGap proto.public.A) :
    postQuantumSecurityLevel proto.public ≥ 2 ^ 128
```

**IV. Machine Learning Bridge (tactics: induction, linarith, exact)**

```lean
/-- Tropical polynomials are exactly piecewise-linear concave functions.
    Bridge: tropical algebra → ReLU network expressivity.
    Every tropical poly IS a shallow ReLU network. -/
theorem tropical_poly_piecewise_linear {n : ℕ} (p : TropicalPoly n) :
    ∃ (regions : Finset (Fin n → ℝ × ℝ)) (affineFns : Fin n → ℝ → ℝ),
    regions.card ≤ ∏ i : Fin n, (p.degree i + 1) ∧
    ∀ x : Fin n → ℝ, ∃ r ∈ regions, 
    tropicalPolyEvalFn p x = affineFns r x
```

```lean
/-- CERTIFIED ROBUSTNESS: Tropical polynomial maps have Lipschitz
    constant equal to the maximum absolute coefficient.
    Bridge: tropical algebra → certified ML robustness.
    Explicit bound: L = max |cᵢⱼ| over all coefficients. -/
theorem tropical_lipschitz_certified_robustness {n : ℕ} (p : TropicalPoly n) :
    let K := Finset.sup' p.coeffs (fun c => |c|)
    ∀ x y : Fin n → ℝ,
    |tropicalPolyEvalFn p x - tropicalPolyEvalFn p y| ≤ K * ‖x - y‖∞
```

```lean
/-- The tropical Lipschitz bound from crypto security implies
    certified adversarial robustness for the corresponding
    ReLU network classifier. Bridge: post-quantum crypto → ML safety. -/
theorem crypto_lipschitz_implies_robustness {n : ℕ} (p : TropicalPoly n)
    (x : Fin n → ℝ) (ε : ℝ) (hε : 0 < ε)
    (hL : tropicalLipschitzBound p < ε) :
    ∀ y : Fin n → ℝ, ‖y - x‖∞ < ε → 
    sign (tropicalPolyEvalFn p y) = sign (tropicalPolyEvalFn p x)
```

**V. Quantum Hamiltonian Bridge (tactics: rcases, linarith, field_simp)**

```lean
/-- The tropical eigenvalue equals the ground state energy of the
    quantum Hamiltonian H = Σᵢⱼ Aᵢⱼ |i⟩⟨j| in the tight-binding
    approximation. Bridge: tropical algebra → quantum physics. -/
theorem tropical_eigenvalue_quantum_hamiltonian {n : ℕ} 
    (A : Matrix (Fin n) (Fin n) ℝ) (hn : 0 < n) :
    tropicalEigenvalue A = 
    Inf {E : ℝ | ∃ (ψ : Fin n → ℂ), ‖ψ‖ = 1 ∧ 
    ⟨ψ, H A ψ⟩ = E}
```

```lean
/-- The tropical spectral gap equals the quantum energy gap
    (ground state to first excited state) for the tight-binding
    Hamiltonian. Bridge: post-quantum crypto → quantum phase transitions. -/
theorem tropical_spectral_gap_energy_gap {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ) (hn : 2 ≤ n) :
    tropicalSpectralGap A = 
    Inf {Δ : ℝ | ∃ E₁ E₂, E₁ < E₂ ∧ 
    E₁ ∈ spectrum (H A) ∧ E₂ ∈ spectrum (H A) ∧ E₂ - E₁ = Δ}
```

---

### PROOF STRATEGIES (5 approaches)

**Strategy A: Tropical Monomial Induction (MOST PROMISING for correctness)**
- Prove `tropical_mono_eval_commute` by induction on degree k
  - Base: k=0 is tropical identity (1-matrix), trivially commutes
  - Step: A^{k+1} ⊗ B = A ⊗ (A^k ⊗ B) = A ⊗ (B ⊗ A^k) = (A ⊗ B) ⊗ A^k = (B ⊗ A) ⊗ A^k = B ⊗ A^{k+1}
- Then `tropical_commuting_eval_commute` follows by linearity (tropical poly = min of monomials)
- `stickel_key_agreement` follows by rearranging using `tropical_commuting_eval_commute`
- **Why most promising**: Direct, constructive, no oracles needed

**Strategy B: Karp's Algorithm Structure (for eigenvalue theorems)**
- Define `tropicalPathWeight A (i, k)` = min weight of any path from i of length k
- Prove tropical eigenvalue = max_j lim_{k→∞} (tropicalPathWeight A (j,k) - k)/n
- Use the cycle structure: after n steps, optimal paths repeat the best cycle
- Key lemma: `cycle_decomposition_path` — every long optimal path decomposes into an initial segment plus repeated best cycles
- **Why it works**: Karp's algorithm is already O(n³) constructive

**Strategy C: Convex Geometric Subgradient (for Lipschitz bounds)**
- Tropical polynomials are concave piecewise-linear
- The tropical subgradient at any point is bounded by max |cᵢⱼ|
- Apply the fundamental theorem of Lipschitz analysis: concave PL functions have Lipschitz constant = max |subgradient|
- Key lemma: `tropical_subgradient_coefficient_bound`
- **Why it works**: Gives EXPLICIT bound K = max |cᵢⱼ|, not just existence

**Strategy D: Information-Theoretic Counting (for security bounds)**
- Count distinct tropical polynomial evaluations: with coefficients in [0, M] and degree d, there are ≥ M^{nd} distinct evaluations
- The tropical decomposition problem has ≥ M^{n²} possible decompositions
- Key lemma: `tropical_eval_injective_on_generic` — evaluation map is injective for generic matrices
- **Why it works**: Gives concrete lower bounds without computational assumptions

**Strategy E: Quantum Hamiltonian Reduction (for physics bridge)**
- Map tropical matrix A to tight-binding Hamiltonian H = Σ Aᵢⱼ |i⟩⟨j|
- Use variational principle: E₀ = inf_ψ ⟨ψ, Hψ⟩/⟨ψ,ψ⟩
- Key lemma: `tropical_ground_state_cycle` — ground state concentrated on the maximum-mean cycle
- **Why it works**: Connects tropical algebra to well-developed quantum mechanics

---

### SIGNIFICANCE

This work opens **three new fields** simultaneously:

1. **Tropical Post-Quantum Cryptography**: The first formally verified key exchange protocol with explicit security bounds against quantum adversaries. The tropical matrix decomposition problem has no known quantum speedup, making this a candidate for NIST post-quantum standardization.

2. **Tropical Certified ML**: The same tropical polynomial theory provides Lipschitz certificates for ReLU networks with EXPLICIT constants (K = max |cᵢⱼ|), enabling provably robust classifiers.

3. **Tropical Quantum Theory**: The identification of tropical eigenvalues with quantum Hamiltonian ground states creates a computational bridge between algebraic cryptography and quantum physics, enabling classical verification of quantum security claims.

**Computational impact**: Every bound is explicit — security levels in bits (2^128), Lipschitz constants (max |cᵢⱼ|), eigenvalue computation (O(n³)). This is not just theory; it's implementable.

---

### DEMANDED OUTPUT

Create these files as a complete mathematical narrative:

1. **`TropicalCrypto/Polynomial.lean`** (350+ lines) — Tropical polynomials, evaluation, semiring structure, 8+ theorems
2. **`TropicalCrypto/MatrixAlgebra.lean`** (400+ lines) — Tropical matrix operations, commuting pairs, eigenvalues, Karp's formula, 10+ theorems  
3. **`TropicalCrypto/KeyExchange.lean`** (350+ lines) — Stickel protocol, key agreement correctness, bilateral computation, 6+ theorems
4. **`TropicalCrypto/SecurityBounds.lean`** (400+ lines) — Spectral gap bounds, decomposition hardness, NIST security levels, 8+ theorems
5. **`TropicalCrypto/MLBridge.lean`** (350+ lines) — Lipschitz bounds, piecewise-linear structure, certified robustness, 6+ theorems
6. **`TropicalCrypto/QuantumBridge.lean`** (300+ lines) — Hamiltonian correspondence, energy gaps, phase transitions, 5+ theorems
7. **`FUTURE_DIRECTIONS.md`** — 5 concrete, specific, breakthrough-level next steps

**MANDATES**:
- ZERO sorries — every theorem fully proved
- Diverse tactics: induction, rcases, by_contra, omega, linarith, field_simp across all files
- Every theorem doc comment includes "Bridge: connects X to Y"
- Explicit computational bounds in every security/robustness theorem
- Typeclass abstraction where possible ([Semiring B], [LinearOrder α], etc.)
- Inventive theorem names (NOT *_comm, *_nonneg, *_eq_zero)
- Keywords in names: `post_quantum_security`, `lipschitz_certified_robustness`, `quantum_hamiltonian`, `tropical_decomp_hardness`, `nist_security_level`

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
            Research direction from LLM: algebra domain

            ### Precise Mathematical Framing
            for commuting normal operators



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `berggren_from_root` : theorem berggren_from_root :
     (file: Algebra/AutoResearch/DeepOpenProblems.lean)
  2. `factor_from_square_congruence_int` : theorem factor_from_square_congruence_int (N x y : ℤ)
     (file: Algebra/Core/ChimeraFactoring.lean)
  3. `pythagorean_from_stereo'` : theorem pythagorean_from_stereo' (p q : ℤ) :
     (file: Algebra/Core/StereographicBridge.lean)
  4. `factoring_from_pyth_params` : theorem factoring_from_pyth_params (N m n : ℕ)
     (file: Algebra/Factoring/GeometricNavigation.lean)
  5. `euclid_from_quat_params` : theorem euclid_from_quat_params (m n : ℤ) :
     (file: Algebra/Factoring/HurwitzQuaternions.lean)

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



Recent successful concepts: Prime-Spectral Schrödinger Bridge for Closure-Generated Proof Semirings via Entropic Countermodel Transport, Thermodynamic Sanov–Large-Deviation Completeness for Closure Self-Models via Prime-Spectral Free-Energy Rate Function, Max-Plus Hecke Algebras and Satake Isomorphism on Idempotent Prime Spectra


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

Research domain: Algebra
Research mode: prove
