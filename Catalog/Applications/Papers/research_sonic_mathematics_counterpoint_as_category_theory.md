# Counterpoint as Category Theory: The Algebraic Structure of First-Species Voice Leading

## Abstract

We formalize the rules of first-species counterpoint (Fux 1725) as algebraic structure on the cyclic group ℤ/12ℤ, proving several results that bridge music theory, group theory, order theory, and category theory. We show that: (1) the set of consonant intervals partitions into perfect and imperfect consonances with a precise complement duality that breaks exactly at the perfect fourth; (2) the voice-leading transitions form a quiver with exactly 34 directed edges (a complete graph on 6 vertices minus 2 forbidden parallel-perfect self-loops); (3) non-complementary pairs of imperfect consonances generate all of ℤ/12ℤ while complementary pairs generate only proper subgroups; (4) the consonant interval set is maximally rigid under multiplicative automorphisms. All results are machine-verified in Lean 4 with Mathlib.

## 1. Introduction

Johann Joseph Fux's *Gradus ad Parnassum* (1725) codified the rules of counterpoint that had governed Western polyphonic composition since the Renaissance. In first-species counterpoint—the simplest form—two voices move note-against-note, with each vertical interval required to be *consonant*. The rules further constrain which transitions between consonances are permitted, most famously prohibiting "parallel fifths and octaves."

These rules have been studied extensively from musical, acoustic, and information-theoretic perspectives. Here we adopt a purely algebraic approach, working in the pitch-class interval group ℤ/12ℤ and characterizing the consonant set and its transition structure using tools from group theory, combinatorics, and category theory.

Our main contributions are:

1. **Complement Duality Theorem**: The imperfect consonances {3,4,8,9} are closed under the complement map n ↦ -n in ℤ/12ℤ, but the full consonant set is not. The perfect fifth (7) is the *unique* consonant interval whose complement is dissonant.

2. **Voice-Leading Quiver**: The allowed transitions form a directed graph with exactly 34 edges, obtained from the complete graph K₆ by removing the two self-loops on perfect consonances.

3. **Generation Dichotomy**: Two imperfect consonances generate all of ℤ/12ℤ if and only if they are not complementary. This establishes a precise correspondence between harmonic redundancy and complement structure.

4. **Multiplicative Rigidity**: The identity is the only element of (ℤ/12ℤ)× that preserves the consonant set. The consonance structure has trivial automorphism group under multiplicative maps.

5. **Tension-Parallel Correspondence**: The natural tension ordering on consonances (perfect < imperfect) corresponds exactly to the parallel-motion constraint: an interval forbids parallel self-loops if and only if its tension level is ≤ 1.

## 2. Definitions

### 2.1 Consonance Classification

We work in the cyclic group ℤ/12ℤ of pitch-class intervals.

**Definition 2.1** (Consonant Interval). An interval n ∈ ℤ/12ℤ is *consonant* if n ∈ {0, 3, 4, 7, 8, 9}.

**Definition 2.2** (Perfect/Imperfect). A consonant interval is *perfect* if n ∈ {0, 7} and *imperfect* if n ∈ {3, 4, 8, 9}.

**Definition 2.3** (Complement). The *complement* of n ∈ ℤ/12ℤ is -n (equivalently, 12-n).

### 2.2 Voice Leading

**Definition 2.4** (Voice-Leading Transition). A transition from consonant interval i to consonant interval j is *allowed* if either i ≠ j (cross-transition) or i is imperfect (parallel self-loop on imperfect consonance).

**Definition 2.5** (Tension Level). The *tension level* τ : consonances → ℕ is defined by τ(0) = 0, τ(7) = 1, τ(4) = τ(9) = 2, τ(3) = τ(8) = 3.

### 2.3 Voice-Leading Quiver

The voice-leading quiver Q has:
- Vertices: V(Q) = {0, 3, 4, 7, 8, 9} ⊂ ℤ/12ℤ (consonant intervals)
- Edges: E(Q) = {(i,j) ∈ V×V : transition from i to j is allowed}

## 3. Main Results

### 3.1 Complement Duality

**Theorem 3.1** (Imperfect Complement Closure). If n is an imperfect consonance, then -n is also an imperfect consonance.

*Proof.* The complement map exchanges: 3 ↔ 9, 4 ↔ 8. Both pairs consist of imperfect consonances. ∎

**Theorem 3.2** (Consonance Complement Asymmetry). The full consonant set is not closed under complement. Specifically, 7 is consonant but -7 = 5 is dissonant.

**Theorem 3.3** (Uniqueness of Breaking Point). The interval 7 (perfect fifth) is the *unique* consonant interval whose complement is dissonant.

*Proof sketch.* We verify: complement of 0 is 0 (consonant ✓), complement of 3 is 9 (consonant ✓), complement of 4 is 8 (consonant ✓), complement of 7 is 5 (dissonant ✗), complement of 8 is 4 (consonant ✓), complement of 9 is 3 (consonant ✓). Only 7 fails. ∎

**PEGB Analysis for Theorem 3.3:**

- **P**roof: Verified in Lean 4 as `complement_failure_is_fifth`.
- **E**xample: The perfect fifth C→G (7 semitones up) inverts to C→F (5 semitones up, a perfect fourth). In first-species counterpoint, C-G is a legal vertical interval but C-F (against the bass) is not.
- **G**eneralization: In n-TET (n-tone equal temperament), one could ask: for which consonance sets S ⊂ ℤ/nℤ is there a unique complement-breaking element? This connects to the theory of difference sets in combinatorial design theory.
- **B**oundary: The theorem depends on the specific definition of consonance in first-species counterpoint. In later species and free counterpoint, the perfect fourth becomes conditionally consonant, eliminating the asymmetry. The result is specific to the Fuxian model.

### 3.2 Voice-Leading Quiver Structure

**Theorem 3.4** (Edge Count). The voice-leading quiver has exactly 34 directed edges.

*Proof.* There are 6² = 36 pairs of consonant intervals. Of these, 6 are self-loops. Self-loops on the 4 imperfect consonances are allowed (4 edges), but self-loops on the 2 perfect consonances are forbidden (0 edges). Total: 30 + 4 = 34. ∎

**Theorem 3.5** (Cross-Transition Completeness). For any two distinct consonant intervals i ≠ j, the transition from i to j is allowed.

**Theorem 3.6** (Perfect Self-Transition Forbidden). For any perfect consonance i, the self-transition i → i is forbidden.

**PEGB Analysis for Theorem 3.4:**

- **P**roof: Verified in Lean 4 as `counterpoint_quiver_edge_count`.
- **E**xample: From a perfect fifth, a voice can move to any other consonance (5 options) but cannot stay on a fifth via parallel motion. From a major third, it can move to any consonance including staying on a major third (6 options).
- **G**eneralization: For n consonances with k perfect among them, the edge count would be n² - k. This gives a formula parameterized by the consonance set.
- **B**oundary: This model assumes the strictest interpretation of "no parallel perfect consonances." In practice, oblique and contrary motion to the same perfect consonance IS allowed; the restriction is only on parallel motion. A richer model would distinguish motion types, giving a multi-edge quiver.

### 3.3 Generation Dichotomy

**Theorem 3.7** (Thirds Generate). The additive subgroup of ℤ/12ℤ generated by {3, 4} is all of ℤ/12ℤ.

*Proof sketch.* Since gcd(3,4) = 1, the subgroup generated by 3 and 4 in ℤ contains all integers, so its image in ℤ/12ℤ is everything. ∎

**Theorem 3.8** (Complement Pair 39 Non-Generation). The subgroup generated by {3, 9} is a proper subgroup of ℤ/12ℤ.

*Proof sketch.* Since 9 ≡ -3 mod 12, the subgroup generated by {3, 9} equals the cyclic subgroup ⟨3⟩ = {0, 3, 6, 9}, which has order 4. ∎

**Theorem 3.9** (Complement Pair 48 Non-Generation). The subgroup generated by {4, 8} is a proper subgroup.

**Theorem 3.10** (Non-Complement Generation). Each of {3,8}, {4,9}, {8,9} generates all of ℤ/12ℤ.

**PEGB Analysis for the Generation Dichotomy:**

- **P**roof: All cases verified in Lean 4 (`thirds_generate_chromatic`, `complement_pair_39_not_generate`, etc.).
- **E**xample: Starting from C, stacking minor thirds gives C-E♭-G♭-A (4 notes). Stacking major thirds gives C-E-A♭ (3 notes). But alternating minor and major thirds gives C-E♭-G-B♭-D-F-A-C♯-E-G♯-B-D♯ = all 12 notes.
- **G**eneralization: For ℤ/nℤ, two elements a,b generate the whole group iff gcd(gcd(a,b), n) = 1. The musical significance is that complementary intervals (a + b ≡ 0) satisfy gcd(a,b) = gcd(a,n/gcd(a,n)), which can be > 1.
- **B**oundary: This result is specific to ℤ/12ℤ. In other equal temperament systems (19-TET, 31-TET), the consonance structure changes and different pairs become generators or non-generators.

### 3.4 Multiplicative Rigidity

**Theorem 3.11** (Consonance Multiplicative Rigidity). If k ∈ (ℤ/12ℤ)× satisfies: for all consonant n, k·n is also consonant, then k = 1.

*Proof sketch.* The units of ℤ/12ℤ are {1, 5, 7, 11}. We verify:
- k = 5: 5·7 = 35 ≡ 11, which is dissonant. ✗
- k = 7: 7·3 = 21 ≡ 9 (consonant), 7·4 = 28 ≡ 4 (consonant), 7·7 = 49 ≡ 1 (dissonant). ✗
- k = 11: 11·7 = 77 ≡ 5, which is dissonant. ✗

Only k = 1 works. ∎

**PEGB Analysis:**

- **P**roof: Verified as `consonance_multiplicative_rigidity`.
- **E**xample: Multiplication by 5 (the "cycle of fourths" transformation) maps C-G (fifth) to C-B (seventh)—destroying the consonance.
- **G**eneralization: One could study *affine* automorphisms (n ↦ kn + c) or *permutation* automorphisms of the consonant set, relaxing the multiplicative constraint.
- **B**oundary: The rigidity is specific to the 6-element consonant set. Other musically meaningful subsets of ℤ/12ℤ (e.g., the whole-tone scale {0,2,4,6,8,10}) have non-trivial multiplicative automorphisms.

### 3.5 Tension-Parallel Correspondence

**Theorem 3.12** (Tension-Parallel Correspondence). For a consonant interval n: tension level τ(n) ≤ 1 if and only if parallel motion to n is forbidden.

This establishes a bridge between the *order-theoretic* structure (tension as a partial order) and the *categorical* structure (parallel motion as self-morphisms). The counterpoint rules are equivalent to: "self-morphisms are forbidden on the minimal elements of the tension ordering."

## 4. Discussion

### 4.1 The Counterpoint Semicategory

The voice-leading quiver Q generates a free category on its 34 edges. However, if we view the counterpoint transitions as a *category* with composition, we encounter a fundamental issue: the perfect consonances lack identity morphisms (since self-transitions are forbidden). This means the counterpoint structure is technically a *semicategory* (or semigroupoid)—a category-like structure without the identity axiom.

This is mathematically significant. The distinction between categories and semicategories is rarely relevant in pure mathematics, but counterpoint provides a natural example where it matters. The perfect consonances are "unstable fixed points"—you can pass through them but cannot remain.

### 4.2 Connection to the Poset Conjecture

The original conjecture proposed that the counterpoint category is equivalent to the thin category of a 12-element poset. Our analysis shows this is **false** in its literal form:

1. The category has 6 objects (consonant intervals), not 12.
2. The transition structure is nearly complete (34/36 edges), far from a poset (which would have many missing edges due to antisymmetry).
3. The transition relation is symmetric (if i→j is allowed, so is j→i for cross-transitions), so a thin quotient would give a groupoid, not a poset.

However, the spirit of the conjecture—that counterpoint has a hidden order structure—is confirmed by the tension ordering. The tension function τ defines a partial order on consonances that precisely captures the perfect/imperfect dichotomy and its consequences for parallel motion.

### 4.3 Bridge to Pythagorean Music Theory

This work extends the static consonance classification from `Catalog/Pythagorean/HarmonicMusicTheory.lean`, which established that the Pythagorean triple (3,4,5) generates the consonant frequency ratios 4/3 (perfect fourth), 5/4 (major third), and 5/3 (major sixth). Our contribution is the *dynamic* extension: from "which intervals are consonant?" to "which transitions between consonances are legal?"

The connection is deeper than it appears. The frequency ratios 4/3, 5/4, 5/3 correspond to interval classes 5, 4, 9 in ℤ/12ℤ (in equal temperament approximation). The fact that 5 (the fourth) is dissonant while 4 and 9 are consonant mirrors our complement asymmetry theorem: the fourth is the unique complement-breaking element.

## 5. Algorithms

### 5.1 Consonance Checking
Given an interval n ∈ {0,...,11}, check membership in {0,3,4,7,8,9}. O(1) time.

### 5.2 Voice-Leading Validation
Given a pair of intervals (i,j), check the transition predicate. O(1) time.

### 5.3 Subgroup Generation
Given a set S ⊂ ℤ/12ℤ, compute the generated subgroup by BFS on the Cayley graph. O(12|S|) time.

## 6. Future Work

1. **Higher species**: Extend to second through fifth species counterpoint, where passing tones, suspensions, and other dissonance treatments create richer categorical structure.

2. **Non-12 temperaments**: Study the consonance algebra for 19-TET, 31-TET, and other equal temperaments. The generation dichotomy and rigidity theorems should have analogs.

3. **Category enrichment**: Replace the Boolean "allowed/forbidden" with a graded structure (enriched category over ℝ or a suitable semiring) that captures degrees of consonance.

4. **Inverse problems**: Given a set of algebraic constraints (complement closure, generation properties, rigidity), characterize which subsets of ℤ/nℤ satisfy them. Is the 12-TET consonant set unique in some formal sense?

## 7. References

1. Fux, J.J. (1725). *Gradus ad Parnassum*. Vienna.
2. Tymoczko, D. (2011). *A Geometry of Music*. Oxford University Press.
3. `Catalog/Pythagorean/HarmonicMusicTheory.lean` — Pythagorean triple consonance classification.
4. `Novelty/CounterpointCategory.lean` — Machine-verified proofs of all theorems in this paper.
