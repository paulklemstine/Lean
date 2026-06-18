# Future Directions: Tropical Kernel Dynamics

## Overview

This document outlines five concrete breakthrough research opportunities opened by the formal establishment of tropical kernel dynamics — the rigorous bridge between neural tangent kernel theory, tropical/polyhedral geometry, and variational dynamics. Each direction includes specific hypotheses, proof strategies, and cross-domain connections.

---

## Direction 1: Tropical RKHS Representation Theorem

### Hypothesis
The tropical NTK defines a **reproducing kernel in the min-plus sense**: there exists a tropical Hilbert module (a complete semimodule over the min-plus semiring) such that the tropical NTK is its reproducing kernel. Functions in this space are exactly the piecewise-affine predictors realizable by tropical networks.

### Proof Strategy
1. Define a **min-plus inner product** on the space of tropical parameter gradients: `⟨f, g⟩_trop = min_p (f(p) + g(p))`.
2. Show the tropical NTK satisfies the reproducing property: `f(x) = ⟨f, K_trop(x, ·)⟩_trop`.
3. Characterize the completion as the space of Lipschitz piecewise-affine functions with bounded tropical norm.
4. Prove a tropical representer theorem: optimal tropical predictors are finite min-plus combinations of kernel sections.

### Cross-Domain Impact
- Connects tropical geometry to functional analysis via idempotent analysis (Maslov dequantization)
- Opens tropical kernel PCA, tropical kernel ridge regression
- Provides a representation-theoretic foundation for tropical neural network expressiveness

### Formalization Target
```
theorem tropical_reproducing_property :
  ∀ f ∈ TropicalRKHS K, ∀ x, f x = tropicalInnerProduct f (K x)
```

---

## Direction 2: Wall-Crossing Invariants for Training Trajectories

### Hypothesis
The sequence of tropical cells visited by a training trajectory defines a **combinatorial invariant** — a path in the dual graph of the polyhedral cell complex. Two training runs that visit the same cell sequence produce the same sequence of kernel matrices, regardless of the specific parameter values. The **wall-crossing number** (how many cell boundaries are crossed) is a discrete measure of feature learning intensity.

### Proof Strategy
1. Formalize the **cell adjacency graph**: two cells are adjacent if they share a codimension-1 face.
2. Define the **cell word** of a trajectory: the sequence of cells visited (with multiplicities).
3. Prove that the cell word determines the sequence of kernel matrices (follows from cellwise constancy).
4. Show that gradient descent on a polyhedral loss produces a monotone path in a suitable partial order on cells.
5. Derive upper bounds on the wall-crossing number from loss decrease: each crossing costs at least a minimum gap.

### Cross-Domain Impact
- Connects to discrete Morse theory on polyhedral complexes
- Wall-crossing phenomena in algebraic geometry (Kontsevich–Soibelman) find a learning-theoretic analogue
- The cell word is a topological summary of training — robust to reparametrization

### Formalization Target
```
theorem cell_word_determines_kernel_sequence :
  ∀ traj₁ traj₂, cellWord traj₁ = cellWord traj₂ →
    kernelSequence traj₁ = kernelSequence traj₂
```

---

## Direction 3: Tropical Kernel Generalization Bounds

### Hypothesis
The **tropical Rademacher complexity** of a kernel class defined by a tropical NTK is bounded by a function of the number of tropical cells intersected by the data. This gives **combinatorial generalization bounds** that depend on polyhedral geometry rather than spectral properties.

### Proof Strategy
1. Show that the function class induced by a tropical NTK with fixed cell structure has VC dimension bounded by the number of cells.
2. Prove that the tropical NTK's block-diagonal structure (⟨x,y⟩+1 within cells, 0 across cells) concentrates the Rademacher complexity.
3. Derive a PAC-learning bound: generalization error ≤ O(√(C_eff / n)) where C_eff is the effective number of active cells.
4. Compare with classical NTK generalization bounds to show the tropical bound is tighter when the cell structure is coarse.

### Cross-Domain Impact
- First generalization bounds that explicitly use polyhedral geometry
- Connects combinatorial complexity (number of cells) to statistical complexity
- Suggests a tropical approach to neural network compression: prune cells, not weights

### Formalization Target
```
theorem tropical_rademacher_bound {n : ℕ} (samples : Fin n → X) :
  rademacherComplexity (tropicalKernelClass K) samples ≤
    C * Real.sqrt (numActiveCells K samples / n)
```

---

## Direction 4: Sheaf Cohomology Obstruction to Lazy Training

### Hypothesis
The tropical NTK defines a **constructible sheaf** on the polyhedral cell complex of parameter space. The sheaf assigns to each cell the constant kernel matrix on that cell, with restriction maps given by cell adjacency. **Lazy training corresponds to the sheaf having a global section** (a single kernel matrix valid everywhere along the trajectory). Feature learning corresponds to a non-trivial first cohomology class — the obstruction to gluing local kernel values into a global one.

### Proof Strategy
1. Define the **kernel sheaf** F on the cell complex: F(C) = the kernel matrix on cell C.
2. Show that F is a constructible sheaf (locally constant on each cell, finitely many cells).
3. Compute H⁰(F) = global sections = kernels consistent across all cells along the trajectory.
4. Show H⁰(F) ≠ 0 iff lazy training holds (the trajectory stays in a single cell or all adjacent cells have the same kernel).
5. Compute H¹(F) as the obstruction: non-zero H¹ means the kernel necessarily changes along the trajectory.
6. Connect to the existing `zero_cochain_constant_iff_kernel` theorem as the degree-0 case.

### Cross-Domain Impact
- First application of sheaf cohomology to neural network training dynamics
- Connects to persistent homology and topological data analysis
- Provides topological invariants of training that are robust to continuous deformations
- Opens connections to the geometric Langlands program via constructible sheaves

### Formalization Target
```
theorem lazy_training_iff_global_section :
  isLazyTraining traj ↔ ∃ K₀, ∀ C ∈ cellsAlongTrajectory traj, kernelSheaf C = K₀
```

---

## Direction 5: Zero-Temperature Phase Transition from Smooth NTK to Tropical NTK

### Hypothesis
The degeneration from smooth (log-sum-exp) NTK to tropical (min-plus) NTK exhibits a **phase transition** at a critical temperature τ_c. For τ > τ_c, the smooth NTK has full rank and training explores all directions. For τ < τ_c, the NTK becomes approximately block-diagonal (tropical), and training is confined to the active cell. The critical temperature is determined by the **gap** between the leading and subleading affine scores.

### Proof Strategy
1. Extend the softmin convergence theorem to matrix-valued kernels: show entrywise convergence of smooth NTK(τ) → tropical NTK as τ → 0⁺.
2. Characterize the convergence rate: show |K_smooth(τ) - K_trop| ≤ C · τ · log(m) where m is the number of affine pieces.
3. Identify τ_c as the temperature where the NTK rank drops: for τ < τ_c, the NTK has the same rank as the tropical NTK (number of active cells).
4. Prove a **free energy** characterization: the tropical regime minimizes a min-plus free energy, while the smooth regime minimizes a log-sum-exp free energy.
5. Connect to statistical mechanics: the partition function Z(τ) = ∑ exp(-E_i/τ) undergoes a phase transition as τ → 0.

### Cross-Domain Impact
- Connects neural network training to statistical mechanics phase transitions
- The critical temperature τ_c gives a principled criterion for when tropical approximations are valid
- Opens connections to quantum-classical transitions (tropical = classical limit)
- Suggests a temperature annealing schedule for training: start smooth, gradually tropicalize

### Formalization Target
```
theorem smooth_ntk_convergence_rate {N : ℕ}
  (K_smooth : ℝ → Matrix (Fin N) (Fin N) ℝ) (K_trop : Matrix (Fin N) (Fin N) ℝ) :
  ∀ τ > 0, ‖K_smooth τ - K_trop‖ ≤ C * τ * Real.log m
```

---

## Recommended Prioritization

1. **Direction 5** (Zero-temperature phase transition) — Most immediately actionable, builds directly on the softmin convergence theorem already proved. The matrix-valued extension is a natural next step.

2. **Direction 2** (Wall-crossing invariants) — High impact, moderate difficulty. The cell word construction is concrete and the kernel sequence theorem follows from existing cellwise constancy results.

3. **Direction 3** (Generalization bounds) — High practical impact. The block-diagonal structure of the tropical NTK is already established and directly constrains the function class complexity.

4. **Direction 1** (Tropical RKHS) — Deep theoretical contribution but requires substantial new algebraic infrastructure (min-plus modules, idempotent analysis).

5. **Direction 4** (Sheaf cohomology) — Most ambitious and visionary. Requires formalization of sheaves on polyhedral complexes, which is heavy infrastructure but would open an entirely new research program.

---

## Cross-Cutting Themes

All five directions share common infrastructure needs:
- **Polyhedral cell complex formalization**: adjacency, incidence, dual graph
- **Constructibility**: functions/sheaves that are constant on cells
- **Min-plus linear algebra**: tropical eigenvalues, tropical rank
- **Temperature degeneration**: uniform convergence of smooth to tropical objects

Building this shared infrastructure first would enable all five directions simultaneously.
