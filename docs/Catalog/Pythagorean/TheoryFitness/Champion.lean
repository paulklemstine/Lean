/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license.

# The canonical champion, and the exact boundary where canonicity fails

Fix a finite corpus and a proof system assigning to each statement the
declarations its proof consumes.  Then the dependency-adjusted global champion
is not merely *some* member of a finite comparison class: it is the canonical
transitive closure of the corpus' proof bases, and it beats **every**
dependency-closed development proving the corpus, over the whole (unbounded)
class.

* `canonicalLibrary_covers` : the canonical library does prove the corpus;
* `canonicalClosure_subset_of_covers` : its closure embeds in the closure of
  every competitor;
* `canonicalLibrary_is_global_champion` : hence it is a global fitness maximum
  -- the dependency-adjusted champion conjecture, proved for a fixed proof
  system.

The last section is the adversarial boundary: as soon as a statement admits two
*inequivalent* proof routes, canonicity fails.  `two_routes_no_canonical_champion`
exhibits two cost-equal, fitness-equal champions with incomparable dependency
closures whose intersection proves nothing -- so no least closure exists and the
champion is only unique up to cost ties.  What survives is existence:
`min_cost_cover_is_champion` shows a fitness-maximal covering library is still
attained in the multi-route model, it simply stops being canonical.
-/

import Catalog.Pythagorean.TheoryFitness.Core

namespace TheoryFitness

open Finset

/-- A proof system: direct dependencies of each declaration, and the
declarations consumed by the chosen proof of each statement. -/
structure ProofSystem where
  /-- direct dependencies of a declaration -/
  deps : ℕ → Finset ℕ
  /-- declarations consumed by the chosen proof of a statement -/
  base : ℕ → Finset ℕ

/-- A development proves a statement when its dependency closure contains the
statement's proof base. -/
def ProvesStmt (P : ProofSystem) (T : Theory) (s : ℕ) : Prop := P.base s ⊆ T.closure

/-- A development covers the corpus when it proves each of its statements. -/
def CoversCorpus (P : ProofSystem) (T : Theory) (corpus : Finset ℕ) : Prop :=
  ∀ s ∈ corpus, ProvesStmt P T s

/-- The canonical library for a corpus: the transitive dependency closure of all
the proof bases. -/
def canonicalClosure (P : ProofSystem) (U corpus : Finset ℕ) : Finset ℕ :=
  depClosure P.deps U (corpus.biUnion P.base)

/-- The canonical library as a theory. -/
def canonicalLibrary (P : ProofSystem) (U corpus : Finset ℕ) : Theory where
  closure := canonicalClosure P U corpus
  proves := corpus

/-- The canonical library proves the whole corpus. -/
theorem canonicalLibrary_covers (P : ProofSystem) (U corpus : Finset ℕ) :
    CoversCorpus P (canonicalLibrary P U corpus) corpus := by
  intro s hs x hx
  have hmem : x ∈ corpus.biUnion P.base := mem_biUnion.2 ⟨s, hs, hx⟩
  exact base_subset_depClosure (deps := P.deps) U (corpus.biUnion P.base) hmem

/-- Every dependency-closed development covering the corpus contains the
canonical library. -/
theorem canonicalClosure_subset_of_covers (P : ProofSystem) (U corpus : Finset ℕ)
    (T : Theory) (hclosed : DepClosed P.deps T.closure)
    (hcov : CoversCorpus P T corpus) :
    canonicalClosure P U corpus ⊆ T.closure := by
  apply depClosure_minimal hclosed
  intro x hx
  obtain ⟨s, hs, hxs⟩ := mem_biUnion.1 hx
  exact hcov s hs hxs

/-- **Dependency-adjusted global champion.**  Over the entire class of
dependency-closed developments proving the corpus -- not merely a finite
comparison class -- the canonical library has maximal dependency-adjusted
fitness. -/
theorem canonicalLibrary_is_global_champion (ℓ : ℕ → ℕ) (P : ProofSystem)
    (U corpus : Finset ℕ) (hne : 0 < corpus.card)
    (hpos : 0 < cost ℓ (canonicalLibrary P U corpus)) :
    ∀ T : Theory, T.proves = corpus → DepClosed P.deps T.closure →
      CoversCorpus P T corpus →
      fitness ℓ T ≤ fitness ℓ (canonicalLibrary P U corpus) := by
  intro T hTproves hclosed hcov
  have hsub : (canonicalLibrary P U corpus).closure ⊆ T.closure :=
    canonicalClosure_subset_of_covers P U corpus T hclosed hcov
  have hcost : cost ℓ (canonicalLibrary P U corpus) ≤ cost ℓ T := cost_mono ℓ hsub
  have hposT : 0 < cost ℓ T := lt_of_lt_of_le hpos hcost
  have hcard : T.proves.card = (canonicalLibrary P U corpus).proves.card := by
    rw [hTproves]; rfl
  exact (fitness_le_iff_cost_le ℓ hcard (by rw [hTproves]; exact hne) hposT hpos).2 hcost

/-- The champion is unique up to cost: any other global champion covering the
corpus has exactly the same dependency-adjusted cost. -/
theorem champion_cost_unique (ℓ : ℕ → ℕ) (P : ProofSystem) (U corpus : Finset ℕ)
    (hne : 0 < corpus.card) (hpos : 0 < cost ℓ (canonicalLibrary P U corpus))
    (T : Theory) (hTproves : T.proves = corpus) (hclosed : DepClosed P.deps T.closure)
    (hcov : CoversCorpus P T corpus)
    (hchamp : fitness ℓ (canonicalLibrary P U corpus) ≤ fitness ℓ T) :
    cost ℓ T = cost ℓ (canonicalLibrary P U corpus) := by
  have hsub : (canonicalLibrary P U corpus).closure ⊆ T.closure :=
    canonicalClosure_subset_of_covers P U corpus T hclosed hcov
  have hcost : cost ℓ (canonicalLibrary P U corpus) ≤ cost ℓ T := cost_mono ℓ hsub
  have hposT : 0 < cost ℓ T := lt_of_lt_of_le hpos hcost
  have hcard : (canonicalLibrary P U corpus).proves.card = T.proves.card := by
    rw [hTproves]; rfl
  have := (fitness_le_iff_cost_le ℓ hcard hne hpos hposT).1 hchamp
  omega

/-! ## Boundary: two inequivalent proof routes destroy canonicity

If a statement can be proved in two genuinely different ways, there is no least
dependency closure among the covering developments, and the champion is only
determined up to cost. -/

/-- A proof system for corpus `{0}` in which statement `0` has *two* routes,
`{1}` and `{2}`, is modelled by the two competing developments below. -/
def routeOne : Theory where
  closure := {1}
  proves := {0}

/-- The competing development using the other route. -/
def routeTwo : Theory where
  closure := {2}
  proves := {0}

/-- Both routes cost one line. -/
def unitLen : ℕ → ℕ := fun _ => 1

/-- **No canonical champion under alternative proof routes.**  The two
developments have equal (hence maximal) fitness, their dependency closures are
incomparable, and their intersection is empty -- so no least covering closure
exists and canonicity genuinely fails. -/
theorem two_routes_no_canonical_champion :
    fitness unitLen routeOne = fitness unitLen routeTwo ∧
      ¬ routeOne.closure ⊆ routeTwo.closure ∧
      ¬ routeTwo.closure ⊆ routeOne.closure ∧
      routeOne.closure ∩ routeTwo.closure = ∅ := by
  refine ⟨?_, by decide, by decide, by decide⟩
  unfold fitness cost routeOne routeTwo unitLen
  norm_num

/-! ## What survives with alternative routes: a champion still exists

Canonicity fails, but existence does not.  With several routes per statement the
minimum-cost covering library is still attained, so the champion question stays
well posed -- it merely stops having a canonical answer. -/

/-- A proof system in which each statement may be proved by any one of several
routes. -/
structure MultiProofSystem where
  /-- direct dependencies of a declaration -/
  deps : ℕ → Finset ℕ
  /-- the alternative proof routes available for a statement -/
  routes : ℕ → Finset (Finset ℕ)

/-- A closure proves a statement if it contains one of its routes. -/
def MProves (M : MultiProofSystem) (s : ℕ) (c : Finset ℕ) : Prop :=
  ∃ r ∈ M.routes s, r ⊆ c

/-- A closure covers the corpus if it proves each statement by some route. -/
def MCovers (M : MultiProofSystem) (corpus c : Finset ℕ) : Prop :=
  ∀ s ∈ corpus, MProves M s c

/-- **A minimum-cost covering library always exists.**  Inside a finite universe
that itself covers the corpus, some sub-library covers the corpus at minimal
dependency-adjusted cost. -/
theorem exists_min_cost_cover (ℓ : ℕ → ℕ) (M : MultiProofSystem) (U corpus : Finset ℕ)
    (hU : MCovers M corpus U) :
    ∃ c ⊆ U, MCovers M corpus c ∧
      ∀ d ⊆ U, MCovers M corpus d → (∑ x ∈ c, ℓ x) ≤ ∑ x ∈ d, ℓ x := by
  classical
  set S : Finset (Finset ℕ) := U.powerset.filter (fun c => MCovers M corpus c) with hS
  have hUS : U ∈ S := by
    rw [hS, mem_filter, mem_powerset]
    exact ⟨Subset.rfl, hU⟩
  obtain ⟨c, hcS, hmin⟩ := S.exists_min_image (fun c => ∑ x ∈ c, ℓ x) ⟨U, hUS⟩
  rw [hS, mem_filter, mem_powerset] at hcS
  refine ⟨c, hcS.1, hcS.2, ?_⟩
  intro d hd hdcov
  exact hmin d (by rw [hS, mem_filter, mem_powerset]; exact ⟨hd, hdcov⟩)

/-- **Champion with alternative routes.**  A minimum-cost cover is a fitness
maximum among all sub-libraries of the universe proving the corpus; by
`two_routes_no_canonical_champion` it need not be unique. -/
theorem min_cost_cover_is_champion (ℓ : ℕ → ℕ) (M : MultiProofSystem)
    (U corpus : Finset ℕ) (hU : MCovers M corpus U) (hne : 0 < corpus.card)
    (hpos : ∀ c ⊆ U, MCovers M corpus c → 0 < ∑ x ∈ c, ℓ x) :
    ∃ c ⊆ U, MCovers M corpus c ∧
      ∀ d ⊆ U, MCovers M corpus d →
        fitness ℓ ⟨d, corpus⟩ ≤ fitness ℓ ⟨c, corpus⟩ := by
  obtain ⟨c, hcU, hccov, hmin⟩ := exists_min_cost_cover ℓ M U corpus hU
  refine ⟨c, hcU, hccov, ?_⟩
  intro d hd hdcov
  have hcostc : cost ℓ (⟨c, corpus⟩ : Theory) = ∑ x ∈ c, ℓ x := rfl
  have hcostd : cost ℓ (⟨d, corpus⟩ : Theory) = ∑ x ∈ d, ℓ x := rfl
  have hle : cost ℓ (⟨c, corpus⟩ : Theory) ≤ cost ℓ (⟨d, corpus⟩ : Theory) := by
    rw [hcostc, hcostd]; exact hmin d hd hdcov
  have hposc : 0 < cost ℓ (⟨c, corpus⟩ : Theory) := by
    rw [hcostc]; exact hpos c hcU hccov
  have hposd : 0 < cost ℓ (⟨d, corpus⟩ : Theory) := by
    rw [hcostd]; exact hpos d hd hdcov
  exact (fitness_le_iff_cost_le ℓ (T := ({ closure := d, proves := corpus } : Theory))
    (U := ({ closure := c, proves := corpus } : Theory)) rfl hne hposd hposc).2 hle

end TheoryFitness