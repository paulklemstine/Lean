import Mathlib

/-!
# Integer Structures on the Hyperbolic Disk

This module collects several arithmetic and geometric facts connecting the
upper half-plane, the Poincaré disk, the modular group `Γ(2)`, and the
hyperbolic metric.

* The **Cayley transform** `z ↦ (z - i)/(z + i)` maps the upper half-plane
  bijectively onto the open unit disk.
* The matrices `[[1,2],[0,1]]` and `[[1,0],[2,1]]` generate (and in particular
  belong to) the principal congruence subgroup `Γ(2) ⊆ SL(2, ℤ)`.
* The `Γ(2)`-orbit relation on `ℤ²` is an equivalence relation.
* Euclidean balls contain only finitely many lattice points, giving discreteness
  of lattice orbits.
* On the imaginary axis, the hyperbolic midpoint is the geometric mean; it is
  equidistant, commutative and idempotent, but **not** associative.
* The cross-ratio is invariant under Möbius transformations.
-/

noncomputable section

open Real Complex Matrix

namespace HyperbolicDiskIntegers

/-! ## Part 1: The Cayley transform -/

/-- The Cayley transform, mapping the upper half-plane to the unit disk. -/
def cayley (z : ℂ) : ℂ := (z - Complex.I) / (z + Complex.I)

/-- The inverse Cayley transform, mapping the unit disk to the upper half-plane. -/
def invCayley (w : ℂ) : ℂ := Complex.I * (1 + w) / (1 - w)

/--
The Cayley transform sends the upper half-plane into the open unit disk.
-/
theorem cayley_mem_disk {z : ℂ} (hz : 0 < z.im) : Complex.normSq (cayley z) < 1 := by
  unfold cayley;
  norm_num [ Complex.normSq ];
  rw [ div_lt_iff₀ ] <;> nlinarith

/--
The inverse Cayley transform is a left inverse of the Cayley transform.
-/
theorem invCayley_cayley {z : ℂ} (hz : z ≠ -Complex.I) : invCayley (cayley z) = z := by
  unfold invCayley cayley;
  grind +suggestions

/--
The inverse Cayley transform is a right inverse of the Cayley transform.
-/
theorem cayley_invCayley {w : ℂ} (hw : w ≠ 1) : cayley (invCayley w) = w := by
  unfold cayley invCayley;
  rw [ div_eq_iff ];
  · grind;
  · rw [ Ne, div_add', div_eq_iff ] <;> norm_num [ Complex.ext_iff, hw ]; all_goals exact fun h => fun h' => hw <| by norm_num [ Complex.ext_iff ] ; constructor <;> linarith;

/-! ## Part 2: Generators of `Γ(2)` -/

/-- The translation generator `[[1,2],[0,1]]` of `Γ(2)`. -/
def genT : SpecialLinearGroup (Fin 2) ℤ := ⟨!![1, 2; 0, 1], by norm_num [Matrix.det_fin_two_of]⟩

/-- The lower-triangular generator `[[1,0],[2,1]]` of `Γ(2)`. -/
def genS : SpecialLinearGroup (Fin 2) ℤ := ⟨!![1, 0; 2, 1], by norm_num [Matrix.det_fin_two_of]⟩

/--
`genT` belongs to the principal congruence subgroup `Γ(2)`.
-/
theorem genT_mem_Gamma2 : genT ∈ CongruenceSubgroup.Gamma 2 := by
  ext i j; fin_cases i <;> fin_cases j <;> simp +decide

/--
`genS` belongs to the principal congruence subgroup `Γ(2)`.
-/
theorem genS_mem_Gamma2 : genS ∈ CongruenceSubgroup.Gamma 2 := by
  ext i j;
  fin_cases i <;> fin_cases j <;> simp +decide

/-! ## Part 3: The `Γ(2)`-orbit equivalence relation on `ℤ²` -/

/-- Two integer vectors are `Γ(2)`-related if some `g ∈ Γ(2)` carries one to the
other under the linear action `v ↦ g · v`. -/
def ZHrel (v w : Fin 2 → ℤ) : Prop :=
  ∃ g : SpecialLinearGroup (Fin 2) ℤ,
    g ∈ CongruenceSubgroup.Gamma 2 ∧ (g : Matrix (Fin 2) (Fin 2) ℤ) *ᵥ v = w

/--
Reflexivity of the orbit relation.
-/
theorem ZHrel_refl (v : Fin 2 → ℤ) : ZHrel v v := by
  exact ⟨ 1, Subgroup.one_mem _, by simp +decide ⟩

/--
Symmetry of the orbit relation.
-/
theorem ZHrel_symm {v w : Fin 2 → ℤ} (h : ZHrel v w) : ZHrel w v := by
  obtain ⟨ g, hg, rfl ⟩ := h;
  refine' ⟨ g⁻¹, _, _ ⟩ <;> simp_all +decide [ CongruenceSubgroup.Gamma ];
  simp +decide [ Matrix.adjugate_mul ]

/--
Transitivity of the orbit relation.
-/
theorem ZHrel_trans {u v w : Fin 2 → ℤ} (h₁ : ZHrel u v) (h₂ : ZHrel v w) : ZHrel u w := by
  obtain ⟨ g₁, hg₁, rfl ⟩ := h₁; obtain ⟨ g₂, hg₂, rfl ⟩ := h₂; exact ⟨ g₂ * g₁, Subgroup.mul_mem _ hg₂ hg₁, by rw [ Matrix.SpecialLinearGroup.coe_mul ] ; simp +decide [ Matrix.mulVec_mulVec ] ⟩ ;

/-! ## Part 4: Discreteness of the lattice -/

/--
Every Euclidean ball contains only finitely many lattice points.
-/
theorem lattice_ball_finite (c : ℝ × ℝ) (R : ℝ) :
    Set.Finite {v : ℤ × ℤ | ((v.1 : ℝ) - c.1) ^ 2 + ((v.2 : ℝ) - c.2) ^ 2 < R ^ 2} := by
  -- Each component of the vector must be within a certain range, leading to finitely many possible vectors.
  have h_bound : ∃ m n M N : ℤ, ∀ v : ℤ × ℤ, (v.1 - c.1) ^ 2 + (v.2 - c.2) ^ 2 < R ^ 2 → m ≤ v.1 ∧ v.1 ≤ M ∧ n ≤ v.2 ∧ v.2 ≤ N := by
    exact ⟨ ⌈c.1 - |R|⌉, ⌈c.2 - |R|⌉, ⌊c.1 + |R|⌋, ⌊c.2 + |R|⌋, fun v hv => ⟨ Int.ceil_le.mpr <| by cases abs_cases R <;> nlinarith, Int.le_floor.mpr <| by cases abs_cases R <;> nlinarith, Int.ceil_le.mpr <| by cases abs_cases R <;> nlinarith, Int.le_floor.mpr <| by cases abs_cases R <;> nlinarith ⟩ ⟩;
  obtain ⟨ m, n, M, N, h ⟩ := h_bound; exact Set.Finite.subset ( Set.Finite.prod ( Set.finite_Icc m M ) ( Set.finite_Icc n N ) ) fun v hv => ⟨ ⟨ h v hv |>.1, h v hv |>.2.1 ⟩, ⟨ h v hv |>.2.2.1, h v hv |>.2.2.2 ⟩ ⟩ ;

/-! ## Part 5: The hyperbolic midpoint on the imaginary axis

A point `i · s` (with `s > 0`) on the imaginary axis is represented by the
positive real `s`. The hyperbolic distance between `i · a` and `i · b` is
`|log (a / b)|`, and the hyperbolic midpoint is the geometric mean `√(s t)`. -/

/-- Hyperbolic distance between `i·a` and `i·b`, in terms of the imaginary parts. -/
def hDist (a b : ℝ) : ℝ := |Real.log (a / b)|

/-- Hyperbolic midpoint on the imaginary axis: the geometric mean. -/
def hMid (s t : ℝ) : ℝ := Real.sqrt (s * t)

/--
The hyperbolic midpoint is equidistant from the two endpoints.

Both endpoints are required to be positive so that `i·s` and `i·t` lie on the
imaginary axis of the upper half-plane; the positivity of `s` turns out not to be
needed by the proof itself.
-/
theorem hMid_equidistant {s t : ℝ} (hs : 0 < s) (ht : 0 < t) :
    hDist s (hMid s t) = hDist (hMid s t) t := by
  have := hs
  unfold hDist hMid
  grind

/--
The hyperbolic midpoint is commutative.
-/
theorem hMid_comm (s t : ℝ) : hMid s t = hMid t s := by
  exact congr_arg Real.sqrt ( mul_comm _ _ )

/--
The hyperbolic midpoint is idempotent.
-/
theorem hMid_idem {s : ℝ} (hs : 0 ≤ s) : hMid s s = s := by
  exact Real.sqrt_eq_iff_mul_self_eq ( by positivity ) ( by positivity ) |>.2 ( by ring )

/--
The hyperbolic midpoint is **not** associative.
-/
theorem hMid_not_assoc :
    ∃ s t u : ℝ, 0 < s ∧ 0 < t ∧ 0 < u ∧ hMid (hMid s t) u ≠ hMid s (hMid t u) := by
  refine' ⟨ 1, 1, 16, _, _, _, _ ⟩ <;> norm_num [ hMid ]

/-! ## Part 6: Cross-ratio invariance -/

/-- The cross-ratio of four complex numbers. -/
def crossRatio (z₁ z₂ z₃ z₄ : ℂ) : ℂ :=
  ((z₁ - z₃) * (z₂ - z₄)) / ((z₁ - z₄) * (z₂ - z₃))

/-- A Möbius transformation `z ↦ (a z + b)/(c z + d)`. -/
def mobius (a b c d z : ℂ) : ℂ := (a * z + b) / (c * z + d)

/--
The cross-ratio is invariant under Möbius transformations.
-/
theorem crossRatio_inv (a b c d z₁ z₂ z₃ z₄ : ℂ)
    (hdet : a * d - b * c ≠ 0)
    (h1 : c * z₁ + d ≠ 0) (h2 : c * z₂ + d ≠ 0)
    (h3 : c * z₃ + d ≠ 0) (h4 : c * z₄ + d ≠ 0)
    (h14 : z₁ - z₄ ≠ 0) (h23 : z₂ - z₃ ≠ 0) :
    crossRatio (mobius a b c d z₁) (mobius a b c d z₂) (mobius a b c d z₃)
        (mobius a b c d z₄) = crossRatio z₁ z₂ z₃ z₄ := by
  unfold crossRatio mobius;
  field_simp;
  rw [ div_sub', div_sub', div_mul_eq_mul_div, div_mul_eq_mul_div, div_mul_eq_mul_div, div_eq_iff ];
  · ring;
  · grind;
  · rwa [ mul_comm ];
  · rwa [ mul_comm ]

end HyperbolicDiskIntegers