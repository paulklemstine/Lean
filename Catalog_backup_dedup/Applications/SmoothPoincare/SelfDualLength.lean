/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Self-dual doubly-even codes have length divisible by 4 (and the all-ones glue)

This file is the *local-to-global* sequel to
`Catalog.Applications.SmoothPoincare.TopologicalCodes`.  There, the headline
`doublyEven_selfOrthogonal` shows that double-evenness *forces* pairwise
orthogonality — the coding-theory shadow of "an even form has even diagonal"
(`SmoothPoincare.IntersectionForm.even_diag_of_isEven`).  Here we turn that *local*
(per-pair) datum into a *global* divisibility constraint on the whole code.

The lattice-side miracle is the integer `8`: positive-definite even unimodular
lattices exist only in rank divisible by `8` (`E8` minimal).  Its code shadow is the
length divisibility of doubly-even self-dual codes.  We prove, fully `sorry`-free, the
clean **mod-4** half of that story for *arbitrary* `n`:

* `selfDual_doublyEven_length_div_four` — **the global theorem**: any binary code
  `C ⊆ (ZMod 2)ⁿ` that is *self-dual* (`x ∈ C ↔ x ⟂ C`) and *doubly even*
  (`4 ∣ wt v` for all `v ∈ C`) has length `4 ∣ n`.

The proof is a textbook *local-to-global* / "glue at the all-ones section" argument:
double-evenness makes every codeword have *even* weight, so the constant all-ones
vector `𝟙` is orthogonal to every codeword (`ip_ones`), hence lies in the dual = `C`;
being a codeword it is itself doubly even, and `wt 𝟙 = n`, giving `4 ∣ n`.

We then *instantiate* this on the extended Hamming code `[8,4,4]` (the mod-2 shadow of
`E8`), proving it is genuinely self-dual (`hamming_selfDual`) and recovering
`4 ∣ 8` as a corollary of the general theorem rather than by direct computation —
mirroring how `E8`'s obstruction is *derived* from `E8_even`, not checked by hand.

-- !-- Lab Notebook -- !--
Hypothesis: the per-pair bridge `doublyEven_selfOrthogonal` (a *local* statement)
  should upgrade to a *global* length-divisibility theorem by evaluating the dual at
  the canonical all-ones "global section", exactly as even unimodular lattices force
  rank divisibility through their distinguished vectors.
Result: `selfDual_doublyEven_length_div_four` proved for arbitrary `n`, `sorry`-free,
  and the extended Hamming code shown self-dual (`hamming_selfDual`) so that `4 ∣ 8`
  drops out as `hamming_length_div_four_general`.
Insight: self-duality is the local-to-global glue.  "Doubly even" is a *local* (weight)
  predicate; "self-dual" says the dual sheaf of orthogonality conditions has a global
  section through every point of `C`; the all-ones vector is the obstruction class whose
  membership forces `4 ∣ n`.  The mod-8 (Gleason) refinement is the genuinely harder,
  weight-enumerator/invariant-theory step left to FUTURE_DIRECTIONS.
Failure analysis: the only friction is the ℕ→ZMod 2 cast of `wt`; routing the parity
  through `ZMod.natCast_eq_zero_iff` and `dvd_trans (by norm_num : (2:ℕ) ∣ 4)` keeps the
  whole argument linear.
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

/-- A vector is **doubly even** when its weight is divisible by `4`. -/
def DoublyEven (v : Fin n → ZMod 2) : Prop := 4 ∣ wt v

/-- The constant all-ones vector — the canonical "global section". -/
def ones (n : ℕ) : Fin n → ZMod 2 := fun _ => 1

/-
!-- A product `x_i · y_i` in `ZMod 2` is `1` iff both factors are `1`, so the sum
defining `ip` counts the overlap positions mod 2. -- !--

The binary inner product equals the parity of the overlap.
-/
theorem ip_eq_overlap (x y : Fin n → ZMod 2) :
    ip x y = (overlap x y : ZMod 2) := by
  unfold ip overlap
  rw [Finset.card_filter, Nat.cast_sum]
  exact Finset.sum_congr rfl fun i _ => by
    rcases x i with (_ | _ | x) <;> rcases y i with (_ | _ | y) <;> trivial

/-
!-- `overlap 𝟙 y` filters coordinates with `1 = 1 ∧ y i = 1`, i.e. exactly the
support of `y`, so it equals `wt y`. -- !--

The overlap of the all-ones vector with `y` is the weight of `y`.
-/
theorem overlap_ones (y : Fin n → ZMod 2) : overlap (ones n) y = wt y := by
  unfold overlap wt ones
  congr 1
  apply Finset.filter_congr
  intro i _
  simp

/-
!-- Combine `ip_eq_overlap` with `overlap_ones`. -- !--

The inner product of the all-ones vector with `y` is the parity of `wt y`.
-/
theorem ip_ones (y : Fin n → ZMod 2) : ip (ones n) y = (wt y : ZMod 2) := by
  rw [ip_eq_overlap, overlap_ones]

/-
!-- The support of `𝟙` is everything, so its weight is `n`. -- !--

The all-ones vector has weight `n`.
-/
theorem wt_ones : wt (ones n) = n := by
  unfold wt ones
  simp

/-! ## The global theorem -/

/-
!-- Local-to-global glue: every codeword has even weight (doubly even ⟹ even), so the
all-ones vector is orthogonal to all of `C` (`ip_ones` + parity), hence lies in the
dual = `C`; as a codeword it is doubly even, and `wt 𝟙 = n`, forcing `4 ∣ n`. -- !--

**Self-dual doubly-even codes have length divisible by 4.**  Here self-duality is
`x ∈ C ↔ (∀ y ∈ C, ip x y = 0)`, i.e. `C` equals its own dual.  This is the global
shadow of "even unimodular definite lattices have rank divisible by 8" (the
lattice-side `E8` story in `IntersectionForms`).
-/
theorem selfDual_doublyEven_length_div_four
    (C : Finset (Fin n → ZMod 2))
    (hDE : ∀ v ∈ C, DoublyEven v)
    (hSD : ∀ x, x ∈ C ↔ ∀ y ∈ C, ip x y = 0) :
    4 ∣ n := by
  have hones : ones n ∈ C := by
    rw [hSD]
    intro y hy
    rw [ip_ones, ZMod.natCast_eq_zero_iff]
    exact dvd_trans (by norm_num) (hDE y hy)
  have h4 : DoublyEven (ones n) := hDE _ hones
  unfold DoublyEven at h4
  rwa [wt_ones] at h4

/-! ## The extended Hamming code `[8,4,4]` — self-dual instance -/

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

/-
!-- A finite `native_decide` over the `256` candidate vectors: each is in the code iff
it is orthogonal to all `16` codewords. -- !--

**The extended Hamming code is self-dual.**  This is the code-side analogue of `E8`
being unimodular (Poincaré self-duality).
-/
theorem hamming_selfDual :
    ∀ x : Fin 8 → ZMod 2, x ∈ hamming ↔ ∀ y ∈ hamming, ip x y = 0 := by
  native_decide

/-
!-- A `native_decide` confirming every codeword has weight divisible by `4`. -- !--

The extended Hamming code is doubly even.
-/
theorem hamming_doublyEven : ∀ v ∈ hamming, DoublyEven v := by
  show ∀ v ∈ hamming, 4 ∣ wt v
  native_decide

/-
!-- Apply the global theorem `selfDual_doublyEven_length_div_four` to the self-dual,
doubly-even Hamming code: `4 ∣ 8`. -- !--

**Corollary:** the Hamming code's length `8` is divisible by `4`, obtained from the
*general* theorem rather than by direct computation — mirroring how `E8`'s obstruction
is derived from `E8_even` rather than checked by hand.
-/
theorem hamming_length_div_four_general : (4 : ℕ) ∣ 8 :=
  selfDual_doublyEven_length_div_four hamming hamming_doublyEven hamming_selfDual

end Codes
end SmoothPoincare