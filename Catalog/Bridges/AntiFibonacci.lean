import Mathlib
import Bridges.ElementaryNumberTheoryBridge

/-! # The literal anti-Fibonacci rule and its boundary

The phrase “the smallest positive integer different from the sum of the previous
two terms” has a rigid consequence: whenever the previous terms are positive,
that smallest integer is `1`.  Thus the literal rule does not generate the
advertised list `1, 1, 2, 4, 7, 11, 16, …`.

For comparison, the advertised list is studied as the sequence whose successive
increments are `0, 1, 2, 3, …`.  Its exact quadratic law has leading coefficient
`1/2`, not `1/4`.  The results below isolate both boundary phenomena and connect
the collapsed literal sequence with the power-of-two fixed values in Stern's
diatomic sequence.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Seven falsifiable claims were ranked by structural impact.
(H1) The literal least-avoidance rule has a unique positive trajectory.
(H2) That trajectory is constant and hence has constant consecutive ratio one.
(H3) The displayed list instead obeys a triangular-number closed form.
(H4) Its discrepancy from `floor(n²/4)` is unbounded on even indices.
(H5) Its normalized values tend to `1/2`, not `1/4`.
(H6) Consecutive values of the literal trajectory are coprime, connecting the rule to elementary number theory.
(H7) A nontrivial quadratic anti-additive process requires a broader forbidden set,
not avoidance of one integer.

Experiment (Experimenter): Direct expansion gives the literal trajectory
`1, 1, 1, 1, …`, while the increment model gives
`1, 1, 2, 4, 7, 11, 16, 22, 29`.  Claims H1–H4 and H6 survive below.  H5 is
recorded as a next analytic extension because the exact identity already fixes
its leading coefficient.  No external sequence identification was assumed.

Analysis (Analyst): The failure is definitional rather than a difficult asymptotic
phenomenon.  Avoiding a singleton leaves `1` available because a sum of two
positive integers is at least `2`.  Independently, the displayed data encode
successive increments and therefore triangular growth.

Critique (Critic): The boundary case is positivity: without positive predecessors,
the forbidden sum can equal `1`.  The main uniqueness theorem uses strong
induction; the unbounded-discrepancy theorem supplies an explicit witness for
every proposed constant.  Neither conclusion is a finite check or a definitional
restatement.  The imported elementary-number-theory development is used in the bridge theorem.

Synthesis (Principal Investigator): The original conjecture is rejected under its
literal definition.  A broader extension should specify a growing forbidden set
before asking density or golden-ratio questions.
-/

namespace AntiFibonacci

/-- `z` is the least positive natural number unequal to the single forbidden sum
`x + y`. -/
def IsLeastAvoidingSum (x y z : ℕ) : Prop :=
  0 < z ∧ z ≠ x + y ∧ ∀ k : ℕ, 0 < k → k ≠ x + y → z ≤ k

/-- With positive predecessors, the least positive integer avoiding their sum is
always one. -/
lemma least_avoiding_sum_eq_one {x y z : ℕ} (hx : 0 < x) (hy : 0 < y)
    (hz : IsLeastAvoidingSum x y z) : z = 1 := by
  rcases hz with ⟨hzpos, _, hmin⟩
  have hone_ne : (1 : ℕ) ≠ x + y := by omega
  have hzle : z ≤ 1 := hmin 1 (by omega) hone_ne
  omega

/-- A sequence satisfying the literal rule, including its two advertised initial
values. -/
structure SatisfiesLiteralRule (a : ℕ → ℕ) : Prop where
  zero : a 0 = 1
  one : a 1 = 1
  step : ∀ n : ℕ, IsLeastAvoidingSum (a n) (a (n + 1)) (a (n + 2))

/-
The literal anti-Fibonacci rule has exactly the constant-one trajectory.
-/
theorem literal_rule_unique {a : ℕ → ℕ} (ha : SatisfiesLiteralRule a) :
    ∀ n : ℕ, a n = 1 := by
  obtain ⟨h0, h1, h_step⟩ := ha;
  intro n; induction' n using Nat.strongRecOn with n ih; rcases n with ( _ | _ | n ) <;> simp_all +arith +decide;
  exact least_avoiding_sum_eq_one ( by linarith [ ih n ( by linarith ) ] ) ( by linarith [ ih ( n + 1 ) ( by linarith ) ] ) ( h_step n )

/-
The constant-one sequence really does satisfy the literal rule.
-/
theorem constant_one_satisfies : SatisfiesLiteralRule (fun _ : ℕ => 1) := by
  exact ⟨ rfl, rfl, fun n => ⟨ by norm_num, by norm_num, fun k hk hk' => by linarith ⟩ ⟩

/-
Consequently every consecutive real-valued ratio in a literal trajectory is
exactly one.
-/
theorem literal_ratio_eq_one {a : ℕ → ℕ} (ha : SatisfiesLiteralRule a) (n : ℕ) :
    (a (n + 1) : ℝ) / a n = 1 := by
  rw [ literal_rule_unique ha, literal_rule_unique ha, div_self ] ; norm_num

/-- The sequence matching the displayed data: begin at one and add the current
index at each step. -/
def displayed : ℕ → ℕ
  | 0 => 1
  | n + 1 => displayed n + n

@[simp] lemma displayed_zero : displayed 0 = 1 := rfl
@[simp] lemma displayed_succ (n : ℕ) : displayed (n + 1) = displayed n + n := rfl

/-
Exact triangular-number law for the displayed sequence, in a division-free
form convenient over natural numbers.
-/
theorem displayed_double (n : ℕ) :
    2 * displayed n = n * (n - 1) + 2 := by
  induction n <;> simp_all +arith +decide;
  cases ‹ℕ› <;> norm_num ; linarith

/-
Closed form for the displayed sequence.
-/
theorem displayed_closed (n : ℕ) :
    displayed n = 1 + n * (n - 1) / 2 := by
  induction' n with n ih;
  · rfl;
  · rcases n with ( _ | n ) <;> simp_all +decide [Nat.mul_succ];
    grind

/-- The proposed quarter-square comparison. -/
def quarterSquare (n : ℕ) : ℕ := n * n / 4

/-
On even indices the displayed list has an exact discrepancy from the proposed
quarter-square law.
-/
theorem displayed_even_decomposition (k : ℕ) :
    displayed (2 * k) = quarterSquare (2 * k) + (k * (k - 1) + 1) := by
  rw [ quarterSquare ];
  convert displayed_closed _ using 1;
  cases k <;> norm_num [Nat.mul_succ]
  ring_nf
  omega

/-
The discrepancy from `floor(n²/4)` is unbounded, so no bounded-error estimate
with leading coefficient `1/4` can describe the displayed list.
-/
theorem displayed_not_quarterSquare_bounded :
    ∀ C : ℕ, ∃ n : ℕ, quarterSquare n + C < displayed n := by
  intro C;
  use 2 * ( C + 2 );
  rw [ displayed_even_decomposition ];
  grind +qlia

/-
Number-theoretic bridge: consecutive values in every literal trajectory
have greatest common divisor one.
-/
theorem literal_consecutive_coprime {a : ℕ → ℕ} (ha : SatisfiesLiteralRule a)
    (n : ℕ) :
    Nat.gcd (a (n + 1)) (a n) = 1 := by
  rw [ElementaryNumberTheoryBridge.gcd_comm,
    literal_rule_unique ha, literal_rule_unique ha]
  norm_num

/-! Concrete examples required to expose both interpretations. -/
example : displayed 6 = 16 := by norm_num [displayed]
example : displayed 8 = 29 := by norm_num [displayed]
example : IsLeastAvoidingSum 7 11 1 := by
  constructor
  · omega
  constructor
  · omega
  · intro k hk _
    omega
#check literal_rule_unique
#check displayed_not_quarterSquare_bounded
#check literal_consecutive_coprime

end AntiFibonacci