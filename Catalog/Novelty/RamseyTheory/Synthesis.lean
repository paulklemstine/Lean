import Mathlib
import Novelty.RamseyTheory.RamseyProbabilisticLowerBound

/-!
# Finite avoidance, Ramsey counting, and Turán extremality

This chapter isolates a constructive finite core of the probabilistic method and
connects it to two extremal-combinatorial applications.  A family of bad sets is
handled by a greedy conditional-avoidance principle; the Ramsey result supplies
a nontrivial counting application, while Turán's theorem supplies the sharp
opposite extremal phenomenon.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): finite conditional avoidance should admit a choice-free
  formulation in which a surviving set of outcomes is enlarged one constraint at
  a time.  This mechanism should unify the union-bound proof of exponential Ramsey
  lower bounds with the deterministic extremal bounds of Turán theory.
Experiment (Experimenter): the surviving outcomes after constraints `S` are
  represented by a filtered finite set.  A one-step strict-cardinality condition
  produces a survivor for `insert i S`; induction then handles the full family.
  Existing finite Ramsey counting and Turán bounds were tested as endpoints of
  the same synthesis.
Analysis (Analyst): the finite induction survives without measure-theoretic
  infrastructure.  The dependency-degree estimate of the symmetric local lemma
  remains separate: its role is precisely to imply the one-step strict-cardinality
  hypothesis.  Ramsey counting and Turán extremality both fit into the common
  statement, but they use opposite sides of counting—avoidance versus maximization.
Critique (Critic): the avoidance theorem is not the full Lovász local lemma and
  makes no runtime claim.  It exposes, rather than conceals, the missing numerical
  dependency estimate.  The Ramsey component is a genuine Boolean-lattice union
  bound, and the Turán component is sharp on balanced bipartite graphs.
Synthesis (Principal Investigator): finite filtered-set induction is the common
  constructive core; exact event counting establishes Ramsey avoidance, whereas
  structural clique-freeness establishes the sharp Turán edge ceiling.
-/

open Finset SimpleGraph
open scoped Classical

namespace ProbabilisticMethodSynthesis

variable {Ω ι : Type*} [Fintype Ω] [Fintype ι] [DecidableEq Ω] [DecidableEq ι]

/-- Outcomes surviving all constraints indexed by `S`. -/
def survivors (bad : ι → Finset Ω) (S : Finset ι) : Finset Ω :=
  Finset.univ.filter fun ω => ∀ i ∈ S, ω ∉ bad i

/-- Adding one bad event to the constraint set filters the current survivors. -/
lemma survivors_insert (bad : ι → Finset Ω) (S : Finset ι) (i : ι) :
    survivors bad (insert i S) = (survivors bad S).filter fun ω => ω ∉ bad i := by
  ext ω
  simp [survivors]
  aesop

/-
A strict cardinal bound on the newly forbidden part leaves a survivor.
-/
lemma survivors_insert_nonempty_of_card_lt (bad : ι → Finset Ω) (S : Finset ι) (i : ι)
    (hlt : ((survivors bad S).filter fun ω => ω ∈ bad i).card < (survivors bad S).card) :
    (survivors bad (insert i S)).Nonempty := by
  simp_all +decide [survivors]
  exact Exists.elim (Finset.not_subset.1 fun h => hlt.not_ge <| Finset.card_le_card h)
    fun x hx => ⟨x, by aesop⟩

/-
**Finite conditional-avoidance principle.** If, whenever some outcomes have
survived a finite set of constraints, the next bad event occupies strictly fewer
than all current survivors, then one outcome avoids every bad event.
-/
theorem exists_avoiding_all_of_conditional_card_lt (ω₀ : Ω) (bad : ι → Finset Ω)
    (hstep : ∀ (S : Finset ι) (i : ι), i ∉ S → (survivors bad S).Nonempty →
      ((survivors bad S).filter fun ω => ω ∈ bad i).card < (survivors bad S).card) :
    ∃ ω : Ω, ∀ i : ι, ω ∉ bad i := by
  have h avoidanceSet : (survivors bad avoidanceSet).Nonempty := by
    induction' avoidanceSet using Finset.induction with i S hi ih;
    · exact ⟨ω₀, by simp +decide [survivors]⟩;
    · exact survivors_insert_nonempty_of_card_lt bad S i (hstep S i hi ih);
  exact Exists.elim ( h Finset.univ ) fun x hx => ⟨ x, fun i => by simpa using Finset.mem_filter.mp hx |>.2 i ( Finset.mem_univ i ) ⟩

/-- The balanced two-part Turán graph is triangle-free and attains the Mantel
bound.  This is the sharp deterministic companion to finite random avoidance. -/
lemma balanced_turan_sharp (m : ℕ) :
    (turanGraph (2 * m) 2).CliqueFree 3 ∧
      4 * #(turanGraph (2 * m) 2).edgeFinset = (2 * m) ^ 2 := by
  refine ⟨turanGraph_cliqueFree (by norm_num), ?_⟩
  rw [card_edgeFinset_turanGraph]
  have h : (2 * m) % 2 = 0 := by omega
  rw [h]
  simp
  ring_nf
  omega

/-- **Cross-domain synthesis.** The same finite combinatorial landscape contains
both an exponentially non-Ramsey complete graph coloring and the sharp balanced
Turán extremizer: `K₁₆` admits a red/blue coloring with no monochromatic `K₁₀`,
while every balanced complete bipartite graph is triangle-free and attains
Mantel's edge bound exactly. -/
theorem ramsey_avoidance_and_turan_sharpness (m : ℕ) :
    (¬ RamseyTheory.Arrows 16 10 10) ∧
    (turanGraph (2 * m) 2).CliqueFree 3 ∧
      4 * #(turanGraph (2 * m) 2).edgeFinset = (2 * m) ^ 2 := by
  exact ⟨RamseyTheory.ramsey_ten_lower, balanced_turan_sharp m⟩

end ProbabilisticMethodSynthesis