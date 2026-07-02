/-
Copyright (c) 2026. All rights reserved.

# Geometric Fractional Chromatic Number: the independence-ratio engine

This file develops, from first principles, the linear-programming lower bound that
drives the Matolcsi–Ruzsa–Varga–Zsámboki (`MRVZ`) programme on the fractional
chromatic number of the plane, following the strategy of de Grey (`deGrey`) and the
classical Erdős framing (`Er87`).

The *geometric fractional chromatic number* of a finite graph `G` is the value of the
covering linear program: assign nonnegative weights to the independent sets so that
every vertex is covered with total weight at least `1`, and minimise the total weight.
We model a feasible point as a `FracColoring` and define `geomFrac G` as the infimum of
the achievable totals.

## Main results

* `FracColoring.card_le_indepNum_mul_total` — the LP-duality core:
  `|V| ≤ α(G) · total(c)` for every feasible fractional coloring `c`,
  where `α(G) = G.indepNum` is the independence number.  This is a genuine
  double-counting / weak-duality argument.
* `geomFrac_ge_ratio` — consequently `|V| / α(G) ≤ geomFrac G`.
* `geomFrac_gt_four_of_indep_ratio` — **the key technical mechanism**: if the
  independence ratio is below `1/4` (i.e. `4 · α(G) < |V|`), then
  `geomFrac G > 4`.  This is exactly the reduction used by `MRVZ`: a finite
  unit-distance graph with independence ratio `< 1/4` has fractional chromatic
  number strictly above `4`, hence so does the plane.
* `geomFrac_le_card` — the trivial singleton coloring gives `geomFrac G ≤ |V|`.

The geometric (unit-distance) instantiation lives in `UnitDistanceFractional.lean`.
-/
import Mathlib

open SimpleGraph Finset
open scoped BigOperators

namespace GeomFrac

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- A feasible point of the fractional-coloring covering LP for `G`:
nonnegative weights supported on independent sets, covering every vertex with
total weight at least `1`. -/
structure FracColoring (G : SimpleGraph V) where
  /-- Weight assigned to each finite set of vertices. -/
  weight : Finset V → ℝ
  /-- Weights are nonnegative. -/
  nonneg : ∀ S, 0 ≤ weight S
  /-- Only independent sets may carry positive weight. -/
  supp : ∀ S : Finset V, ¬ G.IsIndepSet (S : Set V) → weight S = 0
  /-- Every vertex is covered with total weight at least `1`. -/
  covers : ∀ v : V, 1 ≤ ∑ S ∈ univ.filter (fun S => v ∈ S), weight S

namespace FracColoring

variable {G : SimpleGraph V}

/-- The total weight of a fractional coloring, i.e. the LP objective. -/
noncomputable def total (c : FracColoring G) : ℝ := ∑ S : Finset V, c.weight S

lemma total_nonneg (c : FracColoring G) : 0 ≤ c.total :=
  Finset.sum_nonneg (fun S _ => c.nonneg S)

/-- Double counting the incidences between vertices and weighted sets. -/
lemma double_count (c : FracColoring G) :
    ∑ v : V, ∑ S ∈ univ.filter (fun S => v ∈ S), c.weight S
      = ∑ S : Finset V, (S.card : ℝ) * c.weight S := by
  have h1 : ∀ v : V, ∑ S ∈ univ.filter (fun S => v ∈ S), c.weight S
      = ∑ S : Finset V, (if v ∈ S then c.weight S else 0) := by
    intro v; rw [Finset.sum_filter]
  simp_rw [h1]
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl (fun S _ => ?_)
  have hf : Finset.filter (fun x => x ∈ S) univ = S := by ext x; simp
  rw [Finset.sum_ite, Finset.sum_const_zero, add_zero, hf, Finset.sum_const, nsmul_eq_mul]

/-- **LP weak-duality core.**  For every feasible fractional coloring `c`,
`|V| ≤ α(G) · total(c)`.  The independence number `α(G)` bounds the size of any
weighted (independent) set, so the covering constraints force the objective up. -/
theorem card_le_indepNum_mul_total (c : FracColoring G) :
    (Fintype.card V : ℝ) ≤ (G.indepNum : ℝ) * c.total := by
  have hcov : (Fintype.card V : ℝ)
      ≤ ∑ v : V, ∑ S ∈ univ.filter (fun S => v ∈ S), c.weight S := by
    have hcard : (Fintype.card V : ℝ) = ∑ _v : V, (1 : ℝ) := by
      simp [Finset.card_univ]
    rw [hcard]
    exact Finset.sum_le_sum (fun v _ => c.covers v)
  rw [c.double_count] at hcov
  refine hcov.trans ?_
  have hterm : ∀ S ∈ (univ : Finset (Finset V)),
      (S.card : ℝ) * c.weight S ≤ (G.indepNum : ℝ) * c.weight S := by
    intro S _
    by_cases hS : G.IsIndepSet (S : Set V)
    · have hle : S.card ≤ G.indepNum := hS.card_le_indepNum
      exact mul_le_mul_of_nonneg_right (by exact_mod_cast hle) (c.nonneg S)
    · rw [c.supp S hS]; simp
  calc ∑ S : Finset V, (S.card : ℝ) * c.weight S
      ≤ ∑ S : Finset V, (G.indepNum : ℝ) * c.weight S := Finset.sum_le_sum hterm
    _ = (G.indepNum : ℝ) * c.total := by rw [total, Finset.mul_sum]

/-- The singleton fractional coloring: weight `1` on every one-element (independent)
set and `0` elsewhere.  This witnesses feasibility of the LP. -/
noncomputable def singleton (G : SimpleGraph V) : FracColoring G where
  weight S := if S.card = 1 then 1 else 0
  nonneg S := by split <;> norm_num
  supp S hS := by
    split
    · rename_i h
      rw [Finset.card_eq_one] at h
      obtain ⟨a, rfl⟩ := h
      exact absurd (by simp [SimpleGraph.IsIndepSet]) hS
    · rfl
  covers v := by
    refine (Finset.single_le_sum (f := fun S : Finset V => if S.card = 1 then (1 : ℝ) else 0)
      (fun S _ => by dsimp only; split <;> norm_num) (a := {v}) (by simp)).trans_eq' ?_
    simp

lemma singleton_total : (singleton G).total = (Fintype.card V : ℝ) := by
  rw [total, singleton]
  show (∑ S : Finset V, if S.card = 1 then (1 : ℝ) else 0) = _
  rw [Finset.sum_ite, Finset.sum_const_zero, add_zero, Finset.sum_const, nsmul_eq_mul, mul_one]
  have hset : (univ.filter (fun S : Finset V => S.card = 1)) = Finset.powersetCard 1 univ := by
    ext S; simp [Finset.mem_powersetCard]
  rw [hset, Finset.card_powersetCard]
  simp [Finset.card_univ]

end FracColoring

omit [DecidableEq V] in
/-- A nonempty vertex set always has a nonempty independent set (any singleton). -/
lemma indepNum_pos [Nonempty V] (G : SimpleGraph V) : 0 < G.indepNum := by
  obtain ⟨v⟩ := (inferInstance : Nonempty V)
  have hind : G.IsIndepSet (({v} : Finset V) : Set V) := by
    simp [SimpleGraph.IsIndepSet]
  have h1 : ({v} : Finset V).card ≤ G.indepNum := hind.card_le_indepNum
  simpa using h1

/-- The **geometric fractional chromatic number** of a finite graph: the infimum of the
total weight over all feasible fractional colorings. -/
noncomputable def geomFrac (G : SimpleGraph V) : ℝ :=
  sInf (Set.range (fun c : FracColoring G => c.total))

lemma geomFrac_bddBelow (G : SimpleGraph V) :
    BddBelow (Set.range (fun c : FracColoring G => c.total)) := by
  refine ⟨0, ?_⟩
  rintro x ⟨c, rfl⟩
  exact c.total_nonneg

lemma geomFrac_range_nonempty (G : SimpleGraph V) :
    (Set.range (fun c : FracColoring G => c.total)).Nonempty :=
  ⟨_, Set.mem_range_self (FracColoring.singleton G)⟩

/-- The singleton coloring gives the easy upper bound `geomFrac G ≤ |V|`. -/
theorem geomFrac_le_card (G : SimpleGraph V) : geomFrac G ≤ (Fintype.card V : ℝ) := by
  have hmem : (Fintype.card V : ℝ) ∈ Set.range (fun c : FracColoring G => c.total) := by
    exact ⟨FracColoring.singleton G, FracColoring.singleton_total⟩
  exact csInf_le (geomFrac_bddBelow G) hmem

/-- `geomFrac G ≥ 0`. -/
theorem geomFrac_nonneg (G : SimpleGraph V) : 0 ≤ geomFrac G :=
  le_csInf (geomFrac_range_nonempty G) (by rintro x ⟨c, rfl⟩; exact c.total_nonneg)

/-- **Independence-ratio lower bound.**  If `α(G) > 0` then `|V| / α(G) ≤ geomFrac G`. -/
theorem geomFrac_ge_ratio (G : SimpleGraph V) (hα : 0 < G.indepNum) :
    (Fintype.card V : ℝ) / (G.indepNum : ℝ) ≤ geomFrac G := by
  have hαR : (0 : ℝ) < (G.indepNum : ℝ) := by exact_mod_cast hα
  refine le_csInf (geomFrac_range_nonempty G) ?_
  rintro x ⟨c, rfl⟩
  rw [div_le_iff₀ hαR, mul_comm]
  exact c.card_le_indepNum_mul_total

/-- **The key technical mechanism (MRVZ reduction).**  A finite graph whose
independence ratio is below `1/4` — equivalently `4 · α(G) < |V|` — has geometric
fractional chromatic number strictly greater than `4`.

Applied to a unit-distance graph, this is precisely the statement that a finite
unit-distance graph with independence ratio `< 1/4` certifies that the fractional
chromatic number of the plane exceeds `4`. -/
theorem geomFrac_gt_four_of_indep_ratio (G : SimpleGraph V)
    (h : 4 * G.indepNum < Fintype.card V) : 4 < geomFrac G := by
  have hcard : 0 < Fintype.card V := lt_of_le_of_lt (Nat.zero_le _) h
  have : Nonempty V := Fintype.card_pos_iff.mp hcard
  have hα : 0 < G.indepNum := indepNum_pos G
  have hαR : (0 : ℝ) < (G.indepNum : ℝ) := by exact_mod_cast hα
  have hstrict : (4 : ℝ) < (Fintype.card V : ℝ) / (G.indepNum : ℝ) := by
    rw [lt_div_iff₀ hαR]
    have : (4 : ℝ) * (G.indepNum : ℝ) < (Fintype.card V : ℝ) := by exact_mod_cast h
    linarith
  exact lt_of_lt_of_le hstrict (geomFrac_ge_ratio G hα)

/-- Generalisation to any threshold `k`: independence ratio below `1/k` forces
`geomFrac G > k`. -/
theorem geomFrac_gt_of_indep_ratio (G : SimpleGraph V) (k : ℕ)
    (h : k * G.indepNum < Fintype.card V) : (k : ℝ) < geomFrac G := by
  have hcard : 0 < Fintype.card V := lt_of_le_of_lt (Nat.zero_le _) h
  have : Nonempty V := Fintype.card_pos_iff.mp hcard
  have hα : 0 < G.indepNum := indepNum_pos G
  have hαR : (0 : ℝ) < (G.indepNum : ℝ) := by exact_mod_cast hα
  have hstrict : (k : ℝ) < (Fintype.card V : ℝ) / (G.indepNum : ℝ) := by
    rw [lt_div_iff₀ hαR]
    have : (k : ℝ) * (G.indepNum : ℝ) < (Fintype.card V : ℝ) := by exact_mod_cast h
    linarith
  exact lt_of_lt_of_le hstrict (geomFrac_ge_ratio G hα)

end GeomFrac

/-!
-- !-- Lab Notes -- !--

**Hypothesis (Hypothesizer).**  The Matolcsi–Ruzsa–Varga–Zsámboki bound
"`χ_f(plane) > 4`" is not really a plane statement: it is a *finite* statement about
one unit-distance graph with independence ratio below `1/4`.  Conjecture: the entire
plane-to-graph reduction is captured by the single inequality
`geomFrac G ≥ |V| / α(G)`, so that `4·α(G) < |V|` alone forces `geomFrac G > 4`.

**Experiment (Experimenter).**  We modelled the covering LP by `FracColoring` and
proved the weak-duality inequality `|V| ≤ α(G)·total(c)` by double counting
vertex–set incidences (`double_count`, `card_le_indepNum_mul_total`).  Taking the
infimum over feasible points gave `geomFrac_ge_ratio`, and the strict corollary
`geomFrac_gt_four_of_indep_ratio` followed by real arithmetic.

**Analysis (Analyst).**  The proof needs only: (i) independent sets have size `≤ α`;
(ii) the covering constraints; (iii) nonnegativity.  No geometry enters the engine —
geometry only supplies a graph `G` with `4·α(G) < |V|`.  The singleton coloring shows
feasibility and gives `geomFrac ≤ |V|`, so the LP value is finite and the infimum is
well posed.

**Critique (Critic).**  Is the statement vacuous?  No: `geomFrac_le_card` shows the
feasible set is nonempty and the value is a real infimum, and
`geomFrac_gt_four_of_indep_ratio` is discharged by genuine arithmetic (`linarith`,
`div_le_iff₀`), not `decide`.  The hypothesis `4·α(G) < |V|` is exactly the MRVZ
independence-ratio condition and is not always satisfiable (it fails for bipartite
graphs, where `α ≥ |V|/2`), so the theorem is not trivially true.

**Synthesis (PI).**  The engine is domain-free and reusable.  The geometric payload —
building `G` with small independence ratio from unit distances — is isolated in
`UnitDistanceFractional.lean`.
-/