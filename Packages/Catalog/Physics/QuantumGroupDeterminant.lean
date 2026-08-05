import Mathlib

/-!
# The quantum determinant of `M_q(2)` is central

This file formalises the fundamental fact of the theory of quantum groups: for a `2 × 2`
*quantum matrix* `!![a, b; c, d]` — i.e. generators satisfying the defining relations of the
bialgebra `M_q(2)` — the **quantum determinant**

`det_q = a * d - q⁻¹ • (b * c)`

is a central element: it commutes with each of `a`, `b`, `c`, `d`.  This is the algebraic
input that makes `SL_q(2)` and `GL_q(2)` into (Hopf) quantum groups, and it is the `2 × 2`
case of the `q`-Cayley determinant of a `q`-right-quantum matrix which is the subject of
"Quantum determinants in polynomial time" (Chan--Pak).

The statement is deliberately given in *hypothesis form*: we work in an arbitrary ring `R`
which is an algebra over a commutative ring `K`, `q : Kˣ` is an invertible scalar, and
`a b c d : R` are arbitrary elements subject to the `M_q(2)` relations.  Thus the theorem
applies to every concrete realisation of the quantum plane relations (matrix realisations,
the universal algebra `M_q(2)` itself, `q`-Weyl algebras, ...).

## Main results

* `QuantumGroup.IsQuantumMatrixTwo` : the defining relations of `M_q(2)`.
* `QuantumGroup.qdet` : the quantum determinant `a * d - q⁻¹ • (b * c)`.
* `QuantumGroup.qdet_comm_a`, `qdet_comm_b`, `qdet_comm_c`, `qdet_comm_d` : centrality of the
  quantum determinant with respect to each generator.
* `QuantumGroup.qdet_central` : the combined statement.
* `QuantumGroup.qdet_eq_qCayley` : the quantum determinant is the `q`-Cayley determinant
  `∑_σ (-q⁻¹)^{inv σ} a_{σ(1)1} a_{σ(2)2}` of the matrix `!![a, b; c, d]`.
* `QuantumGroup.entries_commute_of_q_eq_one` : at `q = 1` the relations degenerate to plain
  commutativity of the four entries, so `qdet` becomes the classical determinant.
-/

namespace QuantumGroup

variable {K : Type*} [CommRing K] {R : Type*} [Ring R] [Algebra K R]

/-- The defining relations of the algebra of `2 × 2` quantum matrices `M_q(2)`, for the
matrix `!![a, b; c, d]`. -/
structure IsQuantumMatrixTwo (q : Kˣ) (a b c d : R) : Prop where
  /-- Rows `q`-commute: `b a = q a b`. -/
  ba : b * a = (q : K) • (a * b)
  /-- Columns `q`-commute: `c a = q a c`. -/
  ca : c * a = (q : K) • (a * c)
  /-- Columns `q`-commute: `d b = q b d`. -/
  db : d * b = (q : K) • (b * d)
  /-- Rows `q`-commute: `d c = q c d`. -/
  dc : d * c = (q : K) • (c * d)
  /-- The antidiagonal entries commute. -/
  cb : c * b = b * c
  /-- The diagonal entries `q`-commute up to the antidiagonal: `ad - da = (q⁻¹ - q) bc`. -/
  da : a * d - d * a = ((q⁻¹ : Kˣ) : K) • (b * c) - (q : K) • (b * c)

/-- The **quantum determinant** of `!![a, b; c, d]`. -/
def qdet (q : Kˣ) (a b c d : R) : R := a * d - ((q⁻¹ : Kˣ) : K) • (b * c)

variable {q : Kˣ} {a b c d : R}

private lemma inv_mul_sq (q : Kˣ) : ((q⁻¹ : Kˣ) : K) * ((q : K) * (q : K)) = (q : K) := by
  rw [← mul_assoc, Units.inv_mul, one_mul]

private lemma da_eq (h : IsQuantumMatrixTwo q a b c d) :
    d * a = a * d - (((q⁻¹ : Kˣ) : K) • (b * c) - (q : K) • (b * c)) := by
  rw [← h.da]; noncomm_ring

/-- The quantum determinant commutes with `a`. -/
theorem qdet_comm_a (h : IsQuantumMatrixTwo q a b c d) :
    qdet q a b c d * a = a * qdet q a b c d := by
  have h1 : (a * d) * a
      = a * (a * d) - a * (((q⁻¹ : Kˣ) : K) • (b * c) - (q : K) • (b * c)) := by
    rw [mul_assoc, da_eq h]; noncomm_ring
  have h2 : (b * c) * a = ((q : K) * (q : K)) • (a * (b * c)) := by
    calc (b * c) * a = b * (c * a) := by noncomm_ring
      _ = b * ((q : K) • (a * c)) := by rw [h.ca]
      _ = (q : K) • ((b * a) * c) := by rw [mul_smul_comm]; noncomm_ring
      _ = (q : K) • (((q : K) • (a * b)) * c) := by rw [h.ba]
      _ = ((q : K) * (q : K)) • (a * (b * c)) := by
            rw [smul_mul_assoc, smul_smul]; noncomm_ring
  rw [qdet, sub_mul, h1, smul_mul_assoc, h2, smul_smul, inv_mul_sq]
  simp only [mul_sub, mul_smul_comm]
  abel

/-- The quantum determinant commutes with `b`. -/
theorem qdet_comm_b (h : IsQuantumMatrixTwo q a b c d) :
    qdet q a b c d * b = b * qdet q a b c d := by
  have h1 : (a * d) * b = (q : K) • (a * (b * d)) := by
    calc (a * d) * b = a * (d * b) := by noncomm_ring
      _ = a * ((q : K) • (b * d)) := by rw [h.db]
      _ = (q : K) • (a * (b * d)) := by rw [mul_smul_comm]
  have h2 : (b * c) * b = b * (b * c) := by
    calc (b * c) * b = b * (c * b) := by noncomm_ring
      _ = b * (b * c) := by rw [h.cb]
  have h3 : b * (a * d) = (q : K) • (a * (b * d)) := by
    calc b * (a * d) = (b * a) * d := by noncomm_ring
      _ = ((q : K) • (a * b)) * d := by rw [h.ba]
      _ = (q : K) • (a * (b * d)) := by rw [smul_mul_assoc]; noncomm_ring
  rw [qdet, sub_mul, mul_sub, h1, h3, smul_mul_assoc, h2, mul_smul_comm]

/-- The quantum determinant commutes with `c`. -/
theorem qdet_comm_c (h : IsQuantumMatrixTwo q a b c d) :
    qdet q a b c d * c = c * qdet q a b c d := by
  have h1 : (a * d) * c = (q : K) • (a * (c * d)) := by
    calc (a * d) * c = a * (d * c) := by noncomm_ring
      _ = a * ((q : K) • (c * d)) := by rw [h.dc]
      _ = (q : K) • (a * (c * d)) := by rw [mul_smul_comm]
  have h2 : c * (a * d) = (q : K) • (a * (c * d)) := by
    calc c * (a * d) = (c * a) * d := by noncomm_ring
      _ = ((q : K) • (a * c)) * d := by rw [h.ca]
      _ = (q : K) • (a * (c * d)) := by rw [smul_mul_assoc]; noncomm_ring
  have h3 : c * (b * c) = (b * c) * c := by
    calc c * (b * c) = (c * b) * c := by noncomm_ring
      _ = (b * c) * c := by rw [h.cb]
  rw [qdet, sub_mul, mul_sub, h1, h2, smul_mul_assoc, mul_smul_comm, h3]

/-- The quantum determinant commutes with `d`. -/
theorem qdet_comm_d (h : IsQuantumMatrixTwo q a b c d) :
    qdet q a b c d * d = d * qdet q a b c d := by
  have h1 : d * (a * d)
      = (a * d) * d - (((q⁻¹ : Kˣ) : K) • ((b * c) * d) - (q : K) • ((b * c) * d)) := by
    calc d * (a * d) = (d * a) * d := by noncomm_ring
      _ = (a * d - (((q⁻¹ : Kˣ) : K) • (b * c) - (q : K) • (b * c))) * d := by rw [da_eq h]
      _ = (a * d) * d - (((q⁻¹ : Kˣ) : K) • ((b * c) * d) - (q : K) • ((b * c) * d)) := by
            rw [sub_mul, sub_mul, smul_mul_assoc, smul_mul_assoc]
  have h2 : d * (b * c) = ((q : K) * (q : K)) • ((b * c) * d) := by
    calc d * (b * c) = (d * b) * c := by noncomm_ring
      _ = ((q : K) • (b * d)) * c := by rw [h.db]
      _ = (q : K) • (b * (d * c)) := by rw [smul_mul_assoc]; noncomm_ring
      _ = (q : K) • (b * ((q : K) • (c * d))) := by rw [h.dc]
      _ = ((q : K) * (q : K)) • ((b * c) * d) := by
            rw [mul_smul_comm, smul_smul]; noncomm_ring
  rw [qdet, sub_mul, mul_sub, smul_mul_assoc, mul_smul_comm, h1, h2, smul_smul, inv_mul_sq]
  abel

/-- **The quantum determinant of a `2 × 2` quantum matrix is central**: it commutes with all
four generators. -/
theorem qdet_central (h : IsQuantumMatrixTwo q a b c d) :
    qdet q a b c d * a = a * qdet q a b c d ∧
    qdet q a b c d * b = b * qdet q a b c d ∧
    qdet q a b c d * c = c * qdet q a b c d ∧
    qdet q a b c d * d = d * qdet q a b c d :=
  ⟨qdet_comm_a h, qdet_comm_b h, qdet_comm_c h, qdet_comm_d h⟩

/-- The quantum determinant is central for the whole subalgebra generated by the entries:
it commutes with every element of the subring generated by `a, b, c, d` (stated as: it
commutes with every element of the closure). -/
theorem qdet_mem_centralizer (h : IsQuantumMatrixTwo q a b c d) :
    ∀ x ∈ Subring.closure ({a, b, c, d} : Set R), qdet q a b c d * x = x * qdet q a b c d := by
  intro x hx
  induction hx using Subring.closure_induction with
  | mem y hy =>
      rcases hy with rfl | rfl | rfl | rfl
      · exact qdet_comm_a h
      · exact qdet_comm_b h
      · exact qdet_comm_c h
      · exact qdet_comm_d h
  | zero => simp
  | one => simp
  | add x y _ _ ihx ihy => rw [mul_add, add_mul, ihx, ihy]
  | neg x _ ihx => rw [mul_neg, neg_mul, ihx]
  | mul x y _ _ ihx ihy => rw [← mul_assoc, ihx, mul_assoc, ihy, mul_assoc]

/-! ### The quantum determinant as a `q`-Cayley determinant -/

/-- The `q`-Cayley determinant of a `2 × 2` matrix: the column-ordered expansion
`∑_σ (-q⁻¹)^{inv σ} A_{σ(1)1} A_{σ(2)2}`. -/
def qCayleyTwo (q : Kˣ) (A : Matrix (Fin 2) (Fin 2) R) : R :=
  A 0 0 * A 1 1 - ((q⁻¹ : Kˣ) : K) • (A 1 0 * A 0 1)

/-- For a quantum matrix, the quantum determinant coincides with the `q`-Cayley determinant,
i.e. with the column-ordered expansion weighted by `(-q⁻¹)^{inv σ}`. -/
theorem qdet_eq_qCayley (h : IsQuantumMatrixTwo q a b c d) :
    qdet q a b c d = qCayleyTwo q !![a, b; c, d] := by
  simp [qdet, qCayleyTwo, h.cb]

/-- At `q = 1` the relations say that all four entries commute, and the quantum determinant is
the classical determinant. -/
theorem entries_commute_of_q_eq_one (h : IsQuantumMatrixTwo (1 : Kˣ) a b c d) :
    b * a = a * b ∧ c * a = a * c ∧ d * b = b * d ∧ d * c = c * d ∧ c * b = b * c ∧
      d * a = a * d := by
  refine ⟨by simpa using h.ba, by simpa using h.ca, by simpa using h.db, by simpa using h.dc,
    h.cb, ?_⟩
  have := h.da
  simp only [inv_one, Units.val_one, one_smul, sub_self] at this
  exact (sub_eq_zero.mp this).symm

end QuantumGroup