# Future Directions: Tropical Brill–Noether Theory

## 1. Baker-Norine Riemann-Roch for Graphs

With the Laplacian sum-zero property, linear equivalence as an equivalence relation, and degree invariance all proved in `Core.lean`, the stage is set for the full Baker-Norine theorem: for any divisor D on a connected graph G of genus g, rank(D) − rank(K_G − D) = deg(D) − g + 1.

The key insight is that our Laplacian infrastructure already gives the "easy direction" (negative-degree implies rank −1, proved as `neg_deg_no_effective_equiv`), and the hard direction reduces to showing existence and uniqueness of q-reduced divisors via Dhar's burning algorithm — a purely combinatorial argument on the graph structure. Why now? The equivalence relation structure means we can quotient by chip-firing to define the Jacobian as a Lean type, and the degree invariance ensures the rank function descends to this quotient. The missing piece is a formalization of Dhar's burning algorithm as a terminating function on `Finset V`, which is tractable with Lean 4's well-founded recursion.

## 2. Jacobian Group and Matrix-Tree Theorem

The Laplacian additivity (`tropicalLaplacian_add`), zero (`tropicalLaplacian_zero`), and negation (`tropicalLaplacian_neg`) theorems proved in `Core.lean` show that the Laplacian is a group homomorphism from (V → ℤ) to TropicalDivisor V. The cokernel of this map restricted to degree-zero divisors is the Jacobian (sandpile group), whose order equals the number of spanning trees by the matrix-tree theorem.

The key insight is that the `tropicalLinearEquiv_equivalence` theorem lets us immediately define `Jac(G) := Quotient (tropicalLinearEquiv_equivalence G).setoid` restricted to degree-zero divisors, getting a genuine Lean type with group operations inherited from the additive structure. The matrix-tree theorem then gives `Fintype.card (Jac G) = number of spanning trees`, connecting our algebraic infrastructure to enumerative combinatorics. Why now? The group homomorphism properties are all proved, so the quotient construction is mechanical; the matrix-tree connection requires formalizing the reduced Laplacian determinant, which Mathlib's `Matrix.det` provides.

## 3. Tropical Linear Series on Metric Graphs

The Brill-Noether number Serre duality (`bnNumber_serre_duality`) and strict monotonicity in degree (`bnNumber_strict_mono_d`) proved in `Core.lean` give complete algebraic control over when the Brill-Noether locus W^r_d(Γ) is expected to be nonempty. The next step is to define tropical linear series |D| = {E ≥ 0 : E ~ D} as a polyhedral complex on a metric graph and prove its dimension equals ρ(g,r,d) for generic metric chains of loops.

The key insight is that on a metric graph, the tropical linear series is a finite polyhedral complex whose cells correspond to chip-firing classes, and the Serre duality ρ(g,r,d) = ρ(g,g−1−d+r,2g−2−d) implies a duality on these polyhedral complexes that constrains their dimension. The CDPR theorem (Cools-Draisma-Payne-Robeva 2012) proves this for generic metric chains of loops using the allocation/tableau correspondence. Why now? The `MetricChainOfLoops` and `IsGeneric` structures are already formalized in `Defs.lean`, and the algebraic identities in `Core.lean` provide the numerical framework; what remains is the polyhedral geometry of piecewise-linear functions on metric graphs.

## 4. Specialization Inequality with Rank Computation

Baker's specialization lemma (abstracted in `Defs.lean` as `SpecializationDatum`) states that tropicalization does not decrease rank. Combined with our `neg_deg_no_effective_equiv` theorem, this gives a complete lower bound on the rank of algebraic divisors: if the tropical rank is −1 (forced by negative degree), then the algebraic rank is also −1. The converse — the lifting problem — asks when tropical divisors of positive rank lift to algebraic ones.

The key insight is that the degree invariance theorem (`tropicalLinearEquiv_deg`) combined with specialization's degree preservation means the Brill-Noether number ρ is preserved by specialization, so the Serre duality constraint ρ(g,r,d) = ρ(g,g−1−d+r,2g−2−d) must hold on both sides. This gives a computable necessary condition for liftability that can be checked entirely in the tropical setting. Why now? The abstract specialization interface is already formalized, and the Brill-Noether duality gives the right numerical obstruction; formalizing the sufficient condition (via non-Archimedean geometry) would be a significant advance.

## 5. Chip-Firing on Complete Graphs and Parking Functions

For the complete graph K_n, the number of maximal parking functions equals (n+1)^(n−1) (by the connection to labeled trees via Cayley's formula). Our `bnNumber_genus_zero` theorem ρ(0,r,d) = (r+1)(d−r) shows the Brill-Noether locus is always nonempty for genus-0 curves when d ≥ r, which is the rational normal curve case. For K_n with genus (n−1)(n−2)/2, the canonical divisor has degree n(n−3) and the Jacobian has order n^(n−2) spanning trees.

The key insight is that parking functions on K_n are exactly the q-reduced divisors (for a fixed vertex q), and the bijection with spanning trees gives both the matrix-tree theorem and a constructive proof of Baker-Norine for complete graphs. This would give a fully computational verification of Riemann-Roch for small complete graphs via `#eval`. Why now? The complete graph infrastructure in `GraphRiemannRoch.lean` (K_degree, K_edge_count, K_genus) provides the concrete graph, and the chip-firing equivalence relation from `Core.lean` gives the quotient; what's needed is a decidable algorithm for q-reduction that terminates in polynomial time.
