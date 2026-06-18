# Future Directions: Tropical Dynamics and Certification Theory

## Overview

The verified tropical matrix iteration theory (monotonicity, dominance certificates, nonexpansiveness, composition, growth bounds) opens five concrete research frontiers. Each direction includes exact theorem targets, required definitions, anticipated blockers, and which current lemmas enable them.

---

## Direction 1: Tropical Eigenvector Existence via Maximum Cycle Mean

### Target Theorem

```lean
theorem exists_tropical_eigenpair
    {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ)
    (h_irred : ∀ i j, ∃ k, tropicalMatPower A k i j > -∞) :
    ∃ (λ : ℝ) (v : Fin n → ℝ),
      ∀ i, tropicalMatMap A v i = v i + λ
```

### Strategy

1. **Define the maximum cycle mean** λ* as the maximum over all cycles of (cycle weight / cycle length). Formalize using `Finset.sup'` over the type of cycles `(k : ℕ) × (Fin k → Fin n)` with adjacency constraints.

2. **Construct the eigenvector** as the "longest path potential": `v_i = max over paths from a reference node to i of (path weight - λ* × path length)`. This is well-defined under irreducibility.

3. **Prove the eigen-equation** by showing `T(v)_i = v_i + λ*` using path extension arguments.

### Required New Definitions

- `tropicalMatPower`: k-th tropical power of A (use `tropicalMatMul` iterated).
- `cycleMean`: weight of a cycle divided by its length.
- `maxCycleMean`: supremum of cycle means over all simple cycles.
- `tropicalPotential`: longest-path potential vector.

### Anticipated Blockers

- Formalizing "all simple cycles" requires working with `Finset` over permutation-like structures. May need to use `List` with deduplication.
- The eigenvector construction requires showing the potential is finite, which needs irreducibility.
- Path-counting arguments may require significant combinatorial infrastructure.

### Enabling Lemmas

- `tropicalMatMap_comp` (composition = tropical multiplication) directly gives `T^k = T_{A^{⊗k}}`.
- `tropicalMatMap_iterate_lower_bound` provides the lower bound on path weights.
- `tropicalMatMap_add_const` (additive homogeneity) is essential for the normalization step.

### Cross-Domain Impact

- **Mean-payoff games**: the tropical eigenvalue equals the value of a mean-payoff game.
- **Performance analysis**: cycle time of discrete event systems.
- **Nonlinear Perron–Frobenius theory**: connects to the Collatz–Wielandt characterization.

---

## Direction 2: Path-Weight Semantics for Tropical Iterates

### Target Theorem

```lean
theorem tropical_iterate_path_expansion
    {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ)
    (x : Fin n → ℝ) :
    ∀ k i,
      (Nat.iterate (tropicalMatMap A) k x) i =
      Finset.univ.sup' (by infer_instance)
        (fun path : Fin (k + 1) → Fin n =>
          (∑ step in Finset.range k, A (path ⟨step, by omega⟩) (path ⟨step + 1, by omega⟩))
          + x (path ⟨k, by omega⟩))
```

(The exact formulation may need adjustment — the point is that `T^k(x)_i` equals the max over all length-k paths ending at `i` of the path weight plus the initial value at the start node, with the constraint `path 0 = i`.)

### Strategy

1. **Base case (k=0)**: `T^0(x)_i = x_i`, which equals the max over the trivial path.
2. **Inductive step**: `T^{k+1}(x)_i = max_j (A_{ij} + T^k(x)_j)`. By IH, `T^k(x)_j` is the max over length-k paths starting at j. Prepending the edge i→j gives a length-(k+1) path starting at i.
3. **Key lemma**: the sup over (j, paths from j) equals the sup over (paths from i of length k+1).

### Required New Definitions

- `tropicalPathWeight`: sum of edge weights along a path.
- Path type: `Fin (k+1) → Fin n` (unconstrained sequence — all transitions allowed).
- Constrained path variant for sparse graphs.

### Anticipated Blockers

- The bijection between "first edge + tail path" and "full path" requires careful `Fin` arithmetic.
- `Finset.sup'` over function types `Fin (k+1) → Fin n` requires `Fintype` instance — this exists but may be slow for large k.
- The base case requires showing that the trivial path (length 0) gives exactly `x_i`.

### Enabling Lemmas

- `tropicalMatMap_comp` shows `T_A ∘ T_B = T_{A⊗B}`, which is the matrix version of path concatenation.
- `tropicalMatMap_monotone` ensures the sup over a larger path set is larger.

### Cross-Domain Impact

- **Certified dynamic programming**: the path expansion gives exact algorithmic semantics.
- **Weighted automata**: tropical iteration = accepting runs of a weighted automaton.
- **Complexity theory**: the number of distinct path values relates to tropical rank.

---

## Direction 3: Algebraic Generalization to Ordered Semirings

### Target Theorem

```lean
theorem tropicalMatMap_monotone_general
    {α : Type*} [LinearOrder α] [Add α] [CovariantClass α α (· + ·) (· ≤ ·)]
    {n : ℕ} [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) α)
    {x y : Fin n → α}
    (hxy : ∀ i, x i ≤ y i) :
    ∀ i, (Finset.univ.sup' Finset.univ_nonempty (fun j => A i j + x j)) ≤
         (Finset.univ.sup' Finset.univ_nonempty (fun j => A i j + y j))
```

### Strategy

1. **Identify minimal typeclasses**: The proof of `tropicalMatMap_monotone` uses only:
   - `add_le_add_left` (monotonicity of addition): `CovariantClass α α (· + ·) (· ≤ ·)`
   - `Finset.sup'_le` and `Finset.le_sup'`: require `SemilatticeSup α`
   - `LinearOrder` implies `SemilatticeSup`.

2. **Verify that `LinearOrder` + `CovariantClass` suffices** for all theorems.

3. **Port all 9 theorems** to the general setting.

### Required New Definitions

- Generic `tropicalMatMapGen` over `α`.
- Possibly a `TropicalSemiring` class bundling the right assumptions.

### Anticipated Blockers

- The `Finset.sup'_add` lemma (used in `tropicalMatMap_add_const`) requires `OrderedAddCommMonoid` or similar.
- The nonexpansiveness theorem uses `|a - b|` which requires a notion of absolute value — may need `LinearOrderedAddCommGroup`.
- Different typeclasses for different theorems: monotonicity needs less than nonexpansiveness.

### Enabling Lemmas

- All current proofs — the refactoring is a direct abstraction of the `ℝ`-specific proofs.

### Cross-Domain Impact

- **Valuation theory**: tropical algebra over non-archimedean fields.
- **Abstract interpretation**: lattice-based program analysis.
- **Fuzzy logic**: t-norm based reasoning with ordered semirings.

---

## Direction 4: Tropical Circuit Semantics and Boolean Encoding

### Target Theorem

```lean
/-- A monotone Boolean circuit, evaluated in the tropical encoding
    (true = 1, false = 0, AND = min, OR = max), is monotone as a
    tropical operator. -/
theorem tropical_circuit_monotone
    (C : MonotoneCircuit n m)
    (x y : Fin n → ℝ)
    (hxy : ∀ i, x i ≤ y i)
    (hx01 : ∀ i, x i ∈ ({0, 1} : Set ℝ))
    (hy01 : ∀ i, y i ∈ ({0, 1} : Set ℝ)) :
    ∀ j, evalTropicalCircuit C x j ≤ evalTropicalCircuit C y j
```

### Strategy

1. **Define `MonotoneCircuit`**: inductive type with AND (min) and OR (max) gates, no negation.
2. **Define `evalTropicalCircuit`**: recursive evaluation where AND = min, OR = max.
3. **Prove gate-level monotonicity**: `min` and `max` are both monotone in both arguments.
4. **Lift by structural induction** to the full circuit.
5. **Extend to quantitative bounds**: if inputs are in `[a, b]` instead of `{0, 1}`, bound the output range.

### Required New Definitions

- `MonotoneCircuit n m`: circuit with n inputs, m outputs, AND/OR gates.
- `evalTropicalCircuit`: evaluation function.
- `circuitDepth`: depth of the circuit.

### Anticipated Blockers

- Defining circuits with shared sub-expressions (DAGs vs trees) — trees are simpler but may not capture all circuits.
- The extension to quantitative bounds requires interpolation between the Boolean and tropical regimes.

### Enabling Lemmas

- `tropicalMatMap_monotone` handles the matrix case; circuits generalize this.
- The existing `bool_and_as_tropical_max` from the catalog provides gate-level correctness.
- `tropical_and_bound` provides quantitative bounds per gate.

### Cross-Domain Impact

- **Circuit complexity**: tropical degree of circuits relates to computational power.
- **Neural network verification**: ReLU networks are tropical circuits.
- **Quantitative logic**: truth values become real-valued confidence levels.

---

## Direction 5: Tropical Bellman Certification for Control Systems

### Target Theorem

```lean
/-- For a tropical Bellman operator with discount factor γ < 1,
    the value function V* is the unique fixed point, and certified
    iteration converges geometrically. -/
theorem tropical_bellman_convergence
    {n : ℕ} [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ)
    (γ : ℝ) (hγ : 0 < γ) (hγ1 : γ < 1)
    (x : Fin n → ℝ) :
    ∃ V : Fin n → ℝ,
      (∀ i, V i = Finset.univ.sup' Finset.univ_nonempty
        (fun j => A i j + γ * V j)) ∧
      ∀ k i, |Nat.iterate (fun v i => Finset.univ.sup' Finset.univ_nonempty
        (fun j => A i j + γ * v j)) k x i - V i| ≤
        γ ^ k * Finset.univ.sup' Finset.univ_nonempty (fun j => |x j - V j|)
```

### Strategy

1. **Define the discounted tropical operator**: `T_γ(x)_i = max_j(A_{ij} + γ·x_j)`.
2. **Prove contraction**: `T_γ` is a γ-contraction in `ℓ∞` norm (not just nonexpansive).
3. **Apply Banach fixed-point theorem** (available in Mathlib as `ContractingWith.fixedPoint`).
4. **Extract convergence rate** from the contraction constant.

### Required New Definitions

- `discountedTropicalMap`: `T_γ(x)_i = max_j(A_{ij} + γ·x_j)`.
- Integration with Mathlib's metric space and contraction mapping infrastructure.

### Anticipated Blockers

- The map `T_γ` is γ-contracting but acts on `Fin n → ℝ` with `ℓ∞` norm — need to show this is a complete metric space (it is, as a product of complete spaces).
- Connecting with Mathlib's `ContractingWith` may require some API work.

### Enabling Lemmas

- `tropicalMatMap_nonexpansive_coord` — the undiscounted version. The discounted version multiplies the bound by γ.
- `tropicalMatMap_monotone` — monotonicity is inherited by the discounted operator.

### Cross-Domain Impact

- **Reinforcement learning**: certified value function bounds for MDPs.
- **Robust control**: guaranteed performance under worst-case disturbances.
- **Game theory**: value of discounted stochastic games.

---

## Priority Ordering

1. **Direction 1** (eigenvector existence) — highest mathematical impact; creates tropical spectral theory.
2. **Direction 2** (path semantics) — most algorithmic value; enables certified DP.
3. **Direction 5** (Bellman certification) — most applied value; connects to RL/control.
4. **Direction 3** (algebraic generalization) — broadest scope; relatively straightforward refactoring.
5. **Direction 4** (circuit semantics) — most speculative; requires new definitions.

---

## Team Directive

Each direction is structured as an independent research track that can be pursued in parallel. The recommended approach:

1. **Validate hypotheses**: Use `#eval` and `lean_run_code` to test theorem statements computationally before formalizing.
2. **Build skeleton first**: Write all definitions and `sorry`'d lemmas, verify the skeleton compiles.
3. **Prove bottom-up**: Start with the simplest helper lemmas and work upward.
4. **Cross-pollinate**: Results from Direction 2 (path semantics) directly feed into Direction 1 (eigenvector construction). Direction 3 (generalization) should wait until Directions 1–2 are stable.

The formal infrastructure from the current cycle — `tropicalMatMap`, `tropicalMatMul`, and the 9 verified theorems — provides the foundation for all five directions.
