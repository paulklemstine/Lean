/-
# Mind and Mathematics: Gödel, Self-Reference, and the Infinite

Rudy Rucker's philosophical core in "Infinity and the Mind" is the relationship
between mathematical truth, formal systems, and consciousness. This module
formalizes results related to Gödel's incompleteness theorems, the limits
of formal systems, and self-referential structures.

## Rucker's Philosophical Claims:
- "The mind is not a machine" — inspired by Gödel's theorems
- Mathematical reality is objective and infinite
- Self-reference is the key to both consciousness and undecidability
-/

import Mathlib

namespace MindAndMathematics

/-! ## Self-Reference and Fixed Points

Rucker identifies self-reference as the common thread linking Cantor's
diagonal argument, Russell's paradox, Gödel's theorems, and consciousness.
The mathematical formalization of self-reference is the fixed point theorem. -/

/-- Every continuous function on [0,1] that maps [0,1] to [0,1] has a fixed point.
(Brouwer's fixed point theorem in 1D — the intermediate value theorem.)
Rucker sees fixed points as formalizations of "self-awareness." -/
theorem brouwer_1d (f : ℝ → ℝ) (hf : Continuous f)
    (h0 : 0 ≤ f 0) (h1 : f 1 ≤ 1) :
    ∃ x ∈ Set.Icc (0 : ℝ) 1, f x = x := by
  set g : ℝ → ℝ := fun x => f x - x
  have hg : ContinuousOn g (Set.Icc 0 1) :=
    hf.continuousOn.sub continuousOn_id
  have h_ivt : ∃ c ∈ Set.Icc 0 1, g c = 0 := by
    apply_rules [intermediate_value_Icc'] <;> aesop
  exact ⟨h_ivt.choose, h_ivt.choose_spec.1, sub_eq_zero.mp h_ivt.choose_spec.2⟩

/-! ## Boundary Points in Infinite Partitions

A consequence of the structure of ℕ: any partition into two infinite
pieces must have "boundary" points where membership changes. This
illustrates the idea that no decidable partition of ℕ can be "gap-free." -/

/-- For any infinite co-infinite subset of ℕ, there exists an element
in the set whose successor is not. -/
theorem exists_boundary_of_infinite_coinfinite
    {S : Set ℕ} (hS : Set.Infinite S) (hSc : Set.Infinite Sᶜ) :
    ∃ n, n ∈ S ∧ n + 1 ∉ S := by
  contrapose! hSc
  exact Set.finite_iff_bddAbove.mpr <| by
    rcases hS.nonempty with ⟨n, hn⟩
    exact ⟨n, fun m hm => not_lt.mp fun contra => hm <|
      Nat.le_induction (by aesop) (fun k hk ih => by aesop) m contra.le⟩

/-! ## The Mindscape: Platonic Mathematical Reality

Rucker argues for a Platonic view of mathematics — that mathematical objects
exist independently of human minds, in what he calls the "Mindscape."
We can formalize some structural properties of this mathematical universe. -/

/-- The powerset operation is monotone on cardinals: if κ ≤ μ then 2^κ ≤ 2^μ.
This captures Rucker's claim that the mathematical universe is
"inherently open-ended" — larger sets always have at least as many subsets.
(Note: strict monotonicity of 2^κ is independent of ZFC by Easton's theorem.) -/
theorem powerset_monotone :
    Monotone (fun κ : Cardinal => (2 : Cardinal) ^ κ) :=
  fun _ _ hab => Cardinal.power_le_power_left two_ne_zero hab

/-- There is no largest cardinal — the mathematical universe is unbounded.
Rucker: "There is no Absolute Infinity that can be captured in a set." -/
theorem no_largest_cardinal : ∀ κ : Cardinal, ∃ μ : Cardinal, κ < μ :=
  fun κ => ⟨_, Cardinal.cantor κ⟩

/-! ## Well-Ordering and Choice

Rucker discusses the Axiom of Choice and the Well-Ordering Theorem
as perhaps the most controversial results in set theory. -/

/-- Zorn's lemma: every non-empty partially ordered set in which every
chain has an upper bound contains a maximal element.
(Equivalent to the Axiom of Choice.) -/
theorem zorns_lemma_variant {α : Type*} [Nonempty α] [PartialOrder α]
    (h : ∀ c : Set α, IsChain (· ≤ ·) c → BddAbove c) :
    ∃ m : α, ∀ a, m ≤ a → a = m := by
  by_contra! h'
  obtain ⟨m, hm⟩ : ∃ m : α, ∀ a : α, m ≤ a → a ≤ m := by
    apply_rules [zorn_le, h]
  exact absurd (h' m) (by
    rintro ⟨a, ha₁, ha₂⟩
    exact ha₂ (le_antisymm (hm a ha₁) ha₁))

end MindAndMathematics
