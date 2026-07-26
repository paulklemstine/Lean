/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Cryptography.GeometricCryptanalysis

/-!
# Generalized parking functions: profiles, slices, and lattice witnesses

A cumulative profile records the partial sums of the positive parameter vector
of a generalized parking function.  The definition below retains the permutation
that sorts the entries; this makes the chamber structure of the parking-function
polytope explicit.

The principal result is a lattice-slice theorem at the level of sorted chambers:
a coordinate of rank `r` can be deleted, and the remaining point is governed by
the profile obtained by deleting the same rank.  We also establish monotonicity
under enlargement of the cumulative profile, an affine dilation operation, and
a bridge from the bounding box of a parking-function polytope to short modular
kernel vectors.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer), ranked by expected impact:
1. Fixed labelled-coordinate lattice slices glue rank-deletion chambers into a
   single generalized parking-function polytope.
2. The chamber decomposition induces a shelling whose local contributions explain
   coefficientwise positivity of the Ehrhart polynomial.
3. Parking-profile boxes yield structured short vectors for modular syndrome maps,
   improving an unstructured pigeonhole radius when the matrix respects rank order.
4. Affine dilation about the all-ones vector is compatible with the integer-decomposition
   property of every generalized parking-function polytope.
5. Profile enlargement defines a functorial filtration whose successive differences
   have positive mixed-volume formulas.
6. Rank deletion commutes with affine dilation and generates a deletion recursion for
   lattice-point counts.

Experiment (Experimenter): cumulative profiles were tested in dimensions one
through four.  Deleting the same rank from a sorted vector and its profile always
preserved all coordinate inequalities.  The affine map `x ↦ 1 + t(x-1)` preserved
both order and positivity for every natural dilation factor `t`.

Analysis (Analyst): rank deletion, profile enlargement, and affine transport all
survive without convexity assumptions.  The full convex-hull identification of a
fixed labelled-coordinate slice additionally requires gluing the sorted chambers;
that geometric step is not asserted here.

Critique (Critic): the slice result is not a definitional equality: it composes a
sorting permutation with the order embedding that skips a rank.  The cryptographic
corollary genuinely invokes a finite pigeonhole theorem for modular syndromes.
The zero-dimensional edge case is isolated by using dimension `n+1` whenever a
largest profile value is required.

Synthesis (Principal Investigator): cumulative profiles provide a common language
for parking inequalities, lattice slices, affine dilations, and bounded-search
lattice attacks.
-- !-- Lab Notes -- !--
-/

open Finset BigOperators

namespace ParkingFunctionPolytope

/-- A cumulative parking profile: positive, nondecreasing rank bounds. -/
structure Profile (n : ℕ) where
  bound : Fin n → ℕ
  positive : ∀ i, 0 < bound i
  monotone : Monotone bound

/-- A vector is admitted by a profile when some permutation puts it in
nondecreasing order and every entry then lies below its rank bound. -/
def IsParking {n : ℕ} (p : Profile n) (x : Fin n → ℕ) : Prop :=
  ∃ σ : Equiv.Perm (Fin n),
    Monotone (fun i => x (σ i)) ∧
    ∀ i, 0 < x (σ i) ∧ x (σ i) ≤ p.bound i

/-- Restrict a profile to all ranks except `r`. -/
def Profile.erase {n : ℕ} (p : Profile (n + 1)) (r : Fin (n + 1)) : Profile n where
  bound i := p.bound (r.succAbove i)
  positive := fun i => p.positive (r.succAbove i)
  monotone := p.monotone.comp (Fin.succAboveOrderEmb r).monotone

/-- A witness permutation exposes the sorted chamber containing a parking vector. -/
theorem parking_has_sorted_chamber {n : ℕ} {p : Profile n} {x : Fin n → ℕ}
    (hx : IsParking p x) :
    ∃ y : Fin n → ℕ, Monotone y ∧ (∀ i, 0 < y i ∧ y i ≤ p.bound i) ∧
      ∃ σ : Equiv.Perm (Fin n), y = x ∘ σ := by
  rcases hx with ⟨σ, hmono, hbound⟩
  exact ⟨x ∘ σ, hmono, hbound, σ, rfl⟩

/-- **Rank-deletion slice theorem.**  Deleting rank `r` from a sorted chamber and
from its cumulative profile preserves every parking inequality. -/
theorem sorted_rank_slice {n : ℕ} (p : Profile (n + 1)) (r : Fin (n + 1))
    (y : Fin (n + 1) → ℕ) (hy_mono : Monotone y)
    (hy_bound : ∀ i, 0 < y i ∧ y i ≤ p.bound i) :
    IsParking (p.erase r) (fun i => y (r.succAbove i)) := by
  refine ⟨Equiv.refl _, ?_, ?_⟩
  · simpa using hy_mono.comp (Fin.succAboveOrderEmb r).monotone
  · intro i
    simpa [Profile.erase] using hy_bound (r.succAbove i)

/-- Enlarging every cumulative bound can only enlarge the set of parking vectors. -/
theorem parking_mono_profile {n : ℕ} (p q : Profile n)
    (hpq : ∀ i, p.bound i ≤ q.bound i) {x : Fin n → ℕ}
    (hx : IsParking p x) : IsParking q x := by
  rcases hx with ⟨σ, hmono, hbound⟩
  refine ⟨σ, hmono, fun i => ⟨(hbound i).1, ?_⟩⟩
  exact (hbound i).2.trans (hpq i)

/-- Affine dilation about the all-ones vector.  This is the integral map underlying
translation of dilates of parking-function polytopes. -/
def affineDilate (t x : ℕ) : ℕ := 1 + t * (x - 1)

/-- Applying an affine dilation simultaneously to a sorted vector and its
cumulative profile preserves the parking inequalities.  At factor zero both
profiles collapse to the all-ones profile. -/
theorem affineDilate_preserves_parking {n : ℕ} (p : Profile n) (x : Fin n → ℕ)
    (t : ℕ) (hx : IsParking p x) :
    ∃ q : Profile n,
      (q.bound = fun i => affineDilate t (p.bound i)) ∧
      IsParking q (fun i => affineDilate t (x i)) := by
  let q : Profile n :=
    { bound := fun i => affineDilate t (p.bound i)
      positive := fun i => by simp [affineDilate]
      monotone := by
        intro i j hij
        exact Nat.add_le_add_left
          (Nat.mul_le_mul_left t (Nat.sub_le_sub_right (p.monotone hij) 1)) 1 }
  refine ⟨q, rfl, ?_⟩
  rcases hx with ⟨σ, hmono, hbound⟩
  refine ⟨σ, ?_, ?_⟩
  · intro i j hij
    exact Nat.add_le_add_left
      (Nat.mul_le_mul_left t (Nat.sub_le_sub_right (hmono hij) 1)) 1
  · intro i
    constructor
    · simp [affineDilate]
    · exact Nat.add_le_add_left
        (Nat.mul_le_mul_left t (Nat.sub_le_sub_right (hbound i).2 1)) 1

/-- Every parking vector lies in the positive cube cut out by the largest
cumulative profile value. -/
theorem parking_coordinate_bound {n : ℕ} (p : Profile (n + 1))
    {x : Fin (n + 1) → ℕ} (hx : IsParking p x) (j : Fin (n + 1)) :
    0 < x j ∧ x j ≤ p.bound (Fin.last n) := by
  rcases hx with ⟨σ, hmono, hbound⟩
  let i : Fin (n + 1) := σ.symm j
  have hσ : σ i = j := Equiv.apply_symm_apply σ j
  constructor
  · simpa [hσ] using (hbound i).1
  · rw [← hσ]
    exact (hbound i).2.trans (p.monotone (Fin.le_last i))

/-- **Parking-to-SIS bridge.**  The largest cumulative parking bound supplies a
search radius.  If that box contains more points than the syndrome space, a
nonzero short modular-kernel vector exists. -/
theorem parking_box_yields_sis_witness {m n q : ℕ}
    (p : Profile (n + 1)) (hq : 0 < q)
    (A : Matrix (Fin m) (Fin (n + 1)) ℤ)
    (hsize : q ^ m < (2 * p.bound (Fin.last n) + 1) ^ (n + 1)) :
    ∃ z : Fin (n + 1) → ℤ,
      z ≠ 0 ∧
      (∀ i, |z i| ≤ 2 * (p.bound (Fin.last n) : ℤ)) ∧
      (∀ j : Fin m, (∑ i, A j i * z i : ℤ) ≡ 0 [ZMOD q]) := by
  exact bounded_box_sis_witness hq A hsize

end ParkingFunctionPolytope