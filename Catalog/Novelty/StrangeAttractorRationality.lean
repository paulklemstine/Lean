import Novelty.StrangeAttractorLorenzTemplate

/-!
# Strange attractors as algebraic objects, VI: rationality of the orbit-counting sequence

The previous files identified the orbit space of a finite directed graph with an inverse
limit of finite path sets and showed that the number of `n`-periodic orbits equals
`trace (A ^ n)` for the transfer matrix `A`.  Here we extract the algebraic consequence:

* `trace_charpoly_recurrence` : for *any* square matrix over a commutative ring the
  sequence `n ↦ trace (M ^ n)` satisfies the linear recurrence given by the coefficients
  of the characteristic polynomial (a Cayley–Hamilton / Newton-identity statement);
* `card_closedWalk_charpoly_recurrence` : consequently the periodic-orbit counting
  sequence of a symbolic attractor obeys an integer linear recurrence of order at most
  the number of vertices — the finite-graph shadow of rationality of the
  Artin–Mazur zeta function;
* `trace_pow_recurrence_two` and `card_closedWalk_two_vertex_recurrence` : the explicit
  order-two recurrence for two-vertex templates, proved by an elementary
  Cayley–Hamilton computation that avoids the `charpoly` machinery;
* `card_closedWalk_lorenz_recurrence` and `card_closedWalk_pruned_recurrence` :
  the doubling recurrence for the Lorenz template and the Lucas (Fibonacci) recurrence
  for the pruned template, both obtained from the same algebraic source.

The moral is that the "strangeness" of the attractor is entirely encoded in a
characteristic polynomial: two templates whose orbit counts disagree are separated by
a *finite* amount of algebraic data.
-/

namespace LorenzLimit

variable {V : Type*} [Fintype V] [DecidableEq V] {E : V → V → Bool}

/-! ## The integral transfer matrix -/

/-- The transfer matrix of a finite directed graph, over the integers. -/
def adjMatrixZ (E : V → V → Bool) : Matrix V V ℤ :=
  Matrix.of fun i j => if E i j = true then 1 else 0

omit [Fintype V] [DecidableEq V] in
theorem adjMatrixZ_eq_map : adjMatrixZ E = (adjMatrix E).map (Nat.cast) := by
  ext i j
  by_cases h : E i j = true <;> simp [adjMatrixZ, adjMatrix, h]

theorem adjMatrixZ_pow_map (n : ℕ) :
    adjMatrixZ E ^ n = ((adjMatrix E) ^ n).map (Nat.cast) := by
  have hmap : ∀ M : Matrix V V ℕ,
      M.map (Nat.cast : ℕ → ℤ) = (Nat.castRingHom ℤ).mapMatrix M := fun _ => rfl
  rw [adjMatrixZ_eq_map, hmap, hmap, ← map_pow]

/-- The trace of the `n`-th power of the integral transfer matrix counts the closed walks
of length `n`, i.e. the `n`-periodic orbits of the attractor. -/
theorem trace_adjMatrixZ_pow (n : ℕ) :
    Matrix.trace (adjMatrixZ E ^ n) = (Fintype.card (ClosedWalk E n) : ℤ) := by
  rw [adjMatrixZ_pow_map, card_closedWalk_eq_trace, Matrix.trace, Matrix.trace]
  push_cast
  exact Finset.sum_congr rfl fun i _ => rfl

/-! ## Cayley–Hamilton for trace sequences -/

/-- **Rationality kernel.** For any square matrix over a commutative ring, the sequence
`n ↦ trace (M ^ n)` satisfies the linear recurrence whose coefficients are those of the
characteristic polynomial of `M`. -/
theorem trace_charpoly_recurrence {R : Type*} [CommRing R] (M : Matrix V V R) (k : ℕ) :
    ∑ i ∈ Finset.range (M.charpoly.natDegree + 1),
      M.charpoly.coeff i * Matrix.trace (M ^ (i + k)) = 0 := by
  have h := Matrix.aeval_self_charpoly M
  rw [Polynomial.aeval_eq_sum_range] at h
  have h2 : (∑ i ∈ Finset.range (M.charpoly.natDegree + 1), M.charpoly.coeff i • M ^ i) * M ^ k
      = 0 := by rw [h, zero_mul]
  rw [Finset.sum_mul] at h2
  have h3 := congrArg Matrix.trace h2
  rw [Matrix.trace_sum, Matrix.trace_zero] at h3
  rw [← h3]
  refine Finset.sum_congr rfl ?_
  intro i _
  rw [smul_mul_assoc, ← pow_add, Matrix.trace_smul, smul_eq_mul]

/-- The periodic-orbit counting sequence of a symbolic attractor satisfies an integer
linear recurrence whose coefficients are those of the characteristic polynomial of the
transfer matrix. -/
theorem card_closedWalk_charpoly_recurrence (k : ℕ) :
    ∑ i ∈ Finset.range ((adjMatrixZ E).charpoly.natDegree + 1),
      (adjMatrixZ E).charpoly.coeff i * (Fintype.card (ClosedWalk E (i + k)) : ℤ) = 0 := by
  have h := trace_charpoly_recurrence (adjMatrixZ E) k
  rw [← h]
  exact Finset.sum_congr rfl fun i _ => by rw [trace_adjMatrixZ_pow]

/-! ## Two-vertex templates: an explicit order-two recurrence -/

section TwoVertex

variable {R : Type*} [CommRing R]

/-- The determinant of a `Bool`-indexed `2 × 2` matrix, written out. -/
def detBool (M : Matrix Bool Bool R) : R :=
  M true true * M false false - M true false * M false true

/-- Cayley–Hamilton in the two-vertex case, proved by direct computation. -/
theorem sq_eq_two_vertex (M : Matrix Bool Bool R) :
    M ^ 2 = Matrix.trace M • M - detBool M • (1 : Matrix Bool Bool R) := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [pow_two, Matrix.mul_apply, Matrix.trace, Matrix.diag,
      detBool, sub_eq_add_neg] <;> ring

/-- The trace sequence of a two-vertex transfer matrix satisfies the order-two recurrence
determined by its trace and determinant. -/
theorem trace_pow_recurrence_two (M : Matrix Bool Bool R) (k : ℕ) :
    Matrix.trace (M ^ (k + 2))
      = Matrix.trace M * Matrix.trace (M ^ (k + 1)) - detBool M * Matrix.trace (M ^ k) := by
  have hM : M ^ (k + 2) = Matrix.trace M • M ^ (k + 1) - detBool M • M ^ k := by
    have : M ^ (k + 2) = M ^ 2 * M ^ k := by rw [← pow_add]; ring_nf
    rw [this, sq_eq_two_vertex, sub_mul, smul_mul_assoc, smul_mul_assoc, one_mul,
      ← pow_succ']
  rw [hM, Matrix.trace_sub, Matrix.trace_smul, Matrix.trace_smul, smul_eq_mul, smul_eq_mul]

end TwoVertex

/-- The periodic-orbit counts of any two-vertex template satisfy the order-two integer
recurrence given by the trace and determinant of its transfer matrix. -/
theorem card_closedWalk_two_vertex_recurrence (E : Bool → Bool → Bool) (k : ℕ) :
    (Fintype.card (ClosedWalk E (k + 2)) : ℤ)
      = Matrix.trace (adjMatrixZ E) * (Fintype.card (ClosedWalk E (k + 1)) : ℤ)
        - detBool (adjMatrixZ E) * (Fintype.card (ClosedWalk E k) : ℤ) := by
  have h := trace_pow_recurrence_two (adjMatrixZ E) k
  rwa [trace_adjMatrixZ_pow, trace_adjMatrixZ_pow, trace_adjMatrixZ_pow] at h

/-! ## The two templates -/

theorem trace_adjMatrixZ_lorenz : Matrix.trace (adjMatrixZ lorenzTemplate) = 2 := by
  simp [Matrix.trace, Matrix.diag, adjMatrixZ, lorenzTemplate]

theorem detBool_adjMatrixZ_lorenz : detBool (adjMatrixZ lorenzTemplate) = 0 := by
  simp [detBool, adjMatrixZ, lorenzTemplate]

theorem trace_adjMatrixZ_pruned : Matrix.trace (adjMatrixZ prunedTemplate) = 1 := by
  simp [Matrix.trace, Matrix.diag, adjMatrixZ, prunedTemplate]

theorem detBool_adjMatrixZ_pruned : detBool (adjMatrixZ prunedTemplate) = -1 := by
  simp [detBool, adjMatrixZ, prunedTemplate]

/-- The Lorenz template's periodic-orbit counts simply double. -/
theorem card_closedWalk_lorenz_recurrence (k : ℕ) :
    Fintype.card (ClosedWalk lorenzTemplate (k + 2))
      = 2 * Fintype.card (ClosedWalk lorenzTemplate (k + 1)) := by
  have h := card_closedWalk_two_vertex_recurrence lorenzTemplate k
  rw [trace_adjMatrixZ_lorenz, detBool_adjMatrixZ_lorenz] at h
  exact_mod_cast by linarith [h]

/-- The pruned template's periodic-orbit counts obey the Lucas (Fibonacci) recurrence. -/
theorem card_closedWalk_pruned_recurrence (k : ℕ) :
    Fintype.card (ClosedWalk prunedTemplate (k + 2))
      = Fintype.card (ClosedWalk prunedTemplate (k + 1))
        + Fintype.card (ClosedWalk prunedTemplate k) := by
  have h := card_closedWalk_two_vertex_recurrence prunedTemplate k
  rw [trace_adjMatrixZ_pruned, detBool_adjMatrixZ_pruned] at h
  exact_mod_cast by linarith [h]

end LorenzLimit