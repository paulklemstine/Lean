# Sonic Mathematics: Counterpoint as Category Theory

## Formalizing Voice-Leading Constraints via Quiver Theory and Lattice-Valued Cost Functions

---

### Abstract

We present a mathematical framework that formalizes first-species counterpoint — the oldest and most fundamental system of Western polyphonic composition rules — using directed multigraphs (quivers), modular arithmetic over cyclic groups, and lattice-valued cost functions. Our central construction is the **Counterpoint System**, a parameterized algebraic structure over ℤ/nℤ that captures the constraint logic of voice leading for arbitrary n-tone equal temperaments. We prove five structural theorems about the standard 12-TET instantiation: (1) strong connectivity of the counterpoint quiver, (2) non-composability of permitted voice leadings, (3) a quantitative bottleneck at perfect consonances (1 vs. 12 self-loops), (4) asymmetry of the consonance set under voice exchange, and (5) precise hom-set cardinalities (61 vs. 72 incoming arrows). In a complementary direction, we establish that the voice-leading cost function — the L¹ norm on voice-motion vectors — is a seminorm satisfying a lattice-cost conservation identity. All results are machine-verified. These results bridge music theory, combinatorics on cyclic groups, and categorical logic, and suggest new directions in computational musicology and constraint-satisfaction theory.

**Keywords**: counterpoint, voice leading, quiver, category theory, modular arithmetic, lattice theory, seminorm, constraint satisfaction, music theory formalization

---

### 1. Introduction

The rules of first-species counterpoint, as codified by Johann Joseph Fux (1725), govern the simultaneous motion of two or more voices constrained to produce consonant intervals at each beat. Despite their antiquity, these rules have resisted satisfactory mathematical formalization. Previous approaches include Mazzola's topos-theoretic framework (2002), Tymoczko's geometric voice-leading spaces (2006, 2011), and Fiore and Satyendra's transformational theory (2005). While each offers valuable insights, none directly addresses the *combinatorial constraint structure* of counterpoint — the precise enumeration of permitted transitions and their algebraic (non-)closure properties.

We take a different approach. We model consonant intervals as vertices of a directed multigraph (quiver) over ℤ/nℤ and voice leadings as edges. The counterpoint rules — particularly the prohibition of parallel motion into perfect consonances — become edge-existence predicates. This shifts the analysis from continuous geometry to discrete combinatorics and allows machine-verified enumeration of the complete transition structure.

Our main contributions are:

1. The **CounterpointSystem** structure (Definition 2.1), parameterizing counterpoint-like constraints over arbitrary ℤ/nℤ.
2. Five structural theorems about the standard 12-TET system (Section 4).
3. A **voice-leading cost function** with seminorm and lattice-conservation properties (Section 5).
4. Connections to constraint-satisfaction theory and computational musicology (Section 6).

---

### 2. Definitions and Notation

#### 2.1. The Counterpoint System

**Definition 2.1** (CounterpointSystem). For n ∈ ℕ with n ≥ 1, a *counterpoint system over ℤ/nℤ* is a tuple (C, P, ⊆, ∃imp) where:

- **C** ⊆ ℤ/nℤ is a finite set of *consonant intervals*,
- **P** ⊆ C is a subset of *perfect consonances*,
- P ⊆ C (perfect consonances are consonant),
- C is nonempty,
- P is nonempty,
- there exists i ∈ C \ P (at least one imperfect consonance exists).

This structure is novel: it abstracts the essential features of any counterpoint-like constraint system without committing to a specific tuning. It applies equally to 12-TET, 19-TET, 31-TET, or any other equal temperament.

#### 2.2. Voice Leadings

**Definition 2.2** (VoiceLeading). A *voice leading* over ℤ/nℤ is a pair (b, s) ∈ ℤ/nℤ × ℤ/nℤ, where b is the bass motion and s is the soprano motion (both in semitones mod n).

**Definition 2.3** (Target interval). Given source interval i ∈ ℤ/nℤ and voice leading (b, s), the *target interval* is:

$$\tau(i, b, s) = i + s - b$$

**Definition 2.4** (Parallel motion). A voice leading (b, s) is *parallel* if b = s and b ≠ 0.

#### 2.3. Permitted Voice Leadings

**Definition 2.5** (Permitted voice leading). A voice leading (b, s) from source interval i to target interval j is *permitted* in a counterpoint system (C, P) if:

1. i ∈ C (source is consonant),
2. j ∈ C (target is consonant),
3. τ(i, b, s) = j (the voice leading maps source to target),
4. ¬(j ∈ P ∧ (b, s) is parallel) (parallel motion into perfect consonances is forbidden).

#### 2.4. The Standard 12-TET System

**Definition 2.6**. The *standard 12-TET counterpoint system* is (C₁₂, P₁₂) where:

- C₁₂ = {0, 3, 4, 7, 8, 9} ⊂ ℤ/12ℤ (unison, minor third, major third, perfect fifth, minor sixth, major sixth),
- P₁₂ = {0, 7} ⊂ ℤ/12ℤ (unison/octave, perfect fifth).

---

### 3. The Counterpoint Quiver

**Definition 3.1** (Counterpoint quiver). The *counterpoint quiver* Q(C, P) of a counterpoint system (C, P) over ℤ/nℤ has:

- **Vertices**: V = C
- **Edges**: E(i, j) = {(b, s) ∈ ℤ/nℤ × ℤ/nℤ : (b, s) is permitted from i to j}

For the standard 12-TET system, V has 6 vertices and the total edge set has cardinality to be determined by our theorems.

The key question — whether Q forms a *category* (i.e., whether edges compose) — is answered negatively in Theorem 4.2.

---

### 4. Main Results

#### 4.1. Strong Connectivity

**Theorem 4.1** (exists_permitted_voice_leading). *For any two consonant intervals i, j ∈ C₁₂, there exists a permitted voice leading from i to j in the standard 12-TET system.*

*Proof sketch.* We distinguish two cases:

- **Case i = j**: For each of the six consonant intervals, we exhibit a specific permitted self-loop. For imperfect consonances, any non-parallel voice leading works. For perfect consonances, the identity voice leading (0, 0) is always permitted.

- **Case i ≠ j**: The *canonical voice leading* (0, j − i) — bass holds, soprano moves — always works. Since bass motion is 0 and soprano motion is j − i ≠ 0, the motion is not parallel (parallel requires b = s ≠ 0, but b = 0). Hence the parallel-consonance restriction cannot trigger. ∎

**Corollary.** The counterpoint quiver Q(C₁₂, P₁₂) is strongly connected as a directed graph.

#### 4.2. Non-Composability

**Theorem 4.2** (non_composability). *The set of permitted one-step voice leadings in the standard 12-TET system is not closed under composition. That is, there exist consonant intervals i, j, k and permitted voice leadings v₁: i → j and v₂: j → k such that the composed voice leading v₂ ∘ v₁: i → k is not permitted.*

*Proof sketch.* We exhibit a concrete counterexample. Consider two successive voice leadings that are each individually valid but whose composition produces parallel motion into a perfect consonance. Each step avoids parallelism individually, but the net effect — the sum of bass motions and the sum of soprano motions — happens to satisfy b_total = s_total ≠ 0 with the final interval being perfect. ∎

**Consequence.** Permitted voice leadings do not form a subcategory of the free category on the quiver. The counterpoint rules are inherently *non-compositional* — local validity does not guarantee global validity.

#### 4.3. Perfect Consonance Bottleneck

**Theorem 4.3** (perfect_self_loop_unique). *If i ∈ P₁₂ is a perfect consonance, there is exactly 1 permitted self-loop at i: the identity voice leading (0, 0).*

*Proof sketch.* A self-loop at i requires τ(i, b, s) = i, i.e., s = b. If s = b ≠ 0, the motion is parallel into a perfect consonance, which is forbidden. Hence b = s = 0. ∎

**Theorem 4.4** (imperfect_self_loops_all). *If i ∈ C₁₂ \ P₁₂ is an imperfect consonance, there are exactly 12 permitted self-loops at i.*

*Proof sketch.* A self-loop requires s = b. Since i is imperfect, the parallel-motion restriction does not apply (it only forbids parallel motion *into perfect* consonances). All 12 values of b ∈ ℤ/12ℤ with s = b give permitted self-loops. ∎

**Interpretation.** The ratio 1:12 quantifies the "stiffness" of perfect consonances. A composer sitting on a perfect fifth has almost no room to maneuver without changing the interval; a composer on a major third has complete freedom for parallel motion.

#### 4.4. Voice-Swap Asymmetry

**Theorem 4.5** (voice_swap_breaks_consonance). *The involution σ: ℤ/12ℤ → ℤ/12ℤ defined by σ(i) = −i does not preserve the consonance set C₁₂. Specifically, σ(7) = 5 ∉ C₁₂.*

*Proof sketch.* Direct computation: −7 ≡ 5 (mod 12). We verify that 5 ∉ {0, 3, 4, 7, 8, 9}. ∎

**Interpretation.** The perfect fifth (7 semitones up from bass) maps to the perfect fourth (5 semitones, equivalently 7 semitones down). In counterpoint, the perfect fourth above the bass is treated as dissonant — a rule that has puzzled students for centuries. This theorem shows it is not a quirk of convention but a structural asymmetry: the consonance set is *not* invariant under voice exchange.

#### 4.5. Hom-Set Cardinalities

**Theorem 4.6** (total_permitted_to_perfect). *Each perfect consonance j ∈ P₁₂ admits exactly 61 permitted incoming voice leadings from all consonant sources combined:*

$$\sum_{i \in C_{12}} |E(i, j)| = 61$$

**Theorem 4.7** (total_permitted_to_imperfect). *Each imperfect consonance j ∈ C₁₂ \setminus P₁₂ admits exactly 72 permitted incoming voice leadings from all consonant sources combined:*

$$\sum_{i \in C_{12}} |E(i, j)| = 72$$

*Proof.* Both results follow from exhaustive enumeration over ℤ/12ℤ × ℤ/12ℤ, verified by decision procedure. ∎

**Interpretation.** The 15% reduction (61 vs. 72) is the quantitative signature of the parallel-motion prohibition. It represents the "compositional tax" on approaching perfect consonances.

---

### 5. The Voice-Leading Cost Function

In a complementary direction, we study the *geometry* of voice leading through a cost function.

#### 5.1. Definitions

**Definition 5.1** (Voice motion). For n voices, a *voice motion* is a vector m ∈ ℤⁿ giving each voice's displacement in semitones.

**Definition 5.2** (Voice-leading cost). The *cost* of a voice motion m is the L¹ norm:

$$\text{cost}(m) = \sum_{i=1}^{n} |m_i|$$

#### 5.2. Seminorm Properties

**Theorem 5.1** (cost_seminorm_properties). *The voice-leading cost function satisfies:*

1. *Nonnegativity*: cost(m) ≥ 0 for all m.
2. *Triangle inequality*: cost(m₁ + m₂) ≤ cost(m₁) + cost(m₂).
3. *Absolute homogeneity*: cost(c · m) = |c| · cost(m) for all c ∈ ℤ.

**Theorem 5.2** (cost_eq_zero_iff). *cost(m) = 0 if and only if m = 0 (no voice moves).*

Together, Theorems 5.1 and 5.2 establish that the voice-leading cost is actually a *norm* on the free ℤ-module ℤⁿ (not merely a seminorm), making the space of voice motions a normed lattice.

#### 5.3. Lattice-Cost Conservation

The space ℤⁿ carries a natural distributive lattice structure via componentwise min (⊓) and max (⊔).

**Theorem 5.3** (cost_meet_join_eq). *For any voice motions m₁, m₂ ∈ ℤⁿ:*

$$\text{cost}(m_1 \sqcap m_2) + \text{cost}(m_1 \sqcup m_2) = \text{cost}(m_1) + \text{cost}(m_2)$$

*Proof sketch.* Reduces pointwise to the identity |min(a,b)| + |max(a,b)| = |a| + |b| for integers a, b, which holds by case analysis on the signs. ∎

**Interpretation.** This is a conservation law for voice-leading effort. Decomposing two voice leadings into their componentwise "gentler" and "bolder" components preserves total displacement. The lattice operations redistribute motion but do not create or destroy it.

**Corollary** (cost_meet_le, cost_join_le). Both the meet and join have cost at most the sum of the individual costs.

#### 5.4. Ascending Motion Sublattice

**Definition 5.3.** A voice motion m is *ascending* if m_i ≥ 0 for all i.

**Theorem 5.4** (ascending_meet, ascending_join). *The set of ascending motions is closed under ⊓ and ⊔. That is, ascending motions form a sublattice of (ℤⁿ, ⊓, ⊔).*

**Theorem 5.5** (ascending_cost_eq_sum). *For ascending motions, cost(m) = Σᵢ mᵢ.* (The absolute values are redundant.)

**Theorem 5.6** (ascending_meet_cost_le). *For ascending m₁, m₂: cost(m₁ ⊓ m₂) ≤ cost(m₁).* The meet of ascending motions is the most efficient.

#### 5.5. Interval Preservation

**Theorem 5.7** (parallel_preserves_interval). *Parallel motion (all voices move by the same amount) preserves all intervals between voices.*

**Theorem 5.8** (nonparallel_changes_interval). *Non-parallel motion between two voices necessarily changes the interval between them.*

These results connect the combinatorial quiver theory of Section 4 with the geometric cost theory: parallel motion is precisely the kernel of the interval-change map.

---

### 6. Discussion

#### 6.1. Category-Theoretic Perspective

The original question motivating this work was whether first-species counterpoint forms a category. Theorem 4.2 answers this decisively: **no**. The permitted voice leadings form a quiver but not a category, because composition fails. This places counterpoint in the interesting class of *non-compositional constraint systems* — systems where local rules do not propagate globally.

The counterpoint quiver is, however, a well-defined object in the category **Quiv** of quivers. The strong connectivity theorem (4.1) shows it is connected, and the hom-set computations (4.6–4.7) fully describe its local structure.

#### 6.2. The Poset Conjecture

Our initial conjecture — that the category of first-species counterpoint is equivalent to the thin category generated by a poset of 12 elements — is *refuted* by Theorem 4.2. The voice leadings do not compose, so they cannot form a category at all, let alone one equivalent to a poset category. However, the strong connectivity theorem suggests a *weaker* structural result: the reachability relation on the quiver *is* a preorder (reflexive and transitive), and Theorem 4.1 shows this preorder is trivial (all pairs are related). The interesting structure lies in the *multiplicity* of edges, not the reachability.

#### 6.3. Generalization to n-TET

The CounterpointSystem structure is defined for arbitrary n. Key questions for future work:

- For which n does the counterpoint quiver remain strongly connected?
- How does the self-loop ratio (perfect vs. imperfect) scale with n?
- Is non-composability a universal feature, or can it fail for certain tuning systems?

#### 6.4. Connections to Constraint Satisfaction

The non-composability result (Theorem 4.2) has implications for constraint-satisfaction theory. In CSP terms, the counterpoint rules define a binary constraint between successive intervals, but this constraint is *not arc-consistent under composition* — a known obstacle to efficient constraint propagation. This connects to the theory of tractable CSP classes (Bulatov, 2017) and suggests that counterpoint constraint satisfaction is inherently harder than its local structure might suggest.

---

### 7. Future Work

1. **Higher species**: Extend the quiver framework to second, third, fourth, and fifth species counterpoint, where rhythm introduces temporal constraints.

2. **Microtonal counterpoint**: Systematically explore CounterpointSystem instantiations for 19-TET, 31-TET, and 53-TET, identifying which structural properties are universal.

3. **Homological invariants**: Compute the homology of the counterpoint quiver's nerve complex to detect higher-dimensional structure.

4. **Algorithmic composition**: Use the hom-set cardinalities as transition weights in a Markov chain model of counterpoint generation.

5. **Multi-voice generalization**: Extend from two-voice to n-voice counterpoint, where the constraint graph becomes hypergraph-valued.

6. **Lattice width bounds**: Prove or disprove the conjecture that optimal voice-leading cost is bounded by the lattice width of the feasible region (bounded by n × b for stepwise bound b).

---

### 8. Detailed Proof Sketches

We now provide expanded proof sketches for the main results, emphasizing the mathematical ideas rather than verification details.

#### 8.1. Proof of Strong Connectivity (Theorem 4.1)

The proof proceeds by case analysis on whether the source and target intervals coincide.

**Case i = j (self-loops):** We must exhibit, for each consonant interval i, a voice leading (b, s) that maps i to i and does not violate the parallel-motion rule. The identity voice leading (0, 0) always works: it maps i to i (trivially), and it is not parallel (since b = 0, the condition b ≠ 0 fails). For imperfect consonances, many other self-loops exist, but the identity suffices.

**Case i ≠ j (distinct intervals):** We use the *canonical voice leading* (0, j − i), where the bass holds and the soprano moves by the difference j − i. The target interval computation yields:

τ(i, 0, j − i) = i + (j − i) − 0 = j

So the voice leading maps i to j as required. Is it parallel? Parallel motion requires b = s and b ≠ 0. Here b = 0, so the second condition fails regardless of s. Therefore the canonical voice leading is never parallel, and the parallel-motion prohibition cannot trigger.

This proof reveals a structural insight: oblique motion (one voice stationary) is always safe. The canonical voice leading is the formalization of the pedagogical advice "when in doubt, hold the bass."

#### 8.2. Proof of Non-Composability (Theorem 4.2)

We construct an explicit counterexample. Consider the path:

- Start at Unison (i = 0)
- Step 1: voice leading (0, 3) moves to Minor 3rd (j = 3). This is permitted: source 0 and target 3 are both consonant, τ(0, 0, 3) = 3, and the motion is not parallel (b = 0).
- Step 2: voice leading (1, 10) moves from Minor 3rd (j = 3) back to Unison (k = 0). Check: τ(3, 1, 10) = 3 + 10 − 1 = 12 ≡ 0 (mod 12). The motion is not parallel (1 ≠ 10). Source 3 and target 0 are both consonant. Permitted.

Now compose: the total voice leading is (0 + 1, 3 + 10) = (1, 13) ≡ (1, 1) (mod 12). Check the composition as a direct step from 0 to 0: τ(0, 1, 1) = 0 + 1 − 1 = 0. ✓ The target is correct. But b = s = 1 ≠ 0, so the motion is parallel, and the target (0) is a perfect consonance. The parallel-motion rule is violated. **The composition is forbidden.**

The total number of such composition violations across all source-intermediate-target triples is 1,320, showing that non-composability is not a marginal phenomenon but a pervasive structural feature.

#### 8.3. Proof of the Bottleneck Theorem (Theorems 4.3–4.4)

For perfect consonances: A self-loop at interval i requires τ(i, b, s) = i, which simplifies to s = b. If s = b ≠ 0, the motion is parallel into a perfect consonance — forbidden. Therefore b = s = 0 is the unique self-loop. This gives exactly 1 self-loop per perfect consonance.

For imperfect consonances: Again s = b is required for a self-loop. But now the target i is imperfect, so the parallel-motion rule does not apply (it only restricts motion into *perfect* consonances). All 12 values b ∈ {0, 1, ..., 11} with s = b are permitted. This gives exactly 12 self-loops per imperfect consonance.

The ratio 1:12 is exact and independent of which specific consonance we consider within its class. It depends only on whether the interval is perfect or imperfect.

#### 8.4. Proof of the Lattice-Cost Identity (Theorem 5.3)

The proof reduces to a pointwise identity on integers. For each coordinate i, we need:

|min(a, b)| + |max(a, b)| = |a| + |b|

where a = m₁(i) and b = m₂(i). We verify this by case analysis:

- **Case a ≤ b**: LHS = |a| + |b| = RHS. ✓
- **Case a > b**: LHS = |b| + |a| = |a| + |b| = RHS. ✓

Summing over all coordinates gives the full identity. The key observation is that {min(a,b), max(a,b)} is always a permutation of {a, b}, and the L¹ norm is invariant under coordinate permutations.

### 9. Computational Verification

All theorems involving the standard 12-TET system were verified by exhaustive computation. The complete counterpoint quiver has:

- **6 vertices** (consonant intervals: 0, 3, 4, 7, 8, 9)
- **410 directed edges** (permitted voice leadings)
- **Edge density**: 410 / (6 × 6 × 144) ≈ 0.079

The adjacency matrix (number of permitted voice leadings from row to column):

|     |  0  |  3  |  4  |  7  |  8  |  9  |
|-----|-----|-----|-----|-----|-----|-----|
| **0** |  1  | 12  | 12  | 12  | 12  | 12  |
| **3** | 12  | 12  | 12  | 12  | 12  | 12  |
| **4** | 12  | 12  | 12  | 12  | 12  | 12  |
| **7** | 12  | 12  | 12  |  1  | 12  | 12  |
| **8** | 12  | 12  | 12  | 12  | 12  | 12  |
| **9** | 12  | 12  | 12  | 12  | 12  | 12  |

The matrix is symmetric under exchange of rows 0 ↔ 7 (the two perfect consonances) and is otherwise uniform. The bottleneck appears exactly at the (0,0) and (7,7) entries.

Row and column sums:
- Perfect consonances (0, 7): 61 outgoing, 61 incoming
- Imperfect consonances (3, 4, 8, 9): 72 outgoing, 72 incoming

The quiver is "doubly stochastic" in the sense that row sums equal column sums for each vertex — a consequence of the group structure of ℤ/12ℤ.

### 10. References

1. Fux, J. J. (1725). *Gradus ad Parnassum*. Vienna.
2. Mazzola, G. (2002). *The Topos of Music*. Birkhäuser.
3. Tymoczko, D. (2006). The geometry of musical chords. *Science*, 313(5783), 72–74.
4. Tymoczko, D. (2011). *A Geometry of Music*. Oxford University Press.
5. Fiore, T. M., & Satyendra, R. (2005). Generalized contextual groups. *Music Theory Online*, 11(3).
6. Bulatov, A. A. (2017). A dichotomy theorem for nonuniform CSPs. *FOCS 2017*, 319–330.
7. Cohn, R. (1998). Introduction to neo-Riemannian theory. *Journal of Music Theory*, 42(2), 167–180.
8. Lewin, D. (1987). *Generalized Musical Intervals and Transformations*. Yale University Press.

---

### Appendix: Catalog of Formal Results

| Result Name | Statement | Type |
|---|---|---|
| `exists_permitted_voice_leading` | ∀ i j ∈ C₁₂, ∃ vl, permitted(i, j, vl) | Strong connectivity |
| `non_composability` | ∃ composition of permitted VLs that is not permitted | Non-closure |
| `perfect_self_loop_unique` | Perfect consonance has exactly 1 self-loop | Bottleneck |
| `imperfect_self_loops_all` | Imperfect consonance has exactly 12 self-loops | Freedom |
| `voice_swap_breaks_consonance` | −7 ≡ 5 ∉ C₁₂ | Asymmetry |
| `total_permitted_to_perfect` | 61 incoming voice leadings to perfect consonances | Hom-set |
| `total_permitted_to_imperfect` | 72 incoming voice leadings to imperfect consonances | Hom-set |
| `cost_triangle` | cost(m₁+m₂) ≤ cost(m₁) + cost(m₂) | Metric |
| `cost_meet_join_eq` | cost(m₁⊓m₂) + cost(m₁⊔m₂) = cost(m₁) + cost(m₂) | Conservation |
| `cost_seminorm_properties` | Nonnegativity + subadditivity + homogeneity | Seminorm |
| `ascending_meet` / `ascending_join` | Ascending motions form sublattice | Lattice |
| `parallel_preserves_interval` | Parallel motion preserves intervals | Geometry |
| `nonparallel_changes_interval` | Non-parallel motion changes intervals | Geometry |
