/-
# Drake's lifetime factor `L`: contact through a temporal window

Real civilizations are not points in time: a civilization born in epoch `e` stays
detectable for `L` epochs.  Two civilizations can meet when their birth epochs
differ by less than `L`, i.e. when `e + L > e'` and `e' + L > e`.  This file
generalises `Contact` to `WindowContact N T L` and proves

  `prb_windowContact_le :
      Prb (WindowContact N T L) ≤ (N ^ 2 - N) * ((2 * L - 1) * p ^ 2 / T)`.

The combinatorial heart is `card_windowPairs_le`: among the `T ^ 2` ordered pairs
of epochs at most `T * (2 * L - 1)` are within a window of width `L`.  So the
lifetime factor enters the contact probability *linearly*, while the abundance
factor `p` enters *quadratically*: lengthening civilizations is a far weaker lever
than making them more common.  Taking `L = 1` recovers the bound of `Contact`.
-/
import Pythagorean.FermiPigeonhole.Contact

namespace Pythagorean.FermiPigeonhole

open Finset

variable {N T L : ℕ} {p : ℝ}

/-- Two epochs (given by their indices) are within a temporal window of width `L`. -/
def WithinWindow (L a b : ℕ) : Prop := a + L > b ∧ b + L > a

instance (L a b : ℕ) : Decidable (WithinWindow L a b) := by
  unfold WithinWindow; infer_instance

/-- Ordered pairs of epochs lying within a temporal window of width `L`. -/
def windowPairs (T L : ℕ) : Finset (Fin T × Fin T) :=
  Finset.univ.filter (fun q : Fin T × Fin T => WithinWindow L q.1.val q.2.val)

/-- Two distinct sites are civilized within a temporal window of width `L` of each
other, so that contact between them is possible. -/
def WindowContact (N T L : ℕ) : Set (Cosmos N T) :=
  {f | ∃ i j, i ≠ j ∧ ∃ e e' : Fin T, f i = some e ∧ f j = some e' ∧
        WithinWindow L e.val e'.val}

/-- For a fixed epoch, at most `2 * L - 1` epochs lie within a window of width `L`. -/
lemma card_window_fiber (e : Fin T) :
    (Finset.univ.filter (fun e' : Fin T => WithinWindow L e.val e'.val)).card
      ≤ 2 * L - 1 := by
  classical
  refine le_trans (Finset.card_le_card_of_injOn
    (fun e' : Fin T => e'.val + L - 1 - e.val) ?_ ?_)
    (le_of_eq (Finset.card_range (2 * L - 1)))
  · intro a ha
    have ha' : e.val + L > a.val ∧ a.val + L > e.val := by
      simpa [WithinWindow] using ha
    show a.val + L - 1 - e.val ∈ Finset.range (2 * L - 1)
    rw [Finset.mem_range]
    omega
  · intro a ha b hb hab
    have ha' : e.val + L > a.val ∧ a.val + L > e.val := by simpa [WithinWindow] using ha
    have hb' : e.val + L > b.val ∧ b.val + L > e.val := by simpa [WithinWindow] using hb
    have hab' : a.val + L - 1 - e.val = b.val + L - 1 - e.val := hab
    have : a.val = b.val := by omega
    exact Fin.ext this

/-- **Window counting.**  At most `T * (2 * L - 1)` of the `T ^ 2` ordered pairs of
epochs lie within a temporal window of width `L`. -/
lemma card_windowPairs_le : (windowPairs T L).card ≤ T * (2 * L - 1) := by
  classical
  have hmaps : Set.MapsTo (fun q : Fin T × Fin T => q.1)
      (windowPairs T L : Set (Fin T × Fin T)) ((Finset.univ : Finset (Fin T)) : Set (Fin T)) :=
    fun q _ => Finset.mem_coe.mpr (Finset.mem_univ _)
  rw [Finset.card_eq_sum_card_fiberwise hmaps]
  have hfib : ∀ e ∈ (Finset.univ : Finset (Fin T)),
      {q ∈ windowPairs T L | q.1 = e}.card ≤ 2 * L - 1 := by
    intro e _
    have hsub : {q ∈ windowPairs T L | q.1 = e}
        ⊆ (Finset.univ.filter (fun e' : Fin T => WithinWindow L e.val e'.val)).image
            (fun e' => (e, e')) := by
      intro q hq
      simp only [Finset.mem_filter, windowPairs, Finset.mem_univ, true_and] at hq
      obtain ⟨hq1, hq2⟩ := hq
      refine Finset.mem_image.mpr ⟨q.2, ?_, ?_⟩
      · simp only [Finset.mem_filter, Finset.mem_univ, true_and]
        rw [← hq2]; exact hq1
      · rw [← hq2]
    calc {q ∈ windowPairs T L | q.1 = e}.card
        ≤ ((Finset.univ.filter (fun e' : Fin T => WithinWindow L e.val e'.val)).image
            (fun e' => (e, e'))).card := Finset.card_le_card hsub
      _ ≤ (Finset.univ.filter (fun e' : Fin T => WithinWindow L e.val e'.val)).card :=
          Finset.card_image_le
      _ ≤ 2 * L - 1 := card_window_fiber e
  calc ∑ e : Fin T, {q ∈ windowPairs T L | q.1 = e}.card
      ≤ ∑ _e : Fin T, (2 * L - 1) := Finset.sum_le_sum hfib
    _ = T * (2 * L - 1) := by
        rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, smul_eq_mul]

/-- **Windowed pairwise bound.**  Two prescribed distinct sites are civilized within
a window of width `L` of one another with probability at most `(2L - 1) * p ^ 2 / T`. -/
lemma prb_windowPair_le (h0 : 0 ≤ p) (h1 : p ≤ 1) (hT : 0 < T) {i j : Fin N}
    (hij : i ≠ j) :
    Prb N T p {f | ∃ e e' : Fin T, f i = some e ∧ f j = some e' ∧
        WithinWindow L e.val e'.val}
      ≤ ((2 * L - 1 : ℕ) : ℝ) * p ^ 2 / T := by
  classical
  have hTpos : (0 : ℝ) < T := by exact_mod_cast hT
  have hsub : {f : Cosmos N T | ∃ e e' : Fin T, f i = some e ∧ f j = some e' ∧
        WithinWindow L e.val e'.val}
      ⊆ {f : Cosmos N T | ∃ q ∈ windowPairs T L,
          f ∈ {g : Cosmos N T | g i = some q.1 ∧ g j = some q.2}} := by
    rintro f ⟨e, e', hfe, hfe', hw⟩
    exact ⟨(e, e'), by simp [windowPairs, hw], hfe, hfe'⟩
  have hterm : ∀ q ∈ windowPairs T L,
      Prb N T p {g : Cosmos N T | g i = some q.1 ∧ g j = some q.2} = (p / T) ^ 2 :=
    fun q _ => prb_two_sites hij q.1 q.2
  have hcount : ((windowPairs T L).card : ℝ) ≤ (T : ℝ) * ((2 * L - 1 : ℕ) : ℝ) := by
    have h := card_windowPairs_le (T := T) (L := L)
    exact_mod_cast h
  calc Prb N T p {f : Cosmos N T | ∃ e e' : Fin T, f i = some e ∧ f j = some e' ∧
        WithinWindow L e.val e'.val}
      ≤ Prb N T p {f : Cosmos N T | ∃ q ∈ windowPairs T L,
          f ∈ {g : Cosmos N T | g i = some q.1 ∧ g j = some q.2}} := prb_mono h0 h1 hsub
    _ ≤ ∑ q ∈ windowPairs T L,
          Prb N T p {g : Cosmos N T | g i = some q.1 ∧ g j = some q.2} :=
        prb_union_bound h0 h1 _ _
    _ = ((windowPairs T L).card : ℝ) * (p / T) ^ 2 := by
        rw [Finset.sum_congr rfl hterm, Finset.sum_const, nsmul_eq_mul]
    _ ≤ ((T : ℝ) * ((2 * L - 1 : ℕ) : ℝ)) * (p / T) ^ 2 :=
        mul_le_mul_of_nonneg_right hcount (sq_nonneg _)
    _ = ((2 * L - 1 : ℕ) : ℝ) * p ^ 2 / T := by
        field_simp

/-- **Windowed contact bound.**  Granting civilizations a lifetime of `L` epochs,
the probability that two of them are ever mutually detectable is at most
`(N ^ 2 - N) * (2L - 1) * p ^ 2 / T`: linear in the lifetime, quadratic in the
abundance. -/
theorem prb_windowContact_le (h0 : 0 ≤ p) (h1 : p ≤ 1) (hT : 0 < T) :
    Prb N T p (WindowContact N T L)
      ≤ ((N : ℝ) ^ 2 - N) * (((2 * L - 1 : ℕ) : ℝ) * p ^ 2 / T) := by
  classical
  have hsub : WindowContact N T L
      ⊆ {f : Cosmos N T | ∃ q ∈ (Finset.univ : Finset (Fin N)).offDiag,
          f ∈ {g : Cosmos N T | ∃ e e' : Fin T, g q.1 = some e ∧ g q.2 = some e' ∧
            WithinWindow L e.val e'.val}} := by
    rintro f ⟨i, j, hij, e, e', hfe, hfe', hw⟩
    exact ⟨(i, j), Finset.mem_offDiag.mpr ⟨Finset.mem_univ _, Finset.mem_univ _, hij⟩,
      e, e', hfe, hfe', hw⟩
  have hcard : (((Finset.univ : Finset (Fin N)).offDiag.card : ℝ)) = (N : ℝ) ^ 2 - N := by
    rw [Finset.offDiag_card]
    simp only [Finset.card_univ, Fintype.card_fin]
    rcases Nat.eq_zero_or_pos N with hN | hN
    · subst hN; simp
    · rw [Nat.cast_sub (Nat.le_mul_of_pos_left N hN)]
      push_cast
      ring
  have hterm : ∀ q ∈ (Finset.univ : Finset (Fin N)).offDiag,
      Prb N T p {g : Cosmos N T | ∃ e e' : Fin T, g q.1 = some e ∧ g q.2 = some e' ∧
          WithinWindow L e.val e'.val}
        ≤ ((2 * L - 1 : ℕ) : ℝ) * p ^ 2 / T :=
    fun q hq => prb_windowPair_le h0 h1 hT (Finset.mem_offDiag.mp hq).2.2
  calc Prb N T p (WindowContact N T L)
      ≤ Prb N T p {f : Cosmos N T | ∃ q ∈ (Finset.univ : Finset (Fin N)).offDiag,
          f ∈ {g : Cosmos N T | ∃ e e' : Fin T, g q.1 = some e ∧ g q.2 = some e' ∧
            WithinWindow L e.val e'.val}} := prb_mono h0 h1 hsub
    _ ≤ ∑ q ∈ (Finset.univ : Finset (Fin N)).offDiag,
          Prb N T p {g : Cosmos N T | ∃ e e' : Fin T, g q.1 = some e ∧ g q.2 = some e' ∧
            WithinWindow L e.val e'.val} := prb_union_bound h0 h1 _ _
    _ ≤ ∑ _q ∈ (Finset.univ : Finset (Fin N)).offDiag,
          ((2 * L - 1 : ℕ) : ℝ) * p ^ 2 / T := Finset.sum_le_sum hterm
    _ = ((N : ℝ) ^ 2 - N) * (((2 * L - 1 : ℕ) : ℝ) * p ^ 2 / T) := by
        rw [Finset.sum_const, nsmul_eq_mul, hcard]

end Pythagorean.FermiPigeonhole