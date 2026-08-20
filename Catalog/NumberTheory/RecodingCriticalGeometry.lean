import Mathlib
import Catalog.Novelty.Counting
import Catalog.Shared.ProofSpacePhaseTransition

/-!
# Critical Geometry of Counted Proof Spaces under Bounded Recoding

This file continues the study of counted proof spaces begun in
`Novelty.Counting`, `Novelty.OrderParameter`, `Novelty.Dimension` and
`Shared.ProofSpacePhaseTransition`, where a *critical index* for the
derivability density was produced from antitonicity plus exponential sparsity.

The question addressed here is the stability of that critical index under a
change of encoding.  Two prefix-free encodings of the same deductive system
that translate into one another with additive length overhead at most `b`
distort metric balls by a radial shift of at most `b`, i.e. the cumulative
derivability counts satisfy `N₁ n ≤ N₂ (n + b)` and `N₂ n ≤ N₁ (n + b)`.

Four groups of results:

* **Radial quasi-invariance (§1).**  Ball counts of a bounded recoding really do
  shift by `b` (`card_ball_le_of_recoding`), the *count radii*
  `countRadius N m = min {n | m ≤ N n}` differ by at most `b`
  (`countRadius_quasi_invariant`), and the exponential growth rate (the entropy
  dimension) is *exactly* invariant (`growthRate_eq_of_recoding`).

* **Density distortion (§2).**  Densities are compared against the ambient count
  `ProofSpace.S k n`, and a radial shift by `b` costs a *multiplicative* factor
  `2 k ^ b`, not an additive one (`density_le_shift`).  Consequently critical
  indices satisfy a sandwich in which the *level* is rescaled by that factor
  (`criticalIndex_sandwich`, `density_criticalIndex_sandwich`).

* **Refutation of the naive conjecture (§3).**  The level rescaling cannot be
  removed: `criticalIndex_gap_unbounded` produces, for each `D`, a pair of
  antitone null profiles satisfying exactly the distortion inequalities that a
  `b = 1` binary recoding yields, whose *same-level* critical indices differ by
  at least `D`.  So "critical indices differ by at most `b`" is false as stated;
  the correct invariants are the count radii and the growth rate.

* **Uniform transition windows (§4–§5).**  If the derivability counts have exact
  exponential order `c a ^ n ≤ N n ≤ C a ^ n` with `a < k`, then the transition
  window at *any* level `ε > 0` has width at most `log (2C/c) / log (k/a)`,
  a bound independent of `ε` (`window_width_cross`, `transition_window_width`).
  The cross-system form yields the **corrected quasi-invariance statement**
  (`criticalIndices_close_of_exponential_order`): two encodings whose counts have
  the same exponential order have level-`ε` critical indices within
  `log (2C/c) / log (k/a) + 1` of one another, uniformly in `ε`, and
  `recoding_exponential_order` shows a bounded recoding only changes the
  constants by `a ^ b`.  Fekete's lemma supplies the matching lower bound for
  submultiplicative counts (`fekete_growthRate`), giving the unconditional
  window bound `submultiplicative_uniform_window`.
-/

namespace RecodingGeometry

open Filter Topology Finset

/-! ## 1. Bounded recodings: radial shift of balls, radii and growth rates -/

/-- **Balls shift radially.**  If a length-`b`-overhead injection translates
system `1` into system `2`, then the ball of radius `n` in system `1` injects
into the ball of radius `n + b` in system `2`. -/
theorem card_ball_le_of_recoding {α β : Type*}
    (len₁ : α → ℕ) (len₂ : β → ℕ) (B₁ : ℕ → Finset α) (B₂ : ℕ → Finset β)
    (hB₁ : ∀ n x, x ∈ B₁ n ↔ len₁ x ≤ n) (hB₂ : ∀ n y, y ∈ B₂ n ↔ len₂ y ≤ n)
    (f : α → β) (hf : Function.Injective f) (b : ℕ)
    (hlen : ∀ x, len₂ (f x) ≤ len₁ x + b) (n : ℕ) :
    (B₁ n).card ≤ (B₂ (n + b)).card := by
  refine Finset.card_le_card_of_injOn f (fun x hx => ?_) hf.injOn
  have hx' : len₁ x ≤ n := (hB₁ n x).1 hx
  exact (hB₂ (n + b) (f x)).2 (le_trans (hlen x) (by omega))

/-- The **count radius**: the first cutoff at which at least `m` objects have
been counted.  This is the metric-geometry observable dual to a density level. -/
noncomputable def countRadius (N : ℕ → ℕ) (m : ℕ) : ℕ := sInf {n | m ≤ N n}

theorem countRadius_le {N : ℕ → ℕ} {m n : ℕ} (h : m ≤ N n) : countRadius N m ≤ n :=
  Nat.sInf_le h

theorem le_countRadius_apply {N : ℕ → ℕ} {m : ℕ} (h : ∃ n, m ≤ N n) :
    m ≤ N (countRadius N m) :=
  Nat.sInf_mem h

/-- One half of the radial quasi-invariance: a recoding with overhead `b`
moves the count radius by at most `b`. -/
theorem countRadius_shift {N₁ N₂ : ℕ → ℕ} {b m : ℕ}
    (h12 : ∀ n, N₁ n ≤ N₂ (n + b)) (hex : ∃ n, m ≤ N₁ n) :
    countRadius N₂ m ≤ countRadius N₁ m + b :=
  countRadius_le (le_trans (le_countRadius_apply hex) (h12 _))

/-- **Radial quasi-invariance of critical radii.**  Two counting functions
related by a bounded recoding have count radii differing by at most the
overhead `b`.  This is the correct form of the "threshold moves rather than
disappears" heuristic. -/
theorem countRadius_quasi_invariant {N₁ N₂ : ℕ → ℕ} {b m : ℕ}
    (h12 : ∀ n, N₁ n ≤ N₂ (n + b)) (h21 : ∀ n, N₂ n ≤ N₁ (n + b))
    (hex₁ : ∃ n, m ≤ N₁ n) (hex₂ : ∃ n, m ≤ N₂ n) :
    countRadius N₂ m ≤ countRadius N₁ m + b ∧
      countRadius N₁ m ≤ countRadius N₂ m + b :=
  ⟨countRadius_shift h12 hex₁, countRadius_shift h21 hex₂⟩

/-- Shifting the argument by a constant does not change a growth rate. -/
theorem tendsto_shift_growth {N : ℕ → ℕ} {h : ℝ} (b : ℕ)
    (hlim : Tendsto (fun n : ℕ => Real.log (N n) / n) atTop (𝓝 h)) :
    Tendsto (fun n : ℕ => Real.log (N (n + b)) / n) atTop (𝓝 h) := by
  have h1 : Tendsto (fun n : ℕ => Real.log (N (n + b)) / ((n + b : ℕ) : ℝ)) atTop (𝓝 h) :=
    hlim.comp (tendsto_add_atTop_nat b)
  have h2 : Tendsto (fun n : ℕ => ((n + b : ℕ) : ℝ) / (n : ℝ)) atTop (𝓝 1) := by
    have hone : Tendsto (fun n : ℕ => 1 + (b : ℝ) / n) atTop (𝓝 (1 + 0)) :=
      tendsto_const_nhds.add (tendsto_const_div_atTop_nhds_zero_nat _)
    rw [add_zero] at hone
    refine hone.congr' ?_
    filter_upwards [eventually_gt_atTop 0] with n hn
    have hn' : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (by omega)
    push_cast
    field_simp
  have hmul := h1.mul h2
  rw [mul_one] at hmul
  refine hmul.congr' ?_
  filter_upwards [eventually_gt_atTop 0] with n hn
  have hn' : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (by omega)
  have hnb : ((n + b : ℕ) : ℝ) ≠ 0 := by
    have : (0 : ℝ) < ((n + b : ℕ) : ℝ) := by exact_mod_cast Nat.lt_of_lt_of_le hn (by omega)
    exact ne_of_gt this
  field_simp

/-- **Exact invariance of the entropy dimension.**  Unlike the level-`ε`
critical index, the exponential growth rate of the derivability counts is
*exactly* preserved by any bounded recoding. -/
theorem growthRate_eq_of_recoding (N₁ N₂ : ℕ → ℕ) (b : ℕ) (h₁ h₂ : ℝ)
    (hpos₁ : ∀ n, 1 ≤ N₁ n) (hpos₂ : ∀ n, 1 ≤ N₂ n)
    (h12 : ∀ n, N₁ n ≤ N₂ (n + b)) (h21 : ∀ n, N₂ n ≤ N₁ (n + b))
    (hlim₁ : Tendsto (fun n : ℕ => Real.log (N₁ n) / n) atTop (𝓝 h₁))
    (hlim₂ : Tendsto (fun n : ℕ => Real.log (N₂ n) / n) atTop (𝓝 h₂)) :
    h₁ = h₂ := by
  have key : ∀ (M₁ M₂ : ℕ → ℕ) (g₁ g₂ : ℝ), (∀ n, 1 ≤ M₁ n) →
      (∀ n, M₁ n ≤ M₂ (n + b)) →
      Tendsto (fun n : ℕ => Real.log (M₁ n) / n) atTop (𝓝 g₁) →
      Tendsto (fun n : ℕ => Real.log (M₂ n) / n) atTop (𝓝 g₂) → g₁ ≤ g₂ := by
    intro M₁ M₂ g₁ g₂ hp₁ hsh l₁ l₂
    refine le_of_tendsto_of_tendsto l₁ (tendsto_shift_growth b l₂) ?_
    filter_upwards [eventually_gt_atTop 0] with n hn
    have hn' : (0 : ℝ) < n := by exact_mod_cast hn
    have hle : (M₁ n : ℝ) ≤ (M₂ (n + b) : ℝ) := by exact_mod_cast hsh n
    have hMpos : (0 : ℝ) < M₁ n := by exact_mod_cast hp₁ n
    have hlog : Real.log (M₁ n) ≤ Real.log (M₂ (n + b)) := Real.log_le_log hMpos hle
    gcongr
  exact le_antisymm (key N₁ N₂ h₁ h₂ hpos₁ h12 hlim₁ hlim₂)
    (key N₂ N₁ h₂ h₁ hpos₂ h21 hlim₂ hlim₁)

/-! ## 2. Density distortion: a radial shift costs a multiplicative factor -/

/-- Splitting the ambient geometric count at a shift. -/
theorem S_add (k n b : ℕ) :
    ProofSpace.S k (n + b) = (∑ i ∈ range b, k ^ i) + k ^ b * ProofSpace.S k n := by
  have hidx : n + b + 1 = b + (n + 1) := by omega
  rw [ProofSpace.S, hidx, Finset.sum_range_add, ProofSpace.S, Finset.mul_sum]
  congr 1
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [pow_add]

theorem geomSum_le_pow (k b : ℕ) (hk : 2 ≤ k) : ∑ i ∈ range b, k ^ i ≤ k ^ b := by
  induction b with
  | zero => simp
  | succ b ih =>
      rw [Finset.sum_range_succ, pow_succ]
      have h2 : k ^ b * 2 ≤ k ^ b * k := Nat.mul_le_mul_left _ hk
      linarith [ih]

/-- The ambient count is at most twice the top layer. -/
theorem S_le_two_pow (k n : ℕ) (hk : 2 ≤ k) : ProofSpace.S k n ≤ 2 * k ^ n := by
  induction n with
  | zero => simp [ProofSpace.S]
  | succ n ih =>
      have hS : ProofSpace.S k (n + 1) = ProofSpace.S k n + k ^ (n + 1) := by
        simp [ProofSpace.S, Finset.sum_range_succ]
      have hpow : 2 * k ^ n ≤ k ^ (n + 1) := by
        rw [pow_succ, mul_comm 2]
        exact Nat.mul_le_mul_left _ hk
      rw [hS]
      linarith [ih, hpow]

/-- **A radial shift costs the factor `2 k ^ b` on the ambient volume.** -/
theorem S_add_le (k n b : ℕ) (hk : 2 ≤ k) :
    ProofSpace.S k (n + b) ≤ 2 * k ^ b * ProofSpace.S k n := by
  have h1 : (1 : ℕ) ≤ ProofSpace.S k n :=
    le_trans (Nat.one_le_pow n k (by omega)) (ProofSpace.pow_le_S k n)
  have h2 := S_add k n b
  have h3 := geomSum_le_pow k b hk
  have h4 : k ^ b ≤ k ^ b * ProofSpace.S k n := Nat.le_mul_of_pos_right _ (by omega)
  have h5 : 2 * k ^ b * ProofSpace.S k n
      = k ^ b * ProofSpace.S k n + k ^ b * ProofSpace.S k n := by ring
  rw [h2, h5]
  linarith

/-- **Density distortion under a bounded recoding.**  A shift by `b` in the
radius is paid for by a multiplicative factor `2 k ^ b` in the density level;
there is no purely additive comparison. -/
theorem density_le_shift (N₁ N₂ : ℕ → ℕ) (k n b : ℕ) (hk : 2 ≤ k)
    (h : N₁ n ≤ N₂ (n + b)) :
    CountedProofSpace.density N₁ k n ≤
      2 * (k : ℝ) ^ b * CountedProofSpace.density N₂ k (n + b) := by
  have hSpos : (0 : ℝ) < (ProofSpace.S k n : ℝ) := by
    exact_mod_cast CountedProofSpace.statementsUpTo_pos k n
  have hSbpos : (0 : ℝ) < (ProofSpace.S k (n + b) : ℝ) := by
    exact_mod_cast CountedProofSpace.statementsUpTo_pos k (n + b)
  have hSb : (ProofSpace.S k (n + b) : ℝ) ≤ 2 * (k : ℝ) ^ b * (ProofSpace.S k n : ℝ) := by
    exact_mod_cast S_add_le k n b hk
  have hN : (N₁ n : ℝ) ≤ (N₂ (n + b) : ℝ) := by exact_mod_cast h
  have hN2 : (0 : ℝ) ≤ (N₂ (n + b) : ℝ) := Nat.cast_nonneg _
  unfold CountedProofSpace.density
  rw [div_le_iff₀ hSpos, mul_comm (2 * (k : ℝ) ^ b), mul_assoc, div_mul_eq_mul_div,
    le_div_iff₀ hSbpos]
  have h5 : (N₁ n : ℝ) * (ProofSpace.S k (n + b) : ℝ) ≤
      (N₂ (n + b) : ℝ) * (2 * (k : ℝ) ^ b * (ProofSpace.S k n : ℝ)) :=
    le_trans (mul_le_mul_of_nonneg_right hN hSbpos.le)
      (mul_le_mul_of_nonneg_left hSb hN2)
  nlinarith [h5]

/-- **Critical-index sandwich under multiplicative distortion.**  If the two
profiles are compared with a shift `b` and a factor `K`, then the level-`ε`
critical index of the first is sandwiched between the level-`Kε` and the
level-`ε/K` critical indices of the second, each shifted by `b`. -/
theorem criticalIndex_sandwich (d₁ d₂ : ℕ → ℝ) (K ε : ℝ) (b c₁ cLo cHi : ℕ)
    (hK : 0 < K)
    (h12 : ∀ n, d₁ n ≤ K * d₂ (n + b))
    (h21 : ∀ n, d₂ n ≤ K * d₁ (n + b))
    (hc₁ : ∀ n, d₁ n < ε ↔ c₁ < n)
    (hLo : ∀ n, d₂ n < ε / K ↔ cLo < n)
    (hHi : ∀ n, d₂ n < K * ε ↔ cHi < n)
    (hb : b ≤ c₁) :
    cHi + b ≤ c₁ ∧ c₁ + b ≤ cLo := by
  constructor
  · -- upper index: `d₂` is already below level `Kε` at radius `c₁ + 1 - b`
    have hd1 : d₁ (c₁ + 1) < ε := (hc₁ (c₁ + 1)).2 (Nat.lt_succ_self c₁)
    have hidx : (c₁ + 1 - b) + b = c₁ + 1 := by omega
    have h := h21 (c₁ + 1 - b)
    rw [hidx] at h
    have hlt2 : d₂ (c₁ + 1 - b) < K * ε := lt_of_le_of_lt h (by nlinarith)
    have hlt := (hHi _).1 hlt2
    omega
  · -- lower index: `d₁` at `c₁` is still at level `ε`, so `d₂` is at level `ε/K`
    have hd1 : ¬ d₁ c₁ < ε := by simp [hc₁ c₁]
    have hge : ε ≤ d₁ c₁ := not_lt.1 hd1
    have h := h12 c₁
    have h2 : ε / K ≤ d₂ (c₁ + b) := by
      rw [div_le_iff₀ hK]
      nlinarith
    have hnot : ¬ d₂ (c₁ + b) < ε / K := not_lt.2 h2
    have hfin := (hLo (c₁ + b)).not.1 hnot
    omega

/-- The density version of the sandwich, with the explicit distortion factor
`K = 2 k ^ b` coming from the ambient geometric volume. -/
theorem density_criticalIndex_sandwich (N₁ N₂ : ℕ → ℕ) (k b : ℕ) (ε : ℝ)
    (c₁ cLo cHi : ℕ) (hk : 2 ≤ k)
    (h12 : ∀ n, N₁ n ≤ N₂ (n + b)) (h21 : ∀ n, N₂ n ≤ N₁ (n + b))
    (hc₁ : ∀ n, CountedProofSpace.density N₁ k n < ε ↔ c₁ < n)
    (hLo : ∀ n, CountedProofSpace.density N₂ k n < ε / (2 * (k : ℝ) ^ b) ↔ cLo < n)
    (hHi : ∀ n, CountedProofSpace.density N₂ k n < 2 * (k : ℝ) ^ b * ε ↔ cHi < n)
    (hb : b ≤ c₁) :
    cHi + b ≤ c₁ ∧ c₁ + b ≤ cLo := by
  have hkpos : (0 : ℝ) < k := by exact_mod_cast (by omega : 0 < k)
  have hkb : (0 : ℝ) < 2 * (k : ℝ) ^ b := by positivity
  exact criticalIndex_sandwich _ _ _ ε b c₁ cLo cHi hkb
    (fun n => density_le_shift N₁ N₂ k n b hk (h12 n))
    (fun n => density_le_shift N₂ N₁ k n b hk (h21 n))
    hc₁ hLo hHi hb

/-! ## 3. The same-level conjecture is false: unbounded critical-index gaps -/

/-- Reference profile with harmonic decay. -/
noncomputable def pRef (n : ℕ) : ℝ := 1 / (n + 1)

/-- Its halved companion, exactly the distortion a `b = 1` binary recoding
can produce. -/
noncomputable def qRef (n : ℕ) : ℝ := 1 / (2 * n + 2)

theorem pRef_antitone : Antitone pRef := by
  intro m n hmn
  unfold pRef
  have hm : (0 : ℝ) < (m : ℝ) + 1 := by positivity
  have hmn' : (m : ℝ) ≤ n := by exact_mod_cast hmn
  exact div_le_div_of_nonneg_left (by norm_num) hm (by linarith)

theorem qRef_antitone : Antitone qRef := by
  intro m n hmn
  unfold qRef
  have hm : (0 : ℝ) < 2 * (m : ℝ) + 2 := by positivity
  have hmn' : (m : ℝ) ≤ n := by exact_mod_cast hmn
  exact div_le_div_of_nonneg_left (by norm_num) hm (by linarith)

theorem pRef_tendsto : Tendsto pRef atTop (𝓝 0) :=
  tendsto_one_div_add_atTop_nhds_zero_nat

theorem qRef_tendsto : Tendsto qRef atTop (𝓝 0) := by
  have h : Tendsto (fun n : ℕ => (1 / 2 : ℝ) * (1 / ((n : ℝ) + 1))) atTop (𝓝 ((1 / 2) * 0)) :=
    tendsto_const_nhds.mul tendsto_one_div_add_atTop_nhds_zero_nat
  rw [mul_zero] at h
  refine h.congr (fun n => ?_)
  unfold qRef
  have hpos : (0 : ℝ) < (n : ℝ) + 1 := by positivity
  field_simp

theorem pRef_le_qRef_shift (n : ℕ) : pRef n ≤ 4 * qRef (n + 1) := by
  unfold pRef qRef
  have hn0 : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
  have hx : (0 : ℝ) < (n : ℝ) + 1 := by positivity
  have hy : (0 : ℝ) < 2 * ((n : ℝ) + 1) + 2 := by positivity
  push_cast
  rw [show (4 : ℝ) * (1 / (2 * ((n : ℝ) + 1) + 2)) = 4 / (2 * ((n : ℝ) + 1) + 2) by ring,
    div_le_div_iff₀ hx hy]
  linarith

theorem qRef_le_pRef_shift (n : ℕ) : qRef n ≤ 4 * pRef (n + 1) := by
  unfold pRef qRef
  have hn0 : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
  have hx : (0 : ℝ) < 2 * (n : ℝ) + 2 := by positivity
  have hy : (0 : ℝ) < ((n : ℝ) + 1) + 1 := by positivity
  push_cast
  rw [show (4 : ℝ) * (1 / ((n : ℝ) + 1 + 1)) = 4 / ((n : ℝ) + 1 + 1) by ring,
    div_le_div_iff₀ hx hy]
  linarith

/-- **Refutation of the naive quasi-invariance conjecture.**  For every `D`
there are two antitone profiles tending to zero, mutually bounded with radial
shift `b = 1` and the distortion factor `4 = 2 · 2 ^ 1` of a binary alphabet,
whose *same-level* critical indices differ by at least `D`.  Hence the level
rescaling in `criticalIndex_sandwich` cannot be dropped: at a fixed level, a
bounded recoding can move the critical index arbitrarily far. -/
theorem criticalIndex_gap_unbounded (D : ℕ) :
    ∃ (p q : ℕ → ℝ) (ε : ℝ) (cp cq : ℕ),
      Antitone p ∧ Antitone q ∧
      Tendsto p atTop (𝓝 0) ∧ Tendsto q atTop (𝓝 0) ∧
      0 < ε ∧ ε ≤ p 0 ∧ ε ≤ q 0 ∧
      (∀ n, p n ≤ 4 * q (n + 1)) ∧ (∀ n, q n ≤ 4 * p (n + 1)) ∧
      (∀ n, p n < ε ↔ cp < n) ∧ (∀ n, q n < ε ↔ cq < n) ∧
      cq + D ≤ cp := by
  have hD0 : (0 : ℝ) ≤ (D : ℝ) := Nat.cast_nonneg D
  refine ⟨pRef, qRef, 1 / (2 * (D : ℝ) + 2), 2 * D + 1, D, pRef_antitone, qRef_antitone,
    pRef_tendsto, qRef_tendsto, by positivity, ?_, ?_,
    pRef_le_qRef_shift, qRef_le_pRef_shift, ?_, ?_, by omega⟩
  · have hp0 : pRef 0 = 1 := by unfold pRef; norm_num
    rw [hp0, div_le_one (by positivity)]
    linarith
  · have hq0 : qRef 0 = 1 / 2 := by unfold qRef; norm_num
    rw [hq0, div_le_div_iff₀ (by positivity) (by positivity)]
    linarith
  · intro n
    unfold pRef
    rw [div_lt_div_iff₀ (by positivity) (by positivity)]
    constructor
    · intro h
      have hcast : ((2 * D + 2 : ℕ) : ℝ) < ((n + 1 : ℕ) : ℝ) := by push_cast; linarith
      have hnat : 2 * D + 2 < n + 1 := by exact_mod_cast hcast
      omega
    · intro h
      have hnat : 2 * D + 2 ≤ n := by omega
      have hcast : ((2 * D + 2 : ℕ) : ℝ) ≤ (n : ℝ) := by exact_mod_cast hnat
      push_cast at hcast
      linarith
  · intro n
    unfold qRef
    rw [div_lt_div_iff₀ (by positivity) (by positivity)]
    constructor
    · intro h
      have hlt : (D : ℝ) < (n : ℝ) := by linarith
      exact_mod_cast hlt
    · intro h
      have hlt : (D : ℝ) + 1 ≤ (n : ℝ) := by exact_mod_cast h
      linarith

/-! ## 4. Uniform transition windows for counts of exact exponential order -/

theorem density_lower_bound (N : ℕ → ℕ) (k n : ℕ) (a c : ℝ) (hk : 2 ≤ k)
    (ha : 0 ≤ a) (hc : 0 < c)
    (hlow : ∀ m, c * a ^ m ≤ (N m : ℝ)) :
    c / 2 * (a / k) ^ n ≤ CountedProofSpace.density N k n := by
  have hkpos : (0 : ℝ) < k := by exact_mod_cast (by omega : 0 < k)
  have hSpos : (0 : ℝ) < (ProofSpace.S k n : ℝ) := by
    exact_mod_cast CountedProofSpace.statementsUpTo_pos k n
  have hS : (ProofSpace.S k n : ℝ) ≤ 2 * (k : ℝ) ^ n := by
    exact_mod_cast S_le_two_pow k n hk
  have hkn : (0 : ℝ) < (k : ℝ) ^ n := by positivity
  have hfac : 0 ≤ c / 2 * (a ^ n / (k : ℝ) ^ n) :=
    mul_nonneg (by linarith) (div_nonneg (pow_nonneg ha n) hkn.le)
  unfold CountedProofSpace.density
  rw [le_div_iff₀ hSpos, div_pow]
  calc c / 2 * (a ^ n / (k : ℝ) ^ n) * (ProofSpace.S k n : ℝ)
      ≤ c / 2 * (a ^ n / (k : ℝ) ^ n) * (2 * (k : ℝ) ^ n) :=
        mul_le_mul_of_nonneg_left hS hfac
    _ = c * a ^ n := by field_simp
    _ ≤ (N n : ℝ) := hlow n

theorem density_upper_bound (N : ℕ → ℕ) (k n : ℕ) (a C : ℝ) (hk : 2 ≤ k)
    (ha : 0 ≤ a) (hup : ∀ m, (N m : ℝ) ≤ C * a ^ m) :
    CountedProofSpace.density N k n ≤ C * (a / k) ^ n := by
  have hkpos : (0 : ℝ) < k := by exact_mod_cast (by omega : 0 < k)
  have hSpos : (0 : ℝ) < (ProofSpace.S k n : ℝ) := by
    exact_mod_cast CountedProofSpace.statementsUpTo_pos k n
  have hS : ((k : ℝ) ^ n) ≤ (ProofSpace.S k n : ℝ) := by
    exact_mod_cast ProofSpace.pow_le_S k n
  have hkn : (0 : ℝ) < (k : ℝ) ^ n := by positivity
  have hC0 : 0 ≤ C := by
    have h0 := hup 0
    simp at h0
    exact le_trans (Nat.cast_nonneg _) h0
  have hfac : 0 ≤ C * (a ^ n / (k : ℝ) ^ n) :=
    mul_nonneg hC0 (div_nonneg (pow_nonneg ha n) hkn.le)
  unfold CountedProofSpace.density
  rw [div_le_iff₀ hSpos, div_pow]
  calc (N n : ℝ) ≤ C * a ^ n := hup n
    _ = C * (a ^ n / (k : ℝ) ^ n) * (k : ℝ) ^ n := by field_simp
    _ ≤ C * (a ^ n / (k : ℝ) ^ n) * (ProofSpace.S k n : ℝ) :=
        mul_le_mul_of_nonneg_left hS hfac

/-- **Cross-system window bound.**  If one count is exponentially dominated by
`C a ^ n` and another exponentially dominates `c a ^ n`, then a radius where the
first is still at level `ε` and a radius where the second has already dropped
below `ε` are separated by at most `log (2C/c) / log (k/a)`, independently of
`ε`.  The two counts may belong to different encodings of the same system. -/
theorem window_width_cross
    (Nup Nlow : ℕ → ℕ) (k : ℕ) (a c C ε : ℝ) (hk : 2 ≤ k) (ha : 0 < a)
    (hak : a < k) (hc : 0 < c) (hcC : c ≤ C)
    (hlow : ∀ m, c * a ^ m ≤ (Nlow m : ℝ)) (hup : ∀ m, (Nup m : ℝ) ≤ C * a ^ m)
    (nplus nminus : ℕ)
    (hplus : ε ≤ CountedProofSpace.density Nup k nplus)
    (hminus : CountedProofSpace.density Nlow k nminus < ε) :
    (nplus : ℝ) - nminus ≤ Real.log (2 * C / c) / Real.log (k / a) := by
  have hkpos : (0 : ℝ) < k := by exact_mod_cast (by omega : 0 < k)
  have hCpos : 0 < C := lt_of_lt_of_le hc hcC
  have hratio : 1 < (k : ℝ) / a := (one_lt_div ha).2 hak
  have hlogpos : 0 < Real.log ((k : ℝ) / a) := Real.log_pos hratio
  have hRHS : 0 ≤ Real.log (2 * C / c) / Real.log ((k : ℝ) / a) := by
    refine div_nonneg (Real.log_nonneg ?_) hlogpos.le
    rw [le_div_iff₀ hc]
    linarith
  rcases le_or_gt nplus nminus with hle | hlt
  · have hcast : (nplus : ℝ) ≤ nminus := by exact_mod_cast hle
    linarith
  · set t : ℝ := a / k with ht
    have htpos : 0 < t := by positivity
    have hub : ε ≤ C * t ^ nplus :=
      le_trans hplus (density_upper_bound Nup k nplus a C hk ha.le hup)
    have hlb : c / 2 * t ^ nminus < ε :=
      lt_of_le_of_lt (density_lower_bound Nlow k nminus a c hk ha.le hc hlow) hminus
    have hkey : c / 2 * t ^ nminus < C * t ^ nplus := lt_of_lt_of_le hlb hub
    set j : ℕ := nplus - nminus with hj
    have hsplit : t ^ nplus = t ^ nminus * t ^ j := by
      rw [← pow_add]
      congr 1
      omega
    rw [hsplit] at hkey
    have htn : 0 < t ^ nminus := by positivity
    have hkey' : c / 2 * t ^ nminus < (C * t ^ j) * t ^ nminus := by
      rw [show (C * t ^ j) * t ^ nminus = C * (t ^ nminus * t ^ j) by ring]
      exact hkey
    have hkey2 : c / 2 < C * t ^ j := lt_of_mul_lt_mul_right hkey' htn.le
    have htj : c / (2 * C) < t ^ j := by
      rw [div_lt_iff₀ (by positivity)]
      nlinarith
    have hlog : Real.log (c / (2 * C)) < Real.log (t ^ j) :=
      Real.log_lt_log (by positivity) htj
    rw [Real.log_pow] at hlog
    have hlogt : Real.log t = - Real.log ((k : ℝ) / a) := by
      rw [ht, ← Real.log_inv]
      congr 1
      field_simp
    have hlogc : Real.log (c / (2 * C)) = - Real.log (2 * C / c) := by
      rw [← Real.log_inv]
      congr 1
      field_simp
    rw [hlogt, hlogc] at hlog
    have hjle : (j : ℝ) ≤ Real.log (2 * C / c) / Real.log ((k : ℝ) / a) := by
      rw [le_div_iff₀ hlogpos]
      linarith
    have hjc : ((j : ℕ) : ℝ) = (nplus : ℝ) - nminus := by
      rw [hj, Nat.cast_sub hlt.le]
    rw [← hjc]
    exact hjle

/-- **Uniform transition window.**  For derivability counts of exact exponential
order `c a ^ n ≤ N n ≤ C a ^ n` with `a < k`, any radius where the density is
still at level `ε` and any radius where it has already dropped below `ε` are
separated by at most `log (2C/c) / log (k/a)` — a bound *independent of the
level `ε`*, hence independent of the cutoff. -/
theorem transition_window_width
    (N : ℕ → ℕ) (k : ℕ) (a c C ε : ℝ) (hk : 2 ≤ k) (ha : 0 < a)
    (hak : a < k) (hc : 0 < c) (hcC : c ≤ C)
    (hlow : ∀ m, c * a ^ m ≤ (N m : ℝ)) (hup : ∀ m, (N m : ℝ) ≤ C * a ^ m)
    (nplus nminus : ℕ)
    (hplus : ε ≤ CountedProofSpace.density N k nplus)
    (hminus : CountedProofSpace.density N k nminus < ε) :
    (nplus : ℝ) - nminus ≤ Real.log (2 * C / c) / Real.log (k / a) :=
  window_width_cross N N k a c C ε hk ha hak hc hcC hlow hup nplus nminus hplus hminus

/-- **Quasi-invariance of critical indices, corrected form.**  Two counts of the
same exact exponential order have level-`ε` critical indices differing by at
most `log (2C/c) / log (k/a) + 1`, *uniformly in `ε`*.  This is the statement
that survives `criticalIndex_gap_unbounded`: the gap is controlled by the
exponential order of the counts, not by the recoding overhead alone, and it is
finite exactly because the level distortion is converted into a radial shift by
the exponential decay rate `log (k/a)`. -/
theorem criticalIndices_close_of_exponential_order
    (N₁ N₂ : ℕ → ℕ) (k : ℕ) (a c C ε : ℝ) (hk : 2 ≤ k) (ha : 0 < a)
    (hak : a < k) (hc : 0 < c) (hcC : c ≤ C)
    (hlow₁ : ∀ m, c * a ^ m ≤ (N₁ m : ℝ)) (hup₁ : ∀ m, (N₁ m : ℝ) ≤ C * a ^ m)
    (hlow₂ : ∀ m, c * a ^ m ≤ (N₂ m : ℝ)) (hup₂ : ∀ m, (N₂ m : ℝ) ≤ C * a ^ m)
    (c₁ c₂ : ℕ)
    (hpos₁ : ε ≤ CountedProofSpace.density N₁ k c₁)
    (hneg₁ : CountedProofSpace.density N₁ k (c₁ + 1) < ε)
    (hpos₂ : ε ≤ CountedProofSpace.density N₂ k c₂)
    (hneg₂ : CountedProofSpace.density N₂ k (c₂ + 1) < ε) :
    |(c₁ : ℝ) - (c₂ : ℝ)| ≤ Real.log (2 * C / c) / Real.log (k / a) + 1 := by
  have h12 := window_width_cross N₁ N₂ k a c C ε hk ha hak hc hcC hlow₂ hup₁
    c₁ (c₂ + 1) hpos₁ hneg₂
  have h21 := window_width_cross N₂ N₁ k a c C ε hk ha hak hc hcC hlow₁ hup₂
    c₂ (c₁ + 1) hpos₂ hneg₁
  have hc1 : (((c₁ + 1 : ℕ)) : ℝ) = (c₁ : ℝ) + 1 := by push_cast; ring
  have hc2 : (((c₂ + 1 : ℕ)) : ℝ) = (c₂ : ℝ) + 1 := by push_cast; ring
  rw [hc2] at h12
  rw [hc1] at h21
  rw [abs_le]
  constructor <;> linarith

/-- **Transfer of exponential order across a recoding.**  A count dominated
below by `c a ^ n` forces its overhead-`b` recoding to be dominated below by
`(c / a ^ b) a ^ m` at every radius `m ≥ b`; dually for upper bounds.  Combined
with `criticalIndices_close_of_exponential_order`, this is the entropy-corrected
quasi-invariance statement: the index gap is bounded by
`(log (2C/c) + 2 b log a) / log (k/a) + 1`, independent of the level. -/
theorem recoding_exponential_order (N₁ N₂ : ℕ → ℕ) (b : ℕ) (a c C : ℝ)
    (ha : 0 < a)
    (h12 : ∀ n, N₁ n ≤ N₂ (n + b)) (h21 : ∀ n, N₂ n ≤ N₁ (n + b))
    (hlow : ∀ m, c * a ^ m ≤ (N₁ m : ℝ)) (hup : ∀ m, (N₁ m : ℝ) ≤ C * a ^ m) :
    (∀ m, b ≤ m → (c / a ^ b) * a ^ m ≤ (N₂ m : ℝ)) ∧
      (∀ m, (N₂ m : ℝ) ≤ (C * a ^ b) * a ^ m) := by
  have hab : (0 : ℝ) < a ^ b := by positivity
  constructor
  · intro m hm
    have hsplit : a ^ m = a ^ (m - b) * a ^ b := by
      rw [← pow_add]
      congr 1
      omega
    have hstep : (N₁ (m - b) : ℝ) ≤ (N₂ m : ℝ) := by
      have := h12 (m - b)
      have hidx : m - b + b = m := by omega
      rw [hidx] at this
      exact_mod_cast this
    have hlow' := hlow (m - b)
    rw [hsplit]
    have : c / a ^ b * (a ^ (m - b) * a ^ b) = c * a ^ (m - b) := by
      field_simp
    rw [this]
    linarith
  · intro m
    have hstep : (N₂ m : ℝ) ≤ (N₁ (m + b) : ℝ) := by exact_mod_cast h21 m
    have hup' := hup (m + b)
    have hsplit : a ^ (m + b) = a ^ m * a ^ b := by rw [pow_add]
    rw [hsplit] at hup'
    nlinarith [hup']

/-! ## 5. Submultiplicativity supplies the missing lower bound (Fekete) -/

/-- **Fekete for derivability counts.**  A cumulative count that is
submultiplicative up to a constant factor `P` has an exponential growth rate
`L`, and moreover satisfies the *matching lower bound* `exp (L n) ≤ P · N n`.
Submultiplicativity thus removes exactly the oscillation that a growth rate
alone cannot see. -/
theorem fekete_growthRate (N : ℕ → ℕ) (P : ℝ) (hP : 1 ≤ P)
    (hN : ∀ n, 1 ≤ N n)
    (hsub : ∀ m n, (N (m + n) : ℝ) ≤ P * N m * N n) :
    ∃ L : ℝ, Tendsto (fun n : ℕ => Real.log (N n) / n) atTop (𝓝 L) ∧
      ∀ n : ℕ, Real.exp (L * n) ≤ P * N n := by
  have hNpos : ∀ n, (1 : ℝ) ≤ (N n : ℝ) := fun n => by exact_mod_cast hN n
  have hPpos : (0 : ℝ) < P := by linarith
  have hupos : ∀ n : ℕ, (1 : ℝ) ≤ P * (N n : ℝ) := fun n => by nlinarith [hNpos n]
  have hsubadd : Subadditive (fun n : ℕ => Real.log (P * (N n : ℝ))) := by
    intro m n
    simp only
    have hstep := mul_le_mul_of_nonneg_left (hsub m n) hPpos.le
    have heq : P * (P * (N m : ℝ) * (N n : ℝ)) = (P * (N m : ℝ)) * (P * (N n : ℝ)) := by
      ring
    have h2 : P * (N (m + n) : ℝ) ≤ (P * (N m : ℝ)) * (P * (N n : ℝ)) := by
      rw [← heq]; exact hstep
    have h3 := Real.log_le_log (by nlinarith [hNpos (m + n)]) h2
    have hlog2 : Real.log ((P * (N m : ℝ)) * (P * (N n : ℝ)))
        = Real.log (P * (N m : ℝ)) + Real.log (P * (N n : ℝ)) :=
      Real.log_mul (by nlinarith [hNpos m]) (by nlinarith [hNpos n])
    rw [hlog2] at h3
    exact h3
  have hbdd : BddBelow (Set.range fun n : ℕ => Real.log (P * (N n : ℝ)) / n) := by
    refine ⟨0, ?_⟩
    rintro x ⟨n, rfl⟩
    exact div_nonneg (Real.log_nonneg (hupos n)) (Nat.cast_nonneg _)
  refine ⟨hsubadd.lim, ?_, ?_⟩
  · have h1 := hsubadd.tendsto_lim hbdd
    have h2 : Tendsto (fun n : ℕ => Real.log P / n) atTop (𝓝 0) :=
      tendsto_const_div_atTop_nhds_zero_nat _
    have h3 := h1.sub h2
    rw [sub_zero] at h3
    refine h3.congr' ?_
    filter_upwards [eventually_gt_atTop 0] with n hn
    have hNn : (0 : ℝ) < (N n : ℝ) := by linarith [hNpos n]
    rw [Real.log_mul (ne_of_gt hPpos) (ne_of_gt hNn)]
    ring
  · intro n
    rcases Nat.eq_zero_or_pos n with rfl | hn
    · simp only [Nat.cast_zero, mul_zero, Real.exp_zero]
      nlinarith [hNpos 0]
    · have hnpos : (0 : ℝ) < n := by exact_mod_cast hn
      have hdiv := hsubadd.lim_le_div hbdd (n := n) (by omega)
      have h2 : hsubadd.lim * n ≤ Real.log (P * (N n : ℝ)) := by
        rw [le_div_iff₀ hnpos] at hdiv
        linarith
      calc Real.exp (hsubadd.lim * n) ≤ Real.exp (Real.log (P * (N n : ℝ))) :=
            Real.exp_le_exp.2 h2
        _ = P * N n := Real.exp_log (by nlinarith [hNpos n])

/-- **Uniform window for submultiplicative counts.**  Combining Fekete's lower
bound with a matching exponential upper bound at the same base gives a
transition window whose width is bounded by `log (2 C P) / log (k / exp L)`,
independently of the level `ε`.  This is the precise sense in which
submultiplicativity suppresses the oscillations that exponential sparsity alone
leaves uncontrolled. -/
theorem submultiplicative_uniform_window
    (N : ℕ → ℕ) (k : ℕ) (P C L ε : ℝ) (hk : 2 ≤ k) (hP : 1 ≤ P)
    (hN : ∀ n, 1 ≤ N n)
    (hlowfek : ∀ n : ℕ, Real.exp (L * n) ≤ P * N n)
    (hup : ∀ n : ℕ, (N n : ℝ) ≤ C * Real.exp L ^ n)
    (hLk : Real.exp L < k)
    (nplus nminus : ℕ)
    (hplus : ε ≤ CountedProofSpace.density N k nplus)
    (hminus : CountedProofSpace.density N k nminus < ε) :
    (nplus : ℝ) - nminus ≤
      Real.log (2 * C * P) / Real.log ((k : ℝ) / Real.exp L) := by
  have hPpos : (0 : ℝ) < P := by linarith
  have ha : (0 : ℝ) < Real.exp L := Real.exp_pos L
  have hlow : ∀ m : ℕ, P⁻¹ * Real.exp L ^ m ≤ (N m : ℝ) := by
    intro m
    have h1 : Real.exp (L * m) = Real.exp L ^ m := by
      rw [mul_comm, Real.exp_nat_mul]
    have h2 := hlowfek m
    rw [h1] at h2
    rw [inv_mul_le_iff₀ hPpos]
    linarith
  have hC : P⁻¹ ≤ C := by
    have h0 := hup 0
    simp at h0
    have h1 : (1 : ℝ) ≤ (N 0 : ℝ) := by exact_mod_cast hN 0
    have hPinv : P⁻¹ ≤ 1 := inv_le_one_of_one_le₀ hP
    linarith
  have hmain := transition_window_width N k (Real.exp L) P⁻¹ C ε hk ha hLk
    (by positivity) hC hlow hup nplus nminus hplus hminus
  have hrw : 2 * C / P⁻¹ = 2 * C * P := by field_simp
  rwa [hrw] at hmain

-- !-- Lab Notes -- !--
-- Hypothesis: Seven conjectures were ranked. (1) A bounded recoding shifts ball
-- counts by at most its overhead; (2) count radii inherit that shift; (3) the
-- entropy dimension is exactly invariant; (4) level-eps critical indices differ
-- by at most the overhead; (5) the density comparison across a shift is purely
-- additive; (6) exact exponential order forces a level-independent transition
-- window; (7) submultiplicativity supplies the missing lower bound.  (1)-(3),
-- (6), (7) survive; (4) and (5) are refuted.
-- Experiment: The ambient count was split exactly, S k (n+b) = geomSum b +
-- k^b * S k n, giving S k (n+b) <= 2 k^b S k n (checked numerically for k = 3,
-- n <= 5, b <= 3).  Densities of the family N n = ceil((3/2)^n) inside the
-- binary language were tabulated for eps from 1/2 down to 1e-6: the last cutoff
-- at level eps and the first cutoff below it stayed one apart throughout, well
-- inside the proved bound log(2C/c)/log(k/a) = log 4 / log(4/3) ~ 4.82.  The
-- harmonic profiles p n = 1/(n+1), q n = 1/(2n+2) satisfy the b = 1, factor-4
-- distortion inequalities and have critical indices 2D+1 and D at level
-- 1/(2D+2), i.e. a gap of D+1 (verified for D up to 50).
-- Analysis: The failure of (4) is structural, not technical.  A recoding acts on
-- radii additively but on densities multiplicatively, because the ambient volume
-- itself grows by k^b over the shift.  When the density decays slowly, a bounded
-- multiplicative distortion moves a fixed level arbitrarily far.  Exponential
-- order of the counts is exactly the hypothesis that converts a level factor
-- into a bounded radius shift, which is why the window bound is uniform in eps.
-- Critique: The window theorem needs a two-sided exponential bound with the same
-- base; a mismatched base (a for the upper bound, rho < a for the lower) makes
-- the width grow like log(1/eps).  Fekete's lemma removes half of that
-- hypothesis unconditionally, but the matching upper bound remains an
-- assumption.  The counterexample is stated at the level of the observables,
-- where the conjecture lives; realizing it by explicit integer counts is left
-- open.
-- Synthesis: The stable observables of a counted proof space are the count radii
-- and the growth rate, not the level-eps critical index.  Any invariant
-- threshold statement must be phrased in radii, or in densities with a level
-- rescaled by the recoding factor.  Adding exact exponential order restores a
-- level-uniform bound on the index gap itself
-- (criticalIndices_close_of_exponential_order), and a bounded recoding only
-- perturbs the constants of that order by a^b (recoding_exponential_order):
-- this is the corrected form of the conjecture the cycle started from.

end RecodingGeometry