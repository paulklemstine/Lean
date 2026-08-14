/-
# ECM-PARITY, the mod-4 face: `4 ∣ #E` on `[1,1,1]`, and the exact law on `[1]`

`ECMParityCore` computes `#E` mod `2`.  This file computes `#E` mod `4`, by
refining the fibrewise count with the **translation-by-2-torsion involution**

  `τ_a(x) = a + k/(x - a)`,  `k = 3a² + A`  (the `x`-coordinate of `P + (a,0)`),

acting on the set `sqSet` of `x` whose fibre `{y : y² = f(x)}` has two points.
Since `#affine = r + 2·#sqSet` with `r = #roots`, the parity of `#sqSet` decides
`#E` mod `4`, and the parity of `#sqSet` equals the number of fixed points of
`τ_a`, i.e. of solutions of `(x - a)² = k`.

Results:

* `ECMParity.four_dvd_curveCard_of_three_roots` — on the split face `[1,1,1]`
  the order is divisible by `4` (full rational `2`-torsion), confirming the
  empirical finding.
* `ECMParity.curveCard_mod_four_of_unique_root` — **the correction**: on the
  transposition face `[1]` the order is `≡ 2 (mod 4)` **iff `3a² + A` is a
  non-square**, where `a` is the unique rational root; when `3a² + A` is a
  square one gets `4 ∣ #E` (a point of order `4`).  The blanket claim
  "`#E ≡ 2 (mod 4)` on the transposition face" is therefore false; see
  `ECMParity.E0Card_23` for the explicit counterexample `p = 23`,
  `#E₀(𝔽₂₃) = 28`, whose cubic `x³ + x + 1` has the single root `x = 4`.
-/
import Mathlib
import Algebra.ECMParityCore
import Algebra.ECMParityFrobenius

namespace ECMParity

open Finset

/-! ## 1. Parity under an involution -/

/-- A fixed-point-free involution of a finite set forces even cardinality. -/
theorem card_even_of_free_involution {α : Type*} [DecidableEq α] (s : Finset α) (g : α → α)
    (hmem : ∀ a ∈ s, g a ∈ s) (hinv : ∀ a ∈ s, g (g a) = a) (hfree : ∀ a ∈ s, g a ≠ a) :
    Even s.card := by
  have hsum : ∑ _x ∈ s, (1 : ZMod 2) = 0 := by
    refine Finset.sum_involution (fun a _ => g a) (fun a _ => by decide) (fun a ha _ => ?_)
      (fun a ha => hmem a ha) (fun a ha => hinv a ha)
    exact hfree a ha
  rw [Finset.sum_const, nsmul_eq_mul, mul_one] at hsum
  exact ZMod.natCast_eq_zero_iff_even.1 hsum

/-- Cardinality mod `2` of a set carrying an involution equals the number of fixed
points mod `2`. -/
theorem card_mod_two_eq_card_fixed {α : Type*} [DecidableEq α] (s : Finset α) (g : α → α)
    (hmem : ∀ a ∈ s, g a ∈ s) (hinv : ∀ a ∈ s, g (g a) = a) :
    (s.card : ZMod 2) = ((s.filter (fun a => g a = a)).card : ZMod 2) := by
  classical
  have hsplit : (s.filter (fun a => g a = a)).card + (s.filter (fun a => ¬ g a = a)).card
      = s.card := Finset.card_filter_add_card_filter_not _
  have heven : Even (s.filter (fun a => ¬ g a = a)).card := by
    refine card_even_of_free_involution _ g (fun a ha => ?_) (fun a ha => ?_) (fun a ha => ?_)
    · simp only [Finset.mem_filter] at ha ⊢
      refine ⟨hmem a ha.1, ?_⟩
      rw [hinv a ha.1]
      exact fun h => ha.2 h.symm
    · simp only [Finset.mem_filter] at ha
      exact hinv a ha.1
    · simp only [Finset.mem_filter] at ha
      exact ha.2
  have h0 : (((s.filter (fun a => ¬ g a = a)).card : ℕ) : ZMod 2) = 0 :=
    ZMod.natCast_eq_zero_iff_even.2 heven
  rw [← hsplit]
  push_cast
  rw [h0, add_zero]

/-! ## 2. Exact fibre counting -/

variable {p : ℕ} [Fact p.Prime]

/-- The `x` whose fibre has two points: `f(x)` a nonzero square. -/
def sqSet (A B : ZMod p) : Finset (ZMod p) :=
  univ.filter (fun x => cubic A B x ≠ 0 ∧ ∃ y : ZMod p, cubic A B x = y * y)

theorem mem_sqSet {A B x : ZMod p} :
    x ∈ sqSet A B ↔ cubic A B x ≠ 0 ∧ IsSquare (cubic A B x) := by
  simp [sqSet, IsSquare]

/-- Exact fibre count: `1` over a root, `2` over a nonzero square value, `0` otherwise. -/
theorem card_sqrt_fiber_exact (hp : p ≠ 2) (c : ZMod p) :
    (univ.filter (fun y : ZMod p => y ^ 2 = c)).card
      = if c = 0 then 1 else if IsSquare c then 2 else 0 := by
  have hp2 : (2 : ZMod p) ≠ 0 := two_ne_zero_of_odd hp
  by_cases hc : c = 0
  · subst hc
    have hset : (univ.filter (fun y : ZMod p => y ^ 2 = 0)) = {0} := by
      ext y; simp [pow_eq_zero_iff]
    rw [hset, Finset.card_singleton, if_pos rfl]
  · simp only [hc, if_false]
    by_cases hs : IsSquare c
    · obtain ⟨y₀, hy₀⟩ := hs
      have hy₀' : y₀ ^ 2 = c := by rw [hy₀]; ring
      have hy0 : y₀ ≠ 0 := by
        rintro rfl; exact hc (by simpa using hy₀)
      have hne : y₀ ≠ -y₀ := by
        intro h
        apply hy0
        have h2 : (2 : ZMod p) * y₀ = 0 := by linear_combination h
        rcases mul_eq_zero.1 h2 with h' | h'
        · exact absurd h' hp2
        · exact h'
      have hset : (univ.filter (fun y : ZMod p => y ^ 2 = c)) = {y₀, -y₀} := by
        ext y
        simp only [mem_filter, mem_univ, true_and, mem_insert, mem_singleton]
        constructor
        · intro hy
          have hfac : (y - y₀) * (y + y₀) = 0 := by linear_combination hy - hy₀'
          rcases mul_eq_zero.1 hfac with h | h
          · exact Or.inl (sub_eq_zero.1 h)
          · exact Or.inr (eq_neg_of_add_eq_zero_left h)
        · rintro (rfl | rfl)
          · exact hy₀'
          · rw [neg_pow]; simpa using hy₀'
      rw [hset, Finset.card_insert_of_notMem (by simpa using hne), Finset.card_singleton,
        if_pos ⟨y₀, hy₀⟩]
    · have hset : (univ.filter (fun y : ZMod p => y ^ 2 = c)) = ∅ := by
        ext y
        simp only [mem_filter, mem_univ, true_and, Finset.notMem_empty, iff_false]
        intro hy
        exact hs ⟨y, by rw [← hy]; ring⟩
      simp [hset, hs]

/-- `#affine = #roots + 2·#sqSet`. -/
theorem affine_card_eq (hp : p ≠ 2) (A B : ZMod p) :
    (affinePoints A B).card = (rootSet A B).card + 2 * (sqSet A B).card := by
  classical
  have h1 : (affinePoints A B).card
      = ∑ x : ZMod p, (univ.filter (fun y : ZMod p => y ^ 2 = cubic A B x)).card := by
    rw [affinePoints, card_filter, Fintype.sum_prod_type]
    exact Finset.sum_congr rfl (fun x _ => by rw [card_filter])
  have h2 : ∀ x : ZMod p, (univ.filter (fun y : ZMod p => y ^ 2 = cubic A B x)).card
      = (if cubic A B x = 0 then 1 else 0) + 2 * (if x ∈ sqSet A B then 1 else 0) := by
    intro x
    rw [card_sqrt_fiber_exact hp]
    by_cases hz : cubic A B x = 0
    · simp [hz, mem_sqSet]
    · by_cases hsq : IsSquare (cubic A B x) <;>
        simp [hz, hsq, mem_sqSet]
  rw [h1]
  simp only [h2, Finset.sum_add_distrib, ← Finset.mul_sum]
  congr 1
  · rw [rootSet, card_filter]
  · rw [Finset.sum_ite_mem]
    simp [Finset.inter_eq_right.2 (Finset.subset_univ _)]

theorem curveCard_eq (hp : p ≠ 2) (A B : ZMod p) :
    curveCard A B = 1 + (rootSet A B).card + 2 * (sqSet A B).card := by
  rw [curveCard, affine_card_eq hp]
  ring

/-! ## 3. The translation involution -/

/-- The `x`-coordinate of translation by the `2`-torsion point `(a,0)`. -/
def tw (a k x : ZMod p) : ZMod p := a + k / (x - a)

section Root

variable {A B a : ZMod p}

theorem hB_of_root (ha : cubic A B a = 0) : B = -a ^ 3 - A * a := by
  unfold cubic at ha; linear_combination ha

/-- `f(a + u) = u (u² + 3au + k)` with `k = 3a² + A`. -/
theorem cubic_shift (ha : cubic A B a = 0) (u : ZMod p) :
    cubic A B (a + u) = u * (u ^ 2 + 3 * a * u + (3 * a ^ 2 + A)) := by
  rw [cubic, hB_of_root ha]; ring

/-- The discriminant factors as `k²·(-3a² - 4A)` at a root `a`. -/
theorem disc_factor_at_root (ha : cubic A B a = 0) :
    disc A B = (3 * a ^ 2 + A) ^ 2 * (-3 * a ^ 2 - 4 * A) := by
  rw [disc, hB_of_root ha]; ring

theorem k_ne_zero (ha : cubic A B a = 0) (hd : disc A B ≠ 0) : 3 * a ^ 2 + A ≠ 0 := by
  intro h
  apply hd
  rw [disc_factor_at_root ha, h]; ring

/-- The key transformation identity: `f(τ_a x)·(x-a)⁴ = k²·f(x)`. -/
theorem cubic_tw (ha : cubic A B a = 0) {x : ZMod p} (hx : x ≠ a) :
    cubic A B (tw a (3 * a ^ 2 + A) x) * (x - a) ^ 4
      = (3 * a ^ 2 + A) ^ 2 * cubic A B x := by
  have hu : x - a ≠ 0 := sub_ne_zero.2 hx
  rw [tw, cubic_shift ha, cubic, hB_of_root ha]
  field_simp
  ring

theorem tw_ne (hk : (3 * a ^ 2 + A) ≠ 0) {x : ZMod p} (hx : x ≠ a) :
    tw a (3 * a ^ 2 + A) x ≠ a := by
  have hu : x - a ≠ 0 := sub_ne_zero.2 hx
  simp only [tw, ne_eq, add_eq_left, div_eq_zero_iff]
  push_neg
  exact ⟨hk, hu⟩

theorem tw_tw (hk : (3 * a ^ 2 + A) ≠ 0) {x : ZMod p} (hx : x ≠ a) :
    tw a (3 * a ^ 2 + A) (tw a (3 * a ^ 2 + A) x) = x := by
  have hu : x - a ≠ 0 := sub_ne_zero.2 hx
  have hdd : (3 * a ^ 2 + A) / ((3 * a ^ 2 + A) / (x - a)) = x - a := by
    field_simp
  simp only [tw, add_sub_cancel_left, hdd]
  ring

theorem mem_sqSet_ne (ha : cubic A B a = 0) {x : ZMod p}
    (hx : x ∈ sqSet A B) : x ≠ a := by
  intro h
  rw [mem_sqSet] at hx
  exact hx.1 (by rw [h, ha])

/-- `τ_a` preserves `sqSet`. -/
theorem tw_mem_sqSet (ha : cubic A B a = 0) (hd : disc A B ≠ 0) {x : ZMod p}
    (hx : x ∈ sqSet A B) : tw a (3 * a ^ 2 + A) x ∈ sqSet A B := by
  have hk := k_ne_zero ha hd
  have hxa : x ≠ a := mem_sqSet_ne ha hx
  have hu : x - a ≠ 0 := sub_ne_zero.2 hxa
  rw [mem_sqSet] at hx ⊢
  obtain ⟨hne, s, hs⟩ := hx
  have hkey := cubic_tw ha hxa
  have hval : cubic A B (tw a (3 * a ^ 2 + A) x)
      = ((3 * a ^ 2 + A) * s / (x - a) ^ 2) * ((3 * a ^ 2 + A) * s / (x - a) ^ 2) := by
    field_simp
    rw [hkey, hs]
    ring
  refine ⟨?_, ⟨_, hval⟩⟩
  rw [hval]
  refine mul_ne_zero ?_ ?_ <;>
    exact div_ne_zero (mul_ne_zero hk (by rintro rfl; exact hne (by rw [hs]; ring)))
      (pow_ne_zero 2 hu)

/-- Fixed points of `τ_a` on `sqSet` are the solutions of `(x - a)² = k`. -/
theorem tw_fixed_iff (ha : cubic A B a = 0) {x : ZMod p}
    (hx : x ∈ sqSet A B) :
    tw a (3 * a ^ 2 + A) x = x ↔ (x - a) ^ 2 = 3 * a ^ 2 + A := by
  have hxa : x ≠ a := mem_sqSet_ne ha hx
  have hu : x - a ≠ 0 := sub_ne_zero.2 hxa
  rw [tw]
  constructor
  · intro h
    field_simp at h
    linear_combination -h
  · intro h
    field_simp
    linear_combination -h

end Root

/-! ## 3b. Quadratic character bookkeeping -/

/-- If `cd` is a nonzero square, `c` and `d` have the same quadratic character. -/
theorem isSquare_iff_of_mul_isSquare {c d : ZMod p} (hc : c ≠ 0) (hd : d ≠ 0)
    (hcd : IsSquare (c * d)) : IsSquare c ↔ IsSquare d := by
  have hmul : quadraticChar (ZMod p) (c * d)
      = quadraticChar (ZMod p) c * quadraticChar (ZMod p) d := map_mul _ _ _
  rw [(quadraticChar_one_iff_isSquare (mul_ne_zero hc hd)).2 hcd] at hmul
  constructor
  · intro h
    rw [(quadraticChar_one_iff_isSquare hc).2 h, one_mul] at hmul
    exact (quadraticChar_one_iff_isSquare hd).1 hmul.symm
  · intro h
    rw [(quadraticChar_one_iff_isSquare hd).2 h, mul_one] at hmul
    exact (quadraticChar_one_iff_isSquare hc).1 hmul.symm

/-- If `cd` is a non-square, exactly one of `c`, `d` is a square. -/
theorem isSquare_iff_not_of_mul_not_isSquare {c d : ZMod p} (hc : c ≠ 0) (hd : d ≠ 0)
    (hcd : ¬ IsSquare (c * d)) : IsSquare c ↔ ¬ IsSquare d := by
  have hmul : quadraticChar (ZMod p) (c * d)
      = quadraticChar (ZMod p) c * quadraticChar (ZMod p) d := map_mul _ _ _
  rw [quadraticChar_neg_one_iff_not_isSquare.2 hcd] at hmul
  constructor
  · intro h hd'
    rw [(quadraticChar_one_iff_isSquare hc).2 h, one_mul,
      (quadraticChar_one_iff_isSquare hd).2 hd'] at hmul
    norm_num at hmul
  · intro h
    rw [quadraticChar_neg_one_iff_not_isSquare.2 h] at hmul
    have hc1 : quadraticChar (ZMod p) c = 1 := by linarith
    exact (quadraticChar_one_iff_isSquare hc).1 hc1

/-! ## 4. The two faces mod `4` -/

section Faces

variable {A B a : ZMod p}

/-- Parity of `#sqSet` equals the number of solutions of `(x-a)² = k` inside `sqSet`. -/
theorem sqSet_card_mod_two (hd : disc A B ≠ 0) (ha : cubic A B a = 0) :
    ((sqSet A B).card : ZMod 2)
      = (((sqSet A B).filter (fun x => tw a (3 * a ^ 2 + A) x = x)).card : ZMod 2) := by
  refine card_mod_two_eq_card_fixed _ _ (fun x hx => tw_mem_sqSet ha hd hx) (fun x hx => ?_)
  exact tw_tw (k_ne_zero ha hd) (mem_sqSet_ne ha hx)

/-- The product of the two candidate fixed values is the discriminant. -/
theorem cubic_pair_prod (ha : cubic A B a = 0) {w : ZMod p} (hw : w * w = 3 * a ^ 2 + A) :
    cubic A B (a + w) * cubic A B (a - w) = disc A B := by
  have hA : A = w * w - 3 * a ^ 2 := by linear_combination -hw
  rw [cubic, cubic, disc, hB_of_root ha, hA]
  ring

/-- On the split face the fixed set has even cardinality, because `Δ` is a square. -/
theorem fixed_card_even_of_disc_isSquare (hd : disc A B ≠ 0) (ha : cubic A B a = 0)
    (hsq : IsSquare (disc A B)) (hp : p ≠ 2) :
    Even (((sqSet A B).filter (fun x => tw a (3 * a ^ 2 + A) x = x)).card) := by
  classical
  by_cases hk : IsSquare (3 * a ^ 2 + A)
  · obtain ⟨w, hw⟩ := hk
    have hw' : w * w = 3 * a ^ 2 + A := hw.symm
    have hwne : w ≠ 0 := by
      rintro rfl
      exact k_ne_zero ha hd (by simpa using hw'.symm)
    -- membership of `a+w` and `a-w` in `sqSet` is equivalent
    have hprod := cubic_pair_prod ha hw'
    have hne1 : cubic A B (a + w) ≠ 0 := by
      intro h; rw [h, zero_mul] at hprod; exact hd hprod.symm
    have hne2 : cubic A B (a - w) ≠ 0 := by
      intro h; rw [h, mul_zero] at hprod; exact hd hprod.symm
    have hchar := isSquare_iff_of_mul_isSquare hne1 hne2 (by rw [hprod]; exact hsq)
    have hiff : (a + w) ∈ sqSet A B ↔ (a - w) ∈ sqSet A B := by
      rw [mem_sqSet, mem_sqSet]
      exact ⟨fun h => ⟨hne2, hchar.1 h.2⟩, fun h => ⟨hne1, hchar.2 h.2⟩⟩
    -- the fixed set is `sqSet ∩ {a+w, a-w}`
    have hfix : ((sqSet A B).filter (fun x => tw a (3 * a ^ 2 + A) x = x))
        = (sqSet A B).filter (fun x => x = a + w ∨ x = a - w) := by
      ext x
      simp only [Finset.mem_filter, and_congr_right_iff]
      intro hx
      rw [tw_fixed_iff ha hx]
      constructor
      · intro h
        have hfac : (x - a - w) * (x - a + w) = 0 := by linear_combination h - hw'
        rcases mul_eq_zero.1 hfac with h' | h'
        · exact Or.inl (by linear_combination h')
        · exact Or.inr (by linear_combination h')
      · rintro (rfl | rfl) <;> linear_combination hw'
    rw [hfix]
    by_cases hmem : (a + w) ∈ sqSet A B
    · have hmem2 : (a - w) ∈ sqSet A B := hiff.1 hmem
      have : (sqSet A B).filter (fun x => x = a + w ∨ x = a - w) = {a + w, a - w} := by
        ext x
        simp only [Finset.mem_filter, Finset.mem_insert, Finset.mem_singleton]
        constructor
        · exact fun h => h.2
        · rintro (rfl | rfl)
          · exact ⟨hmem, Or.inl rfl⟩
          · exact ⟨hmem2, Or.inr rfl⟩
      rw [this]
      have hdist : a + w ≠ a - w := by
        intro h
        apply hwne
        have h2 : (2 : ZMod p) * w = 0 := by linear_combination h
        rcases mul_eq_zero.1 h2 with h' | h'
        · exact absurd h' (two_ne_zero_of_odd hp)
        · exact h'
      rw [Finset.card_insert_of_notMem (by simpa using hdist), Finset.card_singleton]
      exact ⟨1, rfl⟩
    · have hmem2 : (a - w) ∉ sqSet A B := fun h => hmem (hiff.2 h)
      have : (sqSet A B).filter (fun x => x = a + w ∨ x = a - w) = ∅ := by
        ext x
        simp only [Finset.mem_filter, Finset.notMem_empty, iff_false, not_and]
        rintro hx (rfl | rfl)
        · exact hmem hx
        · exact hmem2 hx
      rw [this]
      simp
  · -- `k` is not a square: no fixed points at all
    have : ((sqSet A B).filter (fun x => tw a (3 * a ^ 2 + A) x = x)) = ∅ := by
      ext x
      simp only [Finset.mem_filter, Finset.notMem_empty, iff_false, not_and]
      intro hx hfix
      rw [tw_fixed_iff ha hx] at hfix
      exact hk ⟨x - a, by rw [← hfix]; ring⟩
    rw [this]
    simp

/-- **Split face.**  If the cubic has two distinct roots (hence three), then
`4 ∣ #E`: the full rational `2`-torsion. -/
theorem four_dvd_curveCard_of_three_roots (hp : p ≠ 2) {b : ZMod p} (hd : disc A B ≠ 0)
    (ha : cubic A B a = 0) (hb : cubic A B b = 0) (hab : a ≠ b) :
    4 ∣ curveCard A B := by
  have hsq : IsSquare (disc A B) := disc_isSquare_of_three_roots hab ha hb
  have heven := fixed_card_even_of_disc_isSquare hd ha hsq hp
  have hpar : ((sqSet A B).card : ZMod 2) = 0 := by
    rw [sqSet_card_mod_two hd ha]
    exact ZMod.natCast_eq_zero_iff_even.2 heven
  have heven' : Even (sqSet A B).card := ZMod.natCast_eq_zero_iff_even.1 hpar
  obtain ⟨t, ht⟩ := heven'
  have hr : (rootSet A B).card = 3 := rootSet_card_eq_three hab ha hb hd
  rw [curveCard_eq hp, hr, ht]
  omega

/-- **Transposition face, corrected law.**  If the cubic has the unique root `a`, then
`#E ≡ 2 (mod 4)` exactly when `k = 3a² + A` is a non-square; otherwise `4 ∣ #E`. -/
theorem curveCard_mod_four_of_unique_root (hp : p ≠ 2) (hd : disc A B ≠ 0)
    (ha : cubic A B a = 0) (huniq : ∀ x : ZMod p, cubic A B x = 0 → x = a) :
    curveCard A B % 4 = if IsSquare (3 * a ^ 2 + A) then 0 else 2 := by
  classical
  have hk : (3 * a ^ 2 + A) ≠ 0 := k_ne_zero ha hd
  have hdns : ¬ IsSquare (disc A B) := disc_not_isSquare_of_unique_root hp hd ha huniq
  have hr : (rootSet A B).card = 1 := by
    have : rootSet A B = {a} := by
      ext x
      simp only [rootSet, Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_singleton]
      exact ⟨huniq x, fun h => by rw [h]; exact ha⟩
    rw [this, Finset.card_singleton]
  by_cases hksq : IsSquare (3 * a ^ 2 + A)
  · -- exactly one fixed point, so `#sqSet` is odd and `4 ∣ #E`
    obtain ⟨w, hw⟩ := id hksq
    have hw' : w * w = 3 * a ^ 2 + A := hw.symm
    have hwne : w ≠ 0 := by
      rintro rfl
      exact hk (by simpa using hw'.symm)
    have hprod := cubic_pair_prod ha hw'
    have hne1 : cubic A B (a + w) ≠ 0 := by
      intro h; rw [h, zero_mul] at hprod; exact hd hprod.symm
    have hne2 : cubic A B (a - w) ≠ 0 := by
      intro h; rw [h, mul_zero] at hprod; exact hd hprod.symm
    have hchar := isSquare_iff_not_of_mul_not_isSquare hne1 hne2 (by rw [hprod]; exact hdns)
    have hdist : a + w ≠ a - w := by
      intro h
      apply hwne
      have h2 : (2 : ZMod p) * w = 0 := by linear_combination h
      rcases mul_eq_zero.1 h2 with h' | h'
      · exact absurd h' (two_ne_zero_of_odd hp)
      · exact h'
    -- exactly one of `a ± w` lies in `sqSet`
    have hxor : ((a + w) ∈ sqSet A B ∧ (a - w) ∉ sqSet A B)
        ∨ ((a + w) ∉ sqSet A B ∧ (a - w) ∈ sqSet A B) := by
      by_cases h1 : IsSquare (cubic A B (a + w))
      · exact Or.inl ⟨mem_sqSet.2 ⟨hne1, h1⟩, fun hm => (hchar.1 h1) (mem_sqSet.1 hm).2⟩
      · refine Or.inr ⟨fun hm => h1 (mem_sqSet.1 hm).2, mem_sqSet.2 ⟨hne2, ?_⟩⟩
        by_contra h2
        exact h1 (hchar.2 h2)
    have hfix : ((sqSet A B).filter (fun x => tw a (3 * a ^ 2 + A) x = x)).card = 1 := by
      have hset : ((sqSet A B).filter (fun x => tw a (3 * a ^ 2 + A) x = x))
          = (sqSet A B).filter (fun x => x = a + w ∨ x = a - w) := by
        ext x
        simp only [Finset.mem_filter, and_congr_right_iff]
        intro hx
        rw [tw_fixed_iff ha hx]
        constructor
        · intro h
          have hfac : (x - a - w) * (x - a + w) = 0 := by linear_combination h - hw'
          rcases mul_eq_zero.1 hfac with h' | h'
          · exact Or.inl (by linear_combination h')
          · exact Or.inr (by linear_combination h')
        · rintro (rfl | rfl) <;> linear_combination hw'
      rw [hset]
      rcases hxor with ⟨hin, hout⟩ | ⟨hout, hin⟩
      · have : (sqSet A B).filter (fun x => x = a + w ∨ x = a - w) = {a + w} := by
          ext x
          simp only [Finset.mem_filter, Finset.mem_singleton]
          constructor
          · rintro ⟨hx, rfl | rfl⟩
            · rfl
            · exact absurd hx hout
          · rintro rfl; exact ⟨hin, Or.inl rfl⟩
        rw [this, Finset.card_singleton]
      · have : (sqSet A B).filter (fun x => x = a + w ∨ x = a - w) = {a - w} := by
          ext x
          simp only [Finset.mem_filter, Finset.mem_singleton]
          constructor
          · rintro ⟨hx, rfl | rfl⟩
            · exact absurd hx hout
            · rfl
          · rintro rfl; exact ⟨hin, Or.inr rfl⟩
        rw [this, Finset.card_singleton]
    have hodd : ¬ Even (sqSet A B).card := by
      intro hev
      have h0 : ((sqSet A B).card : ZMod 2) = 0 := ZMod.natCast_eq_zero_iff_even.2 hev
      rw [sqSet_card_mod_two hd ha, hfix] at h0
      exact absurd h0 (by decide)
    rw [Nat.not_even_iff_odd] at hodd
    obtain ⟨t, ht⟩ := hodd
    rw [curveCard_eq hp, hr, ht, if_pos hksq]
    omega
  · -- no fixed points, `#sqSet` even, `#E ≡ 2 (mod 4)`
    have hnofix : ((sqSet A B).filter (fun x => tw a (3 * a ^ 2 + A) x = x)) = ∅ := by
      ext x
      simp only [Finset.mem_filter, Finset.notMem_empty, iff_false, not_and]
      intro hx hf
      rw [tw_fixed_iff ha hx] at hf
      exact hksq ⟨x - a, by rw [← hf]; ring⟩
    have hpar : ((sqSet A B).card : ZMod 2) = 0 := by
      rw [sqSet_card_mod_two hd ha, hnofix]; simp
    obtain ⟨t, ht⟩ := ZMod.natCast_eq_zero_iff_even.1 hpar
    rw [curveCard_eq hp, hr, ht, if_neg hksq]
    omega

end Faces

/-! ## 5. The counterexample to "`#E ≡ 2 (mod 4)` on the transposition face" -/

/-- `x³ + x + 1` has the single root `x = 4` mod `23`. -/
instance fact_prime_23 : Fact (Nat.Prime 23) := ⟨by norm_num⟩

theorem rootSet_23 : rootSet (1 : ZMod 23) 1 = {4} := by decide

/-- Nevertheless `#E₀(𝔽₂₃) = 28 ≡ 0 (mod 4)`: the transposition face does *not* force
`#E ≡ 2 (mod 4)`.  Indeed `3a² + A = 3·16 + 1 = 49 = 3 (mod 23)` is a square mod `23`
(`7² = 3`), so `ECMParity.curveCard_mod_four_of_unique_root` predicts `4 ∣ #E`. -/
theorem curveCard_23 : curveCard (1 : ZMod 23) 1 = 28 := by decide

end ECMParity