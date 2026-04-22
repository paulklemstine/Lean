import Mathlib

/-! # CatalogBuild.Speculative.Forbidden.TwistedMathematics

Auto-generated from theorem catalog database.
Domain: Speculative/Forbidden
Declarations: 7
-/

noncomputable section

/-- **The Well-Ordering Theorem (Zermelo, 1904):**
Every type has a well-ordering. This is equivalent to the
Axiom of Choice, which Lean assumes. We live in a universe
where this horror is true by default. -/
noncomputable def evil_well_order (α : Type*) : LinearOrder α :=
  linearOrderOfSTO (WellOrderingRel)

/-- **The Well-Ordering is Actually Well-Founded:**
Not only can we linearly order any type, but we can well-order it.
Every descending chain terminates. Chaos has a floor. -/
theorem well_ordering_exists (α : Type*) :
    ∃ r : α → α → Prop, IsWellOrder α r := by
  exact ⟨WellOrderingRel, inferInstance⟩

/-- [Section: # CatalogBuild.Speculative.Forbidden.TwistedMathematics
Auto-generated from theorem catalog database.
Domain: Speculative/Forbidden
Declarations: 7] -/
theorem drinkers_paradox [Nonempty α] (drinks : α → Prop) :
    ∃ person : α, drinks person → ∀ x, drinks x := by
  by_contra h;
  simp +zetaDelta at *;
  exact h ( Classical.arbitrary α ) |>.2.elim fun x hx => hx ( h x |>.1 )

/-- [Section: # CatalogBuild.Speculative.Forbidden.TwistedMathematics
Auto-generated from theorem catalog database.
Domain: Speculative/Forbidden
Declarations: 7] -/
theorem not_all_sets_measurable :
    ¬ ∀ (s : Set ℝ), MeasurableSet s := by
  by_contra! h_all_measurable
  have h_card : Cardinal.mk { s : Set ℝ | MeasurableSet s } ≥ Cardinal.mk (Set ℝ) := by
    aesop;
  -- The cardinality of measurable sets is bounded by the continuum.
  have h_measurable_card : Cardinal.mk { s : Set ℝ | MeasurableSet s } ≤ Cardinal.continuum := by
    have h_measurable_card : Cardinal.mk { s : Set ℝ | MeasurableSet s } ≤ Cardinal.mk (Set ℕ) := by
      have h_borel_card : Cardinal.mk {s : Set ℝ | MeasurableSet s} ≤ Cardinal.mk (Set ℕ) := by
        have h_borel_gen : ∃ (S : Set (Set ℝ)), S.Countable ∧ MeasurableSpace.generateFrom S = borel ℝ := by
          use Set.range (fun q : ℚ × ℚ => Set.Ioo (q.1 : ℝ) (q.2 : ℝ));
          refine' ⟨ Set.countable_range _, _ ⟩;
          refine' le_antisymm _ _;
          · exact MeasurableSpace.generateFrom_le fun s hs => by rcases hs with ⟨ q, rfl ⟩ ; exact measurableSet_Ioo;
          · intro s hs;
            convert hs using 1;
            refine' le_antisymm _ _;
            · exact MeasurableSpace.generateFrom_le fun s hs => by rcases hs with ⟨ q, rfl ⟩ ; exact measurableSet_Ioo;
            · -- Any open set in ℝ can be written as a countable union of intervals with rational endpoints.
              have h_open_union : ∀ U : Set ℝ, IsOpen U → ∃ (S : Set (ℚ × ℚ)), S.Countable ∧ U = ⋃ (q : ℚ × ℚ) (hq : q ∈ S), Set.Ioo (q.1 : ℝ) (q.2 : ℝ) := by
                intro U hU
                have h_open_union : ∀ x ∈ U, ∃ q : ℚ × ℚ, x ∈ Set.Ioo (q.1 : ℝ) (q.2 : ℝ) ∧ Set.Ioo (q.1 : ℝ) (q.2 : ℝ) ⊆ U := by
                  intro x hx; rcases Metric.isOpen_iff.mp hU x hx with ⟨ ε, εpos, hε ⟩ ; rcases exists_rat_btwn ( show x - ε < x by linarith ) with ⟨ q₁, hq₁₁, hq₁₂ ⟩ ; rcases exists_rat_btwn ( show x < x + ε by linarith ) with ⟨ q₂, hq₂₁, hq₂₂ ⟩ ; exact ⟨ ⟨ q₁, q₂ ⟩, ⟨ by linarith, by linarith ⟩, fun y hy => hε <| mem_ball_iff_norm.mpr <| abs_lt.mpr ⟨ by linarith [ hy.1 ], by linarith [ hy.2 ] ⟩ ⟩ ;
                choose! q hq₁ hq₂ using h_open_union;
                use Set.image q U;
                exact ⟨ Set.to_countable _, Set.Subset.antisymm ( fun x hx => by aesop ) fun x hx => by aesop ⟩;
              refine' MeasurableSpace.generateFrom_le _;
              intro U hU; obtain ⟨ S, hS_countable, rfl ⟩ := h_open_union U hU; exact MeasurableSet.biUnion hS_countable fun q hq => MeasurableSpace.measurableSet_generateFrom <| by aesop;
        have h_borel_card : ∀ {S : Set (Set ℝ)}, S.Countable → Cardinal.mk {s : Set ℝ | MeasurableSpace.GenerateMeasurable S s} ≤ Cardinal.mk (Set ℕ) := by
          intro S hS_countable
          have h_borel_card : Cardinal.mk {s : Set ℝ | MeasurableSpace.GenerateMeasurable S s} ≤ Cardinal.mk (Set ℕ) := by
            have h_borel_gen : ∀ {S : Set (Set ℝ)}, S.Countable → Cardinal.mk {s : Set ℝ | MeasurableSpace.GenerateMeasurable S s} ≤ Cardinal.mk (Set ℕ) := by
              intro S hS_countable
              exact (by
              have := @MeasurableSpace.cardinal_generateMeasurable_le ℝ S;
              refine' le_trans this _;
              cases max_cases ( Cardinal.mk S ) 2 <;> simp +decide [ * ];
              exact le_trans ( Cardinal.power_le_power_right ( show Cardinal.mk S ≤ Cardinal.aleph0 from by simpa using hS_countable.to_subtype ) ) ( by simp +decide [ Cardinal.aleph0_lt_continuum ] ))
            exact h_borel_gen hS_countable;
          exact h_borel_card;
        convert h_borel_card h_borel_gen.choose_spec.1 using 1;
        congr! 2;
        convert h_borel_gen.choose_spec.2.symm using 1;
        simp +decide [ Set.ext_iff, MeasurableSpace.ext_iff ];
        congr! 2;
      exact h_borel_card;
    exact h_measurable_card.trans ( by simp +decide [ Cardinal.mk_real ] );
  simp_all +decide [ Cardinal.mk_real ];
  exact absurd h_measurable_card ( not_le_of_gt ( Cardinal.cantor _ ) )

theorem hilbert_hotel_one_guest :
    ∃ f : ℕ → ℕ, Injective f ∧ 0 ∉ Set.range f := by
  -- Define a function that is injective and does not contain zero in its range.
  use fun n => n + 1; simp [Nat.succ_ne_zero, Function.Injective]

theorem hilbert_hotel_countable :
    ∃ f : ℕ × ℕ → ℕ, Bijective f := by
  -- The product of two countable types is countable, and since ℕ is countable, ℕ × ℕ is also countable.
  have h_countable : Nonempty (ℕ × ℕ ≃ ℕ) := by
    exact ( Cardinal.eq.1 <| by simp +decide );
  exact ⟨ _, h_countable.some.bijective ⟩

theorem nat_self_similar :
    ∃ f : ℕ → ℕ, Injective f ∧ ¬ Surjective f := by
  exact ⟨ fun n => 2 * n, fun n m h => by linarith, fun h => by have := h ( 1 : ℕ ) ; obtain ⟨ n, hn ⟩ := this; linarith [ show n = 0 by linarith ] ⟩

end
