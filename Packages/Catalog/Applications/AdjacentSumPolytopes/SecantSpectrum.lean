import Applications.AdjacentSumPolytopes.Basic

/-!
# The cosecant spectrum of the adjacent-sum transfer matrix

This file settles, for every slack parameter `s`, the *complete real spectrum* of the
`(s+1) × (s+1)` adjacent-sum transfer matrix `adjMat s` (`adjMat s a b = 1 ↔ a + b ≤ s`),
which was left open as "Conjecture 1 (secant spectrum)" by the previous cycle.

With `N = 2s + 3` put, for `t = 0, 1, …, s`,

`θ_t = (2t+1)π / N`,  `λ_t = (-1)^t / (2 sin(θ_t / 2))`,
`v_t(j) = sin((s + 1 - j) θ_t)`  (`j : Fin (s+1)`).

## Main results

* `AdjSum.adjMatR_mulVec_secEigvec` : `adjMat s ·ᵥ v_t = λ_t • v_t`, an explicit
  eigenvector identity proved from a telescoped sum of sines.
* `AdjSum.secEigvec_ne_zero`, `AdjSum.det_adjMatR_sub_secEigval` : each `λ_t` really is an
  eigenvalue of the matrix.
* `AdjSum.abs_secEigval_lt`, `AdjSum.secEigval_injOn` : the `s + 1` numbers `λ_t` are
  pairwise distinct with strictly decreasing modulus, so `λ_0 = 1/(2 sin(π/(2N)))` is the
  dominant eigenvalue and the `λ_t` exhaust the spectrum.

-- !-- Lab Notes -- !--
* **Hypothesis.** The eigenvalues of the staircase matrix `a + b ≤ s` are the "half-odd
  cosecants" `±1/(2 sin((2t+1)π/(2(2s+3))))`, with alternating signs.
* **Experiment.** For `s = 2` (`N = 7`) the predicted spectrum is
  `1/(2 sin(π/14)) = 2.2470`, `-1/(2 sin(3π/14)) = -0.8019`, `1/(2 sin(5π/14)) = 0.5550`,
  and indeed `tr(M^m) = 2, 6, 11, 26, 57` matches `∑_t λ_t^m` to machine precision for
  `s ≤ 4`, `m ≤ 6`.
* **Analysis.** The proof is *not* a Chebyshev/tridiagonal argument: the staircase matrix
  is a Hankel matrix and the eigenvector equation `∑_{j ≤ s-i} v_j = λ v_i` is a partial
  sum, which telescopes after multiplication by `2 sin(θ/2)`.  The oddness of `2t+1`
  makes the boundary term `cos((2t+1)π/2)` vanish; this is exactly the quantisation
  condition, and the sign `(-1)^t = sin((2t+1)π/2)` is its companion.
* **Critique.** Nothing here is definitional or decidable: the identities are genuine
  analytic facts about `Real.sin`, and the spectral consequences use monicity plus root
  counting, not numerical evaluation.
-/

namespace AdjSum

open Finset Matrix

noncomputable section

/-- The adjacent-sum transfer matrix, viewed over the reals. -/
def adjMatR (s : ℕ) : Matrix (Fin (s + 1)) (Fin (s + 1)) ℝ :=
  fun a b => if (a : ℕ) + (b : ℕ) ≤ s then 1 else 0

lemma adjMatR_apply (s : ℕ) (a b : Fin (s + 1)) :
    adjMatR s a b = if (a : ℕ) + (b : ℕ) ≤ s then 1 else 0 := rfl

lemma adjMatR_eq_map (s : ℕ) : adjMatR s = (adjMat s).map (fun n : ℕ => (n : ℝ)) := by
  ext a b
  simp [adjMatR, adjMat, apply_ite (fun n : ℕ => (n : ℝ))]

/-- The `t`-th quantised angle `θ_t = (2t+1)π/(2s+3)`. -/
def secAngle (s t : ℕ) : ℝ := (2 * t + 1) * Real.pi / (2 * s + 3)

/-- The `t`-th eigenvalue `(-1)^t / (2 sin(θ_t/2))`. -/
def secEigval (s t : ℕ) : ℝ := (-1) ^ t / (2 * Real.sin (secAngle s t / 2))

/-- The `t`-th eigenvector `v_t(j) = sin((s+1-j) θ_t)`. -/
def secEigvec (s t : ℕ) : Fin (s + 1) → ℝ :=
  fun j => Real.sin (((s : ℝ) + 1 - (j : ℕ)) * secAngle s t)

/-! ### A telescoped sum of sines -/

/-- Telescoping partial sums of sines:
`2 sin(θ/2) ∑_{j<M} sin((i+1+j)θ) = cos((i+1/2)θ) - cos((i+M+1/2)θ)`. -/
theorem two_sin_half_mul_sum_sin (θ : ℝ) (i M : ℕ) :
    2 * Real.sin (θ / 2) * ∑ j ∈ Finset.range M, Real.sin (((i : ℝ) + 1 + j) * θ)
      = Real.cos (((i : ℝ) + 1 / 2) * θ) - Real.cos (((i : ℝ) + M + 1 / 2) * θ) := by
  induction M with
  | zero => simp
  | succ M ih =>
      rw [Finset.sum_range_succ, mul_add, ih]
      have key : 2 * Real.sin (θ / 2) * Real.sin (((i : ℝ) + 1 + M) * θ)
          = Real.cos (((i : ℝ) + M + 1 / 2) * θ) - Real.cos (((i : ℝ) + (M + 1) + 1 / 2) * θ) := by
        rw [Real.cos_sub_cos]
        have h1 : (((i : ℝ) + M + 1 / 2) * θ + ((i : ℝ) + (M + 1) + 1 / 2) * θ) / 2
            = ((i : ℝ) + 1 + M) * θ := by ring
        have h2 : (((i : ℝ) + M + 1 / 2) * θ - ((i : ℝ) + (M + 1) + 1 / 2) * θ) / 2
            = -(θ / 2) := by ring
        rw [h1, h2, Real.sin_neg]
        ring
      push_cast
      push_cast at key
      rw [key]
      ring

/-! ### Basic positivity facts about the quantised angles -/

lemma secAngle_pos {s t : ℕ} : 0 < secAngle s t := by
  have hpi := Real.pi_pos
  have h : (0 : ℝ) < 2 * s + 3 := by positivity
  unfold secAngle
  positivity

lemma secAngle_lt_pi {s t : ℕ} (ht : t ≤ s) : secAngle s t < Real.pi := by
  have hpi := Real.pi_pos
  have hden : (0 : ℝ) < 2 * s + 3 := by positivity
  have h : (2 * (t : ℝ) + 1) < 2 * s + 3 := by
    have : (t : ℝ) ≤ s := by exact_mod_cast ht
    linarith
  unfold secAngle
  rw [div_lt_iff₀ hden]
  nlinarith

lemma secAngle_half_lt_pi {s t : ℕ} (ht : t ≤ s) : secAngle s t / 2 < Real.pi := by
  have h := secAngle_lt_pi ht
  have := secAngle_pos (s := s) (t := t)
  linarith

lemma sin_secAngle_half_pos {s t : ℕ} (ht : t ≤ s) : 0 < Real.sin (secAngle s t / 2) := by
  refine Real.sin_pos_of_pos_of_lt_pi (by have := secAngle_pos (s := s) (t := t); linarith) ?_
  exact secAngle_half_lt_pi ht

lemma sin_secAngle_pos {s t : ℕ} (ht : t ≤ s) : 0 < Real.sin (secAngle s t) :=
  Real.sin_pos_of_pos_of_lt_pi secAngle_pos (secAngle_lt_pi ht)

lemma secEigval_ne_zero {s t : ℕ} (ht : t ≤ s) : secEigval s t ≠ 0 := by
  have h := sin_secAngle_half_pos ht
  unfold secEigval
  have hnum : ((-1 : ℝ)) ^ t ≠ 0 := pow_ne_zero _ (by norm_num)
  exact div_ne_zero hnum (ne_of_gt (by linarith))

/-- The boundary term of the telescoped sum vanishes: `cos((2t+1)π/2) = 0`. -/
lemma cos_odd_pi_div_two (t : ℕ) : Real.cos ((2 * (t : ℝ) + 1) * Real.pi / 2) = 0 := by
  have h : (2 * (t : ℝ) + 1) * Real.pi / 2 = t * Real.pi + Real.pi / 2 := by ring
  rw [h, Real.cos_add, Real.cos_pi_div_two, Real.sin_pi_div_two, Real.sin_nat_mul_pi]
  ring

/-- The companion identity `sin((2t+1)π/2) = (-1)^t`. -/
lemma sin_odd_pi_div_two (t : ℕ) : Real.sin ((2 * (t : ℝ) + 1) * Real.pi / 2) = (-1) ^ t := by
  have h : (2 * (t : ℝ) + 1) * Real.pi / 2 = t * Real.pi + Real.pi / 2 := by ring
  rw [h, Real.sin_add, Real.cos_pi_div_two, Real.sin_pi_div_two, Real.cos_nat_mul_pi]
  ring

/-- The quantisation condition: `(s + 3/2) θ_t = (2t+1)π/2`. -/
lemma secAngle_boundary (s t : ℕ) :
    ((s : ℝ) + 3 / 2) * secAngle s t = (2 * (t : ℝ) + 1) * Real.pi / 2 := by
  have hden : ((2 : ℝ) * s + 3) ≠ 0 := by positivity
  unfold secAngle
  field_simp

/-- Reflection identity: `sin((s+1-i)θ_t) = (-1)^t cos((i+1/2)θ_t)`.  This is the
`(2t+1)`-quantisation of the angle in disguise. -/
lemma sin_secAngle_reflect (s t i : ℕ) :
    Real.sin (((s : ℝ) + 1 - i) * secAngle s t)
      = (-1) ^ t * Real.cos (((i : ℝ) + 1 / 2) * secAngle s t) := by
  have harg : ((s : ℝ) + 1 - i) * secAngle s t
      = ((s : ℝ) + 3 / 2) * secAngle s t - ((i : ℝ) + 1 / 2) * secAngle s t := by ring
  rw [harg, secAngle_boundary, Real.sin_sub, sin_odd_pi_div_two, cos_odd_pi_div_two]
  ring

/-! ### The eigenvector identity -/

/-- Key scalar identity: the partial sum `∑_{m=i+1}^{s+1} sin(m θ_t)` equals
`λ_t · sin((s+1-i) θ_t)`. -/
theorem sum_sin_eq_secEigval_mul {s t : ℕ} (ht : t ≤ s) (i : ℕ) (hi : i ≤ s) :
    ∑ j ∈ Finset.range (s + 1 - i), Real.sin (((i : ℝ) + 1 + j) * secAngle s t)
      = secEigval s t * Real.sin (((s : ℝ) + 1 - i) * secAngle s t) := by
  have hsin : 0 < Real.sin (secAngle s t / 2) := sin_secAngle_half_pos ht
  have hcast : ((s + 1 - i : ℕ) : ℝ) = (s : ℝ) + 1 - i := by
    have hle : i ≤ s + 1 := by omega
    push_cast [Nat.cast_sub hle]
    ring
  -- the telescoped sum
  have htel := two_sin_half_mul_sum_sin (secAngle s t) i (s + 1 - i)
  rw [hcast] at htel
  have hbdry : ((i : ℝ) + ((s : ℝ) + 1 - i) + 1 / 2) * secAngle s t
      = (2 * (t : ℝ) + 1) * Real.pi / 2 := by
    have h : ((i : ℝ) + ((s : ℝ) + 1 - i) + 1 / 2) = (s : ℝ) + 3 / 2 := by ring
    rw [h, secAngle_boundary]
  rw [hbdry, cos_odd_pi_div_two] at htel
  -- the right-hand side, also multiplied by `2 sin(θ/2)`
  have hrhs : 2 * Real.sin (secAngle s t / 2) *
      (secEigval s t * Real.sin (((s : ℝ) + 1 - i) * secAngle s t))
      = (-1) ^ t * Real.sin (((s : ℝ) + 1 - i) * secAngle s t) := by
    unfold secEigval
    field_simp
  -- relate `sin((s+1-i)θ)` to `cos((i+1/2)θ)`
  have hrefl := sin_secAngle_reflect s t i
  have h2 : (2 : ℝ) * Real.sin (secAngle s t / 2) ≠ 0 := by positivity
  apply mul_left_cancel₀ h2
  rw [htel, hrhs, hrefl, ← mul_assoc, ← mul_pow]
  norm_num

/-- **Eigenvector identity.**  `adjMat s ·ᵥ v_t = λ_t • v_t`. -/
theorem adjMatR_mulVec_secEigvec {s t : ℕ} (ht : t ≤ s) :
    adjMatR s *ᵥ secEigvec s t = secEigval s t • secEigvec s t := by
  funext i
  have hi : (i : ℕ) ≤ s := Nat.lt_succ_iff.mp i.isLt
  show ∑ j : Fin (s + 1), adjMatR s i j * secEigvec s t j
      = secEigval s t * secEigvec s t i
  set f : ℕ → ℝ := fun j =>
    (if (i : ℕ) + j ≤ s then (1 : ℝ) else 0) * Real.sin (((s : ℝ) + 1 - j) * secAngle s t)
    with hf
  have hA : ∑ j : Fin (s + 1), adjMatR s i j * secEigvec s t j = ∑ j ∈ Finset.range (s + 1), f j := by
    rw [← Fin.sum_univ_eq_sum_range f (s + 1)]
    exact Finset.sum_congr rfl (fun j _ => rfl)
  have hsub : Finset.range (s + 1 - (i : ℕ)) ⊆ Finset.range (s + 1) := by
    intro x hx
    simp only [Finset.mem_range] at hx ⊢
    omega
  have hzero : ∀ j ∈ Finset.range (s + 1), j ∉ Finset.range (s + 1 - (i : ℕ)) → f j = 0 := by
    intro j hj hj2
    simp only [Finset.mem_range, not_lt] at hj hj2
    simp only [hf, if_neg (by omega : ¬((i : ℕ) + j ≤ s)), zero_mul]
  have hB : ∑ j ∈ Finset.range (s + 1), f j
      = ∑ j ∈ Finset.range (s + 1 - (i : ℕ)), Real.sin (((s : ℝ) + 1 - j) * secAngle s t) := by
    rw [← Finset.sum_subset hsub hzero]
    refine Finset.sum_congr rfl (fun j hj => ?_)
    simp only [Finset.mem_range] at hj
    simp only [hf, if_pos (by omega : (i : ℕ) + j ≤ s), one_mul]
  have hC : ∑ j ∈ Finset.range (s + 1 - (i : ℕ)), Real.sin (((s : ℝ) + 1 - j) * secAngle s t)
      = ∑ j ∈ Finset.range (s + 1 - (i : ℕ)), Real.sin (((i : ℝ) + 1 + j) * secAngle s t) := by
    rw [← Finset.sum_range_reflect (fun j => Real.sin (((i : ℝ) + 1 + j) * secAngle s t))]
    refine Finset.sum_congr rfl (fun j hj => ?_)
    simp only [Finset.mem_range] at hj
    congr 1
    have hij : (i : ℕ) + j ≤ s := by omega
    have hnat : s + 1 - (i : ℕ) - 1 - j = s - (i : ℕ) - j := by omega
    rw [hnat, Nat.cast_sub (by omega : j ≤ s - (i : ℕ)), Nat.cast_sub (by omega : (i : ℕ) ≤ s)]
    ring
  rw [hA, hB, hC, sum_sin_eq_secEigval_mul ht (i : ℕ) hi]
  rfl

/-! ### The eigenvalues -/

theorem secEigvec_ne_zero {s t : ℕ} (ht : t ≤ s) : secEigvec s t ≠ 0 := by
  intro hc
  have h := congrFun hc (Fin.last s)
  have hval : secEigvec s t (Fin.last s) = Real.sin (secAngle s t) := by
    simp only [secEigvec, Fin.val_last]
    congr 1
    ring
  rw [hval] at h
  exact absurd h (ne_of_gt (sin_secAngle_pos ht))

/-- Each `λ_t` is an eigenvalue: the matrix `adjMat s - λ_t • 1` is singular. -/
theorem det_adjMatR_sub_secEigval {s t : ℕ} (ht : t ≤ s) :
    (adjMatR s - secEigval s t • 1).det = 0 := by
  refine Matrix.exists_mulVec_eq_zero_iff.mp ⟨secEigvec s t, secEigvec_ne_zero ht, ?_⟩
  rw [Matrix.sub_mulVec, Matrix.smul_mulVec, Matrix.one_mulVec,
    adjMatR_mulVec_secEigvec ht, sub_self]

/-! ### Distinctness and dominance -/

/-- The moduli of the eigenvalues strictly decrease in `t`. -/
theorem abs_secEigval_lt {s t u : ℕ} (hu : u ≤ s) (htu : t < u) :
    |secEigval s u| < |secEigval s t| := by
  have ht : t ≤ s := le_of_lt (lt_of_lt_of_le htu hu)
  have hst : 0 < Real.sin (secAngle s t / 2) := sin_secAngle_half_pos ht
  have hsu : 0 < Real.sin (secAngle s u / 2) := sin_secAngle_half_pos hu
  have habs : ∀ v : ℕ, v ≤ s → |secEigval s v| = 1 / (2 * Real.sin (secAngle s v / 2)) := by
    intro v hv
    have hpos : 0 < Real.sin (secAngle s v / 2) := sin_secAngle_half_pos hv
    unfold secEigval
    rw [abs_div, abs_pow, abs_neg, abs_one, one_pow, abs_of_pos (by linarith)]
  rw [habs t ht, habs u hu]
  -- `sin` is strictly increasing on the relevant range, so the reciprocal decreases
  have hmono : Real.sin (secAngle s t / 2) < Real.sin (secAngle s u / 2) := by
    have hlt : secAngle s t / 2 < secAngle s u / 2 := by
      have hden : (0 : ℝ) < 2 * s + 3 := by positivity
      have hpi := Real.pi_pos
      have htu' : (t : ℝ) < u := by exact_mod_cast htu
      unfold secAngle
      rw [div_lt_div_iff_of_pos_right (by norm_num : (0:ℝ) < 2),
        div_lt_div_iff_of_pos_right hden]
      nlinarith
    have hub : secAngle s u / 2 ≤ Real.pi / 2 := by
      have hden : (0 : ℝ) < 2 * s + 3 := by positivity
      have hnum : (2 * (u : ℝ) + 1) ≤ 2 * s + 3 := by
        have : (u : ℝ) ≤ s := by exact_mod_cast hu
        linarith
      have hpi := Real.pi_pos
      unfold secAngle
      rw [div_le_div_iff_of_pos_right (by norm_num : (0:ℝ) < 2), div_le_iff₀ hden]
      nlinarith
    have hlb : -(Real.pi / 2) ≤ secAngle s t / 2 := by
      have := secAngle_pos (s := s) (t := t)
      have hpi := Real.pi_pos
      linarith
    exact Real.strictMonoOn_sin ⟨hlb, by linarith⟩ ⟨by linarith [secAngle_pos (s := s) (t := u)],
      hub⟩ hlt
  have h1 : 0 < 2 * Real.sin (secAngle s t / 2) := by linarith
  have h2 : 0 < 2 * Real.sin (secAngle s u / 2) := by linarith
  exact one_div_lt_one_div_of_lt h1 (by linarith)

/-- The `s + 1` eigenvalues are pairwise distinct. -/
theorem secEigval_injOn {s : ℕ} : Set.InjOn (secEigval s) (Set.Iic s) := by
  intro t ht u hu hEq
  simp only [Set.mem_Iic] at ht hu
  by_contra hne
  rcases lt_or_gt_of_ne hne with h | h
  · exact absurd (congrArg abs hEq) (ne_of_lt (abs_secEigval_lt hu h)).symm
  · exact absurd (congrArg abs hEq.symm) (ne_of_lt (abs_secEigval_lt ht h)).symm

/-- `λ_0 = 1/(2 sin(π/(2(2s+3))))` is the dominant eigenvalue. -/
theorem secEigval_zero_dominant {s t : ℕ} (ht : t ≤ s) (h : 0 < t) :
    |secEigval s t| < |secEigval s 0| :=
  abs_secEigval_lt ht h

/-! ### Diagonalisation, characteristic polynomial and trace formula -/

/-- The matrix whose `t`-th column is the eigenvector `v_t`. -/
def secEigmat (s : ℕ) : Matrix (Fin (s + 1)) (Fin (s + 1)) ℝ :=
  Matrix.of fun j t => secEigvec s (t : ℕ) j

/-- The diagonal matrix of eigenvalues. -/
def secDiagMat (s : ℕ) : Matrix (Fin (s + 1)) (Fin (s + 1)) ℝ :=
  Matrix.diagonal fun t : Fin (s + 1) => secEigval s (t : ℕ)

theorem adjMatR_mul_secEigmat (s : ℕ) :
    adjMatR s * secEigmat s = secEigmat s * secDiagMat s := by
  ext j t
  have ht : (t : ℕ) ≤ s := Nat.lt_succ_iff.mp t.isLt
  have hcol : (adjMatR s * secEigmat s) j t = (adjMatR s *ᵥ secEigvec s (t : ℕ)) j := rfl
  rw [hcol, adjMatR_mulVec_secEigvec ht, secDiagMat, Matrix.mul_diagonal]
  simp [secEigmat, mul_comm]

/-- The eigenvector matrix is invertible: eigenvectors for distinct eigenvalues are
linearly independent. -/
theorem secEigmat_isUnit (s : ℕ) : IsUnit (secEigmat s) := by
  rw [← Matrix.linearIndependent_cols_iff_isUnit]
  have hcol : (secEigmat s).col = fun t : Fin (s + 1) => secEigvec s (t : ℕ) := rfl
  rw [hcol]
  set f : Module.End ℝ (Fin (s + 1) → ℝ) := Matrix.mulVecLin (adjMatR s) with hf
  refine Module.End.eigenvectors_linearIndependent' f
    (fun t : Fin (s + 1) => secEigval s (t : ℕ)) ?_ _ ?_
  · intro t u h
    have ht : (t : ℕ) ∈ Set.Iic s := Nat.lt_succ_iff.mp t.isLt
    have hu : (u : ℕ) ∈ Set.Iic s := Nat.lt_succ_iff.mp u.isLt
    exact Fin.ext (secEigval_injOn ht hu h)
  · intro t
    have ht : (t : ℕ) ≤ s := Nat.lt_succ_iff.mp t.isLt
    refine ⟨Module.End.mem_eigenspace_iff.mpr ?_, secEigvec_ne_zero ht⟩
    simpa [hf] using adjMatR_mulVec_secEigvec ht

/-- **Diagonalisation.**  `A = B D B⁻¹` for the eigenvector matrix `B`. -/
theorem adjMatR_eq_conj (s : ℕ) :
    adjMatR s = secEigmat s * secDiagMat s * (secEigmat s)⁻¹ := by
  have hu : IsUnit (secEigmat s).det := (Matrix.isUnit_iff_isUnit_det _).mp (secEigmat_isUnit s)
  rw [← adjMatR_mul_secEigmat, Matrix.mul_assoc, Matrix.mul_nonsing_inv _ hu, Matrix.mul_one]

/-- **Characteristic polynomial.**  `charpoly (adjMat s) = ∏_t (X - λ_t)`. -/
theorem charpoly_adjMatR (s : ℕ) :
    (adjMatR s).charpoly = ∏ t : Fin (s + 1), (Polynomial.X - Polynomial.C (secEigval s (t : ℕ))) := by
  obtain ⟨B, hB⟩ := secEigmat_isUnit s
  have hBi : ((B⁻¹ : (Matrix (Fin (s + 1)) (Fin (s + 1)) ℝ)ˣ) :
      Matrix (Fin (s + 1)) (Fin (s + 1)) ℝ) = (secEigmat s)⁻¹ := by
    rw [← hB]
    exact Matrix.coe_units_inv B
  have hconj : adjMatR s = (B : Matrix (Fin (s + 1)) (Fin (s + 1)) ℝ) * secDiagMat s *
      ((B⁻¹ : (Matrix (Fin (s + 1)) (Fin (s + 1)) ℝ)ˣ) :
        Matrix (Fin (s + 1)) (Fin (s + 1)) ℝ) := by
    rw [hB, hBi]
    exact adjMatR_eq_conj s
  rw [hconj, Matrix.charpoly_units_conj, secDiagMat, Matrix.charpoly_diagonal]

/-- Powers of `A` intertwine with powers of the diagonal matrix through `B`. -/
theorem adjMatR_pow_mul_secEigmat (s k : ℕ) :
    adjMatR s ^ k * secEigmat s = secEigmat s * secDiagMat s ^ k := by
  induction k with
  | zero => simp
  | succ k ih =>
      calc adjMatR s ^ (k + 1) * secEigmat s
          = adjMatR s ^ k * (adjMatR s * secEigmat s) := by
            rw [pow_succ, Matrix.mul_assoc]
        _ = adjMatR s ^ k * (secEigmat s * secDiagMat s) := by rw [adjMatR_mul_secEigmat]
        _ = (adjMatR s ^ k * secEigmat s) * secDiagMat s := by rw [Matrix.mul_assoc]
        _ = secEigmat s * secDiagMat s ^ (k + 1) := by
            rw [ih, Matrix.mul_assoc, ← pow_succ]

/-- **Trace formula.**  `trace (A^m) = ∑_t λ_t^m`. -/
theorem trace_pow_adjMatR (s m : ℕ) :
    (adjMatR s ^ m).trace = ∑ t : Fin (s + 1), (secEigval s (t : ℕ)) ^ m := by
  have hu : IsUnit (secEigmat s).det := (Matrix.isUnit_iff_isUnit_det _).mp (secEigmat_isUnit s)
  have hkey := adjMatR_pow_mul_secEigmat s
  have h1 : adjMatR s ^ m = secEigmat s * secDiagMat s ^ m * (secEigmat s)⁻¹ := by
    rw [← hkey m, Matrix.mul_assoc, Matrix.mul_nonsing_inv _ hu, Matrix.mul_one]
  rw [h1, Matrix.trace_mul_comm, ← Matrix.mul_assoc, Matrix.nonsing_inv_mul _ hu,
    Matrix.one_mul, secDiagMat, Matrix.diagonal_pow, Matrix.trace_diagonal]
  rfl

/-! ### The closed form for the cyclic lattice-point counts -/

lemma adjMatR_pow_trace_cast (s m : ℕ) :
    ((Matrix.trace (adjMat s ^ m) : ℕ) : ℝ) = (adjMatR s ^ m).trace := by
  have hmap : (adjMatR s) ^ m = ((adjMat s) ^ m).map (fun n : ℕ => (n : ℝ)) := by
    rw [adjMatR_eq_map]
    exact (map_pow ((Nat.castRingHom ℝ).mapMatrix) (adjMat s) m).symm
  rw [hmap, Matrix.trace, Matrix.trace]
  push_cast
  rfl

/-- **Closed form.**  The number of cyclic adjacent-sum lattice points of length `d + 1`
is `∑_t λ_t^(d+1)`, a sum of `(s+1)` signed cosecant powers. -/
theorem card_cycSet_eq_sum_pow (s d : ℕ) :
    ((cycSet s d).card : ℝ) = ∑ t : Fin (s + 1), (secEigval s (t : ℕ)) ^ (d + 1) := by
  rw [card_cycSet s d, adjMatR_pow_trace_cast, trace_pow_adjMatR]

/-! ### Exponential growth -/

/-- For positive slack the dominant eigenvalue exceeds `1`. -/
theorem one_lt_secEigval_zero {s : ℕ} (hs : 1 ≤ s) : 1 < secEigval s 0 := by
  have hpi := Real.pi_pos
  have hden : (0 : ℝ) < 2 * s + 3 := by positivity
  have hs' : (1 : ℝ) ≤ s := by exact_mod_cast hs
  have hlt : secAngle s 0 / 2 < Real.pi / 6 := by
    have hval : secAngle s 0 / 2 = Real.pi / (2 * (2 * s + 3)) := by
      unfold secAngle
      push_cast
      field_simp
      norm_num
    rw [hval, div_lt_div_iff₀ (by positivity) (by norm_num)]
    nlinarith
  have hpos : 0 < secAngle s 0 / 2 := by
    have := secAngle_pos (s := s) (t := 0)
    linarith
  have hsin : Real.sin (secAngle s 0 / 2) < 1 / 2 := by
    have h6 : Real.sin (Real.pi / 6) = 1 / 2 := Real.sin_pi_div_six
    have hmem1 : secAngle s 0 / 2 ∈ Set.Icc (-(Real.pi / 2)) (Real.pi / 2) :=
      ⟨by linarith, by linarith⟩
    have hmem2 : Real.pi / 6 ∈ Set.Icc (-(Real.pi / 2)) (Real.pi / 2) :=
      ⟨by linarith, by linarith⟩
    have hlt' := Real.strictMonoOn_sin hmem1 hmem2 hlt
    rwa [h6] at hlt'
  have hsinpos : 0 < Real.sin (secAngle s 0 / 2) := sin_secAngle_half_pos (Nat.zero_le s)
  unfold secEigval
  rw [pow_zero, lt_div_iff₀ (by linarith)]
  linarith

/-- **Exponential growth with an explicit error term.**  The cyclic count is within
`s · |λ_1|^(d+1)` of the dominant term `λ_0^(d+1)`. -/
theorem card_cycSet_sub_dominant_le (s d : ℕ) :
    |((cycSet s d).card : ℝ) - (secEigval s 0) ^ (d + 1)|
      ≤ s * |secEigval s 1| ^ (d + 1) := by
  rw [card_cycSet_eq_sum_pow, Fin.sum_univ_succ]
  have hzero : ((0 : Fin (s + 1)) : ℕ) = 0 := rfl
  rw [hzero, add_comm, add_sub_cancel_right]
  have hbound : ∀ i : Fin s, |(secEigval s ((i.succ : Fin (s + 1)) : ℕ)) ^ (d + 1)|
      ≤ |secEigval s 1| ^ (d + 1) := by
    intro i
    have hsucc : ((i.succ : Fin (s + 1)) : ℕ) = (i : ℕ) + 1 := rfl
    have hle : (i : ℕ) + 1 ≤ s := i.isLt
    have habs : |secEigval s ((i : ℕ) + 1)| ≤ |secEigval s 1| := by
      rcases Nat.eq_zero_or_pos (i : ℕ) with h | h
      · simp [h]
      · exact le_of_lt (abs_secEigval_lt hle (by omega))
    rw [hsucc, abs_pow]
    exact pow_le_pow_left₀ (abs_nonneg _) habs _
  calc |∑ i : Fin s, (secEigval s ((i.succ : Fin (s + 1)) : ℕ)) ^ (d + 1)|
      ≤ ∑ i : Fin s, |(secEigval s ((i.succ : Fin (s + 1)) : ℕ)) ^ (d + 1)| :=
        Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _i : Fin s, |secEigval s 1| ^ (d + 1) := Finset.sum_le_sum (fun i _ => hbound i)
    _ = s * |secEigval s 1| ^ (d + 1) := by
        rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]

lemma secEigval_zero_pos (s : ℕ) : 0 < secEigval s 0 := by
  have h := sin_secAngle_half_pos (t := 0) (Nat.zero_le s)
  unfold secEigval
  rw [pow_zero]
  positivity

/-- **Sharp exponential asymptotics.**  The cyclic adjacent-sum counts are asymptotic to
`λ_0^(d+1)`, where `λ_0 = 1/(2 sin(π/(2(2s+3))))` is the dominant cosecant. -/
theorem tendsto_card_cycSet_div_dominant (s : ℕ) :
    Filter.Tendsto
      (fun d : ℕ => ((cycSet s d).card : ℝ) / (secEigval s 0) ^ (d + 1))
      Filter.atTop (nhds 1) := by
  have h0 : 0 < secEigval s 0 := secEigval_zero_pos s
  rcases Nat.eq_zero_or_pos s with hs | hs
  · -- degenerate slack: the count is exactly `λ_0^(d+1)`
    subst hs
    have hconst : ∀ d : ℕ, ((cycSet 0 d).card : ℝ) / (secEigval 0 0) ^ (d + 1) = 1 := by
      intro d
      rw [card_cycSet_eq_sum_pow, Fin.sum_univ_one]
      exact div_self (by positivity)
    simp [hconst]
  · set r : ℝ := |secEigval s 1| / secEigval s 0 with hr
    have hlt : |secEigval s 1| < secEigval s 0 := by
      have := abs_secEigval_lt (t := 0) (u := 1) hs Nat.one_pos
      rwa [abs_of_pos h0] at this
    have hr0 : 0 ≤ r := by positivity
    have hr1 : r < 1 := by
      rw [hr, div_lt_one h0]
      exact hlt
    have hbound : ∀ d : ℕ,
        ‖((cycSet s d).card : ℝ) / (secEigval s 0) ^ (d + 1) - 1‖ ≤ s * r ^ (d + 1) := by
      intro d
      have hpow : (0 : ℝ) < (secEigval s 0) ^ (d + 1) := by positivity
      have hmain := card_cycSet_sub_dominant_le s d
      have hkey : ((cycSet s d).card : ℝ) / (secEigval s 0) ^ (d + 1) - 1
          = (((cycSet s d).card : ℝ) - (secEigval s 0) ^ (d + 1))
            / (secEigval s 0) ^ (d + 1) := by
        field_simp
      rw [Real.norm_eq_abs, hkey, abs_div, abs_of_pos hpow]
      calc |((cycSet s d).card : ℝ) - (secEigval s 0) ^ (d + 1)| / (secEigval s 0) ^ (d + 1)
          ≤ ((s : ℝ) * |secEigval s 1| ^ (d + 1)) / (secEigval s 0) ^ (d + 1) := by gcongr
        _ = s * r ^ (d + 1) := by rw [hr, div_pow, mul_div_assoc]
    have htend : Filter.Tendsto (fun d : ℕ => (s : ℝ) * r ^ (d + 1)) Filter.atTop (nhds 0) := by
      have hpow : Filter.Tendsto (fun d : ℕ => r ^ (d + 1)) Filter.atTop (nhds 0) := by
        simpa [pow_succ] using
          (tendsto_pow_atTop_nhds_zero_of_lt_one hr0 hr1).mul_const r
      simpa using hpow.const_mul (s : ℝ)
    have hdiff : Filter.Tendsto
        (fun d : ℕ => ((cycSet s d).card : ℝ) / (secEigval s 0) ^ (d + 1) - 1)
        Filter.atTop (nhds 0) := squeeze_zero_norm hbound htend
    have := hdiff.add (tendsto_const_nhds (x := (1 : ℝ)) (f := Filter.atTop (α := ℕ)))
    simpa using this

end

end AdjSum