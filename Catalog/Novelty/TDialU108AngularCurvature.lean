import Mathlib

/-!
# U108 in the angle coordinate: angular curvature cannot rescue a monotone fade

## Research context

Third cycle of the `TDIAL-U108-CONTINUES-FADE` thread, extending
`Catalog.Physics.TDialU108BandLoss` (the ladder `rho`, the plateau localisation theorem
`plateau_of_geometric_deceleration`, and `ladder_not_antitone`) and
`Catalog.Physics.TDialU108Deepening` (the correlation angle `corrAngle = arccos` and its
triangle inequality).  This file is self-contained (it imports only `Mathlib`); the real ladder
`measuredRho` below is the real cast of `Catalog.Physics.TDialU108.rho`, and `arccos` is
`corrAngle`.

The proposed replacement for the falsified monotone model was a *curvature* model: the angle
`θₙ = arccos ρₙ` is concave (`θₙ₊₂ − 2θₙ₊₁ + θₙ ≤ 0`) from bitlen 108 on.

## Findings

1. **The conjecture is a theorem** (`angular_deceleration_no_reentry`): angular concavity from
   index 3 forces `θ` to converge with limit `≥ arccos 0.488`, and `ρₙ ≤ 0.488 < 0.55` for all
   `n ≥ 3`.  The mechanism (`concave_bddBelow_monotone`) is that a concave sequence bounded
   below cannot take a single downward step.
2. **But the model class collapses** (`angular_concave_imp_antitone`): for genuine correlations
   angular concavity *implies* antitonicity of `ρ`.  The curvature model is a sub-class of the
   falsified monotone model, not a relaxation of it.
3. **Hence the data refute it** (`no_concave_angle_model`, `no_convex_angle_model`): no sequence
   matching the seven rungs is angularly concave from any index `≤ 4`, or angularly convex from
   any index `≤ 5`.  The second differences alternate in sign in *both* coordinates
   (`measured_rho_curvature_alternates`, `measured_angle_curvature_alternates`); the 108-window
   is locally concave in angle, but the 112-window is convex with excess `> 0.079`
   (`measured_convexity_excess_at_112`).  By contrast, each parity sub-ladder (even rungs,
   odd rungs) is monotone and angularly concave (`parity_subladders_monotone_concave`).
4. **Concavity plus the rebound forces re-entry** (`concave_rebound_forces_reentry`): a model
   reproducing the 112 and 116 rungs and angularly concave on four further windows must read
   `ρ > 0.55` at bitlen 132; and it cannot stay concave for 62 windows at all
   (`concave_rebound_lifetime`).
5. **Plateau localisation in angle** (`angle_plateau`, `u108_angle_plateau_window`): the guarded
   form of the band-loss claim — for nondecreasing angles with deceleration ratio `≤ 1/2` the
   limiting angle lies in `[arccos 0.488, arccos 0.488 + 0.0595]`, outside the `0.55` cap.

Quantitative angle increments are certified by a mean-value sandwich
(`arccos_sub_sandwich`): `(b−a)/√(1−a²) ≤ arccos a − arccos b ≤ (b−a)/√(1−b²)` for `0 ≤ a < b < 1`.
-/

namespace Catalog.Novelty.TDialU108Angular

open Real Set Filter

/-! ## Section 1. Discrete concavity -/

/-- Discrete concavity ("angular deceleration") of a real sequence from index `N` on. -/
def SecondDiffNonpos (s : ℕ → ℝ) (N : ℕ) : Prop :=
  ∀ n, N ≤ n → s (n + 2) - 2 * s (n + 1) + s n ≤ 0

/-- Windowed version: the second differences based at `m, m+1, …` are nonpositive as long as the
three points stay within `m + K`. -/
theorem steps_le_first_window (s : ℕ → ℝ) (m K : ℕ)
    (h : ∀ j, j + 2 ≤ K → s (m + j + 2) - 2 * s (m + j + 1) + s (m + j) ≤ 0) :
    ∀ j, j + 1 ≤ K → s (m + j + 1) - s (m + j) ≤ s (m + 1) - s m := by
  intro j
  induction j with
  | zero => intro _; simp
  | succ j ih =>
      intro hj
      have h1 := ih (by omega)
      have h2 := h j (by omega)
      have e1 : m + (j + 1) + 1 = m + j + 2 := by omega
      have e2 : m + (j + 1) = m + j + 1 := by omega
      rw [e1, e2]
      linarith

/-- Windowed linear upper bound: a concave stretch stays below its initial chord line. -/
theorem le_chord_window (s : ℕ → ℝ) (m K : ℕ)
    (h : ∀ j, j + 2 ≤ K → s (m + j + 2) - 2 * s (m + j + 1) + s (m + j) ≤ 0) :
    ∀ k, k ≤ K → s (m + k) ≤ s m + k * (s (m + 1) - s m) := by
  have hst := steps_le_first_window s m K h
  intro k
  induction k with
  | zero => intro _; simp
  | succ k ih =>
      intro hk
      have h1 := ih (by omega)
      have h2 := hst k (by omega)
      have e : m + (k + 1) = m + k + 1 := by omega
      rw [e]
      push_cast
      linarith

/-- Unbounded-horizon chord bound for a sequence that is concave from `N`. -/
theorem le_chord (s : ℕ → ℝ) (N : ℕ) (hc : SecondDiffNonpos s N) (m : ℕ) (hm : N ≤ m) (k : ℕ) :
    s (m + k) ≤ s m + k * (s (m + 1) - s m) :=
  le_chord_window s m k (fun j _ => hc (m + j) (by omega)) k le_rfl

/-- **Bounded concave sequences are monotone.**  A sequence that is concave from `N` on and
bounded below can never take a downward step after `N`: a single downward step would, by
concavity, be repeated forever and drive the sequence to `-∞`. -/
theorem concave_bddBelow_monotone (s : ℕ → ℝ) (N : ℕ) (B : ℝ) (hc : SecondDiffNonpos s N)
    (hB : ∀ n, B ≤ s n) : ∀ n, N ≤ n → s n ≤ s (n + 1) := by
  intro n hn
  by_contra hlt
  push_neg at hlt
  have hd : 0 < s n - s (n + 1) := by linarith
  obtain ⟨k, hk⟩ := exists_nat_gt ((s n - B) / (s n - s (n + 1)))
  have h1 := le_chord s N hc n hn k
  have h2 := hB (n + k)
  rw [div_lt_iff₀ hd] at hk
  nlinarith

/-- **Bounded concave sequences converge**, and their limit dominates every term after `N`. -/
theorem concave_bdd_tendsto (s : ℕ → ℝ) (N : ℕ) (B C : ℝ) (hc : SecondDiffNonpos s N)
    (hB : ∀ n, B ≤ s n) (hC : ∀ n, s n ≤ C) :
    ∃ L, Tendsto s atTop (nhds L) ∧ ∀ n, N ≤ n → s n ≤ L := by
  have hmono := concave_bddBelow_monotone s N B hc hB
  set t : ℕ → ℝ := fun k => s (k + N) with ht
  have tmono : Monotone t := by
    refine monotone_nat_of_le_succ fun k => ?_
    have := hmono (k + N) (by omega)
    simpa [ht, Nat.add_right_comm] using this
  have tbdd : BddAbove (Set.range t) := ⟨C, by rintro _ ⟨k, rfl⟩; exact hC _⟩
  refine ⟨⨆ k, t k, ?_, fun n hn => ?_⟩
  · exact (tendsto_add_atTop_iff_nat N).1 (tendsto_atTop_ciSup tmono tbdd)
  · have := le_ciSup tbdd (n - N)
    simpa [ht, Nat.sub_add_cancel hn] using this

/-! ## Section 2. The angle coordinate -/

/-- If the angle of `x` is at least the angle of a correlation `a ∈ [-1, 1)`, then `x ≤ a`.
No range assumption on `x` is needed. -/
theorem le_of_arccos_le_arccos {x a : ℝ} (ha1 : -1 ≤ a) (ha2 : a < 1)
    (h : arccos a ≤ arccos x) : x ≤ a := by
  by_contra hxa
  push_neg at hxa
  rcases le_or_gt x 1 with hx1 | hx1
  · exact absurd h (not_le.2 (Real.arccos_lt_arccos ha1 hxa hx1))
  · have h0 : arccos x = 0 := Real.arccos_eq_zero.2 hx1.le
    have hpos : 0 < arccos a := Real.arccos_pos.2 ha2
    linarith

/-- **The angular deceleration conjecture (proved).**  If `θₙ = arccos ρₙ` is concave from
index `3` (bitlen 108) on, and `ρ₃ = 0.488`, then `θ` converges, its limit is at least
`arccos 0.488`, and every later reading satisfies `ρₙ ≤ 0.488 < 0.55`: there is no re-entry into
the `0.55` spherical cap.  No range hypothesis on `ρ` is needed. -/
theorem angular_deceleration_no_reentry (ρ : ℕ → ℝ)
    (hc : SecondDiffNonpos (fun n => arccos (ρ n)) 3) (h3 : ρ 3 = 0.488) :
    ∃ L, Tendsto (fun n => arccos (ρ n)) atTop (nhds L) ∧ arccos 0.488 ≤ L ∧
      ∀ n, 3 ≤ n → ρ n ≤ 0.488 ∧ ρ n < 0.55 := by
  obtain ⟨L, hL, hle⟩ := concave_bdd_tendsto (fun n => arccos (ρ n)) 3 0 π hc
    (fun n => Real.arccos_nonneg _) (fun n => Real.arccos_le_pi _)
  have hmono := concave_bddBelow_monotone (fun n => arccos (ρ n)) 3 0 hc
    (fun n => Real.arccos_nonneg _)
  have hge : ∀ n, 3 ≤ n → arccos (ρ 3) ≤ arccos (ρ n) := by
    intro n hn
    induction n, hn using Nat.le_induction with
    | base => exact le_rfl
    | succ k hk ih => exact ih.trans (hmono k hk)
  refine ⟨L, hL, by simpa [h3] using hle 3 le_rfl, fun n hn => ?_⟩
  have h := hge n hn
  rw [h3] at h
  have hle' : ρ n ≤ 0.488 := le_of_arccos_le_arccos (by norm_num) (by norm_num) h
  exact ⟨hle', by linarith⟩

/-- **The angular class collapses onto the antitone class.**  For genuine correlations
(`ρₙ ∈ [-1, 1]`), angular concavity from `N` on forces `ρ` itself to be antitone from `N` on.
So the curvature model is *not* a relaxation of the falsified monotone model: it is contained in
it. -/
theorem angular_concave_imp_antitone (ρ : ℕ → ℝ) (N : ℕ)
    (hc : SecondDiffNonpos (fun n => arccos (ρ n)) N) (hρ : ∀ n, -1 ≤ ρ n ∧ ρ n ≤ 1) :
    ∀ n, N ≤ n → ρ (n + 1) ≤ ρ n := by
  intro n hn
  have h := concave_bddBelow_monotone (fun n => arccos (ρ n)) N 0 hc
    (fun n => Real.arccos_nonneg _) n hn
  rcases lt_or_eq_of_le (hρ n).2 with hlt | heq
  · exact le_of_arccos_le_arccos (hρ n).1 hlt h
  · rw [heq]; exact (hρ (n + 1)).2

/-- **A rebound is fatal to angular concavity.**  If a sequence of correlations rebounds
(`ρ m < ρ (m+1)`, both in `[-1,1]`) at some index `m ≥ N`, then `arccos ∘ ρ` is not concave
from `N` on. -/
theorem rebound_refutes_angular_concavity (ρ : ℕ → ℝ) (N m : ℕ) (hm : N ≤ m)
    (h1 : -1 ≤ ρ m) (hup : ρ m < ρ (m + 1)) (h2 : ρ (m + 1) ≤ 1) :
    ¬ SecondDiffNonpos (fun n => arccos (ρ n)) N := by
  intro hc
  have h := concave_bddBelow_monotone (fun n => arccos (ρ n)) N 0 hc
    (fun n => Real.arccos_nonneg _) m hm
  have := Real.arccos_lt_arccos h1 hup h2
  simp only at h
  linarith

/-! ## Section 3. Quantitative two-sided bounds for angle increments -/

/-- **Mean-value sandwich for the correlation angle.**  For `0 ≤ a < b < 1`, the angle gained by
lowering the correlation from `b` to `a` lies between `(b-a)/√(1-a²)` and `(b-a)/√(1-b²)`. -/
theorem arccos_sub_sandwich {a b : ℝ} (ha : 0 ≤ a) (hab : a < b) (hb : b < 1) :
    (b - a) / √(1 - a ^ 2) ≤ arccos a - arccos b ∧
      arccos a - arccos b ≤ (b - a) / √(1 - b ^ 2) := by
  obtain ⟨c, ⟨hac, hcb⟩, hc⟩ := exists_hasDerivAt_eq_slope arccos
    (fun x => -(1 / √(1 - x ^ 2))) hab Real.continuous_arccos.continuousOn
    (fun x hx => Real.hasDerivAt_arccos (by linarith [hx.1]) (by linarith [hx.2]))
  have hba : 0 < b - a := by linarith
  have heq : arccos a - arccos b = (b - a) * (1 / √(1 - c ^ 2)) := by
    field_simp at hc ⊢
    linarith
  have hsa : 0 < 1 - a ^ 2 := by nlinarith
  have hsb : 0 < 1 - b ^ 2 := by nlinarith
  have hsc : 0 < 1 - c ^ 2 := by nlinarith
  have hca : √(1 - c ^ 2) ≤ √(1 - a ^ 2) := Real.sqrt_le_sqrt (by nlinarith)
  have hcb' : √(1 - b ^ 2) ≤ √(1 - c ^ 2) := Real.sqrt_le_sqrt (by nlinarith)
  have pa := Real.sqrt_pos.2 hsa
  have pb := Real.sqrt_pos.2 hsb
  have pc := Real.sqrt_pos.2 hsc
  rw [heq]
  constructor
  · rw [div_eq_mul_one_div]
    exact mul_le_mul_of_nonneg_left (one_div_le_one_div_of_le pc hca) hba.le
  · calc (b - a) * (1 / √(1 - c ^ 2)) ≤ (b - a) * (1 / √(1 - b ^ 2)) :=
          mul_le_mul_of_nonneg_left (one_div_le_one_div_of_le pb hcb') hba.le
      _ = (b - a) / √(1 - b ^ 2) := by ring

/-- Rational-friendly lower bound: if `1 - a² ≤ p²` then `(b-a)/p ≤ arccos a - arccos b`. -/
theorem arccos_sub_ge {a b p : ℝ} (ha : 0 ≤ a) (hab : a < b) (hb : b < 1) (hp : 0 < p)
    (hp2 : 1 - a ^ 2 ≤ p ^ 2) : (b - a) / p ≤ arccos a - arccos b := by
  have h := (arccos_sub_sandwich ha hab hb).1
  have hs : √(1 - a ^ 2) ≤ p := by
    rw [show p = √(p ^ 2) from (Real.sqrt_sq hp.le).symm]
    exact Real.sqrt_le_sqrt hp2
  have hsa : 0 < √(1 - a ^ 2) := Real.sqrt_pos.2 (by nlinarith)
  exact le_trans (div_le_div_of_nonneg_left (by linarith) hsa hs) h

/-- Rational-friendly upper bound: if `q² ≤ 1 - b²` then `arccos a - arccos b ≤ (b-a)/q`. -/
theorem arccos_sub_le {a b q : ℝ} (ha : 0 ≤ a) (hab : a < b) (hb : b < 1) (hq : 0 < q)
    (hq2 : q ^ 2 ≤ 1 - b ^ 2) : arccos a - arccos b ≤ (b - a) / q := by
  have h := (arccos_sub_sandwich ha hab hb).2
  have hs : q ≤ √(1 - b ^ 2) := by
    rw [show q = √(q ^ 2) from (Real.sqrt_sq hq.le).symm]
    exact Real.sqrt_le_sqrt hq2
  exact le_trans h (div_le_div_of_nonneg_left (by linarith) hq hs)


/-! ## Section 4. The measured ladder in the angle coordinate -/

/-- The seven measured pooled readings of the `T`-dial ladder as real numbers, indexed by
`bitlen = 96 + 4 * i`; this is the real cast of `Catalog.Physics.TDialU108.rho`. -/
noncomputable def measuredRho : ℕ → ℝ
  | 0 => 0.5739
  | 1 => 0.5436
  | 2 => 0.5005
  | 3 => 0.488
  | 4 => 0.4621
  | 5 => 0.4847
  | 6 => 0.43636
  | _ => 0

/-- The measured correlation angle `θᵢ = arccos ρᵢ`. -/
noncomputable def measuredAngle (i : ℕ) : ℝ := arccos (measuredRho i)

/-- Second difference of a sequence at base index `i`. -/
def secondDiff (s : ℕ → ℝ) (i : ℕ) : ℝ := s (i + 2) - 2 * s (i + 1) + s i

/-- **Raw-coordinate curvature alternates.**  The second differences of the raw ladder have signs
`−, +, −, +, −` on the five windows based at bitlen `96, 100, 104, 108, 112`. -/
theorem measured_rho_curvature_alternates :
    secondDiff measuredRho 0 < 0 ∧ 0 < secondDiff measuredRho 1 ∧
      secondDiff measuredRho 2 < 0 ∧ 0 < secondDiff measuredRho 3 ∧
      secondDiff measuredRho 4 < 0 := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩ <;> norm_num [secondDiff, measuredRho]

/-- **Angular curvature alternates.**  The second differences of the measured angle have signs
`+, −, +, −, +` on the same five windows.  In particular the window based at 108 (rungs
108/112/116) *is* angularly concave — the local compatibility of the 116 rebound with
deceleration — but the very next window (112/116/120) is strictly convex.  The windows based at
96, 100, 104 need the quantitative mean-value bounds of `arccos_sub_ge` / `arccos_sub_le`;
the windows at 108 and 112 follow from the local extremum pattern alone. -/
theorem measured_angle_curvature_alternates :
    0 < secondDiff measuredAngle 0 ∧ secondDiff measuredAngle 1 < 0 ∧
      0 < secondDiff measuredAngle 2 ∧ secondDiff measuredAngle 3 < 0 ∧
      0 < secondDiff measuredAngle 4 := by
  simp only [secondDiff, measuredAngle, measuredRho]
  norm_num
  -- increments, each certified by the mean-value sandwich
  have d10 : arccos 0.5436 - arccos 0.5739 ≤ (0.5739 - 0.5436) / 0.818 :=
    arccos_sub_le (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have d21 : (0.5436 - 0.5005) / 0.866 ≤ arccos 0.5005 - arccos 0.5436 :=
    arccos_sub_ge (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have d32 : arccos 0.488 - arccos 0.5005 ≤ (0.5005 - 0.488) / 0.865 :=
    arccos_sub_le (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have d43 : (0.488 - 0.4621) / 0.887 ≤ arccos 0.4621 - arccos 0.488 :=
    arccos_sub_ge (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have l34 : arccos 0.4621 > arccos 0.488 :=
    Real.arccos_lt_arccos (by norm_num) (by norm_num) (by norm_num)
  have l54 : arccos 0.4621 > arccos 0.4847 :=
    Real.arccos_lt_arccos (by norm_num) (by norm_num) (by norm_num)
  have l56 : arccos 0.43636 > arccos 0.4847 :=
    Real.arccos_lt_arccos (by norm_num) (by norm_num) (by norm_num)
  refine ⟨?_, ?_, ?_, ?_, ?_⟩ <;> norm_num at d10 d21 d32 d43 ⊢ <;> linarith

/-- **Quantitative convexity excess at 112.**  The concave model would require
`θ₁₂₀ ≤ 2θ₁₁₆ − θ₁₁₂`; the measured 120 rung overshoots this concave prediction by more than
`0.079` radians (the computed value is `≈ 0.0801`). -/
theorem measured_convexity_excess_at_112 : 0.079 < secondDiff measuredAngle 4 := by
  simp only [secondDiff, measuredAngle, measuredRho]
  norm_num
  have d65 : (0.4847 - 0.43636) / 0.9 ≤ arccos 0.43636 - arccos 0.4847 :=
    arccos_sub_ge (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have d45 : (0.4847 - 0.4621) / 0.887 ≤ arccos 0.4621 - arccos 0.4847 :=
    arccos_sub_ge (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  norm_num at d65 d45 ⊢
  linarith

/-- **Parity sub-ladders are monotone and angularly concave.**  Split by parity of the rung
index, the even rungs (96, 104, 112, 120) and the odd rungs (100, 108, 116) are each strictly
decreasing in `ρ`, and the angle is concave along each class.  The 116 rebound is therefore
invisible within its own parity class: it is an inter-class (period-8-bit) effect. -/
theorem parity_subladders_monotone_concave :
    (measuredRho 2 < measuredRho 0 ∧ measuredRho 4 < measuredRho 2 ∧
      measuredRho 6 < measuredRho 4 ∧ measuredRho 3 < measuredRho 1 ∧
      measuredRho 5 < measuredRho 3) ∧
    (measuredAngle 4 - 2 * measuredAngle 2 + measuredAngle 0 < 0 ∧
      measuredAngle 6 - 2 * measuredAngle 4 + measuredAngle 2 < 0 ∧
      measuredAngle 5 - 2 * measuredAngle 3 + measuredAngle 1 < 0) := by
  refine ⟨by norm_num [measuredRho], ?_⟩
  simp only [measuredAngle, measuredRho]
  have e20 : (0.5739 - 0.5005) / 0.866 ≤ arccos 0.5005 - arccos 0.5739 :=
    arccos_sub_ge (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have e42u : arccos 0.4621 - arccos 0.5005 ≤ (0.5005 - 0.4621) / 0.865 :=
    arccos_sub_le (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have e42l : (0.5005 - 0.4621) / 0.887 ≤ arccos 0.4621 - arccos 0.5005 :=
    arccos_sub_ge (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have e64 : arccos 0.43636 - arccos 0.4621 ≤ (0.4621 - 0.43636) / 0.886 :=
    arccos_sub_le (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have o31 : (0.5436 - 0.488) / 0.873 ≤ arccos 0.488 - arccos 0.5436 :=
    arccos_sub_ge (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have o53 : arccos 0.4847 - arccos 0.488 ≤ (0.488 - 0.4847) / 0.872 :=
    arccos_sub_le (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  norm_num at e20 e42u e42l e64 o31 o53 ⊢
  refine ⟨?_, ?_, ?_⟩ <;> linarith

/-- **No angularly concave model fits the ladder.**  There is no sequence of correlations that
agrees with the measured ladder on all seven rungs and whose angle is concave from bitlen 108
(index 3) on — nor from any earlier index.  The 116 rebound alone is fatal. -/
theorem no_concave_angle_model (N : ℕ) (hN : N ≤ 4) :
    ¬ ∃ ρ : ℕ → ℝ, (∀ i, i ≤ 6 → ρ i = measuredRho i) ∧
      SecondDiffNonpos (fun n => arccos (ρ n)) N := by
  rintro ⟨ρ, hρ, hc⟩
  have h4 := hρ 4 (by norm_num)
  have h5 := hρ 5 (by norm_num)
  simp only [measuredRho] at h4 h5
  exact rebound_refutes_angular_concavity ρ N 4 hN (by rw [h4]; norm_num)
    (by rw [h4, h5]; norm_num) (by rw [h5]; norm_num) hc

/-- **No angularly convex model fits the ladder either.**  An angle that is convex from `N` on
(and bounded above by `π`) can never increase, i.e. the correlation could never fall; the
120 rung falls below the 116 rung, so no convex angular description exists from any index
`N ≤ 5`. -/
theorem no_convex_angle_model (N : ℕ) (hN : N ≤ 5) :
    ¬ ∃ ρ : ℕ → ℝ, (∀ i, i ≤ 6 → ρ i = measuredRho i) ∧
      ∀ n, N ≤ n → 0 ≤ arccos (ρ (n + 2)) - 2 * arccos (ρ (n + 1)) + arccos (ρ n) := by
  rintro ⟨ρ, hρ, hc⟩
  have hneg : SecondDiffNonpos (fun n => -arccos (ρ n)) N := by
    intro n hn; have := hc n hn; simp only; linarith
  have hmono := concave_bddBelow_monotone (fun n => -arccos (ρ n)) N (-π) hneg
    (fun n => by simp only [neg_le_neg_iff]; exact Real.arccos_le_pi _) 5 hN
  have h5 := hρ 5 (by norm_num)
  have h6 := hρ 6 (by norm_num)
  simp only [measuredRho] at h5 h6
  simp only [h5, h6] at hmono
  have : arccos 0.4847 < arccos 0.43636 :=
    Real.arccos_lt_arccos (by norm_num) (by norm_num) (by norm_num)
  linarith

/-! ## Section 5. Quantitative rebound bounds: concavity *forces* re-entry -/

/-- **Rebound horizon bound.**  If a sequence is concave on a window of length `K` starting at
`m` and drops by `D = sₘ - sₘ₊₁` at the start, then after `K` steps it has lost at least `K·D`.
In the angle coordinate: a rebound of angular size `D` can be sustained by a concave model for at
most `(θₘ - c)/D` steps before the angle falls below any prescribed floor `c`. -/
theorem rebound_horizon_bound (s : ℕ → ℝ) (m K : ℕ)
    (h : ∀ j, j + 2 ≤ K → s (m + j + 2) - 2 * s (m + j + 1) + s (m + j) ≤ 0) :
    K * (s m - s (m + 1)) ≤ s m - s (m + K) := by
  have := le_chord_window s m K h K le_rfl
  linarith

/-- **Concave continuation of the rebound re-enters the cap by bitlen 132.**  Any sequence that
reproduces the 112 and 116 rungs (`0.4621`, `0.4847`) and whose angle is concave on the windows
based at 112, 116, 120, 124 must read `ρ > 0.55` at bitlen 132 (index 9).  The curvature model
thus does not forbid re-entry — once the 116 rebound is admitted, it *forces* it. -/
theorem concave_rebound_forces_reentry (ρ : ℕ → ℝ) (h4 : ρ 4 = 0.4621) (h5 : ρ 5 = 0.4847)
    (hc : ∀ n, 4 ≤ n → n ≤ 7 →
      arccos (ρ (n + 2)) - 2 * arccos (ρ (n + 1)) + arccos (ρ n) ≤ 0) :
    0.55 < ρ 9 := by
  have hb := rebound_horizon_bound (fun n => arccos (ρ n)) 4 5
    (fun j hj => by
      have := hc (4 + j) (by omega) (by omega)
      simpa [Nat.add_assoc] using this)
  simp only [h4, h5] at hb
  have hD : (0.4847 - 0.4621) / 0.887 ≤ arccos 0.4621 - arccos 0.4847 :=
    arccos_sub_ge (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have hC : arccos 0.4621 - arccos 0.55 ≤ (0.55 - 0.4621) / 0.835 :=
    arccos_sub_le (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have hlt : arccos (ρ 9) < arccos 0.55 := by
    norm_num at hb hD hC ⊢
    linarith
  by_contra hle
  push_neg at hle
  exact absurd (Real.arccos_le_arccos hle) (not_le.2 hlt)

/-- **Lifetime bound for the concave continuation.**  No sequence reproducing the 112 and 116
rungs can have an angle that is concave on 62 consecutive windows starting at 112: the angle
would have to fall below `0`.  So the curvature model with the 116 rebound is not merely
cap-violating, it is self-inconsistent within `62` rungs (bitlen `≤ 360`). -/
theorem concave_rebound_lifetime (ρ : ℕ → ℝ) (h4 : ρ 4 = 0.4621) (h5 : ρ 5 = 0.4847) :
    ¬ ∀ n, 4 ≤ n → n ≤ 64 →
      arccos (ρ (n + 2)) - 2 * arccos (ρ (n + 1)) + arccos (ρ n) ≤ 0 := by
  intro hc
  have hb := rebound_horizon_bound (fun n => arccos (ρ n)) 4 62
    (fun j hj => by
      have := hc (4 + j) (by omega) (by omega)
      simpa [Nat.add_assoc] using this)
  simp only [h4, h5] at hb
  have hD : (0.4847 - 0.4621) / 0.887 ≤ arccos 0.4621 - arccos 0.4847 :=
    arccos_sub_ge (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have hpi : arccos 0.4621 ≤ π / 2 := by
    rw [Real.arccos_le_pi_div_two]; norm_num
  have h0 := Real.arccos_nonneg (ρ (4 + 62))
  have := Real.pi_lt_d2
  norm_num at hb hD ⊢
  linarith

/-! ## Section 6. Plateau localisation in the angle coordinate -/

/-- Tail bound for a nondecreasing sequence whose increments contract with ratio `r < 1`. -/
theorem angle_tail_bound {s : ℕ → ℝ} {r : ℝ} (hr1 : r < 1) (hmono : ∀ n, s n ≤ s (n + 1))
    (hgeo : ∀ n, s (n + 2) - s (n + 1) ≤ r * (s (n + 1) - s n)) :
    ∀ n m, s (n + m) - s n ≤ (s (n + 1) - s n) / (1 - r) := by
  have h1r : 0 < 1 - r := by linarith
  intro n m
  induction m generalizing n with
  | zero =>
      have h : 0 ≤ s (n + 1) - s n := by have := hmono n; linarith
      simpa using div_nonneg h h1r.le
  | succ m ih =>
      have hstep := ih (n + 1)
      rw [le_div_iff₀ h1r] at hstep
      have hg := hgeo n
      have hnm : n + (m + 1) = n + 1 + m := by omega
      rw [hnm, le_div_iff₀ h1r]
      nlinarith

/-- **Geometric angular deceleration is a special case of angular concavity.** -/
theorem geometric_deceleration_concave {s : ℕ → ℝ} {r : ℝ} (hr1 : r ≤ 1)
    (hmono : ∀ n, s n ≤ s (n + 1))
    (hgeo : ∀ n, s (n + 2) - s (n + 1) ≤ r * (s (n + 1) - s n)) :
    SecondDiffNonpos s 0 := by
  intro n _
  have h1 := hgeo n
  have h2 : 0 ≤ s (n + 1) - s n := by have := hmono n; linarith
  nlinarith

/-- **Angular plateau localisation.**  A nondecreasing angle sequence with geometrically
contracting increments converges, with `θₙ ≤ L ≤ θₙ + (θₙ₊₁ - θₙ)/(1 - r)` for every `n`. -/
theorem angle_plateau {s : ℕ → ℝ} {r : ℝ} (hr1 : r < 1) (hmono : ∀ n, s n ≤ s (n + 1))
    (hgeo : ∀ n, s (n + 2) - s (n + 1) ≤ r * (s (n + 1) - s n)) :
    ∃ L, Tendsto s atTop (nhds L) ∧ ∀ n, s n ≤ L ∧ L - s n ≤ (s (n + 1) - s n) / (1 - r) := by
  have h1r : 0 < 1 - r := by linarith
  have hmon : Monotone s := monotone_nat_of_le_succ hmono
  have htail := angle_tail_bound hr1 hmono hgeo
  have hbdd : BddAbove (Set.range s) := by
    refine ⟨s 0 + (s 1 - s 0) / (1 - r), ?_⟩
    rintro _ ⟨n, rfl⟩
    have h := htail 0 n
    simp only [Nat.zero_add] at h
    linarith
  refine ⟨⨆ i, s i, tendsto_atTop_ciSup hmon hbdd, fun n => ⟨le_ciSup hbdd n, ?_⟩⟩
  have key : ⨆ i, s i ≤ s n + (s (n + 1) - s n) / (1 - r) := by
    refine ciSup_le fun m => ?_
    rcases le_or_gt n m with h | h
    · have h2 := htail n (m - n)
      rw [show n + (m - n) = m by omega] at h2
      linarith
    · have hd : 0 ≤ s (n + 1) - s n := by have := hmono n; linarith
      have h3 : s m ≤ s n := hmon h.le
      have h4 : (0:ℝ) ≤ (s (n + 1) - s n) / (1 - r) := div_nonneg hd h1r.le
      linarith
  linarith

/-- **The U108 angular plateau window.**  Any angular fade model, indexed from bitlen 108, that
is nondecreasing, decelerates with ratio at most `1/2` and matches the measured angles
`arccos 0.488`, `arccos 0.4621`, has its limiting angle in
`[arccos 0.488, arccos 0.488 + 0.0595]`; the whole window lies strictly outside the `0.55` cap
(`arccos 0.55 < arccos 0.488`), so in this model class the band loss at U108 is permanent. -/
theorem u108_angle_plateau_window {s : ℕ → ℝ} {r : ℝ} (hr : r ≤ 1/2)
    (hmono : ∀ n, s n ≤ s (n + 1))
    (hgeo : ∀ n, s (n + 2) - s (n + 1) ≤ r * (s (n + 1) - s n))
    (h0 : s 0 = arccos 0.488) (h1 : s 1 = arccos 0.4621) :
    ∃ L, Tendsto s atTop (nhds L) ∧ arccos 0.488 ≤ L ∧ L ≤ arccos 0.488 + 0.0595 ∧
      arccos 0.55 < L := by
  obtain ⟨L, hL, hb⟩ := angle_plateau (by linarith : r < 1) hmono hgeo
  obtain ⟨hle, hgap⟩ := hb 0
  rw [h0, h1] at hgap
  rw [h0] at hle
  have hd : arccos 0.4621 - arccos 0.488 ≤ (0.488 - 0.4621) / 0.872 :=
    arccos_sub_le (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have hdpos : 0 ≤ arccos 0.4621 - arccos 0.488 := by
    have := Real.arccos_le_arccos (show (0.4621:ℝ) ≤ 0.488 by norm_num); linarith
  have hden : (0:ℝ) < 1 - r := by linarith
  have hdiv : (arccos 0.4621 - arccos 0.488) / (1 - r) ≤ 0.0595 := by
    rw [div_le_iff₀ hden]
    have hq : ((0.488:ℝ) - 0.4621) / 0.872 ≤ 0.02975 := by norm_num
    linarith
  have hcap : arccos 0.55 < arccos 0.488 :=
    Real.arccos_lt_arccos (by norm_num) (by norm_num) (by norm_num)
  exact ⟨L, hL, hle, by linarith, by linarith⟩

end Catalog.Novelty.TDialU108Angular