import Mathlib
import Physics.PermutationReadoutCore
import Physics.PermutationReadoutEvenModulus
import Physics.PermutationReadoutAffine
import Physics.PermutationReadoutSign

/-!
# The power readout at a prime: `x ↦ x^k` is the multiplicative readout one level down

The PERMORD analysis so far concerns the *affine* family `x ↦ a·x + b`.  The
next natural enlargement of the attack surface is the family of **power maps**
`x ↦ x^k`, which are permutations of `ZMod p` exactly when `k` is coprime to
`p − 1`.  This file computes their cycle structure exactly:

  `#cycles(x ↦ x^k on ZMod p) = #cycles(x ↦ k·x on ZMod (p−1)) + 1`.

So the power readout at a prime modulus is *literally* the multiplicative
readout of this project, evaluated one level down at the modulus `p − 1`, plus
the fixed point `0`.  Combined with the all-moduli sign law
(`permutation_sign_law`, an even modulus `p − 1`) this yields a completely
explicit, factorisation-free sign law for power permutations
(`power_readout_sign_law`): `x ↦ x^k` is an even permutation of `ZMod p`
exactly when `4 ∣ p − 1 → k ≡ 1 (mod 4)`.

The technical content is a transport theory for the orbit count `numOrbits` of
`Physics/PermutationReadoutSign.lean`: it is invariant under conjugation by an
arbitrary bijection (`numOrbits_permCongr`), and adjoining a fixed point adds
exactly one orbit (`numOrbits_optionCongr`).  The discrete logarithm turns
`ZMod p` into `Option (ZMod (p−1))` and the power map into the multiplication
map, whence the count.

## Main results

* `Physics.PermReadout.numOrbits_permCongr`
* `Physics.PermReadout.numOrbits_optionCongr`
* `Physics.PermReadout.cycleCountOf_pow_prime`
* `Physics.PermReadout.power_readout_sign_law`
-/

namespace Physics.PermReadout

open Finset

section Transport

open scoped Classical

variable {α β : Type*} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]

omit [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β] in
/-- `Equiv.permCongr` as a multiplicative equivalence. -/
def permCongrMulEquiv (e : α ≃ β) : Equiv.Perm α ≃* Equiv.Perm β where
  toEquiv := Equiv.permCongr e
  map_mul' := Equiv.permCongr_mul e

omit [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β] in
theorem permCongr_zpow (e : α ≃ β) (σ : Equiv.Perm α) (i : ℤ) :
    (e.permCongr σ) ^ i = e.permCongr (σ ^ i) :=
  (map_zpow (permCongrMulEquiv e) σ i).symm

omit [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β] in
theorem sameCycle_permCongr {e : α ≃ β} {σ : Equiv.Perm α} {x y : α} :
    (e.permCongr σ).SameCycle (e x) (e y) ↔ σ.SameCycle x y := by
  constructor
  · rintro ⟨i, hi⟩
    rw [permCongr_zpow, Equiv.permCongr_apply, Equiv.symm_apply_apply] at hi
    exact ⟨i, e.injective hi⟩
  · rintro ⟨i, rfl⟩
    exact ⟨i, by rw [permCongr_zpow, Equiv.permCongr_apply, Equiv.symm_apply_apply]⟩

theorem permOrbit_permCongr (e : α ≃ β) (σ : Equiv.Perm α) (x : α) :
    permOrbit (e.permCongr σ) (e x) = (permOrbit σ x).image e := by
  ext z
  constructor
  · intro hz
    refine Finset.mem_image.mpr ⟨e.symm z, mem_permOrbit.mpr ?_, e.apply_symm_apply z⟩
    refine (sameCycle_permCongr (e := e) (σ := σ) (x := x) (y := e.symm z)).mp ?_
    rw [Equiv.apply_symm_apply]
    exact mem_permOrbit.mp hz
  · intro hz
    obtain ⟨y, hy, rfl⟩ := Finset.mem_image.mp hz
    exact mem_permOrbit.mpr (sameCycle_permCongr.mpr (mem_permOrbit.mp hy))

/-- **Transport of the orbit count.**  Conjugating a permutation by an arbitrary
bijection — even between different types — does not change the number of
orbits. -/
theorem numOrbits_permCongr (e : α ≃ β) (σ : Equiv.Perm α) :
    numOrbits (e.permCongr σ) = numOrbits σ := by
  classical
  have himg : (Finset.univ.image (permOrbit (e.permCongr σ)))
      = (Finset.univ.image (permOrbit σ)).image (fun s => s.image e) := by
    ext o
    simp only [Finset.mem_image, Finset.mem_univ, true_and]
    constructor
    · rintro ⟨z, rfl⟩
      exact ⟨permOrbit σ (e.symm z), ⟨e.symm z, rfl⟩, by
        rw [← permOrbit_permCongr, Equiv.apply_symm_apply]⟩
    · rintro ⟨s, ⟨x, rfl⟩, rfl⟩
      exact ⟨e x, permOrbit_permCongr e σ x⟩
  rw [numOrbits, himg, Finset.card_image_of_injective _ (Finset.image_injective e.injective),
    numOrbits]

end Transport

section OptionOrbits

open scoped Classical

variable {β : Type*} [Fintype β] [DecidableEq β]

/-- `Equiv.optionCongr` as a monoid homomorphism on permutations. -/
def optionCongrHom (β : Type*) [DecidableEq β] : Equiv.Perm β →* Equiv.Perm (Option β) where
  toFun := Equiv.optionCongr
  map_one' := Equiv.optionCongr_one
  map_mul' f g := by
    ext x
    cases x <;> rfl

omit [Fintype β] in
theorem optionCongr_zpow (g : Equiv.Perm β) (i : ℤ) :
    (Equiv.optionCongr g) ^ i = Equiv.optionCongr (g ^ i) :=
  (map_zpow (optionCongrHom β) g i).symm

omit [Fintype β] in
theorem optionCongr_zpow_some (g : Equiv.Perm β) (i : ℤ) (x : β) :
    ((Equiv.optionCongr g) ^ i) (some x) = some ((g ^ i) x) := by
  rw [optionCongr_zpow]
  rfl

omit [Fintype β] in
theorem optionCongr_zpow_none (g : Equiv.Perm β) (i : ℤ) :
    ((Equiv.optionCongr g) ^ i) none = none := by
  rw [optionCongr_zpow]
  rfl

theorem permOrbit_optionCongr_none (g : Equiv.Perm β) :
    permOrbit (Equiv.optionCongr g) none = {none} := by
  ext z
  constructor
  · intro hz
    obtain ⟨i, hi⟩ := mem_permOrbit.mp hz
    rw [optionCongr_zpow_none] at hi
    exact Finset.mem_singleton.mpr hi.symm
  · intro hz
    rw [Finset.mem_singleton.mp hz]
    exact mem_permOrbit.mpr ⟨0, rfl⟩

theorem permOrbit_optionCongr_some (g : Equiv.Perm β) (x : β) :
    permOrbit (Equiv.optionCongr g) (some x) = (permOrbit g x).image some := by
  ext z
  constructor
  · intro hz
    obtain ⟨i, hi⟩ := mem_permOrbit.mp hz
    refine Finset.mem_image.mpr ⟨(g ^ i) x, mem_permOrbit.mpr ⟨i, rfl⟩, ?_⟩
    rw [← hi, optionCongr_zpow_some]
  · intro hz
    obtain ⟨y, hy, rfl⟩ := Finset.mem_image.mp hz
    obtain ⟨i, rfl⟩ := mem_permOrbit.mp hy
    exact mem_permOrbit.mpr ⟨i, by rw [optionCongr_zpow_some]⟩

/-- **Adjoining a fixed point adds exactly one orbit.** -/
theorem numOrbits_optionCongr (g : Equiv.Perm β) :
    numOrbits (Equiv.optionCongr g) = numOrbits g + 1 := by
  classical
  set S : Finset (Finset (Option β)) := (Finset.univ.image (permOrbit g)).image
    (fun s => s.image (some : β → Option β)) with hS
  have hsplit : Finset.univ.image (permOrbit (Equiv.optionCongr g)) = insert {none} S := by
    ext o
    simp only [Finset.mem_image, Finset.mem_univ, true_and, Finset.mem_insert, hS]
    constructor
    · rintro ⟨z, rfl⟩
      cases z with
      | none => exact Or.inl (permOrbit_optionCongr_none g)
      | some x =>
          exact Or.inr ⟨permOrbit g x, ⟨x, rfl⟩, (permOrbit_optionCongr_some g x).symm⟩
    · rintro (rfl | ⟨s, ⟨x, rfl⟩, rfl⟩)
      · exact ⟨none, permOrbit_optionCongr_none g⟩
      · exact ⟨some x, permOrbit_optionCongr_some g x⟩
  have hnot : ({none} : Finset (Option β)) ∉ S := by
    simp only [hS, Finset.mem_image, Finset.mem_univ, true_and, not_exists]
    rintro s ⟨⟨x, rfl⟩, hs⟩
    have hmem : (none : Option β) ∈ (permOrbit g x).image (some : β → Option β) := by
      rw [hs]; exact Finset.mem_singleton_self _
    simp at hmem
  have hScard : S.card = numOrbits g := by
    rw [hS, Finset.card_image_of_injective _ (Finset.image_injective (Option.some_injective β)),
      numOrbits]
  rw [numOrbits, hsplit, Finset.card_insert_of_notMem hnot, hScard]

end OptionOrbits

section PrimePowerMap

variable {p k : ℕ}

/-- The discrete logarithm of the cyclic group `(ZMod p)ˣ`. -/
noncomputable def unitLog (p : ℕ) [Fact p.Prime] :
    (ZMod p)ˣ ≃ ZMod (Nat.card (ZMod p)ˣ) :=
  ((zmodCyclicMulEquiv (inferInstance : IsCyclic (ZMod p)ˣ)).symm.toEquiv).trans
    Multiplicative.toAdd

/-- The discrete logarithm turns `ZMod p` into `Option (ZMod (p−1))`: the zero
element becomes the extra point `none`. -/
noncomputable def logEquiv (p : ℕ) [Fact p.Prime] :
    ZMod p ≃ Option (ZMod (Nat.card (ZMod p)ˣ)) :=
  (Equiv.optionSubtypeNe (0 : ZMod p)).symm.trans
    (Equiv.optionCongr (unitsEquivNeZero.symm.trans (unitLog p)))

/-- The logarithm turns powers into multiples. -/
theorem unitLog_pow [Fact p.Prime] (u : (ZMod p)ˣ) (k : ℕ) :
    unitLog p (u ^ k) = (k : ZMod (Nat.card (ZMod p)ˣ)) * unitLog p u := by
  have h1 : ((zmodCyclicMulEquiv (inferInstance : IsCyclic (ZMod p)ˣ)).symm.toEquiv (u ^ k))
      = ((zmodCyclicMulEquiv (inferInstance : IsCyclic (ZMod p)ˣ)).symm.toEquiv u) ^ k :=
    map_pow ((zmodCyclicMulEquiv (inferInstance : IsCyclic (ZMod p)ˣ)).symm) u k
  simp only [unitLog, Equiv.trans_apply, h1, toAdd_pow, nsmul_eq_mul]

theorem logEquiv_zero [Fact p.Prime] : logEquiv p 0 = none := by
  have h : (Equiv.optionSubtypeNe (0 : ZMod p)).symm 0 = none := by
    rw [Equiv.symm_apply_eq]; simp
  rw [logEquiv, Equiv.trans_apply, h]
  rfl

theorem logEquiv_unit [Fact p.Prime] (u : (ZMod p)ˣ) :
    logEquiv p (u : ZMod p) = some (unitLog p u) := by
  have hne : ((u : ZMod p)) ≠ 0 := u.ne_zero
  have h : (Equiv.optionSubtypeNe (0 : ZMod p)).symm (u : ZMod p) = some ⟨(u : ZMod p), hne⟩ := by
    rw [Equiv.symm_apply_eq]; simp
  rw [logEquiv, Equiv.trans_apply, h]
  simp only [Equiv.optionCongr_apply, Option.map_some, Equiv.trans_apply]
  congr 1
  congr 1
  exact Units.ext rfl

/-- Two cycle counts at equal moduli agree. -/
theorem cycleCount_congr {M M' : ℕ} [NeZero M] [NeZero M'] (h : M = M') (k : ℕ) :
    cycleCount M k = cycleCount M' k := by
  subst h
  congr!

/-- **The power readout at a prime.**  The permutation `x ↦ x^k` of `ZMod p` has
exactly one more cycle than the multiplication `y ↦ k·y` of `ZMod (p−1)`: the
power readout is the multiplicative readout of this project, one level down. -/
theorem cycleCountOf_pow_prime (hp : p.Prime) (hk : Nat.Coprime k (p - 1)) (hk0 : 0 < k) :
    haveI : NeZero p := ⟨hp.pos.ne'⟩
    haveI : NeZero (p - 1) := ⟨by have := hp.two_le; omega⟩
    cycleCountOf p (fun x : ZMod p => x ^ k) = cycleCount (p - 1) k + 1 := by
  haveI : Fact p.Prime := ⟨hp⟩
  haveI : NeZero p := ⟨hp.pos.ne'⟩
  haveI : NeZero (p - 1) := ⟨by have := hp.two_le; omega⟩
  haveI : NeZero (Nat.card (ZMod p)ˣ) := ⟨Nat.card_pos.ne'⟩
  have hM : Nat.card (ZMod p)ˣ = p - 1 := by
    rw [Nat.card_eq_fintype_card, ZMod.card_units_eq_totient, Nat.totient_prime hp]
  have hkM : Nat.Coprime k (Nat.card (ZMod p)ˣ) := by rw [hM]; exact hk
  set v : (ZMod (Nat.card (ZMod p)ˣ))ˣ := ZMod.unitOfCoprime k hkM with hv
  have hvk : ((v : ZMod (Nat.card (ZMod p)ˣ))) = (k : ZMod (Nat.card (ZMod p)ˣ)) :=
    ZMod.coe_unitOfCoprime k hkM
  set G : Equiv.Perm (Option (ZMod (Nat.card (ZMod p)ˣ))) :=
    Equiv.optionCongr (Units.mulLeft v) with hG
  set σ : Equiv.Perm (ZMod p) := (logEquiv p).symm.permCongr G with hσ
  have hcoe : (σ : ZMod p → ZMod p) = fun x : ZMod p => x ^ k := by
    funext x
    have happ : σ x = (logEquiv p).symm (G (logEquiv p x)) := rfl
    by_cases hx : x = 0
    · subst hx
      rw [happ, logEquiv_zero]
      have hGnone : G none = none := rfl
      rw [hGnone, ← logEquiv_zero (p := p), Equiv.symm_apply_apply]
      exact (zero_pow hk0.ne').symm
    · obtain ⟨u, rfl⟩ : ∃ u : (ZMod p)ˣ, (u : ZMod p) = x :=
        ⟨(Ne.isUnit hx).unit, IsUnit.unit_spec _⟩
      rw [happ, logEquiv_unit]
      have hGsome : G (some (unitLog p u))
          = some ((v : ZMod (Nat.card (ZMod p)ˣ)) * unitLog p u) := rfl
      rw [hGsome, hvk, ← unitLog_pow u k, ← logEquiv_unit (u ^ k), Equiv.symm_apply_apply,
        Units.val_pow_eq_pow_val]
  have h1 : cycleCountOf p (fun x : ZMod p => x ^ k) = numOrbits σ := by
    rw [← hcoe, cycleCountOf_eq_numOrbits]
  have h4 : numOrbits (Units.mulLeft v) = cycleCount (Nat.card (ZMod p)ˣ) k := by
    rw [← cycleCountOf_eq_numOrbits]
    have hcoe2 : ((Units.mulLeft v : Equiv.Perm (ZMod (Nat.card (ZMod p)ˣ))) :
        ZMod (Nat.card (ZMod p)ˣ) → ZMod (Nat.card (ZMod p)ˣ))
        = fun y => (k : ZMod (Nat.card (ZMod p)ˣ)) * y := by
      funext y
      show (v : ZMod (Nat.card (ZMod p)ˣ)) * y = _
      rw [hvk]
    rw [hcoe2, cycleCountOf_mul hkM]
  rw [h1, numOrbits_permCongr, hG, numOrbits_optionCongr, h4, cycleCount_congr hM]

/-- **The sign law for power permutations.**  Combining the count with the
all-moduli sign law at the even modulus `p − 1`: the permutation `x ↦ x^k` of
`ZMod p` is even exactly when `4 ∣ p − 1 → k ≡ 1 (mod 4)`.  Like every other
readout in this project, the sign is factorisation-free — it is computable from
`p` and `k` in polynomial time. -/
theorem power_readout_sign_law (hp : p.Prime) (hodd : p ≠ 2) (hk : Nat.Coprime k (p - 1))
    (hk0 : 0 < k) :
    haveI : NeZero p := ⟨hp.pos.ne'⟩
    ((p - cycleCountOf p (fun x : ZMod p => x ^ k)) % 2 = 0 ↔ (4 ∣ (p - 1) → k % 4 = 1)) := by
  haveI : NeZero p := ⟨hp.pos.ne'⟩
  haveI : NeZero (p - 1) := ⟨by have := hp.two_le; omega⟩
  have hp2 : 2 ≤ p := hp.two_le
  have hpodd : p % 2 = 1 := by
    rcases hp.eq_two_or_odd with h | h
    · exact absurd h hodd
    · exact h
  have hcount := cycleCountOf_pow_prime hp hk hk0
  have hle : cycleCount (p - 1) k ≤ p - 1 := by
    classical
    have h := Finset.card_image_le (s := (Finset.univ : Finset (ZMod (p - 1))))
      (f := fun x : ZMod (p - 1) => orb (p - 1) k x)
    simpa [cycleCount, ZMod.card] using h
  have hlaw := permutation_sign_law (N := p - 1) (a := k) hk
  have heven : (p - 1) % 2 = 0 := by omega
  have hif : (if (p - 1) % 2 = 1 then jacobiSym (k : ℤ) (p - 1) = 1
      else (4 ∣ (p - 1) → k % 4 = 1)) = (4 ∣ (p - 1) → k % 4 = 1) := by
    rw [if_neg (by omega)]
  rw [hif] at hlaw
  rw [hcount]
  have harith : p - (cycleCount (p - 1) k + 1) = (p - 1) - cycleCount (p - 1) k := by omega
  rw [harith]
  exact hlaw

end PrimePowerMap

end Physics.PermReadout