

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

## TASK: Gravitational Factoring — Idempotent Spectral Lensing, Causal Prime Decomposition, and Ring-Theoretic Factorization Certification

### I. Foundational Definitions (5+ New Structures)

Define the following structures, each bridging commutative algebra to computational number theory and cryptographic certification:

```lean
/-- A spectral lens captures an idempotent-induced factorization of n.
    The idempotent e in Z/nZ acts as a gravitational lens, splitting
    the prime spectrum into two disconnected components whose product
    recovers n.
    Bridge: connects CommRing idempotent theory to cryptographic factoring certificates. -/
structure SpectralLens (n : ℕ) where
  e : ℕ  -- representative in [0, n)
  e_pos : 0 < e
  e_lt : e < n
  idempotent : (e * e) % n = e % n
  co_prime_factor : (1 - e % n) % n ≠ 0  -- nontriviality: both factors nonzero

/-- The factorization induced by a spectral lens.
    n = gcd(n, e) · gcd(n, 1-e) with complementary prime support. -/
structure LensFactorization (n : ℕ) where
  lens : SpectralLens n
  factor_a : ℕ
  factor_b : ℕ
  factorization : n = factor_a * factor_b
  factor_a_eq : factor_a = Nat.gcd n lens.e
  factor_b_eq : factor_b = Nat.gcd n (1 - lens.e % n)

/-- A causal chain in Spec(Z/nZ) is a totally ordered sequence of
    prime ideals (p) ⊂ (p²) ⊂ ... ⊂ (p^a) corresponding to a single
    prime power tower. Maximum depth equals the multiplicity a.
    Bridge: connects Zariski topology to analytic number theory (Ω, ω). -/
structure CausalChain (n : ℕ) where
  prime : ℕ
  prime_is_prime : Prime prime
  exponent : ℕ
  chain_length : exponent = Nat.factorization n prime
  ne_chain : Fin exponent → ℕ  -- the k-th ideal is (prime^(k+1))
  chain_strictly_decreasing : ∀ i j, (i : ℕ) < j → 
    ne_chain j ∣ ne_chain i ∧ ¬(ne_chain i ∣ ne_chain j)

/-- A factorization certificate verifies a purported prime factorization
    using O(k·(log n)²) ring operations on Z/nZ. Designed for
    zero-knowledge friendliness: verification requires only modular
    arithmetic, not factorization discovery.
    Bridge: connects algebraic verification to post-quantum certification. -/
structure FactorizationCertificate where
  n : ℕ
  primes : Finset ℕ
  exponents : ℕ → ℕ
  idempotent_witnesses : Finset (SpectralLens n)
  chain_witnesses : Finset (CausalChain n)

/-- The causal depth profile records the depth of each causal chain
    in Spec(Z/nZ), establishing the homeomorphism between causal
    geometry and prime factorization. -/
structure CausalDepthProfile (n : ℕ) where
  num_components : ℕ  -- equals ω(n)
  max_depth : ℕ       -- equals Ω(n) (with multiplicity)
  total_volume : ℕ    -- equals log n (additive on chains)
  components_eq_omega : num_components = n.primeFactorization.card
  depth_eq_big_omega : max_depth = n.primeFactorization.foldl (· + ·) 0
```

### II. Idempotent Spectral Lensing Theorem (Main Result 1)

```lean
/-- **Idempotent Spectral Lensing Theorem**
    For n = ∏ pᵢ^aᵢ, the nontrivial idempotents of Z/nZ are in bijection
    with nonempty proper subsets of {1,...,k}, and each idempotent e_S
    determines a factorization n = gcd(n, e_S) · gcd(n, 1 - e_S).
    
    Bridge: connects ring idempotents (algebra) to gravitational lensing (physics)
    and factoring certificates (cryptography). -/
theorem idempotent_spectral_lensing (n : ℕ) (hn : 0 < n) (hneq : n ≠ 1) :
    ∃ (f : {S : Finset (Fin n.primeFactorization.card) // S.Nonempty ∧ S ≠ Finset.univ}),
      ∀ S, let e := classicalChineseRemainderIdempotent n S.val;
      let a := Nat.gcd n e;
      let b := Nat.gcd n (1 - e % n);
      a * b = n ∧ a > 1 ∧ b > 1 ∧
      (∀ p ∈ n.primeFactorization.support, 
        (p ∈ primeSupportOfSubset n S.val → p ∣ a) ∧ 
        (p ∉ primeSupportOfSubset n S.val → p ∣ b)) :=
  by sorry -- PROVE THIS
```

**Proof Strategy (3 paths, Path A recommended):**

*Path A (CRT Decomposition — Most Promising):*
1. Lemma `crt_idempotent_characterization`: For n = ∏ pᵢ^aᵢ, the ring Z/nZ ≅ ∏ Z/pᵢ^aᵢZ via CRT. An element e is idempotent iff its projection onto each Z/pᵢ^aᵢZ is 0 or 1. This gives 2^k idempotents for k = ω(n).
2. Lemma `idempotent_subset_bijection`: Map each idempotent to the subset S = {i : projection of e onto Z/pᵢ^aᵢZ is 1}. This is a bijection. Prove injectivity by showing distinct subsets yield distinct CRT tuples.
3. Lemma `gcd_idempotent_factor`: For idempotent e with subset S, prove gcd(n, e) = ∏_{i∈S} pᵢ^aᵢ. Key insight: e ≡ 1 (mod pᵢ^aᵢ) for i ∈ S and e ≡ 0 (mod pᵢ^aᵢ) for i ∉ S, so gcd(n, e) captures exactly the S-prime-power factors.
4. Combine with `gcd_complementary_factor`: gcd(n, 1-e) = ∏_{i∉S} pᵢ^aᵢ, yielding the factorization.

*Path B (Direct Induction on ω(n)):*
1. Base case ω(n) = 1: only trivial idempotents 0, 1 exist (Z/p^aZ is local). 
2. Inductive step: If n = m · p^a with ω(m) = k, idempotents of Z/nZ decompose as pairs (e_m, e_p) where e_m is idempotent in Z/mZ and e_p ∈ {0, 1} in Z/p^aZ. Use `Finset.induction` on the prime support.

*Path C (Bézout Identity Construction):*
1. For subset S, construct e_S via Bézout: let M_S = ∏_{i∈S} pᵢ^aᵢ and M_{Sᶜ} = ∏_{i∉S} pᵢ^aᵢ. Since gcd(M_S, M_{Sᶜ}) = 1, find u, v with u·M_S + v·M_{Sᶜ} = 1. Set e_S = v·M_{Sᶜ} mod n. Verify e_S² ≡ e_S (mod n).

### III. Causal Prime Decomposition Theorem (Main Result 2)

```lean
/-- **Causal Prime Decomposition Theorem**
    Spec(Z/nZ) decomposes as a disjoint union of causal chains Cᵢ of length aᵢ,
    one per prime power. The number of connected components equals ω(n) and
    maximum causal depth equals Ω(n).
    
    Bridge: connects Zariski topology (algebraic geometry) to prime factorization
    (number theory) via causal structure (relativistic physics analogy). -/
theorem causal_prime_decomposition (n : ℕ) (hn : n > 1) :
    let spec := primeSpectrumZMod n
    let chains := causalChains n
    let chain_decomp := chains.toList.map (·.toSet)
    (∀ C ∈ chain_decomp, IsCausalChain C) ∧
    (∀ C₁ C₂, C₁ ∈ chain_decomp → C₂ ∈ chain_decomp → C₁ ≠ C₂ → Disjoint C₁ C₂) ∧
    (⋃₀ (chain_decomp.toFinset : Set (Set (primeSpectrumZMod n))) : Set _) = Set.univ) ∧
    (chain_decomp.length = n.primeFactorization.card) ∧  -- ω(n) components
    ((chain_decomp.map (·.length)).maxDflt = n.primeFactorization.foldl (· + ·) 0) :=  -- Ω(n) max depth
  by sorry -- PROVE THIS
```

**Proof Strategy:**

1. Lemma `prime_spectrum_ZMod_points`: For n = ∏ pᵢ^aᵢ, prove Spec(Z/nZ) = {(p) : p | n ∧ Prime p} as a set, with each (p) corresponding to the ideal generated by p in Z/nZ.
2. Lemma `zariski_order_prime_power`: For a single prime power p^a, Spec(Z/p^aZ) forms a chain of length a: (p) ⊃ (p²) ⊃ ... ⊃ (p^a) = ⊥. Prove using `Ideal.mem_span` and divisibility.
3. Lemma `zariski_disconnected_coprime`: For coprime m, n, Spec(Z/(m·n)Z) is a disconnected union of Spec(Z/mZ) and Spec(Z/nZ). Use CRT isomorphism and `PrimeSpectrum.disconnected_of_coprime`.
4. Lemma `causal_depth_equals_multiplicity`: In the chain for p^a, the causal depth from maximal ideal to minimal equals exactly a. Prove by induction on a using the filtration p^k Z/p^a Z.
5. Assemble: by CRT, the full spectrum decomposes into one connected component per prime factor, each component is a chain of length equal to the multiplicity. Use `Finset.foldl` for the Ω(n) computation.

### IV. Ring-Theoretic Factorization Certification Theorem (Main Result 3)

```lean
/-- **Ring-Theoretic Factorization Certification Theorem**
    A purported factorization n = ∏ pᵢ^aᵢ can be certified in O(k · (log n)²)
    ring operations by verifying: (1) each pᵢ is prime, (2) the idempotent
    decomposition witnesses consistent with the factorization exist, and
    (3) the causal structure of Spec(Z/nZ) matches the claimed exponents.
    
    The certification is zero-knowledge friendly: the verifier checks
    algebraic relations without learning the factorization.
    
    Bridge: connects algebraic factoring to post-quantum certification
    and lattice-based cryptographic commitments. -/
theorem factorization_certification_bound (n : ℕ) (hn : n > 1) 
    (primes : Finset ℕ) (exponents : ℕ → ℕ) 
    (hfactorization : n = ∏ p in primes, p ^ exponents p)
    (hprimes : ∀ p ∈ primes, Prime p) :
    let k := primes.card
    let cert := mkCertificate n primes exponents hfactorization
    -- Verification cost: O(k · (log n)²) ring operations
    ∃ (ops : ℕ), ops ≤ 4 * k * (Nat.log 2 n + 1) ^ 2 ∧
      verifyCertificate cert = true ∧
      -- Soundness: if cert verifies, factorization is correct
      ∀ (m : ℕ) (hm : m > 1), 
        verifyCertificate (mkCertificate m primes exponents 
          (by_contra h; exact absurd h hfactorization)) = true → 
        m = ∏ p in primes, p ^ exponents p :=
  by sorry -- PROVE THIS
```

**Proof Strategy:**

1. Lemma `primality_check_cost`: Verifying p is prime costs O((log p)³) using trial division. For all k primes, total O(k · (log n)³) — but we can use `Nat.Prime` decidability which is O(√p). Refine to O(k · log²n) using Miller-Rabin-style witness checking (deterministic for small n).
2. Lemma `idempotent_verification_cost`: Computing gcd(n, e) for an idempotent witness e costs O((log n)²) using Euclidean algorithm. For k idempotents (one per prime boundary), total O(k · (log n)²).
3. Lemma `crt_verification_cost`: Checking the CRT isomorphism Z/nZ ≅ ∏ Z/pᵢ^aᵢZ costs O(k · log n) by verifying modular congruences.
4. Lemma `certificate_soundness`: If certificate verifies, then the idempotents are genuine (by `idempotent_spectral_lensing`), the CRT decomposition holds, and the product recovers n. Use `by_contra` to show any deviation leads to idempotent failure.
5. Lemma `zero_knowledge_property`: The certificate reveals only the idempotents {e_S}, not the factors themselves. Each e_S is a random-looking element of Z/nZ. Formalize as: given e_S, recovering the subset S is as hard as factoring n. Use `Nat.ModEq` for the modular arithmetic.

### V. Supporting Lemmas (10+ Required, Diverse Tactics)

```lean
/-- Bridge: connects Chinese Remainder Theorem to spectral decomposition (physics). -/
lemma crt_spectral_decomposition (n : ℕ) (hn : n > 1) :
    ∀ (decomp : PrimeFactorization n),
    ZMod n ≃+* (∏ p in decomp.primes, ZMod (p ^ decomp.exponents p)) :=
  sorry -- Use Mathlib's ChineseRemainder.ringEquiv

/-- The idempotents of Z/nZ correspond to subsets of prime factors.
    Uses rcases on the CRT decomposition. -/
lemma idempotent_crt_classification (n : ℕ) (hn : n > 1) :
    {e : ZMod n // e * e = e} ≃ 
      {S : Finset (Fin n.primeFactorization.card) // True} :=
  sorry -- Bijection via CRT projections

/-- gcd(n, e) extracts the prime power factors from the idempotent's support.
    Uses field_simp and norm_cast for modular arithmetic. -/
lemma gcd_idempotent_factor_extraction (n e : ℕ) (he : e * e % n = e % n) :
    Nat.gcd n e = ∏ p in primeSupportOfIdempotent n e, p ^ n.primeFactorization p :=
  sorry -- Key: e ≡ 1 mod p^a for p in support, e ≡ 0 mod p^a otherwise

/-- Each connected component of Spec(Z/nZ) contains exactly one minimal prime.
    Uses by_contra for the uniqueness argument. -/
lemma connected_component_unique_minimal_prime (n : ℕ) (hn : n > 1) :
    ∀ C ∈ connectedComponents (primeSpectrumZMod n),
    ∃! p, p ∈ C ∧ Prime p ∧ Irreducible (Ideal.span {p} : Ideal (ZMod n)) :=
  sorry

/-- Causal depth in a prime power chain equals the exponent.
    Uses induction on the exponent. -/
lemma causal_depth_prime_power_chain (p a : ℕ) (hp : Prime p) (ha : 0 < a) :
    causalDepth (primeSpectrumZMod (p ^ a)) = a :=
  sorry -- Induction on a, using the filtration structure

/-- The spectral lens factorization is multiplicative on coprime components.
    Uses omega for arithmetic on exponents. -/
lemma spectral_lens_multiplicative (m n : ℕ) (hcoprime : Nat.gcd m n = 1) :
    ∀ (e_m : SpectralLens m) (e_n : SpectralLens n),
    (lensFactorization e_m).factor_a * (lensFactorization e_n).factor_a =
      (lensFactorization (combineLens e_m e_n hcoprime)).factor_a :=
  sorry -- CRT multiplication

/-- Certification soundness: no false factorizations pass verification.
    Uses by_contra and linarith for the contradiction. -/
lemma certification_soundness (n : ℕ) (hn : n > 1) (cert : FactorizationCertificate) :
    verifyCertificate cert = true →
    cert.n = ∏ p in cert.primes, p ^ cert.exponents p :=
  sorry -- by_contra: assume false factorization, derive idempotent contradiction

/-- The number of nontrivial idempotents equals 2^ω(n) - 2.
    Uses Finset.card and the bijection from idempotent_crt_classification. -/
lemma idempotent_count_formula (n : ℕ) (hn : n > 1) :
    Finset.card {e : ZMod n // e * e = e ∧ e ≠ 0 ∧ e ≠ 1} = 
      2 ^ n.primeFactorization.card - 2 :=
  sorry -- Count subsets minus empty and full

/-- Idempotent-based factoring reduces to Bézout computation.
    Explicit complexity: O((log n)²) per idempotent via extended GCD. -/
lemma bezout_idempotent_complexity (n : ℕ) (S : Finset ℕ) :
    ∃ (ops : ℕ), ops ≤ 3 * (Nat.log 2 n + 1) ^ 2 ∧
      classicalChineseRemainderIdempotent n S = 
        bezoutCoefficient (∏ p in S, p ^ n.primeFactorization p) 
                          (∏ p in (Finset.univ \ S), p ^ n.primeFactorization p) :=
  sorry -- Extended GCD analysis

/-- Causal chains are maximal: they cannot be extended.
    Uses rcases on chain endpoints. -/
lemma causal_chain_maximality (n : ℕ) (hn : n > 1) :
    ∀ C ∈ causalChains n, ∀ (C' : CausalChain n), 
      C.toSet ⊆ C'.toSet → C.toSet = C'.toSet :=
  sorry -- Maximal chains in Spec(Z/nZ) correspond to prime power towers

/-- The spectral lens provides a Lipschitz-stable factorization:
    small perturbations of the idempotent yield proportional changes in factors.
    Bridge: connects algebraic factoring to certified robustness (ML). -/
lemma spectral_lens_lipschitz_stability (n : ℕ) (hn : n > 1) 
    (e₁ e₂ : SpectralLens n) :
    |(lensFactorization e₁).factor_a - (lensFactorization e₂).factor_a| ≤
      Nat.gcd n |e₁.e - e₂.e| :=
  sorry -- Lipschitz bound from gcd properties
```

### VI. Revolutionary Significance

This work opens **algebraic-geometric factoring** as a new field by establishing that:

1. **Factoring is spectral**: The problem of factoring n is equivalent to finding the idempotent spectrum of Z/nZ. This reframes factoring from computational number theory to spectral ring theory.

2. **Causal geometry IS arithmetic**: The topological structure of Spec(Z/nZ) (connected components = ω(n), max depth = Ω(n)) means prime factorization is literally readable from the causal structure. This is a **holographic principle** for arithmetic: the boundary (spectrum) encodes the bulk (factorization).

3. **Certification without revelation**: The O(k·(log n)²) certification scheme is inherently zero-knowledge friendly because idempotent witnesses reveal modular residues, not factors. This has direct applications to **post-quantum lattice-based commitments** where the algebraic structure provides soundness.

4. **Cross-domain bridges established**:
   - Algebra ↔ Physics: Idempotents as gravitational lenses, causal chains as worldlines
   - Algebra ↔ Cryptography: Factorization certificates from ring-theoretic data
   - Algebra ↔ ML: Lipschitz-stable factorizations for certified robustness
   - Topology ↔ Number Theory: Zariski topology encodes prime factorization

### VII. Required: FUTURE_DIRECTIONS.md

Produce a structured FUTURE_DIRECTIONS.md with 3-5 concrete breakthrough-level next steps:

1. **Tropical Idempotent Lensing**: Extend spectral lensing to the tropical semiring (min-plus algebra), where idempotents correspond to tropical hypersurface arrangements. Prove: tropical spectral lenses certify tropical factorizations in O(k) operations — potentially faster than classical certification.

2. **Quantum Idempotent Tomography**: Formulate the quantum measurement of idempotent spectra: given oracle access to Z/nZ (as a black-box ring), prove that O(ω(n)) quantum queries suffice to determine the full idempotent structure, yielding a quantum speedup for factoring certification (not factoring itself).

3. **Lattice-Based Factorization Commitments**: Construct a lattice-based commitment scheme where the committed value is a factorization of n, and opening requires revealing idempotent witnesses. Prove: the commitment is computationally binding under the NTRU lattice assumption, and perfectly hiding by the spectral lensing theorem.

4. **Causal Sheaf Cohomology**: Define sheaf cohomology groups H^i(Spec(Z/nZ), O) where O is the structure sheaf. Prove: H^0 recovers the idempotent structure, H^1 vanishes (affine scheme), and higher groups encode multiplicative relations between prime factors. This opens **arithmetic sheaf theory**.

5. **Neural Certified Factoring**: Train a neural network to predict idempotent witnesses from n, and prove Lipschitz bounds on the prediction map. If the Lipschitz constant is L < √(min prime factor of n), then the network's predictions are self-certifying: they cannot cross factorization boundaries.

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
            Open the field of algebraic-geometric factoring by proving three foundational theorems that establish a gravitational analogy for integer factorization via the recently formalized algebraic spacetime framework. (1) Idempotent Spectral Lensing Theorem: For n = ∏ pᵢ^aᵢ, the nontrivial idempotents of Z/nZ are in bijection with nonempty proper subsets of {1,...,k}, and each idempotent e_S determines a factorization n = gcd(n, e_S) · gcd(n, 1-e_S) — prime factors act as 'gravitational lenses' splitting the spectrum into disconnected components. (2) Causal Prime Decomposition Theorem: Spec(Z/nZ) decomposes as a disjoint union of causal chains Cᵢ of length aᵢ, one per prime power; the number of connected components equals ω(n) (distinct prime factors) and maximum causal depth equals Ω(n) (maximum multiplicity), establishing a homeomorphism between causal geometry and prime factorization. (3) Ring-Theoretic Factorization Certification Theorem: A purported factorization n = ∏ pᵢ^aᵢ is certified in O(k·(log n)²) ring operations by verifying the idempotent decomposition, Chinese Remainder isomorphism, and causal structure consistency — yielding a zero-knowledge-friendly certification scheme.

            ### Precise Mathematical Framing
            The recently completed Algebraic Spacetime work established that prime spectra carry natural causal structure (inclusion ordering). We exploit this to develop a 'gravitational lensing' analogy: for composite n, the Chinese Remainder Theorem decomposes Z/nZ ≅ ∏ Z/pᵢ^aᵢZ, and each projection is a 'lens' focusing on a prime factor. Formally: (1) Prove the idempotent–factorization correspondence: the map S ↦ e_S = ∑ᵢ∈S (n/pᵢ^aᵢ)·((n/pᵢ^aᵢ)⁻¹ mod pᵢ^aᵢ) mod n is a bijection from subsets to idempotents, and e_S ↦ (gcd(n, e_S), gcd(n, 1-e_S)) gives the corresponding coprime factorization. (2) Prove the causal decomposition: Spec(Z/nZ) = ⊔ᵢ Cᵢ where Cᵢ = {(0) ⊂ (pᵢ) ⊂ (pᵢ²) ⊂ ... ⊂ (pᵢ^aᵢ)} has chain length aᵢ, establishing a homeomorphism between the causal poset and the multiset of (prime, exponent) pairs. (3) Prove the certification bound: given claims (p₁, a₁), ..., (pₖ, aₖ), certification requires computing k modular inverses, k GCDs, and k divisibility checks, all in O(k·(log n)²) bit operations, and the idempotent decomposition 1 = ∑ eᵢ serves as a witness verifiable without knowing the factors individually.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `factoring_via_gcd_v2` : theorem factoring_via_gcd_v2 (p q : ℕ) (_hp : Nat.Prime p) (_hq : Nat.Prime q) :
     (file: Algebra/Factoring/Oracle.lean)
  2. `no_nontrivial_idempotents_implies_connected` : theorem no_nontrivial_idempotents_implies_connected (R : Type*) [CommRing R]
     (file: Algebra/Other/UniversalTranslator.lean)
  3. `idempotent_hilbert_basis_theorem` : theorem idempotent_hilbert_basis_theorem
     (file: Algebra/EMLCongruenceHilbert.lean)
  4. `depth_bound_prime` : theorem depth_bound_prime (p : ℕ) (hodd : p % 2 = 1) (hp5 : 5 ≤ p) :
     (file: Algebra/Factoring/ChainFactoring.lean)
  5. `fundamental_theorem_algebraic_light'` : theorem fundamental_theorem_algebraic_light' (a b c : ℤ) :
     (file: Algebra/Other/UnifyingTheory.lean)

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



Recent successful concepts: Pythagorean Holographic Duality: Tree-Geodesic Entropy Bound, Bulk-Boundary Reconstruction, and Primality Error-Correcting Codes, Causal Reconstruction of Zariski Topology: Finite Causal Decomposition, Causal Depth-Dimension Identity, and Holographic Uniqueness, Diophantine Cryptography: Berggren Descent One-Way Functions, Modular Triple Hash Universality, and Tree-Geodesic Collision Resistance


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
