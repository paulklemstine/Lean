import Logic.NumberTheory.RepairedAntiFibonacciClassification

/-!
# The distinct-summand repair

If the forbidden pair sums are required to use two distinct earlier indices, the
initial self-sum obstruction disappears.  The resulting greedy trajectory is

`1, 2, 4, 7, 10, 13, ...`.

After a two-step transient, every increment is three.  The mechanism is a
three-colour invariant: apart from the exceptional value two, all terms are
congruent to one modulo three.  Hence no sum of two distinct earlier terms is
congruent to one modulo three.  Meanwhile, adding the initial values one and
two to the current term forbids the two intervening candidates.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Six claims were tested: the distinct-index rule has a
unique trajectory; its first terms are `1, 2, 4, 7`; it is eventually an
arithmetic progression of difference three; a residue-class invariant explains
admissibility; the transient disappears after one step; and its value set has
asymptotic density one third.  The exact eventual progression was prioritized
because it links greedy sumset avoidance, modular colouring, and density.

Experiment (Experimenter): Direct finite search gives
`1, 2, 4, 7, 10, 13, 16, 19, 22, 25`.  At every stage from the third term onward,
the next two integers are the current term plus one and plus two, hence are
forbidden using the seeds one and two; the third is congruent to one modulo
three and survives every distinct pair sum.

Analysis (Analyst): Uniqueness, the displayed initial segment, eventual period
three, and the modular explanation survive.  The no-transient hypothesis fails:
the first increments are one and two before stabilizing at three.  The density
claim is strongly supported by the exact range description, but a filter-based
density theorem is left as a separate analytic extension.

Critique (Critic): Distinctness is used essentially at the second transition:
`2 + 2` would otherwise forbid four.  All boundary stages are treated
separately.  The classification is extensional and does not assume monotonicity;
strict growth follows from the greedy admissibility clause.

Synthesis (Principal Investigator): Requiring distinct summand indices changes
the odd-number trajectory into a finite transient followed by the residue class
one modulo three.  The seeds act as a complete local certificate of minimality,
while modular colouring gives the global avoidance certificate.
-- !-- Lab Notes -- !--
-/

namespace DistinctSummandTrajectory

noncomputable section

/-- Sums of values at two distinct indices strictly below `n`. -/
def distinctPriorPairSums (a : ℕ → ℕ) (n : ℕ) : Finset ℕ :=
  (((Finset.range n) ×ˢ (Finset.range n)).filter fun ij => ij.1 < ij.2).image
    fun ij => a ij.1 + a ij.2

/-- A candidate is larger than the current term and avoids all distinct-index
pair sums from the available prefix. -/
def DistinctAdmissibleAfter (a : ℕ → ℕ) (n z : ℕ) : Prop :=
  a n < z ∧ z ∉ distinctPriorPairSums a (n + 1)

/-- A candidate is the least admissible successor for the distinct-summand rule. -/
def IsDistinctGreedySuccessor (a : ℕ → ℕ) (n z : ℕ) : Prop :=
  DistinctAdmissibleAfter a n z ∧
    ∀ w, DistinctAdmissibleAfter a n w → z ≤ w

/-- A trajectory starts at one and repeatedly chooses the least value avoiding
all sums from two distinct earlier indices. -/
def SatisfiesDistinctRule (a : ℕ → ℕ) : Prop :=
  a 0 = 1 ∧ ∀ n, IsDistinctGreedySuccessor a n (a (n + 1))

/-- Witness form of membership in the restricted distinct-index sumset. -/
lemma mem_distinctPriorPairSums_iff {a : ℕ → ℕ} {n s : ℕ} :
    s ∈ distinctPriorPairSums a n ↔
      ∃ i < n, ∃ j < n, i < j ∧ a i + a j = s := by
  simp only [distinctPriorPairSums, Finset.mem_image, Finset.mem_filter,
    Finset.mem_product, Finset.mem_range]
  constructor
  · rintro ⟨⟨i, j⟩, ⟨⟨hi, hj⟩, hij⟩, hs⟩
    exact ⟨i, hi, j, hj, hij, hs⟩
  · rintro ⟨i, hi, j, hj, hij, hs⟩
    exact ⟨⟨i, j⟩, ⟨⟨hi, hj⟩, hij⟩, hs⟩

/-- The candidate trajectory, including its two-step transient. -/
def distinctCanonical : ℕ → ℕ
  | 0 => 1
  | 1 => 2
  | Nat.succ (Nat.succ n) => 3 * n + 4

@[simp] lemma distinctCanonical_zero : distinctCanonical 0 = 1 := rfl
@[simp] lemma distinctCanonical_one : distinctCanonical 1 = 2 := rfl
@[simp] lemma distinctCanonical_add_two (n : ℕ) :
    distinctCanonical (n + 2) = 3 * n + 4 := by
  rw [show n + 2 = Nat.succ (Nat.succ n) by omega]
  rfl

/-- Distinct pair sums from the canonical trajectory never occupy its stable
residue class modulo three. -/
lemma distinctCanonical_pair_sum_ne_next (n i j : ℕ)
    (hi : i < n + 3) (hj : j < n + 3) (hij : i < j) :
    distinctCanonical i + distinctCanonical j ≠ distinctCanonical (n + 3) := by
  rw [show n + 3 = (n + 1) + 2 by omega, distinctCanonical_add_two]
  cases i with
  | zero =>
      cases j with
      | zero => omega
      | succ j =>
          cases j with
          | zero => simp [distinctCanonical]
          | succ j => simp [distinctCanonical]; omega
  | succ i =>
      cases i with
      | zero =>
          cases j with
          | zero => omega
          | succ j =>
              cases j with
              | zero => omega
              | succ j => simp [distinctCanonical]; omega
      | succ i =>
          cases j with
          | zero => omega
          | succ j =>
              cases j with
              | zero => omega
              | succ j => simp [distinctCanonical]; omega

/-- Beyond the transient, the next term is globally admissible. -/
lemma distinctCanonical_stable_admissible (n : ℕ) :
    DistinctAdmissibleAfter distinctCanonical (n + 2)
      (distinctCanonical (n + 3)) := by
  constructor
  · simp [distinctCanonical_add_two]
  · rw [mem_distinctPriorPairSums_iff]
    rintro ⟨i, hi, j, hj, hij, heq⟩
    exact distinctCanonical_pair_sum_ne_next n i j hi hj hij heq

/-- Beyond the transient, the two intervening candidates are forbidden by
adding the seeds one and two to the current value. -/
lemma distinctCanonical_stable_minimal (n w : ℕ)
    (hw : DistinctAdmissibleAfter distinctCanonical (n + 2) w) :
    distinctCanonical (n + 3) ≤ w := by
  by_contra h
  have hlow := hw.1
  simp only [distinctCanonical_add_two] at hlow h
  have hwcases : w = (3 * n + 4) + 1 ∨ w = (3 * n + 4) + 2 := by omega
  apply hw.2
  rw [mem_distinctPriorPairSums_iff]
  rcases hwcases with rfl | rfl
  · exact ⟨0, by omega, n + 2, by omega, by omega,
      by simp [distinctCanonical_add_two]; omega⟩
  · exact ⟨1, by omega, n + 2, by omega, by omega,
      by simp [distinctCanonical_add_two]; omega⟩

/-- Every transition of the candidate trajectory obeys the greedy rule. -/
theorem distinctCanonical_greedy_successor (n : ℕ) :
    IsDistinctGreedySuccessor distinctCanonical n (distinctCanonical (n + 1)) := by
  cases n with
  | zero =>
      constructor
      · constructor
        · simp [distinctCanonical]
        · rw [mem_distinctPriorPairSums_iff]
          omega
      · intro w hw
        have hlt : 1 < w := by simpa [distinctCanonical] using hw.1
        simp [distinctCanonical]
        omega
  | succ n =>
      cases n with
      | zero =>
          constructor
          · constructor
            · simp [distinctCanonical]
            · rw [mem_distinctPriorPairSums_iff]
              rintro ⟨i, hi, j, hj, hij, heq⟩
              have hi0 : i = 0 := by omega
              have hj1 : j = 1 := by omega
              subst i
              subst j
              simp [distinctCanonical] at heq
          · intro w hw
            by_contra h
            have hlt : 2 < w := by simpa [distinctCanonical] using hw.1
            have : w = 3 := by
              simp [distinctCanonical] at h
              omega
            subst w
            apply hw.2
            rw [mem_distinctPriorPairSums_iff]
            exact ⟨0, by omega, 1, by omega, by omega, by simp [distinctCanonical]⟩
      | succ n =>
          exact ⟨distinctCanonical_stable_admissible n,
            distinctCanonical_stable_minimal n⟩

/-- The explicit trajectory satisfies the distinct-summand rule. -/
theorem distinctCanonical_satisfies :
    SatisfiesDistinctRule distinctCanonical := by
  exact ⟨rfl, distinctCanonical_greedy_successor⟩

/-- Distinct restricted sumsets depend only on the indicated finite prefix. -/
lemma distinctPriorPairSums_congr {a b : ℕ → ℕ} {n : ℕ}
    (h : ∀ i < n, a i = b i) :
    distinctPriorPairSums a n = distinctPriorPairSums b n := by
  classical
  ext s
  simp only [mem_distinctPriorPairSums_iff]
  constructor <;> rintro ⟨i, hi, j, hj, hij, rfl⟩
  · exact ⟨i, hi, j, hj, hij, by rw [h i hi, h j hj]⟩
  · exact ⟨i, hi, j, hj, hij, by rw [← h i hi, ← h j hj]⟩

/-- Greedy successor status is invariant under equal finite histories. -/
lemma distinctGreedySuccessor_congr {a b : ℕ → ℕ} {n z : ℕ}
    (h : ∀ i ≤ n, a i = b i) :
    IsDistinctGreedySuccessor a n z ↔ IsDistinctGreedySuccessor b n z := by
  have hs : distinctPriorPairSums a (n + 1) = distinctPriorPairSums b (n + 1) :=
    distinctPriorPairSums_congr (fun i hi => h i (by omega))
  unfold IsDistinctGreedySuccessor DistinctAdmissibleAfter
  rw [h n (by omega), hs]

/-- Least admissible successors are unique. -/
lemma distinctGreedySuccessor_unique {a : ℕ → ℕ} {n x y : ℕ}
    (hx : IsDistinctGreedySuccessor a n x)
    (hy : IsDistinctGreedySuccessor a n y) : x = y := by
  exact Nat.le_antisymm (hx.2 y hy.1) (hy.2 x hx.1)

/-- Complete classification of the distinct-summand repair. -/
theorem satisfies_distinct_rule_iff_eq_canonical (a : ℕ → ℕ) :
    SatisfiesDistinctRule a ↔ a = distinctCanonical := by
  constructor
  · intro ha
    funext n
    induction n using Nat.strong_induction_on with
    | h n ih =>
      cases n with
      | zero => exact ha.1
      | succ n =>
        have hp : ∀ i ≤ n, a i = distinctCanonical i := by
          intro i hi
          exact ih i (by omega)
        have ht : IsDistinctGreedySuccessor distinctCanonical n (a (n + 1)) :=
          (distinctGreedySuccessor_congr hp).mp (ha.2 n)
        exact distinctGreedySuccessor_unique ht (distinctCanonical_greedy_successor n)
  · rintro rfl
    exact distinctCanonical_satisfies

/-- Every classified trajectory has constant increment three after index two. -/
theorem distinct_rule_eventual_increment {a : ℕ → ℕ}
    (ha : SatisfiesDistinctRule a) (n : ℕ) :
    a (n + 3) = a (n + 2) + 3 := by
  rw [(satisfies_distinct_rule_iff_eq_canonical a).mp ha]
  simp [distinctCanonical_add_two]
  omega

/-- Exact range classification: the values are the exceptional seed two together
with the positive naturals congruent to one modulo three. -/
theorem distinct_rule_range {a : ℕ → ℕ} (ha : SatisfiesDistinctRule a) :
    Set.range a = {x : ℕ | x = 2 ∨ ∃ k : ℕ, x = 3 * k + 1} := by
  rw [(satisfies_distinct_rule_iff_eq_canonical a).mp ha]
  ext x
  constructor
  · rintro ⟨n, rfl⟩
    cases n with
    | zero => exact Or.inr ⟨0, by simp [distinctCanonical]⟩
    | succ n =>
      cases n with
      | zero => exact Or.inl rfl
      | succ n => exact Or.inr ⟨n + 1, by simp [distinctCanonical]; omega⟩
  · rintro (rfl | ⟨k, rfl⟩)
    · exact ⟨1, rfl⟩
    · cases k with
      | zero => exact ⟨0, by simp [distinctCanonical]⟩
      | succ k => exact ⟨k + 2, by simp [distinctCanonical_add_two]; omega⟩

end

end DistinctSummandTrajectory