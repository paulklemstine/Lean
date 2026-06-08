# Sonic Mathematics: First-Species Counterpoint as a Directed Graph over ℤ/12ℤ

**Abstract.** We formalize first-species counterpoint rules from Fux's *Gradus ad Parnassum* as a directed multigraph — the *Counterpoint Quiver* — whose vertices are consonant intervals modulo 12 semitones and whose edges are voice leadings permitted by the prohibition on parallel motion into perfect consonances. We introduce a parametric structure, the *Counterpoint System*, that captures these constraints over any equal temperament ℤ/nℤ and prove five structural results: (1) the quiver is strongly connected; (2) permitted voice leadings fail to close under composition, so the quiver does not underlie a subcategory of the free category on the complete graph; (3) perfect consonances admit exactly 1 self-loop versus 12 for imperfect consonances; (4) the consonance set is not invariant under the involution i ↦ −i, formalizing bass-voice privilege; and (5) perfect consonances receive exactly 61 incoming permitted voice leadings versus 72 for imperfect consonances. These results connect music theory, combinatorics on ℤ/nℤ, and the theory of quivers.

**Keywords.** counterpoint, voice leading, directed graph, quiver, modular arithmetic, consonance, category theory, Fux, music theory

---

## 1. Introduction

The rules of first-species counterpoint — the simplest layer of the contrapuntal discipline codified by Johann Joseph Fux in 1725 — prescribe how two voices may move simultaneously while maintaining consonance at every beat. Despite their age and pedagogical origin, these rules encode a rich combinatorial structure that has attracted attention from mathematicians and music theorists alike.

Previous mathematical treatments of counterpoint include Mazzola's *topos-theoretic* approach [Mazzola 2002], Tymoczko's continuous voice-leading geometry [Tymoczko 2011], and Cohn's *neo-Riemannian* transformational theory [Cohn 1998]. These works variously model voice leadings as elements of quotient spaces, orbifolds, or group actions. Our approach differs in a fundamental way: rather than embedding voice leadings in a continuous space, we model them as edges of a discrete directed multigraph (quiver) and study the combinatorial and algebraic properties of this graph.

The central objects of study are:

- **Vertices**: the six consonant intervals {0, 3, 4, 7, 8, 9} ⊂ ℤ/12ℤ, representing unison, minor third, major third, perfect fifth, minor sixth, and major sixth.
- **Edges**: permitted voice leadings (b, s) ∈ (ℤ/12ℤ)² mapping a source consonance to a target consonance without violating the parallel-motion rule.

We introduce the *Counterpoint System* as a parametric mathematical structure over ℤ/nℤ and prove structural theorems at this level of generality before specializing to n = 12.

### 1.1 Contributions

1. A novel algebraic structure (`CounterpointSystem n`) abstracting counterpoint constraints over arbitrary equal temperaments.
2. Formal proof of strong connectivity of the Counterpoint Quiver.
3. Formal proof that permitted voice leadings are *not* closed under composition.
4. Quantitative analysis of the self-loop and hom-set structure, revealing a precise bottleneck at perfect consonances.
5. Formal proof of consonance-set asymmetry under pitch-class inversion.

### 1.2 Organization

Section 2 introduces the formal definitions. Section 3 states and proves the main results. Section 4 discusses the general framework beyond 12-TET. Section 5 describes algorithms for computing the quiver. Section 6 provides discussion, structural interpretation, and connections to algebraic topology. Section 7 outlines future work. Section 8 summarizes computational verification. Section 9 concludes.

---

## 2. Definitions

### 2.1 The Counterpoint System

**Definition 2.1** (Counterpoint System). Let n ∈ ℕ with n ≥ 1. A *counterpoint system* over ℤ/nℤ is a triple (C, P, ρ) where:

- C ⊆ ℤ/nℤ is a finite nonempty set of *consonant intervals*.
- P ⊆ C is a nonempty set of *perfect consonances*.
- C \ P is nonempty (there exists at least one *imperfect* consonance).
- ρ is the *parallel motion restriction*: a voice leading into a perfect consonance by parallel motion is forbidden.

This definition captures the essential constraints of any counterpoint-like system. The parameterization by n allows the framework to be applied not only to standard 12-TET but to microtonal systems such as 19-TET, 24-TET, or 31-TET.

The formal structure requires four proof obligations: `perfect_sub : P ⊆ C`, `consonant_nonempty : C.Nonempty`, `perfect_nonempty : P.Nonempty`, and `has_imperfect : ∃ i ∈ C, i ∉ P`. These ensure that the system is non-degenerate and that the distinction between perfect and imperfect consonances is meaningful.

**Definition 2.2** (Voice Leading). A *voice leading* over ℤ/nℤ is a pair vl = (b, s) ∈ (ℤ/nℤ)² where b is the bass motion and s is the soprano motion, both measured in pitch classes. The set of all voice leadings is (ℤ/nℤ)², which has cardinality n².

**Definition 2.3** (Target Interval). Given a source interval i ∈ ℤ/nℤ and voice leading vl = (b, s), the *target interval* is:

$$\tau(i, vl) = i + s - b$$

This formula reflects the geometry: if the soprano is currently i semitones above the bass, and the bass moves by b while the soprano moves by s, the new interval is i + (s − b). The function τ is linear in both i and (s − b).

**Definition 2.4** (Parallel Motion). A voice leading vl = (b, s) exhibits *parallel motion* if b = s and b ≠ 0. The condition b ≠ 0 ensures that the identity (no motion at all) is not classified as parallel. When b = s ≠ 0, both voices move by the same amount, preserving the interval: τ(i, vl) = i.

**Definition 2.5** (Permitted Voice Leading). A voice leading vl from source interval i to target interval j in counterpoint system (C, P, ρ) is *permitted* if:

1. i ∈ C and j ∈ C (both intervals are consonant).
2. τ(i, vl) = j (the voice leading maps i to j).
3. ¬(j ∈ P ∧ vl is parallel) (parallel motion into a perfect consonance is forbidden).

The decidability of this predicate is immediate since all components are decidable predicates on finite types.

### 2.2 The Standard 12-TET System

**Definition 2.6** (Standard System). The *standard 12-TET first-species counterpoint system* is:

- C₁₂ = {0, 3, 4, 7, 8, 9} ⊂ ℤ/12ℤ
- P₁₂ = {0, 7} ⊂ ℤ/12ℤ

The imperfect consonances are C₁₂ \ P₁₂ = {3, 4, 8, 9}. The six consonant intervals correspond to the traditional classification:

| Semitones | Interval | Type |
|-----------|----------|------|
| 0 | Unison / Octave | Perfect |
| 3 | Minor third | Imperfect |
| 4 | Major third | Imperfect |
| 7 | Perfect fifth | Perfect |
| 8 | Minor sixth | Imperfect |
| 9 | Major sixth | Imperfect |

All four proof obligations are discharged by decidability: P₁₂ ⊆ C₁₂, both sets are nonempty, and 3 ∈ C₁₂ \ P₁₂.

### 2.3 The Counterpoint Quiver

**Definition 2.7** (Counterpoint Quiver). The *counterpoint quiver* Q(C, P) of a counterpoint system is the directed multigraph with:

- Vertex set: C
- Edge set: Hom(i, j) = {vl ∈ (ℤ/nℤ)² : vl is permitted from i to j}

for each pair (i, j) ∈ C × C. The quiver has |C| vertices and ∑ᵢⱼ |Hom(i,j)| edges.

### 2.4 The Canonical Voice Leading

**Definition 2.8** (Canonical Voice Leading). For any pair of intervals i, j ∈ ℤ/nℤ, the *canonical voice leading* is κ(i,j) = (0, j − i): the bass remains stationary while the soprano moves by j − i.

**Lemma 2.9.** τ(i, κ(i,j)) = j for all i, j ∈ ℤ/nℤ. *Proof:* τ(i, (0, j−i)) = i + (j−i) − 0 = j.

**Lemma 2.10.** If i ≠ j then κ(i,j) is not parallel. *Proof:* κ(i,j) = (0, j−i). For parallel motion we need b = s, i.e., 0 = j − i, i.e., i = j. Contradiction.

---

## 3. Main Results

### 3.1 Strong Connectivity

**Theorem 3.1** (Strong Connectivity). *For every pair of consonant intervals i, j ∈ C₁₂ in the standard 12-TET system, there exists a permitted voice leading from i to j.*

*Proof sketch.* We distinguish two cases:

**Case 1: i ≠ j.** The canonical voice leading κ(i,j) = (0, j − i) satisfies τ(i, κ) = j by Lemma 2.9. By Lemma 2.10, κ is not parallel. Therefore the parallel-motion restriction cannot apply, regardless of whether j is perfect or imperfect. Since i, j ∈ C₁₂, the voice leading is permitted.

**Case 2: i = j.** The identity voice leading id = (0, 0) satisfies τ(i, id) = i. Since b = 0, the condition b ≠ 0 for parallel motion fails. The voice leading is permitted for any consonance, perfect or imperfect.

In both cases Hom(i, j) ≠ ∅, establishing strong connectivity. ∎

**Remark 3.2.** This result holds for any counterpoint system (C, P) over any ℤ/nℤ, since the canonical voice leading and identity argument depend only on the algebraic structure of ℤ/nℤ, not on specific values. The formal proof handles the i = j case by case analysis on all six consonant intervals.

### 3.2 Non-Composability

**Definition 3.2** (Composition of Voice Leadings). Given voice leadings vl₁ = (b₁, s₁) and vl₂ = (b₂, s₂), their *composition* is vl₂ ∘ vl₁ = (b₁ + b₂, s₁ + s₂).

This operation corresponds to the cumulative effect of two successive voice motions: the total bass motion is b₁ + b₂ and the total soprano motion is s₁ + s₂. Note that τ(i, vl₂ ∘ vl₁) = τ(τ(i, vl₁), vl₂), so composition is compatible with the target-interval function.

**Theorem 3.3** (Non-Composability). *The set of permitted voice leadings in the standard 12-TET system is not closed under composition. That is, there exist consonant intervals i, j, k and permitted voice leadings vl₁ : i → j and vl₂ : j → k such that vl₂ ∘ vl₁ is not permitted from i to k.*

*Proof sketch.* We exhibit an explicit counterexample:

- Source i = 0 (unison), intermediate j = 3 (minor third), target k = 0 (unison).
- vl₁ = (0, 3): bass stays, soprano moves up 3. τ(0, vl₁) = 3. Not parallel (b ≠ s), so permitted.
- vl₂ = (1, 10): bass moves up 1, soprano moves up 10. τ(3, vl₂) = 3 + 10 − 1 = 12 ≡ 0. Since b₂ = 1 ≠ 10 = s₂, not parallel, so permitted.
- Composite vl₂ ∘ vl₁ = (0 + 1, 3 + 10) = (1, 1): both voices move by 1. τ(0, (1,1)) = 0 + 1 − 1 = 0 (unison). Since b = s = 1 ≠ 0, this is parallel motion into a perfect consonance — FORBIDDEN.

Each step is individually permitted, but the composite violates the parallel-motion rule. Exhaustive enumeration reveals 1,320 such counterexample triples in the full quiver. ∎

**Corollary 3.4.** The counterpoint quiver Q(C₁₂, P₁₂) does not underlie a subcategory of the free category on the complete directed graph on C₁₂. The permitted voice leadings form a quiver — a directed graph — but not a category. This is the formal justification for our use of the term "quiver" rather than "category" throughout.

### 3.3 The Perfect Consonance Bottleneck

**Theorem 3.5** (Self-Loop Counts). *In the standard 12-TET system:*

*(a) If p ∈ P₁₂ is a perfect consonance, then* |Hom(p, p)| = 1.

*(b) If q ∈ C₁₂ \ P₁₂ is an imperfect consonance, then* |Hom(q, q)| = 12.

*Proof sketch.*

**(a)** A self-loop at p requires τ(p, vl) = p, i.e., p + s − b = p, i.e., s = b. If s = b ≠ 0, the voice leading is parallel motion into p ∈ P₁₂ — forbidden. So b = s = 0, giving only the identity. |Hom(p,p)| = 1. ∎

**(b)** A self-loop at q requires s = b. Since q ∉ P₁₂, the parallel-motion restriction does not apply. Any of the 12 values b = s ∈ ℤ/12ℤ gives a permitted self-loop. |Hom(q,q)| = 12. ∎

**Theorem 3.6** (Hom-Set Cardinalities). *In the standard 12-TET system:*

*(a) For each perfect consonance p ∈ P₁₂,*

$$\sum_{i \in C_{12}} |\text{Hom}(i, p)| = 61$$

*(b) For each imperfect consonance q ∈ C_{12} \setminus P_{12},$*

$$\sum_{i \in C_{12}} |\text{Hom}(i, q)| = 72$$

*Proof sketch.* For a fixed target j ∈ C₁₂, a voice leading (b, s) from source i is permitted if and only if:
1. i ∈ C₁₂ (6 possible sources)
2. s = j − i + b (uniquely determined by b and i)
3. ¬(j ∈ P₁₂ ∧ b = s ∧ b ≠ 0)

For each source i, there are 12 choices of b ∈ ℤ/12ℤ, each determining a unique s = j − i + b. The condition b = s is equivalent to b = j − i + b, i.e., j = i. So the parallel-motion exclusion applies only when the source equals the target (self-loops).

For a perfect target j: the source i = j loses 11 voice leadings (the 11 nonzero values of b = s), giving:

$$\sum_{i \in C_{12}} |Hom(i, j)| = 5 \times 12 + 1 \times 1 = 61$$

For an imperfect target j: no exclusion is needed:

$$\sum_{i \in C_{12}} |Hom(i, j)| = 6 \times 12 = 72$$ ∎

**Remark 3.7.** The ratio 61/72 ≈ 0.847 quantifies the *constraint intensity* of perfect consonances: they are approximately 15.3% harder to reach than imperfect consonances. Equivalently, of the 432 possible edges in the unconstrained quiver, exactly 22 = 2 × 11 are removed — one for each nonzero parallel motion at each of the two perfect consonances.

### 3.4 Voice-Swap Asymmetry

**Theorem 3.8** (Voice-Swap Breaks Consonance). *The involution ι : ℤ/12ℤ → ℤ/12ℤ defined by ι(i) = −i does not preserve the consonance set C₁₂. Specifically, ι(7) = 5 ∉ C₁₂.*

*Proof sketch.* Direct computation: −7 ≡ 5 (mod 12), and 5 ∉ {0, 3, 4, 7, 8, 9}. The remaining consonances are either fixed (ι(0) = 0) or map to consonances (ι(3) = 9, ι(4) = 8, ι(8) = 4, ι(9) = 3), so the sole failure point is the perfect fifth. ∎

**Corollary 3.9.** The bass and soprano voices in counterpoint are not interchangeable. The consonance set distinguishes a privileged voice (the bass), and the rules of counterpoint are not symmetric under voice exchange. This formalizes a well-known principle in music theory: the perfect fourth (interval 5), while acoustically consonant in isolation, is treated as a dissonance when it appears above the bass in two-voice counterpoint.

**Remark 3.10.** The asymmetry is specifically a consequence of the choice C₁₂ = {0, 3, 4, 7, 8, 9} including 7 but not 5. The complementary set ι(C₁₂) = {0, 3, 4, 5, 8, 9} differs from C₁₂ at exactly one element: 7 is replaced by 5. This minimal asymmetry is musically significant: it is the precise algebraic encoding of the rule that fourths above the bass are dissonant.

---

## 4. The Counterpoint System as a General Framework

### 4.1 Parameterization

The `CounterpointSystem n` structure is parameterized by a positive integer n (the number of pitch classes) and consists of:

```
(C : Finset (ℤ/nℤ), P : Finset (ℤ/nℤ), P ⊆ C, C.Nonempty, P.Nonempty, ∃ i ∈ C, i ∉ P)
```

This minimal axiomatization suffices to state and prove the strong connectivity theorem (Theorem 3.1) and the self-loop bottleneck (Theorem 3.5) at the parametric level. The proofs depend only on the group structure of ℤ/nℤ and the subset relationships, not on the specific values of C and P.

### 4.2 Examples Beyond 12-TET

The framework naturally accommodates microtonal tuning systems. While the choice of consonances in non-standard temperaments is less standardized, plausible systems can be defined by identifying intervals close to simple frequency ratios:

| System | n | C | P | |Hom(p,p)| | |Hom(q,q)| |
|--------|---|---|---|-----------|-----------|
| Standard 12-TET | 12 | {0,3,4,7,8,9} | {0,7} | 1 | 12 |
| 19-TET (proposed) | 19 | {0,5,6,11,13,14} | {0,11} | 1 | 19 |
| 31-TET (proposed) | 31 | {0,8,10,18,21,23} | {0,18} | 1 | 31 |

In each case, the self-loop count at perfect consonances is 1 (identity only) while imperfect consonances admit n self-loops — a universal structural feature that holds for any counterpoint system satisfying Definition 2.1.

### 4.3 Relationship to Category Theory

The original motivation was to investigate whether first-species counterpoint has a natural categorical structure. Our non-composability result (Theorem 3.3) shows that the natural candidate — permitted one-step voice leadings as morphisms — fails to form a category because morphisms do not compose.

The appropriate mathematical object is the *quiver* (directed multigraph). The free category generated by the quiver includes all composable paths of permitted voice leadings as morphisms, but the resulting category is strictly larger than the set of permitted voice leadings — it contains multi-step paths that are not individually permitted as single voice leadings. The distinction between the quiver and its free category captures the fundamentally *local* nature of counterpoint rules: each step must be checked independently, and there is no global guarantee of permissibility for composed paths.

This negative result is itself musically meaningful. It formalizes the fact that counterpoint cannot be automated by finding "safe patterns" and repeating them — a well-known principle in composition pedagogy.

---

## 5. Algorithms and Computation

### 5.1 Enumeration Algorithm

The hom-set Hom(i, j) for a counterpoint system (C, P) over ℤ/nℤ can be enumerated efficiently:

```
Input: i, j ∈ C, system (C, P, n)
Output: Set of permitted voice leadings (b, s)

For b ∈ ℤ/nℤ:
    s ← j - i + b    // unique soprano motion for target j
    if j ∈ P and b = s and b ≠ 0:
        skip          // parallel motion into perfect consonance
    else:
        yield (b, s)
```

**Complexity:** O(n) per hom-set, O(n · |C|²) for the full quiver. For the standard 12-TET system: O(12 · 36) = O(432) operations.

### 5.2 Connectivity Check

Strong connectivity follows analytically (Theorem 3.1), but can also be verified algorithmically via BFS/DFS on the enumerated quiver in O(n · |C|²) time. For the standard system, this amounts to checking that all 36 source-target pairs have at least one edge.

### 5.3 Composability Counterexample Search

To find counterexamples to composability, we enumerate all triples (i, j, k) ∈ C³ and all pairs of permitted voice leadings vl₁ ∈ Hom(i,j), vl₂ ∈ Hom(j,k), checking whether the composite vl₂ ∘ vl₁ is permitted from i to k. The worst-case complexity is O(n² · |C|³) — for the standard system, O(144 · 216) ≈ 31,000 operations. Exhaustive search reveals exactly 1,320 counterexample triples.

---

## 6. Discussion

### 6.1 Structural Interpretation of the Hom-Set Matrix

The full hom-set cardinality matrix |Hom(i, j)| of the standard 12-TET counterpoint quiver exhibits a striking pattern:

|  | P1 | m3 | M3 | P5 | m6 | M6 | Row Σ |
|--|----|----|----|----|----|----|-------|
| **P1** | 1 | 12 | 12 | 12 | 12 | 12 | 61 |
| **m3** | 12 | 12 | 12 | 12 | 12 | 12 | 72 |
| **M3** | 12 | 12 | 12 | 12 | 12 | 12 | 72 |
| **P5** | 12 | 12 | 12 | 1 | 12 | 12 | 61 |
| **m6** | 12 | 12 | 12 | 12 | 12 | 12 | 72 |
| **M6** | 12 | 12 | 12 | 12 | 12 | 12 | 72 |

The matrix is almost completely uniform (all entries 12), with exactly two exceptional entries: Hom(P1, P1) = 1 and Hom(P5, P5) = 1. These correspond to the self-loops at perfect consonances. The total number of edges is 410 = 432 − 22, where 432 = 6² × 12 is the unconstrained count and 22 = 2 × 11 represents the 11 forbidden parallel motions at each of the 2 perfect consonances.

This near-uniformity has a structural explanation: the parallel-motion restriction is a *rank-2 perturbation* of the complete quiver. In matrix terms, if U is the 6×6 all-12s matrix and E is the matrix with −11 at positions (P1,P1) and (P5,P5) and 0 elsewhere, then the hom-set matrix is U + E. This algebraic perspective suggests that the counterpoint constraint is, in a precise sense, a minimal deviation from maximal symmetry.

### 6.2 The Quiver as a Weighted Directed Graph

The hom-set cardinalities naturally equip the counterpoint quiver with edge weights. From this perspective, the quiver becomes a weighted directed graph where the weight w(i,j) = |Hom(i,j)| represents the "freedom" or "variety" of voice leadings available for the transition i → j. Random walks on this weighted graph model a naive compositional process where each transition is chosen uniformly at random from permitted voice leadings.

The stationary distribution of this random walk is proportional to the incoming edge weight of each vertex. Since perfect consonances receive weight 61 and imperfect consonances receive weight 72, the stationary probability of being at a perfect consonance is 61/(2×61 + 4×72) = 61/410 ≈ 0.149, while imperfect consonances have probability 72/410 ≈ 0.176 each. In a random counterpoint composition, imperfect consonances are approximately 18% more likely to appear than perfect ones — a quantitative prediction of the statistical properties of randomly generated counterpoint.

### 6.3 Musical Implications

The quantitative bottleneck at perfect consonances (Theorem 3.6) provides a mathematical explanation for the pedagogical emphasis on careful treatment of perfect consonances. Composition students are instructed to "prepare" perfect consonances and to approach them by contrary or oblique motion — our results show that this is not merely stylistic preference but a reflection of a genuine combinatorial constraint: there are strictly fewer ways to reach a perfect consonance.

The non-composability result (Theorem 3.3) captures a musical reality: counterpoint must be checked beat by beat. There is no "safe trajectory" that can be verified once and then mechanically extended. This aligns with the compositional practice of examining each pair of consecutive vertical sonorities independently.

The voice-swap asymmetry (Theorem 3.8) explains a subtlety that puzzles many music students: why is the perfect fourth "dissonant" when it's simply an inverted perfect fifth? Our framework answers this precisely — the consonance set is defined from the perspective of the bass voice, and the algebraic operation of inversion (ι(i) = −i mod 12) does not preserve this set.

### 6.4 Relationship to Prior Work

Our approach complements Tymoczko's voice-leading geometry [Tymoczko 2011], which models the space of all voice leadings (not just permitted ones) as a continuous orbifold. Where Tymoczko's framework excels at measuring *distance* between voice leadings, ours excels at capturing *permissibility* — the combinatorial structure of which voice leadings are allowed. The two perspectives are not contradictory: distance captures smooth preference, while our quiver captures hard constraints.

Mazzola's *counterpoint theorem* [Mazzola 2002] uses deformation theory to characterize consonance sets as specific subsets of ℤ/12ℤ that admit a "counterpoint symmetry." Our framework is more elementary but yields precise quantitative results about the directed graph structure. The relationship between Mazzola's symmetry conditions and our quiver structure is an interesting open question.

### 6.5 Connections to Algebraic Topology

The counterpoint quiver has a well-defined *path algebra* over any field k: the k-algebra generated by all paths in the quiver, modulo the mesh relations. Since the quiver is finite and strongly connected, its path algebra is infinite-dimensional (there are arbitrarily long paths). The representation theory of this quiver — the study of quiver representations, i.e., functors from the free category of the quiver to the category of vector spaces — could yield invariants of the voice-leading structure that are not visible from the graph-theoretic perspective alone.

The *simplicial nerve* of the quiver's free category provides a simplicial set whose geometric realization is a topological space encoding the "shape" of voice-leading space. Since the quiver is strongly connected, this space is connected. The non-composability result suggests that the nerve has non-trivial higher structure: the distinction between permitted and forbidden compositions creates "holes" in the simplicial complex that would be reflected in non-trivial path homology groups.

### 6.6 Limitations

Our formalization captures only first-species counterpoint (note-against-note). Higher species involve passing tones, suspensions, and rhythmic subdivision, requiring a richer temporal model. The extension to three or more voices introduces additional constraints (e.g., the prohibition on parallel fifths applies to every pair of voices), leading to a quiver over a higher-dimensional consonance space C^(k choose 2).

Additionally, our model treats all voice leadings of a given type as equivalent — it does not distinguish between small and large motions (e.g., moving by 1 semitone versus 11 semitones). A refined model incorporating distance preferences would yield a weighted quiver with non-uniform edge weights within each Hom-set.

---

## 7. Future Work

1. **Higher species.** Extend the framework to second through fifth species counterpoint, modeling suspensions and passing tones as additional edge types or as a labelled quiver.
2. **Multi-voice counterpoint.** Generalize to k-voice counterpoint, where the state space is C^(k choose 2) and the constraint graph grows combinatorially. For k = 3 voices and 6 consonances, the vertex set has up to 6³ = 216 elements.
3. **Microtonal counterpoint.** Use the parametric framework to define and study counterpoint rules for 19-TET, 31-TET, and other equal temperaments. Investigate whether the structural theorems (connectivity, bottleneck, non-composability) hold universally or depend on specific properties of the consonance set.
4. **Path homology.** Compute the path homology groups of the counterpoint quiver. These homological invariants could capture structural features of voice-leading spaces not visible from the graph-theoretic perspective.
5. **Algorithmic composition.** Use the quiver structure to generate counterpoint algorithmically via random walks or constrained optimization on the graph. The stationary distribution analysis in Section 6.2 provides a baseline model.
6. **Connection to Pythagorean harmony.** Integrate with the Pythagorean-triple characterization of consonance to derive the consonance set C₁₂ from first principles (acoustic/number-theoretic) rather than treating it as given.
7. **Spectral analysis.** Study the spectrum of the adjacency matrix (or weighted Laplacian) of the counterpoint quiver. The near-uniform structure (rank-2 perturbation of the complete graph) suggests that spectral methods could yield clean closed-form results.

---

## 8. Computational Verification

All results have been verified computationally by exhaustive enumeration over the finite quiver (6 vertices × 144 voice leadings per pair = 5,184 total checks). The Python demonstration code independently confirms:

- The quiver has exactly **410 edges** (of 432 possible).
- All 36 source-target pairs have at least one permitted voice leading (**strong connectivity**).
- There are exactly **1,320 counterexample triples** demonstrating non-composability.
- Self-loop counts are exactly **1** for P1 and P5, and exactly **12** for m3, M3, m6, M6.
- Column sums of the hom-set matrix are **61** for P1 and P5, and **72** for m3, M3, m6, M6.
- The involution ι sends {0, 3, 4, 7, 8, 9} to {0, 9, 8, 5, 4, 3}, which differs at position **7 → 5**.

The formal proofs in the Lean 4 formalization establish these results with mathematical certainty, independent of the computational verification. The two approaches — formal proof and exhaustive computation — serve as mutual validation.

---

## 9. Conclusion

We have introduced a parametric algebraic framework — the *Counterpoint System* — that captures the constraint structure of first-species counterpoint as a directed multigraph over modular arithmetic. The five main theorems reveal that the counterpoint quiver is strongly connected but non-categorical, with a precise quantitative bottleneck at perfect consonances and a fundamental asymmetry under voice exchange.

The near-uniform structure of the hom-set matrix — a rank-2 perturbation of maximal symmetry — suggests that the counterpoint rules represent a *minimal* constraint: the smallest modification of the "anything goes" quiver that enforces the privileged status of perfect consonances. This minimality may explain the enduring pedagogical and aesthetic appeal of Fux's rules.

These results formalize longstanding musical intuitions in a rigorous mathematical setting and open new directions connecting music theory, combinatorics, and categorical algebra. The parametric framework invites systematic exploration of counterpoint-like constraints in arbitrary equal temperaments, potentially uncovering universal structural features of voice-leading systems.

---

## References

- Cohn, R. (1998). Introduction to neo-Riemannian theory: A survey and a historical perspective. *Journal of Music Theory*, 42(2), 167–180.
- Fux, J.J. (1725). *Gradus ad Parnassum*. Vienna.
- Mazzola, G. (2002). *The Topos of Music: Geometric Logic of Concepts, Theory, and Performance*. Birkhäuser.
- Tymoczko, D. (2011). *A Geometry of Music: Harmony and Counterpoint in the Extended Common Practice*. Oxford University Press.

---

## Appendix A: Catalog of Results

| Result | Type | Statement |
|--------|------|-----------|
| `exists_permitted_voice_leading` | Theorem | ∀ i j ∈ C₁₂, ∃ permitted voice leading i → j |
| `non_composability` | Theorem | ∃ composable permitted pair whose composite is not permitted |
| `perfect_self_loop_unique` | Theorem | \|Hom(p,p)\| = 1 for p ∈ P₁₂ |
| `imperfect_self_loops_all` | Theorem | \|Hom(q,q)\| = 12 for q ∈ C₁₂ \ P₁₂ |
| `total_permitted_to_perfect` | Theorem | Σᵢ \|Hom(i,p)\| = 61 for p ∈ P₁₂ |
| `total_permitted_to_imperfect` | Theorem | Σᵢ \|Hom(i,q)\| = 72 for q ∈ C₁₂ \ P₁₂ |
| `voice_swap_breaks_consonance` | Theorem | ι(C₁₂) ≠ C₁₂ (voice exchange breaks consonance) |
| `targetInterval_canonical` | Theorem | τ(i, κ(i,j)) = j |
| `canonical_not_parallel` | Theorem | i ≠ j → κ(i,j) is not parallel |
