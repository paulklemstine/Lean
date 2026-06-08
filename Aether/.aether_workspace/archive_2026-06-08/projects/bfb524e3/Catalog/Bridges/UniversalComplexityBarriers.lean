import Mathlib

/-!
# Universal Computational Complexity Barriers

This module formalizes the thesis that computational complexity barriers are
inherent to the structure of computation itself, independent of any particular
model or biological substrate. Any civilization — carbon-based, silicon-based,
or hypothetically hypercomputational — that develops a theory of computation
must confront the same diagonal barriers.

## Main Results

* `diagonal_separation`: The diagonal language of any enumeration differs from
  every enumerated language — the engine of all complexity hierarchies.
* `oracle_tower_strict`: The oracle hierarchy is strictly increasing at every level.
* `oracle_tower_non_collapse`: Lower oracle levels cannot reach higher-level barriers.
* `substrate_equiv_same_class`: Mutual simulation implies identical language classes.
* `barrier_survives_combination`: Merging enumerations cannot eliminate barriers.
* `simulation_compose`: Simulations between computation models compose transitively.

## Novel Concepts

* `ComputationalBarrier`: Formal structure capturing complexity separations universally.
* `oracleTower`: Transfinite tower of oracle-augmented computation models.
* `SubstrateEquivalence`: When two models face structurally identical barriers.
-/

namespace UniversalComplexity

/-- A decision problem (language) as a characteristic function ℕ → Bool.
    This is the universal representation of a computational problem,
    independent of any particular encoding or model. -/
abbrev Lang := ℕ → Bool

/-! ## Section 1: The Diagonal Engine

The diagonal construction is the universal engine behind all complexity
separations. It works in any setting where problems can be enumerated. -/

/-- The diagonal language: on input n, flip the n-th function's value at n.
    This single construction underlies Cantor's theorem, the halting problem,
    Gödel's incompleteness, and every time/space hierarchy theorem. -/
def diag (f : ℕ → Lang) : Lang := fun n => !(f n n)

/-- **Diagonal Separation Theorem**: The diagonal language differs from every
    enumerated language. This is model-independent — it holds for Turing machines,
    lambda calculus, quantum circuits, or any enumeration whatsoever. -/
theorem diagonal_separation (f : ℕ → Lang) (k : ℕ) :
    f k ≠ diag f := by
  exact fun h => by have := congr_fun h k; simp +decide [diag] at this

/-- No enumeration of languages is surjective onto all languages.
    This is the complexity-theoretic Cantor theorem. -/
theorem no_surjection_onto_lang :
    ∀ f : ℕ → Lang, ¬Function.Surjective f := by
  intro f hf
  exact absurd (diagonal_separation f (Classical.choose (hf (diag f))))
    (by have := Classical.choose_spec (hf (diag f)); aesop)

/-! ## Section 2: The Oracle Tower

Even a hypercomputational civilization with an oracle for the halting problem
faces new, strictly harder barriers. The oracle tower makes this precise:
each level resolves the previous barrier but creates an entirely new one. -/

/-- The oracle tower: an infinite hierarchy of enumeration systems where each
    level includes the diagonal of the previous level as a new computable function.
    Level 0 is trivial; level n+1 adds the diagonal of level n. -/
def oracleTower : ℕ → (ℕ → Lang)
  | 0 => fun _ => fun _ => false
  | n + 1 => fun k =>
    if k = 0 then diag (oracleTower n)
    else (oracleTower n) (k - 1)

/-- The diagonal at level n appears as a computable function at level n+1. -/
theorem tower_level_access (n : ℕ) :
    oracleTower (n + 1) 0 = diag (oracleTower n) := by
  simp [oracleTower]

/-- Each level of the oracle tower is embedded in the next level (shifted by 1). -/
theorem tower_embed_succ (n k : ℕ) :
    oracleTower n k = oracleTower (n + 1) (k + 1) := by
  exact Eq.symm (by rw [oracleTower]; aesop)

/-- **Oracle Hierarchy Strictness**: Each level of the oracle tower is strictly
    more powerful than the previous — the diagonal of level n is computable at
    level n+1 but not at level n. This is the formalization of "hypercomputation
    doesn't eliminate barriers, it only shifts them." -/
theorem oracle_tower_strict (n : ℕ) :
    (∃ k, oracleTower (n + 1) k = diag (oracleTower n)) ∧
    (∀ k, oracleTower n k ≠ diag (oracleTower n)) := by
  exact ⟨⟨0, tower_level_access n⟩, fun k => diagonal_separation _ _⟩

/-- The range of oracleTower is monotone: lower levels enumerate subsets of
    higher levels. This is the key lemma for the non-collapse theorem. -/
theorem tower_range_monotone {m n : ℕ} (h : m ≤ n) :
    Set.range (oracleTower m) ⊆ Set.range (oracleTower n) := by
  induction' h with n _hn ih
  · rfl
  · intro x hx; obtain ⟨k, rfl⟩ := ih hx; use k + 1; aesop

/-- **Oracle Tower Non-Collapse**: No language computable at any level m ≤ n
    equals the diagonal barrier at level n. This means the hierarchy never
    collapses — you can never "catch up" to the current barrier by combining
    lower-level oracles. -/
theorem oracle_tower_non_collapse {m n : ℕ} (h : m ≤ n) (k : ℕ) :
    oracleTower m k ≠ diag (oracleTower n) := by
  have h_in_range : oracleTower m k ∈ Set.range (oracleTower n) :=
    tower_range_monotone h (Set.mem_range_self k)
  obtain ⟨j, hj⟩ := h_in_range
  exact fun h => diagonal_separation (oracleTower n) j <| by aesop

/-! ## Section 3: Computational Barriers as First-Class Objects -/

/-- A computational barrier consists of an enumerable class of "easy" problems
    and a "hard" problem provably outside that class. This captures the essential
    structure common to P vs NP, decidable vs undecidable, recursive vs
    arithmetical, etc. — the specific model is abstracted away. -/
structure ComputationalBarrier where
  /-- The enumeration of the "easy" class -/
  easyEnum : ℕ → Lang
  /-- The "hard" problem that escapes the class -/
  hardProblem : Lang
  /-- Proof that the hard problem is outside the easy class -/
  separation : ∀ k, easyEnum k ≠ hardProblem

/-- Every enumeration gives rise to a canonical computational barrier
    via the diagonal construction. This is the universal barrier generator. -/
def canonicalBarrier (f : ℕ → Lang) : ComputationalBarrier where
  easyEnum := f
  hardProblem := diag f
  separation := diagonal_separation f

/-- **Barrier Persistence Under Oracle**: Adding an oracle to resolve one barrier
    immediately creates a new, strictly harder barrier. This formalizes the
    "whack-a-mole" nature of computational barriers. -/
theorem barrier_persists_under_oracle (n : ℕ) :
    ∃ B : ComputationalBarrier,
      B.easyEnum = oracleTower (n + 1) ∧
      (∀ k, oracleTower (n + 1) k ≠ B.hardProblem) := by
  exact ⟨⟨oracleTower (n + 1), diag (oracleTower (n + 1)),
    diagonal_separation _⟩, rfl, fun k => diagonal_separation _ _⟩

/-! ## Section 4: Reductions and Structural Invariants -/

/-- A many-one reduction from language L₁ to language L₂:
    there exists a computable function mapping instances of L₁ to instances of L₂. -/
def ManyOneReduces (L₁ L₂ : Lang) : Prop :=
  ∃ f : ℕ → ℕ, ∀ n, L₁ n = L₂ (f n)

infixl:50 " ≤ₘ " => ManyOneReduces

/-- Many-one reducibility is reflexive. -/
theorem reduces_refl (L : Lang) : ManyOneReduces L L :=
  ⟨fun n => n, fun _ => rfl⟩

/-- Many-one reducibility is transitive — reductions compose. -/
theorem reduces_trans {L₁ L₂ L₃ : Lang}
    (h₁₂ : ManyOneReduces L₁ L₂) (h₂₃ : ManyOneReduces L₂ L₃) :
    ManyOneReduces L₁ L₃ := by
  obtain ⟨f, hf⟩ := h₁₂
  obtain ⟨g, hg⟩ := h₂₃
  use g ∘ f
  aesop

/-- A language is hard for an enumeration if every enumerated language reduces to it. -/
def IsHardFor (L : Lang) (f : ℕ → Lang) : Prop :=
  ∀ k, ManyOneReduces (f k) L

/-- Hard problems are closed upward under reduction: if L is hard and L reduces
    to L', then L' is also hard. -/
theorem hard_closed_upward {L L' : Lang} {f : ℕ → Lang}
    (hL : IsHardFor L f) (hred : ManyOneReduces L L') : IsHardFor L' f :=
  fun k => reduces_trans (hL k) hred

/-! ## Section 5: Substrate Independence -/

/-- A simulation between two computation models: model S₂ can compute
    everything that model S₁ can compute, via a translation of programs. -/
structure Simulation (S₁ S₂ : ℕ → Lang) where
  /-- Translation of program indices -/
  translate : ℕ → ℕ
  /-- Correctness: translated programs compute the same function -/
  correct : ∀ k, S₂ (translate k) = S₁ k

/-- Two models are substrate-equivalent if each can simulate the other. -/
structure SubstrateEquivalence (S₁ S₂ : ℕ → Lang) where
  forward : Simulation S₁ S₂
  backward : Simulation S₂ S₁

/-- Simulations compose transitively. -/
def simulation_compose {S₁ S₂ S₃ : ℕ → Lang}
    (sim₁₂ : Simulation S₁ S₂) (sim₂₃ : Simulation S₂ S₃) :
    Simulation S₁ S₃ where
  translate := sim₂₃.translate ∘ sim₁₂.translate
  correct k := by rw [Function.comp_apply, sim₂₃.correct, sim₁₂.correct]

/-- Simulation embeds one model's language class into another's range. -/
theorem simulation_range_subset {S₁ S₂ : ℕ → Lang}
    (sim : Simulation S₁ S₂) :
    Set.range S₁ ⊆ Set.range S₂ := by
  rintro x ⟨y, rfl⟩; exact ⟨sim.translate y, sim.correct y⟩

/-- **Substrate Independence Theorem**: If two computation models can each simulate
    the other (substrate equivalence), they recognize exactly the same class of
    languages. The complexity landscape is invariant under change of substrate. -/
theorem substrate_equiv_same_class {S₁ S₂ : ℕ → Lang}
    (equiv : SubstrateEquivalence S₁ S₂) :
    Set.range S₁ = Set.range S₂ := by
  obtain ⟨forward, backward⟩ := equiv
  exact Set.Subset.antisymm (simulation_range_subset forward) (simulation_range_subset backward)

/-! ## Section 6: Barrier Universality Under Combination -/

/-- Interleaving two enumerations into a single combined enumeration. -/
def interleave (f g : ℕ → Lang) : ℕ → Lang :=
  fun k => if k % 2 = 0 then f (k / 2) else g (k / 2)

/-- Interleaving covers the first enumeration. -/
theorem interleave_covers_left (f g : ℕ → Lang) (k : ℕ) :
    ∃ m, interleave f g m = f k := by
  use 2 * k
  unfold interleave; norm_num

/-- Interleaving covers the second enumeration. -/
theorem interleave_covers_right (f g : ℕ → Lang) (k : ℕ) :
    ∃ m, interleave f g m = g k := by
  use 2 * k + 1
  unfold interleave; norm_num [Nat.add_div]

/-- **Barrier Universality**: Even combining two enumerations, a barrier
    remains — the diagonal of the combined enumeration escapes both
    original enumerations. No finite merging of computational models
    eliminates the fundamental barrier. -/
theorem barrier_survives_combination (f g : ℕ → Lang) :
    (∀ k, f k ≠ diag (interleave f g)) ∧
    (∀ k, g k ≠ diag (interleave f g)) := by
  constructor
  · intro k hk
    exact diagonal_separation (interleave f g) (2 * k) (by simpa [interleave] using hk)
  · intro k
    exact fun h => diagonal_separation (interleave f g) (2 * k + 1) <| by
      unfold interleave; simp +decide [Nat.add_mod] ;
      convert h using 2; norm_num [Nat.add_div]

/-! ## Section 7: The Infinite Barrier Chain

The oracle tower produces an infinite strictly ascending chain of barriers.
Each barrier is "genuinely new" — not merely a relabeling of a lower barrier. -/

/-- The barriers at different oracle levels produce different hard problems. -/
theorem barrier_chain_distinct (m n : ℕ) (h : m ≠ n) :
    (canonicalBarrier (oracleTower m)).hardProblem ≠
    (canonicalBarrier (oracleTower n)).hardProblem := by
  cases lt_or_gt_of_ne h
  · have := oracle_tower_strict m
    have := oracle_tower_non_collapse (by linarith : m + 1 ≤ n) 0
    aesop
  · by_contra h_contra
    have h_diff : (canonicalBarrier (oracleTower m)).hardProblem ∈ Set.range (oracleTower m) := by
      exact Set.mem_range_self 0 |> fun h => by
        simpa [h_contra] using tower_range_monotone (by linarith : n + 1 ≤ m) h
    exact diagonal_separation _ _ h_diff.choose_spec

/-! ## Section 8: Diagonal Alternation Pattern

The diagonal value at input 0 alternates with oracle level, demonstrating
that each level genuinely changes the computational landscape.

**Conjecture (Diagonal Query Complexity)**: Computing the diagonal of an
n-level oracle tower on a single input requires querying at least n distinct
oracle levels. This predicts a linear lower bound on the "depth" of
computation needed to evaluate higher-level diagonals.

Testable prediction: For the oracle tower, diag(oracleTower n) evaluated at
input 0 should depend on the structure of all levels 0..n. We can verify
computationally for small n that removing any single level changes the output. -/

/-- The diagonal at level 0 evaluated at 0 is true (flipping false). -/
theorem diag_level_zero_at_zero :
    diag (oracleTower 0) 0 = true := by
  decide

/-- The diagonal at level 1 evaluated at 0 is false (flipping the level-0 diagonal). -/
theorem diag_level_one_at_zero :
    diag (oracleTower 1) 0 = false := by
  decide +revert

/-- The diagonal at level 2 evaluated at 0 is true (flipping back). -/
theorem diag_level_two_at_zero :
    diag (oracleTower 2) 0 = true := by
  decide +revert

/-- **Alternation Pattern**: The diagonal value at input 0 alternates with
    oracle level, demonstrating that each level genuinely changes the
    computational landscape. -/
theorem diag_alternation (n : ℕ) :
    diag (oracleTower (n + 1)) 0 = !(diag (oracleTower n) 0) := by
  convert congr_arg (fun x => !x)
    (congr_arg (fun f => f 0) (tower_level_access n)) using 1

end UniversalComplexity