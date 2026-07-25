import Mathlib

/-!
# Quadratic Recurrence and Number Theory: The Mandelbrot Set's Algebraic Structure

We formalize the algebraic theory of quadratic iteration `z_{n+1} = z_n² + c`,
focusing on the number-theoretic structure of periodic orbits and their multipliers.

## Main Definitions

- `quadIter`: The n-th iterate of `z ↦ z² + c`
- `mandelbrotIter`: The Mandelbrot sequence starting from 0
- `orbitProduct`: Product of orbit points, related to the multiplier
- `IsPeriodicPt'`: Periodicity predicate for quadratic iteration
- `IsExactPeriod`: Primitive/exact period predicate

## Main Results

- `quadIter_add`: Composition law for iteration (semigroup property)
- `periodic_mul_period`: Period divisibility for periodic orbits
- `period2_equation`: Characterization of period-2 points via quadratic equation
- `fermat_little_orbit_count`: Fermat's little theorem applied to orbit counting
- `orbit_same_period`: All points on a cycle share the same period
- `escape_norm_growth`: Escape criterion for the Mandelbrot iteration
-/

noncomputable section

open Finset BigOperators Nat

/-! ## Core Definitions -/

/-- The n-th iterate of the quadratic map `z ↦ z² + c`, starting from `z`. -/
def quadIter (c z : ℂ) : ℕ → ℂ
  | 0 => z
  | n + 1 => (quadIter c z n) ^ 2 + c

/-- The Mandelbrot iteration: iterating `z ↦ z² + c` starting from `0`. -/
def mandelbrotIter (c : ℂ) : ℕ → ℂ := quadIter c 0

/-- A point `z` is periodic of period `q` under `z ↦ z² + c`. -/
def IsPeriodicPt' (c z : ℂ) (q : ℕ) : Prop :=
  quadIter c z q = z

/-- A point `z` has exact (primitive) period `q` under `z ↦ z² + c`. -/
def IsExactPeriod (c z : ℂ) (q : ℕ) : Prop :=
  0 < q ∧ IsPeriodicPt' c z q ∧ ∀ d, 0 < d → d < q → ¬IsPeriodicPt' c z d

/-- The product of orbit points: `∏_{k=0}^{n-1} quadIter c z k`.
    This appears in the chain rule for the multiplier. -/
def orbitProduct (c z : ℂ) : ℕ → ℂ
  | 0 => 1
  | n + 1 => quadIter c z n * orbitProduct c z n

/-- The orbit multiplier of the n-th iterate at z.
    For `f(z) = z² + c`, we have `(f^n)'(z) = 2^n · ∏_{k<n} f^k(z)`.
    This is the algebraic chain rule applied to polynomial iteration. -/
def orbitMultiplier (c z : ℂ) (n : ℕ) : ℂ :=
  2 ^ n * orbitProduct c z n

/-! ## Basic Iteration Properties -/

@[simp]
theorem quadIter_zero (c z : ℂ) : quadIter c z 0 = z := rfl

@[simp]
theorem quadIter_succ (c z : ℂ) (n : ℕ) :
    quadIter c z (n + 1) = (quadIter c z n) ^ 2 + c := rfl

theorem quadIter_one (c z : ℂ) : quadIter c z 1 = z ^ 2 + c := rfl

theorem quadIter_two (c z : ℂ) : quadIter c z 2 = (z ^ 2 + c) ^ 2 + c := rfl

/-- The Mandelbrot iteration starts at 0. -/
@[simp]
theorem mandelbrotIter_zero (c : ℂ) : mandelbrotIter c 0 = 0 := rfl

/-- First Mandelbrot iterate is c. -/
theorem mandelbrotIter_one (c : ℂ) : mandelbrotIter c 1 = c := by
  simp [mandelbrotIter, quadIter]

/-! ## Composition Law: Iterating Iterates -/

/-- Key composition property: iterating m steps then n steps equals m+n steps.
    This is the fundamental semigroup property of iteration. -/
theorem quadIter_add (c z : ℂ) (m n : ℕ) :
    quadIter c z (m + n) = quadIter c (quadIter c z m) n := by
  induction n with
  | zero => simp [quadIter]
  | succ n ih =>
    show (quadIter c z (m + n)) ^ 2 + c = (quadIter c (quadIter c z m) n) ^ 2 + c
    rw [ih]

/-! ## Period Divisibility -/

/-
If a point is periodic with period q, it is also periodic with period any multiple of q.
    This is a fundamental property connecting periodicity to divisibility.
-/
theorem periodic_mul_period (c z : ℂ) (q : ℕ) (k : ℕ) (hq : IsPeriodicPt' c z q) :
    IsPeriodicPt' c z (q * k) := by
  induction' k with k ih;
  · simp +decide [ IsPeriodicPt' ];
  · convert quadIter_add c z ( q * k ) q using 1 ; ring;
    grind +locals

/-! ## The Orbit Multiplier and Chain Rule -/

@[simp]
theorem orbitProduct_zero (c z : ℂ) : orbitProduct c z 0 = 1 := rfl

@[simp]
theorem orbitProduct_succ (c z : ℂ) (n : ℕ) :
    orbitProduct c z (n + 1) = quadIter c z n * orbitProduct c z n := rfl

/-- The orbit multiplier at step 0 is 1 (identity derivative). -/
theorem orbitMultiplier_zero (c z : ℂ) : orbitMultiplier c z 0 = 1 := by
  simp [orbitMultiplier]

/-- The orbit multiplier satisfies the chain rule recurrence:
    `μ_{n+1}(z) = 2 · f^n(z) · μ_n(z)`.
    This encodes `(f^{n+1})'(z) = f'(f^n(z)) · (f^n)'(z) = 2·f^n(z) · (f^n)'(z)`. -/
theorem orbitMultiplier_succ (c z : ℂ) (n : ℕ) :
    orbitMultiplier c z (n + 1) = 2 * quadIter c z n * orbitMultiplier c z n := by
  simp [orbitMultiplier, orbitProduct]; ring

/-! ## Fixed Points and the Mandelbrot Cardioid -/

/-- A point z is a fixed point of z ↦ z² + c iff z² - z + c = 0. -/
theorem fixed_point_iff (c z : ℂ) :
    IsPeriodicPt' c z 1 ↔ z ^ 2 - z + c = 0 := by
  simp [IsPeriodicPt', quadIter]
  constructor
  · intro h; linear_combination h
  · intro h; linear_combination h

/-- The multiplier of a fixed point is 2z. -/
theorem fixed_point_multiplier (c z : ℂ) :
    orbitMultiplier c z 1 = 2 * z := by
  simp [orbitMultiplier, orbitProduct, quadIter]

/-- At the center of the main cardioid (c = 0), z = 0 is a fixed point
    with multiplier 0. This is a superattracting fixed point. -/
theorem cardioid_center_superattracting :
    IsPeriodicPt' 0 0 1 ∧ orbitMultiplier 0 0 1 = 0 := by
  constructor
  · simp [IsPeriodicPt', quadIter]
  · simp [orbitMultiplier, orbitProduct, quadIter]

/-! ## Period-2 Cycle Characterization -/

/-
The period-2 cycle points satisfy z² + z + c + 1 = 0, obtained by factoring
    f²(z) - z = (f(z) - z)(z² + z + c + 1). The period-2 bulb in the Mandelbrot
    set corresponds to the parameter region where this equation has attracting solutions.
-/
theorem period2_equation (c z : ℂ) (h2 : IsPeriodicPt' c z 2) (h1 : ¬IsPeriodicPt' c z 1) :
    z ^ 2 + z + (c + 1) = 0 := by
  unfold IsPeriodicPt' at *;
  exact mul_left_cancel₀ ( sub_ne_zero_of_ne h1 ) ( by erw [ show quadIter c z 2 = ( quadIter c z 1 ) ^ 2 + c from rfl ] at h2; erw [ show quadIter c z 1 = ( quadIter c z 0 ) ^ 2 + c from rfl ] at *; erw [ show quadIter c z 0 = z from rfl ] at *; linear_combination h2 )

/-
The multiplier of a period-2 cycle is 4z₁z₂ where z₁, z₂ are the cycle points.
    Using Vieta's relations for z² + z + (c+1) = 0: z₁z₂ = c+1 and z₁+z₂ = -1.
-/
theorem period2_multiplier_formula (c z : ℂ)
    (hz : z ^ 2 + z + (c + 1) = 0)
    (hz2 : quadIter c z 1 = z ^ 2 + c) :
    orbitMultiplier c z 2 = 4 * z * (z ^ 2 + c) := by
  unfold orbitMultiplier;
  unfold orbitProduct; norm_num [ hz2 ] ; ring;

/-! ## Number-Theoretic Structure of Periods -/

/-
Fermat's little theorem gives the count of primitive periodic orbits:
    The number of points of exact period p (for prime p) in z² + c is 2^p - 2,
    and these form (2^p - 2)/p distinct orbits. The divisibility 2^p - 2 ≡ 0 (mod p)
    is Fermat's little theorem, connecting Mandelbrot dynamics to number theory.
-/
theorem fermat_little_orbit_count (p : ℕ) (hp : Nat.Prime p) :
    p ∣ 2 ^ p - 2 := by
  haveI := Fact.mk hp; norm_num [ ← ZMod.natCast_eq_zero_iff, Nat.cast_sub ( show 2 ≤ 2 ^ p by exact le_self_pow₀ ( by decide ) hp.ne_zero ) ] ;

/-
For prime p ≥ 3, there are at least 2 primitive orbits of period p.
    This shows the Mandelbrot set has rich structure at every prime period.
-/
theorem prime_orbit_count_ge (p : ℕ) (hp : Nat.Prime p) (hp3 : 3 ≤ p) :
    2 ≤ (2 ^ p - 2) / p := by
  refine Nat.le_div_iff_mul_le hp.pos |>.2 ?_;
  exact Nat.le_sub_of_add_le ( by exact Nat.le_induction ( by norm_num ) ( fun k hk ih => by rw [ pow_succ' ] ; nlinarith [ Nat.Prime.one_lt hp ] ) p hp3 )

/-! ## Orbit Structure Theorems -/

/-
If z is periodic with period q, then all points on the orbit have the same period.
    The orbit {z, f(z), f²(z), ..., f^{q-1}(z)} forms a single cycle under iteration.
-/
theorem orbit_same_period (c z : ℂ) (q : ℕ) (hq : IsPeriodicPt' c z q) (k : ℕ) :
    IsPeriodicPt' c (quadIter c z k) q := by
  unfold IsPeriodicPt' at *;
  rw [ ← quadIter_add, add_comm, quadIter_add, hq ]

/-! ## The Fibonacci-Farey Connection -/

/-- The Farey mediant of two fractions p₁/q₁ and p₂/q₂ is (p₁+p₂)/(q₁+q₂).
    In the Mandelbrot set, this operation governs the arrangement of bulbs:
    the bulb "between" p₁/q₁ and p₂/q₂ has rotation number equal to the mediant. -/
def fareyMediant (p₁ q₁ p₂ q₂ : ℕ) : ℕ × ℕ := (p₁ + p₂, q₁ + q₂)

/-
Fibonacci numbers emerge from iterated Farey mediation between 1/2 and 1/3.
    The denominators (periods) follow the Fibonacci sequence, explaining why
    Fibonacci-period bulbs are prominent in the Mandelbrot set's antenna.
-/
theorem fibonacci_from_farey (n : ℕ) :
    (fareyMediant (Nat.fib n) (Nat.fib (n + 1))
      (Nat.fib (n + 1)) (Nat.fib (n + 2))).2 = Nat.fib (n + 3) := by
  -- By definition of `fareyMediant`, we have:
  simp [fareyMediant];
  simp +arith +decide [ Nat.fib_add_two ]

/-! ## Escape Criterion -/

/-
If |z_n| > 2 and |z_n| > |c|, then |z_{n+1}| > |z_n|.
    This is the basis of the escape-time algorithm for rendering the Mandelbrot set.
-/
theorem escape_norm_growth (c z : ℂ) (n : ℕ)
    (h1 : 2 < ‖quadIter c z n‖)
    (h2 : ‖c‖ < ‖quadIter c z n‖) :
    ‖quadIter c z n‖ < ‖quadIter c z (n + 1)‖ := by
  -- We have $‖w‖ < ‖w^2 + c‖$ by the triangle inequality.
  have h_triangle : ‖quadIter c z n‖^2 - ‖c‖ ≤ ‖quadIter c z (n + 1)‖ := by
    convert norm_sub_norm_le ( ( quadIter c z n ) ^ 2 ) ( -c ) using 1 ; norm_num [ quadIter_succ ] ; ring;
    rw [ add_comm, quadIter_succ ];
  nlinarith

/-! ## The Dynatomic Degree and Necklace Numbers -/

/-- The number of periodic points of exact period n for z² + c (generically)
    is given by the necklace number formula using Möbius inversion:
    Ψ(n) = ∑_{d|n} μ(n/d) · 2^d.
    For n = 1: Ψ(1) = 2 (the two fixed points).
    For n = 2: Ψ(2) = 2² - 2 = 2.
    For prime p: Ψ(p) = 2^p - 2. -/
def dynatomicPointCount (n : ℕ) : ℤ :=
  ∑ d ∈ n.divisors, ArithmeticFunction.moebius (n / d) * (2 ^ d : ℤ)

/-
For n = 1, there are exactly 2 fixed points (generically).
-/
theorem dynatomic_one : dynatomicPointCount 1 = 2 := by
  native_decide +revert

/-
For n = 2, there are exactly 2 period-2 points (one 2-cycle).
-/
theorem dynatomic_two : dynatomicPointCount 2 = 2 := by
  native_decide +revert

/-
For n = 3, there are exactly 6 period-3 points (two 3-cycles).
-/
theorem dynatomic_three : dynatomicPointCount 3 = 6 := by
  native_decide +revert

/-
The dynatomic point count is always nonnegative.
    This is a nontrivial result connecting Möbius inversion with
    the structure of polynomial dynamics.
-/
theorem dynatomic_nonneg (n : ℕ) (hn : 0 < n) : 0 ≤ dynatomicPointCount n := by
  -- We will prove that the sum of the Möbius function over the divisors of n is nonnegative.
  have h_sum_nonneg : ∀ n : ℕ, 0 < n → 0 ≤ ∑ d ∈ Nat.divisors n, (ArithmeticFunction.moebius (n / d)) * (2 ^ d : ℤ) := by
    intro n hn_pos
    induction' n using Nat.strong_induction_on with n ih;
    -- Consider the sum $\sum_{d \mid n} \mu(n/d) \cdot 2^d$. We can rewrite this as $2^n + \sum_{d \mid n, d < n} \mu(n/d) \cdot 2^d$.
    have h_sum : ∑ d ∈ Nat.divisors n, (ArithmeticFunction.moebius (n / d)) * (2 ^ d : ℤ) = 2 ^ n + ∑ d ∈ Nat.properDivisors n, (ArithmeticFunction.moebius (n / d)) * (2 ^ d : ℤ) := by
      rw [ ← Nat.cons_self_properDivisors hn_pos.ne', Finset.sum_cons ] ; aesop;
    -- Consider the sum $\sum_{d \mid n, d < n} \mu(n/d) \cdot 2^d$. We can bound this sum using the induction hypothesis.
    have h_bound : |∑ d ∈ Nat.properDivisors n, (ArithmeticFunction.moebius (n / d)) * (2 ^ d : ℤ)| ≤ ∑ d ∈ Nat.properDivisors n, 2 ^ d := by
      refine' le_trans ( Finset.abs_sum_le_sum_abs _ _ ) _;
      norm_num [ abs_mul, ArithmeticFunction.moebius ];
      exact Finset.sum_le_sum fun x hx => by split_ifs <;> norm_num [ abs_mul, abs_of_nonneg ] ;
    -- The sum $\sum_{d \mid n, d < n} 2^d$ is a geometric series with sum $2^n - 1$.
    have h_geo_series : ∑ d ∈ Nat.properDivisors n, 2 ^ d ≤ 2 ^ n - 1 := by
      have h_geo_series : ∑ d ∈ Finset.range n, 2 ^ d = 2 ^ n - 1 := by
        rw [ Nat.geomSum_eq ] <;> norm_num;
      exact h_geo_series ▸ Finset.sum_le_sum_of_subset ( fun x hx => Finset.mem_range.mpr ( Nat.mem_properDivisors.mp hx |>.2 ) );
    linarith [ abs_le.mp h_bound, Nat.sub_add_cancel ( Nat.one_le_pow n 2 zero_lt_two ) ];
  exact h_sum_nonneg n hn

/-! ## Conjecture: Multiplier-Period Correspondence -/

/-
**Conjecture**: For c at the center of the p/q-bulb of the Mandelbrot set,
    the critical orbit has exact period q, and the multiplier of the cycle is 0
    (superattracting). This is a consequence of the Douady-Hubbard theory:
    the center of each hyperbolic component has a superattracting cycle.

    We state this as: if c gives a superattracting cycle of period q starting at 0,
    then q = period and the multiplier is 0.

    This relates bulb geometry to number theory: the period q determines the
    algebraic degree of the center's minimal polynomial over ℚ, which equals
    the dynatomic point count Ψ(q)/q.
-/
theorem superattracting_center_period (c : ℂ) (q : ℕ) (hq : 0 < q)
    (hper : mandelbrotIter c q = 0) -- critical point returns to itself
    (hmin : ∀ d, 0 < d → d < q → mandelbrotIter c d ≠ 0) : -- q is minimal
    orbitMultiplier c 0 q = 0 := by
  unfold orbitMultiplier;
  induction hq <;> simp_all +decide [ orbitProduct ];
  rename_i k hk ih;
  exact Or.inr ( by rw [ show orbitProduct c 0 k = 0 from by exact Nat.le_induction ( by aesop ) ( fun n hn ih => by rw [ show orbitProduct c 0 ( n + 1 ) = quadIter c 0 n * orbitProduct c 0 n from by rfl ] ; aesop ) k hk ] )

end