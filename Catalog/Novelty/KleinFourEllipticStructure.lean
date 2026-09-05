import Mathlib
import Novelty.KleinFourTwoTorsionReciprocity

/-!
# The 2-torsion of `y² = x³ - c x` really is a Klein four-group

`Novelty/KleinFourTwoTorsionReciprocity.lean` counts the 2-torsion of the twist family
`E_d : y² = x³ - 3 d² x` over `𝔽_p` combinatorially (as roots of the 2-division polynomial).
This file upgrades the count to a *group-theoretic* statement using Mathlib's Weierstrass
curve group law: for a nonzero square `c` in `𝔽_p` (`p ≠ 2, 3`), the subgroup

`E[2] = {P ∈ E(𝔽_p) : P + P = 0}`

of the elliptic curve `E : y² = x³ - c x` is an `IsAddKleinFour` group, hence isomorphic to
`ZMod 2 × ZMod 2`; and if `c` is a non-square then `E[2]` has order two, so `E(𝔽_p)` contains
no Klein four-subgroup of 2-torsion.
-/

namespace KleinFourEllipticStructure

open WeierstrassCurve WeierstrassCurve.Affine

variable {p : ℕ} [Fact p.Prime]

/-- The Weierstrass curve `y² = x³ - c x` over `ZMod p`. -/
def curveC (c : ZMod p) : WeierstrassCurve (ZMod p) :=
  ⟨0, 0, 0, -c, 0⟩

@[simp] lemma curveC_a₁ (c : ZMod p) : (curveC c).a₁ = 0 := rfl
@[simp] lemma curveC_a₂ (c : ZMod p) : (curveC c).a₂ = 0 := rfl
@[simp] lemma curveC_a₃ (c : ZMod p) : (curveC c).a₃ = 0 := rfl
@[simp] lemma curveC_a₄ (c : ZMod p) : (curveC c).a₄ = -c := rfl
@[simp] lemma curveC_a₆ (c : ZMod p) : (curveC c).a₆ = 0 := rfl

lemma equation_curveC (c x y : ZMod p) :
    (curveC c).toAffine.Equation x y ↔ y ^ 2 = x ^ 3 - c * x := by
  rw [Affine.equation_iff]
  simp only [curveC_a₁, curveC_a₂, curveC_a₃, curveC_a₄, curveC_a₆]
  constructor <;> intro h <;> linear_combination h

lemma negY_curveC (c x y : ZMod p) : (curveC c).toAffine.negY x y = -y := by
  simp [Affine.negY]

/-- A point `(x, 0)` with `x` a simple root of the 2-division cubic is nonsingular. -/
lemma nonsingular_of_root {c x : ZMod p} (hx : x ^ 3 = c * x) (hx2 : 3 * x ^ 2 - c ≠ 0) :
    (curveC c).toAffine.Nonsingular x 0 := by
  rw [Affine.nonsingular_iff]
  refine ⟨(equation_curveC c x 0).2 (by linear_combination -hx), Or.inl ?_⟩
  simp only [curveC_a₁, curveC_a₂, curveC_a₄]
  intro h
  exact hx2 (by linear_combination -h)

/-! ## The 2-torsion subgroup -/

/-- The 2-torsion subgroup `E[2] = {P : P + P = 0}` of `E : y² = x³ - c x` over `𝔽_p`. -/
def E2 (c : ZMod p) : AddSubgroup (curveC c).toAffine.Point where
  carrier := {P | P + P = 0}
  add_mem' := by
    intro a b ha hb
    simp only [Set.mem_setOf_eq] at *
    have h : (a + b) + (a + b) = (a + a) + (b + b) := by abel
    rw [h, ha, hb, add_zero]
  zero_mem' := by simp
  neg_mem' := by
    intro a ha
    simp only [Set.mem_setOf_eq] at *
    rw [← neg_add, ha, neg_zero]

lemma mem_E2_iff {c : ZMod p} {P : (curveC c).toAffine.Point} : P ∈ E2 c ↔ P + P = 0 := Iff.rfl

/-- An affine point is 2-torsion exactly when its `y`-coordinate vanishes. -/
lemma mem_E2_some_iff (hp2 : p ≠ 2) {c x y : ZMod p}
    (h : (curveC c).toAffine.Nonsingular x y) : Point.some h ∈ E2 c ↔ y = 0 := by
  have h2 : (2 : ZMod p) ≠ 0 := by
    have h2' : ((2 : ℕ) : ZMod p) ≠ 0 := by
      rw [Ne, ZMod.natCast_eq_zero_iff]
      intro hdvd
      exact hp2 ((Nat.prime_dvd_prime_iff_eq (Fact.out : p.Prime) Nat.prime_two).1 hdvd)
    simpa using h2'
  rw [mem_E2_iff, add_eq_zero_iff_eq_neg, Point.neg_some, Point.some.injEq, negY_curveC]
  constructor
  · rintro ⟨-, hy⟩
    have hy2 : (2 : ZMod p) * y = 0 := by linear_combination hy
    rcases mul_eq_zero.1 hy2 with hh | hh
    · exact absurd hh h2
    · exact hh
  · rintro rfl
    exact ⟨rfl, by ring⟩

/-! ## The three affine 2-torsion points in the split regime -/

variable {c s : ZMod p}

lemma ns_zero (hc : c ≠ 0) : (curveC c).toAffine.Nonsingular (0 : ZMod p) 0 :=
  nonsingular_of_root (by ring) (by simpa using hc)

lemma ns_sqrt (h2 : (2 : ZMod p) ≠ 0) (hc : c ≠ 0) (hs : s ^ 2 = c) :
    (curveC c).toAffine.Nonsingular s 0 :=
  nonsingular_of_root (by linear_combination s * hs)
    (by rw [hs.symm] at hc ⊢; intro hcon; exact hc (by
      have : (2 : ZMod p) * s ^ 2 = 0 := by linear_combination hcon
      rcases mul_eq_zero.1 this with h | h
      · exact absurd h h2
      · exact h))

lemma ns_neg_sqrt (h2 : (2 : ZMod p) ≠ 0) (hc : c ≠ 0) (hs : s ^ 2 = c) :
    (curveC c).toAffine.Nonsingular (-s) 0 :=
  nonsingular_of_root (by linear_combination (-s) * hs)
    (by rw [hs.symm] at hc ⊢; intro hcon; exact hc (by
      have : (2 : ZMod p) * s ^ 2 = 0 := by linear_combination hcon
      rcases mul_eq_zero.1 this with h | h
      · exact absurd h h2
      · exact h))

/-- In the split regime the 2-torsion subgroup consists of exactly four points. -/
theorem E2_set_eq_of_isSquare (hp2 : p ≠ 2) (h2 : (2 : ZMod p) ≠ 0) (hc : c ≠ 0) (hs : s ^ 2 = c) :
    (E2 c : Set (curveC c).toAffine.Point) =
      {0, Point.some (ns_zero hc), Point.some (ns_sqrt h2 hc hs),
        Point.some (ns_neg_sqrt h2 hc hs)} := by
  ext P
  constructor
  · intro hP
    rcases P with _ | @⟨x, y, h⟩
    · exact Or.inl rfl
    · have hy : y = 0 := (mem_E2_some_iff hp2 h).1 hP
      subst hy
      have heq : (0 : ZMod p) ^ 2 = x ^ 3 - c * x := (equation_curveC c x 0).1 h.1
      have hfac : x * (x - s) * (x + s) = 0 := by linear_combination -heq - x * hs
      rcases mul_eq_zero.1 hfac with hfac' | hx
      · rcases mul_eq_zero.1 hfac' with hx | hx
        · subst hx; exact Or.inr (Or.inl rfl)
        · have : x = s := by linear_combination hx
          subst this; exact Or.inr (Or.inr (Or.inl rfl))
      · have : x = -s := by linear_combination hx
        subst this; exact Or.inr (Or.inr (Or.inr rfl))
  · rintro (rfl | rfl | rfl | rfl)
    · exact (E2 c).zero_mem
    · exact (mem_E2_some_iff hp2 _).2 rfl
    · exact (mem_E2_some_iff hp2 _).2 rfl
    · exact (mem_E2_some_iff hp2 _).2 rfl

/-! ## The Klein four-group structure -/

/-- **Split regime, group-theoretic form.** For a nonzero square `c` the 2-torsion subgroup has
order four. -/
theorem card_E2_of_isSquare (hp2 : p ≠ 2) (h2 : (2 : ZMod p) ≠ 0) (hc : c ≠ 0) (hs : s ^ 2 = c) :
    Nat.card (E2 c) = 4 := by
  have hs0 : s ≠ 0 := by
    rintro rfl
    exact hc (by simpa using hs.symm)
  have hsne : s ≠ -s := by
    intro hcon
    have h2s : (2 : ZMod p) * s = 0 := by linear_combination hcon
    rcases mul_eq_zero.1 h2s with h | h
    · exact absurd h h2
    · exact hs0 h
  rw [← SetLike.coe_sort_coe, Nat.card_coe_set_eq, E2_set_eq_of_isSquare hp2 h2 hc hs]
  rw [Set.ncard_insert_of_notMem (by simp) (Set.toFinite _),
    Set.ncard_insert_of_notMem (by simp [Point.some.injEq, hs0, hs0.symm])
      (Set.toFinite _),
    Set.ncard_pair (by simp [Point.some.injEq, hsne])]

/-- **The 2-torsion is a Klein four-group.** -/
theorem isAddKleinFour_E2 (hp2 : p ≠ 2) (h2 : (2 : ZMod p) ≠ 0) (hc : c ≠ 0) (hs : s ^ 2 = c) :
    IsAddKleinFour (E2 c) := by
  have hcard := card_E2_of_isSquare hp2 h2 hc hs
  haveI : Nontrivial (E2 c) := by
    refine ⟨⟨0, ⟨Point.some (ns_zero hc), (mem_E2_some_iff hp2 _).2 rfl⟩, ?_⟩⟩
    intro hcon
    exact Point.some_ne_zero (ns_zero hc) (congrArg Subtype.val hcon).symm
  refine ⟨hcard, ?_⟩
  rw [AddMonoid.exponent_eq_prime_iff Nat.prime_two]
  intro g hg
  refine addOrderOf_eq_prime ?_ hg
  ext
  push_cast
  rw [two_smul]
  exact g.2

/-- **Consequence.** In the split regime the 2-torsion subgroup is isomorphic to `ZMod 2 × ZMod 2`,
the Klein four-group. -/
theorem nonempty_addEquiv_E2 (hp2 : p ≠ 2) (h2 : (2 : ZMod p) ≠ 0) (hc : c ≠ 0) (hs : s ^ 2 = c) :
    Nonempty (E2 c ≃+ (ZMod 2 × ZMod 2)) := by
  haveI := isAddKleinFour_E2 hp2 h2 hc hs
  exact IsAddKleinFour.nonempty_addEquiv

/-! ## The non-split regime -/

/-- If `c` is a non-square, the only affine 2-torsion point is `(0,0)`. -/
theorem E2_set_eq_of_not_isSquare (hp2 : p ≠ 2) (hns : ¬ IsSquare c) :
    (E2 c : Set (curveC c).toAffine.Point) = {0, Point.some (ns_zero (by
      rintro rfl; exact hns (IsSquare.zero)))} := by
  have hc : c ≠ 0 := by rintro rfl; exact hns IsSquare.zero
  ext P
  constructor
  · intro hP
    rcases P with _ | @⟨x, y, h⟩
    · exact Or.inl rfl
    · have hy : y = 0 := (mem_E2_some_iff hp2 h).1 hP
      subst hy
      have heq : (0 : ZMod p) ^ 2 = x ^ 3 - c * x := (equation_curveC c x 0).1 h.1
      have hfac : x * (x ^ 2 - c) = 0 := by linear_combination -heq
      rcases mul_eq_zero.1 hfac with hx | hx
      · subst hx; exact Or.inr rfl
      · exact absurd ⟨x, by linear_combination -hx⟩ hns
  · rintro (rfl | rfl)
    · exact (E2 c).zero_mem
    · exact (mem_E2_some_iff hp2 _).2 rfl

/-- **Non-split regime, group-theoretic form.** For a non-square `c` the 2-torsion subgroup has
order two, so it is *not* a Klein four-group. -/
theorem card_E2_of_not_isSquare (hp2 : p ≠ 2) (hns : ¬ IsSquare c) : Nat.card (E2 c) = 2 := by
  rw [← SetLike.coe_sort_coe, Nat.card_coe_set_eq, E2_set_eq_of_not_isSquare hp2 hns,
    Set.ncard_pair (by simp)]

theorem not_isAddKleinFour_E2_of_not_isSquare (hp2 : p ≠ 2) (hns : ¬ IsSquare c) :
    ¬ IsAddKleinFour (E2 c) := by
  intro hK
  have := hK.card_four
  rw [card_E2_of_not_isSquare hp2 hns] at this
  exact absurd this (by norm_num)

/-! ## Flagship corollaries for the curve `y² = x³ - 3x` -/

/-- For `p ≡ 1` or `11 mod 12`, the 2-torsion of `y² = x³ - 3x` over `𝔽_p` is a Klein
four-group. -/
theorem kleinFour_of_mod_twelve (hp2 : p ≠ 2) (hp3 : p ≠ 3)
    (h : p % 12 = 1 ∨ p % 12 = 11) :
    Nonempty (E2 (3 : ZMod p) ≃+ (ZMod 2 × ZMod 2)) := by
  have h2 : (2 : ZMod p) ≠ 0 := by
    simpa using KleinFourTwoTorsion.cast_prime_ne_zero (p := p) Nat.prime_two hp2
  have hc : (3 : ZMod p) ≠ 0 := by
    simpa using KleinFourTwoTorsion.cast_prime_ne_zero (p := p) Nat.prime_three hp3
  obtain ⟨s, hs⟩ := (KleinFourTwoTorsion.isSquare_three_iff_mod_twelve hp2 hp3).2 h
  exact nonempty_addEquiv_E2 hp2 h2 hc (s := s) (by rw [hs]; ring)

/-- For `p ≡ 5` or `7 mod 12`, the 2-torsion of `y² = x³ - 3x` over `𝔽_p` has order two. -/
theorem card_E2_three_of_mod_twelve (hp2 : p ≠ 2) (hp3 : p ≠ 3)
    (h : p % 12 = 5 ∨ p % 12 = 7) : Nat.card (E2 (3 : ZMod p)) = 2 := by
  refine card_E2_of_not_isSquare hp2 (fun hsq => ?_)
  have := (KleinFourTwoTorsion.isSquare_three_iff_mod_twelve hp2 hp3).1 hsq
  omega

/-! ## Lagrange consequence: divisibility of the point count -/

/-- The affine point type of a Weierstrass curve over a finite field is finite. -/
instance instFinitePoint (c : ZMod p) : Finite (curveC c).toAffine.Point := by
  have hinj : Function.Injective
      (fun P : (curveC c).toAffine.Point =>
        match P with
        | 0 => (none : Option (ZMod p × ZMod p))
        | @Point.some _ _ _ x y _ => some (x, y)) := by
    rintro (_ | @⟨x₁, y₁, h₁⟩) (_ | @⟨x₂, y₂, h₂⟩) hP
    · rfl
    · exact absurd hP (by simp)
    · exact absurd hP (by simp)
    · simp only [Option.some.injEq, Prod.mk.injEq] at hP
      obtain ⟨rfl, rfl⟩ := hP
      rfl
  exact Finite.of_injective _ hinj

/-- The point count is positive, so the divisibility statements below are not vacuous. -/
theorem card_point_pos (c : ZMod p) : 0 < Nat.card (curveC c).toAffine.Point := Nat.card_pos

/-- **Four divides the point count in the split regime.** If `c` is a nonzero square then the
Klein four 2-torsion subgroup forces `4 ∣ #E(𝔽_p)`. -/
theorem four_dvd_card_point (hp2 : p ≠ 2) (h2 : (2 : ZMod p) ≠ 0) (hc : c ≠ 0) (hs : s ^ 2 = c) :
    4 ∣ Nat.card (curveC c).toAffine.Point := by
  have := card_E2_of_isSquare hp2 h2 hc hs
  simpa [this] using AddSubgroup.card_addSubgroup_dvd_card (E2 c)

/-- For `p ≡ 1, 11 mod 12` the curve `y² = x³ - 3x` over `𝔽_p` has point count divisible
by `4`. -/
theorem four_dvd_card_point_three (hp2 : p ≠ 2) (hp3 : p ≠ 3)
    (h : p % 12 = 1 ∨ p % 12 = 11) : 4 ∣ Nat.card (curveC (3 : ZMod p)).toAffine.Point := by
  have h2 : (2 : ZMod p) ≠ 0 := by
    simpa using KleinFourTwoTorsion.cast_prime_ne_zero (p := p) Nat.prime_two hp2
  have hc : (3 : ZMod p) ≠ 0 := by
    simpa using KleinFourTwoTorsion.cast_prime_ne_zero (p := p) Nat.prime_three hp3
  obtain ⟨t, ht⟩ := (KleinFourTwoTorsion.isSquare_three_iff_mod_twelve hp2 hp3).2 h
  exact four_dvd_card_point hp2 h2 hc (s := t) (by rw [ht]; ring)

/-- In every regime the point count is even: the point `(0,0)` always has order two. -/
theorem two_dvd_card_point (hp2 : p ≠ 2) (hc : c ≠ 0) :
    2 ∣ Nat.card (curveC c).toAffine.Point := by
  have hsub : Nat.card (AddSubgroup.zmultiples (Point.some (ns_zero hc)))
      ∣ Nat.card (curveC c).toAffine.Point :=
    AddSubgroup.card_addSubgroup_dvd_card _
  have hord : addOrderOf (Point.some (ns_zero hc)) = 2 := by
    refine addOrderOf_eq_prime ?_ (Point.some_ne_zero _)
    rw [two_smul]
    exact (mem_E2_some_iff hp2 (ns_zero hc)).2 rfl
  rwa [Nat.card_zmultiples, hord] at hsub

end KleinFourEllipticStructure