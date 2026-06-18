# Path Spaces, h-Levels, and Contractibility as a Universal Property

## Abstract

We develop the structural core of a synthetic theory of contractibility and equivalence and weld it to classical point-set topology. Working inside a classical type theory, we define the homotopy-theoretic h-levels of contractibility (`IsContr`) and mere-propositionality (`IsMereProp`) and the homotopy fiber `HFiber` of a function. We prove four interlocking groups of results. **(1) Path spaces.** The based path space `{ b // a = b }` is contractible — the synthetic content of path induction. **(2) Closure of the h-level hierarchy.** Contractibility is closed under dependent sums (Σ), dependent products (Π), and retracts, and decomposes as `IsContr A ↔ Nonempty A ∧ IsMereProp A`. **(3) The fibrewise characterisation of equivalences.** A function is a bijection if and only if every homotopy fiber is contractible. Promoting this biconditional to a first-class predicate `IsEquiv f := ∀ b, IsContr (HFiber f b)` yields a complete *equivalence calculus*: reflexivity, closure under composition, stability under homotopy, the full 2-out-of-3 law, transport of h-levels, and *univalence-lite* transport of algebraic structure along abstract equivalences. **(4) The universal property of contractibility.** Via the classical bridge — every continuous map into a contractible space is null-homotopic — we prove that for contractible `Y` the set of homotopy classes `[X, Y]` is itself contractible for every `X`; that is, **a contractible space is a terminal object of the homotopy category**. All results are fully formalised with no remaining gaps, relying only on the standard foundational axioms (propositional extensionality, the axiom of choice, and quotient soundness). The unifying theme is a precise *duality*: an equivalence is represented by the contractibility of its fibers (a homotopy-spectral datum), exactly dual to the algebraic datum of bijectivity; and contractibility of a *space* is dual to contractibility of the *type* of maps into it.

**Keywords:** homotopy type theory, contractibility, h-levels, path spaces, homotopy fiber, equivalence, 2-out-of-3, terminal object, homotopy category, structure identity principle.

---

## 1. Introduction

Homotopy type theory (HoTT) reinterprets the constructs of dependent type theory through the lens of homotopy theory: types are spaces, terms are points, and the identity type `a = b` is the space of paths from `a` to `b`. Within this dictionary, the most elementary nontrivial object — the *contractible* type, with a single point up to coherent homotopy — plays an outsized organizational role. Contractibility is simultaneously:

- the base case (h-level −2) of the entire hierarchy of homotopical complexity;
- the local certificate of an equivalence (a map is an equivalence iff its fibers are contractible);
- the universal property of a terminal object in the homotopy category.

This paper formalises these three roles and their interconnections, and bridges the synthetic picture to classical topology. We treat two notions of contractibility — a *type* being `IsContr` and a topological *space* being `ContractibleSpace` — and show they are dual faces meeting at the type of homotopy classes `[X, Y]`.

We work in Lean 4's classical type theory (the ambient logic of the Mathlib library), so identity types of propositions are proof-irrelevant. A consequence worth flagging at the outset: in a proof-irrelevant setting the h-set predicate `IsHSet` (h-level 0) is *automatically* satisfied by every type, since any two equality proofs are equal. The only homotopically substantive h-levels are therefore −2 (contractible) and −1 (mere proposition). All the geometric content of "path spaces" consequently lives in `IsContr` of based path spaces and in the fibrewise picture, and that is where we concentrate.

---

## 2. Definitions

Throughout, `A`, `B`, `X`, `Y` denote types; topological structure is added where stated.

**Definition 2.1 (Contractibility, h-level −2).**
A type `A` is *contractible* if it has a center to which every element is equal:
```
IsContr A  :=  ∃ c : A, ∀ a : A, a = c.
```

**Definition 2.2 (Mere proposition, h-level −1).**
A type `A` is a *mere proposition* if any two of its elements are equal:
```
IsMereProp A  :=  ∀ a b : A, a = b.
```

**Definition 2.3 (h-set, h-level 0).**
`IsHSet A := ∀ (a b : A) (p q : a = b), p = q`. In a proof-irrelevant metatheory this holds for all `A` (Remark 2.7).

**Definition 2.4 (Homotopy fiber).**
For `f : A → B` and `b : B`, the *homotopy fiber* of `f` over `b` is the subtype
```
HFiber f b  :=  { a : A // f a = b }.
```

**Definition 2.5 (Based path space).**
For `a : A`, the *based path space out of `a`* is the subtype `{ b : A // a = b }`: destinations paired with a proof of reachability from `a`.

**Definition 2.6 (Equivalence, fibrewise).**
A function `f : A → B` is an *equivalence* if all its homotopy fibers are contractible:
```
IsEquiv f  :=  ∀ b : B, IsContr (HFiber f b).
```

**Remark 2.7.** Because the metatheory is proof-irrelevant on `Prop`, `IsMereProp A → IsHSet A` holds for all `A`, and indeed `IsHSet A` holds unconditionally. This collapses the hierarchy above level −1, justifying our focus on `IsContr` and `IsMereProp`.

We will also use Mathlib's classical notions: `ContractibleSpace Y` (a topological space deformation-retracting to a point), `C(X, Y)` (the type of continuous maps), `ContinuousMap.Homotopic f g` (homotopy of continuous maps), and `ContinuousMap.Nullhomotopic f` (homotopy to a constant).

---

## 3. Contractibility of path spaces

**Theorem 3.1 (Contractibility of singletons / path induction).**
For every `a : A`, the based path space `{ b : A // a = b }` is contractible.

*Proof sketch.* Take the center to be `⟨a, rfl⟩`, where `rfl` is the trivial proof `a = a`. For an arbitrary element `⟨b, p⟩` with `p : a = b`, pattern-match on `p` (path induction): the only constructor of identity reduces `b` to `a` and `p` to `rfl`, whereupon `⟨b, p⟩` is literally the center. Hence every element equals `⟨a, rfl⟩`. ∎

This is the synthetic incarnation of the elimination rule for identity types ("the J rule"): proving a statement for all paths out of `a` reduces to the constant-path case precisely because the space of such paths is contractible. It is the geometric seed from which the rest of the theory grows.

**Theorem 3.2 (Contractibility passes to retracts).**
Let `r : A → B` and `s : B → A` satisfy `r (s b) = b` for all `b` (so `B` is a retract of `A`). If `A` is contractible then so is `B`.

*Proof sketch.* Let `c` be the center of `A` with `a = c` for all `a`. Propose `r c` as the center of `B`. For any `b`, write `b = r (s b)` by the retraction equation, then `r (s b) = r c` by applying `r` to `s b = c`. Hence `b = r c`. ∎

---

## 4. Closure of the h-level hierarchy

**Theorem 4.1 (Σ-closure of contractibility).**
If `A` is contractible and `B a` is contractible for every `a : A`, then the dependent sum `Σ a, B a` is contractible.

*Proof sketch.* Let `c` be the center of `A` and `d` the center of `B c`. Take `⟨c, d⟩` as center. Given `⟨a, x⟩`, contractibility of `A` gives `a = c`; transporting, `x` lives in `B c`, and contractibility there gives `x = d`. The dependent-pair extensionality principle (`Sigma.ext`) glues these into `⟨a, x⟩ = ⟨c, d⟩`. ∎

**Theorem 4.2 (Σ-closure of mere-propositionality).**
If `A` is a mere proposition and each `B a` is a mere proposition, then `Σ a, B a` is a mere proposition.

*Proof sketch.* Given `⟨a, x⟩` and `⟨a', x'⟩`, mere-propositionality of `A` yields `a = a'`; after aligning the bases, mere-propositionality of the fiber yields the second components equal. `Sigma.ext` concludes. ∎

**Theorem 4.3 (Π-closure of contractibility).**
If `B a` is contractible for every `a : A`, then the dependent product `∀ a, B a` is contractible.

*Proof sketch.* Choose the center of each fiber pointwise, giving a canonical section `a ↦ center (B a)`. For any `f`, the contraction in each `B a` collapses `f a` onto the chosen center, and function extensionality (`funext`) assembles these pointwise equalities into `f = section`. ∎

**Theorem 4.4 (Existence–uniqueness decomposition).**
For every type `A`,
```
IsContr A  ↔  Nonempty A ∧ IsMereProp A.
```

*Proof sketch.* (⇒) A center `c` makes `A` inhabited; and for any `a, b` we have `a = c = b`, so `A` is a mere proposition. (⇐) A witness `c` of inhabitation is a center because mere-propositionality gives `a = c` for all `a`. ∎

Theorem 4.4 is the conceptual hinge of the paper: it factors the geometric notion "contractible" into the logical atoms "inhabited" (existence) and "mere proposition" (uniqueness). Both subsequent climaxes — the fiber characterisation of equivalences and the terminal universal property — are obtained by establishing these two atoms separately and recombining them through 4.4.

---

## 5. The fibrewise characterisation of equivalences

**Theorem 5.1 (Equivalences = contractible fibers).**
For any `f : A → B`,
```
Function.Bijective f  ↔  ∀ b : B, IsContr (HFiber f b).
```

*Proof sketch.* (⇒) Assume `f` injective and surjective. Fix `b`. Surjectivity yields `a` with `f a = b`, giving a fiber element `⟨a, _⟩` to serve as center. For any other `⟨a', _⟩`, both map to `b`, so injectivity forces `a' = a`; subtype extensionality identifies the two fiber elements. Hence the fiber is contractible.
(⇐) Assume every fiber contractible. For injectivity, suppose `f a = f a'`; both `⟨a, rfl⟩` and `⟨a', _⟩` are elements of the (contractible) fiber over `f a`, so they are equal, whence `a = a'` on first components. For surjectivity, the center of the (inhabited) fiber over `b` provides a preimage of `b`. ∎

Theorem 5.1 upgrades a previously one-directional implication ("contractible fibers ⇒ bijective") to a genuine biconditional, and it is the representation dictionary on which the entire equivalence calculus rests. Note how it is itself an instance of the existence–uniqueness philosophy: surjectivity = fibers inhabited, injectivity = fibers mere-propositional, and 5.1 is essentially Theorem 4.4 applied fiberwise.

### 5.1 The equivalence calculus

Adopting Definition 2.6, `IsEquiv f := ∀ b, IsContr (HFiber f b)`, Theorem 5.1 reads `IsEquiv f ↔ Function.Bijective f`. Every structural law about equivalences then reduces to bijection bookkeeping.

**Theorem 5.2 (Representation dictionary).** `IsEquiv f ↔ Function.Bijective f`; in particular `IsEquiv.bijective` and `IsEquiv.of_bijective` convert between the two views.

**Theorem 5.3 (Groupoid laws).**
- *(Reflexivity)* `IsEquiv (id : A → A)`.
- *(Composition)* If `IsEquiv f` and `IsEquiv g` then `IsEquiv (g ∘ f)`.
- *(Homotopy stability)* If `IsEquiv f` and `g` is pointwise equal to `f` (`∀ a, f a = g a`) then `IsEquiv g`.

*Proof sketch.* Through Theorem 5.2 these become, respectively, bijectivity of the identity, `Function.Bijective.comp`, and invariance of bijectivity under pointwise equality of functions — all immediate. ∎

**Theorem 5.4 (2-out-of-3 law).** For `f : A → B` and `g : B → C`:
- *(Composition leg)* `IsEquiv f` and `IsEquiv g` imply `IsEquiv (g ∘ f)`.
- *(Left-cancellation leg)* `IsEquiv g` and `IsEquiv (g ∘ f)` imply `IsEquiv f`.
- *(Right-cancellation leg)* `IsEquiv f` and `IsEquiv (g ∘ f)` imply `IsEquiv g`.

*Proof sketch.* Translate to `Function.Bijective` via Theorem 5.2. The composition leg is `Bijective.comp`. For left-cancellation, `g` bijective and `g ∘ f` bijective force `f` bijective: `f` is injective because `g ∘ f` is, and `f` is surjective because for any `b`, applying the inverse of `g ∘ f` to `g b` and then `f` recovers a preimage (using injectivity of `g`). Right-cancellation is dual. Crucially, **no extra coherence hypothesis is needed**: in `Type`, an equivalence *is* a bijection, so the set-level law transfers verbatim. ∎

The verbatim validity of 2-out-of-3 (a question explicitly posed in earlier work) is a clean discovery: the fiberwise predicate is not merely *implied by* bijectivity but logically equivalent to it, so the homotopical and set-theoretic calculi coincide on the nose.

**Theorem 5.5 (Transport of h-levels along equivalences).**
If `IsEquiv f : A → B` then `IsContr A ↔ IsContr B` and `IsMereProp A ↔ IsMereProp B` (`isContr_of_equiv`, `isMereProp_of_equiv`).

*Proof sketch.* An equivalence is a bijection, hence carries a two-sided inverse; contractibility and mere-propositionality are preserved by pushing centers/elements back and forth along the bijection and its inverse. ∎

### 5.2 Univalence-lite: transport of algebraic structure

We instantiate Theorem 5.5 on the leanest algebraic objects. A *magma* is a type with a binary operation and no axioms; a *magma homomorphism* commutes with the operations; its underlying map may or may not be an equivalence.

**Theorem 5.6 (Transport of commutativity and associativity along abstract equivalences).**
Let `φ` be a magma homomorphism `M → N` whose underlying function is an equivalence (`IsEquiv`). Then:
- if `M`'s operation is commutative, so is `N`'s (`magma_comm_transport_equiv`);
- if `M`'s operation is associative, so is `N`'s (`magma_assoc_transport_equiv`).

*Proof sketch.* Equivalence gives surjectivity (Theorem 5.2), so every `x, y, z : N` are images `φ a, φ b, φ c`. The homomorphism property rewrites operations in `N` as images of operations in `M`; the law in `M` then transfers and is rewritten back. ∎

The novelty over the classical named-isomorphism transport is that one needs only that `φ` *be* an equivalence — certifiable purely through contractibility of fibers — rather than possessing an explicit packaged inverse. This decouples "is an equivalence" from "carries an exhibited inverse," a small but genuine step toward the univalence principle: equivalent structures are interchangeable for all structural purposes.

---

## 6. The universal property of contractibility

We now realise contractibility as terminality in the homotopy category, fusing the synthetic and classical strands.

### 6.1 Classical bridge

**Theorem 6.1 (Maps into a contractible space are null-homotopic).**
Let `X`, `Y` be topological spaces with `Y` contractible. Every continuous map `f : C(X, Y)` is null-homotopic (homotopic to a constant).

*Proof sketch.* Contractibility of `Y` makes its identity map `id_Y` null-homotopic. Precomposing the null-homotopy of `id_Y` with `f` (and using `id_Y ∘ f = f`) transfers null-homotopy to `f`. ∎

**Theorem 6.2 (Any two maps into a contractible space are homotopic).**
For `Y` contractible and any `f, g : C(X, Y)`, we have `f.Homotopic g`.

*Proof sketch.* If `X` is empty, `f = g` by extensionality and the claim is reflexivity. Otherwise, Theorem 6.1 gives constants `y, y'` with `f ≃ const y` and `g ≃ const y'`; contractible spaces are path-connected, so `y` and `y'` are joined by a path, making `const y ≃ const y'`. Chaining the homotopies yields `f ≃ g`. ∎

### 6.2 Synthetic packaging and the terminal property

We form the type of homotopy classes. Mathlib provides `ContinuousMap.Homotopic.equivalence`, an equivalence relation on `C(X, Y)`, but no ready-made quotient; we assemble the setoid by hand.

**Definition 6.3 (Homotopy classes).**
```
homotopicSetoid X Y  :=  ⟨ContinuousMap.Homotopic, ContinuousMap.Homotopic.equivalence⟩,
homotopyClasses X Y  :=  Quotient (homotopicSetoid X Y).
```
We write `[X, Y]` for `homotopyClasses X Y`.

**Theorem 6.4 (`[X, Y]` is a mere proposition for contractible `Y`).**
If `Y` is contractible then `IsMereProp (homotopyClasses X Y)`.

*Proof sketch.* By double quotient induction (`Quotient.ind`) it suffices to compare two representatives `f, g : C(X, Y)`. Theorem 6.2 gives `f.Homotopic g`, and `Quotient.sound` turns this homotopy into equality of classes. ∎

**Theorem 6.5 (`[X, Y]` is inhabited for contractible `Y`).**
If `Y` is contractible then `Nonempty (homotopyClasses X Y)`.

*Proof sketch.* A contractible space is nonempty; pick a point `y` and take the class of the constant map `const_X y`. ∎

**Theorem 6.6 (Contractible spaces are terminal in the homotopy category).**
If `Y` is contractible then `IsContr (homotopyClasses X Y)` for every `X`.

*Proof sketch.* Combine Theorems 6.4 and 6.5 through the existence–uniqueness decomposition (Theorem 4.4): an inhabited mere proposition is contractible. ∎

Theorem 6.6 is the precise content of the slogan "the mapping space `C(X, ∗)` is contractible up to homotopy." It states that from every object `X` there is, up to homotopy, exactly one map into a contractible `Y` — the defining universal property of a terminal object. As a corollary, contractible targets are *local* for **every** class `W` of maps one might wish to invert: since every map is sent by `C(−, Y)` to the unique homotopy class, every map in `W` is automatically inverted. Contractible spaces thus furnish a zero-cost family of local objects, the natural seed for a theory of homotopy localization.

---

## 7. Algorithms

The constructions above are largely existence statements, but their *finite models* are fully algorithmic. We record the two algorithms exploited in the accompanying demonstrations.

**Algorithm 7.1 (Fibrewise equivalence test).** Decide whether a function `f : A → B` between finite types is a bijection by computing, for each `b : B`, its fiber `f⁻¹(b)` and checking that the fiber is a singleton (the finite model of `IsContr`). This is the executable shadow of Theorem 5.1. Complexity: `O(|A| + |B|)` with hashing.

**Algorithm 7.2 (Structure transport).** Given a bijection `φ : M → N` (a finite equivalence) and a binary operation table on `M`, transport the operation to `N` by `op_N(x, y) := φ(op_M(φ⁻¹ x, φ⁻¹ y))`, then verify that any algebraic law (commutativity, associativity) holding in `M` holds in `N`. This is the executable shadow of Theorem 5.6. Complexity: `O(|N|²)` to build the table, `O(|N|³)` to verify associativity.

---

## 8. Applications

- **Equivalence reasoning by local data.** Theorem 5.1 lets one certify a map as an equivalence by a purely local, fiberwise check, which is often easier than exhibiting a global inverse — and the 2-out-of-3 law (Theorem 5.4) propagates such certificates through diagrams.
- **Structure identity.** Theorem 5.6 transports algebraic axioms across abstract equivalences, the working core of a structure identity principle: equivalent algebraic structures satisfy the same equational laws.
- **Homotopy-categorical universals.** Theorem 6.6 identifies the terminal object of the homotopy category concretely, providing the universal arrow needed by any downstream localization or model-categorical construction *before* heavier machinery is built.
- **Foundations of path induction.** Theorem 3.1 makes the J-rule a theorem about a concrete contractible object, clarifying its geometric meaning.

---

## 9. Discussion

The recurring methodological device is a **duality between a property and a representation**. An equivalence is, on one face, the algebraic datum `Function.Bijective`; on the other, the homotopy-spectral datum "every fiber is contractible." Theorem 5.1 proves these faces equal, after which all equivalence-theoretic questions may be answered on whichever face is convenient. A second duality runs through Section 6: contractibility of a *space* `Y` is converted, via the quotient `[X, Y]`, into contractibility of the *type* of homotopy classes mapping into it — the cleanest possible bridge between the classical `ContractibleSpace` and the synthetic `IsContr`.

A structural observation organizes the whole development: in a proof-irrelevant metatheory the h-level hierarchy collapses above level −1, so all genuine homotopical content is concentrated in `IsContr` and `IsMereProp`. The existence–uniqueness decomposition (Theorem 4.4) then becomes the universal tool, factoring every contractibility goal into an inhabitation lemma and a mere-propositionality lemma — a pattern that recurs in the fiber characterisation (Theorem 5.1) and in the terminal property (Theorem 6.6).

All results are fully formalised with no remaining gaps and depend only on the standard foundational axioms (propositional extensionality, the axiom of choice, and quotient soundness).

---

## 10. Future work

**Direction 1 — A first-class `IsEquiv` layer and 2-out-of-3.** Realised here: the predicate `IsEquiv f := ∀ b, IsContr (HFiber f b)`, the representation dictionary `isEquiv_iff_bijective`, and the full 2-out-of-3 law, all stable under homotopy. The discovery is that 2-out-of-3 holds verbatim with no coherence condition, because in `Type` an equivalence is a bijection. A natural continuation is a coherent, higher-categorical refinement where the fibers carry their own homotopical structure.

**Direction 2 — Univalence-lite transport.** Realised here as `magma_comm_transport_equiv` / `magma_assoc_transport_equiv`: structure transports along *abstract* equivalences presented fiberwise, generalising named-isomorphism transport. The continuation is a general structure identity principle: *any* property closed under equivalence transports along a map with contractible fibers, for arbitrary algebraic and order-theoretic signatures.

**Direction 3 — Loop spaces, π₁, and Eckmann–Hilton.** Define the loop space `Ω(A, a) := (a = a)` and the based path space `P(A, a) := { b // a = b }`. Since `P(A, a)` is contractible (Theorem 3.1), the path fibration `P(A, a) → A` has fiber `Ω(A, a)`, and the horizontal/vertical composition of 2-cells supplies Eckmann–Hilton data on the double loop space `Ω²`, immediately yielding that `π_n` is abelian for `n ≥ 2` by instantiating the existing Eckmann–Hilton theorem. The one missing geometric input — contractibility of the total path space — is now a proved lemma.

**Direction 4 — Homotopy localization.** Define the localization inverting a chosen class `W` of maps and prove its universal property against contractible targets. Because every map into a contractible `Y` is null-homotopic, every map in `W` is automatically inverted by `C(−, Y)`; contractible spaces are therefore `W`-local for every `W`, a zero-cost first family of local objects. The terminality statement (Theorem 6.6) supplies the defining universal arrow on contractible targets before any model-category machinery is built — a sharp, falsifiable claim: is `C(−, Y)` `W`-invariant for all `W` exactly when `Y` is contractible up to homotopy?
