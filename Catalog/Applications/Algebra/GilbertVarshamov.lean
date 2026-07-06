/-
Copyright (c) 2025. All rights reserved.

# The Gilbert–Varshamov Lower Bound and the Code-Size Sandwich

## Overview

The catalog file `Catalog/Tropical/SpherePackingBound.lean` proves the *upper*
half of the fundamental two-sided estimate on the size of an error-correcting
code: the **sphere-packing / Hamming bound** `|C| · V(t) ≤ qⁿ`, together with the
exact ball-volume formula `V(t) = ∑_{i≤t} C(n,i)(q-1)ⁱ`.

This file closes the **lower** half — the **Gilbert–Varshamov bound**
`qⁿ ≤ |C| · V(d-1)` for any code `C` that is *maximal* with respect to minimum
distance `d` — and combines the two halves into the **code-size sandwich**

      |C| · V(t)  ≤  qⁿ  ≤  |C| · V(2t)        (for a maximal `(2t+1)`-code).

The conceptual engine is the dual pair of geometric facts:

* sphere-packing uses ball **disjointness** (large minimum distance ⇒ disjoint
  balls), giving the upper bound;
* Gilbert–Varshamov uses ball **covering** (maximality ⇒ the radius-`(d-1)` balls
  cover the whole space), giving the lower bound.

We work, exactly as in `SpherePackingBound`, over a finite additive-group alphabet
`G` indexed by a finite type `ι`, reusing the translation-invariance of the
Hamming metric (so all balls of a fixed radius have the same cardinality).

## Main Results

* `maximal_covers` — a maximal `d`-code's radius-`(d-1)` balls cover every word.
* `gilbert_varshamov` — `qⁿ ≤ |C| · V(d-1)` for any maximal `d`-code.
* `code_size_sandwich` — the two-sided bound `|C|·V(t) ≤ qⁿ ≤ |C|·V(2t)`.
* `gilbert_varshamov_formula` — closed form `qⁿ ≤ |C| · ∑_{i≤d-1} C(n,i)(q-1)ⁱ`.

## Catalog Synthesis

Directly dual to `SpherePackingBound.sphere_packing_bound`
(and reusing `SpherePackingBound`-style proofs of `hammingBall_card_translation`
and `hammingWeight_count`, restated here so this file is self-contained). Together
the two files realise the classical sandwich that pins the optimal code size
between the GV and Hamming bounds.

-- !-- Lab Notebook -- !--
Hypothesis: maximality of a `d`-separated code forces a *covering* of the whole
  Hamming space by radius-`(d-1)` balls, dually to how a large minimum distance
  forces a *packing* by radius-`t` balls.
Result: proved `gilbert_varshamov` (`qⁿ ≤ |C|·V(d-1)`), its closed form, and the
  two-sided `code_size_sandwich`, reusing the catalog's translation invariance.
Insight: the entire lower bound is one `Finset.card_le_card` on a covering
  `biUnion`, mirroring the upper bound's `Finset.card_biUnion` on a packing — the
  GV/Hamming duality is literally `covering` vs `disjoint`.
Failure analysis: stating GV for *arbitrary* codes is false (a tiny code covers
  nothing); the hypothesis must be maximality, which is exactly what converts
  "no further word can be added" into "every word is already within `d-1`".
-/
import Mathlib

open Finset BigOperators

noncomputable section

namespace GilbertVarshamov

variable {ι : Type*} [Fintype ι] [DecidableEq ι]
variable {G : Type*} [Fintype G] [DecidableEq G] [AddCommGroup G]

/-! ## Hamming balls and translation invariance (from `SpherePackingBound`) -/

/-- The (closed) Hamming ball of radius `t` centred at `x`. -/
def hammingBall (x : ι → G) (t : ℕ) : Finset (ι → G) :=
  Finset.univ.filter (fun y => hammingDist x y ≤ t)

omit [AddCommGroup G] in
@[simp] theorem mem_hammingBall {x y : ι → G} {t : ℕ} :
    y ∈ hammingBall x t ↔ hammingDist x y ≤ t := by
  simp [hammingBall]

-- Hamming distance is invariant under translation.
omit [DecidableEq ι] [Fintype G] in
theorem hammingDist_add_right (x y c : ι → G) :
    hammingDist (x + c) (y + c) = hammingDist x y := by
  unfold hammingDist
  simp +decide

/-- All Hamming balls of a fixed radius have the same cardinality. -/
theorem hammingBall_card_translation (x : ι → G) (t : ℕ) :
    (hammingBall x t).card = (hammingBall (0 : ι → G) t).card := by
  have h_bij : Finset.image (fun y => y - x) (hammingBall x t) = hammingBall 0 t := by
    ext y
    simp [hammingBall]
    constructor <;> intro h
    · obtain ⟨ a, ha, rfl ⟩ := h; simp_all +decide [ hammingDist, hammingNorm ]
      simpa only [ sub_eq_zero, eq_comm ] using ha
    · refine' ⟨ y + x, _, _ ⟩ <;> simp_all +decide [ hammingDist, hammingNorm ]
  rw [ ← h_bij, Finset.card_image_of_injective _ ( sub_left_injective ) ]

/-! ## Exact sphere count and ball volume (from `SpherePackingBound`) -/

/-- The number of words at Hamming distance exactly `k` from the origin is
    `C(n, k) · (q-1)^k`. -/
theorem hammingWeight_count (k : ℕ) :
    (Finset.univ.filter (fun y : ι → G => hammingDist 0 y = k)).card =
      (Fintype.card ι).choose k * (Fintype.card G - 1) ^ k := by
  set S := Finset.univ.filter (fun y : ι → G => hammingDist 0 y = k) with hS_def
  have h_subset_count : ∀ T : Finset ι, T.card = k → (Finset.univ.filter (fun y : ι → G => Finset.univ.filter (fun i => y i ≠ 0) = T)).card = (Fintype.card G - 1) ^ k := by
    intro T hT_card
    have h_subset_count : (Finset.univ.filter (fun y : ι → G => Finset.univ.filter (fun i => y i ≠ 0) = T)).card = (Finset.univ.filter (fun y : T → G => ∀ i : T, y i ≠ 0)).card := by
      refine' Finset.card_bij ( fun y hy => fun i => y i ) _ _ _ <;> simp_all +decide [ Finset.ext_iff ]
      · intro a₁ ha₁ a₂ ha₂ h; ext i; by_cases hi : i ∈ T <;> simp_all +decide [ funext_iff ]
        grind +ring
      · intro b hb; use fun i => if hi : i ∈ T then b ⟨ i, hi ⟩ else 0; aesop
    rw [ h_subset_count, ← hT_card ]
    rw [ show ( Finset.univ.filter fun y : T → G => ∀ i : T, y i ≠ 0 ) = Finset.image ( fun y : T → { x : G // x ≠ 0 } => fun i => ( y i : G ) ) ( Finset.univ : Finset ( T → { x : G // x ≠ 0 } ) ) from ?_, Finset.card_image_of_injective ]
    · simp +decide [ Finset.card_univ ]
    · exact fun x y hxy => funext fun i => Subtype.ext <| congr_fun hxy i
    · ext; simp [Finset.mem_image]
      exact ⟨ fun h => ⟨ fun i => ⟨ _, h i i.2 ⟩, rfl ⟩, by rintro ⟨ a, rfl ⟩ i hi; exact a ⟨ i, hi ⟩ |>.2 ⟩
  have h_sum : S = Finset.biUnion (Finset.powersetCard k (Finset.univ : Finset ι)) (fun T => Finset.univ.filter (fun y : ι → G => Finset.univ.filter (fun i => y i ≠ 0) = T)) := by
    ext y; simp [S]
    simp +decide [ hammingNorm ]
  rw [ h_sum, Finset.card_biUnion ]
  · rw [ Finset.sum_congr rfl fun T hT => h_subset_count T <| Finset.mem_powersetCard.mp hT |>.2 ] ; simp +decide [ Finset.card_univ ]
  · exact fun x hx y hy hxy => Finset.disjoint_left.mpr fun z hz hz' => hxy <| by aesop

/-- Volume of a Hamming ball: `V(t) = ∑_{i≤t} C(n,i)(q-1)ⁱ`. -/
theorem hammingBall_card_formula (t : ℕ) :
    (hammingBall (0 : ι → G) t).card =
      ∑ i ∈ Finset.range (t + 1),
        (Fintype.card ι).choose i * (Fintype.card G - 1) ^ i := by
  rw [ hammingBall ]
  rw [ show ( Finset.filter ( fun y => hammingDist 0 y ≤ t ) Finset.univ : Finset ( ι → G ) ) = Finset.biUnion ( Finset.range ( t + 1 ) ) fun i => Finset.filter ( fun y => hammingDist 0 y = i ) Finset.univ from ?_, Finset.card_biUnion ]
  · exact Finset.sum_congr rfl fun i hi => hammingWeight_count i
  · exact fun i hi j hj hij => Finset.disjoint_left.mpr fun x hx hx' => hij <| by aesop
  · ext y; simp [Finset.mem_biUnion]

/-! ## Packing disjointness and the sphere-packing bound (from `SpherePackingBound`) -/

-- Packing disjointness: radius-`t` balls about a min-distance-`(2t+1)` code are
-- pairwise disjoint.
omit [AddCommGroup G] in
theorem hammingBall_pairwise_disjoint
    (C : Finset (ι → G)) (t : ℕ)
    (hC : ∀ x ∈ C, ∀ y ∈ C, x ≠ y → 2 * t + 1 ≤ hammingDist x y) :
    (C : Set (ι → G)).PairwiseDisjoint (fun c => hammingBall c t) := by
  intro c hc c' hc' hcc'
  simp only [Function.onFun, Finset.disjoint_left, mem_hammingBall]
  intro y hcy hc'y
  have hmin := hC c hc c' hc' hcc'
  have htri := hammingDist_triangle c y c'
  rw [hammingDist_comm y c'] at htri
  omega

/-- Sphere-packing / Hamming bound: `|C| · V(t) ≤ qⁿ`. -/
theorem sphere_packing_bound
    (C : Finset (ι → G)) (t : ℕ)
    (hC : ∀ x ∈ C, ∀ y ∈ C, x ≠ y → 2 * t + 1 ≤ hammingDist x y) :
    C.card * (hammingBall (0 : ι → G) t).card ≤ Fintype.card (ι → G) := by
  set S := Finset.biUnion C (fun c => hammingBall c t) with hS_def
  have h_card_union : Finset.card S = Finset.sum C (fun c => Finset.card (hammingBall c t)) := by
    rw [ Finset.card_biUnion ] ; exact hammingBall_pairwise_disjoint C t hC
  have h_card_le : Finset.card S ≤ Fintype.card (ι → G) := by
    exact Finset.card_le_univ _
  rw [ h_card_union, Finset.sum_congr rfl fun x hx => hammingBall_card_translation x t ] at h_card_le ; aesop

/-! ## Separated and maximal codes -/

/-- A code is `d`-**separated** if any two distinct codewords are at Hamming
    distance at least `d` (its minimum distance is `≥ d`). -/
def Separated (C : Finset (ι → G)) (d : ℕ) : Prop :=
  ∀ x ∈ C, ∀ y ∈ C, x ≠ y → d ≤ hammingDist x y

/-- A code is **maximal** for minimum distance `d` if it is `d`-separated and no
    further word can be adjoined without destroying `d`-separation. -/
def IsMaximal (C : Finset (ι → G)) (d : ℕ) : Prop :=
  Separated C d ∧ ∀ w, w ∉ C → ¬ Separated (insert w C) d

/-! ## The Gilbert–Varshamov lower bound -/

/-
!-- If a word `w` were at distance `≥ d` from every codeword, then `C ∪ {w}`
would still be `d`-separated, contradicting maximality; hence some codeword lies
within distance `d-1` of `w`. -- !--

**Maximal codes cover the space.** Every word lies within Hamming distance
`d-1` of some codeword of a maximal `d`-code.
-/
omit [DecidableEq ι] [Fintype G] [AddCommGroup G] in
theorem maximal_covers {C : Finset (ι → G)} {d : ℕ} (hd : 1 ≤ d)
    (hmax : IsMaximal C d) (w : ι → G) :
    ∃ c ∈ C, hammingDist c w ≤ d - 1 := by
  by_cases hw : w ∈ C;
  · exact ⟨ w, hw, Nat.le_sub_one_of_lt ( by simp +decide [ hammingDist_self ] ; linarith ) ⟩;
  · obtain ⟨c, hc⟩ : ∃ c ∈ insert w C, ∃ c' ∈ insert w C, c ≠ c' ∧ hammingDist c c' < d := by
      contrapose! hmax;
      exact fun h => h.2 w hw hmax;
    rcases hc with ⟨ hc₁, c', hc₂, hne, hlt ⟩ ; cases' Finset.mem_insert.mp hc₁ with hc₁ hc₁ <;> cases' Finset.mem_insert.mp hc₂ with hc₂ hc₂ <;> simp_all +decide ;
    · exact ⟨ c', hc₂, Nat.le_sub_one_of_lt ( by rwa [ hammingDist_comm ] ) ⟩;
    · exact ⟨ c, hc₁, Nat.le_sub_one_of_lt hlt ⟩;
    · exact absurd ( hmax.1 c hc₁ c' hc₂ hne ) ( by omega )

/-
!-- The radius-`(d-1)` balls about the codewords cover the whole space
(`maximal_covers`), so `qⁿ = |univ| ≤ ∑_c V(d-1) = |C|·V(d-1)` by
`Finset.card_le_card` and `Finset.card_biUnion_le`, using ball uniformity. -- !--

**Gilbert–Varshamov bound.** A maximal `d`-code satisfies `qⁿ ≤ |C| · V(d-1)`.
-/
theorem gilbert_varshamov {C : Finset (ι → G)} {d : ℕ} (hd : 1 ≤ d)
    (hmax : IsMaximal C d) :
    Fintype.card (ι → G) ≤ C.card * (hammingBall (0 : ι → G) (d - 1)).card := by
  have h_cover : (Finset.univ : Finset (ι → G)) ⊆ Finset.biUnion C (fun c => hammingBall c (d - 1)) := by
    intro w hw; obtain ⟨ c, hc, hcd ⟩ := maximal_covers hd hmax w; exact Finset.mem_biUnion.mpr ⟨ c, hc, mem_hammingBall.mpr hcd ⟩ ;
  convert Finset.card_mono h_cover |> le_trans <| Finset.card_biUnion_le;
  rw [ Finset.sum_congr rfl fun x hx => hammingBall_card_translation x _ ] ; simp +decide ;

/-
!-- Substitute `hammingBall_card_formula` into `gilbert_varshamov`. -- !--

**Closed-form Gilbert–Varshamov bound.**
-/
theorem gilbert_varshamov_formula {C : Finset (ι → G)} {d : ℕ} (hd : 1 ≤ d)
    (hmax : IsMaximal C d) :
    (Fintype.card G) ^ (Fintype.card ι) ≤
      C.card * (∑ i ∈ Finset.range (d - 1 + 1),
        (Fintype.card ι).choose i * (Fintype.card G - 1) ^ i) := by
  convert gilbert_varshamov hd hmax using 1;
  · rw [ Fintype.card_fun ];
  · rw [ hammingBall_card_formula ]

/-! ## The code-size sandwich -/

/-
!-- Upper half is `sphere_packing_bound` applied to `hmax.1`; lower half is
`gilbert_varshamov` with `d = 2t+1`, where `d - 1 = 2t`. -- !--

**Code-size sandwich.** A maximal `(2t+1)`-code is pinned between the
Hamming and Gilbert–Varshamov bounds:
`|C| · V(t) ≤ qⁿ ≤ |C| · V(2t)`.
-/
theorem code_size_sandwich {C : Finset (ι → G)} {t : ℕ}
    (hmax : IsMaximal C (2 * t + 1)) :
    C.card * (hammingBall (0 : ι → G) t).card ≤ Fintype.card (ι → G) ∧
    Fintype.card (ι → G) ≤ C.card * (hammingBall (0 : ι → G) (2 * t)).card := by
  refine' ⟨ _, _ ⟩;
  · convert sphere_packing_bound C t hmax.1 using 1;
  · convert gilbert_varshamov ( show 1 ≤ 2 * t + 1 by omega ) hmax using 1

end GilbertVarshamov
end