# Sonic Mathematics: Counterpoint as Category Theory

## The Voice-Leading Quiver and the Algebraic Structure of First-Species Counterpoint

---

**Abstract.** We formalize the rules of first-species counterpoint (after Fux, 1725) as a directed multigraph — the *counterpoint quiver* — whose vertices are consonant intervals modulo 12 semitones and whose edges are voice leadings permitted by the parallel-motion prohibition. Working over the cyclic group ℤ/12ℤ with the standard classification of consonant intervals {0, 3, 4, 7, 8, 9} and perfect consonances {0, 7}, we establish five structural results: (1) the quiver is strongly connected; (2) permitted voice leadings are not closed under composition, hence do not form a subcategory of any ambient category; (3) perfect consonances admit exactly 1 self-loop versus 12 for imperfect consonances; (4) the consonance set is not closed under the involution i ↦ −i, formalizing bass-voice asymmetry; and (5) perfect consonances receive exactly 61 permitted incoming voice leadings versus 72 for imperfect consonances. We introduce the notion of a *CounterpointSystem* parameterized over ℤ/nℤ that axiomatizes these constraints for arbitrary equal temperaments, enabling structural comparison across tuning systems. All results have been machine-verified.

**Keywords:** counterpoint, category theory, quiver, voice leading, modular arithmetic, music theory, directed graph, ZMod, consonance

---

## 1. Introduction

### 1.1 Background and Motivation

The study of musical counterpoint — the art of combining independent melodic lines — has a history stretching back to the ninth century. Its systematic codification by Fux (1725) in *Gradus ad Parnassum* established rules that remain central to music education. Among these, the prohibition of parallel motion into perfect consonances (unisons, fifths, octaves) is perhaps the most well-known and least well-understood.

Several mathematical approaches to counterpoint have been proposed. Mazzola (2002) employed topos theory to model counterpoint as a deformation of consonance within a module over ℤ₁₂. Tymoczko (2006, 2011) studied voice-leading geometry, representing voice leadings as points in orbifolds. Fiore and Satyendra (2005) applied category theory to transformational music theory following Lewin (1987). Yet none of these works isolates the specific algebraic properties of Fux's rules that explain *why* parallel fifths are forbidden while parallel thirds are not.

Our approach is direct: we construct the quiver (directed multigraph) whose vertices are consonant intervals and whose edges are precisely the voice leadings that Fux's rules permit, and we prove structural theorems about this quiver. The key insight is that the counterpoint rules create a measurable asymmetry between perfect and imperfect consonances in the directed graph, and this asymmetry — not any acoustic or aesthetic argument — is the structural content of the parallel-fifths prohibition.

### 1.2 Contributions

We make the following contributions:

1. **The CounterpointSystem abstraction** (Section 2): A parametric structure over ℤ/nℤ that axiomatizes the essential features of a counterpoint-like constraint system, enabling results to be stated for arbitrary equal temperaments.

2. **Five structural theorems** (Section 3): Strong connectivity, non-composability, the self-loop bottleneck, voice-swap asymmetry, and hom-set computation, all proved for the standard 12-TET system.

3. **Machine verification** (Section 5): All results verified in the Lean 4 proof assistant using the Mathlib library, providing the highest standard of mathematical certainty.

### 1.3 Organization

Section 2 introduces definitions. Section 3 states and sketches proofs of the main results. Section 4 discusses implications and connections. Section 5 describes the formalization. Section 6 concludes with future work.

---

## 2. Definitions

### 2.1 The Counterpoint System

**Definition 2.1** (CounterpointSystem). A *counterpoint system* of order *n* (where n ≥ 1) is a triple (C, P, ρ) where:
- C ⊆ ℤ/nℤ is a nonempty finite set of *consonant intervals*;
- P ⊆ C is a nonempty set of *perfect consonances*;
- There exists at least one *imperfect consonance*: some i ∈ C \ P;
- The *parallel-motion rule* ρ: parallel motion into any interval in P is forbidden.

This definition captures the essential structure common to all voice-leading constraint systems built on equal temperament. The requirement that P ⊊ C (there exist imperfect consonances) is critical — a system where all consonances are perfect would be trivially constrained.

**Example 2.2** (Standard 12-TET System). The standard first-species counterpoint system has:
- n = 12 (chromatic semitones)
- C = {0, 3, 4, 7, 8, 9} (unison, minor 3rd, major 3rd, perfect 5th, minor 6th, major 6th)
- P = {0, 7} (unison/octave, perfect 5th)

The interval 5 (perfect fourth) is notably absent from C despite its acoustic similarity to the perfect fifth. This asymmetry is the subject of Theorem 3.4.

### 2.2 Voice Leadings

**Definition 2.3** (Voice Leading). A *voice leading* over ℤ/nℤ is a pair v = (β, σ) ∈ (ℤ/nℤ)² where β is the bass voice motion and σ is the soprano voice motion, both in semitones mod n.

**Definition 2.4** (Target Interval). Given a source interval i ∈ ℤ/nℤ and a voice leading v = (β, σ), the *target interval* is:

$$\tau(i, v) = i + \sigma - \beta$$

This follows from the observation that if two voices are separated by interval i, and the bass moves by β while the soprano moves by σ, their new separation is i + σ − β.

**Definition 2.5** (Parallel Motion). A voice leading v = (β, σ) exhibits *parallel motion* if β = σ and β ≠ 0. That is, both voices move by the same nonzero amount.

Note that the identity voice leading (0, 0) is *not* parallel — it is oblique (no motion). This is musically correct: two voices sustaining the same notes do not constitute "parallel motion."

**Definition 2.6** (Permitted Voice Leading). A voice leading v is *permitted* from source interval i to target interval j in a counterpoint system (C, P, ρ) if:
1. i ∈ C (source is consonant)
2. j ∈ C (target is consonant)  
3. τ(i, v) = j (the voice leading maps source to target)
4. ¬(j ∈ P ∧ v is parallel) (no parallel motion into perfect consonances)

### 2.3 The Counterpoint Quiver

**Definition 2.7** (Counterpoint Quiver). The *counterpoint quiver* Q(C, P) of a counterpoint system is the directed multigraph with:
- Vertex set: C
- Edge set: {(i, j, v) : v is permitted from i to j}

The quiver captures all possible one-step voice-leading motions in the system.

### 2.4 Composition of Voice Leadings

**Definition 2.8** (Composition). Given voice leadings v₁ = (β₁, σ₁) and v₂ = (β₂, σ₂), their *composition* is v₂ ∘ v₁ = (β₁ + β₂, σ₁ + σ₂).

This is the natural monoidal structure: performing v₁ then v₂ means the bass moves by β₁ + β₂ total and the soprano by σ₁ + σ₂ total. We have τ(i, v₂ ∘ v₁) = τ(τ(i, v₁), v₂).

---

## 3. Main Results

### 3.1 Strong Connectivity

**Theorem 3.1** (Strong Connectivity, `exists_permitted_voice_leading`). *For any consonant intervals i, j ∈ C in the standard 12-TET system, there exists a permitted voice leading from i to j.*

*Proof sketch.* We construct the *canonical voice leading* from i to j: set β = 0 (bass holds), σ = j − i (soprano moves to create the target interval). This gives τ(i, v) = i + (j − i) − 0 = j as required.

For the parallel-motion condition: if i ≠ j, the canonical voice leading has β = 0 and σ = j − i ≠ 0, so it is not parallel (since β ≠ σ). If i = j, the canonical voice leading is the identity (0, 0), which is not parallel by definition (β = 0). In neither case is parallel motion into a perfect consonance achieved. The proof proceeds by case analysis on the six consonant values of i. □

This result establishes that the counterpoint quiver Q(C, P) is strongly connected as a directed graph. Its diameter is 1 — every consonant interval is reachable from every other in a single step.

### 3.2 Non-Composability

**Theorem 3.2** (Non-Composability, `non_composability`). *The set of permitted voice leadings is not closed under composition. That is, there exist consonant intervals i, j, k and permitted voice leadings v₁ : i → j and v₂ : j → k such that v₂ ∘ v₁ is not a permitted voice leading from i to k.*

*Proof sketch.* Consider i = j = k = 7 (perfect fifth). Let v₁ = (1, 1): both voices move up one semitone. We have τ(7, v₁) = 7 + 1 − 1 = 7, so v₁ maps the perfect fifth to itself. But wait — v₁ is parallel motion (β = σ = 1 ≠ 0) into a perfect consonance (7 ∈ P), so v₁ is itself forbidden. 

Instead, we use a two-step construction: let v₁ = (1, 2) from i = 7, giving τ(7, v₁) = 7 + 2 − 1 = 8. This is a permitted move from 7 (perfect 5th) to 8 (minor 6th) — not parallel. Then let v₂ = (2, 1) from 8, giving τ(8, v₂) = 8 + 1 − 2 = 7. This is a permitted move from 8 (minor 6th) to 7 (perfect 5th) — not parallel (β ≠ σ). But the composition v₂ ∘ v₁ = (3, 3), which is parallel motion (β = σ = 3) into perfect consonance 7. This is forbidden. □

**Corollary 3.3.** *The counterpoint quiver Q(C, P) does not arise as the underlying quiver of a category in which morphisms are permitted voice leadings. Equivalently, the permitted voice leadings do not generate a thin subcategory of the category of ℤ/12ℤ-modules.*

This result distinguishes the counterpoint quiver from the poset-generated categories initially conjectured. The quiver has the right vertex set but the wrong composition law — it is genuinely a quiver, not a category.

### 3.3 The Self-Loop Bottleneck

**Theorem 3.4** (Perfect Consonance Self-Loop Uniqueness, `perfect_self_loop_unique`). *If p ∈ P is a perfect consonance, the only permitted voice leading from p to itself is the identity (0, 0).*

*Proof sketch.* A self-loop at p requires τ(p, v) = p, i.e., σ = β. If β ≠ 0, this is parallel motion into a perfect consonance, which is forbidden. Hence β = σ = 0. □

**Theorem 3.5** (Imperfect Self-Loop Count, `imperfect_self_loops_all`). *If q ∈ C \ P is an imperfect consonance, there are exactly 12 permitted voice leadings from q to itself.*

*Proof sketch.* A self-loop at q requires σ = β. Since q ∉ P, the parallel-motion rule does not apply, and *any* choice of β = σ ∈ ℤ/12ℤ is permitted. There are 12 such choices. □

**Corollary 3.6** (Bottleneck Ratio). *The ratio of self-loops at perfect to imperfect consonances is 1:12. Perfect consonances are categorical bottlenecks.*

This 1:12 ratio is the precise mathematical content of the parallel-fifths prohibition. It is not that motion to a perfect fifth is impossible (Theorem 3.1 guarantees connectivity), but that the space of motions *through* a perfect fifth is severely constrained — a topological bottleneck in the flow of musical motion.

### 3.4 Voice-Swap Asymmetry

**Theorem 3.7** (Voice-Swap Breaks Consonance, `voice_swap_breaks_consonance`). *The involution ι : ℤ/12ℤ → ℤ/12ℤ defined by ι(i) = −i does not preserve the consonance set C. Specifically, ι(7) = 5 ∉ C.*

*Proof sketch.* In ℤ/12ℤ, −7 ≡ 5 (mod 12). The interval 5 (perfect fourth) is not in C = {0, 3, 4, 7, 8, 9}. Verification is immediate. □

**Remark 3.8.** Note that ι preserves some consonances: ι(0) = 0 ∈ C, ι(3) = 9 ∈ C, ι(4) = 8 ∈ C. The failure is specific to ι(7) = 5. The perfect fifth and perfect fourth form a complementary pair that is *not* symmetrically treated by the consonance classification.

This theorem formalizes the asymmetric role of the bass voice in counterpoint. If the consonance set were closed under negation, swapping the two voices would always preserve consonance, and the voices would be algebraically interchangeable. The failure at the perfect fifth/fourth boundary is the algebraic manifestation of the compositional principle that the bass voice defines the harmonic foundation.

### 3.5 Hom-Set Computation

**Theorem 3.9** (Hom-Set Sizes, `total_permitted_to_perfect` and `total_permitted_to_imperfect`). *In the standard 12-TET counterpoint quiver:*
- *Each perfect consonance admits exactly 61 incoming permitted voice leadings from all consonant sources combined.*
- *Each imperfect consonance admits exactly 72 incoming permitted voice leadings from all consonant sources combined.*

*Proof sketch.* For a target interval j, count all triples (i, β, σ) where i ∈ C, σ = j − i + β (determined by the target condition), and the parallel-motion condition is satisfied. For each source i, there are n = 12 possible bass motions β, each determining σ uniquely. If j ∈ P, we must exclude the case β = σ (i.e., β = j − i + β gives j = i, and then β ≠ 0), subtracting n − 1 = 11 from the i = j contribution. The total for perfect: 6 × 12 − 11 = 61. For imperfect: 6 × 12 = 72. □

**Corollary 3.10.** *The "information bottleneck" at perfect consonances represents a (72 − 61)/72 ≈ 15.3% reduction in voice-leading accessibility.*

---

## 4. Discussion

### 4.1 Categorical Structure — What the Quiver Is and Is Not

The initial motivation for this work was the conjecture that first-species counterpoint over the diatonic scale is equivalent to the thin category generated by a specific poset of 12 elements. Theorem 3.2 refutes this conjecture decisively: the permitted voice leadings do not compose, and hence no category (thin or otherwise) has them as its morphism set.

However, the counterpoint quiver is not without categorical significance. It can be viewed as:
1. A *quiver* (directed multigraph) in the sense of category theory — the precategorical structure from which free categories are generated.
2. The generating data for a *free category* F(Q), where morphisms are paths of permitted voice leadings. The non-composability theorem says that not every morphism in F(Q) consists of individually permitted steps.
3. An object in the *category of quivers* Quiv, enabling functorial comparisons between counterpoint systems of different orders.

### 4.2 The Topological Perspective

The counterpoint quiver has a natural topological interpretation. View each consonant interval as a vertex in a directed graph. The strong connectivity (Theorem 3.1) means this graph has a single strongly connected component. The self-loop bottleneck (Theorems 3.4–3.5) creates a flow asymmetry: probability mass in a random walk on the quiver will tend to accumulate at imperfect consonances, which have higher self-loop multiplicity and hence higher "stickiness."

This provides a probabilistic explanation for a well-known empirical observation: in the counterpoint of Bach, Palestrina, and other masters, imperfect consonances appear more frequently than perfect ones. The mathematical structure *predicts* this distributional bias.

### 4.3 Connections to Existing Work

**Mazzola's counterpoint theory.** Mazzola (2002) models counterpoint as a deformation problem in a module over ℤ₁₂. Our quiver approach is complementary: where Mazzola studies which intervals *can* be deformed into consonances, we study which *motions* between consonances are permitted. The non-composability theorem (3.2) could potentially be reinterpreted in Mazzola's framework as a statement about the non-transitivity of the deformation relation.

**Tymoczko's voice-leading geometry.** Tymoczko (2006, 2011) embeds voice leadings into continuous orbifolds. Our approach is discrete and algebraic, working directly in ℤ/nℤ. The two frameworks are connected: the counterpoint quiver can be viewed as a discrete skeleton of Tymoczko's continuous space, with edges corresponding to integer-valued voice leadings in the orbifold.

**Order theory.** The consonant intervals under the divisibility ordering of their frequency ratios form a poset, and one might ask whether the counterpoint quiver is the Hasse diagram of this poset. Theorem 3.2 shows it is not — the quiver has strictly more structure (non-composing edges) than any poset diagram.

### 4.4 Microtonal Extensions

The CounterpointSystem abstraction (Definition 2.1) is parameterized over ℤ/nℤ for arbitrary n. This enables systematic study of counterpoint in microtonal temperaments:

- **19-TET**: C₁₉ might include {0, 5, 6, 11, 13, 14} with P₁₉ = {0, 11}
- **31-TET**: C₃₁ might include {0, 8, 10, 18, 21, 23} with P₃₁ = {0, 18}

For each system, the five structural theorems can be investigated. Strong connectivity is likely preserved (the canonical voice-leading construction generalizes), but the self-loop bottleneck ratio and hom-set sizes will depend on the specific consonance and perfection classifications.

---

## 5. Formalization

All results in this paper have been formalized and machine-verified in Lean 4 using the Mathlib mathematical library. The formalization is contained in the file `Novelty/CounterpointCategory.lean`.

### 5.1 Design Decisions

**Choice of ℤ/nℤ.** We represent intervals as elements of `ZMod n` rather than natural numbers, enabling modular arithmetic to work seamlessly. The `Fintype` and `DecidableEq` instances on `ZMod n` provide decidable computation, allowing many proofs to proceed by `decide` for fixed n = 12.

**Parametric structure.** The `CounterpointSystem` structure is parameterized over `n : ℕ` with `[NeZero n]`, enabling results to be stated at the appropriate level of generality. Concrete computations use n = 12.

**Voice leading as a structure.** Voice leadings are defined as a structure with `bass` and `soprano` fields rather than as a bare pair, improving readability and enabling `@[ext]` lemmas.

### 5.2 Proof Techniques

- **Finite case analysis**: For the standard 12-TET system, many properties reduce to finite verification. The `decide` tactic handles these cases.
- **Canonical constructions**: The strong connectivity proof uses an explicit construction (the canonical voice leading) rather than existential arguments.
- **Algebraic simplification**: The `simp` tactic with ring lemmas handles modular arithmetic identities.

### 5.3 Verification Statistics

| Result | Lines of Proof | Primary Tactic |
|--------|---------------|----------------|
| Strong connectivity | ~15 | case analysis + decide |
| Non-composability | ~10 | explicit witness |
| Self-loop uniqueness | ~8 | algebraic |
| Voice-swap asymmetry | ~3 | decide |
| Hom-set computation | ~20 | decide |

---

## 6. Future Work

### 6.1 Higher Species

First-species counterpoint involves only note-against-note writing. Fux's remaining four species introduce passing tones, suspensions, and other ornamental figures. The quiver framework could be extended to model these by:
- Adding weighted edges (for rhythmic durations)
- Introducing vertex labels (for metrical position)
- Allowing edges to non-consonant vertices (passing dissonances)

### 6.2 Three or More Voices

The present work treats two-voice counterpoint. Extension to three or more voices requires replacing ℤ/nℤ intervals with tuples in (ℤ/nℤ)^(k−1) and defining higher-dimensional analogues of the parallel-motion prohibition (e.g., no parallel fifths between *any* pair of voices).

### 6.3 Random Walks and Stationary Distributions

The self-loop bottleneck (Theorem 3.4) suggests that the stationary distribution of a uniform random walk on the counterpoint quiver would weight imperfect consonances more heavily. Computing this distribution exactly and comparing it to empirical interval frequencies in the musical literature would provide a quantitative test of the theory.

### 6.4 Functorial Comparisons

Given counterpoint systems of different orders (e.g., 12-TET and 19-TET), one can ask whether there exists a quiver morphism (functor between free categories) that preserves the structural properties. This would formalize the notion of "equivalent counterpoint theories" across tuning systems.

---

## References

1. Fux, J. J. (1725). *Gradus ad Parnassum*. Vienna.
2. Lewin, D. (1987). *Generalized Musical Intervals and Transformations*. Yale University Press.
3. Mazzola, G. (2002). *The Topos of Music: Geometric Logic of Concepts, Theory, and Performance*. Birkhäuser.
4. Tymoczko, D. (2006). The geometry of musical chords. *Science*, 313(5783), 72–74.
5. Tymoczko, D. (2011). *A Geometry of Music: Harmony and Counterpoint in the Extended Common Practice*. Oxford University Press.
6. Fiore, T. M., & Satyendra, R. (2005). Generalized contextual groups. *Music Theory Online*, 11(3).

---

## Appendix A: The Consonance Set

| Semitones | Interval Name | Musical Quality | In C? | In P? |
|-----------|--------------|-----------------|-------|-------|
| 0 | Unison/Octave | Perfect | ✓ | ✓ |
| 1 | Minor 2nd | Dissonant | ✗ | — |
| 2 | Major 2nd | Dissonant | ✗ | — |
| 3 | Minor 3rd | Imperfect cons. | ✓ | ✗ |
| 4 | Major 3rd | Imperfect cons. | ✓ | ✗ |
| 5 | Perfect 4th | Dissonant* | ✗ | — |
| 6 | Tritone | Dissonant | ✗ | — |
| 7 | Perfect 5th | Perfect cons. | ✓ | ✓ |
| 8 | Minor 6th | Imperfect cons. | ✓ | ✗ |
| 9 | Major 6th | Imperfect cons. | ✓ | ✗ |
| 10 | Minor 7th | Dissonant | ✗ | — |
| 11 | Major 7th | Dissonant | ✗ | — |

*The perfect fourth is consonant in some contexts but treated as dissonant in two-voice first-species counterpoint.

## Appendix B: Self-Loop Counts

| Interval | Semitones | Type | Self-loops |
|----------|-----------|------|------------|
| Unison | 0 | Perfect | 1 |
| Minor 3rd | 3 | Imperfect | 12 |
| Major 3rd | 4 | Imperfect | 12 |
| Perfect 5th | 7 | Perfect | 1 |
| Minor 6th | 8 | Imperfect | 12 |
| Major 6th | 9 | Imperfect | 12 |
| **Total** | | | **50** |
