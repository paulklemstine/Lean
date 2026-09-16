import Cryptography.NonabelianTypeChannel.GroupChannel

/-!
# Splitting types, Galois groups of small degree, and the arithmetic of `log₂`

This file supplies the concrete input for the type-channel law:

* the **splitting type readout** `splitType g` of a permutation of the roots, and the
  proof that it is a class function (`splitType_conj`) — this is what makes it the
  well-defined "factorisation shape of `p`" attached to the Frobenius *class*;
* the six Galois groups of the experiment, realised as explicit `Finset`s of
  permutations of the roots, with machine-checked certificates that each is a
  subgroup and that the stated `N` really is its derived subgroup
  (`IsDerivedFinset`), together with explicit numeric coset readouts;
* the small `log₂` arithmetic used to evaluate entropies in closed form.

## The type readout

For a squarefree `f` of degree `n ≤ 4` and an unramified `p`, the factorisation shape
of `f mod p` is the cycle type of Frobenius acting on the roots.  For `n ≤ 4` a cycle
type is determined by the pair

  `splitType g = (#fixed points of g, #points on 2-cycles of g)`,

namely `[1,1,1,1] ↦ (4,0)`, `[2,1,1] ↦ (2,2)`, `[2,2] ↦ (0,4)`, `[3,1] ↦ (1,0)`,
`[4] ↦ (0,0)` in degree 4, and `[1,1,1] ↦ (3,0)`, `[2,1] ↦ (1,2)`, `[3] ↦ (0,0)` in
degree 3.  Working with this pair keeps every count decidable.

## The fields

| field | `G` | `N = [G,G]` | `G/N` |
|---|---|---|---|
| `x³ + x + 1` | `S₃` = `S3` | `A₃` = `A3` | `C₂` |
| `x⁴ - x - 1` | `S₄` = `S4` | `A₄` = `A4` | `C₂` |
| `x⁴ + 8x + 12` | `A₄` = `A4` | `V₄` = `V4` | `C₃` |
| `x⁴ - 2` | `D₄` = `D4` | `Z = {1, (02)(13)}` = `Z4c` | `C₂ × C₂` |
| `x⁴ - 2x² + 9` | `V₄` = `V4` | `1` | `V₄` |
| `Φ₅` | `C₄` = `C4` | `1` | `C₄` |

`D4` is realised as the stabiliser of the pairing `{{0,2},{1,3}}` of the roots
`α, iα, -α, -iα` of `x⁴ - 2`, which is exactly the Galois group of that field.
-/

namespace TypeChannel

open Finset Real Equiv

set_option maxRecDepth 4000000

/-! ### The splitting-type readout -/

/-- The splitting type of a permutation of `n` roots, recorded as the pair
(number of fixed points, number of points lying on 2-cycles).  For `n ≤ 4` this is a
faithful encoding of the cycle type, i.e. of the factorisation shape of the prime. -/
def splitType {n : ℕ} (g : Equiv.Perm (Fin n)) : ℕ × ℕ :=
  ((univ.filter (fun x : Fin n => g x = x)).card,
   (univ.filter (fun x : Fin n => g x ≠ x ∧ g (g x) = x)).card)

/-- **The type readout is a class function.**  Conjugate permutations have the same
splitting type; this is what makes "the splitting type of `p`" depend only on the
Frobenius *conjugacy class*, as Chebotarev's theorem requires. -/
theorem splitType_conj {n : ℕ} (g h : Equiv.Perm (Fin n)) :
    splitType (h * g * h⁻¹) = splitType g := by
  unfold splitType
  have h1 : (univ.filter fun x : Fin n => (h * g * h⁻¹) x = x).card
      = (univ.filter fun x : Fin n => g x = x).card := by
    apply Finset.card_nbij' (fun x => h⁻¹ x) (fun x => h x) <;>
      intro x hx <;> simp_all [Equiv.Perm.mul_apply, Equiv.eq_symm_apply]
  have h2 : (univ.filter fun x : Fin n =>
        (h * g * h⁻¹) x ≠ x ∧ (h * g * h⁻¹) ((h * g * h⁻¹) x) = x).card
      = (univ.filter fun x : Fin n => g x ≠ x ∧ g (g x) = x).card := by
    apply Finset.card_nbij' (fun x => h⁻¹ x) (fun x => h x) <;>
      intro x hx <;> simp_all [Equiv.Perm.mul_apply, Equiv.eq_symm_apply]
  rw [h1, h2]

/-! ### The six Galois groups -/

/-- The parity readout, `0` for even and `1` for odd permutations: the coset readout of
the derived subgroup for `S₃` and `S₄`. -/
def signIdx {n : ℕ} (g : Equiv.Perm (Fin n)) : ℕ :=
  if Equiv.Perm.sign g = 1 then 0 else 1

/-- `S₃`, the Galois group of `x³ + x + 1` (and of `x³ - x + 1`). -/
def S3 : Finset (Equiv.Perm (Fin 3)) := univ

/-- `A₃`, the derived subgroup of `S₃`. -/
def A3 : Finset (Equiv.Perm (Fin 3)) := univ.filter (fun g => Equiv.Perm.sign g = 1)

/-- `S₄`, the Galois group of `x⁴ - x - 1`. -/
def S4 : Finset (Equiv.Perm (Fin 4)) := univ

/-- `A₄`, the derived subgroup of `S₄`; also the Galois group of `x⁴ + 8x + 12`. -/
def A4 : Finset (Equiv.Perm (Fin 4)) := univ.filter (fun g => Equiv.Perm.sign g = 1)

/-- `V₄`, the Klein four-group of double transpositions: the derived subgroup of `A₄`
and the Galois group of `x⁴ - 2x² + 9`. -/
def V4 : Finset (Equiv.Perm (Fin 4)) :=
  univ.filter (fun g => splitType g = (4,0) ∨ splitType g = (0,4))

/-- `D₄`, the Galois group of `x⁴ - 2`: the stabiliser of the pairing
`{{0,2},{1,3}}` of the roots `α, iα, -α, -iα`. -/
def D4 : Finset (Equiv.Perm (Fin 4)) :=
  univ.filter (fun g => ({g 0, g 2} : Finset (Fin 4)) = {0,2} ∨
    ({g 0, g 2} : Finset (Fin 4)) = {1,3})

/-- The centre of `D₄`, which is its derived subgroup. -/
def Z4c : Finset (Equiv.Perm (Fin 4)) :=
  univ.filter (fun g => g = 1 ∨ (g 0 = 2 ∧ g 1 = 3 ∧ g 2 = 0 ∧ g 3 = 1))

/-- `C₄`, the Galois group of `Φ₅`, acting regularly on the four roots. -/
def C4 : Finset (Equiv.Perm (Fin 4)) :=
  univ.filter (fun g => g 1 = (g 0 + 1 : Fin 4) ∧ g 2 = (g 0 + 2 : Fin 4) ∧
    g 3 = (g 0 + 3 : Fin 4))

/-- The trivial subgroup. -/
def One4 : Finset (Equiv.Perm (Fin 4)) := {1}

/-- The `C₃`-coset readout for `A₄ / V₄`: which of the three pairings of the four
roots the pair `{g 0, g 1}` belongs to. -/
def pairIdx (g : Equiv.Perm (Fin 4)) : ℕ :=
  if ({g 0, g 1} : Finset (Fin 4)) = {0,1} ∨ ({g 0, g 1} : Finset (Fin 4)) = {2,3} then 0
  else if ({g 0, g 1} : Finset (Fin 4)) = {0,2} ∨ ({g 0, g 1} : Finset (Fin 4)) = {1,3} then 1
  else 2

/-- The `C₂ × C₂`-coset readout for `D₄` modulo its centre: parity together with
whether the diagonal `{0,2}` is preserved. -/
def d4Idx (g : Equiv.Perm (Fin 4)) : ℕ :=
  signIdx g + 2 * (if ({g 0, g 2} : Finset (Fin 4)) = {0,2} then 0 else 1)

/-- For a group acting regularly (`V₄`, `C₄`) the image of a single root already
separates the group elements, so it is the coset readout of the trivial subgroup. -/
def rootIdx (g : Equiv.Perm (Fin 4)) : ℕ := (g 0 : ℕ)

/-! ### Subgroup and derived-subgroup certificates (machine checked) -/

lemma S3_isSubgroup : IsSubgroupFinset S3 := ⟨by decide, by decide, by decide⟩
lemma A3_isSubgroup : IsSubgroupFinset A3 := ⟨by decide, by decide, by decide⟩
lemma S4_isSubgroup : IsSubgroupFinset S4 := ⟨by decide, by decide, by decide⟩
lemma A4_isSubgroup : IsSubgroupFinset A4 := ⟨by decide, by decide, by decide⟩
lemma V4_isSubgroup : IsSubgroupFinset V4 := ⟨by decide, by decide, by decide⟩
lemma D4_isSubgroup : IsSubgroupFinset D4 := ⟨by decide, by decide, by decide⟩
lemma Z4c_isSubgroup : IsSubgroupFinset Z4c := ⟨by decide, by decide, by decide⟩
lemma C4_isSubgroup : IsSubgroupFinset C4 := ⟨by decide, by decide, by decide⟩
lemma One4_isSubgroup : IsSubgroupFinset One4 := ⟨by decide, by decide, by decide⟩

lemma S3_derived : IsDerivedFinset S3 A3 := ⟨by decide, by decide, by decide⟩
lemma S4_derived : IsDerivedFinset S4 A4 := ⟨by decide, by decide, by decide⟩
lemma A4_derived : IsDerivedFinset A4 V4 := ⟨by decide, by decide, by decide⟩
lemma D4_derived : IsDerivedFinset D4 Z4c := ⟨by decide, by decide, by decide⟩
lemma V4_derived : IsDerivedFinset V4 One4 := ⟨by decide, by decide, by decide⟩
lemma C4_derived : IsDerivedFinset C4 One4 := ⟨by decide, by decide, by decide⟩

lemma S3_coset : IsCosetReadout S3 A3 signIdx := by
  unfold IsCosetReadout; decide
lemma S4_coset : IsCosetReadout S4 A4 signIdx := by
  unfold IsCosetReadout; decide
lemma A4_coset : IsCosetReadout A4 V4 pairIdx := by
  unfold IsCosetReadout; decide
lemma D4_coset : IsCosetReadout D4 Z4c d4Idx := by
  unfold IsCosetReadout; decide
lemma V4_coset : IsCosetReadout V4 One4 rootIdx := by
  unfold IsCosetReadout; decide
lemma C4_coset : IsCosetReadout C4 One4 rootIdx := by
  unfold IsCosetReadout; decide

/-! ### `log₂` arithmetic -/

lemma logb2_two : logb 2 (2:ℝ) = 1 := Real.logb_self_eq_one (by norm_num)

lemma logb2_four : logb 2 (4:ℝ) = 2 := by
  rw [show (4:ℝ) = 2^(2:ℕ) by norm_num, Real.logb_pow]; simp

lemma logb2_eight : logb 2 (8:ℝ) = 3 := by
  rw [show (8:ℝ) = 2^(3:ℕ) by norm_num, Real.logb_pow]; simp

lemma logb2_six : logb 2 (6:ℝ) = 1 + logb 2 3 := by
  rw [show (6:ℝ) = 2 * 3 by norm_num, Real.logb_mul (by norm_num) (by norm_num), logb2_two]

lemma logb2_twelve : logb 2 (12:ℝ) = 2 + logb 2 3 := by
  rw [show (12:ℝ) = 4 * 3 by norm_num, Real.logb_mul (by norm_num) (by norm_num), logb2_four]

lemma logb2_twentyfour : logb 2 (24:ℝ) = 3 + logb 2 3 := by
  rw [show (24:ℝ) = 8 * 3 by norm_num, Real.logb_mul (by norm_num) (by norm_num), logb2_eight]

/-- `0 < logb 2 3 < 2`: the only analytic input needed to compare the channels. -/
lemma logb2_three_pos : 0 < logb 2 3 := Real.logb_pos (by norm_num) (by norm_num)

lemma logb2_three_lt_two : logb 2 3 < 2 := by
  have h := Real.logb_lt_logb (b := 2) (x := 3) (y := 4) (by norm_num) (by norm_num)
    (by norm_num)
  linarith [logb2_four]

lemma logb2_three_gt_one : 1 < logb 2 3 := by
  have h := Real.logb_lt_logb (b := 2) (x := 2) (y := 3) (by norm_num) (by norm_num)
    (by norm_num)
  linarith [logb2_two]

/-- The single-cell entropy identity used to evaluate all the tables. -/
lemma neg_prob_logb (a n : ℕ) (ha : 0 < a) (hn : 0 < n) :
    -(((a:ℝ)/n) * logb 2 ((a:ℝ)/n)) = ((a:ℝ)/n) * (logb 2 n - logb 2 a) := by
  have ha' : (0:ℝ) < a := by exact_mod_cast ha
  have hn' : (0:ℝ) < n := by exact_mod_cast hn
  rw [Real.logb_div (ne_of_gt ha') (ne_of_gt hn')]
  ring

end TypeChannel