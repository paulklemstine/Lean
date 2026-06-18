# Future Directions: Tropical Polyphonic Optimization

## 1. Time-Dependent Chorale Dynamic Programming

**Hypothesis**: When pairwise costs and spacing penalties decompose over time slices, the global four-voice optimization reduces to a chain-structured min-plus dynamic program over time, with state space `(State)^4` at each step.

**Concrete Theorem Target**:
```
theorem choraleCost_time_decomposes {n : ℕ} (C : Chorale n) :
    choraleCost C = ∑ t : Fin n, localTimeCost (fun i => C i t)
```

**Proof Strategy**: Define `localTimeCost` as the restriction of pairwise + unary costs to a single time slice. Show that the global sum telescopes into per-slice sums by exchanging the order of summation (voice-pair sum and time sum commute by Fubini for finite sums).

**Impact**: This enables Viterbi-style certified chorale generation — a polyphonic sequence model with proof certificates. The composition `tropMin_prod ∘ time_decomposition` gives an O(|State|^4 · n) exact DP algorithm with a formal correctness proof.

## 2. Tropical Factor Graphs with Exact Belief Propagation

**Hypothesis**: Tree-structured tropical factor graphs admit exact variable elimination, and the min-plus message-passing algorithm converges in one pass to the global optimum.

**Concrete Theorem Target**:
```
theorem tree_factor_graph_exact_elimination
    {G : FactorGraph} (hTree : IsTree G.structure)
    (hFinite : ∀ v, Fintype (G.stateSpace v)) :
    tropMin G.energy = message_passing_result G
```

**Proof Strategy**: Formalize factor graphs as hypergraphs with variable and factor nodes. Define the elimination order via a tree decomposition. Prove that each elimination step preserves the global minimum (using `tropMin_prod`). Induct on the number of variables.

**Cross-Domain Connection**: This is the tropical analogue of the junction-tree algorithm in probabilistic graphical models. The same framework would formalize Viterbi decoding for HMMs, LDPC decoding, and turbo decoding.

## 3. Zero-Temperature Statistical Mechanics Formalization

**Hypothesis**: The tropical minimum is the zero-temperature (β → ∞) limit of the log-partition function:
```
lim_{β→∞} (-1/β) · log(∑_x exp(-β · f(x))) = min_x f(x)
```

**Concrete Theorem Target**:
```
theorem logSumExp_tendsto_tropMin
    {α : Type*} [Fintype α] [Nonempty α] (f : α → ℝ) :
    Filter.Tendsto (fun β => (-1/β) * Real.log (∑ x, Real.exp (-β * f x)))
      Filter.atTop (nhds (tropMin f))
```

**Proof Strategy**: Factor out `exp(-β · min f)` from the sum. The remaining terms are `∑ exp(-β(f(x) - min f))`, which converges to the count of minimizers as β → ∞. The log of this divided by β vanishes. Use Mathlib's `Filter.Tendsto` and `Real.exp` API.

**Impact**: This formally connects tropical optimization to Gibbs sampling, simulated annealing, and the replica method. It would be the first formal proof that min-plus algebra is the zero-temperature limit of sum-product algebra.

## 4. Certified Polyphonic Generation Algorithms

**Hypothesis**: Given a formally verified cost functional and DP decomposition, one can extract a certified algorithm that produces provably optimal chorales.

**Concrete Theorem Target**:
```
theorem certified_chorale_optimal
    {n : ℕ} (C : Chorale n) (hC : C = dp_solve n) :
    ∀ C' : Chorale n, choraleCost C ≤ choraleCost C'
```

**Implementation Path**:
1. Define the DP table as a computable function (using `Fin` and decidable equality).
2. Prove that the DP solution achieves the minimum cost.
3. Extract executable code via Lean's `#eval` or `@[csimp]`.

**Impact**: This would produce the first formally verified music composition algorithm — a program that outputs a chorale with a machine-checked proof that no chorale of the same length has lower contrapuntal cost.

## 5. Extension to Arbitrary Finite Ensembles

**Hypothesis**: All four-voice theorems generalize to `k`-voice ensembles for arbitrary finite `k`, with the number of voice pairs growing as `k choose 2`.

**Concrete Theorem Target**:
```
theorem rigidity_k_voices {k n : ℕ} (C : Fin k → Melody n)
    (hpair_nonneg : ∀ i j, i < j → 0 ≤ pairCost (C i) (C j))
    (hspace_nonneg : ∀ i, 0 ≤ spacingPenalty i (C i))
    (hzero : ensembleCost C = 0) :
    (∀ i j, i < j → pairCost (C i) (C j) = 0) ∧
    (∀ i, spacingPenalty i (C i) = 0)
```

**Proof Strategy**: The proof of `pairwise_zero_of_choraleCost_eq_zero` generalizes directly — it uses only the nonneg-sum-vanishing lemma, which is parametric in the index set. Replace `Fin 4` with `Fin k` and `voicePairs` with `Finset.univ.filter (fun p => p.1 < p.2)` on `Fin k × Fin k`.

**Impact**: This lifts the theory from SATB chorales to arbitrary orchestral textures, choral works with divisi, and general multi-agent coordination problems.

## 6. NP-Hardness and Tractability Boundaries

**Hypothesis**: Unrestricted four-voice optimization with arbitrary pairwise potentials is NP-hard (by reduction from weighted MAX-2-CSP), but tree-structured decompositions and bounded-treewidth voice interaction graphs restore polynomial tractability.

**Concrete Theorem Targets**:
```
theorem chorale_opt_NP_hard :
    PolynomialTimeReducible WeightedMax2CSP ChoraleOptimization

theorem bounded_treewidth_tractable {w : ℕ} (hw : treewidth G ≤ w) :
    ∃ alg, PolynomialTime alg ∧ alg.solves (FactorGraphOpt G)
```

**Proof Strategy**: For hardness, encode binary CSP variables as voice-pair states. For tractability, use the tree-decomposition DP (Direction 2) and bound the state space at each bag by `|State|^w`.

**Impact**: This would formally characterize the computational complexity landscape of polyphonic optimization, identifying exactly which structural restrictions make certified generation feasible.

## 7. Min-Plus Tensor Network Contraction

**Hypothesis**: Grouping voices into blocks (e.g., (S,A) and (T,B)) and contracting the cross-block interaction defines a min-plus tensor network, and the contraction order affects computational complexity but not the result.

**Concrete Theorem Target**:
```
theorem contraction_order_invariance
    {G : TropicalTensorNetwork} (σ₁ σ₂ : ContractionOrder G) :
    contract G σ₁ = contract G σ₂
```

**Proof Strategy**: Define tropical tensor networks as weighted hypergraphs. Show that each contraction step is an application of `tropMin_prod`. Prove order-invariance by showing that all contraction orders compute the same global minimum.

**Impact**: This connects polyphonic optimization to the tensor network literature in quantum information and machine learning, potentially enabling formal verification of tensor network algorithms.

---

## Priority Ordering

1. **Direction 1** (time decomposition) — highest impact, enables practical algorithms
2. **Direction 5** (k-voice generalization) — straightforward extension of current work
3. **Direction 3** (zero-temperature limit) — deep theoretical connection
4. **Direction 4** (certified generation) — practical application
5. **Direction 2** (factor graphs) — general framework
6. **Direction 6** (complexity) — theoretical completeness
7. **Direction 7** (tensor networks) — visionary extension
