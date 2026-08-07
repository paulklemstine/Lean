/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Geometry.SchubertCalculus.Duality

/-!
# Schubert calculus III: the Poincaré polynomial of the Grassmannian

By the cell decomposition established in `Geometry.SchubertCalculus.Flags`, the Grassmannian
`Gr(k, n)` is stratified by Schubert cells indexed by the `k`-element jump sets
`S ⊆ {0, …, n-1}`, the cell of `S` having dimension

`dimCell n S = #{(a, b) : a ∈ S, b ∉ S, b < a}`  (the number of inversions of `S`),

which is the size of the Young diagram of `S` inside the `k × (n-k)` box.  The generating
function of these dimensions,

`poincare R k n q = ∑_{#S = k} q ^ dimCell n S`,

is the Gaussian binomial coefficient `[n choose k]_q`: the Poincaré polynomial of the
Grassmannian (and, over a finite field, its point count).

Main results:

* `SchubertCalculus.poincare_succ` : the **q-Pascal recursion**
  `[n+1 choose k+1]_q = [n choose k+1]_q + q^{n-k} [n choose k]_q`;
* `SchubertCalculus.poincare_one` : specialising `q = 1` gives the binomial coefficient
  (the number of Schubert cells);
* `SchubertCalculus.dimCell_add_dimCell_compl` : the complementary dimension identity
  `dim σ + dim σᶜ = k (n - k)`, i.e. the Schubert cells come in complementary pairs — the
  combinatorial shadow of Poincaré duality on `Gr(k, n)`;
* `SchubertCalculus.poincare_compl` : the isomorphism `Gr(k, n) ≅ Gr(n-k, n)` at the level of
  Poincaré polynomials;
* `SchubertCalculus.poincare_palindromic` : the Poincaré polynomial is palindromic of degree
  `k (n-k)`, i.e. `q^{k(n-k)} P(1/q) = P(q)` — Poincaré duality.
-/

namespace SchubertCalculus

open Finset

/-- The dimension of the Schubert cell attached to a jump set `S ⊆ {0,…,n-1}`: the number of
pairs `b < a` with `a ∈ S` and `b ∉ S`. -/
def dimCell (n : ℕ) (S : Finset ℕ) : ℕ :=
  ∑ a ∈ S, ((range n \ S).filter fun b => b < a).card

/-- The Poincaré polynomial of the Grassmannian `Gr(k, n)`, i.e. the Gaussian binomial
coefficient `[n choose k]_q`, defined as the generating function of Schubert cell
dimensions. -/
def poincare (R : Type*) [CommSemiring R] (k n : ℕ) (q : R) : R :=
  ∑ S ∈ (range n).powersetCard k, q ^ dimCell n S

variable {R : Type*} [CommSemiring R] (q : R)

@[simp] lemma dimCell_empty (n : ℕ) : dimCell n ∅ = 0 := by simp [dimCell]

/-- Cell dimensions do not depend on how large the ambient flag is, as long as it contains
the jump set. -/
lemma dimCell_succ_of_subset {n : ℕ} {S : Finset ℕ} (hS : S ⊆ range n) :
    dimCell (n + 1) S = dimCell n S := by
  refine Finset.sum_congr rfl fun a ha => ?_
  congr 1
  ext b
  simp only [Finset.mem_filter, Finset.mem_sdiff, Finset.mem_range]
  have han : a < n := Finset.mem_range.mp (hS ha)
  constructor
  · rintro ⟨⟨_, hbS⟩, hba⟩; exact ⟨⟨by omega, hbS⟩, hba⟩
  · rintro ⟨⟨hb, hbS⟩, hba⟩; exact ⟨⟨by omega, hbS⟩, hba⟩

/-- Adding a new largest jump increases the cell dimension by the number of non-jumps below
it. -/
lemma dimCell_insert {n k : ℕ} {S : Finset ℕ} (hS : S ⊆ range n) (hcard : S.card = k) :
    dimCell (n + 1) (insert n S) = dimCell n S + (n - k) := by
  have hnS : n ∉ S := fun h => by simpa using hS h
  rw [dimCell, Finset.sum_insert hnS]
  have htop : ((range (n + 1) \ insert n S).filter fun b => b < n) = range n \ S := by
    ext b
    simp only [Finset.mem_filter, Finset.mem_sdiff, Finset.mem_range, Finset.mem_insert,
      not_or]
    constructor
    · rintro ⟨⟨_, _, hbS⟩, hbn⟩; exact ⟨hbn, hbS⟩
    · rintro ⟨hbn, hbS⟩; exact ⟨⟨by omega, by omega, hbS⟩, hbn⟩
  have hrest : ∀ a ∈ S, ((range (n + 1) \ insert n S).filter fun b => b < a).card =
      ((range n \ S).filter fun b => b < a).card := by
    intro a ha
    congr 1
    ext b
    have han : a < n := Finset.mem_range.mp (hS ha)
    simp only [Finset.mem_filter, Finset.mem_sdiff, Finset.mem_range, Finset.mem_insert,
      not_or]
    constructor
    · rintro ⟨⟨_, _, hbS⟩, hba⟩; exact ⟨⟨by omega, hbS⟩, hba⟩
    · rintro ⟨⟨_, hbS⟩, hba⟩; exact ⟨⟨by omega, by omega, hbS⟩, hba⟩
  have hc : (range n \ S).card = n - k := by
    rw [Finset.card_sdiff, Finset.inter_eq_left.mpr hS, Finset.card_range, hcard]
  rw [htop, hc, Finset.sum_congr rfl hrest, add_comm]
  rfl

@[simp] lemma poincare_zero_left (n : ℕ) : poincare R 0 n q = 1 := by
  simp [poincare, Finset.powersetCard_zero]

@[simp] lemma poincare_zero_right (k : ℕ) : poincare R (k + 1) 0 q = 0 := by
  rw [poincare, Finset.powersetCard_eq_empty.mpr (by simp)]
  simp

/-- **The q-Pascal recursion** for Gaussian binomial coefficients, proved by splitting the
Schubert cells of `Gr(k+1, n+1)` according to whether the last coordinate is a jump. -/
theorem poincare_succ (k n : ℕ) :
    poincare R (k + 1) (n + 1) q =
      poincare R (k + 1) n q + q ^ (n - k) * poincare R k n q := by
  classical
  have hn : n ∉ range n := by simp
  rw [poincare, Finset.range_add_one, Finset.powersetCard_succ_insert hn]
  rw [Finset.sum_union]
  · congr 1
    · refine Finset.sum_congr rfl fun S hS => ?_
      rw [dimCell_succ_of_subset (Finset.mem_powersetCard.mp hS).1]
    · rw [Finset.sum_image]
      · rw [poincare, Finset.mul_sum]
        refine Finset.sum_congr rfl fun S hS => ?_
        obtain ⟨hsub, hcard⟩ := Finset.mem_powersetCard.mp hS
        rw [dimCell_insert hsub hcard, pow_add, mul_comm]
      · intro S hS T hT hST
        obtain ⟨hsubS, _⟩ := Finset.mem_powersetCard.mp (Finset.mem_coe.mp hS)
        obtain ⟨hsubT, _⟩ := Finset.mem_powersetCard.mp (Finset.mem_coe.mp hT)
        have hnS : n ∉ S := fun h => by simpa using hsubS h
        have hnT : n ∉ T := fun h => by simpa using hsubT h
        have := congrArg (fun U => U.erase n) hST
        simpa [Finset.erase_insert, hnS, hnT] using this
  · rw [Finset.disjoint_right]
    rintro S hS hS'
    obtain ⟨T, hT, rfl⟩ := Finset.mem_image.mp hS
    have hsub := (Finset.mem_powersetCard.mp hS').1
    have : n ∈ range n := hsub (Finset.mem_insert_self n T)
    simp at this

/-- Specialising `q = 1` counts the Schubert cells: there are `n.choose k` of them. -/
theorem poincare_one (k n : ℕ) : poincare R k n 1 = (n.choose k : R) := by
  rw [poincare]
  simp [Finset.card_powersetCard]

/-- The Gaussian binomial coefficient vanishes outside the range `0 ≤ k ≤ n`. -/
theorem poincare_eq_zero {k n : ℕ} (h : n < k) : poincare R k n q = 0 := by
  rw [poincare, Finset.powersetCard_eq_empty.mpr (by simpa using h)]
  simp


/-! ### Poincaré duality: the complementary cell identity -/

lemma sdiff_sdiff_self_of_subset {n : ℕ} {S : Finset ℕ} (hS : S ⊆ range n) :
    range n \ (range n \ S) = S := by
  ext b
  simp only [Finset.mem_sdiff, Finset.mem_range]
  constructor
  · rintro ⟨hb, h⟩
    by_contra hbS
    exact h ⟨hb, hbS⟩
  · intro hbS
    exact ⟨Finset.mem_range.mp (hS hbS), fun h => h.2 hbS⟩

lemma sum_card_filter_lt_add_gt {S T : Finset ℕ} (hd : Disjoint S T) :
    (∑ a ∈ S, (T.filter fun b => b < a).card) + (∑ a ∈ S, (T.filter fun b => a < b).card)
      = S.card * T.card := by
  rw [← Finset.sum_add_distrib]
  have hterm : ∀ a ∈ S, (T.filter fun b => b < a).card + (T.filter fun b => a < b).card
      = T.card := by
    intro a ha
    rw [Finset.card_filter, Finset.card_filter, ← Finset.sum_add_distrib,
      Finset.card_eq_sum_ones T]
    refine Finset.sum_congr rfl fun b hb => ?_
    have hne : a ≠ b := fun h => (Finset.disjoint_left.mp hd ha) (h ▸ hb)
    split_ifs <;> omega
  rw [Finset.sum_congr rfl hterm, Finset.sum_const, smul_eq_mul]

lemma sum_card_filter_swap (S T : Finset ℕ) :
    (∑ b ∈ T, (S.filter fun a => a < b).card) = ∑ a ∈ S, (T.filter fun b => a < b).card := by
  simp_rw [Finset.card_filter]
  exact Finset.sum_comm

lemma dimCell_compl_eq {n : ℕ} {S : Finset ℕ} (hS : S ⊆ range n) :
    dimCell n (range n \ S) = ∑ a ∈ S, ((range n \ S).filter fun b => a < b).card := by
  rw [dimCell, sdiff_sdiff_self_of_subset hS, sum_card_filter_swap]

/-- **Complementary dimensions.** A Schubert cell and its complementary cell have dimensions
adding up to `k (n-k) = dim Gr(k, n)`: the combinatorial form of Poincaré duality. -/
theorem dimCell_add_dimCell_compl {n k : ℕ} {S : Finset ℕ} (hS : S ⊆ range n)
    (hcard : S.card = k) :
    dimCell n S + dimCell n (range n \ S) = k * (n - k) := by
  have hdisj : Disjoint S (range n \ S) := Finset.disjoint_sdiff
  have hTcard : (range n \ S).card = n - k := by
    rw [Finset.card_sdiff, Finset.inter_eq_left.mpr hS, Finset.card_range, hcard]
  rw [dimCell_compl_eq hS, dimCell, sum_card_filter_lt_add_gt hdisj, hcard, hTcard]

/-- Every Schubert cell of `Gr(k, n)` has dimension at most `k (n-k)`. -/
theorem dimCell_le {n k : ℕ} {S : Finset ℕ} (hS : S ⊆ range n) (hcard : S.card = k) :
    dimCell n S ≤ k * (n - k) := by
  have := dimCell_add_dimCell_compl hS hcard
  omega

/-! ### The reversal involution and palindromicity -/

/-- Order-reversing involution of `{0, …, n-1}`. -/
def rev (n j : ℕ) : ℕ := n - 1 - j

lemma rev_lt {n j : ℕ} (hj : j < n) : rev n j < n := by
  simp only [rev]; omega

lemma rev_rev {n j : ℕ} (hj : j < n) : rev n (rev n j) = j := by
  simp only [rev]; omega

lemma rev_lt_rev {n a b : ℕ} (ha : a < n) (hb : b < n) : rev n b < rev n a ↔ a < b := by
  simp only [rev]; omega

lemma rev_injOn {n : ℕ} (S : Finset ℕ) (hS : S ⊆ range n) :
    Set.InjOn (rev n) (S : Set ℕ) := by
  intro a ha b hb hab
  have ha' : a < n := Finset.mem_range.mp (hS ha)
  have hb' : b < n := Finset.mem_range.mp (hS hb)
  have := congrArg (rev n) hab
  rwa [rev_rev ha', rev_rev hb'] at this

/-- The reversal of a jump set. -/
def revSet (n : ℕ) (S : Finset ℕ) : Finset ℕ := S.image (rev n)

lemma revSet_subset {n : ℕ} {S : Finset ℕ} (hS : S ⊆ range n) : revSet n S ⊆ range n := by
  intro x hx
  obtain ⟨a, ha, rfl⟩ := Finset.mem_image.mp hx
  exact Finset.mem_range.mpr (rev_lt (Finset.mem_range.mp (hS ha)))

lemma card_revSet {n : ℕ} {S : Finset ℕ} (hS : S ⊆ range n) : (revSet n S).card = S.card :=
  Finset.card_image_of_injOn (rev_injOn S hS)

lemma revSet_revSet {n : ℕ} {S : Finset ℕ} (hS : S ⊆ range n) : revSet n (revSet n S) = S := by
  ext x
  simp only [revSet, Finset.mem_image]
  constructor
  · rintro ⟨y, ⟨a, ha, rfl⟩, rfl⟩
    rwa [rev_rev (Finset.mem_range.mp (hS ha))]
  · intro hx
    exact ⟨rev n x, ⟨x, hx, rfl⟩, rev_rev (Finset.mem_range.mp (hS hx))⟩

lemma sdiff_revSet {n : ℕ} {S : Finset ℕ} (hS : S ⊆ range n) :
    range n \ revSet n S = revSet n (range n \ S) := by
  ext x
  simp only [Finset.mem_sdiff, Finset.mem_range, revSet, Finset.mem_image]
  constructor
  · rintro ⟨hx, hnx⟩
    refine ⟨rev n x, ⟨rev_lt hx, ?_⟩, rev_rev hx⟩
    intro hmem
    exact hnx ⟨rev n x, hmem, rev_rev hx⟩
  · rintro ⟨a, ⟨ha, haS⟩, rfl⟩
    refine ⟨rev_lt ha, ?_⟩
    rintro ⟨b, hb, hba⟩
    have hb' : b < n := Finset.mem_range.mp (hS hb)
    have : b = a := by
      have := congrArg (rev n) hba
      rwa [rev_rev hb', rev_rev ha] at this
    exact haS (this ▸ hb)

/-- Reversal turns a Schubert cell into the cell of complementary dimension. -/
theorem dimCell_revSet {n k : ℕ} {S : Finset ℕ} (hS : S ⊆ range n) (hcard : S.card = k) :
    dimCell n (revSet n S) = k * (n - k) - dimCell n S := by
  have hsub : (range n \ S) ⊆ range n := Finset.sdiff_subset
  have hkey : dimCell n (revSet n S)
      = ∑ a ∈ S, ((range n \ S).filter fun b => a < b).card := by
    rw [dimCell, sdiff_revSet hS, revSet, Finset.sum_image (fun a ha b hb h =>
      rev_injOn S hS ha hb h)]
    refine Finset.sum_congr rfl fun a ha => ?_
    have ha' : a < n := Finset.mem_range.mp (hS ha)
    have himg : ((revSet n (range n \ S)).filter fun b => b < rev n a)
        = revSet n ((range n \ S).filter fun b => a < b) := by
      ext x
      simp only [revSet, Finset.mem_filter, Finset.mem_image]
      constructor
      · rintro ⟨⟨b, hb, rfl⟩, hlt⟩
        have hb' : b < n := Finset.mem_range.mp (hsub hb)
        exact ⟨b, ⟨hb, (rev_lt_rev ha' hb').mp hlt⟩, rfl⟩
      · rintro ⟨b, ⟨hb, hab⟩, rfl⟩
        have hb' : b < n := Finset.mem_range.mp (hsub hb)
        exact ⟨⟨b, hb, rfl⟩, (rev_lt_rev ha' hb').mpr hab⟩
    rw [himg, card_revSet (fun x hx => hsub (Finset.mem_filter.mp hx).1)]
  have hsum := sum_card_filter_lt_add_gt (S := S) (T := range n \ S) Finset.disjoint_sdiff
  have hTcard : (range n \ S).card = n - k := by
    rw [Finset.card_sdiff, Finset.inter_eq_left.mpr hS, Finset.card_range, hcard]
  rw [hcard, hTcard] at hsum
  have hdim : dimCell n S = ∑ a ∈ S, ((range n \ S).filter fun b => b < a).card := rfl
  rw [hkey, hdim]
  exact Nat.eq_sub_of_add_eq' (by rw [← hdim] at hsum ⊢; exact hsum)

/-- **Palindromicity of the Poincaré polynomial** (Poincaré duality for `Gr(k, n)`):
`q^{k(n-k)} · P(1/q) = P(q)`, stated without division as a reindexing of the exponents. -/
theorem poincare_palindromic (k n : ℕ) :
    ∑ S ∈ (range n).powersetCard k, q ^ (k * (n - k) - dimCell n S) = poincare R k n q := by
  rw [poincare]
  refine Finset.sum_nbij' (i := revSet n) (j := revSet n) ?_ ?_ ?_ ?_ ?_
  · intro S hS
    obtain ⟨hsub, hcard⟩ := Finset.mem_powersetCard.mp hS
    exact Finset.mem_powersetCard.mpr ⟨revSet_subset hsub, by rw [card_revSet hsub, hcard]⟩
  · intro S hS
    obtain ⟨hsub, hcard⟩ := Finset.mem_powersetCard.mp hS
    exact Finset.mem_powersetCard.mpr ⟨revSet_subset hsub, by rw [card_revSet hsub, hcard]⟩
  · intro S hS
    exact revSet_revSet (Finset.mem_powersetCard.mp hS).1
  · intro S hS
    exact revSet_revSet (Finset.mem_powersetCard.mp hS).1
  · intro S hS
    obtain ⟨hsub, hcard⟩ := Finset.mem_powersetCard.mp hS
    rw [dimCell_revSet hsub hcard]

/-- **The duality `Gr(k, n) ≅ Gr(n-k, n)`** at the level of Poincaré polynomials. -/
theorem poincare_compl {k n : ℕ} (hk : k ≤ n) : poincare R (n - k) n q = poincare R k n q := by
  rw [← poincare_palindromic q k n, poincare]
  refine Finset.sum_nbij' (i := fun S => range n \ S) (j := fun S => range n \ S) ?_ ?_ ?_ ?_ ?_
  · intro S hS
    obtain ⟨hsub, hcard⟩ := Finset.mem_powersetCard.mp hS
    refine Finset.mem_powersetCard.mpr ⟨Finset.sdiff_subset, ?_⟩
    rw [Finset.card_sdiff, Finset.inter_eq_left.mpr hsub, Finset.card_range, hcard]
    omega
  · intro S hS
    obtain ⟨hsub, hcard⟩ := Finset.mem_powersetCard.mp hS
    refine Finset.mem_powersetCard.mpr ⟨Finset.sdiff_subset, ?_⟩
    rw [Finset.card_sdiff, Finset.inter_eq_left.mpr hsub, Finset.card_range, hcard]
  · intro S hS
    exact sdiff_sdiff_self_of_subset (Finset.mem_powersetCard.mp hS).1
  · intro S hS
    exact sdiff_sdiff_self_of_subset (Finset.mem_powersetCard.mp hS).1
  · intro S hS
    obtain ⟨hsub, hcard⟩ := Finset.mem_powersetCard.mp hS
    have hcompl : (range n \ S).card = k := by
      rw [Finset.card_sdiff, Finset.inter_eq_left.mpr hsub, Finset.card_range, hcard]
      omega
    have h := dimCell_add_dimCell_compl (S := range n \ S) Finset.sdiff_subset hcompl
    rw [sdiff_sdiff_self_of_subset hsub] at h
    congr 1
    exact Nat.eq_sub_of_add_eq' h

/-! ### Point counts of small Grassmannians over finite fields -/

/-- `Gr(2, 4)` has `35` points over `𝔽₂` (the classical count of lines in `ℙ³(𝔽₂)`). -/
theorem poincare_two_four_two : poincare ℕ 2 4 2 = 35 := by decide

/-- `Gr(3, 6)` has `1395` points over `𝔽₂`. -/
theorem poincare_three_six_two : poincare ℕ 3 6 2 = 1395 := by decide

/-- `Gr(2, 5)` has `1210` points over `𝔽₃`. -/
theorem poincare_two_five_three : poincare ℕ 2 5 3 = 1210 := by decide

end SchubertCalculus