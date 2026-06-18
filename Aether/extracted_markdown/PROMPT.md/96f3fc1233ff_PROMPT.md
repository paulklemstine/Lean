
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are a world-class mathematician. Your ONLY job in this cycle is
to produce **new Lean 4 code that extends the frontier of mathematics**.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by the Plan)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.

            ### DO NOT OUTPUT (Phase B handles these — if your work passes quality bar):
            - NO `ARTICLE.md`
            - NO `RESEARCH_PAPER.md`
            - NO `demo.py` / `algorithms.py`
            - NO HTML widgets
            - NO `PACKAGE.json`
            - NO prose for human readers (except FUTURE_DIRECTIONS.md)

            ### WHY THIS NARROW:
            The Lean 4 file IS the deliverable. A self-contained Lean file with
            3-5 world-class theorems is worth more than 30K characters of prose
            about trivial results. Focus 100% of your compute on the math.
            If your work is genuinely world-class, the packaging step is dispatched
            automatically and cheaply.


## Concept

**Title**: Rigorous Lean 4 formalization of provability logic (GL)
**Domain**: Tropical
**Mathematical framing**: # Future Directions: Tangled Hierarchies and Self-Referential Proof Systems

## Synthesis

This cycle established a rigorous Lean 4 formalization of provability logic (GL) via Kripke semantics, proving 12 theorems including Löb's theorem, the semantic second incompleteness theorem, a sharp tangling dichotomy, and a novel bridge between GL frames and well-founded strict partial orders. The most promising cross-domain connection is the **order-theoretic bridge** (Theorem `gl_frame_is_strict_order`): GL frames are exactly well-founded strict partial orders, meaning the entire apparatus of well-quasi-order theory, ordinal analysis, and lattice-theoretic fixed points becomes available to study provability hierarchies.

The key structural insight from this cycle is the **tangling dichotomy** (`tangling_dichotomy_ext`): every sound world either is terminal (vacuously omniscient) or has blind spots about its own soundness. This dichotomy is exhaustive and propagates through the entire consistency hierarchy. Combined with the disjoint union closure result, this shows that tangling is compositional — combining independent systems does not resolve any individual system's tangling.

The highest breakthrough potential lies in **Direction 1** (Polymodal GL and ordinal analysis), which would connect our GL frame theory to Japaridze's GLP logic and proof-theoretic ordinals, bridging modal logic, set theory, and proof theory in a formally verified framework. This would be a significant first in the formalization of proof theory.

---

### Direction 1: Polymodal Provability Logic (GLP) and Ordinal Assignment

**Conjecture**: GLP frames — frames with a sequence of accessibility relations R₀ ⊇ R₁ ⊇ R₂ ⊇ ··· where each Rₙ is transitive and converse well-founded — can be formally constructed in Lean 4 with a well-defined ordinal assignment function that maps each world to its proof-theoretic ordinal. Specifically, the ordinal assignment should satisfy: if Rₙ(w,v) then ord(v) < ord(w), and the ordinal of the "standard world" under R₀ should correspond to ε₀ (the proof-theoretic ordinal of PA).

**Test**: Define a `GLPFrame` structure in Lean 4 with a family of accessibility relations indexed by ℕ, prove that each level gives a valid GL frame, and construct a concrete GLP frame whose ordinal assignment reproduces the standard ordinal analysis of PA (ordinal ε₀ at the base level, ω^ω^···  at higher levels).

**Impact**: If successful, this would be the first machine-verified formalization of the connection between polymodal provability logic and proof-theoretic ordinals, bridging modal logic and ordinal analysis. If the ordinal assignment fails to give ε₀, it would reveal that the standard GLP-ordinal connection requires additional structure beyond the frame semantics (perhaps specific arithmetical interpretations).

**Catalog References**: `Logic/TangledHierarchyDefs.lean` (GLFrame), `Logic/TangledHierarchyTheorems.lean` (loeb_semantic, gl_frame_is_strict_order)

**Proof Strategy**:
1. Define `GLPFrame` as a dependent structure with `R : ℕ → W → W → Prop` and monotonicity/transitivity/well-foundedness conditions.
2. Prove each `R n` gives a GL frame (reuse existing infrastructure).
3. Define ordinal assignment via well-founded recursion on R₀.
4. Prove the assignment is strictly decreasing and bounds the depth.
5. Construct a concrete GLP frame on an ordinal type.

**Domain Bridges**: Logic (provability logic) ↔ Set Theory (ordinal analysis) ↔ Proof Theory (consistency strength)

**Lineage**: Extends `gl_frame_is_strict_order` and `tangling_dichotomy_ext` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: De Jongh-Sambin Fixed-Point Theorem for GL

**Conjecture**: For any modal formula φ(p) where the propositional variable p occurs only within the scope of □, there exists a formula ψ (not containing p) such that GL ⊢ ψ ↔ φ(ψ). Moreover, this fixed point is unique up to GL-provable equivalence. This can be formalized semantically: for every GL frame M and valuation V, the formula ψ constructed by the fixed-point procedure satisfies w ⊩ ψ ↔ w ⊩ φ(ψ) at every world w.

**Test**: Define a substitution operation on modal formulas, formalize the "occurs only under box" condition, and prove the fixed-point existence theorem for GL frames. Test on concrete cases: the Gödel sentence (φ(p) = ¬□p gives ψ ≡ ¬□⊥ ≡ Con) and the Henkin sentence (φ(p) = □p gives ψ ≡ ⊤).

**Impact**: This would formalize one of the deepest results in provability logic, connecting self-reference (fixed points) to the modal-logical framework. It directly extends the Catalog's `fixed_point_construction_bound` to the logical domain. Failure would indicate that the semantic approach is insufficient and a syntactic (Hilbert system) formalization is needed.

**Catalog References**: `Bridges/EMLClosureCore.lean` (fixed_point_construction_bound), `Logic/TangledHierarchyDefs.lean` (MFormula, forces)

**Proof Strategy**:
1. Define formula substitution `MFormula.subst : MFormula α → (α → MFormula α) → MFormula α`.
2. Define the "modalized in p" predicate: p occurs only under □.
3. Construct the fixed-point formula by iterating the substitution (this is well-defined because each step reduces the "modal depth" of occurrences of p).
4. Prove the fixed point satisfies the equivalence using Löb's theorem and well-founded induction.
5. Prove uniqueness using the characterization of GL-provable equivalence via frame validity.

**Domain Bridges**: Logic (fixed-point theorem) ↔ Algebra (fixed-point constructions, Knaster-Tarski) ↔ Computation (self-referential programs, quines)

**Lineage**: Extends `loeb_semantic` and `fixed_point_construction_bound` from the Catalog.

**Ambition**: grand_challenge

---

### Direction 3: Tropical Provability: Min-Plus Semantics for GL

**Conjecture**: GL frames admit a "tropical" semantics where the forcing relation is replaced by a real-valued "proof cost" function cost(w, φ) ∈ [0, ∞], with □φ costing the supremum of costs over accessible worlds plus a "reflection overhead" constant. In this tropical semantics, Löb's theorem corresponds to the statement that the cost of self-referential proofs grows without bound — tangling has a quantitative measure.

**Test**: Define `tropicalForces : GLFrame → (α → M.W → ℝ≥0∞) → M.W → MFormula α → ℝ≥0∞` where:
- cost(w, var p) = V(p)(w)
- cost(w, ⊥) = ∞
- cost(w, φ → ψ) = max(0, cost(w,ψ) - cost(w,φ))
- cost(w, □φ) = sup{cost(v,φ) + 1 : R(w,v)}

Prove that if cost(w, □(□φ→φ)) < ∞ then cost(w, □φ) < ∞ (tropical Löb), and that the reflection overhead creates a strictly increasing cost along the consistency hierarchy.

**Impact**: This bridges provability logic to tropical geometry and optimization, creating a quantitative theory of proof complexity within the GL framework. It would connect to the Catalog's tropical algebra results and create a novel "tropical incompleteness theorem."

**Catalog References**: `Tropical/TropicalOrbitShadowing.lean` (iterate_dist_fixed_point_bound), `Cryptography/BerggrenDiophantineLattice.lean` (tropical structures)

**Proof Strategy**:
1. Define the tropical forcing function using well-founded recursion (similar to `forces`).
2. Prove tropical Löb by adapting the well-founded induction argument.
3. Show that each consistency level adds constant overhead, giving a linear lower bound on cost(w, Conⁿ).
4. Connect to the metric structure via `iterate_dist_fixed_point_bound`.

**Domain Bridges**: Logic (GL frames, Löb's theorem) ↔ Tropical Algebra (min-plus semirings) ↔ Optimization (proof search costs)

**Lineage**: Extends `loeb_semantic` and bridges to `iterate_dist_fixed_point_bound`.

**Ambition**: extension

---

### Direction 4: Tangling in PAC-Bayesian Learning Theory

**Conjecture**: The tangling dichotomy has a precise analog in PAC-Bayesian learning theory: a learning algorithm that is "sound" (its generalization bound holds for all distributions) either has trivial capacity (it can only learn constant functions) or there exist distributions for which its self-estimated generalization bound is strictly looser than the true bound — it cannot accurately predict its own generalization error.

**Test**: Formalize the analogy by defining a "PAC-Bayesian frame" where worlds are distributions, the accessibility relation is "distribution D₁ can be estimated from D₂", and soundness means the generalization bound holds. Prove that the tangling dichotomy applies to this frame, producing a "PAC-Bayesian incompleteness theorem."

**Impact**: This would establish a rigorous connection between Gödelian incompleteness and statistical learning theory, showing that the tangling phenomenon is not merely logical but statistical. It extends the Catalog's `second_incompleteness_analog` and `unprovable_true_generalization` results.

**Catalog References**: `MachineLearning/LoebGeneralization.lean` (lob_generalization_criterion), `MachineLearning/CertificationBarrier.lean` (barriers_from_diagonalization)

**Proof Strategy**:
1. Define a PAC-Bayesian GL frame where worlds are (prior, posterior, sample_size) triples.
2. Define R as the "can estimate from" relation, prove it's transitive and converse well-founded (bounded by sample size).
3. Instantiate the tangling dichotomy to get the PAC-Bayesian incompleteness theorem.
4. Prove concrete bounds: the gap between self-estimated and true generalization error is at least O(1/√n).

**Domain Bridges**: Logic (tangling dichotomy) ↔ Machine Learning (PAC-Bayes, generalization bounds) ↔ Statistics (self-referential estimation)

**Lineage**: Extends `tangling_dichotomy_ext` and connects to `lob_generalization_criterion`.

**Ambition**: extension

---

### Direction 5: Compositional Tangling and Category of GL Frames

**Conjecture**: GL frames form a category where morphisms are "p-morphisms" (bounded morphisms preserving the frame structure). This category has finite products (given by a "synchronized product" where R holds componentwise) and the tangling dichotomy is preserved by all categorical operations — tangling is a "categorical property" in a precise sense.

**Test**: Define the category of GL frames and p-morphisms in Lean 4. Prove that finite products exist and are GL frames. Prove that if M₁ and M₂ each have sound worlds with successors (hence tangled), then their product is also tangled. Show the disjoint union is the coproduct in this category.

**Impact**: This would establish that tangling is not just a property of individual frames but a structural property preserved by the natural categorical operations. It would connect provability logic to categorical logic and topos theory.

**Catalog References**: `Logic/TangledHierarchyTheorems.lean` (GLFrame.disjointUnion, tangling_dichotomy_ext)

**Proof Strategy**:
1. Define `GLFrameMorphism` as structure-preserving maps with back-and-forth conditions.
2. Show composition and identity give a category.
3. Define product frames and prove they satisfy GL conditions.
4. Prove tangling preservation via the tangling dichotomy applied to projected worlds.
5. Prove disjoint union is the coproduct by constructing universal morphisms.

**Domain Bridges**: Logic (GL frames) ↔ Category Theory (products, coproducts, preservation) ↔ Algebra (categorical constructions)

**Lineage**: Extends `GLFrame.disjointUnion` and `tangling_dichotomy_ext`.

**Ambition**: extension

**Concept description**: # Future Directions: Tangled Hierarchies and Self-Referential Proof Systems

## Synthesis

This cycle established a rigorous Lean 4 formalization of provability logic (GL) via Kripke semantics, proving 12 theorems including Löb's theorem, the semantic second incompleteness theorem, a sharp tangling dichotomy, and a novel bridge between GL frames and well-founded strict partial orders. The most promising cross-domain connection is the **order-theoretic bridge** (Theorem `gl_frame_is_strict_order`): GL frames are exactly well-founded strict partial orders, meaning the entire apparatus of well-quasi-order theory, ordinal analysis, and lattice-theoretic fixed points becomes available to study provability hierarchies.

The key structural insight from this cycle is the **tangling dichotomy** (`tangling_dichotomy_ext`): every sound world either is terminal (vacuously omniscient) or has blind spots about its own soundness. This dichotomy is exhaustive and propagates through the entire consistency hierarchy. Combined with the disjoint union closure result, this shows that tangling is compositional — combining independent systems does not resolve any individual system's tangling.

The highest breakthrough potential lies in **Direction 1** (Polymodal GL and ordinal analysis), which would connect our GL frame theory to Japaridze's GLP logic and proof-theoretic ordinals, bridging modal logic, set theory, and proof theory in a formally verified framework. This would be a significant first in the formalization of proof theory.

---

### Direction 1: Polymodal Provability Logic (GLP) and Ordinal Assignment

**Conjecture**: GLP frames — frames with a sequence of accessibility relations R₀ ⊇ R₁ ⊇ R₂ ⊇ ··· where each Rₙ is transitive and converse well-founded — can be formally constructed in Lean 4 with a well-defined ordinal assignment function that maps each world to its proof-theoretic ordinal. Specifically, the ordinal assignment should satisfy: if Rₙ(w,v) then ord(v) < ord(w), and the ordinal of the "standard world" under R₀ should correspond to ε₀ (the proof-theoretic ordinal of PA).

**Test**: Define a `GLPFrame` structure in Lean 4 with a family of accessibility relations indexed by ℕ, prove that each level gives a valid GL frame, and construct a concrete GLP frame whose ordinal assignment reproduces the standard ordinal analysis of PA (ordinal ε₀ at the base level, ω^ω^···  at higher levels).

**Impact**: If successful, this would be the first machine-verified formalization of the connection between polymodal provability logic and proof-theoretic ordinals, bridging modal logic and ordinal analysis. If the ordinal assignment fails to give ε₀, it would reveal that the standard GLP-ordinal connection requires additional structure beyond the frame semantics (perhaps specific arithmetical interpretations).

**Catalog References**: `Logic/TangledHierarchyDefs.lean` (GLFrame), `Logic/TangledHierarchyTheorems.lean` (loeb_semantic, gl_frame_is_strict_order)

**Proof Strategy**:
1. Define `GLPFrame` as a dependent structure with `R : ℕ → W → W → Prop` and monotonicity/transitivity/well-foundedness conditions.
2. Prove each `R n` gives a GL frame (reuse existing infrastructure).
3. Define ordinal assignment via well-founded recursion on R₀.
4. Prove the assignment is strictly decreasing and bounds the depth.
5. Construct a concrete GLP frame on an ordinal type.

**Domain Bridges**: Logic (provability logic) ↔ Set Theory (ordinal analysis) ↔ Proof Theory (consistency strength)

**Lineage**: Extends `gl_frame_is_strict_order` and `tangling_dichotomy_ext` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: De Jongh-Sambin Fixed-Point Theorem for GL

**Conjecture**: For any modal formula φ(p) where the propositional variable p occurs only within the scope of □, there exists a formula ψ (not containing p) such that GL ⊢ ψ ↔ φ(ψ). Moreover, this fixed point is unique up to GL-provable equivalence. This can be formalized semantically: for every GL frame M and valuation V, the formula ψ constructed by the fixed-point procedure satisfies w ⊩ ψ ↔ w ⊩ φ(ψ) at every world w.

**Test**: Define a substitution operation on modal formulas, formalize the "occurs only under box" condition, and prove the fixed-point existence theorem for GL frames. Test on concrete cases: the Gödel sentence (φ(p) = ¬□p gives ψ ≡ ¬□⊥ ≡ Con) and the Henkin sentence (φ(p) = □p gives ψ ≡ ⊤).

**Impact**: This would formalize one of the deepest results in provability logic, connecting self-reference (fixed points) to the modal-logical framework. It directly extends the Catalog's `fixed_point_construction_bound` to the logical domain. Failure would indicate that the semantic approach is insufficient and a syntactic (Hilbert system) formalization is needed.

**Catalog References**: `Bridges/EMLClosureCore.lean` (fixed_point_construction_bound), `Logic/TangledHierarchyDefs.lean` (MFormula, forces)

**Proof Strategy**:
1. Define formula substitution `MFormula.subst : MFormula α → (α → MFormula α) → MFormula α`.
2. Define the "modalized in p" predicate: p occurs only under □.
3. Construct the fixed-point formula by iterating the substitution (this is well-defined because each step reduces the "modal depth" of occurrences of p).
4. Prove the fixed point satisfies the equivalence using Löb's theorem and well-founded induction.
5. Prove uniqueness using the characterization of GL-provable equivalence via frame validity.

**Domain Bridges**: Logic (fixed-point theorem) ↔ Algebra (fixed-point constructions, Knaster-Tarski) ↔ Computation (self-referential programs, quines)

**Lineage**: Extends `loeb_semantic` and `fixed_point_construction_bound` from the Catalog.

**Ambition**: grand_challenge

---

### Direction 3: Tropical Provability: Min-Plus Semantics for GL

**Conjecture**: GL frames admit a "tropical" semantics where the forcing relation is replaced by a real-valued "proof cost" function cost(w, φ) ∈ [0, ∞], with □φ costing the supremum of costs over accessible worlds plus a "reflection overhead" constant. In this tropical semantics, Löb's theorem corresponds to the statement that the cost of self-referential proofs grows without bound — tangling has a quantitative measure.

**Test**: Define `tropicalForces : GLFrame → (α → M.W → ℝ≥0∞) → M.W → MFormula α → ℝ≥0∞` where:
- cost(w, var p) = V(p)(w)
- cost(w, ⊥) = ∞
- cost(w, φ → ψ) = max(0, cost(w,ψ) - cost(w,φ))
- cost(w, □φ) = sup{cost(v,φ) + 1 : R(w,v)}

Prove that if cost(w, □(□φ→φ)) < ∞ then cost(w, □φ) < ∞ (tropical Löb), and that the reflection overhead creates a strictly increasing cost along the consistency hierarchy.

**Impact**: This bridges provability logic to tropical geometry and optimization, creating a quantitative theory of proof complexity within the GL framework. It would connect to the Catalog's tropical algebra results and create a novel "tropical incompleteness theorem."

**Catalog References**: `Tropical/TropicalOrbitShadowing.lean` (iterate_dist_fixed_point_bound), `Cryptography/BerggrenDiophantineLattice.lean` (tropical structures)

**Proof Strategy**:
1. Define the tropical forcing function using well-founded recursion (similar to `forces`).
2. Prove tropical Löb by adapting the well-founded induction argument.
3. Show that each consistency level adds constant overhead, giving a linear lower bound on cost(w, Conⁿ).
4. Connect to the metric structure via `iterate_dist_fixed_point_bound`.

**Domain Bridges**: Logic (GL frames, Löb's theorem) ↔ Tropical Algebra (min-plus semirings) ↔ Optimization (proof search costs)

**Lineage**: Extends `loeb_semantic` and bridges to `iterate_dist_fixed_point_bound`.

**Ambition**: extension

---

### Direction 4: Tangling in PAC-Bayesian Learning Theory

**Conjecture**: The tangling dichotomy has a precise analog in PAC-Bayesian learning theory: a learning algorithm that is "sound" (its generalization bound holds for all distributions) either has trivial capacity (it can only learn constant functions) or there exist distributions for which its self-estimated generalization bound is strictly looser than the true bound — it cannot accurately predict its own generalization error.

**Test**: Formalize the analogy by defining a "PAC-Bayesian frame" where worlds are distributions, the accessibility relation is "distribution D₁ can be estimated from D₂", and soundness means the generalization bound holds. Prove that the tangling dichotomy applies to this frame, producing a "PAC-Bayesian incompleteness theorem."

**Impact**: This would establish a rigorous connection between Gödelian incompleteness and statistical learning theory, showing that the tangling phenomenon is not merely logical but statistical. It extends the Catalog's `second_incompleteness_analog` and `unprovable_true_generalization` results.

**Catalog References**: `MachineLearning/LoebGeneralization.lean` (lob_generalization_criterion), `MachineLearning/CertificationBarrier.lean` (barriers_from_diagonalization)

**Proof Strategy**:
1. Define a PAC-Bayesian GL frame where worlds are (prior, posterior, sample_size) triples.
2. Define R as the "can estimate from" relation, prove it's transitive and converse well-founded (bounded by sample size).
3. Instantiate the tangling dichotomy to get the PAC-Bayesian incompleteness theorem.
4. Prove concrete bounds: the gap between self-estimated and true generalization error is at least O(1/√n).

**Domain Bridges**: Logic (tangling dichotomy) ↔ Machine Learning (PAC-Bayes, generalization bounds) ↔ Statistics (self-referential estimation)

**Lineage**: Extends `tangling_dichotomy_ext` and connects to `lob_generalization_criterion`.

**Ambition**: extension

---

### Direction 5: Compositional Tangling and Category of GL Frames

**Conjecture**: GL frames form a category where morphisms are "p-morphisms" (bounded morphisms preserving the frame structure). This category has finite products (given by a "synchronized product" where R holds componentwise) and the tangling dichotomy is preserved by all categorical operations — tangling is a "categorical property" in a precise sense.

**Test**: Define the category of GL frames and p-morphisms in Lean 4. Prove that finite products exist and are GL frames. Prove that if M₁ and M₂ each have sound worlds with successors (hence tangled), then their product is also tangled. Show the disjoint union is the coproduct in this category.

**Impact**: This would establish that tangling is not just a property of individual frames but a structural property preserved by the natural categorical operations. It would connect provability logic to categorical logic and topos theory.

**Catalog References**: `Logic/TangledHierarchyTheorems.lean` (GLFrame.disjointUnion, tangling_dichotomy_ext)

**Proof Strategy**:
1. Define `GLFrameMorphism` as structure-preserving maps with back-and-forth conditions.
2. Show composition and identity give a category.
3. Define product frames and prove they satisfy GL conditions.
4. Prove tangling preservation via the tangling dichotomy applied to projected worlds.
5. Prove disjoint union is the coproduct by constructing universal morphisms.

**Domain Bridges**: Logic (GL frames) ↔ Category Theory (products, coproducts, preservation) ↔ Algebra (categorical constructions)

**Lineage**: Extends `GLFrame.disjointUnion` and `tangling_dichotomy_ext`.

**Ambition**: extension

**Novelty estimate**: 0.29999999999999993
**Breakthrough potential**: 0.29999999999999993
Research domain: Tropical
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v6 Depth Requirements — Correct Proofs First

You are working on the frontier of mathematics. Your goal is to produce
Lean 4 code that COMPILES and PROVES non-trivial results. A correct proof
of one good theorem is worth more than 5 theorems with `sorry`.

### STEP 1: BRIEF PLAN (2-3 lines)

Before writing Lean code, state:
- **Strategy**: New structure (Grothendieck) OR extend existing result (Cauchy)
- **Theorems**: List the 2-4 theorems you will prove (one sentence each)
- **Why non-trivial**: One sentence explaining the key insight

### STEP 2: PROVE THEOREMS (correctness > completeness)

Write Lean 4 proofs that COMPILE. Every theorem should have:
- A complete proof (no `sorry` for the main result)
- A brief proof sketch as a comment (1-2 sentences)
- An `example` block showing the theorem in action (if practical)

For your BEST theorem, also provide:
- A generalization or strengthening (can use `sorry` if proving it would take too long)
- A boundary case or counterexample showing where the result fails

You do NOT need full PEGB on every theorem. Deep PEGB on your best theorem
and solid proofs on the rest is the target.

### STEP 3: Anti-patterns (avoid these)

These tactics indicate trivial proofs that add no value:
- `native_decide` / `decide` / `norm_num` / `rfl` — unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on the main theorem statement

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for generalizations and boundary cases.

### STEP 4: Novelty

Your theorems should be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### Output format

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
