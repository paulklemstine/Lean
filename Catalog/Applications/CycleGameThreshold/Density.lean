import Mathlib

/-!
# Maximum 2-density of the cycle `C_k` (Bednarska–Łuczak exponent)

For the Maker–Breaker `H`-game on `K_n`, Bednarska and Łuczak (2000) proved that the
threshold bias is `Θ(n^{1/m₂(H)})`, where

  `m₂(H) = max { (e(H') - 1) / (v(H') - 2) : H' ⊆ H, v(H') ≥ 3 }`

is the *maximum 2-density* of `H`.  For the `k`-cycle `C_k` (`k ≥ 4`) the mission
statement asserts a threshold exponent `(k-2)/(k-1)`; this is exactly `1/m₂(C_k)`,
so the combinatorial content behind the exponent is the identity

  `m₂(C_k) = (k-1)/(k-2)`.

This file proves that identity **from first principles about subgraphs of a cycle**.

## Model of subgraphs of `C_k`

A subgraph of the `k`-cycle is described by its number of edges `e` and vertices `v`.
Two mutually exclusive shapes occur:

* the **whole cycle**: `e = k`, `v = k`;
* a **proper subgraph**: it is a disjoint union of `c ≥ 1` paths, hence it is a
  forest with `v = e + c` vertices; in particular `e < v` (strictly fewer edges than
  vertices) and `v ≤ k`.

We collect the corresponding 2-densities `(e-1)/(v-2)` into `twoDensitySet k` and prove
`IsGreatest (twoDensitySet k) ((k-1)/(k-2))`: the whole cycle is the unique densest
subgraph, so `m₂(C_k) = (k-1)/(k-2)`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the game exponent `(k-2)/(k-1)` is `1/m₂(C_k)`, and the
maximum 2-density of a cycle is attained by the whole cycle, equalling `(k-1)/(k-2)`.
Experiment (Experimenter): every *proper* subgraph of a cycle is a disjoint union of
paths, a forest with `e < v`, so its 2-density `(e-1)/(v-2) ≤ 1`; the cycle itself has
density `(k-1)/(k-2) > 1`.  Small cases (`k=4,5,6`) give `3/2, 4/3, 5/4`, matching
`1 + 1/(k-2)`.
Analysis (Analyst): the key inequality `(e-1)/(v-2) ≤ 1` reduces to `e < v`, i.e. a
proper subgraph has a strictly larger vertex than edge count — the defining property of
a forest.  This is what makes the *whole* cycle (`e = v`) strictly denser.
Critique (Critic): the statement is not vacuous — the maximiser `(k-1)/(k-2)` is an
actual member of the set (`e=v=k`), and the upper bound holds for every element.
`IsGreatest` bundles both facts, ruling out a "vacuously true supremum".
Synthesis: `m₂(C_k) = (k-1)/(k-2)`, hence the Bednarska–Łuczak exponent for the
`C_k`-game is `1/m₂(C_k) = (k-2)/(k-1)`.
-/

namespace CycleGameThreshold

/-- The set of 2-densities `(e-1)/(v-2)` of subgraphs of the `k`-cycle:
either the whole cycle (`e = k`, `v = k`) or a proper subforest (`1 ≤ e < v ≤ k`). -/
def twoDensitySet (k : ℕ) : Set ℝ :=
  {r | ∃ e v : ℕ, 3 ≤ v ∧
      ((e = k ∧ v = k) ∨ (1 ≤ e ∧ e < v ∧ v ≤ k)) ∧
      r = ((e : ℝ) - 1) / ((v : ℝ) - 2)}

/-
A proper subforest of the cycle has 2-density at most `1`.
-/
lemma proper_two_density_le_one {e v : ℕ} (hv : 3 ≤ v) (hev : e < v) :
    ((e : ℝ) - 1) / ((v : ℝ) - 2) ≤ 1 := by
  rw [ div_le_iff₀ ] <;> linarith [ show ( e : ℝ ) + 1 ≤ v by norm_cast, show ( v : ℝ ) ≥ 3 by norm_cast ]

/-
The whole cycle has 2-density `(k-1)/(k-2) ≥ 1` for `k ≥ 3`.
-/
lemma cycle_two_density_ge_one {k : ℕ} (hk : 3 ≤ k) :
    (1 : ℝ) ≤ ((k : ℝ) - 1) / ((k : ℝ) - 2) := by
  rw [ le_div_iff₀ ] <;> linarith [ show ( k : ℝ ) ≥ 3 by norm_cast ]

/-
**Main theorem.**  The maximum 2-density of the `k`-cycle (`k ≥ 4`) is
`(k-1)/(k-2)`, attained by the whole cycle.  Equivalently `m₂(C_k) = (k-1)/(k-2)`,
which is the reciprocal of the Bednarska–Łuczak threshold exponent `(k-2)/(k-1)`.
-/
theorem cycle_two_density_isGreatest {k : ℕ} (hk : 4 ≤ k) :
    IsGreatest (twoDensitySet k) (((k : ℝ) - 1) / ((k : ℝ) - 2)) := by
  constructor;
  · exact ⟨ k, k, by linarith, Or.inl ⟨ rfl, rfl ⟩, by ring ⟩;
  · rintro r ⟨ e, v, hv, ( ⟨ rfl, rfl ⟩ | ⟨ he, hev, hvk ⟩ ), rfl ⟩ <;> norm_num;
    exact le_trans ( proper_two_density_le_one hv hev ) ( cycle_two_density_ge_one ( by linarith ) )

end CycleGameThreshold