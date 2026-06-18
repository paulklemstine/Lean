# Counterpoint as Category Theory: The Stepwise Voice Leading Category

## Abstract

We formalize first-species counterpoint as a directed graph on consonant interval classes modulo the octave and prove structural theorems about the resulting combinatorial object. Working in the twelve-tone equal-tempered system (ℤ/12ℤ), we define the consonant interval classes {0, 3, 4, 7, 8, 9} and characterize all valid transitions under stepwise voice leading with the classical no-parallel-motion constraint. Our main results are: (A) the consonance set exhibits a fundamental asymmetry under interval inversion, with the perfect fifth as the unique obstruction; (B) perfect consonances are separated under stepwise motion, requiring at least two steps to move between unison and fifth; (C) the transition graph has exactly 26 directed edges and is balanced (every vertex has equal in-degree and out-degree); (D) the graph has diameter exactly 2; and (E) the voice leading cost function provides a subadditive grading compatible with sequential composition and satisfying a lattice meet-join identity. These results bridge music theory, finite combinatorics, order theory, and category theory, and all proofs are formally verified in Lean 4 with Mathlib.

## 1. Introduction

Species counterpoint, as codified by Fux (1725), provides a rigorous framework for composing multiple independent melodic lines. While the musical significance of these rules has been analyzed extensively, their mathematical structure — particularly from a categorical or graph-theoretic perspective — has received less attention.

Recent work in mathematical music theory (Tymoczko 2011, Mazzola 2002) has used geometry and topology to analyze voice leading spaces. Our contribution differs in that we work combinatorially, enumerating all valid transitions between consonant interval classes and proving structural properties of the resulting finite directed graph.

### 1.1 Setting

We work in the twelve-tone equal-tempered system, representing pitch classes as elements of ℤ/12ℤ. An interval class is the difference between two pitch classes, also in ℤ/12ℤ.

**Definition 1.1.** An interval class *i* ∈ ℤ/12ℤ is *consonant in first-species counterpoint* if *i* ∈ {0, 3, 4, 7, 8, 9}. These correspond to unison (0), minor third (3), major third (4), perfect fifth (7), minor sixth (8), and major sixth (9).

**Definition 1.2.** A consonant interval is *perfect* if *i* ∈ {0, 7} and *imperfect* if *i* ∈ {3, 4, 8, 9}.

**Definition 1.3.** A *stepwise voice leading* is a pair (a, b) ∈ ℤ² with |a|, |b| ≤ 2, where *a* is the motion of voice 1 and *b* is the motion of voice 2. The *interval change* is δ(a,b) = (b − a) mod 12.

**Definition 1.4.** A voice leading (a, b) from interval *i* to interval *j* is *valid* if:
1. Both *i* and *j* are consonant
2. (a, b) is stepwise: |a|, |b| ≤ 2
3. δ(a,b) = j − i (the interval change is correct)
4. If *j* is a perfect consonance, then a ≠ b (no parallel motion to perfect consonances)

**Definition 1.5.** The *counterpoint transition graph* G = (V, E) has V = {0, 3, 4, 7, 8, 9} ⊂ ℤ/12ℤ and (i, j) ∈ E iff there exists a valid voice leading from *i* to *j*.

## 2. Main Results

### 2.1 Theorem A: Inversion Asymmetry

The *inversion* map σ: ℤ/12ℤ → ℤ/12ℤ, σ(i) = −i, is a fundamental symmetry operation in music theory. It maps:
- 0 ↦ 0, 3 ↦ 9, 4 ↦ 8, 7 ↦ 5, 8 ↦ 4, 9 ↦ 3

**Theorem A.1 (Imperfect Closure).** The set of imperfect consonances {3, 4, 8, 9} is closed under σ.

*Proof.* Verified by direct computation: σ(3) = 9, σ(4) = 8, σ(8) = 4, σ(9) = 3. □

**Theorem A.2 (Inversion Asymmetry).** The full consonance set {0, 3, 4, 7, 8, 9} is NOT closed under σ.

*Proof.* σ(7) = 5, and 5 ∉ {0, 3, 4, 7, 8, 9}. □

**Theorem A.3 (Unique Obstruction).** The perfect fifth (7) is the unique consonant interval *i* such that σ(i) is not consonant.

*Proof.* Verified exhaustively over all 6 consonant intervals: σ(0) = 0 ✓, σ(3) = 9 ✓, σ(4) = 8 ✓, σ(7) = 5 ✗, σ(8) = 4 ✓, σ(9) = 3 ✓. □

**PEGB Analysis:**
- **P**roof: Formally verified in Lean 4 (`fifth_unique_asymmetric`)
- **E**xample: The perfect fifth C–G inverts to C–F (a perfect fourth), which is forbidden as a consonance in two-voice first species
- **G**eneralization: In *n*-voice counterpoint, the consonance set changes (the fourth becomes consonant), and inversion closure may be restored. The generalization to arbitrary consonance sets and their closure under inversion groups is natural.
- **B**oundary: The result is specific to two-voice first species. In three or more voices, the perfect fourth IS consonant, and inversion closure holds.

### 2.2 Theorem B: Stepwise Separation

**Lemma 2.1.** If |a|, |b| ≤ k, then |b − a| ≤ 2k.

*Proof.* Triangle inequality for absolute value. □

**Lemma 2.2.** If |d| ≤ 4, then d mod 12 ∉ {5, 7}.

*Proof.* The values d ∈ {−4, −3, −2, −1, 0, 1, 2, 3, 4} have residues {8, 9, 10, 11, 0, 1, 2, 3, 4} modulo 12. Neither 5 nor 7 appears. □

**Theorem B (Stepwise Separation).** For any stepwise voice leading (a, b) with |a|, |b| ≤ 2, the interval change δ(a,b) ∉ {5, 7}. In particular, no single stepwise voice leading can move from interval 0 to interval 7 or vice versa.

*Proof.* By Lemma 2.1, |b − a| ≤ 4. By Lemma 2.2, (b − a) mod 12 ∉ {5, 7}. Since 7 − 0 = 7 and 0 − 7 = 5 (mod 12), neither transition is achievable. □

**PEGB Analysis:**
- **P**roof: Formally verified (`stepwise_separation`, `small_ne_five`, `small_ne_seven`)
- **E**xample: A soprano on G above a bass on C (perfect fifth) cannot move to unison in one stepwise motion; it must pass through an intermediate consonance
- **G**eneralization: For stepwise bound *k*, the interval changes {d : |d| ≤ 2k} ∩ {5, 7} = ∅ iff k ≤ 2. For k = 3, d = ±5 and d = ±7 become possible, dissolving the separation.
- **B**oundary: The separation breaks at stepwise bound 3 (each voice moving up to 3 semitones)

### 2.3 Theorem C: Transition Graph Structure

By exhaustive enumeration (verified computationally), the adjacency list of G is:

| Source | Targets | Out-degree |
|--------|---------|------------|
| 0 (unison) | {3, 4, 8, 9} | 4 |
| 3 (min 3rd) | {0, 3, 4, 7} | 4 |
| 4 (maj 3rd) | {0, 3, 4, 7, 8} | 5 |
| 7 (perf 5th) | {3, 4, 8, 9} | 4 |
| 8 (min 6th) | {0, 4, 7, 8, 9} | 5 |
| 9 (maj 6th) | {0, 7, 8, 9} | 4 |

**Theorem C.1 (Edge Count).** |E| = 26.

**Theorem C.2 (Isomorphic Neighborhoods).** The out-neighborhoods of 0 and 7 are identical: N⁺(0) = N⁺(7) = {3, 4, 8, 9}. Similarly, N⁻(0) = N⁻(7) = {3, 4, 8, 9}.

**Theorem C.3 (Balanced Graph).** For every vertex v ∈ V, deg⁺(v) = deg⁻(v).

*Proof.* Verified computationally:
- deg(0) = deg(7) = 4 (in and out)
- deg(3) = deg(9) = 4 (in and out)
- deg(4) = deg(8) = 5 (in and out)
□

**Theorem C.4 (Non-Regular).** G is not regular: deg(4) = 5 ≠ 4 = deg(0).

**Theorem C.5 (Complement Automorphism).** The inversion map σ restricted to the imperfect consonances is a graph automorphism of the induced subgraph G[{3,4,8,9}].

**PEGB Analysis:**
- **P**roof: All formally verified in Lean 4 (`edge_count`, `balanced_graph`, `perfect_same_outNeighbors`, etc.)
- **E**xample: From a major third (C–E), a composer can reach 5 different consonances; from a unison (C–C), only 4
- **G**eneralization: For different stepwise bounds, the graph changes. The balanced property may or may not persist.
- **B**oundary: The specific counts (26 edges, degree sequence [4,4,5,4,5,4]) are specific to stepwise bound 2. Changing the bound changes the graph entirely.

### 2.4 Theorem D: Strong Connectivity and Diameter

**Theorem D.1 (Perfect Isolation).** No perfect consonance has an edge to any perfect consonance (including self-loops).

*Proof.* For self-loops: the only stepwise motion with δ = 0 is parallel motion (a = b), which is forbidden for perfect consonances. For 0 → 7 or 7 → 0: this would require δ ∈ {5, 7}, impossible by Theorem B. □

**Theorem D.2 (Imperfect Bridge).** Every imperfect consonance has edges to both 0 and 7.

**Theorem D.3 (Diameter 2).** For every pair i, j ∈ V, there exists a path of length ≤ 2 from i to j. Moreover, the path 0 → 7 requires length exactly 2.

*Proof.* By Theorem D.2, every imperfect consonance reaches both 0 and 7. By Theorem C.2, both 0 and 7 reach all imperfect consonances. So any path from a perfect consonance to another can be routed through an imperfect consonance in 2 steps. The remaining cases (imperfect to imperfect) are verified by the adjacency table. □

**PEGB Analysis:**
- **P**roof: Formally verified (`strong_connectivity`, `diameter_exactly_two`, `imperfect_bridges_perfect`)
- **E**xample: To move from unison (C–C) to fifth (C–G), a valid two-step path is: C–C → C–E (major third) → C–G (perfect fifth)
- **G**eneralization: For larger stepwise bounds, the diameter decreases to 1 (all transitions become possible)
- **B**oundary: The diameter-2 property requires at least the 4 imperfect consonances to serve as bridges

### 2.5 Theorem E: Cost Grading

**Definition 2.1.** The *voice leading cost* of (a, b) is cost(a,b) = |a| + |b|.

**Theorem E.1 (Triangle Inequality).** cost(a₁+a₂, b₁+b₂) ≤ cost(a₁,b₁) + cost(a₂,b₂).

**Theorem E.2 (Meet-Join Identity).** For any voice leadings (a₁,b₁) and (a₂,b₂):
cost(min(a₁,a₂), min(b₁,b₂)) + cost(max(a₁,a₂), max(b₁,b₂)) = cost(a₁,b₁) + cost(a₂,b₂)

*Proof.* This reduces to the identity |min(x,y)| + |max(x,y)| = |x| + |y| applied to each voice independently. □

**Theorem E.3 (Functoriality).** The interval change map δ satisfies δ(a₁+a₂, b₁+b₂) = δ(a₁,b₁) + δ(a₂,b₂). This makes sequential composition of voice leadings functorial with respect to the interval class map.

**Theorem E.4 (Lattice Closure).** The set of stepwise voice leadings is closed under componentwise min and max (lattice meet and join).

**PEGB Analysis:**
- **P**roof: All verified (`cost_triangle_ineq`, `meet_join_cost_identity`, `compose_intervalDelta`, `stepwise_meet_closed`, `stepwise_join_closed`)
- **E**xample: Two voice leadings (1,2) and (−1,1) have costs 3 and 2; their composition (0,3) has cost 3 ≤ 5
- **G**eneralization: The cost function is a seminorm on ℤ², and the triangle inequality makes it compatible with categorical composition
- **B**oundary: The lattice closure (stepwise ∩ stepwise = stepwise under meet/join) breaks for non-symmetric bounds

## 3. The Diatonic Restriction

When restricted to the diatonic major scale (intervals 0, 2, 4, 5, 7, 9, 11), the consonant intervals reduce to {0, 4, 7, 9} — the minor third (3) and minor sixth (8) are not available as diatonic intervals from the root. The diatonic transition graph has only 10 edges, a 62% reduction from the chromatic 26.

This quantifies the well-known musical observation that diatonic counterpoint is more constrained than chromatic counterpoint.

## 4. Cross-Domain Bridge: From Music to Poset Theory

The transition graph has a natural interpretation in terms of accessibility posets. Define a preorder on consonant intervals by: *i* ≤ *j* iff every consonant interval that can reach *j* can also reach *i* (i.e., *i* is "at least as accessible" as *j*).

Under this preorder, the imperfect consonances are strictly more accessible than the perfect consonances (Theorem: `imperfect_more_accessible` in the Lean formalization from the existing catalog). This gives a partial order:

```
{3, 4, 8, 9}  (more accessible)
    ↑
{0, 7}         (less accessible)
```

This connects the musical notion of "consonance hierarchy" to the order-theoretic notion of accessibility in directed graphs, providing a bridge between music theory and lattice/poset theory.

## 5. Relationship to Existing Catalog Results

This work builds on and extends two existing formalizations:

1. **HarmonicMusicTheory.lean** (`Catalog/Pythagorean/HarmonicMusicTheory.lean`): This file establishes consonance from Pythagorean triple ratios and proves properties of the circle of fifths. Our work extends this by treating consonance as a graph-theoretic property rather than a ratio-based one, revealing the transition structure invisible to the frequency-ratio approach.

2. **MusicalCounterpoint.lean** (`Catalog/Algebra/MusicalCounterpoint.lean`): This file develops the voice leading cost function as a seminorm with lattice structure. Our Theorem E bridges this to the categorical/graph-theoretic framework by showing that cost provides a grading compatible with composition, and the meet-join identity holds in the two-voice specialization.

The key insight connecting these works: the Pythagorean approach tells us *which* intervals are consonant (via ratio complexity bounds), the constraint satisfaction approach tells us *how* to measure voice leading quality (via the L¹ seminorm), and our graph-theoretic approach reveals *which transitions are possible* and their structural properties.

## 6. Discussion

### 6.1 The Conjecture

The original research direction conjectured that the first-species counterpoint category is equivalent to the thin category generated by a specific poset of 12 elements. Our results show this is not quite right:

1. The transition graph is not a poset (it has cycles: 3 → 4 → 3).
2. The reachability preorder collapses to a single equivalence class (diameter 2 means everything reaches everything).
3. However, the accessibility preorder (Section 4) does give a genuine 2-level poset.

The refined conjecture would be: the counterpoint category is a finite category with 6 objects, 26 morphisms, and a 2-level accessibility stratification into perfect and imperfect consonances.

### 6.2 Categorification

The transition graph defines a finite category:
- **Objects**: consonant interval classes {0, 3, 4, 7, 8, 9}
- **Morphisms**: valid stepwise voice leadings (with appropriate identification)
- **Composition**: sequential application of voice leadings

The functoriality of the interval change map (Theorem E.3) makes the interval class assignment a functor from this category to ℤ/12ℤ (viewed as a group acting on itself). The cost function provides a grading that is subadditive under composition.

## 7. Future Work

1. Extend to second-species and third-species counterpoint (passing tones, suspensions)
2. Analyze the transition graph for different stepwise bounds
3. Study the spectral properties of the 26-edge adjacency matrix
4. Investigate the relationship between graph connectivity and musical tension/resolution
5. Formalize the three-or-more-voice generalization where the perfect fourth becomes consonant

## References

- Fux, J.J. (1725). *Gradus ad Parnassum*.
- Tymoczko, D. (2011). *A Geometry of Music*.
- Mazzola, G. (2002). *The Topos of Music*.
- `Catalog/Pythagorean/HarmonicMusicTheory.lean` — Pythagorean music theory formalization
- `Catalog/Algebra/MusicalCounterpoint.lean` — Voice leading cost as seminorm
