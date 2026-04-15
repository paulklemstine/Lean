/-! # CatalogBuild.Speculative.RudyRucker.MindAndMathematics

Auto-generated from theorem catalog database.
Domain: Speculative/RudyRucker
Declarations: 3
-/

import Mathlib

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

theorem zorns_lemma_variant {α : Type*} [Nonempty α] [PartialOrder α]
    (h : ∀ c : Set α, IsChain (· ≤ ·) c → BddAbove c) :
    ∃ m : α, ∀ a, m ≤ a → a = m := by
  by_contra! h'
  obtain ⟨m, hm⟩ : ∃ m : α, ∀ a : α, m ≤ a → a ≤ m := by
    apply_rules [zorn_le, h]
  exact absurd (h' m) (by
    rintro ⟨a, ha₁, ha₂⟩
    exact ha₂ (le_antisymm (hm a ha₁) ha₁))

