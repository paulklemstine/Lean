
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are leading a research team: Hypothesizer, Experimenter, Analyst,
Critic, and Synthesist. Run the loop:
Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate.
Your ONLY job is to produce **new Lean 4 code** and **take good notes**
for the next team.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by theorem declarations)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.
5. **Lab Notebook** as `-- !-- Lab Notebook -- !--` comment blocks
   in each .lean file: Hypothesis, Result, Insight, Failure analysis.

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

            ### CATALOG SYNTHESIS (required — read the catalog context below):
            The Catalog Context and Recent Discoveries sections list existing theorems
            already proven in this project. You MUST analyze these and combine concepts
            from the catalog with the research direction above. Specifically:

            1. **Identify relevant catalog theorems** — Which existing results connect
               to your research direction? Cite them by name in your proof sketches.
            2. **Build on catalog foundations** — Your theorems should EXTEND or
               GENERALIZE catalog results, not reprove them from scratch. Use `import`
               and reference existing definitions and lemmas where possible.
            3. **Combine concepts across domains** — The most valuable theorems connect
               ideas from different catalog domains (e.g., applying algebraic structures
               to topological problems, or using combinatorial arguments in number theory).
               Look for cross-domain connections in the catalog context.
            4. **Avoid duplication** — Check the catalog context before proving. If a
               similar result already exists, extend it rather than reproving it.


## Concept

**Title**: The Hodge filtration F^p on the complexification of a pure Hodge structure is th
**Domain**: Algebra
**Mathematical framing**: # Future Directions: Hodge Structure Theory in Lean 4

## 1. Hodge Filtration and Degeneration of the Hodge-to-de Rham Spectral Sequence

The Hodge filtration F^p on the complexification of a pure Hodge structure is the decreasing filtration defined by F^p = ⊕_{i≥p} H^{i,k-i}. A natural next step is to formalize the Hodge filtration as a `Submodule` tower and prove that the filtration determines the decomposition when the "opposition" condition F^p ⊕ F̄^{k-p+1} = V_ℂ holds. This would give the first formalized proof that the Hodge filtration is a complete invariant of a pure Hodge structure.

The key insight is that the Hodge filtration and its conjugate together reconstruct the bigrading — this is the essence of the "opposition" or "Hodge symmetry" condition, and formalizing it would connect the linear-algebraic theory to the geometric fact that the Hodge-to-de Rham spectral sequence degenerates at E₁ for compact Kähler manifolds.

Why now? The `HodgeDiamond` structure and `PureHodgeStructure` definitions are in place, and Mathlib's lattice theory on `Submodule` provides all the infrastructure needed for decreasing filtrations. The main challenge is managing the interplay between ℂ-subspaces and complex conjugation, which can be modeled via an involution on the ambient module.

## 2. Künneth Formula for Hodge Diamonds and Product Stability of the Hodge Conjecture

For compact Kähler manifolds X and Y, the Hodge numbers of the product satisfy h^{p,q}(X × Y) = Σ_{a+c=p, b+d=q} h^{a,b}(X) · h^{c,d}(Y). This "convolution" formula on Hodge diamonds should be formalizable as an operation `HodgeDiamond n → HodgeDiamond m → HodgeDiamond (n + m)` with a proof that the product Hodge diamond satisfies Hodge symmetry and Serre duality.

The key insight is that the product formula, combined with our existing `DirectSumHodgeData`, would give a complete proof that if the Hodge conjecture holds for X and Y separately, then it holds for product-type classes on X × Y. This is the content of the "Künneth component" of the Hodge conjecture, which reduces the general case to "primitive" classes.

Why now? The `HodgeDiamond` and `DirectSumHodgeData` structures are defined and the projective space example provides a test case: ℙⁿ × ℙᵐ should give the Segre variety's Hodge diamond, which can be verified computationally.

## 3. Lefschetz (1,1) Theorem: From Abstract to Geometric

Our `hodgeClasses_eq_top_of_vanishing` proves the Hodge conjecture when H^{2,0} = 0. The natural strengthening is the full Lefschetz (1,1) theorem: every rational (1,1)-class on a smooth projective variety is algebraic. This requires connecting the abstract Hodge structure framework to the Chern class map c₁ : Pic(X) → H²(X, ℤ) ∩ H^{1,1}(X).

The key insight is that the proof reduces to the exponential exact sequence 0 → ℤ → 𝒪 → 𝒪* → 0 and the vanishing of H²(X, 𝒪) → H²(X, ℤ) for (1,1)-classes. Formalizing this requires sheaf cohomology on a site, which Mathlib is beginning to support via `CategoryTheory.Sheaf`.

Why now? Mathlib's category theory library now has sites, sheaves, and derived functors in a usable state. The exponential sequence is a short exact sequence of sheaves, and the connecting homomorphism gives the Chern class. This would be the first formalized proof of Lefschetz (1,1) in any proof assistant.

## 4. Hodge Index Theorem for Surfaces and Signature of the Intersection Form

For a compact complex surface, the Hodge index theorem states that the intersection form on H^{1,1}(X, ℝ) has signature (1, h^{1,1} - 1) — exactly one positive eigenvalue, given by the Kähler class. Our `PolarizedHodgeStructure` already carries a nondegenerate bilinear form Q; the next step is to formalize the signature constraint.

The key insight is that the Hodge index theorem is equivalent to the Cauchy-Schwarz inequality for the intersection form restricted to H^{1,1} ∩ H²(X, ℝ). This can be formalized as: the quadratic form Q restricted to the orthogonal complement of the Kähler class is negative definite.

Why now? Mathlib has `LinearMap.BilinForm`, `Finrank`, and the spectral theory infrastructure for proving signature results via Sylvester's law of inertia. The `hodgeClasses_isCompl_orthogonal` theorem already proves the algebraic-transcendental decomposition, providing the starting point for a signature analysis.

## 5. Mumford-Tate Groups and the Hodge Conjecture for Abelian Varieties

The Mumford-Tate group of a Hodge structure is the smallest algebraic subgroup of GL(V) whose real points contain the image of the Hodge circle homomorphism. For abelian varieties, the Hodge conjecture is equivalent to the statement that the Mumford-Tate group determines all Hodge classes (via the Tannakian formalism). Formalizing Mumford-Tate groups would open the path to the known cases of the Hodge conjecture: CM abelian varieties, abelian varieties of dimension ≤ 3, and products of elliptic curves.

The key insight is that the Mumford-Tate group can be defined purely algebraically from the Hodge structure, without reference to the underlying geometry, as the stabilizer of all Hodge tensors in the tensor algebra of V. This makes it amenable to formalization using Mathlib's algebraic group and representation theory.

Why now? The weight-2 Hodge structure and polarization infrastructure are in place. Mathlib's `AlgebraicGroup` and `RepresentationTheory` modules provide the substrate. The CM case is particularly tractable because the Mumford-Tate group is a torus, reducing the Hodge conjecture to a computation with characters.

**Concept description**: # Future Directions: Hodge Structure Theory in Lean 4

## 1. Hodge Filtration and Degeneration of the Hodge-to-de Rham Spectral Sequence

The Hodge filtration F^p on the complexification of a pure Hodge structure is the decreasing filtration defined by F^p = ⊕_{i≥p} H^{i,k-i}. A natural next step is to formalize the Hodge filtration as a `Submodule` tower and prove that the filtration determines the decomposition when the "opposition" condition F^p ⊕ F̄^{k-p+1} = V_ℂ holds. This would give the first formalized proof that the Hodge filtration is a complete invariant of a pure Hodge structure.

The key insight is that the Hodge filtration and its conjugate together reconstruct the bigrading — this is the essence of the "opposition" or "Hodge symmetry" condition, and formalizing it would connect the linear-algebraic theory to the geometric fact that the Hodge-to-de Rham spectral sequence degenerates at E₁ for compact Kähler manifolds.

Why now? The `HodgeDiamond` structure and `PureHodgeStructure` definitions are in place, and Mathlib's lattice theory on `Submodule` provides all the infrastructure needed for decreasing filtrations. The main challenge is managing the interplay between ℂ-subspaces and complex conjugation, which can be modeled via an involution on the ambient module.

## 2. Künneth Formula for Hodge Diamonds and Product Stability of the Hodge Conjecture

For compact Kähler manifolds X and Y, the Hodge numbers of the product satisfy h^{p,q}(X × Y) = Σ_{a+c=p, b+d=q} h^{a,b}(X) · h^{c,d}(Y). This "convolution" formula on Hodge diamonds should be formalizable as an operation `HodgeDiamond n → HodgeDiamond m → HodgeDiamond (n + m)` with a proof that the product Hodge diamond satisfies Hodge symmetry and Serre duality.

The key insight is that the product formula, combined with our existing `DirectSumHodgeData`, would give a complete proof that if the Hodge conjecture holds for X and Y separately, then it holds for product-type classes on X × Y. This is the content of the "Künneth component" of the Hodge conjecture, which reduces the general case to "primitive" classes.

Why now? The `HodgeDiamond` and `DirectSumHodgeData` structures are defined and the projective space example provides a test case: ℙⁿ × ℙᵐ should give the Segre variety's Hodge diamond, which can be verified computationally.

## 3. Lefschetz (1,1) Theorem: From Abstract to Geometric

Our `hodgeClasses_eq_top_of_vanishing` proves the Hodge conjecture when H^{2,0} = 0. The natural strengthening is the full Lefschetz (1,1) theorem: every rational (1,1)-class on a smooth projective variety is algebraic. This requires connecting the abstract Hodge structure framework to the Chern class map c₁ : Pic(X) → H²(X, ℤ) ∩ H^{1,1}(X).

The key insight is that the proof reduces to the exponential exact sequence 0 → ℤ → 𝒪 → 𝒪* → 0 and the vanishing of H²(X, 𝒪) → H²(X, ℤ) for (1,1)-classes. Formalizing this requires sheaf cohomology on a site, which Mathlib is beginning to support via `CategoryTheory.Sheaf`.

Why now? Mathlib's category theory library now has sites, sheaves, and derived functors in a usable state. The exponential sequence is a short exact sequence of sheaves, and the connecting homomorphism gives the Chern class. This would be the first formalized proof of Lefschetz (1,1) in any proof assistant.

## 4. Hodge Index Theorem for Surfaces and Signature of the Intersection Form

For a compact complex surface, the Hodge index theorem states that the intersection form on H^{1,1}(X, ℝ) has signature (1, h^{1,1} - 1) — exactly one positive eigenvalue, given by the Kähler class. Our `PolarizedHodgeStructure` already carries a nondegenerate bilinear form Q; the next step is to formalize the signature constraint.

The key insight is that the Hodge index theorem is equivalent to the Cauchy-Schwarz inequality for the intersection form restricted to H^{1,1} ∩ H²(X, ℝ). This can be formalized as: the quadratic form Q restricted to the orthogonal complement of the Kähler class is negative definite.

Why now? Mathlib has `LinearMap.BilinForm`, `Finrank`, and the spectral theory infrastructure for proving signature results via Sylvester's law of inertia. The `hodgeClasses_isCompl_orthogonal` theorem already proves the algebraic-transcendental decomposition, providing the starting point for a signature analysis.

## 5. Mumford-Tate Groups and the Hodge Conjecture for Abelian Varieties

The Mumford-Tate group of a Hodge structure is the smallest algebraic subgroup of GL(V) whose real points contain the image of the Hodge circle homomorphism. For abelian varieties, the Hodge conjecture is equivalent to the statement that the Mumford-Tate group determines all Hodge classes (via the Tannakian formalism). Formalizing Mumford-Tate groups would open the path to the known cases of the Hodge conjecture: CM abelian varieties, abelian varieties of dimension ≤ 3, and products of elliptic curves.

The key insight is that the Mumford-Tate group can be defined purely algebraically from the Hodge structure, without reference to the underlying geometry, as the stabilizer of all Hodge tensors in the tensor algebra of V. This makes it amenable to formalization using Mathlib's algebraic group and representation theory.

Why now? The weight-2 Hodge structure and polarization infrastructure are in place. Mathlib's `AlgebraicGroup` and `RepresentationTheory` modules provide the substrate. The CM case is particularly tractable because the Mumford-Tate group is a torus, reducing the Hodge conjecture to a computation with characters.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Algebra
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v8 Depth Requirements -- Conceptual Unifier: Duality & Representation Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Conceptual Unification (Duality & Representation)**. Search for deep dualities, representation theorems, and dual translations (such as Stone duality, Gelfand duality, or Fourier/Pontryagin dualities).

### RESEARCH CORE METHODOLOGY:
1. **Dual Translations**: Look for dual formulations of your mathematical objects. Translate geometric or topological spaces into algebraic representations (e.g. rings of functions), and algebraic structures back into geometric spaces.
2. **Representation Theorems**: Seek to represent abstract algebraic or topological structures as concrete operations on simpler, well-understood spaces (e.g. matrices, sets, or functions).
3. **Spectral Perspectives**: Leverage spectral properties, duality pairings, and transform methods to translate hard problems in the primary space into easier problems in the dual space.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
