import MachineLearning.BerggrenTreeStars
import Shared.BerggrenTrees.Parent_hyp_lt
import MachineLearning.BerggrenEuclidParam

/-!
# Completeness of the tree, and a star at every primitive ideal point

`MachineLearning.BerggrenTreeStars` proves that every *node* of the Berggren tree is the
centre of a star of curves in the hyperbolic disc.  To conclude that the observed stars
occupy *every* primitive rational ideal point of the first-quadrant arc, one still needs
the classical Barning–Hall completeness theorem: the tree contains every primitive
Pythagorean triple with odd first leg.

This file proves that completeness by Fermat descent, reusing the catalog's descent
inequalities `parent_exists`, `parent_hyp_lt`, `parent_hyp_pos` from
`Shared/BerggrenTrees/Parent_hyp_lt.lean`, and then combines it with the star theorem.

## Main results

* `mA_pA`, `mB_pB`, `mC_pC` — the three descent maps are sections of the generators.
* `gcd_dvd_hyp` — the gcd of the legs divides the hypotenuse (via `g² ∣ c²`).
* `gcd_parent_*` — descent preserves primitivity.
* `tree_complete` — every primitive Pythagorean triple with positive entries and odd first
  leg is `applyWord W root` for some Berggren word `W`.
* `star_at_every_primitive_ideal_point` — hence every primitive Pythagorean direction is a
  star centre of the plot.
-/

namespace BerggrenStars

open Filter Topology

/-! ### The three descent (parent) maps -/

/-- Parent map inverting `mA` (the catalog's `invB1`). -/
def pA (v : Vec) : Vec :=
  (v.1 + 2 * v.2.1 - 2 * v.2.2, -2 * v.1 - v.2.1 + 2 * v.2.2, -2 * v.1 - 2 * v.2.1 + 3 * v.2.2)

/-- Parent map inverting `mB` (the catalog's `invB2`). -/
def pB (v : Vec) : Vec :=
  (v.1 + 2 * v.2.1 - 2 * v.2.2, 2 * v.1 + v.2.1 - 2 * v.2.2, -2 * v.1 - 2 * v.2.1 + 3 * v.2.2)

/-- Parent map inverting `mC` (the catalog's `invB3`). -/
def pC (v : Vec) : Vec :=
  (-v.1 - 2 * v.2.1 + 2 * v.2.2, 2 * v.1 + v.2.1 - 2 * v.2.2, -2 * v.1 - 2 * v.2.1 + 3 * v.2.2)

/- REPAIR (see the note at the head of this file): `invB1`, `invB2`, `invB3` are not
defined anywhere in the catalog, so the three identifications below cannot be elaborated.
They are retained verbatim, commented out.

theorem pA_eq_invB1 (a b c : ℤ) : pA (a, b, c) = invB1 a b c := rfl
theorem pB_eq_invB2 (a b c : ℤ) : pB (a, b, c) = invB2 a b c := rfl
theorem pC_eq_invB3 (a b c : ℤ) : pC (a, b, c) = invB3 a b c := rfl
-/

theorem mA_pA (v : Vec) : mA (pA v) = v := by
  obtain ⟨a, b, c⟩ := v
  simp only [mA, pA, Prod.mk.injEq]
  refine ⟨by ring, by ring, by ring⟩

theorem mB_pB (v : Vec) : mB (pB v) = v := by
  obtain ⟨a, b, c⟩ := v
  simp only [mB, pB, Prod.mk.injEq]
  refine ⟨by ring, by ring, by ring⟩

theorem mC_pC (v : Vec) : mC (pC v) = v := by
  obtain ⟨a, b, c⟩ := v
  simp only [mC, pC, Prod.mk.injEq]
  refine ⟨by ring, by ring, by ring⟩

theorem onCone_pA {v : Vec} (h : OnCone v) : OnCone (pA v) := by
  obtain ⟨a, b, c⟩ := v
  simp only [OnCone, qform, bil, pA] at h ⊢
  linear_combination h

theorem onCone_pB {v : Vec} (h : OnCone v) : OnCone (pB v) := by
  obtain ⟨a, b, c⟩ := v
  simp only [OnCone, qform, bil, pB] at h ⊢
  linear_combination h

theorem onCone_pC {v : Vec} (h : OnCone v) : OnCone (pC v) := by
  obtain ⟨a, b, c⟩ := v
  simp only [OnCone, qform, bil, pC] at h ⊢
  linear_combination h

/-! ### Descent preserves primitivity -/

/-- The gcd of the two legs divides the hypotenuse, because its square divides `c²`. -/
theorem gcd_dvd_hyp {a b c : ℤ} (h : a ^ 2 + b ^ 2 = c ^ 2) : ((Int.gcd a b : ℤ)) ∣ c := by
  have hga : ((Int.gcd a b : ℤ)) ∣ a := Int.gcd_dvd_left a b
  have hgb : ((Int.gcd a b : ℤ)) ∣ b := Int.gcd_dvd_right a b
  have h2 : ((Int.gcd a b : ℤ)) ^ 2 ∣ c ^ 2 := by
    rw [← h]
    exact dvd_add (pow_dvd_pow_of_dvd hga 2) (pow_dvd_pow_of_dvd hgb 2)
  exact (Int.pow_dvd_pow_iff two_ne_zero).mp h2

/-- Generic primitivity transfer: if the child's legs are integer combinations of the
parent's entries, the parent's leg-gcd divides the child's, hence is `1`. -/
private theorem gcd_parent_aux {a b : ℤ} (p : Vec) (hprim : Int.gcd a b = 1)
    (ha : ((Int.gcd p.1 p.2.1 : ℤ)) ∣ a) (hb : ((Int.gcd p.1 p.2.1 : ℤ)) ∣ b) :
    Int.gcd p.1 p.2.1 = 1 := by
  have hdvd : Int.gcd p.1 p.2.1 ∣ Int.gcd a b := Int.dvd_gcd ha hb
  rw [hprim] at hdvd
  exact Nat.dvd_one.mp hdvd

theorem gcd_parent_A {a b c : ℤ} (h : OnCone (a, b, c)) (hprim : Int.gcd a b = 1) :
    Int.gcd (pA (a, b, c)).1 (pA (a, b, c)).2.1 = 1 := by
  have hp : OnCone (pA (a, b, c)) := onCone_pA h
  set p := pA (a, b, c) with hpdef
  have hg1 : ((Int.gcd p.1 p.2.1 : ℤ)) ∣ p.1 := Int.gcd_dvd_left _ _
  have hg2 : ((Int.gcd p.1 p.2.1 : ℤ)) ∣ p.2.1 := Int.gcd_dvd_right _ _
  have hg3 : ((Int.gcd p.1 p.2.1 : ℤ)) ∣ p.2.2 := by
    apply gcd_dvd_hyp (a := p.1) (b := p.2.1)
    have := hp
    simp only [OnCone, qform, bil] at this
    nlinarith [this]
  refine gcd_parent_aux (a := a) (b := b) p hprim ?_ ?_
  · have hcomb : a = p.1 - 2 * p.2.1 + 2 * p.2.2 := by simp only [hpdef, pA]; ring
    rw [hcomb]
    exact dvd_add (dvd_sub hg1 (hg2.mul_left 2)) (hg3.mul_left 2)
  · have hcomb : b = 2 * p.1 - p.2.1 + 2 * p.2.2 := by simp only [hpdef, pA]; ring
    rw [hcomb]
    exact dvd_add (dvd_sub (hg1.mul_left 2) hg2) (hg3.mul_left 2)

theorem gcd_parent_B {a b c : ℤ} (h : OnCone (a, b, c)) (hprim : Int.gcd a b = 1) :
    Int.gcd (pB (a, b, c)).1 (pB (a, b, c)).2.1 = 1 := by
  have hp : OnCone (pB (a, b, c)) := onCone_pB h
  set p := pB (a, b, c) with hpdef
  have hg1 : ((Int.gcd p.1 p.2.1 : ℤ)) ∣ p.1 := Int.gcd_dvd_left _ _
  have hg2 : ((Int.gcd p.1 p.2.1 : ℤ)) ∣ p.2.1 := Int.gcd_dvd_right _ _
  have hg3 : ((Int.gcd p.1 p.2.1 : ℤ)) ∣ p.2.2 := by
    apply gcd_dvd_hyp (a := p.1) (b := p.2.1)
    have := hp
    simp only [OnCone, qform, bil] at this
    nlinarith [this]
  refine gcd_parent_aux (a := a) (b := b) p hprim ?_ ?_
  · have hcomb : a = p.1 + 2 * p.2.1 + 2 * p.2.2 := by simp only [hpdef, pB]; ring
    rw [hcomb]
    exact dvd_add (dvd_add hg1 (hg2.mul_left 2)) (hg3.mul_left 2)
  · have hcomb : b = 2 * p.1 + p.2.1 + 2 * p.2.2 := by simp only [hpdef, pB]; ring
    rw [hcomb]
    exact dvd_add (dvd_add (hg1.mul_left 2) hg2) (hg3.mul_left 2)

theorem gcd_parent_C {a b c : ℤ} (h : OnCone (a, b, c)) (hprim : Int.gcd a b = 1) :
    Int.gcd (pC (a, b, c)).1 (pC (a, b, c)).2.1 = 1 := by
  have hp : OnCone (pC (a, b, c)) := onCone_pC h
  set p := pC (a, b, c) with hpdef
  have hg1 : ((Int.gcd p.1 p.2.1 : ℤ)) ∣ p.1 := Int.gcd_dvd_left _ _
  have hg2 : ((Int.gcd p.1 p.2.1 : ℤ)) ∣ p.2.1 := Int.gcd_dvd_right _ _
  have hg3 : ((Int.gcd p.1 p.2.1 : ℤ)) ∣ p.2.2 := by
    apply gcd_dvd_hyp (a := p.1) (b := p.2.1)
    have := hp
    simp only [OnCone, qform, bil] at this
    nlinarith [this]
  refine gcd_parent_aux (a := a) (b := b) p hprim ?_ ?_
  · have hcomb : a = 2 * p.2.1 + 2 * p.2.2 - p.1 := by simp only [hpdef, pC]; ring
    rw [hcomb]
    exact dvd_sub (dvd_add (hg2.mul_left 2) (hg3.mul_left 2)) hg1
  · have hcomb : b = p.2.1 + 2 * p.2.2 - 2 * p.1 := by simp only [hpdef, pC]; ring
    rw [hcomb]
    exact dvd_sub (dvd_add hg2 (hg3.mul_left 2)) (hg1.mul_left 2)

/-! ### The base case of the descent -/

/-- A primitive Pythagorean triple with positive entries, odd first leg and hypotenuse at
most `5` is the root `(3,4,5)`. -/
theorem base_case {a b c : ℤ} (h : a ^ 2 + b ^ 2 = c ^ 2) (ha : 0 < a) (hb : 0 < b)
    (hc : 0 < c) (hc5 : c ≤ 5) (hodd : Odd a) : a = 3 ∧ b = 4 ∧ c = 5 := by
  have hac : a ≤ c := by nlinarith
  have hbc : b ≤ c := by nlinarith
  rw [Int.odd_iff] at hodd
  interval_cases c <;> interval_cases a <;> interval_cases b <;> omega

/-! ### Completeness of the Berggren tree -/

/- REPAIR: the descent below invokes `parent_exists`, which is commented out in
`Shared/BerggrenTrees/Parent_hyp_lt.lean` (its own proof quotes four further lemmas that
are absent from the catalog).  The whole block is therefore retained verbatim but
commented out; `tree_complete` is re-proved immediately afterwards from the Euclid-coordinate
descent of `MachineLearning.BerggrenEuclidParam`, which is complete and self-contained.

private theorem tree_complete_aux : ∀ N : ℕ, ∀ a b c : ℤ, c.toNat ≤ N →
    OnCone (a, b, c) → 0 < a → 0 < b → 0 < c → Odd a → Int.gcd a b = 1 →
    ∃ W : List (Vec → Vec), IsBerggrenWord W ∧ applyWord W root = (a, b, c) := by
  intro N
  induction N with
  | zero =>
      intro a b c hN _ _ _ hc _ _
      exfalso
      omega
  | succ n ih =>
      intro a b c hN hcone ha hb hc hodd hprim
      by_cases hsmall : c ≤ 5
      · obtain ⟨rfl, rfl, rfl⟩ := base_case ((onCone_iff a b c).mp hcone) ha hb hc hsmall hodd
        exact ⟨[], fun f hf => by simp at hf, rfl⟩
      · push_neg at hsmall
        have hpt : IsPT a b c := (onCone_iff a b c).mp hcone
        have hlt : -2 * a - 2 * b + 3 * c < c := parent_hyp_lt a b c ha hb hpt
        have hppos : 0 < -2 * a - 2 * b + 3 * c := parent_hyp_pos a b c ha hb hc hpt
        rcases parent_exists a b c ha hb hc hpt hsmall hprim with hcase | hcase | hcase
        · -- parent via `pA`
          obtain ⟨q1, q2, q3⟩ := hcase
          rw [← pA_eq_invB1] at q1 q2 q3
          have hpcone : OnCone (pA (a, b, c)) := onCone_pA hcone
          have hpodd : Odd (pA (a, b, c)).1 := by
            obtain ⟨t, ht⟩ := hodd
            exact ⟨t + b - c, by simp only [pA]; omega⟩
          have hprim' := gcd_parent_A hcone hprim
          have hsmaller : ((pA (a, b, c)).2.2).toNat ≤ n := by
            simp only [pA] at q3 ⊢
            omega
          obtain ⟨W, hW, hWeq⟩ := ih (pA (a, b, c)).1 (pA (a, b, c)).2.1 (pA (a, b, c)).2.2
            hsmaller (by simpa using hpcone) q1 q2 q3 hpodd (by simpa using hprim')
          refine ⟨mA :: W, ?_, ?_⟩
          · intro f hf
            rcases List.mem_cons.mp hf with rfl | hf'
            · exact Or.inl rfl
            · exact hW f hf'
          · rw [applyWord_cons, hWeq, mA_pA]
        · -- parent via `pB`
          obtain ⟨q1, q2, q3⟩ := hcase
          rw [← pB_eq_invB2] at q1 q2 q3
          have hpcone : OnCone (pB (a, b, c)) := onCone_pB hcone
          have hpodd : Odd (pB (a, b, c)).1 := by
            obtain ⟨t, ht⟩ := hodd
            exact ⟨t + b - c, by simp only [pB]; omega⟩
          have hprim' := gcd_parent_B hcone hprim
          have hsmaller : ((pB (a, b, c)).2.2).toNat ≤ n := by
            simp only [pB] at q3 ⊢
            omega
          obtain ⟨W, hW, hWeq⟩ := ih (pB (a, b, c)).1 (pB (a, b, c)).2.1 (pB (a, b, c)).2.2
            hsmaller (by simpa using hpcone) q1 q2 q3 hpodd (by simpa using hprim')
          refine ⟨mB :: W, ?_, ?_⟩
          · intro f hf
            rcases List.mem_cons.mp hf with rfl | hf'
            · exact Or.inr (Or.inl rfl)
            · exact hW f hf'
          · rw [applyWord_cons, hWeq, mB_pB]
        · -- parent via `pC`
          obtain ⟨q1, q2, q3⟩ := hcase
          rw [← pC_eq_invB3] at q1 q2 q3
          have hpcone : OnCone (pC (a, b, c)) := onCone_pC hcone
          have hpodd : Odd (pC (a, b, c)).1 := by
            obtain ⟨t, ht⟩ := hodd
            exact ⟨-t - b + c - 1, by simp only [pC]; omega⟩
          have hprim' := gcd_parent_C hcone hprim
          have hsmaller : ((pC (a, b, c)).2.2).toNat ≤ n := by
            simp only [pC] at q3 ⊢
            omega
          obtain ⟨W, hW, hWeq⟩ := ih (pC (a, b, c)).1 (pC (a, b, c)).2.1 (pC (a, b, c)).2.2
            hsmaller (by simpa using hpcone) q1 q2 q3 hpodd (by simpa using hprim')
          refine ⟨mC :: W, ?_, ?_⟩
          · intro f hf
            rcases List.mem_cons.mp hf with rfl | hf'
            · exact Or.inr (Or.inr rfl)
            · exact hW f hf'
          · rw [applyWord_cons, hWeq, mC_pC]

-/

/-- **Completeness of the Berggren tree (Barning–Hall).**  Every primitive Pythagorean
triple with positive entries and odd first leg occurs as a node of the tree. -/
theorem tree_complete {a b c : ℤ} (hcone : OnCone (a, b, c)) (ha : 0 < a) (hb : 0 < b)
    (hc : 0 < c) (hodd : Odd a) (hprim : Int.gcd a b = 1) :
    ∃ W : List (Vec → Vec), IsBerggrenWord W ∧ applyWord W root = (a, b, c) :=
  (isNode_iff a b c).mpr ⟨ha, hb, hc, (onCone_iff a b c).mp hcone, hprim, hodd⟩

/-- **A star at every primitive ideal point.**  For every primitive Pythagorean triple
`(a,b,c)` with odd first leg there is a family of nodes of the Berggren tree whose plotted
points converge to `(a/c, b/c)`.  Combined with `star_centres_dense`, the boundary circle
carries a dense set of stars. -/
theorem star_at_every_primitive_ideal_point {a b c : ℤ} (hcone : OnCone (a, b, c))
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hodd : Odd a) (hprim : Int.gcd a b = 1) :
    ∃ W : List (Vec → Vec), IsBerggrenWord W ∧ applyWord W root = (a, b, c) ∧
      Tendsto (fun j => dirx (applyWord W (mA (mC^[j] root)))) atTop (𝓝 (dirx (a, b, c))) ∧
      Tendsto (fun j => diry (applyWord W (mA (mC^[j] root)))) atTop (𝓝 (diry (a, b, c))) := by
  obtain ⟨W, hW, hWeq⟩ := tree_complete hcone ha hb hc hodd hprim
  obtain ⟨hx, hy⟩ := star_at_every_tree_node hW
  exact ⟨W, hW, hWeq, by rwa [hWeq] at hx, by rwa [hWeq] at hy⟩

end BerggrenStars