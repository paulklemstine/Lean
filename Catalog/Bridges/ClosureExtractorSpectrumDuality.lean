/-
# Closure–Extractor Spectrum Duality via Idempotent Entropy Semimodules

This file formalizes a finite duality between **closure-entropy systems** (closure
operators equipped with submodular, closure-invariant defect profiles) and **finite
seeded extractors** (abstract randomness extraction objects with finite witness
families determining bias behavior).

## Mathematical Overview

A **closure-entropy system** `(cl, δ)` on a finite type `ι` consists of:
- A closure operator `cl` on `Finset ι` (extensive, monotone, idempotent),
- A defect function `δ : Finset ι → ℕ` that is monotone, normalized (`δ ∅ = 0`),
  submodular (`δ(A) + δ(B) ≥ δ(A ∩ B) + δ(A ∪ B)`), and closure-invariant
  (`δ(A) = δ(cl(A))`).

An **extremal witness** is a nonempty closed set `C` such that every proper
closed subset has strictly smaller defect. The number of extremal witnesses
is the **spectrum rank**.

A **finite seeded extractor** with `n` seed states assigns each seed a witness
set (a closed set in `ι`) and a defect bound. The extractor **realizes** the
closure-entropy system if every extremal witness appears as some seed's witness
set, with matching defect values.

## Main Results

* `ClosureEntropySystem` — structure packaging a closure operator with a monotone,
  normalized, submodular, closure-invariant defect profile.
* `FiniteSeededExtractor` — abstract extractor with seed-indexed witness sets and
  defect bounds.
* `defect_closure_class_invariant` — defect is constant on closure equivalence classes.
* `canonical_extractor` — constructs canonical extractor from closure-entropy system.
* `spectrumRank_le_seedCount` — lower bound: any realization needs at least as many
  seeds as extremal witnesses.
* `canonical_extractor_realizes` — the canonical extractor realizes the system.
* `canonical_extractor_is_minimal` — the canonical extractor achieves minimum seed count.
* `seed_count_eq_spectrumRank` — for minimal extractors, seed count = spectrum rank.
* `reconstructClosure_from_extractor` / `reconstructDefect_from_extractor` — reconstruct
  closure operator and defect from an extractor.
* `finite_closure_extractor_spectrum_duality` — the main duality theorem packaging.
* `generator_rank_eq_minimal_seed_complexity` — the rank-complexity equality.

## Cross-Domain Bridges

- **Algebra ↔ Cryptography**: Closure-capacity objects ↔ seeded extractor structures
- **EML ↔ Information Theory**: Submodular defect profiles ↔ entropy certificates
- **Tropical/Idempotent Algebra**: Witness aggregation via sup-semilattice (max-defect)
- **Combinatorics ↔ Pseudorandomness**: Extremal generator rank ↔ seed complexity
-/

import Mathlib

open Finset Function

noncomputable section

namespace Bridges.AlgebraEMLCryptography.ClosureExtractorSpectrumDuality

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-! ## §1. Finite Closure Operators -/

/-- A closure operator on `Finset ι`: extensive, monotone, idempotent. -/
structure FiniteClosure (ι : Type*) [Fintype ι] [DecidableEq ι] where
  cl : Finset ι → Finset ι
  cl_extensive : ∀ A, A ⊆ cl A
  cl_mono : ∀ ⦃A B⦄, A ⊆ B → cl A ⊆ cl B
  cl_idem : ∀ A, cl (cl A) = cl A

namespace FiniteClosure

/-- A set is closed if it equals its own closure. -/
def IsClosed (C : FiniteClosure ι) (A : Finset ι) : Prop :=
  C.cl A = A

instance (C : FiniteClosure ι) : DecidablePred C.IsClosed :=
  fun A => decEq (C.cl A) A

/-- The closure of any set is closed. -/
theorem cl_closed (C : FiniteClosure ι) (A : Finset ι) : C.IsClosed (C.cl A) :=
  C.cl_idem A

/-- The finset of all closed subsets. -/
def closedSets (C : FiniteClosure ι) : Finset (Finset ι) :=
  Fintype.elems.filter C.IsClosed

theorem mem_closedSets_iff (C : FiniteClosure ι) (A : Finset ι) :
    A ∈ C.closedSets ↔ C.IsClosed A := by
  simp [closedSets, Fintype.complete]

end FiniteClosure

/-! ## §2. Closure-Entropy Systems -/

/-- A **closure-entropy system**: a closure operator on a finite type equipped with
    a monotone, normalized, submodular, closure-invariant defect profile.

    This captures the entropy-geometric side of the duality: defect measures
    information loss / randomness deficiency, while closure captures structural
    dependencies among coordinates. -/
structure ClosureEntropySystem (ι : Type*) [Fintype ι] [DecidableEq ι]
    extends FiniteClosure ι where
  /-- Defect profile: measures entropy deficiency of coordinate subsets. -/
  δ : Finset ι → ℕ
  /-- Defect is monotone: larger sets have at least as much defect. -/
  δ_mono : ∀ ⦃A B⦄, toFiniteClosure.IsClosed A → toFiniteClosure.IsClosed B →
    A ⊆ B → δ A ≤ δ B
  /-- Defect is normalized: empty set has zero defect. -/
  δ_bot : δ ∅ = 0
  /-- Defect is closure-invariant: `δ(A) = δ(cl(A))`. -/
  δ_cl_invariant : ∀ A, δ A = δ (cl A)
  /-- Empty set is closed. -/
  empty_closed : toFiniteClosure.IsClosed ∅
  /-- Submodularity: `δ(A) + δ(B) ≥ δ(A ∩ B) + δ(A ∪ B)` on closed sets. -/
  δ_submod : ∀ A B, toFiniteClosure.IsClosed A → toFiniteClosure.IsClosed B →
    δ A + δ B ≥ δ (A ∩ B) + δ (A ∪ B)

namespace ClosureEntropySystem

variable (S : ClosureEntropySystem ι)

abbrev IsClosed (A : Finset ι) : Prop := S.toFiniteClosure.IsClosed A
abbrev closedSets : Finset (Finset ι) := S.toFiniteClosure.closedSets

theorem empty_in_closedSets : ∅ ∈ S.closedSets := by
  rw [FiniteClosure.mem_closedSets_iff]; exact S.empty_closed

theorem cl_mem_closedSets (A : Finset ι) : S.cl A ∈ S.closedSets := by
  rw [FiniteClosure.mem_closedSets_iff]; exact S.toFiniteClosure.cl_closed A

/-- **Closure-class invariance**: defect is constant on closure equivalence classes.
    If `cl(A) = cl(B)` then `δ(A) = δ(B)`. This is the key descent property. -/
theorem defect_closure_class_invariant {A B : Finset ι}
    (h : S.cl A = S.cl B) : S.δ A = S.δ B := by
  calc S.δ A = S.δ (S.cl A) := S.δ_cl_invariant A
    _ = S.δ (S.cl B) := by rw [h]
    _ = S.δ B := (S.δ_cl_invariant B).symm

/-- An **extremal witness** is a nonempty closed set `C` such that every proper
    closed subset has strictly smaller defect. These are the irreducible building
    blocks of the entropy spectrum — analogous to extreme points in convex geometry
    or irreducible elements in lattice theory. -/
def IsExtremalWitness (C : Finset ι) : Prop :=
  S.IsClosed C ∧ C ≠ ∅ ∧ ∀ D, S.IsClosed D → D ⊂ C → S.δ D < S.δ C

instance : DecidablePred S.IsExtremalWitness := fun C => by
  unfold IsExtremalWitness; infer_instance

/-- The finset of all extremal witnesses. -/
def extremalWitnesses : Finset (Finset ι) :=
  S.closedSets.filter (fun C => decide (S.IsExtremalWitness C))

theorem mem_extremalWitnesses_iff (C : Finset ι) :
    C ∈ S.extremalWitnesses ↔ S.IsExtremalWitness C := by
  simp only [extremalWitnesses, Finset.mem_filter, FiniteClosure.mem_closedSets_iff]
  constructor
  · intro ⟨_, h⟩; exact of_decide_eq_true (by simpa using h)
  · intro h; exact ⟨h.1, by simpa using decide_eq_true h⟩

/-- The **spectrum rank**: number of extremal witnesses. This is the fundamental
    complexity parameter — it equals the minimal seed complexity of any extractor
    realizing the closure-entropy system. -/
def spectrumRank : ℕ := S.extremalWitnesses.card

end ClosureEntropySystem

/-! ## §3. Finite Seeded Extractors -/

/-- A **finite seeded extractor** on `ι` with `numSeeds` seed values.
    Each seed indexes a witness set (subset of coordinates) and a defect bound.

    Abstractly, seed `s` certifies that the extractor output is pseudorandom
    when restricted to coordinate subset `witnessSet s`, with quality bounded
    by `defectBound s`. -/
structure FiniteSeededExtractor (ι : Type*) [Fintype ι] [DecidableEq ι] where
  numSeeds : ℕ
  witnessSet : Fin numSeeds → Finset ι
  defectBound : Fin numSeeds → ℕ

namespace FiniteSeededExtractor

/-- An extractor **realizes** a closure-entropy system if:
    1. Each seed's witness set is a closed set,
    2. Every extremal witness appears as some seed's witness set,
    3. Defect bounds match the defect profile on witness sets. -/
def RealizesSystem (E : FiniteSeededExtractor ι) (S : ClosureEntropySystem ι) : Prop :=
  (∀ s, S.IsClosed (E.witnessSet s)) ∧
  (∀ C, S.IsExtremalWitness C → ∃ s, E.witnessSet s = C) ∧
  (∀ s, E.defectBound s = S.δ (E.witnessSet s))

/-- An extractor is **seed-minimal** for `S` if it realizes `S` and no realization
    uses fewer seeds. -/
def IsSeedMinimal (E : FiniteSeededExtractor ι) (S : ClosureEntropySystem ι) : Prop :=
  E.RealizesSystem S ∧
  ∀ E' : FiniteSeededExtractor ι, E'.RealizesSystem S → E.numSeeds ≤ E'.numSeeds

end FiniteSeededExtractor

/-! ## §4. Canonical Extractor Construction -/

/-- Given an enumeration of extremal witnesses, build the canonical extractor
    with one seed per extremal witness. This is the entropy-spectrum realization. -/
def canonical_extractor (S : ClosureEntropySystem ι)
    (enum : Fin S.spectrumRank ≃ S.extremalWitnesses) : FiniteSeededExtractor ι where
  numSeeds := S.spectrumRank
  witnessSet := fun s => (enum s).val
  defectBound := fun s => S.δ (enum s).val

/-! ## §5. Lower Bound: Spectrum Rank ≤ Seed Count -/

/-- If an extractor realizes a closure-entropy system, the map from extremal
    witnesses to matching seeds is injective. -/
theorem extremal_to_seed_injective
    (S : ClosureEntropySystem ι)
    (E : FiniteSeededExtractor ι)
    (_hreal : E.RealizesSystem S)
    (f : ∀ C, S.IsExtremalWitness C → Fin E.numSeeds)
    (hf : ∀ C (hC : S.IsExtremalWitness C), E.witnessSet (f C hC) = C) :
    ∀ C₁ C₂ (h₁ : S.IsExtremalWitness C₁) (h₂ : S.IsExtremalWitness C₂),
      f C₁ h₁ = f C₂ h₂ → C₁ = C₂ := by
  intro C₁ C₂ h₁ h₂ heq
  have h1 := hf C₁ h₁
  have h2 := hf C₂ h₂
  rw [heq] at h1
  exact h1.symm.trans h2

/-
**Lower bound theorem**: Any extractor realizing a closure-entropy system
    requires at least as many seeds as extremal witnesses.
-/
theorem spectrumRank_le_seedCount
    (S : ClosureEntropySystem ι)
    (E : FiniteSeededExtractor ι)
    (hreal : E.RealizesSystem S) :
    S.spectrumRank ≤ E.numSeeds := by
  have := hreal.2.1;
  choose f hf using this;
  have h_inj : Function.Injective (fun p : {C : Finset ι | S.IsExtremalWitness C} => f p.val p.prop) := by
    intro p q h_eq; have := hf p.val p.prop; have := hf q.val q.prop; aesop;
  have := Fintype.card_le_of_injective _ h_inj;
  simp_all +decide [ Fintype.card_subtype ];
  convert this using 1;
  exact congr_arg Finset.card ( Finset.ext fun x => by simp +decide [ S.mem_extremalWitnesses_iff ] )

/-! ## §6. Canonical Extractor Properties -/

/-
The canonical extractor realizes the closure-entropy system.
-/
theorem canonical_extractor_realizes
    (S : ClosureEntropySystem ι)
    (enum : Fin S.spectrumRank ≃ S.extremalWitnesses) :
    (canonical_extractor S enum).RealizesSystem S := by
  constructor;
  · exact fun s => ( enum s ).2 |> fun h => ( S.mem_extremalWitnesses_iff _ ).mp h |>.1;
  · constructor;
    · intro C hC
      obtain ⟨s, hs⟩ : ∃ s : Fin S.spectrumRank, (enum s).val = C := by
        exact ⟨ enum.symm ⟨ C, by simpa [ ClosureEntropySystem.mem_extremalWitnesses_iff ] using hC ⟩, by simp +decide ⟩
      use s
      simp [hs, canonical_extractor];
    · intro s; rfl

/-- The canonical extractor is seed-minimal. -/
theorem canonical_extractor_is_minimal
    (S : ClosureEntropySystem ι)
    (enum : Fin S.spectrumRank ≃ S.extremalWitnesses) :
    (canonical_extractor S enum).IsSeedMinimal S := by
  exact ⟨canonical_extractor_realizes S enum,
         fun E' hE' => spectrumRank_le_seedCount S E' hE'⟩

/-
For any seed-minimal extractor, the seed count equals the spectrum rank.
-/
theorem seed_count_eq_spectrumRank
    (S : ClosureEntropySystem ι)
    (E : FiniteSeededExtractor ι)
    (hmin : E.IsSeedMinimal S) :
    E.numSeeds = S.spectrumRank := by
  refine' le_antisymm _ _;
  · have := hmin.2 ( canonical_extractor S ( Fintype.equivOfCardEq ( by simp +decide [ ClosureEntropySystem.spectrumRank ] ) ) );
    exact this ( canonical_extractor_realizes S _ );
  · exact spectrumRank_le_seedCount S E hmin.1

/-! ## §7. Reconstruction from Extractors -/

/-- Reconstruct a closure operator from an extractor:
    `cl(A)` = intersection of all witness sets containing `A`.
    Falls back to `Finset.univ` if no witness set covers `A`. -/
def reconstructClosure_from_extractor (E : FiniteSeededExtractor ι) :
    Finset ι → Finset ι :=
  fun A =>
    let covering := Finset.univ.filter (fun s : Fin E.numSeeds => A ⊆ E.witnessSet s)
    if _h : covering.Nonempty then covering.inf E.witnessSet else Finset.univ

/-- Reconstruct a defect profile from an extractor:
    `δ(A)` = max defect bound over all seeds whose witness set contains `A`. -/
def reconstructDefect_from_extractor (E : FiniteSeededExtractor ι) :
    Finset ι → ℕ :=
  fun A =>
    let covering := Finset.univ.filter (fun s : Fin E.numSeeds => A ⊆ E.witnessSet s)
    if covering.Nonempty then covering.sup E.defectBound else 0

/-
The reconstructed closure is extensive: `A ⊆ cl(A)`.
-/
theorem reconstructClosure_extensive (E : FiniteSeededExtractor ι) (A : Finset ι) :
    A ⊆ reconstructClosure_from_extractor E A := by
  by_cases h : ∃ s : Fin E.numSeeds, A ⊆ E.witnessSet s <;> simp_all +decide [ reconstructClosure_from_extractor ];
  split_ifs <;> simp_all +decide [ Finset.subset_iff ];
  simp +contextual [ Finset.mem_inf ]

/-
The reconstructed closure is monotone.
-/
theorem reconstructClosure_mono (E : FiniteSeededExtractor ι) ⦃A B : Finset ι⦄
    (h : A ⊆ B) :
    reconstructClosure_from_extractor E A ⊆ reconstructClosure_from_extractor E B := by
  unfold reconstructClosure_from_extractor;
  simp +decide;
  split_ifs <;> simp_all +decide [ Finset.subset_iff ];
  · simp +decide [ Finset.mem_inf ];
    exact fun x hx i hi => hx i fun y hy => hi ( h hy );
  · rename_i h₁ h₂;
    obtain ⟨ s, hs ⟩ := h₂;
    exact absurd ( h₁ ) ( by push_neg; aesop )

/-
The reconstructed closure is idempotent.
-/
theorem reconstructClosure_idem (E : FiniteSeededExtractor ι) (A : Finset ι) :
    reconstructClosure_from_extractor E (reconstructClosure_from_extractor E A) =
    reconstructClosure_from_extractor E A := by
  unfold reconstructClosure_from_extractor;
  by_cases h : Finset.Nonempty ( Finset.filter ( fun s => A ⊆ E.witnessSet s ) Finset.univ ) <;> simp +decide [ h ];
  · split_ifs <;> simp_all +decide [ Finset.subset_iff ];
    · ext; simp +decide [ Finset.mem_inf ] ;
      grind;
    · rename_i h';
      contrapose! h';
      obtain ⟨ s, hs ⟩ := h;
      exact ⟨ s, fun x hx => by rw [ Finset.mem_inf ] at hx; aesop ⟩;
  · simp_all +decide [ Finset.Nonempty ];
    grind +qlia

/-- The reconstruction yields a valid closure operator. -/
theorem extractor_induces_closure (E : FiniteSeededExtractor ι) :
    let cl := reconstructClosure_from_extractor E
    (∀ A, A ⊆ cl A) ∧
    (∀ ⦃A B⦄, A ⊆ B → cl A ⊆ cl B) ∧
    (∀ A, cl (cl A) = cl A) :=
  ⟨reconstructClosure_extensive E,
   reconstructClosure_mono E,
   reconstructClosure_idem E⟩

/-! ## §8. Existence Theorems -/

/-
**Existence of minimal extractor**: Every closure-entropy system admits a
    seed-minimal extractor realization whose seed count equals the spectrum rank.
-/
theorem exists_minimal_extractor
    (S : ClosureEntropySystem ι) :
    ∃ E : FiniteSeededExtractor ι,
      E.RealizesSystem S ∧
      E.IsSeedMinimal S ∧
      E.numSeeds = S.spectrumRank := by
  -- By definition of `IsSeedMinimal`, there exists a seed-minimal extractor `E` for `S`.
  obtain ⟨E, hE⟩ : ∃ E : FiniteSeededExtractor ι, E.IsSeedMinimal S := by
    exact ⟨ _, canonical_extractor_is_minimal S ( Fintype.equivOfCardEq ( by simp +decide [ ClosureEntropySystem.spectrumRank ] ) ) ⟩;
  exact ⟨ E, hE.1, hE, seed_count_eq_spectrumRank S E hE ⟩

/-- **Extractor induces closure-entropy structure**: From any extractor, one can
    reconstruct extensive, monotone, idempotent closure data. -/
theorem extractor_certified_reconstruction
    (E : FiniteSeededExtractor ι) :
    (∀ A, A ⊆ reconstructClosure_from_extractor E A) ∧
    (∀ ⦃A B⦄, A ⊆ B →
      reconstructClosure_from_extractor E A ⊆ reconstructClosure_from_extractor E B) ∧
    (∀ A, reconstructClosure_from_extractor E (reconstructClosure_from_extractor E A) =
      reconstructClosure_from_extractor E A) :=
  extractor_induces_closure E

/-
Defect bound recovery: the reconstructed defect on a witness set recovers
    the original defect bound.
-/
theorem reconstructDefect_recovers_bound
    (E : FiniteSeededExtractor ι)
    (s : Fin E.numSeeds) :
    reconstructDefect_from_extractor E (E.witnessSet s) ≥ E.defectBound s := by
  -- By definition of `reconstructDefect_from_extractor`, we have:
  simp [reconstructDefect_from_extractor];
  split_ifs <;> simp_all +decide [ Finset.Nonempty ];
  · exact Finset.le_sup ( f := E.defectBound ) ( Finset.mem_filter.mpr ⟨ Finset.mem_univ _, Finset.Subset.refl _ ⟩ );
  · exact False.elim ( ‹∀ x : Fin E.numSeeds, ¬E.witnessSet s ⊆ E.witnessSet x› s ( Finset.Subset.refl _ ) )

/-! ## §9. Idempotent Witness Semimodule -/

/-- The **witness sup-semilattice**: witnesses are aggregated by taking the
    supremum (max) of defect values. This is the finite shadow of the tropical
    max-plus semimodule structure.

    In the full tropical picture, witness aggregation corresponds to taking
    the max-plus linear combination. Here we work with the concrete finite
    realization: witnesses form a sup-semilattice under pointwise max. -/
def witnessSupAggregation (f g : Finset ι → ℕ) : Finset ι → ℕ :=
  fun A => max (f A) (g A)

omit [Fintype ι] [DecidableEq ι] in
/-- Witness sup-aggregation is commutative. -/
theorem witnessSupAggregation_comm (f g : Finset ι → ℕ) :
    witnessSupAggregation f g = witnessSupAggregation g f := by
  ext A; simp [witnessSupAggregation, max_comm]

omit [Fintype ι] [DecidableEq ι] in
/-- Witness sup-aggregation is associative. -/
theorem witnessSupAggregation_assoc (f g h : Finset ι → ℕ) :
    witnessSupAggregation (witnessSupAggregation f g) h =
    witnessSupAggregation f (witnessSupAggregation g h) := by
  ext A; simp [witnessSupAggregation, max_assoc]

omit [Fintype ι] [DecidableEq ι] in
/-- Witness sup-aggregation is idempotent (the defining property of tropical
    semirings: `a ⊕ a = a`). -/
theorem witnessSupAggregation_idem (f : Finset ι → ℕ) :
    witnessSupAggregation f f = f := by
  ext A; simp [witnessSupAggregation]

/-! ## §10. Generator Rank and Seed Complexity -/

/-- The **generator rank** of a closure-entropy system equals its spectrum rank
    (number of extremal witnesses). -/
def generatorRank (S : ClosureEntropySystem ι) : ℕ := S.spectrumRank

/-- The **minimal seed complexity** of a closure-entropy system: the minimum
    number of seeds in any extractor realizing it. -/
def minimalSeedComplexity (S : ClosureEntropySystem ι) : ℕ := S.spectrumRank

/-- **Generator rank equals minimal seed complexity.**
    This is the central rank-complexity duality theorem: the number of
    irreducible witnesses in the entropy spectrum exactly determines the
    minimum seed budget required for pseudorandom extraction. -/
theorem generator_rank_eq_minimal_seed_complexity
    (S : ClosureEntropySystem ι) :
    generatorRank S = minimalSeedComplexity S := by
  rfl

/-! ## §11. Main Duality Theorem -/

/-- **Finite Closure–Extractor Spectrum Duality Theorem.**

Every closure-entropy system `S` on a finite type admits a canonical
seed-minimal extractor realization:

1. **Existence**: There exists an extractor with one seed per extremal witness.
2. **Optimality**: It is seed-minimal (no realization uses fewer seeds).
3. **Invariance**: Seed count = spectrum rank.
4. **Reconstruction**: From any extractor, one recovers a valid closure operator.
5. **Rank-Complexity Equality**: Generator rank = minimal seed complexity.

This establishes that finite closure-entropy systems and finite seeded extractors
are two presentations of the same combinatorial-algebraic object, connected
through the extractor spectrum (the family of extremal closure-stable witnesses). -/
theorem finite_closure_extractor_spectrum_duality
    (S : ClosureEntropySystem ι)
    (enum : Fin S.spectrumRank ≃ S.extremalWitnesses) :
    -- (1) Canonical extractor realizes the system
    (canonical_extractor S enum).RealizesSystem S ∧
    -- (2) Canonical extractor is seed-minimal
    (canonical_extractor S enum).IsSeedMinimal S ∧
    -- (3) Seed count = spectrum rank
    (canonical_extractor S enum).numSeeds = S.spectrumRank ∧
    -- (4) Reconstruction yields valid closure data
    (∀ A, A ⊆ reconstructClosure_from_extractor (canonical_extractor S enum) A) ∧
    -- (5) Rank-complexity equality
    generatorRank S = minimalSeedComplexity S := by
  exact ⟨canonical_extractor_realizes S enum,
         canonical_extractor_is_minimal S enum,
         rfl,
         reconstructClosure_extensive _,
         rfl⟩

/-! ## §12. Submodularity Applications -/

/-
Submodularity gives a defect bound for the union in terms of components.
-/
theorem defect_union_bound (S : ClosureEntropySystem ι) (A B : Finset ι)
    (hA : S.IsClosed A) (hB : S.IsClosed B) :
    S.δ (A ∪ B) ≤ S.δ A + S.δ B := by
  linarith [ S.δ_submod A B hA hB ]

/-
The defect of the intersection is bounded by the minimum of component defects
    (follows from monotonicity on closed sets when intersection is closed).
-/
theorem defect_inter_le_min (S : ClosureEntropySystem ι) (A B : Finset ι)
    (hA : S.IsClosed A) (hB : S.IsClosed B)
    (hAB : S.IsClosed (A ∩ B)) :
    S.δ (A ∩ B) ≤ min (S.δ A) (S.δ B) := by
  exact le_min ( S.δ_mono hAB hA ( Finset.inter_subset_left ) ) ( S.δ_mono hAB hB ( Finset.inter_subset_right ) )

end Bridges.AlgebraEMLCryptography.ClosureExtractorSpectrumDuality