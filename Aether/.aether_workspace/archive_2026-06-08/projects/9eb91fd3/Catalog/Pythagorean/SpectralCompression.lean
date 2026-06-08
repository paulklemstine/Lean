import Mathlib

/-!
# Spectral Optimization for Cryptographic Compression

This module develops a theory of **RMS amplification** for linear maps between
finite-dimensional Euclidean spaces, and proves that the standard operator-norm
bound used in lattice-based cryptographic correctness proofs is never more than
√k worse than the RMS amplification — and that this gap is tight.

## Main Definitions

* `rmsAmp f` — the root-mean-square amplification of a continuous linear map `f`,
  defined as `√(1/k · ∑ᵢ ‖f(eᵢ)‖²)` for the standard orthonormal basis.

## Main Results

* `rmsAmp_le_opNorm`: `rmsAmp f ≤ ‖f‖`
* `opNorm_le_sqrt_card_mul_rmsAmp`: `‖f‖ ≤ √k · rmsAmp f`
* `exists_map_realizing_sqrt_card_gap`: the √k factor is sharp
* `rms_le_sup`: for diagonal data, RMS ≤ sup (equipartition principle)
* `decode_correct_of_rmsAmp_bound`: cryptographic correctness via RMS bound

## Cross-Domain Significance

The operator norm is a Banach-space quantity; the correctness threshold is a
cryptographic object. These theorems say decryption robustness is controlled by
**spectral anisotropy** — the spread of singular values — not just map size.
The isotropy principle (balanced singular values minimize worst-case amplification
at fixed average distortion) mirrors variance-spreading phenomena in statistics,
coding theory, and statistical mechanics (equipartition of energy).
-/

open Finset BigOperators

noncomputable section

/-! ## RMS Amplification -/

/-- The **RMS amplification** of a continuous linear map `f` on `EuclideanSpace ℝ (Fin k)`.
This measures the root-mean-square of `‖f(eᵢ)‖` over the standard orthonormal basis.
Mathematically: `rmsAmp(f) = √(1/k · ∑ᵢ ‖f(eᵢ)‖²)`. -/
def rmsAmp {k m : ℕ}
    (f : EuclideanSpace ℝ (Fin k) →L[ℝ] EuclideanSpace ℝ (Fin m)) : ℝ :=
  Real.sqrt ((∑ i : Fin k, ‖f (EuclideanSpace.single i 1)‖ ^ 2) / k)

/-- RMS amplification of a functional `f : EuclideanSpace ℝ (Fin k) →L[ℝ] ℝ`. -/
def rmsAmpR {k : ℕ}
    (f : EuclideanSpace ℝ (Fin k) →L[ℝ] ℝ) : ℝ :=
  Real.sqrt ((∑ i : Fin k, ‖f (EuclideanSpace.single i 1)‖ ^ 2) / k)

/-- `rmsAmp` is nonneg. -/
theorem rmsAmp_nonneg {k m : ℕ}
    (f : EuclideanSpace ℝ (Fin k) →L[ℝ] EuclideanSpace ℝ (Fin m)) :
    0 ≤ rmsAmp f :=
  Real.sqrt_nonneg _

/-- `rmsAmpR` is nonneg. -/
theorem rmsAmpR_nonneg {k : ℕ}
    (f : EuclideanSpace ℝ (Fin k) →L[ℝ] ℝ) :
    0 ≤ rmsAmpR f :=
  Real.sqrt_nonneg _

/-! ## Core Inequality: rmsAmp ≤ opNorm -/

/-- Each basis image norm is bounded by the operator norm (since basis vectors have norm 1). -/
theorem norm_basis_image_le_opNorm {k m : ℕ}
    (f : EuclideanSpace ℝ (Fin k) →L[ℝ] EuclideanSpace ℝ (Fin m))
    (i : Fin k) :
    ‖f (EuclideanSpace.single i 1)‖ ≤ ‖f‖ := by
  have h := ContinuousLinearMap.le_opNorm f (EuclideanSpace.single i 1)
  simp [EuclideanSpace.norm_single] at h
  exact h

/-
**RMS amplification is bounded by the operator norm.**
Since each `‖f(eᵢ)‖ ≤ ‖f‖`, the RMS average is also bounded.

Proof: Each `‖f(eᵢ)‖² ≤ ‖f‖²`, so `(1/k)∑‖f(eᵢ)‖² ≤ ‖f‖²`,
hence `rmsAmp(f) ≤ ‖f‖`.
-/
theorem rmsAmp_le_opNorm {k m : ℕ} [NeZero k]
    (f : EuclideanSpace ℝ (Fin k) →L[ℝ] EuclideanSpace ℝ (Fin m)) :
    rmsAmp f ≤ ‖f‖ := by
  refine' Real.sqrt_le_iff.mpr ⟨ by positivity, _ ⟩;
  exact div_le_iff₀' ( Nat.cast_pos.mpr <| NeZero.pos k ) |>.2 ( le_trans ( Finset.sum_le_sum fun _ _ => pow_le_pow_left₀ ( norm_nonneg _ ) ( show ‖f ( EuclideanSpace.single _ 1 )‖ ≤ ‖f‖ from f.le_opNorm _ |> le_trans <| by norm_num ) _ ) <| by norm_num )

/-! ## Core Inequality: opNorm ≤ √k · rmsAmp -/

/-
Auxiliary: sum of squared basis image norms equals `rmsAmp(f)² * k`.
-/
theorem sum_sq_basis_images {k m : ℕ} [NeZero k]
    (f : EuclideanSpace ℝ (Fin k) →L[ℝ] EuclideanSpace ℝ (Fin m)) :
    ∑ i : Fin k, ‖f (EuclideanSpace.single i 1)‖ ^ 2 = rmsAmp f ^ 2 * k := by
  rw [ show rmsAmp f = Real.sqrt ( ( ∑ i, ‖f ( EuclideanSpace.single i 1 )‖ ^ 2 ) / k ) by rfl, Real.sq_sqrt <| div_nonneg ( Finset.sum_nonneg fun _ _ => sq_nonneg _ ) <| Nat.cast_nonneg k, div_mul_cancel₀ _ <| Nat.cast_ne_zero.mpr <| NeZero.ne k ]

/-
**The operator norm is bounded by √k times the RMS amplification.**

Proof: Decompose `x = ∑ᵢ xᵢ · eᵢ`, use triangle + Cauchy–Schwarz:
  `‖f(x)‖ ≤ ∑ᵢ |xᵢ| · ‖f(eᵢ)‖ ≤ ‖x‖ · √(∑ᵢ ‖f(eᵢ)‖²) = √k · rmsAmp(f) · ‖x‖`
Then conclude by `opNorm_le_iff`.
-/
theorem opNorm_le_sqrt_card_mul_rmsAmp {k m : ℕ} [NeZero k]
    (f : EuclideanSpace ℝ (Fin k) →L[ℝ] EuclideanSpace ℝ (Fin m)) :
    ‖f‖ ≤ Real.sqrt k * rmsAmp f := by
  -- By the Cauchy-Schwarz inequality, we have $\|f(x)\| \leq \|x\| \cdot \sqrt{\sum_{i=1}^k \|f(e_i)\|^2}$.
  have h_cauchy_schwarz : ∀ x : EuclideanSpace ℝ (Fin k), ‖f x‖ ≤ ‖x‖ * Real.sqrt (∑ i : Fin k, ‖f (EuclideanSpace.single i 1)‖ ^ 2) := by
    intro x;
    -- By the properties of the operator norm and the Cauchy-Schwarz inequality, we have:
    have h_op_norm : ∀ x : EuclideanSpace ℝ (Fin k), ‖f x‖ ≤ ∑ i : Fin k, |x i| * ‖f (EuclideanSpace.single i 1)‖ := by
      intro x
      have h_decomp : x = ∑ i : Fin k, (x.ofLp i) • EuclideanSpace.single i 1 := by
        ext i; simp +decide;
        rw [ Finset.sum_eq_single i ] <;> aesop;
      conv_lhs => rw [ h_decomp ];
      simpa only [ map_sum, ContinuousLinearMap.map_smul ] using le_trans ( norm_sum_le _ _ ) ( Finset.sum_le_sum fun i _ => by simp +decide [ norm_smul ] );
    refine le_trans ( h_op_norm x ) ?_;
    have h_cauchy_schwarz : ∀ (u v : Fin k → ℝ), (∑ i, u i * v i) ^ 2 ≤ (∑ i, u i ^ 2) * (∑ i, v i ^ 2) := by
      exact fun u v => sum_mul_sq_le_sq_mul_sq univ u v;
    convert Real.le_sqrt_of_sq_le ( h_cauchy_schwarz ( fun i => |x.ofLp i| ) ( fun i => ‖f ( EuclideanSpace.single i 1 )‖ ) ) using 1 ; norm_num [ EuclideanSpace.norm_eq ];
    rw [ Real.sqrt_mul <| Finset.sum_nonneg fun _ _ => sq_nonneg _ ];
  refine' ContinuousLinearMap.opNorm_le_bound _ _ fun x => _;
  · exact mul_nonneg ( Real.sqrt_nonneg _ ) ( rmsAmp_nonneg _ );
  · convert h_cauchy_schwarz x using 1 ; ring;
    unfold rmsAmp; ring;
    norm_num [ mul_assoc, mul_comm, mul_left_comm, NeZero.ne ]

/-- Combined statement: the RMS amplification and operator norm are within a √k factor. -/
theorem rmsAmp_le_opNorm_le_sqrt_card_mul_rmsAmp {k m : ℕ} [NeZero k]
    (f : EuclideanSpace ℝ (Fin k) →L[ℝ] EuclideanSpace ℝ (Fin m)) :
    rmsAmp f ≤ ‖f‖ ∧ ‖f‖ ≤ Real.sqrt k * rmsAmp f :=
  ⟨rmsAmp_le_opNorm f, opNorm_le_sqrt_card_mul_rmsAmp f⟩

/-! ## Sharpness: the √k gap is attained -/

/-- The all-ones vector in `EuclideanSpace ℝ (Fin k)`. -/
def onesVec (k : ℕ) : EuclideanSpace ℝ (Fin k) :=
  (WithLp.equiv 2 (Fin k → ℝ)).symm (fun _ => (1 : ℝ))

/-
The norm of the all-ones vector is √k.
-/
theorem norm_onesVec (k : ℕ) : ‖onesVec k‖ = Real.sqrt k := by
  -- By definition of `onesVec`, we have `onesVec k = (1, 1, ..., 1)` with `k` ones.
  simp [onesVec];
  cases k <;> norm_num [ Finset.card_univ, EuclideanSpace.norm_eq ]

/-- The **summation functional**: `x ↦ ⟨1⃗, x⟩ = ∑ᵢ xᵢ`, mapping `ℝᵏ → ℝ`.
Defined as the inner product with the all-ones vector via `innerSL`.
This is the canonical example realizing the √k gap. -/
def sumLin (k : ℕ) : EuclideanSpace ℝ (Fin k) →L[ℝ] ℝ :=
  (@innerSL ℝ (EuclideanSpace ℝ (Fin k)) _ _) (onesVec k)

/-
The norm of the summation functional is √k.
-/
theorem norm_sumLin (k : ℕ) : ‖sumLin k‖ = Real.sqrt k := by
  convert norm_onesVec k;
  convert ( InnerProductSpace.toDual ℝ ( EuclideanSpace ℝ ( Fin k ) ) ).norm_map ( onesVec k )

/-
The summation functional maps each basis vector to 1.
-/
theorem sumLin_single (k : ℕ) (i : Fin k) :
    sumLin k (EuclideanSpace.single i 1) = 1 := by
  unfold sumLin;
  simp [onesVec, innerSL];
  rw [ EuclideanSpace.inner_single_right ] ; norm_num

/-
The RMS amplification of the summation functional is 1.
-/
theorem rmsAmpR_sumLin (k : ℕ) [NeZero k] :
    rmsAmpR (sumLin k) = 1 := by
  unfold rmsAmpR;
  simp +decide [ sumLin_single ]

/-- **Sharpness**: there exists a map for which the √k gap is exactly attained.
The summation functional has `‖sumLin‖ = √k` and `rmsAmpR(sumLin) = 1`,
so `‖sumLin‖ = √k · rmsAmpR(sumLin)`. -/
theorem exists_map_realizing_sqrt_card_gap (k : ℕ) [NeZero k] :
    ∃ f : EuclideanSpace ℝ (Fin k) →L[ℝ] ℝ,
      rmsAmpR f ≠ 0 ∧ ‖f‖ = Real.sqrt k * rmsAmpR f := by
  exact ⟨sumLin k, by rw [rmsAmpR_sumLin]; norm_num,
    by rw [norm_sumLin, rmsAmpR_sumLin, mul_one]⟩

/-! ## Equipartition Principle for Sequences -/

/-
**The RMS of a finite sequence is bounded by the supremum of absolute values.**
This is the core of the equipartition principle: the "average" magnitude
can never exceed the "worst-case" magnitude.

For diagonal maps, this says the RMS amplification is at most the operator norm.
-/
theorem rms_le_sup (k : ℕ) [NeZero k] (d : Fin k → ℝ) :
    Real.sqrt ((∑ i : Fin k, d i ^ 2) / k) ≤ ⨆ i : Fin k, |d i| := by
  refine' le_trans ( Real.sqrt_le_sqrt <| div_le_div_of_nonneg_right ( Finset.sum_le_sum fun i _ => _ ) <| Nat.cast_nonneg _ ) _;
  exact fun i => ( ⨆ i, |d i| ) ^ 2;
  · nlinarith only [ abs_le.mp ( show |d i| ≤ ⨆ i, |d i| from le_ciSup ( Finite.bddAbove_range fun i => |d i| ) i ) ];
  · norm_num [ Real.sqrt_le_iff ];
    rw [ mul_div_cancel_left₀ _ ( ne_of_gt ( Real.sqrt_pos.mpr ( Nat.cast_pos.mpr <| NeZero.pos k ) ) ), Real.sqrt_sq ( by exact Real.iSup_nonneg fun _ => abs_nonneg _ ) ]

/-- **Balanced entries** means all absolute values are equal. -/
def balancedEntries {k : ℕ} (d : Fin k → ℝ) : Prop :=
  ∀ i j : Fin k, |d i| = |d j|

/-
For balanced entries, the supremum equals the RMS.
This is the converse direction of the equipartition principle:
spreading energy evenly minimizes peak excitation.
-/
theorem sup_eq_rms_of_balanced (k : ℕ) [NeZero k] (d : Fin k → ℝ)
    (hbal : balancedEntries d) :
    (⨆ i : Fin k, |d i|) = Real.sqrt ((∑ i : Fin k, d i ^ 2) / k) := by
  -- Since all |d i| are equal, let c be this common value.
  obtain ⟨c, hc⟩ : ∃ c, ∀ i, |d i| = c := by
    exact ⟨ |d ⟨ 0, NeZero.pos k ⟩|, fun i => hbal i ⟨ 0, NeZero.pos k ⟩ ⟩;
  simp_all +decide [ ← sq_abs ];
  rw [ mul_div_cancel_left₀ _ ( ne_of_gt ( Real.sqrt_pos.mpr ( Nat.cast_pos.mpr ( NeZero.pos k ) ) ) ), abs_of_nonneg ( by linarith [ abs_nonneg ( d ⟨ 0, NeZero.pos k ⟩ ), hc ⟨ 0, NeZero.pos k ⟩ ] ) ]

/-! ## Anisotropy Ratio -/

/-- The **anisotropy ratio** of a linear map: `‖f‖ / rmsAmp(f)`.
By the main theorem, this is always in `[1, √k]`.
Maps with ratio 1 are isotropic; ratio √k is maximally anisotropic. -/
def anisotropyRatio {k m : ℕ}
    (f : EuclideanSpace ℝ (Fin k) →L[ℝ] EuclideanSpace ℝ (Fin m)) : ℝ :=
  if rmsAmp f = 0 then 1 else ‖f‖ / rmsAmp f

/-
The anisotropy ratio is at least 1.
-/
theorem one_le_anisotropyRatio {k m : ℕ} [NeZero k]
    (f : EuclideanSpace ℝ (Fin k) →L[ℝ] EuclideanSpace ℝ (Fin m)) :
    1 ≤ anisotropyRatio f := by
  -- By definition of anisotropyRatio, we have two cases: rmsAmp f = 0 or rmsAmp f ≠ 0.
  by_cases h : rmsAmp f = 0;
  · unfold anisotropyRatio; aesop;
  · convert one_le_div ?_ |>.2 <| rmsAmp_le_opNorm f;
    · exact if_neg h;
    · exact lt_of_le_of_ne ( by exact Real.sqrt_nonneg _ ) ( Ne.symm h )

/-
The anisotropy ratio is at most √k.
-/
theorem anisotropyRatio_le_sqrt_card {k m : ℕ} [NeZero k]
    (f : EuclideanSpace ℝ (Fin k) →L[ℝ] EuclideanSpace ℝ (Fin m)) :
    anisotropyRatio f ≤ Real.sqrt k := by
  by_cases h : rmsAmp f = 0;
  · unfold anisotropyRatio;
    rw [ if_pos h, Real.le_sqrt ] <;> norm_num ; linarith [ NeZero.pos k ];
  · unfold anisotropyRatio;
    rw [ if_neg h, div_le_iff₀ ];
    · convert opNorm_le_sqrt_card_mul_rmsAmp f;
    · exact lt_of_le_of_ne ( by exact Real.sqrt_nonneg _ ) ( Ne.symm h )

/-! ## Cryptographic Correctness via RMS Amplification -/

/-- Abstract message type for correctness statements. -/
abbrev Msg := ℕ

/-- **Decode correctness from RMS amplification bound**.

If `√k · rmsAmp(f) · δ ≤ B` and the decoder tolerates errors up to `B`,
then compression preserves correctness. This bridges operator theory
and cryptographic engineering: `rmsAmp` can replace the raw operator norm
in correctness arguments, with at most a √k inflation. -/
theorem decode_correct_of_rmsAmp_bound
    {k m : ℕ} [NeZero k]
    (f : EuclideanSpace ℝ (Fin k) →L[ℝ] EuclideanSpace ℝ (Fin m))
    (decode : EuclideanSpace ℝ (Fin m) → Msg)
    (encode : Msg → EuclideanSpace ℝ (Fin m))
    (msg : Msg) (e : EuclideanSpace ℝ (Fin k)) (δ : ℝ)
    (he : ‖e‖ ≤ δ) (hδ : 0 ≤ δ)
    (hdecode : ∀ x, ‖x - encode msg‖ ≤ Real.sqrt k * rmsAmp f * δ →
      decode x = msg) :
    decode (encode msg + f e) = msg := by
  apply hdecode
  calc ‖encode msg + f e - encode msg‖
      = ‖f e‖ := by rw [add_sub_cancel_left]
    _ ≤ ‖f‖ * ‖e‖ := ContinuousLinearMap.le_opNorm f e
    _ ≤ ‖f‖ * δ := by
        exact mul_le_mul_of_nonneg_left he (norm_nonneg f)
    _ ≤ Real.sqrt ↑k * rmsAmp f * δ := by
        exact mul_le_mul_of_nonneg_right (opNorm_le_sqrt_card_mul_rmsAmp f) hδ

end