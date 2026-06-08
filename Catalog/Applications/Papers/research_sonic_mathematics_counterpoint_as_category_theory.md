# The Counterpoint Quiver: Voice-Leading Constraints as Directed Graph Structure

**A Formal Study of First-Species Counterpoint over Equal Temperaments**

---

## Abstract

We formalize the rules of first-species counterpoint (after Fux, 1725) as a directed multigraph—the **Counterpoint Quiver**—whose vertices are consonant interval classes modulo *n* semitones and whose edges are voice leadings satisfying the prohibition on parallel motion into perfect consonances. Working over the cyclic group ℤ/nℤ, we introduce a parameterized algebraic structure, `CounterpointSystem n`, that captures counterpoint-like constraints for arbitrary equal temperaments.

For the standard 12-tone system, we establish five principal results: (1) strong connectivity of the quiver; (2) failure of edge composability, proving that permitted voice leadings do not form a subcategory; (3) a 12:1 self-loop asymmetry between imperfect and perfect consonances; (4) non-preservation of the consonance set under interval inversion; and (5) explicit hom-set cardinalities (61 incoming edges for perfect consonances vs. 72 for imperfect). Complementing the quiver-theoretic analysis, we develop a metric theory of voice-leading cost as an L¹ seminorm on the voice motion lattice, proving a lattice identity relating meet/join costs to component costs.

All results have been machine-verified.

**Keywords:** counterpoint, voice leading, directed graph, category theory, equal temperament, lattice theory, seminorm

---

## 1. Introduction

### 1.1 Motivation

The theory of musical counterpoint, formalized by Fux in *Gradus ad Parnassum* (1725), prescribes rules governing the simultaneous motion of independent melodic lines. Central among these is the prohibition on *parallel motion into perfect consonances*: two voices sounding a perfect fifth (or octave) may not both move by the same nonzero interval to arrive at another perfect fifth (or octave).

Despite extensive musicological study (Jeppesen 1939, Salzer & Schachter 1969, Tymoczko 2011), the algebraic structure implied by these constraints has not been fully characterized. Tymoczko's geometric approach models voice leadings as points in an orbifold, while Mazzola's *Topos of Music* (2002) applies categorical methods at a high level of abstraction. Our approach is more elementary and combinatorially explicit: we model permitted voice leadings as edges in a finite directed graph and study the graph-theoretic consequences of Fux's rules.

### 1.2 Contributions

1. **A parameterized algebraic structure** (`CounterpointSystem n`) that captures counterpoint constraints over ℤ/nℤ for any positive integer *n*, enabling systematic comparison across equal temperaments.

2. **The Counterpoint Quiver**: a finite directed multigraph whose vertices are consonant intervals and whose edges are permitted voice leadings, with explicit edge counts.

3. **Five structural theorems** about the 12-TET quiver (connectivity, non-composability, self-loop asymmetry, inversion asymmetry, hom-set cardinalities).

4. **A lattice-theoretic cost framework**: voice-leading cost as an L¹ seminorm on the ℤ-module of voice motions, with a lattice identity connecting meet/join costs to component costs.

5. **Machine-verified proofs** of all claims, providing certainty beyond peer review.

### 1.3 Related Work

- **Tymoczko (2006, 2011)**: Models voice leading geometrically as paths in orbifolds. Our approach is combinatorial rather than continuous.
- **Mazzola (2002)**: Applies topos theory to music. Our categorical observations are elementary (quiver-theoretic, not topos-theoretic).
- **Agmon (1997)**: Studies diatonic voice leading with linear-algebraic methods. We work chromatically over ℤ/12ℤ.
- **Hook (2007)**: Uniform triadic transformations as a group. Our morphisms are not group elements but constrained graph edges.

---

## 2. Definitions

### 2.1 The CounterpointSystem Structure

**Definition 2.1** (*CounterpointSystem*). A **counterpoint system of order *n*** (where *n* ≥ 1) is a tuple (C, P) where:
- C ⊆ ℤ/nℤ is a nonempty finite set of **consonant intervals**,
- P ⊆ C is a nonempty subset of **perfect consonances**,
- There exists at least one element of C \ P (an **imperfect consonance**).

The requirement that imperfect consonances exist is essential: a system with only perfect consonances would be trivially constrained (all non-identity voice leadings would be restricted).

**Definition 2.2** (*Voice Leading*). A **voice leading** over ℤ/nℤ is a pair (b, s) ∈ (ℤ/nℤ)², where *b* is the bass motion and *s* is the soprano motion (both in semitones mod *n*).

**Definition 2.3** (*Target Interval*). Given a source interval *i* ∈ ℤ/nℤ and a voice leading (b, s), the **target interval** is:

$$j = i + s - b$$

This follows from the definition: if the initial interval is *i* = soprano pitch − bass pitch, and bass moves by *b* while soprano moves by *s*, the new interval is *(soprano + s) − (bass + b) = i + s − b*.

**Definition 2.4** (*Parallel Motion*). A voice leading (b, s) exhibits **parallel motion** if b = s ≠ 0. Both voices move by the same nonzero amount.

**Definition 2.5** (*Permitted Voice Leading*). A voice leading (b, s) from interval *i* to interval *j* is **permitted** in a counterpoint system (C, P) if:
1. i ∈ C and j ∈ C (both intervals are consonant),
2. j = i + s − b (the voice leading maps *i* to *j*),
3. ¬(j ∈ P ∧ b = s ≠ 0) (parallel motion into a perfect consonance is forbidden).

### 2.2 The Standard 12-TET System

**Definition 2.6**. The **standard 12-TET counterpoint system** is:
- C = {0, 3, 4, 7, 8, 9} ⊂ ℤ/12ℤ (unison, minor third, major third, perfect fifth, minor sixth, major sixth)
- P = {0, 7} ⊂ C (unison/octave and perfect fifth)

This matches the traditional classification in first-species counterpoint. Note that the perfect fourth (5 semitones) is treated as dissonant above the bass, which is standard in Fux's framework.

### 2.3 The Canonical Voice Leading

**Definition 2.7**. The **canonical voice leading** from *i* to *j* is (0, j − i): the bass remains stationary while the soprano moves by exactly *j* − *i* semitones.

This construction is central to the connectivity proof.

### 2.4 Voice-Leading Cost

**Definition 2.8**. For *n* voices with motion vector m ∈ ℤⁿ, the **voice-leading cost** is the L¹ norm:

$$\text{cost}(m) = \sum_{k=1}^{n} |m_k|$$

This is the standard measure of voice-leading efficiency in music theory: smaller total displacement means smoother voice leading.

---

## 3. Main Results: Quiver Structure

### 3.1 Strong Connectivity

**Theorem 3.1** (*exists_permitted_voice_leading*). For any consonant intervals *i, j* ∈ C in the standard 12-TET system, there exists a permitted voice leading from *i* to *j*.

*Proof sketch.* Case split on whether *i* = *j*:
- If *i* ≠ *j*: The canonical voice leading (0, j − i) maps *i* to *j* by construction (`targetInterval_canonical`). It has bass motion 0, so it is never parallel (`canonical_not_parallel`), and Fux's rule cannot trigger.
- If *i* = *j*: The identity voice leading (0, 0) is permitted. It maps *i* to itself, and it is not parallel (since the bass motion is 0). This holds for all six consonant intervals, verified by case analysis. ∎

**Corollary.** The Counterpoint Quiver on the standard 12-TET system is strongly connected as a directed graph.

### 3.2 Non-Composability

**Theorem 3.2** (*non_composability*). There exist consonant intervals *i, j, k* and voice leadings *vl₁, vl₂* such that *vl₁* is permitted from *i* to *j*, *vl₂* is permitted from *j* to *k*, but the composed voice leading (vl₁.bass + vl₂.bass, vl₁.soprano + vl₂.soprano) is NOT permitted from *i* to *k*.

*Proof sketch.* Explicit construction: Choose *i, j, k* among the six consonant intervals and voice leadings such that each individual step uses oblique or contrary motion (legal), but the composite is parallel motion arriving at a perfect consonance (illegal). The composition of bass motions equals the composition of soprano motions and is nonzero, while the target is in P. ∎

**Remark.** This is the central structural theorem. It means that the edge set of the Counterpoint Quiver does NOT form a subcategory of the free category on its vertices. The permitted voice leadings are a **quiver** in the strict sense—a directed graph without guaranteed composition—rather than a category.

### 3.3 Self-Loop Asymmetry

**Theorem 3.3** (*perfect_self_loop_unique*). For any perfect consonance *p* ∈ P in the standard 12-TET system, there is exactly **1** permitted voice leading from *p* to itself: the identity (0, 0).

*Proof sketch.* A voice leading (b, s) from *p* to *p* requires *p + s − b = p*, hence *s = b*. If *b* ≠ 0, the motion is parallel into a perfect consonance—forbidden. So *b* = *s* = 0. ∎

**Theorem 3.4** (*imperfect_self_loops_all*). For any imperfect consonance *q* ∈ C \ P, there are exactly **12** permitted voice leadings from *q* to itself.

*Proof sketch.* The constraint *s = b* must hold (same arithmetic as above). Since *q* ∉ P, parallel motion is unrestricted. Each of the 12 values of *b* ∈ ℤ/12ℤ gives a valid self-loop (b, b). ∎

**Corollary.** The ratio of self-loops at imperfect to perfect consonances is 12:1. This is the categorical manifestation of the "rigidity" of perfect consonances.

### 3.4 Voice-Swap Asymmetry

**Theorem 3.5** (*voice_swap_breaks_consonance*). The involution σ: ℤ/12ℤ → ℤ/12ℤ, σ(i) = −i, does **not** preserve the consonance set C = {0, 3, 4, 7, 8, 9}.

*Proof sketch.* σ(7) = −7 = 5 mod 12. But 5 ∉ C (the perfect fourth is not consonant in first-species counterpoint). ∎

**Remark.** This theorem formalizes the asymmetric role of the bass voice. In counterpoint, the interval is measured *upward* from the bass; swapping voices measures downward, which is equivalent to negation mod 12. The fact that σ does not preserve C means the voice-leading constraints are not symmetric under voice exchange.

### 3.5 Hom-Set Cardinalities

**Theorem 3.6** (*total_permitted_to_perfect*). The total number of permitted voice leadings arriving at any fixed perfect consonance *p* ∈ P, summed over all consonant sources, is **61**.

**Theorem 3.7** (*total_permitted_to_imperfect*). The total number of permitted voice leadings arriving at any fixed imperfect consonance *q* ∈ C \ P, summed over all consonant sources, is **72**.

*Proof.* Direct enumeration over the 6 × 144 = 864 candidate voice leadings, filtering by the permissibility predicate. Both results are verified by decidable computation. ∎

**Corollary.** Perfect consonances receive approximately 15.3% fewer incoming voice leadings than imperfect consonances (61/72 ≈ 0.847), quantifying the compositional constraint imposed by Fux's rule.

---

## 4. Main Results: Metric and Lattice Structure

### 4.1 The Cost Seminorm

**Theorem 4.1** (*cost_seminorm_properties*). The voice-leading cost function cost: ℤⁿ → ℤ satisfies:
1. **Nonnegativity**: cost(m) ≥ 0 for all m.
2. **Subadditivity** (Triangle Inequality): cost(m₁ + m₂) ≤ cost(m₁) + cost(m₂).
3. **Absolute Homogeneity**: cost(c · m) = |c| · cost(m) for all c ∈ ℤ.

*Proof sketch.* Property (1) follows from nonnegativity of absolute values. Property (2) is the triangle inequality for absolute values, summed componentwise. Property (3) uses |c · mₖ| = |c| · |mₖ| and linearity of summation. ∎

**Corollary.** cost is a seminorm on the ℤ-module ℤⁿ. It is in fact a norm (cost(m) = 0 ⟹ m = 0 by `cost_eq_zero_iff`).

### 4.2 The Lattice Identity

The voice motion space ℤⁿ carries a distributive lattice structure under componentwise min (⊓) and max (⊔).

**Theorem 4.2** (*cost_meet_join_eq*). For all voice motions m₁, m₂ ∈ ℤⁿ:

$$\text{cost}(m_1 \wedge m_2) + \text{cost}(m_1 \vee m_2) = \text{cost}(m_1) + \text{cost}(m_2)$$

*Proof sketch.* Reduces to the pointwise identity |min(a,b)| + |max(a,b)| = |a| + |b| for integers, which holds by case analysis on the sign and ordering of *a* and *b*. ∎

**Remark.** This identity is the L¹ analogue of the modular law for valuations on a lattice. It implies that the meet and join operations redistribute cost without creating or destroying it—a conservation law for voice-leading effort.

### 4.3 Ascending Motion Sublattice

**Definition.** A voice motion m ∈ ℤⁿ is **ascending** if mₖ ≥ 0 for all k.

**Theorem 4.3** (*ascending_meet*, *ascending_join*). The ascending motions form a sublattice of (ℤⁿ, ⊓, ⊔).

**Theorem 4.4** (*ascending_cost_eq_sum*). For ascending m: cost(m) = Σₖ mₖ.

**Theorem 4.5** (*ascending_meet_cost_le*). For ascending m₁, m₂: cost(m₁ ⊓ m₂) ≤ cost(m₁).

*Interpretation.* Taking the componentwise minimum of two ascending motions never increases cost. This means that "smoothing" two upward voice leadings by taking their meet always produces a motion at least as efficient.

### 4.4 Interval Preservation

**Theorem 4.6** (*parallel_preserves_interval*). If two voices move in parallel (by the same amount), the interval between them is preserved.

**Theorem 4.7** (*nonparallel_changes_interval*). If two voices move non-parallel, the interval between them necessarily changes.

These are the formal counterparts of elementary counterpoint principles. Together with the non-composability theorem, they explain *why* parallel motion into perfect consonances is problematic: it's the only type of motion that preserves the interval, and perfect consonances are "too rigid" to tolerate being held via non-trivial motion.

---

## 5. Computational Aspects

### 5.1 Decidability

All predicates in the framework—consonance, parallel motion, permissibility—are decidable over ℤ/nℤ, enabling computational verification. The hom-set cardinalities (Theorems 3.6–3.7) are proved by `decide` tactics that exhaustively enumerate the finite state space.

### 5.2 Complexity

For a system of order *n* with |C| consonant intervals, the Counterpoint Quiver has at most |C|² · n² edges (each source-target pair admits up to n² voice leadings). For the 12-TET system: 6² × 144 = 5184 candidate edges, of which the permitted subset can be enumerated in O(n²|C|²) time.

### 5.3 Optimal Voice Leading

**Theorem 5.1** (*optimal_exists_of_finset*). Given a nonempty finite set of voice motions, there exists one of minimum cost.

Combined with the decidability of the permissibility predicate, this guarantees that the optimal permitted voice leading between any two consonant intervals can be found by finite enumeration.

---

## 6. Discussion

### 6.1 Why Not a Category?

The non-composability theorem (Theorem 3.2) is the most structurally significant result. In abstract algebra, it is natural to ask whether a collection of morphisms forms a category. The voice-leading edges of the Counterpoint Quiver fail this test: composition is not guaranteed to stay within the permitted set.

This failure has a musical interpretation. Good counterpoint requires *global* planning—one cannot simply chain together locally valid moves. The non-composability means that a composer who thinks only one step ahead may paint themselves into a corner where the *next* move requires an illegal parallel motion into a perfect consonance.

Pedagogically, this is exactly the experience of students learning counterpoint: individual rules seem simple, but satisfying all of them simultaneously requires looking ahead.

### 6.2 The 12:1 Ratio as Design Principle

The self-loop asymmetry (Theorems 3.3–3.4) suggests that the distinction between perfect and imperfect consonances is not merely a classification but a *design constraint* of the system. Perfect consonances are "attractors" in the sense that the system wants to reach them, but "bottlenecks" in the sense that sustaining them (via self-loops) is heavily restricted.

This creates a natural tension—exactly the kind of tension that makes counterpoint musically interesting. A perfect fifth is a satisfying goal but a dangerous resting place.

### 6.3 Generalization to Other Temperaments

The parameterization by *n* enables systematic study of counterpoint in non-standard temperaments:

| Temperament | n | Notes |
|-------------|---|-------|
| 12-TET | 12 | Standard Western tuning |
| 19-TET | 19 | Better minor thirds; used by Costeley (1570) |
| 31-TET | 31 | Excellent septimal intervals; Huygens (1691) |
| 53-TET | 53 | Close to Pythagorean/just; Mercator/Bosanquet |

For each *n*, one must specify the consonant and perfect interval sets. The structural theorems can then be instantiated, and new quantitative invariants (self-loop ratios, hom-set sizes) computed.

### 6.4 Connection to Pythagorean Theory

The consonant intervals {0, 3, 4, 7, 8, 9} have a Pythagorean pedigree. The companion formalization establishes that primitive Pythagorean triples generate the frequency ratios 4/3 (perfect fourth), 5/4 (major third), and 5/3 (major sixth) via leg and hypotenuse ratios—exactly the intervals (or their complements) in our consonance set.

The Counterpoint Quiver thus studies the *dynamics* of consonance: not what makes intervals consonant (that's the Pythagorean question), but how consonant intervals connect through permitted voice leadings.

---

## 7. Future Work

1. **Higher species**: Extend to second- through fifth-species counterpoint, where rhythmic and melodic constraints introduce additional graph structure.

2. **Three-voice counterpoint**: Generalize from two voices to three, where the state space is (ℤ/nℤ)² (two intervals) and the constraint structure is richer.

3. **Categorical enrichment**: While the edge set is not a category, one can ask whether it generates a free category with interesting properties (e.g., word length = number of voice-leading steps).

4. **Topological analysis**: Study the simplicial complex whose simplices are cliques of mutually compatible voice leadings—this could reveal higher-dimensional structure in the constraint space.

5. **Computational enumeration**: For each *n* in {12, 19, 24, 31, 53}, compute the full Counterpoint Quiver and its graph-theoretic invariants (chromatic number, clique number, diameter).

6. **Connection to orbifold geometry**: Relate the Counterpoint Quiver to Tymoczko's continuous voice-leading spaces, potentially as a combinatorial shadow of the orbifold structure.

---

## 8. Summary of Formal Results

| Result | Statement | Proof Method |
|--------|-----------|-------------|
| Theorem 3.1 | Strong connectivity | Canonical voice leading construction |
| Theorem 3.2 | Non-composability | Explicit counterexample |
| Theorem 3.3 | Perfect self-loops = 1 | Algebraic + Fux constraint |
| Theorem 3.4 | Imperfect self-loops = 12 | Enumeration (no constraint) |
| Theorem 3.5 | Voice swap ≠ consonance-preserving | σ(7) = 5 ∉ C |
| Theorem 3.6 | Incoming to perfect = 61 | Decidable computation |
| Theorem 3.7 | Incoming to imperfect = 72 | Decidable computation |
| Theorem 4.1 | Cost is a seminorm | Abs. value properties |
| Theorem 4.2 | Cost lattice identity | Pointwise case analysis |
| Theorem 4.3 | Ascending sublattice | Min/max preserve ≥ 0 |
| Theorem 4.6 | Parallel preserves interval | Direct calculation |
| Theorem 4.7 | Non-parallel changes interval | Contrapositive |

---

## References

1. Fux, J.J. (1725). *Gradus ad Parnassum*. Vienna.
2. Jeppesen, K. (1939). *Counterpoint: The Polyphonic Vocal Style of the Sixteenth Century*. Prentice-Hall.
3. Tymoczko, D. (2006). "The Geometry of Musical Chords." *Science*, 313(5783), 72–74.
4. Tymoczko, D. (2011). *A Geometry of Music*. Oxford University Press.
5. Mazzola, G. (2002). *The Topos of Music*. Birkhäuser.
6. Agmon, E. (1997). "Musical Durations as Mathematical Intervals." *Music Theory Online*, 3(6).
7. Hook, J. (2007). "Uniform Triadic Transformations." *Journal of Music Theory*, 46(1/2), 57–126.
8. Salzer, F. & Schachter, C. (1969). *Counterpoint in Composition*. McGraw-Hill.
