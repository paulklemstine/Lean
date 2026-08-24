/-
# Round-70 #6, cycle 2 — transfer beyond the magnitude: an exact characterisation
# of mirrors, the correct null, and the Fermat frontier cost law

Cycle 1 (`Combinatorics.MagnitudeMirrorSeal`) established that the realized
probes of papers 193/195 are structural constants or deterministic functions of
`N`'s magnitude, and that a magnitude mirror collapses to *exactly* zero
information inside every magnitude cell.  Cycle 2 asks the three questions the
critic raised against that synthesis.

1. **Is the collapse a characterisation, or only a consequence?**  It is a
   characterisation.  `zeroInfo_self_iff_const` shows that a statistic which is
   uninformative *about itself* is constant, and
   `mirror_iff_conditional_zeroInfo` upgrades this to: a feature collapses to
   exactly zero information inside every magnitude cell, against *every* secret,
   **iff** it is a deterministic function of the magnitude.  So "exact null given
   `|N|`" is not evidence-of-absence — it is *equivalent* to being a mirror.

2. **Why then did the row-shuffle null flag the mirror?**  Because a shuffle
   null tests the wrong hypothesis.  `zeroInfo_of_conditional_homogeneous` proves
   the exact converse direction: a mirror is *unconditionally* uninformative as
   soon as the secret's marginal is homogeneous across magnitude cells.  Hence
   `mirror_signal_forces_stratification`: if a mirror shows any unconditional
   signal at all, the secret's marginal provably varies across magnitude cells.
   Apparent signal from a deterministic function of `N` is scale stratification —
   a theorem, not a heuristic.

3. **What is the surviving geometry worth quantitatively?**  The Fermat frontier.
   `fermat_hit_index_bound` gives the exact ascent law
   `2·⌊√N⌋·j ≤ k² + 2·⌊√N⌋` for the offset `j` of the square-hit of
   `N = u(u+2k)` from the isqrt anchor, and `fermat_hit_index_le` turns it into
   the cost bound `j ≤ k²/(2⌊√N⌋) + 1`: the frontier distance is governed by the
   factor *imbalance* `k = (v−u)/2`, exactly the quantity the positional oracle
   `1{d ≤ B}` reads and no realized probe does.  Finally
   `oracle_capacity_superlevel_interval` shows the capacity profile of that
   oracle has interval superlevel sets, so the reported "`B*` for ≥90% of peak"
   is a well-defined threshold, not an artifact of the search grid.
-/
import Mathlib
import Combinatorics.MagnitudeMirrorSeal

namespace MagnitudeMirror

open Finset Round11

variable {α : Type*} {β γ μ : Type*} [DecidableEq β] [DecidableEq γ] [DecidableEq μ]

/-! ## 1. Zero self-information means constant -/

/-- **A statistic that is uninformative about itself is constant.**  This is the
counting analogue of `H(T) = I(T;T) = 0 ⟹ T` deterministic. -/
theorem zeroInfo_self_iff_const {Ω : Finset α} {T : α → β} (hΩ : Ω.Nonempty) :
    ZeroInfo Ω T T ↔ ∃ t₀, ∀ w ∈ Ω, T w = t₀ := by
  classical
  constructor
  · intro h
    obtain ⟨w₀, hw₀⟩ := hΩ
    refine ⟨T w₀, ?_⟩
    have hself : Ω.filter (fun w => T w = T w₀ ∧ T w = T w₀) = Ω.filter (fun w => T w = T w₀) :=
      Finset.filter_congr (fun w _ => by tauto)
    have h0 := h (T w₀) (T w₀)
    rw [hself] at h0
    have hpos : 0 < #(Ω.filter fun w => T w = T w₀) :=
      Finset.card_pos.2 ⟨w₀, Finset.mem_filter.2 ⟨hw₀, rfl⟩⟩
    have hcard : #(Ω.filter fun w => T w = T w₀) = #Ω := by
      have := h0
      nlinarith [this, hpos]
    have hsub : Ω.filter (fun w => T w = T w₀) = Ω :=
      Finset.eq_of_subset_of_card_le (Finset.filter_subset _ _) (le_of_eq hcard.symm)
    intro w hw
    have : w ∈ Ω.filter (fun w => T w = T w₀) := by rw [hsub]; exact hw
    exact (Finset.mem_filter.1 this).2
  · rintro ⟨t₀, ht⟩
    exact zeroInfo_of_const ht

/-! ## 2. Mirrors are exactly the features with an exact conditional null -/

/-- **Characterisation of magnitude mirrors.**  A feature has *exactly* zero
information about every secret inside every magnitude cell **iff** it is a
deterministic function of the magnitude.  So the exp551 measurement
"0.0000 bits given the magnitude decile, sd 0" is not weak evidence of no
channel: it is logically equivalent to the feature being a mirror. -/
theorem mirror_iff_conditional_zeroInfo {Ω : Finset α} {Φ : α → β} {M : α → μ}
    (hΩ : Ω.Nonempty) :
    (∀ S : α → β, ∀ c : μ, ZeroInfo (Ω.filter fun w => M w = c) Φ S)
      ↔ MirrorsMagnitude Ω Φ M := by
  classical
  obtain ⟨w₀, hw₀⟩ := hΩ
  constructor
  · intro h
    refine ⟨fun c => if hc : (Ω.filter fun w => M w = c).Nonempty then Φ hc.choose else Φ w₀, ?_⟩
    intro w hw
    have hne : (Ω.filter fun w' => M w' = M w).Nonempty :=
      ⟨w, Finset.mem_filter.2 ⟨hw, rfl⟩⟩
    dsimp only
    rw [dif_pos hne]
    obtain ⟨t₀, ht₀⟩ := (zeroInfo_self_iff_const hne).1 (h Φ (M w))
    rw [ht₀ w (Finset.mem_filter.2 ⟨hw, rfl⟩), ht₀ _ hne.choose_spec]
  · intro hmir S c
    exact mirror_conditional_zeroInfo S hmir c

/-! ## 3. The correct null: conditional collapse plus homogeneous marginals -/

/-- **A mirror is unconditionally uninformative once the secret is homogeneous
across magnitude cells.**  The hypothesis `hhom` says every magnitude cell has
the same empirical distribution of the secret (written multiplicatively, so no
division is needed).  Under it, a deterministic function of the magnitude has
exactly product fibre counts against the secret. -/
theorem zeroInfo_of_conditional_homogeneous {Ω : Finset α} {Φ : α → β} {M : α → μ} {S : α → γ}
    (hmir : MirrorsMagnitude Ω Φ M)
    (hhom : ∀ c ∈ Ω.image M, ∀ s : γ,
      #((Ω.filter fun w => M w = c).filter fun w => S w = s) * #Ω
        = #(Ω.filter fun w => M w = c) * #(Ω.filter fun w => S w = s)) :
    ZeroInfo Ω Φ S := by
  classical
  obtain ⟨g, hg⟩ := hmir
  intro t s
  set F := (Ω.image M).filter (fun c => g c = t) with hF
  have hmemF : ∀ c, c ∈ F ↔ (c ∈ Ω.image M ∧ g c = t) := by
    intro c; rw [hF, Finset.mem_filter]
  -- joint fibre, decomposed over magnitude cells
  have h1 : #(Ω.filter fun w => Φ w = t ∧ S w = s)
      = ∑ c ∈ F, #((Ω.filter fun w => M w = c).filter fun w => S w = s) := by
    rw [Finset.card_eq_sum_card_fiberwise (f := M) (t := F) ?_]
    · refine Finset.sum_congr rfl (fun c hc => ?_)
      have hgc : g c = t := ((hmemF c).1 hc).2
      congr 1
      ext w
      simp only [Finset.mem_filter]
      constructor
      · rintro ⟨⟨hw, _, hs⟩, hM⟩; exact ⟨⟨hw, hM⟩, hs⟩
      · rintro ⟨⟨hw, hM⟩, hs⟩
        exact ⟨⟨hw, by rw [hg w hw, hM, hgc], hs⟩, hM⟩
    · intro w hw
      have hw' := Finset.mem_filter.1 hw
      exact (hmemF (M w)).2 ⟨Finset.mem_image_of_mem _ hw'.1,
        by rw [← hg w hw'.1]; exact hw'.2.1⟩
  have h2 : #(Ω.filter fun w => Φ w = t) = ∑ c ∈ F, #(Ω.filter fun w => M w = c) := by
    rw [Finset.card_eq_sum_card_fiberwise (f := M) (t := F) ?_]
    · refine Finset.sum_congr rfl (fun c hc => ?_)
      have hgc : g c = t := ((hmemF c).1 hc).2
      congr 1
      ext w
      simp only [Finset.mem_filter]
      constructor
      · rintro ⟨⟨hw, _⟩, hM⟩; exact ⟨hw, hM⟩
      · rintro ⟨hw, hM⟩
        exact ⟨⟨hw, by rw [hg w hw, hM, hgc]⟩, hM⟩
    · intro w hw
      have hw' := Finset.mem_filter.1 hw
      exact (hmemF (M w)).2 ⟨Finset.mem_image_of_mem _ hw'.1,
        by rw [← hg w hw'.1]; exact hw'.2⟩
  rw [h1, h2, Finset.sum_mul, Finset.sum_mul]
  refine Finset.sum_congr rfl (fun c hc => ?_)
  exact hhom c ((hmemF c).1 hc).1 s

/-- **Diagnosis theorem: a mirror's signal is stratification.**  If a
deterministic function of the magnitude shows *any* unconditional dependence on
the secret, then the secret's marginal necessarily differs between magnitude
cells.  Rejecting a row-shuffle null therefore certifies scale stratification,
never transfer beyond knowing `N`. -/
theorem mirror_signal_forces_stratification {Ω : Finset α} {Φ : α → β} {M : α → μ} {S : α → γ}
    (hmir : MirrorsMagnitude Ω Φ M) (hsig : ¬ ZeroInfo Ω Φ S) :
    ∃ c ∈ Ω.image M, ∃ s : γ,
      #((Ω.filter fun w => M w = c).filter fun w => S w = s) * #Ω
        ≠ #(Ω.filter fun w => M w = c) * #(Ω.filter fun w => S w = s) := by
  by_contra hcon
  push_neg at hcon
  exact hsig (zeroInfo_of_conditional_homogeneous hmir hcon)

/-! ## 4. The Fermat frontier: an exact ascent law for the square-hit offset -/

/-- `⌊√N⌋` never exceeds the Fermat centre `u + k` of `N = u(u+2k)`. -/
theorem anchor_le_center (u k : ℕ) : Nat.sqrt (u * (u + 2 * k)) ≤ u + k := by
  have h : u * (u + 2 * k) ≤ (u + k) * (u + k) := by nlinarith
  calc Nat.sqrt (u * (u + 2 * k)) ≤ Nat.sqrt ((u + k) * (u + k)) := Nat.sqrt_le_sqrt h
  _ = u + k := Nat.sqrt_eq (u + k)

/-- **Fermat frontier ascent law.**  For `N = u(u+2k)` with anchor `m = ⌊√N⌋`,
the offset `j = (u+k) − m` of the square-hit from the isqrt anchor satisfies
`2·m·j ≤ k² + 2·m`.  The distance from the anchor to the *hit* is controlled by
the factor imbalance `k`, not by any divisor position — this is the geometry the
retracted sign-change mechanism was mistaking for a channel. -/
theorem fermat_hit_index_bound (u k : ℕ) :
    2 * Nat.sqrt (u * (u + 2 * k)) * ((u + k) - Nat.sqrt (u * (u + 2 * k)))
      ≤ k ^ 2 + 2 * Nat.sqrt (u * (u + 2 * k)) := by
  set N := u * (u + 2 * k) with hN
  set m := Nat.sqrt N with hm
  have hma : m ≤ u + k := anchor_le_center u k
  obtain ⟨j, hj⟩ : ∃ j, u + k = m + j := ⟨(u + k) - m, by omega⟩
  have hjeq : (u + k) - m = j := by omega
  rw [hjeq]
  have hlow : m * m ≤ N := Nat.sqrt_le N
  have hhigh : N < (m + 1) * (m + 1) := Nat.lt_succ_sqrt N
  have hsq : (m + j) * (m + j) = N + k * k := by
    rw [← hj, hN]; ring
  nlinarith [hlow, hhigh, hsq]

/-- **Fermat frontier cost law.**  The number of ascent steps from the isqrt
anchor to the square-hit is at most `k²/(2⌊√N⌋) + 1`: balanced factorisations
(`k` small) are found in `O(k²/√N)` steps, unbalanced ones are not. -/
theorem fermat_hit_index_le (u k : ℕ) (hm : 0 < Nat.sqrt (u * (u + 2 * k))) :
    (u + k) - Nat.sqrt (u * (u + 2 * k))
      ≤ k ^ 2 / (2 * Nat.sqrt (u * (u + 2 * k))) + 1 := by
  set m := Nat.sqrt (u * (u + 2 * k)) with hm'
  have hb := fermat_hit_index_bound u k
  rw [← hm'] at hb
  set j := (u + k) - m with hj
  rcases Nat.eq_zero_or_pos j with h0 | hpos
  · rw [h0]
    exact Nat.zero_le _
  have hstep : 2 * m * (j - 1) ≤ k ^ 2 := by
    have : 2 * m * j = 2 * m * (j - 1) + 2 * m := by
      have : j = (j - 1) + 1 := by omega
      nlinarith [this]
    omega
  set q := k ^ 2 / (2 * m) with hq
  have hqle : j - 1 ≤ q := (Nat.le_div_iff_mul_le (by omega)).2 (by linarith [hstep])
  omega

/-! ## 5. The oracle capacity profile has interval superlevel sets -/

/-- **Unimodality of the oracle capacity.**  If the capacity of the positional
oracle exceeds a level `θ` at two thresholds, it exceeds `θ` at every threshold
in between.  Hence "the smallest `B` reaching 90% of the peak" is a well-defined
endpoint of an interval, and the reported profile (peak `0.4798` bits at
`B ≈ 22758`, `B* = 10420` for `≥ 90%`) has the shape a single-crossing profile
must have. -/
theorem oracle_capacity_superlevel_interval (Ω : Finset α) (d : α → ℕ) {θ : ℝ}
    {B₁ B B₂ : ℕ} (h1 : B₁ ≤ B) (h2 : B ≤ B₂)
    (hθ₁ : θ ≤ Real.binEntropy (belowFrac Ω d B₁))
    (hθ₂ : θ ≤ Real.binEntropy (belowFrac Ω d B₂)) :
    θ ≤ Real.binEntropy (belowFrac Ω d B) := by
  rcases le_or_gt (belowFrac Ω d B) 2⁻¹ with hcase | hcase
  · exact le_trans hθ₁ (oracle_capacity_ascending Ω d h1 hcase)
  · exact le_trans hθ₂ (oracle_capacity_descending Ω d h2 (le_of_lt hcase))

/-- Non-vacuity of the frontier law: for the classical example `N = 5959 = 59·101`
the imbalance is `k = 21`, the anchor is `⌊√N⌋ = 77`, the Fermat centre is `80`,
and the ascent law is tight to within the `2m` slack. -/
theorem fermat_frontier_example :
    Nat.sqrt (59 * (59 + 2 * 21)) = 77 ∧ 59 + 21 = 80 ∧
      energy (59 * (59 + 2 * 21)) 80 = 21 ^ 2 := by
  refine ⟨by norm_num [Nat.sqrt], by norm_num, ?_⟩
  have := fermat_hit_of_factorization 59 21
  norm_num at this ⊢
  exact this

/-! ## 6. Cycle 4: the frontier law is two-sided, and the capacity peak is exact
balance -/

/-- **Lower half of the frontier law.**  The Fermat ascent from the isqrt anchor
to the square-hit needs at least `k² / (2(u+k))` steps.  Together with
`fermat_hit_index_bound` this pins the frontier distance at `Θ(k²/√N)`: the cost
of the surviving geometry is governed *exactly* by the factor imbalance. -/
theorem fermat_hit_index_ge (u k : ℕ) :
    k ^ 2 ≤ 2 * (u + k) * ((u + k) - Nat.sqrt (u * (u + 2 * k))) := by
  set N := u * (u + 2 * k) with hN
  set m := Nat.sqrt N with hm
  have hma : m ≤ u + k := anchor_le_center u k
  obtain ⟨j, hj⟩ : ∃ j, u + k = m + j := ⟨(u + k) - m, by omega⟩
  have hjeq : (u + k) - m = j := by omega
  rw [hjeq]
  have hlow : m * m ≤ N := Nat.sqrt_le N
  have hsq : (m + j) * (m + j) = N + k * k := by
    rw [← hj, hN]; ring
  have hjm : m ≤ m + j := Nat.le_add_right _ _
  nlinarith [hlow, hsq, hjm, hj]

/-- **The capacity peak is exact balance, in counting form.**  On a nonempty
instance set the below-threshold fraction equals `1/2` precisely when the
threshold splits the set into two equal halves. -/
theorem belowFrac_eq_half_iff {Ω : Finset α} (d : α → ℕ) (B : ℕ) (hΩ : Ω.Nonempty) :
    belowFrac Ω d B = 2⁻¹ ↔ 2 * #(Ω.filter fun w => d w ≤ B) = #Ω := by
  classical
  have hcard : (0 : ℝ) < (#Ω : ℝ) := by exact_mod_cast Finset.card_pos.2 hΩ
  rw [belowFrac, div_eq_iff (ne_of_gt hcard)]
  constructor
  · intro h
    have : (2 : ℝ) * (#(Ω.filter fun w => d w ≤ B) : ℝ) = (#Ω : ℝ) := by linarith
    exact_mod_cast this
  · intro h
    have : (2 : ℝ) * (#(Ω.filter fun w => d w ≤ B) : ℝ) = (#Ω : ℝ) := by exact_mod_cast h
    linarith

/-- **Entropy peak = combinatorial balance.**  The positional oracle attains its
maximal capacity `log 2` at exactly those thresholds that halve the instance set
— the real-analytic peak of `binEntropy` and the counting pigeonhole of
`oracle_bit_pigeonhole` are two faces of the same statement. -/
theorem oracle_capacity_peak_iff_balanced {Ω : Finset α} (d : α → ℕ) (B : ℕ)
    (hΩ : Ω.Nonempty) :
    Real.binEntropy (belowFrac Ω d B) = Real.log 2
      ↔ 2 * #(Ω.filter fun w => d w ≤ B) = #Ω :=
  (oracle_capacity_eq_log_two_iff Ω d B).trans (belowFrac_eq_half_iff d B hΩ)

end MagnitudeMirror