/-
# Third cycle: the quantum trace closes the bridge

The Reshetikhin–Turaev invariant of a closed braid is the **quantum trace** of the image of the
braid under the `R`-matrix representation.  The Kauffman-bracket computation of
`Catalog/Physics/JonesPolynomialTL.lean` was carried out inside the abstract Temperley–Lieb
algebra `TL₂`; this file shows that the two agree, i.e. that the abstract Markov trace used
there really is the quantum trace of the explicit `U_q(sl₂)` `R`-matrix on `V ⊗ V`.

Concretely, with the ribbon-type weight `μ = diag(-A², -A⁻²)` on `V = k²` we define

`qtrace A X = ∑_{i,j} μᵢ μⱼ X_{(i,j),(i,j)}`,

prove `qtrace 1 = δ²` and `qtrace e = δ` for the Temperley–Lieb generator `e` (`qtrace_one`,
`qtrace_eMat`), and conclude

`qtrace A (Řⁿ) = δ · bracket A n`   (`qtrace_kauffman_pow`),

where `Ř = A·1 + A⁻¹·e` is the braiding and `bracket A n` is the Kauffman bracket of the `(2,n)`
torus link.  Specialising to `n = 3` gives the trefoil's bracket and Jones value directly from
the `R`-matrix (`qtrace_trefoil`, `jones_from_qtrace`).
-/

import Mathlib
import Physics.QuantumCasimirRT
import Physics.JonesPolynomialTL

namespace QuantumTrace

open Matrix QuantumBraiding QuantumCasimir QuantumJones

variable {k : Type*} [Field k]

/-- The ribbon weight on the fundamental representation. -/
noncomputable def mu (A : k) : Fin 2 → k := fun i => if i = 0 then -A ^ 2 else -(A⁻¹) ^ 2

/-- The quantum (Markov) trace on `End(V ⊗ V)`. -/
noncomputable def qtrace (A : k) (X : Matrix (Fin 2 × Fin 2) (Fin 2 × Fin 2) k) : k :=
  ∑ p : Fin 2 × Fin 2, mu A p.1 * mu A p.2 * X p p

theorem qtrace_add (A : k) (X Y : Matrix (Fin 2 × Fin 2) (Fin 2 × Fin 2) k) :
    qtrace A (X + Y) = qtrace A X + qtrace A Y := by
  simp only [qtrace, Matrix.add_apply, mul_add]
  exact Finset.sum_add_distrib

theorem qtrace_smul (A c : k) (X : Matrix (Fin 2 × Fin 2) (Fin 2 × Fin 2) k) :
    qtrace A (c • X) = c * qtrace A X := by
  simp only [qtrace, Matrix.smul_apply, smul_eq_mul, Finset.mul_sum]
  exact Finset.sum_congr rfl fun p _ => by ring

/-- The quantum dimension of `V ⊗ V` is `δ²`. -/
theorem qtrace_one (A : k) (hA : A ≠ 0) :
    qtrace A (1 : Matrix (Fin 2 × Fin 2) (Fin 2 × Fin 2) k) = loopValue A ^ 2 := by
  simp only [qtrace, Matrix.one_apply_eq, mul_one, Fintype.sum_prod_type, Fin.sum_univ_two, mu,
    loopValue]
  norm_num
  field_simp
  ring

/-- The quantum trace of the Temperley–Lieb generator is the loop value `δ`. -/
theorem qtrace_eMat (A : k) (hA : A ≠ 0) : qtrace A (eMat A) = loopValue A := by
  simp only [qtrace, eMat, cup, Matrix.of_apply, Fintype.sum_prod_type, Fin.sum_univ_two, mu,
    loopValue]
  norm_num
  field_simp
  ring

/-- **The quantum trace of the braid `σ₁ⁿ` is the Kauffman bracket of the `(2,n)` torus link.**
This identifies the abstract Markov trace on `TL₂` with the quantum trace of the explicit
`U_q(sl₂)` `R`-matrix. -/
theorem qtrace_kauffman_pow (A : k) (hA : A ≠ 0) (n : ℕ) :
    qtrace A ((kauffman A (eMat A)) ^ n) = loopValue A * bracket A n := by
  rw [kauffman_pow (eMat_sq A hA) n, qtrace_add, qtrace_smul, qtrace_smul, qtrace_one A hA,
    qtrace_eMat A hA, bracket]
  ring

/-- The trefoil, computed from the `R`-matrix by the quantum trace. -/
theorem qtrace_trefoil (A : k) (hA : A ≠ 0) :
    qtrace A ((kauffman A (eMat A)) ^ 3) = loopValue A * (-A ^ 5 - (A⁻¹) ^ 3 + (A⁻¹) ^ 7) := by
  rw [qtrace_kauffman_pow A hA 3, bracket_trefoil hA]

/-- The Jones invariant of the closure of `σ₁ⁿ` read off from the quantum trace of the
`R`-matrix. -/
theorem jones_from_qtrace (A : k) (hA : A ≠ 0) (hδ : loopValue A ≠ 0) (n : ℕ) :
    jones A n = (-(A⁻¹) ^ 3) ^ n * (qtrace A ((kauffman A (eMat A)) ^ n) / loopValue A) := by
  rw [qtrace_kauffman_pow A hA n, jones]
  field_simp

end QuantumTrace