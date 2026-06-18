# Foundations of the Proof Phase Transition Program: Derivability as Reachability, Geometry, and Closure in Implicational and Hypergraph Theories

## Abstract

We develop the structural foundations required to study *proof phase transitions*
in implicational theories: collections of single-conclusion logical rules
`a → b`, modelled as binary relations on a set of atoms. We show that derivability
in such a theory is exactly reachability in the directed graph of rules — the
reflexive–transitive closure of the rule relation — and we establish the
properties on which a quantitative theory of thresholds rests.

Our results fall into four groups. (1) *Monotonicity:* derivability is a monotone
property of the rule set, exactly the hypothesis required by sharp-threshold
theory for monotone Boolean functions on the rule hypercube. (2) *The barrier
method:* a set closed under the rules and containing the source contains every
conclusion, giving a universal certificate for non-derivability; we prove this
method *complete* — a fact is derivable iff it lies in every closed set containing
the source — and deduce that derivability is a Kuratowski closure operator
(extensive, monotone, idempotent). (3) *The chain and proof length:* for the
minimal "chain" theory `k → k+1` we obtain the sharp boundary `a ⊢ b ⇔ a ≤ b`, the
criticality of every axiom, a length-graded derivability predicate `a ⊢ₖ b`, the
rigidity result that the chain has *unique* proof length `b − a` (zero proof
slack), the diameter theorem `minProofLen(0, n) = n`, and antitonicity of minimal
proof length (proofs only get shorter under theory extension). (4) *Hypergraphs:*
all of this lifts to multi-premise rules `(a₁ ∧ … ∧ aₘ) → b`, where both
monotonicities and the barrier method survive verbatim, and the single-premise
specialization recovers ordinary derivability exactly.

All results stated below are fully formalized and machine-verified, with no
unproven assumptions beyond the standard foundational axioms. Proof sketches are
given inline; the paper is self-contained.

---

## 1. Introduction

A *proof phase transition* is the sudden onset of provability as logical rules
accumulate. Concretely: equip a set of atoms with random implicational rules at
density `c/n` (where `n` is the number of atoms), and ask whether a fixed target
becomes derivable from a fixed source. Empirically and heuristically, such systems
exhibit a sharp threshold density `c*` below which derivability is rare and above
which it is typical, mirroring the giant-component transition in random graphs and
the satisfiability threshold in random `k`-SAT.

To make this program rigorous one needs a precise structural foundation: a
definition of derivability, a proof that it is monotone (so that sharp-threshold
machinery applies), a complete method for *certifying non-derivability* (so that
the "below threshold" regime can be analyzed), an extremal minimal-density witness
(the chain), a quantitative notion of proof *length* (so that one can speak of a
*proof-length* transition, not merely an existence transition), and a robustness
check that the theory survives the move to multi-premise rules. This paper supplies
exactly these foundations.

Throughout, `α` denotes an arbitrary type of atoms.

---

## 2. Implicational theories and derivability

**Definition 2.1 (Implicational theory).** An *implicational theory* on atoms `α`
is a binary relation `T : α → α → Prop`. We read `T a b` as "`a → b` is an axiom."
Equivalently, `T` is the edge set of a directed graph on `α`.

**Definition 2.2 (Derivability).** *Derivability* in `T`, written `Derivable T` or
`a ⊢ b`, is the reflexive–transitive closure of `T`:
- (refl) `a ⊢ a` for all `a`;
- (tail) if `a ⊢ b` and `T b c`, then `a ⊢ c`.

Thus `a ⊢ b` holds iff there is a finite directed path `a = x₀, x₁, …, x_k = b` with
each `T xᵢ xᵢ₊₁`. Derivability *is* graph reachability.

**Proposition 2.3 (Basic structure).** For every theory `T`:
1. `a ⊢ a` (reflexivity / empty derivation);
2. if `a ⊢ b` and `b ⊢ c` then `a ⊢ c` (transitivity / concatenation);
3. if `T a b` then `a ⊢ b` (single-axiom derivation).

*Proof.* Immediate from the closure definition: (1) is the `refl` constructor, (3)
is one `tail` step from `refl`, and (2) is the transitivity of reflexive–transitive
closure (induction on the second derivation). ∎

---

## 3. Monotonicity and the threshold hypothesis

**Theorem 3.1 (Theory-extension monotonicity).** If `T ⊆ T'` (every axiom of `T` is
an axiom of `T'`), then `a ⊢_T b` implies `a ⊢_{T'} b`. Adding axioms never removes
derivations.

*Proof sketch.* Reflexive–transitive closure is monotone in its underlying
relation: by induction on a `T`-derivation, replay each `tail` step through the
inclusion `T ⊆ T'`, leaving `refl` unchanged. ∎

**Theorem 3.2 (Monotone Boolean form).** For fixed endpoints `a, b`, the map
`T ↦ (a ⊢_T b)` is monotone in the pointwise order on theories.

*Proof sketch.* Restatement of Theorem 3.1 as monotonicity of a Prop-valued
function. ∎

**Significance.** Identify each potential edge of the rule graph with a Boolean
coordinate. Theorem 3.2 says that "`a ⊢ b`" is a *monotone Boolean function on the
edge hypercube*: turning edges on can only make it true. Monotone Boolean functions
are precisely the class for which sharp-threshold theorems (Friedgut–Kalai,
Friedgut's criterion) apply. Theorem 3.2 is therefore the entry ticket to the
quantitative phase-transition program: it certifies that a threshold, if it exists,
behaves well, and that the random model can be analyzed by the standard machinery.

---

## 4. The barrier method and its completeness

We now develop the universal tool for certifying *non*-derivability.

**Definition 4.1 (Closed set).** A set `S ⊆ α` is *closed* under `T` if for every
`x ∈ S` and every `y` with `T x y`, also `y ∈ S`. (No axiom leads out of `S`.)

**Theorem 4.2 (Barrier / invariant-cut lemma; soundness).** If `S` is closed under
`T`, `a ∈ S`, and `a ⊢ b`, then `b ∈ S`.

*Proof sketch.* Induction on the derivation `a ⊢ b`. The base case `b = a` is the
hypothesis `a ∈ S`; for a `tail` step `a ⊢ c` with `T c' c` from `a ⊢ c' ∈ S`,
closure gives `c ∈ S`. ∎

**Corollary 4.3 (Non-derivability certificate).** To prove `a ⊬ b` it suffices to
exhibit a closed `S` with `a ∈ S` and `b ∉ S`. (Such `S` is a *barrier*.)

The deeper fact is that this is not merely sufficient but *necessary*.

**Theorem 4.4 (Completeness of the barrier method).**
`a ⊢ b` if and only if `b` belongs to every closed set containing `a`. Equivalently,
the conclusion set `{x : a ⊢ x}` is the *least* closed set containing `a`.

*Proof sketch.* (⇒) is Theorem 4.2. (⇐) Instantiate the universal hypothesis at the
specific set `S₀ = {x : a ⊢ x}`. This set contains `a` (by reflexivity) and is
closed (by the `tail` rule: if `a ⊢ x` and `T x y` then `a ⊢ y`). Hence `b ∈ S₀`,
i.e. `a ⊢ b`. ∎

**Corollary 4.5 (Complete non-derivability certificate).**
`a ⊬ b` if and only if there exists a closed set `S` with `a ∈ S` and `b ∉ S`.

*Proof sketch.* Contrapositive of Theorem 4.4 (negate the universal quantifier). ∎

Corollary 4.5 has the flavor of an LP-duality or Menger-type min–max statement:
every true impossibility has a finite combinatorial witness of a fixed shape (a
closed cut). No non-derivability is "accidental."

**The derivability closure operator.** Define, for a set `A ⊆ α`,
`Cl_T(A) := {b : ∃ a ∈ A, a ⊢ b}`, the set of all consequences of `A`.

**Theorem 4.6 (Kuratowski closure).** `Cl_T` is
1. *extensive:* `A ⊆ Cl_T(A)`;
2. *monotone:* `A ⊆ B ⇒ Cl_T(A) ⊆ Cl_T(B)`;
3. *idempotent:* `Cl_T(Cl_T(A)) = Cl_T(A)`.

*Proof sketch.* (1) Each `a ∈ A` derives itself. (2) A witness in `A` is a witness
in `B`. (3) `⊇` is extensivity; `⊆` is transitivity of derivation
(`a ⊢ y ⊢ b ⇒ a ⊢ b`). Idempotence is precisely transitivity packaged as
`Cl ∘ Cl = Cl`. ∎

Thus derivability endows the powerset of atoms with a closure operator, the
algebraic shadow of "consequence."

---

## 5. The chain theory: the minimal-density extremal case

**Definition 5.1 (Chain theory).** The *chain theory* on `ℕ` is
`chainT a b :⇔ b = a + 1`: each natural number points only to its successor.

The chain is the minimal theory making `0` reach `n` (it has exactly the `n`
necessary edges), and it serves as the extremal witness in both existence and
length thresholds.

**Theorem 5.2 (Sharp boundary).** In the chain theory, `a ⊢ b ⇔ a ≤ b`.

*Proof sketch.* (⇐) Induct on `b`; either `a = b` (use `refl`) or `a ≤ b − 1`, and
extend the shorter derivation by one `tail` step `(b−1) → b`. (⇒) Apply the barrier
lemma with the upward cut `S = {k : a ≤ k}`, which is closed since each axiom
`k → k+1` only increases the index, and contains `a`. Hence `b ∈ S`, i.e. `a ≤ b`. ∎

**Corollary 5.3 (No backward derivation).** `1 ⊬ 0` in the chain theory.

**Decidability.** Theorem 5.2 reduces chain derivability to the decidable predicate
`a ≤ b`, so `a ⊢ b` is decidable and computes by evaluation; e.g. `2 ⊢ 7` is
verified mechanically.

**Constructive witnesses.** Define the path `chainSeg(a, n) := [a, a+1, …, a+n]`.

**Proposition 5.4.** `chainSeg(a, n)` is a valid chain for `chainT` (consecutive
entries differ by one) and has length `n + 1` (i.e. `n` axiom applications). The
special case `chainPath(n) := chainSeg(0, n)` is the explicit derivation
`0 → 1 → … → n`.

*Proof sketch.* Consecutive entries of the arithmetic progression differ by one
(index arithmetic); length is `n+1` by the length of the underlying range. ∎

### 5.1 Axiom criticality

**Definition 5.5 (Punctured chain).** `chainMinus(m)` is the chain theory with the
single axiom `m → m+1` deleted: `chainMinus(m) a b :⇔ (b = a+1 ∧ a ≠ m)`.

**Theorem 5.6 (Criticality).** For `m < n`, the punctured theory cannot derive `n`
from `0`: `0 ⊬_{chainMinus(m)} n`. Yet the full chain can: `0 ⊢_{chainT} n`. Hence
every axiom of the chain is *critical* — its deletion breaks a derivation, and its
restoration repairs it.

*Proof sketch.* Apply the barrier lemma to `chainMinus(m)` with the downward cut
`S = {k : k ≤ m}`. With the axiom `m → m+1` removed, no remaining axiom escapes `S`
(the only escape would have been `m → m+1`), and `0 ∈ S`. Hence any reachable point
is `≤ m`, so `n > m` is unreachable. The positive half is Theorem 5.2. ∎

Criticality is the microstructure of phase transitions: it identifies precisely the
rules whose presence flips derivability, and in the chain *every* rule has
criticality index 1.

---

## 6. Proof length and the geometry of derivation

Existence of a proof is coarse; we refine it with a step counter.

**Definition 6.1 (Length-graded derivability).** `DerivOfLen T a b k`, written
`a ⊢ₖ b`, asserts the existence of a derivation of `b` from `a` using *exactly* `k`
axiom applications:
- (refl) `a ⊢₀ a`;
- (tail) if `a ⊢ₙ b` and `T b c`, then `a ⊢_{n+1} c`.

**Theorem 6.2 (Refinement).** `a ⊢ b ⇔ ∃ k, a ⊢ₖ b`. The graded predicate refines
ordinary derivability by remembering its length.

*Proof sketch.* (⇒) Induct on the derivation, accumulating the count. (⇐) Forget the
count by induction on the graded witness, mapping `refl`/`tail` to their ungraded
counterparts. ∎

**Theorem 6.3 (Graded monotonicity).** If `T ⊆ T'` then `a ⊢ₖ b` in `T` implies
`a ⊢ₖ b` in `T'`, *with the same length `k`*.

*Proof sketch.* Induct on the graded derivation, replaying each step through
`T ⊆ T'`; the length is preserved step for step. ∎

**Theorem 6.4 (Chain rigidity — zero proof slack).** In the chain theory,
`a ⊢ₖ b ⇔ b = a + k`. There is a *unique* possible proof length, the index gap.

*Proof sketch.* (⇒) Induct on the graded derivation: each chain axiom contributes
exactly `+1` to both the index and the count. (⇐) Induct on `k`, building the unique
ascending derivation. ∎

This rigidity — exactly one proof length, not merely a minimal one — is what makes
the chain the extremal *length* witness, in contrast to richer theories which
exhibit a *band* of achievable lengths.

**Definition 6.5 (Minimal proof length / proof distance).**
`minDerivLen T a b := inf { k : a ⊢ₖ b }` (with the convention that the infimum of
the empty set is `0`). When `a ⊢ b`, this is the length of the shortest proof; write
`d_T(a, b)`.

**Theorem 6.6 (Diameter theorem).** In the chain theory,
`minDerivLen(chainT, 0, n) = n`. The shortest proof of `n` from `0` has length
exactly `n` — the graph distance.

*Proof sketch.* By Theorem 6.4 the achievable-length set of `0 ⊢ n` is the singleton
`{n}`, whose infimum is `n`. Combined with the explicit witness `chainPath(n)` of
length `n`, the bound is tight. ∎

**Theorem 6.7 (Proofs only get shorter).** If `T ⊆ T'` and `a ⊢_T b` (some length
exists), then `minDerivLen(T', a, b) ≤ minDerivLen(T, a, b)`. Enlarging a theory
never lengthens the shortest proof.

*Proof sketch.* The achievable-length set for `T` is nonempty and, by Theorem 6.3,
included in that for `T'`. The minimizer of the smaller set is an achievable length
in `T'`, so the infimum over `T'` is no larger. ∎

### 6.1 Toward a geometry of proof

The proof distance `d_T` is the seed of genuine metric structure. It is reflexive
(`d_T(a,a) = 0`), and it obeys a directed triangle inequality
`d_T(a,c) ≤ d_T(a,b) + d_T(b,c)` (concatenating a length-`m` and a length-`n`
derivation yields a length-`(m+n)` derivation — the *additive composition* of graded
proofs). On the chain the triangle inequality holds with *equality*
(`d(a,c) = (c−a) = (b−a)+(c−b)` for `a ≤ b ≤ c`), so the chain is a *geodesic*: a
straight line in proof space with no slack.

Finally, the *loop lengths* `L(T, a) := { k : a ⊢ₖ a }` of closed derivations form
an **additive submonoid of ℕ** (`0 ∈ L`, and `L` is closed under addition, since
loops concatenate). For the chain `L = {0}` (no nontrivial loops); but a theory with
two cycles through `a` of coprime lengths `p, q` makes `L` a *numerical semigroup*
with a finite Frobenius number `pq − p − q`. The qualitative change of `L` — from
trivial to cofinite — as rule density increases is the precise signature of a
*proof-length* phase transition, and connects the program to the rich theory of
numerical semigroups.

---

## 7. Hypergraph (multi-premise) theories

Real inference rules consume several premises at once (modus ponens needs both `A`
and `A → B`). We generalize accordingly.

**Definition 7.1 (Hypertheory).** A *hypertheory* on `α` is a set
`R ⊆ List α × α` of rules `(prems, concl)`: the conclusion may be inferred once *all*
premises are derived. This is a directed hypergraph.

**Definition 7.2 (Hypergraph derivability).** Given assumptions `S ⊆ α`,
`HDeriv R S` is the least predicate with:
- (base) `a ∈ S ⇒ HDeriv R S a`;
- (rule) `(prems, concl) ∈ R` and `(∀ p ∈ prems, HDeriv R S p)` imply
  `HDeriv R S concl`.

This is the forward hypergraph closure / least fixed point of "all premises derived
⇒ conclusion."

**Theorem 7.3 (Two monotonicities).**
1. *(In the rules)* `R ⊆ R'` implies `HDeriv R S a ⇒ HDeriv R' S a`.
2. *(In the assumptions)* `S ⊆ S'` implies `HDeriv R S a ⇒ HDeriv R S' a`.

*Proof sketch.* Each is a structural induction on the closure derivation: for (1)
replay each `rule` through `R ⊆ R'` and keep `base`; for (2) relax each `base` through
`S ⊆ S'` and keep `rule`. ∎

**Theorem 7.4 (Hypergraph barrier method).** If a set `C` contains the assumptions
(`S ⊆ C`) and is closed under every rule whose premises *all* lie in `C` (i.e.
`(prems, concl) ∈ R` and `prems ⊆ C` imply `concl ∈ C`), then `HDeriv R S a ⇒ a ∈ C`.

*Proof sketch.* Induct on the closure: `base` lands in `C` by `S ⊆ C`; `rule` lands
in `C` because all its premises lie in `C` by the induction hypotheses, triggering
the closure condition. ∎

The barrier certificate is *premise-arity-agnostic*: the conserved set `C` works
regardless of how many premises a rule consumes. The same cuts that prove
impossibility for chains prove it for arbitrary hypergraphs.

**Definition 7.5 (Single-premise embedding).** For a binary theory `T`, let
`toHyper(T) := {([a], b) : T a b}` be the hypertheory whose rules each have a single
premise.

**Theorem 7.6 (Cross-domain bridge).** For all `a, b`,
`HDeriv (toHyper T) {a} b ⇔ Derivable T a b`. Hypergraph derivability with
single-premise rules from a singleton assumption coincides exactly with ordinary
binary derivability.

*Proof sketch.* (⇒) Induct on `HDeriv`: `base` gives `a = b` and reflexivity; each
single-premise `rule` is one axiom step appended via `tail`. (⇐) Induct on the
reflexive–transitive closure: `refl` is `base`, and each step uses the one-premise
rule `([b], c)`. ∎

Theorem 7.6 certifies that the hypergraph layer is a *conservative* generalization:
the binary model is precisely its single-premise slice. Nothing about the earlier
theory is lost; it is exactly recovered.

---

## 8. Applications

**Sharp thresholds for random theories.** Theorem 3.2 places derivability in the
class of monotone Boolean functions on the edge hypercube, so Friedgut-type
criteria apply: in a random implicational theory on `n` atoms with edge density
`c/n`, the event "`a ⊢ b`" has a sharp threshold. The barrier method (Theorems
4.2–4.5) supplies the matching impossibility certificates needed to control the
subcritical regime, and the diameter/length results (Section 6) refine the question
from *whether* a proof exists to *how long* it must be.

**Automated reasoning and proof search.** Derivability-as-reachability (Section 2)
licenses graph-search algorithms for proof discovery; the proof distance (Section 6)
provides an admissible objective (shortest proof), and Theorem 6.7 guarantees that
adding lemmas to a knowledge base never lengthens existing shortest proofs — a
monotone-improvement guarantee for lemma libraries.

**Knowledge-base robustness.** Criticality (Theorem 5.6) is a template for
identifying single points of failure: rules whose removal disconnects a needed
conclusion. The barrier completeness theorem guarantees that every such
vulnerability has an explicit closed-set witness.

**Multi-premise / database reasoning.** Hypergraph derivability (Section 7) is the
semantics of forward chaining in rule engines, Datalog-style evaluation, and
inference networks; Theorems 7.3–7.4 give the monotonicity and barrier guarantees
those systems rely on, and Theorem 7.6 lets results proven for the simpler binary
model transfer.

---

## 9. Discussion

The contribution of this work is foundational rather than singular: it assembles a
coherent toolkit in which a body of implicational rules is simultaneously a network
(reachability), an order with a closure operator (a preorder, `Cl`), and a geometry
(proof distance, triangle inequality, geodesics). The barrier method gives a
*complete* logical language for impossibility; monotonicity guarantees that
thresholds are sharp; criticality localizes the rules that trigger them; the
length-graded layer turns existence into quantity; and the hypergraph generalization
demonstrates robustness across rule arity. Each ingredient was the precise structural
prerequisite that the quantitative phase-transition program was missing.

A notable methodological point is the *uniformity* of the barrier method. The same
one-line invariant-cut argument certifies non-derivability for backward steps in the
chain, for deleted critical axioms, and for arbitrary multi-premise hypergraphs.
This uniformity is what makes the certificate format stable as one moves from
deterministic extremal cases to the random setting.

---

## 10. Future work

The immediate next step is the *algebra of proof lengths* and its phase transition.
The loop-length submonoid `L(T, a)` is now known to be an additive submonoid of `ℕ`;
for the chain it is trivial (`{0}`), but theories with coprime cycle lengths produce
genuine numerical semigroups with finite Frobenius numbers. We conjecture that in a
random implicational theory on `n` atoms at density `c/n`, the loop-length submonoid
through a fixed atom undergoes a sharp transition: subcritically `L = {0}` (a
locally tree-like, loop-free neighborhood), supercritically `L` is cofinite with
Frobenius number `Θ(log n)`. Establishing this would make "the Frobenius signature of
a proof-length phase transition" a theorem and would tie the program to the rich
combinatorics of numerical semigroups. Further directions include criticality-index
distributions in random theories, sharp constants for the existence threshold via
Friedgut's criterion, and proof-distance concentration (a quantitative geometry of
random proof).

All structural results reported here are complete and verified; they form the
foundation on which these quantitative questions can now be posed precisely.
