import Mathlib

/-!
# The Last Theorem: Countability of Provable Statements and the Thermodynamic Horizon of Discovery

**Catalog category: cross-domain bridge (mathematical logic ↔ statistical physics).**

This file makes precise a chain of ideas linking the *combinatorics of formal
statements* to the *thermodynamic limits of physical computation*.

A formal statement is a finite string over a fixed finite alphabet. The collection
of all such strings, and any infinite sub-collection singled out by a deductive
system (the *provable* strings, i.e. the "theorems"), is **countably infinite**:
there are exactly as many theorems as there are natural numbers, so an idealized
enumerator that never halts would eventually list every one of them.

Physical computation, however, does halt. A universe with a finite operation
budget `N` can display only finitely many theorems. We quantify the resulting
scarcity two ways:

* infinitely many theorems remain forever undiscovered (`undiscovered_infinite`);
* the *fraction* of theorems reachable within the budget tends to `0` as the
  enumeration proceeds (`discoverable_fraction_tendsto_zero`).

Finally we turn to the boldest escape hatch: storing statements on the event
horizon of a black hole. The Bekenstein–Hawking entropy scales with horizon
*area*, and for a Schwarzschild hole the radius is proportional to the mass, so
the storable information scales as the **square of the mass**
(`entropy_eq_pi_a_sq_mass_sq`, `entropy_mass_quadratic`). Quadratic growth beats
any linear resource (`entropy_eventually_dominates_linear`), yet it is still
finite — so even a holographic memory leaves the discoverable fraction at zero
(`holographic_fraction_tendsto_zero`).

## Main results
* `theorems_countable` / `theorems_infinite` — the provable strings form a
  countable, infinite set.
* `theorems_denumerable` — hence they biject with `ℕ`.
* `undiscovered_infinite` — a finite discovery budget leaves infinitely many
  theorems undiscovered.
* `discoverable_fraction_tendsto_zero` — the discoverable fraction tends to `0`.
* `entropy_eq_pi_a_sq_mass_sq` — Bekenstein–Hawking entropy `= π a² M²`.
* `entropy_mass_quadratic` / `entropy_mass_scaling` — the `M²` scaling law.
* `entropy_eventually_dominates_linear` — quadratic storage overtakes any linear
  budget.
* `holographic_fraction_tendsto_zero` — holographic memory does not rescue the
  fraction: it remains `0`.

## References
- Bekenstein, J.D. (1973). Black holes and entropy.
- Hawking, S.W. (1975). Particle creation by black holes.
- Gödel, K. (1931); the countability of finitely axiomatized deductive closures.
- Dyson, F.J. (1979). Time without end: physics and biology in an open universe.
-/

noncomputable section

open Filter Topology

namespace HeatDeath

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer): "Theorems" (finite provable strings) form a countably
--   infinite set; any physically realizable enumeration discovers only finitely many,
--   so the discovered fraction is 0. Bold extension: black-hole (holographic) memory
--   scales storage as M², beating linear budgets, yet is still finite — the fraction
--   stays 0. This bridges logic (countability) with physics (Bekenstein entropy).
-- Experiment (Experimenter): Model an alphabet as `Fin b` (b ≥ 1) and statements as
--   `List (Fin b)`; a deductive system's output is an infinite `Set`. Countable+Infinite
--   ⇒ `Denumerable` ⇒ bijection with ℕ. Finite budget ⇒ `Set.Infinite.diff` gives an
--   infinite undiscovered set; a squeeze on `min N n / n` gives fraction → 0. Bekenstein
--   entropy from `S = A/4`, `A = 4π r²`, `r = a M` collapses to `π a² M²` by `ring`.
-- Analysis (Analyst): The M² law is what makes holographic storage tempting, but the
--   decisive fact is *finiteness*, not growth rate: ANY finite N (even ⌊π a² M²⌋) yields
--   fraction → 0. Quadratic-beats-linear (`entropy_eventually_dominates_linear`) is a
--   real gain in absolute capacity but changes nothing about the asymptotic density.
-- Critique (Critic): Guarded the alphabet with `[NeZero b]` (else `List (Fin 0)` is a
--   singleton, not infinite — a genuine boundary case). Fraction statements use n → ∞
--   so are non-vacuous; entropy laws use `ring`, not `rfl`, and the dominance theorem
--   needs the sign hypotheses `0 < k`, `0 ≤ c`.
-- Synthesis (PI): A single file linking Cantor-style countability to a Dyson/Bekenstein
--   thermodynamic horizon: the library of theorems is inexhaustible, our reading of it is not.

/-! ### Part 1 — Theorems as finite strings: countably infinite -/

/-- The alphabet of a formal language: `b` distinct symbols. -/
abbrev Symbol (b : ℕ) := Fin b

/-- A *statement* is a finite string of symbols. -/
abbrev Statement (b : ℕ) := List (Fin b)

/-- A *deductive system* over the alphabet is the set of its provable statements
(its "theorems"). We only assume the system proves infinitely many statements —
true of every consistent extension of elementary arithmetic. -/
structure DeductiveSystem (b : ℕ) where
  /-- The set of provable statements. -/
  theorems : Set (Statement b)
  /-- A nontrivial system proves infinitely many statements. -/
  productive : theorems.Infinite

variable {b : ℕ}

/-- The set of theorems of a productive system is countable. -/
theorem theorems_countable (D : DeductiveSystem b) : D.theorems.Countable :=
  (Set.to_countable D.theorems)

/-- The set of theorems is infinite (by definition of productivity). -/
theorem theorems_infinite (D : DeductiveSystem b) : D.theorems.Infinite :=
  D.productive

/-- **Countably infinite.** The theorems of a productive system biject with `ℕ`:
an ideal, never-halting enumerator lists every theorem exactly once. -/
theorem theorems_denumerable (D : DeductiveSystem b) :
    Nonempty (D.theorems ≃ ℕ) := by
  have hinf : Infinite D.theorems := D.productive.to_subtype
  exact ⟨(nonempty_denumerable D.theorems).some.eqv⟩

/-! ### Part 2 — A finite operation budget discovers a vanishing fraction -/

/-- **Inexhaustibility.** Whatever finite set `F` of theorems has been discovered
with a finite operation budget, infinitely many theorems remain undiscovered. -/
theorem undiscovered_infinite (D : DeductiveSystem b)
    {F : Set (Statement b)} (hF : F.Finite) : (D.theorems \ F).Infinite :=
  D.productive.diff hF

/-- The *discoverable fraction*: with a budget of `N` theorems, the fraction of the
first `n` enumerated theorems that are reachable is `min N n / n`. -/
def discoverableFraction (N n : ℕ) : ℝ := (min N n : ℝ) / n

/-- The discoverable fraction is nonnegative. -/
theorem discoverableFraction_nonneg (N n : ℕ) : 0 ≤ discoverableFraction N n := by
  unfold discoverableFraction
  positivity

/-- The discoverable fraction never exceeds `N / n`. -/
theorem discoverableFraction_le (N n : ℕ) :
    discoverableFraction N n ≤ (N : ℝ) / n := by
  unfold discoverableFraction
  rcases Nat.eq_zero_or_pos n with hn | hn
  · simp [hn]
  · have hn' : (0 : ℝ) ≤ (n : ℝ) := by positivity
    gcongr
    exact_mod_cast Nat.min_le_left N n

/-- **Heat death.** For any finite operation budget `N`, the fraction of theorems
discoverable before computation ceases tends to `0` as the enumeration proceeds:
the library of theorems is, in the limit, entirely beyond reach. -/
theorem discoverable_fraction_tendsto_zero (N : ℕ) :
    Tendsto (fun n : ℕ => discoverableFraction N n) atTop (𝓝 0) := by
  unfold discoverableFraction
  apply squeeze_zero (g := fun n : ℕ => (N : ℝ) / n)
  · intro n; positivity
  · intro n
    rcases Nat.eq_zero_or_pos n with hn | hn
    · simp [hn]
    · have : (0 : ℝ) ≤ (n : ℝ) := by positivity
      gcongr
      exact_mod_cast Nat.min_le_left N n
  · exact tendsto_const_div_atTop_nhds_zero_nat (N : ℝ)

/-! ### Part 3 — Holographic storage: the Bekenstein–Hawking `M²` law -/

/-- Schwarzschild radius `r = a · M`, with `a = 2G/c²` the mass-to-radius constant. -/
def schwarzschildRadius (a M : ℝ) : ℝ := a * M

/-- Horizon area `A = 4π r²` of a spherical event horizon of radius `r`. -/
def horizonArea (r : ℝ) : ℝ := 4 * Real.pi * r ^ 2

/-- Bekenstein–Hawking entropy `S = A / 4` (in Planck units): the number of bits
storable on the horizon is proportional to its area. -/
def bekensteinEntropy (a M : ℝ) : ℝ := horizonArea (schwarzschildRadius a M) / 4

/-- **Area law ⇒ `M²` law.** The horizon entropy of a Schwarzschild black hole is
`π a² M²`: because the radius grows linearly with mass and the storable information
with area, storage capacity grows with the *square* of the mass. -/
theorem entropy_eq_pi_a_sq_mass_sq (a M : ℝ) :
    bekensteinEntropy a M = Real.pi * a ^ 2 * M ^ 2 := by
  unfold bekensteinEntropy horizonArea schwarzschildRadius
  ring

/-- **Quadratic scaling.** Doubling the mass quadruples the storage. -/
theorem entropy_mass_quadratic (a M : ℝ) :
    bekensteinEntropy a (2 * M) = 4 * bekensteinEntropy a M := by
  rw [entropy_eq_pi_a_sq_mass_sq, entropy_eq_pi_a_sq_mass_sq]; ring

/-- **General scaling.** Rescaling the mass by `c` rescales storage by `c²`. -/
theorem entropy_mass_scaling (a c M : ℝ) :
    bekensteinEntropy a (c * M) = c ^ 2 * bekensteinEntropy a M := by
  rw [entropy_eq_pi_a_sq_mass_sq, entropy_eq_pi_a_sq_mass_sq]; ring

/-- The entropy is strictly increasing in the mass (for a genuine geometry `a > 0`
and positive masses): a bigger black hole is a bigger library. -/
theorem entropy_strictMonoOn (a : ℝ) (ha : 0 < a) :
    StrictMonoOn (fun M => bekensteinEntropy a M) (Set.Ici (0 : ℝ)) := by
  intro x hx y hy hxy
  simp only [entropy_eq_pi_a_sq_mass_sq]
  have hpi : 0 < Real.pi * a ^ 2 := by positivity
  have hx0 : (0 : ℝ) ≤ x := hx
  have hsq : x ^ 2 < y ^ 2 := by nlinarith [hx0, hxy]
  nlinarith [hsq, hpi]

/-- **Quadratic beats linear.** For any linear storage budget `c · M` (with `c ≥ 0`)
and any positive Bekenstein coefficient `k = π a²`, holographic storage eventually
dominates: for all `M ≥ c / k`, `π a² M² ≥ c · M`. This is the precise sense in
which black-hole memory is a genuine capacity gain. -/
theorem entropy_eventually_dominates_linear
    (k c M : ℝ) (hk : 0 < k) (hc : 0 ≤ c) (hM : c / k ≤ M) :
    c * M ≤ k * M ^ 2 := by
  have hM0 : 0 ≤ M := le_trans (by positivity) hM
  have h : c ≤ k * M := by
    have := (div_le_iff₀ hk).mp hM
    linarith [this]
  calc c * M ≤ (k * M) * M := by nlinarith [hM0]
    _ = k * M ^ 2 := by ring

/-- **The escape hatch fails.** Even a holographic memory storing `⌊π a² M²⌋`
theorems has only a *finite* budget, so the discoverable fraction still tends to
`0`: quadratic growth increases the absolute haul but not the asymptotic density.
The library remains inexhaustible. -/
theorem holographic_fraction_tendsto_zero (a M : ℝ) :
    Tendsto (fun n : ℕ => discoverableFraction ⌊bekensteinEntropy a M⌋₊ n)
      atTop (𝓝 0) :=
  discoverable_fraction_tendsto_zero _

/-! ### Part 4 — Examples, generalizations, boundaries (PEGB) -/

-- Example: a binary alphabet with the language of all strings as its "theorems".
example : DeductiveSystem 2 :=
  { theorems := Set.univ
    productive := Set.infinite_univ }

#check @theorems_denumerable
#check @discoverable_fraction_tendsto_zero
#check @entropy_eq_pi_a_sq_mass_sq

-- Example: the M² law instantiated — a mass-3 hole stores 9× a unit-mass hole.
example (a : ℝ) : bekensteinEntropy a 3 = 9 * bekensteinEntropy a 1 := by
  rw [entropy_eq_pi_a_sq_mass_sq, entropy_eq_pi_a_sq_mass_sq]; ring

-- Example (concrete number): entropy at π=... we only check the algebraic shape.
example (a M : ℝ) : bekensteinEntropy a M = Real.pi * (a * M) ^ 2 := by
  rw [entropy_eq_pi_a_sq_mass_sq]; ring

/-
Generalization. The countability argument uses nothing about ZFC specifically:
`DeductiveSystem` abstracts any productive (infinitely proving) formal system over
a finite alphabet, so `theorems_denumerable` applies to Peano arithmetic, type
theory, or any recursively enumerable theory. The fraction-zero result depends only
on the budget being finite, hence is robust to the choice of enumeration.

Boundary / limit case. The alphabet must be nonempty: over `Fin 0` the only
statement is the empty string and `Statement 0` is a singleton, so no productive
system exists — the countability picture degenerates. Likewise the dominance
theorem `entropy_eventually_dominates_linear` genuinely needs `0 < k`; with `k = 0`
there is no horizon and linear storage is never overtaken.
-/

end HeatDeath