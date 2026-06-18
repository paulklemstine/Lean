# Summary of changes
## Why Do Random Matrix Eigenvalues Repel Like Charged Particles?

### The Answer

**Eigenvalue repulsion is not an analogy — it is a mathematical identity.** When you diagonalize a random matrix M = UΛU*, the Jacobian of this change of variables is the **Vandermonde determinant** ∏_{i<j} |λⱼ - λᵢ|^β. This is precisely the Boltzmann weight exp(-β·E) of a 2D Coulomb gas:

- Each eigenvalue = a unit charge on the real line  
- The interaction = 2D logarithmic Coulomb repulsion: -log|λⱼ - λᵢ|  
- The confining potential = quadratic (from the Gaussian weight)  
- β = 1 (GOE), 2 (GUE), 4 (GSE) = inverse temperature = repulsion strength

The Vandermonde determinant vanishes when any two eigenvalues coincide, making such configurations have **zero probability**. Near coincidence, the density vanishes as |Δλ|^β — a power-law "hole" enforced by pure geometry.

### Formal Verification

I created `Probability/EigenvalueRepulsion.lean` with **8 machine-verified theorems** (0 sorries, only standard axioms) formalizing the algebraic core:

1. **`vandermonde_det_eq_prod_diff`** — The Vandermonde determinant = ∏_{i<j} (λⱼ - λᵢ)
2. **`vandermonde_det_zero_iff`** — det = 0 ⟺ two eigenvalues coincide (eigenvalue repulsion!)
3. **`vandermonde_det_sq`** — |det|² = ∏_{i<j} (λⱼ - λᵢ)² (GUE Boltzmann weight)
4. **`vandermonde_det_pos_of_strictMono`** — Positive for strictly ordered eigenvalues
5. **`log_abs_vandermonde_eq_sum`** — log|det V| = ∑_{i<j} log(λⱼ - λᵢ) (Coulomb energy decomposition)
6. **`repulsion_stronger_at_higher_beta`** — Higher β ⟹ stronger repulsion near coincidence
7. **`vandermonde_two`** — Explicit 2×2 case: det = b - a
8. **`eigenvalue_gap_sq_symm`** — Gap symmetry

### Research Document

`Probability/EIGENVALUE_REPULSION_RESEARCH.md` contains the full research report covering the mathematical derivation, physical interpretation, connections to number theory (Montgomery-Odlyzko), quantum chaos (BGS conjecture), integrable systems (Calogero-Moser), and free probability (Wigner semicircle law), along with the Oracle's verdict on the deep meaning of this correspondence.