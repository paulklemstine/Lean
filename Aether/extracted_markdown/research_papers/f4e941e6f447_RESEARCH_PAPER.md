# Belnap's FOUR as a Bounded Distributive Lattice: Gluts, Gaps, and the Algebraic Characterization of Paraconsistency

## Abstract

We give a fully self-contained development of Belnap's four-valued logic **FOUR**
(with values `N` = neither/gap, `F` = false, `T` = true, `B` = both/glut) as a
**bounded distributive lattice** under the truth ordering, equipped with an
order-reversing De Morgan negation. Our central result is a clean algebraic
characterization of paraconsistency: the logic is **non-explosive if and only if it
possesses a designated glut**, and the unique such glut is the value `B`. Dually, the
unique gap is `N`. We prove that the truth order makes FOUR isomorphic to the diamond
`2 × 2` (Ginsberg's product `2 ⊙ 2`), that negation is a De Morgan involution
satisfying both De Morgan laws and antitonicity, that FOUR has exactly four elements,
and that it is therefore the smallest non-trivial carrier supporting paraconsistent
reasoning. We then sketch a bridge to **dream spaces** — families of "open" sets
closed under finite intersection but not arbitrary union — and show that the
metalogical "glut locus" of a paraconsistent valuation coincides with a topological
defect: a paraconsistent valuation on `ℕ` whose set of contradiction-points (the even
numbers) is not closed in the canonical finite-or-univ dream space. The metalogical
and topological defects are literally the same set. All results were formalized and
machine-verified.

**Keywords:** Belnap's FOUR, paraconsistency, bilattice, De Morgan algebra,
distributive lattice, truth-value glut, truth-value gap, dream space, explosion.

---

## 1. Introduction

Classical logic obeys *ex contradictione quodlibet* (ECQ): from `a` and `¬a`,
everything follows. For systems that aggregate information from multiple, possibly
conflicting sources — relational databases, sensor fusion, the semantic web,
belief-revision engines — ECQ is fatal: a single inconsistency trivializes the entire
theory. **Paraconsistent logics** are precisely those in which ECQ fails. Belnap's
four-valued logic FOUR, introduced in *"How a Computer Should Think"* (1977), is the
canonical paraconsistent system and the prototypical **bilattice**.

The standard motivation for FOUR is epistemic: instead of tracking a single Boolean
"is it true?", a reasoner tracks two independent Booleans — *is there evidence for?*
and *is there evidence against?* — yielding four epistemic states. The novelty of the
present treatment is not the model itself but the **reduction of paraconsistency to a
single algebraic condition**, proved over the genuine bounded distributive lattice
structure of FOUR, and the identification of the resulting "glut locus" with a
topological defect in an associated dream space.

Our contributions are:

1. A bounded distributive lattice and De Morgan involution structure on FOUR under
   the truth order, realized through the coordinate representation in `Bool × Bool`
   (§3, §4).
2. The characterization theorems `glut_iff_B` and `gap_iff_N`: the unique glut is `B`,
   the unique gap is `N` (§5).
3. The main theorem `paraconsistency_iff_glut`: non-explosion is equivalent to the
   existence of a designated glut; hence FOUR is paraconsistent (§6).
4. Minimality: FOUR has exactly four elements and is the smallest non-trivial
   bilattice carrier (§7).
5. A bridge to dream spaces, identifying the glut locus of a paraconsistent valuation
   with a non-closed set in a non-topological dream space (§8).

---

## 2. Preliminaries and the carrier

We work over the four-element type

```
inductive Belnap | N | F | T | B
```

with decidable equality and finiteness. Informally:

- `N` ("neither"): no evidence for, no evidence against — a **gap**;
- `F` ("false"): no evidence for, evidence against;
- `T` ("true"): evidence for, no evidence against;
- `B` ("both"): evidence for, evidence against — a **glut**.

**Definition 2.1 (Coordinate representation).** Define
`toProd : Belnap → Bool × Bool` by the "evidence-for / evidence-against" coordinates
```
N ↦ (false, false),  F ↦ (false, true),  T ↦ (true, false),  B ↦ (true, true).
```
This is Ginsberg's `2 ⊙ 2` representation. It is a bijection onto `Bool × Bool`, so
FOUR has exactly `2² = 4` elements.

**Definition 2.2 (Negation).** The De Morgan negation `neg : Belnap → Belnap` is
```
neg N = N,  neg F = T,  neg T = F,  neg B = B,
```
i.e. the swap of the two coordinates: `toProd (neg a) = ((toProd a).2, (toProd a).1)`.
It fixes the gap `N` and the glut `B` and exchanges `F` and `T`.

---

## 3. The truth order

**Definition 3.1 (Truth order).** For `a, b : Belnap`, write `a ≤ b` (the *truth
order*, FDE entailment) when there is at least as much evidence-for and at most as
much evidence-against:
```
a ≤ b  :⟺  (toProd a).1 ≤ (toProd b).1  ∧  (toProd b).2 ≤ (toProd a).2.
```
This is the *twisted* product order on `Bool × Bool` (first coordinate increasing,
second decreasing). It is decidable, routed through a Boolean predicate `tleb` so that
all finite verifications below are discharged by exhaustive evaluation.

Concretely the truth order is the four-element **diamond**:
```
        T
       / \
      N   B
       \ /
        F
```
with `F` least, `T` greatest, and `N`, `B` incomparable.

**Proposition 3.2 (Partial order).** `≤` is reflexive, transitive, and
antisymmetric. *(Finite case analysis over the four-element carrier.)*

---

## 4. The bounded distributive lattice and De Morgan structure

**Definition 4.1 (Meet and join).** The truth meet `⊓` and join `⊔` act
coordinatewise on the representation:
```
toProd (a ⊓ b) = ((toProd a).1 && (toProd b).1, (toProd a).2 || (toProd b).2),
toProd (a ⊔ b) = ((toProd a).1 || (toProd b).1, (toProd a).2 && (toProd b).2).
```
That is: meet takes the conjunction of evidence-for and the disjunction of
evidence-against; join does the reverse. These are the FDE conjunction and
disjunction.

**Theorem 4.2 (Lattice).** `(Belnap, ≤, ⊓, ⊔)` is a lattice: `⊓` is the greatest
lower bound and `⊔` the least upper bound for `≤`.

**Theorem 4.3 (Distributivity).** FOUR is a **distributive** lattice:
`a ⊔ (b ⊓ c) = (a ⊔ b) ⊓ (a ⊔ c)` and dually. *(The diamond `2 × 2` is distributive;
the law is a finite identity in the coordinates.)*

**Theorem 4.4 (Bounds).** `F` is the bottom and `T` is the top:
`⊥ = F ≤ a ≤ T = ⊤` for all `a`. Hence FOUR is a **bounded distributive lattice**.

**Theorem 4.5 (De Morgan involution).** `neg` is a De Morgan negation:

- *Involution:* `neg (neg a) = a`.
- *Antitone:* `a ≤ b ⟹ neg b ≤ neg a`.
- *De Morgan laws:* `neg (a ⊓ b) = neg a ⊔ neg b` and `neg (a ⊔ b) = neg a ⊓ neg b`.

Thus `(Belnap, ⊓, ⊔, neg, F, T)` is a **De Morgan algebra**, and indeed the smallest
one that is not a Boolean chain (its two negation-fixed points `N` and `B` distinguish
it from the two- and three-valued De Morgan chains).

*Proof sketch (4.2–4.5).* Each law is a universally quantified identity or implication
over a four-element carrier. Encoding `≤`, `⊓`, `⊔`, `neg` through the `Bool × Bool`
coordinates turns every law into a finite Boolean identity, which is then verified by
exhaustive evaluation (`decide`). Distributivity, the bounds, the involution,
antitonicity, and both De Morgan laws all reduce uniformly to coordinatewise Boolean
algebra, where they are standard. ∎

---

## 5. Designation, gluts, and gaps

**Definition 5.1 (Designation).** A value is **designated** ("at least assertibly
true") when
```
designated a  :⟺  a = T ∨ a = B.
```
A sentence is assertible exactly when its value is designated. Note `B` is designated
despite being contradicted.

**Definition 5.2 (Glut, gap).**
```
IsGlut a  :⟺  designated a ∧ designated (neg a),
IsGap  a  :⟺  ¬ designated a ∧ ¬ designated (neg a).
```
A glut is designated together with its negation; a gap is non-designated together with
its negation.

**Theorem 5.3 (Unique glut).** `IsGlut a ↔ a = B`.

**Theorem 5.4 (Unique gap).** `IsGap a ↔ a = N`.

*Proof sketch.* Finite check over the four values. For `5.3`: `designated a` requires
`a ∈ {T, B}`; for `a = T`, `neg T = F` is not designated, so `T` is not a glut;
`a = B` has `neg B = B` designated, so `B` is a glut; `N, F` are not designated. The
only glut is `B`. Symmetrically, the only gap is `N`. ∎

**Remark 5.5.** Designation respects the truth order: if `a ≤ b` and `a` is designated
then `b` is designated. This is the soundness of FDE entailment with respect to the
designated-value filter `{T, B}`.

---

## 6. Paraconsistency

**Definition 6.1 (Explosion).** FOUR is **explosive** if the explosion rule (ECQ)
holds:
```
Explosive  :⟺  ∀ a q : Belnap, designated a → designated (neg a) → designated q.
```
That is: a designated value with designated negation entails every conclusion `q`.
The logic is **paraconsistent** when `Explosive` fails.

**Theorem 6.2 (Main theorem: paraconsistency ⟺ glut).**
```
¬ Explosive  ↔  ∃ a : Belnap, IsGlut a.
```

*Proof sketch.* (⟸) Suppose `a` is a glut. Then `designated a` and
`designated (neg a)` both hold, but choosing the conclusion `q = F` gives
`¬ designated F`. Hence the explosion implication fails at `(a, F)`, so
`¬ Explosive`. (⟹) Conversely, if `¬ Explosive`, then for some `a, q` we have
`designated a`, `designated (neg a)`, but `¬ designated q`; in particular `a` is a
designated value with designated negation, i.e. a glut. Unfolding the definitions, the
equivalence is a finite check over the carrier. ∎

**Corollary 6.3 (FOUR is paraconsistent).** `¬ Explosive`, witnessed by the glut `B`:
`IsGlut B` holds by Theorem 5.3, so by Theorem 6.2 the logic is non-explosive.

**Theorem 6.4 (Why classical logic is explosive — vacuously).** In the two-valued
Boolean algebra, the contradiction premise is unsatisfiable: there is no `b : Bool`
with `b = true` and `(!b) = true`. Consequently classical logic validates explosion
*vacuously*: `∀ b q : Bool, b = true → (!b) = true → q = true`.

*Discussion.* Theorems 6.2–6.4 together pinpoint the source of paraconsistency.
Classical logic does not "choose" to explode; its explosion principle holds only
because its contradiction premise can never be met. Enlarging the value space by
exactly one value, `B`, makes the contradiction premise *satisfiable*, and Theorem 6.2
shows that satisfiability of the contradiction premise by a value with designated
negation is *equivalent* to the failure of explosion. The glut `B` is simultaneously
the object that makes contradiction expressible and the object that prevents its
spread.

---

## 7. Minimality and two-dimensionality

**Theorem 7.1 (Cardinality).** `Fintype.card Belnap = 4`. FOUR has exactly four
elements.

**Theorem 7.2 (Necessity of four values).** Paraconsistency forces:
- a designated value whose negation is designated — the glut `B`;
- a designated value whose negation is *not* designated — `T`;
- a non-designated value — `F`;
and the knowledge order then forces the fourth value `N` as the bottom dual to `B`.
The four values are pairwise distinct.

*Proof sketch.* By Theorem 6.2 paraconsistency requires a glut, which by Theorem 5.3
must be `B`, with `neg B = B`. To distinguish a *consistent* designated value we need
`T` with `neg T = F` non-designated, and `F` itself is non-designated. The De Morgan
involution, being order-reversing, then forces a negation-fixed point at the opposite
pole — the gap `N` (by Theorem 5.4) — as the knowledge-order bottom. Hence four
pairwise-distinct values are both necessary and sufficient. ∎

**Theorem 7.3 (Genuine bilattice).** Equipping FOUR additionally with the *knowledge
order* (the untwisted product order, `N` at the bottom, `B` at the top) yields a
structure in which neither order refines the other: there exist `a, b` with `a ≤_t b`
but not `a ≤_k b`, and conversely. FOUR is therefore a genuinely two-dimensional
bilattice, not a single chain in disguise.

---

## 8. Bridge: gluts as topological defects in dream spaces

The reduction of paraconsistency to "where are the gluts?" invites a geometric
reading. We sketch a structure in which the *glut locus* of a valuation becomes a
*topological defect*.

**Definition 8.1 (Dream space).** A **dream space** on a set `X` is a family
`𝒟 ⊆ 𝒫(X)` of "dream-open" sets containing `∅` and `X` and closed under *finite*
intersection, but **not required** to be closed under arbitrary unions. Every topology
is a dream space; the converse fails. Dream spaces model *local* coherence (every
finite combination of established facts is established) without *global* coherence
(arbitrary aggregations may escape).

**Definition 8.2 (The finite-or-univ dream space on `ℕ`).** Let `dreamNat` declare a
set `S ⊆ ℕ` dream-open iff `S` is finite or `S = ℕ`. Finite intersections of finite
sets are finite, and intersection with `ℕ` is harmless, so `dreamNat` is a dream
space.

**Theorem 8.3 (`dreamNat` is not a topology).** The set of even numbers is *not*
dream-open: it is neither finite nor all of `ℕ`. Yet it is the union of the singletons
`{0}, {2}, {4}, …`, each of which is finite and hence dream-open. Thus `dreamNat` is
not closed under arbitrary unions and is genuinely non-topological, with the evens as
explicit witness.

**Definition 8.4 (Valuation and glut locus).** A **Belnap valuation** on `ℕ` is a map
`v : ℕ → Belnap`. Its **glut locus** is `{ n : ℕ | IsGlut (v n) }`.

**Theorem 8.5 (Glut locus equals the `B`-locus).** For any valuation `v`,
`{ n | IsGlut (v n) } = { n | v n = B }`. *(Immediate from Theorem 5.3 applied
pointwise.)* The glut locus is exactly the set of facts on which the valuation records
a contradiction.

**Theorem 8.6 (A paraconsistent valuation with non-dream-open glut locus).** There
exists a valuation `v : ℕ → Belnap` that is paraconsistent (assigning `B` to
contradiction-points without explosion) whose glut locus is the set of even numbers.
By Theorem 8.5 its glut locus is `{ n | v n = B }`, and by Theorem 8.3 this set is not
dream-open. The constant valuation `v ≡ B`, by contrast, has glut locus all of `ℕ`,
which *is* dream-open.

*Significance.* The **metalogical defect** of `v` — the set of facts on which it
carries a contradiction — is *literally the same set* as the **topological defect**
of `dreamNat` — the union of dream-opens that escapes the family. The place where the
logic refuses to explode and the place where the geometry refuses to close coincide.
This is the seed of a broader correspondence between paraconsistent valuations and
points of dream spaces.

---

## 9. Algorithms

The finite, decidable nature of FOUR makes every claim above effectively computable.
We highlight three procedures (full code in the accompanying demo).

**Algorithm A (Glut/Gap classifier).** Given `a : Belnap`, decide `IsGlut a` /
`IsGap a` by evaluating `designated a` and `designated (neg a)` from the four-row
tables. `O(1)`.

**Algorithm B (Explosion checker).** Decide `Explosive` by iterating over all
`(a, q) ∈ Belnap × Belnap` (16 pairs) and testing the implication; return the failing
witness `(a, q)` if any. `O(|Belnap|²) = O(16)`. The returned witness `(B, F)`
constructively demonstrates non-explosion.

**Algorithm C (Dream-open / glut-locus tester).** Given a finite description of a
valuation `v` and a bound `N`, compute the glut locus `{ n < N : v n = B }` and test
dream-openness of a finite candidate set against `dreamNat` (finite or full). `O(N)`.

---

## 9b. Worked examples

To make the abstract laws concrete we record several computations that a reader can
reproduce by hand from the coordinate tables of §2–§4.

**Example 1 (Meet and join).** Take `a = N` (gap, coordinates `(false, false)`) and
`b = B` (glut, `(true, true)`). The truth meet combines evidence-for with `&&` and
evidence-against with `||`: `(false && true, false || true) = (false, true) = F`. So
`N ⊓ B = F`. The truth join does the reverse:
`(false || true, false && true) = (true, false) = T`, so `N ⊔ B = T`. The gap and the
glut, meeting, fall to falsity; joining, they rise to truth — they are the two
incomparable middle points of the diamond, and combining them collapses to a pole.

**Example 2 (De Morgan law).** Continuing, `neg(N ⊓ B) = neg F = T`, while
`neg N ⊔ neg B = N ⊔ B = T`. The two sides agree, illustrating Theorem 4.5.

**Example 3 (Glut classification).** For `a = T`: `designated T` holds, but
`neg T = F` and `designated F` is false, so `T` is *not* a glut. For `a = B`:
`designated B` holds and `neg B = B` is designated, so `IsGlut B` holds — confirming
Theorem 5.3 that `B` is the unique glut.

**Example 4 (Explosion fails).** Instantiate the explosion premise at `a = B`:
`designated B` and `designated (neg B) = designated B` both hold. Choose the conclusion
`q = F`: `designated F` is false. Hence the implication
`designated B → designated (neg B) → designated F` is false, refuting `Explosive`
(Theorem 6.2, ⟸ direction) with the explicit witness `(B, F)`.

**Example 5 (Classical contrast).** In `Bool`, the explosion premise `b ∧ ¬b` is
`b = true ∧ (!b) = true`, satisfiable by no `b`; the implication
`b = true → (!b) = true → q = true` therefore holds for every `q` vacuously
(Theorem 6.4). The difference between FOUR and `Bool` is precisely the satisfiability
of the contradiction premise, which §6 shows is equivalent to the presence of a glut.

**Example 6 (Bridge).** Let `v(k) = B` for even `k` and `v(k) = T` for odd `k`. The
glut locus is `{0, 2, 4, …}`, the evens. Each singleton `{2k}` is finite, hence
dream-open in `dreamNat`; their union is the evens, which is infinite and not all of
`ℕ`, hence not dream-open (Theorem 8.3). So `v` is paraconsistent yet its glut locus is
the escaped union — the metalogical and topological defects coincide (Theorem 8.6).

## 10. Applications

- **Inconsistency-tolerant databases.** Annotate each tuple with a Belnap value;
  conflicting updates produce `B` rather than corrupting the relation. Theorem 6.2
  guarantees queries do not trivialize.
- **Sensor fusion.** Two sensors disagreeing on a binary reading yields `B`;
  downstream logic continues to reason about all other readings.
- **Belief revision and the semantic web.** Aggregating contradictory assertions from
  multiple ontologies is safe: gluts localize inconsistency to their locus.
- **Static analysis / abstract interpretation.** The diamond `2 × 2` is a standard
  abstract domain; the De Morgan and distributivity laws license the usual algebraic
  simplifications.

---

## 11. Discussion and future work

The main methodological point is that a metalogical property (non-explosion) has been
reduced to a one-point algebraic condition (existence of a designated glut, located at
`B`). This localization is what makes the bridge to dream spaces possible: paraconsis-
tency lives at a *set* of points — the glut locus — and that set can be studied with
the tools of (generalized) topology.

Several directions follow naturally:

1. **Glut-preservation under lattice homomorphisms.** Characterize which
   homomorphisms `φ : Belnap → L` into a bounded distributive lattice with designation
   transport non-explosion. Conjecture: `φ` preserves paraconsistency iff `φ B` is a
   glut in `L`. Since Theorem 6.2 localizes paraconsistency at `B`, preservation should
   reduce to the image of `B` alone.

2. **Topological completion and defect measure.** Close `dreamNat` under arbitrary
   unions to obtain its completion; conjecturally the discrete topology, with the set
   of newly-opened sets having cardinality `2^{ℵ₀}`.

3. **Paraconsistent valuations as dream-space points.** The space of Belnap valuations
   on countably many variables should carry a non-topological dream-space structure
   whose non-topological points are exactly the valuations assigning `B` to infinitely
   many variables.

4. **Graded paraconsistency.** Generalize the four-element diamond to a continuous
   family parameterizing a "degree of contradiction" in `[0, 1]`; the number of gluts
   in a De Morgan algebra is governed by the width of the lattice between `F` and `T`.

5. **Non-monotone belief revision as dream-space dynamics.** Adding/removing dream-open
   sets models learning/retraction; the resulting category should correspond to
   Belnap-valued Kripke frames with non-monotone accessibility.

---

## 12. Conclusion

Belnap's FOUR is a bounded distributive lattice with an order-reversing De Morgan
involution, exactly four elements, a unique glut `B`, and a unique gap `N`. Its
paraconsistency is not a stipulation but a theorem: non-explosion is *equivalent* to
the existence of a designated glut. The same glut that makes contradiction expressible
makes explosion fail. Pushed into geometry, the glut locus of a paraconsistent
valuation becomes a non-closed set in a non-topological dream space — the metalogical
and topological defects literally coincide. All results have been machine-verified.
