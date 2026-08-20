/-
# Periodicity of `q`-integers modulo `ℓ`, and the block factorisation of the `q`-factorial

Fix `q ≥ 2` and a prime `ℓ ∤ q`, and let `d` be the period supplied by `IsQRegular`
(the multiplicative order of `q` modulo `ℓ`, for odd `ℓ`).  Two structural facts drive every
*congruence* — as opposed to valuation — statement about Gaussian binomial coefficients:

* `QKummer.qNat_mul_eq` : `[d j]_q = [d]_q * S_j` with `S_j = 1 + q^d + ⋯ + q^{d(j-1)}`, so the
  `q`-integers indexed by multiples of `d` all carry the factor `[d]_q`;
* `QKummer.qNat_cast_mod` : modulo `ℓ`, `[m]_q` depends only on `m % d`.

Together with the *exact* splitting of the `q`-factorial into its `d`-free part and its blocks
(`QKummer.qFact_eq_qFactRed_mul_blocks`), and the congruences
`QKummer.qFactRed_cast` and `QKummer.qShiftProd_cast`, these are the ingredients of the
`q`-analogue of Lucas' theorem in `Catalog/NumberTheory/QKummer/Lucas.lean`.
-/
import Catalog.NumberTheory.QKummer.Valuation

namespace QKummer

open Finset

/-- The cofactor `S_j = 1 + q^d + ⋯ + q^{d(j-1)}` in `[d j]_q = [d]_q S_j`. -/
def qShift (q d j : ℕ) : ℕ := ∑ t ∈ Finset.range j, q ^ (d * t)

/-- The `d`-free part of the `q`-factorial: the product of `[m]_q` over `m ≤ n` with `d ∤ m`. -/
def qFactRed (q d : ℕ) : ℕ → ℕ
  | 0 => 1
  | (n + 1) => (if d ∣ (n + 1) then 1 else qNat q (n + 1)) * qFactRed q d n

/-- The block part of the `q`-factorial: the product of `[d j]_q` for `1 ≤ j ≤ M`. -/
def qBlockProd (q d M : ℕ) : ℕ := ∏ j ∈ Finset.Icc 1 M, qNat q (d * j)

@[simp] theorem qShift_zero (q d : ℕ) : qShift q d 0 = 0 := by simp [qShift]

theorem qShift_succ (q d j : ℕ) : qShift q d (j + 1) = qShift q d j + q ^ (d * j) := by
  simp [qShift, Finset.sum_range_succ]

/-- `[d j]_q = [d]_q * S_j`. -/
theorem qNat_mul_eq (q d j : ℕ) : qNat q (d * j) = qNat q d * qShift q d j := by
  induction j with
  | zero => simp
  | succ j ih =>
      have h : d * (j + 1) = d * j + d := by ring
      rw [h, qNat_add, ih, qShift_succ, Nat.mul_add]
      ring

theorem qFactRed_succ (q d n : ℕ) :
    qFactRed q d (n + 1) = (if d ∣ (n + 1) then 1 else qNat q (n + 1)) * qFactRed q d n := rfl

theorem qFactRed_pos (q d n : ℕ) : 0 < qFactRed q d n := by
  induction n with
  | zero => simp [qFactRed]
  | succ n ih =>
      rw [qFactRed_succ]
      split
      · simpa using ih
      · exact Nat.mul_pos (qNat_pos q (Nat.succ_pos n)) ih

theorem qBlockProd_pos {q d : ℕ} (hd : 0 < d) (M : ℕ) : 0 < qBlockProd q d M :=
  Finset.prod_pos fun j hj => qNat_pos q (Nat.mul_pos hd (by simpa using (Finset.mem_Icc.mp hj).1))

/-- **Exact block factorisation of the `q`-factorial**:
`[n]_q! = (d-free part) * ∏_{j ≤ ⌊n/d⌋} [d j]_q`. -/
theorem qFact_eq_qFactRed_mul_blocks (q d n : ℕ) :
    qFact q n = qFactRed q d n * qBlockProd q d (n / d) := by
  induction n with
  | zero => simp [qFactRed, qBlockProd]
  | succ n ih =>
      rw [qFact_succ, ih, qFactRed_succ]
      by_cases hdvd : d ∣ (n + 1)
      · have hstep : (n + 1) / d = n / d + 1 := by
          rw [Nat.succ_div]
          simp [hdvd]
        have hlast : d * ((n + 1) / d) = n + 1 := by
          rw [Nat.mul_div_cancel' hdvd]
        rw [if_pos hdvd, hstep, qBlockProd, qBlockProd,
          Finset.prod_Icc_succ_top (Nat.succ_le_succ (Nat.zero_le (n / d)))]
        rw [hstep] at hlast
        rw [hlast]
        ring
      · have hstep : (n + 1) / d = n / d := by
          rw [Nat.succ_div]
          simp [hdvd]
        rw [if_neg hdvd, hstep]
        ring

/-- The block product is `[d]_q^M` times the product of the shifts. -/
theorem qBlockProd_eq (q d M : ℕ) :
    qBlockProd q d M = qNat q d ^ M * ∏ j ∈ Finset.Icc 1 M, qShift q d j := by
  unfold qBlockProd
  rw [Finset.prod_congr rfl (fun j _ => qNat_mul_eq q d j), Finset.prod_mul_distrib,
    Finset.prod_const, Nat.card_Icc]
  simp

section Cast

variable {q ℓ d : ℕ}

/-- Modulo `ℓ`, the shift `S_j` is just `j`. -/
theorem qShift_cast (hq : ((q : ℕ) : ZMod ℓ) ^ d = 1) (j : ℕ) :
    ((qShift q d j : ℕ) : ZMod ℓ) = (j : ZMod ℓ) := by
  induction j with
  | zero => simp
  | succ j ih =>
      have hpow : ((q : ℕ) : ZMod ℓ) ^ (d * j) = 1 := by
        rw [pow_mul, hq, one_pow]
      rw [qShift_succ]
      push_cast
      rw [ih, hpow]

/-- Modulo `ℓ`, the product of the shifts is a factorial. -/
theorem qShiftProd_cast (hq : ((q : ℕ) : ZMod ℓ) ^ d = 1) (M : ℕ) :
    (((∏ j ∈ Finset.Icc 1 M, qShift q d j : ℕ)) : ZMod ℓ) = (M.factorial : ZMod ℓ) := by
  induction M with
  | zero => simp
  | succ M ih =>
      rw [Finset.prod_Icc_succ_top (by omega : 1 ≤ M + 1)]
      push_cast
      push_cast at ih
      rw [ih, qShift_cast hq]
      rw [Nat.factorial_succ]
      push_cast
      ring

/-- **Periodicity of `q`-integers modulo `ℓ`.**  If `ℓ ∣ [d]_q` and `q^d ≡ 1 (mod ℓ)`, then
`[m]_q ≡ [m % d]_q (mod ℓ)` for every `m`. -/
theorem qNat_cast_mod (h0 : ((qNat q d : ℕ) : ZMod ℓ) = 0)
    (hq : ((q : ℕ) : ZMod ℓ) ^ d = 1) (m : ℕ) :
    ((qNat q m : ℕ) : ZMod ℓ) = ((qNat q (m % d) : ℕ) : ZMod ℓ) := by
  conv_lhs => rw [← Nat.div_add_mod m d, qNat_add]
  push_cast
  rw [qNat_mul_eq]
  push_cast
  rw [h0, pow_mul, hq, one_pow]
  ring

/-- **The `d`-free part of the `q`-factorial, modulo `ℓ`.**  It is `[d-1]_q!` to the power
`⌊n/d⌋` times `[n % d]_q!`. -/
theorem qFactRed_cast (hd : 0 < d) (h0 : ((qNat q d : ℕ) : ZMod ℓ) = 0)
    (hq : ((q : ℕ) : ZMod ℓ) ^ d = 1) (n : ℕ) :
    ((qFactRed q d n : ℕ) : ZMod ℓ)
      = ((qFact q (d - 1) : ℕ) : ZMod ℓ) ^ (n / d) * ((qFact q (n % d) : ℕ) : ZMod ℓ) := by
  induction n with
  | zero => simp [qFactRed]
  | succ n ih =>
      rw [qFactRed_succ]
      by_cases hdvd : d ∣ (n + 1)
      · obtain ⟨t, ht⟩ := hdvd
        have ht1 : 1 ≤ t := by
          rcases Nat.eq_zero_or_pos t with rfl | h
          · omega
          · exact h
        have hstep : (n + 1) / d = n / d + 1 := by
          rw [Nat.succ_div]
          simp [Dvd.intro t ht.symm]
        have hmod0 : (n + 1) % d = 0 := by
          rw [ht, Nat.mul_mod_right]
        have hnmod : n % d = d - 1 := by
          have hrw : n = (d - 1) + d * (t - 1) := by
            have : d * t = d * (t - 1) + d := by
              cases t with
              | zero => omega
              | succ s => simp [Nat.mul_succ]
            omega
          rw [hrw, Nat.add_mul_mod_self_left, Nat.mod_eq_of_lt (by omega)]
        rw [if_pos ⟨t, ht⟩, one_mul, hstep, hmod0, ih, hnmod, qFact_zero]
        push_cast
        ring
      · have hd2 : 2 ≤ d := by
          rcases Nat.lt_or_ge d 2 with h | h
          · exfalso
            have hd1 : d = 1 := by omega
            exact hdvd (by rw [hd1]; exact one_dvd _)
          · exact h
        have hstep : (n + 1) / d = n / d := by
          rw [Nat.succ_div]
          simp [hdvd]
        have hlt : n % d < d := Nat.mod_lt _ hd
        have hne : n % d + 1 ≠ d := by
          intro h
          refine hdvd ⟨n / d + 1, ?_⟩
          have hdm := Nat.div_add_mod n d
          have hexp : d * (n / d + 1) = d * (n / d) + d := by ring
          omega
        have hmod : (n + 1) % d = n % d + 1 := by
          conv_lhs => rw [← Nat.div_add_mod n d]
          have hrw : d * (n / d) + n % d + 1 = (n % d + 1) + d * (n / d) := by ring
          rw [hrw, Nat.add_mul_mod_self_left, Nat.mod_eq_of_lt (by omega)]
        rw [if_neg hdvd, hstep, hmod]
        push_cast
        rw [ih, qNat_cast_mod h0 hq (n + 1), hmod, qFact_succ]
        push_cast
        ring

end Cast

end QKummer