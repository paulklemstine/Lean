/-
# The companion divisibility law on the Pell spine

`Novelty.PellSpineDivisibility` shows that the Pell numbers `P` form a strong divisibility
sequence while the half-companion sequence `Q` does **not** (`gcd (Q 3) (Q 6) = 1`).  That
refutation leaves the real question open: *exactly when* does `Q m` divide `Q n`?

This file answers it completely.  For every `m ≥ 2`,

`Q m ∣ Q n  ↔  n = m * k for some odd k`,

a parity-graded divisibility law with no analogue among the `P`'s.  The proof runs in two
independent halves:

* **index step** — `Q m ∣ P (2m)` and `Q n ∣ P (2n)` push the hypothesis into the strong
  divisibility law for `P`, forcing `Q m ∣ P (2 gcd(m,n))`; if `gcd(m,n) < m` the divisor
  exceeds the dividend, so `m ∣ n`;
* **parity step** — modulo `Q m` the companion sequence satisfies the two-step recursion
  `Q (a + 2m) ≡ 2 P m ^ 2 * Q a`, so `Q (2jm) ≡ (2 P m ^ 2) ^ j`, a unit mod `Q m`
  because `Q m` is odd and coprime to `P m`.  Even multiples are therefore ruled out.

## Proved

* `pellQ_odd`, `pellQ_coprime_two_pellP_sq` — the arithmetic units used by the parity step;
* `pellQ_add_two_mul_modEq` — `Q (a + 2m) ≡ 2 P m ^ 2 * Q a [MOD Q m]`;
* `pellQ_even_multiple_modEq` — `Q (2jm) ≡ (2 P m ^ 2) ^ j [MOD Q m]`;
* `pellQ_coprime_even_multiple` — `gcd (Q m) (Q (2jm)) = 1`;
* `pellQ_dvd_index_dvd` — `Q m ∣ Q n → m ∣ n` for `m ≥ 2`;
* `pellQ_dvd_iff` — **the companion divisibility law**;
* `pellQ_gcd_dvd`, `pellQ_gcd_eq_one_of_even_quotient`, `pellQ_gcd_law` — **the companion
  gcd law**: `gcd (Q m) (Q n) = Q (gcd m n)` when both index quotients are odd, and `1`
  otherwise, with no side condition on `m` and `n`;
* `pellQ_gcd_of_odd_quotients` — the graded gcd statement that survives the refutation;
* summation identities `pellQ_sum`, `pellP_sum`, `pellP_sq_sum` tying the two strands
  of the spine together.

## Refuted

* `not_pellQ_dvd_all_multiples` — `Q n ∣ Q (kn)` fails for even `k`: `Q 2 = 3 ∤ 17 = Q 4`;
* `not_pellQ_dvd_iff_index_dvd` — divisibility of indices is **not** sufficient, by the
  same pair, so the parity grading in `pellQ_dvd_iff` cannot be dropped.
-/
import Novelty.PellSpineCore
import Novelty.PellSpineDivisibility

namespace Catalog.Novelty.PellSpine

open Finset

/-! ## Arithmetic units modulo `Q m` -/

/-- Every half-companion Pell number is odd. -/
theorem pellQ_odd (n : ℕ) : Odd (pellQ n) := by
  induction n with
  | zero => exact ⟨0, by norm_num [pellQ]⟩
  | succ k ih =>
      obtain ⟨t, ht⟩ := ih
      exact ⟨t + pellP k, by rw [pellQ_succ, ht]; ring⟩

/-- `Q m` is coprime to `2 * P m ^ 2`: it is odd, and coprime to `P m`. -/
theorem pellQ_coprime_two_pellP_sq (m : ℕ) :
    Nat.Coprime (pellQ m) (2 * pellP m ^ 2) := by
  have h2 : Nat.Coprime (pellQ m) 2 := by
    have hnd : ¬ (2 ∣ pellQ m) := by
      simpa [Nat.two_dvd_ne_zero, Nat.odd_iff] using (Nat.odd_iff.mp (pellQ_odd m))
    exact ((Nat.Prime.coprime_iff_not_dvd Nat.prime_two).mpr hnd).symm
  have hp : Nat.Coprime (pellQ m) (pellP m) :=
    (Nat.coprime_comm.mp (pellP_coprime_pellQ m))
  exact Nat.Coprime.mul_right h2 (hp.pow_right 2)

/-! ## The parity step -/

/-- Modulo `Q m`, shifting the index by `2m` multiplies the companion value by `2 P m ^ 2`. -/
theorem pellQ_add_two_mul_modEq (m a : ℕ) :
    pellQ (a + 2 * m) ≡ 2 * pellP m ^ 2 * pellQ a [MOD pellQ m] := by
  have hsplit : pellQ (a + 2 * m)
      = pellQ a * pellQ (2 * m) + 2 * (pellP a * pellP (2 * m)) := pellQ_add a (2 * m)
  have hP : pellQ m ∣ pellP (2 * m) := pellQ_dvd_pellP_two_mul m
  have hQ : pellQ (2 * m) ≡ 2 * pellP m ^ 2 [MOD pellQ m] := by
    have : pellQ (2 * m) = pellQ m ^ 2 + 2 * pellP m ^ 2 := pellQ_two_mul m
    rw [this]
    have hsq : pellQ m ^ 2 ≡ 0 [MOD pellQ m] :=
      (Nat.modEq_zero_iff_dvd).mpr (dvd_pow_self _ (by norm_num))
    calc pellQ m ^ 2 + 2 * pellP m ^ 2
        ≡ 0 + 2 * pellP m ^ 2 [MOD pellQ m] := hsq.add_right _
      _ = 2 * pellP m ^ 2 := Nat.zero_add _
  have hzero : 2 * (pellP a * pellP (2 * m)) ≡ 0 [MOD pellQ m] :=
    (Nat.modEq_zero_iff_dvd).mpr (Dvd.dvd.mul_left (hP.mul_left _) 2)
  calc pellQ (a + 2 * m)
      = pellQ a * pellQ (2 * m) + 2 * (pellP a * pellP (2 * m)) := hsplit
    _ ≡ pellQ a * (2 * pellP m ^ 2) + 0 [MOD pellQ m] :=
        Nat.ModEq.add (hQ.mul_left _) hzero
    _ = 2 * pellP m ^ 2 * pellQ a := by ring

/-- Iterating the parity step: `Q (2jm) ≡ (2 P m ^ 2) ^ j` modulo `Q m`. -/
theorem pellQ_even_multiple_modEq (m j : ℕ) :
    pellQ (2 * j * m) ≡ (2 * pellP m ^ 2) ^ j [MOD pellQ m] := by
  induction j with
  | zero =>
      simp only [Nat.mul_zero, Nat.zero_mul, pow_zero]
      rfl
  | succ i ih =>
      have hidx : 2 * (i + 1) * m = 2 * i * m + 2 * m := by ring
      calc pellQ (2 * (i + 1) * m)
          = pellQ (2 * i * m + 2 * m) := by rw [hidx]
        _ ≡ 2 * pellP m ^ 2 * pellQ (2 * i * m) [MOD pellQ m] :=
            pellQ_add_two_mul_modEq m _
        _ ≡ 2 * pellP m ^ 2 * (2 * pellP m ^ 2) ^ i [MOD pellQ m] := ih.mul_left _
        _ = (2 * pellP m ^ 2) ^ (i + 1) := by ring

/-- `Q m` is coprime to every companion value at an even multiple of `m`. -/
theorem pellQ_coprime_even_multiple (m j : ℕ) :
    Nat.Coprime (pellQ m) (pellQ (2 * j * m)) := by
  have hmod := pellQ_even_multiple_modEq m j
  have hcop : Nat.Coprime (pellQ m) ((2 * pellP m ^ 2) ^ j) :=
    (pellQ_coprime_two_pellP_sq m).pow_right j
  have hgcd : Nat.gcd (pellQ m) (pellQ (2 * j * m))
      = Nat.gcd (pellQ m) ((2 * pellP m ^ 2) ^ j) := by
    rw [Nat.gcd_comm (pellQ m) (pellQ (2 * j * m)),
      Nat.gcd_comm (pellQ m) ((2 * pellP m ^ 2) ^ j)]
    exact Nat.ModEq.gcd_eq hmod
  exact hgcd.trans hcop

/-! ## The index step -/

/-- For `m ≥ 2` the companion value strictly dominates the Pell value. -/
theorem pellP_lt_pellQ {m : ℕ} (hm : 2 ≤ m) : pellP m < pellQ m := by
  obtain ⟨k, rfl⟩ : ∃ k, m = k + 1 := ⟨m - 1, by omega⟩
  have hk : 1 ≤ k := by omega
  have h := pellQ_succ_eq_add k
  have : 0 < pellP k := pellP_pos hk
  omega

/-- `3 ≤ Q m` whenever `2 ≤ m`. -/
theorem three_le_pellQ {m : ℕ} (hm : 2 ≤ m) : 3 ≤ pellQ m := by
  have h1 : pellP m < pellQ m := pellP_lt_pellQ hm
  have h2 : 2 ≤ pellP m := two_le_pellP hm
  omega

/-- If `Q m` divides `Q n` (with `m ≥ 2`) then `m` divides `n`. -/
theorem pellQ_dvd_index_dvd {m n : ℕ} (hm : 2 ≤ m) (h : pellQ m ∣ pellQ n) : m ∣ n := by
  set g := Nat.gcd m n with hg
  have hdvd2m : pellQ m ∣ pellP (2 * m) := pellQ_dvd_pellP_two_mul m
  have hdvd2n : pellQ m ∣ pellP (2 * n) := h.trans (pellQ_dvd_pellP_two_mul n)
  have hgcd : pellQ m ∣ pellP (2 * g) := by
    have : pellQ m ∣ Nat.gcd (pellP (2 * m)) (pellP (2 * n)) := Nat.dvd_gcd hdvd2m hdvd2n
    rwa [pellP_gcd, show Nat.gcd (2 * m) (2 * n) = 2 * g by rw [hg, Nat.gcd_mul_left]] at this
  have hgm : g ∣ m := Nat.gcd_dvd_left m n
  rcases Nat.lt_or_ge g m with hlt | hge
  · exfalso
    have h2g : 2 * g ≤ m := by
      obtain ⟨c, hc⟩ := hgm
      have hg0 : 0 < g := by
        rcases Nat.eq_zero_or_pos g with h0 | h0
        · exfalso
          have : m = 0 := Nat.eq_zero_of_gcd_eq_zero_left (hg ▸ h0)
          omega
        · exact h0
      have hc2 : 2 ≤ c := by
        rcases Nat.lt_or_ge c 2 with hc1 | hc2
        · interval_cases c <;> omega
        · exact hc2
      calc 2 * g ≤ c * g := Nat.mul_le_mul_right g hc2
        _ = m := by rw [hc, Nat.mul_comm]
    have hpos : 0 < pellP (2 * g) := by
      have hg0 : 0 < g := by
        rcases Nat.eq_zero_or_pos g with h0 | h0
        · exfalso
          have : m = 0 := Nat.eq_zero_of_gcd_eq_zero_left (hg ▸ h0)
          omega
        · exact h0
      exact pellP_pos (by omega)
    have hle : pellP (2 * g) ≤ pellP m := pellP_strictMono.monotone h2g
    have hlt' : pellP m < pellQ m := pellP_lt_pellQ hm
    have := Nat.le_of_dvd hpos hgcd
    omega
  · have : g = m := le_antisymm (Nat.le_of_dvd (by omega) hgm) hge
    exact this ▸ Nat.gcd_dvd_right m n

/-! ## The companion divisibility law -/

/-- **The companion divisibility law.**  For `m ≥ 2`, `Q m ∣ Q n` exactly when `n` is an
*odd* multiple of `m`.  The parity grading is essential: `Q 2 = 3` divides `Q 6 = 99` but
not `Q 4 = 17`. -/
theorem pellQ_dvd_iff {m : ℕ} (hm : 2 ≤ m) (n : ℕ) :
    pellQ m ∣ pellQ n ↔ ∃ k, Odd k ∧ n = m * k := by
  constructor
  · intro h
    obtain ⟨k, rfl⟩ := pellQ_dvd_index_dvd hm h
    refine ⟨k, ?_, rfl⟩
    rcases Nat.even_or_odd k with he | ho
    · exfalso
      obtain ⟨j, hj⟩ := he
      have hidx : m * k = 2 * j * m := by subst hj; ring
      have hcop : Nat.Coprime (pellQ m) (pellQ (m * k)) := by
        rw [hidx]; exact pellQ_coprime_even_multiple m j
      have hone : pellQ m ∣ 1 := by
        have : pellQ m ∣ Nat.gcd (pellQ m) (pellQ (m * k)) := Nat.dvd_gcd dvd_rfl h
        rwa [hcop] at this
      have h1 : pellQ m = 1 := Nat.eq_one_of_dvd_one hone
      have := three_le_pellQ hm
      omega
    · exact ho
  · rintro ⟨k, ⟨j, rfl⟩, rfl⟩
    have : m * (2 * j + 1) = (2 * j + 1) * m := Nat.mul_comm _ _
    rw [this]
    exact pellQ_dvd_odd_multiple m j

/-- The graded gcd statement that survives `not_pellQ_strong_divisibility`: whenever both
quotients are odd, `Q (gcd m n)` divides `gcd (Q m) (Q n)`. -/
theorem pellQ_gcd_of_odd_quotients {m n g : ℕ} (hg : g = Nat.gcd m n)
    (ha : Odd (m / g)) (hb : Odd (n / g)) :
    pellQ g ∣ Nat.gcd (pellQ m) (pellQ n) := by
  obtain ⟨a, ha'⟩ := ha
  obtain ⟨b, hb'⟩ := hb
  have hm : m = (2 * a + 1) * g := by
    have : g ∣ m := hg ▸ Nat.gcd_dvd_left m n
    rw [← Nat.div_mul_cancel this, ha']
  have hn : n = (2 * b + 1) * g := by
    have : g ∣ n := hg ▸ Nat.gcd_dvd_right m n
    rw [← Nat.div_mul_cancel this, hb']
  exact Nat.dvd_gcd (hm ▸ pellQ_dvd_odd_multiple g a) (hn ▸ pellQ_dvd_odd_multiple g b)

/-- Every divisor of a companion value is odd, hence coprime to `2`. -/
theorem coprime_two_of_dvd_pellQ {d m : ℕ} (h : d ∣ pellQ m) : Nat.Coprime d 2 := by
  have hnd : ¬ (2 ∣ d) := by
    intro h2
    have : (2 : ℕ) ∣ pellQ m := h2.trans h
    have := Nat.odd_iff.mp (pellQ_odd m)
    omega
  exact ((Nat.Prime.coprime_iff_not_dvd Nat.prime_two).mpr hnd).symm

/-- **Half of the companion gcd law.**  The gcd of two companion values always divides the
companion value at the gcd of the indices — the inclusion that survives the failure of
strong divisibility. -/
theorem pellQ_gcd_dvd (m n : ℕ) :
    Nat.gcd (pellQ m) (pellQ n) ∣ pellQ (Nat.gcd m n) := by
  set g := Nat.gcd m n with hg
  set d := Nat.gcd (pellQ m) (pellQ n) with hd
  have hdm : d ∣ pellQ m := Nat.gcd_dvd_left _ _
  have hdn : d ∣ pellQ n := Nat.gcd_dvd_right _ _
  have h2g : d ∣ pellP (2 * g) := by
    have h1 : d ∣ pellP (2 * m) := hdm.trans (pellQ_dvd_pellP_two_mul m)
    have h2 : d ∣ pellP (2 * n) := hdn.trans (pellQ_dvd_pellP_two_mul n)
    have : d ∣ Nat.gcd (pellP (2 * m)) (pellP (2 * n)) := Nat.dvd_gcd h1 h2
    rwa [pellP_gcd, show Nat.gcd (2 * m) (2 * n) = 2 * g by rw [hg, Nat.gcd_mul_left]] at this
  have hprod : d ∣ pellP g * pellQ g := by
    have hform : pellP (2 * g) = 2 * (pellP g * pellQ g) := pellP_two_mul g
    exact (coprime_two_of_dvd_pellQ hdm).dvd_of_dvd_mul_left (by rwa [hform] at h2g)
  have hcopP : Nat.Coprime d (pellP g) := by
    have hPg : pellP g ∣ pellP m := (pellP_dvd_iff g m).mp (hg ▸ Nat.gcd_dvd_left m n)
    have hcm : Nat.Coprime (pellP m) (pellQ m) := pellP_coprime_pellQ m
    exact (Nat.Coprime.coprime_dvd_right hdm (Nat.Coprime.coprime_dvd_left hPg hcm)).symm
  exact hcopP.dvd_of_dvd_mul_left hprod

/-- If one of the two index quotients is even, the companion values are coprime. -/
theorem pellQ_gcd_eq_one_of_even_quotient {m n : ℕ} (heven : Even (m / Nat.gcd m n)) :
    Nat.gcd (pellQ m) (pellQ n) = 1 := by
  set g := Nat.gcd m n with hg
  obtain ⟨a, ha⟩ := heven
  have hm : m = 2 * a * g := by
    have hdvd : g ∣ m := hg ▸ Nat.gcd_dvd_left m n
    have : m / g = 2 * a := by omega
    rw [← Nat.div_mul_cancel hdvd, this]
  have h1 : Nat.gcd (pellQ m) (pellQ n) ∣ pellQ g := pellQ_gcd_dvd m n
  have h2 : Nat.gcd (pellQ m) (pellQ n) ∣ pellQ (2 * a * g) := hm ▸ Nat.gcd_dvd_left _ _
  have := Nat.dvd_gcd h1 h2
  rwa [pellQ_coprime_even_multiple g a, Nat.dvd_one] at this

/-- **The companion gcd law.**  When both index quotients are odd the gcd is exactly the
companion value at `gcd m n`; otherwise it is `1`.  This is the repaired form of the
strong divisibility property that `not_pellQ_strong_divisibility` refutes. -/
theorem pellQ_gcd_law (m n : ℕ) :
    Nat.gcd (pellQ m) (pellQ n)
      = if Odd (m / Nat.gcd m n) ∧ Odd (n / Nat.gcd m n) then pellQ (Nat.gcd m n) else 1 := by
  by_cases hodd : Odd (m / Nat.gcd m n) ∧ Odd (n / Nat.gcd m n)
  · rw [if_pos hodd]
    exact Nat.dvd_antisymm (pellQ_gcd_dvd m n)
      (pellQ_gcd_of_odd_quotients rfl hodd.1 hodd.2)
  · rw [if_neg hodd]
    rcases not_and_or.mp hodd with h | h
    · exact pellQ_gcd_eq_one_of_even_quotient (Nat.not_odd_iff_even.mp h)
    · rw [Nat.gcd_comm]
      have hcomm : Nat.gcd n m = Nat.gcd m n := Nat.gcd_comm n m
      exact pellQ_gcd_eq_one_of_even_quotient (m := n) (n := m)
        (by rw [hcomm]; exact Nat.not_odd_iff_even.mp h)

/-! ## Refutations -/

theorem pellQ_two : pellQ 2 = 3 := by decide

theorem pellQ_four : pellQ 4 = 17 := by decide

/-- **Refutation.**  The companion sequence is not divisibility-closed along multiples:
`Q 2 = 3` does not divide `Q 4 = 17`. -/
theorem not_pellQ_dvd_all_multiples : ¬ ∀ n k : ℕ, pellQ n ∣ pellQ (k * n) := by
  intro h
  have h24 := h 2 2
  norm_num [pellQ_two, pellQ_four] at h24

/-- **Refutation.**  Divisibility of indices does not imply divisibility of companion
values, so the odd-quotient hypothesis in `pellQ_dvd_iff` cannot be removed. -/
theorem not_pellQ_dvd_iff_index_dvd : ¬ ∀ m n : ℕ, m ∣ n → pellQ m ∣ pellQ n := by
  intro h
  have h24 := h 2 4 ⟨2, rfl⟩
  norm_num [pellQ_two, pellQ_four] at h24

/-! ## Summation identities linking the two strands -/

/-- Partial sums of the half-companion sequence are Pell numbers. -/
theorem pellQ_sum (n : ℕ) : ∑ i ∈ range (n + 1), pellQ i = pellP (n + 1) := by
  induction n with
  | zero => decide
  | succ k ih =>
      rw [Finset.sum_range_succ, ih, ← pellP_succ]

/-- Partial sums of the Pell sequence. -/
theorem pellP_sum (n : ℕ) :
    2 * ∑ i ∈ range (n + 1), pellP i + 1 = pellP (n + 1) + pellP n := by
  induction n with
  | zero => decide
  | succ k ih =>
      rw [Finset.sum_range_succ, Nat.mul_add, Nat.add_right_comm, ih]
      have h1 : pellP (k + 1 + 1) = 2 * pellP (k + 1) + pellP k := pellP_add_two k
      omega

/-- Partial sums of squares of Pell numbers telescope into a product. -/
theorem pellP_sq_sum (n : ℕ) :
    2 * ∑ i ∈ range (n + 1), pellP i ^ 2 = pellP n * pellP (n + 1) := by
  induction n with
  | zero => decide
  | succ k ih =>
      rw [Finset.sum_range_succ, Nat.mul_add, ih]
      have h1 : pellP (k + 1 + 1) = 2 * pellP (k + 1) + pellP k := pellP_add_two k
      rw [h1]
      ring

end Catalog.Novelty.PellSpine