import Mathlib

/-!
# Descent Systems and the Basin Fixed Point Theorem

A `DescentSystem` is a discrete dynamical system on a type `S` equipped with a
deterministic update map `step : S → S` and a `ℕ`-valued Lyapunov ("energy")
function that strictly decreases away from fixed points.  This is the abstract
combinatorial skeleton of *gradient descent*: a fixed point is a local minimum,
and every state eventually flows into one.

## Main results

* `DescentSystem.isFix_of_iterate` — the structural descent engine: after
  `D.energy s` iterations (indeed after any `n ≥ D.energy s` iterations) the
  trajectory has reached a fixed point.
* `DescentSystem.limitPoint_isFix` — every state flows to a fixed point.
* `DescentSystem.range_limitPoint_eq_fixedPoints` — the basin↔fixed-point
  correspondence: the image of the limit map is exactly the fixed-point set.
* `DescentSystem.image_limitPoint_eq_fixedPoints` /
  `DescentSystem.basin_count_eq_fixedPoint_count` — **the Basin Fixed Point
  Theorem**: the number of basins of attraction equals the number of fixed
  points.
* `DescentSystem.basin_disjoint`, `DescentSystem.biUnion_basin_eq_univ` — the
  basins partition the state space.
* `DescentSystem.prod_fixedPoint_count` — basin counts are multiplicative across
  independent (product) subsystems.
* `DescentSystem.limitPoint_equivariant`, `DescentSystem.isFix_equiv` —
  energy-preserving symmetries permute fixed points and intertwine the basin map.

-- !-- Lab Notebook: DescentSystem (file overview) -- !--
-- !-- Hypothesis: A single ℕ-valued Lyapunov bound suffices to make discrete
--     gradient descent terminate and to identify basins with fibers of a limit map. -- !--
-- !-- Result: Confirmed. The one lemma `isFix_of_iterate` (induction on the step
--     budget) carries the entire theory; everything else is image/fiber bookkeeping. -- !--
-- !-- Insight: "Counting basins" is a pure fiber computation on `limitPoint`, which
--     makes multiplicativity (product) and equivariance (symmetry) almost syntactic. -- !--
-- !-- Failure analysis: A naive `step^[energy s]` induction on `s` directly is awkward;
--     generalizing to "any budget `n ≥ energy s`" makes the induction on `n` clean. -- !--
-- !-- End Lab Notebook -- !--
-/

namespace MachineLearning

open Function Finset

/-- A discrete dynamical system with a `ℕ`-valued Lyapunov ("energy") function
that strictly decreases at every non-fixed state. -/
structure DescentSystem (S : Type*) where
  /-- The deterministic update rule. -/
  step : S → S
  /-- The Lyapunov / energy function. -/
  energy : S → ℕ
  /-- Energy strictly decreases away from fixed points. -/
  strict_descent : ∀ s, step s ≠ s → energy (step s) < energy s

namespace DescentSystem

variable {S S₁ S₂ : Type*}

/-- `s` is a fixed point of the dynamics. -/
def IsFix (D : DescentSystem S) (s : S) : Prop := D.step s = s

theorem isFix_iff (D : DescentSystem S) (s : S) : D.IsFix s ↔ D.step s = s := Iff.rfl

-- !-- Sketch: if `s` were not fixed, `strict_descent` would force `energy (step s) < 0`. -- !--
/-- Energy zero forces a fixed point: there is nowhere lower to descend. -/
theorem isFix_of_energy_zero (D : DescentSystem S) {s : S} (h : D.energy s = 0) :
    D.IsFix s := by
  exact Classical.not_not.1 fun H => D.strict_descent s H |> fun h' => by linarith

-- !-- Lab Notebook: isFix_of_iterate (the structural engine) -- !--
-- !-- Hypothesis: A budget of `energy s` steps always suffices to reach a fixed point. -- !--
-- !-- Result: Proved by induction on the budget `n` (generalized over `s`). -- !--
-- !-- Insight: This single lemma carries the whole theory; the energy is a literal
--     upper bound on the worst-case descent-path length. -- !--
-- !-- Failure analysis: Inducting on `s` directly fails; generalizing to "any budget
--     `n ≥ energy s`" and inducting on `n` makes both base and step trivial. -- !--
-- !-- Sketch: at a fixed point we stay put (`iterate_fixed`); otherwise energy drops, so a
--     smaller budget suffices on `step s`, and one extra step closes the gap. -- !--
-- !-- End Lab Notebook -- !--
/-- **Descent engine.** Iterating `step` for any number of steps `n ≥ D.energy s`
lands on a fixed point. -/
theorem isFix_of_iterate (D : DescentSystem S) (n : ℕ) (s : S) (h : D.energy s ≤ n) :
    D.IsFix (D.step^[n] s) := by
  induction' n with n ih generalizing s
  · exact D.isFix_of_energy_zero (le_antisymm h (Nat.zero_le _))
  · by_cases h' : D.step s = s
    · simp +decide [*, Function.iterate_fixed]
      exact h'
    · simpa only [Function.iterate_add_apply, Function.iterate_one] using
        ih (D.step s) (Nat.le_of_lt_succ (lt_of_lt_of_le (D.strict_descent s h') h))

/-- The limit point reached by descending from `s` (using the energy as a step budget). -/
def limitPoint (D : DescentSystem S) (s : S) : S := D.step^[D.energy s] s

-- !-- Lab Notebook: limitPoint_isFix -- !--
-- !-- Hypothesis: `step^[energy s] s` is always a fixed point. -- !--
-- !-- Result: Immediate from `isFix_of_iterate` with `n = energy s`. -- !--
-- !-- Insight: This makes `limitPoint` a well-defined retraction onto the fixed set. -- !--
-- !-- Failure analysis: none — the generalized engine lemma does all the work. -- !--
-- !-- End Lab Notebook -- !--
/-- Every state flows to a fixed point. -/
theorem limitPoint_isFix (D : DescentSystem S) (s : S) : D.IsFix (D.limitPoint s) := by
  exact D.isFix_of_iterate _ _ le_rfl

-- !-- Sketch: a fixed point is invariant under any number of iterations (`iterate_fixed`). -- !--
/-- A fixed point is its own limit. -/
theorem limitPoint_eq_self (D : DescentSystem S) {s : S} (h : D.IsFix s) :
    D.limitPoint s = s := by
  exact Function.iterate_fixed h _

-- !-- Sketch: `limitPoint s` is fixed (`limitPoint_isFix`), hence its own limit. -- !--
/-- `limitPoint` is idempotent: descending from a limit point changes nothing. -/
theorem limitPoint_limitPoint (D : DescentSystem S) (s : S) :
    D.limitPoint (D.limitPoint s) = D.limitPoint s :=
  D.limitPoint_eq_self (D.limitPoint_isFix s)

-- !-- Lab Notebook: range_limitPoint_eq_fixedPoints -- !--
-- !-- Hypothesis: The image of the limit map is exactly the fixed-point set. -- !--
-- !-- Result: ⊆ from `limitPoint_isFix`; ⊇ since a fixed point equals its own limit. -- !--
-- !-- Insight: This is the basin↔fixed-point correspondence in set form. -- !--
-- !-- Failure analysis: none. -- !--
-- !-- End Lab Notebook -- !--
/-- **Basin–fixed-point correspondence.** The range of the limit map equals the
set of fixed points. -/
theorem range_limitPoint_eq_fixedPoints (D : DescentSystem S) :
    Set.range D.limitPoint = {s | D.IsFix s} :=
  Set.ext fun x =>
    ⟨fun ⟨s, hs⟩ => hs ▸ limitPoint_isFix D s, fun hx => ⟨x, by rw [limitPoint_eq_self D hx]⟩⟩

/-! ## Counting basins (finite state space) -/

section Fintype

variable [Fintype S] [DecidableEq S]

/-- The finset of fixed points. -/
def fixedPoints (D : DescentSystem S) : Finset S := univ.filter (fun s => D.step s = s)

theorem mem_fixedPoints (D : DescentSystem S) (s : S) :
    s ∈ D.fixedPoints ↔ D.IsFix s := by
  simp [fixedPoints, IsFix]

/-- The basin of attraction of a state `t`: all states whose limit is `t`. -/
def basin (D : DescentSystem S) (t : S) : Finset S := univ.filter (fun s => D.limitPoint s = t)

theorem mem_basin (D : DescentSystem S) (s t : S) :
    s ∈ D.basin t ↔ D.limitPoint s = t := by
  simp [basin]

-- !-- Sketch: a fixed point `t` has `limitPoint t = t`, so it lies in its own basin. -- !--
/-- A fixed point lies in its own basin. -/
theorem mem_basin_self (D : DescentSystem S) {t : S} (h : D.IsFix t) : t ∈ D.basin t :=
  Finset.mem_filter.mpr ⟨Finset.mem_univ _, limitPoint_eq_self D h⟩

-- !-- Lab Notebook: image_limitPoint_eq_fixedPoints -- !--
-- !-- Hypothesis: The image of `limitPoint` over the whole space is the fixedPoints finset. -- !--
-- !-- Result: Finset version of `range_limitPoint_eq_fixedPoints`. -- !--
-- !-- Insight: Reduces "count basins" to "count fixed points" since basins are the
--     nonempty fibers of `limitPoint`, indexed exactly by its image. -- !--
-- !-- Failure analysis: none. -- !--
-- !-- End Lab Notebook -- !--
/-- The image of the limit map is exactly the set of fixed points. -/
theorem image_limitPoint_eq_fixedPoints (D : DescentSystem S) :
    univ.image D.limitPoint = D.fixedPoints := by
  ext t
  constructor <;> intro h <;> simp_all +decide [DescentSystem.fixedPoints]
  · obtain ⟨s, rfl⟩ := h; exact D.limitPoint_isFix s
  · exact ⟨t, limitPoint_eq_self D h⟩

-- !-- Lab Notebook: basin_count_eq_fixedPoint_count (Basin Fixed Point Theorem) -- !--
-- !-- Hypothesis: #basins = #fixed points. -- !--
-- !-- Result: Proved; the number of distinct limit values equals #fixedPoints. -- !--
-- !-- Insight: Basins are fibers of `limitPoint`, so their number is `|image limitPoint|`. -- !--
-- !-- Failure analysis: none — corollary of the image identity. -- !--
-- !-- End Lab Notebook -- !--
/-- **Basin Fixed Point Theorem.** The number of basins of attraction (distinct
limit values) equals the number of fixed points. -/
theorem basin_count_eq_fixedPoint_count (D : DescentSystem S) :
    (univ.image D.limitPoint).card = D.fixedPoints.card := by
  rw [← image_limitPoint_eq_fixedPoints]

-- !-- Sketch: two basins sharing a point would force their (equal) limit values to coincide. -- !--
/-- Distinct fixed points have disjoint basins. -/
theorem basin_disjoint (D : DescentSystem S) {t₁ t₂ : S} (h : t₁ ≠ t₂) :
    Disjoint (D.basin t₁) (D.basin t₂) :=
  Finset.disjoint_filter.2 fun _ _ hx₁ hx₂ => h <| hx₁.symm.trans hx₂

-- !-- Lab Notebook: biUnion_basin_eq_univ -- !--
-- !-- Hypothesis: The basins over the fixed points cover the whole space. -- !--
-- !-- Result: Every `s` lies in basin (limitPoint s), and limitPoint s is a fixed point. -- !--
-- !-- Insight: Together with `basin_disjoint`, the basins partition the state space. -- !--
-- !-- Failure analysis: none. -- !--
-- !-- End Lab Notebook -- !--
/-- The basins indexed by fixed points cover the entire state space. -/
theorem biUnion_basin_eq_univ (D : DescentSystem S) :
    D.fixedPoints.biUnion D.basin = univ := by
  ext s
  simp [Finset.mem_biUnion, mem_basin, mem_fixedPoints, limitPoint_isFix]

end Fintype

/-! ## Multiplicativity across independent subsystems -/

-- !-- Sketch: each component energy is non-increasing under its step, and the non-fixedness
--     hypothesis forces at least one of the two component decreases to be strict. -- !--
/-- Energy of a product strictly decreases away from product fixed points. -/
theorem prod_strict_descent (D₁ : DescentSystem S₁) (D₂ : DescentSystem S₂)
    (p : S₁ × S₂) (h : (D₁.step p.1, D₂.step p.2) ≠ p) :
    D₁.energy (D₁.step p.1) + D₂.energy (D₂.step p.2)
      < D₁.energy p.1 + D₂.energy p.2 := by
  by_cases h₁ : D₁.step p.1 = p.1 <;> by_cases h₂ : D₂.step p.2 = p.2 <;>
    simp_all +decide [Prod.ext_iff]
  · exact D₂.strict_descent _ h₂
  · exact D₁.strict_descent _ h₁
  · exact add_lt_add (D₁.strict_descent _ h₁) (D₂.strict_descent _ h₂)

/-- The synchronous product of two descent systems. -/
def prod (D₁ : DescentSystem S₁) (D₂ : DescentSystem S₂) : DescentSystem (S₁ × S₂) where
  step := fun p => (D₁.step p.1, D₂.step p.2)
  energy := fun p => D₁.energy p.1 + D₂.energy p.2
  strict_descent := fun p h => prod_strict_descent D₁ D₂ p h

-- !-- Sketch: `(step₁ a, step₂ b) = (a,b)` is, by `Prod.ext_iff`, exactly both components fixed. -- !--
/-- A product state is fixed iff both components are. -/
theorem prod_isFix_iff (D₁ : DescentSystem S₁) (D₂ : DescentSystem S₂) (p : S₁ × S₂) :
    (D₁.prod D₂).IsFix p ↔ D₁.IsFix p.1 ∧ D₂.IsFix p.2 :=
  ⟨fun h => ⟨(Prod.ext_iff.mp h).1, (Prod.ext_iff.mp h).2⟩, fun h => Prod.ext h.1 h.2⟩

section ProdFintype

variable [Fintype S₁] [DecidableEq S₁] [Fintype S₂] [DecidableEq S₂]

-- !-- Lab Notebook: prod_fixedPoint_count -- !--
-- !-- Hypothesis: Basin counts are multiplicative across independent subsystems. -- !--
-- !-- Result: fixedPoints(D₁ × D₂) = fixedPoints D₁ ×ˢ fixedPoints D₂, so cards multiply. -- !--
-- !-- Insight: This is the classical (q=1) shadow of a "quantum" basin-count deformation. -- !--
-- !-- Failure analysis: need `prod_isFix_iff` to identify the product fixed set. -- !--
-- !-- End Lab Notebook -- !--
/-- **Multiplicativity of basin counts.** The number of basins of a product
system is the product of the numbers of basins of its factors. -/
theorem prod_fixedPoint_count (D₁ : DescentSystem S₁) (D₂ : DescentSystem S₂) :
    (D₁.prod D₂).fixedPoints.card = D₁.fixedPoints.card * D₂.fixedPoints.card := by
  rw [← Finset.card_product]
  congr 1
  ext x
  simp only [DescentSystem.fixedPoints, Finset.mem_filter, Finset.mem_univ, true_and,
    Finset.mem_product]
  unfold DescentSystem.prod
  aesop

end ProdFintype

/-! ## Equivariance under energy-preserving symmetries -/

variable (D : DescentSystem S)

-- !-- Lab Notebook: isFix_equiv & limitPoint_equivariant -- !--
-- !-- Hypothesis: A symmetry `e` commuting with `step` and preserving `energy` permutes
--     fixed points and intertwines the limit map. -- !--
-- !-- Result: isFix(e s) ↔ isFix s by injectivity of e; limitPoint(e s) = e(limitPoint s)
--     by pushing e through the iterate. -- !--
-- !-- Insight: This is exactly the `MulAction`-on-basins data needed for a Burnside count. -- !--
-- !-- Failure analysis: requires both the commuting and energy-preserving hypotheses;
--     either alone is insufficient (commuting alone cannot align iterate budgets). -- !--
-- !-- End Lab Notebook -- !--
/-- An energy-preserving symmetry commuting with `step` permutes fixed points. -/
theorem isFix_equiv (e : S ≃ S) (hstep : ∀ s, D.step (e s) = e (D.step s)) (s : S) :
    D.IsFix (e s) ↔ D.IsFix s := by
  simp +decide [DescentSystem.IsFix, hstep]

-- !-- Sketch: induct on `n`, pushing `e` through one `step` at a time via `hstep`. -- !--
/-- `step` iterated through a commuting symmetry. -/
theorem iterate_step_equiv (e : S ≃ S) (hstep : ∀ s, D.step (e s) = e (D.step s))
    (n : ℕ) (s : S) : D.step^[n] (e s) = e (D.step^[n] s) := by
  induction' n with n ih generalizing s <;>
    simp_all +decide [Function.iterate_succ_apply']

-- !-- Sketch: `energy (e s) = energy s` aligns the iterate budgets, then `iterate_step_equiv`
--     pushes `e` out through the whole iterate. -- !--
/-- **Equivariance of basins.** An energy-preserving symmetry intertwines the
limit map: descending commutes with the symmetry. -/
theorem limitPoint_equivariant (e : S ≃ S) (henergy : ∀ s, D.energy (e s) = D.energy s)
    (hstep : ∀ s, D.step (e s) = e (D.step s)) (s : S) :
    D.limitPoint (e s) = e (D.limitPoint s) := by
  convert iterate_step_equiv D e hstep (D.energy s) s using 1
  exact henergy s ▸ rfl

end DescentSystem

end MachineLearning