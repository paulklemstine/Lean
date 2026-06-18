# Future Directions: Asymptotic Compactness for Monotone Circuit Lower Bounds

## Synthesis

The results established in this cycle—completeness monotonicity, hereditary restriction, uniform extraction, certificate poset theory, and the triangle instantiation—form the **foundational layer** of a new theory of structured lower bounds. The five directions below extend this foundation along complementary axes: (1) strengthening the polynomial bound conjecture, (2) connecting to proof complexity, (3) developing the order-theoretic structure, (4) extending to broader function classes, and (5) building algorithmic certificate search. Together, they aim to transform monotone circuit lower bounds from a collection of bespoke arguments into a systematic, compositional theory with cross-domain applications.

The unifying theme is that **lower bounds are not chaos—they are architecture**. Certificate families exhibit compactness, heredity, and polynomial describability, suggesting that impossibility results have a canonical normal form waiting to be discovered.

---

## Direction 1: Universal Polynomial Bound for Certificate Families

**Conjecture:** For every monotone graph property P with monotone circuit complexity exceeding s(n), there exists a certified sandwich family complete up to s(n) with at most C · n^d witnesses, where C and d depend only on the property (not on n).

**Test:** Implement exhaustive enumeration of minimal complete sandwich families for:
- Triangle detection (k=3): predicted bound O(n³)
- 4-clique detection (k=4): predicted bound O(n⁴)
- k-clique for k=5,6: measure growth exponent

Compute the minimal family size for n = 4, 5, 6, 7, 8 and fit a polynomial. If the exponent exceeds k for k-clique detection, the conjecture fails in its current form.

**Impact:** A proven universal polynomial bound would establish that monotone lower bounds are always polynomially certifiable—a fundamental structural theorem about computational impossibility.

**Catalog References:**
- `Pythagorean/AsymptoticCompactness.lean`: `asymptotic_compactness_extraction`, `uniform_scheme_implies_lower_bound`
- `Pythagorean/SandwichDefs.lean`: `CertifiedSandwichFamily`, `SandwichCompleteUpTo`

**Proof Strategy:** Extend the restriction theorem to show that minimal complete families at size n project to complete (though possibly non-minimal) families at size m < n. Use an Erdős-Ko-Rado style argument to bound the antichain width of the certificate poset.

**Domain Bridges:** Extremal combinatorics (Turán-type bounds on witness families), Ramsey theory (guaranteed structure in large witness sets).

**Lineage:** Builds directly on `SandwichCompleteUpTo.mono` and `sandwichCompleteUpTo_restrict`.

**Ambition:** ★★★★☆ — Grand challenge. A positive resolution would be a major result in structural complexity theory.

---

## Direction 2: Proof Complexity Correspondence

**Conjecture:** The minimum size of a complete certified sandwich family for a monotone property P at circuit size s corresponds to the minimum refutation length in a natural monotone proof system: the *sandwich refutation system* (SRS). Specifically:

> SRS-refutation length for "P is computable by size-s circuits" = minimum |S.Pos| + |S.Neg| over complete S.

**Test:** Formalize the SRS proof system in Lean. Show that:
1. Every complete sandwich family yields an SRS refutation (already done: `sandwich_as_refutation_system`).
2. Every SRS refutation corresponds to a complete sandwich family.
3. Compute refutation lengths for triangle detection at s = ⌈n^{3/2}⌉ for n = 5, 6, 7, 8.

Compare with known resolution complexity bounds for related formulas.

**Impact:** Would establish a formal equivalence between circuit complexity and proof complexity in the monotone setting, opening both fields to each other's tools.

**Catalog References:**
- `Pythagorean/AsymptoticCompactness.lean`: `sandwich_as_refutation_system`
- `Catalog/FINAL/Pythagorean/SandwichTheorems.lean`: `sandwich_is_transversal`

**Proof Strategy:** Define SRS as a proof system where axioms are individual witness disagreements and the rule is "if all circuits are hit, conclude unsatisfiability." Show this is polynomially equivalent to tree-like resolution over a suitable encoding.

**Domain Bridges:** Proof complexity (resolution, cutting planes), propositional logic, SAT solving.

**Lineage:** Extends `sandwich_as_refutation_system` from a structural observation to a full proof system equivalence.

**Ambition:** ★★★★★ — Paradigm-shifting. Would create a new subfield at the intersection of circuit complexity and proof complexity.

---

## Direction 3: Certificate Poset Well-Quasi-Ordering

**Conjecture:** For any fixed monotone graph property P and size threshold s, the poset of complete sandwich families under `CertificateLE` is well-quasi-ordered: every infinite sequence of complete families contains a pair S_i ≤ S_j with i < j.

**Test:**
1. Formalize the WQO definition in Lean.
2. For triangle detection, enumerate all complete families at n = 4, 5 and check that the poset has no infinite antichains (equivalently, verify finite width).
3. Compute the antichain width and verify it grows at most polynomially.

**Impact:** WQO for certificate posets would imply that every set of complete families has a finite basis—the exact analogue of the Robertson-Seymour theorem for graph minors, but for lower-bound certificates.

**Catalog References:**
- `Pythagorean/AsymptoticCompactness.lean`: `CertificateLE`, `certificateLE_refl`, `certificateLE_trans`, `completeness_mono_certificate`

**Proof Strategy:** Show that CertificateLE embeds into the product order on Finset × Finset, which is WQO by Dickson's lemma when the underlying type is finite. The challenge is extending this to the parametric setting where n varies.

**Domain Bridges:** Order theory (WQO, BQO), graph minor theory (Robertson-Seymour), algebra (Noetherian rings).

**Lineage:** Builds on the certificate poset infrastructure (Theorems 3.8–3.10).

**Ambition:** ★★★☆☆ — Solid extension. The finite case should be tractable; the parametric case is challenging.

---

## Direction 4: Beyond Graphs — Matroid and Hypergraph Properties

**Conjecture:** The certified sandwich framework extends to monotone properties of matroids, hypergraphs, and general finite lattices, with analogous hereditary restriction and polynomial bound results.

**Test:**
1. Instantiate the framework for the monotone property "contains a Hamiltonian cycle" on n-vertex graphs.
2. Instantiate for "has a perfect matching" (a matroid property).
3. Instantiate for hypergraph coloring properties.
4. Measure certificate size growth for each and compare with known circuit lower bounds.

**Impact:** Would demonstrate that the framework is not specific to clique-type properties but applies universally to monotone computation.

**Catalog References:**
- `Pythagorean/SandwichDefs.lean`: `CertifiedSandwichFamily` (already parametric over arbitrary preordered types)
- `Pythagorean/AsymptoticCompactness.lean`: all theorems (stated for general preorders)

**Proof Strategy:** The abstract theorems already apply to general preordered types. The challenge is constructing explicit minimal certificate families for specific properties and proving polynomial bounds.

**Domain Bridges:** Matroid theory, hypergraph theory, lattice theory, algebraic combinatorics.

**Lineage:** Direct generalization of the triangle instantiation.

**Ambition:** ★★★☆☆ — Solid extension. The abstract framework is ready; the work is in constructing and analyzing specific families.

---

## Direction 5: Algorithmic Certificate Search

**Conjecture:** There exists a polynomial-time algorithm that, given oracle access to a monotone Boolean function f on n-input graphs and a size bound s, either:
(a) produces a certified sandwich family complete up to s, or
(b) produces a monotone circuit of size ≤ s computing f.

**Test:**
1. Implement a greedy certificate search algorithm using the obstruction basis approach.
2. Benchmark on triangle detection for n = 5, 6, 7, 8 with s = ⌈n^{3/2}⌉.
3. Measure runtime scaling and certificate quality.
4. Compare with SAT-based certificate search (encoding completeness as a SAT instance).

Falsification: If the greedy algorithm requires super-polynomial time for some n, or if it fails to find complete families of polynomial size, the conjecture needs refinement.

**Impact:** An efficient certificate search would make lower-bound proofs semi-automatic: instead of human-constructed combinatorial arguments, a machine would search for and verify certificates.

**Catalog References:**
- `Pythagorean/AsymptoticCompactness.lean`: `sandwichCompleteUpTo_iff_no_small_circuit` (the search target)
- `Catalog/FINAL/Pythagorean/SandwichGraph.lean`: `verify_sandwich_complete_of_finite_check`

**Proof Strategy:** Reduce certificate search to a covering problem: find a minimum set of witnesses that covers all circuits. Use LP relaxation and rounding, or Lovász Local Lemma, to bound the covering number.

**Domain Bridges:** Algorithm design, SAT solving, integer programming, learning theory (the certificate family as a "hypothesis class").

**Lineage:** Builds on the constructive aspects of the framework and the computational experiments in demo.py.

**Ambition:** ★★★★☆ — Grand challenge. The dichotomy (find certificates or find circuits) would be a major algorithmic result.
