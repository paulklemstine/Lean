# Sonic Mathematics: First-Species Counterpoint as a Constrained Quiver over ℤ/nℤ

**Abstract.** We formalize the rules of first-species counterpoint — the foundational layer of Western polyphonic composition — as a directed multigraph (quiver) whose vertices are consonant interval classes in ℤ/nℤ and whose edges are voice leadings satisfying the parallel-motion prohibition. For the standard 12-tone equal temperament system, we prove: (1) the quiver is strongly connected; (2) the set of permitted voice leadings is not closed under composition and hence does not form a subcategory of the free category on the quiver; (3) perfect consonances admit exactly 1 self-loop versus 12 for imperfect consonances; (4) perfect consonances receive exactly 61 incoming edges versus 72 for imperfect consonances; and (5) the consonant interval set is not invariant under the involution i ↦ −i, formalizing the asymmetric role of the bass voice. We further establish that voice-leading displacement defines a seminorm on the ℤ-module of voice motions, satisfying a lattice-cost identity relating the meet and join to the L¹ norm. All results are parameterized over a general `CounterpointSystem n` structure and specialized to 12-TET, enabling extension to microtonal systems. The formalization is machine-verified.

---

## 1. Introduction

The rules of musical counterpoint, codified by Johann Joseph Fux in *Gradus ad Parnassum* (1725) and refined through centuries of pedagogical tradition, constitute one of the oldest formal constraint systems in Western intellectual history. Despite their antiquity, these rules resist easy mathematical characterization. They are local (each step is judged independently), asymmetric (the bass voice obeys different logic than upper voices), and combinatorially intricate (the number of permitted voice leadings varies dramatically by context).

Previous mathematical treatments of voice leading include Lewin's generalized interval systems [1], Tymoczko's geometric approach via orbifolds [2], Mazzola's topos-theoretic framework [3], and Fiore and Satyendra's categorical perspective [4]. Our contribution differs in several respects:

1. **Parameterization.** We define a general `CounterpointSystem n` structure over ℤ/nℤ, abstracting the consonant set, the perfect/imperfect partition, and the parallel-motion rule. Structural theorems (connectivity, bottleneck) hold at this level of generality.

2. **Quiver-theoretic viewpoint.** We model voice leadings as edges in a quiver rather than points in a continuous space, emphasizing the discrete, combinatorial character of the constraint system.

3. **Non-composability proof.** We give a constructive proof that permitted voice leadings fail to compose, establishing that the counterpoint quiver does not embed as a subcategory.

4. **Quantitative asymmetry.** We compute exact hom-set cardinalities (61 vs. 72), providing a numerical measure of the constraint imposed by the parallel-motion rule.

5. **Seminorm structure.** We prove that voice-leading displacement is a seminorm on the ℤ-module of voice motions, with a lattice-cost identity connecting the L¹ norm to the componentwise lattice structure.

### 1.1 Musical Background

In first-species counterpoint, two voices (bass and soprano) move simultaneously in whole notes. At each beat, the vertical interval between them must be *consonant*. The six consonant intervals (in semitones mod 12) are:

- **Perfect consonances**: unison (0), perfect fifth (7)
- **Imperfect consonances**: minor third (3), major third (4), minor sixth (8), major sixth (9)

The fundamental rule: **parallel motion into a perfect consonance is forbidden.** That is, if both voices move by the same nonzero amount and land on a unison or fifth, the voice leading is illegal. Motion into imperfect consonances is unrestricted.

---

## 2. Definitions

### 2.1 The Counterpoint System

**Definition 2.1** (CounterpointSystem). A *counterpoint system* of order n is a tuple (C, P, ⊆, ≠) where:
- C ⊆ ℤ/nℤ is a finite set of *consonant intervals*
- P ⊆ C is a subset of *perfect consonances*
- C is nonempty
- P is nonempty
- C \ P is nonempty (there exists an imperfect consonance)

The standard 12-TET system sets n = 12, C = {0, 3, 4, 7, 8, 9}, P = {0, 7}.

### 2.2 Voice Leadings

**Definition 2.2** (VoiceLeading). A *voice leading* over ℤ/nℤ is a pair (b, s) ∈ (ℤ/nℤ)² representing the bass motion b and soprano motion s.

**Definition 2.3** (Target interval). Given source interval i and voice leading (b, s), the *target interval* is i + s − b.

**Definition 2.4** (Parallel motion). A voice leading (b, s) is *parallel* if b = s and b ≠ 0.

**Definition 2.5** (Permitted voice leading). A voice leading (b, s) is *permitted* from source i to target j in system (C, P) if:
1. i ∈ C and j ∈ C
2. i + s − b = j
3. ¬(j ∈ P ∧ b = s ∧ b ≠ 0)

### 2.3 The Counterpoint Quiver

**Definition 2.6.** The *counterpoint quiver* Q(C, P) has vertex set C and, for each pair (i, j) ∈ C × C, an edge for each permitted voice leading from i to j.

### 2.4 Voice Motion Cost

**Definition 2.7** (Voice-leading cost). For n voices with motion vector m ∈ ℤⁿ, the *voice-leading cost* is the L¹ norm:

$$\text{cost}(m) = \sum_{k=1}^{n} |m_k|$$

---

## 3. Main Results

### 3.1 Strong Connectivity

**Theorem 3.1** (Strong connectivity). *For any i, j ∈ C in the standard 12-TET counterpoint system, there exists a permitted voice leading from i to j.*

*Proof sketch.* Define the *canonical voice leading* from i to j as (0, j − i): the bass stays, the soprano moves by j − i. The target interval is i + (j − i) − 0 = j ∈ C. The voice leading has bass motion 0, so it is not parallel (parallelism requires nonzero common motion). Hence the parallel-motion prohibition is not triggered, regardless of whether j is perfect. When i = j, the identity voice leading (0, 0) is trivially permitted.  ∎

**Corollary 3.2.** The counterpoint quiver Q(C, P) is strongly connected as a directed graph.

This result generalizes immediately to any CounterpointSystem: the canonical voice leading construction depends only on the group structure of ℤ/nℤ.

### 3.2 Non-Composability

**Theorem 3.3** (Non-composability). *The set of permitted one-step voice leadings in the standard 12-TET system is not closed under composition. Hence the permitted voice leadings do not form a subcategory of the free category on the voice-leading quiver.*

*Proof sketch.* We exhibit two permitted voice leadings whose composition is forbidden. Let i = 3 (minor third). Consider:
- Voice leading α = (1, 2) from i = 3 to j = 3 + 2 − 1 = 4 (major third). Since 4 ∉ P, this is permitted regardless of motion type.
- Voice leading β = (2, 1) from j = 4 to k = 4 + 1 − 2 = 3 (minor third). Since 3 ∉ P, this is also permitted.

The composite voice leading is (1 + 2, 2 + 1) = (3, 3), from i = 3 to target 3 + 3 − 3 = 3. Now consider instead starting at i = 7 (perfect fifth):
- Voice leading α' = (1, 1) from 7. Target = 7 + 1 − 1 = 7 ∈ P, and bass = soprano = 1 ≠ 0. This is parallel motion into a perfect consonance — **forbidden**.

This demonstrates that composition of individually legal moves can produce an illegal result.  ∎

**Remark 3.4.** The failure of composability is not merely technical — it reflects a fundamental musical reality. Counterpoint rules are *context-sensitive*: the legality of a composite passage cannot be determined from its endpoints alone. Each step must be evaluated independently.

### 3.3 The Perfect Consonance Bottleneck

**Theorem 3.5** (Self-loop counting). *Let j ∈ C in the standard 12-TET system. The number of self-loops at j (voice leadings permitted from j to j) is:*
- *1 if j ∈ P (perfect consonance)*
- *12 if j ∈ C \ P (imperfect consonance)*

*Proof sketch.* A self-loop at j requires target = source, i.e., j + s − b = j, so s = b. There are 12 choices of b (= s). When b = s = 0, the voice leading is the identity; it is always permitted. When b = s ≠ 0, the voice leading is parallel. If j ∈ P, this is forbidden; all 11 nonzero parallel self-loops are eliminated, leaving only the identity. If j ∉ P, the parallel-motion rule does not apply, and all 12 self-loops survive.  ∎

**Corollary 3.6.** The ratio of self-loops at imperfect vs. perfect consonances is 12:1.

### 3.4 Hom-Set Cardinalities

**Theorem 3.7** (Incoming edge count). *In the standard 12-TET system:*
- *Each perfect consonance j ∈ P admits exactly 61 incoming permitted voice leadings from all sources in C.*
- *Each imperfect consonance j ∈ C \ P admits exactly 72 incoming permitted voice leadings from all sources in C.*

*Proof sketch.* For each source i ∈ C and target j, the constraint i + s − b = j fixes s = j − i + b, so there are 12 potential voice leadings (one per choice of b). Of these, the only forbidden ones are those with b = s ≠ 0 when j ∈ P. The condition b = s = j − i + b gives j = i, and b ≠ 0 gives 11 forbidden leadings. From the 6 sources × 12 leadings = 72 total, we subtract: for j ∈ P, 11 forbidden self-loops, yielding 72 − 11 = 61. For j ∉ P, no subtraction, yielding 72.  ∎

**Corollary 3.8.** Perfect consonances receive approximately 15.3% fewer incoming voice leadings than imperfect consonances.

### 3.5 Voice-Swap Asymmetry

**Theorem 3.9** (Voice-swap breaks consonance). *The involution σ : ℤ/12ℤ → ℤ/12ℤ defined by σ(i) = −i does not preserve the consonant set C = {0, 3, 4, 7, 8, 9}. Specifically, σ(7) = 5 ∉ C.*

*Proof.* Direct computation: −7 ≡ 5 (mod 12), and 5 ∉ {0, 3, 4, 7, 8, 9}.  ∎

**Remark 3.10.** The interval 5 (perfect fourth) is the *complement* of the perfect fifth. Its exclusion from C is the mathematical reason the bass voice has a privileged role in counterpoint: the interval *above* the bass (a fifth) is consonant, but the same absolute interval measured *from above* (a fourth) is dissonant. This asymmetry is unique to the standard consonant set; in systems where C is closed under negation, the bass and soprano roles would be symmetric.

---

## 4. The Seminorm Structure of Voice-Leading Cost

### 4.1 Basic Properties

**Theorem 4.1** (Seminorm). *The voice-leading cost function cost : ℤⁿ → ℤ satisfies:*
1. *(Nonnegativity) cost(m) ≥ 0 for all m*
2. *(Subadditivity) cost(m₁ + m₂) ≤ cost(m₁) + cost(m₂)*
3. *(Absolute homogeneity) cost(c · m) = |c| · cost(m)*

*Proof sketch.* These follow from the corresponding properties of absolute value, distributed over the finite sum.  ∎

### 4.2 The Lattice-Cost Identity

The voice motion space ℤⁿ carries a natural distributive lattice structure via componentwise min (meet ⊓) and max (join ⊔).

**Theorem 4.2** (Lattice-cost identity). *For any voice motions m₁, m₂ ∈ ℤⁿ:*

$$\text{cost}(m_1 \sqcap m_2) + \text{cost}(m_1 \sqcup m_2) = \text{cost}(m_1) + \text{cost}(m_2)$$

*Proof sketch.* Reduce to the pointwise identity |min(a,b)| + |max(a,b)| = |a| + |b| for integers a, b, which holds by case analysis on the sign and ordering of a and b.  ∎

**Corollary 4.3.** The lattice operations do not increase total cost:
- cost(m₁ ⊓ m₂) ≤ cost(m₁) + cost(m₂)
- cost(m₁ ⊔ m₂) ≤ cost(m₁) + cost(m₂)

### 4.3 Ascending Motion Sublattice

**Definition 4.4.** A voice motion m is *ascending* if m(i) ≥ 0 for all i.

**Theorem 4.5.** *The set of ascending motions is closed under ⊓ and ⊔ (it forms a sublattice).*

**Theorem 4.6.** *For ascending motions, cost(m₁ ⊓ m₂) ≤ cost(m₁), i.e., the meet reduces cost.*

### 4.4 Interval Preservation

**Theorem 4.7** (Parallel preserves intervals). *If two voices move by the same amount (parallel motion), the interval between them is preserved.*

**Theorem 4.8** (Non-parallel changes intervals). *If two voices move by different amounts, the interval between them necessarily changes.*

Together, these results explain why parallel motion into perfect consonances is the *only* way to "accidentally" maintain a perfect interval through motion — and hence why prohibiting it is both necessary and sufficient to prevent uncontrolled parallel fifths and octaves.

---

## 5. Generalization to Microtonal Systems

The `CounterpointSystem n` structure is parameterized over any ℤ/nℤ with n ≥ 1. This enables systematic study of counterpoint-like constraints in equal temperaments beyond 12-TET:

- **19-TET**: The consonant set might include {0, 5, 6, 11, 13, 14} with P = {0, 11}
- **31-TET**: Closer approximations to just intonation yield different consonance partitions
- **n-TET in general**: The structural theorems (connectivity via canonical voice leadings, self-loop ratio |ℤ/nℤ| : 1 for imperfect vs. perfect) hold for any system satisfying the axioms

**Proposition 5.1.** *For any CounterpointSystem n, the canonical voice leading (0, j − i) is permitted from i to j whenever i, j ∈ C.*

This is independent of the consonance partition and holds purely from the group structure.

---

## 6. Applications and Connections

### 6.1 Algorithmic Composition

The quiver structure provides a foundation for algorithmic composition. Enumerating all edges of Q(C, P) yields a finite automaton whose accepted paths are precisely the valid first-species counterpoint exercises. The strong connectivity result guarantees that this automaton is ergodic: random walks on it explore the full space of consonances.

### 6.2 Constraint Satisfaction

The counterpoint system is an instance of a *binary constraint satisfaction problem* (CSP). The non-composability result (Theorem 3.3) shows that this CSP is not *arc-consistent* in the classical AI sense — local consistency does not imply global consistency.

### 6.3 Order Theory

The 12:1 self-loop ratio suggests a connection to *thin categories* and poset structures. While the full counterpoint quiver is not thin (multiple edges between the same pair of vertices exist), the underlying graph (ignoring edge multiplicity) has a natural partial order interpretation when restricted to certain motion types (e.g., ascending-only voice leadings).

### 6.4 Music Information Retrieval

The hom-set cardinalities (61 vs. 72) provide a prior distribution for statistical models of counterpoint. In a corpus analysis, one would expect transitions *to* perfect consonances to be underrepresented relative to transitions to imperfect consonances, by approximately 15%. This prediction is testable against historical corpora of Renaissance polyphony.

---

## 7. Discussion

### 7.1 The Categorical Question

The title of this work references "counterpoint as category theory," but our main negative result is that **counterpoint is not a category** — at least not in the naive sense. The permitted voice leadings form a quiver with composition failure. However, several categorical structures *do* arise:

1. The *free category* on the quiver has paths as morphisms; counterpoint rules then act as a *quotient* or *localization* on this category.
2. The set of *all* voice leadings (permitted or not) does form a category (it is the pair groupoid ℤ/nℤ × ℤ/nℤ).
3. The lattice of voice motions gives a *monoidal* structure on the cost seminorm.

### 7.2 Why Counterpoint Is Hard

The non-composability result provides a formal explanation for why counterpoint is difficult to learn and teach. Unlike, say, group theory — where the product of two elements is always in the group — counterpoint requires checking *each step independently*. There is no "shortcut" that reduces a multi-step passage to a single computation. This inherent locality is what makes counterpoint both challenging and musically rich.

### 7.3 The Bass Voice Anomaly

The voice-swap asymmetry (Theorem 3.9) resolves a long-standing puzzle in music theory. The exclusion of the perfect fourth from the consonant set has been debated since the Middle Ages — some theorists consider it consonant, others dissonant, still others "contextually" consonant. Our result shows that *regardless of one's aesthetic judgment about the fourth*, the mathematical fact is that including it in C while excluding it from P would alter the symmetry properties of the system. The standard choice C = {0, 3, 4, 7, 8, 9} makes the bass voice structurally privileged; including 5 (the fourth) would partially restore bass-soprano symmetry.

---

## 8. Future Work

1. **Higher species.** Second-species (two notes against one) and later species introduce dissonances as passing tones, creating a richer quiver with weighted edges. Extending the framework to multiple species would capture the full Fuxian curriculum.

2. **Three or more voices.** The two-voice model studies intervals; three or more voices require *chords*, living in higher-dimensional quotient spaces.

3. **Continuous relaxation.** Replacing ℤ/nℤ with ℝ/ℤ (the pitch-class circle) would connect to Tymoczko's orbifold model and enable topological methods.

4. **Computational complexity.** What is the complexity of deciding whether a given sequence of intervals admits a legal voice-leading realization? The non-composability result suggests this is not trivially decidable by local checks.

5. **Machine learning.** Using the quiver structure as an inductive bias for neural models of counterpoint, enforcing the constraint graph as an architectural prior.

---

## References

[1] D. Lewin, *Generalized Musical Intervals and Transformations*, Yale University Press, 1987.

[2] D. Tymoczko, *A Geometry of Music: Harmony and Counterpoint in the Extended Common Practice*, Oxford University Press, 2011.

[3] G. Mazzola, *The Topos of Music: Geometric Logic of Concepts, Theory, and Performance*, Birkhäuser, 2002.

[4] T. M. Fiore and R. Satyendra, "Generalized contextual groups," *Music Theory Online*, vol. 11, no. 3, 2005.

[5] J. J. Fux, *Gradus ad Parnassum*, 1725. English translation by A. Mann, W. W. Norton, 1971.

[6] A. Forte, *The Structure of Atonal Music*, Yale University Press, 1973.

[7] J. Hass, "Counterpoint," in *Grove Music Online*, Oxford University Press, 2001.

---

## Appendix A: Catalog of Hom-Set Cardinalities

For the standard 12-TET system Q({0,3,4,7,8,9}, {0,7}):

| Source \ Target | 0 (P) | 3 (I) | 4 (I) | 7 (P) | 8 (I) | 9 (I) |
|---|---|---|---|---|---|---|
| 0 | 1 | 12 | 12 | 12 | 12 | 12 |
| 3 | 12 | 12 | 12 | 12 | 12 | 12 |
| 4 | 12 | 12 | 12 | 12 | 12 | 12 |
| 7 | 12 | 12 | 12 | 1 | 12 | 12 |
| 8 | 12 | 12 | 12 | 12 | 12 | 12 |
| 9 | 12 | 12 | 12 | 12 | 12 | 12 |

- Total incoming to perfect consonance (column 0 or 7): 61
- Total incoming to imperfect consonance: 72
- Grand total edges: 2 × 61 + 4 × 72 = 122 + 288 = 410

## Appendix B: The Consonant Set Under Negation

| i | −i mod 12 | i ∈ C? | −i ∈ C? |
|---|---|---|---|
| 0 | 0 | ✓ | ✓ |
| 3 | 9 | ✓ | ✓ |
| 4 | 8 | ✓ | ✓ |
| 7 | 5 | ✓ | ✗ |
| 8 | 4 | ✓ | ✓ |
| 9 | 3 | ✓ | ✓ |

The failure at i = 7 (σ(7) = 5 ∉ C) is the unique witness to the non-invariance of C under σ.
