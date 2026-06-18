# Future Directions: The Tropical (Min-Plus) Eigenvalue and the Critical Graph

## Synthesis

This cycle formalized the **tropical eigenvalue** of a real square matrix as the normalized
optimal-assignment value

  λ*(A) = (1/n) · min_{σ ∈ S_n} ∑_i A(i, σ(i)),

and proved seven structural laws in `Catalog/Tropical/Applications/TropicalEigenvalue.lean`
(`tropEig_add_const`, `tropEig_transpose`, `tropEig_conj`, `tropEig_mono`, `tropEig_le_trace`,
`tropEig_smul_nonneg`, `tropEig_min_entry_le`). Together they establish that λ* is a
translation-equivariant, transpose- and conjugation-invariant, monotone, positively
homogeneous functional pinched between the matrix minimum and the normalized trace —
precisely the behaviour expected of a min-plus spectral radius.

The work deliberately *bridges* the existing catalog file
`Catalog/Tropical/Applications/TropicalEquivalenceInvariance.lean`. That file proved that
additive (tropical) shifts of a **vector** preserve all rankings
(`tropical_shift_preserves_pairwise_order`, `tropequiv_preserves_argmin_set`). The new
translation law `tropEig_add_const` is the **matrix-level shadow** of the same min-plus
ℝ-action: the same additive group governs both ranking invariance of data vectors and the
eigenvalue of weighted assignment problems. The adversarial stance paid off: each
quantitative law came with an explicitly identified failure boundary (n = 0 for the
translation/trace/floor laws; c < 0 for homogeneity), documented in the Lab Notebook.

## Results Summary

| Theorem | Statement | Boundary stress-tested |
|---|---|---|
| `tropEig_add_const` | λ*(A + c) = λ*(A) + c | fails at n = 0 |
| `tropEig_transpose` | λ*(Aᵀ) = λ*(A) | holds for all n (σ ↦ σ⁻¹) |
| `tropEig_conj` | λ*(P A P⁻¹ relabel) = λ*(A) | needs *common* row/col perm |
| `tropEig_mono` | A ≤ B ⇒ λ*(A) ≤ λ*(B) | holds for all n |
| `tropEig_le_trace` | λ*(A) ≤ trace(A)/n | identity assignment witness |
| `tropEig_smul_nonneg` | λ*(c·A) = c·λ*(A) | fails for c < 0 (min↔max flip) |
| `tropEig_min_entry_le` | (∀ i j, m ≤ A i j) ⇒ m ≤ λ*(A) | floor of the sandwich |

All proofs depend only on `propext`, `Classical.choice`, `Quot.sound`; no `sorry`.

## Research Directions

### 1. The negative-scalar reflection: λ*(c·A) = c · λ_max(A) for c < 0
The homogeneity law `tropEig_smul_nonneg` was stress-tested and *fails* for negative scalars,
because multiplying by c < 0 turns the assignment minimum into a maximum. Define the dual
**max-plus eigenvalue** μ*(A) = (1/n) · max_σ ∑_i A(i, σ(i)) and conjecture
λ*(c·A) = c · μ*(A) for c ≤ 0, with the symmetric μ*(c·A) = c · λ*(A). **The key insight is**
that the single additive ℝ-action splits into two order-dual semiring actions at the sign
boundary, so λ* and μ* are not independent invariants but a Legendre-style conjugate pair.
**Why now?** The min↔max flip is already pinned down as the exact failure mode in this cycle's
Lab Notebook, so the dual functional and its scaling law are the immediate, falsifiable next
step — a counterexample would just be a 2×2 matrix with a negative scalar.

### 2. A tropical sandwich/spectral-gap inequality: μ*(A) − λ*(A) ≤ max diff of entries
With both λ* (proved here) and the dual μ* in hand, conjecture the tight envelope
μ*(A) − λ*(A) ≤ max_{i,j,k,l} (A(i,j) − A(k,l)), with equality characterized by matrices whose
optimal and pessimal assignments are entry-disjoint. **The key insight is** that the
assignment-cost spread is controlled coordinatewise, so the spectral gap of the tropical
operator is a purely combinatorial diameter of the entry set, independent of n. **Why now?**
This cycle already proved the two halves of the sandwich (`tropEig_le_trace` above,
`tropEig_min_entry_le` below); the gap theorem is the natural quantitative closure and is
directly falsifiable by random-matrix search.

### 3. Subadditivity / Fekete regime for tropical matrix powers
In the min-plus semiring, matrix "powers" A^{⊗k} use (⊕,⊗) = (min,+). Conjecture that the
normalized minimal diagonal of A^{⊗k} converges, and its limit equals the **minimum cycle
mean** of A, recovering the classical Cuninghame-Green eigenvalue; moreover λ*(A) (the
assignment version proved here) upper-bounds that limit. **The key insight is** that the
assignment minimum factors through cycle decompositions of permutations, so each σ's
normalized cost is an average of its cycle means, making the cycle-mean minimum the true
asymptotic invariant and λ* its one-step relaxation. **Why now?** We have a fully formal,
axiom-clean `tropEig` and the permutation/cycle machinery of `Equiv.Perm (Fin n)` in Mathlib;
the cycle-mean comparison is the canonical theorem that turns this definition into the
textbook tropical eigenvalue.

### 4. Critical-graph stability under perturbation (a matrix `approximate_*` law)
`TropicalEquivalenceInvariance.lean` proved a gap-robustness theorem for vectors
(`approximate_tropical_shift_preserves_order`). Conjecture the matrix analogue: if the optimal
assignment of A beats every other assignment by margin > 2ε, then any entrywise ε-perturbation
B has the *same* optimal permutation (the critical graph is locally constant). **The key
insight is** that the optimal assignment is the argmin of a finite family of affine functions
of the entries, so a uniform value gap is exactly a stability radius for the minimizer —
lifting vector ranking-robustness to matrix critical-graph robustness. **Why now?** The vector
prototype is already in the catalog and `tropEig_mono` gives the entrywise control needed; the
margin/perturbation bookkeeping is a direct transcription of the proved 2ε argument.

### 5. Doubly-stochastic / Birkhoff relaxation equals the permutation minimum
The assignment minimum over permutations is conjecturally equal to the minimum of
∑_{i,j} A(i,j)·X(i,j) over doubly stochastic X (Birkhoff polytope), since the LP attains its
optimum at a vertex = permutation matrix. **The key insight is** that λ* — defined here
combinatorially over the discrete set S_n — coincides with a *continuous convex* optimum,
giving λ* a variational (and hence differentiable, duality-equipped) characterization.
**Why now?** Mathlib has growing convexity and extreme-point infrastructure, and the discrete
side is now fully formalized; proving the vertex-attainment bridge would connect this cycle's
tropical/combinatorial invariant to the catalog's convex-analysis domain, a genuine
cross-domain bridge theorem.
