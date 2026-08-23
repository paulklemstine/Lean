/-
# NET-73, structural side: the knee is a concentration functional,
# provably decoupled from tokenization density

`Applications/NET73TokenizationDensity.lean` refutes the tokenization
hypothesis on the measured data.  This file explains *why* such a refutation was
possible at all, by isolating the quantity that does control the knee.

A **domain** is modelled by an attention profile: a tokens-per-word number
`tpw` (a surface statistic of the tokenizer) together with the *capture curve*
`cum k` = fraction of attention mass carried by the `k` heaviest keys.  The
knee at tolerance `τ` is the least `k` whose top-`k` keys already capture `τ`
of the mass.

Main results.

* `kneeAt_spec` / `lt_of_lt_kneeAt` — the knee is well defined and is the least
  such `k`; `kneeAt_mono_tol`, `kneeAt_mono_profile`, `kneeAt_congr` — it is
  monotone in the tolerance, *antitone* in the capture curve (a strictly more
  concentrated domain never needs more keys), and depends on nothing but the
  capture curve.
* `cum_le_of_step_le` and `kneeAt_ge_of_concentration` — the **concentration
  law**: if no single key carries more than `m` of the mass, then
  `k* ≥ τ / m`.  Proved by induction along the capture curve.
* `kneeAt_uniform` — the bound is tight: the uniform-mass profile with per-key
  mass `τ / k` has knee exactly `k`.
* `tpw_knee_decoupled` — **decoupling**: every pair (tokens-per-word `d`,
  knee `k`) is realised by some domain.  Hence `no_tpw_functional_law`: there is
  no function whatsoever — monotone or not — from tokens-per-word to the knee.
* `net73_data_realisable_by_concentration` — the four measured NET-73 points are
  jointly realised by concentration alone, at a single fixed tolerance.

So the knee is a *relational* functional of the attention mass profile; the
NET-73 numbers are exactly what the decoupling theorem predicts.
-/
import Mathlib
import Applications.NET73TokenizationDensity

namespace Catalog.NET73

/-! ## 1. Attention profiles and the knee -/

/-- A domain, as seen by the limited-memory axis: a tokenizer density together
with the cumulative attention mass captured by the `k` heaviest keys. -/
structure AttentionProfile where
  /-- Tokens per word of the tokenizer on this domain. -/
  tpw : ℚ
  /-- `cum k` = attention mass carried by the `k` heaviest keys. -/
  cum : ℕ → ℚ
  /-- No keys capture no mass. -/
  cum_zero : cum 0 = 0
  /-- Adding keys never loses mass. -/
  cum_mono : Monotone cum
  /-- The captured mass is a fraction. -/
  cum_le_one : ∀ k, cum k ≤ 1
  /-- Every tolerance short of the full mass is eventually met. -/
  approaches_one : ∀ τ : ℚ, τ < 1 → ∃ k, τ ≤ cum k

namespace AttentionProfile

variable (P Q : AttentionProfile)

/-- The knee: the least number of retained keys capturing a fraction `τ`. -/
noncomputable def kneeAt (τ : ℚ) : ℕ := sInf {k | τ ≤ P.cum k}

lemma kneeSet_nonempty {τ : ℚ} (hτ : τ < 1) : {k | τ ≤ P.cum k}.Nonempty := by
  obtain ⟨k, hk⟩ := P.approaches_one τ hτ
  exact ⟨k, hk⟩

/-- The knee really does capture the tolerance. -/
theorem kneeAt_spec {τ : ℚ} (hτ : τ < 1) : τ ≤ P.cum (P.kneeAt τ) :=
  Nat.sInf_mem (P.kneeSet_nonempty hτ)

/-- Below the knee the tolerance is missed: it is the *least* such index. -/
theorem lt_of_lt_kneeAt {τ : ℚ} {j : ℕ} (hj : j < P.kneeAt τ) : P.cum j < τ := by
  have : j ∉ {k | τ ≤ P.cum k} := Nat.notMem_of_lt_sInf hj
  simpa using lt_of_not_ge (by simpa using this)

/-- Any index that captures the tolerance is at least the knee. -/
theorem kneeAt_le {τ : ℚ} {k : ℕ} (hk : τ ≤ P.cum k) : P.kneeAt τ ≤ k :=
  Nat.sInf_le hk

/-- A positive tolerance needs at least one key. -/
theorem kneeAt_pos {τ : ℚ} (hτ0 : 0 < τ) (hτ1 : τ < 1) : 0 < P.kneeAt τ := by
  rcases Nat.eq_zero_or_pos (P.kneeAt τ) with h | h
  · exact absurd (P.kneeAt_spec hτ1) (by rw [h, P.cum_zero]; exact not_le.mpr hτ0)
  · exact h

/-- The knee is monotone in the tolerance. -/
theorem kneeAt_mono_tol {τ σ : ℚ} (hτσ : τ ≤ σ) (hσ : σ < 1) :
    P.kneeAt τ ≤ P.kneeAt σ :=
  P.kneeAt_le (le_trans hτσ (P.kneeAt_spec hσ))

/-- A domain whose attention is *more* concentrated (a pointwise larger capture
curve) never needs more keys.  This is the exact sense in which the knee is a
concentration functional. -/
theorem kneeAt_mono_profile {τ : ℚ} (hτ : τ < 1) (h : ∀ k, P.cum k ≤ Q.cum k) :
    Q.kneeAt τ ≤ P.kneeAt τ :=
  Q.kneeAt_le (le_trans (P.kneeAt_spec hτ) (h _))

/-- The knee ignores tokens-per-word entirely: it is a function of the capture
curve alone. -/
theorem kneeAt_congr {τ : ℚ} (h : P.cum = Q.cum) : P.kneeAt τ = Q.kneeAt τ := by
  unfold kneeAt; rw [h]

/-! ## 2. The concentration law -/

/-- If no single additional key adds more than `m` mass, the capture curve grows
at most linearly.  (Induction along the curve.) -/
theorem cum_le_of_step_le {m : ℚ} (hstep : ∀ j, P.cum (j + 1) - P.cum j ≤ m) :
    ∀ k, P.cum k ≤ k * m := by
  intro k
  induction k with
  | zero => simp [P.cum_zero]
  | succ n ih =>
      have := hstep n
      push_cast
      nlinarith [ih]

/-- **Concentration law.** If the heaviest key of a domain carries at most `m`
of the attention mass (and hence every key does), the knee is at least `τ / m`.
The knee is therefore driven by the *shape* of the attention distribution. -/
theorem kneeAt_ge_of_concentration {τ m : ℚ} (hm : 0 < m) (hτ : τ < 1)
    (hstep : ∀ j, P.cum (j + 1) - P.cum j ≤ m) :
    τ / m ≤ (P.kneeAt τ : ℚ) := by
  have h1 : τ ≤ P.cum (P.kneeAt τ) := P.kneeAt_spec hτ
  have h2 : P.cum (P.kneeAt τ) ≤ (P.kneeAt τ : ℚ) * m := P.cum_le_of_step_le hstep _
  rw [div_le_iff₀ hm]
  linarith

end AttentionProfile

/-! ## 3. Realising every (density, knee) pair -/

open AttentionProfile

/-- The uniform-mass domain: each of the first `k` keys carries `τ / k` of the
mass, so the tolerance `τ` is met exactly at the `k`-th key.  Its tokenizer
density `d` is a free parameter, unconstrained by its attention shape. -/
noncomputable def uniformProfile (d τ : ℚ) (k : ℕ) (hτ : 0 < τ) (hk : 0 < k) :
    AttentionProfile where
  tpw := d
  cum := fun j => min 1 (j * τ / k)
  cum_zero := by simp
  cum_le_one := fun j => min_le_left _ _
  cum_mono := by
    intro a b hab
    have hk' : (0 : ℚ) < (k : ℚ) := by exact_mod_cast hk
    have hab' : (a : ℚ) ≤ (b : ℚ) := by exact_mod_cast hab
    have : (a : ℚ) * τ / k ≤ (b : ℚ) * τ / k := by
      gcongr
    exact min_le_min le_rfl this
  approaches_one := by
    intro σ _
    refine ⟨k * ⌈τ⁻¹⌉₊, ?_⟩
    have hk' : (0 : ℚ) < (k : ℚ) := by exact_mod_cast hk
    have hceil : τ⁻¹ ≤ (⌈τ⁻¹⌉₊ : ℚ) := Nat.le_ceil _
    have h1 : (1 : ℚ) ≤ ((k * ⌈τ⁻¹⌉₊ : ℕ) : ℚ) * τ / k := by
      push_cast
      rw [le_div_iff₀ hk']
      have : (1 : ℚ) ≤ (⌈τ⁻¹⌉₊ : ℚ) * τ := by
        have := mul_le_mul_of_nonneg_right hceil (le_of_lt hτ)
        rwa [inv_mul_cancel₀ (ne_of_gt hτ)] at this
      nlinarith
    have hfull : (1 : ℚ) ≤ min 1 (((k * ⌈τ⁻¹⌉₊ : ℕ) : ℚ) * τ / k) := le_min le_rfl h1
    exact le_trans (le_of_lt ‹σ < 1›) hfull

/-- The uniform-mass domain has knee exactly `k`: the concentration bound
`k* ≥ τ / m` of `kneeAt_ge_of_concentration` is tight. -/
theorem kneeAt_uniform {d τ : ℚ} {k : ℕ} (hτ0 : 0 < τ) (hτ1 : τ < 1) (hk : 0 < k) :
    (uniformProfile d τ k hτ0 hk).kneeAt τ = k := by
  set P := uniformProfile d τ k hτ0 hk with hP
  have hk' : (0 : ℚ) < (k : ℚ) := by exact_mod_cast hk
  have hcum : ∀ j : ℕ, P.cum j = min 1 ((j : ℚ) * τ / k) := fun j => rfl
  have hle : P.kneeAt τ ≤ k := by
    refine P.kneeAt_le ?_
    rw [hcum k]
    have : (k : ℚ) * τ / k = τ := by field_simp
    rw [this]
    exact le_min hτ1.le le_rfl
  refine le_antisymm hle ?_
  by_contra hlt
  push_neg at hlt
  have hj : P.cum (P.kneeAt τ) < τ := by
    rw [hcum]
    have hlt' : ((P.kneeAt τ : ℕ) : ℚ) < (k : ℚ) := by exact_mod_cast hlt
    have : ((P.kneeAt τ : ℕ) : ℚ) * τ / k < τ := by
      rw [div_lt_iff₀ hk']
      nlinarith
    exact lt_of_le_of_lt (min_le_right _ _) this
  exact absurd (P.kneeAt_spec hτ1) (not_le.mpr hj)

/-- **Decoupling theorem.**  For every tolerance, every tokenizer density `d`
and every target knee `k ≥ 1` there is a domain with exactly that density and
exactly that knee.  Tokens-per-word and the knee are structurally independent
coordinates of a domain. -/
theorem tpw_knee_decoupled {τ : ℚ} (hτ0 : 0 < τ) (hτ1 : τ < 1) (d : ℚ) {k : ℕ}
    (hk : 0 < k) : ∃ P : AttentionProfile, P.tpw = d ∧ P.kneeAt τ = k :=
  ⟨uniformProfile d τ k hτ0 hk, rfl, kneeAt_uniform hτ0 hτ1 hk⟩

/-- **No functional law at all.**  Not merely no monotone law: no function of
tokens-per-word can predict the knee, because a single density supports domains
with different knees. -/
theorem no_tpw_functional_law {τ : ℚ} (hτ0 : 0 < τ) (hτ1 : τ < 1) :
    ¬ ∃ g : ℚ → ℕ, ∀ P : AttentionProfile, P.kneeAt τ = g P.tpw := by
  rintro ⟨g, hg⟩
  obtain ⟨P, hP, hP1⟩ := tpw_knee_decoupled hτ0 hτ1 1 (k := 1) (by norm_num)
  obtain ⟨Q, hQ, hQ2⟩ := tpw_knee_decoupled hτ0 hτ1 1 (k := 2) (by norm_num)
  have h1 : g 1 = 1 := by rw [← hP, ← hg P, hP1]
  have h2 : g 1 = 2 := by rw [← hQ, ← hg Q, hQ2]
  omega

/-- Two domains with the same density but different knees — the minimal
counterexample behind `no_tpw_functional_law`, at tolerance `1/2`. -/
theorem equal_density_different_knee :
    ∃ P Q : AttentionProfile,
      P.tpw = Q.tpw ∧ P.kneeAt (1/2) ≠ Q.kneeAt (1/2) := by
  refine ⟨uniformProfile 1 (1/2) 1 (by norm_num) (by norm_num),
    uniformProfile 1 (1/2) 2 (by norm_num) (by norm_num), rfl, ?_⟩
  rw [kneeAt_uniform (by norm_num) (by norm_num) (by norm_num),
    kneeAt_uniform (by norm_num) (by norm_num) (by norm_num)]
  omega

/-- The four measured NET-73 domains are realised *by concentration alone*, at a
single fixed tolerance: their densities `tpw i` and their knees `kneeN i` occur
together, exactly as the decoupling theorem allows. -/
theorem net73_data_realisable_by_concentration :
    ∃ P : Dom → AttentionProfile,
      ∀ i, (P i).tpw = tpw i ∧ (P i).kneeAt (1/2) = kneeN i := by
  have hpos : ∀ i : Dom, 0 < kneeN i := by decide
  refine ⟨fun i => uniformProfile (tpw i) (1/2) (kneeN i) (by norm_num) (hpos i),
    fun i => ⟨rfl, kneeAt_uniform (by norm_num) (by norm_num) (hpos i)⟩⟩

/-- **Synthesis.**  The knee is antitone in concentration and bounded below by
`τ / m` for per-key mass `m`, while being completely free of tokens-per-word.
That is the formal content of "the mechanism is relational, not
tokenization density". -/
theorem knee_is_concentration_not_density {τ m : ℚ} (hτ0 : 0 < τ) (hτ1 : τ < 1)
    (hm : 0 < m) :
    (∀ P : AttentionProfile, (∀ j, P.cum (j + 1) - P.cum j ≤ m) →
        τ / m ≤ (P.kneeAt τ : ℚ)) ∧
    (∀ P Q : AttentionProfile, (∀ k, P.cum k ≤ Q.cum k) →
        Q.kneeAt τ ≤ P.kneeAt τ) ∧
    (¬ ∃ g : ℚ → ℕ, ∀ P : AttentionProfile, P.kneeAt τ = g P.tpw) :=
  ⟨fun P h => P.kneeAt_ge_of_concentration hm hτ1 h,
    fun P Q h => AttentionProfile.kneeAt_mono_profile P Q hτ1 h,
    no_tpw_functional_law hτ0 hτ1⟩

end Catalog.NET73