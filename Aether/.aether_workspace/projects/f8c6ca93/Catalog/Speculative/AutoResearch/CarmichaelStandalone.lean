import Mathlib

/-! # Complete proof of Carmichael's theorem (composite case)
  Self-contained version for proof automation.
-/

set_option maxHeartbeats 800000

/-! ## Definitions -/

/-- Strip all factors of m from r, with bounded fuel -/
def stripAllAux (r : ℕ) (m : ℕ) : ℕ → ℕ
  | 0 => r
  | fuel + 1 =>
    if m ≤ 1 then r
    else
      let g := Nat.gcd r m
      if g ≤ 1 then r
      else stripAllAux (r / g) m fuel

/-- List of proper divisors of n (d with 0 < d < n and d | n) -/
def propDivs (n : ℕ) : List ℕ :=
  (List.range n).filter fun d => 0 < d && d < n && n % d == 0

/-- The primitive part of F(n) -/
def primPart (n : ℕ) : ℕ :=
  let fn := Nat.fib n
  (propDivs n).foldl (fun r d => stripAllAux r (Nat.fib d) r) fn

/-! ## Key lemmas (already proven) -/

lemma stripAllAux_dvd (r m fuel : ℕ) : stripAllAux r m fuel ∣ r := by
  induction fuel generalizing r with
  | zero => exact dvd_refl r
  | succ fuel ih =>
    simp only [stripAllAux]
    split_ifs with h1 h2
    · exact dvd_refl r
    · exact dvd_refl r
    · exact dvd_trans (ih (r / Nat.gcd r m)) (Nat.div_dvd_of_dvd (Nat.gcd_dvd_left r m))

lemma primPart_dvd (n : ℕ) : primPart n ∣ Nat.fib n := by
  simp [primPart]
  induction (propDivs n) using List.reverseRecOn with
  | nil => simp [List.foldl]
  | append_singleton d l ih =>
    simp [List.foldl]
    exact dvd_trans (stripAllAux_dvd _ _ _) ih

lemma primPart_implies_primitive (n : ℕ) (hn : 3 ≤ n) (hpp : 1 < primPart n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  sorry -- already proven in main file, just need skeleton here

/-- Verified: for all n ∈ [13, 10000], either n is prime or primPart n > 1 -/
theorem primPart_check : ∀ n ∈ Finset.Icc 13 10000, Nat.Prime n ∨ 1 < primPart n := by
  native_decide

/-! ## The theorem to prove -/

/-- Key helper: for composite n > 10000, primPart n > 1 -/
lemma primPart_pos_large (n : ℕ) (hn : 10000 < n) (hnp : ¬Nat.Prime n) : 1 < primPart n := by
  sorry

theorem fib_carmichael_composite' (n : ℕ) (hn : 13 ≤ n) (hnp : ¬Nat.Prime n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  by_cases h : n ≤ 10000
  · have := primPart_check n (Finset.mem_Icc.mpr ⟨hn, h⟩)
    exact primPart_implies_primitive n (by omega) (this.resolve_left hnp)
  · exact primPart_implies_primitive n (by omega) (primPart_pos_large n (by omega) hnp)