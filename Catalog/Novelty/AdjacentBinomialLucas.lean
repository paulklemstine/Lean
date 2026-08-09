/-
# Adjacent repetitions in Pascal's triangle are exactly the Lucas solutions

`Combinatorics.SingmasterFibonacci` exhibits the classical infinite family of numbers
occurring at least six times in Pascal's triangle.  It comes from the *adjacent
repetition* phenomenon: a value that reappears one row higher and one column to the
right,

`C(n,k) = C(n-1,k+1)`,

occupies six positions instead of the usual four.  The catalog proves that the
Fibonacci pairs `n = F_{2i+4}F_{2i+5}`, `k = F_{2i+2}F_{2i+5}` *are* such repetitions
(`Singmaster.fib_cross`, `Singmaster.choose_cross`).  This file proves the converse and
thereby **completely classifies** the adjacent repetitions.

## The three bridges

1. *Combinatorics → arithmetic.*  Clearing factorials shows
   `C(n,k) = C(n-1,k+1) ↔ n(k+1) = (n-k)(n-k-1)`
   (`choose_eq_adjacent_iff`; the `←` direction is the catalog's
   `Singmaster.choose_cross`, the `→` direction is new and is what upgrades the
   catalog's *sufficient* condition to a *characterisation*).
2. *Arithmetic → a binary quadratic form.*  With `u = n - k`, the substitution
   `N = 5n+1`, `U = 5u-3` turns that equation into the norm form equation
   `N² - N·U - U² = -5` of the real quadratic field `ℚ(√5)` (`dioph_to_form`).
3. *Quadratic form → Lucas numbers.*  All natural solutions of `N² - N·U - U² = ±5`
   are pairs of consecutive Lucas numbers (`luc_of_sol`), proved by an unconditional
   Vieta/Euclidean descent `(x,y) ↦ (y, x-y)` that flips the sign of the form; the
   descent bottoms out at `(L₁,L₀) = (1,2)`.  A period-four congruence
   (`luc_mod_five`) then selects the admissible indices.

## Results

* `luc_sol` — consecutive Lucas numbers solve `x² - xy - y² = 5·(-1)^{i+1}`;
* `luc_of_sol` — **conversely, every natural solution is a consecutive Lucas pair**;
* `choose_eq_adjacent_iff` — the combinatorial ↔ Diophantine dictionary;
* `adjacent_iff_luc` — **complete classification**: for `1 ≤ k` and `k + 2 ≤ n`,
  `C(n,k) = C(n-1,k+1)` holds iff `5n + 1 = L_{4j+9}` and `5(n-k) = L_{4j+8} + 3` for
  some `j`; the first three members are `(n,k) = (15,5), (104,39), (714,272)`;
* `exists_adjacent` — each `j` really does produce a solution, so the family is infinite;
* `adjacent_below_seven_hundred` — consequently `(15,5)` and `(104,39)` are the *only*
  adjacent repetitions with `n ≤ 700`;
* `six_le_mult_of_adjacent` — every adjacent repetition produces a number of
  multiplicity at least six, so the classification describes *all* sources of the
  "six times" phenomenon of this shape;
* `six_le_mult_luc` — the resulting infinite family of multiplicity-`≥ 6` numbers,
  indexed by Lucas numbers.
-/
import Mathlib
import Combinatorics.SingmasterOccurrences
import Combinatorics.SingmasterFibonacci

open Finset

namespace Catalog.Novelty.AdjacentBinomial

open Singmaster

/-! ## 1. The Lucas sequence and the norm form `x² - xy - y² = ±5` -/

/-- The Lucas sequence `2, 1, 3, 4, 7, 11, 18, 29, 47, 76, …`. -/
def luc : ℕ → ℕ
  | 0 => 2
  | 1 => 1
  | (n + 2) => luc n + luc (n + 1)

@[simp] theorem luc_zero : luc 0 = 2 := rfl
@[simp] theorem luc_one : luc 1 = 1 := rfl
theorem luc_add_two (n : ℕ) : luc (n + 2) = luc n + luc (n + 1) := rfl

theorem luc_pos (n : ℕ) : 0 < luc n := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    match n with
    | 0 => norm_num
    | 1 => norm_num
    | (m + 2) => rw [luc_add_two]; have := ih m (by omega); omega

/-- Monotonicity of the Lucas sequence from index `1` on. -/
theorem luc_le_luc {a b : ℕ} (ha : 1 ≤ a) (hab : a ≤ b) : luc a ≤ luc b := by
  induction b with
  | zero => omega
  | succ c ih =>
    rcases Nat.lt_or_ge a (c + 1) with h | h
    · refine le_trans (ih (by omega)) ?_
      match c with
      | 0 => omega
      | (d + 1) => rw [luc_add_two]; have := luc_pos d; omega
    · have hac : a = c + 1 := by omega
      rw [hac]

/-- Four-step recurrence: `L_{a+4} = 2 L_a + 3 L_{a+1}`. -/
theorem luc_add_four (a : ℕ) : luc (a + 4) = 2 * luc a + 3 * luc (a + 1) := by
  have e2 : luc (a + 2) = luc a + luc (a + 1) := luc_add_two a
  have e3 : luc (a + 3) = luc (a + 1) + luc (a + 2) := luc_add_two (a + 1)
  have e4 : luc (a + 4) = luc (a + 2) + luc (a + 3) := luc_add_two (a + 2)
  omega

/-- **Consecutive Lucas numbers solve the norm form equation** `x² - xy - y² = ±5`,
with the sign alternating.  (For `(x,y) = (L₉,L₈) = (76,47)`: `76² - 76·47 - 47² = -5`.) -/
theorem luc_sol (i : ℕ) :
    ((luc (i + 1) : ℤ)) ^ 2 - (luc (i + 1)) * (luc i) - (luc i) ^ 2 = 5 * (-1) ^ (i + 1) := by
  induction i with
  | zero => norm_num
  | succ j ih =>
    have h : luc (j + 2) = luc j + luc (j + 1) := rfl
    push_cast [h]
    push_cast [h] at ih ⊢
    ring_nf
    ring_nf at ih
    linarith [ih, pow_succ (-1 : ℤ) j]

/-- `5` is not a perfect square. -/
theorem no_sq_five (x : ℕ) : (x : ℤ) ^ 2 ≠ 5 := by
  intro h
  rcases Nat.lt_or_ge x 3 with hx | hx
  · interval_cases x <;> norm_num at h
  · have : (3 : ℤ) ≤ (x : ℤ) := by exact_mod_cast hx
    nlinarith

/-- **Complete solution of the norm form equation by descent.**  Every pair of natural
numbers with `x² - xy - y² = ±5` is a pair of consecutive Lucas numbers.

The descent step is `(x,y) ↦ (y, x-y)`, which negates the value of the form; it strictly
decreases the first coordinate and terminates at `(L₁,L₀) = (1,2)`. -/
theorem luc_of_sol : ∀ x : ℕ, ∀ y : ℕ,
    ((x : ℤ) ^ 2 - x * y - y ^ 2 = 5 ∨ (x : ℤ) ^ 2 - x * y - y ^ 2 = -5) →
      ∃ i, x = luc (i + 1) ∧ y = luc i := by
  intro x
  induction x using Nat.strong_induction_on with
  | _ x ih =>
    intro y h
    rcases Nat.eq_zero_or_pos y with rfl | hy
    · exfalso
      simp at h
      rcases h with h | h
      · exact no_sq_five x (by linarith)
      · nlinarith [sq_nonneg (x : ℤ)]
    rcases lt_trichotomy x y with hlt | heq | hgt
    · -- the bottom of the descent: `(x,y) = (1,2)`
      have hx1 : (x : ℤ) + 1 ≤ (y : ℤ) := by exact_mod_cast hlt
      have hneg : (x : ℤ) ^ 2 - x * y - y ^ 2 = -5 := by
        rcases h with h | h
        · exfalso; nlinarith [Nat.cast_nonneg (α := ℤ) x, Nat.cast_nonneg (α := ℤ) y]
        · exact h
      have hx : x ≤ 1 := by
        by_contra hc
        push_neg at hc
        have : (2 : ℤ) ≤ (x : ℤ) := by exact_mod_cast hc
        nlinarith
      interval_cases x
      · exact absurd (by push_cast at hneg; linarith : ((y : ℤ)) ^ 2 = 5) (no_sq_five y)
      · have hy2 : y = 2 := by
          have h1 : ((y : ℤ)) ^ 2 + y - 1 = 5 := by push_cast at hneg; linarith
          have : y ≤ 2 := by
            by_contra hc
            push_neg at hc
            have : (3 : ℤ) ≤ (y : ℤ) := by exact_mod_cast hc
            nlinarith
          interval_cases y
          simp_all
        exact ⟨0, by simp [luc, hy2]⟩
    · exfalso
      subst heq
      have hx : (1 : ℤ) ≤ (x : ℤ) := by exact_mod_cast hy
      rcases h with h | h
      · nlinarith
      · exact no_sq_five x (by nlinarith)
    · -- the descent step
      have hxy : (1 : ℤ) ≤ (y : ℤ) := by exact_mod_cast hy
      have hsub : ((x - y : ℕ) : ℤ) = (x : ℤ) - y := by
        have : y ≤ x := le_of_lt hgt
        push_cast [this]; ring
      have hnew : ((y : ℤ) ^ 2 - y * ((x - y : ℕ) : ℤ) - ((x - y : ℕ) : ℤ) ^ 2 = 5 ∨
          (y : ℤ) ^ 2 - y * ((x - y : ℕ) : ℤ) - ((x - y : ℕ) : ℤ) ^ 2 = -5) := by
        rw [hsub]
        rcases h with h | h
        · right; nlinarith
        · left; nlinarith
      obtain ⟨i, hi1, hi2⟩ := ih y hgt (x - y) hnew
      refine ⟨i + 1, ?_, hi1⟩
      rw [luc_add_two]
      omega

/-! ### The period-four congruence mod 5 -/

/-- The Lucas sequence is `2, 1, 3, 4` modulo `5`, with period four. -/
theorem luc_mod_five (j : ℕ) :
    luc (4 * j) % 5 = 2 ∧ luc (4 * j + 1) % 5 = 1 ∧ luc (4 * j + 2) % 5 = 3 ∧
      luc (4 * j + 3) % 5 = 4 := by
  induction j with
  | zero => refine ⟨rfl, rfl, rfl, rfl⟩
  | succ m ih =>
    obtain ⟨h0, h1, h2, h3⟩ := ih
    have e4 : luc (4 * m + 4) = luc (4 * m + 2) + luc (4 * m + 3) := luc_add_two _
    have e5 : luc (4 * m + 5) = luc (4 * m + 3) + luc (4 * m + 4) := luc_add_two _
    have e6 : luc (4 * m + 6) = luc (4 * m + 4) + luc (4 * m + 5) := luc_add_two _
    have e7 : luc (4 * m + 7) = luc (4 * m + 5) + luc (4 * m + 6) := luc_add_two _
    refine ⟨?_, ?_, ?_, ?_⟩
    · rw [show 4 * (m + 1) = 4 * m + 4 by ring]; omega
    · rw [show 4 * (m + 1) + 1 = 4 * m + 5 by ring]; omega
    · rw [show 4 * (m + 1) + 2 = 4 * m + 6 by ring]; omega
    · rw [show 4 * (m + 1) + 3 = 4 * m + 7 by ring]; omega

/-- An index whose Lucas number is `≡ 2 mod 5` is divisible by four. -/
theorem four_dvd_of_luc_mod_five {i : ℕ} (h : luc i % 5 = 2) : i % 4 = 0 := by
  obtain ⟨h0, h1, h2, h3⟩ := luc_mod_five (i / 4)
  have hcase : i % 4 = 0 ∨ i % 4 = 1 ∨ i % 4 = 2 ∨ i % 4 = 3 := by omega
  rcases hcase with he | he | he | he
  · exact he
  · have hii : i = 4 * (i / 4) + 1 := by omega
    rw [hii] at h; omega
  · have hii : i = 4 * (i / 4) + 2 := by omega
    rw [hii] at h; omega
  · have hii : i = 4 * (i / 4) + 3 := by omega
    rw [hii] at h; omega

/-! ## 2. Combinatorics ↔ arithmetic -/

/-- **The dictionary.**  For `1 ≤ k` and `k + 2 ≤ n`, an adjacent repetition
`C(n,k) = C(n-1,k+1)` is equivalent to the Diophantine equation
`n(k+1) = (n-k)(n-k-1)`.

The `←` direction is `Singmaster.choose_cross`; the `→` direction is obtained from the
two Pascal recurrences `C(n-1,k)(n) = C(n,k)(n-k)` and `C(n-1,k+1)(k+1) = C(n-1,k)(n-1-k)`
by cancelling the (positive) factor `C(n-1,k)`. -/
theorem choose_eq_adjacent_iff {n k : ℕ} (hk : 1 ≤ k) (hn : k + 2 ≤ n) :
    n.choose k = (n - 1).choose (k + 1) ↔ n * (k + 1) = (n - k) * (n - k - 1) := by
  obtain ⟨m, rfl⟩ : ∃ m, n = m + 1 := ⟨n - 1, by omega⟩
  simp only [Nat.add_sub_cancel]
  rw [show m + 1 - k = (m - k) + 1 by omega, Nat.add_sub_cancel]
  -- the two Pascal recurrences
  have e1 : m.choose k * (m + 1) = (m + 1).choose k * (m + 1 - k) := Nat.choose_mul_succ_eq m k
  rw [show m + 1 - k = (m - k) + 1 by omega] at e1
  have e2 : m.choose (k + 1) * (k + 1) = m.choose k * (m - k) := Nat.choose_succ_right_eq m k
  have hcross : (m + 1).choose k * (((m - k) + 1) * (m - k)) =
      m.choose (k + 1) * ((m + 1) * (k + 1)) := by
    calc (m + 1).choose k * (((m - k) + 1) * (m - k))
        = ((m + 1).choose k * ((m - k) + 1)) * (m - k) := by ring
      _ = (m.choose k * (m + 1)) * (m - k) := by rw [e1]
      _ = (m.choose k * (m - k)) * (m + 1) := by ring
      _ = (m.choose (k + 1) * (k + 1)) * (m + 1) := by rw [e2]
      _ = m.choose (k + 1) * ((m + 1) * (k + 1)) := by ring
  have hposB : 0 < m.choose (k + 1) := Nat.choose_pos (by omega)
  constructor
  · intro heq
    rw [heq] at hcross
    exact (Nat.eq_of_mul_eq_mul_left hposB hcross).symm
  · intro hdio
    have hswap : (m + 1).choose k * (((m - k) + 1) * (m - k)) =
        m.choose (k + 1) * (((m - k) + 1) * (m - k)) := by
      rw [hcross, hdio]
    have hposX : 0 < ((m - k) + 1) * (m - k) := by
      have h1 : 0 < m - k := by omega
      positivity
    exact Nat.eq_of_mul_eq_mul_right hposX hswap

/-! ## 3. Arithmetic ↔ Lucas numbers -/

/-- The substitution `N = 5n+1`, `U = 5u-3` turns `n(k+1) = (n-k)(n-k-1)` (with
`u = n - k`) into the norm form equation `N² - NU - U² = -5`. -/
theorem dioph_to_form {n u : ℕ} (hu : 2 ≤ u)
    (h : (n : ℤ) * ((n : ℤ) - u + 1) = (u : ℤ) * ((u : ℤ) - 1)) :
    ((5 * n + 1 : ℕ) : ℤ) ^ 2 - ((5 * n + 1 : ℕ) : ℤ) * ((5 * u - 3 : ℕ) : ℤ) -
      ((5 * u - 3 : ℕ) : ℤ) ^ 2 = -5 := by
  have hcast : ((5 * u - 3 : ℕ) : ℤ) = 5 * (u : ℤ) - 3 := by
    have : (3 : ℕ) ≤ 5 * u := by omega
    push_cast [this]
    omega
  rw [hcast]
  push_cast
  nlinarith [h]

/-- **Complete classification of adjacent repetitions in Pascal's triangle.**

For `1 ≤ k` and `k + 2 ≤ n`, the value `C(n,k)` repeats one row higher,
`C(n,k) = C(n-1,k+1)`, if and only if `5n+1` and `5(n-k)-3` are the consecutive Lucas
numbers `L_{4j+9}` and `L_{4j+8}`.

The first three solutions are `(n,k) = (15,5)`, `(104,39)`, `(714,272)`, giving
`C(15,5) = C(14,6) = 3003`, `C(104,39) = C(103,40)`, `C(714,272) = C(713,273)`. -/
theorem adjacent_iff_luc {n k : ℕ} (hk : 1 ≤ k) (hn : k + 2 ≤ n) :
    n.choose k = (n - 1).choose (k + 1) ↔
      ∃ j : ℕ, 5 * n + 1 = luc (4 * j + 9) ∧ 5 * (n - k) = luc (4 * j + 8) + 3 := by
  rw [choose_eq_adjacent_iff hk hn]
  set u := n - k with hu
  have hu2 : 2 ≤ u := by omega
  have hun : u ≤ n := by omega
  have hnk : k = n - u := by omega
  constructor
  · intro hdio
    -- pass to the integer form equation
    have hZ : (n : ℤ) * ((n : ℤ) - u + 1) = (u : ℤ) * ((u : ℤ) - 1) := by
      have h1 : ((n * (k + 1) : ℕ) : ℤ) = ((( n - k) * (n - k - 1) : ℕ) : ℤ) := by
        exact_mod_cast congrArg (Nat.cast : ℕ → ℤ) hdio
      have hk' : ((k : ℤ)) = (n : ℤ) - u := by
        rw [hnk]; push_cast [hun]; ring
      have hc1 : (((n - k) : ℕ) : ℤ) = (u : ℤ) := by rw [← hu]
      have hc2 : (((n - k - 1) : ℕ) : ℤ) = (u : ℤ) - 1 := by
        rw [show n - k - 1 = u - 1 from by omega]
        push_cast [show 1 ≤ u by omega]
        ring
      push_cast [hc1, hc2] at h1
      rw [hk'] at h1
      linarith [h1]
    have hform := dioph_to_form hu2 hZ
    obtain ⟨i, hi1, hi2⟩ := luc_of_sol (5 * n + 1) (5 * u - 3) (Or.inr hform)
    -- the index is divisible by four
    have hmod : luc i % 5 = 2 := by rw [← hi2]; omega
    have h4 := four_dvd_of_luc_mod_five hmod
    obtain ⟨m, hm⟩ : ∃ m, i = 4 * m := ⟨i / 4, by omega⟩
    subst hm
    -- `m ≥ 2`, since the two small indices give degenerate pairs
    have hm2 : 2 ≤ m := by
      by_contra hc
      push_neg at hc
      interval_cases m
      · rw [show 4 * 0 + 1 = 1 from rfl] at hi1
        simp [luc] at hi1
        omega
      · rw [show 4 * 1 + 1 = 5 from rfl] at hi1
        have : luc 5 = 11 := by decide
        rw [this] at hi1
        omega
    refine ⟨m - 2, ?_, ?_⟩
    · rw [show 4 * (m - 2) + 9 = 4 * m + 1 by omega]; exact hi1
    · rw [show 4 * (m - 2) + 8 = 4 * m by omega]; omega
  · rintro ⟨j, h1, h2⟩
    -- run the substitution backwards, using that consecutive Lucas numbers solve the form
    have hsol := luc_sol (4 * j + 8)
    rw [show 4 * j + 8 + 1 = 4 * j + 9 from rfl] at hsol
    have hpar : ((-1 : ℤ)) ^ (4 * j + 8 + 1) = -1 := by
      rw [show 4 * j + 8 + 1 = 2 * (2 * j + 4) + 1 by ring, pow_succ, pow_mul]
      norm_num
    rw [hpar] at hsol
    have hN : ((luc (4 * j + 9) : ℤ)) = 5 * (n : ℤ) + 1 := by exact_mod_cast h1.symm
    have hU : ((luc (4 * j + 8) : ℤ)) = 5 * (u : ℤ) - 3 := by
      have : ((luc (4 * j + 8) + 3 : ℕ) : ℤ) = ((5 * u : ℕ) : ℤ) := by exact_mod_cast h2.symm
      push_cast at this
      linarith
    rw [hN, hU] at hsol
    -- back to the Diophantine equation over `ℕ`
    have hZ : (n : ℤ) * ((k : ℤ) + 1) = (u : ℤ) * ((u : ℤ) - 1) := by
      have hk' : ((k : ℤ)) = (n : ℤ) - u := by
        rw [hnk]; push_cast [hun]; ring
      rw [hk']
      nlinarith [hsol]
    have hc1 : (((n - k) : ℕ) : ℤ) = (u : ℤ) := by rw [← hu]
    have hc2 : (((n - k - 1) : ℕ) : ℤ) = (u : ℤ) - 1 := by
      rw [show n - k - 1 = u - 1 from by omega]
      push_cast [show 1 ≤ u by omega]
      ring
    have : ((n * (k + 1) : ℕ) : ℤ) = (((n - k) * (n - k - 1) : ℕ) : ℤ) := by
      push_cast [hc1, hc2]
      linarith [hZ]
    exact_mod_cast this

/-- **Every index really occurs.**  For each `j` the Lucas pair `(L_{4j+9}, L_{4j+8})`
produces a genuine adjacent repetition; hence there are infinitely many of them. -/
theorem exists_adjacent (j : ℕ) :
    ∃ n k : ℕ, 1 ≤ k ∧ k + 2 ≤ n ∧ 5 * n + 1 = luc (4 * j + 9) ∧
      n.choose k = (n - 1).choose (k + 1) := by
  -- divisibility: `L_{4j+9} ≡ 1` and `L_{4j+8} ≡ 2` mod `5`
  obtain ⟨h0, h1, h2, h3⟩ := luc_mod_five (j + 2)
  have hA : luc (4 * j + 8) % 5 = 2 := by
    rw [show 4 * j + 8 = 4 * (j + 2) by ring]; exact h0
  have hB : luc (4 * j + 9) % 5 = 1 := by
    rw [show 4 * j + 9 = 4 * (j + 2) + 1 by ring]; exact h1
  -- sizes: `L₈ = 47 ≤ L_{4j+8}` and `L_{4j+8} + 4 ≤ L_{4j+9}`
  have hgrow : luc (4 * j + 8) + 29 ≤ luc (4 * j + 9) := by
    have e : luc (4 * j + 9) = luc (4 * j + 7) + luc (4 * j + 8) := luc_add_two _
    have h7 : luc 7 ≤ luc (4 * j + 7) := luc_le_luc (by omega) (by omega)
    have h7' : luc 7 = 29 := by decide
    omega
  have h47 : 47 ≤ luc (4 * j + 8) := by
    have := luc_le_luc (a := 8) (b := 4 * j + 8) (by omega) (by omega)
    have h8 : luc 8 = 47 := by decide
    omega
  set n := (luc (4 * j + 9) - 1) / 5 with hn
  set u := (luc (4 * j + 8) + 3) / 5 with hud
  have hn5 : 5 * n + 1 = luc (4 * j + 9) := by omega
  have hu5 : 5 * u = luc (4 * j + 8) + 3 := by omega
  have hun : u + 2 ≤ n := by omega
  refine ⟨n, n - u, by omega, by omega, hn5, ?_⟩
  rw [adjacent_iff_luc (by omega) (by omega)]
  exact ⟨j, hn5, by omega⟩

/-- **Only two adjacent repetitions occur with `n ≤ 700`**, namely `C(15,5) = C(14,6)`
and `C(104,39) = C(103,40)`. -/
theorem adjacent_below_seven_hundred {n k : ℕ} (hk : 1 ≤ k) (hn : k + 2 ≤ n)
    (hle : n ≤ 700) (h : n.choose k = (n - 1).choose (k + 1)) :
    (n = 15 ∧ k = 5) ∨ (n = 104 ∧ k = 39) := by
  obtain ⟨j, h1, h2⟩ := (adjacent_iff_luc hk hn).1 h
  have hj : j ≤ 1 := by
    by_contra hc
    push_neg at hc
    have := luc_le_luc (a := 17) (b := 4 * j + 9) (by omega) (by omega)
    have h17 : luc 17 = 3571 := by decide
    omega
  interval_cases j
  · left
    have e9 : luc 9 = 76 := by decide
    have e8 : luc 8 = 47 := by decide
    norm_num [e9, e8] at h1 h2
    omega
  · right
    have e13 : luc 13 = 521 := by decide
    have e12 : luc 12 = 322 := by decide
    norm_num [e13, e12] at h1 h2
    omega

/-! ## 4. Back to Singmaster's problem -/

/-- **Any adjacent repetition forces multiplicity at least six.**  This is the general
form of `Singmaster.six_le_mult_fib`: the six positions are `(t,1)`, `(t,t-1)`, `(n,k)`,
`(n,n-k)`, `(n-1,k+1)` and `(n-1,n-k-2)`. -/
theorem six_le_mult_of_adjacent {n k : ℕ} (hk : 2 ≤ k) (hgap : k + 3 < n - k)
    (hcross : n.choose k = (n - 1).choose (k + 1)) : 6 ≤ mult (n.choose k) := by
  classical
  set t := n.choose k with ht
  have hkn : k ≤ n := by omega
  have hn2 : n.choose 2 ≤ t := by rw [ht]; exact choose_two_le_choose hk (by omega)
  have hnt : n < t := by
    have h1 : n * 4 ≤ n * (n - 1) := Nat.mul_le_mul_left n (by omega)
    have h2 : n.choose 2 = n * (n - 1) / 2 := Nat.choose_two_right n
    omega
  have ht3 : 3 ≤ t := by omega
  have m1 : (t, 1) ∈ occ t := mem_occ (by omega) (by omega) (Nat.choose_one_right t)
  have m2 : (t, t - 1) ∈ occ t := by
    refine mem_occ (by omega) (by omega) ?_
    have h := Nat.choose_symm (n := t) (k := 1) (by omega)
    rw [Nat.choose_one_right] at h
    exact h
  have m3 : (n, k) ∈ occ t := mem_occ (by omega) (by omega) ht.symm
  have m4 : (n, n - k) ∈ occ t :=
    mem_occ (by omega) (by omega) (by rw [Nat.choose_symm hkn])
  have m5 : (n - 1, k + 1) ∈ occ t :=
    mem_occ (by omega) (by omega) (by rw [← hcross])
  have m6 : (n - 1, n - k - 2) ∈ occ t := by
    refine mem_occ (by omega) (by omega) ?_
    have hs : (n - 1).choose (n - 1 - (k + 1)) = (n - 1).choose (k + 1) :=
      Nat.choose_symm (by omega)
    rw [show n - k - 2 = n - 1 - (k + 1) by omega, hs, ← hcross]
  have hsub : ({(t, 1), (t, t - 1), (n, k), (n, n - k), (n - 1, k + 1), (n - 1, n - k - 2)} :
      Finset (ℕ × ℕ)) ⊆ occ t := by
    simp only [Finset.insert_subset_iff, Finset.singleton_subset_iff]
    exact ⟨m1, m2, m3, m4, m5, m6⟩
  have hcard : ({(t, 1), (t, t - 1), (n, k), (n, n - k), (n - 1, k + 1), (n - 1, n - k - 2)} :
      Finset (ℕ × ℕ)).card = 6 := by
    rw [Finset.card_insert_of_notMem (by
        simp only [mem_insert, mem_singleton, Prod.mk.injEq]; omega),
      Finset.card_insert_of_notMem (by
        simp only [mem_insert, mem_singleton, Prod.mk.injEq]; omega),
      Finset.card_insert_of_notMem (by
        simp only [mem_insert, mem_singleton, Prod.mk.injEq]; omega),
      Finset.card_insert_of_notMem (by
        simp only [mem_insert, mem_singleton, Prod.mk.injEq]; omega),
      Finset.card_insert_of_notMem (by
        simp only [mem_singleton, Prod.mk.injEq]; omega),
      Finset.card_singleton]
  calc 6 = _ := hcard.symm
    _ ≤ mult t := card_le_card hsub

/-- The Diophantine equation itself forces the gap condition `k + 3 < n - k`. -/
theorem gap_of_dioph {n k : ℕ} (hk : 2 ≤ k) (hn : k + 2 ≤ n)
    (hdio : n * (k + 1) = (n - k) * (n - k - 1)) : k + 3 < n - k := by
  obtain ⟨v, hv⟩ : ∃ v, n - k = v + 2 := ⟨n - k - 2, by omega⟩
  have hnv : n = k + v + 2 := by omega
  have h : (k + v + 2) * (k + 1) = (v + 2) * (v + 1) := by
    rw [hv] at hdio
    simpa [hnv] using hdio
  by_contra hc
  have hvk : v ≤ k + 1 := by omega
  nlinarith [h, hvk, hk, Nat.zero_le v]

/-- The column of an adjacent repetition is at least `2`: the equation has no solution
with `k = 1`. -/
theorem two_le_col_of_dioph {n k : ℕ} (hk : 1 ≤ k) (hn : k + 2 ≤ n)
    (hdio : n * (k + 1) = (n - k) * (n - k - 1)) : 2 ≤ k := by
  by_contra hc
  have hk1 : k = 1 := by omega
  subst hk1
  obtain ⟨w, rfl⟩ : ∃ w, n = w + 3 := ⟨n - 3, by omega⟩
  rw [show w + 3 - 1 = w + 2 by omega, show w + 2 - 1 = w + 1 by omega] at hdio
  have hsq : w * w + w = 4 := by nlinarith [hdio]
  have hw4 : w ≤ 4 := by nlinarith [hsq]
  interval_cases w <;> omega

/-- **The Lucas family of numbers occurring at least six times.**  Combining the
classification with the six-position count: for every `j` there is an adjacent
repetition whose common value occurs at least six times, and its row index `n`
satisfies `5n + 1 = L_{4j+9}`, so the values are pairwise distinct and unbounded. -/
theorem six_le_mult_luc (j : ℕ) :
    ∃ n k : ℕ, 5 * n + 1 = luc (4 * j + 9) ∧ 2 ≤ k ∧ k + 2 ≤ n ∧
      6 ≤ mult (n.choose k) := by
  obtain ⟨n, k, hk1, hn, hluc, hcross⟩ := exists_adjacent j
  have hdio : n * (k + 1) = (n - k) * (n - k - 1) := (choose_eq_adjacent_iff hk1 hn).1 hcross
  have hk2 : 2 ≤ k := two_le_col_of_dioph hk1 hn hdio
  exact ⟨n, k, hluc, hk2, hn, six_le_mult_of_adjacent hk2 (gap_of_dioph hk2 hn hdio) hcross⟩

/-- Linear lower bound for the Lucas numbers along the arithmetic progression `4M + 9`. -/
theorem five_mul_add_two_le_luc (M : ℕ) : 5 * M + 2 ≤ luc (4 * M + 9) := by
  induction M with
  | zero =>
    have h9 : luc (4 * 0 + 9) = 76 := by decide
    omega
  | succ p ih =>
    have h76 : 76 ≤ luc (4 * p + 9) := by
      have := luc_le_luc (a := 9) (b := 4 * p + 9) (by omega) (by omega)
      have h9 : luc 9 = 76 := by decide
      omega
    have e : luc (4 * p + 9 + 4) = 2 * luc (4 * p + 9) + 3 * luc (4 * p + 10) :=
      luc_add_four (4 * p + 9)
    have hpos : 0 < luc (4 * p + 10) := luc_pos _
    have e2 : luc (4 * (p + 1) + 9) = luc (4 * p + 9 + 4) := by congr 1
    omega

/-- The multiplicity-`≥ 6` numbers coming from adjacent repetitions are unbounded. -/
theorem six_le_mult_unbounded (M : ℕ) : ∃ t : ℕ, M < t ∧ 6 ≤ mult t := by
  obtain ⟨n, k, hluc, hk2, hn, hmult⟩ := six_le_mult_luc M
  refine ⟨n.choose k, ?_, hmult⟩
  have hgrow := five_mul_add_two_le_luc M
  have h76 : 76 ≤ luc (4 * M + 9) := by
    have := luc_le_luc (a := 9) (b := 4 * M + 9) (by omega) (by omega)
    have h9 : luc 9 = 76 := by decide
    omega
  have hnM : M < n := by omega
  have hn2 : n.choose 2 ≤ n.choose k := choose_two_le_choose hk2 (by omega)
  have h1 : n * 4 ≤ n * (n - 1) := Nat.mul_le_mul_left n (by omega)
  have h2 : n.choose 2 = n * (n - 1) / 2 := Nat.choose_two_right n
  omega

/-- The Diophantine equation forces the column to be a definite fraction of the row:
`n < 4(k+1)`.  (Asymptotically `k/n → (3-√5)/2 ≈ 0.382`.) -/
theorem row_lt_four_mul_col {n k : ℕ} (hk : 2 ≤ k) (hn : k + 2 ≤ n)
    (hdio : n * (k + 1) = (n - k) * (n - k - 1)) : n < 4 * (k + 1) := by
  obtain ⟨v, hv⟩ : ∃ v, n - k = v + 2 := ⟨n - k - 2, by omega⟩
  have hnv : n = k + v + 2 := by omega
  have h : (k + v + 2) * (k + 1) = (v + 2) * (v + 1) := by
    rw [hv] at hdio
    simpa [hnv] using hdio
  by_contra hc
  push_neg at hc
  have hvk : 3 * k + 2 ≤ v := by omega
  nlinarith [h, hvk, hk]

/-- **Why `3003` is special.**  Among all adjacent repetitions, only the first one has a
value below `10⁶`; its value is `C(15,5) = C(14,6) = 3003`.  (This is the structural
reason behind the empirical observation that `3003` is the record holder below `10⁶`:
`Combinatorics.SingmasterMaxBelowMillion.max_mult_below_million`.) -/
theorem adjacent_value_below_million {n k : ℕ} (hk : 1 ≤ k) (hn : k + 2 ≤ n)
    (hcross : n.choose k = (n - 1).choose (k + 1)) (hval : n.choose k < 1000000) :
    n = 15 ∧ k = 5 := by
  have hdio : n * (k + 1) = (n - k) * (n - k - 1) := (choose_eq_adjacent_iff hk hn).1 hcross
  have hk2 : 2 ≤ k := two_le_col_of_dioph hk hn hdio
  have hgap : k + 3 < n - k := gap_of_dioph hk2 hn hdio
  have hpow : 2 ^ k ≤ n.choose k := two_pow_le_choose (by omega)
  have hklt : k ≤ 19 := by
    by_contra hc
    push_neg at hc
    have h20 : 2 ^ 20 ≤ 2 ^ k := Nat.pow_le_pow_right (by norm_num) (by omega)
    have : (2 : ℕ) ^ 20 = 1048576 := by norm_num
    omega
  have hnlt : n < 4 * (k + 1) := row_lt_four_mul_col hk2 hn hdio
  have hn700 : n ≤ 700 := by omega
  rcases adjacent_below_seven_hundred hk hn hn700 hcross with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
  · exact ⟨rfl, rfl⟩
  · exfalso
    have h39 : 2 ^ 39 ≤ (104 : ℕ).choose 39 := two_pow_le_choose (by norm_num)
    have h20 : (2 : ℕ) ^ 20 ≤ 2 ^ 39 := Nat.pow_le_pow_right (by norm_num) (by norm_num)
    have : (2 : ℕ) ^ 20 = 1048576 := by norm_num
    omega

end Catalog.Novelty.AdjacentBinomial