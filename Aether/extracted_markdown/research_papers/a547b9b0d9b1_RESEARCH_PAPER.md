# Proof Phase Transitions III: Monotonicity and Barriers for Multi-Premise (Hypergraph) Implicational Theories

## Abstract

We develop a uniform structural theory of *derivability* in implicational logics and use
it to lay rigorous foundations for the program of **proof phase transitions** in random
theories. An implicational theory is modeled as a binary relation on a set of atoms
(single-conclusion axioms `a → b`), and derivability as its reflexive–transitive closure
— equivalently, reachability in a directed graph. We isolate two structural pillars that
together govern the existence and non-existence of proofs: **monotonicity** (derivability
is increasing in the axiom set, the precise hypothesis of sharp-threshold theorems) and
the **barrier method** (a forward-closed set separating source from target certifies
non-derivability). On the minimal-density *chain* theory we obtain a sharp boundary
characterization (`a` derives `b` iff `a ≤ b`), a rigid proof-length law (the shortest
proof of `n` from `0` has length exactly `n`), and a criticality theorem (every axiom has
criticality index 1: deleting any single axiom breaks the proof).

The central contribution of this cycle is the generalization of the entire framework from
binary edges to **`k`-premise rules** — directed hypergraphs of the form
`(a₁ ∧ … ∧ aₘ) → b`. We define hypergraph derivability `HDeriv` as a least fixed point and
prove that both pillars survive verbatim: derivability is monotone in *both* the rule set
and the assumption set, and a premise-arity-agnostic barrier lemma furnishes the universal
non-derivability certificate. We close the loop with a conservativity result: when every
rule has a single premise, hypergraph derivability coincides *exactly* with the binary
derivability relation, exhibiting the classical model as the `m = 1` slice of the
hypergraph layer. All results have been formalized and machine-checked. We conclude with
five concrete research directions toward a probabilistic sharp-threshold theorem for
random implicational and hypergraph theories.

**Keywords:** implicational logic, derivability, reflexive–transitive closure, monotone
Boolean functions, sharp thresholds, directed hypergraphs, least fixed point, proof
complexity, random SAT, criticality.

---

## 1. Introduction

A *phase transition* is a sharp change in the macroscopic behavior of a system as a
control parameter crosses a critical value. The paradigmatic examples in discrete
mathematics are the connectivity threshold of the Erdős–Rényi random graph `G(n, p)`
(connectivity appears around `p = (log n)/n`) and the satisfiability threshold of random
`k`-SAT (satisfiability vanishes at a critical clause density). Both rest on a common
abstract engine: the property in question is *monotone* in the random ingredients, and
monotone events on the discrete hypercube obey sharp-threshold theorems
(Friedgut–Kalai, Friedgut, Bourgain).

This paper concerns a less familiar arena for the same phenomenon: **the act of proving
itself**. Consider a body of logical rules — an *implicational theory* — assembled at
random. When is a given conclusion derivable from a given premise? Intuitively there
should be a critical *density of rules* below which the theory is nearly powerless and
above which it abruptly becomes capable of deriving almost anything. The phrase "proof
phase transition" has circulated as a metaphor; our aim is to supply the structural
mathematics that can make it a theorem.

The contribution is a clean **factorization of the program through two pillars**:

1. **Monotonicity** — derivability is a monotone (increasing) function of the rule set.
   This is *exactly* the hypothesis a sharp-threshold theorem consumes, and is the reason
   a threshold can exist at all.
2. **The barrier method** — a forward-closed set separating source from target certifies
   non-derivability. This is the lower-bound tool a sharp-threshold proof requires at low
   density.

We establish both pillars in the single-premise (binary, graph) setting, develop the
extremal **chain** theory as a fully solved minimal-density witness (sharp boundary,
rigid proof length, unit criticality), and — the heart of this cycle — lift the entire
framework to **multi-premise (hypergraph) rules**, where both pillars are shown to survive
verbatim. A conservativity theorem certifies that the classical binary model is the
single-premise slice of the hypergraph model.

All statements below have been formalized and machine-verified; we present the
mathematics with proof sketches rather than formal scripts.

---

## 2. The single-premise framework

### 2.1 Theories and derivability

Fix a type `α` of **atoms**.

**Definition 2.1 (Implicational theory).** An *implicational theory* on `α` is a binary
relation `T : α → α → Prop`. We read `T a b` as "the axiom `a → b` belongs to `T`."
Equivalently, `T` is the edge set of a directed graph on the vertex set `α`.

**Definition 2.2 (Derivability).** The *derivability* relation of `T`, written
`Derivable T`, is the reflexive–transitive closure of `T`:
```
Derivable T a b  :=  ReflTransGen T a b,
```
the smallest relation that (i) contains `T`, (ii) is reflexive (`Derivable T a a`), and
(iii) is transitive. Concretely, `Derivable T a b` holds iff there is a finite directed
path `a = x₀ → x₁ → ⋯ → x_k = b` with each `T xᵢ xᵢ₊₁`.

The basic calculus is immediate: reflexivity (`derivable_refl`, the empty derivation),
transitivity (`derivable_trans`, concatenation of derivations), and the embedding of
single axioms (`derivable_of_axiom`: `T a b ⟹ Derivable T a b`).

### 2.2 Pillar I: monotonicity

**Theorem 2.3 (Theory extension monotonicity, `theory_extension_monotone`).** If
`T a b → T' a b` for all `a, b` (every axiom of `T` is an axiom of `T'`), then
`Derivable T a b → Derivable T' a b`.

*Proof sketch.* The reflexive–transitive closure is monotone in its generating relation
(`ReflTransGen.mono`): a `T`-path is, edge for edge, a `T'`-path. ∎

**Corollary 2.4 (Monotone Boolean form, `derivable_monotone`).** For fixed endpoints
`a, b`, the map `T ↦ Derivable T a b` is monotone with respect to the pointwise order on
theories.

This is the precise statement that, for fixed endpoints, derivability is a **monotone
Boolean function on the hypercube of potential edges**. It is the structural hypothesis
that Friedgut-type sharp-threshold theorems require, and the reason the existence of a
threshold is even well-posed.

### 2.3 Pillar II: the barrier method

**Theorem 2.5 (Barrier / invariant-cut lemma, `refl_trans_gen_closed`).** Let `S ⊆ α`
satisfy:
- (containment) `a ∈ S`, and
- (forward closure) for every `x ∈ S` and every `y` with `T x y`, also `y ∈ S`.

Then `Derivable T a b → b ∈ S`.

*Proof sketch.* Induction on the derivation `Derivable T a b`. The base (reflexive) case
gives `b = a ∈ S`. The inductive (tail) step extends a derivation `Derivable T a x` with
`x ∈ S` by an axiom `T x y`; forward closure places `y ∈ S`. ∎

The contrapositive is the universal **non-derivability certificate**: if `b ∉ S` for some
forward-closed `S ∋ a`, then `b` is not derivable from `a`. Choosing the right `S` is the
standard potential-function / conserved-quantity argument.

### 2.4 The chain theory: the minimal-density extremal case

**Definition 2.6 (Chain theory).** On `α = ℕ`, the *chain theory* is
`chainT a b := (b = a + 1)`: the axioms are exactly `k → k+1`. It is the minimal theory
making `0` derive `n`.

**Theorem 2.7 (Sharp boundary, `chain_derivable_iff`).** For all `a, b ∈ ℕ`,
```
Derivable chainT a b  ↔  a ≤ b.
```
*Proof sketch.* (⟸) Induct on `b`; the path `a → a+1 → ⋯ → b` realizes derivability
(`chain_derivable_le`). (⟹) Apply the barrier lemma with the upward-closed cut
`S = { k | a ≤ k }`. Every chain axiom strictly increases the index, so `S` is forward
closed; hence every derivable target satisfies `a ≤ b` (`chain_barrier_closed`). ∎

In particular `0` derives every `n` (`chain_derivable`) while no backward derivation
exists (e.g. `1` does not derive `0`, `chain_no_backward`).

**Definition 2.8 (Punctured chain).** `chainMinus m a b := (b = a + 1 ∧ a ≠ m)` deletes
the single axiom `m → m+1`. It is a sub-theory of the full chain
(`chainMinus_le_chain`).

**Theorem 2.9 (Axiom criticality, `chain_axiom_critical`).** For `m < n`,
```
¬ Derivable (chainMinus m) 0 n.
```
*Proof sketch.* Apply the barrier lemma to the downward-closed prefix `S = { k | k ≤ m }`.
With `m → m+1` deleted, no remaining axiom escapes `S`, and `0 ∈ S`; hence no `n > m` is
reachable. ∎

Combined with `chain_derivable`, this gives **criticality index 1**
(`chain_axiom_restorable`): deletion of any single axiom both *breaks* the proof
(`¬ Derivable (chainMinus m) 0 n`) and is *reversible* (the full chain still derives `n`).
Notably the proof *combines both pillars*: monotonicity identifies the punctured theory as
a sub-theory, and the barrier furnishes the cut created by the deletion.

### 2.5 Proof length: a constructive and graded layer

**Definition 2.10 (Explicit path).** `chainPath n := List.range (n+1) = [0, 1, …, n]`.

**Theorem 2.11 (Constructive derivation, `chainPath_chain`, `chainPath_length`).**
`chainPath n` is a valid chain for the successor relation, of length `n+1` (i.e. `n`
steps). This realizes the derivation of `n` from `0` as a concrete object of length equal
to the graph diameter.

A length-graded refinement (the *graded layer*) makes proof length first-class. One
introduces `DerivOfLen T a b k` ("a derivation of `b` from `a` using exactly `k` axiom
steps") and the minimal-length function `minDerivLen`. The key structural facts are:

- **Refinement (`derivable_iff_exists_len`).** `Derivable T a b` iff `DerivOfLen T a b k`
  for some `k`: derivability is existence of *some* finite-length derivation.
- **Length-preserving monotonicity (`derivOfLen_theory_monotone`).** Theory extension
  preserves a derivation *together with its length*; consequently adding axioms can only
  shorten the minimal proof (`minDerivLen_theory_anti`).
- **Rigidity on the chain (`chain_derivOfLen_iff`).** In the chain, the *unique* proof
  length of `a ⊢ b` is the index gap `b − a`; hence the **diameter theorem**
  `minDerivLen chainT 0 n = n` (`minDerivLen_chain`) is not a minimum over many lengths
  but the only length.

This rigidity is the deterministic anchor for the (probabilistic) proof-length threshold
program of §6.

---

## 3. The multi-premise (hypergraph) framework

The single-premise framework treats rules with exactly one hypothesis. Real logical
systems and constraint-satisfaction problems use rules with several premises at once. We
now lift the entire framework to such rules, the central new content of this cycle.

### 3.1 Hypertheories and hypergraph derivability

**Definition 3.1 (Hypertheory).** A *hypertheory* on `α` is a set of rules
```
R : Set (List α × α),
```
each rule a pair `(prems, concl)` of a list of premise atoms and a single conclusion
atom. This is a directed hypergraph: a hyperedge gathers several sources before firing a
single target.

**Definition 3.2 (Hypergraph derivability).** Given a set `S ⊆ α` of *assumptions*,
`HDeriv R S : α → Prop` is the least predicate closed under the two constructors
```
(base)  a ∈ S                                   ⟹  HDeriv R S a,
(rule)  (prems, concl) ∈ R  and
        (∀ p ∈ prems, HDeriv R S p)             ⟹  HDeriv R S concl.
```
That is, `HDeriv R S` is the forward closure of `S` under firing any rule *all* of whose
premises are already derived — the standard least fixed point of the immediate-consequence
operator.

### 3.2 Pillar I lifted: two monotonicities

Because a hypertheory has two arguments that can grow — the rules and the assumptions —
monotonicity now appears in two independent forms.

**Theorem 3.3 (Rule monotonicity, `hderiv_axioms_monotone`).** If `R ⊆ R'` then
`HDeriv R S a → HDeriv R' S a`.

*Proof sketch.* Induction on the derivation `HDeriv R S a`. A `base` step is unchanged. A
`rule` step uses a rule `(prems, concl) ∈ R ⊆ R'`, replayed under `R'`, with the inductive
hypotheses supplying `HDeriv R' S p` for each premise `p`. ∎

**Theorem 3.4 (Assumption monotonicity, `hderiv_hyps_monotone`).** If `S ⊆ S'` then
`HDeriv R S a → HDeriv R S' a`.

*Proof sketch.* Induction on the derivation. A `base` step `a ∈ S` is relayed via
`S ⊆ S'` to `a ∈ S'`. A `rule` step is unchanged, using the inductive hypotheses on the
premises. ∎

Theorem 3.3 is the hypergraph analogue and *generalization* of Theorem 2.3 (the
threshold hypothesis): enlarging the hypertheory enlarges the closure.

### 3.3 Pillar II lifted: the premise-arity-agnostic barrier

**Theorem 3.5 (Hypergraph barrier, `hderiv_barrier`).** Let `C ⊆ α` satisfy:
- (containment) `S ⊆ C`, and
- (closure) for every rule `(prems, concl) ∈ R`, if every premise `p ∈ prems` lies in
  `C`, then `concl ∈ C`.

Then `HDeriv R S a → a ∈ C`.

*Proof sketch.* Induction on the derivation. A `base` element lies in `S ⊆ C`. For a
`rule` step, the inductive hypotheses place every premise inside `C`; the closure
condition then places the conclusion inside `C`. ∎

This is the verbatim generalization of Theorem 2.5. The crucial observation is that the
certificate format is **independent of premise arity**: the conserved set `C` plays the
same role whether a rule has one premise or one hundred. Indeed a multi-premise rule is
*harder* to escape from, since it fires only when *all* its premises are already inside
`C`. The same `{k ≤ m}`-style cuts that certify non-derivability for chains certify it for
arbitrary hypergraphs — the lower-bound tool needed for random SAT-like ensembles.

### 3.4 Conservativity: the bridge to the binary model

**Definition 3.6 (Single-premise embedding).** Each binary theory `T` induces the
hypertheory
```
toHyper T := { x | ∃ a, x.1 = [a] ∧ T a x.2 },
```
i.e. each axiom `a → b` becomes the one-premise rule `([a], b)`.

**Theorem 3.7 (Conservativity / cross-domain bridge,
`hderiv_singlePremise_iff_derivable`).** For all `a, b`,
```
HDeriv (toHyper T) {a} b  ↔  Derivable T a b.
```

*Proof sketch.* (⟹) Induction on `HDeriv (toHyper T) {a} b`. A `base` step gives `b = a`,
so `Derivable T a a` by reflexivity. A `rule` step uses a one-premise rule `([x], concl)`
arising from an axiom `T x concl`; the single inductive hypothesis gives
`Derivable T a x`, and `ReflTransGen.tail` appends the axiom step to reach
`Derivable T a concl`. (⟸) Induction on `Derivable T a b = ReflTransGen T a b`. The
reflexive case is `HDeriv.base` on `a ∈ {a}`. Each tail step `T x y` is realized by the
one-premise rule `([x], y) ∈ toHyper T` via `HDeriv.rule`, whose single premise `x` is
supplied by the inductive hypothesis. ∎

Theorem 3.7 certifies that the hypergraph layer is a **conservative generalization**: the
binary derivability relation `Derivable` of §2 is exactly the `m = 1` (single-premise)
slice of `HDeriv`. Everything proved for the binary model — the chain boundary, the
diameter, unit criticality — embeds untouched.

---

## 4. Algorithms

The framework is computational. We record the principal algorithms (full type-hinted
implementations accompany this paper in `demo.py`).

### 4.1 Derivability by forward reachability

To decide `Derivable T a b` on a finite atom set, perform a breadth-first search from `a`
in the directed graph of `T`; `b` is derivable iff it is reached. Complexity
`O(V + E)` in the number of atoms and axioms. The set of nodes visited is itself the
*minimal forward-closed set containing `a`* — i.e. the tightest barrier — so the same
traversal both decides derivability and exhibits the §2.3 certificate.

### 4.2 Hypergraph closure by least fixed point

To compute `HDeriv R S`, iterate the immediate-consequence operator: start with the
derived set `D := S`, and repeatedly add `concl` whenever a rule `(prems, concl) ∈ R` has
`prems ⊆ D`, until `D` stabilizes. This is the standard semi-naïve forward-chaining /
fixpoint algorithm; with appropriate premise counters it runs in time linear in the total
size of the rule set. The fixed point `D` is exactly the smallest set satisfying the
closure hypothesis of Theorem 3.5, so it is simultaneously the answer and the witnessing
barrier.

### 4.3 Criticality testing

To test whether a rule `e` is *critical* for `Derivable T a b`, recompute reachability in
`T` with `e` removed; `e` is critical iff `b` becomes unreachable. Iterating over all
rules yields the set of critical edges (the **backbone**). On the chain theory this returns
*every* axiom on the path, confirming criticality index 1 (Theorem 2.9).

### 4.4 Empirical threshold estimation

To probe the conjectured existence threshold, sample random theories on `n` atoms (each of
the `n²` directed edges present independently with probability `p`), and estimate
`Pr[Derivable T 0 (n−1)]` by Monte Carlo over many samples and a grid of `p`. Plotting the
empirical probability against `p` reveals the characteristic sharp S-curve; the inflection
locates `p*(n)`, conjecturally near `(log n)/n`.

---

## 5. Applications

- **Making the metaphor a theorem.** Corollary 2.4 supplies the monotone-event hypothesis
  required by sharp-threshold theory, so the existence of a critical axiom density for
  random implicational theories becomes a precise, attackable conjecture rather than an
  analogy.
- **Non-derivability certificates.** Theorems 2.5 and 3.5 give compact, checkable proofs
  of impossibility (a single forward-closed set), of immediate use in dependency analysis,
  access-control reachability, and deductive databases.
- **Backbone / criticality analysis.** Theorem 2.9 and the criticality algorithm identify
  the indispensable rules of a theory — the proof-theoretic analogue of SAT backbones —
  relevant to proof minimization and robustness analysis.
- **Bridge to random SAT.** The hypergraph layer (§3) connects formal derivability to
  random `k`-SAT, the most studied phase transition in theoretical computer science, with
  a shared barrier-certificate format spanning both fields.

---

## 6. Discussion and future work

The organizing insight is that the proof-phase-transition program **factors through
monotonicity ⊕ barriers**, and that neither pillar depends on premise arity. Monotonicity
licenses the question (a threshold can exist); barriers answer its hard half (certified
non-derivability); and the chain theory furnishes the fully solved extremal witness. The
hypergraph generalization shows the factorization is structural, not an artifact of the
binary case, and the conservativity bridge keeps the classical model intact inside it.

We highlight five concrete directions (the cycle's stated future program).

**Direction 1 — Probabilistic sharp threshold.** For the random theory on `n` atoms with
each directed edge present independently with probability `p`, conjecture a critical
`p*(n)` across which `Pr[Derivable T 0 (n−1)]` jumps from `≤ ε` to `≥ 1−ε` over a window of
width `o(1)`. *Plan:* express the event as a monotone Boolean function on `{0,1}^{n²}`
(discharging monotonicity by Corollary 2.4) and feed it to a Friedgut/Bourgain
coarse-threshold theorem; numerically `p*(n) ≈ (log n)/n` (the connectivity threshold).
*If true:* "proof phase transition" becomes a theorem. *If false:* a *coarse* threshold
would reveal a proof-theoretic obstruction (a pivotal-axiom cluster) absent in ordinary
connectivity.

**Direction 2 — Proof-length thresholds and the diameter bound.** Define `minDerivLen T a b`
as the least `k` admitting a `k`-step derivation. The chain rigidity
`minDerivLen chainT 0 n = n` and the general lower bound `minDerivLen T a b ≥ graph
distance` form the deterministic core; above `p*` one expects
`minDerivLen 0 (n−1) = O(log n / log(np))` with high probability, versus `∞` below.
*Bridge:* implicational derivation as monotone resolution, importing random-`k`-CNF lower
bounds. *If false:* short proofs below the existence threshold would decouple proof-length
and existence thresholds.

**Direction 3 — Hypergraph theories and threshold sharpening.** For `k`-premise rules
(this paper's `HDeriv`), derivability is still monotone (Theorems 3.3–3.4) and barriers
still certify non-derivability (Theorem 3.5); conjecture that the critical window *narrows*
as `k` grows, mirroring random `k`-SAT. The barrier lemma already generalizes verbatim, so
the template is in place. *If true:* a direct link to random SAT thresholds. *If false:* a
`k`-independent window would expose a structural failure of single-conclusion intuition for
hypergraph reachability.

**Direction 4 — Giant derivability component and order-entropy non-analyticity.** The
derivability preorder is conjectured to collapse, near `p = 1/n`, from many small
antichains to a single giant strongly-connected derivability class, with the
log-number of linear extensions non-analytic at `p*`. *Plan:* form the SCC quotient of
`Derivable`, prove the chain anchors (a total order of `n+1` classes), and transport the
random-digraph giant-SCC theorem through the `Derivable`/SCC correspondence. *If true:* a
thermodynamic ("giant component") reading of proof-theoretic phase transitions with a
measurable order parameter.

**Direction 5 — Criticality-index distribution and backbone universality.** Generalize
Theorem 2.9 to `critIndex T a b e` = the least number of axioms (including `e`) whose
removal kills `Derivable T a b`. Conjecture (i) monotonicity — adding axioms can only lower
existing indices (a corollary of Theorems 2.3 and 2.5) — and (ii) a power-law index
distribution at criticality, the proof-theoretic analogue of SAT backbones, with chain
edges as the `critIndex = 1` base case. *If false:* a non-power-law (e.g. bimodal)
distribution would expose theory-specific structure violating constraint-satisfaction
universality.

---

## 7. Conclusion

We have given a uniform, machine-checked structural account of derivability in
implicational and hypergraph theories, organized around two pillars — monotonicity and the
barrier method — that together delineate the existence and non-existence of proofs. On the
chain theory we obtained a sharp boundary, a rigid proof-length law, and unit criticality;
in the multi-premise setting we showed both pillars survive verbatim and that the
classical binary model embeds conservatively as the single-premise slice. These results
convert the heuristic notion of a "proof phase transition" into a precise program with a
clear path — via the monotone-event hypothesis now in hand — toward a probabilistic
sharp-threshold theorem for random theories, and a structural bridge to the random-SAT
thresholds at the heart of theoretical computer science.
