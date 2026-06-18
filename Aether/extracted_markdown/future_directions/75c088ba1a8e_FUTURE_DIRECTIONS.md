# Future Directions: Tropical Brill–Noether Theory

## Overview

This document presents five falsifiable hypotheses emerging from the formalization of tropical Brill–Noether theory. Each conjecture is precise enough to be tested computationally or proved/disproved mathematically.

---

## Conjecture 1: Lattice Path Witness Count Polynomiality

**Precise Statement.** For fixed genus $g$ and rank $r$, define $W(g, r, d)$ as the number of admissible lingering lattice paths on a generic chain of $g$ loops at degree $d$. Then there exists a polynomial $P_{g,r} \in \mathbb{Q}[d]$ and an integer $N_{g,r}$ such that for all $d \geq N_{g,r}$,

$$W(g, r, d) = P_{g,r}(d),$$

and $\deg P_{g,r} = \rho(g, r, d) = g - (r+1)(g - d + r)$ evaluated symbolically.

**Test.** Enumerate all admissible lattice paths for $g \in \{2,3,4,5\}$, $r \in \{1,2\}$, and $d$ ranging from $0$ to $30$. Fit polynomial models to $W(g,r,d)$ for $d$ beyond the stabilization point. Check whether:
- The fitted polynomial has rational coefficients.
- The degree matches the symbolic expression for $\rho$.
- No counterexample exists up to $d = 50$.

**Refutation criterion.** A single pair $(g,r)$ where $W(g,r,d)$ is not eventually polynomial, or where the degree does not match $\rho$, would refute the conjecture.

**Impact if true.** This would give a closed-form formula for the size of the Brill–Noether locus in the tropical setting, analogous to the dimension formula in algebraic geometry. It would also provide an efficient algorithm for counting tropical linear series.

---

## Conjecture 2: Specialization Strictness for Non-Generic Curves

**Precise Statement.** There exists a family of algebraic curves $\{C_t\}_{t \in \mathbb{C}^*}$ of genus $g = 4$ such that for the generic fiber, the tropicalization $\operatorname{trop}(C_t)$ satisfies Baker's specialization with equality:

$$\operatorname{rank}_{\operatorname{trop}(C_t)}(\operatorname{trop}(D)) = \operatorname{rank}_{C_t}(D)$$

for all divisors $D$ of degree $d \leq 2g - 2$, but for a special fiber $C_0$, strict inequality

$$\operatorname{rank}_{\operatorname{trop}(C_0)}(\operatorname{trop}(D)) > \operatorname{rank}_{C_0}(D)$$

holds for some divisor $D$.

**Test.** Construct explicit families of genus-4 curves degenerating to a chain of loops. Compute divisor ranks on both the algebraic and tropical sides for a set of divisors using:
- Riemann–Roch on the algebraic curve (via computational algebra systems).
- Dhar's burning algorithm on the tropical curve.

Compare ranks and search for gaps.

**Refutation criterion.** If for every constructible family of genus-4 curves, specialization is always an equality for divisors of degree ≤ 6, the conjecture would be refuted.

**Impact if true.** This would identify a precise geometric mechanism for specialization drop, potentially leading to refined specialization lemmas that track exactness conditions.

---

## Conjecture 3: Tropical Matrix Rank Certificate for Divisor Existence

**Precise Statement.** For a generic chain of loops $\Gamma$ of genus $g$, there exists a canonically associated $(r+1) \times (g - d + 2r + 1)$ tropical matrix $M(\Gamma, d, r)$ (whose entries are linear combinations of edge lengths) such that:

$$\text{ExistsDivisorOfDegreeRank}(\Gamma, d, r) \iff \operatorname{trop.rank}(M(\Gamma, d, r)) \leq r.$$

**Test.** For generic chains of loops with $g \in \{3, 4, 5\}$:
1. Build candidate matrices $M(\Gamma, d, r)$ from the chip-firing constraints.
2. Compute tropical rank using the Develin–Santos–Sturmfels algorithm.
3. Compare with brute-force divisor rank computation via Dhar's algorithm.
4. Check equivalence for all $(d, r)$ with $0 \leq r \leq 3$ and $0 \leq d \leq 2g$.

**Refutation criterion.** A single instance where the tropical rank condition disagrees with divisor existence would refute the conjecture.

**Impact if true.** This would provide a polynomial-time certificate for tropical divisor existence, connecting tropical linear algebra (factor rank, tropical rank) directly to Brill–Noether theory. It would also connect our formalized `tropFactorRank_bound_via_tropical_rank` results to divisor theory.

---

## Conjecture 4: Recognizability of Admissible Divisor Languages

**Precise Statement.** Fix a generic chain of loops $\Gamma$ of genus $g$ and parameters $(d, r)$. Define the *chip-firing language* $\mathcal{L}(\Gamma, d, r)$ as the set of sequences of chip-firing moves (elements of $\{1, \ldots, g+1\}^*$) that transform the canonical divisor into an effective divisor of degree $d$ and rank $\geq r$. Then $\mathcal{L}(\Gamma, d, r)$ is a regular language (recognizable by a finite automaton).

**Test.**
1. For $g \in \{2, 3\}$ and small $(d, r)$, enumerate all chip-firing sequences up to length $4g$.
2. Apply the Myhill–Nerode theorem: compute equivalence classes of sequences under the relation "same future behavior."
3. Check if the number of equivalence classes is finite.
4. If finite, construct the minimal DFA and verify closure under the predicted operations.

**Refutation criterion.** If for some $(g, d, r)$ the number of Myhill–Nerode equivalence classes grows without bound as sequence length increases, the language is not regular.

**Impact if true.** This would create an unexpected bridge between tropical geometry and automata theory, potentially connecting to `tropical_formula_iff_recognizable_and_deriv_closed`. It could lead to algorithmic decidability results for tropical linear series existence via automata-theoretic methods.

---

## Conjecture 5: Tropical Brill–Noether for Arbitrary Trivalent Graphs

**Precise Statement.** Let $G$ be a 3-regular (trivalent) graph with first Betti number $g$, equipped with generic edge lengths (all pairwise distinct). Then:

$$\text{ExistsDivisorOfDegreeRank}(G, d, r) \iff \rho(g, r, d) \geq 0$$

whenever $r \leq g/3$.

**Test.**
1. Enumerate all trivalent graphs with $g \leq 7$ (up to isomorphism).
2. Assign random generic edge lengths.
3. Compute divisor ranks for all $(d, r)$ with $r \leq g/3$ using Dhar's algorithm.
4. Check whether the Brill–Noether theorem holds for each graph.

**Refutation criterion.** A single trivalent graph with generic edge lengths where divisor existence disagrees with the sign of $\rho$ (for $r \leq g/3$) would refute the conjecture.

**Impact if true.** This would extend the Cools–Draisma–Payne–Robeva result beyond chains of loops to a much broader class of tropical curves, covering a dense subset of the moduli space of tropical curves. It would be a major step toward the full tropical Brill–Noether theorem for arbitrary metric graphs.

---

## Formalization Priorities

For the next research cycle, we recommend:

1. **Highest priority**: Formalize the lattice path criterion for chains of loops (Conjecture 1). This is the most tractable and would complete the sufficiency direction of our Brill–Noether package.

2. **High priority**: Formalize Baker's specialization lemma as a concrete instance of `SpecializesRankNondecreasing`, connecting to the existing `Tropicalization` interface.

3. **Medium priority**: Implement the tropical matrix certificate (Conjecture 3) and connect to existing tropical rank results in the catalog.

4. **Exploratory**: Investigate the automata-theoretic conjecture (Conjecture 4) computationally before attempting formalization.
