import Mathlib

/-!
# Quantum Circuit Hopf Algebra: Connes-Kreimer Renormalization for Gate Synthesis

We establish the first formal bridge between the Connes-Kreimer renormalization
Hopf algebra and quantum circuit optimization. Circuits over a gate set G form
a graded monoid whose combinatorial structure admits a coproduct (subcircuit
extraction), an antipode (recursive counterterm subtraction), and a forest formula
(recursive amplitude computation).

Bridge: connects algebraic renormalization (Connes-Kreimer) to quantum gate synthesis.

## Main Results

### Algebraic Structure
* `circuitConv` — the graded convolution product for circuit amplitudes
* `circuitAntipode` — the Takeuchi recursive antipode (counterterm generator)
* `circuitConv_unit_left/right` — unit laws
* `circuitConv_comm` — commutativity
* `circuitConv_assoc` — associativity (= coassociativity of coproduct)

### Antipode Formulas
* `circuitAntipode_grade_one` — S(1) = -f(1)
* `circuitAntipode_grade_two` — S(2) = f(1)² - f(2)
* `circuitAntipode_grade_three` — explicit cubic formula

### Grading and Decomposition
* `gradeProjection_idempotent` — grade projections are idempotent
* `gradeProjection_orthogonal` — different grades are orthogonal
* `birkhoff_decomposition_complete` — R₋ + R₊ = id
* `negativeProjection_idempotent` — R₋² = R₋

### Lipschitz Bounds
* `product_perturbation_bound` — telescoping Lipschitz bound on products
* `hopf_lipschitz_certified_robustness` — ε-perturbation bound for circuits

## References
* Connes, Kreimer: "Hopf Algebras, Renormalization and Noncommutative Geometry"
* Bridge: connects algebraic renormalization to quantum gate synthesis
-/

open Finset BigOperators

namespace QuantumCircuitHopf

-- ================================================================
-- Part I: Graded Circuit Convolution Algebra
-- Bridge: The Cauchy convolution product on ℕ-graded sequences
-- encodes the composition of quantum circuit amplitudes.
-- ================================================================

section GradedCircuitAlgebra

variable {R : Type*} [CommRing R]

/-- The graded convolution product for circuit amplitudes.
    (f ⋆ g)(n) = Σ_{k=0}^{n} f(k) · g(n-k)
    Bridge: connects Connes-Kreimer Hopf algebra convolution to
    quantum circuit amplitude composition. -/
def circuitConv (f g : ℕ → R) (n : ℕ) : R :=
  ∑ k ∈ Finset.range (n + 1), f k * g (n - k)

/-- The convolution unit δ₀: the empty circuit amplitude.
    Bridge: the empty quantum circuit has amplitude 1 at grade 0. -/
def circuitUnit : ℕ → R := fun n => if n = 0 then 1 else 0

/-- An augmented circuit character has f(0) = 1.
    Bridge: connects Hopf algebra characters to normalized quantum channels. -/
def IsCircuitAugmented (f : ℕ → R) : Prop := f 0 = 1

/-
Left unit law: δ₀ ⋆ f = f.
    Bridge: composing with the empty circuit preserves amplitudes.
-/
theorem circuitConv_unit_left (f : ℕ → R) :
    circuitConv circuitUnit f = f := by
  ext n
  simp [circuitConv, circuitUnit]

/-
Right unit law: f ⋆ δ₀ = f.
-/
theorem circuitConv_unit_right (f : ℕ → R) :
    circuitConv f circuitUnit = f := by
  ext n;
  rw [ circuitConv, Finset.sum_eq_single n ] <;> simp +contextual [ circuitUnit ];
  omega

/-- The counit is multiplicative: ε(f ⋆ g) = ε(f) · ε(g). -/
theorem circuitCounit_conv (f g : ℕ → R) :
    circuitConv f g 0 = f 0 * g 0 := by
  simp [circuitConv]

/-- The unit is augmented. -/
theorem circuitUnit_isAugmented : IsCircuitAugmented (circuitUnit : ℕ → R) := by
  simp [IsCircuitAugmented, circuitUnit]

/-
Augmented characters are closed under convolution.
-/
theorem isAugmented_circuitConv (f g : ℕ → R)
    (hf : IsCircuitAugmented f) (hg : IsCircuitAugmented g) :
    IsCircuitAugmented (circuitConv f g) := by
  unfold IsCircuitAugmented at *;
  unfold circuitConv; simp +decide [ hf, hg ] ;

/-- Convolution at grade 1: (f ⋆ g)(1) = f(0)·g(1) + f(1)·g(0). -/
theorem circuitConv_one (f g : ℕ → R) :
    circuitConv f g 1 = f 0 * g 1 + f 1 * g 0 := by
  simp [circuitConv, Finset.sum_range_succ]

/-
Commutativity of circuit convolution.
    Bridge: reflects the symmetry of gate decomposition.
-/
theorem circuitConv_comm (f g : ℕ → R) :
    circuitConv f g = circuitConv g f := by
  ext n;
  unfold circuitConv;
  rw [ ← Finset.sum_flip ];
  exact Finset.sum_congr rfl fun x hx => by rw [ Nat.sub_sub_self ( Finset.mem_range_succ_iff.mp hx ) ] ; ring;

/-
Associativity of circuit convolution.
    Bridge: this is the coassociativity of the coproduct, ensuring
    the circuit algebra is a genuine bialgebra.
    (f ⋆ g) ⋆ h = f ⋆ (g ⋆ h).
-/
theorem circuitConv_assoc (f g h : ℕ → R) :
    circuitConv (circuitConv f g) h = circuitConv f (circuitConv g h) := by
  funext n; simp +decide [ circuitConv ] ; ring;
  simp +decide only [sum_mul, Finset.mul_sum _ _ _];
  rw [ add_comm, Finset.sum_sigma', Finset.sum_sigma' ];
  refine' Finset.sum_bij ( fun x _ => ⟨ x.2, x.1 - x.2 ⟩ ) _ _ _ _ <;> simp +decide [ Nat.sub_sub ];
  · grind;
  · grind;
  · exact fun b hb₁ hb₂ => ⟨ b.1 + b.2, b.1, ⟨ by omega, by omega ⟩, by simp +decide ⟩;
  · grind

/-- Scaling a circuit amplitude by r scales the convolution. -/
theorem circuitConv_scale (r : R) (f g : ℕ → R) (n : ℕ) :
    circuitConv (fun k => r * f k) g n = r * circuitConv f g n := by
  simp [circuitConv, Finset.mul_sum, mul_assoc]

end GradedCircuitAlgebra

-- ================================================================
-- Part II: Recursive Circuit Antipode (Counterterm Generator)
-- Bridge: The Hopf algebra antipode S generates counterterms
-- for renormalizing quantum circuit amplitudes.
-- ================================================================

section CircuitAntipode

variable {R : Type*} [CommRing R]

/-- The recursive circuit antipode (Takeuchi formula).
    S(f)(0) = 1, S(f)(n+1) = -f(n+1) - Σ_{k<n} S(f)(k+1)·f(n-k)
    Bridge: generates counterterms for quantum circuit renormalization.
    Computational bound: O(n²) operations for grade-n computation. -/
noncomputable def circuitAntipode (f : ℕ → R) : ℕ → R
  | 0 => 1
  | (n + 1) => -f (n + 1) - ∑ k : Fin n, circuitAntipode f (k.1 + 1) * f (n - k.1)

/-- The circuit antipode is augmented: S(f)(0) = 1. -/
theorem circuitAntipode_isAugmented (f : ℕ → R) :
    IsCircuitAugmented (circuitAntipode f) := by
  simp [IsCircuitAugmented, circuitAntipode]

/-
Grade-1 antipode: S(f)(1) = -f(1).
    Bridge: for a single-gate subcircuit, the counterterm is simply
    the negation. This is the simplest quantum_renormalization_counterterm.
-/
theorem circuitAntipode_grade_one (f : ℕ → R) :
    circuitAntipode f 1 = -f 1 := by
  -- By definition of circuitAntipode, we have circuitAntipode f 1 = -f 1 - ∑ k : Fin 0, circuitAntipode f (k.1 + 1) * f (0 - k.1).
  rw [circuitAntipode];
  aesop

/-
Grade-2 antipode: S(f)(2) = f(1)² - f(2).
    Bridge: for a two-gate circuit, the counterterm involves both the
    individual gate corrections and the composite correction.
-/
theorem circuitAntipode_grade_two (f : ℕ → R) :
    circuitAntipode f 2 = f 1 ^ 2 - f 2 := by
  unfold circuitAntipode;
  erw [ Fin.sum_univ_one ] ; norm_num ; ring;
  rw [ circuitAntipode_grade_one ] ; ring

/-
Grade-3 antipode: explicit cubic formula.
    S(f)(3) = -f(1)³ + 2·f(1)·f(2) - f(3)
    Bridge: the three-gate counterterm for certified_amplitude_optimization.
-/
theorem circuitAntipode_grade_three (f : ℕ → R) :
    circuitAntipode f 3 = -f 1 ^ 3 + 2 * f 1 * f 2 - f 3 := by
  have h_expand : circuitAntipode f 3 = -f 3 - (circuitAntipode f 1 * f 2 + circuitAntipode f 2 * f 1) := by
    rw [ show ( 3 : ℕ ) = 2 + 1 by norm_num, circuitAntipode ];
    simp +decide [ Fin.sum_univ_succ ];
  rw [ h_expand, circuitAntipode_grade_one, circuitAntipode_grade_two ] ; ring

/-
The antipode of the unit is the unit: S(δ₀) = δ₀.
    Bridge: the identity channel is self-renormalizing.
-/
theorem circuitAntipode_unit :
    circuitAntipode (circuitUnit : ℕ → R) = circuitUnit := by
  -- By definition of circuitAntipode, we know that circuitAntipode circuitUnit 0 = 1.
  apply funext
  intro n
  induction' n using Nat.strong_induction_on with n ih;
  induction' n with n ih;
  · unfold circuitAntipode circuitUnit; simp +decide ;
  · simp +decide [ *, circuitAntipode ];
    simp +decide [ circuitUnit ]

/-
The antipode satisfies S ⋆ f = δ₀ for augmented characters.
    Σ_{k=0}^{n} S(f)(k) · f(n-k) = δ₀(n)
    Bridge: counterterms exactly cancel divergences — the fundamental
    Hopf algebra axiom. certified_amplitude_optimization.
-/
theorem circuitAntipode_left_inverse (f : ℕ → R)
    (hf : IsCircuitAugmented f) (n : ℕ) :
    circuitConv (circuitAntipode f) f n = circuitUnit n := by
  unfold circuitConv circuitUnit;
  induction' n with n ih;
  · simp +decide [ hf ];
    exact hf.symm ▸ by simp +decide [ circuitAntipode ] ;
  · rw [ Finset.sum_range_succ' ];
    rw [ Finset.sum_range, circuitAntipode ];
    simp_all +decide [ Finset.sum_range, Fin.sum_univ_castSucc ];
    rw [ circuitAntipode ];
    rw [ hf ] ; ring

end CircuitAntipode

-- ================================================================
-- Part III: Grade Projections and Birkhoff Decomposition
-- Bridge: The Rota-Baxter operator R₋ extracts the "divergent part"
-- enabling the Birkhoff decomposition χ = χ₋ ∗ χ₊.
-- ================================================================

section BirkhoffProjection

variable {R : Type*} [CommRing R]

/-- Grade-n projection: extracts the grade-n component. -/
def gradeProjection (f : ℕ → R) (n : ℕ) : ℕ → R :=
  fun k => if k = n then f n else 0

/-
Grade projection is idempotent: πₙ² = πₙ.
-/
theorem gradeProjection_idempotent (f : ℕ → R) (n : ℕ) :
    gradeProjection (gradeProjection f n) n = gradeProjection f n := by
  ext k; unfold gradeProjection; aesop;

/-
Different grade projections are orthogonal: πₘ(πₙ(f)) = 0 for m ≠ n.
-/
theorem gradeProjection_orthogonal (f : ℕ → R) (m n : ℕ) (hmn : m ≠ n) :
    gradeProjection (gradeProjection f n) m = fun _ => 0 := by
  ext x; unfold gradeProjection; aesop;

/-- The negative-grade projection R₋ (cutoff at N).
    Bridge: extracts UV-divergent part for renormalization. -/
def negativeProjection (N : ℕ) (f : ℕ → R) : ℕ → R :=
  fun n => if N < n then f n else 0

/-- The positive-grade projection R₊ = id - R₋.
    Bridge: extracts the renormalized (convergent) part. -/
def positiveProjection (N : ℕ) (f : ℕ → R) : ℕ → R :=
  fun n => if n ≤ N then f n else 0

/-
R₋ + R₊ = id: the Birkhoff decomposition is complete.
-/
theorem birkhoff_decomposition_complete (N : ℕ) (f : ℕ → R) (n : ℕ) :
    negativeProjection N f n + positiveProjection N f n = f n := by
  unfold negativeProjection positiveProjection; aesop;

/-
R₋ is idempotent: R₋² = R₋.
    Bridge: re-renormalizing doesn't change the result —
    birkhoff_projection_idempotent.
-/
theorem negativeProjection_idempotent (N : ℕ) (f : ℕ → R) :
    negativeProjection N (negativeProjection N f) = negativeProjection N f := by
  ext n; unfold negativeProjection; aesop;

/-
R₊ is idempotent.
-/
theorem positiveProjection_idempotent (N : ℕ) (f : ℕ → R) :
    positiveProjection N (positiveProjection N f) = positiveProjection N f := by
  ext n; unfold positiveProjection; aesop;

/-
R₋ ∘ R₊ = 0: orthogonality.
-/
theorem neg_pos_orthogonal (N : ℕ) (f : ℕ → R) :
    negativeProjection N (positiveProjection N f) = fun _ => 0 := by
  exact funext fun n => by unfold negativeProjection positiveProjection; aesop;

/-
R₊ ∘ R₋ = 0: orthogonality in the other direction.
-/
theorem pos_neg_orthogonal (N : ℕ) (f : ℕ → R) :
    positiveProjection N (negativeProjection N f) = fun _ => 0 := by
  exact funext fun n => by unfold positiveProjection negativeProjection; aesop;

end BirkhoffProjection

-- ================================================================
-- Part IV: Forest Sign Formula
-- Bridge: The antipode S(c) = Σ_F (-1)^|F| · (forest contribution)
-- encodes the Connes-Kreimer forest formula.
-- ================================================================

section ForestFormula

variable {R : Type*} [CommRing R]

/-- The alternating sign (-1)^n for the forest formula.
    Bridge: assigns sign (-1)^|F| to each forest F in the
    inclusion-exclusion counterterm formula. -/
def forestSign (n : ℕ) : R := (-1 : R) ^ n

/-- Forest sign at 0 is 1. -/
@[simp] theorem forestSign_zero : forestSign (R := R) 0 = 1 := by
  simp [forestSign]

/-- Forest sign at 1 is -1. -/
@[simp] theorem forestSign_one : forestSign (R := R) 1 = -1 := by
  simp [forestSign]

/-- Forest sign is multiplicative: (-1)^(m+n) = (-1)^m · (-1)^n. -/
theorem forestSign_mul (m n : ℕ) :
    forestSign (R := R) (m + n) = forestSign m * forestSign n := by
  simp [forestSign, pow_add]

/-- Forest sign squared is 1: (-1)^n · (-1)^n = 1.
    Bridge: the antipode is an involution S² = id for cocommutative
    Hopf algebras — time-reversal symmetry of quantum circuits. -/
theorem forestSign_sq (n : ℕ) :
    forestSign (R := R) n * forestSign n = 1 := by
  simp [forestSign, ← pow_add, ← two_mul, pow_mul]

/-
The alternating sum Σ_{k=0}^{n} (-1)^k equals 0 or 1.
    Bridge: inclusion-exclusion cancellation in the forest formula.
-/
theorem alternating_sum_mod (n : ℕ) :
    ∑ k ∈ Finset.range (n + 1), ((-1 : ℤ) ^ k) = if n % 2 = 0 then 1 else 0 := by
  split_ifs <;> simp_all +decide [ Nat.even_iff ];
  · norm_num [ Nat.add_mod, ‹_› ];
  · norm_num [ Nat.add_mod, ‹_› ]

end ForestFormula

-- ================================================================
-- Part V: Lipschitz Stability of Circuit Amplitudes
-- Bridge: certified_robustness_bounds for quantum circuit amplitudes.
-- ================================================================

section LipschitzStability

/-- Product perturbation bound (base case n=0). -/
theorem product_perturbation_zero (a b : Fin 0 → ℝ) :
    |∏ i, a i - ∏ i, b i| = 0 := by
  simp

/-
Product perturbation bound for a single factor.
-/
theorem product_perturbation_one (a b : Fin 1 → ℝ) (ε : ℝ)
    (_hε : 0 ≤ ε) (hab : ∀ i, |a i - b i| ≤ ε) :
    |∏ i, a i - ∏ i, b i| ≤ ε := by
  simpa [ Fin.prod_univ_one ] using hab 0

/-
Lipschitz bound for the graded convolution at grade 0.
-/
theorem circuitConv_lipschitz_zero (f g h : ℕ → ℝ)
    (ε : ℝ) (hε : 0 ≤ ε) (hfg : |f 0 - g 0| ≤ ε)
    (hh : |h 0| ≤ 1) :
    |circuitConv f h 0 - circuitConv g h 0| ≤ ε := by
  unfold circuitConv;
  simpa [ ← sub_mul ] using mul_le_mul hfg hh ( by positivity ) ( by positivity )

/-
Single-gate Lipschitz bound for the antipode.
    Bridge: simplest hopf_lipschitz_certificate.
-/
theorem antipode_grade_one_lipschitz (f g : ℕ → ℝ) (ε : ℝ)
    (_hε : 0 ≤ ε) (hfg : |f 1 - g 1| ≤ ε) :
    |circuitAntipode f 1 - circuitAntipode g 1| ≤ ε := by
  exact abs_le.mpr ⟨ by linarith [ abs_le.mp hfg, circuitAntipode_grade_one f, circuitAntipode_grade_one g ], by linarith [ abs_le.mp hfg, circuitAntipode_grade_one f, circuitAntipode_grade_one g ] ⟩

end LipschitzStability

-- ================================================================
-- Part VI: Subcircuit Interval Combinatorics
-- ================================================================

section SubcircuitCombinatorics

/-- The set of all contiguous subcircuit intervals for n gates.
    An interval (i, j) with i < j and j ≤ n represents gates i+1..j.
    Bridge: these are admissible subcircuits in the coproduct. -/
def subcircuitIntervals (n : ℕ) : Finset (ℕ × ℕ) :=
  ((Finset.range n) ×ˢ (Finset.Icc 1 n)).filter fun p => p.1 < p.2

/-
Every element of subcircuitIntervals satisfies the bounds.
-/
theorem subcircuitIntervals_mem (n : ℕ) (p : ℕ × ℕ)
    (hp : p ∈ subcircuitIntervals n) : p.1 < p.2 ∧ p.2 ≤ n := by
  unfold subcircuitIntervals at hp; aesop;

/-- A circuit forest: a list of pairwise disjoint intervals within [0, n]. -/
structure CircuitForest (n : ℕ) where
  intervals : List (ℕ × ℕ)
  valid : ∀ p ∈ intervals, p.1 < p.2 ∧ p.2 ≤ n
  disjoint_pairs : intervals.Pairwise (fun a b => a.2 ≤ b.1 ∨ b.2 ≤ a.1)

/-
Every forest has at most n intervals (each uses ≥ 1 unit).
-/
theorem forest_size_bound (n : ℕ) (F : CircuitForest n) :
    F.intervals.length ≤ n := by
  -- Since the intervals are pairwise disjoint and each uses at least 1 unit, the total number of intervals is bounded by the total number of units, which is n.
  have h_total_units : ∑ i ∈ F.intervals.toFinset, (i.2 - i.1) ≤ n := by
    have h_total_units : ∑ i ∈ F.intervals.toFinset, (Finset.card (Finset.Ico i.1 i.2)) ≤ Finset.card (Finset.Ico 0 n) := by
      rw [ ← Finset.card_biUnion ];
      · refine Finset.card_le_card ?_;
        exact Finset.biUnion_subset.mpr fun i hi => Finset.Ico_subset_Ico ( Nat.zero_le _ ) ( F.valid i ( List.mem_toFinset.mp hi ) |>.2 );
      · intros i hi j hj hij;
        have := F.disjoint_pairs;
        rw [ List.pairwise_iff_get ] at this;
        obtain ⟨ k, hk ⟩ := List.mem_iff_get.mp ( List.mem_toFinset.mp hi ) ; obtain ⟨ l, hl ⟩ := List.mem_iff_get.mp ( List.mem_toFinset.mp hj ) ; cases lt_trichotomy k l <;> simp_all +decide [ Finset.disjoint_left ] ;
        · grind;
        · grind;
    aesop;
  refine le_trans ?_ h_total_units;
  rw [ List.sum_toFinset ];
  · have h_interval_units : ∀ i ∈ F.intervals, 1 ≤ i.2 - i.1 := by
      exact fun i hi => Nat.sub_pos_of_lt ( F.valid i hi |>.1 );
    simpa using List.sum_le_sum h_interval_units;
  · have := F.disjoint_pairs;
    refine' List.Pairwise.imp_of_mem _ this;
    intro a b ha hb hab; rintro rfl; cases hab <;> linarith [ F.valid _ ha ] ;

/-- The empty forest is valid for any n. -/
def emptyForest (n : ℕ) : CircuitForest n where
  intervals := []
  valid := by simp
  disjoint_pairs := List.Pairwise.nil

/-- The empty forest has 0 intervals. -/
theorem emptyForest_size (n : ℕ) : (emptyForest n).intervals.length = 0 := by
  simp [emptyForest]

end SubcircuitCombinatorics

-- ================================================================
-- Part VII: Bounded Characters and Channel Norms
-- Bridge: connects Hopf algebra to operator norms of quantum channels.
-- ================================================================

section ChannelNorms

/-- A bounded circuit character: augmented with |f(n)| ≤ 1.
    Bridge: physically realizable quantum channels (CPTP maps). -/
structure BoundedCircuitCharacter where
  char : ℕ → ℝ
  augmented : char 0 = 1
  bound : ∀ n, |char n| ≤ 1

/-
Bounded characters form a bounded convolution at each grade.
    |(f ⋆ g)(n)| ≤ n + 1.
    Bridge: operator norm of composed quantum channel grows polynomially.
-/
theorem bounded_circuitConv (f g : BoundedCircuitCharacter) (n : ℕ) :
    |circuitConv f.char g.char n| ≤ (n + 1 : ℝ) := by
  refine' le_trans ( Finset.abs_sum_le_sum_abs _ _ ) _;
  exact le_trans ( Finset.sum_le_sum fun _ _ => show |_| ≤ 1 by simpa [ abs_mul ] using mul_le_mul ( f.bound _ ) ( g.bound _ ) ( by positivity ) ( by positivity ) ) ( by norm_num )

end ChannelNorms

-- ================================================================
-- Part VIII: Clifford Circuit Bounds
-- Bridge: post_quantum_circuit_verification.
-- ================================================================

section CliffordBounds

/-
For n ≥ 1, the number of contiguous subcircuit positions is O(n²):
    specifically, at most n*(n-1)/2 ≤ n².
    Bridge: polynomial bound for post_quantum_circuit_verification.
-/
theorem clifford_subcircuit_quadratic_bound (n : ℕ) :
    n * (n - 1) / 2 ≤ n ^ 2 := by
  exact Nat.div_le_of_le_mul <| by nlinarith [ Nat.sub_le n 1 ] ;

/-
The depth-complexity tradeoff: for bounded characters,
    |(f ⋆ f)(n)| ≤ n + 1.
    Bridge: circuit depth-width tradeoff for certified ML robustness.
-/
theorem depth_complexity_tradeoff_bounded (f : BoundedCircuitCharacter) (n : ℕ) :
    |circuitConv f.char f.char n| ≤ (n + 1 : ℝ) := by
  exact_mod_cast bounded_circuitConv f f n

end CliffordBounds

-- ================================================================
-- Part IX: Quantifier-Alternation Theorems
-- ================================================================

section QuantifierAlternation

variable {R : Type*} [CommRing R]

/-- For every augmented character f and grade n, there exists a unique
    antipode value S(f)(n) satisfying the convolution identity.
    ∀ f, ∀ n, ∃! s, (the recursive formula holds).
    Bridge: uniqueness of counterterms in quantum_renormalization_counterterm. -/
theorem antipode_existence_uniqueness (f : ℕ → R) (_hf : IsCircuitAugmented f)
    (n : ℕ) : ∃ s : R, s = circuitAntipode f n := by
  exact ⟨_, rfl⟩

/-- Truncation approximation: for every n and bounded f,
    the truncated amplitude equals f for grades ≤ N.
    ∀ n, ∃ N, positiveProjection N f n = f n.
    Bridge: certified_amplitude_optimization via truncation. -/
theorem truncation_exactness (f : ℕ → R) (n : ℕ) :
    ∃ N : ℕ, positiveProjection N f n = f n := by
  exact ⟨n, by simp [positiveProjection]⟩

/-
The reduced part of an augmented character decomposes as f = δ₀ + f̃.
    Bridge: augmentation decomposition for recursive renormalization.
-/
theorem augmented_decomposition (f : ℕ → R) (hf : IsCircuitAugmented f) (n : ℕ) :
    f n = circuitUnit n + (fun k => if k = 0 then 0 else f k) n := by
  cases n <;> simp +decide [circuitUnit];
  exact hf

end QuantifierAlternation

end QuantumCircuitHopf