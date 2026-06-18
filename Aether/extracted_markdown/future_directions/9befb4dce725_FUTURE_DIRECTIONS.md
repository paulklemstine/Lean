# Future Directions: Contraction Dynamics of Evaluation Strategies

## Synthesis

The contraction dynamics framework established here — proving that leftmost-outermost evaluation is a dissipative flow on β-equivalence classes — opens a new bridge between rewriting theory, metric fixed-point theory, and quantitative program semantics. The five directions below form a coherent research program: Direction 1 deepens the contraction theory by seeking uniform constants for restricted type systems; Direction 2 extends the framework to parallel/multi-step reductions; Direction 3 connects to the practical world of compiler optimization via equality saturation; Direction 4 investigates the computability frontier of head-alignment; and Direction 5 proposes the grand challenge of a quantitative Church-Rosser theorem. Together, they aim to establish "computational dynamics" as a recognized subfield at the intersection of lambda calculus, metric geometry, and dynamical systems.

---

## Direction 1: Uniform Contraction for Rank-1 Types

**Conjecture:** For rank-1 simply-typed lambda terms (all types have arrow depth ≤ 1), there exists a universal contraction constant c < 1 such that for ALL β-equivalent pairs (t, u) with loStep reducts (t', u'), we have eqPathDist(t', u') ≤ c · eqPathDist(t, u).

**Test:** Enumerate all rank-1 simply-typed terms up to size 12 with types of depth ≤ 1. Compute eqPathDist for all β-equivalent pairs and their LO reducts. If any pair has ratio ≥ 1, the conjecture is false. Record the maximum observed ratio — the conjecture predicts this is bounded away from 1.

**Impact:** If true, this would give the first uniform Banach contraction for lambda calculus evaluation, implying exponential convergence to normal forms and Banach-theorem uniqueness of fixed points. If false, the counterexample would precisely identify the type-theoretic boundary of contractivity.

**Catalog References:** `Catalog/Pythagorean/ContractionDynamics.lean` (eqPathDist_contracts_on_shell), `Catalog/Pythagorean/STLCDefs.lean` (typing judgments, Ty.depth), `Catalog/Pythagorean/NormalizationBisimDistance.lean` (eqPathDist pseudometric)

**Proof Strategy:** Induction on type depth. At rank 1, all β-redexes have ground-type arguments, which limits the substitution blowup. Show that the eqPathDist chain length is bounded by a function of term size (not just type complexity), then derive a uniform contraction constant from this size bound.

**Domain Bridges:** Banach fixed-point theory → type theory → compiler optimization convergence rates

**Lineage:** Extends eqPathDist_contracts_on_shell from shell-wise to uniform contraction; uses Ty.depth from STLCDefs.lean

**Ambition:** Grand Challenge — would establish the first uniform contraction mapping theorem for any programming language evaluation strategy

---

## Direction 2: Parallel β-Reduction and Multi-Step Contraction

**Conjecture:** For Takahashi's parallel β-reduction (contracting all redexes simultaneously), the contraction constant on bounded shells improves to at most (R − k)/R where k is the number of simultaneously contracted redexes.

**Test:** Implement parallel β-reduction for terms up to size 10. For each β-equivalent pair, compute the distance before and after one parallel step. Verify whether the ratio is bounded by (R − k)/R where k is the parallelism degree.

**Impact:** Would extend the contraction dynamics framework to parallel evaluation strategies, relevant to GPU-based program transformation and massively parallel proof normalization.

**Catalog References:** `Catalog/Pythagorean/ContractionDynamics.lean` (loStep, eqPathDist_contracts_on_shell), `Catalog/Pythagorean/BoundedBetaDefs.lean` (BetaStep, ReachableWithin)

**Proof Strategy:** Define parallel_step as the simultaneous contraction of all non-overlapping redexes. Show that each contracted redex contributes an independent distance decrease of 1, using the context nonexpansiveness lemmas (eqPathDist_app_left_le, eqPathDist_app_right_le, eqPathDist_lam_le) to decompose the global decrease into local contributions.

**Domain Bridges:** Parallel algorithms → rewriting theory → GPGPU compiler optimization

**Lineage:** Builds on the single-step contraction theorem; extends to multi-step via Takahashi's parallel reduction (1995)

**Ambition:** Solid extension — natural next step with clear proof strategy

---

## Direction 3: Equality Saturation Convergence via Contraction Dynamics

**Conjecture:** The e-graph saturation process in equality saturation (Willsey et al., 2021) converges at a rate bounded by the shell-wise contraction constants when the rewrite rules correspond to β-reduction and expansion.

**Test:** Implement a miniature equality saturation engine for lambda terms. Track the e-graph size and internal distance metrics over saturation iterations. Compare observed convergence rates to the predicted (R−1)/R bounds.

**Impact:** Would provide the first theoretical convergence guarantees for equality saturation, connecting the practical optimization technique to the formal contraction dynamics framework.

**Catalog References:** `Catalog/Pythagorean/ContractionDynamics.lean` (contractionDefect, eqPathDist_contracts_on_shell), `Catalog/Pythagorean/NormalizationBisimDistance.lean` (eqPathDist_triangle, context nonexpansiveness)

**Proof Strategy:** Model the e-graph as a quotient of the term space under the equivalence relation maintained by the e-graph. Show that each saturation step (adding a rewrite) monotonically decreases the maximum eqPathDist within each equivalence class, using the contraction defect bound.

**Domain Bridges:** Compiler optimization → rewriting theory → metric geometry

**Lineage:** Extends contractionDefect_le_two to multi-step saturation processes

**Ambition:** Solid extension — high practical relevance, connects formal theory to industrial tools

---

## Direction 4: Decidability of Head-Alignment

**Conjecture:** For simply-typed lambda terms, the predicate HeadAligned(t, u) is decidable, and there exists a polynomial-time algorithm to determine whether a pair is head-aligned.

**Test:** Implement a candidate decision procedure based on type-directed search. Test on all simply-typed pairs up to size 10. Verify completeness by cross-checking against brute-force enumeration of all one-step reducts and distance computations.

**Impact:** Would make the contraction dynamics framework fully constructive and executable, enabling automated certification of contraction properties for compiler passes.

**Catalog References:** `Catalog/Pythagorean/ContractionDynamics.lean` (HeadAligned, exists_betaStep_lyapunov_decrease), `Catalog/Pythagorean/STLCDefs.lean` (HasType, TypedLam)

**Proof Strategy:** For simply-typed terms, the reduction graph is finite (strong normalization). Show that HeadAligned(t, u) can be decided by: (1) computing the reduction graph of t (finite by SN), (2) for each one-step reduct t', computing eqPathDist(t', u) via the finite β-equivalence graph, (3) checking whether any t' achieves the bound.

**Domain Bridges:** Computability theory → type theory → automated verification

**Lineage:** Depends on HeadAligned definition and SN_of_normalForm from STLCDefs.lean

**Ambition:** Solid extension — fills an important gap in the theory's constructivity

---

## Direction 5: Quantitative Church-Rosser via Contraction Geometry

**Conjecture:** For β-equivalent terms t, u with eqPathDist(t, u) = d, the joinability budget (minimum total steps for both sides to reach a common reduct) is at most ⌈d/2⌉ · (⌈d/2⌉ + 1) / 2. Moreover, this bound is tight for some family of terms.

**Test:** Enumerate all β-equivalent pairs up to size 12. For each pair, compute both eqPathDist and the minimum joinability budget (via BFS on the reduction graph). Plot joinability budget vs eqPathDist and fit the conjectured quadratic bound.

**Impact:** This would be a quantitative Church-Rosser theorem — not just "confluent" but "confluent within a computable budget." It would give the first tight relationship between the equivalence-path metric and the join metric, founding a "computational geometry of confluence."

**Catalog References:** `Catalog/Pythagorean/NormalizationBisimDistance.lean` (eqPathDist_le_of_joinBudget, JoinBudgetBound), `Catalog/Pythagorean/ContractionDynamics.lean` (eqPathDist_loIter_decrease), `Catalog/Pythagorean/ChurchRosser.lean` (if it exists)

**Proof Strategy:** Use the iterated convergence theorem to bound the join budget: if each LO step decreases eqPathDist by 1 (head-aligned case), then after d/2 steps from each side, both reach terms within distance 0. The quadratic factor arises from the possibility that head-alignment fails at some steps, requiring detours bounded by the 2-Lipschitz bound.

**Domain Bridges:** Proof theory → metric geometry → automated theorem proving

**Lineage:** Combines eqPathDist_le_of_joinBudget with eqPathDist_loIter_decrease

**Ambition:** Grand Challenge — would unify confluence theory with metric rewriting in a quantitatively precise way
