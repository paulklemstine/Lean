# Future Directions: Tropical Hecke–Crystal Realization Duality

## 1. Full Finite Coxeter Braid Relations

**Current state.** Our formalization treats operators `T_i` as arbitrary endomorphisms on a finite set, with no braid or Coxeter relations imposed. The observational quotient construction works regardless.

**Next step.** Formalize braid relations `T_i T_j T_i = T_j T_i T_j` (type A₂) and more general Coxeter relations `(T_i T_j)^{m_{ij}} = id` for finite Coxeter systems (A, B, D, exceptional types). Show that braid relations constrain the quotient crystal graph to satisfy the corresponding crystal graph axioms from Kashiwara's theory.

**Theorem target:**
```
theorem braid_implies_crystal_graph_axioms
    (D : HeckeActionData ι S) (W : CoxeterMatrix ι)
    (h_braid : ∀ i j, BraidRelation D.T i j (W i j)) :
    SatisfiesKashiwaraAxioms (minimalCrystal D) W
```

**Strategy:** Define `BraidRelation` as equality of iterated word actions for all elements. Show the quotient crystal inherits these as graph-level axioms. The key insight is that braid relations on operators become combinatorial constraints on the crystal graph.

**Impact:** Connects the formalized minimization to the full Kashiwara crystal theory, enabling formalized verification of crystal base computations in representation theory.

---

## 2. Tropical Demazure Operators and Crystal Character Formulas

**Current state.** The tropical character is defined as the multiset of observation values of quotient states. No connection to Demazure character formulas is established.

**Next step.** Define tropical Demazure operators `D_i(χ) = (T_i(χ) ⊕ χ)` on tropical characters and prove the tropical crystal character satisfies the Demazure recursion under appropriate Hecke quadratic conditions.

**Theorem target:**
```
theorem tropical_demazure_character_recursion
    (D : HeckeActionData ι S) (h_quad : TropicalQuadratic D.T q)
    (i : ι) :
    tropicalDemazureOp i (tropicalCharacter D) = tropicalCharacter D
```

**Strategy:** The quadratic Hecke condition `T_i² = q·T_i + (1-q)·id` in tropical form becomes an idempotent/absorptive law. Under this, show the character is stable under Demazure operators by analyzing the action on quotient states.

**Impact:** Opens a path to tropicalized Littelmann path models and piecewise-linear canonical bases, connecting the formalization to geometric representation theory.

---

## 3. Learning-Theoretic Extraction of Hecke Crystals from Oracle Access

**Current state.** The reconstruction theorem is stated for a known, complete Hecke action table. In practice, one may only have oracle access to the operators.

**Next step.** Formalize a tropical analogue of Angluin's L* algorithm that learns the minimal crystal from membership and equivalence queries to the Hecke action oracle. Prove query complexity bounds.

**Theorem target:**
```
theorem tropical_hecke_learning_algorithm
    (D : HeckeActionData ι S)
    (oracle : HeckeOracle D) :
    ∃ (A : Algorithm) (n : ℕ),
      A.terminatesIn n ∧
      n ≤ |ι| * (tropRankHankel D)² ∧
      CrystalIso (A.output) (minimalCrystal D)
```

**Strategy:** Adapt the Angluin framework. The "membership query" is `obs(T_w(m))` for a given word `w` and generator `m`. The "equivalence query" checks if a conjectured crystal reproduces the same observation table. Finiteness of `M` and `S` ensures termination. The quadratic bound comes from the number of table entries needed to separate all quotient classes.

**Impact:** Creates a verified spectral learning algorithm for tropical representations, bridging formal methods, automata learning, and algebraic combinatorics. This could enable automated discovery of crystal structures from experimental or computational data.

---

## 4. Categorification via Idempotent Functor Categories

**Current state.** The realization duality is stated at the level of sets and functions. No categorical framework is used.

**Next step.** Lift the construction to an equivalence of categories:
- The category of finite reachable observable Hecke semimodules over `S`,
- The category of finite weighted crystal automata with `S`-compatible transitions.

Show the observational quotient defines a left adjoint to the inclusion of observable automata, making the minimization a categorical reflection.

**Theorem target:**
```
theorem hecke_crystal_adjunction :
    Adjunction (minimalCrystalFunctor S ι) (inclusionFunctor S ι)
```

**Strategy:** Define morphisms in both categories (equivariant maps / crystal morphisms). The unit of the adjunction is the quotient map; the counit is the identity on observable automata. Naturality follows from the universal property of the observational quotient.

**Impact:** Places the realization duality in the context of abstract algebra and category theory, enabling future connections to Morita equivalence, derived categories, and higher representation theory.

---

## 5. Tropical Hankel Rank Algorithms and Computational Complexity

**Current state.** The tropical rank is defined as the cardinality of the quotient, which equals the number of distinct observation profiles.

**Next step.** Give efficient algorithms for computing the tropical rank of the Hankel–Hecke matrix directly from the observation data, without explicitly constructing the quotient. Analyze the computational complexity.

**Theorem target:**
```
theorem tropical_hankel_rank_polynomial_time
    (D : HeckeActionData ι S)
    [DecidableEq S] [Fintype D.M] [Fintype ι] :
    ∃ (A : Algorithm),
      A.computes (tropRankHankel D) ∧
      A.timeComplexity ≤ |D.M|² * |ι| * |S|
```

**Strategy:** The rank can be computed by iteratively computing the partition of `M` into equivalence classes. Start with the partition by `obs` values, then refine by `obs ∘ T_i` for each `i`, iterating until stable. This is the classical partition refinement algorithm, which runs in `O(|M| * |ι| * log|M|)` time.

**Impact:** Makes the tropical Hankel rank a practically computable invariant, enabling algorithmic applications in tropical optimization, control theory (max-plus systems), and verification of algebraic structures.

---

## Cross-Domain Connections

These five directions span:
- **Representation theory** (Directions 1, 2): Kashiwara crystals, Demazure characters
- **Machine learning / algorithms** (Directions 3, 5): oracle learning, computational complexity
- **Category theory** (Direction 4): adjunctions, Morita equivalence
- **Tropical geometry** (all): max-plus algebra, tropical linear algebra
- **Formal verification** (all): machine-checked mathematical certificates

The central theme is that **finite-state minimization in idempotent algebra** is a rich and computationally meaningful paradigm with connections across mathematics, computer science, and applications.
