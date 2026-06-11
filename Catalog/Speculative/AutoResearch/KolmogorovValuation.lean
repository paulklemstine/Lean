import Physics.KolmogorovAxioms

/-!
# Kolmogorov Probability as a Lattice Valuation, and σ-Additivity

This file builds on `Physics.KolmogorovAxioms`.  It pushes the abstract
finitely-additive Kolmogorov axioms in two directions that are central to
Hilbert's sixth problem:

1. **Valuation theory.**  We generalize the two-event modular law
   (`KolmogorovSpace.prob_modular`) to the finite-additivity-over-a-family law
   and to the explicit inclusion–exclusion identity for three events.  These
   exhibit probability as a *valuation* on the Boolean algebra of events — the
   structural feature shared with topos / locale-theoretic models of physics.

2. **σ-additivity.**  We introduce the genuinely countable form of Kolmogorov's
   third axiom (`SigmaKolmogorovSpace`) and show it *refines* the finitely
   additive theory: every σ-additive space yields a finitely additive
   `KolmogorovSpace`.  The continuity-from-below theorem (Kolmogorov's
   monotone-continuity property) is stated as a conjecture for the next cycle.

## Main theorems
- `KolmogorovSpace.prob_biUnion_disjoint`: finite additivity over a `Finset` of
  pairwise-disjoint events (the n-event form of axiom K3).
- `KolmogorovSpace.prob_inclusion_exclusion_three`: inclusion–exclusion for three
  events.
- `SigmaKolmogorovSpace.toKolmogorov`: a σ-additive space is finitely additive.
- `SigmaKolmogorovSpace.continuity_from_below`: **conjecture** (deferred).
-/

namespace KolmogorovAxioms

open scoped BigOperators

namespace KolmogorovSpace

variable {Ω : Type*} (K : KolmogorovSpace Ω)

-- !-- Lab Notebook: prob_biUnion_disjoint -- !--
-- !-- Hypothesis: for a pairwise-disjoint finite family, K3 upgrades from ≤ to equality. -- !--
-- !-- Result: Finset induction; the inserted event is disjoint from the union of the rest. -- !--
-- !-- Insight: this is the n-event finite additivity; subadditivity (prob_biUnion_le) is its -- !--
-- !-- inequality shadow, recovered when the disjointness hypothesis is dropped. -- !--
-- !-- Failure analysis: the step needs `A a` disjoint from `⋃ i∈s, A i`, obtained from -- !--
-- !-- pairwise disjointness via Set.disjoint_iUnion / disjoint_right reasoning. -- !--
-- !-- End Lab Notebook -- !--
/-- **Finite additivity over a family**: for pairwise-disjoint events indexed by a
`Finset`, the probability of the union is the sum of the probabilities. -/
theorem prob_biUnion_disjoint {ι : Type*} (s : Finset ι) (A : ι → Set Ω)
    (hdisj : (s : Set ι).Pairwise (fun i j => Disjoint (A i) (A j))) :
    K.P (⋃ i ∈ s, A i) = ∑ i ∈ s, K.P (A i) := by
  induction' s using Finset.induction with i s hi ih generalizing A
  all_goals try exact Classical.decEq _
  · simpa using K.prob_empty
  · simp_all +decide
    rw [← ih A fun x hx y hy hxy => hdisj (by aesop) (by aesop) hxy, K.additive]
    exact Set.disjoint_iUnion₂_right.mpr fun j hj => hdisj (by aesop) (by aesop) (by aesop)

-- !-- Lab Notebook: prob_inclusion_exclusion_three -- !--
-- !-- Hypothesis: the three-event inclusion–exclusion identity follows from the modular law. -- !--
-- !-- Result: apply prob_modular to (A∪B) and C, then to A and B, and distribute ∩ over ∪. -- !--
-- !-- Insight: inclusion–exclusion is the valuation polynomial of the Boolean lattice; the -- !--
-- !-- two-event modular law generates every higher identity by recursion. -- !--
-- !-- Failure analysis: the key rewrite is (A∪B)∩C = (A∩C)∪(B∩C) before re-applying modular. -- !--
-- !-- End Lab Notebook -- !--
/-- **Inclusion–exclusion for three events.** -/
theorem prob_inclusion_exclusion_three (A B C : Set Ω) :
    K.P (A ∪ B ∪ C) =
      K.P A + K.P B + K.P C
        - K.P (A ∩ B) - K.P (A ∩ C) - K.P (B ∩ C)
        + K.P (A ∩ B ∩ C) := by
  have h_union : K.P (A ∪ B ∪ C) = K.P (A ∪ B) + K.P C - K.P ((A ∪ B) ∩ C) := by
    have := K.prob_modular (A ∪ B) C
    linarith
  have h_union_inter : K.P ((A ∪ B) ∩ C)
      = K.P (A ∩ C) + K.P (B ∩ C) - K.P ((A ∩ C) ∩ (B ∩ C)) := by
    have := K.prob_modular (A ∩ C) (B ∩ C)
    rw [← this, show (A ∪ B) ∩ C = A ∩ C ∪ B ∩ C by ext; aesop]; ring
  have h_modAB : K.P (A ∪ B) = K.P A + K.P B - K.P (A ∩ B) := by
    linarith [K.prob_modular A B]
  simp_all +decide [Set.inter_left_comm, Set.inter_assoc]; linarith

end KolmogorovSpace

/-! ## σ-additive Kolmogorov spaces (the full third axiom) -/

/-- A **σ-additive** Kolmogorov space: Kolmogorov's third axiom in its genuine
countably-additive form. -/
structure SigmaKolmogorovSpace (Ω : Type*) where
  /-- The probability assignment. -/
  P : Set Ω → ℝ
  /-- Non-negativity. -/
  nonneg : ∀ A, 0 ≤ P A
  /-- Normalization. -/
  prob_univ : P Set.univ = 1
  /-- Countable additivity on a pairwise-disjoint sequence of events. -/
  sigma_additive : ∀ (A : ℕ → Set Ω), Pairwise (fun i j => Disjoint (A i) (A j)) →
      P (⋃ i, A i) = ∑' i, P (A i)

namespace SigmaKolmogorovSpace

variable {Ω : Type*} (K : SigmaKolmogorovSpace Ω)

-- !-- Lab Notebook: toKolmogorov -- !--
-- !-- Hypothesis: σ-additivity implies finite additivity (the refinement is conservative). -- !--
-- !-- Result: pad two disjoint events A,B with ∅,∅,… into a sequence; its union is A∪B and -- !--
-- !-- its tsum collapses (eventually-zero) to P A + P B. -- !--
-- !-- Insight: the finitely additive theory is exactly the "first two terms" of the σ-theory; -- !--
-- !-- everything proved in KolmogorovAxioms transports to σ-spaces for free via this map. -- !--
-- !-- Failure analysis: P ∅ = 0 must be established first (σ-additivity of all-∅ gives a -- !--
-- !-- fixpoint P ∅ = ∑' P ∅, forcing P ∅ = 0) so the padded tail vanishes. -- !--
-- !-- End Lab Notebook -- !--
/-- A σ-additive space is in particular a finitely additive `KolmogorovSpace`. -/
noncomputable def toKolmogorov : KolmogorovAxioms.KolmogorovSpace Ω where
  P := K.P
  nonneg := K.nonneg
  prob_univ := K.prob_univ
  additive A B h := by
    convert K.sigma_additive (fun n => if n = 0 then A else if n = 1 then B else ∅) ?_ using 1
    · congr with x
      exact ⟨fun hx => by
          rcases hx with (hx | hx) <;>
            [exact Set.mem_iUnion.2 ⟨0, by simpa using hx⟩;
             exact Set.mem_iUnion.2 ⟨1, by simpa using hx⟩],
        fun hx => by
          rcases Set.mem_iUnion.1 hx with ⟨i, hi⟩
          rcases i with (_ | _ | i) <;> aesop⟩
    · rw [tsum_eq_sum]
      any_goals exact {0, 1}
      · simp +decide
      · have := K.sigma_additive (fun _ => ∅)
        simp_all +decide [Set.disjoint_iff_inter_eq_empty]
        exact fun _ _ _ => this fun i j hij => trivial
    · intro i j hij
      grind +qlia

-- !-- Proof sketch (conjecture, deferred) -- !--
-- !-- Continuity from below: for A monotone increasing, P(A n) → P(⋃ A n). -- !--
-- !-- Strategy: B 0 = A 0, B (n+1) = A (n+1) \ A n; the B's are disjoint with ⋃B = ⋃A, -- !--
-- !-- and the partial sums of P(B k) equal P(A n) by finite additivity, so they converge -- !--
-- !-- to ∑' P(B k) = P(⋃A). This is Kolmogorov's monotone-continuity property. -- !--
-- !-- End sketch -- !--
/-- **Conjecture (deferred): continuity from below.**  For a monotone increasing
sequence of events, the probabilities converge to the probability of the union.
This is Kolmogorov's monotone-continuity property, deferred to a future cycle. -/
theorem continuity_from_below (A : ℕ → Set Ω) (hmono : Monotone A) :
    Filter.Tendsto (fun n => K.P (A n)) Filter.atTop (nhds (K.P (⋃ n, A n))) := by
  sorry

end SigmaKolmogorovSpace

end KolmogorovAxioms