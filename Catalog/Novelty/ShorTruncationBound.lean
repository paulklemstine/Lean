import Novelty.ShorFullState

/-! # Fidelity of low-rank (truncated tensor-train) approximations to a flat state

This file supplies the quantitative half of the de-quantization assessment.  The
companion files show that Shor's states have Schmidt rank exactly `r` with a
*flat* spectrum.  Here we bound how well *any* bond-dimension-`D` approximant can
do against such a state.

Both the target `M` and the approximant `A` are given in Schmidt form,
`M = L · diag w · Rᴴ`, `A = P · diag s · Qᴴ` with isometric `L, R, P, Q` — the
form produced by a singular value decomposition, and in particular by the
truncated SVD sweeps of a matrix-product-state emulation with bond dimension
`D = #δ`.

The main results are

* `norm_frobInner_le_of_schmidtForms` : `|⟪M, A⟫_F| ≤ (max_j |w j|) · ∑_k |s k|`;
* `norm_frobInner_flat_le` : for a *flat* spectrum of rank `r`,
  `|⟪M, A⟫_F| ≤ √(D / r)`;
* `fidelity_flat_le` : hence the fidelity obeys `|⟪M, A⟫_F|² ≤ D / r`;
* `frobDistSq_flat_ge` : the Frobenius error satisfies `‖M - A‖² ≥ 2 - 2√(D/r)`;
* `fidelity_shorState_le` : for the Shor state itself, every rank-`D`
  approximant has fidelity at most `D / r`.

The bound is **sharp**: `fidelity_flat_eq_of_truncation` exhibits, for every
`D ≤ r`, an approximant attaining `D / r` exactly.  This corrects the informal
claim `(D/r)²` of the source paper: the correct decay is linear in `D/r`, which
is *worse* for the emulator (the fidelity decays more slowly but is still
`O(D/r)`, hence exponentially small at any polynomial bond dimension).
-/

open Finset Matrix IITTensorNetwork

namespace ShorIrreducible

variable {α β γ δ : Type*} [Fintype α] [Fintype β] [Fintype γ] [Fintype δ]
  [DecidableEq α] [DecidableEq β] [DecidableEq γ] [DecidableEq δ]

/-- The Frobenius (Hilbert–Schmidt) inner product of two bipartite states. -/
noncomputable def frobInner (M A : Matrix α β ℂ) : ℂ := Matrix.trace (Mᴴ * A)

/-- The squared Frobenius norm of a bipartite state. -/
noncomputable def frobSq (M : Matrix α β ℂ) : ℝ := ∑ f, ∑ g, ‖M f g‖ ^ 2

omit [DecidableEq α] [DecidableEq β] in
lemma frobSq_nonneg (M : Matrix α β ℂ) : 0 ≤ frobSq M :=
  Finset.sum_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => by positivity

omit [DecidableEq α] [DecidableEq β] in
/-- `frobSq` is the squared norm used by `IITTensorNetwork.Normalized`. -/
lemma normalized_iff_frobSq (M : Matrix α β ℂ) : Normalized M ↔ frobSq M = 1 := Iff.rfl

/-! ### A Bessel inequality for isometries -/

omit [Fintype δ] in
/-- **Bessel's inequality in matrix form.**  If the columns of `R` and of `Q` are
orthonormal families, then every row of `Qᴴ R` has squared length at most one. -/
lemma sum_normSq_row_le_one {R : Matrix β γ ℂ} {Q : Matrix β δ ℂ}
    (hR : Rᴴ * R = 1) (hQ : Qᴴ * Q = 1) (k : δ) :
    ∑ j, ‖(Qᴴ * R) k j‖ ^ 2 ≤ 1 := by
  classical
  set S : Matrix β β ℂ := 1 - R * Rᴴ with hS
  have hSh : Sᴴ = S := by
    simp [hS, Matrix.conjTranspose_sub, Matrix.conjTranspose_mul]
  have hXX : (R * Rᴴ) * (R * Rᴴ) = R * Rᴴ := by
    rw [Matrix.mul_assoc, ← Matrix.mul_assoc Rᴴ R Rᴴ, hR, Matrix.one_mul]
  have hSS : Sᴴ * S = S := by
    rw [hSh, hS, Matrix.sub_mul, Matrix.mul_sub, Matrix.mul_sub, Matrix.one_mul,
      Matrix.mul_one, Matrix.one_mul, hXX]
    abel
  -- the key identity `(Qᴴ R)(Qᴴ R)ᴴ + (S Q)ᴴ (S Q) = 1`
  have hid : (Qᴴ * R) * (Qᴴ * R)ᴴ + (S * Q)ᴴ * (S * Q) = 1 := by
    have h1 : (S * Q)ᴴ * (S * Q) = Qᴴ * (Sᴴ * S) * Q := by
      simp [Matrix.conjTranspose_mul, Matrix.mul_assoc]
    have h2 : (Qᴴ * R) * (Qᴴ * R)ᴴ = Qᴴ * (R * Rᴴ) * Q := by
      simp [Matrix.conjTranspose_mul, Matrix.mul_assoc]
    rw [h1, h2, hSS, hS]
    have hsum : Qᴴ * (R * Rᴴ) * Q + Qᴴ * (1 - R * Rᴴ) * Q = Qᴴ * Q := by
      rw [← Matrix.add_mul, ← Matrix.mul_add]
      have hone : R * Rᴴ + (1 - R * Rᴴ) = (1 : Matrix β β ℂ) := by abel
      rw [hone, Matrix.mul_one]
    rw [hsum, hQ]
  have hentry := congrFun (congrFun hid k) k
  have hleft : ((Qᴴ * R) * (Qᴴ * R)ᴴ) k k = ((∑ j, ‖(Qᴴ * R) k j‖ ^ 2 : ℝ) : ℂ) := by
    simp only [Matrix.mul_apply, Matrix.conjTranspose_apply, RCLike.star_def,
      Complex.ofReal_sum]
    exact Finset.sum_congr rfl fun j _ => by
      rw [Complex.mul_conj']
      norm_num
  have hright : ((S * Q)ᴴ * (S * Q)) k k = ((∑ f, ‖(S * Q) f k‖ ^ 2 : ℝ) : ℂ) := by
    simp only [Matrix.mul_apply, Matrix.conjTranspose_apply, RCLike.star_def,
      Complex.ofReal_sum]
    refine Finset.sum_congr rfl fun f _ => ?_
    rw [mul_comm, Complex.mul_conj']
    norm_num
  rw [Matrix.add_apply, hleft, hright, Matrix.one_apply_eq] at hentry
  have hreal : (∑ j, ‖(Qᴴ * R) k j‖ ^ 2) + (∑ f, ‖(S * Q) f k‖ ^ 2) = 1 := by
    have := hentry
    rw [← Complex.ofReal_add] at this
    exact_mod_cast this
  have hnn : 0 ≤ ∑ f, ‖(S * Q) f k‖ ^ 2 :=
    Finset.sum_nonneg fun _ _ => by positivity
  linarith

omit [Fintype δ] in
/-- The column form of `sum_normSq_row_le_one`. -/
lemma sum_normSq_col_le_one {L : Matrix α γ ℂ} {P : Matrix α δ ℂ}
    (hL : Lᴴ * L = 1) (hP : Pᴴ * P = 1) (k : δ) :
    ∑ j, ‖(Lᴴ * P) j k‖ ^ 2 ≤ 1 := by
  have h := sum_normSq_row_le_one (R := L) (Q := P) hL hP k
  refine le_trans (le_of_eq ?_) h
  refine Finset.sum_congr rfl fun j _ => ?_
  have : (Pᴴ * L) k j = (starRingEnd ℂ) ((Lᴴ * P) j k) := by
    simp only [Matrix.mul_apply, Matrix.conjTranspose_apply, RCLike.star_def,
      map_sum, map_mul, RingHomCompTriple.comp_apply, RingHom.id_apply]
    exact Finset.sum_congr rfl fun f _ => by rw [mul_comm]
  rw [this, RCLike.norm_conj]

omit [Fintype δ] in
/-- Cauchy–Schwarz plus Bessel: the overlap row/column product is at most one. -/
lemma sum_norm_mul_norm_le_one {L : Matrix α γ ℂ} {R : Matrix β γ ℂ}
    {P : Matrix α δ ℂ} {Q : Matrix β δ ℂ}
    (hL : Lᴴ * L = 1) (hR : Rᴴ * R = 1) (hP : Pᴴ * P = 1) (hQ : Qᴴ * Q = 1) (k : δ) :
    ∑ j, ‖(Qᴴ * R) k j‖ * ‖(Lᴴ * P) j k‖ ≤ 1 := by
  have hcs := Finset.sum_mul_sq_le_sq_mul_sq (Finset.univ : Finset γ)
    (fun j => ‖(Qᴴ * R) k j‖) (fun j => ‖(Lᴴ * P) j k‖)
  have h1 := sum_normSq_row_le_one hR hQ k
  have h2 := sum_normSq_col_le_one hL hP k
  have hnn : 0 ≤ ∑ j, ‖(Qᴴ * R) k j‖ * ‖(Lᴴ * P) j k‖ :=
    Finset.sum_nonneg fun _ _ => by positivity
  nlinarith [hcs, h1, h2, hnn,
    Finset.sum_nonneg (fun j (_ : j ∈ (Finset.univ : Finset γ)) =>
      (by positivity : (0:ℝ) ≤ ‖(Qᴴ * R) k j‖ ^ 2)),
    Finset.sum_nonneg (fun j (_ : j ∈ (Finset.univ : Finset γ)) =>
      (by positivity : (0:ℝ) ≤ ‖(Lᴴ * P) j k‖ ^ 2))]

/-! ### The overlap of two states in Schmidt form -/

omit [DecidableEq α] [DecidableEq β] in
/-- The Frobenius overlap of two states given in Schmidt form, expanded in the
two sets of Schmidt vectors. -/
lemma frobInner_schmidtForms {M A : Matrix α β ℂ} {L : Matrix α γ ℂ} {R : Matrix β γ ℂ}
    {P : Matrix α δ ℂ} {Q : Matrix β δ ℂ} {w : γ → ℝ} {s : δ → ℝ}
    (hM : M = L * Matrix.diagonal (fun j => (w j : ℂ)) * Rᴴ)
    (hA : A = P * Matrix.diagonal (fun k => (s k : ℂ)) * Qᴴ) :
    frobInner M A
      = ∑ k, (∑ j, (Qᴴ * R) k j * (w j : ℂ) * (Lᴴ * P) j k) * (s k : ℂ) := by
  classical
  have hMh : Mᴴ = R * Matrix.diagonal (fun j => (w j : ℂ)) * Lᴴ :=
    conjTranspose_schmidtForm hM
  have hAB : Mᴴ * A
      = (R * Matrix.diagonal (fun j => (w j : ℂ)) * (Lᴴ * P)
          * Matrix.diagonal (fun k => (s k : ℂ))) * Qᴴ := by
    rw [hMh, hA]
    simp [Matrix.mul_assoc]
  have hswap : Qᴴ * (R * Matrix.diagonal (fun j => (w j : ℂ)) * (Lᴴ * P)
        * Matrix.diagonal (fun k => (s k : ℂ)))
      = (Qᴴ * R) * Matrix.diagonal (fun j => (w j : ℂ)) * (Lᴴ * P)
        * Matrix.diagonal (fun k => (s k : ℂ)) := by
    simp [Matrix.mul_assoc]
  rw [frobInner, hAB, Matrix.trace_mul_comm, hswap, Matrix.trace]
  refine Finset.sum_congr rfl fun k _ => ?_
  rw [Matrix.diag_apply, Matrix.mul_diagonal, Matrix.mul_apply]
  refine congrArg (fun z => z * (s k : ℂ)) (Finset.sum_congr rfl fun j _ => ?_)
  rw [Matrix.mul_diagonal]

/-- **The overlap bound.**  If the target `M` has Schmidt coefficients bounded by
`W` and the approximant `A` has Schmidt coefficients `s`, then the Frobenius
overlap obeys `|⟪M, A⟫| ≤ W · ∑ |s k|`. -/
theorem norm_frobInner_le_of_schmidtForms {M A : Matrix α β ℂ} {L : Matrix α γ ℂ}
    {R : Matrix β γ ℂ} {P : Matrix α δ ℂ} {Q : Matrix β δ ℂ} {w : γ → ℝ} {s : δ → ℝ}
    {W : ℝ} (hL : Lᴴ * L = 1) (hR : Rᴴ * R = 1) (hP : Pᴴ * P = 1) (hQ : Qᴴ * Q = 1)
    (hM : M = L * Matrix.diagonal (fun j => (w j : ℂ)) * Rᴴ)
    (hA : A = P * Matrix.diagonal (fun k => (s k : ℂ)) * Qᴴ)
    (hW : 0 ≤ W) (hw : ∀ j, |w j| ≤ W) :
    ‖frobInner M A‖ ≤ W * ∑ k, |s k| := by
  classical
  rw [frobInner_schmidtForms hM hA]
  refine le_trans (norm_sum_le _ _) ?_
  rw [Finset.mul_sum]
  refine Finset.sum_le_sum fun k _ => ?_
  rw [norm_mul, Complex.norm_real, Real.norm_eq_abs]
  refine mul_le_mul_of_nonneg_right ?_ (abs_nonneg _)
  refine le_trans (norm_sum_le _ _) ?_
  have hterm : ∀ j : γ, ‖(Qᴴ * R) k j * (w j : ℂ) * (Lᴴ * P) j k‖
      ≤ W * (‖(Qᴴ * R) k j‖ * ‖(Lᴴ * P) j k‖) := by
    intro j
    rw [norm_mul, norm_mul, Complex.norm_real, Real.norm_eq_abs]
    have h1 : ‖(Qᴴ * R) k j‖ * |w j| ≤ ‖(Qᴴ * R) k j‖ * W :=
      mul_le_mul_of_nonneg_left (hw j) (norm_nonneg _)
    have h2 : 0 ≤ ‖(Lᴴ * P) j k‖ := norm_nonneg _
    nlinarith [h1, h2, norm_nonneg ((Qᴴ * R) k j)]
  refine le_trans (Finset.sum_le_sum fun j _ => hterm j) ?_
  rw [← Finset.mul_sum]
  exact mul_le_of_le_one_right hW (sum_norm_mul_norm_le_one hL hR hP hQ k)

/-! ### The flat-spectrum bound -/

omit [DecidableEq δ] in
/-- The `ℓ¹`-norm of a unit `ℓ²` vector of length `D` is at most `√D`. -/
lemma sum_abs_le_sqrt_card {s : δ → ℝ} (hs : ∑ k, s k ^ 2 ≤ 1) :
    ∑ k, |s k| ≤ Real.sqrt (Fintype.card δ) := by
  have hcs := Finset.sum_mul_sq_le_sq_mul_sq (Finset.univ : Finset δ)
    (fun k => |s k|) (fun _ => (1 : ℝ))
  simp only [mul_one, one_pow, Finset.sum_const, Finset.card_univ, nsmul_eq_mul,
    sq_abs] at hcs
  have hnn : 0 ≤ ∑ k, |s k| := Finset.sum_nonneg fun _ _ => abs_nonneg _
  have hcard : (0 : ℝ) ≤ Fintype.card δ := Nat.cast_nonneg _
  have hbound : (∑ k, |s k|) ^ 2 ≤ (Fintype.card δ : ℝ) := by
    calc (∑ k, |s k|) ^ 2 ≤ (∑ k, s k ^ 2) * (Fintype.card δ : ℝ) := by
          simpa [mul_comm] using hcs
      _ ≤ 1 * (Fintype.card δ : ℝ) := by
          exact mul_le_mul_of_nonneg_right hs hcard
      _ = (Fintype.card δ : ℝ) := one_mul _
  nlinarith [Real.sq_sqrt hcard, Real.sqrt_nonneg ((Fintype.card δ : ℝ)), hnn, hbound]

/-- **The flat-spectrum truncation bound.**  If the target state `M` has all its
Schmidt coefficients bounded by `r^{-1/2}` (`r = #γ` the Schmidt rank of a flat
spectrum) and `A` is any state of Schmidt rank at most `D = #δ` and Frobenius
norm at most one, then `|⟪M, A⟫| ≤ √(D / r)`. -/
theorem norm_frobInner_flat_le {M A : Matrix α β ℂ} {L : Matrix α γ ℂ}
    {R : Matrix β γ ℂ} {P : Matrix α δ ℂ} {Q : Matrix β δ ℂ} {w : γ → ℝ} {s : δ → ℝ}
    (hL : Lᴴ * L = 1) (hR : Rᴴ * R = 1) (hP : Pᴴ * P = 1) (hQ : Qᴴ * Q = 1)
    (hM : M = L * Matrix.diagonal (fun j => (w j : ℂ)) * Rᴴ)
    (hA : A = P * Matrix.diagonal (fun k => (s k : ℂ)) * Qᴴ)
    (hw : ∀ j, |w j| ≤ (Real.sqrt (Fintype.card γ))⁻¹) (hs : ∑ k, s k ^ 2 ≤ 1) :
    ‖frobInner M A‖ ≤ Real.sqrt ((Fintype.card δ : ℝ) / (Fintype.card γ : ℝ)) := by
  rcases Nat.eq_zero_or_pos (Fintype.card γ) with h0 | hcardpos
  · haveI : IsEmpty γ := Fintype.card_eq_zero_iff.mp h0
    have hMzero : M = 0 := by
      subst hM
      ext f g
      simp [Matrix.mul_apply]
    have hzero : frobInner M A = 0 := by rw [hMzero]; simp [frobInner]
    rw [hzero]
    simp
  · have hsq : (0 : ℝ) < Real.sqrt (Fintype.card γ) :=
      Real.sqrt_pos.mpr (by exact_mod_cast hcardpos)
    have hWnn : (0 : ℝ) ≤ (Real.sqrt (Fintype.card γ))⁻¹ := by positivity
    have h := norm_frobInner_le_of_schmidtForms hL hR hP hQ hM hA hWnn hw
    refine le_trans h ?_
    rw [Real.sqrt_div (Nat.cast_nonneg _), inv_mul_eq_div,
      div_le_div_iff_of_pos_right hsq]
    exact sum_abs_le_sqrt_card hs

/-- **Fidelity form of the flat-spectrum bound**: the squared overlap of a flat
rank-`r` state with any rank-`D` approximant is at most `D / r`. -/
theorem fidelity_flat_le {M A : Matrix α β ℂ} {L : Matrix α γ ℂ}
    {R : Matrix β γ ℂ} {P : Matrix α δ ℂ} {Q : Matrix β δ ℂ} {w : γ → ℝ} {s : δ → ℝ}
    (hL : Lᴴ * L = 1) (hR : Rᴴ * R = 1) (hP : Pᴴ * P = 1) (hQ : Qᴴ * Q = 1)
    (hM : M = L * Matrix.diagonal (fun j => (w j : ℂ)) * Rᴴ)
    (hA : A = P * Matrix.diagonal (fun k => (s k : ℂ)) * Qᴴ)
    (hw : ∀ j, |w j| ≤ (Real.sqrt (Fintype.card γ))⁻¹) (hs : ∑ k, s k ^ 2 ≤ 1) :
    ‖frobInner M A‖ ^ 2 ≤ (Fintype.card δ : ℝ) / (Fintype.card γ : ℝ) := by
  have h := norm_frobInner_flat_le hL hR hP hQ hM hA hw hs
  have hnn : (0 : ℝ) ≤ (Fintype.card δ : ℝ) / (Fintype.card γ : ℝ) := by positivity
  nlinarith [Real.sq_sqrt hnn, norm_nonneg (frobInner M A),
    Real.sqrt_nonneg ((Fintype.card δ : ℝ) / (Fintype.card γ : ℝ))]

/-- **The bounded-spectrum fidelity bound** (no flatness assumed): if every
Schmidt coefficient of the target is at most `W` in modulus, then every rank-`D`
approximant has fidelity at most `D · W²`. -/
theorem fidelity_le_of_bounded_spectrum {M A : Matrix α β ℂ} {L : Matrix α γ ℂ}
    {R : Matrix β γ ℂ} {P : Matrix α δ ℂ} {Q : Matrix β δ ℂ} {w : γ → ℝ} {s : δ → ℝ}
    {W : ℝ} (hL : Lᴴ * L = 1) (hR : Rᴴ * R = 1) (hP : Pᴴ * P = 1) (hQ : Qᴴ * Q = 1)
    (hM : M = L * Matrix.diagonal (fun j => (w j : ℂ)) * Rᴴ)
    (hA : A = P * Matrix.diagonal (fun k => (s k : ℂ)) * Qᴴ)
    (hW : 0 ≤ W) (hw : ∀ j, |w j| ≤ W) (hs : ∑ k, s k ^ 2 ≤ 1) :
    ‖frobInner M A‖ ^ 2 ≤ (Fintype.card δ : ℝ) * W ^ 2 := by
  have h := norm_frobInner_le_of_schmidtForms hL hR hP hQ hM hA hW hw
  have h2 : ‖frobInner M A‖ ≤ W * Real.sqrt (Fintype.card δ) :=
    le_trans h (mul_le_mul_of_nonneg_left (sum_abs_le_sqrt_card hs) hW)
  have hsq : Real.sqrt (Fintype.card δ) ^ 2 = (Fintype.card δ : ℝ) :=
    Real.sq_sqrt (Nat.cast_nonneg _)
  nlinarith [norm_nonneg (frobInner M A), Real.sqrt_nonneg ((Fintype.card δ : ℝ)), hsq, h2]

/-! ### Sharpness: the truncated state attains the bound -/

omit [Fintype γ] [Fintype δ] [DecidableEq α] [DecidableEq β] in
/-- Restricting an isometry to a subfamily of its columns gives an isometry. -/
lemma isometry_submatrix {L : Matrix α γ ℂ} (hL : Lᴴ * L = 1) (e : δ ↪ γ) :
    (L.submatrix id e)ᴴ * (L.submatrix id e) = 1 := by
  ext k k'
  have h : ((L.submatrix id e)ᴴ * (L.submatrix id e)) k k' = (Lᴴ * L) (e k) (e k') := by
    simp [Matrix.mul_apply, Matrix.conjTranspose_apply, Matrix.submatrix_apply]
  rw [h, hL]
  simp [Matrix.one_apply, e.apply_eq_iff_eq]

omit [DecidableEq α] [DecidableEq β] in
/-- The overlap of a Schmidt-form state with its own truncation to the Schmidt
vectors selected by `e` is `∑ w(e k) s k`. -/
lemma frobInner_truncation {M : Matrix α β ℂ} {L : Matrix α γ ℂ} {R : Matrix β γ ℂ}
    {w : γ → ℝ} {s : δ → ℝ} (hL : Lᴴ * L = 1) (hR : Rᴴ * R = 1) (e : δ ↪ γ)
    (hM : M = L * Matrix.diagonal (fun j => (w j : ℂ)) * Rᴴ) :
    frobInner M ((L.submatrix id e) * Matrix.diagonal (fun k => (s k : ℂ))
        * (R.submatrix id e)ᴴ)
      = ∑ k, (w (e k) : ℂ) * (s k : ℂ) := by
  classical
  rw [frobInner_schmidtForms hM rfl]
  refine Finset.sum_congr rfl fun k _ => ?_
  have hrow : ∀ j : γ, ((R.submatrix id e)ᴴ * R) k j = (1 : Matrix γ γ ℂ) (e k) j := by
    intro j
    have : ((R.submatrix id e)ᴴ * R) k j = (Rᴴ * R) (e k) j := by
      simp [Matrix.mul_apply, Matrix.conjTranspose_apply, Matrix.submatrix_apply]
    rw [this, hR]
  have hcol : ∀ j : γ, (Lᴴ * (L.submatrix id e)) j k = (1 : Matrix γ γ ℂ) j (e k) := by
    intro j
    have : (Lᴴ * (L.submatrix id e)) j k = (Lᴴ * L) j (e k) := by
      simp [Matrix.mul_apply, Matrix.conjTranspose_apply, Matrix.submatrix_apply]
    rw [this, hL]
  have : ∑ j, ((R.submatrix id e)ᴴ * R) k j * (w j : ℂ) * (Lᴴ * (L.submatrix id e)) j k
      = (w (e k) : ℂ) := by
    rw [Finset.sum_congr rfl fun j _ => by rw [hrow j, hcol j]]
    rw [Finset.sum_eq_single (e k)]
    · simp
    · intro j _ hj
      rw [Matrix.one_apply_ne (Ne.symm hj)]
      ring
    · intro h
      exact absurd (Finset.mem_univ (e k)) h
  rw [this]

omit [DecidableEq α] [DecidableEq β] in
/-- **The flat-spectrum bound is attained.**  Truncating a flat rank-`r` state to
`D = #δ` of its Schmidt vectors and renormalizing gives fidelity exactly `D / r`,
so `fidelity_flat_le` cannot be improved. -/
theorem fidelity_flat_truncation_eq {M : Matrix α β ℂ} {L : Matrix α γ ℂ} {R : Matrix β γ ℂ}
    (hL : Lᴴ * L = 1) (hR : Rᴴ * R = 1) (e : δ ↪ γ) (hD : 0 < Fintype.card δ)
    (hM : M = L * Matrix.diagonal
      (fun _ : γ => (((Real.sqrt (Fintype.card γ))⁻¹ : ℝ) : ℂ)) * Rᴴ) :
    ‖frobInner M ((L.submatrix id e)
        * Matrix.diagonal (fun _ : δ => (((Real.sqrt (Fintype.card δ))⁻¹ : ℝ) : ℂ))
        * (R.submatrix id e)ᴴ)‖ ^ 2
      = (Fintype.card δ : ℝ) / (Fintype.card γ : ℝ) := by
  classical
  have hcardγ : 0 < Fintype.card γ := lt_of_lt_of_le hD (Fintype.card_le_of_embedding e)
  have hr : (0 : ℝ) < Real.sqrt (Fintype.card γ) :=
    Real.sqrt_pos.mpr (by exact_mod_cast hcardγ)
  have hd : (0 : ℝ) < Real.sqrt (Fintype.card δ) :=
    Real.sqrt_pos.mpr (by exact_mod_cast hD)
  rw [frobInner_truncation (w := fun _ => ((Real.sqrt (Fintype.card γ))⁻¹ : ℝ))
    (s := fun _ => ((Real.sqrt (Fintype.card δ))⁻¹ : ℝ)) hL hR e hM]
  have hsum : (∑ _k : δ, (((Real.sqrt (Fintype.card γ))⁻¹ : ℝ) : ℂ)
        * (((Real.sqrt (Fintype.card δ))⁻¹ : ℝ) : ℂ))
      = (((Fintype.card δ : ℝ) * (Real.sqrt (Fintype.card γ))⁻¹
          * (Real.sqrt (Fintype.card δ))⁻¹ : ℝ) : ℂ) := by
    rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
    push_cast
    ring
  rw [hsum, Complex.norm_real, Real.norm_eq_abs]
  have hval : (Fintype.card δ : ℝ) * (Real.sqrt (Fintype.card γ))⁻¹
      * (Real.sqrt (Fintype.card δ))⁻¹
      = Real.sqrt (Fintype.card δ) / Real.sqrt (Fintype.card γ) := by
    have hsq : Real.sqrt (Fintype.card δ) * Real.sqrt (Fintype.card δ)
        = (Fintype.card δ : ℝ) := Real.mul_self_sqrt (Nat.cast_nonneg _)
    field_simp
    nlinarith [hsq]
  rw [hval, sq_abs, div_pow, Real.sq_sqrt (Nat.cast_nonneg (Fintype.card δ)),
    Real.sq_sqrt (Nat.cast_nonneg (Fintype.card γ))]

/-! ### The Frobenius error of a low-rank approximation -/

omit [DecidableEq α] [DecidableEq β] in
lemma frobInner_apply (M A : Matrix α β ℂ) :
    frobInner M A = ∑ f, ∑ g, (starRingEnd ℂ) (M f g) * A f g := by
  rw [frobInner, Matrix.trace]
  simp only [Matrix.diag_apply, Matrix.mul_apply, Matrix.conjTranspose_apply,
    RCLike.star_def]
  rw [Finset.sum_comm]

omit [DecidableEq α] [DecidableEq β] in
/-- The parallelogram expansion of the Frobenius error. -/
lemma frobSq_sub (M A : Matrix α β ℂ) :
    frobSq (M - A) = frobSq M + frobSq A - 2 * (frobInner M A).re := by
  have hre : (frobInner M A).re
      = ∑ f, ∑ g, ((starRingEnd ℂ) (M f g) * A f g).re := by
    rw [frobInner_apply]
    simp [Complex.re_sum]
  rw [frobSq, frobSq, frobSq, hre, ← Finset.sum_add_distrib, Finset.mul_sum,
    ← Finset.sum_sub_distrib]
  refine Finset.sum_congr rfl fun f _ => ?_
  rw [← Finset.sum_add_distrib, Finset.mul_sum, ← Finset.sum_sub_distrib]
  refine Finset.sum_congr rfl fun g _ => ?_
  simp only [Matrix.sub_apply, Complex.sq_norm, Complex.normSq_apply, Complex.sub_re,
    Complex.sub_im, Complex.mul_re, Complex.conj_re, Complex.conj_im]
  ring

/-- **The Frobenius error of any low-rank approximation to a flat state.**  A
normalized rank-`D` state is at squared Frobenius distance at least
`2 - 2√(D/r)` from a normalized flat rank-`r` state. -/
theorem frobSq_sub_flat_ge {M A : Matrix α β ℂ} {L : Matrix α γ ℂ}
    {R : Matrix β γ ℂ} {P : Matrix α δ ℂ} {Q : Matrix β δ ℂ} {w : γ → ℝ} {s : δ → ℝ}
    (hL : Lᴴ * L = 1) (hR : Rᴴ * R = 1) (hP : Pᴴ * P = 1) (hQ : Qᴴ * Q = 1)
    (hM : M = L * Matrix.diagonal (fun j => (w j : ℂ)) * Rᴴ)
    (hA : A = P * Matrix.diagonal (fun k => (s k : ℂ)) * Qᴴ)
    (hw : ∀ j, |w j| ≤ (Real.sqrt (Fintype.card γ))⁻¹) (hs : ∑ k, s k ^ 2 ≤ 1)
    (hMn : Normalized M) (hAn : Normalized A) :
    2 - 2 * Real.sqrt ((Fintype.card δ : ℝ) / (Fintype.card γ : ℝ)) ≤ frobSq (M - A) := by
  have hov : (frobInner M A).re ≤ Real.sqrt ((Fintype.card δ : ℝ) / (Fintype.card γ : ℝ)) :=
    le_trans (Complex.re_le_norm _) (norm_frobInner_flat_le hL hR hP hQ hM hA hw hs)
  have hM1 : frobSq M = 1 := (normalized_iff_frobSq M).mp hMn
  have hA1 : frobSq A = 1 := (normalized_iff_frobSq A).mp hAn
  rw [frobSq_sub, hM1, hA1]
  linarith

/-! ### Application: no low-rank emulation of Shor's state -/

section ShorApplication

variable {β : Type*} [Fintype β] [DecidableEq β]

/-- **Every bond-dimension-`D` approximation of Shor's state has fidelity at most
`D / r`.**  With `r` exponentially large in the input size and `D` polynomial,
the fidelity of a tensor-train emulation is exponentially small: the truncated
MPS emulation of Shor's algorithm fails. -/
theorem fidelity_shorState_le {r m : ℕ} {F : Fin (r * m) → β} (hr : 0 < r) (hm : 0 < m)
    (hF : HasExactPeriod r F) {δ : Type*} [Fintype δ] [DecidableEq δ]
    {A : Matrix (Fin (r * m)) β ℂ} {P : Matrix (Fin (r * m)) δ ℂ} {Q : Matrix β δ ℂ}
    {s : δ → ℝ} (hP : Pᴴ * P = 1) (hQ : Qᴴ * Q = 1)
    (hA : A = P * Matrix.diagonal (fun k => (s k : ℂ)) * Qᴴ) (hs : ∑ k, s k ^ 2 ≤ 1) :
    ‖frobInner (shorState (r * m) F) A‖ ^ 2 ≤ (Fintype.card δ : ℝ) / (r : ℝ) := by
  classical
  have hcard : Fintype.card ↑(matchSet F (id : β → β)) = r := by
    rw [Fintype.card_coe, matchSet_id, card_image_of_hasExactPeriod hr hm hF]
  have hrR : (0 : ℝ) < (r : ℝ) := by exact_mod_cast hr
  have hmR : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hw : ∀ j : ↑(matchSet F (id : β → β)),
      |matchWeights F (id : β → β) ((Real.sqrt ((r * m : ℕ) : ℝ))⁻¹) j|
        ≤ (Real.sqrt (Fintype.card ↑(matchSet F (id : β → β))))⁻¹ := by
    intro j
    have hj : (j : β) ∈ (univ : Finset (Fin (r * m))).image F := by
      have hmem : (j : β) ∈ matchSet F (id : β → β) := j.2
      exact (Finset.mem_inter.mp hmem).1
    have hfib : fibreCard F (j : β) = m := fibreCard_of_hasExactPeriod hr hF hj
    have hone : fibreCard (id : β → β) (j : β) = 1 := fibreCard_id _
    have hval : matchWeights F (id : β → β) ((Real.sqrt ((r * m : ℕ) : ℝ))⁻¹) j
        = (Real.sqrt r)⁻¹ := by
      rw [matchWeights, hfib, hone]
      have hcast : ((r * m : ℕ) : ℝ) = (r : ℝ) * (m : ℝ) := by push_cast; ring
      rw [hcast, Real.sqrt_mul hrR.le]
      have hsm : Real.sqrt ((m : ℝ) * (1 : ℝ)) = Real.sqrt m := by rw [mul_one]
      have : ((m : ℕ) : ℝ) * ((1 : ℕ) : ℝ) = (m : ℝ) * (1 : ℝ) := by push_cast; ring
      rw [this, hsm]
      have hsqm : Real.sqrt (m : ℝ) ≠ 0 := by positivity
      field_simp
    rw [hval, hcard, abs_of_nonneg (by positivity)]
  have hmain := fidelity_flat_le (M := shorState (r * m) F) (A := A)
    (L := matchLeft F (id : β → β)) (R := matchRight F (id : β → β)) (P := P) (Q := Q)
    (w := matchWeights F (id : β → β) ((Real.sqrt ((r * m : ℕ) : ℝ))⁻¹)) (s := s)
    (matchLeft_isometry F id) (matchRight_isometry F id) hP hQ
    (matchMatrix_schmidtForm F id _) hA hw hs
  rwa [hcard] at hmain

end ShorApplication

end ShorIrreducible