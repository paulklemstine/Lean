# Future Directions: Tropical Geometry–Phylogenetics Bridge

This document outlines breakthrough research opportunities opened by the formal proof
that the tropical Plücker relation is equivalent to the four-point condition for
symmetric distance functions.

---

## 1. Formalize Trop(Gr(2,n)) ↔ Tree Metrics

**Hypothesis:** The points of the tropical Grassmannian Trop(Gr(2,n)) are in
canonical bijection with phylogenetic (additive) tree metrics on n leaves,
up to the lineality space of adding a linear function to all pairwise distances.

**Proof strategy:**
- Define the tropical Grassmannian as the set of vectors in ℝ^(n choose 2) satisfying
  the tropical Plücker relations for all 4-element subsets.
- Use the now-formalized equivalence to convert each Plücker relation into a four-point
  inequality.
- Invoke the Buneman/Dress tree-realization theorem: a metric satisfying the four-point
  condition is realizable by a weighted tree. This requires formalizing the recursive
  cherry-picking construction.
- The lineality space corresponds to the gauge freedom d(i,j) ↦ d(i,j) + f(i) + f(j).

**Cross-domain impact:** This would give the first certified algebraic-geometric
characterization of phylogenetic tree space, connecting computational biology with
moduli theory.

---

## 2. Prove Buneman Tree Reconstruction Correctness

**Hypothesis:** Given a distance matrix satisfying the four-point condition, the
neighbor-joining / cherry-picking algorithm produces a weighted tree that exactly
realizes the distance matrix.

**Proof strategy:**
- Formalize the cherry identification lemma: in a four-point metric on ≥3 points,
  there exist i,j such that d(i,j) + d(k,l) ≤ d(i,k) + d(j,l) for all k,l.
- Prove that contracting a cherry preserves the four-point condition on the reduced
  metric.
- Induct on the number of leaves.
- The `LBTree` infrastructure in `Catalog/Computation/TreeMetric/Defs.lean` already
  provides the tree data structure and `Realizes` predicate.

**Cross-domain impact:** Certified reconstruction algorithms are directly applicable
to computational phylogenetics, providing machine-verified guarantees for evolutionary
tree inference from molecular sequence data.

---

## 3. Connect Rank-2 Valuated Matroids to Finite Trees

**Hypothesis:** A rank-2 valuated matroid on ground set [n] (in the sense of Dress–Wenzel)
is equivalent to a metric tree on n leaves, via the correspondence
p({i,j}) = −d(i,j).

**Proof strategy:**
- Define valuated matroids axiomatically: a function on the bases of a matroid
  satisfying the tropical exchange axiom.
- For rank 2, bases are 2-element subsets. The tropical exchange axiom specializes to
  exactly the tropical Plücker relation.
- Apply the formalized equivalence theorem to convert to the four-point condition.
- Invoke tree realization (Direction 2) to produce the tree.

**Cross-domain impact:** Creates a formal bridge between combinatorial optimization
(valuated matroids, M-convexity) and geometric group theory (tree-like spaces),
opening paths to certified algorithms for matroid intersection and tropical convexity.

---

## 4. Define and Certify the Dressian as a Tropical Grassmannian Relaxation

**Hypothesis:** The Dressian Dr(2,n) (defined by tropical Plücker relations alone)
equals the tropical Grassmannian Trop(Gr(2,n)) (defined as the tropicalization of the
classical Grassmannian) in rank 2, but strictly contains it for rank ≥ 3.

**Proof strategy:**
- Define Dr(r,n) as the set of vectors satisfying all 3-term tropical Plücker relations.
- Define Trop(Gr(r,n)) via initial ideals or valuated realizability.
- For r=2: prove equality using the tree-metric characterization (both sides equal
  the space of tree metrics).
- For r=3: exhibit an explicit counterexample (the Fano matroid provides one for n=7).

**Cross-domain impact:** This is foundational for tropical moduli theory and connects
to the theory of tropical linear spaces, matroid subdivisions, and the geometry of
the space of phylogenetic networks.

---

## 5. Develop a Verified Tropical-to-Phylogenetic Reconstruction Pipeline

**Hypothesis:** Given noisy distance data from molecular sequences, one can:
(a) project onto the nearest four-point metric (= tropical Grassmannian point),
(b) reconstruct the tree, and
(c) bound the error in the reconstruction.

**Proof strategy:**
- Formalize the L∞ projection onto the space of four-point metrics as a tropical
  nearest-point problem.
- Prove that the projection preserves the tree topology when the noise is below
  half the minimum edge weight (Atteson's theorem).
- Combine with the certified reconstruction (Direction 2) to obtain an end-to-end
  verified pipeline.

**Cross-domain impact:** This would be the first formally verified pipeline from
raw biological distance data to phylogenetic trees, with certified error bounds.
It connects tropical optimization, metric geometry, and computational biology in
a single verified artifact.

---

## Summary Table

| Direction | Key Theorem | Difficulty | Dependencies |
|-----------|------------|------------|--------------|
| 1. Trop(Gr(2,n)) ↔ Trees | Bijection + lineality | Medium | This work + tree realization |
| 2. Buneman Reconstruction | Cherry-picking correctness | Medium | Four-point condition + induction |
| 3. Valuated Matroids | Rank-2 ↔ trees | Medium | This work + matroid axioms |
| 4. Dressian = Trop Grass | Equality in rank 2 | Medium-Hard | Directions 1,3 |
| 5. Verified Pipeline | End-to-end certification | Hard | Directions 1,2 + approximation theory |
