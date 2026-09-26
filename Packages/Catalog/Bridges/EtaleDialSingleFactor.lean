/-
# ETALE-DIAL IV: readable channels see a single CRT factor

`EtaleDialJoinFailure` showed that readable (sum-sufficient) channels are not closed under
joins.  This file proves the structural statement behind that failure, which was
Conjecture 1 of the previous cycle for two factors.

* `swap_dichotomy` — a purely combinatorial lemma: a function `g` on a grid `X × Y` such that
  `{g(x,y), g(x',y')} = {g(x,y'), g(x',y)}` for all `x, x', y, y'` depends on one coordinate.
* `SumSufficient.prod_dichotomy` — a readable channel on `(R₁ × R₂)ˣ` depends only on the
  `R₁`-component or only on the `R₂`-component.
* `sumSufficient_prod_iff` — the exact classification: readable channels on `(R₁ × R₂)ˣ` are
  exactly the pullbacks of readable channels on `R₁ˣ` or on `R₂ˣ`.
* `sumSufficient_zmod_mul_iff` — the same at a coprime conductor `a b`.
* `sumSufficient_primePow_mul_iff` — **the readable-channel classification at conductor
  `ℓ₁^k₁ ℓ₂^k₂`**: a type map is readable iff it factors through `(ZMod ℓ₁^⌈k₁/2⌉)ˣ` or
  through `(ZMod ℓ₂^⌈k₂/2⌉)ˣ`.
-/
module

public import Mathlib
public import Bridges.EtaleDialVietaChannel
public import Bridges.EtaleDialHalfConductor
public import Bridges.EtaleDialJoinFailure

@[expose] public section

namespace EtaleDial

/-! ## 1. The swap dichotomy on a grid -/

/-- **Swap dichotomy.**  If for all `x, x', y, y'` the unordered pairs `{g(x,y), g(x',y')}` and
`{g(x,y'), g(x',y)}` coincide, then `g` is independent of `y` or independent of `x`. -/
theorem swap_dichotomy {X Y β : Type*} (g : X → Y → β)
    (h : ∀ x x' y y', (g x y = g x y' ∧ g x' y' = g x' y) ∨ (g x y = g x' y ∧ g x' y' = g x y')) :
    (∀ x y y', g x y = g x y') ∨ (∀ x x' y, g x y = g x' y) := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨⟨x₀, y₁, y₂, hy⟩, ⟨x₁, x₂, y₀, hx⟩⟩ := hcon
  -- the columns `y₁` and `y₂` are constant
  have col : ∀ x', g x' y₁ = g x₀ y₁ := by
    intro x'
    rcases h x₀ x' y₁ y₂ with ⟨e, _⟩ | ⟨e, _⟩
    · exact absurd e hy
    · exact e.symm
  rcases h x₁ x₂ y₁ y₀ with ⟨e1, e2⟩ | ⟨_, e2⟩
  · exact hx (by rw [← e1, e2, col x₁, col x₂])
  · exact hx e2.symm

/-! ## 2. Readable channels on a product ring -/

variable {R₁ R₂ : Type*} [CommRing R₁] [CommRing R₂]

/-- Assemble a unit of `R₁ × R₂` from its components. -/
def pairUnit (u : R₁ˣ) (v : R₂ˣ) : (R₁ × R₂)ˣ := MulEquiv.prodUnits.symm (u, v)

@[simp] theorem pairUnit_fst (u : R₁ˣ) (v : R₂ˣ) : ((pairUnit u v : (R₁ × R₂)ˣ) : R₁ × R₂).1 = u := by
  simp [pairUnit, MulEquiv.prodUnits]

@[simp] theorem pairUnit_snd (u : R₁ˣ) (v : R₂ˣ) : ((pairUnit u v : (R₁ × R₂)ˣ) : R₁ × R₂).2 = v := by
  simp [pairUnit, MulEquiv.prodUnits]

/-- Every unit of `R₁ × R₂` is assembled from its components. -/
theorem pairUnit_components (x : (R₁ × R₂)ˣ) :
    pairUnit (Units.map (RingHom.fst R₁ R₂).toMonoidHom x)
      (Units.map (RingHom.snd R₁ R₂).toMonoidHom x) = x := by
  apply Units.ext
  ext <;> simp

/-- **Product dichotomy.**  A readable channel on `(R₁ × R₂)ˣ` depends only on the first
component or only on the second component. -/
theorem SumSufficient.prod_dichotomy {β : Type*} {f : (R₁ × R₂)ˣ → β} (hf : SumSufficient f) :
    (∀ x y : (R₁ × R₂)ˣ, Units.map (RingHom.fst R₁ R₂).toMonoidHom x =
        Units.map (RingHom.fst R₁ R₂).toMonoidHom y → f x = f y) ∨
    (∀ x y : (R₁ × R₂)ˣ, Units.map (RingHom.snd R₁ R₂).toMonoidHom x =
        Units.map (RingHom.snd R₁ R₂).toMonoidHom y → f x = f y) := by
  have key := swap_dichotomy (fun (u : R₁ˣ) (v : R₂ˣ) => f (pairUnit u v)) (by
    intro x x' y y'
    have hs : ((pairUnit x y : (R₁ × R₂)ˣ) : R₁ × R₂) + pairUnit x' y'
        = pairUnit x y' + pairUnit x' y := by
      ext <;> simp [add_comm]
    have hp : ((pairUnit x y : (R₁ × R₂)ˣ) : R₁ × R₂) * pairUnit x' y'
        = pairUnit x y' * pairUnit x' y := by
      ext <;> simp [mul_comm]
    exact hf _ _ _ _ hs hp)
  rcases key with h | h
  · refine Or.inl fun x y hxy => ?_
    rw [← pairUnit_components x, ← pairUnit_components y, hxy]
    exact h _ _ _
  · refine Or.inr fun x y hxy => ?_
    rw [← pairUnit_components x, ← pairUnit_components y, hxy]
    exact h _ _ _

/-- A channel on `(R₁ × R₂)ˣ` depending only on the first component is readable iff the induced
channel on `R₁ˣ` is readable. -/
theorem sumSufficient_of_fst_factor {β : Type*} {f : (R₁ × R₂)ˣ → β} (hf : SumSufficient f) :
    SumSufficient (fun u : R₁ˣ => f (pairUnit u 1)) := by
  intro p q p' q' hs hp
  apply hf
  · ext <;> simp [hs]
  · ext <;> simp [hp]

theorem sumSufficient_of_snd_factor {β : Type*} {f : (R₁ × R₂)ˣ → β} (hf : SumSufficient f) :
    SumSufficient (fun v : R₂ˣ => f (pairUnit 1 v)) := by
  intro p q p' q' hs hp
  apply hf
  · ext <;> simp [hs]
  · ext <;> simp [hp]

/-- **Classification of readable channels on a product ring.**  A type map on `(R₁ × R₂)ˣ` is
readable iff it is the pullback of a readable type map on `R₁ˣ` or of one on `R₂ˣ`. -/
theorem sumSufficient_prod_iff {β : Type*} (f : (R₁ × R₂)ˣ → β) :
    SumSufficient f ↔
      (∃ h : R₁ˣ → β, SumSufficient h ∧ f = h ∘ Units.map (RingHom.fst R₁ R₂).toMonoidHom) ∨
      (∃ h : R₂ˣ → β, SumSufficient h ∧ f = h ∘ Units.map (RingHom.snd R₁ R₂).toMonoidHom) := by
  constructor
  · intro hf
    rcases hf.prod_dichotomy with h | h
    · refine Or.inl ⟨_, sumSufficient_of_fst_factor hf, funext fun x => ?_⟩
      exact h _ _ (by apply Units.ext; simp)
    · refine Or.inr ⟨_, sumSufficient_of_snd_factor hf, funext fun x => ?_⟩
      exact h _ _ (by apply Units.ext; simp)
  · rintro (⟨h, hh, rfl⟩ | ⟨h, hh, rfl⟩)
    · exact hh.pullback _
    · exact hh.pullback _

/-! ## 3. Coprime conductors -/

/-- Transport of readability along a ring isomorphism. -/
theorem SumSufficient.of_ringEquiv {R S : Type*} [CommRing R] [CommRing S] (e : R ≃+* S)
    {β : Type*} {f : Rˣ → β} (hf : SumSufficient f) :
    SumSufficient (f ∘ Units.map e.symm.toRingHom.toMonoidHom) :=
  hf.pullback e.symm.toRingHom

/-- The first CRT component is reduction modulo `a`. -/
theorem crt_fst_eq {a b : ℕ} (hab : Nat.Coprime a b) (x : ZMod (a * b)) :
    (ZMod.chineseRemainder hab x).1 = ZMod.castHom (dvd_mul_right a b) (ZMod a) x := by
  have := RingHom.congr_fun (RingHom.ext_zmod ((RingHom.fst _ _).comp
    (ZMod.chineseRemainder hab).toRingHom) (ZMod.castHom (dvd_mul_right a b) (ZMod a))) x
  simpa using this

/-- The second CRT component is reduction modulo `b`. -/
theorem crt_snd_eq {a b : ℕ} (hab : Nat.Coprime a b) (x : ZMod (a * b)) :
    (ZMod.chineseRemainder hab x).2 = ZMod.castHom (dvd_mul_left b a) (ZMod b) x := by
  have := RingHom.congr_fun (RingHom.ext_zmod ((RingHom.snd _ _).comp
    (ZMod.chineseRemainder hab).toRingHom) (ZMod.castHom (dvd_mul_left b a) (ZMod b))) x
  simpa using this

/-- **Single-factor theorem at a coprime conductor.**  For coprime `a, b`, a type map on
`(ZMod (a b))ˣ` is readable iff it is a readable type map of the residue mod `a`, or a readable
type map of the residue mod `b`. -/
theorem sumSufficient_zmod_mul_iff {a b : ℕ} (hab : Nat.Coprime a b) {β : Type*}
    (f : (ZMod (a * b))ˣ → β) :
    SumSufficient f ↔
      (∃ h : (ZMod a)ˣ → β, SumSufficient h ∧ f = h ∘ unitRed a (dvd_mul_right a b)) ∨
      (∃ h : (ZMod b)ˣ → β, SumSufficient h ∧ f = h ∘ unitRed b (dvd_mul_left b a)) := by
  set e := ZMod.chineseRemainder hab
  have hinv : ∀ x : (ZMod (a * b))ˣ,
      Units.map e.symm.toRingHom.toMonoidHom (Units.map e.toRingHom.toMonoidHom x) = x := by
    intro x; apply Units.ext; simp
  have hfst : ∀ x : (ZMod (a * b))ˣ, Units.map (RingHom.fst _ _).toMonoidHom
      (Units.map e.toRingHom.toMonoidHom x) = unitRed a (dvd_mul_right a b) x := by
    intro x; apply Units.ext; simp [unitRed, e, crt_fst_eq]
  have hsnd : ∀ x : (ZMod (a * b))ˣ, Units.map (RingHom.snd _ _).toMonoidHom
      (Units.map e.toRingHom.toMonoidHom x) = unitRed b (dvd_mul_left b a) x := by
    intro x; apply Units.ext; simp [unitRed, e, crt_snd_eq]
  constructor
  · intro hf
    rcases (sumSufficient_prod_iff _).mp (hf.of_ringEquiv e) with ⟨h, hh, hF⟩ | ⟨h, hh, hF⟩
    · refine Or.inl ⟨h, hh, funext fun x => ?_⟩
      have := congrFun hF (Units.map e.toRingHom.toMonoidHom x)
      simp only [Function.comp_apply, hinv, hfst] at this
      exact this
    · refine Or.inr ⟨h, hh, funext fun x => ?_⟩
      have := congrFun hF (Units.map e.toRingHom.toMonoidHom x)
      simp only [Function.comp_apply, hinv, hsnd] at this
      exact this
  · rintro (⟨h, hh, rfl⟩ | ⟨h, hh, rfl⟩)
    · exact hh.pullback _
    · exact hh.pullback _

/-! ## 4. The readable-channel classification at `ℓ₁^k₁ ℓ₂^k₂` -/

/-- **Readable channels at conductor `ℓ₁^k₁ ℓ₂^k₂`.**  For distinct primes `ℓ₁, ℓ₂`, a type map
on `(ZMod (ℓ₁^k₁ ℓ₂^k₂))ˣ` is readable iff it only depends on the residue modulo
`ℓ₁^⌈k₁/2⌉`, or only depends on the residue modulo `ℓ₂^⌈k₂/2⌉`. -/
theorem sumSufficient_primePow_mul_iff {ℓ₁ ℓ₂ : ℕ} [Fact ℓ₁.Prime] [Fact ℓ₂.Prime]
    (h12 : ℓ₁ ≠ ℓ₂) (k₁ k₂ : ℕ) {β : Type*} (f : (ZMod (ℓ₁ ^ k₁ * ℓ₂ ^ k₂))ˣ → β) :
    SumSufficient f ↔
      (∀ x y, unitRed (ℓ₁ ^ ((k₁ + 1) / 2))
          ((pow_dvd_pow ℓ₁ (by omega)).trans (dvd_mul_right _ _)) x =
        unitRed (ℓ₁ ^ ((k₁ + 1) / 2))
          ((pow_dvd_pow ℓ₁ (by omega)).trans (dvd_mul_right _ _)) y → f x = f y) ∨
      (∀ x y, unitRed (ℓ₂ ^ ((k₂ + 1) / 2))
          ((pow_dvd_pow ℓ₂ (by omega)).trans (dvd_mul_left _ _)) x =
        unitRed (ℓ₂ ^ ((k₂ + 1) / 2))
          ((pow_dvd_pow ℓ₂ (by omega)).trans (dvd_mul_left _ _)) y → f x = f y) := by
  have hcop : Nat.Coprime (ℓ₁ ^ k₁) (ℓ₂ ^ k₂) :=
    Nat.Coprime.pow _ _ ((Nat.coprime_primes Fact.out Fact.out).mpr h12)
  -- reduction maps compose
  have comp₁ : ∀ x, unitRed (ℓ₁ ^ ((k₁ + 1) / 2)) (pow_dvd_pow ℓ₁ (by omega))
      (unitRed (ℓ₁ ^ k₁) (dvd_mul_right _ (ℓ₂ ^ k₂)) x) =
      unitRed (n := ℓ₁ ^ k₁ * ℓ₂ ^ k₂) (ℓ₁ ^ ((k₁ + 1) / 2))
        ((pow_dvd_pow ℓ₁ (by omega)).trans (dvd_mul_right _ _)) x := by
    intro x; apply Units.ext
    simp only [unitRed, Units.coe_map, RingHom.toMonoidHom_eq_coe, MonoidHom.coe_coe]
    exact RingHom.congr_fun (ZMod.castHom_comp (pow_dvd_pow ℓ₁ (show (k₁ + 1) / 2 ≤ k₁ by omega))
      (dvd_mul_right (ℓ₁ ^ k₁) (ℓ₂ ^ k₂))) (x : ZMod (ℓ₁ ^ k₁ * ℓ₂ ^ k₂))
  have comp₂ : ∀ x, unitRed (ℓ₂ ^ ((k₂ + 1) / 2)) (pow_dvd_pow ℓ₂ (by omega))
      (unitRed (ℓ₂ ^ k₂) (dvd_mul_left _ (ℓ₁ ^ k₁)) x) =
      unitRed (n := ℓ₁ ^ k₁ * ℓ₂ ^ k₂) (ℓ₂ ^ ((k₂ + 1) / 2))
        ((pow_dvd_pow ℓ₂ (by omega)).trans (dvd_mul_left _ _)) x := by
    intro x; apply Units.ext
    simp only [unitRed, Units.coe_map, RingHom.toMonoidHom_eq_coe, MonoidHom.coe_coe]
    exact RingHom.congr_fun (ZMod.castHom_comp (pow_dvd_pow ℓ₂ (show (k₂ + 1) / 2 ≤ k₂ by omega))
      (dvd_mul_left (ℓ₂ ^ k₂) (ℓ₁ ^ k₁))) (x : ZMod (ℓ₁ ^ k₁ * ℓ₂ ^ k₂))
  constructor
  · rw [sumSufficient_zmod_mul_iff hcop]
    rintro (⟨h, hh, rfl⟩ | ⟨h, hh, rfl⟩)
    · refine Or.inl fun x y hxy => ?_
      rw [← comp₁, ← comp₁] at hxy
      exact (sumSufficient_iff_factors_halfConductor k₁ h).mp hh _ _ hxy
    · refine Or.inr fun x y hxy => ?_
      rw [← comp₂, ← comp₂] at hxy
      exact (sumSufficient_iff_factors_halfConductor k₂ h).mp hh _ _ hxy
  · rintro (H | H) p q p' q' hs hp
    · rcases ((sumSufficient_reduction (ℓ := ℓ₁) k₁).pullback
          (ZMod.castHom (dvd_mul_right (ℓ₁ ^ k₁) (ℓ₂ ^ k₂)) _)) p q p' q' hs hp with
        ⟨h1, h2⟩ | ⟨h1, h2⟩
      · change unitRed _ _ (unitRed _ _ p) = unitRed _ _ (unitRed _ _ p') at h1
        change unitRed _ _ (unitRed _ _ q) = unitRed _ _ (unitRed _ _ q') at h2
        rw [comp₁, comp₁] at h1 h2
        exact Or.inl ⟨H _ _ h1, H _ _ h2⟩
      · change unitRed _ _ (unitRed _ _ p) = unitRed _ _ (unitRed _ _ q') at h1
        change unitRed _ _ (unitRed _ _ q) = unitRed _ _ (unitRed _ _ p') at h2
        rw [comp₁, comp₁] at h1 h2
        exact Or.inr ⟨H _ _ h1, H _ _ h2⟩
    · rcases ((sumSufficient_reduction (ℓ := ℓ₂) k₂).pullback
          (ZMod.castHom (dvd_mul_left (ℓ₂ ^ k₂) (ℓ₁ ^ k₁)) _)) p q p' q' hs hp with
        ⟨h1, h2⟩ | ⟨h1, h2⟩
      · change unitRed _ _ (unitRed _ _ p) = unitRed _ _ (unitRed _ _ p') at h1
        change unitRed _ _ (unitRed _ _ q) = unitRed _ _ (unitRed _ _ q') at h2
        rw [comp₂, comp₂] at h1 h2
        exact Or.inl ⟨H _ _ h1, H _ _ h2⟩
      · change unitRed _ _ (unitRed _ _ p) = unitRed _ _ (unitRed _ _ q') at h1
        change unitRed _ _ (unitRed _ _ q) = unitRed _ _ (unitRed _ _ p') at h2
        rw [comp₂, comp₂] at h1 h2
        exact Or.inr ⟨H _ _ h1, H _ _ h2⟩

end EtaleDial