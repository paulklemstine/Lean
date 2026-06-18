# Future Directions

## Synthesis

The formally verified Ramsey theory framework established here — encompassing recursive bounds, probabilistic lower bounds, exact values, and Hales–Jewett foundations — creates a platform for attacking deeper questions at the intersection of extremal combinatorics, coding theory, and computational complexity. Each direction below builds directly on proven infrastructure and targets falsifiable predictions that drive the next research cycle.

---

### Direction 1: The Diagonal Ramsey Gap — Closing the Exponential Window

**Conjecture:** For all sufficiently large k, R(k,k) > (1.1)·2^(k/2), improving the constant in the probabilistic lower bound.

**Test:** Formalize the Lovász Local Lemma (LLL) for the Ramsey setting and derive the improved bound R(k,k) > √2·2^(k/2)/e. Verify computationally that for k = 4,...,10, the LLL bound strictly exceeds the first-moment bound. A single k where the LLL gives a *worse* bound would disprove the approach (which cannot happen mathematically, but verifying the formalization catches errors).

**Impact:** The LLL-based bound has been the state of the art for lower bounds since the 1970s. Formalizing it would be the first machine-verified proof of a non-trivial probabilistic combinatorics result using dependent events.

**Catalog References:** `Algebra/Ramsey/Probabilistic.lean` — `ramsey_lower_bound_counting`, `good_coloring_count_lower_bound`

**Proof Strategy:** Define a dependency graph on monochromatic-clique events. Prove each event depends on at most C(k,2)·C(n-2, k-2) others. Apply the symmetric LLL criterion. The key helper lemma is: if x·d ≤ 1 where x = C(n,k)·2^(1-C(k,2)) and d = C(k,2)·C(n-2,k-2), then a good coloring exists.

**Domain Bridges:** Probability theory, dependency graphs, coding theory (random codes with local constraints).

**Lineage:** Extends `ramsey_lower_bound_counting` from first-moment to LLL-based existence.

**Ambition:** 🟡 Solid extension — well-understood mathematics, significant formalization challenge.

---

### Direction 2: R(4,4) = 18 via Verified Certificate Pipeline

**Conjecture:** The Paley graph on 17 vertices (quadratic residues mod 17 as red edges) avoids both red K₄ and blue K₄.

**Test:** Formalize the Paley graph construction on GF(17), prove it is self-complementary, and verify K₄-freeness by a combination of modular arithmetic arguments and bounded computation. If the Paley graph on 17 vertices contains a monochromatic K₄, the conjecture fails — checkable by `native_decide`.

**Impact:** R(4,4) = 18 is the largest exactly known diagonal Ramsey number. A formal proof would be a landmark in verified combinatorics. The certificate pipeline (construct → verify → certify) would be reusable for any future exact Ramsey value.

**Catalog References:** `Algebra/Ramsey/Exact.lean` — `ramsey_33_eq`, `ramsey_34_eq`; `Algebra/Ramsey/Recursion.lean` — `RamseyProp_recursion`, `RamseyProp_recursion_parity`

**Proof Strategy:** Upper bound: R(4,4) ≤ R(3,4) + R(4,3) = 9 + 9 = 18 from the basic recursion. Lower bound: define the Paley graph via quadratic residue predicate on ℤ/17ℤ, prove self-complementarity (QR(-1) in GF(17) since 17 ≡ 1 mod 4), then verify K₄-freeness using the structure of quadratic residues.

**Domain Bridges:** Finite fields, quadratic residues, algebraic graph theory.

**Lineage:** Direct extension of `ramsey_34_eq` to the next diagonal value.

**Ambition:** 🟡 Solid extension with computational verification component.

---

### Direction 3: Full Hales–Jewett Theorem

**Conjecture:** For every k ≥ 1 and r ≥ 1, there exists N such that HJProp k r N holds.

**Test:** Formalize the Shelah proof (primitive recursive bounds) for small cases. Verify computationally that HJ(3, 2) ≤ some explicit N by exhaustive search over colorings of [3]^N. If N is found for which a 2-coloring of [3]^N avoids monochromatic lines, the bound is too small.

**Impact:** The Hales–Jewett theorem is the foundational result of higher-dimensional Ramsey theory. A formal proof would be a first in any proof assistant and would unlock formalization of density Hales–Jewett, which itself implies Szemerédi's theorem.

**Catalog References:** `Algebra/Ramsey/HalesJewett.lean` — `HJProp_monotone_dim`, `HJProp_2_2_2`; `Algebra/Ramsey/Defs.lean` — `CombinatorialLine`, `HJProp`

**Proof Strategy:** Product argument: given a coloring of [k]^N, restrict to slices and use the k=2 case (essentially Ramsey) to find monochromatic partial lines. Iterate over dimensions. The key is the color-focusing lemma: from many monochromatic partial lines, extract a full line. Use Shelah's approach for primitive recursive bounds.

**Domain Bridges:** Additive combinatorics, density increment, ergodic theory connections.

**Lineage:** Extends `HJProp_monotone_dim` and `HJProp_2_2_2` to the full theorem.

**Ambition:** 🔴 Grand challenge — multiple person-years of effort expected.

---

### Direction 4: Ramsey Multiplicity and Goodman's Formula

**Conjecture:** (Goodman's formula) In any 2-coloring of K_n, the number of monochromatic triangles is at least C(n,3)/4 (for n ≡ 1 mod 2) or slightly more than C(n,3)/4 (for even n).

**Test:** Formalize the degree-counting proof of Goodman's formula. Verify computationally for n = 5,...,12 that the minimum number of monochromatic triangles matches the predicted formula. A single n where the formula gives a wrong prediction disproves the formalization.

**Impact:** Ramsey multiplicity goes beyond existence (R(3,3) = 6) to quantitative bounds: *how many* monochromatic cliques must exist? This connects to flag algebras and the Razborov method, a powerful tool in extremal combinatorics.

**Catalog References:** `Algebra/Ramsey/Exact.lean` — `redDegree`, `sum_redDegree_even`; `Algebra/Ramsey/Defs.lean` — `IsRedClique`, `IsBlueClique`

**Proof Strategy:** Use the identity: (number of mono triangles) = C(n,3) - (1/2)·Σ_v redDeg(v)·blueDeg(v). Minimize using AM-GM on degree products, subject to redDeg(v) + blueDeg(v) = n-1. The minimum is achieved when all degrees are as equal as possible.

**Domain Bridges:** Flag algebras, semidefinite programming, extremal graph theory.

**Lineage:** Extends `sum_redDegree_even` and degree-counting infrastructure.

**Ambition:** 🟡 Solid extension with rich mathematical content.

---

### Direction 5: Ramsey Numbers and Communication Complexity

**Conjecture:** The two-party communication complexity of detecting a monochromatic K_k in a 2-coloring of K_n (where Alice holds red edges, Bob holds blue edges) is Θ(k² log n).

**Test:** Formalize a protocol achieving O(k² log n) communication for detecting monochromatic K_k. Prove a matching lower bound via a reduction from set disjointness. Verify for small cases (k=3, n ≤ 20) that the protocol correctly identifies monochromatic triangles.

**Impact:** This bridges Ramsey theory and communication complexity, two pillars of theoretical computer science. It would formalize the first non-trivial communication complexity lower bound for a graph property in a proof assistant.

**Catalog References:** `Algebra/Ramsey/Defs.lean` — `RamseyProp`, `TwoColoring`

**Proof Strategy:** Protocol: enumerate k-subsets, for each check if Alice's edges or Bob's edges contain a k-clique. Lower bound: embed set disjointness into the Ramsey detection problem by encoding sets as edge colorings.

**Domain Bridges:** Communication complexity, circuit complexity, information theory.

**Lineage:** New direction connecting Ramsey framework to computational complexity.

**Ambition:** 🔴 Grand challenge — requires significant new infrastructure.
