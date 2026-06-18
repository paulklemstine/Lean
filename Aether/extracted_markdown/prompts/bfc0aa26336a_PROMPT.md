
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

**Title**: The tropical eigenvalue of a matrix A is defined as λ* = min_σ (1/n) ∑ᵢ A(i, σ(i
**Domain**: Applications
**Mathematical framing**: # Future Directions: Tropical Matrix Algebra

## 1. Tropical Eigenvalue Theory and the Critical Graph

The tropical eigenvalue of a matrix A is defined as λ* = min_σ (1/n) ∑ᵢ A(i, σ(i)) where the minimum is taken over cyclic permutations. Equivalently, it is the minimum mean cycle weight in the associated weighted digraph. The critical graph — the subgraph of edges participating in minimum-mean cycles — determines the structure of tropical eigenvectors.

**Conjecture**: For a generic n×n tropical matrix (entries drawn independently from a continuous distribution), the critical graph is almost surely a union of disjoint cycles covering exactly ⌊n/2⌋ + 1 vertices, and the dimension of the tropical eigenspace equals the number of connected components of the critical graph.

The key insight is that the critical graph's structure is governed by the same combinatorial optimization as `tropDet`, and our submultiplicativity theorem `tropDet_submul` should extend to a spectral radius inequality: the tropical spectral radius of A⊗B is bounded by the sum of the individual spectral radii.

**Why now?** Our formalization of `tropDet` and `permSum` provides the exact infrastructure needed — extending from permutations to cyclic permutations and normalizing by cycle length is a natural next step. The `permSum_tropMatMul_le` lemma's proof technique (reindexing over permutation composition) directly generalizes to cycle decompositions.

## 2. Tropical Rank and the Barvinok Conjecture

The tropical rank of a matrix A is the smallest r such that A can be written as a tropical sum (pointwise min) of r tropical rank-1 matrices, where a tropical rank-1 matrix has the form (i,j) ↦ uᵢ + vⱼ. This is fundamentally different from the Kapranov rank (defined via tropicalization of classical rank).

**Conjecture**: For n×n matrices over WithTop ℕ, the tropical rank r satisfies tropDet(A) ≥ ∑ᵢ min_j A(i,j) with equality if and only if r = 1. More precisely, the gap tropDet(A) - ∑ᵢ min_j A(i,j) (our Hadamard gap) is a monotone function of the tropical rank: it is zero for rank 1 and strictly increases with rank up to a computable bound depending on n.

The key insight is that our `tropDet_hadamard` theorem characterizes exactly when the LP relaxation of the assignment problem is tight, and this tightness condition is equivalent to the tropical matrix having rank 1 — connecting our optimization-theoretic results to algebraic structure.

**Why now?** The Hadamard bound formalized in `tropDet_hadamard` is the starting point. Characterizing when equality holds requires analyzing the structure of optimal permutations, which our `permSum` infrastructure supports directly.

## 3. Tropical Permanent vs. Tropical Determinant: The Sign Problem

In classical linear algebra, det and perm differ by signs. In tropical algebra, there is no subtraction, so the tropical determinant equals the tropical permanent. However, one can define a "signed tropical determinant" using the theory of hyperfields or supertropical algebra, where elements carry a "ghost" sign.

**Conjecture**: Over the supertropical semiring (where each element carries a "ghost" layer recording sign cancellations), the signed tropical determinant satisfies a strict multiplicativity: sdet(A⊗B) = sdet(A) + sdet(B), upgrading our inequality `tropDet_submul` to an equality. This would be the tropical analogue of det(AB) = det(A)·det(B).

The key insight is that the inequality in `tropDet_submul` becomes an equality precisely when the optimal permutations for A and B "compose cleanly" — the supertropical ghost layer tracks exactly when this composition fails, and its vanishing is equivalent to the inequality being strict.

**Why now?** Our proof of `tropDet_submul` explicitly constructs the witness permutations (via `permSum_tropMatMul_le`), making the gap between the two sides computable. Formalizing the supertropical semiring and tracking when equality holds is a direct extension.

## 4. Tropical Convexity and the Assignment Polytope

The classical Birkhoff polytope — the set of doubly stochastic matrices — is intimately connected to the assignment problem. Its tropical analogue, the tropical Birkhoff polytope, should be the set of matrices A with tropDet(A) = 0 and all entries ≥ 0.

**Conjecture**: The tropical Birkhoff polytope (matrices A with entries in WithTop ℕ, tropDet(A) = 0, and A(i,j) ≥ 0) is tropically convex and has exactly n! tropical vertices, one for each permutation matrix. Moreover, the `tropDet_row_col_perm` invariance extends to a full tropical Sₙ × Sₙ symmetry group acting on this polytope.

The key insight is that `tropDet_zero_diag_eq_zero` already shows that matrices with zero diagonal are in this polytope, and `tropDet_row_col_perm` gives the symmetry group action. The tropical convexity (closure under tropical linear combinations) should follow from submultiplicativity.

**Why now?** All the ingredients are formalized: `tropDet`, `tropIdentity`, `tropDet_identity`, and `tropDet_row_col_perm`. Defining tropical convex combinations and proving closure is the natural next step.

## 5. Correspondence Theorem: Tropical Curves and Classical Enumerative Geometry

Mikhalkin's correspondence theorem states that the count of tropical curves through generic points in ℝ² (with appropriate multiplicities) equals the count of classical algebraic curves through corresponding points in ℂ². The multiplicities are computed from the Newton polygon subdivision — dual to the tropical curve's combinatorial type.

**Conjecture**: The tropical determinant `tropDet` of the "evaluation matrix" E(i,j) = (tropical distance from the i-th marked point to the j-th edge of the tropical curve) computes the Mikhalkin multiplicity of the tropical curve. More precisely, for a tropical curve Γ of genus 0 with n marked points, the Mikhalkin multiplicity equals a product of local `tropDet` contributions from each vertex of Γ.

The key insight is that `tropDet` is the optimal assignment value, and Mikhalkin's multiplicity involves a product of absolute values of 2×2 determinants at each vertex — these are exactly `tropDet` applied to the local edge direction matrix at each trivalent vertex.

**Why now?** This directly connects our tropical matrix algebra to the broader tropical enumerative geometry program. With `tropDet` formalized and its properties established, formalizing Mikhalkin's formula becomes tractable — start with the genus-0, degree-d case in ℝ² where the tropical curves are trees and the combinatorics is cleanest.

**Concept description**: # Future Directions: Tropical Matrix Algebra

## 1. Tropical Eigenvalue Theory and the Critical Graph

The tropical eigenvalue of a matrix A is defined as λ* = min_σ (1/n) ∑ᵢ A(i, σ(i)) where the minimum is taken over cyclic permutations. Equivalently, it is the minimum mean cycle weight in the associated weighted digraph. The critical graph — the subgraph of edges participating in minimum-mean cycles — determines the structure of tropical eigenvectors.

**Conjecture**: For a generic n×n tropical matrix (entries drawn independently from a continuous distribution), the critical graph is almost surely a union of disjoint cycles covering exactly ⌊n/2⌋ + 1 vertices, and the dimension of the tropical eigenspace equals the number of connected components of the critical graph.

The key insight is that the critical graph's structure is governed by the same combinatorial optimization as `tropDet`, and our submultiplicativity theorem `tropDet_submul` should extend to a spectral radius inequality: the tropical spectral radius of A⊗B is bounded by the sum of the individual spectral radii.

**Why now?** Our formalization of `tropDet` and `permSum` provides the exact infrastructure needed — extending from permutations to cyclic permutations and normalizing by cycle length is a natural next step. The `permSum_tropMatMul_le` lemma's proof technique (reindexing over permutation composition) directly generalizes to cycle decompositions.

## 2. Tropical Rank and the Barvinok Conjecture

The tropical rank of a matrix A is the smallest r such that A can be written as a tropical sum (pointwise min) of r tropical rank-1 matrices, where a tropical rank-1 matrix has the form (i,j) ↦ uᵢ + vⱼ. This is fundamentally different from the Kapranov rank (defined via tropicalization of classical rank).

**Conjecture**: For n×n matrices over WithTop ℕ, the tropical rank r satisfies tropDet(A) ≥ ∑ᵢ min_j A(i,j) with equality if and only if r = 1. More precisely, the gap tropDet(A) - ∑ᵢ min_j A(i,j) (our Hadamard gap) is a monotone function of the tropical rank: it is zero for rank 1 and strictly increases with rank up to a computable bound depending on n.

The key insight is that our `tropDet_hadamard` theorem characterizes exactly when the LP relaxation of the assignment problem is tight, and this tightness condition is equivalent to the tropical matrix having rank 1 — connecting our optimization-theoretic results to algebraic structure.

**Why now?** The Hadamard bound formalized in `tropDet_hadamard` is the starting point. Characterizing when equality holds requires analyzing the structure of optimal permutations, which our `permSum` infrastructure supports directly.

## 3. Tropical Permanent vs. Tropical Determinant: The Sign Problem

In classical linear algebra, det and perm differ by signs. In tropical algebra, there is no subtraction, so the tropical determinant equals the tropical permanent. However, one can define a "signed tropical determinant" using the theory of hyperfields or supertropical algebra, where elements carry a "ghost" sign.

**Conjecture**: Over the supertropical semiring (where each element carries a "ghost" layer recording sign cancellations), the signed tropical determinant satisfies a strict multiplicativity: sdet(A⊗B) = sdet(A) + sdet(B), upgrading our inequality `tropDet_submul` to an equality. This would be the tropical analogue of det(AB) = det(A)·det(B).

The key insight is that the inequality in `tropDet_submul` becomes an equality precisely when the optimal permutations for A and B "compose cleanly" — the supertropical ghost layer tracks exactly when this composition fails, and its vanishing is equivalent to the inequality being strict.

**Why now?** Our proof of `tropDet_submul` explicitly constructs the witness permutations (via `permSum_tropMatMul_le`), making the gap between the two sides computable. Formalizing the supertropical semiring and tracking when equality holds is a direct extension.

## 4. Tropical Convexity and the Assignment Polytope

The classical Birkhoff polytope — the set of doubly stochastic matrices — is intimately connected to the assignment problem. Its tropical analogue, the tropical Birkhoff polytope, should be the set of matrices A with tropDet(A) = 0 and all entries ≥ 0.

**Conjecture**: The tropical Birkhoff polytope (matrices A with entries in WithTop ℕ, tropDet(A) = 0, and A(i,j) ≥ 0) is tropically convex and has exactly n! tropical vertices, one for each permutation matrix. Moreover, the `tropDet_row_col_perm` invariance extends to a full tropical Sₙ × Sₙ symmetry group acting on this polytope.

The key insight is that `tropDet_zero_diag_eq_zero` already shows that matrices with zero diagonal are in this polytope, and `tropDet_row_col_perm` gives the symmetry group action. The tropical convexity (closure under tropical linear combinations) should follow from submultiplicativity.

**Why now?** All the ingredients are formalized: `tropDet`, `tropIdentity`, `tropDet_identity`, and `tropDet_row_col_perm`. Defining tropical convex combinations and proving closure is the natural next step.

## 5. Correspondence Theorem: Tropical Curves and Classical Enumerative Geometry

Mikhalkin's correspondence theorem states that the count of tropical curves through generic points in ℝ² (with appropriate multiplicities) equals the count of classical algebraic curves through corresponding points in ℂ². The multiplicities are computed from the Newton polygon subdivision — dual to the tropical curve's combinatorial type.

**Conjecture**: The tropical determinant `tropDet` of the "evaluation matrix" E(i,j) = (tropical distance from the i-th marked point to the j-th edge of the tropical curve) computes the Mikhalkin multiplicity of the tropical curve. More precisely, for a tropical curve Γ of genus 0 with n marked points, the Mikhalkin multiplicity equals a product of local `tropDet` contributions from each vertex of Γ.

The key insight is that `tropDet` is the optimal assignment value, and Mikhalkin's multiplicity involves a product of absolute values of 2×2 determinants at each vertex — these are exactly `tropDet` applied to the local edge direction matrix at each trivalent vertex.

**Why now?** This directly connects our tropical matrix algebra to the broader tropical enumerative geometry program. With `tropDet` formalized and its properties established, formalizing Mikhalkin's formula becomes tractable — start with the genus-0, degree-d case in ℝ² where the tropical curves are trees and the combinatorics is cleanest.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Applications
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v7 Depth Requirements — Structured Proofs with Completeness Gates

You are producing Lean 4 code on the mathematical frontier. Your output must
be COMPILABLE and your proofs must be COMPLETE. A single correct proof of a
non-trivial result is worth more than 5 theorems with `sorry`.

### STEP 1: THEOREM DECLARATIONS (required — before any code)

List every theorem you intend to prove. For each, state:
- **Name**: The Lean declaration name
- **Statement**: One-sentence informal statement
- **Status**: `proved` | `conjecture` | `proved_with_lemma_sorry`
- **Why non-trivial**: One sentence on the key mathematical insight

Example:
1. `cantorPairing_surjective`: Cantor pairing is surjective — proved — constructive inverse
2. `cantorPairing_injective`: Cantor pairing is injective — proved — diagonal argument
3. `cantorPairing_bijection`: Cantor pairing is a bijection — proved_with_lemma_sorry — follows from 1+2

### STEP 2: PROVE THEOREMS (completeness gate)

Every theorem declared as `proved` MUST have a complete, compiling Lean proof.
No `sorry` on the main result. If you cannot complete a proof, change its status
to `conjecture` or `proved_with_lemma_sorry` and explain why.

For `proved_with_lemma_sorry`:
- The theorem statement must be complete (no sorry in the statement)
- `sorry` is allowed ONLY in supporting lemmas, never the main proof
- A comment must explain what the sorry replaces and why it's deferred

For your BEST theorem, also provide:
- A generalization or strengthening (can use sorry if proving would take too long)
- A boundary case or counterexample showing where the result fails

### STEP 3: Anti-patterns (reject these)

These tactics indicate trivial proofs:
- `native_decide` / `decide` / `norm_num` / `rfl` — unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on any theorem declared as `proved`

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for conjectures and generalizations.

### STEP 4: Novelty

Your theorems must be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### Output format

Your output must include:
1. `.lean` files with the proofs (structured as declared in Step 1)
2. `FUTURE_DIRECTIONS.md` with 3-5 research conjectures extending the work

Both are required. Missing FUTURE_DIRECTIONS.md = automatic quality penalty.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
