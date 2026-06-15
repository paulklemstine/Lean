# The Fundamental Theorem of Identity Systems and Homotopy-Initial Families: A Data-Carrying Development

## Abstract

We present a complete, constructive development of the *Fundamental Theorem of
Identity Systems* in a synthetic Homotopy Type Theory (HoTT) fragment built on a
data-carrying notion of contractibility and a bespoke equivalence structure
`Equiv'` with full computational content. The central result states that any
*identity system* `(R, \mathrm{rflR}, c)` based at a point `a₀` — a relation
family `R` equipped with a reflexivity witness `\mathrm{rflR} : R\,a₀` and a
contractibility witness for the total space `Σ\,a, R\,a` centered at
`⟨a₀, \mathrm{rflR}⟩` — induces, for each point `a`, an equivalence
`(a₀ = a) \simeq R\,a`. The forward (encode) map is transport of the reflexivity
witness; the inverse (decode) map reads the base path off the contractibility
witness. We then prove a suite of structural results: invariance of
contractibility under equivalence, contractibility of the base fibre,
*homotopy-initiality* (uniqueness of identity systems up to fibrewise
equivalence), the **converse** (a fibrewise equivalence to the path family
characterizes identity systems), an induced **path-induction eliminator** with
its definitional computation rule, **closure under products**, and a **bridge**
exporting the fundamental equivalence to a standard library `Equiv`. The
recurring methodological discovery is that *transport of contractibility across
an equivalence* is the single reusable engine underlying the encode/decode
equivalence, the converse, the eliminator, and the closure properties; once the
appropriate `Σ`-congruence of total spaces is named, each result becomes a
one-line assembly. All results are fully formalized and constructive, depending
only on propositional extensionality (and the computation rule on no nontrivial
axiom at all).

**Keywords.** homotopy type theory, identity systems, fundamental theorem,
contractibility, equivalences, path induction, structure identity, formalization.

---

## 1. Introduction

### 1.1 Equality as structure

In Homotopy Type Theory the identity type `a = b` is understood not as a mere
truth value but as a *space* of identifications, with its own higher structure of
paths between paths. A pervasive engineering problem then arises: the
"native" identity type of a constructed object is rarely the relation one wants
to *compute* with. One prefers a tailored relation `R` — encoding equality of
records componentwise, equality of quotient elements via a chosen
representative invariant, equality of fractions via cross-multiplication, and so
on. The *Fundamental Theorem of Identity Systems* is the precise statement that
such a tailored `R` may legitimately stand in for the identity type, provided it
satisfies one global condition.

### 1.2 Contributions

This paper develops the theorem and its consequences in a deliberately
*data-carrying* style: contractibility and equivalence are recorded as
structures with computational content rather than as mere propositions. Our
contributions are:

1. **The Fundamental Theorem** (`fundamentalIdentitySystem`): an identity system
   yields a fibrewise equivalence `(a₀ = a) \simeq R\,a` (Section 4).
2. **Invariance of contractibility** under equivalence (`Equiv'.contractible`),
   the reusable engine for everything that follows (Section 3).
3. **Contractibility of the base fibre** and **homotopy-initiality**
   (`idSys_base_fiber_contractible`, `idSys_unique`) (Section 5).
4. **The converse / characterization** (`idSys_of_fiber_equiv`): a family
   fibrewise equivalent to the path family *is* an identity system (Section 6).
5. **An induced path-induction eliminator** with a definitional computation rule
   (`idSysElim`, `idSysElim_beta`) (Section 7).
6. **Closure under products** (`idSys_prod`) (Section 8).
7. **A bridge** exporting the equivalence to a standard `Equiv`
   (`fundamentalIdentitySystemEquiv`) (Section 9).

A guiding methodological theme — that all homotopical content funnels through one
contractibility-transport lemma — is discussed in Section 10.

---

## 2. Setting and definitions

We work in an intensional dependent type theory in which the identity type `Eq`
is proof-irrelevant (a definitional feature that validates Uniqueness of Identity
Proofs, UIP). We write `a = b` for the identity type, `rfl` for reflexivity,
`p ▸ x` for transport of `x` along `p`, and `Σ' a, R a` for the dependent sum
(total space) of a family `R`.

### Definition 2.1 (Contractibility, data-carrying)

A type `X` is **contractible** if it is equipped with:

> - a **center** `\mathrm{center} : X`, and
> - a **contraction** `\mathrm{contr} : ∀ y : X,\ y = \mathrm{center}`.

We write `Contractible X` for this structure. Unlike a Prop-valued formulation,
this records the center as extractable data.

### Definition 2.2 (Equivalence with computational content)

An **equivalence** `α \simeq β` (notation `Equiv' α β`) is:

> - a forward map `\mathrm{toFun} : α → β`,
> - an inverse map `\mathrm{invFun} : β → α`,
> - a **left inverse** law `\mathrm{left\_inv} : ∀ x,\ \mathrm{invFun}(\mathrm{toFun}\,x) = x`,
> - a **right inverse** law `\mathrm{right\_inv} : ∀ y,\ \mathrm{toFun}(\mathrm{invFun}\,y) = y`.

The identity, inverse, and composite equivalences (`Equiv'.refl`,
`Equiv'.symm`, `Equiv'.trans`) are defined in the obvious way and satisfy the
groupoid laws.

### Definition 2.3 (Identity system)

Let `A` be a type, `a₀ : A` a base point, and `R : A → \mathrm{Sort}` a family.
An **identity system** on `A` based at `a₀` with family `R` consists of:

> - a **reflexivity witness** `\mathrm{rflR} : R\,a₀`,
> - a contractibility witness `\mathrm{contr\_total} : Contractible (Σ'\,a, R\,a)`,
> - a centering equation `\mathrm{center\_eq} : \mathrm{contr\_total.center} = ⟨a₀, \mathrm{rflR}⟩`.

We write `IdentitySystem A a₀ R`. The centering equation is essential: it pins
the center of the total space to the reflexivity witness, which is exactly what
makes the encode/decode maps below mutually inverse.

### Proposition 2.4 (The motivating example: the based path family)

For any `a₀ : A`, the based path space `Σ'\,x, (a₀ = x)` is contractible with
center `⟨a₀, \mathrm{rfl}⟩`: given `⟨x, p⟩`, path induction on `p` reduces the
goal to `⟨a₀, \mathrm{rfl}⟩ = ⟨a₀, \mathrm{rfl}⟩`. Hence
`R\,a := (a₀ = a)` together with `\mathrm{rflR} := \mathrm{rfl}` and this
contractibility witness forms an identity system `pathIdentitySystem a₀`. This is
the canonical identity system that all others will turn out to copy.

---

## 3. Contractibility transports across equivalences

The following lemma is the load-bearing tool of the entire paper.

### Lemma 3.1 (`Equiv'.contractible`)

If `e : α \simeq β` and `α` is contractible, then `β` is contractible.

**Construction.** Take the new center to be `e.\mathrm{toFun}(h.\mathrm{center})`.
For the contraction, given `y : β`, rewrite the goal using
`e.\mathrm{right\_inv}\,y : e.\mathrm{toFun}(e.\mathrm{invFun}\,y) = y` so that it
becomes a statement about `e.\mathrm{toFun}(e.\mathrm{invFun}\,y)`, then apply
`\mathrm{congrArg}\,e.\mathrm{toFun}` to the contraction
`h.\mathrm{contr}(e.\mathrm{invFun}\,y) : e.\mathrm{invFun}\,y = h.\mathrm{center}`.
∎

This lemma says that "essentially a point" is an invariant of equivalence, and —
crucially — it is *data*: it produces an explicit center and contraction in the
codomain. Every later result is an instance of pushing contractibility across a
carefully chosen equivalence of total spaces.

---

## 4. The Fundamental Theorem

Fix an identity system `S : IdentitySystem A a₀ R`.

### Definition 4.1 (Encode)

`idSysEncode S a : (a₀ = a) → R\,a` is defined by `p ↦ p ▸ S.\mathrm{rflR}`:
transport the reflexivity witness along the path.

### Definition 4.2 (Decode)

`idSysDecode S a : R\,a → (a₀ = a)` is defined by sending `r : R a` to the base
path extracted from the contractibility witness. Concretely, the equation

```
eq : ⟨a, r⟩ = ⟨a₀, S.rflR⟩
   := (S.contr_total.contr ⟨a, r⟩).trans S.center_eq
```

holds in `Σ'\,x, R\,x` (both sides equal the center), and
`(\mathrm{congrArg}\ \mathrm{PSigma.fst}\ \mathrm{eq}).\mathrm{symm}` is the
desired `a₀ = a`.

### Theorem 4.3 (Fundamental Theorem of Identity Systems, `fundamentalIdentitySystem`)

For every `a : A`, `idSysEncode` and `idSysDecode` are mutually inverse; hence

$$ (a_0 = a) \;\simeq\; R\,a. $$

**Proof sketch.** The two inverse laws decompose as follows.

- **Left inverse** (`(a₀ = a)`-triangle): for `p : a₀ = a` we must show
  `idSysDecode S a (idSysEncode S a p) = p`. Both sides are inhabitants of
  `a₀ = a`, which is proof-irrelevant; the law is therefore `proof_irrel _ _`,
  *free of homotopical content*.

- **Right inverse** (fibre triangle): for `r : R a` we must show
  `idSysEncode S a (idSysDecode S a r) = r`. Form the total-space equality
  `eq : ⟨a, r⟩ = ⟨a₀, S.rflR⟩` as in Definition 4.2. A naive rewrite fails with a
  *motive-not-type-correct* error because the fibre lives over the moving base
  point. The remedy is to split `eq` with `PSigma.mk.injEq` into a base path
  `hb : a = a₀` and a heterogeneous fibre path `hf`, then `subst hb` so that all
  transports compute; `simp_all` finishes using `eq_of_heq hf`. ∎

This is the central result: an identity system makes `R` indistinguishable, fibre
by fibre, from the based path family.

### Sanity check 4.4 (`fundamental_path_encode_rfl`)

For the path identity system `pathIdentitySystem a₀` (Proposition 2.4), the
fundamental equivalence at `a₀` sends `rfl` to `rfl` *definitionally*: the encode
map specializes to the canonical comparison map. This confirms the theorem
restricts correctly to the motivating example.

---

## 5. First corollaries

### Corollary 5.1 (`idSys_base_fiber_contractible`)

In any identity system `S`, the base fibre `R\,a₀` is contractible.

**Proof.** The self-identity type `a₀ = a₀` is contractible (center `rfl`,
contraction by `proof_irrel`). Transport this contractibility across
`fundamentalIdentitySystem S a₀ : (a₀ = a₀) \simeq R\,a₀` using Lemma 3.1. ∎

There is, up to the canonical identification, exactly one certificate that `a₀`
relates to itself.

### Corollary 5.2 (Homotopy-initiality, `idSys_unique`)

If `S : IdentitySystem A a₀ R` and `S' : IdentitySystem A a₀ R'` are two identity
systems based at the same point, then for every `a`,

$$ R\,a \;\simeq\; R'\,a. $$

**Proof.** Compose `(fundamentalIdentitySystem S a).\mathrm{symm} : R\,a \simeq (a₀ = a)`
with `fundamentalIdentitySystem S' a : (a₀ = a) \simeq R'\,a`. ∎

Identity systems based at a point are unique up to fibrewise equivalence: the
based path family is *homotopy-initial*, the universal such structure, and every
other identity system is a faithful copy of it.

---

## 6. The converse and the characterization

### Lemma 6.1 (`Σ`-congruence, `Equiv'.psigmaCongr`)

A fibrewise family of equivalences `e : ∀ a,\ P\,a \simeq Q\,a` assembles into a
single equivalence of total spaces

$$ \big(Σ'\,a, P\,a\big) \;\simeq\; \big(Σ'\,a, Q\,a\big), $$

acting as the identity on the base and as `e a` on each fibre. The roundtrip laws
follow fibrewise from those of each `e a`.

### Theorem 6.2 (Converse, `idSys_of_fiber_equiv`)

If `e : ∀ a,\ (a₀ = a) \simeq R\,a` is a fibrewise equivalence to the based path
family, then `R` is an identity system based at `a₀`, with reflexivity witness
`(e\,a₀).\mathrm{toFun}\,\mathrm{rfl}`.

**Proof sketch.** Take `\mathrm{rflR} := (e\,a₀).\mathrm{toFun}\,\mathrm{rfl}`.
The total-space contractibility is obtained by transporting the contractibility
of the based path space `Σ'\,a, (a₀ = a)` (Proposition 2.4) across the assembled
equivalence `Equiv'.psigmaCongr e` (Lemma 6.1) via Lemma 3.1. The center lands on
`⟨a₀, (e\,a₀).\mathrm{toFun}\,\mathrm{rfl}⟩`, which is exactly `⟨a₀, \mathrm{rflR}⟩`,
so the centering equation holds by `rfl`. ∎

### Corollary 6.3 (Characterization)

Combining Theorem 4.3 and Theorem 6.2: a family `R` with a designated witness is
an identity system based at `a₀` **if and only if** it is fibrewise equivalent to
the based path family `a₀ = (\cdot)`. The global condition (contractibility of the
total space) and the local condition (fibrewise equivalence) coincide.

---

## 7. The induced eliminator (path induction for `R`)

The native identity type admits *path induction* (`Eq.rec`): to construct a
section of any motive over `a₀ = (\cdot)` it suffices to give its value on `rfl`.
We show every identity system inherits the analogous principle.

### Lemma 7.1 (Transport along a loop is the identity, `mpr_congr_loop`)

For any `D : X → \mathrm{Sort}`, `x : X`, `d : D x`, and any *loop* `pf : x = x`,

$$ \mathrm{Eq.mpr}\,(\mathrm{congrArg}\ D\ pf)\ d = d. $$

**Proof.** By proof irrelevance `pf = \mathrm{rfl}`; substitute and reduce. ∎

### Definition 7.2 (Induced eliminator, `idSysElim`)

Let `S : IdentitySystem A a₀ R`, `D : (a : A) → R\,a → \mathrm{Sort}` a motive,
and `d : D\,a₀\,S.\mathrm{rflR}` a base case. Define, for `a : A` and `r : R a`,

$$ idSysElim\ S\ D\ d\ a\ r \;:=\; \mathrm{Eq.mpr}\big(\mathrm{congrArg}\,(\lambda s.\ D\,s.1\,s.2)\ \mathrm{eq}\big)\ d, $$

where `eq : ⟨a, r⟩ = ⟨a₀, S.\mathrm{rflR}⟩` is the total-space equality from the
contractibility witness. (A direct `pf ▸ d` is rejected — *motive not type
correct* — because the fibre lives over the moving base; transporting in the
*total space*, where the motive is a genuine function of the pair, repairs this.)

### Theorem 7.3 (Computation rule, `idSysElim_beta`)

$$ idSysElim\ S\ D\ d\ a₀\ S.\mathrm{rflR} = d. $$

**Proof.** At the reflexivity witness the relevant total-space equality is a loop
`⟨a₀, \mathrm{rflR}⟩ = ⟨a₀, \mathrm{rflR}⟩`; apply Lemma 7.1 with the explicit
motive `\lambda s.\ D\,s.1\,s.2`. ∎

Thus each identity system carries its own dependent eliminator that reduces to
the base case on the reflexivity witness, exactly as `Eq.rec` reduces on `rfl`.
Notably, the computation rule depends on no nontrivial axiom.

---

## 8. Closure under products

### Lemma 8.1 (Product of contractibles, `Contractible.prod`)

If `X` and `Y` are contractible then so is `X × Y`, with center the pair of
centers and contraction componentwise.

### Lemma 8.2 (`Σ`-distribution, `Equiv'.sigmaProd`)

For families `P` over `A` and `P'` over `A'`,

$$ \big(Σ'\,p : A × A',\ P\,p.1 × P'\,p.2\big) \;\simeq\; \big(Σ'\,a, P\,a\big) × \big(Σ'\,a', P'\,a'\big), $$

a regrouping of a dependent sum over a product base into a product of dependent
sums.

### Theorem 8.3 (Closure under products, `idSys_prod`)

If `S : IdentitySystem A a₀ R` and `S' : IdentitySystem A' a₀' R'`, then

$$ \lambda (p : A × A').\ R\,p.1 × R'\,p.2 $$

is an identity system on `A × A'` based at `(a₀, a₀')`.

**Proof sketch.** The product total space is contractible: by Lemma 8.2 it is
equivalent to the product of the two component total spaces, each contractible by
hypothesis; the product is contractible by Lemma 8.1; transport back across the
equivalence by Lemma 3.1. The reflexivity witness is the pair of reflexivity
witnesses, and the centering equation follows. ∎

The construction again reduces to "name the right `Σ`-equivalence, then push
contractibility across it."

---

## 9. The bridge to a standard equivalence API

The bespoke `Equiv'` is kept deliberately independent of any library equivalence
type so that the HoTT development stands alone. For interoperability we provide a
forgetful bridge.

### Definition 9.1 (`Equiv'.toEquiv`)

For `α β : \mathrm{Type}`, an `Equiv' α β` repackages definitionally as a standard
`Equiv α β` (`α ≃ β`): the forward and inverse maps transfer verbatim, and the
two roundtrip laws `left_inv`/`right_inv` are exactly the library's
`left_inv`/`right_inv`.

### Theorem 9.2 (`fundamentalIdentitySystemEquiv`)

For an identity system `S` on a type `A` and any `a : A`,

$$ (a₀ = a) \;\simeq\; R\,a $$

holds as a *standard* `Equiv`, obtained by applying `Equiv'.toEquiv` to
Theorem 4.3.

This makes every result of the development importable into mainstream library
code — transport, `Equiv.subsingleton`, and the rest — at essentially zero
marginal proof cost, since the bridge is a definitional repackaging on `Type`.

---

## 10. Discussion: one engine, many theorems

The most striking structural feature of this development is the *uniformity* of
its proofs. After Lemma 3.1, virtually every theorem follows the same three-step
recipe:

1. **Name a `Σ`-equivalence** between the total space of interest and a total
   space whose contractibility is already known (`Equiv'.psigmaCongr`,
   `Equiv'.sigmaProd`).
2. **Push contractibility across it** with `Equiv'.contractible`.
3. **Read off the center** to obtain the centering data.

The converse (Theorem 6.2) and product closure (Theorem 8.3) are literal
instances. The eliminator (Section 7) is the same idea applied pointwise:
transport the base datum along the contractibility-derived equality, with the
computation rule "free" because transport along a base loop is the identity
(Lemma 7.1) — the very same proof-irrelevance phenomenon that made the left
inverse of Theorem 4.3 free.

This concentration of content has a practical upshot: extending the theory (new
closure properties, new examples) reduces to producing the appropriate
`Σ`-congruence, after which the homotopical work is already done. The
data-carrying style ensures these assemblies produce explicit centers, inverse
maps, and computation behavior rather than mere existence statements.

A second observation concerns the role of proof irrelevance. Because the ambient
identity type is proof-irrelevant (UIP holds), the *path side* of every
fundamental equivalence is automatically a subsingleton. This trivializes one of
the two triangles in Theorem 4.3 and makes the eliminator's computation rule hold
definitionally. The price is that this particular development cannot distinguish
higher path structure — it is a *set-level* account of identity systems. A
genuinely higher version (in a setting without UIP, with `Eq` replaced by a
`Type`-valued path type eliminated only by path induction) is the natural
sequel; there the converse round-trips require honest higher-path bookkeeping
rather than `proof_irrel`.

---

## 11. Applications

- **Custom equality for constructed types.** To equip a record, quotient, or
  inductive type with a convenient equality relation `R`, prove once that `R` is
  an identity system. By Theorem 4.3 one obtains `(a₀ = a) \simeq R\,a`; by
  Theorem 7.3 a custom induction principle; by Corollary 5.2 uniqueness.
- **Characterization of equality in Σ- and product types.** Theorem 8.3 (and the
  analogous Σ closure) shows the equality of a product is the product of the
  component equalities, recovering the standard "equality lemmas" uniformly.
- **Library interoperability.** Theorem 9.2 exports the equivalence to the
  standard `Equiv` API, so downstream developments (topology, algebra, category
  theory) can consume identity-system results without knowledge of the bespoke
  `Equiv'`.

---

## 12. Related work

The notion of identity system and the fundamental theorem are standard in the
HoTT literature, where the theorem typically appears as the statement that a
pointed family is an identity system iff its total space is contractible iff the
canonical map is a fibrewise equivalence. Our contribution is a self-contained,
fully constructive, *data-carrying* formalization that (i) isolates
contractibility-transport as the single reusable engine, (ii) supplies the
induced eliminator with a definitional computation rule, (iii) establishes the
converse and product closure as one-line `Σ`-equivalence assemblies, and (iv)
bridges to a mainstream equivalence API.

---

## 13. Conclusion and future work

We have given a complete account of the Fundamental Theorem of Identity Systems
together with its converse, an induced path-induction eliminator, product
closure, and a library bridge, all from a single contractibility-transport
lemma. The development is fully constructive and depends only on propositional
extensionality.

Several directions remain open and are detailed in the accompanying future-work
record. Chief among them: a **structure identity principle** for the
proof-irrelevant universe `HProp'` (logical equivalence of h-propositions should
upgrade unconditionally to type equivalence, and to honest equality under
propositional univalence); **further closure properties** (pullbacks, dependent
sums); and a **genuinely higher** development replacing `Eq` by a `Type`-valued
path type, where UIP fails and the homotopical content of the round-trips becomes
visible. The uniformity uncovered here — that everything is contractibility
pushed across a `Σ`-equivalence — suggests these extensions will again reduce to
naming the right congruence.
