# Sonic Mathematics: Counterpoint as Category Theory

**Formalizing First-Species Voice Leading as a Directed Graph with Lattice-Theoretic Cost Structure**

---

## Abstract

We formalize the voice-leading rules of first-species counterpoint (following Fux, 1725) as a directed graph — the *Counterpoint Quiver* — over the modular group ZMod 12, and study its structural properties. Objects are the six consonant interval classes {0, 3, 4, 7, 8, 9} in twelve-tone equal temperament; arrows are voice leadings (pairs of voice motions mod 12) satisfying the prohibition on parallel motion to perfect consonances. We establish five main results: (1) **strong connectivity** — a permitted voice leading exists between any pair of consonant intervals; (2) **non-composability** — permitted voice leadings fail to close under composition, so the quiver is not a subcategory of the free category on ZMod 12 × ZMod 12; (3) **the bottleneck theorem** — perfect consonances admit exactly 1 self-loop (the identity) versus 12 for imperfect consonances, and 61 total incoming arrows versus 72; (4) **voice-swap asymmetry** — the involution i ↦ −i on ZMod 12 does not preserve the consonant set, formalizing the non-interchangeability of bass and soprano; (5) **the L¹-lattice identity** — voice-leading cost (the L¹ norm on ℤⁿ) satisfies cost(m₁ ⊓ m₂) + cost(m₁ ⊔ m₂) = cost(m₁) + cost(m₂), establishing a conservation law linking metric and lattice structure. We introduce the abstract notion of a *Counterpoint System* over ZMod n, generalizing beyond 12-TET, and prove that the cost function is a seminorm on the voice-motion ℤ-module. All results are machine-verified.

**Keywords:** mathematical music theory, counterpoint, category theory, quiver, voice leading, lattice theory, ZMod, seminorm, directed graph

---

## 1. Introduction

### 1.1 Background and Motivation

First-species counterpoint, codified by Fux (1725), is the foundation of Western polyphonic composition. Its rules prescribe which vertical intervals between two voices are *consonant* and constrain the *voice leadings* — simultaneous motions of both voices — by which a composer may move from one consonant interval to another. The central prohibition is on *parallel motion to perfect consonances*: when both voices move in the same direction by the same amount, the resulting interval must not be a unison or perfect fifth.

Modern mathematical music theory, following Lewin (1987), Tymoczko (2011), and Fiore & Satyendra (2005), has explored voice-leading spaces as geometric objects. However, the specific constraint structure of counterpoint — the interplay between consonance classification and motion type — has not been formalized as a categorical or graph-theoretic object with machine-verified structural theorems.

### 1.2 Contributions

We introduce two interconnected formalizations:

1. **The Counterpoint Quiver** — a directed graph (quiver) whose vertices are consonant interval classes in ZMod 12 and whose edges are permitted voice leadings. We prove structural theorems about connectivity, composability failure, and hom-set cardinalities.

2. **The Voice-Leading Seminorm** — the L¹ cost function on voice motions ℤⁿ, shown to be a seminorm with a remarkable interaction with the componentwise lattice structure.

Both are generalized via the notion of a *CounterpointSystem n*, parameterized over arbitrary equal temperaments ZMod n.

### 1.3 Organization

Section 2 establishes definitions. Section 3 presents the main results on the Counterpoint Quiver. Section 4 develops the voice-leading cost theory. Section 5 discusses applications and implications. Section 6 outlines future work.

---

## 2. Definitions

### 2.1 The Counterpoint System

**Definition 2.1** (CounterpointSystem). A *counterpoint system* over ZMod n (for n ≥ 1) consists of:
- A finite set C ⊆ ZMod n of *consonant intervals*
- A subset P ⊆ C of *perfect consonances*
- The conditions: C is nonempty, P is nonempty, and C \ P is nonempty (there exist imperfect consonances)

The standard 12-TET system has:
- C = {0, 3, 4, 7, 8, 9} (unison, minor third, major third, perfect fifth, minor sixth, major sixth)
- P = {0, 7} (unison, perfect fifth)

### 2.2 Voice Leadings

**Definition 2.2** (VoiceLeading). A *voice leading* over ZMod n is a pair (b, s) ∈ ZMod n × ZMod n, where b is the bass motion and s is the soprano motion.

**Definition 2.3** (Target interval). Given a source interval i ∈ ZMod n and a voice leading (b, s), the *target interval* is:

$$\text{target}(i, b, s) = i + s - b$$

This follows from the observation that if the interval is i = p_{\text{soprano}} - p_{\text{bass}}, then after moving bass by b and soprano by s, the new interval is (p_{\text{soprano}} + s) - (p_{\text{bass}} + b) = i + s - b.

**Definition 2.4** (Parallel motion). A voice leading (b, s) is *parallel* if b = s and b ≠ 0.

**Definition 2.5** (Permitted voice leading). A voice leading (b, s) is *permitted* from source i to target j in a counterpoint system (C, P) if:
1. i ∈ C and j ∈ C
2. target(i, b, s) = j
3. ¬(j ∈ P ∧ (b, s) is parallel)

### 2.3 Voice-Leading Cost

**Definition 2.6** (Voice-leading cost). For n voices with integer pitch motions m : Fin n → ℤ, the *voice-leading cost* is the L¹ norm:

$$\text{cost}(m) = \sum_{i=0}^{n-1} |m_i|$$

**Definition 2.7** (Ascending motion). A voice motion m is *ascending* if m(i) ≥ 0 for all i.

---

## 3. The Counterpoint Quiver: Main Results

### 3.1 Strong Connectivity

**Theorem 3.1** (`exists_permitted_voice_leading`). *For any two consonant intervals i, j ∈ C in the standard 12-TET system, there exists a permitted voice leading from i to j.*

*Proof sketch.* For distinct i, j, the *canonical voice leading* (0, j − i) — bass stays, soprano moves — achieves target(i, 0, j − i) = i + (j − i) − 0 = j. Since the bass motion is 0, we have b = 0 ≠ s (as i ≠ j), so the motion is not parallel. Hence the prohibition on parallel motion to perfect consonances never triggers. For i = j, the identity voice leading (0, 0) is permitted since it is not parallel (b = 0). The cases are verified exhaustively over the finite set C = {0, 3, 4, 7, 8, 9}. □

**Corollary 3.2.** The Counterpoint Quiver is strongly connected as a directed graph.

### 3.2 Non-Composability

**Theorem 3.3** (`non_composability`). *There exist consonant intervals i, j, k and permitted voice leadings (b₁, s₁) from i to j and (b₂, s₂) from j to k such that the composed voice leading (b₁ + b₂, s₁ + s₂) from i to k is not permitted.*

*Proof sketch.* This is established by explicit counterexample. Two voice leadings that individually satisfy the parallel-motion prohibition can compose into a parallel motion arriving at a perfect consonance. The composition (b₁ + b₂, s₁ + s₂) may have b₁ + b₂ = s₁ + s₂ ≠ 0 with target in P, even though neither individual voice leading was parallel to a perfect consonance. □

**Corollary 3.4.** The permitted voice leadings do not form a subcategory of the free category on the Counterpoint Quiver. Counterpoint is inherently a *one-step* theory: validity must be checked at each transition, not composed from previously validated transitions.

### 3.3 The Bottleneck Theorem

**Theorem 3.5** (`perfect_self_loop_unique`, `imperfect_self_loops_all`). *A perfect consonance p ∈ P admits exactly 1 self-loop (the identity voice leading (0, 0)), while an imperfect consonance q ∈ C \ P admits exactly 12 self-loops.*

*Proof sketch.* A self-loop at interval i requires target(i, b, s) = i, i.e., s = b. For an imperfect consonance q ∉ P, the parallel-motion prohibition does not apply (the target is not perfect), so all 12 choices of b = s ∈ ZMod 12 are permitted. For a perfect consonance p ∈ P, the condition ¬(p ∈ P ∧ b = s ∧ b ≠ 0) reduces to b = 0, leaving only the identity. □

**Theorem 3.6** (`total_permitted_to_perfect`, `total_permitted_to_imperfect`). *The total number of permitted voice leadings from all consonant sources to a given perfect consonance is 61. The corresponding count for an imperfect consonance is 72.*

*Proof sketch.* For each target j, we enumerate over all sources i ∈ C and all voice leadings (b, s) with target(i, b, s) = j, filtering by the permitted predicate. Given source i and target j, the constraint s = j − i + b parametrizes valid voice leadings by b ∈ ZMod 12. For imperfect targets, all 12 choices of b are permitted for each of the 6 sources, giving 6 × 12 = 72. For perfect targets, 11 of the 12 choices are parallel (b = s ≠ 0) when source = target, reducing the count for the self-loop source by 11, giving 72 − 11 = 61. □

The ratio 61/72 ≈ 0.847 quantifies the *compositional constraint* imposed by the parallel-motion prohibition: perfect consonances are approximately 15% harder to reach than imperfect ones.

### 3.4 Voice-Swap Asymmetry

**Theorem 3.7** (`voice_swap_breaks_consonance`). *The involution i ↦ −i on ZMod 12 does not preserve the set of consonant intervals C = {0, 3, 4, 7, 8, 9}.*

*Proof sketch.* The image −7 ≡ 5 (mod 12), and 5 ∉ C. Specifically, the perfect fifth (7 semitones) maps to the perfect fourth (5 semitones), which is classified as dissonant in first-species counterpoint. □

**Remark 3.8.** This result formalizes the *asymmetric role of the bass voice* in counterpoint. If voice exchange (swapping which voice is higher) preserved consonance, then the bass and soprano would be interchangeable. The failure of this symmetry is what makes the bass voice privileged — a fact well-known empirically in music theory but here given a precise algebraic formulation.

---

## 4. The Voice-Leading Seminorm

### 4.1 Seminorm Properties

**Theorem 4.1** (`cost_seminorm_properties`). *The voice-leading cost function cost : (Fin n → ℤ) → ℤ is a seminorm on the ℤ-module of voice motions. Specifically:*

1. *Nonnegativity* (`cost_nonneg`): cost(m) ≥ 0 for all m.
2. *Subadditivity / Triangle inequality* (`cost_triangle`): cost(m₁ + m₂) ≤ cost(m₁) + cost(m₂).
3. *Absolute homogeneity* (`cost_abs_homogeneous`): cost(c · m) = |c| · cost(m) for all c ∈ ℤ.

*Proof sketch.* (1) follows from nonnegativity of absolute value. (2) is the pointwise triangle inequality |a + b| ≤ |a| + |b| summed over coordinates. (3) uses |c · mᵢ| = |c| · |mᵢ| summed over coordinates. □

**Theorem 4.2** (`cost_eq_zero_iff`). *cost(m) = 0 if and only if m = 0 (no voice moves).*

*Remark 4.3.* Since cost(m) = 0 ⟹ m = 0, the cost function is actually a *norm*, not merely a seminorm. We state it as a seminorm because the proof of the norm property factors naturally through the seminorm properties plus this characterization of the zero set.

**Theorem 4.4** (`cost_neg_eq`). *cost(−m) = cost(m). Voice-leading cost is invariant under retrograde (time reversal).*

### 4.2 The L¹-Lattice Identity

The voice-motion space Fin n → ℤ carries a natural distributive lattice structure via componentwise min (⊓) and max (⊔). The interaction of this lattice structure with the L¹ cost is captured by:

**Theorem 4.5** (`cost_meet_join_eq`). *For all voice motions m₁, m₂:*

$$\text{cost}(m_1 \sqcap m_2) + \text{cost}(m_1 \sqcup m_2) = \text{cost}(m_1) + \text{cost}(m_2)$$

*Proof sketch.* The identity reduces pointwise to |min(a, b)| + |max(a, b)| = |a| + |b| for integers a, b. This is verified by case analysis on the sign and ordering of a and b, then summed over all coordinates. □

**Corollary 4.6** (`cost_meet_le`, `cost_join_le`). *Both the lattice meet and join have cost bounded by the sum of costs:*

$$\text{cost}(m_1 \sqcap m_2) \leq \text{cost}(m_1) + \text{cost}(m_2)$$
$$\text{cost}(m_1 \sqcup m_2) \leq \text{cost}(m_1) + \text{cost}(m_2)$$

**Musical interpretation.** The L¹-lattice identity is a *conservation law*: decomposing two voice leadings into their componentwise minimum and maximum redistributes cost without creating or destroying it. In musical terms, the "cautious" composite motion (take the lesser motion in each voice) and the "bold" composite (take the greater motion) together cost exactly as much as the original pair. This constrains how lattice operations — natural "blending" operations on voice motions — interact with efficiency.

### 4.3 Ascending Motion Sublattice

**Definition 4.7.** A voice motion m is *ascending* if m(i) ≥ 0 for all voices i.

**Theorem 4.8** (`ascending_meet`, `ascending_join`). *The set of ascending motions is closed under lattice meet and join, forming a sublattice of (Fin n → ℤ, ⊓, ⊔).*

**Theorem 4.9** (`ascending_cost_eq_sum`). *For ascending motions, cost(m) = Σᵢ m(i). The absolute values become redundant.*

**Theorem 4.10** (`ascending_meet_cost_le`). *For ascending motions, cost(m₁ ⊓ m₂) ≤ cost(m₁). The lattice meet of two ascending motions is always at least as efficient as either input.*

**Musical interpretation.** Ascending motions — where every voice moves up — form a structurally closed family. The meet operation (componentwise minimum) produces a "most cautious" upward motion that is guaranteed to be smoother (lower cost) than either original. This gives a constructive method for generating efficient ascending voice leadings from pairs of known ones.

### 4.4 Optimal Voice Leading

**Theorem 4.11** (`optimal_exists_of_finset`). *For any nonempty finite set of feasible voice motions, an optimal (cost-minimizing) one exists.*

**Theorem 4.12** (`stepwise_cost_bound`). *Under a stepwise motion bound (each voice moves at most b semitones), the total cost is bounded by n · b.*

---

## 5. Discussion

### 5.1 Counterpoint as Constrained Graph Theory

Our results establish that first-species counterpoint, when formalized over ZMod 12, yields a directed graph with specific structural properties that distinguish it from arbitrary constraint systems:

- **Strong connectivity** ensures compositional freedom: every consonant goal is reachable.
- **Non-composability** ensures that this freedom is *local*: global paths require step-by-step verification, preventing composers from blindly concatenating local solutions.
- **The bottleneck theorem** quantifies the asymmetry between perfect and imperfect consonances at the level of hom-set cardinalities, providing a precise numerical measure of how much harder perfect consonances are to approach.

### 5.2 The Categorical Perspective

The failure of composability (Theorem 3.3) is the most significant result from the categorical viewpoint. In the proposed framing of counterpoint as a category, one might hope that consonant intervals form objects and permitted voice leadings form morphisms. Our result shows this fails: the morphism composition axiom is violated. The Counterpoint Quiver is genuinely a *quiver* (directed multigraph), not a category.

This failure is musically meaningful. If permitted voice leadings composed freely, a composer could plan arbitrarily long passages by ensuring each adjacent pair of intervals is connected by a permitted voice leading. The non-composability theorem shows this strategy fails — intermediate intervals matter — which matches compositional practice: counterpoint requires attention to every successive interval, not just local transitions.

### 5.3 Connections to Voice-Leading Geometry

The seminorm structure of voice-leading cost (Section 4) connects our work to Tymoczko's (2006, 2011) geometric theory of voice leading, which models voice-leading spaces as orbifolds with metrics. Our L¹-lattice identity (Theorem 4.5) appears to be new and adds a lattice-theoretic dimension absent from the geometric tradition. The ascending sublattice theorem (Section 4.3) gives a constructive method for generating efficient voice leadings that has no analogue in the continuous geometric framework.

### 5.4 Generalization to Microtonal Systems

The abstract CounterpointSystem n structure (Definition 2.1) enables investigation of counterpoint-like constraints in arbitrary equal temperaments. Natural questions include:

- For which n and which choices of C, P does the strong connectivity theorem hold?
- Is non-composability generic, or are there temperaments where permitted voice leadings *do* compose?
- How does the bottleneck ratio |Hom(−, p)| / |Hom(−, q)| vary with n?

These questions are computationally tractable for any specific n, C, P by exhaustive enumeration.

---

## 6. Future Work

1. **Higher species.** Extend the formalization to second, third, fourth, and fifth species counterpoint, introducing rhythmic subdivision and dissonance treatment.

2. **Multi-voice counterpoint.** The current framework handles two voices. Extending to three or more voices requires modeling voice leadings as n-tuples and constraints as predicates on all voice pairs — a substantially richer combinatorial object.

3. **The category of counterpoint systems.** Define morphisms between counterpoint systems (e.g., embeddings of ZMod n into ZMod m) and study functorial properties.

4. **Continuous relaxation.** Replace ZMod n with ℝ/ℤ to study voice leading in the continuous pitch-class space, connecting to Tymoczko's orbifold theory.

5. **Computational complexity.** What is the complexity of determining whether a sequence of target intervals admits a valid path of permitted voice leadings? The non-composability result suggests this is non-trivial even for two voices.

6. **Lattice width and optimal cost.** Conjecture: the optimal voice-leading cost for a counterpoint system with stepwise bound b and n voices is bounded by the lattice width of the feasible region, which is at most n · b. This is computationally testable.

---

## References

1. Fux, J. J. (1725). *Gradus ad Parnassum*. Vienna.
2. Lewin, D. (1987). *Generalized Musical Intervals and Transformations*. Yale University Press.
3. Tymoczko, D. (2006). The geometry of musical chords. *Science*, 313(5783), 72–74.
4. Tymoczko, D. (2011). *A Geometry of Music*. Oxford University Press.
5. Fiore, T. M., & Satyendra, R. (2005). Generalized contextual groups. *Music Theory Online*, 11(3).
6. Mazzola, G. (2002). *The Topos of Music*. Birkhäuser.
7. Cohn, R. (1998). Introduction to neo-Riemannian theory. *Journal of Music Theory*, 42(2), 167–180.

---

## Appendix: Catalog of Formal Results

| # | Name | Statement Summary |
|---|------|------------------|
| 1 | `exists_permitted_voice_leading` | Strong connectivity of the Counterpoint Quiver |
| 2 | `non_composability` | Permitted voice leadings fail to compose |
| 3 | `perfect_self_loop_unique` | Perfect consonances have exactly 1 self-loop |
| 4 | `imperfect_self_loops_all` | Imperfect consonances have exactly 12 self-loops |
| 5 | `voice_swap_breaks_consonance` | Voice exchange breaks consonance (7 ↦ 5) |
| 6 | `total_permitted_to_perfect` | 61 incoming voice leadings to perfect consonances |
| 7 | `total_permitted_to_imperfect` | 72 incoming voice leadings to imperfect consonances |
| 8 | `cost_triangle` | Triangle inequality for voice-leading cost |
| 9 | `cost_eq_zero_iff` | Cost is zero iff motion is identity |
| 10 | `cost_meet_join_eq` | L¹-lattice conservation identity |
| 11 | `cost_seminorm_properties` | Cost is a seminorm on voice motions |
| 12 | `ascending_meet` / `ascending_join` | Ascending motions form a sublattice |
| 13 | `parallel_preserves_interval` | Parallel motion preserves intervals |
| 14 | `nonparallel_changes_interval` | Non-parallel motion changes intervals |
| 15 | `optimal_exists_of_finset` | Optimal voice leading exists for finite feasible sets |
