import Mathlib
import Physics.ParabolaQuasicrystal.IrrationalDensity

/-!
# Non-periodicity of awaited Wang stripe sets from irrational slopes

We model the combinatorial core of an aperiodic Wang-tile family (the
Beatty / Sturmian stripe encoding underlying the Kari–Culik construction).
The vertical stripe of slope `α` is the step sequence
`d_α(n) = ⌊(n+1)α⌋ - ⌊nα⌋ ∈ {⌊α⌋, ⌊α⌋+1}` (two vertical tile types); a row uses a
second slope `β`.  A configuration is `wangStripe α β (m,n) = (d_α m, d_β n)`.

## Main results

* `tileStep_not_periodic` : if `α` is irrational the vertical stripe word has **no**
  period — the awaited set is non-periodic in the vertical direction.
* `wangStripe_aperiodic` : if both `α` and `β` are irrational the 2-D stripe
  configuration has **no** non-zero period vector (strong aperiodicity).
* `goldenStripe_not_periodic` : instantiation at the golden slope of the attached
  catalog file `Physics.ParabolaQuasicrystal.IrrationalDensity`.

This reuses `IrrationalDensity.tileStep`, `IrrationalDensity.tileCount`,
`IrrationalDensity.tileCount_eq_floor` and `IrrationalDensity.goldenSlope_irrational`
from the attached catalog reference.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the Beatty stripe word of slope `α` is periodic **iff**
`α` is rational; hence irrational `α` ⇒ non-periodic vertical stripe, and a product
of two irrational stripes is strongly aperiodic.
Experiment (Experimenter): if the step word has period `p>0` then summing over `k`
full periods telescopes (`tileCount_eq_floor`) to `⌊(kp)α⌋ = k⌊pα⌋` for all `k`.
The two floor inequalities `ka ≤ kpα < ka+1` (with `a = ⌊pα⌋`) then squeeze
`pα = a`, an integer, so `α = a/p ∈ ℚ` — contradiction.
Analysis (Analyst): "true but the work is the multi-period block identity"
`tileCount α (k*p) = k * tileCount α p`, proved by induction using periodicity of
`tileStep` shifted by full periods.  The 2-D result is then purely structural: a
product period forces a period in each factor.
Critique (Critic): the model is the *stripe skeleton* of a Wang set, not a literal
tile-adjacency relation; this is stated honestly.  No vacuity: the hypotheses
`Irrational α/β` are satisfiable (golden slope, √2, √3) and the conclusion is a
genuine `¬ ∃ period`.
Synthesis (PI): irrationality of the density parameter is *sufficient* for
non-periodicity; the Diophantine refinement (quadratic irrationals) lives in
`WangQuadraticDiophantine.lean`.
-/

namespace WangStripe

open IrrationalDensity Filter Topology

/-
The step sequence shifted by a whole number `k` of periods is unchanged.
-/
lemma tileStep_periodic_mul (α : ℝ) (p : ℕ)
    (hper : ∀ n, tileStep α (n + p) = tileStep α n) :
    ∀ k n, tileStep α (n + k * p) = tileStep α n := by
  exact fun k n => Nat.recOn k ( by norm_num ) fun k ih => by rw [ Nat.succ_mul, ← add_assoc, hper, ih ] ;

/-
Over `k` full periods the cumulative tile count is `k` copies of one period.
-/
lemma tileCount_block (α : ℝ) (p : ℕ)
    (hper : ∀ n, tileStep α (n + p) = tileStep α n) :
    ∀ k, tileCount α (k * p) = k * tileCount α p := by
  -- Use induction on $k$ to prove the equality.
  intro k
  induction' k with k ih;
  · norm_num [ tileCount ];
  · simp_all +decide [ add_mul, tileCount ];
    rw [ Finset.sum_range_add, ih ];
    exact congrArg _ ( Finset.sum_congr rfl fun x hx => by simpa [ add_comm, mul_comm ] using tileStep_periodic_mul α p hper k x )

/-
**Non-periodicity of the vertical stripe.**  If `α` is irrational, the Beatty
step word has no period: no `p > 0` reproduces the word under shift by `p`.
-/
theorem tileStep_not_periodic (α : ℝ) (hα : Irrational α) :
    ¬ ∃ p : ℕ, 0 < p ∧ ∀ n, tileStep α (n + p) = tileStep α n := by
  intro h
  obtain ⟨p, hp_pos, hp_period⟩ := h
  have h_floor_eq : ∀ k : ℕ, ⌊((k * p : ℕ) : ℝ) * α⌋ = (k : ℤ) * ⌊((p : ℕ) : ℝ) * α⌋ := by
    intro k; have := tileCount_block α p hp_period k; simp_all +decide [ mul_comm, tileCount_eq_floor ] ;
  have h_floor_eq' : ∀ k : ℕ, k * p * α < k * ⌊p * α⌋ + 1 := by
    intro k; specialize h_floor_eq k; rw [ Int.floor_eq_iff ] at h_floor_eq; norm_num at *; linarith;
  -- By contradiction, assume $p \alpha > \lfloor p \alpha \rfloor$.
  by_cases h_gt : p * α > ⌊p * α⌋;
  · -- Choose $k$ such that $k(p\alpha - \lfloor p\alpha \rfloor) > 1$.
    obtain ⟨k, hk⟩ : ∃ k : ℕ, k * (p * α - ⌊p * α⌋) > 1 := by
      exact exists_nat_gt ( 1 / ( p * α - ⌊p * α⌋ ) ) |> fun ⟨ k, hk ⟩ => ⟨ k, by rwa [ div_lt_iff₀ ( sub_pos.mpr h_gt ) ] at hk ⟩;
    linarith [ h_floor_eq' k ];
  · exact hα.ne_rat ( ⌊ ( p : ℝ ) * α⌋ / p ) ( by push_cast; rw [ eq_div_iff ( by positivity ) ] ; linarith [ Int.floor_le ( ( p : ℝ ) * α ), Int.lt_floor_add_one ( ( p : ℝ ) * α ) ] )

/-- The 2-D stripe configuration of slopes `α` (columns) and `β` (rows). -/
noncomputable def wangStripe (α β : ℝ) (m n : ℕ) : ℤ × ℤ :=
  (tileStep α m, tileStep β n)

/-- A non-zero period vector of a 2-D configuration `W : ℕ → ℕ → X`. -/
def HasPeriod {X : Type*} (W : ℕ → ℕ → X) : Prop :=
  ∃ p q : ℕ, (p, q) ≠ (0, 0) ∧ ∀ m n, W (m + p) (n + q) = W m n

/-
**Strong aperiodicity of the awaited stripe set.**  If both density parameters
`α`, `β` are irrational, the 2-D stripe configuration has no non-zero period.
-/
theorem wangStripe_aperiodic (α β : ℝ) (hα : Irrational α) (hβ : Irrational β) :
    ¬ HasPeriod (wangStripe α β) := by
  intro h
  obtain ⟨p, q, hpq, hperiod⟩ := h;
  by_cases hp : p = 0 <;> by_cases hq : q = 0 <;> simp_all +decide [ Prod.ext_iff ];
  · exact tileStep_not_periodic β hβ ⟨ q, Nat.pos_of_ne_zero hq, fun n => by simpa using hperiod 0 n |>.2 ⟩;
  · exact tileStep_not_periodic α hα ⟨ p, Nat.pos_of_ne_zero hp, fun n => by simpa using hperiod n 0 |>.1 ⟩;
  · exact tileStep_not_periodic α hα ⟨ p, Nat.pos_of_ne_zero hp, fun n => by simpa using hperiod n 0 |>.1 ⟩

/-- Instantiation at the golden slope of the attached catalog reference. -/
theorem goldenStripe_not_periodic :
    ¬ ∃ p : ℕ, 0 < p ∧ ∀ n, tileStep goldenSlope (n + p) = tileStep goldenSlope n :=
  tileStep_not_periodic goldenSlope goldenSlope_irrational

/-- The Fibonacci (golden) × Fibonacci stripe set is strongly aperiodic. -/
theorem goldenStripe2D_aperiodic :
    ¬ HasPeriod (wangStripe goldenSlope goldenSlope) :=
  wangStripe_aperiodic _ _ goldenSlope_irrational goldenSlope_irrational

end WangStripe