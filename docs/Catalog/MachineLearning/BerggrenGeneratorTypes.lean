import MachineLearning.BerggrenSpineBinet
import MachineLearning.BerggrenTraceField

/-!
# Spectral trichotomy of the Berggren alphabet: two cusps and one quadratic axis

This cycle explains *why* the real quadratic field appears on exactly one letter of the
Berggren alphabet, by classifying the three generators as isometries of the Lorentz lattice.

* `charpoly_matA`, `charpoly_matC` : the generators `A` and `C` have characteristic
  polynomial `(X − 1)³`; they are **unipotent (parabolic)**, `(A − 1)³ = 0` while
  `(A − 1)² ≠ 0` (`matA_unipotent`, `matA_not_unipotent_two`).
* `mA_fixes_cusp`, `mC_fixes_cusp` : their fixed light-like directions are the *rational*
  cusps `(0, 1, 1)` and `(1, 0, 1)`.
* `mB_no_rational_null_eigenvector` : by contrast the hyperbolic generator `B`
  (`char = (X+1)(X² − 6X + 1)`, eigenvalues `−1, 3 ± 2√2`) has **no rational light-like
  eigendirection at all**; its two ideal fixed points `(1, 1, ±√2)` are quadratic
  irrational (`BerggrenStars.Silver.mBq_eigen_plus`).

The metric shadow of this trichotomy is exact growth data:

* `spineA_closed_form` : the all-`A` branch is `(2n+3, 2n²+6n+4, 2n²+6n+5)`, so its
  hypotenuse grows **quadratically** — the signature of a parabolic;
* `spineC_closed_form` : the all-`C` branch is `(4n²+8n+3, 4n+4, 4n²+8n+5)`, also quadratic;
* while the all-`B` branch grows like `(3 + 2√2)ⁿ` (`BerggrenStars.Binet.spine_binet`).

So the appearance of `ℚ(√2)` in the Berggren tree is not a global arithmetic phenomenon: it
is the multiplier field of the unique hyperbolic letter, and the other two letters are
parabolic elements fixing rational cusps of the light cone.
-/

namespace BerggrenStars

namespace GenTypes

open Polynomial TraceField

/-! ### `A` and `C` are unipotent -/

theorem charpoly_matA : matA.charpoly = (X - 1) ^ 3 := by
  simp [matA, Matrix.charpoly, Matrix.det_fin_three, Matrix.charmatrix]
  ring

theorem charpoly_matC : matC.charpoly = (X - 1) ^ 3 := by
  simp [matC, Matrix.charpoly, Matrix.det_fin_three, Matrix.charmatrix]
  ring

theorem matA_unipotent : (matA - 1) ^ 3 = 0 := by decide

theorem matC_unipotent : (matC - 1) ^ 3 = 0 := by decide

/-- The unipotent has maximal Jordan block: `(A − 1)² ≠ 0`. -/
theorem matA_not_unipotent_two : (matA - 1) ^ 2 ≠ 0 := by decide

theorem matC_not_unipotent_two : (matC - 1) ^ 2 ≠ 0 := by decide

theorem trace_matA : matA.trace = 3 := by
  simp [matA, Matrix.trace_fin_three]

theorem trace_matB : matB.trace = 5 := by
  simp [matB, Matrix.trace_fin_three]

theorem trace_matC : matC.trace = 3 := by
  simp [matC, Matrix.trace_fin_three]

/-! ### The rational cusps fixed by the parabolic letters -/

/-- The parabolic generator `A` fixes the rational light-like direction `(0, 1, 1)`. -/
theorem mA_fixes_cusp : mA (0, 1, 1) = (0, 1, 1) := by decide

/-- The parabolic generator `C` fixes the rational light-like direction `(1, 0, 1)`. -/
theorem mC_fixes_cusp : mC (1, 0, 1) = (1, 0, 1) := by decide

theorem cuspA_onCone : OnCone (0, 1, 1) := by
  simp [OnCone, qform, bil]

theorem cuspC_onCone : OnCone (1, 0, 1) := by
  simp [OnCone, qform, bil]

/-- The hyperbolic generator moves both cusps: they are not fixed points of `B`. -/
theorem mB_moves_cusps : mB (0, 1, 1) ≠ (0, 1, 1) ∧ mB (1, 0, 1) ≠ (1, 0, 1) := by
  constructor <;> decide

/-! ### The hyperbolic letter has no rational ideal fixed point -/

/-- The action of `B` on rational Lorentz vectors. -/
def mBrat (v : ℚ × ℚ × ℚ) : ℚ × ℚ × ℚ :=
  (v.1 + 2 * v.2.1 + 2 * v.2.2, 2 * v.1 + v.2.1 + 2 * v.2.2, 2 * v.1 + 2 * v.2.1 + 3 * v.2.2)

/-- The rational light cone. -/
def OnConeRat (v : ℚ × ℚ × ℚ) : Prop := v.1 ^ 2 + v.2.1 ^ 2 - v.2.2 ^ 2 = 0

theorem no_rat_sqrt_two {x y : ℚ} (hy : y ≠ 0) : 2 * y ^ 2 ≠ x ^ 2 := by
  intro h
  have hq : (x / y) ^ 2 = 2 := by
    field_simp
    linarith [h]
  have hr : ((x / y : ℚ) : ℝ) ^ 2 = 2 := by exact_mod_cast congrArg (fun t : ℚ => (t : ℝ)) hq
  have habs : |((x / y : ℚ) : ℝ)| = Real.sqrt 2 := by
    rw [← Real.sqrt_sq_eq_abs, hr]
  exact irrational_sqrt_two ⟨|x / y|, by rw [Rat.cast_abs, habs]⟩

/-- **No rational ideal fixed point.**  The hyperbolic Berggren generator has no nonzero
rational light-like eigenvector: unlike the parabolic letters `A` and `C`, its two fixed
points on the boundary of the light cone are quadratic irrational, namely `(1, 1, ±√2)`. -/
theorem mB_no_rational_null_eigenvector (v : ℚ × ℚ × ℚ) (mu : ℚ)
    (hv : v ≠ (0, 0, 0)) (hcone : OnConeRat v) (heig : mBrat v = (mu * v.1, mu * v.2.1, mu * v.2.2)) :
    False := by
  obtain ⟨a, b, c⟩ := v
  simp only [mBrat, Prod.mk.injEq] at heig
  obtain ⟨e1, e2, e3⟩ := heig
  simp only [OnConeRat] at hcone
  -- subtracting the first two equations gives `(mu + 1)(a − b) = 0`
  have hkey : (mu + 1) * (a - b) = 0 := by nlinarith [e1, e2]
  rcases mul_eq_zero.mp hkey with hmu | hab
  · -- `mu = -1` forces the vector to be zero
    have hmu' : mu = -1 := by linarith
    subst hmu'
    have h1 : a + b + c = 0 := by linarith [e1]
    have h3 : a + b + 2 * c = 0 := by linarith [e3]
    have hc : c = 0 := by linarith
    have hb : b = -a := by linarith [h1, hc]
    have : a ^ 2 + a ^ 2 = 0 := by
      rw [hb, hc] at hcone; nlinarith [hcone]
    have ha : a = 0 := by nlinarith [this]
    exact hv (by simp [ha, hb, hc])
  · -- `a = b` forces `c² = 2a²`, impossible over `ℚ` unless the vector vanishes
    have hab' : a = b := by linarith
    subst hab'
    have hc2 : 2 * a ^ 2 = c ^ 2 := by nlinarith [hcone]
    by_cases ha : a = 0
    · have hc : c = 0 := by
        rw [ha] at hc2; nlinarith [hc2]
      exact hv (by simp [ha, hc])
    · exact no_rat_sqrt_two ha hc2

/-! ### Growth: the parabolic branches are quadratic -/

/-- The all-`A` branch of the tree. -/
def spineA : ℕ → Vec
  | 0 => root
  | n + 1 => mA (spineA n)

/-- The all-`C` branch of the tree. -/
def spineC : ℕ → Vec
  | 0 => root
  | n + 1 => mC (spineC n)

/-- **Closed form for the parabolic `A`-branch**: hypotenuse `2n² + 6n + 5`, quadratic
growth, as befits a unipotent isometry. -/
theorem spineA_closed_form (n : ℕ) :
    spineA n = (2 * (n : ℤ) + 3, 2 * (n : ℤ) ^ 2 + 6 * n + 4, 2 * (n : ℤ) ^ 2 + 6 * n + 5) := by
  induction n with
  | zero => decide
  | succ k ih =>
      show mA (spineA k) = _
      rw [ih]
      simp only [mA, Prod.mk.injEq]
      push_cast
      refine ⟨by ring, by ring, by ring⟩

/-- **Closed form for the parabolic `C`-branch**: hypotenuse `4n² + 8n + 5`. -/
theorem spineC_closed_form (n : ℕ) :
    spineC n = (4 * (n : ℤ) ^ 2 + 8 * n + 3, 4 * (n : ℤ) + 4, 4 * (n : ℤ) ^ 2 + 8 * n + 5) := by
  induction n with
  | zero => decide
  | succ k ih =>
      show mC (spineC k) = _
      rw [ih]
      simp only [mC, Prod.mk.injEq]
      push_cast
      refine ⟨by ring, by ring, by ring⟩

/-- The parabolic branches grow polynomially: the hypotenuse at depth `n` is at most
`4n² + 8n + 5`, while the hyperbolic branch already exceeds `3ⁿ`
(`BerggrenStars.Silver.spine_hyp_ge`). -/
theorem parabolic_growth_quadratic (n : ℕ) :
    (spineA n).2.2 ≤ 4 * (n : ℤ) ^ 2 + 8 * n + 5 ∧
      (spineC n).2.2 = 4 * (n : ℤ) ^ 2 + 8 * n + 5 := by
  constructor
  · rw [spineA_closed_form]
    nlinarith [sq_nonneg ((n : ℤ)), Int.natCast_nonneg n]
  · rw [spineC_closed_form]

/-- The `A`-branch never returns to a unit node: its leg difference blows up, in accordance
with the classification `BerggrenStars.UnitLocus.unit_locus_eq_spine`. -/
theorem spineA_leg_difference (n : ℕ) :
    (spineA n).1 - (spineA n).2.1 = -(2 * (n : ℤ) ^ 2 + 4 * n + 1) := by
  rw [spineA_closed_form]
  ring

end GenTypes

end BerggrenStars