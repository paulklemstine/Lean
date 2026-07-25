import Mathlib

open BigOperators

namespace SpectralTransferSharpness

variable {ι : Type*} [Fintype ι]

/-- The weighted degree of a vertex. -/
def degree (A : Matrix ι ι ℝ) (i : ι) : ℝ := ∑ j, A i j

/-- The total edge weight, with ordered endpoints. -/
def edgeCount (A : Matrix ι ι ℝ) : ℝ := ∑ i, degree A i

/-- The weighted number of two-step walks beginning at a vertex. -/
def twoStep (A : Matrix ι ι ℝ) (i : ι) : ℝ :=
  ∑ j, A i j * degree A j

/-- The weighted homomorphism count of the five-vertex path.  For a symmetric
matrix this is the usual sum over all maps from the vertices of `P₅`. -/
def pathFiveCount (A : Matrix ι ι ℝ) : ℝ := ∑ i, (twoStep A i) ^ 2

/-- A finite weighted graph is doubly nonnegative when its kernel is symmetric,
entrywise nonnegative, and its quadratic form is nonnegative. -/
def DoublyNonnegative (A : Matrix ι ι ℝ) : Prop :=
  (∀ i j, A i j = A j i) ∧
  (∀ i j, 0 ≤ A i j) ∧
  (∀ x : ι → ℝ, 0 ≤ ∑ i, ∑ j, x i * A i j * x j)

/-- Symmetry identifies the total two-step weight with the sum of squared degrees. -/
theorem sum_twoStep_eq_sum_degree_sq (A : Matrix ι ι ℝ)
    (hsym : ∀ i j, A i j = A j i) :
    ∑ i, twoStep A i = ∑ i, (degree A i) ^ 2 := by
  simp +decide only [twoStep, degree, sq, Finset.sum_mul];
  exact Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by rw [ hsym ] )

/-- The sharp unnormalised Sidorenko inequality for the five-vertex path.
It holds for every symmetric real matrix; entrywise or spectral positivity is
not required. Equality is attained by constant matrices. -/
theorem pathFive_sidorenko (A : Matrix ι ι ℝ)
    (hsym : ∀ i j, A i j = A j i) :
    (edgeCount A) ^ 4 ≤ (Fintype.card ι : ℝ) ^ 3 * pathFiveCount A := by
  by_cases h_card : Fintype.card ι = 0;
  · simp_all +decide [ edgeCount, pathFiveCount ];
    rw [ Fintype.card_eq_zero_iff ] at h_card ; aesop;
  · -- By Cauchy-Schwarz on degrees, $S^2 \leq nT$.
    have h_cauchy_schwarz_degrees : (edgeCount A) ^ 2 ≤ (Fintype.card ι : ℝ) * ∑ i, (degree A i) ^ 2 := by
      have := Finset.univ.sum_le_sum fun i _ => pow_two_nonneg ( degree A i - ( ∑ j, degree A j ) / Fintype.card ι );
      simp_all +decide [sub_sq, Finset.sum_add_distrib, Finset.mul_sum _ _ _];
      simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, edgeCount ];
      nlinarith [ mul_div_cancel₀ ( ∑ i, degree A i ) ( Nat.cast_ne_zero.mpr h_card ) ];
    -- By Cauchy-Schwarz on twoStep, $T^2 \leq nP$.
    have h_cauchy_schwarz_twoStep : (∑ i, (twoStep A i)) ^ 2 ≤ (Fintype.card ι : ℝ) * ∑ i, (twoStep A i) ^ 2 := by
      have := Finset.univ.sum_le_sum fun i _ => pow_two_nonneg ( twoStep A i - ( ∑ j, twoStep A j ) / Fintype.card ι );
      simp_all +decide [sub_sq, Finset.sum_add_distrib, Finset.mul_sum _ _ _];
      simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul ];
      nlinarith [ mul_div_cancel₀ ( ∑ i, twoStep A i ) ( Nat.cast_ne_zero.mpr h_card ) ];
    rw [ sum_twoStep_eq_sum_degree_sq A hsym ] at h_cauchy_schwarz_twoStep;
    nlinarith! [ show 0 ≤ ( Fintype.card ι : ℝ ) ^ 2 by positivity ]

/-- The normalized five-vertex-path density dominates the fourth power of the
edge density on every nonempty finite symmetric weighted graph. -/
theorem pathFive_density_sidorenko (A : Matrix ι ι ℝ)
    (hsym : ∀ i j, A i j = A j i) (hne : Nonempty ι) :
    pathFiveCount A / (Fintype.card ι : ℝ) ^ 5 ≥
      (edgeCount A / (Fintype.card ι : ℝ) ^ 2) ^ 4 := by
  have := pathFive_sidorenko A hsym;
  rw [ div_pow, ge_iff_le, div_le_div_iff₀ ] <;> first | positivity | nlinarith [ show ( Fintype.card ι : ℝ ) ^ 5 > 0 by positivity ] ;

/-
Constant kernels attain equality in the unnormalised `P₅` inequality, proving
that the coefficient `(card ι)³` is sharp.
-/
theorem pathFive_constant_equality (c : ℝ) :
    (edgeCount (fun _ _ : ι => c)) ^ 4 =
      (Fintype.card ι : ℝ) ^ 3 * pathFiveCount (fun _ _ : ι => c) := by
  unfold edgeCount; unfold pathFiveCount; unfold twoStep; unfold degree; norm_num; ring;

/-- In particular, every finite doubly nonnegative weighted graph satisfies the
`P₅` Sidorenko inequality. Thus no finite doubly nonnegative counterexample of
the proposed kind exists under the standard homomorphism-density definitions. -/
theorem doublyNonnegative_pathFive_sidorenko (A : Matrix ι ι ℝ)
    (hA : DoublyNonnegative A) :
    (edgeCount A) ^ 4 ≤ (Fintype.card ι : ℝ) ^ 3 * pathFiveCount A := by
  exact pathFive_sidorenko A hA.1

/-- Any class consisting of symmetric kernels is `P₅`-Sidorenko in the finite
weighted model. This rules out separating a universal spectral condition from
`P₅`-Sidorenko by choosing such a class. -/
theorem class_pathFive_sidorenko
    (C : Matrix ι ι ℝ → Prop)
    (hC : ∀ A, C A → ∀ i j, A i j = A j i) :
    ∀ A, C A →
      (edgeCount A) ^ 4 ≤ (Fintype.card ι : ℝ) ^ 3 * pathFiveCount A := by
  exact fun A hA => pathFive_sidorenko A ( hC A hA )

end SpectralTransferSharpness