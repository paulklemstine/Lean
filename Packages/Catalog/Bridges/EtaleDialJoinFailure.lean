/-
# ETALE-DIAL IV: readable channels do not combine

Cycles I–III classified which single type maps are *sum-sufficient* (readable from the hinted
view `(p + q, p q) mod m`).  This file studies how readable channels interact, which is the
formal content of the round-30 verdict THE-ROUTING-IS-DIAL-DEPENDENT.

* `SumSufficient.pullback` — readability pulls back along any ring homomorphism: a channel
  that factors through a quotient ring on which it is readable stays readable.
* `sumSufficient_of_dvd_vietaInjective` — every type map factoring through `(ZMod d)ˣ` with
  `d ∣ m` and `ZMod d` Vieta-injective (`d = ℓ` or `2ℓ`) is readable at conductor `m`; in
  particular every Legendre-symbol dial of prime conductor `ℓ ∣ m`.
* `vietaInjective_of_sumSufficient_injective` — a readable *injective* channel forces
  Vieta-injectivity of the ring.
* `join_not_sumSufficient` — **join failure**: at conductor `15 = 3 · 5` the mod-`3` channel
  and the mod-`5` channel are each readable, but the joint channel `(p mod 3, p mod 5)` is
  not.  Readability is not closed under joins: the CRT *matching* bit is lost.
* `join_failure_general` — the same for every product `ℓ₁ ℓ₂` of distinct odd primes.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1, cycle 4): the dial-dependence of routing is a lattice phenomenon —
  readable channels form a down-set (closed under coarsening, `SumSufficient.comp`) that is
  *not* closed under joins as soon as the conductor has two non-trivial CRT factors.
Experiment (Stage 2, cycle 4): at `m = 15` the 6 colliding cells found in cycle 1 are all of
  matching type `{(a₁,b₁),(a₂,b₂)} ~ {(a₁,b₂),(a₂,b₁)}`; each component multiset is preserved,
  the matching is not.
Analysis (Stage 3, cycle 4): hence the mod-3 and mod-5 dials are individually readable and
  jointly unreadable — exactly a "combination-required" pattern.
Critique (Stage 4, cycle 4): the statements are about the hinted `(N, s)` view of residues;
  they do not by themselves compute the empirical percentages of the round-30 table.
-/
module

public import Mathlib
public import Bridges.EtaleDialVietaChannel

@[expose] public section

namespace EtaleDial

/-- **Pullback.**  If `g` is readable on `Sˣ` then `g ∘ φˣ` is readable on `Rˣ` for every ring
homomorphism `φ : R →+* S`. -/
theorem SumSufficient.pullback {R S : Type*} [CommRing R] [CommRing S] (φ : R →+* S)
    {β : Type*} {g : Sˣ → β} (hg : SumSufficient g) :
    SumSufficient (g ∘ Units.map φ.toMonoidHom) := by
  intro p q p' q' hs hp
  have hs' : ((Units.map φ.toMonoidHom p : Sˣ) : S) + (Units.map φ.toMonoidHom q : Sˣ)
      = (Units.map φ.toMonoidHom p' : Sˣ) + (Units.map φ.toMonoidHom q' : Sˣ) := by
    simp only [Units.coe_map, RingHom.toMonoidHom_eq_coe, MonoidHom.coe_coe]
    rw [← map_add, ← map_add, hs]
  have hp' : ((Units.map φ.toMonoidHom p : Sˣ) : S) * (Units.map φ.toMonoidHom q : Sˣ)
      = (Units.map φ.toMonoidHom p' : Sˣ) * (Units.map φ.toMonoidHom q' : Sˣ) := by
    simp only [Units.coe_map, RingHom.toMonoidHom_eq_coe, MonoidHom.coe_coe]
    rw [← map_mul, ← map_mul, hp]
  exact hg _ _ _ _ hs' hp'

/-- Every type map factoring through a Vieta-injective quotient `ZMod d`, `d ∣ m`, is
readable at conductor `m`. -/
theorem sumSufficient_of_dvd_vietaInjective {m d : ℕ} (hd : d ∣ m)
    (hV : VietaInjective (ZMod d)) {β : Type*} (g : (ZMod d)ˣ → β) :
    SumSufficient (g ∘ Units.map (ZMod.castHom hd (ZMod d)).toMonoidHom) :=
  SumSufficient.pullback _ (SumSufficient.of_vietaInjective hV g)

/-- A readable injective channel forces Vieta-injectivity. -/
theorem vietaInjective_of_sumSufficient_injective {R : Type*} [CommRing R] {β : Type*}
    {f : Rˣ → β} (hf : SumSufficient f) (hinj : Function.Injective f) : VietaInjective R := by
  intro p q p' q' hs hp
  rcases hf p q p' q' hs hp with ⟨h1, h2⟩ | ⟨h1, h2⟩
  · exact Or.inl ⟨hinj h1, hinj h2⟩
  · exact Or.inr ⟨hinj h1, hinj h2⟩

/-- The joint CRT channel `x ↦ (x mod a, x mod b)` on `(ZMod (a b))ˣ` is injective. -/
theorem crtChannel_injective {a b : ℕ} (hab : Nat.Coprime a b) :
    Function.Injective (fun x : (ZMod (a * b))ˣ =>
      (Units.map (ZMod.castHom (dvd_mul_right a b) (ZMod a)).toMonoidHom x,
       Units.map (ZMod.castHom (dvd_mul_left b a) (ZMod b)).toMonoidHom x)) := by
  intro x y hxy
  simp only [Prod.mk.injEq] at hxy
  obtain ⟨h1, h2⟩ := hxy
  apply Units.ext
  apply (ZMod.chineseRemainder hab).injective
  have e1 := congrArg (fun u : (ZMod a)ˣ => (u : ZMod a)) h1
  have e2 := congrArg (fun u : (ZMod b)ˣ => (u : ZMod b)) h2
  simp only [Units.coe_map, RingHom.toMonoidHom_eq_coe, MonoidHom.coe_coe] at e1 e2
  refine Prod.ext ?_ ?_
  · have := RingHom.congr_fun (RingHom.ext_zmod ((RingHom.fst _ _).comp
      (ZMod.chineseRemainder hab).toRingHom) (ZMod.castHom (dvd_mul_right a b) (ZMod a)))
    simp only [RingHom.coe_comp, Function.comp_apply, RingHom.coe_fst] at this
    rw [RingEquiv.toRingHom_eq_coe] at this
    simp only [RingHom.coe_coe] at this
    rw [this (x : ZMod (a * b)), this (y : ZMod (a * b))]
    exact e1
  · have := RingHom.congr_fun (RingHom.ext_zmod ((RingHom.snd _ _).comp
      (ZMod.chineseRemainder hab).toRingHom) (ZMod.castHom (dvd_mul_left b a) (ZMod b)))
    simp only [RingHom.coe_comp, Function.comp_apply, RingHom.coe_snd] at this
    rw [RingEquiv.toRingHom_eq_coe] at this
    simp only [RingHom.coe_coe] at this
    rw [this (x : ZMod (a * b)), this (y : ZMod (a * b))]
    exact e2

/-- **Join failure for two odd primes.**  For distinct odd primes `ℓ₁, ℓ₂`, at conductor
`ℓ₁ ℓ₂` the mod-`ℓ₁` channel and the mod-`ℓ₂` channel are each readable, while their join is
not. -/
theorem join_failure_general {ℓ₁ ℓ₂ : ℕ} (h₁ : ℓ₁.Prime) (h₂ : ℓ₂.Prime) (h12 : ℓ₁ ≠ ℓ₂)
    (o₁ : ℓ₁ ≠ 2) (o₂ : ℓ₂ ≠ 2) :
    SumSufficient (Units.map (ZMod.castHom (dvd_mul_right ℓ₁ ℓ₂) (ZMod ℓ₁)).toMonoidHom) ∧
    SumSufficient (Units.map (ZMod.castHom (dvd_mul_left ℓ₂ ℓ₁) (ZMod ℓ₂)).toMonoidHom) ∧
    ¬ SumSufficient (fun x : (ZMod (ℓ₁ * ℓ₂))ˣ =>
      (Units.map (ZMod.castHom (dvd_mul_right ℓ₁ ℓ₂) (ZMod ℓ₁)).toMonoidHom x,
       Units.map (ZMod.castHom (dvd_mul_left ℓ₂ ℓ₁) (ZMod ℓ₂)).toMonoidHom x)) := by
  haveI : Fact ℓ₁.Prime := ⟨h₁⟩
  haveI : Fact ℓ₂.Prime := ⟨h₂⟩
  have hcop : Nat.Coprime ℓ₁ ℓ₂ := (Nat.coprime_primes h₁ h₂).mpr h12
  refine ⟨?_, ?_, ?_⟩
  · exact sumSufficient_of_dvd_vietaInjective _ vietaInjective_of_isDomain id
  · exact sumSufficient_of_dvd_vietaInjective _ vietaInjective_of_isDomain id
  · intro h
    have hV := vietaInjective_of_sumSufficient_injective h (crtChannel_injective hcop)
    have t1 : 2 < ℓ₁ := lt_of_le_of_ne h₁.two_le (Ne.symm o₁)
    have t2 : 2 < ℓ₂ := lt_of_le_of_ne h₂.two_le (Ne.symm o₂)
    exact not_vietaInjective_zmod_of_coprime hcop t1 t2 hV

/-- **Join failure at conductor 15.** -/
theorem join_not_sumSufficient :
    SumSufficient (Units.map (ZMod.castHom (dvd_mul_right 3 5) (ZMod 3)).toMonoidHom) ∧
    SumSufficient (Units.map (ZMod.castHom (dvd_mul_left 5 3) (ZMod 5)).toMonoidHom) ∧
    ¬ SumSufficient (fun x : (ZMod (3 * 5))ˣ =>
      (Units.map (ZMod.castHom (dvd_mul_right 3 5) (ZMod 3)).toMonoidHom x,
       Units.map (ZMod.castHom (dvd_mul_left 5 3) (ZMod 5)).toMonoidHom x)) :=
  join_failure_general Nat.prime_three (by norm_num) (by norm_num) (by norm_num) (by norm_num)

end EtaleDial