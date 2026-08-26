import Probability.PriceTwoAdicMechanism

/-!
# Two clicks of visibility, then sealed: the exact 2-adic capacity of the Price tree

Let `N = oddLeg (m,n) = m² - n²` be the odd leg of the primitive Pythagorean triple of a
node of the Price tree, and read the Price address from the leaf backwards
(`letterAt p t`, `t = 0` the last letter).  `Cryptography/Price2Adic/Letters.lean` and
`Probability/PriceTwoAdicMechanism.lean` show that

* position `0` is `A` iff `N ≡ 1 (mod 4)`,
* position `1` is `A` iff `N mod 8 ∈ {1,3}`,

so `N mod 8` reads the first two `A`-nesses, and (`pos01_bijection_mod8`,
`pos01_attained`) this reading is a **bijection** `{1,3,5,7} ↔ Bool × Bool`.

This file proves the complementary, and much sharper, negative half: **position `2` is
not a function of the odd leg at all**.  The mechanism is an explicit twin family
indexed by `y`:

```
X y = (3y+5, 3y+4)     Y y = (y+3, y)
```

Both are valid Price nodes (for `3 ∤ y`), both have *exactly the same odd leg*
`N = 6y + 9` (they are the two coprime factorisations `N = 1·N = 3·(N/3)`), their letters
at positions `0` and `1` therefore agree — and their letters at position `2` always
*disagree* in `A`-ness (`twin_pos2_split`).  Consequences:

* `no_oddLeg_classifier_pos2` — no function of `N` whatsoever computes the position-`2`
  `A`-ness; a fortiori no function of any residue `N mod 2^k`
  (`no_residue_classifier_pos2`).
* `pos2_split_in_every_class` — every odd residue class modulo `2^k`, for every `k`,
  contains nodes of both position-`2` types: the conditional distribution of the third
  letter given the whole 2-adic cell is *never* degenerate.
* `pos2_class_of_node_split` — the "zero conditional variance" statement: the 2-adic cell
  of any given node is split at position `2`.

Together: the Price address is a residue dial of **exactly two clicks**, and it is
structurally sealed from position `2` on.

## Lab notes (round 71, exp 552)

Search over all valid pairs with `m < 300` grouped by odd leg: `3255` pairs of distinct
nodes sharing an odd leg and disagreeing at position `2` (smallest: `N = 33`, nodes
`(7,4)` with address `…A A B` and `(17,16)` with address `A A A A`, read from the leaf).
The twin family `X y`, `Y y` was checked for all `y < 3000` with `3 ∤ y`: identical odd
legs, identical `A`-nesses at positions `0,1`, opposite `A`-ness at position `2`, `0`
exceptions.  The theorems below replace the finite checks by proofs.
-/

namespace Price2Adic

/-! ## The twin family -/

/-- The first twin: the node of the factorisation `N = 1 · N` of `N = 6y+9`. -/
def twinX (y : ℕ) : ℕ × ℕ := (3 * y + 5, 3 * y + 4)

/-- The second twin: the node of the factorisation `N = 3 · (2y+3)` of `N = 6y+9`. -/
def twinY (y : ℕ) : ℕ × ℕ := (y + 3, y)

theorem oddLeg_twinX (y : ℕ) : oddLeg (twinX y) = 6 * y + 9 := by
  have h : (3 * y + 5) ^ 2 = (3 * y + 4) ^ 2 + (6 * y + 9) := by ring
  simp only [twinX, oddLeg]
  omega

theorem oddLeg_twinY (y : ℕ) : oddLeg (twinY y) = 6 * y + 9 := by
  have h : (y + 3) ^ 2 = y ^ 2 + (6 * y + 9) := by ring
  simp only [twinY, oddLeg]
  omega

theorem twinX_valid (y : ℕ) (hy : 0 < y) : Valid (twinX y) := by
  show Valid (3 * y + 5, 3 * y + 4)
  refine ⟨by omega, by omega, ?_, by omega⟩
  show Nat.gcd (3 * y + 5) (3 * y + 4) = 1
  have h : Nat.gcd (3 * y + 5) (3 * y + 4) ∣ (3 * y + 5) - (3 * y + 4) :=
    Nat.dvd_sub (Nat.gcd_dvd_left _ _) (Nat.gcd_dvd_right _ _)
  have h1 : (3 * y + 5) - (3 * y + 4) = 1 := by omega
  rw [h1] at h
  exact Nat.dvd_one.mp h

theorem twinY_valid (y : ℕ) (hy : 0 < y) (h3 : y % 3 ≠ 0) : Valid (twinY y) := by
  show Valid (y + 3, y)
  refine ⟨by omega, by omega, ?_, by omega⟩
  show Nat.gcd (y + 3) y = 1
  set d := Nat.gcd (y + 3) y with hd
  have h1 : d ∣ y + 3 := Nat.gcd_dvd_left _ _
  have h2 : d ∣ y := Nat.gcd_dvd_right _ _
  have h3' : d ∣ 3 := (Nat.dvd_add_right h2).mp (by simpa [Nat.add_comm] using h1)
  rcases (Nat.dvd_prime Nat.prime_three).mp h3' with h | h
  · exact h
  · exfalso
    rw [h] at h2
    omega

/-- **The twins split position 2.**  The two nodes `X y` and `Y y` have the same odd leg,
hence the same letters at positions `0` and `1`, but their letters at position `2` never
have the same `A`-ness. -/
theorem twin_pos2_split (y : ℕ) (hy : 9 ≤ y) (h3 : y % 3 ≠ 0) :
    ¬ (letterAt (twinX y) 2 = .A ↔ letterAt (twinY y) 2 = .A) := by
  have hXv : Valid (twinX y) := twinX_valid y (by omega)
  have hYv : Valid (twinY y) := twinY_valid y (by omega) h3
  have hXr : twinX y ≠ root := by
    simp only [twinX, root, ne_eq, Prod.mk.injEq, not_and]; omega
  have hYr : twinY y ≠ root := by
    simp only [twinY, root, ne_eq, Prod.mk.injEq, not_and]; omega
  rw [show twinX y = (3 * y + 5, 3 * y + 4) from rfl] at hXv hXr ⊢
  rw [show twinY y = (y + 3, y) from rfl] at hYv hYr ⊢
  rw [pos2_A_iff _ _ hXv hXr, pos2_A_iff _ _ hYv hYr]
  simp only [pos2Pred]
  split_ifs <;> omega

/-! ## Hitting an arbitrary 2-adic class -/

/-- Three is invertible modulo every power of two, in the explicit equational form
`3 * u = 1 + 2^k * s`. -/
theorem three_inv_two_pow (k : ℕ) : ∃ u s : ℕ, 3 * u = 1 + 2 ^ k * s := by
  induction k with
  | zero => exact ⟨1, 2, by norm_num⟩
  | succ k ih =>
    obtain ⟨u, s, h⟩ := ih
    rcases Nat.even_or_odd s with he | ho
    · obtain ⟨c, hc⟩ := he
      exact ⟨u, c, by rw [h, hc, pow_succ]; ring⟩
    · obtain ⟨c, hc⟩ := ho
      refine ⟨u + 2 ^ k, c + 2, ?_⟩
      have : 3 * (u + 2 ^ k) = 3 * u + 3 * 2 ^ k := by ring
      rw [this, h, hc, pow_succ]
      ring

/-- Every odd residue class modulo `2^k` is hit by the twin family, arbitrarily far out. -/
theorem exists_twin_in_class (k M r : ℕ) (hr : r % 2 = 1) :
    ∃ y : ℕ, M < y ∧ y % 3 ≠ 0 ∧ (6 * y + 9) ≡ r [MOD 2 ^ k] := by
  obtain ⟨u, s, hus⟩ := three_inv_two_pow (k + 1)
  set c : ℕ := 2 ^ (k + 1) with hc
  have hcpos : 2 ≤ c := by
    have : (2 : ℕ) ^ 1 ≤ 2 ^ (k + 1) := Nat.pow_le_pow_right (by norm_num) (by omega)
    simpa [hc] using this
  set w : ℕ := u * r + c * (M + 3) with hw
  have hkey : 3 * w = r + c * (s * r + 3 * (M + 3)) := by
    have h1 : 3 * w = 3 * u * r + 3 * (c * (M + 3)) := by rw [hw]; ring
    rw [h1, hus]
    ring
  have hceven : 2 ∣ c := by
    refine ⟨2 ^ k, ?_⟩
    rw [hc, pow_succ]
    ring
  have hEeven : 2 ∣ c * (s * r + 3 * (M + 3)) := Dvd.dvd.mul_right hceven _
  have hwodd : w % 2 = 1 := by omega
  have hwbig : 2 * (M + 3) ≤ w := by
    have : 2 * (M + 3) ≤ c * (M + 3) := Nat.mul_le_mul_right _ hcpos
    omega
  obtain ⟨y₀, hy₀⟩ : ∃ y₀, w = 2 * y₀ + 3 := ⟨(w - 3) / 2, by omega⟩
  have hy₀big : M < y₀ := by omega
  have hy₀cong : (6 * y₀ + 9) ≡ r [MOD 2 ^ k] := by
    have h1 : 6 * y₀ + 9 = r + 2 ^ k * (2 * (s * r + 3 * (M + 3))) := by
      have h2 : c = 2 * 2 ^ k := by rw [hc, pow_succ]; ring
      have h3 := hkey
      rw [hy₀, h2] at h3
      calc 6 * y₀ + 9 = 3 * (2 * y₀ + 3) := by ring
        _ = r + 2 * 2 ^ k * (s * r + 3 * (M + 3)) := h3
        _ = r + 2 ^ k * (2 * (s * r + 3 * (M + 3))) := by ring
    show (6 * y₀ + 9) % 2 ^ k = r % 2 ^ k
    rw [h1, Nat.add_mul_mod_self_left]
  by_cases h3 : y₀ % 3 ≠ 0
  · exact ⟨y₀, hy₀big, h3, hy₀cong⟩
  · refine ⟨y₀ + 2 ^ k, by omega, ?_, ?_⟩
    · have h2 : 2 ^ k % 3 = 1 ∨ 2 ^ k % 3 = 2 := by
        have h3' : ¬ (3 ∣ 2 ^ k) := by
          intro hdvd
          have := Nat.Prime.dvd_of_dvd_pow (p := 3) (by norm_num) hdvd
          omega
        omega
      omega
    · have h1 : 6 * (y₀ + 2 ^ k) + 9 = (6 * y₀ + 9) + 2 ^ k * 6 := by ring
      show (6 * (y₀ + 2 ^ k) + 9) % 2 ^ k = r % 2 ^ k
      rw [h1, Nat.add_mul_mod_self_left]
      exact hy₀cong

/-! ## The sealing theorems -/

/-- **Death at position 2.**  For every `k` and every odd `r`, the 2-adic class
`N ≡ r (mod 2^k)` contains two Price nodes with *identical* odd legs, identical `A`-nesses
at positions `0` and `1`, and opposite `A`-nesses at position `2`.  In particular the
conditional distribution of the third letter inside a 2-adic cell is never degenerate. -/
theorem pos2_split_in_every_class (k r : ℕ) (hr : r % 2 = 1) :
    ∃ p q : ℕ × ℕ, Valid p ∧ Valid q ∧ oddLeg p = oddLeg q ∧
      oddLeg p ≡ r [MOD 2 ^ k] ∧
      3 ≤ (address p).length ∧ 3 ≤ (address q).length ∧
      (letterAt p 0 = .A ↔ letterAt q 0 = .A) ∧
      (letterAt p 1 = .A ↔ letterAt q 1 = .A) ∧
      ¬ (letterAt p 2 = .A ↔ letterAt q 2 = .A) := by
  obtain ⟨y, hy, h3, hcong⟩ := exists_twin_in_class k 13 r hr
  have hXv : Valid (twinX y) := twinX_valid y (by omega)
  have hYv : Valid (twinY y) := twinY_valid y (by omega) h3
  have hlegs : oddLeg (twinX y) = oddLeg (twinY y) := by
    rw [oddLeg_twinX, oddLeg_twinY]
  refine ⟨twinX y, twinY y, hXv, hYv, hlegs, by rw [oddLeg_twinX]; exact hcong, ?_, ?_, ?_, ?_,
    twin_pos2_split y (by omega) h3⟩
  · exact three_le_length_address _ hXv (by show 27 < 3 * y + 5 + (3 * y + 4); omega)
  · exact three_le_length_address _ hYv (by show 27 < y + 3 + y; omega)
  · rw [letterAt_zero_A_iff _ hXv, letterAt_zero_A_iff _ hYv, hlegs]
  · rw [letterAt_one_A_iff _ hXv, letterAt_one_A_iff _ hYv, hlegs]

/-- **No function of the odd leg reads position 2.**  Not merely no residue of `N`: the
whole integer `N` does not determine the third letter's `A`-ness. -/
theorem no_oddLeg_classifier_pos2 (f : ℕ → Bool) :
    ¬ ∀ p : ℕ × ℕ, Valid p → 3 ≤ (address p).length →
        (letterAt p 2 = .A ↔ f (oddLeg p) = true) := by
  intro hf
  obtain ⟨p, q, hp, hq, hlegs, -, hlp, hlq, -, -, hsplit⟩ := pos2_split_in_every_class 1 1 rfl
  exact hsplit (by rw [hf p hp hlp, hf q hq hlq, hlegs])

/-- **No 2-adic residue reads position 2**, at any depth `k` of the filtration.  Together
with `two_clicks_visible` this is the exact statement "two clicks, then sealed". -/
theorem no_residue_classifier_pos2 (k : ℕ) (f : ℕ → Bool) :
    ¬ ∀ p : ℕ × ℕ, Valid p → 3 ≤ (address p).length →
        (letterAt p 2 = .A ↔ f (oddLeg p % 2 ^ k) = true) :=
  no_oddLeg_classifier_pos2 (fun N => f (N % 2 ^ k))

/-- **Zero conditional information at `t = 2`.**  The 2-adic cell of *any* node is split at
position `2`: whatever the node, its own class modulo `2^k` contains a node whose third
letter has the opposite `A`-ness. -/
theorem pos2_class_of_node_split (k : ℕ) (p : ℕ × ℕ) (hp : Valid p) :
    ∃ q q' : ℕ × ℕ, Valid q ∧ Valid q' ∧ 3 ≤ (address q).length ∧ 3 ≤ (address q').length ∧
      oddLeg q ≡ oddLeg p [MOD 2 ^ k] ∧ oddLeg q' ≡ oddLeg p [MOD 2 ^ k] ∧
      ¬ (letterAt q 2 = .A ↔ letterAt q' 2 = .A) := by
  obtain ⟨a, b, ha, hb, hlegs, hcong, hla, hlb, -, -, hsplit⟩ :=
    pos2_split_in_every_class k (oddLeg p) (oddLeg_odd p hp)
  exact ⟨a, b, ha, hb, hla, hlb, hcong, by rw [← hlegs]; exact hcong, hsplit⟩

/-! ## The visible half: exactly two clicks, and the `mod 8` bijection -/

/-- **Two clicks are visible.**  The `A`-nesses at positions `0` and `1` are computed by
explicit functions of `N mod 8`. -/
theorem two_clicks_visible :
    ∃ f g : ℕ → Bool, ∀ p : ℕ × ℕ, Valid p →
      ((letterAt p 0 = .A ↔ f (oddLeg p % 8) = true) ∧
       (letterAt p 1 = .A ↔ g (oddLeg p % 8) = true)) := by
  refine ⟨fun x => decide (x = 1 ∨ x = 5), fun x => decide (x = 1 ∨ x = 3), ?_⟩
  intro p hp
  have hodd := oddLeg_odd p hp
  constructor
  · rw [letterAt_zero_A_iff p hp]
    simp only [decide_eq_true_eq]
    omega
  · rw [letterAt_one_A_iff p hp]
    simp only [decide_eq_true_eq]

/-- **The `mod 8` dictionary.**  `N mod 8` and the pair of `A`-nesses at positions `0`
and `1` determine each other. -/
theorem pos01_bijection_mod8 (p : ℕ × ℕ) (hp : Valid p) :
    (oddLeg p % 8 = 1 ↔ (letterAt p 0 = .A ∧ letterAt p 1 = .A)) ∧
    (oddLeg p % 8 = 5 ↔ (letterAt p 0 = .A ∧ letterAt p 1 ≠ .A)) ∧
    (oddLeg p % 8 = 3 ↔ (letterAt p 0 ≠ .A ∧ letterAt p 1 = .A)) ∧
    (oddLeg p % 8 = 7 ↔ (letterAt p 0 ≠ .A ∧ letterAt p 1 ≠ .A)) := by
  have hodd := oddLeg_odd p hp
  have h0 := letterAt_zero_A_iff p hp
  have h1 := letterAt_one_A_iff p hp
  refine ⟨?_, ?_, ?_, ?_⟩ <;> constructor <;> intro h
  · exact ⟨h0.mpr (by omega), h1.mpr (by omega)⟩
  · have ha := h0.mp h.1
    have hb := h1.mp h.2
    omega
  · exact ⟨h0.mpr (by omega), fun hc => by have := h1.mp hc; omega⟩
  · have ha := h0.mp h.1
    have hb : ¬ (oddLeg p % 8 = 1 ∨ oddLeg p % 8 = 3) := fun hc => h.2 (h1.mpr hc)
    omega
  · exact ⟨fun hc => by have := h0.mp hc; omega, h1.mpr (by omega)⟩
  · have ha : oddLeg p % 4 ≠ 1 := fun hc => h.1 (h0.mpr hc)
    have hb := h1.mp h.2
    omega
  · exact ⟨fun hc => by have := h0.mp hc; omega, fun hc => by have := h1.mp hc; omega⟩
  · have ha : oddLeg p % 4 ≠ 1 := fun hc => h.1 (h0.mpr hc)
    have hb : ¬ (oddLeg p % 8 = 1 ∨ oddLeg p % 8 = 3) := fun hc => h.2 (h1.mpr hc)
    omega

/-- **The capacity of the 2-adic dial is exactly two clicks.**  Inside any 2-adic cell
`N ≡ r (mod 2^(k+3))`, however deep, the `A`-nesses at positions `0` and `1` are constant
(they are read off `r mod 8`), while the `A`-ness at position `2` still takes both values.
Refining the modulus past `8` therefore adds no information about the address. -/
theorem twoAdic_capacity_exactly_two (k r : ℕ) (hr : r % 2 = 1) :
    (∃ b₀ b₁ : Bool, ∀ p : ℕ × ℕ, Valid p → oddLeg p ≡ r [MOD 2 ^ (k + 3)] →
        decide (letterAt p 0 = .A) = b₀ ∧ decide (letterAt p 1 = .A) = b₁) ∧
    (∃ p q : ℕ × ℕ, Valid p ∧ Valid q ∧
        oddLeg p ≡ r [MOD 2 ^ (k + 3)] ∧ oddLeg q ≡ r [MOD 2 ^ (k + 3)] ∧
        3 ≤ (address p).length ∧ 3 ≤ (address q).length ∧
        ¬ (letterAt p 2 = .A ↔ letterAt q 2 = .A)) := by
  constructor
  · refine ⟨decide (r % 8 = 1 ∨ r % 8 = 5), decide (r % 8 = 1 ∨ r % 8 = 3), ?_⟩
    intro p hp hcong
    have h8 : (2 : ℕ) ^ 3 ∣ 2 ^ (k + 3) := pow_dvd_pow 2 (by omega)
    have hmod : oddLeg p % 8 = r % 8 := by
      have := Nat.ModEq.of_dvd h8 hcong
      simpa using this
    have hodd := oddLeg_odd p hp
    constructor
    · rw [decide_eq_decide, letterAt_zero_A_iff p hp]
      omega
    · rw [decide_eq_decide, letterAt_one_A_iff p hp]
      omega
  · obtain ⟨p, q, hp, hq, hlegs, hcong, hlp, hlq, -, -, hsplit⟩ :=
      pos2_split_in_every_class (k + 3) r hr
    exact ⟨p, q, hp, hq, hcong, by rw [← hlegs]; exact hcong, hlp, hlq, hsplit⟩

/-- **The dictionary is onto.**  All four combinations of `A`-nesses at positions `0,1`
really occur at nodes of depth at least `3`; with `pos01_bijection_mod8` this makes the
first two `A`-nesses a genuine bijection with `N mod 8 ∈ {1,3,5,7}`. -/
theorem pos01_attained (b₀ b₁ : Bool) :
    ∃ p : ℕ × ℕ, Valid p ∧ 3 ≤ (address p).length ∧
      decide (letterAt p 0 = .A) = b₀ ∧ decide (letterAt p 1 = .A) = b₁ := by
  have key : ∀ p : ℕ × ℕ, Valid p → 27 < p.1 + p.2 → 3 ≤ (address p).length :=
    fun p hp h => three_le_length_address p hp h
  cases b₀ <;> cases b₁
  · exact ⟨(28, 3), by decide, key _ (by decide) (by norm_num), by decide, by decide⟩
  · exact ⟨(26, 3), by decide, key _ (by decide) (by norm_num), by decide, by decide⟩
  · exact ⟨(27, 2), by decide, key _ (by decide) (by norm_num), by decide, by decide⟩
  · exact ⟨(17, 16), by decide, key _ (by decide) (by norm_num), by decide, by decide⟩

end Price2Adic