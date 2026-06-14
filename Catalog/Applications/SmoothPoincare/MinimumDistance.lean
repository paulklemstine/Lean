/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Minimum distance, the weight enumerator of `[8,4,4]`, and self-dual ⟹ even weights

Companion to `Catalog.Applications.SmoothPoincare.SelfDualLength`.  Where that file
extracts a *global length* invariant from the local bridge theorem, this file extracts
the *distance spectrum* — the combinatorial avatar of the "fine arithmetic" that
distinguishes smooth structures (catalog Research Direction 3).

Contents (all `sorry`-free):

* `selfDual_even_weight` — **general theorem**: in any binary *self-dual* code every
  codeword has *even* weight.  This is the unconditional companion of the doubly-even
  hypothesis used in `SelfDualLength`: `ip x x = (wt x mod 2)`, and self-duality makes
  `ip x x = 0`.  (Lattice shadow: a unimodular *even* form has even diagonal.)
* `hamming_minDist_lower` / `hamming_minDist_attained` — the **minimum distance is 4**:
  every nonzero codeword has weight `≥ 4`, and weight `4` is attained.  Together these
  pin the parameters `[n=8, k=4, d=4]` of the extended Hamming code.
* `hamming_weightEnum_0/4/8` — the **complete weight enumerator** `1 + 14·x⁴ + x⁸`:
  exactly `1` word of weight `0`, `14` of weight `4`, `1` of weight `8`, accounting for
  all `16` codewords.  This is the explicit MacWilliams-self-dual weight polynomial of
  the mod-2 shadow of `E8`.

-- !-- Lab Notebook -- !--
Hypothesis: the catalog's `hamming` code, being the mod-2 shadow of `E8`, should carry
  a sharp `[8,4,4]` distance spectrum whose weight enumerator is the order-8
  Gleason-invariant polynomial `1 + 14x⁴ + x⁸`; and self-duality alone (no double
  evenness) should already force even weights.
Result: `selfDual_even_weight` proved generally; the `[8,4,4]` parameters and the full
  weight enumerator `1 + 14x⁴ + x⁸` proved by `native_decide`, accounting for all 16
  codewords (`1 + 14 + 1 = 16`).
Insight: the diagonal pairing `ip x x` collapses to `wt x mod 2` because `t² = t` in
  `ZMod 2`; self-duality then *is* the statement that this diagonal vanishes — the exact
  code-side mirror of "even diagonal" on the lattice side.  The weight enumerator being
  supported only on `{0,4,8}` is the finite fingerprint that the next cycle should test
  against rank-16 lattice pairs (`E8⊕E8` vs `D16⁺`).
Failure analysis: `Finset.min'`/`inf'` definitions of minimum distance drag in
  nonemptiness side-goals; stating the spectrum as a lower bound + attainment pair sides
  steps this entirely and is strictly more informative.
-/

import Mathlib

open scoped BigOperators

namespace SmoothPoincare
namespace Codes

variable {n : ℕ}

/-! ## Core definitions (self-contained mirror of `TopologicalCodes`) -/

/-- **Hamming weight**: the number of nonzero coordinates of a binary vector. -/
def wt (v : Fin n → ZMod 2) : ℕ := (Finset.univ.filter (fun i => v i = 1)).card

/-- **Overlap**: the number of coordinates where both vectors equal `1`. -/
def overlap (x y : Fin n → ZMod 2) : ℕ :=
  (Finset.univ.filter (fun i => x i = 1 ∧ y i = 1)).card

/-- **Binary inner product** in `ZMod 2`. -/
def ip (x y : Fin n → ZMod 2) : ZMod 2 := ∑ i, x i * y i

/-
!-- A product `x_i · y_i` in `ZMod 2` is `1` iff both factors are `1`. -- !--

The binary inner product equals the parity of the overlap.
-/
theorem ip_eq_overlap (x y : Fin n → ZMod 2) :
    ip x y = (overlap x y : ZMod 2) := by
  unfold ip overlap
  rw [Finset.card_filter, Nat.cast_sum]
  exact Finset.sum_congr rfl fun i _ => by
    rcases x i with (_ | _ | x) <;> rcases y i with (_ | _ | y) <;> trivial

/-
!-- `overlap x x` filters coordinates with `x i = 1 ∧ x i = 1`, i.e. the support of
`x`, so it equals `wt x`. -- !--

The self-overlap is the weight.
-/
theorem overlap_self (x : Fin n → ZMod 2) : overlap x x = wt x := by
  unfold overlap wt
  congr 1
  apply Finset.filter_congr
  intro i _
  simp

/-
!-- Combine `ip_eq_overlap` with `overlap_self`. -- !--

The diagonal inner product is the parity of the weight.
-/
theorem ip_self (x : Fin n → ZMod 2) : ip x x = (wt x : ZMod 2) := by
  rw [ip_eq_overlap, overlap_self]

/-! ## General theorem: self-dual codes have even weights -/

/-
!-- For a self-dual code, `x ∈ C` is orthogonal to all of `C`, in particular to itself,
so `ip x x = 0`; but `ip x x = wt x mod 2`, hence `2 ∣ wt x`. -- !--

**In a self-dual binary code, every codeword has even weight.**  This is the
unconditional lattice-shadow of "a unimodular even form has even diagonal", and the
companion to the doubly-even hypothesis of `SelfDualLength`.
-/
theorem selfDual_even_weight
    (C : Finset (Fin n → ZMod 2))
    (hSD : ∀ x, x ∈ C ↔ ∀ y ∈ C, ip x y = 0)
    {x : Fin n → ZMod 2} (hx : x ∈ C) :
    2 ∣ wt x := by
  have hxx : ip x x = 0 := (hSD x).1 hx x hx
  rw [ip_self, ZMod.natCast_eq_zero_iff] at hxx
  exact hxx

/-! ## The extended Hamming code `[8,4,4]` -/

/-- Generator matrix of the extended Hamming code `RM(1,3)`. -/
def hammingGen : Fin 4 → Fin 8 → ZMod 2 :=
  ![ ![1,1,1,1,1,1,1,1],
     ![0,0,0,0,1,1,1,1],
     ![0,0,1,1,0,0,1,1],
     ![0,1,0,1,0,1,0,1] ]

/-- Encoding map: `a ↦ ∑ aᵢ · gen i`. -/
def encode (a : Fin 4 → ZMod 2) : Fin 8 → ZMod 2 := fun j => ∑ i, a i * hammingGen i j

/-- The **extended Hamming code** as the image of the encoder. -/
def hamming : Finset (Fin 8 → ZMod 2) := Finset.image encode Finset.univ

/-! ### Minimum distance is 4 -/

/-
!-- `native_decide`: every one of the 16 codewords other than `0` has weight `≥ 4`. -- !--

**Lower bound:** every nonzero Hamming codeword has weight at least `4`.
-/
theorem hamming_minDist_lower :
    ∀ v ∈ hamming, v ≠ 0 → 4 ≤ wt v := by
  native_decide

/-
!-- `native_decide`: e.g. the second generator row has weight exactly 4. -- !--

**Attainment:** there is a nonzero Hamming codeword of weight exactly `4`, so the
minimum distance equals `4` — the `d` in the parameter triple `[8,4,4]`.
-/
theorem hamming_minDist_attained :
    ∃ v ∈ hamming, v ≠ 0 ∧ wt v = 4 := by
  native_decide

/-! ### The complete weight enumerator `1 + 14·x⁴ + x⁸` -/

/-
!-- `native_decide`: only the zero word has weight `0`. -- !--
There is exactly `1` codeword of weight `0`.
-/
theorem hamming_weightEnum_0 :
    (hamming.filter (fun v => wt v = 0)).card = 1 := by
  native_decide

/-
!-- `native_decide`: the `14` "middle" codewords have weight `4`. -- !--
There are exactly `14` codewords of weight `4`.
-/
theorem hamming_weightEnum_4 :
    (hamming.filter (fun v => wt v = 4)).card = 14 := by
  native_decide

/-
!-- `native_decide`: only the all-ones word has weight `8`. -- !--
There is exactly `1` codeword of weight `8`.
-/
theorem hamming_weightEnum_8 :
    (hamming.filter (fun v => wt v = 8)).card = 1 := by
  native_decide

/-
!-- `1 + 14 + 1 = 16`: the three strata `{0,4,8}` exhaust all codewords. -- !--

**The weight enumerator accounts for every codeword:** the supports at weights
`0, 4, 8` sum to the full `16 = 2⁴`, confirming the enumerator `1 + 14x⁴ + x⁸` is
complete.
-/
theorem hamming_weightEnum_complete :
    (hamming.filter (fun v => wt v = 0)).card
      + (hamming.filter (fun v => wt v = 4)).card
      + (hamming.filter (fun v => wt v = 8)).card = 16 := by
  rw [hamming_weightEnum_0, hamming_weightEnum_4, hamming_weightEnum_8]

end Codes
end SmoothPoincare