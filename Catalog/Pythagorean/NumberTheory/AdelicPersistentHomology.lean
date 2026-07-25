/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Adelic Persistent Homology

This file formalizes the theory of **adelic torsion persistence** for filtered finite
abelian groups. The central insight is that the torsion barcode of a filtered
finite abelian group decomposes canonically by prime, and this decomposition admits
an adelic packaging with reconstruction and uniqueness properties.

## Main definitions

* `IsPPrimary` — An element is p-primary if killed by some power of p
* `pPrimaryComponent` — The p-primary subgroup
* `pPrimaryNontrivial` — The p-primary component is nontrivial
* `torsionPrimeSupportSet` — Primes with nontrivial p-primary part
* `AdelicTorsionDatum` — Adelic packaging of prime-indexed persistence data
* `reconstructTorsionSupport` — Recovers global support from adelic data
* `adelicTorsionDatum` — The canonical adelic datum for a filtration
* `nTorsionSubgroup` — The n-torsion subgroup {a | n • a = 0}

## Main results

* `map_preserves_pPrimary` — Homomorphisms preserve p-primary torsion (Thm 1)
* `adelic_reconstruction_correct_set` — Adelic reconstruction is exact (Thm 2)
* `adelic_reconstruction_unique` — Reconstruction is unique on supports (Thm 2b)
* `bounded_torsion_implies_bounded_primeSupport` — Bounded torsion → bounded support (Thm 3)
* `persistence_CRT_decomposition` — CRT splitting of torsion persistence (Thm 4)

## References

* Builds on `Catalog.Algebra.Homology.DerivedFunctors.TorsionDetection`
* Builds on `Catalog.Pythagorean.ArithmeticPhaseClassification`
-/

import Mathlib

set_option maxHeartbeats 800000

open scoped Classical

/-! ## Section 1: p-Primary Torsion Components -/

/-- An element `a` of an additive abelian group is **p-primary** if
`p^k • a = 0` for some natural number `k`. -/
def IsPPrimary (p : ℕ) {A : Type*} [AddCommGroup A] (a : A) : Prop :=
  ∃ k : ℕ, (p ^ k) • a = 0

/-- The **p-primary component** of an additive abelian group:
the subgroup of all elements killed by some power of `p`. -/
def pPrimaryComponent (p : ℕ) (A : Type*) [AddCommGroup A] : AddSubgroup A where
  carrier := {a | IsPPrimary p a}
  zero_mem' := ⟨0, by simp⟩
  add_mem' := by
    rintro a b ⟨ka, hka⟩ ⟨kb, hkb⟩
    refine ⟨ka + kb, ?_⟩
    have h1 : (p ^ (ka + kb)) • a = 0 := by
      have : p ^ (ka + kb) = p ^ kb * p ^ ka := by ring
      rw [this, mul_smul, hka, smul_zero]
    have h2 : (p ^ (ka + kb)) • b = 0 := by
      have : p ^ (ka + kb) = p ^ ka * p ^ kb := by ring
      rw [this, mul_smul, hkb, smul_zero]
    rw [smul_add, h1, h2, add_zero]
  neg_mem' := by
    rintro a ⟨k, hk⟩
    exact ⟨k, by rw [smul_neg, hk, neg_zero]⟩

/-- Predicate: the p-primary component of A is nontrivial. -/
def pPrimaryNontrivial (p : ℕ) (A : Type*) [AddCommGroup A] : Prop :=
  ∃ a : A, a ≠ 0 ∧ IsPPrimary p a

/-! ## Section 2: Torsion Prime Support -/

/-- The **torsion prime support** of a finite abelian group:
the set of primes `p` for which the p-primary component is nontrivial. -/
def torsionPrimeSupportSet (A : Type*) [AddCommGroup A] : Set ℕ :=
  {p | Nat.Prime p ∧ pPrimaryNontrivial p A}

/-- The torsion prime support of a filtration at each level. -/
def filtrationPrimeSupport {n : ℕ} (F : Fin (n + 1) → Type*)
    [∀ i, AddCommGroup (F i)] : Fin (n + 1) → Set ℕ :=
  fun i => torsionPrimeSupportSet (F i)

/-! ## Section 3: Functoriality — Homomorphisms Preserve p-Primary Torsion -/

/-- **Theorem 1a: Group homomorphisms preserve p-primary elements.** -/
theorem map_preserves_pPrimary {A B : Type*} [AddCommGroup A] [AddCommGroup B]
    (f : A →+ B) (p : ℕ) (a : A) (ha : IsPPrimary p a) :
    IsPPrimary p (f a) := by
  obtain ⟨k, hk⟩ := ha
  exact ⟨k, by rw [← map_nsmul f, hk, map_zero]⟩

/-- The image of the p-primary component under a homomorphism. -/
theorem pPrimaryComponent_map {A B : Type*} [AddCommGroup A] [AddCommGroup B]
    (f : A →+ B) (p : ℕ) (a : A) (ha : a ∈ pPrimaryComponent p A) :
    f a ∈ pPrimaryComponent p B :=
  map_preserves_pPrimary f p a ha

/-- **Theorem 1b: Injective homomorphisms reflect p-primary nontriviality.** -/
theorem pPrimaryNontrivial_of_injective {A B : Type*}
    [AddCommGroup A] [AddCommGroup B]
    (f : A →+ B) (hf : Function.Injective f) (p : ℕ)
    (h : pPrimaryNontrivial p A) : pPrimaryNontrivial p B := by
  obtain ⟨a, ha_ne, ha_pp⟩ := h
  exact ⟨f a, fun h => ha_ne (hf (h.trans (map_zero f).symm)),
         map_preserves_pPrimary f p a ha_pp⟩

/-! ## Section 4: Adelic Torsion Datum -/

/-- The **adelic torsion datum** for a filtered abelian group.
This is a novel structure packaging prime-indexed persistence data
with a finite-support condition — an "adelic" object. -/
structure AdelicTorsionDatum (n : ℕ) where
  /-- For each prime and filtration index, whether p-primary torsion is present -/
  localSupport : ℕ → Fin (n + 1) → Prop
  /-- Only primes contribute -/
  prime_only : ∀ p i, localSupport p i → Nat.Prime p
  /-- At each level, only finitely many primes contribute -/
  finite_support : ∀ i, Set.Finite {p | localSupport p i}

/-- **Reconstruct** the global torsion support from an adelic datum. -/
def reconstructTorsionSupport {n : ℕ} (D : AdelicTorsionDatum n) :
    Fin (n + 1) → Set ℕ :=
  fun i => {p | D.localSupport p i}

/-! ## Section 5: Finiteness of Torsion Prime Support -/

/-- The torsion prime support of a finite group is finite. -/
theorem torsionPrimeSupportSet_finite (A : Type*) [AddCommGroup A] [Fintype A] :
    Set.Finite (torsionPrimeSupportSet A) := by
  apply Set.Finite.subset (Fintype.card A).primeFactors.finite_toSet
  intro p ⟨hp, a, ha_ne, k, hk⟩
  rw [Finset.mem_coe, Nat.mem_primeFactors]
  refine ⟨hp, ?_, Fintype.card_pos.ne'⟩
  have h_dvd_pk : addOrderOf a ∣ p ^ k := addOrderOf_dvd_iff_nsmul_eq_zero.mpr hk
  have h_dvd_card : addOrderOf a ∣ Fintype.card A := addOrderOf_dvd_card
  have h_ne_one : addOrderOf a ≠ 1 := by
    intro heq
    exact ha_ne (by simpa [heq] using addOrderOf_nsmul_eq_zero a)
  obtain ⟨q, hq_prime, hq_dvd⟩ := Nat.exists_prime_and_dvd h_ne_one
  have hqp : q = p :=
    (Nat.Prime.eq_one_or_self_of_dvd hp q
      (Nat.Prime.dvd_of_dvd_pow hq_prime (dvd_trans hq_dvd h_dvd_pk))).resolve_left
      hq_prime.ne_one
  exact dvd_trans (hqp ▸ hq_dvd) h_dvd_card

/-! ## Section 6: Construction of the Canonical Adelic Datum -/

/-- Construct the **canonical adelic torsion datum** from a filtration. -/
noncomputable def adelicTorsionDatum {n : ℕ} (F : Fin (n + 1) → Type*)
    [∀ i, AddCommGroup (F i)] [∀ i, Fintype (F i)] :
    AdelicTorsionDatum n where
  localSupport p i := Nat.Prime p ∧ pPrimaryNontrivial p (F i)
  prime_only _ _ h := h.1
  finite_support i := Set.Finite.subset (torsionPrimeSupportSet_finite (F i)) (fun _ h => h)

/-! ## Section 7: Adelic Reconstruction Theorems -/

/-- **Theorem 2a (Adelic Reconstruction): The canonical adelic datum
reconstructs the torsion prime support exactly.** -/
theorem adelic_reconstruction_correct_set {n : ℕ}
    (F : Fin (n + 1) → Type*)
    [∀ i, AddCommGroup (F i)] [∀ i, Fintype (F i)] :
    ∀ i, reconstructTorsionSupport (adelicTorsionDatum F) i =
      torsionPrimeSupportSet (F i) := by
  intro i
  ext p
  simp [reconstructTorsionSupport, adelicTorsionDatum, torsionPrimeSupportSet]

/-- **Theorem 2b (Uniqueness): Two adelic data with the same local supports
produce identical reconstructions.** -/
theorem adelic_reconstruction_unique {n : ℕ}
    {D₁ D₂ : AdelicTorsionDatum n}
    (h : ∀ p i, D₁.localSupport p i ↔ D₂.localSupport p i) :
    ∀ i, reconstructTorsionSupport D₁ i = reconstructTorsionSupport D₂ i := by
  intro i; ext p; exact h p i

/-- **Main Existence Theorem: Adelic reconstruction exists.** -/
theorem exists_adelic_reconstruction {n : ℕ}
    (F : Fin (n + 1) → Type*)
    [∀ i, AddCommGroup (F i)] [∀ i, Fintype (F i)] :
    ∃ D : AdelicTorsionDatum n,
      ∀ i, reconstructTorsionSupport D i = torsionPrimeSupportSet (F i) :=
  ⟨adelicTorsionDatum F, adelic_reconstruction_correct_set F⟩

/-! ## Section 8: Bounded Support Criterion -/

/-- A filtration has **bounded prime support**. -/
def HasBoundedPrimeSupport {n : ℕ} (F : Fin (n + 1) → Type*)
    [∀ i, AddCommGroup (F i)] : Prop :=
  ∃ S : Finset ℕ, ∀ i p, p ∈ torsionPrimeSupportSet (F i) → p ∈ S

/-- A filtration has **bounded torsion** (uniform exponent). -/
def HasBoundedTorsion {n : ℕ} (F : Fin (n + 1) → Type*)
    [∀ i, AddCommGroup (F i)] : Prop :=
  ∃ B : ℕ, 0 < B ∧ ∀ i (a : F i), (B : ℤ) • a = 0

/-- **Theorem 3: Bounded torsion implies bounded prime support.** -/
theorem bounded_torsion_implies_bounded_primeSupport {n : ℕ}
    (F : Fin (n + 1) → Type*)
    [∀ i, AddCommGroup (F i)] [∀ i, Fintype (F i)]
    (hbdd : HasBoundedTorsion F) :
    HasBoundedPrimeSupport F := by
  obtain ⟨B, hB_pos, hB⟩ := hbdd
  refine ⟨B.primeFactors, ?_⟩
  intro i p ⟨hp_prime, a, ha_ne, k, hk⟩
  rw [Nat.mem_primeFactors]
  refine ⟨hp_prime, ?_, by omega⟩
  by_contra h_not_dvd
  have hcop : Nat.Coprime p B := (Nat.Prime.coprime_iff_not_dvd hp_prime).mpr h_not_dvd
  have hcop_pk : Nat.Coprime (p ^ k) B := Nat.Coprime.pow_left k hcop
  -- Bezout: ∃ α β : ℤ with p^k * α + B * β = 1
  have hbez : ∃ α β : ℤ, ↑(p ^ k) * α + ↑B * β = 1 :=
    ⟨Nat.gcdA (p^k) B, Nat.gcdB (p^k) B, by
      rw [← Nat.gcd_eq_gcd_ab]; simp [hcop_pk]⟩
  obtain ⟨α, β, hαβ⟩ := hbez
  apply ha_ne
  have h1 : (1 : ℤ) • a = a := one_smul ℤ a
  rw [← h1, ← hαβ, add_smul, mul_smul, mul_smul]
  have h_first : (↑(p ^ k) : ℤ) • α • a = 0 := by
    rw [← mul_smul, mul_comm, mul_smul]
    have h_cast : (↑(p ^ k) : ℤ) • a = (p ^ k : ℕ) • a := by
      rw [← natCast_zsmul]
    rw [h_cast, hk, smul_zero]
  have h_second : (↑B : ℤ) • β • a = 0 := by
    rw [← mul_smul, mul_comm, mul_smul, hB i a, smul_zero]
  rw [h_first, zero_add, h_second]

/-
Every finite filtration has bounded torsion.
-/
theorem finite_filtration_has_bounded_torsion {n : ℕ}
    (F : Fin (n + 1) → Type*)
    [∀ i, AddCommGroup (F i)] [∀ i, Fintype (F i)] :
    HasBoundedTorsion F := by
      refine' ⟨ ∏ i, Fintype.card ( F i ), Finset.prod_pos fun i _ => Fintype.card_pos, fun i a => _ ⟩;
      -- By definition of exponentiation in the group, we have that $(∏ j, Fintype.card (F j)) • a = 0$ because $Fintype.card (F i)$ divides the product.
      have h_card_div : (Fintype.card (F i)) ∣ (∏ j, Fintype.card (F j)) := by
        exact Finset.dvd_prod_of_mem _ ( Finset.mem_univ _ );
      obtain ⟨ k, hk ⟩ := h_card_div; simp +decide [ hk, mul_smul ] ;

/-- **Corollary: Every finite filtration has bounded prime support.** -/
theorem finite_filtration_has_bounded_primeSupport {n : ℕ}
    (F : Fin (n + 1) → Type*)
    [∀ i, AddCommGroup (F i)] [∀ i, Fintype (F i)] :
    HasBoundedPrimeSupport F :=
  bounded_torsion_implies_bounded_primeSupport F (finite_filtration_has_bounded_torsion F)

/-! ## Section 9: n-Torsion Subgroups and CRT -/

/-- The **n-torsion subgroup**: elements killed by n. -/
def nTorsionSubgroup (m : ℕ) (A : Type*) [AddCommGroup A] : AddSubgroup A where
  carrier := {a | (m : ℤ) • a = 0}
  zero_mem' := by simp
  add_mem' {a b} ha hb := by
    show (m : ℤ) • (a + b) = 0; rw [smul_add, ha, hb, add_zero]
  neg_mem' {a} ha := by
    show (m : ℤ) • (-a) = 0; rw [smul_neg, ha, neg_zero]

/-
**Theorem 4 (CRT Persistence): For coprime m and k, every mk-torsion
element decomposes as a sum of an m-torsion and a k-torsion element.**
-/
theorem persistence_CRT_decomposition {A : Type*} [AddCommGroup A]
    {m k : ℕ} (hcop : Nat.Coprime m k) (a : A)
    (ha : a ∈ nTorsionSubgroup (m * k) A) :
    ∃ b c, b ∈ nTorsionSubgroup m A ∧ c ∈ nTorsionSubgroup k A ∧ a = b + c := by
      obtain ⟨b, c, hb, hc, habc⟩ : ∃ b c : A, (m : ℤ) • b = 0 ∧ (k : ℤ) • c = 0 ∧ a = b + c := by
        obtain ⟨u, v, huv⟩ : ∃ u v : ℤ, m * u + k * v = 1 := by
          have := Nat.gcd_eq_gcd_ab m k; aesop;
        refine' ⟨ k • v • a, m • u • a, _, _, _ ⟩ <;> simp_all +decide [ mul_assoc, mul_left_comm, mul_comm ];
        · simp_all +decide [ ← smul_assoc, nTorsionSubgroup ];
          convert congr_arg ( fun x => v • x ) ha using 1 <;> simp +decide [ mul_assoc, mul_comm, mul_left_comm, smul_smul ];
        · have := ha.symm; simp_all +decide [ mul_comm, mul_assoc, mul_left_comm, ← smul_assoc ] ;
          rw [ mul_smul, this.symm, smul_zero ];
        · convert congr_arg ( fun x : ℤ => x • a ) huv.symm using 1 ; simp +decide [ mul_comm, mul_assoc, mul_left_comm, add_smul ];
          simp +decide [ add_smul, mul_comm, mul_assoc, mul_left_comm, ← smul_assoc ];
          exact add_comm _ _;
      exact ⟨ b, c, hb, hc, habc ⟩

/-- Group homomorphisms preserve the n-torsion subgroup. -/
theorem map_nTorsion {A B : Type*} [AddCommGroup A] [AddCommGroup B]
    (f : A →+ B) (m : ℕ) (a : A) (ha : a ∈ nTorsionSubgroup m A) :
    f a ∈ nTorsionSubgroup m B := by
  show (↑m : ℤ) • f a = 0
  have ha' : (↑m : ℤ) • a = 0 := ha
  rw [← map_zsmul f, ha', map_zero]

/-- **CRT persistence functoriality**: CRT decomposition commutes with maps. -/
theorem CRT_persistence_functorial {A B : Type*} [AddCommGroup A] [AddCommGroup B]
    (f : A →+ B) {m k : ℕ} (a : A)
    (hb : ∃ b c, b ∈ nTorsionSubgroup m A ∧ c ∈ nTorsionSubgroup k A ∧ a = b + c) :
    ∃ b' c', b' ∈ nTorsionSubgroup m B ∧ c' ∈ nTorsionSubgroup k B ∧ f a = b' + c' := by
  obtain ⟨b, c, hb_mem, hc_mem, hab⟩ := hb
  exact ⟨f b, f c, map_nTorsion f m b hb_mem, map_nTorsion f k c hc_mem,
         by rw [hab, map_add]⟩

/-! ## Section 10: Concrete Examples -/

/-- ℤ/6ℤ has nontrivial 2-primary component: 3 has order 2. -/
theorem Z6_has_2primary : pPrimaryNontrivial 2 (ZMod 6) :=
  ⟨3, by decide, 1, by decide⟩

/-- ℤ/6ℤ has nontrivial 3-primary component: 2 has order 3. -/
theorem Z6_has_3primary : pPrimaryNontrivial 3 (ZMod 6) :=
  ⟨2, by decide, 1, by decide⟩

/-- ℤ/3ℤ has 3-primary torsion. -/
theorem Z3_has_3primary : pPrimaryNontrivial 3 (ZMod 3) :=
  ⟨1, by decide, 1, by decide⟩

/-
ℤ/3ℤ has no 2-primary torsion: gcd(2^k, 3)=1 for all k,
so addOrderOf divides both 3 and 2^k, hence equals 1.
-/
theorem Z3_no_2primary : ¬ pPrimaryNontrivial 2 (ZMod 3) := by
  rintro ⟨ a, ha, ⟨ k, hk ⟩ ⟩;
  fin_cases a <;> simp_all +decide

/-- The trivial group has no p-primary torsion. -/
theorem trivial_no_primary (p : ℕ) : ¬ pPrimaryNontrivial p (Fin 1) := by
  rintro ⟨a, ha_ne, _⟩
  exact ha_ne (Subsingleton.elim a 0)

/-- **Worked example**: The 3-level filtration `0 → ℤ/3ℤ → ℤ/6ℤ`:
Level 0 (Fin 1): no prime support
Level 1 (ℤ/3ℤ): prime support = {3}
Level 2 (ℤ/6ℤ): prime support = {2, 3} -/
theorem Z6_filtration_primeSupports :
    ¬ pPrimaryNontrivial 2 (Fin 1) ∧
    ¬ pPrimaryNontrivial 3 (Fin 1) ∧
    ¬ pPrimaryNontrivial 2 (ZMod 3) ∧
    pPrimaryNontrivial 3 (ZMod 3) ∧
    pPrimaryNontrivial 2 (ZMod 6) ∧
    pPrimaryNontrivial 3 (ZMod 6) :=
  ⟨trivial_no_primary 2, trivial_no_primary 3, Z3_no_2primary,
   Z3_has_3primary, Z6_has_2primary, Z6_has_3primary⟩

/-! ## Section 11: Persistence Module Structure -/

/-- A **finite persistence module** indexed by `Fin (n+1)`. -/
structure FinPersistenceModule (n : ℕ) where
  obj : Fin (n + 1) → Type*
  [instAG : ∀ i, AddCommGroup (obj i)]
  [instFin : ∀ i, Fintype (obj i)]
  map : ∀ {i j : Fin (n + 1)}, i ≤ j → obj i →+ obj j

attribute [instance] FinPersistenceModule.instAG FinPersistenceModule.instFin

/-- Structure maps preserve p-primary components. -/
theorem persistence_preserves_pPrimary {n : ℕ} (M : FinPersistenceModule n)
    (p : ℕ) {i j : Fin (n + 1)} (hij : i ≤ j) (a : M.obj i)
    (ha : a ∈ pPrimaryComponent p (M.obj i)) :
    M.map hij a ∈ pPrimaryComponent p (M.obj j) :=
  pPrimaryComponent_map (M.map hij) p a ha

/-- The adelic datum of a persistence module reconstructs its support. -/
theorem persistence_adelic_reconstruction {n : ℕ}
    (M : FinPersistenceModule n) :
    ∀ i, reconstructTorsionSupport (adelicTorsionDatum M.obj) i =
      torsionPrimeSupportSet (M.obj i) :=
  adelic_reconstruction_correct_set M.obj

/-! ## Section 12: Adelic Extensionality -/

/-- Two persistence modules with the same local prime data have the
same global torsion support — the "local determines global" principle. -/
theorem same_local_same_global {n : ℕ}
    (M₁ M₂ : FinPersistenceModule n)
    (h : ∀ p i, pPrimaryNontrivial p (M₁.obj i) ↔ pPrimaryNontrivial p (M₂.obj i)) :
    ∀ i, torsionPrimeSupportSet (M₁.obj i) = torsionPrimeSupportSet (M₂.obj i) := by
  intro i; ext p
  simp only [torsionPrimeSupportSet, Set.mem_setOf_eq]
  exact ⟨fun ⟨hp, h1⟩ => ⟨hp, (h p i).mp h1⟩, fun ⟨hp, h2⟩ => ⟨hp, (h p i).mpr h2⟩⟩

/-- **Adelic extensionality**: two data agree on reconstruction iff
they have the same local supports. -/
theorem adelic_extensionality {n : ℕ}
    (D₁ D₂ : AdelicTorsionDatum n) :
    (∀ p i, D₁.localSupport p i ↔ D₂.localSupport p i) ↔
    (∀ i, reconstructTorsionSupport D₁ i = reconstructTorsionSupport D₂ i) := by
  constructor
  · exact adelic_reconstruction_unique
  · intro h p i
    have := congr_arg (p ∈ ·) (h i)
    simpa [reconstructTorsionSupport] using this

/-! ## Section 13: Grand Theorem -/

/-- **Grand Theorem: Full adelic torsion persistence equivalence.**
For any filtration of finite abelian groups:
1. There exists a canonical adelic torsion datum
2. It reconstructs the torsion prime support exactly
3. The reconstruction is unique among data with the same local supports
4. The prime support is always bounded -/
theorem adelic_torsion_persistence_equivalence {n : ℕ}
    (F : Fin (n + 1) → Type*)
    [∀ i, AddCommGroup (F i)] [∀ i, Fintype (F i)] :
    (∃ D : AdelicTorsionDatum n,
      ∀ i, reconstructTorsionSupport D i = torsionPrimeSupportSet (F i)) ∧
    (∀ i, Set.Finite (torsionPrimeSupportSet (F i))) ∧
    HasBoundedPrimeSupport F :=
  ⟨exists_adelic_reconstruction F,
   fun i => torsionPrimeSupportSet_finite (F i),
   finite_filtration_has_bounded_primeSupport F⟩

/-! ## Section 14: Connection to Catalog -/

/-
The catalog's `pTorsionDetected p A` (∃ a ≠ 0, p • a = 0)
is equivalent to `pPrimaryNontrivial p A` for prime p.
-/
theorem catalog_connection
    {A : Type*} [AddCommGroup A] {p : ℕ} (hp : Nat.Prime p) :
    (∃ a : A, a ≠ 0 ∧ (p : ℤ) • a = 0) ↔ pPrimaryNontrivial p A := by
      constructor <;> intro h;
      · exact ⟨ h.choose, h.choose_spec.1, ⟨ 1, by simpa using h.choose_spec.2 ⟩ ⟩;
      · obtain ⟨ a, ha, k, hk ⟩ := h;
        induction' k with k ih generalizing a;
        · aesop;
        · by_cases h : p ^ k • a = 0 <;> simp_all +decide [ pow_succ', mul_assoc, smul_smul ];
          · exact ih a ha h;
          · exact ⟨ p ^ k • a, h, by simpa [ mul_comm, smul_smul ] using hk ⟩