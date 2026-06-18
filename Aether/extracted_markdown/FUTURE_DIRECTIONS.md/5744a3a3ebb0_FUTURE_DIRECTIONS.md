# Future Directions: Monotone Circuit Complexity in Lean

This document outlines five concrete next steps building on the formalized Karchmer-Wigderson correspondence and monotone formula lower bounds.

---

## 1. Full KW Equivalence for General (Non-Monotone) Formulas

**Theorem Statement:**
For any Boolean function `f : (Fin n → Bool) → Bool`, the minimum depth of a formula (with negation) computing `f` equals the deterministic communication complexity of the KW relation `KW_f`, where Alice holds `x ∈ f⁻¹(1)`, Bob holds `y ∈ f⁻¹(0)`, and they must find `i` with `x i ≠ y i`.

**Lean Definitions Needed:**
- `Formula n` — formulas with negation, AND, OR
- `KWRelation n f` — general KW relation (find any differing index)
- `DetProtocol` — general deterministic protocol (not restricted to monotone queries)

**Proof Strategy:**
Extend the current proof by allowing negation gates. In the formula→protocol direction, a negation flips which player queries. In the protocol→formula direction, the same OR/AND construction works but with negated variables at leaves where the protocol output indicates `y i = true ∧ x i = false`.

**Cross-Domain Connection:**
Connects to proof complexity via feasible interpolation: a short proof of `φ(x) ∧ ψ(y) → ∨ᵢ (xᵢ ≠ yᵢ)` yields a short communication protocol, hence a small formula separator.

---

## 2. Logarithmic Lower Bound for OR via Rectangle Counting

**Theorem Statement:**
```
theorem orFn_KW_cost_ge_log (hn : 1 ≤ n) (P : KWProtocol n (orFn n)) :
    Nat.clog 2 n ≤ P.cost
```

**Lean Definitions Needed:**
- `KWProto.numLeaves` — count leaves in a protocol tree
- `KWProto.numLeaves_le_pow_cost` — the number of leaves is at most `2^cost`
- Proof that each leaf of an OR protocol covers at most one Alice input

**Proof Strategy:**
Each leaf `i` of a correct KW protocol for OR has `hA : ∀ x, orFn x = true → x i = true`. Among the `n` "unit vectors" (exactly one coordinate true), only the one with coordinate `i` true satisfies this. So each leaf covers at most one unit vector. There are `n` unit vectors, so at least `n` leaves are needed. Since a protocol of cost `c` has at most `2^c` leaves, `2^c ≥ n`, giving `c ≥ ⌈log₂ n⌉`.

**Cross-Domain Connection:**
This is a miniature version of rectangle/partition lower bounds. The same counting argument generalizes to threshold functions and clique predicates.

---

## 3. Monotone Circuit Size Lower Bounds via Approximation Method

**Theorem Statement:**
```
theorem monotone_circuit_size_lower_bound_for_clique
    (m k : ℕ) (C : MonoCircuit (numEdges m)) (hC : C.eval = hasClique m k) :
    explicitBound m k ≤ C.size
```

**Lean Definitions Needed:**
- `MonoCircuit n` — monotone circuits (DAGs, not just trees/formulas)
- `Graph m`, `hasClique m k` — graph predicates
- `SimpleApproximator` — low-complexity approximators (e.g., DNFs of bounded width)
- `approximationError` — probability of disagreement under a chosen distribution

**Proof Strategy (Razborov's Approximation Method):**
1. Every small monotone circuit is close to a simple approximator under a random graph distribution.
2. Every simple approximator fails to distinguish clique-containing graphs from sparse graphs.
3. The clique predicate does distinguish them, so no small circuit computes it.

The key technical lemma: each AND/OR gate introduces bounded approximation error, which accumulates multiplicatively with circuit size.

**Cross-Domain Connection:**
Links to extremal combinatorics (sunflower lemma), probability (random graph models), and information theory (the approximator's "information content" is bounded).

---

## 4. Feasible Interpolation for Resolution

**Theorem Statement:**
```
theorem resolution_interpolation
    (π : ResolutionProof (φ ∧ ψ → ⊥))
    (h_disjoint : Disjoint (vars φ) (vars ψ)) :
    ∃ C : MonoCircuit n, C.eval = interpolant φ ψ ∧ C.size ≤ π.size
```

**Lean Definitions Needed:**
- `ResolutionProof` — resolution proof system for propositional logic
- `interpolant` — Craig interpolant between disjoint variable sets
- Connection from resolution width/size to communication/circuit complexity

**Proof Strategy:**
A resolution refutation of `φ(x, z) ∧ ψ(y, z)` induces a communication protocol between Alice (who knows `x`) and Bob (who knows `y`). Alice simulates the resolution proof, communicating the truth value of shared variables `z` as they appear. Each resolution step corresponds to one bit of communication. The KW correspondence then converts this protocol into a circuit.

**Cross-Domain Connection:**
This connects proof complexity to circuit complexity. Lower bounds on monotone circuits (from Direction 3) yield lower bounds on resolution proof length — a major result in proof complexity.

---

## 5. Extension Complexity via Communication Complexity

**Theorem Statement:**
```
theorem extension_complexity_lower_bound
    (P : Polytope) (f : MonotoneBool) (hf : P = f.polytope) :
    commComplexity f ≤ log₂ (extensionComplexity P)
```

**Lean Definitions Needed:**
- `Polytope`, `extensionComplexity` — polytopes and their extension complexity
- `SlackMatrix` — the slack matrix of a polytope
- `nonnegativeRank` — nonnegative rank of a matrix
- Connection between nonnegative rank and rectangle covers

**Proof Strategy:**
The extension complexity of a polytope equals the nonnegative rank of its slack matrix (Yannakakis' theorem). The nonnegative rank equals the minimum number of rectangles covering the 1-entries of the slack matrix. This rectangle cover number is related to the communication complexity of the corresponding Boolean function. Formalizing this chain gives a bridge from communication lower bounds to polytope extension complexity lower bounds.

**Cross-Domain Connection:**
Connects combinatorial optimization (LP formulations), communication complexity, and algebraic complexity. The celebrated lower bound on the extension complexity of the correlation polytope (and hence TSP) uses exactly this bridge.

---

## Research Team Directive

Each direction above should be pursued with:
1. **Hypothesis formation**: State the precise Lean theorem and verify small instances with `#eval`.
2. **Definition development**: Build the required mathematical infrastructure incrementally.
3. **Proof decomposition**: Break each theorem into 5-10 independent lemmas.
4. **Validation**: Test each lemma on concrete examples before full proof attempts.
5. **Integration**: Ensure each new result imports and extends the existing KW infrastructure.

Priority order: Direction 2 (logarithmic OR bound) is most accessible and validates the framework. Direction 3 (approximation method) is the highest-impact target. Directions 4 and 5 are longer-term goals that leverage the full KW infrastructure.
