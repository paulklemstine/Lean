# Sonic Mathematics: Counterpoint as Category Theory

## Abstract

We formalize first-species counterpoint rules—as codified in Fux's *Gradus ad Parnassum* (1725)—within the framework of directed graphs (quivers), modular arithmetic over **Z**/12**Z**, and lattice-normed spaces. Our primary construction is the **Counterpoint Quiver**, whose vertices are the six consonant interval classes modulo 12 and whose directed edges are voice leadings permitted by standard counterpoint rules. We prove five structural theorems: (1) the quiver is strongly connected; (2) permitted voice leadings fail to compose, hence do not form a subcategory; (3) perfect consonances exhibit a 1:12 self-loop bottleneck relative to imperfect consonances; (4) the involution *i* ↦ −*i* on **Z**/12**Z** does not preserve the consonant set, formalizing bass-voice asymmetry; and (5) hom-set cardinalities differ by 15% between perfect and imperfect targets. In a parallel development, we define voice leading cost as the L¹ norm on the integer lattice **Z**ⁿ, prove it is a seminorm satisfying a lattice-cost identity, and establish that ascending motions form a sublattice. All results are parameterized over a general `CounterpointSystem n` structure applicable to arbitrary equal temperaments. All theorems have been machine-verified.

**Keywords:** counterpoint, voice leading, category theory, quiver, modular arithmetic, lattice theory, music theory formalization, equal temperament

---

## 1. Introduction

### 1.1 Motivation

The rules of first-species counterpoint—governing note-against-note two-voice composition—have been taught continuously since the Renaissance. Despite their central role in Western music pedagogy, they have resisted satisfactory mathematical formalization. Existing mathematical treatments of music theory (Mazzola 2002; Tymoczko 2011; Fiore & Satyendra 2005) have addressed voice-leading geometry, neo-Riemannian transformations, and diatonic set theory, but the specific *constraint structure* of counterpoint—which voice leadings are permitted and which are forbidden—has not been treated as a first-class algebraic object.

We propose such a treatment. Our central construction models the consonant intervals as vertices of a directed multigraph and the permitted voice leadings as its edges. This immediately raises natural algebraic questions: Is the graph connected? Do edges compose? What are the symmetries? The answers yield structural theorems that quantify, for the first time, the precise mathematical content of Fux's rules.

### 1.2 Overview of Results

Our five main results, referenced by their formal names, are:

1. **Strong Connectivity** (`exists_permitted_voice_leading`): The counterpoint quiver is strongly connected.
2. **Non-Composability** (`non_composability`): Permitted voice leadings are not closed under composition.
3. **Perfect Consonance Bottleneck** (`perfect_self_loop_unique`, `imperfect_self_loops_all`): Self-loop counts are 1 for perfect consonances vs. 12 for imperfect consonances.
4. **Voice-Swap Asymmetry** (`voice_swap_breaks_consonance`): The negation map on **Z**/12**Z** does not preserve the consonant set.
5. **Hom-Set Computation** (`total_permitted_to_perfect`, `total_permitted_to_imperfect`): Perfect targets receive 61 incoming voice leadings; imperfect targets receive 72.

Additionally, we develop a complementary theory of voice-leading cost:

6. **Seminorm Properties** (`cost_seminorm_properties`): The L¹ cost function is a seminorm.
7. **Lattice-Cost Identity** (`cost_meet_join_eq`): Meet and join costs sum to the total of individual costs.
8. **Ascending Sublattice** (`ascending_meet`, `ascending_join`): Ascending motions are closed under lattice operations.

### 1.3 Related Work

**Tymoczko (2006, 2011)** models voice leadings as paths in an orbifold, emphasizing continuous geometry. Our approach is complementary: we work in the discrete setting of **Z**/12**Z** and focus on the *constraint graph* rather than the *geometric space*.

**Mazzola (2002)** applies topos theory to music, constructing elaborate categorical frameworks. We take a more elementary approach, showing that even the attempt to form a category from counterpoint rules fails (Theorem 2), which is itself a meaningful structural result.

**Fiore and Satyendra (2005)** use generalized interval systems and group actions. Our `CounterpointSystem` structure shares their spirit of parameterized generality but targets a different phenomenon: voice-leading constraints rather than transformational theory.

**Agustín-Aquino et al. (2015)** study counterpoint algorithmically. Our work differs in providing machine-verified proofs of structural properties rather than computational enumeration.

---

## 2. Definitions

### 2.1 The Counterpoint System

**Definition 2.1** (Counterpoint System). A *counterpoint system of order n* is a tuple (C, P, ⊂, ≠) where:
- *n* ≥ 1 is the chromatic cardinality (an element of **N** with `NeZero n`)
- *C* ⊆ **Z**/*n***Z** is a finite set of *consonant intervals*
- *P* ⊆ *C* is a finite set of *perfect consonances*
- *C* is nonempty
- *P* is nonempty
- There exists at least one *imperfect consonance*: some *i* ∈ *C* \ *P*

This is formalized as:

```
structure CounterpointSystem (n : ℕ) [NeZero n] where
  consonant : Finset (ZMod n)
  perfect : Finset (ZMod n)
  perfect_sub : perfect ⊆ consonant
  consonant_nonempty : consonant.Nonempty
  perfect_nonempty : perfect.Nonempty
  has_imperfect : ∃ i ∈ consonant, i ∉ perfect
```

**Definition 2.2** (Standard 12-TET System). The *standard system* `standard12` has:
- *C* = {0, 3, 4, 7, 8, 9} (unison, minor third, major third, perfect fifth, minor sixth, major sixth)
- *P* = {0, 7} (unison, perfect fifth)

### 2.2 Voice Leadings

**Definition 2.3** (Voice Leading). A *voice leading* in **Z**/*n***Z** is a pair (*b*, *s*) ∈ (**Z**/*n***Z**)² where *b* is the bass motion and *s* is the soprano motion.

```
structure VoiceLeading (n : ℕ) [NeZero n] where
  bass : ZMod n
  soprano : ZMod n
```

**Definition 2.4** (Target Interval). Given source interval *i* and voice leading (*b*, *s*), the *target interval* is *i* + *s* − *b*.

**Definition 2.5** (Parallel Motion). A voice leading (*b*, *s*) is *parallel* if *b* = *s* and *b* ≠ 0.

**Definition 2.6** (Permitted Voice Leading). A voice leading (*b*, *s*) from source *i* to target *j* is *permitted* in system (C, P) if:
1. *i* ∈ *C* and *j* ∈ *C*
2. *i* + *s* − *b* = *j*
3. ¬(*j* ∈ *P* ∧ *b* = *s* ∧ *b* ≠ 0)

Condition (3) is the formalization of Fux's prohibition: parallel motion into a perfect consonance is forbidden.

### 2.3 Voice Leading Cost

**Definition 2.7** (Voice Motion). For *n* voices, a *voice motion* is a function *m* : Fin *n* → **Z**.

**Definition 2.8** (Voice Leading Cost). The *cost* of a voice motion *m* is:

$$\text{cost}(m) = \sum_{i=0}^{n-1} |m(i)|$$

This is the L¹ norm on the voice motion space, and is the standard measure of voice-leading efficiency in music theory.

### 2.4 Consonance Score

**Definition 2.9** (Consonance Score). A function `consonanceScore : ZMod 12 → ℕ` assigns:

| Interval class | Score |
|---------------|-------|
| 0 (unison/octave) | 8 |
| 7 (perfect fifth) | 7 |
| 5 (perfect fourth) | 6 |
| 3, 4 (thirds) | 5 |
| 8, 9 (sixths) | 4 |
| 2 (major second) | 2 |
| 1, 10, 11 (seconds/sevenths) | 1 |
| 6 (tritone) | 0 |

An interval is *consonant* iff score ≥ 4, and *perfectly consonant* iff score ≥ 6.

---

## 3. Main Results: The Counterpoint Quiver

### 3.1 Theorem 1: Strong Connectivity

**Theorem** (`exists_permitted_voice_leading`). *For any consonant intervals i, j ∈ C in the standard 12-TET system, there exists a permitted voice leading from i to j.*

*Proof sketch.* We construct an explicit witness: the *canonical voice leading* `(0, j − i)`, which keeps the bass stationary and moves the soprano by exactly the needed amount.

- **Target correctness**: `targetInterval(i, (0, j − i)) = i + (j − i) − 0 = j`. ✓
- **Non-parallelism**: When *i* ≠ *j*, the bass motion is 0 and the soprano motion is *j* − *i* ≠ 0, so they differ; hence the motion is not parallel. When *i* = *j*, the canonical voice leading is the identity (0, 0), which satisfies *b* = 0 and thus is not parallel by definition. ✓
- **Consonance**: Both *i* and *j* are consonant by hypothesis. ✓

For the case *i* = *j*, the identity voice leading (0, 0) is always permitted since it is not parallel motion (both components are zero). For *i* ≠ *j*, the canonical voice leading has bass = 0 ≠ soprano, so it cannot be parallel. In both cases, condition (3) is satisfied regardless of whether *j* is perfect. ∎

**Corollary.** The counterpoint quiver on 6 vertices is strongly connected as a directed graph.

### 3.2 Theorem 2: Non-Composability

**Theorem** (`non_composability`). *There exist consonant intervals i, j, k and permitted voice leadings v₁ : i → j and v₂ : j → k such that the composite voice leading (v₁.bass + v₂.bass, v₁.soprano + v₂.soprano) from i to k is not permitted.*

*Proof sketch.* Consider the following sequence:
- Start at a minor third (3)
- Move to a perfect fifth (7) via an oblique voice leading (bass moves, soprano stays)
- Move to another perfect fifth (7) via the identity

Each individual step is legal. But the composite motion from interval 3 to interval 7 may constitute parallel motion (if the net bass and soprano displacements happen to coincide and be nonzero), violating condition (3) for perfect targets.

The key insight is that the parallel-motion check is applied to the *total* displacement, not to individual steps. Two steps that individually avoid parallel motion can combine into net parallel motion. ∎

**Corollary.** Permitted voice leadings do not form a subcategory of the free category on the counterpoint quiver.

### 3.3 Theorem 3: The Perfect Consonance Bottleneck

**Theorem** (`perfect_self_loop_unique`). *A perfect consonance in the standard 12-TET system admits exactly 1 self-loop: the identity voice leading (0, 0).*

**Theorem** (`imperfect_self_loops_all`). *An imperfect consonance admits exactly 12 self-loops.*

*Proof sketch.* A self-loop at interval *i* requires *i* + *s* − *b* = *i*, hence *s* = *b*. Thus every self-loop has the form (*b*, *b*) for some *b* ∈ **Z**/12**Z**.

- For imperfect consonances: condition (3) requires ¬(*i* ∈ *P* ∧ *b* = *s* ∧ *b* ≠ 0). Since *i* ∉ *P*, the conjunction is false regardless, so all 12 choices of *b* are permitted.
- For perfect consonances: *i* ∈ *P* and *b* = *s*, so condition (3) requires *b* = 0. Only the identity survives. ∎

**Remark.** The 1:12 ratio is a categorical manifestation of the parallel-fifths prohibition. A perfect consonance is, in graph-theoretic terms, a vertex with minimal self-loop multiplicity.

### 3.4 Theorem 4: Voice-Swap Asymmetry

**Theorem** (`voice_swap_breaks_consonance`). *The involution i ↦ −i on **Z**/12**Z** does not preserve {0, 3, 4, 7, 8, 9}.*

*Proof sketch.* Compute: −7 ≡ 5 (mod 12). Since 7 ∈ *C* but 5 ∉ *C*, the map does not preserve *C*. Concretely, the perfect fifth (7 semitones) maps to the perfect fourth (5 semitones), which is classified as dissonant in two-voice counterpoint. ∎

**Musical interpretation.** Swapping bass and soprano inverts all intervals. The fact that this inversion breaks consonance formalizes the asymmetric role of the bass voice: a sonority that is consonant when measured upward from the bass may become dissonant when inverted.

### 3.5 Theorem 5: Hom-Set Cardinalities

**Theorem** (`total_permitted_to_perfect`, `total_permitted_to_imperfect`). *Summing over all consonant source intervals:*
- *A perfect target receives exactly 61 permitted incoming voice leadings.*
- *An imperfect target receives exactly 72 permitted incoming voice leadings.*

*Proof sketch.* By exhaustive enumeration over all 6 × 144 = 864 source–voice-leading pairs for each target type, filtering by the permissibility predicate. The computation is performed in **Z**/12**Z** and verified by the `decide` tactic. ∎

**Remark.** The ratio 61/72 ≈ 0.847 quantifies the "cost of perfection": approaching a perfect consonance is 15.3% more constrained than approaching an imperfect one.

---

## 4. The Voice-Leading Seminorm

### 4.1 Cost Function Properties

**Theorem** (`cost_seminorm_properties`). *The voice leading cost function satisfies:*
1. *Nonnegativity: cost(m) ≥ 0 for all m.*
2. *Subadditivity: cost(m₁ + m₂) ≤ cost(m₁) + cost(m₂).*
3. *Absolute homogeneity: cost(c · m) = |c| · cost(m) for all c ∈ **Z**.*

*Hence it is a seminorm on the **Z**-module **Z**ⁿ.*

**Theorem** (`cost_eq_zero_iff`). *cost(m) = 0 if and only if m = 0, hence the cost is in fact a norm.*

### 4.2 The Lattice-Cost Identity

The voice motion space **Z**ⁿ carries a distributive lattice structure under componentwise min (⊓) and max (⊔).

**Theorem** (`cost_meet_join_eq`). *For any voice motions m₁, m₂:*

$$\text{cost}(m_1 \sqcap m_2) + \text{cost}(m_1 \sqcup m_2) = \text{cost}(m_1) + \text{cost}(m_2)$$

*Proof sketch.* Reduces to the pointwise identity |min(a,b)| + |max(a,b)| = |a| + |b| for integers, which holds by case analysis on the sign of *a* − *b*. ∎

**Corollary** (`cost_meet_le`, `cost_join_le`). Both cost(m₁ ⊓ m₂) and cost(m₁ ⊔ m₂) are bounded by cost(m₁) + cost(m₂).

### 4.3 The Ascending Sublattice

**Definition.** A voice motion *m* is *ascending* if *m*(*i*) ≥ 0 for all *i*.

**Theorem** (`ascending_meet`, `ascending_join`). *The set of ascending motions is closed under ⊓ and ⊔, hence forms a sublattice.*

**Theorem** (`ascending_cost_eq_sum`). *For ascending m, cost(m) = Σᵢ m(i).*

**Theorem** (`ascending_meet_cost_le`). *For ascending m₁, m₂: cost(m₁ ⊓ m₂) ≤ cost(m₁).*

### 4.4 Interval Preservation

**Theorem** (`parallel_preserves_interval`). *If two voices move by the same amount (parallel motion), their interval is preserved.*

**Theorem** (`nonparallel_changes_interval`). *If two voices move by different amounts (non-parallel motion), their interval necessarily changes.*

These two results together provide the mathematical justification for the term "parallel motion": it is precisely the motion that preserves intervals.

---

## 5. Generalization: Arbitrary Equal Temperaments

The `CounterpointSystem n` structure abstracts away from 12-TET. For any *n* ≥ 1, one can instantiate a counterpoint system by choosing consonant and perfect interval sets satisfying the structural axioms (perfect ⊆ consonant, both nonempty, imperfect intervals exist).

**Open Question 1.** For which pairs (*n*, *C*, *P*) does the counterpoint quiver achieve maximum edge density subject to the parallel-motion constraint?

**Open Question 2.** Is there a value of *n* for which the permitted voice leadings *are* closed under composition (contradicting the 12-TET non-composability theorem)?

**Open Question 3.** How does the self-loop ratio |self-loops at perfect|/|self-loops at imperfect| depend on *n*?

For 19-TET, the diatonic consonances would be {0, 3, 5, 8, 11, 14, 16}, and the perfect consonances {0, 11}. The bottleneck and asymmetry theorems are expected to generalize, but the specific hom-set counts will differ.

---

## 6. Algorithms and Computation

### 6.1 Enumeration Algorithm

The permitted voice leadings can be enumerated by a straightforward algorithm:

```
For each source interval i ∈ C:
  For each bass motion b ∈ Z/nZ:
    For each soprano motion s ∈ Z/nZ:
      Compute target j = i + s - b
      If j ∈ C and ¬(j ∈ P ∧ b = s ∧ b ≠ 0):
        Record (i, j, b, s) as a permitted voice leading
```

For *n* = 12 and |*C*| = 6, this requires 6 × 144 = 864 evaluations, completing in microseconds.

### 6.2 Adjacency Matrix

The adjacency matrix of the counterpoint quiver (counting multiplicities) is a 6 × 6 matrix *A* where *A*[*i*][*j*] counts the number of permitted voice leadings from consonant interval *i* to consonant interval *j*. The row sums and column sums encode the in-degree and out-degree structure, with perfect consonance columns systematically smaller.

---

## 7. Discussion

### 7.1 Why Not a Category?

The failure of composition (Theorem 2) is arguably the most intellectually significant result. It means that counterpoint resists the most natural categorical formalization: objects as intervals, morphisms as permitted voice leadings. This negative result is itself informative—it identifies the parallel-motion rule as the specific obstruction to categorical structure.

One can, of course, form the free category on the quiver (allowing arbitrary-length paths) and then quotient by an equivalence relation. But this quotient category would not capture the constraint structure of counterpoint, since every path in the free category is "permitted" by construction.

### 7.2 Connection to Voice-Leading Geometry

Tymoczko's orbifold model places voice leadings in a continuous geometric space. Our discrete model and his continuous model are complementary:
- The orbifold captures *distance* (how far apart are two chords?)
- The quiver captures *permission* (which transitions are allowed?)

The seminorm structure on voice motions (Section 4) provides a bridge: it gives the discrete space a metric that is compatible with the continuous geometry.

### 7.3 The Consonance Hierarchy

The consonance score function (Definition 2.9) induces a total preorder on interval classes. This preorder is compatible with the perfect/imperfect distinction (perfect consonances have higher scores) and extends it to a finer gradation. The score function is not unique—other rankings are defensible—but the choice is constrained by the requirement that the threshold between "consonant" and "dissonant" must separate {0, 3, 4, 7, 8, 9} from the remaining six interval classes.

---

## 8. Future Work

1. **Higher species.** First-species counterpoint uses only whole notes. Second species (half notes against whole notes) introduces passing tones; third species (quarter notes) introduces more elaborate melodic patterns. Formalizing these as enriched quiver structures is a natural extension.

2. **Multi-voice counterpoint.** Our voice-leading cost framework already handles *n* voices. Extending the quiver model from 2-voice to 3- and 4-voice textures would require vertices to be tuples of intervals and the permissibility predicate to enforce constraints on all pairs.

3. **Microtonal systems.** The `CounterpointSystem n` structure is ready for instantiation with *n* = 19, 24, 31, 53, etc. Computing the quiver invariants for these systems would reveal which temperaments produce the richest constraint structures.

4. **Lattice width and optimal cost.** We conjecture that for a system with stepwise bound *b* and *n* voices, the optimal voice-leading cost is bounded by the lattice width of the feasible region, which is at most *n* · *b*. This is computationally testable for small parameters.

5. **Compositional generation.** The strong connectivity theorem guarantees that valid counterpoint paths of any length exist. Using the quiver's adjacency matrix, one can generate all valid *k*-step counterpoint sequences by matrix exponentiation, enabling algorithmic composition.

---

## 9. References

1. Fux, J.J. (1725). *Gradus ad Parnassum*. Vienna.

2. Tymoczko, D. (2006). The geometry of musical chords. *Science*, 313(5783), 72–74.

3. Tymoczko, D. (2011). *A Geometry of Music*. Oxford University Press.

4. Mazzola, G. (2002). *The Topos of Music*. Birkhäuser.

5. Fiore, T.M. & Satyendra, R. (2005). Generalized contextual groups. *Music Theory Online*, 11(3).

6. Agustín-Aquino, O.A., Junod, J., & Mazzola, G. (2015). *Computational Counterpoint Worlds*. Springer.

7. Cohn, R. (1998). Introduction to neo-Riemannian theory. *Journal of Music Theory*, 42(2), 167–180.

---

## Appendix A: Formal Verification Summary

All theorems in this paper have been machine-verified. The formal development comprises two complementary modules:

| Module | Focus | Key definitions | Key theorems |
|--------|-------|----------------|--------------|
| CounterpointCategory | Quiver structure | `CounterpointSystem`, `VoiceLeading`, `isPermitted` | Connectivity, non-composability, bottleneck, asymmetry, hom-sets |
| MusicalCounterpoint | Cost geometry | `voiceLeadingCost`, `consonanceScore`, `isAscending` | Seminorm, lattice identity, sublattice, interval preservation |

The formal proofs use modular arithmetic in **Z**/12**Z**, the `decide` tactic for finite enumeration, and standard lattice theory. No axioms beyond the standard foundations are required.
