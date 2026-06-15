# Future Directions — Hodge Spectral Duality, Seventh Cycle

## Synthesis

This cycle closed a structural gap in the discrete-Hodge program and welded its two
historically separate strands into one. The *decomposition foundation* that the
message-passing cycles silently depended on —
`Catalog/Speculative/AutoResearch/HodgeSpectralThreshold.lean` — was missing from the
tree, leaving the entire `HodgeMessagePassing*` chain unbuildable. We rebuilt it from
first principles and proved its headline facts sorry-free: the Cauchy–Schwarz kernel
criterion `psd_inner_self_eq_zero`, the symmetry and positivity of the Hodge Laplacian
`Δ = up + down` (`hodgeLaplacian_symm`, `hodgeLaplacian_pos`), the additive Dirichlet
energy `⟪Δx,x⟫ = ⟪up x,x⟫ + ⟪down x,x⟫` (`hodgeLaplacian_energy_split`), the
closed-and-coclosed characterisation of harmonic cochains (`harmonic_iff`), and its
submodule form `ker Δ = ker up ⊓ ker down` (`ker_hodgeLaplacian`).

On top of this we built `HodgeSpectralDuality.lean`, the synthesis layer. Its organising
phenomenon is **eigenvalue additivity**: on a simultaneous eigenvector of the up and down
pieces the Hodge Laplacian acts as the sum of the eigenvalues
(`hodgeLaplacian_joint_eigen`). Pushing this through the spectral representation of
message passing (`mpStep_eigen`, `mpStep_iterate_eigen`, `mpStep_eigen_energy` from
`HodgeMessagePassingDuality`) shows that one full-Hodge layer `T = 1 - α·Δ` acts as the
scalar `1 - α(a+b)`, every iterate as `(1 - α(a+b))ᵏ`, and the energy of a joint mode
after `k` layers is *exactly* `(1 - α(a+b))^{2k}‖x‖²`. At the kernel end of the spectrum
the dynamical and algebraic pictures coincide: for a nonzero step the fixed points of
full-Hodge message passing are exactly the harmonic cochains
(`mpStep_hodge_fixed_iff_harmonic`), and as submodules the unit eigenspace of the layer
equals `ker up ⊓ ker down` (`mpStep_hodge_eigenspace_one_eq_ker_inf`). The layer inherits
self-adjointness from `Δ` (`mpStep_hodge_symm`).

## Results summary

- `HodgeSpectralThreshold.lean` — 1 definition + 6 theorems, sorry-free. Foundation that
  un-breaks the whole `HodgeMessagePassing*` import chain.
- `HodgeSpectralDuality.lean` — 7 theorems, sorry-free. Cross-cycle synthesis: spectral
  additivity of `Δ`, scalar/energy action of message passing on joint modes, and the
  fixed-point ↔ cohomology identification at both the pointwise and submodule levels.
- Repair: replaced a `module`/`simp`-based proof in `HodgeMessagePassingDuality.lean`
  (`hodge_cohomology_eq_fixed`) that no longer closed under this Mathlib, restoring the
  full chain (`Convergence`, `Duality`, `Energy`, `DeepLimit`) to a clean build.

All main results use only `propext`, `Classical.choice`, and `Quot.sound`.

## Research directions

**1. The full spectral mapping theorem for Hodge message passing.**
We have proved the scalar action of `T = 1 - α·Δ` on a *single* joint eigenvector, but
not yet that the *whole* spectrum of `T` is the affine image `1 - α·spec(Δ)`. The
falsifiable claim: in finite dimension, `spec(mpStep Δ α) = { 1 - α·μ : μ ∈ spec(Δ) }`,
and the eigenspaces match under `x ↦ x`. The key insight is that `T` is a degree-one
*polynomial* in `Δ`, so this is the spectral-mapping theorem `spec(p(Δ)) = p(spec(Δ))`
specialised to `p(t) = 1 - αt`; nothing analytic is needed beyond Mathlib's
`Module.End` eigenvalue API. Why now? With `hodgeLaplacian_joint_eigen` and
`mpStep_eigenspace_one` already in place, the eigenvalue-by-eigenvalue half is done; only
the surjectivity-of-the-spectrum direction (every eigenvalue of `T` arises this way)
remains, and it follows from invertibility of `T - (1-αμ)` off the spectrum.

**2. Quantitative two-sided spectral gap from the up/down split.**
`hodgeLaplacian_pos` gives `⟪Δx,x⟫ ≥ 0`; sharpen it to a *gap*: if `up` has Rayleigh
floor `μ_u` on `(ker up)ᗮ` and `down` has floor `μ_d` on `(ker down)ᗮ`, then on
`(ker Δ)ᗮ` the Laplacian has floor `min(μ_u, μ_d)` and the optimal message-passing rate
is `1 - min(μ_u,μ_d)/λ`. The key insight is that the additive energy split
`⟪Δx,x⟫ = ⟪up x,x⟫ + ⟪down x,x⟫` turns a two-sided gap into a one-sided minimum, so the
existing `contraction_factor_optimal` lemma applies verbatim with `μ := min(μ_u, μ_d)`.
Why now? `hodgeLaplacian_energy_split` is the missing algebraic identity; the optimisation
half already exists in `HodgeMessagePassingConvergence`, so the two compose directly.

**3. Betti numbers as fixed-point multiplicities of message passing.**
`mpStep_hodge_eigenspace_one_eq_ker_inf` identifies the unit eigenspace of `T` with
`ker up ⊓ ker down` as submodules. The falsifiable conjecture: in finite dimension,
`dim (unit eigenspace of T) = dim (ker up ⊓ ker down) = bₖ`, the `k`-th Betti number, and
this equals the algebraic multiplicity of the eigenvalue `1` of `T`. The key insight is
that the discrete Hodge theorem (`Hᵏ ≅ ker Δ`) plus our submodule identity makes Betti
numbers *literally computable* as the dimension of a `1`-eigenspace of an explicit, evaluable
operator. Why now? `HodgeBettiRank.lean` already studies `dim (ker Δ)`; bridging it to the
fixed-point space via this cycle's submodule identity makes the count algorithmic.

**4. Convergence of *scheduled* (multi-rate) full-Hodge message passing.**
Real architectures vary the step `α` per layer. The claim: for a schedule `(αᵢ)` with
each `αᵢ` in the contraction window `0 < αᵢ·λ < 2`, the composite `∏ᵢ (1 - αᵢ·Δ)` still
converges to the harmonic projection, with rate `∏ᵢ |1 - αᵢ·μ|`. The key insight is that
all these layers are simultaneously diagonalised by `Δ` (every `1 - αᵢ·Δ` commutes with
`Δ` and with each other, by `mpStep_comm_L`), so a heterogeneous schedule behaves like a
single operator with eigenvalue `∏(1 - αᵢλ)` on each mode. Why now? `mpStep_comm_L` and
`mpStep_hodge_joint_eigen` already give commutation and per-mode scalar action; the
product over a finite schedule is then a clean induction on the schedule length.
