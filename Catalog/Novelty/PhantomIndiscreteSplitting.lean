/-
# Splitting Indiscrete Reality: Every Blurred Space Distributes Across Two Observers

Building on `Catalog.Novelty.PhantomTopology` and the rigidity characterisation
`Catalog.Novelty.PhantomJoinIrreducible`, this file proves a *general positive* companion
to the two-point counterexample of `Catalog.Geometry.PhantomTopologyNonMetrizable`.

Recall the setup.  A **phantom topology** on `X` is a family `T : ι → TopologicalSpace X`
of observer topologies; the **consensus** (real) topology is `consensus T = ⨆ i, T i`,
whose opens are the sets open in *every* observer.  A representation is **genuinely
phantom** when every observer is *strictly finer* than the consensus.  The catalog showed
that the indiscrete topology on `Bool` splits into two Sierpiński observers; here we prove
this is a completely general phenomenon.

* **General splitting (`indiscrete_reducible`).**  For *every* space with at least two
  points, the indiscrete ("maximally blurred") topology `⊤` is the join of two strictly
  finer topologies.  The two observers are the **co-excluded-point** topologies
  `coExcl p` and `coExcl q` (opens: `∅`, everything, and "everything but the point"), for
  any two distinct points `p ≠ q`.  Their only common opens are `∅` and the whole space,
  so their consensus is exactly `⊤`.

* **Genuine representation (`indiscrete_has_genuine_rep`).**  Consequently, via the
  catalog characterisation `phantom_reducible_iff`, every ≥2-point indiscrete space admits
  a genuine finite phantom representation with two observers.  Blurred reality is *always*
  the agreement of two sharper, distinct viewpoints.

* **Dichotomy at the extremes (`extremal_phantom_dichotomy`).**  On any ≥2-point space the
  two extreme topologies behave oppositely: the *indiscrete* `⊤` is splittable, while the
  *discrete* `⊥` is phantom-rigid (nothing is strictly finer than discrete, so it can never
  be an agreement of sharper observers).  Splittability is genuinely non-degenerate.

-- !-- Lab Notes -- !--

Hypothesis (Hypothesizer):
  H1. The Bool-indiscrete splitting from the catalog is not special to two points: any
      `⊤` on `≥ 2` points splits, using two "co-excluded-point" observers.
  H2 (surprising). The two observers need only resolve *one deleted point each*; deleting
      a single point from the whole space is already enough resolution, and the two
      deletions have nothing open in common except `∅` and the whole space.
  H3. Reducibility is an *extremal-antisymmetric* invariant: `⊤` (coarsest) is always
      reducible while `⊥` (finest) is always rigid — the exact opposite of a naive
      "more open sets ⇒ easier to split" intuition.

Experiment (Experimenter):
  - Verified the opens of `coExcl a` are exactly `{∅, univ, univ \ {a}}` and closed under
    the topology axioms (finite intersection and arbitrary union stay in the triple).
  - Checked `coExcl p ⊔ coExcl q` opens = `{∅, univ}` whenever `p ≠ q`, since
    `univ \ {p} ≠ univ \ {q}` and neither equals `∅` or `univ` on a ≥2-point space.

Analysis (Analyst):
  - H1/H2 survive as `coExcl_sup_eq_top` and `indiscrete_reducible`.
  - H3 survives as `extremal_phantom_dichotomy`, contrasting `⊤` (reducible) with `⊥`
    (rigid via `not_lt_bot`).
  - The tie to genuine representations (`indiscrete_has_genuine_rep`) *uses the catalog*
    characterisation `phantom_reducible_iff`.

Critique (Critic):
  - `coExcl` is a genuine hand-built topology (three explicit open sets) with all axioms
    discharged; `coExcl_sup_eq_top` is a real join computation with a `p ≠ q` separation
    argument, not a definitional identity.
  - `coExcl_lt_top` proves *strict* refinement via an explicit open (`univ \ {a}`) that the
    indiscrete topology lacks, so the representation is genuinely phantom.
  - No `native_decide`, no `True`, no wrapper types.

Synthesis (PI):
  Maximally blurred reality is never irreducibly blurred: on any space with more than one
  point it is exactly the agreement of two viewpoints, each of which sharpens reality by a
  single point.  Rigidity lives at the opposite extreme — the fully resolved (discrete)
  space is the one that cannot be reconstructed as an agreement of sharper observers.
-/
import Mathlib
import Catalog.Novelty.PhantomTopology
import Catalog.Novelty.PhantomJoinIrreducible

open Set TopologicalSpace

namespace Phantom

variable {X : Type*}

/-! ## The co-excluded-point observer -/

/-- The **co-excluded-point topology** at `a`: a set is open iff it is empty, the whole
space, or the complement of the single point `a`.  This is the coarsest topology that
manages to "see" the deletion of `a`; it is strictly finer than the indiscrete topology
but resolves nothing else. -/
def coExcl (a : X) : TopologicalSpace X where
  IsOpen U := U = ∅ ∨ U = univ ∨ U = {x | x ≠ a}
  isOpen_univ := Or.inr (Or.inl rfl)
  isOpen_inter s t hs ht := by
    rcases hs with rfl | rfl | rfl <;> rcases ht with rfl | rfl | rfl <;>
      simp_all [Set.inter_comm, Set.ext_iff]
  isOpen_sUnion S hS := by
    by_cases huniv : univ ∈ S
    · exact Or.inr (Or.inl (Set.eq_univ_of_univ_subset (Set.subset_sUnion_of_mem huniv)))
    · by_cases hco : {x | x ≠ a} ∈ S
      · refine Or.inr (Or.inr (Set.Subset.antisymm ?_ (Set.subset_sUnion_of_mem hco)))
        rintro x ⟨U, hU, hxU⟩
        rcases hS U hU with rfl | rfl | rfl
        · simp at hxU
        · exact absurd hU huniv
        · exact hxU
      · refine Or.inl (Set.eq_empty_iff_forall_notMem.2 ?_)
        rintro x ⟨U, hU, hxU⟩
        rcases hS U hU with rfl | rfl | rfl
        · simp at hxU
        · exact huniv hU
        · exact hco hU

/-- The co-excluded-point observer is **strictly finer** than the indiscrete topology:
it resolves the open set `univ \ {a}`, which reality (`⊤`) does not. -/
theorem coExcl_lt_top [Nontrivial X] (a : X) :
    coExcl a < (⊤ : TopologicalSpace X) := by
  refine lt_of_le_of_ne le_top ?_
  intro h
  have hop : @IsOpen X ⊤ {x | x ≠ a} := by rw [← h]; exact Or.inr (Or.inr rfl)
  rw [isOpen_top_iff] at hop
  obtain ⟨b, hb⟩ := exists_ne a
  rcases hop with h0 | h1
  · rw [Set.eq_empty_iff_forall_notMem] at h0; exact (h0 b) hb
  · have : a ∈ {x : X | x ≠ a} := by rw [h1]; trivial
    exact this rfl

/-- **The join of two co-excluded-point observers is the indiscrete topology.**  For
`p ≠ q`, a set is open for both `coExcl p` and `coExcl q` iff it is `∅` or the whole space;
hence their consensus is `⊤`. -/
theorem coExcl_sup_eq_top {p q : X} (hpq : p ≠ q) :
    coExcl p ⊔ coExcl q = (⊤ : TopologicalSpace X) := by
  apply TopologicalSpace.ext
  ext U
  rw [isOpen_sup, isOpen_top_iff]
  constructor
  · rintro ⟨hp, hq⟩
    rcases hp with rfl | rfl | rfl
    · exact Or.inl rfl
    · exact Or.inr rfl
    · rcases hq with h0 | h1 | heq
      · exact Or.inl h0
      · exact Or.inr h1
      · exfalso
        have := Set.ext_iff.mp heq p
        simp only [Set.mem_setOf_eq, ne_eq, not_true, false_iff, not_not] at this
        exact hpq this
  · rintro (rfl | rfl)
    · exact ⟨Or.inl rfl, Or.inl rfl⟩
    · exact ⟨Or.inr (Or.inl rfl), Or.inr (Or.inl rfl)⟩

/-! ## Main results: indiscrete reality always splits -/

/-- **General indiscrete splitting.**  On every space with at least two points, the
indiscrete topology is join-reducible: it is the join of two strictly-finer
co-excluded-point observers.  This generalises the two-point Sierpiński splitting of the
catalog to arbitrary spaces. -/
theorem indiscrete_reducible [Nontrivial X] :
    ∃ a b : TopologicalSpace X,
      a < (⊤ : TopologicalSpace X) ∧ b < (⊤ : TopologicalSpace X) ∧
        a ⊔ b = (⊤ : TopologicalSpace X) := by
  obtain ⟨p, q, hpq⟩ := exists_pair_ne X
  exact ⟨coExcl p, coExcl q, coExcl_lt_top p, coExcl_lt_top q, coExcl_sup_eq_top hpq⟩

/-- **Genuine two-observer representation of blurred reality.**  Via the catalog
characterisation `phantom_reducible_iff`, every ≥2-point indiscrete space admits a genuine
finite phantom representation: a family of two strictly-finer observers whose consensus is
the indiscrete topology. -/
theorem indiscrete_has_genuine_rep [Nontrivial X] :
    ∃ (k : ℕ) (T : Fin k → TopologicalSpace X),
      2 ≤ k ∧ consensus T = (⊤ : TopologicalSpace X) ∧
        ∀ i, T i < (⊤ : TopologicalSpace X) :=
  (phantom_reducible_iff (⊤ : TopologicalSpace X)).mpr indiscrete_reducible

/-- **Extremal dichotomy.**  On any space with at least two points the two extreme
topologies split oppositely: the indiscrete topology `⊤` is join-reducible (splittable
into two genuine observers), while the discrete topology `⊥` is phantom-rigid — nothing is
strictly finer than discrete, so it can never be the agreement of sharper viewpoints. -/
theorem extremal_phantom_dichotomy [Nontrivial X] :
    (∃ a b : TopologicalSpace X,
        a < (⊤ : TopologicalSpace X) ∧ b < (⊤ : TopologicalSpace X) ∧
          a ⊔ b = (⊤ : TopologicalSpace X)) ∧
    ¬ ∃ a b : TopologicalSpace X,
        a < (⊥ : TopologicalSpace X) ∧ b < (⊥ : TopologicalSpace X) ∧
          a ⊔ b = (⊥ : TopologicalSpace X) := by
  refine ⟨indiscrete_reducible, ?_⟩
  rintro ⟨a, b, ha, _, _⟩
  exact absurd ha (not_lt_bot)

end Phantom