/-
# ETALE-DIAL V: readable channels at an arbitrary conductor

`EtaleDialSingleFactor` classified the readable (sum-sufficient) type maps at conductors with
two prime-power factors.  Here we remove the restriction on the number of prime factors, by
strong induction on the conductor.

Main result.

* `sumSufficient_zmod_iff` — for `m ≠ 0`, a type map `f : (ZMod m)ˣ → β` is sum-sufficient iff
  there is a prime `ℓ` with `ℓ^k ∥ m` (i.e. `ℓ^k ∣ m` and `m / ℓ^k` coprime to `ℓ`) such that
  `f` only depends on the residue modulo `ℓ^⌈k/2⌉`.

So the readable channels at conductor `m` are exactly the channels that look at a *single*
prime-power component, and at that component only at half resolution.  For the D₄@8 dial
this is "only `p mod 4`"; for a composite conductor such as `24` it says a readable map sees
`p mod 4` or `p mod 3`, never both.
-/
module

public import Mathlib
public import Bridges.EtaleDialVietaChannel
public import Bridges.EtaleDialHalfConductor
public import Bridges.EtaleDialSingleFactor

@[expose] public section

namespace EtaleDial

/-- Reducing in two steps `n → r → d` is reducing in one step. -/
theorem zmod_cast_cast_of_dvd {n r d : ℕ} (h1 : d ∣ r) (h2 : r ∣ n) (x : ZMod n) :
    ((x.cast : ZMod r).cast : ZMod d) = x.cast :=
  RingHom.congr_fun (ZMod.castHom_comp h1 h2) x

/-- A type map that only depends on the residue modulo `ℓ^⌈k/2⌉`, where `ℓ^k ∣ m`, is readable
at conductor `m`. -/
theorem sumSufficient_of_factors_primePow {m ℓ k : ℕ} (hℓ : ℓ.Prime) (hk : ℓ ^ k ∣ m)
    {β : Type*} (f : (ZMod m)ˣ → β)
    (H : ∀ x y : (ZMod m)ˣ, ((x : ZMod m).cast : ZMod (ℓ ^ ((k + 1) / 2))) =
      ((y : ZMod m).cast : ZMod (ℓ ^ ((k + 1) / 2))) → f x = f y) :
    SumSufficient f := by
  haveI : Fact ℓ.Prime := ⟨hℓ⟩
  have hd : ℓ ^ ((k + 1) / 2) ∣ ℓ ^ k := pow_dvd_pow ℓ (by omega)
  have key : ∀ x y : (ZMod m)ˣ,
      unitRed (n := ℓ ^ k) (ℓ ^ ((k + 1) / 2)) hd (unitRed (ℓ ^ k) hk x) =
      unitRed (n := ℓ ^ k) (ℓ ^ ((k + 1) / 2)) hd (unitRed (ℓ ^ k) hk y) → f x = f y := by
    intro x y hxy
    apply H
    have := congrArg (fun u : (ZMod (ℓ ^ ((k + 1) / 2)))ˣ => (u : ZMod (ℓ ^ ((k + 1) / 2)))) hxy
    simp only [unitRed, Units.coe_map, RingHom.toMonoidHom_eq_coe, MonoidHom.coe_coe,
      ZMod.castHom_apply] at this
    rwa [zmod_cast_cast_of_dvd hd hk, zmod_cast_cast_of_dvd hd hk] at this
  intro p q p' q' hs hp
  rcases ((sumSufficient_reduction (ℓ := ℓ) k).pullback (ZMod.castHom hk (ZMod (ℓ ^ k))))
      p q p' q' hs hp with ⟨h1, h2⟩ | ⟨h1, h2⟩
  · exact Or.inl ⟨key _ _ h1, key _ _ h2⟩
  · exact Or.inr ⟨key _ _ h1, key _ _ h2⟩

/-- **Readable channels at an arbitrary conductor.**  For `m ≠ 0`, a type map on `(ZMod m)ˣ`
is sum-sufficient iff for some prime `ℓ` with `ℓ^k ∥ m` it only depends on the residue modulo
`ℓ^⌈k/2⌉`. -/
theorem sumSufficient_zmod_iff {m : ℕ} (hm : m ≠ 0) {β : Type*} (f : (ZMod m)ˣ → β) :
    SumSufficient f ↔ ∃ ℓ k : ℕ, ℓ.Prime ∧ ℓ ^ k ∣ m ∧ Nat.Coprime (m / ℓ ^ k) ℓ ∧
      ∀ x y : (ZMod m)ˣ, ((x : ZMod m).cast : ZMod (ℓ ^ ((k + 1) / 2))) =
        ((y : ZMod m).cast : ZMod (ℓ ^ ((k + 1) / 2))) → f x = f y := by
  constructor
  swap
  · rintro ⟨ℓ, k, hℓ, hk, -, H⟩
    exact sumSufficient_of_factors_primePow hℓ hk f H
  induction m using Nat.strong_induction_on generalizing β with
  | _ m ih =>
  intro hf
  -- the trivial conductor
  by_cases h1 : m = 1
  · subst h1
    refine ⟨2, 0, Nat.prime_two, by simp, by simp, fun x y _ => ?_⟩
    rw [Subsingleton.elim x y]
  -- split off the smallest prime factor
  have hm2 : 2 ≤ m := by omega
  set ℓ := m.minFac with hℓdef
  have hℓ : ℓ.Prime := Nat.minFac_prime h1
  set k := m.factorization ℓ with hkdef
  set r := m / ℓ ^ k with hrdef
  have hmr : ℓ ^ k * r = m := Nat.ordProj_mul_ordCompl_eq_self m ℓ
  have hcopr : Nat.Coprime ℓ r := Nat.coprime_ordCompl hℓ hm
  have hk1 : 1 ≤ k := hℓ.factorization_pos_of_dvd hm (Nat.minFac_dvd m)
  have hr0 : r ≠ 0 := by
    rintro h; rw [h, mul_zero] at hmr; exact hm hmr.symm
  have hℓk : 2 ≤ ℓ ^ k := le_trans hℓ.two_le
    (by simpa using Nat.pow_le_pow_right hℓ.pos hk1)
  have hrm : r < m := by
    rw [← hmr]; have : 1 ≤ r := Nat.one_le_iff_ne_zero.mpr hr0; nlinarith
  have hcop : Nat.Coprime (ℓ ^ k) r := Nat.Coprime.pow_left _ hcopr
  -- transport to the product form `ℓ^k * r`
  clear_value ℓ k r
  subst hmr
  rcases (sumSufficient_zmod_mul_iff hcop f).mp hf with ⟨h, hh, rfl⟩ | ⟨h, hh, rfl⟩
  · -- the readable part lives at `ℓ^k`
    haveI : Fact ℓ.Prime := ⟨hℓ⟩
    refine ⟨ℓ, k, hℓ, dvd_mul_right _ _, ?_, fun x y hxy => ?_⟩
    · rw [Nat.mul_div_cancel_left _ (by omega)]; exact hcopr.symm
    apply (sumSufficient_iff_factors_halfConductor k h).mp hh
    apply Units.ext
    simp only [unitRed, Units.coe_map, RingHom.toMonoidHom_eq_coe, MonoidHom.coe_coe,
      ZMod.castHom_apply]
    rwa [zmod_cast_cast_of_dvd (pow_dvd_pow ℓ (by omega)) (dvd_mul_right _ _),
      zmod_cast_cast_of_dvd (pow_dvd_pow ℓ (by omega)) (dvd_mul_right _ _)]
  · -- the readable part lives at `r`: use the induction hypothesis
    obtain ⟨ℓ', k', hℓ', hk', hc', H'⟩ := ih r hrm hr0 h hh
    by_cases hk0 : k' = 0
    · -- `h` is constant, so any prime-power witness works
      subst hk0
      haveI : Subsingleton (ZMod (ℓ' ^ ((0 + 1) / 2))) := ZMod.subsingleton_iff.mpr (by simp)
      have hconst : ∀ a b : (ZMod r)ˣ, h a = h b := fun a b =>
        H' a b (Subsingleton.elim _ _)
      refine ⟨ℓ, k, hℓ, dvd_mul_right _ _, ?_, fun x y _ => hconst _ _⟩
      rw [Nat.mul_div_cancel_left _ (by omega)]; exact hcopr.symm
    · have hℓ'r : ℓ' ∣ r := (dvd_pow_self ℓ' hk0).trans hk'
      have hne : ℓ' ≠ ℓ := by
        rintro rfl
        exact hℓ.one_lt.ne' (Nat.Coprime.eq_one_of_dvd hcopr hℓ'r)
      refine ⟨ℓ', k', hℓ', hk'.trans (dvd_mul_left _ _), ?_, fun x y hxy => ?_⟩
      · rw [Nat.mul_div_assoc _ hk']
        exact Nat.Coprime.mul_left
          (Nat.Coprime.pow_left _ ((Nat.coprime_primes hℓ hℓ').mpr hne.symm)) hc'
      apply H'
      have hd : ℓ' ^ ((k' + 1) / 2) ∣ r := (pow_dvd_pow ℓ' (by omega)).trans hk'
      simp only [unitRed, Units.coe_map, RingHom.toMonoidHom_eq_coe,
        MonoidHom.coe_coe, ZMod.castHom_apply]
      rwa [zmod_cast_cast_of_dvd hd (dvd_mul_left _ _),
        zmod_cast_cast_of_dvd hd (dvd_mul_left _ _)]

end EtaleDial