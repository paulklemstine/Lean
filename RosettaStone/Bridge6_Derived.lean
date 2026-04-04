/-
  Bridge 6: Derived / Homotopical Algebra
  =========================================
  Idempotent splitting in modules.
  In derived AG, idempotency holds "up to homotopy."
-/
import Mathlib

namespace RosettaStone.Derived

section IdempotentModules

variable {R : Type*} [CommRing R]
variable {M : Type*} [AddCommGroup M] [Module R M]

/-
PROBLEM
The kernel and range of an idempotent span the whole module.

PROVIDED SOLUTION
For any x in M, write x = e(x) + (x - e(x)). Then e(x) is in range(e) and (x - e(x)) is in ker(e) because e(x - e(x)) = e(x) - e(e(x)) = e(x) - e(x) = 0 using he: e∘e = e. Use Submodule.mem_sup, LinearMap.mem_range, LinearMap.mem_ker.
-/
theorem idempotent_range_ker_sup (e : M →ₗ[R] M) (he : e ∘ₗ e = e) :
    LinearMap.range e ⊔ LinearMap.ker e = ⊤ := by
  ext x;
  simp +zetaDelta at *;
  rw [ Submodule.mem_sup ];
  refine' ⟨ e x, _, x - e x, _, _ ⟩ <;> simp +decide [ he ];
  rw [ sub_eq_zero, LinearMap.ext_iff ] at * ; aesop

/-
PROBLEM
The kernel and range of an idempotent are disjoint.

PROVIDED SOLUTION
If x is in range(e) ∩ ker(e), then x = e(y) for some y (from range), and e(x) = 0 (from ker). But then x = e(y) and e(e(y)) = e(y) by he, so 0 = e(x) = e(e(y)) = e(y) = x. Use Submodule.mem_inf, Submodule.mem_bot.
-/
theorem idempotent_range_ker_inf (e : M →ₗ[R] M) (he : e ∘ₗ e = e) :
    LinearMap.range e ⊓ LinearMap.ker e = ⊥ := by
  simp_all +decide [ Submodule.eq_bot_iff ];
  simp_all +decide [ LinearMap.ext_iff ]

/-
PROBLEM
An idempotent acts as identity on its range.

PROVIDED SOLUTION
Since x is in range(e), there exists y such that e(y) = x. Then e(x) = e(e(y)) = e(y) = x using he: e∘e = e. Use LinearMap.mem_range to obtain y, then LinearMap.ext_iff.mp he y or the fact that (e∘e)(y) = e(y).
-/
theorem idempotent_restrict_range (e : M →ₗ[R] M) (he : e ∘ₗ e = e)
    (x : M) (hx : x ∈ LinearMap.range e) : e x = x := by
  obtain ⟨ y, rfl ⟩ := hx; simp +decide [ ← LinearMap.comp_apply, he ] ;

end IdempotentModules

section Trace

/-- Trace is invariant under cyclic permutation: Tr(AB) = Tr(BA). -/
theorem trace_cyclic (n : ℕ) (A B : Matrix (Fin n) (Fin n) ℝ) :
    (A * B).trace = (B * A).trace :=
  Matrix.trace_mul_comm A B

end Trace

end RosettaStone.Derived