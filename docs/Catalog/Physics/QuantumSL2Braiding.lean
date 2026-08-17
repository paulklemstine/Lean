/-
# Braiding from `U_q(sl₂)`: Temperley–Lieb, the Yang–Baxter/braid relation, and `B₃`

This file is the *topological* half of the bridge

`U_q(sl₂)`  ⟶  braided tensor category  ⟶  braid group representations  ⟶  Jones polynomial.

## Contents

* **Abstract Temperley–Lieb input.**  `QuantumBraiding.IsTLPair A e₁ e₂` records the
  Temperley–Lieb relations `eᵢ² = δ eᵢ` (with loop value `δ = -A² - A⁻²`), `e₁e₂e₁ = e₁`,
  `e₂e₁e₂ = e₂` in an arbitrary `k`-algebra.

* **Braiding.**  `kauffman A e = A·1 + A⁻¹·e` is the Kauffman-bracket resolution of a positive
  crossing.  We prove it is invertible (`kauffman_mul_inv`, a Reidemeister-II statement) and
  satisfies the **braid relation / Yang–Baxter equation** `g₁g₂g₁ = g₂g₁g₂`
  (`kauffman_braid_relation`).  This is exactly the statement that the `U_q(sl₂)` `R`-matrix
  makes its representation category *braided*.

* **Braid group representations.**  `QuantumBraiding.B3` is the 3-strand braid group as a
  presented group and `braidRep` turns any Temperley–Lieb pair into a genuine group
  homomorphism `B₃ →* Rˣ` (`braidRep_of`, `braidRep_of'` compute it on the generators).

* **A concrete 8-dimensional realisation.**  On `V ⊗ V ⊗ V` with `V = k²` we build `E1`, `E2`
  out of the `q`-deformed cup/cap and verify all Temperley–Lieb relations by explicit
  computation (`E1_sq`, `E2_sq`, `E1_E2_E1`, `E2_E1_E2`).  Consequently `R_1 = kauffman A E1`,
  `R_2 = kauffman A E2` satisfy the Yang–Baxter equation and give a representation of `B₃` by
  `8 × 8` matrices (`matrixBraidRep`).

* **Why this is `U_q(sl₂)`.**  `uqSl2_fundamental` shows the explicit `2 × 2` matrices
  `E, F, K, K⁻¹` satisfy the `U_q(sl₂)` relations of
  `Catalog/Physics/QuantumSL2ClassicalLimit.lean`, and `singlet_invariant` shows that the cup
  vector `ω = A|01⟩ - A⁻¹|10⟩` spans a *trivial subrepresentation* of `V ⊗ V` for the standard
  coproduct `Δ(E) = E⊗1 + K⊗E`, `Δ(F) = F⊗K⁻¹ + 1⊗F`, `Δ(K) = K⊗K`, provided `q = A⁻²`.
  Finally `loop_value_eq_neg_qdim` identifies the Temperley–Lieb loop value `δ` with minus the
  quantum dimension `[2]_q` of the fundamental representation.
-/

import Mathlib
import Physics.QuantumSL2ClassicalLimit

open Matrix

namespace QuantumBraiding

/-! ## 1. Temperley–Lieb pairs and the Kauffman braiding -/

section Abstract

variable {k : Type*} [Field k] {R : Type*} [Ring R] [Algebra k R]

/-- The loop value (quantum dimension) `δ = -A² - A⁻²` of the Kauffman bracket. -/
noncomputable def loopValue (A : k) : k := -A ^ 2 - (A ^ 2)⁻¹

/-- Two Temperley–Lieb generators inside a `k`-algebra. -/
structure IsTLPair (A : k) (e1 e2 : R) : Prop where
  /-- The Kauffman variable is invertible. -/
  A_ne : A ≠ 0
  /-- `e₁² = δ e₁`. -/
  sq1 : e1 * e1 = loopValue A • e1
  /-- `e₂² = δ e₂`. -/
  sq2 : e2 * e2 = loopValue A • e2
  /-- `e₁e₂e₁ = e₁`. -/
  zig : e1 * e2 * e1 = e1
  /-- `e₂e₁e₂ = e₂`. -/
  zag : e2 * e1 * e2 = e2

/-- Kauffman's resolution of a positive crossing, `A·1 + A⁻¹·e`. -/
noncomputable def kauffman (A : k) (e : R) : R := A • (1 : R) + A⁻¹ • e

/-- The inverse crossing `A⁻¹·1 + A·e`. -/
noncomputable def kauffmanInv (A : k) (e : R) : R := A⁻¹ • (1 : R) + A • e

/-- **Reidemeister II**: the two crossings are inverse to each other. -/
theorem kauffman_mul_inv {A : k} {e : R} (hA : A ≠ 0) (he : e * e = loopValue A • e) :
    kauffman A e * kauffmanInv A e = 1 := by
  simp only [kauffman, kauffmanInv, loopValue, add_mul, mul_add, smul_mul_assoc, mul_smul_comm,
    one_mul, mul_one, smul_smul, he]
  match_scalars <;> field_simp <;> ring

theorem kauffmanInv_mul {A : k} {e : R} (hA : A ≠ 0) (he : e * e = loopValue A • e) :
    kauffmanInv A e * kauffman A e = 1 := by
  simp only [kauffman, kauffmanInv, loopValue, add_mul, mul_add, smul_mul_assoc, mul_smul_comm,
    one_mul, mul_one, smul_smul, he]
  match_scalars <;> field_simp <;> ring

variable {A : k} {e1 e2 : R}

/-- Normal form of the triple product `g₁g₂g₁`: it is symmetric in `e₁ ↔ e₂`. -/
theorem kauffman_triple (h : IsTLPair A e1 e2) :
    kauffman A e1 * kauffman A e2 * kauffman A e1
      = (A ^ 3) • (1 : R) + A • e1 + A • e2 + A⁻¹ • (e1 * e2) + A⁻¹ • (e2 * e1) := by
  have hA := h.A_ne
  simp only [kauffman, loopValue, add_mul, mul_add, smul_mul_assoc, mul_smul_comm, one_mul,
    mul_one, smul_smul, h.zig, h.sq1, loopValue]
  match_scalars <;> field_simp <;> ring

theorem kauffman_triple' (h : IsTLPair A e1 e2) :
    kauffman A e2 * kauffman A e1 * kauffman A e2
      = (A ^ 3) • (1 : R) + A • e1 + A • e2 + A⁻¹ • (e1 * e2) + A⁻¹ • (e2 * e1) := by
  have hA := h.A_ne
  simp only [kauffman, loopValue, add_mul, mul_add, smul_mul_assoc, mul_smul_comm, one_mul,
    mul_one, smul_smul, h.zag, h.sq2, loopValue]
  match_scalars <;> field_simp <;> ring

/-- **The braid relation (Yang–Baxter equation)** for the Kauffman braiding. -/
theorem kauffman_braid_relation (h : IsTLPair A e1 e2) :
    kauffman A e1 * kauffman A e2 * kauffman A e1
      = kauffman A e2 * kauffman A e1 * kauffman A e2 := by
  rw [kauffman_triple h, kauffman_triple' h]

/-- The braiding as a unit of the algebra. -/
noncomputable def kauffmanUnit (A : k) (e : R) (hA : A ≠ 0) (he : e * e = loopValue A • e) : Rˣ where
  val := kauffman A e
  inv := kauffmanInv A e
  val_inv := kauffman_mul_inv hA he
  inv_val := kauffmanInv_mul hA he

end Abstract

/-! ## 2. The three-strand braid group and its Temperley–Lieb representations -/

/-- The single defining relator of the 3-strand braid group `σ₁σ₂σ₁ = σ₂σ₁σ₂`. -/
def braidRels : Set (FreeGroup (Fin 2)) :=
  {FreeGroup.of 0 * FreeGroup.of 1 * FreeGroup.of 0 *
    (FreeGroup.of 1 * FreeGroup.of 0 * FreeGroup.of 1)⁻¹}

/-- The 3-strand braid group `B₃ = ⟨σ₁, σ₂ | σ₁σ₂σ₁ = σ₂σ₁σ₂⟩`. -/
abbrev B3 := PresentedGroup braidRels

/-- Any pair of elements of a group satisfying the braid relation defines a representation
of `B₃`. -/
def braidHom {G : Type*} [Group G] (g0 g1 : G) (h : g0 * g1 * g0 = g1 * g0 * g1) : B3 →* G := by
  refine PresentedGroup.toGroup (f := fun i => if i = 0 then g0 else g1) ?_
  intro r hr
  simp only [braidRels, Set.mem_singleton_iff] at hr
  subst hr
  simp [h]
  group

@[simp] theorem braidHom_of {G : Type*} [Group G] (g0 g1 : G)
    (h : g0 * g1 * g0 = g1 * g0 * g1) : braidHom g0 g1 h (PresentedGroup.of 0) = g0 := by
  simp [braidHom, PresentedGroup.toGroup.of]

@[simp] theorem braidHom_of' {G : Type*} [Group G] (g0 g1 : G)
    (h : g0 * g1 * g0 = g1 * g0 * g1) : braidHom g0 g1 h (PresentedGroup.of 1) = g1 := by
  simp [braidHom, PresentedGroup.toGroup.of]

section BraidRep

variable {k : Type*} [Field k] {R : Type*} [Ring R] [Algebra k R] {A : k} {e1 e2 : R}

/-- **The Reshetikhin–Turaev braid representation.**  Every Temperley–Lieb pair yields a
representation of the 3-strand braid group by units of the algebra. -/
noncomputable def braidRep (h : IsTLPair A e1 e2) : B3 →* Rˣ :=
  braidHom (kauffmanUnit A e1 h.A_ne h.sq1) (kauffmanUnit A e2 h.A_ne h.sq2)
    (Units.ext (by
      simpa [kauffmanUnit] using kauffman_braid_relation h))

theorem braidRep_of (h : IsTLPair A e1 e2) :
    (braidRep h (PresentedGroup.of 0) : R) = kauffman A e1 := by
  simp [braidRep, kauffmanUnit]

theorem braidRep_of' (h : IsTLPair A e1 e2) :
    (braidRep h (PresentedGroup.of 1) : R) = kauffman A e2 := by
  simp [braidRep, kauffmanUnit]

end BraidRep

/-! ## 3. The concrete `8`-dimensional Temperley–Lieb representation -/

section Concrete

variable {k : Type*} [Field k]

/-- Index type of `V ⊗ V ⊗ V` for `V = k²`. -/
abbrev Tri := Fin 2 × Fin 2 × Fin 2

/-- The `q`-deformed cup `ω = A|01⟩ - A⁻¹|10⟩`, as a matrix of coefficients. -/
noncomputable def cup (A : k) : Fin 2 → Fin 2 → k := fun i j =>
  if i = 0 ∧ j = 1 then A else if i = 1 ∧ j = 0 then -A⁻¹ else 0

/-- The Temperley–Lieb generator `e₁ = (cup ∘ cap) ⊗ id`. -/
noncomputable def E1 (A : k) : Matrix Tri Tri k := Matrix.of fun p r =>
  cup A p.1 p.2.1 * (-cup A r.1 r.2.1) * (if p.2.2 = r.2.2 then 1 else 0)

/-- The Temperley–Lieb generator `e₂ = id ⊗ (cup ∘ cap)`. -/
noncomputable def E2 (A : k) : Matrix Tri Tri k := Matrix.of fun p r =>
  (if p.1 = r.1 then 1 else 0) * (cup A p.2.1 p.2.2 * (-cup A r.2.1 r.2.2))

set_option maxHeartbeats 1000000 in
theorem E1_sq (A : k) (hA : A ≠ 0) : E1 A * E1 A = loopValue A • E1 A := by
  ext p r
  fin_cases p <;> fin_cases r <;>
    simp [Matrix.mul_apply, Fintype.sum_prod_type, Fin.sum_univ_two, E1, cup, loopValue] <;>
    field_simp <;> ring

set_option maxHeartbeats 1000000 in
theorem E2_sq (A : k) (hA : A ≠ 0) : E2 A * E2 A = loopValue A • E2 A := by
  ext p r
  fin_cases p <;> fin_cases r <;>
    simp [Matrix.mul_apply, Fintype.sum_prod_type, Fin.sum_univ_two, E2, cup, loopValue] <;>
    field_simp <;> ring

set_option maxHeartbeats 2000000 in
theorem E1_E2_E1 (A : k) (hA : A ≠ 0) : E1 A * E2 A * E1 A = E1 A := by
  ext p r
  fin_cases p <;> fin_cases r <;>
    simp [Matrix.mul_apply, Fintype.sum_prod_type, Fin.sum_univ_two, E1, E2, cup] <;>
    field_simp

set_option maxHeartbeats 2000000 in
theorem E2_E1_E2 (A : k) (hA : A ≠ 0) : E2 A * E1 A * E2 A = E2 A := by
  ext p r
  fin_cases p <;> fin_cases r <;>
    simp [Matrix.mul_apply, Fintype.sum_prod_type, Fin.sum_univ_two, E1, E2, cup] <;>
    field_simp

/-- The explicit `8 × 8` Temperley–Lieb pair coming from the `U_q(sl₂)` cup/cap. -/
theorem isTLPair_matrix (A : k) (hA : A ≠ 0) : IsTLPair A (E1 A) (E2 A) where
  A_ne := hA
  sq1 := E1_sq A hA
  sq2 := E2_sq A hA
  zig := E1_E2_E1 A hA
  zag := E2_E1_E2 A hA

/-- **The `R`-matrix satisfies the Yang–Baxter equation on `V ⊗ V ⊗ V`.** -/
theorem yang_baxter (A : k) (hA : A ≠ 0) :
    kauffman A (E1 A) * kauffman A (E2 A) * kauffman A (E1 A)
      = kauffman A (E2 A) * kauffman A (E1 A) * kauffman A (E2 A) :=
  kauffman_braid_relation (isTLPair_matrix A hA)

/-- The resulting `8`-dimensional representation of the 3-strand braid group. -/
noncomputable def matrixBraidRep (A : k) (hA : A ≠ 0) : B3 →* (Matrix Tri Tri k)ˣ :=
  braidRep (isTLPair_matrix A hA)

end Concrete

/-! ## 4. The `U_q(sl₂)` origin of the cup: invariance of the quantum singlet -/

section Singlet

open QuantumSL2

variable {k : Type*} [Field k]

/-- The fundamental (2-dimensional) representation: `E`. -/
noncomputable def Emat : Matrix (Fin 2) (Fin 2) k := !![0, 1; 0, 0]

/-- The fundamental representation: `F`. -/
noncomputable def Fmat : Matrix (Fin 2) (Fin 2) k := !![0, 0; 1, 0]

/-- The fundamental representation: `K`. -/
noncomputable def Kmat (q : k) : Matrix (Fin 2) (Fin 2) k := !![q, 0; 0, q⁻¹]

/-- The fundamental representation: `K⁻¹`. -/
noncomputable def Kimat (q : k) : Matrix (Fin 2) (Fin 2) k := !![q⁻¹, 0; 0, q]

/-- **The fundamental representation of `U_q(sl₂)`.** -/
theorem uqSl2_fundamental (q : k) (hq : q ≠ 0) (hq2 : q ^ 2 ≠ 1) :
    IsUqSl2 q (Emat : Matrix (Fin 2) (Fin 2) k) Fmat (Kmat q) (Kimat q) where
  q_ne := hq
  qsq_ne := hq2
  K_mul_Ki := by
    ext i j; fin_cases i <;> fin_cases j <;> simp [Kmat, Kimat, Matrix.mul_apply,
      Fin.sum_univ_two, mul_inv_cancel₀ hq, inv_mul_cancel₀ hq]
  Ki_mul_K := by
    ext i j; fin_cases i <;> fin_cases j <;> simp [Kmat, Kimat, Matrix.mul_apply,
      Fin.sum_univ_two, mul_inv_cancel₀ hq, inv_mul_cancel₀ hq]
  K_E := by
    ext i j; fin_cases i <;> fin_cases j <;>
      simp [Kmat, Emat, Matrix.mul_apply, Fin.sum_univ_two] <;> field_simp
  K_F := by
    ext i j; fin_cases i <;> fin_cases j <;>
      simp [Kmat, Fmat, Matrix.mul_apply, Fin.sum_univ_two] <;> field_simp
  E_F := by
    have h21 : q ^ 2 - 1 ≠ 0 := sub_ne_zero.mpr hq2
    have hd : q - q⁻¹ ≠ 0 := by
      intro hc
      apply hq2
      field_simp at hc
      linear_combination hc
    ext i j; fin_cases i <;> fin_cases j <;>
      simp [Kmat, Kimat, Emat, Fmat] <;> field_simp <;> ring
  
/-- The `q`-deformed singlet vector `ω = A|01⟩ - A⁻¹|10⟩` inside `V ⊗ V`. -/
noncomputable def omegaVec (A : k) : Fin 2 × Fin 2 → k := fun p => cup A p.1 p.2

/-- The coproduct `Δ(E) = E ⊗ 1 + K ⊗ E` acting on `V ⊗ V`. -/
noncomputable def deltaE (q : k) : Matrix (Fin 2 × Fin 2) (Fin 2 × Fin 2) k :=
  Matrix.kroneckerMap (· * ·) Emat 1 + Matrix.kroneckerMap (· * ·) (Kmat q) Emat

/-- The coproduct `Δ(F) = F ⊗ K⁻¹ + 1 ⊗ F`. -/
noncomputable def deltaF (q : k) : Matrix (Fin 2 × Fin 2) (Fin 2 × Fin 2) k :=
  Matrix.kroneckerMap (· * ·) Fmat (Kimat q) + Matrix.kroneckerMap (· * ·) 1 Fmat

/-- The coproduct `Δ(K) = K ⊗ K`. -/
noncomputable def deltaK (q : k) : Matrix (Fin 2 × Fin 2) (Fin 2 × Fin 2) k :=
  Matrix.kroneckerMap (· * ·) (Kmat q) (Kmat q)

/-- **The cup vector spans a trivial subrepresentation of `V ⊗ V`.**  This is the
representation-theoretic reason why the Temperley–Lieb cup/cap — and hence the whole
Reshetikhin–Turaev / Kauffman bracket construction of the Jones polynomial — exists.
The Kauffman variable is tied to the quantum parameter by `q = A⁻²`. -/
theorem singlet_invariant (A : k) (hA : A ≠ 0) (q : k) (hq : q = (A ^ 2)⁻¹) :
    deltaE q *ᵥ omegaVec A = 0 ∧ deltaF q *ᵥ omegaVec A = 0 ∧
      deltaK q *ᵥ omegaVec A = omegaVec A := by
  subst hq
  refine ⟨?_, ?_, ?_⟩ <;> ext p <;> fin_cases p <;>
    simp [deltaE, deltaF, deltaK, omegaVec, Emat, Fmat, Kmat, Kimat, cup, Matrix.mulVec,
      Matrix.kroneckerMap, dotProduct, Fintype.sum_prod_type, Fin.sum_univ_two] <;>
    field_simp <;> ring

/-- The Temperley–Lieb loop value is minus the quantum dimension `[2]_q` of the fundamental
representation of `U_q(sl₂)`, under the standard substitution `q = A⁻²`. -/
theorem loop_value_eq_neg_qdim (A : k) (hA : A ≠ 0) (q : k) (hq : q = (A ^ 2)⁻¹)
    (hq1 : q - q⁻¹ ≠ 0) : loopValue A = -qInt q 2 := by
  subst hq
  rw [qInt_two _ (inv_ne_zero (pow_ne_zero 2 hA)) hq1, inv_inv, loopValue]
  ring

end Singlet

end QuantumBraiding