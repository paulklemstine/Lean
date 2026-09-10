/-
# A Fibonacci family with Singmaster multiplicity at least six

The only *infinite* family of integers known to occur many times in Pascal's triangle
comes from the row-shift equation

`C(N, k) = C(N-1, k+1)`,

whose solutions are governed by the Fibonacci numbers.  This file gives a complete,
self-contained formal proof.

* `Singmaster.choose_row_shift` — the exact arithmetic criterion
  `(M+1)(k+1) = (M+1-k)(M-k)` for `C(M+1,k) = C(M,k+1)`, proved from the two
  multiplicative recurrences of `Nat.choose` by cancellation.
* `Singmaster.six_le_mult_of_shift_eq` — a row-shift solution produces four distinct
  interior occurrences, hence multiplicity at least six.
* `Singmaster.fib_cassini_even` — the even-index Cassini identity
  `F(2i+1)² = F(2i)F(2i+1) + F(2i)² + 1`, proved by induction.
* `Singmaster.six_le_mult_of_cassini` — *any* Cassini pair `(a,b)` (not just a
  Fibonacci one) yields a number of multiplicity at least six.
* `Singmaster.six_le_mult_fib` — for every `i ≥ 1`, with `N = F(2i+2)F(2i+3)` and
  `k = F(2i)F(2i+3)`, the number `C(N,k)` occurs at least six times.
  The case `i = 1` is `N = 15`, `k = 5`, `C(15,5) = 3003`.
* `Singmaster.infinite_six_le_mult` — consequently infinitely many integers occur
  at least six times in Pascal's triangle.
-/
import NumberTheory.SingmasterCore

namespace Singmaster

open Finset

/-! ## The row-shift criterion -/

/-- `C(M+1,k) = C(M,k+1)` holds exactly when `(M+1)(k+1) = (M+1-k)(M-k)`.
This is the "shift one row up, one column right" equation. -/
theorem choose_row_shift {M k : ℕ} (hk : k ≤ M)
    (h : (M + 1) * (k + 1) = (M + 1 - k) * (M - k)) :
    (M + 1).choose k = M.choose (k + 1) := by
  have hpos : 0 < (M + 1 - k) * (k + 1) := Nat.mul_pos (by omega) (by omega)
  refine Nat.eq_of_mul_eq_mul_right hpos ?_
  have h1 := Nat.choose_mul_succ_eq M k
  have h2 := Nat.choose_succ_right_eq M k
  calc (M + 1).choose k * ((M + 1 - k) * (k + 1))
      = ((M + 1).choose k * (M + 1 - k)) * (k + 1) := by ring
    _ = (M.choose k * (M + 1)) * (k + 1) := by rw [← h1]
    _ = M.choose k * ((M + 1) * (k + 1)) := by ring
    _ = M.choose k * ((M + 1 - k) * (M - k)) := by rw [h]
    _ = (M.choose k * (M - k)) * (M + 1 - k) := by ring
    _ = (M.choose (k + 1) * (k + 1)) * (M + 1 - k) := by rw [← h2]
    _ = M.choose (k + 1) * ((M + 1 - k) * (k + 1)) := by ring

/-! ## Four interior occurrences from a row-shift solution -/

/-- A solution of the row-shift equation yields four distinct interior occurrences of
`C(N,k)`, hence multiplicity at least `6`. -/
theorem six_le_mult_of_shift_eq {N k : ℕ} (h2 : 2 ≤ k) (h4 : k + 4 ≤ N)
    (hne1 : 2 * k ≠ N) (hne2 : 2 * k + 3 ≠ N)
    (hcond : N * (k + 1) = (N - k) * (N - k - 1)) : 6 ≤ mult (N.choose k) := by
  set n := N.choose k with hn
  have hshift : (N - 1).choose (k + 1) = n := by
    have hM : N - 1 + 1 = N := by omega
    have h := choose_row_shift (M := N - 1) (k := k) (by omega) (by
      rw [hM, show N - 1 - k = N - k - 1 from by omega]
      exact hcond)
    rw [hM] at h
    exact h.symm
  have hbig : 3 ≤ n := by
    have h3 := choose_le_choose_left (N := N) (j := 2) (k := k) h2 (by omega)
    have h4' := two_mul_choose_two N
    have : 6 * 5 ≤ N * (N - 1) := Nat.mul_le_mul (by omega) (by omega)
    omega
  have hn2 : 2 ≤ n := by omega
  have hm1 : ((N, k) : ℕ × ℕ) ∈ interiorOcc n := by
    rw [mem_interiorOcc hn2]; exact ⟨h2, by omega, rfl⟩
  have hm2 : ((N, N - k) : ℕ × ℕ) ∈ interiorOcc n := by
    rw [mem_interiorOcc hn2]
    exact ⟨by omega, by omega, Nat.choose_symm (by omega)⟩
  have hm3 : ((N - 1, k + 1) : ℕ × ℕ) ∈ interiorOcc n := by
    rw [mem_interiorOcc hn2]; exact ⟨by omega, by omega, hshift⟩
  have hm4 : ((N - 1, N - 2 - k) : ℕ × ℕ) ∈ interiorOcc n := by
    rw [mem_interiorOcc hn2]
    refine ⟨by omega, by omega, ?_⟩
    rw [show N - 2 - k = (N - 1) - (k + 1) from by omega, Nat.choose_symm (by omega)]
    exact hshift
  have hsub : ({(N, k), (N, N - k), (N - 1, k + 1), (N - 1, N - 2 - k)} : Finset (ℕ × ℕ))
      ⊆ interiorOcc n := by
    intro p hp
    simp only [Finset.mem_insert, Finset.mem_singleton] at hp
    rcases hp with rfl | rfl | rfl | rfl
    exacts [hm1, hm2, hm3, hm4]
  have hcard : ({(N, k), (N, N - k), (N - 1, k + 1), (N - 1, N - 2 - k)} : Finset (ℕ × ℕ)).card
      = 4 := by
    rw [Finset.card_insert_of_notMem (by simp [Prod.ext_iff]; omega),
      Finset.card_insert_of_notMem (by simp [Prod.ext_iff]; omega),
      Finset.card_insert_of_notMem (by simp [Prod.ext_iff]; omega),
      Finset.card_singleton]
  have h4card : 4 ≤ (interiorOcc n).card := by
    have := Finset.card_le_card hsub
    omega
  rw [mult_eq_two_add_interior hbig]
  omega

/-! ## Cassini pairs -/

/-- Auxiliary cancellation lemma for the nat-subtraction in the row-shift equation. -/
theorem eq_mul_pred_of_add_eq {X Z : ℕ} (hX : 1 ≤ X) (h : Z + X = X * X) :
    Z = X * (X - 1) := by
  obtain ⟨Y, rfl⟩ : ∃ Y, X = Y + 1 := ⟨X - 1, by omega⟩
  simp only [Nat.add_sub_cancel]
  nlinarith

/-- **Cassini pairs give multiplicity `≥ 6`.**  If `b² = ab + a² + 1` (with `a ≥ 1` and
`a < b`) then `C((a+b)(a+2b), a(a+2b))` occurs at least six times in Pascal's triangle. -/
theorem six_le_mult_of_cassini {a b : ℕ} (ha : 1 ≤ a) (hab : a < b)
    (hcass : b * b = a * b + a * a + 1) :
    6 ≤ mult (((a + b) * (a + 2 * b)).choose (a * (a + 2 * b))) := by
  have hd5 : 5 ≤ a + 2 * b := by omega
  -- the key polynomial identity, obtained from Cassini by one substitution
  have hk1 : (a + b) * (a * (a + 2 * b) + 1) + b = b * b * (a + 2 * b) := by
    rw [hcass]; ring
  have hsplit : (a + b) * (a + 2 * b) = a * (a + 2 * b) + b * (a + 2 * b) := by ring
  have hX5 : 5 ≤ b * (a + 2 * b) := by nlinarith
  have hsub1 : (a + b) * (a + 2 * b) - a * (a + 2 * b) = b * (a + 2 * b) := by
    rw [hsplit, Nat.add_sub_cancel_left]
  have hsum : ((a + b) * (a + 2 * b)) * (a * (a + 2 * b) + 1) + b * (a + 2 * b)
      = (b * (a + 2 * b)) * (b * (a + 2 * b)) := by
    calc ((a + b) * (a + 2 * b)) * (a * (a + 2 * b) + 1) + b * (a + 2 * b)
        = ((a + b) * (a * (a + 2 * b) + 1) + b) * (a + 2 * b) := by ring
      _ = (b * b * (a + 2 * b)) * (a + 2 * b) := by rw [hk1]
      _ = (b * (a + 2 * b)) * (b * (a + 2 * b)) := by ring
  refine six_le_mult_of_shift_eq (N := (a + b) * (a + 2 * b)) (k := a * (a + 2 * b))
    (by nlinarith) (by nlinarith) (by nlinarith) (by nlinarith) ?_
  rw [hsub1]
  exact eq_mul_pred_of_add_eq (by omega) hsum

/-! ## The even-index Cassini identity -/

/-- `F(2i+1)² = F(2i)·F(2i+1) + F(2i)² + 1` for all `i`. -/
theorem fib_cassini_even (i : ℕ) :
    Nat.fib (2 * i + 1) * Nat.fib (2 * i + 1)
      = Nat.fib (2 * i) * Nat.fib (2 * i + 1) + Nat.fib (2 * i) * Nat.fib (2 * i) + 1 := by
  induction i with
  | zero => decide
  | succ m ih =>
    have hA : Nat.fib (2 * m + 2) = Nat.fib (2 * m) + Nat.fib (2 * m + 1) := Nat.fib_add_two
    have hB : Nat.fib (2 * m + 3) = Nat.fib (2 * m + 1) + Nat.fib (2 * m + 2) := by
      rw [show 2 * m + 3 = (2 * m + 1) + 2 from by ring, Nat.fib_add_two,
        show 2 * m + 1 + 1 = 2 * m + 2 from by ring]
    rw [show 2 * (m + 1) = 2 * m + 2 from by ring, show 2 * m + 2 + 1 = 2 * m + 3 from by ring,
      hB, hA]
    nlinarith [ih]

/-! ## The Fibonacci family -/

/-- Row index of the `i`-th Singmaster–Fibonacci coincidence. -/
def fibRow (i : ℕ) : ℕ := Nat.fib (2 * i + 2) * Nat.fib (2 * i + 3)

/-- Column index of the `i`-th Singmaster–Fibonacci coincidence. -/
def fibCol (i : ℕ) : ℕ := Nat.fib (2 * i) * Nat.fib (2 * i + 3)

/-- The `i`-th Singmaster–Fibonacci value. -/
def fibVal (i : ℕ) : ℕ := (fibRow i).choose (fibCol i)

/-- Sanity check: the first member of the family is the famous `3003 = C(15,5)`. -/
theorem fibVal_one : fibVal 1 = 3003 := by decide

theorem one_le_fib_even {i : ℕ} (hi : 1 ≤ i) : 1 ≤ Nat.fib (2 * i) := by
  have : Nat.fib 2 ≤ Nat.fib (2 * i) := Nat.fib_mono (by omega)
  simpa using this

theorem fib_lt_fib_even {i : ℕ} (hi : 1 ≤ i) : Nat.fib (2 * i) < Nat.fib (2 * i + 1) :=
  Nat.fib_lt_fib_succ (by omega)

theorem fib_two_add {i : ℕ} : Nat.fib (2 * i + 2) = Nat.fib (2 * i) + Nat.fib (2 * i + 1) :=
  Nat.fib_add_two

theorem fib_three_add {i : ℕ} :
    Nat.fib (2 * i + 3) = Nat.fib (2 * i) + 2 * Nat.fib (2 * i + 1) := by
  have hB : Nat.fib (2 * i + 3) = Nat.fib (2 * i + 1) + Nat.fib (2 * i + 2) := by
    rw [show 2 * i + 3 = (2 * i + 1) + 2 from by ring, Nat.fib_add_two,
      show 2 * i + 1 + 1 = 2 * i + 2 from by ring]
  rw [hB, fib_two_add]; ring

/-- **The Singmaster–Fibonacci family.** For every `i ≥ 1` the binomial coefficient
`C(F(2i+2)·F(2i+3), F(2i)·F(2i+3))` occurs at least six times in Pascal's triangle. -/
theorem six_le_mult_fib {i : ℕ} (hi : 1 ≤ i) : 6 ≤ mult (fibVal i) := by
  have hmain := six_le_mult_of_cassini (a := Nat.fib (2 * i)) (b := Nat.fib (2 * i + 1))
    (one_le_fib_even hi) (fib_lt_fib_even hi) (fib_cassini_even i)
  rw [fibVal, fibRow, fibCol, fib_two_add, fib_three_add]
  exact hmain

/-- **Infinitely many integers occur at least six times in Pascal's triangle.** -/
theorem infinite_six_le_mult : {n : ℕ | 6 ≤ mult n}.Infinite := by
  apply Set.infinite_of_not_bddAbove
  rintro ⟨B, hB⟩
  have hi : 1 ≤ B + 1 := by omega
  have hmem : fibVal (B + 1) ∈ {n : ℕ | 6 ≤ mult n} := six_le_mult_fib hi
  have hle := hB hmem
  have hfib1 : 1 ≤ Nat.fib (2 * (B + 1)) := one_le_fib_even hi
  have hfib2 : 1 ≤ Nat.fib (2 * (B + 1) + 1) := by
    have : Nat.fib 2 ≤ Nat.fib (2 * (B + 1) + 1) := Nat.fib_mono (by omega)
    simpa using this
  have hfib3 : 2 * (B + 1) + 3 ≤ Nat.fib (2 * (B + 1) + 3) := Nat.le_fib_self (by omega)
  have hrow : Nat.fib (2 * (B + 1) + 3) ≤ fibRow (B + 1) := by
    rw [fibRow, fib_two_add]
    nlinarith
  have hcol1 : 1 ≤ fibCol (B + 1) := by
    rw [fibCol]
    have : 1 ≤ Nat.fib (2 * (B + 1) + 3) := by omega
    nlinarith
  have hcolN : 1 + fibCol (B + 1) ≤ fibRow (B + 1) := by
    rw [fibRow, fibCol, fib_two_add]
    have h3 : 1 ≤ Nat.fib (2 * (B + 1) + 3) := by omega
    nlinarith
  have hval : fibRow (B + 1) ≤ fibVal (B + 1) := self_le_choose hcol1 hcolN
  omega

/-! ## Rigidity: Cassini pairs are exactly the even-index Fibonacci pairs -/

/-- **Classification of Cassini pairs.**  Every solution of `b² = ab + a² + 1` with
`a ≤ b` is a consecutive pair of Fibonacci numbers at even/odd index.  The proof is a
Vieta-style descent `(a, b) ↦ (a - (b - a), b - a)`, which preserves the relation and
strictly decreases the first entry. -/
theorem cassini_classification :
    ∀ a b : ℕ, a ≤ b → b * b = a * b + a * a + 1 →
      ∃ i, a = Nat.fib (2 * i) ∧ b = Nat.fib (2 * i + 1) := by
  intro a
  induction a using Nat.strong_induction_on with
  | _ a ih =>
    intro b hab h
    obtain ⟨u, rfl⟩ : ∃ u, b = a + u := ⟨b - a, by omega⟩
    have hrel : a * u + u * u = a * a + 1 := by nlinarith
    rcases Nat.eq_zero_or_pos a with rfl | ha
    · have hu : u = 1 := by nlinarith
      subst hu
      exact ⟨0, by simp, by simp⟩
    · have hu : 1 ≤ u := by
        rcases Nat.eq_zero_or_pos u with rfl | h1
        · exfalso; nlinarith
        · exact h1
      have hua : u ≤ a := by nlinarith
      obtain ⟨w, hw⟩ : ∃ w, a = u + w := ⟨a - u, by omega⟩
      have hrel2 : u * u = w * u + w * w + 1 := by subst hw; nlinarith
      have hwu : w ≤ u := by nlinarith
      have hwa : w < a := by omega
      obtain ⟨i, hi1, hi2⟩ := ih w hwa u hwu hrel2
      have hA : a = Nat.fib (2 * i + 2) := by
        rw [hw, hi1, hi2, Nat.fib_add_two]; ring
      refine ⟨i + 1, ?_, ?_⟩
      · rw [hA, show 2 * (i + 1) = 2 * i + 2 from by ring]
      · rw [hA, hi2, show 2 * (i + 1) + 1 = (2 * i + 1) + 2 from by ring]
        have hR : Nat.fib (2 * i + 1 + 2) = Nat.fib (2 * i + 1) + Nat.fib (2 * i + 2) :=
          Nat.fib_add_two
        rw [hR]
        ring

/-- **Cassini rigidity.**  For `a ≤ b`, the relation `b² = ab + a² + 1` holds precisely
for the even-index Fibonacci pairs.  Hence `six_le_mult_of_cassini` is *exactly* as
general as `six_le_mult_fib`: the Fibonacci family is the only source of six-fold
coincidences obtainable from a one-row shift. -/
theorem cassini_iff {a b : ℕ} (hab : a ≤ b) :
    b * b = a * b + a * a + 1 ↔ ∃ i, a = Nat.fib (2 * i) ∧ b = Nat.fib (2 * i + 1) := by
  constructor
  · exact cassini_classification a b hab
  · rintro ⟨i, rfl, rfl⟩
    exact fib_cassini_even i

end Singmaster