/-
# Composite degree: the split count stops being a sufficient statistic

`Physics.AbelianLadderPrimeRungUniversality` and
`AbelianLadder.Ipair_eq_Isplit_prime` show that at every **prime** degree the
`s`-projection (how many of the two prime factors split completely) loses no
information at all: `Ipair q = Isplit q`.

This file settles the first **composite** degree.  At `n = 4` the two channels
are computed exactly,

* `Ipair 4 = 5/4` — a rational value, and in particular above the one-bit
  binary-fork cap;
* `Isplit 4 = 19/8 − (21/16) log₂ 3 = 0.29473…`,

so the `s`-projection destroys more than three quarters of the channel
(`Isplit_four_lt_Ipair_four`) and, unlike the type pair itself, respects the
one-bit cap (`Isplit_four_lt_one`, `one_lt_Ipair_four`).  Combined with
`Ipair_eq_Isplit_prime` this exhibits primality of the degree as the exact
mechanism behind the sufficiency of the split count.

The witness for the strict inequalities is the elementary integer bound
`2²² < 3²¹`.
-/
import Physics.AbelianLadderDegreeSeven

namespace AbelianLadder

open Finset CyclicTypeChannel

set_option maxRecDepth 10000
set_option exponentiation.threshold 100000

/-! ## 1. Logarithms of the small numbers involved -/

private theorem lb4_2 : Real.logb 2 (2 : ℝ) = 1 := Real.logb_self_eq_one (by norm_num)

private theorem lb4_4 : Real.logb 2 (4 : ℝ) = 2 := by
  rw [show (4 : ℝ) = 2 ^ 2 by norm_num, Real.logb_pow, lb4_2]
  norm_num

private theorem lb4_16 : Real.logb 2 (16 : ℝ) = 4 := by
  rw [show (16 : ℝ) = 2 ^ 4 by norm_num, Real.logb_pow, lb4_2]
  norm_num

private theorem lb4_9 : Real.logb 2 (9 : ℝ) = 2 * Real.logb 2 3 := by
  rw [show (9 : ℝ) = 3 ^ 2 by norm_num, Real.logb_pow]
  norm_num

private theorem lb4_6 : Real.logb 2 (6 : ℝ) = 1 + Real.logb 2 3 := by
  rw [show (6 : ℝ) = 2 * 3 by norm_num, Real.logb_mul (by norm_num) (by norm_num), lb4_2]

/-! ## 2. The type-pair channel at degree 4 -/

theorem uEnt_typePair_four : uEnt (box 4) (typePair 4) = 19 / 8 := by
  rw [uEnt_eq_image_sum,
    show (box 4).image (typePair 4)
      = ({(1, 1), (1, 2), (1, 4), (2, 2), (2, 4), (4, 4)} : Finset (ℕ × ℕ)) from by decide,
    show (box 4).card = 16 from by decide]
  rw [Finset.sum_insert (by decide), Finset.sum_insert (by decide),
    Finset.sum_insert (by decide), Finset.sum_insert (by decide),
    Finset.sum_insert (by decide), Finset.sum_singleton]
  rw [show #{x ∈ box 4 | typePair 4 x = (1, 1)} = 1 from by decide,
    show #{x ∈ box 4 | typePair 4 x = (1, 2)} = 2 from by decide,
    show #{x ∈ box 4 | typePair 4 x = (1, 4)} = 4 from by decide,
    show #{x ∈ box 4 | typePair 4 x = (2, 2)} = 1 from by decide,
    show #{x ∈ box 4 | typePair 4 x = (2, 4)} = 4 from by decide,
    show #{x ∈ box 4 | typePair 4 x = (4, 4)} = 4 from by decide]
  norm_num [lb4_2, lb4_4, lb4_16]

theorem condEnt_typePair_four : condEnt (box 4) (typePair 4) (prodRes 4) = 9 / 8 := by
  have hfib : ∀ c ∈ (box 4).image (prodRes 4), #{x ∈ box 4 | prodRes 4 x = c} = 4 := by decide
  rw [condEnt, show (box 4).image (prodRes 4) = ({0, 1, 2, 3} : Finset ℕ) from by decide]
  rw [Finset.sum_insert (by decide), Finset.sum_insert (by decide),
    Finset.sum_insert (by decide), Finset.sum_singleton]
  have h0 : uEnt {x ∈ box 4 | prodRes 4 x = 0} (typePair 4) = 3 / 2 := by
    rw [uEnt_eq_image_sum,
      show ({x ∈ box 4 | prodRes 4 x = 0}).image (typePair 4)
        = ({(1, 1), (2, 2), (4, 4)} : Finset (ℕ × ℕ)) from by decide,
      show ({x ∈ box 4 | prodRes 4 x = 0}).card = 4 from by decide]
    rw [Finset.sum_insert (by decide), Finset.sum_insert (by decide), Finset.sum_singleton,
      show #{x ∈ {x ∈ box 4 | prodRes 4 x = 0} | typePair 4 x = (1, 1)} = 1 from by decide,
      show #{x ∈ {x ∈ box 4 | prodRes 4 x = 0} | typePair 4 x = (2, 2)} = 1 from by decide,
      show #{x ∈ {x ∈ box 4 | prodRes 4 x = 0} | typePair 4 x = (4, 4)} = 2 from by decide]
    norm_num [lb4_2, lb4_4]
  have h1 : uEnt {x ∈ box 4 | prodRes 4 x = 1} (typePair 4) = 1 := by
    rw [uEnt_eq_image_sum,
      show ({x ∈ box 4 | prodRes 4 x = 1}).image (typePair 4)
        = ({(1, 4), (2, 4)} : Finset (ℕ × ℕ)) from by decide,
      show ({x ∈ box 4 | prodRes 4 x = 1}).card = 4 from by decide]
    rw [Finset.sum_insert (by decide), Finset.sum_singleton,
      show #{x ∈ {x ∈ box 4 | prodRes 4 x = 1} | typePair 4 x = (1, 4)} = 2 from by decide,
      show #{x ∈ {x ∈ box 4 | prodRes 4 x = 1} | typePair 4 x = (2, 4)} = 2 from by decide]
    norm_num [lb4_2, lb4_4]
  have h2 : uEnt {x ∈ box 4 | prodRes 4 x = 2} (typePair 4) = 1 := by
    rw [uEnt_eq_image_sum,
      show ({x ∈ box 4 | prodRes 4 x = 2}).image (typePair 4)
        = ({(1, 2), (4, 4)} : Finset (ℕ × ℕ)) from by decide,
      show ({x ∈ box 4 | prodRes 4 x = 2}).card = 4 from by decide]
    rw [Finset.sum_insert (by decide), Finset.sum_singleton,
      show #{x ∈ {x ∈ box 4 | prodRes 4 x = 2} | typePair 4 x = (1, 2)} = 2 from by decide,
      show #{x ∈ {x ∈ box 4 | prodRes 4 x = 2} | typePair 4 x = (4, 4)} = 2 from by decide]
    norm_num [lb4_2, lb4_4]
  have h3 : uEnt {x ∈ box 4 | prodRes 4 x = 3} (typePair 4) = 1 := by
    rw [uEnt_eq_image_sum,
      show ({x ∈ box 4 | prodRes 4 x = 3}).image (typePair 4)
        = ({(1, 4), (2, 4)} : Finset (ℕ × ℕ)) from by decide,
      show ({x ∈ box 4 | prodRes 4 x = 3}).card = 4 from by decide]
    rw [Finset.sum_insert (by decide), Finset.sum_singleton,
      show #{x ∈ {x ∈ box 4 | prodRes 4 x = 3} | typePair 4 x = (1, 4)} = 2 from by decide,
      show #{x ∈ {x ∈ box 4 | prodRes 4 x = 3} | typePair 4 x = (2, 4)} = 2 from by decide]
    norm_num [lb4_2, lb4_4]
  rw [h0, h1, h2, h3, show (box 4).card = 16 from by decide,
    show #{x ∈ box 4 | prodRes 4 x = 0} = 4 from by decide,
    show #{x ∈ box 4 | prodRes 4 x = 1} = 4 from by decide,
    show #{x ∈ box 4 | prodRes 4 x = 2} = 4 from by decide,
    show #{x ∈ box 4 | prodRes 4 x = 3} = 4 from by decide]
  norm_num

/-- **The degree-4 type-pair channel is exactly `5/4` bits** — a rational value,
strictly above the one-bit cap. -/
theorem Ipair_four_eq : Ipair 4 = 5 / 4 := by
  rw [Ipair, mutInfo, uEnt_typePair_four, condEnt_typePair_four]
  norm_num

/-! ## 3. The split-count channel at degree 4 -/

theorem uEnt_splitCount_four :
    uEnt (box 4) (sProj ∘ typePair 4) = 29 / 8 - (3 / 2) * Real.logb 2 3 := by
  rw [uEnt_eq_image_sum,
    show (box 4).image (sProj ∘ typePair 4) = ({0, 1, 2} : Finset ℕ) from by decide,
    show (box 4).card = 16 from by decide]
  rw [Finset.sum_insert (by decide), Finset.sum_insert (by decide), Finset.sum_singleton,
    show #{x ∈ box 4 | (sProj ∘ typePair 4) x = 0} = 9 from by decide,
    show #{x ∈ box 4 | (sProj ∘ typePair 4) x = 1} = 6 from by decide,
    show #{x ∈ box 4 | (sProj ∘ typePair 4) x = 2} = 1 from by decide]
  norm_num [lb4_9, lb4_6, lb4_16]
  ring

theorem condEnt_splitCount_four :
    condEnt (box 4) (sProj ∘ typePair 4) (prodRes 4) = 5 / 4 - (3 / 16) * Real.logb 2 3 := by
  rw [condEnt, show (box 4).image (prodRes 4) = ({0, 1, 2, 3} : Finset ℕ) from by decide]
  rw [Finset.sum_insert (by decide), Finset.sum_insert (by decide),
    Finset.sum_insert (by decide), Finset.sum_singleton]
  have h0 : uEnt {x ∈ box 4 | prodRes 4 x = 0} (sProj ∘ typePair 4)
      = 2 - (3 / 4) * Real.logb 2 3 := by
    rw [uEnt_eq_image_sum,
      show ({x ∈ box 4 | prodRes 4 x = 0}).image (sProj ∘ typePair 4) = ({0, 2} : Finset ℕ) from
        by decide,
      show ({x ∈ box 4 | prodRes 4 x = 0}).card = 4 from by decide]
    rw [Finset.sum_insert (by decide), Finset.sum_singleton,
      show #{x ∈ {x ∈ box 4 | prodRes 4 x = 0} | (sProj ∘ typePair 4) x = 0} = 3 from by decide,
      show #{x ∈ {x ∈ box 4 | prodRes 4 x = 0} | (sProj ∘ typePair 4) x = 2} = 1 from by decide]
    norm_num [lb4_4]
    ring
  have h1 : uEnt {x ∈ CyclicTypeChannel.box 4 | prodRes 4 x = 1} (sProj ∘ typePair 4) = 1 := by
    rw [uEnt_eq_image_sum,
      show ({x ∈ box 4 | prodRes 4 x = 1}).image (sProj ∘ typePair 4) = ({0, 1} : Finset ℕ) from
        by decide,
      show ({x ∈ box 4 | prodRes 4 x = 1}).card = 4 from by decide]
    rw [Finset.sum_insert (by decide), Finset.sum_singleton,
      show #{x ∈ {x ∈ box 4 | prodRes 4 x = 1} | (sProj ∘ typePair 4) x = 0} = 2 from by decide,
      show #{x ∈ {x ∈ box 4 | prodRes 4 x = 1} | (sProj ∘ typePair 4) x = 1} = 2 from by decide]
    norm_num [lb4_2, lb4_4]
  have h2 : uEnt {x ∈ CyclicTypeChannel.box 4 | prodRes 4 x = 2} (sProj ∘ typePair 4) = 1 := by
    rw [uEnt_eq_image_sum,
      show ({x ∈ box 4 | prodRes 4 x = 2}).image (sProj ∘ typePair 4) = ({0, 1} : Finset ℕ) from
        by decide,
      show ({x ∈ box 4 | prodRes 4 x = 2}).card = 4 from by decide]
    rw [Finset.sum_insert (by decide), Finset.sum_singleton,
      show #{x ∈ {x ∈ box 4 | prodRes 4 x = 2} | (sProj ∘ typePair 4) x = 0} = 2 from by decide,
      show #{x ∈ {x ∈ box 4 | prodRes 4 x = 2} | (sProj ∘ typePair 4) x = 1} = 2 from by decide]
    norm_num [lb4_2, lb4_4]
  have h3 : uEnt {x ∈ CyclicTypeChannel.box 4 | prodRes 4 x = 3} (sProj ∘ typePair 4) = 1 := by
    rw [uEnt_eq_image_sum,
      show ({x ∈ box 4 | prodRes 4 x = 3}).image (sProj ∘ typePair 4) = ({0, 1} : Finset ℕ) from
        by decide,
      show ({x ∈ box 4 | prodRes 4 x = 3}).card = 4 from by decide]
    rw [Finset.sum_insert (by decide), Finset.sum_singleton,
      show #{x ∈ {x ∈ box 4 | prodRes 4 x = 3} | (sProj ∘ typePair 4) x = 0} = 2 from by decide,
      show #{x ∈ {x ∈ box 4 | prodRes 4 x = 3} | (sProj ∘ typePair 4) x = 1} = 2 from by decide]
    norm_num [lb4_2, lb4_4]
  rw [h0, h1, h2, h3, show (CyclicTypeChannel.box 4).card = 16 from by decide,
    show #{x ∈ CyclicTypeChannel.box 4 | prodRes 4 x = 0} = 4 from by decide,
    show #{x ∈ CyclicTypeChannel.box 4 | prodRes 4 x = 1} = 4 from by decide,
    show #{x ∈ CyclicTypeChannel.box 4 | prodRes 4 x = 2} = 4 from by decide,
    show #{x ∈ CyclicTypeChannel.box 4 | prodRes 4 x = 3} = 4 from by decide]
  norm_num
  ring

/-- **The degree-4 split-count channel in closed form.** -/
theorem Isplit_four_eq : Isplit 4 = 19 / 8 - (21 / 16) * Real.logb 2 3 := by
  rw [Isplit, mutInfo, uEnt_splitCount_four, condEnt_splitCount_four]
  ring

/-! ## 4. A primality criterion for the split-count read-out -/

/-- At a composite degree the split count no longer determines the type pair:
the divisor `d` and the unit exponent `1` both have split count `0` but
different types. -/
theorem exists_sProj_eq_typePair_ne_of_not_prime {n : ℕ} (hn : 2 ≤ n) (hnp : ¬ n.Prime) :
    ∃ x ∈ box n, ∃ y ∈ box n,
      sProj (typePair n x) = sProj (typePair n y) ∧ typePair n x ≠ typePair n y := by
  obtain ⟨d, hd, hd2, hdn⟩ := Nat.exists_dvd_of_not_prime2 hn hnp
  obtain ⟨e, he⟩ := hd
  have hn0 : 0 < n := by omega
  have he2 : 2 ≤ e := by
    rcases Nat.lt_or_ge e 2 with h | h
    · interval_cases e <;> omega
    · exact h
  have hen : e < n := by nlinarith
  have hgcd : Nat.gcd d n = d := Nat.gcd_eq_left ⟨e, he⟩
  have hordd : ordType n d = e := by
    rw [ordType, hgcd, he, Nat.mul_div_cancel_left e (by omega : 0 < d)]
  have hord1 : ordType n 1 = n := by
    rw [ordType, Nat.gcd_comm, Nat.gcd_one_right, Nat.div_one]
  refine ⟨(d, d), mem_box_iff.2 ⟨hdn, hdn⟩, (1, 1), mem_box_iff.2 ⟨by omega, by omega⟩, ?_, ?_⟩
  · simp [typePair, sProj, hordd, hord1, show e ≠ 1 from by omega, show n ≠ 1 from by omega]
  · simp only [typePair, hordd, hord1, min_self, max_self, ne_eq, Prod.mk.injEq, not_and]
    omega

/-- **The split count is a sufficient statistic exactly at prime degree.**  The
read-out `sProj ∘ typePair n` induces the same partition of the exponent box as
the full type pair if and only if `n` is prime. -/
theorem sProj_sufficient_iff_prime {n : ℕ} (hn : 2 ≤ n) :
    (∀ x ∈ box n, ∀ y ∈ box n,
        sProj (typePair n x) = sProj (typePair n y) → typePair n x = typePair n y)
      ↔ n.Prime := by
  constructor
  · intro h
    by_contra hnp
    obtain ⟨x, hx, y, hy, hs, hne⟩ := exists_sProj_eq_typePair_ne_of_not_prime hn hnp
    exact hne (h x hx y hy hs)
  · intro hp x hx y hy hs
    exact typePair_eq_of_sProj_eq hp hx hy hs

/-! ## 5. Strict loss at composite degree -/

private theorem logb_three_gt : (22 : ℝ) / 21 < Real.logb 2 3 := by
  have hnat : (2 : ℕ) ^ 22 < 3 ^ 21 := by norm_num
  have hR : ((2 : ℝ) ^ 22) < ((3 : ℝ) ^ 21) := by
    calc ((2 : ℝ) ^ 22) = ((2 ^ 22 : ℕ) : ℝ) := by push_cast; ring
      _ < ((3 ^ 21 : ℕ) : ℝ) := by exact_mod_cast hnat
      _ = ((3 : ℝ) ^ 21) := by push_cast; ring
  have h := Real.logb_lt_logb (b := 2) (by norm_num) (by positivity) hR
  rw [Real.logb_pow, Real.logb_pow, Real.logb_self_eq_one (by norm_num)] at h
  push_cast at h
  linarith

/-- **The type pair breaks the one-bit cap at degree 4.** -/
theorem one_lt_Ipair_four : 1 < Ipair 4 := by
  rw [Ipair_four_eq]; norm_num

/-- **The split count restores the cap.** -/
theorem Isplit_four_lt_one : Isplit 4 < 1 := by
  rw [Isplit_four_eq]
  have := logb_three_gt
  linarith

/-- **Strict information loss at the first composite degree.**  In contrast with
`Ipair_eq_Isplit_prime`, at `n = 4` the `s`-projection is *not* a sufficient
statistic: it destroys more than three quarters of the channel. -/
theorem Isplit_four_lt_Ipair_four : Isplit 4 < Ipair 4 := by
  rw [Ipair_four_eq]
  exact lt_trans Isplit_four_lt_one (by norm_num)

/-- Quantitatively: the degree-4 split channel is below `0.3` bits while the
type-pair channel is `1.25` bits. -/
theorem Isplit_four_lt_three_tenths : Isplit 4 < 0.3 := by
  rw [Isplit_four_eq]
  have hnat : (2 : ℕ) ^ 3325 < 3 ^ 2098 := by norm_num
  have hR : ((2 : ℝ) ^ 3325) < ((3 : ℝ) ^ 2098) := by
    calc ((2 : ℝ) ^ 3325) = ((2 ^ 3325 : ℕ) : ℝ) := by push_cast; ring
      _ < ((3 ^ 2098 : ℕ) : ℝ) := by exact_mod_cast hnat
      _ = ((3 : ℝ) ^ 2098) := by push_cast; ring
  have h := Real.logb_lt_logb (b := 2) (by norm_num) (by positivity) hR
  rw [Real.logb_pow, Real.logb_pow, Real.logb_self_eq_one (by norm_num)] at h
  push_cast at h
  linarith

end AbelianLadder