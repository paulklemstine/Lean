import Mathlib
import Computation.EastinKnillLie

/-!
# A concrete code: the two-qubit detection code, and what it can and cannot do

The Eastin–Knill development in `Computation.EastinKnill` and
`Computation.EastinKnillLie` is stated for an abstract code with hypotheses
`Detectable` and `CodePreserving`.  This file grounds it in an explicit quantum code — the
two-qubit bit-flip *detection* code with code space spanned by `|00⟩` and `|11⟩`, i.e. the
projector `P = diag(1,0,0,1)` on `ℂ⁴` — and shows that every hypothesis used in the no-go
theorem is (a) satisfiable and (b) independent of the others.

Concretely we verify, by direct computation on `4 × 4` matrices:

* `X_first_detectable` — a single-qubit bit flip is detectable with scalar `0`: it maps the
  code space to an orthogonal subspace, which is exactly the statement that this code
  *detects* one bit flip.
* `Z_first_not_detectable` — a single-qubit phase flip is **not** detectable, for any
  scalar.  The code has distance 2 for `X`-type errors only, and the formal predicate sees
  the difference.
* `X_sum_not_codePreserving` — the transversal generator `X₁ + X₂` *is* detectable (as a
  sum of detectable terms) but does **not** preserve the code space.  So detectability
  alone does not imply code preservation: the two hypotheses of
  `eastin_knill_flow_phase` are genuinely independent.
* `logicalXX_codePreserving`, `logicalXX_not_phase` — the transversal operator `X ⊗ X`
  *does* preserve the code and implements the nontrivial logical gate `X̄` (it exchanges
  `|00⟩` and `|11⟩`), so nontrivial logical gates do exist on this code.
* `logicalXX_not_generated` — nevertheless no code-preserving detectable generator produces
  it.  Eastin–Knill on a real code.

Together the last two items sharpen the no-go statement: the obstruction is not that
nontrivial logical gates fail to exist (they do exist, and `X ⊗ X` is even transversal as
a *discrete* gate), but that they cannot be reached by a *continuous* transversal
symmetry — precisely the content of `eastin_knill_flow_phase`.

-- !-- Lab Notebook -- !--
-- Hypothesis:  `Detectable` and `CodePreserving` are independent hypotheses, and the
--   no-go theorem is not vacuous — i.e. there exists a genuine code where detectable
--   single-site errors exist and nontrivial logical gates exist.
-- Result:  Confirmed on the [[2,1,2]] detection code:
--     P X₁ P = 0            (detectable, scalar 0)
--     P Z₁ P = diag(1,0,0,-1)  (not a multiple of P: entries +1 and −1)
--     (X₁+X₂) P ≠ P (X₁+X₂) P  (detectable but leaking)
--     P (X⊗X) P = antidiag     (a genuine logical gate, code preserving)
-- Insight:  Detectability with scalar 0 means "the error is *seen*"; code preservation
--   means "the operator is *logical*".  A single-site error is detectable precisely
--   because it is not logical, and a logical gate is code preserving precisely because it
--   is not detectable-with-a-scalar.  Eastin–Knill lives exactly on the intersection of
--   the two conditions, which this code shows is (as it must be) only the phases.
-- Failure analysis:  A first attempt used the three-qubit repetition code on `ℂ⁸`; every
--   computation went through, but the `fin_cases` blow-up on `8 × 8` matrices made the
--   file slow with no extra mathematical content, so the minimal distance-2 example was
--   kept.
-/

open Matrix NormedSpace

namespace EastinKnill

/-! ## The code -/

/-- The two-qubit bit-flip **detection** code: code space `span{|00⟩, |11⟩}` inside `ℂ⁴`,
with basis order `|00⟩, |01⟩, |10⟩, |11⟩`. -/
def repCode : QECCode (Fin 4) where
  P := !![1, 0, 0, 0; 0, 0, 0, 0; 0, 0, 0, 0; 0, 0, 0, 1]
  herm := by
    ext i j; fin_cases i <;> fin_cases j <;> simp [Matrix.conjTranspose]
  idem := by
    ext i j; fin_cases i <;> fin_cases j <;> simp [Matrix.mul_apply, Fin.sum_univ_four]

/-- A bit flip on the first qubit, `X ⊗ I`. -/
def Xfirst : Matrix (Fin 4) (Fin 4) ℂ := !![0, 0, 1, 0; 0, 0, 0, 1; 1, 0, 0, 0; 0, 1, 0, 0]

/-- A bit flip on the second qubit, `I ⊗ X`. -/
def Xsecond : Matrix (Fin 4) (Fin 4) ℂ := !![0, 1, 0, 0; 1, 0, 0, 0; 0, 0, 0, 1; 0, 0, 1, 0]

/-- A phase flip on the first qubit, `Z ⊗ I`. -/
def Zfirst : Matrix (Fin 4) (Fin 4) ℂ := !![1, 0, 0, 0; 0, 1, 0, 0; 0, 0, -1, 0; 0, 0, 0, -1]

/-- The transversal operator `X ⊗ X`, which implements the logical `X̄`. -/
def logicalXX : Matrix (Fin 4) (Fin 4) ℂ := !![0, 0, 0, 1; 0, 0, 1, 0; 0, 1, 0, 0; 1, 0, 0, 0]

/-! ## Single-qubit errors: what is detected -/

/-- **A single bit flip is detected.**  `P X₁ P = 0 = 0 • P`: the error maps the code space
into its orthogonal complement, so the code detects it. -/
theorem X_first_detectable : Detectable repCode Xfirst 0 := by
  unfold Detectable repCode Xfirst
  ext i j
  fin_cases i <;> fin_cases j <;> simp [Matrix.mul_apply, Fin.sum_univ_four]

/-- The same for the second qubit. -/
theorem X_second_detectable : Detectable repCode Xsecond 0 := by
  unfold Detectable repCode Xsecond
  ext i j
  fin_cases i <;> fin_cases j <;> simp [Matrix.mul_apply, Fin.sum_univ_four]

/-- **A single phase flip is *not* detected.**  `P Z₁ P = diag(1,0,0,-1)` is not a multiple
of `P`, for any scalar: the code has distance `2` against `X`-type errors only. -/
theorem Z_first_not_detectable : ∀ c : ℂ, ¬ Detectable repCode Zfirst c := by
  intro c h
  unfold Detectable repCode Zfirst at h
  have h00 := congrArg (fun M => M 0 0) h
  have h33 := congrArg (fun M => M 3 3) h
  simp [Matrix.mul_apply, Fin.sum_univ_four] at h00 h33
  rw [← h00] at h33
  exact absurd h33 (by norm_num)

/-- The transversal generator `X₁ + X₂` is detectable with scalar `0`, being a sum of
detectable single-site terms — this is `Detectable.sum` in action. -/
theorem X_sum_detectable : Detectable repCode (Xfirst + Xsecond) 0 := by
  have h := (X_first_detectable).add repCode X_second_detectable
  simpa using h

/-- **Detectability does not imply code preservation.**  The transversal generator
`X₁ + X₂` is detectable, yet it maps the code vector `|00⟩` to `|01⟩ + |10⟩`, which is
orthogonal to the code: it leaks.  Hence the two hypotheses of `eastin_knill_flow_phase`
are independent and neither can be dropped. -/
theorem X_sum_not_codePreserving : ¬ CodePreserving repCode (Xfirst + Xsecond) := by
  intro h
  unfold CodePreserving repCode Xfirst Xsecond at h
  have h10 := congrArg (fun M => M 1 0) h
  simp [Matrix.mul_apply, Fin.sum_univ_four] at h10

/-! ## A genuine logical gate exists — but not from a continuous transversal symmetry -/

/-- `X ⊗ X` preserves the code space: it exchanges `|00⟩` and `|11⟩`. -/
theorem logicalXX_codePreserving : CodePreserving repCode logicalXX := by
  unfold CodePreserving repCode logicalXX
  ext i j
  fin_cases i <;> fin_cases j <;> simp [Matrix.mul_apply, Fin.sum_univ_four]

/-- `X ⊗ X` acts nontrivially on the code: it is not a phase. -/
theorem logicalXX_not_phase (z : ℂ) : logicalXX * repCode.P ≠ z • repCode.P := by
  intro h
  have h03 := congrArg (fun M => M 0 3) h
  simp [logicalXX, repCode, Matrix.mul_apply, Fin.sum_univ_four] at h03

/-- Consequently `X ⊗ X` is not detectable with any scalar: a code-preserving operator
that is detectable acts as a scalar, which `X ⊗ X` does not. -/
theorem logicalXX_not_detectable : ∀ c : ℂ, ¬ Detectable repCode logicalXX c := by
  intro c h
  exact logicalXX_not_phase c
    (codePreserving_detectable_mul_eq_smul logicalXX_codePreserving h)

/-- **Eastin–Knill on a real code.**  The logical `X̄ = X ⊗ X` of the two-qubit detection
code is a genuine logical gate, and it is even transversal as a discrete operator — yet no
code-preserving detectable generator produces it as a continuous flow.  Continuous
transversal symmetries of this code give phases and nothing else. -/
theorem logicalXX_not_generated :
    ¬ ∃ (A : Matrix (Fin 4) (Fin 4) ℂ) (c t : ℂ),
        CodePreserving repCode A ∧ Detectable repCode A c ∧
        exp (t • A) * repCode.P = logicalXX * repCode.P := by
  rintro ⟨A, c, t, hinv, hdet, hX⟩
  exact logicalXX_not_phase (Complex.exp (t * c))
    (by rw [← hX, eastin_knill_flow_phase hinv hdet t])

end EastinKnill