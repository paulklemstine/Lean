import Cryptography.MarkoffTransfer.MarkoffFreeBinary

/-!
# Cycle 2: What the Transfer *Does* Buy on the Markoff Side

Cycle 1 showed that the Berggren ternary tree and the Markoff binary tree are not
isomorphic, and located the two obstructions (ternary vs binary branching; silver vs
golden growth).  This file harvests the parts of the Berggren methodology — descent,
unique parents, and the "one coordinate determines the rest" style of argument — that
*do* apply to the Markoff tree, and pins down the exact reason the Berggren *linear*
(Lorentz) machinery cannot be imported.

## Main results

* `markoff_middle_unique` — **the smallest and largest entries determine the middle one.**
  Two ordered Markoff triples with the same outer pair are equal.
* `markoff_unique_of_min_one` — consequently, for a fixed top entry there is at most one
  ordered Markoff triple with smallest entry `1`.
* `markoff_uniqueness_iff_min_determined` — a **reduction of the (open) Markoff uniqueness
  conjecture**: uniqueness of the whole triple given the maximum is equivalent to
  uniqueness of the *minimum* given the maximum.  The middle entry is free of charge.
* `MReach.isCoprime` — every tree triple is pairwise coprime (transfer of the Berggren
  primitivity invariant, proved by induction along the tree).
* `vieta_not_linear` — **the linear obstruction.**  The Berggren moves act on triples by
  integer matrices preserving the Lorentz form `a² + b² - c²`
  (`BerggrenSpectral.berg_isometry_*`).  No matrix whatsoever implements the Markoff Vieta
  move on the Markoff surface: the move is genuinely quadratic.  This is the structural
  reason the Lorentz/hyperbolic half of the Berggren machinery cannot be transported.
-/

namespace MarkoffTransfer

/-! ## The outer pair determines the middle entry -/

/-- **Rigidity of the middle entry.**  If `(x, y, z)` and `(x, y', z)` are ordered positive
Markoff triples with the same smallest and largest entries, then `y = y'`.

Proof: `y` and `y'` are roots of `t² - 3xz·t + (x² + z²)`; if they were distinct they would
be *the* two roots, hence `y·y' = x² + z² > z²`, contradicting `y, y' ≤ z`. -/
theorem markoff_middle_unique {x y y' z : ℤ} (h : IsMarkoff x y z) (h' : IsMarkoff x y' z)
    (hx : 0 < x) (hyz : y ≤ z) (hyz' : y' ≤ z) (hy : 0 < y) : y = y' := by
  rw [isMarkoff_iff] at h h'
  by_contra hne
  -- distinct roots of the same quadratic: their sum is `3xz`
  have hsum : y + y' = 3 * x * z := by
    have hfac : (y - y') * (y + y' - 3 * x * z) = 0 := by nlinarith [h, h']
    rcases mul_eq_zero.mp hfac with h₁ | h₁
    · exact absurd (by linarith : y = y') hne
    · linarith
  -- hence their product is `x² + z²`
  have hprod : y * y' = x ^ 2 + z ^ 2 := by nlinarith [h, hsum]
  nlinarith [hprod, hyz, hyz', hy, hx]

/-- For a fixed largest entry there is at most one ordered Markoff triple with smallest
entry `1`. -/
theorem markoff_unique_of_min_one {y y' z : ℤ} (h : IsMarkoff 1 y z) (h' : IsMarkoff 1 y' z)
    (hyz : y ≤ z) (hyz' : y' ≤ z) (hy : 0 < y) : y = y' :=
  markoff_middle_unique h h' one_pos hyz hyz' hy

/-! ## Reduction of the Markoff uniqueness conjecture -/

/-- The Markoff uniqueness conjecture (open): an ordered positive Markoff triple is
determined by its largest entry. -/
def MarkoffUniqueness : Prop :=
  ∀ x y x' y' z : ℤ, 0 < x → x ≤ y → y ≤ z → IsMarkoff x y z →
    0 < x' → x' ≤ y' → y' ≤ z → IsMarkoff x' y' z → x = x' ∧ y = y'

/-- The weaker statement that only the *smallest* entry is determined by the largest. -/
def MarkoffMinUniqueness : Prop :=
  ∀ x y x' y' z : ℤ, 0 < x → x ≤ y → y ≤ z → IsMarkoff x y z →
    0 < x' → x' ≤ y' → y' ≤ z → IsMarkoff x' y' z → x = x'

/-- **Reduction theorem.**  The full Markoff uniqueness conjecture is equivalent to the
statement that the maximum determines the *minimum*: the middle entry is then forced. -/
theorem markoff_uniqueness_iff_min_determined : MarkoffUniqueness ↔ MarkoffMinUniqueness := by
  constructor
  · intro H x y x' y' z hx hxy hyz hM hx' hxy' hyz' hM'
    exact (H x y x' y' z hx hxy hyz hM hx' hxy' hyz' hM').1
  · intro H x y x' y' z hx hxy hyz hM hx' hxy' hyz' hM'
    have hxx : x = x' := H x y x' y' z hx hxy hyz hM hx' hxy' hyz' hM'
    subst hxx
    exact ⟨rfl, markoff_middle_unique hM hM' hx hyz hyz' (lt_of_lt_of_le hx hxy)⟩

/-! ## Pairwise coprimality along the tree -/

theorem isCoprime_vieta {x z : ℤ} (y : ℤ) (h : IsCoprime x z) : IsCoprime x (3 * x * y - z) := by
  have h1 : IsCoprime x (-z) := h.neg_right
  have h2 : IsCoprime x (-z + x * (3 * y)) := h1.add_mul_left_right (3 * y)
  have h3 : -z + x * (3 * y) = 3 * x * y - z := by ring
  rwa [h3] at h2

/-- **Primitivity transfer.**  Every triple of the Markoff tree is pairwise coprime — the
Markoff analogue of the primitivity of Berggren's Pythagorean triples, proved by the same
"invariant along the tree" method. -/
theorem MReach.isCoprime {x y z : ℤ} (h : MReach x y z) :
    IsCoprime x y ∧ IsCoprime y z ∧ IsCoprime x z := by
  induction h with
  | root => exact ⟨isCoprime_one_left, isCoprime_one_left, isCoprime_one_left⟩
  | @vieta x y z _ ih =>
      obtain ⟨hxy, hyz, hxz⟩ := ih
      have hmid : IsCoprime y (MarkoffTransfer.vieta x y z) := by
        have h1 := isCoprime_vieta (x := y) (z := z) x hyz
        have heq : 3 * y * x - z = MarkoffTransfer.vieta x y z := by
          unfold MarkoffTransfer.vieta; ring
        rwa [heq] at h1
      have hout : IsCoprime x (MarkoffTransfer.vieta x y z) := by
        have h1 := isCoprime_vieta (x := x) (z := z) y hxz
        have heq : 3 * x * y - z = MarkoffTransfer.vieta x y z := by
          unfold MarkoffTransfer.vieta; ring
        rwa [heq] at h1
      exact ⟨hxy, hmid, hout⟩
  | swap₁₂ _ ih => exact ⟨ih.1.symm, ih.2.2, ih.2.1⟩
  | swap₂₃ _ ih => exact ⟨ih.2.2, ih.2.1.symm, ih.1⟩

/-! ## The linear obstruction -/

/-- The four base points used to obstruct linearity. -/
theorem markoff_base_points :
    IsMarkoff 1 1 1 ∧ IsMarkoff 1 2 5 ∧ IsMarkoff 1 5 13 ∧ IsMarkoff 2 5 29 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> rw [isMarkoff_iff] <;> norm_num

/-- **No linear model for the Vieta move.**

The Berggren moves are given by integer matrices acting linearly on triples, which is why
the whole Lorentz/`O(2,1)` machinery applies to them.  By contrast, no matrix — over `ℚ`,
hence none over `ℤ` — can reproduce the Markoff Vieta move `(x,y,z) ↦ (x,y,3xy - z)` on the
Markoff surface: four explicit Markoff triples already over-determine the last row of such
a matrix inconsistently.  The Markoff dynamics is irreducibly quadratic. -/
theorem vieta_not_linear :
    ¬ ∃ A : Matrix (Fin 3) (Fin 3) ℚ, ∀ x y z : ℤ, IsMarkoff x y z →
      A.mulVec ![(x : ℚ), (y : ℚ), (z : ℚ)] = ![(x : ℚ), (y : ℚ), 3 * x * y - z] := by
  rintro ⟨A, hA⟩
  obtain ⟨m1, m2, m3, m4⟩ := markoff_base_points
  have e1 := congrFun (hA 1 1 1 m1) 2
  have e2 := congrFun (hA 1 2 5 m2) 2
  have e3 := congrFun (hA 1 5 13 m3) 2
  have e4 := congrFun (hA 2 5 29 m4) 2
  simp only [Matrix.mulVec, dotProduct, Fin.sum_univ_three, Matrix.cons_val_zero,
    Matrix.cons_val_one, Matrix.head_cons, Matrix.cons_val_two, Matrix.tail_cons] at e1 e2 e3 e4
  norm_num at e1 e2 e3 e4
  linarith [e1, e2, e3, e4]

end MarkoffTransfer