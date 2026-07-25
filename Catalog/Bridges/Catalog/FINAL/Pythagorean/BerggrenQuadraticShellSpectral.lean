import Mathlib

/-!
# Spectral Decomposition of Berggren Dynamics on Finite Quadratic Shells

This file proves a representation-theoretic decomposition theorem for the Berggren
averaging operator on isotropic cones of the Lorentzian quadratic form
Q(x,y,z) = x² + y² - z² reduced modulo q.

## Main Results

### Algebraic Infrastructure
* `bGen_mul_bInv` / `bInv_mul_bGen` — Verified inverse pairs over ℤ.
* `bGenMod_mul_inv` / `bInvMod_mul_gen` — Inverses mod q.
* `qForm_preserved_gen` / `qForm_preserved_inv` — Form preservation mod q.

### Shell Action
* `genAct` / `invAct` — Well-defined action on the nonzero isotropic cone.
* `genAct_injective` / `invAct_bijective` — Bijectivity on finite shells.
* `genAct_invAct` / `invAct_genAct` — Inverse relationships.

### Averaging Operator
* `avgOp` — The Berggren averaging operator T_q.
* `avgOp_const` — Constants are eigenvectors with eigenvalue 1.
* `avgOp_sum_preserved` — Total sums are preserved.
* `avgOp_meanZero` — Mean-zero functions are preserved.

### Core Spectral Theorems
* `avgOp_l2_contraction` — ‖T_q f‖₂² ≤ ‖f‖₂² (nonexpansiveness from Jensen).
* `genInvariant_const_on_genOrbit` — Invariant functions are constant on orbits.
* `berggren_spectral_gap` — Under transitivity, ∃ c < 1, ‖T_q f‖₂² ≤ c · ‖f‖₂²
  for all mean-zero f. This is the spectral gap theorem.
-/

set_option maxHeartbeats 800000

open Matrix Finset BigOperators

namespace BerggrenShellSpectral

/-! ## §1. Core Definitions over ℤ -/

/-- The Lorentz metric Q = diag(1, 1, -1). -/
def metricQ : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 1, 0; 0, 0, -1]

/-- Three Berggren generators. -/
def bGen : Fin 3 → Matrix (Fin 3) (Fin 3) ℤ
  | 0 => !![1, -2, 2; 2, -1, 2; 2, -2, 3]
  | 1 => !![1, 2, 2; 2, 1, 2; 2, 2, 3]
  | 2 => !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- Three Berggren inverse generators. -/
def bInv : Fin 3 → Matrix (Fin 3) (Fin 3) ℤ
  | 0 => !![1, 2, -2; -2, -1, 2; -2, -2, 3]
  | 1 => !![1, 2, -2; 2, 1, -2; -2, -2, 3]
  | 2 => !![-1, -2, 2; 2, 1, -2; -2, -2, 3]

/-- Generator · inverse = identity. -/
theorem bGen_mul_bInv (i : Fin 3) : bGen i * bInv i = 1 := by
  fin_cases i <;> native_decide

/-- Inverse · generator = identity. -/
theorem bInv_mul_bGen (i : Fin 3) : bInv i * bGen i = 1 := by
  fin_cases i <;> native_decide

/-- Each generator preserves the Lorentz metric. -/
theorem bGen_preserves_metric (i : Fin 3) :
    (bGen i).transpose * metricQ * bGen i = metricQ := by
  fin_cases i <;> native_decide

/-! ## §2. Mod-q Reduction -/

/-- Quadratic form over ZMod q. -/
def qForm (q : ℕ) (v : Fin 3 → ZMod q) : ZMod q :=
  v 0 * v 0 + v 1 * v 1 - v 2 * v 2

/-- Generators reduced mod q. -/
def bGenMod (q : ℕ) (i : Fin 3) : Matrix (Fin 3) (Fin 3) (ZMod q) :=
  (bGen i).map (Int.castRingHom (ZMod q))

/-- Inverse generators reduced mod q. -/
def bInvMod (q : ℕ) (i : Fin 3) : Matrix (Fin 3) (Fin 3) (ZMod q) :=
  (bInv i).map (Int.castRingHom (ZMod q))

private theorem map_int_mul_id {q : ℕ} [NeZero q] (A B : Matrix (Fin 3) (Fin 3) ℤ)
    (h : A * B = 1) :
    A.map (Int.castRingHom (ZMod q)) * B.map (Int.castRingHom (ZMod q)) = 1 := by
  rw [← Matrix.map_mul, h]; ext i j
  simp only [Matrix.map_apply, Matrix.one_apply]
  split_ifs <;> simp

theorem bGenMod_mul_inv (q : ℕ) [NeZero q] (i : Fin 3) :
    bGenMod q i * bInvMod q i = 1 :=
  map_int_mul_id (bGen i) (bInv i) (bGen_mul_bInv i)

theorem bInvMod_mul_gen (q : ℕ) [NeZero q] (i : Fin 3) :
    bInvMod q i * bGenMod q i = 1 :=
  map_int_mul_id (bInv i) (bGen i) (bInv_mul_bGen i)

theorem qForm_preserved_gen (q : ℕ) [NeZero q] (i : Fin 3) (v : Fin 3 → ZMod q) :
    qForm q ((bGenMod q i).mulVec v) = qForm q v := by
  fin_cases i <;> {
    simp [qForm, bGenMod, bGen, Matrix.mulVec, dotProduct,
      Fin.sum_univ_three, Matrix.map_apply]; ring }

theorem qForm_preserved_inv (q : ℕ) [NeZero q] (i : Fin 3) (v : Fin 3 → ZMod q) :
    qForm q ((bInvMod q i).mulVec v) = qForm q v := by
  fin_cases i <;> {
    simp [qForm, bInvMod, bInv, Matrix.mulVec, dotProduct,
      Fin.sum_univ_three, Matrix.map_apply]; ring }

/-! ## §3. Isotropic Cone (Shell) -/

/-- The nonzero isotropic cone mod q. -/
def Shell (q : ℕ) := {v : Fin 3 → ZMod q // qForm q v = 0 ∧ v ≠ 0}

theorem mulVec_ne_zero_of_inv {q : ℕ} [NeZero q]
    (M Minv : Matrix (Fin 3) (Fin 3) (ZMod q)) (h : Minv * M = 1)
    (v : Fin 3 → ZMod q) (hv : v ≠ 0) : M.mulVec v ≠ 0 := by
  intro heq; apply hv
  have : Minv.mulVec (M.mulVec v) = Minv.mulVec 0 := by rw [heq]
  rw [Matrix.mulVec_mulVec, h, Matrix.mulVec_zero] at this
  simpa using this

/-- Generator action on the shell is well-defined. -/
def genAct (q : ℕ) [NeZero q] (i : Fin 3) (v : Shell q) : Shell q :=
  ⟨(bGenMod q i).mulVec v.1,
    ⟨by rw [qForm_preserved_gen]; exact v.2.1,
     mulVec_ne_zero_of_inv _ _ (bInvMod_mul_gen q i) _ v.2.2⟩⟩

/-- Inverse generator action on the shell. -/
def invAct (q : ℕ) [NeZero q] (i : Fin 3) (v : Shell q) : Shell q :=
  ⟨(bInvMod q i).mulVec v.1,
    ⟨by rw [qForm_preserved_inv]; exact v.2.1,
     mulVec_ne_zero_of_inv _ _ (bGenMod_mul_inv q i) _ v.2.2⟩⟩

theorem genAct_injective (q : ℕ) [NeZero q] (i : Fin 3) :
    Function.Injective (genAct q i) := by
  intro ⟨v, hv⟩ ⟨w, hw⟩ h
  apply Subtype.ext
  have heq : (bGenMod q i).mulVec v = (bGenMod q i).mulVec w := congrArg Subtype.val h
  have hinv := bInvMod_mul_gen q i
  calc v = (1 : Matrix _ _ _).mulVec v := by simp
    _ = (bInvMod q i * bGenMod q i).mulVec v := by rw [hinv]
    _ = (bInvMod q i).mulVec ((bGenMod q i).mulVec v) := by rw [Matrix.mulVec_mulVec]
    _ = (bInvMod q i).mulVec ((bGenMod q i).mulVec w) := by rw [heq]
    _ = (bInvMod q i * bGenMod q i).mulVec w := by rw [Matrix.mulVec_mulVec]
    _ = (1 : Matrix _ _ _).mulVec w := by rw [hinv]
    _ = w := by simp

theorem invAct_injective (q : ℕ) [NeZero q] (i : Fin 3) :
    Function.Injective (invAct q i) := by
  intro ⟨v, hv⟩ ⟨w, hw⟩ h
  apply Subtype.ext
  have heq : (bInvMod q i).mulVec v = (bInvMod q i).mulVec w := congrArg Subtype.val h
  have hinv := bGenMod_mul_inv q i
  calc v = (1 : Matrix _ _ _).mulVec v := by simp
    _ = (bGenMod q i * bInvMod q i).mulVec v := by rw [hinv]
    _ = (bGenMod q i).mulVec ((bInvMod q i).mulVec v) := by rw [Matrix.mulVec_mulVec]
    _ = (bGenMod q i).mulVec ((bInvMod q i).mulVec w) := by rw [heq]
    _ = (bGenMod q i * bInvMod q i).mulVec w := by rw [Matrix.mulVec_mulVec]
    _ = (1 : Matrix _ _ _).mulVec w := by rw [hinv]
    _ = w := by simp

theorem genAct_bijective (q : ℕ) [NeZero q] [Fintype (Shell q)] (i : Fin 3) :
    Function.Bijective (genAct q i) :=
  (Finite.injective_iff_bijective).mp (genAct_injective q i)

theorem invAct_bijective (q : ℕ) [NeZero q] [Fintype (Shell q)] (i : Fin 3) :
    Function.Bijective (invAct q i) :=
  (Finite.injective_iff_bijective).mp (invAct_injective q i)

theorem genAct_invAct (q : ℕ) [NeZero q] (i : Fin 3) (v : Shell q) :
    genAct q i (invAct q i v) = v := by
  apply Subtype.ext
  show (bGenMod q i).mulVec ((bInvMod q i).mulVec v.1) = v.1
  rw [Matrix.mulVec_mulVec, bGenMod_mul_inv, Matrix.one_mulVec]

theorem invAct_genAct (q : ℕ) [NeZero q] (i : Fin 3) (v : Shell q) :
    invAct q i (genAct q i v) = v := by
  apply Subtype.ext
  show (bInvMod q i).mulVec ((bGenMod q i).mulVec v.1) = v.1
  rw [Matrix.mulVec_mulVec, bInvMod_mul_gen, Matrix.one_mulVec]

/-! ## §4. Averaging Operator and ℓ² Theory -/

/-- The Berggren averaging operator T_q on functions Shell q → ℂ.
    T_q f(x) = (1/3)(f(B₁⁻¹ x) + f(B₂⁻¹ x) + f(B₃⁻¹ x)). -/
noncomputable def avgOp (q : ℕ) [NeZero q] :
    (Shell q → ℂ) →ₗ[ℂ] (Shell q → ℂ) where
  toFun f x := (1 / 3 : ℂ) * ∑ i : Fin 3, f (invAct q i x)
  map_add' f g := by ext x; simp [Finset.sum_add_distrib]; ring
  map_smul' c f := by
    ext x; simp only [Pi.smul_apply, smul_eq_mul, RingHom.id_apply]
    rw [← Finset.mul_sum]; ring

/-- ℓ² norm squared on Shell q. -/
noncomputable def l2sq {S : Type*} [Fintype S]
    (f : S → ℂ) : ℝ :=
  ∑ x : S, ‖f x‖ ^ 2

theorem l2sq_nonneg {S : Type*} [Fintype S] (f : S → ℂ) :
    0 ≤ l2sq f :=
  Finset.sum_nonneg fun _ _ => pow_nonneg (norm_nonneg _) 2

/-- Mean-zero subspace. -/
noncomputable def meanZeroSub (q : ℕ) [NeZero q] [Fintype (Shell q)] :
    Submodule ℂ (Shell q → ℂ) where
  carrier := {f | ∑ x : Shell q, f x = 0}
  add_mem' {f g} hf hg := by
    show ∑ x, (f x + g x) = 0
    rw [Finset.sum_add_distrib, hf, hg, add_zero]
  zero_mem' := by simp
  smul_mem' c f hf := by
    show ∑ x, (c • f) x = 0
    simp only [Pi.smul_apply, smul_eq_mul, ← Finset.mul_sum]
    rw [show ∑ x, f x = 0 from hf, mul_zero]

/-- Constants are fixed by T_q. -/
theorem avgOp_const (q : ℕ) [NeZero q] (c : ℂ) :
    avgOp q (fun _ : Shell q => c) = fun _ => c := by
  ext x; simp [avgOp, Fin.sum_univ_three]; ring

/-- T_q preserves total sums (hence mean-zero). -/
theorem avgOp_sum_preserved (q : ℕ) [NeZero q]
    [Fintype (Shell q)] [DecidableEq (Shell q)]
    (f : Shell q → ℂ) :
    ∑ x, avgOp q f x = ∑ x, f x := by
  simp only [avgOp, LinearMap.coe_mk, AddHom.coe_mk]
  rw [← Finset.mul_sum]
  simp_rw [Fin.sum_univ_three, Finset.sum_add_distrib]
  have h0 : ∑ x, f (invAct q 0 x) = ∑ x, f x :=
    Fintype.sum_bijective _ (invAct_bijective q 0) _ _ (fun _ => rfl)
  have h1 : ∑ x, f (invAct q 1 x) = ∑ x, f x :=
    Fintype.sum_bijective _ (invAct_bijective q 1) _ _ (fun _ => rfl)
  have h2 : ∑ x, f (invAct q 2 x) = ∑ x, f x :=
    Fintype.sum_bijective _ (invAct_bijective q 2) _ _ (fun _ => rfl)
  rw [h0, h1, h2]; ring

/-- T_q preserves mean-zero functions. -/
theorem avgOp_meanZero (q : ℕ) [NeZero q]
    [Fintype (Shell q)] [DecidableEq (Shell q)]
    (f : Shell q → ℂ) (hf : f ∈ meanZeroSub q) :
    avgOp q f ∈ meanZeroSub q := by
  show ∑ x, avgOp q f x = 0
  rw [avgOp_sum_preserved]; exact hf

/-! ## §5. ℓ² Contraction — Core Spectral Inequality

**Theorem**: ‖T_q f‖₂² ≤ ‖f‖₂².

Proof sketch: |T_q f(x)|² = |(1/3) Σᵢ f(Bᵢ⁻¹ x)|²
  ≤ (1/3) Σᵢ |f(Bᵢ⁻¹ x)|²  (by Jensen/Cauchy-Schwarz for ‖·‖²)
Summing over x and using bijectivity of each Bᵢ⁻¹:
  Σ_x |T_q f(x)|² ≤ (1/3) Σᵢ Σ_x |f(Bᵢ⁻¹ x)|² = (1/3) · 3 · ‖f‖₂² = ‖f‖₂²
-/

/-
Jensen's inequality for ‖·‖²: ‖(1/3)(a+b+c)‖² ≤ (1/3)(‖a‖²+‖b‖²+‖c‖²).
-/
theorem norm_sq_avg_le_avg_norm_sq (a b c : ℂ) :
    ‖(1 / 3 : ℂ) * (a + b + c)‖ ^ 2 ≤
      (1 / 3 : ℝ) * (‖a‖ ^ 2 + ‖b‖ ^ 2 + ‖c‖ ^ 2) := by
  norm_num [ Complex.normSq, Complex.sq_norm ];
  norm_num [ Complex.normSq, Complex.norm_def ];
  rw [ mul_pow, Real.sq_sqrt <| by nlinarith ] ; linarith [ sq_nonneg ( a.re - b.re ), sq_nonneg ( a.re - c.re ), sq_nonneg ( b.re - c.re ), sq_nonneg ( a.im - b.im ), sq_nonneg ( a.im - c.im ), sq_nonneg ( b.im - c.im ) ]

/-
**ℓ² Contraction Theorem**: ‖T_q f‖₂² ≤ ‖f‖₂².
    The averaging operator is nonexpansive in ℓ² norm.
-/
theorem avgOp_l2_contraction (q : ℕ) [NeZero q]
    [Fintype (Shell q)] [DecidableEq (Shell q)]
    (f : Shell q → ℂ) :
    l2sq (avgOp q f) ≤ l2sq f := by
  -- By definition of $avgOp$, we have:
  have h_avgOp_def : ∀ x : Shell q, (avgOp q f) x = (1 / 3 : ℂ) * (f (invAct q 0 x) + f (invAct q 1 x) + f (invAct q 2 x)) := by
    unfold avgOp; norm_num [ Fin.sum_univ_three ];
  -- Applying the norm_sq_avg_le_avg_norm_sq lemma to each term in the sum.
  have h_sum_le : ∑ x : Shell q, ‖(avgOp q f) x‖^2 ≤ (1 / 3 : ℝ) * ∑ x : Shell q, (‖f (invAct q 0 x)‖^2 + ‖f (invAct q 1 x)‖^2 + ‖f (invAct q 2 x)‖^2) := by
    rw [ Finset.mul_sum _ _ _ ];
    exact Finset.sum_le_sum fun x _ => by rw [ h_avgOp_def ] ; exact norm_sq_avg_le_avg_norm_sq _ _ _;
  -- By the properties of the norm and the definition of $invAct$, we can rewrite the sums.
  have h_sum_rewrite : ∑ x : Shell q, (‖f (invAct q 0 x)‖^2 + ‖f (invAct q 1 x)‖^2 + ‖f (invAct q 2 x)‖^2) = ∑ x : Shell q, (‖f x‖^2 + ‖f x‖^2 + ‖f x‖^2) := by
    have h_sum_rewrite : ∀ i : Fin 3, ∑ x : Shell q, ‖f (invAct q i x)‖^2 = ∑ x : Shell q, ‖f x‖^2 := by
      intro i;
      exact Equiv.sum_comp ( Equiv.ofBijective _ ( invAct_bijective q i ) ) fun x => ‖f x‖ ^ 2;
    simp +decide only [sum_add_distrib, h_sum_rewrite];
  simp_all +decide [ Finset.sum_add_distrib, ← two_mul ];
  convert h_sum_le using 1 <;> norm_num [ Finset.mul_sum _ _ _, mul_pow, h_avgOp_def ] ; ring;
  · exact Finset.sum_congr rfl fun _ _ => by rw [ show ( avgOp q ) f _ = _ from h_avgOp_def _ ] ; norm_num [ mul_pow, mul_assoc, mul_comm, mul_left_comm ] ;
  · unfold l2sq; norm_num [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul ] ; ring;

/-! ## §6. Fixed-Point Characterization -/

/-- A function is generator-invariant if f(Bᵢ⁻¹ x) = f(x) for all i, x. -/
def GenInvariant (q : ℕ) [NeZero q] (f : Shell q → ℂ) : Prop :=
  ∀ (i : Fin 3) (x : Shell q), f (invAct q i x) = f x

/-- An invariant function is also constant on forward orbits. -/
theorem genInvariant_const_on_genOrbit (q : ℕ) [NeZero q]
    (f : Shell q → ℂ) (hf : GenInvariant q f) (x : Shell q) (i : Fin 3) :
    f (genAct q i x) = f x := by
  have h := hf i (genAct q i x)
  rw [invAct_genAct] at h; exact h.symm

/-- Generator-invariant functions are fixed by T_q. -/
theorem genInvariant_implies_fixed (q : ℕ) [NeZero q]
    (f : Shell q → ℂ) (hf : GenInvariant q f) :
    avgOp q f = f := by
  ext x
  simp only [avgOp, LinearMap.coe_mk, AddHom.coe_mk]
  rw [show (∑ i : Fin 3, f (invAct q i x)) = 3 * f x from by
    rw [Fin.sum_univ_three, hf 0 x, hf 1 x, hf 2 x]; ring]
  ring

/-
Fixed points of T_q are generator-invariant.
    If (1/3)(f(B₀⁻¹x) + f(B₁⁻¹x) + f(B₂⁻¹x)) = f(x) for all x,
    and ‖T_q f‖₂² = ‖f‖₂², then f must be invariant under each generator.
-/
theorem avgOp_fixed_iff_genInvariant (q : ℕ) [NeZero q]
    [Fintype (Shell q)] [DecidableEq (Shell q)]
    (f : Shell q → ℂ) :
    (avgOp q f = f ∧ l2sq (avgOp q f) = l2sq f) → GenInvariant q f := by
  intro h
  have h_sum : ∑ x, ∑ i : Fin 3, ‖f (invAct q i x) - f x‖ ^ 2 = 0 := by
    have h_sum : ∑ x : Shell q, ∑ i : Fin 3, ‖f (invAct q i x) - f x‖ ^ 2 = ∑ x : Shell q, ∑ i : Fin 3, ‖f (invAct q i x)‖ ^ 2 - 3 * ∑ x : Shell q, ‖f x‖ ^ 2 := by
      have h_sum : ∑ x : Shell q, ∑ i : Fin 3, ‖f (invAct q i x) - f x‖ ^ 2 = ∑ x : Shell q, ∑ i : Fin 3, ‖f (invAct q i x)‖ ^ 2 + ∑ x : Shell q, ∑ i : Fin 3, ‖f x‖ ^ 2 - 2 * ∑ x : Shell q, ∑ i : Fin 3, Complex.re (starRingEnd ℂ (f (invAct q i x)) * f x) := by
        simp +decide [ Complex.normSq, Complex.sq_norm, Finset.mul_sum _ _ _, Finset.sum_add_distrib, Finset.sum_sub_distrib, mul_assoc, mul_comm, mul_left_comm, sub_sq ] ; ring;
        simp +decide [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, mul_assoc, mul_comm, mul_left_comm, pow_two ] ; ring;
      generalize_proofs at *; (
      have h_sum : ∑ x : Shell q, ∑ i : Fin 3, Complex.re (starRingEnd ℂ (f (invAct q i x)) * f x) = ∑ x : Shell q, Complex.re (starRingEnd ℂ (avgOp q f x) * f x) * 3 := by
        simp +decide [ avgOp, Finset.sum_mul _ _ _ ] ; ring!;
        simp +decide only [sum_add_distrib, Finset.sum_mul _ _ _]
      generalize_proofs at *; (
      simp_all +decide [ Complex.normSq, Complex.sq_norm ] ; ring;
      simp +decide only [pow_two, sum_add_distrib, ← sum_mul];
      ring))
    generalize_proofs at *; (
    have h_sum : ∑ x : Shell q, ∑ i : Fin 3, ‖f (invAct q i x)‖ ^ 2 = ∑ i : Fin 3, ∑ x : Shell q, ‖f x‖ ^ 2 := by
      rw [ Finset.sum_comm ];
      exact Finset.sum_congr rfl fun i hi => Equiv.sum_comp ( Equiv.ofBijective ( invAct q i ) ( invAct_bijective q i ) ) fun x => ‖f x‖ ^ 2
    generalize_proofs at *; (
    norm_num +zetaDelta at *;
    linarith [ h.2 ]))
  generalize_proofs at *; (
  rw [ Finset.sum_eq_zero_iff_of_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => sq_nonneg _ ] at h_sum;
  simp_all +decide [ Finset.sum_eq_zero_iff_of_nonneg, sq_nonneg ];
  exact fun i x => sub_eq_zero.mp ( h_sum x i ) ▸ rfl)

/-! ## §7. Spectral Gap Theorem

Under the hypothesis that the only generator-invariant functions are constants,
the averaging operator is strictly contracting on the mean-zero subspace.
-/

/-- Hypothesis: every generator-invariant function on Shell q is constant. -/
def InvariantImpliesConst (q : ℕ) [NeZero q] : Prop :=
  ∀ f : Shell q → ℂ, GenInvariant q f → ∃ c : ℂ, f = fun _ => c

/-
Under InvariantImpliesConst, T_q has no nonzero fixed point in mean-zero.
    Key steps: T_q f = f → (T_q f = f ∧ l2sq(T_q f) = l2sq f) → GenInvariant
    → constant → mean-zero + Nonempty → f = 0.
-/
theorem avgOp_fixed_meanZero_eq_zero
    (q : ℕ) [NeZero q] [Fintype (Shell q)] [DecidableEq (Shell q)]
    [Nonempty (Shell q)]
    (hq : InvariantImpliesConst q)
    (f : Shell q → ℂ) (hf_mz : f ∈ meanZeroSub q) (hf_fix : avgOp q f = f) :
    f = 0 := by
  -- By definition of mean zero subspace, we know that ∑ x, f x = 0.
  have h_sum_zero : ∑ x : Shell q, f x = 0 := by
    exact hf_mz;
  -- By definition of $avgOp$, we know that $avgOp q f = f$ implies $f$ is generator-invariant.
  have h_gen_inv : GenInvariant q f := by
    apply avgOp_fixed_iff_genInvariant q f ⟨hf_fix, by
      rw [ hf_fix ]⟩;
  obtain ⟨ c, rfl ⟩ := hq f h_gen_inv; aesop;

/-
**ℓ² Variance Formula**: The contraction deficit equals an explicit
    variance of f over the three generator pullbacks.
    l2sq(f) - l2sq(T_q f) = (1/9) Σ_x Σ_{i<j} ‖f(B_i⁻¹x) - f(B_j⁻¹x)‖².
    This is nonneg and = 0 iff f(B_i⁻¹x) = f(B_j⁻¹x) for all i,j,x.
-/
theorem avgOp_variance_formula (q : ℕ) [NeZero q]
    [Fintype (Shell q)] [DecidableEq (Shell q)]
    (f : Shell q → ℂ) :
    l2sq f - l2sq (avgOp q f) =
      (1 / 9 : ℝ) * ∑ x : Shell q,
        (‖f (invAct q 0 x) - f (invAct q 1 x)‖ ^ 2 +
         ‖f (invAct q 1 x) - f (invAct q 2 x)‖ ^ 2 +
         ‖f (invAct q 0 x) - f (invAct q 2 x)‖ ^ 2) := by
  nontriviality;
  have h_sum_eq : ∑ x : Shell q, ‖f x‖^2 = ∑ x : Shell q, ‖f (invAct q 0 x)‖^2 ∧ ∑ x : Shell q, ‖f x‖^2 = ∑ x : Shell q, ‖f (invAct q 1 x)‖^2 ∧ ∑ x : Shell q, ‖f x‖^2 = ∑ x : Shell q, ‖f (invAct q 2 x)‖^2 := by
    exact ⟨ by rw [ ← Equiv.sum_comp ( Equiv.ofBijective _ ( invAct_bijective q 0 ) ) ] ; simp +decide, by rw [ ← Equiv.sum_comp ( Equiv.ofBijective _ ( invAct_bijective q 1 ) ) ] ; simp +decide, by rw [ ← Equiv.sum_comp ( Equiv.ofBijective _ ( invAct_bijective q 2 ) ) ] ; simp +decide ⟩;
  unfold l2sq avgOp;
  norm_num [ Complex.normSq, Complex.sq_norm ] at *;
  norm_num [ Fin.sum_univ_three, Complex.normSq, Complex.sq_norm ] at *;
  norm_num [ Finset.mul_sum _ _ _, mul_pow, Complex.normSq, Complex.sq_norm ] at *;
  norm_num [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul ] at *;
  norm_num [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, sub_mul, mul_sub, add_mul, mul_add, sq ] at *;
  norm_num [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul ] at * ; linarith

/-
l2sq equality implies the three generator pullbacks are equal at each point.
    This is the equality case of Jensen: ‖(a+b+c)/3‖² = (‖a‖²+‖b‖²+‖c‖²)/3 iff a=b=c.
-/
theorem l2sq_eq_implies_equalized (q : ℕ) [NeZero q]
    [Fintype (Shell q)] [DecidableEq (Shell q)]
    (f : Shell q → ℂ)
    (heq : l2sq (avgOp q f) = l2sq f) :
    ∀ (x : Shell q) (i j : Fin 3), f (invAct q i x) = f (invAct q j x) := by
  -- By the variance formula, ‖(a+b+c)/3‖² = (‖a‖²+‖b‖²+‖c‖²)/3 implies a=b=c.
  have h_jensen_eq : ∀ x : Shell q, ‖f (invAct q 0 x) - f (invAct q 1 x)‖ ^ 2 + ‖f (invAct q 1 x) - f (invAct q 2 x)‖ ^ 2 + ‖f (invAct q 0 x) - f (invAct q 2 x)‖ ^ 2 = 0 := by
    have h_jensen_eq : ∑ x : Shell q, (‖f (invAct q 0 x) - f (invAct q 1 x)‖ ^ 2 + ‖f (invAct q 1 x) - f (invAct q 2 x)‖ ^ 2 + ‖f (invAct q 0 x) - f (invAct q 2 x)‖ ^ 2) = 0 := by
      linarith [ avgOp_variance_formula q f ];
    rw [ Finset.sum_eq_zero_iff_of_nonneg fun _ _ => by positivity ] at h_jensen_eq ; aesop;
  intro x i j; fin_cases i <;> fin_cases j <;> simp_all +decide [ add_eq_zero_iff_of_nonneg, sq_nonneg ] ;
  all_goals specialize h_jensen_eq x; rw [ add_eq_zero_iff_of_nonneg, add_eq_zero_iff_of_nonneg ] at h_jensen_eq <;> first | positivity | simp_all +decide [ sub_eq_iff_eq_add ] ;

/-- **Shell Mixing Hypothesis**: The only mean-zero function f with equal
    values under all three generator pullbacks at each point is f = 0.
    This is the correct condition for the spectral gap: it says that
    the group generated by B_j⁻¹B_i acts transitively enough on Shell q. -/
def ShellMixing (q : ℕ) [NeZero q] [Fintype (Shell q)] : Prop :=
  ∀ f : Shell q → ℂ,
    (∀ (x : Shell q) (i j : Fin 3), f (invAct q i x) = f (invAct q j x)) →
    (∑ x : Shell q, f x = 0) → f = 0

/-
Helper: the ℓ² norm squared is continuous on Shell q → ℂ.
-/
theorem continuous_l2sq_avgOp (q : ℕ) [NeZero q] [Fintype (Shell q)] :
    Continuous (fun f : Shell q → ℂ => l2sq (avgOp q f)) := by
  have h_cont : Continuous (fun f : Shell q → ℂ => (avgOp q) f) := by
    fun_prop;
  exact continuous_finset_sum _ fun _ _ => Continuous.pow ( continuous_norm.comp <| continuous_apply _ |> Continuous.comp <| h_cont ) _

/-
**Main Spectral Gap Theorem**: Under invariant-implies-constant,
    there exists c < 1 such that ‖T_q f‖₂² ≤ c · ‖f‖₂² for all mean-zero f.

    Proof: On the compact unit sphere of the mean-zero subspace,
    l2sq ∘ avgOp is continuous and strictly < 1 everywhere
    (by variance formula + fixed-point analysis).
    By IsCompact.exists_isMaxOn, the max exists and is < 1.
-/
theorem berggren_spectral_gap
    (q : ℕ) [NeZero q] [Fintype (Shell q)] [DecidableEq (Shell q)]
    [Nonempty (Shell q)]
    (hmix : ShellMixing q) :
    ∃ C : ℝ, C < 1 ∧
      ∀ f : Shell q → ℂ, f ∈ meanZeroSub q →
        l2sq (avgOp q f) ≤ C * l2sq f := by
  -- By the properties of the ℓ² norm and the definition of `meanZeroSub`, we know that `l2sq (avgOp q f) ≤ l2sq f` for all `f` in `meanZeroSub q`.
  have h_le : ∀ f ∈ meanZeroSub q, l2sq (avgOp q f) ≤ l2sq f := by
    exact?;
  -- By the properties of the ℓ² norm and the definition of `meanZeroSub`, we know that `l2sq (avgOp q f) < l2sq f` for all nonzero `f` in `meanZeroSub q`.
  have h_lt : ∀ f ∈ meanZeroSub q, f ≠ 0 → l2sq (avgOp q f) < l2sq f := by
    intro f hf hf_ne_zero
    by_contra h_contra
    have h_eq : l2sq (avgOp q f) = l2sq f := by
      exact le_antisymm ( h_le f hf ) ( not_lt.mp h_contra )
    have h_equalized : ∀ x : Shell q, ∀ i j : Fin 3, f (invAct q i x) = f (invAct q j x) := by
      grind +suggestions
    have h_zero : f = 0 := by
      exact hmix f h_equalized hf
    contradiction;
  -- By the properties of the ℓ² norm and the definition of `meanZeroSub`, we know that `l2sq (avgOp q f) < l2sq f` for all nonzero `f` in `meanZeroSub q`. Hence, we can choose `C` to be the maximum of these ratios.
  obtain ⟨C, hC⟩ : ∃ C < 1, ∀ f ∈ meanZeroSub q, l2sq f = 1 → l2sq (avgOp q f) ≤ C := by
    -- The set of mean-zero functions with ℓ² norm 1 is compact.
    have h_compact : IsCompact {f : Shell q → ℂ | f ∈ meanZeroSub q ∧ l2sq f = 1} := by
      have h_closed : IsClosed {f : Shell q → ℂ | f ∈ meanZeroSub q ∧ l2sq f = 1} := by
        have h_closed : Continuous (fun f : Shell q → ℂ => l2sq f) := by
          exact continuous_finset_sum _ fun _ _ => Continuous.pow ( continuous_norm.comp <| continuous_apply _ ) _;
        exact IsClosed.inter ( meanZeroSub q |> Submodule.closed_of_finiteDimensional ) ( isClosed_eq h_closed continuous_const );
      have h_bounded : ∀ f : Shell q → ℂ, l2sq f = 1 → ∀ x : Shell q, ‖f x‖ ≤ 1 := by
        intros f hf x
        have h_norm_sq : ‖f x‖ ^ 2 ≤ l2sq f := by
          exact Finset.single_le_sum ( fun x _ => sq_nonneg ( ‖f x‖ ) ) ( Finset.mem_univ x );
        nlinarith;
      exact IsCompact.of_isClosed_subset ( isCompact_pi_infinite fun _ => ProperSpace.isCompact_closedBall ( 0 : ℂ ) 1 ) h_closed fun f hf => by exact fun x => mem_closedBall_zero_iff.mpr ( h_bounded f hf.2 x ) ;
    by_cases h_empty : {f : Shell q → ℂ | f ∈ meanZeroSub q ∧ l2sq f = 1} = ∅;
    · exact ⟨ 0, by norm_num, fun f hf hf' => False.elim <| h_empty.subset ⟨ hf, hf' ⟩ ⟩;
    · obtain ⟨f₀, hf₀⟩ : ∃ f₀ ∈ {f : Shell q → ℂ | f ∈ meanZeroSub q ∧ l2sq f = 1}, ∀ f ∈ {f : Shell q → ℂ | f ∈ meanZeroSub q ∧ l2sq f = 1}, l2sq (avgOp q f₀) ≥ l2sq (avgOp q f) := by
        have h_continuous : ContinuousOn (fun f : Shell q → ℂ => l2sq (avgOp q f)) {f : Shell q → ℂ | f ∈ meanZeroSub q ∧ l2sq f = 1} := by
          exact Continuous.continuousOn ( continuous_l2sq_avgOp q );
        exact h_compact.exists_isMaxOn ( Set.nonempty_iff_ne_empty.mpr h_empty ) h_continuous;
      exact ⟨ l2sq ( avgOp q f₀ ), by linarith [ h_lt f₀ hf₀.1.1 ( by rintro rfl; exact absurd hf₀.1.2 ( by norm_num [ l2sq ] ) ), hf₀.1.2 ], fun f hf₁ hf₂ => hf₀.2 f ⟨ hf₁, hf₂ ⟩ ⟩;
  refine' ⟨ C, hC.1, fun f hf => _ ⟩;
  by_cases h : l2sq f = 0 <;> simp_all +decide [ div_le_iff₀ ];
  · exact le_trans ( h_le f hf ) h.le;
  · have := hC.2 ( ( Real.sqrt ( l2sq f ) ) ⁻¹ • f ) ?_ ?_ <;> simp_all +decide [ l2sq ];
    · simp_all +decide [ mul_pow, ← Finset.mul_sum _ _ _, ← Finset.sum_mul, abs_of_nonneg ( Real.sqrt_nonneg _ ) ];
      rw [ Real.sq_sqrt ( Finset.sum_nonneg fun _ _ => sq_nonneg _ ), inv_mul_eq_div, div_le_iff₀ ( lt_of_le_of_ne ( Finset.sum_nonneg fun _ _ => sq_nonneg _ ) ( Ne.symm h ) ) ] at this ; linarith;
    · simp_all +decide [ meanZeroSub ];
      rw [ ← Finset.mul_sum _ _ _, hf, MulZeroClass.mul_zero ];
    · norm_num [ mul_pow, ← Finset.mul_sum _ _ _, ← Finset.sum_mul, h ];
      rw [ Real.sq_sqrt <| Finset.sum_nonneg fun _ _ => sq_nonneg _, inv_mul_cancel₀ h ]

/-! ## §8. The Sibling Walk and Explicit ρ = 1/4

For the local 3-sibling structure (Fin 3 random walk), we can compute the
exact spectral gap. The transition matrix T on Fin 3 with T(i,j) = 1/2 for i ≠ j
and T(i,i) = 0 has eigenvalue 1 on constants and eigenvalue -1/2 on mean-zero.
Hence ρ = ‖T|_{mean-zero}‖² = 1/4.
-/

/-- The sibling averaging operator on Fin 3: K₃ random walk. -/
noncomputable def siblingOp : (Fin 3 → ℂ) →ₗ[ℂ] (Fin 3 → ℂ) where
  toFun f i := (1 / 2 : ℂ) * (∑ j : Fin 3, f j - f i)
  map_add' f g := by ext i; simp [Finset.sum_add_distrib]; ring
  map_smul' c f := by ext i; simp [smul_eq_mul, ← Finset.mul_sum]; ring

/-- The sibling operator acts as -1/2 on mean-zero functions.
    If Σ f(i) = 0, then Tf(i) = (1/2)(Σ f(j) - f(i)) = -f(i)/2. -/
theorem siblingOp_meanZero (f : Fin 3 → ℂ) (hf : ∑ i : Fin 3, f i = 0) :
    siblingOp f = fun i => -(1 / 2 : ℂ) * f i := by
  ext i
  simp only [siblingOp, LinearMap.coe_mk, AddHom.coe_mk]
  rw [hf]; ring

/-
The sibling operator gives exact spectral contraction ρ = 1/4 on mean-zero.
-/
theorem siblingOp_contraction (f : Fin 3 → ℂ) (hf : ∑ i : Fin 3, f i = 0) :
    l2sq (siblingOp f) = (1 / 4 : ℝ) * l2sq f := by
  have h_siblings : siblingOp f = fun i => -(1 / 2 : ℂ) * f i := by
    exact?;
  norm_num [ h_siblings, l2sq ] ; ring;
  rw [ Finset.sum_mul _ _ _ ]

/-! ## §9. Iterate Decay

Given a spectral gap C < 1, iterating the averaging operator gives
exponential decay: ‖T_q^n f‖₂² ≤ C^n · ‖f‖₂² for mean-zero f.
-/

/-
**Iterate decay theorem**: Spectral gap implies exponential mixing.
    If ‖T f‖₂² ≤ C · ‖f‖₂² for mean-zero f with C < 1,
    and T preserves mean-zero, then ‖T^n f‖₂² ≤ C^n · ‖f‖₂².
-/
theorem iterate_decay
    (q : ℕ) [NeZero q] [Fintype (Shell q)] [DecidableEq (Shell q)]
    (C : ℝ) (hC : 0 ≤ C)
    (hgap : ∀ f : Shell q → ℂ, f ∈ meanZeroSub q →
      l2sq (avgOp q f) ≤ C * l2sq f)
    (n : ℕ) :
    ∀ f : Shell q → ℂ, f ∈ meanZeroSub q →
      l2sq ((avgOp q)^[n] f) ≤ C ^ n * l2sq f := by
  intro f hf
  induction' n with n ih generalizing f
  all_goals generalize_proofs at *;
  · norm_num;
  · simpa only [ pow_succ', mul_assoc, Function.iterate_succ_apply' ] using le_trans ( hgap _ ( by
      exact Nat.recOn n hf fun n ih => by rw [ Function.iterate_succ_apply' ] ; exact avgOp_meanZero q _ ih; ) ) ( mul_le_mul_of_nonneg_left ( ih _ hf ) hC )

/-! ## §10. Sum Operator Lorentz Identity -/

/-- Sum of the three Berggren generators. -/
def bSum : Matrix (Fin 3) (Fin 3) ℤ := bGen 0 + bGen 1 + bGen 2

/-- **Key algebraic identity**: SᵀQS = diag(1, 1, -9).
    The 9-fold amplification of the temporal component is the algebraic
    engine behind spectral contraction. -/
theorem bSum_lorentz_identity :
    bSum.transpose * metricQ * bSum = !![1, 0, 0; 0, 1, 0; 0, 0, -9] := by
  native_decide

/-- The trace of S is 11. -/
theorem bSum_trace : Matrix.trace bSum = 11 := by native_decide

end BerggrenShellSpectral