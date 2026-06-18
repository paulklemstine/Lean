# Sonic Mathematics: Counterpoint as Category Theory

## The Counterpoint Quiver, Voice-Leading Seminorms, and Lattice-Cost Duality

---

**Abstract.** We formalize Johann Joseph Fux's first-species counterpoint rules as a directed multigraph — the *Counterpoint Quiver* — whose vertices are consonant intervals modulo 12 semitones and whose edges are voice leadings permitted by the parallel-motion prohibition. We prove five structural theorems: (1) **Strong connectivity**: between any two consonant intervals, at least one permitted voice leading exists; (2) **Non-composability**: permitted voice leadings fail to compose, hence do not form a subcategory of the free category; (3) **Perfect-consonance bottleneck**: perfect consonances admit exactly 1 self-loop versus 12 for imperfect consonances, and receive 61 incoming arrows versus 72; (4) **Voice-swap asymmetry**: the involution *i ↦ −i* on ℤ/12ℤ does not preserve consonance; (5) **L¹-lattice identity**: voice-leading cost (the L¹ seminorm on motion vectors) distributes perfectly over lattice meet and join. The framework generalizes to arbitrary equal temperaments via a parameterized `CounterpointSystem n` structure. We prove the cost function is a seminorm, ascending motions form a sublattice, and optimal voice leadings exist for finite constraint sets. These results bridge music theory, order theory, and categorical logic, providing rigorous foundations for computational analysis of contrapuntal structure.

**Keywords:** counterpoint, voice leading, category theory, quiver, seminorm, lattice theory, pitch-class arithmetic, ZMod 12

---

## 1. Introduction

### 1.1 Background and Motivation

Musical counterpoint — the art of combining independent melodic lines — has been the subject of systematic rule codification since at least the Renaissance. Fux's *Gradus ad Parnassum* (1725) remains the canonical pedagogical text, organizing counterpoint into five "species" of increasing rhythmic complexity. First-species counterpoint, the simplest, requires note-against-note motion where every vertical simultaneity must be consonant and parallel motion into perfect consonances (unisons, fifths, octaves) is forbidden.

Despite the long history of mathematical approaches to music — from Pythagorean tuning theory through Euler's *Tentamen* (1739) to the pitch-class set theory of Forte (1973) and the transformational theory of Lewin (1987) — the *combinatorial structure of permitted voice leadings* in counterpoint has received surprisingly little rigorous treatment. Tymoczko (2011) introduced voice-leading geometry using continuous spaces, but the discrete, combinatorial structure of the Fux constraints admits a different and complementary analysis.

### 1.2 Contributions

We introduce two interlocking mathematical frameworks:

1. **The Counterpoint Quiver** — a directed multigraph on consonant interval classes, with edges given by permitted voice leadings. We prove structural theorems about connectivity, non-composability, and quantitative asymmetry.

2. **The Voice-Leading Seminorm** — the L¹ cost function on voice motion vectors, shown to be a seminorm with a remarkable lattice-cost duality identity.

Both frameworks are parameterized over arbitrary equal temperaments, enabling comparative analysis across tuning systems.

### 1.3 Related Work

- **Tymoczko (2006, 2011):** Voice-leading geometry in continuous orbifold spaces. Our work is complementary: we study discrete permitted moves rather than continuous distances.
- **Mazzola (2002):** Topos-theoretic approach to music theory. Our categorical perspective is more concrete and computationally explicit.
- **Callender, Quinn, Tymoczko (2008):** Generalized voice-leading spaces. We add the constraint dimension (which moves are *permitted*) to the distance dimension.
- **Cohn (1998):** Neo-Riemannian transformations as a group acting on triads. Our quiver is not a group — non-composability is a central theorem.

---

## 2. Definitions

### 2.1 The Counterpoint System

**Definition 2.1** (Counterpoint System). A *counterpoint system of order n* is a tuple (C, P, n) where:
- n ≥ 1 is a positive natural number (the number of pitch classes),
- C ⊆ ℤ/nℤ is a nonempty finite set of *consonant intervals*,
- P ⊆ C is a nonempty finite set of *perfect consonances*, with P ⊊ C (there exists at least one imperfect consonance).

The formal structure `CounterpointSystem n` packages these data with proof obligations: `perfect_sub : P ⊆ C`, `consonant_nonempty`, `perfect_nonempty`, and `has_imperfect`.

**Definition 2.2** (Standard 12-TET System). The *standard system* `standard12` has:
- C = {0, 3, 4, 7, 8, 9} ⊂ ℤ/12ℤ (unison, minor third, major third, perfect fifth, minor sixth, major sixth),
- P = {0, 7} ⊂ ℤ/12ℤ (unison/octave and perfect fifth).

### 2.2 Voice Leadings

**Definition 2.3** (Voice Leading). A *voice leading* in ℤ/nℤ is a pair vl = (b, s) ∈ (ℤ/nℤ)² specifying the bass motion b and soprano motion s.

**Definition 2.4** (Target Interval). Given source interval i ∈ ℤ/nℤ and voice leading (b, s), the *target interval* is:

$$\tau(i, b, s) = i + s - b$$

**Definition 2.5** (Parallel Motion). A voice leading (b, s) exhibits *parallel motion* if b = s and b ≠ 0.

**Definition 2.6** (Permitted Voice Leading). A voice leading vl from source i to target j is *permitted* in system (C, P, n) if:
1. i ∈ C and j ∈ C,
2. τ(i, vl) = j,
3. ¬(j ∈ P ∧ vl is parallel).

### 2.3 Voice Motion Cost

**Definition 2.7** (Voice Motion). For n voices, a *voice motion* is a function m : Fin(n) → ℤ. The *voice-leading cost* is the L¹ norm:

$$\text{Cost}(m) = \sum_{i=0}^{n-1} |m(i)|$$

**Definition 2.8** (Consonance Score). A function σ : ℤ/12ℤ → ℕ assigns consonance scores: unison (8), fifth (7), fourth (6), thirds (5), sixths (4), second (2), sevenths (1), tritone (0).

**Definition 2.9** (Ascending Motion). A voice motion m is *ascending* if m(i) ≥ 0 for all i.

---

## 3. Main Results: The Counterpoint Quiver

### 3.1 Strong Connectivity

**Theorem 3.1** (`exists_permitted_voice_leading`). *For any consonant intervals i, j ∈ C in the standard 12-TET system, there exists a permitted voice leading from i to j.*

*Proof sketch.* For i ≠ j, use the **canonical voice leading** (0, j − i) — bass holds, soprano moves. Since bass motion is 0, the motion is not parallel (parallel requires both voices to move identically and nonzero). The target interval is i + (j − i) − 0 = j. For i = j, use the identity voice leading (0, 0); verified by case analysis on all six consonant intervals. □

**Corollary 3.2.** The Counterpoint Quiver is strongly connected as a directed graph. Every consonant interval can reach every other in a single step.

### 3.2 Non-Composability

**Theorem 3.3** (`non_composability`). *The set of permitted one-step voice leadings in the standard 12-TET system is not closed under composition. There exist consonant intervals i, j, k and permitted voice leadings vl₁ : i → j, vl₂ : j → k such that the composed voice leading (vl₁.bass + vl₂.bass, vl₁.soprano + vl₂.soprano) is not permitted from i to k.*

*Proof sketch.* Construct an explicit counterexample. Choose voice leadings where each individual step avoids parallel motion into a perfect consonance, but the net motion (sum of bass motions, sum of soprano motions) constitutes parallel motion into a perfect consonance. This is possible because the parallel-motion check is not additive: two non-parallel motions can sum to a parallel one. □

**Corollary 3.4.** Permitted voice leadings do not form a subcategory of the free category on the Counterpoint Quiver. The system is inherently non-algebraic.

### 3.3 Perfect-Consonance Bottleneck

**Theorem 3.5** (`perfect_self_loop_unique`). *A perfect consonance in the standard 12-TET system admits exactly 1 self-loop: the identity voice leading (0, 0).*

*Proof.* A self-loop on interval p ∈ P is a voice leading (b, s) with p + s − b = p, hence s = b. If b ≠ 0, then s = b ≠ 0, making the motion parallel into a perfect consonance — forbidden. Hence b = s = 0. □

**Theorem 3.6** (`imperfect_self_loops_all`). *An imperfect consonance admits exactly 12 self-loops (all voice leadings with equal bass and soprano motion).*

*Proof.* For imperfect consonance q ∉ P, any voice leading (b, b) maps q to q + b − b = q. The parallel-motion condition (q ∈ P ∧ b = s ∧ b ≠ 0) fails because q ∉ P. All 12 choices of b ∈ ℤ/12ℤ yield distinct permitted self-loops. □

**Corollary 3.7.** The self-loop ratio is 1:12, a twelve-fold asymmetry between perfect and imperfect consonances.

### 3.4 Hom-Set Cardinalities

**Theorem 3.8** (`total_permitted_to_perfect`). *Each perfect consonance receives exactly 61 permitted voice leadings from all consonant sources combined.*

**Theorem 3.9** (`total_permitted_to_imperfect`). *Each imperfect consonance receives exactly 72 permitted voice leadings from all consonant sources combined.*

The 72 − 61 = 11 deficit (≈15%) quantifies the compositional constraint imposed by the parallel-motion rule on perfect consonances.

### 3.5 Voice-Swap Asymmetry

**Theorem 3.10** (`voice_swap_breaks_consonance`). *The involution i ↦ −i on ℤ/12ℤ does not preserve the consonant set {0, 3, 4, 7, 8, 9}. Specifically, 7 ↦ 5, and 5 ∉ {0, 3, 4, 7, 8, 9}.*

*Proof.* Direct computation: −7 ≡ 5 (mod 12), and 5 ∉ C. □

This formalizes the asymmetric role of the bass voice in counterpoint. The perfect fourth (interval 5) is the inversion of the perfect fifth (interval 7), yet only the fifth is consonant when measured upward from the bass.

---

## 4. Main Results: The Voice-Leading Seminorm

### 4.1 Seminorm Properties

**Theorem 4.1** (`cost_seminorm_properties`). *The voice-leading cost function satisfies:*
1. *Nonnegativity*: Cost(m) ≥ 0 for all m.
2. *Triangle inequality* (`cost_triangle`): Cost(m₁ + m₂) ≤ Cost(m₁) + Cost(m₂).
3. *Absolute homogeneity* (`cost_abs_homogeneous`): Cost(c · m) = |c| · Cost(m) for all c ∈ ℤ.

**Theorem 4.2** (`cost_eq_zero_iff`). *Cost(m) = 0 if and only if m(i) = 0 for all i. Hence the cost is in fact a norm.*

### 4.2 The L¹-Lattice Identity

The space of voice motions Fin(n) → ℤ carries a distributive lattice structure under componentwise min (⊓) and max (⊔).

**Theorem 4.3** (`cost_meet_join_eq`). *For all voice motions m₁, m₂:*

$$\text{Cost}(m_1 \sqcap m_2) + \text{Cost}(m_1 \sqcup m_2) = \text{Cost}(m_1) + \text{Cost}(m_2)$$

*Proof sketch.* Reduce to the pointwise identity |min(a,b)| + |max(a,b)| = |a| + |b| for integers, then sum over all voice indices. The pointwise identity follows by case analysis on the sign and ordering of a and b. □

**Corollary 4.4** (`cost_meet_le`, `cost_join_le`). *Both Cost(m₁ ⊓ m₂) and Cost(m₁ ⊔ m₂) are at most Cost(m₁) + Cost(m₂).*

### 4.3 Ascending Motion Sublattice

**Theorem 4.5** (`ascending_meet`, `ascending_join`). *The set of ascending motions {m | ∀i, m(i) ≥ 0} is closed under ⊓ and ⊔, hence forms a sublattice.*

**Theorem 4.6** (`ascending_cost_eq_sum`). *For ascending m, Cost(m) = Σᵢ m(i).*

**Theorem 4.7** (`ascending_meet_cost_le`). *For ascending m₁, m₂: Cost(m₁ ⊓ m₂) ≤ Cost(m₁).* That is, the lattice meet never increases cost within the ascending sublattice.

### 4.4 Optimal Voice Leading Existence

**Theorem 4.8** (`optimal_exists_of_finset`). *Given a nonempty finite set S of voice motions, there exists m* ∈ S minimizing Cost over S.*

### 4.5 Interval Preservation

**Theorem 4.9** (`parallel_preserves_interval`). *Parallel motion preserves the interval between the moving voices.*

**Theorem 4.10** (`nonparallel_changes_interval`). *Non-parallel motion necessarily changes the interval.*

These two theorems justify the contrapuntal intuition: parallel motion "freezes" intervals, while independent motion is the mechanism of intervallic change.

### 4.6 Stepwise Bounds

**Theorem 4.11** (`stepwise_cost_bound`). *Under a stepwise bound |m(i)| ≤ B for all i, the total cost satisfies Cost(m) ≤ n · B.*

**Theorem 4.12** (`stepwise_zero_feasible`). *The zero motion satisfies any stepwise bound, proving feasibility is nonempty.*

---

## 5. The `CounterpointSystem n` Abstraction

A key design choice is the parameterization over arbitrary *n* (the number of pitch classes in the equal temperament). This enables:

### 5.1 Microtonal Counterpoint Systems

For 19-TET (*n* = 19), the consonant intervals would be those closest to just-intonation ratios: {0, 5, 6, 11, 13, 14} (approximations of unison, minor third, major third, fifth, minor sixth, major sixth). The `CounterpointSystem 19` structure can instantiate these and the same structural theorems apply.

For 31-TET (*n* = 31), the finer division of the octave yields closer approximations to just intonation, and the consonant set expands. The quiver structure and bottleneck analysis would differ quantitatively.

### 5.2 Structural Theorems at General n

Many results hold at the level of `CounterpointSystem n` without specializing to *n* = 12:
- The canonical voice leading construction (Theorem 3.1) works for any *n*.
- The self-loop analysis (Theorems 3.5–3.6) generalizes: perfect consonances always have exactly 1 self-loop, imperfect consonances have *n* self-loops.
- The voice-leading cost theorems (Section 4) are entirely independent of pitch-class arithmetic.

---

## 6. Algorithms and Computation

### 6.1 Enumeration of the Counterpoint Quiver

For the standard 12-TET system:
- Vertices: |C| = 6
- Total possible arrows (per source-target pair): 144 (= 12²)
- Total source-target pairs: 36 (= 6²)
- Permitted arrows: computed by filtering the parallel-motion predicate.

For each target in P (2 targets), 11 of the 12 parallel motions are forbidden per source, yielding a deficit. For each target in C \ P (4 targets), no parallel motions are forbidden.

### 6.2 Hom-Set Computation

For target *t* ∈ P and source *s*:
- There are 12 voice leadings (b, s − t + b) mapping *s* to *t* (parameterized by bass motion *b*).
- The parallel ones have b = s − t + b, i.e., s = t, and then any nonzero b is parallel.
- If s = t: 12 total, minus 11 parallel = 1 permitted.
- If s ≠ t: all 12 are permitted (none are parallel since s ≠ t means the target-equals-source check for parallel motion may or may not apply, but the voice leading has bass ≠ soprano in general).

Summing: 1 (from s = t) + 5 × 12 (from s ≠ t) = 61 per perfect target.
For imperfect target: 6 × 12 = 72 per imperfect target.

---

## 7. Discussion

### 7.1 Why Not a Category?

The non-composability result (Theorem 3.3) is mathematically sharp: counterpoint is not a category. This distinguishes our framework from neo-Riemannian theory (Cohn 1998), where transformations *do* form a group (and hence a category with one object). The difference is that neo-Riemannian transformations act on *chords* (triads), while our voice leadings act on *intervals* with constraints that reference the *manner of arrival*, not just the result.

The non-composability reflects a musically meaningful reality: a sequence of smooth, legal moves can accumulate into a forbidden one. This is analogous to the failure of "small-step legality" to imply "big-step legality" in certain formal verification problems.

### 7.2 Connection to Thin Categories and Posets

The original conjecture motivating this work was that the Counterpoint Quiver might be equivalent to a thin category (a poset). Theorem 3.3 refutes this in a strong sense: not only is the quiver not a thin category, it is not a category at all. However, the *consonance score* function σ : ℤ/12ℤ → ℕ does induce a partial order on consonant intervals (by consonance level), and the quiver's asymmetries (bottleneck, hom-set cardinalities) correlate with this order.

### 7.3 The Bass Voice and Broken Symmetry

Theorem 3.10 on voice-swap asymmetry connects to a long-standing debate in music theory: *why is the perfect fourth dissonant above the bass but consonant between upper voices?* Our formalization shows this is a necessary consequence of fixing the consonant set in ℤ/12ℤ: the arithmetic of modular negation simply does not preserve {0, 3, 4, 7, 8, 9}. Any theory that treats consonance as a symmetric relation on pitch classes (as opposed to directed intervals from the bass) must either exclude the fourth or include it and sacrifice the voice-swap invariance.

### 7.4 Lattice-Cost Duality

The L¹-lattice identity (Theorem 4.3) is, to our knowledge, new in the music-theoretic literature. It suggests a duality between the *algebraic* structure of voice motions (lattice operations) and their *metric* structure (cost). The identity is an exact conservation law: lattice operations redistribute cost without creating or destroying it. This may have applications in algorithmic composition, where one seeks cost-optimal voice leadings subject to constraints.

---

## 8. Future Work

1. **Higher species.** Second through fifth species introduce rhythmic subdivisions, suspensions, and passing tones. Extending the quiver to a 2-category (with 2-morphisms for temporal refinements) is a natural next step.

2. **Homology of the quiver.** The simplicial complex of permitted voice-leading chains may carry nontrivial homology, reflecting topological features of the constraint space.

3. **Microtonal enumeration.** Compute the Counterpoint Quiver for *n* = 19, 24, 31, 53 and compare bottleneck ratios, connectivity, and hom-set cardinalities.

4. **Multi-voice generalization.** The current framework handles two voices (bass and soprano). The full *n*-voice problem embeds in (ℤ/12ℤ)^(n−1), with constraints on all pairwise intervals.

5. **Lattice width conjecture.** Conjecture: for a counterpoint system with stepwise bound B and n voices, the optimal cost is bounded by the lattice width of the feasible region. This can be tested computationally for small parameters.

6. **Algorithmic composition.** Use the optimal voice-leading existence theorem (4.8) and the ascending-sublattice results (4.5–4.7) as the foundation for a constraint-based composition algorithm.

---

## 9. Catalog of Formal Results

| # | Name | Statement (informal) |
|---|------|---------------------|
| 1 | `exists_permitted_voice_leading` | Strong connectivity of the Counterpoint Quiver |
| 2 | `non_composability` | Permitted voice leadings are not closed under composition |
| 3 | `perfect_self_loop_unique` | Perfect consonances admit exactly 1 self-loop |
| 4 | `imperfect_self_loops_all` | Imperfect consonances admit 12 self-loops |
| 5 | `total_permitted_to_perfect` | 61 incoming voice leadings to perfect consonances |
| 6 | `total_permitted_to_imperfect` | 72 incoming voice leadings to imperfect consonances |
| 7 | `voice_swap_breaks_consonance` | Voice swap does not preserve consonance |
| 8 | `cost_triangle` | Triangle inequality for voice-leading cost |
| 9 | `cost_eq_zero_iff` | Cost is zero iff no voice moves |
| 10 | `cost_abs_homogeneous` | Absolute homogeneity of cost |
| 11 | `cost_seminorm_properties` | Cost is a seminorm (summary) |
| 12 | `cost_meet_join_eq` | L¹-lattice identity |
| 13 | `cost_meet_le` | Meet cost bounded by sum |
| 14 | `cost_join_le` | Join cost bounded by sum |
| 15 | `ascending_meet` | Ascending motions closed under meet |
| 16 | `ascending_join` | Ascending motions closed under join |
| 17 | `ascending_cost_eq_sum` | Cost simplifies for ascending motions |
| 18 | `ascending_meet_cost_le` | Meet minimizes cost for ascending motions |
| 19 | `optimal_exists_of_finset` | Optimal voice leading exists for finite constraint sets |
| 20 | `parallel_preserves_interval` | Parallel motion preserves intervals |
| 21 | `nonparallel_changes_interval` | Non-parallel motion changes intervals |
| 22 | `cost_neg_eq` | Retrograde has same cost |
| 23 | `stepwise_cost_bound` | Stepwise bound implies total cost bound |
| 24 | `canonical_not_parallel` | Canonical voice leading is never parallel (i ≠ j) |
| 25 | `targetInterval_canonical` | Canonical voice leading hits target |

---

## References

1. Fux, J.J. *Gradus ad Parnassum* (1725). Translated by A. Mann, W.W. Norton, 1965.
2. Tymoczko, D. *A Geometry of Music: Harmony and Counterpoint in the Extended Common Practice.* Oxford University Press, 2011.
3. Cohn, R. "Introduction to Neo-Riemannian Theory: A Survey and a Historical Perspective." *Journal of Music Theory* 42(2), 1998, 167–180.
4. Lewin, D. *Generalized Musical Intervals and Transformations.* Yale University Press, 1987.
5. Forte, A. *The Structure of Atonal Music.* Yale University Press, 1973.
6. Mazzola, G. *The Topos of Music.* Birkhäuser, 2002.
7. Callender, C., Quinn, I., Tymoczko, D. "Generalized Voice-Leading Spaces." *Science* 320(5874), 2008, 346–348.
8. Euler, L. *Tentamen novae theoriae musicae.* 1739.
