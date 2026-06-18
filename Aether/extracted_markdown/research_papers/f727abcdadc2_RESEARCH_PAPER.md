# A Functor from Neural Observation Pseudometrics to Proof-Spectrum Congruence Kernels

## Abstract

We construct an explicit bridge between two structures that arise independently
in the semantics of neural architectures and in the algebraic geometry of proof
systems. On the one side, a *neural observation system* is a deterministic state
machine `(step, observe)` whose behavioral (Myhill–Nerode) equivalence collapses
internal states that no input word can distinguish; quotienting by it yields the
canonical minimal realization, i.e. certified compression. On the other side, a
*semiring congruence* is the basic datum of proof-theoretic algebraic geometry,
whose prime instances are the points of a proof spectrum. We isolate the minimal
hypothesis under which these worlds meet: an **algebraic neural observation
system**, whose state and output spaces are semirings and whose layers and
read-out are semiring maps preserving `0`, `+`, and `·` (but *not* the
multiplicative unit). Under this hypothesis we prove that the behavior map
`x ↦ (w ↦ behavior(x, w))` is a semiring homomorphism in its state argument,
that behavioral equivalence is therefore a genuine **semiring congruence**
`behaviorCongruence`, and that the assignment `N ↦ behaviorCongruence(N)` is
**functorial** along intertwining morphisms of algebraic neural systems. We
realize the same kernel analytically as the zero-set of an **observation
pseudometric** `obsDist`, prove `obsDist` is a pseudometric, and prove the
keystone identity `pseudometric_kernel_eq_congruence`: the metric kernel equals
the semiring congruence. We further identify the kernel with the intersection of
the depth-`k` partition-refinement filtration, giving a computable handle. All
results have been formally verified.

**Keywords.** behavioral equivalence, Myhill–Nerode, coalgebra, semiring
congruence, proof spectrum, pseudometric, certified compression, functoriality,
partition refinement, weighted automata.

---

## 1. Introduction

Two classical impulses meet in this paper.

The first is the **Myhill–Nerode** impulse: understand a state machine through
the equivalence that identifies states no observation can separate, and study the
quotient as the canonical minimal realization. In the neural setting this models
*certified compression* — discarding redundant internal degrees of freedom while
preserving every observable output. In its weighted form, with outputs in a
semiring, it specializes the theory of weighted automata minimization.

The second is the **proof-spectrum** impulse: treat a proof or computation system
as a semiring (disjunction as `+`, conjunction as `·`), and develop an algebraic
geometry of its **congruences** in analogy with the Zariski geometry of ideals.
The prime congruences are geometric points; their zero-classes are vanishing
loci; a Galois connection links systems of equations to the loci on which they
hold.

The contribution of this paper is to make these two impulses literally the same
object under a minimal hypothesis. We show that behavioral equivalence of an
*algebraic* neural observation system is not merely an equivalence relation but a
**semiring congruence**, i.e. a point datum of the proof-spectrum world; that the
assignment is **functorial**; and that the congruence is simultaneously the
zero-set of an **observation pseudometric** and the limit of the depth filtration
used by partition refinement.

### Contributions

1. **Algebraic neural observation systems** (Definition 3.1): the minimal
   semiring-compatible structure on a neural observation system.
2. **Homomorphism property** (Theorems 4.1–4.5): the behavior map is a semiring
   homomorphism in its state argument.
3. **The behavior congruence** (Definition 5.1, Theorem 5.2): behavioral
   equivalence as an object `behaviorCongruence : SRCong R`, agreeing with the
   weighted Myhill–Nerode equivalence.
4. **Zero-class and filtration** (Theorems 5.4–5.5): the congruence's zero-class
   is the set of behaviorally-null states, and the congruence is the intersection
   of the depth filtration.
5. **Functoriality** (Theorems 6.1–6.2): intertwining morphisms push the
   congruence forward.
6. **The observation pseudometric and the keystone** (Definition 7.1, Theorems
   7.2–7.6): `obsDist` is a pseudometric, and its kernel equals
   `behaviorCongruence`.

---

## 2. Preliminaries

Throughout, a **semiring** is a set with `0, 1, +, ·` where `(+, 0)` is a
commutative monoid, `(·, 1)` is a monoid, multiplication distributes over
addition, and `0` annihilates. `α` denotes a fixed input alphabet, and a **word**
is a finite list `w ∈ List α`. For a step function `step : R → α → R` and a state
`x`, `w.foldl step x` denotes the left fold of `w` over `step` starting at `x`
(process the symbols of `w` left to right).

### 2.1 Neural observation systems (the coalgebraic side)

**Definition 2.1 (Neural observation system).** A *neural observation system*
over state space `σ`, alphabet `α`, output `β` is a pair `N = (step, observe)`
with `step : σ → α → σ` and `observe : σ → β`. Its **behavior** is
```
behavior(N, x, w) = observe(w.foldl step x).
```
States `s, t` are **behaviorally equivalent**, written `s ≈ t`, iff
`behavior(N, s, w) = behavior(N, t, w)` for all `w`. The **depth-`k`
approximation** `s ≈ₖ t` requires agreement only for `|w| ≤ k`.

Two structural identities hold by definition of `foldl`: behavior on the empty
word is the read-out, `behavior(N, x, []) = observe(x)`; and prepending a symbol
is a one-step derivative, `behavior(N, step(x, a), w) = behavior(N, x, a :: w)`.
The relation `≈` is an equivalence relation; `≈` is a right congruence for the
dynamics (`s ≈ t ⟹ step(s,a) ≈ step(t,a)`); and `≈` is the intersection of the
`≈ₖ`, which form a refinement filtration `≈_{k+1} ⊆ ≈_k`.

**Definition 2.2 (Weighted system).** A *weighted neural observation system*
`N = (step, observe)` has output in a semiring `K`: `observe : σ → K`. Its
behavior `weighted_behavior(N, x, w) = observe(w.foldl step x)` and equivalence
`weighted_equiv` are the specializations of Definition 2.1; indeed
`weighted_equiv(N) = ≈` for the underlying system `weighted_to_neural(N)`.

### 2.2 Semiring congruences (the proof-spectrum side)

**Definition 2.3 (Semiring congruence).** A *semiring congruence* on a semiring
`R` is a relation `rel : R → R → Prop` that is reflexive, symmetric, transitive,
and **compatible** with the operations:
```
rel a b → rel c d → rel (a + c) (b + d),
rel a b → rel c d → rel (a · c) (b · d).
```
We write `SRCong R` for the type of such congruences. Two derived facts we use:
left/right scaling preserve `rel` (`rel a b → rel (f·a) (f·b)` and `rel a b →
rel (a·f) (b·f)`), via compatibility with reflexivity.

**Definition 2.4 (Zero-class).** The *zero-class* of `C : SRCong R` is
`zeroClass(C) = { a : C.rel a 0 }`. It contains `0`, is closed under addition,
and absorbs multiplication (if `a ∈ zeroClass(C)` then `a·b ∈ zeroClass(C)`).
A congruence is **prime** when `a·b ∈ zeroClass ⟹ a ∈ zeroClass ∨ b ∈
zeroClass`; primes are the points of the **proof spectrum**. (Primality is not
required for the present bridge; see §8.)

---

## 3. Algebraic neural observation systems

We seek the weakest structure making the behavior map a semiring homomorphism in
its state argument.

**Definition 3.1 (Algebraic neural observation system).** Let `R` and `K` be
semirings. An *algebraic neural observation system* `N : AlgNeuralSystem R K α`
consists of `step : R → α → R` and `observe : R → K` satisfying the six laws
```
(S0) step(0, a) = 0,
(S+) step(x + y, a) = step(x, a) + step(y, a),
(S·) step(x · y, a) = step(x, a) · step(y, a),
(O0) observe(0) = 0,
(O+) observe(x + y) = observe(x) + observe(y),
(O·) observe(x · y) = observe(x) · observe(y),
```
for all `a : α`, `x, y : R`.

**Remark 3.2 (Minimality).** We deliberately omit preservation of the
multiplicative unit (`step(1,a) = 1` and `observe(1) = 1`). Behavioral
equivalence never inspects the multiplicative unit of the *state* space — only
sums and products of states enter — so a unit-preservation hypothesis would be
unused, and is false in many natural models (e.g. truncating or projecting
layers). Every congruence axiom below goes through with exactly the six laws of
Definition 3.1, confirming their sufficiency.

Each algebraic system has an underlying weighted system `toWeighted(N) =
(step, observe)`, and we set
```
algBehavior(N, x, w) = weighted_behavior(toWeighted(N), x, w) = observe(w.foldl step x).
```

---

## 4. The behavior map is a semiring homomorphism

We first lift the layer laws from a single step to whole words.

**Theorem 4.1 (Fold preserves zero).** `w.foldl step 0 = 0` for all `w`.

*Proof sketch.* Induction on `w`. Base: `[].foldl step 0 = 0`. Step: by `(S0)`
each layer maps `0` to `0`, so the fold never leaves `0`. ∎

**Theorem 4.2 (Fold is additive).** `w.foldl step (x + y) = w.foldl step x +
w.foldl step y`.

*Proof sketch.* Induction on `w` from the right (`reverseRecOn`): the inductive
hypothesis handles the prefix, and the final layer is additive by `(S+)`,
`step(u + v, a) = step(u, a) + step(v, a)`. ∎

**Theorem 4.3 (Fold is multiplicative).** `w.foldl step (x · y) = w.foldl step x
· w.foldl step y`.

*Proof sketch.* Identical to Theorem 4.2 with `(S·)` in place of `(S+)`. ∎

Composing with the read-out laws `(O0), (O+), (O·)` yields the homomorphism
property of the behavior map.

**Theorem 4.4 (Behavior of zero).** `algBehavior(N, 0, w) = 0`.

*Proof sketch.* `observe(w.foldl step 0) = observe(0) = 0` by Theorem 4.1 and
`(O0)`. ∎

**Theorem 4.5 (Behavior is a homomorphism in the state).** For all `x, y, w`,
```
algBehavior(N, x + y, w) = algBehavior(N, x, w) + algBehavior(N, y, w),
algBehavior(N, x · y, w) = algBehavior(N, x, w) · algBehavior(N, y, w).
```

*Proof sketch.* Apply the read-out to Theorems 4.2/4.3 and use `(O+)`/`(O·)`:
`observe(w.foldl step (x + y)) = observe(w.foldl step x + w.foldl step y) =
observe(w.foldl step x) + observe(w.foldl step y)`, and likewise for products. ∎

Thus, for each fixed word `w`, `x ↦ algBehavior(N, x, w)` is a homomorphism of
the additive monoid and of the multiplicative semigroup, sending `0` to `0`.
Equivalently, the **behavioral image map** `B : R → (List α → K)`, `B(x) =
(w ↦ algBehavior(N, x, w))`, is a semiring homomorphism into the pointwise
semiring `List α → K`.

---

## 5. The behavior congruence

**Definition 5.1 (Behavior relation and congruence).** The *behavior relation* of
an algebraic neural system is
```
behaviorRel(N, x, y)  :⟺  ∀ w, algBehavior(N, x, w) = algBehavior(N, y, w),
```
i.e. `B(x) = B(y)`. We package it as `behaviorCongruence(N) : SRCong R`.

**Theorem 5.2 (`behaviorCongruence` is a congruence).** `behaviorRel(N)` is a
semiring congruence: it is reflexive, symmetric, transitive, and compatible with
`+` and `·`.

*Proof sketch.* Reflexivity, symmetry, transitivity are pointwise consequences of
the same properties of equality in `K`. For additive compatibility, assume
`behaviorRel(N, a, b)` and `behaviorRel(N, c, d)`; for each `w`, Theorem 4.5
gives `algBehavior(N, a+c, w) = algBehavior(N, a, w) + algBehavior(N, c, w) =
algBehavior(N, b, w) + algBehavior(N, d, w) = algBehavior(N, b+d, w)`, so
`behaviorRel(N, a+c, b+d)`. Multiplicative compatibility is identical using the
product clause of Theorem 4.5. ∎

This is the central bridge: behavioral equivalence of an algebraic neural system
*is* a point datum `SRCong R` of the proof-spectrum world.

**Theorem 5.3 (Agreement with the catalog equivalence).**
`behaviorCongruence(N).rel x y ↔ weighted_equiv(toWeighted(N), x y)`.

*Proof sketch.* Both unfold to `∀ w, observe(w.foldl step x) = observe(w.foldl
step y)`; the equivalence is definitional. ∎

**Theorem 5.4 (Zero-class = behaviorally-null states).**
```
zeroClass(behaviorCongruence(N)) = { x : ∀ w, algBehavior(N, x, w) = 0 }.
```

*Proof sketch.* `x ∈ zeroClass` means `behaviorRel(N, x, 0)`, i.e.
`∀ w, algBehavior(N, x, w) = algBehavior(N, 0, w)`; by Theorem 4.4 the right side
is `0`. ∎

So the vanishing locus of the proof-spectrum congruence is exactly the set of
internal states the network can never render visibly nonzero — a clean
machine-learning meaning for an algebraic-geometry object.

**Theorem 5.5 (Kernel = intersection of the depth filtration).** Writing
`M = weighted_to_neural(toWeighted(N))`,
```
behaviorCongruence(N).rel x y  ↔  ∀ k, neural_equiv_upto(M, k, x, y).
```

*Proof sketch.* `(⟸)` Given equivalence at every depth, fix any `w`; choose
`k = |w|`; then `≈ₖ` applied to `w` gives the desired equality. `(⟹)` Behavioral
equivalence implies agreement on all words, in particular those of length `≤ k`
for every `k`. This is precisely the finite-depth stabilization theorem of the
underlying coalgebraic theory. ∎

Because each `≈ₖ` is decidable with an `O(|α|ᵏ)` observation budget and the
filtration is monotone (`≈_{k+1} ⊆ ≈_k`), Theorem 5.5 turns the abstract
congruence into a computable partition-refinement target.

---

## 6. Functoriality

A **morphism of algebraic neural systems** `f : N → N'` (with state spaces `R`,
`R'`) is a state map `f : R → R'` that intertwines the dynamics and read-outs:
`f(step(x, a)) = step'(f(x), a)` and `observe(x) = observe'(f(x))` (so that the
output is read identically before and after `f`).

**Theorem 6.1 (Behavior transports along morphisms).** For every morphism
`f : N → N'`,
```
algBehavior(N, x, w) = algBehavior(N', f(x), w)   for all x, w.
```

*Proof sketch.* Induction on `w` shows `f(w.foldl step x) = w.foldl step'
(f(x))` using `map_step` at each layer; applying `map_observe` to the result
equates the read-outs. ∎

**Theorem 6.2 (Functoriality / push-forward of the congruence).** If `f : N →
N'` and `f(x) = f(y)`, then `behaviorCongruence(N).rel x y`. More generally, the
assignment `N ↦ behaviorCongruence(N)` is functorial: a morphism `f` carries the
congruence of `N` forward, and behaviorally equivalent states remain equivalent.

*Proof sketch.* From Theorem 6.1, `algBehavior(N, x, w) = algBehavior(N', f(x),
w) = algBehavior(N', f(y), w) = algBehavior(N, y, w)` for all `w`, which is
exactly `behaviorRel(N, x, y)`. Identities and composites of morphisms preserve
behavior (Theorem 6.1 is compositional), giving functoriality. ∎

Interpretation: any semantics-preserving architecture transformation — a faithful
compression, a refactoring, a re-implementation — acts predictably on the
proof-spectrum point attached to the network. Certified compression is precisely
a morphism whose induced map on congruences is the quotient projection.

---

## 7. The observation pseudometric and the keystone

We now realize the same kernel analytically.

**Definition 7.1 (Observation pseudometric).** Define `obsDist(N, ·, ·) : R → R →
ℝ` by
```
obsDist(N, x, y) = 0   if behaviorRel(N, x, y),
obsDist(N, x, y) = 1   otherwise.
```
This is the discrete pseudometric induced by the behavior relation.

**Theorem 7.2 (Non-negativity).** `0 ≤ obsDist(N, x, y)`.

**Theorem 7.3 (Self-distance zero).** `obsDist(N, x, x) = 0`.

*Proof sketch.* `behaviorRel(N, x, x)` holds by reflexivity, so the first branch
applies. ∎

**Theorem 7.4 (Symmetry).** `obsDist(N, x, y) = obsDist(N, y, x)`.

*Proof sketch.* `behaviorRel` is symmetric (Theorem 5.2), so the two
case-splits select the same branch and the same value. ∎

**Theorem 7.5 (Triangle inequality).** `obsDist(N, x, z) ≤ obsDist(N, x, y) +
obsDist(N, y, z)`.

*Proof sketch.* If both right-hand terms are `1` the bound is `≤ 2`, trivial. If
either is `0`, the corresponding pair is behaviorally equal, so by transitivity
(Theorem 5.2) `behaviorRel(N, x, z)` reduces to the other pair; then
`obsDist(N, x, z)` equals the nonzero summand and the inequality is an equality
(or `0 ≤ 0`). In all cases the discrete distance obeys the triangle law. ∎

Theorems 7.2–7.5 establish that `obsDist` is a genuine **pseudometric**: it may
assign distance `0` to distinct states (those that are behaviorally identical),
which is exactly the intended degeneracy.

**Theorem 7.6 (Keystone: metric kernel = semiring congruence).**
```
{ (x, y) : obsDist(N, x, y) = 0 } = { (x, y) : behaviorCongruence(N).rel x y }.
```

*Proof sketch.* By Definition 7.1, `obsDist(N, x, y) = 0` holds in exactly the
branch where `behaviorRel(N, x, y)` holds (the value `1` is nonzero), and
`behaviorRel(N) = behaviorCongruence(N).rel` by Definition 5.1. ∎

Consequently the **analytic quotient** (collapse all pairs at distance zero) and
the **algebraic quotient** (quotient by the congruence) coincide, and both agree
with the coalgebraic Myhill–Nerode quotient. The diagram

```
neural observation pseudometric  ⟶  congruence kernel  ⟶  proof-spectrum congruence
```

commutes, with each arrow an identity of relations.

---

## 8. Discussion

**Why the unit may be dropped.** The minimality remark (3.2) is not a technical
convenience but a structural fact: behavioral equivalence is testable by sums and
products of states alone, so the multiplicative unit of the state semiring is
invisible to it. Dropping `1`-preservation widens the class of admissible
architectures (projections, truncations, weighting layers) without losing a
single congruence axiom.

**Three quotients, one object.** The paper's payoff is that an equivalence
defined coalgebraically (no word separates the states), an equivalence defined
metrically (distance zero), and an equivalence defined algebraically (a semiring
congruence) are literally equal. Each viewpoint donates tools: coalgebra donates
the depth filtration and a finite stabilization/partition-refinement algorithm;
metric geometry donates a topology and the language of completion; universal
algebra and proof-spectrum geometry donate primality, radicals, zero-classes,
and the Zariski-style Galois connection.

**Primality is a genuine restriction.** `behaviorCongruence(N)` need not be
*prime* even when `K` is an integral domain: `∀ w, algBehavior(N, x·y, w) = 0`
only yields, for each `w`, that one of `algBehavior(N, x, w)`,
`algBehavior(N, y, w)` vanishes — a *pointwise* disjunction that need not be
uniform in `w`. Primality is recovered exactly when the behavioral image `B(R)`
is an integral domain under pointwise operations (Conjecture 1 in §9).

**Relation to weighted automata.** When `R = K` and the layers are linear, an
algebraic neural system is a weighted automaton, and `behaviorCongruence` is its
minimization equivalence. The bridge thus reinterprets classical weighted-
automaton minimization as the computation of a proof-spectrum congruence.

---

## 9. Future directions

**Conjecture 1 (Primality criterion).** Let `K` be an integral domain. Then
`behaviorCongruence(N)` lifts to a prime congruence `PrimeSRCong R` iff the
behavioral image `B(R) = { w ↦ algBehavior(N, x, w) : x ∈ R }` is an integral
domain under pointwise operations — equivalently, iff for all `x, y`,
`(∀ w, algBehavior(N, x, w) · algBehavior(N, y, w) = 0)` implies
`(∀ w, algBehavior(N, x, w) = 0) ∨ (∀ w, algBehavior(N, y, w) = 0)`. A 2-state
counterexample over `K = ℤ` should establish necessity.

**Conjecture 2 (Graded ultrametric).** Replace the discrete `obsDist` with the
convergent series
```
ugobsDist(N, x, y) = Σ_{k≥0} 2^{-(k+1)} · [ x ≉ₖ y ],
```
(`[P] = 1` if `P`, else `0`). Conjecturally `ugobsDist` is an ultrametric
(`ugobsDist(x, z) ≤ max(ugobsDist(x, y), ugobsDist(y, z))`), topologically
equivalent to `obsDist` on behaviorally-finite systems, with kernel identity
`ugobsDist(N, x, y) = 0 ↔ behaviorCongruence(N).rel x y`. The ultrametric
inequality reduces to filtration monotonicity `≈_{k+1} ⊆ ≈_k`.

**Conjecture 3 (Fullness / essential surjectivity).** Functoriality is one-way so
far (morphisms push congruences forward). Conjecturally, for every finitely
generated semiring congruence `C : SRCong R` there is an algebraic neural system
`N` over a suitable output semiring `K` (e.g. `K = R` with an evaluation read-out)
whose behavior congruence is `C` — i.e. every congruence arises from a network.

---

## 10. Conclusion

We built a precise, formally verified bridge: under a minimal six-law algebraic
hypothesis, the behavioral equivalence of a neural observation system is a
semiring congruence — a point datum in the algebraic geometry of proofs — and the
assignment is functorial. The same congruence is the zero-set of an observation
pseudometric and the intersection of a computable depth filtration. The analytic,
algebraic, and coalgebraic quotients coincide. In one sentence: *the way a machine
sees and the way a proof adds up are, under the right hypothesis, the same
shape.*
