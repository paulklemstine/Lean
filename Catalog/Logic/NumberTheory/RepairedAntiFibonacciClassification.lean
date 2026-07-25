import Mathlib

/-!
# Classification of the repaired anti-Fibonacci process

The global additive repair from `Novelty.RepairedAntiFibonacci` is not merely
well-defined and increasing: its trajectory is forced exactly.  Starting from
one, the greedy process enumerates the positive odd integers.

The key point is that sums of earlier odd values are even.  At stage `n`, the
next odd value `2n+3` is therefore admissible, while the only smaller candidate
above `2n+1`, namely `2n+2`, is already the sum of the first and current values.
This gives both existence and uniqueness, and turns the earlier exponential
one-step ceiling into an exact linear law.
-/

namespace RepairedAntiFibonacci

noncomputable section

/-- Pair sums formed from values whose indices are strictly below `n`. -/
def priorPairSums (a : ℕ → ℕ) (n : ℕ) : Finset ℕ :=
  ((Finset.range n) ×ˢ (Finset.range n)).image fun ij => a ij.1 + a ij.2

/-- A candidate exceeds the current value and avoids every prior pair sum. -/
def AdmissibleAfter (a : ℕ → ℕ) (n z : ℕ) : Prop :=
  a n < z ∧ z ∉ priorPairSums a (n + 1)

/-- `z` is the least admissible successor after time `n`. -/
def IsGreedySuccessor (a : ℕ → ℕ) (n z : ℕ) : Prop :=
  AdmissibleAfter a n z ∧ ∀ w, AdmissibleAfter a n w → z ≤ w

/-- A repaired trajectory begins at one and always takes the least globally
additively admissible successor. -/
def SatisfiesRepairedRule (a : ℕ → ℕ) : Prop :=
  a 0 = 1 ∧ ∀ n, IsGreedySuccessor a n (a (n + 1))

/-- Membership in the restricted sumset has the expected witness form. -/
lemma mem_priorPairSums_iff {a : ℕ → ℕ} {n s : ℕ} :
    s ∈ priorPairSums a n ↔ ∃ i < n, ∃ j < n, a i + a j = s := by
  simp only [priorPairSums, Finset.mem_image, Finset.mem_product, Finset.mem_range]
  constructor
  · rintro ⟨⟨i, j⟩, ⟨hi, hj⟩, heq⟩
    exact ⟨i, hi, j, hj, heq⟩
  · rintro ⟨i, hi, j, hj, heq⟩
    exact ⟨⟨i, j⟩, ⟨hi, hj⟩, heq⟩

/-- The unique candidate trajectory: the positive odd integers. -/
def canonical (n : ℕ) : ℕ := 2 * n + 1

@[simp] theorem canonical_zero : canonical 0 = 1 := by
  norm_num [canonical]

/-- Restricted pair-sum sets depend only on the relevant finite prefix. -/
theorem priorPairSums_congr {a b : ℕ → ℕ} {n : ℕ}
    (h : ∀ i < n, a i = b i) :
    priorPairSums a n = priorPairSums b n := by
  classical
  ext s
  simp only [mem_priorPairSums_iff]
  constructor <;> rintro ⟨i, hi, j, hj, rfl⟩
  · exact ⟨i, hi, j, hj, by rw [h i hi, h j hj]⟩
  · exact ⟨i, hi, j, hj, by rw [← h i hi, ← h j hj]⟩

/-- Admissibility is invariant under replacement by an equal finite history. -/
theorem admissibleAfter_congr {a b : ℕ → ℕ} {n z : ℕ}
    (h : ∀ i ≤ n, a i = b i) :
    AdmissibleAfter a n z ↔ AdmissibleAfter b n z := by
  unfold AdmissibleAfter
  rw [h n (by omega), priorPairSums_congr (n := n + 1) (by
    intro i hi
    exact h i (by omega))]

/-- Greedy-successor status is invariant under replacement by an equal history. -/
theorem greedySuccessor_congr {a b : ℕ → ℕ} {n z : ℕ}
    (h : ∀ i ≤ n, a i = b i) :
    IsGreedySuccessor a n z ↔ IsGreedySuccessor b n z := by
  unfold IsGreedySuccessor
  simp only [admissibleAfter_congr h]

/-- A least admissible successor is unique. -/
theorem greedySuccessor_unique {a : ℕ → ℕ} {n x y : ℕ}
    (hx : IsGreedySuccessor a n x) (hy : IsGreedySuccessor a n y) : x = y := by
  exact Nat.le_antisymm (hx.2 y hy.1) (hy.2 x hx.1)

/-- At every stage, the next positive odd integer is admissible for the odd
history. -/
theorem canonical_next_admissible (n : ℕ) :
    AdmissibleAfter canonical n (canonical (n + 1)) := by
  constructor
  · simp [canonical]
  · rw [mem_priorPairSums_iff]
    rintro ⟨i, hi, j, hj, heq⟩
    simp only [canonical] at heq
    omega

/-- The next odd integer is the least admissible candidate.  The intervening
even integer is forbidden because it is `canonical 0 + canonical n`. -/
theorem canonical_greedy_successor (n : ℕ) :
    IsGreedySuccessor canonical n (canonical (n + 1)) := by
  refine ⟨canonical_next_admissible n, ?_⟩
  intro w hw
  by_contra hnot
  have hbetween : canonical n < w := hw.1
  have hwsmall : w < canonical (n + 1) := by omega
  simp only [canonical] at hbetween hwsmall
  have hweq : w = canonical 0 + canonical n := by
    simp only [canonical]
    omega
  apply hw.2
  rw [mem_priorPairSums_iff]
  exact ⟨0, by omega, n, by omega, hweq.symm⟩

/-- The positive odd integers satisfy the repaired global additive rule. -/
theorem canonical_satisfies_repaired_rule :
    SatisfiesRepairedRule canonical := by
  exact ⟨canonical_zero, canonical_greedy_successor⟩

/-- Complete rigidity theorem: the repaired rule has exactly one trajectory,
namely `1, 3, 5, 7, ...`. -/
theorem satisfies_repaired_rule_iff_eq_canonical (a : ℕ → ℕ) :
    SatisfiesRepairedRule a ↔ a = canonical := by
  constructor
  · intro ha
    funext n
    induction n using Nat.strong_induction_on with
    | h n ih =>
      cases n with
      | zero => exact ha.1
      | succ n =>
        have hp : ∀ i ≤ n, a i = canonical i := by
          intro i hi
          exact ih i (by omega)
        have htrans : IsGreedySuccessor canonical n (a (n + 1)) :=
          (greedySuccessor_congr hp).mp (ha.2 n)
        exact greedySuccessor_unique htrans (canonical_greedy_successor n)
  · rintro rfl
    exact canonical_satisfies_repaired_rule

/-- Pointwise form of the classification theorem. -/
theorem repaired_exact_value {a : ℕ → ℕ} (ha : SatisfiesRepairedRule a)
    (n : ℕ) : a n = 2 * n + 1 := by
  rw [(satisfies_repaired_rule_iff_eq_canonical a).mp ha]
  rfl

/-- The repaired process has constant first difference two. -/
theorem repaired_exact_increment {a : ℕ → ℕ} (ha : SatisfiesRepairedRule a)
    (n : ℕ) : a (n + 1) = a n + 2 := by
  rw [repaired_exact_value ha, repaired_exact_value ha]
  omega

/-- Every value in a repaired trajectory is odd. -/
theorem repaired_all_odd {a : ℕ → ℕ} (ha : SatisfiesRepairedRule a)
    (n : ℕ) : Odd (a n) := by
  rw [repaired_exact_value ha]
  exact ⟨n, by omega⟩

/-- Every repaired trajectory is strictly increasing. -/
theorem repaired_strictMono {a : ℕ → ℕ} (ha : SatisfiesRepairedRule a) :
    StrictMono a := by
  exact strictMono_nat_of_lt_succ (fun n => by rw [repaired_exact_increment ha n]; omega)

/-- The value set of every repaired trajectory is exactly the set of odd
natural numbers. -/
theorem repaired_range_eq_odds {a : ℕ → ℕ} (ha : SatisfiesRepairedRule a) :
    Set.range a = {x : ℕ | Odd x} := by
  rw [(satisfies_repaired_rule_iff_eq_canonical a).mp ha]
  ext x
  constructor
  · rintro ⟨n, rfl⟩
    exact ⟨n, by simp [canonical, two_mul]⟩
  · rintro ⟨n, rfl⟩
    exact ⟨n, by simp [canonical, two_mul, add_assoc]⟩

/-- The first `n` stages contain exactly `n` distinct values. -/
theorem repaired_prefix_card {a : ℕ → ℕ} (ha : SatisfiesRepairedRule a)
    (n : ℕ) : ((Finset.range n).image a).card = n := by
  rw [Finset.card_image_of_injective _ (repaired_strictMono ha).injective]
  exact Finset.card_range n

end

end RepairedAntiFibonacci