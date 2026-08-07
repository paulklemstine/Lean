/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Pythagorean.BrillNoether.Divisors
import Pythagorean.BrillNoether.Reduced
import Pythagorean.BrillNoether.ReducedUnique
import Pythagorean.BrillNoether.ResidualDuality

/-!
# Upper bounds for the Baker–Norine rank

Every result about the Baker–Norine rank in this catalogue so far is a *lower*
bound: `Divisors.lean`, `Reduced.lean` and `SetFiringRank.lean` all produce
divisors of guaranteed rank.  Nothing so far can show that a rank bound is
*sharp*, and consequently nothing can refute a proposed improvement.

This file supplies the missing half.  The engine is the uniqueness of `q`-reduced
representatives (`BrillNoetherReducedUnique.reduced_unique`): a `q`-reduced
divisor with a *negative* number of chips at the base vertex `q` is not linearly
equivalent to any effective divisor.  Subtracting `r` chips at `q` from a
`q`-reduced divisor keeps it `q`-reduced, so we obtain the fundamental estimate

  `r(D) ≤ D₀ q`  for the `q`-reduced representative `D₀` of `D` and *every* `q`.

## Main results

* `not_rankAtLeast_zero_of_isReduced_neg` — a `q`-reduced divisor with negative
  value at `q` has no effective representative.
* `not_rankAtLeast_of_sub_isReduced_neg` — the practical form: if some effective
  `E` of degree `r` makes `D - E` (after an explicit chip-firing move) `q`-reduced
  with a negative value at `q`, then `r(D) < r`.
* `le_reduced_of_rankAtLeast` and `rankBN_le_reduced` — `r(D) ≤ D₀ q` for every
  base vertex `q`, in the `RankAtLeast` and in the integer-valued `rankBN` form.
* `rankBN_eq_of_between` — a packaging lemma turning a matching lower and upper
  bound into an exact value of `rankBN`.
-/

open Finset SimpleGraph

namespace BrillNoetherUpper

open BrillNoetherDivisor BrillNoetherReduced BrillNoetherReducedUnique BrillNoetherResidual

variable {V : Type*} [Fintype V] [DecidableEq V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-! ## Reduced divisors with debt at the base vertex -/

/-- Subtracting chips at the base vertex preserves `q`-reducedness: the reducedness
condition never looks at the value of the divisor at `q`. -/
theorem isReduced_sub_base {q : V} {D : Divisor V} (hred : IsReduced G q D) (c : ℤ) :
    IsReduced G q (fun v => if v = q then D v - c else D v) := by
  refine ⟨fun v hv => by simpa [hv] using hred.1 v hv, fun S hS hne => ?_⟩
  obtain ⟨v, hvS, hv⟩ := hred.2 S hS hne
  refine ⟨v, hvS, ?_⟩
  have hvq : v ≠ q := by
    intro h
    exact (Finset.mem_erase.mp (hS hvS)).1 h
  simpa [hvq] using hv

/-- **A reduced divisor in debt is not effective up to equivalence.**  If `D` is
`q`-reduced and carries a negative number of chips at `q`, then no divisor in its
class is effective, i.e. `r(D) < 0`. -/
theorem not_rankAtLeast_zero_of_isReduced_neg (hG : G.Connected) {q : V} {D : Divisor V}
    (hred : IsReduced G q D) (hneg : D q < 0) : ¬ RankAtLeast G D 0 := by
  intro h
  have := (rankAtLeast_zero_iff_reduced_nonneg G hG (linEquiv_refl G D) hred).mp h
  omega

/-! ## The upper bound -/

/-- If a divisor has rank at least `r` then subtracting any effective divisor of
degree `r` leaves something of nonnegative rank. -/
theorem rankAtLeast_zero_sub_of_rankAtLeast {D E : Divisor V} {r : ℕ}
    (h : RankAtLeast G D r) (hE : Effective E) (hdeg : deg E = r) :
    RankAtLeast G (D - E) 0 := by
  obtain ⟨f, hf⟩ := h E hE hdeg
  exact (rankAtLeast_zero_iff G _).mpr ⟨f, hf⟩

/-- **Refuting a rank bound.**  Suppose `E` is effective of degree `r` and the
divisor `D - E` is linearly equivalent to a `q`-reduced divisor `F` with `F q < 0`.
Then `D` does *not* have rank `r`. -/
theorem not_rankAtLeast_of_sub_isReduced_neg (hG : G.Connected) {q : V}
    {D E F : Divisor V} {r : ℕ} (hE : Effective E) (hdeg : deg E = r)
    (hlin : LinEquiv G (D - E) F) (hred : IsReduced G q F) (hneg : F q < 0) :
    ¬ RankAtLeast G D r := by
  intro h
  have h0 : RankAtLeast G (D - E) 0 := rankAtLeast_zero_sub_of_rankAtLeast G h hE hdeg
  have hF : RankAtLeast G F 0 := rankAtLeast_of_linEquiv G hlin h0
  exact not_rankAtLeast_zero_of_isReduced_neg G hG hred hneg hF

/-- The special case in which `D - E` is *itself* `q`-reduced. -/
theorem not_rankAtLeast_of_sub_isReduced_neg' (hG : G.Connected) {q : V}
    {D E : Divisor V} {r : ℕ} (hE : Effective E) (hdeg : deg E = r)
    (hred : IsReduced G q (D - E)) (hneg : (D - E) q < 0) :
    ¬ RankAtLeast G D r :=
  not_rankAtLeast_of_sub_isReduced_neg G hG hE hdeg (linEquiv_refl G _) hred hneg

/-- **The fundamental rank estimate.**  For every base vertex `q`, the Baker–Norine
rank of `D` is at most the number of chips its `q`-reduced representative carries
at `q`. -/
theorem le_reduced_of_rankAtLeast (hG : G.Connected) {q : V} {D D₀ : Divisor V} {r : ℕ}
    (hlin : LinEquiv G D D₀) (hred : IsReduced G q D₀) (h : RankAtLeast G D r) :
    (r : ℤ) ≤ D₀ q := by
  classical
  by_contra hcon
  push_neg at hcon
  -- subtract `r` chips at `q`
  set E : Divisor V := fun v => if v = q then (r : ℤ) else 0 with hE
  have hEeff : Effective E := by intro v; by_cases hv : v = q <;> simp [hE, hv]
  have hEdeg : deg E = r := by simp [deg, hE]
  set F : Divisor V := fun v => if v = q then D₀ v - (r : ℤ) else D₀ v with hF
  have hredF : IsReduced G q F := isReduced_sub_base G hred (r : ℤ)
  have hnegF : F q < 0 := by simp only [hF, if_pos rfl]; omega
  have hlinF : LinEquiv G (D - E) F := by
    obtain ⟨f, hf⟩ := hlin
    refine ⟨f, ?_⟩
    funext v
    by_cases hv : v = q
    · subst hv
      simp only [hF, hE, if_pos rfl, Pi.sub_apply, Pi.add_apply, hf, if_true]
      ring
    · simp only [hF, hE, if_neg hv, Pi.sub_apply, Pi.add_apply, hf]
      ring
  exact not_rankAtLeast_of_sub_isReduced_neg G hG hEeff hEdeg hlinF hredF hnegF h

/-- The same estimate for the integer-valued rank `rankBN`. -/
theorem rankBN_le_reduced [Nonempty V] (hG : G.Connected) {q : V} {D D₀ : Divisor V}
    (hlin : LinEquiv G D D₀) (hred : IsReduced G q D₀) :
    rankBN G D ≤ max (-1) (D₀ q) := by
  rcases le_or_gt (rankBN G D) (-1) with h | h
  · exact h.trans (le_max_left _ _)
  · refine le_trans ?_ (le_max_right (-1 : ℤ) (D₀ q))
    have h0 : 0 ≤ rankBN G D := by omega
    obtain ⟨r, hr⟩ : ∃ r : ℕ, rankBN G D = (r : ℤ) := ⟨(rankBN G D).toNat, by omega⟩
    rw [hr]
    have hrk : RankAtLeast G D r := by
      rw [← rankBN_ge_iff G D r, hr]
    exact le_reduced_of_rankAtLeast G hG hlin hred hrk

/-- **Packaging an exact rank.**  A matching lower and upper bound pins down `rankBN`. -/
theorem rankBN_eq_of_between [Nonempty V] {D : Divisor V} {r : ℕ}
    (hlow : RankAtLeast G D r) (hhigh : ¬ RankAtLeast G D (r + 1)) :
    rankBN G D = (r : ℤ) := by
  have h1 : (r : ℤ) ≤ rankBN G D := (rankBN_ge_iff G D r).mpr hlow
  have h2 : ¬ ((r : ℤ) + 1 ≤ rankBN G D) := by
    intro hc
    exact hhigh ((rankBN_ge_iff G D (r + 1)).mp (by push_cast; omega))
  omega

end BrillNoetherUpper