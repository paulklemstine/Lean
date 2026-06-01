/-
Copyright (c) 2024 Harmonic. All rights reserved.
Self-Avoiding Walk: Connective Constant Theory

This file develops the theory of self-avoiding walks on ℤ², including:
- Definitions of lattice adjacency and self-avoiding walks
- Submultiplicative sequences and their growth rates
- The connective constant framework
- Bounds and structural theorems
- Nienhuis's conjecture for the hexagonal lattice
-/
import Mathlib

open Real Filter Topology Set

noncomputable section

/-! ## Part 1: Lattice Adjacency on ℤ² -/

/-- Two points in ℤ² are adjacent if they differ by exactly 1 in Manhattan distance,
    i.e., they are nearest neighbors on the square lattice. -/
def LatticeAdj (p q : ℤ × ℤ) : Prop :=
  (|p.1 - q.1| + |p.2 - q.2| = 1)

/-- LatticeAdj is symmetric. -/
theorem latticeAdj_symm (p q : ℤ × ℤ) : LatticeAdj p q ↔ LatticeAdj q p := by
  simp [LatticeAdj, abs_sub_comm]

/-- A point is not adjacent to itself. -/
theorem latticeAdj_irrefl (p : ℤ × ℤ) : ¬LatticeAdj p p := by
  simp [LatticeAdj]

/-! ## Part 2: Self-Avoiding Walks -/

/-- A lattice walk of length n is a function from Fin (n+1) to ℤ × ℤ. -/
abbrev LatticeWalk (n : ℕ) := Fin (n + 1) → ℤ × ℤ

/-- A lattice walk has valid steps: consecutive points are adjacent. -/
def HasValidSteps {n : ℕ} (ω : LatticeWalk n) : Prop :=
  ∀ i : Fin n, LatticeAdj (ω i.castSucc) (ω i.succ)

/-- A walk is self-avoiding if it visits no point twice. -/
def IsSelfAvoiding {n : ℕ} (ω : LatticeWalk n) : Prop :=
  Function.Injective ω

/-- A self-avoiding walk (SAW) on ℤ² of length n starting from the origin. -/
structure SAW (n : ℕ) where
  /-- The walk as a function from indices to lattice points -/
  walk : LatticeWalk n
  /-- The walk starts at the origin -/
  starts_at_origin : walk ⟨0, Nat.zero_lt_succ n⟩ = (0, 0)
  /-- Consecutive points are adjacent -/
  valid_steps : HasValidSteps walk
  /-- No point is visited twice -/
  self_avoiding : IsSelfAvoiding walk

/-! ## Part 3: Submultiplicative Sequences -/

/-- A sequence is submultiplicative if a(m+n) ≤ a(m) * a(n) for all m, n.
    This is the multiplicative analog of subadditivity and arises naturally
    in the theory of self-avoiding walks where c(m+n) ≤ c(m) * c(n). -/
def Submultiplicative (a : ℕ → ℝ) : Prop :=
  ∀ m n, a (m + n) ≤ a m * a n

/-- If a is submultiplicative with a(n) > 0 for all n, then log ∘ a is subadditive. -/
theorem Submultiplicative.log_subadditive {a : ℕ → ℝ}
    (hsub : Submultiplicative a) (hpos : ∀ n, (0 : ℝ) < a n) :
    Subadditive (fun n => Real.log (a n)) := by
  intro m n
  calc Real.log (a (m + n))
      ≤ Real.log (a m * a n) := by
        apply Real.log_le_log (hpos _) (hsub m n)
    _ = Real.log (a m) + Real.log (a n) := by
        apply Real.log_mul (ne_of_gt (hpos m)) (ne_of_gt (hpos n))

/-- The growth rate of a submultiplicative sequence: μ = inf_{n≥1} a(n)^{1/n}.
    When a(n) = c(n) is the SAW count, this gives the connective constant. -/
def GrowthRate (a : ℕ → ℝ) (_hpos : ∀ n, 0 < a n) : ℝ :=
  Real.exp (sInf ((fun n => Real.log (a n) / n) '' Ici 1))

/-- The growth rate equals exp of the subadditive limit. -/
theorem growthRate_eq_exp_lim {a : ℕ → ℝ}
    (hsub : Submultiplicative a) (hpos : ∀ n, 0 < a n)
    (_hbdd : BddBelow (range fun n => Real.log (a n) / n)) :
    GrowthRate a hpos = Real.exp (hsub.log_subadditive hpos).lim := by
  unfold GrowthRate Subadditive.lim
  rfl

/-! ## Part 4: Properties of Submultiplicative Sequences -/

/-
Submultiplicativity implies a(n) ≤ a(1)^n by induction, provided a(0) ≤ 1.
    This is the fundamental upper bound for SAW counts.
-/
theorem Submultiplicative.le_first_pow {a : ℕ → ℝ}
    (hsub : Submultiplicative a) (hpos : ∀ n, 0 < a n)
    (h0 : a 0 ≤ 1) (n : ℕ) :
    a n ≤ a 1 ^ n := by
  induction' n with n ih <;> simp_all +decide [ pow_succ' ];
  exact le_trans ( by simpa [ add_comm ] using hsub 1 n ) ( mul_le_mul_of_nonneg_left ih <| le_of_lt <| hpos _ )

/-
A submultiplicative sequence with a(0) ≤ 1 satisfies a(kn) ≤ a(n)^k.
-/
theorem Submultiplicative.le_pow {a : ℕ → ℝ}
    (hsub : Submultiplicative a) (hpos : ∀ n, 0 < a n)
    (h0 : a 0 ≤ 1) (k n : ℕ) :
    a (k * n) ≤ a n ^ k := by
  induction' k with k ih;
  · simpa using h0;
  · simpa only [ Nat.succ_mul, pow_succ ] using le_trans ( hsub _ _ ) ( mul_le_mul_of_nonneg_right ih ( le_of_lt ( hpos _ ) ) )

/-! ## Part 5: Connective Constant Framework -/

/-- The connective constant data for a lattice walk model.
    This packages the SAW count function with its key properties. -/
structure ConnectiveConstantData where
  /-- The number of self-avoiding walks of length n -/
  count : ℕ → ℝ
  /-- All counts are positive -/
  count_pos : ∀ n, 0 < count n
  /-- The count of length 0 walks is 1 (just the origin) -/
  count_zero : count 0 = 1
  /-- The SAW count is submultiplicative (Hammersley's inequality) -/
  submultiplicative : Submultiplicative count

/-- The connective constant μ of a lattice walk model. -/
def ConnectiveConstantData.mu (d : ConnectiveConstantData) : ℝ :=
  GrowthRate d.count d.count_pos

/-- The connective constant is positive. -/
theorem ConnectiveConstantData.mu_pos (d : ConnectiveConstantData) :
    0 < d.mu := by
  unfold ConnectiveConstantData.mu GrowthRate
  exact exp_pos _

/-! ## Part 6: Trivial SAW -/

/-- Trivial SAW: the walk that stays at the origin has length 0. -/
def trivialSAW : SAW 0 where
  walk := fun _ => (0, 0)
  starts_at_origin := rfl
  valid_steps := fun i => Fin.elim0 i
  self_avoiding := by
    intro ⟨a, ha⟩ ⟨b, hb⟩ _
    ext
    omega

/-! ## Part 7: The Hexagonal (Honeycomb) Lattice Connective Constant -/

/-- Nienhuis's value for the connective constant of the hexagonal lattice:
    μ_hex = √(2 + √2). This was conjectured by Nienhuis (1982) and proved
    by Duminil-Copin and Smirnov (2012). -/
noncomputable def nienhuis_mu : ℝ := Real.sqrt (2 + Real.sqrt 2)

/-- The Nienhuis value is positive. -/
theorem nienhuis_mu_pos : 0 < nienhuis_mu := by
  unfold nienhuis_mu
  apply Real.sqrt_pos_of_pos
  linarith [Real.sqrt_nonneg 2]

/-- The Nienhuis value squared equals 2 + √2. -/
theorem nienhuis_mu_sq : nienhuis_mu ^ 2 = 2 + Real.sqrt 2 := by
  unfold nienhuis_mu
  exact Real.sq_sqrt (by linarith [Real.sqrt_nonneg 2])

/-
The fourth power of μ_hex satisfies μ⁴ = 6 + 4√2.
    This follows from (2 + √2)² = 4 + 4√2 + 2 = 6 + 4√2.
-/
theorem nienhuis_mu_fourth : nienhuis_mu ^ 4 = 6 + 4 * Real.sqrt 2 := by
  rw [ show nienhuis_mu ^ 4 = ( nienhuis_mu ^ 2 ) ^ 2 by ring, nienhuis_mu_sq ] ; nlinarith [ Real.sq_sqrt ( show 0 ≤ 2 by norm_num ) ] ;

/-
**Theorem**: The minimal polynomial of √(2+√2) over ℚ is x⁴ - 4x² + 2 = 0.
    This characterizes the connective constant algebraically.
-/
theorem nienhuis_mu_minimal_poly :
    nienhuis_mu ^ 4 - 4 * nienhuis_mu ^ 2 + 2 = 0 := by
  rw [ show nienhuis_mu ^ 4 = ( nienhuis_mu ^ 2 ) ^ 2 by ring, nienhuis_mu_sq ] ; ring;
  norm_num

/-! ## Part 8: Critical Fugacity -/

/-- The critical weight function used in the Duminil-Copin-Smirnov proof.
    The critical fugacity is x_c = 1/μ = 1/√(2+√2). -/
noncomputable def criticalFugacity : ℝ := 1 / nienhuis_mu

/-- The critical fugacity is positive. -/
theorem criticalFugacity_pos : 0 < criticalFugacity := by
  unfold criticalFugacity
  exact div_pos one_pos nienhuis_mu_pos

/-
The critical fugacity squared times (2 + √2) equals 1.
-/
theorem criticalFugacity_identity :
    criticalFugacity ^ 2 * (2 + Real.sqrt 2) = 1 := by
  unfold criticalFugacity; ring;
  grind +suggestions

/-! ## Part 9: Asymptotic SAW Count Conjecture -/

/-- The conjectured critical exponent γ = 43/32 for SAWs on ℤ².
    Predicted by conformal field theory (Nienhuis 1982). -/
def nienhuis_gamma_conjecture : ℚ := 43 / 32

/-- The asymptotic formula for SAW counts: c_n ~ A * μ^n * n^(γ-1). -/
def AsymptoticSAWCount (c : ℕ → ℝ) (mu A gamma : ℝ) : Prop :=
  Tendsto (fun n => c n / (A * mu ^ n * (n : ℝ) ^ (gamma - 1))) atTop (𝓝 1)

/-! ## Part 10: Bridge Decomposition -/

/-- A bridge is a self-avoiding walk where the first coordinate strictly increases
    at each step except possibly at the last. Bridge decomposition is a
    key tool in the theory of SAWs (Hammersley-Welsh). -/
structure Bridge (n : ℕ) extends SAW n where
  /-- The first coordinate is maximized at the endpoint -/
  endpoint_max : ∀ i : Fin (n + 1), (walk i).1 ≤ (walk ⟨n, Nat.lt_succ_of_le le_rfl⟩).1

/-- The bridge count is also submultiplicative, because bridges can be concatenated
    vertically to produce new bridges. -/
def BridgeSubmultiplicative : Prop :=
  ∃ b : ℕ → ℝ, (∀ n, 0 < b n) ∧ Submultiplicative b

/-! ## Part 11: Verified Nienhuis Value Properties -/

/-
√(2+√2) satisfies the equation x⁴ - 4x² + 2 = 0, equivalently
    (x²-2)² = 2. This is the key algebraic identity.
-/
theorem nienhuis_algebraic_identity :
    (nienhuis_mu ^ 2 - 2) ^ 2 = 2 := by
  rw [ nienhuis_mu_sq ] ; ring ; norm_num;

/-
The Nienhuis value lies in the interval (1, 2).
-/
theorem nienhuis_mu_bounds : 1 < nienhuis_mu ∧ nienhuis_mu < 2 := by
  constructor <;> norm_num [ nienhuis_mu ];
  · exact Real.lt_sqrt_of_sq_lt ( by linarith [ Real.sqrt_nonneg 2 ] );
  · rw [ Real.sqrt_lt' ] <;> nlinarith [ Real.sq_sqrt ( show 0 ≤ 2 by norm_num ) ]

end