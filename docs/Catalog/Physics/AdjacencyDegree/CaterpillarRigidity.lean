import Physics.AdjacencyDegree.WalkStatistics
import Physics.AdjacencyDegree.SixVertexWitness

/-!
# Exact strength of the caterpillar invariant

Putting the two halves of the development together gives a sharp description of what the
adjacency-degree moments see and what they miss.

* Upper bound (`walkStat_eq_of_wordMoment_eq`, `degWalkCount_eq_of_wordMoment_eq`): moment
  equality is *equivalent in strength* to the equality of all degree-decorated caterpillar
  counts — one direction is the content of `WalkStatistics.lean`, the other is immediate
  because each caterpillar moment is a nonnegative combination of such counts.
* Lower bound (`SixVertexWitness.lean`): the invariant is not complete, already for connected
  non-regular graphs on six vertices.

Main results:

* `AdjDeg.wordMoment_eq_of_degWalkCount_eq` : equal decorated walk counts of all lengths force
  equal word moments — the converse of `degWalkCount_eq_of_wordMoment_eq`;
* `AdjDeg.wordMoment_eq_iff_degWalkCount_eq` : the two invariants coincide;
* `AdjDeg.caterpillar_counts_not_complete` : the invariant fails to determine connected
  non-regular graphs on six vertices.
-/

namespace AdjDeg

open Matrix Finset

variable {V : Type*} [Fintype V] [DecidableEq V]
variable {W : Type*} [Fintype W] [DecidableEq W]
variable (G : SimpleGraph V) [DecidableRel G.Adj]
variable (G' : SimpleGraph W) [DecidableRel G'.Adj]

/-! ## Every word is a caterpillar word -/

/-- Prepending a `D` increases the first exponent of a caterpillar word. -/
lemma catWord_succ_first :
    ∀ (n : ℕ) (a : Fin (n + 1) → ℕ),
      catWord n (fun i => if i = 0 then a i + 1 else a i) = Letter.deg :: catWord n a := by
  intro n
  cases n with
  | zero =>
      intro a
      simp [catWord, List.replicate_succ]
  | succ n =>
      intro a
      have hsucc : ∀ i : Fin (n + 1),
          (if i.succ = 0 then a i.succ + 1 else a i.succ) = a i.succ := fun i => by
        rw [if_neg (Fin.succ_ne_zero i)]
      simp [catWord, List.replicate_succ]

/-- Grouping consecutive `D`s shows that **every** word in the alphabet `{A, D}` is a
caterpillar word. -/
lemma exists_catWord (w : List Letter) : ∃ (n : ℕ) (a : Fin (n + 1) → ℕ), w = catWord n a := by
  induction w with
  | nil => exact ⟨0, fun _ => 0, rfl⟩
  | cons l w ih =>
      obtain ⟨n, a, rfl⟩ := ih
      cases l with
      | adj =>
          refine ⟨n + 1, Fin.cons 0 a, ?_⟩
          simp [catWord]
      | deg =>
          exact ⟨n, fun i => if i = 0 then a i + 1 else a i, (catWord_succ_first n a).symm⟩

/-- Word moments are determined by caterpillar-word moments. -/
lemma wordMoment_eq_of_catWord
    (h : ∀ (n : ℕ) (a : Fin (n + 1) → ℕ), wordMoment G (catWord n a) = wordMoment G' (catWord n a))
    (w : List Letter) : wordMoment G w = wordMoment G' w := by
  obtain ⟨n, a, rfl⟩ := exists_catWord w
  exact h n a

/-! ## Moments versus decorated walk counts -/

/-- A caterpillar moment is the decorated walk sum, so it is determined by the decorated walk
counts: group the walks by their degree pattern. -/
lemma moment_catMat_eq_sum_degWalkCount (n : ℕ) (a : Fin (n + 1) → ℕ) :
    moment (catMat G n a)
      = ∑ b ∈ Fintype.piFinset (fun _ : Fin (n + 1) => Finset.range (Fintype.card V)),
          (degWalkCount G n b : ℝ) * ∏ i : Fin (n + 1), (b i : ℝ) ^ a i := by
  have hcount : ∀ b : Fin (n + 1) → ℕ,
      (degWalkCount G n b : ℝ)
        = ∑ p : Fin (n + 1) → V,
            (if ((∀ i : Fin n, G.Adj (p i.castSucc) (p i.succ)) ∧
              ∀ i : Fin (n + 1), G.degree (p i) = b i) then (1 : ℝ) else 0) := by
    intro b
    rw [degWalkCount, Finset.sum_boole]
  simp_rw [hcount, Finset.sum_mul]
  rw [moment_catMat, Finset.sum_comm]
  refine Finset.sum_congr rfl fun p _ => ?_
  -- the degree pattern of `p` is the unique index contributing
  set c : Fin (n + 1) → ℕ := fun i => G.degree (p i) with hc
  have hcmem : c ∈ Fintype.piFinset fun _ : Fin (n + 1) => Finset.range (Fintype.card V) := by
    refine Fintype.mem_piFinset.mpr fun i => Finset.mem_range.mpr ?_
    exact G.degree_lt_card_verts (p i)
  rw [Finset.sum_eq_single c]
  · rw [catWeight, prod_adj_eq_ite]
    by_cases hadj : ∀ i : Fin n, G.Adj (p i.castSucc) (p i.succ)
    · simp [hadj, hc]
    · simp [hadj]
  · intro b _ hbc
    have hne : ¬ (∀ i : Fin (n + 1), G.degree (p i) = b i) := by
      intro hall
      exact hbc (funext fun i => (hall i).symm)
    simp [hne]
  · intro hnot
    exact absurd hcmem hnot

/-- **Converse rigidity.** If two graphs have the same degree-decorated walk counts for all
lengths and all degree patterns, then all their adjacency-degree word moments agree. -/
theorem wordMoment_eq_of_degWalkCount_eq
    (hcard : Fintype.card V = Fintype.card W)
    (h : ∀ (n : ℕ) (b : Fin (n + 1) → ℕ), degWalkCount G n b = degWalkCount G' n b)
    (n : ℕ) (a : Fin (n + 1) → ℕ) :
    wordMoment G (catWord n a) = wordMoment G' (catWord n a) := by
  rw [← moment_catMat_eq_wordMoment, ← moment_catMat_eq_wordMoment,
    moment_catMat_eq_sum_degWalkCount, moment_catMat_eq_sum_degWalkCount, ← hcard]
  exact Finset.sum_congr rfl fun b _ => by rw [h n b]

/-- **The moment invariant and the decorated caterpillar counts have the same strength.** -/
theorem wordMoment_eq_iff_degWalkCount_eq (hcard : Fintype.card V = Fintype.card W) :
    (∀ (n : ℕ) (a : Fin (n + 1) → ℕ), wordMoment G (catWord n a) = wordMoment G' (catWord n a))
      ↔ ∀ (n : ℕ) (b : Fin (n + 1) → ℕ), degWalkCount G n b = degWalkCount G' n b := by
  constructor
  · intro h n b
    refine degWalkCount_eq_of_wordMoment_eq G G' (fun w => ?_) n b
    -- every word is, up to reordering the commuting diagonal factors, a caterpillar word;
    -- we only need that the caterpillar words already give all moments used above
    exact wordMoment_eq_of_catWord G G' h w
  · intro h
    exact wordMoment_eq_of_degWalkCount_eq G G' hcard h

/-- **The decorated caterpillar counts do not determine connected graphs.** The six-vertex
witnesses have identical decorated walk counts of every length, are both connected and
non-regular, and are not isomorphic. -/
theorem caterpillar_counts_not_complete :
    (∀ (n : ℕ) (b : Fin (n + 1) → ℕ), degWalkCount hex1 n b = degWalkCount hex2 n b) ∧
      hex1.Connected ∧ hex2.Connected ∧ IsEmpty (hex1 ≃g hex2) :=
  ⟨fun n b => degWalkCount_eq_of_wordMoment_eq hex1 hex2 hex_wordMoment_eq n b,
    hex1_connected, hex2_connected, hex_not_iso⟩

end AdjDeg