/-
# Cycle 13: an unconditional support lower bound — `#supp Δ_{a,b} ≥ max(a,b)`

Cycle 12 (`Computation.AlexanderTorusKnot.SupportLaw`) proved the *support law*
`#supp Δ_{a,b} = 2·β(a,b) + 1`, where `β(a,b) = #downJumps a b` counts the maximal runs of
gaps of the numerical semigroup `⟨a,b⟩`.  That identity is exact but not yet quantitative:
`β` is defined by a `Finset` filter, so on its own it gives no lower bound on the size of the
coefficient vector of the Alexander polynomial.

This file supplies the missing quantitative input, by bounding the *length* of a gap run:

* `exists_isRep_window` : among any `a` consecutive integers one is a multiple of `a`, hence
  lies in `⟨a,b⟩`; so no run of gaps is longer than `a − 1`;
* `runStart` : the start of the maximal gap run containing a gap `g`, obtained as
  `1 + max {j ≤ g : j ∈ ⟨a,b⟩}`;
* `card_gaps_le` : `#gaps ≤ β(a,b) · (a − 1)`, by the injection `g ↦ (runStart g, g − runStart g)`
  into `downJumps ×ˢ range (a−1)`;
* `card_downJumps_ge` : combined with Sylvester's genus formula `2·#gaps = (a−1)(b−1)` this
  gives `b − 1 ≤ 2·β(a,b)`;
* `torusAlexander_support_card_ge` : `#supp Δ_{a,b} ≥ max(a,b)`;
* `torusAlexander_two_support_card` : the bound is attained on the catalog pencil, where
  `#supp A_N = N` exactly (every gap run of `⟨2,N⟩` has length one).

The last statement is the general form of the catalog's exponential barrier: writing down the
Alexander polynomial of `T(a,b)` costs at least `max(a,b)` nonzero coefficients, i.e. `Ω(N)`
for the pencil `T(2,N)`, even though the knot is specified by `O(log N)` bits.
-/
import Computation.AlexanderTorusKnot.SupportLaw

namespace Computation.AlexanderTorusKnot

open Polynomial Finset

variable {a b : ℕ}

/-- Among any `a` consecutive integers there is a multiple of `a`, which lies in `⟨a,b⟩`. -/
lemma exists_isRep_window (ha : 0 < a) (b n : ℕ) : ∃ k < a, IsRep a b (n + k) := by
  refine ⟨(a - n % a) % a, Nat.mod_lt _ ha, ?_⟩
  have hlt : n % a < a := Nat.mod_lt _ ha
  have hk : (a - n % a) % a = a - n % a ∨ n % a = 0 := by
    rcases Nat.eq_zero_or_pos (n % a) with h | h
    · exact Or.inr h
    · exact Or.inl (Nat.mod_eq_of_lt (by omega))
  refine ⟨(n + (a - n % a) % a) / a, 0, ?_⟩
  have hdvd : a ∣ n + (a - n % a) % a := by
    rcases hk with h | h
    · rw [h]
      refine ⟨n / a + 1, ?_⟩
      have hdm := Nat.div_add_mod n a
      have hexp : a * (n / a + 1) = a * (n / a) + a := by ring
      omega
    · rw [h]
      simp only [Nat.sub_zero, Nat.mod_self, Nat.add_zero]
      exact Nat.dvd_of_mod_eq_zero h
  obtain ⟨m, hm⟩ := hdvd
  rw [hm]
  simp [Nat.mul_div_cancel_left _ ha]

/-- The start of the maximal run of gaps containing `g`: one more than the largest element of
`⟨a,b⟩` not exceeding `g`. -/
def runStart (a b g : ℕ) : ℕ :=
  (((Finset.range (g + 1)).filter (fun j => IsRep a b j)).max'
    ⟨0, by simp [isRep_zero a b]⟩) + 1

lemma isRep_runStart_sub_one (a b g : ℕ) : IsRep a b (runStart a b g - 1) := by
  classical
  have hmem := Finset.max'_mem ((Finset.range (g + 1)).filter (fun j => IsRep a b j))
    ⟨0, by simp [isRep_zero a b]⟩
  simp only [Finset.mem_filter] at hmem
  simpa [runStart] using hmem.2

lemma runStart_sub_one_le (a b g : ℕ) : runStart a b g - 1 ≤ g := by
  classical
  have hmem := Finset.max'_mem ((Finset.range (g + 1)).filter (fun j => IsRep a b j))
    ⟨0, by simp [isRep_zero a b]⟩
  simp only [Finset.mem_filter, Finset.mem_range] at hmem
  simp only [runStart, Nat.add_sub_cancel]
  omega

lemma le_max_of_isRep {g j : ℕ} (hj : j ≤ g) (h : IsRep a b j) :
    j ≤ runStart a b g - 1 := by
  classical
  have := Finset.le_max' ((Finset.range (g + 1)).filter (fun j => IsRep a b j)) j
    (by simp only [Finset.mem_filter, Finset.mem_range]; exact ⟨by omega, h⟩)
  simpa [runStart] using this

/-- Every index strictly between the last semigroup element below `g` and `g` itself
(inclusive) is a gap. -/
lemma not_isRep_of_mem_run {g j : ℕ} (hj1 : runStart a b g ≤ j) (hj2 : j ≤ g) :
    ¬ IsRep a b j := by
  intro h
  have hmax := le_max_of_isRep hj2 h
  have hpos : 1 ≤ runStart a b g := by simp [runStart]
  omega

lemma runStart_le_of_gap {g : ℕ} (hg : ¬ IsRep a b g) : runStart a b g ≤ g := by
  have h1 := runStart_sub_one_le a b g
  have h2 : runStart a b g - 1 ≠ g := by
    intro h
    exact hg (h ▸ isRep_runStart_sub_one a b g)
  have h3 : 1 ≤ runStart a b g := by simp [runStart]
  omega

lemma runStart_mem_downJumps (hab : Nat.Coprime a b) (ha : 1 < a) (hb : 1 < b) {g : ℕ}
    (hg : g ∈ gaps a b) : runStart a b g ∈ downJumps a b := by
  have hgap : ¬ IsRep a b g := (mem_gaps_iff hab ha hb).1 hg
  have hglt : g < (a - 1) * (b - 1) := by
    simp only [gaps, Finset.mem_filter, Finset.mem_range] at hg
    exact hg.1
  have hle := runStart_le_of_gap hgap
  simp only [downJumps, Finset.mem_filter, Finset.mem_Icc]
  refine ⟨⟨by simp [runStart], by omega⟩, ?_, isRep_runStart_sub_one a b g⟩
  exact not_isRep_of_mem_run le_rfl hle

/-- A run of gaps has length at most `a − 1`. -/
lemma sub_runStart_lt (ha : 1 < a) {g : ℕ} (hg : ¬ IsRep a b g) :
    g - runStart a b g < a - 1 := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨k, hk, hrep⟩ := exists_isRep_window (by omega : 0 < a) b (runStart a b g)
  have hle := runStart_le_of_gap hg
  have : runStart a b g + k ≤ g := by omega
  exact not_isRep_of_mem_run (Nat.le_add_right _ _) this hrep

/-- **Each gap belongs to a run of length `< a`,** so the number of gaps is at most the number
of runs times `a − 1`. -/
theorem card_gaps_le (hab : Nat.Coprime a b) (ha : 1 < a) (hb : 1 < b) :
    (gaps a b).card ≤ (downJumps a b).card * (a - 1) := by
  classical
  have hcard : ((downJumps a b) ×ˢ (Finset.range (a - 1))).card
      = (downJumps a b).card * (a - 1) := by
    rw [Finset.card_product, Finset.card_range]
  rw [← hcard]
  refine Finset.card_le_card_of_injOn (fun g => (runStart a b g, g - runStart a b g)) ?_ ?_
  · intro g hg
    have hgap : ¬ IsRep a b g := (mem_gaps_iff hab ha hb).1 hg
    exact Finset.mem_product.mpr ⟨runStart_mem_downJumps hab ha hb hg,
      Finset.mem_range.mpr (sub_runStart_lt ha hgap)⟩
  · intro g hg g' hg' heq
    have hgap : ¬ IsRep a b g := (mem_gaps_iff hab ha hb).1 hg
    have hgap' : ¬ IsRep a b g' := (mem_gaps_iff hab ha hb).1 hg'
    have h1 := runStart_le_of_gap hgap
    have h2 := runStart_le_of_gap hgap'
    have e1 : runStart a b g = runStart a b g' := congrArg Prod.fst heq
    have e2 : g - runStart a b g = g' - runStart a b g' := congrArg Prod.snd heq
    omega

/-- **The number of gap runs is at least `(b−1)/2`.** -/
theorem card_downJumps_ge (hab : Nat.Coprime a b) (ha : 1 < a) (hb : 1 < b) :
    b - 1 ≤ 2 * (downJumps a b).card := by
  have hgenus := card_gaps_two_mul hab ha hb
  have hle := card_gaps_le hab ha hb
  have hmul : (a - 1) * (b - 1) ≤ 2 * (downJumps a b).card * (a - 1) := by
    calc (a - 1) * (b - 1) = 2 * (gaps a b).card := hgenus.symm
      _ ≤ 2 * ((downJumps a b).card * (a - 1)) := by omega
      _ = 2 * (downJumps a b).card * (a - 1) := by ring
  have ha1 : 0 < a - 1 := by omega
  exact Nat.le_of_mul_le_mul_right (by simpa [Nat.mul_comm] using hmul) ha1

/-- **Support lower bound (one side).** `Δ_{a,b}` has at least `b` nonzero coefficients. -/
theorem torusAlexander_support_card_ge_right (hab : Nat.Coprime a b) (ha : 1 < a) (hb : 1 < b) :
    b ≤ (torusAlexander a b).support.card := by
  have h := torusAlexander_support_card hab ha hb
  have h2 := card_downJumps_ge hab ha hb
  omega

/-- **Support lower bound.** The Alexander polynomial of `T(a,b)` has at least `max(a,b)`
nonzero coefficients: materializing it costs `Ω(max(a,b))`, exponential in the `O(log ab)`
bits that specify the knot. -/
theorem torusAlexander_support_card_ge (hab : Nat.Coprime a b) (ha : 1 < a) (hb : 1 < b) :
    max a b ≤ (torusAlexander a b).support.card := by
  rcases le_total a b with h | h
  · rw [max_eq_right h]
    exact torusAlexander_support_card_ge_right hab ha hb
  · rw [max_eq_left h, torusAlexander_comm]
    exact torusAlexander_support_card_ge_right hab.symm hb ha

/-- For the catalog pencil `T(2,N)`: `#supp A_N ≥ N`. -/
theorem torusAlexander_two_support_card_ge {N : ℕ} (hN : Odd N) (h1 : 1 < N) :
    N ≤ (torusAlexander 2 N).support.card := by
  have hcop : Nat.Coprime 2 N := by simpa using hN
  simpa using torusAlexander_support_card_ge_right hcop (by omega) h1

/-! ## Tightness: the bound `#supp ≥ max(a,b)` is attained on the pencil `T(2,N)`

Every run start is itself a gap, so `β(a,b) ≤ #gaps` always; for `a = 2` the run-length
bound `card_gaps_le` says runs have length one, so the two counts coincide and the support
law becomes an exact evaluation. -/

/-- Each maximal gap run starts at a gap: `downJumps a b ⊆ gaps a b`. -/
lemma downJumps_subset_gaps (hab : Nat.Coprime a b) (ha : 1 < a) (hb : 1 < b) :
    downJumps a b ⊆ gaps a b := by
  intro n hn
  simp only [downJumps, Finset.mem_filter, Finset.mem_Icc] at hn
  obtain ⟨⟨-, hle⟩, hnrep, -⟩ := hn
  have hne : n ≠ (a - 1) * (b - 1) := by
    intro h
    exact hnrep (isRep_of_conductor_le hab ha hb (le_of_eq h.symm))
  simp only [gaps, Finset.mem_filter, Finset.mem_range]
  exact ⟨lt_of_le_of_ne hle hne, hnrep⟩

/-- The number of gap runs never exceeds the number of gaps. -/
lemma card_downJumps_le_card_gaps (hab : Nat.Coprime a b) (ha : 1 < a) (hb : 1 < b) :
    (downJumps a b).card ≤ (gaps a b).card :=
  Finset.card_le_card (downJumps_subset_gaps hab ha hb)

/-- **Tightness of the support bound.** For the catalog pencil the inequality
`#supp Δ_{a,b} ≥ max(a,b)` is an equality: `#supp A_N = N` for every odd `N > 1`. -/
theorem torusAlexander_two_support_card {N : ℕ} (hN : Odd N) (h1 : 1 < N) :
    (torusAlexander 2 N).support.card = N := by
  have hcop : Nat.Coprime 2 N := by simpa using hN
  have hlaw := torusAlexander_support_card hcop (by omega) h1
  have hgenus := card_gaps_two_mul hcop (by omega) h1
  have hle := card_gaps_le hcop (by omega) h1
  have hge := card_downJumps_le_card_gaps hcop (by omega) h1
  norm_num at hle hgenus
  omega

end Computation.AlexanderTorusKnot