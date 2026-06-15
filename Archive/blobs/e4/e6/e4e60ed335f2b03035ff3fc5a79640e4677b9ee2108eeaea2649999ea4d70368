# Future Directions — Definable Ricci-Flow Renormalization Fixed Points in Simplicial Quantum Codes

## Synthesis

This cycle turned the (informal) physics conjecture — *a coupled discrete Ricci-flow /
Hodge-Laplacian renormalization on a simplicial CSS code converges to a unique
scale-invariant fixed point iff the family has linear distance and a positive threshold* —
into a chain of fully formal Lean theorems (`Catalog/Physics/RicciFlowQECFixedPoint.lean`,
`sorry`-free, only `propext`/`Classical.choice`/`Quot.sound`).

We separated the conjecture into its load-bearing mathematical skeletons and proved each:

1. **Homotopical/homological layer.** A CSS code *is* a `ZMod 2` chain complex; the
   stabilizer commutation `Hx·Hzᵀ = 0` is exactly the chain relation `range ∂₂ ≤ ker ∂₁`
   (`css_stabilizers_commute`, `css_homology_well_defined`), so the logical qubits are a
   homology group — a homotopy invariant of the complex.
2. **Hodge layer.** The discrete Hodge Laplacian `Δ = ∂*∂` is self-adjoint and positive,
   and its harmonic forms are exactly the cocycles: `ker Δ = ker ∂`
   (`hodge_laplacian_isSymmetric/isPositive`, `hodge_harmonic_eq_ker`).
3. **Flow layer.** The linearized renormalization step is a Banach contraction with a
   *unique, globally attracting, scale-invariant* fixed point (`renorm_contracting`,
   `renorm_fixedPoint_unique`, `renorm_global_attractor`), and convergence holds **iff**
   the curvature factor is below the critical value `1` (`renorm_threshold`).
4. **Bridge.** The Hodge heat-flow `x ↦ x − ε·Δx` has fixed-point set *exactly* the
   harmonic forms `ker ∂` (`hodge_flow_fixedPoints_eq_harmonic`), linking flow stability
   to homology — the formal core of the "geometric renormalization criterion".

## Results summary

| Theorem | Statement | Status |
|---|---|---|
| `css_stabilizers_commute` | `Hx·Hzᵀ = 0 ⇒ rows orthogonal` | proved |
| `css_homology_well_defined` | `∂₁∘∂₂ = 0 ⇒ range ∂₂ ≤ ker ∂₁` | proved |
| `hodge_laplacian_isSymmetric` / `isPositive` | `Δ = ∂*∂` self-adjoint, positive | proved |
| `hodge_harmonic_eq_ker` | `ker Δ = ker ∂` (discrete Hodge) | proved |
| `renorm_contracting` / `..._unique` / `..._global_attractor` | Banach fixed-point dynamics | proved |
| `renorm_threshold` | convergence `↔` factor `< 1` | proved |
| `hodge_flow_fixedPoints_eq_harmonic` | Hodge-flow fixed pts `= ker ∂` | proved |

## Bold, falsifiable research directions

### 1. Spectral threshold from the operator norm of the Hodge Laplacian
Replace the abstract scalar curvature factor `a` by the genuine heat-flow operator
`x ↦ x − ε·Δx` and prove convergence to the harmonic projection holds **iff**
`0 < ε < 2/‖Δ‖`, with rate `(1 − ε·λ₁)` set by the smallest nonzero eigenvalue `λ₁`
(the spectral gap). *Falsifiable:* exhibit a complex and an `ε` in that window for which
the iterates fail to converge to `ker ∂`, or one outside it that does converge.
**The key insight is** that `Δ = ∂*∂` is positive and self-adjoint, so its spectral
decomposition turns the nonlinear "coupled flow" into a diagonal family of scalar
contractions — each eigenmode is an instance of `renorm_threshold`.
**Why now?** `hodge_harmonic_eq_ker` and `renorm_threshold` are already proven; the only
missing ingredient is `Mathlib`'s finite-dimensional spectral theorem for
`IsSymmetric` operators, which is available, so this is an assembly task, not new theory.

### 2. Linear distance ⇔ a uniform spectral gap (expander/Cheeger bridge)
Conjecture: a *bounded-degree* simplicial CSS family has asymptotically linear distance
**iff** the family of normalized Hodge Laplacians has a spectral gap bounded away from `0`
(a higher-dimensional Cheeger inequality). *Falsifiable:* a bounded-degree family with
linear distance but `λ₁ → 0`, or vice versa.
**The key insight is** that distance is the minimal weight of a non-harmonic cocycle, and
the gap controls how fast non-harmonic modes are damped by the flow — so distance and
gap are two readings of the same coboundary expansion constant.
**Why now?** The catalog already contains expander machinery
(`Algebra/ClassicalGroupExpanders.lean`, `Algebra/ExpanderWalk/Amplification.lean`) and
parameter bounds (`Physics/StabilizerBounds.lean`); coupling them to
`hodge_harmonic_eq_ker` is a concrete cross-domain bridge.

### 3. Homotopy invariance of the renormalization fixed point
Conjecture: chain-homotopy-equivalent CSS complexes have renormalization flows with
the *same* attracting fixed point up to the induced isomorphism on homology — i.e. the
fixed point is a homotopy invariant, not a presentation artifact. *Falsifiable:* two
homotopy-equivalent complexes whose flows converge to inequivalent harmonic spaces.
**The key insight is** that `ker ∂` modulo `range ∂'` (homology) is preserved by chain
homotopy, and `hodge_flow_fixedPoints_eq_harmonic` pins the fixed set to `ker ∂`; the
quotient by coboundaries should then be invariant.
**Why now?** `Mathlib`'s `HomologicalComplex`/`HomotopyEquiv` API is mature, and our
fixed-point characterization is already homological rather than basis-dependent.

### 4. Strict contraction on the coboundary complement only (degenerate threshold)
Our `renorm` contracts everywhere; the real Hodge flow is *stationary* on `ker ∂` and
contracts only its orthogonal complement. Conjecture: `x ↦ x − ε·Δx` restricted to
`(ker ∂)ᗮ` is a strict `ContractingWith` map, giving convergence of every initial state to
its harmonic projection. *Falsifiable:* a nonzero `ε` in the stable window for which some
state's iterates do not converge to `orthogonalProjection (ker ∂) x`.
**The key insight is** that the threshold is "bounded away from zero" exactly on the
complement of the harmonic (zero-curvature) directions — the degeneracy on `ker ∂` is the
*scale invariance*, not a failure of convergence.
**Why now?** `orthogonalProjection` and `Submodule.orthogonal` are in `Mathlib`, and
`hodge_laplacian_isPositive` already gives the strict positivity needed off the kernel.

### 5. Toric-code instance: closed-form fixed point and gap
Specialize the whole package to `toricCodeParams L` from
`Catalog/Physics/StabilizerBounds.lean`: compute the Hodge spectrum of the `L×L` torus
explicitly (`λ_{j,k} = 4 − 2cos(2πj/L) − 2cos(2πk/L)`), and prove the renormalization
fixed point is the constant harmonic representative with convergence rate `1 − ε·λ_min`.
*Falsifiable:* a closed-form gap prediction that disagrees with the iterated flow.
**The key insight is** that the torus Laplacian diagonalizes under the discrete Fourier
transform, so every claim above becomes an explicit, checkable arithmetic identity in `L`.
**Why now?** `toric_kd2_equals_n` and the toric parameter lemmas are already proven, and
`Mathlib` has the discrete/finite Fourier transform — making this the first fully worked
*numerical-and-formal* test of the original conjecture on a concrete code family.
