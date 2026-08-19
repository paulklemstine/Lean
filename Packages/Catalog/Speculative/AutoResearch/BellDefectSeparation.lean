import Combinatorics.BellDefectGradedSpectrum

/-!
# A single moment is strictly coarser than the fibre spectrum

`Catalog/Combinatorics/BellDefectGradedSpectrum.lean` shows that the *family* of moments
`Σ_g |X^g|^j`, `j ≤ k`, and the fibre spectrum `t_0, …, t_k` are equivalent invariants
(`moments_eq_iff_injOrbits_eq`).  This file completes the picture from the other side, by
exhibiting an explicit pair of actions of the *same* group order with

* equal second moments `Σ_g |X^g|^2`, but
* different fibre spectra (already at `t_1`, the number of point orbits).

So the fibre spectrum is strictly finer than any single moment, but not finer than the whole
moment sequence: the separating information is precisely the grading of the Stirling row.

The two actions are, for a group `G` of order `4`:

* the **regular** action of `G` on itself (`Σ_g |G^g|^2 = |G|^2 = 16`, `t_1 = 1`);
* the **trivial** action of `G` on a two-element set (`Σ_g |X^g|^2 = |G|·|X|^2 = 16`, `t_1 = 2`).

Auxiliary general results proved on the way:

* `injOrbits_one_mul_card` : `t_1·|G| = Σ_g |X^g|` — Burnside's lemma in spectral form.
* `sum_fixedPoints_pow_regular`, `injOrbits_one_regular` : the moments and the point-orbit count
  of a regular action.
* `sum_fixedPoints_pow_trivialSet`, `injOrbits_one_trivialSet` : the same for a trivial
  action.

There are no `sorry`s, no `native_decide`, and no new axioms.
-/

open Finset MulAction Function

namespace BellDefectGraded

open MoonshineBell MoonshineFibre FibreSpectrum

/-! ## Part 1: the first spectral value is Burnside's orbit count -/

section FirstMoment

variable (G : Type*) [Group G] [Fintype G] (X : Type*) [MulAction G X] [Finite X]

/-- **Burnside in spectral form.**  The first entry of the fibre spectrum is the number of point
orbits: `t_1·|G| = Σ_g |X^g|`. -/
theorem injOrbits_one_mul_card :
    injOrbits G X 1 * Nat.card G = ∑ g : G, Nat.card (fixedBy X g) := by
  have h := sum_fixedPoints_pow_eq_sum_stirling 1 G X
  simp only [pow_one] at h
  rw [h, Finset.sum_range_succ, Finset.sum_range_one, stirling_zero_right (le_refl 1),
    stirling_self 1]
  ring

/-- The first spectral value, computed from the first moment. -/
theorem injOrbits_one_eq_of_sum (m : ℕ) (h : ∑ g : G, Nat.card (fixedBy X g) = m * Nat.card G) :
    injOrbits G X 1 = m := by
  have hpos : 0 < Nat.card G := Nat.card_pos
  have := injOrbits_one_mul_card G X
  rw [h] at this
  exact Nat.eq_of_mul_eq_mul_right hpos this

end FirstMoment

/-! ## Part 2: the regular action -/

section Regular

variable (G : Type*) [Group G] [Fintype G]

omit [Fintype G] in
theorem card_fixedBy_regular_one : Nat.card (fixedBy G (1 : G)) = Nat.card G := by
  have h : (fixedBy G (1 : G)) = (Set.univ : Set G) := by ext x; simp
  rw [h, Nat.card_univ]

omit [Fintype G] in
theorem card_fixedBy_regular_of_ne {g : G} (hg : g ≠ 1) : Nat.card (fixedBy G g) = 0 := by
  have h : (fixedBy G g) = (∅ : Set G) := by
    ext x
    simp only [mem_fixedBy, Set.mem_empty_iff_false, iff_false]
    intro hx
    exact hg (by simpa using mul_right_cancel (b := x) (by simpa using hx))
  rw [h]
  simp

/-- All moments of the regular action: only the identity has fixed points. -/
theorem sum_fixedPoints_pow_regular {k : ℕ} (hk : 1 ≤ k) :
    ∑ g : G, Nat.card (fixedBy G g) ^ k = Nat.card G ^ k := by
  classical
  rw [Finset.sum_eq_single_of_mem (1 : G) (Finset.mem_univ _)
    (fun b _ hb => by rw [card_fixedBy_regular_of_ne G hb, Nat.zero_pow (by omega : 0 < k)]),
    card_fixedBy_regular_one]

/-- The regular action is transitive: its point-orbit count is `1`. -/
theorem injOrbits_one_regular : injOrbits G G 1 = 1 := by
  refine injOrbits_one_eq_of_sum G G 1 ?_
  rw [one_mul]
  have := sum_fixedPoints_pow_regular G (k := 1) (le_refl 1)
  simpa using this

end Regular

/-! ## Part 3: the trivial action -/

section Trivial

/-- The set `X` regarded as a `G`-set with the trivial action, for every group `G`. -/
def TrivialSet (X : Type*) : Type _ := X

instance (G X : Type*) [Group G] : MulAction G (TrivialSet X) where
  smul _ x := x
  one_smul _ := rfl
  mul_smul _ _ _ := rfl

instance (X : Type*) [Finite X] : Finite (TrivialSet X) := inferInstanceAs (Finite X)

variable (G : Type*) [Group G] [Fintype G] (X : Type*)

omit [Fintype G] in
theorem card_fixedBy_trivialSet (g : G) :
    Nat.card (fixedBy (TrivialSet X) g) = Nat.card X := by
  have : (fixedBy (TrivialSet X) g) = (Set.univ : Set (TrivialSet X)) := by
    ext x; simp [mem_fixedBy]; rfl
  rw [this, Nat.card_univ]
  rfl

/-- All moments of a trivial action: every group element fixes everything. -/
theorem sum_fixedPoints_pow_trivialSet (k : ℕ) :
    ∑ g : G, Nat.card (fixedBy (TrivialSet X) g) ^ k = Nat.card G * Nat.card X ^ k := by
  rw [Finset.sum_congr rfl (fun g _ => by rw [card_fixedBy_trivialSet G X g]),
    Finset.sum_const, Finset.card_univ, smul_eq_mul]
  congr 1
  exact (Nat.card_eq_fintype_card).symm

variable [Finite X]

/-- The point orbits of a trivial action are the points. -/
theorem injOrbits_one_trivialSet : injOrbits G (TrivialSet X) 1 = Nat.card X := by
  refine injOrbits_one_eq_of_sum G (TrivialSet X) (Nat.card X) ?_
  have := sum_fixedPoints_pow_trivialSet G X 1
  simpa [mul_comm] using this

end Trivial

/-! ## Part 4: the separating pair -/

section Separation

/-- The cyclic group of order `4` used for the separating example. -/
abbrev C4 : Type := Multiplicative (ZMod 4)

theorem card_C4 : Nat.card C4 = 4 := by
  rw [Nat.card_eq_fintype_card]
  rfl

/-- **The second moment does not see the spectrum.**  Two actions of the same group of order `4`
— the regular action on `4` points and the trivial action on `2` points — have the same second
moment `16`, yet different fibre spectra: the numbers of point orbits are `1` and `2`.  Together
with `moments_eq_iff_injOrbits_eq` this pins down exactly how much a single moment forgets. -/
theorem single_moment_not_separating :
    (∑ g : C4, Nat.card (fixedBy C4 g) ^ 2)
        = ∑ g : C4, Nat.card (fixedBy (TrivialSet (Fin 2)) g) ^ 2
      ∧ injOrbits C4 C4 1 ≠ injOrbits C4 (TrivialSet (Fin 2)) 1 := by
  constructor
  · rw [sum_fixedPoints_pow_regular C4 (k := 2) (by omega),
      sum_fixedPoints_pow_trivialSet C4 (Fin 2) 2, card_C4]
    simp
  · rw [injOrbits_one_regular C4, injOrbits_one_trivialSet C4 (Fin 2)]
    simp

/-- The two actions of the separating pair are distinguished by their *first* moments, as the
moment–spectrum equivalence predicts: the spectra differ at `t_1`, hence so does the moment at
`j = 1`. -/
theorem separating_pair_first_moments_differ :
    (∑ g : C4, Nat.card (fixedBy C4 g))
      ≠ ∑ g : C4, Nat.card (fixedBy (TrivialSet (Fin 2)) g) := by
  have h1 : ∑ g : C4, Nat.card (fixedBy C4 g) = 4 := by
    have := sum_fixedPoints_pow_regular C4 (k := 1) (le_refl 1)
    simpa [card_C4] using this
  have h2 : ∑ g : C4, Nat.card (fixedBy (TrivialSet (Fin 2)) g) = 8 := by
    have := sum_fixedPoints_pow_trivialSet C4 (Fin 2) 1
    simpa [card_C4] using this
  rw [h1, h2]
  omega

end Separation

end BellDefectGraded