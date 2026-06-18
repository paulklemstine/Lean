# Future Directions: Tropical Brill–Noether Theory

## Hypothesis 1: Displacement Tableaux Admit a Clean Formalization Via Semi-Standard Young Tableaux

**Conjecture.** The combinatorial heart of the CDPR theorem—that displacement tableaux of type (g, d, r) exist if and only if ρ(g, r, d) ≥ 0—can be formalized in Lean 4 by reducing to a well-studied counting problem on semi-standard Young tableaux fitting inside a rectangular box.

**Test.** Define a "CDPR filling" as a function `Fin (r+1) → Fin g → Fin 2` satisfying: (i) each row j has a prescribed number of 1-entries determined by a per-strand net displacement, (ii) the "state vector" at each column stays in the Weyl chamber, (iii) an intermediate nonnegativity condition. Prove that the existence of such a filling for parameters (g, d, r) is equivalent to ρ ≥ 0 by establishing a bijection with lattice paths in a staircase region. Verify computationally for all g ≤ 12, r ≤ 4.

**Impact.** This would yield the first machine-checked proof of the tropical Brill–Noether existence theorem, completing the sorry-free formalization of the CDPR result.

---

## Hypothesis 2: Baker–Norine Rank Admits a Tropical Linear Algebra Upper Bound

**Conjecture.** There exists a functorial construction sending divisors on a chain of g loops to tropical matrices such that the Baker–Norine divisor rank is bounded above by the tropical matrix rank (Barvinok rank) of the image.

**Test.** For genera g ≤ 6 and all v₀-reduced divisors of degree d ≤ 2g, construct the candidate matrix M(D) ∈ ℝ_trop^{(g+1)×(g+1)} whose (i,j)-entry encodes the tropical distance between chip positions. Compare the computed Barvinok rank of M(D) with the divisor rank r(D) on exhaustive samples. A valid bound would give Barvinok_rank(M(D)) ≥ r(D) for all D.

**Impact.** This would create a new bridge between tropical linear algebra and divisor theory, potentially yielding faster rank computation algorithms and new structural insights into the Baker–Norine rank function.

---

## Hypothesis 3: The Full CDPR Theorem Is Formalizable Without Metric Data

**Conjecture.** The tropical Brill–Noether existence theorem on a chain of g loops can be stated and proved purely combinatorially, without any reference to edge lengths or genericity conditions, by working directly with reduced divisors and chip-firing equivalence classes on the combinatorial (non-metric) chain of loops graph.

**Test.** Define the chain-of-loops as a multigraph (not a metric graph). Define Baker–Norine rank via chip-firing. State and attempt to prove: for the chain of g loops, a divisor of degree d and rank ≥ r exists iff ρ(g,r,d) ≥ 0. The key challenge is that without genericity, the theorem may fail—check computationally whether the combinatorial chain of loops (with unit edge weights) satisfies the BN theorem for g ≤ 8.

**Impact.** If true, this would dramatically simplify the formalization by eliminating all real-number infrastructure. If false, the counterexamples would clarify exactly which metric data is essential.

---

## Hypothesis 4: Specialization Inequality Can Be Fully Formalized for Semistable Degenerations

**Conjecture.** An abstract algebraic interface consisting of (i) a "specialization map" from algebraic to tropical divisors, (ii) degree preservation, and (iii) a rank inequality `r_X(D) ≤ r_Γ(τ*(D))`, suffices to prove a machine-checked theorem linking classical and tropical Brill–Noether theory, without requiring scheme theory, formal models, or Berkovich spaces.

**Test.** Define a Lean typeclass `SpecializationData` with the three axioms above. Prove that the existence direction of tropical BN follows formally from classical BN + specialization. Check that all proof obligations reduce to pure divisor/graph lemmas. Attempt to instantiate the typeclass for the chain-of-loops model by defining a concrete specialization map from hyperelliptic curves.

**Impact.** This would create the first formal bridge between algebraic geometry and tropical geometry in a proof assistant, opening the door to machine-certified degeneration arguments.

---

## Hypothesis 5: Genericity Conditions Can Be Weakened to a Single Non-Vanishing Determinant

**Conjecture.** The full tropical Brill–Noether existence theorem on chains of loops remains valid under a weaker explicit condition than pairwise ratio distinctness: it suffices that a single (r+1) × (r+1) determinant formed from the edge-length ratios is nonzero.

**Test.** For fixed r ∈ {1, 2, 3} and g ≤ 10, enumerate all divisors of degree d and rank ≥ r on chains of g loops with random edge lengths satisfying the weaker determinantal condition but NOT the pairwise distinctness condition. Check whether the BN existence theorem still holds. Search for counterexamples among low-genus metric chains satisfying the weak condition but violating the strong condition.

**Impact.** A weaker genericity condition would enlarge the class of tropical curves for which the BN theorem holds, potentially enabling applications to specific families of curves (e.g., those arising from particular degenerations of moduli spaces).
