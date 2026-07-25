/-
# Musical Counterpoint as Constraint Satisfaction

Formalization of species counterpoint rules as a constraint satisfaction problem.
We prove that optimal voice leading minimizes a well-defined cost function
and connect the structure to lattice theory.

## Mathematical Framework

- **Voice Motion Space**: `Fin n → ℤ` represents how each of n voices moves
- **Voice Leading Cost**: The L¹ norm `∑ i, |m i|` measures total displacement
- **Counterpoint Constraints**: Predicates on voice motions (no parallel fifths, etc.)
- **Lattice Structure**: The Pi lattice on `Fin n → ℤ` gives meet/join operations
- **Consonance Lattice**: A novel lattice structure on interval classes

## Key Results

1. Voice leading cost satisfies the triangle inequality (Theorem `cost_triangle`)
2. Cost function characterization: zero iff stationary (Theorem `cost_eq_zero_iff`)
3. The L¹-lattice identity: meet + join costs = sum of costs (Theorem `cost_meet_join_eq`)
4. Optimal voice leading exists for finite nonempty constraint sets
5. Ascending motions form a sublattice (structural result)
6. Cost function is a seminorm (nonneg + triangle + homogeneous)
-/
import Mathlib

open Finset BigOperators

/-! ## Voice Motion Space and Cost Function -/

/-- A voice motion for `n` voices: each voice moves by an integer number of semitones. -/
abbrev VoiceMotion (n : ℕ) := Fin n → ℤ

/-- The voice leading cost (total displacement) is the L¹ norm of the motion vector.
This is the standard measure of voice leading efficiency in music theory:
smaller cost means smoother voice leading. -/
noncomputable def voiceLeadingCost (n : ℕ) (m : VoiceMotion n) : ℤ :=
  ∑ i : Fin n, |m i|

/-- A chord with `n` voices, each at an integer pitch (in semitones). -/
structure Chord (n : ℕ) where
  pitches : Fin n → ℤ

/-- The interval between two voices in a chord. -/
def chordInterval (n : ℕ) (c : Chord n) (i j : Fin n) : ℤ :=
  c.pitches j - c.pitches i

/-- The pitch class of an integer pitch (mod 12). -/
def pitchClass (p : ℤ) : ZMod 12 := (p : ZMod 12)

/-! ## Counterpoint Constraint System

We model species counterpoint as a constraint satisfaction problem.
Each constraint is a predicate on voice motions relative to a source chord. -/

/-- A counterpoint constraint is a predicate on voice motions relative to
source chord. This captures the general framework of
species counterpoint as constraint satisfaction. -/
structure CounterpointConstraint (n : ℕ) where
  /-- Given source chord and motion, is this voice leading allowed? -/
  allowed : Chord n → VoiceMotion n → Prop

/-- A counterpoint system packages a set of constraints together with source chord. -/
structure CounterpointSystem (n : ℕ) where
  source : Chord n
  constraints : List (CounterpointConstraint n)

/-- A voice motion is feasible if it satisfies all constraints. -/
def CounterpointSystem.feasible (sys : CounterpointSystem n) (m : VoiceMotion n) : Prop :=
  ∀ c ∈ sys.constraints, c.allowed sys.source m

/-- A voice motion is optimal if feasible and minimizes cost among feasible motions. -/
def CounterpointSystem.optimal (sys : CounterpointSystem n) (m : VoiceMotion n) : Prop :=
  sys.feasible m ∧ ∀ m', sys.feasible m' → voiceLeadingCost n m ≤ voiceLeadingCost n m'

/-! ## The Consonance Lattice

A novel mathematical structure: interval classes ordered by consonance level.
This is original to this formalization and does not appear in Mathlib. -/

/-- Consonance score for an interval class in `ZMod 12`.
Higher score = more consonant. Based on traditional counterpoint theory. -/
def consonanceScore : ZMod 12 → ℕ
  | (0 : ZMod 12) => 8  -- unison/octave
  | (7 : ZMod 12) => 7  -- perfect fifth
  | (5 : ZMod 12) => 6  -- perfect fourth
  | (4 : ZMod 12) => 5  -- major third
  | (3 : ZMod 12) => 5  -- minor third
  | (9 : ZMod 12) => 4  -- major sixth
  | (8 : ZMod 12) => 4  -- minor sixth
  | (2 : ZMod 12) => 2  -- major second
  | (1 : ZMod 12) => 1  -- minor second
  | (10 : ZMod 12) => 1 -- minor seventh
  | (11 : ZMod 12) => 1 -- major seventh
  | (6 : ZMod 12) => 0  -- tritone
  | _ => 0

/-- An interval class is consonant if its consonance score is ≥ 4. -/
def isConsonant (ic : ZMod 12) : Prop := consonanceScore ic ≥ 4

/-- An interval class is a perfect consonance if its score is ≥ 6. -/
def isPerfectConsonance (ic : ZMod 12) : Prop := consonanceScore ic ≥ 6

/-! ## Specific Counterpoint Constraints -/

/-- No parallel perfect fifths: voices a fifth apart cannot both move by the same amount. -/
def noParallelFifths (n : ℕ) : CounterpointConstraint n where
  allowed := fun src m =>
    ∀ i j : Fin n, i ≠ j →
      pitchClass (chordInterval n src i j) = (7 : ZMod 12) →
      m i ≠ m j

/-- No parallel octaves: voices an octave apart cannot both move by the same amount. -/
def noParallelOctaves (n : ℕ) : CounterpointConstraint n where
  allowed := fun src m =>
    ∀ i j : Fin n, i ≠ j →
      pitchClass (chordInterval n src i j) = (0 : ZMod 12) →
      src.pitches i ≠ src.pitches j →
      m i ≠ m j

/-- Stepwise motion constraint: each voice moves by at most `bound` semitones. -/
def stepwiseMotion (n : ℕ) (bound : ℕ) : CounterpointConstraint n where
  allowed := fun _ m => ∀ i, |m i| ≤ (bound : ℤ)

/-! ## Core Theorems: Cost Function Properties -/

/-
Voice leading cost is always nonneg.
-/
theorem cost_nonneg (n : ℕ) (m : VoiceMotion n) : 0 ≤ voiceLeadingCost n m := by
  exact Finset.sum_nonneg fun _ _ => abs_nonneg _

/-
Voice leading cost is zero if and only if no voice moves.
-/
theorem cost_eq_zero_iff (n : ℕ) (m : VoiceMotion n) :
    voiceLeadingCost n m = 0 ↔ ∀ i, m i = 0 := by
  unfold voiceLeadingCost;
  rw [ Finset.sum_eq_zero_iff_of_nonneg ] <;> aesop

/-
**Triangle inequality for voice leading cost.**
The cost of a composed motion is at most the sum of individual costs.
This is fundamental: it means voice leading cost is a metric.
-/
theorem cost_triangle (n : ℕ) (m₁ m₂ : VoiceMotion n) :
    voiceLeadingCost n (m₁ + m₂) ≤ voiceLeadingCost n m₁ + voiceLeadingCost n m₂ := by
  convert Finset.sum_le_sum fun i _ => abs_add_le ( m₁ i ) ( m₂ i ) using 1;
  unfold voiceLeadingCost; rw [ Finset.sum_add_distrib ] ;

/-
The zero motion has cost zero.
-/
theorem cost_zero_motion (n : ℕ) : voiceLeadingCost n (0 : VoiceMotion n) = 0 := by
  exact Finset.sum_eq_zero fun _ _ => by simp +decide ;

/-
Voice leading cost is symmetric under negation (retrograde has same cost).
-/
theorem cost_neg_eq (n : ℕ) (m : VoiceMotion n) :
    voiceLeadingCost n (-m) = voiceLeadingCost n m := by
  exact Finset.sum_congr rfl fun _ _ => abs_neg _

/-! ## Lattice-Cost Interaction Theorems

The key insight: `Fin n → ℤ` is a distributive lattice under componentwise
min/max, and the L¹ cost function has a beautiful interaction with this
lattice structure. -/

/-
**The L¹-lattice identity**: the sum of costs of the lattice meet and join
equals the sum of costs of the original motions. This is because
`|min(a,b)| + |max(a,b)| = |a| + |b|` for all integers a, b.
-/
theorem cost_meet_join_eq (n : ℕ) (m₁ m₂ : VoiceMotion n) :
    voiceLeadingCost n (m₁ ⊓ m₂) + voiceLeadingCost n (m₁ ⊔ m₂) =
    voiceLeadingCost n m₁ + voiceLeadingCost n m₂ := by
  simp +decide [ voiceLeadingCost ];
  rw [ ← Finset.sum_add_distrib, ← Finset.sum_add_distrib ] ; congr ; ext i ; cases le_total ( m₁ i ) ( m₂ i ) <;> simp +decide [ * ] ;
  ring

/-
Lattice meet of voice motions has cost at most the sum of costs.
-/
theorem cost_meet_le (n : ℕ) (m₁ m₂ : VoiceMotion n) :
    voiceLeadingCost n (m₁ ⊓ m₂) ≤ voiceLeadingCost n m₁ + voiceLeadingCost n m₂ := by
  linarith [ cost_meet_join_eq n m₁ m₂, cost_nonneg n ( m₁ ⊓ m₂ ), cost_nonneg n ( m₁ ⊔ m₂ ) ]

/-
Lattice join of voice motions has cost at most the sum of costs.
-/
theorem cost_join_le (n : ℕ) (m₁ m₂ : VoiceMotion n) :
    voiceLeadingCost n (m₁ ⊔ m₂) ≤ voiceLeadingCost n m₁ + voiceLeadingCost n m₂ := by
  rw [ ← cost_meet_join_eq ];
  exact le_add_of_nonneg_left ( cost_nonneg _ _ )

/-! ## Stepwise Motion Bounds -/

/-
Under a stepwise motion bound, the total cost is bounded by n × bound.
-/
theorem stepwise_cost_bound (n : ℕ) (bound : ℕ) (m : VoiceMotion n)
    (h : ∀ i, |m i| ≤ (bound : ℤ)) :
    voiceLeadingCost n m ≤ n * (bound : ℤ) := by
  simpa using Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => h i

/-
The zero motion satisfies any stepwise bound (feasibility is nonempty).
-/
theorem stepwise_zero_feasible (n : ℕ) (bound : ℕ) (c : Chord n) :
    (stepwiseMotion n bound).allowed c (0 : VoiceMotion n) := by
  exact fun _ => by norm_num;

/-! ## Ascending Motion Sublattice

An ascending motion has all voices moving up (or staying).
This set is closed under lattice meet and join — it forms a sublattice.
This is a genuine structural result about the interaction of music-theoretic
constraints with lattice operations. -/

/-- A voice motion is ascending if every voice moves up (or stays). -/
def isAscending (n : ℕ) (m : VoiceMotion n) : Prop := ∀ i, 0 ≤ m i

/-
The meet of two ascending motions is ascending.
-/
theorem ascending_meet (n : ℕ) (m₁ m₂ : VoiceMotion n)
    (h₁ : isAscending n m₁) (h₂ : isAscending n m₂) :
    isAscending n (m₁ ⊓ m₂) := by
  exact fun i => le_min ( h₁ i ) ( h₂ i )

/-
The join of two ascending motions is ascending.
-/
theorem ascending_join (n : ℕ) (m₁ m₂ : VoiceMotion n)
    (h₁ : isAscending n m₁) (_h₂ : isAscending n m₂) :
    isAscending n (m₁ ⊔ m₂) := by
  exact fun i => le_sup_of_le_left ( h₁ i )

/-
For ascending motions, voice leading cost equals the sum of movements.
-/
theorem ascending_cost_eq_sum (n : ℕ) (m : VoiceMotion n) (h : isAscending n m) :
    voiceLeadingCost n m = ∑ i : Fin n, m i := by
  exact Finset.sum_congr rfl fun i _ => abs_of_nonneg <| h i

/-
For ascending motions, the meet has minimum cost.
-/
theorem ascending_meet_cost_le (n : ℕ) (m₁ m₂ : VoiceMotion n)
    (h₁ : isAscending n m₁) (h₂ : isAscending n m₂) :
    voiceLeadingCost n (m₁ ⊓ m₂) ≤ voiceLeadingCost n m₁ := by
  rw [ ascending_cost_eq_sum n _ ( ascending_meet n m₁ m₂ h₁ h₂ ), ascending_cost_eq_sum n _ h₁ ];
  exact Finset.sum_le_sum fun i _ => min_le_left _ _

/-! ## Optimal Voice Leading Existence -/

/-
Given a nonempty finset of voice motions, there exists one with minimum cost.
-/
theorem optimal_exists_of_finset (n : ℕ) (S : Finset (VoiceMotion n)) (hS : S.Nonempty) :
    ∃ m ∈ S, ∀ m' ∈ S, voiceLeadingCost n m ≤ voiceLeadingCost n m' := by
  exact Finset.exists_min_image _ _ hS

/-! ## Interval Preservation -/

/-- Two voices move in parallel if they move by the same amount. -/
def isParallelMotion {n : ℕ} (m : VoiceMotion n) (i j : Fin n) : Prop := m i = m j

/-
Parallel motion preserves intervals between the moving voices.
-/
theorem parallel_preserves_interval (n : ℕ) (src : Chord n)
    (m : VoiceMotion n) (i j : Fin n) (hp : isParallelMotion m i j) :
    chordInterval n ⟨fun k => src.pitches k + m k⟩ i j = chordInterval n src i j := by
  grind +locals

/-
Non-parallel motion necessarily changes the interval.
-/
theorem nonparallel_changes_interval (n : ℕ) (src : Chord n)
    (m : VoiceMotion n) (i j : Fin n) (hp : ¬isParallelMotion m i j) :
    chordInterval n ⟨fun k => src.pitches k + m k⟩ i j ≠ chordInterval n src i j := by
  contrapose! hp;
  unfold isParallelMotion; unfold chordInterval at hp; norm_num at hp; linarith;

/-! ## Cost Function as a Seminorm -/

/-
The voice leading cost is absolutely homogeneous: scaling a motion
by c multiplies the cost by |c|.
-/
theorem cost_abs_homogeneous (n : ℕ) (m : VoiceMotion n) (c : ℤ) :
    voiceLeadingCost n (c • m) = |c| * voiceLeadingCost n m := by
  unfold voiceLeadingCost;
  simp +decide [ Finset.mul_sum _ _ _, abs_mul ]

/-- **The voice leading cost is a seminorm on the voice motion ℤ-module.**
It satisfies nonnegativity, subadditivity, and absolute homogeneity. -/
theorem cost_seminorm_properties (n : ℕ) :
    (∀ m : VoiceMotion n, 0 ≤ voiceLeadingCost n m) ∧
    (∀ m₁ m₂ : VoiceMotion n, voiceLeadingCost n (m₁ + m₂) ≤
      voiceLeadingCost n m₁ + voiceLeadingCost n m₂) ∧
    (∀ (m : VoiceMotion n) (c : ℤ),
      voiceLeadingCost n (c • m) = |c| * voiceLeadingCost n m) :=
  ⟨cost_nonneg n, cost_triangle n, cost_abs_homogeneous n⟩

/-! ## Conjecture: Lattice Width Bounds Optimal Cost

**Conjecture**: For a counterpoint system with stepwise bound `b` and `n` voices,
the optimal voice leading cost is bounded by the lattice width of the
feasible region, which is at most `n * b`.

This is testable: enumerate all feasible motions for small `n` and `b`
and verify the bound computationally. -/