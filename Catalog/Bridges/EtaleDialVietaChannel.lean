/-
# ETALE-DIAL I: the Vieta channel and its exact classification over `ZMod m`

Round-30 (`Bridges.HintOrientationLegendre`) analysed the hinted `(N, s)` view of a pair of
residues over a *field*: a cell `(N, s)` hosts at most one unordered factor pair.  The
"sum-sufficiency" explanation of the D₄@8 dial silently transports that field fact to the
*ring* `ZMod 8`.  This file shows that the transport is exactly where things break, and
classifies all conductors for which it is legitimate.

For a commutative ring `R` we say `R` is **Vieta-injective** (`VietaInjective R`) when the
sum and the product of two units determine the unordered pair of units.  A read-out
`f : Rˣ → β` (a *type map*) is **sum-sufficient** (`SumSufficient f`) when the pair
`(p + q, p q)` determines the unordered pair of types `{f p, f q}`.

Main results.

* `vietaInjective_of_isDomain` — every integral domain is Vieta-injective (the field fact of
  round 30, now over any domain, in particular `ℤ` and every `ZMod ℓ`, `ℓ` prime).
* `not_vietaInjective_of_sq_eq_zero` — **nilpotent obstruction**: a nonzero `a` with `a² = 0`
  produces the colliding pairs `{1, 1}` and `{1 + a, 1 - a}`.
* `not_vietaInjective_prod` — **matching obstruction**: in `R₁ × R₂` with two distinct units
  in each factor, the pairs `{(u₁,u₂), (v₁,v₂)}` and `{(u₁,v₂), (v₁,u₂)}` collide.
* `vietaInjective_prod_of_subsingleton` — a factor with a single unit is harmless.
* `vietaInjective_zmod_iff` — **the conductor classification**:
  `ZMod m` is Vieta-injective iff `m = 0, 1, 2, ℓ` or `2ℓ` with `ℓ` an odd prime.
* `sumSufficient_iff_forall` — a ring is Vieta-injective iff *every* type map is
  sum-sufficient; so at any conductor outside the classification list some type map
  (the identity) fails to be sum-sufficient.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): "the hinted sum determines the pair" is a field phenomenon; over
  `ZMod m` it survives exactly when `(ZMod m)ˣ` sees at most one "non-trivial" CRT factor
  and `ZMod m` has no square-zero elements.
Experiment (Stage 2): exhaustive enumeration of all quadruples of units for `1 ≤ m ≤ 60`
  (see `ComputationalEvidence.md`): Vieta-injective conductors are exactly
  `1, 2, 3, 5, 6, 7, 10, 11, 13, 14, 17, 19, 22, 23, 26, 29, 31, 34, 37, 38, 41, 43, 46, 47,
  53, 58, 59` — i.e. `{1, 2} ∪ {ℓ, 2ℓ}`.  At `m = 8` there are 4 colliding cells, at
  `m = 15 = 3·5` there are 6 (all of matching type), at `m = 16` there are 16.
Analysis (Stage 3): the two failure modes are orthogonal — nilpotents (`4 ∣ m` or `ℓ² ∣ m`)
  and CRT matching ambiguity (two coprime factors each `≥ 3`).
Critique (Stage 4): the statement is about units only, which is the arithmetic situation of
  unramified primes `p, q ∤ m`; `m = 0` (`ZMod 0 = ℤ`) is included for completeness.
-/
module

public import Mathlib

@[expose] public section

namespace EtaleDial

universe u

/-! ## 1. Definitions -/

/-- `R` is **Vieta-injective** when the sum and product of two units determine the
unordered pair of units. -/
def VietaInjective (R : Type*) [CommRing R] : Prop :=
  ∀ p q p' q' : Rˣ, (p : R) + q = p' + q' → (p : R) * q = p' * q' →
    (p = p' ∧ q = q') ∨ (p = q' ∧ q = p')

/-- A type map `f : Rˣ → β` is **sum-sufficient** when the hinted view `(p + q, p q)`
determines the unordered pair of types `{f p, f q}`. -/
def SumSufficient {R : Type*} [CommRing R] {β : Type*} (f : Rˣ → β) : Prop :=
  ∀ p q p' q' : Rˣ, (p : R) + q = p' + q' → (p : R) * q = p' * q' →
    (f p = f p' ∧ f q = f q') ∨ (f p = f q' ∧ f q = f p')

variable {R : Type u} [CommRing R]

/-- Vieta-injectivity is the sum-sufficiency of the identity type map. -/
theorem vietaInjective_iff_sumSufficient_id : VietaInjective R ↔ SumSufficient (id : Rˣ → Rˣ) :=
  Iff.rfl

/-- On a Vieta-injective ring every type map is sum-sufficient. -/
theorem SumSufficient.of_vietaInjective (h : VietaInjective R) {β : Type*} (f : Rˣ → β) :
    SumSufficient f := by
  intro p q p' q' hs hp
  rcases h p q p' q' hs hp with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
  · exact Or.inl ⟨rfl, rfl⟩
  · exact Or.inr ⟨rfl, rfl⟩

/-- **Universality.** A ring is Vieta-injective iff every type map on its units is
sum-sufficient. -/
theorem sumSufficient_iff_forall :
    VietaInjective R ↔ ∀ (β : Type u) (f : Rˣ → β), SumSufficient f :=
  ⟨fun h _ f => SumSufficient.of_vietaInjective h f, fun h => h Rˣ id⟩

/-- Sum-sufficiency is inherited by coarsenings of the type map. -/
theorem SumSufficient.comp {β γ : Type*} {f : Rˣ → β} (hf : SumSufficient f) (g : β → γ) :
    SumSufficient (g ∘ f) := by
  intro p q p' q' hs hp
  rcases hf p q p' q' hs hp with ⟨h1, h2⟩ | ⟨h1, h2⟩
  · exact Or.inl ⟨by simp [h1], by simp [h2]⟩
  · exact Or.inr ⟨by simp [h1], by simp [h2]⟩

/-! ## 2. Domains are Vieta-injective -/

/-- The polynomial identity behind Vieta: equal sums and products force
`(x - p')(x - q') = (x - p)(x - q)` evaluated at `x = p`. -/
theorem vieta_root_eq {D : Type*} [CommRing D] [IsDomain D] {p q p' q' : D}
    (hs : p + q = p' + q') (hp : p * q = p' * q') : (p = p' ∧ q = q') ∨ (p = q' ∧ q = p') := by
  have key : (p - p') * (p - q') = 0 := by
    linear_combination p * hs - hp
  rcases mul_eq_zero.mp key with h | h
  · left
    have hpp : p = p' := sub_eq_zero.mp h
    exact ⟨hpp, by subst hpp; exact add_left_cancel hs⟩
  · right
    have hpq : p = q' := sub_eq_zero.mp h
    refine ⟨hpq, ?_⟩
    subst hpq
    have : p + q = p + p' := by rw [hs, add_comm]
    exact add_left_cancel this

/-- **Domains are Vieta-injective.** -/
theorem vietaInjective_of_isDomain [IsDomain R] : VietaInjective R := by
  intro p q p' q' hs hp
  rcases vieta_root_eq hs hp with ⟨h1, h2⟩ | ⟨h1, h2⟩
  · exact Or.inl ⟨Units.ext h1, Units.ext h2⟩
  · exact Or.inr ⟨Units.ext h1, Units.ext h2⟩

/-- A ring with a single unit is (vacuously) Vieta-injective. -/
theorem vietaInjective_of_subsingleton_units [Subsingleton Rˣ] : VietaInjective R :=
  fun _ _ _ _ _ _ => Or.inl ⟨Subsingleton.elim _ _, Subsingleton.elim _ _⟩

/-! ## 3. Transport along ring isomorphisms -/

/-- Vieta-injectivity is invariant under ring isomorphism. -/
theorem VietaInjective.of_ringEquiv {S : Type*} [CommRing S] (e : R ≃+* S)
    (h : VietaInjective S) : VietaInjective R := by
  intro p q p' q' hs hp
  let E : Rˣ →* Sˣ := Units.map (e : R →* S)
  have hE : ∀ a : Rˣ, ((E a : Sˣ) : S) = e a := fun a => rfl
  have hs' : ((E p : Sˣ) : S) + (E q : Sˣ) = (E p' : Sˣ) + (E q' : Sˣ) := by
    rw [hE, hE, hE, hE, ← map_add, ← map_add, hs]
  have hp' : ((E p : Sˣ) : S) * (E q : Sˣ) = (E p' : Sˣ) * (E q' : Sˣ) := by
    rw [hE, hE, hE, hE, ← map_mul, ← map_mul, hp]
  have inj : ∀ a b : Rˣ, E a = E b → a = b := by
    intro a b hab
    apply Units.ext
    have := congrArg (fun u : Sˣ => (u : S)) hab
    simp only [hE] at this
    exact e.injective this
  rcases h _ _ _ _ hs' hp' with ⟨h1, h2⟩ | ⟨h1, h2⟩
  · exact Or.inl ⟨inj _ _ h1, inj _ _ h2⟩
  · exact Or.inr ⟨inj _ _ h1, inj _ _ h2⟩

theorem vietaInjective_congr {S : Type*} [CommRing S] (e : R ≃+* S) :
    VietaInjective R ↔ VietaInjective S :=
  ⟨VietaInjective.of_ringEquiv e.symm, VietaInjective.of_ringEquiv e⟩

/-! ## 4. The two obstructions -/

/-- **Nilpotent obstruction.** A nonzero square-zero element `a` gives the colliding cells
`{1, 1}` and `{1 + a, 1 - a}`: both have sum `2` and product `1`. -/
theorem not_vietaInjective_of_sq_eq_zero {a : R} (ha : a ≠ 0) (ha2 : a * a = 0) :
    ¬ VietaInjective R := by
  intro h
  let u : Rˣ := ⟨1 + a, 1 - a, by linear_combination -ha2, by linear_combination -ha2⟩
  let v : Rˣ := ⟨1 - a, 1 + a, by linear_combination -ha2, by linear_combination -ha2⟩
  have hs : ((1 : Rˣ) : R) + ((1 : Rˣ) : R) = (u : R) + (v : R) := by
    simp only [Units.val_one, u, v]; ring
  have hp : ((1 : Rˣ) : R) * ((1 : Rˣ) : R) = (u : R) * (v : R) := by
    simp only [Units.val_one, u, v]; linear_combination ha2
  rcases h 1 1 u v hs hp with ⟨h1, _⟩ | ⟨h1, _⟩
  · have := congrArg (fun w : Rˣ => (w : R)) h1
    simp only [Units.val_one, u] at this
    exact ha (by linear_combination -this)
  · have := congrArg (fun w : Rˣ => (w : R)) h1
    simp only [Units.val_one, v] at this
    exact ha (by linear_combination this)

/-- **Matching obstruction.** If both factors of `R₁ × R₂` carry two distinct units, the
cells `{(u₁,u₂), (v₁,v₂)}` and `{(u₁,v₂), (v₁,u₂)}` collide: the componentwise pairs are
determined, but the *matching* between components is not. -/
theorem not_vietaInjective_prod {R₁ R₂ : Type*} [CommRing R₁] [CommRing R₂]
    {u₁ v₁ : R₁ˣ} {u₂ v₂ : R₂ˣ} (h₁ : u₁ ≠ v₁) (h₂ : u₂ ≠ v₂) :
    ¬ VietaInjective (R₁ × R₂) := by
  intro h
  let P : (R₁ × R₂)ˣ := MulEquiv.prodUnits.symm (u₁, u₂)
  let Q : (R₁ × R₂)ˣ := MulEquiv.prodUnits.symm (v₁, v₂)
  let P' : (R₁ × R₂)ˣ := MulEquiv.prodUnits.symm (u₁, v₂)
  let Q' : (R₁ × R₂)ˣ := MulEquiv.prodUnits.symm (v₁, u₂)
  have hs : (P : R₁ × R₂) + Q = P' + Q' := by
    ext <;> simp [P, Q, P', Q', MulEquiv.prodUnits, add_comm]
  have hp : (P : R₁ × R₂) * Q = P' * Q' := by
    ext <;> simp [P, Q, P', Q', MulEquiv.prodUnits, mul_comm]
  rcases h P Q P' Q' hs hp with ⟨e1, _⟩ | ⟨e1, _⟩
  · apply h₂
    have := congrArg (fun w : (R₁ × R₂)ˣ => ((w : R₁ × R₂)).2) e1
    simp [P, P', MulEquiv.prodUnits] at this
    exact Units.ext this
  · apply h₁
    have := congrArg (fun w : (R₁ × R₂)ˣ => ((w : R₁ × R₂)).1) e1
    simp [P, Q', MulEquiv.prodUnits] at this
    exact Units.ext this

/-- A factor with a single unit does not disturb Vieta-injectivity. -/
theorem vietaInjective_prod_of_subsingleton {R₁ R₂ : Type*} [CommRing R₁] [CommRing R₂]
    [Subsingleton R₁ˣ] (h : VietaInjective R₂) : VietaInjective (R₁ × R₂) := by
  intro p q p' q' hs hp
  have one : ∀ w : (R₁ × R₂)ˣ, ((w : R₁ × R₂)).1 = 1 := by
    intro w
    have := Subsingleton.elim (Units.map (RingHom.fst R₁ R₂).toMonoidHom w) 1
    simpa using congrArg (fun z : R₁ˣ => (z : R₁)) this
  let s : (R₁ × R₂)ˣ →* R₂ˣ := Units.map (RingHom.snd R₁ R₂).toMonoidHom
  have hs2 : ((s p : R₂ˣ) : R₂) + (s q : R₂ˣ) = (s p' : R₂ˣ) + (s q' : R₂ˣ) := by
    simpa [s] using congrArg Prod.snd hs
  have hp2 : ((s p : R₂ˣ) : R₂) * (s q : R₂ˣ) = (s p' : R₂ˣ) * (s q' : R₂ˣ) := by
    simpa [s] using congrArg Prod.snd hp
  have lift : ∀ a b : (R₁ × R₂)ˣ, s a = s b → a = b := by
    intro a b hab
    apply Units.ext
    have h2 := congrArg (fun z : R₂ˣ => (z : R₂)) hab
    simp only [s, Units.coe_map, RingHom.toMonoidHom_eq_coe, MonoidHom.coe_coe,
      RingHom.coe_snd] at h2
    exact Prod.ext (by rw [one a, one b]) h2
  rcases h _ _ _ _ hs2 hp2 with ⟨h1, h2⟩ | ⟨h1, h2⟩
  · exact Or.inl ⟨lift _ _ h1, lift _ _ h2⟩
  · exact Or.inr ⟨lift _ _ h1, lift _ _ h2⟩

/-! ## 5. The conductor classification over `ZMod m` -/

/-- `ZMod 2` has a single unit. -/
instance subsingleton_units_zmod_two : Subsingleton (ZMod 2)ˣ :=
  ⟨fun a b => by
    have h : ∀ u : (ZMod 2)ˣ, u = 1 := by decide
    rw [h a, h b]⟩

/-- Positive half: `ZMod (2 ℓ)` is Vieta-injective for every odd prime `ℓ`. -/
theorem vietaInjective_zmod_two_mul {ℓ : ℕ} (hℓ : ℓ.Prime) (h2 : ℓ ≠ 2) :
    VietaInjective (ZMod (2 * ℓ)) := by
  have hc : Nat.Coprime 2 ℓ := (Nat.coprime_primes Nat.prime_two hℓ).mpr (Ne.symm h2)
  haveI : Fact ℓ.Prime := ⟨hℓ⟩
  exact (vietaInjective_congr (ZMod.chineseRemainder hc)).mpr
    (vietaInjective_prod_of_subsingleton vietaInjective_of_isDomain)

/-- In `ZMod n` with `n ≥ 3` the units `1` and `-1` are distinct. -/
theorem one_ne_neg_one_units {n : ℕ} (hn : 2 < n) : (1 : (ZMod n)ˣ) ≠ -1 := by
  haveI : Fact (2 < n) := ⟨hn⟩
  intro h
  have := congrArg (fun u : (ZMod n)ˣ => (u : ZMod n)) h
  simp only [Units.val_one, Units.val_neg] at this
  exact ZMod.neg_one_ne_one this.symm

/-- Negative half, nilpotent part: a square factor `ℓ² ∣ m` kills Vieta-injectivity. -/
theorem not_vietaInjective_zmod_of_sq_dvd {m ℓ : ℕ} (hm : m ≠ 0) (hℓ : ℓ.Prime)
    (hdvd : ℓ * ℓ ∣ m) : ¬ VietaInjective (ZMod m) := by
  obtain ⟨k, rfl⟩ := hdvd
  have hk : k ≠ 0 := by rintro rfl; simp at hm
  apply not_vietaInjective_of_sq_eq_zero (a := ((ℓ * k : ℕ) : ZMod (ℓ * ℓ * k)))
  · rw [Ne, ZMod.natCast_eq_zero_iff]
    intro hd
    have hpos : 0 < ℓ * k := Nat.mul_pos hℓ.pos (Nat.pos_of_ne_zero hk)
    have hle := Nat.le_of_dvd hpos hd
    have : ℓ * k < ℓ * ℓ * k := by
      have h2 := hℓ.two_le
      nlinarith [Nat.pos_of_ne_zero hk]
    omega
  · rw [← Nat.cast_mul, ZMod.natCast_eq_zero_iff]
    exact ⟨k, by ring⟩

/-- Negative half, matching part: a coprime splitting `m = a b` with `a, b ≥ 3` kills
Vieta-injectivity. -/
theorem not_vietaInjective_zmod_of_coprime {a b : ℕ} (hab : Nat.Coprime a b)
    (ha : 2 < a) (hb : 2 < b) : ¬ VietaInjective (ZMod (a * b)) := by
  rw [vietaInjective_congr (ZMod.chineseRemainder hab)]
  exact not_vietaInjective_prod (one_ne_neg_one_units ha) (one_ne_neg_one_units hb)

/-- **The conductor classification.**  `ZMod m` is Vieta-injective — i.e. the hinted view
`(p + q mod m, p q mod m)` of two unramified residues determines the unordered residue
pair — exactly for `m = 0, 1, 2`, an odd prime `ℓ`, or twice an odd prime. -/
theorem vietaInjective_zmod_iff (m : ℕ) :
    VietaInjective (ZMod m) ↔
      m = 0 ∨ m = 1 ∨ m = 2 ∨ ∃ ℓ, ℓ.Prime ∧ ℓ ≠ 2 ∧ (m = ℓ ∨ m = 2 * ℓ) := by
  constructor
  · intro h
    by_contra hcon
    push_neg at hcon
    obtain ⟨h0, h1, h2, hl⟩ := hcon
    -- no prime square divides `m`
    have hsq : ∀ ℓ, ℓ.Prime → ¬ ℓ * ℓ ∣ m := fun ℓ hℓ hd =>
      not_vietaInjective_zmod_of_sq_dvd h0 hℓ hd h
    -- `m` has an odd prime factor
    obtain ⟨ℓ, hℓ, hℓm, hℓ2⟩ : ∃ ℓ, ℓ.Prime ∧ ℓ ∣ m ∧ ℓ ≠ 2 := by
      by_contra hne
      push_neg at hne
      have hpow := Nat.eq_prime_pow_of_unique_prime_dvd h0 (fun hd hdm => hne _ hd hdm)
      set e := m.primeFactorsList.length
      rcases Nat.lt_or_ge e 2 with he | he
      · interval_cases e <;> simp_all
      · apply hsq 2 Nat.prime_two
        rw [hpow]
        exact dvd_trans (by norm_num) (pow_dvd_pow 2 he)
    obtain ⟨k, rfl⟩ := hℓm
    have hcop : Nat.Coprime ℓ k := by
      rw [Nat.Prime.coprime_iff_not_dvd hℓ]
      rintro ⟨j, rfl⟩
      exact hsq ℓ hℓ ⟨j, by ring⟩
    have hℓ3 : 2 < ℓ := lt_of_le_of_ne hℓ.two_le (Ne.symm hℓ2)
    have hk0 : k ≠ 0 := by rintro rfl; simp at h0
    have hk1 : 1 ≤ k := Nat.pos_of_ne_zero hk0
    rcases Nat.lt_or_ge 2 k with hk | hk
    · exact not_vietaInjective_zmod_of_coprime hcop hℓ3 hk h
    · interval_cases k
      · exact (hl ℓ hℓ hℓ2).1 (by ring)
      · exact (hl ℓ hℓ hℓ2).2 (by ring)
  · rintro (rfl | rfl | rfl | ⟨ℓ, hℓ, h2, hm | hm⟩)
    · exact vietaInjective_of_isDomain (R := ℤ)
    · exact vietaInjective_of_subsingleton_units
    · exact vietaInjective_of_subsingleton_units
    · rw [hm]
      haveI : Fact ℓ.Prime := ⟨hℓ⟩
      exact vietaInjective_of_isDomain
    · rw [hm]
      exact vietaInjective_zmod_two_mul hℓ h2

/-- **Prime conductor sum-sufficiency.**  At a prime conductor every type map — in
particular every Legendre-symbol dial — is sum-sufficient. -/
theorem sumSufficient_zmod_prime {ℓ : ℕ} [Fact ℓ.Prime] {β : Type*} (f : (ZMod ℓ)ˣ → β) :
    SumSufficient f :=
  SumSufficient.of_vietaInjective vietaInjective_of_isDomain f

end EtaleDial