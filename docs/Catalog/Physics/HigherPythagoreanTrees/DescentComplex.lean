import Mathlib
import Catalog.Shared.Ispythquadruple.IsPythQuadruple
import Catalog.Shared.HigherPythagorean.BranchingContrast

/-!
# The descent complex of a Pythagorean `n`-tuple

The catalog develops the Berggren tree (`n = 2`) and its quadruple analogue (`n = 3`)
through *reflection moves* of the integral Lorentz group of `x₁² + … + xₙ² = y²`:
for a sign pattern `ε ∈ {±1}ⁿ` the move sends the height `y` to `2y − ε·x`, so it
*descends* exactly when `ε · x > y`.

A sign pattern is the same thing as the set `S ⊆ {1,…,n}` of its minus signs, so the
collection of descending patterns at a node is a family of subsets: the **descent complex**
of the node.  This file develops that complex for *arbitrary* `n`; it is the structure
governing how many parents a node of the `n`-dimensional Pythagorean graph has.

Main results.

* `signedSum_eq_total_sub` : the sign-pattern sum is `∑ xᵢ − 2 ∑_{i∈S} xᵢ`.
* `DescendsOn.mono` : the descent complex is **downward closed** (an abstract simplicial
  complex on the coordinate set).
* `DescendsOn.two_le_card_compl` : every face `S` satisfies `#Sᶜ ≥ 2`, i.e. `#S ≤ n − 2`.
  This dimension bound is forced by the Pythagorean relation.
* `DescendsOn.two_le_card_compl_union` : the same bound holds for the union of two
  **disjoint** faces — a genuine strengthening.
* `descent_singleton_unique_of_three` : for `n = 3` at most one singleton is a face, which
  re-derives the catalog's `descend_minus_index_unique` from the general theory.
* Bridges `isPythTuple_iff_isPythQuadruple`, `descendsOn_empty_iff_catalog`,
  `descendsOn_singleton_iff_catalog` identify the `n = 3` instance with the catalog's
  `IsPythQuadruple` / `HigherPythagorean.Descends`.
-/

namespace HigherPythagoreanDescent

open Finset

variable {n : ℕ}

/-- A Pythagorean `n`-tuple: an integral point `x` of the null cone with height `d`. -/
def IsPythTuple (x : Fin n → ℤ) (d : ℤ) : Prop := ∑ i, x i ^ 2 = d ^ 2

/-- The signed coordinate sum `ε · x`, where the sign pattern `ε` is `-1` exactly on `S`. -/
def signedSum (S : Finset (Fin n)) (x : Fin n → ℤ) : ℤ := ∑ i, (if i ∈ S then -x i else x i)

/-- The sign pattern with minus signs on `S` *descends* at the node `(x, d)` when the
reflection move `d ↦ 2d − ε·x` strictly lowers the height. -/
def DescendsOn (S : Finset (Fin n)) (x : Fin n → ℤ) (d : ℤ) : Prop := d < signedSum S x

lemma descendsOn_iff_height_lt (S : Finset (Fin n)) (x : Fin n → ℤ) (d : ℤ) :
    DescendsOn S x d ↔ 2 * d - signedSum S x < d := by
  unfold DescendsOn; constructor <;> intro h <;> linarith

/-- `ε · x = ∑ xᵢ − 2 ∑_{i ∈ S} xᵢ`. -/
lemma signedSum_eq_total_sub (S : Finset (Fin n)) (x : Fin n → ℤ) :
    signedSum S x = (∑ i, x i) - 2 * ∑ i ∈ S, x i := by
  have hpt : ∀ i : Fin n, (if i ∈ S then -x i else x i)
      = x i - (if i ∈ S then 2 * x i else 0) := by
    intro i
    by_cases h : i ∈ S <;> simp [h, two_mul]
  calc signedSum S x = ∑ i, (x i - (if i ∈ S then 2 * x i else 0)) := by
        unfold signedSum; exact Finset.sum_congr rfl fun i _ => hpt i
    _ = (∑ i, x i) - ∑ i, (if i ∈ S then 2 * x i else 0) := by
        rw [Finset.sum_sub_distrib]
    _ = (∑ i, x i) - 2 * ∑ i ∈ S, x i := by
        rw [Finset.sum_ite_mem, Finset.univ_inter, Finset.mul_sum]

/-- The empty sign pattern is the all-plus move. -/
lemma signedSum_empty (x : Fin n → ℤ) : signedSum (∅ : Finset (Fin n)) x = ∑ i, x i := by
  simp [signedSum]

/-! ## The dimension bound: a face has at least two coordinates outside it -/

/-- Each coordinate of a Pythagorean tuple is bounded by the height. -/
lemma coord_le_height {x : Fin n → ℤ} {d : ℤ} (hd : 0 ≤ d)
    (h : IsPythTuple x d) (j : Fin n) : x j ≤ d := by
  have hsq : x j ^ 2 ≤ d ^ 2 := by
    rw [← h]
    exact Finset.single_le_sum (f := fun i => x i ^ 2) (fun i _ => sq_nonneg (x i))
      (Finset.mem_univ j)
  nlinarith

/-- A set of coordinates whose sum exceeds the height must contain at least two indices.
This is the engine of the whole dimension bound. -/
lemma two_le_card_of_sum_gt {x : Fin n → ℤ} {d : ℤ} (hd : 0 ≤ d)
    (h : IsPythTuple x d) {T : Finset (Fin n)} (hT : d < ∑ i ∈ T, x i) : 2 ≤ T.card := by
  by_contra hcard
  push_neg at hcard
  interval_cases hc : T.card
  · rw [Finset.card_eq_zero] at hc
    subst hc
    simp at hT
    omega
  · obtain ⟨j, rfl⟩ := Finset.card_eq_one.mp hc
    rw [Finset.sum_singleton] at hT
    exact absurd (coord_le_height hd h j) (by omega)

/-- **Dimension bound.**  Every face of the descent complex has at least two coordinates in
its complement: `#S ≤ n − 2`.  In particular a descending sign pattern always has at least
two plus signs. -/
theorem DescendsOn.two_le_card_compl {x : Fin n → ℤ} {d : ℤ} (hx : ∀ i, 0 ≤ x i) (hd : 0 ≤ d)
    (h : IsPythTuple x d) {S : Finset (Fin n)} (hS : DescendsOn S x d) : 2 ≤ Sᶜ.card := by
  refine two_le_card_of_sum_gt hd h (T := Sᶜ) ?_
  have hsum : ∑ i ∈ S, x i + ∑ i ∈ Sᶜ, x i = ∑ i, x i := Finset.sum_add_sum_compl S x
  have hnn : 0 ≤ ∑ i ∈ S, x i := Finset.sum_nonneg fun i _ => hx i
  have := hS
  rw [DescendsOn, signedSum_eq_total_sub] at this
  linarith

/-- The cardinality form of the dimension bound. -/
theorem DescendsOn.card_le {x : Fin n → ℤ} {d : ℤ} (hx : ∀ i, 0 ≤ x i) (hd : 0 ≤ d)
    (h : IsPythTuple x d) {S : Finset (Fin n)} (hS : DescendsOn S x d) : S.card + 2 ≤ n := by
  have hc := hS.two_le_card_compl hx hd h
  have : S.card + Sᶜ.card = n := by
    rw [Finset.card_add_card_compl]
    simp
  omega

/-- **The descent complex is downward closed**: if a sign pattern with minus signs on `T`
descends, so does every pattern with fewer minus signs. -/
theorem DescendsOn.mono {x : Fin n → ℤ} {d : ℤ} (hx : ∀ i, 0 ≤ x i) {S T : Finset (Fin n)}
    (hST : S ⊆ T) (hT : DescendsOn T x d) : DescendsOn S x d := by
  rw [DescendsOn, signedSum_eq_total_sub] at hT ⊢
  have : ∑ i ∈ S, x i ≤ ∑ i ∈ T, x i :=
    Finset.sum_le_sum_of_subset_of_nonneg hST fun i _ _ => hx i
  linarith

/-- **Disjoint faces still obey the dimension bound on their union.**  If two disjoint sign
patterns both descend then their union already has two coordinates outside it. -/
theorem DescendsOn.two_le_card_compl_union {x : Fin n → ℤ} {d : ℤ} (hd : 0 ≤ d) (h : IsPythTuple x d) {S T : Finset (Fin n)} (hdisj : Disjoint S T)
    (hS : DescendsOn S x d) (hT : DescendsOn T x d) : 2 ≤ (S ∪ T)ᶜ.card := by
  refine two_le_card_of_sum_gt hd h (T := (S ∪ T)ᶜ) ?_
  rw [DescendsOn, signedSum_eq_total_sub] at hS hT
  have hunion : ∑ i ∈ S ∪ T, x i = ∑ i ∈ S, x i + ∑ i ∈ T, x i :=
    Finset.sum_union hdisj
  have hsplit : ∑ i ∈ S ∪ T, x i + ∑ i ∈ (S ∪ T)ᶜ, x i = ∑ i, x i :=
    Finset.sum_add_sum_compl (S ∪ T) x
  linarith

/-! ## Dimension three: at most one singleton face -/

/-- **Uniqueness of the one-minus descent in dimension three.**  For a Pythagorean triple of
space coordinates (i.e. a Pythagorean quadruple) at most one single sign flip descends. -/
theorem descent_singleton_unique_of_three {x : Fin 3 → ℤ} {d : ℤ} (hd : 0 ≤ d) (h : IsPythTuple x d) {i j : Fin 3}
    (hi : DescendsOn {i} x d) (hj : DescendsOn {j} x d) : i = j := by
  by_contra hij
  have hdisj : Disjoint ({i} : Finset (Fin 3)) {j} := by
    simp [hij]
  have hcard := DescendsOn.two_le_card_compl_union hd h hdisj hi hj
  have hu : ({i} ∪ {j} : Finset (Fin 3)).card = 2 := by
    rw [Finset.card_union_of_disjoint hdisj]
    simp
  have hsum : ({i} ∪ {j} : Finset (Fin 3)).card + (({i} ∪ {j} : Finset (Fin 3))ᶜ).card = 3 := by
    rw [Finset.card_add_card_compl]
    simp
  omega

/-! ## Bridge to the catalog's quadruple machinery (`n = 3`) -/

/-- The `n = 3` null cone is exactly the catalog's `IsPythQuadruple`. -/
theorem isPythTuple_iff_isPythQuadruple (a b c d : ℤ) :
    IsPythTuple ![a, b, c] d ↔ IsPythQuadruple a b c d := by
  unfold IsPythTuple IsPythQuadruple
  simp [Fin.sum_univ_three]

/-- The all-plus move of the general theory is the catalog's `Descends 1 1 1`. -/
theorem descendsOn_empty_iff_catalog (a b c d : ℤ) :
    DescendsOn (∅ : Finset (Fin 3)) ![a, b, c] d ↔ HigherPythagorean.Descends 1 1 1 a b c d := by
  unfold DescendsOn HigherPythagorean.Descends
  rw [signedSum_empty]
  simp [Fin.sum_univ_three]

/-- Flipping the first sign is the catalog's `Descends (-1) 1 1`. -/
theorem descendsOn_singleton_iff_catalog (a b c d : ℤ) :
    DescendsOn ({0} : Finset (Fin 3)) ![a, b, c] d
      ↔ HigherPythagorean.Descends (-1) 1 1 a b c d := by
  unfold DescendsOn HigherPythagorean.Descends signedSum
  simp [Fin.sum_univ_three]

end HigherPythagoreanDescent