/-
# The semiprime split-count channel at prime degree

The type-pair channel `Ipair` of a prime cyclic degree already has a closed form
in the catalog.  This file computes its *coarsening*, the split-count channel

`Isplit q = I( #{split factors} ; N mod f )`,

in closed form for every prime degree, and evaluates it at the degree-11 rung.

The result is a falsification.  The round-50 report lists `Is(11) = 0.116`.  With
the catalog's definitions (`sProj ∘ typePair` against `prodRes`) the true value is

`Isplit 11 = log₂ 11 + (180 log₂ 3 - 210 log₂ 5 - 210)/121 = 0.05189…`,

certified here by `Isplit_eleven_bracket` (`0.0516 < Isplit 11 < 0.0521`) and hence
strictly below the reported figure (`Isplit_eleven_lt_reported`).  The other four
degree-11 predictions of that round survive; this one does not, at least under
this — the catalog's — reading of the statistic.
-/
import Shared.AbelianLadderRealCyclotomic

namespace AbelianLadder

open Finset CyclicTypeChannel

set_option exponentiation.threshold 100000
set_option maxRecDepth 10000

/-! ## 1. The unconditional split-count entropy -/

/-- The split count takes exactly the three values `0, 1, 2`. -/
theorem image_splitCount_prime {q : ℕ} (hq : q.Prime) :
    (box q).image (sProj ∘ typePair q) = ({0, 1, 2} : Finset ℕ) := by
  ext v
  simp only [Finset.mem_image, mem_insert, mem_singleton]
  constructor
  · rintro ⟨⟨a, b⟩, hx, rfl⟩
    rw [mem_box_iff] at hx
    have h := sProj_typePair_prime hq hx.1 hx.2
    simp only [Function.comp_apply, h]
    split_ifs <;> simp
  · have h1 : (1 : ℕ) < q := hq.one_lt
    rintro (rfl | rfl | rfl)
    · exact ⟨(1, 1), by rw [mem_box_iff]; exact ⟨h1, h1⟩, by
        simpa using sProj_typePair_prime hq h1 h1⟩
    · exact ⟨(0, 1), by rw [mem_box_iff]; exact ⟨hq.pos, h1⟩, by
        simpa using sProj_typePair_prime hq hq.pos h1⟩
    · exact ⟨(0, 0), by rw [mem_box_iff]; exact ⟨hq.pos, hq.pos⟩, by
        simpa using sProj_typePair_prime hq hq.pos hq.pos⟩

/-- **The split-count entropy of a prime degree.** -/
theorem uEnt_splitCount_prime {q : ℕ} (hq : q.Prime) :
    uEnt (box q) (sProj ∘ typePair q)
      = Real.logb 2 ((q : ℝ) ^ 2)
        - (((q : ℝ) - 1) ^ 2 * Real.logb 2 (((q : ℝ) - 1) ^ 2)
            + 2 * ((q : ℝ) - 1) * Real.logb 2 (2 * ((q : ℝ) - 1))) / (q : ℝ) ^ 2 := by
  have hq1 : (1 : ℕ) ≤ q := hq.one_lt.le
  have hc0 : ((#{x ∈ box q | (sProj ∘ typePair q) x = 0} : ℕ) : ℝ) = ((q : ℝ) - 1) ^ 2 := by
    rw [show {x ∈ box q | (sProj ∘ typePair q) x = 0} = {x ∈ box q | sProj (typePair q x) = 0} from
      rfl, card_splitCount_zero hq]
    push_cast [Nat.cast_sub hq1]
    ring
  have hc1 : ((#{x ∈ box q | (sProj ∘ typePair q) x = 1} : ℕ) : ℝ) = 2 * ((q : ℝ) - 1) := by
    rw [show {x ∈ box q | (sProj ∘ typePair q) x = 1} = {x ∈ box q | sProj (typePair q x) = 1} from
      rfl, card_splitCount_one hq]
    push_cast [Nat.cast_sub hq1]
    ring
  have hc2 : ((#{x ∈ box q | (sProj ∘ typePair q) x = 2} : ℕ) : ℝ) = 1 := by
    rw [show {x ∈ box q | (sProj ∘ typePair q) x = 2} = {x ∈ box q | sProj (typePair q x) = 2} from
      rfl, card_splitCount_two hq]
    norm_num
  have hbox : ((box q).card : ℝ) = (q : ℝ) ^ 2 := by
    rw [card_box]; push_cast; ring
  rw [uEnt_eq_image_sum, image_splitCount_prime hq, hbox,
    show ({0, 1, 2} : Finset ℕ) = insert 0 (insert 1 {2}) from rfl,
    Finset.sum_insert (by decide), Finset.sum_insert (by decide), Finset.sum_singleton,
    hc0, hc1, hc2]
  simp

/-! ## 2. The conditional split-count entropy -/

/-- On the fibre `N ≡ 0` the split count is `2` at the origin and `0` elsewhere. -/
theorem filter_zero_fiber_two {q : ℕ} (hq : q.Prime) :
    {x ∈ {y ∈ box q | prodRes q y = 0} | (sProj ∘ typePair q) x = 2} = {((0 : ℕ), (0 : ℕ))} := by
  ext ⟨a, b⟩
  simp only [mem_filter, mem_box_iff, mem_singleton, Prod.mk.injEq, Function.comp_apply]
  constructor
  · rintro ⟨⟨⟨ha, hb⟩, _⟩, h⟩
    rw [sProj_typePair_prime hq ha hb] at h
    split_ifs at h with hA hB hB <;> simp_all
  · rintro ⟨rfl, rfl⟩
    refine ⟨⟨⟨hq.pos, hq.pos⟩, by simp [prodRes]⟩, ?_⟩
    rw [sProj_typePair_prime hq hq.pos hq.pos]; simp

/-- On a fibre `N ≡ c ≠ 0` exactly the two pairs `(0, c)` and `(c, 0)` have split
count `1`. -/
theorem filter_nonzero_fiber_one {q c : ℕ} (hq : q.Prime) (hc : c < q) (hc0 : c ≠ 0) :
    {x ∈ {y ∈ box q | prodRes q y = c} | (sProj ∘ typePair q) x = 1}
      = {((0 : ℕ), c), (c, (0 : ℕ))} := by
  ext ⟨a, b⟩
  simp only [mem_filter, mem_box_iff, mem_insert, mem_singleton, Prod.mk.injEq,
    Function.comp_apply]
  constructor
  · rintro ⟨⟨⟨ha, hb⟩, hres⟩, h⟩
    rw [sProj_typePair_prime hq ha hb] at h
    rw [prodRes] at hres
    split_ifs at h with hA hB hB
    · simp at h
    · subst hA
      left
      refine ⟨rfl, ?_⟩
      rw [Nat.zero_add, Nat.mod_eq_of_lt hb] at hres
      exact hres.symm ▸ rfl
    · subst hB
      right
      refine ⟨?_, rfl⟩
      rw [Nat.add_zero, Nat.mod_eq_of_lt ha] at hres
      exact hres.symm ▸ rfl
    · simp at h
  · rintro (⟨rfl, rfl⟩ | ⟨rfl, rfl⟩)
    · refine ⟨⟨⟨hq.pos, hc⟩, by simp [prodRes, Nat.mod_eq_of_lt hc]⟩, ?_⟩
      rw [sProj_typePair_prime hq hq.pos hc]; simp [hc0]
    · refine ⟨⟨⟨hc, hq.pos⟩, by simp [prodRes, Nat.mod_eq_of_lt hc]⟩, ?_⟩
      rw [sProj_typePair_prime hq hc hq.pos]; simp [hc0]

/-- The entropy of the split count on the fibre `N ≡ 0`. -/
theorem uEnt_zero_fiber_split {q : ℕ} (hq : q.Prime) :
    uEnt {y ∈ box q | prodRes q y = 0} (sProj ∘ typePair q) = binEnt q 1 := by
  have hvals : ∀ x ∈ {y ∈ box q | prodRes q y = 0},
      (sProj ∘ typePair q) x = 2 ∨ (sProj ∘ typePair q) x = 0 := by
    rintro ⟨a, b⟩ hx
    simp only [mem_filter, mem_box_iff] at hx
    have h := sProj_typePair_prime hq hx.1.1 hx.1.2
    rcases prodRes_zero_dichotomy hx.1.1 hx.1.2 hx.2 with ⟨rfl, rfl⟩ | ⟨h1, h2⟩
    · left; simpa using h
    · right; simp only [Function.comp_apply, h, if_neg h1, if_neg h2]
  rw [uEnt_binary (by norm_num : (2 : ℕ) ≠ 0) hvals, filter_zero_fiber_two hq, card_singleton,
    card_prodRes_fiber hq.pos hq.pos]

/-- The entropy of the split count on a fibre `N ≡ c ≠ 0`. -/
theorem uEnt_nonzero_fiber_split {q c : ℕ} (hq : q.Prime) (hc : c < q) (hc0 : c ≠ 0) :
    uEnt {y ∈ box q | prodRes q y = c} (sProj ∘ typePair q) = binEnt q 2 := by
  have hvals : ∀ x ∈ {y ∈ box q | prodRes q y = c},
      (sProj ∘ typePair q) x = 1 ∨ (sProj ∘ typePair q) x = 0 := by
    rintro ⟨a, b⟩ hx
    simp only [mem_filter, mem_box_iff] at hx
    have h := sProj_typePair_prime hq hx.1.1 hx.1.2
    rcases prodRes_ne_zero_dichotomy hx.1.1 hx.1.2 hx.2 with (he | he) | ⟨h1, h2⟩
    · simp only [Prod.mk.injEq] at he
      obtain ⟨rfl, rfl⟩ := he
      left; simp [h, hc0]
    · simp only [Prod.mk.injEq] at he
      obtain ⟨rfl, rfl⟩ := he
      left; simp [h, hc0]
    · right; simp only [Function.comp_apply, h, if_neg h1, if_neg h2]
  have hcard : #({((0 : ℕ), c), (c, (0 : ℕ))} : Finset (ℕ × ℕ)) = 2 := by
    rw [card_insert_of_notMem (by simp [hc0, Ne.symm hc0]), card_singleton]
  rw [uEnt_binary (by norm_num : (1 : ℕ) ≠ 0) hvals, filter_nonzero_fiber_one hq hc hc0, hcard,
    card_prodRes_fiber hq.pos hc]

/-- **The conditional split-count entropy of a prime degree.** -/
theorem condEnt_splitCount_prime {q : ℕ} (hq : q.Prime) :
    condEnt (box q) (sProj ∘ typePair q) (prodRes q)
      = (1 / (q : ℝ)) * binEnt q 1 + (((q : ℝ) - 1) / q) * binEnt q 2 := by
  have hq0 : (0 : ℝ) < q := by exact_mod_cast hq.pos
  have hbox : ((box q).card : ℝ) = (q : ℝ) ^ 2 := by rw [card_box]; push_cast; ring
  rw [condEnt, image_prodRes hq.pos, ← Finset.add_sum_erase _ _ (mem_range.2 hq.pos)]
  have hw : ((q : ℝ)) / (q : ℝ) ^ 2 = 1 / (q : ℝ) := by field_simp
  have h0 : ((#{x ∈ CyclicTypeChannel.box q | prodRes q x = 0} : ℝ)
        / (CyclicTypeChannel.box q).card)
      * uEnt {x ∈ CyclicTypeChannel.box q | prodRes q x = 0} (sProj ∘ typePair q)
      = (1 / (q : ℝ)) * binEnt q 1 := by
    rw [card_prodRes_fiber hq.pos hq.pos, hbox, uEnt_zero_fiber_split hq, hw]
  have hrest : ∀ c ∈ (range q).erase 0,
      ((#{x ∈ CyclicTypeChannel.box q | prodRes q x = c} : ℝ)
          / (CyclicTypeChannel.box q).card)
        * uEnt {x ∈ CyclicTypeChannel.box q | prodRes q x = c} (sProj ∘ typePair q)
        = (1 / (q : ℝ)) * binEnt q 2 := by
    intro c hc
    have hc0 : c ≠ 0 := (Finset.mem_erase.1 hc).1
    have hcq : c < q := mem_range.1 (Finset.mem_erase.1 hc).2
    rw [card_prodRes_fiber hq.pos hcq, hbox, uEnt_nonzero_fiber_split hq hcq hc0, hw]
  rw [h0, Finset.sum_congr rfl hrest, Finset.sum_const,
    Finset.card_erase_of_mem (mem_range.2 hq.pos), card_range, nsmul_eq_mul,
    Nat.cast_sub hq.one_lt.le]
  push_cast
  field_simp

/-- **The split-count channel of a prime degree — a closed form.** -/
theorem Isplit_prime {q : ℕ} (hq : q.Prime) :
    Isplit q = Real.logb 2 ((q : ℝ) ^ 2)
        - (((q : ℝ) - 1) ^ 2 * Real.logb 2 (((q : ℝ) - 1) ^ 2)
            + 2 * ((q : ℝ) - 1) * Real.logb 2 (2 * ((q : ℝ) - 1))) / (q : ℝ) ^ 2
        - ((1 / (q : ℝ)) * binEnt q 1 + (((q : ℝ) - 1) / q) * binEnt q 2) := by
  rw [Isplit, mutInfo, uEnt_splitCount_prime hq, condEnt_splitCount_prime hq]

/-! ## 3. The degree-11 value -/

private theorem lb_121 : Real.logb 2 (121 : ℝ) = 2 * Real.logb 2 11 := by
  rw [show (121 : ℝ) = 11 ^ 2 by norm_num, Real.logb_pow]
  norm_num

private theorem lb_100 : Real.logb 2 (100 : ℝ) = 2 + 2 * Real.logb 2 5 := by
  rw [show (100 : ℝ) = 2 ^ 2 * 5 ^ 2 by norm_num,
    Real.logb_mul (by norm_num) (by norm_num), Real.logb_pow, Real.logb_pow,
    Real.logb_self_eq_one (by norm_num)]
  ring

private theorem lb_20 : Real.logb 2 (20 : ℝ) = 2 + Real.logb 2 5 := by
  rw [show (20 : ℝ) = 2 ^ 2 * 5 by norm_num,
    Real.logb_mul (by norm_num) (by norm_num), Real.logb_pow,
    Real.logb_self_eq_one (by norm_num)]
  ring

private theorem lb_10 : Real.logb 2 (10 : ℝ) = 1 + Real.logb 2 5 := by
  rw [show (10 : ℝ) = 2 * 5 by norm_num, Real.logb_mul (by norm_num) (by norm_num),
    Real.logb_self_eq_one (by norm_num)]

private theorem lb_9 : Real.logb 2 (9 : ℝ) = 2 * Real.logb 2 3 := by
  rw [show (9 : ℝ) = 3 ^ 2 by norm_num, Real.logb_pow]
  norm_num

/-- **The degree-11 split-count channel.** -/
theorem Isplit_eleven_value :
    Isplit 11 = Real.logb 2 11
      + (180 * Real.logb 2 3 - 210 * Real.logb 2 5 - 210) / 121 := by
  rw [Isplit_prime (by norm_num), binEnt, binEnt]
  norm_num [lb_121, lb_100, lb_20, lb_10, lb_9]
  ring

/-- **A certified bracket for the degree-11 split-count channel.**
The witnesses are the integer inequalities `2⁸⁶⁵ · 5⁸⁴⁰ < 11⁴⁸⁴ · 3⁷²⁰` and
`11¹²¹⁰ · 3¹⁸⁰⁰ < 2²¹⁶³ · 5²¹⁰⁰`. -/
theorem Isplit_eleven_bracket : 0.0516 < Isplit 11 ∧ Isplit 11 < 0.0521 := by
  set A : ℝ := 121 * Real.logb 2 11 + 180 * Real.logb 2 3 - 210 * Real.logb 2 5 with hA
  have hval : Isplit 11 = (A - 210) / 121 := by
    rw [Isplit_eleven_value, hA]; ring
  -- lower bound
  have hlow : (865 : ℝ) < 4 * A := by
    have hnat : (2 : ℕ) ^ 865 * 5 ^ 840 < 11 ^ 484 * 3 ^ 720 := by norm_num
    have hR : ((2 : ℝ) ^ 865 * 5 ^ 840) < ((11 : ℝ) ^ 484 * 3 ^ 720) := by
      calc ((2 : ℝ) ^ 865 * 5 ^ 840) = ((2 ^ 865 * 5 ^ 840 : ℕ) : ℝ) := by push_cast; ring
        _ < ((11 ^ 484 * 3 ^ 720 : ℕ) : ℝ) := by exact_mod_cast hnat
        _ = ((11 : ℝ) ^ 484 * 3 ^ 720) := by push_cast; ring
    have h := Real.logb_lt_logb (b := 2) (by norm_num) (by positivity) hR
    rw [Real.logb_mul (by positivity) (by positivity),
      Real.logb_mul (by positivity) (by positivity),
      Real.logb_pow, Real.logb_pow, Real.logb_pow, Real.logb_pow,
      Real.logb_self_eq_one (by norm_num)] at h
    push_cast at h
    rw [hA]; linarith
  -- upper bound
  have hhigh : 10 * A < (2163 : ℝ) := by
    have hnat : (11 : ℕ) ^ 1210 * 3 ^ 1800 < 2 ^ 2163 * 5 ^ 2100 := by norm_num
    have hR : ((11 : ℝ) ^ 1210 * 3 ^ 1800) < ((2 : ℝ) ^ 2163 * 5 ^ 2100) := by
      calc ((11 : ℝ) ^ 1210 * 3 ^ 1800) = ((11 ^ 1210 * 3 ^ 1800 : ℕ) : ℝ) := by push_cast; ring
        _ < ((2 ^ 2163 * 5 ^ 2100 : ℕ) : ℝ) := by exact_mod_cast hnat
        _ = ((2 : ℝ) ^ 2163 * 5 ^ 2100) := by push_cast; ring
    have h := Real.logb_lt_logb (b := 2) (by norm_num) (by positivity) hR
    rw [Real.logb_mul (by positivity) (by positivity),
      Real.logb_mul (by positivity) (by positivity),
      Real.logb_pow, Real.logb_pow, Real.logb_pow, Real.logb_pow,
      Real.logb_self_eq_one (by norm_num)] at h
    push_cast at h
    rw [hA]; linarith
  rw [hval]
  constructor <;> [linarith; linarith]

/-- **The reported value `Is(11) = 0.116` is not reproduced.**  Under the
catalog's definition of the split-count channel the true value is `0.0519…`,
less than half the figure of the round-50 report. -/
theorem Isplit_eleven_lt_reported : Isplit 11 < 0.116 :=
  lt_trans Isplit_eleven_bracket.2 (by norm_num)

end AbelianLadder