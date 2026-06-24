import Mathlib

/-!
# Acyclic quivers have bounded path length

For a finite acyclic quiver `Q`, a *topological order* is a map `r : V → ℕ`
that strictly increases along every arrow.  Such an order exists exactly when
`Q` is acyclic.  We show that the existence of a topological order bounded by
`n` forces every path to have length `< n`; i.e. the *longest path length* is at
most `n - 1`.

This is the geometric/combinatorial input to the statement that the principal
subalgebra `𝔽Q≥1` (spanned by the nonempty paths) is nilpotent: a product of
`n` arrows would be a path of length `≥ n`, which cannot exist.

## Main results

* `Quiver.AcyclicBound.r_add_length_le` — along any path `p : a ⟶ b`,
  `r a + p.length ≤ r b`.
* `Quiver.AcyclicBound.length_lt_of_bounded` — if `r v < n` for all `v`, then
  every path has length `< n`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): "Acyclicity of a finite quiver is equivalent to the
existence of a strictly monotone potential `r : V → ℕ`, and that potential
bounds path length."  Experiment (Experimenter): proved the sharp inequality
`r a + length p ≤ r b` by induction on the path; the `cons` step uses the strict
arrow inequality `r b' < r c`.  Analysis (Analyst): the inequality is sharp on
the linear quiver `A_n` with `r = id`.  Critique (Critic): the result is stated
for an arbitrary potential, so it does not silently assume finiteness; finiteness
only enters when one *produces* a bounded potential, which we expose as the
hypothesis `hbdd`.
-/

namespace Quiver.AcyclicBound

open Quiver

variable {V : Type*} [Quiver V] (r : V → ℕ)

/-
If `r` strictly increases along every arrow, then along any path the potential
grows at least by the length of the path.
-/
theorem r_add_length_le (hr : ∀ {a b : V}, (a ⟶ b) → r a < r b) :
    ∀ {a b : V} (p : Path a b), r a + p.length ≤ r b := by
  intro a b p;
  induction p;
  · simp +decide;
  · rename_i k hk ih;
    exact Nat.succ_le_of_lt ( lt_of_le_of_lt ih ( hr hk ) )

/-
A topological order bounded by `n` forces every path to have length `< n`:
the longest path length is at most `n - 1`.
-/
theorem length_lt_of_bounded {n : ℕ} (hr : ∀ {a b : V}, (a ⟶ b) → r a < r b)
    (hbdd : ∀ v : V, r v < n) {a b : V} (p : Path a b) : p.length < n := by
  have := @Quiver.AcyclicBound.r_add_length_le V _ r hr a b p; linarith [ hbdd a, hbdd b ] ;

end Quiver.AcyclicBound