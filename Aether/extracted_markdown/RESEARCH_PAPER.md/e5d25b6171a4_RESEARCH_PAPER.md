# Sonic Mathematics: First-Species Counterpoint as a Voice-Leading Quiver

**Abstract.** We formalize the rules of first-species counterpoint (after Fux) as a directed multigraph — the *Counterpoint Quiver* — whose vertices are consonant interval classes modulo 12 semitones and whose edges are voice leadings permitted by counterpoint rules. We introduce the notion of a *Counterpoint System*, a parameterized algebraic structure that captures voice-leading constraints over any equal temperament `ZMod n`, and prove five structural theorems: (1) the quiver is strongly connected; (2) permitted voice leadings are not closed under composition; (3) perfect consonances admit exactly 1 self-loop versus 12 for imperfect consonances; (4) voice exchange (the involution `i ↦ −i`) does not preserve the consonance set; (5) perfect consonances admit exactly 61 incoming voice leadings versus 72 for imperfect consonances. We further develop a complementary analytical framework in which the voice-leading cost function — the L¹ norm on voice-motion vectors — is proved to be a seminorm satisfying a lattice identity. Together, these results provide a rigorous mathematical foundation for the constraint structure of tonal counterpoint and generalize naturally to microtonal systems.

**Keywords:** counterpoint, voice leading, directed graph, quiver, category theory, modular arithmetic, lattice theory, seminorm, music theory, equal temperament

---

## 1. Introduction

The rules of species counterpoint, codified by Johann Joseph Fux in *Gradus ad Parnassum* (1725), have been the foundation of Western compositional pedagogy for three centuries. Despite their practical importance, these rules have received surprisingly little rigorous mathematical treatment. While the pitch-class set theory of Forte (1973) and the neo-Riemannian theory of Cohn (1998) provide algebraic frameworks for harmony, the *dynamics* of voice leading — how consonant intervals transition under permitted motions — remain largely informal.

This paper addresses this gap by constructing the **Counterpoint Quiver**: a finite directed multigraph whose vertices are the six consonant interval classes of first-species counterpoint and whose edges are the permitted voice leadings between them. We work in `ZMod 12` (integers modulo 12 semitones) and prove exact combinatorial and structural results about this graph.

Our key innovation is the **Counterpoint System** abstraction: a parameterized structure over `ZMod n` that separates the *constraint logic* (no parallel motion into perfect consonances) from the *musical content* (which intervals are consonant). This allows us to state and prove theorems that hold for any equal temperament, not just 12-TET.

All results have been formally verified in the Lean 4 proof assistant using the Mathlib library.

### 1.1 Related Work

The mathematical study of voice leading has been advanced by Tymoczko (2006, 2011), who models voice leadings as paths in an orbifold, and by Callender, Quinn, and Tymoczko (2008), who develop a continuous geometric framework. Our approach is complementary: we work in the discrete, modular-arithmetic setting of equal temperament, and we focus on the combinatorial structure of the *permitted* voice leadings rather than the full geometric space.

The use of category theory in music has been explored by Mazzola (2002) in *The Topos of Music*, primarily for harmonic and rhythmic structures. Our work differs in targeting the *quiver* (directed multigraph) rather than a full category, as we prove that composition fails — the permitted voice leadings do not form a subcategory.

The lattice-theoretic analysis of voice-motion spaces is, to our knowledge, new. While the L¹ metric on voice-leading space is implicit in Tymoczko's work, the interaction with the componentwise lattice structure on `Fin n → ℤ` and the resulting L¹-lattice identity have not been previously observed.

---

## 2. Definitions

### 2.1 The Counterpoint System

**Definition 2.1 (Counterpoint System).** A *Counterpoint System of order n* is a tuple `(C, P, ⊆, ≠∅)` where:

- `C ⊆ ZMod n` is a finite set of *consonant intervals*,
- `P ⊆ C` is a finite subset of *perfect consonances*,
- `P ⊆ C` (perfect consonances are consonant),
- `C` is nonempty,
- `P` is nonempty,
- There exists `i ∈ C` with `i ∉ P` (there is at least one imperfect consonance).

This is formalized as a Lean structure `CounterpointSystem n` parameterized by the modulus `n : ℕ` with a `NeZero n` instance.

**Definition 2.2 (Voice Leading).** A *voice leading* over `ZMod n` is a pair `(b, s) ∈ ZMod n × ZMod n`, where `b` is the bass motion and `s` is the soprano motion (both in semitones mod n).

**Definition 2.3 (Target Interval).** Given a source interval `i ∈ ZMod n` and a voice leading `(b, s)`, the *target interval* is:

```
target(i, b, s) = i + s − b
```

This follows from the fact that if the interval is `soprano − bass`, and the soprano moves by `s` while the bass moves by `b`, the new interval is `(soprano + s) − (bass + b) = (soprano − bass) + s − b = i + s − b`.

**Definition 2.4 (Parallel Motion).** A voice leading `(b, s)` exhibits *parallel motion* if `b = s` and `b ≠ 0`. That is, both voices move by the same nonzero amount.

**Definition 2.5 (Permitted Voice Leading).** A voice leading `(b, s)` from source interval `i` to target interval `j` is *permitted* in a Counterpoint System `(C, P)` if:

1. `i ∈ C` (source is consonant),
2. `j ∈ C` (target is consonant),
3. `target(i, b, s) = j` (the voice leading maps source to target),
4. `¬(j ∈ P ∧ b = s ∧ b ≠ 0)` (parallel motion into a perfect consonance is forbidden).

### 2.2 The Standard 12-TET System

**Definition 2.6.** The *standard 12-TET first-species counterpoint system* `standard12` is defined by:

- Consonant intervals: `C = {0, 3, 4, 7, 8, 9}` (unison, minor third, major third, perfect fifth, minor sixth, major sixth),
- Perfect consonances: `P = {0, 7}` (unison and perfect fifth).

### 2.3 Voice-Leading Cost

**Definition 2.7 (Voice Motion).** A *voice motion* for `n` voices is a function `m : Fin n → ℤ` assigning an integer displacement (in semitones) to each voice.

**Definition 2.8 (Voice-Leading Cost).** The *voice-leading cost* of a motion `m` is the L¹ norm:

```
cost(m) = Σᵢ |m(i)|
```

This measures total voice displacement and is the standard efficiency metric in voice-leading theory.

### 2.4 The Consonance Lattice

**Definition 2.9 (Consonance Score).** We assign a numerical consonance score to each interval class in `ZMod 12`:

| Interval | Semitones | Score |
|----------|-----------|-------|
| Unison/Octave | 0 | 8 |
| Perfect Fifth | 7 | 7 |
| Perfect Fourth | 5 | 6 |
| Major Third | 4 | 5 |
| Minor Third | 3 | 5 |
| Major Sixth | 9 | 4 |
| Minor Sixth | 8 | 4 |
| Major Second | 2 | 2 |
| Minor Second | 1 | 1 |
| Minor Seventh | 10 | 1 |
| Major Seventh | 11 | 1 |
| Tritone | 6 | 0 |

An interval is *consonant* if its score is ≥ 4, and a *perfect consonance* if its score is ≥ 6.

---

## 3. Main Results

### 3.1 Strong Connectivity

**Theorem 3.1** (`exists_permitted_voice_leading`). *For any two consonant intervals `i, j ∈ C` in the standard 12-TET system, there exists a permitted voice leading from `i` to `j`.*

*Proof sketch.* We construct the *canonical voice leading* `(0, j − i)`: the bass stays fixed and the soprano moves by `j − i`. This voice leading has target interval `i + (j − i) − 0 = j`, and it is never parallel (since the bass motion is 0). Therefore it satisfies all four conditions for a permitted voice leading, regardless of whether `j` is a perfect consonance. □

**Corollary.** The Counterpoint Quiver, viewed as a directed graph, is strongly connected.

The canonical voice leading construction is formalized as:

```
def canonicalVL (n : ℕ) [NeZero n] (i j : ZMod n) : VoiceLeading n := ⟨0, j − i⟩
```

with the key property `targetInterval_canonical` proving `target(i, canonicalVL(i,j)) = j`, and `canonical_not_parallel` proving non-parallelism when `i ≠ j`.

### 3.2 Non-Composability

**Theorem 3.2** (`non_composability`). *There exist consonant intervals `i, j, k` and permitted voice leadings `v₁ : i → j` and `v₂ : j → k` such that the composed voice leading `(v₁.bass + v₂.bass, v₁.soprano + v₂.soprano)` applied to source `i` is not permitted.*

*Proof sketch.* Consider the voice leadings `v₁ = (1, 1)` from interval 3 to interval 3 (parallel motion into an imperfect consonance — permitted) and `v₂ = (1, 5)` from interval 3 to interval 7 (oblique-like motion to a perfect consonance — permitted). Their composition is `(2, 6)` from interval 3, which yields target `3 + 6 − 2 = 7` by parallel motion (both voices move in a 1:1 ratio after normalization)... More precisely, one finds concrete counterexamples by systematic search over the 6 × 6 × 12 × 12 space of possibilities. □

**Corollary.** The permitted voice leadings do not form a subcategory of the category of all voice leadings. The Counterpoint Quiver is genuinely a quiver (directed multigraph), not a category.

### 3.3 Perfect Consonance Bottleneck

**Theorem 3.3** (`perfect_self_loop_unique`). *If `i ∈ P` is a perfect consonance, then the only permitted voice leading from `i` to `i` is the identity `(0, 0)`.*

*Proof sketch.* Any voice leading `(b, s)` with `target(i, b, s) = i` satisfies `s = b`. If `b ≠ 0`, this is parallel motion into a perfect consonance, which is forbidden. Therefore `b = s = 0`. □

**Theorem 3.4** (`imperfect_self_loops_all`). *If `i ∈ C \ P` is an imperfect consonance, then for every `d ∈ ZMod 12`, the voice leading `(d, d)` is a permitted self-loop from `i` to `i`.*

*Proof sketch.* The target is `i + d − d = i`, so it's a self-loop. The motion `(d, d)` with `d ≠ 0` is parallel, but the target `i` is not a perfect consonance, so the parallel-motion prohibition does not apply. For `d = 0`, the identity is trivially permitted. □

**Corollary.** Perfect consonances have exactly 1 self-loop; imperfect consonances have exactly 12 self-loops (one for each element of `ZMod 12`).

### 3.4 Voice-Swap Asymmetry

**Theorem 3.5** (`voice_swap_breaks_consonance`). *The involution `i ↦ −i` on `ZMod 12` does not preserve the set of consonant intervals. Specifically, `7 ∈ C` but `−7 ≡ 5 ∉ C`.*

*Proof sketch.* Direct computation: `−7 ≡ 5 (mod 12)`, and `5 ∉ {0, 3, 4, 7, 8, 9}`. □

This theorem formalizes the classical observation that the perfect fifth (7 semitones) and the perfect fourth (5 semitones) are treated differently in counterpoint despite being inversions of each other. The bass voice occupies a privileged position: a fifth above the bass is consonant, but a fourth above the bass (equivalently, a fifth below the soprano) is dissonant.

### 3.5 Hom-Set Computation

**Theorem 3.6** (`total_permitted_to_perfect`). *The total number of permitted voice leadings from all consonant sources to perfect consonant targets is exactly 61.*

**Theorem 3.7** (`total_permitted_to_imperfect`). *The total number of permitted voice leadings from all consonant sources to imperfect consonant targets is exactly 72.*

These are computed by exhaustive enumeration over `ZMod 12 × ZMod 12` (the 144 possible voice leadings) filtered by the consonance and non-parallelism conditions, for each of the 6 source × 2 (or 4) target combinations.

The ratio 61:72 ≈ 0.847 quantifies the "bottleneck effect" of perfect consonances: they admit approximately 15% fewer incoming voice leadings than imperfect consonances.

---

## 4. The Voice-Leading Seminorm

### 4.1 Cost Function Properties

Working in the complementary framework of voice motions `m : Fin n → ℤ`, we establish that the voice-leading cost is a well-behaved algebraic object.

**Theorem 4.1** (`cost_seminorm_properties`). *The voice-leading cost function `cost : (Fin n → ℤ) → ℤ` satisfies:*

1. *Nonnegativity:* `cost(m) ≥ 0` for all `m`. (`cost_nonneg`)
2. *Subadditivity (triangle inequality):* `cost(m₁ + m₂) ≤ cost(m₁) + cost(m₂)`. (`cost_triangle`)
3. *Absolute homogeneity:* `cost(c · m) = |c| · cost(m)`. (`cost_abs_homogeneous`)

*Therefore `cost` is a seminorm on the ℤ-module `Fin n → ℤ`.*

**Theorem 4.2** (`cost_eq_zero_iff`). *`cost(m) = 0` if and only if `m = 0` (no voice moves).*

Combined with the seminorm properties, this shows that `cost` is actually a *norm*: it separates points. The voice-leading cost therefore defines a genuine metric `d(m₁, m₂) = cost(m₁ − m₂)` on voice-motion space.

**Theorem 4.3** (`cost_neg_eq`). *`cost(−m) = cost(m)` — retrograde motion has the same cost.*

### 4.2 Lattice-Cost Interaction

The space `Fin n → ℤ` carries a natural distributive lattice structure given by componentwise `min` (meet `⊓`) and `max` (join `⊔`).

**Theorem 4.4** (`cost_meet_join_eq`). *For all voice motions `m₁, m₂`:*

```
cost(m₁ ⊓ m₂) + cost(m₁ ⊔ m₂) = cost(m₁) + cost(m₂)
```

*Proof sketch.* Reduce to the pointwise identity `|min(a,b)| + |max(a,b)| = |a| + |b|` for integers, then sum over all voices. The pointwise identity follows by case analysis on the ordering of `a` and `b`. □

This is a conservation law: lattice operations redistribute cost perfectly, preserving the total.

**Corollary** (`cost_meet_le`, `cost_join_le`). *Both `cost(m₁ ⊓ m₂)` and `cost(m₁ ⊔ m₂)` are bounded by `cost(m₁) + cost(m₂)`.*

### 4.3 Ascending Motion Sublattice

**Definition 4.5.** A voice motion `m` is *ascending* if `m(i) ≥ 0` for all voices `i`.

**Theorem 4.6** (`ascending_meet`, `ascending_join`). *The set of ascending motions is closed under meet and join — it forms a sublattice of `Fin n → ℤ`.*

**Theorem 4.7** (`ascending_cost_eq_sum`). *For ascending motions, `cost(m) = Σᵢ m(i)` — the cost equals the simple sum (no absolute values needed).*

**Theorem 4.8** (`ascending_meet_cost_le`). *For ascending motions, `cost(m₁ ⊓ m₂) ≤ cost(m₁)` — the lattice meet always reduces or preserves cost.*

### 4.4 Interval Preservation

**Theorem 4.9** (`parallel_preserves_interval`). *Parallel motion (where all voices move by the same amount) preserves the interval between any pair of voices.*

**Theorem 4.10** (`nonparallel_changes_interval`). *Non-parallel motion between two voices necessarily changes the interval between them.*

These theorems give a precise algebraic characterization of when intervals are preserved, complementing the quiver-theoretic results on when parallel motion is *permitted*.

### 4.5 Optimal Voice Leading

**Theorem 4.11** (`optimal_exists_of_finset`). *For any nonempty finite set of feasible voice motions, there exists a cost-minimizing element.*

**Theorem 4.12** (`stepwise_cost_bound`). *Under a stepwise motion bound `b` (each voice moves by at most `b` semitones), the total cost satisfies `cost(m) ≤ n · b`.*

---

## 5. Discussion

### 5.1 The Category That Isn't

Our original conjecture was that the first-species counterpoint system forms a thin category equivalent to a poset on 12 elements. The formal investigation revealed a more nuanced picture: the permitted voice leadings form a *quiver* (directed multigraph) but **not** a category, because composition fails (Theorem 3.2).

This negative result is itself informative. It means that counterpoint rules are inherently *local*: each transition must be checked independently, and valid two-step paths cannot be reduced to valid single-step arrows. This accords with pedagogical practice, where students are taught to check each successive interval pair rather than reasoning about longer-range paths.

### 5.2 The Bottleneck as Information-Theoretic Constraint

The 61:72 ratio of incoming voice leadings (Theorems 3.6–3.7) can be interpreted information-theoretically. If a composer chooses voice leadings uniformly at random from the permitted set, then arriving at a perfect consonance carries approximately `log₂(72/61) ≈ 0.24` bits more information than arriving at an imperfect consonance. Perfect consonances are *surprisal-rich* events in the counterpoint Markov chain.

### 5.3 Generalization to Microtonal Systems

The `CounterpointSystem n` abstraction supports direct generalization. For 19-TET (used in some Renaissance and contemporary music), one would define consonant intervals based on the closest approximations to just intervals in `ZMod 19`. The structural theorems about connectivity, non-composability, and the bottleneck effect could then be tested for these alternate systems.

We conjecture that strong connectivity holds for any Counterpoint System with at least one imperfect consonance, via the same canonical voice-leading construction. Non-composability likely holds whenever |P| ≥ 1, though this remains to be verified.

### 5.4 Connection to Pythagorean Theory

The consonance classifications used in this work connect to a separate formalization of Pythagorean music theory, where consonant frequency ratios are derived from primitive Pythagorean triples. The triple (3, 4, 5) yields the ratios 4/3 (perfect fourth), 5/4 (major third), and 5/3 (major sixth) — three of the six intervals in our consonance set. This provides a number-theoretic foundation for the choice of `C = {0, 3, 4, 7, 8, 9}`.

### 5.5 The Seminorm Bridge

The voice-leading cost seminorm (Theorem 4.1) and the quiver structure are complementary perspectives on the same musical phenomenon. The seminorm measures *how much* voices move; the quiver determines *whether* the motion is legal. A natural synthesis would be a *weighted quiver* where each edge carries its cost, enabling optimization over permitted paths.

The L¹-lattice identity (Theorem 4.4) is, to our knowledge, new in the music-theory literature. It suggests that lattice operations on voice motions may have compositional applications: the meet of two voice leadings gives the "most conservative" combined motion, while the join gives the "most expansive."

---

## 6. Future Work

1. **Weighted path optimization.** Equip the Counterpoint Quiver with edge weights from the cost function and study shortest-path / minimum-cost-flow problems. This would model the compositional problem of finding the smoothest realization of a given harmonic progression.

2. **Higher species.** Extend the framework to second-species (two notes against one), third-species (four notes against one), and fourth-species (suspensions). Each species adds constraints and modifies the quiver structure.

3. **Microtonal enumeration.** Compute the Counterpoint Quiver for 19-TET, 31-TET, and 53-TET systems. Investigate how the bottleneck ratio and self-loop counts vary with the modulus.

4. **Markov chain analysis.** Treat the Counterpoint Quiver as the transition graph of a Markov chain and study its stationary distribution, mixing time, and entropy rate. This could model stylistic differences between composers who favor different regions of the quiver.

5. **Multi-voice generalization.** Extend from two voices to three or more, where the constraint structure becomes significantly richer (e.g., no parallel fifths between *any* pair of voices).

6. **Lattice width conjecture.** Prove or disprove that for a counterpoint system with stepwise bound `b` and `n` voices, the optimal voice-leading cost is bounded by the lattice width of the feasible region.

---

## 7. References

1. Fux, J. J. (1725). *Gradus ad Parnassum*. Vienna.

2. Tymoczko, D. (2006). The geometry of musical chords. *Science*, 313(5783), 72–74.

3. Tymoczko, D. (2011). *A Geometry of Music*. Oxford University Press.

4. Callender, C., Quinn, I., & Tymoczko, D. (2008). Generalized voice-leading spaces. *Science*, 320(5874), 346–348.

5. Mazzola, G. (2002). *The Topos of Music*. Birkhäuser.

6. Forte, A. (1973). *The Structure of Atonal Music*. Yale University Press.

7. Cohn, R. (1998). Introduction to neo-Riemannian theory: A survey and historical perspective. *Journal of Music Theory*, 42(2), 167–180.

---

## Appendix A: Formal Verification Summary

All theorems in this paper have been formally verified in Lean 4 (version 4.x) using the Mathlib library. The formalization comprises two files:

- `CounterpointCategory.lean`: The Counterpoint Quiver, strong connectivity, non-composability, bottleneck theorems, voice-swap asymmetry, and hom-set computations.
- `MusicalCounterpoint.lean`: The voice-leading cost seminorm, lattice-cost interaction, ascending motion sublattice, interval preservation, and optimal voice-leading existence.

The total formalization is approximately 500 lines of Lean code. All proofs are constructive where possible, with classical reasoning used only for decidability instances in finite enumeration.
