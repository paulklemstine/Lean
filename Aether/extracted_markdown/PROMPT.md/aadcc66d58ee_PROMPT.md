

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

## YOUR ASSIGNMENT: Cup-Product Pairing Cryptography: Graded-Commutative Bilinear Maps from Simplicial Cohomology, Topological Identity-Based Encryption, and Betti-Number Security Bounds

**DOMAIN**: Bridges (Algebraic Topology × Cryptography × Quantum Information)

**CONCEPT**: Open the field of topological pairing-based cryptography by proving three foundational theorems that exploit the cup product on simplicial cohomology as a cryptographic bilinear map — the first construction where topological invariants replace number-theoretic hardness assumptions.

---

### THEOREM 1: Cup-Product Bilinearity and Graded Commutativity (TopologicalPairing.lean)

**Precise Statement**: For a finite simplicial complex `K` and a prime field `𝔽_q`, the cup product `⌣ : H^p(K; 𝔽_q) × H^q(K; 𝔽_q) → H^{p+q}(K; 𝔽_q)` is a computable, non-degenerate bilinear pairing satisfying graded commutativity `a ⌣ b = (-1)^{pq} b ⌣ a`. When both `p, q` are even, the pairing is symmetric (type-1 pairing); when both are odd, it is alternating (type-3 pairing). This dual-type property from a single topological space is impossible for elliptic curve pairings.

**Lean 4 Type Signatures**:

```lean
/-- The cup product as a graded bilinear map on simplicial cohomology -/
structure GradedCupProduct (q : ℕ) [Fact (Nat.Prime q)] where
  K : SimplicialComplex  -- finite simplicial complex
  cup : ∀ {p r : ℕ}, Cohomology K p (ZMod q) → Cohomology K r (ZMod q) → Cohomology K (p + r) (ZMod q)
  bilinear_left : ∀ {p r : ℕ} (a b : Cohomology K p (ZMod q)) (c : Cohomology K r (ZMod q)),
    cup (a + b) c = cup a c + cup b c
  bilinear_right : ∀ {p r : ℕ} (a : Cohomology K p (ZMod q)) (b c : Cohomology K r (ZMod q)),
    cup a (b + c) = cup a b + cup a c
  graded_comm : ∀ {p r : ℕ} (a : Cohomology K p (ZMod q)) (b : Cohomology K r (ZMod q)),
    cup a b = (-1 : ZMod q)^(p * r) • cup b a

/-- Type classification of cup-product pairings by parity -/
inductive PairingType where
  | symmetric   -- type-1: both degrees even
  | alternating -- type-3: both degrees odd
  | mixed       -- one even, one odd

def cupPairingType (p q : ℕ) : PairingType :=
  if p % 2 = 0 ∧ q % 2 = 0 then PairingType.symmetric
  else if p % 2 = 1 ∧ q % 2 = 1 then PairingType.alternating
  else PairingType.mixed

theorem cup_product_symmetric_type_one {q : ℕ} [Fact (Nat.Prime q)]
    {K : SimplicialComplex} {p r : ℕ} (h_even_p : p % 2 = 0) (h_even_r : r % 2 = 0)
    (a : Cohomology K p (ZMod q)) (b : Cohomology K r (ZMod q)) :
    (GradedCupProduct.cup a b : Cohomology K (p + r) (ZMod q)) =
    GradedCupProduct.cup b a := by
  -- Proof: (-1)^{p·r} = (-1)^{even} = 1, so graded commutativity gives a⌣b = b⌣a

theorem cup_product_alternating_type_three {q : ℕ} [Fact (Nat.Prime q)]
    {K : SimplicialComplex} {p r : ℕ} (h_odd_p : p % 2 = 1) (h_odd_r : r % 2 = 1)
    (a : Cohomology K p (ZMod q)) (b : Cohomology K r (ZMod q)) :
    (GradedCupProduct.cup a b : Cohomology K (p + r) (ZMod q)) =
    -GradedCupProduct.cup b a := by
  -- Proof: (-1)^{p·r} = (-1)^{odd} = -1, so a⌣b = -b⌣a

/-- Non-degeneracy via Poincaré duality: for closed orientable d-manifolds,
    the pairing H^p × H^{d-p} → H^d ≅ 𝔽_q is non-degenerate -/
theorem poincare_duality_nondegenerate {q : ℕ} [Fact (Nat.Prime q)]
    {K : SimplicialComplex} {d p : ℕ} (h_closed : IsClosedManifold K d)
    (h_orient : IsOrientable K d) :
    ∀ (a : Cohomology K p (ZMod q)),
      a ≠ 0 → ∃ (b : Cohomology K (d - p) (ZMod q)),
        GradedCupProduct.cup a b ≠ (0 : Cohomology K d (ZMod q)) := by
  -- Strategy: Poincaré duality gives isomorphism H^p ≅ H_{d-p},
  -- cap product with fundamental class gives the non-degenerate witness
```

**Proof Strategy (3 paths)**:

*Strategy A (Cochain-level computation)*: Define the cup product at the cochain level via `∪ : C^p × C^q → C^{p+q}` by `(f ∪ g)(σ) = f(σ|[v_0,...,v_p]) · g(σ|[v_p,...,v_{p+q}])`. Prove bilinearity by direct ring computation. Prove graded commutativity via the acyclic model theorem or explicit chain homotopy `D(f ∪ g - (-1)^{pq} g ∪ f) = ∂D + D∂`. **Most promising** because cochain-level computation avoids quotient reasoning and the chain homotopy is explicit.

*Strategy B (Universal coefficient + Künneth)*: Use the Künneth theorem to identify `H^*(K × K)` and pull back along the diagonal `Δ: K → K × K`. Graded commutativity follows from the twist isomorphism `τ: K × K → K × K` and `Δ = τ ∘ Δ`. **Elegant but requires substantial Künneth infrastructure.**

*Strategy C (Simplicial explicit computation)*: For a concrete simplicial complex (e.g., boundary of a simplex), compute the cup product explicitly on generators and verify graded commutativity by case analysis on simplex orderings. **Useful for base cases in an inductive proof on the number of simplices.**

**Recommended**: Strategy A for the general theorem, with Strategy C providing computational verification for key examples.

---

### THEOREM 2: Cohomological Identity-Based Encryption (TopologicalIBE.lean)

**Precise Statement**: Construct an IBE scheme where user identities are cohomology classes `α ∈ H^p(K; 𝔽_q)`, public parameters include generators `g ∈ H^p(K; 𝔽_q)`, `h ∈ H^q(K; 𝔽_q)`, the master secret is `s ∈ H^q(K; 𝔽_q)`, and private key extraction computes `d_α = α ⌣ s`. Encryption uses bilinearity: `e(g^r, α ⌣ h) = (g^r) ⌣ (α ⌣ h) = r · α · (g ⌣ h)` in `H^{p+q}(K; 𝔽_q)`.

**Lean 4 Type Signatures**:

```lean
/-- Identity space: cohomology classes as cryptographic identities -/
structure CohomologicalIdentity (q : ℕ) [Fact (Nat.Prime q)] where
  K : SimplicialComplex
  degree : ℕ
  class : Cohomology K degree (ZMod q)

/-- Master secret for the topological KGC -/
structure TopologicalMasterSecret (q : ℕ) [Fact (Nat.Prime q)] where
  K : SimplicialComplex
  secret_degree : ℕ
  secret : Cohomology K secret_degree (ZMod q)

/-- Public parameters for topological IBE -/
structure TopologicalIBEParams (q : ℕ) [Fact (Nat.Prime q)] where
  K : SimplicialComplex
  g : Cohomology K g_deg (ZMod q)  -- generator in H^p
  h : Cohomology K h_deg (ZMod q)  -- generator in H^q
  pairing_gen : Cohomology K (g_deg + h_deg) (ZMod q)  -- g ⌣ h
  g_deg h_deg : ℕ

/-- Private key derived from identity via cup product -/
def extractPrivateKey {q : ℕ} [Fact (Nat.Prime q)]
    (params : TopologicalIBEParams q) (ms : TopologicalMasterSecret q)
    (id : CohomologicalIdentity q) :
    Cohomology ms.K (id.degree + ms.secret_degree) (ZMod q) :=
  GradedCupProduct.cup id.class ms.secret

/-- Encryption via cup-product bilinear map evaluation -/
def topologicalEncrypt {q : ℕ} [Fact (Nat.Prime q)]
    (params : TopologicalIBEParams q) (id : CohomologicalIdentity q)
    (r : ZMod q) :
    Cohomology params.K (params.g_deg + id.degree + params.h_deg) (ZMod q) :=
  GradedCupProduct.cup (r • params.g) (GradedCupProduct.cup id.class params.h)

/-- Decryption recovers message via bilinearity -/
theorem topological_decrypt_correctness {q : ℕ} [Fact (Nat.Prime q)]
    (params : TopologicalIBEParams q) (ms : TopologicalMasterSecret q)
    (id : CohomologicalIdentity q) (h_secret : ms.secret = params.h)
    (r : ZMod q) :
    topologicalEncrypt params id r =
    r • GradedCupProduct.cup (GradedCupProduct.cup id.class params.h) params.g := by
  -- Key step: bilinearity gives g^r ⌣ (α ⌣ h) = r · (α ⌣ h ⌣ g)
  -- Then graded commutativity reorders if needed

/-- Computational Bilinear Cup-Product (CBCP) assumption:
    Given g, h, g^a, h^b, computing g^a ⌣ h^b is computationally hard -/
structure CBCPAssumption (q : ℕ) [Fact (Nat.Prime q)] where
  K : SimplicialComplex
  g : Cohomology K p (ZMod q)
  h : Cohomology K r (ZMod q)
  hardness_bound : ℕ  -- minimum operations to solve
  -- ∀ adversary A with < hardness_bound operations:
  -- Pr[A(g, h, a·g, b·h) = (a·g) ⌣ (b·h)] ≤ 1/q

/-- Security theorem: IBE security reduces to CBCP -/
theorem ibe_security_reduces_to_cbcp {q : ℕ} [Fact (Nat.Prime q)]
    (params : TopologicalIBEParams q) (assump : CBCPAssumption q) :
    ∃ (ε : ℝ), ε = 1 / (q : ℝ) ∧
    ∀ (adversary_ops : ℕ), adversary_ops < assump.hardness_bound →
      -- Any PPT adversary breaking IBE with advantage ε
      -- yields a CBCP solver with same advantage
      True := by  -- placeholder for full reduction proof
```

**Proof Strategy**:

1. **Lemma `cup_product_scalar_homomorphism`**: Prove `(r • a) ⌣ b = r • (a ⌣ b)` for `r : ZMod q`. This follows from left-bilinearity and the `ZMod q`-module structure.

2. **Lemma `encryption_decomposition`**: Prove `topologicalEncrypt params id r = r • (GradedCupProduct.cup id.class (GradedCupProduct.cup params.h params.g))` by unfolding definitions and applying bilinearity twice.

3. **Lemma `secret_key_matches_encryption`**: When `ms.secret = params.h`, prove `extractPrivateKey params ms id = id.class ⌣ params.h`, and show this factors through the encryption via `r • (id.class ⌣ h) ⌣ g`.

4. **Main theorem**: Chain the above to show decryption correctness: the private key `d_α = α ⌣ s = α ⌣ h` and the ciphertext `r · g ⌣ (α ⌣ h)` combine via `d_α ⌣ (r · g) = r · (α ⌣ h ⌣ g)`, recovering the message `r` when the top pairing `g ⌣ h` is a known generator of `H^{p+q}`.

5. **Security reduction**: Prove that any adversary distinguishing encryptions under two identities `α₁, α₂` with advantage `ε` yields a CBCP solver: use the adversary to distinguish `(a·g) ⌣ (b·h)` from random, breaking the bilinear cup-product assumption.

---

### THEOREM 3: Betti-Number Security Parameter Bounds (BettiSecurity.lean)

**Precise Statement**: The security level of a cup-product cryptosystem on `K` over `𝔽_q` is at least `⌊log₂(q)⌋/2` bits per cohomology dimension. With Betti numbers `β^n = dim_{𝔽_q} H^n(K; 𝔽_q)`, the total key space has dimension `Σ_n β^n`, yielding a topological security bound of `Ω(q^{Σ_{n even} β^n} · 2^{-n})` operations for exhaustive key search. This is the first theorem establishing a topological invariant as a cryptographic security parameter.

**Lean 4 Type Signatures**:

```lean
/-- Betti number as dimension of cohomology over 𝔽_q -/
noncomputable def bettiNumber (K : SimplicialComplex) (n : ℕ) (q : ℕ) [Fact (Nat.Prime q)] : ℕ :=
  Module.rank (ZMod q) (Cohomology K n (ZMod q)).toFinite

/-- Security level in bits from field size -/
def fieldSecurityBits (q : ℕ) [Fact (Nat.Prime q)] : ℝ :=
  (Nat.log 2 q) / 2

/-- Total key space dimension from even-degree Betti numbers -/
noncomputable def topologicalKeyDimension (K : SimplicialComplex) (q : ℕ) [Fact (Nat.Prime q]) : ℕ :=
  ∑ n in (Finset.range (K.dim + 1)).filter (fun n => n % 2 = 0), bettiNumber K n q

/-- Topological security bound: minimum operations to break via exhaustive search -/
noncomputable def topologicalSecurityBound (K : SimplicialComplex) (q : ℕ) [Fact (Nat.Prime q)] : ℝ :=
  (q : ℝ)^(topologicalKeyDimension K q) * fieldSecurityBits q

/-- Main security theorem: exhaustive search requires at least this many operations -/
theorem betti_number_security_lower_bound {q : ℕ} [Fact (Nat.Prime q)]
    {K : SimplicialComplex} (h_finite : K.finiteSimplices) :
    ∀ (search_algorithm : List (CohomologyClass K q) → CohomologyClass K q),
      ∃ (ops : ℕ), ops ≥ ⌈topologicalSecurityBound K q⌉_ℕ ∧
      -- Any algorithm must examine at least this many candidates
      True := by
  -- Strategy: key space has dimension Σ β^n, each element has q choices,
  -- so |key space| = q^{Σ β^n}, and log₂ of this gives the bit security

/-- Comparison theorem: topological security vs. elliptic curve security -/
theorem topological_vs_elliptic_security {q : ℕ} [Fact (Nat.Prime q)]
    {K : SimplicialComplex} (h_rich : topologicalKeyDimension K q ≥ 2) :
    topologicalSecurityBound K q ≥ (q : ℝ) * fieldSecurityBits q := by
  -- When Σ β^n ≥ 2, the topological security exceeds single-pairing EC security

/-- Quantum resistance: Grover's algorithm gives at most square-root speedup -/
theorem quantum_security_bound {q : ℕ} [Fact (Nat.Prime q)]
    {K : SimplicialComplex} :
    ∃ (quantum_speedup : ℝ), quantum_speedup = Real.sqrt 2 ∧
    topologicalSecurityBound K q / quantum_speedup ≥
      (q : ℝ)^(topologicalKeyDimension K q - 1) * fieldSecurityBits q / 2 := by
  -- Grover gives O(√N) search, so security reduces by factor √2 per bit
```

**Proof Strategy**:

1. **Lemma `cohomology_dimension_bound`**: Prove `0 < bettiNumber K n q ↔ H^n(K; 𝔽_q) ≠ 0`. Use the rank-nullity theorem for finite-dimensional vector spaces.

2. **Lemma `key_space_cardinality`**: Prove `|{α ∈ H^p(K; 𝔽_q)}| = q^{β^p}`. This is a standard fact: a vector space of dimension `d` over `𝔽_q` has `q^d` elements. Prove by induction on dimension.

3. **Lemma `exhaustive_search_lower_bound`**: Prove that any algorithm searching a space of size `N` must make at least `N/2` queries on average (decision tree argument). Use `by_contra` to show that fewer queries give probability < 1/2 of success.

4. **Main theorem**: Chain `key_space_cardinality` and `exhaustive_search_lower_bound` to get `topologicalSecurityBound K q = (q^{Σ β^n} · log₂(q)) / 2` bits of security.

5. **Quantum resistance**: Apply the BBBV theorem (Bennett, Bernstein, Brassier, Vazirani) to show Grover's algorithm is optimal for unstructured search, giving at most `O(√N)` speedup. This means the topological security bound degrades gracefully under quantum attack — unlike RSA which collapses completely.

---

### CROSS-DOMAIN CONNECTIONS

**Bridge 1: Algebraic Topology → Cryptography**: Cup products are the first topological operation used as a cryptographic primitive. The graded-commutativity property (absent in elliptic curve pairings) enables type-1 AND type-3 pairings from a single space, opening new cryptographic constructions.

**Bridge 2: Topology → Quantum Information**: The Betti number security bound connects topological invariants to quantum query complexity. The BBBV theorem bounds quantum search, and Betti numbers bound the search space — together they give post-quantum security guarantees from purely topological data.

**Bridge 3: Homological Algebra → Post-Quantum Cryptography**: Unlike RSA (broken by Shor's algorithm), topological pairing cryptography relies on the hardness of computing cup products in high-dimensional cohomology rings — a problem with no known quantum speedup beyond Grover's square-root improvement.

---

### REQUIRED DEFINITIONS (5+ new structures/instances)

1. `GradedCupProduct` — bilinear cup product with graded commutativity
2. `PairingType` — symmetric/alternating/mixed classification
3. `CohomologicalIdentity` — identity as cohomology class
4. `TopologicalIBEParams` / `TopologicalMasterSecret` — IBE scheme parameters
5. `CBCPAssumption` — computational bilinear cup-product hardness
6. `bettiNumber` — cohomological dimension as security parameter
7. `topologicalSecurityBound` — explicit security lower bound in operations
8. `fieldSecurityBits` — bit-level security from field size

### REQUIRED THEOREMS (10+, diverse tactics)

1. `cup_product_symmetric_type_one` — even-degree symmetry [induction on degree parity]
2. `cup_product_alternating_type_three` — odd-degree antisymmetry [ring computation]
3. `poincare_duality_nondegenerate` — non-degeneracy [by_contra + existence witness]
4. `cup_product_scalar_homomorphism` — scalar compatibility [field_simp]
5. `topological_decrypt_correctness` — IBE decryption works [calc + bilinearity]
6. `ibe_security_reduces_to_cbcp` — security reduction [rcases on adversary types]
7. `betti_number_security_lower_bound` — exhaustive search bound [by_contra + omega]
8. `topological_vs_elliptic_security` — comparison with EC security [linarith]
9. `quantum_security_bound` — post-quantum resistance [Real.sqrt properties]
10. `key_space_cardinality` — |H^p| = q^{β^p} [induction on dimension]
11. `graded_comm_implies_pairing_type` — classification theorem [omega + Nat.mod]
12. `cup_product_computable_bound` — cup product computable in O(n^{p+q}) [explicit complexity]

### APPLICATION KEYWORDS FOR IMPACT

- `post_quantum_security` — topological assumptions resist Shor's algorithm
- `lattice_free_cryptography` — no lattice reduction attacks apply
- `certified_bilinear_map` — the cup product is a *proven* bilinear map, not assumed
- `betti_number_hardness` — first topological invariant as security parameter
- `quantum_query_complexity` — BBBV bound applied to topological key space

### EXPLICIT COMPUTATIONAL BOUNDS

- Cup product computation: `O(|K|^{p+q+1})` where `|K|` = number of simplices
- Key extraction: `O(β^p · β^q)` field operations
- Encryption: `O(β^p · β^{p+q})` field operations
- Exhaustive search lower bound: `Ω(q^{Σ_{n even} β^n})` operations
- Quantum exhaustive search: `Ω(q^{Σ_{n even} β^n / 2})` operations (Grover)
- Security bits: `⌊(Σ_{n even} β^n) · log₂(q) / 2⌋` bits

---

**FAILURE MODE**: If full IBE security reduction is intractable, prove the strongest available lemma — ideally `topological_decrypt_correctness` (the bilinear decryption identity) or `betti_number_security_lower_bound` (the information-theoretic bound), both of which require genuine mathematical content and do not depend on computational assumptions.

**FUTURE_DIRECTIONS**: After completing this work, produce a `FUTURE_DIRECTIONS.md` with:
1. Topological NIZK proofs: zero-knowledge from cup-product relations
2. Multilinear topological maps: iterated cup products `H^{p₁} × ... × H^{pₖ} → H^{Σpᵢ}` for k-linear assumptions
3. Topological aggregate signatures: Betti number amplification via connected sums `K₁ # K₂`
4. Persistent homology key rotation: stability theorems for key update under filtration
5. Topological MPC: secret sharing on cohomology groups with reconstruction via Mayer-Vietoris

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
            Open the field of topological pairing-based cryptography by proving three foundational theorems. (1) Cup-Product Bilinearity and Non-Degeneracy Theorem: For a finite simplicial complex K and prime q, the cup product ⌣: H^p(K;𝔽_q) × H^q(K;𝔽_q) → H^{p+q}(K;𝔽_q) is a computable, non-degenerate bilinear pairing with graded-commutativity a⌣b = (-1)^{pq} b⌣a. When both p,q are even the pairing is symmetric (type-1), when both are odd it is alternating (type-3), enabling both pairing types from a single topological space — a property no elliptic curve pairing possesses. (2) Cohomological Identity-Based Encryption Theorem: Construct an IBE scheme where user identities are cohomology classes α ∈ H^p(K;𝔽_q), public parameters include generators g ∈ H^p, h ∈ H^q, and the private key generator extracts d_α = α⌣s for master secret s ∈ H^q. Encryption uses e(g^r, α⌣h) = (g^r)⌣(α⌣h) = α·r·(g⌣h) by bilinearity. Security reduces to the Computational Bilinear Cup-Product (CBCP) assumption: given g, h, g^a, h^b, computing g^a⌣h^b is hard. (3) Betti-Number Security Parameter Theorem: The security level of a cup-product cryptosystem on K over 𝔽_q is at least ⌊log₂(q)⌋/2 bits, with Betti numbers β^n as security multipliers: the key space dimension is ∏_{n even} β^n, yielding a topological security bound of q^{Σ_{n even} β^n·⌊log₂(q)⌋/2} operations. This establishes the first topological invariant (Betti numbers) as a cryptographic security parameter, enabling security proofs from topological rather than number-theoretic assumptions.

            ### Precise Mathematical Framing
            Pairing-based cryptography revolutionized the field via the Weil pairing on elliptic curves, enabling identity-based encryption, short signatures, and attribute-based crypto. The cup product on simplicial cohomology provides an entirely new family of bilinear pairings with distinct properties: (i) graded commutativity gives both symmetric and alternating pairings from one space depending on degree parity; (ii) functoriality under continuous maps f*: H*(L) → H*(K) enables key evolution via topological morphisms; (iii) the Künneth formula H*(K×L) ≅ H*(K) ⊗ H*(L) enables composable product-space cryptosystems. The core insight is that Poincaré duality on a closed orientable n-manifold M provides a canonical non-degenerate pairing H^p(M;𝔽_q) × H^{n-p}(M;𝔽_q) → H^n(M;𝔽_q) ≅ 𝔽_q, which is a perfect pairing suitable for cryptographic use. This bridges Algebra's 4487 declarations (homological algebra, cohomology, ring structures) with Cryptography's 737 declarations (key exchange, hardness assumptions) — currently no bridge exists between these domains despite sharing 17 structural keywords.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `prime_bound_of_admissible_code` : theorem prime_bound_of_admissible_code
     (file: Bridges/LawvereRateDistortionDuality.lean)
  2. `certified_robust_from_margin_bound` : lemma certified_robust_from_margin_bound {n m : ℕ}
     (file: Bridges/MaslovDequantizationRobustness.lean)
  3. `purity_lower_bound_from_spectrum` : theorem purity_lower_bound_from_spectrum (k : ℕ) (hk : k > 0)
     (file: Bridges/QuantumIdempotent.lean)
  4. `exists_least_bisimulation_metric_finite` : theorem exists_least_bisimulation_metric_finite
     (file: Bridges/BisimulationMetric.lean)
  5. `e8_even_property` : theorem e8_even_property (k : ℕ) : Even (2 * k) := ⟨k, by ring⟩
     (file: Bridges/BreakthroughDirections.lean)

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



Recent successful concepts: Cohomological Quantum Contextuality: Sheaf-Theoretic Kochen-Specker, Čech Obstruction Classes, and All-vs-Nothing Contextuality Bounds, Hopf-Algebraic Causal Calculus: Birkhoff–Pearl Decomposition, Forest-Formula Intervention Identification, and Antipodal Counterfactual Adjustment, tropical_cryptography_breakthrough_bridge


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
Research mode: prove
