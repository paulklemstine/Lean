import Mathlib
import Catalog.Computation.UnionClosedAdjoinTop

/-!
# Cycle 4: chains, and a computable certificate for abundance

Two loose ends from cycles 1–3 are closed here.

* **Chains.**  `frankl_of_chain` proves Frankl's conjecture for every family that is totally
  ordered by inclusion and has a nonempty member.  Union-closedness is *not* assumed — it is
  automatic (`isUnionClosed_of_chain`) — and the argument is uniform in the size of the
  family: the elements of the smallest nonempty member lie in *every* nonempty member.
  Together with `frankl_of_card_le_four` of cycle 3 this gives two unconditional families of
  cases with completely different shapes: small families, and arbitrarily long chains.

* **Certificate.**  Deciding "does `F` have an abundant element of the ground set `s`?" needs
  no search over `s` beyond a single maximum:
  `exists_abundant_iff_card_le_two_mul_sup_deg` turns the existential into the numerical test
  `|F| ≤ 2 * max_{x ∈ s} deg F x`.  Cycle 1's operation improves that certificate monotonically
  (`sup_deg_le_sup_deg_adjoinTop`), which is the algorithmic shadow of the surplus calculus.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): (H11) Frankl's conjecture is provable outright for chains, with no
bound on the number of members; (H12) checking abundance is a single max-degree computation,
and adjoining the top never decreases that maximum.

Experiment (Experimenter): H11 proved via `Finset.exists_min_image` on the subfamily of
nonempty members: a member of minimum cardinality is contained in every nonempty member of a
chain, so each of its elements has degree at least `|F| - 1`, and `2 * (|F| - 1) ≥ |F|` for
`|F| ≥ 2` while `|F| = 1` is immediate.  H12 proved: the `↔` needs `Finset.exists_mem_eq_sup`
for the nontrivial direction, monotonicity follows from `deg` being monotone in the family.

Analysis (Analyst): the chain case and the small-family case are the two extremes of the same
counting: chains maximise "how many members contain a fixed minimal element" while small
families minimise "how many members there are to cover".  Both avoid the exponential loss
that cycle 3 showed to be unavoidable when only one member of size `≥ 2` is available.

Critique (Critic): the certificate theorem is an equivalence, not a shortcut for the
conjecture — computing `max deg` is linear in the family but the family itself can be
exponential in the ground set; nothing here reduces the complexity of the open problem.
-/

namespace Catalog.Computation.UnionClosedAdjoinTop

open Finset

variable {α : Type*} [DecidableEq α]

/-! ## Chains -/

/-- A family totally ordered by inclusion is automatically union-closed. -/
theorem isUnionClosed_of_chain {F : Finset (Finset α)}
    (hchain : ∀ A ∈ F, ∀ B ∈ F, A ⊆ B ∨ B ⊆ A) : IsUnionClosed F := by
  intro A hA B hB
  rcases hchain _ hA _ hB with h | h
  · rwa [Finset.union_eq_right.2 h]
  · rwa [Finset.union_eq_left.2 h]

/-- **Frankl's conjecture for chains.**  A family totally ordered by inclusion with a
nonempty member has an abundant element, whatever its size. -/
theorem frankl_of_chain {F : Finset (Finset α)}
    (hchain : ∀ A ∈ F, ∀ B ∈ F, A ⊆ B ∨ B ⊆ A) {A : Finset α} (hA : A ∈ F)
    (hA0 : A.Nonempty) : ∃ x, Abundant F x := by
  set S := F.filter (fun B => B.Nonempty) with hS
  have hSne : S.Nonempty := ⟨A, Finset.mem_filter.2 ⟨hA, hA0⟩⟩
  obtain ⟨M, hM, hMmin⟩ := Finset.exists_min_image S Finset.card hSne
  rw [hS, Finset.mem_filter] at hM
  obtain ⟨x, hx⟩ := hM.2
  refine ⟨x, ?_⟩
  have hsub : S ⊆ F.filter (fun B => x ∈ B) := by
    intro N hN
    have hN' := hN
    rw [hS, Finset.mem_filter] at hN'
    refine Finset.mem_filter.2 ⟨hN'.1, ?_⟩
    rcases hchain _ hM.1 _ hN'.1 with h | h
    · exact h hx
    · exact (Finset.eq_of_subset_of_card_le h (hMmin N hN)) ▸ hx
  have hdeg : S.card ≤ deg F x := Finset.card_le_card hsub
  have hcompl : F.filter (fun B => ¬ B.Nonempty) ⊆ {∅} := by
    intro B hB
    rw [Finset.mem_filter] at hB
    rw [Finset.mem_singleton, Finset.not_nonempty_iff_eq_empty.1 hB.2]
  have h1 : (F.filter (fun B => ¬ B.Nonempty)).card ≤ 1 := by
    simpa using Finset.card_le_card hcompl
  have hsplit : S.card + (F.filter (fun B => ¬ B.Nonempty)).card = F.card := by
    rw [hS, Finset.card_filter_add_card_filter_not]
  have h2 : 1 ≤ S.card := Finset.card_pos.2 hSne
  unfold Abundant
  omega

/-- The chain case survives adjoining the top, as cycle 1 predicts. -/
theorem frankl_adjoinTop_of_chain {F : Finset (Finset α)}
    (hchain : ∀ A ∈ F, ∀ B ∈ F, A ⊆ B ∨ B ⊆ A) {A : Finset α} (hA : A ∈ F)
    (hA0 : A.Nonempty) : ∃ x, Abundant (adjoinTop F) x := by
  obtain ⟨x, hx⟩ := frankl_of_chain hchain hA hA0
  exact ⟨x, abundant_adjoinTop_of_nonempty ⟨A, hA⟩ hx⟩

/-! ## A single-maximum certificate -/

/-- Degrees are monotone in the family. -/
theorem deg_mono {F G : Finset (Finset α)} (h : F ⊆ G) (x : α) : deg F x ≤ deg G x :=
  Finset.card_le_card (Finset.filter_subset_filter _ h)

/-- **Certificate.**  Over a nonempty ground set, the existence of an abundant element is
equivalent to a single numerical test on the maximum degree. -/
theorem exists_abundant_iff_card_le_two_mul_sup_deg {F : Finset (Finset α)} {s : Finset α}
    (hs : s.Nonempty) :
    (∃ x ∈ s, Abundant F x) ↔ F.card ≤ 2 * s.sup (fun x => deg F x) := by
  constructor
  · rintro ⟨x, hx, hax⟩
    have : deg F x ≤ s.sup (fun y => deg F y) := Finset.le_sup hx
    unfold Abundant at hax
    omega
  · intro h
    obtain ⟨x, hx, hxeq⟩ := Finset.exists_mem_eq_sup s hs (fun y => deg F y)
    exact ⟨x, hx, by unfold Abundant; omega⟩

/-- Adjoining the top never decreases the certificate's maximum degree. -/
theorem sup_deg_le_sup_deg_adjoinTop (F : Finset (Finset α)) (s : Finset α) :
    s.sup (fun x => deg F x) ≤ s.sup (fun x => deg (adjoinTop F) x) :=
  Finset.sup_mono_fun (fun x _ => deg_mono (subset_adjoinTop F) x)

/-- Consequently the certificate, once satisfied, stays satisfied after adjoining the top:
a purely computational restatement of cycle 1's main theorem. -/
theorem certificate_stable_adjoinTop {F : Finset (Finset α)} {s : Finset α}
    (hs : s.Nonempty) (h : F.card ≤ 2 * s.sup (fun x => deg F x)) :
    (adjoinTop F).card ≤ 2 * s.sup (fun x => deg (adjoinTop F) x) ∨ F = ∅ := by
  rcases F.eq_empty_or_nonempty with rfl | hne
  · exact Or.inr rfl
  · left
    obtain ⟨x, hx, hax⟩ := (exists_abundant_iff_card_le_two_mul_sup_deg hs).2 h
    have := abundant_adjoinTop_of_nonempty hne hax
    exact (exists_abundant_iff_card_le_two_mul_sup_deg hs).1 ⟨x, hx, this⟩

end Catalog.Computation.UnionClosedAdjoinTop