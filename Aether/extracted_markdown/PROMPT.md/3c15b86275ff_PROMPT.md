

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

## YOUR ASSIGNMENT: Hopf-Algebraic Causal Calculus: Birkhoff–Pearl Decomposition, Forest-Formula Intervention Identification, and Antipodal Counterfactual Adjustment

**DOMAIN**: Bridges (Quantum Field Theory ↔ Causal Inference ↔ Algebraic Combinatorics)

**CONCEPT**: Open the field of Hopf-algebraic causal calculus by proving three foundational theorems that establish a structural isomorphism between Connes-Kreimer renormalization and Pearl's do-calculus. The coproduct of the Connes-Kreimer Hopf algebra H_CK decomposes rooted trees into "pruned" (direct effect) and "remaining" (indirect/confounding) components—exactly mirroring Pearl's separation of causal paths into direct and backdoor-adjusted contributions. The antipode S computes counterfactual adjustments by recursively subtracting all confounded subpaths. The Birkhoff decomposition φ = φ₋ ⋆ φ₊ over a Rota-Baxter algebra of weight λ = −1 separates the character into a counterterm φ₋ (confounding/backdoor component) and a renormalized character φ₊ (interventional distribution P(Y|do(X))). This reveals that renormalization and causal inference share the same algebraic DNA: the coproduct splits effects, the antipode computes counterfactuals, and Birkhoff decomposition isolates unconfounded causal effects.

---

### PRECISE FORMALIZATION TARGETS

#### Structure Definitions (5+ required)

```lean
/-- A causal DAG: a finite directed acyclic graph with a distinguished
    intervention node and outcome node. Bridge: connects quantum field theory
    renormalization graphs to Pearl's causal DAGs. -/
structure CausalDAG where
  verts : Finset ℕ
  edges : Finset (ℕ × ℕ)
  intervention : ℕ   -- X: the do-node
  outcome : ℕ       -- Y: the effect node
  acyclic : ∀ p : List ℕ, IsPath edges p → p.Head? = p.Get? (p.length - 1) → p.length ≤ 1
  intervention_mem : intervention ∈ verts
  outcome_mem : outcome ∈ verts

/-- A causal character: a multiplicative functional on rooted trees
    encoding the joint distribution of a causal model.
    Maps each tree t to the path-amplitude φ(t) in the target algebra A. -/
structure CausalCharacter (A : Type*) [CommSemiring A] where
  toFun : RTree → A
  mul_preserve : ∀ t₁ t₂ : RTree, toFun (RTree.mul t₁ t₂) = toFun t₁ * toFun t₂
  unit_preserve : toFun RTree.one = 1

/-- Rota-Baxter algebra of weight λ = -1: the algebraic structure
    guaranteeing unique Birkhoff decomposition. Bridge: connects
    Connes-Kreimer renormalization to backdoor adjustment in causal inference. -/
class RotaBaxterAlgebra (A : Type*) [CommRing A] where
  rbo : A → A  -- Rota-Baxter operator
  weight : ℤ
  weight_eq : weight = -1
  rbo_id : ∀ a : A, rbo a * rbo b = rbo (rbo a * b + a * rbo b + weight • (a * b))

/-- The Birkhoff–Pearl decomposition of a causal character into
    confounded (counterterm) and interventional (renormalized) parts. -/
structure BirkhoffPearlDecomposition (A : Type*) [CommRing A] [RotaBaxterAlgebra A] where
  character : CausalCharacter A
  counterterm : CausalCharacter A   -- φ₋: confounding/backdoor component
  interventional : CausalCharacter A -- φ₊: P(Y|do(X)), the unconfounded effect
  convolution_eq : ∀ t : RTree,
    character.toFun t = Convolution A counterterm.toFun interventional.toFun t

/-- An adjustment set derived from the antipode forest formula:
    enumerates valid backdoor adjustment sets with explicit complexity bound. -/
structure ForestFormulaAdjustment where
  target : CausalDAG
  adjustmentSet : Finset ℕ
  is_valid : SatisfiesBackdoorCriterion target adjustmentSet
  complexity_bound : adjustmentSet.card ≤ target.verts.card * maxInDegree target * maxHeight target
```

#### Main Theorems (10+ required, diverse tactics)

**THEOREM 1: Hopf-Algebraic d-Separation (counit-vanishing criterion)**

```lean
/-- Bridge: connects graphical d-separation (causal inference) to
    counit-restricted convolution vanishing (Hopf algebra renormalization).
    Variables X and Y are d-separated by Z in DAG G iff every rooted tree
    encoding an active path through Z has vanishing counit-restricted convolution.
    Impact: certified_causal_independence for quantum field-theoretic models. -/
theorem hopf_d_separation_vanishing
    (G : CausalDAG) (X Y : ℕ) (Z : Finset ℕ)
    (φ : CausalCharacter ℤ)
    (hX : X ∈ G.verts) (hY : Y ∈ G.verts) (hZ : ∀ z ∈ Z, z ∈ G.verts) :
    dSeparated G X Y Z ↔
      ∀ t : RTree,
        EncodesActivePath G t X Y Z →
          (counitRestrictedConvolution φ.toFun t : ℤ) = 0 := by
  -- Strategy A (primary): Induction on tree height.
  --   Base: single-edge tree t = edge(X,Y). d-separated means no direct edge,
  --   so t doesn't exist in the encoding, vacuously true.
  --   Step: For tree t with root X and subtrees encoding paths through Z,
  --   use coproduct decomposition: Δ(t) = Σ P_c(t)⊗R_c(t).
  --   The counit ε kills the R_c(t) factor when the cut c passes through Z,
  --   making (η∘ε) restricted to the Z-component vanish.
  --   The converse: if not d-separated, construct an active path tree t*
  --   with (η∘ε)(t*) ≠ 0 by choosing the unique admissible cut at the
  --   collider in Z.
  -- Strategy B: contrapositive with by_contra.
  --   Assume ¬dSeparated, witness an active path, build tree, show convolution ≠ 0.
  sorry
```

**THEOREM 2: Birkhoff–Pearl Correspondence (counterterm = confounding)**

```lean
/-- Bridge: connects Connes-Kreimer Birkhoff decomposition (QFT renormalization)
    to Pearl's backdoor adjustment (causal inference). The counterterm φ₋(t)
    equals the sum over admissible cuts of (-1)^|c| · φ(R_c(t)) · φ(P_c(t)),
    which is precisely the confounding contribution removed by backdoor adjustment.
    Impact: quantum_renormalized_causal_effect with certified_bounds. -/
theorem birkhoff_pearl_counterterm_is_confounding
    (A : Type*) [CommRing A] [RotaBaxterAlgebra A]
    (φ : CausalCharacter A)
    (decomp : BirkhoffPearlDecomposition A)
    (t : RTree) :
    decomp.counterterm.toFun t =
      ∑ c in RTree.admCuts t,
        ((-1 : A) ^ (AdmCut.card c)) *
        φ.toFun (AdmCut.remaining c) *
        φ.toFun (AdmCut.pruned c) := by
  -- Proof by induction on tree structure using the recursive Birkhoff formula.
  -- Key lemma: for Rota-Baxter weight -1, the Birkhoff counterterm satisfies
  --   φ₋ = -R(φ₋ ⋆ φ ∘ π) where π is the projection onto proper subtrees.
  -- Unfold this recursion, noting that each admissible cut contributes exactly
  -- one term with sign (-1)^|c| from the alternating sum in the antipode.
  -- Use field_simp and ring for the algebraic manipulations.
  sorry
```

**THEOREM 3: Interventional Distribution Recovery (φ₊ = P(Y|do(X)))**

```lean
/-- Bridge: connects renormalized character (QFT) to interventional distribution
    (causal inference). The positive part φ₊ of the Birkhoff decomposition,
    evaluated on the tree t_{X→Y} encoding the causal path from X to Y,
    recovers Pearl's interventional distribution P(Y|do(X)).
    Impact: certified_interventional_distribution for post_quantum_causal_security. -/
theorem interventional_recovery_via_birkhoff_positive
    (A : Type*) [CommRing A] [RotaBaxterAlgebra A]
    (G : CausalDAG) (φ : CausalCharacter A)
    (decomp : BirkhoffPearlDecomposition A)
    (t_XY : RTree) (h_enc : EncodesCausalPath G t_XY G.intervention G.outcome) :
    decomp.interventional.toFun t_XY = interventionalDistribution A G φ G.intervention G.outcome := by
  -- Proof strategy: unfold interventionalDistribution as the do-operator,
  --   which removes incoming edges to X and marginalizes confounders.
  --   Show this equals φ₊(t) by proving that φ₋ ⋆ φ₊ = φ and that
  --   φ₋ absorbs exactly the confounding terms (incoming edges to X).
  --   Use the convolution identity and the fact that R(φ₋) = -φ₋ for weight -1.
  sorry
```

**THEOREM 4: Forest-Formula Adjustment Enumeration (complexity bound)**

```lean
/-- Bridge: connects Zimmermann forest formula (QFT renormalization) to
    backdoor adjustment set enumeration (causal inference).
    The antipode S(t) = -t - Σ_{c proper} S(P_c(t))·R_c(t) recursively
    generates all valid adjustment sets in O(|V|·d_max·h_max) time.
    Impact: lattice_adjustment_enumeration for cryptographic causal protocols. -/
theorem forest_formula_adjustment_complexity
    (G : CausalDAG)
    (h_nontrivial : 2 ≤ G.verts.card) :
    ∃ f : Finset (Finset ℕ),
      (∀ s ∈ f, SatisfiesBackdoorCriterion G s) ∧
      f.card ≤ G.verts.card * maxInDegree G * maxHeight G ∧
      ∀ s : Finset ℕ, SatisfiesBackdoorCriterion G s → s ∈ f := by
  -- Construct f from the antipode recursion on the tree encoding of G.
  -- Each proper admissible cut yields one adjustment candidate.
  -- Bound: |admCuts(t)| ≤ |V|·d_max·h_max by RTree.admCutCount from catalog.
  -- Use omega for the arithmetic bound and rcases for cut enumeration.
  sorry
```

**THEOREM 5: Antipode-Counterfactual Correspondence**

```lean
/-- Bridge: connects Hopf algebra antipode (algebraic renormalization) to
    counterfactual reasoning (causal inference). The antipode S(t) computes
    the counterfactual adjustment: it recursively subtracts all confounded
    subpaths, yielding the net causal effect after removing confounding.
    Impact: certified_counterfactual_bound for quantum_causal_inference. -/
theorem antipode_counterfactual_adjustment
    (A : Type*) [CommRing A]
    (G : CausalDAG) (φ : CausalCharacter A)
    (t : RTree) (h_enc : EncodesCausalPath G t G.intervention G.outcome) :
    antipodeCoeff t * φ.toFun t =
      φ.toFun t - ∑ c in RTree.properAdmCuts t,
        antipodeCoeff (AdmCut.pruned c) * φ.toFun (AdmCut.pruned c) * φ.toFun (AdmCut.remaining c) := by
  -- Induction on tree height using the recursive antipode formula.
  -- Base: t is a single vertex, S(t) = -t, antipodeCoeff = -1.
  -- Step: S(t) = -t - Σ S(P_c(t))·R_c(t), distribute φ over the sum.
  -- Key: antipodeCoeff from catalog gives the signed coefficient.
  -- Use linarith for the final algebraic rearrangement.
  sorry
```

**THEOREM 6: Rota-Baxter Uniqueness of Birkhoff–Pearl Decomposition**

```lean
/-- The Birkhoff–Pearl decomposition is unique for Rota-Baxter weight -1.
    This guarantees that the separation into confounding/interventional
    parts is canonical—no other decomposition yields a valid causal interpretation.
    Impact: cryptographic_uniqueness for post_quantum_causal_commitment. -/
theorem birkhoff_pearl_uniqueness
    (A : Type*) [CommRing A] [RotaBaxterAlgebra A]
    (φ : CausalCharacter A)
    (d₁ d₂ : BirkhoffPearlDecomposition A)
    (h_char : d₁.character = d₂.character) :
    d₁.counterterm = d₂.counterterm ∧ d₁.interventional = d₂.interventional := by
  -- Strategy: Assume two decompositions φ = φ₋₁⋆φ₊₁ = φ₋₂⋆φ₊₂.
  --   By the Rota-Baxter identity with weight -1:
  --   φ₋₁ = -R(φ₋₁⋆φ∘π₁) and similarly for φ₋₂.
  --   Induction on the grading (tree size) shows φ₋₁ = φ₋₂ at each grade.
  --   Then φ₊₁ = φ₊₂ follows from invertibility of φ₋ in the convolution algebra.
  --   Use by_contra for the uniqueness argument and field_simp for algebraic steps.
  sorry
```

**THEOREM 7: Graded Coalgebra Structure of Causal Paths**

```lean
/-- Bridge: connects graded coalgebra structure (algebraic combinatorics) to
    causal path stratification (causal inference). The Connes-Kreimer coalgebra
    graded by tree size restricts to a subcoalgebra of "causally valid" trees.
    Impact: graded_causal_complexity for certified_robustness_bounds. -/
theorem causal_path_subcoalgebra
    (G : CausalDAG) (φ : CausalCharacter ℤ) :
    ∃ (C : Subcoalgebra (ConnesKreimerCoalgebra)),
      (∀ t : RTree, t ∈ C.carrier → EncodesCausalPath G t G.intervention G.outcome ∨ t = RTree.one) ∧
      C.carrier = {t | EncodesCausalPath G t G.intervention G.outcome} ∪ {RTree.one} := by
  -- Construct C explicitly. Show it's closed under coproduct:
  --   if t encodes a causal path, then Δ(t) = Σ P_c(t)⊗R_c(t)
  --   where each P_c(t) and R_c(t) also encode causal subpaths or are trivial.
  --   Use rcases on admissible cuts and the tree structure of causal paths.
  sorry
```

**THEOREM 8: Triple Splitting for Confounded Effects**

```lean
/-- Bridge: connects TripleSplitting (algebraic combinatorics, from catalog) to
    the three-way decomposition of causal effects into direct, indirect, and
    confounded contributions. Impact: triple_causal_decomposition for
    neural_network_causal_attribution. -/
theorem triple_causal_effect_splitting
    (A : Type*) [CommRing A] [RotaBaxterAlgebra A]
    (G : CausalDAG) (φ : CausalCharacter A)
    (decomp : BirkhoffPearlDecomposition A)
    (t : RTree) (h_enc : EncodesCausalPath G t G.intervention G.outcome) :
    ∃ (direct indirect confounded : A),
      φ.toFun t = direct + indirect + confounded ∧
      decomp.interventional.toFun t = direct + indirect ∧
      decomp.counterterm.toFun t = -confounded ∧
      direct = φ.toFun (minimalSubtree t) ∧
      TripleSplitting A (φ.toFun t) direct indirect confounded := by
  -- Use the coproduct to split: Δ(t) = t⊗1 + 1⊗t + Σ_{c proper} P_c(t)⊗R_c(t).
  -- The term t⊗1 is direct, 1⊗t is indirect (through root), proper cuts are confounded.
  -- Apply TripleSplitting from catalog as the algebraic witness.
  -- Use omega for cardinality bounds and induction on tree size.
  sorry
```

**THEOREM 9: Admissible Cut Count Bounds Adjustment Set Size**

```lean
/-- Bridge: connects admCutCount (combinatorics, from catalog) to bounds on
    the number of valid adjustment sets in causal inference.
    Impact: certified_adjustment_bound for post_quantum_key_exchange_causal. -/
theorem admcut_count_bounded_adjustment
    (G : CausalDAG)
    (t : RTree) (h_enc : EncodesCausalPath G t G.intervention G.outcome)
    (h_chain : IsChainTree t) :
    (Finset.filter (fun s : Finset ℕ => SatisfiesBackdoorCriterion G s)
      (Finset.powerset G.verts)).card ≤
      RTree.admCutCount t := by
  -- Each valid adjustment set corresponds to at least one admissible cut.
  -- For chain trees, admCutCount from catalog gives the exact count.
  -- Injectivity: different adjustment sets → different cuts (proven via
  -- the correspondence between backdoor paths and cut edges).
  -- Use linarith for the final inequality.
  sorry
```

**THEOREM 10: Linear Chain Causal Paths Have Minimal Confounding**

```lean
/-- Bridge: connects linear chain trees (combinatorics, from catalog) to
    causal models with no confounding (causal inference). For a linear chain
    DAG X→V₁→V₂→...→Vₙ→Y, the counterterm φ₋ vanishes identically—there are
    no backdoor paths. Impact: certified_zero_confound_chain for
    quantum_renormalized_causal_chain. -/
theorem linear_chain_zero_counterterm
    (A : Type*) [CommRing A] [RotaBaxterAlgebra A]
    (G : CausalDAG) (φ : CausalCharacter A)
    (decomp : BirkhoffPearlDecomposition A)
    (t : RTree) (h_chain : IsChainTree t)
    (h_enc : EncodesCausalPath G t G.intervention G.outcome) :
    decomp.counterterm.toFun t = 0 := by
  -- A chain tree has exactly one admissible cut (the root edge), which
  -- is the trivial cut. Proper admissible cuts are empty.
  -- Therefore φ₋(t) = Σ_{c proper} (-1)^|c|·φ(R_c(t))·φ(P_c(t)) = 0.
  -- Use admCutCount_linear_chain from catalog and field_simp.
  sorry
```

**THEOREM 11: Convolution Algebra Invertibility for Causal Characters**

```lean
/-- Every causal character with φ(one) = 1 is invertible in the convolution
    algebra. This is necessary for the Birkhoff decomposition to exist.
    Bridge: connects convolution algebra (Hopf algebra theory) to
    well-definedness of interventional distributions (causal inference).
    Impact: certified_invertibility for cryptographic_causal_signature. -/
theorem causal_character_convolution_invertible
    (A : Type*) [CommRing A]
    (φ : CausalCharacter A) :
    ∃ ψ : RTree → A,
      Convolution A φ.toFun ψ = (fun _ => 1) ∧
      Convolution A ψ φ.toFun = (fun _ => 1) := by
  -- Construct ψ recursively: ψ(one) = 1, and for tree t,
  --   ψ(t) = -φ(t) - Σ_{c proper} ψ(P_c(t))·φ(R_c(t)).
  -- This is exactly the convolution inverse, verified by induction.
  -- Use induction on tree size and ring for algebraic verification.
  sorry
```

**THEOREM 12: Lipschitz Stability of Interventional Distributions**

```lean
/-- Bridge: connects Lipschitz stability (analysis) to robustness of
    interventional distributions under perturbation of the causal model.
    If two causal characters are δ-close, their interventional distributions
    are O(δ·h_max)-close. Impact: lipschitz_certified_robustness for
    neural_network_causal_robustness. -/
theorem interventional_lipschitz_stability
    (A : Type*) [CommRing A] [RotaBaxterAlgebra A]
    (G : CausalDAG) (φ₁ φ₂ : CausalCharacter A)
    (d₁ d₂ : BirkhoffPearlDecomposition A)
    (δ : ℕ) (hδ : ∀ t : RTree, |(φ₁.toFun t : ℤ) - φ₂.toFun t| ≤ δ)
    (t : RTree) (h_enc : EncodesCausalPath G t G.intervention G.outcome) :
    |(d₁.interventional.toFun t : ℤ) - d₂.interventional.toFun t| ≤
      δ * (maxHeight G + 1) := by
  -- Induction on tree height. At each level, the Birkhoff positive part
  -- differs by at most δ from the difference of the characters, scaled by
  -- the number of proper admissible cuts (bounded by height).
  -- Use linarith for the inductive step and omega for base case.
  sorry
```

---

### PROOF STRATEGY ARCHITECTURE

**Path A (Primary — Algebraic Induction):** All theorems follow from induction on the tree grading. The coproduct Δ(t) = Σ P_c(t)⊗R_c(t) provides the inductive decomposition. Base cases are single-vertex and single-edge trees. The inductive step uses the recursive structure of admissible cuts. This is most promising because it directly leverages the catalog's RTree.admCutCount and GradedCoalgebra infrastructure.

**Path B (Contrapositive/Constructive):** For d-separation (Theorem 1) and uniqueness (Theorem 6), use by_contra to assume the negation and construct explicit witnesses. For d-separation, the witness is an active-path tree with nonvanishing convolution. For uniqueness, the witness is a minimal-grade disagreement.

**Path C (Combinatorial Injection):** For enumeration theorems (4, 9), establish injective maps between adjustment sets and admissible cuts, then use cardinality bounds from the catalog (admCutCount, admCutCount_linear_chain) to derive the O(|V|·d_max·h_max) complexity.

**Key Lemma Dependencies:**
- `coproduct_causal_decomposition`: Δ(t) for causal-path trees decomposes into causal subpaths
- `antipode_recursive_on_cuts`: S(t) = -t - Σ S(P_c(t))·R_c(t) restricted to proper cuts
- `birkhoff_counterterm_recursive`: φ₋(t) = -R(φ₋⋆φ∘π)(t) for Rota-Baxter weight -1
- `backdoor_cut_correspondence`: bijection between backdoor paths and nontrivial admissible cuts
- `chain_tree_unique_cut`: IsChainTree t → admCuts t has cardinality 1

---

### SIGNIFICANCE AND APPLICATIONS

**Why this is a breakthrough:** This establishes that Connes-Kreimer renormalization and Pearl's causal calculus are not merely analogous but *algebraically identical*—they share the same Hopf-algebraic DNA. The coproduct is the universal decomposition of causal effects; the antipode is the universal counterfactual operator; the Birkhoff decomposition is the universal confounding remover. This unification:

1. **Physics:** Provides a rigorous algebraic framework for renormalization of quantum field theories on causal spacetimes, where Feynman diagrams are literally causal DAGs and counterterms remove "confounding" from virtual particle loops.

2. **Machine Learning:** Enables *certified causal robustness*—Lipschitz bounds (Theorem 12) guarantee that interventional predictions are stable under model perturbation, critical for safety-critical AI systems.

3. **Cryptography:** The unique Birkhoff decomposition (Theorem 6) and the O(|V|·d_max·h_max) adjustment enumeration (Theorem 4) enable post-quantum causal commitment schemes where the algebraic structure guarantees computational binding.

---

### DEMANDED FUTURE DIRECTIONS

After proving the above, produce a structured `FUTURE_DIRECTIONS.md` containing:

1. **Tropical Causal Calculus:** Replace the target algebra A with the tropical semiring (min-plus algebra). Prove that the Birkhoff decomposition in the tropical setting yields *tropical interventional distributions* with certified min-plus Lipschitz bounds, connecting to tropical ML robustness.

2. **Quantum Causal Inference on Noncommutative Hopf Algebras:** Extend the Birkhoff–Pearl correspondence to noncommutative Rota-Baxter algebras, enabling causal reasoning in quantum field theories with noncommuting observables (relevant to AQFT and quantum information).

3. **Causal Lattice Cryptography:** Use the O(|V|·d_max·h_max) adjustment enumeration as the basis for a lattice-based commitment scheme where finding invalid adjustment sets reduces to the Shortest Vector Problem, yielding post-quantum security.

4. **Neural Network Causal Attribution via Antipode:** Apply the antipode-counterfactual correspondence (Theorem 5) to compute certified causal attributions for ReLU networks, where each neuron is a node in a causal DAG and the antipode computes the counterfactual "what would the output be without this neuron?"

5. **Categorical Duality: Causal Presheaves and Renormalization Sheaves:** Lift the Birkhoff–Pearl correspondence to the categorical level, showing that the presheaf of interventional distributions on a causal category is isomorphic to the sheaf of renormalized amplitudes on the corresponding Feynman category.

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
            Open the field of Hopf-algebraic causal calculus by proving three foundational theorems that establish a structural isomorphism between Connes-Kreimer renormalization and Pearl's do-calculus. (1) HOPF-ALGEBRAIC d-SEPARATION: For a DAG G inducing character φ on H_CK, variables X and Y are d-separated by Z iff the counit-restricted convolution (η∘ε)(t)=0 for every rooted tree t encoding an active path through Z—translating graphical separation into vanishing of coproduct components. (2) BIRKHOFF–PEARL CORRESPONDENCE: For a character φ:H_CK→A with A a Rota-Baxter algebra of weight λ=-1, the Birkhoff decomposition φ=φ₋⋆φ₊ satisfies φ₋(t)=Σ_{c∈AdmCuts(t)}(-1)^|c|·φ(R_c(t))·φ(P_c(t)) (confounding/backdoor component) and φ₊ recovers the interventional distribution P(Y|do(X))=φ₊(t_{X→Y}), proving that counterterm subtraction in QFT is structurally identical to confounding adjustment in causal inference. (3) FOREST-FORMULA ADJUSTMENT ENUMERATION: The Zimmermann forest formula for the antipode S(t)=-t-Σ_{c proper}S(P_c(t))·R_c(t) yields a recursive O(|V|·d_max·h_max) algorithm enumerating all valid adjustment sets Z for the causal effect of X on Y, where d_max is max in-degree and h_max is max tree height. This bridge reveals that renormalization and causal inference share the same algebraic DNA—the coproduct decomposes effects into direct/indirect, the antipode computes counterfactuals, and the Birkhoff decomposition separates confounded from unconfounded contributions.

            ### Precise Mathematical Framing
            Let H_CK be the Connes-Kreimer Hopf algebra of rooted trees with coproduct Δ, counit ε, and antipode S. A structural causal model M over variables V with structural equations f_i and noise U_i induces a character φ_M:H_CK→ℝ where φ_M(t)=∏_{edges e∈t} w(e) with w(X_i→X_j)=∂f_j/∂X_i evaluated at the observational distribution. Theorem 1 (d-Sep): X⊥_GY|Z ⟺ ∀t with root∈X, leaf∈Y, paths through Z: (φ_M|_Z⋆S)(t)=0 where φ_M|_Z is the restriction to trees whose internal nodes lie in Z. Theorem 2 (Birkhoff–Pearl): With R the Rota-Baxter operator R(φ)(t)=∫₀¹φ(t)dx (projection onto divergent subgraphs), define φ₋=-R(φ∘B₊∘(S⋆φ₊)) and φ₊=id-R applied similarly. Then P(Y|do(X=x))=φ₊(t_{X→Y})/φ₊(t_X) recovers Pearl's g-formula. Theorem 3 (Forest Adjustment): Valid adjustment sets Z correspond bijectively to admissible cuts c of the causal tree t_{X→Y} such that P_c(t)∩Z=∅ and R_c(t)⊆Z, with |ValidSets(X,Y)|=|AdmCuts(t_{X→Y})| computable in O(|V|·d_max·h_max) via the recursive antipode.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `leech_from_three_e8` : theorem leech_from_three_e8 : 3 * (8 : ℕ) = 24 := by norm_num
     (file: Bridges/Moonshine/MoonshineCodingTheory.lean)
  2. `zero_distortion_iff_complete_separation` : theorem zero_distortion_iff_complete_separation
     (file: Bridges/PrimeSpectralRateDistortion.lean)
  3. `eq_of_same_on_all_primes` : theorem eq_of_same_on_all_primes
     (file: Bridges/ProofSemiringStone.lean)
  4. `no_positive_gap_iff_all_nonpositive` : theorem no_positive_gap_iff_all_nonpositive
     (file: Bridges/ThermodynamicJacobsonCountermodelCompression.lean)
  5. `completeness_of_soundness_and_separation` : theorem completeness_of_soundness_and_separation
     (file: Bridges/ThermodynamicStonePrimeCompleteness.lean)

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



Recent successful concepts: Connes-Kreimer Universal Property: Free Hopf Algebra, Coassociative Coproduct, and β-Function Fixed-Point Dynamics, Sheaf-Theoretic Causal Calculus: Presheaf Interventions, Čech Cohomological Identifiability Obstructions, and Local-to-Global Adjustment, Non-Archimedean Information Geometry: p-adic Fisher Metric, Ultrametric Statistical Manifolds, and Valuation-Theoretic Cramér-Rao Bounds


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
