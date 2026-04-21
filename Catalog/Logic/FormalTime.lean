/-! # CatalogBuild.Logic.FormalTime

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 57
-/

import Mathlib

noncomputable section

/-- A `TemporalOrder` bundles the axioms of time as an ordered set:
linearly ordered, densely ordered, no minimum, no maximum, nonempty.
This captures the minimal order-theoretic structure of time. -/
class TemporalOrder (T : Type*) extends LinearOrder T, DenselyOrdered T,
    NoMinOrder T, NoMaxOrder T where
  [nonempty : Nonempty T]

attribute [instance] TemporalOrder.nonempty




/-- Between any two distinct real moments, there exists a rational moment.
This is the density of ℚ in ℝ — time's rational skeleton. -/
theorem rational_moment_between {t₁ t₂ : ℝ} (h : t₁ < t₂) :
    ∃ q : ℚ, t₁ < (q : ℝ) ∧ (q : ℝ) < t₂ :=
  exists_rat_btwn h




/-- Duration between two moments on the real line. -/
def duration (t₁ t₂ : ℝ) : ℝ := |t₂ - t₁|




/-- Duration is symmetric. -/
theorem duration_symm (t₁ t₂ : ℝ) : duration t₁ t₂ = duration t₂ t₁ := by
  simp [duration, abs_sub_comm]




/-- Duration is non-negative. -/
theorem duration_nonneg (t₁ t₂ : ℝ) : 0 ≤ duration t₁ t₂ :=
  abs_nonneg _




/-- Duration is zero iff the moments coincide. -/
theorem duration_eq_zero_iff (t₁ t₂ : ℝ) : duration t₁ t₂ = 0 ↔ t₁ = t₂ := by
  simp [duration, abs_eq_zero, sub_eq_zero, eq_comm]




/-- Duration satisfies the triangle inequality. -/
theorem duration_triangle (t₁ t₂ t₃ : ℝ) :
    duration t₁ t₃ ≤ duration t₁ t₂ + duration t₂ t₃ := by
  simp only [duration]
  have : t₃ - t₁ = (t₂ - t₁) + (t₃ - t₂) := by ring
  rw [this]
  exact abs_add_le (t₂ - t₁) (t₃ - t₂)




/-- **Additivity of Duration**: When b is between a and c, duration splits cleanly.
This is the fundamental property of time measurement. -/
theorem duration_additive {t₁ t₂ t₃ : ℝ} (h₁ : t₁ ≤ t₂) (h₂ : t₂ ≤ t₃) :
    duration t₁ t₃ = duration t₁ t₂ + duration t₂ t₃ := by
  simp only [duration]
  rw [abs_of_nonneg (sub_nonneg.mpr h₁), abs_of_nonneg (sub_nonneg.mpr h₂),
      abs_of_nonneg (sub_nonneg.mpr (le_trans h₁ h₂))]
  ring




/-- The rationals are countable — time has a countable skeleton. -/
theorem rationals_countable : Countable ℚ := inferInstance




/-- The rationals are dense in the reals — the skeleton is everywhere dense. -/
theorem rationals_dense_in_reals : DenseRange ((↑) : ℚ → ℝ) :=
  Rat.isDenseEmbedding_coe_real.dense




/-- A clock is a monotone (order-preserving) function from time to a display type. -/
structure Clock (T : Type*) (D : Type*) [Preorder T] [Preorder D] where
  /-- The reading function -/
  read : T → D
  /-- A clock must be monotone: later times give later readings -/
  monotone_read : Monotone read




/-- An ideal clock is an order embedding — it perfectly preserves temporal order. -/
structure IdealClock (T : Type*) (D : Type*) [Preorder T] [Preorder D] where
  /-- The embedding -/
  embed : T ↪o D




/-- Every ideal clock is a clock. -/
def IdealClock.toClock {T D : Type*} [Preorder T] [Preorder D]
    (c : IdealClock T D) : Clock T D where
  read := c.embed
  monotone_read := c.embed.monotone




/-- The identity function is an ideal clock — time reads itself perfectly. -/
def IdealClock.identity (T : Type*) [Preorder T] : IdealClock T T where
  embed := (OrderIso.refl T).toOrderEmbedding




/-- Composition of ideal clocks is an ideal clock. -/
def IdealClock.comp {T D₁ D₂ : Type*} [Preorder T] [Preorder D₁] [Preorder D₂]
    (c₂ : IdealClock D₁ D₂) (c₁ : IdealClock T D₁) : IdealClock T D₂ where
  embed := c₁.embed.trans c₂.embed




/-- A spacetime event in 1+1 dimensions (one time, one space). -/
structure Event1 where
  t : ℝ  -- time coordinate
  x : ℝ  -- space coordinate




/-- A spacetime event in 1+3 dimensions. -/
structure Event where
  t : ℝ  -- time coordinate
  x : ℝ  -- space coordinate 1
  y : ℝ  -- space coordinate 2
  z : ℝ  -- space coordinate 3




/-- The Minkowski interval (squared) between two events in 1+1D.
Negative = timelike, zero = lightlike, positive = spacelike. -/
def minkowskiInterval1 (e₁ e₂ : Event1) : ℝ :=
  -(e₂.t - e₁.t)^2 + (e₂.x - e₁.x)^2




/-- The Minkowski interval (squared) between two events in 1+3D. -/
def minkowskiInterval (e₁ e₂ : Event) : ℝ :=
  -(e₂.t - e₁.t)^2 + (e₂.x - e₁.x)^2 + (e₂.y - e₁.y)^2 + (e₂.z - e₁.z)^2




/-- Two events are **timelike separated** if the interval is negative. -/
def timelikeSeparated (e₁ e₂ : Event) : Prop :=
  minkowskiInterval e₁ e₂ < 0




/-- Two events are **lightlike separated** if the interval is zero. -/
def lightlikeSeparated (e₁ e₂ : Event) : Prop :=
  minkowskiInterval e₁ e₂ = 0




/-- Two events are **spacelike separated** if the interval is positive. -/
def spacelikeSeparated (e₁ e₂ : Event) : Prop :=
  minkowskiInterval e₁ e₂ > 0




/-- Two events are **causally connected** if timelike or lightlike separated. -/
def causallyConnected (e₁ e₂ : Event) : Prop :=
  minkowskiInterval e₁ e₂ ≤ 0




/-- The Minkowski interval is symmetric. -/
theorem minkowskiInterval_symm (e₁ e₂ : Event) :
    minkowskiInterval e₁ e₂ = minkowskiInterval e₂ e₁ := by
  simp [minkowskiInterval]; ring




/-- An event is lightlike separated from itself. -/
theorem minkowskiInterval_self (e : Event) :
    minkowskiInterval e e = 0 := by
  simp [minkowskiInterval]




/-- Every event is causally connected to itself. -/
theorem causallyConnected_self (e : Event) : causallyConnected e e := by
  simp [causallyConnected, minkowskiInterval_self]




/-- Causal connection is symmetric. -/
theorem causallyConnected_symm {e₁ e₂ : Event} :
    causallyConnected e₁ e₂ ↔ causallyConnected e₂ e₁ := by
  simp [causallyConnected, minkowskiInterval_symm]




/-- **The Light Cone Theorem** (1+1D): An event at the origin is causally connected
to event (t, x) iff |x| ≤ |t|. Light travels at speed 1. -/
theorem light_cone_characterization (t x : ℝ) :
    let e₀ : Event1 := ⟨0, 0⟩
    let e : Event1 := ⟨t, x⟩
    minkowskiInterval1 e₀ e ≤ 0 ↔ |x| ≤ |t| := by
  simp only [minkowskiInterval1, sub_zero]
  rw [show -(t)^2 + (x)^2 = x^2 - t^2 from by ring]
  rw [← sq_abs x, ← sq_abs t]
  constructor
  · intro h; nlinarith [abs_nonneg x, abs_nonneg t, sq_nonneg (|x| - |t|)]
  · intro h; nlinarith [abs_nonneg x, abs_nonneg t, sq_nonneg (|x| + |t|)]




/-- The Lorentz factor γ for velocity v (|v| < 1). -/
def lorentzGamma (v : ℝ) : ℝ := 1 / Real.sqrt (1 - v^2)




/-- Apply a Lorentz boost with velocity v to a 1+1D event. -/
def lorentzBoost (v : ℝ) (e : Event1) : Event1 where
  t := lorentzGamma v * (e.t - v * e.x)
  x := lorentzGamma v * (e.x - v * e.t)




/-- [Section: # CatalogBuild.Logic.FormalTime
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 57] -/
theorem lorentzGamma_ge_one {v : ℝ} (hv : |v| < 1) : 1 ≤ lorentzGamma v := by
  exact one_le_one_div ( Real.sqrt_pos.mpr ( by nlinarith [ abs_lt.mp hv ] ) ) ( Real.sqrt_le_iff.mpr ⟨ by nlinarith [ abs_lt.mp hv ], by nlinarith [ abs_lt.mp hv ] ⟩ )




/-- [Section: # CatalogBuild.Logic.FormalTime
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 57] -/
theorem lorentz_boost_preserves_interval {v : ℝ} (hv : v^2 < 1) (e₁ e₂ : Event1) :
    minkowskiInterval1 (lorentzBoost v e₁) (lorentzBoost v e₂) =
    minkowskiInterval1 e₁ e₂ := by
  unfold minkowskiInterval1 lorentzBoost lorentzGamma;
  grind




/-- **Time dilation**: A clock at rest measures Δt; a moving observer measures γ · Δt. -/
theorem time_dilation (v Δt : ℝ) :
    let e₂ : Event1 := ⟨Δt, 0⟩
    (lorentzBoost v e₂).t = lorentzGamma v * Δt := by
  simp [lorentzBoost, lorentzGamma]




/-- An **Arrow of Time** is a monotonically non-decreasing entropy function. -/
structure ArrowOfTime (T : Type*) [Preorder T] where
  entropy : T → ℝ
  monotone_entropy : Monotone entropy




/-- A **Strict Arrow of Time** — entropy strictly increases. -/
structure StrictArrow (T : Type*) [Preorder T] where
  entropy : T → ℝ
  strict_mono_entropy : StrictMono entropy




/-- A strict arrow is an arrow. -/
def StrictArrow.toArrow {T : Type*} [LinearOrder T] (a : StrictArrow T) : ArrowOfTime T where
  entropy := a.entropy
  monotone_entropy := a.strict_mono_entropy.monotone




/-- A strict arrow is injective — distinct moments have distinct entropies. -/
theorem StrictArrow.injective {T : Type*} [LinearOrder T] (a : StrictArrow T) :
    Injective a.entropy := a.strict_mono_entropy.injective




/-- **Time reversal breaks the arrow**: strictly increasing → time-reversed is
strictly decreasing. This formalizes why the arrow "picks a direction." -/
theorem time_reversal_breaks_strict_arrow {f : ℝ → ℝ} (hf : StrictMono f) :
    StrictAnti (f ∘ Neg.neg) := by
  intro a b hab
  simp [Function.comp]
  exact hf (neg_lt_neg hab)




/-- The identity function on ℝ is a trivial strict arrow —
"time is its own clock." -/
def trivialArrow : StrictArrow ℝ where
  entropy := id
  strict_mono_entropy := strictMono_id




/-- A discrete dynamical system: a set with a "next step" function. -/
structure DiscreteTimeDynamics (X : Type*) where
  step : X → X




/-- The state after n steps. -/
def DiscreteTimeDynamics.evolve {X : Type*} (d : DiscreteTimeDynamics X) (x : X) : ℕ → X
  | 0 => x
  | n + 1 => d.step (d.evolve x n)




/-- A point is **periodic** with period p > 0. -/
def DiscreteTimeDynamics.isPeriodic {X : Type*} (d : DiscreteTimeDynamics X)
    (x : X) (p : ℕ) : Prop :=
  0 < p ∧ d.evolve x p = x




/-- A point is a **fixed point**. -/
def DiscreteTimeDynamics.isFixedPoint {X : Type*} (d : DiscreteTimeDynamics X)
    (x : X) : Prop :=
  d.step x = x




/-- A fixed point is periodic with period 1. -/
theorem DiscreteTimeDynamics.fixedPoint_isPeriodic {X : Type*}
    (d : DiscreteTimeDynamics X) (x : X) (hx : d.isFixedPoint x) :
    d.isPeriodic x 1 := by
  refine ⟨Nat.one_pos, ?_⟩
  simp [DiscreteTimeDynamics.evolve, DiscreteTimeDynamics.isFixedPoint] at *
  exact hx




theorem periodic_orbit_finite {X : Type*} (d : DiscreteTimeDynamics X) (x : X)
    (p : ℕ) (hp : d.isPeriodic x p) :
    Set.Finite (Set.range (d.evolve x)) := by
  -- By definition of periodicity, we have d.evolve x p = x.
  obtain ⟨k, hk⟩ := hp;
  have h_orbit : ∀ n ≥ 0, d.evolve x (n + p) = d.evolve x n := by
    intro n hn; induction hn <;> simp_all +decide [ Nat.succ_add, DiscreteTimeDynamics.evolve ] ;
  -- Therefore, the orbit is contained in the set {d.evolve x 0, d.evolve x 1, ..., d.evolve x (p-1)}.
  have h_orbit_subset : ∀ n ≥ 0, d.evolve x n ∈ Set.image (d.evolve x) (Finset.range p) := by
    intro n hn
    have h_mod : ∃ m ∈ Finset.range p, d.evolve x n = d.evolve x m := by
      refine' ⟨ n % p, Finset.mem_range.mpr ( Nat.mod_lt _ k ), _ ⟩;
      conv_lhs => rw [ ← Nat.mod_add_div n p ];
      exact Nat.recOn ( n / p ) rfl fun n hn => by rw [ Nat.mul_succ, ← add_assoc, h_orbit _ ( Nat.zero_le _ ), hn ] ;
    grind;
  exact Set.Finite.subset ( Set.toFinite _ ) ( Set.range_subset_iff.mpr fun n => h_orbit_subset n n.zero_le )




/-- Projection from linear time to cyclic time (period 1). -/
def toCyclicTime (t : ℝ) : ℝ := Int.fract t




/-- Cyclic time projection is periodic with period 1. -/
theorem cyclicTime_periodic (t : ℝ) : toCyclicTime (t + 1) = toCyclicTime t := by
  simp only [toCyclicTime]
  exact_mod_cast Int.fract_add_natCast t 1




/-- Cyclic time values lie in [0, 1). -/
theorem cyclicTime_mem_Ico (t : ℝ) : toCyclicTime t ∈ Set.Ico (0 : ℝ) 1 :=
  ⟨Int.fract_nonneg t, Int.fract_lt_one t⟩




/-- A proof is a finite sequence of steps — a temporal process. -/
structure FormalProof (State : Type*) where
  states : List State
  nonempty : states ≠ []




/-- The initial state of a proof (the original goal). -/
def FormalProof.initial {State : Type*} (p : FormalProof State) : State :=
  p.states.head p.nonempty




/-- The final state of a proof (QED). -/
def FormalProof.final {State : Type*} (p : FormalProof State) : State :=
  p.states.getLast p.nonempty




/-- The duration of a proof in steps. -/
def FormalProof.proofLength {State : Type*} (p : FormalProof State) : ℕ :=
  p.states.length - 1




/-- **The Oracle's Fixed Point**: the research function is idempotent at
the completed theory. -/
def oracleFixedPoint {T : Type*} (research : T → T) (theory : T) : Prop :=
  research theory = theory




/-- **ℤ is countable.** -/
theorem int_countable : Countable ℤ := inferInstance




/-- **ℝ is uncountable.** -/
theorem real_uncountable : ¬ Countable ℝ := not_countable




theorem clock_impossibility : ¬ ∃ f : ℤ → ℝ, Surjective f := by
  -- By contradiction, assume there exists a surjective function from ℤ to ℝ.
  by_contra h_surj
  obtain ⟨f, hf⟩ := h_surj;
  have h_countable : Countable (Set.range f) := by
    exact Set.countable_range f;
  rw [ Set.range_eq_univ.mpr hf ] at h_countable ; exact absurd h_countable ( by simpa using Cardinal.not_countable_real ) ;




/-- **Synthesis Theorem**: ℝ is the canonical model of time — it is ordered, dense,
complete, metrizable, has a dense countable subset (ℚ), supports arrows of time,
and is strictly larger than any countable (discrete) clock. -/
theorem reals_are_time :
    DenselyOrdered ℝ ∧
    NoMinOrder ℝ ∧
    NoMaxOrder ℝ ∧
    DenseRange ((↑) : ℚ → ℝ) ∧
    ¬Countable ℝ ∧
    (∃ _ : StrictArrow ℝ, True) := by
  exact ⟨inferInstance, inferInstance, inferInstance,
         rationals_dense_in_reals, real_uncountable, ⟨trivialArrow, trivial⟩⟩




end
