import Cryptography.Price2Adic.Tree

/-!
# The Price alphabet is a 2-adic dial — exactly two letters deep

The Price moves double a parameter, so one expects the address of a node to be readable
from the 2-adic expansion of its triple.  This file makes that precise **and** locates
the exact point where the 2-adic reading stops.

Write `N = oddLeg (m,n) = m² - n²` for the odd leg of the triple of a node, and read a
Price address from the leaf backwards (position `0` = last letter).

* `oddLeg_odd` — `N` is always odd: **the modulus `2` is vacuous**, no information.
* `letter_pos0_iff` — position `0` is `A` **iff** `N ≡ 1 (mod 4)` (and `B`/`C` iff
  `N ≡ 3 (mod 4)`).  A single bit of `N mod 4` determines the last letter.
* `letter_pos1_iff` — position `1` is `A` **iff** `N mod 8 ∈ {1,3}`.  A second bit,
  living in `N mod 8`, determines the previous letter.
* `letter_pos0_pos1_table` — the full `N mod 8` dictionary of the last two letters.
* `twoAdic_blind_BC` — **sharpness**: the `B`/`C` distinction is 2-adically invisible.
  For *every* `k` there are two Price nodes, one a `B`-child and one a `C`-child, whose
  three triple entries agree modulo `2^k`.  Consequently no function of any 2-adic
  residue of the triple can separate `B` from `C`.

So the halving alphabet is a *residue dial of exactly two symbols*: `N mod 8` reads two
letters and nothing more, and the residual ternary choice is invisible at `2`.  This is
the complement of the Berggren picture, whose moves are 3-adic.

## Lab notes (round 70, exp 548)

BFS to depth `8` (`9841` nodes).  For `j = 1, 2` (positions counted from the leaf) the
predicate "letter at position `j` is `A`" is a function of `N mod 2^(j+1)` — a perfect
classifier, and `2^(j+1)` is the smallest such modulus.  For `j = 3, 4, 5` no modulus
`2^k` with `k ≤ 10` classifies: some class always splits.
Tabulated dictionary at `N mod 16` (letters read from the leaf):
`1,9 ↦ AA`, `3,11 ↦ A{B,C}`, `5,13 ↦ {B,C}A`, `7,15 ↦ {B,C}{B,C}`.
`twoAdic_blind_BC` explains the `j ≥ 3` failure at its source: the residual `B`/`C` bit
never enters the 2-adic filtration at all.
-/

namespace Price2Adic

/-! ## The odd leg -/

theorem oddLeg_eq (m n : ℕ) : oddLeg (m, n) = m ^ 2 - n ^ 2 := rfl

/-- `N = m² - n²` is odd for every primitive parameter pair: the modulus `2` carries no
information about the Price address. -/
theorem oddLeg_odd (p : ℕ × ℕ) (hp : Valid p) : oddLeg p % 2 = 1 := by
  obtain ⟨m, n⟩ := p
  obtain ⟨hn, hlt, -, hpar⟩ := hp
  have hle : n ^ 2 ≤ m ^ 2 := Nat.pow_le_pow_left hlt.le 2
  have key : oddLeg (m, n) + n ^ 2 = m ^ 2 := by
    simp only [oddLeg_eq]; omega
  rcases Nat.even_or_odd m with hm | hm
  · -- m even, n odd
    obtain ⟨s, hs⟩ := hm
    have hn2 : n % 2 = 1 := by omega
    obtain ⟨t, ht⟩ : ∃ t, n = 2 * t + 1 := ⟨n / 2, by omega⟩
    have h1 : m ^ 2 = 4 * (s * s) := by subst hs; ring
    have h2 : n ^ 2 = 4 * (t * t + t) + 1 := by subst ht; ring
    omega
  · obtain ⟨s, hs⟩ := hm
    have hn2 : n % 2 = 0 := by omega
    obtain ⟨t, ht⟩ : ∃ t, n = 2 * t := ⟨n / 2, by omega⟩
    have h1 : m ^ 2 = 4 * (s * s + s) + 1 := by subst hs; ring
    have h2 : n ^ 2 = 4 * (t * t) := by subst ht; ring
    omega

/-! ## Position 0: the modulus 4 -/

theorem letterOf_eq_A_iff (p : ℕ × ℕ) : letterOf p = .A ↔ p.2 % 2 = 0 := by
  obtain ⟨m, n⟩ := p
  simp only [letterOf]
  split_ifs with h1 h2 <;> simp_all

theorem letterOf_pair_eq_A_iff (m n : ℕ) : letterOf (m, n) = .A ↔ n % 2 = 0 :=
  letterOf_eq_A_iff (m, n)

theorem letterOf_pair_ne_A_iff (m n : ℕ) : letterOf (m, n) ≠ .A ↔ n % 2 = 1 := by
  rw [ne_eq, letterOf_pair_eq_A_iff]
  omega

/-- **Position 0 law.** The last letter of the Price address of a node is `A` exactly
when its odd leg is `1 mod 4`; it is `B` or `C` exactly when the odd leg is `3 mod 4`. -/
theorem oddLeg_mod_four (p : ℕ × ℕ) (hp : Valid p) :
    (letterOf p = .A ∧ oddLeg p % 4 = 1) ∨ (letterOf p ≠ .A ∧ oddLeg p % 4 = 3) := by
  obtain ⟨m, n⟩ := p
  obtain ⟨hn, hlt, -, hpar⟩ := hp
  have hle : n ^ 2 ≤ m ^ 2 := Nat.pow_le_pow_left hlt.le 2
  have key : oddLeg (m, n) + n ^ 2 = m ^ 2 := by simp only [oddLeg_eq]; omega
  rcases Nat.even_or_odd n with hne | hno
  · left
    obtain ⟨t, ht⟩ := hne
    obtain ⟨s, hs⟩ : ∃ s, m = 2 * s + 1 := ⟨m / 2, by omega⟩
    have h1 : m ^ 2 = 4 * (s * s + s) + 1 := by subst hs; ring
    have h2 : n ^ 2 = 4 * (t * t) := by subst ht; ring
    exact ⟨(letterOf_eq_A_iff (m, n)).mpr (by simp only; omega), by omega⟩
  · right
    obtain ⟨t, ht⟩ := hno
    obtain ⟨s, hs⟩ : ∃ s, m = 2 * s := ⟨m / 2, by omega⟩
    have h1 : m ^ 2 = 4 * (s * s) := by subst hs; ring
    have h2 : n ^ 2 = 4 * (t * t + t) + 1 := by subst ht; ring
    refine ⟨fun hA => ?_, by omega⟩
    have := (letterOf_eq_A_iff (m, n)).mp hA
    simp only at this
    omega

theorem letterOf_eq_A_iff_oddLeg (p : ℕ × ℕ) (hp : Valid p) :
    letterOf p = .A ↔ oddLeg p % 4 = 1 := by
  rcases oddLeg_mod_four p hp with ⟨h1, h2⟩ | ⟨h1, h2⟩
  · simp [h1, h2]
  · constructor
    · intro h; exact absurd h h1
    · intro h; omega

/-- Read from the leaf, position `0` of the address of `eval (w ++ [l])` is `l`, and it is
`A` exactly when the odd leg is `1 mod 4`. -/
theorem letter_pos0_iff (w : PriceWord) (l : PriceLetter) :
    l = .A ↔ oddLeg (eval (w ++ [l])) % 4 = 1 := by
  have hv : Valid (eval (w ++ [l])) := Valid_eval _
  have hl : letterOf (eval (w ++ [l])) = l := by
    rw [eval_append_one]; exact letterOf_step l _ (Valid_eval w)
  have h := letterOf_eq_A_iff_oddLeg _ hv
  rwa [hl] at h

/-! ## Position 1: the modulus 8 -/

/-- **Position 1 law.** The letter one step above the leaf is `A` exactly when the odd leg
of the leaf lies in `{1, 3} mod 8`. -/
theorem letterOf_parent_eq_A_iff (p : ℕ × ℕ) (hp : Valid p) :
    letterOf (parent p) = .A ↔ (oddLeg p % 8 = 1 ∨ oddLeg p % 8 = 3) := by
  obtain ⟨m, n⟩ := p
  obtain ⟨hn, hlt, -, hpar⟩ := hp
  have hle : n ^ 2 ≤ m ^ 2 := Nat.pow_le_pow_left hlt.le 2
  have key : oddLeg (m, n) + n ^ 2 = m ^ 2 := by simp only [oddLeg_eq]; omega
  rcases Nat.even_or_odd n with hne | hno
  · -- `n` even, `m` odd; parent is `(m - n/2, n/2)`, an `A`-child iff `4 ∣ n`
    obtain ⟨t, ht⟩ := hne
    obtain ⟨s, hs⟩ : ∃ s, m = 2 * s + 1 := ⟨m / 2, by omega⟩
    have hm2 : m ^ 2 = 8 * (s * (s + 1) / 2) + 1 := by
      have hev : 2 ∣ s * (s + 1) := (Nat.even_mul_succ_self s).two_dvd
      obtain ⟨u, hu⟩ := hev
      subst hs
      rw [hu]
      have : (2 * u) / 2 = u := by omega
      rw [this]
      nlinarith [hu]
    have hpar' : parent (m, n) = (m - n / 2, n / 2) := by
      simp only [parent]; rw [if_pos (by omega)]
    rw [hpar', letterOf_eq_A_iff]
    simp only
    rcases Nat.even_or_odd t with hte | hto
    · obtain ⟨r, hr⟩ := hte
      have hn2 : n ^ 2 = 16 * (r * r) := by subst ht; subst hr; ring
      constructor
      · intro _; left; omega
      · intro _; omega
    · obtain ⟨r, hr⟩ := hto
      have hn2 : n ^ 2 = 8 * (2 * (r * r + r)) + 4 := by subst ht; subst hr; ring
      constructor
      · intro h; omega
      · intro h; omega
  · -- `n` odd, `m` even; parent is `(m/2, ·)`, an `A`-child iff `m/2` is odd
    obtain ⟨t, ht⟩ := hno
    obtain ⟨s, hs⟩ : ∃ s, m = 2 * s := ⟨m / 2, by omega⟩
    have hn2 : n ^ 2 = 8 * ((t * (t + 1)) / 2) + 1 := by
      have hev : 2 ∣ t * (t + 1) := (Nat.even_mul_succ_self t).two_dvd
      obtain ⟨u, hu⟩ := hev
      subst ht
      rw [hu]
      have : (2 * u) / 2 = u := by omega
      rw [this]
      nlinarith [hu]
    have hms : m / 2 = s := by omega
    have hpar' : (parent (m, n) = (m / 2, m / 2 - n) ∧ 2 * n < m) ∨
        (parent (m, n) = (m / 2, n - m / 2) ∧ m ≤ 2 * n) := by
      simp only [parent]
      rw [if_neg (by omega)]
      by_cases h : 2 * n < m
      · exact Or.inl ⟨by rw [if_pos h], h⟩
      · exact Or.inr ⟨by rw [if_neg h], by omega⟩
    rcases Nat.even_or_odd s with hse | hso
    · -- `m/2` even: the parent is a `B`/`C`-child and `N ≡ 7 mod 8`
      obtain ⟨r, hr⟩ := hse
      have hm2 : m ^ 2 = 8 * (2 * (r * r)) := by subst hs; subst hr; ring
      have hNval : oddLeg (m, n) % 8 = 7 := by omega
      have : letterOf (parent (m, n)) ≠ .A := by
        rcases hpar' with ⟨h, hbc⟩ | ⟨h, hbc⟩ <;> rw [h, letterOf_pair_ne_A_iff] <;> omega
      constructor
      · intro h; exact absurd h this
      · intro h; omega
    · -- `m/2` odd: the parent is an `A`-child and `N ≡ 3 mod 8`
      obtain ⟨r, hr⟩ := hso
      have hm2 : m ^ 2 = 8 * (2 * (r * r + r)) + 4 := by subst hs; subst hr; ring
      have hNval : oddLeg (m, n) % 8 = 3 := by omega
      have : letterOf (parent (m, n)) = .A := by
        rcases hpar' with ⟨h, hbc⟩ | ⟨h, hbc⟩ <;> rw [h, letterOf_pair_eq_A_iff] <;> omega
      simp [this, hNval]

/-- Read from the leaf, position `1` of the address of `eval (w ++ [l₁, l₂])` is `l₁`,
and it is `A` exactly when the odd leg of the leaf lies in `{1,3} mod 8`. -/
theorem letter_pos1_iff (w : PriceWord) (l₁ l₂ : PriceLetter) :
    l₁ = .A ↔ (oddLeg (eval (w ++ [l₁, l₂])) % 8 = 1 ∨
      oddLeg (eval (w ++ [l₁, l₂])) % 8 = 3) := by
  have hw1 : Valid (eval (w ++ [l₁])) := Valid_eval _
  have hnode : eval (w ++ [l₁, l₂]) = step l₂ (eval (w ++ [l₁])) := by
    have : w ++ [l₁, l₂] = (w ++ [l₁]) ++ [l₂] := by simp
    rw [this, eval_append_one]
  have hpar : parent (eval (w ++ [l₁, l₂])) = eval (w ++ [l₁]) := by
    rw [hnode]; exact parent_step l₂ _ hw1
  have hl : letterOf (eval (w ++ [l₁])) = l₁ := by
    rw [eval_append_one]; exact letterOf_step l₁ _ (Valid_eval w)
  have h := letterOf_parent_eq_A_iff (eval (w ++ [l₁, l₂])) (Valid_eval _)
  rw [hpar, hl] at h
  exact h

/-- The two-letter dictionary at the leaf: `N mod 8` determines the pair
(position 1 is `A`?, position 0 is `A`?) — and nothing finer, by `twoAdic_blind_BC`. -/
theorem letter_pos0_pos1_table (w : PriceWord) (l₁ l₂ : PriceLetter) :
    (oddLeg (eval (w ++ [l₁, l₂])) % 8 = 1 ↔ (l₁ = .A ∧ l₂ = .A)) ∧
    (oddLeg (eval (w ++ [l₁, l₂])) % 8 = 3 ↔ (l₁ = .A ∧ l₂ ≠ .A)) ∧
    (oddLeg (eval (w ++ [l₁, l₂])) % 8 = 5 ↔ (l₁ ≠ .A ∧ l₂ = .A)) ∧
    (oddLeg (eval (w ++ [l₁, l₂])) % 8 = 7 ↔ (l₁ ≠ .A ∧ l₂ ≠ .A)) := by
  have hnode : w ++ [l₁, l₂] = (w ++ [l₁]) ++ [l₂] := by simp
  have h0 : l₂ = .A ↔ oddLeg (eval (w ++ [l₁, l₂])) % 8 % 4 = 1 := by
    rw [hnode] at *
    have := letter_pos0_iff (w ++ [l₁]) l₂
    rw [this]
    constructor
    · intro h; omega
    · intro h; omega
  have h1 := letter_pos1_iff w l₁ l₂
  have hodd : oddLeg (eval (w ++ [l₁, l₂])) % 2 = 1 :=
    oddLeg_odd _ (Valid_eval _)
  set N := oddLeg (eval (w ++ [l₁, l₂])) % 8 with hN
  have hNlt : N < 8 := by omega
  have hNodd : N % 2 = 1 := by omega
  refine ⟨?_, ?_, ?_, ?_⟩ <;> constructor <;> intro h
  · exact ⟨h1.mpr (Or.inl h), h0.mpr (by omega)⟩
  · have ha := h1.mp h.1
    have hb : N % 4 = 1 := by have := h0.mp h.2; omega
    omega
  · exact ⟨h1.mpr (Or.inr h), fun hc => by have := h0.mp hc; omega⟩
  · have ha := h1.mp h.1
    have hb : N % 4 ≠ 1 := fun hc => h.2 (h0.mpr (by omega))
    omega
  · refine ⟨fun hc => ?_, h0.mpr (by omega)⟩
    have := h1.mp hc
    omega
  · have ha : ¬ (N = 1 ∨ N = 3) := fun hc => h.1 (h1.mpr hc)
    have hb : N % 4 = 1 := by have := h0.mp h.2; omega
    omega
  · refine ⟨fun hc => by have := h1.mp hc; omega, fun hc => by have := h0.mp hc; omega⟩
  · have ha : ¬ (N = 1 ∨ N = 3) := fun hc => h.1 (h1.mpr hc)
    have hb : N % 4 ≠ 1 := fun hc => h.2 (h0.mpr (by omega))
    omega

/-! ## Sharpness: `B` versus `C` is 2-adically invisible -/

theorem oddLeg_step_B (p : ℕ × ℕ) (hp : Valid p) :
    oddLeg (step .B p) = oddLeg (step .C p) + 4 * p.1 * p.2 := by
  obtain ⟨m, n⟩ := p
  obtain ⟨hn, hlt, -, -⟩ := hp
  have h1 : (m - n) ^ 2 ≤ (2 * m) ^ 2 := Nat.pow_le_pow_left (by omega) 2
  have h2 : (m + n) ^ 2 ≤ (2 * m) ^ 2 := Nat.pow_le_pow_left (by omega) 2
  simp only [step, oddLeg_eq]
  zify [h1, h2, hlt.le]
  ring

theorem hyp_step_C (p : ℕ × ℕ) (hp : Valid p) :
    (triple (step .C p)).2.2 = (triple (step .B p)).2.2 + 4 * p.1 * p.2 := by
  obtain ⟨m, n⟩ := p
  obtain ⟨hn, hlt, -, -⟩ := hp
  simp only [step, triple]
  zify [hlt.le]
  ring

theorem evenLeg_step_C (p : ℕ × ℕ) (hp : Valid p) :
    (triple (step .C p)).2.1 = (triple (step .B p)).2.1 + 8 * p.1 * p.2 := by
  obtain ⟨m, n⟩ := p
  obtain ⟨hn, hlt, -, -⟩ := hp
  simp only [step, triple]
  zify [hlt.le]
  ring

/-- **Sharpness of the 2-adic reading.**  For every `k` there is a `B`-child and a
`C`-child of the Price tree whose three triple entries agree modulo `2^k`.  Hence no
function of the 2-adic residues of a triple can decide the `B`/`C` letter: the halving
alphabet is a residue dial of exactly two symbols (`A` versus not-`A`, twice). -/
theorem twoAdic_blind_BC (k : ℕ) :
    ∃ p q : ℕ × ℕ, Valid p ∧ Valid q ∧ letterOf p = .B ∧ letterOf q = .C ∧
      (triple p).1 % 2 ^ k = (triple q).1 % 2 ^ k ∧
      (triple p).2.1 % 2 ^ k = (triple q).2.1 % 2 ^ k ∧
      (triple p).2.2 % 2 ^ k = (triple q).2.2 % 2 ^ k := by
  set r : ℕ × ℕ := (2 ^ k + 1, 2 ^ k) with hr
  have hpos : 0 < 2 ^ k := Nat.pow_pos (by norm_num)
  have hrv : Valid r := by
    refine ⟨by simp [hpos], by simp, ?_, ?_⟩
    · show Nat.gcd (2 ^ k + 1) (2 ^ k) = 1
      simp [Nat.gcd_comm]
    · show (2 ^ k + 1 + 2 ^ k) % 2 = 1
      have : (2 : ℕ) ∣ 2 ^ k + 2 ^ k := ⟨2 ^ k, by ring⟩
      omega
  refine ⟨step .B r, step .C r, Valid_step _ _ hrv, Valid_step _ _ hrv,
    letterOf_step _ _ hrv, letterOf_step _ _ hrv, ?_, ?_, ?_⟩
  · have h := oddLeg_step_B r hrv
    have hd : 4 * r.1 * r.2 = 2 ^ k * (4 * r.1) := by simp only [hr]; ring
    have hA : (triple (step .B r)).1 = oddLeg (step .B r) := by
      obtain ⟨a, b⟩ := step .B r; rfl
    have hC : (triple (step .C r)).1 = oddLeg (step .C r) := by
      obtain ⟨a, b⟩ := step .C r; rfl
    rw [hA, hC, h, hd, Nat.add_mul_mod_self_left]
  · have h := evenLeg_step_C r hrv
    have hd : 8 * r.1 * r.2 = 2 ^ k * (8 * r.1) := by simp only [hr]; ring
    rw [h, hd, Nat.add_mul_mod_self_left]
  · have h := hyp_step_C r hrv
    have hd : 4 * r.1 * r.2 = 2 ^ k * (4 * r.1) := by simp only [hr]; ring
    rw [h, hd, Nat.add_mul_mod_self_left]

end Price2Adic