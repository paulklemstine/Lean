# Viral Information Topology: A Closure-Theoretic Foundation for Contagion with Synergy

## Abstract

We develop a self-contained, order-theoretic and logical theory of information
contagion on networks, in which the propagation of a "meme" — a unit of
cultural or informational content — is modeled by a collection of
finite-premise **Horn-style rules**. Each rule pairs a finite set of premises
(the people who must already hold the idea) with a conclusion (a person who then
acquires it). Given a set of *seed* holders, we define the **semantic closure**
as the intersection of all closed supersets of the seeds, where a set is closed
if it contains the seeds and is stable under the one-step contagion operator. We
define, independently, an inductive notion of **derivability**, capturing the
existence of a finite transmission history reaching a given agent. Our central
theorem is that the two notions coincide exactly: the semantic closure equals
the set of derivable agents. This is a soundness-and-completeness correspondence
identifying a non-constructive, lattice-theoretic least fixed point with a
constructive, inductively generated set. We give complete proof sketches of the
correspondence and of all supporting lemmas (monotonicity of the one-step
operator; extensivity of the closure; the post-fixed-point property; soundness
of derivability against arbitrary closed sets; and closedness of the derivable
set). We then situate the result within a broader program — Viral Information
Topology — and discuss three structural phenomena it organizes: total cascades,
a compactness principle reducing infinite spread to finite causes, and a
topological dichotomy in which single-premise (pairwise) contagion satisfies the
Kuratowski closure axioms while synergistic (multi-premise) contagion provably
does not. We close with algorithms, numerical experiments, and conjectures.

**Keywords:** contagion, closure operator, Horn clause, least fixed point,
soundness and completeness, monotone operator, compactness, Kuratowski axioms,
social networks, consequence operator.

---

## 1. Introduction

The diffusion of information through a population is usually studied either
probabilistically (independent-cascade and linear-threshold models, SIR/SIS
epidemic dynamics) or empirically (measuring observed virality). Both
approaches tend to treat "who eventually gets the idea" as the output of a
dynamical simulation. In this paper we take a different stance, drawn from
logic and order theory: we treat the final reach of a contagion as a
**closure** — a least fixed point of a monotone operator — and we ask what
*structural* laws govern it independently of any particular dynamics.

The modeling primitive is a **rule** `(P, v)`, read "if every member of the
finite set `P` holds the idea, then `v` acquires it." A single rule with a
one-element premise is ordinary pairwise transmission. A rule with two or more
premises encodes **synergy**: an agent adopts only after a *combination* of
prior adopters is in place. Synergy is the formal signature of social
reinforcement, complex contagion, and threshold adoption.

Two definitions of "final reach" present themselves. The **semantic** one is
global and declarative: intersect all self-consistent end-states. The
**syntactic** one is local and operational: collect all agents with a finite
transmission history. Our main result, the **Closure–Derivability Theorem**,
states that these coincide for every contagion and every seed set. This is, in
the precise sense made explicit in Section 6, a soundness-and-completeness
theorem for a propositional Horn logic whose atoms are agents.

All definitions and theorems are stated inline and are self-contained; no
external reference is required to follow the development.

---

## 2. Setup and Definitions

Throughout, fix a (possibly infinite) carrier type `V` of **agents**
(equivalently, vertices of a social network, or propositional atoms). We write
`Set V` for subsets of `V` and `Finset V` for finite subsets.

**Definition 2.1 (Contagion).** A **contagion** on `V` is a set of rules
```
C ⊆ Finset V × V,
```
i.e. `C : Set (Finset V × V)`. A rule `(P, v) ∈ C` has **premise** `P` (a finite
set of agents) and **conclusion** `v`. The **arity** of a rule is `|P|`; the
arity of `C` is the supremum of its rule arities. A contagion is **simple** if
every rule has arity `≤ 1`.

**Definition 2.2 (One-step operator).** The **one-step contagion operator**
`stepOp C : Set V → Set V` sends a set `T` to the set of agents that some rule
fires into from `T`:
```
stepOp C T = { v | ∃ P : Finset V, (P, v) ∈ C ∧ ∀ x ∈ P, x ∈ T }.
```
Intuitively, `stepOp C T` is the set of agents who can be infected in one
synchronous round, given that exactly the agents in `T` are currently infected.
Note `stepOp` does **not** include `T` itself; it is the "new arrivals"
operator.

**Definition 2.3 (Closed set).** Given seeds `S : Set V`, a set `T : Set V` is
**closed for `C` over `S`**, written `IsClosed C S T`, if it contains the seeds
and is stable under one step:
```
IsClosed C S T  ⇔  (S ⊆ T) ∧ (stepOp C T ⊆ T).
```
A closed set is a self-consistent end-state: it includes the originators, and
every rule whose premises lie in `T` already has its conclusion in `T`.

**Definition 2.4 (Semantic closure).** The **closure** of `S` under `C` is the
intersection of all closed supersets:
```
closure C S = ⋂ { T : Set V | IsClosed C S T }.
```
Because the full set `V` (i.e. `Set.univ`) is always closed, the intersection is
over a nonempty family and is well defined; it is the **least** closed set
(Lemma 3.4 below).

**Definition 2.5 (Derivability).** The predicate `Derivable C S : V → Prop` is
defined inductively by two constructors:
- **seed:** if `v ∈ S` then `Derivable C S v`;
- **step:** if `(P, v) ∈ C` and `Derivable C S x` for every `x ∈ P`, then
  `Derivable C S v`.

We write `derivableSet C S = { v | Derivable C S v }`. A proof that
`Derivable C S v` is precisely a finite, well-founded transmission tree whose
leaves are seeds and whose internal nodes are rule applications.

---

## 3. Order-Theoretic Core

We first establish the lattice-theoretic backbone. All proofs are elementary but
load-bearing.

**Lemma 3.1 (Monotonicity of the one-step operator).** *If `A ⊆ B` then
`stepOp C A ⊆ stepOp C B`.*

*Proof sketch.* Let `v ∈ stepOp C A`, witnessed by a rule `(P, v) ∈ C` with
`P ⊆ A`. Since `A ⊆ B`, also `P ⊆ B`, so the same rule witnesses
`v ∈ stepOp C B`. ∎

Monotonicity is the structural reason a least fixed point exists; it is invoked
in Lemma 3.3.

**Lemma 3.2 (Extensivity).** *`S ⊆ closure C S`.*

*Proof sketch.* Fix `v ∈ S`. To show `v ∈ closure C S` we must show `v ∈ T` for
every closed `T`. But any closed `T` satisfies `S ⊆ T`, hence `v ∈ T`. ∎

**Lemma 3.3 (Post-fixed point).** *`stepOp C (closure C S) ⊆ closure C S`.*

*Proof sketch.* Let `v ∈ stepOp C (closure C S)`. To show membership in the
closure, fix an arbitrary closed `T`. By Lemma 3.4, `closure C S ⊆ T`, so by
monotonicity (Lemma 3.1), `stepOp C (closure C S) ⊆ stepOp C T`, giving
`v ∈ stepOp C T`. Since `T` is closed, `stepOp C T ⊆ T`, so `v ∈ T`. As `T` was
arbitrary, `v ∈ closure C S`. ∎

**Lemma 3.4 (Greatest-lower-bound / minimality).** *If `IsClosed C S T` then
`closure C S ⊆ T`.*

*Proof sketch.* `closure C S` is an intersection of a family containing `T`;
membership in the intersection implies membership in each member, in particular
in `T`. ∎

Lemmas 3.2–3.4 together say that `closure C S` is itself closed (it contains the
seeds by 3.2 and is stable by 3.3) and is the least such set (by 3.4). Hence
`closure C S` is the **least fixed point** of `λ T. S ∪ stepOp C T`, recovering
the Knaster–Tarski characterization without invoking the general theorem.

**Corollary 3.5 (Closure operator).** The map `S ↦ closure C S` is extensive
(`S ⊆ closure C S`), monotone (`S₁ ⊆ S₂ ⇒ closure C S₁ ⊆ closure C S₂`), and
idempotent (`closure C (closure C S) = closure C S`). The fixed points — the
**virally closed sets** — form a Moore family (closed under arbitrary
intersection).

*Proof sketch.* Extensivity is Lemma 3.2. Monotonicity: any closed set over
`S₂` is closed over `S₁` once `S₁ ⊆ S₂`, so the intersection defining
`closure C S₁` is over a larger family, hence smaller. Idempotence: `closure C S`
is closed, so it is one of the sets intersected to form
`closure C (closure C S)`, giving `⊆`; the reverse is extensivity. Intersection-
closedness follows because an intersection of closed sets is closed (the seed
and stability conditions are preserved by intersection). ∎

---

## 4. The Closure–Derivability Theorem

We now prove the central correspondence. It has two halves.

### 4.1 Soundness: derivability implies semantic membership

**Lemma 4.1 (Soundness against closed sets).** *If `IsClosed C S T` and
`Derivable C S v`, then `v ∈ T`.*

*Proof sketch.* Induct on the derivation of `Derivable C S v`.
- **seed case:** `v ∈ S ⊆ T` because `T` contains the seeds.
- **step case:** there is a rule `(P, v) ∈ C` with `Derivable C S x` for all
  `x ∈ P`, and the induction hypothesis gives `x ∈ T` for all `x ∈ P`. Hence
  `v ∈ stepOp C T`, and stability `stepOp C T ⊆ T` gives `v ∈ T`. ∎

**Theorem 4.2 (Derivability ⊆ closure).** *If `Derivable C S v` then
`v ∈ closure C S`.*

*Proof sketch.* By Definition 2.4, `v ∈ closure C S` means `v ∈ T` for every
closed `T`. This is exactly Lemma 4.1. ∎

### 4.2 Completeness: semantic membership implies derivability

The crux is that the derivable set is *itself* one of the closed sets.

**Lemma 4.3 (The derivable set is closed).** *`IsClosed C S (derivableSet C S)`.*

*Proof sketch.* Two conditions.
- **Seeds:** if `v ∈ S` then `Derivable C S v` by the seed constructor, so
  `S ⊆ derivableSet C S`.
- **Stability:** suppose `v ∈ stepOp C (derivableSet C S)`, witnessed by a rule
  `(P, v) ∈ C` with every `x ∈ P` derivable. The step constructor immediately
  yields `Derivable C S v`, so `v ∈ derivableSet C S`. ∎

**Theorem 4.4 (closure ⊆ derivability).** *If `v ∈ closure C S` then
`Derivable C S v`.*

*Proof sketch.* By Lemma 4.3, `derivableSet C S` is closed. By Lemma 3.4 the
closure is contained in every closed set, in particular in `derivableSet C S`.
Hence `v ∈ closure C S` gives `v ∈ derivableSet C S`, i.e. `Derivable C S v`. ∎

### 4.3 Main result

**Theorem 4.5 (Closure–Derivability).** *For every contagion `C` and seed set
`S`,*
```
closure C S = { v | Derivable C S v }.
```

*Proof.* Set extensionality reduces the claim to the biconditional
`v ∈ closure C S ⇔ Derivable C S v`. The forward direction is Theorem 4.4; the
backward direction is Theorem 4.2. ∎

Theorem 4.5 is the formal heart of the package. It certifies that the
**declarative** specification of contagion reach (intersection of consistent
end-states) and its **operational** specification (existence of a finite
transmission history) define exactly the same set of agents, for arbitrary —
including infinite — carriers and rule families.

---

## 5. Structural Phenomena

The correspondence organizes several qualitative phenomena. We summarize three
that have been established within the broader program; each is a direct
consequence of, or close companion to, the framework above.

**5.1 Total cascades.** On the carrier `V = ℕ` consider the simple contagion
`C = { ({n}, n+1) | n ∈ ℕ }` (each agent infects its successor), seeded at
`S = {0}`. Then `closure C S = ℕ`: every natural number is derivable by a finite
chain `0 → 1 → ⋯ → n`, and by Theorem 4.5 this exhausts the closure. A finite —
indeed singleton — seed produces unbounded reach. This is the order-theoretic
skeleton of a genuine viral event.

**5.2 Compactness (finite causation).** Suppose every rule of `C` has a finite
premise (automatic here, since premises are `Finset`s). Then closure is
**finitary**: if `v ∈ closure C S`, there is a *finite* `S₀ ⊆ S` with
`v ∈ closure C S₀`. The reason is immediate from Theorem 4.5: a derivation of
`v` is a finite tree, mentioning only finitely many seeds; collect those into
`S₀`. This is the contagion analog of the compactness theorem of propositional
logic, and it licenses reasoning about infinite networks through finite
witnesses.

**5.3 Topological dichotomy: synergy breaks topology.** Recall the Kuratowski
closure axioms characterizing topological closure operators `cl`:
(K1) `cl ∅ = ∅`; (K2) `S ⊆ cl S`; (K3) `cl (cl S) = cl S`; (K4)
`cl (A ∪ B) = cl A ∪ cl B`. The contagion closure always satisfies (K2) and (K3)
(Corollary 3.5). The remaining axioms behave sharply:

- *(K1) can fail.* If `C` contains a rule with **empty** premise `(∅, v)`, then
  `v ∈ closure C ∅`, so `closure C ∅ ≠ ∅`. Empty-premise rules are
  "spontaneous adopters" — agents who hold the idea unconditionally.
- *(K4) fails exactly when synergy is present.* For a **simple** contagion
  (arity `≤ 1`), all four axioms hold and the closure is a genuine topological
  (indeed Alexandrov) closure operator. But with a rule of arity `≥ 2`, additivity
  (K4) provably fails: take a synergy rule `({a, b}, c)` and the seeds
  `A = {a}`, `B = {b}`. Then `c ∈ closure C (A ∪ B)` (both premises present), yet
  `c ∉ closure C A` and `c ∉ closure C B` (each premise alone cannot fire the
  rule), so `c ∉ closure C A ∪ closure C B`. Hence
  `closure C (A ∪ B) ≠ closure C A ∪ closure C B`.

This yields a clean slogan: **viral spread is topological if and only if it is
pairwise.** Synergy — premises of size `≥ 2` — is the exact obstruction to
topologicality. Complex (reinforcement-driven) contagion lives strictly outside
the world of topology, in the richer world of logical consequence.

---

## 6. The Logical Reading: Soundness and Completeness

Reinterpret agents as propositional atoms, the seed set `S` as a set of axioms,
and each rule `(P, v) ∈ C` as a definite Horn clause
`(⋀_{x ∈ P} x) → v`. Then:
- `Derivable C S v` is *provability* of `v` from axioms `S` using the Horn rules
  as inference steps (forward chaining);
- a closed set `T` is a *model* (a truth assignment closed under the clauses and
  satisfying the axioms);
- `closure C S` is the set of atoms *true in every model*, i.e. *semantic
  entailment*.

Under this dictionary, Theorem 4.5 reads: **`S` proves `v` if and only if `S`
entails `v`** — soundness (Theorem 4.2) and completeness (Theorem 4.4) for the
propositional Horn fragment. The compactness principle of §5.2 is then exactly
the compactness theorem for this fragment. The framework thus unifies the
contagion narrative with one of the load-bearing results of mathematical logic,
and with the semantics of Datalog/Horn knowledge bases, where `closure C S` is
the set of facts entailed by a rule base — computed by precisely the
forward-chaining of Definition 2.5.

---

## 7. Algorithms

We record two algorithms whose correctness is underwritten by the theory.

**7.1 Forward-chaining saturation.** To compute `closure C S` on a finite
carrier, iterate the inflationary operator `T ↦ T ∪ stepOp C T` from `T₀ = S`
until a fixed point. Monotonicity (Lemma 3.1) guarantees a non-decreasing chain;
finiteness guarantees termination; the limit is closed (it is a fixed point of
the inflationary operator) and is reached from `S`, hence equals `closure C S` by
minimality (Lemma 3.4) and Theorem 4.5. With `n = |V|` agents and total rule
size `m = Σ_{(P,v) ∈ C} (|P| + 1)`, a counter-based "semi-naive" implementation
achieves `O(n + m)` time by decrementing, for each rule, a count of
not-yet-satisfied premises and firing the rule when the count hits zero — the
contagion analog of unit propagation / Dowling–Gallier Horn satisfiability.

**7.2 Derivation extraction.** Because membership is equivalent to derivability
(Theorem 4.5), one can extract an explicit transmission tree for any infected
`v`: record, during saturation, the rule that first fired `v`, then recurse into
its premises. The result is a finite, well-founded witness — an auditable
genealogy of the idea reaching `v`.

---

## 8. Numerical Experiments

The accompanying `demo.py` instantiates the theory and verifies its predictions
on concrete networks:
1. **Closure = derivability**, checked by computing the closure via
   forward-chaining saturation and, independently, the derivable set via an
   inductive worklist, then asserting set equality across many random
   contagions.
2. **Total cascade** on a finite line, recovering `closure {0} = V`.
3. **Compactness**, exhibiting for a sampled infected agent a finite seed subset
   that already infects it.
4. **Synergy breaks additivity**, exhibiting `a, b, c` with
   `c ∈ closure(A ∪ B)` but `c ∉ closure A ∪ closure B`, and contrasting with a
   simple contagion where additivity holds.

These experiments are deterministic checks of the theorems, not statistical
estimates; every assertion is expected to pass exactly.

---

## 9. Applications

- **Information diffusion.** Closure gives the exact final reach of a meme under
  deterministic threshold/synergy rules — a tractable, fully analyzable
  counterpart to stochastic cascade models.
- **Knowledge bases / Datalog.** Forward-chaining closure is the standard
  bottom-up evaluation of Horn rule bases; Theorem 4.5 is the
  model-theory/proof-theory bridge underlying it.
- **Epidemiology of complex contagion.** The arity hierarchy distinguishes
  simple (pairwise) contagion from reinforcement-driven spread, with the
  topological dichotomy quantifying the difference.
- **Program analysis & reachability.** Least-fixed-point reachability under
  multi-premise rules is exactly closure under a contagion, so the API doubles
  as a reachability/derivation engine.

---

## 10. Discussion and Future Directions

The contribution is a clean, fully general identification of a non-constructive
least fixed point with a constructive inductive set, together with the structural
consequences (cascades, compactness, the synergy-topology dichotomy) it
organizes. Several directions extend it.

**C1 — Alexandrov correspondence (topology ⇄ preorder).** For a simple
contagion, conjecture that the closure coincides with the reachability closure
of the digraph whose edges are the rules, and that virally closed sets are
exactly the down-sets (or up-sets) of the reachability preorder, with a lattice
isomorphism between the two.

**C2 — Strict synergy-arity hierarchy.** Conjecture that for each `k ≥ 2` there
is a contagion of arity `k` whose lattice of closed sets is not realizable by any
contagion of arity `< k` on the same carrier. The failure of additivity (§5.3) is
the `k = 2 ≠ 1` base case; a `k`-threshold gadget on `Fin (k+1)` is the proposed
separator.

**C3 — Compactness characterizes finitary contagions.** We proved finite
premises ⇒ compactness. Conjecture sharpness: an "irredundant" infinite-premise
rule forces a seed `S` and target `v` with `v ∈ closure C S` but `v ∉ closure C S₀`
for every finite `S₀ ⊆ S`, making compactness an exact characterization of
finitary spread.

**C4 — Galois duality with firewalls.** Define a **firewall** as a set `F` whose
removal renders a target `t` unreachable from a seed `S` (i.e. `t ∉ closure_{C∖F} S`).
Conjecture a Galois connection / min-cut–max-flow duality between minimal
firewalls and maximal robust transmission flows, quantifying the cost of
stopping a contagion.

---

## 11. Conclusion

We have given a compact, self-contained theory in which the final reach of a
contagion is simultaneously a least fixed point (the intersection of all
self-consistent end-states) and an inductively defined set (the agents with a
finite transmission history), and we proved that the two always coincide. This
Closure–Derivability Theorem is a soundness-and-completeness statement that ties
viral information spread to the deepest currents of mathematical logic, while its
corollaries — total cascades, compactness, and the synergy-topology dichotomy —
turn vague intuitions about "going viral" into precise structural mathematics.
Virality, on this account, is not a property of content but of the **shape of the
rules** by which belief propagates.
