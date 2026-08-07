/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Geometry.SchubertCalculus.QBinomial

/-!
# Schubert calculus IV: Pieri chains and the degree of `Gr(2, n)`

Pieri's rule says that multiplying a Schubert class by the hyperplane class `σ₁` of the
Plücker embedding adds one box to the Young diagram in all possible ways.  Consequently the
degree of `Gr(k, n)` in its Plücker embedding — the number `∫ σ₁^{k(n-k)}` — equals the
number of saturated chains from the empty diagram to the full `k × (n-k)` box in Young's
lattice.

This file works with the two-row case, where the saturated chains are exactly the ballot
sequences, and proves

* `SchubertCalculus.boxChains_add_choose` : the ballot-number identity
  `N(i,j) + C(f, m+1-j) = C(f, m-j)` (the reflection principle, proved by induction and
  Pascal's rule);
* `SchubertCalculus.boxChains_eq_catalan` : the number of saturated chains in the `2 × m`
  box is the Catalan number `Cₘ`, hence `deg Gr(2, m+2) = Cₘ`.

The link with the geometry of the Grassmannian is made in
`SchubertCalculus.chainCount_eq_boxChains`, which identifies the chain counting on
*jump sets* (the Schubert cell indices of `Geometry.SchubertCalculus.Flags`) with the
combinatorial ballot recursion, and in `SchubertCalculus.dimCell_of_mem_coverSet`, which is
the statement that a Pieri move raises the dimension of the Schubert cell by exactly one.
-/

namespace SchubertCalculus

open Finset

/-! ### Ballot paths in a two-row box -/

/-- `boxChains m f i j` is the number of ways to complete the two-row partition `(i, j)`
(inside the `2 × m` box) to the full box by adding `f` boxes one at a time, always keeping a
partition shape. -/
def boxChains (m : ℕ) : ℕ → ℕ → ℕ → ℕ
  | 0, _, _ => 1
  | f + 1, i, j =>
      (if i < m then boxChains m f (i + 1) j else 0) +
      (if j < i then boxChains m f i (j + 1) else 0)

@[simp] lemma boxChains_zero (m i j : ℕ) : boxChains m 0 i j = 1 := rfl

lemma boxChains_succ (m f i j : ℕ) :
    boxChains m (f + 1) i j =
      (if i < m then boxChains m f (i + 1) j else 0) +
      (if j < i then boxChains m f i (j + 1) else 0) := rfl

/-- **The reflection principle** for two-row ballot paths, in a subtraction-free form:
the number of saturated chains from `(i, j)` to the full `2 × m` box, together with the
number of "reflected" (bad) paths, exhausts all monotone lattice paths. -/
theorem boxChains_add_choose (m : ℕ) :
    ∀ f i j, j ≤ i → i ≤ m → f = (m - i) + (m - j) →
      boxChains m f i j + Nat.choose f ((m - j) + 1) = Nat.choose f (m - j) := by
  intro f
  induction f with
  | zero =>
      intro i j hji him hf
      have hj : j = m := by omega
      simp [hj]
  | succ f ih =>
      intro i j hji him hf
      rw [boxChains_succ]
      by_cases hiM : i < m
      · obtain ⟨u, hu⟩ : ∃ u, m - j = u + 1 := ⟨m - j - 1, by omega⟩
        rw [hu]
        have p1 : Nat.choose (f + 1) (u + 1 + 1) =
            Nat.choose f (u + 1) + Nat.choose f (u + 1 + 1) := Nat.choose_succ_succ f (u + 1)
        have p2 : Nat.choose (f + 1) (u + 1) =
            Nat.choose f u + Nat.choose f (u + 1) := Nat.choose_succ_succ f u
        by_cases hjI : j < i
        · rw [if_pos hiM, if_pos hjI]
          have h1 := ih (i + 1) j (by omega) (by omega) (by omega)
          have h2 := ih i (j + 1) (by omega) (by omega) (by omega)
          rw [hu] at h1
          rw [show m - (j + 1) = u from by omega] at h2
          omega
        · rw [if_pos hiM, if_neg hjI]
          have h1 := ih (i + 1) j (by omega) (by omega) (by omega)
          rw [hu] at h1
          have hsymm : Nat.choose f (u + 1) = Nat.choose f u := by
            have hfu : f - (u + 1) = u := by omega
            have hch := Nat.choose_symm (n := f) (k := u + 1) (by omega)
            rw [hfu] at hch
            exact hch.symm
          omega
      · have him' : i = m := by omega
        have hjI : j < i := by omega
        rw [if_neg hiM, if_pos hjI]
        obtain ⟨u, hu⟩ : ∃ u, m - j = u + 1 := ⟨m - j - 1, by omega⟩
        rw [hu]
        have h2 := ih i (j + 1) (by omega) (by omega) (by omega)
        rw [show m - (j + 1) = u from by omega] at h2
        have hfu : f = u := by omega
        have hzero : Nat.choose f (u + 1) = 0 := by
          apply Nat.choose_eq_zero_of_lt; omega
        have hone : Nat.choose f u = 1 := by
          rw [hfu]; exact Nat.choose_self u
        have hzero' : Nat.choose (f + 1) (u + 1 + 1) = 0 := by
          apply Nat.choose_eq_zero_of_lt; omega
        have hone' : Nat.choose (f + 1) (u + 1) = 1 := by
          rw [show f + 1 = u + 1 from by omega]; exact Nat.choose_self _
        omega

/-- Auxiliary identity: `C(2m, m+1) = m · Cₘ`. -/
lemma choose_two_mul_succ (m : ℕ) : Nat.choose (2 * m) (m + 1) = m * catalan m := by
  have hcb : Nat.choose (2 * m) m = (m + 1) * catalan m := by
    have h := succ_mul_catalan_eq_centralBinom m
    rw [Nat.centralBinom] at h
    omega
  have hkey : Nat.choose (2 * m) (m + 1) * (m + 1) = Nat.choose (2 * m) m * (2 * m - m) :=
    Nat.choose_succ_right_eq (2 * m) m
  have h2 : (2 * m - m) = m := by omega
  rw [h2, hcb] at hkey
  have : Nat.choose (2 * m) (m + 1) * (m + 1) = (m * catalan m) * (m + 1) := by
    rw [hkey]; ring
  exact Nat.eq_of_mul_eq_mul_right (Nat.succ_pos m) this

/-- **The number of saturated chains in the `2 × m` box is the `m`-th Catalan number.**
Via Pieri's rule this is the degree of `Gr(2, m+2)` in its Plücker embedding. -/
theorem boxChains_eq_catalan (m : ℕ) : boxChains m (2 * m) 0 0 = catalan m := by
  have h := boxChains_add_choose m (2 * m) 0 0 (le_refl 0) (Nat.zero_le m) (by omega)
  simp only [Nat.sub_zero] at h
  rw [choose_two_mul_succ m] at h
  have hcb : Nat.choose (2 * m) m = (m + 1) * catalan m := by
    have h' := succ_mul_catalan_eq_centralBinom m
    rw [Nat.centralBinom] at h'
    omega
  rw [hcb] at h
  have hm : m * catalan m + catalan m = (m + 1) * catalan m := by ring
  omega


/-! ### Pieri chains on jump sets, and the degree of `Gr(2, n)` -/

/-- The Pieri covering moves on a jump set: push one jump up by one step, provided the
resulting set is again a jump set inside `{0, …, n-1}`.  Under the dictionary
`jump set ↔ Young diagram` this is exactly "add one box in all possible ways", i.e. the
Pieri rule for multiplication by the hyperplane class `σ₁`. -/
def coverSet (n : ℕ) (S : Finset ℕ) : Finset (Finset ℕ) :=
  (S.filter fun a => a + 1 < n ∧ a + 1 ∉ S).image fun a => insert (a + 1) (S.erase a)

/-- `chainCount n top f S` is the number of saturated `f`-step Pieri chains from the Schubert
cell `S` to the cell `top`. -/
def chainCount (n : ℕ) (top : Finset ℕ) : ℕ → Finset ℕ → ℕ
  | 0, S => if S = top then 1 else 0
  | f + 1, S => ∑ T ∈ coverSet n S, chainCount n top f T

/-- The degree of `Gr(k, n)` in the Plücker embedding, computed by Pieri's rule as the number
of saturated chains from the bottom cell `{0, …, k-1}` to the top cell
`{n-k, …, n-1}`. -/
def degreeGr (k n : ℕ) : ℕ := chainCount n (Finset.Ico (n - k) n) (k * (n - k)) (range k)

lemma chainCount_succ (n : ℕ) (top : Finset ℕ) (f : ℕ) (S : Finset ℕ) :
    chainCount n top (f + 1) S = ∑ T ∈ coverSet n S, chainCount n top f T := rfl

private lemma insert_erase_left {a b : ℕ} (hab : a < b) :
    insert (a + 1) (({a, b} : Finset ℕ).erase a) = ({a + 1, b} : Finset ℕ) := by
  ext x
  simp only [Finset.mem_insert, Finset.mem_erase, Finset.mem_singleton]
  constructor
  · rintro (rfl | ⟨hx, hxa | hxb⟩)
    · exact Or.inl rfl
    · exact absurd hxa hx
    · exact Or.inr hxb
  · rintro (rfl | rfl)
    · exact Or.inl rfl
    · exact Or.inr ⟨by omega, Or.inr rfl⟩

private lemma insert_erase_right {a b : ℕ} (hab : a < b) :
    insert (b + 1) (({a, b} : Finset ℕ).erase b) = ({a, b + 1} : Finset ℕ) := by
  ext x
  simp only [Finset.mem_insert, Finset.mem_erase, Finset.mem_singleton]
  constructor
  · rintro (rfl | ⟨hx, hxa | hxb⟩)
    · exact Or.inr rfl
    · exact Or.inl hxa
    · exact absurd hxb hx
  · rintro (rfl | rfl)
    · exact Or.inr ⟨by omega, Or.inl rfl⟩
    · exact Or.inl rfl

private lemma pair_ne {a b : ℕ} (hab : a < b) :
    ({a, b + 1} : Finset ℕ) ≠ ({a + 1, b} : Finset ℕ) := by
  intro hcon
  have ha : a ∈ ({a + 1, b} : Finset ℕ) := by rw [← hcon]; simp
  simp only [Finset.mem_insert, Finset.mem_singleton] at ha
  omega

/-- The Pieri moves available from a two-element jump set `{a, b}`. -/
lemma mem_coverSet_pair {n a b : ℕ} (hab : a < b) (hbn : b < n) {X : Finset ℕ} :
    X ∈ coverSet n ({a, b} : Finset ℕ) ↔
      (a + 1 < b ∧ X = ({a + 1, b} : Finset ℕ)) ∨
      (b + 1 < n ∧ X = ({a, b + 1} : Finset ℕ)) := by
  simp only [coverSet, Finset.mem_image, Finset.mem_filter, Finset.mem_insert,
    Finset.mem_singleton]
  constructor
  · rintro ⟨y, ⟨(rfl | rfl), hlt, hnot⟩, rfl⟩
    · have hne : y + 1 ≠ b := fun h => hnot (Or.inr h)
      exact Or.inl ⟨by omega, insert_erase_left hab⟩
    · exact Or.inr ⟨hlt, insert_erase_right hab⟩
  · rintro (⟨h1, rfl⟩ | ⟨h2, rfl⟩)
    · exact ⟨a, ⟨Or.inl rfl, by omega, by simp; omega⟩, insert_erase_left hab⟩
    · exact ⟨b, ⟨Or.inr rfl, h2, by simp; omega⟩, insert_erase_right hab⟩

/-- The Pieri moves out of a two-element jump set `{a, b}`, as a sum formula. -/
lemma sum_coverSet_pair {n a b : ℕ} (hab : a < b) (hbn : b < n) (g : Finset ℕ → ℕ) :
    ∑ T ∈ coverSet n ({a, b} : Finset ℕ), g T =
      (if a + 1 < b then g {a + 1, b} else 0) + (if b + 1 < n then g {a, b + 1} else 0) := by
  by_cases h1 : a + 1 < b <;> by_cases h2 : b + 1 < n
  · have hcov : coverSet n ({a, b} : Finset ℕ)
        = ({({a, b + 1} : Finset ℕ), ({a + 1, b} : Finset ℕ)} : Finset (Finset ℕ)) := by
      ext X
      rw [mem_coverSet_pair hab hbn]
      simp only [Finset.mem_insert, Finset.mem_singleton]
      constructor
      · rintro (⟨_, rfl⟩ | ⟨_, rfl⟩)
        · exact Or.inr rfl
        · exact Or.inl rfl
      · rintro (rfl | rfl)
        · exact Or.inr ⟨h2, rfl⟩
        · exact Or.inl ⟨h1, rfl⟩
    rw [hcov, Finset.sum_insert (by simp [pair_ne hab]), Finset.sum_singleton, if_pos h1,
      if_pos h2]
    omega
  · have hcov : coverSet n ({a, b} : Finset ℕ)
        = ({({a + 1, b} : Finset ℕ)} : Finset (Finset ℕ)) := by
      ext X
      rw [mem_coverSet_pair hab hbn]
      simp only [Finset.mem_singleton]
      constructor
      · rintro (⟨_, rfl⟩ | ⟨hc, rfl⟩)
        · rfl
        · exact absurd hc h2
      · rintro rfl
        exact Or.inl ⟨h1, rfl⟩
    rw [hcov, Finset.sum_singleton, if_pos h1, if_neg h2]
    omega
  · have hcov : coverSet n ({a, b} : Finset ℕ)
        = ({({a, b + 1} : Finset ℕ)} : Finset (Finset ℕ)) := by
      ext X
      rw [mem_coverSet_pair hab hbn]
      simp only [Finset.mem_singleton]
      constructor
      · rintro (⟨hc, rfl⟩ | ⟨_, rfl⟩)
        · exact absurd hc h1
        · rfl
      · rintro rfl
        exact Or.inr ⟨h2, rfl⟩
    rw [hcov, Finset.sum_singleton, if_neg h1, if_pos h2]
    omega
  · have hcov : coverSet n ({a, b} : Finset ℕ) = (∅ : Finset (Finset ℕ)) := by
      ext X
      rw [mem_coverSet_pair hab hbn]
      simp only [Finset.notMem_empty, iff_false, not_or]
      exact ⟨fun hc => h1 hc.1, fun hc => h2 hc.1⟩
    rw [hcov, Finset.sum_empty, if_neg h1, if_neg h2]
    omega

/-- **Bridge between geometry and combinatorics.** For `Gr(2, m+2)` the Pieri chain counting
on jump sets coincides with the two-row ballot recursion. -/
theorem chainCount_pair (m : ℕ) :
    ∀ f a b, a < b → b < m + 2 → f = (m - (b - 1)) + (m - a) →
      chainCount (m + 2) (Finset.Ico m (m + 2)) f ({a, b} : Finset ℕ)
        = boxChains m f (b - 1) a := by
  intro f
  induction f with
  | zero =>
      intro a b hab hbn hf
      have ha : a = m := by omega
      have hb : b = m + 1 := by omega
      have htop : ({a, b} : Finset ℕ) = Finset.Ico m (m + 2) := by
        subst ha; subst hb
        ext x
        simp only [Finset.mem_insert, Finset.mem_singleton, Finset.mem_Ico]
        omega
      simp [chainCount, htop]
  | succ f ih =>
      intro a b hab hbn hf
      obtain ⟨c, rfl⟩ : ∃ c, b = c + 1 := ⟨b - 1, by omega⟩
      simp only [Nat.add_sub_cancel] at hf ⊢
      rw [chainCount_succ, sum_coverSet_pair hab hbn, boxChains_succ]
      by_cases h1 : a + 1 < c + 1
      · by_cases h2 : c + 1 + 1 < m + 2
        · rw [if_pos h1, if_pos h2, if_pos (show c < m by omega),
            if_pos (show a < c by omega)]
          have e1 := ih (a + 1) (c + 1) (by omega) (by omega) (by simp; omega)
          have e2 := ih a (c + 1 + 1) (by omega) (by omega) (by simp; omega)
          simp only [Nat.add_sub_cancel] at e1 e2
          rw [e1, e2]
          omega
        · rw [if_pos h1, if_neg h2, if_neg (show ¬ c < m by omega),
            if_pos (show a < c by omega)]
          have e1 := ih (a + 1) (c + 1) (by omega) (by omega) (by simp; omega)
          simp only [Nat.add_sub_cancel] at e1
          rw [e1]
          omega
      · by_cases h2 : c + 1 + 1 < m + 2
        · rw [if_neg h1, if_pos h2, if_pos (show c < m by omega),
            if_neg (show ¬ a < c by omega)]
          have e2 := ih a (c + 1 + 1) (by omega) (by omega) (by simp; omega)
          simp only [Nat.add_sub_cancel] at e2
          rw [e2]
          omega
        · rw [if_neg h1, if_neg h2, if_neg (show ¬ c < m by omega),
            if_neg (show ¬ a < c by omega)]

/-- **The degree of `Gr(2, m+2)` in its Plücker embedding is the Catalan number `Cₘ`.**
Combining Pieri chain counting on Schubert cells with the reflection principle. -/
theorem degreeGr_two_eq_catalan (m : ℕ) : degreeGr 2 (m + 2) = catalan m := by
  have hrange : (range 2 : Finset ℕ) = ({0, 1} : Finset ℕ) := by
    ext x; simp only [Finset.mem_range, Finset.mem_insert, Finset.mem_singleton]; omega
  have hIco : (Finset.Ico (m + 2 - 2) (m + 2) : Finset ℕ) = Finset.Ico m (m + 2) := by
    congr 1
  have hlen : 2 * (m + 2 - 2) = 2 * m := by omega
  rw [degreeGr, hrange, hIco, hlen]
  have := chainCount_pair m (2 * m) 0 1 (by omega) (by omega) (by omega)
  simpa using this.trans (boxChains_eq_catalan m)

/-- The first few degrees of `Gr(2, n)`: `1, 2, 5, 14, 42`. -/
example : (degreeGr 2 3, degreeGr 2 4, degreeGr 2 5, degreeGr 2 6, degreeGr 2 7)
    = (1, 2, 5, 14, 42) := by decide


/-! ### Pieri moves raise the dimension of the Schubert cell by one -/

/-- **The Pieri rule is dimension-graded.** Every Pieri move on jump sets increases the
dimension of the corresponding Schubert cell by exactly one; hence a chain of
`k(n-k)` moves starting at the point cell is a *maximal* chain, and the degree computed by
`degreeGr` is the intersection number `∫_{Gr(k,n)} σ₁^{k(n-k)}`. -/
theorem dimCell_of_mem_coverSet {n : ℕ} {S T : Finset ℕ}
    (hT : T ∈ coverSet n S) : dimCell n T = dimCell n S + 1 := by
  classical
  obtain ⟨a, ha, rfl⟩ := Finset.mem_image.mp hT
  obtain ⟨haS, han, hanS⟩ : a ∈ S ∧ a + 1 < n ∧ a + 1 ∉ S := by
    obtain ⟨h1, h2, h3⟩ := Finset.mem_filter.mp ha
    exact ⟨h1, h2, h3⟩
  have hanotin : a ∉ range n \ S := by simp [haS]
  have hain : a + 1 ∈ range n \ S := by
    simp only [Finset.mem_sdiff, Finset.mem_range]
    exact ⟨han, hanS⟩
  have hcompl : range n \ insert (a + 1) (S.erase a)
      = insert a ((range n \ S).erase (a + 1)) := by
    ext x
    simp only [Finset.mem_sdiff, Finset.mem_range, Finset.mem_insert, Finset.mem_erase,
      not_or, not_and]
    constructor
    · rintro ⟨hxn, hne, hx⟩
      by_cases hxa : x = a
      · exact Or.inl hxa
      · exact Or.inr ⟨hne, hxn, hx hxa⟩
    · rintro (rfl | ⟨hne, hxn, hxS⟩)
      · exact ⟨by omega, by omega, fun h => absurd rfl h⟩
      · exact ⟨hxn, hne, fun _ => hxS⟩
  have key1 : ∀ x ∈ S.erase a,
      ((range n \ insert (a + 1) (S.erase a)).filter fun b => b < x).card
        = ((range n \ S).filter fun b => b < x).card := by
    intro x hx
    obtain ⟨hxa, hxS⟩ := Finset.mem_erase.mp hx
    have hxne : x ≠ a + 1 := fun h => hanS (h ▸ hxS)
    rw [hcompl, Finset.filter_insert, Finset.filter_erase]
    rcases lt_or_gt_of_ne hxa with hlt | hgt
    · rw [if_neg (by omega), Finset.erase_eq_of_notMem (by
        simp only [Finset.mem_filter]
        rintro ⟨-, hcon⟩
        omega)]
    · have hax : a + 1 < x := by omega
      have hmem : a + 1 ∈ (range n \ S).filter fun b => b < x :=
        Finset.mem_filter.mpr ⟨hain, hax⟩
      have hnot : a ∉ ((range n \ S).filter fun b => b < x).erase (a + 1) := by
        intro hcon
        exact hanotin (Finset.mem_filter.mp (Finset.mem_of_mem_erase hcon)).1
      rw [if_pos (by omega), Finset.card_insert_of_notMem hnot,
        Finset.card_erase_of_mem hmem]
      have : 1 ≤ ((range n \ S).filter fun b => b < x).card :=
        Finset.card_pos.mpr ⟨a + 1, hmem⟩
      omega
  have key2 : ((range n \ insert (a + 1) (S.erase a)).filter fun b => b < a + 1).card
      = ((range n \ S).filter fun b => b < a).card + 1 := by
    rw [hcompl, Finset.filter_insert, Finset.filter_erase, if_pos (by omega)]
    have hfil : ((range n \ S).filter fun b => b < a + 1)
        = ((range n \ S).filter fun b => b < a) := by
      ext b
      simp only [Finset.mem_filter]
      constructor
      · rintro ⟨hb, hblt⟩
        refine ⟨hb, ?_⟩
        rcases Nat.lt_succ_iff_lt_or_eq.mp hblt with h | h
        · exact h
        · exact absurd (h ▸ hb) hanotin
      · rintro ⟨hb, hblt⟩
        exact ⟨hb, by omega⟩
    rw [hfil, Finset.erase_eq_of_notMem (by
      simp only [Finset.mem_filter]
      rintro ⟨-, hcon⟩
      omega)]
    refine Finset.card_insert_of_notMem ?_
    simp only [Finset.mem_filter]
    rintro ⟨hcon, -⟩
    exact hanotin hcon
  have hsplitT : dimCell n (insert (a + 1) (S.erase a))
      = ((range n \ insert (a + 1) (S.erase a)).filter fun b => b < a + 1).card
        + ∑ x ∈ S.erase a,
            ((range n \ insert (a + 1) (S.erase a)).filter fun b => b < x).card := by
    rw [dimCell, Finset.sum_insert (by simp [hanS])]
  have hsplitS : dimCell n S
      = ((range n \ S).filter fun b => b < a).card
        + ∑ x ∈ S.erase a, ((range n \ S).filter fun b => b < x).card := by
    rw [dimCell, ← Finset.add_sum_erase S _ haS]
  rw [hsplitT, hsplitS, key2, Finset.sum_congr rfl key1]
  omega


/-- **The classical Schubert problem.** `deg Gr(2, 4) = 2`: exactly two lines of `ℙ³` meet
four lines in general position. -/
theorem degreeGr_two_four : degreeGr 2 4 = 2 := by
  have h := degreeGr_two_eq_catalan 2
  rwa [catalan_two] at h

/-- `deg Gr(2, 5) = 5`. -/
theorem degreeGr_two_five : degreeGr 2 5 = 5 := by
  have h := degreeGr_two_eq_catalan 3
  rwa [catalan_three] at h

end SchubertCalculus