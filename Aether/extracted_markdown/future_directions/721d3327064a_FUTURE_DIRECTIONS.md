# Future Directions: Local-Global Geometry of Sums of Three Cubes

## Synthesis

The formalization developed here establishes the first layer of a local-global architecture for the Diophantine surface $x^3+y^3+z^3 = k$: local obstructions, symmetry reductions, the global-to-local implication, and a factorization-based search algorithm. These form a coherent foundation, but the deepest questions—Why does the Hasse principle appear to hold? What structure underlies the enormous solutions for small $k$?—remain open. The directions below form a **progressive deepening** of the framework: Direction 1 attacks the gap between local and global from the cohomological side, Direction 2 connects to analytic density predictions, Direction 3 bridges to computational complexity, Direction 4 exploits parametric families, and Direction 5 pushes toward a general Diophantine surface theory. Each builds directly on the catalog theorems proved here.

---

## Direction 1: Brauer-Manin Obstructions for Integral Points on Cubic Surfaces

**Conjecture:** For the cubic surface $X_k : x^3+y^3+z^3 = k$, the Brauer-Manin obstruction is the only obstruction to the integral Hasse principle. That is, if $k$ is everywhere locally admissible and survives the Brauer-Manin filtration, then $k$ is representable.

**Test:** Compute the Brauer group $\text{Br}(X_k)/\text{Br}(\mathbb{Q})$ for specific $k$ values (e.g., $k = 33, 42, 114$) and verify that the Brauer-Manin set $X_k(\mathbb{A}_\mathbb{Z})^{\text{Br}}$ is nonempty whenever solutions exist. A counterexample would be a $k$ with nonempty Brauer-Manin set but no integral point.

**Impact:** This would establish the three-cubes problem as a test case for the Colliot-Thélène conjecture on integral points, one of the central open problems in arithmetic geometry. It would also provide the first formal connection between computational Diophantine search and cohomological obstructions.

**The key insight is** that the mod 9 obstruction we formalized is the shadow of a Brauer class at the prime 3, and the general Brauer-Manin framework subsumes all such modular obstructions into a single cohomological invariant.

**Why now?** The formal infrastructure for local admissibility (`ThreeCubeLocalAdmissible`, `EverywhereLocallyAdmissible`) created in this cycle provides the precise definitions needed to state and test Brauer-Manin predictions. Mathlib's growing étale cohomology library makes partial formalization feasible.

**Catalog References:** `sumThreeCubesRep_implies_everywhereLocallyAdmissible` (Algebra/SumThreeCubes/LocalGlobal.lean), `not_threeCubeLocalAdmissible_mod9_of_eq_four_or_five` (Algebra/SumThreeCubes/LocalObstruction.lean)

**Proof Strategy:** Formalize the Brauer group of a smooth cubic surface over $\mathbb{Q}$, compute generators via Azumaya algebras, and evaluate the Brauer-Manin pairing at each completion of $\mathbb{Q}$.

**Domain Bridges:** Arithmetic geometry, étale cohomology, class field theory

**Lineage:** Extends the local-global implication (Theorem 4) from modular arithmetic to cohomological invariants

**Ambition:** Grand challenge — would resolve a major case of the integral Hasse principle

---

## Direction 2: Density Heuristics via the Circle Method

**Conjecture:** For each admissible $k$ (i.e., $k \not\equiv 4,5 \pmod{9}$), the number of representations $|\{(x,y,z) \in [-N,N]^3 : x^3+y^3+z^3 = k\}|$ grows as $c_k \cdot N^{1/3}$ for an explicit constant $c_k > 0$ depending on the singular series and singular integral.

**Test:** Compute empirical counts of representations for $k \in \{0, 1, 2, 3, 6, 7, 8, 9\}$ up to $N = 10^6$ and compare with the predicted asymptotic. Measure the relative error $|R(N) - c_k N^{1/3}| / (c_k N^{1/3})$ and verify it decreases with $N$.

**Impact:** Would provide the first formally grounded connection between the combinatorial/algebraic framework and analytic number theory. The singular series in the density prediction is a product of local densities, directly connecting to our `ThreeCubeLocalAdmissible` counts.

**The key insight is** that the local admissibility counts $|A_n|/n$ at each modulus $n$ are the local factors of the singular series, and the everywhere-local-admissibility theorem guarantees this product converges when $k$ is admissible.

**Why now?** The formal definitions of local admissibility and the computational infrastructure for counting admissible residues provide the exact data needed to compute singular series factors and compare with empirical density.

**Catalog References:** `ThreeCubeLocalAdmissible` (Algebra/SumThreeCubes/Defs.lean), `sumThreeCubesRep_implies_everywhereLocallyAdmissible` (Algebra/SumThreeCubes/LocalGlobal.lean)

**Proof Strategy:** Formalize the circle method setup for cubic forms, compute the singular integral, and bound the minor arc contributions.

**Domain Bridges:** Analytic number theory, harmonic analysis, probability theory

**Lineage:** Connects the discrete local admissibility framework to continuous density predictions

**Ambition:** Solid extension — the circle method for three cubes is at the boundary of current analytic technique

---

## Direction 3: Computational Complexity of Diophantine Search

**Conjecture:** The factorization-based search algorithm (exploiting $x^3+y^3 = (x+y)(x^2-xy+y^2)$) achieves time complexity $O(B^{1+\epsilon})$ for search bound $B$, compared to $O(B^3)$ for brute force. Furthermore, lattice reduction methods can improve this to $O(B^{2/3+\epsilon})$ by exploiting the geometry of the cubic surface.

**Test:** Implement the lattice reduction approach (as used by Booker-Sutherland) and formally verify its correctness relative to the factorization theorem. Measure empirical running times and compare with the theoretical bounds.

**Impact:** Would establish a formal connection between algebraic structure (the sum-of-cubes factorization) and computational complexity, showing that algebraic identities yield provable speedups in Diophantine search.

**The key insight is** that the factorization reduction theorem `sumThreeCubesRep_iff_exists_factorization` transforms a 3D search into a 1D search plus a factorization problem, and this dimensional reduction has precise complexity implications.

**Why now?** The formal factorization theorem and discriminant relation provide the mathematical foundation for analyzing the algorithm's correctness and complexity within a verified framework.

**Catalog References:** `sumThreeCubesRep_iff_exists_factorization` (Algebra/SumThreeCubes/Factorization.lean), `factorization_discriminant` (Algebra/SumThreeCubes/Factorization.lean)

**Proof Strategy:** Formalize the LLL lattice reduction algorithm, connect lattice vectors to solutions of the cubic equation, and verify the complexity bounds.

**Domain Bridges:** Computational complexity, lattice algorithms, algorithmic number theory

**Lineage:** Extends the factorization reduction from algebraic identity to complexity-theoretic tool

**Ambition:** Solid extension — combines formal verification with algorithm analysis

---

## Direction 4: Parametric Families and Algebraic Curves on Cubic Surfaces

**Conjecture:** The parametric family $k = -3ab(a+b)$ (from `sum_three_cubes_neg_sum`) covers a positive density of admissible integers. More precisely, $|\{k \in [1,N] : k = 3ab(a+b) \text{ for some } a,b \in \mathbb{Z}\}| \gg N^{2/3}$.

**Test:** Enumerate all values of $-3ab(a+b)$ for $|a|, |b| \leq 1000$ and measure the density of covered integers in $[1, 10^6]$. Compare with the predicted $N^{2/3}$ growth.

**Impact:** Parametric families correspond to **algebraic curves** on the cubic surface. Understanding which curves pass through integer points, and how densely they cover the integers, connects Diophantine approximation to the geometry of rational curves on cubic surfaces.

**The key insight is** that each parametric identity for sums of three cubes corresponds to a rational curve on $X_k$ parametrized over $\mathbb{Z}$, and the union of all such curves determines a "constructively representable" subset whose density is a geometric invariant.

**Why now?** The formal proof of `sumThreeCubesRep_neg_iff` and the identity $a^3 + b^3 + (-a-b)^3 = -3ab(a+b)$ provide the first verified parametric family, which can be used as a template for formalizing others.

**Catalog References:** `sumThreeCubesRep_neg_iff` (Algebra/SumThreeCubes/Symmetry.lean), `sum_three_cubes_neg_sum` (Catalog/Algebra/LocalGlobal.lean)

**Proof Strategy:** Enumerate known parametric families, compute their images, and prove density bounds using sieve methods.

**Domain Bridges:** Algebraic geometry (rational curves on surfaces), sieve theory, additive combinatorics

**Lineage:** Extends sign symmetry to full parametric family analysis

**Ambition:** Solid extension — combines known identities with density estimation

---

## Direction 5: Generalization to Higher-Degree Diagonal Surfaces

**Conjecture (Waring-type local-global):** For the equation $x_1^n + x_2^n + \cdots + x_s^n = k$ with $s$ sufficiently large relative to $n$, the only local obstructions arise from $n$-th power residue conditions at primes dividing $n$, analogous to the mod-9 obstruction for $n=3, s=3$.

**Test:** Compute local admissible sets for $x^4+y^4+z^4+w^4 = k$ modulo all $n \leq 100$ and identify the obstructing moduli. Compare with the predicted pattern (obstructions only at powers of 2 and primes $p \equiv 1 \pmod{4}$).

**Impact:** Would establish a general theory of local obstructions for Waring-type problems, unifying the three-cubes result with classical results on sums of squares, biquadrates, and higher powers.

**The key insight is** that our framework—local admissibility, everywhere local admissibility, the global-to-local implication—generalizes verbatim to $x_1^n + \cdots + x_s^n = k$ by replacing cubes with $n$-th powers, and the new obstructions reflect the arithmetic of $n$-th power residues.

**Why now?** The Lean definitions `ThreeCubeLocalAdmissible` and `EverywhereLocallyAdmissible` are parametric in the modulus and can be straightforwardly generalized to arbitrary degree, making this the natural next step.

**Catalog References:** All definitions in `Algebra/SumThreeCubes/Defs.lean`, the obstruction framework in `Algebra/SumThreeCubes/LocalObstruction.lean`

**Proof Strategy:** Generalize definitions to $n$-th powers, classify $n$-th power residues modulo prime powers, and prove the analogue of Theorem 4 (global implies local) for general degree.

**Domain Bridges:** Waring's problem, algebraic number theory ($n$-th power reciprocity), analytic number theory (circle method for higher powers)

**Lineage:** Direct generalization of the entire framework from degree 3 to degree $n$

**Ambition:** Grand challenge — would create a unified formal theory of local obstructions for additive Diophantine problems
