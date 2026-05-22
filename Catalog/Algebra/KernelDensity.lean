/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# General Linear Map Kernel Density Theorem

For a nonzero linear map `f : V →ₗ[ZMod q] W` between finite-dimensional vector spaces
over a prime field, the kernel occupies at most a `1/q` fraction of the domain.

## Main results

* `card_kernel_mul_card_range` — The exact product formula:
  `|ker f| * |range f| = |V|`.

* `nonzero_linear_map_range_card_ge_q` — If `f ≠ 0`, then `q ≤ |range f|`.

* `nonzero_linear_map_kernel_density` — If `f ≠ 0`, then `|ker f| * q ≤ |V|`.

* `card_kernel_dvd_card_domain` — `|ker f|` divides `|V|`.

* `nonzero_linear_map_kernel_codim_pos` — If `f ≠ 0`, then
  `finrank (ZMod q) (ker f) < finrank (ZMod q) V`.

* `nonzero_linear_functional_kernel_density` — Specialization to linear functionals.
-/

open Classical

noncomputable section

variable {q : ℕ} [Fact q.Prime]
variable {V W : Type*} [AddCommGroup V] [Module (ZMod q) V]
    [AddCommGroup W] [Module (ZMod q) W]
    [FiniteDimensional (ZMod q) V] [FiniteDimensional (ZMod q) W]
    [Fintype V] [Fintype W]

-- The exact product formula: the cardinality of the kernel times the cardinality
-- of the range equals the cardinality of the domain. This is a cardinal form of
-- rank-nullity, proved via the first isomorphism theorem.
omit [FiniteDimensional (ZMod q) V] [FiniteDimensional (ZMod q) W] in
theorem card_kernel_mul_card_range (f : V →ₗ[ZMod q] W) :
    Fintype.card f.ker * Fintype.card f.range = Fintype.card V := by
  have h_iso : Fintype.card (V ⧸ f.ker.toAddSubgroup) = Fintype.card f.range := by
    convert Fintype.card_congr (f.quotKerEquivRange.toEquiv)
  have := AddSubgroup.card_mul_index f.ker.toAddSubgroup
  simp_all +decide [AddSubgroup.index]

-- The kernel cardinality divides the domain cardinality.
omit [FiniteDimensional (ZMod q) V] [FiniteDimensional (ZMod q) W] in
theorem card_kernel_dvd_card_domain (f : V →ₗ[ZMod q] W) :
    Fintype.card f.ker ∣ Fintype.card V := by
  exact ⟨Fintype.card f.range, (card_kernel_mul_card_range f).symm⟩

-- A nonzero linear map has range of cardinality at least `q`.
omit [FiniteDimensional (ZMod q) W] [Fintype W] in
theorem nonzero_linear_map_range_card_ge_q
    (f : V →ₗ[ZMod q] W) (hf : f ≠ 0) :
    q ≤ Fintype.card f.range := by
  have h_range_dim : 1 ≤ Module.finrank (ZMod q) f.range := by
    contrapose! hf
    simp_all +decide [Submodule.eq_bot_iff]
    exact LinearMap.ext hf
  have h_range_card : Fintype.card f.range = q ^ Module.finrank (ZMod q) f.range :=
    Eq.symm (FiniteField.pow_finrank_eq_card q ↥f.range)
  exact h_range_card.symm ▸ Nat.le_self_pow (by linarith) _

omit [FiniteDimensional (ZMod q) W] in
/-- **Kernel Density Theorem**: For a nonzero linear map between finite-dimensional
vector spaces over `ZMod q`, the kernel occupies at most a `1/q` fraction of the domain.
This is the universal counting principle behind linear codes, randomized linear tests,
and finite-field density arguments. -/
theorem nonzero_linear_map_kernel_density
    (f : V →ₗ[ZMod q] W) (hf : f ≠ 0) :
    Fintype.card f.ker * q ≤ Fintype.card V := by
  calc Fintype.card f.ker * q
      ≤ Fintype.card f.ker * Fintype.card f.range := by
        exact Nat.mul_le_mul_left _ (nonzero_linear_map_range_card_ge_q f hf)
    _ = Fintype.card V := card_kernel_mul_card_range f

-- For a nonzero linear map, the kernel has strictly smaller dimension than the domain.
omit [FiniteDimensional (ZMod q) W] [Fintype V] [Fintype W] in
theorem nonzero_linear_map_kernel_codim_pos
    (f : V →ₗ[ZMod q] W) (hf : f ≠ 0) :
    Module.finrank (ZMod q) f.ker < Module.finrank (ZMod q) V := by
  have h_rank_nullity : Module.finrank (ZMod q) V =
      Module.finrank (ZMod q) f.ker + Module.finrank (ZMod q) f.range := by
    rw [← LinearMap.finrank_range_add_finrank_ker f, add_comm]
  contrapose! hf
  simp_all +decide [Submodule.eq_bot_iff]
  exact LinearMap.ext hf

-- Specialization to linear functionals: the kernel of a nonzero linear functional
-- `φ : V →ₗ[ZMod q] ZMod q` satisfies `|ker φ| * q ≤ |V|`.
theorem nonzero_linear_functional_kernel_density
    {V : Type*} [AddCommGroup V] [Module (ZMod q) V]
    [FiniteDimensional (ZMod q) V] [Fintype V]
    (φ : V →ₗ[ZMod q] ZMod q) (hφ : φ ≠ 0) :
    Fintype.card φ.ker * q ≤ Fintype.card V := by
  exact nonzero_linear_map_kernel_density φ hφ

end