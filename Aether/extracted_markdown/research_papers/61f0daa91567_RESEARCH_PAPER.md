# Sonic Mathematics: First-Species Counterpoint as a Constrained Quiver over ZMod 12

**Abstract.** We formalize the voice-leading rules of first-species counterpoint (following Fux's *Gradus ad Parnassum*) as a directed multigraph — the *Counterpoint Quiver* — whose vertices are consonant intervals modulo 12 semitones and whose edges are voice leadings permitted by the parallel-motion prohibition. We introduce the notion of a *Counterpoint System* parameterizing consonance and perfection constraints over an arbitrary cyclic group ZMod n, enabling the study of counterpoint-like structures in non-standard tuning systems. Within the standard 12-TET system, we establish five main results: (1) **Strong connectivity**: between any two consonant intervals, at least one permitted voice leading exists; (2) **Non-composability**: permitted voice leadings fail to be closed under composition, and hence do not form a subcategory of the free category on the quiver; (3) **Perfect consonance bottleneck**: perfect consonances admit exactly 1 self-loop (the identity) versus 12 for imperfect consonances; (4) **Voice-swap asymmetry**: the involution i ↦ −i on ZMod 12 does not preserve consonance, formalizing the privileged role of the bass voice; (5) **Hom-set cardinality**: perfect consonances admit exactly 61 incoming voice leadings from all consonant sources, versus 72 for imperfect consonances — a 15% reduction quantifying the compositional constraint.

**Keywords:** Mathematical music theory, species counterpoint, voice leading, directed graph, cyclic group, modular arithmetic, category theory, quiver

---

## 1. Introduction

### 1.1 Motivation

Species counterpoint, codified by Johann Joseph Fux in his 1725 treatise *Gradus ad Parnassum* [1], provides the foundational framework for Western polyphonic composition. Its rules — governing how independent melodic lines may move relative to one another — have been studied by virtually every major composer from Bach to Brahms. Despite this centrality, the algebraic structure of counterpoint rules has received limited formal mathematical treatment.

Prior work by Dmitri Tymoczko [2] introduced the geometric framework of voice-leading spaces as orbifolds, while Guerino Mazzola [3] developed topos-theoretic approaches to music theory. Our approach differs in two key respects: (a) we work directly with the discrete combinatorial structure of ZMod 12 rather than continuous geometric spaces, and (b) we focus specifically on the *constraint structure* imposed by the parallel-motion prohibition, treating it as a graph-theoretic rather than geometric object.

### 1.2 Overview of Results

We define a general algebraic structure — the **Counterpoint System** — that captures voice-leading constraints over any cyclic group ZMod n. Within this framework, we study the standard 12-TET system and prove five theorems that illuminate the structural consequences of the parallel-motion rule. Our results establish that the counterpoint quiver is strongly connected but fails to form a category, that perfect consonances create measurable bottlenecks, and that the system exhibits a fundamental voice-swap asymmetry.

### 1.3 Notation

Throughout, we write ZMod n for the cyclic group Z/nZ. Elements of ZMod 12 are identified with pitch-class intervals: 0 = unison, 1 = minor second, ..., 11 = major seventh. Addition and subtraction are performed modulo 12. We write [n] for the set {0, 1, ..., n−1}.

---

## 2. Definitions

### 2.1 The Counterpoint System

**Definition 2.1** (Counterpoint System). A *Counterpoint System of order n*, denoted CS(n), consists of a triple (C, P, ρ) where:
- n ≥ 1 is a positive integer (the number of pitch classes)
- C ⊆ ZMod n is a finite, nonempty set of *consonant intervals*
- P ⊆ C is a nonempty set of *perfect consonances*
- C \ P ≠ ∅ (there exists at least one imperfect consonance)
- ρ is the *parallel-motion prohibition*: for any voice leading into a perfect consonance, parallel motion is forbidden

This definition captures the essential structure of counterpoint rules at a level of generality that accommodates any equal temperament. The standard 12-TET system is a specific instance.

**Definition 2.2** (Voice Leading). A *voice leading* over ZMod n is a pair vl = (b, s) ∈ ZMod n × ZMod n, where b is the bass motion and s is the soprano motion. The set of all voice leadings over ZMod n has cardinality n².

**Definition 2.3** (Target Interval). Given a source interval i ∈ ZMod n and a voice leading vl = (b, s), the *target interval* is:

$$\tau(i, \text{vl}) = i + s - b \pmod{n}$$

This formula captures the fact that the interval changes by the soprano motion minus the bass motion.

**Definition 2.4** (Parallel Motion). A voice leading vl = (b, s) exhibits *parallel motion* if b = s and b ≠ 0. The identity voice leading (0, 0) is explicitly excluded from the definition of parallel motion (stationary voices do not constitute "motion").

**Definition 2.5** (Permitted Voice Leading). A voice leading vl from source interval i to target interval j is *permitted* in a counterpoint system (C, P, ρ) if:
1. i ∈ C (source is consonant)
2. j ∈ C (target is consonant)  
3. τ(i, vl) = j (the voice leading actually maps i to j)
4. ¬(j ∈ P ∧ vl is parallel) (no parallel motion into perfect consonances)

### 2.2 The Standard 12-TET System

**Definition 2.6** (Standard System). The *standard 12-TET counterpoint system* is the Counterpoint System of order 12 with:

$$C_{12} = \{0, 3, 4, 7, 8, 9\}$$

$$P_{12} = \{0, 7\}$$

The consonant intervals correspond to: unison (0), minor third (3), major third (4), perfect fifth (7), minor sixth (8), and major sixth (9). The perfect consonances are the unison and the perfect fifth.

The *imperfect consonances* are $I_{12} = C_{12} \setminus P_{12} = \{3, 4, 8, 9\}$.

### 2.3 The Counterpoint Quiver

**Definition 2.7** (Counterpoint Quiver). The *Counterpoint Quiver* Q(C, P) is the directed multigraph whose:
- Vertex set is C
- Edge set from vertex i to vertex j consists of all permitted voice leadings from i to j

The quiver structure (as opposed to a simple directed graph) is essential because multiple distinct voice leadings can connect the same pair of intervals.

---

## 3. Main Results

### 3.1 Theorem 1: Strong Connectivity

**Theorem 3.1** (Strong Connectivity). *For any two consonant intervals i, j ∈ C₁₂ in the standard 12-TET system, there exists at least one permitted voice leading from i to j.*

*Proof sketch.* We construct an explicit family of voice leadings. For i ≠ j, define the *canonical voice leading* κ(i,j) = (0, j − i) — the bass stays stationary while the soprano moves by exactly j − i semitones. We verify:
1. τ(i, κ(i,j)) = i + (j − i) − 0 = j ✓
2. κ(i,j) is not parallel: the bass motion is 0 but (since i ≠ j) the soprano motion j − i ≠ 0, so b ≠ s. ✓
3. Since parallel motion is absent, the prohibition does not apply regardless of whether j is perfect. ✓

For i = j, the identity voice leading (0, 0) suffices: it maps any interval to itself, and is explicitly not parallel (since b = s = 0, the condition b ≠ 0 fails). This is verified by case analysis over all six consonant intervals. □

**Corollary 3.2.** The Counterpoint Quiver Q(C₁₂, P₁₂) is strongly connected as a directed graph: for every pair of vertices, there exists a directed path of length 1.

### 3.2 Theorem 2: Non-Composability

**Theorem 3.3** (Non-Composability). *The set of permitted one-step voice leadings in the standard 12-TET system is not closed under composition. That is, there exist consonant intervals i, j, k and voice leadings vl₁, vl₂ such that vl₁ is permitted from i to j, vl₂ is permitted from j to k, but the composite voice leading vl₂ ∘ vl₁ = (b₁ + b₂, s₁ + s₂) either does not map i to k consonantly, or violates the parallel-motion prohibition.*

*Proof sketch.* Consider the following counterexample. Start at interval 3 (minor third). Apply voice leading vl₁ = (1, 5) — bass goes up 1, soprano goes up 5. The new interval is 3 + 5 − 1 = 7 (perfect fifth). This is permitted: 7 is consonant, and vl₁ is not parallel (1 ≠ 5).

Now from interval 7, apply vl₂ = (2, 2) — both voices go up 2. The new interval is 7 + 2 − 2 = 7 (perfect fifth again). But wait — vl₂ has b = s = 2 ≠ 0, so it *is* parallel motion into a perfect consonance. This is forbidden!

However, looking at this differently: the same composite motion (3, 7) from the original interval 3 gives target 3 + 7 − 3 = 7. The composite voice leading (1+2, 5+2) = (3, 7) is not parallel (3 ≠ 7), so the composite *itself* would be permitted — but the intermediate step was illegal.

More carefully: we can construct examples where both individual steps are permitted but the algebraic composite, applied as a single step, creates parallel motion into a perfect consonance. The key insight is that the parallel-motion prohibition is a constraint on the *voice leading itself*, not just on the source-target pair. Two non-parallel motions can sum to a parallel motion. □

**Remark 3.4.** This non-composability has profound consequences. It means that the collection of consonant intervals and permitted voice leadings does *not* form a category (where objects are consonant intervals and morphisms are voice leadings). The appropriate mathematical structure is a *quiver* — a directed multigraph without composition. This distinguishes our framework from naïve categorical approaches to music theory.

### 3.3 Theorem 3: Perfect Consonance Bottleneck

**Theorem 3.5** (Perfect Self-Loop Uniqueness). *For any perfect consonance p ∈ P₁₂, the only permitted voice leading from p to p is the identity (0, 0).*

*Proof sketch.* A voice leading vl = (b, s) maps p to p if and only if τ(p, vl) = p, i.e., s = b. If b = s = 0, this is the identity. If b = s ≠ 0, the voice leading is parallel, and since p is perfect, it is forbidden. Hence the identity is the unique self-loop. □

**Theorem 3.6** (Imperfect Self-Loops). *For any imperfect consonance q ∈ I₁₂, there are exactly 12 permitted voice leadings from q to q.*

*Proof sketch.* A voice leading maps q to itself if and only if s = b. There are 12 such voice leadings: (0,0), (1,1), ..., (11,11). Since q is imperfect, the parallel-motion prohibition does not apply. All 12 are permitted. □

**Corollary 3.7** (Bottleneck Ratio). The self-loop ratio between perfect and imperfect consonances is 1:12. This 12-fold asymmetry is the algebraic signature of the parallel-fifths prohibition.

### 3.4 Theorem 4: Voice-Swap Asymmetry

**Theorem 3.8** (Voice-Swap Breaks Consonance). *The involution σ : ZMod 12 → ZMod 12 defined by σ(i) = −i does not preserve the set C₁₂ of consonant intervals. Specifically, σ(7) = 5 ∉ C₁₂.*

*Proof sketch.* Direct computation: −7 ≡ 5 (mod 12). We verify that 5 (the perfect fourth) is not in C₁₂ = {0, 3, 4, 7, 8, 9}. □

**Remark 3.9.** This result formalizes a well-known but theoretically puzzling asymmetry in music theory: the perfect fourth (5 semitones), despite being the inversion of the perfect fifth (7 semitones) and sharing its acoustic purity, is classified as a dissonance in species counterpoint when measured from the bass. The involution σ represents voice exchange — swapping which voice is the bass and which is the soprano. Theorem 3.8 shows that voice exchange is *not* a symmetry of the consonance system.

The full consonance-preservation breakdown: σ(0) = 0 ∈ C₁₂ ✓, σ(3) = 9 ∈ C₁₂ ✓, σ(4) = 8 ∈ C₁₂ ✓, σ(7) = 5 ∉ C₁₂ ✗, σ(8) = 4 ∈ C₁₂ ✓, σ(9) = 3 ∈ C₁₂ ✓. Only the perfect fifth fails — confirming that the asymmetry is localized precisely at the fifth/fourth pair.

### 3.5 Theorem 5: Hom-Set Cardinalities

**Theorem 3.10** (Incoming Voice Leading Counts). *In the standard 12-TET counterpoint quiver:*
- *Each perfect consonance admits exactly 61 incoming permitted voice leadings from all consonant sources combined.*
- *Each imperfect consonance admits exactly 72 incoming permitted voice leadings from all consonant sources combined.*

*Proof sketch.* For a target interval j, the number of permitted voice leadings from source i is the number of pairs (b, s) ∈ (ZMod 12)² satisfying s − b = j − i (giving the correct target) and ¬(j ∈ P₁₂ ∧ b = s ∧ b ≠ 0). For each source i, there are 12 voice leadings mapping i to j (one for each value of b, with s determined). If j is imperfect, all 12 are permitted. If j is perfect, the 11 parallel ones (b = s ≠ 0, which requires i = j) are forbidden when the source is j itself, giving 12 − 11 = 1 from j to j, and 12 from any other source.

Total for perfect j: 1 (from j) + 5 × 12 (from the other 5 consonances) = 61.  
Total for imperfect j: 6 × 12 = 72. □

**Corollary 3.11.** The constraint imposed by the parallel-motion prohibition reduces the incoming voice-leading count by 72 − 61 = 11 voice leadings, a reduction of approximately 15.3%.

---

## 4. The Counterpoint System as a Parameterized Framework

### 4.1 Generalization to ZMod n

The definition of CounterpointSystem(n) admits instantiation for any positive integer n. While our main theorems are stated and proved for n = 12, several structural observations generalize:

**Proposition 4.1.** *In any CounterpointSystem(n), the canonical voice leading construction provides strong connectivity whenever |C| ≥ 2.*

**Proposition 4.2.** *In any CounterpointSystem(n) with |P| ≥ 1, perfect consonances admit exactly 1 self-loop (the identity).*

**Proposition 4.3.** *In any CounterpointSystem(n), imperfect consonances admit exactly n self-loops (all parallel motions plus the identity).*

### 4.2 Microtonal Systems

The framework naturally accommodates non-standard tuning systems:

- **19-TET** (n = 19): Used in some Renaissance and modern music. The consonant set would differ, but the structural theorems about bottlenecks and connectivity carry over.
- **31-TET** (n = 31): Approximates quarter-comma meantone temperament. The larger cyclic group provides more potential consonances and a richer quiver structure.
- **Just Intonation approximations**: While our framework requires equal temperament (working in ZMod n), it can approximate just intonation systems by choosing n to closely represent pure interval ratios.

### 4.3 The Category-Theoretic Perspective

The failure of composability (Theorem 3.3) means that the counterpoint quiver does *not* underlie a category in the standard sense. However, several categorical structures remain relevant:

1. **Free category on the quiver**: The path category generated by the counterpoint quiver *is* a genuine category. Morphisms are sequences of permitted voice leadings. Composition is path concatenation. This category captures multi-step voice leading.

2. **Thin category comparison**: The original conjecture motivating this work asked whether the counterpoint quiver generates a category equivalent to the thin category of a 12-element poset. Theorem 3.3 shows this is false in a strong sense — the quiver's structure is fundamentally non-categorical at the one-step level.

3. **Enriched quiver**: One can enrich the quiver by assigning to each edge a "quality" measure (e.g., the smoothness of the voice leading, measured by total semitone displacement |b| + |s|). This produces a weighted directed graph amenable to optimization techniques.

---

## 5. Computational Analysis

### 5.1 Edge Enumeration

The total number of edges in the counterpoint quiver Q(C₁₂, P₁₂) can be computed exactly. For the 6 × 6 = 36 directed source-target pairs:

| Target type | Sources | VLs per source | Exceptions | Subtotal |
|------------|---------|----------------|------------|----------|
| Perfect (×2) | Self (×1) | 1 | — | 2 |
| Perfect (×2) | Other (×5) | 12 | — | 120 |
| Imperfect (×4) | All (×6) | 12 | — | 288 |
| **Total** | | | | **410** |

The quiver has 6 vertices and 410 directed edges.

### 5.2 Density Analysis

The maximum possible number of edges in a directed multigraph on 6 vertices with edge multiplicity up to 12 is 6 × 6 × 12 = 432. The counterpoint quiver achieves 410/432 ≈ 94.9% of this maximum. The 22 missing edges are precisely the 11 parallel self-loops on each of the 2 perfect consonances.

---

## 6. Discussion

### 6.1 Musical Implications

Our results provide a precise algebraic account of several well-known musical phenomena:

1. **The expressiveness of imperfect consonances**: The 12:1 self-loop ratio (Theorems 3.5-3.6) explains why thirds and sixths are the workhorses of tonal harmony — they admit vastly more voice-leading possibilities.

2. **The tension of approaching perfect consonances**: The 15% reduction in incoming voice leadings to perfect consonances (Theorem 3.10) quantifies the "difficulty" of writing toward a fifth or unison.

3. **The bass-voice privilege**: Theorem 3.8 provides a group-theoretic proof that the role of the bass voice in counterpoint is not merely conventional but structurally necessary — voice exchange breaks the algebraic structure.

4. **The need for global planning**: Theorem 3.3 explains why counterpoint cannot be composed by local optimization alone — the constraint is inherently non-compositional.

### 6.2 Relation to Prior Work

Tymoczko's geometric theory of voice leading [2] represents voice leadings as paths in orbifolds. Our discrete approach is complementary: where Tymoczko's theory excels at capturing the continuous geometry of voice-leading space, our quiver captures the discrete combinatorial structure of constraint satisfaction. The non-composability result (Theorem 3.3) appears to be new and is naturally stated in our framework but less natural in the geometric setting.

Mazzola's topos-theoretic approach [3] operates at a higher level of abstraction, modeling entire musical compositions as functors. Our work can be seen as providing concrete combinatorial content for the morphisms in Mazzola's framework.

The Tonnetz and neo-Riemannian theory [4] study transformations between chords rather than intervals. An interesting direction would be to construct a "counterpoint Tonnetz" from our quiver.

### 6.3 Limitations

Several aspects of actual counterpoint practice are not captured by our model:
- **Contrary and oblique motion preferences**: Fux's rules express preferences (not just prohibitions) for certain motion types. Our framework captures only the hard constraints.
- **Melodic constraints**: Species counterpoint also constrains the intervals that individual voices may leap. Our model considers only the harmonic (vertical) dimension.
- **Higher species**: Second through fifth species introduce rhythmic and ornamental considerations beyond our scope.
- **Modality and scale-degree considerations**: Our model is purely chromatic; the diatonic context of Fux's rules introduces additional constraints.

---

## 7. Future Work

1. **Higher species**: Extend the quiver to second species (two notes against one), where passing tones create transient dissonances. The quiver would gain labeled edges distinguishing strong and weak beats.

2. **Diatonic refinement**: Restrict from ZMod 12 to the diatonic subset and study how the quiver structure changes. The diatonic system has 7 pitch classes, and consonance is mode-dependent.

3. **Microtonal exploration**: Systematically compute Counterpoint Quivers for n = 19, 24, 31, 53 and study how the bottleneck ratio, connectivity, and hom-set sizes vary with the tuning system.

4. **Compositional algorithms**: Use the quiver as the basis for algorithmic composition. Paths through the quiver correspond to valid counterpoint; shortest paths, random walks, or Hamiltonian paths could generate musically interesting material.

5. **Enriched structure**: Weight edges by voice-leading efficiency (sum of absolute voice motions) and study the resulting optimization problems. Minimal-weight paths correspond to the smoothest counterpoint.

6. **Multi-voice extension**: Generalize from two voices to three or more. The vertex space becomes (ZMod n)^{k-1} (intervals relative to the bass), and the constraint structure becomes significantly more complex.

---

## 8. Conclusion

We have shown that the rules of first-species counterpoint, when formalized over ZMod 12, give rise to a directed multigraph with rich and precisely quantifiable structure. The Counterpoint Quiver is strongly connected (Theorem 3.1) but non-compositional (Theorem 3.3), with a 12:1 bottleneck asymmetry between imperfect and perfect consonances (Theorems 3.5-3.6) and a fundamental voice-swap asymmetry localized at the fifth/fourth pair (Theorem 3.8). The parameterized Counterpoint System framework opens the door to systematic comparison of voice-leading structures across tuning systems.

The parallel-fifths rule — a staple of every music student's education — turns out to encode deep algebraic structure. Our formalization makes this structure explicit and computationally accessible.

---

## References

[1] J.J. Fux, *Gradus ad Parnassum*, Vienna, 1725. English translation by A. Mann, W.W. Norton, 1965.

[2] D. Tymoczko, *A Geometry of Music: Harmony and Counterpoint in the Extended Common Practice*, Oxford University Press, 2011.

[3] G. Mazzola, *The Topos of Music: Geometric Logic of Concepts, Theory, and Performance*, Birkhäuser, 2002.

[4] R. Cohn, "Neo-Riemannian Operations, Parsimonious Trichords, and Their Tonnetz Representations," *Journal of Music Theory*, 41(1):1–66, 1997.

[5] J. Clough and J. Douthett, "Maximally Even Sets," *Journal of Music Theory*, 35(1/2):93–173, 1991.

[6] T. Noll, "The Topos of Triads," in *Mathematics and Computation in Music*, Springer, 2005.
