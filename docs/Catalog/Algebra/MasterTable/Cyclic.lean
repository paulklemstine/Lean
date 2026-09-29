/-
# MASTER-TABLE (paper 119) — the cyclic columns

For the cyclic degree-`n` channel (`C n`, the source is a uniformly random residue
`a ∈ range n`, the splitting type is `ordType n a`) the catalog records two
read-outs: the full type `T` (`typeEntropy n`) and the number of roots
`rootCount n T` (`n` if `p` splits completely, `0` otherwise).

This file proves, for **every** `n`:

* `rootCountEntropy_eq_pinEnt` — the root-count channel is the pinning entropy:
  `H(rootCount) = pinEnt n = log₂ n - ((n-1)/n) log₂ (n-1)`;
* `typeEntropy_eq_totient_sum` — `H(T) = log₂ n - (1/n) ∑_{d ∣ n} φ(d) log₂ φ(d)`;
* `rootCount_lossless_iff_prime` — **the root count is a lossless read-out of the
  splitting type iff `n` is prime** (for `n ≥ 2`); for composite `n` the loss is
  strict (`rootCountEntropy_lt_typeEntropy`).

In the master table this explains the pattern of the degree-`3…6` rows: at the
prime degrees `3, 5` the root-count column coincides with the type column, at the
composite degrees `4, 6` it falls strictly below it.
-/
import Algebra.MasterTable.Fibres

namespace MasterTable

open CyclicTypeChannel Finset

/-- The **root-count channel** of the cyclic degree-`n` field: the entropy of the
number of roots `rootCount n T` of a uniformly random Frobenius. -/
noncomputable def rootCountEntropy (n : ℕ) : ℝ := uEnt (range n) (rootCount n ∘ ordType n)

/-- A residue splits completely iff it is the identity residue. -/
lemma ordType_eq_one_iff {n a : ℕ} (hn : 0 < n) (ha : a < n) : ordType n a = 1 ↔ a = 0 := by
  constructor
  · intro h
    have hg : Nat.gcd a n ∣ n := Nat.gcd_dvd_right a n
    have hgn : Nat.gcd a n = n := by
      have := Nat.div_mul_cancel hg
      rw [← ordType, h, one_mul] at this
      exact this
    have hna : n ∣ a := hgn ▸ Nat.gcd_dvd_left a n
    exact Nat.eq_zero_of_dvd_of_lt hna ha
  · rintro rfl
    exact ordType_zero hn

/-- **The root-count channel is the pinning entropy**, for every `n ≥ 1`. -/
theorem rootCountEntropy_eq_pinEnt {n : ℕ} (hn : 0 < n) : rootCountEntropy n = pinEnt n := by
  have hne : ∀ x ∈ range n, x ≠ 0 → rootCount n (ordType n x) = 0 := by
    intro x hx hx0
    rw [rootCount, if_neg ((ordType_eq_one_iff hn (mem_range.1 hx)).not.2 hx0)]
  rw [rootCountEntropy, uEnt_pinned (a₀ := 0) (mem_range.2 hn), card_range]
  · intro x hx hgx
    by_contra h0
    have h1 : rootCount n (ordType n 0) = n := by simp [rootCount, ordType_zero hn]
    simp only [Function.comp_apply, hne x hx h0, h1] at hgx
    exact hn.ne' hgx.symm
  · intro x hx y hy hx0 hy0
    simp only [Function.comp_apply, hne x hx hx0, hne y hy hy0]

/-- **The `φ`-form of the type entropy**:
`H(T) = log₂ n - (1/n) ∑_{d ∣ n} φ(d) · log₂ φ(d)`. -/
theorem typeEntropy_eq_totient_sum {n : ℕ} (hn : 0 < n) :
    typeEntropy n = Real.logb 2 n
      - (∑ d ∈ n.divisors, (Nat.totient d : ℝ) * Real.logb 2 (Nat.totient d)) / n := by
  rw [typeEntropy, uEnt, sum_logb_fiber, image_ordType n hn, card_range]
  congr 2
  exact sum_congr rfl fun d hd => by rw [card_ordType_eq_totient hn (Nat.mem_divisors.1 hd).1]

/-- At a prime degree the root count is an injective recoding of the type. -/
theorem rootCountEntropy_prime {p : ℕ} (hp : p.Prime) : rootCountEntropy p = typeEntropy p := by
  rw [rootCountEntropy, typeEntropy, uEnt_comp_injOn]
  have hmem : ∀ t ∈ ordType p '' (range p : Set ℕ), t = 1 ∨ t = p := by
    rintro t ⟨a, -, rfl⟩
    exact (Nat.dvd_prime hp).1 (ordType_dvd a)
  intro x hx y hy hxy
  have hp1 : p ≠ 1 := hp.one_lt.ne'
  have hp0 : p ≠ 0 := hp.ne_zero
  rcases hmem x hx with rfl | rfl <;> rcases hmem y hy with rfl | rfl <;>
    simp_all [rootCount]

/-- **Strict loss at composite degrees**: if `n ≥ 2` is not prime, the root count
carries strictly less information than the splitting type. -/
theorem rootCountEntropy_lt_typeEntropy {n : ℕ} (hn : 2 ≤ n) (hnp : ¬ n.Prime) :
    rootCountEntropy n < typeEntropy n := by
  have hn0 : 0 < n := by omega
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn0
  have h1mem : 1 ∈ n.divisors := Nat.mem_divisors.2 ⟨one_dvd n, hn0.ne'⟩
  set p := n.minFac with hpdef
  have hplt : p < n := (Nat.not_prime_iff_minFac_lt hn).1 hnp
  have hp1 : 1 < p := (Nat.minFac_prime (by omega)).one_lt
  have hpmem : p ∈ n.divisors.erase 1 :=
    mem_erase.2 ⟨hp1.ne', Nat.mem_divisors.2 ⟨Nat.minFac_dvd n, hn0.ne'⟩⟩
  -- total mass of the non-trivial types
  have hmass : (∑ d ∈ n.divisors.erase 1, (Nat.totient d : ℝ)) = (n : ℝ) - 1 := by
    have h := Nat.sum_totient n
    rw [← add_sum_erase _ _ h1mem, Nat.totient_one] at h
    have h' : ((1 + ∑ d ∈ n.divisors.erase 1, Nat.totient d : ℕ) : ℝ) = n := by
      exact_mod_cast h
    push_cast at h'
    linarith
  have hbound : ∀ d ∈ n.divisors.erase 1, (Nat.totient d : ℝ) ≤ (n : ℝ) - 1 := by
    intro d hd
    obtain ⟨hd1, hdd⟩ := mem_erase.1 hd
    have hdn : d ≤ n := Nat.divisor_le hdd
    have hd0 : 0 < d := Nat.pos_of_mem_divisors hdd
    have : Nat.totient d < d := Nat.totient_lt d (by omega)
    have : (Nat.totient d : ℝ) + 1 ≤ n := by exact_mod_cast (show Nat.totient d + 1 ≤ n by omega)
    linarith
  have hpos : ∀ d ∈ n.divisors.erase 1, (0 : ℝ) < Nat.totient d := by
    intro d hd
    exact_mod_cast Nat.totient_pos.2 (Nat.pos_of_mem_divisors (mem_erase.1 hd).2)
  have hstrict : (∑ d ∈ n.divisors.erase 1, (Nat.totient d : ℝ) * Real.logb 2 (Nat.totient d))
      < ∑ d ∈ n.divisors.erase 1, (Nat.totient d : ℝ) * Real.logb 2 ((n : ℝ) - 1) := by
    apply Finset.sum_lt_sum
    · intro d hd
      exact mul_le_mul_of_nonneg_left
        (Real.logb_le_logb_of_le (by norm_num) (hpos d hd) (hbound d hd)) (hpos d hd).le
    · refine ⟨p, hpmem, mul_lt_mul_of_pos_left ?_ (hpos p hpmem)⟩
      refine Real.logb_lt_logb (by norm_num) (hpos p hpmem) ?_
      have : Nat.totient p < p := Nat.totient_lt p hp1
      have : (Nat.totient p : ℝ) + 1 < n := by
        exact_mod_cast (show Nat.totient p + 1 < n by omega)
      linarith
  rw [← sum_mul, hmass] at hstrict
  rw [rootCountEntropy_eq_pinEnt hn0, typeEntropy_eq_totient_sum hn0, pinEnt,
    ← add_sum_erase _ _ h1mem, Nat.totient_one, Nat.cast_one, Real.logb_one, mul_zero, zero_add]
  have : ((n : ℝ) - 1) / n * Real.logb 2 ((n : ℝ) - 1)
      = ((n : ℝ) - 1) * Real.logb 2 ((n : ℝ) - 1) / n := by ring
  rw [this]
  have := div_lt_div_of_pos_right hstrict hnR
  linarith

/-- **The root count is lossless iff the degree is prime** (`n ≥ 2`). -/
theorem rootCount_lossless_iff_prime {n : ℕ} (hn : 2 ≤ n) :
    rootCountEntropy n = typeEntropy n ↔ n.Prime :=
  ⟨fun h => by_contra fun hnp => (rootCountEntropy_lt_typeEntropy hn hnp).ne h,
    rootCountEntropy_prime⟩

end MasterTable