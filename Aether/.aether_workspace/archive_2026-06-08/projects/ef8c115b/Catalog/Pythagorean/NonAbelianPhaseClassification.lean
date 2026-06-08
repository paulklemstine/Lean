/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Non-Abelian Arithmetic Phase Classification

The **arithmetic phase profile** of a finite group G is the set of primes p
for which G admits an abelian quotient with p-torsion. The central theorem
shows this profile is entirely controlled by the abelianization G^ab = G/[G,G].

## Main Definitions

* `GroupHasPTorsion` — multiplicative p-torsion in a group
* `PrimePhaseVisible` — prime p is visible via some abelian quotient
* `arithmeticPhaseProfile` — the set of visible primes

## Main Theorems

* `primePhaseVisible_iff_abelianization` — the core biconditional (Theorem A)
* `primePhaseVisible_iff_of_abelianization_iso` — invariance (Theorem B)
* `arithmeticPhaseProfile_eq_of_abelianization_iso` — profile-level Theorem B
* `primePhaseVisible_prod_iff` — product decomposition (Cross-Domain Bridge)
* `primePhaseVisible_comm_iff` — abelian groups are phase-transparent
-/
import Mathlib

open Subgroup

/-! ## Section 1: Core Definitions -/

/-- A group `G` **has p-torsion** if some nontrivial element satisfies `g^p = 1`. -/
def GroupHasPTorsion (G : Type*) [Group G] (p : ℕ) : Prop :=
  ∃ g : G, g ≠ 1 ∧ g ^ p = 1

/-- **Prime Phase Visibility**: a prime `p` is *phase-visible* for a group `G` if
    there exists a normal subgroup `N ⊇ [G,G]` (making `G/N` abelian) such that
    `G/N` has p-torsion. -/
def PrimePhaseVisible (G : Type*) [Group G] (p : ℕ) : Prop :=
  ∃ (N : Subgroup G) (_ : N.Normal),
    commutator G ≤ N ∧ ∃ (g : G ⧸ N), g ≠ 1 ∧ g ^ p = 1

/-- The **arithmetic phase profile** of a group: the set of primes visible
    to homological probes through abelian quotients. -/
def arithmeticPhaseProfile (G : Type*) [Group G] : Set ℕ :=
  {p | Nat.Prime p ∧ PrimePhaseVisible G p}

/-! ## Section 2: Auxiliary Lemmas -/

/-- Surjective group homs: target card divides source card (using Nat.card). -/
theorem nat_card_dvd_of_surjective_hom
    {G H : Type*} [Group G] [Group H] [Finite G]
    (f : G →* H) (hf : Function.Surjective f) : Nat.card H ∣ Nat.card G := by
  have hrange : f.range = ⊤ := MonoidHom.range_eq_top.mpr hf
  have h1 := f.ker.card_mul_index
  rw [index_ker, hrange, card_top] at h1
  exact ⟨Nat.card f.ker, by linarith⟩

/-- If a finite group has p-torsion (prime p), then p divides Nat.card. -/
theorem prime_dvd_natcard_of_torsion
    {G : Type*} [Group G] [Finite G] (p : ℕ) [hp : Fact p.Prime]
    (h : GroupHasPTorsion G p) : p ∣ Nat.card G := by
  haveI : Fintype G := Fintype.ofFinite G
  rw [Nat.card_eq_fintype_card]
  obtain ⟨g, hne, hpow⟩ := h
  exact (orderOf_eq_prime hpow hne) ▸ orderOf_dvd_card

/-- Cauchy's theorem: if p (prime) divides Nat.card G, then G has p-torsion. -/
theorem torsion_of_prime_dvd_natcard
    {G : Type*} [Group G] [Finite G] (p : ℕ) [hp : Fact p.Prime]
    (h : p ∣ Nat.card G) : GroupHasPTorsion G p := by
  haveI : Fintype G := Fintype.ofFinite G
  rw [Nat.card_eq_fintype_card] at h
  obtain ⟨g, hord⟩ := exists_prime_orderOf_dvd_card p h
  exact ⟨g, fun h1 => by simp [h1] at hord; exact hp.out.one_lt.ne hord,
         hord ▸ pow_orderOf_eq_one g⟩

/-- Transport p-torsion across a multiplicative equivalence. -/
theorem groupHasPTorsion_of_mulEquiv
    {G H : Type*} [Group G] [Group H]
    (e : G ≃* H) (p : ℕ) :
    GroupHasPTorsion G p ↔ GroupHasPTorsion H p := by
  constructor
  · rintro ⟨x, hne, hpow⟩
    refine ⟨e x, ?_, ?_⟩
    · intro h; exact hne (e.injective (by rw [h]; exact (map_one e).symm))
    · rw [← map_pow, hpow, map_one]
  · rintro ⟨y, hne, hpow⟩
    refine ⟨e.symm y, ?_, ?_⟩
    · intro h; exact hne (e.symm.injective (by rw [h]; exact (map_one e.symm).symm))
    · rw [← map_pow, hpow, map_one]

/-- p-torsion in a product ↔ p-torsion in at least one factor.
    Uses `rcases` to decompose product elements and `by_cases` for which factor
    contributes the torsion. -/
theorem groupHasPTorsion_prod_iff {G H : Type*} [Group G] [Group H] (p : ℕ) :
    GroupHasPTorsion (G × H) p ↔ GroupHasPTorsion G p ∨ GroupHasPTorsion H p := by
  constructor
  · rintro ⟨⟨g, h⟩, hne, hpow⟩
    simp only [Prod.pow_mk, Prod.mk_eq_one] at hpow
    by_cases hg1 : g = 1
    · right; exact ⟨h, fun heq => hne (Prod.ext hg1 heq), hpow.2⟩
    · left; exact ⟨g, hg1, hpow.1⟩
  · rintro (⟨g, hne, hpow⟩ | ⟨h, hne, hpow⟩)
    · exact ⟨(g, 1), fun h => hne (by simpa using congr_arg Prod.fst h), by simp [hpow]⟩
    · exact ⟨(1, h), fun h' => hne (by simpa using congr_arg Prod.snd h'), by simp [hpow]⟩

/-! ## Section 3: The Main Classification Theorem (Theorem A) -/

/-- Quotient map G/N → G/M when N ≤ M (both normal) is surjective.
    This is the key step: [G,G] ≤ N means G^ab = G/[G,G] surjects onto G/N. -/
theorem quotient_map_surjective {G : Type*} [Group G]
    (N M : Subgroup G) [N.Normal] [M.Normal] (h : N ≤ M) :
    Function.Surjective (QuotientGroup.map N M (MonoidHom.id G) (by simpa using h)) := by
  intro x
  induction x using QuotientGroup.induction_on with
  | H g => exact ⟨QuotientGroup.mk g, by simp⟩

/-- **Theorem A: Abelianization Controls Prime Phase Visibility**.

    For any finite group G and prime p:
      `PrimePhaseVisible G p ↔ GroupHasPTorsion (Abelianization G) p`

    **Forward**: Given N ⊇ [G,G] with G/N having p-torsion, the quotient map
    G/[G,G] →* G/N is surjective. By Lagrange, p | |G/N| | |G^ab|.
    By Cauchy, G^ab has an element of order p.

    **Backward**: Take N = [G,G]. -/
theorem primePhaseVisible_iff_abelianization
    (G : Type*) [Group G] [Finite G] (p : ℕ) [hp : Fact p.Prime] :
    PrimePhaseVisible G p ↔ GroupHasPTorsion (Abelianization G) p := by
  constructor
  · -- Forward direction: uses multi-step divisibility chain
    rintro ⟨N, hNnorm, hcomm, g, hg_ne, hg_pow⟩
    haveI := hNnorm
    -- Step 1: G/N has p-torsion, so p | |G/N|
    have hp_dvd_GN : p ∣ Nat.card (G ⧸ N) :=
      prime_dvd_natcard_of_torsion p ⟨g, hg_ne, hg_pow⟩
    -- Step 2: G^ab surjects onto G/N (since [G,G] ≤ N), so |G/N| | |G^ab|
    have hcard_dvd : Nat.card (G ⧸ N) ∣ Nat.card (Abelianization G) :=
      nat_card_dvd_of_surjective_hom
        (QuotientGroup.map (commutator G) N (MonoidHom.id G) (by simpa using hcomm))
        (quotient_map_surjective (commutator G) N hcomm)
    -- Step 3: therefore p | |G^ab|, and by Cauchy G^ab has p-torsion
    exact torsion_of_prime_dvd_natcard p (dvd_trans hp_dvd_GN hcard_dvd)
  · -- Backward: take N = [G,G]
    rintro ⟨x, hx_ne, hx_pow⟩
    exact ⟨commutator G, inferInstance, le_refl _, x, hx_ne, hx_pow⟩

/-! ## Section 4: Invariance Under Abelianization Isomorphisms (Theorem B) -/

/-- **Theorem B**: Isomorphic abelianizations ⟹ identical phase visibility.
    The proof reduces to Theorem A and transports torsion across the isomorphism. -/
theorem primePhaseVisible_iff_of_abelianization_iso
    (G₁ G₂ : Type*) [Group G₁] [Finite G₁] [Group G₂] [Finite G₂]
    (e : Abelianization G₁ ≃* Abelianization G₂)
    (p : ℕ) [Fact p.Prime] :
    PrimePhaseVisible G₁ p ↔ PrimePhaseVisible G₂ p := by
  rw [primePhaseVisible_iff_abelianization, primePhaseVisible_iff_abelianization]
  exact groupHasPTorsion_of_mulEquiv e p

/-- **Profile-level Theorem B**: Isomorphic abelianizations give identical arithmetic
    phase profiles. Uses `by_cases` on primality. -/
theorem arithmeticPhaseProfile_eq_of_abelianization_iso
    (G₁ G₂ : Type*) [Group G₁] [Finite G₁] [Group G₂] [Finite G₂]
    (e : Abelianization G₁ ≃* Abelianization G₂) :
    arithmeticPhaseProfile G₁ = arithmeticPhaseProfile G₂ := by
  ext p
  simp only [arithmeticPhaseProfile, Set.mem_setOf_eq]
  constructor
  · rintro ⟨hpp, hv⟩
    refine ⟨hpp, ?_⟩
    haveI : Fact p.Prime := ⟨hpp⟩
    exact (primePhaseVisible_iff_of_abelianization_iso G₁ G₂ e p).mp hv
  · rintro ⟨hpp, hv⟩
    refine ⟨hpp, ?_⟩
    haveI : Fact p.Prime := ⟨hpp⟩
    exact (primePhaseVisible_iff_of_abelianization_iso G₁ G₂ e p).mpr hv

/-! ## Section 5: Cross-Domain Bridge — Product Decomposition -/

/-
**Cross-Domain Bridge**: Phase profile of a product is the union of factor profiles.

    Proves `PrimePhaseVisible (G × H) p ↔ PrimePhaseVisible G p ∨ PrimePhaseVisible H p`
    by reducing to abelianization torsion and using the fact that
    `Abelianization (G × H) ≃* Abelianization G × Abelianization H`.
-/
theorem primePhaseVisible_prod_iff
    (G H : Type*) [Group G] [Finite G] [Group H] [Finite H]
    (p : ℕ) [Fact p.Prime] :
    PrimePhaseVisible (G × H) p ↔
      PrimePhaseVisible G p ∨ PrimePhaseVisible H p := by
  rw [primePhaseVisible_iff_abelianization, primePhaseVisible_iff_abelianization,
      primePhaseVisible_iff_abelianization]
  -- We need to show that the abelianization of a product is the product of the abelianizations.
  have h_abelianization_prod : Abelianization (G × H) ≃* (Abelianization G) × (Abelianization H) := by
    -- Define the map from the abelianization of the product to the product of the abelianizations.
    have h_map : ∃ (f : Abelianization (G × H) →* Abelianization G × Abelianization H), Function.Bijective f := by
      have h_map : ∃ (f : Abelianization (G × H) →* Abelianization G × Abelianization H), ∀ (g : G) (h : H), f (Abelianization.of (g, h)) = (Abelianization.of g, Abelianization.of h) := by
        refine' ⟨ _, _ ⟩;
        refine' Abelianization.lift _;
        exact MonoidHom.prod ( Abelianization.of.comp ( MonoidHom.fst G H ) ) ( Abelianization.of.comp ( MonoidHom.snd G H ) );
        aesop;
      obtain ⟨ f, hf ⟩ := h_map;
      refine' ⟨ f, _, _ ⟩;
      · have h_card : Nat.card (Abelianization (G × H)) = Nat.card (Abelianization G × Abelianization H) := by
          have h_card : Nat.card (Abelianization (G × H)) = Nat.card (G × H) / Nat.card (commutator (G × H)) := by
            have := Subgroup.card_eq_card_quotient_mul_card_subgroup ( commutator ( G × H ) );
            rw [ this, Nat.mul_div_cancel _ ( Nat.card_pos ) ];
            grind
          have h_card_G : Nat.card (Abelianization G) = Nat.card G / Nat.card (commutator G) := by
            have := Subgroup.card_eq_card_quotient_mul_card_subgroup ( commutator G );
            rw [ this, Nat.mul_div_cancel _ ( Nat.card_pos ) ];
            grind +extAll
          have h_card_H : Nat.card (Abelianization H) = Nat.card H / Nat.card (commutator H) := by
            have := Subgroup.card_eq_card_quotient_mul_card_subgroup ( _root_.commutator H );
            rw [ this, Nat.mul_div_cancel _ ( Nat.card_pos ) ];
            grind
          simp_all +decide [ Nat.card_prod ];
          have h_card_comm : Nat.card (commutator (G × H)) = Nat.card (commutator G) * Nat.card (commutator H) := by
            have h_card_comm : _root_.commutator (G × H) = Subgroup.prod (_root_.commutator G) (_root_.commutator H) := by
              refine' le_antisymm _ _;
              · simp +decide [ _root_.commutator_def, Subgroup.commutator_def ];
                rintro _ ⟨ a, b, c, d, rfl ⟩ ; exact ⟨ Subgroup.subset_closure ⟨ a, c, rfl ⟩, Subgroup.subset_closure ⟨ b, d, rfl ⟩ ⟩ ;
              · simp +decide [ Subgroup.prod_le_iff, _root_.commutator_def ];
                simp +decide [ Subgroup.map_commutator ];
                exact ⟨ Subgroup.commutator_mono le_top le_top, Subgroup.commutator_mono le_top le_top ⟩;
            rw [ h_card_comm, Nat.card_congr ];
            convert Nat.card_prod _ _;
            exact ⟨ fun x => ⟨ ⟨ x.val.1, x.prop.1 ⟩, ⟨ x.val.2, x.prop.2 ⟩ ⟩, fun x => ⟨ ⟨ x.1.val, x.2.val ⟩, x.1.prop, x.2.prop ⟩, fun x => rfl, fun x => rfl ⟩;
          rw [ h_card_comm, Nat.div_mul_div_comm ];
          · convert Subgroup.card_subgroup_dvd_card ( commutator G );
          · exact Subgroup.card_subgroup_dvd_card _;
        have h_card : Function.Surjective f := by
          intro x;
          obtain ⟨g, hg⟩ : ∃ g : G, Abelianization.of g = x.1 := by
            exact QuotientGroup.mk_surjective x.1
          obtain ⟨h, hh⟩ : ∃ h : H, Abelianization.of h = x.2 := by
            exact QuotientGroup.mk_surjective x.2
          use Abelianization.of (g, h)
          simp [hf, hg, hh];
        haveI := Fintype.ofFinite ( Abelianization ( G × H ) ) ; haveI := Fintype.ofFinite ( Abelianization G × Abelianization H ) ; exact ( Fintype.bijective_iff_surjective_and_card f ).mpr ⟨ by assumption, by aesop ⟩ |>.1;
      · intro x;
        rcases x with ⟨ x, y ⟩;
        induction x using Quotient.inductionOn' ; induction y using Quotient.inductionOn' ; aesop;
    exact MulEquiv.ofBijective h_map.choose h_map.choose_spec;
  convert groupHasPTorsion_of_mulEquiv h_abelianization_prod p |> Iff.trans <| groupHasPTorsion_prod_iff p using 1

/-! ## Section 6: Abelian Groups Are Phase-Transparent -/

/-- For commutative groups, phase visibility = group torsion. -/
theorem primePhaseVisible_comm_iff
    (G : Type*) [CommGroup G] [Finite G] (p : ℕ) [Fact p.Prime] :
    PrimePhaseVisible G p ↔ GroupHasPTorsion G p := by
  rw [primePhaseVisible_iff_abelianization]
  exact groupHasPTorsion_of_mulEquiv Abelianization.equivOfComm.symm p

/-! ## Section 7: Concrete Computations -/

/-
`Multiplicative (ZMod n)` has p-torsion iff p ∣ n, for prime p and n ≥ 2.
    Uses `by_contra` and multi-step divisibility.
-/
theorem groupHasPTorsion_multiplicative_zmod
    (n : ℕ) (hn : 2 ≤ n) (p : ℕ) [hp : Fact p.Prime] :
    GroupHasPTorsion (Multiplicative (ZMod n)) p ↔ p ∣ n := by
  constructor <;> intro h;
  · convert prime_dvd_natcard_of_torsion p h;
    · cases n <;> aesop;
    · cases n <;> [ tauto; infer_instance ];
  · -- If $p \mid n$, write $n = p \cdot k$ for some $k \geq 1$.
    obtain ⟨k, hk⟩ : ∃ k, n = p * k := h
    have hk_pos : 1 ≤ k := by
      nlinarith [ hp.1.two_le ];
    -- Consider the element $a = k$ in $\mathbb{Z}/n\mathbb{Z}$.
    use Multiplicative.ofAdd (k : ZMod n);
    simp +decide [ ← ofAdd_nsmul, hk ];
    rw [ ZMod.natCast_eq_zero_iff ];
    exact ⟨ Nat.not_dvd_of_pos_of_lt hk_pos ( by nlinarith [ hp.1.two_le ] ), by rw [ ← Nat.cast_mul, hk, ZMod.natCast_self ] ⟩

#print axioms primePhaseVisible_iff_abelianization
#print axioms primePhaseVisible_iff_of_abelianization_iso
#print axioms arithmeticPhaseProfile_eq_of_abelianization_iso
#print axioms primePhaseVisible_comm_iff
#print axioms groupHasPTorsion_prod_iff
#print axioms groupHasPTorsion_of_mulEquiv