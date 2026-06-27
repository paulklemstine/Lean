/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Direct sums (concatenation) of binary self-dual codes

This file is the **coding-theory mirror** of
`Catalog.Applications.SmoothPoincare.DirectSum`, where the orthogonal direct sum
`Q ⊕ R` of intersection forms is shown to be *closed* under the three structural
predicates (`Unimodular`, `IsEven`, `StdDiagonalizable`), with headline `E8 ⊕ E8`.

Under Construction A the orthogonal direct sum of even unimodular lattices reduces,
modulo `2`, to the **direct sum (coordinate concatenation)** of binary self-dual
codes.  This file develops that operation `C ⊕ D ⊆ (ZMod 2)^{m+n}` and proves the
exact code-side analogues of the lattice closure theorems:

* `wt_append` / `ip_append` — weight is *additive* and the binary inner product is
  *block-diagonal* under concatenation (the combinatorial shadow of the block-diagonal
  Gram matrix `diag(G_Q, G_R)`).
* `appendCode_card` — `|C ⊕ D| = |C|·|D|` (the code shadow of `det` multiplicativity
  used in `directSum_unimodular`).
* `appendCode_doublyEven` — double-evenness is closed under `⊕` (shadow of
  `directSum_isEven`).
* `appendCode_selfDual` — **the headline closure theorem**: self-duality is closed
  under `⊕` (the code shadow of `directSum_unimodular`, Poincaré self-duality being
  preserved by connected sum).
* `appendCode_length_div_eight` — Gleason length divisibility is *additive*: the direct
  sum of two doubly-even self-dual codes again has length divisible by `8`.

The headline application is `hamming ⊕ hamming`, the length-`16` direct sum of two
copies of the extended Hamming `[8,4,4]` code — the precise mod-2 shadow of the
rank-`16` lattice `E8 ⊕ E8` (`DirectSum.E8E8form`).  It is self-dual, doubly even, has
`256 = 16·16` codewords, and length `16` divisible by `8`, all *derived* from the
general closure theorems rather than by a brute-force `decide` over `2^16` vectors.

## References
* J. H. Conway, N. J. A. Sloane, *Sphere Packings, Lattices and Groups* (Construction A).
* F. J. MacWilliams, N. J. A. Sloane, *The Theory of Error-Correcting Codes*.

-- !-- Lab Notebook -- !--
Hypothesis: the lattice direct-sum closure theorems of `DirectSum.lean` (Unimodular,
  IsEven, StdDiagonalizable closed under `⊕`) have verbatim coding-theory shadows under
  coordinate concatenation, with `hamming ⊕ hamming` the mod-2 image of `E8 ⊕ E8`.
Result: all closure theorems (`appendCode_selfDual`, `appendCode_doublyEven`,
  `appendCode_card`) proved `sorry`-free for arbitrary lengths; `hamming ⊕ hamming`
  shown self-dual + doubly-even of length 16 with 256 codewords, with `8 ∣ 16` recovered
  via Gleason rather than by `native_decide` over `2^16` vectors.
Insight: concatenation makes weight additive and the inner product block-diagonal, so
  self-orthogonality is transparent; the only content of the *backward* self-duality
  direction is that a self-dual code contains `0`, letting one probe each block
  independently via `append a 0` and `append 0 b`. This is the exact mirror of the
  block-diagonal `Tᵀ G T` argument in `directSum_stdDiagonalizable`.
Failure analysis: the `Fin (m+n)` index split is handled entirely by
  `Fin.sum_univ_add`, `Fin.append_left/right`, and `Fin.append_castAdd_natAdd`, with no
  explicit index arithmetic — the code analogue of routing the lattice proof through
  `finSumFinEquiv` / `submatrix_mul_equiv`.
-/

import Mathlib
import Applications.SmoothPoincare.GleasonLength

open scoped BigOperators

namespace SmoothPoincare
namespace Codes

variable {m n : ℕ}

/-! ## The left/right coordinate projections and the concatenation code -/

/-- The "left block" of a length-`(m+n)` vector: its first `m` coordinates. -/
def leftPart (z : Fin (m + n) → ZMod 2) : Fin m → ZMod 2 := fun i => z (Fin.castAdd n i)

/-- The "right block" of a length-`(m+n)` vector: its last `n` coordinates. -/
def rightPart (z : Fin (m + n) → ZMod 2) : Fin n → ZMod 2 := fun i => z (Fin.natAdd m i)

@[simp] theorem leftPart_append (a : Fin m → ZMod 2) (b : Fin n → ZMod 2) :
    leftPart (Fin.append a b) = a := by
  funext i; simp [leftPart, Fin.append_left]

@[simp] theorem rightPart_append (a : Fin m → ZMod 2) (b : Fin n → ZMod 2) :
    rightPart (Fin.append a b) = b := by
  funext i; simp [rightPart, Fin.append_right]

theorem append_leftPart_rightPart (z : Fin (m + n) → ZMod 2) :
    Fin.append (leftPart z) (rightPart z) = z :=
  Fin.append_castAdd_natAdd

/-- **Direct sum (concatenation) of binary codes.**  `C ⊕ D ⊆ (ZMod 2)^{m+n}` is the
set of all concatenations `Fin.append a b` of a codeword `a ∈ C` and `b ∈ D`.  This is
the code-side analogue of `IntersectionForm.directSum` (block-diagonal Gram matrix). -/
def appendCode (C : Finset (Fin m → ZMod 2)) (D : Finset (Fin n → ZMod 2)) :
    Finset (Fin (m + n) → ZMod 2) :=
  (C ×ˢ D).image (fun p => Fin.append p.1 p.2)

@[inherit_doc] infixl:65 " ⊕c " => appendCode

/-! ## Membership, weight, inner product, and cardinality -/

/-- **Membership criterion** for the concatenation code: a vector lies in `C ⊕ D` iff
its left block lies in `C` and its right block lies in `D`. -/
theorem mem_appendCode {C : Finset (Fin m → ZMod 2)} {D : Finset (Fin n → ZMod 2)}
    {z : Fin (m + n) → ZMod 2} :
    z ∈ C ⊕c D ↔ leftPart z ∈ C ∧ rightPart z ∈ D := by
  constructor <;> intro h;
  · obtain ⟨ p, hp, rfl ⟩ := Finset.mem_image.mp h;
    aesop;
  · exact Finset.mem_image.mpr ⟨ ( leftPart z, rightPart z ), Finset.mem_product.mpr h, append_leftPart_rightPart z ⟩

/-- **Existential membership criterion.** A vector lies in `C ⊕ D` iff it is the
concatenation `Fin.append a b` of a codeword `a ∈ C` and a codeword `b ∈ D`. This is
the form `x ∈ C ⊕ D ↔ ∃ a∈C, ∃ b∈D, x = Fin.append a b` directly mirroring the
lattice-side block decomposition. -/
theorem mem_appendCode_iff_exists {C : Finset (Fin m → ZMod 2)}
    {D : Finset (Fin n → ZMod 2)} {z : Fin (m + n) → ZMod 2} :
    z ∈ C ⊕c D ↔ ∃ a ∈ C, ∃ b ∈ D, z = Fin.append a b := by
  rw [mem_appendCode]
  constructor
  · intro h
    exact ⟨leftPart z, h.1, rightPart z, h.2, (append_leftPart_rightPart z).symm⟩
  · rintro ⟨a, ha, b, hb, rfl⟩
    simp [ha, hb]

/-- **Weight is additive under concatenation.** -/
theorem wt_append (a : Fin m → ZMod 2) (b : Fin n → ZMod 2) :
    wt (Fin.append a b) = wt a + wt b := by
  unfold wt;
  rw [ Finset.card_filter, Finset.card_filter, Finset.card_filter ];
  rw [ Fin.sum_univ_add ] ; aesop

/-- **The inner product is block-diagonal under concatenation.** -/
theorem ip_append (a c : Fin m → ZMod 2) (b d : Fin n → ZMod 2) :
    ip (Fin.append a b) (Fin.append c d) = ip a c + ip b d := by
  unfold ip;
  rw [ Fin.sum_univ_add ] ; aesop

/-- The concatenation map is injective on the product `C ×ˢ D`, hence
**`|C ⊕ D| = |C|·|D|`** — the code shadow of `det` multiplicativity. -/
theorem appendCode_card (C : Finset (Fin m → ZMod 2)) (D : Finset (Fin n → ZMod 2)) :
    (C ⊕c D).card = C.card * D.card := by
  rw [ Codes.appendCode, Finset.card_image_of_injective ];
  · exact Finset.card_product _ _;
  · intro p q h; have := congr_fun h; simp_all +decide [ Fin.append ] ;
    exact Prod.ext ( funext fun i => by simpa using congr_fun h ( Fin.castAdd n i ) ) ( funext fun i => by simpa using congr_fun h ( Fin.natAdd m i ) )

/-! ## Closure of the structural predicates -/

/-- **Double-evenness is additive under concatenation** (shadow of `directSum_isEven`). -/
theorem doublyEven_append {a : Fin m → ZMod 2} {b : Fin n → ZMod 2}
    (ha : DoublyEven a) (hb : DoublyEven b) : DoublyEven (Fin.append a b) := by
  exact dvd_trans ( by decide ) ( Nat.dvd_add ha hb ) |> fun h => h.trans ( by rw [ wt_append ] ) ;

/-- **Double-evenness is closed under `⊕`.** -/
theorem appendCode_doublyEven {C : Finset (Fin m → ZMod 2)} {D : Finset (Fin n → ZMod 2)}
    (hC : ∀ v ∈ C, DoublyEven v) (hD : ∀ v ∈ D, DoublyEven v) :
    ∀ v ∈ C ⊕c D, DoublyEven v := by
  intro v hv; rw [ mem_appendCode ] at hv; obtain ⟨ hv₁, hv₂ ⟩ := hv; exact append_leftPart_rightPart v ▸ doublyEven_append ( hC _ hv₁ ) ( hD _ hv₂ ) ;

/-- **Self-orthogonality is closed under `⊕`.** If every pair of codewords of `C` is
orthogonal and likewise for `D`, then every pair of codewords of the concatenation
`C ⊕ D` is orthogonal.  This is the code-side analogue of the block-diagonal Gram
matrix having zero off-diagonal blocks: the inner product `ip_append` splits as the
sum of the two block inner products, each vanishing by hypothesis. -/
theorem appendCode_selfOrthogonal {C : Finset (Fin m → ZMod 2)}
    {D : Finset (Fin n → ZMod 2)}
    (hC : ∀ x ∈ C, ∀ y ∈ C, ip x y = 0)
    (hD : ∀ x ∈ D, ∀ y ∈ D, ip x y = 0) :
    ∀ x ∈ C ⊕c D, ∀ y ∈ C ⊕c D, ip x y = 0 := by
  intro x hx y hy
  obtain ⟨a, ha, b, hb, rfl⟩ := mem_appendCode_iff_exists.1 hx
  obtain ⟨c, hc, d, hd, rfl⟩ := mem_appendCode_iff_exists.1 hy
  rw [ip_append, hC a ha c hc, hD b hb d hd, add_zero]

/-- **Self-duality is closed under `⊕`** — the headline closure theorem, the code-side
analogue of `directSum_unimodular` (Poincaré self-duality preserved by connected sum). -/
theorem appendCode_selfDual {C : Finset (Fin m → ZMod 2)} {D : Finset (Fin n → ZMod 2)}
    (hC : ∀ x, x ∈ C ↔ ∀ y ∈ C, ip x y = 0)
    (hD : ∀ x, x ∈ D ↔ ∀ y ∈ D, ip x y = 0) :
    ∀ x, x ∈ C ⊕c D ↔ ∀ y ∈ C ⊕c D, ip x y = 0 := by
  intro x
  rw [mem_appendCode];
  constructor;
  · intro hx y hy
    obtain ⟨a, b, ha, hb, rfl⟩ : ∃ a b, a ∈ C ∧ b ∈ D ∧ y = Fin.append a b := by
      unfold appendCode at hy; obtain ⟨ p, hp, rfl ⟩ := Finset.mem_image.mp hy; exact ⟨ p.1, p.2, Finset.mem_product.mp hp |>.1, Finset.mem_product.mp hp |>.2, rfl ⟩ ;
    rw [ ← append_leftPart_rightPart x, ip_append ];
    rw [ hC _ |>.1 hx.1 _ ha, hD _ |>.1 hx.2 _ hb, add_zero ];
  · intro hx
    apply And.intro;
    · rw [ hC ];
      intro y hy; specialize hx ( Fin.append y 0 ) ; simp +decide [ appendCode ] at hx;
      convert hx y 0 hy ( hD 0 |>.2 fun _ _ => by simp +decide [ ip ] ) ( by simp +decide [ Fin.append ] ) using 1;
      unfold ip; simp +decide [ Fin.sum_univ_add, leftPart ] ;
    · rw [ hD ];
      intro y hy
      specialize hx (Fin.append 0 y) (by
      exact Finset.mem_image.mpr ⟨ ( 0, y ), Finset.mem_product.mpr ⟨ show 0 ∈ C from by rw [ hC ] ; intros; simp +decide [ ip ], hy ⟩, rfl ⟩);
      convert hx using 1;
      unfold ip rightPart; simp +decide [ Fin.sum_univ_add ] ;

/-- **Gleason length divisibility is additive.** The direct sum of two doubly-even
self-dual codes is again doubly-even self-dual, so by Gleason its length `m + n` is
divisible by `8`. -/
theorem appendCode_length_div_eight {C : Finset (Fin m → ZMod 2)}
    {D : Finset (Fin n → ZMod 2)}
    (hCDE : ∀ v ∈ C, DoublyEven v) (hCSD : ∀ x, x ∈ C ↔ ∀ y ∈ C, ip x y = 0)
    (hDDE : ∀ v ∈ D, DoublyEven v) (hDSD : ∀ x, x ∈ D ↔ ∀ y ∈ D, ip x y = 0) :
    8 ∣ (m + n) :=
  doublyEven_selfDual_length_div_eight (C ⊕c D)
    (appendCode_doublyEven hCDE hDDE) (appendCode_selfDual hCSD hDSD)

/-! ## The headline: `hamming ⊕ hamming`, the mod-2 shadow of `E8 ⊕ E8` -/

/-- The length-`16` direct sum of two extended Hamming `[8,4,4]` codes: the precise
mod-2 shadow of the rank-`16` lattice `E8 ⊕ E8` (`DirectSum.E8E8form`). -/
def hamming16 : Finset (Fin (8 + 8) → ZMod 2) := hamming ⊕c hamming

/-- `hamming ⊕ hamming` is doubly even. -/
theorem hamming16_doublyEven : ∀ v ∈ hamming16, DoublyEven v :=
  appendCode_doublyEven hamming_doublyEven hamming_doublyEven

/-- `hamming ⊕ hamming` is self-dual. -/
theorem hamming16_selfDual :
    ∀ x, x ∈ hamming16 ↔ ∀ y ∈ hamming16, ip x y = 0 :=
  appendCode_selfDual hamming_selfDual hamming_selfDual

/-- `hamming ⊕ hamming` has `256 = 16·16` codewords, *derived* from `appendCode_card`
(`|C ⊕ D| = |C|·|D|`) rather than by a brute-force count over `2^16` vectors. -/
theorem hamming16_card : hamming16.card = 256 := by
  rw [hamming16, appendCode_card]
  native_decide

/-- **Stable length divisibility.** `hamming ⊕ hamming` has length `16`, divisible by
`8` — the code-side echo of `E8 ⊕ E8` having rank `16` divisible by `8`, recovered from
the general Gleason theorem rather than by `native_decide` over `2^16` vectors. -/
theorem hamming16_length_div_eight : (8 : ℕ) ∣ (8 + 8) :=
  appendCode_length_div_eight hamming_doublyEven hamming_selfDual
    hamming_doublyEven hamming_selfDual

end Codes
end SmoothPoincare