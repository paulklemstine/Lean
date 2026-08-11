import Logic.ImmortalityHierarchy

/-!
# Structure theory of survival games

Three structural themes, all building on `Catalog/Novelty/ImmortalityGame.lean` and
`Catalog/Logic/ImmortalityHierarchy.lean`.

* **Completeness of the survival value.**  `clockIso` exhibits every survival game as order
  isomorphic to the canonical clock of its own value, and `value_eq_iff_orderIso` concludes
  that two games have equal value precisely when their clocks are order isomorphic: the value
  is a complete invariant.
* **Concatenation of lives.**  `concatGame` glues two games end to end and
  `concatGame_value` shows values add.  Ordinal addition is not commutative, and
  `concatGame_not_comm` turns this into a statement about survival: a single extra moment
  *after* an `ω`-life is a real gain, while the same moment *before* it is invisible
  (`concatGame_point_finite`).
* **Refinement stability.**  `RefinementStable o` says that a further `ω`-refinement of a game
  of value `o` buys nothing.  `refinementStable_opow_iff` characterizes stability inside the
  scale `ω ^ a`: it holds exactly when `ω ≤ a`.  Hence every finite refinement depth is
  unstable while the finite-refinement limit `ω ^ ω` is stable.
-/

namespace ImmortalityStructure

open Ordinal ImmortalityGame ImmortalityHierarchy

/-! ## Completeness of the survival value -/

/-- Every survival game is order-isomorphic to the canonical clock of its own survival value:
the value is a *complete* invariant of a game. -/
noncomputable def clockIso (G : SurvivalGame) : G.Moment ≃o (G.value).ToType :=
  StrictMono.orderIsoOfSurjective
    (fun x => Ordinal.ToType.mk ⟨typein (α := G.Moment) (· < ·) x,
      typein_lt_type _ x⟩)
    (fun _ _ h => by
      have := (typein_lt_typein (α := G.Moment) (· < ·)).2 h
      simpa [Subtype.mk_lt_mk] using this)
    (by
      intro z
      obtain ⟨p, hp⟩ : ∃ p : Set.Iio (G.value), Ordinal.ToType.mk p = z :=
        ⟨Ordinal.ToType.mk.symm z, by simp⟩
      obtain ⟨x, hx⟩ := typein_surj ((· < ·) : G.Moment → G.Moment → Prop)
        (show (p : Ordinal) < type ((· < ·) : G.Moment → G.Moment → Prop) from p.2)
      refine ⟨x, ?_⟩
      rw [← hp]
      have hsub : (⟨typein (α := G.Moment) (· < ·) x, typein_lt_type _ x⟩ :
          Set.Iio (G.value)) = p :=
        Subtype.ext (show typein (α := G.Moment) (· < ·) x = (p : Ordinal) from hx)
      beta_reduce
      rw [hsub])

/-- **Completeness of the survival value.**  Two survival games have the same value exactly
when their clocks are order-isomorphic. -/
theorem value_eq_iff_orderIso (G H : SurvivalGame) :
    G.value = H.value ↔ Nonempty (G.Moment ≃o H.Moment) := by
  constructor
  · intro h
    refine ⟨(clockIso G).trans ?_⟩
    rw [h]
    exact (clockIso H).symm
  · rintro ⟨e⟩
    exact e.toRelIsoLT.ordinal_type_eq

/-- Every ordinal is realized as a survival value. -/
theorem value_surjective : Function.Surjective SurvivalGame.value := by
  intro o
  exact ⟨{ Moment := o.ToType }, type_toType o⟩

/-! ## Concatenating lives: the additive structure -/

instance instIsWellOrderSumLex (G H : SurvivalGame) :
    IsWellOrder (G.Moment ⊕ₗ H.Moment) (· < ·) :=
  inferInstanceAs (IsWellOrder (G.Moment ⊕ H.Moment) (Sum.Lex (· < ·) (· < ·)))

/-- Living through `G` and then through `H`. -/
def concatGame (G H : SurvivalGame) : SurvivalGame where
  Moment := Lex (G.Moment ⊕ H.Moment)

@[simp] theorem concatGame_value (G H : SurvivalGame) :
    (concatGame G H).value = G.value + H.value := by
  show type (Sum.Lex _ _) = _
  rw [type_sum_lex]
  rfl

/-- **Concatenation is not commutative**: an extra moment tacked on *after* an `ω`-life is a
genuine gain, while an extra moment *before* it is invisible. -/
theorem concatGame_not_comm :
    (concatGame finiteGame pointGame).value ≠ (concatGame pointGame finiteGame).value := by
  rw [concatGame_value, concatGame_value, finiteGame_value, pointGame_value, one_add_omega0]
  exact (lt_add_one ω).ne'

/-- Prefixing a finite prelude to an infinite life changes nothing. -/
theorem concatGame_point_finite :
    (concatGame pointGame finiteGame).value = finiteGame.value := by
  rw [concatGame_value, pointGame_value, finiteGame_value, one_add_omega0]

/-! ## Refinement-stable survival values -/

/-- A survival value is **refinement stable** when a further `ω`-refinement buys nothing. -/
def RefinementStable (o : Ordinal.{0}) : Prop := ω * o = o

/-- **Stability criterion.**  A value of the form `ω ^ a` is refinement stable exactly when the
exponent is already infinite.  In particular every finite-depth value `ω ^ (k+1)` is unstable
while the finite-refinement limit `ω ^ ω` is stable. -/
theorem refinementStable_opow_iff (a : Ordinal.{0}) :
    RefinementStable (ω ^ a) ↔ ω ≤ a := by
  rw [RefinementStable, ← opow_one_add]
  constructor
  · intro h
    have h1 : 1 + a = a := (Ordinal.isNormal_opow one_lt_omega0).strictMono.injective h
    by_contra hlt
    push_neg at hlt
    obtain ⟨n, rfl⟩ := lt_omega0.1 hlt
    have : ((1 + n : ℕ) : Ordinal.{0}) = ((n : ℕ) : Ordinal.{0}) := by
      push_cast
      exact h1
    have hn : (1 + n : ℕ) = n := by exact_mod_cast this
    omega
  · intro h
    rw [one_add_of_omega0_le h]

theorem refinementStable_omega_opow_omega : RefinementStable (ω ^ ω) :=
  (refinementStable_opow_iff ω).2 le_rfl

theorem not_refinementStable_finite (k : ℕ) :
    ¬ RefinementStable (ω ^ ((k : Ordinal.{0}) + 1)) := by
  intro h
  have hle := (refinementStable_opow_iff _).1 h
  have hlt : ((k : Ordinal.{0}) + 1) < ω := by
    have h1 : ((k : Ordinal.{0}) + 1) = ((k + 1 : ℕ) : Ordinal.{0}) := by simp
    rw [h1]
    exact nat_lt_omega0 _
  exact absurd hle (not_le.2 hlt)

/-- Stability of a value is exactly the statement that the `ω`-refinement of a game with that
value does not extend the life of Mortal. -/
theorem refinementStable_iff_no_gain (G : SurvivalGame) :
    RefinementStable G.value ↔ (nondetExt G).value = G.value := by
  rw [RefinementStable, nondetExt_value]

end ImmortalityStructure