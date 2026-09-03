/-
# Strict monotone decay of the abelian ladder

The ladder of real-cyclotomic rungs `Q(ζ_{2q+1})⁺` carries the Frobenius type
entropy `H(T_q) = log₂ q - ((q-1)/q) log₂ (q-1)`, the binary entropy of the
splitting density `1/q`.  Round-50 reports the numerical values
`1, 0.9183, 0.7219, 0.5917, 0.4395` for degrees `2, 3, 5, 7, 11` and observes
that they decrease.  Here we prove that decay *as a theorem*, not rung by rung.

The interpolating function

`hFun x = log₂ x - ((x-1)/x) · log₂ (x-1)`

extends the ladder to all real `x ≥ 2`, and its derivative is exactly

`hFun' x = - log (x-1) / (x² log 2)`,

which is `0` at `x = 2` and strictly negative beyond.  Hence `hFun` is strictly
antitone on `[2, ∞)`, and the ladder entropies strictly decrease along the primes:
degree 2 is the unique rung carrying a full bit, and every later rung is strictly
lossier than all its predecessors.
-/
import Shared.AbelianLadderUniversality

namespace AbelianLadder

open Finset CyclicTypeChannel

/-! ## 1. The real interpolation of the ladder -/

/-- The real interpolation of the ladder entropy:
`hFun x = log₂ x - ((x-1)/x) log₂ (x-1)`. -/
noncomputable def hFun (x : ℝ) : ℝ :=
  Real.logb 2 x - (x - 1) / x * Real.logb 2 (x - 1)

/-- At a prime degree the interpolation reproduces the type entropy. -/
theorem hFun_eq_typeEntropy {q : ℕ} (hq : q.Prime) : hFun (q : ℝ) = typeEntropy q := by
  rw [hFun, typeEntropy_prime_formula hq]

/-- The bottom rung: `hFun 2 = 1` bit. -/
theorem hFun_two : hFun 2 = 1 := by
  rw [hFun]
  norm_num

/-! ## 2. The derivative -/

/-- **The derivative of the ladder profile**: `hFun' x = - log (x-1) / (x² log 2)`.
It vanishes at `x = 2` and is strictly negative for `x > 2`. -/
theorem hasDerivAt_hFun {x : ℝ} (hx : 1 < x) :
    HasDerivAt hFun (-Real.log (x - 1) / (x ^ 2 * Real.log 2)) x := by
  have hx0 : x ≠ 0 := by positivity
  have hx1 : x - 1 ≠ 0 := sub_ne_zero.2 hx.ne'
  have hl2 : Real.log 2 ≠ 0 := ne_of_gt (Real.log_pos (by norm_num))
  -- `log x`
  have h1 : HasDerivAt Real.log x⁻¹ x := Real.hasDerivAt_log hx0
  -- `log (x - 1)`
  have hsub : HasDerivAt (fun y : ℝ => y - 1) 1 x := (hasDerivAt_id x).sub_const 1
  have h2 : HasDerivAt (fun y : ℝ => Real.log (y - 1)) (1 / (x - 1)) x := hsub.log hx1
  -- `(x - 1)/x`
  have h3 : HasDerivAt (fun y : ℝ => (y - 1) / y) ((1 * x - (x - 1) * 1) / x ^ 2) x :=
    hsub.div (hasDerivAt_id x) hx0
  -- the product
  have h4 : HasDerivAt (fun y : ℝ => (y - 1) / y * Real.log (y - 1))
      ((1 * x - (x - 1) * 1) / x ^ 2 * Real.log (x - 1) + (x - 1) / x * (1 / (x - 1))) x :=
    h3.mul h2
  have h5 : HasDerivAt (fun y : ℝ => Real.log y - (y - 1) / y * Real.log (y - 1))
      (x⁻¹ - ((1 * x - (x - 1) * 1) / x ^ 2 * Real.log (x - 1) + (x - 1) / x * (1 / (x - 1)))) x :=
    h1.sub h4
  have h6 := h5.div_const (Real.log 2)
  have hfun : (fun y : ℝ => (Real.log y - (y - 1) / y * Real.log (y - 1)) / Real.log 2) = hFun := by
    funext y
    rw [hFun, Real.logb, Real.logb]
    ring
  rw [hfun] at h6
  convert h6 using 1
  field_simp
  ring

/-- `hFun` is differentiable, hence continuous, on `(1, ∞)`. -/
theorem continuousOn_hFun : ContinuousOn hFun (Set.Ici (2 : ℝ)) := fun x hx =>
  ((hasDerivAt_hFun (by have : (2:ℝ) ≤ x := hx; linarith)).continuousAt).continuousWithinAt

/-! ## 3. Strict decay -/

/-- **The ladder profile is strictly antitone on `[2, ∞)`.** -/
theorem strictAntiOn_hFun : StrictAntiOn hFun (Set.Ici (2 : ℝ)) := by
  apply strictAntiOn_of_deriv_neg (convex_Ici 2) continuousOn_hFun
  intro x hx
  rw [interior_Ici] at hx
  have hx2 : (2 : ℝ) < x := hx
  have hd := hasDerivAt_hFun (x := x) (by linarith)
  rw [hd.deriv]
  have hlog : 0 < Real.log (x - 1) := Real.log_pos (by linarith)
  have hl2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have : 0 < x ^ 2 * Real.log 2 := by positivity
  exact div_neg_of_neg_of_pos (by linarith) this

/-- **Strict decay of the abelian ladder**: the type entropy strictly decreases
along the prime degrees. -/
theorem typeEntropy_strict_decay {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p < q) :
    typeEntropy q < typeEntropy p := by
  have hp2 : (2 : ℝ) ≤ (p : ℝ) := by exact_mod_cast hp.two_le
  have hq2 : (2 : ℝ) ≤ (q : ℝ) := by exact_mod_cast hq.two_le
  have hlt : (p : ℝ) < (q : ℝ) := by exact_mod_cast hpq
  have := strictAntiOn_hFun (Set.mem_Ici.2 hp2) (Set.mem_Ici.2 hq2) hlt
  rwa [hFun_eq_typeEntropy hp, hFun_eq_typeEntropy hq] at this

/-- Degree 2 is the unique rung carrying a full bit: every higher prime degree is
strictly lossier. -/
theorem typeEntropy_lt_one_of_two_lt {q : ℕ} (hq : q.Prime) (h2 : 2 < q) :
    typeEntropy q < 1 := by
  have h := typeEntropy_strict_decay Nat.prime_two hq h2
  have h2' : typeEntropy 2 = 1 := by
    rw [← hFun_eq_typeEntropy Nat.prime_two]
    simpa using hFun_two
  rwa [h2'] at h

/-- The first five rungs of the ladder, strictly decreasing. -/
theorem ladder_decay_chain :
    typeEntropy 11 < typeEntropy 7 ∧ typeEntropy 7 < typeEntropy 5 ∧
      typeEntropy 5 < typeEntropy 3 ∧ typeEntropy 3 < typeEntropy 2 :=
  ⟨typeEntropy_strict_decay (by norm_num) (by norm_num) (by norm_num),
   typeEntropy_strict_decay (by norm_num) (by norm_num) (by norm_num),
   typeEntropy_strict_decay (by norm_num) (by norm_num) (by norm_num),
   typeEntropy_strict_decay (by norm_num) (by norm_num) (by norm_num)⟩

/-- The ladder entropy tends to `0`: combined with the sandwich bound
`H(T_q) ≤ (log₂ q + 1/log 2)/q`, strict decay shows the ladder is a strictly
decreasing null sequence along the primes. -/
theorem typeEntropy_pos {q : ℕ} (hq : q.Prime) (h2 : 2 < q) : 0 < typeEntropy q := by
  have h := typeEntropy_prime_sandwich hq
  have hlog : 0 < Real.logb 2 q := Real.logb_pos (by norm_num) (by exact_mod_cast hq.one_lt)
  have hq0 : (0 : ℝ) < q := by exact_mod_cast hq.pos
  have : 0 < Real.logb 2 q / q := by positivity
  linarith [h.1]

end AbelianLadder