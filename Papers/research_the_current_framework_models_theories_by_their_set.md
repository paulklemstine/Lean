# An Abstract Order Geometry of Proof-Theoretic Ordinals: Totality, Lattice Homomorphism, and a Directed Quasi-Metric

## Abstract

Proof-theoretic ordinal analysis assigns to each formal theory a transfinite
ordinal — its *proof-theoretic ordinal* (PTO) — measuring the supremum of the
ordinals it can prove well-ordered. We develop a purely order-theoretic
abstraction of this assignment in which a theory is identified with its set of
provably well-ordered ordinals: a bounded, downward-closed set of ordinals,
which we call an **OrdinalTheory**. Its PTO is the supremum of that set. Working
in this minimal setting we establish four structural results. First, the
inclusion order on OrdinalTheories is **total**: downward-closed subsets of the
ordinals are nested, so theory-space is a single chain. Second, OrdinalTheories
form a **lattice** (join = union, meet = intersection) and the PTO map is a
**lattice homomorphism** onto the ordinals: it sends join to max and meet to min.
Third, the PTO map's fibers are **order-convex** (intervals of the chain), even
though the map is not injective. Fourth, we analyze the natural symmetric
ordinal-valued separation `depthDist(T₁,T₂) = (PTO T₁ − PTO T₂) + (PTO T₂ − PTO
T₁)`: it is symmetric, vanishes exactly on equal PTO, and is **exactly additive
along chains**, hence satisfies the *directed* triangle inequality with equality;
but it **provably violates the general (symmetric) triangle inequality**, with an
explicit counterexample at the PTO triple (ω+1, ω, 0) driven by the
non-commutativity 1 + ω = ω. Thus `depthDist` is a directed quasi-metric, not a
pseudometric. All results have been formalized and machine-checked. We close with
research directions on the additive-principal boundary of the triangle inequality
and a Hessenberg (natural-sum) metric repair.

**Keywords:** proof-theoretic ordinal, ordinal analysis, well-ordering, initial
segment, lattice homomorphism, quasi-metric, ordinal arithmetic, additive
principal ordinal.

---

## 1. Introduction

### 1.1 Background

Ordinal analysis, inaugurated by Gentzen's 1936/38 consistency proof of Peano
Arithmetic, attaches to a theory `T` an ordinal `|T|`, its proof-theoretic
ordinal, characterized (in one of several equivalent ways) as the supremum of the
order types of the primitive-recursive well-orderings that `T` proves to be
well-founded. The canonical values — `|PA| = ε₀`, `|ATR₀| = Γ₀`, and the
Bachmann–Howard ordinal for stronger systems — are central invariants of
mathematical logic, encoding both consistency strength and the provably total
recursive functions of a theory.

The classical theory is inseparable from syntax: arithmetized provability,
ordinal notation systems, cut elimination. This paper isolates the
*order-theoretic skeleton* of the PTO assignment and asks what can be proved when
syntax is discarded entirely.

### 1.2 The abstraction

We model a theory by the **set of ordinals it certifies well-ordered**. This set
is bounded above (a theory has finite consistency strength) and downward closed
(certifying a well-ordering certifies all shorter ones). Stripped to these two
properties, a theory becomes a bounded initial segment of the ordinals, and its
PTO becomes a supremum. The payoff is that statements about *all* theories become
statements about *all bounded initial segments of the ordinals*, provable with
the order theory of `Ordinal`.

### 1.3 Contributions

1. **Totality (Theorem 4.1).** The inclusion order on OrdinalTheories is total.
2. **Lattice homomorphism (Theorems 5.3, 5.4).** PTO sends join to max and meet
   to min.
3. **Order-convex fibers (Theorem 7.1).** PTO is constant on intervals with equal
   endpoints; its fibers are intervals.
4. **Directed quasi-metric (Theorems 6.2, 6.3, 6.5).** `depthDist` is exactly
   additive along chains (hence directed-triangle with equality) but violates the
   symmetric triangle inequality at (ω+1, ω, 0).

A handful of supporting results (half-saturation, monotonicity, sandwiching,
canonical PTO values) round out the development.

---

## 2. Preliminaries on ordinals

We work with the class `Ordinal` of ordinals, linearly ordered and well-founded
under `<`. We use the following standard facts.

- **Suprema.** For a set `S` of ordinals that is nonempty and bounded above,
  `sSup S` exists; `csSup_le` and `le_csSup` are the universal/existential
  characterizations, and `csSup_le_csSup` gives monotonicity.
- **Ordinal subtraction.** For ordinals `a, b`, `a − b` denotes the unique
  ordinal `c` with `b + c = a` when `b ≤ a`, and `a − b = 0` when `a ≤ b`
  (`Ordinal.sub_eq_zero_iff_le`). Key identity:
  `Ordinal.add_sub_cancel_of_le : b ≤ a → b + (a − b) = a`.
- **Non-commutativity.** Ordinal addition is associative but **not** commutative.
  The canonical witness is `1 + ω = ω` (`Ordinal.one_add_omega0`), while
  `ω + 1 > ω`.
- **Successor limits.** `Order.IsSuccLimit α` (α neither 0 nor a successor)
  satisfies `α = sup{β : β < α}` (`IsSuccLimit.sSup_Iio`). Also
  `sSup (Iio (α+1)) = sSup (Iic α) = α` and `Ordinal.isSuccLimit_omega0`.

---

## 3. The OrdinalTheory structure

**Definition 3.1 (OrdinalTheory).** An `OrdinalTheory` consists of:

- `provablyWO : Set Ordinal` — the ordinals the theory proves well-ordered;
- a proof that `provablyWO` is **bounded above** (`BddAbove`);
- a proof that `provablyWO` is **downward closed** (an *initial segment*):
  `α ∈ provablyWO → β < α → β ∈ provablyWO`.

**Definition 3.2 (PTO).** The proof-theoretic ordinal of `T` is
`pto T := sSup (provablyWO T)`.

**Definition 3.3 (Order).** `T₁ ≤ T₂ :↔ provablyWO T₁ ⊆ provablyWO T₂` and
`T₁ < T₂ :↔ provablyWO T₁ ⊊ provablyWO T₂`.

**Definition 3.4 (Canonical theory).** For an ordinal `α`,
`ofOrdinal α` is the theory with `provablyWO = Iio α = {β : β < α}`.
It is bounded by `α` and trivially downward closed.

**Definition 3.5 (Lattice operations).**
- `empty`: `provablyWO = ∅`.
- `join T₁ T₂`: `provablyWO = provablyWO T₁ ∪ provablyWO T₂`.
- `meet T₁ T₂`: `provablyWO = provablyWO T₁ ∩ provablyWO T₂`.
Each inherits boundedness and downward closure from its components (the union by
taking the max of the two bounds; the intersection by monotonicity of `BddAbove`).

**Definition 3.6 (Depth distance).**
`depthDist T₁ T₂ := (pto T₁ − pto T₂) + (pto T₂ − pto T₁)`, using ordinal
subtraction.

---

## 4. Half-saturation, monotonicity, and totality

### 4.1 Half-saturation

**Lemma 4.1 (No gaps below the supremum).** Let `S` be a nonempty, bounded,
downward-closed set of ordinals. If `β < sSup S` then `β ∈ S`.

*Proof sketch.* Contrapositive. If `β ∉ S`, then for every `α ∈ S` we cannot have
`β < α` (else downward closure puts `β ∈ S`); hence `α ≤ β` for all `α ∈ S`, so
`β` is an upper bound and `sSup S ≤ β` by `csSup_le`. ∎

**Corollary 4.2.** For nonempty `T`, `Iio (pto T) ⊆ provablyWO T`. The PTO is the
exact threshold: everything strictly below it is certified.

### 4.2 PTO of canonical theories

**Lemma 4.3.**
- (limit) If `Order.IsSuccLimit α` then `pto (ofOrdinal α) = α`.
- (successor) `pto (ofOrdinal (α+1)) = α`, since `Iio(α+1) = Iic α` and
  `sSup (Iic α) = α`.
- (zero) `pto (ofOrdinal 0) = 0`.
- (omega) `pto (ofOrdinal ω) = ω`.

The successor case is essential and slightly counterintuitive: `ofOrdinal (α+1)`
has PTO `α`, not `α+1`, because its certified set is `Iic α` whose supremum is
`α`. This is the source of PTO non-injectivity.

### 4.3 Monotonicity and sandwiching

**Theorem 4.4 (Monotonicity).** `T₁ ≤ T₂ ⇒ pto T₁ ≤ pto T₂`.

*Proof sketch.* If `T₁` is empty, `pto T₁ = sSup ∅ = 0 ≤ pto T₂`. Otherwise apply
`csSup_le_csSup` with the bound from `T₂.bddAbove` and the inclusion `T₁ ⊆ T₂`. ∎

**Lemma 4.5 (Non-membership bound).** For nonempty `T`, if `α ∉ provablyWO T`
then `pto T ≤ α`. (Contrapositive of Lemma 4.1.)

**Lemma 4.6 (Sandwich).** If `T₁ ⊆ T₂`, `T₁` nonempty, and `α ∈ provablyWO T₂ \
provablyWO T₁`, then `pto T₁ ≤ α ≤ pto T₂`. (Lemma 4.5 for the left bound,
`le_csSup` for the right.)

**Remark 4.7 (PTO is not strictly monotone / not injective).** Strict inclusion
need not raise the PTO. Counterexample: `T₁ = ofOrdinal ω` (certifies `{β : β <
ω}`) and `T₂` certifying `{β : β ≤ ω}` satisfy `T₁ ⊊ T₂` yet both have PTO `ω`.
Equivalently `ofOrdinal ω` and `ofOrdinal (ω+1)` have PTO `ω` and `ω`
respectively — the latter via Lemma 4.3 — and `meet` of them again has PTO `ω`.

### 4.4 Totality

**Theorem 4.8 (Totality).** For any `T₁, T₂`, either `provablyWO T₁ ⊆ provablyWO
T₂` or `provablyWO T₂ ⊆ provablyWO T₁`. Hence `≤` is total and OrdinalTheory is a
chain.

*Proof sketch.* Suppose neither inclusion holds. Choose `s ∈ provablyWO T₁ \
provablyWO T₂` and `t ∈ provablyWO T₂ \ provablyWO T₁`. By trichotomy on the
ordinals `s, t`:
- if `s < t`: downward closure of `T₂` from `t` gives `s ∈ provablyWO T₂`,
  contradiction;
- if `s = t`: then `s ∈ provablyWO T₂` directly, contradiction;
- if `t < s`: downward closure of `T₁` from `s` gives `t ∈ provablyWO T₁`,
  contradiction.
All cases contradict the choice. ∎

This is the structural heart of the development: the abstraction makes the
hierarchy of strength one-dimensional.

---

## 5. The lattice and the PTO homomorphism

**Lemma 5.1 (Join is the supremum).** `T₁ ≤ join T₁ T₂` and `T₂ ≤ join T₁ T₂`;
and `join` is the least upper bound (any common upper bound contains the union).

**Lemma 5.2 (Meet is the infimum).** `meet T₁ T₂ ≤ T₁`, `meet T₁ T₂ ≤ T₂`, and
`T ≤ T₁ ∧ T ≤ T₂ ⇒ T ≤ meet T₁ T₂`.

**Theorem 5.3 (Join PTO = max).** `pto (join T₁ T₂) = max (pto T₁) (pto T₂)`.

*Proof sketch.* On nonempty components, `provablyWO (join T₁ T₂)` is the union, and
`csSup_union` gives `sSup (A ∪ B) = max (sSup A) (sSup B)`. Empty components are
handled separately (the empty set contributes `sSup ∅ = 0`). ∎

**Theorem 5.4 (Meet PTO = min).** `pto (meet T₁ T₂) = min (pto T₁) (pto T₂)`.

*Proof sketch.* By Totality (Theorem 4.8) the two certified sets are nested. If
`provablyWO T₁ ⊆ provablyWO T₂` then their intersection *is* `provablyWO T₁`, so
`pto (meet T₁ T₂) = pto T₁ = min (pto T₁) (pto T₂)` using `pto T₁ ≤ pto T₂` from
monotonicity; symmetrically in the other case. ∎

**Corollary 5.5 (PTO is a lattice homomorphism).** `pto : OrdinalTheory →
Ordinal` preserves both lattice operations: it sends `join ↦ max` and `meet ↦
min`. It is a surjection onto an order-convex sublattice (Section 7) and is
*not* injective (Remark 4.7).

---

## 6. The directed quasi-metric `depthDist`

**Lemma 6.1 (Basic metric-like properties).**
- `depthDist T T = 0` (`Ordinal.sub_self`);
- **Symmetry:** `depthDist T₁ T₂ = depthDist T₂ T₁` (one of the two subtractions
  is always 0);
- **Faithfulness:** `depthDist T₁ T₂ = 0 ↔ pto T₁ = pto T₂` (an ordinal sum is 0
  iff both summands are 0, and `a − b = 0 ∧ b − a = 0 ↔ a = b`).
- **Ordered form:** if `pto T₁ ≤ pto T₂` then `depthDist T₁ T₂ = pto T₂ − pto T₁`.

**Theorem 6.2 (Exact additivity along chains).** If `T₁ ≤ T₂ ≤ T₃` then
`depthDist T₁ T₃ = depthDist T₁ T₂ + depthDist T₂ T₃`.

*Proof sketch.* Let `a = pto T₁ ≤ b = pto T₂ ≤ c = pto T₃` (monotonicity). By the
ordered form, the claim is `c − a = (b − a) + (c − b)`. Using
`add_sub_cancel_of_le` twice,
`a + ((b − a) + (c − b)) = (a + (b − a)) + (c − b) = b + (c − b) = c = a + (c −
a)`. Left-cancelling `a` (`add_right_inj`) yields the identity. ∎

Remarkably, despite the non-commutativity of ordinal addition, **no defect term
appears** when the three points are linearly arranged.

**Corollary 6.3 (Directed triangle inequality).** If `T₁ ≤ T₂ ≤ T₃` then
`depthDist T₁ T₃ ≤ depthDist T₁ T₂ + depthDist T₂ T₃` (with equality).

**Theorem 6.5 (Failure of the general triangle inequality).** There exist `T₁,
T₂, T₃` with `depthDist T₁ T₃ > depthDist T₁ T₂ + depthDist T₂ T₃`.

*Proof sketch.* Take `T₁ = ofOrdinal (ω+1+1)`, `T₂ = ofOrdinal ω`,
`T₃ = ofOrdinal 0`, with PTOs `ω+1, ω, 0` by Lemma 4.3. Compute via the ordered
form and `sub_eq_zero_iff_le`:
- `depthDist T₁ T₃ = (ω+1) − 0 = ω+1`;
- `depthDist T₁ T₂ = (ω+1) − ω = 1`;
- `depthDist T₂ T₃ = ω − 0 = ω`.
Then `depthDist T₁ T₂ + depthDist T₂ T₃ = 1 + ω = ω` (by `one_add_omega0`), and
`ω < ω + 1`, so the triangle inequality fails. ∎

**Interpretation.** The unit step from `ω+1` to `ω` is genuine, but placed in
front of the larger jump `ω` it is **left-absorbed**: `1 + ω = ω`. The symmetric
distance therefore underestimates the true separation. `depthDist` is a *directed
quasi-metric*: faithful and additive in the direction of the chain, but not a
pseudometric. The obstruction is precisely the negation of the *additive
principal* property of ordinals.

---

## 7. Order-convexity of PTO fibers

**Theorem 7.1 (Convex fibers / interval theorem).** If `T₁ ≤ T ≤ T₂` and
`pto T₁ = pto T₂`, then `pto T = pto T₁`.

*Proof sketch.* Monotonicity gives `pto T₁ ≤ pto T ≤ pto T₂ = pto T₁`; squeeze. ∎

Thus each fiber `{T : pto T = α}` is order-convex — an interval of the chain.
Combined with Corollary 5.5, the picture is complete: PTO is a surjective lattice
homomorphism onto the ordinals whose level sets are intervals. The non-injectivity
of Remark 4.7 is exactly the width of these intervals (e.g. `ofOrdinal ω ⊊
ofOrdinal (ω+1)` both lie in the fiber over `ω`).

---

## 8. Algorithms

The abstract framework induces concrete computations on ordinals in Cantor normal
form (CNF), which the demonstration code realizes. We summarize the two central
procedures.

**Algorithm A (Ordinal left-subtraction in CNF).** Given ordinals `a ≥ b` in CNF,
compute the unique `c` with `b + c = a`. Process terms from the leading
(largest-exponent) end: where the leading exponent of `a` exceeds that of `b`,
`b` is absorbed and `c = a`; where the leading exponents are equal, subtract
coefficients (or, if equal, recurse on the tails). This realizes
`Ordinal.sub` and is the kernel of every `depthDist` computation. Complexity is
linear in the number of CNF terms.

**Algorithm B (depthDist and the triangle test).** Given two theories presented
by PTOs `p, q`, compute `depthDist = (p − q) ⊕ (q − p)` (one summand is 0 by
comparison), where `−` is Algorithm A and `+` is CNF ordinal addition. The
triangle test on a triple `(p, q, r)` compares `depthDist(p,r)` against
`depthDist(p,q) + depthDist(q,r)`, exhibiting equality on monotone arrangements
(Theorem 6.2) and strict failure on the absorbing arrangement `(ω+1, ω, 0)`
(Theorem 6.5).

---

## 9. Applications and connections

- **Calibration of theory strength.** The lattice-homomorphism property
  (Corollary 5.5) gives a clean calculus: the strength of a union of theories is
  the max of the strengths, of an intersection the min — a structural counterpart
  to the empirical "the stronger theory wins" heuristic of ordinal analysis.
- **One-dimensionality of consistency strength.** Totality (Theorem 4.8) is the
  abstract shadow of the empirical observation that natural theories line up in a
  near-linear hierarchy of consistency strength.
- **Geometry of theory-space.** The directed quasi-metric (Section 6) formalizes
  a meaningful asymmetry: the "cost" of bridging strength gaps is path- and
  direction-dependent precisely when small gaps abut large limit jumps.
- **Boundary diagnostics.** The triangle failure provides a sharp test for when a
  *true* metric geometry of theories is available: only when the relevant ordinals
  avoid left-absorption, i.e. lie below an additive principal ordinal.

---

## 10. Discussion and limitations

The framework is deliberately syntax-free. It does not, on its own, compute the
PTO of any concrete formal system; rather, it isolates and proves the structural
laws any reasonable PTO assignment must obey. Two consequences deserve emphasis.
First, PTO non-injectivity (Remark 4.7) means the abstraction cannot distinguish
theories that share a supremum but differ at the supremum itself (open vs. closed
initial segments); the convexity theorem (Theorem 7.1) quantifies exactly this
loss. Second, the triangle failure (Theorem 6.5) shows that the most naive
distance is not a metric; any metric theory of strength must either restrict the
ordinal range or change the arithmetic.

---

## 11. Future directions

*(Reproduced from the project's research notes; see the package's
`future_directions` field for the full text.)*

1. **The additive-principal boundary of the triangle inequality.** Theorem 6.2
   gives additivity on chains and Theorem 6.5 gives one failure. The conjectured
   frontier: `depthDist` restricted to theories whose PTOs all lie strictly below
   a fixed additive principal ordinal `δ` (e.g. `δ = ω^ω`) satisfies the full
   symmetric triangle inequality, and `δ` additive principal is necessary. The
   single mechanism behind every failure is left-absorption of a small remainder
   by a larger limit — the negation of additive-principality. The missing lemma is
   an absorption fact about ordinal subtraction, nearly available via
   `Ordinal.add_sub_cancel`.

2. **A Hessenberg (natural-sum) metric repair.** Replace ordinary `+`/`−` by the
   commutative, cancellative natural operations `⊕` (`Ordinal.nadd`), defining
   `natDist T₁ T₂ := (pto T₁ ⊖ pto T₂) ⊕ (pto T₂ ⊖ pto T₁)`. Conjecture: `natDist`
   is a genuine `Ordinal`-valued metric with `depthDist ≤ natDist` pointwise; the
   metric axioms become algebraic identities because `nadd` has a full
   commutative-monoid API, with Theorem 6.2 supplying the monotone-case
   calibration.

---

## 12. Conclusion

From the single assumption that a theory is a bounded initial segment of the
ordinals, we derived a complete structural geometry: theory-space is a chain
(Theorem 4.8); the proof-theoretic ordinal is a lattice homomorphism onto the
ordinals (Corollary 5.5) with order-convex fibers (Theorem 7.1); and the natural
ordinal-valued separation is a directed quasi-metric — exactly additive along
chains (Theorem 6.2) yet provably non-metric in general (Theorem 6.5), with the
obstruction pinned to the elementary non-commutativity `1 + ω = ω`. The results
are elementary in their tools and structural in their reach, and they chart a
precise path toward a genuine metric geometry of logical strength.
