/-
  # A Functorial Tropical Lower Bound for Rips Connectivity
  ## via Valuation-Depth Sublevel Graphs

  Bridge: connects **metric filtrations / Vietoris–Rips graphs**
  (`Applications/PoincareData/MetricFiltration.lean`) ↔ **tropical (max-plus) valuation
  algebra** (`Bridges/CategoricalTropicalUltrametric.lean`) ↔ **ultrametric / valuation
  depth** (`Computation/PadicValuationDepth.lean`).

  ## Core principle

  In a *general* pseudometric space, two points may become path-connected in the Rips
  graph at scale `ε` even when their distance is much larger than `ε`: connectivity is
  governed by the **bottleneck (tropical) path distance** `min over paths of max edge`,
  which can be far below the true distance. This is the "Archimedean leak": a chain of
  short edges spans a long distance.

  Over an **ultrametric** (= non-Archimedean / valuation) space the strong triangle
  inequality `dist x z ≤ max (dist x y) (dist y z)` plugs this leak completely: the
  bottleneck path distance **equals** the metric distance, so

      `Reachable_ε x y  ↔  dist x y ≤ ε`.

  Hence the **connectivity threshold** `connThreshold x y := dist x y` is the exact
  (tight, tropically certified) scale at which `x` and `y` merge, and — being a metric
  distance on an ultrametric space — it *itself* satisfies the tropical/max inequality.
  This is the "functorial tropical lower bound": the connectivity-threshold functor lands
  in the tropical (max) semiring, and `dist x y` is a *certified lower bound* on any scale
  that can connect `x` to `y`.

  ## Main results

  * `ripsGraph`                       — Rips 1-skeleton at scale `ε` (re-stated, self-contained)
  * `ripsGraph_mono`                  — filtration monotonicity
  * `reachable_mono`                  — functoriality: reachability is monotone in `ε`
  * `dist_le_of_walk_length`          — general (Archimedean) bound: `dist ≤ length · ε`
  * `reachable_dist_le`               — **ultrametric collapse**: reachable ⇒ `dist ≤ ε`
  * `reachable_iff`                   — `Reachable_ε x y ↔ dist x y ≤ ε`
  * `reachableSet_eq_closedBall`      — connectivity classes are closed balls
  * `connThreshold_ultra`             — the threshold functor is tropical (max-subadditive)
  * `rips_connectivity_lower_bound`   — `dist x y` certifies a lower bound on connecting scale

  -- !-- Lab Notes -- !--
  HYPOTHESIS (H1): In an ultrametric space the Rips reachability relation collapses to a
  single sublevel test `dist ≤ ε`.  CONFIRMED below (`reachable_iff`).
  HYPOTHESIS (H2): The connectivity threshold inherits the tropical max-inequality.
  CONFIRMED (`connThreshold_ultra`) — it is literally the strong triangle inequality.
  FAILURE ANALYSIS: the naive statement `Reachable ⇒ dist ≤ ε` is FALSE without `0 ≤ ε`
  (the reflexive walk `x = x` is always reachable yet forces `dist x x = 0 ≤ ε`), and
  FALSE without ultrametricity (chains of short edges, see `dist_le_of_walk_length` which
  is the best general bound). Both hypotheses are therefore load-bearing.
  -- !--
-/
import Mathlib

open Function Metric

noncomputable section

namespace TropicalRipsConnectivity

universe u
variable {α : Type u}

/-! ## §1. The Rips graph (self-contained re-statement) -/

/-- The **Rips graph** (Vietoris–Rips 1-skeleton) at scale `ε`: distinct points are
    adjacent iff within distance `ε`.  Re-stated from
    `Applications/PoincareData/MetricFiltration.lean` so this file builds standalone. -/
def ripsGraph (α : Type u) [PseudoMetricSpace α] (ε : ℝ) : SimpleGraph α where
  Adj x y := x ≠ y ∧ dist x y ≤ ε
  symm x y h := ⟨h.1.symm, by rw [dist_comm]; exact h.2⟩
  loopless := ⟨fun x h => h.1 rfl⟩

variable [PseudoMetricSpace α]

@[simp] lemma ripsGraph_adj_iff {ε : ℝ} {x y : α} :
    (ripsGraph α ε).Adj x y ↔ x ≠ y ∧ dist x y ≤ ε := Iff.rfl

/-- Filtration monotonicity: larger scale ⇒ larger graph. -/
theorem ripsGraph_mono {ε₁ ε₂ : ℝ} (h : ε₁ ≤ ε₂) :
    ripsGraph α ε₁ ≤ ripsGraph α ε₂ := by
  intro x y hxy
  exact ⟨hxy.1, hxy.2.trans h⟩

/-- Functoriality of connectivity: reachability is monotone in the scale. -/
theorem reachable_mono {ε₁ ε₂ : ℝ} (h : ε₁ ≤ ε₂) {x y : α}
    (hr : (ripsGraph α ε₁).Reachable x y) : (ripsGraph α ε₂).Reachable x y :=
  hr.mono (ripsGraph_mono h)

/-! ## §2. The general (Archimedean) bound -/

/-- **General bound.** In an arbitrary pseudometric space, a Rips walk of length `n` from
    `x` to `y` only certifies `dist x y ≤ n · ε`.  This is the "Archimedean leak":
    connectivity does *not* control the true distance.  Note: `0 ≤ ε` is *not* needed —
    if a positive-length edge exists then `ε ≥ dist ≥ 0` automatically. -/
theorem dist_le_of_walk_length {ε : ℝ} {x y : α}
    (p : (ripsGraph α ε).Walk x y) : dist x y ≤ p.length * ε := by
  induction' p with x y hxy p ih;
  · simp +decide;
  · simp +zetaDelta at *;
    linarith [ dist_triangle y hxy p, ih.2 ]

/-! ## §3. The ultrametric collapse -/

variable [IsUltrametricDist α]

/-- **Ultrametric collapse (lower bound).** Over an ultrametric space, *any* Rips walk
    from `x` to `y` at scale `ε` forces `dist x y ≤ ε`: the strong triangle inequality
    makes the bottleneck path distance equal the metric distance. -/
theorem reachable_dist_le {ε : ℝ} (hε : 0 ≤ ε) {x y : α}
    (h : (ripsGraph α ε).Reachable x y) : dist x y ≤ ε := by
  -- By definition of reachability, there exists a walk from $x$ to $y$ in the Rips graph at scale $\epsilon$.
  obtain ⟨p, hp⟩ : ∃ p : (ripsGraph α ε).Walk x y, True := by
    exact ⟨ h.some, trivial ⟩;
  induction' p with x y hxy p ih;
  · simpa using hε;
  · rename_i h₁ h₂;
    exact le_trans ( IsUltrametricDist.dist_triangle_max y hxy p ) ( max_le ih.2 ( h₂ <| h₁.reachable ) )

/-- **Connectivity = sublevel test.** Over an ultrametric space, `x` and `y` are
    Rips-connected at scale `ε` iff `dist x y ≤ ε`. -/
theorem reachable_iff {ε : ℝ} (hε : 0 ≤ ε) {x y : α} :
    (ripsGraph α ε).Reachable x y ↔ dist x y ≤ ε := by
  by_cases hxy : x = y <;> simp +decide [ *, ripsGraph ];
  exact ⟨ fun h => reachable_dist_le hε h, fun h => SimpleGraph.Adj.reachable ( by tauto ) ⟩

/-- The connectivity class of `x` is exactly the closed metric ball of radius `ε`. -/
theorem reachableSet_eq_closedBall {ε : ℝ} (hε : 0 ≤ ε) (x : α) :
    {y | (ripsGraph α ε).Reachable x y} = Metric.closedBall x ε := by
  ext y
  simp only [Set.mem_setOf_eq, Metric.mem_closedBall, reachable_iff hε, dist_comm y x]

/-! ## §4. The tropical connectivity-threshold functor -/

/-- The **connectivity threshold**: the exact scale at which `x` and `y` merge in the
    Rips filtration.  Over an ultrametric space this equals the distance. -/
def connThreshold (x y : α) : ℝ := dist x y

/-- **Functorial tropical lower bound.** The connectivity-threshold functor lands in the
    tropical (max) semiring: it satisfies the strong/tropical triangle inequality. -/
theorem connThreshold_ultra (x y z : α) :
    connThreshold x z ≤ max (connThreshold x y) (connThreshold y z) :=
  dist_triangle_max x y z

/-- `dist x y` is the *least* scale connecting `x` and `y`: it is connected for every
    `ε ≥ dist x y`, and every connecting scale `ε` satisfies `ε ≥ dist x y`.  Hence the
    threshold is a certified, tight lower bound. -/
theorem rips_connectivity_lower_bound {ε : ℝ} (hε : 0 ≤ ε) {x y : α} :
    (ripsGraph α ε).Reachable x y ↔ connThreshold x y ≤ ε := by
  simpa [connThreshold] using reachable_iff (α := α) hε (x := x) (y := y)

end TropicalRipsConnectivity