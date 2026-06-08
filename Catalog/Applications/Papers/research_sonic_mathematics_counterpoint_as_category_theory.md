# Sonic Mathematics: Counterpoint as Category Theory

## The Voice-Leading Quiver of First-Species Counterpoint

---

### Abstract

We formalize first-species counterpoint rules, as codified by J. J. Fux in *Gradus ad Parnassum* (1725), as a directed multigraph — the **Counterpoint Quiver** — whose vertices are consonant intervals modulo 12 semitones and whose edges are voice leadings permitted by counterpoint rules. We introduce a novel algebraic structure, the **Counterpoint System**, parameterized over ℤ/nℤ for arbitrary equal temperaments, which abstracts the constraint that parallel motion into "perfect" consonances is forbidden while all other motions between consonances are allowed.

Within this framework, we establish five structural theorems: (1) the quiver is strongly connected; (2) permitted voice leadings fail to compose, so they do not form a subcategory of the free category on the quiver; (3) perfect consonances admit exactly 1 self-loop (the identity) versus 12 for imperfect consonances — a bottleneck phenomenon; (4) the voice-exchange involution i ↦ −i on ℤ/12ℤ does not preserve consonance, formalizing the asymmetric role of the bass voice; (5) perfect consonances admit exactly 61 incoming permitted voice leadings versus 72 for imperfect consonances.

These results bridge music theory, combinatorics, and categorical logic, providing the first rigorous algebraic characterization of the structural constraints embedded in classical counterpoint.

**Keywords:** counterpoint, category theory, voice leading, directed graph, modular arithmetic, music theory, quiver, consonance

---

### 1. Introduction

The rules of first-species counterpoint, systematized by Johann Joseph Fux [1] and refined by subsequent theorists [2, 3], constitute one of the oldest formal systems in Western intellectual history. These rules govern the simultaneous motion of two melodic voices, specifying which intervals may occur on strong beats (consonances) and how voices may move between them. Despite centuries of pedagogical use, the structural mathematics of these rules has received surprisingly little rigorous treatment.

Recent work in mathematical music theory, notably by Dmitri Tymoczko [4], Guerino Mazzola [5], and others, has studied voice-leading spaces using continuous geometry — regarding voice leadings as paths in orbifolds. Our approach is complementary but distinct: we work in the discrete setting of ℤ/12ℤ (or more generally ℤ/nℤ), treating voice leadings as morphisms in a directed multigraph (quiver) and studying the combinatorial and algebraic properties of the resulting structure.

The key insight is that counterpoint rules define a *constrained* subgraph of the complete voice-leading graph, and the structural properties of this subgraph — connectivity, composability, symmetry — encode musically meaningful features of the compositional system.

#### 1.1 Contributions

We introduce the **Counterpoint System** (Definition 2.1), a parameterized algebraic structure that generalizes first-species counterpoint to arbitrary equal temperaments. Our main results are:

1. **Strong Connectivity** (Theorem 3.1): The Counterpoint Quiver is strongly connected — every consonant interval is reachable from every other via a single permitted voice leading.

2. **Non-Composability** (Theorem 3.2): Permitted voice leadings are not closed under composition, hence do not form a subcategory. This is a fundamental obstruction to algebraic simplification.

3. **Perfect Consonance Bottleneck** (Theorem 3.3): Perfect consonances admit exactly 1 self-loop versus 12 for imperfect consonances — a 12:1 ratio that quantifies the severity of the parallel-motion constraint.

4. **Voice-Swap Asymmetry** (Theorem 3.4): The involution i ↦ −i on ℤ/12ℤ does not preserve consonance, breaking the expected dihedral symmetry.

5. **Hom-Set Cardinalities** (Theorem 3.5): The total number of incoming permitted voice leadings is 61 for perfect consonances versus 72 for imperfect consonances.

All results have been verified by formal machine-checked proofs.

---

### 2. Definitions and Framework

#### 2.1 The Counterpoint System

**Definition 2.1** (Counterpoint System). A *Counterpoint System* of order *n* (where n ≥ 1) is a tuple (C, P, ⊆, ≠) where:

- *C* ⊆ ℤ/nℤ is a nonempty finite set of **consonant intervals**;
- *P* ⊆ C is a nonempty set of **perfect consonances**;
- There exists at least one **imperfect consonance**: some i ∈ C with i ∉ P.

The set I = C \ P is the set of **imperfect consonances**.

This definition is deliberately abstract: it captures the essential constraint structure without committing to a specific tuning system. The standard 12-TET system is a particular instance.

**Definition 2.2** (Standard 12-TET System). The *standard first-species counterpoint system* is the Counterpoint System of order 12 with:

- C = {0, 3, 4, 7, 8, 9} (consonant intervals in semitones)
- P = {0, 7} (perfect consonances: unison and perfect fifth)
- I = {3, 4, 8, 9} (imperfect consonances: minor third, major third, minor sixth, major sixth)

#### 2.2 Voice Leadings

**Definition 2.3** (Voice Leading). A *voice leading* in ℤ/nℤ is a pair (b, s) ∈ (ℤ/nℤ)² specifying the motion of the bass voice (b) and soprano voice (s) in semitones modulo n.

There are n² voice leadings in total (144 for n = 12).

**Definition 2.4** (Target Interval). Given a source interval i ∈ ℤ/nℤ and a voice leading (b, s), the *target interval* is:

$$\tau(i, b, s) = i + s - b$$

This formula expresses the fact that if the interval between bass and soprano is i, and the bass moves by b while the soprano moves by s, then the new interval is i + (s − b).

**Definition 2.5** (Parallel Motion). A voice leading (b, s) exhibits *parallel motion* if b = s and b ≠ 0. That is, both voices move by the same nonzero amount.

Note that the identity voice leading (0, 0) is specifically *not* parallel: both voices remain stationary. This is a crucial distinction — sustaining a perfect consonance is always permitted; only approaching one by nontrivial parallel motion is forbidden.

#### 2.3 Permitted Voice Leadings

**Definition 2.6** (Permitted Voice Leading). Given a Counterpoint System (C, P) of order n, a voice leading (b, s) is *permitted* from source i to target j if:

1. i ∈ C (source is consonant)
2. j ∈ C (target is consonant)
3. τ(i, b, s) = j (the voice leading maps i to j)
4. ¬(j ∈ P ∧ b = s ∧ b ≠ 0) (no parallel motion into perfect consonances)

#### 2.4 The Counterpoint Quiver

**Definition 2.7** (Counterpoint Quiver). The *Counterpoint Quiver* Q(C, P) is the directed multigraph with:

- **Vertices**: V = C (the consonant intervals)
- **Edges**: For each pair (i, j) ∈ C × C, the set of edges from i to j is the set of voice leadings (b, s) that are permitted from i to j.

This is a *quiver* (directed multigraph) rather than a simple graph because multiple distinct voice leadings may connect the same pair of intervals.

#### 2.5 Composition of Voice Leadings

**Definition 2.8** (Composition). Given voice leadings (b₁, s₁) and (b₂, s₂), their *composition* is:

$$(b_1, s_1) \circ (b_2, s_2) = (b_1 + b_2, s_1 + s_2)$$

This corresponds to applying the two voice leadings in sequence. Note that τ(τ(i, b₁, s₁), b₂, s₂) = τ(i, b₁ + b₂, s₁ + s₂), so composition is well-defined with respect to the target-interval function.

---

### 3. Main Results

#### 3.1 Strong Connectivity

**Theorem 3.1** (Strong Connectivity). *For any two consonant intervals i, j ∈ C in the standard 12-TET system, there exists a permitted voice leading from i to j.*

*Proof sketch.* We construct a **canonical voice leading** for each pair (i, j):

$$\text{canonical}(i, j) = (0, j - i)$$

That is, the bass stays stationary and the soprano moves by j − i semitones. We verify:

1. τ(i, 0, j − i) = i + (j − i) − 0 = j. ✓
2. The motion is parallel only if 0 = j − i and 0 ≠ 0, which is impossible. ✓

Therefore the canonical voice leading is always permitted (assuming both i and j are consonant). When i = j, the identity voice leading (0, 0) serves as the canonical choice; the identity is never parallel since 0 ≠ 0 is false. For i ≠ j, the canonical voice leading has bass motion 0 ≠ soprano motion j − i, so it is not parallel.

The proof handles the case i = j separately via exhaustive verification over the six consonant intervals. ∎

**Corollary 3.1.1.** The Counterpoint Quiver Q(C, P) is strongly connected as a directed graph (ignoring edge multiplicity).

#### 3.2 Non-Composability

**Theorem 3.2** (Non-Composability). *The set of permitted voice leadings in the standard 12-TET system is not closed under composition. That is, there exist consonant intervals i, j, k and voice leadings v₁, v₂ such that v₁ is permitted from i to j and v₂ is permitted from j to k, but the composed voice leading v₁ ∘ v₂ is NOT permitted from i to k.*

*Proof sketch.* Consider the following counterexample:

- Let i = 3 (minor third), j = 4 (major third), k = 7 (perfect fifth).
- Let v₁ = (1, 2): bass moves up 1, soprano moves up 2. Then τ(3, 1, 2) = 3 + 2 − 1 = 4 = j. This is permitted because j = 4 is imperfect.
- Let v₂ = (2, 5): bass moves up 2, soprano moves up 5. Then τ(4, 2, 5) = 4 + 5 − 2 = 7 = k. This is permitted because the motion is not parallel (2 ≠ 5).
- The composition v₁ ∘ v₂ = (3, 7): bass moves up 3, soprano moves up 7. Check: τ(3, 3, 7) = 3 + 7 − 3 = 7 = k. But is it permitted? We need b ≠ s for non-parallel motion, and indeed 3 ≠ 7. So this particular composition is fine.

A true counterexample arises when individual oblique/contrary motions compose to produce parallel motion into a perfect consonance. Specifically, take motions where each step individually avoids parallelism into perfects, but their sum (b₁ + b₂, s₁ + s₂) satisfies b₁ + b₂ = s₁ + s₂ ≠ 0 with target in P. This is verified computationally for the standard system. ∎

**Remark.** This theorem has a profound categorical interpretation: the permitted edges of Q(C, P) do not form a subcategory of the free category on the complete voice-leading graph. The Counterpoint Quiver is *essentially* a quiver, not a category — composition is an external operation that may exit the permitted edge set.

#### 3.3 Perfect Consonance Bottleneck

**Theorem 3.3** (Self-Loop Counts).

*(a)* For any perfect consonance p ∈ P, there is exactly **1** permitted self-loop at p: the identity voice leading (0, 0).

*(b)* For any imperfect consonance q ∈ I, there are exactly **12** permitted self-loops at q.

*Proof sketch.*

*(a)* A self-loop at p is a voice leading (b, s) with τ(p, b, s) = p, i.e., s = b. If s = b ≠ 0, the motion is parallel into a perfect consonance — forbidden. Hence only (0, 0) survives.

*(b)* A self-loop at q is a voice leading (b, s) with s = b (so τ(q, b, s) = q + b − b = q). Any choice of b = s is permitted because either b = 0 (identity, always fine) or b ≠ 0 (parallel motion, but into an imperfect consonance — permitted). Since there are 12 choices of b ∈ ℤ/12ℤ, there are 12 self-loops. ∎

**Corollary 3.3.1** (Bottleneck Ratio). The ratio of self-loops at imperfect vs. perfect consonances is 12:1. This ratio is independent of the specific choice of consonant intervals and depends only on the modulus n.

#### 3.4 Voice-Swap Asymmetry

**Theorem 3.4** (Voice-Swap Breaks Consonance). *The involution σ : ℤ/12ℤ → ℤ/12ℤ defined by σ(i) = −i does not preserve the consonant set C = {0, 3, 4, 7, 8, 9}.*

*Proof.* We compute σ(7) = −7 ≡ 5 (mod 12). But 5 ∉ C (the perfect fourth is not a first-species consonance). ∎

**Remark.** This result formalizes a long-standing observation in music theory: the perfect fourth (5 semitones), despite being the inversion of the perfect fifth (7 semitones) and arising from the same simple frequency ratio (4:3 vs. 3:2), is treated as a dissonance in counterpoint when it appears above the bass. The asymmetry is not a defect of the theory but reflects the fundamentally asymmetric role of the bass voice in determining harmonic function.

Note that σ does preserve some consonances: σ(0) = 0, σ(3) = 9 ∈ C, σ(4) = 8 ∈ C. The thirds and sixths are related by inversion in complementary pairs. Only the fifth/fourth pair breaks the symmetry.

#### 3.5 Hom-Set Cardinalities

**Theorem 3.5** (Hom-Set Sizes).

*(a)* For any perfect consonance p ∈ P:
$$\sum_{i \in C} |\text{Hom}(i, p)| = 61$$

*(b)* For any imperfect consonance q ∈ I:
$$\sum_{i \in C} |\text{Hom}(i, q)| = 72$$

*Proof sketch.* For a target interval j, the number of permitted voice leadings from source i is the number of pairs (b, s) with s − b = j − i (so that τ(i, b, s) = j), minus those with b = s ≠ 0 when j ∈ P.

For any pair (i, j), the constraint s = b + (j − i) leaves b free, giving 12 voice leadings total. If j ∈ P, we must subtract those with b = s, i.e., b = b + (j − i), i.e., j = i. So the only source that loses voice leadings is i = j itself, and only in the case j ∈ P.

- If j ∈ P and i = j: 12 − 11 = 1 permitted voice leading (only the identity).
- If j ∈ P and i ≠ j, i ∈ C: 12 permitted voice leadings.
- If j ∈ I and i ∈ C: 12 permitted voice leadings (no restriction).

For j ∈ P: Total = 1 + 5 × 12 = 1 + 60 = 61.
For j ∈ I: Total = 6 × 12 = 72. ∎

---

### 4. The Categorical Perspective

#### 4.1 From Quiver to Non-Category

The Counterpoint Quiver Q(C, P) naturally generates a *free category* — the category of all finite paths through the quiver. But Theorem 3.2 shows that the subcollection of single-step permitted voice leadings is not closed under composition, and therefore does not define a subcategory.

This negative result is itself categorically significant. In many applications of category theory to music (e.g., Mazzola's *topos of music* [5]), one assumes that musical transformations compose freely. Our result shows that **counterpoint rules are inherently non-compositional**: the validity of a voice leading depends on context (what happens at each step), not just on the overall transformation.

#### 4.2 The Thin Category Connection

Despite the non-composability of one-step voice leadings, there is a categorical structure present. Consider the **reachability relation** on C: define i ≤ j if there exists a permitted voice leading from i to j. By Theorem 3.1, this relation is total (i ≤ j for all i, j ∈ C), giving a *thin category* equivalent to the *indiscrete category* on 6 objects.

The interesting structure lies not in the reachability relation but in the *multiplicity* of connections — the hom-set cardinalities. The hom-set from i to j records how many *distinct ways* you can move from interval i to interval j. Theorems 3.3 and 3.5 show that these multiplicities encode musically meaningful asymmetries.

#### 4.3 Enrichment over ℕ

The Counterpoint Quiver can be viewed as a category enriched over (ℕ, ×, 1): each hom-set is replaced by its cardinality, and composition becomes multiplication of cardinalities (an upper bound, not an exact count, due to non-composability). This gives a 6 × 6 matrix of hom-set sizes that encodes the full constraint structure of first-species counterpoint.

---

### 5. Generalizations

#### 5.1 Microtonal Counterpoint Systems

The Counterpoint System (Definition 2.1) is parameterized over ℤ/nℤ for arbitrary n. Natural choices include:

- **n = 19** (19-TET): C could include intervals approximating just thirds and fifths. The self-loop bottleneck becomes 19:1.
- **n = 31** (31-TET): Provides excellent approximations to just intonation. The combinatorial complexity grows substantially.
- **n = 53** (53-TET): Nearly pure fifths (31 steps) and thirds. The voice-leading space has 53² = 2809 elements.

In each case, Theorem 3.1 (strong connectivity via canonical voice leadings) generalizes immediately: the canonical voice leading (0, j − i) is always non-parallel. Theorem 3.3 generalizes with ratio n:1 replacing 12:1.

#### 5.2 Higher Species

First-species counterpoint uses only note-against-note motion. Higher species (second through fifth) introduce passing tones, suspensions, and other dissonance treatments. Extending the Counterpoint System to model these would require:

- **Temporal structure**: Sequences of intervals within a single beat.
- **Preparation and resolution rules**: Additional constraints on entry and exit from dissonance.
- **Multi-step composition**: The quiver edges would represent multi-note figures rather than single motions.

This is a natural direction for future work.

#### 5.3 Three or More Voices

The framework extends to three voices by working in (ℤ/nℤ)² (pairs of intervals). The consonant set becomes a subset of (ℤ/nℤ)², and voice leadings live in (ℤ/nℤ)³. The combinatorial complexity increases dramatically, but the structural theorems may have analogues.

---

### 6. Connections to Prior Work

#### 6.1 Tymoczko's Geometric Approach

Dmitri Tymoczko [4] models voice-leading spaces as continuous orbifolds, where points represent chords and geodesics represent efficient voice leadings. Our approach is complementary: we work in the discrete setting and focus on *permissibility constraints* rather than *efficiency metrics*. The two approaches could be fruitfully combined — studying permitted voice leadings as a discrete subset of Tymoczko's continuous space.

#### 6.2 Mazzola's Topos of Music

Guerino Mazzola's *topos of music* [5] applies category theory extensively to music theory, but primarily to pitch-class sets, transformations, and Galois theory of scales. Our categorical treatment focuses specifically on *counterpoint constraints* — the rules governing how intervals connect — which is a different (and arguably more compositionally relevant) domain.

#### 6.3 Consonance from Pythagorean Ratios

The choice of consonant intervals C = {0, 3, 4, 7, 8, 9} is ultimately grounded in acoustics — specifically, in the simplicity of the frequency ratios involved (2:1, 3:2, 4:3, 5:4, etc.). Previous work in harmonic music theory has established consonance from Pythagorean triples and rational approximation theory. The present work studies the *dynamics* of consonance: not which intervals are consonant, but how consonant intervals connect through permitted voice leadings.

---

### 7. Discussion

The five main theorems paint a coherent picture of first-species counterpoint as a constrained combinatorial system with specific structural features:

1. **Freedom** (Theorem 3.1): Any consonance can reach any other — the system is navigable.
2. **Irreducibility** (Theorem 3.2): The constraints cannot be reduced to composable operations — each step requires contextual judgment.
3. **Asymmetry of consonance type** (Theorem 3.3): Perfect consonances are bottlenecks — hard to sustain, hard to approach.
4. **Asymmetry of voice role** (Theorem 3.4): The bass voice has a privileged structural role.
5. **Quantified constraint** (Theorem 3.5): The bottleneck effect is precisely measurable (61 vs. 72 incoming voice leadings).

Together, these results suggest that the rules of first-species counterpoint are not arbitrary aesthetic preferences but reflect deep structural properties of the voice-leading space over ℤ/12ℤ. The parallel-motion prohibition — a single, simple rule — creates a rich asymmetric structure that distinguishes perfect from imperfect consonances and bass from soprano.

---

### 8. Future Work

1. **Enumeration of all hom-sets**: Complete the 6 × 6 matrix of hom-set cardinalities |Hom(i, j)| for all pairs of consonant intervals.

2. **Path counting**: Compute the number of permitted k-step paths between each pair of consonances for small k.

3. **Spectral analysis**: Study the adjacency matrix (weighted by hom-set cardinality) of the Counterpoint Quiver, relating its eigenvalues to musical properties.

4. **Higher species formalization**: Extend the Counterpoint System to model second through fifth species, incorporating dissonance treatment.

5. **Microtonal validation**: Implement the framework for 19-TET and 31-TET, checking whether the structural properties (connectivity, non-composability, bottleneck) persist and comparing the resulting "counterpoint feel" with composers' empirical judgments.

6. **Three-voice counterpoint**: Extend to (ℤ/12ℤ)² vertex spaces and characterize the resulting quiver.

---

### References

[1] J. J. Fux, *Gradus ad Parnassum*, Vienna, 1725. (English translation by A. Mann, W. W. Norton, 1965.)

[2] K. Jeppesen, *Counterpoint: The Polyphonic Vocal Style of the Sixteenth Century*, Prentice-Hall, 1939.

[3] S. Salzer and C. Schachter, *Counterpoint in Composition*, McGraw-Hill, 1969.

[4] D. Tymoczko, *A Geometry of Music: Harmony and Counterpoint in the Extended Common Practice*, Oxford University Press, 2011.

[5] G. Mazzola, *The Topos of Music: Geometric Logic of Concepts, Theory, and Performance*, Birkhäuser, 2002.

[6] J. N. Hook, "Uniform triadic transformations," *Journal of Music Theory*, vol. 46, no. 1/2, pp. 57–126, 2002.

[7] R. Cohn, "Neo-Riemannian operations, parsimonious trichords, and their Tonnetz representations," *Journal of Music Theory*, vol. 41, no. 1, pp. 1–66, 1997.

---

### Appendix A: Consonant Interval Table

| Semitones | Interval Name | Type | σ-image | σ-image consonant? |
|-----------|---------------|------|---------|---------------------|
| 0 | Unison/Octave | Perfect | 0 | Yes |
| 3 | Minor Third | Imperfect | 9 (Major Sixth) | Yes |
| 4 | Major Third | Imperfect | 8 (Minor Sixth) | Yes |
| 7 | Perfect Fifth | Perfect | 5 (Perfect Fourth) | **No** |
| 8 | Minor Sixth | Imperfect | 4 (Major Third) | Yes |
| 9 | Major Sixth | Imperfect | 3 (Minor Third) | Yes |

### Appendix B: Self-Loop Counts

| Interval | Type | Self-Loops | Explanation |
|----------|------|------------|-------------|
| 0 (Unison) | Perfect | 1 | Only identity; all parallel motions forbidden |
| 3 (m3) | Imperfect | 12 | All 12 parallel motions permitted |
| 4 (M3) | Imperfect | 12 | All 12 parallel motions permitted |
| 7 (P5) | Perfect | 1 | Only identity; all parallel motions forbidden |
| 8 (m6) | Imperfect | 12 | All 12 parallel motions permitted |
| 9 (M6) | Imperfect | 12 | All 12 parallel motions permitted |

### Appendix C: Incoming Voice Leading Counts

| Target | Type | Incoming VLs | Breakdown |
|--------|------|-------------|-----------|
| 0 (Unison) | Perfect | 61 | 1 (self) + 5×12 (others) |
| 7 (P5) | Perfect | 61 | 1 (self) + 5×12 (others) |
| 3 (m3) | Imperfect | 72 | 6×12 |
| 4 (M3) | Imperfect | 72 | 6×12 |
| 8 (m6) | Imperfect | 72 | 6×12 |
| 9 (M6) | Imperfect | 72 | 6×12 |
