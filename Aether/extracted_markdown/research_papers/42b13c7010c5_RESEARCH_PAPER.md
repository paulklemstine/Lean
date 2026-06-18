# One-Way Functions: Existence, Inversion Capacity, and the Order Structure of the Cryptographic Hardness Hierarchy

## Abstract

One-way functions (OWFs) are the foundational primitive of modern
cryptography: functions that are easy to evaluate but, conjecturally, hard to
invert. The conjectural status of their hardness is not an accident of our
ignorance — it is forced by a structural fact. We isolate and formalize that
fact: **one-wayness is never an information-theoretic property.** Over an
arbitrary nonempty domain, every function admits a *weak inverse*, a map that
for each input recovers some genuine preimage of its image; consequently no
function can resist a resource-unbounded adversary, and one-wayness must live
entirely in computational complexity.

We then quantify exactly how successful an inverter can be. We distinguish
*weak* inversion (recover any preimage) from *exact* inversion (recover the
original input). Weak inversion is always perfect: a weak inverter succeeds on
all `|α|` inputs of a finite domain. Exact inversion is genuinely constrained:
no inverter can exactly recover more than `|Im f|` inputs, where `Im f` is the
image of `f`, and this optimum is attained by the canonical inverse
`Function.invFun f`. The image size therefore emerges as the precise
*information-theoretic capacity of exact inversion*, the bridge between the
collision/fiber structure of a function and its invertibility.

Finally we expose the order-theoretic skeleton of the qualitative hardness
hierarchy `OWF → PRG → PRF → ENC`: its rank map is injective, the implication
relation is a total order, OWF is its least element and ENC its greatest. The
hierarchy is order-isomorphic to the chain `Fin 4`.

All results have been formally verified in the Lean 4 proof assistant with no
remaining gaps, depending only on the standard foundational axioms; the order
results use no nonconstructive axioms at all.

**Keywords:** one-way functions, information-theoretic security, weak inverse,
preimage capacity, cryptographic hierarchy, total order, formal verification.

---

## 1. Introduction

### 1.1 Motivation

The entire superstructure of modern cryptography — pseudorandom generators,
pseudorandom functions, digital signatures, IND-CPA encryption — rests on a
single conjectured object: a *one-way function*. Informally, `f` is one-way if
it is computable in polynomial time but every efficient algorithm, given
`f(x)` for a uniformly random `x`, fails (except with negligible probability)
to output any preimage of `f(x)`.

A natural and pedagogically important question is *why* this must remain a
conjecture. Why can we not simply *prove* some explicit function one-way, the
way we prove a number prime? The answer is structural and is the conceptual
core of this paper: hardness of inversion is impossible to obtain from
information alone. Strip away every resource bound and the adversary always
wins. One-wayness is a statement about *computation*, never about
*information*, and so it can be assumed but not derived from counting
arguments.

This paper formalizes that principle, sharpens it into a quantitative theory of
inversion capacity, and situates one-way functions at the base of the
cryptographic hardness hierarchy as a genuine order-theoretic least element.

### 1.2 Contributions

We make three contributions, each fully formalized.

1. **Existence layer (Section 3).** Every function over a nonempty domain has a
   weak inverse, hence no function is information-theoretically one-way.

2. **Capacity theory (Sections 4–5).** Weak inversion is always perfect on a
   finite domain; exact inversion is bounded above by `|Im f|`, and this bound
   is tight, achieved by the canonical inverse.

3. **Order structure (Section 6).** The four-level hardness hierarchy is a
   total order with explicit extremal elements, order-isomorphic to `Fin 4`.

### 1.3 Relation to prior formalized work

This development extends two companion modules. From the *Hardness Hierarchy*
module it inherits the `CryptoLevel` enumeration with its rank map and strict
chain, the `LossyFunction` model of image-bounded functions, and the fiber
machinery (`fiber`, `fiber_sum_eq_card`, `large_fiber_exists`). The present
work adds the *existence* layer beneath the hierarchy and promotes the discrete
rank chain into a genuine total order with extrema. It complements a separate
treatment of OWF *hardness* (verification cost and exponential preimage
sparsity) by explaining why such hardness is *necessary*: information alone
never yields one-wayness.

---

## 2. Preliminaries and Notation

Let `α` and `β` be types (the domain and codomain). We write `f : α → β` for a
function. For finite `α` we write `|α|` for `Fintype.card α`, and for a
function `f` we write `Im f` for the image `Finset.univ.image f` and `|Im f|`
for its cardinality.

**Canonical inverse.** Mathlib provides, for any `f : α → β` with `α` nonempty,
a function `Function.invFun f : β → α` characterized by the property that
whenever `y` has a preimage, `f (invFun f y) = y`. Concretely, `invFun f y`
chooses (using the axiom of choice) some `x` with `f x = y` if one exists, and
an arbitrary fixed element of `α` otherwise. We will use the one fact we need:

> **Lemma (invFun_eq).** If there exists `a` with `f a = y`, then
> `f (invFun f y) = y`.

**Fibers.** For `f : α → β` and `y : β`, the *fiber* of `y` is
`fiber f y = {x : α | f x = y}` (as a finite set when `α` is finite). The
fibers partition the domain, giving the identity (formalized as
`fiber_sum_eq_card`)

> `∑_{y ∈ Im f} |fiber f y| = |α|`.   (★)

---

## 3. Weak Inverses and Information-Theoretic Impossibility

### 3.1 The definition

The crucial modeling decision is what "inverting" means. A *left inverse*
`g(f(x)) = x` is too strong: it exists only for injective `f`. The correct
notion for cryptography is recovery of *some* preimage, because an adversary
breaking a system needs any valid input, not the specific one originally used.

> **Definition 3.1 (Weak inverse).** A map `g : β → α` is a *weak inverse* of
> `f : α → β` if for every input `x`,
> `f (g (f x)) = f x`.
> Equivalently, `g (f x)` always lies in the fiber of `f x`.

### 3.2 The canonical weak inverse

> **Theorem 3.2 (invFun_weakInverse).** For `α` nonempty and any `f : α → β`,
> the canonical inverse `invFun f` is a weak inverse of `f`.

*Proof.* Fix `x`. The element `f x` has the preimage `x` itself, so the
hypothesis of `invFun_eq` is satisfied with witness `⟨x, rfl⟩`. Hence
`f (invFun f (f x)) = f x`, which is exactly the weak-inverse condition. ∎

> **Corollary 3.3 (exists_weakInverse).** For `α` nonempty, every `f : α → β`
> has a weak inverse.

*Proof.* Take `g = invFun f` and apply Theorem 3.2. ∎

### 3.3 Impossibility of information-theoretic one-wayness

We formalize the "information-theoretic security game" as the demand that
*every* candidate inverter fail somewhere.

> **Definition 3.4 (Information-theoretic one-wayness).** A function `f` is
> *information-theoretically one-way* if for every `g : β → α` there exists an
> input `x` with `f (g (f x)) ≠ f x`.

> **Theorem 3.5 (not_infoTheoreticOneWay).** For `α` nonempty, no function `f`
> is information-theoretically one-way.

*Proof.* Suppose `f` were information-theoretically one-way. By Corollary 3.3
there is a weak inverse `g` with `f (g (f x)) = f x` for all `x`. But the
one-wayness assumption applied to this very `g` yields some `x` with
`f (g (f x)) ≠ f x`, a contradiction. ∎

**Interpretation.** Theorem 3.5 is the conceptual heart of the development. An
adversary with unbounded resources can, before the game starts, tabulate a
weak inverse (indeed `invFun f` is such a table) and thereafter invert every
output. Therefore one-wayness can only ever be a *complexity-theoretic*
assertion — the table exists but is infeasible to build — which is precisely
why the existence of OWFs is *assumed* throughout cryptography rather than
proved.

---

## 4. Quantitative Success of Weak Inversion

Over a finite domain we can count exactly how often an inverter succeeds. For
weak inversion the answer is: always.

> **Theorem 4.1 (weakInverse_inverts_all).** Let `α` be a finite type, `f : α →
> β`, and `g` a weak inverse of `f`. Then the number of inputs on which weak
> inversion succeeds is maximal:
> `|{x : α | f (g (f x)) = f x}| = |α|`.

*Proof.* By the definition of weak inverse, the predicate `f (g (f x)) = f x`
holds for every `x`. Filtering a finite set by a universally true predicate
returns the whole set, whose cardinality is `|α|`. ∎

Thus weak inversion confers *perfect information-theoretic advantage*: the
attacker recovers a valid preimage for all `|α|` inputs. This quantitative
statement makes the impossibility of Section 3 concrete — not only does the
attacker win, the attacker wins on the entire domain.

---

## 5. The Capacity of Exact Inversion

Weak inversion is unconstrained. *Exact* inversion — recovering the original
input itself — is the genuinely limited resource, and the limit is collision
structure.

> **Definition 5.1 (Exact inversions).** For `f : α → β` and `g : β → α`, the
> set of *exactly inverted* inputs is
> `exactInversions f g = {x : α | g (f x) = x}`.

### 5.1 The upper bound

> **Theorem 5.2 (exact_inversions_le_image).** For any finite `α`, any `f : α →
> β`, and any `g : β → α`,
> `|exactInversions f g| ≤ |Im f|`.

*Proof.* We show `f` restricted to `exactInversions f g` is injective into the
image. The map `f` certainly sends each element of the set into `Im f`. For
injectivity, suppose `x, y ∈ exactInversions f g` with `f x = f y`. Then
`x = g(f x) = g(f y) = y`, using the defining property of the set at both `x`
and `y` and the hypothesis `f x = f y` in between. An injective map from a
finite set into `Im f` cannot have a domain larger than `|Im f|`, by
`Finset.card_le_card_of_injOn`. ∎

The mechanism is exactly the collision obstruction: on inputs the inverter
pins down exactly, `f` cannot collide, so the count is capped by the number of
distinct outputs.

### 5.2 Tightness

> **Theorem 5.3 (invFun_exact_inversions).** For `α` nonempty and any `f : α →
> β`,
> `|exactInversions f (invFun f)| = |Im f|`.

*Proof.* The upper bound is Theorem 5.2. For the matching lower bound we
exhibit `exactInversions f (invFun f)` as the bijective image of `Im f`. The
key set identity is

> `exactInversions f (invFun f) = (Im f).image (invFun f)`,

i.e. the exactly-inverted inputs are precisely the canonical preimages of the
distinct outputs. We verify both inclusions:

- *(⊆)* If `invFun f (f x) = x`, then `x` is the `invFun`-image of `f x ∈ Im f`.
- *(⊇)* If `x = invFun f y` for some `y = f a ∈ Im f`, then by `invFun_eq`
  applied to the witness `⟨a, rfl⟩` we have `f (invFun f (f a)) = f a`, i.e.
  `f x = y`, whence `invFun f (f x) = invFun f y = x`, so `x ∈ exactInversions`.

It remains to show `invFun f` is injective on `Im f`, so that the image has the
same cardinality `|Im f|`. If `y = f a` and `y' = f b` lie in `Im f` and
`invFun f y = invFun f y'`, then applying `f` and using `invFun_eq` on each
side gives `y = f(invFun f y) = f(invFun f y') = y'`. Hence
`|(Im f).image (invFun f)| = |Im f|` by `Finset.card_image_of_injOn`, and the
result follows. ∎

### 5.3 The capacity interpretation

Theorems 5.2 and 5.3 together identify `|Im f|` as the exact
*information-theoretic capacity of exact inversion*: the supremum, over all
inverters, of the number of exactly recovered inputs, attained by the canonical
inverter. Combining this with the fiber identity (★) yields a collision-deficit
form of the capacity:

> **Corollary 5.4 (capacity as collision deficit).**
> `max_g |exactInversions f g| = |Im f| = |α| − ∑_{y ∈ Im f} (|fiber f y| − 1).`

*Proof sketch.* The maximum equals `|Im f|` by Theorems 5.2–5.3. By (★),
`|α| = ∑_{y ∈ Im f} |fiber f y| = |Im f| + ∑_{y ∈ Im f} (|fiber f y| − 1)`,
since the image has `|Im f|` summands each contributing a `1`. Rearranging
gives the stated identity. ∎

The sum `∑_{y} (|fiber f y| − 1)` is the *collision deficit* — the total excess
of inputs over distinct outputs. A function that is far from injective (many
large fibers) has a large deficit and correspondingly small exact-inversion
capacity, regardless of the attacker's power. This is the precise sense in
which lossy functions resist exact inversion: the lost information is gone for
everyone.

---

## 6. The Order Structure of the Hardness Hierarchy

We now turn from individual functions to the qualitative ordering of
cryptographic primitives.

> **Definition 6.1 (Crypto levels and rank).** The hierarchy levels are the
> four-element enumeration `CryptoLevel = {OWF, PRG, PRF, ENC}`. The *rank* map
> is `rank OWF = 0`, `rank PRG = 1`, `rank PRF = 2`, `rank ENC = 3`. We declare
> `A ≤ B` (read "`A` is implied by `B`", i.e. `B` is at least as strong) iff
> `rank A ≤ rank B`. (Following the source convention, the order tracks
> strength: the stronger primitive is the larger element.)

The companion module already established reflexivity, transitivity, and
strictness (`hierarchy_strict`: distinct levels are never mutually implied).
We upgrade these to a full total order with extrema.

> **Theorem 6.2 (rank_injective).** The rank map `CryptoLevel → ℕ` is
> injective: distinct levels have distinct ranks.

*Proof.* A finite case check over the sixteen ordered pairs; distinct
constructors receive distinct numerals `0,1,2,3`. ∎

> **Theorem 6.3 (level_total).** The implication order is total: for any two
> levels `A, B`, either `A ≤ B` or `B ≤ A`.

*Proof.* The order is the pullback along `rank` of the total order on `ℕ`. For
any `A, B`, the naturals `rank A` and `rank B` are comparable, so `A` and `B`
are too. ∎

> **Theorem 6.4 (owf_weakest).** `OWF` is the least element:
> `OWF ≤ A` for every level `A`. Equivalently, every stronger primitive
> implies a one-way function.

*Proof.* `rank OWF = 0 ≤ rank A` for all `A`. ∎

> **Theorem 6.5 (enc_strongest).** `ENC` is the greatest element:
> `A ≤ ENC` for every level `A`. Every primitive is implied by secure
> encryption (in the strength ordering).

*Proof.* `rank A ≤ 3 = rank ENC` for all `A`. ∎

> **Corollary 6.6 (order isomorphism).** Together with antisymmetry
> (`hierarchy_strict`) and transitivity, `(CryptoLevel, ≤)` is a total order
> with least element `OWF` and greatest element `ENC`, order-isomorphic via
> `rank` to the chain `Fin 4` with its usual order.

Structurally, then, the elaborate web of cryptographic reductions collapses, at
the level of pure order, to counting `0 < 1 < 2 < 3`. One-way functions are not
merely *a* foundation; they are the provable *bottom* of the order.

---

## 7. Algorithms

The constructive content of the theory yields three concrete algorithms over a
finite domain. We summarize them; full type-hinted implementations accompany
this paper.

**A1 — Canonical weak inverse (table construction).** Build a dictionary that,
for each output value `y` actually produced by `f`, stores one input mapping to
`y`. Inversion is then a lookup. Construction is `O(|α|)` time and `O(|Im f|)`
space; lookup is `O(1)` amortized. This is the explicit realization of the
Oracle's table from Section 3, and the formal witness `invFun f`.

**A2 — Exact-inversion counter.** Given `f` and any inverter `g`, count
`|{x : f^{-1}(f(x)) chosen by g equals x}|` by a single pass over the domain.
Used to validate the bound of Theorem 5.2 and the optimality of Theorem 5.3
empirically. Complexity `O(|α|)`.

**A3 — Capacity / collision-deficit computation.** Compute `|Im f|` directly,
and independently compute `|α| − ∑_y (|fiber y| − 1)`; verify equality
(Corollary 5.4). Complexity `O(|α|)` using a hash map of fiber sizes.

---

## 8. Applications

**Pedagogy of cryptographic foundations.** Theorem 3.5 gives a one-line,
fully rigorous answer to the perennial student question "why can't we just
prove a function is one-way?" — because information never suffices; only
complexity does.

**Lossy primitives.** Corollary 5.4 quantifies the intuition behind lossy
trapdoor functions and lossy encryption: small image (large collision deficit)
provably caps exact inversion for *all* adversaries. This gives a clean,
adversary-independent measure of "how lossy" a function is.

**Hierarchy reasoning.** The total-order structure (Section 6) lets one reason
about cryptographic assumptions with the full strength of order theory:
least/greatest elements, monotone maps, and the absence of incomparable
"side" assumptions within this four-element core.

**Formal-methods infrastructure.** Because every result is machine-checked, the
module serves as a trustworthy base layer for larger verified cryptographic
developments built atop OWFs.

---

## 9. Discussion

The development draws a sharp line between two notions that informal treatments
often blur: *information* and *computation*. The weak-inverse construction
shows that, informationally, inversion is free. What is expensive — and what
all of practical cryptography rents — is the *time* to realize the construction
for functions whose domains are astronomically large. The quantitative theory
then refines "inversion" itself into weak (always free) and exact (bounded by
image size), pinpointing collisions as the only true obstruction and
identifying `|Im f|` as the exact currency of exact recovery.

A notable methodological point is the choice of the weak-inverse invariant
`f(g(f x)) = f x` over the naive left-inverse `g(f x) = x`. The latter is
simply false for non-injective `f`, and an early formalization attempt that
used it could not be completed. The correct invariant — recover *a* preimage,
not *the* input — is both provable in full generality and faithful to the
cryptographic threat model.

---

## 10. Future Directions

We highlight two concrete, falsifiable directions (further directions appear in
the accompanying package).

**(1) Exact-inversion capacity as a collision invariant.** Corollary 5.4 already
gives `max_g |exactInversions f g| = |α| − (collision deficit)`. The remaining
program is to package this as a reusable invariant of `LossyFunction`, tying
the inversion optimum directly to the image-bound field and to
`large_fiber_exists`, so that "this primitive is hard to invert exactly" becomes
a computable property of the function's collision profile rather than an ad hoc
estimate. Both ingredients — `invFun_exact_inversions` and the fiber identity
`fiber_sum_eq_card` — are already formalized, so the bridge is a short
composition.

**(2) Monotonicity of impossibility along the hierarchy.** Conjecture: the
impossibility of information-theoretic security propagates *upward* through the
order `OWF ≤ PRG ≤ PRF ≤ ENC`. Concretely, the existence of a weak inverse at
the base should lift, via the standard reductions, to information-theoretic
attacks against the derived primitives in the unbounded model, formalizing the
slogan "no rung of the ladder is information-theoretically secure." The
order-theoretic scaffolding of Section 6 (least element, totality) is the
natural setting for such an induction.

---

## 11. Conclusion

We have isolated, sharpened, and formally verified the conceptual core of
one-way function theory. One-wayness is impossible to obtain from information
alone: every function over a nonempty domain has a weak inverse, so no function
is information-theoretically one-way. Exact inversion, by contrast, has a sharp
capacity `|Im f|`, attained by the canonical inverter and equal to domain size
minus collision deficit. And the four-level hardness hierarchy is a total order
with one-way functions provably at the bottom and secure encryption at the top.
Together these results explain, precisely and from first principles, why
cryptography is a race against computation rather than a wall against
information.

---

## Appendix A: Index of formal results

| Name | Statement |
|---|---|
| `WeakInverse` | `g` weak inverse of `f` iff `∀ x, f (g (f x)) = f x` |
| `invFun_weakInverse` | `invFun f` is a weak inverse of `f` (nonempty domain) |
| `exists_weakInverse` | every `f` over nonempty `α` has a weak inverse |
| `InfoTheoreticOneWay` | `∀ g, ∃ x, f (g (f x)) ≠ f x` |
| `not_infoTheoreticOneWay` | no `f` is information-theoretically one-way |
| `weakInverse_inverts_all` | a weak inverter succeeds on all `|α|` inputs |
| `exactInversions` | `{x | g (f x) = x}` |
| `exact_inversions_le_image` | `|exactInversions f g| ≤ |Im f|` |
| `invFun_exact_inversions` | `|exactInversions f (invFun f)| = |Im f|` |
| `rank_injective` | rank map is injective |
| `level_total` | implication order is total |
| `owf_weakest` | `OWF` is the least level |
| `enc_strongest` | `ENC` is the greatest level |

All results compile with no remaining gaps; the order results require no
nonconstructive axioms, and the inversion results depend only on the standard
foundational axioms (propositional extensionality, choice, and quotient
soundness).
