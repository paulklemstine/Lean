# Future Directions: EML Differential Equation Obstruction Theory

## Synthesis

This cycle extended the formal polynomial obstruction theory for ODE solvability in two directions: higher-order generalizations and Riccati parity obstructions. The original cycle established that no nonzero polynomial satisfies Airy's equation y″ = xy (degree mismatch) and the associated Riccati equation v' + v² = X (degree parity). We generalized the first result to y^(k) = q·y for arbitrary order k ≥ 1 and arbitrary polynomial coefficient q with deg(q) ≥ 1, and the second to v' + v² = q for any q with odd degree. We also strengthened the Wronskian derivative-zero result to full constancy over ℝ[X].

A key negative finding was that the `reconstructFromStableHankel` theorem in `Bridges/AlgebraEMLComputation/Theorems.lean` was **false as stated**: the finite-window stability hypothesis `ClosureHankelRankStableOn cl B P Q` is trivially satisfied with empty P, Q, but not all behaviors admit finite realizations. We commented out the false statement and provided a corrected version (`reconstructFromGlobalHankelRank`) using the proper global hypothesis `FiniteClosureHankelRank`.

The structural insight from this cycle: polynomial obstructions to ODE solvability decompose cleanly into two orthogonal mechanisms — **degree mismatch** (the k-th derivative has degree too low) and **parity obstruction** (the Riccati square forces even degree). Both mechanisms are independently sufficient for impossibility, and together they cover a wide class of coefficient polynomials q.

## Results Summary

- `higher_order_poly_obstruction`: **proved** — No nonzero polynomial satisfies y^(k) = q·y for k ≥ 1 and deg(q) ≥ 1; generalizes the Airy obstruction to all higher-order linear ODEs with polynomial coefficients
- `no_poly_solves_riccati_odd_deg`: **proved** — No polynomial solves v' + v² = q when q has odd degree ≥ 1; captures parity obstruction independent of degree mismatch
- `natDegree_deriv_add_sq`: **proved** — Auxiliary: for deg(v) ≥ 1, deg(v' + v²) = 2·deg(v); key lemma for Riccati arguments
- `poly_wronskian_is_constant`: **proved** — Wronskian of two polynomial solutions to y″ = q·y is constant; strengthens derivative-zero to full constancy
- `no_poly_solves_riccati_airy'`: **proved** — Recovers original Airy Riccati obstruction as corollary of odd-degree result
- `reconstructFromGlobalHankelRank`: **proved** — Corrected reconstruction theorem with proper global Hankel rank hypothesis
- `reconstructFromStableHankel`: **disproved** — Original statement false; finite-window stability insufficient for global realization

## Research Directions

### Direction 1: Riccati obstruction for even-degree coefficients with non-square leading coefficient

**Hypothesis**: For polynomial q with even degree d and leading coefficient a_d < 0, no polynomial satisfies v' + v² = q. More precisely, if v' + v² = q with deg(v) = d/2, then the leading coefficient of v² must equal a_d, but no real number squares to a negative value.

**Test**: Formalize the leading coefficient comparison: if v' + v² = q with deg(q) = 2n, then the leading coefficient of v must satisfy lc(v)² = lc(q). Prove no_poly_solves_riccati_neg_leading (q : Polynomial ℝ) (heven : Even q.natDegree) (hneg : q.leadingCoeff < 0) (v : Polynomial ℝ) (heq : derivative v + v * v = q) : False.

**Why now**: The `natDegree_deriv_add_sq` lemma already establishes the degree arithmetic; extending to leading coefficient comparison is the natural next step.

**If true**: Combined with the odd-degree result, this would give: no polynomial Riccati solution whenever deg(q) is odd OR lc(q) < 0, covering most interesting cases.

**If false**: Would reveal that some even-degree polynomials with negative leading coefficient DO admit polynomial Riccati solutions, which would be surprising and worth investigating.

### Direction 2: Rational function obstruction for Airy's equation

**Hypothesis**: No nonzero rational function p/q (with p, q ∈ ℝ[X], q ≠ 0) satisfies y″ = xy in the fraction field of ℝ[X]. This extends the polynomial obstruction to the broader class of rational functions.

**Test**: Formalize the statement in terms of the fraction field FractionRing (Polynomial ℝ). The key insight is that if p/q satisfies y″ = xy, then p·q satisfies a related polynomial ODE whose degree structure forces a contradiction. Specifically, y = p/q gives y″ = (p″q² - 2p'q'q + 2p(q')² - pq″q) / q³, and setting this equal to x·p/q gives a polynomial equation that can be analyzed by degree.

**Why now**: The polynomial case is fully settled, and the Wronskian constancy theorem provides tools for analyzing pairs of solutions in ℝ[X]. The fraction field generalization is the natural algebraic extension.

**If true**: Would establish that Airy's equation has no algebraic solution over ℝ(x), which is a key step toward the full differential Galois theory result.

**If false**: Would be extremely surprising and would likely indicate a gap in the classical theory.

### Direction 3: Certified finite-window reconstruction with completeness hypothesis

**Hypothesis**: If `ClosureHankelRankStableOn cl B P Q` holds AND P is "prefix-complete" (contains all words of length ≤ N for some N ≥ rank) AND Q is "suffix-complete" (contains all words of length ≤ M for some M ≥ rank), then the global realization exists.

**Test**: Define `PrefixComplete P N := ∀ w, w.length ≤ N → w ∈ P` and state the theorem with these additional hypotheses. The key insight is that prefix-completeness ensures every Hankel row can be expressed via the generator rows (by induction on word length), and suffix-completeness ensures the coefficient equations determined on Q extend to all suffixes (by polynomial identity / overdetermined system arguments).

**Why now**: We identified the exact failure point of the original theorem: finite-window stability is vacuous without coverage assumptions. Adding explicit coverage conditions is the minimal fix.

**If true**: Would give a constructive algorithm: enumerate words up to length N+M, check stability, extract realization.

**If false**: Would show that even with coverage, the finite-to-infinite extension requires additional structure (perhaps semiring-specific properties beyond the closure axioms).

### Direction 4: Iterated Riccati tower and differential Galois group

**Hypothesis**: For the generalized Airy equation y″ = x^n · y, the associated Riccati tower (v₁ = y'/y, v₂ = v₁'/v₁, ...) has no polynomial solution at any level, for any n ≥ 1. This would formalize the algebraic independence of Airy-type functions at all derivative levels.

**Test**: Define the k-th Riccati transform recursively: R₀(q) = q (the ODE y″ = q·y), R₁(q) = v' + v² = q, R₂(q) = the Riccati equation for v₁'/v₁, etc. Prove by induction on k that no polynomial satisfies the k-th equation. The key insight is that each Riccati transform preserves (or increases) the "obstruction degree," so the parity/degree arguments propagate up the tower.

**Why now**: Both the degree-mismatch and parity obstructions are established. The Riccati tower is the natural algebraic structure connecting these to differential Galois theory, where the Galois group of Airy's equation is SL₂(ℂ).

**If true**: Would give a complete algebraic obstruction hierarchy, connecting polynomial ring theory to differential Galois theory within Lean.

**If false**: Would identify the exact level at which polynomial obstructions fail, pointing to the need for transcendental (analytic) methods.

### Direction 5: Polynomial obstruction for systems of ODEs

**Hypothesis**: For the system Y' = A(x)·Y where A(x) is a matrix with polynomial entries of positive degree, no nonzero polynomial vector Y satisfies the system. This generalizes the scalar case y″ = q·y (which can be written as a first-order system [y, y']' = [[0,1],[q,0]] · [y, y']).

**Test**: Formalize matrix polynomial ODE systems over ℝ[X] and prove the degree obstruction for the system case. The key insight is that the degree mismatch argument works component-wise: the derivative of a polynomial vector has degree ≤ deg - 1 in each component, while multiplication by a matrix with polynomial entries increases degree. The proof should use `Polynomial.natDegree_iterate_derivative` applied to each component.

**Why now**: The scalar higher-order case `y^(k) = q·y` is proved, and the first-order matrix formulation is a standard reduction. Formalizing the system case would connect the obstruction theory to the broader theory of linear algebraic groups and D-modules.

**If true**: Would provide a uniform framework for polynomial impossibility results across all linear ODE systems with polynomial coefficients.

**If false**: Would identify specific matrix structures that admit polynomial solutions (e.g., nilpotent coefficient matrices), which would be interesting in their own right.
