/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The symmetric Rademacher Wigner ensemble and its spectral moments

This file constructs a concrete Wigner ensemble — the uniform measure on real
symmetric `N × N` sign matrices with zero diagonal — and computes the first
nontrivial normalised spectral moments of `W/√N` by the moment method:

* the second moment is **deterministically** `1 - 1/N` (self-averaging), and
* the expected fourth moment is exactly `(N-1)(2N-3)/N²`.

Both converge to the corresponding moments of the Wigner semicircle law,
`C₁ = 1` and `C₂ = 2` (see `Probability.WignerSemicircleMoments`), which is the
moment-method statement of the semicircle law at orders 2 and 4.

The key probabilistic input is a *sign-flip involution*: if some edge of the
closed walk `i → j → k → l → i` is traversed an odd number of times, flipping
the corresponding Rademacher variable negates the summand, so the expectation
vanishes.  This replaces the usual independence/factorisation argument by an
exact combinatorial symmetry.
-/
import Probability.WignerSemicircleMoments
import Probability.WignerTraceBridge

open Matrix BigOperators Finset

namespace RademacherWigner

variable {N : ℕ}

/-- A configuration of the ensemble: a sign for every ordered pair of indices
(only the pairs `i < j` are ever read). -/
abbrev Config (N : ℕ) := (Fin N × Fin N) → Bool

/-- The Rademacher sign attached to a Boolean. -/
def sgn (b : Bool) : ℝ := if b then 1 else -1

@[simp] theorem sgn_not (b : Bool) : sgn (!b) = -sgn b := by
  cases b <;> simp [sgn]

@[simp] theorem sgn_mul_self (b : Bool) : sgn b * sgn b = 1 := by
  cases b <;> norm_num [sgn]

/-- The unordered edge `{i, j}`, represented by the increasing ordered pair. -/
def edgeOf (i j : Fin N) : Fin N × Fin N := if i < j then (i, j) else (j, i)

theorem edgeOf_comm (i j : Fin N) : edgeOf i j = edgeOf j i := by
  unfold edgeOf
  rcases lt_trichotomy i j with h | h | h
  · simp [h, not_lt.2 h.le]
  · simp [h]
  · simp [h, not_lt.2 h.le]

theorem edgeOf_eq_iff {i j k l : Fin N} (_hij : i ≠ j) (hkl : k ≠ l) :
    edgeOf i j = edgeOf k l ↔ (i = k ∧ j = l) ∨ (i = l ∧ j = k) := by
  constructor
  · intro h
    unfold edgeOf at h
    by_cases h1 : i < j <;> by_cases h2 : k < l <;>
      simp [h1, h2, Prod.ext_iff] at h <;> tauto
  · rintro (⟨rfl, rfl⟩ | ⟨rfl, rfl⟩)
    · rfl
    · exact edgeOf_comm _ _

/-- The `(i, j)` entry of the sign matrix: zero on the diagonal, a Rademacher
sign off it, symmetric by construction. -/
def entry (g : Config N) (i j : Fin N) : ℝ :=
  if i = j then 0 else sgn (g (edgeOf i j))

theorem entry_symm (g : Config N) (i j : Fin N) : entry g i j = entry g j i := by
  unfold entry
  by_cases h : i = j
  · simp [h]
  · simp [h, Ne.symm h, edgeOf_comm i j]

theorem entry_diag (g : Config N) (i : Fin N) : entry g i i = 0 := by simp [entry]

theorem entry_mul_self (g : Config N) {i j : Fin N} (h : i ≠ j) :
    entry g i j * entry g i j = 1 := by
  simp [entry, h]

/-- The random symmetric sign matrix. -/
def W (g : Config N) : Matrix (Fin N) (Fin N) ℝ := Matrix.of fun i j => entry g i j

@[simp] theorem W_apply (g : Config N) (i j : Fin N) : W g i j = entry g i j := rfl

theorem W_isHermitian (g : Config N) : (W g).IsHermitian := by
  ext i j
  simp [Matrix.conjTranspose_apply, entry_symm g j i]

/-! ### The second spectral moment is deterministic -/

theorem trace_W_sq (g : Config N) : ((W g) ^ 2).trace = (N : ℝ) ^ 2 - N := by
  have h : ((W g) ^ 2).trace = ∑ i : Fin N, ∑ j : Fin N, entry g i j * entry g j i := by
    rw [pow_two, Matrix.trace_mul_comm]
    simp [Matrix.trace, Matrix.diag, Matrix.mul_apply]
  rw [h]
  have h2 : ∀ i : Fin N, (∑ j : Fin N, entry g i j * entry g j i) = (N : ℝ) - 1 := by
    intro i
    have : ∀ j : Fin N, entry g i j * entry g j i = if j = i then 0 else 1 := by
      intro j
      by_cases hj : j = i
      · simp [hj, entry_diag]
      · rw [entry_symm g i j, entry_mul_self g hj]
        simp [hj]
    rw [Finset.sum_congr rfl fun j _ => this j]
    have hN : 1 ≤ N := lt_of_le_of_lt (Nat.zero_le i) i.isLt
    simp [Finset.sum_ite, Finset.filter_ne', Nat.cast_sub hN]
  rw [Finset.sum_congr rfl fun i _ => h2 i]
  simp
  ring

/-! ### Expectation over the ensemble -/

/-- The uniform expectation over all sign configurations. -/
noncomputable def expect (f : Config N → ℝ) : ℝ :=
  (∑ g : Config N, f g) / (Fintype.card (Config N) : ℝ)

theorem card_config_pos (N : ℕ) : 0 < (Fintype.card (Config N) : ℝ) := by
  have : 0 < Fintype.card (Config N) := Fintype.card_pos
  exact_mod_cast this

theorem expect_const (c : ℝ) : expect (fun _ : Config N => c) = c := by
  unfold expect
  rw [Finset.sum_const, nsmul_eq_mul, Finset.card_univ]
  field_simp

theorem expect_zero : expect (fun _ : Config N => (0:ℝ)) = 0 := by
  simpa using expect_const (N := N) 0

theorem expect_sum {ι : Type*} (s : Finset ι) (F : ι → Config N → ℝ) :
    expect (fun g => ∑ i ∈ s, F i g) = ∑ i ∈ s, expect (F i) := by
  unfold expect
  rw [Finset.sum_comm, Finset.sum_div]

/-! ### The sign-flip involution -/

/-- Flipping the Rademacher sign attached to one edge is an involution of the
configuration space. -/
def flipEdge (p : Fin N × Fin N) : Config N ≃ Config N where
  toFun g := Function.update g p (!(g p))
  invFun g := Function.update g p (!(g p))
  left_inv g := by
    funext q
    by_cases h : q = p <;> simp [Function.update, h]
  right_inv g := by
    funext q
    by_cases h : q = p <;> simp [Function.update, h]

theorem entry_flipEdge (g : Config N) (p : Fin N × Fin N) (i j : Fin N) :
    entry (flipEdge p g) i j =
      if edgeOf i j = p then -entry g i j else entry g i j := by
  unfold entry flipEdge
  by_cases hij : i = j
  · simp [hij]
  · by_cases hp : edgeOf i j = p <;>
      simp [hij, hp, Function.update, Equiv.coe_fn_mk]

/-! ### The fourth moment -/

/-- Reversing the order of three nested sums. -/
theorem sum_reverse3 (G : Fin N → Fin N → Fin N → ℝ) :
    (∑ b, ∑ c, ∑ d, G b c d) = ∑ d, ∑ c, ∑ b, G b c d := by
  have h1 : (∑ b, ∑ c, ∑ d, G b c d) = ∑ b, ∑ d, ∑ c, G b c d :=
    Finset.sum_congr rfl fun _ _ => Finset.sum_comm
  have h2 : (∑ b, ∑ d, ∑ c, G b c d) = ∑ d, ∑ b, ∑ c, G b c d := Finset.sum_comm
  have h3 : (∑ d, ∑ b, ∑ c, G b c d) = ∑ d, ∑ c, ∑ b, G b c d :=
    Finset.sum_congr rfl fun _ _ => Finset.sum_comm
  rw [h1, h2, h3]

/-- The trace of the fourth power is the sum over closed walks of length four. -/
theorem trace_pow_four (M : Matrix (Fin N) (Fin N) ℝ) :
    (M ^ 4).trace = ∑ i, ∑ j, ∑ k, ∑ l, M i j * M j k * M k l * M l i := by
  simp only [Matrix.trace, Matrix.diag, show (4:ℕ) = 1 + 1 + 1 + 1 from rfl, pow_succ, pow_zero,
    Matrix.one_mul, Matrix.mul_apply, Finset.sum_mul]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [sum_reverse3 (fun l k j => M i j * M j k * M k l * M l i)]

theorem trace_W_four (g : Config N) :
    ((W g) ^ 4).trace =
      ∑ i : Fin N, ∑ j : Fin N, ∑ k : Fin N, ∑ l : Fin N,
        entry g i j * entry g j k * entry g k l * entry g l i :=
  trace_pow_four (W g)

/-- In a nondegenerate closed 4-walk with `i ≠ k` and `j ≠ l`, the first edge
`{i,j}` is traversed exactly once: the three other steps use different edges. -/
theorem edges_ne_first {i j k l : Fin N} (hij : i ≠ j) (hjk : j ≠ k) (hkl : k ≠ l)
    (hli : l ≠ i) (hik : i ≠ k) (hjl : j ≠ l) :
    edgeOf j k ≠ edgeOf i j ∧ edgeOf k l ≠ edgeOf i j ∧ edgeOf l i ≠ edgeOf i j := by
  refine ⟨?_, ?_, ?_⟩
  · intro h
    rcases (edgeOf_eq_iff hjk hij).1 h with ⟨h1, -⟩ | ⟨-, h2⟩
    · exact hij h1.symm
    · exact hik h2.symm
  · intro h
    rcases (edgeOf_eq_iff hkl hij).1 h with ⟨h1, -⟩ | ⟨-, h2⟩
    · exact hik h1.symm
    · exact hli h2
  · intro h
    rcases (edgeOf_eq_iff hli hij).1 h with ⟨h1, -⟩ | ⟨h1, -⟩
    · exact hli h1
    · exact hjl h1.symm

/-- If the closed walk `i → j → k → l → i` traverses the edge `{i,j}` exactly
once, the ensemble average of the corresponding monomial vanishes. -/
theorem expect_term_eq_zero {i j k l : Fin N} (hij : i ≠ j) (hjk : j ≠ k) (hkl : k ≠ l)
    (hli : l ≠ i) (hik : i ≠ k) (hjl : j ≠ l) :
    expect (fun g : Config N => entry g i j * entry g j k * entry g k l * entry g l i) = 0 := by
  set p : Fin N × Fin N := edgeOf i j with hp
  obtain ⟨e2, e3, e4⟩ := edges_ne_first hij hjk hkl hli hik hjl
  have hflip : ∀ g : Config N,
      entry (flipEdge p g) i j * entry (flipEdge p g) j k * entry (flipEdge p g) k l *
        entry (flipEdge p g) l i =
      -(entry g i j * entry g j k * entry g k l * entry g l i) := by
    intro g
    rw [entry_flipEdge, entry_flipEdge, entry_flipEdge, entry_flipEdge,
      if_pos rfl, if_neg e2, if_neg e3, if_neg e4]
    ring
  have hsum : (∑ g : Config N, entry g i j * entry g j k * entry g k l * entry g l i) = 0 := by
    have h1 := Equiv.sum_comp (flipEdge (N := N) p)
      (fun g => entry g i j * entry g j k * entry g k l * entry g l i)
    rw [Finset.sum_congr rfl fun g _ => hflip g] at h1
    rw [Finset.sum_neg_distrib] at h1
    linarith
  unfold expect
  rw [hsum, zero_div]

/-- Nondegenerate closed 4-walks with `i = k` or `j = l` contribute exactly `1`. -/
theorem term_eq_one {i j k l : Fin N} (g : Config N) (hij : i ≠ j) (hjk : j ≠ k) (hkl : k ≠ l)
    (hli : l ≠ i) (h : i = k ∨ j = l) :
    entry g i j * entry g j k * entry g k l * entry g l i = 1 := by
  rcases h with rfl | rfl
  · -- i = k : the walk is i → j → i → l → i, both edges traversed twice
    have h1 : entry g i j * entry g j i = 1 := by
      rw [entry_symm g j i]; exact entry_mul_self g hij
    have h2 : entry g i l * entry g l i = 1 := by
      rw [entry_symm g l i]; exact entry_mul_self g hkl
    calc entry g i j * entry g j i * entry g i l * entry g l i
        = (entry g i j * entry g j i) * (entry g i l * entry g l i) := by ring
      _ = 1 := by rw [h1, h2]; ring
  · -- j = l : the walk is i → j → k → j → i
    have h1 : entry g i j * entry g j i = 1 := by
      rw [entry_symm g j i]; exact entry_mul_self g hij
    have h2 : entry g j k * entry g k j = 1 := by
      rw [entry_symm g k j]; exact entry_mul_self g hjk
    calc entry g i j * entry g j k * entry g k j * entry g j i
        = (entry g i j * entry g j i) * (entry g j k * entry g k j) := by ring
      _ = 1 := by rw [h1, h2]; ring

/-- The indicator of a "paired" closed 4-walk. -/
def pairedWalk (i j k l : Fin N) : ℝ :=
  if i ≠ j ∧ j ≠ k ∧ k ≠ l ∧ l ≠ i ∧ (i = k ∨ j = l) then 1 else 0

theorem expect_term (i j k l : Fin N) :
    expect (fun g : Config N => entry g i j * entry g j k * entry g k l * entry g l i) =
      pairedWalk i j k l := by
  by_cases hij : i = j
  · have h0 : ∀ g : Config N,
        entry g i j * entry g j k * entry g k l * entry g l i = 0 := by
      intro g; simp [hij, entry_diag]
    simp only [h0]
    rw [expect_zero, pairedWalk, if_neg (by tauto)]
  by_cases hjk : j = k
  · have h0 : ∀ g : Config N,
        entry g i j * entry g j k * entry g k l * entry g l i = 0 := by
      intro g; simp [hjk, entry_diag]
    simp only [h0]
    rw [expect_zero, pairedWalk, if_neg (by tauto)]
  by_cases hkl : k = l
  · have h0 : ∀ g : Config N,
        entry g i j * entry g j k * entry g k l * entry g l i = 0 := by
      intro g; simp [hkl, entry_diag]
    simp only [h0]
    rw [expect_zero, pairedWalk, if_neg (by tauto)]
  by_cases hli : l = i
  · have h0 : ∀ g : Config N,
        entry g i j * entry g j k * entry g k l * entry g l i = 0 := by
      intro g; simp [hli, entry_diag]
    simp only [h0]
    rw [expect_zero, pairedWalk, if_neg (by tauto)]
  by_cases hpair : i = k ∨ j = l
  · have h1 : ∀ g : Config N,
        entry g i j * entry g j k * entry g k l * entry g l i = 1 := fun g =>
      term_eq_one g hij hjk hkl hli hpair
    simp only [h1]
    rw [expect_const, pairedWalk, if_pos ⟨hij, hjk, hkl, hli, hpair⟩]
  · push_neg at hpair
    rw [pairedWalk, if_neg (by tauto)]
    exact expect_term_eq_zero hij hjk hkl hli hpair.1 hpair.2

/-- Indicator of the walks with `k = i` (the two edges `{i,j}`, `{i,l}` doubled). -/
def indA (i j k l : Fin N) : ℝ :=
  (if j = i then 0 else 1) * (if k = i then 1 else 0) * (if l = i then 0 else 1)

/-- Indicator of the walks with `l = j`. -/
def indB (i j k l : Fin N) : ℝ :=
  (if i = j then 0 else 1) * (if k = j then 0 else 1) * (if l = j then 1 else 0)

/-- Indicator of the doubly-degenerate walks `k = i` and `l = j`. -/
def indC (i j k l : Fin N) : ℝ :=
  (if i = j then 0 else 1) * (if k = i then 1 else 0) * (if l = j then 1 else 0)

/-- Inclusion–exclusion for paired closed 4-walks. -/
theorem pairedWalk_decomp (i j k l : Fin N) :
    pairedWalk i j k l = indA i j k l + indB i j k l - indC i j k l := by
  unfold pairedWalk indA indB indC
  by_cases h1 : k = i <;> by_cases h2 : l = j <;> by_cases h3 : i = j <;> by_cases h4 : l = i <;>
    by_cases h5 : k = j <;> simp_all [eq_comm]

theorem sum_indicator_eq_one (i : Fin N) : (∑ k : Fin N, (if k = i then (1:ℝ) else 0)) = 1 := by
  simp

theorem sum_indicator_ne (i : Fin N) :
    (∑ j : Fin N, (if j = i then (0:ℝ) else 1)) = (N:ℝ) - 1 := by
  have hN : 1 ≤ N := lt_of_le_of_lt (Nat.zero_le i) i.isLt
  simp [Finset.sum_ite, Finset.filter_ne', Nat.cast_sub hN]

theorem sum_indicator_ne' (i : Fin N) :
    (∑ j : Fin N, (if i = j then (0:ℝ) else 1)) = (N:ℝ) - 1 := by
  have h : (∑ j : Fin N, (if i = j then (0:ℝ) else 1))
      = ∑ j : Fin N, (if j = i then (0:ℝ) else 1) := by
    refine Finset.sum_congr rfl fun j _ => ?_
    by_cases hj : j = i
    · simp [hj]
    · simp [hj, Ne.symm hj]
  rw [h, sum_indicator_ne]

theorem sum_indA (N : ℕ) :
    (∑ i : Fin N, ∑ j : Fin N, ∑ k : Fin N, ∑ l : Fin N, indA i j k l)
      = (N:ℝ) * ((N:ℝ) - 1) ^ 2 := by
  have key : ∀ i : Fin N,
      (∑ j : Fin N, ∑ k : Fin N, ∑ l : Fin N, indA i j k l) = ((N:ℝ) - 1) ^ 2 := by
    intro i
    simp_rw [indA, ← Finset.mul_sum, sum_indicator_ne, ← Finset.sum_mul]
    rw [← Finset.sum_mul_sum, sum_indicator_eq_one, sum_indicator_ne]
    ring
  rw [Finset.sum_congr rfl fun i _ => key i]
  simp [Finset.card_univ]

theorem sum_indB (N : ℕ) :
    (∑ i : Fin N, ∑ j : Fin N, ∑ k : Fin N, ∑ l : Fin N, indB i j k l)
      = (N:ℝ) * ((N:ℝ) - 1) ^ 2 := by
  rw [Finset.sum_comm]
  have key : ∀ j : Fin N,
      (∑ i : Fin N, ∑ k : Fin N, ∑ l : Fin N, indB i j k l) = ((N:ℝ) - 1) ^ 2 := by
    intro j
    simp_rw [indB, ← Finset.mul_sum, sum_indicator_eq_one, mul_one]
    rw [← Finset.sum_mul_sum, sum_indicator_ne]
    ring
  rw [Finset.sum_congr rfl fun j _ => key j]
  simp [Finset.card_univ]

theorem sum_indC (N : ℕ) :
    (∑ i : Fin N, ∑ j : Fin N, ∑ k : Fin N, ∑ l : Fin N, indC i j k l)
      = (N:ℝ) * ((N:ℝ) - 1) := by
  have key : ∀ i j : Fin N,
      (∑ k : Fin N, ∑ l : Fin N, indC i j k l) = (if i = j then (0:ℝ) else 1) := by
    intro i j
    simp_rw [indC, ← Finset.mul_sum, sum_indicator_eq_one, mul_one]
    rw [← Finset.mul_sum, sum_indicator_eq_one, mul_one]
  simp_rw [key]
  rw [Finset.sum_congr rfl fun i _ => sum_indicator_ne' i]
  simp [Finset.card_univ]
  ring

theorem sum_pairedWalk (N : ℕ) :
    (∑ i : Fin N, ∑ j : Fin N, ∑ k : Fin N, ∑ l : Fin N, pairedWalk i j k l) =
      2 * (N : ℝ) * ((N : ℝ) - 1) ^ 2 - (N : ℝ) * ((N : ℝ) - 1) := by
  have hsplit : (∑ i : Fin N, ∑ j : Fin N, ∑ k : Fin N, ∑ l : Fin N, pairedWalk i j k l)
      = (∑ i : Fin N, ∑ j : Fin N, ∑ k : Fin N, ∑ l : Fin N, indA i j k l)
        + (∑ i : Fin N, ∑ j : Fin N, ∑ k : Fin N, ∑ l : Fin N, indB i j k l)
        - (∑ i : Fin N, ∑ j : Fin N, ∑ k : Fin N, ∑ l : Fin N, indC i j k l) := by
    simp_rw [pairedWalk_decomp, Finset.sum_sub_distrib, Finset.sum_add_distrib]
  rw [hsplit, sum_indA, sum_indB, sum_indC]
  ring

/-- **Exact fourth trace moment of the Rademacher Wigner ensemble.** -/
theorem expect_trace_W_four (N : ℕ) :
    expect (fun g : Config N => ((W g) ^ 4).trace) =
      2 * (N : ℝ) * ((N : ℝ) - 1) ^ 2 - (N : ℝ) * ((N : ℝ) - 1) := by
  have h1 : ∀ g : Config N, ((W g) ^ 4).trace =
      ∑ i : Fin N, ∑ j : Fin N, ∑ k : Fin N, ∑ l : Fin N,
        entry g i j * entry g j k * entry g k l * entry g l i := trace_W_four
  simp only [h1]
  rw [expect_sum]
  have h2 : ∀ i : Fin N,
      expect (fun g : Config N => ∑ j : Fin N, ∑ k : Fin N, ∑ l : Fin N,
        entry g i j * entry g j k * entry g k l * entry g l i)
      = ∑ j : Fin N, ∑ k : Fin N, ∑ l : Fin N, pairedWalk i j k l := by
    intro i
    rw [expect_sum]
    refine Finset.sum_congr rfl fun j _ => ?_
    rw [expect_sum]
    refine Finset.sum_congr rfl fun k _ => ?_
    rw [expect_sum]
    exact Finset.sum_congr rfl fun l _ => expect_term i j k l
  rw [Finset.sum_congr rfl fun i _ => h2 i, sum_pairedWalk]

end RademacherWigner