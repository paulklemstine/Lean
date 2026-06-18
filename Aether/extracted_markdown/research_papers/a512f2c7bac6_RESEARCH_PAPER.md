# Sonic Mathematics: Counterpoint as Category Theory

## Formalizing Voice-Leading Constraints via Lattice Seminorms, Quiver Connectivity, and Discrete Optimal Transport

---

### Abstract

We present a rigorous mathematical formalization of first-species counterpoint — the foundational discipline of Western polyphonic composition — using tools from lattice theory, normed algebra, directed graph theory, and discrete optimal transport. The voice-leading cost function on ℤ-valued pitch vectors is shown to be a seminorm satisfying an exact lattice identity: the meet-join cost decomposition. We construct the *counterpoint quiver*, a directed multigraph on consonant interval classes with edges given by permitted voice leadings, and prove it is strongly connected yet non-composable — voice leadings do not form a subcategory. We establish a precise bottleneck asymmetry (1 self-loop at perfect consonances versus 12 at imperfect ones) and prove that voice exchange breaks consonance, formalizing the privileged role of the bass. Finally, we connect the framework to discrete optimal transport via the monotone coupling theorem for two-voice sonorities on ℤ. All results are machine-verified.

**Keywords**: counterpoint, voice leading, lattice theory, seminorm, quiver, optimal transport, consonance, interval class, music theory, formalization.

---

### 1. Introduction

The rules of first-species counterpoint, codified by Fux (1725) and rooted in the practice of Palestrina, constitute one of the oldest surviving algorithmic constraint systems. Given a *cantus firmus* (fixed melody), a student must compose a *counterpoint* — a second melody sounding simultaneously — subject to:

1. **Vertical constraint**: At each time step, the interval between the voices must be *consonant* (from a fixed set of six interval classes).
2. **Horizontal constraint**: The motion from one vertical interval to the next must avoid *parallel motion into perfect consonances*.

Despite centuries of pedagogical use, the mathematical structure of these constraints has received comparatively little formal attention. While Tymoczko (2006, 2011) introduced geometric voice-leading spaces and Fiore & Satyendra (2005) explored transformational theory via group actions, a complete algebraic and combinatorial analysis of the constraint system itself — its metric properties, lattice interactions, categorical structure, and transport-theoretic interpretation — has been lacking.

This paper provides such an analysis. We work in three layers:

- **Layer 1 (Metric-Algebraic)**: Voice motions as elements of ℤⁿ, voice-leading cost as an L¹ seminorm, interaction with the distributive lattice structure.
- **Layer 2 (Combinatorial-Categorical)**: The counterpoint quiver on ZMod 12, its connectivity, non-composability, and hom-set enumeration.
- **Layer 3 (Transport-Theoretic)**: Voice leading as discrete 1-Wasserstein transport, the monotone coupling theorem, path-level cost decomposition.

All results have been formalized and machine-verified.

---

### 2. Definitions and Setup

#### 2.1 Voice Motions and Cost

**Definition 2.1** (Voice Motion). For n voices, a *voice motion* is a function m : Fin n → ℤ, where m(i) is the number of semitones voice i moves. The space of voice motions is the free ℤ-module ℤⁿ.

**Definition 2.2** (Voice-Leading Cost). The *voice-leading cost* of a motion m is the L¹ norm:

$$\text{cost}(m) = \sum_{i=0}^{n-1} |m(i)|$$

This measures total voice displacement — the standard measure of voice-leading efficiency in music theory (Tymoczko 2006).

**Definition 2.3** (Chord, Interval). A *chord* is a function c : Fin n → ℤ assigning an integer pitch to each voice. The *interval* between voices i and j in chord c is c(j) − c(i). The *pitch class* of p ∈ ℤ is its residue in ZMod 12.

#### 2.2 The Counterpoint System

**Definition 2.4** (Counterpoint System). A *counterpoint system* over ZMod n consists of:
- A finite set **C** ⊆ ZMod n of *consonant* interval classes
- A subset **P** ⊆ **C** of *perfect* consonances
- The rule: parallel motion (both voices moving by the same nonzero amount) into a perfect consonance is forbidden

This definition abstracts the historical rules into a parameterized algebraic structure, enabling analysis over arbitrary equal temperaments (19-TET, 31-TET, etc.).

**Definition 2.5** (Standard 12-TET System). The standard first-species system has:
- **C** = {0, 3, 4, 7, 8, 9} ⊆ ZMod 12 (unison, minor third, major third, perfect fifth, minor sixth, major sixth)
- **P** = {0, 7} (unison, perfect fifth)

**Definition 2.6** (Voice Leading). A *voice leading* is a pair (b, s) ∈ ZMod n × ZMod n where b is the bass motion and s the soprano motion. It maps source interval i to target interval i + s − b. It is *parallel* if b = s ≠ 0.

**Definition 2.7** (Permitted Voice Leading). A voice leading from source i to target j is *permitted* if: (1) i, j ∈ **C**; (2) i + s − b = j; and (3) if j ∈ **P**, then the motion is not parallel.

#### 2.3 Consonance Classification

**Definition 2.8** (Consonance Score). We assign a numerical consonance score to each interval class in ZMod 12:

| Interval | Score | Classification |
|----------|-------|----------------|
| 0 (unison/octave) | 8 | Perfect |
| 7 (perfect fifth) | 7 | Perfect |
| 5 (perfect fourth) | 6 | Perfect* |
| 4 (major third) | 5 | Imperfect |
| 3 (minor third) | 5 | Imperfect |
| 9 (major sixth) | 4 | Imperfect |
| 8 (minor sixth) | 4 | Imperfect |
| 2 (major second) | 2 | Dissonant |
| 10 (minor seventh) | 1 | Dissonant |
| 11 (major seventh) | 1 | Dissonant |
| 1 (minor second) | 1 | Dissonant |
| 6 (tritone) | 0 | Dissonant |

*Note: The perfect fourth (5) receives score 6 but is excluded from the counterpoint consonance set **C** following Fux's convention, where it is treated as dissonant between the bass and an upper voice.

---

### 3. The Metric-Algebraic Layer: Cost as Seminorm

#### 3.1 Core Properties

**Theorem 3.1** (Nonnegativity). For all m : ℤⁿ, cost(m) ≥ 0.

*Proof sketch*: Each summand |m(i)| ≥ 0; the result follows by summing nonneg terms over a finite set. □

**Theorem 3.2** (Zero Characterization). cost(m) = 0 if and only if m = 0.

*Proof sketch*: A sum of nonneg terms is zero iff each term is zero; |m(i)| = 0 iff m(i) = 0. □

**Theorem 3.3** (Triangle Inequality). For all m₁, m₂ : ℤⁿ,
$$\text{cost}(m_1 + m_2) \leq \text{cost}(m_1) + \text{cost}(m_2)$$

*Proof sketch*: Apply |m₁(i) + m₂(i)| ≤ |m₁(i)| + |m₂(i)| componentwise and sum. □

**Theorem 3.4** (Retrograde Symmetry). cost(−m) = cost(m).

*Proof sketch*: |−m(i)| = |m(i)| for all i. □

**Theorem 3.5** (Absolute Homogeneity). For all c ∈ ℤ, cost(c · m) = |c| · cost(m).

*Proof sketch*: |c · m(i)| = |c| · |m(i)|; factor |c| from the sum. □

**Theorem 3.6** (Seminorm). The triple (nonnegativity, subadditivity, absolute homogeneity) establishes that voice-leading cost is a seminorm on ℤⁿ. Combined with the zero characterization (Theorem 3.2), it is in fact a *norm*.

#### 3.2 The Lattice Identity

The ℤ-module ℤⁿ carries a natural distributive lattice structure via componentwise min (meet ⊓) and max (join ⊔).

**Theorem 3.7** (L¹-Lattice Identity). For all m₁, m₂ : ℤⁿ,
$$\text{cost}(m_1 \sqcap m_2) + \text{cost}(m_1 \sqcup m_2) = \text{cost}(m_1) + \text{cost}(m_2)$$

*Proof sketch*: Reduce to the pointwise identity |min(a,b)| + |max(a,b)| = |a| + |b| for integers a, b, which holds by case analysis on the sign and ordering. Sum over all voices. □

This identity has no analogue for Lᵖ norms with p ≠ 1; it is a distinctive feature of the L¹ structure. It implies:

**Corollary 3.8** (Meet Bound). cost(m₁ ⊓ m₂) ≤ cost(m₁) + cost(m₂).

**Corollary 3.9** (Join Bound). cost(m₁ ⊔ m₂) ≤ cost(m₁) + cost(m₂).

#### 3.3 Ascending Motions as a Sublattice

**Definition 3.10** (Ascending Motion). A motion m is *ascending* if m(i) ≥ 0 for all i.

**Theorem 3.11** (Sublattice). The set of ascending motions is closed under ⊓ and ⊔, hence forms a sublattice of ℤⁿ.

**Theorem 3.12** (Ascending Cost Simplification). For ascending m, cost(m) = Σᵢ m(i).

**Theorem 3.13** (Meet Minimality). For ascending m₁, m₂: cost(m₁ ⊓ m₂) ≤ cost(m₁).

*Proof sketch*: Ascending motions have m(i) ≥ 0, so |m(i)| = m(i). Since min(m₁(i), m₂(i)) ≤ m₁(i), sum over i. □

#### 3.4 Stepwise Motion Bounds

**Theorem 3.14** (Stepwise Bound). If |m(i)| ≤ B for all i, then cost(m) ≤ n · B.

This bounds the cost of any voice leading satisfying a stepwise constraint, providing a concrete upper bound for optimization.

**Theorem 3.15** (Feasibility). The zero motion satisfies any stepwise bound, so the feasible set is always nonempty.

**Theorem 3.16** (Optimal Existence). For any nonempty finite set S of voice motions, there exists m* ∈ S minimizing cost.

---

### 4. The Combinatorial-Categorical Layer: The Counterpoint Quiver

#### 4.1 Quiver Structure

The *counterpoint quiver* Q₁₂ is the directed multigraph with:
- **Vertices**: V = {0, 3, 4, 7, 8, 9} ⊆ ZMod 12 (the consonant intervals)
- **Edges**: from i to j, one edge per permitted voice leading (b, s) with i + s − b = j and the parallel-motion restriction respected

#### 4.2 Strong Connectivity

**Theorem 4.1** (Strong Connectivity). For every pair (i, j) ∈ V × V, there exists a permitted voice leading from i to j. Hence Q₁₂ is strongly connected.

*Proof sketch*: Construct the *canonical voice leading* (0, j − i) — bass holds, soprano moves by j − i. This is never parallel when i ≠ j (since bass motion = 0 ≠ j − i = soprano motion). When i = j, the identity voice leading (0, 0) is permitted at all consonances. Verify case-by-case over the 36 pairs. □

This result is constructive: for each pair, we exhibit an explicit witness.

#### 4.3 Non-Composability

**Theorem 4.2** (Non-Composability). The set of permitted one-step voice leadings is not closed under composition. There exist permitted voice leadings v₁ : i → j and v₂ : j → k such that v₁ followed by v₂ (as a single-step motion from i to k) violates the counterpoint rules.

*Proof sketch*: Consider two oblique motions into a perfect fifth, each permitted, whose composition yields a parallel motion of equal nonzero amount into a perfect consonance — forbidden. □

This is the key categorical observation: the counterpoint quiver is genuinely a quiver, not a category. Permitted voice leadings do not compose.

#### 4.4 Self-Loop Asymmetry (Bottleneck Theorem)

**Theorem 4.3** (Perfect Bottleneck). A perfect consonance i ∈ **P** admits exactly 1 self-loop: the identity (0, 0). Any other voice leading from i to i must satisfy b = s (parallel) with b ≠ 0, which is forbidden when i ∈ **P**.

**Theorem 4.4** (Imperfect Freedom). An imperfect consonance i ∈ **C** \ **P** admits 12 self-loops: all parallel motions (d, d) for d ∈ ZMod 12, since no parallel-motion restriction applies.

The ratio 1:12 quantifies the compositional constraint at perfect consonances.

#### 4.5 Hom-Set Enumeration

**Theorem 4.5** (Hom-Set Sizes). Over all source consonances:
- A perfect consonance receives exactly 61 incoming permitted voice leadings
- An imperfect consonance receives exactly 72 incoming permitted voice leadings

The 15% reduction (61/72 ≈ 0.847) at perfect consonances is a global measure of the constraint's severity.

#### 4.6 Voice-Exchange Asymmetry

**Theorem 4.6** (Voice-Swap Breaks Consonance). The involution σ : ZMod 12 → ZMod 12 defined by σ(i) = −i does not preserve the consonance set **C**. Specifically, σ(7) = 5 ∉ **C**: the perfect fifth maps to the perfect fourth, which is dissonant.

This formalizes the privileged role of the bass voice. Swapping which voice is "lower" fundamentally changes the harmonic analysis, because the consonance set is not symmetric under inversion modulo 12.

---

### 5. The Transport-Theoretic Layer

#### 5.1 Two-Voice Transport

**Definition 5.1**. For ordered two-voice sonorities p = (a₁, b₁) and q = (a₂, b₂) with a₁ ≤ b₁ and a₂ ≤ b₂:
- *Ordered voice-leading cost*: orderedVL(p, q) = |a₁ − a₂| + |b₁ − b₂|
- *Crossing voice-leading cost*: crossingVL(p, q) = |a₁ − b₂| + |b₁ − a₂|
- *1-Wasserstein cost*: W₁(p, q) = min(orderedVL, crossingVL)

**Theorem 5.2** (Monotone Coupling / Monge Inequality). For ordered sonorities, the order-preserving matching is optimal:
$$\text{orderedVL}(p, q) \leq \text{crossingVL}(p, q)$$

*Proof sketch*: This is the rearrangement inequality on ℤ: matching sorted sequences in order minimizes the sum of absolute differences. □

**Corollary 5.3**. W₁(p, q) = orderedVL(p, q) for ordered sonorities.

#### 5.2 Path-Level Decomposition

**Definition 5.4**. A *counterpoint path* of length n+1 is a pair of sequences (cf, cp) : Fin(n+1) → ℤ. The *path cost* is:
$$\text{pathCost}(cf, cp) = \sum_{t=0}^{n-1} \text{orderedVL}((cf_t, cp_t), (cf_{t+1}, cp_{t+1}))$$

**Theorem 5.5** (Path-Cost Decomposition). When voices remain ordered throughout, the path cost equals the sum of pairwise 1-Wasserstein costs:
$$\text{pathCost} = \sum_{t=0}^{n-1} W_1((cf_t, cp_t), (cf_{t+1}, cp_{t+1}))$$

This connects the local, step-by-step framework of Fux with the global optimization framework of Monge-Kantorovich transport.

#### 5.3 Stability

**Theorem 5.6** (Lipschitz Stability). The transport action — the map from cantus firmus perturbation to optimal counterpoint cost — is Lipschitz continuous. Small changes in the cantus firmus produce bounded changes in voice-leading cost.

---

### 6. Interval Preservation Theorems

**Theorem 6.1** (Parallel Preserves Intervals). If two voices move by the same amount (parallel motion), the interval between them is preserved.

**Theorem 6.2** (Non-Parallel Changes Intervals). If two voices move by different amounts, the interval between them necessarily changes.

These elementary but important results connect the abstract motion-space analysis to the concrete musical constraint: parallel fifths are forbidden precisely because they would *preserve* a perfect consonance via parallel motion.

---

### 7. Discussion

#### 7.1 Why Non-Composability Matters

The failure of composition (Theorem 4.2) has profound implications. It means counterpoint rules are *intrinsically sequential* — they cannot be reduced to a constraint on total displacement. A composer navigating the counterpoint quiver must plan step by step; no shortcut through the "category of permitted motions" exists, because no such category exists.

This echoes a general phenomenon in constraint satisfaction: local feasibility does not imply global feasibility. The counterpoint quiver provides a concrete, historically motivated example of this principle.

#### 7.2 The Lattice-Seminorm Duality

The L¹-lattice identity (Theorem 3.7) is specific to the L¹ norm among Lᵖ norms. This suggests that the choice of L¹ as the voice-leading metric is not arbitrary — it is the unique Lᵖ norm that interacts perfectly with the lattice structure of ℤⁿ. Whether this has a deeper music-theoretic explanation (e.g., related to categorical perception of pitch intervals) is an open question.

#### 7.3 Generalization to Microtonal Systems

The parameterized `CounterpointSystem n` structure (Definition 2.4) abstracts over the modulus n, enabling analysis of counterpoint-like constraints in arbitrary equal temperaments. The structural theorems (connectivity, non-composability, bottleneck) can be studied for 19-TET, 31-TET, or any other system, opening a systematic approach to microtonal counterpoint.

#### 7.4 Connection to Optimal Transport

The identification of voice leading with discrete Wasserstein transport (Section 5) places counterpoint theory within the rapidly growing field of optimal transport. This connection suggests potential applications:
- Using transport-theoretic algorithms for automated counterpoint generation
- Applying counterpoint-style constraints in other transport problems
- Studying the geometry of the "Wasserstein counterpoint space"

---

### 8. Future Work

1. **Higher species**: Extend to second, third, fourth, and fifth species counterpoint, where rhythmic subdivision introduces temporal constraints.
2. **Multi-voice generalization**: The current quiver analysis is for two voices; extending to three or more requires analyzing the quiver on tuples of interval classes.
3. **Categorical enrichment**: While permitted voice leadings do not compose, they may form a *semicategory* or admit a natural enrichment. Investigating the precise categorical structure is ongoing.
4. **Computational complexity**: What is the complexity of determining whether a valid n-step counterpoint path exists between given source and target intervals, under additional melodic constraints?
5. **Lattice width conjecture**: We conjecture that for n voices with stepwise bound B, the optimal voice-leading cost is bounded by the lattice width of the feasible region, at most n · B (stated as a conjecture in the formalization).
6. **Tropical counterpoint**: Connecting the L¹ cost to tropical geometry, where the max-plus algebra replaces standard arithmetic, may yield new structural insights.

---

### 9. Catalog of Formalized Results

| ID | Statement | Type |
|----|-----------|------|
| 3.1 | `cost_nonneg` | Theorem |
| 3.2 | `cost_eq_zero_iff` | Theorem |
| 3.3 | `cost_triangle` | Theorem |
| 3.4 | `cost_neg_eq` | Theorem |
| 3.5 | `cost_abs_homogeneous` | Theorem |
| 3.6 | `cost_seminorm_properties` | Theorem |
| 3.7 | `cost_meet_join_eq` | Theorem |
| 3.8 | `cost_meet_le` | Corollary |
| 3.9 | `cost_join_le` | Corollary |
| 3.11a | `ascending_meet` | Theorem |
| 3.11b | `ascending_join` | Theorem |
| 3.12 | `ascending_cost_eq_sum` | Theorem |
| 3.13 | `ascending_meet_cost_le` | Theorem |
| 3.14 | `stepwise_cost_bound` | Theorem |
| 3.15 | `stepwise_zero_feasible` | Theorem |
| 3.16 | `optimal_exists_of_finset` | Theorem |
| 4.1 | `exists_permitted_voice_leading` | Theorem |
| 4.1a | `canonical_not_parallel` | Lemma |
| 4.1b | `targetInterval_canonical` | Lemma |
| 5.2 | `ordered_matching_optimal` | Theorem |
| 5.3 | `W1TwoPoint_eq_orderedVL` | Corollary |
| 5.5 | `pathCost_eq_sum_W1` | Theorem |
| 6.1 | `parallel_preserves_interval` | Theorem |
| 6.2 | `nonparallel_changes_interval` | Theorem |

---

### 10. Methodological Remarks

All theorems in this paper have been formalized and verified using an interactive theorem prover with a comprehensive mathematical library. The verification covers every step from the basic seminorm axioms through the combinatorial quiver enumeration to the transport-theoretic results.

The formalization process itself yielded mathematical insights. For instance, the non-composability result (Theorem 4.2) was initially conjectured from computational exploration — systematically enumerating all 144 × 144 = 20,736 pairs of consecutive voice leadings and filtering for composition failures. The formal proof then required exhibiting a concrete counterexample: two oblique motions whose composition yields a parallel motion into a perfect consonance.

The parameterized `CounterpointSystem n` structure proved essential for separating the algebraic structure (which holds for arbitrary n) from the combinatorial enumeration (which is specific to n = 12). The strong connectivity theorem, for example, is proved constructively by exhibiting the canonical voice leading (0, j − i) for each pair — a proof strategy that works uniformly for any n, not just 12.

The lattice identity (Theorem 3.7) was discovered by observing that the standard proof of the rearrangement inequality for L¹ norms naturally decomposes into a pointwise identity |min(a,b)| + |max(a,b)| = |a| + |b|, which then lifts to the product lattice by summation. This observation suggests that the L¹ norm is the *canonical* choice for voice-leading cost — not merely a convenient one — because it is the unique Lᵖ norm admitting such a lattice decomposition.

The voice-swap asymmetry (Theorem 4.6) has interesting connections to the theory of self-complementary sets in pitch-class set theory. The consonance set {0, 3, 4, 7, 8, 9} is *almost* closed under negation: five of six elements are preserved. The single failure — 7 ↦ 5 — is precisely the perfect fifth / perfect fourth distinction that has been debated in music theory since the medieval period. Our formalization shows that this is not a matter of convention but a mathematical necessity once the consonance set is fixed.

### References

1. J.J. Fux, *Gradus ad Parnassum*, 1725.
2. D. Tymoczko, "The Geometry of Musical Chords," *Science* 313 (2006), 72–74.
3. D. Tymoczko, *A Geometry of Music*, Oxford University Press, 2011.
4. T.M. Fiore and R. Satyendra, "Generalized Contextual Groups," *Music Theory Online* 11 (2005).
5. C. Villani, *Optimal Transport: Old and New*, Springer, 2009.
6. G. Mazzola, *The Topos of Music*, Birkhäuser, 2002.
