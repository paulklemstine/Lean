import MachineLearning.CayleyCensusMoments

/-!
# Worked censuses on the dihedral group `D₃`, and the sharpness of the hypotheses

The general theory proved in `MachineLearning.CayleyCensusInvariance` and
`MachineLearning.CayleyCensusMoments` is exercised here on `DihedralGroup 3`
(the symmetric group on three letters) with three different connection sets.
The point of the file is twofold: to *instantiate* the abstract invariance
statements on explicit data, and to *delimit* them by finite counterexamples.

Census tables (rows indexed by `n`, columns by `r 0, r 1, r 2, sr 0, sr 1, sr 2`):

* `rotSet = {r 1, r 2}` (a full conjugacy class):
  `n = 0..5` gives
  `[1,0,0,0,0,0]`, `[0,1,1,0,0,0]`, `[2,1,1,0,0,0]`, `[2,3,3,0,0,0]`,
  `[6,5,5,0,0,0]`, `[10,11,11,0,0,0]`.
* `reflSet = {sr 0, sr 1, sr 2}` (the reflection class):
  `[1,0,0,0,0,0]`, `[0,0,0,1,1,1]`, `[3,3,3,0,0,0]`, `[0,0,0,9,9,9]`, …
* `mixSet = {r 1, r 2, sr 0}` (inversion closed, *not* conjugation closed):
  `[1,0,0,0,0,0]`, `[0,1,1,1,0,0]`, `[3,1,1,0,2,2]`, `[2,6,6,7,3,3]`,
  `[19,11,11,8,16,16]`, `[30,46,46,51,35,35]`.
  Exactly four distinct rows appear, matching the four orbits
  `{r 0}, {r 1, r 2}, {sr 0}, {sr 1, sr 2}` of `⟨inversion, Aut(G, S)⟩`.

## Main results

* `mix_census_r1_eq_r2`, `mix_census_sr1_eq_sr2` — orbit degeneracies predicted
  by the general theorems.
* `mix_card_census_le_four` — the quantitative orbit bound realised.
* `refl_isClassFunction` — a normal Cayley graph gives an honest class function.
* `walkCount_inv_fails_without_invClosed` — the inversion hypothesis is *not*
  removable: for `S = {r 1}` one has `walkCount S 1 (r 1) ≠ walkCount S 1 (r 1)⁻¹`.
* `return_dominance_fails_for_odd_length` — the evenness hypothesis in
  `walkCount_two_mul_le_walkCount_two_mul_one` is *not* removable: at length `3`
  the rotation census is strictly larger at `r 1` than at the identity.
-/

namespace CayleyCensus

open DihedralGroup

/-- The dihedral group of order `6`, i.e. the symmetric group on three points. -/
abbrev D3 := DihedralGroup 3

/-- The rotation class `{r, r²}`: a full conjugacy class of `D₃`. -/
def rotSet : Finset D3 := {r 1, r 2}

/-- The reflection class `{s, sr, sr²}`: the other nontrivial conjugacy class. -/
def reflSet : Finset D3 := {sr 0, sr 1, sr 2}

/-- An inversion-closed but *not* conjugation-closed connection set. -/
def mixSet : Finset D3 := {r 1, r 2, sr 0}

/-- A connection set that is not even inversion closed. -/
def dirSet : Finset D3 := {r 1}

theorem rotSet_invClosed : InvClosed rotSet := by decide

theorem reflSet_invClosed : InvClosed reflSet := by decide

theorem mixSet_invClosed : InvClosed mixSet := by decide

theorem dirSet_not_invClosed : ¬ InvClosed dirSet := by decide

/-! ### A normal Cayley graph: the census is a class function -/

theorem reflSet_conjClosed :
    ∀ (a : D3) ⦃s : D3⦄, s ∈ reflSet → a * s * a⁻¹ ∈ reflSet := by
  intro a s hs
  fin_cases hs <;> revert a <;> decide

/-- Since `reflSet` is a union of conjugacy classes, the census of the
corresponding (bipartite) Cayley graph is a genuine class function. -/
theorem refl_isClassFunction (n : ℕ) (a g : D3) :
    walkCount reflSet n (a * g * a⁻¹) = walkCount reflSet n g :=
  walkCount_conj reflSet_conjClosed n a g

/-! ### An inversion-closed, non-normal connection set -/

/-- Conjugation by the reflection `sr 0` is an automorphism preserving `mixSet`
(it swaps the two rotations and fixes `sr 0`), even though `mixSet` is not a
union of conjugacy classes. -/
theorem mixSet_preserves_conj_sr0 : Preserves (MulAut.conj (sr 0 : D3)) mixSet := by
  decide

/-- The two rotations have identical censuses — here because they are swapped by
inversion. -/
theorem mix_census_r1_eq_r2 (n : ℕ) :
    walkCount mixSet n (r 1 : D3) = walkCount mixSet n (r 2 : D3) := by
  have hinv : (r 2 : D3)⁻¹ = r 1 := by decide
  rw [← hinv, walkCount_inv mixSet_invClosed]

/-- The two reflections outside the connection set have identical censuses —
here because they are swapped by an `S`-preserving automorphism, *not* by
inversion (they are involutions). -/
theorem mix_census_sr1_eq_sr2 (n : ℕ) :
    walkCount mixSet n (sr 1 : D3) = walkCount mixSet n (sr 2 : D3) := by
  have hmap : (MulAut.conj (sr 0 : D3)) (sr 2 : D3) = sr 1 := by decide
  rw [← hmap, walkCount_mulAut mixSet_preserves_conj_sr0]

/-- Every element of `D₃` is census-equivalent, for `mixSet`, to one of the four
representatives `r 0, r 1, sr 0, sr 1`. -/
theorem mixSet_representatives (g : D3) :
    ∃ t ∈ ({r 0, r 1, sr 0, sr 1} : Finset D3), CensusEquiv mixSet g t := by
  have hσ := mixSet_preserves_conj_sr0
  match g with
  | r 0 => exact ⟨r 0, by decide, CensusEquiv.refl _⟩
  | r 1 => exact ⟨r 1, by decide, CensusEquiv.refl _⟩
  | r 2 =>
      refine ⟨r 1, by decide, ?_⟩
      have hstep : CensusEquiv mixSet (r 2 : D3) ((r 2 : D3)⁻¹) :=
        (CensusEquiv.refl _).inv
      have hval : (r 2 : D3)⁻¹ = r 1 := by decide
      rwa [hval] at hstep
  | sr 0 => exact ⟨sr 0, by decide, CensusEquiv.refl _⟩
  | sr 1 => exact ⟨sr 1, by decide, CensusEquiv.refl _⟩
  | sr 2 =>
      refine ⟨sr 1, by decide, ?_⟩
      have hstep : CensusEquiv mixSet (sr 2 : D3)
          ((MulAut.conj (sr 0 : D3)) (sr 2 : D3)) :=
        (CensusEquiv.refl _).aut _ hσ
      have hval : (MulAut.conj (sr 0 : D3)) (sr 2 : D3) = sr 1 := by decide
      rwa [hval] at hstep

open scoped Classical in
/-- **The orbit bound, realised.**  The census table of `(D₃, mixSet)` has at
most four distinct rows; the explicit table above shows that four is attained,
so the bound coming from `⟨inversion, Aut(G,S)⟩` is sharp here. -/
theorem mix_card_census_le_four :
    (Finset.univ.image (census mixSet)).card ≤ 4 := by
  have hcard : ({r 0, r 1, sr 0, sr 1} : Finset D3).card = 4 := by decide
  have h := card_census_image_le mixSet_invClosed ({r 0, r 1, sr 0, sr 1} : Finset D3)
    mixSet_representatives
  rwa [hcard] at h

/-! ### Sharpness of the hypotheses -/

/-- **The inversion hypothesis cannot be dropped.**  For the directed connection
set `{r 1}` the census separates `r 1` from its inverse already at length `1`. -/
theorem walkCount_inv_fails_without_invClosed :
    walkCount dirSet 1 ((r 1 : D3)⁻¹) ≠ walkCount dirSet 1 (r 1 : D3) := by decide

/-- **The evenness hypothesis in return dominance cannot be dropped.**  At odd
length `3` the rotation census of `D₃` is strictly larger at `r 1` than at the
identity, even though `rotSet` is inversion closed. -/
theorem return_dominance_fails_for_odd_length :
    walkCount rotSet 3 (1 : D3) < walkCount rotSet 3 (r 1 : D3) := by decide

/-- Return dominance itself, verified on the same data at length `4`. -/
theorem rot_return_dominance_four (g : D3) :
    walkCount rotSet 4 g ≤ walkCount rotSet 4 (1 : D3) := by
  have h := walkCount_two_mul_le_walkCount_two_mul_one rotSet_invClosed 2 g
  simpa using h

end CayleyCensus