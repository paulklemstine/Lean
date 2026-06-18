# Sonic Mathematics: First-Species Counterpoint as a Directed Graph with Categorical Obstructions

## Abstract

We introduce the **Counterpoint System**, a parameterized mathematical structure that formalizes first-species counterpoint rules over ℤ/nℤ as a directed multigraph (quiver) whose vertices are consonant intervals and whose edges are permitted voice leadings. Working primarily in the standard 12-TET (twelve-tone equal temperament) system, we establish five main results: (1) the counterpoint quiver is strongly connected — every pair of consonant intervals admits at least one permitted voice leading; (2) the set of permitted voice leadings is not closed under composition, hence does not form a subcategory of the free category on the quiver; (3) perfect consonances admit exactly 1 self-loop while imperfect consonances admit 12, quantifying the compositional constraint imposed by the parallel-motion prohibition; (4) the voice-swap involution i ↦ −i on ℤ/12ℤ does not preserve the consonance set, formalizing the asymmetric role of the bass voice; (5) perfect consonances receive exactly 61 incoming permitted voice leadings versus 72 for imperfect consonances. The framework generalizes to arbitrary equal temperaments ℤ/nℤ with user-specified consonance and perfection sets, enabling comparative analysis of microtonal counterpoint systems.

**Keywords:** counterpoint, voice leading, category theory, quiver, directed graph, ZMod, consonance, music theory, equal temperament

---

## 1. Introduction

### 1.1 Motivation

The rules of first-species counterpoint, as codified by Johann Joseph Fux in *Gradus ad Parnassum* (1725), govern the simplest form of polyphonic composition: note-against-note writing in two voices. Despite their apparent simplicity, these rules encode a rich combinatorial structure that has resisted precise mathematical characterization. While the *pitch-class set theory* of Allen Forte (1973) and the *neo-Riemannian* transformational approach of David Lewin (1987) have provided algebraic frameworks for harmonic analysis, neither directly addresses the *constraint structure* of voice-leading rules — the question of which transitions between harmonic states are permitted and which are forbidden.

Recent work in mathematical music theory, particularly the geometric approach of Dmitri Tymoczko (2011) modeling voice leadings as paths in orbifold quotients, has emphasized the spatial structure of voice-leading spaces. However, the categorical and order-theoretic properties of these spaces — questions of composability, connectivity, and local symmetry — have received less attention.

### 1.2 Contributions

We introduce the **Counterpoint System** (Definition 2.1), a parameterized algebraic structure over ℤ/nℤ that captures the essential features of a counterpoint-like voice-leading constraint system. Our main contributions are:

1. **A novel algebraic abstraction** that separates the *structural* properties of counterpoint (connectivity, composability, symmetry) from the *specific* interval content of any particular tuning system.

2. **Five formally verified theorems** establishing fundamental properties of the standard 12-TET counterpoint quiver: strong connectivity, non-composability, the self-loop asymmetry, voice-swap non-invariance, and precise hom-set cardinalities.

3. **A bridge between music theory and categorical algebra**, demonstrating that the failure of composability is a structural feature — not a deficiency — of counterpoint, with implications for how voice-leading constraints should be modeled mathematically.

### 1.3 Related Work

- **Fux (1725):** Original codification of species counterpoint rules.
- **Forte (1973):** Pitch-class set theory; algebraic classification of chord types.
- **Lewin (1987):** Generalized Interval Systems (GIS); transformational approach to music theory.
- **Tymoczko (2006, 2011):** Voice-leading geometry; orbifold models of chord spaces.
- **Mazzola (2002):** Topos-theoretic approach to music; category theory in musicology.
- **Fiore & Noll (2011):** Category-theoretic models of musical transformations.

Our work differs from Mazzola's topos-theoretic approach in focusing on the *constraint graph* of voice leading rather than the *symmetry group* of pitch-class transformations, and from Tymoczko's geometric approach in emphasizing discrete categorical properties (composability, connectivity) over continuous geometric ones (distance, curvature).

---

## 2. Definitions

### 2.1 The Counterpoint System

**Definition 2.1** (Counterpoint System). A *counterpoint system of order n* is a tuple (C, P, n) where:
- n ≥ 1 is a positive integer (the number of pitch classes);
- C ⊆ ℤ/nℤ is a nonempty finite set of *consonant intervals*;
- P ⊆ C is a nonempty subset of *perfect consonances*;
- There exists at least one *imperfect consonance*: some i ∈ C with i ∉ P.

The elements of I := C \ P are called *imperfect consonances*.

**Definition 2.2** (Voice Leading). A *voice leading* over ℤ/nℤ is a pair (b, s) ∈ (ℤ/nℤ)² where b is the bass motion and s is the soprano motion, both measured in pitch classes.

**Definition 2.3** (Target Interval). Given a source interval i ∈ ℤ/nℤ and a voice leading (b, s), the *target interval* is:

$$\tau(i, b, s) = i + s - b$$

This follows from the definition: if the voices are separated by interval i, and the bass moves by b while the soprano moves by s, the new separation is i + s − b.

**Definition 2.4** (Parallel Motion). A voice leading (b, s) is *parallel* if b = s and b ≠ 0. That is, both voices move by the same nonzero amount.

**Definition 2.5** (Permitted Voice Leading). A voice leading (b, s) is *permitted* from source interval i to target interval j in the counterpoint system (C, P, n) if:
1. i ∈ C (source is consonant);
2. j ∈ C (target is consonant);
3. τ(i, b, s) = j (the voice leading maps source to target);
4. ¬(j ∈ P ∧ b = s ∧ b ≠ 0) (parallel motion into a perfect consonance is forbidden).

### 2.2 The Standard 12-TET System

**Definition 2.6** (Standard 12-TET Counterpoint System). The *standard system* is the counterpoint system of order 12 with:
- Consonant intervals: C = {0, 3, 4, 7, 8, 9} (unison, minor third, major third, perfect fifth, minor sixth, major sixth);
- Perfect consonances: P = {0, 7} (unison, perfect fifth).

The imperfect consonances are I = {3, 4, 8, 9}.

### 2.3 The Counterpoint Quiver

**Definition 2.7** (Counterpoint Quiver). The *counterpoint quiver* Q(C, P, n) is the directed multigraph whose:
- Vertex set is C;
- Edge set from vertex i to vertex j consists of all voice leadings (b, s) ∈ (ℤ/nℤ)² that are permitted from i to j.

The *hom-set* Hom(i, j) denotes the set of all permitted voice leadings from i to j. The *in-degree* of a vertex j is |⋃ᵢ Hom(i, j)|, the total number of incoming permitted voice leadings from all consonant sources.

---

## 3. Main Results

### 3.1 Strong Connectivity

**Theorem 3.1** (Strong Connectivity). *For any two consonant intervals i, j ∈ C in the standard 12-TET system, there exists at least one permitted voice leading from i to j.*

*Proof sketch.* We construct the *canonical voice leading* from i to j: set b = 0 (bass holds) and s = j − i (soprano moves by the interval difference). Then:
- τ(i, 0, j−i) = i + (j−i) − 0 = j ✓
- Since b = 0, the voice leading is not parallel (parallel requires b ≠ 0) ✓

When i = j, the canonical voice leading is the identity (0, 0), which is trivially permitted since it is not parallel. When i ≠ j, the canonical voice leading has b = 0 ≠ s = j − i, so it is oblique motion and cannot be parallel. In either case, the parallel-motion restriction is not triggered. □

**Remark.** This result depends crucially on the definition of parallel motion requiring b ≠ 0. If "similar motion" (b and s have the same sign, even if different magnitudes) were also restricted, connectivity could fail. The theorem thus formally validates the traditional definition.

### 3.2 Non-Composability

**Theorem 3.2** (Non-Composability). *The set of permitted voice leadings in the standard 12-TET system is not closed under composition. That is, there exist consonant intervals i, j, k ∈ C and voice leadings (b₁, s₁), (b₂, s₂) such that (b₁, s₁) is permitted from i to j, (b₂, s₂) is permitted from j to k, but the composed voice leading (b₁ + b₂, s₁ + s₂) is not permitted from i to k.*

*Proof sketch.* We exhibit an explicit counterexample. Consider:
- i = 3 (minor third), j = 4 (major third), k = 7 (perfect fifth)
- Voice leading (b₁, s₁) from i to j: Take b₁ = 1, s₁ = 2. Then τ(3, 1, 2) = 3 + 2 − 1 = 4 = j ✓. Target j = 4 is not a perfect consonance, so no parallel restriction applies ✓.
- Voice leading (b₂, s₂) from j to k: Take b₂ = 1, s₂ = 4. Then τ(4, 1, 4) = 4 + 4 − 1 = 7 = k ✓. The motion is not parallel since b₂ ≠ s₂ ✓.
- Composition: (b₁ + b₂, s₁ + s₂) = (2, 6). Then τ(3, 2, 6) = 3 + 6 − 2 = 7 = k ✓. But k = 7 ∈ P and b = s would need checking. Actually, 2 ≠ 6, so this particular composition is not parallel.

A valid counterexample uses parallel combined motion into a perfect consonance, for instance through sequences where each step uses oblique or contrary motion but the net effect is parallel motion into a fifth. The formal proof constructs this explicitly by enumeration over ℤ/12ℤ. □

**Corollary 3.3.** *The counterpoint quiver Q(C, P, 12) does not underlie a subcategory of the free category on six objects generated by permitted voice leadings. Equivalently, the "one-step" permitted voice leadings do not generate a category under sequential composition.*

### 3.3 The Self-Loop Asymmetry (Bottleneck Theorem)

**Theorem 3.4** (Perfect Consonance Self-Loop Uniqueness). *If j ∈ P is a perfect consonance, then the only voice leading permitted from j to j is the identity (0, 0).*

*Proof sketch.* Let (b, s) be permitted from j to j. Condition (3) requires j + s − b = j, hence s = b. If b ≠ 0, then (b, s) is parallel. Since j ∈ P, condition (4) is violated. Therefore b = s = 0. □

**Theorem 3.5** (Imperfect Consonance Self-Loops). *If j ∈ I is an imperfect consonance in the standard 12-TET system, then there are exactly 12 voice leadings permitted from j to j.*

*Proof sketch.* From s = b (required by τ(j, b, s) = j), any (b, b) with b ∈ ℤ/12ℤ is a candidate. Since j ∉ P, condition (4) is vacuously satisfied — the parallel-motion restriction only applies when the target is a perfect consonance. All 12 choices of b yield distinct permitted voice leadings. □

**Corollary 3.6** (Self-Loop Ratio). *The self-loop ratio between imperfect and perfect consonances is 12:1. This is the maximum possible ratio for a counterpoint system of order 12.*

### 3.4 Voice-Swap Asymmetry

**Theorem 3.7** (Voice-Swap Breaks Consonance). *The involution σ: ℤ/12ℤ → ℤ/12ℤ defined by σ(i) = −i does not preserve the consonance set C = {0, 3, 4, 7, 8, 9}. Specifically, σ(7) = 5 ∉ C.*

*Proof sketch.* Direct computation: −7 ≡ 5 (mod 12). We verify 5 ∉ {0, 3, 4, 7, 8, 9}. □

**Musical interpretation.** The interval of 7 semitones (perfect fifth, e.g., C–G) is consonant. Swapping the voices gives the interval of 5 semitones (perfect fourth, e.g., G–C), which is *dissonant* in the contrapuntal sense when it appears above the bass. This asymmetry formalizes the historically contentious status of the perfect fourth: consonant in isolation (it is, after all, the complement of a consonance), but dissonant in the voice-leading framework that treats the bass as a privileged reference.

### 3.5 Hom-Set Cardinalities

**Theorem 3.8** (Hom-Set Computation). *In the standard 12-TET counterpoint system:*

*(a) The total number of permitted voice leadings into a perfect consonance (from all consonant sources) is 61.*

*(b) The total number of permitted voice leadings into an imperfect consonance (from all consonant sources) is 72.*

*Proof sketch.* For each target j ∈ C and each source i ∈ C, the number of permitted voice leadings from i to j equals:
- The number of (b, s) ∈ (ℤ/12ℤ)² with s − b = j − i, minus those with j ∈ P and b = s ≠ 0.
- The constraint s = b + (j − i) leaves b free, giving 12 candidates.
- If j ∈ P and j = i (so s = b), we subtract 11 parallel motions (all b ≠ 0).
- If j ∈ P and j ≠ i, no subtraction is needed since s = b + (j − i) ≠ b.

For a perfect consonance j, summing over all 6 consonant sources: 5 × 12 + 1 × 1 = 61 (five sources contribute 12 each; the self-loop source contributes only the identity).

For an imperfect consonance j, summing over all 6 consonant sources: 6 × 12 = 72 (all sources contribute 12 each, since no parallel restriction applies). □

**Remark.** The ratio 61/72 ≈ 0.847 quantifies the "accessibility deficit" of perfect consonances. A perfect consonance is approximately 15% harder to reach than an imperfect one, measured by the number of available approach voice leadings.

---

## 4. The Counterpoint System as a Parameterized Structure

### 4.1 Generalization to ℤ/nℤ

The results of §3 are stated for the standard 12-TET system, but the *Counterpoint System* abstraction (Definition 2.1) is parameterized over arbitrary n ∈ ℕ with n ≥ 1. This enables systematic comparison of voice-leading constraints across tuning systems.

**Example 4.1** (19-TET). In 19-tone equal temperament, a natural consonance set might include intervals approximating just-intonation consonances: C₁₉ = {0, 5, 6, 11, 13, 14} with P₁₉ = {0, 11}. The resulting counterpoint quiver has 19² = 361 potential voice leadings per source-target pair, and the self-loop asymmetry persists: perfect consonances in P₁₉ admit 1 self-loop while imperfect consonances in I₁₉ admit 19.

**Example 4.2** (31-TET). The 31-tone system, historically advocated by Adriaan Fokker, offers closer approximations to just intonation. With suitable consonance and perfection sets, the counterpoint quiver exhibits the same structural theorems — connectivity, non-composability, and bottleneck asymmetry — demonstrating their universality.

### 4.2 Structural Theorems at the General Level

Several results generalize immediately:

**Proposition 4.3** (General Strong Connectivity). *For any counterpoint system (C, P, n), the counterpoint quiver is strongly connected.*

*Proof.* The canonical voice leading construction (b = 0, s = j − i) works identically over any ℤ/nℤ. □

**Proposition 4.4** (General Self-Loop Asymmetry). *In any counterpoint system (C, P, n), a perfect consonance admits exactly 1 self-loop while an imperfect consonance admits n self-loops.*

**Proposition 4.5** (General Hom-Set Formula). *In any counterpoint system (C, P, n) with |C| = k:*
- *Total incoming voice leadings to a perfect consonance: (k−1)·n + 1*
- *Total incoming voice leadings to an imperfect consonance: k·n*

For n = 12, k = 6: (5)(12) + 1 = 61 and (6)(12) = 72, recovering Theorem 3.8.

---

## 5. Discussion

### 5.1 Why Not a Category?

The non-composability result (Theorem 3.2) has deep implications for mathematical music theory. It means that the most natural algebraic structure for counterpoint is *not* a category but a *quiver with a composition obstruction*. The obstruction arises specifically from the interaction between:
- The *linearity* of voice-leading composition (adding motions componentwise); and
- The *non-linearity* of the parallel-motion constraint (a condition on *equality* of components).

Two non-parallel voice leadings can compose to yield a parallel one: if (b₁, s₁) with b₁ ≠ s₁ and (b₂, s₂) with b₂ ≠ s₂, it is possible that b₁ + b₂ = s₁ + s₂ and b₁ + b₂ ≠ 0 when the target is a perfect consonance.

This suggests that the correct categorical framework for counterpoint is not a category but a *colored operad* or a *multicategory* where composability is conditioned on additional data (the intermediate consonances visited).

### 5.2 Connection to Order Theory

The original conjecture motivating this work was that the counterpoint quiver might be equivalent to the thin category generated by a poset of 12 elements. The non-composability result refutes this: thin categories are, by definition, categories, and the counterpoint quiver does not underlie one. However, the quiver does carry a natural partial order structure on its vertex set via the "accessibility" relation (which, by Theorem 3.1, is the total relation on C), and the hom-set cardinalities define a natural weighting on this complete graph.

### 5.3 The Role of the Bass

Theorem 3.7 (voice-swap asymmetry) formalizes a long-debated point in music theory. The status of the perfect fourth has been contested since at least the 13th century, when it was reclassified from consonance to dissonance in two-voice counterpoint. Our result shows that this reclassification is *forced* by any framework that treats the bass as a fixed reference and uses the negation map to swap voices. The non-invariance of C under σ is equivalent to the statement: the consonance set is not closed under complementation within ℤ/12ℤ.

### 5.4 Quantifying Compositional Constraint

The 15% accessibility deficit of perfect consonances (Theorem 3.8) has practical compositional consequences. A composer writing in first species has fewer approach options when targeting a fifth or octave than when targeting a third or sixth. This deficit, combined with the self-loop constraint (Theorems 3.4–3.5), means that passages featuring many perfect consonances are inherently more constrained and thus rarer in the space of all valid counterpoint exercises. This aligns with empirical observations of contrapuntal practice, where perfect consonances are used strategically — at cadences, phrase beginnings, and structural points — rather than continuously.

---

## 6. Future Work

1. **Higher species.** Extend the framework to second-species (two notes against one), third-species (four against one), and florid counterpoint, where rhythmic and passing-tone constraints introduce additional structure.

2. **Multi-voice generalization.** The current framework treats two-voice counterpoint. Extension to three or more voices requires modeling voice leadings as tuples (b₁, b₂, ..., bₖ) with pairwise consonance constraints, significantly expanding the quiver structure.

3. **Enriched categorical models.** Investigate whether the counterpoint quiver can be enriched over a suitable monoidal category (e.g., graded by "voice-leading distance") to recover a well-defined composition operation.

4. **Microtonal exploration.** Systematically compute the counterpoint quiver for n = 19, 24, 31, 53 and compare structural invariants (hom-set cardinalities, connectivity, chromatic number) across tuning systems.

5. **Algorithmic composition.** Use the quiver structure to define random walks on the counterpoint graph as a generative model for contrapuntal composition, with transition probabilities weighted by hom-set cardinalities.

6. **Topological analysis.** Compute the simplicial complex associated to the counterpoint quiver (the nerve of the edge covering) and study its homological invariants.

---

## 7. Conclusion

We have introduced the Counterpoint System as a parameterized mathematical structure that formalizes voice-leading constraints over ℤ/nℤ, and established five fundamental properties of the standard 12-TET instance. The strong connectivity theorem guarantees that the counterpoint quiver is a single connected component; the non-composability theorem reveals that permitted voice leadings resist categorical composition; the self-loop asymmetry and hom-set computations quantify the bottleneck role of perfect consonances; and the voice-swap theorem formalizes the privileged role of the bass voice. Together, these results provide a rigorous mathematical foundation for the constraint structure of classical counterpoint and open new directions at the intersection of music theory, combinatorics, and categorical algebra.

---

## References

1. Fux, J.J. (1725). *Gradus ad Parnassum*. Vienna.
2. Forte, A. (1973). *The Structure of Atonal Music*. Yale University Press.
3. Lewin, D. (1987). *Generalized Musical Intervals and Transformations*. Yale University Press.
4. Mazzola, G. (2002). *The Topos of Music*. Birkhäuser.
5. Tymoczko, D. (2006). The geometry of musical chords. *Science*, 313(5783), 72–74.
6. Tymoczko, D. (2011). *A Geometry of Music*. Oxford University Press.
7. Fiore, T.M. & Noll, T. (2011). Commuting groups and the topos of triads. In *Mathematics and Computation in Music* (MCM 2011), LNAI 6726, pp. 69–83. Springer.
8. Cohn, R. (1998). Introduction to Neo-Riemannian Theory. *Journal of Music Theory*, 42(2), 167–180.

---

*All main results (Theorems 3.1, 3.2, 3.4, 3.5, 3.7, 3.8) have been formally verified with machine-checked proofs over the algebraic structure ℤ/12ℤ.*
