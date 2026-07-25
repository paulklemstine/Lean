import Mathlib

/-!
# Reduction-Enriched Complexity Hierarchies

This module develops an axiomatic theory of complexity hierarchies enriched with
abstract reduction relations. The central insight is that the combination of
a stratified hierarchy (monotone level assignment) with a compatible reduction
preorder yields rich structural consequences — completeness, separation transfer,
and cryptographic barrier theorems — all provable from the axioms alone.

## Main Definitions

* `ReductionHierarchy` — A hierarchy of problem classes with a compatible reduction preorder
* `IsComplete` — A problem is complete for a level if it's the hardest in that level
* `SeparationWitness` — Evidence that two levels are genuinely distinct
* `CryptoHierarchy` — Specialization to cryptographic primitive hierarchies
* `OracleExtension` — Abstract oracle augmentation for relativization results

## Main Results

* `complete_element_level_bound` — Complete elements are at their declared level
* `complete_incomparable_downward` — Complete elements at higher levels don't reduce downward
* `separation_witness_propagation` — Separation witnesses propagate upward
* `chain_level_strict_mono` — Reduction chains have strictly monotone levels
* `relativization_obstruction` — Conflicting oracles block uniform separation proofs
* `abstract_ladner` — Abstract Ladner: separated levels have intermediate problems
* `information_gap` — Information-theoretic lower bounds from level separation

## References

Builds on `UniversalComplexity` from `Bridges/UniversalComplexityBarriers.lean`.
-/

noncomputable section

open Set Function

set_option linter.dupNamespace false
namespace ReductionHierarchy

/-! ## Section 1: Core Definitions -/

/-- A `ReductionHierarchy` captures the essential structure of computational complexity:
    a universe of problems stratified into levels, with a reduction relation that
    respects the stratification. -/
structure ReductionHierarchy (Problem : Type*) where
  /-- Complexity level assignment -/
  level : Problem → ℕ
  /-- Reduction relation: A reduces to B means A is "no harder than" B -/
  reduces : Problem → Problem → Prop
  /-- Reduction is reflexive -/
  reduces_refl : ∀ p, reduces p p
  /-- Reduction is transitive -/
  reduces_trans : ∀ {a b c}, reduces a b → reduces b c → reduces a c
  /-- Reduction respects levels: reducing to something means your level is at most theirs -/
  reduces_level_le : ∀ {a b}, reduces a b → level a ≤ level b
  /-- The hierarchy is infinitely stratified -/
  infinite_levels : ∀ n, ∃ p, level p > n

/-- A problem is `complete` for level n if it's at level n and every level-n problem
    reduces to it. -/
def IsComplete {Problem : Type*} (H : ReductionHierarchy Problem)
    (p : Problem) (n : ℕ) : Prop :=
  H.level p = n ∧ ∀ q, H.level q = n → H.reduces q p

/-- A `SeparationWitness` between levels m and n provides a problem at level n
    that is strictly above level m. -/
structure SeparationWitness {Problem : Type*} (H : ReductionHierarchy Problem)
    (m n : ℕ) where
  witness : Problem
  at_level : H.level witness = n
  above : m < n

/-! ## Section 2: Complete Element Theory -/

/-
Complete elements are at their declared level (immediate from definition).
-/
theorem complete_element_level_bound {Problem : Type*}
    (H : ReductionHierarchy Problem) (p : Problem) (m n : ℕ)
    (hc : IsComplete H p n) (hmn : m < n) : H.level p ≠ m := by
  linarith [ hc.1 ]

/-
If q is complete for level n > m and p is complete for level m,
    then q does not reduce to p.
-/
theorem complete_incomparable_downward {Problem : Type*}
    (H : ReductionHierarchy Problem)
    {p q : Problem} {m n : ℕ}
    (hp : IsComplete H p m) (hq : IsComplete H q n)
    (hmn : m < n) : ¬H.reduces q p := by
  -- Assume H.reduces q p. By reduces_level_le, H.level q ≤ H.level p.
  by_contra h
  have h_le : H.level q ≤ H.level p := by
    exact H.reduces_level_le h;
  linarith [ hp.1, hq.1 ]

/-
Complete elements at the same level are mutually reducible.
-/
theorem complete_elements_equivalent {Problem : Type*}
    (H : ReductionHierarchy Problem)
    {p q : Problem} {n : ℕ}
    (hp : IsComplete H p n) (hq : IsComplete H q n) :
    H.reduces p q ∧ H.reduces q p := by
  unfold IsComplete at hp hq; aesop;

/-! ## Section 3: Separation Witness Propagation -/

/-- Separation witnesses propagate upward: a separation between m and n
    extends to a separation between m and any k > n. -/
def separation_witness_propagation {Problem : Type*}
    (H : ReductionHierarchy Problem)
    {m n : ℕ} (w : SeparationWitness H m n)
    {k : ℕ} (hk : k > n) (pk : Problem) (hpk : H.level pk = k) :
    SeparationWitness H m k :=
  ⟨pk, hpk, Nat.lt_trans w.above hk⟩

/-
Separation witnesses exist between any level and some higher level.
-/
theorem separation_witnesses_exist {Problem : Type*}
    (H : ReductionHierarchy Problem) (m : ℕ) :
    ∃ n > m, Nonempty (SeparationWitness H m n) := by
  obtain ⟨ p, hp ⟩ := H.infinite_levels m;
  exact ⟨ H.level p, hp, ⟨ p, rfl, hp ⟩ ⟩

/-! ## Section 4: Reduction Chains and Strict Monotonicity -/

/-- A `ReductionChain` is an infinite ascending sequence of problems with
    strictly increasing levels. -/
structure ReductionChain {Problem : Type*} (H : ReductionHierarchy Problem) where
  chain : ℕ → Problem
  ascending : ∀ i, H.reduces (chain i) (chain (i + 1))
  strict_levels : ∀ i, H.level (chain i) < H.level (chain (i + 1))

/-
Any element in a reduction chain reduces to any later element.
-/
theorem chain_reduces_forward {Problem : Type*}
    {H : ReductionHierarchy Problem}
    (C : ReductionChain H) {i j : ℕ} (hij : i ≤ j) :
    H.reduces (C.chain i) (C.chain j) := by
  induction' hij with k hk;
  · exact H.reduces_refl _;
  · exact H.reduces_trans ‹_› ( C.ascending k )

/-
Levels along a reduction chain are strictly monotone.
-/
theorem chain_level_strict_mono {Problem : Type*}
    {H : ReductionHierarchy Problem}
    (C : ReductionChain H) : StrictMono (fun i => H.level (C.chain i)) := by
  exact strictMono_nat_of_lt_succ fun i => C.strict_levels i

/-
A reduction chain witnesses unbounded levels.
-/
theorem chain_unbounded_levels {Problem : Type*}
    {H : ReductionHierarchy Problem}
    (C : ReductionChain H) : ∀ N, ∃ i, H.level (C.chain i) > N := by
  intro N
  by_contra h_contra
  push_neg at h_contra
  have h_bounded : ∀ i, H.level (C.chain i) ≤ N := by
    exact h_contra;
  exact absurd ( Set.infinite_range_of_injective ( chain_level_strict_mono C ).injective ) ( Set.not_infinite.mpr <| Set.finite_iff_bddAbove.mpr ⟨ N, by rintro a ⟨ i, rfl ⟩ ; exact h_bounded i ⟩ )

/-! ## Section 5: Abstract Ladner Theorem -/

/-- A problem is intermediate between levels m and n. -/
def IsIntermediate {Problem : Type*} (H : ReductionHierarchy Problem)
    (p : Problem) (m n : ℕ) : Prop :=
  m < H.level p ∧ H.level p < n

/-
**Abstract Ladner Theorem**: Given a dense hierarchy with a gap of ≥ 2
    between levels m and n, intermediate problems exist.
-/
theorem abstract_ladner {Problem : Type*}
    (H : ReductionHierarchy Problem)
    {m n : ℕ} (hmn : m + 2 ≤ n)
    (dense : ∀ k, m < k → k < n → ∃ p, H.level p = k) :
    ∃ p, IsIntermediate H p m n := by
  obtain ⟨ p, hp ⟩ := dense ( m + 1 ) ( by linarith ) ( by linarith ) ; exact ⟨ p, by linarith, by linarith ⟩ ;

/-! ## Section 6: Cryptographic Hierarchy -/

/-- A `CryptoHierarchy` enriches the reduction hierarchy with security thresholds,
    modeling the hierarchy of cryptographic primitives. -/
structure CryptoHierarchy (Primitive : Type*) extends ReductionHierarchy Primitive where
  securityThreshold : Primitive → ℕ
  threshold_monotone : ∀ {a b}, reduces a b → securityThreshold a ≤ securityThreshold b
  owf_base : ∃ p, level p = 0

/-
In a crypto hierarchy, if a is strictly harder than b,
    a cannot simultaneously have lower threshold and reduce to b.
-/
theorem crypto_threshold_gap {Primitive : Type*}
    (CH : CryptoHierarchy Primitive)
    {a b : Primitive}
    (_ha : CH.level a > CH.level b)
    (hred : ¬CH.reduces a b) :
    ¬(CH.securityThreshold a ≤ CH.securityThreshold b ∧ CH.reduces a b) := by
  grind

/-! ## Section 7: Relativization Obstruction -/

/-- An `OracleExtension` augments problems with oracle access. -/
structure OracleExtension {Problem : Type*} (H : ReductionHierarchy Problem) where
  augment : Problem → Problem
  level_nondecreasing : ∀ p, H.level p ≤ H.level (augment p)
  preserves_reduces : ∀ {a b}, H.reduces a b → H.reduces (augment a) (augment b)

/-
**Relativization Obstruction**: If two oracles give conflicting orderings,
    no oracle-uniform proof can determine relative complexity.
-/
theorem relativization_obstruction {Problem : Type*}
    (H : ReductionHierarchy Problem)
    (O₁ O₂ : OracleExtension H)
    {a b : Problem}
    (_h₁ : H.level (O₁.augment a) < H.level (O₁.augment b))
    (h₂ : H.level (O₂.augment b) < H.level (O₂.augment a)) :
    ¬(∀ O : OracleExtension H,
      H.level (O.augment a) < H.level (O.augment b)) := by
  exact fun h => h₂.not_ge ( h O₂ |> le_of_lt )

/-! ## Section 8: Dense Chains and Hardness Condensation -/

/-- A `DenseChain` of length L has consecutive level differences of exactly 1. -/
structure DenseChain {Problem : Type*} (H : ReductionHierarchy Problem) (len : ℕ) where
  chain : Fin len → Problem
  unit_steps : ∀ i : Fin (len - 1),
    H.level (chain ⟨i.val + 1, by omega⟩) = H.level (chain ⟨i.val, by omega⟩) + 1
  ascending : ∀ i : Fin (len - 1),
    H.reduces (chain ⟨i.val, by omega⟩) (chain ⟨i.val + 1, by omega⟩)

/-
**Hardness Condensation**: Dense hierarchies with compatible reductions
    admit arbitrarily long dense chains starting from level 0.
-/
theorem hardness_condensation {Problem : Type*}
    (H : ReductionHierarchy Problem)
    (dense : ∀ n : ℕ, ∃ p, H.level p = n)
    (reduces_at_adjacent : ∀ n : ℕ, ∀ p q : Problem,
      H.level p = n → H.level q = n + 1 → H.reduces p q)
    (L : ℕ) (hL : L ≥ 2) :
    ∃ C : DenseChain H L, H.level (C.chain ⟨0, by omega⟩) = 0 := by
  choose f hf using dense;
  refine' ⟨ ⟨ fun i => f i, _, _ ⟩, _ ⟩ <;> aesop

/-! ## Section 9: Information-Theoretic Lower Bounds -/

/-- An `InformationMeasure` assigns real-valued information content compatible
    with the hierarchy. -/
structure InformationMeasure {Problem : Type*} (H : ReductionHierarchy Problem) where
  info : Problem → ℝ
  info_nonneg : ∀ p, 0 ≤ info p
  info_monotone : ∀ {a b}, H.reduces a b → info a ≤ info b
  info_strict : ∀ {a b}, H.level a < H.level b → info a < info b

/-
**Information Gap Theorem**: Level-separated problems have strictly different
    information content.
-/
theorem information_gap {Problem : Type*}
    {H : ReductionHierarchy Problem}
    (μ : InformationMeasure H)
    {a b : Problem}
    (hsep : H.level a < H.level b) :
    μ.info a < μ.info b := by
  convert μ.info_strict hsep using 1

/-! ## Section 10: Falsifiable Conjecture

**Conjecture (Reduction Completeness from Density)**:
In any dense reduction hierarchy (every ℕ level is realized), if the reduction
relation is downward dense (for any problem p at level n+1, there exists q at
level n reducing to p), then every level has a complete element.

**Testable**: Construct a hierarchy that is dense and downward-connected but
where some level lacks a complete element, or prove the conjecture. -/

def ReductionCompletenessConjecture (Problem : Type*) : Prop :=
  ∀ (H : ReductionHierarchy Problem),
    (∀ n : ℕ, ∃ p, H.level p = n) →
    (∀ (p : Problem), H.level p > 0 →
      ∃ q, H.level q = H.level p - 1 ∧ H.reduces q p) →
    ∀ n : ℕ, ∃ p, IsComplete H p n

end ReductionHierarchy