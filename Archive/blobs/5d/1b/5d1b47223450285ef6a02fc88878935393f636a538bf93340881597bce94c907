# Future Directions — Discrete Hodge Decomposition Core

## Synthesis

The discrete-Hodge program in this catalog already carried a *dynamical* layer
(`HodgeMessagePassingConvergence`: deep gradient message passing `T = 1 - αΔ`
transports the harmonic part exactly and contracts the residual at the spectral
rate). What it lacked was a *self-contained geometric/decomposition* foundation that
does not depend on the (currently absent) `HodgeSpectralThreshold` file. This cycle
supplies exactly that, in `HodgeDecompositionCore.lean`, for an arbitrary real
inner-product space `E` and an abstract Hodge Laplacian `Δ = up + down` assembled from
two symmetric positive-semidefinite operators (`up = d∘dᵀ`, the *up* Laplacian
measuring failure of closedness; `down = eᵀ∘e`, the *down* Laplacian measuring failure
of coclosedness).

The five proven theorems establish the local-to-global core of discrete Hodge theory
as a chain of energy arguments:

* `psd_inner_self_eq_zero` — the **energy-vanishing principle**: for a symmetric PSD
  operator `A`, the Dirichlet energy `⟪x, A x⟫` vanishes *iff* `A x = 0`. A quadratic
  (energy) obstruction is upgraded to a linear (kernel) one via one-variable
  nonnegativity of `t ↦ ⟪x + t•y, A(x + t•y)⟫`.
* `dirichlet_energy_split` — the **split Dirichlet energy** `⟪x, Δ x⟫ = ⟪x, up x⟫ +
  ⟪x, down x⟫`.
* `harmonic_iff` and `energy_zero_iff_harmonic` — the **three equivalent harmonicity
  conditions**: `Δ x = 0 ⇔ (closed ∧ coclosed) ⇔ total Dirichlet energy is zero`. This
  is the discrete analogue of "the harmonic representative is the unique closed-and-
  coclosed representative of its cohomology class".
* `harmonic_orthogonal_image` — **Hodge orthogonality**: every harmonic cochain is
  orthogonal to `range up` and `range down`, exhibiting the cohomology (harmonic) part
  as the obstruction-free orthogonal complement of the exact + coexact part.

These results connect two catalog domains: the spectral/dynamical message-passing
results (`HodgeMessagePassingConvergence.hodge_harmonic_mpStep_fixed`,
`mpStep_converges_to_harmonic`) now rest on a decomposition foundation proved here
without external dependencies, and the energy-vanishing principle is the precise lemma
those convergence statements need to identify the limit subspace `ker Δ`.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `psd_inner_self_eq_zero` | symmetric PSD `A`: `⟪x,Ax⟫ = 0 ↔ A x = 0` | proved, sorry-free |
| `dirichlet_energy_split` | `⟪x, Δx⟫ = ⟪x, up x⟫ + ⟪x, down x⟫` | proved, sorry-free |
| `harmonic_iff` | `Δx = 0 ↔ up x = 0 ∧ down x = 0` | proved, sorry-free |
| `energy_zero_iff_harmonic` | `⟪x, Δx⟫ = 0 ↔ Δx = 0` | proved, sorry-free |
| `harmonic_orthogonal_image` | harmonic ⊥ `range up`, `range down` | proved, sorry-free |

All proofs are axiom-clean (only `propext`, `Classical.choice`, `Quot.sound`).

## Research Directions

### 1. The full orthogonal Hodge splitting `E = ker Δ ⊕ range Δ` in finite dimensions

`harmonic_orthogonal_image` shows `ker Δ ⊆ (range up + range down)ᗮ`. The next step is
the *converse and the direct-sum*: in a finite-dimensional `E`, prove
`E = ker Δ ⊕ᗮ range Δ` with `(ker Δ)ᗮ = range Δ`, and refine it to the three-way
`E = ker Δ ⊕ range up ⊕ range down` once `down ∘ up = 0` (a discrete `e∘d = 0`) is
assumed. **The key insight is** that for a *symmetric* operator the range and kernel
are mutually orthogonal complements, so the entire decomposition is forced by the
energy-vanishing principle already proved here — no eigenbasis is needed.
**Why now?** `psd_inner_self_eq_zero` gives `(ker Δ)ᗮ ⊇ range Δ` cheaply, and Mathlib's
`Submodule.orthogonal` and finite-dimensional `IsCompl` machinery close the gap; this
is the missing geometric statement the message-passing limit theorems implicitly use.

### 2. Quantitative harmonicity: a spectral-gap energy inequality

Replace the qualitative `energy_zero_iff_harmonic` with a quantitative *Poincaré-type*
bound: if `Δ` has spectral gap `μ > 0` on `(ker Δ)ᗮ`, then for the orthogonal
residual `r = x - P_{ker Δ} x`, `μ ⟪r, r⟫ ≤ ⟪x, Δ x⟫`. **The key insight is** that the
gap converts the *energy* `⟪x, Δx⟫` into a *distance-to-harmonic* `⟪r,r⟫`, turning the
decomposition into an effective error bound. **Why now?** The contraction rate
`1 - μ/λ` is already pinned down in `HodgeMessagePassingConvergence`
(`contraction_factor_at_optimal`); pairing it with this Poincaré inequality would yield
an end-to-end *a priori* convergence-rate certificate for Hodge message passing.

### 3. Sheaf-theoretic gluing: local harmonicity implies global harmonicity

Model a cover of the index set by overlapping "patches" and define, per patch, a local
Hodge Laplacian `Δ_U`. Conjecture: a cochain that is harmonic on every patch and
agrees on overlaps glues to a globally harmonic cochain, with the obstruction living in
a Čech `H¹` of the harmonic presheaf. **The key insight is** that `harmonic_iff`
localizes — being harmonic is the *conjunction* of two pointwise (local) conditions
`up x = 0`, `down x = 0` — so harmonicity is literally a sheaf condition, and the only
obstruction to gluing is cohomological. **Why now?** The local-to-global engine this
cycle is configured for needs a concrete sheaf whose stalks are computable; the
discrete harmonic spaces `ker Δ_U`, being kernels of explicit symmetric matrices, are
the simplest nontrivial example to formalize.

### 4. Discrete Hodge duality and the Euler-characteristic invariant

With a degree-graded complex `... → E_{k-1} → E_k → E_{k+1} → ...` and Hodge Laplacians
`Δ_k`, conjecture the discrete Hodge isomorphism `ker Δ_k ≅ H^k` and derive the
combinatorial Euler characteristic `Σ (-1)^k dim(ker Δ_k) = Σ (-1)^k dim E_k`.
**The key insight is** that `harmonic_orthogonal_image` already separates harmonics
from coboundaries in each degree, so the alternating-sum cancellation of the
non-harmonic (image) parts is a finite linear-algebra identity. **Why now?** All the
per-degree pieces (energy split, orthogonality) are in hand; only the bookkeeping of an
alternating sum over a finite graded family remains, which `Finset.sum` handles
directly.

### 5. Robustness of harmonics under operator perturbation

Conjecture a stability statement: if `‖Δ' - Δ‖` is small and `Δ` has spectral gap `μ`,
then the harmonic subspaces `ker Δ` and `ker Δ'` are close (small principal angles),
with an explicit bound in `‖Δ' - Δ‖ / μ`. **The key insight is** that the
energy-vanishing principle makes "almost harmonic" (small energy) equivalent to "almost
in the kernel", so a perturbation that barely changes the energy form barely moves the
kernel. **Why now?** This is the missing *numerical-analysis* counterpart to the exact
decomposition: it would certify that discrete Hodge / spectral message passing computed
on a noisy graph still recovers the true cohomology, directly extending the exact
transport theorem `hodge_harmonic_mpStep_fixed`.
