# Path Spaces, h-Levels, and the Fibrewise Characterisation of Equivalences

## Abstract

We develop, within a classical type-theoretic foundation (Lean 4's dependent type
theory with a proof-irrelevant universe of propositions), the structural core of the
synthetic theory of *contractibility* and its bridge to classical topology. We prove
that the based path space of any point is contractible — the synthetic content of
path induction — and that the h-level hierarchy is closed under the basic type
formers: Σ-types, Π-types, and retracts. We give the standard decomposition of
contractibility into inhabitation plus mere-propositionality. The central result is
a *fibrewise characterisation of equivalences*: a function is bijective if and only
if all of its homotopy fibres are contractible, an "if-and-only-if" upgrade of the
classical one-directional sufficiency criterion. We deduce that any two contractible
types are equivalent — uniqueness of the terminal homotopy type — and we realise the
abstract picture classically by proving that every continuous map into a
contractible topological space is null-homotopic and that any two such maps are
homotopic. Conceptually, the paper isolates a single thesis: *contractibility is
terminality in the homotopy category*, and this terminality has both a synthetic
(type-theoretic) and a classical (topological) incarnation. All results are
formalised with no unproved assumptions beyond the standard logical axioms
(propositional extensionality, the axiom of choice, quotient soundness).

**Keywords.** homotopy type theory, contractibility, h-levels, path space, homotopy
fiber, equivalence, terminal object, null-homotopy, mere proposition.

## 1. Introduction

Homotopy Type Theory (HoTT) reinterprets the identity type `a = b` as a *path space*
between points of a type-as-space. Under this reading, the logical machinery of
equality acquires geometric meaning, and the basic invariants of homotopy theory —
connectedness, truncation level, equivalence — become statements one can prove by
type-theoretic manipulation. A foundational classification in this setting is the
**h-level hierarchy**, which stratifies types by the complexity of their iterated
path spaces. The two lowest levels — contractible types (level −2) and mere
propositions (level −1) — carry essentially all of the homotopically non-trivial
content in a foundation, like Lean's, where the universe `Prop` is proof-irrelevant
and therefore every identity type is automatically a subsingleton (so every type is
an h-set; see Remark 3.4).

This paper concentrates the development where the substance lies: on contractibility
of path spaces and on the *fibrewise* theory of equivalences. We establish closure
of the hierarchy under the standard constructors, prove the based path space
contractible, characterise equivalences fibrewise, and exhibit the universal
property that unifies the synthetic and classical pictures: a contractible object is
terminal in the homotopy category.

The development extends a pre-existing synthetic homotopy module that supplies the
basic vocabulary — `IsContr`, `IsMereProp`, `IsHSet`, the homotopy fiber `HFiber`,
the Eckmann–Hilton argument, transport — and in particular a one-directional lemma
`bijective_of_contr_fibers` (contractible fibres ⇒ bijective). Our contribution is to
turn that sufficiency into a characterisation and to surround it with the closure
and universality results that give contractibility its structural meaning.

## 2. Definitions

We work in a fixed type universe and write `Type*` for an arbitrary universe-
polymorphic type.

**Definition 2.1 (Contractibility, h-level −2).**
A type `A` is *contractible* when it has a *center* to which every element is equal:
```
IsContr A  :=  ∃ c : A, ∀ a : A, a = c.
```

**Definition 2.2 (Mere proposition, h-level −1).**
A type `A` is a *mere proposition* when any two of its elements are equal:
```
IsMereProp A  :=  ∀ a b : A, a = b.
```

**Definition 2.3 (h-set, h-level 0).**
A type `A` is an *h-set* when any two parallel paths are equal:
```
IsHSet A  :=  ∀ (a b : A) (p q : a = b), p = q.
```

**Definition 2.4 (Based path space).**
For `a : A`, the *based path space* (the space of paths emanating from `a`) is the
subtype
```
PathsFrom a  :=  { b : A // a = b }.
```
We use a subtype rather than a Σ-type because in Lean the identity type `a = b`
inhabits the propositional universe `Sort 0`, whereas `Sigma` requires a `Type`
fiber; the subtype `{ b // a = b }` is the correct total space.

**Definition 2.5 (Homotopy fiber).**
For `f : A → B` and `b : B`, the *homotopy fiber* of `f` over `b` is
```
HFiber f b  :=  { a : A // f a = b }.
```

**Definition 2.6 (Retract).**
`B` is a *retract* of `A` if there are maps `s : B → A` and `r : A → B` with
`r (s b) = b` for all `b : B`.

For the classical bridge (Section 6) we use Mathlib's topological notions:
`ContractibleSpace Y` (the space `Y` is contractible in the literal homotopy sense),
the type `C(X, Y)` of continuous maps, the constant continuous map, and the relation
`ContinuousMap.Homotopic` of being homotopic.

## 3. Contractibility of path spaces and the h-level decomposition

**Theorem 3.1 (Contractibility of singletons / path induction).**
For every `a : A`, the based path space `{ b // a = b }` is contractible.

*Proof sketch.* Take the center to be `⟨a, rfl⟩`. Given any element `⟨b, p⟩` with
`p : a = b`, eliminate the path by `rintro ⟨b, rfl⟩` (the synthetic J rule
specialises `b := a` and `p := rfl`); the goal `⟨a, rfl⟩ = ⟨a, rfl⟩` is then `rfl`.
∎

This is precisely the geometric reading of path induction: proving a property of an
arbitrary path reduces to proving it for the trivial path, *because the entire space
of based paths contracts onto the trivial one*.

**Theorem 3.2 (Retract closure).**
If `B` is a retract of a contractible `A`, then `B` is contractible.

*Proof sketch.* Let `c` be the center of `A` and `h : ∀ b, r (s b) = b` the
retraction. The point `r c` is a center for `B`: for any `b`, rewrite
`b = r (s b) = r c` using `h b` and the contraction `s b = c`. ∎

**Theorem 3.3 (Decomposition of contractibility).**
`IsContr A ↔ Nonempty A ∧ IsMereProp A`.

*Proof sketch.* (⇒) From a center `c`, inhabitation is `⟨c⟩`, and any `a, b` are
equal via `a = c = b`. (⇐) From a witness `c` and propositionality, `c` is a center
because `hp a c : a = c`. ∎

**Remark 3.4 (Why only two non-trivial levels).** In Lean's proof-irrelevant `Prop`,
any two proofs of an equality are definitionally equal, so `IsHSet A` holds for
*every* type. Consequently the homotopically informative levels in this foundation
are exactly −2 and −1, which is why the development concentrates on `IsContr` and
`IsMereProp`.

## 4. Closure of h-levels under Σ and Π

**Theorem 4.1 (Σ-closure for contractibility).**
If `A` is contractible and each fiber `B a` is contractible, then `Σ a, B a` is
contractible.

*Proof sketch.* Let `c` be the center of `A` and `d` the center of `B c`. Take
`⟨c, d⟩` as center. For `⟨a, x⟩`, the base contraction gives `a = c`; substituting
(`obtain rfl := hc a`) reduces the goal to the fiber, where `Sigma.ext rfl` and the
fiber contraction `hd x` finish. ∎

**Theorem 4.2 (Σ-closure for mere propositions).**
If `A` is a mere proposition and each `B a` is a mere proposition, then `Σ a, B a` is
a mere proposition.

*Proof sketch.* Given `⟨a, x⟩` and `⟨a', x'⟩`, base propositionality gives `a = a'`;
substituting and applying fiber propositionality through `Sigma.ext rfl` closes the
goal. ∎

**Theorem 4.3 (Π-closure for contractibility).**
If each `B a` is contractible, then the dependent product `∀ a, B a` is contractible.

*Proof sketch.* Define the center pointwise as `fun a => (hB a).choose`. For any `f`,
function extensionality reduces equality to the pointwise statement
`f a = (hB a).choose`, which is the fiber contraction `(hB a).choose_spec (f a)`. ∎

These three closure properties (with retract closure, Theorem 3.2) show that
contractibility — "being a point up to homotopy" — is preserved by the fundamental
type formers used to assemble dependent constructions.

## 5. The fibrewise characterisation of equivalences

We now state the central result, which upgrades the ambient module's one-directional
`bijective_of_contr_fibers` (contractible fibres ⇒ bijective) to a biconditional.

**Theorem 5.1 (Equivalence ⇔ contractible fibres).**
For any `f : A → B`,
```
Function.Bijective f  ↔  ∀ b : B, IsContr (HFiber f b).
```

*Proof sketch.*
(⇒) Assume `f` injective and surjective and fix `b`. Surjectivity yields `a` with
`f a = b`, so `⟨a, _⟩` is a candidate center. For any `⟨a', p⟩` in the fiber,
injectivity applied to `p` and the center's equation gives `a' = a`, and
`Subtype.ext` lifts this to fiber equality.
(⇐) Assume every fiber is contractible. *Injectivity*: if `f a = f a'`, both
`⟨a, rfl⟩` and `⟨a', _⟩` lie in `HFiber f (f a)`; the fiber's contraction forces them
equal, hence `a = a'` by taking first components. *Surjectivity*: the center of
`HFiber f b` supplies a preimage of `b`. ∎

**Discussion.** The theorem is a compression of two classical clauses into one
homogeneous geometric condition. Via Theorem 3.3, "each fiber contractible" is
equivalent to "each fiber inhabited (surjectivity) and a mere proposition
(injectivity)." Thus *bijective = every fiber is a point*. This is the structural
basis of the homotopy theory of equivalences: invertibility of a map is a *local,
fibrewise* condition of uniform triviality, not a global pair of separate
properties.

## 6. Contractibility as a universal property

The fibrewise picture culminates in the identification of contractibility with
terminality, expressed both synthetically and classically.

**Theorem 6.1 (Uniqueness of the terminal homotopy type).**
If `A` and `B` are both contractible, then `A ≃ B` (they are equivalent).

*Proof sketch.* Let `a` and `b` be the centers. The constant maps `_ ↦ b : A → B`
and `_ ↦ a : B → A` are mutually inverse: `left_inv` follows from the contraction of
`A` (every point equals `a`), `right_inv` from the contraction of `B`. ∎

Up to equivalence there is exactly one contractible type. In categorical language it
is the *terminal object* of the homotopy category: every object admits an
essentially unique map into it.

The classical realisation makes this terminality literal in ordinary topology.

**Theorem 6.2 (Maps into a contractible space are null-homotopic).**
Let `X` and `Y` be topological spaces with `Y` contractible. Then every continuous
map `f : C(X, Y)` is null-homotopic: there is a point `y : Y` with `f` homotopic to
the constant map at `y`.

*Proof sketch.* Contractibility of `Y` provides a homotopy from `id_Y` to a constant
map `const_{y₀}`. Whiskering this homotopy by `f` (post-composing the homotopy with
`f`, equivalently pre-composing into the homotopy) yields a homotopy from `f` to the
constant map at `y₀`. ∎

**Theorem 6.3 (All maps into a contractible space are homotopic).**
Let `Y` be contractible. Then any two continuous maps `f, g : C(X, Y)` are homotopic.

*Proof sketch.* By Theorem 6.2 each of `f` and `g` is homotopic to a constant map;
constant maps into a path-connected space (a contractible space is path-connected)
are homotopic to one another, and `Homotopic` is an equivalence relation, so `f` and
`g` are homotopic. A subtlety handled in the formalisation: the standard lemma
`ContinuousMap.homotopic_const_iff` carries a `[Nonempty X]` hypothesis, so the proof
case-splits on whether `X` is empty; when `X` is empty, `C(X, Y)` is a subsingleton
and reflexivity finishes. ∎

**Corollary 6.4 (The mapping space is homotopy-contractible).**
For contractible `Y`, the space of continuous maps `C(X, Y)` is "contractible up to
homotopy": it is inhabited (by any constant map) and all its points are connected by
homotopies (Theorem 6.3), i.e. it is a single point of the homotopy category. This
is the mapping-space form of terminality.

## 7. Algorithmic and computational content

Although the results are about spaces and proofs, each carries finite, checkable
*combinatorial shadows* that we exploit in the accompanying numerical demonstrations
(Section 8). The key reductions:

1. **Contractibility test on finite types.** For a finite type with a decidable
   equality, `IsContr A` is decidable: check that `A` is nonempty and that all
   elements coincide with a chosen witness. Equivalently, `|A| = 1`.
2. **Fiber enumeration.** For a function `f : A → B` between finite types, the
   homotopy fiber `HFiber f b` is the finite set `f⁻¹(b)`. Theorem 5.1 becomes the
   familiar finite statement "`f` is a bijection iff every fiber has exactly one
   element," i.e. `|f⁻¹(b)| = 1` for all `b`.
3. **h-level closure as cardinality identities.** Σ-closure specialises to
   `|Σ a, B a| = Σ_a |B a|`; contractibility of base and fibers forces each summand
   to be `1`, recovering `|Σ| = 1`. Π-closure specialises to `|Π a, B a| = Π_a |B a|`.

These reductions let us *verify the theorems numerically* by exhaustive enumeration
on small finite models, which is exactly what the demonstration code does.

## 8. Applications and examples

- **Certifying isomorphisms by fibers.** To check that a constructed map between two
  data structures is a bijection, one need only verify that each fiber is a
  singleton — a uniform, local check that parallelises trivially and is robust to the
  internal representation of the structures.
- **Singleton-elimination in proofs.** Theorem 3.1 underwrites the ubiquitous
  proof move "without loss of generality the path is reflexivity," because the based
  path space is contractible; numerically, any computation indexed by a based path
  depends only on the endpoint.
- **Choice-free normalisation over contractible parameter spaces.** Theorem 4.3
  says a family of contractible choices has an essentially unique global section;
  computationally, any algorithm parameterised by a contractible space can fix the
  unique center without loss of generality.
- **Homotopy-invariant targets.** Theorem 6.3 implies that any classifying problem
  with a contractible target is *trivial*: there is essentially one solution. This is
  the abstract reason that, e.g., sections of a bundle with contractible fibers
  always exist and are unique up to homotopy.

## 9. Discussion

The recurring theme is **unification through a single concept**. Contractibility
appears, with one definition, as: the bottom of the h-level hierarchy; the shape of
the based path space (the geometry of equality itself); the local criterion for a map
to be invertible (each fiber a point); the terminal object of the homotopy category;
and the classical fact that maps into a point are interchangeable. The fibrewise
characterisation (Theorem 5.1) is the hinge: it translates the global notion of
"isomorphism" into the uniform local notion of "all fibers contractible," and through
the decomposition (Theorem 3.3) it explains *why* injectivity and surjectivity are
the two halves of a single homotopical condition.

A methodological observation specific to a proof-irrelevant foundation (Remark 3.4):
because every identity type is a subsingleton, `IsHSet` is automatic, so the
informative content of "h-levels" lives entirely at levels −2 and −1. This sharpens,
rather than weakens, the theory: it tells us exactly where the mathematics is, and we
placed all of the proof effort there.

## 10. Future work

A natural next step is a genuine *equivalence layer*: define `IsEquiv f` directly as
"all homotopy fibers are contractible," prove its propositionality, and establish the
**2-out-of-3 law** (if two of `f`, `g`, `g ∘ f` are equivalences, so is the third)
purely from the fibrewise characterisation. From there one obtains a self-contained
calculus of equivalences — composition, inversion, whiskering — entirely in terms of
contractible fibers, and a clean route to the univalence-style transport of structure
along equivalences (of which the magma transport results in the ambient module are a
first instance). Further directions include connectivity and truncation (`n`-types
and their closure properties), the long exact sequence of a fibration phrased through
homotopy fibers, and tightening the classical bridge to identify
homotopy-contractibility of `C(X, Y)` with literal contractibility under suitable
hypotheses on `X`.

## 11. Worked examples

We close with three concrete instances that make the abstract statements tangible
and which the accompanying code verifies by enumeration.

**Example 11.1 (Based path space of a four-point type).** Let `A = {x, y, z, w}`.
For `a = x`, the based path space `{ b // x = b }` contains exactly the inhabited
pair `(x, refl)` — the destinations `y, z, w` carry no proof `x = b`, so they do not
appear. The total space is the singleton `{(x, refl)}`, manifestly contractible,
illustrating Theorem 3.1 and the path-induction principle: any computation indexed
by a based path out of `x` is determined by its value at the reflexive path.

**Example 11.2 (Fibrewise test on `ℤ/6ℤ`).** Consider three self-maps of
`Z₆ = {0, …, 5}`:

- the shift `f(a) = a + 1 mod 6`: every fiber `f⁻¹(b)` is a singleton, so by
  Theorem 5.1 `f` is an equivalence (indeed a bijection);
- the doubling `g(a) = 2a mod 6`: the fiber over `0` is `{0, 3}` (size 2, failing
  the mere-proposition clause) and the fiber over `1` is empty (failing the
  inhabitation clause), so `g` is not an equivalence — and the two failures are
  *exactly* the failures of injectivity and surjectivity, as the decomposition
  (Theorem 3.3) predicts;
- the constant `h(a) = 0`: every fiber except over `0` is empty, so `h` is maximally
  far from an equivalence.

The single criterion "all fibers are points" thus detects, and *localises*, both
failure modes simultaneously.

**Example 11.3 (Uniqueness of the terminal type).** Take `A = {★}` and `B = {42}`,
both contractible. The constant maps `★ ↦ 42` and `42 ↦ ★` are mutually inverse, so
`A ≃ B` (Theorem 6.1). There is, up to equivalence, only one contractible type;
operationally, any contractible parameter space may be collapsed to its center
without affecting any homotopy-invariant computation.

## 12. Related context and methodology

The results are standard facts of homotopy type theory — contractibility of
singletons, h-level closure, the equivalence/contractible-fiber correspondence, and
the terminality of contractible objects are foundational to the subject. The
contribution here is their *self-contained formal development* in a classical,
proof-irrelevant setting and, in particular, the explicit welding of the synthetic
statements to Mathlib's classical topology through the null-homotopy theorems
(Section 6). Two methodological points deserve emphasis.

First, the choice of the *subtype* `{ b // a = b }` for the based path space, rather
than a Σ-type, is forced by the universe placement of the identity type in a
proof-irrelevant foundation; this is a recurring subtlety when transcribing HoTT
idioms into Lean and is the reason the path-induction proof goes through by a single
`rintro ⟨b, rfl⟩`.

Second, the proof-irrelevance of `Prop` (Remark 3.4) means the development does not,
and cannot, distinguish higher h-levels; rather than a limitation, this is a precise
delineation of where the homotopical content lives. The same phenomenon explains why
the fibrewise characterisation (Theorem 5.1) is the natural stopping point: it is the
first statement that genuinely couples the two informative levels (−2 and −1) into a
single global invariant of a map. Everything downstream — the 2-out-of-3 calculus,
transport of structure, the long exact sequence of a fibration — is built on top of
this coupling, which is why we identified it as the cornerstone.

## 13. Conclusion

We have isolated and formally established the structural core of contractibility:
path spaces are contractible, the h-level hierarchy is closed under Σ, Π, and
retracts, equivalences are exactly the maps with contractible fibers, and a
contractible space is the unique terminal object of the homotopy category — a fact
with both a synthetic proof and a classical, topological realisation. The single idea
of "being a point up to homotopy" thereby organises path induction, the theory of
equivalences, and the universal property that anchors homotopy theory.
