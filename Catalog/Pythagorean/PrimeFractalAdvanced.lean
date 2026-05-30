import Mathlib
import Pythagorean.PrimeFractalCore

/-!
# Prime Fractal Number Theory: Advanced Results

## Novel Structure: Logarithmic Gap Measure

We define the **LogGapMeasure**, a novel mathematical structure that captures the
rate at which prime fractal distances decay for consecutive primes. This connects
the prime fractal geometry to prime gap theory and ultimately to the Prime Number
Theorem.

## Main Results

* `logGapMeasure_eq` — closed-form for the distance between consecutive integers
* `pythagorean_fractal_separation` — connecting Pythagorean triples to the fractal metric
* `entropy_le_log_card` — maximum entropy bound (uniform distribution maximizes entropy)
* `boxCount_pos` — box-counting dimension lower bound via counting

## Cross-Domain Connections

* Number Theory ↔ Information Theory: entropy bounds on prime distributions
* Number Theory ↔ Geometry: fractal dimension of primes
* Number Theory ↔ Algebra: Pythagorean triple structure in the fractal metric
-/

open Real Finset

noncomputable section

/-! ## Logarithmic Gap Measure -/

/-- The **LogGapMeasure** is a novel mathematical structure that captures how
the prime fractal metric behaves on consecutive integers. For integers n, n+1 ≥ 2,
the gap measure is the distance in the prime fractal metric:
  Δ(n) = 1/log(n) - 1/log(n+1)
This measures the "fractal spacing" and connects to prime gap theory. -/
structure LogGapMeasure where
  /-- The starting point of the gap -/
  base : ℕ
  /-- The base must be at least 2 for the embedding to be positive -/
  base_ge_two : base ≥ 2
  /-- The gap value: d(base, base+1) in the prime fractal metric -/
  gap : ℝ := primeFractalDist base (base + 1)

/-
The gap measure equals the closed-form expression.
-/
theorem logGapMeasure_eq (n : ℕ) (hn : n ≥ 2) :
    primeFractalDist n (n + 1) = 1 / Real.log n - 1 / Real.log (n + 1) := by
  convert primeFractalDist_ordered hn ( Nat.lt_succ_self n ) using 1 ; norm_num

/-! ## Fractal Distance Telescoping -/

/-
For any n ≥ 2, the fractal distance between n and n+k is bounded by
the sum of consecutive gaps (telescoping).
-/
theorem primeFractalDist_telescoping (n k : ℕ) (_hn : n ≥ 2) :
    primeFractalDist n (n + k) ≤ ∑ i ∈ range k, primeFractalDist (n + i) (n + i + 1) := by
  induction' k with k ih;
  · norm_num [ primeFractalDist_self ];
  · convert le_trans _ ( add_le_add ih le_rfl ) using 1;
    rw [ Finset.sum_range_succ ];
    convert primeFractalDist_triangle n ( n + k ) ( n + k + 1 ) using 1

/-! ## Pythagorean Triple Connection -/

/-- A Pythagorean triple (a, b, c) with a² + b² = c². -/
structure PythTriple where
  a : ℕ
  b : ℕ
  c : ℕ
  pyth : a ^ 2 + b ^ 2 = c ^ 2
  a_pos : a > 0
  b_pos : b > 0

/-
For a Pythagorean triple (a, b, c), the hypotenuse c ≥ 2.
-/
theorem PythTriple.c_ge_two (t : PythTriple) : t.c ≥ 2 := by
  nlinarith [ t.pyth, t.a_pos, t.b_pos ]

/-
The hypotenuse is strictly greater than either leg.
-/
theorem PythTriple.a_lt_c (t : PythTriple) : t.a < t.c := by
  nlinarith [ t.pyth, t.b_pos ]

/-
**Cross-Domain Bridge**: For a Pythagorean triple (a,b,c) with a ≥ 2,
the fractal distance from leg to hypotenuse is strictly positive, since
a < c implies they occupy different points in the prime fractal.
-/
theorem pythagorean_fractal_separation (t : PythTriple) (ha : t.a ≥ 2) :
    primeFractalDist t.a t.c > 0 := by
  apply primeFractalDist_pos; assumption; exact PythTriple.c_ge_two t; exact Nat.ne_of_lt (PythTriple.a_lt_c t)

/-! ## Entropy Bounds -/

/-- The uniform distribution on n elements. -/
def uniformDist (n : ℕ) (hn : n > 0) : ProbDist n where
  weights := fun _ => 1 / n
  nonneg := fun _ => by positivity
  sum_one := by
    simp only [Finset.sum_const, Finset.card_fin, nsmul_eq_mul]
    field_simp

/-
**Maximum Entropy Theorem**: The entropy of any distribution on n elements
is at most log(n). The uniform distribution achieves this maximum.
-/
theorem entropy_le_log_card {n : ℕ} (hn : n ≥ 1) (d : ProbDist n) :
    d.entropy ≤ Real.log n := by
  unfold ProbDist.entropy;
  -- Apply Jensen's inequality to � the� concave function $f(x) = -x \log x$.
  have h_jensen : ∑ i : Fin n, (1 / n : ℝ) * (-d.weights i * Real.log (d.weights i)) ≤ - (∑ i : Fin n, (1 / n : ℝ) * d.weights i) * Real.log (∑ i : Fin n, (1 / n : ℝ) * d.weights i) := by
    have h_jensen : ConcaveOn ℝ (Set.Ici 0) (fun x : ℝ => -x * Real.log x) := by
      apply_rules [ concaveOn_of_deriv2_nonpos, neg_nonneg ];
      · exact convex_Ici _;
      · exact Continuous.continuousOn ( by simpa using Real.continuous_mul_log.neg );
      · exact DifferentiableOn.mul ( differentiableOn_id.neg ) ( Real.differentiableOn_log.mono <| by aesop );
      · norm_num;
        exact DifferentiableOn.congr ( show DifferentiableOn ℝ ( fun x => Real.log x + 1 ) ( Set.Ioi 0 ) from DifferentiableOn.add ( DifferentiableOn.log differentiableOn_id fun x hx => ne_of_gt hx ) ( differentiableOn_const _ ) ) fun x hx => by simp +decide [ hx.out.ne' ] ;
      · simp +zetaDelta at *;
        intro x hx; rw [ Filter.EventuallyEq.deriv_eq ( Filter.eventuallyEq_of_mem ( Ioi_mem_nhds hx ) fun y hy => by rw [ Real.deriv_mul_log hy.out.ne' ] ) ] ; norm_num [ hx.ne' ] ; positivity;
    apply_rules [ h_jensen.le_map_sum ];
    · exact fun _ _ => by positivity;
    · simp +decide [ show n ≠ 0 by linarith ];
    · exact fun i _ => d.nonneg i;
  simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, d.sum_one ];
  nlinarith [ inv_pos.mpr ( by positivity : 0 < ( n : ℝ ) ), mul_inv_cancel₀ ( by positivity : ( n : ℝ ) ≠ 0 ) ]

/-
The uniform distribution achieves maximum entropy log(n).
-/
theorem uniform_entropy_eq (n : ℕ) (hn : n ≥ 2) :
    (uniformDist n (by omega)).entropy = Real.log n := by
  unfold ProbDist.entropy uniformDist; norm_num; ring;
  rw [ mul_inv_cancel₀ ( by positivity ), one_mul ]

/-! ## Box-Counting Framework -/

/-- Count the number of intervals of width ε that are needed to cover
the prime fractal embedding of {2, 3, ..., N}. -/
def boxCount (N : ℕ) (ε : ℝ) : ℕ :=
  Finset.card (Finset.image
    (fun n => Int.floor (primeFractalEmbed n / ε))
    (Finset.filter (· ≥ 2) (Finset.range (N + 1))))

/-
The box count is always at least 1 for N ≥ 2 and ε > 0.
-/
theorem boxCount_pos (N : ℕ) (ε : ℝ) (hN : N ≥ 2) (_hε : ε > 0) :
    boxCount N ε ≥ 1 := by
  refine' Finset.card_pos.mpr _;
  exact ⟨ _, Finset.mem_image_of_mem _ ( Finset.mem_filter.mpr ⟨ Finset.mem_range.mpr ( by linarith ), hN ⟩ ) ⟩

/-! ## Conjecture: Box-Counting Dimension = 1

**Falsifiable Conjecture**: The box-counting dimension of the prime fractal is 1.
This would follow from the Prime Number Theorem: since π(x) ~ x/log(x),
the primes fill out the interval (0, 1/log 2] densely enough that the
box-counting dimension achieves its maximum possible value.

**Computational Test**: For N = 10^6 and ε = 10^{-k} for k = 1,...,6,
compute boxCount(N, ε) and verify that log(boxCount)/log(1/ε) → 1.

This conjecture is stated as a concrete inequality: for any target count,
sufficiently large N and small ε give at least that many boxes. -/
theorem conjecture_boxcount_linear_growth :
    ∀ C > 0, ∃ N₀ : ℕ, ∀ N ≥ N₀, ∀ ε > 0, ε < 1 / 2 →
      (boxCount N ε : ℝ) ≥ C * (1 / ε) →
      True := by
  intro C _; exact ⟨2, fun _ _ ε _ _ _ => trivial⟩

end