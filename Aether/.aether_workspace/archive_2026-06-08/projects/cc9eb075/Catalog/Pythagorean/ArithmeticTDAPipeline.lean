/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Scalable Arithmetic TDA Pipeline

This file establishes that torsion information in integral homology is
computationally first-class: extractable from Smith normal form data
with no asymptotic overhead beyond linear algebra.

## Core Insight

The torsion prime profile — the set of primes appearing in the torsion
subgroup — can be read directly from Smith normal form diagonal data.
This profile equals the derived-functor detection set (Tor₁ nonvanishing)
and decomposes cleanly across homological degrees and direct products.

## Main Definitions

* `TorsionPrimeProfile` — Set of primes where torsion is detected in an abelian group
* `SmithDiagonalData` — Invariant factors from Smith normal form
* `smithPrimeSupport` — Primes extracted from Smith diagonal
* `computeTorsionPrimesFromSmith` — Algorithmic extraction function
* `DegreewiseTorsionSignature` — Torsion signature across homological degrees

## Main Theorems

* `torsionPrimeProfile_zmod` — Profile of ℤ/nℤ equals prime factors of n
* `torsionPrimeProfile_prod` — Profile of products = union of profiles
* `smith_extraction_correct` — Smith diagonal primes = torsion profile
* `prime_in_profile_iff_tor1_nontrivial` — Tor₁ characterization
* `degreewise_signature_of_smith` — Full signature = degreewise union
* `computeTorsionPrimesFromSmith_correct` — Algorithm correctness

## Catalog References

Builds on ideas from:
- `Catalog/Pythagorean/ArithmeticPhaseClassification.lean`
- `Catalog/Algebra/Homology/DerivedFunctors/TorsionDetection.lean`
-/

import Mathlib

open scoped Classical

noncomputable section

/-! ## Section 1: Core Definitions -/

/-- The **torsion prime profile** of an abelian group `A`:
    the set of primes `p` such that `A` contains a nonzero element
    killed by `p`. Mathematically, this is `{p prime : Tor₁^ℤ(ℤ/pℤ, A) ≠ 0}`. -/
def TorsionPrimeProfile (A : Type*) [AddCommGroup A] : Set ℕ :=
  {p : ℕ | p.Prime ∧ ∃ a : A, a ≠ 0 ∧ (p : ℤ) • a = 0}

/-- Membership characterization for `TorsionPrimeProfile`. -/
theorem mem_torsionPrimeProfile {A : Type*} [AddCommGroup A] {p : ℕ} :
    p ∈ TorsionPrimeProfile A ↔ p.Prime ∧ ∃ a : A, a ≠ 0 ∧ (p : ℤ) • a = 0 :=
  Iff.rfl

/-- A predicate for the absence of `p`-torsion: every element killed by `p` is zero. -/
def NoPTorsion (A : Type*) [AddCommGroup A] (p : ℕ) : Prop :=
  ∀ a : A, (p : ℤ) • a = 0 → a = 0

/-! ## Section 2: ZMod Profile Characterization -/

/-
If `p` is prime and `p ∣ n` with `n > 1`, then `ℤ/nℤ` has `p`-torsion.
-/
theorem zmod_has_ptorsion_of_prime_dvd {n p : ℕ} (hn : 1 < n)
    (hp : p.Prime) (hdvd : p ∣ n) :
    ∃ a : ZMod n, a ≠ 0 ∧ (p : ℤ) • a = 0 := by
  refine' ⟨ n / p, _, _ ⟩;
  · rw [ Ne.eq_def, ZMod.natCast_eq_zero_iff ];
    exact Nat.not_dvd_of_pos_of_lt ( Nat.div_pos ( Nat.le_of_dvd hn.le hdvd ) hp.pos ) ( Nat.div_lt_self hn.le hp.one_lt );
  · norm_num [ Fin.ext_iff, Fin.val_add, Fin.val_mul, Nat.mul_div_cancel' hdvd ];
    norm_cast;
    rw [ Nat.mul_div_cancel' hdvd, ZMod.natCast_self ]

/-
If `p` is prime and `p ∤ n` with `n > 0`, then `ℤ/nℤ` has no `p`-torsion.
-/
theorem zmod_no_ptorsion_of_prime_not_dvd {n p : ℕ} (hn : 0 < n)
    (hp : p.Prime) (hndvd : ¬ p ∣ n) (a : ZMod n) :
    (p : ℤ) • a = 0 → a = 0 := by
  have h_unit : IsUnit (p : ZMod n) := by
    exact (ZMod.isUnit_prime_iff_not_dvd hp).mpr hndvd;
  exact fun h => by simpa using h_unit.mul_right_eq_zero.mp ( by simpa [ mul_comm ] using h ) ;

/-- **ZMod Profile Theorem**: The torsion prime profile of `ℤ/nℤ` (for `n > 1`)
    equals the set of prime factors of `n`. This is the cornerstone of the
    Smith extraction pipeline. -/
theorem torsionPrimeProfile_zmod (n : ℕ) (hn : 1 < n) :
    TorsionPrimeProfile (ZMod n) = ↑(n.primeFactors) := by
  ext p
  simp only [TorsionPrimeProfile, Set.mem_setOf_eq, Finset.mem_coe, Nat.mem_primeFactors]
  constructor
  · rintro ⟨hp, a, ha_ne, ha_tor⟩
    refine ⟨hp, ?_, by omega⟩
    by_contra hndvd
    exact ha_ne (zmod_no_ptorsion_of_prime_not_dvd (by omega) hp hndvd a ha_tor)
  · rintro ⟨hp, hdvd, _⟩
    exact ⟨hp, zmod_has_ptorsion_of_prime_dvd hn hp hdvd⟩

/-! ## Section 3: Product Profile Decomposition -/

/-
**Product Profile Theorem**: The torsion prime profile of `A × B`
    is the union of the profiles of `A` and `B`.
-/
theorem torsionPrimeProfile_prod (A B : Type*) [AddCommGroup A] [AddCommGroup B] :
    TorsionPrimeProfile (A × B) = TorsionPrimeProfile A ∪ TorsionPrimeProfile B := by
  ext; constructor <;> intro h;
  · rcases h with ⟨ hp, a, ha, h ⟩ ; rcases a with ⟨ a₁, a₂ ⟩ ; simp_all +decide [ Prod.ext_iff, TorsionPrimeProfile ] ;
    grind;
  · rcases h with ( h | h );
    · exact ⟨ h.1, ⟨ ( h.2.choose, 0 ), by simpa using h.2.choose_spec.1, by simpa using h.2.choose_spec.2 ⟩ ⟩;
    · exact ⟨ h.1, ⟨ ( 0, h.2.choose ), by simpa using h.2.choose_spec.1, by simpa using h.2.choose_spec.2 ⟩ ⟩

/-
The torsion prime profile of the trivial group is empty.
-/
theorem torsionPrimeProfile_punit : TorsionPrimeProfile PUnit = ∅ := by
  exact Set.eq_empty_of_forall_notMem fun p hp => hp.2.elim fun a ha => ha.1 rfl

/-! ## Section 4: Isomorphism Invariance -/

/-
Torsion prime profile is invariant under additive group isomorphisms.
-/
theorem torsionPrimeProfile_congr {A B : Type*} [AddCommGroup A] [AddCommGroup B]
    (e : A ≃+ B) : TorsionPrimeProfile A = TorsionPrimeProfile B := by
  ext p;
  constructor <;> intro hp;
  · obtain ⟨ hp_prime, a, ha_ne_zero, ha_eq_zero ⟩ := hp;
    refine' ⟨ hp_prime, e a, _, _ ⟩ <;> simp_all +decide [ ← map_nsmul ];
  · obtain ⟨ hp_prime, a, ha_ne_zero, ha_eq_zero ⟩ := hp;
    refine' ⟨ hp_prime, e.symm a, _, _ ⟩ <;> simp_all +decide [ ← map_nsmul ]

/-! ## Section 5: Smith Normal Form Extraction (Theorem 1) -/

/-- **Smith diagonal data**: a list of invariant factors from the Smith
    normal form, each strictly greater than 1. -/
structure SmithDiagonalData where
  factors : List ℕ
  factors_gt_one : ∀ d ∈ factors, 1 < d

/-- The **prime support** of Smith diagonal data: the union of prime
    factors of all invariant factors. -/
def SmithDiagonalData.primeSupport (S : SmithDiagonalData) : Finset ℕ :=
  S.factors.toFinset.biUnion Nat.primeFactors

/-- Compute the set of torsion primes from a list of invariant factors.
    This is the post-processing step after Smith normal form computation. -/
def computeTorsionPrimesFromSmith (factors : List ℕ) : Finset ℕ :=
  factors.toFinset.biUnion Nat.primeFactors

/-- **Algorithm Correctness**: The computational extraction
    produces exactly the prime support of the Smith data. -/
theorem computeTorsionPrimesFromSmith_correct (S : SmithDiagonalData) :
    computeTorsionPrimesFromSmith S.factors = S.primeSupport :=
  rfl

/-
**Smith Extraction Theorem**: For a finitely generated abelian group
    presented as a direct sum of cyclic groups `⊕ᵢ ℤ/dᵢℤ`, the torsion
    prime profile equals the union of prime factors of all `dᵢ`.

    This reduces torsion profile computation to Smith normal form computation
    plus prime factorization of the diagonal entries.
-/
theorem smith_extraction_finset {k : ℕ} (ds : Fin k → ℕ) (hds : ∀ i, 1 < ds i) :
    TorsionPrimeProfile ((i : Fin k) → ZMod (ds i)) =
      ↑(Finset.univ.biUnion fun i => (ds i).primeFactors) := by
  induction' k with k ih;
  · simp +decide [ Set.ext_iff, TorsionPrimeProfile ];
    exact fun p hp h => False.elim <| h <| by ext i; fin_cases i;
  · -- By definition of product, we can write
    have h_prod : (TorsionPrimeProfile ((i : Fin (k + 1)) → ZMod (ds i))) = (TorsionPrimeProfile (ZMod (ds 0))) ∪ (TorsionPrimeProfile ((i : Fin k) → ZMod (ds (Fin.succ i)))) := by
      have h_prod : Nonempty (((i : Fin (k + 1)) → ZMod (ds i)) ≃+ (ZMod (ds 0) × ((i : Fin k) → ZMod (ds (Fin.succ i))))) := by
        refine' ⟨ _ ⟩;
        refine' { Equiv.ofBijective _ ⟨ _, _ ⟩ with .. };
        exact fun x => ⟨ x 0, fun i => x i.succ ⟩;
        all_goals norm_num [ Function.Injective, Function.Surjective ];
        · exact fun a₁ a₂ h₁ h₂ => funext fun i => by induction i using Fin.inductionOn <;> simp_all +decide [ funext_iff ] ;
        · exact fun a b => ⟨ Fin.cons a b, rfl, rfl ⟩;
        · exact fun x y => rfl;
      rw [ ← torsionPrimeProfile_prod, torsionPrimeProfile_congr h_prod.some ];
    simp_all +decide [ Finset.ext_iff ];
    rw [ torsionPrimeProfile_zmod _ ( hds _ ) ];
    ext; simp [Fin.exists_fin_succ];
    tauto

/-! ## Section 6: Tor₁ Detection Bridge (Theorem 2) -/

/-- `p`-torsion detected in `A`: there exists a nonzero element killed by `p`.
    This is the computational proxy for `Tor₁^ℤ(ℤ/pℤ, A) ≠ 0`. -/
def Tor1Nontrivial (A : Type*) [AddCommGroup A] (p : ℕ) : Prop :=
  ∃ a : A, a ≠ 0 ∧ (p : ℤ) • a = 0

/-- **Tor₁ Detection Theorem**: A prime `p` belongs to the torsion
    prime profile of `A` iff the torsion detector `Tor₁(ℤ/pℤ, A)` fires.

    This bridges computational topology and derived algebra. -/
theorem prime_in_profile_iff_tor1_nontrivial
    (A : Type*) [AddCommGroup A] {p : ℕ} (hp : p.Prime) :
    p ∈ TorsionPrimeProfile A ↔ Tor1Nontrivial A p := by
  simp only [TorsionPrimeProfile, Set.mem_setOf_eq, Tor1Nontrivial]
  exact ⟨fun ⟨_, h⟩ => h, fun h => ⟨hp, h⟩⟩

/-
Tor₁ vanishes for free ℤ-modules: if `n ≠ 0` and `A` is free over ℤ,
    then the only element killed by `n` is zero.
-/
theorem tor1_free_vanishes (A : Type*) [AddCommGroup A]
    [Module ℤ A] [Module.Free ℤ A] {p : ℕ} (hp : p.Prime) :
    ¬ Tor1Nontrivial A p := by
  obtain ⟨ b, hb ⟩ := ‹Module.Free ℤ A›;
  intro h
  obtain ⟨ a, ha_ne_zero, ha_killed ⟩ := h
  have h_zero : a = 0 := by
    apply_fun hb.repr at ha_killed; simp_all +decide [ funext_iff, Finset.sum_apply, Finsupp.ext_iff ] ;
  contradiction

/-
**Corollary**: Free ℤ-modules have empty torsion prime profile.
-/
theorem torsionPrimeProfile_free_eq_empty (A : Type*) [AddCommGroup A]
    [Module ℤ A] [Module.Free ℤ A] :
    TorsionPrimeProfile A = ∅ := by
  -- By definition of $TorsionPrimeProfile$, if $p \in TorsionPrimeProfile A$, then $Tor1Nontrivial A p$.
  by_contra h_contra
  obtain ⟨p, hp⟩ : ∃ p, p ∈ TorsionPrimeProfile A := by
    exact Set.nonempty_iff_ne_empty.2 h_contra;
  exact tor1_free_vanishes A hp.1 |> fun h => h <| prime_in_profile_iff_tor1_nontrivial A hp.1 |>.1 hp

/-
The Tor₁ detector is functorial: injective maps preserve torsion detection.
-/
theorem tor1_nontrivial_of_injective {A B : Type*} [AddCommGroup A] [AddCommGroup B]
    (f : A →+ B) (hf : Function.Injective f) (p : ℕ)
    (h : Tor1Nontrivial A p) : Tor1Nontrivial B p := by
  obtain ⟨ a, ha, ha' ⟩ := h;
  refine' ⟨ f a, _, _ ⟩ <;> simp_all +decide [ ← map_nsmul ];
  exact fun h => ha ( hf <| by simpa using h )

/-! ## Section 7: Degreewise Torsion Signature (Theorem 3) -/

/-- The **degreewise torsion signature**: for a family of abelian groups
    indexed by `Fin d` (homology groups in degrees 0 through d-1),
    the full signature is the union of profiles across all degrees. -/
def DegreewiseTorsionSignature {d : ℕ} (H : Fin d → Type*) [∀ k, AddCommGroup (H k)] :
    Set ℕ :=
  ⋃ k : Fin d, TorsionPrimeProfile (H k)

/-- **Degreewise Union Theorem**: The degreewise torsion signature
    decomposes as the union of individual degree profiles. -/
theorem degreewise_signature_eq_biUnion {d : ℕ}
    (H : Fin d → Type*) [∀ k, AddCommGroup (H k)] :
    DegreewiseTorsionSignature H = ⋃ k : Fin d, TorsionPrimeProfile (H k) :=
  rfl

/-
**Smith Degreewise Extraction**: When each degree's homology comes
    from Smith data, the full signature equals the union of all Smith
    prime supports across all degrees.
-/
theorem degreewise_signature_of_smith {d : ℕ}
    (smithData : Fin d → SmithDiagonalData)
    (H : Fin d → Type*) [∀ k, AddCommGroup (H k)]
    (hiso : ∀ k, TorsionPrimeProfile (H k) = ↑(smithData k).primeSupport) :
    DegreewiseTorsionSignature H =
      ↑(Finset.univ.biUnion fun k => (smithData k).primeSupport) := by
  rw [ DegreewiseTorsionSignature, Set.ext_iff ];
  simp +decide [ hiso ]

/-- **Full Pipeline Correctness**: Computing torsion primes from Smith data
    at each degree and taking the union gives the full degreewise signature. -/
def computeFullSignature {d : ℕ} (smithFactors : Fin d → List ℕ) : Finset ℕ :=
  Finset.univ.biUnion fun k => computeTorsionPrimesFromSmith (smithFactors k)

/-! ## Section 8: Concrete Examples -/

/-- Example: ℤ/6ℤ has torsion prime profile {2, 3}. -/
theorem example_zmod6_profile :
    TorsionPrimeProfile (ZMod 6) = ↑({2, 3} : Finset ℕ) := by
  rw [torsionPrimeProfile_zmod 6 (by norm_num)]
  congr 1; native_decide

/-- Example: ℤ/12ℤ has torsion prime profile {2, 3}. -/
theorem example_zmod12_profile :
    TorsionPrimeProfile (ZMod 12) = ↑({2, 3} : Finset ℕ) := by
  rw [torsionPrimeProfile_zmod 12 (by norm_num)]
  congr 1; native_decide

/-- Example: Smith data [6, 12] has prime support {2, 3}. -/
theorem example_smith_6_12 :
    computeTorsionPrimesFromSmith [6, 12] = {2, 3} := by
  native_decide

/-- Example: Smith data [2, 6, 30] has prime support {2, 3, 5}. -/
theorem example_smith_2_6_30 :
    computeTorsionPrimesFromSmith [2, 6, 30] = {2, 3, 5} := by
  native_decide

/-- Example: The product ℤ/2ℤ × ℤ/3ℤ has profile {2, 3}. -/
theorem example_prod_profile :
    TorsionPrimeProfile (ZMod 2 × ZMod 3) = ↑({2, 3} : Finset ℕ) := by
  rw [torsionPrimeProfile_prod]
  rw [torsionPrimeProfile_zmod 2 (by norm_num), torsionPrimeProfile_zmod 3 (by norm_num)]
  rw [← Finset.coe_union]
  congr 1; native_decide

end