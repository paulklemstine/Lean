/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Primewise Birth Spectra Distinguish Filtrations

This file establishes that the **primewise torsion-birth spectrum** is a strictly finer
invariant than the undifferentiated global torsion-birth set. We work with a finite
combinatorial model of birth profiles, where each filtration level carries a finite set
of torsion orders. The main result exhibits two profiles with identical global birth sets
but distinct primewise birth spectra — proving that primary decomposition leaves a
detectable chronological signature in filtrations.

## Main definitions

* `FiniteBirthProfile` — A finite model of a filtration's torsion data
* `globalTorsionBirthSet` — Levels where some nontrivial torsion order is born
* `pTorsionBirthSet` — Levels where some torsion order divisible by `p` is born
* `primewiseBirthSpectrum` — The full function `p ↦ pTorsionBirthSet p F`
* `distinguishingPairs` — Algorithmic search for separating profile pairs

## Main results

* `mem_global_iff_exists_prime_mem_pTorsion` — The iff characterization bridging
  global and primewise birth sets via prime divisors
* `global_eq_of_primewise_eq` — Equal primewise spectra imply equal global birth sets
* `exists_same_global_different_primewise` — Separation: same global, different primewise
* `primewise_strictly_finer_than_global` — The primewise spectrum is strictly finer
* `explicit_primewise_separation` — Fully explicit witness with computed birth sets
* `mem_distinguishingPairs_sound` — Soundness of the search algorithm

## Cross-domain significance

The separation theorem demonstrates that **primewise chronology is mathematically visible
and irreducible**. In the language of persistent homology, two filtered spaces can exhibit
identical coarse "torsion appears at these times" patterns yet differ in the prime
decomposition of that torsion — analogous to two signals with identical time-domain
support but different frequency content. This opens the door to prime-resolved persistent
invariants, arithmetic persistence barcodes, and spectral signatures for filtered
algebraic objects.

### Application domains
- **Persistent torsion** in topological data analysis
- **Primary decomposition** of filtered abelian groups
- **Spectral signatures** and arithmetic invariants
- **Information loss** in algebraic signal processing
- **Prime-sensitive persistence** barcodes
-/
import Mathlib

/-! ## Section 1: Core Definitions -/

/-- A **finite birth profile** records torsion orders born at each level of a filtration
    with finitely many levels. This is the minimal combinatorial model capturing the
    torsion-birth data of a filtered abelian group. -/
structure FiniteBirthProfile where
  /-- The maximum filtration level (levels are `0, 1, ..., maxLevel`). -/
  maxLevel : ℕ
  /-- The finite set of torsion orders born at each level. -/
  ordersAt : Fin (maxLevel + 1) → Finset ℕ

/-- The **global torsion birth set**: the set of filtration levels at which some
    nontrivial torsion order (i.e., an order `m > 1`) is born.
    This is the coarsest torsion-timing invariant. -/
def globalTorsionBirthSet (F : FiniteBirthProfile) : Finset ℕ :=
  (Finset.univ.filter (fun i : Fin (F.maxLevel + 1) =>
    ∃ m ∈ F.ordersAt i, m > 1)).image Fin.val

/-- The **p-torsion birth set**: the set of filtration levels at which some nontrivial
    torsion order divisible by `p` is born. This refines the global birth set by
    resolving torsion along the prime spectrum. -/
def pTorsionBirthSet (p : ℕ) (F : FiniteBirthProfile) : Finset ℕ :=
  (Finset.univ.filter (fun i : Fin (F.maxLevel + 1) =>
    ∃ m ∈ F.ordersAt i, m > 1 ∧ p ∣ m)).image Fin.val

/-- The **primewise birth spectrum**: the complete prime-resolved invariant,
    sending each natural number `p` to the set of levels where `p`-divisible
    torsion is born. This is the filtration-level analogue of primary decomposition
    and constitutes our new mathematical object. -/
def primewiseBirthSpectrum (F : FiniteBirthProfile) : ℕ → Finset ℕ :=
  fun p => pTorsionBirthSet p F

/-! ## Section 2: Explicit Witness Profiles -/

/-- **Profile F**: torsion order 2 born at level 1, torsion order 6 born at level 3.
    Represents a filtration where 2-torsion appears first, then 6-torsion (carrying
    both 2-primary and 3-primary components) appears later. -/
def F_witness : FiniteBirthProfile where
  maxLevel := 3
  ordersAt i := if i.val = 1 then {2} else if i.val = 3 then {6} else ∅

/-- **Profile G**: torsion order 3 born at level 1, torsion order 6 born at level 3.
    Represents a filtration where 3-torsion appears first, then 6-torsion appears later.
    Has the same global birth set as F but a different primewise spectrum. -/
def G_witness : FiniteBirthProfile where
  maxLevel := 3
  ordersAt i := if i.val = 1 then {3} else if i.val = 3 then {6} else ∅

/-! ## Section 3: Theorem 1 — The Primewise-to-Global Bridge (Iff Characterization)

This theorem establishes the fundamental bridge between the global and primewise
birth sets: a level belongs to the global birth set if and only if it belongs to
some primewise birth set for a prime `p`. The forward direction uses the existence
of prime divisors for integers > 1 (connecting to the catalog theorem
`mem_globalTorsionBirthSet_implies_exists_prime`); the reverse direction is immediate.

This is deeper than the catalog theorem because it establishes an equivalence, not
just one direction, in our finite model. -/

theorem mem_global_iff_exists_prime_mem_pTorsion
    (F : FiniteBirthProfile) (n : ℕ) :
    n ∈ globalTorsionBirthSet F ↔
      ∃ p : ℕ, Nat.Prime p ∧ n ∈ pTorsionBirthSet p F := by
  -- By definition of `globalTorsionBirthSet`, we know that `n ∈ globalTorsionBirthSet F` if and only if there exists a level `i` such that `n = i.val` and there exists an `m ∈ F.ordersAt i` with `m > 1`.
  simp [globalTorsionBirthSet, pTorsionBirthSet];
  exact ⟨ fun ⟨ a, ha, hn ⟩ ↦ ⟨ Nat.minFac ( Classical.choose ha ), Nat.minFac_prime ( by linarith [ Classical.choose_spec ha ] ), a, ⟨ Classical.choose ha, Classical.choose_spec ha |>.1, Classical.choose_spec ha |>.2, Nat.minFac_dvd _ ⟩, hn ⟩, by rintro ⟨ p, hp, a, ⟨ m, hm₁, hm₂, hm₃ ⟩, hn ⟩ ; exact ⟨ a, ⟨ m, hm₁, hm₂ ⟩, hn ⟩ ⟩

/-! ## Section 4: Theorem 2 — Primewise Equality Implies Global Equality

If two profiles have identical primewise birth sets for every prime, then
they have identical global birth sets. This shows the global invariant is a
**quotient** of the primewise spectrum — it factors through the primewise data.
The proof proceeds by extensionality using the iff characterization above. -/

theorem global_eq_of_primewise_eq
    {F G : FiniteBirthProfile}
    (h : ∀ p : ℕ, Nat.Prime p → pTorsionBirthSet p F = pTorsionBirthSet p G) :
    globalTorsionBirthSet F = globalTorsionBirthSet G := by
  ext n; simp_all +decide [ Finset.ext_iff ] ;
  convert mem_global_iff_exists_prime_mem_pTorsion F n using 1 ; convert mem_global_iff_exists_prime_mem_pTorsion G n using 1 ; aesop;

/-! ## Section 5: Theorem 3 — The Separation Theorem

The centerpiece: there exist profiles with identical global birth sets but
different primewise birth spectra. This proves that primewise chronology is
a **strict refinement** of global chronology — primary decomposition carries
temporal information that the global invariant discards. -/

theorem exists_same_global_different_primewise :
    ∃ F G : FiniteBirthProfile,
      globalTorsionBirthSet F = globalTorsionBirthSet G ∧
      ∃ p : ℕ, Nat.Prime p ∧ pTorsionBirthSet p F ≠ pTorsionBirthSet p G := by
  -- Use F_witness and G_witness.
  refine ⟨F_witness, G_witness, ?_, 2, by norm_num, ?_⟩ <;> norm_cast at *

/-! ## Section 6: Theorem 4 — Strictness of Refinement

The direct logical consequence of the separation theorem: the primewise
spectrum is not determined by the global birth set. Equivalently, the
converse of `global_eq_of_primewise_eq` is false. -/

theorem primewise_strictly_finer_than_global :
    ¬ ∀ F G : FiniteBirthProfile,
        globalTorsionBirthSet F = globalTorsionBirthSet G →
        ∀ p : ℕ, Nat.Prime p → pTorsionBirthSet p F = pTorsionBirthSet p G := by
  push_neg;
  -- Apply the theorem `exists_same_global_different_primewise` to obtain the required profiles.
  apply exists_same_global_different_primewise

/-! ## Section 7: Explicit Witness Computation

The fully explicit version: computes all six birth sets for the witness pair
and verifies exact equality with the predicted values. -/

theorem explicit_primewise_separation :
    globalTorsionBirthSet F_witness = {1, 3} ∧
    globalTorsionBirthSet G_witness = {1, 3} ∧
    pTorsionBirthSet 2 F_witness = {1, 3} ∧
    pTorsionBirthSet 3 F_witness = {3} ∧
    pTorsionBirthSet 2 G_witness = {3} ∧
    pTorsionBirthSet 3 G_witness = {1, 3} := by
  native_decide +revert

/-! ## Section 8: Verified Search Algorithm

A decision procedure that, given a list of candidate profiles and a list of
primes to test, returns all pairs with equal global birth sets but differing
primewise birth sets for some tested prime. The soundness theorem ensures
every returned pair is a genuine separating example. -/

/-- Search for pairs of profiles with equal global but differing primewise birth sets. -/
def distinguishingPairs
    (profiles : List FiniteBirthProfile)
    (primes : List ℕ) :
    List (FiniteBirthProfile × FiniteBirthProfile × ℕ) :=
  (profiles.flatMap fun F =>
    (profiles.flatMap fun G =>
      (primes.filterMap fun p =>
        if globalTorsionBirthSet F = globalTorsionBirthSet G ∧
           pTorsionBirthSet p F ≠ pTorsionBirthSet p G
        then some (F, G, p)
        else none)))

/-
**Soundness**: every triple returned by `distinguishingPairs` is a genuine
    separating example — the two profiles share a global birth set but differ
    on the primewise birth set for the returned prime.
-/
theorem mem_distinguishingPairs_sound
    {profiles : List FiniteBirthProfile} {primes : List ℕ}
    {F G : FiniteBirthProfile} {p : ℕ}
    (hmem : (F, G, p) ∈ distinguishingPairs profiles primes) :
    globalTorsionBirthSet F = globalTorsionBirthSet G ∧
    p ∈ primes ∧
    pTorsionBirthSet p F ≠ pTorsionBirthSet p G := by
  unfold distinguishingPairs at hmem; aesop;

/-! ## Section 9: Auxiliary Results -/

/-
The p-torsion birth set is always a subset of the global torsion birth set.
-/
theorem pTorsionBirthSet_subset_global (p : ℕ) (hp : Nat.Prime p)
    (F : FiniteBirthProfile) :
    pTorsionBirthSet p F ⊆ globalTorsionBirthSet F := by
  intro x hx; exact ( mem_global_iff_exists_prime_mem_pTorsion F x ).mpr ⟨ p, hp, hx ⟩ ;

/-
The global birth set decomposes as a finite union of primewise birth sets
    over any sufficiently large set of primes.
-/
theorem global_eq_biUnion_primewise (F : FiniteBirthProfile)
    (primes : Finset ℕ)
    (hprimes : ∀ i : Fin (F.maxLevel + 1), ∀ m ∈ F.ordersAt i,
      m > 1 → ∀ p : ℕ, Nat.Prime p → p ∣ m → p ∈ primes) :
    globalTorsionBirthSet F =
      primes.biUnion (fun p => pTorsionBirthSet p F) := by
  ext n
  constructor;
  · simp +decide [ globalTorsionBirthSet ];
    intro i m hm₁ hm₂ hm;
    exact ⟨ Nat.minFac m, hprimes i m hm₁ hm₂ _ ( Nat.minFac_prime hm₂.ne' ) ( Nat.minFac_dvd m ), Finset.mem_image.mpr ⟨ i, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, m, hm₁, hm₂, Nat.minFac_dvd m ⟩, hm ⟩ ⟩;
  · simp +decide [ globalTorsionBirthSet, pTorsionBirthSet ];
    grind

/-! ## Axiom Checks -/

#print axioms mem_global_iff_exists_prime_mem_pTorsion
#print axioms global_eq_of_primewise_eq
#print axioms exists_same_global_different_primewise
#print axioms primewise_strictly_finer_than_global
#print axioms explicit_primewise_separation
#print axioms mem_distinguishingPairs_sound
#print axioms pTorsionBirthSet_subset_global
#print axioms global_eq_biUnion_primewise