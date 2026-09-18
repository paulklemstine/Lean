/-
# BATTERY-SYNERGY, part IV: arbitrarily high-order batteries

Part III exhibited a three-dial battery whose capacity is entirely order-`3`
synergy.  Here the phenomenon is pushed to every order at once.

Fix `k` dials.  The population is the cube `Cube k = Fin k → Bool`, the `i`-th
dial reads the `i`-th bit (modulus `2`), and the label is the parity of all `k`
bits, valued in `ZMod 2`.  Then

* `ParityBattery.info_proper_eq_zero` — **every proper sub-battery carries
  exactly `0` bits**: knowing any `k - 1` of the dials leaves the label perfectly
  uncertain;
* `ParityBattery.info_univ_eq_one` — the **full battery carries exactly `1`
  bit**, which is its joint label-entropy ceiling;
* `ParityBattery.synergy_is_order_k` — consequently the additive prediction is
  `0` while the joint capacity is `1`: all of the capacity is order-`k` synergy,
  for every `k ≥ 1`.

This is the strongest possible form of the round-27 verdict
*SYNERGY-COMPOUNDS*: the synergy of a battery is not controlled by the synergies
of its sub-batteries at any lower order, and the ratio
`joint capacity / Σ marginals` is unbounded (indeed undefined, the denominator
being `0`) for every width `k`.

The arithmetic is exact: fibre cardinalities are computed with
`Fintype.piFinset` and a coordinate-flip involution, and the entropies follow
from part I's `H_eq_log_sub_log_of_uniform`.
-/
import Mathlib
import MachineLearning.BatterySynergy.Capacity

namespace BatterySynergy

namespace ParityBattery

open TraceBattery Finset

variable {k : ℕ}

/-! ## 1. The cube, its coordinate dials and the parity label -/

/-- The population of `k` bits. -/
abbrev Cube (k : ℕ) : Type := Fin k → Bool

/-- The reading of the `i`-th coordinate dial. -/
def crd (i : Fin k) (x : Cube k) : ℕ := if x i then 1 else 0

/-- The parity label. -/
def parz (x : Cube k) : ZMod 2 := ∑ i, (if x i then 1 else 0)

/-- The `k`-dial coordinate battery. -/
def cdial (i : Fin k) : Dial (Cube k) where
  modulus := 2
  modulus_pos := by norm_num
  read := crd i
  read_lt := by
    intro x
    unfold crd
    split <;> norm_num

theorem crd_eq_iff (i : Fin k) (x y : Cube k) : crd i x = crd i y ↔ x i = y i := by
  unfold crd
  cases hx : x i <;> cases hy : y i <;> simp

/-- The fibres of a sub-battery are the coordinate-agreement classes. -/
theorem joint_iff (S : Finset (Fin k)) (x y : Cube k) :
    joint cdial S x = joint cdial S y ↔ ∀ i ∈ S, x i = y i := by
  constructor
  · intro h i hi
    exact (crd_eq_iff i x y).1 (congrFun h ⟨i, hi⟩)
  · intro h
    funext i
    exact (crd_eq_iff i.1 x y).2 (h i.1 i.2)

theorem card_cube : Fintype.card (Cube k) = 2 ^ k := by
  simp [Cube]

/-! ## 2. Coordinate-agreement classes and their cardinalities -/

/-- The individuals agreeing with `a` on the dials of `S`. -/
def agree (S : Finset (Fin k)) (a : Cube k) : Finset (Cube k) :=
  Finset.univ.filter (fun x => ∀ i ∈ S, x i = a i)

theorem mem_agree {S : Finset (Fin k)} {a x : Cube k} :
    x ∈ agree S a ↔ ∀ i ∈ S, x i = a i := by
  simp [agree]

theorem agree_eq_piFinset (S : Finset (Fin k)) (a : Cube k) :
    agree S a
      = Fintype.piFinset (fun i => if i ∈ S then ({a i} : Finset Bool) else Finset.univ) := by
  ext x
  simp only [mem_agree, Fintype.mem_piFinset]
  constructor
  · intro h i
    by_cases hi : i ∈ S <;> simp [hi, h i]
  · intro h i hi
    have := h i
    simp only [hi, if_true, Finset.mem_singleton] at this
    exact this

/-- **The agreement class has `2 ^ (k - |S|)` members.** -/
theorem card_agree (S : Finset (Fin k)) (a : Cube k) :
    (agree S a).card = 2 ^ (k - S.card) := by
  classical
  rw [agree_eq_piFinset, Fintype.card_piFinset]
  have hcard : ∀ i : Fin k,
      (if i ∈ S then ({a i} : Finset Bool) else Finset.univ).card = if i ∈ S then 1 else 2 := by
    intro i
    by_cases hi : i ∈ S <;> simp [hi]
  rw [Finset.prod_congr rfl (fun i _ => hcard i), Finset.prod_ite, Finset.prod_const_one,
    Finset.prod_const, one_mul]
  congr 1
  have hfil : (Finset.univ.filter (fun i : Fin k => i ∉ S)) = Finset.univ \ S := by
    ext i
    simp
  rw [hfil, Finset.card_univ_diff, Fintype.card_fin]

/-! ## 3. The coordinate flip halves an agreement class -/

/-- Flip the `j`-th bit. -/
def flipAt (j : Fin k) (x : Cube k) : Cube k := Function.update x j (!x j)

theorem flipAt_involutive (j : Fin k) (x : Cube k) : flipAt j (flipAt j x) = x := by
  funext i
  unfold flipAt
  by_cases hij : i = j
  · subst hij
    simp
  · simp [Function.update_of_ne hij]

theorem flipAt_of_ne {j i : Fin k} (h : i ≠ j) (x : Cube k) : flipAt j x i = x i := by
  simp [flipAt, Function.update_of_ne h]

/-- Flipping one bit toggles the parity. -/
theorem parz_flipAt (j : Fin k) (x : Cube k) : parz (flipAt j x) = parz x + 1 := by
  classical
  have hsplit : ∀ y : Cube k,
      parz y = (if y j then 1 else 0) + ∑ i ∈ Finset.univ.erase j, (if y i then 1 else 0) := by
    intro y
    rw [parz, ← Finset.add_sum_erase _ _ (Finset.mem_univ j)]
  rw [hsplit (flipAt j x), hsplit x]
  have hcoord : ∀ i ∈ Finset.univ.erase j,
      (if flipAt j x i then (1 : ZMod 2) else 0) = if x i then 1 else 0 := by
    intro i hi
    rw [flipAt_of_ne (Finset.ne_of_mem_erase hi) x]
  rw [Finset.sum_congr rfl hcoord]
  have hjv : flipAt j x j = !x j := by simp [flipAt]
  have key : ∀ b : Bool, (if !b then (1 : ZMod 2) else 0) = (if b then 1 else 0) + 1 := by decide
  rw [hjv, key]
  ring

/-- **Half of an agreement class has each parity**, provided the class has a free
coordinate `j ∉ S`. -/
theorem card_agree_parity {S : Finset (Fin k)} {j : Fin k} (hj : j ∉ S) (a : Cube k)
    (p : ZMod 2) :
    ((agree S a).filter (fun x => parz x = p)).card = 2 ^ (k - S.card - 1) := by
  classical
  set T0 := (agree S a).filter (fun x => parz x = p) with hT0
  set T1 := (agree S a).filter (fun x => parz x = p + 1) with hT1
  have hflip_mem : ∀ x ∈ agree S a, flipAt j x ∈ agree S a := by
    intro x hx
    rw [mem_agree] at hx ⊢
    intro i hi
    have hij : i ≠ j := by
      rintro rfl
      exact hj hi
    rw [flipAt_of_ne hij x]
    exact hx i hi
  have hcard : T0.card = T1.card := by
    refine Finset.card_bij' (fun x _ => flipAt j x) (fun x _ => flipAt j x) ?_ ?_ ?_ ?_
    · intro x hx
      rw [hT0, Finset.mem_filter] at hx
      rw [hT1, Finset.mem_filter]
      exact ⟨hflip_mem x hx.1, by rw [parz_flipAt, hx.2]⟩
    · intro x hx
      rw [hT1, Finset.mem_filter] at hx
      rw [hT0, Finset.mem_filter]
      have htwice : ∀ q : ZMod 2, q + 1 + 1 = q := by decide
      exact ⟨hflip_mem x hx.1, by rw [parz_flipAt, hx.2, htwice]⟩
    · intro x _
      exact flipAt_involutive j x
    · intro x _
      exact flipAt_involutive j x
  have hne : ∀ q r : ZMod 2, (q = r + 1) ↔ ¬ q = r := by decide
  have hcompl : T1 = (agree S a).filter (fun x => ¬ parz x = p) := by
    rw [hT1]
    exact Finset.filter_congr fun x _ => hne (parz x) p
  have hsplit : T0.card + T1.card = (agree S a).card := by
    rw [hcompl, hT0]
    exact Finset.card_filter_add_card_filter_not (fun x => parz x = p)
  have hpos : 0 < k - S.card := by
    have hlt : S.card < k := by
      have hsub : S ⊆ Finset.univ.erase j := by
        intro i hi
        refine Finset.mem_erase.2 ⟨?_, Finset.mem_univ i⟩
        rintro rfl
        exact hj hi
      have hkpos : 0 < k := lt_of_le_of_lt (Nat.zero_le _) j.isLt
      have := Finset.card_le_card hsub
      rw [Finset.card_erase_of_mem (Finset.mem_univ j), Finset.card_univ, Fintype.card_fin] at this
      omega
    omega
  have hpow : (2 : ℕ) ^ (k - S.card) = 2 * 2 ^ (k - S.card - 1) := by
    obtain ⟨m, hm⟩ : ∃ m, k - S.card = m + 1 := ⟨k - S.card - 1, by omega⟩
    rw [hm, Nat.add_sub_cancel, pow_succ]
    ring
  rw [card_agree] at hsplit
  have hdouble : 2 * T0.card = 2 * 2 ^ (k - S.card - 1) := by
    rw [← hpow, ← hsplit, hcard]
    ring
  exact Nat.eq_of_mul_eq_mul_left (by norm_num) hdouble

/-! ## 4. Fibre counts of the sub-battery statistics -/

theorem fib_joint (S : Finset (Fin k)) (a : Cube k) :
    fib (joint cdial S) (joint cdial S a) = agree S a := by
  ext x
  rw [mem_fib, mem_agree, joint_iff]

theorem cnt_joint {S : Finset (Fin k)} {v : (↥S → ℕ)} (hv : v ∈ img (joint cdial S)) :
    cnt (joint cdial S) v = 2 ^ (k - S.card) := by
  obtain ⟨a, rfl⟩ := mem_img.1 hv
  rw [cnt, fib_joint, card_agree]

theorem fib_pr (S : Finset (Fin k)) (a : Cube k) :
    fib (pr parz (joint cdial S)) (pr parz (joint cdial S) a)
      = (agree S a).filter (fun x => parz x = parz a) := by
  ext x
  rw [mem_fib, Finset.mem_filter, mem_agree]
  simp only [pr, Prod.mk.injEq, joint_iff]
  tauto

theorem cnt_pr {S : Finset (Fin k)} {j : Fin k} (hj : j ∉ S) {w : ZMod 2 × (↥S → ℕ)}
    (hw : w ∈ img (pr parz (joint cdial S))) :
    cnt (pr parz (joint cdial S)) w = 2 ^ (k - S.card - 1) := by
  obtain ⟨a, rfl⟩ := mem_img.1 hw
  rw [cnt, fib_pr, card_agree_parity hj]

/-! ## 5. The entropies -/

theorem log_two_pow (n : ℕ) : Real.log ((2 ^ n : ℕ) : ℝ) = n * Real.log 2 := by
  push_cast
  rw [Real.log_pow]

theorem H_joint (S : Finset (Fin k)) : H (joint cdial S) = S.card * Real.log 2 := by
  have hcard : S.card ≤ k := by
    have := Finset.card_le_card (Finset.subset_univ S)
    rwa [Finset.card_univ, Fintype.card_fin] at this
  have h := H_eq_log_sub_log_of_uniform (joint cdial S) (2 ^ (k - S.card))
    (Nat.two_pow_pos _) (fun v hv => cnt_joint hv)
  rw [h, card_cube, log_two_pow, log_two_pow]
  have hcast : ((k - S.card : ℕ) : ℝ) = (k : ℝ) - (S.card : ℝ) := by
    rw [Nat.cast_sub hcard]
  rw [hcast]
  ring

theorem H_pr_joint {S : Finset (Fin k)} {j : Fin k} (hj : j ∉ S) :
    H (pr parz (joint cdial S)) = (S.card + 1) * Real.log 2 := by
  have hlt : S.card < k := by
    have hsub : S ⊆ Finset.univ.erase j := by
      intro i hi
      refine Finset.mem_erase.2 ⟨?_, Finset.mem_univ i⟩
      rintro rfl
      exact hj hi
    have hkpos : 0 < k := lt_of_le_of_lt (Nat.zero_le _) j.isLt
    have := Finset.card_le_card hsub
    rw [Finset.card_erase_of_mem (Finset.mem_univ j), Finset.card_univ, Fintype.card_fin] at this
    omega
  have h := H_eq_log_sub_log_of_uniform (pr parz (joint cdial S)) (2 ^ (k - S.card - 1))
    (Nat.two_pow_pos _) (fun w hw => cnt_pr hj hw)
  rw [h, card_cube, log_two_pow, log_two_pow]
  have hc : ((k - S.card - 1 : ℕ) : ℝ) = (k : ℝ) - (S.card : ℝ) - 1 := by
    have h1 : S.card + 1 ≤ k := hlt
    have hstep : k - S.card - 1 = k - (S.card + 1) := by omega
    rw [hstep, Nat.cast_sub h1]
    push_cast
    ring
  rw [hc]
  ring

theorem H_parz (hk : 0 < k) : H (parz : Cube k → ZMod 2) = Real.log 2 := by
  obtain ⟨j⟩ : Nonempty (Fin k) := Fin.pos_iff_nonempty.1 hk
  have hj : j ∉ (∅ : Finset (Fin k)) := Finset.notMem_empty j
  have hfib : ∀ p ∈ img (parz : Cube k → ZMod 2),
      cnt (parz : Cube k → ZMod 2) p = 2 ^ (k - 0 - 1) := by
    intro p hp
    obtain ⟨a, rfl⟩ := mem_img.1 hp
    have hfil : fib (parz : Cube k → ZMod 2) (parz a)
        = (agree (∅ : Finset (Fin k)) a).filter (fun x => parz x = parz a) := by
      ext x
      rw [mem_fib, Finset.mem_filter, mem_agree]
      simp
    rw [cnt, hfil, card_agree_parity hj]
    simp
  have h := H_eq_log_sub_log_of_uniform (parz : Cube k → ZMod 2) (2 ^ (k - 0 - 1))
    (Nat.two_pow_pos _) hfib
  rw [h, card_cube, log_two_pow, log_two_pow]
  have hk1 : 1 ≤ k := hk
  have hcast : ((k - 0 - 1 : ℕ) : ℝ) = (k : ℝ) - 1 := by
    have hstep : k - 0 - 1 = k - 1 := by omega
    rw [hstep, Nat.cast_sub hk1]
    push_cast
    ring
  rw [hcast]
  ring

/-! ## 6. The verdict at every order -/

/-- **Every proper sub-battery is blind.**  If even one dial is missing, the
remaining `k - 1` dials carry exactly `0` bits about the parity label. -/
theorem info_proper_eq_zero (hk : 0 < k) {S : Finset (Fin k)} (hS : S ≠ Finset.univ) :
    info cdial (parz : Cube k → ZMod 2) S = 0 := by
  obtain ⟨j, hj⟩ : ∃ j : Fin k, j ∉ S := by
    by_contra hcon
    push_neg at hcon
    exact hS (Finset.eq_univ_iff_forall.2 hcon)
  have hMI : MI (parz : Cube k → ZMod 2) (joint cdial S) = 0 := by
    rw [MI_eq, H_parz hk, H_joint S, H_pr_joint hj]
    ring
  rw [info, MIb, hMI, zero_div]

/-- **The full battery saturates its ceiling**: it pins the parity label, so it
carries exactly `1` bit. -/
theorem info_univ_eq_one (hk : 0 < k) :
    info cdial (parz : Cube k → ZMod 2) Finset.univ = 1 := by
  have hdet : ∀ x y : Cube k, joint cdial Finset.univ x = joint cdial Finset.univ y →
      parz x = parz y := by
    intro x y h
    have h' := (joint_iff Finset.univ x y).1 h
    have : x = y := funext fun i => h' i (Finset.mem_univ i)
    rw [this]
  rw [info, MIb_eq_label_entropy_of_determines _ _ hdet, Hb, H_parz hk]
  field_simp

/-- Each single dial is blind, as long as there are at least two dials. -/
theorem info_singleton_eq_zero (hk : 1 < k) (i : Fin k) :
    info cdial (parz : Cube k → ZMod 2) {i} = 0 := by
  refine info_proper_eq_zero (by omega) ?_
  intro hcon
  have hcard : ({i} : Finset (Fin k)).card = Fintype.card (Fin k) := by
    rw [hcon, Finset.card_univ]
  rw [Finset.card_singleton, Fintype.card_fin] at hcard
  omega

/-- **SYNERGY-COMPOUNDS at every order.**  For the `k`-dial parity battery with
`k ≥ 2`:

* every dial carries `0` bits, so the additive prediction is `0`;
* *every* proper sub-battery — of any size `< k` — carries `0` bits, so every
  synergy of order `< k` vanishes;
* the full battery carries `1` bit, its joint label-entropy ceiling, and all of
  it is order-`k` synergy.

Hence no bookkeeping over sub-batteries of bounded order can predict the
capacity of a battery: the capacity arithmetic must be done jointly. -/
theorem synergy_is_order_k (hk : 1 < k) :
    (∀ S : Finset (Fin k), S ≠ Finset.univ → info cdial (parz : Cube k → ZMod 2) S = 0) ∧
    (∀ S : Finset (Fin k), S ≠ Finset.univ → synergy cdial (parz : Cube k → ZMod 2) S = 0) ∧
    info cdial (parz : Cube k → ZMod 2) Finset.univ = 1 ∧
    synergy cdial (parz : Cube k → ZMod 2) Finset.univ = 1 := by
  have hk0 : 0 < k := by omega
  have hmarg : ∀ i : Fin k, info cdial (parz : Cube k → ZMod 2) {i} = 0 :=
    info_singleton_eq_zero hk
  refine ⟨fun S hS => info_proper_eq_zero hk0 hS, fun S hS => ?_, info_univ_eq_one hk0, ?_⟩
  · rw [synergy, info_proper_eq_zero hk0 hS, Finset.sum_congr rfl (fun i _ => hmarg i)]
    simp
  · rw [synergy, info_univ_eq_one hk0, Finset.sum_congr rfl (fun i _ => hmarg i)]
    simp

end ParityBattery

end BatterySynergy