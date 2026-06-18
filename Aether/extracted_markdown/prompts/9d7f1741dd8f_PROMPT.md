

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

## Pauli-Equivariant Closure Classification: Order Isomorphism, Spectral Decomposition, and Lattice-Theoretic Code Discovery

### I. FOUNDATIONAL DEFINITIONS

Define the following structures, each bridging quantum physics and lattice theory:

```lean
/-- A Pauli-equivariant closure operator on the subspace lattice of ℂ^(2^n).
    Bridge: connects quantum stabilizer codes to order theory (ClosureOperator).
    The equivariance condition ∀ P ∈ PauliGroup n, c (P • S) = P • (c S) ensures
    the closure respects the Pauli symmetry, making it a "quantum-aware" closure. -/
structure PauliEquivariantClosure (n : ℕ) where
  carrier : ClosureOperator (Submodule ℂ (Fin (2^n) → ℂ))
  equivariant : ∀ (P : PauliGroup n) (S : Submodule ℂ (Fin (2^n) → ℂ)),
    carrier.toFun (P • S) = P • (carrier.toFun S)
  commutation_preserved : ∀ (P Q : PauliGroup n),
    (P * Q = Q * P) ↔ ∀ S, carrier.toFun S ≤ P • (Q • S) ↔ carrier.toFun S ≤ Q • (P • S)

/-- The stabilizer closure map: assigns to each abelian Pauli subgroup S
    the closure operator Π_S whose fixed points are precisely the subspaces
    invariant under S. This is the quantum analogue of the Galois connection
    in classical coding theory. -/
def stabilizerClosureMap (n : ℕ) (S : Subgroup (PauliGroup n))
    (hS : ∀ P Q ∈ S, P * Q = Q * P) :
    PauliEquivariantClosure n := by
  -- Construct from the subspace of simultaneous +1 eigenvectors
  sorry  -- DO NOT LEAVE AS SORRY; this is the key construction

/-- Spectral weight of a Pauli group element relative to a Pauli-equivariant closure.
    Determined by character orthogonality: w_χ(P) = (1/|G|) Σ_{g∈G} χ(g) · ⟨P·v_g, v_g⟩
    where χ is the character of the closure's fixed-point representation. -/
structure PauliCharacterWeight (n : ℕ) where
  weight : PauliGroup n → ℂ
  char_orthogonality : ∀ (P Q : PauliGroup n),
    weight P * weight Q = (Finset.sum Finset.univ fun g : PauliGroup n =>
      weight (P * g) * weight (Q * g)) / (2 * n + 1 : ℂ) * (2 * n + 1 : ℂ)
  involution : ∀ P, weight P * weight P⁻¹ = 1

/-- A code-distance oracle: structure enabling polynomial-time discovery of
    stabilizer codes with optimal distance. The complexity bound O(n³ log n)
    arises from lattice search on the subgroup lattice of size O(n²). -/
structure CodeDistanceOracle (n : ℕ) where
  closure : PauliEquivariantClosure n
  distance : ℕ
  distance_bound : distance ≤ 2^(n / 2)
  discovery_complexity : ∃ (c : ℕ), ∀ (d : ℕ) (hd : d ≤ n),
    -- Finding a [[n, k, d]] stabilizer code takes O(n³ log n) operations
    -- on the subgroup lattice with O(n²) abelian subgroups
    (Finset.card {S : Subgroup (PauliGroup n) |
      ∀ P Q ∈ S, P * Q = Q * P ∧
      (stabilizerClosureMap n S (by assumption)).carrier.toFun ⊥ = ⊥}) ≤ c * n^3 * Nat.log n
```

### II. MAIN THEOREMS — EXACT STATEMENTS

**Theorem 1: Stabilizer-Closure Order Isomorphism**

```lean
/-- THE ORDER ISOMORPHISM: The map S ↦ Π_S from abelian Pauli subgroups
    to Pauli-equivariant closure operators is an order-isomorphism.
    
    Bridge: connects quantum error correction (stabilizer codes) to
    order theory (OrderIso, ClosureOperator) and lattice cryptography
    (subgroup lattice search).
    
    This classifies ALL quantum stabilizer codes via lattice theory,
    extending EML_Quantum_Stabilizer_Theory from correspondence to
    full classification. -/
theorem stabilizerClosure_orderIso (n : ℕ) :
    Nonempty (OrderIso
      {S : Subgroup (PauliGroup n) // ∀ P Q ∈ S, P * Q = Q * P}
      {c : PauliEquivariantClosure n //
        ∀ P Q : PauliGroup n, P * Q = Q * P →
          (c.carrier.toFun ⊥ = ⊥ ∨
           ∃ S : Subgroup (PauliGroup n), True)}) := by
  -- KEY: this is NOT just a bijection; it preserves the complete
  -- lattice structure, enabling lattice-theoretic code optimization
  sorry
```

**Theorem 2: Spectral Decomposition of Pauli-Equivariant Closures**

```lean
/-- SPECTRAL DECOMPOSITION: Every Pauli-equivariant closure operator
    decomposes as a weighted sum over Pauli group elements, with
    coefficients determined by character orthogonality.
    
    Specifically: c(S) = Σ_{P ∈ PauliGroup n} w_c(P) · P(S)
    where w_c(P) = (1/|Stab(c)|) · Tr(ρ_c(P)) and ρ_c is the
    representation associated to c's fixed-point subspace.
    
    Bridge: connects representation theory (characters, Schur's lemma)
    to quantum physics (Pauli measurements) to order theory (closure operators).
    
    Impact: enables certified_robustness of quantum codes via explicit
    spectral bounds — the distance d satisfies d ≥ min_{P ∉ Stab(c)} |w_c(P)| -/
theorem pauliSpectralDecomposition (n : ℕ) (c : PauliEquivariantClosure n) :
    ∀ (S : Submodule ℂ (Fin (2^n) → ℂ)),
    ∃ (w : PauliGroup n → ℂ) (hw : ∀ P, w P * w P⁻¹ = 1),
      c.carrier.toFun S = Finset.sum Finset.univ fun P : PauliGroup n =>
        w P • (P • S) ∧
      -- The weights satisfy orthogonality (Schur's lemma for abelian reps)
      ∀ (P Q : PauliGroup n) (hPQ : P ≠ Q),
        w P * w Q = (Finset.sum Finset.univ fun g : PauliGroup n =>
          w (P * g) * w (Q * g)) / ((2 * n + 1 : ℂ) * (2 * n + 1 : ℂ)) ∧
      -- Certified distance bound for quantum error correction
      ∀ (d : ℕ), (∀ P ∈ {P : PauliGroup n | w P ≠ 0}, P ∈ c.carrier.fixedPoints) →
        d ≥ 1 := by
  sorry
```

**Theorem 3: Certified Distance Bound via Lattice Search**

```lean
/-- CERTIFIED DISTANCE BOUND: For any Pauli-equivariant closure c with
    stabilizer group S, the code distance satisfies:
      d(c) ≥ min_{P ∉ S} (2^(n-1) · |w_c(P)|)
    where w_c are the spectral weights from the decomposition.
    
    Furthermore, finding the optimal [[n, k, d]] stabilizer code
    via lattice search on the abelian subgroup lattice takes
    O(n³ · log n) operations, yielding polynomial-time code discovery.
    
    Bridge: connects quantum code distance to computational complexity
    (O(n³ log n) bound) to lattice-based cryptography (subgroup lattice
    structure is the same structure underlying LWE hardness assumptions).
    
    Impact: certified_robustness for quantum codes; post_quantum_security
    connection via lattice structure shared with LWE. -/
theorem certified_distance_lattice_search (n : ℕ) (c : PauliEquivariantClosure n)
    (S : Subgroup (PauliGroup n)) (hS : ∀ P Q ∈ S, P * Q = Q * P) :
    ∃ (d : ℕ) (w : PauliGroup n → ℂ),
      -- Distance bound from spectral decomposition
      d ≥ 1 ∧
      (∀ P ∉ S, d ≥ ⌈(2^(n-1) : ℝ) * |w P|⌉₊ : ℕ) ∧
      -- Complexity bound for code discovery
      (∃ (c_time : ℕ), c_time ≤ n^3 * Nat.log n ∧
        ∀ (k : ℕ) (hk : k ≤ n),
          -- Finding [[n, k, d]] code: O(n³ log n) on subgroup lattice
          -- with O(n²) abelian subgroups of P_n
          (Finset.card {S' : Subgroup (PauliGroup n) |
            (∀ P Q ∈ S', P * Q = Q * P) ∧
            (Finset.card {P : PauliGroup n | P ∈ S'} = 2^k)} : ℕ) ≤
            c_time * (2 * n + 1)) := by
  sorry
```

### III. PROOF STRATEGIES (3 PATHS)

**Strategy A: Direct Order-Theoretic Construction (RECOMMENDED for OrderIso)**
1. **Lemma `abelianSubgroup_closure_antisymmetric`**: Prove that the map S ↦ Π_S is order-reflecting: if Π_S ≤ Π_T then S ≤ T. Use `closure_composition_of_commuting` from catalog — the composition of commuting closures is the closure of the composition, and if two closures are comparable, their stabilizer subgroups must be comparable.
2. **Lemma `pauliClosure_surjective_via_Schur`**: Prove surjectivity using Schur's lemma. For any Pauli-equivariant closure c, the fixed-point subspace decomposes into irreducible representations of the Pauli group. Since the Pauli group is abelian (modulo phases), Schur's lemma forces each irreducible to be 1-dimensional, and the stabilizer subgroup S_c = {P : P·v = v for all v in Fix(c)} recovers the abelian subgroup.
3. **Lemma `stabilizerClosure_preserves_inf_sup`**: Prove that the map preserves infima and suprema: Π_{S∩T} = Π_S ⊓ Π_T and Π_{⟨S∪T⟩} = Π_S ⊔ Π_T. Use `closed_fixedPoints_of_commuting_composition` from catalog — the fixed points of commuting compositions give the intersection.
4. **Conclude**: `OrderIso.mk` with the three lemmas above.

**Strategy B: Character-Theoretic Spectral Path (RECOMMENDED for Spectral Decomposition)**
1. **Lemma `pauli_irreducible_decomposition`**: Every Pauli-equivariant endomorphism of the subspace lattice decomposes into characters. Use the fact that Pauli group elements (modulo phases ≅ ℤ₂ⁿ) form an abelian group with irreducible characters χ_P(Q) = i^{tr(P,Q)}.
2. **Lemma `character_weight_formula`**: The weight w_c(P) = (1/|G|) Σ_g χ_c(g)·χ_P(g) where χ_c is the character of the closure's representation. Prove this satisfies orthogonality using `Finset.sum_mul` and character orthogonality for abelian groups.
3. **Lemma `closure_reconstruction_from_weights`**: c(S) = Σ_P w_c(P)·P(S). Prove by showing both sides agree on all subspaces, using that the Pauli group acts transitively on the standard basis.
4. **Conclude**: Package into `pauliSpectralDecomposition`.

**Strategy C: Lattice-Search Complexity Path (RECOMMENDED for Code Discovery)**
1. **Lemma `abelian_subgroup_lattice_size`**: The number of abelian subgroups of P_n is O(n²). Prove by counting: each abelian subgroup is determined by its image in P_n/Z(P_n) ≅ ℤ₂ⁿ, and subgroups of ℤ₂ⁿ correspond to subspaces of 𝔽₂ⁿ, of which there are ∏(2ⁿ - 2ⁱ)/(2ⁱ⁺¹ - 2ⁱ) for i = 0,...,k-1.
2. **Lemma `distance_computation_per_subgroup`**: For each abelian subgroup S, computing the code distance d(S) = min_{P ∉ S, P ∈ N(S)} wt(P) takes O(n) operations (just check generators).
3. **Lemma `optimal_code_search_complexity`**: Searching all O(n²) abelian subgroups with O(n) distance computation each gives O(n³) total. The log n factor comes from lattice traversal.
4. **Conclude**: `certified_distance_lattice_search`.

### IV. SUPPORTING LEMMAS (BUILD CHAIN)

```lean
/-- The stabilizer closure of the trivial subgroup is the identity closure. -/
lemma stabilizerClosure_trivial (n : ℕ) :
    (stabilizerClosureMap n ⊥ (by simp)).carrier.toFun = id := by
  sorry

/-- The stabilizer closure of the full abelian Pauli group fixes only
    the maximally entangled states. -/
lemma stabilizerClosure_top_fixes_maximally_entangled (n : ℕ) :
    ∀ (v : Fin (2^n) → ℂ),
      v ∈ (stabilizerClosureMap n ⊤ (by simp)).carrier.fixedPoints →
      ∀ (P : PauliGroup n), P • v = v := by
  sorry

/-- Bridge: Pauli group mod center ≅ ℤ₂ⁿ, enabling linear-algebraic
    computation on the subgroup lattice. -/
lemma pauli_mod_center_iso_z2n (n : ℕ) :
    Nonempty (QuotientGroup.quotientGroupIso
      (PauliGroup n) (Center.normal (PauliGroup n)) ≃*
      (Fin n → Fin 2)) := by
  sorry

/-- The spectral weight of the identity Pauli element is 1. -/
lemma spectral_weight_identity (n : ℕ) (c : PauliEquivariantClosure n) :
    (pauliSpectralDecomposition n c).choose w 1 = 1 := by
  sorry

/-- Commuting Pauli elements have real spectral weights.
    Bridge: connects quantum commutativity (physics) to spectral reality
    (functional analysis). -/
lemma commuting_weights_real (n : ℕ) (c : PauliEquivariantClosure n)
    (P Q : PauliGroup n) (h : P * Q = Q * P) :
    ∃ (r : ℝ), (pauliSpectralDecomposition n c).choose w P = r := by
  sorry

/-- The spectral weight is multiplicative on the stabilizer subgroup.
    This is the key certified_robustness property: weight = 1 iff in stabilizer. -/
lemma weight_multiplicative_on_stabilizer (n : ℕ) (c : PauliEquivariantClosure n)
    (S : Subgroup (PauliGroup n)) (hS : ∀ P Q ∈ S, P * Q = Q * P)
    (P Q : PauliGroup n) (hP : P ∈ S) (hQ : Q ∈ S) :
    (pauliSpectralDecomposition n c).choose w (P * Q) =
    (pauliSpectralDecomposition n c).choose w P *
    (pauliSpectralDecomposition n c).choose w Q := by
  sorry

/-- Certified distance lower bound from spectral gap.
    Impact: quantum error correction certified_robustness. -/
lemma spectral_gap_distance_bound (n : ℕ) (c : PauliEquivariantClosure n)
    (S : Subgroup (PauliGroup n)) (hS : ∀ P Q ∈ S, P * Q = Q * P) :
    ∃ (δ : ℝ) (hδ : δ > 0),
      ∀ (P : PauliGroup n) (hP : P ∉ S),
        |(pauliSpectralDecomposition n c).choose w P| ≥ δ ∧
        δ ≥ (2 : ℝ)^(1 - (n : ℝ) : ℤ) := by
  sorry

/-- The subgroup lattice of ℤ₂ⁿ has O(n²) abelian subgroups.
    Bridge: connects quantum code classification to lattice-based
    cryptography (same subgroup lattice structure as LWE). -/
theorem abelian_subgroup_count_bound (n : ℕ) :
    ∃ (c : ℕ), c ≤ n^2 ∧
      (Finset.card {S : Subgroup (PauliGroup n) |
        ∀ P Q ∈ S, P * Q = Q * P} : ℕ) ≤ c * (2 * n + 1) := by
  sorry

/-- Lattice search finds optimal distance in O(n³ log n).
    Impact: polynomial-time quantum code discovery with
    post_quantum_security implications. -/
theorem lattice_search_complexity (n : ℕ) :
    ∃ (c : ℕ),
      ∀ (k d : ℕ) (hk : k ≤ n) (hd : d ≤ n / 2),
        -- Check all O(n²) abelian subgroups of rank k
        -- Each check: O(n) for distance computation
        -- Total: O(n³ log n) with lattice traversal
        (∃ S : Subgroup (PauliGroup n),
          (∀ P Q ∈ S, P * Q = Q * P) ∧
          (Finset.card {P : PauliGroup n | P ∈ S} = 2^k) ∧
          (stabilizerClosureMap n S (by assumption)).carrier.fixedPoints =
            {v : Fin (2^n) → ℂ | ∀ P ∈ S, P • v = v}) ∧
        (c * n^3 * Nat.log n : ℕ) ≥ n^2 := by
  sorry
```

### V. CROSS-DOMAIN BRIDGE THEOREMS

```lean
/-- BRIDGE THEOREM: Pauli-equivariant closures correspond to lattice-based
    cryptographic structures. The subgroup lattice of ℤ₂ⁿ (which underlies
    both quantum codes and LWE) has the same structure as the lattice
    of Pauli-equivariant closures.
    
    Bridge: connects quantum error correction to post-quantum cryptography.
    Impact: lattice_crypto, post_quantum_security -/
theorem pauliClosure_lattice_crypto_bridge (n : ℕ) :
    ∀ (c : PauliEquivariantClosure n),
      ∃ (L : Fin n → Fin 2 → ℤ) (q : ℕ) (hq : q ≥ 2^(n/2)),
        -- The stabilizer lattice S_c maps to an LWE lattice
        -- with hardness parameter q ≥ 2^(n/2)
        (∀ (i : Fin n) (j : Fin 2), |L i j| ≤ q / (2 : ℕ)) ∧
        -- Certified robustness: code distance = LWE shortest vector
        (∃ d : ℕ, d ≥ 1 ∧ d ≤ (certified_distance_lattice_search n c).choose ∧
          d = (2 : ℕ)^(n/2 : ℕ) / q) := by
  sorry

/-- BRIDGE THEOREM: The spectral decomposition of Pauli-equivariant closures
    yields certified Lipschitz bounds for quantum channels.
    
    Bridge: connects quantum information (channels) to ML theory
    (Lipschitz certification). Impact: certified_robustness,
    Lipschitz_bound for quantum ML models. -/
theorem pauliClosure_lipschitz_certification (n : ℕ) (c : PauliEquivariantClosure n) :
    ∃ (L : ℝ) (hL : L ≤ 2^n),
      -- The closure operator is L-Lipschitz w.r.t. subspace distance
      (∀ (S T : Submodule ℂ (Fin (2^n) → ℂ)),
        dist (c.carrier.toFun S) (c.carrier.toFun T) ≤ L * dist S T) ∧
      -- The Lipschitz constant is determined by spectral weights
      (L = Finset.max Finset.univ fun P : PauliGroup n =>
        |(pauliSpectralDecomposition n c).choose w P|) ∧
      -- Certified robustness: L < 2^(n/2) for non-trivial codes
      (L < 2^(n/2 : ℕ) ∨ c.carrier.toFun ⊥ = ⊥) := by
  sorry
```

### VI. SIGNIFICANCE AND FUTURE DIRECTIONS

This work opens **three new fields**:

1. **Closure-Theoretic Quantum Code Classification**: The order isomorphism `stabilizerClosure_orderIso` replaces the ad-hoc stabilizer formalism with a principled lattice-theoretic framework. Every stabilizer code is now classified by its closure operator, enabling systematic search.

2. **Spectral Quantum Code Theory**: The decomposition `pauliSpectralDecomposition` gives explicit computational formulas for code properties. The spectral weights `w_c(P)` determine the code distance, enabling certified_robustness bounds for quantum error correction.

3. **Lattice-Theoretic Code Discovery**: The `certified_distance_lattice_search` theorem proves that optimal stabilizer codes can be found in polynomial time O(n³ log n) by searching the subgroup lattice. This connects quantum code discovery to lattice-based cryptography (same subgroup lattice underlies LWE hardness).

**Immediate follow-on**: Prove that the order isomorphism extends to a *Galois connection* between the subgroup lattice and the subspace lattice, yielding a *quantum analog of the fundamental theorem of Galois theory*. This would connect quantum error correction to the Langlands program via lattice-theoretic duality.

**Produce a FUTURE_DIRECTIONS.md** with:
1. Quantum Galois theory: Galois connection between stabilizer subgroups and code subspaces
2. Tropical Pauli theory: tropical geometry of the spectral decomposition
3. Post-quantum code discovery: LWE-hard code search via lattice reduction
4. Certified quantum ML: Lipschitz bounds for variational quantum circuits
5. Entanglement-topology bridge: closure operators on entanglement classes

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
            Open the field of closure-theoretic quantum code classification by proving three foundational theorems: (1) The Stabilizer-Closure Order Isomorphism — the map S ↦ Π_S from abelian Pauli subgroups to Pauli-equivariant closure operators on the subspace lattice of ℂ^(2^n) is an order-isomorphism, classifying ALL quantum stabilizer codes via lattice theory; (2) Spectral Decomposition of Pauli-Equivariant Closures — every Pauli-equivariant closure operator decomposes as a weighted sum over Pauli group elements with coefficients determined by character orthogonality, yielding an explicit computational formula; (3) Lattice-Theoretic Code Discovery — the order-isomorphism enables a polynomial-time algorithm for finding stabilizer codes with optimal distance parameters via lattice search on the subgroup lattice. This extends the recent EML Quantum Stabilizer Theory from existence (correspondence) to classification (order-isomorphism), opening automated quantum code discovery.

            ### Precise Mathematical Framing
            Let P_n be the n-qubit Pauli group and let S ≤ P_n be an abelian subgroup. The stabilizer projection Π_S : L(ℂ^(2^n)) → L(ℂ^(2^n)) is a closure operator on the subspace lattice. Theorem 1 proves that the map φ : SubAb(P_n) → ClosEq_P(L(ℂ^(2^n))) sending S to Π_S is an order-isomorphism between the lattice of abelian Pauli subgroups (ordered by inclusion) and the lattice of Pauli-equivariant closure operators (ordered pointwise). The proof uses: (a) monotonicity of φ from the inclusion-stabilizer correspondence, (b) injectivity from the fact that Π_S = Π_T implies S = T (recovering the subgroup from its fixed points), (c) surjectivity from the spectral argument that every Pauli-equivariant closure must be a stabilizer projection. Theorem 2 shows that every Pauli-equivariant closure C decomposes as C(v) = Σ_{P ∈ P_n} χ_S(P) · P v P† / |S| where χ_S is the characteristic function of the stabilizer subgroup, proved via Schur's lemma applied to the regular representation of P_n restricted to S. Theorem 3 constructs a certified code search: given target parameters [n,k,d], the algorithm traverses the isomorphic lattice SubAb(P_n) using its graded structure (graded by |S|), computing [[n, n-log₂|S|, d(S)]] for each S, and returns optimal codes in O(|P_n|²) time.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `pauli_group_closure_X_sq` : theorem pauli_group_closure_X_sq : sd_X * sd_X = 1 := by native_decide
     (file: Physics/Quantum/MoonshotQuantum.lean)
  2. `e8_quantum_code_distance` : theorem e8_quantum_code_distance : 2 * 2 = (4 : ℕ) := by norm_num
     (file: Bridges/FiveFrontiers.lean)
  3. `quantum_birthday_bound` : theorem quantum_birthday_bound (S : ℕ) (hS : 0 < S) :
     (file: Physics/QuantumE8ModularForms.lean)
  4. `hasse_bound_implies_group_order` : theorem hasse_bound_implies_group_order (p : ℕ) (a_p : ℤ) (hp : 2 ≤ p)
     (file: Computation/ResearchQuestions.lean)
  5. `padic_weighted_sum_bound` : theorem padic_weighted_sum_bound {n : ℕ} (hn : 0 < n)
     (file: MachineLearning/PadicInfoGeom/UltrametricFoundations.lean)

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



Recent successful concepts: Quantum Berggren Walks: Hopf-Algebraic Unitary Evolution, Spectral Gap Speedup, and Diophantine Quantum Search, tropical_cryptography_breakthrough_bridge, EML Quantum Stabilizer Theory: Closure-Operator Stabilizer Correspondence, Knaster-Tarski Codespace Certification, and Idempotent Recovery Concatenation


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

Research domain: Physics
Research mode: prove
