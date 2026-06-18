# Future Directions: Certified Bottleneck Upgrade Theory

This document outlines specific, actionable research directions opened by the formalization of the Bottleneck Upgrade Theorems. Each direction includes concrete hypotheses, proof strategies, and cross-domain connections.

---

## 1. Graph Min-Cut Upgrade Theorem

**Hypothesis:** For a finite directed graph with integer edge capacities, upgrading every edge of a certified minimum cut by one unit raises the max-flow lower bound by exactly one.

**Proof Strategy:**
- Formalize simple directed graphs as `α → α → ℕ` capacity functions over a `Fintype α`.
- Define s-t cuts as sets of edges separating source from sink.
- State the max-flow/min-cut theorem (or assume it as an axiom initially).
- Apply `bottleneck_upgrade_strict_improvement` to the edge set of a minimum cut, viewing max-flow as the infimum over all cuts of the cut capacity.

**Key Definitions Needed:**
```
structure DirectedGraph (V : Type*) where
  cap : V → V → ℕ

def cutCapacity (G : DirectedGraph V) (S : Finset V) : ℕ := ...
def minCut (G : DirectedGraph V) (s t : V) : ℕ := ...
```

**Cross-Domain Bridge:** This connects combinatorial optimization (max-flow/min-cut duality) to the abstract capacity framework, enabling certified network design interventions.

---

## 2. Tropical Production Network Generalization

**Hypothesis:** For assembly networks combining serial (min) and parallel (+) stages in min-plus algebra, targeted upgrades on the tropical critical path yield provable throughput gains.

**Proof Strategy:**
- Define min-plus semiring operations on `ℕ∞` (or `WithTop ℕ`).
- Model production networks as min-plus polynomials: `throughput = ⊓ᵢ (⊔ⱼ cᵢⱼ)` where ⊓ is min and ⊔ is addition.
- Identify the critical set as the "tropical variety" — the support where minima are attained.
- Generalize `bottleneck_raiseOn_one_step` to min-plus expressions.

**Key Insight:** Serial throughput (our current theorem) is the degree-one case. Assembly networks with convergent stages require min-plus polynomials of higher degree.

**Lean Target:**
```
def TropicalNetwork (α : Type*) := α → WithTop ℕ
def tropicalThroughput (stages : List (TropicalNetwork α)) : WithTop ℕ := ...
theorem tropical_upgrade_improvement : ...
```

---

## 3. Closure-Capacity Transfer Principle

**Hypothesis:** The bottleneck set of a finite min-capacity system corresponds to the fixed-point support of an associated closure operator, and capacity-improving moves correspond to raising the minimal fixed-point value.

**Proof Strategy:**
- Define a closure operator on `Finset α` by `cl(S) = {x ∈ s | c x ≤ s.inf' hs c + k}` for parameter k.
- Show that `bottleneckSet` is `cl(∅)` for k = 0.
- Prove that after a raiseOn upgrade, the new closure contracts: `cl_new(∅) ⊂ cl_old(∅)` when the upgrade is exactly on the bottleneck.
- Connect to `certified_reconstruction_from_closure_capacity` by showing capacity reconstruction from closure data.

**Long-Term Vision:** A categorical framework where capacity is a natural transformation between capacity functors, and upgrades are morphisms in the category of capacity-valued closure systems.

---

## 4. Budget-Constrained Optimal Intervention (Multi-Round)

**Hypothesis:** Given a total upgrade budget of `B` units and a system of `n` components, the greedy strategy of repeatedly upgrading all current bottleneck elements is optimal for maximizing minimum throughput after `B` rounds.

**Proof Strategy:**
- Define an iterated upgrade process: `iterate_upgrade s c k` applies `raiseOn (bottleneckSet ...)` for `k` rounds.
- Prove monotonicity: each round strictly increases the minimum (under gap conditions).
- Prove termination: after at most `max(c) - min(c)` rounds, all capacities are equal.
- Prove optimality by exchange argument: any deviation from bottleneck-first ordering can be matched or beaten.

**Lean Target:**
```
def iterateUpgrade (s : Finset α) (c : α → ℕ) (hs : s.Nonempty) : ℕ → (α → ℕ)
  | 0 => c
  | k + 1 => raiseOn (bottleneckSet s (iterateUpgrade s c hs k) hs) 1 (iterateUpgrade s c hs k)

theorem greedy_upgrade_terminates :
  ∀ T, ∃ k ≤ T - s.inf' hs c, ∀ x ∈ s, iterateUpgrade s c hs k x ≥ T

theorem greedy_upgrade_optimal :
  -- Among all k-unit upgrade strategies, greedy bottleneck-first maximizes min throughput
```

**Complexity:** The greedy algorithm runs in O(n · (max - min)) iterations, each requiring O(n) to compute the bottleneck set.

---

## 5. Latency Dual Theorem over ℚ

**Hypothesis:** If capacity `c(x)` represents throughput rate and latency is `1/c(x)`, then upgrading the bottleneck by one unit yields a certified worst-case latency reduction of `1/(m(m+1))` where `m` is the old minimum capacity.

**Proof Strategy:**
- Work over `ℚ` or `ℝ` with positive capacity constraints.
- Define latency as `sup' (fun x => 1 / c x)` (dual of inf' for capacity).
- Use the capacity improvement theorem: new min capacity = m + 1.
- Compute: old max latency = 1/m, new max latency = 1/(m+1), improvement = 1/(m(m+1)).

**Lean Target:**
```
theorem latency_improvement_from_bottleneck_upgrade
    (s : Finset α) (c : α → ℚ) (hs : s.Nonempty)
    (hpos : ∀ x ∈ s, 0 < c x)
    (hgap : ...) :
    s.sup' hs (fun x => 1 / c x) - s.sup' hs (fun x => 1 / c' x) =
      1 / (m * (m + 1))
```

**Application:** Quality-of-Service (QoS) certification in telecommunications — proving that specific link upgrades guarantee measurable latency improvements.

---

## 6. Distributed Bottleneck Detection via Nerve Complexes

**Hypothesis:** In distributed systems where bottleneck detection requires coordination across overlapping monitoring regions, the relevant critical set is encoded by the nerve of a covering, and upgrades must respect the nerve structure.

**Proof Strategy:**
- Model monitoring regions as a family of `Finset`s covering `s`.
- Define the nerve complex: simplices correspond to non-empty intersections.
- Show that the bottleneck set decomposes along the nerve.
- Prove that distributed upgrades (each region upgrades its local bottleneck) achieve global optimality when the nerve is acyclic.

**Connection to Catalog:** `certified_generalization_with_nerve_depth` provides depth bounds for nerve complexes. The bottleneck depth (number of nerve simplices containing a bottleneck element) bounds the communication rounds needed for distributed upgrade coordination.

---

## 7. Parametric Capacity Sensitivity Analysis

**Hypothesis:** The system throughput `s.inf' hs c` is a piecewise-linear function of a perturbation parameter `ε`, with breakpoints at values where the bottleneck set changes.

**Proof Strategy:**
- Define parameterized capacity: `c_ε(x) = c(x) + ε * d(x)` for direction `d`.
- Show that for small ε, the bottleneck set is stable.
- Prove that throughput is linear in ε within each stability interval.
- Characterize breakpoints: ε values where `bottleneckSet` gains or loses elements.

**Application:** Sensitivity analysis for infrastructure planning — understanding how robust a bottleneck upgrade is to uncertainty in capacity measurements.

---

## 8. Certified Intervention Sequencing for Multi-Objective Systems

**Hypothesis:** When multiple objectives (throughput, reliability, cost) each define their own bottleneck set, the Pareto-optimal intervention strategy can be characterized by the intersection structure of these bottleneck sets.

**Proof Strategy:**
- Define multi-objective capacity: `c : α → ℕ × ℕ × ℕ` (throughput, reliability, cost).
- Each objective has its own bottleneck set.
- Prove: if bottleneck sets have non-empty intersection, upgrading the intersection improves all objectives simultaneously.
- Characterize Pareto frontiers when bottleneck sets are disjoint.

**Application:** Infrastructure planning under competing objectives — e.g., a rail system that must simultaneously maximize throughput, minimize failure rate, and stay within budget.

---

## Summary Table

| Direction | Difficulty | Dependencies | Impact |
|-----------|-----------|-------------|--------|
| Graph min-cut | Medium | Max-flow formalization | High |
| Tropical networks | Hard | Min-plus algebra | Very High |
| Closure transfer | Hard | Closure operator theory | Theoretical |
| Multi-round budget | Medium | Current theorems | High |
| Latency dual | Easy-Medium | ℚ arithmetic | High |
| Nerve complexes | Hard | Simplicial complexes | Theoretical |
| Sensitivity analysis | Medium | Parameterized families | Medium |
| Multi-objective | Hard | Pareto theory | Very High |

Each direction is designed to be independently pursuable while contributing to the larger vision of a **universal certified capacity engineering framework**.
