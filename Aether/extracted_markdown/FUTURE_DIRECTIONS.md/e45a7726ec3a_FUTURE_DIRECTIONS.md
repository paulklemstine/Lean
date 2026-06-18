# Future Directions: Depth Rigidity and Growth-Rank Classification

## Synthesis

The depth rigidity theorem for generalized tower families opens a new axis of investigation at the intersection of arithmetic circuit complexity, asymptotic majorization theory, and proof-theoretic growth hierarchies. The central insight — that growth-rank separation implies depth separation — converts isolated lower bounds into a classification principle. The five directions below each extend this principle along a different axis: universality of polynomial seeds, robustness under inversion, transfinite indexing, reverse-mathematical calibration, and multivariate generalization.

These directions are interconnected: the universal seed conjecture (Direction 1) provides the foundation, the inverse extension (Direction 2) broadens applicability, the transfinite theory (Direction 3) deepens the proof-theoretic bridge, the reverse-mathematical calibration (Direction 4) quantifies the logical strength of the results, and the multivariate extension (Direction 5) connects to practical algebraic complexity.

---

## Direction 1: Universal Polynomial Seed Rigidity (Grand Challenge)

**Conjecture.** For every polynomial seed p : ℕ → ℕ with p monotone and p(x) ≥ x + 1 eventually, the family defined by T^p₀(x) = p(x), T^p_{n+1}(x) = 2^{T^p_n(x)} is tower-separated and hence depth-rigid.

**Test.** 
1. *Formal test:* Attempt to prove tower separation for seeds p(x) = x + 1 (identity seed, recovering standard iterExp), p(x) = x³ + 1 (cubic seed), and p(x) = 2x + 1 (linear seed). Each case should follow the same inductive argument as the quadratic case, with different polynomial absorption bounds.
2. *Computational test:* Enumerate inverse-free DAGs of depth ≤ 3 over a bounded input domain [0, 100]. For each seed polynomial of degree ≤ 5, compare DAG outputs against T^p_n for n > depth. A single match on sufficiently many inputs suggests a candidate disproof.

**Impact.** Would establish that depth rigidity depends only on the gross structural feature of super-polynomial amplification, not on specific polynomial coefficients. This would be the definitive universality theorem for the growth-separation principle.

**Catalog References.** 
- `Catalog/Pythagorean/DepthRigidity/Theorems.lean`: shiftedTower_separated_step (template for inductive argument)
- `Catalog/Algebra/TightDepthHierarchy/Theorems.lean`: iterExp_poly_lt_iterExp_succ (standard tower absorption)

**Proof Strategy.** Generalize the induction in shiftedTower_separated_step: at each level, bound (C·x^k + C)^{deg(p)} + ... by a new polynomial C'·x^{k·deg(p)} + C', then apply the inductive hypothesis. The key lemma is that polynomial composition is closed under the polynomial majorant class.

**Domain Bridges.** Connects to polynomial dynamics (iteration of polynomial maps) and algebraic complexity theory (polynomial identity testing).

**Lineage.** Directly extends the current work's quadratic seed to arbitrary polynomial seeds.

**Ambition.** ★★★★☆ — Grand challenge. The formal proof requires generalizing over arbitrary polynomial degrees, which introduces significant bookkeeping but no fundamentally new ideas.

---

## Direction 2: Depth Rigidity with Inversion

**Conjecture.** The depth rigidity theorem fails in the full EML model (with inversion): there exists a tower-separated family T and an inversion-including DAG of depth n-1 computing T_n.

**Test.**
1. *Disproof search:* Construct DAGs using the inv node. For example, exp(x) - exp(x-1) = exp(x)(1 - e^{-1}) shows how cancellation can produce exponential functions with unexpected depth. Search for cancellation patterns that reduce apparent depth.
2. *Formal test:* Attempt to prove the noInv_unfoldNode theorem variant for inv-including DAGs. A failure in the majorant bound would indicate where inversions break the argument.

**Impact.** Would precisely delineate the boundary of depth rigidity: inverse-free ↔ depth-rigid, inverse-including ↔ depth-compressible. This distinction has implications for symbolic computation engines that must decide when to allow division.

**Catalog References.**
- `Catalog/Pythagorean/DagDepthHierarchy/Defs.lean`: EMLDag, DagOp.inv
- `Catalog/Algebra/TightDepthHierarchy/Defs.lean`: EMLExpr.noInv predicate

**Proof Strategy.** For the positive direction: show that inv nodes can create cancellations that reduce the effective growth rank. For the negative: construct explicit counterexample DAGs using exp(a)·exp(-b) patterns.

**Domain Bridges.** Connects to differential algebra (the algebraic structure of exp and log) and the Risch integration algorithm (deciding whether elementary antiderivatives exist).

**Lineage.** Extends the current inverse-free restriction to the full EML model.

**Ambition.** ★★★★★ — Paradigm-shifting. Resolving this would fundamentally change our understanding of what makes depth rigidity work.

---

## Direction 3: Transfinite Tower Families and Ordinal Indexing

**Conjecture.** There exists a tower family indexed by ordinals α < ε₀ such that:
1. T_α is tower-separated for all α < β,
2. T_ω(x) corresponds to the Ackermann function (or a primitive-recursive variant),
3. The depth rigidity theorem extends to ordinal-indexed levels.

**Test.**
1. *Formal test:* Define tower families for small transfinite ordinals (ω, ω+1, ω·2) using ordinal recursion in Lean 4. Prove tower separation for ω vs finite levels.
2. *Computational test:* Implement the fast-growing hierarchy for ordinals up to ω² and compare growth rates against candidate transfinite tower families.

**Impact.** Would create a full bridge between arithmetic circuit depth and proof-theoretic ordinal analysis. The ordinal of a function's growth rate would simultaneously determine its minimum circuit depth and the induction strength needed to prove its totality.

**Catalog References.**
- `Catalog/Pythagorean/DepthRigidity/Theorems.lean`: fg_zero_eq_shiftedTower_zero, fg_one_le_shiftedTower_one (finite-level bridge)
- `Catalog/Speculative/HardyHierarchy/Theorems.lean`: (if available, ordinal hierarchy definitions)

**Proof Strategy.** Define T_ω(x) = T_x(x) (diagonalization), then T_{ω+n} by iterating. Tower separation for ω vs finite levels follows from the fact that T_ω eventually dominates any fixed T_n. The depth model needs extension to support ordinal-indexed depth.

**Domain Bridges.** Connects to ordinal analysis, proof theory (Gentzen's consistency proof, Friedman's independence results), and the theory of recursive ordinals.

**Lineage.** Extends the finite-level fast-growing hierarchy bridge to transfinite ordinals.

**Ambition.** ★★★★★ — Grand challenge. Requires formalizing ordinal arithmetic and extending the DAG model to ordinal-indexed depth.

---

## Direction 4: Reverse-Mathematical Calibration

**Conjecture.** The statement "shiftedTower(n) is not computable at depth n-1" is provable in IΣ_n (Σ_n-induction) but not in IΣ_{n-1} for each n ≥ 1.

**Test.**
1. *Formal test:* Formalize the depth rigidity proof for specific n = 1, 2, 3 and verify that only Σ_n-induction is used. Then attempt to show unprovability in IΣ_{n-1} by constructing models where the depth bound fails.
2. *Computational test:* Implement a proof-length analyzer that counts the induction depth used in the Lean proof at each level. Verify that level n uses exactly n-level induction.

**Impact.** Would establish a precise calibration between computational lower bounds and proof-theoretic strength: each additional tower level requires exactly one additional level of induction. This would be a new reverse-mathematical classification theorem.

**Catalog References.**
- `Catalog/Pythagorean/DepthRigidity/Theorems.lean`: depth_lower_bound_of_towerSeparated (the abstract theorem whose proof strength we calibrate)
- `Catalog/Algebra/TightDepthHierarchy/Theorems.lean`: iterExp_poly_lt_iterExp_succ (induction structure)

**Proof Strategy.** For provability in IΣ_n: verify that the tower separation induction at level n uses only Σ_n formulas in its induction hypotheses. For unprovability in IΣ_{n-1}: use indicator arguments or Paris-Harrington style combinatorics to construct models of IΣ_{n-1} where shiftedTower(n) has a spurious depth-(n-1) representation.

**Domain Bridges.** Connects to reverse mathematics (the "Big Five" systems), proof complexity (lengths of proofs), and Friedman's program for independence results.

**Lineage.** Builds on the proof-theoretic bridge (Direction 3) but at the finite level.

**Ambition.** ★★★★☆ — Deep extension. The provability direction is likely tractable; the unprovability direction requires sophisticated model theory.

---

## Direction 5: Multivariate Tower Separation

**Conjecture.** The depth rigidity theorem extends to multivariate tower families F_n : ℕ^k → ℕ, where the tower separation condition becomes: for m < n and any multivariate polynomial P : ℕ^k → ℕ, F_m(P(x₁,...,x_k)) < F_n(x₁,...,x_k) eventually.

**Test.**
1. *Formal test:* Define a bivariate shifted tower: T_0(x,y) = x + y + 1, T_{n+1}(x,y) = 2^{T_n(x²+1, y²+1)}. Prove tower separation in the bivariate case.
2. *Computational test:* Search for bivariate DAGs of depth d that match T_n for n > d on a grid of inputs.

**Impact.** Would extend depth rigidity to functions of multiple variables, applicable to multivariate algebraic complexity (e.g., determinant computation, permanent vs determinant).

**Catalog References.**
- `Catalog/Pythagorean/DepthRigidity/Theorems.lean`: TowerFamily structure (to be generalized)
- `Catalog/Algebra/TightDepthHierarchy/Defs.lean`: EMLExpr.eval (currently univariate)

**Proof Strategy.** Define multivariate monotonicity via componentwise ordering on ℕ^k. The tower separation proof should generalize directly, with polynomials replaced by multivariate polynomials bounded in total degree.

**Domain Bridges.** Connects to algebraic complexity theory (VP vs VNP, tensor rank), computational algebraic geometry, and multilinear algebra.

**Lineage.** Natural generalization of the univariate theory to multiple variables.

**Ambition.** ★★★☆☆ — Solid extension. The mathematical ideas are straightforward generalizations; the formal bookkeeping for multivariate polynomials is the main challenge.
