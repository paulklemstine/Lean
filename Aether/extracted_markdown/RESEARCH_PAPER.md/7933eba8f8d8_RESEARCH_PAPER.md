# Sonic Mathematics: Counterpoint as Category Theory

**Abstract.** We formalize first-species counterpoint rules (Fux, 1725) as a directed multigraph — the *Counterpoint Quiver* — whose vertices are consonant intervals modulo 12 semitones and whose edges are permitted voice leadings. We introduce the *CounterpointSystem*, a parameterized algebraic structure over ℤ/nℤ that captures counterpoint-like constraints for arbitrary equal temperaments. Within this framework, we prove five structural theorems: (1) the quiver is strongly connected; (2) permitted voice leadings fail to compose, hence do not form a subcategory; (3) perfect consonances admit exactly 1 self-loop versus 12 for imperfect consonances — a categorical bottleneck; (4) voice exchange (the involution *i* ↦ −*i*) does not preserve the consonant set, formalizing bass-voice asymmetry; (5) perfect consonances admit exactly 61 incoming voice leadings versus 72 for imperfect consonances. We further prove that voice-leading cost defines a seminorm and a Lawvere metric on chord space. All results are machine-verified.

**Keywords:** counterpoint, voice leading, category theory, Lawvere metric space, directed graph, modular arithmetic, music theory, formal verification

---

## 1. Introduction

### 1.1 Motivation

The rules of species counterpoint, codified by Fux (1725) and foundational to Western art music, specify which voice leadings between consonant intervals are permitted. Despite centuries of pedagogical transmission, the *structural* content of these rules — what they imply about the space of harmonic possibilities — has resisted precise mathematical characterization.

Prior mathematical treatments of voice leading include Tymoczko's geometric approach via orbifolds (2006, 2011), Callender–Quinn–Tymoczko's generalized voice-leading spaces (2008), and Fiore–Satyendra's categorical formulation of Riemannian transformations (2005). Cohn's work on neo-Riemannian theory (1998) and Douthett–Steinbach's parsimonious graphs (1998) explored the graph structure of specific transformations. However, none of these formalizations addresses the *full constraint system* of first-species counterpoint as a single mathematical object, nor provides machine-verified proofs of the resulting structural properties.

### 1.2 Contributions

We introduce the **CounterpointSystem**, a parameterized structure over ℤ/nℤ that abstracts the essential features of counterpoint constraints:

- A finite set of *consonant* intervals
- A distinguished subset of *perfect* consonances
- The rule that *parallel motion into perfect consonances is forbidden*

This abstraction enables structural theorems that apply uniformly to all equal temperaments, not just 12-TET. We prove five main results about the standard 12-TET instantiation and establish the Lawvere metric structure of voice-leading space.

### 1.3 Organization

Section 2 defines the core structures. Section 3 presents the five main theorems. Section 4 develops the metric and seminorm theory. Section 5 discusses the lattice-cost interaction. Section 6 treats applications and future work. Proof sketches are given throughout; full machine-checked proofs are available in the accompanying formalization.

---

## 2. Definitions

### 2.1 The CounterpointSystem Structure

**Definition 2.1** (CounterpointSystem). A *counterpoint system of order n* is a tuple (C, P, ⊆, ≠) where:
- n ≥ 1 is a positive integer (the number of pitch classes)
- C ⊆ ℤ/nℤ is a nonempty finite set of *consonant intervals*
- P ⊆ C is a nonempty finite set of *perfect consonances*
- There exists at least one *imperfect consonance*: some i ∈ C \ P

**Remark.** The definition is parameterized over n, enabling application to microtonal systems (n = 19, 24, 31, 53, etc.). The constraint structure — not the specific interval content — drives the main theorems.

### 2.2 Voice Leadings

**Definition 2.2** (Voice Leading). A *voice leading* over ℤ/nℤ is a pair (b, s) ∈ (ℤ/nℤ)² representing the bass motion b and soprano motion s.

The space of voice leadings over ℤ/nℤ is thus (ℤ/nℤ)² and has cardinality n².

**Definition 2.3** (Target Interval). Given a source interval i ∈ ℤ/nℤ and a voice leading (b, s), the *target interval* is:

$$\tau(i, b, s) = i + s - b$$

This formula captures the geometry: if two voices are i semitones apart and the bass moves by b while the soprano moves by s, the new interval is i + s − b.

**Definition 2.4** (Parallel Motion). A voice leading (b, s) exhibits *parallel motion* if b = s and b ≠ 0. That is, both voices move by the same nonzero amount.

**Definition 2.5** (Permitted Voice Leading). A voice leading (b, s) is *permitted* from source interval i to target interval j in a counterpoint system (C, P) if:
1. i ∈ C (source is consonant)
2. j ∈ C (target is consonant)
3. τ(i, b, s) = j (the voice leading maps i to j)
4. ¬(j ∈ P ∧ b = s ∧ b ≠ 0) (parallel motion into a perfect consonance is forbidden)

### 2.3 The Standard 12-TET System

**Definition 2.6** (Standard System). The *standard first-species counterpoint system* is the CounterpointSystem of order 12 with:
- C = {0, 3, 4, 7, 8, 9} (unison, minor 3rd, major 3rd, perfect 5th, minor 6th, major 6th)
- P = {0, 7} (unison/octave and perfect 5th)

The four imperfect consonances are {3, 4, 8, 9}. The six dissonant interval classes are {1, 2, 5, 6, 10, 11}.

### 2.4 The Counterpoint Quiver

**Definition 2.7** (Counterpoint Quiver). The *counterpoint quiver* Q(C, P) is the directed multigraph with:
- Vertex set: C (consonant intervals)
- Edge set from i to j: {(b, s) ∈ (ℤ/nℤ)² : (b, s) is permitted from i to j}

This is a quiver (directed multigraph) rather than a simple graph because multiple distinct voice leadings may connect the same pair of intervals.

---

## 3. Main Results

### 3.1 Strong Connectivity

**Theorem 3.1** (Strong Connectivity). *For any two consonant intervals i, j ∈ C in the standard 12-TET system, there exists a permitted voice leading from i to j.*

*Proof sketch.* We exhibit a uniform construction: the *canonical voice leading* (0, j − i), where the bass stays fixed and the soprano moves by j − i semitones. This is never parallel when i ≠ j (since bass motion is 0 ≠ j − i = soprano motion when j ≠ i). When i = j, the identity voice leading (0, 0) is permitted (verified by case analysis over all six consonant intervals). The result follows by exhaustive verification over the 36 source-target pairs. □

**Corollary.** The counterpoint quiver Q(C, P) is strongly connected as a directed graph.

### 3.2 Non-Composability

**Theorem 3.2** (Non-Composability). *The set of permitted one-step voice leadings in the standard 12-TET system is not closed under composition. That is, there exist permitted voice leadings (b₁, s₁) from i to j and (b₂, s₂) from j to k such that (b₁ + b₂, s₁ + s₂) is not a permitted voice leading from i to k.*

*Proof sketch.* Consider the voice leading (1, 1) — both voices move up by one semitone. This is parallel motion. From interval 3 (minor third), applying (1, 1) yields target 3 + 1 − 1 = 3, still consonant. Since 3 ∉ P, this parallel motion is permitted. Composing (1, 1) with itself gives (2, 2), which is also parallel. From interval 3, this yields target 3, still consonant. But composing seven times gives (7, 7), which from interval 0 yields target 0 — parallel motion into the perfect consonance 0 ∈ P, which is forbidden. Thus the composition of individually permitted moves produces a forbidden move. □

**Remark.** This theorem has a categorical interpretation: the permitted voice leadings do not form a *subcategory* of the free category on the quiver. Counterpoint rules are inherently non-compositional.

### 3.3 The Perfect Consonance Bottleneck

**Theorem 3.3** (Self-Loop Bottleneck). *Let i be a consonant interval in the standard 12-TET system.*
- *(a) If i ∈ P (perfect consonance), then i admits exactly 1 self-loop: the identity (0, 0).*
- *(b) If i ∈ C \ P (imperfect consonance), then i admits exactly 12 self-loops.*

*Proof sketch.* A self-loop on interval i is a voice leading (b, s) with τ(i, b, s) = i, i.e., s = b. This is parallel when b = s ≠ 0. For a perfect consonance, the parallel-motion prohibition eliminates all self-loops except (0, 0), leaving exactly 1. For an imperfect consonance, no parallel-motion restriction applies, so all 12 values of b (with s = b) are permitted, giving 12 self-loops. □

This 12:1 ratio is the categorical manifestation of the parallel-motion prohibition. Perfect consonances are *categorically rigid* — they have minimal automorphism groups in the voice-leading quiver.

### 3.4 Voice-Swap Asymmetry

**Theorem 3.4** (Voice-Swap Asymmetry). *The involution ι : ℤ/12ℤ → ℤ/12ℤ defined by ι(i) = −i does not preserve the set of consonant intervals. Specifically, ι(7) = 5 ∉ C.*

*Proof sketch.* Direct computation: −7 ≡ 5 (mod 12). The interval 5 (perfect fourth) is not in C = {0, 3, 4, 7, 8, 9}. □

**Remark.** This formalizes the asymmetric role of the bass voice in counterpoint. The perfect fourth, acoustically the inversion of the perfect fifth, is treated as a dissonance when measured from the bass. This asymmetry is not a cultural convention but a structural feature of the consonant set under the negation involution on ℤ/12ℤ.

**Corollary.** The consonant set C is not closed under the dihedral group action on ℤ/12ℤ. In particular, it is not a union of orbits under the involution ι.

### 3.5 Hom-Set Cardinality

**Theorem 3.5** (Hom-Set Computation). *In the standard 12-TET system:*
- *(a) Each perfect consonance admits exactly 61 incoming permitted voice leadings (summed over all consonant sources).*
- *(b) Each imperfect consonance admits exactly 72 incoming permitted voice leadings.*

*Proof sketch.* For a perfect consonance j ∈ P: from each of the 6 consonant sources, there are 12² = 144 candidate voice leadings, of which those satisfying τ(i, b, s) = j number 12 (for each b, s = j − i + b is determined). Of these 12, the parallel ones (b = s, b ≠ 0) are forbidden — there are either 0 or 11 depending on whether j − i = 0. Summing over sources: from i = j, 1 is permitted (the identity); from each i ≠ j, 12 are permitted minus the number of forbidden parallel motions. The total is 61.

For an imperfect consonance j ∉ P: no parallel-motion restriction applies, so all 12 voice leadings from each source are permitted. Total: 6 × 12 = 72. □

The ratio 61:72 ≈ 0.847 quantifies the *compositional bottleneck* at perfect consonances: approximately 15% fewer voice-leading options are available when targeting a perfect consonance.

---

## 4. Metric Structure of Voice-Leading Space

### 4.1 Voice-Leading Cost as Seminorm

Beyond the quiver structure, we establish metric properties of voice-leading cost. Define the *voice-leading cost* of a motion m : Fin(n) → ℤ as:

$$\text{cost}(m) = \sum_{i=1}^{n} |m_i|$$

**Theorem 4.1** (Seminorm Properties). *The voice-leading cost function satisfies:*
- *(a) Nonnegativity: cost(m) ≥ 0 for all m.*
- *(b) Identity: cost(m) = 0 if and only if m = 0.*
- *(c) Triangle inequality: cost(m₁ + m₂) ≤ cost(m₁) + cost(m₂).*
- *(d) Absolute homogeneity: cost(c · m) = |c| · cost(m) for all c ∈ ℤ.*

*Proof sketch.* Properties (a) and (d) follow from properties of absolute value. Property (b) follows from the characterization of when a sum of nonneg terms vanishes. Property (c) is the triangle inequality for the ℓ¹ norm, applied componentwise. □

**Corollary.** The voice-leading cost is a norm on the free ℤ-module ℤⁿ (since it satisfies definiteness, not just seminorm properties).

### 4.2 Lawvere Metric Space Structure

**Definition 4.2** (Lawvere Metric Space). A *Lawvere metric space* is a set X equipped with a function d : X × X → [0, ∞) satisfying:
- d(x, x) = 0 for all x
- d(x, z) ≤ d(x, y) + d(y, z) for all x, y, z

Note: symmetry and separation are not required. A Lawvere metric space is equivalently a category enriched over ([0, ∞], ≥, +).

**Theorem 4.2** (Voice-Leading Lawvere Metric). *The space of n-voice voicings, equipped with the minimum voice-leading distance*

$$d(V, W) = \min_{\sigma \in S_n} \sum_{i=1}^{n} |V_i - W_{\sigma(i)}|$$

*forms a Lawvere metric space.*

*Proof sketch.* Self-distance is zero (take σ = id). The triangle inequality follows from: let σ₁ achieve d(V, W) and σ₂ achieve d(W, U); then σ₁ ∘ σ₂ is a candidate for d(V, U), and:

$$d(V, U) \leq \sum_i |V_i - U_{\sigma_2(\sigma_1(i))}| \leq \sum_i |V_i - W_{\sigma_1(i)}| + \sum_i |W_{\sigma_1(i)} - U_{\sigma_2(\sigma_1(i))}|$$

The second sum, reindexed by σ₁, equals d(W, U). □

**Remark.** The minimum over permutations reflects the fact that voices in a chord have no intrinsic ordering — we seek the most efficient assignment. This connects to the optimal transport (Wasserstein-1) distance on discrete measures.

### 4.3 Composition Triangle Inequality

**Theorem 4.3** (Cost Triangle for Composed Voice Leadings). *For voice-leading morphisms f : V → W and g : W → U, the composed voice leading f ; g satisfies:*

$$\text{cost}(f \mathbin{;} g) \leq \text{cost}(f) + \text{cost}(g)$$

*Proof sketch.* Direct application of the absolute-value triangle inequality componentwise, followed by reindexing the second sum via the permutation of f. □

---

## 5. Lattice-Cost Interaction

### 5.1 The Distributive Lattice of Voice Motions

The space ℤⁿ of voice motions carries a natural distributive lattice structure under componentwise min (meet) and max (join). This lattice interacts with the voice-leading cost in a remarkable way.

**Theorem 5.1** (Lattice-Cost Identity). *For any voice motions m₁, m₂ : Fin(n) → ℤ:*

$$\text{cost}(m_1 \wedge m_2) + \text{cost}(m_1 \vee m_2) = \text{cost}(m_1) + \text{cost}(m_2)$$

*Proof sketch.* The identity reduces componentwise to |min(a,b)| + |max(a,b)| = |a| + |b|, which holds for all integers a, b by case analysis on their signs. □

**Corollary 5.2.** *cost(m₁ ∧ m₂) ≤ cost(m₁) + cost(m₂) and cost(m₁ ∨ m₂) ≤ cost(m₁) + cost(m₂).*

### 5.2 The Ascending Sublattice

**Definition 5.3.** A voice motion m is *ascending* if m_i ≥ 0 for all i.

**Theorem 5.4** (Ascending Sublattice). *The set of ascending motions is closed under both meet and join, hence forms a sublattice of (ℤⁿ, ∧, ∨).*

*Proof sketch.* If m₁, m₂ are ascending, then min(m₁(i), m₂(i)) ≥ min(0, 0) = 0 and max(m₁(i), m₂(i)) ≥ m₁(i) ≥ 0. □

**Theorem 5.5** (Ascending Cost Formula). *For ascending motion m, cost(m) = ∑ᵢ mᵢ (no absolute values needed).*

**Theorem 5.6** (Ascending Meet Minimizes Cost). *For ascending motions m₁, m₂: cost(m₁ ∧ m₂) ≤ min(cost(m₁), cost(m₂)).*

*Proof sketch.* By Theorem 5.5, cost(m₁ ∧ m₂) = ∑ᵢ min(m₁(i), m₂(i)) ≤ ∑ᵢ m₁(i) = cost(m₁), and similarly for m₂. □

---

## 6. Connections and Interpretation

### 6.1 Relation to Neo-Riemannian Theory

The PLR transformations (Parallel, Leading-tone exchange, Relative) of neo-Riemannian theory act on major/minor triads. In the companion formalization, these transformations are shown to be geodesic: P and L achieve voice-leading distance exactly 1 (the minimum possible for quality-changing moves), while R achieves distance 2. The present framework extends beyond triadic neo-Riemannian theory to encompass the full first-species counterpoint constraint system.

### 6.2 Relation to Optimal Transport

The minimum voice-leading distance (Theorem 4.2) is precisely the Wasserstein-1 (earth mover's) distance between the discrete measures defined by two chords. This places voice-leading theory within the framework of optimal transport, connecting to Monge-Kantorovich duality and Brenier's theorem.

### 6.3 Microtonal Generalization

The CounterpointSystem structure is parameterized over ℤ/nℤ for arbitrary n. For any choice of consonant and perfect intervals in a microtonal system, the quiver construction applies and the structural theorems (connectivity, bottleneck) can be investigated. This opens the possibility of *designing* microtonal consonance systems with prescribed categorical properties.

---

## 7. Future Work

1. **Higher species.** Extend the quiver to second-, third-, and fourth-species counterpoint, where rhythmic offset introduces additional constraint dimensions.

2. **Enriched category structure.** Equip each hom-set with the voice-leading cost metric, creating a category enriched over Lawvere metric spaces (a metric on morphisms, not just objects).

3. **Tropical counterpoint.** The min-plus (tropical) semiring is a natural home for voice-leading optimization. Tropical geometry of the feasible region may yield sharp bounds on optimal voice-leading cost.

4. **Persistent homology.** Apply persistent homology to the family of directed graphs obtained by varying the cost threshold, extracting topological features of voice-leading space.

5. **Algorithmic composition.** Use the Lawvere metric structure to define gradient flows on chord space, generating counterpoint compositions that minimize voice-leading cost subject to consonance constraints.

6. **Lattice width conjecture.** Prove that the optimal voice-leading cost for a bounded counterpoint system is bounded by the lattice width of the feasible region.

---

## 8. References

1. Fux, J.J. (1725). *Gradus ad Parnassum*. Vienna.
2. Tymoczko, D. (2006). "The Geometry of Musical Chords." *Science*, 313(5783), 72–74.
3. Tymoczko, D. (2011). *A Geometry of Music*. Oxford University Press.
4. Callender, C., Quinn, I., Tymoczko, D. (2008). "Generalized Voice-Leading Spaces." *Science*, 320(5874), 346–348.
5. Cohn, R. (1998). "Neo-Riemannian Operations, Parsimonious Trichords, and Their Tonnetz Representations." *Journal of Music Theory*, 41(1), 1–66.
6. Douthett, J., Steinbach, P. (1998). "Parsimonious Graphs: A Study in Parsimony, Contextual Transformations, and Modes of Limited Transposition." *Journal of Music Theory*, 42(2), 241–263.
7. Fiore, T.M., Satyendra, R. (2005). "Generalized Contextual Groups." *Music Theory Online*, 11(3).
8. Lawvere, F.W. (1973). "Metric Spaces, Generalized Logic, and Closed Categories." *Rendiconti del Seminario Matematico e Fisico di Milano*, 43, 135–166.
9. Villani, C. (2003). *Topics in Optimal Transport*. American Mathematical Society.

---

## Appendix A: Catalog of Formalized Results

| # | Theorem | File | Statement |
|---|---------|------|-----------|
| 1 | Strong Connectivity | CounterpointCategory | ∀ i j ∈ C, ∃ vl, isPermitted(i, j, vl) |
| 2 | Non-Composability | CounterpointCategory | ∃ composed permitted moves yielding forbidden move |
| 3 | Self-Loop Bottleneck | CounterpointCategory | perfect: 1 self-loop; imperfect: 12 |
| 4 | Voice-Swap Asymmetry | CounterpointCategory | ι(7) = 5 ∉ C |
| 5 | Hom-Set Computation | CounterpointCategory | perfect: 61 incoming; imperfect: 72 |
| 6 | Cost Triangle Inequality | MusicalCounterpoint | cost(m₁ + m₂) ≤ cost(m₁) + cost(m₂) |
| 7 | Lattice-Cost Identity | MusicalCounterpoint | cost(m₁∧m₂) + cost(m₁∨m₂) = cost(m₁) + cost(m₂) |
| 8 | Seminorm Properties | MusicalCounterpoint | (nonneg, triangle, homogeneity) |
| 9 | Lawvere Metric | VoiceLeadingCategory | vlDist defines a Lawvere metric |
| 10 | Composition Triangle | VoiceLeadingCategory | cost(f;g) ≤ cost(f) + cost(g) |
