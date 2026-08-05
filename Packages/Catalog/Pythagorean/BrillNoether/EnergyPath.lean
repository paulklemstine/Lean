/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Catalog.Pythagorean.BrillNoether.EnergyCovering

/-!
# From the energy form to the sup norm: the path (Cauchy–Schwarz) bridge

`Catalog/Pythagorean/BrillNoether/EnergyCovering.lean` studies the energy
(Dirichlet) form `E(x) = ∑_{i ∼ j} (x i - x j)²` of a finite graph, and
`Catalog/Pythagorean/BrillNoether/Divisors.lean` derives Brill–Noether existence
from an `ℓ^∞` covering bound for the Laplacian lattice.  The missing link between
the two is the elementary inequality

`(x u - x w)² ≤ dist(u, w) · E(x)`,

obtained by applying Cauchy–Schwarz to the telescoping sum of the increments of
`x` along a shortest path from `u` to `w`.  This file proves that inequality and
deduces that a vector of mean zero is bounded in sup norm by
`√(diam · E(x))`, which is exactly the step converting an energy-metric covering
radius into an `ℓ^∞` covering radius.

The only nontrivial point is that the increments must not be double counted: the
`dist(u, w)` steps of a *path* are pairwise distinct ordered pairs of adjacent
vertices, and none of them is the reverse of another (a path never repeats a
vertex).  This is packaged in `sum_pairs_le_energy`.

## Main results

* `BrillNoetherEnergyPath.sum_pairs_le_energy` — if `P` is a set of adjacent
  ordered pairs containing no pair together with its reverse, then
  `∑_{(a,b) ∈ P} (x a - x b)² ≤ E(x)`.
* `BrillNoetherEnergyPath.sq_sub_le_dist_mul_energy` — the bridge
  `(x u - x w)² ≤ dist(u, w) · E(x)`.
* `BrillNoetherEnergyPath.abs_sub_le_sqrt_dist_mul_energy` — its square-root form.
* `BrillNoetherEnergyPath.abs_le_sqrt_of_sum_eq_zero` — a vector of mean zero
  satisfies `|x u| ≤ √(d · E(x))` whenever `d` bounds all distances; combined with
  a small energy distance to the Laplacian lattice this produces an `ℓ^∞` covering
  bound.
-/

open Finset BrillNoetherEnergy

namespace BrillNoetherEnergyPath

variable {V : Type*} [Fintype V] [DecidableEq V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-! ## Sums of squared increments over sets of adjacent pairs -/

omit [DecidableEq V] in
/-- Summing the squared increments over any set of adjacent ordered pairs is
bounded by twice the energy. -/
theorem sum_pairs_le_two_mul_energy (x : V → ℝ) (P : Finset (V × V))
    (hP : ∀ p ∈ P, G.Adj p.1 p.2) :
    ∑ p ∈ P, (x p.1 - x p.2) ^ 2 ≤ 2 * energy G x := by
  classical
  have hsub : P ⊆ univ.filter (fun p : V × V => G.Adj p.1 p.2) := by
    intro p hp
    simp only [Finset.mem_filter, Finset.mem_univ, true_and]
    exact hP p hp
  have hall : ∑ p ∈ univ.filter (fun p : V × V => G.Adj p.1 p.2), (x p.1 - x p.2) ^ 2
      = 2 * energy G x := by
    rw [Finset.sum_filter, Fintype.sum_prod_type, energy]
    ring
  calc ∑ p ∈ P, (x p.1 - x p.2) ^ 2
      ≤ ∑ p ∈ univ.filter (fun p : V × V => G.Adj p.1 p.2), (x p.1 - x p.2) ^ 2 :=
        Finset.sum_le_sum_of_subset_of_nonneg hsub (fun p _ _ => by positivity)
    _ = 2 * energy G x := hall

/-- If moreover no pair of `P` occurs together with its reverse, the bound improves
to the energy itself. -/
theorem sum_pairs_le_energy (x : V → ℝ) (P : Finset (V × V))
    (hP : ∀ p ∈ P, G.Adj p.1 p.2) (hswap : ∀ p ∈ P, (p.2, p.1) ∉ P) :
    ∑ p ∈ P, (x p.1 - x p.2) ^ 2 ≤ energy G x := by
  classical
  set Q : Finset (V × V) := P.image Prod.swap with hQ
  have hQsum : ∑ p ∈ Q, (x p.1 - x p.2) ^ 2 = ∑ p ∈ P, (x p.1 - x p.2) ^ 2 := by
    rw [hQ, Finset.sum_image (fun a _ b _ h => Prod.swap_injective h)]
    refine Finset.sum_congr rfl fun p _ => ?_
    simp only [Prod.fst_swap, Prod.snd_swap]
    ring
  have hdisj : Disjoint P Q := by
    refine Finset.disjoint_left.mpr fun p hp hpQ => ?_
    rw [hQ, Finset.mem_image] at hpQ
    obtain ⟨r, hr, hrp⟩ := hpQ
    have : r = (p.2, p.1) := by
      rw [← hrp]; simp
    rw [this] at hr
    exact hswap p hp hr
  have hunion : ∀ p ∈ P ∪ Q, G.Adj p.1 p.2 := by
    intro p hp
    rcases Finset.mem_union.mp hp with h | h
    · exact hP p h
    · rw [hQ, Finset.mem_image] at h
      obtain ⟨r, hr, hrp⟩ := h
      have := hP r hr
      rw [← hrp]
      simpa using this.symm
  have hbound := sum_pairs_le_two_mul_energy G x (P ∪ Q) hunion
  rw [Finset.sum_union hdisj, hQsum] at hbound
  linarith

/-! ## The path bridge -/

/-- **Energy controls increments along shortest paths.**  For every vector `x` and
all vertices `u`, `w` of a connected graph,
`(x u - x w)² ≤ dist(u, w) · E(x)`. -/
theorem sq_sub_le_dist_mul_energy (hG : G.Connected) (x : V → ℝ) (u w : V) :
    (x u - x w) ^ 2 ≤ (G.dist u w : ℝ) * energy G x := by
  classical
  -- a shortest path from `u` to `w`
  obtain ⟨p, hp⟩ := hG.exists_walk_length_eq_dist u w
  set q := p.bypass with hq
  have hqpath : q.IsPath := p.bypass_isPath
  have hqlen : q.length = G.dist u w := by
    have h1 : q.length ≤ p.length := SimpleGraph.Walk.length_bypass_le p
    have h2 : G.dist u w ≤ q.length := SimpleGraph.dist_le _
    omega
  have hinj2 : ∀ a b : ℕ, a ≤ q.length → b ≤ q.length →
      q.getVert a = q.getVert b → a = b := fun a b ha hb h =>
    hqpath.getVert_injOn ha hb h
  -- the increments telescope
  have htel : ∑ i ∈ range q.length, (x (q.getVert i) - x (q.getVert (i + 1))) = x u - x w := by
    have h := Finset.sum_range_sub' (fun i => x (q.getVert i)) q.length
    rw [h]
    simp
  -- the steps of a path are distinct ordered pairs, none the reverse of another
  set P : Finset (V × V) :=
    (range q.length).image (fun i => (q.getVert i, q.getVert (i + 1))) with hPdef
  have hinj : Set.InjOn (fun i => (q.getVert i, q.getVert (i + 1)))
      (↑(range q.length) : Set ℕ) := by
    intro i hi j hj hij
    simp only [Finset.coe_range, Set.mem_Iio] at hi hj
    exact hinj2 i j (le_of_lt hi) (le_of_lt hj) (congrArg Prod.fst hij)
  have hsumP : ∑ pr ∈ P, (x pr.1 - x pr.2) ^ 2
      = ∑ i ∈ range q.length, (x (q.getVert i) - x (q.getVert (i + 1))) ^ 2 := by
    rw [hPdef, Finset.sum_image hinj]
  have hPadj : ∀ pr ∈ P, G.Adj pr.1 pr.2 := by
    intro pr hpr
    rw [hPdef, Finset.mem_image] at hpr
    obtain ⟨i, hi, rfl⟩ := hpr
    exact q.adj_getVert_succ (Finset.mem_range.mp hi)
  have hPswap : ∀ pr ∈ P, (pr.2, pr.1) ∉ P := by
    intro pr hpr hcon
    rw [hPdef, Finset.mem_image] at hpr hcon
    obtain ⟨i, hi, rfl⟩ := hpr
    obtain ⟨j, hj, hj2⟩ := hcon
    have hiL : i < q.length := Finset.mem_range.mp hi
    have hjL : j < q.length := Finset.mem_range.mp hj
    have e1 : q.getVert j = q.getVert (i + 1) := congrArg Prod.fst hj2
    have e2 : q.getVert (j + 1) = q.getVert i := congrArg Prod.snd hj2
    have h1 : j = i + 1 := hinj2 j (i + 1) (le_of_lt hjL) hiL e1
    have h2 : j + 1 = i := hinj2 (j + 1) i hjL (le_of_lt hiL) e2
    omega
  -- Cauchy–Schwarz along the path
  have hcs : (∑ i ∈ range q.length, (x (q.getVert i) - x (q.getVert (i + 1)))) ^ 2
      ≤ (q.length : ℝ) * ∑ i ∈ range q.length,
          (x (q.getVert i) - x (q.getVert (i + 1))) ^ 2 := by
    have h := sq_sum_le_card_mul_sum_sq (s := range q.length)
      (f := fun i => x (q.getVert i) - x (q.getVert (i + 1)))
    simpa using h
  have hstep : ∑ i ∈ range q.length, (x (q.getVert i) - x (q.getVert (i + 1))) ^ 2
      ≤ energy G x := by
    rw [← hsumP]
    exact sum_pairs_le_energy G x P hPadj hPswap
  have hLnn : (0 : ℝ) ≤ (q.length : ℝ) := Nat.cast_nonneg _
  calc (x u - x w) ^ 2
      = (∑ i ∈ range q.length, (x (q.getVert i) - x (q.getVert (i + 1)))) ^ 2 := by rw [htel]
    _ ≤ (q.length : ℝ) * ∑ i ∈ range q.length,
          (x (q.getVert i) - x (q.getVert (i + 1))) ^ 2 := hcs
    _ ≤ (q.length : ℝ) * energy G x := mul_le_mul_of_nonneg_left hstep hLnn
    _ = (G.dist u w : ℝ) * energy G x := by rw [hqlen]

/-- The square-root form of the bridge: `|x u - x w| ≤ √(dist(u, w) · E(x))`. -/
theorem abs_sub_le_sqrt_dist_mul_energy (hG : G.Connected) (x : V → ℝ) (u w : V) :
    |x u - x w| ≤ Real.sqrt ((G.dist u w : ℝ) * energy G x) :=
  Real.abs_le_sqrt (sq_sub_le_dist_mul_energy G hG x u w)

/-- **From energy to sup norm.**  If `d` bounds all distances in a connected graph
(for instance `d = diam G`), then every vector of mean zero satisfies
`|x u| ≤ √(d · E(x))` at every vertex.  This converts a covering radius measured in
the energy metric into one measured in the `ℓ^∞` metric. -/
theorem abs_le_sqrt_of_sum_eq_zero [Nonempty V] (hG : G.Connected) {d : ℕ}
    (hd : ∀ a b : V, G.dist a b ≤ d) (x : V → ℝ) (hx : ∑ v, x v = 0) (u : V) :
    |x u| ≤ Real.sqrt ((d : ℝ) * energy G x) := by
  classical
  have hn : (0 : ℝ) < (Fintype.card V : ℝ) := by
    exact_mod_cast Fintype.card_pos
  have hbound : ∀ w : V, |x u - x w| ≤ Real.sqrt ((d : ℝ) * energy G x) := by
    intro w
    refine Real.abs_le_sqrt (le_trans (sq_sub_le_dist_mul_energy G hG x u w) ?_)
    have h1 : (G.dist u w : ℝ) ≤ (d : ℝ) := by exact_mod_cast hd u w
    exact mul_le_mul_of_nonneg_right h1 (energy_nonneg G x)
  have hsum : (Fintype.card V : ℝ) * x u = ∑ w : V, (x u - x w) := by
    rw [Finset.sum_sub_distrib, hx]
    simp [Finset.card_univ, mul_comm]
  have h2 : |(Fintype.card V : ℝ) * x u| ≤ (Fintype.card V : ℝ) *
      Real.sqrt ((d : ℝ) * energy G x) := by
    rw [hsum]
    calc |∑ w : V, (x u - x w)| ≤ ∑ w : V, |x u - x w| := Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ _w : V, Real.sqrt ((d : ℝ) * energy G x) :=
          Finset.sum_le_sum fun w _ => hbound w
      _ = (Fintype.card V : ℝ) * Real.sqrt ((d : ℝ) * energy G x) := by
          simp [Finset.card_univ, mul_comm]
  rw [abs_mul, abs_of_pos hn] at h2
  exact le_of_mul_le_mul_left h2 hn

end BrillNoetherEnergyPath