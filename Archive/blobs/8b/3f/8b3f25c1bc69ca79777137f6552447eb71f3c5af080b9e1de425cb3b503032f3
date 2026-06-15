import Mathlib

/-!
# Universal Scaling of Minimal PDE-Solver Size at a Spectral Phase Transition

This file formalizes the (empirical, ML-flavored) conjecture that the *minimal
neural-operator / iterative-solver size* diverges as a universal power law near an
operator-spectrum phase transition.

The central scalar object is the **minimal iteration / depth count**

  `Nmin ρ ε = least n with ρ^n ≤ ε`,

the shadow of how many Neumann / power-iteration terms (equivalently, how much
polynomial depth) a solver needs to invert a discretized solution operator with
contraction factor `ρ = 1 - g`, where `g` is the spectral gap.

The headline result `Nmin_sandwich` is a two-sided power law

  `(1 - ε)/g ≤ Nmin (1-g) ε ≤ log(1/ε)/g + 1`,

so the size diverges as `g⁻¹` with a class-universal exponent and an
`ε`-dependent prefactor band `[1-ε, log(1/ε)]`. The "critical exponent" content
collapses onto two elementary inequalities:

* Bernoulli `1 - n·g ≤ (1-g)^n` (which *forces* divergence), and
* `1 - g ≤ e^{-g}` (which *controls* it).

-- !-- Lab Notebook -- !--
Hypothesis: minimal solver depth `Nmin (1-g) ε` scales like a universal power
  law `g^{-ν}` near a spectral phase transition, with the critical exponent `ν`
  independent of microscopic details and halved by polynomial acceleration.
Result: proved a sharp two-sided sandwich `(1-ε)/g ≤ Nmin (1-g) ε ≤ log(1/ε)/g+1`
  (`Nmin_sandwich`); derived the accelerated (`g ↦ √g`) version, the
  control-parameter power laws `D^{-α}` / `D^{-α/2}`, the exponent separation
  `α/2 < α`, and discretization independence (the constant `c` only moves the
  prefactor).
Insight: the *entire* power-law content is two scalar inequalities — Bernoulli
  for the floor, `1-g ≤ e^{-g}` for the ceiling — so the divergence exponent is
  a pure consequence of convexity of `exp`, not of any spectral detail.
Failure analysis: the prefactor band `[1-ε, log(1/ε)]` is not yet collapsed to a
  single constant; closing it to an asymptotic equivalence (see FUTURE_DIRECTIONS
  §1) needs the `log(1-g)` power series and a `Filter.Tendsto` statement.
-- !-- end -- !--
-/

namespace SpectralPhaseTransition

open Real

/-- The set of depths sufficient to reach target error `ε` at contraction `ρ`. -/
def reachSet (ρ ε : ℝ) : Set ℕ := {n : ℕ | ρ ^ n ≤ ε}

/-- Minimal iteration / depth count: the least `n` with `ρ^n ≤ ε`. -/
noncomputable def Nmin (ρ ε : ℝ) : ℕ := sInf (reachSet ρ ε)

/-
!-- The reach set is nonempty: `ρ^n → 0` for `ρ < 1`, so some power drops below `ε > 0`. -- !--
-/
lemma reachSet_nonempty {ρ ε : ℝ} (hρ : ρ < 1) (hε : 0 < ε) :
    (reachSet ρ ε).Nonempty := by
  by_contra h;
  simp_all +decide [ Set.Nonempty ];
  -- Since $\rho < 1$, we have $\lim_{n \to \infty} \rho^n = 0$.
  have h_lim : Filter.Tendsto (fun n : ℕ => ρ ^ n) Filter.atTop (nhds 0) := by
    norm_num [ reachSet ] at h;
    exact tendsto_pow_atTop_nhds_zero_of_lt_one ( show 0 ≤ ρ by have := h 1; norm_num at this; linarith ) hρ;
  exact absurd ( h_lim.eventually ( gt_mem_nhds hε ) ) fun H => by obtain ⟨ n, hn ⟩ := H.exists; exact h n hn.le;

/-
!-- `Nmin` lies in the reach set (ℕ is well-ordered, so the infimum is attained). -- !--
-/
lemma Nmin_mem {ρ ε : ℝ} (hρ : ρ < 1) (hε : 0 < ε) :
    ρ ^ (Nmin ρ ε) ≤ ε := by
  exact Nat.sInf_mem ( reachSet_nonempty hρ hε )

/-
!-- Any admissible depth dominates `Nmin` (infimum is a lower bound). -- !--
-/
lemma Nmin_le {ρ ε : ℝ} {n : ℕ} (h : ρ ^ n ≤ ε) : Nmin ρ ε ≤ n := by
  apply Nat.sInf_le; exact h

/-
**Headline two-sided power law.**
For spectral gap `g ∈ (0,1)` and target error `ε ∈ (0,1)`, the minimal solver
depth obeys `(1-ε)/g ≤ Nmin (1-g) ε ≤ log(1/ε)/g + 1`, i.e. it diverges as
`g⁻¹` with a class-universal exponent.

!-- Floor: Bernoulli `1 - N g ≤ (1-g)^N ≤ ε`. Ceiling: `n₀ = ⌊log(1/ε)/g⌋+1`
satisfies `(1-g)^{n₀} ≤ e^{-n₀ g} ≤ ε`, so `Nmin ≤ n₀ ≤ log(1/ε)/g + 1`. -- !--
-/
theorem Nmin_sandwich {g ε : ℝ} (hg0 : 0 < g) (hg1 : g < 1)
    (hε0 : 0 < ε) (hε1 : ε < 1) :
    (1 - ε) / g ≤ (Nmin (1 - g) ε : ℝ) ∧
      (Nmin (1 - g) ε : ℝ) ≤ Real.log (1 / ε) / g + 1 := by
  constructor;
  · -- By Bernoulli's inequality, we have $(1 - g)^{Nmin} \geq 1 - Nmin \cdot g$.
    have h_bernoulli : (1 - g) ^ (Nmin (1 - g) ε) ≥ 1 - (Nmin (1 - g) ε) * g := by
      exact le_trans ( by norm_num ) ( one_add_mul_le_pow ( by linarith ) _ );
    rw [ div_le_iff₀ hg0 ] ; linarith [ show ( 1 - g ) ^ Nmin ( 1 - g ) ε ≤ ε from Nmin_mem ( by linarith ) ( by linarith ) ] ;
  · -- Let $n₀ = \lfloor \frac{\log(1/\epsilon)}{g} \rfloor + 1$. We need to show that $(1-g)^{n₀} \leq \epsilon$.
    set n₀ := Nat.floor ((Real.log (1 / ε)) / g) + 1 with hn₀
    have h_n₀ : (1 - g) ^ n₀ ≤ ε := by
      -- Since $1 - g \leq \exp(-g)$, we have $(1 - g)^{n₀} \leq \exp(-g \cdot n₀)$.
      have h_exp : (1 - g) ^ n₀ ≤ Real.exp (-g * n₀) := by
        rw [ ← Real.rpow_natCast, Real.rpow_def_of_pos ( by linarith ) ] ; norm_num ; ring_nf;
        nlinarith [ Real.log_le_sub_one_of_pos ( by linarith : 0 < 1 - g ) ];
      -- Since $n₀ \geq \frac{\log(1/\epsilon)}{g}$, we have $-g \cdot n₀ \leq -\log(1/\epsilon)$.
      have h_neg_g_n₀ : -g * n₀ ≤ -Real.log (1 / ε) := by
        simp +zetaDelta at *;
        nlinarith [ Nat.lt_floor_add_one ( -Real.log ε / g ), mul_div_cancel₀ ( -Real.log ε ) hg0.ne' ];
      exact h_exp.trans ( Real.exp_le_exp.mpr h_neg_g_n₀ |> le_trans <| by norm_num [ Real.exp_neg, Real.exp_log, hε0, hε1 ] );
    -- Since $n₀ = \lfloor \frac{\log(1/\epsilon)}{g} \rfloor + 1$, we have $Nmin (1 - g) ε \leq n₀$.
    have h_Nmin_le_n₀ : Nmin (1 - g) ε ≤ n₀ := by
      exact Nat.sInf_le h_n₀;
    exact le_trans ( Nat.cast_le.mpr h_Nmin_le_n₀ ) ( by push_cast [ hn₀ ] ; linarith [ Nat.floor_le ( show 0 ≤ Real.log ( 1 / ε ) / g by exact div_nonneg ( Real.log_nonneg ( by rw [ le_div_iff₀ hε0 ] ; linarith ) ) hg0.le ) ] )

/-
**Accelerated (square-root) law.** Feeding the accelerated contraction
`1 - √g` (Chebyshev / conjugate-gradient acceleration) replaces `g` by `√g`,
halving the divergence exponent to `1/2`.

!-- Direct instantiation of `Nmin_sandwich` at the gap `√g ∈ (0,1)`. -- !--
-/
theorem Nmin_sandwich_accelerated {g ε : ℝ} (hg0 : 0 < g) (hg1 : g < 1)
    (hε0 : 0 < ε) (hε1 : ε < 1) :
    (1 - ε) / Real.sqrt g ≤ (Nmin (1 - Real.sqrt g) ε : ℝ) ∧
      (Nmin (1 - Real.sqrt g) ε : ℝ) ≤ Real.log (1 / ε) / Real.sqrt g + 1 := by
  apply Nmin_sandwich (Real.sqrt_pos.mpr hg0) (by
  rw [ Real.sqrt_lt' ] <;> linarith) hε0 hε1

/-
**Control-parameter power law (unaccelerated).** With the gap closing as
`g = D^α` in the control parameter `D = |λ - λc|`, the depth diverges as
`D^{-α}`: critical exponent `ν = α`.

!-- Apply `Nmin_sandwich` at `g = D^α ∈ (0,1)` and rewrite `1/D^α = D^(-α)`. -- !--
-/
theorem power_law_control {D α ε : ℝ} (hD0 : 0 < D) (hD1 : D < 1)
    (hα : 0 < α) (hε0 : 0 < ε) (hε1 : ε < 1) :
    (1 - ε) * D ^ (-α) ≤ (Nmin (1 - D ^ α) ε : ℝ) ∧
      (Nmin (1 - D ^ α) ε : ℝ) ≤ Real.log (1 / ε) * D ^ (-α) + 1 := by
  convert Nmin_sandwich ( show 0 < D ^ α by positivity ) ( show D ^ α < 1 by exact Real.rpow_lt_one hD0.le hD1 hα ) ( show 0 < ε by positivity ) ( show ε < 1 by linarith ) using 2;
  · rw [ div_eq_mul_inv, Real.rpow_neg hD0.le ];
  · rw [ Real.rpow_neg hD0.le, one_div ] ; ring

/-
**Control-parameter power law (accelerated).** Acceleration replaces `α` by
`α/2`, so the depth diverges as `D^{-α/2}`: critical exponent `ν = α/2`.

!-- Same as `power_law_control` with `α ↦ α/2` (the gap is `D^(α/2) = √(D^α)`). -- !--
-/
theorem power_law_control_accelerated {D α ε : ℝ} (hD0 : 0 < D) (hD1 : D < 1)
    (hα : 0 < α) (hε0 : 0 < ε) (hε1 : ε < 1) :
    (1 - ε) * D ^ (-(α / 2)) ≤ (Nmin (1 - D ^ (α / 2)) ε : ℝ) ∧
      (Nmin (1 - D ^ (α / 2)) ε : ℝ) ≤ Real.log (1 / ε) * D ^ (-(α / 2)) + 1 := by
  convert power_law_control hD0 hD1 ( half_pos hα ) hε0 hε1 using 1

/-
**The two universality classes are distinct.** The accelerated exponent is
strictly smaller than the unaccelerated one.
-/
theorem accelerated_exponent_lt {α : ℝ} (hα : 0 < α) : α / 2 < α := by
  linarith

/-
**Discretization independence (renormalization).** Replacing the gap by
`c · D^α` for any microscopic constant `c ∈ (0,1]` leaves the divergence exponent
equal to `α`; only the prefactor (here `1/c`) moves.

!-- Apply `Nmin_sandwich` at `g = c·D^α ∈ (0,1)` and factor `1/(c D^α) = (1/c) D^(-α)`. -- !--
-/
theorem power_law_discretization_independent {c D α ε : ℝ}
    (hc0 : 0 < c) (hc1 : c ≤ 1) (hD0 : 0 < D) (hD1 : D < 1)
    (hα : 0 < α) (hε0 : 0 < ε) (hε1 : ε < 1) :
    (1 - ε) / c * D ^ (-α) ≤ (Nmin (1 - c * D ^ α) ε : ℝ) ∧
      (Nmin (1 - c * D ^ α) ε : ℝ) ≤ Real.log (1 / ε) / c * D ^ (-α) + 1 := by
  have := Nmin_sandwich ( show 0 < c * D ^ α by positivity ) ( show c * D ^ α < 1 by exact lt_of_le_of_lt ( mul_le_of_le_one_left ( by positivity ) hc1 ) ( by exact Real.rpow_lt_one hD0.le hD1 hα ) ) hε0 hε1 ; simp_all +decide [ Real.rpow_neg hD0.le ] ;
  convert this using 2 <;> ring

/-! ## Computable rational analogue

A fueled rational search makes the `g⁻¹` divergence concrete:
shrinking the gap tenfold (`ρ = 0.9 → 0.99`) grows the count roughly tenfold. -/

/-- Fueled search for the least `n` with `ρ^n ≤ ε` over the rationals. -/
def NminQaux (ρ ε : ℚ) : ℕ → ℕ → ℕ
  | 0, n => n
  | (fuel + 1), n => if ρ ^ n ≤ ε then n else NminQaux ρ ε fuel (n + 1)

/-- Computable rational analogue of `Nmin`. -/
def NminQ (ρ ε : ℚ) : ℕ := NminQaux ρ ε 4000 0

-- `ρ = 0.9` reaches `ε = 0.01` in 44 steps; `ρ = 0.99` needs 459 — the gap
-- shrinks tenfold, the count grows ≈ tenfold, numerically confirming the `g⁻¹` law.
#eval NminQ (9/10) (1/100)    -- 44
#eval NminQ (99/100) (1/100)  -- 459

end SpectralPhaseTransition