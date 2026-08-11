import Pythagorean.RationalStarFarey

/-!
# Which stars are visible: a Farey-level resolution law

The last piece of the explanation of the picture. `RationalStarPencil` shows that *every*
rational boundary point `p/q` carries a fan of radial lines, at the quantised hyperbolic
levels `arsinh (|k|/q)`. Why then does the eye see only the fans at `0, 1, 1/2, 1/3, 1/5,
…`? Because the *Euclidean* gap between two adjacent rays of the star at `p/q`, measured at
plot height `y`, is exactly `y/q`: it shrinks with the denominator. At a given plotting
resolution `ε` only the stars with `q ≤ y/ε` are resolved, and those are exactly the Farey
fractions of level `⌊y/ε⌋` — a finite set, counted by `∑_{q ≤ Q} φ(q)`.

## Main results

* `same_height_separation` : two nodes at the same height `1/m` whose charges at `p/q`
  differ by `d` are separated horizontally by exactly `|d|/(q m) = |d| y / q`.
* `adjacent_ray_gap` : consecutive rays of the star at `p/q` are `y/q` apart at height `y`.
* `resolved_iff_denominator_le` : the star at `p/q` is resolved at height `y` and
  resolution `ε` (`y/q ≥ ε`) if and only if `q ≤ y/ε`.
* `card_fareyStars` : the number of star centres in `(0,1]` of denominator at most `Q` is
  `∑_{q=1}^{Q} φ(q)` — the Farey count. Together with the previous item: **the set of
  visible star centres at resolution `ε` and height `y` is the Farey set of level
  `⌊y/ε⌋`, and it is finite of size `∑_{q ≤ ⌊y/ε⌋} φ(q)`.**
* `visible_star_centres` : the packaged statement.

For example at height `y = 0.5` and a resolution of one part in `10`, the resolvable stars
are those with `q ≤ 5`: the centres `1/1, 1/2, 1/3, 2/3, 1/4, 3/4, 1/5, 2/5, 3/5, 4/5`
(together with `0`), which is precisely the set of fans that the plot displays.
-/

namespace BerggrenRationalStar

open BerggrenHypercycleStars Finset

/-! ## Part 1. The Euclidean gap between two rays -/

/-- **Ray separation at a fixed height.** Two nodes of the same height `1/m` whose charges
at `p/q` differ by `d` are separated in the real part by exactly `|d| / (q m)`. -/
theorem same_height_separation (p : ℤ) (q m n n' : ℕ) (hq : 0 < q) (hm : 0 < m) :
    |(hpoint m n hm).re - (hpoint m n' hm).re|
      = |(charge p q m n : ℝ) - (charge p q m n' : ℝ)| / ((q : ℝ) * m) := by
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hQ : (0 : ℝ) < (q : ℝ) := by exact_mod_cast hq
  have hdiff : (charge p q m n : ℝ) - (charge p q m n' : ℝ) = -((q : ℝ) * ((n : ℝ) - n')) := by
    simp only [charge, chargeZ, Int.cast_sub, Int.cast_mul, Int.cast_natCast]
    ring
  rw [hdiff, abs_neg, abs_mul, abs_of_pos hQ, hpoint_re, hpoint_re]
  rw [show (n : ℝ) / m - (n' : ℝ) / m = ((n : ℝ) - n') / m by field_simp, abs_div,
    abs_of_pos hM]
  field_simp

/-- **The gap between adjacent rays.** At the height `y = 1/m` the rays of charges `k` and
`k + 1` at `p/q` are separated by exactly `y / q`. Small denominators give wide fans; large
denominators give fans compressed below any fixed resolution. -/
theorem adjacent_ray_gap (p : ℤ) (q m n n' : ℕ) (hq : 0 < q) (hm : 0 < m)
    (hadj : charge p q m n - charge p q m n' = 1) :
    |(hpoint m n hm).re - (hpoint m n' hm).re| = (hpoint m n hm).im / q := by
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hQ : (0 : ℝ) < (q : ℝ) := by exact_mod_cast hq
  rw [same_height_separation p q m n n' hq hm, hpoint_im]
  have h1 : (charge p q m n : ℝ) - (charge p q m n' : ℝ) = 1 := by
    have := congrArg (fun z : ℤ => (z : ℝ)) hadj
    push_cast at this
    linarith
  rw [h1, abs_one]
  field_simp

/-- **The resolution criterion.** The star at `p/q` is resolved at height `y > 0` and
resolution `ε > 0` — meaning its adjacent rays are at least `ε` apart — exactly when
`q ≤ y/ε`. -/
theorem resolved_iff_denominator_le {y ε : ℝ} (hε : 0 < ε) {q : ℕ}
    (hq : 0 < q) : ε ≤ y / q ↔ (q : ℝ) ≤ y / ε := by
  have hQ : (0 : ℝ) < (q : ℝ) := by exact_mod_cast hq
  rw [le_div_iff₀ hQ, le_div_iff₀ hε]
  constructor <;> intro h <;> nlinarith

/-! ## Part 2. Counting the resolvable star centres: the Farey count -/

/-- The star centres in `(0, 1]` whose denominator is at most `Q`, as pairs `(p, q)` in
lowest terms with `1 ≤ p ≤ q ≤ Q`. -/
def fareyStars (Q : ℕ) : Finset (ℕ × ℕ) :=
  (Icc 1 Q).biUnion fun q => ((Icc 1 q).filter (fun p => Nat.Coprime q p)).image
    fun p => (p, q)

/-- Membership in the Farey star set. -/
theorem mem_fareyStars {Q : ℕ} {x : ℕ × ℕ} :
    x ∈ fareyStars Q ↔ 1 ≤ x.2 ∧ x.2 ≤ Q ∧ 1 ≤ x.1 ∧ x.1 ≤ x.2 ∧ Nat.Coprime x.2 x.1 := by
  simp only [fareyStars, Finset.mem_biUnion, Finset.mem_image, Finset.mem_filter,
    Finset.mem_Icc]
  constructor
  · rintro ⟨q, ⟨hq1, hqQ⟩, p, ⟨⟨hp1, hpq⟩, hcop⟩, rfl⟩
    exact ⟨hq1, hqQ, hp1, hpq, hcop⟩
  · rintro ⟨h1, h2, h3, h4, h5⟩
    exact ⟨x.2, ⟨h1, h2⟩, x.1, ⟨⟨h3, h4⟩, h5⟩, rfl⟩

/-- **The Farey count.** The number of star centres of denominator at most `Q` is
`∑_{q=1}^{Q} φ(q)`. -/
theorem card_fareyStars (Q : ℕ) :
    (fareyStars Q).card = ∑ q ∈ Icc 1 Q, Nat.totient q := by
  rw [fareyStars, Finset.card_biUnion]
  · refine Finset.sum_congr rfl ?_
    intro q hq
    rw [Finset.card_image_of_injective _ (fun a b hab => (Prod.mk.injEq _ _ _ _ ▸ hab).1)]
    have hIcc : Icc 1 q = Ico 1 (1 + q) := by
      ext x
      simp only [Finset.mem_Icc, Finset.mem_Ico]
      omega
    rw [hIcc]
    exact Nat.filter_coprime_Ico_eq_totient q 1
  · intro q _ q' _ hne
    refine Finset.disjoint_left.mpr ?_
    intro x hx hx'
    simp only [Finset.mem_image, Finset.mem_filter, Finset.mem_Icc] at hx hx'
    obtain ⟨p, _, rfl⟩ := hx
    obtain ⟨p', _, hp'⟩ := hx'
    exact hne (congrArg Prod.snd hp').symm

/-- **Visibility law.** At plot height `y` and resolution `ε`, the star centres whose
adjacent rays are separated by at least `ε` are exactly those of denominator at most
`y/ε`; there are `∑_{q ≤ Q} φ(q)` of them in `(0,1]`, where `Q = ⌊y/ε⌋`. In particular only
finitely many fans are ever visible, and they are the Farey fractions of low order — which
is why the eye picks out `1/2`, `1/3`, `1/5` and their neighbours. -/
theorem visible_star_centres {y ε : ℝ} (hε : 0 < ε) (Q : ℕ)
    (hQ : (Q : ℝ) ≤ y / ε) :
    (∀ x ∈ fareyStars Q, ε ≤ y / (x.2 : ℝ)) ∧
      (fareyStars Q).card = ∑ q ∈ Icc 1 Q, Nat.totient q := by
  refine ⟨?_, card_fareyStars Q⟩
  intro x hx
  obtain ⟨h1, h2, _, _, _⟩ := mem_fareyStars.mp hx
  have hq0 : 0 < x.2 := h1
  have hle : (x.2 : ℝ) ≤ (Q : ℝ) := by exact_mod_cast h2
  exact (resolved_iff_denominator_le hε hq0).mpr (le_trans hle hQ)

/-- The Farey set of level `5`, the stars resolved at height `1/2` with resolution `1/10`,
has `10` centres in `(0,1]`: `1/1, 1/2, 1/3, 2/3, 1/4, 3/4, 1/5, 2/5, 3/5, 4/5`. -/
theorem card_fareyStars_five : (fareyStars 5).card = 10 := by
  rw [card_fareyStars]
  decide

end BerggrenRationalStar