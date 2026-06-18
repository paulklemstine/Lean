

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

## YOUR ASSIGNMENT: Connes-Kreimer Hopf Algebra of Rooted Trees — Graded Coproduct via Admissible Cuts, Recursive Antipode, and Birkhoff Decomposition of Renormalization Characters

### I. FORMALIZATION TARGET: The Complete Hopf Algebra Structure on Rooted Trees with QFT Renormalization Applications

The Connes-Kreimer Hopf algebra is the algebraic engine of perturbative renormalization in quantum field theory. Every Feynman diagram maps to a rooted tree, and the Bogoliubov R-operation is precisely the Birkhoff decomposition of characters. This formalization establishes the certified computational pipeline from combinatorial Hopf algebra theory to renormalized scattering amplitudes.

**Bridge: connects algebraic combinatorics (Hopf algebras on rooted trees) to quantum field theory (Bogoliubov R-operation renormalization) to certified machine learning (forest-structured neural network regularizers).**

---

### II. CORE DEFINITIONS (5+ required, with precise Lean 4 signatures)

```lean
-- A rooted tree is a finite tree with a distinguished root vertex.
-- We represent it as a well-founded inductive type.
inductive RootedTree where
  | stump : RootedTree                    -- single node (the root)
  | graft (root_children : Finset RootedTree) : RootedTree
  deriving DecidableEq

-- The graded component: trees with exactly n nodes have degree n.
def RootedTree.degree : RootedTree → ℕ
  | stump => 1
  | graft children => 1 + Finset.sum children (fun t => t.degree)

-- An admissible cut on a rooted tree is a subset of edges such that
-- at most one edge on any root-to-leaf path is cut.
-- Equivalently: the set of cut nodes forms an antichain in the tree order.
structure AdmissibleCut (T : RootedTree) where
  cut_nodes : Finset {n : T.nodes // n ≠ T.root}
  is_antichain : ∀ n₁ ∈ cut_nodes, ∀ n₂ ∈ cut_nodes,
    n₁ ≠ n₂ → ¬(IsAncestor n₁ n₂ ∨ IsAncestor n₂ n₁)

-- The pruning of an admissible cut: the forest of subtrees above the cut.
def AdmissibleCut.pruning {T : RootedTree} (c : AdmissibleCut T) : Multiset RootedTree := ...

-- The trunk of an admissible cut: the remaining tree below the cut.
def AdmissibleCut.trunk {T : RootedTree} (c : AdmissibleCut T) : RootedTree := ...

-- The Connes-Kreimer coproduct: Δ(T) = Σ_{c admissible} P_c(T) ⊗ R_c(T)
-- where the sum includes the trivial cut (empty cut, giving 1 ⊗ T) and
-- the full cut (all leaves, giving T ⊗ 1).
def connesKreimerCoproduct {k : Type*} [CommRing k] :
    H_CK k →ₐ[k] k ⊗[k] H_CK k := ...

-- The reduced coproduct: Δ'(x) = Δ(x) - x⊗1 - 1⊗x + ε(x)·1⊗1
def reducedCoproduct {k : Type*} [CommRing k] (x : H_CK k) : H_CK k ⊗[k] H_CK k := ...

-- Rota-Baxter algebra: the algebraic structure enabling Birkhoff decomposition.
-- A Rota-Baxter operator R satisfies R(x)R(y) = R(xR(y) + R(x)y) with weight λ.
class RotaBaxterAlgebra (A : Type*) (λ : k) [Ring A] [Algebra k A] where
  r : A → A  -- Rota-Baxter operator
  rbt_axiom : ∀ x y, r x * r y = r (x * r y + r x * y + λ * x * y)

-- A character of the Connes-Kreimer algebra into a Rota-Baxter algebra
-- (this models a regularized Feynman rule in QFT).
structure RenormalizationCharacter (k A : Type*) [CommRing k] [Ring A] 
    [Algebra k A] [RotaBaxterAlgebra A λ] extends H_CK k →ₐ[k] A where
  -- The character preserves the multiplicative structure (Feynman rules are multiplicative)

-- The Bogoliubov preparation map B_φ = (φ₋ ⊗ φ) ∘ Δ'
-- This is the core operation of perturbative renormalization.
def bogoliubovPreparation {k A : Type*} [CommRing k] [Ring A] 
    [Algebra k A] [RotaBaxterAlgebra A λ] 
    (φ₋ : H_CK k →ₐ[k] A) (φ : H_CK k →ₐ[k] A) :
    H_CK k → A := fun x => (Algebra.lmul k A) ((φ₋.toAlgHom ⊗ₐ[k] φ.toAlgHom) (reducedCoproduct x))
```

---

### III. MAIN THEOREMS (10+ required, with diverse proof tactics)

```lean
-- THEOREM 1: Coassociativity of the Connes-Kreimer coproduct
-- This is the foundational structural result. The proof goes through
-- the combinatorial fact that pairs of admissible cuts compose.
theorem connesKreimer_coproduct_coassociative {k : Type*} [Field k] (T : RootedTree) :
    (TensorProduct.map connesKreimerCoproduct (LinearMap.id k (H_CK k))) 
      (connesKreimerCoproduct T) = 
    (TensorProduct.map (LinearMap.id k (H_CK k)) connesKreimerCoproduct) 
      (connesKreimerCoproduct T) := by
  -- Strategy: Induction on tree structure. Key lemma: admissible cuts on T
  -- correspond to antichains, and composing two successive antichain selections
  -- is symmetric (associative) because the middle layer can be split either way.
  -- More precisely: a pair (c₁, c₂) of admissible cuts on T where c₂ refines c₁
  -- corresponds bijectively to a triple partition of T into three forests.
  sorry

-- THEOREM 2: Admissible cuts form a lattice under refinement
-- This is the key combinatorial lemma that makes coassociativity work.
theorem admissibleCut_refinement_lattice (T : RootedTree) :
    IsLattice (AdmissibleCut T) where
  -- The join of two cuts c₁ ∨ c₂ is the antichain generated by taking all
  -- nodes in c₁ ∪ c₂ and removing any that are ancestors of others.
  -- The meet c₁ ∧ c₂ is the maximal common refinement.
  sorry

-- THEOREM 3: Antichain composition bijection (KEY LEMMA)
-- This is the combinatorial heart of coassociativity.
theorem antichain_composition_bijection (T : RootedTree) :
    ∃ (f : (Σ c₁ : AdmissibleCut T, {c₂ : AdmissibleCut (c₁.trunk) // True}) → 
         (Σ c₁ : AdmissibleCut T, {c₂ : AdmissibleCut (c₁.pruning) // True})),
      Bijective f := by
  -- Strategy: The bijection sends (c₁, c₂) where c₂ refines c₁ to (c₁', c₂')
  -- where c₁' is the cut consisting of nodes in c₂, and c₂' consists of nodes
  -- from c₁ that are above c₁'. This uses the tree structure crucially.
  -- Use classical logic and construct the inverse explicitly.
  sorry

-- THEOREM 4: Recursive antipode formula (Bogoliubov's formula)
-- S(x) = -x - Σ_{(x')} S(x'₁) · x'₂ where Δ'(x) = Σ x'₁ ⊗ x'₂
theorem antipode_recursive_formula {k : Type*} [Field k] (x : H_CK k) (h : x ≠ 1) :
    antipode x = -x - Finset.sum (reducedCoproduct x).support 
      (fun p => antipode p.1 * p.2) := by
  -- Strategy: Induction on the degree of x. The antipode S satisfies
  -- S * id = ε (the counit), so m ∘ (S ⊗ id) ∘ Δ = η ∘ ε.
  -- Unfolding Δ(x) = Σ P_c ⊗ R_c + x ⊗ 1 + 1 ⊗ x (for non-trivial x),
  -- and applying the induction hypothesis to P_c (which has lower degree),
  -- the result follows by algebraic manipulation.
  sorry

-- THEOREM 5: Antipode is an algebra anti-homomorphism
theorem antipode_anti_hom {k : Type*} [Field k] (x y : H_CK k) :
    antipode (x * y) = antipode y * antipode x := by
  -- Strategy: Use the fact that S is the convolution inverse of id in
  -- End(H_CK). The anti-homomorphism property follows from:
  -- S(x·y) = S(m(x⊗y)) = S ∘ m (x⊗y) = m^{op} ∘ (S⊗S)(x⊗y)
  -- This requires the Hopf algebra axiom that m is a coalgebra morphism.
  sorry

-- THEOREM 6: Graded structure — the coproduct respects the degree grading
theorem coproduct_respects_grading {k : Type*} [Field k] (n : ℕ) (x : (H_CK_graded k n)) :
    ∀ (a b : H_CK k), (a ⊗ b) ∈ connesKreimerCoproduct x.support → 
      a.degree + b.degree = n := by
  -- Strategy: Each admissible cut on a tree of degree n produces a pruning
  -- (forest) and trunk (tree) whose total node count equals n.
  sorry

-- THEOREM 7: Bogoliubov preparation satisfies recursive identity
-- This is the computational engine of renormalization.
theorem bogoliubov_recursive {k A : Type*} [Field k] [CommRing A] 
    [Algebra k A] [RotaBaxterAlgebra A λ]
    (φ : RenormalizationCharacter k A λ) (T : RootedTree) (hT : T ≠ RootedTree.stump) :
    bogoliubovPreparation φ₋ φ T = φ₋ T + R(φ₊(bogoliubovPreparation φ₋ φ' T)) := by
  -- Strategy: Unfold the Bogoliubov map and use the Rota-Baxter identity.
  -- The recursion is the algebraic shadow of the Zimmermann forest formula.
  sorry

-- THEOREM 8: Birkhoff decomposition exists and is unique
-- THE MAIN RESULT: Every character φ into a Rota-Baxter algebra decomposes uniquely
-- as φ = φ₋ * φ₊ where φ₋ is group-like (takes values in R(A)) and 
-- φ₊ is an algebra homomorphism.
theorem birkhoff_decomposition_unique {k A : Type*} [Field k] [CommRing A]
    [Algebra k A] [RotaBaxterAlgebra A λ]
    (φ : H_CK k →ₐ[k] A) :
    ∃! (φ₋ φ₊ : H_CK k →ₐ[k] A), 
      φ = φ₋ * φ₊ ∧ 
      (∀ T, φ₋ T ∈ Set.range (RotaBaxterAlgebra.r A λ)) ∧  -- φ₋ is R-valued
      (∀ x y, φ₊ (x * y) = φ₊ x * φ₊ y) := by
  -- Strategy: Construct φ₋ and φ₊ by induction on the degree grading.
  -- For degree 0 (scalars): φ₋(1) = 1, φ₊(1) = 1.
  -- For degree n (assuming defined for < n):
  --   φ₋(T) = -R(φ₊(B_φ(T)))  (Bogoliubov formula)
  --   φ₊(T) = R̃(φ₊(B_φ(T))) + ε(T)  (where R̃ = id - R)
  -- Uniqueness follows from the Rota-Baxter algebra being a direct sum decomposition.
  -- Key lemma: Rota-Baxter identity ensures φ₋ * φ₊ = φ on all graded components.
  sorry

-- THEOREM 9: The antipode counts forests with signs (combinatorial interpretation)
theorem antipode_forest_sign_formula {k : Type*} [Field k] (T : RootedTree) :
    antipode T = Finset.sum (allCuts T) 
      (fun c => (-1)^(c.numCutEdges + 1) * (c.pruning : H_CK k)) := by
  -- Strategy: Induction on T, using the recursive antipode formula.
  -- Each admissible cut contributes a signed monomial.
  -- The sign is (-1)^(#cut edges + 1) by the recursive formula.
  sorry

-- THEOREM 10: Computational complexity of coproduct — explicit bound
-- The number of admissible cuts on a tree with n nodes is at most the
-- nth Catalan number C_n = (2n)! / ((n+1)! · n!), giving O(4^n / n^{3/2}).
theorem coproduct_complexity_bound (T : RootedTree) (n : ℕ) (hn : T.degree = n) :
    (connesKreimerCoproduct T).support.card ≤ (2*n)! / ((n+1)! * n!) := by
  -- Strategy: Admissible cuts correspond to antichains in the tree.
  -- The maximum number of antichains in any rooted tree with n nodes is C_n.
  -- This follows from the correspondence with Dyck paths.
  -- Use the Catalan number formula and the fact that the tree order
  -- refines the chain order.
  sorry

-- THEOREM 11: Renormalization group equation (physics connection)
-- The counterterm character φ₋ satisfies a multiplicative renormalization group equation.
theorem renormalization_group_equation {k : Type*} [Field k] 
    (φ : H_CK k →ₐ[k] k[[ε]]) (μ : k) :
    letI φ₋ := (birkhoff_decomposition φ).1
    φ₋ (scaleAction μ T) = φ₋ T * (1 + μ * ε + O(ε²)) := by
  -- Strategy: The scale action on trees corresponds to rescaling the 
  -- regularization parameter. The RG equation follows from the 
  -- multiplicativity of φ₋ and the Birkhoff decomposition.
  sorry

-- THEOREM 12: Certified Lipschitz bound for renormalized amplitudes (ML connection)
-- Bridge: connects QFT renormalization to certified robustness in neural networks.
theorem renormalized_lipschitz_bound {k : Type*} [Field k] [IsROrC k]
    (φ : H_CK k →ₐ[k] k) (L : ℕ) (hL : L > 0) :
    ∃ (C : ℝ), C = 2^(2*L) * L! ∧
    ∀ (T : RootedTree) (hT : T.degree ≤ L),
      ‖birkhoff_decomposition φ |>.1 T‖ ≤ C * ‖φ T‖ := by
  -- Strategy: The Birkhoff decomposition is built inductively on degree.
  -- At each level, the Rota-Baxter operator introduces a factor of 2
  -- (from the splitting R + R̃ = id). The factorial comes from the
  -- number of terms in the reduced coproduct (bounded by C_n).
  -- This gives a certified Lipschitz constant for renormalized Feynman rules,
  -- directly applicable to certified_robustness bounds in forest-structured ML models.
  sorry
```

---

### IV. PROOF STRATEGIES (Multiple paths for each major theorem)

**Strategy for Coassociativity (Theorem 1):**

*Path A (Direct Combinatorial — RECOMMENDED):* Establish the antichain composition bijection (Theorem 3). This reduces coassociativity to a combinatorial fact: selecting two successive antichains from a tree is the same as selecting an antichain and then selecting sub-antichains from the resulting forest. The bijection is constructed explicitly by splitting nodes into three categories: above both cuts, between the cuts, and below both cuts.

*Path B (Inductive on Tree Structure):* Prove coassociativity for `stump` (trivial: Δ(•) = •⊗•), then for `graft(children)` by expanding the coproduct formula and using the inductive hypothesis on each child. This requires a messy but mechanical calculation with `Finset.sum` manipulations.

*Path C (Universal Property):* Show that H_CK satisfies the universal property of the free commutative Hopf algebra on the comonoid of rooted trees, then deduce coassociativity from the universal property. This is elegant but requires building significant infrastructure first.

**Strategy for Birkhoff Decomposition (Theorem 8):**

*Path A (Inductive on Grading — RECOMMENDED):* Define φ₋ and φ₊ by strong induction on degree. At degree n, use the Bogoliubov preparation map with the already-defined lower-degree parts. The Rota-Baxter identity ensures the construction is well-defined and unique. Prove multiplicativity of φ₊ by induction, using the fact that the product of trees of degree < n has degree < n only if both factors have degree < n.

*Path B (Contraction Mapping):* View the Birkhoff decomposition as a fixed point of a contraction on the space of characters (equipped with the degree filtration topology). Use Banach's fixed point theorem in the graded completion. This is more abstract but gives a cleaner existence proof.

*Path C (Algebraic Birkhoff — Foissy's approach):* Use the fact that the group of characters G(A) is a pro-unipotent group, and the Rota-Baxter splitting gives a decomposition G(A) = G₋(A) · G₊(A) where G₋ = exp(A₋) and G₊ = exp(A₊). This requires developing the Lie algebra of primitive elements first.

**Key Lemma for All Paths:**
```lean
-- The Rota-Baxter splitting lemma: any element decomposes uniquely
theorem rota_baxter_splitting {A : Type*} [CommRing A] [RotaBaxterAlgebra A λ] 
    (x : A) : ∃! (x₋ x₊ : A), x = x₋ + x₊ ∧ x₋ ∈ Set.range r ∧ x₊ ∈ Set.range (id - r) := by
  -- Use x₋ = r(x), x₊ = x - r(x). Uniqueness follows from r(A) ∩ (id-r)(A) = {0}
  -- when λ ≠ 0 (which we assume for renormalization).
  sorry
```

---

### V. SIGNIFICANCE AND APPLICATIONS

**Quantum Field Theory (Physics):** The Connes-Kreimer Hopf algebra is the mathematical framework underlying dimensional regularization and the Bogoliubov R-operation. The Birkhoff decomposition of characters IS the renormalization procedure: φ₋ gives the counterterms and φ₊ gives the renormalized Feynman rules. Our formalization provides the first certified computational pipeline for renormalization, with explicit Lipschitz bounds on renormalized amplitudes (Theorem 12).

**Post-Quantum Cryptography (Cryptography):** The graded Hopf algebra structure on rooted trees naturally connects to lattice-based cryptography through the following: the coproduct on trees defines a convolution product on the character group, and the computational hardness of inverting the antipode (which has exponential complexity O(4^n/n^{3/2}) by Theorem 10) provides a candidate one-way function for post-quantum key exchange. The certified complexity bounds enable `post_quantum_security_parameter` analysis.

**Certified Robustness in ML (Machine Learning):** Forest-structured neural networks (ensembles of decision trees) have a natural Hopf algebra structure. The Birkhoff decomposition provides a certified regularization scheme: the φ₋ component acts as an adversarial defense (absorbing divergent perturbations) while φ₊ preserves the learned function. The Lipschitz bound from Theorem 12 directly translates to `certified_adversarial_robustness` guarantees for tree ensemble models, with the explicit constant C = 2^(2L) · L! providing a `lipschitz_certified_bound`.

---

### VI. FUTURE DIRECTIONS

You MUST produce a structured FUTURE_DIRECTIONS.md with these concrete next steps:

1. **Tropical Renormalization:** Define the tropical (min-plus) shadow of the Connes-Kreimer algebra and prove that the Birkhoff decomposition descends to a tropical Birkhoff decomposition with piecewise-linear counterterms. This connects `tropical_hash_collision` bounds to renormalization group flow.

2. **Motivic Galois Group:** Formalize the motivic Galois group of Connes-Marcoli acting on the Hopf algebra and prove that the Birkhoff decomposition is equivariant under this action. This would establish `quantum_field_certified_invariants` for renormalization schemes.

3. **Non-commutative Version (Planar Trees):** Extend the formalization to the non-commutative Connes-Kreimer algebra on planar rooted trees, prove coassociativity and Birkhoff decomposition in this setting, and establish the connection to `post_quantum_lattice_hardness` via the non-commutative hidden subgroup problem.

4. **Computational Renormalization Algorithm:** Extract a certified algorithm from the Birkhoff decomposition proof that computes φ₋ and φ₊ in O(C_n · n²) time for trees of degree n, with `certified_runtime_bound` verified in Lean. Target: renormalize all 1PI diagrams of φ⁴ theory through 3 loops.

5. **Quantum Hopf Algebra Deformation:** Deform H_CK by a parameter q to obtain H_CK^q, prove that coassociativity survives the deformation (giving a quasi-Hopf algebra for q a root of unity), and establish the `quantum_renormalization_correspondence` between the deformed and undeformed Birkhoff decompositions.

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
            Open the field of algebraic renormalization theory by proving three foundational theorems establishing the Hopf-algebraic foundations of perturbative renormalization in quantum field theory: (1) Connes-Kreimer Structure Theorem: rooted forests over a field k carry a connected graded commutative Hopf algebra structure H_CK where the coproduct Δ(T) = Σ_{c admissible} P_c(T) ⊗ R_c(T) is given by admissible cuts on trees, the counit vanishes on positive-degree elements, and the antipode satisfies the recursive formula S(x) = -x - Σ S(x')x'' via the reduced coproduct, making H_CK the free commutative Hopf algebra on rooted trees; (2) Birkhoff Decomposition Theorem: every algebra homomorphism φ: H_CK → A into a Rota-Baxter algebra (A, R, λ) has a unique factorization φ = φ₋ ⋆ φ₊ into a divergent part φ₋ and a renormalized part φ₊, given explicitly by the Atkinson recursion φ₋(x) = -R(φ₋ ⊗ φ)(Δ'(x)) and φ₊(x) = φ(x) + R⁻¹(φ₊ ⊗ φ₋)(Δ'(x)); (3) Universal Property: H_CK is the initial object in the category of connected graded Hopf algebras admitting Birkhoff decomposition, establishing that combinatorial renormalization is intrinsically Hopf-algebraic. This would be the first formalization of the Connes-Kreimer Hopf algebra in any proof assistant, opening algebraic renormalization theory for formal mathematics and creating a revolutionary bridge between Algebra and Physics.

            ### Precise Mathematical Framing
            The Connes-Kreimer Hopf algebra H_CK is the polynomial ring k[T] where T ranges over isomorphism classes of rooted trees, graded by vertex count |T|. Multiplication is disjoint union of forests. The coproduct Δ: H_CK → H_CK ⊗_k H_CK is defined on trees by Δ(T) = Σ_{c ∈ AdmCuts(T)} P_c(T) ⊗ R_c(T) where P_c(T) is the forest of pruned branches and R_c(T) is the remaining trunk, extended as an algebra homomorphism. The key structural theorems are: (i) Coassociativity (Δ ⊗ id)∘Δ = (id ⊗ Δ)∘Δ proven by unique decomposition of nested admissible cuts; (ii) Antipode existence via well-founded recursion on the grading: S(1)=1, S(T) = -T - Σ S(P_c(T))·R_c(T) over proper admissible cuts; (iii) Birkhoff decomposition φ = φ₋ ⋆ φ₊ unique in the character group G(A), proven by the Atkinson formula using the Rota-Baxter identity R(x)R(y) = R(R(x)y + xR(y) - λxy). The universal property follows from the freeness of H_CK as a commutative algebra on rooted trees.

            ### Lean 4 Sketch
theorem connes_kreimer_coproduct_coassociative {k : Type*} [Field k] (T : RootedTree) : (TensorProduct.map coproduct id) (coproduct T) = (TensorProduct.map id coproduct) (coproduct T) := ... 
theorem antipode_recursive {k : Type*} [Field k] (x : H_CK k) (h : x ≠ 1) : antipode x = -x - Finset.sum (reducedCoproduct x) (fun p => antipode p.1 * p.2) := ... 
theorem birkhoff_decomposition_unique {k : Type*} [Field k] {A : Type*} [CommRing A] [RotaBaxterAlgebra A λ] (φ : H_CK k →ₐ[k] A) : ∃! (φ₋ φ₊ : H_CK k →ₐ[k] A), φ = convProduct φ₋ φ₊ ∧ IsGroupLike φ₋ ∧ IsAlgebraHom φ₊ := ...

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `fundamental_theorem_algebraic_light'` : theorem fundamental_theorem_algebraic_light' (a b c : ℤ) :
     (file: Algebra/Other/UnifyingTheory.lean)
  2. `semiprime_unique_factorization` : theorem semiprime_unique_factorization (p q p' q' : ℕ)
     (file: Algebra/Core/ChimeraFactoring.lean)
  3. `any_semiring_reduced_basis_exists` : theorem any_semiring_reduced_basis_exists {A : Type*} [Semiring A]
     (file: Algebra/EMLCongruenceHilbert.lean)
  4. `fg_congruence_has_reduced_basis` : theorem fg_congruence_has_reduced_basis
     (file: Algebra/IdempotentCongruenceBasis.lean)
  5. `no_three_squares_for_7` : theorem no_three_squares_for_7 :
     (file: Algebra/IntegerEnergy/MetaOracleNextSteps.lean)

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



Recent successful concepts: Tropical Central Limit Theorem: Gumbel Attraction, Max-Plus Stein Method, and Berry-Esseen Convergence Bounds, Tropical Quantum Mechanics: Maslov Dequantization, Tropical Born Rule, Max-Plus Unitary Collapse, and Entanglement Detection, Tropical Riesz–Markov–Kakutani Representation: Max-Plus Functional–Measure Duality on Compact Hausdorff Spaces


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
Research mode: formalize
