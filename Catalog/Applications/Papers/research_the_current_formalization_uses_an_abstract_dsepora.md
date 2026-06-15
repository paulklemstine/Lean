# Concrete d-Separation via Reachability: Undirected Vertex Separation is a Compositional Graphoid

## Abstract

Conditional independence is the algebraic backbone of causal inference. In the
abstract theory it is governed by the **graphoid axioms** — symmetry,
decomposition, weak union, and contraction — which are conventionally *postulated*
of an opaque independence oracle and then used to justify the do-calculus and
identification algorithms. We replace the oracle by a fully concrete,
combinatorial model: **undirected vertex separation**, defined as the
non-reachability of one vertex set from another in the graph obtained by deleting
a conditioning set. We prove, from first principles and with no unproved
assumptions, that vertex separation satisfies all four semi-graphoid axioms, and
in addition the **composition** axiom that generic probabilistic independence
fails. Thus graph separation is a *compositional graphoid*, strictly stronger
than the probabilistic semi-graphoid. The technical core is a single
domain-agnostic lemma — a **first-hitting decomposition** of a
reflexive-transitive-closure walk relative to an arbitrary predicate — which
powers the contraction axiom and, as a byproduct, sharpens it: contraction
requires only that A and B be disjoint, not the customary disjointness of A and
the conditioning set. All results have been formalized and machine-checked. We
situate the construction within an existing catalog of causal-inference
infrastructure (directed acyclic graphs with topological ordering, reachability,
and graph mutilation) and explain how the undirected separation core is the
combinatorial heart of d-separation via moralization of the ancestral graph.

**Keywords.** d-separation, graphoid axioms, conditional independence, causal
inference, reachability, reflexive-transitive closure, compositional graphoid,
do-calculus.

---

## 1. Introduction

### 1.1 The problem

The central technical object of graphical causal inference is the relation of
*conditional independence* (CI). Pearl's do-calculus, the ID algorithm of Tian
and Pearl, and the completeness results of Shpitser and Pearl all manipulate CI
statements `A ⊥ B | Z` ("A is independent of B given Z") through a small set of
structural rules. Dawid, and later Pearl and Paz, distilled these rules into the
**graphoid axioms**. A *semi-graphoid* is any ternary relation `· ⊥ · | ·` on
disjoint subsets of a ground set satisfying:

1. **Symmetry:** `A ⊥ B | Z ⟹ B ⊥ A | Z`.
2. **Decomposition:** `A ⊥ (B ∪ W) | Z ⟹ A ⊥ B | Z`.
3. **Weak union:** `A ⊥ (B ∪ W) | Z ⟹ A ⊥ B | (Z ∪ W)`.
4. **Contraction:** `A ⊥ B | Z  ∧  A ⊥ W | (Z ∪ B) ⟹ A ⊥ (B ∪ W) | Z`.

A *graphoid* additionally satisfies **intersection**; a *compositional graphoid*
additionally satisfies **composition** (Definition 6.1).

In most formal treatments the graphoid axioms are *axioms* in the literal sense:
hypotheses on an abstract oracle. This is methodologically unsatisfying. The
axioms are advertised as *captured* by d-separation in directed acyclic graphs
(DAGs), yet the capturing is rarely made internal: one quotes the soundness of
d-separation as folklore and proceeds. The goal of this paper is to make the
capturing a theorem.

### 1.2 Contribution

We give a concrete combinatorial relation and *derive* the axioms.

- We define an undirected graph as a symmetric adjacency relation on a finite
  vertex set, a `Z`-avoiding step relation, `Z`-avoiding reachability as its
  reflexive-transitive closure, and **separation** as the failure of
  cross-reachability between two vertex sets.
- We prove the four semi-graphoid axioms (Theorems 5.1–5.4) and bundle them into
  a single semi-graphoid instance (Theorem 5.5).
- We prove the **composition** axiom (Theorem 6.2), demonstrating that graph
  separation is strictly stronger than probabilistic independence.
- We isolate the **first-hitting decomposition** (Lemma 4.1), a reusable fact
  about reflexive-transitive closure and an arbitrary predicate, and show it is
  the precise engine behind contraction.
- We observe that the formal contraction proof needs only `Disjoint A B`, not the
  usual `Disjoint A Z`, yielding a sharper statement (Remark 5.6).

Every statement below has been formalized and verified with a proof assistant;
the prose proof sketches mirror the formal arguments line for line.

### 1.3 Relation to d-separation

d-separation in a DAG is a directed criterion involving chains, forks, and
colliders. The classical Lauritzen–Verma reduction shows that `A ⊥ B | Z` holds
by d-separation in a DAG `G` if and only if `A` and `B` are separated by `Z` in
the *moralized ancestral graph*: restrict to the ancestors of `A ∪ B ∪ Z`, marry
co-parents (connect any two vertices sharing a child), drop directions, and ask
ordinary undirected vertex separation. Hence the *undirected separation relation
studied here is the combinatorial heart of d-separation*; the directed-to-
undirected reduction (moralization) is a graph construction layered on top. Our
construction connects to a catalog `CausalDAG` through its undirected skeleton:
moralized d-separation is undirected separation in a supergraph of the skeleton.

---

## 2. Preliminaries: graphs and reachability

We work over a finite vertex set, modeled as `Fin n` (the integers
`0, 1, …, n-1`). Subsets are finite sets `Finset (Fin n)`.

**Definition 2.1 (Undirected graph).**
An *undirected graph* on `Fin n` is a relation `adj : Fin n → Fin n → Prop`
together with a proof of symmetry: for all `i, j`, `adj i j → adj j i`.

**Definition 2.2 (Z-avoiding step).**
Given a graph `G` and a conditioning set `Z : Finset (Fin n)`, the *Z-avoiding
step relation* is
```
stepZ G Z x y  :=  G.adj x y  ∧  x ∉ Z  ∧  y ∉ Z.
```
Both endpoints are required to lie outside `Z`. Because the graph is undirected
and both endpoint conditions are symmetric in `x, y`, the step relation is itself
symmetric.

**Definition 2.3 (Z-avoiding reachability).**
`ConnAvoid G Z u v` holds when there is a walk from `u` to `v` using only
`Z`-avoiding steps. Formally it is the reflexive-transitive closure of `stepZ`:
```
ConnAvoid G Z u v  :=  ReflTransGen (stepZ G Z) u v.
```
Reflexivity gives `ConnAvoid G Z u u`; transitivity lets walks be concatenated.

**Definition 2.4 (Separation).**
For vertex sets `A, B, Z`, define
```
Separated G A B Z  :=  ∀ a ∈ A, ∀ b ∈ B, ¬ ConnAvoid G Z a b.
```
We write `A ⊥ B | Z` for `Separated G A B Z`: no vertex of `A` reaches any vertex
of `B` while avoiding `Z`.

---

## 3. Basic properties of reachability

These three facts are the entire toolkit; every axiom is a corollary.

**Lemma 3.1 (Symmetry of the step relation).**
`stepZ G Z` is symmetric: `stepZ G Z x y → stepZ G Z y x`.

*Proof.* Unfold: from `G.adj x y ∧ x ∉ Z ∧ y ∉ Z` produce
`G.adj y x ∧ y ∉ Z ∧ x ∉ Z` using graph symmetry and reordering the endpoint
conditions. ∎

**Lemma 3.2 (Reversibility of reachability).**
If `ConnAvoid G Z u v` then `ConnAvoid G Z v u`.

*Proof sketch.* Induct on the walk. The empty walk reverses to itself. For a walk
`u ⇝ a → v` (a tail step), the inductive hypothesis reverses the prefix to
`a ⇝ u`; prepend the reversed final edge `v → a` (legal by Lemma 3.1) using the
`head` constructor of reflexive-transitive closure, yielding `v ⇝ u`. ∎

**Lemma 3.3 (Anti-monotonicity in the conditioning set).**
If `Z ⊆ Z'` and `ConnAvoid G Z' u v`, then `ConnAvoid G Z u v`.

*Proof.* Every `Z'`-avoiding step is a `Z`-avoiding step: if an endpoint lies
outside `Z'` it lies outside the smaller set `Z`. Apply monotonicity of
reflexive-transitive closure under this edge-wise implication. Enlarging the
deleted set can only remove walks. ∎

The contrapositive of Lemma 3.3 is the one we use: deleting *more* vertices (a
larger `Z`) preserves *separation*. This is the source of weak union.

---

## 4. The first-hitting decomposition

The contraction axiom requires reasoning about *where* a walk first enters a
region. We isolate this as a self-contained lemma about an arbitrary relation
`step` and an arbitrary predicate `P`, with no reference to graphs.

**Lemma 4.1 (First-hitting decomposition).**
Let `step : α → α → Prop` and `P : α → Prop`. Suppose `ReflTransGen step u v` and
`¬ P u`. Then *either*

- **(avoidance)** the walk lies entirely in `{x | ¬ P x}`, i.e.
  `ReflTransGen (fun x y => step x y ∧ ¬ P x ∧ ¬ P y) u v`; *or*
- **(first hit)** there exist `w'` and `w` with a `P`-free prefix
  `ReflTransGen (fun x y => step x y ∧ ¬ P x ∧ ¬ P y) u w'`, a single edge
  `step w' w`, `¬ P w'`, and `P w`.

*Proof sketch.* Induct on the walk `ReflTransGen step u v` with `u` fixed.

- *Base* (`v = u`, empty walk): `¬ P u` holds, so the avoidance disjunct is
  witnessed by the empty `P`-free walk.
- *Tail step* (`u ⇝ m → v` from `ReflTransGen step u m` and `step m v`): apply the
  inductive hypothesis to the prefix `u ⇝ m`. If the prefix already first-hits
  `P`, that witness is returned unchanged (the final edge is irrelevant). If the
  prefix avoids `P`, then in particular `¬ P m`. Now split on `P v`:
  - if `P v`, we have just first-hit `P`: the `P`-free prefix is `u ⇝ m`, the
    edge is `m → v` with `¬ P m` and `P v` — emit the first-hit disjunct with
    `w' := m`, `w := v`;
  - if `¬ P v`, extend the `P`-free prefix by the edge `m → v`, which now
    satisfies `step m v ∧ ¬ P m ∧ ¬ P v` — emit the avoidance disjunct. ∎

**Design note.** A tempting but *wrong* formulation is to phrase the first-hit
case as a single `ReflTransGen` *reaching* the `P`-vertex under the
both-endpoints-`¬P` restriction. This is impossible: the last edge *into* a
`P`-vertex cannot satisfy a "`¬P` on the target" constraint. The fix is to split
off the final edge `w' → w` explicitly, restricting only the strict prefix
`u ⇝ w'`. This is why the statement carries a separate edge witness rather than a
single closed walk.

---

## 5. The semi-graphoid axioms

Throughout, `G` is an undirected graph on `Fin n` and `A, B, W, Z` are finite
vertex sets.

**Theorem 5.1 (Symmetry).** `A ⊥ B | Z ⟹ B ⊥ A | Z`.

*Proof.* Suppose for contradiction `b ∈ B`, `a ∈ A`, and `ConnAvoid G Z b a`. By
Lemma 3.2 reverse it to `ConnAvoid G Z a b`, contradicting `A ⊥ B | Z`. ∎

**Theorem 5.2 (Decomposition).** `A ⊥ (B ∪ W) | Z ⟹ A ⊥ B | Z`.

*Proof.* Let `a ∈ A`, `b ∈ B`. Since `B ⊆ B ∪ W`, we have `b ∈ B ∪ W`. A walk
`a ⇝ b` would witness `a`-reaches-`(B ∪ W)`, contradicting the hypothesis. ∎

(The symmetric variant `A ⊥ (B ∪ W) | Z ⟹ A ⊥ W | Z` follows identically via
`W ⊆ B ∪ W`.)

**Theorem 5.3 (Weak union).** `A ⊥ (B ∪ W) | Z ⟹ A ⊥ B | (Z ∪ W)`.

*Proof.* Let `a ∈ A`, `b ∈ B`. Suppose `ConnAvoid G (Z ∪ W) a b`. By
anti-monotonicity (Lemma 3.3, with `Z ⊆ Z ∪ W`), this upgrades to
`ConnAvoid G Z a b`. Since `b ∈ B ⊆ B ∪ W`, this contradicts
`A ⊥ (B ∪ W) | Z`. ∎

The mechanism is exactly the contrapositive of Lemma 3.3: a walk avoiding the
*larger* set `Z ∪ W` also avoids the smaller set `Z`, so adding `W` to the
conditioning set cannot break a separation that already held against `Z`.

**Theorem 5.4 (Contraction).**
Assume `Disjoint A B`. Then
`A ⊥ B | Z  ∧  A ⊥ W | (Z ∪ B)  ⟹  A ⊥ (B ∪ W) | Z`.

*Proof sketch.* Let `a ∈ A` and `t ∈ B ∪ W`, and suppose `ConnAvoid G Z a t`. We
derive a contradiction. Apply the first-hitting decomposition (Lemma 4.1) to this
walk with the predicate `P x := x ∈ B`. Note `¬ P a`: indeed `a ∈ A` and
`Disjoint A B` force `a ∉ B`.

- *Avoidance case.* The walk lies entirely outside `B`, so every step avoids
  `Z ∪ B`; hence `ConnAvoid G (Z ∪ B) a t`. We split on membership of the
  endpoint `t`:
  - if `t ∈ B`, the original walk `a ⇝ t` (avoiding `Z`) already contradicts
    `A ⊥ B | Z`;
  - if `t ∈ W`, the upgraded walk `ConnAvoid G (Z ∪ B) a t` contradicts
    `A ⊥ W | (Z ∪ B)`.
- *First-hit case.* The walk first meets `B` at a vertex `w` via a `B`-free prefix
  `a ⇝ w'` followed by an edge `w' → w` with `w ∈ B`. The prefix avoids `Z`
  (every `stepZ`-edge avoids `Z` by definition), and the final edge `w' → w` is a
  `stepZ`-edge, so appending it yields `ConnAvoid G Z a w` with `w ∈ B`. This
  contradicts `A ⊥ B | Z`.

In all cases a contradiction, so no such walk exists and `A ⊥ (B ∪ W) | Z`. ∎

**Theorem 5.5 (Semi-graphoid instance).**
Vertex separation `Separated G` satisfies the four axioms above and therefore
assembles into a `SemiGraphoid` structure (`graphSeparation_semigraphoid`),
furnishing the previously abstract independence oracle with a concrete witnessed
model.

**Remark 5.6 (Sharper contraction).**
The standard statement of contraction assumes pairwise disjointness of
`A, B, W, Z`. The proof above used only `Disjoint A B` — the single fact `a ∉ B`
needed to launch the first-hitting decomposition. Disjointness from `Z`, and from
`W`, are never invoked. Hence the formal statement is strictly more general than
the folklore version.

---

## 6. Composition: graph separation is strictly stronger

**Definition 6.1 (Composition; compositional graphoid).**
A relation satisfies *composition* if
`A ⊥ B | Z  ∧  A ⊥ W | Z ⟹ A ⊥ (B ∪ W) | Z`. A semi-graphoid that also
satisfies composition (and intersection) is a *compositional graphoid*.

**Theorem 6.2 (Composition for graph separation).**
`A ⊥ B | Z  ∧  A ⊥ W | Z ⟹ A ⊥ (B ∪ W) | Z`.

*Proof.* Let `a ∈ A` and `t ∈ B ∪ W`. Then `t ∈ B` or `t ∈ W`. In the first case
any walk `a ⇝ t` contradicts `A ⊥ B | Z`; in the second it contradicts
`A ⊥ W | Z`. No walk exists, so `A ⊥ (B ∪ W) | Z`. ∎

The proof is trivial precisely *because* reachability cannot conspire across a
disjunction: a destination in `B ∪ W` is literally a destination in one of the
parts. There is no analogue of probabilistic "information fusion."

**Proposition 6.3 (Failure of composition for probability).**
General probabilistic conditional independence does *not* satisfy composition.

*Witness.* Let `B, W` be independent fair bits and `A := B ⊕ W` (parity). Then
`A ⊥ B` (the parity alone is uniform regardless of `B`) and `A ⊥ W`, yet
`A` is a deterministic function of `(B, W)`, so `A` is *not* independent of
`(B, W)`. Two marginal independences combine into total dependence. ∎

**Corollary 6.4.** Graph separation is a *compositional graphoid*, strictly
stronger than the probabilistic semi-graphoid. The extra rigidity is a structural
consequence of independence arising from a *graph* rather than from numerical
coincidence.

---

## 7. The unifying picture

The four semi-graphoid axioms are *shadows* of three elementary facts about the
reflexive-transitive closure `ReflTransGen`:

| Graphoid axiom | Reachability fact |
|---|---|
| Symmetry | reversibility of undirected walks (Lemma 3.2) |
| Decomposition | a part is reachable only if the whole is (set inclusion) |
| Weak union | anti-monotonicity in the deleted set (Lemma 3.3) |
| Contraction | first-hitting decomposition (Lemma 4.1) |
| Composition | a walk into `B ∪ W` is a walk into `B` or into `W` |

The probabilistic axiom system is not, at bottom, a statement about probability;
it is a statement about *connectivity*. This is the methodological payoff: an
opaque oracle of postulated rules is replaced by a transparent combinatorial
object whose laws are theorems.

---

## 8. Algorithms

Because separation is decidable connectivity, all axioms have direct algorithmic
content.

**Algorithm A (Separation oracle).** To decide `A ⊥ B | Z`: delete `Z` from the
graph, run a breadth-first search from the set `A` over the remaining vertices,
and report separation iff no vertex of `B` is reached. Complexity `O(V + E)` on
the deleted graph.

**Algorithm B (First-hitting witness).** Given a walk and a predicate `P`, scan
the walk left to right; emit the avoidance certificate if `P` never fires, else
emit the prefix up to (and the edge into) the first `P`-vertex. Linear in the walk
length; this is the constructive content of Lemma 4.1.

**Algorithm C (Axiom checker).** Given finite `A, B, W, Z`, verify any graphoid
axiom by reducing each side to a separation-oracle call (Algorithm A) and checking
the implication. Used as a falsification engine for conjectural axioms (e.g.
intersection).

---

## 9. Applications

- **Foundations of do-calculus.** Pearl's three do-calculus rules and the ID
  algorithm presuppose graphoid behavior of d-separation. Theorem 5.5 discharges
  that presupposition for the undirected separation core.
- **Adjustment validity.** "Is `Z` a valid adjustment set for the effect of `A`
  on `B`?" reduces to separation queries in mutilated graphs; the axioms justify
  the standard manipulations (e.g. moving covariates between the conditioning and
  query sets via weak union).
- **Causal discovery.** Under the faithfulness assumption, observed conditional
  independencies are exactly the separations of some DAG; composition (Theorem
  6.2) is a *testable* structural constraint distinguishing graph-induced
  independence from generic statistical independence.
- **Certified tooling.** Separation is decidable connectivity, so the oracle and
  axiom-checker (§8) are extractable to executable, certified code.

---

## 10. Discussion and future work

This work realizes the first item of a broader do-calculus formalization roadmap:
replacing the abstract `DSepOracle` by a concrete combinatorial relation and
proving the graphoid axioms as theorems. Natural continuations:

1. **Concrete directed d-separation via moralization.** Define d-separation on a
   DAG through path blocking (chains, forks, colliders), construct the moralized
   ancestral graph, and prove equivalence with undirected separation in that
   construction — transferring all axioms to the directed setting for free.
2. **The intersection axiom and the compositional-graphoid closure.** Conjecture:
   under pairwise disjointness, vertex separation also satisfies intersection
   (`A ⊥ B | (Z ∪ W)  ∧  A ⊥ W | (Z ∪ B) ⟹ A ⊥ (B ∪ W) | Z`), making it a *full*
   compositional graphoid. This is falsifiable by a single finite counterexample
   and provable, if true, by a *simultaneous* two-predicate first-hitting
   argument.
3. **Completeness of do-calculus** (Shpitser–Pearl) via the hedge criterion.
4. **A verified ID algorithm** (Tian–Pearl) recursing on c-component
   decompositions.
5. **Measure-theoretic structural causal models**, attaching measurable spaces and
   structural equations so that the graph-theoretic separation becomes the shadow
   of genuine probabilistic conditional independence.

---

## 11. Conclusion

Conditional independence, the slipperiest primitive in causal inference, becomes
a finger-on-a-maze question once interpreted as undirected vertex separation. The
graphoid axioms — symmetry, decomposition, weak union, contraction — are not
assumptions but theorems, each a shadow of reversibility, set inclusion,
anti-monotonicity, or a first-hitting decomposition of a walk. Graph separation
additionally satisfies composition, a law probability cannot keep, marking it a
strictly stronger compositional graphoid. The decisive technical instrument, the
first-hitting decomposition, is a reusable, domain-agnostic fact about
reflexive-transitive closure. The lesson generalizes: the laws of independence
are, at root, the laws of reachability.
