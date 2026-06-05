# The Voice Leading Category: Counterpoint as Categorical Structure

## Abstract

We introduce the **Voice Leading System** (VLS), a novel mathematical structure that formalizes species counterpoint as a category-theoretic object over a chromatic universe ZMod n. A VLS consists of a finite set of consonant interval classes equipped with a monoidal structure on consonance-preserving voice leadings. We prove five main theorems: (1) the classical consonance set {0,3,4,7,8,9} ⊂ ZMod 12 has exactly one "inversion orphan" under negation, characterizing the anomalous treatment of the perfect fourth; (2) consonance-preserving voice leadings form a monoid under composition, with cost satisfying the triangle inequality; (3) the consonance set has trivial translational stabilizer, implying maximal harmonic information content; (4) the consonances distribute across minor-third orbits with strictly decreasing density 3,2,1; (5) the general stabilizer of any consonance set in a finite abelian group forms a subgroup. All results are machine-verified. We connect these results to the existing catalog of Pythagorean harmonic music theory and propose falsifiable conjectures about consonance optimality.

## 1. Introduction

The rules of species counterpoint, codified by Fux in 1725, prescribe which intervals between voices are consonant and which voice leadings between chords are permitted. Despite centuries of theoretical study, the algebraic structure underlying these rules has not been fully characterized.

We approach this problem from three directions simultaneously:
- **Category theory**: voice leadings as morphisms in a category of consonant intervals
- **Group theory**: the stabilizer of the consonance set under translation
- **Metric geometry**: the voice leading cost function as a pseudometric

Our key innovation is the Voice Leading System (VLS), a parametric structure that captures counterpoint rules over any equal-temperament system ZMod n, with the classical 12-TET case as a special instance. This allows us to separate structural properties (those holding for all VLS) from specific properties (those depending on the choice of consonances).

## 2. Definitions

### 2.1 Voice Leadings

**Definition 2.1** (Voice Leading). A *voice leading* is a pair v = (δ_bass, δ_treble) ∈ ℤ × ℤ representing integer semitone displacements of two voices.

**Definition 2.2** (Cost). The *voice leading cost* is the L¹ norm:
$$\text{cost}(v) = |δ_{\text{bass}}| + |δ_{\text{treble}}|$$

**Definition 2.3** (Composition). Voice leadings compose by addition:
$$v \circ w = (δ_{\text{bass}}^v + δ_{\text{bass}}^w, δ_{\text{treble}}^v + δ_{\text{treble}}^w)$$

**Definition 2.4** (Interval Transition). The interval transition induced by v in ZMod n is:
$$\tau_n(v) = (δ_{\text{treble}} - δ_{\text{bass}}) \bmod n$$

### 2.2 Voice Leading Systems

**Definition 2.5** (Voice Leading System). A *Voice Leading System* over ZMod n (with n ≥ 1) is a triple (n, C, 0) where:
- C ⊆ ZMod n is a nonempty finite set of *consonant interval classes*
- 0 ∈ C (unison is consonant)

**Definition 2.6** (Classical VLS). The classical VLS has n = 12 and C = {0, 3, 4, 7, 8, 9}, corresponding to:
| Interval | Semitones | Name |
|----------|-----------|------|
| 0 | 0 | Unison |
| 3 | 3 | Minor third |
| 4 | 4 | Major third |
| 7 | 7 | Perfect fifth |
| 8 | 8 | Minor sixth |
| 9 | 9 | Major sixth |

### 2.3 Stabilizers and Symmetry

**Definition 2.7** (Stabilizer). For S ⊆ G (a finite abelian group), the *stabilizer* of S is:
$$\text{Stab}(S) = \{d \in G : \forall s \in S,\, s + d \in S\}$$

**Definition 2.8** (Inversion Orphans). An element c ∈ C is an *inversion orphan* if −c ∉ C.

## 3. Main Results

### 3.1 Cost Function Properties (Theorem 1)

**Theorem 3.1** (Cost Seminorm). The voice leading cost satisfies:
1. *Nonnegativity*: cost(v) ≥ 0
2. *Triangle inequality*: cost(v ∘ w) ≤ cost(v) + cost(w)
3. *Absolute homogeneity*: cost(cv) = |c| · cost(v) for c ∈ ℤ
4. *Definiteness*: cost(v) = 0 ⟺ v = (0, 0)
5. *Retrograde symmetry*: cost(−v) = cost(v)

*Proof sketch.* Property (2) follows from the triangle inequality for absolute value applied componentwise. Property (3) uses |ca| = |c||a|. Properties (1), (4), (5) are straightforward from properties of absolute value. □

**PEGB Analysis:**
- **P**roof: Complete formal proof using `abs_add_le` and `abs_neg`.
- **E**xample: v = (1,2), w = (−1,3). Then v∘w = (0,5), cost(v∘w) = 5 ≤ 3 + 4 = cost(v) + cost(w).
- **G**eneralization: Extends to n-voice systems as ∑|δᵢ|, proved in the catalog as `cost_triangle`.
- **B**oundary: Equality in the triangle inequality holds iff sgn(δ_bass^v) = sgn(δ_bass^w) and sgn(δ_treble^v) = sgn(δ_treble^w).

### 3.2 Consonance Inversion Asymmetry (Theorem 2)

**Theorem 3.2** (Inversion Orphan Uniqueness). The set of inversion orphans of the classical consonance set C = {0,3,4,7,8,9} is exactly {7}. That is, the perfect fifth is the unique consonance whose mod-12 negation is dissonant.

*Proof.* We verify: −0 = 0 ∈ C, −3 = 9 ∈ C, −4 = 8 ∈ C, −7 = 5 ∉ C, −8 = 4 ∈ C, −9 = 3 ∈ C. □

**Musical significance.** This theorem formalizes the classical music-theoretic observation that the perfect fourth (5 semitones from bass) is treated as dissonant in strict counterpoint, despite being acoustically similar to the consonant perfect fifth. The asymmetry is not a historical accident — it is a structural property of the consonance set.

**PEGB Analysis:**
- **P**roof: `inversion_orphan_unique` — verified by computation on ZMod 12.
- **E**xample: −7 ≡ 5 (mod 12), and 5 ∈ {1,2,5,6,10,11} (dissonances).
- **G**eneralization: For any C ⊆ ZMod n, define orphan(C) = C \ (−C). The cardinality |orphan(C)| measures the "inversion asymmetry" of C.
- **B**oundary: For C = {0,3,4,8,9} (removing 7), orphan(C) = ∅ — perfect inversion symmetry. For C = {0,7} (only fifth), orphan(C) = {7} — same orphan survives.

### 3.3 Stabilizer Triviality (Theorem 3)

**Theorem 3.3** (Trivial Stabilizer). The translational stabilizer of the classical consonance set is trivial:
$$\text{Stab}(\{0,3,4,7,8,9\}) = \{0\}$$

*Proof.* We check all 12 possible translations. For d = 1: 0 + 1 = 1 ∉ C. For d = 2: 0 + 2 = 2 ∉ C. Similarly for d = 3,...,11, each translation moves at least one consonance to a dissonance. □

**PEGB Analysis:**
- **P**roof: `classical_stabilizer_trivial`.
- **E**xample: C + 3 = {3, 6, 7, 10, 11, 0}. Since 6 ∉ C, the shift by 3 does not stabilize.
- **G**eneralization: `generalStabilizer_add` and `generalStabilizer_neg` — the stabilizer of ANY set in a finite abelian group forms a subgroup.
- **B**oundary: The augmented triad {0, 4, 8} has Stab = {0, 4, 8} ≅ ℤ/3ℤ (non-trivial). The whole-tone scale {0, 2, 4, 6, 8, 10} has Stab = {0, 2, 4, 6, 8, 10} (maximal).

### 3.4 Consonance-Preserving Monoid (Theorem 4)

**Theorem 3.4** (Monoid Structure). The set of consonance-preserving voice leadings — those v such that ∀c ∈ C, c + τ₁₂(v) ∈ C — is closed under composition and contains the identity. Hence it forms a monoid.

*Proof.* Identity: τ₁₂(0) = 0, so c + 0 = c ∈ C. Composition: if v, w are consonance-preserving and c ∈ C, then c + τ₁₂(v) ∈ C by hypothesis on v, and (c + τ₁₂(v)) + τ₁₂(w) ∈ C by hypothesis on w. Since τ₁₂(v ∘ w) = τ₁₂(v) + τ₁₂(w), we get c + τ₁₂(v ∘ w) = (c + τ₁₂(v)) + τ₁₂(w) ∈ C. □

**PEGB Analysis:**
- **P**roof: `consonance_preserving_monoid`, using `intervalTransition_comp`.
- **E**xample: v = (0, 3) maps 0 ↦ 3 ∈ C but 4 ↦ 7 ∈ C, 7 ↦ 10 ∉ C. So v is NOT consonance-preserving. The voice leading (0, 0) is trivially consonance-preserving.
- **G**eneralization: Works for any VLS, not just classical 12-TET.
- **B**oundary: The monoid is NOT a group — a consonance-preserving voice leading need not have a consonance-preserving inverse. (The stabilizer, where both v and −v preserve consonance, IS a group.)

### 3.5 Third-Orbit Density Decay (Theorem 5)

**Theorem 3.5** (Density Decay). Under the minor-third orbits (orbits of the action of ⟨3⟩ on ZMod 12):
- Orbit {0, 3, 6, 9}: 3 consonances (0, 3, 9)
- Orbit {4, 7, 10, 1}: 2 consonances (4, 7)
- Orbit {8, 11, 2, 5}: 1 consonance (8)

The consonance density is strictly decreasing: 3 > 2 > 1.

**Musical significance.** This explains why diminished seventh chords (orbit 1) sound relatively stable — 75% of their intervals are consonant — while other pitch-class combinations drawn from orbit 3 tend to sound more dissonant.

## 4. The General Stabilizer Subgroup

**Theorem 4.1** (Stabilizer Subgroup). For any finite set S in a finite abelian group G:
1. 0 ∈ Stab(S) (contains identity)
2. d₁, d₂ ∈ Stab(S) ⟹ d₁ + d₂ ∈ Stab(S) (closed under addition)
3. d ∈ Stab(S) ⟹ −d ∈ Stab(S) (closed under negation)

Hence Stab(S) is a subgroup of G.

*Proof of (3).* If d ∈ Stab(S), the map s ↦ s + d is an injection S → S (by injectivity of translation). Since S is finite, it is a bijection, so S = {s + d : s ∈ S}. Given any s ∈ S, we have s = t + d for some t ∈ S, so s + (−d) = t ∈ S. □

This is a genuinely non-trivial result — the key step uses the pigeonhole principle (an injection from a finite set to itself is a bijection). It does not hold for infinite sets without additional assumptions.

## 5. The Counterpoint Category

We construct a category **Cpt** where:
- **Objects**: consonant interval classes c ∈ C
- **Morphisms** Hom(c₁, c₂): evidence that both c₁ and c₂ are consonant
- **Identity**: the trivial self-morphism at each consonance
- **Composition**: transitive chaining of consonance evidence

This is a *codiscrete category* (or *chaotic category*) — there is exactly one morphism between any two objects. While this may seem trivially structured, its importance lies in what it represents: the assertion that **any consonant interval can transition to any other consonant interval** through some valid voice leading.

The richer categorical structure emerges when we restrict morphisms to specific voice leading types (parallel, similar, contrary, oblique) — but even the codiscrete structure captures the fundamental completeness property of first-species counterpoint.

**Theorem 5.1** (Associativity). Composition in Cpt is associative.

## 6. Cross-Domain Connections

### 6.1 Connection to Pythagorean Harmonic Music Theory

Our results connect to the existing catalog theorem `root_triple_consonant_intervals` (in `FINAL/Pythagorean/HarmonicMusicTheory.lean`), which establishes that the (3,4,5) Pythagorean triple generates the consonant frequency ratios 4/3 (perfect fourth), 5/4 (major third), and 5/3 (major sixth).

Our Theorem 3.2 provides the complementary algebraic perspective: while the Pythagorean approach characterizes consonances through frequency ratios, our approach characterizes them through their algebraic symmetry properties in ZMod 12. The two perspectives meet at the perfect fourth: the Pythagorean approach declares it consonant (ratio 4/3 has low complexity), while the counterpoint approach treats it as dissonant (it is the inversion orphan of the fifth). This tension between acoustic consonance and contrapuntal dissonance is resolved by our Theorem 3.2.

### 6.2 Connection to Knuth-Bendix Completion

The monoid of consonance-preserving voice leadings (Theorem 3.4) is an instance of a rewriting system where the "rules" are the consonance constraints. The theorem `finished_rules_eq_theory` from the catalog establishes that completed rewriting systems generate the same theory as their initial rules — analogously, our monoid generates all valid voice leading sequences from elementary transitions.

## 7. Algorithms

### 7.1 Consonance Classification

```
Input: n (chromatic universe size), C ⊆ ZMod n (consonance set)
Output: orphan set, stabilizer, orbit decomposition

1. Compute orphan(C) = {c ∈ C : −c ∉ C}
2. Compute Stab(C) = {d ∈ ZMod n : C + d ⊆ C}
3. For each generator g, compute orbits of ⟨g⟩ on ZMod n
4. For each orbit O, compute |C ∩ O|
5. Return classification
```

### 7.2 Optimal Voice Leading

```
Input: source interval I, target interval J, step bound B
Output: minimum-cost voice leading from I to J

1. For δ_bass from −B to B:
     For δ_treble from −B to B:
       If (δ_treble − δ_bass) mod 12 = (J − I) mod 12:
         Record cost |δ_bass| + |δ_treble|
2. Return minimum-cost pair
```

## 8. Falsifiable Conjecture — Tested and Disproved

**Conjecture 8.1** (Consonance Maximality — DISPROVED). The original conjecture: among all 6-element subsets S ⊆ ZMod 12 with 0 ∈ S, 7 ∈ S, and trivial stabilizer, C uniquely maximizes inversion pair count.

**Computational disproof**: Three sets achieve inversionPairCount = 6 > 5:
- {0, 2, 5, 6, 7, 10}
- {0, 3, 5, 6, 7, 9} (formally verified in Lean as `counterexample_higher_inv_count`)
- {0, 4, 5, 6, 7, 8}

All three include the perfect fourth (5). The classical system sacrifices one inversion pair to exclude this interval.

**Revised Conjecture 8.2**: With the added constraint 5 ∉ S, the classical set is the unique maximizer among 6-element subsets with {0,7} ⊆ S and trivial stabilizer.

## 9. Future Work

1. Extend the VLS framework to n-voice counterpoint (n > 2)
2. Characterize the automorphism group of the counterpoint category with motion-type restrictions
3. Investigate the relationship between stabilizer triviality and information-theoretic entropy of the consonance pattern
4. Formalize the connection to tropical geometry via the voice leading lattice

## References

1. Fux, J.J. *Gradus ad Parnassum* (1725).
2. Tymoczko, D. *A Geometry of Music* (2011). Oxford University Press.
3. Cohn, R. "Neo-Riemannian Operations, Parsimonious Trichords, and Their Tonnetz Representations." *Journal of Music Theory* 41.1 (1997): 1–66.
4. Mazzola, G. *The Topos of Music* (2002). Birkhäuser.
5. Fiore, T.M. and Satyendra, R. "Generalized Contextual Groups." *Music Theory Online* 11.3 (2005).
