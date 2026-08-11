import Mathlib
import Novelty.BakryEmeryGraphCore

/-!
# Point-mass consequences of `Γ₂ ≥ 0`

The dimension-free curvature condition `CD(0,∞)` is a statement about *all* functions.
Following the strategy of the paper *Nonnegative Bakry–Émery curvature on bounded-degree
graphs implies volume doubling and Poincaré inequalities* — where "point-mass
consequences of `Γ₂ ≥ 0`" replace any global `CD(0,n)` reduction — we extract explicit
combinatorial information by testing the curvature condition on **Dirac masses**.

The computation is carried out in full: for `x ∼ y` and `δ_x` the point mass at `x`,

  `Γ₂(δ_x, δ_x)(y) = (3 deg x + t(x,y) - deg y + 2) / 4`,

where `t(x,y) = #(N(x) ∩ N(y))` is the number of triangles on the edge `xy`.
Consequently `CD(0,∞)` forces a **local degree comparison**

  `deg y ≤ 3 deg x + t(x,y) + 2 ≤ 4 deg x + 1`   whenever `x ∼ y`,

which propagates along walks to `deg y + 1 ≤ 4^{d(x,y)} (deg x + 1)`.  This is the
quantitative mechanism that makes "bounded degree" a *local* rather than a global
hypothesis, and it rules out e.g. all sufficiently large stars.
-/

namespace BakryEmery

open Finset

variable {V : Type*} [DecidableEq V] {G : SimpleGraph V} [DecidableRel G.Adj]
  [G.LocallyFinite]

/-- The Dirac mass (point mass) at a vertex. -/
noncomputable def pointMass (x : V) : V → ℝ := fun v => if v = x then 1 else 0

/-- Number of triangles supported on the edge `xy`. -/
def triangleCount (G : SimpleGraph V) [DecidableRel G.Adj] [G.LocallyFinite] (x y : V) : ℕ :=
  (G.neighborFinset x ∩ G.neighborFinset y).card

/-! ### The Laplacian and `Γ` of a point mass -/

@[simp] lemma Delta_pointMass_self (x : V) : Delta G (pointMass x) x = -(G.degree x) := by
  simp [Delta, pointMass]

lemma Delta_pointMass_adj {x y : V} (h : G.Adj x y) : Delta G (pointMass x) y = 1 := by
  have hx : x ∈ G.neighborFinset y := by simp [SimpleGraph.mem_neighborFinset, h.symm]
  have hyx : y ≠ x := (G.ne_of_adj h).symm
  simp [Delta, pointMass, hyx, Finset.sum_ite_eq' (G.neighborFinset y) x (fun _ => (1:ℝ)), hx]

lemma Gamma_pointMass_self (x : V) :
    Gamma G (pointMass x) (pointMass x) x = (G.degree x) / 2 := by
  have h : ∀ y ∈ G.neighborFinset x,
      (pointMass x y - pointMass x x) * (pointMass x y - pointMass x x) = 1 := by
    intro y hy
    have hyx : y ≠ x := by
      intro h'
      rw [h'] at hy
      exact (SimpleGraph.notMem_neighborFinset_self G x) hy
    simp [pointMass, hyx]
  rw [Gamma, Finset.sum_congr rfl h]
  simp [SimpleGraph.card_neighborFinset_eq_degree]
  ring

lemma Gamma_pointMass_adj {x y : V} (h : G.Adj x y) :
    Gamma G (pointMass x) (pointMass x) y = 1 / 2 := by
  have hyx : y ≠ x := (G.ne_of_adj h).symm
  have hx : x ∈ G.neighborFinset y := by simp [SimpleGraph.mem_neighborFinset, h.symm]
  have hcongr : ∀ z ∈ G.neighborFinset y,
      (pointMass x z - pointMass x y) * (pointMass x z - pointMass x y)
        = if z = x then (1:ℝ) else 0 := by
    intro z _
    by_cases hz : z = x <;> simp [pointMass, hz, hyx]
  rw [Gamma, Finset.sum_congr rfl hcongr,
    Finset.sum_ite_eq' (G.neighborFinset y) x (fun _ => (1:ℝ))]
  simp [hx]

lemma Gamma_pointMass_far {x v : V} (hne : v ≠ x) (hnadj : ¬ G.Adj v x) :
    Gamma G (pointMass x) (pointMass x) v = 0 := by
  have hcongr : ∀ z ∈ G.neighborFinset v,
      (pointMass x z - pointMass x v) * (pointMass x z - pointMass x v) = 0 := by
    intro z hz
    have hzx : z ≠ x := by
      intro h'
      apply hnadj
      rw [SimpleGraph.mem_neighborFinset] at hz
      rw [← h']
      exact hz
    simp [pointMass, hzx, hne]
  rw [Gamma, Finset.sum_congr rfl hcongr]
  simp

/-- Closed formula for `Γ(δ_x, δ_x)` at every vertex. -/
lemma Gamma_pointMass_apply (x v : V) :
    Gamma G (pointMass x) (pointMass x) v
      = if v = x then (G.degree x : ℝ) / 2 else if G.Adj v x then 1 / 2 else 0 := by
  by_cases hv : v = x
  · subst hv; simp [Gamma_pointMass_self]
  · by_cases hadj : G.Adj v x
    · simp [hv, hadj, Gamma_pointMass_adj hadj.symm]
    · simp [hv, hadj, Gamma_pointMass_far hv hadj]

/-! ### The two `Γ₂` ingredients at a neighbour of `x` -/

lemma Delta_Gamma_pointMass_adj {x y : V} (h : G.Adj x y) :
    Delta G (Gamma G (pointMass x) (pointMass x)) y
      = (G.degree x : ℝ) / 2 + (triangleCount G x y : ℝ) / 2 - (G.degree y : ℝ) / 2 := by
  have hyx : y ≠ x := (G.ne_of_adj h).symm
  have hx : x ∈ G.neighborFinset y := by simp [SimpleGraph.mem_neighborFinset, h.symm]
  have hGy : Gamma G (pointMass x) (pointMass x) y = 1 / 2 := Gamma_pointMass_adj h
  have hsplit : Delta G (Gamma G (pointMass x) (pointMass x)) y
      = (∑ z ∈ G.neighborFinset y, Gamma G (pointMass x) (pointMass x) z)
        - (G.degree y : ℝ) * (1 / 2) := by
    rw [Delta_eq_sum_sub, hGy]
  -- evaluate the sum over the neighbours of `y`
  have hsum : ∑ z ∈ G.neighborFinset y, Gamma G (pointMass x) (pointMass x) z
      = (G.degree x : ℝ) / 2 + (triangleCount G x y : ℝ) / 2 := by
    rw [← Finset.add_sum_erase _ _ hx]
    rw [Gamma_pointMass_self]
    congr 1
    have hcongr : ∀ z ∈ (G.neighborFinset y).erase x,
        Gamma G (pointMass x) (pointMass x) z = if G.Adj z x then (1:ℝ)/2 else 0 := by
      intro z hz
      have hzx : z ≠ x := Finset.ne_of_mem_erase hz
      rw [Gamma_pointMass_apply]
      simp [hzx]
    rw [Finset.sum_congr rfl hcongr, Finset.sum_ite (h := fun z => Classical.dec _)]
    have hfilter : ((G.neighborFinset y).erase x).filter (fun z => G.Adj z x)
        = G.neighborFinset x ∩ G.neighborFinset y := by
      ext z
      simp only [Finset.mem_filter, Finset.mem_erase, Finset.mem_inter,
        SimpleGraph.mem_neighborFinset]
      constructor
      · rintro ⟨⟨_, hzy⟩, hzx⟩
        exact ⟨hzx.symm, hzy.symm⟩
      · rintro ⟨hxz, hyz⟩
        exact ⟨⟨(G.ne_of_adj hxz).symm, hyz.symm⟩, hxz.symm⟩
    simp only [Finset.sum_const, Finset.sum_const_zero, add_zero, nsmul_eq_mul, hfilter]
    rw [triangleCount]
    ring
  rw [hsplit, hsum]
  ring

lemma Gamma_pointMass_Delta_adj {x y : V} (h : G.Adj x y) :
    Gamma G (pointMass x) (Delta G (pointMass x)) y = (-(G.degree x : ℝ) - 1) / 2 := by
  have hyx : y ≠ x := (G.ne_of_adj h).symm
  have hx : x ∈ G.neighborFinset y := by simp [SimpleGraph.mem_neighborFinset, h.symm]
  have hDy : Delta G (pointMass x) y = 1 := Delta_pointMass_adj h
  have hcongr : ∀ z ∈ G.neighborFinset y,
      (pointMass x z - pointMass x y) * (Delta G (pointMass x) z - Delta G (pointMass x) y)
        = if z = x then (-(G.degree x : ℝ) - 1) else 0 := by
    intro z _
    by_cases hz : z = x
    · subst hz
      simp [pointMass, hyx, hDy, Delta_pointMass_self]
    · simp [pointMass, hz, hyx]
  rw [Gamma, Finset.sum_congr rfl hcongr,
    Finset.sum_ite_eq' (G.neighborFinset y) x (fun _ => (-(G.degree x : ℝ) - 1))]
  simp [hx]
  ring

/-- **Point-mass curvature formula.** For adjacent `x ∼ y`, testing `Γ₂` on the Dirac
mass at `x` and evaluating at `y` gives
`Γ₂(δ_x, δ_x)(y) = (3 deg x + t(x,y) - deg y + 2)/4`. -/
theorem Gamma2_pointMass_adj {x y : V} (h : G.Adj x y) :
    Gamma2 G (pointMass x) (pointMass x) y
      = (3 * (G.degree x : ℝ) + (triangleCount G x y : ℝ) - (G.degree y : ℝ) + 2) / 4 := by
  rw [Gamma2_self, Delta_Gamma_pointMass_adj h, Gamma_pointMass_Delta_adj h]
  ring

/-! ### Local degree comparison under `CD(0,∞)` -/

/-- **Local degree bound from nonnegative curvature.**  If `Γ₂ ≥ 0` then the degrees of
adjacent vertices are comparable: `deg y ≤ 3 deg x + t(x,y) + 2`. -/
theorem CD0_degree_bound (hCD : CD0 G) {x y : V} (h : G.Adj x y) :
    (G.degree y : ℝ) ≤ 3 * (G.degree x : ℝ) + (triangleCount G x y : ℝ) + 2 := by
  have := hCD (pointMass x) y
  rw [Gamma2_pointMass_adj h] at this
  linarith

/-- The triangle count on an edge is at most `deg x - 1`. -/
lemma triangleCount_lt_degree {x y : V} (h : G.Adj x y) :
    triangleCount G x y + 1 ≤ G.degree x := by
  have hsub : G.neighborFinset x ∩ G.neighborFinset y ⊆ (G.neighborFinset x).erase y := by
    intro z hz
    rw [Finset.mem_inter] at hz
    rw [Finset.mem_erase]
    refine ⟨?_, hz.1⟩
    intro hzy
    subst hzy
    exact (G.irrefl (SimpleGraph.mem_neighborFinset G z z |>.1 hz.2))
  have hy : y ∈ G.neighborFinset x := by simp [SimpleGraph.mem_neighborFinset, h]
  have hcard : ((G.neighborFinset x).erase y).card + 1 = (G.neighborFinset x).card := by
    rw [Finset.card_erase_of_mem hy]
    have : 1 ≤ (G.neighborFinset x).card := Finset.card_pos.2 ⟨y, hy⟩
    omega
  have := Finset.card_le_card hsub
  rw [triangleCount]
  omega

/-- **Degrees of adjacent vertices are comparable** under `CD(0,∞)`:
`deg y ≤ 4 deg x + 1`. -/
theorem CD0_degree_le_adj (hCD : CD0 G) {x y : V} (h : G.Adj x y) :
    G.degree y ≤ 4 * G.degree x + 1 := by
  have h1 := CD0_degree_bound hCD h
  have h2 : (triangleCount G x y : ℝ) + 1 ≤ (G.degree x : ℝ) := by
    exact_mod_cast triangleCount_lt_degree h
  have : (G.degree y : ℝ) ≤ 4 * (G.degree x : ℝ) + 1 := by linarith
  exact_mod_cast this

/-- Rephrased multiplicatively for the shifted degree `deg + 1`. -/
lemma CD0_succ_degree_le_adj (hCD : CD0 G) {x y : V} (h : G.Adj x y) :
    G.degree y + 1 ≤ 4 * (G.degree x + 1) := by
  have := CD0_degree_le_adj hCD h
  omega

/-- **Geometric degree control along walks.**  Under `CD(0,∞)`, degrees can grow at most
geometrically with the graph distance. -/
theorem CD0_succ_degree_le_walk (hCD : CD0 G) {x y : V} (w : G.Walk x y) :
    G.degree y + 1 ≤ 4 ^ w.length * (G.degree x + 1) := by
  induction w with
  | nil => simp
  | cons h p ih =>
    rename_i u v z hadj
    have hstep := CD0_succ_degree_le_adj hCD hadj
    calc G.degree z + 1 ≤ 4 ^ p.length * (G.degree v + 1) := ih
      _ ≤ 4 ^ p.length * (4 * (G.degree u + 1)) := by
          exact Nat.mul_le_mul_left _ hstep
      _ = 4 ^ (p.length + 1) * (G.degree u + 1) := by ring
      _ = 4 ^ (SimpleGraph.Walk.cons hadj p).length * (G.degree u + 1) := by
          simp [SimpleGraph.Walk.length_cons]

/-- Distance form of the previous bound. -/
theorem CD0_succ_degree_le_dist (hCD : CD0 G) {x y : V} (hr : G.Reachable x y) :
    G.degree y + 1 ≤ 4 ^ (G.dist x y) * (G.degree x + 1) := by
  obtain ⟨w, hw⟩ := hr.exists_walk_length_eq_dist
  have := CD0_succ_degree_le_walk hCD w
  rwa [hw] at this

/-- **Nonvacuity / sharpness test.**  A vertex adjacent to a vertex of degree `1` has
degree at most `5` in a `CD(0,∞)` graph.  In particular no graph containing a leaf
attached to a vertex of degree `≥ 6` (e.g. a star `K_{1,n}` with `n ≥ 6`) can satisfy
`CD(0,∞)`. -/
theorem CD0_degree_le_of_adj_leaf (hCD : CD0 G) {x y : V} (h : G.Adj x y)
    (hx : G.degree x = 1) : G.degree y ≤ 5 := by
  have h1 := CD0_degree_bound hCD h
  have h2 : triangleCount G x y = 0 := by
    have := triangleCount_lt_degree h
    omega
  rw [h2, hx] at h1
  have : (G.degree y : ℝ) ≤ 5 := by push_cast at h1 ⊢; linarith
  exact_mod_cast this

end BakryEmery