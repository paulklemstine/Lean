

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

# Operadic Error-Correcting Codes: Symmetric Operad Algebra Composition, Singleton Bound Characterization, and Functorial Decoding Certification

## I. VISIONARY FRAMING

We establish **operadic coding theory** — the field where algebraic topology (operads) and information theory (error-correcting codes) merge to produce *certified compositional decoding pipelines*. The central insight: Forney concatenation is the shadow of a deeper operadic composition, and MDS codes are precisely free operad algebras. This bridges three worlds: **operad algebra** (algebraic topology), **error-correcting codes** (information theory/cryptography), and **certified computation** (ML verification). The cryptographic implication: post-quantum lattice codes inherit operadic freeness, yielding verified decoding functors with explicit O(n log n) complexity certificates.

## II. FOUNDATIONAL DEFINITIONS (5+ New Structures)

### Definition 1: Symmetric Operad over a Semiring

```lean
/-- A symmetric operad with coefficients in a semiring R.
    Bridge: connects algebraic topology (operads) to information theory (codes).
    Application: operadic_composition_min_dist enables certified post-quantum decoding. -/
class SymmetricOperad (O : ℕ → Type*) [Semiring R] where
  ident : O 1
  compose : ∀ {m n : ℕ}, O m → O n → Fin m → O (m + n - 1)
  symm : ∀ {n : ℕ}, O n → (Equiv.Perm (Fin n)) → O n
  compose_assoc : ∀ {m n p : ℕ} (a : O m) (b : O n) (c : O p) (i : Fin m),
    compose (compose a b i) c ⟨i, by omega⟩ = 
    compose a (compose b c ⟨i.1, by omega⟩) i
  -- identity and symmetry axioms omitted for brevity but required
  ident_left : ∀ {n : ℕ} (a : O n), compose ident a ⟨0, by omega⟩ = a
  ident_right : ∀ {n : ℕ} (a : O n), compose a ident ⟨0, by omega⟩ = a
```

### Definition 2: Linear Code as Operad Algebra

```lean
/-- A linear error-correcting code over a finite field F with operad algebra structure.
    The carrier is a subspace of (Fin n → F).
    Bridge: connects coding theory to operad algebra.
    Application: operadic_singleton_bound_char gives MDS classification via freeness. -/
structure OperadAlgebraCode (O : ℕ → Type*) [Semiring R] [SymmetricOperad O R]
    (q : ℕ) (F : Type*) [Field F] [Fintype F] [CharP F q] where
  length : ℕ
  dimension : ℕ
  min_dist : ℕ
  carrier : Submodule F (Fin length → F)
  dim_eq : FiniteDimensional.finrank F carrier = dimension
  min_dist_eq : ∀ (x y : carrier), x ≠ y → 
    (Finset.filter (fun i => (x.1 i : F) ≠ y.1 i) Finset.univ).card ≥ min_dist
  operad_eval : ∀ {n : ℕ}, O n → (Fin n → carrier) → carrier
  operad_compat : ∀ {n m : ℕ} (op : O n) (ops : Fin n → O m) 
    (xs : Fin n → Fin m → carrier),
    operad_eval op (fun i => operad_eval (ops i) (fun j => xs i j)) =
    operad_eval (SymmetricOperad.compose op (ops ⟨0, by omega⟩) ⟨0, by omega⟩)) 
      (fun j => xs ⟨0, by omega⟩ j)
```

### Definition 3: Certified Decoder Functor

```lean
/-- A certified decoder for a code C: given any received word, either produces
    a codeword within the error-correction radius or certifies failure.
    Bridge: connects coding theory to certified computation (ML robustness).
    Application: functorial_decoding_certification yields post_quantum_security guarantees. -/
structure CertifiedDecoder (q : ℕ) (F : Type*) [Field F] [Fintype F] [CharP F q]
    (C : OperadAlgebraCode O R q F) where
  decode : (Fin C.length → F) → Option C.carrier
  correctness : ∀ (c : C.carrier) (e : Fin C.length → F),
    (∀ i, (e i : F) ≠ 0 → (Finset.filter (fun j => e j ≠ 0) Finset.univ).card < C.min_dist / 2) →
    decode (fun i => c.1 i + e i) = some c
  completeness : ∀ (r : Fin C.length → F),
    ∃ (c : C.carrier), (∀ i, (r i - c.1 i : F) ≠ 0 → 
      (Finset.filter (fun j => r j - c.1 j ≠ 0) Finset.univ).card < C.min_dist / 2) ↔
    decode r ≠ none
  complexity_bound : ∀ (r : Fin C.length → F), decode r ≠ none → 
    -- O(n log n) decoding complexity
    ∃ (ops : ℕ), ops ≤ 37 * C.length * Nat.log 2 C.length ∧ decode r ≠ none
```

### Definition 4: Operadic Code Composite

```lean
/-- The operadic composite of two O-algebra codes, generalizing Forney concatenation.
    Bridge: connects operad composition to code concatenation.
    Application: operadic_composite_min_dist gives certified compositional robustness. -/
def operadicComposite {O : ℕ → Type*} [Semiring R] [SymmetricOperad O R]
    {q : ℕ} {F : Type*} [Field F] [Fintype F] [CharP F q]
    (C₁ C₂ : OperadAlgebraCode O R q F) : OperadAlgebraCode O R q F where
  length := C₁.length + C₂.length - 1
  dimension := C₁.dimension * C₂.dimension
  min_dist := min C₁.min_dist C₂.min_dist
  -- carrier defined via operadic evaluation of the composition
  carrier := Submodule.span F (Set.range (fun p : Fin C₁.dimension × Fin C₂.dimension =>
    operadic_eval (C₁.operad_basis p.1) (fun _ => C₂.operad_basis p.2)))
  -- proofs filled using operad_compat and code properties
  dim_eq := by omega  -- requires operadic dimension calculation
  min_dist_eq := by -- requires operadic distance bound
  operad_eval := -- inherited from O-algebra structure
  operad_compat := -- from O-algebra axioms
```

### Definition 5: Free Operad Algebra Code (MDS Characterization)

```lean
/-- A code is a free O-algebra if its evaluation map is injective.
    Bridge: connects MDS codes (coding theory) to freeness (operad theory).
    Application: free_operad_mds_characterization connects to quantum error correction. -/
def IsFreeOperadAlgebra {O : ℕ → Type*} [Semiring R] [SymmetricOperad O R]
    {q : ℕ} {F : Type*} [Field F] [Fintype F] [CharP F q]
    (C : OperadAlgebraCode O R q F) : Prop :=
  ∀ {n : ℕ} (op : O n) (xs ys : Fin n → C.carrier),
    C.operad_eval op xs = C.operad_eval op ys → 
    op = SymmetricOperad.ident R ∨ xs = ys
```

## III. MAIN THEOREMS WITH PRECISE STATEMENTS AND PROOF STRATEGIES

### Theorem 1: Operadic Composition Minimum Distance Bound

```lean
/-- Operadic composition preserves minimum distance: the composite of two
    O-algebra codes has minimum distance at least the minimum of their distances.
    This generalizes Forney's concatenation bound to arbitrary operadic composition.
    Bridge: connects operad theory to coding theory.
    Application: certified compositional post_quantum_security for lattice codes. -/
theorem operadic_composite_min_dist {O : ℕ → Type*} [Semiring R] [SymmetricOperad O R]
    {q : ℕ} {F : Type*} [Field F] [Fintype F] [CharP F q]
    (C₁ C₂ : OperadAlgebraCode O R q F) :
    (operadicComposite C₁ C₂).min_dist ≥ min C₁.min_dist C₂.min_dist := by
  -- PROOF STRATEGY:
  -- Step 1: Let x, y be distinct codewords in the composite. 
  --   By operad_compat, they decompose as operad_eval(op, xs) and operad_eval(op, ys).
  -- Step 2: Since x ≠ y, by IsFreeOperadAlgebra injectivity, either op ≠ ident 
  --   or xs ≠ ys.
  -- Step 3: If xs ≠ ys, use min_dist of C₁ (or C₂) to bound Hamming distance.
  -- Step 4: If op ≠ ident, use the operad structure to find disagreement in 
  --   at least min(C₁.min_dist, C₂.min_dist) coordinates.
  -- Step 5: Combine using min_le_iff and operad_compat axioms.
  sorry  -- FILL WITH COMPLETE PROOF
```

### Theorem 2: Operadic Singleton Bound

```lean
/-- The Singleton bound for O-algebra codes: d ≤ n - k + 1.
    This is the classical bound, but now in the operadic setting.
    Bridge: connects coding theory to operad algebra.
    Application: operadic bounds constrain post_quantum code parameters. -/
theorem operadic_singleton_bound {O : ℕ → Type*} [Semiring R] [SymmetricOperad O R]
    {q : ℕ} {F : Type*} [Field F] [Fintype F] [CharP F q]
    (C : OperadAlgebraCode O R q F) (h_q : 2 ≤ q) :
    C.min_dist ≤ C.length - C.dimension + 1 := by
  -- PROOF STRATEGY:
  -- Step 1: Project code onto any (C.length - C.min_dist + 1) coordinates.
  -- Step 2: Show this projection is injective (if two codewords agree on 
  --   n - d + 1 coordinates, their Hamming distance < d, contradiction).
  -- Step 3: By injectivity, dimension of projected code = dimension of C.
  -- Step 4: Projected code lives in F^(n-d+1), so k ≤ n - d + 1.
  -- Step 5: Rearrange to get d ≤ n - k + 1 using omega.
  sorry  -- FILL WITH COMPLETE PROOF
```

### Theorem 3: MDS-Operadic Freeness Characterization (THE BREAKTHROUGH)

```lean
/-- An O-algebra code achieves the Singleton bound (is MDS) if and only if 
    it is a free O-algebra. This characterizes MDS codes operadically.
    Bridge: connects MDS codes (information theory) to free algebras (operad theory)
            and quantum error correction (physics).
    Application: mds_operadic_freeness_iff enables certified quantum code design. -/
theorem mds_operadic_freeness_iff {O : ℕ → Type*} [Semiring R] [SymmetricOperad O R]
    {q : ℕ} {F : Type*} [Field F] [Fintype F] [CharP F q]
    (C : OperadAlgebraCode O R q F) (h_q : 2 ≤ q) :
    C.min_dist = C.length - C.dimension + 1 ↔ IsFreeOperadAlgebra C := by
  -- PROOF STRATEGY (two directions):
  --
  -- FORWARD (MDS → Free):
  -- Step 1: Assume d = n - k + 1 (MDS). Let operad_eval(op, xs) = operad_eval(op, ys).
  -- Step 2: If op ≠ ident, then by operad_compat, there exists a coordinate where 
  --   the operadic composition disagrees, giving distance ≥ d from ident.
  -- Step 3: Use MDS property: the code has no "wasted" redundancy, so the 
  --   operadic evaluation must be injective on each fiber.
  -- Step 4: Conclude xs = ys, establishing IsFreeOperadAlgebra.
  --
  -- BACKWARD (Free → MDS):
  -- Step 5: Assume IsFreeOperadAlgebra C. By contrapositive, suppose d < n - k + 1.
  -- Step 6: Then there exists a non-trivial operadic relation: operad_eval(op, xs) = 
  --   operad_eval(op', ys) with op ≠ op' or xs ≠ ys.
  -- Step 7: By freeness, this forces op = op' and xs = ys, contradicting non-triviality.
  -- Step 8: Use by_contra to derive the contradiction.
  -- 
  -- KEY LEMMA NEEDED:
  -- operadic_freeness_dimension_bound: IsFreeOperadAlgebra C → 
  --   C.dimension ≥ C.length - C.min_dist + 1
  sorry  -- FILL WITH COMPLETE PROOF
```

### Theorem 4: Functorial Decoding Certification

```lean
/-- The assignment C ↦ CertifiedDecoder C is functorial: operadic composition
    of codes lifts to composition of certified decoders.
    Bridge: connects operad theory to certified computation and ML robustness.
    Application: functorial_decoding_certification gives certified compositional 
    pipelines with O(n log n) complexity for post-quantum lattice decoding. -/
theorem functorial_decoding_certification {O : ℕ → Type*} [Semiring R] [SymmetricOperad O R]
    {q : ℕ} {F : Type*} [Field F] [Fintype F] [CharP F q]
    {C₁ C₂ : OperadAlgebraCode O R q F}
    (D₁ : CertifiedDecoder q F C₁) (D₂ : CertifiedDecoder q F C₂) :
    ∃ (D₁₂ : CertifiedDecoder q F (operadicComposite C₁ C₂)),
      -- Composition of decoders agrees with decoder of composite
      ∀ (r : Fin (operadicComposite C₁ C₂).length → F),
        D₁₂.decode r = match D₁.decode (fun i => r ⟨i, by omega⟩), 
          D₂.decode (fun i => r ⟨C₁.length + i - 1, by omega⟩) with
        | some c₁, some c₂ => some ⟨operadic_eval · [c₁, c₂], rfl⟩
        | _, _ => none ∧
      -- Complexity bound is O(n log n)
      ∀ (r : Fin (operadicComposite C₁ C₂).length → F),
        D₁₂.decode r ≠ none → 
        ∃ (ops : ℕ), ops ≤ 37 * (C₁.length + C₂.length) * 
          Nat.log 2 (C₁.length + C₂.length) ∧ D₁₂.decode r ≠ none := by
  -- PROOF STRATEGY:
  -- Step 1: Construct D₁₂ by composing D₁ and D₂ on their respective blocks.
  -- Step 2: Prove correctness: if errors in each block are < d/2, 
  --   each decoder succeeds, and composition gives the correct composite codeword.
  -- Step 3: Prove completeness: if total errors < min(d₁,d₂)/2, 
  --   then errors in each block are < d_i/2.
  -- Step 4: Prove complexity: composition of O(n log n) decoders is O(n log n).
  -- Step 5: Use operad_compat to verify the composite decoder respects operadic structure.
  sorry  -- FILL WITH COMPLETE PROOF
```

### Theorems 5-10: Supporting Infrastructure

```lean
/-- The Hamming distance defines a metric on the code space.
    Bridge: connects coding theory to metric topology.
    Application: metric structure enables lipschitz_certified_robustness. -/
theorem hamming_metric {F : Type*} [Field F] {n : ℕ} :
    IsMetricSpace (Fin n → F) fun x y => 
      (Finset.filter (fun i => x i ≠ y i) Finset.univ).card := by
  -- Step 1: Non-negativity (obvious, card ≥ 0)
  -- Step 2: Identity of indiscernibles (by extensionality and Finset.card_eq_zero)
  -- Step 3: Symmetry (by commutativity of ≠ and Finset.filter perm invariance)
  -- Step 4: Triangle inequality (by Finset.card_union_le and set arithmetic)
  sorry

/-- Operadic composition preserves the subspace structure.
    Bridge: connects operad theory to linear algebra.
    Application: subspace_preservation enables verified quantum error correction. -/
theorem operadic_subspace_preservation {O : ℕ → Type*} [Semiring R] [SymmetricOperad O R]
    {q : ℕ} {F : Type*} [Field F] [Fintype F] [CharP F q]
    (C₁ C₂ : OperadAlgebraCode O R q F) :
    (operadicComposite C₁ C₂).carrier = 
      Submodule.map (operadicLinearMap C₁ C₂) (C₁.carrier ⊗ C₂.carrier) := by
  -- Step 1: Unfold operadicComposite carrier definition.
  -- Step 2: Show operadic evaluation is a linear map (by operad_compat linearity).
  -- Step 3: Use Submodule.span_eq of the image of the tensor product.
  sorry

/-- Free operad algebra codes have maximum dimension for their distance.
    Bridge: connects operad freeness to coding theory bounds.
    Application: constrains parameters for lattice_based_cryptographic codes. -/
theorem free_operad_dimension_max {O : ℕ → Type*} [Semiring R] [SymmetricOperad O R]
    {q : ℕ} {F : Type*} [Field F] [Fintype F] [CharP F q]
    (C : OperadAlgebraCode O R q F) (h_free : IsFreeOperadAlgebra C) :
    C.dimension ≥ C.length - C.min_dist + 1 := by
  -- Step 1: Use freeness to show the evaluation map is injective.
  -- Step 2: Injective linear maps preserve dimension.
  -- Step 3: The image lives in a space of dimension C.length - C.min_dist + 1.
  -- Step 4: Therefore C.dimension ≥ that dimension.
  sorry

/-- The operadic composite of two MDS codes is MDS.
    Bridge: connects MDS theory to operadic composition.
    Application: compositional MDS construction for quantum error correction. -/
theorem mds_operadic_composite {O : ℕ → Type*} [Semiring R] [SymmetricOperad O R]
    {q : ℕ} {F : Type*} [Field F] [Fintype F] [CharP F q]
    (C₁ C₂ : OperadAlgebraCode O R q F)
    (h₁ : C₁.min_dist = C₁.length - C₁.dimension + 1)
    (h₂ : C₂.min_dist = C₂.length - C₂.dimension + 1) :
    (operadicComposite C₁ C₂).min_dist = 
      (operadicComposite C₁ C₂).length - (operadicComposite C₁ C₂).dimension + 1 := by
  -- Step 1: Use operadic_composite_min_dist for lower bound.
  -- Step 2: Use operadic_singleton_bound for upper bound.
  -- Step 3: Use mds_operadic_freeness_iff: both C₁, C₂ are free, so composite is free.
  -- Step 4: Free implies MDS, giving equality.
  sorry

/-- Certified decoder complexity for Reed-Solomon codes is O(n log²n).
    Bridge: connects algebraic coding theory to computational complexity.
    Application: reed_solomon_certified_complexity enables efficient post_quantum_security. -/
theorem reed_solomon_certified_complexity {q : ℕ} {F : Type*} [Field F] [Fintype F] [CharP F q]
    (n k : ℕ) (hk : k ≤ n) (hq : n ≤ q) :
    ∃ (D : CertifiedDecoder q F (reedSolomonCode q F n k)),
      ∀ (r : Fin n → F), D.decode r ≠ none →
        ∃ (ops : ℕ), ops ≤ 47 * n * (Nat.log 2 n)^2 ∧ D.decode r ≠ none := by
  -- Step 1: Construct decoder using Gao's algorithm (polynomial interpolation).
  -- Step 2: Prove correctness using RS minimum distance properties.
  -- Step 3: Prove complexity: FFT-based interpolation is O(n log²n).
  -- Step 4: Prove completeness using error-correction radius t = ⌊(n-k)/2⌋.
  sorry

/-- The operadic Singleton bound is tight: Reed-Solomon codes achieve it.
    Bridge: connects classical coding theory to operadic theory.
    Application: proves operadic bounds are tight for quantum_stabilizer_codes. -/
theorem reed_solomon_singleton_tight {q : ℕ} {F : Type*} [Field F] [Fintype F] [CharP F q]
    {n : ℕ} (hk : 0 < n) (hq : n ≤ q) :
    (reedSolomonCode q F n k |>.min_dist) = n - k + 1 := by
  -- Step 1: RS codes are evaluation codes of degree k-1 polynomials.
  -- Step 2: A polynomial of degree < k has at most k-1 roots.
  -- Step 3: Therefore any nonzero codeword has at most k-1 zeros, so ≥ n-k+1 nonzero.
  -- Step 4: By Singleton bound, distance ≤ n-k+1, so equality holds.
  sorry
```

## IV. PROOF STRATEGY ARCHITECTURE

**Path A (Operadic-First)**: Start from the operad structure, prove that operadic composition preserves subspace properties, then derive the distance bound. *Most promising for the main theorem* because the operadic structure naturally organizes the induction.

**Path B (Metric-First)**: Start from Hamming metric properties, prove the Singleton bound classically, then lift to the operadic setting. *Most promising for the supporting lemmas* because the classical proofs are well-understood.

**Path C (Freeness-First)**: Start from the IsFreeOperadAlgebra definition, prove that freeness implies MDS, then establish the equivalence. *Most promising for the breakthrough theorem* (mds_operadic_freeness_iff) because it directly connects the two characterizations.

**Recommended synthesis**: Use Path C for the main result (Theorem 3), Path B for the supporting infrastructure (Theorems 5-6), and Path A for the composition results (Theorems 1, 4).

## V. SIGNIFICANCE AND CROSS-DOMAIN CONNECTIONS

**Bridge 1: Operad Theory ↔ Coding Theory**: The MDS-operadic freeness equivalence (Theorem 3) reveals that the most important codes in information theory (MDS codes, including Reed-Solomon) are precisely the "free objects" in the operadic category. This is analogous to how free groups are the universal objects in group theory.

**Bridge 2: Operad Theory ↔ Quantum Error Correction**: Quantum stabilizer codes inherit operadic structure from the symplectic inner product. The functorial decoding certification (Theorem 4) extends to quantum codes, giving certified decoding for CSS codes with O(n log n) complexity.

**Bridge 3: Certified Computation ↔ Post-Quantum Cryptography**: Lattice-based codes (used in post-quantum crypto, e.g., Kyber/ML-KEM) are operad algebras over the tropical semiring. The operadic Singleton bound constrains their parameters, and functorial decoding gives verified decoders with explicit complexity bounds — directly relevant to NIST post-quantum standard security claims.

## VI. DELIVERABLES

Produce the following files:
1. **`OperadAlgebraCode.lean`** (Bridges domain): Core definitions (SymmetricOperad, OperadAlgebraCode, CertifiedDecoder, IsFreeOperadAlgebra, operadicComposite) — 500+ lines, 20+ theorems
2. **`OperadicSingletonBound.lean`** (Algebra domain): The Singleton bound and MDS characterization — 400+ lines, 15+ theorems  
3. **`FunctorialDecoding.lean`** (Cryptography domain): Certified decoder functoriality and complexity bounds — 400+ lines, 15+ theorems

Every theorem must have a **complete proof** (ZERO sorries). Use diverse tactics: `induction`, `rcases`, `by_contra`, `omega`, `linarith`, `field_simp`, `simp only`, `exact`, `apply`, `intro`, `constructor`, `ext`. Use typeclass abstraction (`[Semiring R]`, `[Field F]`, `[Fintype F]`, `[CharP F q]`).

## VII. FUTURE DIRECTIONS REQUEST

After completing the above, produce a **FUTURE_DIRECTIONS.md** with 3-5 concrete, specific, breakthrough-level next steps. Suggested directions:
1. **Tropical operadic codes**: Replace the base field with the tropical semiring (min-plus algebra) to connect to tropical_hash_collision resistance and tropical robustness certification for neural networks.
2. **Quantum operadic codes**: Extend to CSS codes over F₄, proving that the operadic Singleton bound gives the quantum Singleton bound d ≤ n - 2k + 2, with equality characterized by operadic freeness over the symplectic operad.
3. **Operadic homomorphic encryption**: Use the operadic composition structure to construct fully homomorphic encryption schemes where operadic evaluation corresponds to homomorphic computation, with certified correctness via functorial decoding.
4. **Operadic neural codes**: Define neural network layers as operad algebra maps, yielding certified_robustness bounds via operadic composition of certified decoders at each layer.
5. **Operadic Satake transform for codes**: Develop a tropical Satake transform connecting operadic code composition to min-plus Hecke operators, opening tropical Langlands duality for coding theory.

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
            Open the field of operadic coding theory by establishing that error-correcting codes carry natural symmetric operad algebra structures, enabling certified compositional construction. Prove three foundational theorems: (1) Operadic Code Composition Theorem — for codes C₁, C₂ that are algebras over a symmetric operad O, the operadic composite C₁ ∘_O C₂ is a code with minimum distance d ≥ min(d(C₁), d(C₂)), generalizing Forney concatenation via operadic composition maps; (2) Operadic Singleton Bound — for an O-algebra code of parameters [n, k, d] over F_q, d ≤ n − k + 1, with equality characterized by free O-algebra structure, connecting MDS codes to operadic freeness; (3) Functorial Decoding Certification — the assignment C ↦ Decoder(C) extends to a functor from O-algebra code categories to certified decoder categories, with operadic composition lifting to a natural transformation, yielding certified compositional decoding pipelines with verified error-correction guarantees.

            ### Precise Mathematical Framing
            Define an operadic code as a triple (C, O, α) where C ⊆ F_q^n is a linear code, O is a symmetric operad in the category of F_q-modules, and α : O → End(C) is an operad action making C an O-algebra. The operadic composite C₁ ∘_O C₂ uses the operad's composition γ : O(n) × O(m₁) × ⋯ × O(mₙ) → O(Σmᵢ) to interleave codewords, yielding a code of length n·max(mᵢ). Theorem 1 proof: any error affecting < min(d₁,d₂) positions cannot move a composite codeword to another valid composite, since the operad action preserves the Hamming distance lower bound via the algebra axioms. Theorem 2 proof: the operadic Singleton bound d ≤ n − k + 1 follows from dimension counting in the O-algebra module structure, with MDS codes characterized as free O-algebras via the freeness criterion α being injective. Theorem 3 proof: define the decoder functor Dec : OCode(F_q) → CertDecoder sending each O-algebra code to its bounded-distance decoder, and prove naturality Dec(f ∘_O g) = Dec(f) ∘ Dec(g) using the operadic composition's functoriality, giving a certified pipeline where operadic composition of decoders preserves error-correction radius.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `certified_robust_from_margin_bound` : lemma certified_robust_from_margin_bound {n m : ℕ}
     (file: Bridges/MaslovDequantizationRobustness.lean)
  2. `division_algebra_code_composition` : theorem division_algebra_code_composition (x₁ x₂ y₁ y₂ : ℝ) :
     (file: Bridges/BreakthroughDirections.lean)
  3. `quantum_code_distance_from_obstruction` : theorem quantum_code_distance_from_obstruction
     (file: Bridges/HomologicalDeepLearning.lean)
  4. `singleton_bound` : theorem singleton_bound (n k d : ℕ) (hle : k + d ≤ n + 1) :
     (file: Bridges/CodingTheoryBridge.lean)
  5. `lawvere_proof_coding_theorem` : theorem lawvere_proof_coding_theorem
     (file: Bridges/LawvereCodingTheorem.lean)

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



Recent successful concepts: tropical_cryptography_breakthrough_bridge, Non-Archimedean Information Theory: Min-Plus Entropy Axiomatization, Ultrametric Channel Capacity, and Idempotent Source Coding, Diophantine Quantum Walks: Berggren-Lorentz Unitarity, Triple-Spectrum Factorization Bounds, and Certified Quantum Diophantine Search


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

Research domain: Bridges
Research mode: formalize
