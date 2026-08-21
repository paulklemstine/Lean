import MachineLearning.BerggrenSilverUnits
import MachineLearning.BerggrenBoundaryHecke

/-!
# The unit locus of the Berggren tree is a single geodesic

`MachineLearning.BerggrenSilverUnits` shows that the all-`B` spine of the Berggren tree is
carried by the silver coordinate `ζ(a,b,c) = (a+b) + c√2` onto the odd powers of the
fundamental unit of `ℤ[√2]`.  This file proves the exact converse — a complete
classification of the nodes at which the `ℚ(√2)`-structure appears — and extracts the local
Euler factor attached to the hyperbolic eigenvalues.

## The norm identity

For a node on the light cone,

  `N(ζ(a,b,c)) = (a+b)² − 2c² = −(a−b)²`      (`zeta_norm_eq_neg_sq`)

because `a² + b² = c²`.  Hence `ζ(v)` is a unit of `ℤ[√2]` **iff the triple is
almost-isoceles**, `|a − b| = 1` (`isUnit_zeta_iff`).

## The classification

Along the tree the three generators change the leg difference by

  `mA : a − b ↦ −(a + b)`,  `mB : a − b ↦ −(a − b)`,  `mC : a − b ↦ a + b`,

so the `B`-letter preserves the unit property and the letters `A`, `C` destroy it
irrevocably (`unit_locus_eq_spine`): a node of the tree has unit silver coordinate **iff its
address is a word in the single letter `B`**.  In the 3-adic Cantor boundary of the tree,
the `ℚ(√2)`-locus is therefore the single point `BBBB…` (`boundary_unit_locus_singleton`),
a set of Hausdorff dimension `0` inside a boundary of dimension `1` (in the natural
`log 3`-normalization).  This is the precise sense in which the moonshot conjecture fails:
the real quadratic field lives on one geodesic axis, not on the boundary.

## The Euler factor

The hypotenuses of the spine satisfy the Pell recursion `c_{n+2} = 6c_{n+1} − c_n`
(`spine_hyp_recursion`), whose reciprocal characteristic polynomial factors over `ℤ[√2]` as

  `1 − 6X + X² = (1 − (3+2√2)X)(1 − (3−2√2)X)`   (`local_euler_factor`),

exactly the shape of an unramified local `L`-factor with Satake parameters `3 ± 2√2`.  The
parameters have product `1` rather than the norm `2` of the ramified prime above `2`
(`BerggrenStars.Boundary.satake_product_ne_two`), so this Euler factor is that of a
*non-tempered, non-unitarily-normalized* datum: it is the `L`-factor of a real quadratic
unit, not of a Hilbert modular form.
-/

namespace BerggrenStars

namespace UnitLocus

open Silver

/-! ### Admissible nodes -/

/-- The geometric invariant satisfied by every node of the Berggren tree: a genuine
right triangle with positive legs shorter than the hypotenuse. -/
def Adm (v : Vec) : Prop := 0 < v.1 ∧ 0 < v.2.1 ∧ v.1 < v.2.2 ∧ v.2.1 < v.2.2

theorem adm_root : Adm root := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> simp [root]

theorem adm_mA {v : Vec} (h : Adm v) : Adm (mA v) := by
  obtain ⟨h1, h2, h3, h4⟩ := h
  refine ⟨?_, ?_, ?_, ?_⟩ <;> simp only [mA] <;> linarith

theorem adm_mB {v : Vec} (h : Adm v) : Adm (mB v) := by
  obtain ⟨h1, h2, h3, h4⟩ := h
  refine ⟨?_, ?_, ?_, ?_⟩ <;> simp only [mB] <;> linarith

theorem adm_mC {v : Vec} (h : Adm v) : Adm (mC v) := by
  obtain ⟨h1, h2, h3, h4⟩ := h
  refine ⟨?_, ?_, ?_, ?_⟩ <;> simp only [mC] <;> linarith

theorem adm_act (x : Gen) {v : Vec} (h : Adm v) : Adm (Gen.act x v) := by
  cases x
  · exact adm_mA h
  · exact adm_mB h
  · exact adm_mC h

/-- Every node of the tree is admissible. -/
theorem adm_applyGens (g : List Gen) : Adm (applyGens g root) := by
  induction g with
  | nil => exact adm_root
  | cons x t ih => exact adm_act x ih

theorem onCone_applyGens (g : List Gen) : OnCone (applyGens g root) := by
  induction g with
  | nil => exact onCone_root
  | cons x t ih =>
      cases x
      · exact onCone_mA ih
      · exact onCone_mB ih
      · exact onCone_mC ih

/-! ### The norm identity and the unit criterion -/

/-- On the light cone the `ℤ[√2]`-norm of the silver coordinate is minus the square of the
leg difference. -/
theorem zeta_norm_eq_neg_sq {v : Vec} (h : OnCone v) :
    (zeta v).norm = -((v.1 - v.2.1) ^ 2) := by
  obtain ⟨a, b, c⟩ := v
  rw [onCone_iff] at h
  simp only [zeta, Zsqrtd.norm_def]
  nlinarith [h]

/-- **Unit criterion.**  A node of the light cone has unit silver coordinate exactly when
its two legs differ by one: the almost-isoceles Pythagorean triples. -/
theorem isUnit_zeta_iff {v : Vec} (h : OnCone v) :
    IsUnit (zeta v) ↔ (v.1 - v.2.1) ^ 2 = 1 := by
  rw [← Zsqrtd.norm_eq_one_iff, zeta_norm_eq_neg_sq h]
  constructor
  · intro hn
    have : ((v.1 - v.2.1) ^ 2).natAbs = 1 := by simpa using hn
    have hpos : (0 : ℤ) ≤ (v.1 - v.2.1) ^ 2 := sq_nonneg _
    omega
  · intro hn
    rw [hn]
    norm_num

/-! ### How the three generators move the leg difference -/

theorem diff_mA (v : Vec) : (mA v).1 - (mA v).2.1 = -(v.1 + v.2.1) := by
  simp only [mA]; ring

theorem diff_mB (v : Vec) : (mB v).1 - (mB v).2.1 = -(v.1 - v.2.1) := by
  simp only [mB]; ring

theorem diff_mC (v : Vec) : (mC v).1 - (mC v).2.1 = v.1 + v.2.1 := by
  simp only [mC]; ring

/-- The `A`-child of an admissible node is never a unit: the leg sum is at least `2`. -/
theorem not_isUnit_mA {v : Vec} (hadm : Adm v) (h : OnCone v) : ¬ IsUnit (zeta (mA v)) := by
  rw [isUnit_zeta_iff (onCone_mA h), diff_mA]
  intro hc
  obtain ⟨h1, h2, _, _⟩ := hadm
  nlinarith [hc]

/-- The `C`-child of an admissible node is never a unit. -/
theorem not_isUnit_mC {v : Vec} (hadm : Adm v) (h : OnCone v) : ¬ IsUnit (zeta (mC v)) := by
  rw [isUnit_zeta_iff (onCone_mC h), diff_mC]
  intro hc
  obtain ⟨h1, h2, _, _⟩ := hadm
  nlinarith [hc]

/-- The `B`-child is a unit exactly when its parent is: the `B`-letter is the unit-preserving
letter of the alphabet. -/
theorem isUnit_mB_iff {v : Vec} (h : OnCone v) :
    IsUnit (zeta (mB v)) ↔ IsUnit (zeta v) := by
  rw [isUnit_zeta_iff (onCone_mB h), isUnit_zeta_iff h, diff_mB]
  constructor <;> intro hc <;> nlinarith [hc]

/-! ### The classification -/

/-- **Main classification theorem.**  A node of the Berggren tree has unit silver
coordinate — equivalently, is an almost-isoceles triple, equivalently solves the negative
Pell equation — if and only if its address is a word in the single letter `B`. -/
theorem unit_locus_eq_spine (g : List Gen) :
    IsUnit (zeta (applyGens g root)) ↔ ∀ x ∈ g, x = Gen.B := by
  induction g with
  | nil =>
      constructor
      · intro _ x hx; simp at hx
      · intro _
        rw [applyGens_nil, zeta_root]
        exact silver_isUnit.pow _
  | cons x t ih =>
      have hadm := adm_applyGens t
      have hcone := onCone_applyGens t
      cases x
      · constructor
        · intro hu
          exact absurd hu (not_isUnit_mA hadm hcone)
        · intro hall
          exact absurd (hall Gen.A (by simp)) (by simp)
      · rw [show applyGens (Gen.B :: t) root = mB (applyGens t root) from rfl,
          isUnit_mB_iff hcone, ih]
        constructor
        · intro hall y hy
          rcases List.mem_cons.mp hy with rfl | hy'
          · rfl
          · exact hall y hy'
        · intro hall y hy
          exact hall y (List.mem_cons_of_mem _ hy)
      · constructor
        · intro hu
          exact absurd hu (not_isUnit_mC hadm hcone)
        · intro hall
          exact absurd (hall Gen.C (by simp)) (by simp)

/-- The unit locus, described positively: it is the set of `B`-words, i.e. the spine. -/
theorem applyGens_replicate_B (n : ℕ) : applyGens (List.replicate n Gen.B) root = spine n := by
  induction n with
  | zero => rfl
  | succ k ih =>
      rw [List.replicate_succ, applyGens_cons, ih]
      rfl

theorem unit_locus_eq_spine' (g : List Gen) :
    IsUnit (zeta (applyGens g root)) ↔ applyGens g root = spine g.length := by
  rw [unit_locus_eq_spine]
  constructor
  · intro hall
    have hg : g = List.replicate g.length Gen.B := List.eq_replicate_iff.mpr ⟨rfl, hall⟩
    conv_lhs => rw [hg]
    rw [applyGens_replicate_B]
  · intro heq x hx
    by_contra hne
    -- a non-`B` letter forces a non-unit, while the spine is a unit
    have hu : IsUnit (zeta (spine g.length)) := by
      rw [zeta_spine]; exact silver_isUnit.pow _
    rw [← heq] at hu
    rw [unit_locus_eq_spine] at hu
    exact hne (hu x hx)

/-! ### The unit locus in the boundary is a single point -/

open Boundary

/-- **The `ℚ(√2)`-locus of the boundary is a singleton.**  An infinite address all of whose
finite truncations are unit nodes must be the constant word `BBB…`; the unit locus of the
3-adic Cantor boundary is one point, of Hausdorff dimension `0`. -/
theorem boundary_unit_locus_singleton :
    {w : Bdry | ∀ n : ℕ, IsUnit (zeta (applyGens (List.ofFn (fun i : Fin n => w i)) root))}
      = {fun _ => Gen.B} := by
  ext w
  simp only [Set.mem_setOf_eq, Set.mem_singleton_iff]
  constructor
  · intro h
    funext k
    have hk := h (k + 1)
    rw [unit_locus_eq_spine] at hk
    exact hk (w k) (List.mem_ofFn.mpr ⟨⟨k, Nat.lt_succ_self k⟩, rfl⟩)
  · rintro rfl n
    rw [unit_locus_eq_spine]
    intro x hx
    obtain ⟨i, rfl⟩ := List.mem_ofFn.mp hx
    rfl

/-! ### The local Euler factor of the hyperbolic eigenvalues -/

/-- The hypotenuse sequence of the spine satisfies the Pell recursion. -/
theorem spine_hyp_recursion (n : ℕ) :
    (spine (n + 2)).2.2 = 6 * (spine (n + 1)).2.2 - (spine n).2.2 := by
  have h1 : spine (n + 1) = mB (spine n) := rfl
  have h2 : spine (n + 2) = mB (spine (n + 1)) := rfl
  have hp : (spine (n + 1)).1 + (spine (n + 1)).2.1
      = 3 * ((spine n).1 + (spine n).2.1) + 4 * (spine n).2.2 := by
    rw [h1]; simp only [mB]; ring
  have hc : (spine (n + 1)).2.2 = 2 * ((spine n).1 + (spine n).2.1) + 3 * (spine n).2.2 := by
    rw [h1]; simp only [mB]; ring
  have hc2 : (spine (n + 2)).2.2
      = 2 * ((spine (n + 1)).1 + (spine (n + 1)).2.1) + 3 * (spine (n + 1)).2.2 := by
    rw [h2]; simp only [mB]; ring
  rw [hc2, hp]
  linarith [hc]

open Polynomial

/-- **The local Euler factor.**  Over `ℤ[√2]` the reciprocal characteristic polynomial of
the Pell recursion factors through the two hyperbolic eigenvalues `3 ± 2√2`. -/
theorem local_euler_factor :
    (1 - C lam * X) * (1 - C (⟨3, -2⟩ : ℤ√2) * X) = 1 - C (6 : ℤ√2) * X + X ^ 2 := by
  have h1 : lam * (⟨3, -2⟩ : ℤ√2) = 1 := eigen_product_one
  have h2 : lam + (⟨3, -2⟩ : ℤ√2) = (6 : ℤ√2) := eigen_sum_six
  have : (1 - C lam * X) * (1 - C (⟨3, -2⟩ : ℤ√2) * X)
      = 1 - C (lam + (⟨3, -2⟩ : ℤ√2)) * X + C (lam * (⟨3, -2⟩ : ℤ√2)) * X ^ 2 := by
    simp only [map_add, map_mul]
    ring
  rw [this, h1, h2]
  simp

/-- The same factor over `ℝ`, in the shape of an unramified local `L`-factor with Satake
parameters `3 ± 2√2` (note that their product is `1`, so this is *not* the `L`-factor of a
unitary automorphic representation at a prime of norm `2`). -/
theorem local_euler_factor_real (x : ℝ) :
    (1 - (3 + 2 * Real.sqrt 2) * x) * (1 - (3 - 2 * Real.sqrt 2) * x) = 1 - 6 * x + x ^ 2 := by
  have hs : Real.sqrt 2 * Real.sqrt 2 = 2 := Real.mul_self_sqrt (by norm_num)
  nlinarith [hs]

end UnitLocus

end BerggrenStars