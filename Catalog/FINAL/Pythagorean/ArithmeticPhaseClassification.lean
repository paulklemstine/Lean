/-
# Non-Abelian Arithmetic Phase Classification

This file formalizes a classification principle for arithmetic phase detection in
finite groups. The central result is that prime-level torsion information
detectable by any homomorphism into an abelian group is completely controlled by
the abelianization.

## Main definitions

* `HasPTorsion` — A group has p-torsion if it contains an element of order exactly p.
* `PrimeHomologicalPhaseVisible` — A prime p is "homologically phase-visible" for a
  group G if there exists a commutative group A and a group homomorphism G →* A
  whose image contains an element of order p.
* `arithmeticPhaseProfile` — The set of primes visible through homological probes.

## Main results

* `primePhaseVisible_iff_hasPTorsion_abelianization` — Prime phase visibility through
  any abelian probe is equivalent to the abelianization having p-torsion.
* `arithmeticPhaseProfile_eq_of_abelianization_equiv` — Groups with isomorphic
  abelianizations have identical arithmetic phase profiles.
* `primePhaseVisible_prod_iff` — Phase visibility for products decomposes as a
  disjunction (phase-union law).
-/

import Mathlib

open scoped Classical

universe u

/-! ## Core definitions -/

/-- A group has p-torsion if it contains an element of order exactly `p`. -/
def HasPTorsion (A : Type*) [Group A] (p : ℕ) : Prop :=
  ∃ (a : A), orderOf a = p

/-- A prime `p` is *homologically phase-visible* for a group `G` if there exists a
commutative group `A` and a group homomorphism `f : G →* A` such that the image of `f`
contains an element of order `p`.

This captures the notion that `p` is detectable by abelian/additive/homological probes:
any such probe factors through the abelianization by the universal property. -/
def PrimeHomologicalPhaseVisible (G : Type u) [Group G] (p : ℕ) : Prop :=
  ∃ (A : Type u) (_ : CommGroup A) (f : G →* A) (a : A),
    a ∈ f.range ∧ orderOf a = p

/-- The *arithmetic phase profile* of a group is the set of primes that are
homologically phase-visible. -/
def arithmeticPhaseProfile (G : Type u) [Group G] : Set ℕ :=
  {p | Nat.Prime p ∧ PrimeHomologicalPhaseVisible G p}

/-- The torsion profile of a commutative group: the set of primes `p` for which the
group has `p`-torsion. -/
def arithmeticPhaseProfileOfAbelianGroup (A : Type*) [CommGroup A] : Set ℕ :=
  {p | Nat.Prime p ∧ HasPTorsion A p}

/-! ## Basic lemmas about HasPTorsion -/

/-- Transport of p-torsion across a group isomorphism. -/
theorem HasPTorsion.of_mulEquiv {A B : Type*} [Group A] [Group B]
    (e : A ≃* B) {p : ℕ} (h : HasPTorsion A p) : HasPTorsion B p := by
  obtain ⟨a, ha⟩ := h
  exact ⟨e a, by rw [MulEquiv.orderOf_eq e a, ha]⟩

/-- p-torsion is preserved by group isomorphisms (iff version). -/
theorem hasPTorsion_iff_of_mulEquiv {A B : Type*} [Group A] [Group B]
    (e : A ≃* B) (p : ℕ) : HasPTorsion A p ↔ HasPTorsion B p :=
  ⟨HasPTorsion.of_mulEquiv e, HasPTorsion.of_mulEquiv e.symm⟩

/-- The abelianization map is surjective. -/
theorem abelianization_of_surjective (G : Type*) [Group G] :
    Function.Surjective (Abelianization.of (G := G)) :=
  fun x => Quotient.inductionOn x (fun g => ⟨g, rfl⟩)

/-- The factorization property: `Abelianization.lift f` composed with `of` equals `f`. -/
theorem abelianization_lift_of_apply {G : Type*} [Group G] {A : Type*} [CommGroup A]
    (f : G →* A) (g : G) :
    (Abelianization.lift f) (Abelianization.of g) = f g :=
  congr_fun (congr_arg DFunLike.coe (Abelianization.lift.left_inv f)) g

/-! ## Helper lemma: extracting prime-order elements -/

/-- If `p` is prime and divides the order of an element in a group, then the group
has `p`-torsion. -/
theorem exists_orderOf_eq_prime_of_dvd {A : Type*} [Group A] {a : A} {p : ℕ}
    (hdvd : p ∣ orderOf a) (hne : orderOf a ≠ 0) :
    HasPTorsion A p :=
  ⟨a ^ (orderOf a / p), orderOf_pow_orderOf_div hne hdvd⟩

/-! ## Main Theorem A: Phase visibility ↔ abelianization torsion -/

/-- **Theorem A (Abelianization Controls Prime Phase Visibility).**
A prime `p` is homologically phase-visible for a finite group `G` if and only if
the abelianization `G^ab` has `p`-torsion.

The proof uses:
1. **Forward direction**: Any homomorphism `f : G →* A` with `A` abelian factors through
   `G^ab` via the universal property. If the image has an element of order `p`, then by
   `orderOf_map_dvd` the preimage element in `G^ab` has order divisible by `p`, and we
   extract an element of order exactly `p`.
2. **Backward direction**: Take the abelianization map itself as the probe. -/
theorem primePhaseVisible_iff_hasPTorsion_abelianization
    (G : Type u) [Group G] [Finite G] (p : ℕ) (_hp : Nat.Prime p) :
    PrimeHomologicalPhaseVisible G p ↔
      HasPTorsion (Abelianization G) p := by
  constructor
  · -- Forward: any abelian probe factors through abelianization
    rintro ⟨A, hA, f, a, ha_mem, ha_ord⟩
    obtain ⟨g, hg⟩ := ha_mem
    -- a = f g, and lift f (of g) = f g
    have key : (Abelianization.lift f) (Abelianization.of g) = a := by
      rw [abelianization_lift_of_apply, hg]
    rw [← key] at ha_ord
    -- orderOf(of g) is divisible by p
    have hdvd : p ∣ orderOf (Abelianization.of g) := by
      rw [← ha_ord]
      exact orderOf_map_dvd (Abelianization.lift f) (Abelianization.of g)
    exact exists_orderOf_eq_prime_of_dvd hdvd ((orderOf_pos (Abelianization.of g)).ne')
  · -- Backward: use the abelianization map as the probe
    rintro ⟨a, ha⟩
    obtain ⟨g, hg⟩ := abelianization_of_surjective G a
    exact ⟨Abelianization G, inferInstance, Abelianization.of, a, ⟨g, hg⟩, ha⟩

/-! ## Theorem B: Isomorphic abelianizations ⟹ identical phase profiles -/

/-- **Theorem B (Phase Profile Invariance Under Abelianization Isomorphism).**
If two finite groups have isomorphic abelianizations, then they have identical
arithmetic phase profiles. -/
theorem arithmeticPhaseProfile_eq_of_abelianization_equiv
    (G₁ : Type u) (G₂ : Type u) [Group G₁] [Finite G₁] [Group G₂] [Finite G₂]
    (e : Abelianization G₁ ≃* Abelianization G₂) :
    arithmeticPhaseProfile G₁ = arithmeticPhaseProfile G₂ := by
  ext p
  simp only [arithmeticPhaseProfile, Set.mem_setOf_eq]
  constructor <;> intro ⟨hpp, hv⟩
  · exact ⟨hpp, by
      rw [primePhaseVisible_iff_hasPTorsion_abelianization _ _ hpp] at hv ⊢
      exact (hasPTorsion_iff_of_mulEquiv e p).mp hv⟩
  · exact ⟨hpp, by
      rw [primePhaseVisible_iff_hasPTorsion_abelianization _ _ hpp] at hv ⊢
      exact (hasPTorsion_iff_of_mulEquiv e p).mpr hv⟩

/-! ## Product theorem: Phase-union law -/

/-
p-torsion in a product iff p-torsion in a factor (for prime p).
-/
theorem hasPTorsion_prod_iff {A B : Type*} [Group A] [Group B] (p : ℕ)
    (hp : Nat.Prime p) :
    HasPTorsion (A × B) p ↔ HasPTorsion A p ∨ HasPTorsion B p := by
  constructor <;> intro h;
  · obtain ⟨ x, hx ⟩ := h;
    -- By definition of order in a product group, we have that `orderOf x = Nat.lcm (orderOf x.1) (orderOf x.2)`.
    have h_order : Nat.lcm (orderOf x.1) (orderOf x.2) = p := by
      convert hx using 1
      exact Eq.symm (Prod.orderOf x)
    have := Nat.dvd_lcm_left ( orderOf x.1 ) ( orderOf x.2 ) ; ( have := Nat.dvd_lcm_right ( orderOf x.1 ) ( orderOf x.2 ) ; simp_all +decide [ Nat.dvd_prime hp ] ; );
    cases ‹x.1 = 1 ∨ orderOf x.1 = p› <;> cases ‹x.2 = 1 ∨ orderOf x.2 = p› <;> simp_all +decide [ HasPTorsion ];
    · exact absurd h_order.symm hp.ne_one;
    · exact Or.inr ⟨ x.2, by assumption ⟩;
    · exact Or.inl ⟨ x.1, by assumption ⟩;
    · exact Or.inl ⟨ x.1, by assumption ⟩;
  · rcases h with ( ⟨ a, ha ⟩ | ⟨ b, hb ⟩ );
    · refine' ⟨ ⟨ a, 1 ⟩, _ ⟩;
      simp +decide [ ← ha, orderOf_eq_orderOf_iff ];
    · refine' ⟨ ⟨ 1, b ⟩, _ ⟩;
      simp +decide [ ← hb, orderOf_eq_orderOf_iff ]

/-- The abelianization of a product is isomorphic to the product of abelianizations.
This is the group-theoretic Künneth decomposition for H₁. -/
noncomputable def abelianizationProdEquiv (G H : Type*) [Group G] [Group H] :
    Abelianization (G × H) ≃* Abelianization G × Abelianization H := by
  let fwd : G × H →* Abelianization G × Abelianization H :=
    MonoidHom.prod
      (Abelianization.of.comp (MonoidHom.fst G H))
      (Abelianization.of.comp (MonoidHom.snd G H))
  let bwdG : G →* Abelianization (G × H) :=
    Abelianization.of.comp (MonoidHom.inl G H)
  let bwdH : H →* Abelianization (G × H) :=
    Abelianization.of.comp (MonoidHom.inr G H)
  let F := Abelianization.lift fwd
  let B := MonoidHom.coprod (Abelianization.lift bwdG) (Abelianization.lift bwdH)
  refine MonoidHom.toMulEquiv F B ?_ ?_
  · apply Abelianization.hom_ext
    ext ⟨g, h⟩
    simp only [MonoidHom.comp_apply, MonoidHom.id_apply, F, B]
    rw [abelianization_lift_of_apply]
    simp only [fwd, MonoidHom.prod_apply, MonoidHom.comp_apply]
    simp only [MonoidHom.coprod_apply]
    rw [abelianization_lift_of_apply, abelianization_lift_of_apply]
    simp only [bwdG, bwdH, MonoidHom.comp_apply]
    rw [← map_mul]
    congr 1; ext <;> simp
  · ext ⟨a, b⟩
    · show (F (B (a, b))).1 = a
      induction a using Quotient.inductionOn with
      | h g =>
        induction b using Quotient.inductionOn with
        | h h =>
          change (F (B (Abelianization.of g, Abelianization.of h))).1 = Abelianization.of g
          simp only [B, MonoidHom.coprod_apply, F]
          rw [abelianization_lift_of_apply, abelianization_lift_of_apply]
          simp only [bwdG, bwdH, MonoidHom.comp_apply]
          rw [map_mul, abelianization_lift_of_apply, abelianization_lift_of_apply]
          simp [fwd, MonoidHom.prod_apply]
    · show (F (B (a, b))).2 = b
      induction a using Quotient.inductionOn with
      | h g =>
        induction b using Quotient.inductionOn with
        | h h =>
          change (F (B (Abelianization.of g, Abelianization.of h))).2 = Abelianization.of h
          simp only [B, MonoidHom.coprod_apply, F]
          rw [abelianization_lift_of_apply, abelianization_lift_of_apply]
          simp only [bwdG, bwdH, MonoidHom.comp_apply]
          rw [map_mul, abelianization_lift_of_apply, abelianization_lift_of_apply]
          simp [fwd, MonoidHom.prod_apply]

/-- **Phase-Union Law for Products.**
The arithmetic phase profile of a direct product `G × H` at a prime `p` decomposes as
the disjunction of the profiles of `G` and `H`. -/
theorem primePhaseVisible_prod_iff
    (G H : Type u) [Group G] [Finite G] [Group H] [Finite H]
    (p : ℕ) (hp : Nat.Prime p) :
    PrimeHomologicalPhaseVisible (G × H) p ↔
      PrimeHomologicalPhaseVisible G p ∨ PrimeHomologicalPhaseVisible H p := by
  rw [primePhaseVisible_iff_hasPTorsion_abelianization _ _ hp,
      primePhaseVisible_iff_hasPTorsion_abelianization G _ hp,
      primePhaseVisible_iff_hasPTorsion_abelianization H _ hp]
  rw [hasPTorsion_iff_of_mulEquiv (abelianizationProdEquiv G H) p]
  exact hasPTorsion_prod_iff p hp

/-! ## Profile equality theorem -/

/-- The arithmetic phase profile equals the torsion profile of the abelianization. -/
theorem arithmeticPhaseProfile_eq_abelianization_profile
    (G : Type u) [Group G] [Finite G] :
    arithmeticPhaseProfile G =
      arithmeticPhaseProfileOfAbelianGroup (Abelianization G) := by
  ext p
  simp only [arithmeticPhaseProfile, arithmeticPhaseProfileOfAbelianGroup, Set.mem_setOf_eq]
  constructor <;> intro ⟨hpp, hv⟩
  · exact ⟨hpp, (primePhaseVisible_iff_hasPTorsion_abelianization G p hpp).mp hv⟩
  · exact ⟨hpp, (primePhaseVisible_iff_hasPTorsion_abelianization G p hpp).mpr hv⟩

/-! ## Torsion detection: wrong characteristic invisibility -/

/-
If `p` does not divide the order of a finite group `A`, then `A` has no
`p`-torsion. This is the "wrong characteristic invisibility" principle.
-/
theorem torsion_invisible_wrong_characteristic
    (A : Type*) [CommGroup A] [Fintype A] (p : ℕ) (_hp : Nat.Prime p)
    (hnd : ¬ (p ∣ Fintype.card A)) :
    ¬ HasPTorsion A p := by
  exact fun h => hnd <| h.choose_spec.symm ▸ orderOf_dvd_card

/-
The `ZMod n` group (viewed multiplicatively) has `p`-torsion iff `p ∣ n`,
for prime `p` and positive `n`.
-/
theorem HasPTorsion_ZMod_iff_dvd (n : ℕ) (hn : n ≠ 0) (p : ℕ) (hp : Nat.Prime p) :
    HasPTorsion (Multiplicative (ZMod n)) p ↔ p ∣ n := by
  constructor <;> intro h;
  · cases n <;> simp_all +decide [ HasPTorsion ];
    exact h.choose_spec ▸ addOrderOf_dvd_card.trans ( by simp +decide );
  · convert exists_prime_orderOf_dvd_card ( p := p ) _;
    all_goals cases n <;> simp_all +decide [ ZMod ];
    exacts [ inferInstance, False.elim <| hn rfl, by simpa [ Fintype.card_fin ] using h ]