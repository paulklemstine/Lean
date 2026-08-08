import Mathlib

/-!
# Equivariant spectrum: basics

This module previously contained only a stray relative path pointing at a
non-existent file `Shared/EquivariantSpectrum/Basic.lean`.  It is reconstructed
here as a self-contained development of the elementary theory of the spectrum of
an operator that is *equivariant* for a group of symmetries.

Setting: `V` a module over a commutative ring `R`, `A : V →ₗ[R] V` an operator,
and `T : V →ₗ[R] V` a symmetry commuting with `A`.  The main results are:

* `EquivariantSpectrum.eigenvector_map` — symmetries permute eigenvectors of a
  given eigenvalue;
* `EquivariantSpectrum.eigenspace_invariant` — eigenspaces are invariant subspaces;
* `EquivariantSpectrum.ker_pow_invariant` — generalized eigenspaces (kernels of
  powers) are invariant;
* `EquivariantSpectrum.spectrum_conj` — the spectrum is a conjugation invariant, so
  it is a genuine invariant of the equivariant isomorphism class.
-/

namespace EquivariantSpectrum

variable {R V : Type*} [CommRing R] [AddCommGroup V] [Module R V]

/-- `T` is `A`-equivariant when it commutes with `A`. -/
def Commutes (A T : V →ₗ[R] V) : Prop := A ∘ₗ T = T ∘ₗ A

lemma Commutes.apply {A T : V →ₗ[R] V} (h : Commutes A T) (v : V) : A (T v) = T (A v) :=
  congrArg (fun L : V →ₗ[R] V => L v) h

/-- **Symmetries permute eigenvectors.**  If `T` commutes with `A` and `v` is an
eigenvector of `A` with eigenvalue `μ`, then so is `T v`. -/
theorem eigenvector_map {A T : V →ₗ[R] V} (h : Commutes A T) {μ : R} {v : V}
    (hv : A v = μ • v) : A (T v) = μ • T v := by
  rw [h.apply v, hv, map_smul]

/-- **Eigenspaces are invariant.** -/
theorem eigenspace_invariant {A T : V →ₗ[R] V} (h : Commutes A T) (μ : R) :
    ∀ v ∈ LinearMap.ker (A - μ • LinearMap.id), T v ∈ LinearMap.ker (A - μ • LinearMap.id) := by
  intro v hv
  simp only [LinearMap.mem_ker, LinearMap.sub_apply, LinearMap.smul_apply,
    LinearMap.id_apply, sub_eq_zero] at hv ⊢
  exact eigenvector_map h hv

/-- If `T` commutes with `A` then it commutes with every power of `A`. -/
theorem commutes_pow {A T : V →ₗ[R] V} (h : Commutes A T) (n : ℕ) :
    Commutes (A ^ n) T := by
  induction n with
  | zero => ext v; simp
  | succ k ih =>
      ext v
      simp only [pow_succ, LinearMap.comp_apply, Module.End.mul_apply]
      rw [h.apply v]
      exact ih.apply (A v)

/-- **Generalized eigenspaces are invariant.**  Kernels of powers of `A` are stable
under any symmetry commuting with `A`. -/
theorem ker_pow_invariant {A T : V →ₗ[R] V} (h : Commutes A T) (n : ℕ) :
    ∀ v ∈ LinearMap.ker (A ^ n), T v ∈ LinearMap.ker (A ^ n) := by
  intro v hv
  simp only [LinearMap.mem_ker] at hv ⊢
  rw [(commutes_pow h n).apply v, hv, map_zero]

/-- The kernels of the powers of `A` form an ascending filtration. -/
theorem ker_pow_mono (A : V →ₗ[R] V) (m n : ℕ) (hmn : m ≤ n) :
    LinearMap.ker (A ^ m) ≤ LinearMap.ker (A ^ n) := by
  intro v hv
  obtain ⟨d, rfl⟩ := Nat.exists_eq_add_of_le hmn
  simp only [LinearMap.mem_ker] at hv ⊢
  rw [Nat.add_comm, pow_add, Module.End.mul_apply, hv, map_zero]

/-! ## Conjugation invariance of the spectrum

A group `G` of symmetries acting on an algebra `A` by conjugation, through a
representation `ρ : G →* Aˣ`, leaves the spectrum of every element unchanged.  The
spectrum is therefore a genuine invariant of the `G`-orbit of an operator, and an
operator is *equivariant* precisely when it is a fixed point of this action.
-/

variable {G B : Type*} [Group G] [Ring B] [Algebra R B]

/-- The conjugation action of `G` on `B` through a representation `ρ`. -/
def conjAction (rho : G →* Bˣ) (g : G) (b : B) : B := (rho g : B) * b * (↑(rho g)⁻¹ : B)

@[simp] lemma conjAction_one (rho : G →* Bˣ) (b : B) : conjAction rho 1 b = b := by
  simp [conjAction]

lemma conjAction_mul (rho : G →* Bˣ) (g h : G) (b : B) :
    conjAction rho (g * h) b = conjAction rho g (conjAction rho h b) := by
  simp only [conjAction, map_mul, Units.val_mul, mul_inv_rev]
  group

/-- **The spectrum is a symmetry invariant.** -/
theorem spectrum_conjAction (rho : G →* Bˣ) (g : G) (b : B) :
    spectrum R (conjAction rho g b) = spectrum R b :=
  spectrum.units_conjugate

/-- An element is a fixed point of the conjugation action exactly when it commutes
with the image of the representation: this is the algebraic form of equivariance. -/
theorem conjAction_eq_self_iff (rho : G →* Bˣ) (g : G) (b : B) :
    conjAction rho g b = b ↔ (rho g : B) * b = b * (rho g : B) := by
  constructor
  · intro h
    conv_rhs => rw [← h]
    simp [conjAction, mul_assoc]
  · intro h
    simp only [conjAction, h, mul_assoc]
    simp

/-- Consequently all operators in a single orbit share their spectrum, so the
spectrum descends to the quotient by the symmetry group. -/
theorem spectrum_eq_of_mem_orbit (rho : G →* Bˣ) (b c : B)
    (hbc : ∃ g : G, c = conjAction rho g b) : spectrum R c = spectrum R b := by
  obtain ⟨g, rfl⟩ := hbc
  exact spectrum_conjAction rho g b

end EquivariantSpectrum