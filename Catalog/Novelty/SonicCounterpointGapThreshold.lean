import Novelty.SonicCounterpointConnectivity

/-!
# Gap graphs on `ℤ` and the structural reason for the counterpoint threshold

The refutation in `Novelty.SonicCounterpointConnectivity` is a finite table
computation.  This file explains it structurally, by proving a general
connectivity criterion for *gap graphs* on the integers and then specializing
it to the consonance ladder `{0, 3, 4, 7, 8, 9, 12}`.

For a finite set `S ⊆ ℤ` and a width `w`, join `a, b ∈ S` when
`|b - a| ≤ w`.  The main theorem is

  `conn_iff_consecutiveGapBound` :
    every two points of `S` are joined by a finite path
      ↔ every pair of *consecutive* points of `S` is at distance at most `w`.

The forward direction is a cut invariant (nothing can cross a wide gap); the
backward direction is a strong induction on the integer distance, splitting a
long pair at an interior point.  Neither direction is a finite check: the
statement is uniform in `S` and `w`.

Specializing to the consonance ladder, whose consecutive gaps are
`3, 1, 3, 1, 1, 3`, the criterion holds exactly when `w ≥ 3`.  This recovers
`gap_connectivity_threshold` conceptually: the seven-state system fails to be
strongly connected for the first-species step width `w = 2` precisely because
the ladder has three gaps of a minor third, and those gaps are the four
registers' boundaries.
-/

namespace SonicCounterpoint
namespace GapGraph

/-- One legal hop inside `S`: both endpoints in `S`, distance at most `w`. -/
def Step (S : Finset ℤ) (w : ℕ) (a b : ℤ) : Prop :=
  a ∈ S ∧ b ∈ S ∧ (b - a).natAbs ≤ w

/-- Finite-path connectivity inside a gap graph. -/
def Conn (S : Finset ℤ) (w : ℕ) (a b : ℤ) : Prop :=
  Relation.ReflTransGen (Step S w) a b

theorem step_symmetric (S : Finset ℤ) (w : ℕ) : Symmetric (Step S w) := by
  rintro a b ⟨ha, hb, hab⟩
  exact ⟨hb, ha, by omega⟩

theorem conn_symm {S : Finset ℤ} {w : ℕ} {a b : ℤ} (h : Conn S w a b) : Conn S w b a :=
  Relation.ReflTransGen.symmetric (step_symmetric S w) h

/-- Consecutive points of `S` are never farther apart than `w`. -/
def ConsecutiveGapBound (S : Finset ℤ) (w : ℕ) : Prop :=
  ∀ x ∈ S, ∀ y ∈ S, x < y → (∀ z ∈ S, ¬ (x < z ∧ z < y)) → (y - x).natAbs ≤ w

/-- Widening the admissible hop preserves the gap bound. -/
theorem consecutiveGapBound_mono {S : Finset ℤ} {w w' : ℕ} (hw : w ≤ w')
    (h : ConsecutiveGapBound S w) : ConsecutiveGapBound S w' := fun x hx y hy hxy hgap =>
  le_trans (h x hx y hy hxy hgap) hw

/-- Widening the admissible hop preserves connectivity. -/
theorem conn_mono {S : Finset ℤ} {w w' : ℕ} (hw : w ≤ w') {a b : ℤ}
    (h : Conn S w a b) : Conn S w' a b :=
  h.mono fun _ _ hab => ⟨hab.1, hab.2.1, le_trans hab.2.2 hw⟩

/-- Ordered case of sufficiency, by strong induction on the integer distance:
either the pair is already a legal hop, or some point of `S` lies strictly
between and both halves are shorter. -/
theorem conn_of_consecutiveGapBound_aux {S : Finset ℤ} {w : ℕ}
    (h : ConsecutiveGapBound S w) :
    ∀ n : ℕ, ∀ a ∈ S, ∀ b ∈ S, a < b → (b - a).toNat = n → Conn S w a b := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    intro a ha b hb hab hn
    by_cases hstep : (b - a).natAbs ≤ w
    · exact Relation.ReflTransGen.single ⟨ha, hb, hstep⟩
    · by_cases hz : ∃ z ∈ S, a < z ∧ z < b
      · obtain ⟨z, hzS, h1, h2⟩ := hz
        have c1 : Conn S w a z :=
          ih (z - a).toNat (by omega) a ha z hzS h1 rfl
        have c2 : Conn S w z b :=
          ih (b - z).toNat (by omega) z hzS b hb h2 rfl
        exact c1.trans c2
      · push_neg at hz
        refine absurd (h a ha b hb hab ?_) hstep
        rintro z hzS ⟨h1, h2⟩
        exact absurd h2 (not_lt.2 (hz z hzS h1))

/-- **Sufficiency.** If no consecutive gap exceeds `w`, the gap graph on `S` is
connected. -/
theorem conn_of_consecutiveGapBound {S : Finset ℤ} {w : ℕ}
    (h : ConsecutiveGapBound S w) : ∀ a ∈ S, ∀ b ∈ S, Conn S w a b := by
  intro a ha b hb
  rcases lt_trichotomy a b with hab | hab | hab
  · exact conn_of_consecutiveGapBound_aux h _ a ha b hb hab rfl
  · exact hab ▸ Relation.ReflTransGen.refl
  · exact conn_symm (conn_of_consecutiveGapBound_aux h _ b hb a ha hab rfl)

/-- **Necessity.** A wide consecutive gap is an impassable cut: nothing reachable
from its left endpoint ever crosses it. -/
theorem consecutiveGapBound_of_conn {S : Finset ℤ} {w : ℕ}
    (hconn : ∀ a ∈ S, ∀ b ∈ S, Conn S w a b) : ConsecutiveGapBound S w := by
  intro x hx y hy hxy hgap
  by_contra hwide
  have hcut : ∀ v : ℤ, Conn S w x v → v ≤ x := by
    intro v hv
    induction hv with
    | refl => exact le_rfl
    | tail _ hstep ih =>
        rename_i u v _
        obtain ⟨huS, hvS, huv⟩ := hstep
        by_contra hvx
        push_neg at hvx
        have hvy : y ≤ v := by
          by_contra hvy
          push_neg at hvy
          exact hgap v hvS ⟨hvx, hvy⟩
        omega
  exact absurd (hcut y (hconn x hx y hy)) (not_le.2 hxy)

/-- **Connectivity criterion for integer gap graphs.** -/
theorem conn_iff_consecutiveGapBound (S : Finset ℤ) (w : ℕ) :
    (∀ a ∈ S, ∀ b ∈ S, Conn S w a b) ↔ ConsecutiveGapBound S w :=
  ⟨consecutiveGapBound_of_conn, conn_of_consecutiveGapBound⟩

/-! ## Specialization to the consonance ladder -/

/-- The simple consonances through the octave, as a subset of `ℤ`. -/
def consonanceLadder : Finset ℤ := {0, 3, 4, 7, 8, 9, 12}

theorem semitones_mem_consonanceLadder (i : SimpleConsonance) :
    (i.semitones : ℤ) ∈ consonanceLadder := by
  cases i <;> decide

theorem consonanceLadder_gapBound_three : ConsecutiveGapBound consonanceLadder 3 := by
  unfold ConsecutiveGapBound consonanceLadder
  decide

/-- The ladder has a genuine minor-third gap at the very bottom, so no width
below three can satisfy the criterion. -/
theorem consonanceLadder_gapBound_le (w : ℕ) (h : ConsecutiveGapBound consonanceLadder w) :
    3 ≤ w := by
  have h03 : (3 : ℤ) - 0 = 3 := by ring
  have := h 0 (by decide) 3 (by decide) (by norm_num) (by decide)
  rwa [h03] at this

/-- **Structural threshold.** The consonance ladder's gap graph is connected
exactly for widths at least a minor third. -/
theorem consonanceLadder_conn_iff (w : ℕ) :
    (∀ a ∈ consonanceLadder, ∀ b ∈ consonanceLadder, Conn consonanceLadder w a b) ↔ 3 ≤ w := by
  rw [conn_iff_consecutiveGapBound]
  exact ⟨consonanceLadder_gapBound_le w,
    fun hw => consecutiveGapBound_mono hw consonanceLadder_gapBound_three⟩

/-! ## Reconciliation with the seven-state model -/

/-- The seven-state width-`w` motion is exactly a hop of the ladder gap graph. -/
theorem gapMotion_iff_step (w : ℕ) (i j : SimpleConsonance) :
    GapMotion w i j ↔ Step consonanceLadder w (i.semitones : ℤ) (j.semitones : ℤ) :=
  ⟨fun h => ⟨semitones_mem_consonanceLadder i, semitones_mem_consonanceLadder j, h⟩,
    fun h => h.2.2⟩

/-- Seven-state reachability transports to ladder connectivity. -/
theorem gapReachable_to_conn {w : ℕ} {i j : SimpleConsonance} (h : GapReachable w i j) :
    Conn consonanceLadder w (i.semitones : ℤ) (j.semitones : ℤ) :=
  Relation.ReflTransGen.lift (fun i : SimpleConsonance => (i.semitones : ℤ))
    (fun a b hab => (gapMotion_iff_step w a b).1 hab) h

/-- A second, structural proof of the threshold for the seven canonical states:
the first-species width `2` fails because the ladder has a minor-third gap,
and width `3` succeeds because that is the largest gap. -/
theorem gap_threshold_via_ladder (w : ℕ) :
    (∀ i j : SimpleConsonance, GapReachable w i j) ↔ 3 ≤ w := by
  constructor
  · intro h
    refine consonanceLadder_gapBound_le w (consecutiveGapBound_of_conn ?_)
    intro a ha b hb
    -- every ladder point is the semitone value of a named consonance
    have hmem : ∀ c : ℤ, c ∈ consonanceLadder →
        ∃ i : SimpleConsonance, (i.semitones : ℤ) = c := by
      intro c hc
      fin_cases hc
      exacts [⟨.unison, rfl⟩, ⟨.minorThird, rfl⟩, ⟨.majorThird, rfl⟩,
        ⟨.perfectFifth, rfl⟩, ⟨.minorSixth, rfl⟩, ⟨.majorSixth, rfl⟩, ⟨.octave, rfl⟩]
    obtain ⟨i, rfl⟩ := hmem a ha
    obtain ⟨j, rfl⟩ := hmem b hb
    exact gapReachable_to_conn (h i j)
  · intro hw i j
    exact gap_supercritical_total w hw i j

/-- The two derivations of the threshold agree. -/
theorem gap_threshold_agreement (w : ℕ) :
    ((∀ i j : SimpleConsonance, GapReachable w i j) ↔ 3 ≤ w) ∧
      ((∀ a ∈ consonanceLadder, ∀ b ∈ consonanceLadder, Conn consonanceLadder w a b) ↔ 3 ≤ w) :=
  ⟨gap_threshold_via_ladder w, consonanceLadder_conn_iff w⟩

/-- At the historical first-species width the ladder is disconnected, which is
the gap-graph explanation of the refuted conjecture. -/
theorem consonanceLadder_disconnected_at_two :
    ¬ ∀ a ∈ consonanceLadder, ∀ b ∈ consonanceLadder, Conn consonanceLadder 2 a b := by
  rw [consonanceLadder_conn_iff]
  omega

end GapGraph
end SonicCounterpoint