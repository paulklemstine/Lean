/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Betti Numbers from the Harmonic Kernel: Discrete Hodge Theory via Rank–Nullity

This file *globalizes* the discrete Hodge theorem proved entrywise (matrix form) in
`Catalog/Speculative/AutoResearch/HodgeFullDecomposition.lean`
(`fullHodge_kernel`, `hodge_image_orthogonal`) to an **operator-theoretic, basis-free**
statement on arbitrary finite-dimensional real inner product spaces, and then extracts the
central numerical invariant of local-to-global cohomology: the **harmonic space dimension
equals a Betti number**.

For a two-step cochain complex of finite-dimensional inner product spaces

  `U --e--> V --d--> W`        with the chain condition `d ∘ e = 0`,

the combinatorial **Hodge Laplacian** on `V` is

  `Δ = d* d + e e*`            (`hodgeLap d e`),

where `d*`, `e*` are the (finite-dimensional) adjoints.  The discrete Hodge theorem
(`hodgeLap_ker`) identifies the harmonic cochains `ker Δ` with the *closed-and-coclosed*
signals `ker d ⊓ ker e*`, and `ker e* = (range e)ᗮ`.  Under the chain condition the gradient
image `range e` lies inside the closed space `ker d`, so harmonic cochains are exactly the
orthogonal complement of `range e` *inside* `ker d`.  Rank–nullity in the inner product space
then gives the **Hodge–Betti identity**

  `dim (harmonic) + rank e = dim (ker d)`,    i.e.   `b = dim ker d − rank e`   (`hodge_betti`).

This is the local-to-global principle in its purest discrete form: a global topological
invariant (the Betti number `dim ker Δ`) is computed from purely *local* algebraic data
(the ranks and kernels of the two boundary maps).

## Main results

* `ker_adjoint_eq_orthogonal_range` — `ker e* = (range e)ᗮ` (coclosed = perp of gradients).
* `hodgeLap_quadform`               — `⟪Δ x, x⟫ = ‖d x‖² + ‖e* x‖²` (split Dirichlet energy).
* `hodgeLap_ker`                    — discrete Hodge theorem: `ker Δ = ker d ⊓ ker e*`.
* `range_e_le_ker_d`                — chain condition `d ∘ e = 0` puts `range e ≤ ker d`.
* `hodge_betti`                     — **Hodge–Betti identity** `dim (ker Δ) + rank e = dim (ker d)`.
* `hodge_betti_eq`                  — `dim (ker Δ) = dim (ker d) − rank e` (Betti number formula).

## Catalog synthesis

This realizes **Research Direction 1** of `HodgeFullDecomposition`'s FUTURE_DIRECTIONS
("Betti numbers from the harmonic kernel dimension").  It promotes the matrix lemmas
`fullHodge_kernel` and `hodge_image_orthogonal` to the operator level, and supplies the one
missing ingredient — the orthogonal rank–nullity step
`Submodule.finrank_add_inf_finrank_orthogonal` — to turn the kernel description into a
dimension count.  It bridges the *MachineLearning* domain (simplicial message passing) with
algebraic topology (the Hodge isomorphism `harmonic ≅ Hᵏ` and Betti numbers).
-/
import Mathlib

namespace HodgeBettiRank

open LinearMap RealInnerProductSpace
open scoped InnerProductSpace

variable {U V W : Type*}
  [NormedAddCommGroup U] [InnerProductSpace ℝ U] [FiniteDimensional ℝ U]
  [NormedAddCommGroup V] [InnerProductSpace ℝ V] [FiniteDimensional ℝ V]
  [NormedAddCommGroup W] [InnerProductSpace ℝ W] [FiniteDimensional ℝ W]

-- !-- Lab Notebook -- !--
-- Hypothesis: The entrywise matrix discrete-Hodge theorem `fullHodge_kernel` should lift to a
--   basis-free operator statement `ker(d*d + e e*) = ker d ⊓ ker e*`, and combining it with
--   `ker e* = (range e)ᗮ` plus the chain condition `range e ≤ ker d` should yield the
--   Betti-number identity `dim(ker Δ) = dim(ker d) − rank e` by orthogonal rank–nullity.
-- Result: All six statements are proven sorry-free.  `hodge_betti` is the genuine
--   Hodge–Betti dimension count, with the local boundary data (ker d, range e) determining
--   the global invariant dim(ker Δ).
-- Insight: The single load-bearing geometric lemma is Mathlib's
--   `Submodule.finrank_add_inf_finrank_orthogonal : K₁ ≤ K₂ → dim K₁ + dim (K₁ᗮ ⊓ K₂) = dim K₂`.
--   With K₁ = range e and K₂ = ker d, the inner term `(range e)ᗮ ⊓ ker d` is *exactly* the
--   harmonic space (after `hodgeLap_ker` and `ker_adjoint_eq_orthogonal_range`), so the
--   Betti identity is rank–nullity applied to the gradient map restricted to closed cochains.
-- Failure analysis: the energy-vanishing step needs `inner_self_eq_zero` over ℝ together with
--   `adjoint_inner_left`/`adjoint_inner_right`; `real_inner_comm` is required to align the
--   coclosed condition `⟪e w, x⟫` with the adjoint adjunction `⟪x, e w⟫ = ⟪e* x, w⟫`.  The
--   chain condition `d ∘ e = 0` is consumed *only* in `range_e_le_ker_d`.
-- !-- end Lab Notebook -- !--

/-- The combinatorial **Hodge Laplacian** `Δ = d* d + e e*` on the middle space `V` of a
two-step complex `U --e--> V --d--> W`. -/
noncomputable def hodgeLap (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) : V →ₗ[ℝ] V :=
  (LinearMap.adjoint d) ∘ₗ d + e ∘ₗ (LinearMap.adjoint e)

-- !-- Coclosed = perp of gradients.  `e* x = 0 ↔ ∀ w, ⟪x, e w⟫ = 0` via the adjoint
--    adjunction `⟪x, e w⟫ = ⟪e* x, w⟫` and `inner_self_eq_zero`. -- !--
theorem ker_adjoint_eq_orthogonal_range (e : U →ₗ[ℝ] V) :
    LinearMap.ker (LinearMap.adjoint e) = (LinearMap.range e)ᗮ := by
  ext x
  simp only [LinearMap.mem_ker, Submodule.mem_orthogonal]
  constructor
  · intro hx u hu
    obtain ⟨w, rfl⟩ := hu
    rw [real_inner_comm, ← LinearMap.adjoint_inner_left, hx, inner_zero_left]
  · intro hx
    rw [← inner_self_eq_zero (𝕜 := ℝ), LinearMap.adjoint_inner_left, real_inner_comm]
    exact hx _ ⟨_, rfl⟩

-- !-- Split Dirichlet energy.  Distribute the inner product over the sum and apply the
--    adjoint adjunctions: `⟪d* (d x), x⟫ = ⟪d x, d x⟫` and `⟪e (e* x), x⟫ = ⟪e* x, e* x⟫`. -- !--
theorem hodgeLap_quadform (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) (x : V) :
    ⟪hodgeLap d e x, x⟫_ℝ = ⟪d x, d x⟫_ℝ + ⟪(LinearMap.adjoint e) x, (LinearMap.adjoint e) x⟫_ℝ := by
  simp only [hodgeLap, LinearMap.add_apply, LinearMap.comp_apply, inner_add_left]
  have hsecond : ⟪ e ((LinearMap.adjoint e) x), x ⟫_ℝ
      = ⟪ (LinearMap.adjoint e) x, (LinearMap.adjoint e) x ⟫_ℝ := by
    rw [real_inner_comm, ← LinearMap.adjoint_inner_left]
  rw [LinearMap.adjoint_inner_left, hsecond]

-- !-- Discrete Hodge theorem (operator form).  `(→)`: `Δ x = 0` makes the sum of the two
--    nonnegative energies vanish, so each vanishes; `inner_self_eq_zero` gives `d x = 0`,
--    `e* x = 0`.  `(←)`: both vanish so `Δ x = d* 0 + e 0 = 0`. -- !--
theorem hodgeLap_ker (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) :
    LinearMap.ker (hodgeLap d e) = LinearMap.ker d ⊓ LinearMap.ker (LinearMap.adjoint e) := by
  ext x
  simp only [LinearMap.mem_ker, Submodule.mem_inf]
  constructor
  · intro hx
    have hq : ⟪d x, d x⟫_ℝ + ⟪(LinearMap.adjoint e) x, (LinearMap.adjoint e) x⟫_ℝ = 0 := by
      rw [← hodgeLap_quadform, hx, inner_zero_left]
    have h1 : (0:ℝ) ≤ ⟪d x, d x⟫_ℝ := real_inner_self_nonneg
    have h2 : (0:ℝ) ≤ ⟪(LinearMap.adjoint e) x, (LinearMap.adjoint e) x⟫_ℝ := real_inner_self_nonneg
    exact ⟨inner_self_eq_zero (𝕜 := ℝ) |>.mp (by linarith),
      inner_self_eq_zero (𝕜 := ℝ) |>.mp (by linarith)⟩
  · rintro ⟨hd, he⟩
    simp only [hodgeLap, LinearMap.add_apply, LinearMap.comp_apply, hd, he, map_zero, add_zero]

-- !-- Chain condition.  `d (e u) = (d ∘ e) u = 0`, so every gradient lies in the closed
--    (kernel-of-`d`) space. -- !--
omit [FiniteDimensional ℝ U] [FiniteDimensional ℝ V] [FiniteDimensional ℝ W] in
theorem range_e_le_ker_d (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) (hde : d ∘ₗ e = 0) :
    LinearMap.range e ≤ LinearMap.ker d := by
  rintro v ⟨u, rfl⟩
  rw [LinearMap.mem_ker, ← LinearMap.comp_apply, hde, LinearMap.zero_apply]

-- !-- Hodge–Betti identity.  Rewrite `ker Δ` as `(range e)ᗮ ⊓ ker d` (via `hodgeLap_ker` and
--    `ker_adjoint_eq_orthogonal_range`), then apply orthogonal rank–nullity
--    `Submodule.finrank_add_inf_finrank_orthogonal` with `range e ≤ ker d`. -- !--
theorem hodge_betti (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) (hde : d ∘ₗ e = 0) :
    Module.finrank ℝ (LinearMap.ker (hodgeLap d e))
      + Module.finrank ℝ (LinearMap.range e) = Module.finrank ℝ (LinearMap.ker d) := by
  have hker : LinearMap.ker (hodgeLap d e)
      = (LinearMap.range e)ᗮ ⊓ LinearMap.ker d := by
    rw [hodgeLap_ker, ker_adjoint_eq_orthogonal_range, inf_comm]
  rw [hker, add_comm]
  exact Submodule.finrank_add_inf_finrank_orthogonal (range_e_le_ker_d d e hde)

-- !-- Betti number as a subtraction.  Immediate from `hodge_betti` by transposing the
--    `rank e` term (a `Nat` subtraction made exact by the additive identity). -- !--
theorem hodge_betti_eq (d : V →ₗ[ℝ] W) (e : U →ₗ[ℝ] V) (hde : d ∘ₗ e = 0) :
    Module.finrank ℝ (LinearMap.ker (hodgeLap d e))
      = Module.finrank ℝ (LinearMap.ker d) - Module.finrank ℝ (LinearMap.range e) := by
  have := hodge_betti d e hde
  omega

end HodgeBettiRank