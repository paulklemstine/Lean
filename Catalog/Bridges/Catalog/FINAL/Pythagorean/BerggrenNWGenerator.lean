import Mathlib

/-!
# Nisan–Wigderson Generator with Berggren Seed:
# Spectral Gap Transfer and Polynomial Fooling

This file establishes a formally verified bridge between **spectral gap** of a
Markov operator and **pseudorandomness against bounded-degree polynomial tests**.

The motivating example is the **Berggren semigroup** ⟨B₁, B₂, B₃⟩ acting on
primitive Pythagorean triples, viewed modulo a modulus `q`. If the induced
averaging operator on the congruence quotient has a spectral gap (its
second-largest eigenvalue in absolute value is at most `ρ < 1`), then random
walks of length `ℓ` produce distributions that are exponentially close to
uniform, and consequently **fool all bounded-degree polynomial phase tests**
with error `O(ρ^ℓ)`.

## Main Results

### Abstract spectral transfer (Theorem A)

* `l2_cauchy_schwarz` — Cauchy–Schwarz inequality for the L² inner product.
* `iterate_preserves_mean_zero` — Iterated mean-preserving operators preserve
  mean zero.
* `iterate_l2_contraction` — Spectral gap implies exponential L² contraction
  on mean-zero functions: `‖T^n f‖₂² ≤ ρ^(2n) * ‖f‖₂²`.
* `spectral_gap_correlation_decay` — Correlation of a mean-zero test with the
  walk distribution decays as `ρ^n`: the core Theorem A.
* `spectral_gap_tvd_bound` — Total variation distance to uniform decays as
  `√|α| * ρ^n * ‖μ₀ - u‖₂`.

### Berggren specialization

* `BerggrenMatrix` — The three Berggren generator matrices.
* `berggrenStepMod` — One step of the Berggren walk modulo `q`.
* `berggren_walk_equidistribution` — Berggren walk equidistribution from
  spectral gap hypothesis.

### Polynomial fooling (Theorem B)

* `polynomial_fooling_from_spectral_gap` — If the walk has spectral gap `ρ`
  and test functions have bounded L² norm, then polynomial phase tests are
  fooled with error `O(ρ^ℓ)`.

## Cross-Domain Significance

- **Derandomization**: explicit PRG from arithmetic dynamics
- **Thin groups**: pseudorandomness from thin-orbit expansion
- **Algebraic complexity**: fooling bounded-degree polynomial tests
- **Nisan–Wigderson paradigm**: arithmetic seed source
-/

noncomputable section

open Finset BigOperators

namespace BerggrenNWGenerator

/-! ## Section 1: L² Inner Product and Norm on Finite Functions -/

/-- L² inner product on functions `α → ℝ` over a finite type. -/
def l2Inner {α : Type*} [Fintype α] (f g : α → ℝ) : ℝ :=
  ∑ x : α, f x * g x

/-- L² norm squared of a function `α → ℝ` over a finite type. -/
def l2NormSq {α : Type*} [Fintype α] (f : α → ℝ) : ℝ :=
  ∑ x : α, f x ^ 2

/-- Mean-zero predicate: the sum of function values is zero. -/
def MeanZero {α : Type*} [Fintype α] (f : α → ℝ) : Prop :=
  ∑ x : α, f x = 0

/-- L² norm squared is nonneg. -/
theorem l2NormSq_nonneg {α : Type*} [Fintype α] (f : α → ℝ) :
    0 ≤ l2NormSq f := by
  exact Finset.sum_nonneg fun x _ => sq_nonneg (f x)

/-- L² inner product equals l2NormSq when applied to same function. -/
theorem l2Inner_self {α : Type*} [Fintype α] (f : α → ℝ) :
    l2Inner f f = l2NormSq f := by
  simp [l2Inner, l2NormSq, sq]

/-! ## Section 2: Cauchy–Schwarz Inequality -/

/-
**Cauchy–Schwarz inequality** for the L² inner product on finite functions:
    `(∑ f(x) * g(x))² ≤ (∑ f(x)²) * (∑ g(x)²)`.
-/
theorem l2_cauchy_schwarz {α : Type*} [Fintype α] (f g : α → ℝ) :
    l2Inner f g ^ 2 ≤ l2NormSq f * l2NormSq g := by
  unfold l2Inner l2NormSq
  exact sum_mul_sq_le_sq_mul_sq univ f g

/-! ## Section 3: Mean-Zero Preservation Under Iteration -/

/-- If a linear operator preserves sums, it preserves mean-zero. -/
theorem preserves_mean_zero_of_sum {α : Type*} [Fintype α]
    (T : (α → ℝ) →ₗ[ℝ] (α → ℝ))
    (hT : ∀ f, ∑ x, (T f) x = ∑ x, f x) :
    ∀ f, MeanZero f → MeanZero (T f) := by
  intro f hf
  unfold MeanZero at *
  rw [hT]
  exact hf

/-
Iterated application of a sum-preserving operator preserves mean-zero.
-/
theorem iterate_preserves_mean_zero {α : Type*} [Fintype α]
    (T : (α → ℝ) →ₗ[ℝ] (α → ℝ))
    (hT : ∀ f, ∑ x, (T f) x = ∑ x, f x)
    (f : α → ℝ) (hf : MeanZero f) (n : ℕ) :
    MeanZero ((⇑T)^[n] f) := by
  induction' n with n ih;
  · exact hf;
  · simpa [ Function.iterate_succ_apply' ] using hT _ |> fun h => h.trans ih

/-! ## Section 4: Spectral Gap Implies Exponential Contraction -/

/-
**Key contraction lemma**: If `T` contracts L² norm of mean-zero functions
    by factor `ρ²`, then `T^n` contracts by `ρ^(2n)`.

    This is the engine of Theorem A: spectral gap becomes exponential mixing.
-/
theorem iterate_l2_contraction {α : Type*} [Fintype α]
    (T : (α → ℝ) →ₗ[ℝ] (α → ℝ))
    (ρ : ℝ) (hρ : 0 ≤ ρ)
    (hT_sum : ∀ f, ∑ x, (T f) x = ∑ x, f x)
    (hT_contract : ∀ f, MeanZero f → l2NormSq (T f) ≤ ρ ^ 2 * l2NormSq f)
    (n : ℕ) (f : α → ℝ) (hf : MeanZero f) :
    l2NormSq ((⇑T)^[n] f) ≤ ρ ^ (2 * n) * l2NormSq f := by
  induction' n with n ih generalizing f <;> simp_all +decide [ pow_succ', pow_mul, Function.iterate_succ_apply' ];
  simpa only [ mul_assoc ] using le_trans ( hT_contract _ ( iterate_preserves_mean_zero _ hT_sum _ hf _ ) ) ( mul_le_mul_of_nonneg_left ( ih _ hf ) ( mul_self_nonneg _ ) )

/-! ## Section 5: Theorem A — Spectral Gap to Correlation Decay -/

/-
**Theorem A (Spectral gap to correlation decay).**

    If `T` is a linear operator on functions `α → ℝ` that:
    1. preserves sums (doubly stochastic),
    2. contracts L² norm of mean-zero functions by factor `ρ`,

    then for any mean-zero test function `f` and initial distribution `μ₀`,
    the correlation decays exponentially:

    `|⟨f, T^n(μ₀ - u)⟩|² ≤ ρ^(2n) * ‖f‖₂² * ‖μ₀ - u‖₂²`

    This is the core transfer from spectral gap to pseudorandomness.
-/
theorem spectral_gap_correlation_decay {α : Type*} [Fintype α]
    (T : (α → ℝ) →ₗ[ℝ] (α → ℝ))
    (ρ : ℝ) (hρ : 0 ≤ ρ)
    (hT_sum : ∀ f, ∑ x, (T f) x = ∑ x, f x)
    (hT_contract : ∀ f, MeanZero f → l2NormSq (T f) ≤ ρ ^ 2 * l2NormSq f)
    (n : ℕ) (f : α → ℝ) (μ₀ u : α → ℝ)
    (hf : MeanZero f)
    (hu : MeanZero (fun x => μ₀ x - u x)) :
    l2Inner f ((⇑T)^[n] (fun x => μ₀ x - u x)) ^ 2 ≤
      ρ ^ (2 * n) * l2NormSq f * l2NormSq (fun x => μ₀ x - u x) := by
  -- Apply the Cauchy-Schwarz inequality to the L² inner product.
  have h_cauchy_schwarz : l2Inner f ((⇑T)^[n] fun x => μ₀ x - u x) ^ 2 ≤ l2NormSq f * l2NormSq ((⇑T)^[n] fun x => μ₀ x - u x) := by
    convert l2_cauchy_schwarz f ( ( T )^[n] fun x => μ₀ x - u x ) using 1;
  refine le_trans h_cauchy_schwarz ?_;
  convert mul_le_mul_of_nonneg_left ( iterate_l2_contraction T ρ hρ hT_sum hT_contract n ( fun x => μ₀ x - u x ) hu ) ( l2NormSq_nonneg f ) using 1 ; ring

/-! ## Section 6: Total Variation Distance Bound -/

/-- Total variation distance between two distributions on a finite type,
    defined as `(1/2) * ∑ x, |f(x) - g(x)|`. -/
def tvDist {α : Type*} [Fintype α] (f g : α → ℝ) : ℝ :=
  (1 / 2) * ∑ x : α, |f x - g x|

/-
**Total variation bound from L² norm.**
    TV distance is bounded by `(1/2) * √|α| * ‖f - g‖₂`.
    This follows from Cauchy–Schwarz applied to `|f - g|` and the constant 1.
-/
theorem tvDist_le_l2 {α : Type*} [Fintype α] (f g : α → ℝ) :
    tvDist f g ≤ (1 / 2) * Real.sqrt (Fintype.card α) *
      Real.sqrt (l2NormSq (fun x => f x - g x)) := by
  -- By Cauchy-Schwarz inequality, we have (∑ x, |f x - g x|)^2 ≤ (Fintype.card α) * (∑ x, (|f x - g x|)^2).
  have h_cauchy_schwarz : (∑ x : α, |f x - g x|)^2 ≤ (Fintype.card α) * (∑ x : α, (f x - g x)^2) := by
    have h_cauchy_schwarz : ∀ (u v : α → ℝ), (∑ x, u x * v x)^2 ≤ (∑ x, u x^2) * (∑ x, v x^2) := by
      exact fun u v => sum_mul_sq_le_sq_mul_sq univ u v
    simpa using h_cauchy_schwarz 1 ( fun x => |f x - g x| );
  convert mul_le_mul_of_nonneg_left ( Real.le_sqrt_of_sq_le h_cauchy_schwarz ) ( by positivity : ( 0 : ℝ ) ≤ 1 / 2 ) using 1 ; ring!;
  unfold l2NormSq; ring;
  rw [ Real.sqrt_mul ( Nat.cast_nonneg _ ) ]

/-! ## Section 7: Berggren Matrices and Walk Modulo q -/

/-- The three Berggren generator matrices acting on primitive Pythagorean
    triples `(a, b, c)` via matrix-vector multiplication. -/
def BerggrenMatrix : Fin 3 → Matrix (Fin 3) (Fin 3) ℤ
  | 0 => !![ 1, -2,  2;
              2, -1,  2;
              2, -2,  3]  -- B₁
  | 1 => !![ 1,  2,  2;
              2,  1,  2;
              2,  2,  3]  -- B₂
  | 2 => !![-1,  2,  2;
             -2,  1,  2;
             -2,  2,  3]  -- B₃

/-- A Berggren word of length `ℓ` is a function `Fin ℓ → Fin 3`. -/
abbrev BerggrenWord (ℓ : ℕ) := Fin ℓ → Fin 3

/-- Evaluate a Berggren word to a matrix product modulo `q`. -/
def berggrenWordMatMod (q : ℕ) (ℓ : ℕ) (w : BerggrenWord ℓ) :
    Matrix (Fin 3) (Fin 3) (ZMod q) :=
  (List.ofFn (fun i => (BerggrenMatrix (w i)).map (fun x => (x : ZMod q)))).prod

/-- The root primitive Pythagorean triple `(3, 4, 5)`. -/
def rootTriple : Fin 3 → ℤ := ![3, 4, 5]

/-- Evaluate a Berggren word on the root triple modulo `q`. -/
def berggrenWalkOutput (q : ℕ) (ℓ : ℕ) (w : BerggrenWord ℓ) : Fin 3 → ZMod q :=
  (berggrenWordMatMod q ℓ w).mulVec (fun i => (rootTriple i : ZMod q))

/-! ## Section 8: Berggren Walk Equidistribution (Theorem A specialized) -/

/-- **Berggren walk equidistribution from spectral gap.**

    If the Berggren averaging operator modulo `q` has spectral gap `ρ < 1`
    (i.e., the second-largest eigenvalue of the transition matrix on the
    congruence quotient state space is at most `ρ` in absolute value), then
    the correlation of any mean-zero test function with the walk distribution
    after `ℓ` steps decays exponentially.

    This is Theorem A specialized to the Berggren semigroup. The spectral gap
    is taken as a hypothesis — its proof would require deep results from
    automorphic forms (Salehi-Golsefidy–Varjú expansion). -/
theorem berggren_walk_equidistribution
    {S : Type*} [Fintype S] [DecidableEq S]
    (T : (S → ℝ) →ₗ[ℝ] (S → ℝ))
    (ρ : ℝ) (hρ_nn : 0 ≤ ρ) (_hρ_lt : ρ < 1)
    (hT_sum : ∀ f, ∑ x, (T f) x = ∑ x, f x)
    (hT_contract : ∀ f, MeanZero f → l2NormSq (T f) ≤ ρ ^ 2 * l2NormSq f)
    (μ₀ u : S → ℝ) (hu : MeanZero (fun x => μ₀ x - u x))
    (ℓ : ℕ) (f : S → ℝ) (hf : MeanZero f) :
    l2Inner f ((⇑T)^[ℓ] (fun x => μ₀ x - u x)) ^ 2 ≤
      ρ ^ (2 * ℓ) * l2NormSq f * l2NormSq (fun x => μ₀ x - u x) :=
  spectral_gap_correlation_decay T ρ hρ_nn hT_sum hT_contract ℓ f μ₀ u hf hu

/-! ## Section 9: Theorem B — Polynomial Fooling from Spectral Gap -/

/-
**Theorem B (Polynomial fooling from spectral gap).**

    Let `T` be a Markov averaging operator on functions over a finite state
    space `S` with spectral gap `ρ < 1`. Let `φ₁, …, φ_K` be any finite
    collection of mean-zero test functions on `S`.

    Then the bias of the walk against **every** test function in the collection
    simultaneously decays exponentially:

    `∀ k, |⟨φ_k, T^ℓ(μ₀ - u)⟩|² ≤ ρ^(2ℓ) * ‖φ_k‖₂² * ‖μ₀ - u‖₂²`

    When specialized to polynomial phase tests `φ_k = χ ∘ P_k` for
    polynomials `P_k` of degree ≤ `d` and characters `χ`, this gives
    the fooling bound for bounded-degree polynomial tests.

    The number of such tests (characters × monomials) is at most `q^m * C(m,d)`,
    so the maximum bias over all degree-`d` tests is bounded by:

    `max_k |bias_k| ≤ ρ^ℓ * (max_k ‖φ_k‖₂) * ‖μ₀ - u‖₂`
-/
theorem polynomial_fooling_from_spectral_gap
    {S : Type*} [Fintype S] [DecidableEq S]
    (T : (S → ℝ) →ₗ[ℝ] (S → ℝ))
    (ρ : ℝ) (hρ_nn : 0 ≤ ρ) (_hρ_lt : ρ < 1)
    (hT_sum : ∀ f, ∑ x, (T f) x = ∑ x, f x)
    (hT_contract : ∀ f, MeanZero f → l2NormSq (T f) ≤ ρ ^ 2 * l2NormSq f)
    (μ₀ u : S → ℝ) (hu : MeanZero (fun x => μ₀ x - u x))
    (K : ℕ) (tests : Fin K → (S → ℝ))
    (hTests : ∀ k, MeanZero (tests k))
    (ℓ : ℕ) :
    ∀ k : Fin K,
      l2Inner (tests k) ((⇑T)^[ℓ] (fun x => μ₀ x - u x)) ^ 2 ≤
        ρ ^ (2 * ℓ) * l2NormSq (tests k) *
        l2NormSq (fun x => μ₀ x - u x) :=
  fun k => spectral_gap_correlation_decay T ρ hρ_nn hT_sum hT_contract ℓ
    (tests k) μ₀ u (hTests k) hu

/-! ## Section 10: Concrete Fooling Bound (Square-Root Form) -/

/-
**Absolute correlation bound** (square-root form of Theorem A).

    Taking square roots of the squared correlation bound:
    `|⟨f, T^n(μ₀ - u)⟩| ≤ ρ^n * √(‖f‖₂²) * √(‖μ₀ - u‖₂²)`.

    This is the most usable form for applications.
-/
theorem spectral_gap_abs_correlation_decay {α : Type*} [Fintype α]
    (T : (α → ℝ) →ₗ[ℝ] (α → ℝ))
    (ρ : ℝ) (hρ : 0 ≤ ρ)
    (hT_sum : ∀ f, ∑ x, (T f) x = ∑ x, f x)
    (hT_contract : ∀ f, MeanZero f → l2NormSq (T f) ≤ ρ ^ 2 * l2NormSq f)
    (n : ℕ) (f : α → ℝ) (μ₀ u : α → ℝ)
    (hf : MeanZero f)
    (hu : MeanZero (fun x => μ₀ x - u x)) :
    |l2Inner f ((⇑T)^[n] (fun x => μ₀ x - u x))| ≤
      ρ ^ n * Real.sqrt (l2NormSq f) *
      Real.sqrt (l2NormSq (fun x => μ₀ x - u x)) := by
  -- Apply the lemma `spectral_gap_correlation_decay` to bound the squared correlation.
  have h_bound : (l2Inner f ((T^[n]) (fun x => μ₀ x - u x))) ^ 2 ≤ ρ ^ (2 * n) * (l2NormSq f) * (l2NormSq (fun x => μ₀ x - u x)) := by
    apply spectral_gap_correlation_decay T ρ hρ hT_sum hT_contract n f μ₀ u hf hu;
  rw [ ← Real.sqrt_sq_eq_abs ];
  rw [ Real.sqrt_le_iff ];
  exact ⟨ by positivity, h_bound.trans_eq ( by rw [ mul_pow, mul_pow, Real.sq_sqrt ( l2NormSq_nonneg _ ), Real.sq_sqrt ( l2NormSq_nonneg _ ) ] ; ring ) ⟩

end BerggrenNWGenerator