/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Geometry.AffineParitySingleton

/-!
# Affine subspace statistics in `𝔽₂ⁿ`: the extremal sets in top dimension

`Catalog/Geometry/AffineParitySingleton.lean` shows that for affine `n`-cubes in `𝔽₂ⁿ` the
refined parity bound is attained:
`max_{A} P[|F ∩ A| odd] = (1/2) ∏_{i<n-1}(1 - 2^{i-n})`, a single point being extremal.

This file determines **all** the extremal sets: they are exactly the subsets of **odd
cardinality**.  The mechanism is that an independent `(n-1)`-tuple `w` spans a hyperplane,
so extending it by any `u` outside that hyperplane produces a full basis, and a full affine
basis cube is a bijective parametrisation of `𝔽₂ⁿ`; hence
`|cube(c,w) ∩ A| + |cube(c+u,w) ∩ A| = |A|`.
If `|A|` is odd this pairs up the base points perfectly (balancedness), and if `|A|` is even
the parity of `|cube(c,w) ∩ A|` is a constant function of `c`, which is as unbalanced as
possible.

## Main results

* `AffineParityTopDim.cnt_eq_card_of_indep` : a full-dimensional independent cube meets `A`
  in exactly `|A|` points.
* `AffineParityTopDim.balanced_iff_odd_card` : all derivative counts are balanced iff `|A|`
  is odd.
* `AffineParityTopDim.oddProb_eq_max_iff` : `A` is extremal for affine `n`-cubes iff `|A|`
  is odd.
* `AffineParityTopDim.card_extremal` : consequently there are exactly `2^{2ⁿ-1}` extremal
  sets (`8` for `n = 2`, `128` for `n = 3`).
-/

namespace AffineParityTopDim

open Finset AffineStats AffineParityGap

variable {n d : ℕ}

section Span

/-- The linear span of the direction tuple `w`, as a `Finset`. -/
def spanF (w : Fin d → Vec n) : Finset (Vec n) :=
  Finset.image (fun y : Fin d → ZMod 2 => ∑ i, y i • w i) univ

lemma mem_spanF_iff (w : Fin d → Vec n) (x : Vec n) :
    x ∈ spanF w ↔ ∃ y : Fin d → ZMod 2, ∑ i, y i • w i = x := by
  simp [spanF]

lemma add_mem_spanF {w : Fin d → Vec n} {x z : Vec n} (hx : x ∈ spanF w) (hz : z ∈ spanF w) :
    x + z ∈ spanF w := by
  obtain ⟨y, rfl⟩ := (mem_spanF_iff w x).1 hx
  obtain ⟨t, rfl⟩ := (mem_spanF_iff w z).1 hz
  refine (mem_spanF_iff w _).2 ⟨y + t, ?_⟩
  rw [← Finset.sum_add_distrib]
  exact Finset.sum_congr rfl fun i _ => by simp [add_smul]

/-- An independent tuple spans a set of size `2^d`. -/
lemma card_spanF {w : Fin d → Vec n} (hw : Indep w) : (spanF w).card = 2 ^ d := by
  classical
  rw [spanF, Finset.card_image_of_injective _ ?inj]
  · simp
  case inj =>
    intro y z hyz
    refine pt_injective (0 : Vec n) hw ?_
    simpa [pt] using hyz

/-- Extending an independent tuple by a vector outside its span keeps it independent. -/
lemma indep_cons {w : Fin d → Vec n} (hw : Indep w) {u : Vec n} (hu : u ∉ spanF w) :
    Indep (Fin.cons u w : Fin (d + 1) → Vec n) := by
  intro y hy hsum
  rw [Fin.sum_univ_succ] at hsum
  simp only [Fin.cons_zero, Fin.cons_succ] at hsum
  by_cases h0 : y 0 = 0
  · rw [h0, zero_smul, zero_add] at hsum
    refine hw (fun i => y i.succ) ?_ hsum
    intro hcon
    refine hy (funext fun i => ?_)
    refine Fin.cases ?_ (fun j => ?_) i
    · exact h0
    · exact congrFun hcon j
  · have h1 : y 0 = 1 := by
      revert h0; generalize y 0 = t; revert t; decide
    rw [h1, one_smul] at hsum
    refine hu ((mem_spanF_iff w u).2 ⟨fun i => y i.succ, ?_⟩)
    have h2 := congrArg (fun z : Vec n => u + z) hsum
    simpa [← add_assoc, vadd_self] using h2

/-- If `d < n` there is a vector outside the span. -/
lemma exists_not_mem_spanF {w : Fin d → Vec n} (hw : Indep w) (hd : d < n) :
    ∃ u : Vec n, u ∉ spanF w := by
  classical
  by_contra hcon
  push_neg at hcon
  have huniv : spanF w = univ := Finset.eq_univ_iff_forall.2 hcon
  have h1 : (2 : ℕ) ^ d = 2 ^ n := by
    rw [← card_spanF hw, huniv, Finset.card_univ, card_Vec]
  have := Nat.pow_right_injective (le_refl 2) h1
  omega

end Span

section FullDimension

/-- A full-dimensional independent affine cube parametrises `𝔽₂ⁿ` bijectively, hence meets
`A` in exactly `|A|` points. -/
theorem cnt_eq_card_of_indep (A : Finset (Vec n)) (c : Vec n) {v : Fin n → Vec n}
    (hv : Indep v) : cnt A c v = A.card := by
  classical
  have hinj : Function.Injective (pt c v) := pt_injective c hv
  have hsurj : Function.Surjective (pt c v) := Finite.injective_iff_surjective.1 hinj
  rw [cnt]
  refine Finset.card_bij (fun y _ => pt c v y) (fun y hy => ?_) (fun y _ z _ h => hinj h)
    (fun a ha => ?_)
  · simpa using (mem_filter.1 hy).2
  · obtain ⟨y, rfl⟩ := hsurj a
    exact ⟨y, by simpa using ha, rfl⟩

/-- Splitting a full-dimensional cube into two parallel hyperplane cubes. -/
lemma cnt_add_cnt (A : Finset (Vec (d + 1))) (c : Vec (d + 1)) {w : Fin d → Vec (d + 1)}
    (hw : Indep w) {u : Vec (d + 1)} (hu : u ∉ spanF w) :
    cnt A c w + cnt A (c + u) w = A.card := by
  have hv := indep_cons hw hu
  have h := cnt_succ A c (Fin.cons u w)
  simp only [Fin.cons_zero, Fin.cons_succ] at h
  rw [← h]
  exact cnt_eq_card_of_indep A c hv

end FullDimension

section Characterisation

variable {A : Finset (Vec (d + 1))}

/-- If `|A|` is odd, every independent direction tuple is balanced. -/
theorem balanced_of_odd_card (hA : Odd A.card) (w : Fin d → Vec (d + 1)) (hw : Indep w) :
    2 * (oddBase A w).card = 2 ^ (d + 1) := by
  classical
  obtain ⟨u, hu⟩ := exists_not_mem_spanF hw (Nat.lt_succ_self d)
  have hinv : Function.Involutive (fun c : Vec (d + 1) => c + u) := by
    intro c; funext i; simp [add_assoc, CharTwo.add_self_eq_zero]
  have hflip : ∀ c : Vec (d + 1), (¬ (2 ∣ cnt A (c + u) w)) ↔ ¬ (¬ (2 ∣ cnt A c w)) := by
    intro c
    have hsum := cnt_add_cnt A c hw hu
    rw [Nat.odd_iff] at hA
    omega
  have h := card_filter_involutive (fun c : Vec (d + 1) => ¬ (2 ∣ cnt A c w))
    (fun c => c + u) hinv hflip
  rw [card_Vec] at h
  exact h

/-- If `|A|` is even, the parity of the intersection count does not depend on the base
point. -/
lemma parity_const_of_even_card (hA : ¬ Odd A.card) {w : Fin d → Vec (d + 1)} (hw : Indep w)
    (c t : Vec (d + 1)) : (2 ∣ cnt A c w) ↔ (2 ∣ cnt A (c + t) w) := by
  classical
  have hstep : ∀ (c s : Vec (d + 1)), s ∉ spanF w →
      ((2 ∣ cnt A c w) ↔ (2 ∣ cnt A (c + s) w)) := by
    intro c s hs
    have hsum := cnt_add_cnt A c hw hs
    rw [Nat.not_odd_iff_even, Nat.even_iff] at hA
    omega
  by_cases ht : t ∈ spanF w
  · obtain ⟨s, hs⟩ := exists_not_mem_spanF hw (Nat.lt_succ_self d)
    have hts : t + s ∉ spanF w := by
      intro hcon
      refine hs ?_
      have : t + (t + s) ∈ spanF w := add_mem_spanF ht hcon
      rwa [← add_assoc, vadd_self, zero_add] at this
    have h1 := hstep c s hs
    have h2 := hstep (c + s) (t + s) hts
    have hrw : c + s + (t + s) = c + t := by
      have : c + s + (t + s) = c + t + (s + s) := by abel
      rw [this, vadd_self, add_zero]
    rw [hrw] at h2
    exact h1.trans h2
  · exact hstep c t ht

/-- If `|A|` is even, no independent direction tuple is balanced. -/
theorem not_balanced_of_even_card (hA : ¬ Odd A.card) {w : Fin d → Vec (d + 1)}
    (hw : Indep w) : 2 * (oddBase A w).card ≠ 2 ^ (d + 1) := by
  classical
  have hconst : oddBase A w = ∅ ∨ oddBase A w = univ := by
    by_cases hne : (oddBase A w).Nonempty
    · refine Or.inr (Finset.eq_univ_iff_forall.2 fun c => ?_)
      obtain ⟨c₀, hc₀⟩ := hne
      simp only [oddBase, mem_filter, mem_univ, true_and] at hc₀ ⊢
      have h := parity_const_of_even_card hA hw c₀ (c₀ + c)
      have hrw : c₀ + (c₀ + c) = c := by
        rw [← add_assoc, vadd_self, zero_add]
      rw [hrw] at h
      exact fun hcon => hc₀ (h.2 hcon)
    · exact Or.inl (Finset.not_nonempty_iff_eq_empty.1 hne)
  rcases hconst with h | h
  · rw [h]
    simp only [Finset.card_empty, Nat.mul_zero]
    have hp : 0 < (2 : ℕ) ^ (d + 1) := pow_pos (by norm_num) _
    omega
  · rw [h, Finset.card_univ, card_Vec]
    intro hcon
    have h2 : (2 : ℕ) ^ (d + 2) = 2 ^ (d + 1) := by
      rw [show d + 2 = (d + 1) + 1 from rfl, pow_succ, mul_comm]
      exact hcon
    have := Nat.pow_right_injective (le_refl 2) h2
    omega

/-- **All derivative counts are balanced iff `|A|` is odd.** -/
theorem balanced_iff_odd_card (A : Finset (Vec (d + 1))) :
    (∀ w : Fin d → Vec (d + 1), Indep w → 2 * (oddBase A w).card = 2 ^ (d + 1))
      ↔ Odd A.card := by
  refine ⟨fun h => ?_, fun h w hw => balanced_of_odd_card h w hw⟩
  by_contra hA
  -- there is at least one independent tuple
  have hpos : 0 < (univ.filter fun w : Fin d → Vec (d + 1) => Indep w).card := by
    rw [card_indep_eq_prod (Nat.le_succ d)]
    refine Finset.prod_pos fun i _ => ?_
    have : (2 : ℕ) ^ (i : ℕ) < 2 ^ (d + 1) :=
      Nat.pow_lt_pow_right (by norm_num) (lt_trans i.isLt (Nat.lt_succ_self d))
    omega
  obtain ⟨w, hw⟩ := Finset.card_pos.1 hpos
  simp only [mem_filter, mem_univ, true_and] at hw
  exact not_balanced_of_even_card hA hw (h w hw)

/-- **The extremal sets for affine `n`-cubes in `𝔽₂ⁿ` are exactly those of odd size.** -/
theorem oddProb_eq_max_iff (A : Finset (Vec (d + 1))) :
    oddProb (d + 1) (d + 1) A = maxOddProb (d + 1) (d + 1) ↔ Odd A.card := by
  rw [AffineParitySingleton.maxOddProb_full_eq d, ← AffineParityGap.indepRatio_eq_prod
    (n := d + 1) (d := d) (Nat.le_succ d)]
  rw [oddProb_eq_indepRatio_iff (n := d + 1) (d := d) A]
  exact balanced_iff_odd_card A

end Characterisation

section Counting

/-- Exactly half of all subsets of a nonempty finite type have odd cardinality. -/
lemma card_odd_subsets (n : ℕ) :
    2 * (univ.filter fun A : Finset (Vec (n + 1)) => Odd A.card).card = 2 ^ (2 ^ (n + 1)) := by
  classical
  set p : Vec (n + 1) := 0 with hp
  have hinv : Function.Involutive (fun A : Finset (Vec (n + 1)) => symmDiff A {p}) := by
    intro A
    simp [symmDiff_symmDiff_cancel_right]
  have hflip : ∀ A : Finset (Vec (n + 1)),
      Odd (symmDiff A {p}).card ↔ ¬ Odd A.card := by
    intro A
    by_cases hmem : p ∈ A
    · have : symmDiff A {p} = A.erase p := by
        ext x
        simp only [Finset.mem_symmDiff, Finset.mem_singleton, Finset.mem_erase]
        constructor
        · rintro (⟨hx, hxp⟩ | ⟨rfl, hcon⟩)
          · exact ⟨hxp, hx⟩
          · exact absurd hmem hcon
        · rintro ⟨hxp, hx⟩
          exact Or.inl ⟨hx, hxp⟩
      rw [this, Finset.card_erase_of_mem hmem]
      have h1 : 1 ≤ A.card := Finset.card_pos.2 ⟨p, hmem⟩
      rw [Nat.odd_iff, Nat.odd_iff]
      omega
    · have : symmDiff A {p} = insert p A := by
        ext x
        simp only [Finset.mem_symmDiff, Finset.mem_singleton, Finset.mem_insert]
        constructor
        · rintro (⟨hx, hxp⟩ | ⟨rfl, -⟩)
          · exact Or.inr hx
          · exact Or.inl rfl
        · rintro (rfl | hx)
          · exact Or.inr ⟨rfl, hmem⟩
          · exact Or.inl ⟨hx, fun hcon => hmem (hcon ▸ hx)⟩
      rw [this, Finset.card_insert_of_notMem hmem]
      rw [Nat.odd_iff, Nat.odd_iff]
      omega
  have h := card_filter_involutive (fun A : Finset (Vec (n + 1)) => Odd A.card)
    (fun A => symmDiff A {p}) hinv hflip
  rwa [Fintype.card_finset, card_Vec] at h

/-- **The number of extremal sets** for affine `n`-cubes in `𝔽₂ⁿ` is `2^{2ⁿ - 1}`:
`8` for `n = 2`, `128` for `n = 3`. -/
theorem card_extremal (d : ℕ) :
    (univ.filter fun A : Finset (Vec (d + 1)) =>
        oddProb (d + 1) (d + 1) A = maxOddProb (d + 1) (d + 1)).card
      = 2 ^ (2 ^ (d + 1) - 1) := by
  classical
  have hfil : (univ.filter fun A : Finset (Vec (d + 1)) =>
      oddProb (d + 1) (d + 1) A = maxOddProb (d + 1) (d + 1))
      = univ.filter fun A : Finset (Vec (d + 1)) => Odd A.card :=
    Finset.filter_congr fun A _ => by rw [oddProb_eq_max_iff A]
  have h := card_odd_subsets d
  rw [hfil]
  have hpow : (2 : ℕ) ^ (2 ^ (d + 1)) = 2 * 2 ^ (2 ^ (d + 1) - 1) := by
    rw [← pow_succ']
    congr 1
    have : 1 ≤ 2 ^ (d + 1) := Nat.one_le_two_pow
    omega
  omega

end Counting

end AffineParityTopDim