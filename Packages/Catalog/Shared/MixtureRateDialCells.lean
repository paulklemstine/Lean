import Mathlib

/-!
# The divisibility grid of `j² - N` is a rate dial, not a position dial (Part I)

Context: experiment 588c / paper 242.  A mid-window excess in the small-prime
sieve hit profile was tested against a **16-cell divisibility mixture baseline**:
each sieve value `v = j² - N` is labelled by its divisibility pattern
`(2 ∣ v, 3 ∣ v, 5 ∣ v, 7 ∣ v)`, giving `16` cells, and the baseline prediction is
`PRED(t) = Σ_c κ_c · S_c(t)` with per-cell rates `κ_c` fitted on the flanks.

The measurement found the class *composition* flat in the window coordinate
(max cell drift `0.269 %`), so the mixture had no positional freedom.  This file
proves the structural reason: **the cell label of `j² - N` is a periodic
function of `j` with period `210 = 2·3·5·7`, hence every window of `210`
consecutive `j` contains exactly the same number of members of every cell.**
Composition is therefore *exactly* position-independent, whatever `N` is.

Main results.

* `cellOf_periodic`, `cell_periodic` — the cell label is `210`-periodic.
* `windowCount_succ`, `windowCount_const` — the per-cell population of a window
  of `210` consecutive `j` does not depend on where the window starts.
* `two_dvd_iff_odd` — for odd `N`, bit `0` of the grid (`2 ∣ j² - N`) is exactly
  the parity of `j`: parity is *inside* the grid, not an extra carrier.
* `windowCount_8051_table`, `windowCount_8051_three_empty`,
  `windowCount_8051_parity_split`, `windowCount_8051_table_everywhere` — a
  kernel-checked rate table for `N = 8051 = 83·97`, and the same table at every
  window position.
* `sqCount_three`, `sqCount_five`, `sqCount_seven` — the per-prime rates are
  genuinely modulated (`0`, `1` or `2` roots mod `p`, i.e. rate `0`, `1/p` or
  `2/p`), so the "rate dial" really does turn; `windowCount_const` says it never
  turns *with position*.
-/

set_option maxRecDepth 8000

namespace RateDial

open Finset

/-! ## The 16 divisibility cells -/

/-- The divisibility pattern of `v` with respect to the primes `2, 3, 5, 7`:
one of `16` cells. -/
def cellOf (v : ℤ) : Bool × Bool × Bool × Bool :=
  (decide (2 ∣ v), decide (3 ∣ v), decide (5 ∣ v), decide (7 ∣ v))

/-- The cell of the sieve value `v = j² - N`. -/
def cell (N j : ℤ) : Bool × Bool × Bool × Bool := cellOf (j ^ 2 - N)

/-- The cell label only sees `v` modulo `210 = 2 · 3 · 5 · 7`. -/
theorem cellOf_periodic (v k : ℤ) : cellOf (v + 210 * k) = cellOf v := by
  have h2 : ((2:ℤ) ∣ v + 210 * k) ↔ (2:ℤ) ∣ v := by
    constructor <;> intro h <;> omega
  have h3 : ((3:ℤ) ∣ v + 210 * k) ↔ (3:ℤ) ∣ v := by
    constructor <;> intro h <;> omega
  have h5 : ((5:ℤ) ∣ v + 210 * k) ↔ (5:ℤ) ∣ v := by
    constructor <;> intro h <;> omega
  have h7 : ((7:ℤ) ∣ v + 210 * k) ↔ (7:ℤ) ∣ v := by
    constructor <;> intro h <;> omega
  simp only [cellOf, h2, h3, h5, h7]

/-- The cell of `j² - N` is a `210`-periodic function of `j`. -/
theorem cell_periodic (N j : ℤ) : cell N (j + 210) = cell N j := by
  have hv : (j + 210) ^ 2 - N = (j ^ 2 - N) + 210 * (2 * j + 210) := by ring
  simp only [cell, hv, cellOf_periodic]

/-! ## Window populations are position independent -/

/-- The number of `j` in the window `{a, a+1, …, a+209}` of `210` consecutive
integers whose sieve value lies in cell `c`. -/
def windowCount (N a : ℤ) (c : Bool × Bool × Bool × Bool) : ℕ :=
  ∑ i ∈ Finset.range 210, if cell N (a + i) = c then 1 else 0

/-- Shifting the window by one does not change any cell population. -/
theorem windowCount_succ (N a : ℤ) (c : Bool × Bool × Bool × Bool) :
    windowCount N (a + 1) c = windowCount N a c := by
  classical
  set h : ℕ → ℕ := fun i => if cell N (a + i) = c then 1 else 0 with hh
  have e1 : ∑ i ∈ range 211, h i = (∑ i ∈ range 210, h (i + 1)) + h 0 :=
    Finset.sum_range_succ' h 210
  have e2 : ∑ i ∈ range 211, h i = (∑ i ∈ range 210, h i) + h 210 :=
    Finset.sum_range_succ h 210
  have e3 : h 210 = h 0 := by
    have hcell : cell N (a + ((210 : ℕ) : ℤ)) = cell N (a + ((0 : ℕ) : ℤ)) := by
      have : a + ((210 : ℕ) : ℤ) = (a + ((0 : ℕ) : ℤ)) + 210 := by push_cast; ring
      rw [this, cell_periodic]
    simp only [hh, hcell]
  have e4 : windowCount N (a + 1) c = ∑ i ∈ range 210, h (i + 1) := by
    refine Finset.sum_congr rfl fun i _ => ?_
    have harg : a + 1 + ((i : ℕ) : ℤ) = a + (((i + 1 : ℕ)) : ℤ) := by push_cast; ring
    simp only [hh, harg]
  have e5 : windowCount N a c = ∑ i ∈ range 210, h i := rfl
  omega

/-- **Flat composition.**  Every window of `210` consecutive `j` has exactly the
same cell population: the divisibility grid carries no positional information. -/
theorem windowCount_const (N a : ℤ) (c : Bool × Bool × Bool × Bool) :
    windowCount N a c = windowCount N 0 c := by
  refine Int.induction_on a rfl (fun n ih => ?_) (fun n ih => ?_)
  · rw [windowCount_succ]; exact ih
  · have hstep := windowCount_succ N (-(n : ℤ) - 1) c
    have hEq : (-(n : ℤ) - 1) + 1 = -(n : ℤ) := by ring
    rw [hEq] at hstep
    rw [← hstep]
    exact ih

/-- Two windows anywhere on the line have identical composition. -/
theorem windowCount_eq (N a b : ℤ) (c : Bool × Bool × Bool × Bool) :
    windowCount N a c = windowCount N b c := by
  rw [windowCount_const N a c, windowCount_const N b c]

/-! ## Bit 0 of the grid is exactly `j`-parity -/

/-- For odd `N`, `2 ∣ j² - N` holds precisely when `j` is odd: the parity
"carrier" is a coordinate of the divisibility grid, not something outside it. -/
theorem two_dvd_iff_odd {N : ℤ} (hN : Odd N) (j : ℤ) :
    (2 : ℤ) ∣ j ^ 2 - N ↔ Odd j := by
  obtain ⟨m, hm⟩ := hN
  constructor
  · intro h
    rcases Int.even_or_odd j with he | ho
    · obtain ⟨k, hk⟩ := he
      exfalso
      rw [hk, hm] at h
      have hexp : (k + k) ^ 2 - (2 * m + 1) = 2 * (2 * k ^ 2 - m) - 1 := by ring
      rw [hexp] at h
      omega
    · exact ho
  · rintro ⟨k, hk⟩
    subst hk hm
    have : (2 * k + 1) ^ 2 - (2 * m + 1) = 2 * (2 * k ^ 2 + 2 * k - m) := by ring
    rw [this]
    exact ⟨_, rfl⟩

/-! ## The rates themselves are real: quadratic-residue modulation -/

/-- Mod `3` the number of `j` with `j² = N` is `1`, `2` or `0`: the `3 ∣ v` rate
is `1/3`, `2/3` or `0` times the generic `1/3`. -/
theorem sqCount_three (N : ZMod 3) :
    (Finset.univ.filter fun j : ZMod 3 => j ^ 2 = N).card =
      if N = 0 then 1 else if N = 1 then 2 else 0 := by revert N; decide

/-- Mod `5`: the same trichotomy, with two square classes. -/
theorem sqCount_five (N : ZMod 5) :
    (Finset.univ.filter fun j : ZMod 5 => j ^ 2 = N).card ≤ 2 ∧
      ((Finset.univ.filter fun j : ZMod 5 => j ^ 2 = N).card = 0 ∨
       (Finset.univ.filter fun j : ZMod 5 => j ^ 2 = N).card = 1 ∨
       (Finset.univ.filter fun j : ZMod 5 => j ^ 2 = N).card = 2) := by revert N; decide

/-- Mod `7`: idem; and the rate really is modulated, e.g. `N = 3` is a
non-residue (`0` roots) while `N = 1` has `2` roots. -/
theorem sqCount_seven :
    (Finset.univ.filter fun j : ZMod 7 => j ^ 2 = 3).card = 0 ∧
    (Finset.univ.filter fun j : ZMod 7 => j ^ 2 = 1).card = 2 := by decide

/-! ## A kernel-checked rate table

Real data for `N = 8051 = 83 · 97` (odd, `8051 ≡ 2 mod 3`, a quadratic
non-residue mod `3`).  These are the exact cell populations of a `210`-window;
by `windowCount_const` the very same numbers occur at *every* window position,
which is the content of the flat-composition finding. -/

section RateTable

set_option maxRecDepth 1000000

/-- The eight nonempty cells of `N = 8051`, exactly. -/
theorem windowCount_8051_table :
    windowCount 8051 0 (false, false, false, false) = 45 ∧
    windowCount 8051 0 (false, false, false, true) = 18 ∧
    windowCount 8051 0 (false, false, true, false) = 30 ∧
    windowCount 8051 0 (false, false, true, true) = 12 ∧
    windowCount 8051 0 (true, false, false, false) = 45 ∧
    windowCount 8051 0 (true, false, false, true) = 18 ∧
    windowCount 8051 0 (true, false, true, false) = 30 ∧
    windowCount 8051 0 (true, false, true, true) = 12 :=
  ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

/-- All cells with `3 ∣ v` are empty, because `8051` is a quadratic non-residue
mod `3`: a per-cell rate of exactly `0`.  The dial is genuinely turned. -/
theorem windowCount_8051_three_empty (b₀ b₂ b₃ : Bool) :
    windowCount 8051 0 (b₀, true, b₂, b₃) = 0 := by
  revert b₀ b₂ b₃
  decide

/-- The parity bit splits the window exactly in half: `105` odd `j` and `105`
even `j`, matching `two_dvd_iff_odd`. -/
theorem windowCount_8051_parity_split :
    windowCount 8051 0 (true, false, false, false) +
      windowCount 8051 0 (true, false, false, true) +
      windowCount 8051 0 (true, false, true, false) +
      windowCount 8051 0 (true, false, true, true) = 105 := by
  decide

/-- The table is positional data-free: the same populations occur in the window
starting at any `a`, e.g. at `a = 1234` and `a = -77777`. -/
theorem windowCount_8051_table_everywhere (a : ℤ) :
    windowCount 8051 a (false, false, false, false) = 45 ∧
    windowCount 8051 a (false, false, true, true) = 12 ∧
    windowCount 8051 a (false, true, false, false) = 0 := by
  refine ⟨?_, ?_, ?_⟩
  · rw [windowCount_const 8051 a]; exact windowCount_8051_table.1
  · rw [windowCount_const 8051 a]; exact windowCount_8051_table.2.2.2.1
  · rw [windowCount_const 8051 a]; exact windowCount_8051_three_empty false false false

end RateTable

end RateDial