import Logic.StronglyCriticalOrdinals
import MachineLearning.OrdinalCollapse.Basic

/-!
# Arithmetic closure of strongly critical ordinals and the Ordinal Collapsing Bridge

This file extends the predicative-ordinal-analysis fragment of
`Catalog/Logic/StronglyCriticalOrdinals.lean` with the *arithmetic* of strongly critical
ordinals, and then forges a cross-domain bridge to the finite-branching collapse theory of
`Catalog/MachineLearning/OrdinalCollapse/Basic.lean`.

The pivot is `StronglyCritical.omega0_opow_eq`: the single unary Veblen fixed-point condition
`veblen o 0 = o` (the catalog's definition of `StronglyCritical`) forces `o` to be an
ε-number, `ω ^ o = o`.  Every further arithmetic property — being a limit ordinal, additive
and multiplicative principality — then follows from Mathlib's principal-ordinal API applied
to `ω ^ o`.

## Main results

### Cluster E — Arithmetic closure
* `StronglyCritical.omega0_opow_eq` — a strongly critical ordinal is an ε-number `ω ^ o = o`.
* `StronglyCritical.isLimit` — strongly critical ordinals are (successor) limit ordinals.
* `StronglyCritical.principal_add` / `StronglyCritical.add_lt` — additive principality.
* `StronglyCritical.principal_mul` / `StronglyCritical.mul_lt` — multiplicative principality.

### Cluster F — The Ordinal Collapsing Bridge
* `omega0_opow_lt_epsilon_zero_of_lt` — `ε₀` is closed under `ω ^ ⬝` below itself.
* `researchObject_omega_tower_lt_epsilon_zero` (flagship) — for *every* finitely branching
  `ResearchObject A`, `ω ^ (researchDepth A) < ε₀`.  A finite epistemic process, even after a
  transfinite exponential lift, never reaches the proof-theoretic ordinal of `PA`.

### Cluster G — Ascending strength tower
* `exists_infinite_ascending_strength_tower` — the strictly increasing ω-tower
  `Γ_ 0 < Γ_ 1 < ⋯` of strongly critical systems, the constructive complement to the
  catalog's `no_infinite_consistency_descent`.

## Lineage / catalog synthesis

The file builds directly on the catalog: `StronglyCritical` and `StronglyCritical.veblen_eq`
come from `Logic.StronglyCriticalOrdinals`; the bridge fuses
`ResearchObject.researchDepth_lt_omega` from `MachineLearning.OrdinalCollapse.Basic` with the
predicative hierarchy; the ascending tower is the order-dual of
`Predicative.no_infinite_consistency_descent` over the same `OrdAnalyzedSystem`/`StrongerThan`
infrastructure.
-/

/- -- !-- Lab Notebook -- !--
  Hypothesis (Cluster E): The unary Veblen fixed point `veblen o 0 = o` that *defines*
    `StronglyCritical` should be strong enough to recover the full arithmetic profile of a
    strongly critical ordinal — ε-number, limit, additively and multiplicatively principal —
    without any further hypotheses.
  Result: Confirmed. `StronglyCritical.veblen_eq` (catalog) at `a = 0` plus
    `veblen_zero_apply` collapses the definition to `ω ^ o = o`; everything else is a
    one-line transport of a Mathlib `principal_*`/`isSuccLimit_*` lemma across that equation.
  Insight: ε-numberhood is the *correct* normal form for `StronglyCritical`. The unary Veblen
    condition and the exponential fixed-point condition `ω ^ o = o` are interchangeable, which
    is what lets the entire `Ordinal.Principal` toolbox apply verbatim.

  Hypothesis (Cluster F): Finite branching (catalog `researchDepth_lt_omega`) is preserved
    under the exponential lift `ω ^ ⬝` relative to the ceiling `ε₀`.
  Result: Confirmed via `omega0_opow_lt_epsilon_zero_of_lt`, proved from the fundamental
    sequence `lt_epsilon_zero` for `ε₀`. Since `researchDepth A < ω < ε₀`, the lift stays
    below `ε₀`.
  Insight: The bridge is sharp at the *base* level — `ω < ε₀` is what makes the single lift
    safe; iterating the lift transfinitely is exactly Future Direction 3.
  Failure analysis: The first instinct was to bound `ω ^ (researchDepth A)` by an explicit
    iterate `(ω ^ ⬝)^[n] 0`; this is true but awkward. Routing through the abstract closure
    lemma `omega0_opow_lt_epsilon_zero_of_lt` (`o < ε₀ → ω ^ o < ε₀`) is cleaner and reusable.

  Hypothesis (Cluster G): The `gamma` scale gives a constructive strictly ascending tower of
    strongly critical systems, mirroring (dually) `no_infinite_consistency_descent`.
  Result: Confirmed. `gamma_lt_gamma` gives strict monotonicity of `n ↦ Γ_ n`, and
    `gamma_stronglyCritical` (catalog) gives strong criticality of every rung.
-/

namespace Predicative

open Ordinal

/-! ## Cluster E — Arithmetic closure of strongly critical ordinals -/

-- !-- `StronglyCritical.veblen_eq` at `a = 0` gives `veblen 0 o = o`; rewrite the left side
-- with `veblen_zero_apply : veblen 0 o = ω ^ o`. -- !--
/-- **ε-number.**  Every strongly critical ordinal is a fixed point of `ω ^ ⬝`. -/
theorem StronglyCritical.omega0_opow_eq {o : Ordinal} (h : StronglyCritical o) :
    ω ^ o = o := by
  have hv := h.veblen_eq h.1
  rw [veblen_zero_apply] at hv
  exact hv

-- !-- Rewrite `o` as `ω ^ o` (`omega0_opow_eq`) and apply `isSuccLimit_opow_left` with the
-- limit base `ω` and the nonzero exponent `o`. -- !--
/-- **Limit ordinal.**  Every strongly critical ordinal is a successor-limit ordinal. -/
theorem StronglyCritical.isLimit {o : Ordinal} (h : StronglyCritical o) :
    Order.IsSuccLimit o := by
  have he : ω ^ o = o := h.omega0_opow_eq
  rw [← he]
  exact isSuccLimit_opow_left isSuccLimit_omega0 (ne_of_gt h.1)

-- !-- Transport `principal_add_omega0_opow o : Principal (·+·) (ω ^ o)` across
-- `ω ^ o = o`. -- !--
/-- **Additive principality.**  Strongly critical ordinals are additively principal. -/
theorem StronglyCritical.principal_add {o : Ordinal} (h : StronglyCritical o) :
    Principal (· + ·) o := by
  have he : ω ^ o = o := h.omega0_opow_eq
  rw [← he]
  exact principal_add_omega0_opow o

-- !-- Specialize additive principality to the two summands. -- !--
/-- If `a, b < o` and `o` is strongly critical then `a + b < o`. -/
theorem StronglyCritical.add_lt {o a b : Ordinal} (h : StronglyCritical o)
    (ha : a < o) (hb : b < o) : a + b < o :=
  h.principal_add ha hb

-- !-- From `ω ^ o = o` we get `ω ^ ω ^ o = o`; transport `principal_mul_omega0_opow_opow o`
-- across this equation. -- !--
/-- **Multiplicative principality.**  Strongly critical ordinals are multiplicatively
principal. -/
theorem StronglyCritical.principal_mul {o : Ordinal} (h : StronglyCritical o) :
    Principal (· * ·) o := by
  have he : ω ^ o = o := h.omega0_opow_eq
  have he2 : ω ^ ω ^ o = o := by rw [he, he]
  rw [← he2]
  exact principal_mul_omega0_opow_opow o

-- !-- Specialize multiplicative principality to the two factors. -- !--
/-- If `a, b < o` and `o` is strongly critical then `a * b < o`. -/
theorem StronglyCritical.mul_lt {o a b : Ordinal} (h : StronglyCritical o)
    (ha : a < o) (hb : b < o) : a * b < o :=
  h.principal_mul ha hb

/-! ## Cluster F — The Ordinal Collapsing Bridge -/

-- !-- Use the fundamental sequence `lt_epsilon_zero` to get `o < (ω ^ ⬝)^[n] 0`; then
-- `ω ^ o < ω ^ ((ω ^ ⬝)^[n] 0) = (ω ^ ⬝)^[n+1] 0 < ε₀` via `opow_lt_opow_iff_right` and
-- `iterate_omega0_opow_lt_epsilon_zero`. -- !--
/-- **ε₀ is closed under `ω ^ ⬝` below itself.**  If `o < ε₀` then `ω ^ o < ε₀`. -/
theorem omega0_opow_lt_epsilon_zero_of_lt {o : Ordinal} (h : o < ε₀) : ω ^ o < ε₀ := by
  rw [lt_epsilon_zero] at h
  obtain ⟨n, hn⟩ := h
  calc ω ^ o < ω ^ ((fun a => ω ^ a)^[n] 0) :=
        (opow_lt_opow_iff_right one_lt_omega0).mpr hn
    _ = (fun a => ω ^ a)^[n + 1] 0 := by rw [Function.iterate_succ_apply']
    _ < ε₀ := iterate_omega0_opow_lt_epsilon_zero (n + 1)

-- !-- The catalog's `researchDepth_lt_omega` gives `researchDepth A < ω`, and
-- `ω < ε₀` (`omega0_lt_epsilon 0`); chain them and apply
-- `omega0_opow_lt_epsilon_zero_of_lt`. -- !--
/-- **Flagship — the Ordinal Collapsing Bridge.**  For *every* finitely branching research
object `A`, the transfinite exponential lift of its depth stays below the proof-theoretic
ordinal of Peano Arithmetic: `ω ^ (researchDepth A) < ε₀`.

This fuses the finite-branching collapse theorem
`ResearchObject.researchDepth_lt_omega` with the predicative hierarchy. -/
theorem researchObject_omega_tower_lt_epsilon_zero (A : ResearchObject) :
    ω ^ (ResearchObject.researchDepth A) < ε₀ :=
  omega0_opow_lt_epsilon_zero_of_lt
    (lt_trans (ResearchObject.researchDepth_lt_omega A) (omega0_lt_epsilon 0))

/-! ## Cluster G — Ascending strength tower -/

-- !-- Take `f n = ⟨Γ_ n⟩`. Strict ascent is `gamma_lt_gamma` applied to `n < n+1`; each rung
-- is strongly critical by the catalog's `gamma_stronglyCritical`. -- !--
/-- **Ascending strength tower.**  There is a strictly increasing ω-tower of strongly
critical systems `Γ_ 0 < Γ_ 1 < Γ_ 2 < ⋯`.  This is the constructive complement of the
catalog theorem `no_infinite_consistency_descent`: while no infinite *descent* of strength is
possible, an infinite *ascent* of strongly critical strength always exists. -/
theorem exists_infinite_ascending_strength_tower :
    ∃ f : ℕ → OrdAnalyzedSystem, (∀ n, StrongerThan (f (n + 1)) (f n)) ∧
      ∀ n, StronglyCritical (f n).pto := by
  refine ⟨fun n => ⟨Γ_ (n : Ordinal)⟩, ?_, ?_⟩
  · intro n
    show Γ_ (n : Ordinal) < Γ_ ((n + 1 : ℕ) : Ordinal)
    rw [gamma_lt_gamma]
    exact_mod_cast Nat.lt_succ_self n
  · intro n
    exact gamma_stronglyCritical _

end Predicative