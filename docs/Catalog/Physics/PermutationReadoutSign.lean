import Mathlib
import Physics.PermutationReadoutCore
import Physics.PermutationReadoutZolotarevGeneral
import Physics.PermutationReadoutAffine

/-!
# The sign bridge: cycle counts are permutation signs, and the affine readout is a product

The earlier files of this project analyse the readout `#cycles(σ)` of the
permutations `σ` of `ZMod N` by hand, and read its *parity* — the quantity
`N − #cycles(σ)` — as the "sign" of the permutation.  This file supplies the
missing formal bridge: for **every** permutation `σ` of a finite type,

  `sign σ = (−1)^(card α − #orbits σ)`,

where `#orbits σ` counts the `SameCycle` classes.  Composed with the
identification of `#orbits` with the concrete cycle count `cycleCountOf` of
`Physics/PermutationReadoutAffine.lean`, this turns the whole readout into a
genuine `Equiv.Perm.sign` computation, and hence makes it *multiplicative*.

The pay-off is the closure of conjecture **C1** of `FUTURE_DIRECTIONS.md` in all
regimes: for every modulus `N`, every multiplier `a` coprime to `N` and every
shift `b`,

  `N − #cycles(x ↦ a·x + b) ≡ (N − #cycles(x ↦ a·x)) + (N − gcd(N, b))  (mod 2)`,

i.e. the affine sign is the multiplicative sign times the translation sign.  The
previous file settled this only for `1 − a` invertible (where even the count,
not just its parity, is shift-independent) and for `a = 1`.  In particular, at
an odd modulus the shift is *always* invisible and the affine sign is the
Jacobi symbol `J(a | N)` for every coprime `a` and every `b` — a
factorisation-free quantity, so the affine family adds nothing to the PERMORD
readout.

## Main results

* `Physics.PermReadout.numOrbits_eq` — `#orbits σ = (card α − |support σ|) +
  |cycleFactorsFinset σ|`.
* `Physics.PermReadout.sign_eq_neg_one_pow_sub_numOrbits` — the sign bridge
  `sign σ = (−1)^(card α − #orbits σ)`.
* `Physics.PermReadout.cycleCountOf_eq_numOrbits` — the concrete `cycleCountOf`
  of a permutation of `ZMod N` is its number of orbits.
* `Physics.PermReadout.affine_sign_law` — conjecture C1, all regimes.
* `Physics.PermReadout.zolotarev_affine_all` — at an odd modulus the affine sign
  is `J(a | N)`, for every coprime `a` and every shift.
-/

namespace Physics.PermReadout

open Finset

section GeneralPerm

open scoped Classical

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- The orbit of `x` under the permutation `σ`: its `SameCycle` class. -/
noncomputable def permOrbit (σ : Equiv.Perm α) (x : α) : Finset α :=
  Finset.univ.filter (fun y => σ.SameCycle x y)

/-- The number of orbits (cycles, fixed points included) of a permutation. -/
noncomputable def numOrbits (σ : Equiv.Perm α) : ℕ :=
  (Finset.univ.image (permOrbit σ)).card

theorem mem_permOrbit {σ : Equiv.Perm α} {x y : α} :
    y ∈ permOrbit σ x ↔ σ.SameCycle x y := by
  simp [permOrbit]

/-- A fixed point is an orbit on its own. -/
theorem permOrbit_of_notMem_support {σ : Equiv.Perm α} {x : α} (h : x ∉ σ.support) :
    permOrbit σ x = {x} := by
  have hx : σ x = x := by simpa [Equiv.Perm.mem_support] using h
  ext y
  simp only [mem_permOrbit, Finset.mem_singleton]
  constructor
  · rintro ⟨i, hi⟩
    rw [Equiv.Perm.zpow_apply_eq_self_of_apply_eq_self hx i] at hi
    exact hi.symm
  · rintro rfl
    exact ⟨0, by simp⟩

/-- A moved point has as its orbit the support of the corresponding cycle. -/
theorem permOrbit_of_mem_support {σ : Equiv.Perm α} {x : α} (h : x ∈ σ.support) :
    permOrbit σ x = (σ.cycleOf x).support := by
  ext y
  rw [mem_permOrbit, Equiv.Perm.mem_support_cycleOf_iff]
  exact ⟨fun hy => ⟨hy, h⟩, fun hy => hy.1⟩

/-- Every cycle factor is the `cycleOf` of any of the points it moves. -/
theorem cycleFactorsFinset_eq_image (σ : Equiv.Perm α) :
    σ.cycleFactorsFinset = σ.support.image (fun x => σ.cycleOf x) := by
  ext c
  simp only [Finset.mem_image]
  constructor
  · intro hc
    obtain ⟨x, hx, -⟩ := (Equiv.Perm.mem_cycleFactorsFinset_iff.mp hc).1
    have hxc : x ∈ c.support := Equiv.Perm.mem_support.mpr hx
    exact ⟨x, Equiv.Perm.mem_cycleFactorsFinset_support_le hc hxc,
      (Equiv.Perm.cycle_is_cycleOf hxc hc).symm⟩
  · rintro ⟨x, hx, rfl⟩
    exact Equiv.Perm.cycleOf_mem_cycleFactorsFinset_iff.mpr hx

/-- A cycle factor is determined by its support. -/
theorem cycleFactors_support_injOn (σ : Equiv.Perm α) :
    Set.InjOn Equiv.Perm.support (σ.cycleFactorsFinset : Set (Equiv.Perm α)) := by
  intro c hc d hd hcd
  simp only [Finset.mem_coe] at hc hd
  obtain ⟨x, hx, -⟩ := (Equiv.Perm.mem_cycleFactorsFinset_iff.mp hc).1
  have hxc : x ∈ c.support := Equiv.Perm.mem_support.mpr hx
  have hxd : x ∈ d.support := hcd ▸ hxc
  rw [Equiv.Perm.cycle_is_cycleOf hxc hc, Equiv.Perm.cycle_is_cycleOf hxd hd]

/-- **Orbit count of a permutation.**  The orbits are the fixed points (as
singletons) together with the supports of the cycle factors. -/
theorem numOrbits_eq (σ : Equiv.Perm α) :
    numOrbits σ = (Fintype.card α - σ.support.card) + σ.cycleFactorsFinset.card := by
  classical
  set A : Finset (Finset α) := σ.cycleFactorsFinset.image Equiv.Perm.support with hA
  set B : Finset (Finset α) := (Finset.univ \ σ.support).image (fun x => ({x} : Finset α)) with hB
  have hsplit : Finset.univ.image (permOrbit σ) = A ∪ B := by
    ext s
    simp only [Finset.mem_image, Finset.mem_univ, true_and, Finset.mem_union, hA, hB,
      Finset.mem_sdiff]
    constructor
    · rintro ⟨x, rfl⟩
      by_cases hx : x ∈ σ.support
      · exact Or.inl ⟨σ.cycleOf x, Equiv.Perm.cycleOf_mem_cycleFactorsFinset_iff.mpr hx,
          (permOrbit_of_mem_support hx).symm⟩
      · exact Or.inr ⟨x, hx, (permOrbit_of_notMem_support hx).symm⟩
    · rintro (⟨c, hc, rfl⟩ | ⟨x, hx, rfl⟩)
      · obtain ⟨x, hx, -⟩ := (Equiv.Perm.mem_cycleFactorsFinset_iff.mp hc).1
        have hxc : x ∈ c.support := Equiv.Perm.mem_support.mpr hx
        refine ⟨x, ?_⟩
        rw [permOrbit_of_mem_support (Equiv.Perm.mem_cycleFactorsFinset_support_le hc hxc),
          ← Equiv.Perm.cycle_is_cycleOf hxc hc]
      · exact ⟨x, permOrbit_of_notMem_support hx⟩
  have hdisj : Disjoint A B := by
    rw [Finset.disjoint_left]
    rintro s hs hsB
    simp only [hA, Finset.mem_image] at hs
    simp only [hB, Finset.mem_image] at hsB
    obtain ⟨c, hc, rfl⟩ := hs
    obtain ⟨x, -, hx⟩ := hsB
    have h2 : 2 ≤ c.support.card :=
      (Equiv.Perm.mem_cycleFactorsFinset_iff.mp hc).1.two_le_card_support
    rw [← hx] at h2
    simp at h2
  have hAcard : A.card = σ.cycleFactorsFinset.card :=
    Finset.card_image_of_injOn (cycleFactors_support_injOn σ)
  have hBcard : B.card = Fintype.card α - σ.support.card := by
    rw [hB, Finset.card_image_of_injective _ (fun x y h => by simpa using h),
      Finset.card_univ_diff]
  rw [numOrbits, hsplit, Finset.card_union_of_disjoint hdisj, hAcard, hBcard]
  omega

theorem card_cycleType_eq (σ : Equiv.Perm α) :
    σ.cycleType.card = σ.cycleFactorsFinset.card := by
  simp [Equiv.Perm.cycleType]

theorem cycleFactors_card_le_support (σ : Equiv.Perm α) :
    σ.cycleFactorsFinset.card ≤ σ.support.card := by
  have h1 : σ.cycleType.card • 1 ≤ σ.cycleType.sum :=
    Multiset.card_nsmul_le_sum (fun x hx => le_trans (by norm_num)
      (Equiv.Perm.two_le_of_mem_cycleType hx))
  rw [smul_eq_mul, mul_one] at h1
  rwa [card_cycleType_eq, Equiv.Perm.sum_cycleType] at h1

/-- **The sign bridge.**  For every permutation of a finite type the sign is
`(−1)^(card − #orbits)`: the parity read off from the cycle count in the earlier
files really is the signature of the permutation. -/
theorem sign_eq_neg_one_pow_sub_numOrbits (σ : Equiv.Perm α) :
    Equiv.Perm.sign σ = (-1 : ℤˣ) ^ (Fintype.card α - numOrbits σ) := by
  have hsupp : σ.support.card ≤ Fintype.card α := Finset.card_le_univ _
  have hfac : σ.cycleFactorsFinset.card ≤ σ.support.card := cycleFactors_card_le_support σ
  have hsub : Fintype.card α - numOrbits σ = σ.support.card - σ.cycleFactorsFinset.card := by
    rw [numOrbits_eq]
    omega
  have hkey : σ.cycleType.sum + σ.cycleType.card =
      (σ.support.card - σ.cycleFactorsFinset.card) + 2 * σ.cycleFactorsFinset.card := by
    rw [card_cycleType_eq, Equiv.Perm.sum_cycleType]
    omega
  rw [Equiv.Perm.sign_of_cycleType, hkey, hsub, pow_add, pow_mul]
  simp

/-- The sign bridge in parity form: the permutation is even exactly when
`card α − #orbits` is even. -/
theorem sign_eq_one_iff_even (σ : Equiv.Perm α) :
    Equiv.Perm.sign σ = 1 ↔ (Fintype.card α - numOrbits σ) % 2 = 0 := by
  rw [sign_eq_neg_one_pow_sub_numOrbits]
  constructor
  · intro h
    by_contra hodd
    have : Odd (Fintype.card α - numOrbits σ) := Nat.odd_iff.mpr (by omega)
    rw [this.neg_one_pow] at h
    exact absurd h (by decide)
  · intro h
    exact (Nat.even_iff.mpr h).neg_one_pow

end GeneralPerm

section ZModBridge

variable {N : ℕ} [NeZero N]

/-- Every point of `ZMod N` returns to itself within `N` steps of a
permutation. -/
theorem exists_period_le (e : Equiv.Perm (ZMod N)) (x : ZMod N) :
    ∃ p, 0 < p ∧ p ≤ N ∧ (e : ZMod N → ZMod N)^[p] x = x := by
  classical
  have hcard : Fintype.card (ZMod N) < Fintype.card (Fin (N + 1)) := by
    simp [ZMod.card]
  obtain ⟨i, j, hij, hEq⟩ := Fintype.exists_ne_map_eq_of_card_lt
    (fun k : Fin (N + 1) => (e : ZMod N → ZMod N)^[(k : ℕ)] x) hcard
  rcases lt_or_gt_of_ne (fun h : (i : ℕ) = (j : ℕ) => hij (Fin.ext h)) with hlt | hlt
  · refine ⟨(j : ℕ) - (i : ℕ), by omega, by omega, ?_⟩
    have hinj : Function.Injective ((e : ZMod N → ZMod N)^[(i : ℕ)]) :=
      Function.Injective.iterate e.injective _
    apply hinj
    rw [← Function.iterate_add_apply]
    have : (i : ℕ) + ((j : ℕ) - (i : ℕ)) = (j : ℕ) := by omega
    rw [this]
    exact hEq.symm
  · refine ⟨(i : ℕ) - (j : ℕ), by omega, by omega, ?_⟩
    have hinj : Function.Injective ((e : ZMod N → ZMod N)^[(j : ℕ)]) :=
      Function.Injective.iterate e.injective _
    apply hinj
    rw [← Function.iterate_add_apply]
    have : (j : ℕ) + ((i : ℕ) - (j : ℕ)) = (i : ℕ) := by omega
    rw [this]
    exact hEq

omit [NeZero N] in
theorem iterate_add_period {e : Equiv.Perm (ZMod N)} {x : ZMod N} {p : ℕ}
    (hp : (e : ZMod N → ZMod N)^[p] x = x) (k : ℕ) :
    (e : ZMod N → ZMod N)^[p * k] x = x := by
  induction k with
  | zero => simp
  | succ n ih =>
      rw [show p * (n + 1) = p + p * n by ring, Function.iterate_add_apply, ih, hp]

omit [NeZero N] in
theorem zpow_apply_eq_iterate {e : Equiv.Perm (ZMod N)} {x : ZMod N} {p : ℕ}
    (hp0 : 0 < p) (hp : (e : ZMod N → ZMod N)^[p] x = x) (i : ℤ) :
    ∃ k < p, (e ^ i) x = (e : ZMod N → ZMod N)^[k] x := by
  have hpow : ∀ n : ℕ, (e ^ (n : ℤ)) x = (e : ZMod N → ZMod N)^[n] x := by
    intro n
    rw [zpow_natCast, Equiv.Perm.coe_pow]
  have hshift : ∀ j : ℤ, (e ^ (j + (p : ℤ))) x = (e ^ j) x := by
    intro j
    have : (e ^ (j + (p : ℤ))) x = (e ^ j) ((e ^ (p : ℤ)) x) := by
      rw [zpow_add, Equiv.Perm.mul_apply]
    rw [this, hpow p, hp]
  have hmul : ∀ (m : ℕ) (j : ℤ), (e ^ (j + m * (p : ℤ))) x = (e ^ j) x := by
    intro m
    induction m with
    | zero => simp
    | succ n ih =>
        intro j
        have hcast : j + ((n : ℕ) + 1 : ℕ) * (p : ℤ) = (j + (n : ℤ) * (p : ℤ)) + (p : ℤ) := by
          push_cast; ring
        rw [hcast, hshift, ih]
  have hp1 : (1 : ℤ) ≤ (p : ℤ) := by exact_mod_cast hp0
  have hnn : 0 ≤ i + (i.natAbs : ℤ) * (p : ℤ) := by
    have h1 : -(i.natAbs : ℤ) ≤ i := by omega
    nlinarith [Int.natCast_nonneg i.natAbs]
  set n : ℕ := (i + (i.natAbs : ℤ) * (p : ℤ)).toNat with hn
  have hnval : ((n : ℤ)) = i + (i.natAbs : ℤ) * (p : ℤ) := Int.toNat_of_nonneg hnn
  have hkey : (e ^ i) x = (e : ZMod N → ZMod N)^[n] x := by
    rw [← hpow n]
    rw [show ((n : ℕ) : ℤ) = i + (i.natAbs : ℤ) * (p : ℤ) from hnval]
    exact (hmul i.natAbs i).symm
  refine ⟨n % p, Nat.mod_lt _ hp0, ?_⟩
  rw [hkey]
  conv_lhs => rw [← Nat.mod_add_div n p]
  rw [Function.iterate_add_apply, iterate_add_period hp]

/-- **Compatibility of the two cycle counts.**  For a permutation of `ZMod N`
the concrete count `cycleCountOf` (orbits of the iteration truncated at `N`
steps) is the number of `SameCycle` classes. -/
theorem cycleCountOf_eq_numOrbits (e : Equiv.Perm (ZMod N)) :
    cycleCountOf N (e : ZMod N → ZMod N) = numOrbits e := by
  classical
  have horb : ∀ x, orbIter N (e : ZMod N → ZMod N) x = permOrbit e x := by
    intro x
    obtain ⟨p, hp0, hpN, hp⟩ := exists_period_le e x
    ext y
    simp only [orbIter, Finset.mem_image, Finset.mem_range, mem_permOrbit]
    constructor
    · rintro ⟨k, -, rfl⟩
      exact ⟨(k : ℤ), by rw [zpow_natCast, Equiv.Perm.coe_pow]⟩
    · rintro ⟨i, hi⟩
      obtain ⟨k, hk, hke⟩ := zpow_apply_eq_iterate hp0 hp i
      exact ⟨k, lt_of_lt_of_le hk hpN, by rw [← hke, hi]⟩
  rw [cycleCountOf, numOrbits]
  congr 1
  exact Finset.image_congr (fun x _ => horb x)

end ZModBridge

section AffineSign

variable {N : ℕ} [NeZero N] {a : ℕ}

/-- The affine permutation `x ↦ u·x + b` of `ZMod N`, as an `Equiv.Perm`. -/
def affinePerm (u : (ZMod N)ˣ) (b : ZMod N) : Equiv.Perm (ZMod N) :=
  Equiv.addRight b * Units.mulLeft u

omit [NeZero N] in
theorem affinePerm_apply (u : (ZMod N)ˣ) (b x : ZMod N) :
    affinePerm u b x = (u : ZMod N) * x + b := rfl

omit [NeZero N] in
theorem coe_affinePerm (u : (ZMod N)ˣ) (b : ZMod N) :
    (affinePerm u b : ZMod N → ZMod N) = fun x => (u : ZMod N) * x + b := rfl

omit [NeZero N] in
theorem coe_mulLeft (u : (ZMod N)ˣ) :
    (Units.mulLeft u : ZMod N → ZMod N) = fun x => (u : ZMod N) * x := rfl

omit [NeZero N] in
theorem coe_addRightPerm (b : ZMod N) :
    ((Equiv.addRight b : Equiv.Perm (ZMod N)) : ZMod N → ZMod N) = fun x => x + b := rfl

/-- The sign of an affine permutation is the product of the signs of its
multiplicative and its additive part. -/
theorem sign_affinePerm (u : (ZMod N)ˣ) (b : ZMod N) :
    Equiv.Perm.sign (affinePerm u b) =
      Equiv.Perm.sign (Equiv.addRight b : Equiv.Perm (ZMod N)) *
        Equiv.Perm.sign (Units.mulLeft u) := by
  rw [affinePerm, Equiv.Perm.sign_mul]

/-- **Conjecture C1, all regimes.**  For every modulus, every multiplier coprime
to it and every shift, the parity of the affine readout is the sum of the parity
of the multiplicative readout and the parity of the translation readout: the
shift enters only through the free gcd probe `gcd(N, b)`.  No affine readout can
carry information beyond the multiplicative one plus one gcd. -/
theorem affine_sign_law (hcop : Nat.Coprime a N) (b : ZMod N) :
    (N - cycleCountOf N (fun x => (a : ZMod N) * x + b)) % 2 =
      ((N - cycleCount N a) + (N - Nat.gcd N b.val)) % 2 := by
  classical
  set u : (ZMod N)ˣ := ZMod.unitOfCoprime a hcop with hu
  have hucoe : ((u : ZMod N)) = (a : ZMod N) := ZMod.coe_unitOfCoprime a hcop
  have hcardZ : Fintype.card (ZMod N) = N := ZMod.card N
  -- the three cycle counts
  have hAff : cycleCountOf N (fun x => (a : ZMod N) * x + b) = numOrbits (affinePerm u b) := by
    rw [← cycleCountOf_eq_numOrbits, coe_affinePerm, hucoe]
  have hMul : cycleCountOf N (fun x => (a : ZMod N) * x) = numOrbits (Units.mulLeft u) := by
    rw [← cycleCountOf_eq_numOrbits, coe_mulLeft, hucoe]
  have hAdd : cycleCountOf N (fun x => x + b) =
      numOrbits (Equiv.addRight b : Equiv.Perm (ZMod N)) := by
    rw [← cycleCountOf_eq_numOrbits, coe_addRightPerm]
  have hMul' : numOrbits (Units.mulLeft u) = cycleCount N a := by
    rw [← hMul, cycleCountOf_mul hcop]
  have hAdd' : numOrbits (Equiv.addRight b : Equiv.Perm (ZMod N)) = Nat.gcd N b.val := by
    rw [← hAdd, cycleCountOf_add b]
  -- signs
  have hsign := sign_affinePerm u b
  rw [sign_eq_neg_one_pow_sub_numOrbits, sign_eq_neg_one_pow_sub_numOrbits,
    sign_eq_neg_one_pow_sub_numOrbits, hcardZ, hMul', hAdd', ← pow_add] at hsign
  rw [hAff]
  -- turn the sign identity into a parity identity
  set A := N - numOrbits (affinePerm u b) with hA
  set C := (N - Nat.gcd N b.val) + (N - cycleCount N a) with hC
  have hpar : A % 2 = C % 2 := by
    rcases Nat.even_or_odd A with hAe | hAo <;> rcases Nat.even_or_odd C with hCe | hCo
    · rw [Nat.even_iff.mp hAe, Nat.even_iff.mp hCe]
    · rw [hAe.neg_one_pow, hCo.neg_one_pow] at hsign
      exact absurd hsign (by decide)
    · rw [hAo.neg_one_pow, hCe.neg_one_pow] at hsign
      exact absurd hsign (by decide)
    · rw [Nat.odd_iff.mp hAo, Nat.odd_iff.mp hCo]
  rw [hpar, hC]
  omega

/-- The number of cycles never exceeds the size of the ring. -/
theorem cycleCount_le_modulus (a : ℕ) : cycleCount N a ≤ N := by
  classical
  have h := Finset.card_image_le (s := (Finset.univ : Finset (ZMod N)))
    (f := fun x : ZMod N => orb N a x)
  simpa [cycleCount, ZMod.card] using h

/-- **Zolotarev for the whole affine family.**  At an odd modulus, the sign of
`x ↦ a·x + b` is the Jacobi symbol `J(a | N)` for *every* coprime multiplier and
*every* shift: the translation part is always even, so the affine readout has
exactly the factorisation-free sign of the multiplicative one.  This removes the
invertibility hypothesis of `zolotarev_affine`. -/
theorem zolotarev_affine_all (hodd : Odd N) (hcop : Nat.Coprime a N) (b : ZMod N) :
    jacobiSym (a : ℤ) N = 1 ↔
      (N - cycleCountOf N (fun x => (a : ZMod N) * x + b)) % 2 = 0 := by
  have hg : Nat.gcd N b.val ∣ N := Nat.gcd_dvd_left _ _
  have hNodd : N % 2 = 1 := Nat.odd_iff.mp hodd
  have hgodd : Nat.gcd N b.val % 2 = 1 := by
    rcases Nat.even_or_odd (Nat.gcd N b.val) with he | ho
    · exfalso
      have h2 : 2 ∣ N := dvd_trans he.two_dvd hg
      omega
    · exact Nat.odd_iff.mp ho
  have hle : Nat.gcd N b.val ≤ N :=
    Nat.le_of_dvd (Nat.pos_of_ne_zero (NeZero.ne N)) hg
  have hlaw := affine_sign_law (a := a) hcop b
  have hcc : cycleCount N a ≤ N := cycleCount_le_modulus a
  rw [zolotarev_general hodd hcop]
  omega

end AffineSign

end Physics.PermReadout