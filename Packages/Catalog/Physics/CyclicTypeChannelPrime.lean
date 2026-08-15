import Catalog.Physics.CyclicTypeChannelPrimeCore

/-!
# The prime-order cyclic type-pair channel: closed form, sub-cap theorem, CRT additivity

This file continues `Catalog.Physics.CyclicTypeChannelPrimeCore`, which evaluates the
type-pair occupation numbers of a *prime* cyclic order `p` for symbolic `p`.

## Main results

* `CyclicType.Ipair_prime` : the exact closed form, valid for **every** prime `p`,
  `Ipair p = log₂ p - ((p-1)(2p-1)/p²) log₂ (p-1) + ((p-1)(p-2)/p²) log₂ (p-2)`.
* `CyclicType.Ipair_prime_le` : the upper envelope
  `Ipair p ≤ log₂ p - log₂ (p-1) + log₂ (p-1)/p²`.
* `CyclicType.Ipair_prime_decay` : `Ipair p < 3/(p-1)` for every odd prime — the prime-order
  channel is asymptotically silent.
* `CyclicType.Ipair_prime_lt_one` : **the sub-cap theorem**: every odd prime cyclic order stays
  strictly below the one-bit binary-fork cap; `CyclicType.Ipair_prime_eq_one_iff_two` shows
  `p = 2` is the unique prime attaining it.  Combined with the strict violations
  `1 < Ipair 4, 6, 8, 10, 12, 14, 16` of `Catalog.Computation.CyclicTypeChannelLaws`, the
  cap-breaking phenomenon is pinned on the *divisor structure* of the cyclic order.
* `CyclicType.typNat_mul_coprime`, `CyclicType.typNat_lcm` : the CRT decomposition of the
  splitting type, `T_{mn} = T_m · T_n = lcm (T_m, T_n)` for coprime moduli.
* `CyclicType.HT_mul_coprime` : the exact additivity `H(T)(mn) = H(T)(m) + H(T)(n)` of the
  type entropy over coprime factorisations, for all `m, n ≥ 1`.
-/

set_option maxHeartbeats 1000000

namespace CyclicType

open Finset

variable {p : ℕ}

section Conditional

variable [NeZero p]

/-- The three type-pair states of a prime cyclic order, in terms of `x = 0`. -/
lemma keyOf_prime' (hp : p.Prime) (w : Fin p × Fin p) :
    keyOf p w = if w.1 = 0 then (if w.2 = 0 then (1, 1) else (1, p))
      else (if w.2 = 0 then (1, p) else (p, p)) := by
  rw [keyOf_prime hp]
  simp only [Fin.val_eq_zero_iff]

lemma sum_ite_eq_zero (p : ℕ) [NeZero p] : ∑ x : Fin p, (if x = 0 then 1 else 0) = 1 := by
  simp

lemma sum_ite_ne_zero (p : ℕ) [NeZero p] : ∑ x : Fin p, (if x = 0 then 0 else 1) = p - 1 := by
  simpa only [Fin.val_eq_zero_iff] using sum_ite_val_ne_zero p

/-- Conditioned on the norm class `N = 0`, the type pair is `{1,1}` once and `{p,p}` for the
remaining `p - 1` residues; the mixed state `{1,p}` cannot occur. -/
lemma condCounts_perm_zero (hp : p.Prime) :
    (condCounts p 0).Perm [1, 0, p - 1] := by
  have hne : (1 : ℕ) ≠ p := hp.one_lt.ne
  have h := (keyList_perm_primeKeys hp).map
    (fun k => ((allPairs p).filter
      (fun w => w.1 + w.2 = (0 : Fin p) ∧ keyOf p w = k)).length)
  rw [condCounts]
  refine h.trans ?_
  rw [primeKeys]
  simp only [List.map_cons, List.map_nil]
  have hzero : ∀ x : Fin p, ((0 : Fin p) - x = 0) ↔ (x = 0) := by
    intro x; rw [zero_sub, neg_eq_zero]
  have key : ∀ x : Fin p, keyOf p (x, (0 : Fin p) - x)
      = if x = 0 then ((1 : ℕ), (1 : ℕ)) else (p, p) := by
    intro x
    rw [keyOf_prime' hp]
    by_cases hx : x = 0
    · simp [hx]
    · simp [hx]
  have e1 : ((allPairs p).filter
      (fun w => w.1 + w.2 = (0 : Fin p) ∧ keyOf p w = (1, 1))).length = 1 := by
    rw [condCount_eval (0 : Fin p) (1, 1)]
    have hsimp : ∀ x : Fin p,
        (if keyOf p (x, (0 : Fin p) - x) = ((1 : ℕ), (1 : ℕ)) then 1 else 0)
          = (if x = 0 then 1 else 0) := by
      intro x
      rw [key x]
      by_cases hx : x = 0 <;> simp [hp.ne_one, hx, Prod.ext_iff]
    simp only [hsimp, sum_ite_eq_zero]
  have e2 : ((allPairs p).filter
      (fun w => w.1 + w.2 = (0 : Fin p) ∧ keyOf p w = (1, p))).length = 0 := by
    rw [condCount_eval (0 : Fin p) (1, p)]
    have hsimp : ∀ x : Fin p,
        (if keyOf p (x, (0 : Fin p) - x) = ((1 : ℕ), p) then 1 else 0) = 0 := by
      intro x
      rw [key x]
      by_cases hx : x = 0 <;> simp [hp.ne_one, hx, hne, Prod.ext_iff]
    simp only [hsimp, Finset.sum_const_zero]
  have e3 : ((allPairs p).filter
      (fun w => w.1 + w.2 = (0 : Fin p) ∧ keyOf p w = (p, p))).length = p - 1 := by
    rw [condCount_eval (0 : Fin p) (p, p)]
    have hsimp : ∀ x : Fin p, (if keyOf p (x, (0 : Fin p) - x) = (p, p) then 1 else 0)
        = (if x = 0 then 0 else 1) := by
      intro x
      rw [key x]
      by_cases hx : x = 0 <;> simp [hx, hne, Prod.ext_iff]
    simp only [hsimp, sum_ite_ne_zero]
  rw [e1, e2, e3]

/-- Conditioned on a nonzero norm class, the type pair is mixed `{1,p}` exactly twice and
`{p,p}` for the remaining `p - 2` residues; the split state `{1,1}` cannot occur. -/
lemma condCounts_perm_ne (hp : p.Prime) {c : Fin p} (hc : c ≠ 0) :
    (condCounts p c).Perm [0, 2, p - 2] := by
  have hne : (1 : ℕ) ≠ p := hp.one_lt.ne
  have h := (keyList_perm_primeKeys hp).map
    (fun k => ((allPairs p).filter (fun w => w.1 + w.2 = c ∧ keyOf p w = k)).length)
  rw [condCounts]
  refine h.trans ?_
  rw [primeKeys]
  simp only [List.map_cons, List.map_nil]
  have hzero : ∀ x : Fin p, (c - x = 0) ↔ (x = c) := by
    intro x
    rw [sub_eq_zero]
    exact eq_comm
  have key : ∀ x : Fin p, keyOf p (x, c - x)
      = if x = 0 then ((1 : ℕ), p) else if x = c then ((1 : ℕ), p) else (p, p) := by
    intro x
    rw [keyOf_prime' hp]
    by_cases hx : x = 0
    · have hcx : ¬ (c - x = 0) := by rw [hzero x, hx]; exact fun h => hc h.symm
      simp [hc, hx]
    · by_cases hxc : x = c
      · have hcx : c - x = 0 := (hzero x).2 hxc
        simp [hc, hxc]
      · have hcx : ¬ (c - x = 0) := by rw [hzero x]; exact hxc
        simp [hx, hxc, hcx]
  have e1 : ((allPairs p).filter
      (fun w => w.1 + w.2 = c ∧ keyOf p w = (1, 1))).length = 0 := by
    rw [condCount_eval c (1, 1)]
    have hsimp : ∀ x : Fin p,
        (if keyOf p (x, c - x) = ((1 : ℕ), (1 : ℕ)) then 1 else 0) = 0 := by
      intro x
      rw [key x]
      by_cases hx : x = 0
      · simp [hp.ne_one, hx, Prod.ext_iff]
      · by_cases hxc : x = c <;> simp [hp.ne_one, hc, hx, hxc, Prod.ext_iff]
    simp only [hsimp, Finset.sum_const_zero]
  have e2 : ((allPairs p).filter
      (fun w => w.1 + w.2 = c ∧ keyOf p w = (1, p))).length = 2 := by
    rw [condCount_eval c (1, p)]
    have hsimp : ∀ x : Fin p, (if keyOf p (x, c - x) = ((1 : ℕ), p) then 1 else 0)
        = (if x = 0 then 1 else 0) + (if x = c then 1 else 0) := by
      intro x
      rw [key x]
      by_cases hx : x = 0
      · have hxc : ¬ (x = c) := by rw [hx]; exact fun h => hc h.symm
        simp [Ne.symm hc, hx]
      · by_cases hxc : x = c <;> simp [hp.ne_one, hc, hx, hxc, Prod.ext_iff]
    simp only [hsimp, Finset.sum_add_distrib]
    simp
  have e3 : ((allPairs p).filter
      (fun w => w.1 + w.2 = c ∧ keyOf p w = (p, p))).length = p - 2 := by
    rw [condCount_eval c (p, p)]
    have hsimp : ∀ x : Fin p, (if keyOf p (x, c - x) = (p, p) then 1 else 0)
        = (if x = 0 then 0 else if x = c then 0 else 1) := by
      intro x
      rw [key x]
      by_cases hx : x = 0
      · simp [hx, hne, Prod.ext_iff]
      · by_cases hxc : x = c <;> simp [hc, hx, hxc, hne, Prod.ext_iff]
    simp only [hsimp]
    exact sum_ite_two_ne p hc
  rw [e1, e2, e3]

end Conditional

/-! ## The exact closed form -/

lemma cast_sub_one (hp : p.Prime) : ((p - 1 : ℕ) : ℝ) = (p : ℝ) - 1 := by
  have h : 1 ≤ p := hp.one_lt.le
  push_cast [h]
  ring

lemma cast_sub_two (hp : p.Prime) : ((p - 2 : ℕ) : ℝ) = if p = 2 then 0 else (p : ℝ) - 2 := by
  rcases eq_or_ne p 2 with rfl | h2
  · norm_num
  · rw [if_neg h2]
    push_cast [hp.two_le]
    ring

lemma Hpair_prime (hp : p.Prime) :
    Hpair p = 2 * Real.logb 2 p
      - (1 / (p : ℝ) ^ 2) * (2 * ((p : ℝ) - 1)
        + 2 * (p : ℝ) * ((p : ℝ) - 1) * Real.logb 2 ((p : ℝ) - 1)) := by
  have hp1 : (1 : ℕ) ≤ p := hp.one_lt.le
  have hppos : 0 < p := hp.pos
  have hsum : ([1, 2 * (p - 1), (p - 1) * (p - 1)] : List ℕ).sum = p * p := by
    obtain ⟨q, rfl⟩ : ∃ q, p = q + 1 := ⟨p - 1, by omega⟩
    simp only [List.sum_cons, List.sum_nil, Nat.add_sub_cancel]
    ring
  have hpr : (0 : ℝ) < (p : ℝ) := by exact_mod_cast hppos
  have hne1 : ((p : ℝ) - 1) ≠ 0 := by
    have h2 : (2 : ℝ) ≤ (p : ℝ) := by exact_mod_cast hp.two_le
    intro h; linarith
  rw [Hpair, Hlist_perm (pairCounts_perm_prime hp),
    Hlist_eq_SL (p * p) _ hsum (Nat.mul_pos hppos hppos), SL]
  have hlog : Real.logb 2 ((p * p : ℕ) : ℝ) = 2 * Real.logb 2 p := by
    push_cast
    rw [show (p : ℝ) * p = (p : ℝ) ^ 2 by ring, Real.logb_pow]
    ring
  rw [hlog]
  congr 1
  have hc1 : ((2 * (p - 1) : ℕ) : ℝ) = 2 * ((p : ℝ) - 1) := by
    push_cast [hp1]; ring
  have hc2 : (((p - 1) * (p - 1) : ℕ) : ℝ) = ((p : ℝ) - 1) * ((p : ℝ) - 1) := by
    push_cast [hp1]; ring
  have hlog1 : Real.logb 2 (2 * ((p : ℝ) - 1)) = 1 + Real.logb 2 ((p : ℝ) - 1) := by
    rw [Real.logb_mul (by norm_num) hne1, lb_2]
  have hlog2 : Real.logb 2 (((p : ℝ) - 1) * ((p : ℝ) - 1)) = 2 * Real.logb 2 ((p : ℝ) - 1) := by
    rw [Real.logb_mul hne1 hne1]; ring
  simp only [List.map_cons, List.map_nil, List.sum_cons, List.sum_nil, Nat.cast_one,
    Real.logb_one, mul_zero, zero_add, add_zero, hc1, hc2, hlog1, hlog2]
  push_cast
  ring

lemma HpairGivenN_prime (hp : p.Prime) :
    HpairGivenN p = Real.logb 2 p
      - (1 / (p : ℝ) ^ 2) * (((p : ℝ) - 1) * Real.logb 2 ((p : ℝ) - 1))
      - (1 / (p : ℝ) ^ 2) * (((p : ℝ) - 1)
          * (2 + ((p : ℝ) - 2) * Real.logb 2 ((p : ℝ) - 2))) := by
  haveI : NeZero p := ⟨hp.ne_zero⟩
  have hppos : 0 < p := hp.pos
  have hpr : (0 : ℝ) < (p : ℝ) := by exact_mod_cast hppos
  have hp2 : 2 ≤ p := hp.two_le
  have hsum0 : ([1, 0, p - 1] : List ℕ).sum = p := by simp; omega
  have hsum1 : ([0, 2, p - 2] : List ℕ).sum = p := by simp; omega
  have hA : Hlist p (condCounts p 0)
      = Real.logb 2 p - (1 / (p : ℝ)) * (((p : ℝ) - 1) * Real.logb 2 ((p : ℝ) - 1)) := by
    rw [Hlist_perm (condCounts_perm_zero hp), Hlist_eq_SL p _ hsum0 hppos, SL]
    simp only [List.map_cons, List.map_nil, List.sum_cons, List.sum_nil, Nat.cast_one,
      Real.logb_one, mul_zero, zero_add, add_zero, Nat.cast_zero, cast_sub_one hp]
    norm_num
  have hB : ∀ c : Fin p, c ≠ 0 → Hlist p (condCounts p c)
      = Real.logb 2 p
        - (1 / (p : ℝ)) * (2 + ((p : ℝ) - 2) * Real.logb 2 ((p : ℝ) - 2)) := by
    intro c hc
    rw [Hlist_perm (condCounts_perm_ne hp hc), Hlist_eq_SL p _ hsum1 hppos, SL]
    simp only [List.map_cons, List.map_nil, List.sum_cons, List.sum_nil, Nat.cast_zero,
      Real.logb_zero, mul_zero, zero_add, add_zero, Nat.cast_ofNat]
    rcases eq_or_ne p 2 with rfl | hne2
    · norm_num
    · rw [cast_sub_two hp, if_neg hne2, lb_2]
      ring
  rw [HpairGivenN, condTable, List.map_map, ← sum_fin_eq_list]
  have hterm : ∀ c : Fin p, ((Hlist p ∘ condCounts p) c)
      = if c = 0 then (Real.logb 2 p - (1 / (p : ℝ)) * (((p : ℝ) - 1)
            * Real.logb 2 ((p : ℝ) - 1)))
        else (Real.logb 2 p - (1 / (p : ℝ)) * (2 + ((p : ℝ) - 2)
            * Real.logb 2 ((p : ℝ) - 2))) := by
    intro c
    rcases eq_or_ne c 0 with rfl | hc
    · simpa using hA
    · simpa [hc] using hB c hc
  simp only [hterm]
  rw [Finset.sum_ite, Finset.sum_const, Finset.sum_const, Finset.filter_eq',
    Finset.filter_ne']
  simp only [Finset.mem_univ, if_true, Finset.card_singleton, one_smul,
    Finset.card_erase_of_mem, Finset.card_univ, Fintype.card_fin]
  rw [nsmul_eq_mul, cast_sub_one hp]
  field_simp
  ring

/-- **The prime-order type-pair channel, exactly.**  For every prime `p` the semiprime
type-pair channel of the cyclic order `p` equals
`log₂ p - ((p-1)(2p-1)/p²) log₂(p-1) + ((p-1)(p-2)/p²) log₂(p-2)`.

Specialising: `Ipair 2 = 1` (the quadratic fork sits exactly at the binary cap),
`Ipair 3 = log₂ 3 - 10/9 ≈ 0.4739`, `Ipair 5 ≈ 0.2027`. -/
theorem Ipair_prime (hp : p.Prime) :
    Ipair p = Real.logb 2 p
      - (((p : ℝ) - 1) * (2 * (p : ℝ) - 1) / (p : ℝ) ^ 2) * Real.logb 2 ((p : ℝ) - 1)
      + (((p : ℝ) - 1) * ((p : ℝ) - 2) / (p : ℝ) ^ 2) * Real.logb 2 ((p : ℝ) - 2) := by
  have hppos : (0 : ℝ) < (p : ℝ) := by exact_mod_cast hp.pos
  rw [Ipair, Hpair_prime hp, HpairGivenN_prime hp]
  field_simp
  ring

/-! ## Consequences: the one-bit cap is never broken by a prime order -/

/-- The clean upper envelope of the prime-order channel. -/
theorem Ipair_prime_le (hp : p.Prime) :
    Ipair p ≤ Real.logb 2 p - Real.logb 2 ((p : ℝ) - 1)
      + Real.logb 2 ((p : ℝ) - 1) / (p : ℝ) ^ 2 := by
  have hp2 : (2 : ℝ) ≤ (p : ℝ) := by exact_mod_cast hp.two_le
  have hppos : (0 : ℝ) < (p : ℝ) := by linarith
  have hmono : Real.logb 2 ((p : ℝ) - 2) ≤ Real.logb 2 ((p : ℝ) - 1) := by
    rcases eq_or_lt_of_le hp2 with h | h
    · rw [← h]; norm_num
    · exact Real.logb_le_logb_of_le (by norm_num) (by linarith) (by linarith)
  have hcoef : 0 ≤ ((p : ℝ) - 1) * ((p : ℝ) - 2) / (p : ℝ) ^ 2 := by
    apply div_nonneg _ (by positivity)
    rcases eq_or_lt_of_le hp2 with h | h
    · rw [← h]; norm_num
    · nlinarith
  rw [Ipair_prime hp]
  have key : (((p : ℝ) - 1) * ((p : ℝ) - 2) / (p : ℝ) ^ 2) * Real.logb 2 ((p : ℝ) - 2)
      ≤ (((p : ℝ) - 1) * ((p : ℝ) - 2) / (p : ℝ) ^ 2) * Real.logb 2 ((p : ℝ) - 1) :=
    mul_le_mul_of_nonneg_left hmono hcoef
  have hid : Real.logb 2 p
      - (((p : ℝ) - 1) * (2 * (p : ℝ) - 1) / (p : ℝ) ^ 2) * Real.logb 2 ((p : ℝ) - 1)
      + (((p : ℝ) - 1) * ((p : ℝ) - 2) / (p : ℝ) ^ 2) * Real.logb 2 ((p : ℝ) - 1)
      = Real.logb 2 p - Real.logb 2 ((p : ℝ) - 1)
        + Real.logb 2 ((p : ℝ) - 1) / (p : ℝ) ^ 2 := by
    field_simp
    ring
  linarith [key, hid.le, hid.ge]

/-- **Asymptotic silence of the prime-order channel.**  For every odd prime `p`,
`I_pair(p) < 3/(p-1)`: the prime-order type-pair channels carry vanishing information
as `p → ∞`. -/
theorem Ipair_prime_decay (hp : p.Prime) (hodd : p ≠ 2) : Ipair p < 3 / ((p : ℝ) - 1) := by
  have hp3 : (3 : ℝ) ≤ (p : ℝ) := by
    have h3 : 3 ≤ p := by have := hp.two_le; omega
    exact_mod_cast h3
  have hppos : (0 : ℝ) < (p : ℝ) := by linarith
  have hlog2 : (0.6931471803 : ℝ) < Real.log 2 := Real.log_two_gt_d9
  have hlog2pos : (0 : ℝ) < Real.log 2 := by linarith
  have hA : Real.logb 2 p - Real.logb 2 ((p : ℝ) - 1) ≤ (1 / ((p : ℝ) - 1)) / Real.log 2 := by
    have hdiv : Real.log ((p : ℝ) / ((p : ℝ) - 1)) ≤ (p : ℝ) / ((p : ℝ) - 1) - 1 :=
      Real.log_le_sub_one_of_pos (div_pos hppos (by linarith))
    have hsplit : Real.log ((p : ℝ) / ((p : ℝ) - 1)) = Real.log p - Real.log ((p : ℝ) - 1) :=
      Real.log_div (by linarith) (by linarith)
    have hfrac : (p : ℝ) / ((p : ℝ) - 1) - 1 = 1 / ((p : ℝ) - 1) := by
      have hne : ((p : ℝ) - 1) ≠ 0 := by linarith
      field_simp
      ring
    rw [Real.logb, Real.logb, div_sub_div_same]
    rw [hsplit, hfrac] at hdiv
    exact (div_le_div_iff_of_pos_right hlog2pos).2 hdiv
  have hB : Real.logb 2 ((p : ℝ) - 1) / (p : ℝ) ^ 2 ≤ (1 / ((p : ℝ) - 1)) / Real.log 2 := by
    have hl : Real.log ((p : ℝ) - 1) ≤ (p : ℝ) - 2 := by
      have := Real.log_le_sub_one_of_pos (x := (p : ℝ) - 1) (by linarith)
      linarith
    have h1 : Real.logb 2 ((p : ℝ) - 1) / (p : ℝ) ^ 2
        ≤ ((p : ℝ) - 2) / (p : ℝ) ^ 2 / Real.log 2 := by
      rw [Real.logb, div_div, div_div, mul_comm (Real.log 2) ((p : ℝ) ^ 2)]
      exact (div_le_div_iff_of_pos_right (by positivity)).2 hl
    have h2 : ((p : ℝ) - 2) / (p : ℝ) ^ 2 ≤ 1 / ((p : ℝ) - 1) := by
      rw [div_le_div_iff₀ (by positivity) (by linarith)]
      nlinarith
    calc Real.logb 2 ((p : ℝ) - 1) / (p : ℝ) ^ 2
        ≤ ((p : ℝ) - 2) / (p : ℝ) ^ 2 / Real.log 2 := h1
      _ ≤ (1 / ((p : ℝ) - 1)) / Real.log 2 := (div_le_div_iff_of_pos_right hlog2pos).2 h2
  have hle := Ipair_prime_le hp
  have hbound : Ipair p ≤ 2 * ((1 / ((p : ℝ) - 1)) / Real.log 2) := by linarith
  have hfin : 2 * ((1 / ((p : ℝ) - 1)) / Real.log 2) < 3 / ((p : ℝ) - 1) := by
    have hp1 : (0 : ℝ) < (p : ℝ) - 1 := by linarith
    have hrw : 2 * ((1 / ((p : ℝ) - 1)) / Real.log 2)
        = 2 / (((p : ℝ) - 1) * Real.log 2) := by field_simp
    rw [hrw, div_lt_div_iff₀ (by positivity) hp1]
    nlinarith
  linarith

/-- **The sub-cap theorem.**  Every *odd* prime cyclic order stays strictly below the
one-bit binary-fork cap.  Cap-breaking therefore requires a composite cyclic order: it is a
property of the divisor lattice of the Galois group, not of its size. -/
theorem Ipair_prime_lt_one (hp : p.Prime) (hodd : p ≠ 2) : Ipair p < 1 := by
  rcases eq_or_ne p 3 with rfl | h3
  · rw [Ipair_prime (by norm_num)]
    have h := lb3_upper
    norm_num
    linarith
  · have hp5 : (5 : ℝ) ≤ (p : ℝ) := by
      have h5 : 5 ≤ p := by
        have h2 := hp.two_le
        by_contra hlt
        push_neg at hlt
        interval_cases p
        · exact hodd rfl
        · exact h3 rfl
        · norm_num at hp
      exact_mod_cast h5
    have hdecay := Ipair_prime_decay hp hodd
    have h34 : 3 / ((p : ℝ) - 1) ≤ 3 / 4 :=
      div_le_div_of_nonneg_left (by norm_num) (by norm_num) (by linarith)
    linarith

/-- The cap is attained by exactly one prime order, namely `p = 2` (the quadratic fork of
papers 72–74). -/
theorem Ipair_prime_eq_one_iff_two (hp : p.Prime) : Ipair p = 1 ↔ p = 2 := by
  constructor
  · intro h
    by_contra h2
    exact absurd h (ne_of_lt (Ipair_prime_lt_one hp h2))
  · rintro rfl
    rw [Ipair_prime (by norm_num)]
    norm_num

/-! ## CRT structure of the type and additivity of the type entropy -/

/-- **CRT multiplicativity of the splitting type.**  For coprime moduli the type of a
residue is the product of the two component types. -/
theorem typNat_mul_coprime {m n : ℕ} (h : Nat.Coprime m n) (a : ℕ) :
    typNat (m * n) a = typNat m a * typNat n a := by
  have hgcd : Nat.gcd (m * n) a = Nat.gcd m a * Nat.gcd n a := Nat.Coprime.mul_gcd h a
  rw [typNat, typNat, typNat, hgcd,
    Nat.div_mul_div_comm (Nat.gcd_dvd_left m a) (Nat.gcd_dvd_left n a)]

/-- The splitting type of a composite modulus is the lcm of its coprime component types. -/
theorem typNat_lcm {m n : ℕ} (h : Nat.Coprime m n) (a : ℕ) :
    typNat (m * n) a = Nat.lcm (typNat m a) (typNat n a) := by
  have hdm : typNat m a ∣ m := typNat_dvd m a
  have hdn : typNat n a ∣ n := typNat_dvd n a
  have hcop : Nat.Coprime (typNat m a) (typNat n a) :=
    Nat.Coprime.coprime_dvd_left hdm (Nat.Coprime.coprime_dvd_right hdn h)
  rw [typNat_mul_coprime h a, Nat.Coprime.lcm_eq_mul hcop]

/-- Divisor sums over a coprime product split as a double sum. -/
theorem sum_divisors_mul_coprime {M : Type*} [AddCommMonoid M] {m n : ℕ}
    (hm : 0 < m) (hn : 0 < n) (h : Nat.Coprime m n) (f : ℕ → M) :
    ∑ d ∈ (m * n).divisors, f d = ∑ i ∈ m.divisors, ∑ j ∈ n.divisors, f (i * j) := by
  rw [← Finset.sum_product']
  refine Finset.sum_nbij' (i := fun d => (Nat.gcd d m, Nat.gcd d n)) (j := fun q => q.1 * q.2)
    ?_ ?_ ?_ ?_ ?_
  · intro a _
    simp only [Finset.mem_product, Nat.mem_divisors]
    exact ⟨⟨Nat.gcd_dvd_right a m, hm.ne'⟩, ⟨Nat.gcd_dvd_right a n, hn.ne'⟩⟩
  · rintro ⟨i, j⟩ hij
    simp only [Finset.mem_product, Nat.mem_divisors] at hij
    rw [Nat.mem_divisors]
    exact ⟨Nat.mul_dvd_mul hij.1.1 hij.2.1, by positivity⟩
  · intro a ha
    rw [Nat.mem_divisors] at ha
    have hgcd : Nat.gcd (m * n) a = Nat.gcd m a * Nat.gcd n a := Nat.Coprime.mul_gcd h a
    have hfull : Nat.gcd (m * n) a = a := Nat.gcd_eq_right ha.1
    show Nat.gcd a m * Nat.gcd a n = a
    rw [Nat.gcd_comm a m, Nat.gcd_comm a n, ← hgcd, hfull]
  · rintro ⟨i, j⟩ hij
    simp only [Finset.mem_product, Nat.mem_divisors] at hij
    obtain ⟨⟨hi, -⟩, ⟨hj, -⟩⟩ := hij
    have hij_cop : Nat.Coprime i j :=
      Nat.Coprime.coprime_dvd_left hi (Nat.Coprime.coprime_dvd_right hj h)
    have hjm : Nat.gcd j m = 1 := Nat.Coprime.coprime_dvd_left hj h.symm
    have him : Nat.gcd i m = i := Nat.gcd_eq_left hi
    have hin : Nat.gcd i n = 1 := Nat.Coprime.coprime_dvd_left hi h
    have hjn : Nat.gcd j n = j := Nat.gcd_eq_left hj
    have h1 : Nat.gcd (i * j) m = i := by rw [Nat.Coprime.mul_gcd hij_cop m, him, hjm, mul_one]
    have h2 : Nat.gcd (i * j) n = j := by rw [Nat.Coprime.mul_gcd hij_cop n, hin, hjn, one_mul]
    simp [h1, h2]
  · intro a ha
    rw [Nat.mem_divisors] at ha
    have hgcd : Nat.gcd (m * n) a = Nat.gcd m a * Nat.gcd n a := Nat.Coprime.mul_gcd h a
    have hfull : Nat.gcd (m * n) a = a := Nat.gcd_eq_right ha.1
    have hprod : Nat.gcd a m * Nat.gcd a n = a := by
      rw [Nat.gcd_comm a m, Nat.gcd_comm a n, ← hgcd, hfull]
    simp only [hprod]

/-- **Exact additivity of the type entropy over coprime factorisations.**  The Euler-φ type
law of a cyclic order factors through the CRT decomposition, so the splitting-type entropy is
additive: `H(T)(mn) = H(T)(m) + H(T)(n)` whenever `gcd (m, n) = 1`.  This is the single-prime
counterpart of the CRT-additivity instances `Ipair_crt_twelve`, `Ipair_crt_ten`, … of
`Catalog.Computation.CyclicTypeChannelLaws`. -/
theorem HT_mul_coprime {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (h : Nat.Coprime m n) :
    HT (m * n) = HT m + HT n := by
  have hmn : 0 < m * n := Nat.mul_pos hm hn
  have hmR : (0 : ℝ) < m := by exact_mod_cast hm
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  have htotm : ∑ i ∈ m.divisors, ((Nat.totient i : ℝ)) = (m : ℝ) := by
    rw [← Nat.cast_sum, Nat.sum_totient]
  have htotn : ∑ j ∈ n.divisors, ((Nat.totient j : ℝ)) = (n : ℝ) := by
    rw [← Nat.cast_sum, Nat.sum_totient]
  rw [HT_divisor_formula hmn, HT_divisor_formula hm, HT_divisor_formula hn]
  rw [sum_divisors_mul_coprime hm hn h
    (fun d => (Nat.totient d : ℝ) * Real.logb 2 (Nat.totient d))]
  have key : ∀ i ∈ m.divisors, ∀ j ∈ n.divisors,
      ((Nat.totient (i * j) : ℝ) * Real.logb 2 (Nat.totient (i * j)))
        = (Nat.totient i : ℝ) * (Nat.totient j : ℝ) * Real.logb 2 (Nat.totient i)
          + (Nat.totient i : ℝ) * (Nat.totient j : ℝ) * Real.logb 2 (Nat.totient j) := by
    intro i hi j hj
    rw [Nat.mem_divisors] at hi hj
    have hipos : 0 < i := Nat.pos_of_dvd_of_pos hi.1 hm
    have hjpos : 0 < j := Nat.pos_of_dvd_of_pos hj.1 hn
    have hcop : Nat.Coprime i j :=
      Nat.Coprime.coprime_dvd_left hi.1 (Nat.Coprime.coprime_dvd_right hj.1 h)
    have hti : (0 : ℝ) < (Nat.totient i : ℝ) := by exact_mod_cast Nat.totient_pos.2 hipos
    have htj : (0 : ℝ) < (Nat.totient j : ℝ) := by exact_mod_cast Nat.totient_pos.2 hjpos
    rw [Nat.totient_mul hcop]
    push_cast
    rw [Real.logb_mul (ne_of_gt hti) (ne_of_gt htj)]
    ring
  rw [Finset.sum_congr rfl (fun i hi => Finset.sum_congr rfl (fun j hj => key i hi j hj))]
  have hsplit : ∀ i ∈ m.divisors,
      ∑ j ∈ n.divisors, ((Nat.totient i : ℝ) * (Nat.totient j : ℝ) * Real.logb 2 (Nat.totient i)
        + (Nat.totient i : ℝ) * (Nat.totient j : ℝ) * Real.logb 2 (Nat.totient j))
      = (Nat.totient i : ℝ) * Real.logb 2 (Nat.totient i) * (n : ℝ)
        + (Nat.totient i : ℝ)
          * ∑ j ∈ n.divisors, (Nat.totient j : ℝ) * Real.logb 2 (Nat.totient j) := by
    intro i _
    rw [Finset.sum_add_distrib]
    congr 1
    · calc ∑ j ∈ n.divisors,
            (Nat.totient i : ℝ) * (Nat.totient j : ℝ) * Real.logb 2 (Nat.totient i)
          = ((Nat.totient i : ℝ) * Real.logb 2 (Nat.totient i))
              * ∑ j ∈ n.divisors, (Nat.totient j : ℝ) := by
            rw [Finset.mul_sum]
            exact Finset.sum_congr rfl (fun j _ => by ring)
        _ = (Nat.totient i : ℝ) * Real.logb 2 (Nat.totient i) * (n : ℝ) := by rw [htotn]
    · rw [Finset.mul_sum]
      exact Finset.sum_congr rfl (fun j _ => by ring)
  rw [Finset.sum_congr rfl hsplit, Finset.sum_add_distrib]
  have hA : ∑ i ∈ m.divisors, (Nat.totient i : ℝ) * Real.logb 2 (Nat.totient i) * (n : ℝ)
      = (∑ i ∈ m.divisors, (Nat.totient i : ℝ) * Real.logb 2 (Nat.totient i)) * (n : ℝ) := by
    rw [Finset.sum_mul]
  have hB : ∑ i ∈ m.divisors, ((Nat.totient i : ℝ)
        * ∑ j ∈ n.divisors, (Nat.totient j : ℝ) * Real.logb 2 (Nat.totient j))
      = (m : ℝ) * ∑ j ∈ n.divisors, (Nat.totient j : ℝ) * Real.logb 2 (Nat.totient j) := by
    rw [← Finset.sum_mul, htotm]
  rw [hA, hB]
  have hlog : Real.logb 2 ((m * n : ℕ) : ℝ) = Real.logb 2 m + Real.logb 2 n := by
    push_cast
    rw [Real.logb_mul (ne_of_gt hmR) (ne_of_gt hnR)]
  rw [hlog]
  push_cast
  field_simp
  ring

end CyclicType