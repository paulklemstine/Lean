/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Integrated Energy Laws for Hodge-Laplacian Message Passing

This file is the **sixth cycle** of the Hodge message-passing program.  The fifth
cycle (`Catalog/Speculative/AutoResearch/HodgeMessagePassingConvergence.lean`)
established *pointwise* convergence of one-step gradient message passing
`T = 1 - α·L` to the harmonic (cohomology) subspace: the harmonic part of any input
is transported exactly through every depth (`mpStep_iterate_add_harmonic`) while the
residual contracts at the spectral rate (`mpStep_iterate_contraction`).

Here we lift that single-orbit picture to **global, integrated energy laws** for the
whole operator family:

1. **Heterogeneous depth commutes.** Layers `1 - α·L` and `1 - β·L` of *different*
   learning rates commute (`mpStep_comm`), and so do their powers
   (`mpStep_comm_iterate`).  A deep network with an arbitrary *schedule* of step
   sizes depends only on the multiset of rates, not their order.
2. **Energy is antitone in depth.** Under a sub-unital contraction the residual
   Dirichlet energy never increases layer to layer (`mpStep_energy_antitone`): deep
   message passing is provably a low-pass smoother, not merely an asymptotic one.
3. **Total energy is finite.** For a strict contraction the energy summed over
   *every* depth is bounded by the geometric budget `⟪r,r⟫/(1−ρ)`, uniformly in the
   truncation (`mpStep_partial_energy_bound`, `mpStep_total_energy_bound`).  This is
   the discrete shadow of finite Dirichlet action `∫₀^∞ ‖∇u‖² < ∞` for the Hodge
   heat flow, and it is instantiated for the catalog Hodge Laplacian `Δ = up + down`
   in `hodge_total_energy_bound`.

-- !-- Lab Notebook -- !--
Hypothesis:  The convergence cycle controls a *single* orbit `Tᵏr`.  We conjecture
  the *aggregate* quantities are equally clean: (a) different learning rates commute
  because both are polynomials in the single operator `L`, so a schedule of steps is
  order-independent; (b) per-layer Dirichlet energy is monotonically non-increasing
  under any sub-unital contraction; and (c) the energy summed over all depths is a
  convergent geometric series bounded by `⟪r,r⟫/(1−ρ)`, the discrete Dirichlet
  action.
Result:  Formalised and proved sorry-free.  `mpStep_comm` / `mpStep_comm_iterate`
  (commuting layers and their powers), `mpStep_energy_antitone` (layerwise energy
  decrease), `mpStep_partial_energy_bound` / `mpStep_total_energy_bound` (finite
  total energy with the geometric budget), and `hodge_total_energy_bound` (the budget
  instantiated at the catalog Hodge Laplacian `Δ = up + down`, with the per-layer
  rate derived from the spectral bounds via `mpStep_contraction`).
Insight:  Commutation is purely algebraic: `α•L` and `β•L` commute as elements of
  `Module.End ℝ E`, so `Commute.pow_pow` upgrades it to arbitrary depths for free —
  no spectral theory needed.  The energy laws reduce to the scalar geometric series
  `∑ ρᵏ ≤ 1/(1−ρ)` once the per-layer contraction `mpStep_iterate_contraction` of the
  fifth cycle is in hand, so the analytic content is entirely in `geom_sum`.
Failure analysis:  Phrasing antitonicity needs `0 ≤ ⟪T^k r⟫` (`real_inner_self_nonneg`)
  to chain `ρ·E ≤ E` from `ρ ≤ 1`; forgetting nonnegativity makes the step false for
  signed energies.  The total bound needs `0 ≤ ⟪r,r⟫` to turn `∑ρᵏ ≤ 1/(1−ρ)` into
  the energy inequality, and `0 ≤ ρ` for the partial sums to dominate termwise.
-- !-- Lab Notebook -- !--
-/
import Mathlib
import Speculative.AutoResearch.HodgeSpectralThreshold
import Speculative.AutoResearch.HodgeMessagePassingConvergence

open scoped InnerProductSpace BigOperators Topology

namespace HodgeMessagePassingEnergy

open HodgeMessagePassingConvergence

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

/-! ## Heterogeneous learning rates commute -/

/-
!-- comment: Both `1 - α•L` and `1 - β•L` are polynomials in the single operator
`L`, so they commute; `α•L` and `β•L` commute as elements of `Module.End ℝ E`. -- !--

**Commuting layers.** Two message-passing layers `1 - α·L` and `1 - β·L` of
different learning rates commute as linear operators.
-/
theorem mpStep_comm (L : E →ₗ[ℝ] E) (α β : ℝ) :
    (mpStep L α) * (mpStep L β) = (mpStep L β) * (mpStep L α) := by
  unfold mpStep; ext; simp +decide;
  module

/-
!-- comment: `mpStep_comm` gives `Commute (mpStep L α) (mpStep L β)`; then
`Commute.pow_pow` lifts it to arbitrary powers. -- !--

**Commuting schedules.** Powers of layers with different learning rates commute:
`Tα^m · Tβ^n = Tβ^n · Tα^m`.  A heterogeneous depth schedule is order-independent.
-/
theorem mpStep_comm_iterate (L : E →ₗ[ℝ] E) (α β : ℝ) (m n : ℕ) :
    (mpStep L α) ^ m * (mpStep L β) ^ n = (mpStep L β) ^ n * (mpStep L α) ^ m := by
  have h_comm : Commute (mpStep L α) (mpStep L β) := by
    apply mpStep_comm;
  exact h_comm.pow_pow m n

/-! ## Energy is antitone in depth -/

/-
!-- comment: `⟪T^{k+1}r⟫ = ⟪T(T^k r)⟫ ≤ ρ·⟪T^k r⟫ ≤ ⟪T^k r⟫` using the per-layer
contraction with `ρ ≤ 1` and `0 ≤ ⟪T^k r⟫` (`real_inner_self_nonneg`). -- !--

**Layerwise energy decrease.** If a single layer contracts every Dirichlet
energy by a sub-unital factor `ρ ≤ 1`, then the residual energy is non-increasing
from depth `k` to depth `k+1`: deep message passing is a low-pass smoother.
-/
theorem mpStep_energy_antitone (L : E →ₗ[ℝ] E) (α ρ : ℝ) (hρ1 : ρ ≤ 1)
    (hc : ∀ x, ⟪mpStep L α x, mpStep L α x⟫_ℝ ≤ ρ * ⟪x, x⟫_ℝ) (r : E) (k : ℕ) :
    ⟪((mpStep L α) ^ (k + 1)) r, ((mpStep L α) ^ (k + 1)) r⟫_ℝ
      ≤ ⟪((mpStep L α) ^ k) r, ((mpStep L α) ^ k) r⟫_ℝ := by
  convert le_trans ( hc ( ( mpStep L α ^ k ) r ) ) _ using 1;
  · simp +decide [ pow_succ' ];
  · exact mul_le_of_le_one_left ( real_inner_self_nonneg ) hρ1

/-! ## Total Dirichlet energy is finite -/

/-
!-- comment: Bound each term `⟪T^k r⟫ ≤ ρ^k ⟪r,r⟫` by `mpStep_iterate_contraction`,
then `Finset.sum_le_sum` and `Finset.sum_mul`. -- !--

**Partial energy bound.** The energy summed over the first `n` depths is bounded
by the geometric partial sum `(∑_{k<n} ρ^k)·⟪r,r⟫`.
-/
theorem mpStep_partial_energy_bound (L : E →ₗ[ℝ] E) (α ρ : ℝ) (hρ : 0 ≤ ρ)
    (hc : ∀ x, ⟪mpStep L α x, mpStep L α x⟫_ℝ ≤ ρ * ⟪x, x⟫_ℝ) (r : E) (n : ℕ) :
    ∑ k ∈ Finset.range n, ⟪((mpStep L α) ^ k) r, ((mpStep L α) ^ k) r⟫_ℝ
      ≤ (∑ k ∈ Finset.range n, ρ ^ k) * ⟪r, r⟫_ℝ := by
  convert Finset.sum_le_sum fun i hi => HodgeMessagePassingConvergence.mpStep_iterate_contraction L α ρ hρ hc r i using 1;
  rw [ Finset.sum_mul _ _ _ ]

/-
!-- comment: `∑_{k<n} ρ^k ≤ 1/(1−ρ)` for `0 ≤ ρ < 1` (`geom_sum`), and
`0 ≤ ⟪r,r⟫`, so the partial bound `mpStep_partial_energy_bound` gives the budget. -- !--

**Finite total energy (geometric budget).** For a strict contraction
`0 ≤ ρ < 1`, the Dirichlet energy summed over *every* depth is bounded uniformly in
the truncation `n` by `⟪r,r⟫/(1−ρ)` — the discrete shadow of finite Dirichlet action
`∫₀^∞ ‖∇u‖² < ∞` for the Hodge heat flow.
-/
theorem mpStep_total_energy_bound (L : E →ₗ[ℝ] E) (α ρ : ℝ) (hρ0 : 0 ≤ ρ)
    (hρ1 : ρ < 1)
    (hc : ∀ x, ⟪mpStep L α x, mpStep L α x⟫_ℝ ≤ ρ * ⟪x, x⟫_ℝ) (r : E) (n : ℕ) :
    ∑ k ∈ Finset.range n, ⟪((mpStep L α) ^ k) r, ((mpStep L α) ^ k) r⟫_ℝ
      ≤ ⟪r, r⟫_ℝ / (1 - ρ) := by
  refine' le_trans ( mpStep_partial_energy_bound L α ρ hρ0 hc r n ) _;
  rw [ le_div_iff₀ ];
  · nlinarith [ show 0 ≤ ⟪r, r⟫_ℝ by exact real_inner_self_nonneg, show ( ∑ k ∈ Finset.range n, ρ ^ k ) * ( 1 - ρ ) ≤ 1 by rw [ geom_sum_mul_neg ] ; exact sub_le_self _ ( by positivity ) ];
  · linarith

/-! ## Bridge to the catalog Hodge Laplacian -/

/-
!-- comment: Use `mpStep_contraction` to derive the per-layer factor
`ρ = 1 - αμ(2−αλ)` for `L = Δ = up + down` from the spectral bounds, then feed it
to `mpStep_total_energy_bound`. -- !--

**Total energy budget for the Hodge Laplacian.** For the abstract Hodge Laplacian
`Δ = up + down` with symmetric PSD `up`, `down`, a step `α ≥ 0` with `αλ ≤ 2`, and
spectral bounds `μ⟪x,x⟫ ≤ ⟪x,Δx⟫`, `⟪Δx,Δx⟫ ≤ λ⟪x,Δx⟫`, the integrated Dirichlet
energy of message passing is bounded by `⟪r,r⟫/(αμ(2−αλ))`, provided the per-layer
contraction factor `ρ = 1 − αμ(2−αλ)` is a strict contraction.
-/
theorem hodge_total_energy_bound
    (up down : E →ₗ[ℝ] E)
    (α μ lam : ℝ) (hα : 0 ≤ α) (hstep : α * lam ≤ 2)
    (hlower : ∀ x, μ * ⟪x, x⟫_ℝ
        ≤ ⟪x, (HodgeSpectralThreshold.hodgeLaplacian up down) x⟫_ℝ)
    (hupper : ∀ x, ⟪(HodgeSpectralThreshold.hodgeLaplacian up down) x,
            (HodgeSpectralThreshold.hodgeLaplacian up down) x⟫_ℝ
        ≤ lam * ⟪x, (HodgeSpectralThreshold.hodgeLaplacian up down) x⟫_ℝ)
    (hρ0 : 0 ≤ 1 - α * μ * (2 - α * lam))
    (hρ1 : 1 - α * μ * (2 - α * lam) < 1)
    (r : E) (n : ℕ) :
    ∑ k ∈ Finset.range n,
        ⟪((mpStep (HodgeSpectralThreshold.hodgeLaplacian up down) α) ^ k) r,
          ((mpStep (HodgeSpectralThreshold.hodgeLaplacian up down) α) ^ k) r⟫_ℝ
      ≤ ⟪r, r⟫_ℝ / (1 - (1 - α * μ * (2 - α * lam))) := by
  apply mpStep_total_energy_bound (HodgeSpectralThreshold.hodgeLaplacian up down) α (1 - α * μ * (2 - α * lam)) hρ0 hρ1 (HodgeMessagePassingConvergence.mpStep_contraction (HodgeSpectralThreshold.hodgeLaplacian up down) α μ lam hα hstep hlower hupper) r n

end HodgeMessagePassingEnergy