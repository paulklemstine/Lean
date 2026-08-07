/-
  # Cycle 5b: Entanglement Monotonicity as a Topological Degree Bound (Conjecture D)

  Conjecture D of the previous cycle: under a *non-unitary* local operation `A ⊗ B` with
  `A`, `B` contractions (a local filtering), the concurrence satisfies
  `C(A⊗B ψ) ≤ C(ψ)`, and consequently the linking number of the two Hopf circles is never
  increased by a local operation.  The cycle already contained the exact algebraic
  transformation law `entanglementDet_localAct : det(A⊗Bψ) = det A · det B · det ψ`; what
  was missing was the analytic input `|det A| ≤ 1` for a contraction `A`.

  This file supplies it.  The `2 × 2` Hadamard inequality
  `|det A|² ≤ ‖col₁‖² ‖col₂‖²` is *not* imported: it is derived from the complex Lagrange
  identity already proved in `QubitQuditConcurrence.lean`, so the analytic half of
  Conjecture D is itself a corollary of the Bloch-gap machinery.

  Main results.

  * `hadamard_two` — `|det A|² ≤ ‖col₁‖²‖col₂‖²`, with the defect identified as `|⟨c₁,c₂⟩|²`.
  * `normSq_det_le_one_of_contraction` — a contraction has `|det A| ≤ 1`.
  * `concurrence_localAct` — the exact transformation law
    `C(A⊗Bψ) = ‖det A‖ · ‖det B‖ · C(ψ)`.
  * `concurrence_localFiltering_le` — **entanglement monotonicity**: local filtering never
    increases the concurrence.
  * `linkingNumber_localAct_le` — **topological monotonicity**: if the filtered state is
    linked then the original state was already linked; a local operation can create no
    linking.  Combined with `HopfLink.entangled_iff_linked` this says the `{0,1}`-valued
    topological invariant is an entanglement monotone for *arbitrary* local operations.
  * `concurrence_localAct_unitary` — equality for unitaries, so the bound is sharp.

  -- !-- Lab Notes -- !--
  HYPOTHESIS (Hypothesizer): monotonicity of the topological invariant is purely a
  determinant statement — `det A · det B ≠ 0` is what can destroy, but never create, a link.
  EXPERIMENT (Experimenter): specialise `QubitQudit.lagrange_complex` to the two columns of
  a `2 × 2` matrix; the four-term sum collapses to `2|det A|²`, giving Hadamard for free.
  ANALYSIS (Analyst): "contraction" is formalised through the Euclidean quadratic form
  (`IsContraction`), avoiding any operator-norm instance; testing it on the two standard
  basis vectors is all that the determinant bound needs.
  CRITIQUE (Critic): the converse of `linkingNumber_localAct_le` is false — a filtering can
  destroy entanglement (take `A` of rank one), which is exactly why only one implication is
  claimed; `linkingNumber_rankOne_zero` records the boundary case.
-/
import Mathlib
import Bridges.QuantumSystems.QuantumEntanglementLinkingNumber
import Pythagorean.QubitQuditConcurrence
import Pythagorean.HopfLinkingEntanglement
import Pythagorean.EntanglementInvariance

open Complex Finset Matrix TwoQubitState

noncomputable section

namespace LocalFiltering

/-! ## Hadamard's inequality for `2 × 2` matrices, from the Lagrange identity -/

/-- **Hadamard's inequality in dimension two**, with the defect identified: the squared
modulus of the determinant plus the squared modulus of the inner product of the two
columns equals the product of their squared norms. -/
theorem hadamard_two_eq (A : Matrix (Fin 2) (Fin 2) ℂ) :
    Complex.normSq A.det
        + Complex.normSq (∑ i, A i 0 * (starRingEnd ℂ) (A i 1))
      = (∑ i, Complex.normSq (A i 0)) * (∑ i, Complex.normSq (A i 1)) := by
  have h := QubitQudit.lagrange_complex (fun i => A i 0) (fun i => A i 1)
  have hdet : A.det = A 0 0 * A 1 1 - A 1 0 * A 0 1 := by
    rw [Matrix.det_fin_two]; ring
  simp only [Fin.sum_univ_two] at h ⊢
  rw [hdet]
  have hswap : Complex.normSq (A 1 0 * A 0 1 - A 0 0 * A 1 1)
      = Complex.normSq (A 0 0 * A 1 1 - A 1 0 * A 0 1) := by
    rw [show A 1 0 * A 0 1 - A 0 0 * A 1 1 = -(A 0 0 * A 1 1 - A 1 0 * A 0 1) by ring]
    exact Complex.normSq_neg _
  simp only [sub_self, Complex.normSq_zero, zero_add, add_zero, hswap] at h
  linarith

/-- Hadamard's inequality proper. -/
theorem hadamard_two (A : Matrix (Fin 2) (Fin 2) ℂ) :
    Complex.normSq A.det ≤ (∑ i, Complex.normSq (A i 0)) * (∑ i, Complex.normSq (A i 1)) := by
  have h := hadamard_two_eq A
  nlinarith [Complex.normSq_nonneg (∑ i, A i 0 * (starRingEnd ℂ) (A i 1))]

/-! ## Contractions -/

/-- `A` is a contraction for the Euclidean quadratic form: it never increases
`∑ᵢ |vᵢ|²`.  (Stated through `normSq` so that no normed-space instance on `Fin 2 → ℂ`
is involved.) -/
def IsContraction (A : Matrix (Fin 2) (Fin 2) ℂ) : Prop :=
  ∀ v : Fin 2 → ℂ, ∑ i, Complex.normSq (A.mulVec v i) ≤ ∑ i, Complex.normSq (v i)

/-- The columns of a contraction have squared norm at most one. -/
theorem column_normSq_le_one {A : Matrix (Fin 2) (Fin 2) ℂ} (hA : IsContraction A) (j : Fin 2) :
    ∑ i, Complex.normSq (A i j) ≤ 1 := by
  have h := hA (Pi.single j 1)
  have hcol : ∀ i, A.mulVec (Pi.single j 1) i = A i j := by
    intro i
    simp [Matrix.mulVec, dotProduct, Pi.single_apply, Finset.sum_ite_eq']
  have hv : ∑ i, Complex.normSq ((Pi.single j 1 : Fin 2 → ℂ) i) = 1 := by
    simp [Pi.single_apply, Finset.sum_ite_eq']
  simp only [hcol, hv] at h
  exact h

/-- **A contraction has determinant of modulus at most one.**  This is the analytic input
that Conjecture D was missing. -/
theorem normSq_det_le_one_of_contraction {A : Matrix (Fin 2) (Fin 2) ℂ} (hA : IsContraction A) :
    Complex.normSq A.det ≤ 1 := by
  have h0 := column_normSq_le_one hA 0
  have h1 := column_normSq_le_one hA 1
  have hn0 : (0 : ℝ) ≤ ∑ i, Complex.normSq (A i 0) :=
    Finset.sum_nonneg fun _ _ => Complex.normSq_nonneg _
  have hn1 : (0 : ℝ) ≤ ∑ i, Complex.normSq (A i 1) :=
    Finset.sum_nonneg fun _ _ => Complex.normSq_nonneg _
  have := hadamard_two A
  nlinarith

theorem norm_det_le_one_of_contraction {A : Matrix (Fin 2) (Fin 2) ℂ} (hA : IsContraction A) :
    ‖A.det‖ ≤ 1 := by
  have h := normSq_det_le_one_of_contraction hA
  rw [Complex.normSq_eq_norm_sq] at h
  nlinarith [norm_nonneg A.det]

/-- A unitary is a contraction. -/
theorem isContraction_of_unitary {A : Matrix (Fin 2) (Fin 2) ℂ} (hA : Aᴴ * A = 1) :
    IsContraction A := by
  intro v
  have key : ∀ w : Fin 2 → ℂ,
      ((∑ i, Complex.normSq (w i) : ℝ) : ℂ) = ∑ i, (starRingEnd ℂ) (w i) * w i := by
    intro w
    push_cast
    exact Finset.sum_congr rfl fun i _ => (Complex.normSq_eq_conj_mul_self)
  have hquad : ∑ i, (starRingEnd ℂ) (A.mulVec v i) * A.mulVec v i
      = ∑ i, (starRingEnd ℂ) (v i) * v i := by
    have expand : ∀ i, (starRingEnd ℂ) (A.mulVec v i) * A.mulVec v i
        = ∑ j, ∑ k, (starRingEnd ℂ) (A i j) * (starRingEnd ℂ) (v j) * (A i k * v k) := by
      intro i
      simp only [Matrix.mulVec, dotProduct, map_sum, map_mul, Finset.sum_mul,
        Finset.mul_sum]
      exact Finset.sum_comm
    simp only [expand]
    rw [Finset.sum_comm]
    have : ∀ j, ∑ i, ∑ k, (starRingEnd ℂ) (A i j) * (starRingEnd ℂ) (v j) * (A i k * v k)
        = ∑ k, (starRingEnd ℂ) (v j) * v k * (Aᴴ * A) j k := by
      intro j
      rw [Finset.sum_comm]
      refine Finset.sum_congr rfl fun k _ => ?_
      rw [Matrix.mul_apply]
      simp only [Matrix.conjTranspose_apply, RCLike.star_def, Finset.mul_sum]
      exact Finset.sum_congr rfl fun i _ => by ring
    simp only [this, hA]
    simp only [Matrix.one_apply, mul_ite, mul_one, mul_zero, Finset.sum_ite_eq, Finset.mem_univ,
      if_true]
  have hcast : ((∑ i, Complex.normSq (A.mulVec v i) : ℝ) : ℂ)
      = ((∑ i, Complex.normSq (v i) : ℝ) : ℂ) := by
    rw [key, key]; exact hquad
  exact le_of_eq (by exact_mod_cast hcast)

/-! ## Monotonicity of the concurrence -/

/-- **Exact transformation law of the concurrence** under a local operation. -/
theorem concurrence_localAct (A B : Matrix (Fin 2) (Fin 2) ℂ) (ψ : TwoQubitState) :
    (EntanglementInvariance.localAct A B ψ).concurrence = ‖A.det‖ * ‖B.det‖ * ψ.concurrence := by
  rw [TwoQubitState.concurrence, TwoQubitState.concurrence,
    EntanglementInvariance.entanglementDet_localAct, norm_mul, norm_mul]
  ring

/-- **Entanglement monotonicity (Conjecture D).**  A local filtering by contractions never
increases the concurrence. -/
theorem concurrence_localFiltering_le {A B : Matrix (Fin 2) (Fin 2) ℂ} (hA : IsContraction A)
    (hB : IsContraction B) (ψ : TwoQubitState) :
    (EntanglementInvariance.localAct A B ψ).concurrence ≤ ψ.concurrence := by
  rw [concurrence_localAct]
  have hA1 := norm_det_le_one_of_contraction hA
  have hB1 := norm_det_le_one_of_contraction hB
  have hC : 0 ≤ ψ.concurrence := by
    rw [TwoQubitState.concurrence]; positivity
  have hAB : ‖A.det‖ * ‖B.det‖ ≤ 1 :=
    mul_le_one₀ hA1 (norm_nonneg _) hB1
  nlinarith [hC, hAB]

/-- Sharpness: for unitaries the inequality is an equality. -/
theorem concurrence_localAct_unitary {A B : Matrix (Fin 2) (Fin 2) ℂ} (hA : Aᴴ * A = 1)
    (hB : Bᴴ * B = 1) (ψ : TwoQubitState) :
    (EntanglementInvariance.localAct A B ψ).concurrence = ψ.concurrence := by
  rw [concurrence_localAct, EntanglementInvariance.norm_det_of_unitary hA,
    EntanglementInvariance.norm_det_of_unitary hB]
  ring

/-! ## Monotonicity of the linking number -/

/-- **Topological monotonicity.**  A local operation can never *create* a link: if the two
Hopf circles of `A ⊗ B ψ` are linked, they were already linked for `ψ`.  No hypothesis on
`A`, `B` is needed — the statement is purely about the determinant factorisation. -/
theorem linkingNumber_localAct_le (A B : Matrix (Fin 2) (Fin 2) ℂ) (ψ : TwoQubitState)
    (h : HopfLink.stateLinkingNumber (EntanglementInvariance.localAct A B ψ) = 1) :
    HopfLink.stateLinkingNumber ψ = 1 := by
  have hne := (HopfLink.entangled_iff_linked _).2 h
  refine (HopfLink.entangled_iff_linked ψ).1 fun hc => hne ?_
  have hdet : ψ.entanglementDet = 0 := by
    have : 2 * ‖ψ.entanglementDet‖ = 0 := hc
    have : ‖ψ.entanglementDet‖ = 0 := by linarith
    exact norm_eq_zero.mp this
  rw [concurrence_localAct, TwoQubitState.concurrence, hdet]
  simp

/-- Boundary case showing the converse fails: a rank-one filtering `A = |0⟩⟨0|` destroys
all entanglement, so the linking number drops from `1` to `0`. -/
theorem linkingNumber_rankOne_zero (B : Matrix (Fin 2) (Fin 2) ℂ) (ψ : TwoQubitState) :
    HopfLink.stateLinkingNumber
      (EntanglementInvariance.localAct (Matrix.of ![![1, 0], ![0, 0]]) B ψ) = 0 := by
  refine (HopfLink.isProduct_iff_unlinked _).1 ?_
  rw [TwoQubitState.entangled_iff_det_nonzero,
    EntanglementInvariance.entanglementDet_localAct]
  have : (Matrix.of ![![1, 0], ![0, 0]] : Matrix (Fin 2) (Fin 2) ℂ).det = 0 := by
    simp [Matrix.det_fin_two]
  rw [this]
  ring

end LocalFiltering