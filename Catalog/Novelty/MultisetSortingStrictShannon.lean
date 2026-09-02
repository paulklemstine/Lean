import Novelty.MultisetSortingEntropy

/-!
# Strictness of the Shannon ceiling for multiset erasure

`Novelty.MultisetSortingEntropy` proves the ceiling `log₂ (n!/∏ mᵢ!) ≤ n · H(p)`.  The lab-notes
instance `infoErased_wAABB_lt_keyEntropyBits` (`log₂ 6 ≈ 2.585 < 4`) suggests that the ceiling is
never attained once the multiset is genuinely mixed.  This file proves that in general.

The mechanism is the multinomial expansion `1 = (∑ᵢ pᵢ)^n = ∑_k multinomial(k) ∏ᵢ pᵢ^{kᵢ}` at
the empirical distribution `pᵢ = mᵢ/n`: the ceiling comes from keeping only the term `k = m`, and
whenever two distinct keys actually occur there is a *second* strictly positive term, obtained by
moving one unit of multiplicity from `i` to `j`.  Hence the retained term is strictly below `1`.

## Main results

* `log_multinomial_lt_entropy` : if two distinct keys occur then
  `log (n!/∏ mᵢ!) < ∑ᵢ mᵢ log (n/mᵢ)` — strictly.
* `infoErased_lt_keyEntropyBits` : the erased information of multiset sorting is *strictly* below
  the Shannon budget `n · H(p)` whenever the multiset is not a single repeated key.
* `landauerGap_lt_keyEntropy` : the Landauer form of the strict gap.
-/

open Finset Nat

namespace MultisetSorting

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- The multiplicity vector obtained from `m` by moving one unit from key `i` to key `j`. -/
def shiftMult (m : ι → ℕ) (i j : ι) : ι → ℕ :=
  fun l => if l = i then m l - 1 else if l = j then m l + 1 else m l

theorem shiftMult_sum {m : ι → ℕ} {i j : ι} (hij : i ≠ j) (hi : 0 < m i) :
    ∑ l, shiftMult m i j l = ∑ l, m l := by
  classical
  have hi' : i ∈ (Finset.univ : Finset ι) := Finset.mem_univ i
  have hj' : j ∈ (Finset.univ.erase i) := Finset.mem_erase.mpr ⟨hij.symm, Finset.mem_univ j⟩
  rw [← Finset.add_sum_erase _ (shiftMult m i j) hi', ← Finset.add_sum_erase _ m hi',
    ← Finset.add_sum_erase _ (shiftMult m i j) hj', ← Finset.add_sum_erase _ m hj']
  have hshift_i : shiftMult m i j i = m i - 1 := by simp [shiftMult]
  have hshift_j : shiftMult m i j j = m j + 1 := by simp [shiftMult, hij.symm]
  have hrest : ∀ l ∈ (Finset.univ.erase i).erase j, shiftMult m i j l = m l := by
    intro l hl
    have hli : l ≠ i := (Finset.mem_erase.mp (Finset.mem_erase.mp hl).2).1
    have hlj : l ≠ j := (Finset.mem_erase.mp hl).1
    simp [shiftMult, hli, hlj]
  have hEq : ∑ l ∈ (Finset.univ.erase i).erase j, shiftMult m i j l
      = ∑ l ∈ (Finset.univ.erase i).erase j, m l := Finset.sum_congr rfl hrest
  rw [hshift_i, hshift_j, hEq]
  omega

omit [Fintype ι] in
theorem shiftMult_ne {m : ι → ℕ} {i j : ι} (hi : 0 < m i) : shiftMult m i j ≠ m := by
  intro h
  have h1 : shiftMult m i j i = m i := congrFun h i
  simp only [shiftMult, if_pos] at h1
  omega

/-- **Strict Shannon ceiling (combinatorial form).**  If two distinct keys occur, the logarithm
of the multinomial coefficient is *strictly* below the entropy budget. -/
theorem log_multinomial_lt_entropy (m : ι → ℕ) (n : ℕ) (hn : 0 < n) (hsum : ∑ l, m l = n)
    {i j : ι} (hij : i ≠ j) (hi : 0 < m i) (hj : 0 < m j) :
    Real.log (Nat.multinomial Finset.univ m) < ∑ l, (m l : ℝ) * Real.log ((n : ℝ) / m l) := by
  classical
  have hnn : (0:ℝ) < (n:ℝ) := by exact_mod_cast hn
  set p : ι → ℝ := fun l => (m l : ℝ) / n with hp
  have hp_nonneg : ∀ l, 0 ≤ p l := fun l => by positivity
  have hp_pos_of : ∀ l, 0 < m l → 0 < p l := by
    intro l hl
    have : (0:ℝ) < (m l : ℝ) := by exact_mod_cast hl
    exact div_pos this hnn
  -- the two competing terms of the multinomial expansion
  set F : (ι → ℕ) → ℝ := fun k => (Nat.multinomial Finset.univ k : ℝ) * ∏ l, p l ^ k l with hF
  have hF_nonneg : ∀ k, 0 ≤ F k := by
    intro k
    have : (0:ℝ) ≤ ∏ l, p l ^ k l := Finset.prod_nonneg fun l _ => by positivity
    have h0 : (0:ℝ) ≤ (Nat.multinomial Finset.univ k : ℝ) := by positivity
    exact mul_nonneg h0 this
  have hmem : m ∈ (Finset.univ : Finset ι).piAntidiag n := by
    rw [Finset.mem_piAntidiag]
    exact ⟨hsum, fun l _ => Finset.mem_univ l⟩
  have hkmem : shiftMult m i j ∈ (Finset.univ : Finset ι).piAntidiag n := by
    rw [Finset.mem_piAntidiag]
    exact ⟨by rw [shiftMult_sum hij hi, hsum], fun l _ => Finset.mem_univ l⟩
  -- the shifted term is strictly positive
  have hshift_pos : 0 < F (shiftMult m i j) := by
    have hmulti : (0:ℝ) < (Nat.multinomial Finset.univ (shiftMult m i j) : ℝ) := by
      exact_mod_cast Nat.multinomial_pos _ _
    have hprod : (0:ℝ) < ∏ l, p l ^ (shiftMult m i j l) := by
      refine Finset.prod_pos fun l _ => ?_
      rcases Nat.eq_zero_or_pos (shiftMult m i j l) with h | h
      · simp [h]
      · have hml : 0 < m l := by
          by_cases hli : l = i
          · subst hli; exact hi
          · by_cases hlj : l = j
            · subst hlj; exact hj
            · simpa [shiftMult, hli, hlj] using h
        exact pow_pos (hp_pos_of l hml) _
    exact mul_pos hmulti hprod
  -- the expansion of 1
  have hone : (∑ l, p l) = 1 := by
    rw [hp]
    rw [← Finset.sum_div]
    have hc : ((∑ l, m l : ℕ) : ℝ) = n := by rw [hsum]
    push_cast at hc
    rw [hc]
    have hn0 : (n : ℝ) ≠ 0 := by positivity
    field_simp
  have key := Finset.sum_pow_eq_sum_piAntidiag (Finset.univ : Finset ι) p n
  rw [hone, one_pow] at key
  -- keep two terms
  have hsplit : F m + ∑ k ∈ ((Finset.univ : Finset ι).piAntidiag n).erase m, F k = 1 := by
    rw [Finset.add_sum_erase _ F hmem]
    exact key.symm
  have hin : shiftMult m i j ∈ ((Finset.univ : Finset ι).piAntidiag n).erase m :=
    Finset.mem_erase.mpr ⟨shiftMult_ne hi, hkmem⟩
  have hrest : 0 < ∑ k ∈ ((Finset.univ : Finset ι).piAntidiag n).erase m, F k :=
    lt_of_lt_of_le hshift_pos (Finset.single_le_sum (fun k _ => hF_nonneg k) hin)
  have hFm : F m < 1 := by linarith
  -- take logarithms
  have hPpos : (0:ℝ) < (Nat.multinomial Finset.univ m : ℝ) := by
    exact_mod_cast Nat.multinomial_pos _ _
  have hfac : ∀ l : ι, p l ^ (m l) ≠ 0 := by
    intro l
    rcases Nat.eq_zero_or_pos (m l) with h | h
    · simp [h]
    · exact ne_of_gt (pow_pos (hp_pos_of l h) _)
  have hQ : (0:ℝ) < ∏ l, p l ^ (m l) :=
    Finset.prod_pos fun l _ => lt_of_le_of_ne (by positivity) (Ne.symm (hfac l))
  have hlog : Real.log (F m) < 0 := by
    have := Real.log_lt_log (by positivity) hFm
    simpa using this
  rw [hF] at hlog
  simp only at hlog
  rw [Real.log_mul (ne_of_gt hPpos) (ne_of_gt hQ), Real.log_prod (fun l _ => hfac l)] at hlog
  have hterm : ∀ l : ι, Real.log (p l ^ (m l)) = - ((m l : ℝ) * Real.log ((n : ℝ) / m l)) := by
    intro l
    rw [Real.log_pow, hp]
    rcases Nat.eq_zero_or_pos (m l) with h | h
    · simp [h]
    · have hml : (0:ℝ) < (m l : ℝ) := by exact_mod_cast h
      simp only
      rw [Real.log_div (ne_of_gt hml) (ne_of_gt hnn), Real.log_div (ne_of_gt hnn) (ne_of_gt hml)]
      ring
  simp only [hterm] at hlog
  rw [Finset.sum_neg_distrib] at hlog
  linarith

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- **The Shannon ceiling is never attained by a genuinely mixed multiset.**  If two distinct
keys occur in `w`, then sorting erases strictly fewer than `n · H(p)` bits. -/
theorem infoErased_lt_keyEntropyBits (w : α → ι) [Nonempty α] {i j : ι} (hij : i ≠ j)
    (hi : 0 < keyMult w i) (hj : 0 < keyMult w j) :
    infoErased (multisetSortingFunction w) < keyEntropyBits w := by
  have hn : 0 < Fintype.card α := Fintype.card_pos
  have hlog :=
    log_multinomial_lt_entropy (keyMult w) (Fintype.card α) hn (sum_keyMult w) hij hi hj
  have h2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  rw [infoErased_multisetSorting]
  unfold keyEntropyBits Real.logb
  rw [div_lt_iff₀ h2]
  calc Real.log (Nat.multinomial Finset.univ (keyMult w))
      < ∑ l, (keyMult w l : ℝ) * Real.log ((Fintype.card α : ℝ) / (keyMult w l)) := hlog
    _ = (∑ l, (keyMult w l : ℝ) *
          (Real.log ((Fintype.card α : ℝ) / (keyMult w l)) / Real.log 2)) * Real.log 2 := by
        rw [Finset.sum_mul]
        refine Finset.sum_congr rfl fun l _ => ?_
        field_simp

/-- **Landauer form of the strict Shannon gap.** -/
theorem landauerGap_lt_keyEntropy (w : α → ι) [Nonempty α] {i j : ι} (hij : i ≠ j)
    (hi : 0 < keyMult w i) (hj : 0 < keyMult w j) {kT : ℝ} (hkT : 0 < kT) :
    landauerGap (multisetSortingFunction w) kT < kT * Real.log 2 * keyEntropyBits w := by
  unfold landauerGap landauerCost
  have h2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  exact mul_lt_mul_of_pos_left (infoErased_lt_keyEntropyBits w hij hi hj) (mul_pos hkT h2)

end MultisetSorting