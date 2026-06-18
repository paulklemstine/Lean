# Sonic Mathematics: First-Species Counterpoint as Categorical and Lattice-Theoretic Structure

**Abstract.** We formalize the voice-leading rules of first-species counterpoint — the foundational framework of Western polyphonic composition codified by Fux (1725) — as precise mathematical structures amenable to rigorous analysis. Two complementary formalizations are developed. First, we construct the *Counterpoint Quiver*, a directed multigraph whose vertices are the six consonant interval classes modulo 12 and whose edges are permitted voice leadings. We prove that this quiver is strongly connected, that its edge set is not closed under composition (hence does not form a category), that perfect consonances admit exactly 1 self-loop versus 12 for imperfect consonances, and that the involution i ↦ −i on ℤ/12ℤ does not preserve consonance. Second, we develop a *voice-leading cost theory* in which the L¹ norm on voice motions serves as a seminorm satisfying a lattice identity: the cost of the meet plus the cost of the join equals the sum of the individual costs. All results are formalized and machine-verified, ensuring complete mathematical certainty. The framework generalizes to arbitrary equal temperaments via a parameterized *CounterpointSystem* structure.

**Keywords:** musical counterpoint, category theory, quiver, lattice theory, seminorm, voice leading, modular arithmetic, formal verification

---

## 1. Introduction

The rules of first-species counterpoint, as codified by Johann Joseph Fux in *Gradus ad Parnassum* (1725), constitute one of the oldest and most precisely stated constraint systems in the arts. Despite their antiquity, these rules have resisted rigorous mathematical formalization until recently. Prior mathematical treatments of music theory — notably the work of Guerino Mazzola (2002) on topos-theoretic music theory and Dmitri Tymoczko (2011) on the geometry of voice-leading spaces — have provided geometric and topological perspectives. However, the *combinatorial constraint structure* of the counterpoint rules themselves — particularly the prohibition against parallel motion into perfect consonances — has not been analyzed at the level of directed graph theory and category theory.

This paper fills that gap with two complementary approaches:

1. **The Counterpoint Quiver** (§3): We construct a directed multigraph whose vertices are consonant interval classes and whose edges are voice leadings permitted by the counterpoint rules. We prove structural theorems about connectivity, composability, self-loop counts, and symmetry-breaking.

2. **Voice-Leading Cost Theory** (§4): We equip the space of voice motions with the L¹ norm and prove it forms a seminorm with a remarkable lattice identity, connecting music theory to the theory of valuations on distributive lattices.

Both formalizations are parameterized — the quiver construction works over ℤ/nℤ for any n, enabling comparative study across tuning systems.

### 1.1 Notation

Throughout, we work in ℤ/12ℤ (the integers modulo 12) for the standard chromatic system, and ℤ/nℤ for the general parameterized setting. We write interval classes as elements of these groups. A *voice leading* is a pair (b, s) ∈ (ℤ/nℤ)² representing the motion of bass and soprano voices respectively.

---

## 2. Definitions

### 2.1 The CounterpointSystem Structure

**Definition 2.1** (CounterpointSystem). A *counterpoint system of order n* (where n ≥ 1) is a tuple (C, P, ⊆, ∃) where:
- C ⊆ ℤ/nℤ is a nonempty finite set of *consonant intervals*,
- P ⊆ C is a nonempty set of *perfect consonances*,
- There exists at least one *imperfect consonance*: some i ∈ C \ P.

The key constraint is: *parallel motion into perfect consonances is forbidden*.

**Definition 2.2** (Voice Leading). A *voice leading* over ℤ/nℤ is a pair vl = (b, s) where b, s ∈ ℤ/nℤ represent the bass and soprano motions respectively.

**Definition 2.3** (Target Interval). Given source interval i ∈ ℤ/nℤ and voice leading (b, s), the *target interval* is:

$$\tau(i, b, s) = i + s - b$$

**Definition 2.4** (Parallel Motion). A voice leading (b, s) is *parallel* if b = s and b ≠ 0.

**Definition 2.5** (Permitted Voice Leading). A voice leading from source i to target j is *permitted* if:
1. i ∈ C and j ∈ C (both intervals are consonant),
2. τ(i, b, s) = j (the voice leading maps i to j),
3. ¬(j ∈ P ∧ (b, s) is parallel) (no parallel motion into perfect consonances).

### 2.2 The Standard 12-TET System

**Definition 2.6**. The *standard 12-TET counterpoint system* is:
- C = {0, 3, 4, 7, 8, 9} (unison, minor third, major third, perfect fifth, minor sixth, major sixth),
- P = {0, 7} (unison/octave and perfect fifth).

### 2.3 Voice Motion Space

**Definition 2.7** (Voice Motion). For n voices, a *voice motion* is a function m : Fin(n) → ℤ, where m(i) is the number of semitones voice i moves.

**Definition 2.8** (Voice Leading Cost). The *cost* of a voice motion m is:

$$\text{cost}(m) = \sum_{i=0}^{n-1} |m(i)|$$

This is the L¹ norm on ℤⁿ — the standard measure of voice-leading efficiency in music theory.

**Definition 2.9** (Consonance Score). We assign a consonance score to each interval class in ℤ/12ℤ:

| Interval | Score | Classification |
|----------|-------|----------------|
| 0 (unison) | 8 | Perfect consonance |
| 7 (fifth) | 7 | Perfect consonance |
| 5 (fourth) | 6 | Perfect consonance* |
| 4 (major third) | 5 | Imperfect consonance |
| 3 (minor third) | 5 | Imperfect consonance |
| 9 (major sixth) | 4 | Imperfect consonance |
| 8 (minor sixth) | 4 | Imperfect consonance |
| 2 (major second) | 2 | Dissonance |
| 10 (minor seventh) | 1 | Dissonance |
| 1 (minor second) | 1 | Dissonance |
| 11 (major seventh) | 1 | Dissonance |
| 6 (tritone) | 0 | Dissonance |

*Note: The perfect fourth (5) receives a high consonance score but is treated as dissonant in two-voice first-species counterpoint when measured above the bass — a subtlety our voice-swap asymmetry theorem captures precisely.

---

## 3. The Counterpoint Quiver: Main Results

### 3.1 Strong Connectivity

**Theorem 3.1** (Strong Connectivity). *For any two consonant intervals i, j ∈ C in the standard 12-TET system, there exists a permitted voice leading from i to j.*

*Proof sketch.* We distinguish two cases:
- If i = j: the identity voice leading (0, 0) is always permitted, since it is not parallel (both components are zero, which means b = 0, violating the condition b ≠ 0 for parallelism).
- If i ≠ j: the canonical voice leading (0, j − i) maps i to j and is not parallel since b = 0 while s = j − i ≠ 0 (as i ≠ j in ℤ/12ℤ), so b ≠ s. ∎

This is formalized as `exists_permitted_voice_leading` and `canonical_not_parallel` in the codebase.

### 3.2 Non-Composability

**Theorem 3.2** (Non-Composability). *The set of permitted one-step voice leadings is not closed under composition. That is, there exist consonant intervals i, j, k and voice leadings vl₁, vl₂ such that vl₁ is permitted from i to j and vl₂ is permitted from j to k, but the composite voice leading (vl₁.b + vl₂.b, vl₁.s + vl₂.s) is not permitted from i to k.*

*Proof sketch.* Consider the composition of two voice leadings that individually avoid parallel motion into a perfect consonance, but whose composite has equal nonzero bass and soprano components, targeting a perfect consonance. The individual steps each have b ≠ s (or target an imperfect consonance), but the sums b₁ + b₂ = s₁ + s₂ ≠ 0, violating the parallel-motion prohibition at the final target. ∎

**Corollary 3.3.** *The permitted voice leadings of first-species counterpoint do not form a subcategory of the free category on the complete quiver over C.*

### 3.3 The Perfect Consonance Bottleneck

**Theorem 3.4** (Perfect Self-Loop Uniqueness). *A perfect consonance p ∈ P admits exactly 1 self-loop: the identity voice leading (0, 0).*

*Proof sketch.* A self-loop at p requires τ(p, b, s) = p, i.e., s = b. If b = s = 0, this is the identity. If b = s ≠ 0, the voice leading is parallel motion into a perfect consonance, which is forbidden. ∎

**Theorem 3.5** (Imperfect Self-Loops). *An imperfect consonance q ∈ C \ P admits exactly 12 self-loops (over ℤ/12ℤ): one for each value of b = s.*

*Proof sketch.* A self-loop at q requires s = b. Since q is imperfect, parallel motion into q is permitted. Thus every pair (b, b) for b ∈ ℤ/12ℤ gives a valid self-loop. ∎

The ratio 1:12 quantifies the categorical "bottleneck" at perfect consonances.

### 3.4 Hom-Set Cardinalities

**Theorem 3.6** (Hom-Set Computation). *In the standard 12-TET system:*
- *Each perfect consonance admits exactly 61 incoming permitted voice leadings from all consonant sources combined.*
- *Each imperfect consonance admits exactly 72 incoming permitted voice leadings from all consonant sources combined.*

The difference (72 − 61 = 11 = 12 − 1) is precisely the number of non-identity parallel motions forbidden at perfect targets.

### 3.5 Voice-Swap Asymmetry

**Theorem 3.7** (Voice-Swap Breaks Consonance). *The involution neg : ℤ/12ℤ → ℤ/12ℤ defined by i ↦ −i does not preserve the set of consonant intervals C = {0, 3, 4, 7, 8, 9}.*

*Proof sketch.* We have neg(7) = −7 ≡ 5 (mod 12), and 5 ∉ C. The perfect fifth maps to the perfect fourth, which is classified as dissonant in two-voice counterpoint above the bass. ∎

This formalizes the *bass voice privilege*: the classification of an interval as consonant or dissonant depends on which voice is lower. Swapping the voices can change a consonance into a dissonance.

---

## 4. Voice-Leading Cost Theory: Main Results

### 4.1 Seminorm Properties

**Theorem 4.1** (Cost Seminorm). *The voice-leading cost function satisfies:*
1. *Nonnegativity:* cost(m) ≥ 0 for all voice motions m.
2. *Triangle inequality:* cost(m₁ + m₂) ≤ cost(m₁) + cost(m₂).
3. *Absolute homogeneity:* cost(c · m) = |c| · cost(m) for c ∈ ℤ.
4. *Definiteness:* cost(m) = 0 if and only if m = 0.

*Hence cost is actually a norm on the free ℤ-module ℤⁿ.*

These are formalized as `cost_nonneg`, `cost_triangle`, `cost_abs_homogeneous`, `cost_eq_zero_iff`, and bundled as `cost_seminorm_properties`.

### 4.2 The L¹-Lattice Identity

The space of voice motions ℤⁿ = (Fin n → ℤ) carries a distributive lattice structure under componentwise min (⊓) and max (⊔).

**Theorem 4.2** (L¹-Lattice Identity). *For any voice motions m₁, m₂:*

$$\text{cost}(m_1 \sqcap m_2) + \text{cost}(m_1 \sqcup m_2) = \text{cost}(m_1) + \text{cost}(m_2)$$

*Proof sketch.* Reduce to the componentwise identity |min(a,b)| + |max(a,b)| = |a| + |b| for integers a, b, which holds by case analysis on their signs and relative order. ∎

This is formalized as `cost_meet_join_eq`. It states that the cost function is a *lattice valuation* — it distributes additively over the lattice operations. This connects music-theoretic voice leading to the classical theory of valuations on distributive lattices.

**Corollary 4.3.** cost(m₁ ⊓ m₂) ≤ cost(m₁) + cost(m₂) and cost(m₁ ⊔ m₂) ≤ cost(m₁) + cost(m₂).

### 4.3 The Ascending Motion Sublattice

**Definition 4.4.** A voice motion m is *ascending* if m(i) ≥ 0 for all voices i.

**Theorem 4.5** (Ascending Sublattice). *The set of ascending voice motions is closed under ⊓ and ⊔ — it forms a sublattice of (ℤⁿ, ⊓, ⊔).*

Formalized as `ascending_meet` and `ascending_join`.

**Theorem 4.6** (Ascending Cost Simplification). *For ascending motions, cost(m) = Σᵢ m(i). Moreover, cost(m₁ ⊓ m₂) ≤ cost(m₁) for ascending m₁, m₂.*

Formalized as `ascending_cost_eq_sum` and `ascending_meet_cost_le`.

### 4.4 Interval Preservation

**Theorem 4.7** (Parallel Preserves Intervals). *If two voices move by the same amount (parallel motion), the interval between them is preserved.*

**Theorem 4.8** (Non-Parallel Changes Intervals). *If two voices move by different amounts, the interval between them necessarily changes.*

These are formalized as `parallel_preserves_interval` and `nonparallel_changes_interval`. Together they provide a complete characterization: parallel motion is *exactly* the condition for interval preservation, establishing a bijection between the algebraic notion (equal components) and the musical notion (maintained harmony).

### 4.5 Optimal Voice Leading Existence

**Theorem 4.9.** *Given any nonempty finite set S of voice motions, there exists m* ∈ S minimizing cost over S.*

Formalized as `optimal_exists_of_finset`. Combined with the stepwise motion bound (cost ≤ n · bound for motions bounded by `bound`), this guarantees the existence of optimal voice leadings under standard counterpoint constraints.

---

## 5. The Parameterized Framework

A key feature of this work is the parameterization over an arbitrary modulus n. The `CounterpointSystem n` structure captures:

- **12-TET** (n = 12): Standard Western counterpoint.
- **19-TET** (n = 19): A meantone temperament where thirds are purer.
- **31-TET** (n = 31): A system approximating quarter-comma meantone.
- **24-TET** (n = 24): Quarter-tone music used in some 20th-century and Middle Eastern traditions.

For each n, one specifies the consonant set C ⊆ ℤ/nℤ and the perfect subset P ⊆ C, then the structural theorems (connectivity, bottleneck asymmetry) can be investigated. The strong connectivity proof, for instance, works for *any* counterpoint system — the canonical voice leading construction is independent of n.

---

## 6. Discussion

### 6.1 Why Not a Category?

The non-composability theorem (Theorem 3.2) is perhaps the most philosophically significant result. Category theory is often proposed as the natural language for musical transformation — and indeed, Neo-Riemannian operations (P, L, R) *do* form a group acting on triads. But the counterpoint rules, which are *constraints* rather than *transformations*, resist categorical formulation precisely because they are contextual: the legality of a transition depends on properties of the *target*, not just the *morphism*.

This suggests that the natural mathematical home for counterpoint is not category theory per se, but rather the theory of *constraint satisfaction problems* (CSPs) — or equivalently, the theory of *quivers with forbidden patterns*. The Counterpoint Quiver is a CSP instance where the constraint is: "no parallel edges targeting perfect vertices."

### 6.2 The Lattice-Cost Duality

The L¹-lattice identity (Theorem 4.2) reveals that voice-leading cost is a *modular function* on the distributive lattice of voice motions. Modular functions on lattices have been studied extensively in combinatorics (they underlie matroid theory and submodular optimization). The music-theoretic significance is that lattice operations (componentwise min/max) provide a principled way to interpolate between voice leadings while conserving total displacement.

### 6.3 Relationship to Prior Work

Our quiver-theoretic approach complements Tymoczko's (2011) geometric model of voice-leading spaces as orbifolds. Where Tymoczko works in continuous space (ℝⁿ/Sₙ), we work in the discrete chromatic universe (ℤ/12ℤ). The two approaches capture different aspects: geometry captures *distance*, while quiver theory captures *permitted transitions*.

The consonance score function (Definition 2.9) is related to Helmholtz's (1863) roughness theory and Plomp and Levelt's (1965) psychoacoustic consonance curves, but our treatment is purely algebraic — we take the classification as given and derive its structural consequences.

---

## 7. Computational Results

To complement the formal proofs, we performed exhaustive enumeration of the Counterpoint Quiver for the standard 12-TET system. The results are summarized below.

### 7.1 Edge Count Matrix

The adjacency matrix of the Counterpoint Quiver (entries = number of permitted voice leadings from row to column):

|            | 0  | 3  | 4  | 7  | 8  | 9  |
|------------|----|----|----|----|----|----|----|
| **0**      | 1  | 12 | 12 | 12 | 12 | 12 |
| **3**      | 12 | 12 | 12 | 12 | 12 | 12 |
| **4**      | 12 | 12 | 12 | 12 | 12 | 12 |
| **7**      | 12 | 12 | 12 | 1  | 12 | 12 |
| **8**      | 12 | 12 | 12 | 12 | 12 | 12 |
| **9**      | 12 | 12 | 12 | 12 | 12 | 12 |

The total number of permitted voice leadings is 410 (out of a maximum 6 × 6 × 12 = 432). The deficit of 22 = 2 × 11 accounts for exactly the 11 non-identity parallel motions forbidden at each of the 2 perfect consonance targets.

### 7.2 In-Degree and Out-Degree

| Interval | Type | In-degree | Out-degree |
|----------|------|-----------|------------|
| 0 (Unison) | Perfect | 61 | 61 |
| 3 (Minor 3rd) | Imperfect | 72 | 72 |
| 4 (Major 3rd) | Imperfect | 72 | 72 |
| 7 (Perfect 5th) | Perfect | 61 | 61 |
| 8 (Minor 6th) | Imperfect | 72 | 72 |
| 9 (Major 6th) | Imperfect | 72 | 72 |

The symmetry between in-degree and out-degree follows from the fact that the forbidden motions are determined by the target interval class, not the source. The 11-edge deficit at perfect targets (72 − 61 = 11) is invariant: it equals |ℤ/12ℤ| − 1, the number of non-identity elements.

### 7.3 Non-Composability Witness

A concrete counterexample to composability:
- **Step 1**: From Perfect 5th (7) to Unison (0) via voice leading (bass=0, soprano=5). The soprano moves up a perfect fourth while the bass stays — oblique motion, always permitted.
- **Step 2**: From Unison (0) to Perfect 5th (7) via voice leading (bass=1, soprano=8). The bass moves up a semitone, soprano up a minor sixth — contrary motion, permitted.
- **Composite**: From Perfect 5th (7) to Perfect 5th (7) via (bass=1, soprano=1). Both voices move up by 1 semitone — parallel motion into a perfect consonance, FORBIDDEN.

This witness demonstrates that the constraint is genuinely non-local: the legality of a composite motion cannot be determined from the legality of its components.

### 7.4 Voice-Swap Analysis

The negation map on ℤ/12ℤ acts on the 12 interval classes as follows:

| i | −i mod 12 | i consonant? | −i consonant? | Preserved? |
|---|-----------|-------------|--------------|------------|
| 0 | 0 | Yes | Yes | ✓ |
| 1 | 11 | No | No | ✓ |
| 2 | 10 | No | No | ✓ |
| 3 | 9 | Yes | Yes | ✓ |
| 4 | 8 | Yes | Yes | ✓ |
| 5 | 7 | No | Yes | ✗ |
| 6 | 6 | No | No | ✓ |
| 7 | 5 | Yes | No | ✗ |
| 8 | 4 | Yes | Yes | ✓ |
| 9 | 3 | Yes | Yes | ✓ |
| 10 | 2 | No | No | ✓ |
| 11 | 1 | No | No | ✓ |

The map fails to preserve consonance at exactly two points: 5 ↦ 7 (dissonant to consonant) and 7 ↦ 5 (consonant to dissonant). These are the perfect fourth/fifth pair, the interval pair whose asymmetric treatment is the most distinctive feature of two-voice counterpoint.

## 8. Future Work

1. **Higher species.** Second-species counterpoint (two notes against one) introduces passing tones and changes the constraint structure. The quiver gains additional edge types, and composability properties may differ.

2. **Multi-voice generalization.** Extending from two voices to n voices replaces ℤ/12ℤ-valued intervals with (ℤ/12ℤ)^(n choose 2)-valued interval vectors, dramatically expanding the quiver.

3. **Lattice width bounds.** We conjecture that for a counterpoint system with stepwise bound b and n voices, the optimal voice-leading cost is bounded by the lattice width of the feasible region, which is at most n · b.

4. **Microtonal counterpoint.** Systematically instantiating the parameterized `CounterpointSystem n` for n = 19, 24, 31, 53 and characterizing the resulting quivers' connectivity and bottleneck structure.

5. **Computational enumeration.** Using the decidability instances in the formalization to exhaustively enumerate all permitted voice leadings for small systems and study their statistical properties.

---

## 9. Appendix: The Counterpoint System as a CSP

The framework developed in this paper naturally embeds into the theory of constraint satisfaction problems (CSPs). A first-species counterpoint exercise over a cantus firmus of length L is a CSP instance where:

- **Variables**: L interval classes, one per beat.
- **Domains**: Each variable ranges over the consonant set C = {0, 3, 4, 7, 8, 9}.
- **Constraints**: For each pair of adjacent beats (t, t+1), the voice leading from interval(t) to interval(t+1) must be among the permitted voice leadings — that is, the pair must be an edge in the Counterpoint Quiver.

Our strong connectivity theorem (Theorem 3.1) implies that this CSP is always satisfiable for any starting interval, since from any vertex, every other vertex is reachable in one step. However, the non-composability theorem (Theorem 3.2) implies that the constraint graph is not closed under path composition, which has implications for arc consistency algorithms: standard constraint propagation may not eliminate as many values as one might expect from a strongly connected constraint graph.

The CSP perspective also connects to the optimization framework of §4: among all solutions to the CSP (all valid counterpoint exercises), one seeks the one minimizing the total voice-leading cost. This is an integer programming problem whose feasible region is a subset of (ℤ/12ℤ)^L satisfying binary constraints, with an L¹ objective function over the motion variables.

The lattice structure of §4.2–4.3 suggests that lattice-based relaxation methods may be effective for approximate optimization: replacing the integer constraint with a lattice-valued relaxation and using the L¹-lattice identity to bound the gap.

## 10. References

1. Fux, J.J. (1725). *Gradus ad Parnassum*. Vienna.
2. Helmholtz, H. von (1863). *Die Lehre von den Tonempfindungen*. Braunschweig: Vieweg.
3. Mazzola, G. (2002). *The Topos of Music*. Basel: Birkhäuser.
4. Plomp, R. & Levelt, W.J.M. (1965). Tonal consonance and critical bandwidth. *J. Acoust. Soc. Am.*, 38(4), 548–560.
5. Tymoczko, D. (2011). *A Geometry of Music*. Oxford University Press.
6. Mac Lane, S. (1998). *Categories for the Working Mathematician*. 2nd ed. Springer.
7. Birkhoff, G. (1967). *Lattice Theory*. 3rd ed. AMS Colloquium Publications.

---

*All theorems in this paper have been machine-verified, providing the highest standard of mathematical certainty for the results claimed.*
