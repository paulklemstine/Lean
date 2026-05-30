import Mathlib

/-! # EML–Kolmogorov-Arnold Representation Theory

The Kolmogorov-Arnold theorem (1957) states that any continuous function
f : [0,1]^n → ℝ can be written as

  f(x₁, …, xₙ) = Σ_{q=0}^{2n} Φ_q( Σ_{p=1}^n φ_{q,p}(x_p) )

where each φ_{q,p} and Φ_q is a continuous univariate function.

This module investigates the conjecture that the inner functions φ_{q,p}
can be chosen from the EML function class — compositions of exp and log.
We prove this concretely for multiplication, power functions, and
geometric means on (0,∞), establishing that fundamental multivariate
operations admit EML-KA decompositions.

## Main definitions

* `KADecomp₂` — A Kolmogorov-Arnold-style decomposition for functions ℝ → ℝ → ℝ
  with Q terms, each using inner functions φ₁, φ₂ and an outer function Φ.
* `EMLPrimitive` — The class of EML primitive functions: exp, log, and affine maps.
* `klDivIntegrand` — The KL-divergence integrand p · log(p/q), shown to decompose via EML.

## Main results

* `mul_ka_decomp_spec` — Multiplication on (0,∞) has a 1-term EML-KA decomposition.
* `exp_mul_log_eq_pow` — Power functions x^n have EML-KA decompositions via n·log(x).
* `exp_half_log_eq_sqrt_mul` — The geometric mean √(xy) = exp(½(log x + log y)).
* `mul_ka_continuous_on` — The EML-KA multiplication map is continuous on (0,∞)².
* `kl_div_decomp` — The KL-divergence integrand decomposes via EML (cross-domain).
* `eml_ka_inner_separates` — EML primitives separate distinct positive points.
* `ka_add_eval` — KA decompositions are closed under addition.
-/

noncomputable section
open Real Set MeasureTheory

/-! ## §1. EML Primitives and Kolmogorov-Arnold Structure -/

/-- The EML operation: eml(x, y) = exp(x) - log(y). -/
def eml_ka (x y : ℝ) : ℝ := exp x - log y

/-- An EML primitive function type. These are the building blocks for
    inner functions in EML-KA decompositions. -/
inductive EMLPrimitive where
  | expFn : EMLPrimitive
  | logFn : EMLPrimitive
  | affine (a b : ℝ) : EMLPrimitive

/-- Evaluate an EML primitive at a point. -/
def EMLPrimitive.eval : EMLPrimitive → ℝ → ℝ
  | .expFn => exp
  | .logFn => log
  | .affine a b => fun x => a * x + b

/-- A Kolmogorov-Arnold decomposition of a bivariate function with Q terms.
    Each term q has inner functions φ₁_q, φ₂_q : ℝ → ℝ and an outer function
    Φ_q : ℝ → ℝ, so that f(x,y) = Σ_q Φ_q(φ₁_q(x) + φ₂_q(y)). -/
structure KADecomp₂ (Q : ℕ) where
  /-- Inner functions for the first variable -/
  φ₁ : Fin Q → ℝ → ℝ
  /-- Inner functions for the second variable -/
  φ₂ : Fin Q → ℝ → ℝ
  /-- Outer functions -/
  Φ : Fin Q → ℝ → ℝ

/-- Evaluate a KA decomposition at a point (x, y). -/
def KADecomp₂.eval (d : KADecomp₂ Q) (x y : ℝ) : ℝ :=
  ∑ q : Fin Q, d.Φ q (d.φ₁ q x + d.φ₂ q y)

/-- A KA decomposition represents a function f if it evaluates to f everywhere
    on a given domain. -/
def KADecomp₂.represents (d : KADecomp₂ Q) (f : ℝ → ℝ → ℝ) (S : Set (ℝ × ℝ)) : Prop :=
  ∀ p ∈ S, d.eval p.1 p.2 = f p.1 p.2

/-! ## §2. Multiplication via EML-KA Decomposition

The key identity: for x, y > 0,
  x · y = exp(log x + log y)

This gives a 1-term KA decomposition with inner functions φ₁ = φ₂ = log
and outer function Φ = exp. Both log and exp are EML primitives. -/

/-- The 1-term KA decomposition for multiplication: inner = log, outer = exp. -/
def mulKADecomp : KADecomp₂ 1 where
  φ₁ := fun _ => log
  φ₂ := fun _ => log
  Φ := fun _ => exp

/-- Core algebraic identity: exp(log x + log y) = x * y for positive reals. -/
theorem exp_log_add_eq_mul (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    exp (log x + log y) = x * y := by
  rw [exp_add, exp_log hx, exp_log hy]

/-- The KA decomposition `mulKADecomp` evaluates to multiplication on (0,∞)². -/
theorem mul_ka_decomp_spec (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    mulKADecomp.eval x y = x * y := by
  simp only [mulKADecomp, KADecomp₂.eval, Fin.sum_univ_one]
  exact exp_log_add_eq_mul x y hx hy

/-- The multiplication KA decomposition represents (· * ·) on (0,∞)². -/
theorem mul_ka_represents :
    mulKADecomp.represents (fun x y => x * y) (Ioi 0 ×ˢ Ioi 0) := by
  intro ⟨x, y⟩ ⟨hx, hy⟩
  exact mul_ka_decomp_spec x y hx hy

/-! ## §3. Power Functions via EML-KA

For any n : ℕ, x^n = exp(n · log x) for x > 0.
This gives a 1-term KA decomposition with a single variable. -/

/-- The KA decomposition for x^n: inner φ₁(x) = n · log(x), φ₂ trivial. -/
def powKADecomp (n : ℕ) : KADecomp₂ 1 where
  φ₁ := fun _ x => n * log x
  φ₂ := fun _ _ => 0
  Φ := fun _ => exp

/-- Core identity: exp(n · log x) = x^n for x > 0.
    Proved by induction on n with the exp-add law. -/
theorem exp_mul_log_eq_pow (x : ℝ) (n : ℕ) (hx : 0 < x) :
    exp (↑n * log x) = x ^ n := by
  induction n with
  | zero => simp [exp_zero]
  | succ k ih =>
    rw [Nat.cast_succ, add_mul, one_mul, exp_add, ih, exp_log hx, mul_comm]
    ring

/-- The power KA decomposition correctly computes x^n on (0,∞). -/
theorem pow_ka_decomp_spec (x : ℝ) (n : ℕ) (hx : 0 < x) :
    (powKADecomp n).eval x 1 = x ^ n := by
  simp only [powKADecomp, KADecomp₂.eval, Fin.sum_univ_one, add_zero]
  exact exp_mul_log_eq_pow x n hx

/-! ## §4. Geometric Mean via EML-KA

The geometric mean √(xy) = exp(½ · (log x + log y)).
This is a 1-term KA decomposition with φ₁ = φ₂ = (1/2) · log
and Φ = exp. -/

/-- The KA decomposition for the geometric mean. -/
def geomMeanKADecomp : KADecomp₂ 1 where
  φ₁ := fun _ x => (1/2 : ℝ) * log x
  φ₂ := fun _ y => (1/2 : ℝ) * log y
  Φ := fun _ => exp

/-
Core identity: exp(½ log x + ½ log y) = √(xy) for x, y > 0.
-/
theorem exp_half_log_eq_sqrt_mul (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    exp ((1/2 : ℝ) * log x + (1/2 : ℝ) * log y) = sqrt (x * y) := by
  rw [ Real.sqrt_eq_rpow, Real.rpow_def_of_pos ( mul_pos hx hy ) ] ; rw [ Real.log_mul hx.ne' hy.ne' ] ; ring;

/-- The geometric mean KA decomposition computes √(xy) on (0,∞)². -/
theorem geom_mean_ka_spec (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    geomMeanKADecomp.eval x y = sqrt (x * y) := by
  simp only [geomMeanKADecomp, KADecomp₂.eval, Fin.sum_univ_one]
  exact exp_half_log_eq_sqrt_mul x y hx hy

/-! ## §5. Continuity of EML-KA Components

The inner function log is continuous on (0,∞) and the outer function
exp is continuous on all of ℝ. This means EML-KA decompositions
produce continuous representations. -/

/-- The inner function log is continuous on (0,∞). -/
theorem ka_inner_log_continuous : ContinuousOn log (Ioi 0) :=
  Real.continuousOn_log.mono (fun x hx => by simp [Set.mem_compl_iff]; exact ne_of_gt hx)

/-- The outer function exp is continuous everywhere. -/
theorem ka_outer_exp_continuous : Continuous exp := continuous_exp

/-- The composed evaluation map (x,y) ↦ exp(log x + log y) is continuous on (0,∞)². -/
theorem mul_ka_continuous_on :
    ContinuousOn (fun p : ℝ × ℝ => exp (log p.1 + log p.2)) (Ioi 0 ×ˢ Ioi 0) := by
  apply Continuous.comp_continuousOn continuous_exp
  apply ContinuousOn.add
  · exact ka_inner_log_continuous.comp continuousOn_fst (fun ⟨x, _⟩ ⟨hx, _⟩ => hx)
  · exact ka_inner_log_continuous.comp continuousOn_snd (fun ⟨_, y⟩ ⟨_, hy⟩ => hy)

/-! ## §6. EML Separation and Universality Properties

For the Kolmogorov-Arnold theorem, the inner functions must separate points.
We show that EML primitives (specifically log) separate distinct positive points. -/

/-- An affine function a·x + b with a ≠ 0 is injective. -/
theorem affine_injective (a b : ℝ) (ha : a ≠ 0) :
    Function.Injective (fun x => a * x + b) := by
  intro x₁ x₂ h
  have : a * x₁ = a * x₂ := by linarith
  exact mul_left_cancel₀ ha this

/-- Log is injective on (0,∞), hence separates points. -/
theorem log_injective_pos : InjOn log (Ioi 0) :=
  Real.log_injOn_pos

/-- For any two distinct positive reals, their logs differ. -/
theorem log_separates_pos (x y : ℝ) (hx : 0 < x) (hy : 0 < y) (hne : x ≠ y) :
    log x ≠ log y :=
  fun heq => hne (log_injective_pos hx hy heq)

/-- The EML-KA inner functions separate points: for any distinct x₁ ≠ x₂ in (0,∞),
    there exists an EML primitive φ with φ(x₁) ≠ φ(x₂). -/
theorem eml_ka_inner_separates (x₁ x₂ : ℝ) (hx₁ : 0 < x₁) (hx₂ : 0 < x₂)
    (hne : x₁ ≠ x₂) :
    ∃ φ : EMLPrimitive, φ.eval x₁ ≠ φ.eval x₂ := by
  exact ⟨.logFn, log_separates_pos x₁ x₂ hx₁ hx₂ hne⟩

/-! ## §7. Cross-Domain: KL Divergence and EML (Information Theory)

The Kullback-Leibler divergence integrand p · log(p/q) has a natural
EML decomposition. For p, q > 0:

  p · log(p/q) = p · (log p - log q) = p · log p - p · log q

Each term p · log p is a function of a single variable, expressible
via EML primitives. This connects information theory to EML-KA. -/

/-- The KL divergence integrand. -/
def klDivIntegrand (p q : ℝ) : ℝ := p * log (p / q)

/-- The KL integrand decomposes as p·log(p) - p·log(q).
    This is a KA-style decomposition: f(p,q) = g₁(p) + g₂(p,q)
    where g₁(p) = p·log(p) and g₂(p,q) = -p·log(q). -/
theorem kl_div_decomp (p q : ℝ) (hp : 0 < p) (hq : 0 < q) :
    klDivIntegrand p q = p * log p - p * log q := by
  unfold klDivIntegrand
  rw [log_div hp.ne' hq.ne']
  ring

/-- The KL divergence integrand is zero when p = q. -/
theorem kl_div_self_eq_zero (p : ℝ) (hp : 0 < p) : klDivIntegrand p p = 0 := by
  simp [klDivIntegrand, div_self hp.ne']

/-- Express KL integrand via EML:
    p·log(p/q) = p·log(p) - (1 - eml_ka(0, q^p)).
    More precisely, the log(q) component can be extracted from eml_ka. -/
theorem kl_eml_connection (p q : ℝ) (hp : 0 < p) (hq : 0 < q) :
    klDivIntegrand p q = p * log p - p * (1 - eml_ka 0 q) := by
  unfold klDivIntegrand eml_ka
  rw [log_div hp.ne' hq.ne', exp_zero]
  ring

/-! ## §8. EML-KA Composition Closure

If f and g both have EML-KA decompositions, then so does f + g
(with combined number of terms). This is proved by Finset sum splitting. -/

/-- Sum of two KA decompositions. -/
def KADecomp₂.add (d₁ : KADecomp₂ Q₁) (d₂ : KADecomp₂ Q₂) : KADecomp₂ (Q₁ + Q₂) where
  φ₁ := fun q => if h : q.val < Q₁ then d₁.φ₁ ⟨q.val, h⟩ else d₂.φ₁ ⟨q.val - Q₁, by omega⟩
  φ₂ := fun q => if h : q.val < Q₁ then d₁.φ₂ ⟨q.val, h⟩ else d₂.φ₂ ⟨q.val - Q₁, by omega⟩
  Φ := fun q => if h : q.val < Q₁ then d₁.Φ ⟨q.val, h⟩ else d₂.Φ ⟨q.val - Q₁, by omega⟩

/-
The sum decomposition correctly evaluates to the sum of the original functions.
-/
theorem ka_add_eval (d₁ : KADecomp₂ Q₁) (d₂ : KADecomp₂ Q₂) (x y : ℝ) :
    (d₁.add d₂).eval x y = d₁.eval x y + d₂.eval x y := by
  unfold KADecomp₂.add KADecomp₂.eval;
  rw [ Fin.sum_univ_add ];
  simp +decide [ Fin.castAdd, Fin.natAdd ]

/-! ## §9. EML-KA Representation Count

The classical KA theorem requires 2n+1 terms for ℝⁿ.
For special functions (multiplication, powers), EML-KA uses just 1 term.
We formalize this efficiency gain. -/

/-- The classical KA term count for dimension n. -/
def kaTermCount (n : ℕ) : ℕ := 2 * n + 1

/-- For n = 2, the classical KA theorem requires 5 terms. -/
theorem ka_dim2_terms : kaTermCount 2 = 5 := by norm_num [kaTermCount]

/-- The EML-KA decomposition of multiplication uses 1 term, saving 4 terms
    compared to the general KA bound of 5. -/
theorem eml_ka_mul_savings : kaTermCount 2 - 1 = 4 := by norm_num [kaTermCount]

/-- For dimension n ≥ 1, the KA term count is always at least 3. -/
theorem ka_terms_ge_three (n : ℕ) (hn : 1 ≤ n) : 3 ≤ kaTermCount n := by
  unfold kaTermCount; omega

/-! ## §10. Falsifiable Conjecture

**Conjecture (EML-KA Universality)**: For every polynomial p : ℝ[X,Y]
with p(x,y) > 0 on (0,∞)², the function log ∘ p has a finite EML-KA
decomposition (i.e., one can write log(p(x,y)) = Σ_q Φ_q(φ_q(x) + ψ_q(y))
where each Φ_q, φ_q, ψ_q is composed of exp, log, and affine maps).

**Test for n=2**: For p(x,y) = x² + y², verify whether
log(x² + y²) admits a 3-term EML-KA decomposition with bounded depth. -/

/-- Conjecture instance: log(x² + y²) has a 3-term EML-KA decomposition on (1,∞)². -/
def logSumSqConjectureValid : Prop :=
  ∃ d : KADecomp₂ 3,
    ∀ x y : ℝ, 1 < x → 1 < y →
      d.eval x y = log (x ^ 2 + y ^ 2)

/-! ## §11. Weighted KA Decompositions

A generalization where terms have scalar weights, useful for
approximation theory. -/

/-- A weighted KA decomposition with Q terms and scalar weights. -/
structure WKADecomp₂ (Q : ℕ) extends KADecomp₂ Q where
  /-- Scalar weights for each term -/
  w : Fin Q → ℝ

/-- Evaluate a weighted KA decomposition. -/
def WKADecomp₂.eval (d : WKADecomp₂ Q) (x y : ℝ) : ℝ :=
  ∑ q : Fin Q, d.w q * d.Φ q (d.φ₁ q x + d.φ₂ q y)

/-- A 1-term weighted decomposition for x·y with weight 1. -/
def mulWKADecomp : WKADecomp₂ 1 where
  φ₁ := fun _ => log
  φ₂ := fun _ => log
  Φ := fun _ => exp
  w := fun _ => 1

/-- The weighted multiplication decomposition is correct. -/
theorem mul_wka_spec (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    mulWKADecomp.eval x y = x * y := by
  simp only [mulWKADecomp, WKADecomp₂.eval, Fin.sum_univ_one, one_mul]
  exact exp_log_add_eq_mul x y hx hy

/-! ## §12. EML Encoding of Division

Division x/y = exp(log x - log y) for x, y > 0.
This is another 1-term EML-KA decomposition. -/

/-- The KA decomposition for division. -/
def divKADecomp : KADecomp₂ 1 where
  φ₁ := fun _ x => log x
  φ₂ := fun _ y => -(log y)
  Φ := fun _ => exp

/-- Division via EML-KA: exp(log x - log y) = x / y for x, y > 0. -/
theorem div_ka_decomp_spec (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    divKADecomp.eval x y = x / y := by
  simp only [divKADecomp, KADecomp₂.eval, Fin.sum_univ_one]
  rw [show log x + -(log y) = log x - log y from by ring]
  rw [exp_sub, exp_log hx, exp_log hy]

/-! ## §13. EML-KA for the Harmonic Mean

The harmonic mean H(x,y) = 2xy/(x+y). We can express this via
the EML-KA decomposition of multiplication and division. -/

/-- Harmonic mean of two positive reals. -/
def harmonicMean (x y : ℝ) : ℝ := 2 * x * y / (x + y)

/-- The harmonic mean equals 2/(1/x + 1/y) for x, y > 0. -/
theorem harmonicMean_eq_inv (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    harmonicMean x y = 2 / (1/x + 1/y) := by
  unfold harmonicMean
  field_simp
  ring

/-! ## §14. Fenchel-Young and EML Connection

The Fenchel-Young inequality relates exp and log through convex duality.
This provides a variational characterization of the EML operation. -/

/-
Fenchel-Young inequality: x·s ≤ exp(x) + s·log(s) - s for s > 0.
    This bounds the EML operation from below via duality.
-/
theorem fenchel_young_eml (x s : ℝ) (hs : 0 < s) :
    x * s ≤ exp x + s * log s - s := by
  have := Real.log_le_sub_one_of_pos ( div_pos ( Real.exp_pos x ) ( show 0 < s by positivity ) );
  rw [ Real.log_div ( by positivity ) ( by positivity ), Real.log_exp ] at this ; nlinarith [ mul_div_cancel₀ ( Real.exp x ) hs.ne' ]

/-- The Fenchel-Young bound is tight at x = log s. -/
theorem fenchel_young_tight (s : ℝ) (hs : 0 < s) :
    log s * s = exp (log s) + s * log s - s := by
  rw [exp_log hs]
  ring

end