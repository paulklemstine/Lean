import Novelty.BekensteinHawkingProjectionConstraint

/-!
# A sharper entropy defect for the projection constraint, and a parity obstruction

`Novelty.BekensteinHawkingProjectionConstraint` bounds the entropy cost of the Gauss
(projection) constraint by `log 4 + 2 log(A+1)`, via the pigeonhole inequality
`W(A)² ≤ (2A+1)²·Z(2A)`.  `FUTURE_DIRECTIONS.md` conjectured that the true cost is
`(1/2) log A + O(1)`, and proposed *unimodality of the projection profile*,
`D(A,M) ≤ D(A,0)`, as the intermediate step that would halve the gap.

This file does two things.

1. **The gap is halved without unimodality.**  Cauchy–Schwarz applied to the fibrewise
   decomposition `W(A) = ∑_M D(A,M)`, together with the *summed* concatenation injection
   `∑_M D(A,M)² ≤ Z(2A)` (`sum_sq_hStatesProj_le_singlet`), gives
   `W(A)² ≤ (2A+1)·Z(2A)` (`hStates_sq_le_singlet_sharp`) — one power of `(2A+1)` better
   than the pigeonhole bound — and hence an entropy defect at most `log 4 + log(2A+1)`
   (`singlet_entropy_defect_le_sharp`).  This is the `log A` bound that unimodality was
   supposed to provide, obtained by a different and much cheaper route.

2. **The proposed unimodality statement is false as stated.**
   `hStatesProj_not_le_singlet` exhibits an explicit counterexample: at area `1` the two
   configurations with `M = ±1` have no constrained counterpart at all, because the parity
   superselection rule `hStatesSinglet_odd` forces `D(A,0) = 0` in odd area.  Unimodality
   can only hold within a parity class, i.e. for even areas; the corrected statement is
   recorded in `FUTURE_DIRECTIONS.md`.
-/

open Finset

namespace BekensteinHawking

/-! ## The fibrewise decomposition and the summed concatenation injection -/

/-- The projection sectors partition the configurations of a given area. -/
theorem hStates_eq_sum_hStatesProj (n : ℕ) :
    hStates n = ∑ M ∈ Finset.Icc (-(n : ℤ)) (n : ℤ), hStatesProj n M := by
  classical
  have hmaps : ∀ l ∈ horizonStates n, projOf l ∈ Finset.Icc (-(n : ℤ)) (n : ℤ) := by
    intro l hl
    have h := abs_projOf_le (isHorizonConfig_of_mem hl)
    rw [areaOf_of_mem hl] at h
    have := abs_le.mp h
    simp only [Finset.mem_Icc]
    exact ⟨this.1, this.2⟩
  exact Finset.card_eq_sum_card_fiberwise hmaps

/-- **The summed concatenation injection.**  Gluing a configuration of projection `M` to one
of projection `-M` is injective across all sectors simultaneously, so the *sum* of the
squares of the sector occupations is bounded by the constrained count in twice the area. -/
theorem sum_sq_hStatesProj_le_singlet (n : ℕ) :
    ∑ M ∈ Finset.Icc (-(n : ℤ)) (n : ℤ), hStatesProj n M * hStatesProj n M
      ≤ hStatesSinglet (2 * n) := by
  classical
  set S : Finset (ℤ × (List (ℕ × ℤ) × List (ℕ × ℤ))) :=
    (Finset.Icc (-(n : ℤ)) (n : ℤ)).biUnion (fun M =>
      (((horizonStates n).filter (fun l => projOf l = M)) ×ˢ
        ((horizonStates n).filter (fun l => projOf l = -M))).image (fun p => (M, p))) with hS
  have hcard : S.card = ∑ M ∈ Finset.Icc (-(n : ℤ)) (n : ℤ),
      hStatesProj n M * hStatesProj n M := by
    rw [hS, Finset.card_biUnion]
    · refine Finset.sum_congr rfl (fun M _ => ?_)
      rw [Finset.card_image_of_injective _ (fun a b hab => by
        simpa using congrArg Prod.snd hab), Finset.card_product]
      show hStatesProj n M * hStatesProj n (-M) = hStatesProj n M * hStatesProj n M
      rw [hStatesProj_neg]
    · intro M _ M' _ hne
      refine Finset.disjoint_left.2 (fun x hx hx' => ?_)
      simp only [Finset.mem_image] at hx hx'
      obtain ⟨_, _, rfl⟩ := hx
      obtain ⟨_, _, h⟩ := hx'
      exact hne (congrArg Prod.fst h).symm
  rw [← hcard, hStatesSinglet, hStatesProj]
  refine Finset.card_le_card_of_injOn (fun x => x.2.1 ++ x.2.2) ?_ ?_
  · rintro ⟨M, l₁, l₂⟩ hx
    simp only [hS, Finset.mem_coe, Finset.mem_biUnion, Finset.mem_image, Finset.mem_product,
      Finset.mem_filter, Prod.mk.injEq] at hx
    obtain ⟨M', _, ⟨q₁, q₂⟩, ⟨⟨hq₁, hp₁⟩, ⟨hq₂, hp₂⟩⟩, hMM, hq⟩ := hx
    have hl₁ : l₁ ∈ horizonStates n := by
      have : q₁ = l₁ := congrArg Prod.fst hq
      rwa [this] at hq₁
    have hl₂ : l₂ ∈ horizonStates n := by
      have : q₂ = l₂ := congrArg Prod.snd hq
      rwa [this] at hq₂
    have hpr₁ : projOf l₁ = M' := by
      have : q₁ = l₁ := congrArg Prod.fst hq
      rwa [this] at hp₁
    have hpr₂ : projOf l₂ = -M' := by
      have : q₂ = l₂ := congrArg Prod.snd hq
      rwa [this] at hp₂
    simp only [Finset.mem_coe, Finset.mem_filter]
    refine ⟨?_, ?_⟩
    · rw [mem_horizonStates_iff]
      refine ⟨?_, ?_⟩
      · intro p hp
        rcases List.mem_append.mp hp with h | h
        · exact isHorizonConfig_of_mem hl₁ p h
        · exact isHorizonConfig_of_mem hl₂ p h
      · rw [areaOf_append, areaOf_of_mem hl₁, areaOf_of_mem hl₂]; ring
    · rw [projOf_append, hpr₁, hpr₂]; ring
  · rintro ⟨M, l₁, l₂⟩ hx ⟨M', l₁', l₂'⟩ hx' heq
    simp only [hS, Finset.mem_coe, Finset.mem_biUnion, Finset.mem_image, Finset.mem_product,
      Finset.mem_filter, Prod.mk.injEq] at hx hx'
    obtain ⟨N, _, ⟨q₁, q₂⟩, ⟨⟨hq₁, hp₁⟩, _⟩, hNM, hq⟩ := hx
    obtain ⟨N', _, ⟨s₁, s₂⟩, ⟨⟨hs₁, hs₁'⟩, _⟩, hNM', hs⟩ := hx'
    have he₁ : q₁ = l₁ := congrArg Prod.fst hq
    have he₁' : s₁ = l₁' := congrArg Prod.fst hs
    have hl₁ : l₁ ∈ horizonStates n := by rwa [he₁] at hq₁
    have hl₁' : l₁' ∈ horizonStates n := by rwa [he₁'] at hs₁
    have hkey := append_left_inj (isHorizonConfig_of_mem hl₁) (isHorizonConfig_of_mem hl₁')
      (by rw [areaOf_of_mem hl₁, areaOf_of_mem hl₁']) heq
    have hM : M = M' := by
      have h1 : projOf l₁ = N := by rwa [he₁] at hp₁
      have h2 : projOf l₁' = N' := by rwa [he₁'] at hs₁'
      rw [← hNM, ← hNM', ← h1, ← h2, hkey.1]
    simp only [Prod.mk.injEq]
    exact ⟨hM, hkey.1, hkey.2⟩

/-! ## The sharpened combinatorial bound -/

/-- **Cauchy–Schwarz beats the pigeonhole.**  `W(A)² ≤ (2A+1)·Z(2A)`: one factor of the
number of projection sectors better than `hStates_sq_le_singlet`. -/
theorem hStates_sq_le_singlet_sharp (n : ℕ) :
    (hStates n : ℝ) ^ 2 ≤ (2 * n + 1) * (hStatesSinglet (2 * n) : ℝ) := by
  classical
  set s : Finset ℤ := Finset.Icc (-(n : ℤ)) (n : ℤ) with hs
  have hsum : (hStates n : ℝ) = ∑ M ∈ s, (hStatesProj n M : ℝ) := by
    rw [hs]
    exact_mod_cast congrArg (fun m : ℕ => (m : ℝ)) (hStates_eq_sum_hStatesProj n)
  have hcs : (∑ M ∈ s, (hStatesProj n M : ℝ)) ^ 2
      ≤ (s.card : ℝ) * ∑ M ∈ s, ((hStatesProj n M : ℝ)) ^ 2 := sq_sum_le_card_mul_sum_sq
  have hcard : (s.card : ℝ) = 2 * n + 1 := by
    rw [hs, card_Icc_proj]
    push_cast
    ring
  have hsq : ∑ M ∈ s, ((hStatesProj n M : ℝ)) ^ 2 ≤ (hStatesSinglet (2 * n) : ℝ) := by
    have h := sum_sq_hStatesProj_le_singlet n
    have hcast : ((∑ M ∈ s, hStatesProj n M * hStatesProj n M : ℕ) : ℝ)
        ≤ (hStatesSinglet (2 * n) : ℝ) := by exact_mod_cast h
    calc ∑ M ∈ s, ((hStatesProj n M : ℝ)) ^ 2
        = ((∑ M ∈ s, hStatesProj n M * hStatesProj n M : ℕ) : ℝ) := by
          push_cast
          exact Finset.sum_congr rfl (fun M _ => by ring)
      _ ≤ (hStatesSinglet (2 * n) : ℝ) := hcast
  rw [hsum]
  calc (∑ M ∈ s, (hStatesProj n M : ℝ)) ^ 2
      ≤ (s.card : ℝ) * ∑ M ∈ s, ((hStatesProj n M : ℝ)) ^ 2 := hcs
    _ ≤ (2 * n + 1) * (hStatesSinglet (2 * n) : ℝ) := by
        rw [hcard]
        have hpos : (0:ℝ) ≤ 2 * n + 1 := by positivity
        exact mul_le_mul_of_nonneg_left hsq hpos

/-- Sharpened two-sided bounds for the constrained microstate count: the lower bound now
loses only one power of the area. -/
theorem singlet_bounds_sharp (n : ℕ) (hn : 1 ≤ n) :
    growth ^ (2 * n) / (4 * (2 * n + 1)) ≤ (hStatesSinglet (2 * n) : ℝ) := by
  obtain ⟨hlow, _⟩ := hStates_bounds n hn
  have hkey := hStates_sq_le_singlet_sharp n
  have hpow : growth ^ (2 * n) = (growth ^ n) ^ 2 := by rw [← pow_mul, mul_comm]
  have hgpos : (0:ℝ) < growth ^ n := pow_pos growth_pos n
  have hcard : (0:ℝ) < 2 * (n : ℝ) + 1 := by positivity
  rw [div_le_iff₀ (by positivity), hpow]
  nlinarith

/-- **The sharpened entropy defect.**  The projection constraint costs at most
`log 4 + log(2A+1)`, i.e. `log A + O(1)` rather than `2 log A + O(1)`. -/
theorem singlet_entropy_defect_le_sharp (n : ℕ) (hn : 1 ≤ n) :
    0 ≤ (2 * n : ℝ) * entropyDensity - Real.log (hStatesSinglet (2 * n))
      ∧ (2 * n : ℝ) * entropyDensity - Real.log (hStatesSinglet (2 * n))
          ≤ Real.log 4 + Real.log (2 * n + 1) := by
  have hlow := singlet_bounds_sharp n hn
  have hupp := (singlet_bounds n hn).2
  have hgpos : (0:ℝ) < growth ^ (2 * n) := pow_pos growth_pos _
  have hden : (0:ℝ) < 4 * (2 * (n : ℝ) + 1) := by positivity
  have hZpos : (0:ℝ) < (hStatesSinglet (2 * n) : ℝ) := by
    refine lt_of_lt_of_le ?_ hlow
    positivity
  have hlogpow : Real.log (growth ^ (2 * n)) = (2 * n : ℝ) * entropyDensity := by
    rw [Real.log_pow]; push_cast; rfl
  constructor
  · have := Real.log_le_log hZpos hupp
    rw [hlogpow] at this
    linarith
  · have h := Real.log_le_log (by positivity) hlow
    rw [Real.log_div (ne_of_gt hgpos) (ne_of_gt hden), hlogpow,
      Real.log_mul (by norm_num) (by positivity)] at h
    linarith

/-! ## The parity obstruction to unimodality -/

lemma one_le_hStatesProj_one_one : 1 ≤ hStatesProj 1 1 := by
  classical
  have hconfig : IsHorizonConfig [(1, (1:ℤ))] := by
    intro p hp
    simp only [List.mem_singleton] at hp
    subst hp
    refine ⟨le_refl 1, ?_⟩
    rw [mem_punctureLabels_iff]
    norm_num
  have hmem : [(1, (1:ℤ))] ∈ (horizonStates 1).filter (fun l => projOf l = 1) := by
    rw [Finset.mem_filter]
    refine ⟨?_, rfl⟩
    rw [mem_horizonStates_iff]
    exact ⟨hconfig, rfl⟩
  exact Finset.card_pos.2 ⟨_, hmem⟩

/-- **The projection profile is not unimodal across parity classes.**  At area `1` the
sector `M = 1` is occupied while the constrained sector `M = 0` is empty, so the naive
statement `D(A,M) ≤ D(A,0)` fails: unimodality can only be asked for within the parity
class selected by the superselection rule `hStatesSinglet_odd`. -/
theorem hStatesProj_not_le_singlet :
    ¬ (∀ (n : ℕ) (M : ℤ), hStatesProj n M ≤ hStatesSinglet n) := by
  intro h
  have h1 := h 1 1
  have h1' := one_le_hStatesProj_one_one
  have h0 : hStatesSinglet 1 = 0 := by
    have := hStatesSinglet_odd 0
    simpa using this
  omega

end BekensteinHawking