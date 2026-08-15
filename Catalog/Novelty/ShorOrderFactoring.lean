import Novelty.ShorCombState

/-! # Order finding is factoring: the decisive equivalence, formalized

The assessment of the de-quantization proposal rests on the classical half of
Shor's algorithm: *a sample from the ideal QFT output distribution yields the
order `r`, and the order yields a factor of `N`.*  This file formalizes that
half, and the complementary observation that every regime in which the
tensor-network bond dimension of Shor's state is small is a regime in which the
order is found by classical search.

Main results:

* `exists_factor_of_sqrt_one` : **a nontrivial square root of `1` mod `N`
  produces a nontrivial divisor of `N`** — the classical core of Shor's
  post-processing, via `gcd(x - 1, N)`;
* `exists_factor_of_orderOf_even` : if the order `r` of `a` in `ZMod N` is
  even, positive, and `a^{r/2} ≠ -1`, then `N` has a nontrivial divisor.  So an
  order-finding oracle factors `N`;
* `exists_pow_eq_one_le_of_bondDim` : conversely, if the Shor state admits *any*
  MPS representation of bond dimension `χ` across the register cut, then
  `orderOf a ≤ χ`, hence the order is exhibited by a search of length `χ`: a
  polynomial bond dimension is a polynomial-time classical order-finding
  algorithm.  Low rank and classical easiness coincide.
-/

open Finset

namespace ShorIrreducible

/-! ## A nontrivial square root of one factors `N` -/

/-- **The classical core of Shor's algorithm.**  If `x² ≡ 1 (mod N)` but
`x ≢ ±1 (mod N)`, then `gcd(x - 1, N)` is a nontrivial divisor of `N`. -/
theorem exists_factor_of_sqrt_one {N : ℕ} (hN : 1 < N) {x : ℤ}
    (hsq : (N : ℤ) ∣ x ^ 2 - 1) (hne1 : ¬ (N : ℤ) ∣ x - 1) (hne2 : ¬ (N : ℤ) ∣ x + 1) :
    ∃ d : ℕ, d ∣ N ∧ 1 < d ∧ d < N := by
  classical
  set d : ℕ := Int.gcd (x - 1) (N : ℤ) with hd
  have hdvdN : (d : ℕ) ∣ N := by
    have : (d : ℤ) ∣ (N : ℤ) := Int.gcd_dvd_right _ _
    exact_mod_cast this
  have hd1 : d ≠ 1 := by
    intro h1
    have hcop : IsCoprime (x - 1) (N : ℤ) := Int.isCoprime_iff_gcd_eq_one.mpr h1
    have hfac : (N : ℤ) ∣ (x - 1) * (x + 1) := by
      have : (x - 1) * (x + 1) = x ^ 2 - 1 := by ring
      rw [this]
      exact hsq
    exact hne2 (hcop.symm.dvd_of_dvd_mul_left hfac)
  have hdN : d ≠ N := by
    intro hDN
    apply hne1
    have : (d : ℤ) ∣ (x - 1) := Int.gcd_dvd_left _ _
    rwa [hDN] at this
  have hdpos : 0 < d := by
    rcases Nat.eq_zero_or_pos d with h0 | h
    · exfalso
      have : (N : ℕ) = 0 := Nat.eq_zero_of_zero_dvd (h0 ▸ hdvdN)
      omega
    · exact h
  refine ⟨d, hdvdN, ?_, ?_⟩
  · omega
  · exact lt_of_le_of_ne (Nat.le_of_dvd (by omega) hdvdN) hdN

/-- The same statement inside `ZMod N`: a square root of `1` other than `±1`
yields a nontrivial factor. -/
theorem exists_factor_of_sqrt_one_zmod {N : ℕ} (hN : 1 < N) (b : ZMod N)
    (hsq : b ^ 2 = 1) (hne1 : b ≠ 1) (hne2 : b ≠ -1) :
    ∃ d : ℕ, d ∣ N ∧ 1 < d ∧ d < N := by
  haveI : NeZero N := ⟨by omega⟩
  set x : ℤ := (b.val : ℤ) with hx
  have hcast : ((x : ℤ) : ZMod N) = b := by
    rw [hx]
    push_cast
    exact ZMod.natCast_zmod_val b
  refine exists_factor_of_sqrt_one (x := x) hN ?_ ?_ ?_
  · rw [← ZMod.intCast_zmod_eq_zero_iff_dvd]
    push_cast
    rw [hcast, hsq, sub_self]
  · rw [← ZMod.intCast_zmod_eq_zero_iff_dvd]
    push_cast
    rw [hcast]
    intro hcon
    exact hne1 (by rwa [sub_eq_zero] at hcon)
  · rw [← ZMod.intCast_zmod_eq_zero_iff_dvd]
    push_cast
    rw [hcast]
    intro hcon
    exact hne2 (by rwa [add_eq_zero_iff_eq_neg] at hcon)

/-- **Order finding factors `N`.**  If the order `r` of `a` modulo `N` is even
and `a^{r/2} ≢ -1`, the order yields a nontrivial divisor of `N`.  Together with
the continued-fraction step this is the classical half of Shor's algorithm: a
polynomial-time sampler for the QFT output distribution would be a
polynomial-time factoring algorithm. -/
theorem exists_factor_of_orderOf_even {N : ℕ} (hN : 1 < N) (a : ZMod N)
    (hpos : 0 < orderOf a) (heven : Even (orderOf a)) (hne : a ^ (orderOf a / 2) ≠ -1) :
    ∃ d : ℕ, d ∣ N ∧ 1 < d ∧ d < N := by
  set r := orderOf a with hr
  obtain ⟨k, hk⟩ := heven
  have hk2 : r / 2 = k := by omega
  have hsq : (a ^ (r / 2)) ^ 2 = 1 := by
    rw [← pow_mul, hk2]
    have : k * 2 = r := by omega
    rw [this, hr, pow_orderOf_eq_one]
  have hne1 : a ^ (r / 2) ≠ 1 := by
    intro hcon
    have hdvd : r ∣ (r / 2) := orderOf_dvd_of_pow_eq_one hcon
    have hlt : r / 2 < r := by omega
    have hposhalf : 0 < r / 2 := by omega
    exact absurd (Nat.le_of_dvd hposhalf hdvd) (not_le.mpr hlt)
  exact exists_factor_of_sqrt_one_zmod hN _ hsq hne1 hne

/-- The reduction is not vacuous: `4` is a nontrivial square root of `1`
modulo `15`, and `gcd(4 - 1, 15) = 3`. -/
example : ((4 : ZMod 15) ^ 2 = 1 ∧ (4 : ZMod 15) ≠ 1 ∧ (4 : ZMod 15) ≠ -1) ∧
    Int.gcd ((4 : ℤ) - 1) (15 : ℤ) = 3 := by
  refine ⟨⟨by decide, by decide, by decide⟩, by decide⟩

/-! ## Low bond dimension means a classically easy order -/

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]

/-- **Every low-rank regime is a classically easy regime.**  If the Shor state
of `a` admits a bond-dimension-`χ` matrix product representation across the
register cut, then the order of `a` is at most `χ`, so it is exhibited by a
search of length `χ`: there is no regime in which a tensor-train emulation is
cheap *and* the order-finding problem is hard. -/
theorem exists_pow_eq_one_le_of_bondDim {a : G} {r m χ : ℕ} (hr : orderOf a = r)
    (hrpos : 0 < r) (hm : 0 < m)
    (h : IITTensorNetwork.HasBondDim (shorState (r * m) (powFun a (r * m))) χ) :
    ∃ k : ℕ, 1 ≤ k ∧ k ≤ χ ∧ a ^ k = 1 := by
  have hle : r ≤ χ :=
    bondDim_shorState_ge hrpos hm (hr ▸ hasExactPeriod_powFun a (r * m)) h
  exact ⟨r, hrpos, hle, by rw [← hr]; exact pow_orderOf_eq_one a⟩

/-- Contrapositive slogan: an exponentially large order forces an exponentially
large bond dimension. -/
theorem bondDim_gt_of_orderOf_gt {a : G} {r m χ : ℕ} (hr : orderOf a = r) (hrpos : 0 < r)
    (hm : 0 < m) (hχ : χ < r) :
    ¬ IITTensorNetwork.HasBondDim (shorState (r * m) (powFun a (r * m))) χ :=
  not_hasBondDim_shorState_pow hr hrpos hm hχ

end ShorIrreducible