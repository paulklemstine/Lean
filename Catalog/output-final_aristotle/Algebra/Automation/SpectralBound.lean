import Mathlib

/-! # `spectral_bound`: sound eigenvalue estimates via row sums

This file develops `spectral_bound`, a tactic that produces an *a priori*
bound on the absolute value of a real eigenvalue of a matrix from the
absolute row sums of that matrix — the elementary half of the Gershgorin
circle theorem.

The soundness backbone is `eigenvalue_abs_le_of_rowSum_le`: if `λ` is an
eigenvalue of `A` (i.e. `A.mulVec v = λ • v` for some `v ≠ 0`) and every
absolute row sum of `A` is at most `B`, then `|λ| ≤ B`. The tactic simply
applies this theorem, so any bound it derives is provably correct.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Every real eigenvalue is bounded in absolute value
by the maximum absolute row sum (the ∞-operator-norm bound). Equivalently,
there is a row index whose absolute row sum dominates `|λ|`.
Experiment (Experimenter): Pick a coordinate `i₀` maximising `|v i₀|`; from the
`i₀`-th eigen-equation, `|λ| |v i₀| = |∑ⱼ Aᵢ₀ⱼ vⱼ| ≤ (∑ⱼ |Aᵢ₀ⱼ|) |v i₀|`.
Dividing by `|v i₀| > 0` gives the bound. Package as an existential plus a
uniform-bound corollary, then wrap in the tactic.
Analysis (Analyst): The argmax exists because `v ≠ 0` makes `Finset.univ`
nonempty and some `|v i| > 0`; `Finset.exists_max_image` supplies it. The
triangle inequality `abs_sum_le_sum_abs` and monotonicity of the sum finish it.
Critique (Critic): The result is vacuous only if no eigenvector exists; the
`v ≠ 0` hypothesis rules this out, and division by `|v i₀|` is justified since
it is strictly positive. No step is a bare `decide`.
Synthesis (PI): `spectral_bound` = `apply eigenvalue_abs_le_of_rowSum_le` with
`assumption` discharging the eigen-equation.
-/

namespace SpectralBound

open Matrix Finset

/-
**Row-sum eigenvalue estimate (existential form).** If `λ` is an eigenvalue
of `A` with eigenvector `v ≠ 0`, then some absolute row sum of `A` bounds
`|λ|`.
-/
theorem exists_rowSum_ge_abs_eigenvalue
    {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (lam : ℝ) (v : Fin n → ℝ)
    (hv : v ≠ 0) (hAv : A.mulVec v = lam • v) :
    ∃ i : Fin n, |lam| ≤ ∑ j, |A i j| := by
  obtain ⟨i₀, hi₀⟩ : ∃ i₀, ∀ i, |v i| ≤ |v i₀| := by
    simpa using Finset.exists_max_image Finset.univ ( fun i => |v i| ) ⟨ Classical.choose ( Function.ne_iff.mp hv ), Finset.mem_univ _ ⟩;
  have h_abs : |lam| * |v i₀| ≤ ∑ j, |A i₀ j| * |v j| := by
    have h_abs : |lam * v i₀| ≤ ∑ j, |A i₀ j * v j| := by
      convert Finset.abs_sum_le_sum_abs _ _ using 2 ; simp_all +decide;
      · simpa [ Matrix.mulVec, dotProduct ] using congr_fun hAv.symm i₀;
      · infer_instance;
    simpa only [ abs_mul ] using h_abs;
  exact ⟨ i₀, by nlinarith [ show 0 < |v i₀| from abs_pos.mpr ( show v i₀ ≠ 0 from fun h => hv <| funext fun i => by simpa [ h ] using hi₀ i ), show ∑ j, |A i₀ j| * |v j| ≤ ∑ j, |A i₀ j| * |v i₀| by exact Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left ( hi₀ i ) ( abs_nonneg _ ), show ∑ j, |A i₀ j| * |v i₀| = ( ∑ j, |A i₀ j| ) * |v i₀| by rw [ Finset.sum_mul _ _ _ ] ] ⟩

/-- **Row-sum eigenvalue estimate (uniform bound).** If every absolute row sum
of `A` is at most `B`, then every real eigenvalue `λ` of `A` satisfies
`|λ| ≤ B`. This is the soundness statement backing `spectral_bound`. -/
theorem eigenvalue_abs_le_of_rowSum_le
    {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (lam : ℝ) (v : Fin n → ℝ)
    (hv : v ≠ 0) (hAv : A.mulVec v = lam • v)
    (B : ℝ) (hB : ∀ i, ∑ j, |A i j| ≤ B) :
    |lam| ≤ B := by
  obtain ⟨i, hi⟩ := exists_rowSum_ge_abs_eigenvalue A lam v hv hAv
  exact le_trans hi (hB i)

/-- The custom tactic: reduce an eigenvalue-magnitude goal to a row-sum bound. -/
macro "spectral_bound" : tactic =>
  `(tactic| apply SpectralBound.eigenvalue_abs_le_of_rowSum_le <;> assumption)

/-! ## Soundness demonstration -/

/-- A closed-form use: any eigenvalue of a matrix all of whose absolute row
sums are `≤ 5` has magnitude `≤ 5`. -/
example {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (lam : ℝ) (v : Fin n → ℝ)
    (hv : v ≠ 0) (hAv : A.mulVec v = lam • v)
    (hB : ∀ i, ∑ j, |A i j| ≤ 5) : |lam| ≤ 5 := by
  spectral_bound

end SpectralBound