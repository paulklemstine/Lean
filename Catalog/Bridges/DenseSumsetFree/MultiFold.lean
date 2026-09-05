import Mathlib
import Bridges.DenseSumsetFree.Basic
/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# From two summands to `t` summands

Avoiding two-fold sumsets automatically gives avoidance of `t`-fold sumsets
`A₁ + A₂ + ⋯ + A_t`: grouping `B = A₂ + ⋯ + A_t` only increases the size of the
second summand.  Consequently the polylogarithmic construction of `Main.lean`
also produces dense sets containing no `t`-fold sumset with all parts of size
`≥ C (log n)³`, for every `t ≥ 2` simultaneously.

## Main results

* `sumsetNat` — the iterated sumset of a list of finite sets of naturals;
* `avoidsSumsets_multifold` — a `k`-sumset-avoiding set avoids every `t`-fold
  sumset (`t ≥ 2`) whose parts all have `≥ k` elements;
* `exists_dense_set_avoiding_polylog_multifold_sumsets` — the resulting
  polylogarithmic, all-`t`-at-once, dense-set theorem.
-/
-- MISSING MODULE (not present in this repository): import Bridges.DenseSumsetFree.Main
open Finset Pointwise

namespace DenseSumsetFree

/-- The iterated sumset `A₁ + A₂ + ⋯ + A_t` of a list of finite sets of naturals,
realised as a right fold; the empty list gives `{0}`. -/
def sumsetNat (L : List (Finset ℕ)) : Finset ℕ := L.foldr (fun A acc => A + acc) {0}

@[simp] lemma sumsetNat_nil : sumsetNat [] = {0} := rfl

@[simp] lemma sumsetNat_cons (A : Finset ℕ) (L : List (Finset ℕ)) :
    sumsetNat (A :: L) = A + sumsetNat L := rfl

/-- An iterated sumset of nonempty sets is nonempty. -/
lemma sumsetNat_nonempty (L : List (Finset ℕ)) (h : ∀ A ∈ L, A.Nonempty) :
    (sumsetNat L).Nonempty := by
  induction L with
  | nil => simp
  | cons A L ih =>
    have hA : A.Nonempty := h A (by simp)
    simpa using hA.add (ih fun B hB => h B (by simp [hB]))

/-- Each part of an iterated sumset bounds its size from below. -/
lemma card_le_card_sumsetNat (L : List (Finset ℕ)) (k : ℕ) (hne : ∀ A ∈ L, A.Nonempty)
    (hk : ∀ A ∈ L, k ≤ A.card) (hL : L ≠ []) : k ≤ (sumsetNat L).card := by
  match L with
  | [] => exact absurd rfl hL
  | A :: L' =>
    have hA : k ≤ A.card := hk A (by simp)
    have hLne : (sumsetNat L').Nonempty :=
      sumsetNat_nonempty L' fun B hB => hne B (by simp [hB])
    have := Finset.card_le_card_add_right (s := A) hLne
    rw [sumsetNat_cons]
    omega

/-- **Two-fold avoidance implies `t`-fold avoidance.**  If `S` avoids all sumsets
`A + B` with `|A|, |B| ≥ k`, then for every `t ≥ 2` it contains no iterated sumset
`A₁ + ⋯ + A_t` all of whose parts have at least `k` elements. -/
theorem avoidsSumsets_multifold {S : Finset ℕ} {k : ℕ} (h : AvoidsSumsets S k)
    (L : List (Finset ℕ)) (hlen : 2 ≤ L.length) (hne : ∀ A ∈ L, A.Nonempty)
    (hk : ∀ A ∈ L, k ≤ A.card) : ¬ sumsetNat L ⊆ S := by
  match L with
  | [] => simp at hlen
  | [A] => simp at hlen
  | A :: B :: L' =>
    intro hsub
    have hA : k ≤ A.card := hk A (by simp)
    have htail : k ≤ (sumsetNat (B :: L')).card :=
      card_le_card_sumsetNat (B :: L') k (fun C hC => hne C (by simp [hC]))
        (fun C hC => hk C (by simp [hC])) (by simp)
    exact h A (sumsetNat (B :: L')) hA htail (by rwa [sumsetNat_cons] at hsub)

-- The two theorems that used to sit here, `exists_dense_set_avoiding_polylog_sumsets`
-- (the `(log n)³` theorem for two summands, formerly in the missing module
-- `Bridges.DenseSumsetFree.Main`) and its `t`-fold corollary
-- `exists_dense_set_avoiding_polylog_multifold_sumsets`, now live in
-- `Bridges.DenseSumsetFree.TwoSummands`, which obtains the two-summand statement as the
-- `t = 2` case of `exists_dense_set_avoiding_N_sumsets`.  Keeping them there breaks the
-- import cycle `MultiFold → Main → General → MultiFold`.

end DenseSumsetFree