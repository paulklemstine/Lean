# Future Directions — Spectral Depth Thresholds for Hodge–Laplacian Message Passing

## Synthesis

The file `Catalog/MachineLearning/HodgeSpectralThreshold.lean` extracts a rigorous,
sorry-free linear-algebraic skeleton for *spectral depth thresholds* in higher-order
message passing. The combinatorial Hodge Laplacian `L = Bᵀ B` is realized as a symmetric
positive-semidefinite operator whose Dirichlet energy `⟨x, L x⟩ = ⟨B x, B x⟩` is the
single identity from which everything else flows. Two regimes are made precise and
proven in full:

* **Homotopy-invariant core.** Harmonic cochains — the kernel of `L`, isomorphic by the
  discrete Hodge theorem to a cohomology group — are *exact fixed points* of message
  passing at every depth (`mpStep_iterate_fixes_harmonic`). Topology survives arbitrarily
  deep networks undistorted.
* **Contractive complement.** On energy-carrying signals, one layer contracts the energy
  by the quantitative factor `1 - αμ(2 - αλ)` (`mpStep_contraction`); iterating contracts
  geometrically (`quadform_iterate_bound`), so for any tolerance `ε` only finitely many
  layers are needed (`spectral_depth_threshold`).

The conceptual payload is a unification: message passing is a *discrete deformation
retraction* onto the harmonic (homotopy-invariant) subspace, and "depth" is the
continuous-time parameter of that retraction. This is the Homotopy & Path-Space lens
applied to learning on cell complexes.

## Results summary

| Theorem | Statement |
|---|---|
| `hodge_isSymm` | `Bᵀ B` is symmetric |
| `hodge_quadform` | `⟨x, L x⟩ = ⟨B x, B x⟩` (Dirichlet energy) |
| `hodge_psd` | `L` is positive semidefinite |
| `harmonic_iff_boundary` | discrete Hodge: `L x = 0 ↔ B x = 0` |
| `mpStep_fixes_harmonic` / `..._iterate_...` | harmonic signals fixed at every depth |
| `quadform_mpStep` | exact one-layer energy expansion |
| `mpStep_contraction` | one-layer contraction factor `1 - αμ(2 - αλ)` |
| `quadform_iterate_bound` | geometric energy decay `ρ^k` |
| `spectral_depth_threshold` | finite depth suffices for any tolerance |

All proofs use only `propext`, `Classical.choice`, `Quot.sound`.

## Research directions

### 1. The retraction is a deformation onto the harmonic subspace (orthogonal splitting)
Conjecture: with the admissible step `0 < α < 2/λ_max`, the message-passing flow `mpStep`
restricted to the `⟨·,·⟩`-orthogonal complement of `ker L` is a strict contraction, so
the iterate `(mpStep L α)^[k]` converges to the orthogonal projection `P_ker` onto the
harmonic subspace, and `‖(mpStep L α)^[k] x − P_ker x‖² ≤ (1 − αμ(2 − αλ))^k ‖x − P_ker x‖²`.
This is falsifiable: a single complex with an eigenvalue outside `(0, 2/α)` would exhibit
non-contraction or oscillation. **The key insight is** that `quadform_iterate_bound`
already gives the geometric rate on any invariant subspace, so the missing ingredient is
purely the invariance `mpStep L α '' (ker L)ᗮ ⊆ (ker L)ᗮ`, which follows from self-adjointness
of `L`. **Why now?** The orthogonal projection and `IsSymm`/self-adjoint spectral theorem
for finite real matrices are fully available in Mathlib, so the splitting can be assembled
from existing pieces rather than rebuilt.

### 2. Full Hodge decomposition: down + up Laplacian and the harmonic obstruction
Conjecture: for boundary maps `∂ₖ₊₁ : C_{k+1} → C_k` and `∂ₖ : C_k → C_{k-1}` with
`∂ₖ ∂ₖ₊₁ = 0`, the full Hodge Laplacian `L = ∂ₖ₊₁ ∂ₖ₊₁ᵀ + ∂ₖᵀ ∂ₖ` satisfies
`ker L = ker ∂ₖ ∩ ker ∂ₖ₊₁ᵀ`, and `dim ker L = dim ker ∂ₖ − rank ∂ₖ₊₁` (Betti number).
This refines `harmonic_iff_boundary` from the up-only case to the genuine cohomological
invariant. **The key insight is** that the cross term vanishes exactly when `∂ₖ ∂ₖ₊₁ = 0`,
turning the two energies into an orthogonal sum so harmonicity decouples into "closed" and
"coclosed". **Why now?** The up-Laplacian quadratic-form machinery in this file transfers
verbatim to each summand; the only new lemma is the orthogonality of the two images,
which is a one-line `∂∂ = 0` consequence.

### 3. Depth–accuracy trade-off is logarithmic and tight
Conjecture: the minimal depth `N(ε)` from `spectral_depth_threshold` satisfies
`N(ε) = ⌈ log(ε / ‖x‖²) / log ρ ⌉` with `ρ = 1 − αμ(2 − αλ)`, and this bound is tight:
there exists an input (the bottom non-harmonic eigenvector) achieving equality. Falsifiable
by exhibiting a complex where fewer layers already reach `ε`. **The key insight is** that
the worst-case input saturates every inequality in `quadform_iterate_bound` simultaneously,
so the geometric bound is not merely sufficient but exact on the spectral edge. **Why now?**
`Real.logb` and the monotonicity lemmas for `ρ^k` used in `spectral_depth_threshold` make
the explicit `⌈log⌉` formula a direct corollary.

### 4. Oversmoothing as collapse of the path space of signals
Conjecture: define the "signal path space" as the set of trajectories `k ↦ (mpStep L α)^[k] x`;
then as `k → ∞` every path is homotopic (through the linear deformation `t ↦ x − tα L x`,
`t ∈ [0,1]`) to the constant path at `P_ker x`, and the diameter of the reachable set
shrinks like `ρ^k`. Oversmoothing is precisely this collapse of the path space to its
homotopy-invariant core. **The key insight is** that the contraction factor `ρ` bounds the
diameter of the orbit, so the fundamental groupoid of the signal flow degenerates to a
point set indexed by harmonic classes. **Why now?** With the geometric decay already
formalized, the only remaining step is to phrase the orbit diameter bound, which reuses
`quadform_iterate_bound` directly.

### 5. Heat-flow continuum limit and the spectral-gap eigenvalue
Conjecture: the discrete flow `x_{k+1} = x_k − α L x_k` is the explicit Euler scheme of the
Hodge heat equation `ẋ = −L x`; as `α → 0` with `kα = t` fixed, `(mpStep L α)^[k] x → e^{−tL} x`,
and the asymptotic decay constant equals the spectral gap `μ = λ_min(L | (ker L)ᗮ)`. Falsifiable
by a complex whose empirical decay rate differs from its second-smallest Hodge eigenvalue.
**The key insight is** that `mpStep_contraction`'s factor `1 − αμ(2 − αλ) ≈ 1 − 2αμ` matches
the first-order expansion of `e^{−2αμ}`, identifying the discrete contraction rate with the
continuous heat-kernel rate. **Why now?** Mathlib's matrix exponential `Matrix.exp` and its
derivative API are in place, so the Euler-to-exponential limit is a concrete (if technical)
analysis target rather than new theory.
