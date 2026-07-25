/-
  # Commitment-Based Matrix Verification Protocol

  This file formalizes a framework for verifiable linear algebra via
  commitment-based interactive protocols. The core insight is that
  matrix multiplication K = A ⬝ B decomposes into row-local constraints,
  and a verifier who checks all challenged rows against binding commitments
  can certify the global product identity.

  ## Main results

  1. `matrix_mul_eq_iff_rowwise` — Exact iff characterization of matrix
     multiplication via row-wise summation identities.

  2. `matrix_mul_eq_iff_rowProd` — Protocol-facing form: the verifier
     challenges row i, receives `rowProd A B i`, and checks against K.

  3. `oneHotRow_mul_extracts_row` — One-hot row selectors extract rows
     via linear functional application (challenge-response as linear testing).

  4. `oneHotRow_mul_A_mul_B` — Challenge extraction composes with
     matrix multiplication to yield the row-product formula.

  5. `binding_and_all_row_checks_imply_global_correctness` — Soundness:
     if all row checks pass, the committed product is globally correct.

  6. `committed_matrix_determined_by_all_opened_rows` — Local-to-global
     reconstruction: a matrix is uniquely determined by all its opened rows
     (finite algebraic analogue of Čech cocycle determination).

  7. `binding_row_checks_force_unique_product` — Binding commitments
     force unique matrices from equal commitments.
-/

import Mathlib

open Matrix Finset BigOperators

noncomputable section

/-! ## Row-product definition -/

/-- The row-product vector: for a given row index `i`, this computes
    the `i`-th row of the matrix product `A ⬝ B`. This is the data
    revealed by the prover in a row-challenge protocol. -/
def rowProd
    {m n p : ℕ}
    (A : Matrix (Fin m) (Fin n) ℝ)
    (B : Matrix (Fin n) (Fin p) ℝ)
    (i : Fin m) : Fin p → ℝ :=
  fun k => ∑ j : Fin n, A i j * B j k

/-! ## One-hot row selector -/

/-- A one-hot row selector: the function that is 1 at index `i` and 0 elsewhere.
    This models the verifier's challenge as a linear functional. -/
def oneHotRow {m : ℕ} (i : Fin m) : Fin m → ℝ :=
  fun r => if r = i then 1 else 0

/-! ## Commitment scheme abstraction -/

/-- A binding commitment scheme for matrices. The key property is injectivity
    of the `commit` function: distinct matrices produce distinct commitments.
    This is the minimal abstraction needed for protocol soundness. -/
structure CommitmentScheme (m n : ℕ) where
  /-- The type of commitments -/
  Commitment : Type
  /-- Commit to a matrix -/
  commit : Matrix (Fin m) (Fin n) ℝ → Commitment
  /-- Binding property: equal commitments imply equal matrices -/
  binding : ∀ {M₁ M₂ : Matrix (Fin m) (Fin n) ℝ},
    commit M₁ = commit M₂ → M₁ = M₂

/-! ## Core theorems -/

/-- **Row-local characterization of matrix multiplication.**
    A matrix `K` equals the product `A ⬝ B` if and only if every entry
    of `K` equals the corresponding dot product of a row of `A` with
    a column of `B`. This is the exact formal hinge between global
    product verification and row-challenge checking. -/
theorem matrix_mul_eq_iff_rowwise
    {m n p : ℕ}
    (A : Matrix (Fin m) (Fin n) ℝ)
    (B : Matrix (Fin n) (Fin p) ℝ)
    (K : Matrix (Fin m) (Fin p) ℝ) :
    K = A * B ↔
      ∀ i : Fin m, ∀ k : Fin p,
        K i k = ∑ j : Fin n, A i j * B j k :=
  ⟨fun h i k => by rw [h, Matrix.mul_apply], fun h => by ext i k; exact h i k⟩

/-- **Protocol-facing form of row verification.**
    Equivalent to `matrix_mul_eq_iff_rowwise` but stated in terms of
    row-function equality. The verifier challenges `i`, the prover
    reveals `rowProd A B i`, and the verifier checks it matches
    row `i` of `K`. -/
theorem matrix_mul_eq_iff_rowProd
    {m n p : ℕ}
    (A : Matrix (Fin m) (Fin n) ℝ)
    (B : Matrix (Fin n) (Fin p) ℝ)
    (K : Matrix (Fin m) (Fin p) ℝ) :
    K = A * B ↔
      ∀ i : Fin m, (fun k => K i k) = rowProd A B i := by
  constructor
  · intro h i
    ext k
    simp [rowProd, ← Matrix.mul_apply, ← h]
  · intro h
    ext i k
    have := congr_fun (h i) k
    simp [rowProd] at this
    rw [this, Matrix.mul_apply]

/-- **One-hot row selector extracts rows.**
    Summing `oneHotRow i r * K r k` over all row indices `r` yields `K i k`.
    This is the finite-dimensional analogue of delta-function extraction. -/
theorem oneHotRow_mul_extracts_row
    {m p : ℕ}
    (K : Matrix (Fin m) (Fin p) ℝ)
    (i : Fin m) :
    ∀ k : Fin p, ∑ r : Fin m, oneHotRow i r * K r k = K i k :=
  fun k => by rw [Finset.sum_eq_single i] <;> simp +contextual [oneHotRow]

/-- **Challenge extraction composes with matrix multiplication.**
    One-hot probing of `A ⬝ B` yields the row-product formula.
    This expresses challenge-response verification as a linear
    functional identity, connecting to Freivalds-style verification. -/
theorem oneHotRow_mul_A_mul_B
    {m n p : ℕ}
    (A : Matrix (Fin m) (Fin n) ℝ)
    (B : Matrix (Fin n) (Fin p) ℝ)
    (i : Fin m) :
    ∀ k : Fin p,
      ∑ r : Fin m, oneHotRow i r * (A * B) r k
        = ∑ j : Fin n, A i j * B j k := by
  intro k
  rw [oneHotRow_mul_extracts_row (A * B) i k, Matrix.mul_apply]

/-- **Binding commitments force unique matrices.**
    If two matrices have the same commitment under a binding scheme,
    they must be equal. Applied to both factors of a product, this
    means the committed product is uniquely determined. -/
theorem binding_row_checks_force_unique_product
    {m n p : ℕ}
    (CSA : CommitmentScheme m n)
    (CSB : CommitmentScheme n p)
    (A A' : Matrix (Fin m) (Fin n) ℝ)
    (B B' : Matrix (Fin n) (Fin p) ℝ)
    (hA : CSA.commit A = CSA.commit A')
    (hB : CSB.commit B = CSB.commit B') :
    A = A' ∧ B = B' :=
  ⟨CSA.binding hA, CSB.binding hB⟩

/-- **Soundness theorem for full challenge coverage.**
    If all row checks pass — that is, every row of `K` matches the
    corresponding row of the product `A ⬝ B` — then `K` equals the
    global product. This is the deterministic soundness core for
    commitment-based matrix verification protocols. -/
theorem binding_and_all_row_checks_imply_global_correctness
    {m n p : ℕ}
    (A : Matrix (Fin m) (Fin n) ℝ)
    (B : Matrix (Fin n) (Fin p) ℝ)
    (K : Matrix (Fin m) (Fin p) ℝ)
    (hchecks : ∀ i : Fin m, ∀ k : Fin p,
      K i k = ∑ j : Fin n, A i j * B j k) :
    K = A * B :=
  (matrix_mul_eq_iff_rowwise A B K).mpr hchecks

/-- **Matrix determined by rows (local-to-global reconstruction).**
    A matrix is uniquely determined by its pointwise entries.
    This is the finite-dimensional algebraic analogue of the principle
    that a sheaf section is determined by its restrictions to a cover,
    mirroring Čech cocycle determination. -/
theorem matrix_determined_by_rows
    {m p : ℕ}
    {K L : Matrix (Fin m) (Fin p) ℝ}
    (h : ∀ i : Fin m, ∀ k : Fin p, K i k = L i k) :
    K = L :=
  Matrix.ext h

/-- **Committed matrix determined by all opened rows.**
    Protocol-native form of local-to-global reconstruction:
    if every opened row of `K` matches the corresponding row of `L`
    (as functions), then `K = L`. This is the matrix counterpart of
    local cocycle determination. -/
theorem committed_matrix_determined_by_all_opened_rows
    {m p : ℕ}
    {K L : Matrix (Fin m) (Fin p) ℝ}
    (h : ∀ i : Fin m, (fun k => K i k) = (fun k => L i k)) :
    K = L :=
  matrix_determined_by_rows fun i => congrFun (h i)

/-! ## Bridge lemma: one-hot extraction connects to row-product protocol

    This establishes that the one-hot linear functional view of challenge-response
    is equivalent to the direct row-product computation, connecting the
    linear-testing perspective to the algebraic row-decomposition. -/

/-- The one-hot extraction of row `i` from `A ⬝ B` equals the row-product
    at index `i`. This bridges the linear functional (challenge) view
    with the algebraic (row-product) view of the verification protocol. -/
theorem oneHot_extraction_eq_rowProd
    {m n p : ℕ}
    (A : Matrix (Fin m) (Fin n) ℝ)
    (B : Matrix (Fin n) (Fin p) ℝ)
    (i : Fin m) :
    (fun k => ∑ r : Fin m, oneHotRow i r * (A * B) r k)
      = rowProd A B i := by
  ext k
  exact oneHotRow_mul_A_mul_B A B i k

/-! ## Full protocol soundness: combining all pieces

    The final theorem combines binding commitments with row-local
    verification to establish global correctness. -/

/-- **Full protocol soundness.**
    Given binding commitment schemes for A and B, if a prover commits
    to A and B, and for every challenged row i the verifier confirms
    that K's row i matches the row-product, then K = A ⬝ B.
    Moreover, the committed matrices are uniquely determined. -/
theorem full_protocol_soundness
    {m n p : ℕ}
    (CSA : CommitmentScheme m n)
    (CSB : CommitmentScheme n p)
    (A : Matrix (Fin m) (Fin n) ℝ)
    (B : Matrix (Fin n) (Fin p) ℝ)
    (K : Matrix (Fin m) (Fin p) ℝ)
    (A' : Matrix (Fin m) (Fin n) ℝ)
    (B' : Matrix (Fin n) (Fin p) ℝ)
    (hcommitA : CSA.commit A = CSA.commit A')
    (hcommitB : CSB.commit B = CSB.commit B')
    (hchecks : ∀ i : Fin m, (fun k => K i k) = rowProd A B i) :
    K = A * B ∧ A = A' ∧ B = B' :=
  ⟨(matrix_mul_eq_iff_rowProd A B K).mpr hchecks,
   CSA.binding hcommitA,
   CSB.binding hcommitB⟩

end