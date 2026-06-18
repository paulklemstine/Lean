# Polymodal Provability, Ordinal Ranks, and the Category of Gödel–Löb Frames

## Abstract

We present a rigorous, machine-verified development of the Kripke semantics of
Gödel–Löb provability logic (GL) and three structural extensions that bridge the
logic of provability to set theory, proof theory, and category theory. Working
with finite, irreflexive, transitive Kripke frames — the frames that
characterize GL by Segerberg's theorem — we (i) prove that every such frame
validates Löb's axiom `□(□φ → φ) → □φ` via well-founded induction along
accessibility; (ii) extract from the converse well-foundedness of accessibility a
canonical **ordinal rank** on every GL frame, strictly decreasing along the
accessibility relation, and identify it as the frame-internal form of
proof-theoretic ordinal analysis; (iii) define **polymodal GLP frames** as a
single world set carrying a nested family `R₀ ⊇ R₁ ⊇ ⋯` of GL accessibility
relations, show that each level is a genuine GL frame, and deduce that the boxes
are monotone in the modal index — the frame-semantic root of the GLP axiom
`[n]φ → [n+1]φ`; and (iv) define the **synchronized product** of GL frames, prove
closure of the GL frame class under it, and establish that the diamond
(consistency) operator factors exactly across a product rectangle,
`◇(A × B) = ◇A × ◇B`, while the box (provability) operator provably does not.
The non-factorization of the box is traced to vacuous truth at dead-end worlds,
exposing a directional asymmetry in the compositionality of self-referential
limitation. Every result is stated semantically over arbitrary finite frames and
is therefore independent of any particular arithmetical interpretation.

**Keywords:** provability logic, Gödel–Löb logic, Kripke semantics, Löb's
theorem, ordinal analysis, polymodal logic, GLP, well-foundedness, modal
products, incompleteness.

---

## 1. Introduction

Provability logic studies the modal principles governing the predicate "… is
provable in a fixed formal theory `T`." Writing `□φ` for "φ is provable in `T`,"
Solovay's arithmetical completeness theorem (1976) shows that the modal theorems
valid for `T = PA` are exactly those of the system **GL**, axiomatized by the
normal modal axioms together with **Löb's axiom**

```
□(□φ → φ) → □φ.
```

Setting `φ = ⊥` recovers Gödel's second incompleteness theorem: a consistent
theory cannot prove its own consistency. The semantic counterpart, due to
Segerberg (1971), characterizes GL by the class of **finite transitive
irreflexive Kripke frames** — equivalently, finite strict partial orders that are
(necessarily) well-founded.

This paper records a fully formal treatment of the frame semantics of GL and
extends it in three directions that connect provability logic outward to
adjacent fields:

1. **Set theory / ordinal analysis.** Converse well-foundedness — the defining
   feature of a GL frame — is exactly what is needed to assign every world an
   ordinal rank that strictly decreases along accessibility. This is the
   frame-internal incarnation of ordinal analysis.

2. **Proof theory / polymodal provability.** Japaridze's polymodal logic GLP
   stratifies provability into a sequence of modalities `[0], [1], [2], …` of
   increasing strength. We give the frame skeleton — a nested family of GL
   accessibility relations — and show the entire single-modal theory lifts level
   by level.

3. **Category theory.** GL frames are closed under a synchronized product, and
   the consistency operator factors across products exactly, while the
   provability operator does not. This identifies the product categorically (via
   the diamond) and isolates the obstruction (vacuous box truth at dead ends).

We emphasize that all theorems are purely semantic, quantifying over arbitrary
finite frames; they hold regardless of which arithmetical theory one interprets
the boxes by.

---

## 2. GL Frames and the Box/Diamond Operators

### 2.1 Frames

**Definition 2.1 (GL frame).** A *GL frame* `F` consists of a finite type of
*worlds* `W`, together with a binary *accessibility relation* `R : W → W → Prop`
that is

- **irreflexive:** `∀ w, ¬ R w w`; and
- **transitive:** `∀ w v u, R w v → R v u → R w u`.

We read `R w v` as "`v` is accessible from `w`," and intend worlds as
hypothetical complete extensions of a base theory ordered by relative strength.

**Definition 2.2 (box and diamond).** For a set of worlds `S ⊆ W`,

```
□S = boxSet(S)     := { w | ∀ v, R w v → v ∈ S },
◇S = diamondSet(S) := { w | ∃ v, R w v ∧ v ∈ S }.
```

Thus `w ∈ □S` iff `S` holds at every world visible from `w`, and `w ∈ ◇S` iff `S`
holds at some visible world.

### 2.2 Elementary algebra of the box

The following are proved directly from the definitions.

- **Monotonicity:** `boxSet` is monotone: `S ⊆ T ⟹ □S ⊆ □T`.
- **Normality / top:** `□W = W`.
- **Conjunctivity:** `□(S ∩ T) = □S ∩ □T`.
- **Duality:** `◇S = (□Sᶜ)ᶜ` and `□S = (◇Sᶜ)ᶜ`.

**Proposition 2.3 (upward closure of the box).** For every `S`, the set `□S` is
*upward closed*: if `w ∈ □S` and `R w v` then `v ∈ □S`.

*Proof.* If `R v u` then `R w u` by transitivity, so `u ∈ S` because `w ∈ □S`;
hence `v ∈ □S`. ∎

A set `S` is *upward closed* when `w ∈ S` and `R w v` imply `v ∈ S`. The upward
closed sets contain `∅` and `W` and are closed under finite intersection and
union; `□S` is always upward closed. (These facts assemble the upward-closed sets
into the algebraic structure underlying the lattice-of-extensions reading of GL,
but we will not need that structure below.)

### 2.3 Anti-reflexivity as Gödel II

**Proposition 2.4 (anti-reflexivity).** In any GL frame, `¬ R w w` for every `w`.

This is immediate from irreflexivity, but its semantic reading is the content of
Gödel's second theorem: no world can *see itself*, i.e., no consistent complete
extension lies in its own field of vision, so none can certify its own
soundness/consistency from within.

---

## 3. Well-Foundedness and Löb's Theorem

### 3.1 Well-foundedness

**Theorem 3.1 (well-foundedness).** In a GL frame, `R` is well-founded: there is
no infinite descending chain `w₀ R w₁ R w₂ R ⋯`.

*Proof sketch.* On a finite type, a transitive irreflexive relation has, in every
nonempty finite subset, an `R`-minimal element. (One proves this by induction on
the finite subset, using transitivity to merge the inductive minimal element with
a new element and irreflexivity to rule out self-loops.) Having minima in all
nonempty subsets is equivalent to well-foundedness. ∎

The dual statement — well-foundedness of the *converse* relation `flip R` — is
proved the same way and is what powers the ordinal rank of Section 4.

### 3.2 Löb's axiom

The principal soundness result is the semantic Löb theorem. Encoding the
implication `(□S → S)` as the set `(□S)ᶜ ∪ S` (since `p → q ≡ ¬p ∨ q`):

**Theorem 3.2 (frames validate Löb).** For every GL frame and every `S ⊆ W`,

```
boxSet( (boxSet S)ᶜ ∪ S ) ⊆ boxSet S,
```

i.e. `□(□S → S) ⊆ □S`.

*Proof sketch.* Fix `w` with `w ∈ □((□S)ᶜ ∪ S)`, and let `v` be any world with
`R w v`; we must show `v ∈ S`. Run a well-founded induction measuring each world
`v` by the (finite) number of worlds it can see, `|{ u | R v u }|`. By the upward
closure of the outer box (Proposition 2.3), `v` again satisfies
`□((□S)ᶜ ∪ S)`. For any successor `u` of `v`, the set of worlds `u` sees is a
*strict* subset of the set `v` sees (it omits `u` itself, which `v` sees by
transitivity but `u` cannot see by irreflexivity), so the measure strictly drops
and the induction hypothesis gives `u ∈ S`; thus `v ∈ □S`. The membership
`v ∈ (□S)ᶜ ∪ S` then forces `v ∈ S`. ∎

This is exactly the modal expression of Löb's theorem; with `S = ∅` it yields the
semantic form of Gödel II.

### 3.3 Maximal worlds

**Definition 3.3.** A world `w` is *maximal* (a *dead end*) if `∀ v, ¬ R w v`.

**Proposition 3.4.** At a maximal world, `w ∈ □S` for every `S` (vacuous truth).

**Proposition 3.5 (existence of dead ends).** Every nonempty GL frame has a
maximal world.

*Proof.* By well-foundedness of `flip R`, the whole (nonempty) world set has an
element minimal for `flip R`; such an element has no `R`-successor. ∎

Dead-end worlds are the base cases of every induction along accessibility and, as
we will see in Section 6, the precise obstruction to the box factoring over
products.

---

## 4. The Ordinal Rank of a GL Frame (Logic ↔ Set Theory)

### 4.1 Converse well-foundedness

**Theorem 4.1 (`flip_wellFounded`).** For every GL frame, the converse relation
`flip R` (defined by `flip R v w := R w v`) is well-founded.

*Proof.* `flip R` is transitive and irreflexive whenever `R` is, and the world
type is finite; a finite transitive irreflexive relation is well-founded. ∎

Concretely: there is no infinite *ascending* `R`-chain `w R w₁ R w₂ R ⋯`.

### 4.2 The rank

**Definition 4.2 (`rank`).** The *ordinal rank* of a world `w` is the
well-founded rank of `w` with respect to `flip R`:

```
rank(w) := IsWellFounded.rank (flip R) w
         = sup { rank(v) + 1 | R w v }.
```

Equivalently, `rank(w)` is the order type of the tree of `R`-ascending chains
issuing from `w`; for finite frames it is the length of the longest accessibility
chain starting at `w`. Dead ends have rank `0`.

**Theorem 4.3 (`gl_rank_lt_of_R`: rank strictly decreases along accessibility).**
For all worlds `w, v`, if `R w v` then `rank(v) < rank(w)`.

*Proof.* `R w v` means `flip R v w`, and the well-founded rank strictly increases
along the relation, i.e. `rank` of a `flip R`-predecessor is smaller; unwinding,
`rank(v) < rank(w)`. ∎

### 4.3 Reading: ordinal analysis inside the frame

Theorem 4.3 is the qualitative, *every-frame* generalization of an explicit
computation in the canonical model. Take `W = ℕ` with `R = (>)` — the purest GL
frame, "`n` sees all smaller numbers." Then `rank(n) = n`, and the iterated box
of falsity satisfies `□^k ∅ = { 0, 1, …, k-1 }`: the `k`-fold inconsistency
statement is *literally* the set of worlds of rank `< k`. Consistency strength and
frame depth coincide, and the strengths `k ↦ □^k ⊥` form a strictly increasing
chain that never reaches the top — a graded refinement of Gödel II. Theorem 4.3
says this rank phenomenon is not special to `(ℕ, >)`: every GL frame carries an
ordinal-valued depth that drops along accessibility, the semantic shadow of
assigning a proof-theoretic ordinal to a consistency level. Choosing the
*converse* relation is essential: using `R` directly inverts the inequality, and
indeed `(ℕ, <)` is not converse well-founded and fails Löb.

---

## 5. Polymodal GLP Frames (Logic ↔ Proof Theory)

### 5.1 Definition

**Definition 5.1 (`GLPFrame`).** A *polymodal GLP frame* `G` consists of a finite
type of worlds `W` together with an `ℕ`-indexed family of accessibility relations
`R : ℕ → W → W → Prop` such that

- **irreflexivity at each level:** `∀ n w, ¬ R n w w`;
- **transitivity at each level:** `∀ n w v u, R n w v → R n v u → R n w u`;
- **nesting:** `∀ n w v, R (n+1) w v → R n w v`, i.e. `R(n+1) ⊆ R n`.

These are the Kripke frames for Japaridze's polymodal provability logic GLP, with
`R n` interpreting the `n`-th provability modality `[n]`.

### 5.2 Antitone nesting

**Theorem 5.2 (`R_anti`).** The family is antitone in the index: for all `n ≤ m`,
`R m w v ⟹ R n w v`. (Hence `R m ⊆ R n` whenever `n ≤ m`.)

*Proof.* Induction on `m ≥ n`, peeling one `nesting` step at a time. ∎

### 5.3 Each level is a GL frame

**Definition 5.3 (`level`).** The *`n`-th level* of `G` is the GL frame
`G.level n` with worlds `W`, accessibility `R n`, irreflexivity and transitivity
inherited from level `n`.

This is a reduction, not a fresh soundness proof: every modality of GLP is, on the
frame side, an ordinary GL frame.

**Corollary 5.4 (`glp_level_validates_loeb`).** Every level `G.level n` validates
Löb's axiom (Theorem 3.2 applied to `G.level n`).

**Corollary 5.5 (`glp_level_rank_lt`).** Every level carries the ordinal rank of
Section 4, strictly decreasing along `R n` (Theorem 4.3 applied to `G.level n`).

### 5.4 Monotonicity of boxes in the index

Write `□ₙ` for the box of level `n`, i.e. `□ₙ S = { w | ∀ v, R n w v → v ∈ S }`.

**Theorem 5.6 (`glp_box_mono_in_level`).** For every `S` and every `n`,
`□ₙ S ⊆ □(n+1) S`. More generally, `n ≤ m ⟹ □ₙ S ⊆ □ₘ S`.

*Proof.* If `w ∈ □ₙ S` and `R(n+1) w v`, then `R n w v` by nesting, so `v ∈ S`;
hence `w ∈ □(n+1) S`. The general case uses `R_anti`. ∎

This is the frame-semantic root of the GLP axiom schema `[n]φ → [n+1]φ`: higher
modalities are *logically weaker* because they survey fewer worlds. The polymodal
soundness phenomenon thus decomposes into (a) the single-modal Löb theorem applied
at each level, plus (b) pure nesting bookkeeping — no separate polymodal induction
is required.

---

## 6. The Category of GL Frames (Logic ↔ Category Theory)

### 6.1 The synchronized product

**Definition 6.1 (`prod`).** The *synchronized product* `F × G` of GL frames `F`
and `G` has worlds `W_F × W_G` and accessibility

```
R((w₁,w₂),(v₁,v₂))  :⟺  R_F w₁ v₁  ∧  R_G w₂ v₂.
```

**Theorem 6.2 (closure).** `F × G` is a GL frame: it is irreflexive (a self-loop
would require self-loops in both coordinates) and transitive (componentwise from
transitivity of `R_F` and `R_G`); finiteness is preserved by the product of finite
types.

### 6.2 The diamond factors; the box does not

For sets `A ⊆ W_F`, `B ⊆ W_G`, write the *rectangle* `A × B ⊆ W_F × W_G`.

**Theorem 6.3 (`prod_diamond_rectangle`).** The diamond of a rectangle is the
rectangle of diamonds:

```
◇_{F×G}(A × B) = (◇_F A) × (◇_G B).
```

*Proof.* `(w₁,w₂) ∈ ◇(A × B)` iff there exists `(v₁,v₂)` with `R_F w₁ v₁`,
`R_G w₂ v₂`, `v₁ ∈ A`, `v₂ ∈ B`. Since the existential quantifier distributes over
the conjunction of independent coordinates, this is equivalent to
`(∃ v₁, R_F w₁ v₁ ∧ v₁ ∈ A) ∧ (∃ v₂, R_G w₂ v₂ ∧ v₂ ∈ B)`, i.e.
`w₁ ∈ ◇_F A ∧ w₂ ∈ ◇_G B`. ∎

This exact factorization is the algebraic signature of a categorical product:
consistency of a compound scenario is the conjunction of the consistencies of its
parts.

**Remark 6.4 (the box does not factor).** In general
`□_{F×G}(A × B) ≠ (□_F A) × (□_G B)`. The obstruction is vacuous truth at dead
ends: if `w₁` is maximal in `F` (Proposition 3.4), then `(w₁, w₂)` has no
successor in the product — *whatever* `w₂` is — so `(w₁, w₂) ∈ □(A × B)`
vacuously, even when `w₂ ∉ □_G B`. Universal modalities (the box) are sensitive to
the *absence* of successors, which the product can manufacture in one coordinate;
existential modalities (the diamond) are not. Hence ◇ detects the product
structure, while □ does not — a directional asymmetry in how self-referential
limitation behaves under composition.

---

## 7. Algorithms and Computation

The semantic content of Sections 2–6 is finitely computable on any explicitly
presented frame, which makes the theory directly testable. We summarize the core
procedures (full Python in the accompanying demo).

**Algorithm A (box / diamond evaluation).** Given a frame as an adjacency
structure and a set `S`, compute `□S` and `◇S` by, for each world `w`, scanning its
successors. Complexity `O(|W|²)` per operator in the worst case.

**Algorithm B (ordinal rank).** Compute `rank(w)` for all `w` by memoized
recursion `rank(w) = 0` if `w` is a dead end, else
`1 + max { rank(v) | R w v }`. Because `R` is well-founded the recursion
terminates; with memoization it is `O(|W| + |R|)`.

**Algorithm C (Löb verification).** Given `S`, form `T = (□S)ᶜ ∪ S`, compute `□T`
and `□S`, and check `□T ⊆ □S`. By Theorem 3.2 this always succeeds on a genuine GL
frame; running it on a frame *with* a self-loop produces a counterexample,
exhibiting irreflexivity as load-bearing.

**Algorithm D (product diamond check).** Build `F × G`, choose rectangle `A × B`,
and verify `◇(A × B) = ◇A × ◇B` (Theorem 6.3) while exhibiting a witness where
`□(A × B) ≠ □A × □B` (Remark 6.4).

---

## 8. Applications and Connections

- **Foundations of self-reference.** The frames are a faithful, finite,
  fully-checked model of "what a theory can and cannot prove about itself." Löb's
  wall (`□(□φ → φ) → □φ`) and Gödel II (`¬□⊥` true, `□¬□⊥` false) become concrete
  facts about arrows and dead ends.

- **Ordinal analysis.** The rank function is a frame-internal proxy for the
  proof-theoretic ordinal of a consistency level. The polymodal levels provide the
  skeleton on which the GLP-based ordinal notations (Beklemishev's analysis of PA
  via GLP and ε₀) are built.

- **Self-referential computation and verification.** Any system asked to certify
  its own soundness — a proof checker validating its own kernel, a learner bounding
  its own generalization, a reflective interpreter — meets Löb's obstruction; the
  frames map exactly which scenarios such a system can and cannot "see," and the
  product results describe how these blind spots behave when systems are combined.

---

## 9. Discussion

The unifying theme is that **converse well-foundedness — the single defining
feature of a GL frame — is already enough** to (i) validate Löb, (ii) carry an
ordinal rank, and (iii) behave functorially under the polymodal and product
constructions. Two methodological lessons emerged:

1. *Polymodal soundness is inherited.* What might have required a bespoke
   polymodal Löb argument reduces to the single-modal theorem applied level by
   level plus the antitone nesting `R_anti`. Monotonicity of the boxes in the
   index (`glp_box_mono_in_level`) is then immediate.

2. *◇ factors, □ does not.* The product is a categorical product *detected by the
   diamond*, while the box's failure to factor is precisely vacuous truth at
   dead-end worlds. This asymmetry is not a defect of the construction; it is a
   genuine feature of universal versus existential modalities under composition,
   and it pinpoints where the next (categorical-logic) cycle must work.

---

## 10. Future Work

- **Polymodal ordinal assignment.** Equip `GLPFrame` with a cross-level ordinal
  function realizing the GLP/ε₀ analysis of PA, verifying the connection between
  polymodal provability and proof-theoretic ordinals.
- **De Jongh–Sambin fixed points.** Formalize the semantic fixed-point theorem:
  for `φ(p)` modalized in `p`, a unique (up to GL-equivalence) `ψ` with
  `ψ ↔ φ(ψ)`, recovering the Gödel sentence (`φ(p) = ¬□p`) and Henkin sentence
  (`φ(p) = □p`).
- **Tropical / quantitative GL.** Replace forcing by a real-valued proof-cost
  function with a reflection overhead, yielding a "tropical Löb theorem" and a
  quantitative measure of self-referential cost.
- **PAC-Bayesian tangling.** Transport the dichotomy to learning theory: a sound
  learner either has trivial capacity or cannot tightly self-estimate its own
  generalization gap.
- **The category of GL frames.** Develop p-morphisms, prove the synchronized
  product is the categorical product and the disjoint union the coproduct, and show
  tangling is preserved by all categorical operations.

---

## 11. Conclusion

We have given a fully rigorous, machine-verified account of the Kripke semantics of
Gödel–Löb provability logic and extended it along three axes. Semantic Löb is
proved for every finite GL frame; a canonical ordinal rank, strictly decreasing
along accessibility, is extracted from converse well-foundedness; polymodal GLP
frames are introduced with each level a GL frame and the boxes monotone in the
index; and the synchronized product of GL frames is shown to be a GL frame across
which the diamond factors exactly while the box does not. Together these results
turn the abstract self-reference of Gödel and Löb into a sharp, computable, and
formally certified geometry connecting provability logic to ordinal analysis,
proof theory, and category theory.
