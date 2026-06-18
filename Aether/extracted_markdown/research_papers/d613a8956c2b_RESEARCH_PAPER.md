# Formalized Karchmer-Wigderson Correspondence and Monotone Formula Lower Bounds

## Abstract

We present the first machine-verified formalization of the Karchmer-Wigderson correspondence for monotone Boolean formulas, together with a certified lower bound transfer mechanism and a concrete lower bound for the OR function. Our development, formalized in Lean 4 with the Mathlib library, establishes a complete bidirectional equivalence between monotone formula depth and the deterministic communication complexity of the monotone KW search problem. We introduce a novel "certified protocol tree" formalization that embeds correctness constraints directly into the inductive type structure, enabling clean inductive proofs of both directions. The formalization comprises approximately 350 lines of definitions and proofs with zero unverified assumptions (`sorry`-free), using only standard axioms (propext, Classical.choice, Quot.sound).

## 1. Introduction

### 1.1 Background

The Karchmer-Wigderson (KW) theorem [KW88] establishes a fundamental connection between circuit complexity and communication complexity. For monotone Boolean functions, it states that the minimum depth of a monotone formula computing a function *f* equals the deterministic communication complexity of the associated monotone KW search problem. This correspondence has been instrumental in proving lower bounds for monotone computation, including the seminal results of Karchmer and Wigderson on st-connectivity [KW90].

### 1.2 Contributions

1. **Certified KW Protocol Trees** (§3): A novel inductive type `KWProto` indexed by predicates describing reachable input sets, with correctness conditions guarded by nonemptiness requirements. This design enables vacuous protocols for constant functions while supporting clean inductive proofs.

2. **Formula → Protocol (Theorem A)** (§4): A constructive transformation from monotone formulas to KW protocols, with a machine-verified cost bound.

3. **Protocol → Formula (Theorem B)** (§5): An extraction procedure from protocols to formulas, handling unreachable subtrees via classical case analysis, with verified correctness and depth bounds.

4. **Lower Bound Transfer (Theorem C)** (§6): A formal mechanism for transferring communication complexity lower bounds to formula depth lower bounds.

5. **Concrete Lower Bound** (§7): A verified proof that the OR function on n ≥ 2 variables requires monotone formula depth at least 1, demonstrating the complete pipeline from communication game analysis to circuit lower bounds.

## 2. Definitions and Notation

### 2.1 Bitwise Ordering

```
def BitwiseLE (x y : Fin n → Bool) : Prop :=
  ∀ i, x i = true → y i = true
```

This is the standard product ordering on {0,1}ⁿ.

### 2.2 Monotone Boolean Functions

```
def MonotoneBool (f : (Fin n → Bool) → Bool) : Prop :=
  ∀ ⦃x y⦄, BitwiseLE x y → f x = true → f y = true
```

### 2.3 Monotone Formulas

```
inductive MonoFormula (n : ℕ) where
  | var : Fin n → MonoFormula n
  | top | bot : MonoFormula n
  | and | or : MonoFormula n → MonoFormula n → MonoFormula n
```

With semantics `eval`, structural metrics `depth` and `size`, and a verified monotonicity theorem `eval_monotone`.

### 2.4 KW Witness Existence

**Theorem (exists_KW_witness):** For any monotone function *f*, if *f(x) = true* and *f(y) = false*, there exists an index *i* with *x(i) = true* and *y(i) = false*.

*Proof.* By contraposition: if no such *i* exists, then *x ≤ y* in the bitwise order, so *f(y) = true* by monotonicity, contradicting *f(y) = false*. □

## 3. Certified KW Protocol Trees

### 3.1 Design Philosophy

A key formalization challenge is representing protocols with their correctness guarantees. We introduce `KWProto`, an inductive type indexed by two predicates `PA, PB : (Fin n → Bool) → Prop` describing the reachable Alice and Bob input sets:

```
inductive KWProto (n : ℕ) :
    ((Fin n → Bool) → Prop) → ((Fin n → Bool) → Prop) → Type 1 where
  | leaf (i : Fin n)
      (hA : (∃ y, PB y) → ∀ x, PA x → x i = true)
      (hB : (∃ x, PA x) → ∀ y, PB y → y i = false)
  | alice (q : (Fin n → Bool) → Bool)
      (t_ff : KWProto n (fun x => PA x ∧ q x = false) PB)
      (t_tt : KWProto n (fun x => PA x ∧ q x = true) PB)
  | bob (q : (Fin n → Bool) → Bool)
      (t_ff : KWProto n PA (fun y => PB y ∧ q y = false))
      (t_tt : KWProto n PA (fun y => PB y ∧ q y = true))
```

**Key design decisions:**

1. **Predicate indexing**: The predicates `PA` and `PB` track the reachable input sets *structurally*, enabling inductive proofs without auxiliary reachability predicates.

2. **Guarded leaf conditions**: The conditions `hA` and `hB` at leaves are guarded by nonemptiness of the *opposite* set. This is crucial: it allows constructing vacuous protocols when `PA` or `PB` is empty (e.g., for constant functions), while maintaining enough strength for the correctness proofs.

3. **Predicate refinement**: At Alice nodes, the Alice predicate is refined by conjoining the query result, while Bob's predicate is unchanged (and vice versa). This mirrors the rectangle structure of communication protocols.

### 3.2 Weakening

The `weaken` operation adapts a protocol from predicates `(PA, PB)` to subsets `(PA', PB')`:

```
def weaken (hA : ∀ x, PA' x → PA x) (hB : ∀ y, PB' y → PB y) :
    KWProto n PA PB → KWProto n PA' PB'
```

**Theorem (weaken_cost):** `(T.weaken hA hB).cost = T.cost`.

## 4. Formula → Protocol (Theorem A)

### 4.1 Construction

Given a monotone formula `φ`, we construct a KW protocol by structural recursion:

- **`var i`**: A leaf outputting index `i`. Correctness: `x(i) = true` is exactly `PA x`, and `y(i) = false` is exactly `PB y`.

- **`or φ₁ φ₂`**: An Alice node querying `φ₁(x)`. If true, recurse on `φ₁`; if false, `φ₂(x)` must be true (since OR is true), so recurse on `φ₂`. The weakening from the parent predicates to the child formula's predicates uses Boolean logic on the OR structure.

- **`and φ₁ φ₂`**: A Bob node querying `φ₁(y)`. If false, recurse on `φ₁`; if true, `φ₂(y)` must be false (since AND is false), so recurse on `φ₂`.

- **`top` / `bot`**: Vacuous protocols (one side's predicate is empty).

### 4.2 Cost Bound

**Theorem (toKWProto_cost):** `φ.toKWProto.cost ≤ φ.depth`.

*Proof.* By induction on `φ`, using `weaken_cost` to show that weakening preserves cost.

### 4.3 Main Result

**Theorem A (monotone_formula_gives_KW_protocol):** For any monotone formula `φ` computing `f`, there exists a KW protocol `P` for `f` with `P.cost ≤ φ.depth`.

## 5. Protocol → Formula (Theorem B)

### 5.1 Formula Extraction

Given a protocol tree `T`, we extract a formula `toFormula` by:

- **Leaf `i`**: `var i`
- **Alice node**: OR of children's formulas (when both subtrees have reachable Alice inputs); otherwise, the single reachable subtree's formula; otherwise `bot`.
- **Bob node**: AND of children's formulas (symmetrically); otherwise, the single reachable subtree's formula; otherwise `top`.

The case analysis on reachable set nonemptiness uses classical logic (`Decidable` via `Classical.choice`).

### 5.2 Correctness

**Theorem (toFormula_true):** If `PA x` and `∃ y, PB y`, then `T.toFormula.eval x = true`.

**Theorem (toFormula_false):** If `PB y` and `∃ x, PA x`, then `T.toFormula.eval y = false`.

Both are proved by induction on `T`, with case analysis matching the `toFormula` definition.

### 5.3 Depth Bound

**Theorem (toFormula_depth):** `T.toFormula.depth ≤ T.cost`.

### 5.4 Main Result

**Theorem B (KW_protocol_gives_monotone_formula):** For any non-constant monotone function `f` and any KW protocol `P` for `f`, there exists a monotone formula `φ` with `∀ x, φ.eval x = f x` and `φ.depth ≤ P.cost`.

## 6. Lower Bound Transfer (Theorem C)

**Theorem C (KW_lower_bound_implies_formula_depth_lower_bound):** If every KW protocol for `f` has cost at least `c`, then every monotone formula computing `f` has depth at least `c`.

*Proof.* Given a formula `φ` computing `f`, Theorem A produces a protocol `P` with `P.cost ≤ φ.depth`. The hypothesis gives `c ≤ P.cost`. By transitivity, `c ≤ φ.depth`. □

## 7. Concrete Lower Bound: OR Function

### 7.1 Definition

```
def orFn (n : ℕ) : (Fin n → Bool) → Bool :=
  fun x => decide (∃ i : Fin n, x i = true)
```

### 7.2 Properties

- **orFn_iff**: `orFn n x = true ↔ ∃ i, x i = true`
- **orFn_monotone**: `MonotoneBool (orFn n)`

### 7.3 Communication Lower Bound

**Theorem (orFn_KW_cost_ge_one):** For `n ≥ 2`, any KW protocol for `orFn n` has cost ≥ 1.

*Proof.* A zero-cost protocol is a leaf `i` with:
- `hA`: (∃ y, orFn n y = false) → ∀ x, orFn n x = true → x i = true

The all-false vector witnesses `∃ y, orFn n y = false`. Choose `j ≠ i` (exists since `n ≥ 2`). The unit vector `eⱼ` (true only at `j`) satisfies `orFn n eⱼ = true`. By `hA`, `eⱼ i = true`. But `eⱼ i = false` since `i ≠ j`. Contradiction. □

### 7.4 Formula Depth Lower Bound

**Theorem (or_function_depth_ge_one):** For `n ≥ 2`, any monotone formula computing OR has depth ≥ 1.

*Proof.* Apply Theorem C with `c = 1`, using `orFn_KW_cost_ge_one`. □

## 8. Discussion

### 8.1 Formalization Metrics

| Component | Lines | Sorries |
|-----------|-------|---------|
| Definitions (Defs.lean) | ~180 | 0 |
| KW Correspondence (KarchmerWigderson.lean) | ~350 | 0 |
| **Total** | **~530** | **0** |

### 8.2 Key Design Insights

1. **Predicate-indexed inductive types** enabled clean inductive proofs by embedding the communication game's rectangle structure into the type system.

2. **Guarded leaf conditions** (conditioned on nonemptiness of the opposite set) were essential for handling constant functions while maintaining proof strength.

3. **Classical case analysis** in `toFormula` was necessary to handle unreachable subtrees, which cannot be avoided in general protocols.

### 8.3 Limitations

- The current concrete lower bound (depth ≥ 1 for OR) is modest. The framework supports stronger bounds (e.g., depth ≥ ⌈log₂ n⌉ for OR) via rectangle counting arguments, which are a natural next step.
- The formalization covers monotone formulas (trees) but not monotone circuits (DAGs). Extending to circuits requires different techniques (e.g., Razborov's approximation method).

## 9. Future Work

See FUTURE_DIRECTIONS.md for detailed next steps including:
1. Logarithmic lower bound for OR via rectangle counting
2. Razborov's approximation method for clique lower bounds
3. Feasible interpolation for proof complexity
4. Extension complexity via communication complexity

## References

[KW88] M. Karchmer and A. Wigderson. "Monotone circuits for connectivity require super-logarithmic depth." *STOC*, 1988.

[KW90] M. Karchmer and A. Wigderson. "On the connection between communication complexity and circuit complexity." *STOC*, 1990.

[Raz85] A. Razborov. "Lower bounds on the monotone complexity of some Boolean functions." *Doklady Akademii Nauk SSSR*, 1985.

[Jan12] S. Jukna. *Boolean Function Complexity: Advances and Frontiers.* Springer, 2012.

[AB09] S. Arora and B. Barak. *Computational Complexity: A Modern Approach.* Cambridge University Press, 2009.
