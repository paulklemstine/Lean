import Mathlib

/-!
# Collatz Convergence via Tropical Contracting Dynamics

This module formalizes a bridge between the Collatz iteration and tropical/logarithmic
contraction theory. We define the Collatz map and its accelerated variants, introduce
a logarithmic potential (tropical coordinate), and prove:

1. **Exact branch identities** in logarithmic coordinates (even branch).
2. **Coarse tropical majorization** for the odd branch.
3. **Arithmetic contraction** when the 2-adic valuation provides extra division.
4. **Conditional convergence theorems** reducing Collatz convergence to
   strict descent or logarithmic contraction hypotheses.
5. **Two-step accelerated bounds** showing net potential change for odd→even pairs.

These results are unconditional where stated without hypotheses, and cleanly
conditional where global convergence would require unproven assumptions.
-/

noncomputable section

namespace CollatzTropical

/-! ## Definitions -/

/-- The standard Collatz map: divide by 2 if even, multiply by 3 and add 1 if odd. -/
def collatz (n : ℕ) : ℕ :=
  if n % 2 = 0 then n / 2 else 3 * n + 1

/-- The Collatz odd step: maps n to (3n+1)/2, combining the odd step with one halving. -/
def collatzOdd (n : ℕ) : ℕ := (3 * n + 1) / 2

/-- Logarithmic potential: the tropical coordinate for Collatz dynamics. -/
def logPotential (n : ℕ) : ℝ := Real.log (n : ℝ)

/-! ## Basic Computations -/

/-- The Collatz map on even inputs simply halves. -/
theorem collatz_even {n : ℕ} (h : n % 2 = 0) : collatz n = n / 2 := by
  simp [collatz, h]

/-- The Collatz map on odd inputs applies 3n+1. -/
theorem collatz_odd {n : ℕ} (h : n % 2 = 1) : collatz n = 3 * n + 1 := by
  unfold collatz; split_ifs with h2 <;> omega

/-- The fundamental Collatz cycle: 1 → 4 → 2 → 1.
    Note that 1 is NOT a fixed point of the standard Collatz map;
    rather, {1, 2, 4} forms a 3-cycle. -/
theorem collatz_cycle : collatz 1 = 4 ∧ collatz 4 = 2 ∧ collatz 2 = 1 := by
  refine ⟨?_, ?_, ?_⟩ <;> native_decide

/-- For odd n, 3n+1 is always even, so the next Collatz step is a halving. -/
theorem collatz_odd_produces_even {n : ℕ} (hOdd : n % 2 = 1) :
    (3 * n + 1) % 2 = 0 := by
  omega

/-- Two steps of Collatz starting from an odd number: first 3n+1, then divide by 2. -/
theorem collatz_two_step_odd {n : ℕ} (hOdd : n % 2 = 1) :
    collatz (collatz n) = (3 * n + 1) / 2 := by
  rw [collatz_odd hOdd, collatz_even (collatz_odd_produces_even hOdd)]

/-! ## Arithmetic Contraction Lemmas -/

/-- If 4 divides 3n+1 and n ≥ 1, then (3n+1)/4 ≤ n.
    This is the weak form of arithmetic contraction under extra 2-adic division. -/
theorem odd_branch_weakly_contracts_if_four_dvd
    {n : ℕ} (hn : 1 ≤ n) (h4 : 4 ∣ (3 * n + 1)) :
    (3 * n + 1) / 4 ≤ n := by
  omega

/-- If 4 divides 3n+1 and n ≥ 2, then (3n+1)/4 < n (strict contraction).
    This isolates a uniform arithmetic contraction regime: whenever the odd step
    produces a number divisible by 4, the quotient is strictly smaller. -/
theorem odd_branch_contracts_if_four_dvd
    {n : ℕ} (hn : 2 ≤ n) (h4 : 4 ∣ (3 * n + 1)) :
    (3 * n + 1) / 4 < n := by
  omega

/-- The descent threshold for 4-divisibility contraction: N = 2 suffices. -/
theorem accelerated_collatz_descent_above_threshold :
    ∃ N : ℕ, ∀ n : ℕ, N ≤ n → 4 ∣ (3 * n + 1) → (3 * n + 1) / 4 < n := by
  exact ⟨2, fun n hn _ => by omega⟩

/-
The accelerated odd map (3n+1)/2 satisfies (3n+1)/2 ≤ 2n for n ≥ 1.
    This is a coarse arithmetic bound showing the odd step grows by at most factor 2.
-/
theorem collatzOdd_le_two_mul {n : ℕ} (hn : 1 ≤ n) :
    collatzOdd n ≤ 2 * n := by
  exact Nat.div_le_of_le_mul <| by linarith;

/-
For odd n ≡ 1 (mod 4), the value 3n+1 is divisible by 4, giving extra contraction.
    This identifies the favorable residue class for the accelerated dynamics.
-/
theorem four_dvd_of_one_mod_four {n : ℕ} (h : n % 4 = 1) :
    4 ∣ (3 * n + 1) := by
  norm_num [ Nat.dvd_iff_mod_eq_zero, Nat.add_mod, Nat.mul_mod, h ]

/-! ## Conditional Convergence Theorems -/

/-- **Convergence from strict descent**: If a map T sends every n ≥ 2 to a strictly
    smaller positive value, then every positive natural eventually reaches 1.
    This is the core fixed-point theorem for arithmetic dynamics.

    The proof uses strong induction on ℕ: for n = 1 we are done; for n ≥ 2,
    T(n) < n and T(n) ≥ 1, so the inductive hypothesis applies. -/
theorem convergence_of_strict_descent
    (T : ℕ → ℕ)
    (hPos : ∀ n, 1 ≤ n → 1 ≤ T n)
    (hDesc : ∀ n, 2 ≤ n → T n < n)
    : ∀ n, 1 ≤ n → ∃ m, Nat.iterate T m n = 1 := by
  intro n hn
  induction' n using Nat.strongRecOn with n ih
  exact if h : n = 1 then ⟨0, h⟩ else by
    obtain ⟨m, hm⟩ := ih (T n) (hDesc n (by omega)) (hPos n hn)
    exact ⟨m + 1, by simpa [Function.iterate_succ'] using hm⟩

/-- **Convergence from eventual descent**: Generalization with a threshold N.
    If T is strictly descending above N and all values below N eventually reach 1,
    then every positive natural reaches 1. This separates the "contracting regime"
    (n ≥ N, proved by potential theory) from the "finite verification regime"
    (n < N, checked computationally). -/
theorem collatz_convergence_of_eventual_descent
    (T : ℕ → ℕ) (N : ℕ)
    (hPos : ∀ n, 1 ≤ n → 1 ≤ T n)
    (hDesc : ∀ n, N ≤ n → T n < n)
    (hSmall : ∀ n, 1 ≤ n → n < N → ∃ m, Nat.iterate T m n = 1)
    : ∀ n, 1 ≤ n → ∃ m, Nat.iterate T m n = 1 := by
  intro n hn
  induction' n using Nat.strongRecOn with n ih
  by_cases h : n < N
  · exact hSmall n hn h
  · have hTn := hDesc n (le_of_not_gt h)
    obtain ⟨m, hm⟩ := ih (T n) hTn (hPos n hn)
    exact ⟨m + 1, by simpa [Function.iterate_succ'] using hm⟩

/-! ## Logarithmic Branch Analysis -/

/-
**Even branch identity**: In logarithmic/tropical coordinates, the even branch
    of the Collatz map acts as a translation by -log 2. This is exact, not an estimate.
-/
theorem collatz_log_even
    {n : ℕ} (hn : 2 ≤ n) (hEven : n % 2 = 0) :
    logPotential (collatz n) = logPotential n - Real.log 2 := by
  unfold logPotential collatz;
  rw [ if_pos hEven, Nat.cast_div ( Nat.dvd_of_mod_eq_zero hEven ) ] <;> norm_num;
  exact Real.log_div ( by positivity ) ( by positivity )

/-
**Odd branch coarse majorization**: In logarithmic coordinates, the odd branch
    is bounded above by a translation by +log 4. Since 3n+1 ≤ 4n for n ≥ 1,
    the tropical update has slope at most log 4 in the odd case.
-/
theorem collatz_log_odd_upper_coarse
    {n : ℕ} (hn : 1 ≤ n) (hOdd : n % 2 = 1) :
    logPotential (collatz n) ≤ logPotential n + Real.log 4 := by
  unfold logPotential collatz;
  rw [ ← Real.log_mul, Real.log_le_log_iff ] <;> norm_cast <;> norm_num [ hOdd ] ; linarith;
  · grind +revert;
  · linarith

/-
**Two-step odd-then-even bound**: For odd n ≥ 1, two steps of Collatz give
    (3n+1)/2, and log((3n+1)/2) ≤ log(n) + log(2). This is the key bound for
    the accelerated odd map showing growth by at most factor 2.
-/
theorem collatz_two_step_log_bound
    {n : ℕ} (hn : 1 ≤ n) (hOdd : n % 2 = 1) :
    logPotential (collatz (collatz n)) ≤ logPotential n + Real.log 2 := by
  convert Real.log_le_log ?_ ?_ using 1;
  rotate_left;
  exact 2 * n;
  · unfold collatz;
    norm_num [ Nat.add_mod, Nat.mul_mod, hOdd ];
    linarith;
  · unfold collatz;
    split_ifs <;> norm_cast <;> omega;
  · rw [ Real.log_mul ] <;> norm_num ; ring;
    · exact add_comm _ _;
    · grind +splitImp

/-! ## Logarithmic Contraction Implies Arithmetic Descent -/

/-
**Bridge theorem**: Logarithmic contraction with ratio c < 1 implies
    strict arithmetic descent. If log(T(n)) ≤ c · log(n) for all n ≥ 2
    (with T(n) ≥ 1), then T(n) < n for all n ≥ 2.

    Proof sketch: T(n) ≤ exp(c · log(n)) = n^c. Since 0 < c < 1 and n ≥ 2 > 1,
    we have n^c < n, hence T(n) < n.
-/
theorem log_contraction_implies_descent
    (T : ℕ → ℕ)
    (c : ℝ) (hc : c < 1)
    (hContract : ∀ n : ℕ, 2 ≤ n → Real.log (T n : ℝ) ≤ c * Real.log (n : ℝ))
    (hPos : ∀ n, 1 ≤ n → 1 ≤ T n)
    : ∀ n : ℕ, 2 ≤ n → T n < n := by
  intro n hn
  have hT_lt_n : (T n : ℝ) < n := by
    exact_mod_cast ( by have := hContract n hn; rw [ ← Real.log_lt_log_iff ( Nat.cast_pos.mpr ( hPos n ( by linarith ) ) ) ( Nat.cast_pos.mpr ( by linarith ) ) ] ; nlinarith [ Real.log_pos ( show ( n : ℝ ) > 1 by norm_cast ) ] : ( T n : ℝ ) < n );
  exact_mod_cast hT_lt_n

/-! ## The Reduction Theorem: From Log-Contraction to Collatz Convergence -/

/-
**The Architectural Reduction Theorem**: This packages the complete reduction
    from Collatz convergence to logarithmic contraction. If there exists an accelerated
    Collatz operator T and a contraction ratio c < 1 such that:
    1. T preserves positivity,
    2. log(T(n)) ≤ c · log(n) for all n ≥ N,
    3. All small values reach 1,
    then every positive natural reaches 1 under T.

    This theorem composes `log_contraction_implies_descent` with
    `collatz_convergence_of_eventual_descent` to bridge from tropical/spectral
    analysis to concrete orbit convergence.
-/
theorem collatz_convergence_of_log_contraction
    (T : ℕ → ℕ) (N : ℕ)
    (c : ℝ) (hc : c < 1)
    (hPos : ∀ n, 1 ≤ n → 1 ≤ T n)
    (hContract : ∀ n : ℕ, N ≤ n → Real.log (T n : ℝ) ≤ c * Real.log (n : ℝ))
    (hSmall : ∀ n, 1 ≤ n → n < N → ∃ m, Nat.iterate T m n = 1)
    : ∀ n, 1 ≤ n → ∃ m, Nat.iterate T m n = 1 := by
  -- Apply the reduction theorem to conclude the proof.
  apply collatz_convergence_of_eventual_descent;
  exact hPos;
  case N => exact Max.max N 2;
  · intro n hn; have := hContract n ( le_trans ( le_max_left _ _ ) hn ) ; contrapose! this;
    exact lt_of_lt_of_le ( mul_lt_of_lt_one_left ( Real.log_pos ( Nat.one_lt_cast.mpr ( by linarith [ le_max_right N 2 ] ) ) ) hc ) ( Real.log_le_log ( Nat.cast_pos.mpr ( by linarith [ le_max_right N 2 ] ) ) ( Nat.cast_le.mpr this ) );
  · intro n hn hn'; cases max_cases N 2 <;> simp_all +decide ;
    interval_cases n ; exact ⟨ 0, rfl ⟩

/-! ## Unique Fixed Point from Contraction -/

/-- In any metric space, a contracting map has at most one fixed point.
    This is a direct application of the contraction mapping principle and connects
    the Collatz tropical framework to standard metric fixed-point theory. -/
theorem unique_fixed_point_of_contraction
    {X : Type*} [MetricSpace X] {T : X → X} {K : NNReal}
    (hK : K < 1) (hcontract : ∀ x y : X, dist (T x) (T y) ≤ K * dist x y)
    {x₀ : X} (hfix : T x₀ = x₀)
    : ∀ y : X, T y = y → y = x₀ := by
  intro y hy
  have h := hcontract x₀ y
  rw [hfix, hy] at h
  by_contra hne
  have hd : 0 < dist x₀ y := dist_pos.mpr (Ne.symm hne)
  have hK1 : (K : ℝ) < 1 := NNReal.coe_lt_coe.mpr hK
  linarith [mul_lt_of_lt_one_left hd hK1]

end CollatzTropical

end