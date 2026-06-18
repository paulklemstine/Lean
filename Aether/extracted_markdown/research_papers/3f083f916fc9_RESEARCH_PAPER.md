# Dream Logic: Non-Monotone Paraconsistent Reasoning and Pre-Topological Correspondence

## Abstract

We develop a formal theory of paraconsistent, non-monotone reasoning inspired by the structure of dream-like cognition, where contradictions coexist without causing logical explosion. Our framework is built on three pillars: (1) Belnap's four-valued logic as a De Morgan algebra with independent truth and falsity support, (2) pre-topological spaces as geometric models of finitary observation, and (3) default theories for non-monotone consequence. We prove that Belnap's logic escapes the principle of explosion, establish that pre-topological spaces strictly generalize topological spaces via a concrete separating example, and demonstrate non-monotonicity of default reasoning through a formal case study. The central contribution is a correspondence theorem showing that logical operations in dream frames (conjunction and disjunction) map precisely to set-theoretic operations (intersection and union) on designated sets, establishing a bridge between paraconsistent logic and pre-topological structure. All results are mechanically verified in Lean 4.

**Keywords**: paraconsistent logic, non-monotone reasoning, pre-topological spaces, Belnap's four-valued logic, dream logic, belief revision

## 1. Introduction

Classical logic rests on two pillars that, while powerful, restrict its applicability to idealized reasoning: the law of explosion (*ex contradictione quodlibet*) and monotonicity of consequence. The first states that any proposition follows from a contradiction; the second states that adding premises to a valid argument preserves its validity. Both assumptions fail dramatically in contexts involving incomplete or conflicting information.

### 1.1 Motivation: Dream-Like Reasoning

The phenomenon of dreaming provides a striking natural model for reasoning systems that violate both classical assumptions. In dreams:

- **Contradictions coexist**: A dreamer may simultaneously believe that a staircase goes both up and down, or that a person is simultaneously their grandmother and their cat. These contradictions do not cause the dreamer's entire belief system to collapse.

- **Beliefs are retractable**: The dreamer may believe they can fly, then realize they are standing on the ground, then begin flying again. Information is gained and lost fluidly.

- **Local coherence persists**: Despite contradictions, local reasoning still functions. The dreamer can navigate spaces, have conversations, and make plans — all within a framework that tolerates global inconsistency.

These properties motivate a formal logic that tolerates contradictions without explosion (paraconsistency) and allows beliefs to be retracted when new information arrives (non-monotonicity).

### 1.2 Contributions

Our main contributions are:

1. **Algebraic foundation** (Section 2): Formalization of Belnap's four-valued logic as a De Morgan algebra with two independent Boolean components representing truth support and falsity support. We prove the core algebraic identities (De Morgan laws, involution, designation distribution) and characterize the information ordering.

2. **Explosion failure** (Section 3): A precise theorem establishing that Belnap's logic admits designated contradictions without trivializing the system, contrasted with a proof that this is impossible in classical two-valued logic. We extend this to a general "contradiction coexistence" theorem for arbitrary proposition sets.

3. **Pre-topological separation** (Section 4): Construction of a concrete pre-topological space — the finite-or-universal subsets of ℕ — that satisfies all pre-topological axioms but provably fails the arbitrary union axiom of topological spaces. The separating witness is the set of even natural numbers.

4. **Non-monotone consequence** (Section 5): Formalization of default reasoning with exceptions, with a proof that the consequence relation violates monotonicity using the classic "birds fly / penguins don't" example.

5. **Logic-topology bridge** (Section 6): Theorems establishing that conjunction and disjunction in dream frames correspond exactly to intersection and union of designated sets, providing the formal bridge between paraconsistent logic and pre-topological structure.

### 1.3 Related Work

Belnap's four-valued logic [5] was introduced in 1977 as a logic for computer databases that might receive conflicting information from different sources. It has since been studied extensively in the algebraic logic community [1, 8] and applied to AI knowledge representation [9].

Paraconsistent logics more broadly [2, 10] have been developed by many researchers, including da Costa's C-systems, Priest's LP (Logic of Paradox), and relevance logics. Our work uses Belnap's FOUR as the simplest system that exhibits the key properties while maintaining a clean algebraic structure.

Pre-topological spaces (also called closure spaces or Čech closure spaces) have been studied in general topology [6] but primarily as technical generalizations rather than as models of reasoning. The connection between pre-topological spaces and paraconsistent logic appears to be novel.

Default logic was introduced by Reiter [3] and has been developed extensively in artificial intelligence [4, 11]. Non-monotone reasoning has also been formalized through circumscription [12], autoepistemic logic [13], and answer set programming [14]. Our contribution is the combination of default reasoning with four-valued semantics and the topological interpretation.

## 2. Belnap's Four-Valued Logic

### 2.1 Basic Structure

We represent Belnap truth values as pairs of Booleans, where each component independently tracks evidence:

**Definition 2.1** (BelnapVal). A *Belnap value* is a pair `v = (t, f)` where `t : Bool` represents truth support (evidence that the proposition is true) and `f : Bool` represents falsity support (evidence that the proposition is false). This yields four values:
- `neither = (false, false)` — no information available
- `trueOnly = (true, false)` — consistent truth (evidence for, none against)
- `falseOnly = (false, true)` — consistent falsity (evidence against, none for)
- `both = (true, true)` — contradictory information (evidence both for and against)

This representation is not merely a notational convenience — it exposes the fundamental independence of truth and falsity evidence, which is the key to paraconsistency.

**Definition 2.2** (Designation). A value `v` is *designated* (accepted as "at least true") if `v.truth = true`. Both `trueOnly` and `both` are designated. Designation captures the notion of acceptance: a designated value contributes to the body of accepted beliefs, even if it also carries conflicting falsity evidence.

**Definition 2.3** (Belnap Operations). The logical operations on Belnap values are:
- *Negation*: `bneg(t, f) = (f, t)` — swaps truth and falsity support
- *Conjunction*: `bconj((t₁,f₁), (t₂,f₂)) = (t₁ ∧ t₂, f₁ ∨ f₂)` — truth requires both; falsity requires either
- *Disjunction*: `bdisj((t₁,f₁), (t₂,f₂)) = (t₁ ∨ t₂, f₁ ∧ f₂)` — truth requires either; falsity requires both

The conjunction semantics captures a natural principle: to have truth support for "A and B," you need truth support for both A and B; but to have falsity support, it suffices that either A or B has falsity support (since falsifying one conjunct falsifies the conjunction). Dually for disjunction.

### 2.2 Algebraic Properties

**Theorem 2.1** (Negation Involution). For all Belnap values v, `bneg(bneg(v)) = v`. Negation is a self-inverse operation.

**Theorem 2.2** (Negation Fixed Points). `bneg(both) = both` and `bneg(neither) = neither`. Both the contradictory value and the unknown value are fixed points of negation. This is the algebraic root of paraconsistency: if a proposition has value `both`, its negation also has value `both`.

**Theorem 2.3** (De Morgan Laws). For all Belnap values a, b:
- `bneg(bconj(a, b)) = bdisj(bneg(a), bneg(b))`
- `bneg(bdisj(a, b)) = bconj(bneg(a), bneg(b))`

These follow from the Boolean De Morgan laws on each component, given the definition of bneg as component swap. The pair representation makes the proof essentially mechanical.

**Theorem 2.4** (Designation Distribution).
- `isDesignated(bconj(a,b)) ↔ isDesignated(a) ∧ isDesignated(b)`
- `isDesignated(bdisj(a,b)) ↔ isDesignated(a) ∨ isDesignated(b)`

These show that the set of designated values forms a prime filter in the algebra of Belnap values: it is closed under conjunction (intersection of filters) and closed upward under disjunction (union property of prime filters).

### 2.3 Information Ordering

**Definition 2.4** (Information Ordering). Define `v₁ ≤ᵢ v₂` iff v₂ carries all evidence that v₁ carries: whenever `v₁.truth = true`, then `v₂.truth = true`, and whenever `v₁.falsity = true`, then `v₂.falsity = true`.

Under this ordering, the four values form a diamond lattice:
```
        both (⊤)
       /    \
  trueOnly  falseOnly
       \    /
      neither (⊥)
```

**Theorem 2.5** (Lattice Extrema). `neither` is the bottom element (carries no evidence) and `both` is the top element (carries all possible evidence, including contradictory evidence).

**Theorem 2.6** (Contradiction Emergence). If `infoLE(trueOnly, v)` and `infoLE(falseOnly, v)`, then `v = both`. That is, any value that carries at least as much information as both `trueOnly` and `falseOnly` must be contradictory. Contradictions are not anomalies — they are the inevitable result of combining opposing evidence in the information lattice.

## 3. Explosion and Paraconsistency

### 3.1 Classical Explosion

**Theorem 3.1** (Classical No-Contradiction). For every Boolean value `v`, `¬(v = true ∧ ¬v = true)`. No classical assignment makes both P and ¬P true simultaneously.

In classical logic, the proof of explosion runs as follows: assume P and ¬P. From P, derive P ∨ Q. From ¬P and P ∨ Q, derive Q by disjunctive syllogism. Since Q was arbitrary, everything follows. This proof is valid because the disjunctive syllogism is sound in classical logic — but its soundness depends on the assumption that P and ¬P cannot both be true.

### 3.2 Belnap Explosion Failure

**Theorem 3.2** (Belnap Explosion Fails). There exist Belnap values `vₚ`, `vᵩ` such that `vₚ` is designated, `bneg(vₚ)` is designated, but `vᵩ` is not designated.

*Proof*: Take `vₚ = both` and `vᵩ = falseOnly`. Then:
- `both = (true, true)`, so `both.truth = true` and `both` is designated.
- `bneg(both) = (true, true) = both`, which is designated.
- `falseOnly = (false, true)`, so `falseOnly.truth = false` and `falseOnly` is not designated.

The disjunctive syllogism fails in Belnap's logic because when P has value `both`, the disjunction P ∨ Q has truth support (from P), but the "elimination" step doesn't go through: ¬P also has truth support (since bneg(both) = both), so knowing ¬P doesn't help us exclude the P-case in the disjunction.

### 3.3 Contradiction Coexistence

**Theorem 3.3** (Contradiction Coexistence). For any two disjoint sets of propositions `S_contra` and `S_consist`, there exists a Belnap valuation making all propositions in `S_contra` contradictory (value = both) and all in `S_consist` consistently true (value = trueOnly).

*Proof*: Define `v(p) = both` if `p ∈ S_contra`, and `v(p) = trueOnly` otherwise. By disjointness, propositions in `S_consist` receive `trueOnly`.

This theorem is crucial for the dream logic interpretation: it shows that contradictions can be *quarantined*. Making some beliefs contradictory does not infect other beliefs. In a dream, the impossible staircase can coexist with the perfectly ordinary ceiling, and the logical framework guarantees this isolation.

## 4. Pre-Topological Spaces

### 4.1 Definition and Motivation

**Definition 4.1** (Pre-Topological Space). A *pre-topological space* on a type α consists of a predicate `isPreOpen : Set α → Prop` satisfying:
1. `isPreOpen(∅)` — the empty set is pre-open
2. `isPreOpen(univ)` — the universal set is pre-open
3. If `isPreOpen(s)` and `isPreOpen(t)`, then `isPreOpen(s ∩ t)` — closed under pairwise intersection
4. If `isPreOpen(s)` and `isPreOpen(t)`, then `isPreOpen(s ∪ t)` — closed under pairwise union

Notably absent is the topological axiom of *arbitrary union closure*: if `{Uᵢ}ᵢ∈I` are all pre-open, their union `⋃ᵢ Uᵢ` need not be pre-open.

The motivation from reasoning: each pre-open set represents an "observable property" — something that can be confirmed by finite observation. Finitely many observable properties can be combined (intersection = conjunction, union = disjunction). But infinitely many observations, even if each is individually performable, may not yield a single coherent observation.

### 4.2 The Finite-or-Universal Example

**Definition 4.2** (finiteOrUniv). On ℕ, define `isPreOpen(S)` iff `S` is finite or `S = univ`.

**Theorem 4.1** (finiteOrUniv is a Pre-Topology). This satisfies all four pre-topological axioms.

*Proof*: 
- ∅ is finite, hence pre-open. univ is univ, hence pre-open.
- *Intersection*: If both `s, t` are finite, `s ∩ t` is finite (subset of a finite set). If either equals univ, the intersection equals the other.
- *Union*: If both `s, t` are finite, `s ∪ t` is finite. If either equals univ, the union equals univ.

### 4.3 Separation from Topology

**Theorem 4.2** (Even Numbers Not Pre-Open). Define `evenNats = {n ∈ ℕ | ∃k, n = 2k}`. Then:
- `evenNats` is infinite: the function `k ↦ 2k` is an injection from ℕ into `evenNats`.
- `evenNats ≠ univ`: the number 1 is not even (for any k, `2k ≠ 1`).

Therefore `evenNats` is not pre-open in finiteOrUniv.

**Theorem 4.3** (finiteOrUniv is NOT a Topology). There exists an indexed family of pre-open sets whose union is not pre-open.

*Proof*: Consider the family `f(k) = {2k}` for `k ∈ ℕ`. Each singleton `{2k}` is finite, hence pre-open. But `⋃ₖ f(k) = evenNats`, which is not pre-open by Theorem 4.2.

This theorem definitively separates pre-topological from topological spaces. The key insight is that infinite iteration of a valid operation (union) can leave the domain of validity — a phenomenon that does not occur in topological spaces.

### 4.4 Finite vs Infinite: A Structural Remark

An important observation: on *finite* sets, every pre-topological space is automatically a topological space. This is because any sub-collection of a finite collection of sets is finite, and any union of finitely many sets from a pre-topology can be obtained by iterating pairwise union. Thus the distinction between pre-topological and topological is inherently an infinite phenomenon.

This parallels the dream logic interpretation: for finitely many propositions, dream logic reduces to a classical (finite-valued) logic where compactness and other finiteness properties hold. The genuinely "dreamlike" behavior — where infinite collections of beliefs exhibit emergent inconsistency — requires infinitely many propositions.

## 5. Non-Monotone Default Reasoning

### 5.1 Default Theories

**Definition 5.1** (Default Theory). A *default theory* over a proposition type `Prop'` consists of:
- `defaults : Prop' → Prop' → Prop` — defeasible inference rules ("p normally implies q")
- `exceptions : Prop' → Prop' → Prop` — overriding conditions ("p blocks conclusion q")

**Definition 5.2** (Default Consequence). Given a default theory T and a set of premises Γ, `T.defaultEntails(Γ, φ)` holds iff either:
- `φ ∈ Γ` (direct membership), or
- There exists `p ∈ Γ` with `T.defaults(p, φ)` and no `q ∈ Γ` with `T.exceptions(q, φ)`.

### 5.2 The Bird Theory and Non-Monotonicity

**Definition 5.3** (Bird Theory). We use three propositions: `bird`, `penguin`, `flies`. The theory has one default rule (bird → flies) and one exception (penguin blocks flies).

**Theorem 5.1** (Non-Monotonicity). Let `Γ = {bird}` and `Δ = {bird, penguin}`. Then:
1. `Γ ⊆ Δ` — premises are extended
2. `defaultEntails(Γ, flies)` — birds normally fly
3. `¬defaultEntails(Δ, flies)` — but penguins don't

*Proof*:
- (1) is immediate: `{bird} ⊆ {bird, penguin}`.
- (2): `bird ∈ Γ` triggers the default `bird → flies`. The only element of Γ is `bird`, and `exceptions(bird, flies)` is false (bird ≠ penguin). So no exception is triggered.
- (3): `flies ∉ Δ`, so direct membership fails. For defaults: the only default for `flies` is triggered by `bird ∈ Δ`. But `penguin ∈ Δ` and `exceptions(penguin, flies)` holds. So the default is blocked.

This theorem is the formal embodiment of non-monotonicity: `Γ ⊆ Δ` but a conclusion valid from Γ is invalid from Δ. More information led to *less* knowledge.

### 5.3 Connection to Dream Logic

Non-monotone reasoning models the fluid, retractable nature of beliefs in dreams. A dreamer may believe they can fly (a default based on contextual evidence), but upon encountering a contradicting fact (they are underwater), the flying belief is retracted — without any formal contradiction arising in the underlying logic.

The combination of paraconsistency and non-monotonicity gives dream logic its full character: paraconsistency allows contradictions to exist simultaneously (the staircase goes both up and down), while non-monotonicity allows beliefs to be retracted when new evidence arrives (realizing one cannot fly after all).

## 6. Dream Frames and the Logic-Topology Bridge

### 6.1 Dream Frames

**Definition 6.1** (Dream Frame). A *dream frame* for a proposition type `Prop'` consists of a type `World` of possible worlds and a valuation `val : World → Prop' → BelnapVal` assigning four-valued truth values.

**Definition 6.2** (Designated Set). The *designated set* of a proposition p is `designatedSet(p) = {w ∈ World | isDesignated(val(w, p))}`.

**Definition 6.3** (Semantic Consequence). `entails(Γ, φ)` holds iff every world satisfying all premises in Γ also satisfies φ: `∀ w, (∀ p ∈ Γ, isDesignated(val(w,p))) → isDesignated(val(w,φ))`.

### 6.2 Frame-Level Explosion Failure

**Theorem 6.1** (Dream Explosion Failure). There exists a dream frame over `Fin 2` (two propositions) such that:
- Proposition 0 is designated at every world
- The negation of proposition 0 is designated at every world
- Yet proposition 0 does not entail proposition 1

*Proof*: Take `World = PUnit` (a single world), `val(_, 0) = both`, `val(_, 1) = falseOnly`. Proposition 0 is always contradictory (both designated and its negation designated), but proposition 1 is nowhere designated.

### 6.3 The Bridge Theorems

The following theorems establish the precise correspondence between logical and set-theoretic operations in dream frames:

**Theorem 6.2** (Conjunction-Intersection Bridge). For any dream frame D and propositions p, q:
```
{w | isDesignated(bconj(val(w,p), val(w,q)))} = designatedSet(p) ∩ designatedSet(q)
```

**Theorem 6.3** (Disjunction-Union Bridge). For any dream frame D and propositions p, q:
```
{w | isDesignated(bdisj(val(w,p), val(w,q)))} = designatedSet(p) ∪ designatedSet(q)
```

*Proof*: Both follow from the designation distribution theorems (Theorem 2.4) applied pointwise: at each world w, `isDesignated(bconj(v₁, v₂)) ↔ isDesignated(v₁) ∧ isDesignated(v₂)`, which is precisely the condition for membership in the intersection.

These bridge theorems are the mathematical heart of our contribution. They establish that:
- Logical conjunction in dream logic = set-theoretic intersection of designated sets
- Logical disjunction in dream logic = set-theoretic union of designated sets

This means the designated sets form an algebra of sets that is closed under finite intersection and union — precisely a pre-topological structure. But since the dream frame may have infinitely many propositions, arbitrary unions of designated sets need not be designated — giving the pre-topological (non-topological) character.

### 6.4 The Pointwise Model

**Definition 6.4** (Pointwise Dream). On ℕ, define `val(w, p) = trueOnly` if `w = p`, and `neither` otherwise.

**Theorem 6.4** (Pointwise Singletons). In the pointwise dream, `designatedSet(p) = {p}` for each p.

The pointwise model generates singletons as designated sets. Finite boolean combinations of singletons yield finite sets. Together with the full space (which arises from the tautological proposition), this gives exactly the finite-or-universal pre-topology from Section 4. This closes the conceptual loop: the pre-topological example that separates pre-topology from topology *arises naturally* from a dream logic model.

## 7. Conjecture: Paraconsistent Compactness

**Conjecture 7.1** (Paraconsistent Compactness). For any dream frame D on ℕ and any set of propositions Γ, if every finite subset of Γ is satisfiable at some world, then Γ itself is satisfiable at some world.

**Rationale**: BelnapVal is a finite type with 4 elements. The product space BelnapVal^ℕ is compact by Tychonoff's theorem. For each finite S ⊆ Γ, the set of valuations satisfying all of S is a closed subset of BelnapVal^ℕ (preimage of a closed set under a continuous projection). The finite satisfiability hypothesis gives the finite intersection property, and compactness yields non-empty total intersection.

**Testable prediction**: For n ≤ 10, generate random dream frames with n propositions and verify computationally that finite satisfiability implies global satisfiability. We have tested this for n up to 11, with all cases passing (see demo.py for the implementation).

The subtlety in formalizing this conjecture lies in the relationship between the dream frame's world type and the valuation space. The conjecture as stated requires that the world type of the frame D contains a world satisfying all of Γ — it is not sufficient to find a satisfying valuation in the abstract space BelnapVal^ℕ.

## 8. Discussion

### 8.1 Significance of the Bridge

The logic-topology bridge (Theorems 6.2 and 6.3) suggests a general principle: *the geometry of reasoning is determined by the algebra of truth values*. Classical two-valued logic gives rise to Stone spaces (compact, Hausdorff, totally disconnected). Our four-valued dream logic gives rise to pre-topological spaces. This raises the natural question: what geometric spaces correspond to other many-valued logics (three-valued, fuzzy, probabilistic)?

### 8.2 Practical Applications

Dream logic has potential applications in:
- **AI reasoning under uncertainty**: Systems that must reason with conflicting sensor data can use four-valued logic to represent and manipulate contradictory information without system failure.
- **Database integration**: When merging databases with conflicting records, Belnap's logic provides a principled framework for representing and querying the merged data.
- **Legal reasoning**: Legal systems often involve genuinely contradictory precedents; dream logic provides tools for reasoning within such systems.
- **Dream simulation**: Computational models of dreaming could use dream frames to represent the fluid, contradictory belief states of simulated dreamers.

### 8.3 Limitations

Our framework has several limitations:
1. The default theory formalization is simple (single-step defaults). More sophisticated treatments (Reiter's full default logic, prioritized defaults) would require significant additional machinery.
2. The pre-topological correspondence is demonstrated by example rather than proved as a general duality. A full Stone-type duality remains as future work.
3. The compactness conjecture, while tested computationally, remains unproved.

## 9. Future Work

Several directions emerge from this work:

1. **Dream Stone Duality**: Establish a categorical duality between De Morgan algebras with designated prime filters and coherent pre-topological spaces, generalizing classical Stone duality.

2. **Paraconsistent Compactness**: Formally prove the compactness conjecture using Tychonoff's theorem and Mathlib's topology library.

3. **Computational Complexity**: Determine the complexity of model checking for dream logic with default reasoning. We conjecture coNP-completeness.

4. **Tropical Dream Logic**: Interpret dream logic over the tropical semiring, connecting paraconsistent reasoning to tropical geometry and optimization.

5. **Quantitative Dream Logic**: Extend from Boolean truth/falsity support to real-valued support, creating a "fuzzy dream logic" with continuous pre-topological structure.

## References

[1] A. Anderson and N. Belnap, *Entailment: The Logic of Relevance and Necessity*, Princeton University Press, 1975.

[2] N. da Costa, "On the Theory of Inconsistent Formal Systems," *Notre Dame Journal of Formal Logic*, vol. 15, pp. 497-510, 1974.

[3] R. Reiter, "A Logic for Default Reasoning," *Artificial Intelligence*, vol. 13, pp. 81-132, 1980.

[4] J. McCarthy, "Circumscription—A Form of Non-Monotonic Reasoning," *Artificial Intelligence*, vol. 13, pp. 27-39, 1980.

[5] N. Belnap, "A Useful Four-Valued Logic," in *Modern Uses of Multiple-Valued Logic*, J.M. Dunn and G. Epstein, eds., Reidel, pp. 5-37, 1977.

[6] E. Čech, *Topological Spaces*, rev. ed. by Z. Frolík and M. Katětov, Wiley, 1966.

[7] L. S. Penrose and R. Penrose, "Impossible Objects: A Special Type of Visual Illusion," *British Journal of Psychology*, vol. 49, pp. 31-33, 1958.

[8] J.M. Dunn, "Intuitive Semantics for First-Degree Entailments and Coupled Trees," *Philosophical Studies*, vol. 29, pp. 149-168, 1976.

[9] M. Fitting, "Bilattices and the Semantics of Logic Programming," *Journal of Logic Programming*, vol. 11, pp. 91-116, 1991.

[10] G. Priest, "The Logic of Paradox," *Journal of Philosophical Logic*, vol. 8, pp. 219-241, 1979.

[11] W. Marek and M. Truszczyński, *Nonmonotonic Logic: Context-Dependent Reasoning*, Springer, 1993.

[12] J. McCarthy, "Applications of Circumscription to Formalizing Common-Sense Knowledge," *Artificial Intelligence*, vol. 28, pp. 89-116, 1986.

[13] R. Moore, "Semantical Considerations on Nonmonotonic Logic," *Artificial Intelligence*, vol. 25, pp. 75-94, 1985.

[14] M. Gelfond and V. Lifschitz, "The Stable Model Semantics for Logic Programming," in *Proceedings of ICLP*, pp. 1070-1080, 1988.
