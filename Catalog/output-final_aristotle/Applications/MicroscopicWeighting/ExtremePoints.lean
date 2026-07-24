import Catalog.Applications.MicroscopicWeighting.Examples

/-!
# Geometric tie-in: sign of `μ` versus extreme points

For two Euclidean configurations we verify, in full, the research statement
"the microscopic weighting `μ` has `μ(x) > 0` iff `x` is an extreme point
(vertex) of `conv X`, and `μ(x) ≤ 0` at every non-extreme point."

* **Three collinear points** `X = {0,1,2} ⊆ ℝ`: `μ = (½, 0, ½)`. The endpoints
  are extreme points of `conv X = [0,2]` (positive weight); the midpoint is not
  (weight `0`).
* **Square `{(±1,±1)}` plus its centre** `⊆ ℝ²`: the centre is *not* an extreme
  point of the convex hull and receives a *negative* weight; each of the four
  vertices *is* an extreme point and receives a *positive* weight.

The weightings and their signs were established in `Examples.lean`; here we prove
the geometric half and assemble the equivalence.
-/

namespace MicroWeighting

open Set

/-! ## Three collinear points -/

/-- `conv {0,1,2} ⊆ [0,2]`. -/
theorem collinear_hull_subset :
    convexHull ℝ ({0, 1, 2} : Set ℝ) ⊆ Set.Icc (0:ℝ) 2 := by
  apply convexHull_min
  · intro x hx
    simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at hx
    rcases hx with h | h | h <;> subst h <;> constructor <;> norm_num
  · exact convex_Icc 0 2

/-- The endpoint `0` is an extreme point of `conv {0,1,2}`. -/
theorem collinear_zero_extreme :
    (0:ℝ) ∈ Set.extremePoints ℝ (convexHull ℝ ({0, 1, 2} : Set ℝ)) := by
  rw [mem_extremePoints]
  refine ⟨subset_convexHull ℝ _ (by simp), ?_⟩
  intro x1 hx1 x2 hx2 hmem
  have h1 := collinear_hull_subset hx1
  have h2 := collinear_hull_subset hx2
  rw [openSegment] at hmem
  obtain ⟨a, b, ha, hb, _, hx⟩ := hmem
  simp only [smul_eq_mul] at hx
  constructor <;> nlinarith [mul_nonneg ha.le h1.1, mul_nonneg hb.le h2.1]

/-- The endpoint `2` is an extreme point of `conv {0,1,2}`. -/
theorem collinear_two_extreme :
    (2:ℝ) ∈ Set.extremePoints ℝ (convexHull ℝ ({0, 1, 2} : Set ℝ)) := by
  rw [mem_extremePoints]
  refine ⟨subset_convexHull ℝ _ (by norm_num), ?_⟩
  intro x1 hx1 x2 hx2 hmem
  have h1 := collinear_hull_subset hx1
  have h2 := collinear_hull_subset hx2
  rw [openSegment] at hmem
  obtain ⟨a, b, ha, hb, _, hx⟩ := hmem
  simp only [smul_eq_mul] at hx
  constructor <;>
    nlinarith [mul_nonneg ha.le (by linarith [h1.2] : (0:ℝ) ≤ 2 - x1),
      mul_nonneg hb.le (by linarith [h2.2] : (0:ℝ) ≤ 2 - x2)]

/-- The middle point `1` is **not** an extreme point of `conv {0,1,2}`: it is the
midpoint of the two endpoints. -/
theorem collinear_one_not_extreme :
    (1:ℝ) ∉ Set.extremePoints ℝ (convexHull ℝ ({0, 1, 2} : Set ℝ)) := by
  rw [mem_extremePoints]
  push_neg
  intro _
  refine ⟨0, subset_convexHull ℝ _ (by simp), 2, subset_convexHull ℝ _ (by norm_num),
    ?_, by norm_num⟩
  rw [openSegment_eq_Ioo (by norm_num)]
  constructor <;> norm_num

/-- **Sign characterisation for three collinear points.** With `μ = (½, 0, ½)`
(index `k` ↔ point `k`): a coordinate of `μ` is strictly positive exactly at the
vertices of `conv X`, and non-positive at the interior point. -/
theorem collinear_sign_characterisation :
    ((0:ℝ) ∈ Set.extremePoints ℝ (convexHull ℝ ({0, 1, 2} : Set ℝ)) ∧
        0 < (![1/2, 0, 1/2] : Fin 3 → ℝ) 0) ∧
    ((1:ℝ) ∉ Set.extremePoints ℝ (convexHull ℝ ({0, 1, 2} : Set ℝ)) ∧
        (![1/2, 0, 1/2] : Fin 3 → ℝ) 1 ≤ 0) ∧
    ((2:ℝ) ∈ Set.extremePoints ℝ (convexHull ℝ ({0, 1, 2} : Set ℝ)) ∧
        0 < (![1/2, 0, 1/2] : Fin 3 → ℝ) 2) := by
  obtain ⟨s0, s1, s2⟩ := collinear_signs
  exact ⟨⟨collinear_zero_extreme, s0⟩, ⟨collinear_one_not_extreme, s1⟩,
    ⟨collinear_two_extreme, s2⟩⟩

/-! ## Square with centre (the negative-weight configuration) -/

/-- The five points: the centre `(0,0)` and the four square vertices `(±1,±1)`. -/
def sqPts : Set (ℝ × ℝ) := {(0, 0), (1, 1), (1, -1), (-1, 1), (-1, -1)}

/-- The convex hull of the five points lies in the box `[-1,1]²`. -/
theorem sq_hull_subset :
    convexHull ℝ sqPts ⊆ Set.Icc ((-1, -1) : ℝ × ℝ) (1, 1) := by
  apply convexHull_min
  · intro x hx
    simp only [sqPts, Set.mem_insert_iff, Set.mem_singleton_iff] at hx
    rcases hx with h | h | h | h | h <;> subst h <;> constructor <;> constructor <;> norm_num
  · exact convex_Icc _ _

/-- Pinning lemma: if `a·x + b·y = ε` with `ε = ±1`, `a,b > 0`, `a+b = 1`, and
both `ε·x, ε·y ≤ 1`, then `x = y = ε`. This expresses that a vertex of the box
`[-1,1]²` cannot lie in the open segment of two of its points unless both equal
it. -/
theorem pin_vertex {ε a b x y : ℝ} (ha : 0 < a) (hb : 0 < b) (hab : a + b = 1)
    (hε : ε = 1 ∨ ε = -1) (hx : a * x + b * y = ε)
    (hxb : ε * x ≤ 1) (hyb : ε * y ≤ 1) : x = ε ∧ y = ε := by
  have hε2 : ε * ε = 1 := by rcases hε with h | h <;> subst h <;> norm_num
  have key : a * (ε * x) + b * (ε * y) = 1 := by
    have h : a * (ε * x) + b * (ε * y) = ε * (a * x + b * y) := by ring
    rw [h, hx, hε2]
  have hex : ε * x = 1 := le_antisymm hxb (by nlinarith [key, hyb])
  have hey : ε * y = 1 := le_antisymm hyb (by nlinarith [key, hxb])
  exact ⟨by rcases hε with h | h <;> subst h <;> nlinarith [hex],
    by rcases hε with h | h <;> subst h <;> nlinarith [hey]⟩

/-- The centre `(0,0)` is **not** an extreme point of the convex hull: it is the
midpoint of the diagonal vertices `(1,1)` and `(-1,-1)`. -/
theorem sq_centre_not_extreme :
    ((0, 0) : ℝ × ℝ) ∉ Set.extremePoints ℝ (convexHull ℝ sqPts) := by
  rw [mem_extremePoints]
  push_neg
  intro _
  refine ⟨(1, 1), subset_convexHull ℝ _ (by simp [sqPts]), (-1, -1),
    subset_convexHull ℝ _ (by simp [sqPts]), ?_, by simp⟩
  exact ⟨1 / 2, 1 / 2, by norm_num, by norm_num, by norm_num, by simp⟩

/-- Every square vertex `(±1,±1)` is an extreme point of the convex hull. -/
theorem sq_vertex_extreme (p : ℝ × ℝ) (hp : p ∈ sqPts) (hne : p ≠ (0, 0)) :
    p ∈ Set.extremePoints ℝ (convexHull ℝ sqPts) := by
  rw [mem_extremePoints]
  refine ⟨subset_convexHull ℝ _ hp, ?_⟩
  intro x1 hx1 x2 hx2 hmem
  have h1 := sq_hull_subset hx1
  have h2 := sq_hull_subset hx2
  rw [Set.mem_Icc, Prod.le_def, Prod.le_def] at h1 h2
  obtain ⟨⟨hl11, hl12⟩, hu11, hu12⟩ := h1
  obtain ⟨⟨hl21, hl22⟩, hu21, hu22⟩ := h2
  rw [openSegment] at hmem
  obtain ⟨a, b, ha, hb, hab, hx⟩ := hmem
  rw [Prod.ext_iff] at hx
  obtain ⟨hxa, hxb⟩ := hx
  simp only [Prod.fst_add, Prod.snd_add, Prod.smul_fst, Prod.smul_snd, smul_eq_mul] at hxa hxb
  simp only [sqPts, Set.mem_insert_iff, Set.mem_singleton_iff] at hp
  rcases hp with h | h | h | h | h
  · exact absurd h hne
  all_goals subst h
  · have c1 := pin_vertex ha hb hab (Or.inl rfl) hxa (by linarith) (by linarith)
    have c2 := pin_vertex ha hb hab (Or.inl rfl) hxb (by linarith) (by linarith)
    exact ⟨Prod.ext c1.1 c2.1, Prod.ext c1.2 c2.2⟩
  · have c1 := pin_vertex ha hb hab (Or.inl rfl) hxa (by linarith) (by linarith)
    have c2 := pin_vertex ha hb hab (Or.inr rfl) hxb (by linarith) (by linarith)
    exact ⟨Prod.ext c1.1 c2.1, Prod.ext c1.2 c2.2⟩
  · have c1 := pin_vertex ha hb hab (Or.inr rfl) hxa (by linarith) (by linarith)
    have c2 := pin_vertex ha hb hab (Or.inl rfl) hxb (by linarith) (by linarith)
    exact ⟨Prod.ext c1.1 c2.1, Prod.ext c1.2 c2.2⟩
  · have c1 := pin_vertex ha hb hab (Or.inr rfl) hxa (by linarith) (by linarith)
    have c2 := pin_vertex ha hb hab (Or.inr rfl) hxb (by linarith) (by linarith)
    exact ⟨Prod.ext c1.1 c2.1, Prod.ext c1.2 c2.2⟩

/-- **Sign characterisation for the square-plus-centre configuration.**

* the interior centre gets a **negative** weight and is **not** an extreme point;
* every non-centre index gets a **positive** weight;
* every non-centre point of the configuration **is** an extreme point of the hull.

This is the two-dimensional instance of the research theme in which the sign of
the microscopic weighting genuinely goes negative at a strictly interior point. -/
theorem square_sign_characterisation :
    (musq 0 < 0 ∧ ((0, 0) : ℝ × ℝ) ∉ Set.extremePoints ℝ (convexHull ℝ sqPts)) ∧
    (∀ i : Fin 5, i ≠ 0 → 0 < musq i) ∧
    (∀ p ∈ sqPts, p ≠ (0, 0) → p ∈ Set.extremePoints ℝ (convexHull ℝ sqPts)) := by
  obtain ⟨hcentre, hvert⟩ := square_signs
  exact ⟨⟨hcentre, sq_centre_not_extreme⟩, hvert, sq_vertex_extreme⟩

end MicroWeighting