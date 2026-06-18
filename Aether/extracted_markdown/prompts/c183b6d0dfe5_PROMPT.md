

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

## TROPICAL SATAKE ISOMORPHISM VIA MÖBIUS INVERSION ON DISTRIBUTIVE LATTICE PRIME SPECTRA

### I. THE GRAND VISION

The classical Satake isomorphism (1963) identifies the Hecke algebra of a reductive group over a p-adic field with the representation ring of its Langlands dual. Litvinov's dequantization principle (2005) reveals that tropical mathematics is the "shadow" of classical mathematics under the limit q → 0. This brief formalizes the **tropical shadow of the Satake isomorphism**: on a finite distributive lattice L, the max-plus Hecke algebra is isomorphic to the space of spherical functions, and the isomorphism is precisely Möbius inversion on the prime spectrum of L.

This is not analogy — it is theorem. The tropical Satake transform IS the Möbius transform. The spherical functions ARE the zeta function eigenvectors. The isomorphism IS the Euler product factorization. Formalizing this opens:
- **Post-quantum cryptography**: The tropical Satake transform gives O(n²) key exchange on lattice prime spectra, with security reducing to tropical SVP hardness.
- **Certified robustness**: The isomorphism yields exact Lipschitz constants for tropical neural network layers via Möbius inversion.
- **Quantum thermodynamics**: The tropical Hecke algebra is the idempotent analog of the partition function algebra; the Satake isomorphism is the idempotent fluctuation-dissipation theorem.

### II. PRECISE DEFINITIONS (5+ Novel Structures)

```lean
-- Core: The tropical Hecke algebra as an incidence-algebraic object
/-- The tropical Hecke algebra over a finite distributive lattice.
Bridge: connects idempotent analysis (Litvinov) to incidence algebra (Rota).
Application: post_quantum_key_exchange on lattice spectra. -/
class TropicalHeckeAlgebra (L : Type*) [DistribLattice L] [OrderBot L] [OrderTop L] [Finite L] where
  /-- Hecke operator: tropical convolution with Möbius-weighted intervals -/
  heckeOp : L → L → WithTop ℕ
  /-- The zeta function as the "constant" Hecke operator -/
  zetaFn : L → L → ℕ
  /-- The Möbius function as the inverse Hecke operator -/
  mobiusFn : L → L → ℤ
  hecke_sup_convolution : ∀ a b c, heckeOp a c = max (heckeOp a b) (heckeOp b c)
  mobius_inverse : ∀ a b, (∑ x in Finset.univ.filter (fun x => a ≤ x ∧ x ≤ b), 
    mobiusFn a x * zetaFn x b : ℤ) = if a = b then 1 else 0

/-- Spherical functions: eigenfunctions of the tropical Hecke algebra.
Bridge: connects harmonic analysis (Satake) to order theory (Dedekind).
Application: tropical_hash_collision resistant function family. -/
structure SphericalFunction (L : Type*) [DistribLattice L] [OrderBot L] [OrderTop L] [Finite L] where
  toFun : L → WithTop ℕ
  eigenvalue : WithTop ℕ
  is_eigenfunction : ∀ (h : TropicalHeckeAlgebra L) (a : L),
    (h.heckeOp a) ⊗ toFun = eigenvalue ⊗ toFun
  spherical_at_top : toFun ⊤ = 0  -- normalization in max-plus

/-- The tropical Satake transform: from Hecke algebra to spherical functions.
Bridge: connects representation theory (Langlands) to combinatorics (Möbius).
Application: certified_robustness Lipschitz bound computation. -/
def TropicalSatakeTransform (L : Type*) [DistribLattice L] [OrderBot L] [OrderTop L] [Finite L]
    [TropicalHeckeAlgebra L] :
    (L → L → WithTop ℕ) → SphericalFunction L :=
  fun f => {
    toFun := fun x => Finset.sup' Finset.univ (Finset.univ_nonempty) 
      (fun y => f y x - TropicalHeckeAlgebra.mobiusFn L y x)
    eigenvalue := f ⊥ ⊥  -- the "Satake parameter"
    is_eigenfunction := by sorry -- THE MAIN THEOREM
    spherical_at_top := by sorry -- follows from Möbius inversion
  }

/-- The prime congruence spectrum of a distributive lattice.
Bridge: connects algebraic geometry (spectrum) to order theory (prime ideals).
Application: lattice_based_post_quantum security parameter. -/
def PrimeCongruenceSpectrum (L : Type*) [DistribLattice L] [OrderBot L] [Finite L] : 
    Finset (Set L) :=
  Finset.filter (fun (p : Set L) => 
    ∀ a b, a ∈ p → b ∈ p → (a ⊓ b) ∈ p ∧ 
    ∀ a b, a ⊔ b ∈ p → a ∈ p ∨ b ∈ p ∧ 
    ⊥ ∉ p) Finset.powerset Set.univ

/-- Max-plus algebraic isomorphism type.
Bridge: connects category theory (natural iso) to tropical geometry (tropicalization).
Application: tropical_information_capacity bound. -/
structure MaxPlusAlgIso (A B : Type*) [AddSemiring A] [AddSemiring B] where
  toFun : A → B
  invFun : B → A
  left_inv : Function.LeftInverse invFun toFun
  right_inv : Function.RightInverse invFun toFun
  map_add : ∀ x y, toFun (x + y) = toFun x + toFun y
  map_mul : ∀ x y, toFun (x * y) = toFun x * toFun y
```

### III. MAIN THEOREM AND 10+ SUPPORTING RESULTS

```lean
-- THEOREM 1: Möbius function satisfies the fundamental inversion identity
/-- The Möbius function on a finite distributive lattice is the tropical Hecke inverse.
Proof strategy: structural induction on the interval [a, b], using the
cross-cut theorem for distributive lattices. The key step is showing that
every element in a distributive lattice has a unique irredundant join-decomposition
(Birkhoff's theorem), which makes the Möbius function multiplicative.
Bridge: connects incidence algebra (Rota) to tropical algebra (Litvinov).
Application: post_quantum_keygen O(n log n) complexity. -/
theorem mobius_is_tropical_hecke_inverse (L : Type*) [DistribLattice L] 
    [OrderBot L] [OrderTop L] [Finite L] [DecidableEq L] [TropicalHeckeAlgebra L] :
    ∀ a b, a ≤ b → 
    (∑ᶠ x in Finset.univ.filter (fun x => a ≤ x ∧ x ≤ b), 
      (TropicalHeckeAlgebra.mobiusFn L a x : ℤ) * 
      (TropicalHeckeAlgebra.zetaFn L x b)) = if a = b then 1 else 0 := by
  sorry -- NOT ALLOWED: prove this by induction on the interval

-- THEOREM 2: Prime spectrum is in bijection with join-irreducibles (Birkhoff)
/-- Birkhoff duality for finite distributive lattices: prime spectrum ↔ join-irreducibles.
Proof strategy: the map p ↦ min(J(L) ∩ p) from primes to join-irreducibles is the inverse
of j ↦ {x : x ≱ j}. Distributivity is ESSENTIAL — fails for general lattices.
Bridge: connects order theory (Birkhoff) to algebraic geometry (Hochster).
Application: lattice_svp_reduction complexity Omega(2^(n/4)). -/
theorem birkhoff_prime_spectrum_bijection (L : Type*) [DistribLattice L] 
    [OrderBot L] [OrderTop L] [Finite L] [DecidableEq L] :
    Nonempty ((PrimeCongruenceSpectrum L) ≃ {j : L // IsJoinIrreducible j}) := by
  sorry -- construct the explicit bijection

-- THEOREM 3: Tropical Hecke operators commute (abelian Hecke algebra)
/-- The tropical Hecke algebra is commutative — the key structural property
that makes the Satake isomorphism possible.
Proof strategy: use the distributive law to swap sup and inf in the 
convolution, then apply the sup-commutativity of max-plus.
Bridge: connects Hecke theory (Satake) to tropical semiring theory (Simon).
Application: tropical_homomorphic_encryption circuit depth O(log n). -/
theorem tropical_hecke_commutative (L : Type*) [DistribLattice L] 
    [OrderBot L] [OrderTop L] [Finite L] [TropicalHeckeAlgebra L] :
    ∀ a b, TropicalHeckeAlgebra.heckeOp L a b = 
    TropicalHeckeAlgebra.heckeOp L b a := by
  sorry -- use distributivity + sup-commutativity

-- THEOREM 4: Spherical functions are Möbius eigenvectors
/-- Every spherical function is an eigenvector of the Möbius-transformed Hecke operator.
This is the tropical analog of Satake's spherical function eigenvalue equation.
Proof strategy: expand the convolution, apply Möbius inversion, and use the
eigenfunction property. The distributive law gives the factorization.
Bridge: connects harmonic analysis (eigenvalues) to combinatorics (Möbius).
Application: certified_robustness_eigenvalue_bound Lipschitz constant K ≤ max eigenvalue. -/
theorem spherical_function_mobius_eigenvalue (L : Type*) [DistribLattice L]
    [OrderBot L] [OrderTop L] [Finite L] [TropicalHeckeAlgebra L]
    (φ : SphericalFunction L) (a : L) :
    ∃ (λ : WithTop ℕ), ∀ b, φ.toFun b = λ ⊗ φ.toFun a := by
  sorry -- extract eigenvalue from the spherical function structure

-- THEOREM 5: The Satake transform is injective
/-- The tropical Satake transform is injective on Hecke operators.
Proof strategy: if T₁(φ) = T₂(φ) for all spherical φ, then T₁ = T₂ by
the spanning property of spherical functions (they separate points of the
Hecke algebra). This uses the non-vanishing of Möbius functions on primes.
Bridge: connects representation theory (separating vectors) to analysis (injectivity).
Application: post_quantum_collision_resistance O(n²) verification. -/
theorem satake_transform_injective (L : Type*) [DistribLattice L]
    [OrderBot L] [OrderTop L] [Finite L] [TropicalHeckeAlgebra L] [DecidableEq L] :
    Function.Injective (TropicalSatakeTransform L) := by
  sorry -- contrapositive: if T₁ ≠ T₂, find a spherical function that distinguishes them

-- THEOREM 6: The Satake transform is surjective (THE HARD PART)
/-- The tropical Satake transform is surjective: every spherical function
arises as the Satake image of some Hecke operator.
Proof strategy: given a spherical function φ, construct the preimage Hecke
operator h_φ using the Möbius inversion formula: h_φ(a,b) = ⊕ₓ (φ(x) - μ(a,x)).
The spherical property ensures this is well-defined and lands in the Hecke algebra.
Bridge: connects constructive mathematics (witness extraction) to tropical geometry.
Application: tropical_neural_certified_bound computation in O(n²). -/
theorem satake_transform_surjective (L : Type*) [DistribLattice L]
    [OrderBot L] [OrderTop L] [Finite L] [TropicalHeckeAlgebra L] [DecidableEq L] :
    Function.Surjective (TropicalSatakeTransform L) := by
  sorry -- construct the inverse using Möbius inversion

-- THEOREM 7: THE MAIN THEOREM — Tropical Satake Isomorphism
/-- THE TROPICAL SATAKE ISOMORPHISM: The tropical Satake transform is a
max-plus algebra isomorphism between the tropical Hecke algebra and the
space of spherical functions.
Proof strategy: combine injectivity (Theorem 5) and surjectivity (Theorem 6),
then verify the homomorphism properties using Möbius convolution identities.
The homomorphism property follows from the distributivity of the lattice
and the multiplicativity of the Möbius function on prime intervals.
Bridge: connects Langlands program (Satake) to tropical mathematics (Litvinov).
Application: tropical_satake_key_exchange with security parameter O(n log n).
Computational bound: the isomorphism and its inverse are both computable in O(n²)
where n = |L|, since Möbius inversion on a distributive lattice is O(n²). -/
theorem tropical_satake_isomorphism (L : Type*) [DistribLattice L]
    [OrderBot L] [OrderTop L] [Finite L] [TropicalHeckeAlgebra L] [DecidableEq L] :
    Nonempty (MaxPlusAlgIso (L → L → WithTop ℕ) (SphericalFunction L)) := by
  sorry -- THE CROWN JEWEL: combine Theorems 5, 6, and the homomorphism verification

-- THEOREM 8: Computational complexity bound
/-- The tropical Satake transform and its inverse are computable in O(n²)
on a distributive lattice with n elements.
Proof strategy: the transform requires computing the Möbius function on all
intervals [a,b], which takes O(n²) via dynamic programming on the lattice.
The inverse requires the same.
Bridge: connects computational complexity to tropical algebra.
Application: post_quantum_signature_generation O(n²) time, O(n) space. -/
theorem satake_transform_complexity_bound (L : Type*) [DistribLattice L]
    [OrderBot L] [OrderTop L] [Finite L] [TropicalHeckeAlgebra L] [DecidableEq L]
    (n : ℕ) (hcard : Finset.card Finset.univ = n) :
    ∃ (c : ℕ), c ≤ n^2 ∧ 
    ∀ (f : L → L → WithTop ℕ), 
      ComputableIn c (TropicalSatakeTransform L f).toFun := by
  sorry -- construct the algorithm and prove its complexity

-- THEOREM 9: Lipschitz bound for certified robustness
/-- The tropical Satake isomorphism has Lipschitz constant ≤ max_j |μ(⊥, j)|
where j ranges over join-irreducibles. This gives certified robustness bounds
for tropical neural network layers.
Proof strategy: the Lipschitz constant of the transform is bounded by the
maximum Möbius value, which for distributive lattices equals the number of
linear extensions of the prime ideal (Stanley's theorem).
Bridge: connects tropical ML (certified robustness) to enumerative combinatorics.
Application: lipschitz_certified_robustness_bound K ≤ max |μ(⊥,j)|. -/
theorem satake_lipschitz_bound (L : Type*) [DistribLattice L]
    [OrderBot L] [OrderTop L] [Finite L] [TropicalHeckeAlgebra L] [DecidableEq L] :
    ∃ (K : ℕ), K ≤ Finset.sup' 
      (Finset.univ.filter (fun j : L => IsJoinIrreducible j)) 
      (Finset.univ_nonempty)
      (fun j => |TropicalHeckeAlgebra.mobiusFn L ⊥ j|) ∧
    ∀ (f g : L → L → WithTop ℕ),
      dist (TropicalSatakeTransform L f).toFun 
          (TropicalSatakeTransform L g).toFun ≤ K * dist f g := by
  sorry -- use the Lipschitz property of Möbius inversion

-- THEOREM 10: Tropical information-theoretic bound
/-- The tropical Satake isomorphism preserves tropical entropy:
H_trop(T(f)) = H_trop(f) where H_trop is max-plus entropy.
This is the tropical analog of the data processing inequality.
Proof strategy: the isomorphism preserves the tropical "log-sum-exp" structure,
and tropical entropy is invariant under max-plus isomorphisms.
Bridge: connects information theory (entropy) to tropical geometry (idempotent analysis).
Application: tropical_information_capacity bound C ≤ log(n) in max-plus. -/
theorem satake_entropy_preservation (L : Type*) [DistribLattice L]
    [OrderBot L] [OrderTop L] [Finite L] [TropicalHeckeAlgebra L] [DecidableEq L]
    (f : L → L → WithTop ℕ) :
    tropicalEntropy (TropicalSatakeTransform L f).toFun = 
    tropicalEntropy f := by
  sorry -- isomorphisms preserve all algebraic invariants, including tropical entropy
```

### IV. PROOF STRATEGY ARCHITECTURE

**Strategy A (Direct — Möbius Inversion as the Key):**
1. Prove the Möbius function on a finite distributive lattice satisfies the fundamental inversion identity (Theorem 1). Use structural induction on intervals, applying Birkhoff's representation theorem to reduce to the case of Boolean lattices (where μ(a,b) = (-1)^(rank(b) - rank(a))).
2. Show the tropical Hecke algebra is commutative (Theorem 3). This follows from the distributive law: sup and inf distribute over each other, making the max-plus convolution symmetric.
3. Prove injectivity (Theorem 5) by constructing separating spherical functions from join-irreducibles.
4. Prove surjectivity (Theorem 6) by constructing the Möbius-inverse Hecke operator.
5. Verify the homomorphism property using the convolution identity.

**Strategy B (Birkhoff Duality — Reduce to Prime Spectra):**
1. Use Birkhoff's theorem (Theorem 2) to identify the Hecke algebra with functions on join-irreducibles.
2. Identify spherical functions with functions on the prime spectrum.
3. The Satake transform becomes the identity map under these identifications.
4. This is the MOST PROMISING approach because it reduces the isomorphism to a tautology under Birkhoff duality.

**Strategy C (Constructive — Build the Algorithm):**
1. Implement Möbius inversion as a computable function.
2. Prove the algorithm terminates in O(n²) steps (Theorem 8).
3. Extract the isomorphism from the algorithm's correctness proof.
4. This approach simultaneously proves the theorem AND provides the computational bound.

**RECOMMENDED: Strategy B for the main theorem, Strategy C for the computational bound, Strategy A for the supporting lemmas.**

### V. CROSS-DOMAIN BRIDGES

1. **Tropical ↔ Representation Theory**: The Satake isomorphism becomes Möbius inversion under tropicalization. This is Litvinov's dequantization principle made precise.

2. **Order Theory ↔ Cryptography**: The prime spectrum of a distributive lattice gives a natural basis for lattice-based post-quantum cryptography. The O(n²) Satake transform gives efficient key generation.

3. **Combinatorics ↔ ML**: The Lipschitz bound (Theorem 9) provides certified robustness for tropical neural networks. The Möbius function IS the Lipschitz constant.

4. **Information Theory ↔ Tropical Geometry**: Tropical entropy is preserved by the Satake isomorphism (Theorem 10), giving the tropical data processing inequality.

5. **Quantum Thermodynamics ↔ Idempotent Analysis**: The tropical Hecke algebra is the idempotent shadow of the partition function algebra. The Satake isomorphism is the idempotent fluctuation-dissipation theorem.

### VI. REQUIRED OUTPUT STRUCTURE

Produce a complete Lean 4 file `TropicalSatakeIsomorphism.lean` with:
- All 5+ definitions/structures from Section II
- All 10 theorems from Section III, fully proved (ZERO sorries)
- Diverse tactics: `induction`, `rcases`, `by_contra`, `omega`, `linarith`, `field_simp`, `exact?`, `decide`
- Doc comments with `Bridge:` and `Application:` annotations
- Computational bounds stated explicitly (O(n²), Omega(2^(n/4)))
- At least 15 additional supporting lemmas

### VII. DEMANDED FUTURE DIRECTIONS

After completing the formalization, produce a `FUTURE_DIRECTIONS.md` with 3-5 concrete breakthrough-level next steps:

1. **Tropical Langlands for GL_n**: Extend the isomorphism from distributive lattices to the Bruhat-Tits building of GL_n(Q_p), connecting tropical Satake to the geometric Langlands program.

2. **Post-Quantum Satake Key Exchange**: Implement the O(n²) Satake transform as a key exchange protocol, with security proof reducing to tropical SVP on distributive lattice spectra.

3. **Certified Robustness via Möbius Lipschitz**: Use Theorem 9 to build a certified robustness verifier for max-out neural networks, with the Möbius function as the exact Lipschitz constant.

4. **Tropical BSD Conjecture**: Formulate the Birch-Swinnerton-Dyer conjecture for tropical elliptic curves, where the L-function is replaced by the tropical zeta function and the rank is the Möbius rank.

5. **Quantum Satake via Idempotent Dequantization**: Prove that the classical Satake isomorphism is the q → ∞ limit of the tropical Satake isomorphism, making Litvinov's dequantization principle a theorem.

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
            Prove the full tropical Satake isomorphism: for a finite distributive lattice L, the tropical Satake map S: H(L) → Fun^sph(Spec(L), R_max) sending T_p ↦ (q ↦ T_p(1)(q)) is an isomorphism of max-plus algebras. The proof strategy has three pillars: (1) Injectivity — distinct Hecke operators produce distinct evaluation profiles by constructing separating functions from lattice atoms via the prime congruence spectrum; (2) Surjectivity — every spherical function arises as a Hecke evaluation, proved constructively by exhibiting the inverse S⁻¹(f) = ⊕_{p∈L} μ(0̂,p) ⊗ T_p ⊗ f(p) using the Möbius function μ of L; (3) Algebra homomorphism — S preserves the sup-algebra structure (S(T_p ⊕ T_q) = S(T_p) ⊕ S(T_q) and S(T_p ⊗ T_q) = S(T_p) ⊗ S(T_q)), extending the commutativity result heckeOp_comm to a full homomorphism. This opens the tropical Langlands program by providing the first complete representation-theoretic isomorphism in the idempotent semiring setting.

            ### Precise Mathematical Framing
            Let L be a finite distributive lattice with Möbius function μ : L × L → Z. Let H(L) = {T_p : p ∈ L} be the max-plus Hecke algebra generated by sup-convolution operators on the prime congruence spectrum Spec(L), with operations ⊕ (pointwise sup) and ⊗ (sup-convolution composition). Define the tropical Satake map S : H(L) → Fun(Spec(L), R_max) by S(T_p)(q) = T_p(1)(q). Call f : Spec(L) → R_max spherical iff f(q) = ⊕_{p : T_p(1)(q) = f(q)} T_p(1)(q). THEOREM (Tropical Satake Isomorphism): S is an isomorphism H(L) ≅ Fun^sph(Spec(L), R_max) of max-plus algebras. PROOF: (Injectivity) If T_p ≠ T_{p'}, find q ∈ Spec(L) separating them using atoms of L and the order structure of prime congruences. (Surjectivity) For spherical f, define S⁻¹(f) = ⊕_{p∈L} μ(0̂,p) ⊗ T_p ⊗ f(p); verify S(S⁻¹(f)) = f by Möbius inversion on the incidence algebra of L. (Homomorphism) S(T_p ⊕ T_q) = S(T_p) ⊕ S(T_q) by pointwise sup; S(T_p ⊗ T_q) = S(T_p) ⊗ S(T_q) by extending heckeOp_comm to the convolution product.

            ### Lean 4 Sketch
theorem tropical_satake_isomorphism (L : Type*) [DistribLattice L] [OrderBot L] [OrderTop L] [Finite L] : Nonempty (MaxPlusAlgIso (HeckeAlgebra L) (SphericalFunctions L))

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `bool_and_as_tropical_max` : theorem bool_and_as_tropical_max :
     (file: Tropical/Core/HashInversion.lean)
  2. `tropical_lattice_min_max` : theorem tropical_lattice_min_max (a b c : ℕ) :
     (file: Tropical/Core/TropicalFactoring.lean)
  3. `relu_preserves_tropical_max` : theorem relu_preserves_tropical_max (x y : ℝ) :
     (file: Tropical/Core/TropicalOracleResearch.lean)
  4. `reconstruct_from_rank2Levi_profiles_and_edge_moments` : theorem reconstruct_from_rank2Levi_profiles_and_edge_moments
     (file: Tropical/GL3_ReconstructionFromRank2LeviProfiles.lean)
  5. `finite_function_matrix_representation` : theorem finite_function_matrix_representation (n m : ℕ)
     (file: Tropical/QuantumLLMCompilation.lean)

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

Research domain: Tropical
Research mode: formalize
