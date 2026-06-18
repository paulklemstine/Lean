# Counterpoint as Category Theory: Voice Leading Categories over ℤ/12ℤ

## Abstract

We formalize first-species counterpoint (Fux, 1725) as a category where objects are consonant interval classes in ℤ/12ℤ and morphisms are permitted voice leading motions. We identify and prove several structural results: (1) the Fourth Anomaly — the consonant interval set is not closed under inversion due to the perfect fifth/fourth asymmetry, with exactly 5 of 6 consonances having consonant inversions; (2) the 2/4 Law — transitions to perfect consonances admit exactly 2 motion types while transitions to imperfect consonances admit all 4, yielding 120 total abstract morphisms; (3) Contrary Motion Completeness — the contrary-motion subcategory is a complete graph on 6 vertices; (4) a bridge to order theory via the consonance distance preorder. All results are machine-verified in the Lean 4 proof assistant with the Mathlib library. The formalization reveals that the classical rules of counterpoint encode precise algebraic constraints arising from the group structure of ℤ/12ℤ and the combinatorial properties of the consonance set {0, 3, 4, 7, 8, 9}.

## 1. Introduction

Species counterpoint, as codified by Fux [1] and refined by subsequent theorists, provides a rule-based system for composing multiple independent melodic lines. The rules constrain which intervals may appear between voices (consonance) and how voices may move from one interval to the next (voice leading). While these rules have been studied extensively from musical, acoustic, and cognitive perspectives, a rigorous algebraic analysis of their structure has been lacking.

We model first-species counterpoint as a *constrained category* over the cyclic group ℤ/12ℤ. In this framework:
- **Objects** are consonant interval classes: elements of the set C = {0, 3, 4, 7, 8, 9} ⊂ ℤ/12ℤ
- **Morphisms** from interval *a* to interval *b* are permitted voice leading motions, classified by motion type (contrary, oblique, similar, parallel)
- **Composition** is sequential voice leading

This categorical perspective reveals structural properties that are not apparent from the traditional rule-based formulation.

### 1.1 Relation to Prior Work

This work builds on and extends:
- **Catalog entry `FINAL/Pythagorean/HarmonicMusicTheory.lean`**: The `root_triple_consonant_intervals` theorem establishing basic properties of consonant intervals in relation to Pythagorean triples.
- **Catalog entry `Catalog/Algebra/MusicalCounterpoint.lean`**: Voice leading cost functions, the seminorm structure, and the no-parallel-perfects constraint. Our work extends this from cost analysis to full categorical structure.
- **Catalog entry `Bridges/KnuthBendixCompletion.lean`** (`finished_rules_eq_theory`): The technique of showing that a finite set of rules generates exactly a specified theory, which we adapt to show that counterpoint rules generate a specific morphism set.

### 1.2 Summary of Contributions

| Result | Statement | Significance |
|--------|-----------|-------------|
| Fourth Anomaly | ¬(∀ i ∈ C, -i ∈ C) | Consonance breaks inversion symmetry |
| Neg-stable count | |{i ∈ C : -i ∈ C}| = 5 | Exactly one consonance breaks symmetry |
| 2/4 Law | |Mor(a,b)| = 2 if b perfect, 4 if imperfect | Morphism count depends only on target |
| Morphism count | |Mor| = 120 = 5! | Total abstract morphism count |
| Contrary completeness | ∀ a,b ∈ C, ∃ contrary motion a → b | Complete subgraph on 6 vertices |
| Hexachordal balance | |C| = |ℤ/12ℤ \ C| = 6 | Equal consonant/dissonant partition |
| Non-additivity | C + C ⊄ C | Consonances don't form a subgroup |
| Self-inverse uniqueness | ∀ i ∈ C, -i = i → i = 0 | Only unison is self-inverse among consonances |

## 2. Definitions

### 2.1 Interval Classes

**Definition 2.1.** An *interval class* is an element of the cyclic group ℤ/12ℤ, representing the distance between two pitch classes measured in semitones modulo the octave.

**Definition 2.2.** The *consonant set* is C = {0, 3, 4, 7, 8, 9} ⊂ ℤ/12ℤ. This decomposes as:
- *Perfect consonances*: P = {0, 7} (unison and perfect fifth)
- *Imperfect consonances*: I = {3, 4, 8, 9} (thirds and sixths)

with C = P ⊔ I (disjoint union), |P| = 2, |I| = 4.

### 2.2 Voice Leading

**Definition 2.3.** A *voice leading* from interval *a* to interval *b* is a tuple (a, b, δ_bass, δ_soprano) ∈ ℤ/12ℤ × ℤ/12ℤ × ℤ × ℤ satisfying the *coherence condition*: a + (δ_soprano - δ_bass) ≡ b (mod 12).

**Definition 2.4.** The *motion type* of a voice leading is classified as:
- **Parallel**: δ_bass = δ_soprano
- **Oblique**: δ_bass = 0 or δ_soprano = 0 (but not parallel)
- **Contrary**: sgn(δ_bass) ≠ sgn(δ_soprano) (but not oblique)
- **Similar**: sgn(δ_bass) = sgn(δ_soprano) (but not parallel)

### 2.3 First-Species Validity

**Definition 2.5.** A voice leading (a, b, δ_bass, δ_soprano) is *first-species valid* if:
1. a, b ∈ C (both intervals are consonant)
2. The coherence condition holds
3. If the motion is parallel with δ_bass ≠ 0, then b ∉ P
4. If the motion is similar, then b ∉ P

These rules formalize Fux's prohibition on parallel and similar motion to perfect consonances.

## 3. Main Results

### 3.1 The Fourth Anomaly (Theorem 3.1)

**Theorem 3.1** (consonance_neg_not_closed). *The consonant set C is not closed under negation in ℤ/12ℤ.*

*Proof.* -7 ≡ 5 (mod 12), and 5 ∉ C. □

This is significant because the imperfect consonances I = {3, 4, 8, 9} *are* closed under negation: -3 = 9, -4 = 8, -9 = 3, -8 = 4. The symmetry breaks at the perfect consonances: -0 = 0 ∈ P, but -7 = 5 ∉ C.

**Theorem 3.2** (neg_stable_count). *|{i ∈ C : -i ∈ C}| = 5.*

*Proof.* The five neg-stable consonances are {0, 3, 4, 8, 9}. The unique neg-unstable consonance is 7 (perfect fifth). □

**Corollary 3.3** (fourth_anomaly). *The perfect fourth (5) is the unique element of ℤ/12ℤ that is not consonant but whose negation is consonant.*

This anomaly explains the historical controversy surrounding the perfect fourth in counterpoint theory. Acoustically, the fourth is as "pure" as the fifth (both arise from simple frequency ratios), yet counterpoint treats them asymmetrically. Our formalization shows this asymmetry is forced by the algebraic structure of the consonance set.

### 3.2 The 2/4 Law (Theorems 3.4-3.5)

**Theorem 3.4** (two_four_perfect). *For b ∈ P and motion type m, the constraint (m ∈ {parallel, similar} → b ∉ P) is equivalent to m ∈ {contrary, oblique}.*

**Theorem 3.5** (two_four_imperfect). *For b ∈ I and any motion type m, the constraint (m ∈ {parallel, similar} → b ∉ P) holds trivially.*

These theorems establish the 2/4 Law: transitions to perfect consonances admit exactly 2 motion types (contrary, oblique), while transitions to imperfect consonances admit all 4 motion types. This asymmetry is a direct consequence of the definitions and the disjointness of P and I.

**Corollary 3.6** (morphism_count). *The counterpoint category has 6 × 2 × 2 + 6 × 4 × 4 = 120 abstract morphisms.*

The number 120 = 5! is suggestive of a connection to the symmetric group S₅, though we have not established such a connection.

### 3.3 Contrary Motion Completeness (Theorem 3.7)

**Theorem 3.7** (contrary_motion_complete). *For any a, b ∈ C, there exists a valid first-species voice leading from a to b with contrary motion.*

*Proof.* We construct explicit witnesses. For arbitrary a, b ∈ C, set δ_bass to a negative value and δ_soprano to a positive value such that (δ_soprano - δ_bass) ≡ b - a (mod 12). The coherence condition is satisfied by construction, and since the motion type is contrary, the constraint on perfect targets does not apply. □

This theorem establishes that the contrary-motion subcategory is a complete directed graph K₆ on 6 vertices, with 36 morphisms.

### 3.4 Hexachordal Balance (Theorem 3.8)

**Theorem 3.8** (hexachordal_balance). *|C| = |ℤ/12ℤ \ C| = 6.*

The consonant and dissonant interval classes form an equal partition of the chromatic space. This hexachordal balance relates to the hexachordal combinatoriality property studied in twelve-tone theory.

### 3.5 Non-Subgroup Structure (Theorem 3.9)

**Theorem 3.9** (consonant_not_additive). *C is not closed under addition in ℤ/12ℤ.*

*Proof.* 3 + 3 = 6 ∉ C. □

Despite not forming a subgroup, C has interesting additive structure. For instance, 3 + 4 = 7 (the perfect fifth is the sum of minor and major thirds), which is a fundamental fact of music theory.

### 3.6 Self-Inverse Uniqueness (Theorem 3.10)

**Theorem 3.10** (consonant_self_inverse_only_zero). *For i ∈ C, -i = i if and only if i = 0.*

Among the full group ℤ/12ℤ, the elements satisfying -i = i are {0, 6}. Since 6 ∉ C (the tritone is dissonant), the only self-inverse consonance is the unison.

## 4. The Counterpoint Category: Structure

### 4.1 Objects and Morphisms

The counterpoint category **Cpt** has:
- 6 objects (consonant interval classes)
- 120 abstract morphisms (valid voice leading types)
- Identity morphisms at each object (stationary voice leading)

### 4.2 Subcategories

| Subcategory | Morphism restriction | Count | Structure |
|-------------|---------------------|-------|-----------|
| Contrary | Only contrary motion | 36 | Complete graph K₆ |
| Oblique | Only oblique motion | 36 | Complete graph K₆ |
| Parallel | Only parallel motion | 24 | Bipartite: C → I |
| Similar | Only similar motion | 24 | Bipartite: C → I |

The parallel and similar subcategories have the same structure: all 6 sources can reach all 4 imperfect targets, but no perfect targets. This creates a bipartite-like structure that distinguishes the counterpoint category from a free category.

### 4.3 Composition

We prove that composition of coherent voice leadings is coherent (Theorem `seq_coherent`), establishing that the sequential application of voice leadings respects the interval arithmetic.

## 5. The Consonance Preorder

### 5.1 Circle Distance

We define the *circle distance* of an interval class as min(v, 12-v) where v is the value in {0, ..., 11}. This measures proximity to the unison in the chromatic circle.

### 5.2 Preorder Structure

The circle distance induces a preorder on interval classes:
- **Minimum**: Unison (distance 0) — most consonant
- **Maximum among consonances**: Perfect fifth (distance 5) — least consonant among consonances

The preorder has three levels among consonances:
1. Distance 0: {0} (unison) — 1 element
2. Distance 3: {3, 9} (minor third, major sixth) — 2 elements
3. Distance 4: {4, 8} (major third, minor sixth) — 2 elements
4. Distance 5: {7} (perfect fifth) — 1 element

This preorder connects music theory to lattice theory: the consonance hierarchy becomes a partially ordered set with precise algebraic properties.

## 6. Discussion

### 6.1 The Original Conjecture

The original conjecture — that the counterpoint category is equivalent to the thin category generated by a poset of 12 elements — turns out to be false in its exact form. The counterpoint category has 6 objects (not 12), and it is *not* thin (multiple morphisms between the same pair of objects, one for each valid motion type). However, the category has a rich structure that can be analyzed through its subcategories, each of which has a clear poset-theoretic interpretation.

### 6.2 Comparison with Existing Work

Our formalization extends the existing `MusicalCounterpoint.lean` catalog entry, which focused on the cost function (L¹ norm) and its seminorm properties. While that work analyzed *how much* voices move, our work analyzes *which transitions are structurally permitted*, revealing the categorical skeleton underlying counterpoint.

### 6.3 Connection to the Existing `root_triple_consonant_intervals` Theorem

The `root_triple_consonant_intervals` theorem in `FINAL/Pythagorean/HarmonicMusicTheory.lean` establishes consonant intervals in relation to Pythagorean triples. Our work complements this by analyzing the consonance set as a subset of ℤ/12ℤ rather than through frequency ratios, showing that the algebraic properties of {0, 3, 4, 7, 8, 9} in the cyclic group are sufficient to derive the structure of counterpoint without reference to acoustics.

## 7. Future Work

1. **Higher species**: Extend to second and third species counterpoint, where passing tones and suspensions create richer categorical structures.
2. **The 120 = 5! coincidence**: Investigate whether the morphism count reflects a genuine connection to S₅.
3. **Tropical counterpoint**: Reformulate voice leading costs in the tropical semiring, connecting to the tropical geometry literature.
4. **n-voice categories**: Extend from two voices to n voices, where the morphism constraints become more complex.

## 8. References

[1] J.J. Fux, *Gradus ad Parnassum*, 1725.

[2] D. Tymoczko, *A Geometry of Music: Harmony and Counterpoint in the Extended Common Practice*, Oxford University Press, 2011.

[3] `Catalog/Algebra/MusicalCounterpoint.lean` — Voice leading cost functions and seminorm structure.

[4] `FINAL/Pythagorean/HarmonicMusicTheory.lean` — Consonant intervals and Pythagorean triples (`root_triple_consonant_intervals`).

[5] `FINAL/Bridges/KnuthBendixCompletion.lean` — Rule completion theory (`finished_rules_eq_theory`).

[6] `Catalog/Bridges/TropicalCounterpoint/Defs.lean` — Tropical counterpoint foundations.
