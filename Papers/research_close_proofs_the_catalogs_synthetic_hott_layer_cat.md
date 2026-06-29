# The Fundamental Theorem of Identity Systems in a Data-Carrying Synthetic Homotopy Layer

## Abstract

We give a fully constructive proof of the **Fundamental Theorem of Identity
Systems** in a self-contained synthetic-homotopy fragment built on top of an
intensional dependent type theory with proof-irrelevant propositional equality.
An *identity system* based at a point `a₀` is a type family `R : A → Sort` equipped
with a reflexivity witness `rflR : R a₀` and a contractible total space
`Σ' a, R a` whose center is `(a₀, rflR)`. We prove that this data canonically
induces, for every `a : A`, an equivalence `(a₀ = a) ≃' R a` whose forward map is
transport of the reflexivity witness and whose inverse is extracted from the
contractibility witness of the total space. We then derive three structural
corollaries: (i) contractibility is invariant under equivalence
(`Equiv'.contractible`); (ii) the base fibre `R a₀` of any identity system is
contractible (`idSys_base_fiber_contractible`); and (iii) any two identity
systems based at the same point are fibrewise equivalent
(`idSys_unique`), which is the precise *homotopy-initiality* of the based path
family. A distinctive feature of the host foundation is that propositional
equality `Eq` is `Prop`-valued and hence a subsingleton (uniqueness of identity
proofs, UIP). This collapses one of the two coherence triangles of the
equivalence to a triviality and concentrates all homotopical content into a
single transport computation, which we discharge by `Σ'`-injectivity followed by
based path induction. All results are constructive and free of unverified
assumptions beyond propositional extensionality.

**Keywords:** identity system, homotopy type theory, contractibility, transport,
encode–decode, homotopy-initiality, uniqueness of identity proofs, equivalence.

---

## 1. Introduction

### 1.1 Motivation

A recurrent pattern across mathematics is the use of a *bespoke notion of
relatedness* in place of literal equality: isomorphism of algebraic structures,
observational equivalence of programs, indistinguishability of inputs under a
model. In each case one would like to import the reasoning principles of equality
— substitution, transport of structure, and the induction principle "to prove
something for all paths out of `a₀`, prove it for the trivial path" — and apply
them to the bespoke relation. The question this paper answers is exactly: *when is
a family of relationships `R a` interchangeable with the genuine identity family
`a₀ = a`?*

The **identity system** abstraction isolates the minimal data that guarantees
this interchangeability. Its governing result, the **Fundamental Theorem of
Identity Systems**, states that the data of a reflexivity witness together with a
contractible, correctly-centred total space is *necessary and sufficient* for `R`
to be fibrewise equivalent to the path family. This paper formalizes and proves
the sufficiency direction in full, together with its principal corollaries.

### 1.2 Setting

We work in a data-carrying synthetic-homotopy layer (`HoTTFound`) whose primitives
are recalled in Section 2. The key environmental fact is that propositional
equality `Eq` is valued in `Prop` and is therefore a *subsingleton*: any two
proofs of `a = b` are themselves equal (UIP / proof irrelevance for `Eq`). This
is *not* the univalent setting of Book HoTT, where identity types may be higher
groupoids; it is the pragmatic setting of a proof assistant with definitional
proof irrelevance for the equality type. The consequence, exploited throughout,
is that the *path side* of every equivalence we construct is automatically
0-truncated, which trivializes one of the two round-trip coherences.

### 1.3 Contributions

1. A constructive proof of `fundamentalIdentitySystem`: every identity system
   yields `(a₀ = a) ≃' R a`, with explicit `idSysEncode` / `idSysDecode` maps.
2. `Equiv'.contractible`: transport of a contractibility witness across a bespoke
   equivalence, completing the `Equiv'` API.
3. `idSys_base_fiber_contractible`: contractibility of the base fibre `R a₀`.
4. `idSys_unique`: fibrewise equivalence of any two identity systems based at the
   same point — the homotopy-initiality of the path family.
5. A compatibility check `fundamental_path_encode_rfl` tying the construction back
   to the canonical path identity system.

---

## 2. Preliminaries

We recall the primitives of the host layer.

### 2.1 Contractibility (data-carrying)

> **Definition 2.1 (`Contractible`).** A type `X : Sort u` is *contractible* if it
> is equipped with
> - a `center : X`, and
> - a function `contr : ∀ y : X, y = center`
>
> exhibiting every element as equal to the center.

Unlike a mere proposition `isContr`, this is a *structure carrying data*: the
center and the contraction are concrete and can be projected and computed with.

> **Lemma 2.2 (`contractible_subsingleton`).** If `X` is contractible then `X` is
> a subsingleton: for all `a b : X`, `a = b`.
>
> *Proof.* `a = center = b` by two applications of `contr`. ∎

> **Example 2.3 (based path space, `contractible_based_paths`).** For any `a₀ : A`,
> the based path space `Σ' x, a₀ = x` is contractible with center `(a₀, rfl)`.
>
> *Proof.* Given `(x, p)` with `p : a₀ = x`, based path induction on `p` reduces
> the goal to `(a₀, rfl) = (a₀, rfl)`, which is `rfl`. ∎

### 2.2 Equivalences (data-carrying)

> **Definition 2.4 (`Equiv'`).** An *equivalence* `α ≃' β` consists of maps
> `toFun : α → β` and `invFun : β → α` together with homotopies
> `left_inv : ∀ x, invFun (toFun x) = x` and
> `right_inv : ∀ y, toFun (invFun y) = y`.

This is the "bi-invertible/quasi-inverse" packaging with full computational
content. It supports the groupoid operations `refl`, `symm`, and `trans`:

- `refl α := ⟨id, id, λ_. rfl, λ_. rfl⟩`,
- `symm e := ⟨e.invFun, e.toFun, e.right_inv, e.left_inv⟩`,
- `trans e₁ e₂ := ⟨e₂.toFun ∘ e₁.toFun, e₁.invFun ∘ e₂.invFun, …⟩`,

with the round-trip homotopies of `trans` assembled from those of `e₁` and `e₂`.

### 2.3 Identity systems

> **Definition 2.5 (`IdentitySystem`).** An *identity system* on `A` based at
> `a₀ : A` with family `R : A → Sort v` consists of:
> - a reflexivity witness `rflR : R a₀`;
> - a contractibility witness `contr_total : Contractible (Σ' a, R a)`;
> - a centring equation `center_eq : contr_total.center = ⟨a₀, rflR⟩`.

> **Example 2.6 (`pathIdentitySystem`).** The path family `R a := (a₀ = a)` is an
> identity system, with `rflR := rfl`, `contr_total := contractible_based_paths a₀`,
> and `center_eq := rfl`.

The Fundamental Theorem will show Example 2.6 is, up to fibrewise equivalence, the
*only* identity system based at `a₀`.

---

## 3. The Fundamental Theorem

Fix `A : Sort u`, `a₀ : A`, `R : A → Sort v`, and an identity system
`S : IdentitySystem A a₀ R`.

### 3.1 The encode and decode maps

> **Definition 3.1 (`idSysEncode`).** For `a : A`,
> `idSysEncode S a : (a₀ = a) → R a` is defined by
>
> `idSysEncode S a p := p ▸ S.rflR`,
>
> i.e. transport of the reflexivity witness along the path `p`.

By based path induction `idSysEncode S a₀ rfl = S.rflR`, so encode is the
canonical comparison map sending the trivial path to the reflexivity witness.

> **Definition 3.2 (`idSysDecode`).** For `a : A`,
> `idSysDecode S a : R a → (a₀ = a)` is defined by, given `r : R a`,
>
> 1. forming the equality in the total space
>    `eq : (⟨a, r⟩ : Σ' x, R x) = ⟨a₀, S.rflR⟩`, obtained as
>    `(S.contr_total.contr ⟨a, r⟩).trans S.center_eq`
>    (every element equals the center, and the center equals `⟨a₀, rflR⟩`); then
> 2. returning `(congrArg PSigma.fst eq).symm`, the symmetrized projection of `eq`
>    onto first components.

Intuitively, decode reads the base path off the contractibility of the total
space.

### 3.2 Statement and proof

> **Theorem 3.3 (`fundamentalIdentitySystem`).** For every `a : A`,
> `idSysEncode S a` and `idSysDecode S a` constitute an equivalence
>
> `(a₀ = a) ≃' R a`.

*Proof.* We must supply the two round-trip homotopies.

**(left_inv) `decode ∘ encode = id` on `a₀ = a`.** The codomain of this composite
is the path space `a₀ = a`, which is `Prop`-valued and hence a subsingleton (UIP).
Therefore `idSysDecode S a (idSysEncode S a p) = p` holds by proof irrelevance
(`proof_irrel _ _`) with no further computation. This is the *free* triangle.

**(right_inv) `encode ∘ decode = id` on `R a`.** This triangle carries all the
content. Fix `r : R a`. Form the total-space equality
`eq : (⟨a, r⟩ : Σ' x, R x) = ⟨a₀, S.rflR⟩` exactly as in Definition 3.2. A naive
attempt to rewrite the goal directly along `eq` fails: the fibre component `r`
lives over the *moving* base point `a`, so substituting the raw `Σ'`-equality
produces an ill-typed motive ("motive is not type correct"). The fix is to split
`eq` into independent base and fibre components via the injectivity characterization
of pair equality `PSigma.mk.injEq`, obtaining

- a base path `hb : a = a₀`, and
- a heterogeneous fibre path `hf : HEq r S.rflR`.

Now `subst hb` anchors the base, after which the transports in `idSysEncode` /
`idSysDecode` compute, and the residual goal is closed using `eq_of_heq hf`
(`simp_all`). Concretely, after anchoring the base, decode's recovered path is a
proof of `a₀ = a₀` (a subsingleton, so definitionally the relevant `rfl` up to
proof irrelevance), transport along it is the identity, and `hf` identifies the
result with the original `r`. Hence `idSysEncode S a (idSysDecode S a r) = r`. ∎

The asymmetry of the two triangles is the methodological heart of the proof: UIP
makes the path-space triangle free and isolates the genuine homotopical work in a
single transport-and-recover step over the total space.

### 3.3 Compatibility with the canonical identity system

> **Proposition 3.4 (`fundamental_path_encode_rfl`).** For the path identity
> system of Example 2.6,
> `(fundamentalIdentitySystem (pathIdentitySystem a₀) a₀).toFun rfl = rfl`.
>
> *Proof.* By definition `idSysEncode` transports `rflR = rfl` along `rfl`, which
> is `rfl`; the equation holds definitionally. ∎

This certifies that the abstract construction reproduces the canonical
encode map on the motivating example.

---

## 4. Structural corollaries

### 4.1 Contractibility is invariant under equivalence

> **Theorem 4.1 (`Equiv'.contractible`).** If `e : α ≃' β` and `α` is contractible
> with center `c`, then `β` is contractible with center `e.toFun c`.
>
> *Proof.* Take `center := e.toFun (h.center)`. For `y : β`, we must show
> `y = e.toFun (h.center)`. Rewriting `y` as `e.toFun (e.invFun y)` via
> `e.right_inv y`, it suffices to show
> `e.toFun (e.invFun y) = e.toFun (h.center)`, which is
> `congrArg e.toFun (h.contr (e.invFun y))`. ∎

This is the missing functoriality lemma making `Contractible` an invariant of the
bespoke `Equiv'`, and it is the workhorse for the next corollary.

### 4.2 The base fibre is contractible

> **Theorem 4.2 (`idSys_base_fiber_contractible`).** For any identity system `S`
> on `A` based at `a₀`, the base fibre `R a₀` is contractible.
>
> *Proof.* The path space `a₀ = a₀` is contractible: take center `rfl`, and every
> `p : a₀ = a₀` equals `rfl` by proof irrelevance. Transport this contractibility
> across the fundamental equivalence `fundamentalIdentitySystem S a₀ : (a₀ = a₀) ≃'
> R a₀` using Theorem 4.1. ∎

Thus every identity system is "rigid at the basepoint": up to `R`, there is a
unique self-relationship, namely `rflR`.

### 4.3 Uniqueness of identity systems (homotopy-initiality)

> **Theorem 4.3 (`idSys_unique`).** Let `S : IdentitySystem A a₀ R` and
> `S' : IdentitySystem A a₀ R'` be identity systems based at the *same* point `a₀`,
> with possibly distinct families `R` and `R'`. Then for every `a : A`,
>
> `R a ≃' R' a`.
>
> *Proof.* Compose `(fundamentalIdentitySystem S a).symm : R a ≃' (a₀ = a)` with
> `fundamentalIdentitySystem S' a : (a₀ = a) ≃' R' a`. ∎

Concretely, the path family `(a₀ = a)` is a common hub through which every
identity system based at `a₀` factors. This is the precise sense in which the
based path family is **homotopy-initial**: it is *the* identity system at `a₀`, and
any other is a faithful fibrewise copy. There is no proliferation of competing
"equalities at a point."

---

## 5. Discussion

### 5.1 Where the content lives

The proof exhibits a clean separation of labor enforced by the foundation:

- **Subsingleton path side.** Because `Eq` is `Prop`-valued, the round-trip
  landing in `a₀ = a` is discharged by proof irrelevance. No transport algebra is
  required.
- **Total-space side.** All homotopical content is the single computation showing
  that transporting `rflR` along the path recovered from contractibility returns
  the original fibre element. The contractible total space supplies *exactly* the
  dependent path needed to identify `p ▸ rflR` with `r`.

This is a faithful, if 0-truncated, shadow of the full HoTT fundamental theorem,
in which the path side is itself a nontrivial type and both triangles carry
content. The present setting is the appropriate one for a proof assistant with
definitional proof irrelevance for equality.

### 5.2 The `motive is not type correct` obstruction

The recorded failure mode — rewriting along the raw `Σ'`-equality — is instructive
beyond this proof. Whenever a dependent witness sits over a base that the rewrite
would move, the induced motive is ill-typed. The general remedy is the one used
here: decompose the pair equality into a base path and a heterogeneous fibre path
(`PSigma.mk.injEq`), `subst` the base path to make transports compute, then close
the heterogeneous residue with `eq_of_heq`. This pattern is reusable across the
synthetic-homotopy layer.

### 5.3 Relationship to the catalog

The development completes a promissory note: the host `IdentitySystem` definition
advertised in its documentation that "this data yields an equivalence
`(a₀ = a) ≃' R a`", but supplied only the definitions. Theorem 3.3 supplies the
proof; Theorem 4.1 extends the `Equiv'` API; Theorems 4.2–4.3 are the structural
payoff. All results depend only on propositional extensionality.

---

## 6. Algorithms and computational content

Although the statements are about types, the data-carrying formulation means the
constructions are *executable* on decidable instances. We summarize them as
algorithms (Python realizations appear in the accompanying demo).

**Algorithm A (Encode).** Input: a path `p : a₀ = a`, the witness `rflR`. Output:
`p ▸ rflR : R a`. On discrete models a path exists only when `a = a₀`, in which
case transport is the identity, returning `rflR`.

**Algorithm B (Decode).** Input: `r : R a`, the contractibility witness of the
total space. Output: the base path obtained by projecting the equality
`(a,r) = center = (a₀, rflR)` onto first coordinates and symmetrizing.

**Algorithm C (Equivalence checker).** Given a finite identity system, verify
that encode and decode are mutually inverse by exhaustive enumeration of `(a₀ = a)`
and `R a` for each `a` — a direct, finite witness of Theorem 3.3.

**Algorithm D (Uniqueness composition).** Given two finite identity systems based
at `a₀`, build the fibrewise equivalence `R a ≃ R' a` by composing each side's
equivalence with the path family through the common hub.

---

## 6bis. A worked example end to end

To make the abstract construction concrete, we trace it on the simplest nontrivial
base type and then on a renamed copy, exhibiting both the Fundamental Theorem and
homotopy-initiality explicitly.

**The base.** Let `A = {a₀, a₁, a₂}` be a discrete (decidable) type with
basepoint `a₀`. Because equality on a discrete type is decidable and
`Prop`-valued, the path family `P a := (a₀ = a)` has exactly one inhabitant — the
reflexivity path `rfl` — when `a = a₀`, and is empty otherwise. Thus
`P a₀ = {rfl}`, while `P a₁ = P a₂ = ∅`.

**The total space.** The total space `Σ' a, P a` consists of all pairs `(a, p)`
with `p : a₀ = a`. The only such pair is `(a₀, rfl)`. Hence the total space is a
singleton, manifestly contractible, with center `(a₀, rfl)` — which is exactly the
required center `(a₀, rflR)` with `rflR = rfl`. This is `pathIdentitySystem a₀` of
Example 2.6, and it satisfies Definition 2.5 by construction.

**Encode/decode at each fibre.** For `a = a₀`: `idSysEncode` sends the unique path
`rfl` to `rfl ▸ rfl = rfl ∈ P a₀`, and `idSysDecode` sends the unique element
`rfl ∈ P a₀` back to the base path read off `(a₀, rfl) = (a₀, rfl)`, namely `rfl`.
The two maps are mutually inverse on a one-element set, trivially. For `a = a₁` or
`a = a₂`: both `P a` and `(a₀ = a)` are empty, so encode and decode are the unique
(vacuous) maps between empty sets, again mutually inverse. Theorem 3.3 therefore
holds fibrewise, and `fundamental_path_encode_rfl` records the salient equation
`encode(rfl) = rfl` at the basepoint.

**Base fibre.** `P a₀ = {rfl}` is a singleton, hence contractible with center
`rfl`; this is precisely Theorem 4.2 instantiated here, and it agrees with the
transport of contractibility of `a₀ = a₀` (also `{rfl}`) across the identity
equivalence.

**A renamed identity system and uniqueness.** Define a *different* family
`R' a := {(★, a)}` (a one-element fibre carrying a tag) when `a = a₀` and `∅`
otherwise, with `rflR' = (★, a₀)`. Its total space is again a singleton
`{(a₀, (★, a₀))}`, contractible with the required center, so `R'` is also an
identity system at `a₀`. Although `R'` is *syntactically distinct* from the path
family `P`, Theorem 4.3 produces a fibrewise equivalence `P a ≃' R' a` for every
`a`: at `a₀` it matches the single inhabitant `rfl` with the single inhabitant
`(★, a₀)`, and at `a₁, a₂` it is the empty equivalence. This is homotopy-initiality
in miniature: the path family is the canonical identity system, and `R'` is forced
to be a faithful copy of it. The accompanying `demo.py` verifies exactly this pair
by exhaustive enumeration, and a negative control (a 2-element base fibre) shows
the identity-system conditions genuinely fail when contractibility is violated.

The example also clarifies the proof's division of labor (Section 5): on each
fibre the path-space round-trip is forced by the fact that the relevant path sets
have at most one element (UIP), while the only computation with content is the
transport `p ▸ rflR`, which on the discrete model is the identity because the only
path is `rfl`.

## 7. Applications

- **Algebra / structure transport.** Replacing an object by an equivalent one and
  transporting all structure is precisely the use of an identity system; Theorem
  3.3 certifies the substitution is sound and explicit.
- **Programming-language semantics.** Observational equivalence presented as an
  identity system yields a verified license to substitute equals in any context.
- **Data and machine learning.** When a model induces an indistinguishability
  relation `R` on inputs, the identity-system test states exactly when the quotient
  may be reasoned about as literal equality, with an explicit translation and a
  uniqueness guarantee preventing inconsistent notions of "the same input."

---

## 8. Future work

1. **The full converse.** Sufficiency is proved here. The complete fundamental
   theorem is the bidirectional statement that a family `R` with `r₀ : R a₀` is an
   identity system *iff* the canonical map `(a₀ = a) → R a` is an equivalence for
   all `a`, *iff* the total space `Σ' a, R a` is contractible. The remaining two
   implications should be provable in the same data-carrying setting.
2. **Higher coherence.** Re-examine the construction in a univalent setting where
   the path side is not truncated, recovering both nontrivial triangles.
3. **Library integration.** Promote `Equiv'.contractible` and the
   `PSigma.mk.injEq`/`subst`/`eq_of_heq` transport pattern to reusable lemmas of
   the synthetic-homotopy layer.

---

## 9. Conclusion

We have given a complete, constructive proof of the Fundamental Theorem of
Identity Systems in a data-carrying synthetic-homotopy layer, together with the
invariance of contractibility under equivalence, the contractibility of the base
fibre, and the homotopy-initiality (uniqueness up to fibrewise equivalence) of the
based path family. The decisive structural observation is that proof irrelevance
for `Eq` trivializes the path-space coherence and localizes all homotopical
content into a single transport computation over the contractible total space.
The result turns the informal slogan "if your relation behaves like equality at a
point, it *is* equality there" into a theorem with explicit, executable
translations in both directions.
