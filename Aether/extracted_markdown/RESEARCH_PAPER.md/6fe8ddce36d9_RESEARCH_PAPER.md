# Sheaf-Theoretic Tropical Persistence: Constructibility, Recovery, and Stability

## Abstract

We introduce a constructible sheaf framework for tropical persistence on finite graph filtrations. Given a finite simple graph *G* and a vertex filtration (entrance-time function), we define a tropical rank sheaf on the threshold parameter line whose stalks encode degree-weighted invariants of the active subgraph. We prove four main theorems: (1) **Constructibility** — the active vertex set is constant between consecutive entrance times, making the sheaf constructible with singular support equal to the entrance times; (2) **Recovery** — the tropical event profile equals the cumulative sum of sheaf jumps at critical values; (3) **Stability** — ε-close filtrations yield ε-interleaved sheaf profiles, so stability is a consequence of functoriality; (4) **Cross-domain bridge** — the Euler characteristic of the active subgraph is itself a constructible function of the threshold. All theorems are formally verified in Lean 4 with Mathlib, using only standard axioms. We provide algorithms, computational experiments on path and cycle graphs, and identify connections to microlocal analysis, Möbius inversion, and the six-functor formalism.

## 1. Introduction

### 1.1 Motivation

Topological data analysis (TDA) studies the persistent homology of filtered topological spaces, extracting "barcode" invariants that track the birth and death of topological features across a filtration parameter. The stability theorem of Cohen-Steiner, Edelsbrunner, and Harer [1] shows that persistence barcodes are Lipschitz-stable under perturbations of the input. This stability is proved by an ad hoc interleaving argument.

In tropical geometry, Baker and Norine [2] established a Riemann-Roch theorem for finite graphs, and subsequent work by Develin, Santos, and Sturmfels [3] developed tropical matrix rank theory. These tools provide algebraic invariants for graphs that parallel classical algebraic geometry in a combinatorial setting.

The present work bridges these two domains by showing that the tropical persistence data of a graph filtration — specifically, the degree-weighted event profile — is the decategorified trace of a **constructible sheaf** on the threshold parameter line. This identification:

- converts the event profile from a computed quantity into a *functorial invariant*,
- explains stability as a consequence of sheaf interleaving (functoriality) rather than a standalone estimate,
- opens connections to constructible sheaf theory, microlocal analysis, and derived categories.

### 1.2 Summary of contributions

1. **New structures:** `TropRankSheaf`, a constructible presheaf on ℝ with values in ℤ; `TropKernelData`, a type-valued sheaf with restriction maps satisfying functoriality.

2. **Theorem 1 (Constructibility):** The active vertex set `activeVerts f t` is constant on each interval between consecutive critical values.

3. **Theorem 2 (Recovery):** `tropEvtProfile G f t = sheafEvtProfile G f t` for all thresholds `t`.

4. **Theorem 3 (Stability):** For ε-close filtrations, `sheafEvtProfile G f t ≤ sheafEvtProfile G g (t + ε)`.

5. **Theorem 4 (Cross-domain):** The Euler characteristic `activeEulerChar G f t` is constructible.

6. **Computational verification** on path and cycle graphs.

### 1.3 Related work

- **Persistent homology:** Edelsbrunner, Letscher, Zomorodian [4]; Zomorodian, Carlsson [5].
- **Stability theorems:** Cohen-Steiner, Edelsbrunner, Harer [1]; Chazal et al. [6].
- **Persistent sheaves:** Curry [7]; Kashiwara, Schapira [8].
- **Tropical graph theory:** Baker, Norine [2]; Gathmann, Kerber [9].
- **Constructible sheaves:** Kashiwara, Schapira [10]; Schapira [11].

## 2. Definitions and Setup

### 2.1 Graph filtrations

Let *V* be a finite type with `[Fintype V]` and `[DecidableEq V]`. A **vertex filtration** is a function `f : V → ℝ` assigning an entrance time to each vertex. The **active vertex set** at threshold *t* is:

```
activeVerts f t := {v ∈ V | f(v) ≤ t}
```

### 2.2 Critical values

The **critical values** of a filtration are the image of *f*:

```
critVals f := {f(v) | v ∈ V}
```

This is a finite subset of ℝ, and the active vertex set can only change at these values.

### 2.3 Same critical gap

Two thresholds *s ≤ t* lie in the **same critical gap** if no critical value lies in the half-open interval (s, t]:

```
sameCritGap crit s t := s ≤ t ∧ ∀ c ∈ crit, ¬(s < c ∧ c ≤ t)
```

### 2.4 Tropical event profile

Given a simple graph `G` on *V* with decidable adjacency, the **tropical event profile** at threshold *t* is:

```
tropEvtProfile G f t := Σ_{v ∈ activeVerts f t} (deg_G(v) + 1)
```

### 2.5 Sheaf jump

The **sheaf jump** at a critical value *c* measures the degree-weighted contribution of vertices entering at exactly time *c*:

```
sheafJump G f c := Σ_{v : f(v) = c} (deg_G(v) + 1)
```

### 2.6 Sheaf event profile

The **sheaf event profile** is the cumulative sum of sheaf jumps:

```
sheafEvtProfile G f t := Σ_{c ∈ critVals(f), c ≤ t} sheafJump G f c
```

## 3. The Tropical Rank Sheaf

### 3.1 Definition

A **tropical rank sheaf** on *V* consists of:

```
structure TropRankSheaf (V) where
  graph : SimpleGraph V
  filt : V → ℝ
  rankAt : ℝ → ℤ
  critical : Finset ℝ
  mono : Monotone rankAt
  locConst : ∀ {s t}, sameCritGap critical s t → rankAt s = rankAt t
```

The fields encode: (1) monotonicity of the rank function (as the active set grows, the profile grows), and (2) local constancy away from the critical set (constructibility).

### 3.2 Construction

The function `mkTropRankSheaf G f` constructs a tropical rank sheaf from any graph and filtration, with `rankAt := tropEvtProfile G f` and `critical := critVals f`. The monotonicity proof uses `Finset.sum_le_sum_of_subset_of_nonneg` applied to the monotone growth of active vertex sets. The local constancy proof uses `activeVerts_eq_of_sameCritGap`.

### 3.3 Type-valued kernel sheaf

For finer structural analysis, we define the **tropical kernel data** at threshold *t* as the subtype `{v : V // f(v) ≤ t}`, with restriction maps `kernelRestriction f (hst : s ≤ t)` given by the canonical inclusion. These satisfy:

- **Identity:** `kernelRestriction f (le_refl t) = id`
- **Composition:** `kernelRestriction f (le_trans hrs hst) = kernelRestriction f hst ∘ kernelRestriction f hrs`

making `TropKernelData f` a covariant functor from `(ℝ, ≤)` to `Type`.

## 4. Main Results

### 4.1 Theorem 1: Constructibility

**Theorem** (`activeVerts_eq_of_sameCritGap`). *If `sameCritGap (critVals f) s t` holds, then `activeVerts f s = activeVerts f t`.*

*Proof sketch.* The forward direction (s ≤ t implies active at s → active at t) is immediate from monotonicity. For the reverse, suppose v is active at t but not at s. Then s < f(v) ≤ t, and f(v) ∈ critVals f (as the image of v), contradicting the gap condition. □

**Corollary** (`tropEvtProfile_const_between_critical`). *The tropical event profile is constant between consecutive critical values.*

**Corollary** (`tropKernelData_equiv_of_sameCritGap`). *Between critical values, the kernel data stalks are equivalent: `TropKernelData f s ≃ TropKernelData f t`.*

This equivalence is constructed via `Equiv.subtypeEquiv (Equiv.refl V)`, using the proof that the predicate `f(v) ≤ s ↔ f(v) ≤ t` holds in the gap.

### 4.2 Theorem 2: Recovery

**Theorem** (`tropEvtProfile_eq_cumSheafJump`). *For all t, `tropEvtProfile G f t = sheafEvtProfile G f t`.*

*Proof sketch.* We decompose the active vertex set as a disjoint union of fibers:

```
activeVerts f t = ⋃_{c ∈ critVals(f), c ≤ t} {v | f(v) = c}
```

This is proved in `activeVerts_eq_biUnion`. The fibers at distinct critical values are disjoint (`fibers_pairwiseDisjoint`). By `Finset.sum_biUnion`, the sum over the union equals the sum of sums over fibers, which is exactly the cumulative sheaf jump. □

**Corollary** (`sheafEvtProfile_eq_rankSheaf`). *The sheaf event profile equals the rank function of the constructed rank sheaf.*

This theorem is the central result. It identifies the persistence observable (a direct computation) with a constructible-sheaf invariant (a cumulative jump formula), establishing that the two viewpoints are provably equivalent.

### 4.3 Theorem 3: Stability

**Theorem** (`sheafEvtProfile_stability`). *If `∀ v, |f(v) - g(v)| ≤ ε`, then for all t, `sheafEvtProfile G f t ≤ sheafEvtProfile G g (t + ε)`.*

*Proof sketch.* By the recovery theorem, it suffices to prove the interleaving for `tropEvtProfile`. The key lemma is `activeVerts_subset_close`: if f(v) ≤ t and |f(v) - g(v)| ≤ ε, then g(v) ≤ t + ε. This gives `activeVerts f t ⊆ activeVerts g (t + ε)`. The result follows from `Finset.sum_le_sum_of_subset_of_nonneg` applied to the non-negative summand `deg(v) + 1`. □

**Theorem** (`sheafEvtProfile_stability_both`). *The interleaving holds symmetrically: both `P_f(t) ≤ P_g(t + ε)` and `P_g(t) ≤ P_f(t + ε)`.*

The conceptual significance is that stability is a *consequence of functoriality*: the sheaf construction `f ↦ mkTropRankSheaf G f` is "continuous" (Lipschitz with respect to the sup-norm on filtrations and the interleaving distance on sheaves). No ad hoc argument is needed.

### 4.4 Theorem 4: Cross-domain Bridge

**Theorem** (`activeEulerChar_const_between_critical`). *The Euler characteristic `χ(t) = |activeVerts f t| - |active edges at t|` is constant between consecutive critical values.*

*Proof.* Immediate from `activeVerts_eq_of_sameCritGap`, since the Euler characteristic depends only on the active vertex set (which determines the active edge set). □

This connects tropical persistence to combinatorial topology: the Euler characteristic forms its own constructible function on the threshold line, with the same singular support as the rank sheaf.

### 4.5 Additional results

- **Jump at critical value** (`tropEvtProfile_jump_at_critical`): If no critical value lies in (s, c) and every vertex has f(v) ≤ s or f(v) ≥ c, then the profile jump equals the sheaf jump: `P(c) - P(s) = sheafJump G f c`.

- **Total jump formula** (`total_sheafJump_eq_total_profile`): When all vertices are active, the total sheaf jump equals the total profile.

- **Zero below critical** (`tropEvtProfile_below_all_critical`): Below all entrance times, the profile is zero.

- **Path graph example** (`activeVerts_pathFilt_card`): For the standard filtration on P_{n+1}, the number of active vertices at threshold k is k+1.

## 5. Algorithms

### Algorithm 1: Sheaf Jump Computation

```
Input: Graph G = (V, E), filtration f : V → ℝ
Output: List of (critical_value, jump, cumulative) triples

1. Sort unique entrance times → crit = [c₁, ..., cₖ]
2. For each cᵢ:
   a. entering ← {v ∈ V : f(v) = cᵢ}
   b. jump ← Σ_{v ∈ entering} (deg(v) + 1)
   c. cumulative += jump
3. Return [(cᵢ, jumpᵢ, cumulativeᵢ)]
```

**Complexity:** O(n log n + n · average_degree) = O(n log n + |E|).

### Algorithm 2: Constructibility Verification

```
Input: Graph G, filtration f, sample count k
Output: True/False

1. crit ← sorted unique entrance times
2. For each interval (cᵢ, cᵢ₊₁):
   a. ref ← activeVerts(f, cᵢ)
   b. For k sample points t in (cᵢ, cᵢ₊₁):
      - If activeVerts(f, t) ≠ ref: return False
3. Return True
```

### Algorithm 3: Stability Verification

```
Input: Graph G, filtrations f₁, f₂
Output: (ε, interleaving_holds)

1. ε ← max_v |f₁(v) - f₂(v)|
2. crit ← union of critical values of f₁ and f₂
3. For each c ∈ crit:
   a. If P₁(c) > P₂(c + ε): return (ε, False)
   b. If P₂(c) > P₁(c + ε): return (ε, False)
4. Return (ε, True)
```

## 6. Computational Experiments

### 6.1 Path graph P₆

| Threshold | Entering | Degree | Jump | Cumulative | Euler χ |
|-----------|----------|--------|------|------------|---------|
| 0 | {0} | 1 | 2 | 2 | 1 |
| 1 | {1} | 2 | 3 | 5 | 1 |
| 2 | {2} | 2 | 3 | 8 | 1 |
| 3 | {3} | 2 | 3 | 11 | 1 |
| 4 | {4} | 2 | 3 | 14 | 1 |
| 5 | {5} | 1 | 2 | 16 | 1 |

**Observations:**
- Euler characteristic is constantly 1 (trees have χ = 1).
- Endpoint vertices have jump 2 (degree 1 + 1); interior vertices have jump 3 (degree 2 + 1).
- Recovery theorem verified: cumulative = direct profile at all thresholds.

### 6.2 Cycle graph C₆

| Threshold | Jump | Cumulative | Euler χ |
|-----------|------|------------|---------|
| 0 | 3 | 3 | 1 |
| 1 | 3 | 6 | 1 |
| 2 | 3 | 9 | 1 |
| 3 | 3 | 12 | 1 |
| 4 | 3 | 15 | 1 |
| 5 | 3 | 18 | 0 |

**Observations:**
- All vertices have degree 2, so every jump is 3.
- Euler characteristic drops from 1 to 0 when the closing edge completes the cycle at the last threshold.
- The total profile is 18 = 6 × 3 (uniform jumps).

### 6.3 Stability experiment

For P₅ with original filtration [0, 1, 2, 3, 4] and perturbed filtration [0.00, 1.25, 2.27, 3.04, 3.77]:
- Sup distance: ε = 0.273
- Forward interleaving verified: P₁(t) ≤ P₂(t + ε) for all t ✓
- Backward interleaving verified: P₂(t) ≤ P₁(t + ε) for all t ✓

## 7. Discussion

### 7.1 Conceptual significance

The identification of the tropical event profile with a constructible sheaf invariant is conceptually significant for several reasons:

1. **Functoriality explains stability.** The stability theorem is not an accident or a computational coincidence. It follows from the general principle that functorial constructions respect continuous (Lipschitz) maps. The sheaf construction `f ↦ mkTropRankSheaf G f` is a functor from filtrations (with sup-norm) to constructible sheaves (with interleaving distance).

2. **Singular support = entrance times.** The critical values of the filtration are precisely the singular support of the constructible sheaf. This connects tropical persistence to the microlocal theory of Kashiwara and Schapira, where the singular support of a sheaf encodes the "directions of non-propagation."

3. **Recovery = global-sections formula.** The cumulative jump formula is a discrete analogue of computing global sections of a pushforward sheaf. In the continuous setting, this would be an instance of the projection formula in derived categories.

### 7.2 Connections to other domains

**Microlocal analysis.** The singular support of the tropical rank sheaf (the set of entrance times) is a 1-dimensional analogue of the microsupport of a constructible sheaf on a manifold. The jump data at each critical value corresponds to the "microlocal stalk" of the sheaf at that singular point.

**Möbius inversion.** The cumulative jump formula `P(t) = Σ_{c ≤ t} J(c)` is an instance of summation over a poset (the critical values with their natural ordering). The inverse formula `J(c) = P(c) - P(c⁻)` is a Möbius inversion on the poset of critical strata.

**Incidence algebras.** The jump function `J` and profile function `P` are related by convolution with the zeta function of the critical poset. This connects tropical persistence to the theory of incidence algebras.

### 7.3 Limitations

The current framework treats only vertex filtrations on finite graphs with real-valued entrance times. Extensions to:
- edge filtrations,
- multiparameter filtrations,
- infinite graphs,
- and derived/higher-categorical settings

are natural next steps but require additional mathematical infrastructure.

## 8. Future Work

1. **Higher sheaf invariants.** Define analogues of higher cohomology for the tropical rank sheaf and study whether they detect finer network features.

2. **Multiparameter persistence.** Extend the constructible sheaf framework to filtrations indexed by ℝⁿ, using the theory of constructible sheaves on higher-dimensional parameter spaces.

3. **Derived tropical persistence.** Construct a derived category of tropical sheaves and study pushforwards, pullbacks, and Euler characteristics in this setting.

4. **Applications to data analysis.** Apply the sheaf framework to practical TDA problems, using the stability theorem to guarantee robustness and the constructibility to enable efficient computation.

## References

[1] D. Cohen-Steiner, H. Edelsbrunner, J. Harer, "Stability of Persistence Diagrams," *Discrete & Computational Geometry* 37 (2007), 103–120.

[2] M. Baker, S. Norine, "Riemann–Roch and Abel–Jacobi Theory on a Finite Graph," *Advances in Mathematics* 215 (2007), 766–788.

[3] M. Develin, F. Santos, B. Sturmfels, "On the Rank of a Tropical Matrix," *Combinatorial and Computational Geometry*, MSRI Publications 52 (2005), 213–242.

[4] H. Edelsbrunner, D. Letscher, A. Zomorodian, "Topological Persistence and Simplification," *Discrete & Computational Geometry* 28 (2002), 511–533.

[5] A. Zomorodian, G. Carlsson, "Computing Persistent Homology," *Discrete & Computational Geometry* 33 (2005), 249–274.

[6] F. Chazal, D. Cohen-Steiner, M. Glisse, L. Guibas, S. Oudot, "Proximity of Persistence Modules and Their Diagrams," *Proc. SoCG* (2009), 237–246.

[7] J. Curry, "Sheaves, Cosheaves and Applications," Ph.D. thesis, University of Pennsylvania, 2014.

[8] M. Kashiwara, P. Schapira, "Persistent Homology and Microlocal Sheaf Theory," *Journal of Applied and Computational Topology* 2 (2018), 83–113.

[9] A. Gathmann, M. Kerber, "A Riemann-Roch Theorem in Tropical Geometry," *Mathematische Zeitschrift* 259 (2008), 217–230.

[10] M. Kashiwara, P. Schapira, *Sheaves on Manifolds*, Springer, 1990.

[11] P. Schapira, "Tomography of Constructible Functions," *Applied Algebra, Algebraic Algorithms and Error-Correcting Codes* (1995), 427–435.

## Appendix: Formal Verification

All results in this paper are formalized in Lean 4 with Mathlib and verified to depend only on the standard axioms `propext`, `Classical.choice`, and `Quot.sound`. The formal development is contained in `Pythagorean/TropicalBridge/SheafPersistence.lean` (421 lines, 0 sorries). Key formal identifiers:

| Paper Theorem | Lean Identifier |
|---|---|
| Constructibility | `activeVerts_eq_of_sameCritGap` |
| Recovery | `tropEvtProfile_eq_cumSheafJump` |
| Stability | `sheafEvtProfile_stability` |
| Euler bridge | `activeEulerChar_const_between_critical` |
| Kernel data equiv | `tropKernelData_equiv_of_sameCritGap` |
| Jump formula | `tropEvtProfile_jump_at_critical` |
