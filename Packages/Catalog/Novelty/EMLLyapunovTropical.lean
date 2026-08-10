import Mathlib

/-!
# Lyapunov Exponents for Recurrent EML Architectures II: nonlinear and tropical cells

The linear theory (companion file `EMLLyapunovStability.lean`) measures gradient growth by
the norm of a Jacobian product.  For a *nonlinear* recurrent cell the right global object
is the **optimal Lipschitz constant** of the `T`-fold iterate,

`optLip f^[T] = inf {K ≥ 0 | ∀ x y, dist (f^[T] x) (f^[T] y) ≤ K * dist x y}`,

whose logarithmic growth rate is the (global, sup-norm) maximum Lyapunov exponent.  This
file proves two things.

1. **Saturated-activation cells.**  For `f = σ ∘ (W · + b)` with a `1`-Lipschitz
   activation `σ` (`tanh`, `ReLU`, hard-sigmoid, …) all iterates are `‖W‖ ^ T`-Lipschitz,
   the exponent is at most `log ‖W‖`, and the derivative of the unrolled network obeys
   `‖D(f^[T])‖ ≤ ‖W‖ ^ T` — a genuine non-exploding-gradient guarantee at the level of
   backpropagation, not merely of trajectories.

2. **A universal edge-of-chaos theorem.**  Any cell that is *monotone* and *translation
   homogeneous* is automatically non-expansive in the sup norm (a Crandall–Tartar type
   argument), and its Lipschitz constant is *exactly* `1` because uniform shifts are
   transported exactly.  Hence its maximum Lyapunov exponent is **exactly `0`**, with no
   hypothesis on the weights at all.  Two families of EML primitives are covered:

   * max-plus (tropical) cells `x ↦ (⨆ j, A i j + x j)_i`, the tropical analogue of a
     linear RNN — a bridge between tropical algebra and dynamical stability;
   * row-stochastic mixing cells `x ↦ (∑ j, P i j x j)_i`, the linear part of attention,
     averaging and consensus layers.

## Main results

* `optLip_le`, `le_optLip`, `optLip_eq_one` — calculus of the optimal Lipschitz constant.
* `lipschitzWith_emlCell`, `lipschitzWith_emlCell_iterate` — contraction budget of a
  saturated-activation recurrent cell.
* `norm_fderiv_emlCell_iterate_le` — the backpropagated derivative bound.
* `nlFtle_emlCell_le` — Lyapunov exponent bound `≤ log ‖W‖`.
* `exists_fixedPoint_emlCell` — a strict budget yields a unique stable memory state.
* `lipschitzWith_one_of_monotone_homogeneous`, `optLip_iterate_eq_one`,
  `nlMle_eq_zero_of_monotone_homogeneous` — the universal edge-of-chaos theorem.
* `lipschitzWith_one_tropCell`, `optLip_tropCell_iterate_eq_one`, `nlFtle_tropCell`,
  `nlMle_tropCell` — the tropical cell has maximum Lyapunov exponent exactly `0`.
* `nlMle_stochCell` — row-stochastic attention/averaging cells have exponent exactly `0`.
* `nlMle_dilationCell` — sharpness: translation homogeneity cannot be dropped.
* `nlMle_resCell_le`, `dist_resCell_iterate_le_exp`, `norm_fderiv_resCell_iterate_le_exp`,
  `nlMle_resCell_dilation` — residual (skip-connection) cells: the exact budget
  `log (1 + ‖W‖)`, and a *depth-uniform* gradient bound `exp c` under the critical
  depth scaling `‖W‖ ≤ c / T`.
* `GradedHomogeneous`, `nlMle_eq_log_of_monotone_graded` — the graded exponent theorem: a
  monotone cell answering a uniform shift `c` by `s · c` has exponent *exactly* `log s`.
* `nlMle_skip_eq_log_two`, `nlMle_averaged_skip` — a skip connection on any monotone
  homogeneous branch has exponent exactly `log 2`, and halving the sum restores `0`.
-/

open Filter Topology

namespace EMLLyapunovNL

/-! ## 1.  The optimal Lipschitz constant and the nonlinear Lyapunov exponent -/

/-- The set of admissible Lipschitz constants of `g`. -/
def lipSet {α : Type*} [PseudoMetricSpace α] (g : α → α) : Set ℝ :=
  {K : ℝ | 0 ≤ K ∧ ∀ x y, dist (g x) (g y) ≤ K * dist x y}

/-- The optimal (least) Lipschitz constant of `g`. -/
noncomputable def optLip {α : Type*} [PseudoMetricSpace α] (g : α → α) : ℝ :=
  sInf (lipSet g)

variable {α : Type*} [PseudoMetricSpace α]

lemma lipSet_bddBelow (g : α → α) : BddBelow (lipSet g) := ⟨0, fun _ hx => hx.1⟩

/-- Any admissible constant dominates the optimal one. -/
lemma optLip_le {g : α → α} {K : ℝ} (hK : 0 ≤ K) (h : ∀ x y, dist (g x) (g y) ≤ K * dist x y) :
    optLip g ≤ K :=
  csInf_le (lipSet_bddBelow g) ⟨hK, h⟩

/-- A lower bound valid for every admissible constant bounds the optimal one. -/
lemma le_optLip {g : α → α} {L : ℝ} (hne : (lipSet g).Nonempty)
    (h : ∀ K ∈ lipSet g, L ≤ K) : L ≤ optLip g :=
  le_csInf hne h

/-- If `g` is non-expansive and *saturates* non-expansiveness on one pair of distinct
points, its optimal Lipschitz constant is exactly `1`. -/
theorem optLip_eq_one {g : α → α} (hne : ∀ x y, dist (g x) (g y) ≤ dist x y)
    (hsat : ∃ x y, 0 < dist x y ∧ dist x y ≤ dist (g x) (g y)) : optLip g = 1 := by
  obtain ⟨x₀, y₀, hpos, hsat⟩ := hsat
  refine le_antisymm (optLip_le zero_le_one (by simpa using hne)) ?_
  refine le_optLip ⟨1, zero_le_one, by simpa using hne⟩ ?_
  rintro K ⟨hK0, hK⟩
  have h1 : dist x₀ y₀ ≤ K * dist x₀ y₀ := le_trans hsat (hK x₀ y₀)
  nlinarith

/-- If `g` scales all distances by exactly `K`, its optimal Lipschitz constant is `K`. -/
theorem optLip_eq_of_dist_eq {g : α → α} {K : ℝ} (hK : 0 ≤ K)
    (h : ∀ x y, dist (g x) (g y) = K * dist x y) (hnt : ∃ x y : α, dist x y ≠ 0) :
    optLip g = K := by
  obtain ⟨x₀, y₀, hxy⟩ := hnt
  have hpos : 0 < dist x₀ y₀ := lt_of_le_of_ne dist_nonneg (Ne.symm hxy)
  refine le_antisymm (optLip_le hK (fun x y => le_of_eq (h x y))) ?_
  refine le_optLip ⟨K, hK, fun x y => le_of_eq (h x y)⟩ ?_
  rintro K' ⟨hK'0, hK'⟩
  have := hK' x₀ y₀
  rw [h x₀ y₀] at this
  exact le_of_mul_le_mul_right (by linarith) hpos

/-- Finite-time Lyapunov exponent of a nonlinear recurrent EML cell. -/
noncomputable def nlFtle (f : α → α) (T : ℕ) : ℝ := (T : ℝ)⁻¹ * Real.log (optLip f^[T])

/-- Maximum Lyapunov exponent of a nonlinear recurrent EML cell. -/
noncomputable def nlMle (f : α → α) : ℝ := limsup (nlFtle f) atTop

/-- A `limsup` comparison that survives the `ℝ`-valued junk conventions: an eventual upper
bound `M ≥ 0` bounds the `limsup`, even when the sequence is unbounded below (in which case
Mathlib's real `sInf` returns `0 ≤ M`). -/
lemma limsup_le_of_nonneg_of_eventually_le {u : ℕ → ℝ} {M : ℝ} (hM : 0 ≤ M)
    (h : ∀ᶠ T in atTop, u T ≤ M) : limsup u atTop ≤ M := by
  rw [Filter.limsup_eq]
  by_cases hb : BddBelow {a : ℝ | ∀ᶠ T in atTop, u T ≤ a}
  · exact csInf_le hb h
  · rw [Real.sInf_of_not_bddBelow hb]
    exact hM

/-! ## 2.  Saturated-activation recurrent cells -/

section Saturated

variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]

/-- A recurrent EML cell: an affine recurrent map composed with a saturating activation. -/
def emlCell (W : E →L[ℝ] E) (b : E) (σ : E → E) : E → E := fun x => σ (W x + b)

/-- With a `1`-Lipschitz activation, a recurrent EML cell is `‖W‖`-Lipschitz. -/
theorem lipschitzWith_emlCell (W : E →L[ℝ] E) (b : E) {σ : E → E} (hσ : LipschitzWith 1 σ) :
    LipschitzWith ‖W‖₊ (emlCell W b σ) := by
  have h1 : LipschitzWith ‖W‖₊ (fun x : E => W x + b) := by
    refine LipschitzWith.of_dist_le_mul (fun x y => ?_)
    rw [dist_add_right, dist_eq_norm, dist_eq_norm, ← map_sub]
    exact W.le_opNorm _
  simpa [emlCell] using (hσ.comp h1)

/-- Iterating the cell multiplies the Lipschitz budget: `f^[T]` is `‖W‖ ^ T`-Lipschitz. -/
theorem lipschitzWith_emlCell_iterate (W : E →L[ℝ] E) (b : E) {σ : E → E}
    (hσ : LipschitzWith 1 σ) (T : ℕ) :
    LipschitzWith (‖W‖₊ ^ T) (emlCell W b σ)^[T] :=
  (lipschitzWith_emlCell W b hσ).iterate T

/-- **Non-exploding gradients for saturated-activation cells.**  The Fréchet derivative of
the `T`-step unrolled network is bounded by `‖W‖ ^ T`; in particular a spectral-norm budget
`‖W‖ ≤ 1` prevents gradient explosion at every depth. -/
theorem norm_fderiv_emlCell_iterate_le (W : E →L[ℝ] E) (b : E) {σ : E → E}
    (hσ : LipschitzWith 1 σ) (T : ℕ) (x : E) :
    ‖fderiv ℝ (emlCell W b σ)^[T] x‖ ≤ ‖W‖ ^ T := by
  have h := lipschitzWith_emlCell_iterate W b hσ T
  have := norm_fderiv_le_of_lipschitz ℝ h (x₀ := x)
  simpa using this

/-- The optimal Lipschitz constant of the `T`-step unrolled cell is at most `‖W‖ ^ T`. -/
theorem optLip_emlCell_iterate_le (W : E →L[ℝ] E) (b : E) {σ : E → E} (hσ : LipschitzWith 1 σ)
    (T : ℕ) : optLip (emlCell W b σ)^[T] ≤ ‖W‖ ^ T := by
  have hlip := lipschitzWith_emlCell_iterate W b hσ T
  refine optLip_le (by positivity) (fun x y => ?_)
  simpa using hlip.dist_le_mul x y

/-- The finite-time Lyapunov exponent of a nondegenerate saturated-activation cell is at
most `log ‖W‖`.  Nondegeneracy (`0 < optLip`) rules out the collapsed case of a constant
activation, whose exponent is `-∞`. -/
theorem nlFtle_emlCell_le (W : E →L[ℝ] E) (b : E) {σ : E → E} (hσ : LipschitzWith 1 σ)
    {T : ℕ} (hT : 0 < T) (hpos : 0 < optLip (emlCell W b σ)^[T]) :
    nlFtle (emlCell W b σ) T ≤ Real.log ‖W‖ := by
  have hTpos : (0:ℝ) < T := by exact_mod_cast hT
  have hle := optLip_emlCell_iterate_le W b hσ T
  have h1 : Real.log (optLip (emlCell W b σ)^[T]) ≤ (T : ℝ) * Real.log ‖W‖ := by
    have := Real.log_le_log hpos hle
    rwa [Real.log_pow] at this
  rw [nlFtle, inv_mul_le_iff₀ hTpos]
  linarith

/-- **Stable memory state.**  A strict spectral budget `‖W‖ < 1` makes the cell a
contraction, so it has a unique fixed point (a stable memory state) which every trajectory
approaches geometrically. -/
theorem exists_fixedPoint_emlCell [CompleteSpace E] [Nonempty E] (W : E →L[ℝ] E) (b : E)
    {σ : E → E} (hσ : LipschitzWith 1 σ) (hW : ‖W‖₊ < 1) :
    ∃! x : E, emlCell W b σ x = x := by
  have hc : ContractingWith ‖W‖₊ (emlCell W b σ) := ⟨hW, lipschitzWith_emlCell W b hσ⟩
  refine ⟨hc.fixedPoint _, hc.fixedPoint_isFixedPt, fun y hy => ?_⟩
  exact hc.fixedPoint_unique hy

end Saturated

/-! ## 3.  A universal edge-of-chaos theorem for monotone, translation-homogeneous cells

Many recurrent EML primitives share two structural features: they are **monotone** (larger
inputs give larger outputs) and **translation homogeneous** (a uniform shift of the state
shifts the output by the same amount).  Max-plus (tropical) layers, min-plus layers,
maxout units, and row-stochastic attention/averaging layers are all of this type.  We prove
once and for all that any such cell has maximum Lyapunov exponent **exactly zero**.
-/

section Homogeneous

variable {m : Type*} [Fintype m] [Nonempty m]

/-- A cell is *translation homogeneous* when shifting every coordinate of the state by `c`
shifts every coordinate of the output by `c`. -/
def TranslationHomogeneous (f : (m → ℝ) → (m → ℝ)) : Prop :=
  ∀ (x : m → ℝ) (c : ℝ), f (x + fun _ => c) = f x + fun _ => c

/-- Distance to a uniform shift. -/
lemma dist_add_const (x : m → ℝ) (c : ℝ) : dist (x + fun _ => c) x = |c| := by
  rw [dist_eq_norm]
  simp

omit [Nonempty m] in
/-- **Crandall–Tartar for EML cells.**  A monotone, translation-homogeneous cell is
automatically non-expansive in the sup norm — no weight constraint whatsoever is needed. -/
theorem lipschitzWith_one_of_monotone_homogeneous {f : (m → ℝ) → (m → ℝ)}
    (hmono : Monotone f) (hhom : TranslationHomogeneous f) : LipschitzWith 1 f := by
  refine LipschitzWith.of_dist_le_mul (fun x y => ?_)
  simp only [NNReal.coe_one, one_mul]
  have hxy : ∀ j, |x j - y j| ≤ dist x y := by
    intro j
    have := dist_le_pi_dist x y j
    rwa [Real.dist_eq] at this
  have h1 : x ≤ y + fun _ => dist x y := by
    intro j
    have := (abs_le.mp (hxy j)).2
    simp only [Pi.add_apply]
    linarith
  have h2 : y ≤ x + fun _ => dist x y := by
    intro j
    have := (abs_le.mp (hxy j)).1
    simp only [Pi.add_apply]
    linarith
  have k1 : f x ≤ f y + fun _ => dist x y := by
    have := hmono h1
    rwa [hhom y (dist x y)] at this
  have k2 : f y ≤ f x + fun _ => dist x y := by
    have := hmono h2
    rwa [hhom x (dist x y)] at this
  refine (dist_pi_le_iff dist_nonneg).mpr (fun i => ?_)
  have hk1 := k1 i
  have hk2 := k2 i
  simp only [Pi.add_apply] at hk1 hk2
  rw [Real.dist_eq, abs_le]
  constructor <;> linarith

omit [Fintype m] [Nonempty m] in
/-- Translation homogeneity passes to all iterates. -/
theorem translationHomogeneous_iterate {f : (m → ℝ) → (m → ℝ)}
    (hhom : TranslationHomogeneous f) (T : ℕ) : TranslationHomogeneous f^[T] := by
  intro x c
  induction T generalizing x with
  | zero => simp
  | succ T ih =>
      rw [Function.iterate_succ_apply, Function.iterate_succ_apply, hhom x c, ih]

/-- Uniform shifts are transported exactly, so non-expansiveness is *saturated*: the
Lipschitz constant of every iterate is attained. -/
lemma dist_iterate_shift {f : (m → ℝ) → (m → ℝ)} (hhom : TranslationHomogeneous f) (T : ℕ)
    (x : m → ℝ) (c : ℝ) : dist (f^[T] (x + fun _ => c)) (f^[T] x) = |c| := by
  rw [translationHomogeneous_iterate hhom T x c, dist_add_const]

/-- **Exact Lipschitz constant.**  Every iterate of a monotone, translation-homogeneous
cell has optimal Lipschitz constant exactly `1`. -/
theorem optLip_iterate_eq_one {f : (m → ℝ) → (m → ℝ)} (hmono : Monotone f)
    (hhom : TranslationHomogeneous f) (T : ℕ) : optLip f^[T] = 1 := by
  have hlip : LipschitzWith 1 f^[T] := by
    simpa using (lipschitzWith_one_of_monotone_homogeneous hmono hhom).iterate T
  refine optLip_eq_one (fun x y => by simpa using hlip.dist_le_mul x y) ?_
  refine ⟨(0 : m → ℝ) + fun _ => (1:ℝ), 0, ?_, ?_⟩
  · rw [dist_add_const]
    norm_num
  · rw [dist_iterate_shift hhom T (0 : m → ℝ) 1, dist_add_const]

/-- The finite-time exponent of a monotone, translation-homogeneous cell vanishes at every
depth. -/
theorem nlFtle_eq_zero_of_monotone_homogeneous {f : (m → ℝ) → (m → ℝ)} (hmono : Monotone f)
    (hhom : TranslationHomogeneous f) (T : ℕ) : nlFtle f T = 0 := by
  rw [nlFtle, optLip_iterate_eq_one hmono hhom, Real.log_one, mul_zero]

/-- **Universal edge-of-chaos theorem.**  The maximum Lyapunov exponent of any monotone,
translation-homogeneous recurrent EML cell is exactly `0`: such an architecture can never
suffer exploding gradients, and never suffers geometric gradient decay either. -/
theorem nlMle_eq_zero_of_monotone_homogeneous {f : (m → ℝ) → (m → ℝ)} (hmono : Monotone f)
    (hhom : TranslationHomogeneous f) : nlMle f = 0 := by
  rw [nlMle, funext (nlFtle_eq_zero_of_monotone_homogeneous hmono hhom)]
  exact limsup_const 0

end Homogeneous

/-! ## 4.  Tropical (max-plus) recurrent cells -/

section Tropical

variable {m : Type*} [Fintype m] [Nonempty m]

/-- The max-plus (tropical) recurrent EML cell `x ↦ (max_j (A i j + x j))_i`. -/
noncomputable def tropCell (A : m → m → ℝ) (x : m → ℝ) : m → ℝ :=
  fun i => Finset.univ.sup' Finset.univ_nonempty (fun j => A i j + x j)

/-- Tropical cells are monotone. -/
theorem monotone_tropCell (A : m → m → ℝ) : Monotone (tropCell A) := by
  intro x y hxy i
  refine Finset.sup'_le _ _ (fun j _ => ?_)
  have h1 : A i j + x j ≤ A i j + y j := by linarith [hxy j]
  exact le_trans h1 (Finset.le_sup' (fun k => A i k + y k) (Finset.mem_univ j))

/-- Tropical cells are translation-equivariant. -/
theorem translationHomogeneous_tropCell (A : m → m → ℝ) :
    TranslationHomogeneous (tropCell A) := by
  intro x c
  funext i
  simp only [tropCell, Pi.add_apply]
  rw [Finset.sup'_add Finset.univ (fun j => A i j + x j) c]
  refine Finset.sup'_congr _ rfl (fun j _ => by ring)

/-- **Tropical cells are unconditionally non-expansive.**  For *every* weight matrix the
max-plus recurrent cell is `1`-Lipschitz in the sup norm; no spectral-norm constraint,
no orthogonality, and no gating is needed. -/
theorem lipschitzWith_one_tropCell (A : m → m → ℝ) : LipschitzWith 1 (tropCell A) :=
  lipschitzWith_one_of_monotone_homogeneous (monotone_tropCell A)
    (translationHomogeneous_tropCell A)

/-- **Exact Lipschitz constant of a tropical cell.**  Every iterate of a max-plus recurrent
EML cell has optimal Lipschitz constant *exactly* `1`. -/
theorem optLip_tropCell_iterate_eq_one (A : m → m → ℝ) (T : ℕ) :
    optLip (tropCell A)^[T] = 1 :=
  optLip_iterate_eq_one (monotone_tropCell A) (translationHomogeneous_tropCell A) T

/-- **The tropical Lyapunov exponent is exactly zero at every depth.** -/
theorem nlFtle_tropCell (A : m → m → ℝ) (T : ℕ) : nlFtle (tropCell A) T = 0 :=
  nlFtle_eq_zero_of_monotone_homogeneous (monotone_tropCell A)
    (translationHomogeneous_tropCell A) T

/-- **Main theorem (tropical edge of chaos).**  The maximum Lyapunov exponent of a max-plus
recurrent EML architecture is exactly `0`, for every weight matrix.  Tropical recurrence is
therefore intrinsically gradient-stable: no exploding gradients, and no geometric
vanishing either. -/
theorem nlMle_tropCell (A : m → m → ℝ) : nlMle (tropCell A) = 0 :=
  nlMle_eq_zero_of_monotone_homogeneous (monotone_tropCell A)
    (translationHomogeneous_tropCell A)

end Tropical

/-! ## 5.  Row-stochastic (attention / averaging) recurrent cells -/

section Stochastic

variable {m : Type*} [Fintype m] [Nonempty m]

/-- A row-stochastic mixing cell `x ↦ (∑ j, P i j * x j)_i`: the linear part of an
attention or averaging recurrent layer. -/
def stochCell (P : m → m → ℝ) (x : m → ℝ) : m → ℝ := fun i => ∑ j, P i j * x j

omit [Nonempty m] in
/-- Row-stochastic cells are monotone. -/
theorem monotone_stochCell {P : m → m → ℝ} (hP : ∀ i j, 0 ≤ P i j) : Monotone (stochCell P) := by
  intro x y hxy i
  exact Finset.sum_le_sum (fun j _ => mul_le_mul_of_nonneg_left (hxy j) (hP i j))

omit [Nonempty m] in
/-- Row-stochastic cells are translation homogeneous. -/
theorem translationHomogeneous_stochCell {P : m → m → ℝ} (hrow : ∀ i, ∑ j, P i j = 1) :
    TranslationHomogeneous (stochCell P) := by
  intro x c
  funext i
  simp only [stochCell, Pi.add_apply, mul_add, Finset.sum_add_distrib, ← Finset.sum_mul,
    hrow i, one_mul]

/-- **Attention layers sit exactly at the edge of chaos.**  Any row-stochastic mixing cell
— convex-combination attention, averaging, or consensus dynamics — has maximum Lyapunov
exponent exactly `0`, whatever the (nonnegative, normalised) attention weights are. -/
theorem nlMle_stochCell {P : m → m → ℝ} (hP : ∀ i j, 0 ≤ P i j) (hrow : ∀ i, ∑ j, P i j = 1) :
    nlMle (stochCell P) = 0 :=
  nlMle_eq_zero_of_monotone_homogeneous (monotone_stochCell hP)
    (translationHomogeneous_stochCell hrow)

end Stochastic

/-! ## 6.  Sharpness: dropping translation homogeneity breaks the theorem

A pure dilation `x ↦ r • x` is monotone (on the coordinatewise order) but *not*
translation homogeneous unless `r = 1`, and its exponent is exactly `log |r|`.  Taking
`r = 2` exhibits a monotone cell with a strictly positive exponent, so translation
homogeneity is not removable from `nlMle_eq_zero_of_monotone_homogeneous`.
-/

section Sharpness

variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E] [Nontrivial E]

/-- The pure dilation cell. -/
def dilationCell (r : ℝ) : E → E := fun x => r • x

omit [Nontrivial E] in
/-- Iterating a dilation multiplies the scale factor. -/
lemma dilationCell_iterate (r : ℝ) (T : ℕ) (x : E) : (dilationCell r)^[T] x = (r ^ T) • x := by
  induction T generalizing x with
  | zero => simp
  | succ T ih =>
      rw [Function.iterate_succ_apply, ih, dilationCell, smul_smul, pow_succ, mul_comm]

/-- **Exact optimal Lipschitz constant of a dilation cell.** -/
theorem optLip_dilationCell (r : ℝ) (T : ℕ) : optLip (dilationCell (E := E) r)^[T] = |r| ^ T := by
  obtain ⟨x₁, x₂, hx⟩ := ‹Nontrivial E›
  refine optLip_eq_of_dist_eq (by positivity) (fun x y => ?_) ⟨x₁, x₂, by simpa using hx⟩
  rw [dilationCell_iterate, dilationCell_iterate, dist_smul₀]
  simp

/-- **Exact maximum Lyapunov exponent of a dilation cell:** `log |r|`.  With `r = 2` this is
`log 2 > 0`, so the monotone cell `x ↦ 2 • x` explodes: translation homogeneity really is
needed in the universal edge-of-chaos theorem. -/
theorem nlMle_dilationCell {r : ℝ} (hr : r ≠ 0) : nlMle (dilationCell (E := E) r) = Real.log |r| := by
  have habs : 0 < |r| := abs_pos.mpr hr
  have hftle : ∀ T : ℕ, 0 < T → nlFtle (dilationCell (E := E) r) T = Real.log |r| := by
    intro T hT
    have hT' : (T : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hT.ne'
    rw [nlFtle, optLip_dilationCell, Real.log_pow]
    field_simp
  rw [nlMle]
  refine Tendsto.limsup_eq ?_
  refine Tendsto.congr' ?_ (tendsto_const_nhds (x := Real.log |r|) (f := atTop))
  filter_upwards [eventually_gt_atTop 0] with T hT
  exact (hftle T hT).symm

end Sharpness

/-! ## 7.  Residual (skip-connection) cells and depth-scaled non-explosion

Modern deep EML stacks are *residual*: `x ↦ x + σ (W x + b)`.  The skip connection costs
one unit of Lipschitz budget, so the naive bound `(1 + ‖W‖) ^ T` still explodes with depth
for any fixed nonzero `W`.  The point of this section is that the explosion is *exactly*
compensated by the standard depth scaling `‖W‖ ≤ c / T`: then

`(1 + c/T) ^ T ≤ exp c`

uniformly in `T`, so a depth-`T` residual EML network with depth-scaled weights has
backpropagated gradients bounded by `exp c` at *every* depth and *every* point.  The final
theorem shows this budget is attained, so `log (1 + ‖W‖)` is the exact exponent, not merely
an upper bound.
-/

section Residual

variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]

/-- A residual EML cell: an identity skip connection plus a saturated affine branch. -/
def resCell (W : E →L[ℝ] E) (b : E) (σ : E → E) : E → E := fun x => x + σ (W x + b)

/-- The skip connection costs exactly one unit of Lipschitz budget. -/
theorem lipschitzWith_resCell (W : E →L[ℝ] E) (b : E) {σ : E → E} (hσ : LipschitzWith 1 σ) :
    LipschitzWith (1 + ‖W‖₊) (resCell W b σ) := by
  have hbranch : LipschitzWith ‖W‖₊ (emlCell W b σ) := lipschitzWith_emlCell W b hσ
  have := (LipschitzWith.id (α := E)).add hbranch
  simpa [resCell, emlCell, Function.id_def] using this

/-- Unrolling a residual cell to depth `T` costs `(1 + ‖W‖) ^ T`. -/
theorem lipschitzWith_resCell_iterate (W : E →L[ℝ] E) (b : E) {σ : E → E}
    (hσ : LipschitzWith 1 σ) (T : ℕ) :
    LipschitzWith ((1 + ‖W‖₊) ^ T) (resCell W b σ)^[T] :=
  (lipschitzWith_resCell W b hσ).iterate T

/-- The optimal Lipschitz constant of the unrolled residual network. -/
theorem optLip_resCell_iterate_le (W : E →L[ℝ] E) (b : E) {σ : E → E} (hσ : LipschitzWith 1 σ)
    (T : ℕ) : optLip (resCell W b σ)^[T] ≤ (1 + ‖W‖) ^ T := by
  refine optLip_le (by positivity) (fun x y => ?_)
  have h := (lipschitzWith_resCell_iterate W b hσ T).dist_le_mul x y
  simpa using h

/-- The exponent of a residual EML cell is at most `log (1 + ‖W‖)`. -/
theorem nlMle_resCell_le (W : E →L[ℝ] E) (b : E) {σ : E → E} (hσ : LipschitzWith 1 σ) :
    nlMle (resCell W b σ) ≤ Real.log (1 + ‖W‖) := by
  have hM : 0 ≤ Real.log (1 + ‖W‖) := Real.log_nonneg (by linarith [norm_nonneg W])
  refine limsup_le_of_nonneg_of_eventually_le hM ?_
  filter_upwards [eventually_gt_atTop 0] with T hT
  have hT' : (0:ℝ) < T := by exact_mod_cast hT
  have hmem : (1 + ‖W‖) ^ T ∈ lipSet (resCell W b σ)^[T] :=
    ⟨by positivity, fun x y => by
      simpa using (lipschitzWith_resCell_iterate W b hσ T).dist_le_mul x y⟩
  have hnn : 0 ≤ optLip (resCell W b σ)^[T] := le_csInf ⟨_, hmem⟩ (fun K hK => hK.1)
  have hle := optLip_resCell_iterate_le W b hσ T
  rcases eq_or_lt_of_le hnn with h0 | h0
  · rw [nlFtle, ← h0, Real.log_zero, mul_zero]
    exact hM
  · have hlog : Real.log (optLip (resCell W b σ)^[T]) ≤ (T : ℝ) * Real.log (1 + ‖W‖) := by
      have := Real.log_le_log h0 hle
      rwa [Real.log_pow] at this
    rw [nlFtle, inv_mul_le_iff₀ hT']
    linarith

/-- **Depth-scaled residual networks do not explode.**  If the residual branch is scaled by
depth, `‖W‖ ≤ c / T`, then the depth-`T` unrolled network is `exp c`-Lipschitz — a bound
*independent of the depth `T`*.  This is the precise sense in which the `1/T` scaling used
in deep residual EML stacks is the critical scaling. -/
theorem dist_resCell_iterate_le_exp (W : E →L[ℝ] E) (b : E) {σ : E → E}
    (hσ : LipschitzWith 1 σ) {c : ℝ} {T : ℕ} (hT : 0 < T) (hW : ‖W‖ ≤ c / T) (x y : E) :
    dist ((resCell W b σ)^[T] x) ((resCell W b σ)^[T] y) ≤ Real.exp c * dist x y := by
  have hT' : (0:ℝ) < T := by exact_mod_cast hT
  have hstep : (1 + ‖W‖) ^ T ≤ Real.exp c := by
    have h1 : (1 + ‖W‖) ≤ Real.exp (c / T) := by
      have := Real.add_one_le_exp (c / T)
      linarith [hW]
    calc (1 + ‖W‖) ^ T ≤ (Real.exp (c / T)) ^ T :=
          pow_le_pow_left₀ (by positivity) h1 T
      _ = Real.exp c := by
          rw [← Real.exp_nat_mul]
          congr 1
          field_simp
  have h := (lipschitzWith_resCell_iterate W b hσ T).dist_le_mul x y
  have h' : dist ((resCell W b σ)^[T] x) ((resCell W b σ)^[T] y) ≤ (1 + ‖W‖) ^ T * dist x y := by
    simpa using h
  exact h'.trans (mul_le_mul_of_nonneg_right hstep dist_nonneg)

/-- **Depth-uniform non-exploding gradient guarantee for residual EML stacks.**  With the
critical depth scaling `‖W‖ ≤ c / T`, the backpropagated Fréchet derivative of the depth-`T`
unrolled residual network is bounded by `exp c` at every point, uniformly in `T`. -/
theorem norm_fderiv_resCell_iterate_le_exp (W : E →L[ℝ] E) (b : E) {σ : E → E}
    (hσ : LipschitzWith 1 σ) {c : ℝ} {T : ℕ} (hT : 0 < T) (hW : ‖W‖ ≤ c / T) (x : E) :
    ‖fderiv ℝ (resCell W b σ)^[T] x‖ ≤ Real.exp c := by
  have hlip : LipschitzWith (Real.toNNReal (Real.exp c)) (resCell W b σ)^[T] := by
    refine LipschitzWith.of_dist_le_mul (fun u v => ?_)
    have := dist_resCell_iterate_le_exp W b hσ hT hW u v
    simpa [Real.coe_toNNReal _ (Real.exp_pos c).le] using this
  have := norm_fderiv_le_of_lipschitz ℝ hlip (x₀ := x)
  simpa [Real.coe_toNNReal _ (Real.exp_pos c).le] using this

/-- **The residual budget is attained.**  For the linear residual cell
`x ↦ x + r • x` the exponent is exactly `log (1 + ‖W‖)`, so `nlMle_resCell_le` is sharp and
the skip connection genuinely contributes its unit of budget. -/
theorem nlMle_resCell_dilation [Nontrivial E] {r : ℝ} (hr : 0 ≤ r) :
    nlMle (resCell (r • ContinuousLinearMap.id ℝ E) 0 id)
      = Real.log (1 + ‖(r • ContinuousLinearMap.id ℝ E : E →L[ℝ] E)‖) := by
  have hnorm : ‖(r • ContinuousLinearMap.id ℝ E : E →L[ℝ] E)‖ = r := by
    rw [norm_smul, ContinuousLinearMap.norm_id, mul_one, Real.norm_eq_abs, abs_of_nonneg hr]
  have hfun : resCell (r • ContinuousLinearMap.id ℝ E) 0 id = dilationCell (E := E) (1 + r) := by
    funext x
    simp [resCell, dilationCell, add_smul, one_smul]
  rw [hfun, hnorm, nlMle_dilationCell (by positivity), abs_of_nonneg (by linarith : (0:ℝ) ≤ 1 + r)]

end Residual

/-! ## 8.  Graded homogeneity: skip connections are incompatible with the edge of chaos

Section 3 shows that a monotone cell whose response to a uniform shift `c` is again the
shift `c` sits exactly at the edge of chaos.  Section 7 shows that a residual cell can
explode.  Both are instances of one graded statement: if a monotone cell answers a uniform
shift `c` by the shift `s · c`, its maximum Lyapunov exponent is **exactly** `log s`.  The
grade `s` is a *multiplicative character of the shift action*, and the exponent reads it
off directly — no spectral information about the cell is used.

Two consequences are worth naming.  Adding an identity skip connection to any monotone,
translation-homogeneous branch doubles the grade, giving exponent exactly `log 2`
regardless of the weights: **skip connections cannot be at the edge of chaos**.  Dividing
the sum by two restores grade `1` and exponent exactly `0`, so the averaged skip
`x ↦ (x + f x)/2` is the unique convex repair.
-/

section Graded

variable {m : Type*} [Fintype m] [Nonempty m]

/-- A cell is *`s`-graded homogeneous* when a uniform shift of the state by `c` produces a
uniform shift of the output by `s * c`.  Grade `1` is translation homogeneity. -/
def GradedHomogeneous (s : ℝ) (f : (m → ℝ) → (m → ℝ)) : Prop :=
  ∀ (x : m → ℝ) (c : ℝ), f (x + fun _ => c) = f x + fun _ => s * c

omit [Fintype m] [Nonempty m] in
/-- Grade `1` is exactly translation homogeneity. -/
theorem gradedHomogeneous_one_iff {f : (m → ℝ) → (m → ℝ)} :
    GradedHomogeneous 1 f ↔ TranslationHomogeneous f := by
  constructor <;> intro h x c <;> simpa using h x c

omit [Nonempty m] in
/-- **Graded Crandall–Tartar.**  A monotone `s`-graded cell is `s`-Lipschitz in the sup
metric, with no hypothesis on the weights. -/
theorem dist_le_of_monotone_graded {s : ℝ} (hs : 0 ≤ s) {f : (m → ℝ) → (m → ℝ)}
    (hmono : Monotone f) (hhom : GradedHomogeneous s f) (x y : m → ℝ) :
    dist (f x) (f y) ≤ s * dist x y := by
  have hxy : ∀ j, |x j - y j| ≤ dist x y := by
    intro j
    have := dist_le_pi_dist x y j
    rwa [Real.dist_eq] at this
  have h1 : x ≤ y + fun _ => dist x y := by
    intro j
    have := (abs_le.mp (hxy j)).2
    simp only [Pi.add_apply]
    linarith
  have h2 : y ≤ x + fun _ => dist x y := by
    intro j
    have := (abs_le.mp (hxy j)).1
    simp only [Pi.add_apply]
    linarith
  have k1 : f x ≤ f y + fun _ => s * dist x y := by
    have := hmono h1
    rwa [hhom y (dist x y)] at this
  have k2 : f y ≤ f x + fun _ => s * dist x y := by
    have := hmono h2
    rwa [hhom x (dist x y)] at this
  refine (dist_pi_le_iff (mul_nonneg hs dist_nonneg)).mpr (fun i => ?_)
  have hk1 := k1 i
  have hk2 := k2 i
  simp only [Pi.add_apply] at hk1 hk2
  rw [Real.dist_eq, abs_le]
  constructor <;> linarith

omit [Fintype m] [Nonempty m] in
/-- Grades multiply along iterates: the `T`-fold iterate has grade `s ^ T`. -/
theorem gradedHomogeneous_iterate {s : ℝ} {f : (m → ℝ) → (m → ℝ)}
    (hhom : GradedHomogeneous s f) (T : ℕ) : GradedHomogeneous (s ^ T) f^[T] := by
  induction T with
  | zero => intro x c; simp
  | succ T ih =>
      intro x c
      rw [Function.iterate_succ_apply, hhom x c, ih (f x) (s * c),
        Function.iterate_succ_apply]
      congr 1
      funext i
      rw [pow_succ]
      ring

omit [Fintype m] [Nonempty m] in
/-- Monotonicity passes to iterates. -/
theorem monotone_iterate_of_monotone {f : (m → ℝ) → (m → ℝ)} (hmono : Monotone f) (T : ℕ) :
    Monotone f^[T] := by
  induction T with
  | zero => simpa using monotone_id
  | succ T ih =>
      rw [Function.iterate_succ]
      exact ih.comp hmono

/-- **Exact optimal Lipschitz constant of a graded cell.**  Uniform shifts saturate the
bound, so the constant of the `T`-fold iterate is exactly `s ^ T`. -/
theorem optLip_iterate_eq_of_monotone_graded {s : ℝ} (hs : 0 ≤ s) {f : (m → ℝ) → (m → ℝ)}
    (hmono : Monotone f) (hhom : GradedHomogeneous s f) (T : ℕ) : optLip f^[T] = s ^ T := by
  have hlip : ∀ x y : m → ℝ, dist (f^[T] x) (f^[T] y) ≤ s ^ T * dist x y :=
    dist_le_of_monotone_graded (pow_nonneg hs T) (monotone_iterate_of_monotone hmono T)
      (gradedHomogeneous_iterate hhom T)
  refine le_antisymm (optLip_le (pow_nonneg hs T) hlip) ?_
  refine le_optLip ⟨s ^ T, pow_nonneg hs T, hlip⟩ ?_
  rintro K ⟨hK0, hK⟩
  have h1 := hK ((0 : m → ℝ) + fun _ => (1:ℝ)) 0
  rw [gradedHomogeneous_iterate hhom T (0 : m → ℝ) 1, dist_add_const, dist_add_const] at h1
  simpa [abs_of_nonneg (pow_nonneg hs T)] using h1

/-- **Graded exponent theorem.**  The maximum Lyapunov exponent of a monotone cell of
grade `s > 0` is exactly `log s`.  Grade `1` recovers the edge-of-chaos theorem of §3. -/
theorem nlMle_eq_log_of_monotone_graded {s : ℝ} (hs : 0 < s) {f : (m → ℝ) → (m → ℝ)}
    (hmono : Monotone f) (hhom : GradedHomogeneous s f) : nlMle f = Real.log s := by
  have hftle : ∀ T : ℕ, 0 < T → nlFtle f T = Real.log s := by
    intro T hT
    have hT' : (T : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hT.ne'
    rw [nlFtle, optLip_iterate_eq_of_monotone_graded hs.le hmono hhom, Real.log_pow]
    field_simp
  rw [nlMle]
  refine Tendsto.limsup_eq ?_
  refine Tendsto.congr' ?_ (tendsto_const_nhds (x := Real.log s) (f := atTop))
  filter_upwards [eventually_gt_atTop 0] with T hT
  exact (hftle T hT).symm

omit [Fintype m] [Nonempty m] in
/-- Adding an identity skip connection doubles the grade. -/
theorem gradedHomogeneous_skip {f : (m → ℝ) → (m → ℝ)} (hhom : TranslationHomogeneous f) :
    GradedHomogeneous 2 (fun x => x + f x) := by
  intro x c
  show (x + fun _ => c) + f (x + fun _ => c) = (x + f x) + fun _ => 2 * c
  rw [hhom x c]
  funext i
  simp only [Pi.add_apply]
  ring

omit [Fintype m] [Nonempty m] in
/-- A skip connection preserves monotonicity. -/
theorem monotone_skip {f : (m → ℝ) → (m → ℝ)} (hmono : Monotone f) :
    Monotone (fun x => x + f x) := fun _ _ h => add_le_add h (hmono h)

/-- **Skip connections break the edge of chaos.**  Attaching an identity skip connection to
*any* monotone, translation-homogeneous branch — tropical, min-plus, attention, averaging —
produces a cell whose maximum Lyapunov exponent is exactly `log 2 > 0`, independently of the
weights.  So the edge-of-chaos class of §3 is not closed under residual wiring. -/
theorem nlMle_skip_eq_log_two {f : (m → ℝ) → (m → ℝ)} (hmono : Monotone f)
    (hhom : TranslationHomogeneous f) : nlMle (fun x => x + f x) = Real.log 2 :=
  nlMle_eq_log_of_monotone_graded two_pos (monotone_skip hmono) (gradedHomogeneous_skip hhom)

/-- **Averaging repairs the skip connection exactly.**  Halving the residual sum restores
grade `1`, hence exponent exactly `0`: `x ↦ (x + f x) / 2` is at the edge of chaos for every
monotone, translation-homogeneous branch `f`. -/
theorem nlMle_averaged_skip {f : (m → ℝ) → (m → ℝ)} (hmono : Monotone f)
    (hhom : TranslationHomogeneous f) : nlMle (fun x => (2:ℝ)⁻¹ • (x + f x)) = 0 := by
  have hg : GradedHomogeneous 1 (fun x => (2:ℝ)⁻¹ • (x + f x)) := by
    intro x c
    show (2:ℝ)⁻¹ • ((x + fun _ => c) + f (x + fun _ => c))
        = (2:ℝ)⁻¹ • (x + f x) + fun _ => 1 * c
    rw [hhom x c]
    funext i
    simp only [Pi.add_apply, Pi.smul_apply, smul_eq_mul]
    ring
  have hm : Monotone (fun x => (2:ℝ)⁻¹ • (x + f x)) := by
    intro x y h
    refine fun j => ?_
    have h1 := h j
    have h2 := hmono h j
    simp only [Pi.smul_apply, smul_eq_mul, Pi.add_apply]
    linarith
  simpa using nlMle_eq_log_of_monotone_graded one_pos hm hg

end Graded

end EMLLyapunovNL