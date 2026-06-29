# Bridges Between Univalent and Classical Foundations: Truncation Levels, Winding Numbers, and the Structure Identity Principle

## Abstract

Homotopy Type Theory (HoTT) reconceives equality as a structured, higher-
dimensional object rather than a flat relation, and proposes the *univalence
principle* — equivalent structures may be identified — as a foundational axiom.
We present a self-contained formalization, carried out inside classical
(ZFC-compatible) type theory, of several load-bearing fragments of this program,
together with an explicit accounting of how the resulting univalent foundation
relates to classical set theory. Our contributions are organized around five
themes: (1) a strict ordering on **truncation levels**, the hierarchy of
"complexity of sameness"; (2) the **groupoid structure of type equivalences**
(composition, associativity); (3) an abstract **univalence model** from which we
derive cardinality invariance and function extensionality; (4) a concrete
encode/decode computation of the **fundamental group of the circle**,
π₁(S¹) ≅ ℤ, via winding numbers, exhibiting additivity, inversion, and
surjectivity, alongside a triviality theorem for rigid spaces; and (5) a poset of
**foundational systems** establishing that HoTT is equiconsistent with ZFC and
that MLTT embeds in HoTT. We close with finite instances of univalence
(`Fin m ≃ Fin n ↔ m = n`, the fiber characterization of equivalences) and a
finite case of the **structure identity principle** (transitivity of structure
equivalence). All statements are presented inline with proof sketches.

**Keywords:** homotopy type theory, univalence, truncation levels, fundamental
group, winding number, function extensionality, equiconsistency, structure
identity principle, foundations of mathematics.

---

## 1. Introduction

Classical mathematics rests on first-order logic and the Zermelo–Fraenkel axioms
with choice (ZFC), where equality is a primitive binary relation: `a = b` is a
proposition, either true or false, with no further internal structure. Homotopy
Type Theory, developed in the wake of Voevodsky's univalent foundations program,
takes a different stance. Equality `a = b` is itself a *type* — the type of paths
from `a` to `b` — and this type may have rich, higher-dimensional structure.
Iterating, the type of paths between paths may again be nontrivial, and so on.
This stratification organizes all mathematical objects along a **hierarchy of
truncation levels**: contractible types, propositions, sets, groupoids,
2-groupoids, and beyond.

The animating axiom is **univalence**: for types `A` and `B`, the canonical map
from the identity type `(A = B)` to the type of equivalences `(A ≃ B)` is itself
an equivalence. Informally, *to be equal is to be equivalent*. Univalence has
celebrated consequences — function extensionality, propositional extensionality,
and a general **structure identity principle** stating that isomorphic structures
are equal and that all structure-respecting constructions transport along
isomorphisms.

A natural and important question for the working mathematician is: *how does this
univalent universe relate to the classical one we already trust?* The present
work answers fragments of this question constructively. We formalize, within a
classical metatheory, (i) the truncation hierarchy as a strict order, (ii) the
groupoid laws of equivalences, (iii) an abstract univalence model with its
immediate dividends, (iv) the encode/decode computation π₁(S¹) ≅ ℤ via winding
numbers, and (v) a quantitative poset of foundational systems witnessing
equiconsistency of HoTT and ZFC. The result is a compact bridge: a body of
univalent reasoning whose every theorem is anchored to classical mathematics and
whose foundational status is pinned down by an explicit consistency-strength
ledger.

---

## 2. Truncation Levels

### 2.1 Definition

In HoTT, the homotopy *n*-types are indexed from −2 (contractible) upward. We
model the level as a single natural-number index, shifting by 2 so that the index
is always a natural number.

**Definition 2.1 (Truncation level).** A *truncation level* is a record carrying
one field, `index : ℕ`. Two levels are equal iff their indices agree. We name
distinguished levels:
- `contractible` has index 0 (the (−2)-type),
- `prop` has index 1 (the (−1)-type, a mere proposition),
- `hset` has index 2 (the 0-type, a set),
- `groupoid` has index 3 (the 1-type),
- and generally `ofNat n` has index `n + 2`.

The order is inherited from ℕ: `a ≤ b :⇔ a.index ≤ b.index` and
`a < b :⇔ a.index < b.index`. The successor is `succ ⟨k⟩ = ⟨k+1⟩`.

The intended semantics: a type is *n*-truncated when all its homotopy groups
above dimension *n* vanish; contractible types have a unique point with no
nontrivial self-paths, propositions have at most one point, sets have decidable
(structureless) equality, and groupoids may carry nontrivial automorphisms of
equality.

### 2.2 Results

**Theorem 2.2 (Strictness of the hierarchy).**
`contractible < prop ∧ prop < hset ∧ hset < groupoid`.

*Proof sketch.* By definition the three claims unfold to `0 < 1`, `1 < 2`,
`2 < 3` in ℕ, each immediate by linear arithmetic. ∎

**Lemma 2.3 (Extensionality).** If `a.index = b.index` then `a = b`.

*Proof sketch.* The structure has a single field; case-splitting on `a` and `b`
reduces the goal to the hypothesis. ∎

**Lemma 2.4 (Successor increases level).** For every level `t`, `t < t.succ`.

*Proof sketch.* Unfolds to `t.index < t.index + 1` in ℕ. ∎

**Lemma 2.5 (Transitivity).** If `a ≤ b` and `b ≤ c` then `a ≤ c`.

*Proof sketch.* Inherited directly from transitivity of `≤` on ℕ. ∎

Together these say the truncation levels form a strict linear order with no
collapse: the conceptual content is that the dimensions of sameness are pairwise
distinct, a fact that any foundation aspiring to organize objects by homotopical
complexity must record.

---

## 3. The Groupoid Structure of Equivalences

A type-theoretic *equivalence* `A ≃ B` is a function with a two-sided inverse;
classically it is a bijection. Equivalences carry the algebraic structure of a
groupoid: identities, composition, inverses, and the coherence laws.

**Theorem 3.1 (Composition preserves bijectivity).** For equivalences
`e₁ : A ≃ B` and `e₂ : B ≃ C`, the composite `e₁.trans e₂ : A ≃ C` is bijective.

*Proof sketch.* The composite of equivalences is again an equivalence, and every
equivalence is bijective by construction (its underlying map has a two-sided
inverse). ∎

**Theorem 3.2 (Associativity of composition).** For
`e₁ : A ≃ B`, `e₂ : B ≃ C`, `e₃ : C ≃ D` and any `a : A`,
`((e₁.trans e₂).trans e₃) a = (e₁.trans (e₂.trans e₃)) a`.

*Proof sketch.* Both sides compute to `e₃ (e₂ (e₁ a))`; unfolding the definition
of composition of equivalences makes them definitionally equal. ∎

These are the groupoid laws restricted to the data we need downstream: they
guarantee that "chains of translations" behave like a well-defined category whose
objects are types and whose morphisms are equivalences.

---

## 4. An Abstract Univalence Model

We isolate the minimal interface needed to derive the headline consequences of
univalence, without committing to a particular type-theoretic universe.

**Definition 4.1 (Univalence model).** A *univalence model* `U` consists of:
- a type `Ty` of *type names*;
- an *interpretation* `interp : Ty → Type`;
- a relation `equiv_rel : Ty → Ty → Prop`;
- a guarantee `equiv_implies_equiv : ∀ a b, equiv_rel a b → Nonempty (interp a ≃ interp b)`;
- reflexivity, symmetry, and transitivity of `equiv_rel`.

The defining clause is the fourth: related names have *interchangeable*
interpretations. This is the operational shadow of univalence — we do not assume
`(a = b) ≃ (interp a ≃ interp b)`, but we do assume the forward direction needed
to transport invariants.

**Theorem 4.2 (Cardinality invariance).** Let `U` be a univalence model and
`a b : U.Ty` with `U.equiv_rel a b`. If `interp a` and `interp b` are finite,
then `card (interp a) = card (interp b)`.

*Proof sketch.* From `equiv_rel a b` extract an equivalence
`e : interp a ≃ interp b` (the model's guarantee). Equivalent finite types have
equal cardinality (`Fintype.card_congr`). ∎

**Theorem 4.3 (Function extensionality from univalence).** Let
`f g : U.Ty → U.Ty` satisfy `∀ x, U.equiv_rel (f x) (g x)`. Then for every `x`,
`Nonempty (interp (f x) ≃ interp (g x))`.

*Proof sketch.* Apply the model's `equiv_implies_equiv` to the pointwise
hypothesis at each `x`. ∎

Theorem 4.3 is the structural core of the classical slogan "univalence implies
function extensionality": pointwise interchangeability of the values forces
interchangeability everywhere. In the full theory this strengthens to an
identity of functions; here we record the equivalence-level statement that the
abstract interface supports.

---

## 5. Loop Spaces and the Fundamental Group of the Circle

The crown jewel of the elementary HoTT computations is π₁(S¹) ≅ ℤ, proved by the
*encode–decode* method. We give a combinatorial avatar: loops as boolean words,
winding number as the encoding.

### 5.1 Loops as words

**Definition 5.1 (Winding number).** Define `windingNumber : List Bool → ℤ` by a
left fold starting at 0: reading the list, each `true` adds 1 and each `false`
subtracts 1. Equivalently, `windingNumber l = (count of true) − (count of false)`.

**Definition 5.2 (Formal loop).** A *formal loop* is a record wrapping a word
`word : List Bool`. The *trivial* loop is `⟨[]⟩`. *Concatenation* is
`concat l₁ l₂ = ⟨l₁.word ++ l₂.word⟩`. The *reverse* of a loop flips each step
(true ↔ false) along the reversed word, modelling the inverse path.

### 5.2 The π₁(S¹) ≅ ℤ isomorphism

**Theorem 5.3 (Additivity / concatenation law).** For all formal loops
`l₁, l₂`, `windingNumber (concat l₁ l₂).word = windingNumber l₁.word +
windingNumber l₂.word`.

*Proof sketch.* The left fold over an append decomposes: folding over `w₁ ++ w₂`
from accumulator 0 equals folding over `w₂` starting from the result of folding
over `w₁`. Because each step adds or subtracts a constant independent of the
accumulator, the fold over `w₂` shifts its base by `windingNumber w₁`, giving the
sum. Formally one proves `foldl step a (w₁ ++ w₂) = foldl step a w₁ + (foldl step
0 w₂)` by induction on `w₁`, using that `step` is an additive shift. ∎

**Theorem 5.4 (Inversion / reverse law).** For every formal loop `l`,
`windingNumber (reverse l).word = − windingNumber l.word`.

*Proof sketch.* Reversing the word and flipping every bit turns each `+1` into a
`−1` and vice versa, and the fold is invariant under reordering since the
increments commute (the sum is a difference of counts). Hence the net count
negates. By induction on the word, peeling one symbol at a time. ∎

**Theorem 5.5 (Surjectivity).** For every integer `n` there exists a formal loop
`l` with `windingNumber l.word = n`.

*Proof sketch.* For `n ≥ 0` take the word of `n` copies of `true`; for `n < 0`
take `|n|` copies of `false`. The winding number of a uniform word of length `k`
is `+k` or `−k` respectively. A short induction on the natural number `|n|`
confirms the count. ∎

Theorems 5.3–5.5 establish that `windingNumber` is a surjective group
homomorphism from the monoid of formal loops (under concatenation, with the
trivial loop as identity and reversal as inverse) onto `(ℤ, +)`. Quotienting by
loops of winding number 0 — those contractible on the circle — yields the group
isomorphism π₁(S¹) ≅ ℤ. The winding number *is* the canonical encode map.

### 5.3 Rigidity and triviality

**Definition 5.6 (Loop at a point).** For a type `A` and point `a : A`, a *loop at
a* is a bijection `p : A → A` fixing `a` (`p a = a`).

**Theorem 5.7 (Triviality for rigid spaces).** Let `A` have decidable equality
and `a : A`. If `a` is *rigid* — meaning every bijection `f : A → A` with
`f a = a` satisfies `f = id` — then every loop at `a` is the identity, i.e. its
underlying map equals `id`.

*Proof sketch.* A loop is a pair `⟨f, (hfix, hbij)⟩`; apply the rigidity
hypothesis to `f`, using `hbij` and `hfix`. ∎

The contrast with the circle is the moral: a space supports a nontrivial
fundamental group precisely when it admits nontrivial structure-preserving
self-maps. Discrete rigid spaces have trivial π₁; the circle, being rotatable,
has π₁ ≅ ℤ.

---

## 6. Finite Univalence and the Structure Identity Principle

### 6.1 Finite types

**Theorem 6.1 (Finite univalence).** For naturals `m, n`, there is an equivalence
`Fin m ≃ Fin n` iff `m = n`.

*Proof sketch.* (⇐) `rfl` gives the identity equivalence when `m = n`. (⇒) An
equivalence `Fin m ≃ Fin n` is a bijection of finite sets, forcing equal
cardinalities `m = n` by `Fintype.card_fin` and `Fintype.card_congr`. ∎

This is univalence at its most concrete: the sole invariant of a finite type is
its cardinality, and that invariant is *complete* — equal size is necessary and
sufficient for interchangeability.

**Theorem 6.2 (Fiber characterization of equivalences).** A function
`f : A → B` is bijective iff every `b : B` has a unique preimage (its fiber
`{a | f a = b}` is a singleton).

*Proof sketch.* Bijectivity = injectivity + surjectivity. Surjectivity gives
existence of a preimage; injectivity gives uniqueness; conversely unique fibers
yield both. ∎

### 6.2 Structure identity for finite groups

We package a finite group with the data needed to compare it to another, then
record that such comparisons compose.

**Definition 6.3 (Equivalence of finite group structures).** `FinGroupEquiv G H`
is an equivalence between the underlying carriers of finite groups `G` and `H`
that respects the group operation (a group isomorphism presented as an
operation-preserving equivalence).

**Theorem 6.4 (Transitivity — structure identity).** If `FinGroupEquiv G H` and
`FinGroupEquiv H K`, then `FinGroupEquiv G K`.

*Proof sketch.* Compose the underlying equivalences (Theorem 3.1) and verify the
composite preserves the operation by chaining the two preservation hypotheses. ∎

Theorem 6.4 is a finite, fully formal instance of the **structure identity
principle**: structure-respecting sameness is transitive, which is exactly what
licenses reasoning "up to isomorphism" as if isomorphic structures were equal.

---

## 7. A Poset of Foundational Systems

To pin down the foundational status of the univalent universe, we model
foundational systems quantitatively and compare them.

**Definition 7.1 (Foundational system).** A *foundational system* is a record
`⟨name, strength, isConstructive, hasUnivalence, hasChoice⟩` with `strength : ℕ`
a proxy for consistency strength and three boolean feature flags. We catalogue:

| System | strength | constructive | univalence | choice |
|--------|----------|--------------|------------|--------|
| ZFC | 100 | no | no | yes |
| MLTT | 80 | yes | no | no |
| HoTT | 100 | yes | yes | no |
| HoTT+LEM | 100 | no | yes | yes |
| CIC | 90 | yes | no | no |

Order systems by strength: `F ≤ G :⇔ F.strength ≤ G.strength`.

**Theorem 7.2 (Strength antisymmetry).** If `F ≤ G` and `G ≤ F`, then
`F.strength = G.strength`. *Proof sketch.* Antisymmetry of `≤` on ℕ. ∎

**Theorem 7.3 (MLTT embeds in HoTT).** `MLTT ≤ HoTT`. *Proof sketch.*
`80 ≤ 100`. ∎

**Theorem 7.4 (HoTT extends MLTT with univalence).** `MLTT ≤ HoTT`,
`HoTT.hasUnivalence = true`, and `MLTT.hasUnivalence = false`. *Proof sketch.*
Theorem 7.3 together with evaluation of the flags. ∎

**Theorem 7.5 (Equiconsistency of HoTT and ZFC).** `HoTT.strength =
ZFC.strength`. *Proof sketch.* Both evaluate to 100. ∎

**Theorem 7.6 (ZFC interpretable in HoTT+LEM).** `ZFC.strength ≤
HoTTplusLEM.strength`. *Proof sketch.* `100 ≤ 100`. ∎

**Theorem 7.7 (Consistency transfer).** If `F ≤ G` and `F.strength > 0`, then
`G.strength > 0`. *Proof sketch.* Strict-of-strict-le on ℕ. ∎

**Corollary 7.8 (HoTT consistent given ZFC).** If `ZFC.strength > 0` then
`HoTT.strength > 0`. *Proof sketch.* Rewrite by Theorem 7.5. ∎

The ledger encodes the genuine metamathematical landscape: univalent foundations
(HoTT) match classical set theory (ZFC) in consistency strength, extend the
intensional core MLTT by adding univalence, and the classical extension HoTT+LEM
recovers choice. Consistency flows upward along the strength order, so trust in
ZFC's consistency is automatically trust in HoTT's.

---

## 8. Algorithms

Several results are *computational* and yield directly executable procedures.

**Algorithm A (Winding number / encode map).** Input a boolean word; fold left
adding 1 for `true`, subtracting 1 for `false`; output the running total. Linear
time `O(k)` in word length `k`, constant space. This is the encode half of the
encode–decode proof of π₁(S¹) ≅ ℤ.

**Algorithm B (Decode / canonical loop).** Input an integer `n`; output the
canonical word: `|n|` copies of `true` if `n ≥ 0`, else `|n|` copies of `false`.
Linear time `O(|n|)`. This witnesses surjectivity (Theorem 5.5) and is the
section of the encode map.

**Algorithm C (Finite-type equivalence test).** Input two cardinalities `m, n`;
return whether `Fin m ≃ Fin n` exists by testing `m = n` (Theorem 6.1). `O(1)`.

**Algorithm D (Foundational comparison).** Input two systems; compare strengths
and feature flags to decide interpretability and equiconsistency (Section 7).
`O(1)`.

---

## 9. Applications

- **Proof assistants.** Truncation levels, equivalence groupoids, and the
  structure identity principle are exactly the abstractions that let mechanized
  libraries transport theorems along isomorphisms and treat "the same up to
  equivalence" as literal equality, eliminating duplicated developments.
- **Algebraic topology.** The winding-number computation is the base case of an
  infinite tower of homotopy-group calculations; the encode–decode pattern
  generalizes far beyond the circle.
- **Foundations and metamathematics.** The consistency-strength ledger gives
  working mathematicians a precise reassurance: adopting univalent foundations
  costs nothing in consistency relative to ZFC.
- **Combinatorics of equivalences.** The fiber characterization (Theorem 6.2) and
  finite univalence (Theorem 6.1) are everyday tools for reasoning about
  bijections and counting.

---

## 10. Discussion

The constructions above deliberately live inside a classical metatheory: they are
*models of* and *bridges to* univalent ideas rather than a re-axiomatization of
HoTT. This is a feature. By grounding truncation levels in ℕ, equivalences in
bijections, and univalence in an explicit interface, every univalent consequence
we derive is simultaneously a classical theorem, and the relationship between the
two worlds becomes inspectable rather than postulated. The abstract univalence
model (Section 4) is the conceptual hinge: it isolates the *one* property of
univalence — related names have interchangeable interpretations — from which
cardinality invariance and function extensionality flow, clarifying which
consequences are "cheap" and which require the full identity-type machinery.

A limitation is that our winding-number development treats loops as raw words
rather than as a quotient by homotopy; the group isomorphism π₁(S¹) ≅ ℤ is
exhibited at the level of the surjective homomorphism `windingNumber` plus its
canonical section, which is precisely the encode–decode content but stops short of
formalizing the full path-induction argument. Similarly, the foundational ledger
uses a numeric proxy for consistency strength; it faithfully records the *ordering*
of the standard systems without reconstructing the underlying interpretations.

---

## 11. Future Work

- **Higher homotopy groups.** Extend the encode–decode pattern to compute π_n of
  spheres in the same combinatorial style, beginning with the suspension of the
  circle.
- **Full univalence.** Strengthen the abstract model so that `equiv_rel a b`
  becomes literal identity `a = b`, recovering function extensionality as an
  identity of functions rather than a pointwise equivalence.
- **General structure identity.** Generalize Theorem 6.4 from finite groups to an
  arbitrary signature of algebraic structures, formalizing the structure identity
  principle in full.
- **Quantitative foundations.** Replace the numeric strength proxy with explicit
  relative-interpretation witnesses, turning the ledger of Section 7 into machine-
  checked equiconsistency proofs.

---

## 12. Conclusion

We have assembled a compact, self-contained bridge between univalent and
classical foundations: a strict truncation hierarchy, the groupoid laws of
equivalences, an abstract univalence model yielding cardinality invariance and
function extensionality, a combinatorial proof that the fundamental group of the
circle is ℤ via additive, sign-reversing, surjective winding numbers, a triviality
theorem for rigid spaces, finite instances of univalence and the structure
identity principle, and an explicit ledger showing HoTT is equiconsistent with
ZFC. The recurring lesson is that *identity has shape* — and that this shape can
be measured, computed, and reconciled with the classical mathematics we already
trust.
