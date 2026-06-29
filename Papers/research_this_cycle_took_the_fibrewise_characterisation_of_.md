# The Equivalence Calculus and Contractibility as a Universal Property

## A Fibrewise Representation of Bijections and Its Structural Laws

### Abstract

We develop, in a synthetic homotopy-theoretic setting compatible with
classical set theory, a self-contained *equivalence calculus* built on a
single bridge: a function is a bijection if and only if all of its
homotopy fibres are contractible. Promoting this bridge to a first-class
predicate `IsEquiv f := ∀ b, IsContr (HFiber f b)`, we prove a
*representation dictionary* identifying `IsEquiv` with `Function.Bijective`,
and from it derive the complete groupoidal structure of equivalences:
reflexivity, closure under composition, stability under pointwise homotopy,
and the full **two-out-of-three law** in all three legs. We show the
two-out-of-three law holds *verbatim*, with no extra coherence hypothesis,
because in the category of types an equivalence is literally a bijection.
We then prove that h-levels (contractibility and mere-propositionality)
transport across equivalences, and establish a *univalence-lite* transport
principle moving equational structure (commutativity, associativity) along
any operation-preserving equivalence of magmas. Dually, we characterise
contractibility as a **universal property**: every continuous map into a
contractible space is null-homotopic, any two such maps are homotopic, and
any two contractible types are equivalent — i.e. a contractible space is
the terminal object of the homotopy category, unique up to equivalence. All
results are formalised with no `sorry` and depend only on the standard
axioms `propext`, `Classical.choice`, and `Quot.sound`.

---

### 1. Introduction

The notion of *equivalence* admits two seemingly different definitions.
Classically, an equivalence of sets is a **bijection**: a function that is
injective and surjective. Homotopically, an equivalence is a map all of
whose **homotopy fibres are contractible** — a definition that survives in
settings where bare bijectivity is too coarse, and which is the technically
preferred definition in homotopy type theory because it is a *mere
proposition* (it carries no choice).

This paper takes the bridge between these two definitions as a foundation
and builds the resulting algebra of equivalences end to end. The
methodological theme throughout is **representation/duality**: each
homotopical question about equivalences is faithfully *represented* by a
question about `Function.Bijective`, where it becomes finite combinatorial
bookkeeping; and contractibility of a space is *dual* to a universal
mapping property identifying it as terminal in the homotopy category.

The work is organised around two source files of fully formalised results:

- a **path-spaces and h-levels** layer establishing contractibility of
  path spaces, closure of the h-level hierarchy, the fibrewise
  characterisation of equivalences, and the classical-topology realisation
  of contractible targets as terminal;
- an **equivalence calculus** layer promoting the fibrewise characterisation
  to the predicate `IsEquiv`, proving the representation dictionary, the
  groupoid laws, the two-out-of-three law, h-level transport, and
  univalence-lite structure transport.

We state every definition, theorem, and proof sketch inline.

---

### 2. Preliminaries and Definitions

We work with types `A, B, C, …` and total functions between them. Equality
`a = b` is the identity type; in the ambient proof-irrelevant setting,
every identity type is a subsingleton, so the homotopically nontrivial
h-levels are exactly the two lowest ones, defined next.

**Definition 2.1 (Contractibility).** A type `A` is *contractible*, written
`IsContr A`, when it has a centre to which every point is equal:
```
IsContr A  :=  ∃ c : A, ∀ a : A, a = c.
```
Contractibility is h-level `(-2)`, the homotopical analogue of "has exactly
one element."

**Definition 2.2 (Mere proposition).** A type `A` is a *mere proposition*,
written `IsMereProp A`, when any two of its points are equal:
```
IsMereProp A  :=  ∀ x y : A, x = y.
```
This is h-level `(-1)`, the analogue of "has at most one element."

**Definition 2.3 (Homotopy fibre).** For `f : A → B` and `b : B`, the
*homotopy fibre* of `f` over `b` is the type of source points equipped with
a proof that they map to `b`:
```
HFiber f b  :=  { a : A // f a = b }.
```

**Definition 2.4 (Based path space).** For `a : A`, the *based path space*
is the subtype `{ b : A // a = b }`, the type of points reachable from `a`
together with the witnessing equality.

**Definition 2.5 (Magma and magma homomorphism).** A *magma* `M` is a type
`M.Carrier` equipped with a binary operation `M.op : M.Carrier →
M.Carrier → M.Carrier`. A *magma homomorphism* `φ : MagmaHom M N` is a map
`φ.toFun : M.Carrier → N.Carrier` satisfying `φ.toFun (M.op a b) = N.op
(φ.toFun a) (φ.toFun b)`. A *magma isomorphism* `MagmaIso M N` is a magma
homomorphism whose underlying map is bijective.

We take as given the following facts from the underlying synthetic-homotopy
layer (used as black boxes here):

- `bijective_of_contr_fibers` (the *forward* one-directional precursor of
  Theorem 3.6);
- `magma_comm_transport` and `magma_assoc_transport`: along a *named*
  magma isomorphism `MagmaIso M N`, commutativity (resp. associativity) of
  `M.op` implies the same for `N.op`;
- the classical-topology facts `id_nullhomotopic`,
  `ContinuousMap.Nullhomotopic.comp_left`, `ContinuousMap.homotopic_const_iff`,
  and `PathConnectedSpace.joined`, available from the standard library for
  spaces carrying a `ContractibleSpace` instance.

---

### 3. Path Spaces, h-Levels, and the Fibrewise Characterisation

This section assembles the homotopical infrastructure. Its summit is the
fibrewise characterisation of equivalences (Theorem 3.6), the bridge on
which the entire calculus rests.

**Theorem 3.1 (Contractibility of singletons / path induction).** For any
`a : A`, the based path space `{ b : A // a = b }` is contractible.

*Proof sketch.* The centre is `⟨a, rfl⟩`. For any other point `⟨b, p⟩`,
path induction (eliminating the equality `p : a = b`) reduces `b` to `a`
and `p` to `rfl`, whereupon the point is judgmentally the centre. This is
the synthetic content of the "J rule." ∎

**Theorem 3.2 (Contractibility is inherited by retracts).** If `r : A → B`
and `s : B → A` satisfy `r (s b) = b` for all `b`, and `A` is contractible,
then `B` is contractible.

*Proof sketch.* Let `c` be the centre of `A`. The point `r c` is the centre
of `B`: for any `b`, write `b = r (s b)` by the retraction equation, then
`r (s b) = r c` since `s b = c` by contractibility of `A`. ∎

**Theorem 3.3 (Σ-closure of h-levels).**
(i) If the base `A` is contractible and every fibre `B a` is contractible,
then `Σ a, B a` is contractible.
(ii) If `A` is a mere proposition and every `B a` is a mere proposition,
then `Σ a, B a` is a mere proposition.

*Proof sketch.* For (i), the centre is `⟨c, d⟩` with `c` the centre of `A`
and `d` the centre of the fibre `B c`. Given any `⟨a, x⟩`, contractibility
of `A` identifies `a` with `c`; transporting, contractibility of the fibre
identifies `x` with `d`; `Sigma.ext` glues the two equalities. Part (ii) is
the same argument with the mere-propositional witnesses in place of
centres. ∎

**Theorem 3.4 (Π-closure for contractibility).** If every `B a` is
contractible, then the dependent product `∀ a, B a` is contractible.

*Proof sketch.* The centre is the pointwise choice `a ↦ centre of B a`.
Function extensionality reduces equality of any `f` to the centre to a
family of fibrewise equalities, each supplied by contractibility of `B a`. ∎

**Theorem 3.5 (Characterisation of contractibility).** For any type `A`,
```
IsContr A  ↔  Nonempty A ∧ IsMereProp A.
```

*Proof sketch.* Forward: a centre witnesses `Nonempty A`, and any two
points equal the centre, hence each other (via `(hc a).trans (hc b).symm`),
giving `IsMereProp A`. Backward: an inhabitant `c` plus
mere-propositionality makes `c` a centre, since `hp a c : a = c`. This is
the bridge between h-levels `(-2)` and `(-1)`. ∎

**Theorem 3.6 (Fibrewise characterisation of equivalences).** For
`f : A → B`,
```
Function.Bijective f  ↔  ∀ b, IsContr (HFiber f b).
```

*Proof sketch.* (⇒) Given injectivity and surjectivity, fix `b`.
Surjectivity yields `a` with `f a = b`; this `⟨a, ha⟩` is the fibre's
centre. Any other `⟨a', ha'⟩` satisfies `f a' = b = f a`, so injectivity
gives `a' = a`, and `Subtype.ext` upgrades this to equality of fibre
points. (⇐) Suppose each fibre is contractible. *Injectivity:* if
`f a = f a'`, the fibre over `f a` is contractible, so its two points
`⟨a, rfl⟩` and `⟨a', _⟩` coincide; projecting to first components gives
`a = a'`. *Surjectivity:* the centre of the (inhabited) fibre over `b`
provides a preimage of `b`. This upgrades the one-directional
`bijective_of_contr_fibers` to a genuine biconditional. ∎

**Theorem 3.7 (Uniqueness of the terminal homotopy type).** If `A` and `B`
are both contractible, then there is an equivalence `A ≃ B`.

*Proof sketch.* Let `a₀, b₀` be the centres. The constant maps `_ ↦ b₀` and
`_ ↦ a₀` are mutually inverse: each round trip lands in a contractible type
and so equals the centre, which the contractions certify. ∎

**Theorem 3.8 (Contractible targets are terminal up to homotopy).** Let `X`
and `Y` be topological spaces with `Y` contractible (`ContractibleSpace Y`).
(i) Every continuous map `f : C(X, Y)` is null-homotopic.
(ii) Any two continuous maps `f, g : C(X, Y)` are homotopic.

*Proof sketch.* (i) The identity on a contractible space is null-homotopic;
precomposing the null-homotopy with `f` (via `Nullhomotopic.comp_left`,
using `id ∘ f = f`) makes `f` null-homotopic. (ii) If `X` is empty, the map
space is a subsingleton and the maps are literally equal. Otherwise `f` and
`g` are each homotopic to constants `c_y` and `c_{y'}`; a contractible space
is path-connected, so `y` and `y'` are joined by a path, whence the
constants are homotopic (`homotopic_const_iff`), and transitivity chains
the three homotopies. ∎

Theorems 3.7 and 3.8 together express the **universal property** of
contractibility: a contractible object receives an essentially unique map
from every object, the defining signature of a terminal object, and the
terminal object is unique up to equivalence.

---

### 4. The Equivalence Calculus

We now promote Theorem 3.6 to a definition and develop its algebra.

**Definition 4.1 (Equivalence predicate).**
```
IsEquiv f  :=  ∀ b, IsContr (HFiber f b).
```
This is the homotopy-native definition of "type equivalence": `f` is an
equivalence exactly when its homotopy-fibre spectrum is uniformly trivial.

**Theorem 4.2 (Representation dictionary).** For `f : A → B`,
```
IsEquiv f  ↔  Function.Bijective f,
```
and consequently `IsEquiv.bijective` and `IsEquiv.of_bijective` translate
freely between the two presentations.

*Proof.* This is exactly Theorem 3.6 read in the reverse direction. ∎

The dictionary is the strategic device of the paper: every subsequent law
is proved by translating to `Function.Bijective`, applying elementary
injectivity/surjectivity bookkeeping, and translating back.

**Theorem 4.3 (Reflexivity).** `IsEquiv (id)`.

*Proof.* `id` is bijective; apply `IsEquiv.of_bijective`. ∎

**Theorem 4.4 (Closure under composition).** If `IsEquiv f` and `IsEquiv g`,
then `IsEquiv (g ∘ f)`.

*Proof.* Compose the underlying bijections via `Function.Bijective.comp`,
then translate back. ∎

**Theorem 4.5 (Homotopy stability).** If `f a = g a` for all `a` and
`IsEquiv f`, then `IsEquiv g`.

*Proof.* Function extensionality turns the pointwise homotopy into `g = f`;
rewriting reduces the goal to `IsEquiv f`. Being an equivalence is thus a
property of a map's homotopy class, not its presentation. ∎

Theorems 4.3–4.5 establish that equivalences form a **groupoid**: a
reflexive, composition-closed, homotopy-invariant class of reversible
maps.

**Theorem 4.6 (Two-out-of-three law).** Given `f : A → B` and `g : B → C`:
1. *(first leg)* if `IsEquiv f` and `IsEquiv g`, then `IsEquiv (g ∘ f)`;
2. *(second leg, `cancel_left`)* if `IsEquiv g` and `IsEquiv (g ∘ f)`, then
   `IsEquiv f`;
3. *(third leg, `cancel_right`)* if `IsEquiv f` and `IsEquiv (g ∘ f)`, then
   `IsEquiv g`.

*Proof sketch.* The first leg is Theorem 4.4. For the second leg, translate
`g` and `g ∘ f` to bijections. *`f` injective:* if `f a = f a'`, apply `g`
to get `(g ∘ f) a = (g ∘ f) a'`, then cancel using injectivity of `g ∘ f`.
*`f` surjective:* given `b`, surjectivity of `g ∘ f` applied to `g b`
yields `a` with `g (f a) = g b`; injectivity of `g` cancels the outer `g`,
giving `f a = b`. For the third leg, translate `f` and `g ∘ f`. *`g`
surjective:* a preimage of `c` under `g ∘ f` provides `f a` mapping to `c`.
*`g` injective:* given `g b = g b'`, surjectivity of `f` writes `b = f a`,
`b' = f a'`; then `(g ∘ f) a = (g ∘ f) a'`, so injectivity of `g ∘ f` gives
`a = a'`, hence `b = b'`. ∎

**Remark 4.7 (No coherence is required).** A recurring concern in abstract
treatments of weak equivalences is whether the cancellation legs of
two-out-of-three need an auxiliary *coherence* hypothesis (e.g. a supplied
section for the middle map). Theorem 4.6 shows that for `IsContr`-fibre
equivalences in the category of types they do **not**: the proof passes
through `Function.Bijective`, where cancellation is bare set-theoretic
injectivity/surjectivity reasoning. The earlier-posed falsifiable question
is thereby answered in the affirmative — the law holds verbatim.

**Theorem 4.8 (Transport of h-levels along equivalences).** Let `e : A ≃ B`.
(i) If `A` is contractible, so is `B`.
(ii) If `A` is a mere proposition, so is `B`.

*Proof sketch.* (i) The pair `(e, e.symm)` is a retraction
(`e (e.symm b) = b`), so Theorem 3.2 carries the centre of `A` to a centre
of `B`. (ii) For `x, y : B`, pull back along `e.symm`, use
mere-propositionality of `A` to equate `e.symm x` and `e.symm y`, and push
forward with `e` using `e.apply_symm_apply`. ∎

**Theorem 4.9 (Univalence-lite structure transport).** Let `φ : MagmaHom M
N` with `IsEquiv φ.toFun`.
(i) *(commutativity)* If `M.op a b = M.op b a` for all `a, b`, then
`N.op x y = N.op y x` for all `x, y`.
(ii) *(associativity)* If `M.op (M.op a b) c = M.op a (M.op b c)` for all
`a, b, c`, then the same holds in `N`.

*Proof.* By the dictionary, `φ.toFun` is bijective, so `⟨φ, hφ.bijective⟩`
is a magma isomorphism `MagmaIso M N`. Apply the named-isomorphism
transports `magma_comm_transport` (resp. `magma_assoc_transport`). The
content beneath those black boxes is the pull-back/push-forward round trip:
to verify an equation in `N`, transport the operands back to `M` along the
inverse, use the law in `M`, and transport the result forward, the
equivalence guaranteeing the round trip is lossless. ∎

Theorem 4.9 generalises transport along *named* isomorphisms to transport
along *abstract* equivalences presented fibrewise. It is a concrete,
hand-earned fragment of Voevodsky's univalence principle: equivalent
algebraic structures share their equational laws.

---

### 5. Algorithms and Computational Content

Although the development is logical, every theorem has an explicit finite
witness on finite types, which we expose algorithmically (see `demo.py`).

**Algorithm A (Fibre contractibility check).** Given `f : A → B` over
finite `A, B`, compute for each `b ∈ B` the fibre `f⁻¹(b)` and report it
contractible iff `|f⁻¹(b)| = 1`. The map is an equivalence iff every fibre
is a singleton. Complexity `O(|A| + |B|)`. This is the executable shadow of
Theorem 4.2.

**Algorithm B (Two-out-of-three solver).** Given any two of `f`, `g`,
`g ∘ f` known to be bijective on finite carriers, decide the third by the
constructive cancellation arguments of Theorem 4.6. Complexity is linear in
carrier size. The reconstruction of the missing map's inverse is explicit.

**Algorithm C (Structure transport).** Given an operation-preserving
bijection `φ : M → N` with inverse `ψ`, and a law `L` holding in `M`,
verify `L` in `N` by `x ⋆_N y = φ(ψ(x) ⋆_M ψ(y))` and reduce to `L` in `M`.
This is the executable form of Theorem 4.9 and makes the round-trip proof
literally a computation.

---

### 6. Applications

- **Diagram chasing.** The two-out-of-three law (Theorem 4.6) is the
  routine engine for proving a map is an equivalence from its diagrammatic
  context, without direct inspection — the daily idiom of homotopy theory
  and category theory.
- **Reduction of algebraic problems.** Theorem 4.9 lets one prove an
  equational property of an awkward structure by transporting it from an
  equivalent, more tractable one.
- **Recognising universal objects.** Theorem 3.8 gives a usable criterion:
  a space is terminal in the homotopy category as soon as it is
  contractible; conversely all maps into it coincide up to homotopy.
- **h-level engineering.** Theorems 3.3, 3.4, and 4.8 give closure rules
  for building contractible and propositional types and transporting those
  properties across equivalences — basic moves in formalised mathematics.

---

### 7. Discussion

The architecture of this development is a single design decision applied
relentlessly: *represent the homotopical notion by the classical one and
let the classical bookkeeping do the work.* The predicate `IsEquiv`, a
proposition stable under homotopy and free of choice, is the "right"
homotopical definition; `Function.Bijective` is the computationally
convenient one. The dictionary (Theorem 4.2) makes them interchangeable, so
every result enjoys the conceptual cleanliness of the former and the
mechanical tractability of the latter.

The same duality organises the contractibility results. Contractibility is
simultaneously the *smallest* h-level (an internal, pointwise notion,
Definitions 2.1 and Theorem 3.5) and a *universal* property (an external,
mapping-in notion, Theorems 3.7–3.8). The reconciliation — terminal objects
are the contractible ones, unique up to equivalence — is the categorical
shadow of the synthetic statement.

A noteworthy feature of the proof-irrelevant ambient setting is that the
higher h-levels collapse: every identity type is automatically a
subsingleton, so `IsHSet` and above are vacuous, and *all* homotopical
content concentrates in `IsContr` and `IsMereProp`. This is why the
substantive theorems concern contractibility of path spaces and the
fibrewise picture, and why the two-out-of-three law needs no coherence: the
coherence cells that would obstruct it in a genuinely higher setting are
trivialised here.

---

### 8. Future Directions

- **Two-out-of-six.** The natural strengthening of Theorem 4.6: from
  `g ∘ f` and `h ∘ g` equivalences conclude all six of `f, g, h, g∘f,
  h∘g, h∘g∘f` are equivalences. The dictionary reduces this to one extra
  cancellation over `Function.Bijective`.
- **Structured equivalences.** Upgrade the *property* `IsEquiv` to a
  *structure* carrying an explicit half-adjoint inverse and proving the
  type of such inverse data contractible, enabling actual computation of
  inverses while retaining the property-level theorems.
- **Loop spaces and Eckmann–Hilton.** Use contractibility of the based
  path space (Theorem 3.1) to build the path fibration and feed the
  double loop space into the Eckmann–Hilton argument, concluding the second
  homotopy group is abelian.
- **Genuine contractible mapping spaces.** Promote the homotopy-class
  statement (Theorem 3.8) to contractibility of the mapping space
  `C(X, Y)` itself in the compact-open topology, the missing datum being
  continuity of post-composition.
- **Univalence-lite for arbitrary equational theories.** Generalise
  Theorem 4.9 from commutativity and associativity to a single transport
  theorem over a free-magma term datatype, recovering group, ring, and
  general algebraic transport as one-line corollaries, and testing whether
  the principle is balancedness-blind.

---

### 9. Conclusion

We have turned a single bridge — *a function is a bijection iff all its
homotopy fibres are contractible* — into a complete, self-contained calculus
of equivalences, and have exhibited contractibility as a universal property
identifying terminal objects of the homotopy category. The representation
dictionary makes the groupoid laws, the coherence-free two-out-of-three
law, h-level transport, and univalence-lite structure transport all
immediate, mechanical consequences of one identification. The development
is fully formalised with no `sorry`, relying only on the standard axioms
`propext`, `Classical.choice`, and `Quot.sound`.
