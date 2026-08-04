import Algebra.DerivedFunctors.TorZMod
import Algebra.DerivedFunctors.Tor

/-!
# Flatness of abelian groups is detected by `Tor₁` against cyclic groups

This file completes the criterion whose "only if" half was proved in
`Algebra.DerivedFunctors.Tor` (`Catalog.DerivedFunctors.isZero_Tor_succ_of_flat`) and whose
computation of the correction term was carried out in `Algebra.DerivedFunctors.TorZMod`
(`Catalog.DerivedFunctors.torOneZModIso : Tor₁(G, ℤ/k) ≅ G[k]`).

Main results:

* `Catalog.DerivedFunctors.flat_iff_torsionFree`: a `ℤ`-module is flat if and only if it is
  torsion-free;
* `Catalog.DerivedFunctors.flat_iff_isZero_kernel_mulBy`: `G` is flat iff multiplication by every
  nonzero `k` is injective on `G`, stated categorically as the vanishing of `ker(k·)`;
* `Catalog.DerivedFunctors.flat_iff_isZero_torOne_zmod`: **`G` is flat iff `Tor₁(G, ℤ/k) = 0` for
  every `k ≠ 0`**;
* `Catalog.DerivedFunctors.flat_iff_isZero_tor_succ`: consequently `G` is flat iff *all* higher
  `Tor`-groups `Torₙ₊₁(G, −)` vanish.
-/

open CategoryTheory Limits

namespace Catalog.DerivedFunctors

/-- **Flat = torsion-free over `ℤ`.** -/
theorem flat_iff_torsionFree (G : Type) [AddCommGroup G] [inst : Module ℤ G] :
    Module.Flat ℤ G ↔ ∀ k : ℕ, k ≠ 0 → ∀ g : G, (k : ℤ) • g = 0 → g = 0 := by
  have hsub : inst = AddCommGroup.toIntModule G := Subsingleton.elim _ _
  subst hsub
  rw [Module.Flat.flat_iff_torsion_eq_bot_of_isBezout,
    ← Submodule.isTorsionFree_iff_torsion_eq_bot]
  constructor
  · intro h k hk g hg
    have hreg : IsSMulRegular G (k : ℤ) :=
      h.isSMulRegular (isRegular_iff_ne_zero.2 (Int.natCast_ne_zero.2 hk))
    refine hreg ?_
    show (k : ℤ) • g = (k : ℤ) • (0 : G)
    rw [hg, smul_zero]
  · intro h
    refine ⟨fun r hr => ?_⟩
    have hr0 : r ≠ 0 := isRegular_iff_ne_zero.1 hr
    intro a b hab
    have hab' : r • a = r • b := hab
    have h1 : r • (a - b) = (0 : G) := by rw [smul_sub, hab', sub_self]
    have habs : ((r.natAbs : ℕ) : ℤ) • (a - b) = (0 : G) := by
      rcases Int.natAbs_eq r with he | he
      · rw [← he, h1]
      · rw [show ((r.natAbs : ℤ)) = -r by omega, neg_smul, h1, neg_zero]
    exact sub_eq_zero.1 (h r.natAbs (Int.natAbs_ne_zero.2 hr0) _ habs)

/-- The kernel of multiplication by `k` on `G` vanishes exactly when `k` acts injectively. -/
theorem isZero_kernel_mulBy_iff (k : ℕ) (G : ModuleCat.{0} ℤ) :
    IsZero (kernel (mulBy k G)) ↔ ∀ g : G, (k : ℤ) • g = 0 → g = 0 := by
  rw [← Preadditive.mono_iff_isZero_kernel, ModuleCat.mono_iff_injective]
  constructor
  · intro h g hg
    refine h ?_
    show (ModuleCat.Hom.hom (mulBy k G)) g = (ModuleCat.Hom.hom (mulBy k G)) 0
    rw [map_zero]
    exact hg
  · intro h a b hab
    have key : (ModuleCat.Hom.hom (mulBy k G)) (a - b) = 0 := by
      rw [map_sub, hab, sub_self]
    exact sub_eq_zero.1 (h (a - b) key)

/-- `G` is flat iff multiplication by every nonzero natural number is injective on `G`. -/
theorem flat_iff_isZero_kernel_mulBy (G : ModuleCat.{0} ℤ) :
    Module.Flat ℤ G ↔ ∀ k : ℕ, k ≠ 0 → IsZero (kernel (mulBy k G)) := by
  rw [flat_iff_torsionFree G]
  exact ⟨fun h k hk => (isZero_kernel_mulBy_iff k G).2 (h k hk),
    fun h k hk => (isZero_kernel_mulBy_iff k G).1 (h k hk)⟩

/-- **Flatness of an abelian group is detected by `Tor₁` against the cyclic groups.** -/
theorem flat_iff_isZero_torOne_zmod (G : ModuleCat.{0} ℤ) :
    Module.Flat ℤ G ↔ ∀ k : ℕ, k ≠ 0 →
      IsZero (((Tor (ModuleCat.{0} ℤ) 1).obj G).obj (ModuleCat.of ℤ (ZMod k))) := by
  rw [flat_iff_isZero_kernel_mulBy G]
  refine ⟨fun h k hk => IsZero.of_iso (h k hk) (torOneZModIso k G hk), fun h k hk => ?_⟩
  exact IsZero.of_iso (h k hk) (torOneZModIso k G hk).symm

/-- **Flatness is equivalent to the vanishing of all higher `Tor`-groups.** -/
theorem flat_iff_isZero_tor_succ (G : ModuleCat.{0} ℤ) :
    Module.Flat ℤ G ↔ ∀ (n : ℕ) (M : ModuleCat.{0} ℤ),
      IsZero (((Tor (ModuleCat.{0} ℤ) (n + 1)).obj G).obj M) := by
  refine ⟨fun hf n M => letI := hf; isZero_Tor_succ_of_flat G M n, fun h => ?_⟩
  exact (flat_iff_isZero_torOne_zmod G).2 fun k _ => h 0 _

/-- A group with `k`-torsion is not flat; e.g. `ℤ/k` is not a flat `ℤ`-module for `k ≥ 2`. -/
theorem not_flat_zmod (k : ℕ) (hk : 2 ≤ k) : ¬ Module.Flat ℤ (ZMod k) := by
  haveI : Fact (1 < k) := ⟨by omega⟩
  intro hflat
  have h := (flat_iff_torsionFree (ZMod k)).1 hflat k (by omega) 1 (by simp [zsmul_eq_mul])
  exact one_ne_zero h

end Catalog.DerivedFunctors