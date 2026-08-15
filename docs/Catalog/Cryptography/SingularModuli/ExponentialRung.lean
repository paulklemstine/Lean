import Cryptography.SingularModuli.SqrtBarrier
import Cryptography.FactoringBarriers.Capstone

/-!
# Singular Moduli Factoring, Step 4: which rung of the ladder it occupies

`SqrtBarrier.lean` proves that the expected number of evaluations of the
singular moduli method on a balanced semiprime is at least `√N / (4h)`.  In the
bit-size variable `x = log N` this is the cost function

  `smCost h x = exp (x / 2) / (4 h)`.

This file places that function on the asymptotic ladder of
`FactoringBarriers.AsymptoticLadder`:

* `smCost_superpoly`      — it is superpolynomial (no polynomial time);
* `smCost_not_subexp`     — it is a *genuine exponential*, unlike the
  smoothness/sieve barrier `L[1/3,1]`;
* `smCost_dominates_randomness` — it eventually dominates the Pollard rho
  barrier `exp (x/4)`, so singular moduli is asymptotically at least as
  expensive as rho;
* `singularModuliAlgorithm` / `singularModuli_usesClassifiedResource` — the
  method fits into the existing four-resource classification (its barrier is the
  randomness/collision rung), and therefore
* `singularModuli_not_polyTime` — its cost profile is not polynomially bounded.

Together with `Cryptography/FactoringBarriers/ResourceClassification.lean`, this
is the precise sense of the paper's claim: singular moduli factoring joins
Pollard rho and Pollard `p-1` in the `√N` family, strictly above the sieve rung.
-/

namespace SingularModuli

open Filter Real FactoringBarriers
open scoped Topology

/-! ## Two stability lemmas for the growth classes -/

/-- Superpolynomiality is preserved by dividing by a positive constant. -/
theorem superpoly_div_const {f : ℝ → ℝ} (hf : Superpoly f) {c : ℝ} (hc : 0 < c) :
    Superpoly (fun x => f x / c) := by
  intro d
  have h := (hf d).atTop_div_const hc
  refine h.congr (fun x => ?_)
  rw [div_div, div_div, mul_comm]

/-- Subexponentiality is preserved by multiplying by a constant. -/
theorem subexp_const_mul {f : ℝ → ℝ} (hf : Subexp f) (c : ℝ) :
    Subexp (fun x => c * f x) := by
  intro ε hε
  have h := (hf ε hε).const_mul c
  rw [mul_zero] at h
  refine h.congr (fun x => ?_)
  rw [mul_div_assoc]

/-! ## The singular moduli cost function -/

/-- The proven lower bound on the expected cost of the singular moduli method for
a balanced semiprime, in the bit-size variable `x = log N`:
`√N / (4h) = exp (x/2) / (4h)`. -/
noncomputable def smCost (h : ℝ) (x : ℝ) : ℝ := Real.exp (x / 2) / (4 * h)

variable {h : ℝ}

/-- The singular moduli cost is superpolynomial: the method cannot run in
polynomial time in the bit-size. -/
theorem smCost_superpoly (hh : 0 < h) : Superpoly (smCost h) := by
  have hbase : Superpoly (fun x : ℝ => Real.exp (1 / 2 * x)) :=
    Superpoly_exp_linear (by norm_num)
  have hdiv := superpoly_div_const hbase (by positivity : (0:ℝ) < 4 * h)
  have heq : (fun x : ℝ => Real.exp (1 / 2 * x) / (4 * h)) = smCost h := by
    funext x
    rw [smCost, show (1:ℝ) / 2 * x = x / 2 by ring]
  rwa [heq] at hdiv

/-- The singular moduli cost is a *genuine* exponential: it is not
subexponential, so it does not reach the sieve rung `L[1/3, c]`. -/
theorem smCost_not_subexp (hh : 0 < h) : ¬ Subexp (smCost h) := by
  intro hsub
  have hmul := subexp_const_mul hsub (4 * h)
  have heq : (fun x => (4 * h) * smCost h x) = fun x => Real.exp (1 / 2 * x) := by
    funext x
    rw [smCost, mul_div_cancel₀ _ (by positivity : (4 : ℝ) * h ≠ 0),
      show (1:ℝ) / 2 * x = x / 2 by ring]
  rw [heq] at hmul
  exact exp_linear_not_subexp (by norm_num) hmul

/-- Consequently the cost profile is not polynomially bounded. -/
theorem smCost_not_polyBounded (hh : 0 < h) : ¬ PolyBounded (smCost h) :=
  not_polyBounded_of_superpoly (smCost_superpoly hh)

/-- **Singular moduli is asymptotically at least as expensive as Pollard rho.**
Eventually `exp (x/4) ≤ exp (x/2) / (4h)`: the proven `√N/(4h)` bound dominates
the `N^{1/4}` birthday bound of the collision methods. -/
theorem smCost_dominates_randomness (hh : 0 < h) :
    ∀ᶠ x in atTop, barrierCost .randomness x ≤ smCost h x := by
  have hexp : Tendsto (fun x : ℝ => Real.exp (x / 4)) atTop atTop :=
    Real.tendsto_exp_atTop.comp (tendsto_id.atTop_div_const (by norm_num))
  filter_upwards [hexp.eventually_ge_atTop (4 * h)] with x hx
  have h4 : (0:ℝ) < 4 * h := by positivity
  have hsplit : Real.exp (x / 2) = Real.exp (x / 4) * Real.exp (x / 4) := by
    rw [← Real.exp_add]; ring_nf
  show Real.exp (1 / 4 * x) ≤ Real.exp (x / 2) / (4 * h)
  rw [le_div_iff₀ h4, hsplit, show (1:ℝ) / 4 * x = x / 4 by ring]
  exact mul_le_mul_of_nonneg_left hx (Real.exp_pos _).le

/-- **Ladder placement.** The singular moduli barrier is exponential while the
sieve barrier is subexponential: the two live on different rungs, and singular
moduli is on the worse one. -/
theorem smCost_above_sieve (hh : 0 < h) :
    Subexp (barrierCost .smoothness) ∧ ¬ Subexp (smCost h) :=
  ⟨smoothness_barrier_subexp, smCost_not_subexp hh⟩

/-! ## Fitting the method into the four-resource classification -/

/-- The singular moduli method, abstracted to its proven cost profile. -/
noncomputable def singularModuliAlgorithm (hh : 0 < h) : ClassicalAlgorithm where
  cost := smCost h
  one_le_cost := by
    have hexp : Tendsto (fun x : ℝ => Real.exp (x / 4)) atTop atTop :=
      Real.tendsto_exp_atTop.comp (tendsto_id.atTop_div_const (by norm_num))
    filter_upwards [smCost_dominates_randomness hh,
      hexp.eventually_ge_atTop (1 : ℝ)] with x hx hx1
    have : (1:ℝ) ≤ barrierCost .randomness x := by
      show (1:ℝ) ≤ Real.exp (1 / 4 * x)
      rw [show (1:ℝ) / 4 * x = x / 4 by ring]
      exact hx1
    linarith

/-- The method is limited by the randomness/collision barrier: its proven cost
dominates `exp (x/4)`.  So it is *inside* the classified resource set of the
capstone framework — it is not a new resource. -/
theorem singularModuli_limitedBy_randomness (hh : 0 < h) :
    LimitedBy (singularModuliAlgorithm hh) ClassicalResource.randomness :=
  smCost_dominates_randomness hh

/-- Hence the singular moduli method uses a classified resource. -/
theorem singularModuli_usesClassifiedResource (hh : 0 < h) :
    UsesClassifiedResource (singularModuliAlgorithm hh) :=
  ⟨ClassicalResource.randomness, singularModuli_limitedBy_randomness hh⟩

/-- **No polynomial-time singular moduli attack.** The cost profile proved in
`SqrtBarrier.lean` is not polynomially bounded, so this method cannot be a
polynomial-time factoring algorithm. -/
theorem singularModuli_not_polyTime (hh : 0 < h) :
    ¬ PolyTime (singularModuliAlgorithm hh) :=
  smCost_not_polyBounded hh

end SingularModuli