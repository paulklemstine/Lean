

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

## SYMPLECTIC POST-QUANTUM CRYPTOGRAPHY: Lagrangian Key Exchange, Transvection Generation, and Uncertainty-Principle Shielding

### THE VISION

We open an entirely new cryptographic primitive: **symplectic cryptography**, where hardness arises not from lattice problems (SIS/LWE), code problems (SD/Goppa), or multivariate quadratic systems — but from the intersection geometry of Lagrangian subspaces in symplectic vector spaces over finite fields. The symplectic form ω, which classically encodes the canonical commutation relations [x̂ᵢ, p̂ⱼ] = iℏδᵢⱼ of quantum mechanics, becomes the shield: any quantum adversary distinguishing Lagrangian subspaces must violate these commutation relations, incurring provable Ω(√p) query complexity. This is the first cryptographic construction whose quantum resistance is information-theoretic rather than computational, derived from the structure of phase space itself.

---

### PRECISE THEOREM TARGETS

#### TARGET 1: Symplectic Transvection Decomposition with Explicit Bound

**Theorem (transvection_decomposition_bounded)**: Every symplectic matrix over F_p decomposes as a product of at most 4n symplectic transvections, where n is the symplectic half-dimension.

```lean
theorem transvection_decomposition_bounded {n : ℕ} {p : ℕ} [hp : Fact (Nat.Prime p)]
    (M : Matrix (Fin (2*n)) (Fin (2*n)) (ZMod p))
    (hM : M ∈ Matrix.symplecticGroup (Fin (2*n)) (ZMod p)) :
    ∃ (k : ℕ) (v : Fin k → (Fin (2*n)) → ZMod p) (hv : ∀ i, v i ≠ 0),
    k ≤ 4 * n ∧
    M = (List.ofFn fun i => symplecticTransvection (J ![]) (v i)).prod :=
  sorry -- DO NOT USE SORRY; prove by induction on dimension
```

**Proof Strategy A (Dimension Induction — MOST PROMISING)**: 
- Base: n = 1, Sp(2, F_p) = SL(2, F_p). Every SL₂ element is a product of ≤ 4 elementary transvections (this is the classical generation by shear matrices). Prove this directly by case analysis on matrix entries using `rcases`.
- Inductive step: Given M ∈ Sp(2n, F_p), find v such that T_v · M fixes e₁. This uses the transitivity of Sp(2n) on non-zero vectors (a consequence of Witt's theorem for symplectic spaces). Then apply the inductive hypothesis to the stabilizer of e₁, which is isomorphic to Sp(2(n-1), F_p) ⋉ (F_p)^(n-1).
- Key lemma: `symplectic_group_transitive_on_nonisotropic_vectors` — for any non-zero u, w with ω(u,u) = ω(w,w), ∃ g ∈ Sp(2n) with g · u = w. Prove by constructing g as a product of ≤ 2 transvections.
- Bound: T(n) ≤ 2 + T(n-1) + 2, giving T(n) ≤ 4n.

**Proof Strategy B (Bruhat Decomposition)**:
- Decompose Sp(2n, F_p) into Bruhat cells indexed by Weyl group elements. Each cell representative w can be written as a product of ≤ n simple reflections, each a product of ≤ 2 transvections. The unipotent radicals contribute ≤ 2n additional transvections.
- This gives 4n but requires developing the Bruhat decomposition, which is heavier machinery.

**Proof Strategy C (Elementary Row Reduction)**:
- Mimic Gaussian elimination in symplectic setting. Use symplectic transvections as "elementary operations" that preserve ω. Clear entries column by column, requiring at most 2 transvections per entry.

#### TARGET 2: Lagrangian Intersection Dimension and Key Exchange Correctness

**Theorem (lagrangian_intersection_dimension_bound)**: For any two Lagrangian subspaces of a 2n-dimensional symplectic space, their intersection has dimension between 0 and n.

```lean
theorem lagrangian_intersection_dimension_bound {V : Type*} 
    [AddCommGroup V] [Module (ZMod p) V] [FiniteDimensional (ZMod p) V]
    (ω : AlternatingForm (ZMod p) V) (hω : SymplecticForm ω)
    (L_A L_B : LagrangianSubspace ω) :
    0 ≤ Module.finrank (ZMod p) (L_A.1 ⊓ L_B.1) ∧
    Module.finrank (ZMod p) (L_A.1 ⊓ L_B.1) ≤ 
      Module.finrank (ZMod p) V / 2 :=
  sorry -- Prove using isotropic containment and dimension formula
```

**Theorem (lagrangian_key_exchange_correctness)**: Two parties exchanging transformed Lagrangian subspaces derive the same shared secret dimension.

```lean
theorem lagrangian_key_exchange_correctness {V : Type*}
    [AddCommGroup V] [Module (ZMod p) V] [FiniteDimensional (ZMod p) V]
    (ω : AlternatingForm (ZMod p) V) (hω : SymplecticForm ω)
    (L_A L_B : LagrangianSubspace ω)
    (g_A g_B : Matrix (Fin (2*n)) (Fin (2*n)) (ZMod p))
    (hgA : g_A ∈ Matrix.symplecticGroup (Fin (2*n)) (ZMod p))
    (hgB : g_B ∈ Matrix.symplecticGroup (Fin (2*n)) (ZMod p)) :
    Module.finrank (ZMod p) ((g_A • L_A.1) ⊓ (g_B • L_B.1)) =
    Module.finrank (ZMod p) (L_A.1 ⊓ ((g_A⁻¹ * g_B) • L_B.1)) :=
  sorry -- Prove by symplectic invariance and change of basis
```

**Proof Strategy (Dimension Formula)**:
- Key lemma: `lagrangian_self_orthogonal` — for Lagrangian L, L = L^⊥ where ⊥ is the symplectic complement. This uses maximality of L as an isotropic subspace.
- Key lemma: `intersection_isotropic` — L_A ∩ L_B is isotropic (since both are isotropic).
- Key lemma: `symplectic_complement_intersection` — (L_A ∩ L_B)^⊥ ⊇ L_A^⊥ + L_B^⊥ = L_A + L_B, giving dim(L_A ∩ L_B) = dim(L_A) + dim(L_B) - dim(L_A + L_B) = 2n - dim(L_A + L_B) ≤ n.
- For correctness: use that g_A, g_B preserve ω, so g_A • L_A is still Lagrangian. Apply dimension invariance under symplectic transformations.

#### TARGET 3: Quantum Shielding via Symplectic Uncertainty Principle

**Theorem (symplectic_uncertainty_shielding)**: Any quantum oracle algorithm distinguishing two Lagrangian subspaces of Sp(2n, F_p) requires Ω(√p) queries.

```lean
theorem symplectic_uncertainty_shielding (n : ℕ) (p : ℕ) [hp : Fact (Nat.Prime p)]
    (h_large : p > 2^(2*n)) :
    ∃ (C : ℕ), C > 0 ∧
    ∀ (A : QuantumOracle → Bool),  -- Abstract quantum algorithm
    -- Any algorithm making fewer than C * √p queries
    -- cannot reliably distinguish random Lagrangians
    Pr[distinction_success A] ≤ 1/2 + (1 : ℝ) / (√(p : ℝ)) :=
  sorry -- This is the information-theoretic bound
```

**Concrete realizable version**: The symplectic form ω encodes canonical commutation relations. Two Lagrangian subspaces correspond to two maximal commuting sets of observables. Distinguishing them requires measuring non-commuting observables.

```lean
-- Bridge: connects symplectic geometry to quantum information
theorem symplectic_commutator_lower_bound {n : ℕ} {p : ℕ} [Fact (Nat.Prime p)]
    (L_A L_B : LagrangianSubspace ω)
    (h_transverse : Module.finrank (ZMod p) (L_A.1 ⊓ L_B.1) = 0) :
    -- For any v ∈ L_A and w ∈ L_B with ω(v,w) ≠ 0,
    -- the corresponding quantum observables don't commute
    ∀ (v : L_A.1) (w : L_B.1), 
      ω v w ≠ 0 → 
      -- The "symplectic distance" is at least √p
      symplecticDistance L_A L_B ≥ √(p : ℝ) :=
  sorry
```

**Proof Strategy (BBBV-type polynomial method adapted to symplectic setting)**:
- Encode the Lagrangian distinguishing problem as a query problem to a phase oracle O_L indexed by Lagrangian L.
- The acceptance probability of any T-query quantum algorithm is a degree-2T polynomial in the oracle variables.
- Two transverse Lagrangians (L_A ∩ L_B = 0) differ in p^n positions. By the symplectic uncertainty principle, measuring L_A-observables and L_B-observables simultaneously has uncertainty ≥ ℏ per dimension.
- Total uncertainty over n dimensions: ≥ nℏ = n (in natural units). This forces the distinguishing advantage to be O(T/√p).
- Setting T < C√p gives advantage < 1/2 + ε for small ε.

---

### REQUIRED DEFINITIONS AND STRUCTURES (5+)

```lean
/-- A symplectic transvection: T_v(x) = x + ω(x,v) · v -/
def symplecticTransvection {n : ℕ} {p : ℕ} [Fact (Nat.Prime p)]
    (ω : AlternatingForm (ZMod p) (Fin (2*n) → ZMod p))
    (v : Fin (2*n) → ZMod p) : 
    Fin (2*n) → ZMod p →ₗ[ZMod p] Fin (2*n) → ZMod p

/-- A Lagrangian subspace: maximal isotropic, self-orthogonal -/
structure LagrangianSubspace {V : Type*} [AddCommGroup V] [Module (ZMod p) V]
    [FiniteDimensional (ZMod p) V]
    (ω : AlternatingForm (ZMod p) V) where
  carrier : Submodule (ZMod p) V
  is_isotropic : ∀ x ∈ carrier, ∀ y ∈ carrier, ω x y = 0
  is_maximal : ∀ L ≥ carrier, (∀ x ∈ L, ∀ y ∈ L, ω x y = 0) → L = carrier
  is_half_dimension : Module.finrank (ZMod p) carrier = Module.finrank (ZMod p) V / 2

/-- Symplectic distance between Lagrangian subspaces -/
def symplecticDistance {V : Type*} [AddCommGroup V] [Module (ZMod p) V]
    [FiniteDimensional (ZMod p) V]
    (ω : AlternatingForm (ZMod p) V)
    (L₁ L₂ : LagrangianSubspace ω) : ℝ :=
  √(p : ℝ) ^ (Module.finrank (ZMod p) (L₁.1 ⊓ L₂.1))

/-- The Lagrangian Diffie-Hellman key exchange protocol -/
structure LagrangianDiffieHellman (n : ℕ) (p : ℕ) [Fact (Nat.Prime p)] where
  -- Public: the symplectic space (V, ω) and base Lagrangian L₀
  base_lagrangian : LagrangianSubspace symplecticFormStd
  -- Alice's secret: symplectic transformation g_A, sends L₀ to her public Lagrangian
  alice_secret : Matrix (Fin (2*n)) (Fin (2*n)) (ZMod p)
  alice_secret_symplectic : alice_secret ∈ Matrix.symplecticGroup (Fin (2*n)) (ZMod p)
  -- Bob's secret: symplectic transformation g_B
  bob_secret : Matrix (Fin (2*n)) (Fin (2*n)) (ZMod p)
  bob_secret_symplectic : bob_secret ∈ Matrix.symplecticGroup (Fin (2*n)) (ZMod p)
  -- Shared secret dimension = dim(g_A · L₀ ∩ g_B · L₀)
  shared_secret_dimension : ℕ

/-- The Symplectic Subspace Intersection Problem (SSIP): computational hardness assumption -/
def SSIP_Hardness (n : ℕ) (p : ℕ) (λ : ℕ) : Prop :=
  ∀ (A : Algorithm), -- polynomial-time algorithm
    time_bound A ≤ poly(n, log p) →
    Pr[compute_intersection_dim A n p = true] ≤ (1 : ℝ)/2 + 1/(p : ℝ)^λ
```

---

### PROOF STRATEGY DETAILS FOR KEY LEMMAS

**Lemma 1 (transvection_preserves_symplectic)**: A symplectic transvection T_v lies in Sp(2n, F_p).

```lean
lemma transvection_preserves_symplectic {n p : ℕ} [Fact (Nat.Prime p)]
    (ω : AlternatingForm (ZMod p) (Fin (2*n) → ZMod p)) 
    (hω : ω.IsSymplectic)
    {v : Fin (2*n) → ZMod p} (hv : v ≠ 0) :
    symplecticTransvection ω v ∈ Matrix.symplecticGroup (Fin (2*n)) (ZMod p)
```
*Proof*: Direct computation. Show ω(T_v(x), T_v(y)) = ω(x,y) by expanding and using ω(x,y) = -ω(y,x). Use `field_simp` and the alternating property.

**Lemma 2 (transvections_generate_symplectic)**: Symplectic transvections generate the full symplectic group.

```lean
lemma transvections_generate_symplectic {n p : ℕ} [Fact (Nat.Prime p)] :
    Subgroup.closure {symplecticTransvection ω v | v ≠ 0} = 
    Matrix.symplecticGroup (Fin (2*n)) (ZMod p)
```
*Proof*: By Artin-Dieudonné. Show that any g ∈ Sp(2n) either has a fixed non-zero vector (then g = T_v · h for some transvection T_v and h with smaller support) or is the identity. Induction on the "symplectic displacement."

**Lemma 3 (lagrangian_grassmannian_size)**: |Lag(2n, F_p)| = ∏ᵢ₌₀ⁿ⁻¹ (p^(n+i) + ... + p^i + 1). This gives the key space size for cryptographic security.

```lean
lemma lagrangian_grassmannian_size {n p : ℕ} [Fact (Nat.Prime p)] :
    Fintype.card (LagrangianSubspace symplecticFormStd) = 
    ∏ i : Fin n, (∑ j : Fin (n - i + 1), p ^ (i : ℕ) * p ^ (j : ℕ))
```
*Proof*: Count Lagrangian subspaces by building them one dimension at a time. At step i, we have an i-dimensional isotropic subspace and need to extend by one dimension. The number of choices is computed via the symplectic complement structure.

**Lemma 4 (symplectic_uncertainty_principle)**: For transverse Lagrangians L_A, L_B with L_A ∩ L_B = 0, the symplectic form restricts to a perfect pairing L_A × L_B → F_p.

```lean
lemma symplectic_perfect_pairing_transverse {V : Type*}
    [AddCommGroup V] [Module (ZMod p) V] [FiniteDimensional (ZMod p) V]
    {ω : AlternatingForm (ZMod p) V} {hω : SymplecticForm ω}
    {L_A L_B : LagrangianSubspace ω}
    (h_transverse : L_A.1 ⊓ L_B.1 = ⊥) :
    Function.Bijective (fun v : L_A.1 => fun w : L_B.1 => ω v w)
```
*Proof*: Use that L_B = L_A^⊥ (since L_B is Lagrangian and transverse to L_A). The restriction ω|_{L_A × L_B} is then a perfect pairing by non-degeneracy of ω.

**Lemma 5 (key_exchange_security_reduction)**: Breaking the Lagrangian Diffie-Hellman protocol reduces to SSIP.

```lean
theorem lagrangian_DH_security_reduction {n p : ℕ} [Fact (Nat.Prime p)]
    (h_SSIP : SSIP_Hardness n p 1) :
    -- Any adversary breaking LagDH with advantage ε
    -- yields an SSIP solver with comparable advantage
    ∀ (Adv : LagrangianDiffieHellman n p → Bool),
    |Pr[Adv_correct Adv] - 1/2| ≤ ε →
    ∃ (Solver : Algorithm), SSIP_advantage Solver ≥ ε / 2
```
*Proof*: Reduction. Given a LagDH distinguisher, construct an SSIP solver that embeds the SSIP instance into the LagDH protocol. The symplectic group acts transitively on Lagrangian pairs with fixed intersection dimension, so the embedding preserves the success probability up to a polynomial factor.

---

### CROSS-DOMAIN CONNECTIONS

**Bridge: Symplectic Geometry ↔ Post-Quantum Cryptography**: Lagrangian subspaces are the key space; the symplectic form provides quantum resistance. The SSIP problem is structurally different from SIS/LWE — it is a geometric intersection problem in a non-Euclidean space.

**Bridge: Symplectic Geometry ↔ Quantum Mechanics**: The symplectic form ω on (F_p)^(2n) is the finite-field avatar of the canonical commutation relations. Lagrangian subspaces correspond to maximal commuting observable sets. The uncertainty principle (non-commutativity of x̂ᵢ and p̂ⱼ when i≠j, encoded by ω ≠ 0) directly provides the quantum shielding.

**Bridge: Algebraic Groups ↔ Cryptographic Primitives**: The symplectic group Sp(2n, F_p) is a Chevalley group of type C_n. Its structure theory (Bruhat decomposition, maximal tori, Weyl group) provides the algorithmic backbone for key generation, validation, and the transvection decomposition theorem.

---

### SIGNIFICANCE

This work opens **symplectic cryptography** as a new paradigm, orthogonal to all existing post-quantum candidates:
- **vs. Lattice-based (Kyber, Dilithium)**: Lattices live in Euclidean space (R^n with inner product). Symplectic cryptography lives in phase space (F_p^(2n) with symplectic form). The geometry is fundamentally different — symplectic, not metric.
- **vs. Code-based (McEliece)**: Code-based crypto hides structure via permutation equivalence. Symplectic crypto hides structure via symplectic equivalence, which preserves the alternating form rather than Hamming weight.
- **vs. Isogeny-based (SIDH)**: Both use algebraic geometry, but SIDH uses elliptic curve isogenies (dimension 1), while symplectic crypto uses Lagrangian Grassmannians (arbitrary dimension). The higher-dimensional structure provides more flexibility and larger key spaces.

The quantum shielding theorem is the first information-theoretic security guarantee in post-quantum cryptography — it does not rely on the assumption that quantum computers cannot solve certain problems, but on the structural fact that quantum mechanics itself prevents efficient Lagrangian distinction.

---

### DELIVERABLE REQUIREMENTS

Prove at least **15 theorems** with ZERO sorries, using diverse tactics:
- `induction` for the transvection decomposition bound
- `rcases` for the Lagrangian intersection dimension cases
- `by_contra` for the perfect pairing lemma
- `omega` / `linarith` for dimension inequalities
- `field_simp` for the symplectic form computations
- `simp` only for definitional unfoldings, NOT for substantial proofs

Define at least **5 structures** (`LagrangianSubspace`, `SymplecticTransvection`, `LagrangianDiffieHellman`, `SSIP_Hardness`, `symplecticDistance`).

Include **explicit computational bounds**: transvection decomposition ≤ 4n, key space ≥ p^(n²), quantum query complexity ≥ Ω(√p), Lagrangian intersection dimension ≤ n.

Every theorem doc comment must include `Bridge: connects X to Y` identifying the cross-domain connection.

Produce a **FUTURE_DIRECTIONS.md** with 3-5 concrete next steps:
1. Extend to symplectic groups over rings Z/p^k Z (lattice-chained symplectic crypto)
2. Prove IND-CPA security of Lagrangian Diffie-Hellman under SSIP in the quantum random oracle model
3. Construct symplectic hash functions from the Lagrangian Grassmannian and prove collision resistance
4. Connect to tropical geometry: tropical Lagrangian subspaces and min-plus symplectic forms for certified ML robustness
5. Implement constant-time Lagrangian subspace arithmetic for embedded systems

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
            Open the field of symplectic cryptography by proving three foundational theorems that bridge symplectic geometry and post-quantum cryptography. (1) Lagrangian Diffie-Hellman Key Exchange: Define a key exchange protocol where two parties exchange Lagrangian subspaces of a symplectic vector space (V, ω) over F_p and derive a shared secret from the symplectic complement of their intersection. Prove that security reduces to the Symplectic Subspace Intersection Problem (SSIP), which is computationally hard even for quantum adversaries due to the non-degeneracy of ω. (2) Symplectic Transvection Decomposition: Prove that every symplectic matrix over F_p decomposes as a product of symplectic transvections T_v(x) = x + ω(x,v)·v, generalizing Williamson's normal form theorem and providing the algorithmic foundation for efficient key generation and validation. (3) Uncertainty-Principle Quantum Shielding: Prove that any quantum algorithm distinguishing Lagrangian subspaces must violate the symplectic uncertainty principle (the canonical commutation relations [x̂ᵢ, p̂ⱼ] = iℏδᵢⱼ encoded by ω), yielding provable information-theoretic lower bounds of Ω(√p) on quantum attack complexity that grow with symplectic dimension. This creates the first bridge between symplectic geometry (Sp(2n, F_p), Lagrangian Grassmannians, symplectic transvections) and cryptographic hardness (key exchange, quantum resistance, information-theoretic shielding), opening an entirely new field that is structurally orthogonal to lattice-based, code-based, and multivariate cryptography.

            ### Precise Mathematical Framing
            Let (V, ω) be a symplectic vector space of dimension 2n over F_p with ω the standard alternating form. A Lagrangian subspace L ⊂ V is a maximal isotropic subspace: dim L = n and ω(u,v) = 0 for all u,v ∈ L. The symplectic group Sp(2n, F_p) acts transitively on the Lagrangian Grassmannian Lag(V) ≅ Sp(2n, F_p)/P (parabolic subgroup). THEOREM 1 (Lagrangian DH): Define DH_ω: (L_A, L_B) ↦ (L_A ∩ g·L_B)^⊥ω where g ∈ Sp(2n, F_p) is the public symplectic transformation. Prove correctness (both parties compute the same shared key via symplectic complementation) and security (an eavesdropper solving SSIP recovers the key, but SSIP reduces to computing Lagrangian intersection orbits, which requires Ω(p^{n/2}) classical operations). THEOREM 2 (Transvection Decomposition): Prove that every M ∈ Sp(2n, F_p) admits a decomposition M = T_{v_1} · T_{v_2} · ... · T_{v_k} where each T_v is a symplectic transvection, with k ≤ 4n^2 + O(n), providing O(n^2 log p) key generation. THEOREM 3 (Quantum Shielding): The symplectic form ω encodes canonical commutation relations; prove that any quantum query algorithm distinguishing Lagrangian subspaces L₁, L₂ with L₁ ∩ L₂ = {0} vs. dim(L₁ ∩ L₂) = 1 requires Ω(√p) quantum queries via a symplectic analogue of the polynomial method, establishing information-theoretic quantum resistance.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `post_quantum_nist_security_dimension_bound` : theorem post_quantum_nist_security_dimension_bound
     (file: Tropical/PostQuantum/Algebra.lean)
  2. `purity_lower_bound_from_spectrum` : theorem purity_lower_bound_from_spectrum (k : ℕ) (hk : k > 0)
     (file: Bridges/QuantumIdempotent.lean)
  3. `post_quantum_security_from_faithfulness` : theorem post_quantum_security_from_faithfulness
     (file: MachineLearning/CategoricalRL/FaithfulRepresentation.lean)
  4. `new_bridge_count` : theorem new_bridge_count : newBridges.length = 12 := by decide
     (file: Bridges/ArchitectureOfReality/UnificationGraph.lean)
  5. `security_linear_in_dimension` : theorem security_linear_in_dimension (params : BettiSecurityParams) :
     (file: Bridges/CupProductCryptography.lean)

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



Recent successful concepts: Gödelian Learning Theory: Incompleteness Barriers for Neural Certification, Löb-Theorem Generalization Bounds, and Provability-Operator PAC-Bayesian Analysis, Topological Zero-Knowledge Proofs from Cup-Product Bilinear Pairings: Sigma Protocol Construction, Honest-Verifier Simulation, and Betti-Number Soundness, Geometric Complexity Theory: Representation-Theoretic Obstruction Maps, Orbit Closure Non-Containment, and Algebraic Natural Proofs Barrier


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
