import Shared.EquivariantspectrumBasic.EquivariantSpectrum_Basic

/-!
# Equivariant spectrum: the invariant-subspace filtration

This module previously contained only a stray relative path pointing at a
non-existent file `Shared/EquivariantSpectrum/Filter.lean`.  It is reconstructed
here as the lattice/filtration theory attached to the basic equivariant spectrum
module `Shared.EquivariantspectrumBasic.EquivariantSpectrum_Basic`.

Main results:

* `EquivariantSpectrum.Invariant` and the closure of invariant submodules under
  `⊥`, `⊤`, `⊓` and `⊔` (`invariant_inf`, `invariant_sup`, …): the invariant
  subspaces of a symmetry form a sublattice of the submodule lattice;
* `EquivariantSpectrum.kerFiltration` — the ascending filtration by kernels of the
  powers of an operator, shown to be monotone (`kerFiltration_mono`) and
  pointwise invariant under every commuting symmetry (`kerFiltration_invariant`);
* `EquivariantSpectrum.kerFiltration_stabilizes` — once two consecutive steps of
  the filtration agree, the filtration is constant from then on.
-/

namespace EquivariantSpectrum

variable {R V : Type*} [CommRing R] [AddCommGroup V] [Module R V]

/-- A submodule is `T`-invariant if `T` maps it into itself. -/
def Invariant (T : V →ₗ[R] V) (p : Submodule R V) : Prop := ∀ v ∈ p, T v ∈ p

theorem invariant_bot (T : V →ₗ[R] V) : Invariant T (⊥ : Submodule R V) := by
  intro v hv
  rw [Submodule.mem_bot] at hv
  simp [hv]

theorem invariant_top (T : V →ₗ[R] V) : Invariant T (⊤ : Submodule R V) := fun _ _ => trivial

theorem invariant_inf {T : V →ₗ[R] V} {p q : Submodule R V}
    (hp : Invariant T p) (hq : Invariant T q) : Invariant T (p ⊓ q) := by
  rintro v ⟨hvp, hvq⟩
  exact ⟨hp v hvp, hq v hvq⟩

theorem invariant_sup {T : V →ₗ[R] V} {p q : Submodule R V}
    (hp : Invariant T p) (hq : Invariant T q) : Invariant T (p ⊔ q) := by
  intro v hv
  rw [Submodule.mem_sup] at hv ⊢
  obtain ⟨x, hx, y, hy, rfl⟩ := hv
  exact ⟨T x, hp x hx, T y, hq y hy, by rw [map_add]⟩

theorem invariant_iSup {ι : Type*} {T : V →ₗ[R] V} {p : ι → Submodule R V}
    (hp : ∀ i, Invariant T (p i)) : Invariant T (⨆ i, p i) := by
  intro v hv
  refine Submodule.iSup_induction p (motive := fun w => T w ∈ ⨆ i, p i) hv ?_ ?_ ?_
  · intro i x hx
    exact Submodule.mem_iSup_of_mem i (hp i x hx)
  · simp
  · intro x y hx hy
    rw [map_add]
    exact Submodule.add_mem _ hx hy

theorem invariant_iInf {ι : Type*} {T : V →ₗ[R] V} {p : ι → Submodule R V}
    (hp : ∀ i, Invariant T (p i)) : Invariant T (⨅ i, p i) := by
  intro v hv
  rw [Submodule.mem_iInf] at hv ⊢
  exact fun i => hp i v (hv i)

/-! ## The kernel filtration -/

/-- The `n`-th step of the kernel filtration of `A`: the generalized kernel
`ker (Aⁿ)`. -/
def kerFiltration (A : V →ₗ[R] V) (n : ℕ) : Submodule R V := LinearMap.ker (A ^ n)

@[simp] lemma kerFiltration_zero (A : V →ₗ[R] V) : kerFiltration A 0 = ⊥ := by
  ext v
  simp [kerFiltration]

lemma mem_kerFiltration {A : V →ₗ[R] V} {n : ℕ} {v : V} :
    v ∈ kerFiltration A n ↔ (A ^ n) v = 0 := Iff.rfl

/-- The kernel filtration is ascending. -/
theorem kerFiltration_mono (A : V →ₗ[R] V) : Monotone (kerFiltration A) :=
  fun _ _ hmn => ker_pow_mono A _ _ hmn

/-- Every step of the kernel filtration is invariant under every symmetry
commuting with `A`. -/
theorem kerFiltration_invariant {A T : V →ₗ[R] V} (h : Commutes A T) (n : ℕ) :
    Invariant T (kerFiltration A n) := ker_pow_invariant h n

/-- The whole filtration is invariant, hence so is its union (the generalized
`0`-eigenspace). -/
theorem kerFiltration_iSup_invariant {A T : V →ₗ[R] V} (h : Commutes A T) :
    Invariant T (⨆ n, kerFiltration A n) :=
  invariant_iSup fun n => kerFiltration_invariant h n

/-- **Stabilization.**  If two consecutive steps of the kernel filtration agree, the
filtration is constant from that point on. -/
theorem kerFiltration_stabilizes (A : V →ₗ[R] V) (n : ℕ)
    (h : kerFiltration A (n + 1) = kerFiltration A n) :
    ∀ m, n ≤ m → kerFiltration A m = kerFiltration A n := by
  have step : ∀ k, kerFiltration A (n + k) = kerFiltration A n := by
    intro k
    induction k with
    | zero => rfl
    | succ j ih =>
        refine le_antisymm ?_ (kerFiltration_mono A (by omega))
        intro v hv
        -- `A v` lies in `ker (A ^ (n + j))`, hence in `ker (A ^ n)` by induction
        have hAv : A v ∈ kerFiltration A (n + j) := by
          rw [mem_kerFiltration] at hv ⊢
          rw [show n + (j + 1) = (n + j) + 1 by omega, pow_succ] at hv
          rwa [Module.End.mul_apply] at hv
        rw [ih] at hAv
        have : v ∈ kerFiltration A (n + 1) := by
          rw [mem_kerFiltration] at hAv ⊢
          rw [pow_succ, Module.End.mul_apply]
          exact hAv
        rwa [h] at this
  intro m hm
  obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hm
  exact step k

end EquivariantSpectrum