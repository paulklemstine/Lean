# Completeness of the Barrier Method and the Derivability Closure Operator

## Abstract

We study derivability in *implicational theories* — sets of single-conclusion
axioms `a → b` over a type of atoms — modelled as the reflexive–transitive closure
of the axiom relation, equivalently reachability in a directed graph. Building on a
prior development that isolated the *barrier (invariant-cut) lemma* as a sound
certificate for non-derivability, we close the loop and prove its **completeness**.
Our central duality states that `a` derives `b` if and only if `b` belongs to every
axiom-closed set containing `a`; contrapositively, every true non-derivability is
witnessed by an explicit closed barrier separating source from target. The proof
rests on a single structural observation — *the set of conclusions of a fixed
source is axiom-closed* — which simultaneously yields the **idempotence** of the
induced derivability closure operator. We show this operator is extensive,
monotone, and idempotent, hence a Kuratowski closure operator, with idempotence
being precisely the transitivity of derivation packaged as `Cl ∘ Cl = Cl`. We
complement the abstract theory with a constructive, source-general derivation
witness for the linear chain theory and establish that chain-theory derivability is
decidable. All results are formalized and machine-checked; this paper presents the
mathematics, definitions, and proof sketches in self-contained form.

**Keywords:** implicational theory, derivability, reflexive–transitive closure,
reachability, barrier method, closure operator, Kuratowski axioms, completeness,
non-derivability certificate, decidability, proof phase transitions.

---

## 1. Introduction

A recurring pattern across logic, automata, databases, and program analysis is the
following: given a set of one-step rules and two states, decide whether one state
can be transformed into the other by a finite sequence of rules. Abstractly, the
rules form a binary relation and the question is one of *reachability*. We call such
a rule set an **implicational theory** and the reachability relation
**derivability**.

Two complementary modes of certification arise. To certify *derivability*, one
exhibits a path: an explicit chain of rule applications. To certify
*non-derivability*, paths are useless, and one instead exhibits an **invariant** — a
set closed under the rules, containing the source, and excluding the target. This is
the *barrier method*, the order-theoretic analogue of a conserved quantity in
physics or a potential function in algorithm analysis.

A prior development (the catalog module `ProofPhaseTransitions`) established the
soundness of the barrier method via the lemma `refl_trans_gen_closed`, and used it
to derive sharp boundary characterizations for the linear chain theory. The natural
and pressing question left open was **completeness**: does every true
non-derivability admit a barrier certificate, or can the method fail?

This paper answers that question affirmatively and develops the surrounding
structure. Our contributions are:

1. **Completeness of the barrier method** (Theorem 4.1): `a` derives `b` iff `b`
   lies in every axiom-closed superset of `{a}`.
2. **A complete non-derivability certificate** (Theorem 4.2): a duality of
   Menger / LP-flavour stating that non-derivability is equivalent to the existence
   of an explicit closed barrier.
3. **The derivability closure operator** (Section 5): derivability induces a
   Kuratowski closure operator `Cl`, proved extensive, monotone, and idempotent,
   with idempotence identified with transitivity.
4. **Constructive and decidable chain theory** (Section 6): a source-general
   explicit derivation witness `chainSeg`, and decidability of chain derivability.

The unifying theme is that a single fact — the conclusion-set of a source is
closed — powers both the completeness theorem and the idempotence law, demonstrating
that invariant-cut (potential-function) arguments lose no information.

---

## 2. Preliminaries: implicational theories and derivability

Throughout, `α` is an arbitrary type of *atoms*.

**Definition 2.1 (Implicational theory).** An *implicational theory* on `α` is a
binary relation
```
ImplTheory α := α → α → Prop,
```
where `T a b` holds exactly when `a → b` is an axiom of `T`.

**Definition 2.2 (Derivability).** The *derivability* relation of `T` is the
reflexive–transitive closure of `T`:
```
Derivable T := ReflTransGen T.
```
Concretely, `Derivable T a b` holds iff there is a finite sequence
`a = x₀, x₁, …, xₙ = b` (with `n ≥ 0`) such that `T xᵢ xᵢ₊₁` for all `i`.

The following are immediate from the inductive structure of `ReflTransGen`.

**Proposition 2.3.** For every theory `T`:
1. (Reflexivity) `Derivable T a a`.
2. (Transitivity) `Derivable T a b` and `Derivable T b c` imply `Derivable T a c`.
3. (Axiom embedding) `T a b` implies `Derivable T a b`.

*Proof.* (1) is the `refl` constructor; (3) is the single-step constructor; (2) is
concatenation of closure chains (`ReflTransGen.trans`). ∎

**Proposition 2.4 (Monotonicity).** If `T a b → T' a b` for all `a, b`, then
`Derivable T a b → Derivable T' a b`. Equivalently, for fixed endpoints `a, b` the
map `T ↦ Derivable T a b` is monotone in the pointwise order on theories.

*Proof.* Functoriality of reflexive–transitive closure (`ReflTransGen.mono`): a
chain valid for `T` is, edge by edge, a chain valid for any larger `T'`. ∎

Monotonicity is the structural precondition required by sharp-threshold results
(e.g. Friedgut's theorem) for random theories: `T ↦ Derivable T a b` is a monotone
Boolean function on the hypercube of potential edges. It is the entry point to the
*proof phase transition* program.

---

## 3. The barrier method (soundness)

**Definition 3.1 (Closed set).** A set `S ⊆ α` is *closed* under `T` if every axiom
out of a member of `S` lands back in `S`:
```
Closed T S := ∀ x ∈ S, ∀ y, T x y → y ∈ S.
```

**Lemma 3.2 (Barrier / invariant-cut lemma).** If `S` is closed under `T` and
`a ∈ S`, then `Derivable T a b` implies `b ∈ S`.

*Proof.* Induct on the derivation `Derivable T a b`. The empty derivation gives
`b = a ∈ S`. For a derivation ending in a step `T c b` from an already-established
`Derivable T a c`, the inductive hypothesis gives `c ∈ S`, and closedness applied to
the axiom `T c b` gives `b ∈ S`. ∎

Lemma 3.2 is *sound*: a closed set `S` with `a ∈ S` and `b ∉ S` proves
`¬ Derivable T a b`. It is the canonical tool for certifying non-derivability and
is the order-theoretic form of a conserved quantity. The question of Section 4 is
whether such a certificate always exists.

---

## 4. Completeness of the barrier method

The key construction is the *conclusion-set* of a source.

**Lemma 4.1 (The conclusion-set is closed).** For any theory `T` and atom `a`, the
set
```
R(a) := { x | Derivable T a x }
```
contains `a` and is closed under `T`.

*Proof.* `a ∈ R(a)` by reflexivity (Proposition 2.3(1)). For closedness, suppose
`x ∈ R(a)`, i.e. `Derivable T a x`, and `T x y`. Appending the axiom step to the
derivation (`ReflTransGen.tail`) yields `Derivable T a y`, so `y ∈ R(a)`. ∎

`R(a)` is, by construction, the *least* closed set containing `a`: any closed `S`
with `a ∈ S` contains every conclusion of `a` by Lemma 3.2, i.e. `R(a) ⊆ S`.

**Theorem 4.2 (Completeness of the barrier method).** For any theory `T` and atoms
`a, b`,
```
Derivable T a b  ⇔  ∀ S, a ∈ S ∧ Closed T S → b ∈ S.
```

*Proof.*
(`⇒`) This is soundness, Lemma 3.2: if `a` derives `b`, then for any closed `S`
containing `a` we have `b ∈ S`.

(`⇐`) Instantiate the universally quantified hypothesis at `S := R(a)`. By
Lemma 4.1, `a ∈ R(a)` and `R(a)` is closed, so the hypothesis yields `b ∈ R(a)`,
which is exactly `Derivable T a b`. ∎

Theorem 4.2 expresses the universal property of `ReflTransGen` as a closure: `R(a)`
is the least closed superset of `{a}`, and derivability is membership in it.

Taking the contrapositive gives the complete certificate.

**Theorem 4.3 (Complete non-derivability certificate).** For any theory `T` and
atoms `a, b`,
```
¬ Derivable T a b  ⇔  ∃ S, a ∈ S ∧ Closed T S ∧ b ∉ S.
```

*Proof.* Negate both sides of Theorem 4.2 and push the negation through the
universal quantifier: `¬ ∀ S, (a ∈ S ∧ Closed T S) → b ∈ S` is logically
equivalent to `∃ S, a ∈ S ∧ Closed T S ∧ b ∉ S`. ∎

Theorem 4.3 is a Menger / LP-duality-flavoured statement: every true
non-derivability is witnessed by an explicit closed barrier. The hand-built barrier
cuts used in concrete non-derivability proofs (e.g. upward-closed cuts in the chain
theory, Section 6) are therefore not ad hoc — they are instances of a complete
method. **Consequence:** invariant-cut / potential-function arguments are complete
for non-reachability; restricting to closed-set certificates loses no information.

---

## 5. The derivability closure operator

We now exhibit derivability as a closure operator on sets of atoms.

**Definition 5.1 (Derivability closure).** For a set `A ⊆ α`,
```
Cl T A := { b | ∃ a ∈ A, Derivable T a b }
```
is the set of all atoms derivable from some member of `A`. (Note `Cl T {a} = R(a)`
of Section 4.)

**Theorem 5.2 (Kuratowski closure laws).** The operator `Cl T` is:
1. **Extensive:** `A ⊆ Cl T A`.
2. **Monotone:** `A ⊆ B` implies `Cl T A ⊆ Cl T B`.
3. **Idempotent:** `Cl T (Cl T A) = Cl T A`.

*Proof.*
(1) For `x ∈ A`, take the witness `a := x` with the empty derivation
(`Derivable T x x`); hence `x ∈ Cl T A`.

(2) If `x ∈ Cl T A` with witness `a ∈ A` and `Derivable T a x`, then `a ∈ B` (since
`A ⊆ B`) is a witness for `x ∈ Cl T B`.

(3) ⊇ is extensivity (1) applied to `Cl T A`. For ⊆, let `x ∈ Cl T (Cl T A)`: there
is `y ∈ Cl T A` with `Derivable T y x`, and in turn `z ∈ A` with `Derivable T z y`.
By transitivity (Proposition 2.3(2)), `Derivable T z x`, so `x ∈ Cl T A`. ∎

The proof of idempotence is exactly transitivity of derivation; thus the law
`Cl ∘ Cl = Cl` *is* the composability of proofs. Together with Lemma 4.1 (the
conclusion-set is closed), this is the second consequence of the single hinge
observation, mirroring the completeness theorem of Section 4.

**Remark 5.3 (Galois / fixed-point view).** The fixed points of `Cl T` are exactly
the `T`-closed sets of Definition 3.1 (when `A` is itself a union of conclusion-sets
it equals its closure). The completeness theorem then reads: `b ∈ Cl T {a}` iff `b`
lies in every fixed point of `Cl T` above `{a}` — the standard relationship between a
closure operator and the intersection of its closed sets.

---

## 6. The linear chain theory: constructivity and decidability

The extremal minimal case is the linear chain, the leanest theory making `0` reach
every `n`.

**Definition 6.1 (Chain theory).** On `α = ℕ`,
```
chainT a b := (b = a + 1).
```
The axioms are exactly the successor steps `k → k+1`.

**Theorem 6.2 (Chain boundary).** `Derivable chainT a b ⇔ a ≤ b`.

*Proof.*
(`⇐`) By induction on `b`; if `a ≤ b`, either `a = b` (empty derivation) or
`a ≤ b−1` and we extend a shorter derivation by the step `(b−1) → b`.
(`⇒`) Apply the barrier Lemma 3.2 with the upward-closed cut `S := { k | a ≤ k }`.
Every axiom `x → x+1` preserves `S` (since `a ≤ x` implies `a ≤ x+1`), and `a ∈ S`,
so any conclusion `b` satisfies `a ≤ b`. ∎

In particular `¬ Derivable chainT 1 0`: no backward derivation exists, certified by
the barrier `{ k | 1 ≤ k }`.

**Definition 6.3 (Punctured chain).** Deleting the single axiom `m → m+1`:
```
chainMinus m a b := (b = a + 1) ∧ (a ≠ m).
```

**Theorem 6.4 (Axiom criticality).** For `m < n`, `¬ Derivable (chainMinus m) 0 n`,
yet `Derivable chainT 0 n`. Every axiom of the chain is critical: its deletion
breaks every crossing derivation, and its restoration recovers them.

*Proof.* For the negative, apply Lemma 3.2 with the downward-closed prefix
`S := { k | k ≤ m }`: the only axiom that could escape `S` is `m → m+1`, which is
absent in `chainMinus m`, so `S` is closed; `0 ∈ S` and `n ∉ S` (as `n > m`). The
positive is Theorem 6.2 with `0 ≤ n`. ∎

We now give a *constructive*, source-general derivation witness, generalizing the
catalog's `chainPath n` (which is the `a = 0` case).

**Definition 6.5 (Chain segment).** For `a, n : ℕ`,
```
chainSeg a n := map (· + a) (range (n + 1)) = [a, a+1, …, a+n].
```

**Theorem 6.6 (Chain segment is a derivation).**
1. `chainSeg a n` is a valid chain for the successor relation: consecutive entries
   differ by exactly one.
2. `length (chainSeg a n) = n + 1`.

*Proof.* (1) The `i`-th entry of `chainSeg a n` is `i + a` (by `getElem_map` and
`getElem_range`); consecutive entries `i + a` and `(i+1) + a` differ by one, which is
exactly the `chainT` step. (2) `map` preserves length and `length (range (n+1)) =
n+1`. ∎

Thus `chainSeg a n` realizes the derivation `a → a+1 → ⋯ → a+n` of length `n` (that
is, `n+1` atoms) from *any* source `a`, the proof-length witness anchoring the
proof-length phase-transition program.

**Theorem 6.7 (Decidability of chain derivability).** The relation
`Derivable chainT a b` is decidable, and the decision procedure computes by
evaluating `a ≤ b`.

*Proof.* By Theorem 6.2, `Derivable chainT a b` is propositionally equivalent to the
decidable predicate `a ≤ b` on `ℕ`; transport decidability across the equivalence.
Concretely, derivability questions in the chain theory reduce to a single
comparison and are settled by direct evaluation. ∎

---

## 6b. A worked finite example

To make the abstract duality concrete, fix the finite theory on atoms
`{0, 1, 2, 3, 4, 5}` with axioms
```
0 -> 1,  0 -> 2,  1 -> 3,  2 -> 3,  3 -> 4,
```
and the isolated atom `5` (no axiom touches it). This is a *diamond* (the two
parallel routes `0 -> 1 -> 3` and `0 -> 2 -> 3`) followed by a *tail* `3 -> 4`.

**Reachable sets.** Computing conclusion-sets by the forward fixpoint of Lemma 4.1:
`R(0) = {0, 1, 2, 3, 4}`, `R(1) = {1, 3, 4}`, `R(2) = {2, 3, 4}`,
`R(3) = {3, 4}`, `R(4) = {4}`, and `R(5) = {5}`. Each is closed: no axiom escapes
it, as the reader can check edge by edge.

**Completeness in action.** The closed sets of this theory are exactly the sets `S`
with the property that whenever `x ∈ S` has an out-axiom `x → y`, then `y ∈ S`.
Enumerating them and testing Theorem 4.2 for, say, the pair `(0, 4)`: every closed
set containing `0` must, by closure along `0 → 1 → 3 → 4` (or `0 → 2 → 3 → 4`),
contain `4`; and indeed `0` derives `4`. For the pair `(0, 5)`: the set
`R(0) = {0,1,2,3,4}` is closed, contains `0`, and excludes `5`, so by Theorem 4.3
`0` does not derive `5` — the isolated atom is unreachable, certified by an explicit
barrier. Likewise `R(3) = {3,4}` certifies `¬ Derivable T 3 0` and
`¬ Derivable T 3 1`.

**Closure operator.** Take `A = {0}`. Then `Cl(A) = R(0) = {0,1,2,3,4}`;
extensivity is `A ⊆ Cl(A)`; and closing again gives `Cl(Cl(A)) = Cl(A)` since every
member of `{0,1,2,3,4}` already has all its conclusions inside. Enlarging to
`B = {0, 5}` gives `Cl(B) = {0,1,2,3,4,5} ⊇ Cl(A)`, illustrating monotonicity.

This miniature already exhibits all four phenomena — soundness, completeness,
barrier certificates, and the Kuratowski laws — and is exactly the configuration
used in the accompanying numerical demonstrations.

---

## 7. Algorithms

We summarize the effective content of the theory.

**Algorithm A (Reachable-set / closure computation).** Given a finitely-branching
theory `T` and a source `a`, compute `R(a) = Cl T {a}` by forward fixpoint: start
from `{a}` and repeatedly add all axiom-successors of current members until no
change. By Lemma 4.1 the result is the least closed set containing `a`; by
Theorem 4.2, `b` is derivable iff `b ∈ R(a)`. Termination requires finiteness of the
reachable set; complexity is `O(V + E)` in the induced reachability subgraph (a
BFS/DFS).

**Algorithm B (Barrier extraction).** If `b ∉ R(a)`, the set `R(a)` itself is a
closed barrier with `a ∈ R(a)`, `b ∉ R(a)`, certifying `¬ Derivable T a b` by
Theorem 4.3. This turns the completeness proof into a certificate generator.

**Algorithm C (Chain decision).** For `chainT`, decide `Derivable chainT a b` by
returning `a ≤ b` (Theorems 6.2, 6.7) — constant work after reading the inputs.

---

## 8. Applications

- **Verification by invariants.** Theorem 4.3 guarantees that any true safety/
  unreachability property of a transition system (states = atoms, transitions =
  axioms) admits an inductive invariant (a closed barrier). Invariant synthesis is
  therefore complete in principle, justifying the universal use of inductive
  invariants in model checking.
- **Datalog / closure under rules.** `Cl` is the least-fixpoint semantics of
  single-premise rules; idempotence is the saturation guarantee.
- **Graph reachability.** The development is reachability in directed graphs, with
  the closure operator the transitive-reflexive closure and the barrier the notion
  of a closed (forward-invariant) vertex set.
- **Proof phase transitions.** Monotonicity (Proposition 2.4) is the precondition
  for sharp thresholds in random implicational theories; the chain is the extremal
  minimal-density witness with every axiom critical (Theorem 6.4).

---

## 9. Discussion

The mathematical core is the single observation of Lemma 4.1: *the conclusion-set of
a source is closed*. This one fact is the hinge for two otherwise distinct pillars:

- it gives the `⇐` direction of completeness (Theorem 4.2), because the
  conclusion-set is the least closed witness; and
- it gives idempotence of `Cl` (Theorem 5.2(3)), because closing again adds nothing.

Both reductions are, at bottom, transitivity of derivation. The conceptual payoff is
that *invariant-cut certificates are complete*: there is never a true non-derivability
that resists the barrier method, and never a need to abandon potential-function
reasoning for an ad hoc argument.

---

## 10. Future work

**Finite barriers and a compactness theorem.** Theorem 4.3 produces *some* closed
barrier, possibly infinite (e.g. an upward cut in `ℕ`). Conjecture: for locally
finite theories (each atom has finitely many out-axioms), if `a` does not derive `b`
then there is a *finite* closed barrier, computable from the reachable set. The
reachable set from `a` is the minimal closed barrier whenever `b` is unreachable, and
local finiteness makes its frontier finite — turning the semantic certificate into a
finite, checkable witness.

**Sharp proof-length thresholds via `Cl`.** Define `derivLen T a b` as the minimal
number of axiom steps deriving `b` from `a`, a graded version of `Cl`. Study sharp
thresholds for proof length in random theories, with the chain segment `chainSeg`
(Theorem 6.6) as the extremal tight case of length exactly `n`.

**Random theories and Friedgut thresholds.** Combine monotonicity (Proposition 2.4)
with sharp-threshold machinery to locate the critical density at which a random
implicational theory begins to derive a fixed target, and characterize the width of
the transition window.

**Multi-premise generalization.** Extend from single-conclusion axioms to Horn-style
multi-premise rules; the closure operator generalizes to the least-fixpoint of a
monotone operator, and we expect the completeness duality to persist with closed
sets replaced by models.

---

## 11. Conclusion

We have proved the completeness of the barrier method for non-derivability in
implicational theories and identified derivability with a Kuratowski closure
operator, all from the single observation that the conclusion-set of a source is
axiom-closed. The chain theory provides constructive, decidable, extremal witnesses.
Together these results give a compact, complete structural account of when one atom
can reach another, and lay the groundwork for a quantitative theory of proof phase
transitions.
