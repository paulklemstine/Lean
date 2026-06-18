# Future Directions: Tropical Hodge Theory

The new file `Catalog/Tropical/HodgeDecomposition/Orthogonal.lean` completes the
abstract backbone of tropical Hodge theory: starting from a two-step cochain
complex `E₀ → E₁ → E₂` of finite-dimensional real inner-product spaces (the
cochain spaces of a *balanced weighted polyhedral complex*, equipped with their
canonical weighted inner product), it proves the **Bochner identity**, the
**harmonic characterization** `ker Δ = ker d₁ ∩ ker δ₀`, the **orthogonal Hodge
decomposition** `E₁ = (im d₀ ⊕ im δ₁) ⊕ ℋ`, and the capstone **Hodge
isomorphism** `unique_harmonic_representative`, which exhibits a unique harmonic
representative in every cohomology class. This extends the catalog file
`HodgeDecomposition/Defs.lean` (which only had the single-Laplacian kernel
identity `ker_laplacianUp_eq_ker_d`) to the full middle-degree theory, and it
connects directly to the cycle-class story in `HodgeCorrespondence.lean`.

Below are five concrete, falsifiable directions that the next cycle should
attempt, each phrased so that it can be stated as a Lean theorem and either
proved or disproved.

## 1. The long cochain complex and degreewise Hodge decomposition

Generalize from a single middle term to a finite graded complex
`C⁰ → C¹ → ⋯ → Cⁿ` with `dᵏ⁺¹ ∘ dᵏ = 0`, and prove that *every* degree splits
orthogonally as `Cᵏ = im dᵏ⁻¹ ⊕ ℋᵏ ⊕ im δᵏ⁺¹`, with `ℋᵏ ≅ Hᵏ`. The conjecture
is that the alternating sum of `dim ℋᵏ` equals the Euler characteristic of the
complex, recovering `Defs.rank_nullity` as the `n = 1` shadow.
**The key insight is** that the middle-term result already proved is degree-local:
each `Cᵏ` sees only its two neighboring differentials, so the global statement is
an indexed product of the theorem `hodge_decomposition` glued by `dᵏ⁺¹ ∘ dᵏ = 0`.
**Why now?** With `unique_harmonic_representative` in hand, the only missing
ingredient is bookkeeping over `Fin (n+1)`; no new analytic input is needed, so
this is a pure linear-algebra extension that Lean's `DirectSum.IsInternal` API
can carry.

## 2. Poincaré duality via the tropical Hodge star

Define a nondegenerate pairing `ℋᵖ × ℋⁿ⁻ᵖ → ℝ` from the weighted Hodge star
(`Defs.tropicalHodgeStar`) and prove it induces an isomorphism `ℋᵖ ≅ (ℋⁿ⁻ᵖ)*`,
hence `dim Hᵖ = dim Hⁿ⁻ᵖ`. **The key insight is** that the Hodge star intertwines
`d` and `δ` (`⋆ δ = ± d ⋆`), so it carries harmonic forms to harmonic forms; the
pairing's nondegeneracy then follows from positive-definiteness of the weighted
inner product, exactly the property `weightedIP_pos_def` already establishes in
`Defs.lean`. **Why now?** The harmonic spaces are now identified with cohomology,
so duality becomes a statement about a single finite-dimensional inner-product
space and its star operator — provable without ever leaving linear algebra.

## 3. Hard Lefschetz as positivity of a commutator

Replace the *combinatorial* `SatisfiesHLP` predicate of `Defs.lean` with the
*operator* statement: for a Lefschetz element `L` (cup with an ample tropical
divisor class) the `sl₂`-triple `(L, Λ, H)` acts on `⨁ ℋᵏ`, and `Lⁿ⁻ᵏ : ℋᵏ → ℋ²ⁿ⁻ᵏ`
is an isomorphism. **The key insight is** that Hard Lefschetz for matroids is
equivalent to a single positivity/commutator identity `[L, Λ] = H`, which is a
finite linear-algebra check on the harmonic spaces rather than an algebro-geometric
theorem. **Why now?** Adiprasito–Huh–Katz proved Hodge theory for matroids; with
harmonic spaces formalized we can finally state HL as a Lean proposition about
explicit matrices and test it on the rank-2 uniform matroid `U_{2,4}`, whose
predicted Betti vector `(1,3,1)` is already recorded in `Defs.lean`.

## 4. Stability of the spectrum under balanced refinement

Conjecture: subdividing a balanced weighted complex while preserving the balancing
condition leaves the nonzero spectrum of the Hodge Laplacian `Δ` invariant up to
the multiplicities forced by the new cells, and in particular leaves `dim ℋᵏ`
unchanged. **The key insight is** that harmonicity was shown to be purely a
kernel/orthogonality condition (`mem_harmonic_iff`), so subdivision acts by an
isometric inclusion of cochain spaces under which the harmonic subspace is
preserved — a combinatorial invariance, not a metric one. **Why now?** Because
`harmonic_eq_orthogonal` reduces `dim ℋᵏ` to a rank computation, invariance can be
phrased as an equality of ranks of explicit incidence matrices and attacked with
the matrix Laplacian machinery (`WeightedCoboundary.laplacianUp`) already present.

## 5. A heat-flow / spectral-gap certificate for tropical harmonic projection

Define the discrete heat semigroup `e^{-tΔ}` on `E₁` and prove it converges as
`t → ∞` to the orthogonal projection onto `ℋ`, with exponential rate governed by
the smallest nonzero eigenvalue of `Δ`. **The key insight is** that
`hodgeLaplacian_isSelfAdjoint` plus the orthogonal decomposition gives an
eigenbasis in which `e^{-tΔ}` is diagonal, so convergence to the harmonic
projector is termwise and the spectral gap is literally the second-smallest
eigenvalue. **Why now?** Mathlib's finite-dimensional spectral theorem for
self-adjoint operators is available, and self-adjointness is already proved, so
this turns an analytic-looking statement into a finite eigenvalue estimate —
yielding a *quantitative* tropical Hodge theory with direct applications to the
certified-robustness and tropical-SVP bridges flagged in `HodgeTheory/Foundations.lean`.
