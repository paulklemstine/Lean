# Proof Phase Transitions: Implicational Theories as Monotone Reachability

## Abstract

We develop the structural foundations for treating *derivability in a single-conclusion
implicational theory* as a monotone reachability property on the directed graph of axioms.
An implicational theory on a type of atoms `α` is a binary relation `T : α → α → Prop`
encoding the single-conclusion axioms `a → b`; derivability is the reflexive–transitive
closure of `T`, equivalently reachability in the directed graph whose edges are the axioms.
On this foundation we establish five structural pillars. (1) **Monotonicity**: derivability
is monotone increasing in the axiom set, so for fixed endpoints the indicator
`T ↦ Derivable T a b` is a monotone Boolean function on the hypercube of potential edges —
precisely the hypothesis required by Friedgut's sharp-threshold theorem. (2) **The barrier
method**: any axiom-closed set containing the source contains every derivable conclusion,
giving a universal certificate for non-derivability. (3) **A sharp boundary**: for the
linear chain theory, `a` derives `b` iff `a ≤ b`. (4) **Axiom criticality**: deleting any
single axiom of the chain destroys a derivation, while the full theory restores it. (5) **A
constructive witness**: the explicit derivation `0 → 1 → ⋯ → n` of length exactly `n`. We
explain how these pillars assemble into a program for proving probabilistic sharp thresholds
for random implicational theories, and we discuss the connections to proof complexity, random
k-SAT, and the thermodynamics of random partial orders. All structural results are fully
formalized and machine-checked.

**Keywords**: implicational logic, reflexive–transitive closure, graph reachability,
monotone Boolean functions, sharp thresholds, proof complexity, random structures, phase
transitions.

---

## 1. Introduction

A *phase transition* is a qualitative change in the macroscopic behavior of a system as a
control parameter crosses a critical value. The paradigm cases — freezing, percolation, the
emergence of a giant component in a random graph, the satisfiability threshold of random
k-SAT — share a common signature: a property that is monotone in the underlying randomness
switches from "almost surely false" to "almost surely true" across a window whose width
tends to zero relative to the system size.

This paper concerns a less familiar but equally natural arena for this phenomenon:
**logical deduction**. We restrict attention to the simplest non-trivial fragment of logic,
the *single-conclusion implicational* fragment, whose only sentences are implications
`a → b` with atomic premise and atomic conclusion. A theory is a set of such implications;
derivation chains implications together. The central observation, which we make fully
precise, is that derivability in such a theory is *definitionally* graph reachability, and
hence a monotone property of the edge set. This places the question "is `b` provable from
`a`?" squarely within the machinery of random-structure phase transitions.

Our contribution is the structural scaffolding required to launch this program. We isolate
the five facts that any phase-transition argument for implicational theories must rest on,
state them in maximal generality where possible, and specialize them to the linear chain —
the unique minimal-density theory deriving `n` from `0`, which serves throughout as the
extremal benchmark.

### 1.1 Notation and conventions

Throughout, `α` denotes a type of *atoms*. We write `Prop` for the type of propositions.
A relation on `α` is a function `α → α → Prop`. We use `ReflTransGen R` for the
reflexive–transitive closure of a relation `R` (the least reflexive, transitive relation
containing `R`). Natural numbers are denoted `ℕ` with `0, 1, 2, …` and the successor of `k`
written `k + 1`. We write `a ≤ b` for the usual order on `ℕ`.

---

## 2. Definitions

### 2.1 Theories and derivability

> **Definition 2.1 (Implicational theory).** An *implicational theory* on atoms `α` is a
> binary relation
> ```
> ImplTheory α := α → α → Prop.
> ```
> The intended reading of `T a b` is "the axiom `a → b` belongs to `T`."

> **Definition 2.2 (Derivability).** The *derivability* relation of a theory `T` is the
> reflexive–transitive closure of the axiom relation:
> ```
> Derivable T := ReflTransGen T.
> ```
> Equivalently, `Derivable T a b` holds iff there is a finite sequence
> `a = x₀, x₁, …, x_ℓ = b` with `T x_i x_{i+1}` for every `i` (the case `ℓ = 0` giving the
> empty derivation `a = b`). This is exactly reachability from `a` to `b` in the directed
> graph with vertex set `α` and an edge `a → b` whenever `T a b`.

The basic algebra of derivations is immediate from the closure operator:

- **Reflexivity** (`derivable_refl`): `Derivable T a a` for all `a` (the empty proof).
- **Transitivity** (`derivable_trans`): `Derivable T a b` and `Derivable T b c` imply
  `Derivable T a c` (concatenation of derivations).
- **Axiom step** (`derivable_of_axiom`): `T a b` implies `Derivable T a b` (a one-step
  derivation).

### 2.2 The chain theory

> **Definition 2.3 (Chain theory).** The *chain theory* on `ℕ` is
> ```
> chainT a b := (b = a + 1),
> ```
> i.e. the only axioms are `k → k+1`. This is the minimal theory making `0` derive `n`, and
> it serves as our extremal benchmark of minimal density.

> **Definition 2.4 (Punctured chain).** For `m : ℕ`, the *punctured chain* `chainMinus m`
> is the chain theory with the single axiom `m → m+1` deleted:
> ```
> chainMinus m a b := (b = a + 1) ∧ a ≠ m.
> ```

---

## 3. Main results

We organize the development into five structural pillars.

### 3.1 Pillar I — Monotonicity

> **Theorem 3.1 (Theory extension monotonicity, `theory_extension_monotone`).**
> Let `T, T'` be theories with `∀ a b, T a b → T' a b`. Then for all `a, b`,
> ```
> Derivable T a b  →  Derivable T' a b.
> ```

> **Theorem 3.2 (Monotone Boolean form, `derivable_monotone`).** For fixed atoms `a, b`,
> the map
> ```
> T ↦ Derivable T a b
> ```
> is monotone with respect to the pointwise order on theories (`T ≤ T'` iff every axiom of
> `T` is an axiom of `T'`).

**Proof sketch.** Both are instances of the functoriality of the closure operator: if
`R ≤ R'` pointwise, then `ReflTransGen R ≤ ReflTransGen R'`, because every `R`-step is in
particular an `R'`-step and reflexivity/transitivity are preserved. Formally one inducts on
the derivation `Derivable T a b`: the reflexive case transfers unchanged, and a tail step
`T x y` is promoted to `T' x y` by hypothesis, then re-attached. ∎

**Significance.** Identifying `α` with `Fin n` and a theory with its set of present edges
exhibits `T ↦ Derivable T a b` as a Boolean function on the hypercube `{0,1}^{n²}`.
Theorem 3.2 says this function is *monotone increasing*. This is precisely the hypothesis of
Friedgut's sharp-threshold theorem (Section 5.1), and it is the linchpin of the entire
phase-transition program: the indicator of derivability never "switches off" as edges are
added.

### 3.2 Pillar II — The barrier method

> **Theorem 3.3 (Barrier / invariant-cut lemma, `refl_trans_gen_closed`).**
> Let `T` be a theory and `S ⊆ α` a set that is *closed under the axioms of `T`*:
> ```
> ∀ a ∈ S, ∀ b, T a b → b ∈ S.
> ```
> If `a ∈ S` and `Derivable T a b`, then `b ∈ S`.

**Proof sketch.** Induct on the derivation `Derivable T a b`. The reflexive case is `a ∈ S`,
which holds by assumption. For a tail step, the inductive hypothesis places the penultimate
atom `c` in `S`, and closure applied to the final axiom `T c b` places `b` in `S`. ∎

**Significance.** This single lemma is the universal certificate for *non*-derivability: to
prove that `b` is **not** derivable from `a`, exhibit a closed set `S` with `a ∈ S` and
`b ∉ S`. It is the discrete analogue of a conservation law or potential-function argument —
one designs an invariant that the source satisfies and the target violates. Every
impossibility result below is an instance of choosing the right cut.

### 3.3 Pillar III — The sharp boundary of the chain

> **Theorem 3.4 (Forward direction, `chain_derivable_le`).** If `a ≤ b` then
> `Derivable chainT a b`. In particular `Derivable chainT 0 n` for every `n`
> (`chain_derivable`).

**Proof sketch.** Induct on `b`. If `a = b`, use reflexivity. If `a < b`, then
`a ≤ b - 1`, so by the inductive hypothesis `Derivable chainT a (b-1)`; append the axiom
`(b-1) → b` to reach `b`. ∎

> **Theorem 3.5 (Backward direction / no descent, `chain_barrier_closed`).** If
> `Derivable chainT a b` then `a ≤ b`.

**Proof sketch.** Apply the barrier lemma (Theorem 3.3) with the upward-closed cut
`S = { k | a ≤ k }`. The set contains `a` (reflexivity of `≤`), and it is closed under
`chainT`: if `a ≤ x` and `y = x + 1`, then `a ≤ x ≤ y`. Hence the conclusion `b` lies in
`S`, i.e. `a ≤ b`. ∎

> **Theorem 3.6 (Sharp boundary, `chain_derivable_iff`).** For all `a, b : ℕ`,
> ```
> Derivable chainT a b  ↔  a ≤ b.
> ```
> Consequently `¬ Derivable chainT 1 0` (`chain_no_backward`).

**Proof sketch.** Combine Theorems 3.4 and 3.5. The non-derivability `¬ Derivable chainT 1 0`
follows because `1 ≤ 0` is false. ∎

**Significance.** The chain admits a complete, decidable description of its consequence
relation. It is the perfectly understood extreme: provability coincides exactly with the
order, with no shortcuts and no obstructions beyond monotone index increase.

### 3.4 Pillar IV — Axiom criticality

> **Theorem 3.7 (Criticality, `chain_axiom_critical`).** Deleting the single axiom
> `m → m+1` destroys the derivation of `m+1` from `0`:
> ```
> ¬ Derivable (chainMinus m) 0 (m + 1).
> ```

**Proof sketch.** Use the barrier lemma with the *downward* cut `S = { k | k ≤ m }`. The
source `0 ∈ S`. The cut is closed under `chainMinus m`: the only way to leave `{k ≤ m}` by a
step `y = x + 1` would require `x = m`, but the axiom `m → m+1` has been removed, so every
remaining axiom out of `S` (those with `x < m`) lands in `S`. Hence everything derivable from
`0` stays `≤ m`, and `m + 1 ∉ S`. ∎

> **Theorem 3.8 (Restorability, `chain_axiom_restorable`).** The full chain theory restores
> the derivation:
> ```
> Derivable chainT 0 (m + 1).
> ```

**Proof sketch.** Immediate from Theorem 3.4 with `a = 0`, `b = m + 1`. ∎

**Significance.** Together, Theorems 3.7–3.8 show that every axiom of the chain has
*criticality index 1*: the removal of just that one axiom severs a proof, and reinstating it
recovers the proof. The chain has zero redundancy — it is the proof-theoretic analogue of a
structure in which every component is load-bearing, and it is the correct extremal object
against which to measure the *slack* (over-completeness) of a random, denser theory.

### 3.5 Pillar V — The constructive witness and proof length

> **Definition 3.9 (Chain path).** Let `chainPath n` denote the explicit list of atoms
> `[0, 1, 2, …, n]`, the candidate derivation of `n` from `0`.

> **Theorem 3.10 (Validity, `chainPath_chain`).** `chainPath n` is a genuine chain of axiom
> applications: consecutive entries `x_i, x_{i+1}` satisfy `chainT x_i x_{i+1}`, i.e.
> `x_{i+1} = x_i + 1`.

> **Theorem 3.11 (Length, `chainPath_length`).** The derivation `chainPath n` has length
> exactly `n` (it visits `n + 1` atoms and uses `n` axiom steps).

**Proof sketch.** `chainPath n` is the list `List.range (n+1)`. Validity is the statement
that consecutive elements of `range` differ by `1`, verified entrywise via the indexed
characterization of chains. The length count is the elementary `List.length (range (n+1)) =
n + 1`, hence `n` steps. ∎

**Significance.** Existence of a derivation (Theorem 3.4) is here upgraded to a *concrete*
witness with a *measured* length. Proof length is the currency of proof complexity, and the
chain delivers the cleanest possible identity: the minimum number of steps to derive `n` from
`0` equals the graph distance `n`. This diameter–length identity is the base case of the
proof-length program of Section 5.2.

---

## 4. Algorithms

The structural theory is constructive and translates directly into algorithms over finite
atom sets `α = {0, …, n-1}`, representing a theory as its set of directed edges.

### 4.1 Derivability by closure (reachability)

To decide `Derivable T a b`, compute the forward reachable set of `a` by repeatedly
expanding along edges until a fixed point is reached, then test membership of `b`.

```
DerivableReach(T, a, b):
  R ← {a}
  repeat
    R' ← R ∪ { y : ∃ x ∈ R, T x y }
    if R' = R then break
    R ← R'
  return (b ∈ R)
```

On `n` atoms with `E` edges this is breadth-first search: `O(n + E)` time, `O(n)` space. The
loop's invariant is exactly the barrier property of Theorem 3.3: `R` is always axiom-reachable
from `a`, and at termination `R` is closed, so `b ∉ R` *certifies* non-derivability.

### 4.2 Minimal proof length (shortest derivation)

Breadth-first search additionally returns the *length* of the shortest derivation, realizing
the diameter–length identity of Theorem 3.11 for arbitrary theories.

```
MinProofLength(T, a, b):
  dist[·] ← ∞;  dist[a] ← 0;  Q ← queue([a])
  while Q nonempty:
    x ← Q.pop()
    for y with T x y:
      if dist[y] = ∞:
        dist[y] ← dist[x] + 1;  Q.push(y)
  return dist[b]      -- ∞ means b is not derivable
```

For the chain theory this returns `b - a` when `a ≤ b` and `∞` otherwise, matching
Theorems 3.6 and 3.11.

### 4.3 Barrier certificate extraction

When `b` is unreachable, the terminal reachable set `R` of Section 4.1 *is* a barrier
certificate: it satisfies the hypotheses of Theorem 3.3 (`a ∈ R`, `R` axiom-closed) and
witnesses `b ∉ R`. This converts a failed search into a checkable proof of impossibility.

### 4.4 Monotone threshold estimation

To estimate the critical density `p*(n)` for random theories on `n` atoms, sample many random
edge sets at density `p`, test derivability of a fixed pair by Section 4.1, and bisect on `p`
to locate the crossover of the empirical probability through `1/2`. Monotonicity (Theorem 3.2)
guarantees the empirical curve is increasing in expectation, so the crossover is well defined.

---

## 5. Applications and the phase-transition program

### 5.1 Probabilistic sharp threshold

Equip the edge set on `Fin n` with the product measure in which each directed edge is present
independently with probability `p`. Fix endpoints, say `0` and `n-1`, and consider
`f(T) := Derivable T 0 (n-1)`. By Theorem 3.2, `f` is a *monotone Boolean function* on the
hypercube `{0,1}^{n²}`. Friedgut's sharp-threshold theorem states that a monotone Boolean
function with a coarse threshold (one whose total influence is small relative to the variance)
must in fact have a *sharp* threshold: there is a critical probability `p*(n)` such that
`ℙ[f] : 0 → 1` across a window of width `o(1)`. The structural input — monotonicity — is
exactly what we have formalized; the remaining target is Friedgut's theorem itself, whose
proof rests on discrete Fourier analysis on the Boolean cube.

### 5.2 Proof-length transition and resolution complexity

Single-conclusion implicational derivation is a fragment of (monotone) resolution. The
constructive witness of Theorem 3.11 establishes the diameter–length identity in the
minimal-density case. The conjecture is that for random theories there is a *second* threshold
governing the existence of *short* (polynomial-length) derivations: below a critical density,
minimal proofs are super-polynomially long or nonexistent; above it, polynomial proofs exist
with high probability. This mirrors resolution lower bounds for random k-CNF and would bridge
combinatorial proof complexity with random-graph threshold machinery.

### 5.3 Multi-premise theories and the k-SAT analogy

Replacing single-premise axioms `a → b` by multi-premise axioms
`(a₁ ∧ ⋯ ∧ a_k) → b` turns the axiom graph into a directed *hypergraph*, and derivability
into k-uniform hypergraph reachability. The barrier method (Theorem 3.3) generalizes verbatim
to hypergraph-closed sets, and the expectation — by analogy with random k-SAT — is that the
threshold *sharpens* as `k` grows. This connects the program directly to the most actively
studied thresholds in probabilistic combinatorics.

### 5.4 Thermodynamics of the derivability order

The derivability preorder, quotiented by mutual derivability, is a partial order on the
strongly connected components of the axiom graph. For random theories this order undergoes a
structural transition: below criticality it is a scattering of small antichains; above it, a
giant mutually-derivable class emerges, mirroring the giant component of a random digraph at
edge density `1/n`. One can then study the entropy of the order (the logarithm of its number
of linear extensions) and conjecture a non-analytic point at `p*`.

### 5.5 Axiom criticality index and backbones

Theorem 3.7 shows every chain axiom has criticality index `1`. For general theories, define
the criticality index of an axiom as the minimum number of axioms (including itself) whose
joint removal breaks some derivation. This is the proof-theoretic analogue of the *backbone*
in constraint satisfaction — variables fixed across all solutions. The conjecture is a
power-law distribution of criticality indices near the critical density, reflecting the
universality of heavy-tailed behavior at phase transitions.

---

## 6. Discussion

The conceptual yield of this development is the clean separation it enforces between the
*theory* (the random combinatorial object, a relation/edge set) and the *consequence
relation* (the derived structure, its reflexive–transitive closure). This separation is what
allows random-graph theory to be brought to bear on random *formal theories*. Monotonicity
(Pillar I) supplies the admissibility hypothesis for threshold theorems; the barrier method
(Pillar II) supplies the impossibility certificates; the chain (Pillars III–V) supplies the
exactly-solvable extremal model against which density, redundancy, and proof length are
measured.

A noteworthy methodological point is the *reusability* of the barrier lemma. Both directions
of non-derivability we prove — "no backward derivation" and "a deleted axiom blocks the
proof" — are the *same* lemma applied to different cuts: the upward cut `{k | a ≤ k}` and the
downward cut `{k | k ≤ m}` respectively. Impossibility in this setting is uniformly the
exhibition of an invariant cut, exactly as conservation laws certify dynamical impossibility.

A second point is the constructive character of the whole development. Every existence claim
is witnessed by an explicit object (a path, a derivation list) of measured size, so the
results translate without friction into the algorithms of Section 4.

---

## 7. Future work

The immediate target is a fully formal proof of the probabilistic sharp threshold (Section
5.1), which reduces — given the monotonicity we have established — to formalizing Friedgut's
theorem and the requisite Fourier analysis on the Boolean cube. Beyond that lie the
proof-length transition (Section 5.2), the multi-premise/hypergraph generalization (Section
5.3), the thermodynamics of the derivability order (Section 5.4), and the criticality-index
distribution (Section 5.5). Each builds directly on a pillar formalized here: the chain's
constructive length for proof complexity, the barrier method for hypergraph impossibility, the
theory/consequence separation for random orders, and the criticality results for backbones.

---

## 8. Conclusion

We have laid the structural foundation for a theory of *proof phase transitions* in
single-conclusion implicational logic. By identifying derivability with reflexive–transitive
closure — graph reachability — we obtained monotonicity for free, isolated the barrier method
as the universal impossibility certificate, and solved the linear chain completely: a sharp
order-theoretic boundary, criticality of every axiom, and an explicit minimal-length witness.
These five pillars are the precise inputs that probabilistic threshold theory, proof
complexity, and random-order thermodynamics require. The toy of arrows and paths is, in the
end, a faithful microcosm of the moment when reasoning itself crystallizes from impossible to
inevitable.
