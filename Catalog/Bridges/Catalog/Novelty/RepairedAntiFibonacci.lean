import Mathlib
import Bridges.AntiFibonacci

/-!
# Global additive avoidance as a repaired anti-Fibonacci rule

A nonconstant replacement for the literal rule must exclude a growing set rather
than one current sum. Here a step exceeds the preceding value and avoids every
sum of two values already seen. The least admissible candidate is chosen.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): We tested existence, strict growth, chronological
sum-freeness, a doubling growth ceiling, an empty additive hypergraph, and
compatibility with the displayed triangular prefix.

Experiment (Experimenter): The displayed prefix fails because `1+1=2`. For an
increasing history, every forbidden pair sum is at most twice the current value,
so `2a+1` is always available.

Analysis (Analyst): Monotonicity turns all pairwise inequalities into one uniform
ceiling on the restricted sumset. Minimality converts that ceiling into a growth
bound and additive avoidance into hypergraph emptiness.

Critique (Critic): Repeated summand indices are allowed. Avoidance is chronological,
not a claim that the value set is globally sum-free without regard to order.
Positivity and existence are explicit rather than hidden assumptions.

Synthesis (Principal Investigator): The repaired specification has an admissible
successor after every increasing finite history, forces strict growth, excludes
all chronological additive triples, and has a quantitative one-step ceiling.
-- !-- Lab Notes -- !--
-/

namespace RepairedAntiFibonacci

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

/-- Any increasing finite history admits the explicit candidate `2a(n)+1`. -/
lemma twice_plus_one_admissible {a : ℕ → ℕ} {n : ℕ}
    (hmono : ∀ i ≤ n, a i ≤ a n) :
    AdmissibleAfter a n (2 * a n + 1) := by
  constructor
  · omega
  · rw [mem_priorPairSums_iff]
    rintro ⟨i, hi, j, hj, hij⟩
    have hi' : i ≤ n := by omega
    have hj' : j ≤ n := by omega
    have hai := hmono i hi'
    have haj := hmono j hj'
    omega

/-- Every finite increasing history has a least globally admissible successor,
with an explicit quantitative upper bound. -/
theorem greedy_successor_exists {a : ℕ → ℕ} {n : ℕ}
    (hmono : ∀ i ≤ n, a i ≤ a n) :
    ∃ z, IsGreedySuccessor a n z ∧ z ≤ 2 * a n + 1 := by
  classical
  have hc := twice_plus_one_admissible hmono
  let z := Nat.find ⟨2 * a n + 1, hc⟩
  refine ⟨z, ⟨Nat.find_spec ⟨2 * a n + 1, hc⟩, ?_⟩, ?_⟩
  · intro w hw
    exact Nat.find_min' ⟨2 * a n + 1, hc⟩ hw
  · exact Nat.find_min' ⟨2 * a n + 1, hc⟩ hc

/-- The repaired rule forces strict monotonicity. -/
theorem repaired_strictMono {a : ℕ → ℕ} (ha : SatisfiesRepairedRule a) :
    StrictMono a := by
  apply strictMono_nat_of_lt_succ
  intro n
  exact (ha.2 n).1.1

/-- No value can equal a sum of two values at earlier indices. Repetition of the
two summand indices is permitted. -/
theorem repaired_avoids_chronological_sums {a : ℕ → ℕ}
    (ha : SatisfiesRepairedRule a) {i j k : ℕ} (hik : i < k) (hjk : j < k) :
    a i + a j ≠ a k := by
  cases k with
  | zero => omega
  | succ n =>
      have hnot := (ha.2 n).1.2
      rw [mem_priorPairSums_iff] at hnot
      intro heq
      apply hnot
      exact ⟨i, by omega, j, by omega, heq⟩

/-- Minimality and the explicit admissible witness give a uniform one-step growth
ceiling. -/
theorem repaired_growth_ceiling {a : ℕ → ℕ} (ha : SatisfiesRepairedRule a)
    (n : ℕ) :
    a (n + 1) ≤ 2 * a n + 1 := by
  have hmono : ∀ i ≤ n, a i ≤ a n := fun i hi =>
    (repaired_strictMono ha).monotone hi
  exact (ha.2 n).2 _ (twice_plus_one_admissible hmono)

/-- Chronological additive triples among the first `n` indices. -/
def additiveTriples (a : ℕ → ℕ) (n : ℕ) : Finset (ℕ × ℕ × ℕ) :=
  ((Finset.range n).product ((Finset.range n).product (Finset.range n))).filter fun t =>
    t.1 < t.2.2 ∧ t.2.1 < t.2.2 ∧ a t.1 + a t.2.1 = a t.2.2

/-- Extremal-combinatorial bridge: the chronological additive hypergraph of a
repaired trajectory has no edges. -/
theorem additiveTriples_eq_empty {a : ℕ → ℕ} (ha : SatisfiesRepairedRule a)
    (n : ℕ) :
    additiveTriples a n = ∅ := by
  apply Finset.not_nonempty_iff_eq_empty.mp
  intro hne
  rcases hne with ⟨t, ht⟩
  simp only [additiveTriples, Finset.mem_filter] at ht
  exact repaired_avoids_chronological_sums ha ht.2.1 ht.2.2.1 ht.2.2.2

/-- The displayed triangular sequence from the original proposal fails the global
repair at its third value, because its two initial ones sum to two. -/
theorem displayed_fails_repaired_rule :
    ¬ SatisfiesRepairedRule AntiFibonacci.displayed := by
  intro h
  have hstrict := repaired_strictMono h
  have := hstrict (show 0 < 1 by omega)
  norm_num [AntiFibonacci.displayed] at this

end RepairedAntiFibonacci