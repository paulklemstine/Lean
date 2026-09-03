import Bridges.Ma1EffectivityCeiling
import Mathlib.NumberTheory.DirichletCharacter.Basic

/-!
# Effectivizing MA-1: what an `ε`-equidistribution certificate buys

Experiment 509 (round-48 #1) measures, for the moduli `m ∈ {3,4,5,7,8,11,31}`, the maximal
relative deviation of the prime counts `π(x; m, a)` from the equidistributed prediction
`Li(x)/φ(m)`, and records `ε = 0.000446` at `x = 2^30`.  The recorded consequence is that
"the 4/3 cap's constants hold to three significant figures".

A measurement is not a theorem.  This file supplies the deductive layer: it defines the
*equidistribution certificate* `EquiCert N μ ε` (every class count is within a relative
`ε` of the common target `μ = Li(x)/φ(m)`) and proves, from that certificate alone, exactly
what transfers and how much it costs.

Main results.

* `EquiCert.ratio_le` — the two-sided ratio bound `N a ≤ ((1+ε)/(1−ε)) · N b`, and
  `ratio_bound_sharp`: the constant `(1+ε)/(1−ε)` is attained, even under exact total
  conservation, so no better transfer constant exists.
* `cap_transfer` — **the effectivization of MA-1.**  Any cap `Φ(uniform) ≤ (4/3)·Ψ(uniform)`
  proved *under* the equidistribution assumption, for functionals `Φ, Ψ` that are monotone
  and positively homogeneous, transfers to the true counts with the degraded constant
  `capConst ε = (4/3)·(1+ε)/(1−ε)`.
* `capConst_exp509`, `capConst_exp509_rel_error`, `exp509_cap_three_sig_figs` — the numeric
  payload: at the recorded `ε = 0.000446` the transferred constant lies strictly between
  `1.3345` and `1.3346`, a relative perturbation `< 0.001`; the three significant figures
  `1.33` are therefore genuinely certified.
* `maxOf_le_capConst_mul_minOf` — a concrete non-vacuous instance of `cap_transfer` with
  `Φ = max`, `Ψ = min`, requiring the monotonicity and homogeneity of `Finset.sup'`/`inf'`.
* `abs_dev_le_half_sum_abs_dev`, `excess_forces_deficit` — **conservation.**  When the total
  is exactly `card ι · μ`, an excess in one class is *paid for* by a deficit elsewhere:
  some other class lies at least `(N a − μ)/(n−1)` below target.
* `test_function_bound_real` / `dev_from_mean_le_of_test_bound` — **duality.**  The
  certificate is equivalent, up to the empirical mean, to a uniform bound on all mean-zero
  test correlations.  This is the bridge to harmonic analysis:
* `character_sum_bound`, `dirichletCharacter_sum_bound` — an `ε`-certificate bounds *every*
  nontrivial character sum of the count vector by `φ(m)·ε·μ`, i.e. by `ε·Li(x)`.
* `tss_le_of_equiCert`, `separation_margin_le_of_equiCert` — **the statistics bridge.**  The
  certificate caps the total sum of squares of the count field, hence (through the two-group
  identity of `Bridges.Ma1EffectivityCeiling`) caps the margin of *every* threshold criterion
  built from *any* feature: no per-modulus criterion can separate an `ε`-equidistributed
  field by more than `ε·μ`.
* `worst_class_switch_near_tie`, `worst_class_stable_of_gap` — **H2, as a dichotomy.**  The
  worst class can only switch between two scales at a near-tie: both top-two gaps are at
  most twice the drift; equivalently, a top-two gap exceeding twice the drift forces
  stability.  This is the theorem-level content of the observed split between moduli whose
  worst class is stable and moduli whose worst class moves.
* `shrink_majority_total`, `shrink_majority_total_lt` — **H3, as a theorem.**  A majority of
  moduli shrinking by a factor `ρ < 1`, with the exceptional ones merely not growing, forces
  the aggregate deviation to drop by `(1−ρ)` times the shrinking mass.

Everything is exact real algebra; no analytic input about primes is used or claimed.  The
number-theoretic content is confined to the *hypothesis* `EquiCert`, which is what the
experiment measures.
-/

namespace Ma1Effective

open Finset

variable {ι : Type*} [Fintype ι] {N : ι → ℝ} {μ ε : ℝ}

/-! ## The equidistribution certificate -/

/-- **The MA-1 certificate.**  `EquiCert N μ ε` says that every class count `N a` lies
within a relative `ε` of the common target `μ` (in the intended application
`N a = π(x; m, a)` and `μ = Li(x)/φ(m)`).  This is precisely what experiment 509 measures,
with `ε = 0.000446` at `x = 2^30`. -/
def EquiCert (N : ι → ℝ) (μ ε : ℝ) : Prop := ∀ a, |N a - μ| ≤ ε * μ

omit [Fintype ι] in
theorem EquiCert.upper (h : EquiCert N μ ε) (a : ι) : N a ≤ (1 + ε) * μ := by
  have := (abs_le.1 (h a)).2; linarith

omit [Fintype ι] in
theorem EquiCert.lower (h : EquiCert N μ ε) (a : ι) : (1 - ε) * μ ≤ N a := by
  have := (abs_le.1 (h a)).1; linarith

omit [Fintype ι] in
theorem EquiCert.pos (h : EquiCert N μ ε) (hμ : 0 < μ) (hε : ε < 1) (a : ι) : 0 < N a := by
  have h1 := h.lower a
  nlinarith

omit [Fintype ι] in
/-- A weaker certificate is implied by a stronger one. -/
theorem EquiCert.mono (h : EquiCert N μ ε) (hμ : 0 ≤ μ) {ε' : ℝ} (hle : ε ≤ ε') :
    EquiCert N μ ε' := fun a => (h a).trans (by nlinarith)

omit [Fintype ι] in
/-- **The transfer ratio.**  Under an `ε`-certificate any two class counts differ by a factor
of at most `(1+ε)/(1−ε)`. -/
theorem EquiCert.ratio_le (h : EquiCert N μ ε) (hε : ε < 1) (hε0 : 0 ≤ ε) (a b : ι) :
    N a ≤ (1 + ε) / (1 - ε) * N b := by
  have h1 : (0 : ℝ) < 1 - ε := by linarith
  have hq : 0 ≤ (1 + ε) / (1 - ε) := by positivity
  have hb : (1 - ε) * μ ≤ N b := h.lower b
  have key : (1 + ε) / (1 - ε) * ((1 - ε) * μ) = (1 + ε) * μ := by field_simp
  calc N a ≤ (1 + ε) * μ := h.upper a
    _ = (1 + ε) / (1 - ε) * ((1 - ε) * μ) := key.symm
    _ ≤ (1 + ε) / (1 - ε) * N b := mul_le_mul_of_nonneg_left hb hq

/-- **Sharpness of the transfer ratio.**  For every admissible `ε` there is a two-class
count vector satisfying the `ε`-certificate *and* exact total conservation whose class ratio
is exactly `(1+ε)/(1−ε)`.  So `EquiCert.ratio_le` cannot be improved, and neither can the
constant `capConst ε` below. -/
theorem ratio_bound_sharp (hε0 : 0 ≤ ε) (hε : ε < 1) (hμ : 0 < μ) :
    ∃ N : Fin 2 → ℝ, EquiCert N μ ε ∧ (∑ a, N a = 2 * μ) ∧
      N 0 = (1 + ε) / (1 - ε) * N 1 := by
  refine ⟨fun a => if a = 0 then (1 + ε) * μ else (1 - ε) * μ, ?_, ?_, ?_⟩
  · intro a
    show |(if a = 0 then (1 + ε) * μ else (1 - ε) * μ) - μ| ≤ ε * μ
    by_cases ha : a = 0
    · rw [if_pos ha, show (1 + ε) * μ - μ = ε * μ by ring, abs_of_nonneg (by positivity)]
    · rw [if_neg ha, show (1 - ε) * μ - μ = -(ε * μ) by ring, abs_neg,
        abs_of_nonneg (by positivity)]
  · rw [Fin.sum_univ_two, if_pos rfl, if_neg (by decide : ¬((1 : Fin 2) = 0))]
    ring
  · have h1 : (0 : ℝ) < 1 - ε := by linarith
    show (if (0 : Fin 2) = 0 then (1 + ε) * μ else (1 - ε) * μ)
        = (1 + ε) / (1 - ε) * (if (1 : Fin 2) = 0 then (1 + ε) * μ else (1 - ε) * μ)
    rw [if_pos rfl, if_neg (by decide : ¬((1 : Fin 2) = 0))]
    field_simp

/-! ## The effective cap constant -/

/-- The MA-1-effective cap constant: the exact-equidistribution constant `4/3` degraded by
the certificate's transfer ratio. -/
noncomputable def capConst (ε : ℝ) : ℝ := 4 / 3 * ((1 + ε) / (1 - ε))

theorem capConst_zero : capConst 0 = 4 / 3 := by norm_num [capConst]

theorem capConst_nonneg {ε : ℝ} (h0 : 0 ≤ ε) (h1 : ε < 1) : 0 ≤ capConst ε := by
  have : (0 : ℝ) < 1 - ε := by linarith
  unfold capConst; positivity

theorem capConst_mono {ε₁ ε₂ : ℝ} (h : ε₁ ≤ ε₂) (h1 : ε₂ < 1) :
    capConst ε₁ ≤ capConst ε₂ := by
  have hp1 : (0 : ℝ) < 1 - ε₁ := by linarith
  have hp2 : (0 : ℝ) < 1 - ε₂ := by linarith
  unfold capConst
  have : (1 + ε₁) / (1 - ε₁) ≤ (1 + ε₂) / (1 - ε₂) := by
    rw [div_le_div_iff₀ hp1 hp2]; nlinarith
  linarith

/-- **The numeric payload of experiment 509.**  At the recorded maximal relative deviation
`ε = 0.000446` the effective cap constant is pinned to five decimals. -/
theorem capConst_exp509 : 1.3345 < capConst 0.000446 ∧ capConst 0.000446 < 1.3346 := by
  constructor <;> · unfold capConst; norm_num

/-- **Three significant figures.**  The effectivization perturbs the `4/3` cap by less than
one part in a thousand, so the leading three digits `1.33` are certified. -/
theorem capConst_exp509_rel_error : |capConst 0.000446 - 4 / 3| < 4 / 3 * (1 / 1000) := by
  have h : capConst 0.000446 - 4 / 3 > 0 := by unfold capConst; norm_num
  rw [abs_of_pos h]
  unfold capConst; norm_num

/-- The transferred constant still rounds to `1.33` at three significant figures. -/
theorem capConst_exp509_rounds : (1.325 : ℝ) ≤ capConst 0.000446 ∧ capConst 0.000446 < 1.335 :=
  ⟨le_of_lt (by linarith [capConst_exp509.1]), by linarith [capConst_exp509.2]⟩

/-! ## Monotone, positively homogeneous readouts -/

/-- A readout of the count vector that is monotone in the counts. -/
def MonotoneReadout (Φ : (ι → ℝ) → ℝ) : Prop := ∀ f g : ι → ℝ, (∀ a, f a ≤ g a) → Φ f ≤ Φ g

/-- A readout of the count vector that scales with the counts. -/
def PosHomogeneous (Φ : (ι → ℝ) → ℝ) : Prop :=
  ∀ c : ℝ, 0 ≤ c → ∀ f : ι → ℝ, Φ (fun a => c * f a) = c * Φ f

omit [Fintype ι] in
/-- Under an `ε`-certificate, a monotone homogeneous readout is at most `(1+ε)` times its
value on the exactly equidistributed vector. -/
theorem readout_upper {Φ : (ι → ℝ) → ℝ} (hm : MonotoneReadout Φ) (hh : PosHomogeneous Φ)
    (h : EquiCert N μ ε) (hε : 0 ≤ ε) : Φ N ≤ (1 + ε) * Φ (fun _ => μ) := by
  have hstep : Φ N ≤ Φ (fun a => (1 + ε) * (fun _ : ι => μ) a) :=
    hm _ _ fun a => h.upper a
  rwa [hh (1 + ε) (by linarith)] at hstep

omit [Fintype ι] in
/-- Under an `ε`-certificate, a monotone homogeneous readout is at least `(1−ε)` times its
value on the exactly equidistributed vector. -/
theorem readout_lower {Ψ : (ι → ℝ) → ℝ} (hm : MonotoneReadout Ψ) (hh : PosHomogeneous Ψ)
    (h : EquiCert N μ ε) (hε : ε ≤ 1) : (1 - ε) * Ψ (fun _ => μ) ≤ Ψ N := by
  have hstep : Ψ (fun a => (1 - ε) * (fun _ : ι => μ) a) ≤ Ψ N :=
    hm _ _ fun a => h.lower a
  rwa [hh (1 - ε) (by linarith)] at hstep

omit [Fintype ι] in
/-- **Effectivization of MA-1.**  Suppose a cap `Φ ≤ (4/3)·Ψ` has been proved *assuming*
exact equidistribution, for readouts `Φ, Ψ` that are monotone and positively homogeneous.
Then on any count vector carrying an `ε`-certificate the same cap holds with the degraded
constant `capConst ε = (4/3)(1+ε)/(1−ε)`.  Combined with `ratio_bound_sharp`, this constant
is optimal for the class of such readouts. -/
theorem cap_transfer {Φ Ψ : (ι → ℝ) → ℝ}
    (hΦm : MonotoneReadout Φ) (hΦh : PosHomogeneous Φ)
    (hΨm : MonotoneReadout Ψ) (hΨh : PosHomogeneous Ψ)
    (hcap : Φ (fun _ => μ) ≤ 4 / 3 * Ψ (fun _ => μ))
    (h : EquiCert N μ ε) (hε0 : 0 ≤ ε) (hε1 : ε < 1) :
    Φ N ≤ capConst ε * Ψ N := by
  have h1 : (0 : ℝ) < 1 - ε := by linarith
  have hup : Φ N ≤ (1 + ε) * Φ (fun _ => μ) := readout_upper hΦm hΦh h hε0
  have hlo : (1 - ε) * Ψ (fun _ => μ) ≤ Ψ N := readout_lower hΨm hΨh h (le_of_lt hε1)
  have hstep : Φ N ≤ (1 + ε) * (4 / 3 * Ψ fun _ => μ) := by
    have : (1 + ε) * Φ (fun _ => μ) ≤ (1 + ε) * (4 / 3 * Ψ fun _ => μ) :=
      mul_le_mul_of_nonneg_left hcap (by linarith)
    linarith
  have hΨu : Ψ (fun _ => μ) ≤ Ψ N / (1 - ε) := by
    rw [le_div_iff₀ h1]; linarith
  have hfin : (1 + ε) * (4 / 3 * Ψ fun _ => μ) ≤ (1 + ε) * (4 / 3 * (Ψ N / (1 - ε))) := by
    have := mul_le_mul_of_nonneg_left hΨu (by linarith : (0:ℝ) ≤ 4 / 3)
    exact mul_le_mul_of_nonneg_left this (by linarith)
  have hrw : (1 + ε) * (4 / 3 * (Ψ N / (1 - ε))) = capConst ε * Ψ N := by
    unfold capConst; field_simp
  linarith [hstep.trans hfin, hrw]

omit [Fintype ι] in
/-- **The headline theorem of experiment 509.**  At the measured `ε = 0.000446`, every cap
of the above shape survives with constant `< 1.3346`: the `4/3` cap holds to three
significant figures, the equidistribution assumption contributing a relative error below
`0.1 %`. -/
theorem exp509_cap_three_sig_figs {Φ Ψ : (ι → ℝ) → ℝ}
    (hΦm : MonotoneReadout Φ) (hΦh : PosHomogeneous Φ)
    (hΨm : MonotoneReadout Ψ) (hΨh : PosHomogeneous Ψ)
    (hcap : Φ (fun _ => μ) ≤ 4 / 3 * Ψ (fun _ => μ))
    (h : EquiCert N μ 0.000446) (hΨ : 0 ≤ Ψ N) :
    Φ N ≤ 1.3346 * Ψ N := by
  have hmain := cap_transfer hΦm hΦh hΨm hΨh hcap h (by norm_num) (by norm_num)
  have := mul_le_mul_of_nonneg_right (le_of_lt capConst_exp509.2) hΨ
  linarith

/-! ### A concrete instance: the max/min cap -/

section MaxMin

variable [Nonempty ι]

/-- The largest class count. -/
noncomputable def maxOf (N : ι → ℝ) : ℝ := Finset.univ.sup' Finset.univ_nonempty N

/-- The smallest class count. -/
noncomputable def minOf (N : ι → ℝ) : ℝ := Finset.univ.inf' Finset.univ_nonempty N

theorem monotoneReadout_maxOf : MonotoneReadout (maxOf (ι := ι)) := by
  intro f g hfg
  refine Finset.sup'_le _ _ fun a _ => ?_
  exact (hfg a).trans (Finset.le_sup' g (Finset.mem_univ a))

theorem monotoneReadout_minOf : MonotoneReadout (minOf (ι := ι)) := by
  intro f g hfg
  refine Finset.le_inf' _ _ fun a _ => ?_
  exact (Finset.inf'_le f (Finset.mem_univ a)).trans (hfg a)

theorem posHomogeneous_maxOf : PosHomogeneous (maxOf (ι := ι)) := by
  intro c hc f
  rcases eq_or_lt_of_le hc with hc0 | hcpos
  · simp [maxOf, ← hc0]
  · refine le_antisymm ?_ ?_
    · refine Finset.sup'_le _ _ fun a _ => ?_
      exact mul_le_mul_of_nonneg_left (Finset.le_sup' f (Finset.mem_univ a)) hc
    · rw [← le_div_iff₀' hcpos]
      refine Finset.sup'_le _ _ fun a _ => ?_
      rw [le_div_iff₀' hcpos]
      exact Finset.le_sup' (fun a => c * f a) (Finset.mem_univ a)

theorem posHomogeneous_minOf : PosHomogeneous (minOf (ι := ι)) := by
  intro c hc f
  rcases eq_or_lt_of_le hc with hc0 | hcpos
  · simp [minOf, ← hc0]
  · refine le_antisymm ?_ ?_
    · rw [← div_le_iff₀' hcpos]
      refine Finset.le_inf' _ _ fun a _ => ?_
      rw [div_le_iff₀' hcpos]
      exact Finset.inf'_le (fun a => c * f a) (Finset.mem_univ a)
    · refine Finset.le_inf' _ _ fun a _ => ?_
      exact mul_le_mul_of_nonneg_left (Finset.inf'_le f (Finset.mem_univ a)) hc

/-- A non-vacuous instance of `cap_transfer`: the largest class count is at most
`capConst ε` times the smallest.  (Under exact equidistribution the two coincide, so the
`4/3` cap holds there trivially; the theorem is that the certificate degrades it by no more
than the transfer ratio.) -/
theorem maxOf_le_capConst_mul_minOf (h : EquiCert N μ ε) (hμ : 0 ≤ μ) (hε0 : 0 ≤ ε)
    (hε1 : ε < 1) : maxOf N ≤ capConst ε * minOf N := by
  refine cap_transfer monotoneReadout_maxOf posHomogeneous_maxOf monotoneReadout_minOf
    posHomogeneous_minOf ?_ h hε0 hε1
  have hmax : maxOf (fun _ : ι => μ) = μ := by simp [maxOf]
  have hmin : minOf (fun _ : ι => μ) = μ := by simp [minOf]
  rw [hmax, hmin]; linarith

end MaxMin

/-! ## Conservation: an excess in one class is paid for elsewhere -/

theorem sum_dev_eq_zero (hsum : ∑ a, N a = (Fintype.card ι : ℝ) * μ) :
    ∑ a, (N a - μ) = 0 := by
  rw [Finset.sum_sub_distrib, hsum, Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  ring

/-- **Half-`ℓ¹` bound.**  Under exact conservation of the total, no single class deviation
can exceed half of the total absolute deviation. -/
theorem abs_dev_le_half_sum_abs_dev (hsum : ∑ a, N a = (Fintype.card ι : ℝ) * μ) (a : ι) :
    |N a - μ| ≤ (∑ b, |N b - μ|) / 2 := by
  classical
  have hz := sum_dev_eq_zero hsum
  have hsplit : (N a - μ) + ∑ b ∈ Finset.univ.erase a, (N b - μ) = 0 := by
    have hs := Finset.add_sum_erase Finset.univ (fun b => N b - μ) (Finset.mem_univ a)
    rw [hz] at hs
    exact hs
  have h1 : |N a - μ| = |∑ b ∈ Finset.univ.erase a, (N b - μ)| := by
    have : N a - μ = -∑ b ∈ Finset.univ.erase a, (N b - μ) := by linarith
    rw [this, abs_neg]
  have h2 : |∑ b ∈ Finset.univ.erase a, (N b - μ)| ≤ ∑ b ∈ Finset.univ.erase a, |N b - μ| :=
    Finset.abs_sum_le_sum_abs _ _
  have h3 : |N a - μ| + ∑ b ∈ Finset.univ.erase a, |N b - μ| = ∑ b, |N b - μ| :=
    Finset.add_sum_erase Finset.univ (fun b => |N b - μ|) (Finset.mem_univ a)
  linarith [h1 ▸ h2]

/-- **Conservation forces a compensating deficit.**  If the total is exactly `n·μ` and class
`a` runs an excess `N a − μ`, then some other class runs a deficit of at least
`(N a − μ)/(n−1)`.  Equidistribution failures never come alone. -/
theorem excess_forces_deficit (hsum : ∑ a, N a = (Fintype.card ι : ℝ) * μ)
    (hcard : 1 < Fintype.card ι) (a : ι) :
    ∃ b, b ≠ a ∧ N b - μ ≤ -((N a - μ) / ((Fintype.card ι : ℝ) - 1)) := by
  classical
  set S : Finset ι := Finset.univ.erase a with hS
  have hcardS : (S.card : ℝ) = (Fintype.card ι : ℝ) - 1 := by
    rw [hS, Finset.card_erase_of_mem (Finset.mem_univ a), Finset.card_univ]
    have h1 : 1 ≤ Fintype.card ι := le_of_lt hcard
    push_cast [Nat.cast_sub h1]
    ring
  have hpos : (0 : ℝ) < (Fintype.card ι : ℝ) - 1 := by
    rw [← hcardS]
    have hc : 0 < S.card := by
      rw [hS, Finset.card_erase_of_mem (Finset.mem_univ a), Finset.card_univ]; omega
    exact_mod_cast hc
  have hSne : S.Nonempty := by
    rw [← Finset.card_pos]
    have : (0 : ℝ) < (S.card : ℝ) := by rw [hcardS]; exact hpos
    exact_mod_cast this
  have hz := sum_dev_eq_zero hsum
  have hsplit : (N a - μ) + ∑ b ∈ S, (N b - μ) = 0 := by
    have hs := Finset.add_sum_erase Finset.univ (fun b => N b - μ) (Finset.mem_univ a)
    rw [hz] at hs
    rw [hS]
    exact hs
  have hsumS : ∑ b ∈ S, (N b - μ) = ∑ _b ∈ S, -((N a - μ) / ((Fintype.card ι : ℝ) - 1)) := by
    rw [Finset.sum_const, nsmul_eq_mul, hcardS]
    field_simp
    linarith
  obtain ⟨b, hbS, hb⟩ := Finset.exists_le_of_sum_le hSne (le_of_eq hsumS)
  exact ⟨b, Finset.ne_of_mem_erase hbS, hb⟩

/-! ## Duality: certificates and mean-zero test correlations -/

/-- **A certificate kills every mean-zero test correlation.**  This is the abstract form of
"all nontrivial character sums are small". -/
theorem test_function_bound_real (f : ι → ℝ) (hf : ∑ a, f a = 0) (hb : ∀ a, |f a| ≤ 1)
    (h : EquiCert N μ ε) : |∑ a, f a * N a| ≤ (Fintype.card ι : ℝ) * (ε * μ) := by
  have hkey : ∑ a, f a * N a = ∑ a, f a * (N a - μ) := by
    have hzero : ∑ a, f a * μ = 0 := by rw [← Finset.sum_mul, hf, zero_mul]
    have hexp : ∑ a, f a * (N a - μ) = (∑ a, f a * N a) - ∑ a, f a * μ := by
      rw [← Finset.sum_sub_distrib]; exact Finset.sum_congr rfl fun a _ => by ring
    rw [hexp, hzero, sub_zero]
  rw [hkey]
  calc |∑ a, f a * (N a - μ)| ≤ ∑ a, |f a * (N a - μ)| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _a : ι, ε * μ := by
        refine Finset.sum_le_sum fun a _ => ?_
        rw [abs_mul]
        calc |f a| * |N a - μ| ≤ 1 * (ε * μ) :=
              mul_le_mul (hb a) (h a) (abs_nonneg _) zero_le_one
          _ = ε * μ := one_mul _
    _ = (Fintype.card ι : ℝ) * (ε * μ) := by
        rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]

/-- **The converse direction.**  A uniform bound `δ` on all mean-zero, sup-norm-bounded test
correlations forces every class to sit within `δ` of the empirical mean.  Together with
`test_function_bound_real` this makes the certificate and the test-correlation bound
equivalent up to the factor `card ι`. -/
theorem dev_from_mean_le_of_test_bound {δ : ℝ}
    (hδ : ∀ f : ι → ℝ, (∑ a, f a = 0) → (∀ a, |f a| ≤ 1) → |∑ a, f a * N a| ≤ δ) (a : ι) :
    |N a - (∑ b, N b) / (Fintype.card ι : ℝ)| ≤ δ := by
  classical
  have hcard : 0 < Fintype.card ι := Fintype.card_pos_iff.2 ⟨a⟩
  have hn : (0 : ℝ) < (Fintype.card ι : ℝ) := by exact_mod_cast hcard
  have hpos : 0 < 1 / (Fintype.card ι : ℝ) := by positivity
  have hle : 1 / (Fintype.card ι : ℝ) ≤ 1 := by
    rw [div_le_one hn]; exact_mod_cast hcard
  have hsum : ∑ b, ((if b = a then (1 : ℝ) else 0) - 1 / (Fintype.card ι : ℝ)) = 0 := by
    have h1 : ∑ b, (if b = a then (1 : ℝ) else 0) = 1 := by simp
    have h2 : ∑ _b : ι, (1 / (Fintype.card ι : ℝ)) = 1 := by
      rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
      field_simp
    rw [Finset.sum_sub_distrib, h1, h2, sub_self]
  have hbound : ∀ b, |(if b = a then (1 : ℝ) else 0) - 1 / (Fintype.card ι : ℝ)| ≤ 1 := by
    intro b
    by_cases hb : b = a
    · rw [if_pos hb, abs_of_nonneg (by linarith)]; linarith
    · rw [if_neg hb, zero_sub, abs_neg, abs_of_nonneg (le_of_lt hpos)]; linarith
  have hval : ∑ b, ((if b = a then (1 : ℝ) else 0) - 1 / (Fintype.card ι : ℝ)) * N b
      = N a - (∑ b, N b) / (Fintype.card ι : ℝ) := by
    have hterm : ∀ b : ι, ((if b = a then (1 : ℝ) else 0) - 1 / (Fintype.card ι : ℝ)) * N b
        = (if b = a then N b else 0) - N b / (Fintype.card ι : ℝ) := by
      intro b
      by_cases hb : b = a
      · rw [if_pos hb, if_pos hb]; ring
      · rw [if_neg hb, if_neg hb]; ring
    rw [Finset.sum_congr rfl fun b _ => hterm b, Finset.sum_sub_distrib,
      Finset.sum_ite_eq' Finset.univ a N, ← Finset.sum_div]
    simp
  have hmain := hδ _ hsum hbound
  rwa [hval] at hmain

/-! ### The harmonic-analysis bridge: character sums -/

/-- **Complex test functions.**  Same statement, complex coefficients. -/
theorem test_function_bound_complex (f : ι → ℂ) (hf : ∑ a, f a = 0) (hb : ∀ a, ‖f a‖ ≤ 1)
    (h : EquiCert N μ ε) : ‖∑ a, f a * (N a : ℂ)‖ ≤ (Fintype.card ι : ℝ) * (ε * μ) := by
  have hkey : ∑ a, f a * (N a : ℂ) = ∑ a, f a * ((N a - μ : ℝ) : ℂ) := by
    have hzero : ∑ a, f a * ((μ : ℝ) : ℂ) = 0 := by rw [← Finset.sum_mul, hf, zero_mul]
    have hexp : ∑ a, f a * ((N a - μ : ℝ) : ℂ)
        = (∑ a, f a * (N a : ℂ)) - ∑ a, f a * ((μ : ℝ) : ℂ) := by
      rw [← Finset.sum_sub_distrib]
      refine Finset.sum_congr rfl fun a _ => ?_
      push_cast; ring
    rw [hexp, hzero, sub_zero]
  rw [hkey]
  calc ‖∑ a, f a * ((N a - μ : ℝ) : ℂ)‖ ≤ ∑ a, ‖f a * ((N a - μ : ℝ) : ℂ)‖ :=
        norm_sum_le _ _
    _ ≤ ∑ _a : ι, ε * μ := by
        refine Finset.sum_le_sum fun a _ => ?_
        rw [norm_mul, Complex.norm_real, Real.norm_eq_abs]
        calc ‖f a‖ * |N a - μ| ≤ 1 * (ε * μ) :=
              mul_le_mul (hb a) (h a) (abs_nonneg _) zero_le_one
          _ = ε * μ := one_mul _
    _ = (Fintype.card ι : ℝ) * (ε * μ) := by
        rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]

/-- **Every nontrivial character sum is small.**  For a finite abelian group of classes and
any nontrivial character `χ`, an `ε`-certificate bounds `|Σ χ(a) N a|` by `|G|·ε·μ`, which
in the arithmetic application is exactly `ε · Li(x)`. -/
theorem character_sum_bound {G : Type*} [Fintype G] [CommGroup G] (χ : G →* ℂ) (hχ : χ ≠ 1)
    {N : G → ℝ} (h : EquiCert N μ ε) :
    ‖∑ a, χ a * (N a : ℂ)‖ ≤ (Fintype.card G : ℝ) * (ε * μ) := by
  refine test_function_bound_complex (fun a => χ a) (sum_hom_units_eq_zero χ hχ) ?_ h
  intro a
  show ‖χ a‖ ≤ 1
  have hp : (χ a) ^ (Fintype.card G) = 1 := by rw [← map_pow, pow_card_eq_one, map_one]
  have hcard : 0 < Fintype.card G := Fintype.card_pos
  exact le_of_eq (Complex.norm_eq_one_of_pow_eq_one hp (by omega))

/-- **The Dirichlet-character form.**  For a modulus `m` and a Dirichlet character mod `m`
whose restriction to the units is nontrivial, an `ε`-certificate on the class counts bounds
the twisted sum by `φ(m)·ε·μ`. -/
theorem dirichletCharacter_sum_bound {m : ℕ} [NeZero m] (χ : DirichletCharacter ℂ m)
    (hχ : χ.toUnitHom ≠ 1) {N : (ZMod m)ˣ → ℝ} (h : EquiCert N μ ε) :
    ‖∑ a : (ZMod m)ˣ, χ (a : ZMod m) * (N a : ℂ)‖ ≤ (Nat.totient m : ℝ) * (ε * μ) := by
  have hθ : ((Units.coeHom ℂ).comp χ.toUnitHom) ≠ 1 := by
    intro hcon
    refine hχ (MonoidHom.ext fun a => Units.ext ?_)
    have hva := DFunLike.congr_fun hcon a
    simpa using hva
  have hb := character_sum_bound ((Units.coeHom ℂ).comp χ.toUnitHom) hθ h (μ := μ) (ε := ε)
  have hcard : (Fintype.card (ZMod m)ˣ : ℝ) = (Nat.totient m : ℝ) := by
    rw [ZMod.card_units_eq_totient]
  rw [hcard] at hb
  have heq : ∀ a : (ZMod m)ˣ, ((Units.coeHom ℂ).comp χ.toUnitHom) a = χ (a : ZMod m) := by
    intro a; simp
  calc ‖∑ a : (ZMod m)ˣ, χ (a : ZMod m) * (N a : ℂ)‖
      = ‖∑ a : (ZMod m)ˣ, ((Units.coeHom ℂ).comp χ.toUnitHom) a * (N a : ℂ)‖ := by
        refine congrArg norm (Finset.sum_congr rfl fun a _ => ?_)
        rw [heq a]
    _ ≤ (Nat.totient m : ℝ) * (ε * μ) := hb

/-! ## The statistics bridge: a certificate caps every criterion's margin -/

section Statistics

open QRResidual

open scoped Classical

variable [Nonempty ι]

/-- The empirical variance is minimised at the empirical mean, so any reference value gives
an upper bound for the total sum of squares. -/
theorem tss_le_sum_sq (y : ι → ℝ) (c : ℝ) : tss y ≤ ∑ a, (y a - c) ^ 2 := by
  have hn : ((Fintype.card ι : ℝ)) ≠ 0 := by
    have : 0 < Fintype.card ι := Fintype.card_pos
    positivity
  have hmz : ∑ a, (y a - mean y) = 0 := by
    rw [Finset.sum_sub_distrib, Finset.sum_const, Finset.card_univ, nsmul_eq_mul, mean]
    field_simp
    ring
  have hexp : ∀ a, (y a - c) ^ 2
      = (y a - mean y) ^ 2 + 2 * (mean y - c) * (y a - mean y) + (mean y - c) ^ 2 :=
    fun a => by ring
  have hsum : ∑ a, (y a - c) ^ 2
      = (∑ a, (y a - mean y) ^ 2) + (Fintype.card ι : ℝ) * (mean y - c) ^ 2 := by
    rw [Finset.sum_congr rfl fun a _ => hexp a]
    rw [Finset.sum_add_distrib, Finset.sum_add_distrib, ← Finset.mul_sum, hmz, mul_zero,
      add_zero, Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  have htss : tss y = ∑ a, (y a - mean y) ^ 2 := by
    simp [tss, sqNorm, Pi.sub_apply]
  have hnn : 0 ≤ (Fintype.card ι : ℝ) * (mean y - c) ^ 2 := by positivity
  rw [htss, hsum]; linarith

/-- **A certificate caps the total sum of squares** of the count field. -/
theorem tss_le_of_equiCert (h : EquiCert N μ ε) :
    tss N ≤ (Fintype.card ι : ℝ) * (ε * μ) ^ 2 := by
  refine (tss_le_sum_sq N μ).trans ?_
  have hpt : ∀ a ∈ (Finset.univ : Finset ι), (N a - μ) ^ 2 ≤ (ε * μ) ^ 2 := by
    intro a _
    have h1 := h a
    have h2 : |N a - μ| ^ 2 = (N a - μ) ^ 2 := sq_abs _
    nlinarith [abs_nonneg (N a - μ)]
  calc ∑ a, (N a - μ) ^ 2 ≤ ∑ _a : ι, (ε * μ) ^ 2 := Finset.sum_le_sum hpt
    _ = (Fintype.card ι : ℝ) * (ε * μ) ^ 2 := by
        rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]

/-- **No criterion can find structure in an `ε`-equidistributed field.**  If any feature `P`
and any threshold `t` separate the class counts into a high group (`≥ μ₀ + δ`) and a low
group (`≤ μ₀ − δ`), then the separation obeys `4δ²n₁n₂/n ≤ card ι · (εμ)²`.  For a balanced
split this says `δ ≤ ε·μ`: the achievable margin is bounded by the certificate itself,
uniformly over all criteria. -/
theorem separation_margin_le_of_equiCert {P : ι → ℝ} {t μ₀ δ : ℝ}
    (hhigh : ∀ i, t ≤ P i → μ₀ + δ ≤ N i) (hlow : ∀ i, ¬ t ≤ P i → N i ≤ μ₀ - δ)
    (hδ : 0 ≤ δ) (hS : (univ.filter fun i => t ≤ P i).Nonempty)
    (hSc : (univ.filter fun i => t ≤ P i)ᶜ.Nonempty) (htss : 0 < tss N)
    (h : EquiCert N μ ε) :
    4 * δ ^ 2 * ((univ.filter fun i => t ≤ P i).card : ℝ)
        * (((univ.filter fun i => t ≤ P i)ᶜ).card : ℝ) / (Fintype.card ι : ℝ)
      ≤ (Fintype.card ι : ℝ) * (ε * μ) ^ 2 := by
  have hmargin := Ma1Effectivity.margin_criterion_rsq_lower hhigh hlow hδ hS hSc htss
  have hrss : 0 ≤ rss N (measurableClass P) :=
    rss_nonneg N ⟨fun _ => 0, fun _ => 0, rfl⟩
  have hrsq : rsq N (measurableClass P) * tss N = tss N - rss N (measurableClass P) := by
    rw [rsq]; field_simp
  have htss' := tss_le_of_equiCert h
  rw [hrsq] at hmargin
  linarith

end Statistics

/-! ## H2: the worst class can only switch at a near-tie -/

omit [Fintype ι] in
/-- **Switching implies a near-tie.**  If the deviation field drifts by at most `η` in sup
norm between two scales, and the worst class is `a` at the first scale and `b` at the
second, then the two top-two gaps sum to at most `2η`. -/
theorem worst_class_switch_near_tie {d₁ d₂ : ι → ℝ} {η : ℝ} (hη : ∀ c, |d₁ c - d₂ c| ≤ η)
    {a b : ι} : (d₁ a - d₁ b) + (d₂ b - d₂ a) ≤ 2 * η := by
  have h1 := (abs_le.1 (hη a)).2
  have h2 := (abs_le.1 (hη b)).1
  linarith

omit [Fintype ι] in
/-- Each individual gap is then at most `2η`, since the other is nonnegative. -/
theorem worst_class_gap_le {d₁ d₂ : ι → ℝ} {η : ℝ} (hη : ∀ c, |d₁ c - d₂ c| ≤ η)
    {a b : ι} (hb : ∀ c, d₂ c ≤ d₂ b) : d₁ a - d₁ b ≤ 2 * η := by
  have h := worst_class_switch_near_tie hη (a := a) (b := b)
  have := hb a
  linarith

omit [Fintype ι] in
/-- **H2, the stable side.**  If at the first scale the worst class `a` leads the field by a
gap `g` strictly larger than twice the drift `η`, then the worst class at the second scale is
still `a`.  Instability therefore certifies a small top-two gap: the observed split between
moduli whose worst class is stable and moduli whose worst class moves is a statement about
gaps, not about arithmetic. -/
theorem worst_class_stable_of_gap {d₁ d₂ : ι → ℝ} {η g : ℝ} (hη : ∀ c, |d₁ c - d₂ c| ≤ η)
    {a b : ι} (ha : ∀ c, c ≠ a → d₁ c + g ≤ d₁ a) (hb : ∀ c, d₂ c ≤ d₂ b) (hg : 2 * η < g) :
    b = a := by
  by_contra hne
  have h1 := ha b hne
  have h2 := hb a
  have h3 := (abs_le.1 (hη a)).2
  have h4 := (abs_le.1 (hη b)).1
  linarith

/-! ## H3: a shrinking majority shrinks the aggregate -/

/-- **H3, as a theorem.**  Let `M` be a finite family of moduli, `D₁`, `D₂` the maximal
relative deviations at two scales.  If a subfamily `S ⊆ M` shrinks by a factor `ρ` and the
remaining moduli merely do not grow, then the aggregate deviation drops by at least
`(1−ρ)·Σ_S D₁`. -/
theorem shrink_majority_total {σ : Type*} [DecidableEq σ] (M S : Finset σ) (D₁ D₂ : σ → ℝ)
    (ρ : ℝ) (hS : S ⊆ M) (hshrink : ∀ s ∈ S, D₂ s ≤ ρ * D₁ s)
    (hrest : ∀ s ∈ M \ S, D₂ s ≤ D₁ s) :
    ∑ s ∈ M, D₂ s ≤ ∑ s ∈ M, D₁ s - (1 - ρ) * ∑ s ∈ S, D₁ s := by
  have hsplit₂ : (∑ s ∈ M \ S, D₂ s) + ∑ s ∈ S, D₂ s = ∑ s ∈ M, D₂ s :=
    Finset.sum_sdiff hS
  have hsplit₁ : (∑ s ∈ M \ S, D₁ s) + ∑ s ∈ S, D₁ s = ∑ s ∈ M, D₁ s :=
    Finset.sum_sdiff hS
  have hA : ∑ s ∈ S, D₂ s ≤ ρ * ∑ s ∈ S, D₁ s := by
    rw [Finset.mul_sum]
    exact Finset.sum_le_sum hshrink
  have hB : ∑ s ∈ M \ S, D₂ s ≤ ∑ s ∈ M \ S, D₁ s := Finset.sum_le_sum hrest
  linarith

/-- The strict version: if the shrinking factor is `< 1` and the shrinking subfamily carries
positive mass, the aggregate strictly decreases. -/
theorem shrink_majority_total_lt {σ : Type*} [DecidableEq σ] (M S : Finset σ) (D₁ D₂ : σ → ℝ)
    (ρ : ℝ) (hS : S ⊆ M) (hshrink : ∀ s ∈ S, D₂ s ≤ ρ * D₁ s)
    (hrest : ∀ s ∈ M \ S, D₂ s ≤ D₁ s) (hρ : ρ < 1) (hmass : 0 < ∑ s ∈ S, D₁ s) :
    ∑ s ∈ M, D₂ s < ∑ s ∈ M, D₁ s := by
  have h := shrink_majority_total M S D₁ D₂ ρ hS hshrink hrest
  nlinarith

end Ma1Effective