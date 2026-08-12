/-
# Cycle 15: the staircase family `T(a, a+1)` — an exact second support count

Cycle 12 proved the *support law* `#supp Δ_{a,b} = 2·β(a,b) + 1` with `β` the number of
maximal gap runs of `⟨a,b⟩`, and Cycle 13 turned it into the unconditional bound
`#supp Δ_{a,b} ≥ max(a,b)`, shown to be attained on the catalog pencil `T(2,N)`.

The bound is *not* attained anywhere else, and this file proves the first family witnessing
that.  For the staircase torus knots `T(a, a+1)` the semigroup `⟨a, a+1⟩` has the explicit
membership test

  `n ∈ ⟨a, a+1⟩  ↔  n % a ≤ n / a`   (`isRep_succ_iff`),

which makes the gap runs completely transparent: the run starting points are exactly the
`a − 1` numbers `q·(a+1) + 1` for `0 ≤ q < a − 1` (`downJumps_succ`), one per "step" of the
staircase.  Consequently

* `card_downJumps_succ`               : `β(a, a+1) = a − 1`;
* `torusAlexander_staircase_support`  : `#supp Δ_{a,a+1} = 2a − 1`;
* `torusAlexander_staircase_support_gt` : for `a ≥ 3` this *strictly exceeds* `max(a, a+1)`,
  so the Cycle 13 bound is sharp only on the pencil `T(2,N)`;
* `torusAlexander_staircase_support_eq_add_sub_two` : `#supp Δ_{a,a+1} = a + (a+1) − 2`,
  the same value `a + b − 2` that `T(2,N)` realises — evidence for the sharper conjectural
  law `#supp Δ_{a,b} ≥ a + b − 2` recorded in `FUTURE_DIRECTIONS.md`.

The mathematical content is the residue-class description of the staircase semigroup: writing
`n = a·q + r` with `r < a`, membership means "the quotient pays for the remainder", so the
gaps of `⟨a,a+1⟩` form a triangular array with exactly one run per quotient level.
-/
import Computation.AlexanderTorusKnot.SupportLowerBound

namespace Computation.AlexanderTorusKnot

open Polynomial Finset

variable {a : ℕ}

/-- **Membership test for the staircase semigroup.** For `a ≥ 1`,
`n ∈ ⟨a, a+1⟩` exactly when the quotient of `n` by `a` is at least its remainder. -/
theorem isRep_succ_iff (ha : 0 < a) (n : ℕ) : IsRep a (a + 1) n ↔ n % a ≤ n / a := by
  constructor
  · rintro ⟨i, j, rfl⟩
    induction j using Nat.strong_induction_on generalizing i with
    | _ j IH =>
      by_cases hj : j < a
      · have hrw : a * i + (a + 1) * j = a * (i + j) + j := by ring
        rw [hrw, Nat.mul_add_div ha, Nat.mul_add_mod, Nat.mod_eq_of_lt hj,
          Nat.div_eq_of_lt hj]
        omega
      · obtain ⟨k, rfl⟩ : ∃ k, j = a + k := ⟨j - a, by omega⟩
        have hk := IH k (by omega) (i + a + 1)
        rwa [show a * (i + a + 1) + (a + 1) * k = a * i + (a + 1) * (a + k) from by ring] at hk
  · intro h
    refine ⟨n / a - n % a, n % a, ?_⟩
    have hsplit : a * (n / a - n % a) + a * (n % a) = a * (n / a) := by
      rw [← Nat.mul_add]
      congr 1
      omega
    have hdm : a * (n / a) + n % a = n := Nat.div_add_mod n a
    have hexp : (a + 1) * (n % a) = a * (n % a) + n % a := by ring
    omega

/-- The gap runs of `⟨a, a+1⟩`: their starting points are exactly the numbers
`q·(a+1) + 1` for `0 ≤ q < a − 1`, one per staircase step. -/
theorem downJumps_succ (ha : 1 < a) :
    downJumps a (a + 1) = (Finset.range (a - 1)).image (fun q => q * (a + 1) + 1) := by
  have ha0 : 0 < a := by omega
  ext n
  simp only [downJumps, Finset.mem_filter, Finset.mem_Icc, Finset.mem_image, Finset.mem_range,
    isRep_succ_iff ha0, Nat.add_sub_cancel, not_le]
  constructor
  · rintro ⟨⟨hn1, -⟩, hgap, hprev⟩
    have hlt : n % a < a := Nat.mod_lt _ ha0
    have hprev' : (n - 1) % a = n % a - 1 ∧ (n - 1) / a = n / a := by
      obtain ⟨q, r, hr, rfl⟩ : ∃ q r, r < a ∧ n = a * q + r :=
        ⟨n / a, n % a, Nat.mod_lt _ ha0, (Nat.div_add_mod n a).symm⟩
      have hrpos : 0 < r := by
        rcases Nat.eq_zero_or_pos r with h | h
        · subst h
          rw [Nat.add_zero, Nat.mul_mod_right, Nat.mul_div_cancel_left _ ha0] at hgap
          omega
        · exact h
      have h1 : a * q + r - 1 = a * q + (r - 1) := by omega
      rw [h1, Nat.mul_add_div ha0, Nat.mul_add_mod, Nat.mul_add_div ha0, Nat.mul_add_mod,
        Nat.mod_eq_of_lt (by omega : r - 1 < a), Nat.mod_eq_of_lt hr,
        Nat.div_eq_of_lt (by omega : r - 1 < a), Nat.div_eq_of_lt hr]
      omega
    have hkey : n % a = n / a + 1 := by omega
    have hdm : a * (n / a) + n % a = n := Nat.div_add_mod n a
    have hexp : n / a * (a + 1) + 1 = a * (n / a) + (n / a + 1) := by ring
    exact ⟨n / a, by omega, by omega⟩
  · rintro ⟨q, hq, rfl⟩
    have hqa : q + 1 < a := by omega
    have hdiv : (q * (a + 1) + 1) / a = q := by
      have hrw : q * (a + 1) + 1 = a * q + (q + 1) := by ring
      rw [hrw, Nat.mul_add_div ha0, Nat.div_eq_of_lt hqa, Nat.add_zero]
    have hmod : (q * (a + 1) + 1) % a = q + 1 := by
      have hrw : q * (a + 1) + 1 = a * q + (q + 1) := by ring
      rw [hrw, Nat.mul_add_mod, Nat.mod_eq_of_lt hqa]
    have hprevdiv : (q * (a + 1) + 1 - 1) / a = q := by
      have hrw : q * (a + 1) + 1 - 1 = a * q + q := by
        have : q * (a + 1) + 1 - 1 = q * (a + 1) := by omega
        rw [this]; ring
      rw [hrw, Nat.mul_add_div ha0, Nat.div_eq_of_lt (by omega : q < a), Nat.add_zero]
    have hprevmod : (q * (a + 1) + 1 - 1) % a = q := by
      have hrw : q * (a + 1) + 1 - 1 = a * q + q := by
        have : q * (a + 1) + 1 - 1 = q * (a + 1) := by omega
        rw [this]; ring
      rw [hrw, Nat.mul_add_mod, Nat.mod_eq_of_lt (by omega : q < a)]
    refine ⟨⟨by omega, ?_⟩, by omega, by omega⟩
    have hle : q * (a + 1) + 1 ≤ (a - 1) * a := by
      have h1 : q ≤ a - 2 := by omega
      have h2 : q * (a + 1) + 1 ≤ (a - 2) * (a + 1) + 1 :=
        by exact Nat.add_le_add_right (Nat.mul_le_mul_right _ h1) 1
      have h3 : (a - 2) * (a + 1) + 1 ≤ (a - 1) * a := by
        obtain ⟨m, rfl⟩ : ∃ m, a = m + 2 := ⟨a - 2, by omega⟩
        simp only [Nat.add_sub_cancel]
        have : m + 2 - 1 = m + 1 := by omega
        rw [this]
        nlinarith
      omega
    exact hle

/-- **The staircase gap-run count.** `⟨a, a+1⟩` has exactly `a − 1` maximal gap runs. -/
theorem card_downJumps_succ (ha : 1 < a) : (downJumps a (a + 1)).card = a - 1 := by
  rw [downJumps_succ ha, Finset.card_image_of_injective _ ?_, Finset.card_range]
  intro x y hxy
  simp only at hxy
  have : x * (a + 1) = y * (a + 1) := by omega
  exact Nat.eq_of_mul_eq_mul_right (by omega) this

/-- **Exact support count for the staircase family.** The Alexander polynomial of the torus
knot `T(a, a+1)` has exactly `2a − 1` nonzero coefficients. -/
theorem torusAlexander_staircase_support (ha : 1 < a) :
    (torusAlexander a (a + 1)).support.card = 2 * a - 1 := by
  have hcop : Nat.Coprime a (a + 1) := by simp
  rw [torusAlexander_support_card hcop ha (by omega), card_downJumps_succ ha]
  omega

/-- The Cycle 13 bound `#supp ≥ max(a,b)` is *strict* on the staircase family as soon as
`a ≥ 3`: the true count `2a − 1` exceeds `max(a, a+1) = a + 1`.  Together with the tightness
theorem for `T(2,N)` this pins down the pencil as the unique place where the general bound is
attained inside the staircase family. -/
theorem torusAlexander_staircase_support_gt (ha : 2 < a) :
    max a (a + 1) < (torusAlexander a (a + 1)).support.card := by
  rw [torusAlexander_staircase_support (by omega)]
  omega

/-- Both families for which the support is known exactly — the pencil `T(2,N)` and the
staircase `T(a,a+1)` — realise the value `a + b − 2`. -/
theorem torusAlexander_staircase_support_eq_add_sub_two (ha : 1 < a) :
    (torusAlexander a (a + 1)).support.card = a + (a + 1) - 2 := by
  rw [torusAlexander_staircase_support ha]
  omega

end Computation.AlexanderTorusKnot