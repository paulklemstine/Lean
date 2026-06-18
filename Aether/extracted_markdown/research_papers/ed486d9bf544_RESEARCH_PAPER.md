# The Adaptive Observation Gap: Decision-Tree Indistinguishability and the Invariance of the Information Ceiling

## Abstract

We study the fundamental limits of distinguishing the internal states of a system
through finite collections of Boolean observations. In the *static* model, an
observation system is a fixed family of *n* Boolean predicates, and two states are
*twins* (observationally indistinguishable) when every predicate agrees on them.
A counting argument — the pigeonhole principle on the space of *n*-bit
observation profiles — shows that any static system on more than 2ⁿ states must
admit a twin pair, that the quotient by indistinguishability has at most 2ⁿ
classes, and that 2ⁿ states can in fact be fully separated by *n* suitably chosen
predicates.

We then introduce the *adaptive* model, in which the predicate posed at step *k+1*
may depend on the answers to the first *k* predicates. We formalize an adaptive
system as a binary decision tree of depth *n* and define the *transcript* of a
state as the length-*n* sequence of answers obtained by running the tree on it.
Our central result is that adaptivity provides no additional discriminative
power: the transcript of any depth-*n* tree lives in the space of *n*-bit strings,
of size 2ⁿ, so the static cardinality bound, pigeonhole theorem, and quotient
bound all transplant verbatim — now proved by structural recursion on the tree
rather than by direct product counting. We exhibit an explicit faithful bridge
embedding every static system into an adaptive one with identical transcripts,
realizing the static theory as the history-independent special case. The
overarching theme is an *invariance principle*: the information ceiling 2ⁿ is a
policy-independent invariant, a discrete avatar of Shannon's "one bit per query"
heuristic.

All results stated below are fully formalized and machine-checked. We give
self-contained mathematical statements and proof sketches, the supporting
algorithms with pseudocode, applications, and a program of future directions.

**Keywords:** observation systems, indistinguishability, pigeonhole principle,
decision trees, adaptive queries, information theory, quotient structures,
twin pairs.

---

## 1. Introduction

### 1.1 The distinguishability problem

A recurring question across the sciences is: *how much of a system's internal
state can be reconstructed from external observations?* A clinician infers a
disease from lab tests; a verification engineer infers a fault from output
probes; an experimentalist infers a physical configuration from measurements. In
each case there is a hidden *state space* and a finite battery of *observations*,
each returning a small amount of information, and the question is whether the
observations suffice to pin down the state.

We isolate the combinatorial core of this question. Let α be the (finite) state
space and consider observations that are *Boolean*: each returns one bit. Two
states are **twins** if every observation agrees on them; twins are
indistinguishable from the outside. The **observation gap** is the discrepancy
between the true state and the equivalence class of states sharing its
observational signature.

### 1.2 Static versus adaptive observation

The classical framing fixes all observations in advance: an observation system is
a family of *n* predicates chosen before any answer is seen. This is the *static*
model, governed by a clean pigeonhole bound (Section 2).

Real investigation, however, is *adaptive*: each new question is chosen in light
of prior answers. A physician reads one test before ordering the next; a binary-
search procedure splits on the outcome of each comparison. Intuitively, adaptivity
ought to be strictly more powerful. The contribution of this paper is to make the
adaptive model precise, via decision trees, and to prove that — for the purpose of
*worst-case distinguishing power* — it is exactly as strong as the static model,
neither more nor less (Section 3). The bound 2ⁿ is invariant under the passage
from fixed lists to adaptive policies.

### 1.3 Summary of contributions

1. A formal *static* theory (Section 2): the Observation Pigeonhole Theorem, the
   Quotient Bound, the Sufficiency Boundary, Refinement Monotonicity, and a
   generalization to arbitrary finite observation codomains.
2. A formal *adaptive* theory (Section 3) built on a decision-tree model and the
   transcript abstraction: the Adaptive Cardinality Bound, the Adaptive
   Observation Pigeonhole, and the Adaptive Quotient Bound.
3. An explicit, transcript-preserving **bridge** embedding static systems into
   adaptive ones, exhibiting the static theory as the history-independent special
   case (Section 4).
4. Algorithms realizing the constructive content — profile computation, twin
   detection, decision-tree evaluation, and the binary-encoding separator
   achieving the sufficiency boundary (Section 5).
5. Applications and a program of future directions (Sections 6–7).

---

## 2. The static observation theory

### 2.1 Definitions

**Definition 2.1 (Observation system).** For a type α and *n ∈ ℕ*, a *static
observation system* of width *n* is a family of *n* Boolean predicates,
`pred : Fin n → α → Bool`. We write `ObsSys α n` for the type of such systems.

**Definition 2.2 (Profile).** The *profile* of a state *a* under a system *O* is
the *n*-tuple of its predicate values,
$$\mathrm{profile}_O(a) \;=\; (i \mapsto O.\mathrm{pred}\,i\,a) \;\in\; (\mathrm{Fin}\,n \to \mathrm{Bool}).$$
The codomain `Fin n → Bool` is the set of length-*n* bit strings, of cardinality
2ⁿ.

**Definition 2.3 (Twins).** Two states *a, b* are *twins* under *O*, written
`O.twins a b`, when `profile_O(a) = profile_O(b)`.

**Proposition 2.4 (Twinhood is an equivalence relation).** For every *O*, the
relation `O.twins` is reflexive, symmetric, and transitive. *Proof.* It is the
kernel of the function `profile_O`, and kernels of functions are equivalence
relations: reflexivity is `rfl`, symmetry is `Eq.symm`, transitivity is
`Eq.trans`. ∎

We write `O.setoid` for the induced setoid and `Quotient O.setoid` for the space
of observational equivalence classes.

### 2.2 The pigeonhole theorem

**Theorem 2.5 (Observation Pigeonhole).** *Let α be finite with*
`2^n < |α|`. *Then for every system `O : ObsSys α n` there exist distinct states
`a ≠ b` with `O.twins a b`.*

*Proof sketch.* The profile map `profile_O : α → (Fin n → Bool)` has codomain of
cardinality `|Bool|^n = 2^n`. Since `2^n < |α|`, the map cannot be injective; by
the finite pigeonhole principle (`Fintype.exists_ne_map_eq_of_card_lt`) there
exist `a ≠ b` with equal profiles, i.e. twins. ∎

### 2.3 The quotient bound

**Theorem 2.6 (Quotient Bound).** *For every `O : ObsSys α n` with α finite,*
$$|\,\mathrm{Quotient}\;O.\mathrm{setoid}\,| \;\le\; 2^n.$$

*Proof sketch.* The profile map factors through the quotient: define
$\bar f : \mathrm{Quotient}\,O.\mathrm{setoid} \to (\mathrm{Fin}\,n \to \mathrm{Bool})$
by $\bar f(\llbracket a\rrbracket) = \mathrm{profile}_O(a)$. This is well defined
because twins have equal profiles, and it is injective because equal profiles
*means* twins, so $\bar f(\llbracket a\rrbracket) = \bar f(\llbracket b\rrbracket)$
forces $\llbracket a\rrbracket = \llbracket b\rrbracket$. An injection into a set
of size 2ⁿ bounds the domain: `Fintype.card_le_of_injective`. ∎

### 2.4 The sufficiency boundary

The pigeonhole bound is *tight*: at the boundary `|α| = 2^n`, separation is
achievable.

**Theorem 2.7 (Sufficiency Boundary).** *For every n there is a system*
`O : ObsSys (Fin (2^n)) n` *that separates all elements: `O.twins a b → a = b`.*

*Proof sketch.* Take the *bit-extraction* system `pred i a = testBit (a.val) i`,
which asks whether the *i*-th binary digit of *a* is set. If two elements of
`Fin (2^n)` agree on all bits `i < n`, they agree on all bits whatsoever (higher
bits vanish because both values are below 2ⁿ), hence are equal by
`Nat.eq_of_testBit_eq`. ∎

Theorems 2.5 and 2.7 together pin the *observation complexity* of an *m*-state
type at exactly `⌈log₂ m⌉`: fewer predicates than this force a twin pair, and that
many suffice.

### 2.5 Refinement monotonicity

**Definition 2.8 (Refinement).** A system `O₂ : ObsSys α m` *refines*
`O₁ : ObsSys α n`, written `O₂.refines O₁`, when `O₂`-twins are always `O₁`-twins:
adding observations can only split classes, never merge them.

**Theorem 2.9 (Refinement Surjection).** *If `O₂.refines O₁`, there is a
surjection from `Quotient O₂.setoid` onto `Quotient O₁.setoid`.*

*Proof sketch.* The identity on α descends to a well-defined map of quotients
(well-definedness is exactly the refinement hypothesis), and it is surjective
because every `O₁`-class has a representative whose `O₂`-class maps onto it
(`Quotient.inductionOn'`). ∎

Refinement equips the collection of observation systems on α with the structure of
a partially ordered set whose quotient maps are coherent — the seed of an
"observation lattice" (Section 7).

### 2.6 Arbitrary codomains

**Definition 2.10 (Generalized system).** A *β-valued* observation system
`GenObsSys α β n` replaces Boolean predicates with `pred : Fin n → α → β`, with
profile and twins defined identically.

**Theorem 2.11 (Generalized Pigeonhole).** *If β is finite and*
`|β|^n < |α|`, *then every `O : GenObsSys α β n` admits a twin pair.* The proof is
identical to Theorem 2.5 with `|β|^n` in place of 2ⁿ. This recovers the Boolean
case at `|β| = 2` and quantifies how richer measurement alphabets raise the
ceiling.

---

## 3. The adaptive observation theory

### 3.1 The decision-tree model

The static model fixes its predicates in advance. To allow the *(k+1)*-th
predicate to depend on the first *k* answers, we model an adaptive system as a
binary decision tree.

**Definition 3.1 (Adaptive observation system).** `AdaptiveObs α n` is defined
inductively:
- `nil : AdaptiveObs α 0` — the empty interrogation (depth 0);
- `node p f : AdaptiveObs α (n+1)` — given a predicate `p : α → Bool` and a
  continuation `f : Bool → AdaptiveObs α n`, ask `p`, observe the answer `b`, and
  proceed with the subtree `f b`.

A `node` thus chooses its next subtree *based on the answer received*, which is
exactly the adaptive freedom.

**Definition 3.2 (Transcript).** The *transcript* of a state *a* under a tree *O*
is the length-*n* sequence of answers produced by running *O* on *a*:
$$\mathrm{transcript}(\mathrm{nil},a) = (),\qquad
  \mathrm{transcript}(\mathrm{node}\,p\,f,\,a) = (p\,a)\,::\,\mathrm{transcript}(f(p\,a),\,a).$$
Formally `transcript O a : Fin n → Bool`, built with `Fin.cons`. **The transcript
of a depth-n tree always lies in `Fin n → Bool`**, the same 2ⁿ-element space as a
static profile, regardless of how the tree branches. This single observation is
the engine of the entire section.

**Definition 3.3 (Adaptive twins).** `O.twins a b` holds when
`transcript O a = transcript O b`. As in the static case this is the kernel of the
transcript map, hence an equivalence relation (Proposition 3.4), inducing a setoid
`O.setoid` and quotient `Quotient O.setoid`.

**Proposition 3.4.** For every adaptive tree *O*, `O.twins` is an equivalence
relation. *Proof.* Kernel of `transcript O`; same as Proposition 2.4. ∎

### 3.2 The adaptive cardinality bound and pigeonhole

**Theorem 3.5 (Adaptive Cardinality Bound).** *Let α be finite and let
`O : AdaptiveObs α n`. If the transcript map `transcript O : α → (Fin n → Bool)`
is injective (the tree distinguishes all states), then `|α| ≤ 2^n`.*

*Proof sketch.* An injection into `Fin n → Bool` bounds the domain by the
codomain's cardinality, which is `|Bool|^n = 2^n`
(`Fintype.card_le_of_injective` together with `Fintype.card_pi`). The branching of
the tree is irrelevant: only the *type* of the transcript matters, and that type
has 2ⁿ inhabitants. ∎

**Theorem 3.6 (Adaptive Observation Pigeonhole).** *Let α be finite with
`2^n < |α|`. Then for every `O : AdaptiveObs α n` there exist distinct states
`a ≠ b` that are adaptive twins.*

*Proof sketch.* Contrapositive of Theorem 3.5. If no two distinct states were
twins, the transcript map would be injective, forcing `|α| ≤ 2^n` and
contradicting `2^n < |α|`. Hence a twin pair exists — and it exists for *every*
tree, so adaptivity never escapes the gap. ∎

### 3.3 The adaptive quotient bound

**Theorem 3.7 (Adaptive Quotient Bound).** *For α finite and any
`O : AdaptiveObs α n`,*
$$|\,\mathrm{Quotient}\;O.\mathrm{setoid}\,| \;\le\; 2^n.$$

*Proof sketch.* The transcript map descends to the quotient as
$\bar f(\llbracket a\rrbracket) = \mathrm{transcript}(O,a)$; it is well defined and
injective by the definition of adaptive twins, exactly as in Theorem 2.6. An
injection into the 2ⁿ-element transcript space bounds the number of classes. ∎

The three theorems 3.5–3.7 are the precise adaptive analogues of 2.5–2.6,
established by *structural recursion / the transcript abstraction* rather than
product counting, yet yielding the identical constant 2ⁿ. This is the paper's
central message: **the information ceiling is invariant under adaptivity.**

---

## 4. The bridge: static as the history-independent special case

The two theories are not merely parallel; the static one *embeds* in the adaptive
one with transcripts preserved on the nose.

**Definition 4.1 (Lazy tree from a predicate family).** Given predicates
`p : Fin n → α → Bool`, define `ofPreds p : AdaptiveObs α n` by recursion:
`ofPreds (n=0) = nil`, and `ofPreds (p) = node (p 0) (fun _ => ofPreds (p ∘ succ))`
— ask `p 0`, then, *ignoring* the answer, recurse on the remaining predicates.
This is the decision tree that never branches: every internal answer leads to the
same continuation.

**Theorem 4.2 (Transcript preservation).** *For all `p : Fin n → α → Bool` and all
`a : α`,*
$$\mathrm{transcript}(\mathrm{ofPreds}\,p,\,a) \;=\; (i \mapsto p\,i\,a),$$
*i.e. the adaptive transcript of the lazy tree equals the static profile of the
predicate family.*

*Proof sketch.* Induction on *n*. At `n = 0` both sides are the empty tuple. At
`n+1`, evaluate at index `i` and split with `Fin.cases`: at `i = 0`, both sides
are `p 0 a` (by definition of `Fin.cons` and of `transcript` on a `node`); at
`i = succ j`, the `Fin.cons` head is discarded and the claim is the induction
hypothesis applied to the tail predicate family `p ∘ succ`. ∎

**Corollary 4.3 (Static system embeds adaptively).** Mapping a static system
`O : ObsSys α n` to `ofPreds (O.pred)` yields an adaptive system whose transcripts
*equal* `O`'s profiles, hence whose twins, setoid, and quotient coincide with
`O`'s. Consequently every static theorem of Section 2 is recovered as the
restriction of the corresponding adaptive theorem of Section 3 to lazy trees, and
the *adaptive observation complexity* of any finite type is at most its static
observation complexity. (The reverse inequality follows from Theorem 3.5, so the
two complexities are equal — see Section 7.2.)

This makes the conceptual claim rigorous: **adaptivity is a strictly larger model
that nonetheless shares the exact same fundamental bound, and the static model
lives inside it.**

---

## 5. Algorithms

The theory has constructive content, summarized by four algorithms (full
pseudocode and code in the accompanying package).

### 5.1 Profile computation and twin detection (static)

Given predicates and a state, evaluate all *n* predicates to produce the profile;
two states are twins iff their profiles are equal. Detecting *some* twin pair over
*m* states is an O(*m*·*n*) scan: hash each profile and report the first
collision; a collision is *guaranteed* once *m > 2ⁿ* by Theorem 2.5.

### 5.2 Decision-tree evaluation (adaptive)

Represent a depth-*n* tree as nested nodes carrying a predicate and a pair of
subtrees. To compute a transcript, descend from the root: evaluate the current
predicate on the state, append the bit, and recurse into the subtree selected by
that bit, halting at depth *n*. This runs in O(*n*) predicate evaluations per
state and produces an *n*-bit transcript, directly witnessing the
"transcript ∈ {0,1}ⁿ" invariant.

### 5.3 Binary-encoding separator (sufficiency)

To realize Theorem 2.7 on `Fin (2^n)`, use predicate *i* = "bit *i* of the state
is set." The resulting profiles are exactly the *n*-bit binary representations,
which are pairwise distinct, so all 2ⁿ states are separated. This is the optimal
static separator and the constructive witness that the pigeonhole bound is sharp.

### 5.4 Balanced separating tree (adaptive sufficiency)

The lazy tree built from the bit-extraction predicates (Definition 4.1, Theorem
4.2) separates all 2ⁿ states adaptively, demonstrating the boundary case for the
adaptive model and the bridge of Section 4 simultaneously.

---

## 6. Applications

**Diagnosis and testing.** A panel of *n* binary tests can resolve at most 2ⁿ
conditions, and Theorem 3.6 shows that ordering the tests adaptively — read one,
decide the next — cannot raise this ceiling. Indistinguishable conditions require
*new* tests, not smarter scheduling.

**Hardware/software verification.** Internal states vastly outnumber observable
outputs; whenever the state count exceeds 2ⁿ for *n* probes, some genuinely
distinct (e.g. faulty vs. correct) states are forced to be twins, escaping any
probe schedule. The theory quantifies the probe budget below which detection is
provably impossible.

**Sensing.** *n* binary sensors resolve at most 2ⁿ situations whether they fire
simultaneously (static) or in a reactive cascade (adaptive); resolution scales
only with sensor count.

**Foundations of measurement.** The observation gap formalizes a basic epistemic
limit: states agreeing on every available observation are externally identical.
The invariance of 2ⁿ under adaptivity is a discrete conservation-of-information
law.

---

## 7. Discussion and future directions

The decisive structural move of this work is recognizing that the *transcript* of
answers, even under adaptive querying, still lives in `Fin n → Bool`, so the
recursive decision tree collapses to the same 2ⁿ counting bound — proved by
structural recursion rather than direct product counting. The static theory
re-enters as the history-independent special case through the lazy-tree bridge.
The following conjectures push the same "one bit per query, no matter how cleverly
asked" principle further.

### 7.1 Tight adaptive sufficiency on every tree shape

We proved that on `Fin (2^n)` *some* adaptive system separates all elements. The
sharper statement is structural: an adaptive system `O` separates all states *iff*
its transcript map hits exactly `|α|` distinct leaves, achievable iff α injects
into the set of length-*n* bitstrings reachable under the tree's prefix shape.
Concretely, define the reachable-leaf finset `leaves O ⊆ (Fin n → Bool)` and prove
`|α| ≤ |leaves O| ≤ 2^n` with both bounds tight. Adaptivity reshapes *which* 2ⁿ
leaves are reachable but never their number, so separation is pure injectivity-
into-leaves, independent of policy.

### 7.2 Adaptivity gives no speed-up: the worst-case query lower bound

Define `adaptiveComplexity α` as the least *n* admitting a separating
`AdaptiveObs α n`, and `staticComplexity α` analogously. Conjecture: for every
finite α, `adaptiveComplexity α = staticComplexity α = ⌈log₂ |α|⌉`. The bridge
gives `adaptiveComplexity ≤ staticComplexity`; the reverse follows from the
Adaptive Cardinality Bound (`2^n ≥ |α| ⇒ n ≥ ⌈log₂ |α|⌉`), leaving only a matching
balanced-tree construction.

### 7.3 Average-case twin abundance

The pigeonhole theorem is worst-case. Conjecture: for any system, a uniformly
random ordered pair of states is observationally indistinguishable with
probability at least `1 − 2ⁿ/|α|`, and the expected number of distinguishing
predicates is at most `n·(1 − 1/|α|)`. In a type with `|α| ≫ 2ⁿ`, *most* pairs are
twins, not just one — a quantitative strengthening accessible via Finset counting
and probability machinery.

### 7.4 Continuous and topological observation

Replace Boolean predicates with continuous real-valued observations on a compact
Hausdorff space. The pigeonhole analogue becomes: *n* continuous functions cannot
injectively map a space of covering dimension exceeding *n* into ℝⁿ — a topological
(invariance-of-domain / Borsuk–Ulam) phenomenon. The algebraic skeleton — quotient
by observational equivalence — is identical; only the cardinality argument is
replaced by a dimension argument.

### 7.5 Observation algebras and Stone-type duality

The refinement order (Theorem 2.9) makes observation systems a lattice;
conjecturally it is isomorphic to the partition lattice of α, with a kernel map
realizing a Stone-type duality between observable properties and quotient
structures.

### 7.6 Observation complexity and computability

For infinite computable types, no finite observation system separates all states;
the observation complexity is infinite. For *decidable* equivalence relations on
ℕ, the minimum number of decidable predicates separating all classes should relate
to the Turing degree of the relation, bridging the finite combinatorial theory to
computability and, potentially, to incompleteness phenomena: some states are
indistinguishable by any *computable* observation system.

---

## 8. Conclusion

We have given a complete, machine-checked account of the observation gap in both
the static and adaptive regimes. The static pigeonhole, quotient, and sufficiency
results pin the discriminative power of *n* Boolean observations at exactly 2ⁿ. The
adaptive theory, built on decision trees and the transcript abstraction, reproves
each bound with an identical constant, and the lazy-tree bridge embeds the static
theory as the no-branching special case. The unifying lesson is an *invariance
principle*: the information ceiling 2ⁿ is independent of whether observations are
fixed in advance or chosen adaptively. Cleverness in *ordering* questions can save
effort on typical inputs, but it cannot raise the worst-case number of states that
*n* yes/no questions can ever distinguish. Counting, in the end, is destiny.
