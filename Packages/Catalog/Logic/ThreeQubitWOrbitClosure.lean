import Mathlib
import Logic.ThreeQubitGHZNormalForm
import Logic.ThreeQubitOrbitTopology

/-!
# The closure of the W orbit is the hyperdeterminant hypersurface

`Catalog/Logic/ThreeQubitGHZNormalForm.lean` proved that the three SLOCC classes of
three-qubit amplitude tensors are

* the **GHZ class** `{hyperdet ψ ≠ 0}`,
* the **W class** `{ψ genuinely entangled, hyperdet ψ = 0}`,
* the **biseparable** tensors,

and `Catalog/Logic/ThreeQubitOrbitTopology.lean` proved that the first is open and dense.
This file settles the remaining degeneration: every biseparable tensor is an arbitrarily
close limit of W-class tensors, so

`closure (W class) = { ψ | hyperdet ψ = 0 }`  (`closure_wClass`),

and the orbit closures form the chain
`{0} ⊆ product ⊆ biseparable ⊆ closure (W class) = {hyperdet = 0} ⊆ closure (GHZ class) = ⊤`
(`orbit_closure_chain`).

## Method

Four one-parameter families do all the work; each is a W-class tensor for `s ≠ 0` and
degenerates at `s = 0` onto a normal form of a biseparable tensor:

| family | `s ≠ 0` | limit `s = 0` |
| --- | --- | --- |
| `wFam0 s = ∣000⟩ + s∣101⟩ + s∣110⟩` | W class | `∣000⟩` (fully product) |
| `wFamA s = ∣000⟩ + ∣011⟩ + s∣110⟩` | W class | `∣0⟩ ⊗ (∣00⟩ + ∣11⟩)` (`A∣BC` split) |
| `wFamB s = ∣000⟩ + ∣101⟩ + s∣110⟩` | W class | `∣0⟩_B ⊗ (∣00⟩ + ∣11⟩)_{AC}` |
| `wFamC s = ∣000⟩ + ∣110⟩ + s∣011⟩` | W class | `(∣00⟩ + ∣11⟩)_{AB} ⊗ ∣0⟩_C` |

Each family is *affine* in `s`, so applying a fixed invertible `A ⊗ B ⊗ C` keeps the
dependence affine and the perturbation can be made uniformly small
(`exists_close_slocc_wState_of_localAct`).  Every biseparable tensor is an invertible local
image of one of the four limits: this is where the rank-one factorization
`exists_rank_one_factor` of the previous file and the column-extension lemma
`exists_invertible_col` enter.

## Main results

* `slocc_wFam0`, `slocc_wFamA`, `slocc_wFamB`, `slocc_wFamC` — the four families lie in the
  W class for `s ≠ 0`.
* `exists_close_slocc_wState_of_localAct` — an affine family through a biseparable normal
  form produces W-class tensors arbitrarily close to any invertible local image of it.
* `not_genuine_mem_closure_wClass` — every biseparable tensor is a limit of W-class tensors.
* `hyperdet_zero_mem_closure_wClass`, `closure_wClass` — the closure of the W class is exactly
  the hyperdeterminant hypersurface.
* `orbit_closure_chain` — the full chain of orbit closures.
-/

open Matrix

noncomputable section

namespace ThreeQubitWClosure

open ThreeQubitGHZ ThreeQubitOrbit

/-! ## Two elementary tools -/


/-- A nonzero scalar making a fixed tensor uniformly small. -/
theorem exists_small_scalar (T : Amp) {ε : ℝ} (hε : 0 < ε) :
    ∃ s : ℂ, s ≠ 0 ∧ ∀ i j k, ‖s * T i j k‖ < ε := by
  set R : ℝ := 1 + ∑ p : Fin 2 × Fin 2 × Fin 2, ‖T p.1 p.2.1 p.2.2‖ with hR
  have hsum : 0 ≤ ∑ p : Fin 2 × Fin 2 × Fin 2, ‖T p.1 p.2.1 p.2.2‖ :=
    Finset.sum_nonneg fun p _ => norm_nonneg _
  have hRpos : 0 < R := by rw [hR]; linarith
  have hle : ∀ i j k, ‖T i j k‖ ≤ R := by
    intro i j k
    have h1 := Finset.single_le_sum
      (f := fun p : Fin 2 × Fin 2 × Fin 2 => ‖T p.1 p.2.1 p.2.2‖)
      (fun p _ => norm_nonneg _) (Finset.mem_univ (i, j, k))
    rw [hR]
    simp only at h1
    linarith
  refine ⟨((ε / (2 * R) : ℝ) : ℂ), ?_, ?_⟩
  · simp only [ne_eq, Complex.ofReal_eq_zero]
    positivity
  · intro i j k
    rw [norm_mul, Complex.norm_real, Real.norm_eq_abs, abs_of_pos (by positivity)]
    have h1 : ‖T i j k‖ ≤ R := hle i j k
    have h2 : ε / (2 * R) * ‖T i j k‖ ≤ ε / (2 * R) * R :=
      mul_le_mul_of_nonneg_left h1 (by positivity)
    have h3 : ε / (2 * R) * R = ε / 2 := by field_simp
    linarith

/-- Any nonzero vector is the first column of an invertible `2 × 2` matrix. -/
theorem exists_invertible_col {u : Fin 2 → ℂ} (hu : ¬ ∀ i, u i = 0) :
    ∃ A : Matrix (Fin 2) (Fin 2) ℂ, A.det ≠ 0 ∧ ∀ i, A i 0 = u i := by
  by_cases h0 : u 0 = 0
  · have h1 : u 1 ≠ 0 := by
      intro h1
      exact hu fun i => by fin_cases i <;> assumption
    refine ⟨!![u 0, 1; u 1, 0], ?_, ?_⟩
    · rw [Matrix.det_fin_two]
      simpa using h1
    · intro i; fin_cases i <;> simp
  · refine ⟨!![u 0, 0; u 1, 1], ?_, ?_⟩
    · rw [Matrix.det_fin_two]
      simpa using h0
    · intro i; fin_cases i <;> simp

/-- Rescaling by a nonzero scalar is a SLOCC operation. -/
theorem slocc_smul {s : ℂ} (hs : s ≠ 0) (a : Amp) :
    SLOCC (fun i j k => s * a i j k) a := by
  refine ⟨!![s⁻¹, 0; 0, s⁻¹], 1, 1, ?_, ?_, ?_, ?_⟩
  · rw [Matrix.det_fin_two]
    simp
    exact hs
  · rw [Matrix.det_one]; exact one_ne_zero
  · rw [Matrix.det_one]; exact one_ne_zero
  · funext i j k
    simp only [localAct, Fin.sum_univ_two, Matrix.one_apply]
    fin_cases i <;> fin_cases j <;> fin_cases k <;>
      simp <;> field_simp

/-! ## The four degenerating families -/

/-- `∣000⟩ + s∣101⟩ + s∣110⟩`: degenerates onto a fully product tensor. -/
def wFam0 (s : ℂ) : Amp := ![![![1, 0], ![0, 0]], ![![0, s], ![s, 0]]]

/-- `∣000⟩ + ∣011⟩ + s∣110⟩`: degenerates onto an `A ∣ BC` biseparable tensor. -/
def wFamA (s : ℂ) : Amp := ![![![1, 0], ![0, 1]], ![![0, 0], ![s, 0]]]

/-- `∣000⟩ + ∣101⟩ + s∣110⟩`: degenerates onto a `B ∣ AC` biseparable tensor. -/
def wFamB (s : ℂ) : Amp := ![![![1, 0], ![0, 0]], ![![0, 1], ![s, 0]]]

/-- `∣000⟩ + ∣110⟩ + s∣011⟩`: degenerates onto a `C ∣ AB` biseparable tensor. -/
def wFamC (s : ℂ) : Amp := ![![![1, 0], ![0, s]], ![![0, 0], ![1, 0]]]

theorem hyperdet_wFam0 (s : ℂ) : hyperdet (wFam0 s) = 0 := by
  simp only [hyperdet, wFam0, Matrix.cons_val_zero, Matrix.cons_val_one]
  ring

theorem hyperdet_wFamA (s : ℂ) : hyperdet (wFamA s) = 0 := by
  simp only [hyperdet, wFamA, Matrix.cons_val_zero, Matrix.cons_val_one]
  ring

theorem hyperdet_wFamB (s : ℂ) : hyperdet (wFamB s) = 0 := by
  simp only [hyperdet, wFamB, Matrix.cons_val_zero, Matrix.cons_val_one]
  ring

theorem hyperdet_wFamC (s : ℂ) : hyperdet (wFamC s) = 0 := by
  simp only [hyperdet, wFamC, Matrix.cons_val_zero, Matrix.cons_val_one]
  ring

theorem genuine_wFam0 {s : ℂ} (hs : s ≠ 0) : Genuine (wFam0 s) := by
  refine ⟨?_, ?_, ?_⟩
  · rw [isProductA_iff_minors]
    intro h
    have := h 0 0 0 1
    simp only [wFam0, Matrix.cons_val_zero, Matrix.cons_val_one] at this
    exact hs (by linear_combination this)
  · rw [isProductB_iff_minors]
    intro h
    have := h 0 0 1 0
    simp only [wFam0, Matrix.cons_val_zero, Matrix.cons_val_one] at this
    exact hs (by linear_combination this)
  · rw [isProductC_iff_minors]
    intro h
    have := h 0 0 1 0
    simp only [wFam0, Matrix.cons_val_zero, Matrix.cons_val_one] at this
    exact hs (by linear_combination this)

theorem genuine_wFamA {s : ℂ} (hs : s ≠ 0) : Genuine (wFamA s) := by
  refine ⟨?_, ?_, ?_⟩
  · rw [isProductA_iff_minors]
    intro h
    have := h 1 0 1 1
    simp only [wFamA, Matrix.cons_val_zero, Matrix.cons_val_one] at this
    exact hs (by linear_combination -this)
  · rw [isProductB_iff_minors]
    intro h
    have := h 0 0 0 1
    simp only [wFamA, Matrix.cons_val_zero, Matrix.cons_val_one] at this
    norm_num at this
  · rw [isProductC_iff_minors]
    intro h
    have := h 0 0 0 1
    simp only [wFamA, Matrix.cons_val_zero, Matrix.cons_val_one] at this
    norm_num at this

theorem genuine_wFamB {s : ℂ} (hs : s ≠ 0) : Genuine (wFamB s) := by
  refine ⟨?_, ?_, ?_⟩
  · rw [isProductA_iff_minors]
    intro h
    have := h 0 0 0 1
    simp only [wFamB, Matrix.cons_val_zero, Matrix.cons_val_one] at this
    norm_num at this
  · rw [isProductB_iff_minors]
    intro h
    have := h 0 0 1 0
    simp only [wFamB, Matrix.cons_val_zero, Matrix.cons_val_one] at this
    exact hs (by linear_combination this)
  · rw [isProductC_iff_minors]
    intro h
    have := h 0 0 1 0
    simp only [wFamB, Matrix.cons_val_zero, Matrix.cons_val_one] at this
    norm_num at this

theorem genuine_wFamC {s : ℂ} (hs : s ≠ 0) : Genuine (wFamC s) := by
  refine ⟨?_, ?_, ?_⟩
  · rw [isProductA_iff_minors]
    intro h
    have := h 1 1 1 0
    simp only [wFamC, Matrix.cons_val_zero, Matrix.cons_val_one] at this
    exact hs (by linear_combination this)
  · rw [isProductB_iff_minors]
    intro h
    have := h 0 0 1 0
    simp only [wFamC, Matrix.cons_val_zero, Matrix.cons_val_one] at this
    norm_num at this
  · rw [isProductC_iff_minors]
    intro h
    have := h 0 0 0 1
    simp only [wFamC, Matrix.cons_val_zero, Matrix.cons_val_one] at this
    exact hs (by linear_combination this)

theorem slocc_wFam0 {s : ℂ} (hs : s ≠ 0) : SLOCC (wFam0 s) wState :=
  (slocc_wState_iff _).2 ⟨genuine_wFam0 hs, hyperdet_wFam0 s⟩

theorem slocc_wFamA {s : ℂ} (hs : s ≠ 0) : SLOCC (wFamA s) wState :=
  (slocc_wState_iff _).2 ⟨genuine_wFamA hs, hyperdet_wFamA s⟩

theorem slocc_wFamB {s : ℂ} (hs : s ≠ 0) : SLOCC (wFamB s) wState :=
  (slocc_wState_iff _).2 ⟨genuine_wFamB hs, hyperdet_wFamB s⟩

theorem slocc_wFamC {s : ℂ} (hs : s ≠ 0) : SLOCC (wFamC s) wState :=
  (slocc_wState_iff _).2 ⟨genuine_wFamC hs, hyperdet_wFamC s⟩

/-! ## The approximation lemma -/

/-- If `F` is an affine family of tensors whose members are in the W class for `s ≠ 0`, then
every invertible local image of the limit `F 0` is an arbitrarily close limit of W-class
tensors. -/
theorem exists_close_slocc_wState_of_localAct
    {A B C : Matrix (Fin 2) (Fin 2) ℂ} (hA : A.det ≠ 0) (hB : B.det ≠ 0) (hC : C.det ≠ 0)
    {F : ℂ → Amp} {base D a : Amp}
    (hF : ∀ s i j k, F s i j k = base i j k + s * D i j k)
    (hslocc : ∀ s : ℂ, s ≠ 0 → SLOCC (F s) wState)
    (hbase : localAct A B C base = a)
    {ε : ℝ} (hε : 0 < ε) :
    ∃ b : Amp, (∀ i j k, ‖b i j k - a i j k‖ < ε) ∧ SLOCC b wState := by
  obtain ⟨s, hs, hsmall⟩ := exists_small_scalar (localAct A B C D) hε
  refine ⟨localAct A B C (F s), ?_, ?_⟩
  · intro i j k
    have hdiff : localAct A B C (F s) i j k - a i j k = s * localAct A B C D i j k := by
      rw [← hbase]
      simp only [localAct, Fin.sum_univ_two, hF]
      ring
    rw [hdiff]
    exact hsmall i j k
  · have h1 : SLOCC (F s) (localAct A B C (F s)) := ⟨A, B, C, hA, hB, hC, rfl⟩
    exact SLOCC.trans h1.symm (hslocc s hs)

/-! ## Local images of the four limits -/

theorem localAct_wFam0_zero (A B C : Matrix (Fin 2) (Fin 2) ℂ) (i j k : Fin 2) :
    localAct A B C (wFam0 0) i j k = A i 0 * B j 0 * C k 0 := by
  simp only [localAct, wFam0, Fin.sum_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one]
  ring

theorem localAct_wFamA_zero (A B : Matrix (Fin 2) (Fin 2) ℂ) (i j k : Fin 2) :
    localAct A B 1 (wFamA 0) i j k = A i 0 * B j k := by
  simp only [localAct, wFamA, Fin.sum_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one,
    Matrix.one_apply]
  fin_cases k <;> norm_num

theorem localAct_wFamB_zero (A B : Matrix (Fin 2) (Fin 2) ℂ) (i j k : Fin 2) :
    localAct A B 1 (wFamB 0) i j k = A i k * B j 0 := by
  simp only [localAct, wFamB, Fin.sum_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one,
    Matrix.one_apply]
  fin_cases k <;> norm_num

theorem localAct_wFamC_zero (A C : Matrix (Fin 2) (Fin 2) ℂ) (i j k : Fin 2) :
    localAct A 1 C (wFamC 0) i j k = A i j * C k 0 := by
  simp only [localAct, wFamC, Fin.sum_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one,
    Matrix.one_apply]
  fin_cases j <;> norm_num

/-! ## Affine structure of the families -/

/-- `∣101⟩ + ∣110⟩`. -/
def dFam0 : Amp := ![![![0, 0], ![0, 0]], ![![0, 1], ![1, 0]]]

/-- `∣110⟩`. -/
def dFam110 : Amp := ![![![0, 0], ![0, 0]], ![![0, 0], ![1, 0]]]

/-- `∣011⟩`. -/
def dFam011 : Amp := ![![![0, 0], ![0, 1]], ![![0, 0], ![0, 0]]]

theorem wFam0_affine (s : ℂ) (i j k : Fin 2) :
    wFam0 s i j k = wFam0 0 i j k + s * dFam0 i j k := by
  fin_cases i <;> fin_cases j <;> fin_cases k <;> simp [wFam0, dFam0]

theorem wFamA_affine (s : ℂ) (i j k : Fin 2) :
    wFamA s i j k = wFamA 0 i j k + s * dFam110 i j k := by
  fin_cases i <;> fin_cases j <;> fin_cases k <;> simp [wFamA, dFam110]

theorem wFamB_affine (s : ℂ) (i j k : Fin 2) :
    wFamB s i j k = wFamB 0 i j k + s * dFam110 i j k := by
  fin_cases i <;> fin_cases j <;> fin_cases k <;> simp [wFamB, dFam110]

theorem wFamC_affine (s : ℂ) (i j k : Fin 2) :
    wFamC s i j k = wFamC 0 i j k + s * dFam011 i j k := by
  fin_cases i <;> fin_cases j <;> fin_cases k <;> simp [wFamC, dFam011]

/-! ## Every biseparable tensor is a limit of W-class tensors -/

/-- The zero tensor is a limit of W-class tensors. -/
theorem zero_mem_closure_wClass {a : Amp} (ha : ∀ i j k, a i j k = 0) {ε : ℝ} (hε : 0 < ε) :
    ∃ b : Amp, (∀ i j k, ‖b i j k - a i j k‖ < ε) ∧ SLOCC b wState := by
  refine exists_close_slocc_wState_of_localAct (A := 1) (B := 1) (C := 1)
    (by rw [Matrix.det_one]; exact one_ne_zero) (by rw [Matrix.det_one]; exact one_ne_zero)
    (by rw [Matrix.det_one]; exact one_ne_zero)
    (F := fun s => fun i j k => s * wState i j k) (base := fun _ _ _ => (0 : ℂ)) (D := wState)
    (fun s i j k => by simp) (fun s hs => slocc_smul hs wState) ?_ hε
  rw [localAct_one]
  funext i j k
  exact (ha i j k).symm

/-- A fully product tensor is a limit of W-class tensors. -/
theorem product_mem_closure_wClass {a : Amp} {u v w : Fin 2 → ℂ}
    (hu : ¬ ∀ i, u i = 0) (hv : ¬ ∀ j, v j = 0) (hw : ¬ ∀ k, w k = 0)
    (ha : ∀ i j k, a i j k = u i * v j * w k) {ε : ℝ} (hε : 0 < ε) :
    ∃ b : Amp, (∀ i j k, ‖b i j k - a i j k‖ < ε) ∧ SLOCC b wState := by
  obtain ⟨A, hA, hAu⟩ := exists_invertible_col hu
  obtain ⟨B, hB, hBv⟩ := exists_invertible_col hv
  obtain ⟨C, hC, hCw⟩ := exists_invertible_col hw
  refine exists_close_slocc_wState_of_localAct hA hB hC
    (F := wFam0) (D := dFam0) wFam0_affine (fun s hs => slocc_wFam0 hs) ?_ hε
  funext i j k
  rw [localAct_wFam0_zero, ha i j k, hAu i, hBv j, hCw k]

/-- A tensor that factorizes across the `A ∣ BC` cut is a limit of W-class tensors. -/
theorem productA_mem_closure_wClass {a : Amp} {u : Fin 2 → ℂ} {v : Fin 2 → Fin 2 → ℂ}
    (hu : ¬ ∀ i, u i = 0) (hv : v 0 0 * v 1 1 - v 0 1 * v 1 0 ≠ 0)
    (ha : ∀ i j k, a i j k = u i * v j k) {ε : ℝ} (hε : 0 < ε) :
    ∃ b : Amp, (∀ i j k, ‖b i j k - a i j k‖ < ε) ∧ SLOCC b wState := by
  obtain ⟨A, hA, hAu⟩ := exists_invertible_col hu
  have hB : (Matrix.of v).det ≠ 0 := by rwa [Matrix.det_fin_two]
  refine exists_close_slocc_wState_of_localAct hA hB (C := 1) (by simp)
    (F := wFamA) (D := dFam110) wFamA_affine (fun s hs => slocc_wFamA hs) ?_ hε
  funext i j k
  rw [localAct_wFamA_zero, ha i j k, hAu i]
  rfl

/-- A tensor that factorizes across the `B ∣ AC` cut is a limit of W-class tensors. -/
theorem productB_mem_closure_wClass {a : Amp} {u : Fin 2 → ℂ} {v : Fin 2 → Fin 2 → ℂ}
    (hu : ¬ ∀ j, u j = 0) (hv : v 0 0 * v 1 1 - v 0 1 * v 1 0 ≠ 0)
    (ha : ∀ i j k, a i j k = u j * v i k) {ε : ℝ} (hε : 0 < ε) :
    ∃ b : Amp, (∀ i j k, ‖b i j k - a i j k‖ < ε) ∧ SLOCC b wState := by
  obtain ⟨B, hB, hBu⟩ := exists_invertible_col hu
  have hA : (Matrix.of v).det ≠ 0 := by rwa [Matrix.det_fin_two]
  refine exists_close_slocc_wState_of_localAct hA hB (C := 1) (by simp)
    (F := wFamB) (D := dFam110) wFamB_affine (fun s hs => slocc_wFamB hs) ?_ hε
  funext i j k
  rw [localAct_wFamB_zero, ha i j k, hBu j, Matrix.of_apply]
  ring

/-- A tensor that factorizes across the `C ∣ AB` cut is a limit of W-class tensors. -/
theorem productC_mem_closure_wClass {a : Amp} {u : Fin 2 → ℂ} {v : Fin 2 → Fin 2 → ℂ}
    (hu : ¬ ∀ k, u k = 0) (hv : v 0 0 * v 1 1 - v 0 1 * v 1 0 ≠ 0)
    (ha : ∀ i j k, a i j k = u k * v i j) {ε : ℝ} (hε : 0 < ε) :
    ∃ b : Amp, (∀ i j k, ‖b i j k - a i j k‖ < ε) ∧ SLOCC b wState := by
  obtain ⟨C, hC, hCu⟩ := exists_invertible_col hu
  have hA : (Matrix.of v).det ≠ 0 := by rwa [Matrix.det_fin_two]
  refine exists_close_slocc_wState_of_localAct hA (B := 1) (by simp) hC
    (F := wFamC) (D := dFam011) wFamC_affine (fun s hs => slocc_wFamC hs) ?_ hε
  funext i j k
  rw [localAct_wFamC_zero, ha i j k, hCu k, Matrix.of_apply]
  ring

/-- **Every biseparable tensor is an arbitrarily close limit of W-class tensors.** -/
theorem not_genuine_mem_closure_wClass {a : Amp} (h : ¬ Genuine a) {ε : ℝ} (hε : 0 < ε) :
    ∃ b : Amp, (∀ i j k, ‖b i j k - a i j k‖ < ε) ∧ SLOCC b wState := by
  -- a general step: a biseparable tensor with a rank-one "matrix part" is fully product
  have hprod : ∀ {u e f : Fin 2 → ℂ}, (∀ i j k, a i j k = u i * e j * f k) →
      ∃ b : Amp, (∀ i j k, ‖b i j k - a i j k‖ < ε) ∧ SLOCC b wState := by
    intro u e f ha
    by_cases hu : ∀ i, u i = 0
    · exact zero_mem_closure_wClass (fun i j k => by rw [ha i j k, hu i]; ring) hε
    by_cases he : ∀ j, e j = 0
    · exact zero_mem_closure_wClass (fun i j k => by rw [ha i j k, he j]; ring) hε
    by_cases hf : ∀ k, f k = 0
    · exact zero_mem_closure_wClass (fun i j k => by rw [ha i j k, hf k]; ring) hε
    exact product_mem_closure_wClass hu he hf ha hε
  rw [Genuine] at h
  push_neg at h
  by_cases hA : IsProductA a
  · obtain ⟨u, v, huv⟩ := hA
    by_cases hu : ∀ i, u i = 0
    · exact zero_mem_closure_wClass (fun i j k => by rw [huv i j k, hu i]; ring) hε
    by_cases hdet : v 0 0 * v 1 1 - v 0 1 * v 1 0 = 0
    · obtain ⟨e, f, hef⟩ := exists_rank_one_factor v hdet
      exact hprod (u := u) (e := e) (f := f)
        (fun i j k => by rw [huv i j k, hef j k]; ring)
    · exact productA_mem_closure_wClass hu hdet huv hε
  by_cases hB : IsProductB a
  · obtain ⟨u, v, huv⟩ := hB
    by_cases hu : ∀ j, u j = 0
    · exact zero_mem_closure_wClass (fun i j k => by rw [huv i j k, hu j]; ring) hε
    by_cases hdet : v 0 0 * v 1 1 - v 0 1 * v 1 0 = 0
    · obtain ⟨e, f, hef⟩ := exists_rank_one_factor v hdet
      exact hprod (u := e) (e := u) (f := f)
        (fun i j k => by rw [huv i j k, hef i k]; ring)
    · exact productB_mem_closure_wClass hu hdet huv hε
  have hC : IsProductC a := h hA hB
  obtain ⟨u, v, huv⟩ := hC
  by_cases hu : ∀ k, u k = 0
  · exact zero_mem_closure_wClass (fun i j k => by rw [huv i j k, hu k]; ring) hε
  by_cases hdet : v 0 0 * v 1 1 - v 0 1 * v 1 0 = 0
  · obtain ⟨e, f, hef⟩ := exists_rank_one_factor v hdet
    exact hprod (u := e) (e := f) (f := u)
      (fun i j k => by rw [huv i j k, hef i j]; ring)
  · exact productC_mem_closure_wClass hu hdet huv hε

/-- **Every tensor on the hyperdeterminant hypersurface is a limit of W-class tensors.** -/
theorem hyperdet_zero_mem_closure_wClass {a : Amp} (h : hyperdet a = 0) {ε : ℝ} (hε : 0 < ε) :
    ∃ b : Amp, (∀ i j k, ‖b i j k - a i j k‖ < ε) ∧ SLOCC b wState := by
  by_cases hg : Genuine a
  · exact ⟨a, fun i j k => by simpa using hε, (slocc_wState_iff a).2 ⟨hg, h⟩⟩
  · exact not_genuine_mem_closure_wClass hg hε

/-- **The closure of the W SLOCC class is exactly the hyperdeterminant hypersurface.** -/
theorem closure_wClass :
    closure { a : Amp | SLOCC a wState } = { a : Amp | hyperdet a = 0 } := by
  apply subset_antisymm
  · have hclosed : IsClosed { a : Amp | hyperdet a = 0 } := by
      have : { a : Amp | hyperdet a = 0 } = hyperdet ⁻¹' {0} := rfl
      rw [this]
      exact (isClosed_singleton).preimage continuous_hyperdet
    apply closure_minimal _ hclosed
    intro a ha
    exact ((slocc_wState_iff a).1 ha).2
  · intro a ha
    rw [Metric.mem_closure_iff]
    intro ε hε
    obtain ⟨b, hb, hslocc⟩ := hyperdet_zero_mem_closure_wClass ha hε
    exact ⟨b, hslocc, dist_amp_lt hε (fun i j k => by rw [norm_sub_rev]; exact hb i j k)⟩

/-- **The chain of orbit closures.**  The biseparable tensors sit inside the closure of the W
class, which is the hyperdeterminant hypersurface, which sits inside the closure of the GHZ
class, which is everything. -/
theorem orbit_closure_chain :
    { a : Amp | ¬ Genuine a } ⊆ closure { a : Amp | SLOCC a wState } ∧
      closure { a : Amp | SLOCC a wState } = { a : Amp | hyperdet a = 0 } ∧
      closure { a : Amp | SLOCC a ghz } = Set.univ := by
  refine ⟨?_, closure_wClass, dense_ghzClass.closure_eq⟩
  intro a ha
  rw [closure_wClass]
  by_contra h
  exact ha (genuine_of_hyperdet_ne_zero h)

end ThreeQubitWClosure

end