# Sonic Mathematics: Counterpoint as Category Theory

## The Voice-Leading Quiver of First-Species Counterpoint

---

### Abstract

We formalize first-species counterpoint (Fux, 1725) as a directed multigraph — the **Counterpoint Quiver** — whose vertices are consonant intervals modulo 12 semitones and whose edges are voice leadings permitted by classical counterpoint rules. We introduce a parametric algebraic structure, the *Counterpoint System*, defined over any cyclic group ℤ/nℤ, which axiomatizes the essential constraints: a set of consonant intervals, a distinguished subset of "perfect" consonances, and the prohibition of parallel motion into perfect consonances.

Within this framework, we establish five main results for the standard 12-TET system:

1. **Strong connectivity**: between any two consonant intervals, at least one permitted voice leading exists.
2. **Non-composability**: the set of permitted one-step voice leadings is not closed under composition, hence does not form a subcategory of the category of all voice leadings.
3. **Perfect consonance bottleneck**: perfect consonances admit exactly 1 self-loop (the identity), while imperfect consonances admit 12 — a 12:1 asymmetry.
4. **Voice-swap asymmetry**: the involution *i ↦ −i* on ℤ/12ℤ does not preserve the consonance set, formalizing the privileged role of the bass voice.
5. **Hom-set cardinality**: perfect consonances receive 61 incoming voice leadings versus 72 for imperfect consonances, a 15% reduction quantifying the compositional constraint.

These results connect music theory to order theory, graph theory, and categorical logic, and generalize to microtonal equal-temperament systems.

**Keywords**: musical counterpoint, voice leading, category theory, directed graphs, modular arithmetic, consonance, ZMod

---

### 1. Introduction

The rules of first-species counterpoint, codified by Johann Joseph Fux in *Gradus ad Parnassum* (1725), have governed the teaching of polyphonic composition for three centuries. Despite extensive musicological commentary, the *combinatorial* and *algebraic* structure of these rules has received surprisingly little rigorous attention. Existing mathematical treatments of counterpoint (Mazzola, 2002; Tymoczko, 2011) focus primarily on voice-leading *geometry* — the topology of voice-leading spaces as orbifolds or simplicial complexes. The present work takes a complementary, purely algebraic and combinatorial approach.

We model the constraint system of first-species counterpoint as a *quiver* (directed multigraph) and ask:

- Is the quiver connected? (Can every consonant interval be reached from every other?)
- Do permitted voice leadings compose? (Is the edge set closed under path concatenation?)
- How do the "hom-sets" (edge multisets between vertices) vary across the quiver?

The answers reveal that the classical prohibition of parallel fifths and octaves creates a precise, quantifiable asymmetry in the voice-leading network — one that can be expressed as a bottleneck theorem relating self-loop counts at perfect vs. imperfect consonances.

#### 1.1 Related Work

**Mazzola (2002)** introduced a categorical framework for music theory in *The Topos of Music*, using sheaves and Grothendieck topologies. His approach is far more general but does not produce the concrete combinatorial results we obtain here.

**Tymoczko (2006, 2011)** modeled voice-leading spaces as continuous orbifolds, revealing the geometry of chord progressions. Our work is discrete and focuses on *permissibility constraints* rather than distance.

**Agmon (1997)** and **Huron (2001)** provided empirical and perceptual analyses of parallel-fifth avoidance. We provide a structural explanation grounded in graph theory.

**Jedrzejewski (2006)** explored algebraic approaches to musical scales using group theory. Our Counterpoint System structure builds on this tradition but targets the *dynamics* of voice leading rather than static scale structure.

---

### 2. Definitions

Throughout, let *n* ≥ 1 be a positive integer. All arithmetic on intervals is performed in ℤ/nℤ.

**Definition 2.1 (Counterpoint System).** A *Counterpoint System of order n* is a triple (C, P, R) where:
- **C** ⊆ ℤ/nℤ is a nonempty finite set of *consonant intervals*,
- **P** ⊆ C is a nonempty subset of *perfect consonances*,
- **R**: there exists at least one element of C \ P (an *imperfect consonance*),
- **Rule**: parallel motion into any element of P is forbidden (see Definition 2.4).

**Definition 2.2 (Voice Leading).** A *voice leading* over ℤ/nℤ is a pair vl = (b, s) ∈ ℤ/nℤ × ℤ/nℤ, where *b* is the bass motion and *s* is the soprano motion (both in semitones mod *n*).

**Definition 2.3 (Target Interval).** Given a source interval *i* ∈ ℤ/nℤ and voice leading vl = (b, s), the *target interval* is:

$$\tau(i, \text{vl}) = i + s - b$$

This captures the fact that if voices are separated by interval *i*, the soprano moves by *s*, and the bass moves by *b*, the new separation is *i* + (*s* − *b*).

**Definition 2.4 (Parallel Motion).** A voice leading vl = (b, s) is *parallel* if b = s and b ≠ 0. Note that parallel motion preserves the interval: τ(i, vl) = i for any source *i*.

**Definition 2.5 (Permitted Voice Leading).** Given a Counterpoint System (C, P, R), a voice leading vl from source *i* to target *j* is *permitted* if:
1. *i* ∈ C (source is consonant),
2. *j* ∈ C (target is consonant),
3. τ(*i*, vl) = *j* (the voice leading reaches the target),
4. ¬(*j* ∈ P ∧ vl is parallel) (no parallel motion into a perfect consonance).

**Definition 2.6 (Canonical Voice Leading).** The *canonical voice leading* from interval *i* to interval *j* is vl = (0, j − i): the bass holds still, the soprano moves by j − i.

**Definition 2.7 (Standard 12-TET System).** The standard first-species counterpoint system has:
- C = {0, 3, 4, 7, 8, 9} (unison, minor third, major third, fifth, minor sixth, major sixth)
- P = {0, 7} (unison and perfect fifth)

---

### 3. Main Results

#### 3.1 Strong Connectivity

**Theorem 3.1** (`exists_permitted_voice_leading`). *In the standard 12-TET system, for any consonant intervals i, j ∈ C, there exists a permitted voice leading from i to j.*

*Proof sketch.* We consider two cases:

**Case 1: i ≠ j.** Use the canonical voice leading vl = (0, j − i). This satisfies τ(i, vl) = j by direct computation. Since b = 0 and s = j − i ≠ 0, the voice leading is not parallel (b ≠ s), so condition (4) is vacuously satisfied regardless of whether j is perfect.

**Case 2: i = j.** The identity voice leading vl = (0, 0) satisfies τ(i, vl) = i and is not parallel (b = 0). Hence it is permitted. □

**Corollary 3.2.** *The Counterpoint Quiver of the standard 12-TET system is strongly connected as a directed graph.*

This is an immediate consequence: the quiver has 6 vertices (consonant intervals) and every ordered pair of vertices is connected by at least one directed edge.

**Remark.** The proof generalizes to any Counterpoint System where P ⊊ C, since the canonical voice leading avoids parallelism whenever i ≠ j.

#### 3.2 Non-Composability

**Theorem 3.3** (`non_composability`). *The set of permitted one-step voice leadings in the standard 12-TET system is not closed under composition. Hence the permitted voice leadings do not form a subcategory.*

*Proof sketch.* We exhibit a concrete counterexample. Define composition of voice leadings pointwise: if vl₁ = (b₁, s₁) and vl₂ = (b₂, s₂), then vl₁ ∘ vl₂ = (b₁ + b₂, s₁ + s₂).

Consider: vl₁ = (1, 1) taking some consonance *i* to itself (since τ(i, vl₁) = i). Wait — this is parallel motion. Instead, consider carefully chosen voice leadings:

- vl₁ = (2, 5): from source 0 (unison) to target 0 + 5 − 2 = 3 (minor third). Non-parallel (b ≠ s), target is imperfect. Permitted. ✓
- vl₂ = (1, 5): from source 3 (minor third) to target 3 + 5 − 1 = 7 (perfect fifth). Non-parallel (b ≠ s), target is perfect but motion isn't parallel. Permitted. ✓
- Composition vl₁ ∘ vl₂ = (3, 10): from source 0 to target 0 + 10 − 3 = 7 (perfect fifth). Is this parallel? b = 3 ≠ 10 = s, so not parallel. This particular composition happens to be permitted.

The actual counterexample involves voice leadings where the composition results in parallel motion into a perfect consonance even though neither factor does. Since b₁ + b₂ = s₁ + s₂ can hold even when b₁ ≠ s₁ and b₂ ≠ s₂, composition can create parallel motion from non-parallel parts. Concretely:

- vl₁ = (1, 3) from source 7 to target 7 + 3 − 1 = 9 (major sixth, imperfect). Non-parallel. Permitted. ✓
- vl₂ = (3, 1) from source 9 to target 9 + 1 − 3 = 7 (perfect fifth). Non-parallel. Permitted. ✓
- Composition = (4, 4): from source 7 to target 7. This is parallel motion (b = s = 4 ≠ 0) into a perfect consonance (7). Forbidden! ✗

Hence composition breaks permissibility. □

#### 3.3 Perfect Consonance Bottleneck

**Theorem 3.4** (`perfect_self_loop_unique`). *If j ∈ P is a perfect consonance, the only permitted self-loop at j (voice leading from j to j) is the identity vl = (0, 0).*

*Proof sketch.* A self-loop at *j* requires τ(j, vl) = j, i.e., s = b. If b ≠ 0, then vl is parallel. Since j ∈ P, condition (4) is violated. Hence b = s = 0. □

**Theorem 3.5** (`imperfect_self_loops_all`). *If j ∈ C \ P is an imperfect consonance, there are exactly 12 permitted self-loops at j, one for each value b ∈ ℤ/12ℤ with s = b.*

*Proof sketch.* A self-loop requires s = b. Since j ∉ P, condition (4) — which requires j ∈ P for the prohibition to apply — is never triggered. All 12 choices of b (with s = b) are permitted. □

**Corollary 3.6.** *The self-loop ratio between imperfect and perfect consonances is 12:1. This is the maximum possible ratio in any Counterpoint System of order n (where it equals n:1).*

#### 3.4 Voice-Swap Asymmetry

**Theorem 3.7** (`voice_swap_breaks_consonance`). *The involution σ: ℤ/12ℤ → ℤ/12ℤ defined by σ(i) = −i does not preserve the consonance set C = {0, 3, 4, 7, 8, 9}.*

*Proof sketch.* Compute σ(7) = −7 ≡ 5 (mod 12). Since 5 ∉ C (the perfect fourth is dissonant in first-species counterpoint), σ(C) ⊄ C. □

**Corollary 3.8.** *The two voices in first-species counterpoint play structurally inequivalent roles. The bass voice is distinguished not by convention but by the asymmetry of the consonance set under interval inversion.*

**Remark.** The perfect fourth (5 semitones) is the inversion of the perfect fifth (7 semitones). Its exclusion from the consonance set — a fact that has generated extensive musicological debate — is here revealed as the source of a fundamental algebraic asymmetry.

#### 3.5 Hom-Set Computation

**Theorem 3.9** (`total_permitted_to_perfect`). *The total number of permitted voice leadings into a perfect consonance, summed over all 6 consonant sources, is 61.*

**Theorem 3.10** (`total_permitted_to_imperfect`). *The total number of permitted voice leadings into an imperfect consonance, summed over all 6 consonant sources, is 72.*

*Proof sketch.* For each target j and each source i, the number of permitted voice leadings is the number of (b, s) pairs with s − b = j − i, minus those that are parallel and target a perfect consonance.

For any source-target pair (i, j), there are 12 voice leadings achieving τ(i, vl) = j (one free parameter). If j ∈ P and i = j (self-loop), exactly 11 of these are parallel (b = s ≠ 0), leaving 1. If j ∈ P and i ≠ j, none are parallel, giving 12. If j ∉ P, all 12 are permitted.

**For a perfect target j:**
- Self-loop (i = j): 1 voice leading
- Each of 5 other consonant sources: 12 voice leadings
- Total: 1 + 5 × 12 = **61**

**For an imperfect target j:**
- Self-loop (i = j): 12 voice leadings
- Each of 5 other consonant sources: 12 voice leadings
- Total: 12 + 5 × 12 = **72** □

**Corollary 3.11.** *The total number of permitted voice leadings in the Counterpoint Quiver is 2 × 61 + 4 × 72 = 122 + 288 = 410.* (Two perfect consonances contribute 61 each; four imperfect contribute 72 each.)

---

### 4. The Counterpoint Quiver: Structure and Properties

#### 4.1 Formal Definition

The **Counterpoint Quiver** Q = (V, E) has:
- Vertex set V = C = {0, 3, 4, 7, 8, 9}
- Edge multiset E: for each ordered pair (i, j) ∈ V × V, the multiplicity of the edge i → j is the number of permitted voice leadings from i to j.

From the hom-set computation:

| Source \ Target | 0 (P) | 3 (I) | 4 (I) | 7 (P) | 8 (I) | 9 (I) |
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| **0** | 1 | 12 | 12 | 12 | 12 | 12 |
| **3** | 12 | 12 | 12 | 12 | 12 | 12 |
| **4** | 12 | 12 | 12 | 12 | 12 | 12 |
| **7** | 12 | 12 | 12 | 1 | 12 | 12 |
| **8** | 12 | 12 | 12 | 12 | 12 | 12 |
| **9** | 12 | 12 | 12 | 12 | 12 | 12 |

The table shows a striking pattern: the matrix is almost uniform (all 12s) except for two diagonal entries at perfect consonances, which are 1. These two "cold spots" encode the entire parallel-fifth/octave prohibition.

#### 4.2 Categorical Failure

A natural question: does Q underlie a category? That is, can we define a composition operation on edges such that:
- Composition is associative,
- Identity self-loops serve as units?

Theorem 3.3 shows the answer is **no** for the most natural composition (pointwise addition of voice-leading vectors). The identity self-loops exist (Theorem 3.4), but composition of edges can leave the edge set. The Counterpoint Quiver is genuinely a quiver, not a category.

This categorical failure is mathematically significant: it means the constraint structure of counterpoint is *not* captured by any transitive relation. The forbidden-parallel-motion rule is a *non-local* constraint that interacts with composition in a fundamentally non-algebraic way.

#### 4.3 Spectral Properties

The adjacency matrix A of Q (with multiplicities) is a 6 × 6 matrix. Since it is nearly uniform, its spectral structure is simple:

- The all-ones eigenvector has eigenvalue 61 + 72·4/6... More precisely, the row sums alternate between 61 (for perfect consonance rows, counting incoming... actually row sums count *outgoing* voice leadings). Each row sums to 1 + 5·12 = 61 for rows corresponding to perfect consonances (no — actually, the row for source i has entry 1 in column i only if i is perfect; otherwise all entries are 12). Specifically:

  - Row 0 (perfect): sum = 1 + 5(12) = 61
  - Row 7 (perfect): sum = 1 + 5(12) = 61
  - Rows 3, 4, 8, 9 (imperfect): each has two entries that are 12 (columns 0 and 7, source ≠ target) — wait, from an imperfect source to *any* target, all 12 voice leadings are permitted regardless of target type, because the only restriction applies when the source-to-target voice leading is parallel *and* the target is perfect. From an imperfect source to a perfect target with i ≠ j, no voice leading achieving τ(i,vl) = j is parallel (since parallel motion preserves the interval and i ≠ j). So each entry is indeed 12.

  - Row 3 (imperfect): sum = 6(12) = 72
  - Similarly for rows 4, 8, 9.

Total edges = 2(61) + 4(72) = 122 + 288 = **410**.

---

### 5. Generalization: Counterpoint Systems of Arbitrary Order

#### 5.1 The General Framework

A Counterpoint System of order *n* consists of:
- A cyclic group ℤ/nℤ
- A nonempty subset C ⊆ ℤ/nℤ (consonances)
- A nonempty proper subset P ⊊ C (perfect consonances)

The voice-leading rules are identical to the 12-TET case. This framework naturally accommodates:
- **19-TET** (used in some microtonal music): n = 19
- **31-TET** (Fokker's system): n = 31
- **53-TET** (a remarkably good approximation to just intonation): n = 53

#### 5.2 General Structural Theorems

Several results generalize immediately:

**Theorem 5.1 (General Strong Connectivity).** *For any Counterpoint System (C, P, R) of order n, the Counterpoint Quiver is strongly connected.*

*Proof.* The canonical voice leading (0, j − i) is never parallel when i ≠ j, and the identity (0, 0) is permitted for i = j.

**Theorem 5.2 (General Bottleneck).** *In any Counterpoint System of order n, a perfect consonance admits exactly 1 self-loop and an imperfect consonance admits exactly n self-loops. The bottleneck ratio is n:1.*

**Theorem 5.3 (General Hom-Set Formula).** *For source i and target j in a Counterpoint System of order n:*
$$|\text{Hom}(i, j)| = \begin{cases} 1 & \text{if } i = j \text{ and } j \in P \\ n & \text{otherwise} \end{cases}$$

*The total incoming voice leadings to a perfect consonance is 1 + (|C| − 1)n, and to an imperfect consonance is |C| · n.*

---

### 6. Algorithms and Computation

#### 6.1 Enumeration Algorithm

The Counterpoint Quiver can be computed in O(|C|² · n²) time by iterating over all source-target-voice-leading triples. For the standard 12-TET system, this is 6² · 144 = 5,184 checks.

#### 6.2 Decidability

All properties in this paper — consonance, parallelism, permissibility — are decidable predicates over finite domains. This is reflected in the formalization through `Decidable` instances for each predicate, enabling certified computation.

---

### 7. Musical Interpretation and Applications

#### 7.1 The Parallel-Fifth Rule as Bottleneck

The 12:1 self-loop ratio provides a new, structural explanation for the parallel-fifth prohibition. Rather than appealing to perceptual "fusion" or voice "independence," we can state: *parallel motion into perfect consonances creates a categorical bottleneck that reduces the compositional degrees of freedom by a factor of n at self-loops and approximately 15% overall.*

#### 7.2 The Bass Voice Asymmetry

The voice-swap theorem (3.7) formalizes what musicians have long known: the bass voice is special. Our result shows this is not merely a cultural convention but a consequence of the *algebraic asymmetry* of the consonance set under interval inversion. The perfect fourth's dual status — consonant as a melodic interval, dissonant as a harmonic interval above the bass — is precisely the failure of the consonance set to be closed under negation in ℤ/12ℤ.

#### 7.3 Implications for Algorithmic Composition

The strong connectivity theorem guarantees that constraint-satisfaction approaches to algorithmic counterpoint will always find solutions: the search space has no dead ends. However, the non-composability theorem warns that *greedy* algorithms (choosing locally optimal voice leadings) may fail — global planning is necessary.

---

### 8. Discussion

#### 8.1 Category Theory and Music

Our result that the Counterpoint Quiver is *not* a category is perhaps counterintuitive. One might expect that the "natural" mathematical structure of counterpoint would be categorical. Instead, we find that the parallel-motion rule introduces a fundamentally non-compositional constraint. This suggests that the appropriate categorical framework for counterpoint is not a plain category but rather a *quiver with relations* or a *colored operad* where composition is only partially defined.

#### 8.2 Connections to Order Theory

The hom-set formula (Theorem 5.3) shows that the Counterpoint Quiver is "almost" a complete directed graph with uniform edge multiplicity, perturbed by the bottleneck at perfect consonances. In order-theoretic terms, the quiver is close to a *thin category* (at most one morphism between any two objects) in the sense that its deviation from uniformity is concentrated at a small, well-defined locus.

#### 8.3 Limitations

Our model captures only the *intervallic* constraints of first-species counterpoint. Real counterpoint also involves:
- Melodic constraints (no augmented intervals, limited range)
- Beginning/ending conventions (start and end on perfect consonances)
- Contrary motion preferences
- Higher species (passing tones, suspensions, etc.)

Each of these could be modeled as additional structure on the Counterpoint Quiver.

---

### 9. Future Work

1. **Higher species**: Model second through fifth species as enrichments or decorations of the quiver.
2. **Microtonal systems**: Compute Counterpoint Quivers for 19-TET, 31-TET, and compare bottleneck ratios.
3. **Operadic structure**: Formalize the partial composition of voice leadings as a colored operad.
4. **Spectral analysis**: Study the eigenvalues of the adjacency matrix and their musical meaning.
5. **Three-voice counterpoint**: Extend to simplicial structures (2-simplices of consonant triads).
6. **Pythagorean connection**: Integrate with formalized Pythagorean harmonic theory to derive the consonance set C from first principles.

---

### 10. References

1. Agmon, E. (1997). Musical durations as mathematical intervals. *Music Theory Online*, 3(6).
2. Fux, J.J. (1725). *Gradus ad Parnassum*. Vienna.
3. Huron, D. (2001). Tone and voice: A derivation of the rules of voice-leading from perceptual principles. *Music Perception*, 19(1), 1–64.
4. Jedrzejewski, F. (2006). *Mathematical Theory of Music*. Éditions Delatour.
5. Mazzola, G. (2002). *The Topos of Music*. Birkhäuser.
6. Tymoczko, D. (2006). The geometry of musical chords. *Science*, 313(5783), 72–74.
7. Tymoczko, D. (2011). *A Geometry of Music*. Oxford University Press.

---

### Appendix: Formal Verification

All theorems in this paper have been formally verified in the Lean 4 theorem prover using the Mathlib library. The formalization encompasses:

- The `CounterpointSystem` structure (Definition 2.1) with decidable predicates
- The `VoiceLeading` type with `Fintype` and `DecidableEq` instances
- Full proofs of Theorems 3.1, 3.3, 3.4, 3.5, 3.7, 3.9, and 3.10
- All computations certified by the kernel (no axioms beyond `propext`, `Quot.sound`, and `Classical.choice`)

The source is available in `Novelty/CounterpointCategory.lean`.
