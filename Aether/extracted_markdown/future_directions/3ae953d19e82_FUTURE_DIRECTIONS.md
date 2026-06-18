# Future Directions: Polymodal Provability Logic and GL Frame Theory

## What We Built

This cycle formalized **polymodal provability logic (GLP)** and the **categorical structure of GL frames** in Lean 4, extending the existing single-modal GL framework in the catalog. The key contributions are:

1. **GLP Frame Hierarchy** (`GLPFrame`, `glp_loeb_at_level`, `glp_no_cross_cycle`): GLP frames with ℕ-indexed nested accessibility relations, where each level is a valid GL frame and no cycles can span different levels.

2. **P-Morphism Truth Lemma** (`pmorphism_truth_lemma`): Bounded morphisms preserve and reflect forcing under pullback valuation — the semantic backbone of GL model theory, proved axiom-free.

3. **Products and Coproducts** (`GLFrame.prod`, `GLFrame.sum`, `GLFrame.iProduct`): GL frames are closed under synchronized products, indexed products, and disjoint unions, with the second incompleteness theorem propagating through products.

4. **Order-Theoretic Bridge** (`GLFrame.toWFSPO`, `WFSPO.toGLFrame`): GL frames are exactly well-founded strict partial orders, with round-trip theorems confirming the equivalence.

---

## Direction 1: Solovay Completeness for Finite GL Frames

**Conjecture**: Every formula valid in all *finite* transitive irreflexive frames is provable in GL, and conversely. This completeness theorem would close the loop between our Kripke semantics and the Hilbert-style axiom system for GL.

The key insight is that GL has the finite model property: any formula not provable in GL can be refuted in a finite GL frame. This means our existing frame-theoretic infrastructure (products, p-morphisms, etc.) is sufficient to study the full logic — we don't need infinite frames for completeness.

Why now? We have p-morphisms and the truth lemma, which are the essential tools for filtration arguments. The filtration construction takes an infinite GL frame and a finite formula, and produces a finite frame refuting the same formula. With the truth lemma already proved, the remaining work is: (a) define a Hilbert-style proof system for GL, (b) prove soundness (easy given `loeb_valid`), (c) prove completeness via canonical model + filtration.

---

## Direction 2: GLP and Proof-Theoretic Ordinal Assignment

**Conjecture**: GLP frames admit a well-defined ordinal assignment function `ord : W → Ordinal` satisfying: if R_n(w,v) then ord(v) < ord(w), and the ordinal of a "standard world" under R₀ corresponds to the proof-theoretic ordinal of the theory (e.g., ε₀ for PA).

The key insight is that the nesting R₀ ⊇ R₁ ⊇ ··· creates a refined ordinal structure: the R_n-depth of a world gives its "n-th ordinal coordinate." Japaridze showed that GLP can compute proof-theoretic ordinals via the worm sequence, and our `glp_nesting_le` theorem provides the algebraic foundation for this.

Why now? The `GLPFrame.level` extraction and `glp_nesting_le` give us the tools to define depth functions at each level. The next step is to define the ordinal assignment via well-founded recursion on R₀ (using `R_wf 0`), prove it's strictly decreasing, and construct a concrete GLP frame on `Ordinal` that models PA's provability hierarchy.

---

## Direction 3: De Jongh–Sambin Fixed-Point Theorem via P-Morphisms

**Conjecture**: For any modal formula φ(p) where p occurs only within the scope of □, there exists a formula ψ (not containing p) such that the Löb-formula equivalence ψ ↔ φ(ψ) is valid in all GL frames. Moreover, the fixed point ψ is unique up to frame validity.

The key insight is that the "modalized" condition (p only under □) ensures the substitution φ(p) ↦ φ(ψ) is well-behaved with respect to forcing: the box modality absorbs the substitution's complexity. The p-morphism truth lemma (`pmorphism_truth_lemma`) provides the technical machinery to transfer fixed-point constructions between frames.

Why now? The truth lemma and the explicit formula language (`MFormula`) give us a solid foundation for defining substitution and the "modalized" predicate. The proof would use well-founded induction on the modal depth of p's occurrences and Löb's theorem (`loeb_valid`) at each step.

---

## Direction 4: Tangling Propagation in the Category of GL Frames

**Conjecture**: The category of GL frames with p-morphisms has finite limits and colimits, and the "tangling" property (that a sound world cannot prove its own consistency) is preserved by all categorical constructions. In particular, the pullback of two GL frames along p-morphisms is a GL frame, and tangling in the pullback implies tangling in at least one factor.

The key insight is that p-morphisms already form a category (composition is `PMorphism.comp`, identity is `PMorphism.id`), and the truth lemma ensures that validity — and hence tangling — transfers correctly. Pullbacks would give "synchronized products along a common quotient," which is the natural construction for combining proof systems that share a common sub-theory.

Why now? We have `PMorphism.comp`, `PMorphism.id`, `GLFrame.prod`, `GLFrame.sum`, and `PMorphism.inl`/`PMorphism.inr`. The missing piece is the pullback construction and the universal property proofs. The truth lemma makes the tangling-preservation argument straightforward once the pullback is constructed.

---

## Direction 5: Computational Depth Functions and Decidability

**Conjecture**: For any fixed formula φ of modal depth d, GL-validity of φ is decidable by checking validity in all GL frames of size ≤ 2^(2^d). This gives an explicit upper bound on the complexity of GL-satisfiability and connects our semantic framework to algorithmic logic.

The key insight is that the finite model property + our product construction gives a concrete bound: the filtration of the canonical model through a formula of depth d produces a frame of bounded size. The `GLFrame.iProduct` construction shows that the search space is finite when restricted to finite frames of bounded size.

Why now? The product and coproduct constructions provide the algebraic tools to build and decompose finite frames systematically. The order-theoretic bridge (`GLFrame.toWFSPO`) connects to Mathlib's extensive library on finite partial orders, which includes enumeration and cardinality results that could automate the decidability bound computation.
