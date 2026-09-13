import Novelty.SonicCounterpointRegisterGroupoid

/-!
# A metric refinement: the free-bass distance from unison to octave is exactly three

`Novelty.SonicCounterpointConnectivity` shows that, once the bass is free to
move, all seven consonances communicate.  Connectivity alone says nothing about
*cost*, so this file turns the qualitative statement into a sharp quantitative
one for the extremal pair.

We count steps with an explicitly indexed reachability relation `ReachableIn`.
Two facts pin the distance down.

* **Lower bound (potential argument).** Each voice moves by at most two
  semitones, so a single legal motion changes the vertical interval by at most
  four; by induction an `n`-step path changes it by at most `4 * n`.  Since the
  unison and the octave differ by `12`, no path of length two or less can join
  them, for *any* choice of realizing dyads.
* **Upper bound (explicit path).** The maximally contrary path
  `(0,0) → (-2,2) → (-4,4) → (-6,6)` is legal and realizes the intervals
  `0 → 4 → 8 → 12`.

Hence the free-bass distance between unison and octave sonorities is exactly
three, and the contrary-motion spine of the connectivity file (six steps) is
not geodesic.
-/

namespace SonicCounterpoint

/-- Reachability by a path of exactly `n` legal first-species motions. -/
inductive ReachableIn : ℕ → Dyad → Dyad → Prop
  | refl (x : Dyad) : ReachableIn 0 x x
  | step {n : ℕ} {x y z : Dyad} :
      ReachableIn n x y → PermittedMotion y z → ReachableIn (n + 1) x z

/-- A counted path is a path. -/
theorem reachable_of_reachableIn {n : ℕ} {x y : Dyad} (h : ReachableIn n x y) :
    Reachable x y := by
  induction h with
  | refl _ => exact Relation.ReflTransGen.refl
  | step _ hstep ih => exact ih.tail hstep

/-- A single legal motion moves the vertical interval by at most four
semitones: each voice contributes at most two. -/
theorem interval_change_le_four {x y : Dyad} (h : PermittedMotion x y) :
    (verticalInterval y - verticalInterval x).natAbs ≤ 4 := by
  obtain ⟨-, -, ⟨h0, h1⟩, -⟩ := h
  simp only [verticalInterval]
  omega

/-- **Potential bound.** An `n`-step path moves the vertical interval by at most
`4 * n` semitones. -/
theorem interval_change_le_of_reachableIn {n : ℕ} {x y : Dyad}
    (h : ReachableIn n x y) :
    (verticalInterval y - verticalInterval x).natAbs ≤ 4 * n := by
  induction h with
  | refl x => simp
  | step _ hstep ih =>
      rename_i n x y z _
      have hs := interval_change_le_four hstep
      omega

/-- **Lower bound.** No path of length at most two joins a unison sonority to an
octave sonority, whatever dyads realize them. -/
theorem no_short_path_unison_to_octave (n : ℕ) (hn : n ≤ 2) (x y : Dyad)
    (hx : verticalInterval x = 0) (hy : verticalInterval y = 12) :
    ¬ ReachableIn n x y := by
  intro h
  have hbound := interval_change_le_of_reachableIn h
  rw [hx, hy] at hbound
  omega

/-- The three maximally contrary motions of the geodesic. -/
theorem geodesic_step_one : PermittedMotion (dyad 0 0) (dyad (-2) 2) := by
  norm_num [dyad, PermittedMotion, Consonant, Perfect, Stepwise, SimilarMotion,
    verticalInterval]

theorem geodesic_step_two : PermittedMotion (dyad (-2) 2) (dyad (-4) 4) := by
  norm_num [dyad, PermittedMotion, Consonant, Perfect, Stepwise, SimilarMotion,
    verticalInterval]

theorem geodesic_step_three : PermittedMotion (dyad (-4) 4) (dyad (-6) 6) := by
  norm_num [dyad, PermittedMotion, Consonant, Perfect, Stepwise, SimilarMotion,
    verticalInterval]

/-- **Upper bound.** Three legal motions suffice. -/
theorem reachableIn_three_unison_octave :
    ReachableIn 3 (dyad 0 0) (dyad (-6) 6) :=
  ((ReachableIn.refl (dyad 0 0)).step geodesic_step_one |>.step geodesic_step_two).step
    geodesic_step_three

theorem geodesic_endpoints :
    verticalInterval (dyad 0 0) = 0 ∧ verticalInterval (dyad (-6) 6) = 12 := by
  constructor <;> norm_num [dyad, verticalInterval]

/-- **Exact free-bass distance.** Three legal first-species motions join a
unison to an octave, and no shorter path does so for any realizing dyads. -/
theorem free_bass_distance_unison_octave_eq_three :
    (∃ x y : Dyad, verticalInterval x = 0 ∧ verticalInterval y = 12 ∧
        ReachableIn 3 x y) ∧
      (∀ n ≤ 2, ∀ x y : Dyad, verticalInterval x = 0 → verticalInterval y = 12 →
        ¬ ReachableIn n x y) :=
  ⟨⟨dyad 0 0, dyad (-6) 6, geodesic_endpoints.1, geodesic_endpoints.2,
      reachableIn_three_unison_octave⟩,
    fun n hn x y hx hy => no_short_path_unison_to_octave n hn x y hx hy⟩

/-- The six-step contrary spine used for the connectivity proof is not
geodesic: the same interval jump is achievable in three steps. -/
theorem spine_not_geodesic :
    ∃ x y : Dyad, verticalInterval x = verticalInterval (spine .unison) ∧
      verticalInterval y = verticalInterval (spine .octave) ∧ ReachableIn 3 x y := by
  refine ⟨dyad 0 0, dyad (-6) 6, ?_, ?_, reachableIn_three_unison_octave⟩
  · rw [geodesic_endpoints.1, spine_interval .unison]
    norm_num [SimpleConsonance.semitones]
  · rw [geodesic_endpoints.2, spine_interval .octave]
    norm_num [SimpleConsonance.semitones]

end SonicCounterpoint