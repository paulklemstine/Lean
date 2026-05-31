import Mathlib

/-! # Deep EML–Kolmogorov-Arnold Representation Theory

This module develops the connection between the EML (exp-minus-log) function class
and the Kolmogorov-Arnold representation theorem. We introduce **EML chains** —
finite compositions of exp, log, and affine maps — and prove structural results
about their Kolmogorov-Arnold decomposition capabilities.

## Main new definitions

* `EMLChainOp` — Elementary operations in an EML chain (exp, log, affine).
* `evalChain` / `chainDepth` — Evaluation and depth of EML chains.
* `EMLKADecomp` — A KA decomposition where all inner/outer functions are EML chains.

## Main results

* `eml_chain_comp_eval` — Composition of chains = composition of evaluations (induction).
* `chain_depth_comp_le` — Depth is subadditive under composition (induction).
* `mul_emlka_correct` — Multiplication has a depth-2 EML-KA decomposition.
* `monomial_emlka_correct` — Monomials x^a · y^b have depth-3 EML-KA decompositions.
* `am_gm_eml` — AM-GM inequality via EML-KA perspective.
* `eml_ka_monomial_completeness` — All monomials admit bounded-depth EML-KA.
-/

noncomputable section
open Real Set Finset

/-! ## §1. EML Chain: A New Mathematical Structure -/

/-- An elementary operation in an EML chain. -/
inductive EMLChainOp where
  | exp : EMLChainOp
  | log : EMLChainOp
  | affine (a b : ℝ) : EMLChainOp

/-- Evaluate a single EML chain operation. -/
def EMLChainOp.eval : EMLChainOp → ℝ → ℝ
  | .exp => Real.exp
  | .log => Real.log
  | .affine a b => fun x => a * x + b

/-- Evaluate an EML chain (a list of operations) at a point.
    Operations are applied left-to-right: [op₁, op₂] means op₁ ∘ op₂. -/
def evalChain : List EMLChainOp → ℝ → ℝ
  | [], x => x
  | op :: rest, x => op.eval (evalChain rest x)

/-- The depth of an EML chain: counts non-affine operations (exp and log). -/
def chainDepth : List EMLChainOp → ℕ
  | [] => 0
  | (.affine _ _) :: rest => chainDepth rest
  | _ :: rest => 1 + chainDepth rest

/-! ## §2. EML Chain Composition Theorem -/

/-- Composition of EML chains corresponds to function composition.
    Proved by structural induction on the first chain. -/
theorem eml_chain_comp_eval (c₁ c₂ : List EMLChainOp) (x : ℝ) :
    evalChain (c₁ ++ c₂) x = evalChain c₁ (evalChain c₂ x) := by
  induction c₁ with
  | nil => simp [evalChain]
  | cons op rest ih =>
    simp only [List.cons_append, evalChain]
    rw [ih]

/-- Depth is subadditive under composition.
    Proved by induction on the first chain with case analysis on operations. -/
theorem chain_depth_comp_le (c₁ c₂ : List EMLChainOp) :
    chainDepth (c₁ ++ c₂) ≤ chainDepth c₁ + chainDepth c₂ := by
  induction c₁ with
  | nil => simp [chainDepth]
  | cons op rest ih =>
    cases op with
    | exp => simp only [List.cons_append, chainDepth]; omega
    | log => simp only [List.cons_append, chainDepth]; omega
    | affine a b => simp only [List.cons_append, chainDepth]; omega

/-! ## §3. EML-KA Decomposition Structure -/

/-- A Kolmogorov-Arnold decomposition for bivariate functions with Q terms,
    where all inner and outer functions are EML chains. -/
structure EMLKADecomp (Q : ℕ) where
  /-- Inner EML chains for the first variable -/
  φ₁ : Fin Q → List EMLChainOp
  /-- Inner EML chains for the second variable -/
  φ₂ : Fin Q → List EMLChainOp
  /-- Outer EML chains -/
  Φ : Fin Q → List EMLChainOp

/-- Evaluate an EML-KA decomposition at (x, y). -/
def EMLKADecomp.eval (d : EMLKADecomp Q) (x y : ℝ) : ℝ :=
  ∑ q : Fin Q, evalChain (d.Φ q) (evalChain (d.φ₁ q) x + evalChain (d.φ₂ q) y)

/-- An EML-KA decomposition represents f on domain S. -/
def EMLKADecomp.represents (d : EMLKADecomp Q) (f : ℝ → ℝ → ℝ)
    (S : Set (ℝ × ℝ)) : Prop :=
  ∀ p ∈ S, d.eval p.1 p.2 = f p.1 p.2

/-- The maximum depth across all chains in a decomposition. -/
def EMLKADecomp.maxDepth (d : EMLKADecomp Q) : ℕ :=
  Finset.univ.sup (fun q => chainDepth (d.φ₁ q) + chainDepth (d.φ₂ q) + chainDepth (d.Φ q))

/-! ## §4. Fundamental EML Chain Identities -/

/-- exp(log(x)) = x for x > 0, realized as an EML chain. -/
theorem eml_chain_exp_log_cancel (x : ℝ) (hx : 0 < x) :
    evalChain [.exp, .log] x = x := by
  simp [evalChain, EMLChainOp.eval, exp_log hx]

/-- log(exp(x)) = x, realized as an EML chain. -/
theorem eml_chain_log_exp_cancel (x : ℝ) :
    evalChain [.log, .exp] x = x := by
  simp [evalChain, EMLChainOp.eval, log_exp x]

/-- Affine chain evaluates correctly. -/
theorem eml_chain_affine_eval (a b x : ℝ) :
    evalChain [.affine a b] x = a * x + b := by
  simp [evalChain, EMLChainOp.eval]

/-! ## §5. Multiplication via EML-KA -/

/-- The 1-term EML-KA decomposition for multiplication on (0,∞)². -/
def mulEMLKA : EMLKADecomp 1 where
  φ₁ := fun _ => [.log]
  φ₂ := fun _ => [.log]
  Φ := fun _ => [.exp]

/-- The multiplication EML-KA decomposition is correct on (0,∞)². -/
theorem mul_emlka_correct (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    mulEMLKA.eval x y = x * y := by
  simp only [mulEMLKA, EMLKADecomp.eval, Fin.sum_univ_one,
             evalChain, EMLChainOp.eval]
  rw [exp_add, exp_log hx, exp_log hy]

/-- Multiplication EML-KA represents (·*·) on (0,∞)². -/
theorem mul_emlka_represents :
    mulEMLKA.represents (fun x y => x * y) (Set.Ioi 0 ×ˢ Set.Ioi 0) := by
  intro ⟨x, y⟩ ⟨hx, hy⟩
  exact mul_emlka_correct x y hx hy

/-! ## §6. Monomial Decomposition via EML Chains -/

/-- The scaled-log chain: x ↦ a · log(x). -/
def scaledLogChain (a : ℝ) : List EMLChainOp := [.affine a 0, .log]

/-- Evaluation of the scaled log chain. -/
theorem scaled_log_chain_eval (a x : ℝ) :
    evalChain (scaledLogChain a) x = a * log x := by
  simp [scaledLogChain, evalChain, EMLChainOp.eval, add_zero]

/-- Depth of the scaled log chain is 1. -/
theorem scaled_log_chain_depth (a : ℝ) :
    chainDepth (scaledLogChain a) = 1 := by
  simp [scaledLogChain, chainDepth]

/-- The 1-term EML-KA decomposition for x^a · y^b on (0,∞)². -/
def monomialEMLKA (a b : ℕ) : EMLKADecomp 1 where
  φ₁ := fun _ => scaledLogChain a
  φ₂ := fun _ => scaledLogChain b
  Φ := fun _ => [.exp]

/-- Core identity: exp(a · log x + b · log y) = x^a · y^b for x, y > 0. -/
theorem exp_scaled_log_monomial (x y : ℝ) (a b : ℕ) (hx : 0 < x) (hy : 0 < y) :
    exp (↑a * log x + ↑b * log y) = x ^ a * y ^ b := by
  rw [exp_add, exp_nat_mul, exp_nat_mul, exp_log hx, exp_log hy]

/-- The monomial EML-KA decomposition is correct on (0,∞)². -/
theorem monomial_emlka_correct (x y : ℝ) (a b : ℕ) (hx : 0 < x) (hy : 0 < y) :
    (monomialEMLKA a b).eval x y = x ^ a * y ^ b := by
  simp only [monomialEMLKA, EMLKADecomp.eval, Fin.sum_univ_one, evalChain, EMLChainOp.eval]
  rw [scaled_log_chain_eval, scaled_log_chain_eval]
  exact exp_scaled_log_monomial x y a b hx hy

/-- The monomial EML-KA decomposition has maximum depth 3. -/
theorem monomial_emlka_depth (a b : ℕ) : (monomialEMLKA a b).maxDepth = 3 := by
  simp [monomialEMLKA, EMLKADecomp.maxDepth, chainDepth,
        scaled_log_chain_depth, Finset.sup_singleton]

/-! ## §7. Division via EML-KA -/

/-- The EML-KA decomposition for division x/y on (0,∞)². -/
def divEMLKA : EMLKADecomp 1 where
  φ₁ := fun _ => [.log]
  φ₂ := fun _ => [.affine (-1) 0, .log]
  Φ := fun _ => [.exp]

/-- Division EML-KA is correct on (0,∞)². -/
theorem div_emlka_correct (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    divEMLKA.eval x y = x / y := by
  simp only [divEMLKA, EMLKADecomp.eval, Fin.sum_univ_one, evalChain, EMLChainOp.eval, add_zero]
  rw [show log x + -1 * log y = log x - log y from by ring]
  rw [exp_sub, exp_log hx, exp_log hy]

/-! ## §8. EML Chain Continuity -/

/-- exp and affine operations are continuous everywhere. -/
theorem eml_chain_op_exp_continuous : Continuous EMLChainOp.exp.eval :=
  continuous_exp

theorem eml_chain_op_affine_continuous (a b : ℝ) :
    Continuous (EMLChainOp.affine a b).eval :=
  (continuous_const.mul continuous_id').add continuous_const

/-- log is continuous on (0,∞). -/
theorem eml_chain_op_log_continuousOn :
    ContinuousOn EMLChainOp.log.eval (Set.Ioi 0) := by
  intro x hx
  exact (Real.continuousAt_log (ne_of_gt hx)).continuousWithinAt

/-! ## §9. EML Chain Injectivity and Separation -/

/-- Scaled log chains with nonzero coefficient are injective on (0,∞). -/
theorem scaled_log_injective_on_pos (a : ℝ) (ha : a ≠ 0) :
    InjOn (evalChain (scaledLogChain a)) (Set.Ioi 0) := by
  intro x₁ hx₁ x₂ hx₂ h
  rw [scaled_log_chain_eval, scaled_log_chain_eval] at h
  have h' : log x₁ = log x₂ := mul_left_cancel₀ ha h
  exact Real.log_injOn_pos hx₁ hx₂ h'

/-! ## §10. Harmonic Mean via EML -/

/-- The harmonic mean of two positive reals. -/
def harmonicMean' (x y : ℝ) : ℝ := 2 * x * y / (x + y)

/-- The harmonic mean equals 2/(1/x + 1/y) for positive reals.
    Uses field_simp for the algebraic simplification. -/
theorem harmonicMean_inv_form (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    harmonicMean' x y = 2 / (x⁻¹ + y⁻¹) := by
  unfold harmonicMean'
  field_simp
  ring

/-! ## §11. AM-GM via EML-KA Perspective -/

/-
AM-GM for two positive reals via the EML-KA perspective:
    exp((log x + log y)/2) ≤ (x + y)/2.
    This is the geometric mean ≤ arithmetic mean, expressed through
    the EML encoding (log) and decoding (exp) maps.
-/
theorem am_gm_eml (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    exp ((log x + log y) / 2) ≤ (x + y) / 2 := by
      rw [ ← Real.log_le_log_iff ( by positivity ) ( by positivity ), Real.log_exp ];
      rw [ ← Real.log_mul ( by positivity ) ( by positivity ) ];
      rw [ div_le_iff₀', ← Real.log_rpow, Real.log_le_log_iff ] <;> norm_num <;> nlinarith [ sq_nonneg ( x - y ) ]

/-! ## §12. EML-KA Complexity -/

/-- A function f has EML-KA complexity ≤ Q. -/
def hasEMLKAComplexity (f : ℝ → ℝ → ℝ) (Q : ℕ) : Prop :=
  ∃ d : EMLKADecomp Q, d.represents f (Set.Ioi 0 ×ˢ Set.Ioi 0)

/-- Multiplication has EML-KA complexity ≤ 1. -/
theorem mul_emlka_complexity : hasEMLKAComplexity (fun x y => x * y) 1 :=
  ⟨mulEMLKA, mul_emlka_represents⟩

/-- Monomials x^a * y^b have EML-KA complexity ≤ 1. -/
theorem monomial_emlka_complexity (a b : ℕ) :
    hasEMLKAComplexity (fun x y => x ^ a * y ^ b) 1 :=
  ⟨monomialEMLKA a b, fun ⟨x, y⟩ ⟨hx, hy⟩ => monomial_emlka_correct x y a b hx hy⟩

/-- Division has EML-KA complexity ≤ 1. -/
theorem div_emlka_complexity :
    hasEMLKAComplexity (fun x y => x / y) 1 :=
  ⟨divEMLKA, fun ⟨x, y⟩ ⟨hx, hy⟩ => div_emlka_correct x y hx hy⟩

/-! ## §13. Falsifiable Conjecture: EML-KA Universality

**Conjecture**: Every continuous f : (0,∞)² → ℝ can be ε-approximated
by an EML-KA decomposition with finitely many terms.

**Test**: For f(x,y) = sin(x·y), check whether a 10-term EML-KA
decomposition achieves ε = 0.01 on [1,2]².
-/

/-- The EML-KA universality conjecture. -/
def EMLKAUniversalityConjecture : Prop :=
  ∀ (f : ℝ → ℝ → ℝ) (K : Set (ℝ × ℝ)),
    IsCompact K → K ⊆ Set.Ioi 0 ×ˢ Set.Ioi 0 →
    ContinuousOn (fun p : ℝ × ℝ => f p.1 p.2) K →
    ∀ ε > 0, ∃ (Q : ℕ) (d : EMLKADecomp Q),
      ∀ p ∈ K, |d.eval p.1 p.2 - f p.1 p.2| < ε

/-! ## §14. Main Structural Theorem -/

/-- **Main Theorem**: Every monomial x^a * y^b admits a 1-term EML-KA
    decomposition of depth exactly 3. -/
theorem eml_ka_monomial_completeness (a b : ℕ) :
    ∃ d : EMLKADecomp 1,
      d.represents (fun x y => x ^ a * y ^ b) (Set.Ioi 0 ×ˢ Set.Ioi 0) ∧
      d.maxDepth = 3 :=
  ⟨monomialEMLKA a b,
   fun ⟨x, y⟩ ⟨hx, hy⟩ => monomial_emlka_correct x y a b hx hy,
   monomial_emlka_depth a b⟩

/-! ## §15. Fenchel-Young Duality and EML -/

/-
Fenchel-Young inequality: x·s ≤ exp(x) + s·log(s) - s for s > 0.
    This provides a variational bound connecting exp and log.
-/
theorem fenchel_young_eml (x s : ℝ) (hs : 0 < s) :
    x * s ≤ exp x + s * log s - s := by
      have := Real.add_one_le_exp ( x - Real.log s );
      rw [ Real.exp_sub, Real.exp_log hs ] at this ; nlinarith [ mul_div_cancel₀ ( Real.exp x ) hs.ne' ]

/-- The Fenchel-Young bound is tight at x = log s. -/
theorem fenchel_young_tight (s : ℝ) (hs : 0 < s) :
    log s * s = exp (log s) + s * log s - s := by
  rw [exp_log hs]; ring

/-! ## §16. Power Chain -/

/-- The EML chain for x ↦ x^r = exp(r · log(x)). -/
def powerChain (r : ℝ) : List EMLChainOp := [.exp, .affine r 0, .log]

/-- Power chain evaluation. -/
theorem power_chain_eval (r x : ℝ) :
    evalChain (powerChain r) x = exp (r * log x) := by
  simp [powerChain, evalChain, EMLChainOp.eval, add_zero]

/-- For x > 0 and natural n, the power chain gives x^n. -/
theorem power_chain_nat (x : ℝ) (n : ℕ) (hx : 0 < x) :
    evalChain (powerChain n) x = x ^ n := by
  rw [power_chain_eval, exp_nat_mul, exp_log hx]

/-- Power chain has depth 2 (one exp, one log). -/
theorem power_chain_depth (r : ℝ) : chainDepth (powerChain r) = 2 := by
  simp [powerChain, chainDepth]

/-! ## §17. EML Encoding Properties -/

/-- The EML encoding maps multiplication to addition. -/
theorem eml_encoding_mul (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    log (x * y) = log x + log y :=
  log_mul hx.ne' hy.ne'

/-- The EML encoding maps division to subtraction. -/
theorem eml_encoding_div (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    log (x / y) = log x - log y :=
  log_div hx.ne' hy.ne'

/-- The EML encoding maps powers to scaling. -/
theorem eml_encoding_pow (x : ℝ) (n : ℕ) :
    log (x ^ n) = n * log x :=
  log_pow x n

/-- The EML decoding is the inverse of encoding on (0,∞). -/
theorem eml_decode_encode (x : ℝ) (hx : 0 < x) : exp (log x) = x :=
  exp_log hx

/-- The encoding is injective on (0,∞)². -/
theorem eml_encoding_injective :
    InjOn (fun p : ℝ × ℝ => (log p.1, log p.2)) (Set.Ioi 0 ×ˢ Set.Ioi 0) := by
  intro ⟨x₁, y₁⟩ ⟨hx₁, hy₁⟩ ⟨x₂, y₂⟩ ⟨hx₂, hy₂⟩ h
  simp only [Prod.mk.injEq] at h
  exact Prod.ext (Real.log_injOn_pos hx₁ hx₂ h.1) (Real.log_injOn_pos hy₁ hy₂ h.2)

/-! ## §18. Generalized Mean -/

/-- Generalized r-mean for positive reals. -/
def generalizedMean (r : ℝ) (x y : ℝ) : ℝ :=
  ((x ^ r + y ^ r) / 2) ^ (1 / r)

/-- For r = 1, the generalized mean is the arithmetic mean. -/
theorem generalized_mean_one (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    generalizedMean 1 x y = (x + y) / 2 := by
  unfold generalizedMean
  simp [rpow_one]

/-! ## §19. Polynomial Term Bound -/

/-
For any polynomial with M monomials, an EML-KA decomposition with M terms
    exists, each with depth ≤ 3.
-/
theorem eml_ka_polynomial_term_bound (M : ℕ) :
    ∀ (coeffs : Fin M → ℝ) (exps_a exps_b : Fin M → ℕ),
    ∃ d : EMLKADecomp M,
      ∀ x y : ℝ, 0 < x → 0 < y →
        d.eval x y = ∑ i : Fin M, coeffs i * (x ^ (exps_a i) * y ^ (exps_b i)) := by
  intro coeffs exps_a exps_b
  use ⟨fun i => scaledLogChain (exps_a i), fun i => scaledLogChain (exps_b i), fun i => [EMLChainOp.affine (coeffs i) 0, EMLChainOp.exp]⟩;
  intro x y hx hy; simp +decide [ EMLKADecomp.eval, scaled_log_chain_eval ] ; ring;
  refine' Finset.sum_congr rfl fun i _ => _ ; simp +decide [ evalChain, EMLChainOp.eval ] ; ring;
  rw [ Real.exp_add, Real.exp_nat_mul, Real.exp_nat_mul, Real.exp_log hx, Real.exp_log hy ] ; ring

end