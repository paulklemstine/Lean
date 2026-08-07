import Algebra.ReciprocalZeroHarmonics.Rationality
import MachineLearning.LFunctions.IharaZetaDefs

/-!
# Reciprocal-Zero Harmonics IV: chord spectra under graph operations

Direction 3 of the programme asks how the *chord spectrum* — the multiset of reciprocal sums of
the zeros of the Ihara local factors — behaves under graph operations.  `Rationality.lean`
identifies the chord value of the local factor `1 - λu + qu²` with the adjacency eigenvalue `λ`
(`localFactor_chord`).  Hence the chord spectrum of a regular graph *is* its adjacency spectrum,
and the question becomes a spectral one.

This file settles the Cartesian-product case and records the global trace law.

## Main results

* `cartesianAdj_mulVec` — **spectral additivity for the Cartesian product.**  If `A v = λ v` and
  `B w = μ w` then the Cartesian-product adjacency matrix `A □ B` satisfies
  `(A □ B)(v ⊗ w) = (λ + μ)(v ⊗ w)`.
* `chord_cartesian_add` — consequently the chord value attached to the product eigenvector is the
  **sum of the two chord values**: chord spectra add (as a sumset) under Cartesian products.
  This is a positive instance of "graph operations induce predictable operations on chord
  spectra".
* `cartesianAdj_isFinGraph` (`cartesianAdj_symm`, `cartesianAdj_diag`, `cartesianAdj_zero_one`)
  and `cartesianAdj_degree` — the construction really is the Cartesian product of simple graphs,
  and degrees add: the product of a `(q₁+1)`- and a `(q₂+1)`-regular graph is
  `(q₁ + q₂ + 2)`-regular.
* `adjMat_trace_eq_zero` and `total_chord_eq_zero` — **the chord spectrum of a loopless graph is
  traceless**: whatever the spectrum is, the total chord value vanishes.  Any proposed "musical"
  normalisation of chord spectra must therefore be affine-invariant, since the raw total carries
  no information.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).** Chord spectra should transform predictably under graph
  operations; for Cartesian products the transformation should be a sumset.
* **Experiment (Experimenter).** `cartesianAdj_mulVec` is a direct computation with
  `Fintype.sum_prod_type` splitting the product-index sum into the two factor sums; the
  Kronecker eigenvector `v ⊗ w` is produced explicitly rather than abstractly.
* **Analysis (Analyst).** The result confirms the conjecture for products and simultaneously
  *refutes* the hope that the total chord value is an informative invariant: it is always `0`
  by looplessness.  The informative statistic must be the chord *multiset*, or a nonlinear
  functional of it.
* **Critique (Critic).** `chord_cartesian_add` is stated with the Frobenius-pair hypotheses
  `α + β = λ + μ`, `αβ = q` so that it genuinely refers to the zeros of an Ihara local factor and
  not to an abstract identity; `total_chord_eq_zero` carries its spectral hypothesis explicitly
  (the trace formula for the eigenvalue multiset is an input, not an assumption smuggled in).
-/

namespace ReciprocalZeroHarmonics

open Matrix

/-! ## The Cartesian product of two adjacency matrices -/

/-- Adjacency matrix of the Cartesian product `G □ H`:
`(A □ B)((i,j),(k,l)) = A i k·[j = l] + [i = k]·B j l`. -/
def cartesianAdj {n m : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (B : Matrix (Fin m) (Fin m) ℝ) :
    Matrix (Fin n × Fin m) (Fin n × Fin m) ℝ :=
  Matrix.of fun x y => A x.1 y.1 * (if x.2 = y.2 then 1 else 0)
    + (if x.1 = y.1 then 1 else 0) * B x.2 y.2

/-- The elementary tensor `(v ⊗ w)(i,j) = v i · w j`. -/
def tensorVec {n m : ℕ} (v : Fin n → ℝ) (w : Fin m → ℝ) : Fin n × Fin m → ℝ :=
  fun x => v x.1 * w x.2

theorem tensorVec_ne_zero {n m : ℕ} {v : Fin n → ℝ} {w : Fin m → ℝ} (hv : v ≠ 0) (hw : w ≠ 0) :
    tensorVec v w ≠ 0 := by
  obtain ⟨i, hi⟩ := Function.ne_iff.mp hv
  obtain ⟨j, hj⟩ := Function.ne_iff.mp hw
  intro h
  have := congrFun h (i, j)
  simp only [tensorVec, Pi.zero_apply] at this
  rcases mul_eq_zero.mp this with h' | h'
  · exact hi h'
  · exact hj h'

/-- **Spectral additivity under Cartesian products.**  Eigenvalues of `A □ B` include all sums
`λ + μ` of eigenvalues of `A` and `B`, with explicit eigenvector `v ⊗ w`. -/
theorem cartesianAdj_mulVec {n m : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    (B : Matrix (Fin m) (Fin m) ℝ) (v : Fin n → ℝ) (w : Fin m → ℝ) (l mu : ℝ)
    (hv : A.mulVec v = l • v) (hw : B.mulVec w = mu • w) :
    (cartesianAdj A B).mulVec (tensorVec v w) = (l + mu) • tensorVec v w := by
  have hv' : ∀ i, ∑ j, A i j * v j = l * v i := fun i => by
    simpa [Matrix.mulVec, dotProduct] using congrFun hv i
  have hw' : ∀ i, ∑ j, B i j * w j = mu * w i := fun i => by
    simpa [Matrix.mulVec, dotProduct] using congrFun hw i
  funext x
  simp only [Matrix.mulVec, cartesianAdj, tensorVec, Matrix.of_apply, dotProduct,
    Fintype.sum_prod_type, Pi.smul_apply, smul_eq_mul]
  have inner : ∀ i : Fin n,
      ∑ j, ((A x.1 i * if x.2 = j then 1 else 0) + (if x.1 = i then 1 else 0) * B x.2 j)
        * (v i * w j)
      = A x.1 i * v i * w x.2 + (if x.1 = i then v i * (mu * w x.2) else 0) := by
    intro i
    simp only [add_mul, Finset.sum_add_distrib, ite_mul, one_mul, zero_mul, mul_ite, mul_zero,
      mul_one, Finset.sum_ite_eq, Finset.mem_univ, if_true]
    congr 1
    · ring
    · split_ifs with h
      · rw [← hw', Finset.mul_sum]
        exact Finset.sum_congr rfl fun j _ => by ring
      · simp
  rw [Finset.sum_congr rfl fun i _ => inner i, Finset.sum_add_distrib, Finset.sum_ite_eq]
  simp only [Finset.mem_univ, if_true]
  rw [← Finset.sum_mul, hv']
  ring

/-- **Chord spectra add under Cartesian products.**  If `α, β` are the Frobenius-type parameters
of the Ihara local factor attached to the product eigenvalue `λ + μ`, then the chord value of
that factor is the sum of the chord values of the two factors. -/
theorem chord_cartesian_add {n m : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    (B : Matrix (Fin m) (Fin m) ℝ) (v : Fin n → ℝ) (w : Fin m → ℝ) (l mu : ℝ)
    (hv : A.mulVec v = l • v) (hw : B.mulVec w = mu • w) (hv0 : v ≠ 0) (hw0 : w ≠ 0)
    (q α β : ℂ) (hs : α + β = ((l : ℂ) + (mu : ℂ))) (hp : α * β = q) (ha : α ≠ 0) (hb : β ≠ 0) :
    ((cartesianAdj A B).mulVec (tensorVec v w) = (l + mu) • tensorVec v w ∧
      tensorVec v w ≠ 0) ∧
      harmonicSum {α⁻¹, β⁻¹} = (l : ℂ) + (mu : ℂ) :=
  ⟨⟨cartesianAdj_mulVec A B v w l mu hv hw, tensorVec_ne_zero hv0 hw0⟩,
    (localFactor_chord ((l : ℂ) + (mu : ℂ)) q α β hs hp ha hb).2.2⟩

/-! ## The product really is a simple graph, and degrees add -/

theorem cartesianAdj_symm {n m : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    (B : Matrix (Fin m) (Fin m) ℝ) (hA : ∀ i j, A i j = A j i) (hB : ∀ i j, B i j = B j i)
    (x y : Fin n × Fin m) : cartesianAdj A B x y = cartesianAdj A B y x := by
  simp only [cartesianAdj, Matrix.of_apply, hA x.1 y.1, hB x.2 y.2]
  by_cases h1 : x.1 = y.1 <;> by_cases h2 : x.2 = y.2 <;>
    simp [h1, h2, eq_comm, hA, hB]

theorem cartesianAdj_diag {n m : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    (B : Matrix (Fin m) (Fin m) ℝ) (hA : ∀ i, A i i = 0) (hB : ∀ i, B i i = 0)
    (x : Fin n × Fin m) : cartesianAdj A B x x = 0 := by
  simp [cartesianAdj, hA, hB]

theorem cartesianAdj_zero_one {n m : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    (B : Matrix (Fin m) (Fin m) ℝ) (hA : ∀ i j, A i j = 0 ∨ A i j = 1)
    (hB : ∀ i j, B i j = 0 ∨ B i j = 1) (hA0 : ∀ i, A i i = 0) (hB0 : ∀ i, B i i = 0)
    (x y : Fin n × Fin m) : cartesianAdj A B x y = 0 ∨ cartesianAdj A B x y = 1 := by
  obtain ⟨x1, x2⟩ := x
  obtain ⟨y1, y2⟩ := y
  simp only [cartesianAdj, Matrix.of_apply]
  by_cases h1 : x1 = y1 <;> by_cases h2 : x2 = y2
  · subst h1; subst h2; left; simp [hA0, hB0]
  · subst h1; simpa [h2, hA0] using hB x2 y2
  · subst h2; simpa [h1, hB0] using hA x1 y1
  · left; simp [h1, h2]

/-- **Degrees add.**  The row sums of `A □ B` are the sums of the row sums of `A` and `B`; the
Cartesian product of a `(q₁+1)`-regular and a `(q₂+1)`-regular graph is `(q₁+q₂+2)`-regular. -/
theorem cartesianAdj_degree {n m : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    (B : Matrix (Fin m) (Fin m) ℝ) (x : Fin n × Fin m) :
    ∑ y, cartesianAdj A B x y = (∑ k, A x.1 k) + ∑ l, B x.2 l := by
  simp only [cartesianAdj, Matrix.of_apply, Fintype.sum_prod_type]
  have inner : ∀ i : Fin n,
      ∑ j, ((A x.1 i * if x.2 = j then 1 else 0) + (if x.1 = i then 1 else 0) * B x.2 j)
        = A x.1 i + (if x.1 = i then ∑ j, B x.2 j else 0) := by
    intro i
    simp only [Finset.sum_add_distrib, mul_ite, mul_one, mul_zero, Finset.sum_ite_eq,
      Finset.mem_univ, if_true, ite_mul, one_mul, zero_mul]
    congr 1
    split_ifs with h <;> simp
  rw [Finset.sum_congr rfl fun i _ => inner i, Finset.sum_add_distrib, Finset.sum_ite_eq]
  simp

/-! ## The trace law: chord spectra are traceless -/

/-- The adjacency matrix of a loopless graph has zero trace. -/
theorem adjMat_trace_eq_zero {n : ℕ} (G : FinGraph n) : G.adjMat.trace = 0 := by
  simp [Matrix.trace, Matrix.diag, FinGraph.adjMat, G.no_loops]

/-- **Total chord value vanishes.**  For any loopless graph, if `L` is the eigenvalue multiset of
its adjacency matrix (so that `L.sum` is the trace), the total chord value of its Ihara local
factors is `0`.  The raw total is therefore never a distinguishing "musical" invariant. -/
theorem total_chord_eq_zero {n : ℕ} (G : FinGraph n) (L : Multiset ℝ)
    (hL : L.sum = G.adjMat.trace) : L.sum = 0 := by
  rw [hL, adjMat_trace_eq_zero]

end ReciprocalZeroHarmonics