import Mathlib
import Shared.PoleOrderObstruction
import Shared.PoleOrderObstructionDeep
import Computation.PoleOrderTorsor
import Computation.PoleOrderTorsorOrbits
import Computation.PoleOrderTorsorBinomial

/-!
# The associated graded of the corrected-product filtration

Cycle 2 built the descending filtration `PoleOrderTorsor.deepSubgroup` of the group `Norm` of
normalized `q`-series under the corrected product, together with the graded invariants
`PoleOrderTorsor.gradedHom k : deepSubgroup k →* Multiplicative ℂ`.  This file identifies the
associated graded object completely and draws the structural consequence for the original
research question ("which invariant first distinguishes two orbits?").

Main results.

* `PoleOrderTorsor.ker_gradedHom` — the kernel of the level-`k` invariant on the `k`-th stage is
  exactly the next stage of the filtration.
* `PoleOrderTorsor.gradedQuotEquiv` — hence every graded piece is *the same* group,
  `deepSubgroup k ⧸ deepSubgroup (k+1) ≃* (ℂ, +)`; the tower is level-independent
  (`PoleOrderTorsor.gradedPieceEquivGradedPiece`).  Consequently no intrinsic invariant of a
  single graded piece can distinguish levels: the distinguishing data is the position in the
  tower, which is what `PoleOrderTorsor.first_invariant` extracts.
* `PoleOrderTorsor.deepSubgroup_succ_lt` — the filtration is *strictly* descending at every
  positive level, so the tower has infinite length.
* `PoleOrderTorsor.iInf_deepSubgroup` — it is separated: the intersection of all stages is
  trivial.
* `PoleOrderTorsor.coeffSystem_bijective` — the full invariant system
  `f ↦ (coeffAt 1 f, coeffAt 2 f, …)` is a *bijection* `Norm ≃ (ℕ → ℂ)`.  So the invariants are
  complete and completely free: any prescribed sequence of invariants is realized by exactly one
  normalized series.
-/

namespace PoleOrderTorsor

open PoleOrderObstruction PowerSeries

namespace Norm

/-! ## The kernel of a graded invariant is the next stage -/

/-- **The graded invariant cuts out the next stage.**  On the `k`-th stage of the filtration the
kernel of the level-`k` coefficient homomorphism is precisely the `(k+1)`-st stage. -/
theorem ker_gradedHom (k : ℕ) (hk : 0 < k) :
    (gradedHom k hk).ker = (deepSubgroup (k + 1)).subgroupOf (deepSubgroup k) := by
  ext f
  rw [MonoidHom.mem_ker, Subgroup.mem_subgroupOf, gradedHom_apply]
  constructor
  · intro h
    have hz : coeffAt k (f : Norm) = 0 := by
      have := congrArg Multiplicative.toAdd h
      simpa using this
    exact (mem_deepSubgroup_succ_iff k _).2 ⟨f.2, fun _ => hz⟩
  · intro h
    have hz := ((mem_deepSubgroup_succ_iff k _).1 h).2 hk
    rw [hz]
    rfl

/-- **Every graded piece is a copy of `(ℂ, +)`.**  The quotient of the `k`-th stage of the
filtration by the `(k+1)`-st is multiplicatively isomorphic to the additive group of complex
numbers. -/
noncomputable def gradedQuotEquiv (k : ℕ) (hk : 0 < k) :
    (deepSubgroup k ⧸ (deepSubgroup (k + 1)).subgroupOf (deepSubgroup k)) ≃* Multiplicative ℂ :=
  (QuotientGroup.quotientMulEquivOfEq (ker_gradedHom k hk).symm).trans
    (QuotientGroup.quotientKerEquivOfSurjective _ (gradedHom_surjective k hk))

/-- **The tower is level-independent.**  Any two graded pieces are isomorphic, so no invariant
computed inside a single graded piece can tell the levels apart. -/
noncomputable def gradedPieceEquivGradedPiece (k l : ℕ) (hk : 0 < k) (hl : 0 < l) :
    (deepSubgroup k ⧸ (deepSubgroup (k + 1)).subgroupOf (deepSubgroup k)) ≃*
      (deepSubgroup l ⧸ (deepSubgroup (l + 1)).subgroupOf (deepSubgroup l)) :=
  (gradedQuotEquiv k hk).trans (gradedQuotEquiv l hl).symm

/-! ## The filtration is strictly descending and separated -/

theorem deepSubgroup_mono {k l : ℕ} (h : k ≤ l) : deepSubgroup l ≤ deepSubgroup k :=
  fun _ hf i hi0 hik => hf i hi0 (lt_of_lt_of_le hik h)

/-- **Strictness.**  At every positive level the filtration genuinely drops: there is a
normalized series which is `k`-deep but not `(k+1)`-deep. -/
theorem deepSubgroup_succ_lt (k : ℕ) (hk : 0 < k) : deepSubgroup (k + 1) < deepSubgroup k := by
  refine lt_of_le_of_ne (deepSubgroup_mono (Nat.le_succ k)) ?_
  intro hEq
  obtain ⟨f, hf⟩ := gradedHom_surjective k hk (Multiplicative.ofAdd (1 : ℂ))
  have hone : coeffAt k (f : Norm) = 1 := by
    have := congrArg Multiplicative.toAdd hf
    simpa using this
  have hmem : (f : Norm) ∈ deepSubgroup (k + 1) := by rw [hEq]; exact f.2
  have := ((mem_deepSubgroup_succ_iff k _).1 hmem).2 hk
  rw [hone] at this
  exact one_ne_zero this

/-- **Separatedness.**  A normalized series lying in every stage of the filtration is the base
point `q⁻¹`. -/
theorem iInf_deepSubgroup : (⨅ k : ℕ, deepSubgroup k) = ⊥ := by
  refine le_antisymm (fun f hf => ?_) bot_le
  rw [Subgroup.mem_bot]
  refine eq_one_of_forall_coeffAt_eq_zero (fun k hk => ?_)
  have := Subgroup.mem_iInf.1 hf (k + 1)
  exact this k hk (Nat.lt_succ_self k)

/-! ## The invariant system is complete and free -/

/-- The complete system of invariants of a normalized series: the sequence of all its
coefficients at positive levels. -/
noncomputable def coeffSystem (f : Norm) : ℕ → ℂ := fun k => coeffAt (k + 1) f

/-- **The invariants are complete and completely free.**  The map sending a normalized series to
its sequence of invariants is a bijection onto all of `ℕ → ℂ`: two normalized series with the
same invariants are equal, and every prescribed sequence of invariants occurs. -/
theorem coeffSystem_bijective : Function.Bijective coeffSystem := by
  constructor
  · intro f g h
    have hcoeff : ∀ i : ℕ,
        PowerSeries.coeff i ((toOneUnit f : PowerSeries ℂ))
          = PowerSeries.coeff i ((toOneUnit g : PowerSeries ℂ)) := by
      intro i
      cases i with
      | zero =>
        rw [PowerSeries.coeff_zero_eq_constantCoeff_apply,
          PowerSeries.coeff_zero_eq_constantCoeff_apply,
          (toOneUnit f).constantCoeff_val, (toOneUnit g).constantCoeff_val]
      | succ n =>
        have := congrFun h n
        simpa only [coeffSystem, coeffAt_toOneUnit] using this
    have huv : toOneUnit f = toOneUnit g := OneUnit.ext (PowerSeries.ext hcoeff)
    rw [← ofOneUnit_toOneUnit f, ← ofOneUnit_toOneUnit g, huv]
  · intro c
    set u : PowerSeries ℂ := PowerSeries.mk (fun i => if i = 0 then 1 else c (i - 1)) with hu
    have hcc : PowerSeries.constantCoeff u = 1 := by
      rw [← PowerSeries.coeff_zero_eq_constantCoeff_apply, hu, PowerSeries.coeff_mk]
      norm_num
    refine ⟨ofOneUnit ⟨u, hcc⟩, ?_⟩
    funext k
    have hval : ((toOneUnit (ofOneUnit ⟨u, hcc⟩) : OneUnit) : PowerSeries ℂ) = u := by
      rw [toOneUnit_ofOneUnit]
    rw [coeffSystem, coeffAt_toOneUnit, hval, hu, PowerSeries.coeff_mk, if_neg (by omega)]
    norm_num

/-- Restating the previous theorem: the invariant system is a bijection `Norm ≃ (ℕ → ℂ)`.  It is
*not* a group isomorphism — the corrected product mixes the coordinates nonlinearly, which is
exactly why the individual invariants are only homomorphisms after restricting to a stage of the
filtration (`PoleOrderTorsor.gradedHom`). -/
noncomputable def coeffSystemEquiv : Norm ≃ (ℕ → ℂ) :=
  Equiv.ofBijective coeffSystem coeffSystem_bijective

/-- The invariant system is *not* additive on the nose: for `f = g = q⁻¹ + q` the level-2
invariant of the product is `1`, while both factors have level-2 invariant `0`.  This records
that the filtration is genuinely needed to turn the coefficients into homomorphisms. -/
theorem coeffSystem_not_additive :
    ∃ f g : Norm, coeffSystem (f * g) 1 ≠ coeffSystem f 1 + coeffSystem g 1 := by
  obtain ⟨f, hf⟩ := gradedHom_surjective 1 one_pos (Multiplicative.ofAdd (1 : ℂ))
  have hone : coeffAt 1 (f : Norm) = 1 := by
    have := congrArg Multiplicative.toAdd hf
    simpa using this
  refine ⟨(f : Norm), (f : Norm), ?_⟩
  have hsq : coeffAt 2 ((f : Norm) * (f : Norm)) = 2 * coeffAt 2 (f : Norm) + 1 := by
    have h := coeff_mul_split_two (a := (toOneUnit (f : Norm) : PowerSeries ℂ))
      (b := (toOneUnit (f : Norm) : PowerSeries ℂ)) one_pos
      (toOneUnit (f : Norm)).constantCoeff_val (toOneUnit (f : Norm)).constantCoeff_val f.2 f.2
    rw [show 2 * 1 = 2 from rfl] at h
    rw [coeffAt_toOneUnit, toOneUnit_mul, OneUnit.val_mul, h]
    rw [← coeffAt_toOneUnit, ← coeffAt_toOneUnit, hone]
    ring
  simp only [coeffSystem, show (1 : ℕ) + 1 = 2 from rfl]
  rw [hsq]
  intro hcon
  have : (1 : ℂ) = 0 := by linear_combination hcon
  exact one_ne_zero this

end Norm

end PoleOrderTorsor