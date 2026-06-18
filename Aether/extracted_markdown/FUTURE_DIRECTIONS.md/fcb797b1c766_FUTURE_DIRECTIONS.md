# Future Directions: Tropical Functorial Surgery Calculus

## Overview

The tropical functorial surgery calculus establishes that composition of cost-kernel surgeries is exactly min-plus matrix multiplication. This opens several breakthrough research directions connecting tropical algebra, category theory, dynamic programming, and mathematical physics.

---

## Direction 1: Tropical Identity and Categorical Completion

### Goal
Extend the surgery calculus from a semicategory (no identities) to a full category by working over `WithTop ℝ` or `EReal` instead of `ℝ`, enabling identity surgeries with cost 0 on the diagonal and +∞ off-diagonal.

### Precise Theorem Statement
```
def Surgery.id (n : ℕ) : Surgery (Fin n) (Fin n) where
  cost i j := if i = j then (0 : EReal) else ⊤

theorem updateMatrix_id (n : ℕ) :
    updateMatrix (Surgery.id n) = minPlusId n

theorem Surgery.comp_id_left (S : Surgery (Fin m) (Fin n)) :
    Surgery.comp (Surgery.id m) S = S

theorem Surgery.comp_id_right (S : Surgery (Fin m) (Fin n)) :
    Surgery.comp S (Surgery.id n) = S

def TropicalUpdateFunctor : SurgeryCat ⥤ MinPlusMatCat
```

### Proof Strategy
1. Redefine all structures over `EReal` or `WithTop ℝ`.
2. Show that `⊤ + x = ⊤` and `0 + x = x` in the extended semiring.
3. Prove identity laws by showing `min(⊤, 0 + cost(i,j)) = cost(i,j)` for diagonal entries and `min(⊤, ⊤ + cost(i,j)) = ⊤` otherwise.
4. Package as a Lean 4 `CategoryTheory.Functor`.

### Cross-Domain Significance
- **Category theory:** Establishes the first formal tropical enriched category in machine-verified mathematics.
- **TQFT:** Identity surgeries correspond to the "do nothing" cobordism, completing the analogy with topological field theory.
- **Programming semantics:** Identity is the trivial propagator, essential for program composition.

### Estimated Difficulty
Medium. Main challenge is handling `EReal` arithmetic in Lean/Mathlib, which has less developed API than `ℝ`.

---

## Direction 2: Tropical Spectral Theory and Critical Circuits

### Goal
Formalize the tropical eigenvalue (minimum cycle mean) and prove that iterated surgery composition converges to a tropical eigenvector, establishing the spectral theorem for tropical matrices.

### Precise Theorem Statement
```
def tropicalEigenvalue (W : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  -- minimum cycle mean: min over all circuits of (total weight / length)

theorem tropical_spectral_theorem (W : Matrix (Fin n) (Fin n) ℝ) :
    ∃ (λ : ℝ) (v : Fin n → ℝ), ∀ i,
      minPlusMul W (Matrix.col v) i = λ + v i

theorem surgery_iteration_convergence (S : Surgery (Fin n) (Fin n)) :
    ∃ (λ : ℝ), ∀ (v : Fin n → ℝ),
      -- iterate S k times and normalize → converges to eigenvector
      Filter.Tendsto (fun k => tropicalNormalize (iterateApply S k v))
        Filter.atTop (nhds (tropicalEigenvector S))
```

### Proof Strategy
1. Implement Karp's algorithm for tropical eigenvalue computation.
2. Prove the min-plus version of Perron-Frobenius: irreducible tropical matrices have a unique eigenvalue.
3. Use the critical graph characterization: the eigenvalue is achieved on the critical circuit.

### Cross-Domain Significance
- **Scheduling theory:** The tropical eigenvalue gives maximum throughput of a cyclic production system.
- **Network analysis:** Determines bottleneck cycle in a network.
- **Dynamical systems:** Tropical eigenvectors are fixed points of Bellman operators.

### Estimated Difficulty
High. Requires formalizing graph-theoretic concepts (circuits, critical graphs) and convergence arguments.

---

## Direction 3: Weighted Automata Equivalence

### Goal
Prove that finite-state surgeries are equivalent to weighted finite automata (WFA) under tropical semantics, establishing a formal language interpretation of the surgery calculus.

### Precise Theorem Statement
```
structure WeightedAutomaton (Σ : Type*) (n : ℕ) where
  transition : Σ → Matrix (Fin n) (Fin n) ℝ
  initial : Fin n → ℝ
  final : Fin n → ℝ

def WFA.recognize (A : WeightedAutomaton Σ n) (w : List Σ) : ℝ :=
  -- min-plus composition of transition matrices along word w

theorem surgery_pipeline_eq_wfa
    (pipeline : List (Surgery (Fin n) (Fin n))) :
    ∃ (A : WeightedAutomaton (Fin (pipeline.length)) n),
      ∀ start finish,
        composePipeline pipeline start finish = A.recognize [0, 1, ..., k-1]

theorem wfa_composition_tropical
    (A₁ : WeightedAutomaton Σ n₁) (A₂ : WeightedAutomaton Σ n₂) :
    ∀ w, (tensorProduct A₁ A₂).recognize w =
      A₁.recognize w + A₂.recognize w
```

### Proof Strategy
1. Define weighted automata as sequences of surgery matrices indexed by alphabet symbols.
2. Show that word recognition is iterated surgery composition.
3. Prove the Schützenberger-style equivalence between WFA expressions and tropical rational series.

### Cross-Domain Significance
- **Formal languages:** Connects surgery calculus to the theory of recognizable power series.
- **Speech/NLP:** Viterbi decoding is surgery composition; this makes the connection formal.
- **Program verification:** Weighted program semantics as tropical functors.

### Estimated Difficulty
Medium-High. Requires formalizing basic automata theory in the tropical setting.

---

## Direction 4: Stability and Perturbation Bounds

### Goal
Prove tight quantitative bounds on how perturbing surgery costs affects the composed cost matrix, establishing a Lipschitz property for the tropical functor.

### Precise Theorem Statement
```
theorem minPlusMul_perturbation_bound
    {A A' : Matrix (Fin m) (Fin n) ℝ}
    {B B' : Matrix (Fin n) (Fin p) ℝ}
    (hA : ∀ i j, |A i j - A' i j| ≤ ε)
    (hB : ∀ j k, |B j k - B' j k| ≤ δ) :
    ∀ i k, |minPlusMul A B i k - minPlusMul A' B' i k| ≤ ε + δ

theorem pipeline_perturbation_bound
    (surgeries : Fin k → Surgery (Fin n) (Fin n))
    (perturbations : Fin k → ℝ)
    (h : ∀ t i j, |surgeries t .cost i j - surgeries' t .cost i j| ≤ perturbations t) :
    ∀ i j, |composePipeline surgeries i j - composePipeline surgeries' i j| ≤
      ∑ t, perturbations t
```

### Proof Strategy
1. Start from the monotonicity theorem (already proved).
2. Upgrade to two-sided bounds using |min f - min g| ≤ max |f - g|.
3. Compose perturbation bounds through the pipeline by induction on pipeline length.

### Cross-Domain Significance
- **Robust optimization:** Guarantees that approximate cost data yields approximately optimal solutions.
- **Sensitivity analysis:** Quantifies which surgery in a pipeline has the greatest impact on total cost.
- **Machine learning:** Error bounds for tropical neural network computations.

### Estimated Difficulty
Medium. The base case (monotonicity) is already proved; the perturbation upgrade requires absolute-value arguments.

---

## Direction 5: Tropical TQFT and Cobordism Gluing

### Goal
Formalize a gluing law for surgery-generated cobordism-like objects, proving that gluing two cobordisms along a shared boundary corresponds to min-plus multiplication of their associated operators. This would be the first formal tropical topological quantum field theory.

### Precise Theorem Statement
```
structure Cobordism where
  incoming : ℕ  -- number of incoming boundary components
  outgoing : ℕ  -- number of outgoing boundary components
  surgery : Surgery (Fin incoming) (Fin outgoing)

def Cobordism.glue (C₁ : Cobordism) (C₂ : Cobordism)
    (h : C₁.outgoing = C₂.incoming) : Cobordism where
  incoming := C₁.incoming
  outgoing := C₂.outgoing
  surgery := Surgery.comp C₁.surgery (h ▸ C₂.surgery)

theorem tqft_gluing_law (C₁ C₂ : Cobordism) (h : C₁.outgoing = C₂.incoming) :
    updateMatrix (Cobordism.glue C₁ C₂ h).surgery =
    minPlusMul (updateMatrix C₁.surgery) (h ▸ updateMatrix C₂.surgery)

-- Symmetric monoidal structure (disjoint union of boundaries)
def Cobordism.tensor (C₁ C₂ : Cobordism) : Cobordism where
  incoming := C₁.incoming + C₂.incoming
  outgoing := C₁.outgoing + C₂.outgoing
  surgery := blockDiag C₁.surgery C₂.surgery
```

### Proof Strategy
1. Define cobordisms as surgeries with labeled incoming/outgoing boundaries.
2. Gluing is surgery composition (already proved to be tropical multiplication).
3. Tensor product is block-diagonal surgery (new definition needed).
4. Prove the coherence axioms of a symmetric monoidal functor.

### Cross-Domain Significance
- **Topology:** First machine-verified tropical TQFT, opening connections to Floer theory and symplectic topology.
- **Physics:** Ground-state sector of topological field theories via tropical limit.
- **Mathematics:** Connects Mikhalkin's tropical geometry with functorial field theory.

### Estimated Difficulty
High. Requires careful handling of type-level dimension arithmetic and monoidal category axioms.

---

## Research Team Directive

Each direction should be pursued by a team that:
1. **States hypotheses precisely** as Lean type signatures before attempting proofs.
2. **Validates computationally** using the Python demo infrastructure (algorithms.py, applications.py).
3. **Decomposes aggressively** — each theorem should be broken into 3-8 helper lemmas.
4. **Cross-references** with existing Mathlib infrastructure (tropical semiring, category theory, matrix algebra).
5. **Documents connections** to at least two application domains per theorem.

The iteration cycle is: hypothesize → formalize statement → test computationally → decompose → prove → verify → document → iterate.

---

## Priority Ranking

1. **Direction 4** (Stability bounds) — nearest to completion, builds directly on proved monotonicity.
2. **Direction 1** (Categorical completion) — most architecturally important, unlocks all other directions.
3. **Direction 3** (Weighted automata) — highest application impact.
4. **Direction 2** (Spectral theory) — mathematically deepest.
5. **Direction 5** (Tropical TQFT) — most visionary, longest timeline.
