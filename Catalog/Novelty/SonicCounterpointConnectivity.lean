import Novelty.SonicCounterpointCategory

/-!
# Refutation of seven-state strong connectivity for canonical counterpoint motions

This file settles the conjecture that, for the seven canonical interval
representatives of `Novelty.SonicCounterpointCategory`, the reflexive-transitive
closure of `CanonicalMotion` is total.

**The conjecture is false.**  The canonical realization fixes the bass at pitch
zero, so a legal motion between canonical representatives can only change the
upper voice, hence can only change the vertical interval by at most a whole
tone.  The consonance ladder `0, 3, 4, 7, 8, 9, 12` has gaps of size three at
`0 → 3`, `4 → 7` and `9 → 12`, so it splits into four blocks

  `{0}`, `{3, 4}`, `{7, 8, 9}`, `{12}`,

which we call *registers*.  Registers are a complete invariant of the relation:
`CanonicalMotion i j` holds **iff** `i` and `j` lie in the same register.
Consequently the one-step table is already an equivalence relation, the
reflexive-transitive closure adds nothing, exactly `15` of the `49` ordered
pairs are reachable, and `34` ordered pairs — among them `unison → octave` — are
unreachable.

Three further layers of structure are proved here.

* **Threshold / phase transition.**  Parameterizing the admissible melodic step
  width by `w`, reachability among the seven intervals is total **iff** `w ≥ 3`.
  So strong connectivity fails for every stepwise rule and is restored exactly
  when leaps of a minor third are admitted.
* **Universality of the register invariant.**  Every function constant along
  canonical motions factors through `register`; no finer invariant exists.
* **The failure is an artifact of the frozen bass.**  Inside the full dyad
  system of `PermittedMotion`, where both voices may move, all seven
  consonances are mutually reachable: an explicit contrary-motion spine
  `(0,0) → (-1,2) → (-1,3) → (-2,5) → (-2,6) → (-2,7) → (-3,9)` realizes the
  intervals `0, 3, 4, 7, 8, 9, 12` in a single legal path, and `PermittedMotion`
  is symmetric, so the path can be traversed in either direction.

Thus the conjecture is refuted in its stated form and replaced by a sharp
guarded version.
-/

namespace SonicCounterpoint

/-! ## The register invariant -/

/-- The connected block ("register") of a canonical consonance: unison, the
thirds, the fifth–sixth cluster, and the octave. -/
def register : SimpleConsonance → Fin 4
  | .unison => 0
  | .minorThird => 1
  | .majorThird => 1
  | .perfectFifth => 2
  | .minorSixth => 2
  | .majorSixth => 2
  | .octave => 3

/-- Exhaustive check on the `7 × 7` table: a canonical one-step motion is legal
exactly when source and target share a register. -/
theorem canonicalMotion_iff_register (i j : SimpleConsonance) :
    CanonicalMotion i j ↔ register i = register j := by
  revert i j; decide

/-- Hence the raw canonical table is reflexive. -/
theorem canonicalMotion_refl (i : SimpleConsonance) : CanonicalMotion i i :=
  (canonicalMotion_iff_register i i).2 rfl

/-- Hence the raw canonical table is symmetric. -/
theorem canonicalMotion_symm {i j : SimpleConsonance} (h : CanonicalMotion i j) :
    CanonicalMotion j i :=
  (canonicalMotion_iff_register j i).2 ((canonicalMotion_iff_register i j).1 h).symm

/-- Hence the raw canonical table is transitive: unlike the ambient dyad rule
(`permittedMotion_not_transitive`), the canonical restriction *is* closed under
composition. -/
theorem canonicalMotion_trans {i j k : SimpleConsonance}
    (hij : CanonicalMotion i j) (hjk : CanonicalMotion j k) : CanonicalMotion i k :=
  (canonicalMotion_iff_register i k).2
    (((canonicalMotion_iff_register i j).1 hij).trans
      ((canonicalMotion_iff_register j k).1 hjk))

/-- Reachability among the seven canonical representatives. -/
def CanonicalReachable (i j : SimpleConsonance) : Prop :=
  Relation.ReflTransGen CanonicalMotion i j

/-- The register is a reachability invariant, and it is a complete one. -/
theorem canonicalReachable_iff_register (i j : SimpleConsonance) :
    CanonicalReachable i j ↔ register i = register j := by
  constructor
  · intro h
    induction h with
    | refl => rfl
    | tail _ hbc ih => exact ih.trans ((canonicalMotion_iff_register _ _).1 hbc)
  · intro h
    exact Relation.ReflTransGen.single ((canonicalMotion_iff_register i j).2 h)

/-- Reachability is decidable through the register invariant. -/
instance canonicalReachableDecidable (i j : SimpleConsonance) :
    Decidable (CanonicalReachable i j) :=
  decidable_of_iff _ (canonicalReachable_iff_register i j).symm

/-- Taking the reflexive-transitive closure of the canonical table adds no new
morphisms: the table is already saturated. -/
theorem canonicalReachable_iff_canonicalMotion (i j : SimpleConsonance) :
    CanonicalReachable i j ↔ CanonicalMotion i j :=
  (canonicalReachable_iff_register i j).trans (canonicalMotion_iff_register i j).symm

/-! ## The refutation -/

/-- **Counterexample.** The unison cannot reach the octave: every canonical
motion preserves the register, and unison and octave sit in registers `0` and
`3`. -/
theorem unison_not_canonicalReachable_octave :
    ¬ CanonicalReachable .unison .octave := by
  rw [canonicalReachable_iff_register]
  decide

/-- **Main theorem: the seven-state strong-connectivity conjecture is false.**
The reflexive-transitive closure of `CanonicalMotion` is not total. -/
theorem canonical_strong_connectivity_refuted :
    ¬ ∀ i j : SimpleConsonance, CanonicalReachable i j := fun h =>
  unison_not_canonicalReachable_octave (h .unison .octave)

/-- The octave is in fact totally isolated: it reaches, and is reached by, only
itself. -/
theorem octave_isolated (i : SimpleConsonance) :
    (CanonicalReachable .octave i ∨ CanonicalReachable i .octave) → i = .octave := by
  revert i; decide

/-- The unison is likewise isolated. -/
theorem unison_isolated (i : SimpleConsonance) :
    (CanonicalReachable .unison i ∨ CanonicalReachable i .unison) → i = .unison := by
  revert i; decide

/-! ## Exact census of the reachability relation -/

/-- The ordered pairs joined by a finite legal path. -/
def canonicalReachablePairs : Finset (SimpleConsonance × SimpleConsonance) :=
  Finset.univ.filter fun p => CanonicalReachable p.1 p.2

/-- The ordered pairs that no finite legal path joins. -/
def canonicalUnreachablePairs : Finset (SimpleConsonance × SimpleConsonance) :=
  Finset.univ.filter fun p => ¬ CanonicalReachable p.1 p.2

/-- Exactly fifteen of the forty-nine ordered pairs are reachable. -/
theorem canonicalReachablePairs_card : canonicalReachablePairs.card = 15 := by
  decide

/-- Exactly thirty-four ordered pairs refute totality; a single one suffices. -/
theorem canonicalUnreachablePairs_card : canonicalUnreachablePairs.card = 34 := by
  decide

/-- The reachable pairs are precisely the one-step legal motions already
tabulated in the catalog file: closure is idempotent on the nose. -/
theorem canonicalReachablePairs_eq_allCanonicalMotions :
    canonicalReachablePairs = allCanonicalMotions := by
  decide

/-- The two censuses partition the `49` ordered pairs. -/
theorem canonical_pair_census :
    canonicalReachablePairs.card + canonicalUnreachablePairs.card
      = Fintype.card SimpleConsonance * Fintype.card SimpleConsonance := by
  rw [canonicalReachablePairs_card, canonicalUnreachablePairs_card, simpleConsonance_card]

/-- The seven states fall into exactly four strongly connected components. -/
theorem canonical_component_count : (Finset.univ.image register).card = 4 := by
  decide

/-- Strong connectivity would force a single component; there are four. -/
theorem component_count_obstructs_connectivity :
    (Finset.univ.image register).card ≠ 1 := by
  rw [canonical_component_count]
  omega

/-- **Universality of the register invariant.** Any quantity preserved by
one-step canonical motions is already determined by the register, so `register`
is the finest possible invariant and the block decomposition is canonical. -/
theorem register_universal {α : Type*} (f : SimpleConsonance → α)
    (hf : ∀ i j, CanonicalMotion i j → f i = f j) :
    ∀ i j, register i = register j → f i = f j := fun i j h =>
  hf i j ((canonicalMotion_iff_register i j).2 h)

/-! ## The step-width threshold: a sharp phase transition

The failure is caused by the width of the admissible melodic step.  Replacing
"at most a whole tone" by "at most `w` semitones" gives a one-parameter family;
connectivity switches on exactly at `w = 3`.
-/

/-- The `w`-bounded interval motion on canonical representatives. -/
def GapMotion (w : ℕ) (i j : SimpleConsonance) : Prop :=
  ((j.semitones : ℤ) - (i.semitones : ℤ)).natAbs ≤ w

instance gapMotionDecidable (w : ℕ) (i j : SimpleConsonance) :
    Decidable (GapMotion w i j) := by
  unfold GapMotion; infer_instance

/-- Reachability in the `w`-bounded model. -/
def GapReachable (w : ℕ) (i j : SimpleConsonance) : Prop :=
  Relation.ReflTransGen (GapMotion w) i j

theorem gapMotion_mono {w w' : ℕ} (h : w ≤ w') {i j : SimpleConsonance}
    (hij : GapMotion w i j) : GapMotion w' i j := le_trans hij h

theorem gapMotion_symmetric (w : ℕ) : Symmetric (GapMotion w) := by
  intro i j h
  have hneg : ((i.semitones : ℤ) - (j.semitones : ℤ))
      = -(((j.semitones : ℤ) - (i.semitones : ℤ))) := by ring
  have hAbs : ((i.semitones : ℤ) - (j.semitones : ℤ)).natAbs
      = ((j.semitones : ℤ) - (i.semitones : ℤ)).natAbs := by
    rw [hneg, Int.natAbs_neg]
  show ((i.semitones : ℤ) - (j.semitones : ℤ)).natAbs ≤ w
  rw [hAbs]
  exact h

/-- At the historical step width `w = 2` the parameterized model reproduces the
canonical table exactly. -/
theorem gapMotion_two_iff_canonicalMotion (i j : SimpleConsonance) :
    GapMotion 2 i j ↔ CanonicalMotion i j := by
  revert i j; decide

/-- **Subcritical regime.** For every step width `w ≤ 2` the unison still fails
to reach the octave, so no stepwise rule can be strongly connected. -/
theorem gap_subcritical_not_total (w : ℕ) (hw : w ≤ 2) :
    ¬ GapReachable w .unison .octave := by
  intro h
  refine unison_not_canonicalReachable_octave ?_
  refine h.mono ?_
  intro a b hab
  exact (gapMotion_two_iff_canonicalMotion a b).1 (gapMotion_mono hw hab)

/-- The critical spine: at width `3` the unison reaches every consonance. -/
theorem gapReachable_three_of_unison (i : SimpleConsonance) :
    GapReachable 3 .unison i := by
  have e1 : GapMotion 3 .unison .minorThird := by decide
  have e2 : GapMotion 3 .minorThird .majorThird := by decide
  have e3 : GapMotion 3 .majorThird .perfectFifth := by decide
  have e4 : GapMotion 3 .perfectFifth .minorSixth := by decide
  have e5 : GapMotion 3 .minorSixth .majorSixth := by decide
  have e6 : GapMotion 3 .majorSixth .octave := by decide
  have r1 : GapReachable 3 .unison .minorThird := Relation.ReflTransGen.single e1
  have r2 : GapReachable 3 .unison .majorThird := r1.tail e2
  have r3 : GapReachable 3 .unison .perfectFifth := r2.tail e3
  have r4 : GapReachable 3 .unison .minorSixth := r3.tail e4
  have r5 : GapReachable 3 .unison .majorSixth := r4.tail e5
  have r6 : GapReachable 3 .unison .octave := r5.tail e6
  cases i
  · exact Relation.ReflTransGen.refl
  · exact r1
  · exact r2
  · exact r3
  · exact r4
  · exact r5
  · exact r6

/-- **Supercritical regime.** As soon as leaps of a minor third are admitted,
the seven-state system is strongly connected. -/
theorem gap_supercritical_total (w : ℕ) (hw : 3 ≤ w) (i j : SimpleConsonance) :
    GapReachable w i j := by
  have hsymm : Symmetric (GapReachable 3) :=
    Relation.ReflTransGen.symmetric (gapMotion_symmetric 3)
  have h3 : GapReachable 3 i j :=
    (hsymm (gapReachable_three_of_unison i)).trans (gapReachable_three_of_unison j)
  exact h3.mono fun _ _ hab => gapMotion_mono hw hab

/-- **Sharp threshold.** Strong connectivity of the seven canonical states holds
precisely for step widths at least a minor third.  The historical first-species
width `2` lies strictly below the threshold, which is why the conjecture fails. -/
theorem gap_connectivity_threshold (w : ℕ) :
    (∀ i j : SimpleConsonance, GapReachable w i j) ↔ 3 ≤ w := by
  constructor
  · intro h
    by_contra hw
    exact gap_subcritical_not_total w (by omega) (h .unison .octave)
  · intro hw
    exact gap_supercritical_total w hw

/-! ## The obstruction is an artifact of the frozen bass

In the ambient dyad system both voices move, and then all seven consonances do
communicate.  So the refutation above is not a statement about counterpoint but
about the canonical realization chosen in the catalog file.
-/

theorem similarMotion_symm {x y : Dyad} (h : SimilarMotion x y) : SimilarMotion y x :=
  h.symm

/-- The first-species one-step rule is symmetric: every legal motion may be
retrograded. -/
theorem permittedMotion_symm {x y : Dyad} (h : PermittedMotion x y) :
    PermittedMotion y x := by
  obtain ⟨hx, hy, hstep, hperf⟩ := h
  refine ⟨hy, hx, ⟨?_, ?_⟩, ?_⟩
  · have := hstep.1
    omega
  · have := hstep.2
    omega
  · rintro ⟨h1, h2, h3⟩
    exact hperf ⟨h2, h1, similarMotion_symm h3⟩

/-- Consequently finite-path reachability between dyads is symmetric. -/
theorem reachable_symm {x y : Dyad} (h : Reachable x y) : Reachable y x :=
  Relation.ReflTransGen.symmetric (fun _ _ => permittedMotion_symm) h

/-- A contrary-motion spine realizing each of the seven consonances with a
moving bass. -/
def spine : SimpleConsonance → Dyad
  | .unison => dyad 0 0
  | .minorThird => dyad (-1) 2
  | .majorThird => dyad (-1) 3
  | .perfectFifth => dyad (-2) 5
  | .minorSixth => dyad (-2) 6
  | .majorSixth => dyad (-2) 7
  | .octave => dyad (-3) 9

/-- The spine really does realize the intended intervals. -/
theorem spine_interval (i : SimpleConsonance) :
    verticalInterval (spine i) = (i.semitones : ℤ) := by
  cases i <;>
    norm_num [spine, dyad, verticalInterval, SimpleConsonance.semitones]

/-- Each consecutive pair of the spine is a legal first-species motion. -/
theorem spine_edge_unison_minorThird :
    PermittedMotion (spine .unison) (spine .minorThird) := by
  norm_num [spine, dyad, PermittedMotion, Consonant, Perfect, Stepwise,
    SimilarMotion, verticalInterval]

theorem spine_edge_minorThird_majorThird :
    PermittedMotion (spine .minorThird) (spine .majorThird) := by
  norm_num [spine, dyad, PermittedMotion, Consonant, Perfect, Stepwise,
    SimilarMotion, verticalInterval]

theorem spine_edge_majorThird_perfectFifth :
    PermittedMotion (spine .majorThird) (spine .perfectFifth) := by
  norm_num [spine, dyad, PermittedMotion, Consonant, Perfect, Stepwise,
    SimilarMotion, verticalInterval]

theorem spine_edge_perfectFifth_minorSixth :
    PermittedMotion (spine .perfectFifth) (spine .minorSixth) := by
  norm_num [spine, dyad, PermittedMotion, Consonant, Perfect, Stepwise,
    SimilarMotion, verticalInterval]

theorem spine_edge_minorSixth_majorSixth :
    PermittedMotion (spine .minorSixth) (spine .majorSixth) := by
  norm_num [spine, dyad, PermittedMotion, Consonant, Perfect, Stepwise,
    SimilarMotion, verticalInterval]

theorem spine_edge_majorSixth_octave :
    PermittedMotion (spine .majorSixth) (spine .octave) := by
  norm_num [spine, dyad, PermittedMotion, Consonant, Perfect, Stepwise,
    SimilarMotion, verticalInterval]

/-- From the unison sonority the whole spine is reachable. -/
theorem reachable_spine_of_unison (i : SimpleConsonance) :
    Reachable (spine .unison) (spine i) := by
  have r1 : Reachable (spine .unison) (spine .minorThird) :=
    Relation.ReflTransGen.single spine_edge_unison_minorThird
  have r2 : Reachable (spine .unison) (spine .majorThird) :=
    r1.tail spine_edge_minorThird_majorThird
  have r3 : Reachable (spine .unison) (spine .perfectFifth) :=
    r2.tail spine_edge_majorThird_perfectFifth
  have r4 : Reachable (spine .unison) (spine .minorSixth) :=
    r3.tail spine_edge_perfectFifth_minorSixth
  have r5 : Reachable (spine .unison) (spine .majorSixth) :=
    r4.tail spine_edge_minorSixth_majorSixth
  have r6 : Reachable (spine .unison) (spine .octave) :=
    r5.tail spine_edge_majorSixth_octave
  cases i
  · exact Relation.ReflTransGen.refl
  · exact r1
  · exact r2
  · exact r3
  · exact r4
  · exact r5
  · exact r6

/-- Every pair of spine sonorities is mutually reachable. -/
theorem spine_reachable (i j : SimpleConsonance) :
    Reachable (spine i) (spine j) :=
  (reachable_symm (reachable_spine_of_unison i)).trans (reachable_spine_of_unison j)

/-- **Guarded positive form of the conjecture.** Once the bass is allowed to
move, every consonance can be connected to every other by a finite legal
first-species path.  The seven-state obstruction is therefore created solely by
the frozen-bass canonical realization. -/
theorem consonances_connected_with_free_bass (i j : SimpleConsonance) :
    ∃ x y : Dyad,
      verticalInterval x = (i.semitones : ℤ) ∧
      verticalInterval y = (j.semitones : ℤ) ∧ Reachable x y :=
  ⟨spine i, spine j, spine_interval i, spine_interval j, spine_reachable i j⟩

/-- **Dichotomy.** Strong connectivity fails on the canonical frozen-bass states
and simultaneously holds in the ambient free-bass dyad system. -/
theorem connectivity_dichotomy :
    (¬ ∀ i j : SimpleConsonance, CanonicalReachable i j) ∧
      (∀ i j : SimpleConsonance, ∃ x y : Dyad,
        verticalInterval x = (i.semitones : ℤ) ∧
        verticalInterval y = (j.semitones : ℤ) ∧ Reachable x y) :=
  ⟨canonical_strong_connectivity_refuted, consonances_connected_with_free_bass⟩

end SonicCounterpoint