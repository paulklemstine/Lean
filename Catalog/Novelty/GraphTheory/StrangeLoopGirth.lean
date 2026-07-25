/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# I Am a Strange Loop, Part VI: The Girth of a Tangled Hierarchy

Part II showed that an oriented (asymmetric) hierarchy admits no strange loop of
length `1` or `2`, while genuine loops appear at length `3` — the minimum
"strange-loop length".  Here we go deeper and compute the loop length exactly for
a tunable family of hierarchies, exhibiting *girth* as a controllable resource.

We study the cyclic **successor** relation `a ↦ a + 1` on `ZMod n`, the
prototypical tangled hierarchy (rock-paper-scissors when `n = 3`).  A closed walk
of length `k` in this relation forces the running index to advance by `k` and
return to its start, which is possible exactly when `n ∣ k`.  Consequently:

* a strange loop of length `n` always exists (`succ_loop_exists`);
* every closed loop has length divisible by `n` (`succ_loop_dvd`);
* hence the **minimum strange-loop length ("girth") is exactly `n`**
  (`succ_min_loop_length`).

This bridges the **combinatorics of tangled hierarchies** with the **arithmetic
of cyclic groups**: the depth of self-reference realizable in a hierarchy is
governed by a divisibility condition, and can be tuned to any prescribed value
`n ≥ 3`.  The generic bound "girth ≥ 3" of Part II becomes the exact identity
"girth = n" for these relations.

This file is fully self-contained.
-/
import Mathlib

namespace StrangeLoop.Girth

open Relation

/-! ## Closed loops indexed by natural numbers with wraparound -/

/-- A **closed loop of length `k`** in a relation `R`: an assignment `v` of
levels to positions `0, 1, …, k-1` with consecutive positions `R`-related and
the last position wrapping back to the first (index arithmetic modulo `k`). -/
def IsLoopN {V : Type*} (R : V → V → Prop) (k : ℕ) (v : ℕ → V) : Prop :=
  0 < k ∧ ∀ i, i < k → R (v i) (v ((i + 1) % k))

/-! ## The successor relation on `ZMod n` -/

/-- The cyclic successor relation `a ↦ a + 1` on `ZMod n`. -/
def succR (n : ℕ) : ZMod n → ZMod n → Prop := fun a b => b = a + 1

/-- **A strange loop of length `n` exists.**  The tautological assignment
`i ↦ i` traverses the whole cycle `0 → 1 → ⋯ → n-1 → 0`. -/
theorem succ_loop_exists {n : ℕ} (hn : 0 < n) :
    IsLoopN (succR n) n (fun i => (i : ZMod n)) := by
  refine ⟨hn, ?_⟩
  intro i _
  show ((((i + 1) % n : ℕ) : ZMod n)) = (i : ZMod n) + 1
  rw [ZMod.natCast_mod]
  push_cast
  ring

/-- **Affine structure of a loop.**  Along the non-wrapping part of a closed
loop of the successor relation, the value advances linearly: `v j = v 0 + j`. -/
theorem chain_affine {n k : ℕ} (v : ℕ → ZMod n)
    (hchain : ∀ i, i + 1 < k → v (i + 1) = v i + 1) :
    ∀ j, j < k → v j = v 0 + (j : ZMod n) := by
  intro j
  induction j with
  | zero => intro _; simp
  | succ m ih =>
    intro hj
    have hm : m < k := Nat.lt_of_succ_lt hj
    rw [hchain m hj, ih hm]
    push_cast; ring

/-- **Every closed loop has length divisible by `n`.**  Traversing a closed
walk of the successor relation advances the index by the loop length and must
return to the start, forcing `n ∣ k`. -/
theorem succ_loop_dvd {n k : ℕ} (v : ℕ → ZMod n)
    (h : IsLoopN (succR n) k v) : n ∣ k := by
  obtain ⟨hk, hloop⟩ := h
  have hchain : ∀ i, i + 1 < k → v (i + 1) = v i + 1 := by
    intro i hi
    have := hloop i (Nat.lt_of_succ_lt hi)
    simpa [succR, Nat.mod_eq_of_lt hi] using this
  have hlast := hloop (k - 1) (by omega)
  have hmod : (k - 1 + 1) % k = 0 := by
    have hkk : k - 1 + 1 = k := by omega
    rw [hkk, Nat.mod_self]
  rw [hmod] at hlast
  have haff := chain_affine v hchain (k - 1) (by omega)
  rw [succR] at hlast
  rw [haff] at hlast
  have hkc : ((k - 1 : ℕ) : ZMod n) + 1 = (k : ZMod n) := by
    rw [Nat.cast_sub hk]; ring
  have e : v 0 + (k : ZMod n) = v 0 := by rw [← hkc]; linear_combination -hlast
  have hk0 : (k : ZMod n) = 0 := left_eq_add.mp e.symm
  exact (CharP.cast_eq_zero_iff (ZMod n) n k).mp hk0

/-- **The girth is exactly `n`.**  Every strange loop of the successor relation
on `ZMod n` has length at least `n`, and length `n` is attained.  The minimum
strange-loop length is therefore precisely `n` — self-referential depth is a
tunable resource. -/
theorem succ_min_loop_length {n : ℕ} (hn : 0 < n) :
    (∀ k v, IsLoopN (succR n) k v → n ≤ k) ∧
    (∃ v, IsLoopN (succR n) n v) := by
  refine ⟨?_, ⟨_, succ_loop_exists hn⟩⟩
  intro k v hloop
  exact Nat.le_of_dvd hloop.1 (succ_loop_dvd v hloop)

/-! ## Examples and boundary cases -/

/-- For the rock-paper-scissors hierarchy (`n = 3`) the girth is `3`: a genuine
strange loop `0 → 1 → 2 → 0` exists. -/
example : ∃ v, IsLoopN (succR 3) 3 v := ⟨_, succ_loop_exists (by norm_num)⟩

/-- Boundary: no strange loop of length `2` exists in the `n = 3` hierarchy,
recovering Part II's "no length-2 loop" as an instance of `3 ∤ 2`. -/
example : ¬ ∃ v, IsLoopN (succR 3) 2 v := by
  rintro ⟨v, hv⟩
  have : (3 : ℕ) ∣ 2 := succ_loop_dvd v hv
  omega

/-- A deeper hierarchy: girth `7` is realizable, so self-reference of arbitrary
prescribed depth genuinely occurs. -/
example : ∃ v, IsLoopN (succR 7) 7 v := ⟨_, succ_loop_exists (by norm_num)⟩

#check @succ_loop_exists
#check @succ_loop_dvd
#check @succ_min_loop_length

/-! ## Synthesis

Part II bounded the girth of any oriented hierarchy from below by `3`.  Here the
successor relation on `ZMod n` realizes girth *exactly* `n`, tied to the cyclic
group's order through a divisibility law.  Tangled hierarchies thus carry a
precise arithmetic invariant — their girth — and Hofstadter's "the loop must run
through the hierarchy and return" is quantified: the shortest return has length
equal to the number of levels the cycle spans. -/
theorem girth_is_group_order {n k : ℕ} {v : ℕ → ZMod n}
    (hloop : IsLoopN (succR n) k v) : n ∣ k ∧ n ≤ k :=
  ⟨succ_loop_dvd v hloop, Nat.le_of_dvd hloop.1 (succ_loop_dvd v hloop)⟩

end StrangeLoop.Girth

/-
-- !-- Lab Notes -- !--

Hypothesis (Hypothesizer): Part II's generic bound "strange-loop length ≥ 3" for
oriented hierarchies should sharpen to an *exact* value for structured
hierarchies, controlled by an arithmetic invariant, making self-referential depth
a tunable resource.

Experiment (Experimenter): Modeled the cyclic successor relation `a ↦ a+1` on
`ZMod n`. Proved existence of a length-`n` loop (identity assignment) and, via an
affine-chain induction, that every closed loop has length divisible by `n`. Hence
girth `= n`.

Analysis (Analyst): The divisibility law `n ∣ k` is the crux; it follows because
traversing a closed walk advances the index by `k` and must return to start,
forcing `k ≡ 0 (mod n)`. The `n = 3` case reproduces Part II ("no length-2 loop"
because `3 ∤ 2`), confirming the new result strictly generalizes the old.

Critique (Critic): Verified no circularity — `girth_is_group_order` and
`succ_min_loop_length` are built from `succ_loop_dvd`/`succ_loop_exists`, both
proved earlier without self-reference. The loop definition uses honest index
wraparound `(i+1) % k`, so the boundary edge is not swept under the rug; the
example `¬ ∃ v, IsLoopN (succR 3) 2 v` exercises exactly that edge.

Synthesis (PI): Tangled hierarchies carry a precise arithmetic fingerprint — their
girth equals the cyclic group's order. Hofstadter's "the loop runs through the
hierarchy and returns" is quantified: the shortest return spans exactly `n`
levels.
-/