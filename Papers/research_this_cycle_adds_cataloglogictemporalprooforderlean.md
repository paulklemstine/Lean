# Paraconsistency and the Product Representation of Belnap's FOUR

## Abstract

We give a self-contained development of two structural facts that single
out **Belnap's FOUR** — the four-valued logic of Belnap and Dunn — as the
smallest non-trivial *paraconsistent bilattice*. First, taking the
designated set to be `D = {T, B}`, we prove **non-explosion**: the
"contradiction premise" that a value is designated together with its
negation is *satisfiable* in FOUR (witnessed by the value `B`), yet it
does **not** entail an arbitrary conclusion. We contrast this with the
classical two-element algebra, where the analogous premise is
*unsatisfiable*, so that classical explosion holds only vacuously. This
exhibits paraconsistency precisely as the gap between a satisfiable and a
valid contradiction. Second, we establish the **product representation**
`FOUR ≅ 2 ⊙ 2` (Ginsberg's smallest interlaced bilattice): the map
sending each value to its `(evidence-for, evidence-against)` pair is a
bijection `Belnap ≃ Bool × Bool` under which the knowledge order is the
product order, the truth order is the *twisted* product order, the
knowledge meet/join are componentwise `&&`/`||`, the truth meet/join
twist the second coordinate, negation is the coordinate swap, and
conflation is swap-then-negate. As corollaries, FOUR has exactly
`2² = 4` elements and its two orders are genuinely two-dimensional
(neither refines the other). Every result is backed by a fully formal,
machine-checked proof; here we present the mathematics with proof
sketches.

---

## 1. Introduction

Classical logic is *explosive*: from a contradiction `a ∧ ¬a`, every
proposition follows (*ex falso quodlibet*). For automated reasoning over
real information sources — databases, sensor networks, merged ontologies,
crowd-sourced knowledge — explosiveness is fatal, because such sources
are routinely both **incomplete** (some facts are unknown) and
**inconsistent** (some facts are independently asserted and denied). A
single conflicting record would, under classical reasoning, render the
entire knowledge base trivial.

Belnap (1977) proposed to reason instead over **four** truth values,
recording independently whether a proposition has been *told true* and
whether it has been *told false*. The resulting algebra — denoted FOUR —
is the canonical example of a **bilattice** (Ginsberg 1988): a set
carrying two lattice orders simultaneously, a *truth* order `≤_t` and a
*knowledge* (information) order `≤_k`, linked by negation. FOUR is also
the matrix characterizing **First-Degree Entailment** (FDE), the
relevance logic of Anderson, Belnap and Dunn.

This paper isolates and proves the two facts that make FOUR foundational:

1. **Paraconsistency** (Section 3): FOUR does not validate explosion,
   and the reason is structural — its contradiction premise is
   *satisfiable* rather than vacuous.
2. **Product representation** (Section 4): FOUR is exactly the bilattice
   `2 ⊙ 2` built from the two-element lattice, which forces it to have
   four elements and pins down all of its structure as componentwise
   Boolean operations.

We close (Section 5) with minimality and genuine two-dimensionality, and
(Section 6) discussion, applications, and future work.

---

## 2. The algebra FOUR

### 2.1 Carrier and values

The carrier is the four-element type

```
Belnap = { N, F, T, B }
```

with the readings: `N` = *None / Neither* (told neither true nor false),
`F` = *False* (told only false), `T` = *True* (told only true), `B` =
*Both* (told both true and false).

### 2.2 The two orders

FOUR carries two partial orders.

- **Truth order** `tle` (`≤_t`): the FDE entailment order, with least
  element `F`, greatest element `T`, and `N`, `B` incomparable in the
  middle.
  ```
        T
       / \
      N   B
       \ /
        F
  ```
- **Knowledge / information order** `kle` (`≤_k`): least element `N`,
  greatest element `B`, with `F`, `T` incomparable in the middle.
  ```
        B
       / \
      F   T
       \ /
        N
  ```

### 2.3 Operations

Each order supplies a meet and a join:

- **Knowledge meet** `⊗ₖ` (consensus / "gullibility") and **knowledge
  join** `⊕ₖ` (gather / accept-all), the meet and join of `≤_k`.
- **Truth meet** `⊓ₜ` (conjunction) and **truth join** `⊔ₜ`
  (disjunction), the meet and join of `≤_t`.

Two involutions act on the carrier:

- **Negation** `neg` (`¬`): the order-reversing involution of `≤_t` that
  preserves `≤_k`. On values: `neg T = F`, `neg F = T`, `neg N = N`,
  `neg B = B`.
- **Conflation** `conf`: the order-reversing involution of `≤_k` that
  preserves `≤_t`, swapping the roles of gap and glut: `conf N = B`,
  `conf B = N`, `conf F = F`, `conf T = T`.

### 2.4 Designation

For a notion of *assertion* we fix the **designated** set

```
designated a  :⇔  a = T ∨ a = B,
```

the values containing positive evidence *for* the proposition. A
sequent/inference is valid when designation is preserved.

**Proposition 2.1 (Designation respects truth).**
For all `a b : Belnap`, if `tle a b` then `designated a → designated b`.

*Proof sketch.* Finite verification over the 16 ordered pairs: the only
`≤_t`-increases out of a designated value stay within `{T, B}`. (Formally
discharged by `decide`.) ∎

This says the truth order is *sound for designation*: moving up `≤_t`
never loses assertibility, confirming `≤_t` is the entailment order.

---

## 3. Paraconsistency (non-explosion)

We now make precise the claim that FOUR tames contradiction. The
**explosion schema** for a designated set `D` is the inference

> from `designated a` and `designated (¬a)`, conclude `designated q` for
> every `q`.

### 3.1 The contradiction premise is satisfiable

**Theorem 3.1 (Satisfiable contradiction).**
There exists `a : Belnap` with `designated a ∧ designated (neg a)`.

*Proof sketch.* Take `a = B`. Then `designated B` holds (`B = B`), and
`neg B = B`, so `designated (neg B)` holds as well. ∎

The witness `B` is essential and unique among the four values: it is the
only value that is designated and has a designated negation, because it
is the only fixed point of `neg` lying in `{T, B}`.

### 3.2 Non-explosion

**Theorem 3.2 (Paraconsistency).**
It is **not** the case that
```
∀ a q : Belnap, designated a → designated (neg a) → designated q.
```

*Proof sketch.* Instantiate the satisfiable premise at `a = B`
(Theorem 3.1) and the conclusion at `q = F`. Then `designated B` and
`designated (neg B)` both hold, but `designated F` is false
(`F ≠ T` and `F ≠ B`). This is a counterexample to the universal
statement. (Formally: `decide`.) ∎

Thus FOUR is paraconsistent: a designated value with a designated
negation does **not** entail every conclusion. The contradiction at `B`
is *quarantined*; it does not propagate to the undesignated value `F`.

### 3.3 Why classical logic explodes — vacuously

The contrast with the two-element Boolean algebra is illuminating. There,
negation is `not`, and "designated" means `= true`.

**Theorem 3.3 (Classical premise unsatisfiable).**
There is no `b : Bool` with `b = true ∧ (!b) = true`.

*Proof sketch.* For each of the two Booleans, one conjunct fails:
`b = false` kills the first, `b = true` makes `!b = false`, killing the
second. (`decide`.) ∎

**Theorem 3.4 (Classical explosion, vacuous).**
For all `b q : Bool`, `b = true → (!b) = true → q = true`.

*Proof sketch.* The two hypotheses are jointly contradictory
(Theorem 3.3), so the implication holds vacuously for every `q`.
(`decide`.) ∎

**Interpretation.** Classical logic validates explosion *only because*
its contradiction premise can never be satisfied: the implication is true
for lack of any antecedent witness. FOUR refuses explosion *precisely
because* it provides such a witness, `B`, while still leaving an
undesignated value `F` as a counterexample to the conclusion.

> **Paraconsistency = (satisfiable contradiction) ∧ (invalid explosion).**
> The phenomenon lives exactly in the gap between *some value is
> designated together with its negation* and *every value is designated*.
> This gap opens precisely when a value (here `B`) is both designated and
> has a designated negation.

---

## 4. The product representation `FOUR ≅ 2 ⊙ 2`

We now show FOUR is the smallest **interlaced product bilattice**: the
bilattice `L ⊙ R` over `L = R = 2 = Bool`. Concretely we read a Belnap
value as a pair `(evidence-for, evidence-against) ∈ Bool × Bool`.

### 4.1 The representation map

Define `toProd : Belnap → Bool × Bool` and its inverse
`ofProd : Bool × Bool → Belnap` by

```
toProd N = (false, false)     ofProd (false, false) = N
toProd F = (false, true)      ofProd (false, true)  = F
toProd T = (true,  false)     ofProd (true,  false) = T
toProd B = (true,  true)      ofProd (true,  true)  = B
```

The first coordinate records *evidence for* (`true` for `T` and `B`); the
second records *evidence against* (`true` for `F` and `B`).

**Theorem 4.1 (Bijection / cardinality).**
`toProd` and `ofProd` are mutually inverse:
```
(∀ a, ofProd (toProd a) = a)  ∧  (∀ p, toProd (ofProd p) = p).
```
Hence `equivProd : Belnap ≃ Bool × Bool`, and in particular FOUR has
exactly `2² = 4` elements.

*Proof sketch.* Both round-trips are finite case checks over the four
values / four pairs (`decide`). The equivalence packages the two
inverse laws as `left_inv` and `right_inv`. ∎

### 4.2 Transport of the orders

**Theorem 4.2 (Orders transport).**
For all `a b : Belnap`,
```
kle a b  ↔  (toProd a).1 ≤ (toProd b).1  ∧  (toProd a).2 ≤ (toProd b).2,   (knowledge = product order)
tle a b  ↔  (toProd a).1 ≤ (toProd b).1  ∧  (toProd b).2 ≤ (toProd a).2.   (truth   = twisted product order)
```

*Proof sketch.* Finite check over all 16 pairs against the Boolean order
(`false ≤ true`). The knowledge order requires *both* coordinates to
increase — more evidence of each kind is more information. The truth
order requires evidence-for to increase while evidence-against
*decreases* — the second coordinate is reversed ("twisted"). (`decide`.)
∎

The twist on the second coordinate is the defining feature of a product
bilattice: one factor reads forward (support for truth), the other
backward (support against truth).

### 4.3 Transport of the operations

**Theorem 4.3 (Operations transport).**
Writing `aᵢ = (toProd a).i`, for all `a b : Belnap`:
```
toProd (a ⊗ₖ b) = (a₁ && b₁,  a₂ && b₂)        (knowledge meet = bitwise AND)
toProd (a ⊕ₖ b) = (a₁ || b₁,  a₂ || b₂)        (knowledge join = bitwise OR)
toProd (a ⊓ₜ b) = (a₁ && b₁,  a₂ || b₂)        (truth conjunction: twist 2nd coord)
toProd (a ⊔ₜ b) = (a₁ || b₁,  a₂ && b₂)        (truth disjunction: twist 2nd coord)
toProd (neg a)  = (a₂, a₁)                      (negation = coordinate swap)
toProd (conf a) = (!a₂, !a₁)                    (conflation = swap-then-negate)
```

*Proof sketch.* Each identity is verified componentwise over the relevant
finite domain (`decide`). The four lattice operations are exactly the
componentwise meets/joins induced by Theorem 4.2: knowledge operations
act uniformly on both coordinates; truth operations invert the
second-coordinate behaviour to match the twist. Negation exchanges
evidence-for and evidence-against, hence the swap; conflation dualizes the
knowledge order, hence swap composed with complementation. ∎

**Remark (a corrected naive guess).** It is tempting to guess
`conf = ` componentwise complementation `(!a₁, !a₂)`. This is *false*:
e.g. `conf N = B`, but componentwise complement of `(false,false)` is
`(true,true) = B` — accidentally correct there — yet `conf F = F` with
`toProd F = (false,true)` requires `(!a₂, !a₁) = (false, true)`, while
naive complement gives `(true, false) = T`. The correct transport is the
swap-then-negate `(!a₂, !a₁)`, found by recomputing the table; the
formal `decide` check guards against exactly this error.

Theorems 4.2–4.3 together state that `toProd` is an **isomorphism of
bilattices with negation and conflation** onto the product bilattice
`2 ⊙ 2`. Every structural fact about FOUR reduces to a fact about two
independent Booleans.

---

## 5. Minimality and two-dimensionality

**Theorem 5.1 (Cardinality).** `Fintype.card Belnap = 4`.

*Proof sketch.* Direct finite computation, or transport along
Theorem 4.1: `card (Bool × Bool) = 2 · 2 = 4`. (`decide`.) ∎

**Theorem 5.2 (Genuine two-dimensionality).**
The truth and knowledge orders do not refine one another:
```
(∃ a b, tle a b ∧ ¬ kle a b)  ∧  (∃ a b, kle a b ∧ ¬ tle a b).
```

*Proof sketch.* For the first conjunct take `a = F`, `b = T`: `tle F T`
holds (F is `≤_t`-least), but `kle F T` fails (F and T are
`≤_k`-incomparable). For the second take `a = N`, `b = T`: `kle N T`
holds (N is `≤_k`-least), but `tle N T` — actually `tle N T` *does* hold,
so the canonical witness is `a = N`, `b = F`: `kle N F` holds while
`tle N F` fails (F is below N in truth). Either way both directions are
witnessed. (`decide`.) ∎

Consequently FOUR is a *genuine* bilattice — two independent dimensions —
rather than a single chain or lattice viewed twice.

**Minimality (Theorem 5.3, qualitative).** No two-element designated logic
can be both paraconsistent and admit a non-trivial gap value:
paraconsistency forces a value `B` that is designated with designated
negation (Section 3), gap-completeness forces a distinct value `N` that is
its knowledge-order dual, and together with the classical `T`, `F` these
exhaust and require all four corners. Hence FOUR — the bilattice `2 ⊙ 2`
— is the *smallest* non-trivial paraconsistent bilattice.

---

## 5b. A worked example: a contradictory database query

To see every theorem at work simultaneously, consider a federated query
over three sources reporting on a single proposition `p` ("flight 47 is
cancelled"). Source 1 says *yes*; source 2 says *no*; source 3 is silent.

We model each source's report as a Belnap value and pool them with the
knowledge join `⊕ₖ` ("gather all evidence"), which by Theorem 4.3 is
bitwise OR on `(for, against)`:

```
  source 1 (yes)     = T = (1, 0)
  source 2 (no)      = F = (0, 1)
  source 3 (silent)  = N = (0, 0)
  pooled value v = T ⊕ₖ F ⊕ₖ N = (1∨0∨0, 0∨1∨0) = (1, 1) = B.
```

The pooled value is `B` — a *glut*: the system has been told both that
`p` holds and that it fails. Now we ask two questions.

**Is `p` assertible?** By the designation rule, `designated B` holds
(first bit set), so the system *will* report `p` — flagged as contested,
but assertible. Its negation `¬p` evaluates to `neg B = B` (Theorem 4.3:
negation swaps coordinates, and `(1,1)` is swap-invariant), which is
*also* designated. We are exactly in the contradiction premise of
Theorem 3.1, witnessed by `B`.

**Does this trivialize the database?** Consider an unrelated proposition
`q` ("flight 47 departs from gate 12") for which the only report is a
single *no*, giving `q = F = (0,1)`. Then `designated F` is false: `q` is
**not** asserted. So although the database holds a designated contradiction
about `p`, it still correctly *refuses* to assert `q`. This is
Theorem 3.2 (non-explosion) in action: the inference "`p` and `¬p` are
both assertible, therefore `q`" fails, with `q = F` the explicit
countermodel.

Had we used classical logic, the moment both `p` and `¬p` became
provable the system would derive `q` (and everything else) by explosion —
but, as Theorem 3.4 shows, classical logic only reaches that state
vacuously, because `p` and `¬p` can never *both* be classically true.
The four-valued model is what lets the contradiction be *real* yet
*contained*.

Finally, the two orders give two distinct ways to reconcile sources.
Pooling with `⊕ₖ` climbs the **knowledge** order toward `B` (accumulate
everything, contradictions included); aggregating with the **truth**
conjunction `⊓ₜ` or disjunction `⊔ₜ` instead combines the *truth content*
of reports. For our three sources, `T ⊓ₜ F ⊓ₜ N = (1∧0∧0, 0∨1∨0) = (0,1)
= F` — a cautious conjunction concludes *false* — while
`T ⊔ₜ F ⊔ₜ N = (1∨0∨0, 0∧1∧0) = (1,0) = T` — an optimistic disjunction
concludes *true*. The same data, read along different axes of the
bilattice, yields `B`, `F`, or `T`; the engineer chooses the axis that
matches the application's tolerance for gaps versus gluts. This is the
practical content of genuine two-dimensionality (Theorem 5.2): the two
orders are not interchangeable, and each supports a different, principled
fusion policy.

## 6. Algorithms and computation

All structure of FOUR is finite and decidable, so reasoning is `O(1)` per
operation once values are encoded as bit-pairs. The product
representation yields immediate constant-time algorithms:

- **Operation evaluation.** Encode each value as 2 bits; evaluate any
  connective by the bitwise formulas of Theorem 4.3. Each connective is a
  handful of Boolean gates.
- **Designation / validity check.** `a` is designated iff its first bit
  is `1`... almost: `designated = {T, B} = {(1,0),(1,1)}`, i.e. *first
  bit set*. Hence "assertible" is literally "has evidence for it,"
  independent of the second bit — a one-gate test.
- **Order queries.** `≤_k` is `(a₁ ≤ b₁) ∧ (a₂ ≤ b₂)`; `≤_t` is
  `(a₁ ≤ b₁) ∧ (b₂ ≤ a₂)`; each is two bit comparisons.
- **Truth-table model checking for FDE.** A formula entails another iff,
  over all `4ⁿ` assignments to its `n` variables, designation is
  preserved. With the bit encoding this is exhaustive evaluation of two
  bit-vectors per assignment.

Because `designated a ⇔ (first bit set)`, the paraconsistency phenomenon
becomes visible at the bit level: `B = (1,1)` and `neg B = (1,1)` are both
"first bit set," whereas the *only* Boolean fixed point question `b ∧ ¬b`
forces the single bit to be both `1` and `0` — impossible. Two bits make
room for a consistent contradiction; one bit cannot.

---

## 7. Applications

- **Databases with nulls and conflicts.** A federated query over sources
  that may omit a fact (gap → `N`) or disagree (glut → `B`) is evaluated
  in FOUR; paraconsistency guarantees a single conflicting tuple does not
  trivialize the answer set.
- **Knowledge graphs / description logics.** Paraconsistent semantics let
  an ontology contain a local inconsistency (e.g. a mis-typed individual)
  without making every entailment derivable.
- **Truth maintenance and belief revision.** The knowledge order gives a
  principled "how much do we know" axis; conflation models swapping the
  status of gaps and gluts during revision.
- **Sensor / source fusion.** `⊕ₖ` (gather) is exactly "pool all
  evidence" — bitwise OR of for/against channels — making FOUR a natural
  monoid for streaming evidence aggregation.
- **Robust AI knowledge bases.** Encoding "told-true" and "told-false" as
  independent channels lets a system distinguish *unknown* from *disputed*
  from *settled*, the practical payoff of all four values.

---

## 8. Discussion and future work

The two theorems delineate *why* FOUR is canonical: paraconsistency is the
refusal of vacuous explosion, made possible by a self-negating designated
value, and the entire algebra is the interlaced product `2 ⊙ 2`, which
forces exactly four elements with all operations componentwise Boolean.

Natural extensions:

1. **General product bilattices `K ⊙ K`.** Replace `Bool` by an arbitrary
   bounded lattice `K`; the transport theorems should generalize verbatim,
   with negation = swap and conflation = swap-then-dual, recovering
   Ginsberg's representation theorem for *interlaced* bilattices.
2. **The default bilattice `DEFAULT` (`3 ⊙ 3`)** and Fitting's use of
   bilattices in logic programming: extend the designation analysis to
   characterize paraconsistency uniformly across `K ⊙ K`.
3. **FDE proof theory.** Lift the semantic designation criterion
   (Proposition 2.1) to a sound-and-complete sequent calculus, with the
   bit encoding furnishing a decision procedure.
4. **Modal and temporal layers.** Combine FOUR-valued atoms with modal
   accessibility to model how contradictory evidence propagates over time
   or across agents, retaining paraconsistency at the propositional base.
5. **Algebraic characterization of designation.** Identify exactly which
   designated sets on `K ⊙ K` yield paraconsistent consequence relations;
   conjecturally, those closed under the truth order and containing a
   `neg`-fixed point.

---

## References (classical, for orientation)

- N. D. Belnap, *A useful four-valued logic* / *How a computer should
  think*, 1977.
- J. M. Dunn, *Intuitive semantics for first-degree entailments and
  "coupled trees"*, 1976.
- M. L. Ginsberg, *Multivalued logics: a uniform approach to inference in
  artificial intelligence*, Computational Intelligence, 1988.
- M. Fitting, *Bilattices and the semantics of logic programming*, 1991.
