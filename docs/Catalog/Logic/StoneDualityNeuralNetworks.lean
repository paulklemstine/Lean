import Mathlib

/-!
# Stone duality and neural classifiers: precise positive results and counterexamples

A classifier induces a Boolean algebra of observable predicates, but several stronger
claims in the proposed framing fail.  This file isolates the failures without assuming
any particular implementation of neural networks.
-/

namespace StoneDualityNeuralNetworks

/-- The strict-threshold binary classifier on the real line. -/
noncomputable def thresholdClassifier (x : ℝ) : Bool := decide (0 < x)

/-- Its positive decision region. -/
def positiveRegion : Set ℝ := {x | thresholdClassifier x = true}

/-- Its nonpositive decision region. -/
def nonpositiveRegion : Set ℝ := {x | thresholdClassifier x = false}

/-- The classifier's two decision regions are exactly the expected half-lines. -/
theorem threshold_regions :
    positiveRegion = Set.Ioi 0 ∧ nonpositiveRegion = Set.Iic 0 := by
  constructor <;> ext x <;> simp [positiveRegion, nonpositiveRegion, thresholdClassifier]

/-- **Disproof of the Euclidean clopen claim.**  Even the decision region of one
nonconstant threshold neuron is not clopen in the usual topology on `ℝ`. -/
theorem positiveRegion_not_clopen : ¬ IsClopen positiveRegion := by
  rw [threshold_regions.1]
  intro h
  have hz : (0 : ℝ) ∈ closure (Set.Ioi 0) := by
    rw [closure_Ioi]
    simp
  have hc : IsClosed (Set.Ioi (0 : ℝ)) := h.isClosed
  have : (0 : ℝ) ∈ Set.Ioi 0 := by
    rw [← hc.closure_eq]
    exact hz
  exact (lt_irrefl (0 : ℝ)) (by simpa only [Set.mem_Ioi] using this)

/-- Activation vector of a list of scalar threshold neurons. -/
noncomputable def activationVector (bias : Fin k → ℝ) (x : ℝ) : Fin k → Bool :=
  fun i => decide (bias i < x)

/-- Two neurons having the same threshold can realize only the two constant activation
patterns, not all four elements of `Fin 2 → Bool`. -/
theorem duplicate_neurons_range :
    Set.range (activationVector (k := 2) (fun _ => 0)) =
      {p | p = (fun _ => false) ∨ p = (fun _ => true)} := by
  ext p
  constructor
  · rintro ⟨x, rfl⟩
    by_cases hx : 0 < x
    · right
      funext i
      simp [activationVector, hx]
    · left
      funext i
      simp [activationVector, hx]
  · intro hp
    rcases hp with rfl | rfl
    · refine ⟨0, ?_⟩
      funext i
      simp [activationVector]
    · refine ⟨1, ?_⟩
      funext i
      simp [activationVector]

/-- **Disproof of the `2^number-of-neurons` feasible-points claim.**  A two-neuron
network may have only two feasible activation patterns. -/
theorem duplicate_neurons_have_two_patterns :
    Set.ncard (Set.range (activationVector (k := 2) (fun _ => 0))) = 2 := by
  rw [duplicate_neurons_range]
  have hne : (fun _ : Fin 2 => false) ≠ (fun _ : Fin 2 => true) := by
    intro h
    have := congrFun h 0
    simp at this
  simpa [Set.setOf_or] using Set.ncard_pair hne.symm

/-- The full *formal* pattern type does have `2^k` elements.  The error in the bold
conjecture is identifying this type with the subset realizable by inputs. -/
theorem all_formal_patterns_card (k : ℕ) :
    Fintype.card (Fin k → Bool) = 2 ^ k := by
  simp

/-- A hypothesis class is a set of subsets, viewed as positive regions. -/
abbrev HypothesisClass (α : Type*) := Set (Set α)

/-- Standard finite-set shattering. -/
def Shatters {α : Type*} (H : HypothesisClass α) (C : Finset α) : Prop :=
  ∀ L : Finset α, L ⊆ C → ∃ h ∈ H, (C : Set α) ∩ h = L

/-- A class containing one fixed classifier cannot shatter a nonempty sample. -/
theorem singleton_class_not_shatter_nonempty {α : Type*} [DecidableEq α]
    (h : Set α) (C : Finset α) (hC : C.Nonempty) :
    ¬ Shatters ({h} : HypothesisClass α) C := by
  intro hs
  obtain ⟨x, hx⟩ := hC
  by_cases hxh : x ∈ h
  · obtain ⟨g, hg, heq⟩ := hs ∅ (by simp)
    have gh : g = h := by simpa using hg
    subst g
    have : x ∈ (C : Set α) ∩ h := ⟨by simpa, hxh⟩
    rw [heq] at this
    simp at this
  · obtain ⟨g, hg, heq⟩ := hs {x} (by simpa using hx)
    have gh : g = h := by simpa using hg
    subst g
    have : x ∈ (C : Set α) ∩ h := by
      rw [heq]
      simp
    exact hxh this.2

/-- Nevertheless the threshold classifier has two nonempty decision regions. -/
theorem threshold_has_two_nonempty_regions :
    positiveRegion.Nonempty ∧ nonpositiveRegion.Nonempty := by
  constructor
  · exact ⟨1, by simp [positiveRegion, thresholdClassifier]⟩
  · exact ⟨0, by simp [nonpositiveRegion, thresholdClassifier]⟩

/-- **Disproof of “VC dimension equals number of regions” for a fixed network.**
Its singleton hypothesis class shatters no one-point sample, despite having two
nonempty decision regions. -/
theorem fixed_threshold_cannot_shatter_singleton (x : ℝ) :
    ¬ Shatters ({positiveRegion} : HypothesisClass ℝ) {x} := by
  apply singleton_class_not_shatter_nonempty
  simp

/-- Pullback of a set along any map; this is the correct elementary mechanism by which
clopens of a finite discrete pattern space yield classifier predicates. -/
def pullback {α β : Type*} (encode : α → β) (s : Set β) : Set α := encode ⁻¹' s

/-- Boolean operations commute with semantic pullback. -/
theorem pullback_compl {α β : Type*} (encode : α → β) (s : Set β) :
    pullback encode sᶜ = (pullback encode s)ᶜ := by
  ext x
  rfl

/-- Boolean union also commutes with semantic pullback. -/
theorem pullback_union {α β : Type*} (encode : α → β) (s t : Set β) :
    pullback encode (s ∪ t) = pullback encode s ∪ pullback encode t := by
  ext x
  rfl

/-- If the pattern type is finite and discrete, every pattern predicate is clopen.
This gives a valid Stone-style semantics, but only after changing from Euclidean input
topology to the discrete pattern topology. -/
theorem finite_pattern_predicate_clopen {β : Type*} [Fintype β] [TopologicalSpace β]
    [DiscreteTopology β] (s : Set β) : IsClopen s := by
  exact isClopen_discrete s

end StoneDualityNeuralNetworks