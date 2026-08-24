import Applications.JokeSurpriseAlgebra

/-!
# Humor is a colimit: universality, submodularity, and the failure of expected resolutions

This file continues the programme begun in `Applications.JokeSurpriseAlgebra`, where a
*setup* was modelled by a nonempty finite configuration of resolutions `S ⊆ ℝ` and its
*surprise* by the range `humor S = max' S - min' S`. There, surprise was shown to be a
monotone functor on the refinement poset, subadditive under shared context.

Here we push the categorical slogan of the programme — **"the punchline is a colimit,
the expected resolution is a limit"** — to its logical conclusion, and we test the
associated universality conjecture ("the funniest jokes are the terminal ones").

## Results

### The exact combination law
* `humor_submodular` : surprise is a **submodular valuation**:
  `humor (S ∪ T) + humor (S ∩ T) ≤ humor S + humor T` whenever the two setups share a
  reading. This *strictly strengthens* the catalog's `humor_union_le_add_of_inter`,
  which is recovered as `humor_union_le_add_of_inter_of_submodular`.
* `humor_inter_le_union` : the colimit (joint reading) is always at least as surprising
  as the limit (shared reading).

### Colimits exist, limits need not
* `jointIsColimit` : the joint setup `S ∪ T` **is** the binary coproduct of `S` and `T`
  in the category of setups; so every pair of jokes has a colimit.
* `no_binaryProduct_of_disjoint` : two setups with no shared reading have **no** binary
  product. The expected resolution — the limit — genuinely may fail to exist, while the
  punchline — the colimit — always does. This is the precise sense in which humor is a
  colimit.

### Universality
* `le_obj_of_isTerminal` : for *any* category `C` and *any* real-valued functor
  `F : C ⥤ ℝ`, a terminal object maximises `F`. Terminality is therefore a purely
  categorical certificate of maximal surprise.
* `JokeOver` : the category of jokes with a fixed setup `S`, bounded by an ambient
  universe `U`; `isTerminal_ambient` shows the ambient universe is its terminal object, and
  `humor_le_of_isTerminal` shows universal jokes are the funniest ones.
* `humor_eq_of_isTerminal` : any two universal jokes over the same setup have exactly
  the same surprise — the humor of a universal joke is a well-defined invariant.

### Where the conjecture breaks
* `humor_not_reflects_refinement` : surprise does **not** reflect the order. There are
  strictly refining setups of identical surprise, so maximal surprise does *not* imply
  terminality.
* `exists_maximal_humor_not_terminal` : consequently there is a joke category with a
  non-terminal object of maximal humor. The implication "universal ⇒ funniest" is a
  theorem; its converse "funniest ⇒ universal" is **false**.

-- !-- Lab Notes -- !--
Hypothesis (H1): surprise is not merely subadditive under shared context, but exactly
submodular — the union/intersection defect is controlled by the four extremes.
Hypothesis (H2): the slogan "humor is a colimit" is literally true: the category of
setups has all binary coproducts but not all binary products.
Hypothesis (H3): "funniest = universal = terminal" is an equivalence.

Experiment: H1 was reduced to the four inequalities
`min' S ≤ min' (S ∩ T) ≤ max' (S ∩ T) ≤ max' S` (and the same for `T`) plus the
identity `max (A,B) + min (A,B) = A + B`, discharged by `split_ifs <;> linarith` after
`max_def`/`min_def`. H2 was proved by exhibiting the colimit cocone explicitly
(`BinaryCofan.IsColimit.mk`, all coherence conditions free by thinness) and by deriving
a contradiction from `prod.fst`/`prod.snd` for disjoint setups. H3 was tested on the
pair `{0,1} ⊂ {0,1/2,1}`.

Analysis: H1 and H2 survive. H3 is **false**, and the failure is structural rather
than accidental: surprise only sees the two extremal readings, so it is blind to every
refinement that adds interior readings. Terminality implies maximal surprise
(`humor_le_of_isTerminal`), but maximal surprise is attained on a whole up-set of
non-terminal objects. The correct guarded statement is: universal jokes maximise
surprise, and all universal jokes over a fixed setup are equally surprising.

Critique: `no_binaryProduct_of_disjoint` needs disjointness, not merely distinctness —
with a shared reading the intersection *is* the product. The counterexample to H3 uses
a genuinely strict refinement (`{0,1} ⊊ {0,1/2,1}`), so it is not an artefact of a
degenerate category.

Synthesis: colimits are unconditional and limits are conditional; universality is a
sufficient but not necessary condition for maximal humor; and surprise is an exactly
submodular valuation on the refinement lattice.
-/

open CategoryTheory Limits Finset JokeSurpriseAlgebra

namespace JokeColimitUniversality

/-! ### The exact combination law -/

/-- **Surprise is a submodular valuation.** If two setups share a reading, then the
surprise of their joint reading plus the surprise of their shared reading is at most
the sum of their individual surprises. -/
theorem humor_submodular (S T : Finset ℝ) (hS : S.Nonempty) (hT : T.Nonempty)
    (h : (S ∩ T).Nonempty) :
    humor (S ∪ T) hS.inl + humor (S ∩ T) h ≤ humor S hS + humor T hT := by
  have h1 : (S ∩ T).max' h ≤ S.max' hS :=
    S.le_max' _ (Finset.mem_of_mem_inter_left ((S ∩ T).max'_mem h))
  have h2 : (S ∩ T).max' h ≤ T.max' hT :=
    T.le_max' _ (Finset.mem_of_mem_inter_right ((S ∩ T).max'_mem h))
  have h3 : S.min' hS ≤ (S ∩ T).min' h :=
    S.min'_le _ (Finset.mem_of_mem_inter_left ((S ∩ T).min'_mem h))
  have h4 : T.min' hT ≤ (S ∩ T).min' h :=
    T.min'_le _ (Finset.mem_of_mem_inter_right ((S ∩ T).min'_mem h))
  unfold humor
  rw [Finset.max'_union hS hT, Finset.min'_union hS hT]
  simp only [max_def, min_def]
  split_ifs <;> linarith

/-- Surprise is nonnegative. -/
theorem humor_nonneg (S : Finset ℝ) (hS : S.Nonempty) : 0 ≤ humor S hS :=
  sub_nonneg.2 (S.min'_le_max' hS)

/-- **Subadditivity is a consequence of submodularity.** This recovers the catalog
result `JokeSurpriseAlgebra.humor_union_le_add_of_inter` from `humor_submodular`. -/
theorem humor_union_le_add_of_inter_of_submodular (S T : Finset ℝ) (hS : S.Nonempty)
    (hT : T.Nonempty) (h : (S ∩ T).Nonempty) :
    humor (S ∪ T) hS.inl ≤ humor S hS + humor T hT := by
  have := humor_submodular S T hS hT h
  have := humor_nonneg (S ∩ T) h
  linarith

/-- **The colimit is at least as surprising as the limit.** The joint reading of two
setups is never less surprising than their shared reading. -/
theorem humor_inter_le_union (S T : Finset ℝ) (hS : S.Nonempty) (h : (S ∩ T).Nonempty) :
    humor (S ∩ T) h ≤ humor (S ∪ T) hS.inl := by
  refine le_trans (humor_inter_le_left S T h hS) ?_
  exact humor_union_ge_left S T hS

/-! ### Colimits always exist -/

/-- The **joint setup**: telling both jokes at once. -/
noncomputable def joint (S T : Setup) : Setup := ⟨S.1 ∪ T.1, S.2.inl⟩

/-- The cocone exhibiting the joint setup as a candidate coproduct. -/
noncomputable def cofanJoint (S T : Setup) : BinaryCofan S T :=
  BinaryCofan.mk (P := joint S T) (homOfLE Finset.subset_union_left)
    (homOfLE Finset.subset_union_right)

/-- **The punchline is a colimit.** The joint setup `S ∪ T` is the binary coproduct of
`S` and `T` in the category of setups. -/
noncomputable def jointIsColimit (S T : Setup) : IsColimit (cofanJoint S T) :=
  BinaryCofan.IsColimit.mk _
    (fun {_} f g => homOfLE (Finset.union_subset (leOfHom f) (leOfHom g)))
    (fun _ _ => Subsingleton.elim _ _) (fun _ _ => Subsingleton.elim _ _)
    (fun _ _ _ _ _ => Subsingleton.elim _ _)

/-- Every pair of setups has a colimit. -/
theorem hasBinaryCoproduct (S T : Setup) : HasBinaryCoproduct S T :=
  ⟨⟨⟨_, jointIsColimit S T⟩⟩⟩

/-- **The expected resolution may fail to exist.** Two setups with no shared reading
have no binary product in the category of setups: there is no limit for the joke to
subvert, only a colimit for it to land in. -/
theorem no_binaryProduct_of_disjoint (S T : Setup) (hd : Disjoint S.1 T.1) :
    ¬ HasBinaryProduct S T := by
  intro h
  have h1 : (Limits.prod S T).1 ⊆ S.1 := leOfHom (Limits.prod.fst (X := S) (Y := T))
  have h2 : (Limits.prod S T).1 ⊆ T.1 := leOfHom (Limits.prod.snd (X := S) (Y := T))
  obtain ⟨x, hx⟩ := (Limits.prod S T).2
  exact (Finset.disjoint_left.mp hd (h1 hx)) (h2 hx)

/-! ### Universality: terminal objects maximise every invariant -/

/-- **Terminal objects maximise every real-valued invariant.** If `F : C ⥤ ℝ` is any
functor to the linear order `ℝ` viewed as a category, then `F` attains its maximum at
any terminal object. This is the categorical core of the universality conjecture. -/
theorem le_obj_of_isTerminal {C : Type*} [Category C] (F : C ⥤ ℝ) {T : C}
    (hT : IsTerminal T) (X : C) : F.obj X ≤ F.obj T :=
  leOfHom (F.map (hT.from X))

/-- Dually, initial objects minimise every real-valued invariant. -/
theorem obj_le_of_isInitial {C : Type*} [Category C] (F : C ⥤ ℝ) {I : C}
    (hI : IsInitial I) (X : C) : F.obj I ≤ F.obj X :=
  leOfHom (F.map (hI.to X))

/-- The **category of jokes over a setup** `S`, inside an ambient universe `U` of
readings: an object is a setup refining `S` and contained in `U`, and a morphism is a
refinement. -/
def JokeOver (S U : Setup) : Type := {T : Setup // S ≤ T ∧ T ≤ U}

instance (S U : Setup) : Preorder (JokeOver S U) := Subtype.preorder _

/-- The ambient universe of readings, viewed as a joke over `S`. -/
def ambient (S U : Setup) (h : S ≤ U) : JokeOver S U := ⟨U, h, le_refl U⟩

/-- **The universe is the universal joke.** In the category of jokes over `S` bounded
by `U`, the object `U` is terminal: every joke admits a unique refinement morphism into
it. -/
def isTerminal_ambient (S U : Setup) (h : S ≤ U) : IsTerminal (ambient S U h) :=
  IsTerminal.ofUniqueHom (fun J => homOfLE J.2.2) (fun _ _ => Subsingleton.elim _ _)

/-- Surprise, as an invariant of jokes over a fixed setup. -/
noncomputable def humorOver {S U : Setup} (J : JokeOver S U) : ℝ := humorS J.1

theorem humorOver_monotone {S U : Setup} : Monotone (humorOver (S := S) (U := U)) :=
  fun _ _ h => humorS_monotone h

/-- Surprise as a functor on the category of jokes over a fixed setup. -/
noncomputable def humorOverFunctor (S U : Setup) : JokeOver S U ⥤ ℝ :=
  (humorOver_monotone (S := S) (U := U)).functor

/-- **Universal jokes are the funniest.** If a joke over `S` is terminal, its surprise
dominates that of every other joke with the same setup. -/
theorem humor_le_of_isTerminal {S U : Setup} {T : JokeOver S U} (hT : IsTerminal T)
    (J : JokeOver S U) : humorOver J ≤ humorOver T :=
  le_obj_of_isTerminal (humorOverFunctor S U) hT J

/-- **The humor of a universal joke is well defined.** Any two universal jokes over the
same setup have exactly the same surprise. -/
theorem humor_eq_of_isTerminal {S U : Setup} {T T' : JokeOver S U} (hT : IsTerminal T)
    (hT' : IsTerminal T') : humorOver T = humorOver T' :=
  le_antisymm (humor_le_of_isTerminal hT' T) (humor_le_of_isTerminal hT T')

/-! ### The converse fails -/

/-- A convenient way to compute surprise from explicit extremes. -/
theorem humorS_eq_of_bounds (S : Setup) (m M : ℝ) (hm : m ∈ S.1) (hM : M ∈ S.1)
    (hlb : ∀ x ∈ S.1, m ≤ x) (hub : ∀ x ∈ S.1, x ≤ M) : humorS S = M - m := by
  have h1 : S.1.max' S.2 = M :=
    le_antisymm (Finset.max'_le _ _ _ hub) (S.1.le_max' _ hM)
  have h2 : S.1.min' S.2 = m :=
    le_antisymm (S.1.min'_le _ hm) (Finset.le_min' _ _ _ hlb)
  simp [humorS, h1, h2]

/-- The two-reading setup `{0, 1}`. -/
noncomputable def pun : Setup := ⟨{0, 1}, ⟨0, by simp⟩⟩

/-- Its refinement by an intermediate reading, `{0, 1/2, 1}`. -/
noncomputable def punRefined : Setup := ⟨{0, 1/2, 1}, ⟨0, by simp⟩⟩

theorem humorS_pun : humorS pun = 1 := by
  refine (humorS_eq_of_bounds pun 0 1 (by simp [pun]) (by simp [pun]) ?_ ?_).trans (by ring)
  · intro x hx; simp [pun] at hx; rcases hx with rfl | rfl <;> norm_num
  · intro x hx; simp [pun] at hx; rcases hx with rfl | rfl <;> norm_num

theorem humorS_punRefined : humorS punRefined = 1 := by
  refine (humorS_eq_of_bounds punRefined 0 1 (by simp [punRefined]) (by simp [punRefined])
    ?_ ?_).trans (by ring)
  · intro x hx; simp [punRefined] at hx; rcases hx with rfl | rfl | rfl <;> norm_num
  · intro x hx; simp [punRefined] at hx; rcases hx with rfl | rfl | rfl <;> norm_num

theorem pun_lt_punRefined : pun < punRefined := by
  constructor
  · intro x hx
    simp [pun] at hx
    rcases hx with rfl | rfl <;> simp [punRefined]
  · intro hle
    have hmem : (1/2 : ℝ) ∈ pun.1 := hle (by simp [punRefined])
    simp [pun] at hmem

/-- **Surprise does not reflect refinement.** There are strictly refining setups with
identical surprise: adding an interior reading changes the joke but not its measured
humor. Hence maximal humor cannot characterise terminality. -/
theorem humor_not_reflects_refinement :
    ∃ S T : Setup, S < T ∧ humorS S = humorS T :=
  ⟨pun, punRefined, pun_lt_punRefined, by rw [humorS_pun, humorS_punRefined]⟩

/-- **The converse of the universality theorem is false.** There is a category of jokes
over a fixed setup containing a non-terminal object whose humor is maximal. So
"universal ⇒ funniest" holds (`humor_le_of_isTerminal`) but "funniest ⇒ universal" does
not. -/
theorem exists_maximal_humor_not_terminal :
    ∃ (S U : Setup) (J : JokeOver S U),
      (∀ K : JokeOver S U, humorOver K ≤ humorOver J) ∧ ¬ IsTop J := by
  refine ⟨pun, punRefined, ⟨pun, le_refl _, le_of_lt pun_lt_punRefined⟩, ?_, ?_⟩
  · rintro ⟨K, -, hKU⟩
    have : humorS K ≤ humorS punRefined := humorS_monotone hKU
    simpa [humorOver, humorS_pun, humorS_punRefined] using this
  · intro htop
    have h := htop ⟨punRefined, le_of_lt pun_lt_punRefined, le_refl _⟩
    have h2 : punRefined ≤ pun := h
    exact absurd h2 (not_le_of_gt pun_lt_punRefined)

end JokeColimitUniversality