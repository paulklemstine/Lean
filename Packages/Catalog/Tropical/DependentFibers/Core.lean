import Mathlib

/-!
# Fibres of a one-variable tropical polynomial: the core structure theory

A tropical (min-plus) polynomial of degree `n` with coefficient vector `c : ℕ → ℚ` is
the piecewise-linear concave function

`tropVal n c x = min_{0 ≤ i ≤ n} (c i + i · x)`.

Its **fibre at `x`** is the set of indices realising the minimum,

`fiber n c x = {i ≤ n | c i + i·x = tropVal n c x}`.

This is the combinatorial datum attached to a point of the tropical line: the *support
of the tropical evaluation*, whose cardinality is the local multiplicity (the lattice
length of the corresponding edge of the Newton polygon).  The family
`x ↦ fiber n c x` is the "witness family" of the research thread; the question the
thread asks is whether it can be *pointwise equivalent to a constant family*, i.e.
whether all its fibres can have the same cardinality.

This file develops the structure theory needed for that question:

* `tropVal_le`, `fiber_nonempty`, `mem_fiber_iff` — basic calculus of the fibre;
* `fiber_order` — the **monotone ordering law**: if `x < y` then every index in the
  fibre at `y` is `≤` every index in the fibre at `x` (slopes decrease as the argument
  increases);
* `fiber_inter_subsingleton` — two distinct points share at most one index;
* `multiplicity_sum_le` — the **degree bound** (upper half of the tropical fundamental
  theorem): for *any* finite set `S` of points, `∑_{x ∈ S} (|fiber x| − 1) ≤ n`;
* `multiplicity_sum_eq_deg` — sharpness of the degree bound.
-/

namespace TropicalDependentFibers

open Finset

/-- `range (n+1)` is never empty; the index `0` always lies in it. -/
theorem range_succ_nonempty (n : ℕ) : (range (n + 1)).Nonempty :=
  ⟨0, mem_range.mpr (Nat.succ_pos n)⟩

/-- The **tropical evaluation** `min_{i ≤ n} (c i + i·x)` of the degree-`n` min-plus
polynomial with coefficients `c`. -/
def tropVal (n : ℕ) (c : ℕ → ℚ) (x : ℚ) : ℚ :=
  (range (n + 1)).inf' (range_succ_nonempty n) fun i => c i + (i : ℚ) * x

/-- The **fibre** of the tropical polynomial at `x`: the set of monomials attaining the
minimum.  Its cardinality is the local multiplicity at `x`. -/
def fiber (n : ℕ) (c : ℕ → ℚ) (x : ℚ) : Finset ℕ :=
  (range (n + 1)).filter fun i => c i + (i : ℚ) * x = tropVal n c x

theorem tropVal_le {n i : ℕ} (c : ℕ → ℚ) (x : ℚ) (hi : i ≤ n) :
    tropVal n c x ≤ c i + (i : ℚ) * x :=
  Finset.inf'_le _ (mem_range.mpr (by omega))

theorem le_tropVal {n : ℕ} {c : ℕ → ℚ} {x v : ℚ} (h : ∀ i ≤ n, v ≤ c i + (i : ℚ) * x) :
    v ≤ tropVal n c x :=
  Finset.le_inf' _ _ fun i hi => h i (by simpa [Nat.lt_succ_iff] using mem_range.mp hi)

/-- Membership in the fibre: `i` is in the fibre at `x` iff it is a legal index that
minimises the monomial value. -/
theorem mem_fiber_iff {n i : ℕ} {c : ℕ → ℚ} {x : ℚ} :
    i ∈ fiber n c x ↔ i ≤ n ∧ ∀ j ≤ n, c i + (i : ℚ) * x ≤ c j + (j : ℚ) * x := by
  constructor
  · intro h
    rw [fiber, mem_filter, mem_range] at h
    refine ⟨by omega, fun j hj => ?_⟩
    rw [h.2]
    exact tropVal_le c x hj
  · rintro ⟨hi, hmin⟩
    rw [fiber, mem_filter, mem_range]
    exact ⟨by omega, le_antisymm (le_tropVal hmin) (tropVal_le c x hi)⟩

theorem fiber_subset (n : ℕ) (c : ℕ → ℚ) (x : ℚ) : fiber n c x ⊆ range (n + 1) :=
  filter_subset _ _

theorem fiber_le {n i : ℕ} {c : ℕ → ℚ} {x : ℚ} (hi : i ∈ fiber n c x) : i ≤ n :=
  (mem_fiber_iff.mp hi).1

/-- The fibre is never empty: the minimum is attained. -/
theorem fiber_nonempty (n : ℕ) (c : ℕ → ℚ) (x : ℚ) : (fiber n c x).Nonempty := by
  obtain ⟨i, hi, hmin⟩ :=
    Finset.exists_mem_eq_inf' (range_succ_nonempty n) fun i => c i + (i : ℚ) * x
  exact ⟨i, by rw [fiber, mem_filter]; exact ⟨hi, hmin.symm⟩⟩

theorem fiber_card_pos (n : ℕ) (c : ℕ → ℚ) (x : ℚ) : 0 < (fiber n c x).card :=
  Finset.card_pos.mpr (fiber_nonempty n c x)

theorem fiber_card_le (n : ℕ) (c : ℕ → ℚ) (x : ℚ) : (fiber n c x).card ≤ n + 1 := by
  simpa using Finset.card_le_card (fiber_subset n c x)

/-- **Monotone ordering law.**  The winning exponents decrease as the argument grows:
if `x < y`, then every index of the fibre at `y` is at most every index of the fibre
at `x`.  This is the combinatorial shadow of concavity of `tropVal`. -/
theorem fiber_order {n : ℕ} {c : ℕ → ℚ} {x y : ℚ} (hxy : x < y) {i j : ℕ}
    (hi : i ∈ fiber n c x) (hj : j ∈ fiber n c y) : j ≤ i := by
  rw [mem_fiber_iff] at hi hj
  have h1 := hi.2 j hj.1
  have h2 := hj.2 i hi.1
  by_contra hcon
  push_neg at hcon
  have hcast : (i : ℚ) < (j : ℚ) := by exact_mod_cast hcon
  nlinarith [sub_pos.mpr hcast, sub_pos.mpr hxy]

/-- Two distinct points share at most one winning exponent: a monomial pair can tie at
only one place.  (Equivalently: two distinct affine functions meet once.) -/
theorem fiber_inter_subsingleton {n : ℕ} {c : ℕ → ℚ} {x y : ℚ} (hxy : x ≠ y) :
    ((fiber n c x) ∩ (fiber n c y)).card ≤ 1 := by
  rw [Finset.card_le_one]
  intro a ha b hb
  rw [mem_inter] at ha hb
  rcases lt_or_gt_of_ne hxy with h | h
  · exact le_antisymm (fiber_order h hb.1 ha.2) (fiber_order h ha.1 hb.2)
  · exact le_antisymm (fiber_order h hb.2 ha.1) (fiber_order h ha.2 hb.1)

/-! ## Local multiplicity and the degree bound -/

/-- The smallest winning exponent at `x`. -/
def loIdx (n : ℕ) (c : ℕ → ℚ) (x : ℚ) : ℕ := (fiber n c x).min' (fiber_nonempty n c x)

/-- The largest winning exponent at `x`. -/
def hiIdx (n : ℕ) (c : ℕ → ℚ) (x : ℚ) : ℕ := (fiber n c x).max' (fiber_nonempty n c x)

theorem loIdx_le_hiIdx (n : ℕ) (c : ℕ → ℚ) (x : ℚ) : loIdx n c x ≤ hiIdx n c x :=
  Finset.min'_le_max' _ _

theorem hiIdx_le (n : ℕ) (c : ℕ → ℚ) (x : ℚ) : hiIdx n c x ≤ n :=
  fiber_le ((fiber n c x).max'_mem (fiber_nonempty n c x))

/-- The multiplicity at a point is bounded by the lattice length of the index window
it occupies. -/
theorem fiber_card_le_window (n : ℕ) (c : ℕ → ℚ) (x : ℚ) :
    (fiber n c x).card ≤ hiIdx n c x - loIdx n c x + 1 := by
  have hsub : fiber n c x ⊆ Finset.Icc (loIdx n c x) (hiIdx n c x) := by
    intro i hi
    exact mem_Icc.mpr ⟨Finset.min'_le _ _ hi, Finset.le_max' _ _ hi⟩
  have h := Finset.card_le_card hsub
  have hlh := Finset.min'_le_max' (fiber n c x) (fiber_nonempty n c x)
  rw [Nat.card_Icc] at h
  simp only [loIdx, hiIdx] at *
  omega

/-- Windows at ordered points are nested back-to-back: `hiIdx y ≤ loIdx x` for `x < y`. -/
theorem hiIdx_le_loIdx_of_lt {n : ℕ} {c : ℕ → ℚ} {x y : ℚ} (hxy : x < y) :
    hiIdx n c y ≤ loIdx n c x := by
  exact fiber_order hxy ((fiber n c x).min'_mem _) ((fiber n c y).max'_mem _)

/-- A weaker, uniform form of the previous lemma valid for `x ≤ y`. -/
theorem loIdx_le_hiIdx_of_le {n : ℕ} {c : ℕ → ℚ} {x y : ℚ} (hxy : x ≤ y) :
    loIdx n c y ≤ hiIdx n c x := by
  rcases eq_or_lt_of_le hxy with rfl | h
  · exact loIdx_le_hiIdx n c x
  · exact le_trans (le_trans (loIdx_le_hiIdx n c y) (hiIdx_le_loIdx_of_lt h))
      (loIdx_le_hiIdx n c x)

/-- **Telescoping bound.**  For a nonempty finite set of points the total multiplicity
excess is bounded by the index window spanned between the extreme points. -/
theorem sum_mult_le_window (n : ℕ) (c : ℕ → ℚ) :
    ∀ S : Finset ℚ, ∀ hS : S.Nonempty,
      ∑ x ∈ S, ((fiber n c x).card - 1) ≤ hiIdx n c (S.min' hS) - loIdx n c (S.max' hS) := by
  intro S
  induction S using Finset.strongInduction with
  | _ S ih =>
    intro hS
    set a := S.min' hS with ha
    have haS : a ∈ S := S.min'_mem hS
    have hsplit : ((fiber n c a).card - 1) + ∑ x ∈ S.erase a, ((fiber n c x).card - 1)
        = ∑ x ∈ S, ((fiber n c x).card - 1) :=
      Finset.add_sum_erase S (fun x => (fiber n c x).card - 1) haS
    by_cases hS' : (S.erase a).Nonempty
    · set b := (S.erase a).min' hS' with hb
      set d := (S.erase a).max' hS' with hd
      have hbS : b ∈ S.erase a := (S.erase a).min'_mem hS'
      have hdS : d ∈ S.erase a := (S.erase a).max'_mem hS'
      have hab : a < b := by
        have hbmem : b ∈ S := Finset.mem_of_mem_erase hbS
        have hne : b ≠ a := Finset.ne_of_mem_erase hbS
        exact lt_of_le_of_ne (S.min'_le b hbmem) (Ne.symm hne)
      have hmax : S.max' hS = d := by
        refine le_antisymm ?_ (S.le_max' d (Finset.mem_of_mem_erase hdS))
        refine Finset.max'_le _ _ _ fun y hy => ?_
        by_cases hya : y = a
        · subst hya
          exact le_trans (le_of_lt hab) ((S.erase a).le_max' b hbS)
        · exact (S.erase a).le_max' y (Finset.mem_erase.mpr ⟨hya, hy⟩)
      have hrec := ih (S.erase a) (Finset.erase_ssubset haS) hS'
      rw [← hb, ← hd] at hrec
      have hbd : loIdx n c d ≤ hiIdx n c b :=
        loIdx_le_hiIdx_of_le ((S.erase a).min'_le d hdS)
      have hchain : hiIdx n c b ≤ loIdx n c a := hiIdx_le_loIdx_of_lt hab
      have hwin := fiber_card_le_window n c a
      have hlh := loIdx_le_hiIdx n c a
      rw [hmax, ← hsplit]
      omega
    · have hempty : S.erase a = ∅ := Finset.not_nonempty_iff_eq_empty.mp hS'
      have hsingle : S = {a} := by
        refine Finset.eq_singleton_iff_unique_mem.mpr ⟨haS, fun y hy => ?_⟩
        by_contra hne
        exact absurd (Finset.mem_erase.mpr ⟨hne, hy⟩) (by simp [hempty])
      have hmax : S.max' hS = a :=
        le_antisymm (Finset.max'_le _ _ _ fun y hy => le_of_eq (by
          have hy' : y ∈ ({a} : Finset ℚ) := hsingle ▸ hy
          simpa using hy')) (S.le_max' a haS)
      rw [hmax, ← hsplit, hempty]
      have := fiber_card_le_window n c a
      simp only [Finset.sum_empty, add_zero]
      omega

/-- **Degree bound (upper half of the tropical fundamental theorem).**  The total
multiplicity excess of a degree-`n` tropical polynomial over *any* finite set of
points is at most `n`: corners can be many, but they cost lattice length, and there is
only `n` of it. -/
theorem multiplicity_sum_le (n : ℕ) (c : ℕ → ℚ) (S : Finset ℚ) :
    ∑ x ∈ S, ((fiber n c x).card - 1) ≤ n := by
  by_cases hS : S.Nonempty
  · have h := sum_mult_le_window n c S hS
    have := hiIdx_le n c (S.min' hS)
    omega
  · rw [Finset.not_nonempty_iff_eq_empty.mp hS]
    simp

/-! ## Sharpness: the totally degenerate polynomial saturates the degree bound -/

/-- For the all-zero coefficient vector every monomial ties at `x = 0`. -/
theorem fiber_zero_zero (n : ℕ) : fiber n (fun _ => 0) 0 = range (n + 1) := by
  have hval : tropVal n (fun _ => 0) 0 = 0 := by
    refine le_antisymm ?_ (le_tropVal fun i _ => by simp)
    simpa using tropVal_le (n := n) (fun _ => (0 : ℚ)) 0 (Nat.zero_le n)
  refine Finset.filter_true_of_mem fun i _ => ?_
  simp [hval]

/-- The degree bound is attained: the totally degenerate polynomial has one point of
multiplicity `n + 1`. -/
theorem multiplicity_sum_eq_deg (n : ℕ) :
    ∑ x ∈ ({0} : Finset ℚ), ((fiber n (fun _ => 0) x).card - 1) = n := by
  simp [fiber_zero_zero n]

end TropicalDependentFibers