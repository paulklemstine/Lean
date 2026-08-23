import Mathlib
import Novelty.EscapeDoublyExponential

/-!
# The filled Julia set as the exact complement of the escape-time test

Fourth iteration of the escape-criterion thread. The escape-time test
(`EscapeCriterion.bounded_iff_never_escapes`) says that an orbit is bounded iff it never
leaves the disk of radius `escapeRadius c`. Here that equivalence is used to give the
filled Julia set
`K_c = {z | the orbit of z under f_c is bounded}`
its standard structure theory, entirely from the escape estimates:

* `mem_filledJulia_iff`: membership is decided by the radius-`max 2 ‖c‖` test.
* `filledJulia_qmap_iff`: total invariance `z ∈ K_c ↔ f_c z ∈ K_c`.
* `isClosed_filledJulia`, `isCompact_filledJulia`: `K_c` is compact.
* `filledJulia_nonempty`: `K_c` is nonempty — via the algebraic input that `z² - z + c` has a
  root in `ℂ`, i.e. a fixed point of `f_c`, whose orbit is constant.
* `filledJulia_eq_iInter`: `K_c` is the nested intersection of the escape-time test sets,
  the dynamical counterpart of `Mandelbrot_eq_iInter`.
* `escapeRate_pos_of_not_mem`: outside `K_c` the escape rate is strictly positive, so
  `K_c = {z | G_c(z) = 0}` on the region where `G_c` is defined (`filledJulia_eq_zero_set`).
-/

namespace EscapeCriterion

open Filter MandelbrotEscape
open scoped Topology

variable {c z : ℂ}

/-- The filled Julia set of `f_c`: the points with bounded forward orbit. -/
def filledJulia (c : ℂ) : Set ℂ := {z | BoundedOrbit c z}

theorem mem_filledJulia_iff (c z : ℂ) :
    z ∈ filledJulia c ↔ ∀ n, ‖orbit c z n‖ ≤ escapeRadius c :=
  bounded_iff_never_escapes c z

theorem filledJulia_subset_closedBall : filledJulia c ⊆ Metric.closedBall 0 (escapeRadius c) := by
  intro z hz
  have h := (mem_filledJulia_iff c z).mp hz 0
  simpa [mem_closedBall_zero_iff] using h

/-- **Total invariance**: `z` has bounded orbit iff `f_c z` does. -/
theorem filledJulia_qmap_iff (c z : ℂ) : z ∈ filledJulia c ↔ qmap c z ∈ filledJulia c := by
  constructor
  · rintro ⟨B, hB⟩
    refine ⟨B, fun n => ?_⟩
    rw [orbit_qmap]
    exact hB (n + 1)
  · intro h
    rw [mem_filledJulia_iff]
    intro n
    by_contra hlt
    push_neg at hlt
    have hdiv := tendsto_atTop_of_exists_escape c z ⟨n, hlt⟩
    obtain ⟨B, hB⟩ := h
    have hdiv' : Tendsto (fun k => ‖orbit c (qmap c z) k‖) atTop atTop := by
      rw [← Filter.tendsto_add_atTop_iff_nat 1] at hdiv
      exact hdiv.congr fun k => by rw [orbit_qmap, Nat.add_comm]
    obtain ⟨m, hm⟩ := (hdiv'.eventually_gt_atTop B).exists
    exact absurd (hB m) (not_le.mpr hm)

/-- The escape-time test sets for the point-dynamics. -/
def juliaTestSet (c : ℂ) (n : ℕ) : Set ℂ := {z | ∀ k ≤ n, ‖orbit c z k‖ ≤ escapeRadius c}

lemma continuous_orbit (c : ℂ) (n : ℕ) : Continuous fun z : ℂ => orbit c z n := by
  induction n with
  | zero => simpa using continuous_id
  | succ n ih =>
    simp only [orbit_succ]
    exact (ih.pow 2).add continuous_const

lemma isClosed_juliaTestSet (c : ℂ) (n : ℕ) : IsClosed (juliaTestSet c n) := by
  have h : juliaTestSet c n = ⋂ k ∈ Set.Iic n, {z : ℂ | ‖orbit c z k‖ ≤ escapeRadius c} := by
    ext z; simp [juliaTestSet, Set.mem_Iic]
  rw [h]
  exact isClosed_biInter fun k _ => isClosed_le ((continuous_orbit c k).norm) continuous_const

theorem filledJulia_eq_iInter (c : ℂ) : filledJulia c = ⋂ n, juliaTestSet c n := by
  ext z
  simp only [Set.mem_iInter, juliaTestSet, Set.mem_setOf_eq]
  rw [mem_filledJulia_iff]
  exact ⟨fun h n k _ => h k, fun h n => h n n le_rfl⟩

theorem isClosed_filledJulia (c : ℂ) : IsClosed (filledJulia c) := by
  rw [filledJulia_eq_iInter]
  exact isClosed_iInter (isClosed_juliaTestSet c)

theorem isCompact_filledJulia (c : ℂ) : IsCompact (filledJulia c) := by
  refine Metric.isCompact_of_isClosed_isBounded (isClosed_filledJulia c) ?_
  exact Bornology.IsBounded.subset
    (Metric.isBounded_closedBall (x := (0 : ℂ)) (r := escapeRadius c))
    filledJulia_subset_closedBall

/-- A fixed point of `f_c` has constant orbit, hence lies in the filled Julia set. -/
theorem fixedPoint_mem_filledJulia {w : ℂ} (hw : w ^ 2 + c = w) : w ∈ filledJulia c := by
  have horb : ∀ n, orbit c w n = w := by
    intro n
    induction n with
    | zero => simp
    | succ n ih => rw [orbit_succ, ih, hw]
  exact ⟨‖w‖, fun n => by rw [horb n]⟩

/-- **Nonemptiness**: `f_c` has a fixed point (a root of `z² - z + c`, which exists because
`ℂ` is algebraically closed), so `K_c ≠ ∅`. -/
theorem filledJulia_nonempty (c : ℂ) : (filledJulia c).Nonempty := by
  obtain ⟨u, hu⟩ : ∃ u : ℂ, u ^ 2 = 1 - 4 * c := IsSepClosed.exists_pow_nat_eq _ 2
  refine ⟨(1 + u) / 2, fixedPoint_mem_filledJulia ?_⟩
  have : ((1 + u) / 2) ^ 2 + c - (1 + u) / 2 = (u ^ 2 - (1 - 4 * c)) / 4 := by ring
  have h0 : ((1 + u) / 2) ^ 2 + c - (1 + u) / 2 = 0 := by rw [this, hu]; ring
  linear_combination h0

/-- Outside the filled Julia set the escape rate is defined and strictly positive at every
orbit point that has crossed the escape radius. -/
theorem escapeRate_pos_of_not_mem (hz : z ∉ filledJulia c) :
    ∃ N, escapeRadius c < ‖orbit c z N‖ ∧ 0 < escapeRate c (orbit c z N) := by
  rw [mem_filledJulia_iff] at hz
  push_neg at hz
  obtain ⟨N, hN⟩ := hz
  exact ⟨N, hN, escapeRate_pos hN⟩

/-- The filled Julia set is exactly the zero set of the escape rate, in the sense that a
point is in `K_c` iff no forward image has a positive escape rate. -/
theorem filledJulia_eq_zero_set (c : ℂ) :
    filledJulia c = {z | ∀ N, ¬ (escapeRadius c < ‖orbit c z N‖ ∧ 0 < escapeRate c (orbit c z N))} := by
  ext z
  constructor
  · intro hz N
    rintro ⟨hN, -⟩
    exact absurd ((mem_filledJulia_iff c z).mp hz N) (not_le.mpr hN)
  · intro hz
    by_contra hnot
    obtain ⟨N, hN, hpos⟩ := escapeRate_pos_of_not_mem hnot
    exact hz N ⟨hN, hpos⟩

end EscapeCriterion