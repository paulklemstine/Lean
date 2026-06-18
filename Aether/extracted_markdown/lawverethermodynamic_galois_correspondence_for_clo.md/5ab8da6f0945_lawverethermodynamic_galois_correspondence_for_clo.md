# The Lawvere–Thermodynamic Galois Correspondence: Identifying Derivability Closure with Free-Energy Adjunction

## Abstract

We formalize and prove the **Lawvere–Thermodynamic Galois Correspondence**, a bridge theorem that identifies derivability closure in proof theory with the closure operator induced by a Galois connection between proof states and thermodynamic observables. The central result is a representation theorem: the derivability-closed proof states are *exactly* those determined by thermodynamic observables. All results are machine-verified in Lean 4 using Mathlib. We demonstrate finite stabilization of iterative refinement and discuss applications to proof search, semantic compression, and spectral reconstruction.

## 1. Introduction

A fundamental question in the foundations of mathematics is: *what is the relationship between syntactic derivability and semantic truth?* Classical completeness theorems (Gödel, Henkin) answer this for first-order logic: a sentence is derivable if and only if it is true in all models. But this answer is non-constructive and non-quantitative.

We propose a different bridge, inspired by two traditions:

1. **Lawvere's enriched category theory** (1973), which reinterprets logical entailment as a generalized metric, and adjunctions as the fundamental organizing structure of semantics.

2. **Thermodynamic semantics**, which associates to each proof state a "free-energy profile" measuring its separation from thermodynamic observables — much as a physical system's free energy measures its distance from equilibrium.

The bridge theorem states: *derivability closure is the closure operator induced by the Galois connection between proof states and observables*. More precisely:

**Theorem (Representation).** Let `P` be a partial order of proof states, `O` a preorder of observables, and `(lowerEnv, theoryOf)` a Galois connection between `P` and `O^{op}`. Then:

$$\{p \in P \mid \text{theoryOf}(\text{lowerEnv}(p)) = p\} = \text{range}(\text{theoryOf})$$

This says: a proof state is a fixed point of the thermodynamic closure if and only if it equals `theoryOf(o)` for some observable `o`.

## 2. Mathematical Framework

### 2.1 The Galois Connection

We work with two preordered sets:
- **P**: proof states, ordered by logical strength (p ≤ q means "q derives everything p derives")
- **O**: thermodynamic observables, ordered by informativeness

The key maps are:
- **lowerEnv : P → O^{op}**: the *free-energy lower envelope*, sending each proof state to its thermodynamic profile. This is antitone in the natural orders (stronger proofs have smaller envelopes), which becomes monotone when O carries the dual order.
- **theoryOf : O^{op} → P**: the *theory map*, sending each observable to the derivability-closed theory it determines. Also antitone in natural orders, monotone in the dualized setting.

These form a **Galois connection**: for all p ∈ P and o ∈ O^{op},

$$\text{lowerEnv}(p) \leq_{O^{op}} o \quad\Longleftrightarrow\quad p \leq_P \text{theoryOf}(o)$$

This adjunction law encodes the duality between syntactic derivability and semantic separation.

### 2.2 The Thermodynamic Closure Operator

The composite `c = theoryOf ∘ lowerEnv : P → P` is the **thermodynamic closure operator**. From the general theory of Galois connections, it satisfies:

1. **Extensivity**: p ≤ c(p) for all p
2. **Monotonicity**: p ≤ q implies c(p) ≤ c(q)
3. **Idempotency**: c(c(p)) = c(p) for all p (when P is a partial order)

**Proof sketch**. Extensivity follows from the Galois law: lowerEnv(p) ≤ lowerEnv(p) implies p ≤ theoryOf(lowerEnv(p)) = c(p). Monotonicity follows from composition of monotone maps. Idempotency uses the *counit inequality* lowerEnv(theoryOf(o)) ≤ o: applying theoryOf (monotone) gives c(c(p)) = theoryOf(lowerEnv(theoryOf(lowerEnv(p)))) ≤ theoryOf(lowerEnv(p)) = c(p), and extensivity gives the reverse inequality.

### 2.3 The Representation Theorem

**Theorem.** *The fixed points of thermodynamic closure are exactly the image of theoryOf:*

$$\text{Fix}(c) = \{p \mid c(p) = p\} = \text{range}(\text{theoryOf})$$

**Proof**. (⊇) If p = theoryOf(o), then c(p) = theoryOf(lowerEnv(theoryOf(o))). By the counit, lowerEnv(theoryOf(o)) ≤ o, so theoryOf(lowerEnv(theoryOf(o))) ≤ theoryOf(o) = p by monotonicity. Combined with extensivity, c(p) = p.

(⊆) If c(p) = p, then p = theoryOf(lowerEnv(p)) ∈ range(theoryOf).

### 2.4 Finite Stabilization

When P is finite, the iterative refinement sequence p, c(p), c²(p), ... stabilizes. In fact, since c is idempotent, it stabilizes after exactly one step: c(c(p)) = c(p) for all p.

**Theorem.** *For any p ∈ P, the sequence refineIter(n, p) = cⁿ(p) satisfies refineIter(1, p) = refineIter(n, p) for all n ≥ 1.*

This is a trivial consequence of idempotency, but it has a non-trivial algorithmic interpretation: one round of "thermodynamic refinement" (computing the free-energy profile and extracting the theory) suffices to reach the closed theory.

## 3. Formal Verification

All results are formalized in Lean 4 with Mathlib. The key declarations are:

| Declaration | Type | Description |
|---|---|---|
| `ThermoGaloisContext'` | structure | The abstract adjunction interface |
| `thermoClosure` | def | The closure operator c = theoryOf ∘ lowerEnv |
| `thermoClosureOperator` | def | Packaging as Mathlib's `ClosureOperator` |
| `le_thermoClosure` | theorem | Extensivity |
| `thermoClosure_monotone` | theorem | Monotonicity |
| `thermoClosure_idem` | theorem | Idempotency |
| `fixedPoints_thermoClosure_eq_range_theoryOf` | theorem | The Representation Theorem |
| `derivability_closed_iff_theory_of_observable` | theorem | Iff characterization |
| `derivabilityClosure_eq_thermoClosure` | theorem | Closure uniqueness |
| `refineIter_stabilizes_at_one` | theorem | 1-step stabilization |
| `refineIter_limit_is_closed` | theorem | Limit is a fixed point |

The proof development uses Mathlib's `GaloisConnection` API extensively, deriving monotonicity and adjunction properties from the connection rather than proving them from scratch. Total formalization: ~280 lines of Lean 4.

## 4. Discussion: A Scientific American Perspective

### What does this theorem really say?

Imagine you're trying to solve a puzzle. You have a collection of "proof states" — partial solutions, incomplete arguments, rough sketches. Some are better than others: more complete, more rigorous, closer to a real proof. There's a natural ordering: proof state A is "below" proof state B if B contains everything A does and more.

Now imagine you also have a collection of "thermodynamic observables" — measuring instruments, if you like. Each observable gives you a number that measures some aspect of a proof state, like how much "energy" it takes to maintain, or how "far" it is from a complete proof.

The Galois correspondence says: **there's a perfect duality between these two worlds**. For every observable, there's a "theory" — the set of all proof states that the observable can't distinguish from a complete proof. And for every proof state, there's a "free-energy profile" — the minimal set of observables needed to see that it's incomplete.

The closure operator is the bridge: it takes a proof state, computes its free-energy profile, and then finds the best theory compatible with that profile. The result is always at least as good as the original — you can never lose information by going through the thermodynamic lens.

The punchline: **the "derivability-closed" proof states — the ones that are already as good as they can get — are exactly the ones determined by some observable**. This is like saying: a physical system is in equilibrium if and only if its state is completely determined by its thermodynamic properties.

### An analogy from physics

Think of a gas in a box. Its microstate (positions and velocities of all molecules) is incredibly detailed. But thermodynamics tells us that the equilibrium state is determined by just a few macroscopic observables: temperature, pressure, volume.

The Galois correspondence says the same thing about proofs: a "mature" proof — one that can't be improved by further derivation — is completely characterized by its thermodynamic profile. The observable IS the proof, in the same way that the temperature-pressure-volume triple IS the equilibrium state.

### Why does this matter?

1. **For proof search**: Instead of searching through the vast space of proof states, we can search through observables. The correspondence guarantees we won't miss anything.

2. **For understanding**: It gives us a principled way to measure "how far" a partial proof is from completion — its free-energy gap.

3. **For compression**: Closed theories are determined by observables, which are often much simpler than the theories themselves.

4. **For transfer**: The same adjunction pattern appears whenever we have a "syntax-semantics" duality — in logic, in algebra, in topology, in physics.

## 5. Applications

### 5.1 Certified Proof Search

The iterative refinement scheme provides a certified convergence algorithm: starting from any proof state p, compute c(p) = theoryOf(lowerEnv(p)). The result is guaranteed to be derivability-closed. This transforms proof search from an open-ended exploration into a one-shot computation (given the Galois connection).

### 5.2 Semantic Compression

The representation theorem implies that every closed theory T has a "thermodynamic witness" — an observable o with theoryOf(o) = T. Finding the *minimal* such witness (in terms of description complexity) gives a semantic compression scheme: represent theories by their simplest determining observables.

### 5.3 Spectral Reconstruction

The fixed points of thermodynamic closure form a lattice isomorphic to (a quotient of) the observable lattice. This is the beginning of a spectral theory: observables are "points" of a spectrum, and closed theories are "open sets" (or "sections of a sheaf"). This connects proof theory to algebraic geometry's spectral methods.

## 6. Related Work

- **Lawvere (1973)**: Introduced the framework of enriched categories and generalized metric spaces that underlies our use of Galois connections for semantic interpretation.
- **Birkhoff (1935)**: The lattice-theoretic study of closure operators and their fixed-point characterizations.
- **Stone (1936)**: Stone duality between Boolean algebras and topological spaces, which is a special case of the observable-theory correspondence.
- **Galois connections in computer science**: Cousot & Cousot's abstract interpretation (1977) uses Galois connections between concrete and abstract domains — our setup is structurally analogous with "proof states" playing the role of concrete semantics and "observables" playing the role of abstract domains.

## 7. Conclusion

The Lawvere–Thermodynamic Galois Correspondence is not a deep mathematical theorem — the proofs follow straightforwardly from the theory of Galois connections. Its value lies in the *interpretation*: it provides a precise, machine-verified framework for understanding derivability closure through the lens of thermodynamic observables.

The formalization in Lean 4 serves as both a correctness guarantee and a template for future instantiations. The abstract `ThermoGaloisContext'` structure can be instantiated with any concrete pair of preorders and Galois-connected maps, automatically inheriting all the closure and fixed-point theorems.

The next steps — quantitative convergence bounds, sheaf-theoretic upgrades, tropical instantiations, and coding-theoretic optimality — are outlined in the accompanying FUTURE_DIRECTIONS.md.

## References

1. F. W. Lawvere, "Metric spaces, generalized logic, and closed categories," *Rendiconti del Seminario Matematico e Fisico di Milano*, 43 (1973), 135–166.
2. G. Birkhoff, "On the structure of abstract algebras," *Proceedings of the Cambridge Philosophical Society*, 31 (1935), 433–454.
3. M. H. Stone, "The theory of representations for Boolean algebras," *Transactions of the AMS*, 40 (1936), 37–111.
4. P. Cousot and R. Cousot, "Abstract interpretation: a unified lattice model for static analysis of programs," *POPL*, 1977.
5. B. A. Davey and H. A. Priestley, *Introduction to Lattices and Order*, Cambridge University Press, 2002.
