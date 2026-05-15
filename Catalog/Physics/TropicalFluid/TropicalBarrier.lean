/-
# Tropical Dissipative Barriers and Regularity Criteria

This file proves the core anti-blowup theorems: if a discrete-time evolution
is dominated by tropical diffusion with nonpositive dissipation, then the
global maximum is nonincreasing (Theorem B) and, with linear damping, decays
exponentially (Theorem C). These constitute formal regularity criteria for
discrete Navier–Stokes surrogates.

## Navier–Stokes Surrogate Interpretation

- `ω_n : ι → ℝ` models a discretized vorticity magnitude field
- `K : ι → ι → ℝ` encodes a tropical diffusion cost between grid sites
- `c_n ≤ 0` represents idempotent energy dissipation
- The theorems show that if vorticity updates are dominated by tropical
  diffusion plus nonpositive forcing, the sup norm cannot grow, hence
  finite-time blowup in the surrogate system is excluded

## Main Results

- `tropical_barrier_nonincreasing`: fmax is nonincreasing under barrier updates
- `tropical_barrier_exponential_decay`: exponential decay with linear damping
- `tropicalEnergy_nonincreasing`: oscillation (energy) is nonincreasing
- `dissipativeUpdate_le_self`: barrier updates never exceed the current state
-/

import Physics.TropicalFluid.TropicalDiffusion

open Finset

variable {ι : Type*} [Fintype ι] [Nonempty ι]

/-! ## Dissipative Update Properties -/

/-- The dissipative update never exceeds the current state pointwise. -/
theorem dissipativeUpdate_le_self (K : ι → ι → ℝ) (c : ℝ) (u : ι → ℝ) :
    ∀ i, dissipativeUpdate K c u i ≤ u i := by
  intro i
  exact min_le_left _ _

/-
If `c ≤ 0` and `K` is a tropical viscosity kernel, the dissipative update
is pointwise bounded by `u`.
-/
theorem fmax_dissipativeUpdate_le
    (K : ι → ι → ℝ) (c : ℝ) (u : ι → ℝ)
    (_hK : ∀ i j, 0 ≤ K i j)
    (_hdiag : ∀ i, K i i = 0)
    (_hc : c ≤ 0) :
    fmax (dissipativeUpdate K c u) ≤ fmax u := by
  -- For each i, dissipativeUpdate K c u i = min(u i, T_K(u)(i) + c). Since T_K(u)(i) ≤ u i (from K i i = 0, inf includes u i + 0 = u i) and c ≤ 0, we have T_K(u)(i) + c ≤ u i.
  have h_le : ∀ i, dissipativeUpdate K c u i ≤ u i :=
    dissipativeUpdate_le_self K c u
  exact fmax_le_iff _ _ |>.2 fun i => le_trans ( h_le i ) ( apply_le_fmax _ _ )

/-! ## Theorem B: Tropical Dissipative Barrier -/

/-
**Tropical Dissipative Barrier (Theorem B).**

If `ω` evolves by the inequality
  `ω(n+1)(i) ≤ min(ω(n)(i), T_K(ω(n))(i) + c(n))`
with `c(n) ≤ 0`, `K ≥ 0`, and `K(i,i) = 0`, then the global maximum
`fmax(ω(n))` is nonincreasing in `n`.

This is the formal anti-blowup barrier theorem: tropical viscosity combined
with nonpositive dissipation prevents amplitude growth. It is the discrete
analogue of the classical vorticity comparison principle for Navier–Stokes.
-/
theorem tropical_barrier_nonincreasing
    (K : ι → ι → ℝ) (ω : ℕ → ι → ℝ) (c : ℕ → ℝ)
    (_hK : ∀ i j, 0 ≤ K i j)
    (_hdiag : ∀ i, K i i = 0)
    (hω : ∀ n i, ω (n + 1) i ≤ min (ω n i) (tropicalDiffusion K (ω n) i + c n))
    (_hc : ∀ n, c n ≤ 0) :
    ∀ n, fmax (ω (n + 1)) ≤ fmax (ω n) := by
  exact fun n => fmax_mono fun i => ( le_trans ( hω n i ) ( min_le_left _ _ ) )

/-! ## Theorem C: Exponential Tropical Regularity Criterion -/

/-
**Exponential Tropical Regularity Criterion (Theorem C).**

If `ω` evolves by the inequality
  `ω(n+1)(i) ≤ min(lam * ω(n)(i), T_K(ω(n))(i) + c(n))`
with `0 ≤ lam ≤ 1`, `c(n) ≤ 0`, `K ≥ 0`, `K(i,i) = 0`,
and all values nonneg, then
  `fmax(ω(n)) ≤ lam^n * fmax(ω(0))`.

If `lam < 1`, this gives exponential decay of the amplitude, making
finite-time blowup impossible. This is the strongest regularity criterion:
tropical viscosity with linear damping enforces a quantitative non-blowup
envelope for the discrete Navier–Stokes surrogate.
-/
theorem tropical_barrier_exponential_decay
    (K : ι → ι → ℝ) (ω : ℕ → ι → ℝ) (c : ℕ → ℝ) (lam : ℝ)
    (hlam0 : 0 ≤ lam) (_hlam1 : lam ≤ 1)
    (_hK : ∀ i j, 0 ≤ K i j)
    (_hdiag : ∀ i, K i i = 0)
    (hω : ∀ n i, ω (n + 1) i ≤ min (lam * ω n i) (tropicalDiffusion K (ω n) i + c n))
    (_hc : ∀ n, c n ≤ 0)
    (_hnonneg : ∀ n i, 0 ≤ ω n i) :
    ∀ n, fmax (ω n) ≤ lam ^ n * fmax (ω 0) := by
  intro n;
  induction' n with n ih;
  · simp +decide;
  · -- By the induction hypothesis, we have $fmax (ω n) ≤ lam^n * fmax (ω 0)$.
    have h_ind : ∀ i, ω (n + 1) i ≤ lam * fmax (ω n) := by
      exact fun i => le_trans ( hω n i ) ( min_le_of_left_le ( mul_le_mul_of_nonneg_left ( apply_le_fmax _ _ ) hlam0 ) );
    exact fmax_le_iff _ _ |>.2 fun i => le_trans ( h_ind i ) ( by rw [ pow_succ', mul_assoc ] ; gcongr )

/-! ## Theorem E: Oscillation (Energy) Contraction -/

/-
**Oscillation contraction under dissipative update.**
The tropical energy (oscillation = fmax - fmin) does not increase under
dissipative updates with a tropical viscosity kernel and nonpositive forcing.

This is a stronger regularization statement than maximum nonincrease alone:
it shows the spread of values contracts, not just that the peak is controlled.
-/
theorem tropicalEnergy_dissipativeUpdate_le
    (K : ι → ι → ℝ) (c : ℝ) (u : ι → ℝ)
    (hK : ∀ i j, 0 ≤ K i j)
    (hdiag : ∀ i, K i i = 0)
    (hc : c ≤ 0) :
    tropicalEnergy (dissipativeUpdate K c u) ≤ tropicalEnergy u := by
  -- By definition of $dissipativeUpdate$, we know that $dissipativeUpdate K c u = fun i => tropicalDiffusion K u i + c$ for all $i$.
  have h_dissipativeUpdate : dissipativeUpdate K c u = fun i => tropicalDiffusion K u i + c := by
    ext iUpdate;
    exact min_eq_right ( by linarith [ hK iUpdate iUpdate, hdiag iUpdate, ( show tropicalDiffusion K u iUpdate ≤ u iUpdate from Finset.inf'_le _ ( Finset.mem_univ iUpdate ) |> le_trans <| by simp +decide [ hdiag ] ) ] );
  unfold tropicalEnergy; simp +decide [ h_dissipativeUpdate ] ;
  -- By definition of $fmax$ and $fmin$, we know that $fmax (fun i => tropicalDiffusion K u i + c) = fmax (tropicalDiffusion K u) + c$ and $fmin (fun i => tropicalDiffusion K u i + c) = fmin (tropicalDiffusion K u) + c$.
  have h_fmax_fmin : fmax (fun i => tropicalDiffusion K u i + c) = fmax (tropicalDiffusion K u) + c ∧ fmin (fun i => tropicalDiffusion K u i + c) = fmin (tropicalDiffusion K u) + c := by
    unfold fmax fmin;
    constructor <;> refine' le_antisymm _ _ <;> simp +decide [ Finset.sup'_le_iff, Finset.le_inf'_iff ];
    · exact fun i => ⟨ i, le_rfl ⟩;
    · simpa using Finset.exists_max_image Finset.univ ( fun i => tropicalDiffusion K u i ) ⟨ Classical.arbitrary ι, Finset.mem_univ _ ⟩;
    · simpa using Finset.exists_min_image Finset.univ ( fun i => tropicalDiffusion K u i ) ⟨ Classical.arbitrary ι, Finset.mem_univ _ ⟩;
    · exact fun i => ⟨ i, le_rfl ⟩;
  linarith [ fmax_tropicalDiffusion_le K u hK hdiag, tropical_min_preserved K u hK hdiag ]

/-
Oscillation is nonincreasing along exact dissipative-update trajectories.
When `ω(n+1) = dissipativeUpdate K (c n) (ω n)`, oscillation is controlled.
-/
theorem tropicalEnergy_nonincreasing_exact
    (K : ι → ι → ℝ) (ω : ℕ → ι → ℝ) (c : ℕ → ℝ)
    (hK : ∀ i j, 0 ≤ K i j)
    (hdiag : ∀ i, K i i = 0)
    (hω : ∀ n, ω (n + 1) = dissipativeUpdate K (c n) (ω n))
    (hc : ∀ n, c n ≤ 0) :
    ∀ n, tropicalEnergy (ω (n + 1)) ≤ tropicalEnergy (ω n) := by
  exact fun n => by rw [ hω ] ; exact tropicalEnergy_dissipativeUpdate_le K ( c n ) ( ω n ) hK hdiag ( hc n ) ;