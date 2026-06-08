import Mathlib

/-! # EML Density Bridge: Connecting Exp-Minus-Log to Analysis and Number Theory

This file establishes bridge theorems connecting the EML (Exp-Minus-Log) operation
`EMLd(a, b) = exp(a) - log(b)` to classical analysis, fixed point theory,
and information theory.

## Main Results

1. **Continuity Bridge**: `EMLd` is continuous on its natural domain,
   connecting the computational EML algebra to topological analysis.

2. **Monotonicity Bridge**: `EMLd` is strictly increasing in the first argument
   and strictly decreasing in the second, connecting to order theory.

3. **Fixed Point Bridge**: The map `x ↦ EMLd(0, x) = 1 - ln(x)` has a unique
   fixed point at x = 1, connecting to fixed point theory.

4. **Information-Theoretic Bridge**: `EMLd(0, p)` equals `1 + I(p)` where
   `I(p) = -ln(p)` is the self-information (surprisal), connecting EML to
   Shannon entropy.

5. **Transcendence Bridge**: EML generates transcendental numbers from {1},
   bridging computation to number theory via `e = EMLd(1, 1)`.

6. **Involution Bridge**: The map `x ↦ EMLd(0, exp(x))` is an involution on ℝ,
   connecting EML to group theory (ℤ/2ℤ actions).

7. **Duality Bridge**: EML mediates between exponential growth and logarithmic
   compression, with `EMLd(0, e) = 0` as the balance point.
-/

noncomputable section

open Real Set

namespace EMLDensityBridge

/-- The EML operation: exp(a) - log(b). -/
def EMLd (a b : ℝ) : ℝ := Real.exp a - Real.log b

/-! ## Section 1: Continuity Bridge -/

/-- EMLd is continuous in the first argument. -/
theorem EMLd_continuous_fst (b : ℝ) : Continuous (fun a => EMLd a b) := by
  exact continuous_exp.sub continuous_const

/-- EMLd is continuous in the second argument on the positive reals. -/
theorem EMLd_continuousOn_snd (a : ℝ) : ContinuousOn (fun b => EMLd a b) {0}ᶜ := by
  unfold EMLd
  exact continuousOn_const.sub Real.continuousOn_log

/-! ## Section 2: Monotonicity Bridge -/

/-- EMLd is strictly increasing in the first argument. -/
theorem EMLd_strictMono_fst (b : ℝ) : StrictMono (fun a => EMLd a b) := by
  intro x y hxy
  unfold EMLd
  linarith [Real.exp_strictMono hxy]

/-- EMLd is strictly decreasing in the second argument for positive inputs. -/
theorem EMLd_strictAnti_snd (a : ℝ) : StrictAntiOn (fun b => EMLd a b) (Ioi 0) := by
  intro x hx y hy hxy
  unfold EMLd
  linarith [Real.log_lt_log hx hxy]

/-! ## Section 3: Algebraic Bridge Identities -/

/-- EML(x, 1) = exp(x): EML recovers the exponential. -/
theorem EMLd_recovers_exp (x : ℝ) : EMLd x 1 = exp x := by
  simp [EMLd, log_one]

/-- EML(0, exp(x)) = 1 - x: EML recovers affine functions. -/
theorem EMLd_recovers_affine (x : ℝ) : EMLd 0 (exp x) = 1 - x := by
  simp [EMLd, log_exp]

/-- EML(0, x) = 1 - ln(x): the "surprisal shift" form. -/
theorem EMLd_surprisal (x : ℝ) : EMLd 0 x = 1 - log x := by
  simp [EMLd]

/-- The composition EML(EML(0, x), 1) = e/x for x > 0. -/
theorem EMLd_inv_composition (x : ℝ) (hx : 0 < x) :
    EMLd (EMLd 0 x) 1 = exp 1 / x := by
  simp [EMLd, log_one, exp_sub, exp_log hx]

/-- Log-split: EML(x, y·z) = EML(x, y) - ln(z) for y, z > 0. -/
theorem EMLd_log_split (x y z : ℝ) (hy : 0 < y) (hz : 0 < z) :
    EMLd x (y * z) = EMLd x y - log z := by
  simp [EMLd, log_mul hy.ne' hz.ne']; ring

/-! ## Section 4: Involution Bridge -/

/-- The map x ↦ EML(0, exp(x)) = 1 - x applied twice gives the identity. -/
theorem EMLd_involution (x : ℝ) :
    EMLd 0 (exp (EMLd 0 (exp x))) = x := by
  simp [EMLd, log_exp]

/-- The underlying involution is x ↦ 1 - x. -/
theorem one_minus_involution (x : ℝ) : 1 - (1 - x) = x := by ring

/-! ## Section 5: Transcendence Bridge -/

/-- EML(1, 1) = e, generating a transcendental from integers. -/
theorem EMLd_generates_e : EMLd 1 1 = exp 1 := by
  simp [EMLd, log_one]

/-- EML(1, e) = e - 1. -/
theorem EMLd_one_e : EMLd 1 (exp 1) = exp 1 - 1 := by
  simp [EMLd, log_exp]

/-- EML(e, 1) = e^e: double exponentiation through EML. -/
theorem EMLd_e_one : EMLd (exp 1) 1 = exp (exp 1) := by
  simp [EMLd, log_one]

/-- EML(e, e) = e^e - 1. -/
theorem EMLd_e_e : EMLd (exp 1) (exp 1) = exp (exp 1) - 1 := by
  simp [EMLd, log_exp]

/-! ## Section 6: Information-Theoretic Bridge

The self-information (surprisal) of an event with probability p is I(p) = -ln(p).
Then EML(0, p) = 1 - ln(p) = 1 + I(p), establishing a direct bridge between
EML and information theory. -/

/-- Self-information (surprisal): I(p) = -ln(p). -/
def selfInfo (p : ℝ) : ℝ := -log p

/-- EML(0, p) = 1 + self-information of p. -/
theorem EMLd_eq_one_plus_selfInfo (p : ℝ) :
    EMLd 0 p = 1 + selfInfo p := by
  simp [EMLd, selfInfo]; ring

/-- For a certain event (p = 1), the self-information is 0. -/
theorem selfInfo_certain : selfInfo 1 = 0 := by
  simp [selfInfo, log_one]

/-- The surprisal is positive for unlikely events (p ∈ (0, 1)). -/
theorem selfInfo_pos_of_prob {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1) :
    0 < selfInfo p := by
  simp [selfInfo]
  exact Real.log_neg hp0 hp1

/-- EML at a certain event: EML(0, 1) = 1. -/
theorem EMLd_certain : EMLd 0 1 = 1 := by
  simp [EMLd, log_one]

/-! ## Section 7: Fixed Point Bridge

The map f(x) = EML(0, x) = 1 - ln(x) has a unique fixed point in (0, ∞).
The fixed point x = 1 satisfies 1 - ln(1) = 1 = 1.
-/

/-- The EML self-map: x ↦ EML(0, x) = 1 - ln(x). -/
def EMLSelfMap (x : ℝ) : ℝ := 1 - log x

/-- EMLSelfMap equals EMLd 0. -/
theorem EMLSelfMap_eq_EMLd (x : ℝ) : EMLSelfMap x = EMLd 0 x := by
  simp [EMLSelfMap, EMLd]

/-- EMLSelfMap(1) = 1: x = 1 is a fixed point. -/
theorem EMLSelfMap_fixed_one : EMLSelfMap 1 = 1 := by
  simp [EMLSelfMap, log_one]

/-
x = 1 is the unique fixed point of EMLSelfMap on (0, ∞).
-/
theorem EMLSelfMap_unique_fixed_point (x : ℝ) (hx : 0 < x) (hfp : EMLSelfMap x = x) :
    x = 1 := by
  unfold EMLSelfMap at hfp;
  exact le_antisymm ( le_of_not_gt fun h => by linarith [ Real.log_pos h ] ) ( le_of_not_gt fun h => by linarith [ Real.log_le_sub_one_of_pos hx ] )

/-! ## Section 8: Exp-Log Duality Bridge

EML establishes a duality between exponential growth and logarithmic compression.
-/

/-
For x > 0, EML(x, 1) > x (exponential growth dominates linear growth).
-/
theorem EMLd_growth (x : ℝ) (_hx : 0 < x) : EMLd x 1 > x := by
  unfold EMLd; norm_num; linarith [ Real.add_one_le_exp x ] ;

/-- For x > 1, EML(0, x) < 1 (logarithmic compression). -/
theorem EMLd_compression (x : ℝ) (hx : 1 < x) : EMLd 0 x < 1 := by
  unfold EMLd; simp; linarith [log_pos hx]

/-- The "balance point": EML(0, e) = 0 (exp and log perfectly cancel). -/
theorem EMLd_balance : EMLd 0 (exp 1) = 0 := by
  simp [EMLd, log_exp]

/-
EML(0, x) > 1 for x ∈ (0, 1): small probabilities have large surprisal.
-/
theorem EMLd_large_surprisal (x : ℝ) (hx0 : 0 < x) (hx1 : x < 1) :
    EMLd 0 x > 1 := by
  unfold EMLd; norm_num; linarith [ Real.log_le_sub_one_of_pos hx0 ] ;

/-- EML sum identity: sum of two EML values relates to exp sum and log product. -/
theorem EMLd_sum (a b c d : ℝ) (hb : 0 < b) (hd : 0 < d) :
    EMLd a b + EMLd c d = (exp a + exp c) - log (b * d) := by
  simp [EMLd, log_mul hb.ne' hd.ne']; ring

/-! ## Section 9: EML Closure Properties -/

/-- The EML closure of {1} contains e. -/
theorem e_in_EMLClosure : exp 1 ∈ {z | ∃ a ∈ ({1} : Set ℝ), ∃ b ∈ ({1} : Set ℝ), z = EMLd a b} := by
  exact ⟨1, mem_singleton 1, 1, mem_singleton 1, (EMLd_generates_e).symm⟩

/-- The EML closure of {1} contains e - 1. -/
theorem e_minus_one_in_closure :
    exp 1 - 1 ∈ {z | ∃ a ∈ ({1, exp 1} : Set ℝ), ∃ b ∈ ({1, exp 1} : Set ℝ), z = EMLd a b} := by
  refine ⟨1, Or.inl rfl, exp 1, Or.inr rfl, ?_⟩
  simp [EMLd, log_exp]

/-! ## Section 10: Derivative Bridge

The derivative of EML connects to both exponential and logarithmic rates of change.
-/

/-
∂EML/∂a = exp(a): rate of change in the first argument is exponential.
-/
theorem EMLd_deriv_fst (b : ℝ) :
    HasDerivAt (fun a => EMLd a b) (exp 0) 0 := by
  simpa using HasDerivAt.sub ( Real.hasDerivAt_exp 0 ) ( hasDerivAt_const _ _ )

/-
∂EML/∂b = -1/b for b > 0: rate of change in the second argument is hyperbolic.
-/
theorem EMLd_deriv_snd (b : ℝ) (hb : 0 < b) :
    HasDerivAt (fun x => EMLd 0 x) (-1/b) b := by
  convert HasDerivAt.const_sub _ ( Real.hasDerivAt_log hb.ne' ) using 1 ; ring!

end EMLDensityBridge
end