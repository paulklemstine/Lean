# Dream Logic: Coexisting Contradictions in Four-Valued Paraconsistency and Their Topological Models

**Author:** Aristotle

**Date:** 2026-06-19

**Domain:** Logic (Paraconsistency, Topology, Non-monotone reasoning)

---

## Abstract

We present a fully formalized account of *paraconsistent* reasoning — logic in
which a contradiction is a contained, local phenomenon rather than a global
catastrophe — and we exhibit its precise topological semantics. On the algebraic
side we formalize Belnap's four-valued logic `FOUR` (the logic of First-Degree
Entailment), whose values are `true`, `false`, `both` (a *glut*: information
asserting a proposition and its negation), and `neither` (a *gap*: no
information either way). We prove that the Law of Non-Contradiction can fail
(`lnc_can_fail`), that the Law of Excluded Middle can fail (`lem_can_fail`), and
— the defining feature of paraconsistency — that *ex contradictione quodlibet*
("explosion") fails (`explosion_fails`): an accepted contradiction does not
entail an arbitrary proposition. We characterize the two impossible objects
exactly: `both` is the unique glut (`glut_iff`) and `neither` is the unique gap
(`gap_iff`), and we certify the contrast with classical logic
(`classical_no_glut`, `classical_explosion`).

On the geometric side we develop the closed-set co-Heyting model. Defining
paraconsistent negation as the closure of the complement, `pneg A := closure
Aᶜ`, and the contradiction set as `contradiction A := A ∩ pneg A`, we prove that
for a closed set the contradiction set is exactly the topological frontier
(`contradiction_eq_frontier`), that the Law of Non-Contradiction holds for a
closed set iff that set is *clopen* (`lnc_holds_iff_clopen`), and that on a
preconnected space every proper nonempty closed set carries a nonempty
contradiction set (`connected_forces_paraconsistency`). A concrete dialetheia is
exhibited in `ℝ`: the point `0` is a coexisting contradiction of `[0,1]`
(`dream_object_real`). These two developments are linked by the dictionary
identifying a topological frontier point with the Belnap glut value `both`.

---

## 1. Introduction

Classical logic is governed by two principles inherited from Aristotle. The
**Law of Non-Contradiction (LNC)** forbids any proposition from being both true
and false. The **principle of explosion**, *ex contradictione quodlibet* (ECQ),
states that from a contradiction every proposition follows: `P, ¬P ⊢ Q` for
arbitrary `Q`. ECQ makes classical logic *brittle* with respect to inconsistency:
a single accepted contradiction trivializes the entire theory.

Real reasoning — scientific theories during periods of anomaly, large knowledge
bases merged from conflicting sources, legal and ethical deliberation, and the
phenomenology of dreams — routinely tolerates local inconsistency without
collapsing into triviality. *Paraconsistent* logics formalize this: they are
logics in which ECQ fails, so that contradictions can be quarantined. *Dialetheic*
positions go further and accept that some contradictions are *true*; the
true-and-false propositions are called **dialetheias**, or, in our metaphor,
*impossible objects* — objects that coexist with their own negation.

This paper formalizes two complementary faces of paraconsistency and proves they
are aspects of a single phenomenon:

1. **An algebraic semantics** — Belnap's four-valued logic `FOUR`, the canonical
   matrix for First-Degree Entailment (FDE). Here gluts and gaps are first-class
   truth values, and the failure of LNC, LEM, and ECQ are exact, provable facts.

2. **A topological semantics** — the co-Heyting (Brouwerian) algebra of closed
   sets of a topological space, where paraconsistent negation is closure of the
   complement, and where the dialetheias are precisely the boundary points of
   shapes.

The bridge between them is the central conceptual payoff: a *topological frontier
point is a Belnap glut*. All results below are mechanically verified.

### 1.1 Note on the guiding slogan

The informal brief that motivated this work spoke of "topological spaces where
open sets are not closed under arbitrary union." Taken literally this is false:
the axioms of a topology *require* open sets to be closed under arbitrary union.
A central methodological finding of the project is that the correct dual reading
is **"closed sets need not be open"** — and that paraconsistency lives exactly in
the gap between *closed* and *clopen*. Theorem `lnc_holds_iff_clopen` makes this
precise.

---

## 2. The four-valued logic `FOUR`

### 2.1 Definitions

**Definition 2.1 (Truth values).** Let `FOUR = {true, false, both, neither}`.
The four values answer the question *what does our information say about a
proposition?*

- `true`: information establishes it holds (and nothing contradicts);
- `false`: information establishes it fails;
- `both`: a **glut** — information asserts it holds *and* asserts it fails;
- `neither`: a **gap** — no information either way.

**Definition 2.2 (Truth order).** `FOUR` is partially ordered by *information
truth-content*, with `false` least, `true` greatest, and `both`, `neither`
incomparable in the middle (the "diamond"):

```
            true
           /    \
        both    neither
           \    /
           false
```

**Definition 2.3 (Connectives).**
- **Conjunction** `conj x y` is the lattice meet (greatest lower bound) in the
  diamond order.
- **Disjunction** `disj x y` is the lattice join (least upper bound).
- **Negation** `neg` is the order-reversing involution that swaps `true ↔ false`
  and fixes both impossible objects: `neg both = both`, `neg neither = neither`.

Explicitly, negation is given by

| `x`       | `neg x`   |
|-----------|-----------|
| `true`    | `false`   |
| `false`   | `true`    |
| `both`    | `both`    |
| `neither` | `neither` |

and conjunction/disjunction by the meet/join tables of the diamond. For example
`conj both false = false`, `conj both true = both`, `disj neither false =
neither`, `disj neither true = true`.

**Definition 2.4 (Designation).** A value is **designated** (asserted, believed)
iff it carries at least a grain of truth:

> `designated x  :⟺  x = true ∨ x = both`.

Designation is the consequence relation's notion of "holding": an inference is
valid when designated premises force a designated conclusion.

### 2.2 Glut and gap, made exact

**Definition 2.5 (Glut, gap).**
- `x` is a **glut** iff `designated (conj x (neg x))` — its conjunction with its
  own negation is asserted (a *coexisting contradiction*).
- `x` is a **gap** iff `¬ designated (disj x (neg x))` — its disjunction with its
  own negation fails to be asserted (excluded middle fails at `x`).

**Theorem 2.6 (`glut_iff`).** `x` is a glut iff `x = both`.

*Proof sketch.* Finite case analysis over the four values. For `true`:
`conj true (neg true) = conj true false = false`, undesignated. For `false`:
symmetric, value `false`. For `neither`: `conj neither neither = neither`,
undesignated. For `both`: `conj both (neg both) = conj both both = both`,
designated. Hence `both` is the only glut. ∎

**Theorem 2.7 (`gap_iff`).** `x` is a gap iff `x = neither`.

*Proof sketch.* Dual case analysis. `disj true (neg true) = true` and `disj false
(neg false) = true` are designated; `disj both both = both` is designated; only
`disj neither neither = neither` is undesignated. ∎

### 2.3 Failure of the classical laws

**Theorem 2.8 (`lnc_can_fail`).** There exists `x` with `designated (conj x (neg
x))`; equivalently, the Law of Non-Contradiction fails in `FOUR`.

*Proof sketch.* Witness `x = both`; `conj both (neg both) = both` is designated.
This is the existential extract of Theorem 2.6. ∎

**Theorem 2.9 (`lem_can_fail`).** There exists `x` with `¬ designated (disj x
(neg x))`; the Law of Excluded Middle fails.

*Proof sketch.* Witness `x = neither`; `disj neither (neg neither) = neither` is
undesignated. This is the existential extract of Theorem 2.7. ∎

**Theorem 2.10 (`explosion_fails`, paraconsistency).** There exist values `p, q`
such that `p` is an accepted contradiction (both `p` and `neg p` are designated)
yet `q` is *not* designated. Hence the inference schema "from `p` and `¬p`,
conclude `q`" is invalid: ECQ fails.

*Proof sketch.* Take `p = both` and `q = false`. Then `p` and `neg p = both` are
both designated, so the premises of explosion hold; but `q = false` is
undesignated, so the conclusion fails. The accepted contradiction at `both` does
not propagate to the unrelated `false`. ∎

Theorem 2.10 is the defining property: `FOUR` *tolerates* contradiction. Together
with Theorem 2.9, `FOUR` is simultaneously **paraconsistent** (tolerates gluts)
and **paracomplete** (tolerates gaps).

### 2.4 Classical contrast

To certify that these failures are features of `FOUR` rather than artifacts of
the ambient metalogic, we record the Boolean facts.

**Theorem 2.11 (`classical_no_glut`).** In the two-valued Boolean algebra (with
ordinary `∧`, `¬`, and `designated b := b = true`), no value is a glut:
`b ∧ ¬b` is never designated.

**Theorem 2.12 (`classical_explosion`).** In the Boolean algebra, ECQ holds: if
`b` and `¬b` are both designated then every `c` is designated (vacuously, since
the premise is unsatisfiable).

The difference between Theorems 2.10–2.11 quantifies precisely what is gained by
moving from two to four values: the existence of a satisfiable, designated,
non-explosive contradiction.

---

## 3. The topological model of paraconsistency

The Tarski–McKinsey duality models *intuitionistic* logic in the Heyting algebra
of **open** sets of a topological space, with intuitionistic negation `¬A :=
interior(Aᶜ)`. The order-theoretic dual replaces open with **closed** sets,
yielding a *co-Heyting* (Brouwerian) algebra, the natural home of paraconsistent
negation.

Throughout, `X` is a topological space, `Aᶜ` is the set complement, `closure`,
`interior`, and `frontier` are the standard operators, and `frontier A = closure
A ∩ closure Aᶜ`.

### 3.1 Definitions

**Definition 3.1 (Paraconsistent negation).** For `A ⊆ X`,

> `pneg A := closure Aᶜ`.

Unlike intuitionistic negation (interior of the complement), `pneg` adds the
boundary back on, keeping us inside the algebra of closed sets when `A` is
closed.

**Definition 3.2 (Contradiction set).** For `A ⊆ X`,

> `contradiction A := A ∩ pneg A = A ∩ closure Aᶜ`.

A point of `contradiction A` lies in `A` and is simultaneously a limit of points
outside `A`: a topological dialetheia, an *impossible object* that is both "in"
and "out."

### 3.2 Contradiction equals frontier

**Theorem 3.3 (`contradiction_eq_frontier`).** If `A` is closed, then

> `contradiction A = frontier A`.

*Proof sketch.* By definition `frontier A = closure A ∩ closure Aᶜ`. For closed
`A`, `closure A = A`, so `frontier A = A ∩ closure Aᶜ`. The right-hand side is
exactly `A ∩ pneg A = contradiction A`. (Formally: rewrite `pneg` via `closure`
of the complement, use `IsClosed.frontier_eq`, and simplify the set-difference
form `frontier A = A \ interior A`.) ∎

This identity is the semantic core: for closed beliefs, *coexisting
contradictions are exactly boundary points.*

### 3.3 Non-contradiction characterizes clopen sets

**Theorem 3.4 (`lnc_holds_iff_clopen`).** For closed `A`,

> `contradiction A = ∅  ⟺  A is clopen`.

*Proof sketch.* By Theorem 3.3, `contradiction A = ∅` iff `frontier A = ∅`. A
standard topological fact (`isClopen_iff_frontier_eq_empty`) states that a set is
clopen iff its frontier is empty. Compose. ∎

**Corollary 3.5 (`not_clopen_contradiction`).** A closed set that is not clopen
has a nonempty contradiction set.

*Proof sketch.* Contrapositive of the forward direction of Theorem 3.4: if
`contradiction A` were empty, `A` would be clopen. ∎

Theorem 3.4 is the precise, true form of the guiding slogan. Classical
(non-contradictory) behavior for a closed set occurs *exactly* on the clopen
sets; genuine paraconsistency appears precisely where a closed set fails to be
open.

### 3.4 A concrete impossible object in `ℝ`

**Theorem 3.6 (`dream_object_real`).** In `ℝ`, `0 ∈ contradiction([0,1])`.

*Proof sketch.* `[0,1]` is closed (`isClosed_Icc`), so by Theorem 3.3 its
contradiction set is `frontier [0,1] = {0,1}` (`frontier_Icc`, using `0 ≤ 1`).
Then `0 ∈ {0,1}`. ∎

**Corollary 3.7 (`contradiction_nonempty_real`).** `contradiction([0,1])` is
nonempty in `ℝ`.

The point `0` belongs to `[0,1]` and is a limit of negative reals outside it; it
is a genuine dialetheia realized on the number line.

### 3.5 Connectedness forces paraconsistency

**Theorem 3.8 (`connected_forces_paraconsistency`).** Let `X` be a preconnected
space and `A ⊆ X` closed with `A` nonempty and `Aᶜ` nonempty (i.e. `A` is a
*proper, nontrivial* belief). Then `contradiction A` is nonempty.

*Proof sketch.* By Corollary 3.5 it suffices to show `A` is not clopen. Suppose
it were. In a preconnected space the only clopen sets are `∅` and `X`
(`isClopen_iff`). If `A = ∅` this contradicts `A` nonempty; if `A = X` then `Aᶜ =
∅`, contradicting `Aᶜ` nonempty. Hence `A` is not clopen, and `contradiction A`
is nonempty. ∎

**Interpretation.** On a connected space, the only contradiction-free closed
beliefs are the two trivial ones (believe nothing, believe everything). *Every*
proper belief is dialetheic. Connectedness — geometric unity — *forces* dream
logic. The hypotheses `A.Nonempty` and `Aᶜ.Nonempty` are load-bearing: without
properness the frontier may be empty (e.g. `A = X`).

---

## 4. The bridge: frontier points are gluts

The four-valued and topological semantics are two presentations of one structure.
Given a closed set `A`, define a pointwise valuation `val_A : X → FOUR` recording
membership in `A` and in `pneg A`:

- in `A` only ⟶ `true`;
- in `pneg A` only ⟶ `false`;
- in both ⟶ `both`;
- in neither ⟶ `neither`.

Because `A` is closed and `pneg A = closure Aᶜ`, every point lies in `A ∪ pneg A`
(their union is all of `X`), so the value `neither` cannot occur for closed `A`;
the available values are `true`, `false`, and `both`.

**Bridge principle (`val_both_iff_frontier`).** `val_A x = both` iff `x ∈
frontier A`. Combined with Theorem 3.3 (`glut_iff_contradiction`): a point
receives the Belnap glut value `both` precisely when it is a coexisting
contradiction of `A`. The concrete witness of Theorem 3.6 is then a literal glut
(`dream_object_real_is_glut`): the valuation of `[0,1]` assigns `both` to the
point `0`.

This identifies the *unique glut value* of Theorem 2.6 with the *boundary points*
of Theorem 3.3 — algebra and geometry naming the same impossible object.

---

## 5. Algorithms

The finite, decidable core of `FOUR` makes the logic directly computable. We
record the central procedures (full Python in the accompanying demo and package).

### 5.1 Truth-table evaluation of `FOUR`

Encode each value by its pair of *bits of evidence* `(t, f)` where `t` = "asserted
true" and `f` = "asserted false":

- `true  = (1,0)`, `false = (0,1)`, `both = (1,1)`, `neither = (0,0)`.

Then, remarkably, the connectives are *bitwise*:

- `conj`: take the componentwise behavior of the diamond meet, which reduces to
  `t = t1 ∧ t2`, `f = f1 ∨ f2`;
- `disj`: `t = t1 ∨ t2`, `f = f1 ∧ f2`;
- `neg`: swap the bits, `(t,f) ↦ (f,t)`;
- `designated (t,f) := (t = 1)`.

This representation (the "Belnap bilattice" coordinates) makes evaluation `O(1)`
per connective and an `n`-variable formula computable over all `4ⁿ` assignments
in `O(4ⁿ · |formula|)`.

### 5.2 Paraconsistency checker (countermodel search)

Given a candidate entailment "premises ⊢ conclusion," search all `4ⁿ`
assignments for one making every premise designated and the conclusion
undesignated. If found, the entailment is *invalid* and the assignment is an
explicit countermodel. Applied to `P, ¬P ⊢ Q`, this returns the countermodel
`P = both, Q = false`, mechanizing Theorem 2.10.

### 5.3 Contradiction set via frontier

For the topological side over a discretized domain, approximate `contradiction A
= frontier A` by flagging grid points of `A` that have a neighbor outside `A`.
This realizes Theorem 3.3 numerically and recovers `{0,1}` for `[0,1]`.

---

## 6. Applications

- **Inconsistency-tolerant databases and knowledge fusion.** Merging conflicting
  sources yields gluts; `FOUR` lets queries return useful answers about the
  consistent part without explosion (Theorem 2.10).
- **Belief revision and non-monotone update.** Gaps (`neither`) model retracted
  or suspended beliefs; the interior/closure operators of the topological model
  give idempotent *retraction* and *revision* operators (see Future Directions).
- **Region connection and spatial reasoning.** Theorem 3.3 ties qualitative
  spatial calculi (boundaries, contact) to a logical semantics, and Theorem 3.8
  explains why genuinely connected regions cannot be described
  contradiction-free.
- **Robust automated reasoning.** A paraconsistent core prevents a single faulty
  axiom from trivializing a large derived theory.

---

## 7. Discussion

The two semantics illuminate each other. The algebraic `FOUR` makes the *logical*
content sharp: LNC and LEM fail at exactly one value each, and explosion fails
because designation does not propagate through an isolated glut. The topological
model makes the *structural* content sharp: dialetheias are boundaries, classical
behavior is clopen-ness, and connectedness forces contradiction. The bridge
(`val_both_iff_frontier`) shows these are not analogies but coordinates on one
object.

A philosophical reading of Theorem 3.8 is worth emphasizing. Intuition suggests
that a perfectly coherent, seamless world should be the one most free of
contradiction. The mathematics says the reverse: it is precisely the *connected*
(seamless) worlds in which every nontrivial belief is dialetheic. To avoid all
impossible objects, a space must already be disconnected into clopen pieces.

A methodological lesson: the original slogan ("open sets not closed under
arbitrary union") was literally false, and locating its correct content
("closed need not be clopen") was itself a result of the investigation —
crystallized in `lnc_holds_iff_clopen`.

---

## 8. Future directions

**Conjecture 1 — The clopen algebra is the largest classical sublogic.** For a
space `X`, the Boolean algebra of clopen sets is the unique maximal subfamily of
closed sets on which `contradiction A = ∅` for every member, and the four-valued
valuation collapses to two values exactly there. Classical reasoning is recovered
precisely on the clopen sets, so "how classical" a space is can be measured by
the cardinality of its clopen algebra. Building on `lnc_holds_iff_clopen`, the
maximality claim is a finite combinatorial step, testable on finite spaces and
`ℝⁿ`.

**Conjecture 2 — Frontier dimension grades the severity of a contradiction.**
Order dialetheic closed sets by the topological dimension of their frontier. In
`ℝⁿ`, the glut content of a closed set should be a monotone function of `dim
(frontier A)`, with the clopen (empty-frontier) case at the bottom. A
point-frontier dialetheia (`[0,1]`, frontier `{0,1}`) is "smaller" than a
hypersurface-frontier dialetheia (a closed ball, frontier a sphere). Via
`contradiction_eq_frontier` this reduces to dimension theory of frontiers; the
`n = 1` base case is computable from `frontier_Icc`.

**Conjecture 3 — Belief retraction = interior; revision = closure.** Model
non-monotone update on `FOUR`-valuations by the idempotent operators `A ↦
interior A` (retraction: kills gluts) and `A ↦ closure A` (revision: may create
gluts). Conjecture: every finite sequence of retract/revise operations stabilizes
(reaches a regular open or regular closed set).

---

## 9. Conclusion

We have formalized paraconsistent "dream logic" in two registers and proved them
to coincide. Belnap's `FOUR` hosts accepted contradictions without explosion
(`explosion_fails`), with `both` the unique glut (`glut_iff`) and `neither` the
unique gap (`gap_iff`). The closed-set topological model identifies coexisting
contradictions with boundaries (`contradiction_eq_frontier`), classical behavior
with clopen-ness (`lnc_holds_iff_clopen`), and proves that connectedness forces
paraconsistency (`connected_forces_paraconsistency`), with `0 ∈ [0,1]` a concrete
dialetheia (`dream_object_real`). Contradiction, handled with the right algebra,
is just another truth value; handled with the right geometry, just an edge; and
in any connected world, it is the unavoidable price of belief.
