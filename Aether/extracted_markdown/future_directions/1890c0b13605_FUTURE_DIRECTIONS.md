# Future Directions: Tropical Brill–Noether Theory

## Conjecture 1: Crystal Model Hypothesis

**Conjecture:** For each r ≥ 0, the set of valid CDPR paths for parameters (g, r, d) carries the structure of a crystal graph for the representation V(λ) of sl_{r+1}, where λ is determined by (g, d, r). Specifically, there exists a bijection between CDPR paths and vertices of a restricted Littelmann path model that is compatible with the crystal operators e_j, f_j.

**Test:** For r ≤ 3 and g ≤ 8, construct the explicit crystal operators on the set of CDPR paths and verify that they satisfy the Kashiwara axioms. Compare the resulting crystal graph with the Littelmann path crystal for the corresponding highest weight. Check that the character of the crystal matches the number of CDPR paths.

**What would refute it:** If the CDPR path set for some (g, r, d) has a cardinality that does not match any crystal graph character for sl_{r+1}, the conjecture is false. Alternatively, if the natural candidate operators fail the Sternberg/Kashiwara axioms, the conjecture needs modification.

**Impact if true:** This would establish a direct formal link between tropical Brill–Noether theory and quantum group combinatorics. It would imply that divisor class counts on chains of loops are given by Kostka numbers or their generalizations, making tropical enumerative geometry computable via the Robinson–Schensted–Knuth correspondence.

---

## Conjecture 2: Tropical Rank Bound Hypothesis

**Conjecture:** For a reduced divisor D of degree d on a chain of g loops, define the chip-distance matrix M(D) ∈ ℤ^{(g+1)×(g+1)} by M(D)_{ij} = minimum total chip movement to make D − (vertex i effective divisor) equivalent to an effective divisor concentrated near vertex j. Then:

$$\text{bakerNorineRank}(D) \leq \text{tropicalRank}(M(D))$$

where tropicalRank is the Barvinok/Develin–Santos–Sturmfels tropical rank (minimum r such that M can be written as a tropical sum of r rank-1 tropical matrices).

**Test:** Compute both sides exhaustively for all reduced divisors on chains of loops with g ≤ 6 and d ≤ 2g. If a counterexample is found, test modifications: (a) restrict to v₀-reduced divisors only, (b) add an additive constant C_r depending on the rank, (c) use the Kapranov rank instead of Barvinok rank.

**What would refute it:** An explicit divisor D with bakerNorineRank(D) > tropicalRank(M(D)). The smallest such counterexample would be valuable for identifying which tropical linear algebra invariant correctly bounds Baker–Norine rank.

**Impact if true:** This would connect chip-firing rank to tropical linear algebra, enabling rank computation via tropical matrix factorization algorithms. It would also open a route to proving tropical Brill–Noether via min-plus linear algebra rather than lattice paths.

---

## Conjecture 3: Metric Independence Threshold

**Conjecture:** For the chain of loops graph with *any* assignment of positive real edge lengths, the existence of a rank-r degree-d divisor depends only on the sign of ρ(g,r,d) — not on the specific edge lengths. That is, the *existence* half of the CDPR theorem is metric-free: it holds for all metric chains, not just generic ones.

**Test:** For g ≤ 6, r ≤ 3, and d ≤ 2g, compute the set of metric chains (parameterized by edge lengths) that admit a rank-r degree-d divisor. Check whether this set is either empty or the entire parameter space, matching the sign of ρ.

**What would refute it:** Specific edge lengths (l₁, ..., l_g) for the chain of g loops such that a rank-r degree-d divisor exists despite ρ < 0, or fails to exist despite ρ ≥ 0. The CDPR paper shows existence for *generic* edge lengths when ρ ≥ 0, so a counterexample would require *non-generic* edge lengths where existence fails.

**Impact if true:** This would prove that the tropical Brill–Noether existence theorem is a purely combinatorial fact about the graph, independent of its tropical geometry. This is a strong form of metric independence that would simplify the theory significantly.

---

## Conjecture 4: Tableau Counting and Kostka Coefficients

**Conjecture:** The number of divisor classes of degree d and rank exactly r on a chain of g loops with generic edge lengths equals a Kostka-type coefficient: specifically, it equals the number of semistandard Young tableaux of a specific shape determined by (g, r, d), with content determined by the loop structure.

More precisely, define the *CDPR counting function* N(g, r, d) as the number of valid CDPR paths for parameters (g, r, d). Then:

$$N(g, r, d) = K_{\lambda, \mu}$$

where λ and μ are partitions explicitly determined by (g, r, d), and K_{λ,μ} is the Kostka number.

**Test:** Compute N(g, r, d) for g ≤ 9, r ≤ 3, d ≤ 2g by exhaustive enumeration of CDPR paths. Compare with Kostka numbers for candidate (λ, μ) pairs. The most natural candidate is λ = (c^{r+1}) (a rectangular partition with r+1 rows of length c = g−d+r) and μ determined by the round-robin structure.

**What would refute it:** If N(g, r, d) fails to match any Kostka number for any reasonable choice of (λ, μ), the exact Kostka connection fails. A weaker version — that N(g,r,d) is a *sum* of Kostka numbers — may still hold.

**Impact if true:** This would provide a closed-form formula for counting tropical divisor classes, connecting tropical enumerative geometry to the combinatorics of symmetric functions. It would also imply that CDPR counting is #P-hard (since Kostka number computation is #P-complete in general).

---

## Conjecture 5: Polynomial-Time Certified Rank Decision

**Conjecture:** For an arbitrary multigraph G on n vertices with m edges, the Baker–Norine rank of a divisor D can be certified (both upper and lower bounds) by a polynomial-size witness checkable in polynomial time. Specifically:

- **Upper bound witness:** A subset S of vertices of size r+1 such that no chip-firing sequence makes D − S effective.
- **Lower bound witness:** For each effective divisor E of degree r, an explicit chip-firing sequence making D − E effective.

For the chain of loops, both witnesses can be computed in O(g · r) time using Weyl chamber dynamic programming.

**Test:** Implement the dynamic programming algorithm for chains of loops with g ≤ 100, r ≤ 10. Verify that the computed witnesses are valid. Benchmark against naive rank computation (which requires checking all effective divisors of degree r).

**What would refute it:** If there exist divisors on chains of loops where the DP-produced certificates are exponentially large, or where no polynomial-size certificate exists (conditional on complexity-theoretic assumptions).

**Impact if true:** This would establish that Baker–Norine rank on chains of loops is in NP ∩ co-NP, and likely in P. It would make the CDPR theorem not just a theoretical existence result but a practical algorithmic tool for certified computation in tropical geometry.
