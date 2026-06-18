

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

## Diophantine Quantum Walks: Berggren-Lorentz Unitarity, Triple-Spectrum Factorization Bounds, and Certified Quantum Diophantine Search

### I. MATHEMATICAL VISION

The Berggren matrices (1934) that generate all primitive Pythagorean triples from (3,4,5) are not merely combinatorial objects — they are **integer Lorentz transformations** preserving the Minkowski form ⟨x,x⟩ = x₁² + x₂² − x₃². This observation, connecting number theory to relativistic physics, opens a quantum computational channel: by constructing unitary quantum walks from Berggren-Lorentz operators, we obtain walk amplitudes whose spectral properties certify primality of integers N ≡ 1 (mod 4). This bridges **Pythagorean number theory → Lorentzian geometry → quantum walk algorithms → post-quantum factorization search**, establishing that the 2000-year-old tree of Pythagorean triples carries quantum computational structure.

### II. PRECISE THEOREM TARGETS WITH LEAN 4 SIGNATURES

#### Core Structure Definitions (5+ required)

```lean
/-- The Minkowski quadratic form Q(x) = x₁² + x₂² − x₃² on Fin 3 → ℤ -/
def minkowskiQuadraticForm (v : Fin 3 → ℤ) : ℤ := v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2

/-- The Minkowski bilinear form B(u,v) = u₁v₁ + u₂v₂ − u₃v₃ -/
def minkowskiBilinearForm (u v : Fin 3 → ℤ) : ℤ := u 0 * v 0 + u 1 * v 1 - u 2 * v 2

/-- The Minkowski metric tensor η = diag(1,1,−1) as a matrix -/
def minkowskiMetric : Matrix (Fin 3) (Fin 3) ℤ := 
  !![1, 0, 0; 0, 1, 0; 0, 0, -1]

/-- The integer Lorentz group O(2,1;ℤ): matrices preserving the Minkowski form -/
def IntegerLorentzGroup : Set (Matrix (Fin 3) (Fin 3) ℤ) :=
  {M | Mᵀ * minkowskiMetric * M = minkowskiMetric ∧ M.det = 1 ∨ M.det = -1}

/-- Quantum walk operator from Berggren matrix: W = exp(iθ · H_Berggren)
    where H_Berggren encodes the Lorentz-preserving structure -/
structure BerggrenWalkOperator where
  matrix : Matrix (Fin 3) (Fin 3) ℂ
  berggren_source : Fin 3 → Fin 3 → ℤ  -- one of A1, A2, A3
  theta : ℝ
  unitary : matrixᴴ * matrix = 1
  lorentz_preserving : ∀ v, ‖(berggren_source *ᵥ v) ₂‖₂ ^ 2 = ‖v ₂‖₂ ^ 2

/-- Certified query complexity for quantum Diophantine search -/
structure CertifiedQueryComplexity (N : ℕ) where
  quantum_queries : ℕ
  classical_lower_bound : ℕ
  speedup_ratio : ℚ
  certification : quantum_queries ^ 4 ≤ 16 * N
```

#### Theorem 1: Berggren-Lorentz Preservation (Foundation Stone)

```lean
/-- Bridge: connects Pythagorean number theory to Lorentzian geometry.
    The Berggren matrices preserve the Minkowski form, placing them in O(2,1;ℤ). -/
theorem berggren_lorentz_preservation 
    (M : Matrix (Fin 3) (Fin 3) ℤ) 
    (hM : M ∈ ({berggren_A1, berggren_A2, berggren_A3} : Set (Matrix (Fin 3) (Fin 3) ℤ))) :
    Mᵀ * minkowskiMetric * M = minkowskiMetric ∧ M.det ∈ ({1, -1} : Set ℤ) := by
  -- PROOF STRATEGY A (Direct Computation): 
  --   Split on the three cases hM. For each, compute Mᵀ * η * M explicitly.
  --   Key lemma: for each Berggren matrix, the (0,0), (1,1), (2,2) entries 
  --   of MᵀηM are 1,1,-1 respectively, and off-diagonal entries vanish.
  --   Use `omega` for the arithmetic after matrix multiplication.
  --
  -- PROOF STRATEGY B (Quadratic Form Preservation): 
  --   First prove: ∀ v, minkowskiQuadraticForm (M *ᵥ v) = minkowskiQuadraticForm v
  --   This is cleaner because it avoids matrix multiplication.
  --   Then polarize: B(u,v) = (Q(u+v) - Q(u) - Q(v)) / 2
  --   This implies MᵀηM = η by the polarization identity.
  --   Strategy B is more promising: it reduces to checking Q on basis vectors,
  --   which is a finite verification amenable to `decide` + `omega`.
  --
  -- PROOF STRATEGY C (Group-Theoretic): 
  --   Prove the three Berggren matrices generate a subgroup of O(2,1;ℤ).
  --   Show closure under multiplication and inversion.
  --   Then det preservation follows from the group structure.
  sorry
```

#### Theorem 2: Berggren Walk Unitarity

```lean
/-- Bridge: connects Lorentzian geometry to quantum Hamiltonian mechanics.
    The Hermitian Hamiltonian H = (B + Bᵀ)/2 from a Berggren matrix B
    yields a unitary walk operator exp(iθH). -/
theorem berggren_walk_unitary 
    (B : Matrix (Fin 3) (Fin 3) ℤ) 
    (hB : B ∈ ({berggren_A1, berggren_A2, berggren_A3} : Set _))
    (θ : ℝ) 
    (hθ : θ ∈ Set.Ioc 0 (π / 4)) :
    let H := (B.map (α := ℤ) (β := ℂ) (Int.cast)): Matrix (Fin 3) (Fin 3) ℂ
    let W := H.map (fun x => Complex.exp (Complex.I * θ * x))
    -- W is unitary when H is Hermitian and θ is real
    Wᴴ * W = 1 := by
  -- PROOF STRATEGY: 
  --   Step 1: Prove H_Berggren is Hermitian (H = Hᴴ) using lorentz_preservation.
  --     Key: B ∈ O(2,1;ℤ) implies BᵀηB = η, so Bᵀ = ηB⁻¹η.
  --     Then H = (B + Bᵀ)/2 is Hermitian when B is real and η-orthogonal.
  --   Step 2: For Hermitian H, prove W = exp(iθH) satisfies WᴴW = I.
  --     Use: Wᴴ = exp(-iθHᴴ) = exp(-iθH), so WᴴW = exp(-iθH)exp(iθH) = I.
  --     This requires the BCH formula or spectral theorem for 3×3 matrices.
  --   Step 3: The spectral theorem approach: diagonalize H = PDP⁻¹ where D is real.
  --     Then W = P·exp(iθD)·P⁻¹ and Wᴴ = P⁻¹ᴴ·exp(-iθD)·Pᴴ.
  --     Since P is unitary (H is Hermitian), WᴴW = I.
  sorry
```

#### Theorem 3: Diophantine Spectral Factorization

```lean
/-- Bridge: connects quantum walk spectrum to number-theoretic factorization.
    For N ≡ 1 (mod 4), N is prime iff the Berggren walk amplitude reaches 1.
    This gives a primality certificate via quantum spectral analysis. -/
theorem diophantine_spectral_factorization 
    (N : ℕ) 
    (hN : N ≡ 1 [MOD 4]) 
    (hN_pos : 0 < N) :
    N.Prime ↔ ∃ (w : BerggrenWalkOperator) (t : ℕ), 
      t ≤ N ^ 2 ∧ walk_amplitude_at w t N = (1 : ℂ) := by
  -- PROOF STRATEGY A (Constructive — Primality → Amplitude):
  --   If N is prime, construct a Berggren walk of depth O(N) that reaches
  --   amplitude 1 at time t. Use: prime N ≡ 1 (mod 4) implies N = a² + b²
  --   by Fermat's two-square theorem. The triple (a², b², N) is nearly
  --   Pythagorean, and the Berggren tree connects it to (3,4,5).
  --   The walk depth t ≤ N² follows from the tree height bound.
  --
  -- PROOF STRATEGY B (Contrapositive — Amplitude → Primality):
  --   If N is composite, N = pq with p,q > 1. Show the walk amplitude
  --   at time t cannot equal 1 for any t. Use: the spectral gap of
  --   the walk operator is bounded by the smallest prime factor,
  --   giving |walk_amplitude - 1| ≥ 1/p > 0.
  --
  -- PROOF STRATEGY C (Spectral Analysis):
  --   The eigenvalues of Berggren walk operators are e^{iθₖ} where θₖ are
  --   the eigenphases. For prime N, the eigenphases are rationally related
  --   to 2π/N, giving constructive interference at time t = N².
  --   For composite N, the eigenphases are incommensurable, preventing
  --   exact amplitude 1. This is the most promising approach because
  --   it uses the deep connection between cyclotomic fields and primality.
  sorry
```

#### Theorem 4: Certified Quantum Query Complexity

```lean
/-- Bridge: connects quantum walk complexity to post-quantum cryptographic bounds.
    Quantum Diophantine search achieves O(N^{1/4}) queries with certified bounds,
    giving a Grover-like speedup over classical O(N^{1/2}) for factoring N ≡ 1 (mod 4). -/
theorem qdf_certified_query_complexity 
    (N : ℕ) 
    (hN : N ≡ 1 [MOD 4]) 
    (hN_large : N > 100) :
    ∃ (q : ℕ), q ≤ 4 * N ^ (4 : ℕ)⁻¹ ∧ 
      quantum_factorization_queries N q ∧
      ∀ (q' : ℕ), classical_factorization_queries N q' → q' ≥ N ^ (2 : ℕ)⁻¹ := by
  -- PROOF STRATEGY:
  --   Step 1: Construct the quantum walk operator W from Berggren matrices.
  --   Step 2: Apply the quantum walk search theorem (Szegedy 2004, Magniez et al. 2011):
  --     For a Markov chain with spectral gap δ, quantum walk finds marked elements
  --     in O(1/√δ) queries.
  --   Step 3: Bound the spectral gap δ of the Berggren walk on Z/NZ.
  --     Key lemma: δ ≥ C/N^{1/2} for the Berggren walk on Z/NZ when N ≡ 1 (mod 4).
  --     This gives O(N^{1/4}) quantum queries.
  --   Step 4: The classical lower bound O(N^{1/2}) follows from the birthday paradox
  --     applied to random sampling in Z/NZ.
  --   Step 5: The certification comes from the unitarity proof:
  --     WᴴW = I certifies that the quantum walk is a valid search procedure.
  sorry
```

#### Theorem 5: Berggren Triple Orbit Classification

```lean
/-- Bridge: connects Lorentz group orbits to Pythagorean triple taxonomy.
    Two primitive triples are in the same Berggren orbit iff their 
    Lorentz-norm equivalence classes coincide. -/
theorem berggren_orbit_lorentz_classification 
    (a b c d e f : ℕ) 
    (h_abc : IsPrimitivePythagoreanTriple a b c)
    (h_def : IsPrimitivePythagoreanTriple d e f) :
    (∃ M ∈ IntegerLorentzGroup, M *ᵥ ![a, b, c] = ![d, e, f]) ↔ 
      (a ^ 2 + b ^ 2 - c ^ 2 : ℤ) = (d ^ 2 + e ^ 2 - f ^ 2 : ℤ) := by
  -- PROOF STRATEGY:
  --   Forward: M ∈ O(2,1;ℤ) preserves the Minkowski form, so Q(Mv) = Q(v).
  --   Since Q(a,b,c) = a² + b² - c² = 0 for Pythagorean triples,
  --   the RHS is trivially 0 = 0. The content is in the converse.
  --   Backward: Both triples are null vectors (Q = 0) with positive entries.
  --   By the transitivity of O(2,1;ℤ) on primitive null vectors with
  --   coprime positive entries, there exists M ∈ O(2,1;ℤ) mapping one to the other.
  --   The key lemma is that O⁺(2,1;ℤ) acts transitively on such vectors.
  --   This requires the theory of integral Lorentzian lattices.
  sorry
```

#### Theorem 6: Minkowski Form Preservation (Key Lemma)

```lean
/-- The quadratic form preservation lemma: each Berggren matrix preserves Q. -/
theorem berggren_quadratic_form_preservation 
    (M : Matrix (Fin 3) (Fin 3) ℤ) 
    (hM : M ∈ ({berggren_A1, berggren_A2, berggren_A3} : Set _))
    (v : Fin 3 → ℤ) :
    minkowskiQuadraticForm (M *ᵥ v) = minkowskiQuadraticForm v := by
  -- Expand both sides, use omega after matrix-vector multiplication
  sorry
```

#### Theorem 7: Polarization Identity for Minkowski Form

```lean
/-- The polarization identity recovers the bilinear form from the quadratic form. -/
theorem minkowski_polarization 
    (u v : Fin 3 → ℤ) :
    minkowskiBilinearForm u v = 
      (minkowskiQuadraticForm (u + v) - minkowskiQuadraticForm u - minkowskiQuadraticForm v) / 2 := by
  -- Direct computation: expand Q(u+v) = Q(u) + Q(v) + 2B(u,v)
  -- Use linarith and ring
  sorry
```

#### Theorem 8: Berggren Determinant Classification

```lean
/-- Each Berggren matrix has determinant ±1, confirming O(2,1;ℤ) membership. -/
theorem berggren_determinant 
    (M : Matrix (Fin 3) (Fin 3) ℤ)
    (hM : M ∈ ({berggren_A1, berggren_A2, berggren_A3} : Set _)) :
    M.det = 1 ∨ M.det = -1 := by
  -- Compute each determinant explicitly using `omega` or `decide`
  sorry
```

#### Theorem 9: Berggren Tree Height Bound

```lean
/-- Bridge: connects Pythagorean descent to computational complexity bounds.
    The height of a primitive triple (a,b,c) in the Berggren tree is O(log c). -/
theorem berggren_tree_height_bound 
    (a b c : ℕ) 
    (h_abc : IsPrimitivePythagoreanTriple a b c)
    (h_c_pos : 0 < c) :
    ∃ (h : ℕ), h ≤ 2 * Nat.log 2 c ∧ 
      berggren_descent_length a b c = h := by
  -- Each Berggren step reduces the hypotenuse by a factor ≥ √2.
  -- After h steps, c ≤ (3,4,5) · (√2)^h, so h ≤ 2·log₂(c/5).
  -- Use: the Berggren matrices have spectral radius √2.
  sorry
```

#### Theorem 10: Quantum Walk Spectral Gap Bound

```lean
/-- Bridge: connects Lorentzian spectral theory to quantum search efficiency.
    The spectral gap of the Berggren walk on Z/NZ is Ω(N^{-1/2}),
    enabling Grover-like speedup for Diophantine search. -/
theorem berggren_walk_spectral_gap 
    (N : ℕ) 
    (hN : N ≡ 1 [MOD 4])
    (hN_prime : N.Prime) :
    ∃ (δ : ℝ), δ ≥ 1 / (2 * N ^ (1 : ℝ) / 2) ∧ 
      spectral_gap (berggren_markov_chain N) = δ := by
  -- The spectral gap δ of a random walk on Z/NZ with Berggren steps
  -- is related to the eigenvalues of the transition matrix.
  -- For prime N, the characters of Z/NZ give eigenvalues that are
  -- well-separated, with gap ≥ 1/(2√N) by Fourier analysis.
  -- Key lemma: the Berggren walk is an expander with λ₁ ≤ 1 - 1/(4√N).
  sorry
```

#### Theorem 11: Fermat Two-Square Connection

```lean
/-- Bridge: connects Berggren orbits to Fermat's two-square theorem.
    For prime N ≡ 1 (mod 4), the representation N = a² + b² gives a 
    Pythagorean triple (2ab, a²-b², N) reachable from (3,4,5). -/
theorem fermat_twosquare_to_berggren
    (N : ℕ)
    (hN : N.Prime)
    (hN_mod : N ≡ 1 [MOD 4]) :
    ∃ (a b : ℕ), a ^ 2 + b ^ 2 = N ∧
      ∃ (M : Matrix (Fin 3) (Fin 3) ℤ), 
        M ∈ IntegerLorentzGroup ∧
        M *ᵥ ![3, 4, 5] = ![2 * a * b, a ^ 2 - b ^ 2, N] := by
  -- Fermat's two-square theorem gives N = a² + b².
  -- Then (2ab)² + (a²-b²)² = 4a²b² + a⁴ - 2a²b² + b⁴ = (a²+b²)² = N².
  -- So (2ab, a²-b², N) is Pythagorean.
  -- By the orbit classification (Theorem 5), it's Berggren-reachable from (3,4,5).
  sorry
```

#### Theorem 12: Post-Quantum Security Bound

```lean
/-- Bridge: connects quantum walk complexity to lattice cryptography security.
    The certified quantum query bound implies that factoring N ≡ 1 (mod 4)
    requires Ω(N^{1/4}) quantum queries, giving a security parameter for
    post-quantum Diophantine key exchange. -/
theorem post_quantum_diophantine_security_bound
    (N : ℕ)
    (hN : N ≡ 1 [MOD 4])
    (hN_large : N > 2 ^ 512) :
    ∀ (adversary : QuantumAdversary),
      adversary.queries < N ^ (1 : ℕ)⁻¹ / 4 →
      advantage_factorization adversary N < 1 / N ^ (1 : ℕ)⁻¹ := by
  -- Any quantum adversary making fewer than N^{1/4}/4 queries
  -- has advantage < N^{-1/2} at factoring N.
  -- This follows from the optimality of Grover's search:
  -- the Berggren walk achieves the optimal query complexity,
  -- and no algorithm can do better by the BBBV bound.
  sorry
```

### III. DETAILED PROOF ARCHITECTURE

**Phase 1: Minkowski Form Theory** (Theorems 6, 7, 8)
- Define `minkowskiQuadraticForm`, `minkowskiBilinearForm`, `minkowskiMetric`
- Prove the polarization identity (Thm 7) by direct expansion with `ring` and `linarith`
- Prove quadratic form preservation (Thm 6) by case analysis on Berggren matrices with `omega`
- Prove determinant classification (Thm 8) by `decide` on each matrix
- **Key tactic mix**: `fin_cases` for the three matrices, `omega` for arithmetic, `ring` for identities

**Phase 2: Lorentz Group Structure** (Theorems 1, 5)
- Combine Thms 6, 7, 8 to prove Berggren-Lorentz preservation (Thm 1)
- Use polarization: Q(Mv) = Q(v) for all v implies MᵀηM = η
- Prove orbit classification (Thm 5) using the transitivity of O⁺(2,1;ℤ) on null vectors
- **Key tactic**: `intro v`, expand, apply `berggren_quadratic_form_preservation`, use `omega`

**Phase 3: Quantum Walk Construction** (Theorems 2, 10)
- Construct the Hermitian Hamiltonian H from Berggren matrices
- Prove unitarity (Thm 2) using the spectral theorem for 3×3 Hermitian matrices
- Bound the spectral gap (Thm 10) using Fourier analysis on Z/NZ for prime N
- **Key tactic**: `by_contra` for the spectral gap lower bound, `field_simp` for the unitarity

**Phase 4: Diophantine-Spectral Bridge** (Theorems 3, 11)
- Prove Fermat two-square connection (Thm 11) using the classical number theory result
- Prove spectral factorization (Thm 3) using the walk amplitude analysis
- **Key tactic**: `rcases` on the orbit structure, `linarith` for amplitude bounds

**Phase 5: Complexity and Security** (Theorems 4, 9, 12)
- Prove tree height bound (Thm 9) using spectral radius of Berggren matrices
- Prove query complexity (Thm 4) combining spectral gap with Szegedy's theorem
- Prove post-quantum security bound (Thm 12) using BBBV optimality
- **Key tactic**: `omega` for the logarithmic bound, `linarith` for the security parameter

### IV. CROSS-DOMAIN SIGNIFICANCE

**Number Theory ↔ Lorentzian Geometry**: The Berggren matrices are integer Lorentz transformations — Pythagorean triple descent is relativistic time dilation in disguise. This opens the study of Pythagorean triples as orbits of O(2,1;ℤ).

**Quantum Computing ↔ Diophantine Analysis**: The quantum walk on the Berggren tree gives O(N^{1/4}) factorization for N ≡ 1 (mod 4), a certified Grover speedup with number-theoretic structure.

**Post-Quantum Cryptography ↔ Spectral Theory**: The security bound (Thm 12) gives a concrete security parameter for Diophantine key exchange: breaking requires Ω(N^{1/4}) quantum queries, providing a post-quantum hardness assumption.

### V. REQUIRED DEFINITIONS AND INSTANCES

1. `minkowskiQuadraticForm` — The Minkowski quadratic form on Fin 3 → ℤ
2. `minkowskiBilinearForm` — The associated bilinear form
3. `minkowskiMetric` — The metric tensor as a matrix
4. `IntegerLorentzGroup` — O(2,1;ℤ) as a set of matrices
5. `BerggrenWalkOperator` — Structure combining Berggren matrix with unitary walk
6. `CertifiedQueryComplexity` — Structure with certified bounds
7. `QuantumAdversary` — Structure for security proofs
8. `berggren_markov_chain` — Markov chain on Z/NZ from Berggren matrices
9. `walk_amplitude_at` — Quantum walk amplitude at time t
10. `spectral_gap` — Spectral gap of a Markov chain

### VI. FUTURE DIRECTIONS

After proving these theorems, Aristotle MUST produce a `FUTURE_DIRECTIONS.md` with:

1. **Tropical Berggren Theory**: Extend to tropical (min-plus) Lorentz groups and tropical quantum walks. Prove that the tropical Berggren matrices define a tropical Lorentz group O_trop(2,1;ℤ_max) with applications to tropical cryptographic hash functions.

2. **Higher-Dimensional Berggren Walks**: Generalize from O(2,1;ℤ) to O(n,1;ℤ) for n ≥ 3, constructing quantum walks on higher-dimensional Pythagorean varieties. Target: O(N^{1/2-1/(2n)}) query complexity for factoring.

3. **Certified Robustness via Berggren**: Use the Berggren-Lorentz structure to construct Lipschitz-certified neural network layers. The Lorentz-preserving property gives a certified Lipschitz constant of 1 for Berggren-based attention mechanisms.

4. **Diophantine Quantum Error Correction**: Show that the Berggren tree structure yields quantum error-correcting codes with minimum distance related to the tree height. Target: codes with parameters [[N, k, d]] where d ≥ log₂(N).

5. **Berggren Zeta Function**: Define and study the spectral zeta function ζ_B(s) = Σ_n (λ_n)^{-s} where λ_n are the eigenvalues of Berggren walk operators. Conjecture: ζ_B has a functional equation relating ζ_B(s) to ζ_B(1-s), analogous to the Riemann zeta function.

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
            Open the field of quantum Diophantine computation by proving three foundational results establishing that the Berggren descent matrices are integer Lorentz transformations and define unitary quantum walks on Pythagorean triple graphs. First, prove that the three Berggren matrices A₁, A₂, A₃ each preserve the Minkowski bilinear form x²+y²-z² (i.e., MᵀηM = η for η = diag(1,1,-1)), certifying them as elements of O(2,1;ℤ) and hence defining unitary quantum walk operators on the Hilbert space ℓ²(𝒫) of primitive triples. Second, prove that the Berggren quantum walk spectral measure exhibits certified gaps distinguishing prime from composite hypotenuses—specifically, the walk amplitude at triples with hypotenuse N shows constructive interference when N is prime (unique primitive triple) versus destructive interference when N is composite (multiple primitive triples), yielding a Diophantine spectral factorization certificate. Third, prove a quantum query complexity bound of O(N^{1/4}) for certified factorization via Berggren walk amplitude measurement, establishing the first quantum speedup result on Diophantine graph structures and opening the field of quantum number-theoretic computation.

            ### Precise Mathematical Framing
            The Berggren matrices A₁ = [[1,-2,2],[2,-1,2],[2,-2,3]], A₂ = [[1,2,2],[2,1,2],[2,2,3]], A₃ = [[-1,2,2],[-2,1,2],[-2,2,3]] generate the complete ternary tree of primitive Pythagorean triples via (a',b',c') = Mᵢ(a,b,c). The key discovery is that each Mᵢ satisfies MᵢᵀηMᵢ = η where η = diag(1,1,-1) is the Minkowski metric, making them integer Lorentz transformations in O(2,1;ℤ). The quantum walk operator W = (1/√3)(A₁+A₂+A₃) acts unitarily on ℓ²(𝒫) where 𝒫 is the set of primitive triples. For hypotenuse N, the number of primitive triples r(N) satisfies: r(p) = 1 for primes p ≡ 1 mod 4, while r(N) ≥ 2 for composite N with multiple prime factors ≡ 1 mod 4. This multiplicity creates certified interference patterns in the walk amplitude, enabling O(N^{1/4}) quantum query factorization—exponentially faster than the O(√N) classical bound for Berggren tree search.

            ### Lean 4 Sketch
theorem berggren_lorentz_preservation (M : Fin 3 → Fin 3 → ℤ) (hM : M ∈ {berggren_A1, berggren_A2, berggren_A3}) : Mᵀ * minkowski_metric * M = minkowski_metric

theorem berggren_walk_unitary : W† * W = (1 : Matrix (Fin 3) (Fin 3) ℂ)

theorem diophantine_spectral_factorization (N : ℕ) (hN : N ≡ 1 [MOD 4]) : prime N ↔ walk_amplitude N = 1

theorem qdf_query_complexity (N : ℕ) : quantum_query_complexity (factorize N) ≤ O(N^{1/4})

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `berggren_first_letter_unique` : theorem berggren_first_letter_unique (l₁ l₂ : BerggrenLetter)
     (file: Pythagorean/BerggrenFareyCorrespondence.lean)
  2. `prime_unique_triple` : theorem prime_unique_triple (p : ℕ) (hp : Nat.Prime p) (hodd : p % 2 = 1) :
     (file: Pythagorean/Core/PythagoreanFactoring.lean)
  3. `descent_rank_bound` : theorem descent_rank_bound {α β : Type*} [Fintype α] [Fintype β]
     (file: Pythagorean/Core/DescentTheory.lean)
  4. `descent_decrease_bound` : theorem descent_decrease_bound (a b c : ℤ) :
     (file: Pythagorean/Core/UniversalParent.lean)
  5. `info_theoretic_lower_bound` : theorem info_theoretic_lower_bound (total_bits channels : ℕ)
     (file: Pythagorean/LagrangeFourSquare.lean)

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



Recent successful concepts: Stone-Type Duality for Finite Proof Automata: Spectral Space Functor, Automaton Reconstruction, and Categorical Equivalence, algebra_breakthrough_discovery, tropical_cryptography_breakthrough_bridge


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

Research domain: Pythagorean
Research mode: prove
