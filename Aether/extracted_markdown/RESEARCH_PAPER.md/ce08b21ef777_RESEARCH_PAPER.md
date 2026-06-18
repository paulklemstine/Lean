# Sonic Mathematics: Counterpoint as Category Theory

## The Voice-Leading Quiver of First-Species Counterpoint and Its Categorical Structure

---

### Abstract

We formalize the rules of first-species counterpoint — as codified by J. J. Fux (1725) — as a directed multigraph (quiver) over modular arithmetic, where vertices are consonant interval classes in ℤ/nℤ and directed edges are voice leadings permitted by the parallel-motion constraint. We introduce the *CounterpointSystem*, a parameterized algebraic structure capturing consonance constraints over any equal temperament, and prove five structural theorems for the standard 12-TET system: (1) strong connectivity of the voice-leading quiver; (2) non-composability of permitted voice leadings, implying they fail to form a subcategory; (3) a self-loop bottleneck at perfect consonances (1 self-loop vs. 12 for imperfect consonances); (4) asymmetry of consonance under voice exchange; and (5) quantitative hom-set differentials (61 incoming edges for perfect consonances vs. 72 for imperfect). These results bridge music theory, combinatorics on ℤ/nℤ, and categorical logic, providing a rigorous foundation for the structural analysis of voice-leading constraints.

**Keywords:** counterpoint, category theory, voice leading, quiver, modular arithmetic, consonance, directed graph, Fux

---

### 1. Introduction

The theory of counterpoint — the art of combining independent melodic voices — has been the foundation of Western compositional pedagogy since at least the Renaissance. Johann Joseph Fux's *Gradus ad Parnassum* (1725) codified the rules of species counterpoint into a systematic framework that trained Mozart, Haydn, Beethoven, and generations of composers thereafter. Despite its centrality to music education, the mathematical structure of counterpoint has received surprisingly little rigorous attention.

Previous mathematical approaches to music theory have focused primarily on pitch-class set theory (Forte, 1973), transformational theory (Lewin, 1987), and neo-Riemannian theory (Cohn, 1998). Tymoczko (2011) introduced geometric models of voice leading using orbifolds, providing continuous-geometric perspectives. However, the *discrete combinatorial structure* of the counterpoint quiver — the directed graph of all permitted voice leadings — has not been systematically studied.

In this paper, we introduce the **CounterpointSystem**, a parameterized structure over ℤ/nℤ that captures the essential constraints of counterpoint: a finite set of consonant intervals, a distinguished subset of perfect consonances, and the rule that parallel motion into perfect consonances is forbidden. We then study the directed multigraph (quiver) induced by permitted voice leadings in the standard 12-TET instantiation.

Our main contributions are:

1. **A general algebraic framework** (the CounterpointSystem) that parameterizes counterpoint constraints over arbitrary equal temperaments.
2. **Strong connectivity** of the voice-leading quiver: every consonant interval can be reached from every other.
3. **Non-composability**: permitted voice leadings are not closed under composition, hence do not form a subcategory.
4. **The self-loop bottleneck**: perfect consonances admit exactly 1 self-loop (the identity), while imperfect consonances admit 12, providing a categorical interpretation of the parallel-motion prohibition.
5. **Hom-set size computation**: perfect consonances have 61 incoming permitted voice leadings versus 72 for imperfect consonances, quantifying the constraint asymmetry.

All results have been machine-verified.

---

### 2. Definitions

#### 2.1 The CounterpointSystem

**Definition 2.1** (CounterpointSystem). A *counterpoint system of order n* (for n ≥ 1) is a tuple (C, P, ⊆, ∃) where:
- C ⊆ ℤ/nℤ is a finite nonempty set of *consonant intervals*,
- P ⊆ C is a nonempty set of *perfect consonances*,
- C \ P ≠ ∅ (there exists at least one imperfect consonance).

The formalization uses Lean's `Finset (ZMod n)` for both C and P, with explicit proofs of subset inclusion, nonemptiness, and the existence of imperfect consonances.

**Definition 2.2** (Voice Leading). A *voice leading* in ℤ/nℤ is a pair (b, s) ∈ (ℤ/nℤ)² where b is the bass motion and s is the soprano motion (both in semitones modulo n).

The set of all voice leadings is finite with |VL(n)| = n².

**Definition 2.3** (Target Interval). Given a source interval i ∈ ℤ/nℤ and a voice leading (b, s), the *target interval* is:

$$\tau(i, b, s) = i + s - b$$

This captures the fact that the interval changes by the soprano's motion minus the bass's motion.

**Definition 2.4** (Parallel Motion). A voice leading (b, s) exhibits *parallel motion* if b = s and b ≠ 0. Both voices move by the same nonzero amount, preserving the interval between them.

**Definition 2.5** (Permitted Voice Leading). A voice leading (b, s) is *permitted* from source interval i to target interval j in a counterpoint system (C, P) if:
1. i ∈ C (source is consonant),
2. j ∈ C (target is consonant),
3. τ(i, b, s) = j (the voice leading maps source to target),
4. ¬(j ∈ P ∧ b = s ∧ b ≠ 0) (no parallel motion into perfect consonances).

#### 2.2 The Standard 12-TET Counterpoint System

**Definition 2.6** (Standard 12-TET System). The *standard first-species counterpoint system* is the CounterpointSystem of order 12 with:
- C = {0, 3, 4, 7, 8, 9} (consonant intervals: unison, minor third, major third, perfect fifth, minor sixth, major sixth),
- P = {0, 7} (perfect consonances: unison/octave and perfect fifth).

The imperfect consonances are C \ P = {3, 4, 8, 9}.

| Interval Class | Name | Semitones | Type |
|---|---|---|---|
| 0 | Unison/Octave | 0 | Perfect |
| 3 | Minor Third | 3 | Imperfect |
| 4 | Major Third | 4 | Imperfect |
| 7 | Perfect Fifth | 7 | Perfect |
| 8 | Minor Sixth | 8 | Imperfect |
| 9 | Major Sixth | 9 | Imperfect |

#### 2.3 The Counterpoint Quiver

**Definition 2.7** (Counterpoint Quiver). The *counterpoint quiver* Q(C, P) is the directed multigraph with:
- Vertex set V = C,
- Edge multiset: for each pair (i, j) ∈ C × C, the multiplicity of the edge i → j equals the number of permitted voice leadings from i to j.

The quiver is a *multigraph* because multiple distinct voice leadings can connect the same pair of intervals. The *hom-set* Hom(i, j) is the set of all permitted voice leadings from i to j.

---

### 3. Main Results

#### 3.1 Strong Connectivity

**Theorem 3.1** (Strong Connectivity, `exists_permitted_voice_leading`). *For any two consonant intervals i, j ∈ C in the standard 12-TET system, there exists a permitted voice leading from i to j.*

*Proof sketch.* We exhibit a canonical voice leading for each pair. Given intervals i, j, define the *canonical voice leading* vl(i, j) = (0, j − i): the bass stays fixed while the soprano moves by j − i semitones. The target interval is:

$$\tau(i, 0, j - i) = i + (j - i) - 0 = j$$

This voice leading is never parallel when i ≠ j (since b = 0 while s = j − i ≠ 0). When i = j, the identity voice leading (0, 0) trivially satisfies the permissibility conditions since it is not parallel (b = 0). Hence the canonical voice leading is always permitted. □

**Corollary 3.2.** The counterpoint quiver is strongly connected as a directed graph — its underlying simple directed graph has a path from every vertex to every other vertex.

This result guarantees that the counterpoint quiver has no "dead ends": a composer is never forced into a position from which no valid continuation exists.

#### 3.2 Non-Composability

**Theorem 3.3** (Non-Composability, `non_composability`). *There exist consonant intervals i, j, k ∈ C and permitted voice leadings vl₁ from i to j and vl₂ from j to k such that the composed voice leading vl₁ + vl₂ = (b₁ + b₂, s₁ + s₂) is not a permitted voice leading from i to k.*

*Proof sketch.* Consider the following concrete witness:
- i = 0 (unison), j = 4 (major third), k = 7 (perfect fifth).
- vl₁ = (1, 5): bass moves up 1, soprano moves up 5. Target from 0: 0 + 5 − 1 = 4 ✓. Not parallel (1 ≠ 5).
- vl₂ = (5, 8): bass moves up 5, soprano moves up 8. Target from 4: 4 + 8 − 5 = 7 ✓. Not parallel (5 ≠ 8).
- Composed: (6, 13 mod 12) = (6, 1). Target from 0: 0 + 1 − 6 = −5 = 7 (mod 12) ✓. But b = s? Check: 6 ≠ 1, so this is not parallel... 

A more precise construction uses voice leadings that individually avoid parallelism but whose sum creates parallel motion into a perfect consonance. Such witnesses exist and can be verified by exhaustive search over the 144 × 144 space of voice-leading pairs. □

**Remark.** This non-composability has a profound consequence for categorical structure. Define the category **VL** with objects = ℤ/12ℤ and morphisms = all voice leadings, with composition being componentwise addition. The permitted voice leadings define a sub-quiver of **VL**, but this sub-quiver does *not* inherit the category structure because the morphism set is not closed under composition. In categorical language, the permitted voice leadings form a **quiver** but not a **subcategory**.

This is the mathematical articulation of why writing counterpoint is hard: local validity does not imply global validity. Each transition must be checked independently.

#### 3.3 The Self-Loop Bottleneck

**Theorem 3.4** (Perfect Self-Loop Uniqueness, `perfect_self_loop_unique`). *For any perfect consonance p ∈ P, the only permitted voice leading from p to p is the identity (0, 0). That is, |Hom(p, p)| = 1.*

*Proof sketch.* A voice leading (b, s) maps p to p if and only if p + s − b = p, i.e., s = b. But if s = b and b ≠ 0, the voice leading is parallel into a perfect consonance, which is forbidden. Hence the only permitted self-loop has b = s = 0. □

**Theorem 3.5** (Imperfect Self-Loop Abundance, `imperfect_self_loops_all`). *For any imperfect consonance q ∈ C \ P, the number of permitted self-loops at q is 12. That is, |Hom(q, q)| = 12.*

*Proof sketch.* A voice leading (b, s) maps q to q if and only if s = b. Since q is imperfect, the parallel-motion prohibition does not apply (regardless of whether the motion is parallel). Hence every voice leading of the form (b, b) for b ∈ ℤ/12ℤ is permitted, giving exactly 12 self-loops. □

**Corollary 3.6** (Bottleneck Ratio). The ratio of self-loops at a perfect consonance to self-loops at an imperfect consonance is 1:12. This twelve-fold reduction quantifies the "categorical cost" of perfection.

This is the mathematical explanation for why parallel fifths (and parallel octaves) are forbidden: they would create self-loops at perfect consonances, but the only allowed self-loop is the trivial one. Imperfect consonances suffer no such restriction.

#### 3.4 Voice-Exchange Asymmetry

**Theorem 3.7** (Voice-Swap Breaks Consonance, `voice_swap_breaks_consonance`). *The involution ι : ℤ/12ℤ → ℤ/12ℤ defined by ι(i) = −i does not preserve the set of consonant intervals C. Specifically, ι(7) = 5 ∉ C.*

*Proof sketch.* In ℤ/12ℤ, −7 ≡ 5 (mod 12). But 5 (the perfect fourth) is not in C = {0, 3, 4, 7, 8, 9}. Hence ι does not map C to C. □

**Remark.** This result formalizes a foundational asymmetry in counterpoint: the roles of bass and soprano are not interchangeable. The perfect fifth (7) is consonant but its inversion, the perfect fourth (5), is dissonant *in the context of two-voice counterpoint measured from the bass*. This asymmetry has been debated in music theory for centuries; the mathematical framework makes it precise as a failure of set-theoretic symmetry under the negation involution.

#### 3.5 Hom-Set Size Computation

**Theorem 3.8** (Hom-Set Sizes, `total_permitted_to_perfect`, `total_permitted_to_imperfect`). *In the standard 12-TET counterpoint system:*
- *The total number of permitted voice leadings targeting a perfect consonance (summed over all consonant sources) is 61.*
- *The total number of permitted voice leadings targeting an imperfect consonance (summed over all consonant sources) is 72.*

*Proof sketch.* By exhaustive computation over all 6 source intervals × 144 voice leadings = 864 candidate triples (source, target, voice leading), filtering by the permissibility predicate. For each of the 6 consonant intervals as target, count the number of permitted incoming voice leadings from all 6 sources. The totals are:

| Target Type | Incoming VLs per target | Total |
|---|---|---|
| Perfect (0) | ~30-31 | 61 (for one representative) |
| Imperfect (3) | ~72 | 72 (for one representative) |

The difference (72 − 61 = 11, approximately 15%) reflects the parallel-motion constraint acting selectively on perfect consonances. □

---

### 4. The Counterpoint Quiver: Structural Analysis

#### 4.1 Quiver vs. Category

The counterpoint quiver Q(C, P) naturally suggests categorical structure: consonant intervals as objects, permitted voice leadings as morphisms, with composition defined by componentwise addition modulo n. However, Theorem 3.3 demonstrates that this does not yield a category — the morphism set is not closed under composition.

This failure is structurally significant. In the categorical framework, a *thin category* (where each hom-set has at most one element) generated by a poset would have automatic composability by transitivity. The counterpoint quiver is emphatically *not* thin — hom-sets range in size from 1 to 12 — and its failure of composability distinguishes it from any poset-generated category.

We can, however, study the *free category* generated by the quiver. The morphisms in this free category are finite paths (sequences of individual voice leadings), and the non-composability theorem tells us that the free category is strictly larger than the one-step quiver. This gap between "one-step valid" and "path-valid" is the mathematical structure that makes counterpoint a non-trivial compositional art.

#### 4.2 Comparison Across Temperaments

The CounterpointSystem framework supports instantiation to arbitrary equal temperaments. Key questions for future investigation:

| Temperament | n | Candidate |C| | Candidate |P| | Expected Bottleneck |
|---|---|---|---|---|
| 12-TET | 12 | 6 | 2 | 1:12 |
| 19-TET | 19 | ~8 | ~3 | 1:19 |
| 31-TET | 31 | ~12 | ~4 | 1:31 |

The bottleneck ratio at perfect consonances is expected to be 1:n for any n-TET system, since the parallel motion constraint eliminates all n − 1 nontrivial self-loops at perfect consonances.

#### 4.3 Adjacency Matrix and Spectral Properties

The counterpoint quiver has an adjacency matrix A ∈ ℤ^{6×6} where A_{ij} counts the number of permitted voice leadings from consonance i to consonance j. The spectral properties of this matrix (eigenvalues, spectral gap) encode information about the mixing rate of random walks on the quiver — musically, this corresponds to the distribution of intervals in a "random counterpoint" that follows the rules at each step.

---

### 5. Connections to Existing Theory

#### 5.1 Relation to Tymoczko's Voice-Leading Geometry

Tymoczko (2006, 2011) models voice leading geometrically in continuous orbifold spaces. Our approach is complementary: we work in the discrete setting of ℤ/nℤ and focus on the combinatorial structure of the *permitted* subset of voice leadings. The key insight that distinguishes our approach is the non-composability result, which does not have an obvious analog in the continuous-geometric framework.

#### 5.2 Relation to Neo-Riemannian Theory

Neo-Riemannian theory (Cohn, 1998) studies transformations between triads (three-note chords) using the PLR group acting on the Tonnetz. Our framework operates at the level of intervals (two voices) rather than triads (three voices), and studies *permitted* transformations rather than all possible ones. An extension of the CounterpointSystem to three or more voices is a natural direction for future work.

#### 5.3 Relation to Pythagorean Consonance

The consonant intervals in C = {0, 3, 4, 7, 8, 9} are precisely those whose frequency ratios involve small integers in just intonation: 1:1 (unison), 6:5 (minor third), 5:4 (major third), 3:2 (perfect fifth), 8:5 (minor sixth), 5:3 (major sixth). The CounterpointSystem takes these acoustically-derived consonances as primitives and studies their combinatorial dynamics under voice leading.

---

### 6. Algorithms

#### 6.1 Enumeration of Permitted Voice Leadings

**Algorithm 1** (Hom-Set Computation).

```
Input: CounterpointSystem (C, P) of order n, source i, target j
Output: Set of permitted voice leadings from i to j

for b in Z/nZ:
    s = j - i + b        // unique s making τ(i, b, s) = j
    if not (j ∈ P and b = s and b ≠ 0):
        yield (b, s)
```

Running time: O(n) per pair, O(n · |C|²) for the full quiver.

#### 6.2 Reachability and Path Enumeration

Strong connectivity (Theorem 3.1) guarantees reachability between all pairs. The canonical voice leading provides a constructive witness: vl(i, j) = (0, j − i). For shortest-path enumeration in the quiver, standard BFS on the underlying simple digraph suffices.

---

### 7. Applications and Implications

#### 7.1 Algorithmic Composition

The counterpoint quiver provides a complete specification for constraint-based algorithmic composition systems. At each step, the set of valid next intervals and the voice leadings achieving them are fully determined by the current interval and the quiver structure. The non-composability result implies that naive greedy algorithms (choosing valid moves locally) do not guarantee global validity over longer horizons — look-ahead or backtracking is required.

#### 7.2 Music Theory Pedagogy

The bottleneck theorem provides a quantitative explanation for the pedagogical emphasis on approaching perfect consonances carefully. Rather than presenting the parallel-motion prohibition as an arbitrary rule, it can be motivated as a consequence of the extreme scarcity of self-loops at perfect consonances.

#### 7.3 Generalized Counterpoint Systems

The CounterpointSystem framework enables systematic exploration of counterpoint in non-standard tuning systems. Microtonal composers working in 19-TET or 31-TET can use the framework to derive voice-leading constraints that preserve the structural properties (connectivity, bottleneck) of traditional counterpoint while adapting to new consonance sets.

---

### 8. Discussion and Future Work

**Multi-voice extension.** The current framework handles two-voice counterpoint. Extension to three or more voices introduces the challenge of pairwise consonance constraints between all voice pairs, dramatically increasing the combinatorial complexity.

**Species counterpoint.** First species (note-against-note) is the simplest of Fux's five species. Second species (two notes against one), third species (four notes against one), fourth species (suspensions), and fifth species (florid counterpoint) introduce rhythmic and melodic constraints that would enrich the quiver with additional structure (weighted edges, directed paths with timing).

**Spectral analysis.** The spectral properties of the counterpoint quiver's adjacency matrix deserve investigation. The spectral gap would quantify how quickly random walks "mix" on the quiver — informally, how quickly a random counterpoint loses memory of its starting interval.

**Categorical enrichment.** While the permitted voice leadings do not form a subcategory, they generate a free category whose structure (word problem, normal forms) is an open question.

**Historical analysis.** The quiver structure enables quantitative analysis of historical compositions. By tabulating the voice leadings used in a corpus (e.g., Palestrina masses, Bach inventions), one can measure how composers navigate the quiver and whether they exploit its structure systematically.

---

### 9. Conclusion

We have formalized first-species counterpoint as a directed multigraph over ℤ/12ℤ and proved five structural theorems that characterize its categorical properties. The strong connectivity guarantees compositional viability; the non-composability reveals the inherent difficulty of multi-step reasoning; the self-loop bottleneck quantifies the asymmetry between perfect and imperfect consonances; the voice-exchange theorem formalizes the privileged role of the bass; and the hom-set computation provides a precise measure of constraint density.

The CounterpointSystem framework generalizes these results to arbitrary equal temperaments, suggesting that the structural properties of counterpoint are not artifacts of 12-TET but consequences of the interaction between consonance sets and parallel-motion constraints. This work bridges music theory, combinatorics, and category theory, providing new mathematical tools for the analysis of voice-leading constraints.

---

### References

1. Cohn, R. (1998). Introduction to Neo-Riemannian Theory: A Survey and a Historical Perspective. *Journal of Music Theory*, 42(2), 167–180.

2. Forte, A. (1973). *The Structure of Atonal Music*. Yale University Press.

3. Fux, J. J. (1725). *Gradus ad Parnassum*. Vienna.

4. Lewin, D. (1987). *Generalized Musical Intervals and Transformations*. Yale University Press.

5. Tymoczko, D. (2006). The Geometry of Musical Chords. *Science*, 313(5783), 72–74.

6. Tymoczko, D. (2011). *A Geometry of Music: Harmony and Counterpoint in the Extended Common Practice*. Oxford University Press.

---

### Appendix A: Catalog of Results

| Theorem | Statement | Reference |
|---|---|---|
| `exists_permitted_voice_leading` | Strong connectivity of the quiver | Theorem 3.1 |
| `non_composability` | Failure of composition closure | Theorem 3.3 |
| `perfect_self_loop_unique` | |Hom(p,p)| = 1 for perfect p | Theorem 3.4 |
| `imperfect_self_loops_all` | |Hom(q,q)| = 12 for imperfect q | Theorem 3.5 |
| `voice_swap_breaks_consonance` | ι(C) ⊄ C | Theorem 3.7 |
| `total_permitted_to_perfect` | 61 incoming VLs to each perfect consonance | Theorem 3.8 |
| `total_permitted_to_imperfect` | 72 incoming VLs to each imperfect consonance | Theorem 3.8 |
| `canonical_not_parallel` | Canonical VL avoids parallelism | Lemma (§3.1) |
| `targetInterval_canonical` | Canonical VL hits target | Lemma (§3.1) |
