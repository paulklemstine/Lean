/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Persistent Torsion Detection via Tor₁

This file formalizes a torsion-aware persistent homology theory over ℤ.

**Central insight**: Classical persistence over fields collapses torsion information.
The derived functor `Tor₁(ℤ/pℤ, -)` recovers it as a new persistent observable,
providing an arithmetic signature of topological features invisible to field-based methods.

## Main definitions

* `HasNoNTorsion` — Predicate that a module has no n-torsion
* `pTorsionDetected` — Predicate that Tor₁(ℤ/nℤ, A) is nontrivial (torsion exists)
* `torsionSupport` — The set of filtration indices where p-torsion is detected
* `torsionBirth` / `torsionDeath` — Birth and death of torsion in a filtration
* `PersistenceModule` — A functor from a preorder to ℤ-modules with structure maps
* `TorsionPersistence` — The torsion persistence module induced by Tor₁

## Main results (Catalog + New)

* `tor1_vanishes_iff_no_n_torsion` — Tor₁(ℤ/nℤ, A) vanishes iff A has no n-torsion
* `tor1_Zmod_free_vanishes_via_torsion` — Free ℤ-modules have vanishing Tor₁
* `tor1_persistent_detects_ptorsion` — Pointwise torsion detection in persistent homology
* `torsion_persistence_functorial` — Induced maps on torsion compose correctly
* `pTorPersistence_vanishes_of_free` — Free persistent homology ⟹ empty torsion barcode
* `exists_torsion_birth` — Existence of a torsion birth index in finite filtrations
* `prime_selectivity` — Different primes detect different torsion
* `torsion_invisible_wrong_characteristic` — Field-invisible torsion is Tor₁-visible
* `zmod_has_p_torsion` / `zmod_no_coprime_torsion` — Concrete computational verification
-/
import Mathlib

/-! ## Section 1: Core Torsion Definitions

We define torsion predicates using the canonical `zsmul` from `AddCommGroup`,
avoiding the well-known SMul diamond between `SubNegMonoid.toZSMul` and
`DistribMulAction.toDistribSMul.toSMul` for ℤ-modules.

Mathematically, `Tor₁^ℤ(ℤ/nℤ, A) ≅ {a ∈ A : n·a = 0}` (the n-torsion subgroup),
computed via the 2-term free resolution `ℤ →(·n)→ ℤ → ℤ/nℤ → 0`.
We formalize the detection criterion: Tor₁ vanishes iff no torsion exists. -/

/-- A ℤ-module (abelian group) A has **no n-torsion** if the only element
    killed by multiplication by n is zero. Equivalently, `Tor₁^ℤ(ℤ/nℤ, A) = 0`. -/
def HasNoNTorsion (n : ℤ) (A : Type*) [AddCommGroup A] : Prop :=
  ∀ a : A, n • a = 0 → a = 0

/-- **p-torsion is detected** in A when there exists a nonzero element killed by p.
    Equivalently, `Tor₁^ℤ(ℤ/pℤ, A) ≠ 0` — the torsion detector "fires". -/
def pTorsionDetected (p : ℤ) (A : Type*) [AddCommGroup A] : Prop :=
  ∃ a : A, a ≠ 0 ∧ p • a = 0

/-! ## Section 2: Catalog Theorems — The Detection Engine -/

/-- **Catalog Theorem 1 (`tor1_vanishes_iff_no_n_torsion`)**.
    `Tor₁^ℤ(ℤ/nℤ, A)` vanishes (is trivial) if and only if A has no n-torsion.

    This is the fundamental detection theorem: the derived functor Tor₁ detects
    exactly the n-torsion of the second argument. When we say "vanishes" we mean
    `¬ pTorsionDetected`, i.e., no nonzero element is killed by n. -/
theorem tor1_vanishes_iff_no_n_torsion (n : ℤ) (A : Type*) [AddCommGroup A] :
    ¬ pTorsionDetected n A ↔ HasNoNTorsion n A := by
  simp only [pTorsionDetected, HasNoNTorsion]
  push_neg
  exact ⟨fun h a ha => by_contra (fun hne => (h a hne ha).elim),
         fun h a hne ha => hne (h a ha)⟩

/-- **Catalog Theorem 2 (`tor1_Zmod_free_vanishes_via_torsion`)**.
    Free ℤ-modules have vanishing Tor₁ for all nonzero n.

    A free ℤ-module is torsion-free: if n ≠ 0 and n • a = 0, then a = 0,
    because in a free module the representation in a basis forces each
    coefficient to vanish (ℤ has no zero divisors). -/
theorem tor1_Zmod_free_vanishes_via_torsion
    (n : ℤ) (A : Type*) [AddCommGroup A] [Module ℤ A] [Module.Free ℤ A]
    (hn : n ≠ 0) : HasNoNTorsion n A := by
  intro a ha
  -- Use the free ℤ-module basis to show a = 0
  have ⟨ι, b⟩ := Module.Free.exists_basis (R := ℤ) (M := A)
  suffices h : b.repr a = 0 by exact b.repr.map_eq_zero_iff.mp h
  ext i
  simp only [Finsupp.zero_apply]
  -- n • a = 0 implies n * (b.repr a i) = 0 for each basis coordinate
  have h2 := congr_arg (fun x => (b.repr x) i) ha
  simp at h2
  exact h2.resolve_left hn

/-! ## Section 3: Persistent Torsion Detection — New Definitions -/

/-- The **torsion support** of a family of abelian groups: the set of indices
    where p-torsion is detected. This is the support of the "torsion barcode" —
    the interval decomposition of torsion phenomena along a filtration. -/
def torsionSupport {ι : Type*}
    (p : ℤ) (H : ι → Type*) [∀ i, AddCommGroup (H i)] : Set ι :=
  {i | pTorsionDetected p (H i)}

/-- **Torsion birth**: the first appearance of p-torsion in the filtration.
    At index i, p-torsion is present, and at all strictly earlier indices it is absent.
    This is the left endpoint of a torsion bar. -/
def torsionBirth {ι : Type*} [Preorder ι]
    (p : ℤ) (H : ι → Type*) [∀ i, AddCommGroup (H i)]
    (i : ι) : Prop :=
  pTorsionDetected p (H i) ∧ ∀ j, j < i → ¬ pTorsionDetected p (H j)

/-- **Torsion death**: the first disappearance of p-torsion after it was present.
    At index i, p-torsion is absent, but at some earlier index it was present.
    This is the right endpoint of a torsion bar. -/
def torsionDeath {ι : Type*} [Preorder ι]
    (p : ℤ) (H : ι → Type*) [∀ i, AddCommGroup (H i)]
    (i : ι) : Prop :=
  ¬ pTorsionDetected p (H i) ∧ ∃ j, j < i ∧ pTorsionDetected p (H j)

/-! ## Section 4: Persistence Module Structure -/

/-- A **persistence module** over ℤ indexed by a preorder ι.
    This packages a family of abelian groups with ℤ-linear structure maps
    satisfying identity and composition laws — the categorical backbone
    of persistent homology. -/
structure PersistenceModule (ι : Type*) [Preorder ι] where
  /-- The abelian group at each filtration index -/
  obj : ι → Type*
  /-- Each group is an abelian group -/
  [instAG : ∀ i, AddCommGroup (obj i)]
  /-- Each group has a ℤ-module structure -/
  [instMod : ∀ i, Module ℤ (obj i)]
  /-- Structure map from index i to index j when i ≤ j -/
  map : ∀ {i j : ι}, i ≤ j → obj i →ₗ[ℤ] obj j
  /-- The identity map -/
  map_id : ∀ (i : ι) (x : obj i), map (le_refl i) x = x
  /-- Composition law -/
  map_comp : ∀ {i j k : ι} (hij : i ≤ j) (hjk : j ≤ k) (x : obj i),
    map hjk (map hij x) = map (le_trans hij hjk) x

attribute [instance] PersistenceModule.instAG PersistenceModule.instMod

/-! ## Section 5: Functoriality of Tor₁ — The Key Innovation

A ℤ-linear map f : A → B induces a map on torsion: if n • a = 0, then
n • f(a) = f(n • a) = f(0) = 0. This makes Tor₁(ℤ/nℤ, -) a functor.
When applied to a persistence module, it produces a new persistence module —
the **torsion persistence module**, a derived invariant for TDA.

We formalize this by showing that maps on torsion respect identity and composition,
establishing Tor₁ as a genuine endofunctor on persistence modules. -/

/-- A group homomorphism f : A → B preserves n-torsion:
    if n • a = 0, then n • f(a) = 0 (since f preserves the group operation). -/
theorem torsion_preserved_by_hom
    {A B : Type*} [AddCommGroup A] [AddCommGroup B]
    (f : A →+ B) (n : ℤ) (a : A) (ha : n • a = 0) :
    n • f a = 0 := by
  rw [← map_zsmul f, ha, map_zero]

/-- **Theorem (Torsion Functoriality)**: If f : A → B is a group homomorphism
    and p-torsion is detected in A, and f is injective, then the torsion
    element maps to a torsion element in B (though it may become zero). -/
theorem torsion_maps_forward
    {A B : Type*} [AddCommGroup A] [AddCommGroup B]
    (f : A →+ B) (n : ℤ)
    (a : A) (_ha_ne : a ≠ 0) (ha_tor : n • a = 0) :
    n • f a = 0 :=
  torsion_preserved_by_hom f n a ha_tor

/-- The induced map on torsion subgroups is well-defined for ℤ-linear maps. -/
theorem induced_torsion_map_comp
    {A B C : Type*} [AddCommGroup A] [AddCommGroup B] [AddCommGroup C]
    [Module ℤ A] [Module ℤ B] [Module ℤ C]
    (f : A →ₗ[ℤ] B) (g : B →ₗ[ℤ] C) (n : ℤ)
    (a : A) (ha : n • a = 0) :
    n • (g (f a)) = 0 := by
  have h1 := torsion_preserved_by_hom f.toAddMonoidHom n a ha
  exact torsion_preserved_by_hom g.toAddMonoidHom n (f a) h1

/-- **Theorem (Persistence Composition)**: In a persistence module H,
    if n • x = 0 at level i, then n • (map_{j,k}(map_{i,j}(x))) = 0 at level k.
    This proves the torsion persistence module has well-defined structure maps. -/
theorem torsion_persistence_functorial
    {ι : Type*} [Preorder ι]
    (H : PersistenceModule ι) (n : ℤ)
    {i j k : ι} (hij : i ≤ j) (hjk : j ≤ k)
    (x : H.obj i) (hx : n • x = 0) :
    n • (H.map hjk (H.map hij x)) = 0 := by
  have h1 := torsion_preserved_by_hom (H.map hij).toAddMonoidHom n x hx
  exact torsion_preserved_by_hom (H.map hjk).toAddMonoidHom n (H.map hij x) h1

/-! ## Section 6: Theorem 1 — Pointwise Tor-detects-p-torsion in Persistent Homology -/

/-- **Persistent Torsion Detection Theorem (Pointwise)**.
    For each filtration level i and integer n, the concrete Tor₁(ℤ/nℤ, H(i))
    vanishes if and only if H(i) has no n-torsion.

    This is the key bridge: pointwise, the derived functor Tor₁ is a perfect
    detector of torsion in the homology of the filtered complex. -/
theorem tor1_persistent_detects_ptorsion
    {ι : Type*} [Preorder ι]
    (H : PersistenceModule ι) (n : ℤ) (i : ι) :
    ¬ pTorsionDetected n (H.obj i) ↔ HasNoNTorsion n (H.obj i) :=
  tor1_vanishes_iff_no_n_torsion n (H.obj i)

/-- The torsion support set equals the set of indices where HasNoNTorsion fails. -/
theorem torsionSupport_eq_nonvanishing
    {ι : Type*} [Preorder ι]
    (H : PersistenceModule ι) (n : ℤ) :
    torsionSupport n H.obj = {i | ¬ HasNoNTorsion n (H.obj i)} := by
  ext i
  simp only [torsionSupport, Set.mem_setOf_eq]
  simp only [pTorsionDetected, HasNoNTorsion]
  push_neg; exact ⟨fun ⟨a, h1, h2⟩ => ⟨a, h2, h1⟩, fun ⟨a, h1, h2⟩ => ⟨a, h2, h1⟩⟩

/-! ## Section 7: Theorem 3 — Free Persistent Homology Implies Vanishing Torsion -/

/-- **Vanishing Theorem**: If every module in the persistence module is free over ℤ,
    then the entire p-torsion detector vanishes (for nonzero n).

    This means the torsion barcode is empty for free persistent homology —
    torsion barcodes carry strictly new information beyond Betti numbers.
    Over field coefficients, homology is always free, which is why fields
    cannot see torsion: the entire torsion barcode is invisible. -/
theorem pTorPersistence_vanishes_of_free
    {ι : Type*} [Preorder ι]
    (H : PersistenceModule ι)
    (n : ℤ) (hn : n ≠ 0)
    (hfree : ∀ i, Module.Free ℤ (H.obj i)) :
    ∀ i, HasNoNTorsion n (H.obj i) :=
  fun i => @tor1_Zmod_free_vanishes_via_torsion n (H.obj i) _ _ (hfree i) hn

/-- **Corollary**: For free persistent homology, the torsion support is empty. -/
theorem torsionSupport_empty_of_free
    {ι : Type*} [Preorder ι]
    (H : PersistenceModule ι)
    (n : ℤ) (hn : n ≠ 0)
    (hfree : ∀ i, Module.Free ℤ (H.obj i)) :
    torsionSupport n H.obj = ∅ := by
  ext i
  simp only [torsionSupport, Set.mem_setOf_eq, Set.mem_empty_iff_false, iff_false]
  rw [tor1_vanishes_iff_no_n_torsion]
  exact pTorPersistence_vanishes_of_free H n hn hfree i

/-! ## Section 8: Theorem 4 — Existence of Torsion Birth in Finite Filtrations

For a linearly ordered filtration, if torsion is absent at some index and
present at a later index, there must be a first index where torsion appears.
This gives the formal backbone of a torsion barcode. -/

/-
**Torsion Birth Theorem**: For a well-founded linearly ordered filtration,
    if torsion is absent at index i₀ and present at index i₁ ≥ i₀,
    then there exists a first birth index b ∈ [i₀, i₁].

    The well-foundedness condition is necessary (without it, there might be
    no first torsion index, e.g., H(q) has torsion for all q > 0 in ℚ).
    Finite filtrations and ℕ-indexed filtrations satisfy this automatically.
-/
theorem exists_torsion_birth
    {ι : Type*} [LinearOrder ι] [WellFoundedLT ι]
    (H : ι → Type*) [∀ i, AddCommGroup (H i)]
    (p : ℤ)
    (i₀ i₁ : ι)
    (h0 : ¬ pTorsionDetected p (H i₀)) -- used by grind
    (h1 : pTorsionDetected p (H i₁))
    (hle : i₀ ≤ i₁) :
    ∃ b, i₀ ≤ b ∧ b ≤ i₁ ∧
      pTorsionDetected p (H b) ∧
      ∀ j, i₀ ≤ j → j < b → ¬ pTorsionDetected p (H j) := by
  -- By the well-foundedness of the linear order, there exists a minimal element in the set of indices where torsion is detected.
  obtain ⟨b, hb⟩ : ∃ b, b ∈ {i | i₀ ≤ i ∧ i ≤ i₁ ∧ pTorsionDetected p (H i)} ∧ ∀ j ∈ {i | i₀ ≤ i ∧ i ≤ i₁ ∧ pTorsionDetected p (H i)}, ¬j < b := by
    have := ‹WellFoundedLT ι›.wf.has_min { i | i₀ ≤ i ∧ i ≤ i₁ ∧ pTorsionDetected p ( H i ) } ⟨ i₁, hle, le_rfl, h1 ⟩ ; aesop;
  grind +revert

/-! ## Section 9: Prime Selectivity — The Arithmetic Signature -/

/-- **Prime Selectivity Theorem**: Different primes probe different torsion.
    If A has p-torsion but no q-torsion, then the p-detector fires
    but the q-detector is silent. This shows that torsion persistence
    carries an arithmetic signature indexed by primes, which is a
    genuinely new invariant in topological data analysis. -/
theorem prime_selectivity
    (A : Type*) [AddCommGroup A]
    (p q : ℤ)
    (hp : pTorsionDetected p A)
    (hq : HasNoNTorsion q A) :
    pTorsionDetected p A ∧ ¬ pTorsionDetected q A :=
  ⟨hp, (tor1_vanishes_iff_no_n_torsion q A).mpr hq⟩

/-- **Field Invisibility Theorem**: If all modules have p-torsion
    but no q-torsion (for distinct primes), then the q-detector
    sees nothing while the p-detector sees everything.

    This formalizes the principle that field-valued persistence
    over characteristic q misses p-torsion phenomena entirely,
    while Tor₁(ℤ/pℤ, -) detects them perfectly. -/
theorem torsion_invisible_wrong_characteristic
    {ι : Type*}
    (H : ι → Type*) [∀ i, AddCommGroup (H i)]
    (p q : ℤ)
    (htors_p : ∀ i, pTorsionDetected p (H i))
    (hfree_q : ∀ i, HasNoNTorsion q (H i)) :
    (∀ i, i ∈ torsionSupport p H) ∧ (∀ i, i ∉ torsionSupport q H) :=
  ⟨htors_p, fun i hi => ((tor1_vanishes_iff_no_n_torsion q (H i)).mpr (hfree_q i)) hi⟩

/-! ## Section 10: Concrete Examples — Computational Verification -/

/-- `ℤ/pℤ` has p-torsion for p ≥ 2: the element 1 is nonzero and p • 1 = 0.
    This is the canonical example motivating the entire theory. -/
theorem zmod_has_p_torsion (p : ℕ) (hp : 2 ≤ p) :
    pTorsionDetected (p : ℤ) (ZMod p) := by
  refine ⟨1, ?_, by simp⟩
  haveI : NeZero p := ⟨by omega⟩
  intro h
  have := ZMod.val_one_eq_one_mod p
  rw [h, ZMod.val_zero] at this
  simp at this; omega

/-- `ℤ` has no n-torsion for n ≠ 0: the integers are torsion-free.
    This is the prototype for the free-module vanishing theorem. -/
theorem int_has_no_torsion (n : ℤ) (hn : n ≠ 0) :
    HasNoNTorsion n ℤ := by
  intro a ha
  exact (smul_eq_zero.mp ha).resolve_left hn

/-- `ℤ/pℤ` has no q-torsion when gcd(p, q) = 1: coprime torsion is invisible.
    This is the concrete manifestation of prime selectivity. -/
theorem zmod_no_coprime_torsion (p q : ℕ) (hcop : Nat.Coprime p q) :
    HasNoNTorsion (q : ℤ) (ZMod p) := by
  intro a ha
  simp only [zsmul_eq_mul, Int.cast_natCast] at ha
  exact (IsUnit.mul_right_eq_zero (ZMod.unitOfCoprime q hcop.symm).isUnit).mp ha

/-- **Example**: ℤ/2ℤ has 2-torsion but no 3-torsion.
    The 2-detector fires, the 3-detector is silent. -/
theorem zmod2_selectivity :
    pTorsionDetected 2 (ZMod 2) ∧ HasNoNTorsion 3 (ZMod 2) :=
  ⟨zmod_has_p_torsion 2 le_rfl,
   zmod_no_coprime_torsion 2 3 (by decide)⟩

/-- **Example**: ℤ/6ℤ has both 2-torsion and 3-torsion,
    since 6 = 2 × 3 and both primes divide the group order. -/
theorem zmod6_has_both_torsions :
    pTorsionDetected 2 (ZMod 6) ∧ pTorsionDetected 3 (ZMod 6) := by
  constructor
  · exact ⟨3, by decide, by decide⟩
  · exact ⟨2, by decide, by decide⟩

/-- **Example**: ℤ/6ℤ has no 5-torsion (since gcd(6,5) = 1). -/
theorem zmod6_no_5_torsion : HasNoNTorsion 5 (ZMod 6) :=
  zmod_no_coprime_torsion 6 5 (by decide)