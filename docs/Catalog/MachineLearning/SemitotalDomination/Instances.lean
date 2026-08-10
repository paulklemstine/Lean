import MachineLearning.SemitotalDomination.Necessity

/-!
# Fully verified instances

Two exact computations that calibrate the theory.

1. `semitotalDominationNumber_lineGraph_seven`: for the seven-vertex path realized as a unit disk
   graph, `γ_t2 = 3`.  Since the domination number of `P₇` is also `3`, this instance shows the
   inequality `γ ≤ γ_t2` can be an equality even when the "obvious" maximal independent sets
   (such as `{0,3,6}`, see `MachineLearning.SemitotalDomination.Necessity`) fail badly.

2. `semitotalDominationNumber_star`, `dominationNumber_star`: for the star `K₁,₃` we get
   `γ = 1 < 2 = γ_t2`, so the first inequality of the chain `γ ≤ γ_t2 ≤ γ_t` is strict in
   general, and the "+1 vertex" repair in the degenerate branch of the algorithm is unavoidable.

Both numbers are obtained by exhaustive kernel evaluation (`decide`) over all subsets, after
rewriting the geometric adjacency of the unit disk graph into its combinatorial form.

-- !-- Lab Notes -- !--
## Experimental data
| graph | γ | γ_t2 | greedy BFS output |
|-------|---|------|-------------------|
| `P₇` (line UDG) | 3 | 3 | `{0,2,4,6}`, size 4 |
| `K₁,₃` (star)   | 1 | 2 | `{centre}` repaired to `{centre, leaf}`, size 2 |

## Insights
* The star is exactly the degenerate case of the algorithm: the greedy BFS set is the singleton
  `{r}` and has to be enlarged; the resulting size `2` is *optimal*, not merely within a factor
  of `5`.
* On `P₇` the greedy BFS set has size `4 = γ_t2 + 1`, far below the guaranteed `5 · γ_t2 = 15`.
-/

namespace SemitotalDomination

open Finset

/-! ### The seven-vertex path -/

/-- `{1,3,5}` is a semitotal dominating set of the seven-vertex path. -/
theorem P7_semitotal_135 :
    IsSemitotalDominatingSet (lineGraph 7) ({1, 3, 5} : Finset (Fin 7)) := by
  unfold IsSemitotalDominatingSet IsDominatingSet IsSemitotalSet Within2
  simp only [lineGraph_adj_iff]
  decide

set_option maxRecDepth 10000 in
/-- No set of at most two vertices is a semitotal dominating set of the seven-vertex path. -/
theorem P7_no_small_semitotal (S : Finset (Fin 7)) (h : S.card ≤ 2) :
    ¬ IsSemitotalDominatingSet (lineGraph 7) S := by
  revert S h
  unfold IsSemitotalDominatingSet IsDominatingSet IsSemitotalSet Within2
  simp only [lineGraph_adj_iff]
  decide

/-- **`γ_t2(P₇) = 3`.** -/
theorem semitotalDominationNumber_lineGraph_seven :
    semitotalDominationNumber (lineGraph 7) = 3 := by
  have hmem : (3 : ℕ) ∈ {k | ∃ S : Finset (Fin 7),
      IsSemitotalDominatingSet (lineGraph 7) S ∧ S.card = k} := by
    exact ⟨{1, 3, 5}, P7_semitotal_135, by decide⟩
  have hub : semitotalDominationNumber (lineGraph 7) ≤ 3 := Nat.sInf_le hmem
  obtain ⟨S, hS, hcard⟩ := Nat.sInf_mem (⟨3, hmem⟩ :
    {k | ∃ S : Finset (Fin 7), IsSemitotalDominatingSet (lineGraph 7) S ∧ S.card = k}.Nonempty)
  by_contra hne
  have hlt : S.card ≤ 2 := by
    rw [hcard]
    unfold semitotalDominationNumber at hub hne
    omega
  exact P7_no_small_semitotal S hlt hS

/-! ### The star `K₁,₃` -/

/-- The star with centre `0` and three leaves. -/
def starGraph : SimpleGraph (Fin 4) where
  Adj i j := (i = 0 ∧ j ≠ 0) ∨ (j = 0 ∧ i ≠ 0)
  symm := by
    intro i j h
    tauto
  loopless := ⟨by
    rintro i (⟨h1, h2⟩ | ⟨h1, h2⟩) <;> exact h2 h1⟩

instance : DecidableRel starGraph.Adj :=
  fun i j => decidable_of_iff ((i = 0 ∧ j ≠ 0) ∨ (j = 0 ∧ i ≠ 0)) Iff.rfl

/-- **`γ(K₁,₃) = 1`**: the centre alone dominates. -/
theorem dominationNumber_star : dominationNumber starGraph = 1 := by
  have hmem : (1 : ℕ) ∈ {k | ∃ D : Finset (Fin 4), IsDominatingSet starGraph D ∧ D.card = k} := by
    refine ⟨{0}, ?_, by decide⟩
    unfold IsDominatingSet
    decide
  have hub : dominationNumber starGraph ≤ 1 := Nat.sInf_le hmem
  have hpos : dominationNumber starGraph ≠ 0 := by
    intro h0
    obtain ⟨D, hD, hcard⟩ := Nat.sInf_mem (⟨1, hmem⟩ :
      {k | ∃ D : Finset (Fin 4), IsDominatingSet starGraph D ∧ D.card = k}.Nonempty)
    rw [show sInf {k | ∃ D : Finset (Fin 4), IsDominatingSet starGraph D ∧ D.card = k}
      = dominationNumber starGraph from rfl, h0] at hcard
    rw [Finset.card_eq_zero] at hcard
    subst hcard
    rcases hD 0 with h | ⟨d, hd, -⟩
    · simp at h
    · simp at hd
  omega

/-- **`γ_t2(K₁,₃) = 2`**: no single vertex can satisfy the semitotal condition. -/
theorem semitotalDominationNumber_star : semitotalDominationNumber starGraph = 2 := by
  have hmem : (2 : ℕ) ∈ {k | ∃ S : Finset (Fin 4),
      IsSemitotalDominatingSet starGraph S ∧ S.card = k} := by
    refine ⟨{0, 1}, ?_, by decide⟩
    unfold IsSemitotalDominatingSet IsDominatingSet IsSemitotalSet Within2
    decide
  have hub : semitotalDominationNumber starGraph ≤ 2 := Nat.sInf_le hmem
  obtain ⟨S, hS, hcard⟩ := Nat.sInf_mem (⟨2, hmem⟩ :
    {k | ∃ S : Finset (Fin 4), IsSemitotalDominatingSet starGraph S ∧ S.card = k}.Nonempty)
  have hsmall : ∀ T : Finset (Fin 4), T.card ≤ 1 → ¬ IsSemitotalDominatingSet starGraph T := by
    intro T hT
    revert hT
    revert T
    unfold IsSemitotalDominatingSet IsDominatingSet IsSemitotalSet Within2
    decide
  by_contra hne
  have hlt : S.card ≤ 1 := by
    rw [hcard]
    unfold semitotalDominationNumber at hub hne
    omega
  exact hsmall S hlt hS

/-- **The inequality `γ ≤ γ_t2` is strict for the star.** -/
theorem dominationNumber_lt_semitotalDominationNumber_star :
    dominationNumber starGraph < semitotalDominationNumber starGraph := by
  rw [dominationNumber_star, semitotalDominationNumber_star]
  norm_num

/-- **Sharpness of the universal bound `γ_t2 ≤ 2 γ`** (`TotalBound.lean`): the star attains
it, since `γ = 1` and `γ_t2 = 2`. -/
theorem semitotalDominationNumber_star_eq_two_mul :
    semitotalDominationNumber starGraph = 2 * dominationNumber starGraph := by
  rw [dominationNumber_star, semitotalDominationNumber_star]

/-! ### The star is itself a unit disk graph

Placing the centre at the origin and the three leaves at the cube roots of unity realizes
`K₁,₃` as a unit disk graph: each leaf is at distance exactly `1` from the centre, while two
leaves are `√3 > 1` apart.  Consequently the universal bound `γ_t2 ≤ 2γ` proved in
`TotalBound.lean` is attained *inside the unit disk class*, which shows that the structural
corollary `γ_t2 ≤ 5γ` extracted from the approximation algorithm is never tight. -/

open Complex Real in
/-- Angles of the three leaves of the star (the cube roots of unity); the centre's entry is
unused. -/
noncomputable def starAngle : Fin 4 → ℝ := ![0, 0, 2 * π / 3, 4 * π / 3]

open Complex Real in
/-- Positions in the plane realizing the star `K₁,₃` as a unit disk graph. -/
noncomputable def starPos (i : Fin 4) : ℂ :=
  if i = 0 then 0 else Complex.exp ((starAngle i : ℂ) * I)

open Complex Real in
lemma starPos_eq {i : Fin 4} (hi : i ≠ 0) :
    starPos i = Complex.exp ((starAngle i : ℂ) * I) := by simp [starPos, hi]

/-- Every leaf is at distance exactly `1` from the centre. -/
lemma starPos_dist_centre {i : Fin 4} (hi : i ≠ 0) : dist (starPos 0) (starPos i) = 1 := by
  rw [starPos_eq hi, show starPos 0 = 0 from by simp [starPos], dist_comm, dist_zero_right]
  simp

lemma starPos_far_aux {i j : Fin 4} (hj : j ≠ 0) (hlt : j < i) :
    1 < dist (starPos i) (starPos j) := by
  have hpi := Real.pi_pos
  have hi : i ≠ 0 := by
    rintro rfl
    exact absurd hlt (by simp [Fin.lt_def])
  rw [starPos_eq hi, starPos_eq hj]
  apply one_lt_dist_of_angle
  · fin_cases i <;> fin_cases j <;> simp_all [starAngle, Fin.lt_def] <;> nlinarith
  · fin_cases i <;> fin_cases j <;> simp_all [starAngle, Fin.lt_def] <;> nlinarith

/-- Two distinct leaves are more than `1` apart (their distance is `√3`). -/
lemma starPos_leaf_far {i j : Fin 4} (hi : i ≠ 0) (hj : j ≠ 0) (hij : i ≠ j) :
    1 < dist (starPos i) (starPos j) := by
  rcases lt_trichotomy i j with h | h | h
  · rw [dist_comm]; exact starPos_far_aux hi h
  · exact absurd h hij
  · exact starPos_far_aux hj h

/-- **The star `K₁,₃` is a unit disk graph.** -/
noncomputable def starRep : UnitDiskRep starGraph where
  pos := starPos
  adj_iff u v := by
    constructor
    · rintro (⟨rfl, hv⟩ | ⟨rfl, hu⟩)
      · exact ⟨fun h => hv h.symm, le_of_eq (starPos_dist_centre hv)⟩
      · exact ⟨hu, by rw [dist_comm]; exact le_of_eq (starPos_dist_centre hu)⟩
    · rintro ⟨hne, hd⟩
      by_cases hu : u = 0
      · exact Or.inl ⟨hu, by rintro rfl; exact hne hu⟩
      · by_cases hv : v = 0
        · exact Or.inr ⟨hv, hu⟩
        · exact absurd hd (not_le.mpr (starPos_leaf_far hu hv hne))

/-- The star is connected: every vertex is adjacent to the centre. -/
theorem starGraph_connected : starGraph.Connected := by
  rw [SimpleGraph.connected_iff]
  have h : ∀ w : Fin 4, starGraph.Reachable 0 w := by
    intro w
    by_cases hw : w = 0
    · subst hw; rfl
    · exact SimpleGraph.Adj.reachable (Or.inl ⟨rfl, hw⟩)
  exact ⟨fun u v => ((h u).symm).trans (h v), ⟨0⟩⟩

/-- **The bound `γ_t2 ≤ 2γ` is attained by a connected unit disk graph.**  Hence, on unit disk
graphs, the ratio `γ_t2/γ` reaches `2` but never `5`: the paper's factor `5` is an approximation
guarantee against `γ_t2` itself, not a bound on that ratio. -/
theorem star_unitDisk_sharp :
    starGraph.Connected ∧ 1 < Fintype.card (Fin 4) ∧ Nonempty (UnitDiskRep starGraph) ∧
      semitotalDominationNumber starGraph = 2 * dominationNumber starGraph :=
  ⟨starGraph_connected, by norm_num, ⟨starRep⟩, semitotalDominationNumber_star_eq_two_mul⟩

end SemitotalDomination