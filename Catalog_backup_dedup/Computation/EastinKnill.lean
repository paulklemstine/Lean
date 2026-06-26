import Mathlib

/-!
# The Algebraic Kernel of the Eastin–Knill No-Go Theorem

This file isolates the *algebraic kernel* of the **Eastin–Knill theorem** in a fully
rigorous, finite-dimensional matrix setting over `ℂ`.

A *code* is modelled by a Hermitian idempotent (a projector) `P` onto the code subspace.
An operator `A` is **detectable** with scalar `c` when it compresses to a scalar on the
code, `P A P = c • P` — this is the (compressed) Knill–Laflamme error-detection
condition.  The Eastin–Knill obstruction to universal *transversal* computation is then a
purely algebraic statement: a transversal generator (a finite sum of detectable
single-site terms) compresses to a scalar `(∑ cᵢ) • P`, and any such generator is
**central** in the logical operator algebra.  Hence the logical gates it generates can
only ever act as global phases — they cannot be computationally universal.

## Main results

* `Detectable.smul`, `Detectable.add`, `Detectable.sum` — detectable operators form a
  scalar-valued, linear / sum-closed family (the additivity behind charge conservation).
* `eastin_knill_transversal_scalar` — a transversal generator compresses to the scalar
  `(∑ cᵢ) • P`.
* `detectable_logical_central` / `eastin_knill_transversal_central` — a detectable
  operator (resp. transversal generator) is central in the logical operator algebra:
  its compression commutes with *every* logical operator.
* `logical_noncentral_without_detection` — a boundary theorem: dropping detectability,
  the logical algebra can be the full non-commutative matrix algebra, so the detection
  hypothesis is genuinely necessary.

-- !-- Lab Notebook -- !--
-- Hypothesis:  The Eastin–Knill obstruction is, at its core, the single algebraic fact
--   that idempotency of the code projector forces any scalar-compressing operator to be
--   central in the compressed (logical) algebra.
-- Result:  Confirmed.  `detectable_logical_central` derives centrality from only
--   `P*P = P` and `P A P = c • P`; no analysis or representation theory is needed.
-- Insight:  Centrality is "free" once an operator compresses to a multiple of the
--   projector, because the projector absorbs into the scalar on either side.  The whole
--   physical content (single-site/transversal structure) lives in *establishing*
--   detectability, not in deducing the no-go consequence.
-- Failure analysis:  The naive hope that *all* compressed operators commute is false
--   (`logical_noncentral_without_detection`): with `P = 1` the compression is the
--   identity map and Pauli X, Z fail to commute.  Detectability is the indispensable
--   hypothesis.
-/

open Matrix BigOperators

namespace EastinKnill

variable {n : Type*} [Fintype n] [DecidableEq n]

/-- A quantum error-correcting code, modelled by its (Hermitian) projector `P` onto the
code subspace.  We only need the two algebraic facts that `P` is idempotent and
self-adjoint. -/
structure QECCode (n : Type*) [Fintype n] [DecidableEq n] where
  /-- The projector onto the code subspace. -/
  P : Matrix n n ℂ
  /-- `P` is self-adjoint. -/
  herm : P.conjTranspose = P
  /-- `P` is idempotent. -/
  idem : P * P = P

variable (Q : QECCode n)

/-- An operator `A` is **detectable** with scalar `c` on the code `Q` when it compresses
to a multiple of the projector: `P A P = c • P`.  This is the compressed Knill–Laflamme
error-detection condition. -/
def Detectable (Q : QECCode n) (A : Matrix n n ℂ) (c : ℂ) : Prop :=
  Q.P * A * Q.P = c • Q.P

/-- The **logical compression** of an operator: `A ↦ P A P`.  This is the operator as
seen by the code subspace. -/
noncomputable def logical (Q : QECCode n) (A : Matrix n n ℂ) : Matrix n n ℂ :=
  Q.P * A * Q.P

-- !-- Scalars compress: pulling `d` through `P (d•A) P` scales the detection value. -- !--
/-- Detectability is closed under scalar multiplication. -/
theorem Detectable.smul {A : Matrix n n ℂ} {c : ℂ} (h : Detectable Q A c) (d : ℂ) :
    Detectable Q (d • A) (d * c) := by
  unfold Detectable at *
  rw [Matrix.mul_smul, Matrix.smul_mul, h, smul_smul]

-- !-- Detection values add (`P (A+B) P = P A P + P B P`); additivity = charge conservation. -- !--
/-- Detectability is closed under addition; the detection scalars add. -/
theorem Detectable.add {A B : Matrix n n ℂ} {a b : ℂ}
    (hA : Detectable Q A a) (hB : Detectable Q B b) :
    Detectable Q (A + B) (a + b) := by
  unfold Detectable at *
  rw [Matrix.mul_add, Matrix.add_mul, hA, hB, add_smul]

-- !-- Iterating additivity over a finite family of single-site terms via `Finset.induction`. -- !--
/-- Detectability is closed under finite sums (a transversal generator). -/
theorem Detectable.sum {m : Type*} (s : Finset m) (A : m → Matrix n n ℂ) (c : m → ℂ)
    (h : ∀ i ∈ s, Detectable Q (A i) (c i)) :
    Detectable Q (∑ i ∈ s, A i) (∑ i ∈ s, c i) := by
  classical
  induction s using Finset.induction with
  | empty => simp [Detectable]
  | insert a s ha ih =>
      rw [Finset.sum_insert ha, Finset.sum_insert ha]
      exact (h a (Finset.mem_insert_self a s)).add Q
        (ih (fun i hi => h i (Finset.mem_insert_of_mem hi)))

/-- A **transversal generator**: a finite family of detectable single-site terms.  Its
sum models a transversal Hamiltonian / conserved additive charge. -/
structure TransversalGenerator (Q : QECCode n) (m : Type*) [Fintype m] where
  /-- The single-site term on factor `i`. -/
  term : m → Matrix n n ℂ
  /-- The detection scalar of term `i`. -/
  scalar : m → ℂ
  /-- Each single-site term is detectable. -/
  detect : ∀ i, Detectable Q (term i) (scalar i)

/-- The total operator of a transversal generator. -/
noncomputable def TransversalGenerator.total {m : Type*} [Fintype m]
    (G : TransversalGenerator Q m) : Matrix n n ℂ :=
  ∑ i, G.term i

-- !-- A transversal generator is a finite sum of detectables, so `Detectable.sum` applies. -- !--
/-- **Eastin–Knill scalar compression.**  A transversal generator compresses on the code
to the scalar `(∑ cᵢ) • P`. -/
theorem eastin_knill_transversal_scalar {m : Type*} [Fintype m]
    (G : TransversalGenerator Q m) :
    Q.P * G.total * Q.P = (∑ i, G.scalar i) • Q.P :=
  Detectable.sum Q Finset.univ G.term G.scalar (fun i _ => G.detect i)

-- !-- After `P A P = c•P`, idempotency lets `P` absorb the scalar on either side. -- !--
/-- **Centrality of a detectable operator.**  If `A` is detectable then its logical
compression commutes with the logical compression of *every* operator `B`: the
detectable operator is central in the logical operator algebra. -/
theorem detectable_logical_central {A : Matrix n n ℂ} {c : ℂ}
    (h : Detectable Q A c) (B : Matrix n n ℂ) :
    logical Q A * logical Q B = logical Q B * logical Q A := by
  have hP := Q.idem
  unfold logical
  rw [show Q.P * A * Q.P = c • Q.P from h, Matrix.smul_mul, Matrix.mul_smul]
  congr 1
  -- `P * (P B P) = P B P = (P B P) * P`, using `P * P = P`.
  have e1 : Q.P * (Q.P * B * Q.P) = Q.P * B * Q.P := by
    rw [← Matrix.mul_assoc, ← Matrix.mul_assoc, hP]
  have e2 : (Q.P * B * Q.P) * Q.P = Q.P * B * Q.P := by
    rw [Matrix.mul_assoc, hP]
  rw [e1, e2]

-- !-- The total generator is detectable (scalar compression), so `detectable_logical_central` applies. -- !--
/-- **Eastin–Knill no-go (algebraic kernel).**  The compression of a transversal
generator is central in the logical operator algebra: it commutes with the compression of
every operator.  This is the precise obstruction to logical universality — the generator
can only ever act as a global phase. -/
theorem eastin_knill_transversal_central {m : Type*} [Fintype m]
    (G : TransversalGenerator Q m) (B : Matrix n n ℂ) :
    logical Q G.total * logical Q B = logical Q B * logical Q G.total :=
  detectable_logical_central Q (eastin_knill_transversal_scalar Q G) B

end EastinKnill

namespace EastinKnill

/-! ## Boundary theorem: detectability is essential

With the *trivial* code `P = 1` (the whole space is the code subspace, distance `1`),
the logical compression is the identity map, so logical operators inherit the full
non-commutativity of the matrix algebra.  Concretely, the Pauli `X` and `Z` matrices have
non-commuting compressions.  This shows the detection hypothesis in
`detectable_logical_central` cannot be dropped. -/

/-- The trivial (distance-1) code on a 2-level system: the identity projector. -/
def trivialCode : QECCode (Fin 2) where
  P := 1
  herm := by simp
  idem := by simp

/-- Pauli `X`. -/
def pauliX : Matrix (Fin 2) (Fin 2) ℂ := !![0, 1; 1, 0]

/-- Pauli `Z`. -/
def pauliZ : Matrix (Fin 2) (Fin 2) ℂ := !![1, 0; 0, -1]

-- !-- With `P = 1` the compression is the identity map, and Pauli `X`, `Z` fail to commute. -- !--
/-- **Boundary theorem.**  Without detectability the logical operators need not commute:
on the trivial code the compressions of Pauli `X` and `Z` do not commute.  Hence the
detection hypothesis in `detectable_logical_central` is essential. -/
theorem logical_noncentral_without_detection :
    logical trivialCode pauliX * logical trivialCode pauliZ
      ≠ logical trivialCode pauliZ * logical trivialCode pauliX := by
  unfold logical trivialCode
  simp only [one_mul, mul_one]
  exact ne_of_apply_ne (fun M => M 0 1) (by norm_num [Matrix.mul_apply, Fin.sum_univ_two,
    pauliX, pauliZ, Complex.ext_iff])

/-! ## A concrete detectable example

The rank-1 projector `P = diag(1,0)` is a genuine code, and every diagonal operator
`diag(a,b)` is detectable on it with scalar `a` — a witness that the `Detectable`
predicate is inhabited non-trivially. -/

/-- The rank-1 code projecting onto the first basis vector. -/
def basisCode : QECCode (Fin 2) where
  P := !![1, 0; 0, 0]
  herm := by
    ext i j; fin_cases i <;> fin_cases j <;> simp [Matrix.conjTranspose]
  idem := by
    ext i j; fin_cases i <;> fin_cases j <;> simp [Matrix.mul_apply, Fin.sum_univ_two]

-- !-- The (0,0) entry survives the rank-1 compression; all others vanish. -- !--
/-- A diagonal operator `diag(a,b)` is detectable on the rank-1 `basisCode` with scalar
`a`, witnessing that detectability is inhabited non-trivially. -/
theorem diagonal_detectable (a b : ℂ) :
    Detectable basisCode (!![a, 0; 0, b]) a := by
  unfold Detectable basisCode
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [Matrix.mul_apply, Fin.sum_univ_two]

end EastinKnill