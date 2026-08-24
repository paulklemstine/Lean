import Probability.PriceTwoAdicSealing

/-!
# Nothing beyond the second click: every position `t ≥ 2` is sealed

`Probability/PriceTwoAdicSealing.lean` shows that position `2` of a Price address is not a
function of the odd leg `N`.  Here we upgrade this to *every* position `t ≥ 2`
simultaneously, by an explicit twin family indexed by `t`.

Fix `t = s + 2` and put `a = 2^s`.  The two nodes

```
bigX s = (2^(s+2)·(10·2^s - 3) + 1, 2^(s+2)·(10·2^s - 3))     (the factorisation N = 1·N)
bigY s = (12·2^s - 1, 2^(s+3))                                 (the factorisation N = (2^t-1)·(5·2^t-1))
```

are valid Price nodes with the **same** odd leg `N = 80a² - 24a + 1`, both of depth at
least `t + 1`.  The second Euclid parameter of `bigX s` has 2-adic valuation exactly `t`,
that of `bigY s` has valuation `t + 1`; by the `A`-run law (`letterAt_even_iff`) their
addresses therefore agree — all letters `A` — at every position `u < t`, and disagree at
position `t`.

Hence (`no_oddLeg_classifier_pos`, `no_residue_classifier_pos`) for every `t ≥ 2` no
function of `N`, and a fortiori no function of any residue `N mod 2^k`, computes the
`A`-ness of the letter at position `t`.  Combined with `two_clicks_visible`
(`Probability/PriceTwoAdicSealing.lean`) this is the exact statement of the law:

> the 2-adic reading of a Price address has **exactly two clicks**, `N mod 4` and
> `N mod 8`, and is structurally blind from position `2` onwards.

## Lab notes (round 71, exp 552)

The family was checked for `t = 2, …, 11`: valid nodes, equal odd legs
(`57, 273, 1185, 4929, 20097, 81153, …`), addresses agreeing in `A`-ness at all positions
`u < t` and disagreeing at `t`, `0` exceptions; the address lengths (`4,7,9,11,…` and
`4,6,8,10,…`) exceed `t` in every case.
-/

namespace Price2Adic

/-! ## The odd cofactor `10·2^s - 3` -/

/-- The odd part of the second Euclid parameter of `bigX`. -/
def bigW (s : ℕ) : ℕ := 10 * 2 ^ s - 3

theorem bigW_eq (s : ℕ) : 10 * 2 ^ s = bigW s + 3 := by
  have h : 1 ≤ 2 ^ s := Nat.one_le_two_pow
  simp only [bigW]
  omega

theorem bigW_odd (s : ℕ) : bigW s % 2 = 1 := by
  have h := bigW_eq s
  have h2 : 2 ∣ 10 * 2 ^ s := ⟨5 * 2 ^ s, by ring⟩
  omega

theorem bigW_ge (s : ℕ) : 7 ≤ bigW s := by
  have h := bigW_eq s
  have h1 : 1 ≤ 2 ^ s := Nat.one_le_two_pow
  omega

/-- The first Euclid parameter of `bigY`. -/
def bigV (s : ℕ) : ℕ := 12 * 2 ^ s - 1

theorem bigV_eq (s : ℕ) : 12 * 2 ^ s = bigV s + 1 := by
  have h : 1 ≤ 2 ^ s := Nat.one_le_two_pow
  simp only [bigV]
  omega

theorem bigV_odd (s : ℕ) : bigV s % 2 = 1 := by
  have h := bigV_eq s
  have h2 : 2 ∣ 12 * 2 ^ s := ⟨6 * 2 ^ s, by ring⟩
  omega

/-! ## The two twins at position `t = s + 2` -/

/-- The node of the trivial factorisation `N = 1 · N`; its second parameter has 2-adic
valuation exactly `s + 2`. -/
def bigX (s : ℕ) : ℕ × ℕ := (2 ^ (s + 2) * bigW s + 1, 2 ^ (s + 2) * bigW s)

/-- The node of the factorisation `N = (2^t - 1)·(5·2^t - 1)`; its second parameter has
2-adic valuation `s + 3`. -/
def bigY (s : ℕ) : ℕ × ℕ := (bigV s, 2 ^ (s + 3))

theorem bigX_valid (s : ℕ) : Valid (bigX s) := by
  have hw := bigW_ge s
  have h1 : 1 ≤ 2 ^ (s + 2) := Nat.one_le_two_pow
  have hpos : 0 < 2 ^ (s + 2) * bigW s := Nat.mul_pos (by omega) (by omega)
  show Valid (2 ^ (s + 2) * bigW s + 1, 2 ^ (s + 2) * bigW s)
  refine ⟨hpos, by omega, ?_, by omega⟩
  show Nat.gcd (2 ^ (s + 2) * bigW s + 1) (2 ^ (s + 2) * bigW s) = 1
  have h : Nat.gcd (2 ^ (s + 2) * bigW s + 1) (2 ^ (s + 2) * bigW s) ∣
      (2 ^ (s + 2) * bigW s + 1) - (2 ^ (s + 2) * bigW s) :=
    Nat.dvd_sub (Nat.gcd_dvd_left _ _) (Nat.gcd_dvd_right _ _)
  rw [show (2 ^ (s + 2) * bigW s + 1) - (2 ^ (s + 2) * bigW s) = 1 from by omega] at h
  exact Nat.dvd_one.mp h

theorem bigY_valid (s : ℕ) : Valid (bigY s) := by
  have hv := bigV_eq s
  have hodd := bigV_odd s
  have h1 : 1 ≤ 2 ^ s := Nat.one_le_two_pow
  have h2 : 2 ^ (s + 3) = 8 * 2 ^ s := by rw [pow_add]; ring
  show Valid (bigV s, 2 ^ (s + 3))
  refine ⟨by positivity, by omega, ?_, by omega⟩
  show Nat.gcd (bigV s) (2 ^ (s + 3)) = 1
  have hcop : Nat.Coprime 2 (bigV s) :=
    (Nat.Prime.coprime_iff_not_dvd Nat.prime_two).mpr (by omega)
  exact (hcop.pow_left (s + 3)).symm

theorem oddLeg_bigX (s : ℕ) : oddLeg (bigX s) = 2 * (2 ^ (s + 2) * bigW s) + 1 := by
  have h : (2 ^ (s + 2) * bigW s + 1) ^ 2
      = (2 ^ (s + 2) * bigW s) ^ 2 + (2 * (2 ^ (s + 2) * bigW s) + 1) := by ring
  simp only [bigX, oddLeg]
  omega

theorem oddLeg_bigY (s : ℕ) : oddLeg (bigY s) = 2 * (2 ^ (s + 2) * bigW s) + 1 := by
  have hw := bigW_eq s
  have hv := bigV_eq s
  have h2 : 2 ^ (s + 2) = 4 * 2 ^ s := by rw [pow_add]; ring
  have h3 : 2 ^ (s + 3) = 8 * 2 ^ s := by rw [pow_add]; ring
  have hsq : (bigV s) ^ 2 = (2 ^ (s + 3)) ^ 2 + (2 * (2 ^ (s + 2) * bigW s) + 1) := by
    have e1 : bigV s = 12 * 2 ^ s - 1 := rfl
    have e2 : bigV s + 1 = 12 * 2 ^ s := hv.symm
    have e3 : bigW s + 3 = 10 * 2 ^ s := (bigW_eq s).symm
    have expand : (bigV s + 1) ^ 2 = (bigV s) ^ 2 + 2 * bigV s + 1 := by ring
    have hV : (12 * 2 ^ s) ^ 2 = 144 * (2 ^ s * 2 ^ s) := by ring
    have hW : 2 * (4 * 2 ^ s * bigW s) = 8 * 2 ^ s * bigW s := by ring
    have hWval : 8 * 2 ^ s * bigW s + 24 * 2 ^ s = 80 * (2 ^ s * 2 ^ s) := by
      have : 8 * 2 ^ s * (bigW s + 3) = 8 * 2 ^ s * (10 * 2 ^ s) := by rw [e3]
      nlinarith [this]
    have h8 : (8 * 2 ^ s) ^ 2 = 64 * (2 ^ s * 2 ^ s) := by ring
    rw [h2, h3, hW, h8]
    nlinarith [expand, e2, hV, hWval]
  simp only [bigY, oddLeg]
  omega

/-- The two twins have the same odd leg: they are two coprime factorisations of the same
odd number `N = 80·4^s - 24·2^s + 1`. -/
theorem oddLeg_bigX_eq_bigY (s : ℕ) : oddLeg (bigX s) = oddLeg (bigY s) := by
  rw [oddLeg_bigX, oddLeg_bigY]

/-! ## The valuations, the letters, and the depth -/

theorem pow_dvd_bigX (s : ℕ) : 2 ^ (s + 2) ∣ (bigX s).2 := ⟨bigW s, rfl⟩

theorem not_pow_dvd_bigX (s : ℕ) : ¬ 2 ^ (s + 3) ∣ (bigX s).2 := by
  rintro ⟨c, hc⟩
  have hodd := bigW_odd s
  have hpos : 0 < (2 : ℕ) ^ (s + 2) := pow_pos (by norm_num : 0 < 2) _
  have h : 2 ^ (s + 2) * bigW s = 2 ^ (s + 2) * (2 * c) := by
    simp only [bigX] at hc
    rw [hc, pow_succ]
    ring
  have := Nat.eq_of_mul_eq_mul_left hpos h
  omega

/-- Below position `t = s+2` both twins are in their `A`-run: all their letters are `A`. -/
theorem bigX_bigY_agree (s : ℕ) (u : ℕ) (hu : u < s + 2) :
    letterAt (bigX s) u = .A ∧ letterAt (bigY s) u = .A := by
  have hwpos := bigW_ge s
  have hXle : (bigX s).2 ≤ (bigX s).1 := by simp only [bigX]; omega
  have h1 : 1 ≤ 2 ^ s := Nat.one_le_two_pow
  have hYle : (bigY s).2 ≤ (bigY s).1 := by
    have hv := bigV_eq s
    have h3 : 2 ^ (s + 3) = 8 * 2 ^ s := by rw [pow_add]; ring
    simp only [bigY]; omega
  constructor
  · have hdvd : 2 ^ u ∣ (bigX s).2 :=
      dvd_trans (pow_dvd_pow 2 (by omega)) (pow_dvd_bigX s)
    have := letterAt_even_iff (bigX s).1 (bigX s).2 u hXle hdvd
    rw [show ((bigX s).1, (bigX s).2) = bigX s from rfl] at this
    exact this.mpr (dvd_trans (pow_dvd_pow 2 (by omega)) (pow_dvd_bigX s))
  · have hdvdY : ∀ v ≤ s + 3, (2 : ℕ) ^ v ∣ (bigY s).2 := by
      intro v hv
      have hY2 : (bigY s).2 = 2 ^ (s + 3) := rfl
      rw [hY2]
      exact pow_dvd_pow 2 hv
    have := letterAt_even_iff (bigY s).1 (bigY s).2 u hYle (hdvdY u (by omega))
    rw [show ((bigY s).1, (bigY s).2) = bigY s from rfl] at this
    exact this.mpr (hdvdY (u + 1) (by omega))

/-- At position `t = s+2` the twins disagree: `bigX` has left its `A`-run, `bigY` has not. -/
theorem bigX_bigY_split (s : ℕ) :
    letterAt (bigX s) (s + 2) ≠ .A ∧ letterAt (bigY s) (s + 2) = .A := by
  have hwpos := bigW_ge s
  have hXle : (bigX s).2 ≤ (bigX s).1 := by simp only [bigX]; omega
  have hYle : (bigY s).2 ≤ (bigY s).1 := by
    have hv := bigV_eq s
    have h3 : 2 ^ (s + 3) = 8 * 2 ^ s := by rw [pow_add]; ring
    simp only [bigY]; omega
  constructor
  · have := letterAt_even_iff (bigX s).1 (bigX s).2 (s + 2) hXle (pow_dvd_bigX s)
    rw [show ((bigX s).1, (bigX s).2) = bigX s from rfl] at this
    exact fun hc => not_pow_dvd_bigX s (this.mp hc)
  · have hY2 : (bigY s).2 = 2 ^ (s + 3) := rfl
    have hdvd : (2 : ℕ) ^ (s + 2) ∣ (bigY s).2 := by
      rw [hY2]; exact pow_dvd_pow 2 (by omega)
    have := letterAt_even_iff (bigY s).1 (bigY s).2 (s + 2) hYle hdvd
    rw [show ((bigY s).1, (bigY s).2) = bigY s from rfl] at this
    exact this.mpr (by rw [hY2])

theorem bigX_depth (s : ℕ) : s + 3 ≤ (address (bigX s)).length := by
  refine length_address_ge (s + 3) (bigX s) (bigX_valid s) ?_
  intro u hu
  have hwpos := bigW_ge s
  have hXle : (bigX s).2 ≤ (bigX s).1 := by simp only [bigX]; omega
  have hdvd : 2 ^ u ∣ (bigX s).2 := dvd_trans (pow_dvd_pow 2 (by omega)) (pow_dvd_bigX s)
  have hiter := iterate_parent_even (bigX s).1 (bigX s).2 hXle u hdvd
  rw [show ((bigX s).1, (bigX s).2) = bigX s from rfl] at hiter
  rw [hiter]
  have hpos : 0 < (2 : ℕ) ^ u := pow_pos (by norm_num : 0 < 2) _
  have hle : (2 : ℕ) ^ u ≤ 2 ^ (s + 2) := Nat.pow_le_pow_right (by norm_num) (by omega)
  have hge : 2 ≤ (bigX s).2 / 2 ^ u := by
    have h1 : 2 ^ (s + 2) * bigW s / 2 ^ u ≥ 2 ^ (s + 2) * bigW s / 2 ^ (s + 2) := by
      exact Nat.div_le_div_left hle hpos
    have h2 : 2 ^ (s + 2) * bigW s / 2 ^ (s + 2) = bigW s :=
      Nat.mul_div_cancel_left _ (pow_pos (by norm_num : 0 < 2) _)
    simp only [bigX]
    omega
  simp only [root, ne_eq, Prod.mk.injEq, not_and]
  omega

theorem bigY_depth (s : ℕ) : s + 3 ≤ (address (bigY s)).length := by
  refine length_address_ge (s + 3) (bigY s) (bigY_valid s) ?_
  intro u hu
  have hv := bigV_eq s
  have h1 : 1 ≤ 2 ^ s := Nat.one_le_two_pow
  have h3 : 2 ^ (s + 3) = 8 * 2 ^ s := by rw [pow_add]; ring
  have hYle : (bigY s).2 ≤ (bigY s).1 := by simp only [bigY]; omega
  have hY2 : (bigY s).2 = 2 ^ (s + 3) := rfl
  have hdvd : 2 ^ u ∣ (bigY s).2 := by
    rw [hY2]
    exact pow_dvd_pow 2 (show u ≤ s + 3 by omega)
  have hiter := iterate_parent_even (bigY s).1 (bigY s).2 hYle u hdvd
  rw [show ((bigY s).1, (bigY s).2) = bigY s from rfl] at hiter
  rw [hiter]
  have hpow : (bigY s).2 / 2 ^ u = 2 ^ (s + 3 - u) := by
    simp only [bigY]
    rw [show (2 : ℕ) ^ (s + 3) = 2 ^ u * 2 ^ (s + 3 - u) from by
      rw [← pow_add]; congr 1; omega]
    exact Nat.mul_div_cancel_left _ (pow_pos (by norm_num : 0 < 2) _)
  have hge : 2 ≤ (bigY s).2 / 2 ^ u := by
    rw [hpow]
    have : (2 : ℕ) ^ 1 ≤ 2 ^ (s + 3 - u) := Nat.pow_le_pow_right (by norm_num) (by omega)
    simpa using this
  simp only [root, ne_eq, Prod.mk.injEq, not_and]
  omega

/-! ## Sealing at every position `t ≥ 2` -/

/-- **Every position from the third on is sealed.**  For `t = s + 2` there are two valid
Price nodes of depth `> t` with *identical* odd legs whose addresses have the same
`A`-nesses at all positions `u < t` and opposite `A`-nesses at position `t`. -/
theorem pos_sealed_at (s : ℕ) :
    ∃ p q : ℕ × ℕ, Valid p ∧ Valid q ∧ oddLeg p = oddLeg q ∧
      s + 3 ≤ (address p).length ∧ s + 3 ≤ (address q).length ∧
      (∀ u < s + 2, (letterAt p u = .A ↔ letterAt q u = .A)) ∧
      ¬ (letterAt p (s + 2) = .A ↔ letterAt q (s + 2) = .A) := by
  refine ⟨bigX s, bigY s, bigX_valid s, bigY_valid s, oddLeg_bigX_eq_bigY s,
    bigX_depth s, bigY_depth s, ?_, ?_⟩
  · intro u hu
    obtain ⟨h1, h2⟩ := bigX_bigY_agree s u hu
    rw [h1, h2]
  · obtain ⟨h1, h2⟩ := bigX_bigY_split s
    intro hc
    exact h1 (hc.mpr h2)

/-- **No function of the odd leg reads any position `t ≥ 2`.** -/
theorem no_oddLeg_classifier_pos (t : ℕ) (ht : 2 ≤ t) (f : ℕ → Bool) :
    ¬ ∀ p : ℕ × ℕ, Valid p → t < (address p).length →
        (letterAt p t = .A ↔ f (oddLeg p) = true) := by
  intro hf
  obtain ⟨s, hs⟩ : ∃ s, t = s + 2 := ⟨t - 2, by omega⟩
  subst hs
  obtain ⟨p, q, hp, hq, hlegs, hdp, hdq, -, hsplit⟩ := pos_sealed_at s
  exact hsplit (by rw [hf p hp (by omega), hf q hq (by omega), hlegs])

/-- **No 2-adic residue reads any position `t ≥ 2`**, at any depth `k` of the 2-adic
filtration.  With `two_clicks_visible` this pins the capacity of the Price residue dial at
exactly two clicks. -/
theorem no_residue_classifier_pos (t : ℕ) (ht : 2 ≤ t) (k : ℕ) (f : ℕ → Bool) :
    ¬ ∀ p : ℕ × ℕ, Valid p → t < (address p).length →
        (letterAt p t = .A ↔ f (oddLeg p % 2 ^ k) = true) :=
  no_oddLeg_classifier_pos t ht (fun N => f (N % 2 ^ k))

end Price2Adic