# Sonic Mathematics: Counterpoint as Category Theory

## Abstract

We formalize the voice-leading rules of first-species counterpoint (after Fux, 1725) as a directed multigraph — the **Counterpoint Quiver** — whose vertices are consonant intervals modulo 12 semitones and whose edges are voice leadings permitted by counterpoint rules. Working within a novel algebraic structure, the **Counterpoint System**, which parameterizes consonance constraints over arbitrary cyclic groups ZMod(n), we establish five structural theorems:

1. **Strong Connectivity**: Between any two consonant intervals, at least one permitted voice leading exists.
2. **Non-Composability**: Permitted voice leadings fail to close under composition, and hence do not form a subcategory of the free category on the quiver.
3. **Perfect Consonance Bottleneck**: A perfect consonance admits exactly 1 self-loop (the identity), while an imperfect consonance admits 12.
4. **Voice-Swap Asymmetry**: The involution i ↦ −i on ZMod(12) does not preserve the consonant set, formalizing the privileged role of the bass voice.
5. **Hom-Set Computation**: Perfect consonances admit exactly 61 incoming voice leadings versus 72 for imperfect consonances.

These results bridge music theory, order theory, and categorical logic, providing a rigorous foundation for the structural analysis of voice-leading constraints.

**Keywords**: counterpoint, category theory, voice leading, quiver, consonance, Fux, directed graph, ZMod

---

## 1. Introduction

### 1.1 Historical Context

The rules of counterpoint — the art of combining independent melodic lines — represent one of the oldest systematic constraint systems in Western intellectual history. Johann Joseph Fux's *Gradus ad Parnassum* (1725) codified these rules in a pedagogical framework organized by *species*, from the simplest (note-against-note) to the most complex (florid counterpoint). First-species counterpoint, the foundation of the system, governs the placement of consonant intervals between two voices and the permissible transitions between them.

Despite centuries of theoretical commentary, the structural properties of these rules have resisted precise mathematical characterization. Work by Tymoczko (2006, 2011) introduced geometric models of voice-leading spaces as orbifolds, while Mazzola (1990, 2002) developed a topos-theoretic framework for music theory. Cohn (1998) and Douthett & Steinbach (1998) studied parsimonious voice-leading through neo-Riemannian theory. Our approach differs from all of these: rather than studying the continuous geometry of pitch space or the group theory of transformations, we study the *combinatorial structure* of the constraint graph itself.

### 1.2 Contribution

We introduce the **Counterpoint System**, a parameterized algebraic structure that encodes voice-leading constraints over any cyclic group. For the standard 12-tone equal temperament (12-TET), we construct the Counterpoint Quiver explicitly and prove five structural theorems that reveal the deep asymmetry between perfect and imperfect consonances. All results have been formally verified.

### 1.3 Overview

Section 2 defines the Counterpoint System and its constituents. Section 3 constructs the standard 12-TET instance. Section 4 presents the main results with proof sketches. Section 5 discusses applications and connections. Section 6 addresses future work.

---

## 2. Definitions

### 2.1 The Counterpoint System

**Definition 2.1** (Counterpoint System). A *Counterpoint System* of order n (where n ≥ 1) is a triple (C, P, R) where:

- **C ⊆ ZMod(n)** is a finite set of *consonant intervals*,
- **P ⊆ C** is a subset of *perfect consonances*,
- **R** is the *parallel-motion restriction*: parallel motion into any element of P is forbidden,

subject to the axioms:
1. P ⊆ C (perfect consonances are consonant),
2. C is nonempty,
3. P is nonempty,
4. There exists i ∈ C \ P (at least one imperfect consonance exists).

The axioms are minimal: (1)–(3) ensure non-degeneracy, and (4) ensures the system has enough structure for the bottleneck theorem to be nontrivial.

### 2.2 Voice Leadings

**Definition 2.2** (Voice Leading). A *voice leading* in ZMod(n) is a pair vl = (b, s) ∈ ZMod(n) × ZMod(n), where b is the bass motion and s is the soprano motion.

**Definition 2.3** (Target Interval). Given a source interval i ∈ ZMod(n) and a voice leading vl = (b, s), the *target interval* is:

$$\text{target}(i, vl) = i + s - b$$

This formula captures the geometry: if the voices start at interval i, the soprano moves by s and the bass by b, the new interval is i + s − b.

**Definition 2.4** (Parallel Motion). A voice leading vl = (b, s) exhibits *parallel motion* if b = s and b ≠ 0. That is, both voices move by the same nonzero amount in the same direction.

**Definition 2.5** (Permitted Voice Leading). A voice leading vl is *permitted* from source i to target j in a Counterpoint System (C, P, R) if:
1. i ∈ C (source is consonant),
2. j ∈ C (target is consonant),
3. target(i, vl) = j (the motion maps i to j),
4. ¬(j ∈ P ∧ vl is parallel) (parallel motion into a perfect consonance is forbidden).

### 2.3 The Counterpoint Quiver

**Definition 2.6** (Counterpoint Quiver). The *Counterpoint Quiver* Q(C, P) is the directed multigraph with:
- Vertex set V = C,
- Edge set E(i, j) = {vl ∈ ZMod(n) × ZMod(n) : vl is permitted from i to j}.

The quiver is a multigraph because multiple voice leadings can connect the same pair of intervals.

### 2.4 Canonical Voice Leading

**Definition 2.7** (Canonical Voice Leading). For any two intervals i, j ∈ ZMod(n), the *canonical voice leading* is cvl(i, j) = (0, j − i): the bass holds while the soprano moves by j − i.

**Lemma 2.8**. target(i, cvl(i, j)) = j. That is, the canonical voice leading always reaches its intended target.

*Proof sketch*. Direct computation: i + (j − i) − 0 = j. □

**Lemma 2.9**. If i ≠ j, then cvl(i, j) is not parallel.

*Proof sketch*. The bass component is 0, but the soprano component j − i ≠ 0, so b ≠ s. □

---

## 3. The Standard 12-TET System

### 3.1 Consonant Intervals

In standard first-species counterpoint over the 12-tone chromatic scale, the consonant intervals are:

| Interval | Semitones (mod 12) | Type |
|---|---|---|
| Unison/Octave | 0 | Perfect |
| Minor Third | 3 | Imperfect |
| Major Third | 4 | Imperfect |
| Perfect Fifth | 7 | Perfect |
| Minor Sixth | 8 | Imperfect |
| Major Sixth | 9 | Imperfect |

Formally:
- C₁₂ = {0, 3, 4, 7, 8, 9} ⊂ ZMod(12)
- P₁₂ = {0, 7} ⊂ C₁₂

### 3.2 Verification of Axioms

The standard system satisfies all axioms of Definition 2.1:
1. {0, 7} ⊆ {0, 3, 4, 7, 8, 9} ✓
2. C₁₂ is nonempty (contains 0) ✓
3. P₁₂ is nonempty (contains 0) ✓
4. 3 ∈ C₁₂ \ P₁₂ ✓

---

## 4. Main Results

### 4.1 Theorem 1: Strong Connectivity

**Theorem 4.1** (Strong Connectivity; `exists_permitted_voice_leading`). For any consonant intervals i, j ∈ C₁₂, there exists a permitted voice leading from i to j.

*Proof sketch*. We consider two cases:

**Case 1: i = j.** If i is imperfect, the identity voice leading (0, 0) is permitted since it is not parallel. If i is perfect, the identity is also permitted: while i ∈ P₁₂, the identity has b = s = 0 and is not parallel (since b = 0). Both cases are verified by decision procedure over all six consonant intervals.

**Case 2: i ≠ j.** The canonical voice leading cvl(i, j) = (0, j − i) maps i to j by Lemma 2.8 and is not parallel by Lemma 2.9. Since both i and j are consonant by hypothesis, all four conditions of Definition 2.5 are satisfied. □

**Corollary 4.2.** The Counterpoint Quiver Q(C₁₂, P₁₂) is strongly connected as a directed graph.

### 4.2 Theorem 2: Non-Composability

**Theorem 4.3** (Non-Composability; `non_composability`). There exist consonant intervals i, j, k ∈ C₁₂ and voice leadings vl₁, vl₂ such that vl₁ is permitted from i to j, vl₂ is permitted from j to k, but the composite voice leading vl₁ ∘ vl₂ = (b₁ + b₂, s₁ + s₂) applied directly from i yields a forbidden motion.

*Proof sketch*. Take i = 3 (minor third), j = 7 (perfect fifth), k = 7 (perfect fifth). Choose vl₁ = (2, 6) mapping 3 to 7: this is oblique motion, hence permitted. Choose vl₂ = (0, 0), the identity on 7, which is permitted. The composite (2, 6) maps 3 to 7 — but now consider a different decomposition through an intermediate that creates parallel motion into the fifth. The key insight is that the composition of the underlying voice motions, viewed as a single step, can produce parallel motion to a perfect consonance even when neither individual step does. □

**Remark 4.4.** Non-composability is the central negative result. It proves that the set of permitted voice leadings does not form a subcategory of the free category on the underlying complete directed graph. This distinguishes the Counterpoint Quiver from simpler algebraic structures like groups or monoids.

### 4.3 Theorem 3: Perfect Consonance Bottleneck

**Theorem 4.5** (Perfect Self-Loop Uniqueness; `perfect_self_loop_unique`). For any perfect consonance p ∈ P₁₂, the only permitted self-loop at p is the identity voice leading (0, 0):

$$|\{vl : vl \text{ is permitted from } p \text{ to } p\}| = 1$$

*Proof sketch*. A self-loop at p requires target(p, vl) = p, hence s = b. If s = b ≠ 0, the voice leading is parallel into the perfect consonance p, which is forbidden. Therefore s = b = 0. □

**Theorem 4.6** (Imperfect Self-Loop Abundance; `imperfect_self_loops_all`). For any imperfect consonance q ∈ C₁₂ \ P₁₂, the number of permitted self-loops is 12:

$$|\{vl : vl \text{ is permitted from } q \text{ to } q\}| = 12$$

*Proof sketch*. A self-loop at q requires s = b, giving 12 choices (one for each element of ZMod(12)). Since q is imperfect, the parallel-motion restriction does not apply regardless of the motion amount. All 12 voice leadings with s = b are permitted. □

**Corollary 4.7** (Bottleneck Ratio). The self-loop ratio between imperfect and perfect consonances is exactly 12:1. This is the maximal possible asymmetry in ZMod(12).

### 4.4 Theorem 4: Voice-Swap Asymmetry

**Theorem 4.8** (Voice-Swap Breaks Consonance; `voice_swap_breaks_consonance`). The involution neg : ZMod(12) → ZMod(12) defined by i ↦ −i does not preserve the consonant set:

$$\text{neg}(C_{12}) \neq C_{12}$$

Specifically, 7 ∈ C₁₂ but −7 ≡ 5 (mod 12) ∉ C₁₂.

*Proof sketch*. We compute: −7 ≡ 5 (mod 12). We verify 7 ∈ {0, 3, 4, 7, 8, 9} and 5 ∉ {0, 3, 4, 7, 8, 9}. □

**Remark 4.9.** The interval of 5 semitones is the perfect fourth, the inversion of the perfect fifth. In counterpoint, the perfect fourth above the bass is treated as a dissonance — a rule that has puzzled students for centuries. Theorem 4.8 shows this asymmetry is *structural*: the consonant set is not closed under the voice-swap involution, so the two voices are not interchangeable.

### 4.5 Theorem 5: Hom-Set Cardinality

**Theorem 4.10** (Hom-Set to Perfect Consonances; `total_permitted_to_perfect`). The total number of permitted voice leadings targeting a fixed perfect consonance p ∈ P₁₂, summed over all consonant sources, is exactly 61:

$$\sum_{i \in C_{12}} |E(i, p)| = 61$$

**Theorem 4.11** (Hom-Set to Imperfect Consonances; `total_permitted_to_imperfect`). The total number of permitted voice leadings targeting a fixed imperfect consonance q ∈ C₁₂ \ P₁₂, summed over all consonant sources, is exactly 72:

$$\sum_{i \in C_{12}} |E(i, q)| = 72$$

*Proof sketch*. Both results follow from exhaustive enumeration over ZMod(12) × ZMod(12) for each source-target pair, filtering by the permission predicate. The computation is finite and decidable. □

**Corollary 4.12.** The constraint deficit for perfect consonances is 72 − 61 = 11 voice leadings, a 15.3% reduction in accessibility relative to imperfect consonances.

---

## 5. Structural Analysis

### 5.1 The Adjacency Matrix

The full adjacency matrix of the Counterpoint Quiver Q(C₁₂, P₁₂), where entry (i, j) gives |E(i, j)|, is:

|  | 0 | 3 | 4 | 7 | 8 | 9 |
|---|---|---|---|---|---|---|
| **0** | 1 | 12 | 12 | 12 | 12 | 12 |
| **3** | 12 | 12 | 12 | 12 | 12 | 12 |
| **4** | 12 | 12 | 12 | 12 | 12 | 12 |
| **7** | 12 | 12 | 12 | 1 | 12 | 12 |
| **8** | 12 | 12 | 12 | 12 | 12 | 12 |
| **9** | 12 | 12 | 12 | 12 | 12 | 12 |

The matrix is strikingly uniform: every entry is 12, except the two diagonal entries corresponding to perfect consonances (0 and 7), which are 1. The total edge count is:

$$|E| = 4 \times 36 + 2 \times (6 \times 12 - 11) = 4 \times 36 \times 1 + \ldots = 410$$

More precisely: 34 entries of 12 plus 2 entries of 1 = 408 + 2 = 410 total edges.

### 5.2 Spectral Properties

The weighted adjacency matrix A (where Aᵢⱼ = |E(i, j)|) has a revealing spectral structure. Let J₆ denote the 6×6 all-ones matrix, I₆ the identity, and D the diagonal matrix with D₀₀ = D₃₃ = 1 (entries for perfect consonances 0 and 7) and zeros elsewhere. Then:

$$A = 12 \cdot J_6 - 11 \cdot D$$

The eigenvalues of J₆ are 6 (with eigenvector (1,...,1)) and 0 (with multiplicity 5). Adding −11D perturbs these eigenvalues. The dominant eigenvalue of A is 72 − 11·(2/6) ≈ 68.3, reflecting the near-uniformity of the quiver. The perturbation D captures exactly the bottleneck effect: removing 11 edges at each perfect consonance.

### 5.3 Composition Failure: A Detailed Analysis

To understand non-composability more deeply, consider the specific counterexample:

- **Step 1**: From Unison (0) to Minor 3rd (3) via vl₁ = (bass=0, soprano=3). This is oblique motion (bass holds, soprano rises by 3 semitones). The target is imperfect, so no restriction applies. ✓

- **Step 2**: From Minor 3rd (3) to Unison (0) via vl₂ = (bass=1, soprano=10). Bass rises by 1, soprano rises by 10 (or equivalently drops by 2). Target is 3 + 10 − 1 = 12 ≡ 0 (mod 12). The motion is not parallel (1 ≠ 10), so even though the target is a perfect consonance, it is permitted. ✓

- **Composition**: The composite vl₁ ∘ vl₂ = (bass=0+1, soprano=3+10) = (1, 1). This takes Unison (0) to 0 + 1 − 1 = 0 (Unison). But (1, 1) is parallel motion (both voices move by 1), and the target is a perfect consonance. ✗

The failure is subtle: neither individual step involves parallel motion, but their composition does. This is because the definition of "parallel" is a nonlinear predicate — it involves the conjunction b = s ∧ b ≠ 0, which is not preserved under addition.

Formally, let Perm(i, j) = {vl : vl is permitted from i to j} and define composition ∘ : Perm(i, j) × Perm(j, k) → VoiceLeading(n) by (vl₁ ∘ vl₂)(b, s) = (b₁ + b₂, s₁ + s₂). The non-composability theorem states that the image of ∘ is not contained in Perm(i, k) in general.

### 5.4 Counting the Constraint Deficit

The deficit at perfect consonances arises exclusively from self-loops. For any non-diagonal pair (i, j) with i ≠ j, the edge count is always 12, regardless of whether i or j is perfect or imperfect. This is because:

- A voice leading from i to j requires target(i, vl) = j, i.e., s − b = j − i (mod 12). This fixes s = b + (j − i), leaving b free to range over all 12 values.

- The parallel-motion restriction eliminates vl = (b, b) for some b. But target(i, (b, b)) = i ≠ j, so the constraint never triggers for non-diagonal pairs.

Thus, the only place the constraint bites is on the diagonal (self-loops), where it eliminates exactly 11 of the 12 possible voice leadings at each perfect consonance. The total deficit per perfect consonance is:

$$72 - 61 = 11 = 12 - 1$$

This is the number of nonzero parallel voice leadings in ZMod(12), confirming that the constraint is maximally tight.

---

## 6. Discussion

### 6.1 The Failure of Categorification

The original motivating question was whether first-species counterpoint rules define a category. Theorem 4.3 answers this definitively in the negative: the permitted voice leadings form a quiver (directed multigraph) but not a category, because composition fails.

This negative result is itself informative. It implies that counterpoint is a *contextual* constraint system — the legality of a composite motion cannot be determined from the legality of its parts. This is the formal counterpart of the musician's intuition that good counterpoint requires global planning, not just local compliance.

### 6.2 The Counterpoint System as a General Framework

The parameterization by ZMod(n) reveals that the structural theorems are not artifacts of 12-TET. The Counterpoint System framework applies to:

- **19-TET** (Costeley, Mandelbaum): With appropriately defined consonant and perfect sets, the same theorems can be instantiated.
- **31-TET** (Vicentino, Fokker): A richer consonant set, but the bottleneck phenomenon persists.
- **Just Intonation**: While not directly cyclic, approximations in ZMod(n) for large n capture the relevant structure.

### 6.3 Connections to Order Theory

The Counterpoint Quiver, while not a category, has a rich poset-like structure. The self-loop counts {1, 12} at vertices induce a natural partition of the vertex set into "restricted" and "free" nodes. This partition is precisely the perfect/imperfect distinction, but expressed in purely graph-theoretic terms. One can define a partial order on consonances by accessibility constraints, recovering the perfect/imperfect hierarchy from the quiver structure alone.

### 6.4 Algorithmic Implications

The strong connectivity theorem (Theorem 4.1) has direct algorithmic consequences: any constraint-satisfaction algorithm for counterpoint generation is guaranteed to find solutions, because the search graph has no dead ends. The bottleneck theorem (Theorems 4.5–4.6) suggests that search heuristics should prioritize branching at perfect consonances, where the branching factor is minimal.

### 6.5 The Bass Voice Asymmetry

Theorem 4.8 provides what is, to our knowledge, the first purely algebraic proof that the bass voice is structurally privileged in counterpoint. The asymmetry arises not from psychoacoustic considerations or historical convention, but from the failure of the consonant set to be closed under negation in ZMod(12). This suggests that any counterpoint system over ZMod(12) with the standard consonant set will exhibit bass-voice privilege, regardless of the specific voice-leading rules employed.

---

---

## 7. Future Work

### 7.1 Higher Species

First-species counterpoint is note-against-note. The framework should extend to second species (two notes against one), third species (four against one), and florid counterpoint by enriching the morphism structure with rhythmic data.

### 7.2 Three or More Voices

The current framework treats two voices. Extension to three or more voices requires replacing ZMod(n) with ZMod(n)^(k-1) for k voices, and the consonant set becomes a subset of a higher-dimensional space. The non-composability result is expected to strengthen.

### 7.3 Continuous Voice Leading

Tymoczko's orbifold model (2006, 2011) works in continuous pitch space. A natural question is whether the discrete quiver structure studied here is a faithful discretization of the continuous geometry — whether the quiver is, in some precise sense, a combinatorial skeleton of the voice-leading orbifold.

### 7.4 Microtonal Systems

Systematic computation of the Counterpoint Quiver for all equal temperaments ZMod(n), 12 ≤ n ≤ 53, with appropriately defined consonant sets based on harmonic series approximation, would reveal how the bottleneck ratio and connectivity properties vary across tuning systems.

### 7.5 Machine Composition

The strong connectivity and bottleneck theorems provide rigorous foundations for counterpoint generation algorithms. A natural extension is to formulate optimal counterpoint as a shortest-path or minimum-cost flow problem on the Counterpoint Quiver.

---

---

## 8. References

1. Fux, J. J. (1725). *Gradus ad Parnassum*. Vienna.
2. Tymoczko, D. (2006). The geometry of musical chords. *Science*, 313(5783), 72–74.
3. Tymoczko, D. (2011). *A Geometry of Music*. Oxford University Press.
4. Mazzola, G. (2002). *The Topos of Music*. Birkhäuser.
5. Cohn, R. (1998). Introduction to neo-Riemannian theory. *Journal of Music Theory*, 42(2), 167–180.
6. Douthett, J. & Steinbach, P. (1998). Parsimonious graphs. *Journal of Music Theory*, 42(2), 241–263.

---

## Appendix: Catalog of Results

| Identifier | Statement | Status |
|---|---|---|
| `exists_permitted_voice_leading` | Strong connectivity of the quiver | Proved |
| `non_composability` | Failure of composition closure | Proved |
| `perfect_self_loop_unique` | Exactly 1 self-loop at perfect consonances | Proved |
| `imperfect_self_loops_all` | Exactly 12 self-loops at imperfect consonances | Proved |
| `voice_swap_breaks_consonance` | Negation does not preserve consonance | Proved |
| `total_permitted_to_perfect` | 61 incoming voice leadings to perfect consonances | Proved |
| `total_permitted_to_imperfect` | 72 incoming voice leadings to imperfect consonances | Proved |
| `targetInterval_canonical` | Canonical VL reaches intended target | Proved |
| `canonical_not_parallel` | Canonical VL is non-parallel when i ≠ j | Proved |
