/-
# Exact induced-subgraph thresholds inside complete graphs

For a finite pattern graph `H` and a complete host graph, induced containment has
an exact classification.  It occurs precisely when `H` is complete and the host
has at least as many vertices as `H`.  Thus the complete hosts exhibit a sharp
cardinality threshold for complete patterns and exclude every noncomplete pattern
at every order.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Induced containment in a complete host should forget all
  structure except two obstructions: a nonedge in the pattern, or insufficient
  host cardinality.  This predicts an exact threshold rather than merely a
  one-sided freeness criterion.
Experiment (Experimenter): An induced embedding into a complete graph reflects
  adjacency, forcing every distinct pattern pair to be adjacent.  Conversely,
  when the pattern is complete, any type embedding is automatically an induced
  graph embedding; finite cardinal comparison supplies such an embedding exactly
  at the predicted threshold.
Analysis (Analyst): The argument separates graph structure from finite-set order.
  Extensionality converts adjacency reflection into equality with the complete
  graph, while the existence theorem for embeddings converts containment into a
  cardinal inequality.  This yields both the containment theorem and its negated
  freeness trichotomy.
Critique (Critic): Empty patterns and empty hosts are included.  In particular,
  the empty graph on an empty type is complete and embeds into every host, while a
  nonempty complete pattern cannot embed into an empty host.  No nonemptiness
  assumption is silently required.
Synthesis (PI): Complete-host induced containment is now classified by a
  conjunction of completeness and order comparison, with freeness expressed by
  the complementary disjunction.  The earlier nonedge obstruction is recovered
  as a strict special case.
-/

import Catalog.Novelty.MinimallyToughP4Free

open SimpleGraph

namespace CompleteInducedThreshold

open ToughP4

variable {V W : Type*}

/-- If a finite graph occurs as an induced subgraph of a complete graph, then it
is itself complete and cannot have more vertices than its host. -/
theorem complete_and_card_le_of_induced_in_complete [Fintype V] [Fintype W]
    {H : SimpleGraph W}
    (h : ∃ f : W ↪ V, ∀ a b, H.Adj a b ↔ (⊤ : SimpleGraph V).Adj (f a) (f b)) :
    H = ⊤ ∧ Fintype.card W ≤ Fintype.card V := by
  refine ⟨?_, Fintype.card_le_of_injective _ h.choose.injective⟩
  ext a b
  by_cases ha : a = b <;> simp_all +decide

/-- A complete finite pattern whose order does not exceed that of the host occurs
as an induced subgraph of the complete host. -/
theorem induced_in_complete_of_complete_and_card_le [Fintype V] [Fintype W]
    {H : SimpleGraph W} (hH : H = ⊤)
    (hcard : Fintype.card W ≤ Fintype.card V) :
    ∃ f : W ↪ V, ∀ a b, H.Adj a b ↔ (⊤ : SimpleGraph V).Adj (f a) (f b) := by
  convert Function.Embedding.nonempty_of_card_le hcard
  constructor <;> intro <;> aesop

/-- **Exact complete-host containment threshold.**  A finite pattern occurs
induced in a complete host exactly when the pattern is complete and its order is
at most the host order. -/
theorem induced_in_complete_iff [Fintype V] [Fintype W] (H : SimpleGraph W) :
    (∃ f : W ↪ V, ∀ a b, H.Adj a b ↔ (⊤ : SimpleGraph V).Adj (f a) (f b)) ↔
      H = ⊤ ∧ Fintype.card W ≤ Fintype.card V := by
  constructor
  · exact complete_and_card_le_of_induced_in_complete
  · rintro ⟨hH, hcard⟩
    exact induced_in_complete_of_complete_and_card_le hH hcard

/-- **Forbidden-subgraph trichotomy for complete hosts.**  A complete host is
induced-`H`-free exactly when `H` is noncomplete or the host lies strictly below
`H`'s cardinality threshold. -/
theorem inducedFree_complete_iff [Fintype V] [Fintype W] (H : SimpleGraph W) :
    InducedFree H (⊤ : SimpleGraph V) ↔
      H ≠ ⊤ ∨ Fintype.card V < Fintype.card W := by
  rw [InducedFree, induced_in_complete_iff]
  grind

/-- At and above its order, a complete pattern always occurs in a complete host. -/
theorem not_inducedFree_complete_of_threshold [Fintype V] [Fintype W]
    {H : SimpleGraph W} (hH : H = ⊤)
    (hcard : Fintype.card W ≤ Fintype.card V) :
    ¬ InducedFree H (⊤ : SimpleGraph V) := by
  rw [inducedFree_complete_iff]
  aesop

/-- Below its order, every finite pattern is absent from the complete host, even
when the pattern itself is complete. -/
theorem inducedFree_complete_of_card_lt [Fintype V] [Fintype W]
    (H : SimpleGraph W) (hcard : Fintype.card V < Fintype.card W) :
    InducedFree H (⊤ : SimpleGraph V) := by
  apply (inducedFree_complete_iff H).mpr
  exact Or.inr hcard

end CompleteInducedThreshold