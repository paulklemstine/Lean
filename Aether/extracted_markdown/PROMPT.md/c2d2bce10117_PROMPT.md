

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

## YOUR ASSIGNMENT: Neural Proof Mining — Tactic Monoid Representation, Lipschitz-Certified Goal Embeddings, and Irreducible Proof Depth Bounds

### Domain Architecture

This work opens the field of **neural proof mining** by establishing that proof tactics form a monoid whose finite-dimensional representation theory governs proof search complexity, that goal embeddings satisfying Lipschitz constraints certify faithful neural representations of proof-theoretic proximity (with applications to certified adversarial robustness of theorem-proving neural networks), and that irreducible decomposition of the tactic monoid yields tight, computationally explicit proof depth bounds — a Maschke-type theorem for proof complexity that stratifies goals into representation-theoretic levels with consequences for post-quantum lattice security assumptions underlying proof-of-work systems.

**Bridge: connects representation theory of finite monoids to certified robustness in neural theorem proving and to post-quantum cryptographic hardness of proof search.**

---

### Part I: The Tactic Shape Monoid and Its Faithful Representations

#### Definitions (5+ required)

```lean
/-- A tactic shape is an abstract element representing a proof tactic.
    The monoid structure comes from sequential composition of tactics. -/
structure TacticShape where
  label : String
  arity : ℕ  -- number of subgoals generated
  deriving DecidableEq, Repr

/-- The tactic shape monoid: elements are sequences of tactic shapes,
    with composition by concatenation. This is the free monoid on TacticShape. -/
@[ext]
structure TacticTrace where
  shapes : List TacticShape
  deriving DecidableEq, Repr

instance : Monoid TacticTrace where
  one := ⟨[]⟩
  mul t₁ t₂ := ⟨t₁.shapes ++ t₂.shapes⟩

/-- A tactic representation maps the tactic monoid into endomorphisms of a module.
    Faithfulness means distinct tactics yield distinct linear maps. -/
structure TacticRepresentation (M : Type*) [Monoid M] (R : Type*) [Semiring R] (n : ℕ) where
  toFun : M → Matrix (Fin n) (Fin n) R
  map_mul : ∀ {a b : M}, toFun (a * b) = toFun a * toFun b
  map_one : toFun 1 = 1

/-- A representation is faithful when it is injective on the monoid. -/
def TacticRepresentation.IsFaithful {M R n} [Monoid M] [Semiring R]
    (ρ : TacticRepresentation M R n) : Prop :=
  ∀ a b : M, ρ.toFun a = ρ.toFun b → a = b

/-- The regular representation of a finite monoid: each element acts by
    left multiplication on the vector space with basis indexed by monoid elements.
    Dimension equals |M|. -/
def regularRepresentation (M : Type*) [Monoid M] [Fintype M] [DecidableEq M] :
    TacticRepresentation M ℕ (Fintype.card M) where
  toFun m := Matrix.of fun i j => if (m * (Fin.equivSymm ⟨j, by omega⟩ : M)) =
      (Fin.equivSymm ⟨i, by omega⟩ : M) then 1 else 0
  map_mul := by
    intro a b; ext i j
    simp [Matrix.mul_apply, Finset.sum_apply]
    -- Key: left multiplication is associative
    split_ifs with h₁ h₂ h₃ <;> simp_all
    · congr 1; exact mul_assoc a b _
  map_one := by
    ext i j
    simp [Matrix.one_apply]
    split_ifs <;> simp_all [Fin.equivSymm]

/-- The proof distance between two goals is the minimum number of
    tactic applications needed to transform one into the other,
    or infinity if they lie in different connected components. -/
def proofDistance (goals : Type*) [DecidableEq goals]
    (tactics : Finset (TacticShape)) :
    goals → goals → ℕ∞ :=
  fun g₁ g₂ =>
    if g₁ = g₂ then 0
    else sInf {n : ℕ | ∃ (ts : List TacticShape),
      ts.length = n ∧ ts.toList.Forall (· ∈ tactics) ∧
      applyTrace g₁ ts = some g₂}
```

#### Theorem 1: Cayley Faithfulness for Tactic Monoids

```lean
/-- **Cayley Faithfulness Theorem for Tactic Monoids**
    Every finite monoid admits a faithful finite-dimensional representation
    over ℕ, with dimension equal to the monoid order.
    
    Bridge: connects monoid theory to representation theory of proof systems.
    Impact: establishes that proof tactics have faithful linear models,
    enabling certified_robustness of neural theorem provers. -/
theorem tactic_cayley_faithful (M : Type*) [Monoid M] [Fintype M] [DecidableEq M] :
    TacticRepresentation.IsFaithful (regularRepresentation M) := by
  intro a b h
  -- Strategy: regular representation is faithful because if ρ(a) = ρ(b),
  -- then left-multiplication by a equals left-multiplication by b on all
  -- basis vectors, hence a = a·1 = b·1 = b.
  have key : ∀ m : M, a * m = b * m := by
    intro m
    have := congrArg (fun ρ => Matrix.of (fun i j => ρ.toFun a i j)) h)
    -- Extract the (Fin.equivSymm ⟨m⟩, Fin.equivSymm ⟨1⟩) entry
    sorry -- This requires careful matrix entry extraction
  exact (key 1).trans (one_mul b).symm ▸ (mul_one a).symm ▸ (key 1)
```

**Proof Strategy (3 paths):**

*Path A (Direct — Recommended):* Use the regular representation. If `ρ(a) = ρ(b)`, then for each basis vector `eₘ`, we have `ρ(a) · eₘ = a · m = ρ(b) · eₘ = b · m`. Setting `m = 1` gives `a = b`. This is the cleanest path because the regular representation is canonical and the proof reduces to a single substitution.

*Path B (Cayley-Hamilton):* Construct the representation explicitly as permutation-like matrices. Use the fact that left multiplication is a function `M → M` and embed this in `Matrix (Fin |M|) (Fin |M|) ℕ` via the indicator function. Faithfulness follows from function extensionality.

*Path C (Inductive on monoid order):* For monoids of order ≤ k, prove by induction. Base case trivial. Inductive step: if `a ≠ b`, find `m` with `a·m ≠ b·m` (take `m = 1`), so `ρ(a) ≠ ρ(b)`.

---

#### Theorem 2: Maschke's Theorem for Finite Monoids

```lean
/-- An irreducible tactic representation has no nontrivial invariant submodules.
    This classifies canonical proof strategies. -/
def IsIrreducible {M R n} [Monoid M] [Semiring R]
    (ρ : TacticRepresentation M R n) : Prop :=
  ∀ (U : Submodule R (Fin n → R)),
    (∀ m : M, ∀ u : Fin n → R, u ∈ U → ρ.toFun m ᵥ u ∈ U) →
    U = ⊥ ∨ U = ⊤

/-- **Maschke's Theorem for Tactic Monoids**
    Every finite-dimensional representation of a finite monoid over a field
    with characteristic coprime to the monoid order decomposes as a direct
    sum of irreducible representations.
    
    Bridge: connects representation theory to proof strategy classification.
    Impact: irreducible decomposition classifies canonical proof strategies,
    enabling certified_robustness bounds for neural provers. -/
theorem maschke_tactic_decomposition (M : Type*) [Monoid M] [Fintype M]
    [DecidableEq M] (K : Type*) [Field K] [DecidableEq K]
    (hchar : Ring.char K = 0 ∨ (Ring.char K ∣ Fintype.card M → False))
    (ρ : TacticRepresentation M K n) :
    ∃ (irreps : Finset (TacticRepresentation M K n))
      (mults : Finset ℕ),
      -- ρ decomposes as direct sum of irreducibles with multiplicities
      True := by
  sorry
```

**Proof Strategy:**

*Step 1:* Define the averaging operator `E(f) = (1/|M|) Σ_{m∈M} ρ(m)⁻¹ · f · ρ(m)` which projects any submodule complement to an invariant complement. This requires `|M|⁻¹ ∈ K`, guaranteed by the characteristic condition.

*Step 2:* Show `E` is a projection onto the space of module homomorphisms and preserves invariant submodules.

*Step 3:* By induction on dimension: if `U` is a proper invariant submodule, apply `E` to find an invariant complement `V`. Then `ρ = ρ|_U ⊕ ρ|_V` and both have smaller dimension.

*Step 4:* The induction terminates since dimension is finite, yielding a complete decomposition into irreducibles.

---

### Part II: Lipschitz-Certified Goal Embeddings

#### Definition: Lipschitz Goal Embedding

```lean
/-- A goal embedding maps proof goals to vectors in a normed space.
    The Lipschitz condition relative to proof distance certifies that
    the embedding faithfully represents proof-theoretic proximity:
    goals close in proof distance map to close points in vector space.
    
    This is the certified_robustness condition for neural theorem provers:
    if ‖ε(g₁) - ε(g₂)‖ ≤ L · d(g₁, g₂), then a neural prover cannot
    be fooled by small perturbations into misclassifying proof proximity. -/
structure LipschitzGoalEmbedding (goals : Type*) [DecidableEq goals]
    (tactics : Finset TacticShape) (E : Type*) [NormedAddCommGroup E]
    where
  embed : goals → E
  lipschitz_const : ℝ
  lipschitz_certified : ∀ g₁ g₂ : goals,
    ‖embed g₁ - embed g₂‖ ≤ lipschitz_const * (proofDistance goals tactics g₁ g₂).toReal
  lipschitz_optimal : ∀ L' < lipschitz_const,
    ¬(∀ g₁ g₂, ‖embed g₁ - embed g₂‖ ≤ L' * (proofDistance goals tactics g₁ g₂).toReal)
```

#### Theorem 3: Existence of Lipschitz Goal Embeddings

```lean
/-- **Lipschitz Embedding Existence Theorem**
    Every finite proof system admits a Lipschitz goal embedding into ℝ^|M|
    with Lipschitz constant equal to the operator norm of the regular
    representation, where M is the tactic monoid.
    
    Bridge: connects metric graph theory to representation theory and
    certified_robustness of neural provers.
    Impact: guarantees existence of certified_robustness parameters
    for neural theorem provers; the dimension |M| and Lipschitz constant
    ‖ρ_reg‖ are computable from the tactic system alone. -/
theorem lipschitz_goal_embedding_exists (M : Type*) [Monoid M] [Fintype M]
    [DecidableEq M] (goals : Type*) [Fintype goals] [DecidableEq goals]
    (tactics : Finset TacticShape)
    (applyTrace : goals → List TacticShape → Option goals) :
    ∃ (E : Type*) (_ : NormedAddCommGroup E) (ε : LipschitzGoalEmbedding goals tactics E),
      (ε.lipschitz_const : ℝ) ≤
        (Matrix.opNorm (regularRepresentation M).toFun 1 : ℝ) ∧
      Module.finrank ℝ E ≤ Fintype.card M := by
  sorry
```

**Proof Strategy:**

*Step 1:* Define the embedding `ε(g) = ρ_reg(δ(g))` where `δ(g)` is the "goal vector" with 1 in position `g` and 0 elsewhere.

*Step 2:* Prove `‖ε(g₁) - ε(g₂)‖ = ‖ρ_reg(δ(g₁) - δ(g₂))‖ ≤ ‖ρ_reg‖ · ‖δ(g₁) - δ(g₂)‖`.

*Step 3:* Show `‖δ(g₁) - δ(g₂)‖ ≤ d(g₁, g₂)` by constructing the path in the Cayley graph of the tactic monoid.

*Step 4:* The Lipschitz constant is bounded by the operator norm of `ρ_reg(1)`, which is computable.

---

#### Theorem 4: Lipschitz Constant Determined by Operator Norm

```lean
/-- **Operator Norm Lipschitz Bound**
    The optimal Lipschitz constant for the canonical goal embedding
    equals the operator norm of the regular representation evaluated at
    the identity element.
    
    Bridge: connects functional analysis (operator norms) to
    certified_robustness bounds for neural proof search.
    Impact: gives an EXACT Lipschitz constant (not just an upper bound)
    for certified adversarial robustness of theorem provers. -/
theorem lipschitz_constant_operator_norm (M : Type*) [Monoid M] [Fintype M]
    [DecidableEq M] (goals : Type*) [Fintype goals] [DecidableEq goals]
    (tactics : Finset TacticShape)
    (hconn : ∀ g₁ g₂ : goals, proofDistance goals tactics g₁ g₂ ≠ ⊤) :
    ∃ (ε : LipschitzGoalEmbedding goals tactics (Fin (Fintype.card M) → ℝ)),
      ε.lipschitz_const = Matrix.opNorm (regularRepresentation M).toFun 1 := by
  sorry
```

---

### Part III: Irreducible Proof Depth Bounds

#### Theorem 5: Depth Bound from Irreducible Decomposition

```lean
/-- The tactic trace character records which irreducible representations
    appear in the decomposition of the tactic trace. -/
def tacticTraceCharacter (M : Type*) [Monoid M] [Fintype M] [DecidableEq M]
    (K : Type*) [Field K] [DecidableEq K]
    (irreps : Finset (TacticRepresentation M K)) :
    TacticTrace → Finset ℕ :=
  fun trace => {i ∈ irreps | isIrreducibleComponent i trace}

/-- **Irreducible Depth Bound Theorem**
    The proof depth of a goal is bounded by the number of distinct
    irreducible representations appearing in its tactic trace character:
    
      depth(g) ≤ |{ρ ∈ Irr(M) : ρ appears in trace(g)}|
    
    Moreover, this bound is tight: there exist goals for which equality holds,
    and the bound is O(log |M|) for monoids with few irreducible types.
    
    Bridge: connects representation character theory to proof complexity
    and computational complexity of proof search.
    Impact: gives O(log |M|) proof depth bounds for tactic monoids with
    polylogarithmic irreducible count, directly relevant to
    lattice_crypto hardness assumptions (short vectors in ideal lattices
    correspond to short proofs in sparse monoid representations). -/
theorem irreducible_depth_bound (M : Type*) [Monoid M] [Fintype M] [DecidableEq M]
    (K : Type*) [Field K] [DecidableEq K]
    (hchar : Ring.char K = 0 ∨ (Ring.char K ∣ Fintype.card M → False))
    (goals : Type*) [Fintype goals] [DecidableEq goals]
    (depth : goals → ℕ)
    (irreps : Finset (TacticRepresentation M K))
    (hdecomp : isCompleteIrreducibleDecomposition M K irreps) :
    ∀ g : goals,
      depth g ≤ (tacticTraceCharacter M K irreps (goalTrace g)).card ∧
      ∃ g₀ : goals,
        depth g₀ = (tacticTraceCharacter M K irreps (goalTrace g₀)).card := by
  sorry
```

**Proof Strategy:**

*Step 1:* Each tactic application either (a) introduces a new irreducible component or (b) increases the multiplicity of an existing one. Case (a) increases the character set cardinality by at most 1.

*Step 2:* The depth of a goal equals the length of the shortest trace reaching it. Each step in the trace can introduce at most one new irreducible.

*Step 3:* Therefore `depth(g) ≤ |Irr(trace(g))|`.

*Step 4:* For tightness: take a goal whose trace uses each irreducible exactly once. The depth equals the number of irreducibles.

---

#### Theorem 6: Maschke-Type Stratification

```lean
/-- **Representation-Theoretic Proof Stratification**
    Goals stratify into levels indexed by their irreducible character
    complexity. Level-k goals require traces with exactly k distinct
    irreducible representations. The number of goals at level k is
    bounded by (|M| choose k) · (dimension bound)^k.
    
    Bridge: connects algebraic combinatorics to proof search complexity.
    Impact: gives explicit O(|M|^k) bounds on proof search space size
    at each level, enabling certified_robustness guarantees for
    bounded-depth neural provers. -/
theorem proof_stratification_bound (M : Type*) [Monoid M] [Fintype M] [DecidableEq M]
    (K : Type*) [Field K] [DecidableEq K]
    (irreps : Finset (TacticRepresentation M K))
    (goals : Type*) [Fintype goals] [DecidableEq goals]
    (level : goals → ℕ) :
    ∀ k : ℕ,
      (Finset.filter (fun g => level g = k) Finset.univ).card ≤
        (Fintype.card M).choose k * ((Fintype.card M : ℕ) : ℕ)^k := by
  sorry
```

---

#### Theorem 7: Certified Robustness from Lipschitz Embeddings

```lean
/-- **Certified Robustness Theorem for Neural Provers**
    If a neural prover uses a Lipschitz goal embedding with constant L,
    then adversarial perturbations of norm < δ can only fool the prover
    on goals within proof distance δ/L. This gives a certified robustness
    radius of δ/L in proof-distance space.
    
    Bridge: connects Lipschitz certification (ML robustness) to
    proof-theoretic distance (logic).
    Impact: first certified_robustness guarantee for neural theorem
    provers against adversarial proof search perturbations. -/
theorem certified_prover_robustness (goals : Type*) [Fintype goals] [DecidableEq goals]
    (tactics : Finset TacticShape)
    (E : Type*) [NormedAddCommGroup E]
    (ε : LipschitzGoalEmbedding goals tactics E)
    (prover : E → Option goals)
    (δ : ℝ) (hδ : 0 < δ) :
    ∀ g₁ g₂ : goals,
      ‖ε.embed g₁ - ε.embed g₂‖ < δ →
      proofDistance goals tactics g₁ g₂ < δ / ε.lipschitz_const →
      prover (ε.embed g₁) = prover (ε.embed g₂) ∨
      proofDistance goals tactics g₁ g₂ ≥ δ / ε.lipschitz_const := by
  intro g₁ g₂ h_norm h_dist
  -- If proof distance is small, embeddings are close, so prover must agree
  -- or the distance threshold is violated
  left
  by_contra h_ne
  -- If prover disagrees, the goals must be far apart in proof distance
  have := ε.lipschitz_certified g₁ g₂
  -- This contradicts h_dist
  omega
```

---

#### Theorem 8: Post-Quantum Security from Proof Depth

```lean
/-- **Post-Quantum Security from Representation Depth**
    Finding a proof of depth ≤ k in a tactic monoid with n irreducible
    representations requires Ω(2^(n/k)) quantum queries when the
    irreducible decomposition has dimension ≥ 2 per component.
    This gives post-quantum security for proof-of-work systems based
    on proof search.
    
    Bridge: connects representation theory to post-quantum cryptography
    and lattice_crypto hardness.
    Impact: establishes quantum-resistant proof-of-work from algebraic
    structure of proof systems. -/
theorem post_quantum_proof_security (n k : ℕ) (hk : 0 < k) :
    ∃ (M : Type*) (_ : Monoid M) (_ : Fintype M) (_ : DecidableEq M),
      Fintype.card M = 2^n ∧
      ∀ (quantum_adversary : QuantumQuery → Option TacticTrace),
        (quantum_adversary.proof_depth_bound k).queries ≥ 2^(n/k : ℕ) := by
  sorry
```

---

#### Theorem 9: Convergence Rate for Neural Proof Mining

```lean
/-- **Neural Proof Mining Convergence**
    A neural prover trained on Lipschitz goal embeddings converges to
    the optimal proof strategy at rate O(L²/n) where L is the Lipschitz
    constant and n is the number of training examples.
    
    Bridge: connects learning theory to representation-theoretic proof search.
    Impact: gives explicit convergence bounds for certified_robustness
    of learned theorem provers. -/
theorem neural_proof_mining_convergence (L : ℝ) (n : ℕ) (hL : 0 < L) :
    ∀ (ε_goal : ℝ) (hε : 0 < ε_goal),
      ∃ (N : ℕ),
        N = ⌈L^2 / (n * ε_goal^2)⌉₊ ∧
        ∀ m ≥ N,
          ‖learned_strategy m - optimal_strategy‖ ≤ ε_goal := by
  sorry
```

---

#### Theorem 10: Tactic Monoid Isomorphism Invariant

```lean
/-- **Tactic Monoid Isomorphism Invariant Theorem**
    Two proof systems have isomorphic tactic monoids if and only if
    their irreducible representation theories are equivalent.
    This provides a complete invariant for proof search complexity.
    
    Bridge: connects category theory (isomorphism invariants) to
    proof theory (search complexity).
    Impact: classifies proof systems by representation type,
    enabling transfer of certified_robustness results between systems. -/
theorem tactic_isomorphism_invariant (M₁ M₂ : Type*)
    [Monoid M₁] [Monoid M₂] [Fintype M₁] [Fintype M₂]
    [DecidableEq M₁] [DecidableEq M₂]
    (K : Type*) [Field K] [DecidableEq K]
    (hchar : Ring.char K = 0 ∨ (Ring.char K ∣ Fintype.card M₁ → False)) :
    (∃ (e : M₁ ≃* M₂), True) ↔
      (∃ (h : Fintype.card M₁ = Fintype.card M₂),
        ∀ (ρ₁ : IrreducibleRep M₁ K) (ρ₂ : IrreducibleRep M₂ K),
          dimension ρ₁ = dimension ρ₂ ↔ True) := by
  sorry
```

---

### FUTURE_DIRECTIONS.md Requirements

After proving the above, produce a `FUTURE_DIRECTIONS.md` containing:

1. **Tropical Proof Mining**: Extend to min-plus semirings where the Lipschitz constant becomes a tropical eigenvalue. Connect to tropical_hash_collision resistance in post-quantum proof-of-work.

2. **Quantum Tactic Monoids**: Define quantum tactic representations over ℂ with unitarity constraints. Prove that quantum proof search has O(√n) speedup over classical (matching Grover's bound) using representation-theoretic arguments.

3. **Hamiltonian Proof Systems**: Define a proof Hamiltonian whose ground state energy equals the minimum proof depth. Prove that the spectral gap bounds the mixing time of proof search MCMC, connecting to quantum_annealing for theorem proving.

4. **Lattice-Based Proof Certificates**: Show that short vectors in the ideal lattice of the tactic monoid correspond to short proofs, establishing a reduction from proof search to lattice_crypto SVP. This gives post_quantum_security for proof-of-work.

5. **Neural Tangent Kernel of Proof Search**: Compute the neural tangent kernel of a Lipschitz goal embedding prover and show its eigenvalues are bounded by the irreducible character values, giving explicit generalization bounds for learned provers.

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
            Open the field of neural proof mining by establishing that proof tactics form a monoid whose representation theory governs proof search complexity. Prove three foundational results: (1) The tactic shape monoid of a proof system admits faithful finite-dimensional representations whose irreducible decomposition classifies proof strategies, with each irreducible corresponding to a canonical strategy type and the regular representation decomposing via Maschke's theorem for finite monoids. (2) Goal embeddings satisfying a Lipschitz condition relative to proof distance certify faithful neural representations of proof-theoretic proximity, with the Lipschitz constant determined by the operator norm of the regular representation and existence guaranteed at dimension equal to the monoid order. (3) The irreducible decomposition of the tactic shape monoid yields tight proof depth bounds: the depth of a goal is bounded by the number of distinct irreducible representations appearing in its tactic trace character, giving a Maschke-type theorem for proof complexity that stratifies goals into representation-theoretic levels.

            ### Precise Mathematical Framing
            Let (S, ∘, id) be the tactic shape monoid of a proof system, where S is the finite set of tactic shapes (intro, apply, rewrite, induction, etc.) with sequential composition. A representation is a monoid homomorphism ρ: S → End(V) for a finite-dimensional vector space V. The regular representation ρ_reg: S → End(ℂ[S]) decomposes as ⊕ᵢ mᵢVᵢ via Maschke's theorem for finite monoids over ℂ. Theorem 1 (Tactic Monoid Representation): Each irreducible Vᵢ corresponds to a canonical proof strategy σᵢ, and every composite proof strategy decomposes uniquely into irreducible strategy components via the isotypic decomposition. The strategy type of a goal g is the irreducible Vᵢ maximizing ⟨χ_g, χᵢ⟩. Theorem 2 (Goal Embedding Lipschitz Certification): A goal embedding φ: Goal → ℝⁿ is L-proof-Lipschitz if ‖φ(g₁) - φ(g₂)‖₂ ≤ L · d_proof(g₁, g₂). Such embeddings exist with L = ‖ρ_reg‖_op and n = |S|, constructed via the character table of S mapped to ℝ^|S|. Theorem 3 (Irreducible Depth Bounds): For provable goal g with tactic trace character χ_g = Σₛ aₛ·s ∈ ℂ[S], depth(g) ≤ |{i : ⟨χ_g, χᵢ⟩ ≠ 0}| where χᵢ are the irreducible characters. This stratifies goals by representation-theoretic complexity: goals in a single isotypic component have depth 1, while goals requiring k distinct irreducible strategy types need depth ≥ k.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `depth_filtration_lipschitz_bound` : theorem depth_filtration_lipschitz_bound
     (file: Bridges/HomologicalDeepLearning.lean)
  2. `lawvere_proof_coding_theorem` : theorem lawvere_proof_coding_theorem
     (file: Bridges/LawvereCodingTheorem.lean)
  3. `depth_bounded_stabilization` : theorem depth_bounded_stabilization {α : Type*} [BooleanAlgebra α]
     (file: Bridges/ProvabilitySpectralTheory.lean)
  4. `field_causal_depth_zero` : theorem field_causal_depth_zero (K : Type*) [Field K] :
     (file: Bridges/CausalZariskiReconstruction.lean)
  5. `finite_representation_formula` : theorem finite_representation_formula [Nonempty X]
     (file: Bridges/FiniteRiesz.lean)

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



Recent successful concepts: Algebraic K-Theory of Neural Architectures: Projective Transfer Classification, Elementary Adversarial Certification, and Milnor Compositional Bounds, Differential-Algebraic Learning: Backpropagation Derivation Structure, Differential Galois Architecture Classification, and Ritt Decomposition Training Bounds, Cohomological Cryptography: Extension Obstruction One-Way Functions, Cup Product Commitment Certification, and Inflation-Restriction Key Exchange


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
Research mode: prove
