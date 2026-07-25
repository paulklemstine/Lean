import Mathlib

/-! # CatalogBuild.Speculative.RosettaStone.Bridge6_Derived

Auto-generated from theorem catalog database.
Domain: Speculative/RosettaStone
Declarations: 4
-/

/-- [Section: # CatalogBuild.Speculative.RosettaStone.Bridge6_Derived
Auto-generated from theorem catalog database.
Domain: Speculative/RosettaStone
Declarations: 4] -/
theorem idempotent_range_ker_sup (e : M →ₗ[R] M) (he : e ∘ₗ e = e) :
    LinearMap.range e ⊔ LinearMap.ker e = ⊤ := by
  ext x;
  simp +zetaDelta at *;
  rw [ Submodule.mem_sup ];
  refine' ⟨ e x, _, x - e x, _, _ ⟩ <;> simp +decide [ he ];
  rw [ sub_eq_zero, LinearMap.ext_iff ] at * ; aesop

/-- [Section: # CatalogBuild.Speculative.RosettaStone.Bridge6_Derived
Auto-generated from theorem catalog database.
Domain: Speculative/RosettaStone
Declarations: 4] -/
theorem idempotent_range_ker_inf (e : M →ₗ[R] M) (he : e ∘ₗ e = e) :
    LinearMap.range e ⊓ LinearMap.ker e = ⊥ := by
  simp_all +decide [ Submodule.eq_bot_iff ];
  simp_all +decide [ LinearMap.ext_iff ]

theorem idempotent_restrict_range (e : M →ₗ[R] M) (he : e ∘ₗ e = e)
    (x : M) (hx : x ∈ LinearMap.range e) : e x = x := by
  obtain ⟨ y, rfl ⟩ := hx; simp +decide [ ← LinearMap.comp_apply, he ] ;

/-- Trace is invariant under cyclic permutation: Tr(AB) = Tr(BA). -/
theorem trace_cyclic (n : ℕ) (A B : Matrix (Fin n) (Fin n) ℝ) :
    (A * B).trace = (B * A).trace :=
  Matrix.trace_mul_comm A B