# Future Directions: Ordinal Classification of EML Growth

## Synthesis

The ordinal classification of EML growth established in this work — the bridge **syntax → ordinal → asymptotic class** — opens multiple research frontiers. The core insight is that a computable ordinal rank, defined compositionally on expression syntax, determines asymptotic growth behavior. This insight naturally extends in five directions: completing the strict hierarchy (Direction 1), extending beyond ω² (Direction 2), refining the finite part to capture polynomial distinctions (Direction 3), connecting to proof-theoretic strength (Direction 4), and applying ordinal rank as a complexity certificate for symbolic computation (Direction 5).

These directions are tightly interconnected. Direction 1 (full separation) is prerequisite for Direction 2 (higher ordinals). Direction 3 (fine structure) enhances the practical utility of Direction 5 (complexity certificates). Direction 4 (reverse mathematics) provides the conceptual framework that unifies all others: it identifies *why* each ω-block represents a genuine logical jump, not just a growth jump.

---

## Direction 1: Full Strict Hierarchy Theorem

**Conjecture:** For all k ≥ 1, `iterExp(k)` does not belong to Hardy level k−1. Equivalently, no function at Hardy level k−1 eventually dominates `iterExp(k)`.

**Test:** Currently proved for k = 1 (exp is not at level 0). For k = 2, one must show that no combination of level-1 functions (products and sums of `f · exp(g)` where f, g are level-0) can eventually match `exp(exp(x))`. This requires proving that level-1 functions have at most single-exponential growth.

Computational test: evaluate `iterExp(k, n)` and the maximum of all level-(k−1) benchmark combinations at n = 10, 20, 50, 100. If `iterExp(k, n)` consistently exceeds every benchmark, this supports the conjecture. A counterexample would be a level-(k−1) expression whose evaluation matches or exceeds `iterExp(k)` for all tested n.

**Impact:** Establishes the full hierarchy theorem: the ordinal rank gives a *complete* asymptotic classification, not just an upper bound.

**Catalog References:** `Pythagorean/OrdinalClassification/Theorems.lean` (exp_not_hardyLevel'_zero, hardyLevel'_zero_poly_bound)

**Proof Strategy:** Generalize `hardyLevel'_zero_poly_bound` to all levels: prove that every HardyLevel n function is eventually bounded by C · iterExp(n+1, x). Then the argument for level 0 (polynomial bound ⟹ exp dominates) lifts to: level-n bound ⟹ iterExp(n+1) dominates.

**Domain Bridges:** Proof theory (ordinal strength), asymptotic analysis (growth comparison), computability theory (hierarchy separation)

**Lineage:** Builds directly on Theorems 4, 5, 6 of this paper.

**Ambition:** Solid extension — the k=1 case is proved, the general case requires one key growth bound lemma.

---

## Direction 2: Extension to Ordinals Beyond ω²

**Conjecture:** There exist natural extensions of the EML language (e.g., allowing recursion, self-reference, or higher-order operations) whose growth rates correspond to ordinals ω², ω³, ..., ε₀ in the fast-growing hierarchy.

**Test:** Define an extended EML language with a "tower" operation T(e) that applies eml n times where n is the evaluation of e. Compute T(var).eval(n) and compare with F_{ω²}(n) from the fast-growing hierarchy. If they match asymptotically (up to elementary factors), the conjecture is supported.

**Impact:** Grand challenge — would create an ordinal notation system for a substantial initial segment of the countable ordinals, arising entirely from analytic expression syntax. This would be the first such system not designed by logicians but discovered in analysis.

**Catalog References:** `Pythagorean/OrdinalClassification/Theorems.lean` (exprRank, OmegaBlock), `MachineLearning/HardyHierarchy/Defs.lean` (HardyLevel)

**Proof Strategy:** Define `OmegaNotation` as a tree-structured notation system for ordinals below ε₀. Define an extended rank function that maps the new operations to ordinal arithmetic operations (ω-exponentiation for the tower operation). Prove growth bounds using transfinite induction.

**Domain Bridges:** Proof theory (ε₀ analysis), ordinal notation theory, computability (Ackermann hierarchy), dynamical systems (renormalization)

**Lineage:** Natural successor to the current ω² classification.

**Ambition:** Grand challenge — paradigm-shifting if successful.

---

## Direction 3: Fine Structure of the Finite Part

**Conjecture:** Within each ω-block (fixed omegaCoeff = k), the finite part of the ordinal rank can be refined to capture polynomial degree: an expression of the form `p(x) · iterExp(k, x)` where p is a polynomial of degree d should have rank ⟨k, d⟩, and rank ⟨k, d₁⟩ is eventually dominated by rank ⟨k, d₂⟩ whenever d₁ < d₂.

**Test:** Compare `x · exp(x)` (expected rank ⟨1, 1⟩) with `x² · exp(x)` (expected rank ⟨1, 2⟩) and `exp(x)` (expected rank ⟨1, 0⟩). Verify that at large x, the ordering is exp(x) < x·exp(x) < x²·exp(x), consistent with the finite part ordering.

Computational disproof: find two expressions with different proposed finite parts but eventual mutual domination.

**Impact:** Transforms the coarse ω-block classification into a precise ordinal classification at every level below ω².

**Catalog References:** `Pythagorean/OrdinalClassification/Theorems.lean` (OmegaBlock, exprRank — currently finitePart is always 0)

**Proof Strategy:** Redefine exprRank to track polynomial degree through `add` (max degree), `mul` (sum of degrees), and `eml` (reset with the inner expression's degree). Prove that within each ω-block, the finite part controls an eventual domination ordering.

**Domain Bridges:** Analytic number theory (growth of arithmetic functions), algebraic complexity (degree bounds), approximation theory

**Lineage:** Refines the current exprRank definition.

**Ambition:** Solid extension — requires careful tracking of polynomial degrees.

---

## Direction 4: Reverse-Mathematical Strength of Rank-Bounded EML

**Conjecture:** Proving the totality of the growth function for all expressions of rank ω·k requires the logical strength of Σ^0_{k+1}-induction (or equivalently, k+1 nested inductions over ℕ). In particular, proving "every rank-⟨1,0⟩ expression is total" requires Σ^0_1-induction, and proving "every rank-⟨2,0⟩ expression is total" requires Σ^0_2-induction.

**Test:** Formalize the totality statements in a weak arithmetic (e.g., IΣ_1) and attempt to prove them. If the proof of rank-⟨k,0⟩ totality requires Σ^0_k-induction but not Σ^0_{k+1}-induction, the conjecture is confirmed. A refutation would be a proof of rank-⟨k,0⟩ totality in IΣ_{k-1}.

**Impact:** Grand challenge — would establish EML as a laboratory for reverse mathematics, where each ω-block corresponds to a precise logical principle.

**Catalog References:** `Pythagorean/OrdinalClassification/Theorems.lean` (rank_implies_hardyLevel, hardyLevel'_zero_poly_bound)

**Proof Strategy:** Use the Löb-Wainer theorem relating fast-growing hierarchy levels to fragments of arithmetic. Embed EML growth bounds into the corresponding arithmetic fragments and verify that the proofs cannot be carried out in weaker systems.

**Domain Bridges:** Reverse mathematics, proof theory, ordinal analysis, foundations of mathematics

**Lineage:** Connects ordinal rank to logical strength.

**Ambition:** Grand challenge — paradigm-shifting if successful, connecting analysis to logic.

---

## Direction 5: Ordinal Rank as Symbolic Complexity Certificate

**Conjecture:** The cost of symbolically differentiating, simplifying, or normalizing an EML expression e is bounded by a function that depends only on `exprRank(e)` and `size(e)`. Specifically, differentiation produces an expression of the same rank, and simplification (reducing to a canonical form within each rank class) runs in time O(size(e)^{f(rank.omegaCoeff)}) for some fixed function f.

**Test:** Implement symbolic differentiation for EML expressions. Measure the output size and computation time for expressions of various ranks and sizes. Plot size_output / size_input as a function of rank. If the ratio stabilizes within each ω-block but jumps between blocks, the conjecture is supported.

**Impact:** Creates a practical complexity theory for computer algebra, where the ordinal rank serves as a static analysis tool predicting algorithmic cost.

**Catalog References:** `Pythagorean/OrdinalClassification/Theorems.lean` (exprRank, ordinalClassify)

**Proof Strategy:** Define symbolic differentiation on EmlExpr. Prove that d/dx(eml(a,b)) = eml(a',b) + eml(a,b) · b' where a', b' are derivatives — this preserves the rank. Bound the size blowup per differentiation step and iterate.

**Domain Bridges:** Computer algebra, computational complexity, compiler optimization, scientific computing

**Lineage:** Applies the ordinal classifier as a practical tool.

**Ambition:** Solid extension — differentiation-preserving-rank is likely provable; the exact complexity bounds are harder.
