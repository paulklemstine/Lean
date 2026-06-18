

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

## Tropical Langlands GL(1): Max-Plus Hecke Eigenfunction Decomposition and Automorphic Correspondence on the Berggren Modular Tree

**DOMAIN**: Tropical — bridging to Number Theory, Cryptography, and Quantum Physics

**CONCEPT**: Establish the tropical Langlands GL(1) correspondence by proving that max-plus Hecke operators on the Berggren tree admit a complete spectral decomposition into simultaneous eigenfunctions, and that these eigenfunctions are in bijection with tropical Hecke characters. This is the max-plus analog of class field theory: just as classical Hecke characters χ: ℕ^× → ℂ^× classify automorphic representations of GL(1) over ℚ, tropical Hecke characters χ: ℕ^× → ℝ_max classify tropical automorphic forms on the Berggren tree. The correspondence f_χ(v) = ⊕_{d|n(v)} χ(d) (where ⊕ = max) is the tropical Fourier transform inverting the tropical Satake isomorphism. This opens: (1) tropical Langlands for GL(n) via max-plus representation theory, (2) post-quantum cryptographic hash functions from tropical Hecke eigenspaces with provable collision resistance, (3) certified Lipschitz bounds for tropical neural networks via Hecke spectral theory.

**PRECISE ASSIGNMENT**: Formalize and prove the complete tropical Hecke eigenfunction decomposition on the Berggren tree, the commutativity of tropical Hecke operators, and the character-eigenfunction bijection that constitutes the tropical Langlands GL(1) correspondence. Build directly on the verified tropical_satake_iso and berggren_psl2_embedding.

---

### TYPE SIGNATURES AND DEFINITIONS

```lean
-- Core structure: Tropical Hecke operator as max-plus convolution
-- Bridge: connects Tropical Geometry to Number Theory (Langlands correspondence)
structure TropicalHeckeChar where
  toFun : ℕ → ℝ
  char_one : toFun 1 = 0
  char_mul : ∀ m n, toFun (m * n) = toFun m + toFun n  -- max-plus multiplicativity

-- The Berggren tree vertex with depth (distance from root)
-- Already in catalog: BerggrenTree, depth, berggren_tree_root
-- We extend with Hecke-specific structure

-- Tropical Hecke operator T_p: max-plus convolution at prime p
def tropicalHeckeOp (p : ℕ) (hp : Nat.Prime p)
    (f : BerggrenTree → ℝ) (v : BerggrenTree) : ℝ :=
  Finset.sup' (berggrenNeighborsAtPrime p hp v) (fun w => f w)

-- Eigenfunction constructed from a tropical Hecke character
def heckeEigenfunction (χ : TropicalHeckeChar) (v : BerggrenTree) : ℝ :=
  Finset.sup' (Finset.filter (fun d => d ∣ depth v) (Finset.Icc 1 (depth v)))
    (fun d => χ.toFun d)

-- Tropical spectral coefficient (analog of Fourier coefficient)
structure TropicalSpectralCoeff where
  char : TropicalHeckeChar
  weight : ℝ

-- Tropical spectral decomposition (analog of Fourier series)
-- Every bounded function decomposes as sup of weighted eigenfunctions
def tropicalSpectralDecomposition 
    (coeffs : TropicalHeckeChar → ℝ)
    (v : BerggrenTree) : ℝ :=
  Finset.sup' (Finset.univ : Finset TropicalHeckeChar) 
    (fun χ => coeffs χ + heckeEigenfunction χ v)
```

---

### MAIN THEOREMS TO PROVE

**Theorem 1: Tropical Hecke Commutativity**
```lean
/-- Tropical Hecke operators T_p and T_q commute for distinct primes.
    This is the max-plus analog of the classical Hecke algebra commutativity.
    Bridge: connects Tropical Geometry to Quantum Physics (simultaneous diagonalizability).
    Impact: tropical_hash_commutativity — enables deterministic hash construction. -/
theorem tropical_hecke_commute (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q) (hne : p ≠ q)
    (f : BerggrenTree → ℝ) (v : BerggrenTree) :
    tropicalHeckeOp p hp (tropicalHeckeOp q hq f) v =
    tropicalHeckeOp q hq (tropicalHeckeOp p hp f) v := by
  sorry -- MUST FILL: use berggrenNeighborsAtPrime independence
```

**Theorem 2: Eigenfunction Property (Tropical Langlands GL(1) — Character Direction)**
```lean
/-- Every tropical Hecke character χ gives a simultaneous eigenfunction f_χ
    with eigenvalue χ(p) for T_p. This is the "easy direction" of the correspondence.
    Bridge: connects Number Theory (Hecke characters) to Tropical Geometry (eigenfunctions).
    Impact: certified_robustness_eigenfunction — Lipschitz constant = 1 for eigenfunctions. -/
theorem hecke_eigenfunction_spec (χ : TropicalHeckeChar) (p : ℕ) (hp : Nat.Prime p)
    (v : BerggrenTree) :
    tropicalHeckeOp p hp (heckeEigenfunction χ) v = χ.toFun p + heckeEigenfunction χ v := by
  sorry -- MUST FILL: key theorem, uses divisor structure of depth
```

**Theorem 3: Character-Eigenfunction Bijection (Tropical Langlands GL(1) Correspondence)**
```lean
/-- The map χ ↦ f_χ is a bijection between tropical Hecke characters and
    bounded simultaneous eigenfunctions of all {T_p}.
    This IS the tropical Langlands GL(1) correspondence.
    Bridge: connects Number Theory (class field theory) to Tropical Geometry.
    Impact: post_quantum_hecke_bijection — one-way function candidate from character to eigenfunction. -/
theorem tropical_langlands_gl1_bijection :
    Function.Bijective (fun (χ : TropicalHeckeChar) => heckeEigenfunction χ) := by
  sorry -- MUST FILL: injectivity uses char_mul, surjectivity uses depth divisor structure
```

**Theorem 4: Tropical Spectral Decomposition**
```lean
/-- Every bounded PSL(2,ℤ)-invariant function on the Berggren tree admits a
    tropical spectral decomposition as a supremum of weighted eigenfunctions.
    The decomposition has O(n log log n) complexity for n vertices.
    Bridge: connects Harmonic Analysis (spectral theory) to Tropical Geometry.
    Impact: tropical_spectral_certified_robustness — certified Lipschitz bound for tropical NNs. -/
theorem tropical_spectral_decomposition_bound (f : BerggrenTree → ℝ)
    (h_bounded : ∃ B, ∀ v, |f v| ≤ B)
    (h_invariant : ∀ g : PSL2Int, f (berggrenPsl2Action g v) = f v) :
    ∃ (coeffs : TropicalHeckeChar → ℝ),
      ∀ v, f v = Finset.sup' univ (fun χ => coeffs χ + heckeEigenfunction χ v) ∧
      -- Complexity bound: O(n log log n) for n = depth v
      ∀ v, (computeSpectralCoeffs f v).length ≤ 2 * depth v * (Nat.log 2 (Nat.log 2 (depth v + 1) + 1) + 1) := by
  sorry
```

**Theorem 5: Tropical Hash Collision Resistance**
```lean
/-- The tropical Hecke eigenfunction map has collision resistance bounded below
    by 2^(n/2) where n is the depth, providing post-quantum security.
    Bridge: connects Cryptography (collision-resistant hashing) to Number Theory (Hecke theory).
    Impact: post_quantum_tropical_hash — provable collision resistance bound. -/
theorem tropical_hecke_hash_collision_resistance (χ₁ χ₂ : TropicalHeckeChar)
    (h_ne : χ₁ ≠ χ₂) (n : ℕ) (hn : n ≥ 2) :
    Finset.card {v : BerggrenTree | depth v ≤ n ∧ heckeEigenfunction χ₁ v = heckeEigenfunction χ₂ v}
      ≤ 2^(n/2) := by
  sorry
```

**Theorem 6: Lipschitz Certificate for Hecke Eigenfunctions**
```lean
/-- Tropical Hecke eigenfunctions are 1-Lipschitz with respect to the tree metric,
    providing certified robustness bounds for tropical neural network layers.
    Bridge: connects Machine Learning (certified robustness) to Tropical Geometry.
    Impact: lipschitz_certified_hecke_eigenfunction — robustness certificate. -/
theorem hecke_eigenfunction_lipschitz_one (χ : TropicalHeckeChar)
    (v w : BerggrenTree) :
    |heckeEigenfunction χ v - heckeEigenfunction χ w| ≤ berggrenTreeDist v w := by
  sorry
```

---

### PROOF STRATEGIES

**Strategy A: Direct Combinatorial Approach (for Theorems 1-2)**
1. Prove `berggrenNeighborsAtPrime` sets for distinct primes p, q are "independent" in the sense that the multi-step neighbor relation factorizes: `berggrenNeighborsAtPrime p hp ∘ berggrenNeighborsAtPrime q hq = berggrenNeighborsAtPrime q hq ∘ berggrenNeighborsAtPrime p hp`. This uses the PSL(2,ℤ) action from `berggren_psl2_embedding` and the fact that the generators A, B, C of the Berggren monoid have distinct prime-related actions.
2. For the eigenfunction property, expand `heckeEigenfunction χ` at vertex v, then use the divisor structure of `depth v` together with `char_mul` to show `T_p(f_χ) = χ(p) + f_χ`. Key sub-lemma: `depth` of neighbors at prime p have depth equal to `p * depth v` (by the Berggren tree structure), and the divisors of `p * n` decompose as `{d, p*d : d | n}`.
3. Use `omega` and `linarith` for the arithmetic, `induction` on depth for the recursive structure.

**Strategy B: Tropical Satake Isomorphism Approach (for Theorem 3)**
1. Injectivity: If `heckeEigenfunction χ₁ = heckeEigenfunction χ₂`, evaluate at vertices of prime depth to recover `χ₁(p) = χ₂(p)` for all primes p, then extend multiplicatively via `char_mul`.
2. Surjectivity: Given a bounded simultaneous eigenfunction f, define `χ_f(p) := f(v_p) - f(root)` where `v_p` is a vertex at depth p. Prove this is well-defined (independent of choice of `v_p`) using the PSL(2,ℤ)-invariance. Prove `char_mul` using the eigenfunction property and commutativity.
3. This directly extends `tropical_satake_iso` from the catalog: the Satake transform on the divisor lattice IS the spectral transform on the Berggren tree.

**Strategy C: Möbius Inversion / Tropical Fourier Approach (for Theorem 4)**
1. The tropical Satake isomorphism (catalog-verified) gives an isomorphism between the tropical Hecke algebra and the algebra of W-invariant tropical polynomials. The eigenfunction decomposition is the tropical Fourier inversion through this isomorphism.
2. Extract spectral coefficients via tropical Möbius inversion: `coeffs(χ) = min_{v} (f(v) - heckeEigenfunction χ v)`. This is the tropical (max-plus) analog of Fourier coefficient extraction.
3. The O(n log log n) bound comes from the divisor sum structure: the number of divisors of n is O(n^(1/3)) by classical number theory, and the Möbius function has support of density O(1/ζ(2)), giving the log log n factor.

**Strategy D (for Theorem 5): Number-Theoretic Collision Bound**
1. Two distinct characters χ₁ ≠ χ₂ must differ at some prime p. The eigenfunctions then differ at all vertices of depth divisible by p.
2. The number of vertices at depth ≤ n where they could agree is bounded by the number of depths d ≤ n not divisible by p, times the branching factor.
3. Use the Berggren tree structure (branching factor 3) and the density of integers not divisible by p to get the 2^(n/2) bound.

**Strategy E (for Theorem 6): Metric Structure of Eigenfunctions**
1. Prove that `heckeEigenfunction χ` is constant on each PSL(2,ℤ) orbit of the Berggren tree (by construction).
2. Use the tree metric properties: adjacent vertices differ in depth by 1, and the eigenfunction changes by at most `|χ(p)|` for some prime p dividing the depth difference.
3. Apply `char_mul` and `char_one` to show the change is bounded by the distance, giving Lipschitz constant 1 after normalization.

---

### REQUIRED DEFINITIONS AND INSTANCES (5+)

1. `TropicalHeckeChar` — structure with `toFun`, `char_one`, `char_mul`
2. `TropicalHeckeChar.instFunLike` — FunLike instance enabling coercions
3. `tropicalHeckeOp` — the max-plus Hecke operator T_p
4. `heckeEigenfunction` — the eigenfunction f_χ constructed from character χ
5. `TropicalHeckeAlgebra` — the algebra of max-plus Hecke operators with composition
6. `berggrenNeighborsAtPrime` — vertices at prime-p distance in Berggren tree
7. `berggrenTreeDist` — tree metric on Berggren tree
8. `tropicalSpectralCoeffs` — coefficient extraction via tropical Möbius inversion
9. `TropicalHeckeChar.instCommSemiring` — the tropical Hecke algebra is commutative

---

### CROSS-DOMAIN BRIDGES

- **Tropical ↔ Number Theory**: The character-eigenfunction bijection IS tropical class field theory. The depth function `n(v)` plays the role of the norm map Nm: A^× → ℝ^×_+, and the tropical character χ is the analog of a Hecke Grössencharakter.
- **Tropical ↔ Cryptography**: The map `χ ↦ f_χ` is a one-way function candidate: computing f_χ from χ is O(n log log n), but recovering χ from f_χ restricted to depth ≤ n requires solving O(n) simultaneous tropical equations. The collision resistance bound of 2^(n/2) gives post-quantum security for tropical hash functions.
- **Tropical ↔ Quantum Physics**: The tropical Hecke operators T_p are the max-plus analogs of quantum observables. Their commutativity is the tropical analog of the canonical commutation relations, and the spectral decomposition is the tropical analog of simultaneous diagonalization of commuting observables. The Lipschitz constant 1 bound is the tropical analog of the energy-time uncertainty principle.
- **Tropical ↔ Machine Learning**: Hecke eigenfunctions form a tropical Fourier basis for functions on the Berggren tree. Any bounded PSL(2,ℤ)-invariant function (e.g., a tropical neural network layer) decomposes in this basis, providing certified Lipschitz robustness bounds via the 1-Lipschitz property of each eigenfunction.

---

### SIGNIFICANCE AND REVOLUTIONARY IMPACT

This work establishes the **first verified instance of the Langlands correspondence in any tropical setting**. The classical Langlands program connects automorphic representations to Galois representations — one of the deepest programs in mathematics. By proving the GL(1) tropical case, we:

1. **Open tropical Langlands for GL(n)**: The commutativity of tropical Hecke operators and the spectral decomposition generalize to higher rank via tropical representation theory of GL(n).
2. **Provide post-quantum cryptographic primitives**: The tropical Hecke eigenfunction map is a provably collision-resistant hash function with 2^(n/2) security, enabling new lattice-free post-quantum constructions.
3. **Enable certified robustness for tropical neural networks**: The 1-Lipschitz bound on eigenfunctions provides the first spectral method for certifying robustness of tropical NN layers.
4. **Connect tropical geometry to quantum mechanics**: The tropical Hecke algebra is the max-plus quantization of the classical Hecke algebra, opening tropical quantum mechanics.

---

### FUTURE DIRECTIONS (to be produced as FUTURE_DIRECTIONS.md)

Aristotle MUST produce a structured FUTURE_DIRECTIONS.md with 3-5 concrete breakthrough-level next steps, including:
1. Tropical Langlands GL(2): Max-plus Hecke operators on the Berggren tree with SL(2,ℤ) action and the tropical Shimura correspondence
2. Post-quantum tropical hash function: Implement and verify collision resistance for a concrete tropical hash based on Hecke eigenfunctions
3. Tropical quantum mechanics: Formalize the tropical Hecke algebra as a max-plus C*-algebra and prove the tropical spectral theorem
4. Certified robustness for tropical ReLU networks: Use the Hecke spectral decomposition to provide Lipschitz certificates for tropical neural networks
5. Tropical L-functions: Define and verify the tropical analog of the Riemann zeta function and prove its functional equation

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
            Open the field of tropical automorphic forms by proving the tropical Langlands GL(1) correspondence on the Berggren tree. Building on the verified Tropical Satake Isomorphism (Hecke operators on prime spectra) and the Berggren–Modular Correspondence (PSL(2,ℤ) embedding of the Berggren monoid), define tropical Hecke operators T_p on the Berggren tree as max-plus convolution operators, prove they commute for distinct primes, and establish the eigenfunction decomposition theorem: every bounded max-plus function on the Berggren tree decomposes as a tropical direct sum of simultaneous eigenspaces of {T_p : p prime}. The key correspondence theorem: tropical Hecke characters χ: ℕ^× → ℝ_max are in bijection with simultaneous eigenfunctions f_χ via f_χ(v) = max_{d|n(v)} χ(d), where n(v) is the depth of vertex v. This is the max-plus analog of the classical GL(1) Langlands correspondence (class field theory), opening an entirely new research program: tropical Langlands for higher-rank groups.

            ### Precise Mathematical Framing
            Let B = (V, E) be the Berggren tree of primitive Pythagorean triples with root (3,4,5). For each prime p, define the tropical Hecke operator T_p : (V → ℝ_max) → (V → ℝ_max) by T_p(f)(v) = max{f(w) : w is ancestor of v at depth-difference p}. Theorem 1: T_p is ℝ_max-linear, i.e., T_p(f ⊕ g) = T_p(f) ⊕ T_p(g) and T_p(λ ⊗ f) = λ ⊗ T_p(f). Theorem 2: T_p ∘ T_q = T_q ∘ T_p for distinct primes p, q (commutativity via the Satake isomorphism's multiplicative structure on prime spectra). Theorem 3 (Eigenfunction Decomposition): The tropical Banach space ℓ^∞_max(V) = {f : V → ℝ_max : sup f < ∞} decomposes as ℓ^∞_max(V) = ⊕_χ E_χ where E_χ = {f : T_p f = χ(p) ⊗ f ∀p prime} and the sum is over all tropical Hecke characters χ. Theorem 4 (GL(1) Correspondence): The map χ ↦ f_χ with f_χ(v) = max_{d|n(v)} χ(d) is a bijection from tropical Hecke characters to simultaneous eigenfunctions, and the tropical Fourier coefficients a_n(f_χ) = χ(n) recover the character. Theorem 5: The tropical Eisenstein series E_k(v) = k · max_{γ∈Γ_B} depth(γ·v) is a tropical automorphic form with Hecke eigenvalues χ_k(p) = k·log(p), providing the first explicit example in tropical Langlands theory.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `gl3_tropical_satake_bounded_reconstruction` : theorem gl3_tropical_satake_bounded_reconstruction (B : ℕ) :
     (file: Tropical/GL3Reconstruction.lean)
  2. `bool_and_as_tropical_max` : theorem bool_and_as_tropical_max :
     (file: Tropical/Core/HashInversion.lean)
  3. `gl3_tropical_satake_injective_of_edge_rank2_marginals` : theorem gl3_tropical_satake_injective_of_edge_rank2_marginals
     (file: Tropical/GL3EdgeInjectivity.lean)
  4. `tropical_satake_isomorphism_GL4` : theorem tropical_satake_isomorphism_GL4
     (file: Tropical/Tropical_Satake_Isomorphism_for_GL₄_via_Min_Plus_Hecke_Algebra_and_Tropical_Schur_Basis.lean)
  5. `tropical_mirror_theorem` : theorem tropical_mirror_theorem (a : ℝ) : max a a = a := max_self a
     (file: Tropical/AlgebraicMirror.lean)

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



Recent successful concepts: Tropical Berggren Faithfulness via Signed Tropicalization: Exact Classical-to-Tropical Correspondence for Pythagorean Dynamics, Max-Plus One-Way Functions and Quantum Resistance from Idempotent Semiring Intractability, Berggren–Modular Correspondence: Pythagorean Light Cone Geodesics, PSL(2,ℤ) Embedding, and Gaussian Factorization Recovery


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
