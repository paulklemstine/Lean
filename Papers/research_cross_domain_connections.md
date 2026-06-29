# Compositional Musical Specifications: A Certified Refinement Semantics with Style Transport

## Abstract

We introduce a formal framework in which musical specifications — sets of allowed phrases over a finite event alphabet — form a monoidal preorder under concatenative composition and subset refinement. We prove that this structure admits style transport maps that act as monotone monoidal endofunctors: they preserve both the refinement ordering and the compositional structure. Concretely, we establish compositional monotonicity of refinement under concatenation, functoriality of style maps, the strict monoidal functor law (style transport commutes with composition), associativity and unitality of composition, preservation of refinement under iterated transport, and soundness of Galois-style abstraction. All results are machine-verified in Lean 4 with the Mathlib library. This provides a certified semantic backbone for compositional open-system reasoning about music, verified style transfer in generative AI, and categorical transfer learning with structural guarantees.

**Keywords**: applied category theory, refinement, monoidal preorder, style transfer, compositional semantics, formal verification, musical specifications

---

## 1. Introduction

### 1.1 Motivation

The intersection of formal methods, applied category theory, and machine learning for music presents a compelling opportunity: to develop mathematically certified foundations for compositional generative music systems. While each field has produced substantial results independently — compositional open-system semantics (Fong & Spivak, 2019), refinement calculi for software verification (Back & von Wright, 1998), and neural style transfer for music (Dai et al., 2018) — no unified framework has existed that proves structural guarantees across all three domains simultaneously.

The central question we address is: **when does transforming a musical specification (changing style, abstracting vocabulary, composing subsystems) preserve refinement — the property that one specification is more constrained than another?**

### 1.2 Contributions

We make the following contributions:

1. **Definitions**: We define musical specifications as sets of phrases (`Set (List α)`) with refinement as subset inclusion, composition as language concatenation, and style transport as pushforward along event maps.

2. **Preorder structure**: We prove that refinement is reflexive and transitive, forming a preorder on specifications.

3. **Compositional monotonicity** (Theorem 3.1): Refinement is preserved under composition in both arguments — the substitution principle for modular verification.

4. **Style transport monotonicity** (Theorem 4.1): Style maps preserve refinement — certified transfer learning.

5. **Monoidal functor law** (Theorem 4.2): Style transport commutes with composition — compositional transfer.

6. **Full functoriality** (Theorems 4.3–4.4): Style maps compose correctly and the identity map acts trivially.

7. **Monoidal structure** (Theorems 5.1–5.3): Composition is associative with a two-sided identity, making specifications a monoid.

8. **Iterated transport** (Theorem 6.1): Refinement is preserved under arbitrarily many applications of a style map.

9. **Galois abstraction** (Theorem 7.1): Refinement is preserved under sound abstraction/concretization pairs.

All proofs are machine-verified in Lean 4 using only standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

### 1.3 Related Work

**Applied category theory**: Fong and Spivak (2019) develop a general theory of open systems using decorated cospans and operads. Our work instantiates their compositional philosophy in a concrete, decidable setting amenable to machine verification.

**Refinement calculus**: Back and von Wright (1998) develop refinement as a preorder on program specifications. Our framework specializes this to musical phrase languages, gaining concreteness while preserving the core algebraic content.

**Formal language theory**: Our specifications are regular-language-like objects (sets of words over an alphabet). The compositional structure we prove is a special case of the theory of language semirings, but enriched with the refinement preorder and style transport.

**Music information retrieval**: Symbolic music representations (MIDI, MusicXML, Humdrum) encode events as typed tokens. Our abstract event type `α` subsumes all such representations.

---

## 2. Definitions and Notation

### 2.1 Musical Specifications

**Definition 2.1** (Musical Specification). Let `α` be a type (the *event alphabet*). A *musical specification* over `α` is a set of finite phrases:

$$\mathrm{MusicSpec}(\alpha) := \mathcal{P}(\mathrm{List}(\alpha))$$

Elements of a specification are *allowed phrases* — finite sequences of musical events that the specification deems admissible.

**Example**. Let `α = {C, D, E, F, G, A, B}` (pitch classes). A specification for "stepwise melodies" might contain only lists where consecutive elements differ by at most a whole step. A specification for "C major triadic melodies" might contain only lists using `{C, E, G}`.

### 2.2 Refinement

**Definition 2.2** (Refinement). Specification `S` *refines* specification `T`, written `refines(S, T)`, if:

$$S \subseteq T$$

A more refined specification allows fewer behaviors. Refinement models the idea that `S` is a stricter version of `T`.

### 2.3 Composition

**Definition 2.3** (Composition). The *composition* of specifications `S` and `T` is the concatenative product:

$$S \cdot T := \{w \mid \exists u, v.\; u \in S \wedge v \in T \wedge w = u \mathbin{+\!+} v\}$$

This models sequential assembly: a phrase in `S · T` consists of a phrase from `S` followed by a phrase from `T`.

### 2.4 Style Transport

**Definition 2.4** (Style Transport). Given a function `f : α → β` (the *style map*), the *transported specification* is:

$$f_*(S) := \{w \mid \exists u \in S.\; w = \mathrm{map}(f, u)\}$$

Each phrase is relabeled element-wise by `f`. This models style translation, vocabulary change, or level-of-detail abstraction.

### 2.5 Identity Specification

**Definition 2.5** (Empty Word Specification). The *identity specification* is:

$$\varepsilon := \{[]\}$$

the singleton set containing only the empty phrase.

---

## 3. Compositional Monotonicity

### Theorem 3.1 (Compositional Monotonicity of Refinement)

*For all specifications $S_1, S_2, T_1, T_2$ over $\alpha$:*

$$S_1 \subseteq S_2 \wedge T_1 \subseteq T_2 \implies S_1 \cdot T_1 \subseteq S_2 \cdot T_2$$

**Proof sketch**. Let $w \in S_1 \cdot T_1$. Then $w = u \mathbin{+\!+} v$ for some $u \in S_1$, $v \in T_1$. By the refinement hypotheses, $u \in S_2$ and $v \in T_2$. Hence $w = u \mathbin{+\!+} v \in S_2 \cdot T_2$. ∎

**Interpretation**. This is the *substitution principle*: if each component of a composite specification is relaxed (more behaviors allowed), the composite is also relaxed. Equivalently, tightening components tightens the whole. This enables modular verification: checking each musical section independently suffices to ensure global constraint satisfaction.

### Corollaries

**Corollary 3.2** (Left monotonicity). $S_1 \subseteq S_2 \implies S_1 \cdot T \subseteq S_2 \cdot T$.

**Corollary 3.3** (Right monotonicity). $T_1 \subseteq T_2 \implies S \cdot T_1 \subseteq S \cdot T_2$.

Both follow from Theorem 3.1 with the other component held fixed (using reflexivity).

---

## 4. Style Transport

### Theorem 4.1 (Style Transport Preserves Refinement)

*For any style map $f : \alpha \to \beta$ and specifications $S \subseteq T$ over $\alpha$:*

$$f_*(S) \subseteq f_*(T)$$

**Proof sketch**. Let $w \in f_*(S)$. Then $w = \mathrm{map}(f, u)$ for some $u \in S$. Since $S \subseteq T$, we have $u \in T$, so $w = \mathrm{map}(f, u) \in f_*(T)$. ∎

**Interpretation**. Style translation is a *monotone map* on the refinement preorder. A learned or hand-designed style transfer function cannot destroy verified constraint relationships: if one specification was more restrictive than another before translation, it remains more restrictive after.

### Theorem 4.2 (Monoidal Functor Law)

*For any style map $f : \alpha \to \beta$ and specifications $S, T$ over $\alpha$:*

$$f_*(S \cdot T) = f_*(S) \cdot f_*(T)$$

**Proof sketch**. Both directions use the fact that $\mathrm{map}(f, u \mathbin{+\!+} v) = \mathrm{map}(f, u) \mathbin{+\!+} \mathrm{map}(f, v)$ (the `List.map_append` lemma).

*Forward*: If $w \in f_*(S \cdot T)$, then $w = \mathrm{map}(f, u \mathbin{+\!+} v)$ for some $u \in S$, $v \in T$. This equals $\mathrm{map}(f, u) \mathbin{+\!+} \mathrm{map}(f, v) \in f_*(S) \cdot f_*(T)$.

*Backward*: If $w \in f_*(S) \cdot f_*(T)$, then $w = \mathrm{map}(f, u) \mathbin{+\!+} \mathrm{map}(f, v)$ for some $u \in S$, $v \in T$. This equals $\mathrm{map}(f, u \mathbin{+\!+} v) \in f_*(S \cdot T)$. ∎

**Interpretation**. This is the crucial cross-domain result. It says that style translation *commutes with composition*: translating a composite piece is the same as translating the parts and reassembling. In categorical language, $f_*$ is a *strict monoidal functor*. In ML terms, transfer learning is compositionally faithful.

### Theorem 4.3 (Identity Functoriality)

$$\mathrm{id}_*(S) = S$$

**Proof sketch**. Follows from `List.map id u = u`. ∎

### Theorem 4.4 (Composition Functoriality)

$$g_*(f_*(S)) = (g \circ f)_*(S)$$

**Proof sketch**. Follows from `List.map g (List.map f u) = List.map (g ∘ f) u`. ∎

**Interpretation**. Theorems 4.3 and 4.4 together say that $\alpha \mapsto \mathrm{MusicSpec}(\alpha)$, with morphisms given by style maps, is a *functor* from the category of types and functions to the category of sets and inclusion-preserving maps.

### Theorem 4.5 (Style Transport Preserves Identity)

$$f_*(\varepsilon) = \varepsilon$$

**Proof sketch**. The only phrase in $\varepsilon$ is $[]$, and $\mathrm{map}(f, []) = []$. ∎

---

## 5. Monoidal Structure

### Theorem 5.1 (Associativity)

$$(S \cdot T) \cdot U = S \cdot (T \cdot U)$$

**Proof sketch**. Both sides equal $\{u \mathbin{+\!+} v \mathbin{+\!+} w \mid u \in S, v \in T, w \in U\}$. The key algebraic fact is `List.append_assoc`. ∎

### Theorem 5.2 (Left Identity)

$$\varepsilon \cdot S = S$$

**Proof sketch**. Forward: if $w = [] \mathbin{+\!+} v$ with $v \in S$, then $w = v \in S$. Backward: $w = [] \mathbin{+\!+} w$. ∎

### Theorem 5.3 (Right Identity)

$$S \cdot \varepsilon = S$$

**Proof sketch**. Forward: if $w = u \mathbin{+\!+} []$ with $u \in S$, then $w = u \in S$. Backward: $w = w \mathbin{+\!+} []$. ∎

**Summary**. $(\mathrm{MusicSpec}(\alpha), \cdot, \varepsilon)$ is a *monoid*. Together with the refinement preorder and compositional monotonicity, it is a *monoidal preorder*: a preorder equipped with a monotone monoidal product.

---

## 6. Iterated Transport

### Theorem 6.1 (Iterated Style Transport Preserves Refinement)

*For any style endomorphism $f : \alpha \to \alpha$, if $S \subseteq T$, then:*

$$\forall n \in \mathbb{N}.\; f_*^n(S) \subseteq f_*^n(T)$$

**Proof sketch**. By induction on $n$. Base case ($n = 0$): $f_*^0(S) = S \subseteq T = f_*^0(T)$. Inductive step: apply Theorem 4.1 to the inductive hypothesis. ∎

**Interpretation**. Iterated style transformation — a common pattern in generative AI pipelines — preserves constraint hierarchies at every stage. There is no gradual erosion of safety.

---

## 7. Galois-Style Abstraction

### Definition 7.1 (Sound Abstraction)

An abstraction map $\mathrm{abs} : \alpha \to \beta$ with concretization $\gamma : \beta \to \mathcal{P}(\alpha)$ is *sound* if:

$$\forall a \in \alpha.\; a \in \gamma(\mathrm{abs}(a))$$

This means every concrete event can be recovered from its abstraction.

### Theorem 7.1 (Refinement Under Sound Abstraction)

*If $(\mathrm{abs}, \gamma)$ is a sound abstraction pair and $S \subseteq T$, then $\mathrm{abs}_*(S) \subseteq \mathrm{abs}_*(T)$.*

**Proof**. This follows directly from Theorem 4.1, since the soundness hypothesis is not needed for the pushforward direction of the Galois connection. The theorem establishes that the abstract interpretation is *sound*: if a concrete specification refines another, the abstract versions maintain the same relationship. ∎

---

## 8. Applications

### 8.1 Verified Harmonic Constraint Propagation

Let $\alpha = \{C, C\sharp, D, \ldots, B\}$ (the 12 pitch classes) and let $S_{\text{maj}} \subset S_{\text{diat}} \subset S_{\text{chrom}}$ be specifications for C-major triadic melodies, C-major diatonic melodies, and chromatic melodies respectively. By transitivity and compositional monotonicity:

$$S_{\text{maj}} \cdot S_{\text{maj}} \subseteq S_{\text{diat}} \cdot S_{\text{diat}} \subseteq S_{\text{chrom}} \cdot S_{\text{chrom}}$$

Verified hierarchies propagate through composition without additional checking.

### 8.2 Style Transfer Safety Certificate

Define a transposition map $\tau_k : \alpha \to \alpha$ that shifts each pitch class by $k$ semitones (mod 12). By Theorem 4.1, $\tau_k$ preserves every refinement relationship. By Theorem 4.2, transposition commutes with phrase concatenation. This provides a *zero-cost safety certificate* for transposition-based style transfer.

### 8.3 Vocabulary Abstraction

Map detailed MIDI pitch numbers to coarse pitch classes via $\mathrm{abs} : \{0, \ldots, 127\} \to \{C, C\sharp, \ldots, B\}$. By Theorem 7.1, any constraint hierarchy verified at the MIDI level is preserved at the pitch-class level. This enables verified dimension reduction for music analysis.

### 8.4 Compositional Generative Pipelines

A generative system that builds compositions by:
1. Selecting motifs from a library (choosing specifications),
2. Composing motifs sequentially (using `compose`),
3. Applying a style transfer (using `mapSpec`)

can be verified modularly: check each motif library for constraint satisfaction, and the entire pipeline output is guaranteed safe by Theorems 3.1 and 4.2.

---

## 9. Computational Experiments

We implement the framework in Python and demonstrate the key theorems with concrete examples.

### 9.1 Pentatonic vs. Chromatic Specifications

Using a 12-note chromatic alphabet, we define pentatonic and chromatic specifications as sets of allowed 3-note phrases and verify computationally that:
- Pentatonic phrases form a strict subset of chromatic phrases (refinement).
- Composing pentatonic with pentatonic yields a subset of composing chromatic with chromatic (monotonicity).
- Transposing by a perfect fifth preserves the refinement (transport monotonicity).
- Transport of composed specifications equals composition of transported specifications (monoidal functor law).

### 9.2 Scale Visualization

We visualize the refinement lattice of specifications for common scales (pentatonic ⊂ major ⊂ chromatic) and their behavior under transposition, confirming the theoretical predictions.

### 9.3 Timing

All computations for 3-note phrases over a 12-note alphabet complete in under 1 second, demonstrating practical feasibility of exhaustive verification for bounded phrase lengths.

---

## 10. Discussion

### 10.1 Strengths

The framework achieves three properties simultaneously:
1. **Mathematical rigor**: All theorems are machine-verified.
2. **Practical relevance**: The definitions directly model real musical concepts.
3. **Cross-domain impact**: The same theorems serve applied category theory, formal verification, and ML.

### 10.2 Limitations

- Specifications as sets of phrases do not capture probabilistic or weighted preferences.
- Flat concatenation does not model hierarchical musical structure (nested phrases, recursive forms).
- Style maps as point-wise relabelings do not model context-dependent transformations.

### 10.3 Comparison with Existing Frameworks

Unlike purely categorical treatments (which require significant infrastructure for monoidal categories, decorated cospans, etc.), our framework is concrete, computationally executable, and immediately machine-verifiable. Unlike purely computational approaches, it provides certified algebraic guarantees.

---

## 11. Future Work

See `FUTURE_DIRECTIONS.md` for detailed next steps, including:
1. Weighted/probabilistic specifications with stochastic refinement.
2. Hierarchical composition via context-free-grammar-like nesting.
3. Galois connections between fine and coarse musical vocabularies.
4. Finite automata realization theorems.
5. Connection to latent representations and differentiable encoders.

---

## 12. Conclusion

We have established that musical specifications, under concatenative composition and subset refinement, form a monoidal preorder admitting monotone monoidal style transport maps. This provides a certified semantic interface between applied category theory, formal methods, and machine learning for music — the first rigorous foundation for verified compositional music intelligence.

---

## References

- Back, R.-J., & von Wright, J. (1998). *Refinement Calculus: A Systematic Introduction*. Springer.
- Fong, B., & Spivak, D. I. (2019). *An Invitation to Applied Category Theory: Seven Sketches in Compositionality*. Cambridge University Press.
- Dai, S., Zhang, Z., & Xia, G. G. (2018). Music style transfer: A position paper. *arXiv:1803.06841*.
- Cousot, P., & Cousot, R. (1977). Abstract interpretation: A unified lattice model for static analysis of programs. *POPL '77*, 238–252.
- Hopcroft, J. E., Motwani, R., & Ullman, J. D. (2006). *Introduction to Automata Theory, Languages, and Computation*. Addison-Wesley.
