/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Topological error-correcting codes: the mod-2 shadow of even unimodular forms

The catalog's `SmoothPoincare` files build the *lattice* side of the smooth/topological
gap in dimension 4: the **even unimodular** intersection form `E8` (rank `8`), its
self-sum `E8 ⊕ E8` (rank `16`), and the Donaldson obstruction
`even_not_stdDiagonalizable`.  A recurring miracle there is the number **8**: even
unimodular *definite* lattices exist only in rank divisible by `8`, with `E8` the
minimal witness.

This file develops the **coding-theory shadow** of exactly that phenomenon.  Reducing
a unimodular even lattice modulo `2` (Construction A in reverse) produces a *binary
self-dual code*; the evenness of the form becomes the **doubly-even** condition (all
codeword weights divisible by `4`).  The combinatorial analogue of "rank divisible by
`8`" is "length divisible by `8`", and the minimal witness — the shadow of `E8` — is
the **extended Hamming code** `[8,4,4]`, the Reed–Muller code `RM(1,3)`.

We prove, fully `sorry`-free:

* `wt_add_overlap` — the Hamming inclusion–exclusion identity
  `wt(x+y) + 2·overlap(x,y) = wt x + wt y`, the combinatorial heart everything rests on.
* `doublyEven_selfOrthogonal` — **the bridge theorem**: any two codewords of weight
  divisible by `4` are orthogonal.  This is the binary mirror of "an even form has even
  diagonal" (`even_diag_of_isEven` / `isEven_of_even_diag` in `IntersectionForms`): a
  doubly-even code is automatically self-orthogonal.
* `hamming_doublyEven` — the extended Hamming code has all weights divisible by `4`
  (the code-side analogue of `E8_even`).
* `hamming_add_closed` / `hamming_selfOrthogonal` — closure under `+` and, via the
  bridge theorem, self-orthogonality (the analogue of `E8`'s self-duality / Donaldson
  evenness obstruction), obtained *without* a brute-force pairwise check.
* `hamming_length_div_four` — every codeword length-`8` constraint: the all-ones word
  lies in the code and has weight `8`, divisible by `4` (the code-side echo of the
  signature divisibility behind Rokhlin/Donaldson).

## References
* J. H. Conway, N. J. A. Sloane, *Sphere Packings, Lattices and Groups* (Construction A,
  Chapter 7): even unimodular lattices ↔ doubly-even self-dual codes.
* F. J. MacWilliams, N. J. A. Sloane, *The Theory of Error-Correcting Codes*.

-- !-- Lab Notebook -- !--
Hypothesis: the rank-divisible-by-8 obstruction governing even unimodular lattices
  (catalog `E8form`, `E8_even`, `even_not_stdDiagonalizable`) has a verbatim
  coding-theory shadow: doubly-even ⟹ self-orthogonal, with the extended Hamming
  `[8,4,4]` code as the mod-2 image of `E8`.
Result: all five headline theorems proved `sorry`-free.  `doublyEven_selfOrthogonal`
  is the load-bearing bridge; the explicit Hamming code's properties then follow by a
  cheap `decide` on its 16-element generator image plus the bridge theorem.
Insight: evenness/double-evenness is governed by a single divisibility identity
  (`wt_add_overlap`), exactly as form-evenness is governed by the diagonal
  (`isEven_of_even_diag`).  Self-orthogonality is then *derived*, never checked
  pairwise, mirroring how `E8`'s obstruction is derived from `E8_even`.
Failure analysis: the only subtlety is ℕ-subtraction in inclusion–exclusion; stating
  the identity additively (`wt(x+y) + 2·overlap = wt x + wt y`) and passing to ℤ for
  the divisibility step avoids it entirely.
-/

import Mathlib

-- Conceptually builds on `Catalog.Applications.SmoothPoincare.IntersectionForms`
-- (`E8form`, `E8_even`, `even_not_stdDiagonalizable`, `isEven_of_even_diag`,
-- `even_diag_of_isEven`); kept self-contained here so the file verifies standalone.

open scoped BigOperators

namespace SmoothPoincare
namespace Codes

variable {n : ℕ}

/-- **Hamming weight**: the number of nonzero coordinates of a binary vector. -/
def wt (v : Fin n → ZMod 2) : ℕ := (Finset.univ.filter (fun i => v i = 1)).card

/-- **Overlap**: the number of coordinates where both vectors equal `1`. -/
def overlap (x y : Fin n → ZMod 2) : ℕ :=
  (Finset.univ.filter (fun i => x i = 1 ∧ y i = 1)).card

/-- **Binary inner product** in `ZMod 2`; `selfOrthogonal` codes have all such products
zero. -/
def ip (x y : Fin n → ZMod 2) : ZMod 2 := ∑ i, x i * y i

/-
!-- Per-coordinate case check: only `(0,0),(1,0),(0,1),(1,1)` occur; in each the
contributions to both sides of `wt(x+y)+2·overlap = wt x + wt y` agree, so summing
over coordinates gives the identity. -- !--

**Inclusion–exclusion for Hamming weight.** Stated additively to avoid ℕ-subtraction:
`wt(x+y) + 2·overlap(x,y) = wt x + wt y`.
-/
theorem wt_add_overlap (x y : Fin n → ZMod 2) :
    wt (x + y) + 2 * overlap x y = wt x + wt y := by
  unfold wt overlap
  rw [ Finset.card_filter, Finset.card_filter, Finset.card_filter, Finset.card_filter ];
  rw [ Finset.mul_sum _ _ _ ] ; rw [ ← Finset.sum_add_distrib, ← Finset.sum_add_distrib ] ; congr ; ext i ; have := Fin.exists_fin_two.mp ⟨ x i, rfl ⟩ ; have := Fin.exists_fin_two.mp ⟨ y i, rfl ⟩ ; aesop;

/-
!-- `ip x y = ∑ x_i·y_i`; a product is `1` iff both factors are `1`, so the sum counts
overlap positions mod 2, i.e. `ip x y = (overlap x y : ZMod 2)`. -- !--

The binary inner product is the parity of the overlap.
-/
theorem ip_eq_overlap (x y : Fin n → ZMod 2) :
    ip x y = (overlap x y : ZMod 2) := by
  unfold ip overlap;
  rw [ Finset.card_filter, Nat.cast_sum ];
  exact Finset.sum_congr rfl fun i _ => by rcases x i with ( _ | _ | x ) <;> rcases y i with ( _ | _ | y ) <;> trivial;

/-- A vector is **doubly even** when its weight is divisible by `4`. -/
def DoublyEven (v : Fin n → ZMod 2) : Prop := 4 ∣ wt v

/-
!-- From `wt_add_overlap` in ℤ, `2·overlap = wt x + wt y − wt(x+y)`; if `4` divides
all three weights then `4 ∣ 2·overlap`, so `2 ∣ overlap`, so `ip x y = overlap mod 2
= 0`. -- !--

**The bridge theorem.** Two doubly-even vectors whose sum is also doubly even are
orthogonal.  This is the coding-theory mirror of "an even form has even diagonal"
(`SmoothPoincare.IntersectionForm.even_diag_of_isEven`): a doubly-even code is
automatically self-orthogonal.
-/
theorem doublyEven_selfOrthogonal (x y : Fin n → ZMod 2)
    (hx : DoublyEven x) (hy : DoublyEven y) (hxy : DoublyEven (x + y)) :
    ip x y = 0 := by
  convert ip_eq_overlap x y;
  exact Eq.symm ( ZMod.natCast_eq_zero_iff _ _ |>.2 <| Nat.dvd_of_mod_eq_zero <| by have := wt_add_overlap x y; obtain ⟨ k, hk ⟩ := hx; obtain ⟨ l, hl ⟩ := hy; obtain ⟨ m, hm ⟩ := hxy; omega )

/-! ## The extended Hamming code `[8,4,4]` — the mod-2 shadow of `E8` -/

/-- Generator matrix of the extended Hamming code `RM(1,3)`: the all-ones row together
with the three coordinate "address-bit" functions. -/
def hammingGen : Fin 4 → Fin 8 → ZMod 2 :=
  ![ ![1,1,1,1,1,1,1,1],
     ![0,0,0,0,1,1,1,1],
     ![0,0,1,1,0,0,1,1],
     ![0,1,0,1,0,1,0,1] ]

/-- Encoding map: a message `a ∈ (ZMod 2)⁴` maps to `∑ aᵢ · gen i`. -/
def encode (a : Fin 4 → ZMod 2) : Fin 8 → ZMod 2 := fun j => ∑ i, a i * hammingGen i j

/-- The **extended Hamming code** as the image of the encoder: a 16-element set of
length-`8` binary words. -/
def hamming : Finset (Fin 8 → ZMod 2) := Finset.image encode Finset.univ

/-
!-- Direct enumeration: the encoder image has 16 distinct words. -- !--

The extended Hamming code has `16 = 2⁴` codewords.
-/
theorem hamming_card : hamming.card = 16 := by
  native_decide

/-
!-- Encoding is ℤ/2-linear: `encode a + encode b = encode (a+b)` coordinatewise,
so the image is closed under addition. -- !--

The Hamming code is closed under addition (it is a linear code).
-/
theorem hamming_add_closed {x y : Fin 8 → ZMod 2}
    (hx : x ∈ hamming) (hy : y ∈ hamming) : x + y ∈ hamming := by
  by_contra hxy;
  unfold hamming at *;
  simp +zetaDelta at *;
  rcases hx with ⟨ a, rfl ⟩ ; rcases hy with ⟨ b, rfl ⟩ ; exact hxy ( a + b ) ( by ext j; simp +decide [ encode, Finset.sum_add_distrib, add_mul ] ) ;

/-
!-- Every one of the 16 codewords has weight `0`, `4`, or `8`, all divisible by `4`;
check by `decide` over the generator image (the code-side analogue of `E8_even`). -- !--

**The Hamming code is doubly even**: every codeword has weight divisible by `4`.
This is the coding-theory analogue of `SmoothPoincare.IntersectionForm.E8_even`.
-/
theorem hamming_doublyEven {v : Fin 8 → ZMod 2} (hv : v ∈ hamming) : DoublyEven v := by
  have : ∀ v ∈ hamming, 4 ∣ wt v := by
    native_decide;
  exact this v hv

/-
!-- The all-ones word is `encode (1,0,0,0)`, so it lies in the code; its weight is `8`,
divisible by `4`. -- !--

The all-ones codeword lies in the Hamming code, with weight `8` divisible by `4` —
the code-side echo of the signature divisibility behind Donaldson/Rokhlin.
-/
theorem hamming_length_div_four :
    (fun _ => (1 : ZMod 2)) ∈ hamming ∧ DoublyEven (fun _ : Fin 8 => (1 : ZMod 2)) := by
  simp +decide [ DoublyEven ]

-- !-- Both codewords and their sum are doubly even (`hamming_doublyEven` +
-- `hamming_add_closed`), so `doublyEven_selfOrthogonal` gives orthogonality — no
-- pairwise brute force needed. -- !--
/-- **The Hamming code is self-orthogonal**, derived from double-evenness via the
bridge theorem `doublyEven_selfOrthogonal` rather than a brute-force pairwise check.
This mirrors how `E8`'s Donaldson obstruction is *derived* from `E8_even`. -/
theorem hamming_selfOrthogonal {x y : Fin 8 → ZMod 2}
    (hx : x ∈ hamming) (hy : y ∈ hamming) : ip x y = 0 :=
  doublyEven_selfOrthogonal x y (hamming_doublyEven hx) (hamming_doublyEven hy)
    (hamming_doublyEven (hamming_add_closed hx hy))

end Codes
end SmoothPoincare