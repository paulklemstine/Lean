# Stone Duality as a Bridge Between Logic and Topology: A Formally Verified Object-Level Representation Theorem

## Abstract

We present a complete, machine-verified development of the object-level core of
**Stone duality**: for every Boolean algebra `B`, the canonical *Stone map*
exhibits `B` as the Boolean algebra of clopen subsets of its *Stone space*. The
decisive design choice is to realize the Stone space not through order-theoretic
ultrafilters — which would require a hand-built Boolean prime ideal theorem via
Zorn's lemma — but as the **prime spectrum of the associated Boolean ring**,
`StoneSpace B := PrimeSpectrum (AsBoolRing B)`. This reframing imports a mature
commutative-algebra spectrum theory: the Zariski topology, the basic-open basis,
compactness of the spectrum, and the characterization of compact opens. We prove
(i) that every basic open `D(r)` of a Boolean-ring spectrum is clopen, with
explicit complement `D(1+r)`; (ii) that the Stone map `b ↦ D(b)` is a
Boolean-algebra homomorphism; (iii) that it is injective, via the
non-nilpotence of nonzero Boolean-ring elements (the representation theorem);
(iv) that it is surjective onto clopens, via compactness ("every clopen is a
finite, hence single, basic open"); and (v) that, assembled, these yield an
order isomorphism `B ≃o Clopens (StoneSpace B)`. Every result is `sorry`-free
and rests only on the standard foundational axioms `propext`,
`Classical.choice`, and `Quot.sound`. We discuss the role of the Boolean
algebra/Boolean ring bridge, the proof architecture, and the path to the full
categorical duality.

**Keywords.** Stone duality, Boolean algebra, Boolean ring, prime spectrum,
clopen sets, representation theorem, compactness, formal verification.

---

## 1. Introduction

Marshall H. Stone's 1936 representation theorem and its 1937 topological
refinement established one of the founding *dualities* of modern mathematics: an
exact, arrow-reversing correspondence between **Boolean algebras** (the algebra
of classical propositional logic) and **Stone spaces** (compact, Hausdorff,
totally disconnected topological spaces). The object-level heart of the theory
is the statement that *every Boolean algebra is isomorphic to the algebra of
clopen subsets of a topological space*. This is simultaneously a
*representation* theorem (abstract Boolean algebras are concrete algebras of
sets) and the foundation of a *categorical* duality.

This paper documents a formal verification of that object-level core. Our
contribution is twofold:

1. **A complete formal proof** of the Stone representation/duality isomorphism
   `B ≅ Clopens(StoneSpace B)`, with all lemmas verified and no unproven gaps.
2. **A reusable architectural pattern**: by defining the Stone space as the
   prime spectrum of the associated Boolean ring, we reduce a deep
   order-theoretic theorem to a short sequence of commutative-algebra lemmas,
   thereby inheriting compactness, the basic-open basis, and the
   compact-open characterization "for free."

The remainder of the paper fixes definitions (§2), states and sketches the
clopenness lemmas (§3), the homomorphism property (§4), injectivity (§5),
surjectivity (§6), and the final isomorphism (§7), then discusses methodology
(§8), applications (§9), and future work (§10).

---

## 2. Definitions and setup

### 2.1 Boolean algebras and Boolean rings

A **Boolean algebra** is a complemented distributive lattice `(B, ⊓, ⊔, ᶜ, ⊥,
⊤)`. A **Boolean ring** is a (commutative, unital) ring `R` in which every
element is idempotent: `r · r = r` for all `r`. Idempotence forces
characteristic 2: from `(r + r) = (r + r)²` one derives `r + r = 0`, so `-r = r`.

These two notions are *equivalent categories*, via mutually inverse functors
that we denote `AsBoolRing` (algebra → ring) and the order side
(`ofBoolRing`/`toBoolRing` for the underlying-element translation):

- **From algebra to ring.** Multiplication is meet, `r · s := r ⊓ s`; addition
  is symmetric difference, `r + s := (r ⊓ sᶜ) ⊔ (rᶜ ⊓ s)`; the unit is `⊤` and
  the zero is `⊥`.
- **From ring to algebra.** Meet is multiplication, `r ⊓ s := r · s`; join is
  `r ⊔ s := r + s + r·s`; complement is `rᶜ := 1 + r`; bottom is `0`, top is
  `1`.

We write `toBoolRing : B → AsBoolRing B` for the (bijective) element-level
translation. Key arithmetic identities we use:
`toBoolRing (a ⊓ b) = toBoolRing a · toBoolRing b`, `toBoolRing aᶜ =
toBoolRing a + 1`, and the join law `toBoolRing(a ⊔ b) = f + g + f·g` with
`f = toBoolRing a`, `g = toBoolRing b`.

### 2.2 The prime spectrum and basic opens

For a commutative ring `R`, the **prime spectrum** `PrimeSpectrum R` is the set
of prime ideals, topologized by the *Zariski topology* whose basic opens are

> `D(r) := { p ∈ PrimeSpectrum R : r ∉ p }`,  for `r ∈ R`.

Standard spectrum facts we invoke:

- `D(r) ∩ D(s) = D(r·s)` (`basicOpen_mul`);
- `D(r) = ∅ ⇔ r` is nilpotent (`basicOpen_eq_bot_iff`);
- `PrimeSpectrum R` is **compact** (`CompactSpace`);
- a subset is compact-open iff it is a finite union of basic opens
  (`isCompact_isOpen_iff` / the basic-open basis).

### 2.3 The Stone space and the Stone map

> **Definition 2.1 (Stone space).** For a Boolean algebra `B`,
> `StoneSpace B := PrimeSpectrum (AsBoolRing B)`.

`AsBoolRing B` is a Boolean ring, so `StoneSpace B` carries the Zariski topology
and is compact.

> **Definition 2.2 (clopen algebra).** `Clopens X` is the Boolean algebra of
> clopen (simultaneously open and closed) subsets of a topological space `X`,
> ordered by inclusion, with `⊓` = intersection, `⊔` = union, `ᶜ` = complement,
> `⊥ = ∅`, `⊤ = X`.

> **Definition 2.3 (Stone map).** `stoneClopen : B → Clopens (StoneSpace B)` is
> `b ↦ ⟨D(toBoolRing b), isClopen_basicOpen _⟩`. Its underlying set is
> `D(toBoolRing b)`.

The well-definedness of Definition 2.3 — that `D(r)` is genuinely clopen — is
the content of §3.

---

## 3. Basic opens of a Boolean-ring spectrum are clopen

Throughout this section `R` is a Boolean ring and `r ∈ R`.

> **Lemma 3.1 (complement of a basic open).**
> `(D(r))ᶜ = D(1 + r)` as subsets of `PrimeSpectrum R`.

*Proof sketch.* Two arithmetic facts drive the proof:
`r · (1 + r) = r + r² = r + r = 0` and `r + (1 + r) = 1`. Fix a prime `p`.
Since `r·(1+r) = 0 ∈ p` and `p` is prime, `r ∈ p` or `1 + r ∈ p`. They cannot
both lie in `p`: otherwise their sum `1 ∈ p`, making `p` the unit ideal,
contradicting primeness. Hence exactly one of `r, 1+r` lies in `p`, i.e. `p` is
in exactly one of `D(r)`, `D(1+r)`. Therefore `D(1+r)` is the set-complement of
`D(r)`. ∎

> **Lemma 3.2 (basic opens are clopen).** `D(r)` is clopen in `PrimeSpectrum R`.

*Proof sketch.* `D(r)` is open as a basic open. By Lemma 3.1 its complement is
`D(1+r)`, also open; hence `D(r)` is closed. Being both, it is clopen. ∎

Lemma 3.2 makes Definition 2.3 type-correct and is the structural reason the
Stone space is totally disconnected: it has a basis of clopen sets.

We also record the join law, needed in §4 and §6:

> **Lemma 3.3 (union of basic opens).**
> `D(f) ∪ D(g) = D(f + g + f·g)`.

*Proof sketch.* `⊇`: if a prime `p` omits `f + g + f·g`, it cannot contain both
`f` and `g` (else it would contain the combination), so `p ∈ D(f) ∪ D(g)`.
`⊆`: if `p` omits `f`, then since `f·(f + g + f·g) = f` (a Boolean-ring
computation: `f² = f`, `f² g = fg`, and `f + f = 0` cancel to leave `f`), the
element `f + g + f·g` cannot lie in `p` either, lest `f ∈ p`; symmetrically for
`g`. Hence `p ∈ D(f + g + f·g)`. ∎

The exponent-2 cancellation `f·(f + g + f·g) = f² + fg + f²g = f + fg + fg = f`
is the crux; the two `fg` terms annihilate because `R` has characteristic 2.

---

## 4. The Stone map is a Boolean-algebra homomorphism

We show `stoneClopen` preserves the full Boolean signature. Write `D(b)` for
`D(toBoolRing b)`.

> **Theorem 4.1 (homomorphism).** For all `a, b ∈ B`:
>
> 1. `stoneClopen ⊥ = ⊥`  (i.e. `D(⊥) = ∅`);
> 2. `stoneClopen ⊤ = ⊤`  (i.e. `D(⊤) = X`);
> 3. `stoneClopen (a ⊓ b) = stoneClopen a ⊓ stoneClopen b`;
> 4. `stoneClopen (a ⊔ b) = stoneClopen a ⊔ stoneClopen b`;
> 5. `stoneClopen aᶜ = (stoneClopen a)ᶜ`.

*Proof sketch.*
(1) `toBoolRing ⊥ = 0` and `D(0) = ∅` since `0` is nilpotent.
(2) `toBoolRing ⊤ = 1` and `D(1) = X` (`1` lies in no prime ideal).
(3) `toBoolRing(a ⊓ b) = toBoolRing a · toBoolRing b`, and
`D(r·s) = D(r) ∩ D(s)` (`basicOpen_mul`); intersection of clopens is the meet in
`Clopens`.
(4) By the algebra/ring dictionary `toBoolRing(a ⊔ b) = f + g + f·g`
(with `f = toBoolRing a`, `g = toBoolRing b`), so Lemma 3.3 gives
`D(a ⊔ b) = D(f) ∪ D(g) = D(a) ∪ D(b)`, the join in `Clopens`. The identity
`toBoolRing(a ⊔ b) = f + g + f·g` follows from
`a ⊔ b = (a △ b) △ (a ⊓ b)` (symmetric-difference expansion of join).
(5) `toBoolRing aᶜ = toBoolRing a + 1`. For a prime `p`, `aᶜ ∈ D(·)` iff
`toBoolRing a + 1 ∉ p`. Using Lemma 3.1 with `r = toBoolRing a`,
`D(toBoolRing a + 1) = D(toBoolRing a)ᶜ`, which is exactly the complement of
`stoneClopen a` in `Clopens`. (Equivalently: `toBoolRing a · toBoolRing aᶜ =
toBoolRing(a ⊓ aᶜ) = toBoolRing ⊥ = 0`, so the two basic opens are disjoint and
cover `X`.) ∎

Theorem 4.1 says the Stone map is a morphism in the category of Boolean
algebras; combined with §5–§6 it is an isomorphism.

---

## 5. Injectivity: the Stone representation theorem

The injectivity of the Stone map is precisely Stone's representation theorem: an
abstract Boolean algebra embeds into a concrete field of sets.

> **Lemma 5.1 (nonzero elements are non-nilpotent; nonempty basic opens).**
> If `r ∈ R` with `r ≠ 0`, then `r` is not nilpotent, and consequently
> `D(r) ≠ ∅`; i.e. there exists a prime ideal `p` with `r ∉ p`.

*Proof sketch.* In a Boolean ring `rⁿ = r` for all `n ≥ 1` (immediate from
`r² = r` by induction). So if `rⁿ = 0` for some `n ≥ 1`, then `r = 0`,
contradicting `r ≠ 0`. Thus `r` is not nilpotent. By `basicOpen_eq_bot_iff`,
`D(r) = ∅ ⇔ r` nilpotent, so `D(r) ≠ ∅`; choose any point of it. ∎

> **Theorem 5.2 (injectivity).** `stoneClopen : B → Clopens (StoneSpace B)` is
> injective.

*Proof sketch.* It suffices to show `stoneClopen` reflects `⊥`: a Boolean
homomorphism is injective iff its kernel (preimage of `⊥`) is trivial. Suppose
`a ≠ b`. Then `a △ b = (a ⊓ bᶜ) ⊔ (b ⊓ aᶜ) ≠ ⊥`, so at least one of
`a ⊓ bᶜ`, `b ⊓ aᶜ` is `≠ ⊥`; say `c := a ⊓ bᶜ ≠ ⊥`. Then
`toBoolRing c ≠ 0`, so by Lemma 5.1 there is a prime `p` with
`toBoolRing c ∉ p`, i.e. `p ∈ D(c) = D(a) ∩ D(b)ᶜ` (using Theorem 4.1(3),(5)).
Thus `p ∈ stoneClopen a` but `p ∉ stoneClopen b`, so
`stoneClopen a ≠ stoneClopen b`. ∎

Lemma 5.1 is the existential core — the only place where "points are
manufactured." In the ultrafilter approach this is the Boolean prime ideal
theorem; in the spectrum approach it is a one-line consequence of idempotence
plus the existing `basicOpen_eq_bot_iff`.

---

## 6. Surjectivity: every clopen is a basic open

> **Theorem 6.1 (clopens are basic opens).** For `R` a Boolean ring, every
> clopen `K ⊆ PrimeSpectrum R` equals `D(r)` for some `r ∈ R`.

*Proof sketch.* `PrimeSpectrum R` is **compact**. A clopen set `K` is closed in
a compact space, hence compact; it is also open. A compact open subset of a
spectrum is a *finite* union of basic opens (the basic opens form a basis, and
compactness extracts a finite subcover): `K = D(r₁) ∪ … ∪ D(rₙ)`. By Lemma 3.3,
finite unions of basic opens are again basic opens — inductively,
`D(r₁) ∪ … ∪ D(rₙ) = D(s)` where `s` is the iterated Boolean join
`r₁ ⊔ ⋯ ⊔ rₙ` in `R` (`s_{k+1} = s_k + r_{k+1} + s_k·r_{k+1}`). The empty union
is `D(0) = ∅`. Hence `K = D(s)`. ∎

> **Theorem 6.2 (surjectivity).** `stoneClopen` is surjective onto
> `Clopens (StoneSpace B)`.

*Proof sketch.* Given a clopen `K`, Theorem 6.1 yields `r ∈ AsBoolRing B` with
`K = D(r)`. Since `toBoolRing : B → AsBoolRing B` is a bijection, write
`r = toBoolRing b`; then `stoneClopen b = ⟨D(r), _⟩ = K`. ∎

---

## 7. The Stone isomorphism

Combining the previous sections:

> **Theorem 7.1 (Stone duality, object form).** For every Boolean algebra `B`,
> the Stone map underlies an **order isomorphism**
> `stoneOrderIso : B ≃o Clopens (StoneSpace B)`.

*Proof sketch.* By Theorem 4.1 `stoneClopen` is a Boolean-algebra homomorphism;
by Theorems 5.2 and 6.2 it is a bijection. A bijective Boolean homomorphism is a
Boolean isomorphism, and in particular monotone with monotone inverse (it
preserves `⊓`, hence `≤`, in both directions: `a ≤ b ⇔ a ⊓ b = a ⇔
stoneClopen a ⊓ stoneClopen b = stoneClopen a ⇔ stoneClopen a ≤ stoneClopen b`).
Packaging the bijection with this order equivalence yields `B ≃o
Clopens (StoneSpace B)`. ∎

Theorem 7.1 is the formally verified statement that *every Boolean algebra is
the clopen algebra of its Stone space* — the object-level content of Stone
duality.

### 7.1 Verification status

All statements in §3–§7 are formalized and proved with no `sorry`. The
development depends only on the foundational axioms `propext`,
`Classical.choice`, and `Quot.sound` (the standard classical-logic kernel),
together with Mathlib's commutative-algebra and topology libraries.

---

## 8. Methodology and proof architecture

### 8.1 The pivotal definition

The single most consequential decision is **Definition 2.1**: realizing the
Stone space as `PrimeSpectrum (AsBoolRing B)` rather than as a space of
ultrafilters/prime order-ideals. The payoff is structural reuse:

| Needed fact | Classical (order) route | Spectrum route |
|---|---|---|
| Topology with clopen basis | build from filters | Zariski topology (free) |
| Compactness | prove via ultrafilter lemma | `CompactSpace` of spectrum (free) |
| Existence of separating points | Boolean prime ideal theorem (Zorn) | `basicOpen_eq_bot_iff` + idempotence |
| Compact-open = finite union of basics | hand-rolled | basis + compactness (free) |

The Boolean prime ideal theorem — the hardest classical ingredient — is replaced
by the elementary observation that idempotents are non-nilpotent (Lemma 5.1).

### 8.2 The "modulo 2" toolkit

Three Boolean-ring identities recur and account for nearly all the algebra:

1. `r² = r` (idempotence), hence `rⁿ = r` and "no nonzero nilpotents."
2. `r + r = 0` (characteristic 2), which collapses cross terms, e.g.
   `f·(f + g + f·g) = f`.
3. `r·(1+r) = 0` and `r + (1+r) = 1`, giving the clopen complement `D(1+r)`.

### 8.3 Logic-side vs. topology-side division of labor

The proof cleanly partitions: **logic supplies existence** (Lemma 5.1 makes
points), **topology supplies finiteness** (compactness makes every clopen a
finite union), and the **algebra/ring dictionary** translates the Boolean
operations into ring operations so each side can use its native tools.

---

## 9. Applications

- **Completeness and consistency in logic.** The representation theorem
  underlies the algebraic semantics of classical propositional logic: a formula
  is a theorem iff it is `⊤` in every Boolean algebra iff it is the whole Stone
  space — the algebraic completeness theorem.
- **Set-theoretic forcing.** Boolean-valued models are built from complete
  Boolean algebras; their Stone spaces and clopen algebras organize the
  combinatorics of forcing.
- **Circuit and database theory.** Boolean functions and query predicates form
  Boolean algebras; the clopen/spectral picture provides a geometric semantics
  for "regions of inputs" and supports normal-form (DNF/finite-union)
  arguments mirrored exactly by Theorem 6.1.
- **Template for dualities.** The architecture (object → algebra of structured
  subsets of a spectrum) is the prototype for Gelfand, Pontryagin, and
  scheme-theoretic dualities; the formal pattern here transfers.

---

## 10. Discussion and future directions

### 10.1 Functoriality and the full duality of categories
Promote the object-level isomorphism to a genuine contravariant equivalence
between the category of Boolean algebras (Boolean homomorphisms) and the
category of Stone spaces (continuous maps). A Boolean homomorphism `f : B → C`
induces a continuous `Spec(f) : StoneSpace C → StoneSpace B`. The key insight is
that turning a Boolean homomorphism into a ring homomorphism makes
`PrimeSpectrum.comap` supply the contravariant action *for free*; functoriality
reduces to `comap_id`/`comap_comp`, already in Mathlib. With the objects pinned
down by Definition 2.1, the morphism layer is the natural next increment, and
`stoneOrderIso` becomes the unit of an adjoint equivalence.

### 10.2 The Stone space is a Stone space (topological characterization)
Prove `T2Space (StoneSpace B)`, `TotallyDisconnectedSpace (StoneSpace B)`, and
(with compactness) that `StoneSpace B` is a profinite/Stone space — and
conversely that every such space arises this way. The clopen basis (Lemma 3.2)
already supplies total disconnectedness; Hausdorffness follows from separating
points by clopens via Lemma 5.1.

### 10.3 Completeness ↔ extremal disconnectedness
Formalize the refinement that `B` is a *complete* Boolean algebra iff its Stone
space is *extremally disconnected* (the closure of every open is open),
connecting the order-completeness of `B` to a topological regularity of its
spectrum.

### 10.4 Spectral spaces and distributive lattices
Generalize from Boolean algebras to bounded distributive lattices (Stone's
1937 theorem / Priestley duality), where the spectrum is a *spectral space* and
clopen up-sets replace clopens. The same spectrum-first methodology should apply.

### 10.5 Boolean-valued semantics and forcing
Use the verified clopen isomorphism as a foundation for a formal treatment of
Boolean-valued models, linking the algebraic and topological views of forcing.

---

## 11. Conclusion

We have formally verified the object-level core of Stone duality: every Boolean
algebra is canonically isomorphic to the clopen algebra of its Stone space,
realized as the prime spectrum of the associated Boolean ring. The proof is
short, modular, and free of unproven assumptions, and it demonstrates a reusable
principle — *choose the definition that lets existing geometry do the work* —
that converts a classically heavy representation theorem into a clean bridge
between logic and topology.
