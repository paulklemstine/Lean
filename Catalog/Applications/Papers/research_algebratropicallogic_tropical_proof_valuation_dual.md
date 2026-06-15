# Tropical Proof-Valuation Duality via Min-Plus Consequence Operators

## Abstract

We establish a structural duality between weighted proof systems and tropical (min-plus) algebra. Given a finite weighted proof system — a collection of inference rules, each with premises, a conclusion, and a non-negative integer weight — we define a consequence operator on the complete lattice of valuations `P → ℕ∞` and prove three main results: (1) the minimal derivation cost function is the greatest fixed point of this operator (Bellman optimality), (2) every fixed point provides a sound lower bound on derivation costs, and (3) for every derivable proposition, the minimum cost is attained by a concrete derivation (certified reconstruction). All results are formalized and verified in the Lean 4 proof assistant with no unproven assumptions beyond standard axioms.

## 1. Introduction

### 1.1 Motivation

The problem of finding optimal proofs in weighted logical systems arises in multiple domains:

- **Automated theorem proving**: Minimizing proof length or complexity.
- **Logic programming**: Computing minimal-cost answers in weighted Datalog.
- **Verification**: Finding shortest error traces or minimal counterexamples.
- **Network optimization**: Shortest hyperpaths generalize shortest paths.

The connection between shortest-path algorithms and logic programming has been noted informally, but a precise algebraic duality — showing that the tropical fixed-point structure completely characterizes proof cost semantics — has not been established in the formal mathematics literature.

### 1.2 Contributions

1. **Formalization of weighted proof systems** with an inductive derivation predicate supporting structural induction through nested sub-derivations.

2. **Bellman fixed-point theorem**: The minimal derivation cost function satisfies the tropical consequence equation `T(m) = m`, and it is the greatest fixed point of `T` among all valuations.

3. **Certified reconstruction**: For every derivable proposition, the infimum cost is attained — there exists a concrete derivation achieving exactly the minimum cost.

4. **Prime template classification**: The minimal derivation cost function is a "prime template" — every proposition with finite cost is directly justified by an axiom or a rule with all premises having finite cost.

5. **Machine-verified proofs**: All results are formally verified in Lean 4 with Mathlib, using only standard axioms (propext, Classical.choice, Quot.sound).

### 1.3 Related Work

- **Bellman equations and dynamic programming** (Bellman, 1957): The fixed-point characterization of optimal costs in sequential decision problems.
- **Tropical semirings** (Simon, 1988; Pin, 1998): Algebraic structures with idempotent addition.
- **Logic programming semantics** (van Emden & Kowalski, 1976; Lloyd, 1987): Immediate consequence operators and their fixed points.
- **Shortest hyperpaths** (Gallo et al., 1993; Knuth, 1977): Generalization of shortest paths to directed hypergraphs.
- **Proof complexity** (Cook & Reckhow, 1979): Measuring the difficulty of proofs in formal systems.

Our contribution unifies these threads by establishing a precise algebraic duality with machine-verified proofs.

## 2. Definitions and Notation

### 2.1 Cost Domain

We work over the extended natural numbers `ℕ∞ = ℕ ∪ {∞}`, equipped with the natural order where `∞` is the top element. This forms a complete lattice under `min` (as meet) with `∞` as top and `0` as bottom. Addition extends to `ℕ∞` by `∞ + n = n + ∞ = ∞`.

### 2.2 Weighted Proof Systems

**Definition.** A *weighted proof system* over a type `P` of propositions consists of:
- A list `rules` of *weighted inference rules*, each specifying:
  - `premises : List P` — the required hypotheses
  - `conclusion : P` — the derived proposition
  - `weight : ℕ` — the cost of applying this rule
- A predicate `isAxiom : P → Bool` — axioms are derivable at cost 0.

### 2.3 Derivations

**Definition.** The predicate `HasDeriv S q n` (proposition `q` is derivable in system `S` at cost `n`) is defined inductively:

1. **Axiom**: If `isAxiom(q) = true`, then `HasDeriv S q 0`.
2. **Rule application**: If rule `r ∈ S.rules` has premises `p₁, ..., pₖ` and weight `w`, and for each `i`, `HasDeriv S pᵢ cᵢ`, then `HasDeriv S r.conclusion (w + Σᵢ cᵢ)`.

**Definition.** `Derivable S q ≡ ∃ n, HasDeriv S q n`.

**Definition.** `minDerivCost S q = ⨅{n : ℕ | HasDeriv S q n}` (as an element of `ℕ∞`).

### 2.4 Consequence Operator

**Definition.** The *rule cost* of applying rule `r` given valuation `f : P → ℕ∞` is:
```
ruleCost(f, r) = r.weight + Σ_{p ∈ r.premises} f(p)
```

**Definition.** The *consequence operator* `T_S : (P → ℕ∞) → (P → ℕ∞)` is:
```
T_S(f)(q) = min(axiomCost(q), inf_{r : r.conclusion = q} ruleCost(f, r))
```
where `axiomCost(q) = 0` if `q` is an axiom, `∞` otherwise.

## 3. Main Results

### 3.1 Monotonicity (Theorem `consequenceOp_monotone`)

**Theorem.** The consequence operator `T_S` is monotone on `(P → ℕ∞, ≤)`.

*Proof sketch.* If `f ≤ g` pointwise, then for each rule `r`, `ruleCost(f, r) ≤ ruleCost(g, r)` (since addition and summation are monotone on `ℕ∞`). Taking infima preserves the inequality. □

### 3.2 Soundness (Theorem `fixedPoint_le_derivCost`)

**Theorem.** If `f` is a fixed point of `T_S` (i.e., `T_S(f) = f`), then for all `q` and `n`, `HasDeriv S q n` implies `f(q) ≤ n`.

*Proof sketch.* By structural induction on derivations.

- **Axiom case**: `f(q) = T_S(f)(q) ≤ axiomCost(q) = 0 = n`. ✓
- **Rule case**: `f(q) = T_S(f)(q) ≤ ruleCost(f, r) = w + Σ f(pᵢ)`. By induction hypothesis, `f(pᵢ) ≤ cᵢ` for each premise. So `f(q) ≤ w + Σ cᵢ = n`. ✓

**Corollary** (`fixedPoint_le_minDerivCost`): Every fixed point `f` satisfies `f ≤ minDerivCost` pointwise.

### 3.3 Bellman Optimality (Theorem `minDerivCost_fixed_point`)

**Theorem.** `T_S(minDerivCost) = minDerivCost`.

*Proof.* Two directions:

**Direction ≤** (`consequenceOp_minDerivCost_le`): For any derivation `HasDeriv S q n`, `T_S(m)(q) ≤ n`. By cases:
- Axiom: `T_S(m)(q) ≤ 0 = n`.
- Rule `r` with costs `cᵢ`: `T_S(m)(q) ≤ ruleCost(m, r) ≤ w + Σ cᵢ = n` (since `m(pᵢ) ≤ cᵢ` by definition of infimum).

**Direction ≥** (`minDerivCost_le_consequenceOp`): If `T_S(m)(q) = c < ∞`, then either `q` is an axiom (so `m(q) = 0 ≤ c`) or some rule `r` has `ruleCost(m, r) ≤ c`. In the latter case, each premise `pᵢ` has `m(pᵢ) < ∞`, hence is derivable. By well-orderedness of `ℕ`, the infimum `m(pᵢ)` is attained by some derivation of cost `m(pᵢ)`. Combining these sub-derivations via rule `r` yields a derivation of `q` at cost `w + Σ m(pᵢ) ≤ c`. □

### 3.4 Greatest Fixed Point (Theorem `minDerivCost_greatest_fixedPoint`)

**Theorem.** `minDerivCost` is the greatest fixed point of `T_S`: it is a fixed point, and every other fixed point `f` satisfies `f ≤ minDerivCost`.

*Proof.* Combines Theorems 3.2 and 3.3. □

### 3.5 Certified Reconstruction (Theorem `exists_optimal_derivation`)

**Theorem.** For every derivable `q`, there exists `n` such that `HasDeriv S q n` and `minDerivCost S q = n`.

*Proof.* Since `q` is derivable, the set `{n : ℕ | HasDeriv S q n}` is nonempty. Its infimum in `ℕ∞` is finite (≤ the cost of any witness derivation), hence equals some `m ∈ ℕ`. By well-orderedness of `ℕ`, this infimum is attained: `HasDeriv S q m` and `m = minDerivCost S q`. □

### 3.6 Prime Template (Theorem `minDerivCost_isPrimeTemplate`)

**Theorem.** `minDerivCost` is a prime template: every proposition with finite cost is directly justified by an axiom or by a rule whose premises all have finite cost.

*Proof.* If `minDerivCost(q) < ∞`, then `q` is derivable. By the reconstruction theorem, the optimal derivation exists. If it's an axiom, done. If it uses rule `r`, each premise has a sub-derivation, hence finite cost. □

### 3.7 Main Duality Theorem

**Theorem** (`tropical_proof_valuation_duality`). For any weighted proof system `S`:
1. `T_S(minDerivCost) = minDerivCost` (Bellman equation).
2. For all fixed points `f` of `T_S`: `f ≤ minDerivCost` (greatest fixed point).
3. For all derivable `q`: the minimum cost is attained (certified reconstruction).

## 4. Algorithms

### 4.1 Bellman Iteration

```
Algorithm: ComputeMinDerivCost(S)
Input: Weighted proof system S with propositions P
Output: minDerivCost : P → ℕ∞

1. Initialize f(q) = 0 if isAxiom(q), else f(q) = ∞
2. Repeat:
   a. f' = T_S(f)  // Apply consequence operator
   b. If f' = f, return f
   c. f = f'
3. Return f
```

**Complexity**: For `|P| = n` propositions, `|R| = m` rules, and maximum cost `W`:
- Each iteration updates all propositions: `O(m · k)` where `k` is the max premise count.
- At most `n · W` iterations (each iteration decreases at least one cost by at least 1).
- Total: `O(n · W · m · k)`.

### 4.2 Witness Reconstruction

```
Algorithm: ReconstructDerivation(S, q, f)
Input: S, target q, optimal valuation f = minDerivCost
Output: Derivation tree of q with cost f(q)

1. If isAxiom(q): return AxiomDeriv(q)
2. Find rule r with r.conclusion = q and
   r.weight + Σ f(pᵢ) = f(q)
3. For each premise pᵢ of r:
   dᵢ = ReconstructDerivation(S, pᵢ, f)
4. Return RuleDeriv(r, [d₁, ..., dₖ])
```

**Correctness**: Guaranteed by `exists_optimal_derivation`.

## 5. Concrete Example

We demonstrate the theory on a system with 3 propositions (0, 1, 2):
- Proposition 0 is an axiom (cost 0)
- Rule: {0} ⊢ 1 (weight 3)
- Rule: {0, 1} ⊢ 2 (weight 2)

**Optimal costs:**
| Proposition | minDerivCost | Optimal derivation |
|---|---|---|
| 0 | 0 | Axiom |
| 1 | 3 | Rule 1 from {0} |
| 2 | 5 | Rule 2 from {0, 1} (0 + 3 + 2) |

These results are formally verified in the Lean development.

## 6. Discussion

### 6.1 Relationship to Shortest Hyperpaths

A weighted proof system is precisely a directed B-hypergraph. Our consequence operator is the Bellman operator for shortest B-hyperpaths (Gallo et al., 1993). The main duality theorem thus provides a formal proof of correctness for shortest-hyperpath dynamic programming, embedded in a proof-theoretic framework.

### 6.2 Greatest vs. Least Fixed Point

An important subtlety: `minDerivCost` is the *greatest*, not least, fixed point of `T_S`. This is because the consequence operator is defined on `(P → ℕ∞, ≤)` where smaller values represent better (cheaper) derivations. The least fixed point assigns cost 0 everywhere (including non-derivable propositions), which is unsound. The greatest fixed point correctly assigns `∞` to non-derivable propositions.

### 6.3 Handling Cycles

Rules with weight 0 can create cycles in the derivation graph. The formalization handles this correctly: a cycle with weight 0 does not produce a derivation (there is no base case), so `minDerivCost` correctly assigns `∞` to propositions that are only reachable through zero-weight cycles without axiom support.

### 6.4 Extremal Valuations

We define extremal valuations (those that cannot be decomposed as the pointwise minimum of two strictly larger realizable valuations) and prime templates (where every finite-cost proposition is directly justified). We prove that `minDerivCost` is both realizable and a prime template. The full classification of extremal valuations as prime templates (and vice versa) is an important direction for future work.

## 7. Future Work

See FUTURE_DIRECTIONS.md for detailed research directions including:
1. Enriched category formulation over quantales
2. Extension to infinite proof systems via ω-continuity
3. Proof entropy and tropical information measures
4. Craig interpolation via extremal factorization
5. Weighted linear logic and game semantics realization

## 8. References

1. R. Bellman, *Dynamic Programming*, Princeton University Press, 1957.
2. G. Gallo, G. Longo, S. Pallottino, S. Nguyen, "Directed hypergraphs and applications," *Discrete Applied Mathematics*, 42(2-3):177-201, 1993.
3. D.E. Knuth, "A generalization of Dijkstra's algorithm," *Information Processing Letters*, 6(1):1-5, 1977.
4. I. Simon, "Recognizable sets with multiplicities in the tropical semiring," *MFCS 1988*, LNCS 324, pp. 107-120, 1988.
5. M.H. van Emden, R.A. Kowalski, "The semantics of predicate logic as a programming language," *JACM*, 23(4):733-742, 1976.
6. S.A. Cook, R.A. Reckhow, "The relative efficiency of propositional proof systems," *Journal of Symbolic Logic*, 44(1):36-50, 1979.
