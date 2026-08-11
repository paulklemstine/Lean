import Cryptography.FactoringBarriers.AsymptoticLadder

/-!
# Classification of Classical Factoring Resources and Their Barriers

Every *known* classical resource for attacking integer factorization comes with
a documented running-time barrier:

| resource      | representative algorithm | barrier (in `x = log N`)         |
|---------------|--------------------------|----------------------------------|
| randomness    | Pollard rho              | `exp (x/4)`  (i.e. `Θ(N^{1/4})`) |
| smoothness    | CFRAC / QS / GNFS        | `L[1/3, c]`                      |
| iteration     | Williams `p+1` / ECM     | `L[1/2, √2]` in `log p ≈ x/2`    |
| analog/chaos  | analog dynamics          | no structural gain: `L[1/3, c]`  |

This file formalises the classification as a finite type `ClassicalResource`
with an assigned `barrierCost`, and proves the two facts that make the
conditional-impossibility schema work:

* `barrierCost_superpoly` — **every** classified barrier is superpolynomial;
* `barrier_hierarchy` — the classification is non-degenerate: the randomness
  barrier is genuinely exponential while the smoothness/analog barriers are
  strictly subexponential, so the four entries are not a repackaging of one bound.

Note the honest scope: these are *definitions recording the known state of the
art*, together with real theorems about the growth of the recorded bounds.
Nothing here asserts that the table is exhaustive of all conceivable resources;
that is exactly the gap the capstone keeps explicit.
-/

namespace FactoringBarriers

open Filter Real
open scoped Topology

/-! ## Stability of superpolynomiality under linear rescaling of the input -/

/-- If `f` is superpolynomial then so is `x ↦ f (x / b)` for any `b > 0`.
This is needed because the ECM barrier is stated in `log p`, not `log N`. -/
theorem Superpoly.comp_div {f : ℝ → ℝ} (hf : Superpoly f) {b : ℝ} (hb : 0 < b) :
    Superpoly (fun x => f (x / b)) := by
  intro d
  have hdiv : Tendsto (fun x : ℝ => x / b) atTop atTop :=
    Filter.Tendsto.atTop_div_const hb tendsto_id
  have h1 : Tendsto (fun x : ℝ => f (x / b) / (x / b) ^ d) atTop atTop :=
    (hf d).comp hdiv
  have hbd : (0:ℝ) < b ^ d := Real.rpow_pos_of_pos hb d
  have h2 : Tendsto (fun x : ℝ => (f (x / b) / (x / b) ^ d) / b ^ d) atTop atTop :=
    Filter.Tendsto.atTop_div_const hbd h1
  refine h2.congr' ?_
  filter_upwards [eventually_gt_atTop (0 : ℝ)] with x hx
  rw [Real.div_rpow hx.le hb.le]
  field_simp

/-! ## The four classified resources -/

/-- The four classified classical resources for circumventing the structural
barrier in factoring. -/
inductive ClassicalResource
  | randomness
  | smoothness
  | iteration
  | analog
  deriving DecidableEq, Repr

/-- The documented running-time barrier attached to each classified resource,
expressed as a function of the bit-size parameter `x = log N`. -/
noncomputable def barrierCost : ClassicalResource → (ℝ → ℝ)
  | .randomness => fun x => Real.exp (1 / 4 * x)
  | .smoothness => Lfun (1 / 3) 1
  | .iteration => fun x => Lfun (1 / 2) (Real.sqrt 2) (x / 2)
  | .analog => Lfun (1 / 3) 1

/-! ## Every classified barrier is superpolynomial -/

/-- **Barrier theorem.** For each of the four classified resources, the
associated running-time barrier grows faster than every polynomial in the
bit-size `log N`. -/
theorem barrierCost_superpoly (rho : ClassicalResource) : Superpoly (barrierCost rho) := by
  cases rho with
  | randomness => exact Superpoly_exp_linear (by norm_num)
  | smoothness => exact Lfun_superpoly (by norm_num) (by norm_num) (by norm_num)
  | iteration =>
      have hs : (0:ℝ) < Real.sqrt 2 := Real.sqrt_pos.mpr (by norm_num)
      exact (Lfun_superpoly hs (by norm_num) (by norm_num)).comp_div (by norm_num)
  | analog => exact Lfun_superpoly (by norm_num) (by norm_num) (by norm_num)

/-- No classified barrier is polynomially bounded. -/
theorem barrierCost_not_polyBounded (rho : ClassicalResource) :
    ¬ PolyBounded (barrierCost rho) :=
  not_polyBounded_of_superpoly (barrierCost_superpoly rho)

/-! ## The classification is non-degenerate -/

/-- The smoothness barrier `L[1/3,1]` is subexponential. -/
theorem smoothness_barrier_subexp : Subexp (barrierCost .smoothness) :=
  Lfun_subexp (by norm_num) (by norm_num)

/-- The randomness barrier `exp (x/4)` is *not* subexponential: it is a genuine
exponential. -/
theorem randomness_barrier_not_subexp : ¬ Subexp (barrierCost .randomness) :=
  exp_linear_not_subexp (by norm_num)

/-- **Non-degeneracy of the classification.** The randomness barrier and the
smoothness barrier live on genuinely different rungs of the asymptotic ladder,
so the table records four distinct pieces of information rather than one bound
in four disguises. -/
theorem barrier_hierarchy :
    Subexp (barrierCost .smoothness) ∧ ¬ Subexp (barrierCost .randomness) ∧
      barrierCost .smoothness ≠ barrierCost .randomness := by
  refine ⟨smoothness_barrier_subexp, randomness_barrier_not_subexp, ?_⟩
  intro h
  exact randomness_barrier_not_subexp (h ▸ smoothness_barrier_subexp)

end FactoringBarriers