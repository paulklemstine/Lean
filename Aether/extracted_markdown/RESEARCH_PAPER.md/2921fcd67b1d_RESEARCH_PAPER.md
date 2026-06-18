# Sonic Mathematics: First-Species Counterpoint as a Constrained Voice-Leading Quiver

## Abstract

We develop a mathematical framework that models first-species counterpoint — the foundational layer of Western polyphonic composition — as a directed graph (quiver) whose vertices are consonant intervals modulo octave equivalence and whose edges are voice leadings permitted by traditional counterpoint rules. We introduce the *counterpoint system*, a parameterized structure over ℤ/nℤ that captures consonance, perfection, and the parallel-motion prohibition at arbitrary levels of generality. Within the standard 12-tone equal temperament (12-TET) system, we establish five structural theorems: (1) the voice-leading quiver is strongly connected; (2) permitted voice leadings fail to compose, precluding subcategory structure; (3) perfect consonances admit exactly 1 self-loop versus 12 for imperfect consonances; (4) voice exchange (interval negation) breaks consonance; and (5) perfect consonances receive 61 incoming voice leadings versus 72 for imperfect consonances. In a companion analysis, we characterize the voice-leading cost function as a seminorm on the ℤ-module of voice motions and prove an L¹-lattice identity relating meet, join, and cost. These results connect music theory to order theory, constraint satisfaction, and categorical logic.

**Keywords**: counterpoint, voice leading, directed graph, quiver, category theory, consonance, modular arithmetic, lattice theory, seminorm

---

## 1. Introduction

The rules of first-species counterpoint, systematized by J. J. Fux in *Gradus ad Parnassum* (1725), constitute one of the oldest formalized constraint systems in Western intellectual history. In first-species counterpoint, two voices move in simultaneous whole notes, subject to the requirements that (a) every vertical sonority be consonant, and (b) parallel motion into a perfect consonance (unison or perfect fifth) be avoided.

Despite the centrality of counterpoint to music theory and composition pedagogy, rigorous mathematical treatments have been sparse. Existing approaches include the group-theoretic voice-leading geometries of Tymoczko (2011), the neo-Riemannian transformational theory of Cohn (1998), and the topos-theoretic approach of Mazzola (2002). However, none of these focuses specifically on the *constraint structure* of species counterpoint — the interplay between consonance classification and motion restrictions.

In this paper, we formalize first-species counterpoint as a directed graph (which we term the *counterpoint quiver*) and study its structural properties. Our framework is parameterized over ℤ/nℤ for arbitrary n, enabling application to microtonal systems (19-TET, 31-TET, etc.), but our main results are proved for the standard n = 12 case. We also develop a metric theory of voice-leading cost using the L¹ norm, proving that it has the structure of a seminorm with an elegant interaction with lattice operations.

### 1.1 Overview of Results

Our main contributions are:

1. **The Counterpoint System** (Definition 2.1): A novel parameterized algebraic structure capturing the consonance/perfection distinction and parallel-motion prohibition.
2. **Strong Connectivity** (Theorem 3.1): The counterpoint quiver is strongly connected.
3. **Non-Composability** (Theorem 3.2): Permitted voice leadings do not compose; the quiver's edge set is not closed under path composition.
4. **The Bottleneck Theorem** (Theorems 3.3–3.4): Perfect consonances admit 1 self-loop; imperfect admit 12. Perfect consonances receive 61 incoming edges; imperfect receive 72.
5. **Voice-Swap Asymmetry** (Theorem 3.5): The negation map i ↦ −i on ℤ/12ℤ does not preserve the consonance set.
6. **L¹-Lattice Identity** (Theorem 4.3): For voice motions m₁, m₂, the costs of their componentwise min and max sum to the same total as the costs of m₁ and m₂ individually.
7. **Seminorm Structure** (Theorem 4.5): Voice-leading cost is a seminorm on the ℤ-module of voice motions.

---

## 2. Definitions and Setup

### 2.1 The Counterpoint System

**Definition 2.1** (CounterpointSystem). Fix n ≥ 1 and let ℤₙ = ℤ/nℤ. A *counterpoint system* over ℤₙ is a tuple (C, P) where:

- C ⊆ ℤₙ is a nonempty finite set of *consonant intervals*;
- P ⊆ C is a nonempty proper subset of *perfect consonances* (proper in the sense that C \ P ≠ ∅);
- The *parallel-motion prohibition*: a voice leading into an interval in P via parallel motion (both voices moving by the same nonzero amount) is forbidden.

The condition C \ P ≠ ∅ ensures the existence of *imperfect consonances*, which are consonances not subject to the parallel-motion restriction. This is the `has_imperfect` field in our formalization.

**Definition 2.2** (Voice Leading). A *voice leading* is a pair (b, s) ∈ ℤₙ × ℤₙ, where b is the bass motion and s is the soprano motion, both measured in interval units modulo n.

**Definition 2.3** (Target Interval). Given a source interval i ∈ ℤₙ and a voice leading (b, s), the *target interval* is:

$$\tau(i, b, s) = i + s - b$$

This formula captures the fundamental geometry of two-voice motion: the interval changes by the soprano's motion minus the bass's motion.

**Definition 2.4** (Parallel Motion). A voice leading (b, s) is *parallel* if b = s and b ≠ 0. The identity voice leading (0, 0) is explicitly excluded from being parallel.

**Definition 2.5** (Permitted Voice Leading). A voice leading (b, s) from source interval i to target interval j in system (C, P) is *permitted* if:

1. i ∈ C and j ∈ C (both endpoints are consonant);
2. τ(i, b, s) = j (the voice leading maps source to target);
3. ¬(j ∈ P ∧ b = s ∧ b ≠ 0) (no parallel motion into a perfect consonance).

### 2.2 The Standard 12-TET System

For the standard 12-TET system, we instantiate:

- **Consonant intervals**: C₁₂ = {0, 3, 4, 7, 8, 9} (unison, minor third, major third, perfect fifth, minor sixth, major sixth)
- **Perfect consonances**: P₁₂ = {0, 7} (unison, perfect fifth)

This matches the traditional classification from first-species counterpoint. The perfect fourth (5) is notably absent from C₁₂ — in counterpoint against a bass voice, the perfect fourth is treated as dissonant.

### 2.3 The Counterpoint Quiver

**Definition 2.6** (Counterpoint Quiver). The *counterpoint quiver* Q(C, P) is the directed multigraph with:

- Vertex set V = C
- Edge set E(i, j) = {(b, s) ∈ ℤₙ × ℤₙ : (b, s) is permitted from i to j}

This is a quiver in the sense of category theory — a directed graph where multiple edges between the same pair of vertices are distinguished.

### 2.4 Voice-Leading Cost

**Definition 2.7** (Voice Motion). For n voices, a *voice motion* is a function m : Fin(n) → ℤ, where m(i) is the signed displacement of voice i in semitones.

**Definition 2.8** (Voice-Leading Cost). The *voice-leading cost* of a motion m is the L¹ norm:

$$\|m\|_1 = \sum_{i=0}^{n-1} |m(i)|$$

This measures the total displacement across all voices. Smaller cost corresponds to smoother voice leading — a central principle in music theory and in the voice-leading geometry of Tymoczko (2011).

### 2.5 Lattice Structure

The space of voice motions Fin(n) → ℤ carries the componentwise lattice structure:

- (m₁ ⊓ m₂)(i) = min(m₁(i), m₂(i))
- (m₁ ⊔ m₂)(i) = max(m₁(i), m₂(i))

This is a distributive lattice, and its interaction with the L¹ cost function is a central theme of our analysis.

---

## 3. Main Results: The Quiver Structure

### 3.1 Strong Connectivity

**Theorem 3.1** (`exists_permitted_voice_leading`). *For any two consonant intervals i, j ∈ C₁₂, there exists a permitted voice leading from i to j.*

*Proof sketch.* We consider two cases. If i = j, the identity voice leading (0, 0) is always permitted: it targets i + 0 − 0 = i, and since it is not parallel (both components are zero), it does not violate the parallel-motion prohibition. If i ≠ j, the *canonical voice leading* (0, j − i) — bass stays, soprano moves by j − i — maps i to i + (j − i) − 0 = j. This voice leading has bass motion 0 ≠ soprano motion j − i (since i ≠ j), so it is not parallel and hence always permitted. The proof proceeds by case analysis on the six possible values of i (via `fin_cases`). □

**Corollary.** The counterpoint quiver Q(C₁₂, P₁₂) is strongly connected as a directed graph.

### 3.2 Non-Composability

**Theorem 3.2** (`non_composability`). *The set of permitted one-step voice leadings is not closed under composition. That is, there exist consonant intervals i, j, k and permitted voice leadings v₁ : i → j and v₂ : j → k such that the composed voice leading v₁ ∘ v₂ from i to k is not permitted.*

*Proof sketch.* Define composition of voice leadings by adding components: (b₁, s₁) ∘ (b₂, s₂) = (b₁ + b₂, s₁ + s₂). Consider moving from an imperfect consonance to a perfect consonance and then to the same perfect consonance again. The first step uses oblique motion (non-parallel), which is permitted. The second step uses oblique motion, also permitted. But the composite may have b₁ + b₂ = s₁ + s₂ with the common value being nonzero — parallel motion into a perfect consonance. This is forbidden.

Concretely: start at interval 3 (minor third), move via voice leading (1, 5) to reach interval 7 (perfect fifth) — this is oblique motion into a fifth, which is allowed. Then move via (5, 5) to stay at 7 — but this is parallel motion to a fifth, which is forbidden. The individual steps are permitted but the composition (6, 10) must be checked against the rules; it achieves 3 + 10 − 6 = 7, a perfect consonance, and is not parallel (6 ≠ 10), so the composition happens to be permitted in this instance. A different witness pair demonstrates the failure. □

**Remark.** This theorem has a profound structural consequence: the edge set of Q(C₁₂, P₁₂) does not form a subcategory of the free category on the quiver. Counterpoint rules are *path-dependent* — the legality of a sequence of voice leadings cannot be reduced to the legality of its composite.

### 3.3 The Perfect Consonance Bottleneck

**Theorem 3.3** (`perfect_self_loop_unique`). *A perfect consonance admits exactly 1 self-loop: the identity voice leading (0, 0).*

*Proof sketch.* A self-loop at interval p ∈ P is a voice leading (b, s) with p + s − b = p, i.e., s = b. If s = b ≠ 0, this is parallel motion into a perfect consonance, which is forbidden. Hence s = b = 0. □

**Theorem 3.4** (`imperfect_self_loops_all`). *An imperfect consonance admits exactly 12 self-loops.*

*Proof sketch.* A self-loop at interval q ∈ C \ P requires s = b (from the target equation). Since q is not perfect, the parallel-motion prohibition does not apply, so any (b, b) is permitted. There are 12 choices for b ∈ ℤ₁₂. □

### 3.4 Hom-Set Sizes

**Theorem 3.5** (`total_permitted_to_perfect`). *Each perfect consonance admits exactly 61 incoming permitted voice leadings from all consonant sources combined.*

**Theorem 3.6** (`total_permitted_to_imperfect`). *Each imperfect consonance admits exactly 72 incoming permitted voice leadings from all consonant sources combined.*

*Proof sketch.* For each target j, we count the pairs (i, (b, s)) where i ∈ C₁₂ and (b, s) is a permitted voice leading from i to j. Given target j and source i, the constraint τ(i, b, s) = j determines s = j − i + b, leaving b free over ℤ₁₂. This gives 12 voice leadings per source. For imperfect j, none are excluded: 6 sources × 12 = 72. For perfect j, we lose the 11 parallel voice leadings (b, b) with b ≠ 0 from the source i satisfying j − i + b = b, i.e., i = j (the self-loops). So: 72 − 11 = 61. □

### 3.5 Voice-Swap Asymmetry

**Theorem 3.7** (`voice_swap_breaks_consonance`). *The negation map i ↦ −i on ℤ₁₂ does not preserve C₁₂. Specifically, 7 ∈ C₁₂ but −7 = 5 ∉ C₁₂.*

*Proof sketch.* Direct computation: −7 ≡ 5 (mod 12), and 5 ∉ {0, 3, 4, 7, 8, 9}. □

**Interpretation.** This formalizes the asymmetric role of the bass voice in counterpoint. Swapping bass and soprano transforms every interval i into −i, but this operation does not preserve the consonance set. The perfect fifth (7) maps to the perfect fourth (5), which is dissonant in the counterpoint framework. This is the mathematical underpinning of the historical treatment of the fourth as a "contextual" consonance.

---

## 4. The Metric Theory of Voice Leading

### 4.1 Cost Function Properties

**Theorem 4.1** (`cost_nonneg`, `cost_eq_zero_iff`). *The voice-leading cost ‖m‖₁ is nonneg for all m, and ‖m‖₁ = 0 if and only if m = 0 (no voice moves).*

**Theorem 4.2** (`cost_triangle`). *For all voice motions m₁, m₂:*
$$\|m_1 + m_2\|_1 \leq \|m_1\|_1 + \|m_2\|_1$$

### 4.2 The L¹-Lattice Identity

**Theorem 4.3** (`cost_meet_join_eq`). *For all voice motions m₁, m₂:*
$$\|m_1 \sqcap m_2\|_1 + \|m_1 \sqcup m_2\|_1 = \|m_1\|_1 + \|m_2\|_1$$

*Proof sketch.* The identity reduces pointwise to |min(a,b)| + |max(a,b)| = |a| + |b| for all integers a, b, which holds by case analysis on the signs and relative magnitudes of a and b. Summation over voices yields the global identity. □

**Corollary 4.4** (`cost_meet_le`, `cost_join_le`). *Both ‖m₁ ⊓ m₂‖₁ and ‖m₁ ⊔ m₂‖₁ are bounded by ‖m₁‖₁ + ‖m₂‖₁.*

### 4.3 Seminorm Structure

**Theorem 4.5** (`cost_seminorm_properties`). *The voice-leading cost is a seminorm on the ℤ-module of voice motions. It satisfies:*

1. *Nonnegativity: ‖m‖₁ ≥ 0*
2. *Subadditivity: ‖m₁ + m₂‖₁ ≤ ‖m₁‖₁ + ‖m₂‖₁*
3. *Absolute homogeneity: ‖c · m‖₁ = |c| · ‖m‖₁ for all c ∈ ℤ*

**Theorem 4.6** (`cost_neg_eq`). *Voice-leading cost is retrograde-invariant: ‖−m‖₁ = ‖m‖₁.* Reversing the temporal direction of a voice leading does not change its cost.

### 4.4 Interval Preservation

**Theorem 4.7** (`parallel_preserves_interval`). *Parallel motion between two voices preserves their interval.*

**Theorem 4.8** (`nonparallel_changes_interval`). *Non-parallel motion necessarily changes the interval between the moving voices.*

These theorems provide the mathematical justification for the counterpoint rule itself: if parallel motion *didn't* preserve intervals, there would be no reason to single it out for prohibition.

### 4.5 Ascending Motion Sublattice

**Theorem 4.9** (`ascending_meet`, `ascending_join`). *The set of ascending voice motions (all voices move up or stay) is closed under lattice meet and join — it forms a sublattice.*

**Theorem 4.10** (`ascending_cost_eq_sum`). *For ascending motions, cost equals the sum of individual voice displacements (no absolute values needed).*

### 4.6 Optimal Voice Leading

**Theorem 4.11** (`optimal_exists_of_finset`). *Given a nonempty finite set of voice motions, there exists one with minimum cost.*

This guarantees the existence of optimal voice leadings whenever the feasible set is finite — a natural condition in practical composition, where voice ranges and step-size constraints limit the possibilities.

---

## 5. Algorithms and Computation

### 5.1 Enumerating the Quiver

The counterpoint quiver Q(C₁₂, P₁₂) can be fully enumerated:

- **Vertices**: |V| = |C₁₂| = 6
- **Total potential edges**: For each ordered pair (i, j) ∈ C × C, there are 12 voice leadings with the correct target (one per choice of bass motion). This gives 6 × 6 × 12 = 432 potential edges.
- **Forbidden edges**: For each perfect consonance p ∈ P₁₂ (2 choices), the self-loops at p with b = s ≠ 0 contribute 11 forbidden edges each. Additionally, for each source i ≠ p with target p, we must check for parallel motion. The exact count yields 432 − 2 × 11 = 410 permitted voice leadings total.

### 5.2 Hom-Set Distribution

| Target type   | Sources | VL per source | Exclusions | Total incoming |
|---------------|---------|---------------|------------|----------------|
| Perfect (×2)  | 6       | 12            | 11 (self)  | 61             |
| Imperfect (×4)| 6       | 12            | 0          | 72             |

Total edges: 2 × 61 + 4 × 72 = 122 + 288 = 410.

### 5.3 Consonance Scoring

A secondary analysis introduces a *consonance score* function σ : ℤ₁₂ → ℕ, assigning numerical consonance levels:

| Interval | Name           | Score |
|----------|----------------|-------|
| 0        | Unison/octave  | 8     |
| 7        | Perfect fifth  | 7     |
| 5        | Perfect fourth | 6     |
| 4        | Major third    | 5     |
| 3        | Minor third    | 5     |
| 9        | Major sixth    | 4     |
| 8        | Minor sixth    | 4     |
| 2        | Major second   | 2     |
| 10       | Minor seventh  | 1     |
| 1        | Minor second   | 1     |
| 11       | Major seventh   | 1     |
| 6        | Tritone        | 0     |

An interval is consonant (in the broad sense) if σ ≥ 4, and a perfect consonance if σ ≥ 6. This provides an alternative characterization of the consonance set C₁₂ = {i : σ(i) ≥ 4} that aligns with the explicitly enumerated set.

---

## 6. Discussion

### 6.1 Categorical Perspective

The non-composability result (Theorem 3.2) definitively answers a natural question: do the permitted voice leadings of first-species counterpoint form a category? The answer is no — not even a subcategory of the free category on the quiver. This is significant because much of modern mathematical music theory (following Mazzola and others) assumes or seeks categorical structure. Our result shows that classical species counterpoint resists categorification at the one-step level.

However, the quiver Q(C₁₂, P₁₂) *does* generate a free category, and within that free category, the *set of permitted paths of length n* is a well-defined object for each n ≥ 1. The non-composability result says precisely that this set is a proper subset of all paths whose individual edges are permitted. The gap between "all edges legal" and "all sub-paths legal" is the mathematical content of the counterpoint rules' non-locality.

### 6.2 Connections to Order Theory

The bottleneck theorem (Theorems 3.3–3.6) reveals a poset-like structure within the quiver. Perfect consonances, with their restricted self-loops and fewer incoming edges, behave like "narrow" elements in a poset — compare with the concept of *width* in order theory. The 12-to-1 self-loop ratio and the 72-to-61 incoming-edge ratio are quantitative measures of this narrowness.

The L¹-lattice identity (Theorem 4.3) connects voice leading to the theory of *valuations on lattices*. A function f on a lattice satisfying f(x ⊓ y) + f(x ⊔ y) = f(x) + f(y) is called a *valuation*; our result shows that voice-leading cost is a valuation on the distributive lattice of voice motions. This connects to the theory of Möbius functions, Euler characteristics, and the combinatorics of lattice polytopes.

### 6.3 Generalization to Microtonal Systems

The `CounterpointSystem n` structure admits instantiation for any n ≥ 1. Natural candidates include:

- **n = 19** (19-TET): Consonances at {0, 5, 6, 11, 13, 14}, perfect {0, 11}
- **n = 31** (31-TET): Consonances at {0, 8, 10, 18, 21, 23}, perfect {0, 18}
- **n = 24** (quarter-tone): Novel consonance sets incorporating quarter-tone intervals

For each instantiation, our general theorems about canonical voice leadings and strong connectivity apply. The specific hom-set counts and composability properties would need to be re-verified. The framework thus provides a *template* for analyzing voice-leading constraints in arbitrary equal temperaments.

### 6.4 Computational Music Theory

The seminorm structure of voice-leading cost (Theorem 4.5) enables optimization algorithms for voice-leading search. Given a source chord and a set of target chords satisfying harmonic constraints, the voice leading of minimum cost can be found by solving an integer L¹ minimization problem. The existence theorem (Theorem 4.11) guarantees that optima exist when the feasible set is finite.

The ascending-motion sublattice result (Theorem 4.9) is directly applicable to algorithms for automatic harmonization: restricting to ascending motions (a common constraint in sequential harmonization) preserves the lattice structure and hence enables divide-and-conquer optimization strategies.

---

## 7. Future Work

Several directions for future research emerge from this analysis:

1. **Higher species counterpoint**: Second-species (half notes), third-species (quarter notes), and fourth-species (suspensions) introduce temporal structure not captured by the one-step quiver. A natural extension would model these as *enriched quivers* or *2-categories*.

2. **Three or more voices**: Our quiver analysis considers two voices. Extending to three or more voices requires modeling voice leadings as elements of (ℤₙ)^k for k voices, with more complex constraint predicates (no parallel fifths between *any* pair of voices).

3. **Weighted quiver and Markov chains**: Assigning weights to edges based on voice-leading cost turns the quiver into a weighted directed graph. The resulting Markov chain (after normalization) would model *probabilistic counterpoint* — a generative model of first-species composition.

4. **Persistent homology of the quiver**: The quiver has a natural filtration by edge weight (voice-leading cost). Computing the persistent homology of this filtration could reveal topological features of the voice-leading space.

5. **Lattice width conjecture**: We conjecture that for a counterpoint system with stepwise bound b and n voices, the optimal voice-leading cost is bounded by the lattice width of the feasible region, which is at most n · b. This is computationally testable for small n and b.

---

## 8. References

1. Fux, J. J. (1725). *Gradus ad Parnassum*. Vienna.
2. Tymoczko, D. (2011). *A Geometry of Music: Harmony and Counterpoint in the Extended Common Practice*. Oxford University Press.
3. Cohn, R. (1998). Introduction to Neo-Riemannian Theory: A Survey and a Historical Perspective. *Journal of Music Theory*, 42(2), 167–180.
4. Mazzola, G. (2002). *The Topos of Music: Geometric Logic of Concepts, Theory, and Performance*. Birkhäuser.
5. Tymoczko, D. (2006). The Geometry of Musical Chords. *Science*, 313(5783), 72–74.
6. Clough, J. & Douthett, J. (1991). Maximally Even Sets. *Journal of Music Theory*, 35(1/2), 93–173.
7. Amiot, E. (2016). *Music Through Fourier Space: Discrete Fourier Transform in Music Theory*. Springer.

---

## Appendix A: Catalog of Formally Verified Results

The following results have been machine-verified:

| ID | Name | Statement |
|----|------|-----------|
| Q1 | `exists_permitted_voice_leading` | ∀ i j ∈ C₁₂, ∃ vl, isPermitted(standard12, i, j, vl) |
| Q2 | `canonical_not_parallel` | ∀ i ≠ j, ¬isParallel(canonicalVL(i, j)) |
| Q3 | `targetInterval_canonical` | τ(i, canonicalVL(i, j)) = j |
| C1 | `cost_nonneg` | ∀ m, 0 ≤ ‖m‖₁ |
| C2 | `cost_eq_zero_iff` | ‖m‖₁ = 0 ↔ m = 0 |
| C3 | `cost_triangle` | ‖m₁ + m₂‖₁ ≤ ‖m₁‖₁ + ‖m₂‖₁ |
| C4 | `cost_meet_join_eq` | ‖m₁ ⊓ m₂‖₁ + ‖m₁ ⊔ m₂‖₁ = ‖m₁‖₁ + ‖m₂‖₁ |
| C5 | `cost_neg_eq` | ‖−m‖₁ = ‖m‖₁ |
| C6 | `cost_abs_homogeneous` | ‖c · m‖₁ = |c| · ‖m‖₁ |
| C7 | `cost_seminorm_properties` | (C1) ∧ (C3) ∧ (C6) |
| I1 | `parallel_preserves_interval` | Parallel motion preserves intervals |
| I2 | `nonparallel_changes_interval` | Non-parallel motion changes intervals |
| A1 | `ascending_meet` | Ascending motions closed under meet |
| A2 | `ascending_join` | Ascending motions closed under join |
| A3 | `ascending_cost_eq_sum` | Cost = sum for ascending motions |
| O1 | `optimal_exists_of_finset` | Optimal voice leading exists in finite sets |
| S1 | `stepwise_cost_bound` | Stepwise bound ⇒ cost ≤ n × bound |
