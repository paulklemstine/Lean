

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

## YOUR ASSIGNMENT: Tropical Arithmetic Geometry: Cuspidal Factorization, Max-Plus Valuation Superadditivity, and Prime Decomposition Recovery on the Berggren Tree

### Revolutionary Significance

This work establishes the **first verified tropical-arithmetical bridge** between the combinatorial structure of Pythagorean triple generation (Berggren tree) and the multiplicative number theory of prime factorization. The central breakthrough: the max-plus valuation `v_B` on Berggren hypotenuses is **superadditive**, meaning the tropical lens captures strictly more structure than classical valuations. This opens:

1. **Post-quantum cryptographic implications**: If `v_B` recovers prime decomposition structure from tropical data, then tropical Berggren lattices yield a candidate one-way function whose hardness reduces to a hybrid of factorization and tropical lattice problems — both believed post-quantum resistant.

2. **Tropical information theory**: The gap `v_B(mn) - v_B(m) - v_B(n)` measures "tropical mutual information" between Berggren representations, satisfying a data-processing inequality that directly bounds certified robustness radii in tropical-geometric ML classifiers.

3. **Quantum-thermodynamic analog**: The superadditivity `v_B(mn) ≥ v_B(m) + v_B(n)` is the arithmetic shadow of subadditivity of von Neumann entropy — the Berggren tree acts as a "number-theoretic density matrix" whose prime spectrum encodes entanglement-like correlations.

### Core Definitions (5+ Required)

```lean
/-- The Berggren valuation: for a Berggren hypotenuse n, v_B(n) is the
    tropical critical multiplicity, measuring the degeneracy of the
    prime factorization under the max-plus lens.
    Bridge: connects algebraic number theory to tropical geometry. -/
def berggrenValuation (n : ℕ+) (h : IsBerggrenHypotenuse n) : ℕ :=
  tropicalCriticalMultiplicity (berggrenHypotenuseMatrix n h)

/-- A Berggren hypotenuse is cuspidal if its valuation equals its
    number of distinct prime factors — i.e., each prime contributes
    exactly one degenerate permutation in the tropical limit.
    Analogous to cuspidal representations in Langlands. -/
def IsCuspidal (n : ℕ+) (h : IsBerggrenHypotenuse n) : Prop :=
  berggrenValuation n h = ω n

/-- The tropical entropy of a Berggren hypotenuse: the logarithmic
    gap between the valuation and the naive bound.
    Connects to thermodynamic entropy via Boltzmann's principle. -/
def tropicalEntropy (n : ℕ+) (h : IsBerggrenHypotenuse n) : ℝ :=
  Real.log (berggrenValuation n h + 1) - Real.log (ω n + 1)

/-- The Berggren spectrum: the image of v_B across all Berggren hypotenuses.
    Forms a sub-semiring of ℕ under max-plus operations.
    Bridge: connects spectral theory to tropical semiring theory. -/
def berggrenSpectrum : Set ℕ :=
  {k : ℕ | ∃ (n : ℕ+) (h : IsBerggrenHypotenuse n), berggrenValuation n h = k}

/-- Tropical prime recovery map: given a Berggren path matrix M,
    extracts the multiset of prime factors recoverable from tropical data.
    Cryptographic significance: this is the "tropical hash" function. -/
def tropicalPrimeRecovery (M : Matrix (Fin 3) (Fin 3) ℤ) : Multiset ℕ :=
  (tropicalCriticalMultiplicity M, berggrenPathMatrix_det M).1.repeat
    (tropicalCriticalMultiplicity M)
    |>.toList.tail?.getD [] |>.toList.toArray |>.toList.toMultiset

/-- The cuspidal defect: measures how far a Berggren hypotenuse
    is from being cuspidal. Zero iff cuspidal.
    Bridge: connects defect theory in algebraic geometry to
    certified robustness margins in tropical ML. -/
def cuspidalDefect (n : ℕ+) (h : IsBerggrenHypotenuse n) : ℕ :=
  berggrenValuation n h - ω n
```

### Main Theorems (10+ Required, ZERO Sorries)

**Theorem 1: Cuspidal Factorization — Upper Bound**
```lean
/-- The number of distinct prime factors of a Berggren hypotenuse is
    bounded above by the tropical critical multiplicity of its path matrix.
    This is the fundamental inequality enabling tropical prime recovery.
    Bridge: connects arithmetic ω-function to tropical algebraic multiplicity.
    Application: tropical_certified_robustness — gives O(v_B) bound on
    the certified radius for tropical-geometric classifiers. -/
theorem cuspidal_factorization_upper_bound (w : List BerggrenGen) (hw : w ≠ []) :
    ω (hypotenuse (berggrenWordToTriple w)).toNat ≤
    tropicalCriticalMultiplicity (berggrenPathMatrix w) := by
  -- Strategy: strong induction on word length.
  -- Base case (w = [g] for g ∈ {A, B₁, B₂}): direct computation using
  -- depth1_omega_le_critMult from catalog.
  -- Inductive step: decompose w = w' ++ [g], apply berggren_monoid_hom
  -- to split the path matrix, then use submultiplicativity of critical
  -- multiplicity under matrix multiplication.
  -- Key lemma: berggrenValuation_monoid_hom
  sorry
```

**Theorem 2: Squarefree Equality — Sharp Bound**
```lean
/-- Equality in the cuspidal bound holds iff the hypotenuse is squarefree.
    This is the tropical analog of the Chebotarev density theorem:
    the "splitting type" (valuation = ω) occurs exactly when primes are unramified
    (i.e., appear with multiplicity 1).
    Bridge: connects squarefreeness (analytic number theory) to tropical
    degeneracy (tropical geometry).
    Application: post_quantum_factorization — squarefree Berggren hypotenuses
    are exactly those for which tropical prime recovery is lossless. -/
theorem squarefree_equality (w : List BerggrenGen) (hw : w ≠ []) :
    ω (hypotenuse (berggrenWordToTriple w)).toNat =
    tropicalCriticalMultiplicity (berggrenPathMatrix w)
    ↔ Squarefree (hypotenuse (berggrenWordToTriple w)).toNat := by
  -- Strategy: prove both implications separately.
  -- (→): Assume equality. By contrapositive: if some prime p divides n²,
  -- then p contributes ≥ 2 to critical multiplicity but only 1 to ω,
  -- contradicting equality. Use multiplicity_le_critical_multiplicity.
  -- (←): Assume squarefree. Each prime factor contributes exactly one
  -- degenerate permutation (by Squarefree_unique_permutation), so
  -- ω = critical multiplicity.
  -- Key lemma: squarefree_iff_prime_multiplicity_eq_one
  sorry
```

**Theorem 3: Valuation Superadditivity — The Deep Result**
```lean
/-- The Berggren valuation is superadditive: v_B(mn) ≥ v_B(m) + v_B(n).
    This is the arithmetic shadow of subadditivity of von Neumann entropy
    in quantum information theory. The gap v_B(mn) - v_B(m) - v_B(n)
    measures "tropical entanglement" between Berggren representations.
    Bridge: connects multiplicative number theory to tropical information
    theory and quantum thermodynamics.
    Application: tropical_hash_collision — superadditivity gives a
    O(log n) lower bound on collision resistance of the tropical hash. -/
theorem valuation_superadditive (m n : ℕ+) 
    (hm : IsBerggrenHypotenuse m) (hn : IsBerggrenHypotenuse n) :
    berggrenValuation (m * n) (berggren_hypotenuse_mul hm hn) ≥
    berggrenValuation m hm + berggrenValuation n hn := by
  -- Strategy A (Direct): Use berggren_monoid_hom to decompose the path matrix
  -- of mn into the product of path matrices of m and n. Then apply
  -- tropical_critical_multiplicity_submultiplicative, which states that
  -- v(M₁M₂) ≥ v(M₁) + v(M₂) in max-plus algebra. This is the tropical
  -- analog of Weyl's inequality for eigenvalues.
  --
  -- Strategy B (Number-theoretic): Use ω(mn) ≤ ω(m) + ω(n) + log(m) + log(n)
  -- and the cuspidal bound to sandwich the valuation. The superadditivity
  -- gap is bounded by the "tropical defect" cuspidalDefect.
  --
  -- Strategy A is most promising because it directly uses the monoid
  -- homomorphism structure and avoids case analysis on prime factorizations.
  sorry
```

**Theorem 4: Cuspidal Defect Vanishing**
```lean
/-- The cuspidal defect vanishes iff the hypotenuse is squarefree.
    This is the "smoothness" condition for tropical prime recovery:
    zero defect means lossless recovery of all prime factors. -/
theorem cuspidal_defect_zero_iff_squarefree (n : ℕ+) (h : IsBerggrenHypotenuse n) :
    cuspidalDefect n h = 0 ↔ Squarefree n :=
  -- Unfold definition, apply squarefree_equality
  sorry
```

**Theorem 5: Tropical Entropy Subadditivity**
```lean
/-- Tropical entropy is subadditive: H(mn) ≤ H(m) + H(n).
    This is the tropical information-theoretic analog of the
    data processing inequality. The proof uses the concavity of
    log and the superadditivity of v_B.
    Application: tropical_certified_robustness — H gives a certified
    robustness radius for tropical-geometric classifiers with
    Lipschitz constant bounded by exp(H). -/
theorem tropical_entropy_subadditive (m n : ℕ+)
    (hm : IsBerggrenHypotenuse m) (hn : IsBerggrenHypotenuse n) :
    tropicalEntropy (m * n) (berggren_hypotenuse_mul hm hn) ≤
    tropicalEntropy m hm + tropicalEntropy n hn := by
  -- Follows from superadditivity of v_B and concavity of log.
  -- Key step: log(a + b) ≤ log(a) + log(b) for a, b ≥ 1.
  sorry
```

**Theorem 6: Berggren Spectrum is Subadditive Semiring**
```lean
/-- The Berggren spectrum forms a sub-semiring of ℕ under max-plus operations:
    max(a, b) and a + b are both in the spectrum whenever a, b are.
    Bridge: connects tropical semiring theory to number-theoretic spectra.
    Application: post_quantum_lattice — the spectrum gives the set of
    achievable "tropical dimensions" for Berggren lattice constructions. -/
theorem berggren_spectrum_max_closed {a b : ℕ} 
    (ha : a ∈ berggrenSpectrum) (hb : b ∈ berggrenSpectrum) :
    max a b ∈ berggrenSpectrum := by
  -- Construct witness: take Berggren hypotenuses with valuations a, b,
  -- use valuation_superadditive to get valuation ≥ a + b ≥ max(a, b).
  sorry

theorem berggren_spectrum_add_closed {a b : ℕ}
    (ha : a ∈ berggrenSpectrum) (hb : b ∈ berggrenSpectrum) :
    a + b ∈ berggrenSpectrum := by
  -- Same witness construction, using superadditivity directly.
  sorry
```

**Theorem 7: Depth-1 Cuspidal Factorization (Building Block)**
```lean
/-- Every depth-1 Berggren hypotenuse (5, 13, 17) is cuspidal.
    This is the base case for the inductive structure of cuspidal decomposition.
    Bridge: connects depth-1 structure (catalog: depth1_omega_le_critMult)
    to the cuspidal framework. -/
theorem depth1_cuspidal (g : BerggrenGen) :
    IsCuspidal (hypotenuse (berggrenWordToTriple [g])).toNat
      (berggren_hypotenuse_depth1 g) := by
  -- Direct computation: depth-1 hypotenuses are prime, hence squarefree.
  -- Apply squarefree_equality (base case of induction).
  sorry
```

**Theorem 8: Cuspidal Defect Multiplicative Bound**
```lean
/-- The cuspidal defect satisfies a multiplicative upper bound:
    δ(mn) ≤ δ(m) · δ(n) + δ(m) · v_B(n) + v_B(m) · δ(n).
    This gives O(n^ε) growth of the defect, enabling efficient
    tropical prime recovery algorithms.
    Application: tropical_prime_recovery_efficiency — gives O(n^ε log n)
    algorithm for recovering prime factors from tropical data. -/
theorem cuspidal_defect_multiplicative_bound (m n : ℕ+)
    (hm : IsBerggrenHypotenuse m) (hn : IsBerggrenHypotenuse n) :
    cuspidalDefect (m * n) (berggren_hypotenuse_mul hm hn) ≤
    cuspidalDefect m hm * cuspidalDefect n hn +
    cuspidalDefect m hm * berggrenValuation n hn +
    berggrenValuation m hm * cuspidalDefect n hn := by
  -- Expand definitions, use superadditivity of v_B and subadditivity of ω.
  -- Key inequality: ω(mn) ≥ ω(m) + ω(n) - gcd(m,n).countFactors
  sorry
```

**Theorem 9: Tropical Prime Recovery — Lossless for Squarefree**
```lean
/-- For squarefree Berggren hypotenuses, tropical prime recovery is lossless:
    the multiset of prime factors is exactly recovered from tropical data.
    This establishes the tropical Berggren tree as a "number-theoretic hash"
    that is collision-free on squarefree inputs.
    Application: post_quantum_security — lossless recovery means the
    tropical hash has zero collision probability on squarefree inputs,
    giving Ω(2^n) collision resistance. -/
theorem tropical_prime_recovery_lossless (n : ℕ+) 
    (h : IsBerggrenHypotenuse n) (hsq : Squarefree n) :
    tropicalPrimeRecovery (berggrenHypotenuseMatrix n h) =
    (n.factorization).keys.map (·.val) |>.toMultiset := by
  -- Use squarefree_equality to show v_B = ω, then each prime
  -- contributes exactly one degenerate permutation, recoverable
  -- from the tropical critical curve data.
  sorry
```

**Theorem 10: Berggren Valuation Monoid Homomorphism Property**
```lean
/-- The Berggren valuation intertwines with matrix multiplication via
    the monoid homomorphism structure of berggrenPathMatrix.
    This is the key structural lemma enabling the superadditivity proof.
    Bridge: connects representation theory (monoid homomorphisms) to
    tropical algebra (max-plus valuations). -/
theorem berggren_valuation_monoid_hom (w₁ w₂ : List BerggrenGen) :
    tropicalCriticalMultiplicity (berggrenPathMatrix (w₁ ++ w₂)) ≥
    tropicalCriticalMultiplicity (berggrenPathMatrix w₁) +
    tropicalCriticalMultiplicity (berggrenPathMatrix w₂) := by
  -- Use berggren_monoid_hom to decompose the path matrix,
  -- then apply tropical_critical_multiplicity_submultiplicative.
  -- This is the core algebraic fact: v(AB) ≥ v(A) + v(B) in max-plus.
  sorry
```

**Theorem 11: Asymptotic Density of Cuspidal Hypotenuses**
```lean
/-- The asymptotic density of cuspidal Berggren hypotenuses is 6/π²
    (the density of squarefree numbers). This follows from the
    squarefree_equality theorem and the known density of squarefree
    numbers among Berggren hypotenuses.
    Application: tropical_certified_robustness — gives the probability
    that a random Berggren hypotenuse admits lossless prime recovery,
    bounding the expected certified robustness radius. -/
theorem cuspidal_asymptotic_density :
    Filter.Tendsto (fun N : ℕ => 
      (Finset.filter (fun n => ∃ h : IsBerggrenHypotenuse ⟨n, by omega⟩, 
        IsCuspidal ⟨n, by omega⟩ h) (Finset.range N)).card / N)
      Filter.atTop (nhds (6 / π^2 : ℝ)) := by
  -- Use squarefree_equality to reduce to density of squarefree numbers,
  -- then apply the classical result that squarefree density = 6/π².
  sorry
```

**Theorem 12: Tropical Collision Resistance Lower Bound**
```lean
/-- The tropical Berggren hash has collision resistance Ω(2^(n/2)) where
    n is the bit length of the input. This follows from superadditivity
    and the cuspidal defect bound.
    Application: post_quantum_security — establishes that finding
    collisions in the tropical hash requires Ω(2^(n/2)) quantum queries,
    making it suitable for post-quantum cryptographic hash constructions. -/
theorem tropical_hash_collision_resistance (N : ℕ) :
    ∀ m₁ m₂ : ℕ+, m₁ < 2^N → m₂ < 2^N →
    m₁ ≠ m₂ →
    IsBerggrenHypotenuse m₁ → IsBerggrenHypotenuse m₂ →
    (berggrenValuation m₁ · + cuspidalDefect m₁ ·) ≠
    (berggrenValuation m₂ · + cuspidalDefect m₂ ·) ∨
    2^(N/2) ≤ m₁ ∨ 2^(N/2) ≤ m₂ := by
  -- Uses superadditivity and defect bound to show that distinct
  -- Berggren hypotenuses with small valuation must differ by at
  -- least an exponential gap, preventing collisions.
  sorry
```

### Proof Strategy Details

**For `cuspidal_factorization_upper_bound` (Theorem 1):**
1. Base case: Apply `depth1_omega_le_critMult` directly for single-generator words.
2. Inductive step: Write `w = w' ++ [g]`, use `berggren_monoid_hom` to decompose `berggrenPathMatrix w = berggrenPathMatrix w' * berggrenGenMatrix g`.
3. Apply `berggren_valuation_monoid_hom` (Theorem 10) to get `v(w) ≥ v(w') + v([g])`.
4. By induction, `ω(hyp(w')) ≤ v(w')` and `ω(hyp([g])) ≤ v([g])`.
5. Use `ω(hyp(w)) ≤ ω(hyp(w')) + ω(hyp([g]))` (subadditivity of ω) to conclude.

**For `valuation_superadditive` (Theorem 3):**
1. Express `berggrenValuation (m*n)` using `berggren_hypotenuse_mul` to get the path matrix.
2. Apply `berggren_monoid_hom` to decompose this as a product.
3. Use the max-plus matrix inequality: `tropicalCriticalMultiplicity (A * B) ≥ tropicalCriticalMultiplicity A + tropicalCriticalMultiplicity B`.
4. This is the tropical analog of Weyl's eigenvalue inequality and follows from the max-plus algebra structure.

**For `squarefree_equality` (Theorem 2):**
1. (←): Assume squarefree. Each prime p|n appears exactly once. The tropical critical multiplicity counts "degenerate permutations" of the prime factorization, each of which contributes exactly one to the count. Hence `v_B = ω`.
2. (→): Assume equality. If some prime p has multiplicity ≥ 2 in n, then p contributes ≥ 2 to `v_B` (via repeated degenerate permutation) but only 1 to `ω`, contradicting equality.

### Cross-Domain Bridges

1. **Tropical Geometry ↔ Post-Quantum Cryptography**: The superadditivity of `v_B` establishes that the tropical Berggren hash is collision-resistant, providing a candidate post-quantum hash function whose security reduces to the difficulty of finding Berggren hypotenuses with matching tropical data.

2. **Arithmetic Number Theory ↔ Quantum Information**: The cuspidal defect `δ = v_B - ω` plays the role of "tropical entanglement" — it measures how much prime multiplicative structure is lost in the tropical projection. Subadditivity of tropical entropy (Theorem 5) is the arithmetic shadow of subadditivity of von Neumann entropy.

3. **Algebraic Geometry ↔ Certified Robustness**: The cuspidal condition (zero defect) exactly characterizes when tropical prime recovery is lossless, which in ML terms means the certified robustness radius of a tropical-geometric classifier is maximized — the classifier can provably distinguish all prime factor patterns.

### Computational Bounds (Explicit)

- **Cuspidal defect**: `δ(n) = O(n^ε)` for any ε > 0 (Theorem 8)
- **Tropical hash collision resistance**: `Ω(2^(n/2))` quantum queries for n-bit inputs (Theorem 12)
- **Tropical prime recovery**: `O(n^ε · log n)` time for squarefree inputs (Theorem 9)
- **Berggren valuation growth**: `v_B(n) ≤ log₂(n)` for all Berggren hypotenuses (from cuspidal bound)
- **Cuspidal density**: `6/π² ≈ 0.6079` of Berggren hypotenuses are cuspidal (Theorem 11)

### FUTURE_DIRECTIONS.md Request

After completing the proofs, produce a structured `FUTURE_DIRECTIONS.md` with 3-5 concrete breakthrough-level next steps, including:

1. **Tropical Langlands for GL₂(Qₚ)**: Extend the cuspidal factorization framework to establish a tropical Satake isomorphism, connecting Berggren representations to automorphic forms via max-plus Hecke operators.

2. **Post-Quantum Tropical Hash Standard**: Construct a practical hash function from the tropical Berggren valuation with provable `Ω(2^(n/2))` quantum collision resistance, and verify it meets NIST post-quantum standards.

3. **Tropical Neural Certified Robustness**: Use the cuspidal defect to establish tight Lipschitz bounds for tropical-geometric neural networks, giving `O(δ(n))` certified robustness radii.

4. **Berggren Zeta Function**: Define `ζ_B(s) = Σ_{n Berggren} v_B(n)^(-s)` and prove it has a meromorphic continuation with poles encoding the cuspidal spectrum — the tropical analog of the Riemann zeta function.

5. **Quantum Tropical Entanglement**: Formalize the analogy between `v_B` superadditivity and von Neumann entropy subadditivity by constructing a "Berggren density matrix" whose eigenvalues encode the prime factorization.

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
            Open the field of tropical arithmetic geometry by proving three foundational results connecting prime factorization of Pythagorean hypotenuses to tropical algebraic invariants of Berggren paths: (1) Cuspidal Factorization Theorem — for all Berggren words w ≠ [], the number of distinct prime factors ω(hypotenuse(w).toNat) is at most the tropical critical multiplicity tropicalCriticalMultiplicity(berggrenPathMatrix w), with equality iff the hypotenuse is squarefree; (2) Max-Plus Valuation Superadditivity — the map v_B(n) = tropicalCriticalMultiplicity(berggrenAncestorMatrix(n)) defines a superadditive valuation on the multiplicative monoid of Berggren hypotenuses satisfying v_B(mn) ≥ v_B(m) + v_B(n); (3) Prime Decomposition Recovery — given v_B(n) and the Berggren path to n, the prime factorization of n can be reconstructed in polynomial time via tropical singular locus analysis. This creates the first bridge between classical arithmetic (prime factorization) and tropical algebraic geometry (determinant degeneracy), showing that the tropical critical multiplicity of a Berggren path matrix is an arithmetic invariant encoding the prime structure of the corresponding hypotenuse.

            ### Precise Mathematical Framing
            The Berggren monoid ⟨A,B,C⟩ acts on primitive Pythagorean triples via 3×3 integer matrices. Each Berggren word w defines a path matrix M_w = berggrenPathMatrix(w) whose classical determinant det(M_w) equals the hypotenuse c_w (up to sign). In the tropical (max-plus) semiring, the tropical determinant tropDet(M_w) = max_σ ⊕_i M_w(i, σ(i)) achieves its maximum value along multiple permutations precisely when M_w has algebraic degeneracies. We define the tropical critical multiplicity critMult(M_w) = |{σ ∈ S_3 : ⊕_i M_w(i, σ(i)) = tropDet(M_w)}|. The Cuspidal Factorization Theorem asserts that each distinct prime factor of c_w introduces at least one additional degenerate permutation in the tropical determinant computation, yielding ω(c_w) ≤ critMult(M_w). The proof proceeds by: (a) extending depth1_omega_le_critMult via berggren_monoid_hom decomposition; (b) showing that prime factorization of c_w creates repeated row/column maxima in M_w, each spawning a degenerate permutation; (c) establishing the squarefree equality criterion via injectivity of the prime-to-degeneracy map. The valuation superadditivity follows from the monoid homomorphism property and submultiplicativity of critical multiplicity under matrix product. Prime decomposition recovery uses the singular locus of M_w (the set of positions contributing to all optimal permutations) to identify which primes appear.

            ### Lean 4 Sketch
theorem cuspidal_factorization (w : List BerggrenGen) (hw : w ≠ []) : ω (hypotenuse (berggrenWordToTriple w)).toNat ≤ tropicalCriticalMultiplicity (berggrenPathMatrix w) := by
  -- Induction on Berggren word length using monoid homomorphism decomposition
  sorry

theorem squarefree_equality (w : List BerggrenGen) (hw : w ≠ []) : ω (hypotenuse (berggrenWordToTriple w)).toNat = tropicalCriticalMultiplicity (berggrenPathMatrix w) ↔ Squarefree (hypotenuse (berggrenWordToTriple w)).toNat := by
  -- Each distinct prime factor introduces exactly one degenerate permutation iff no prime appears with multiplicity > 1
  sorry

theorem valuation_superadditive (m n : ℕ+) (hm : IsBerggrenHypotenuse m) (hn : IsBerggrenHypotenuse n) : v_B (m * n) ≥ v_B m + v_B n := by
  -- Follows from berggren_monoid_hom and submultiplicativity of critical multiplicity
  sorry

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `tropical_fundamental_theorem_of_arithmetic` : theorem tropical_fundamental_theorem_of_arithmetic {a b : ℕ} (ha : 0 < a) (hb : 0 < b)
     (file: Tropical/Core/TropicalFactoring.lean)
  2. `tropical_classical_bridge` : theorem tropical_classical_bridge (a b : ℝ) :
     (file: Tropical/Core/FutureDirectionsV2.lean)
  3. `bool_and_as_tropical_max` : theorem bool_and_as_tropical_max :
     (file: Tropical/Core/HashInversion.lean)
  4. `tropical_mirror_theorem` : theorem tropical_mirror_theorem (a : ℝ) : max a a = a := max_self a
     (file: Tropical/AlgebraicMirror.lean)
  5. `tropical_and_bound` : theorem tropical_and_bound (c₁ c₂ : ℝ) (h₁ : 1 ≤ c₁) (h₂ : 1 ≤ c₂) :
     (file: Tropical/Oracles/OracleApplicationsFrontier.lean)

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



Recent successful concepts: Berggren–Farey Correspondence: Free Monoid Structure, PSL(2,ℤ) Faithfulness, and Continued Fraction Descent Encoding for Primitive Pythagorean Triples, Tropical Modular Lensing: Berggren Critical Curves, Cuspidal Factorization, and Max-Plus Geodesic Deflection on the Modular Tree, Tropical Holographic Duality: Max-Plus Conformal Extension from the Berggren Light Cone Boundary to the Tropical Upper Half-Plane and Satake Operator-State Correspondence


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

Research domain: Tropical
Research mode: prove
