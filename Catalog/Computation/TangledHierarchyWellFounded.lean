/-
# Well-founded tangled hierarchies, and the collapse of their height

`Catalog.Computation.TangledHierarchyConservativity` proves determinacy and
conservativity for hierarchies graded by a *natural number* rank.  Here the
grading is dropped: all that is assumed is that the **dependency relation**

    `c' ≺ c  ↔  the name c' occurs in the sentence den c`

is well-founded.  The truth predicate is then built by well-founded recursion
and is *unique*, whatever the polarities are; conservativity follows.

* `evalD` / `evalD_eq`: evaluation of a formula against a partial assignment
  defined only on the names it actually mentions.
* `wfModel_isModel`, `wf_existsUnique_model`: existence and uniqueness of the
  internal truth predicate of a well-founded tangle.
* `wf_conservative`: conservativity over any truth-free base theory.
* `wellFounded_iff_rank` (**height collapse**): because sentences are finite
  objects, a tangle is well-founded *iff* it carries an `ℕ`-valued rank with
  strictly descending dependencies.  So a finitary tangled hierarchy can be
  infinitely tall but never *transfinitely* tall: every name sits at a finite
  level.  This is a König-type argument, and it is what makes the well-founded
  and the `ℕ`-graded theories coincide.
* `omegaDen`: an infinite, nowhere-positive tangle of unbounded finite height,
  determined and conservative.
-/
import Catalog.Computation.TangledHierarchyConservativity

namespace TangledHierarchy

universe u v

variable {α : Type u} {ι : Type v}

/-! ## Evaluation against a partial assignment -/

/-- Evaluate `φ` using an assignment defined only on the names occurring in `φ`. -/
def evalD (v : α → Prop) : (φ : Frm α ι) → ((c : ι) → Occurs c φ → Prop) → Prop
  | .atom a, _ => v a
  | .fls, _ => False
  | .imp φ ψ, g =>
      evalD v φ (fun c h => g c (Or.inl h)) → evalD v ψ (fun c h => g c (Or.inr h))
  | .tr c', g => g c' rfl

/-- On a total assignment, `evalD` is ordinary evaluation. -/
lemma evalD_eq (v : α → Prop) (w : ι → Prop) :
    ∀ φ : Frm α ι, evalD v φ (fun c _ => w c) = eval v w φ := by
  intro φ
  induction φ with
  | atom a => rfl
  | fls => rfl
  | imp φ ψ ihφ ihψ => simp only [evalD, eval, ihφ, ihψ]
  | tr c => rfl

/-- `evalD` only depends on the values of the partial assignment. -/
lemma evalD_congr (v : α → Prop) :
    ∀ (φ : Frm α ι) (g g' : (c : ι) → Occurs c φ → Prop),
      (∀ c h, g c h ↔ g' c h) → (evalD v φ g ↔ evalD v φ g') := by
  intro φ
  induction φ with
  | atom a => intro g g' _; rfl
  | fls => intro g g' _; rfl
  | imp φ ψ ihφ ihψ =>
      intro g g' h
      simp only [evalD]
      rw [ihφ _ _ (fun c hc => h c (Or.inl hc)), ihψ _ _ (fun c hc => h c (Or.inr hc))]
  | tr c => intro g g' h; exact h c rfl

/-! ## The transfinite Tarskian hierarchy -/

section WellFounded

variable (den : ι → Frm α ι)

/-- The dependency relation of a tangled hierarchy. -/
def depends (den : ι → Frm α ι) (c' c : ι) : Prop := Occurs c' (den c)

variable (hwf : WellFounded (depends den)) (v : α → Prop)

/-- The truth predicate of a well-founded tangle, built by transfinite recursion
along the dependency relation. -/
noncomputable def wfModel : ι → Prop :=
  hwf.fix (fun c g => evalD v (den c) (fun c' h => g c' h))

include hwf in
/-- The transfinite hierarchy solves every loop equation. -/
theorem wfModel_isModel : TangleModel den v (wfModel den hwf v) := by
  intro c
  have hfix := WellFounded.fix_eq hwf (fun c g => evalD v (den c) (fun c' h => g c' h)) c
  have h1 : wfModel den hwf v c
      = evalD v (den c) (fun c' _ => wfModel den hwf v c') := hfix
  rw [h1, evalD_eq v (wfModel den hwf v) (den c)]

include hwf in
/-- **The internal truth predicate of a well-founded tangle is unique**, whatever
the polarities of the dependencies. -/
theorem wf_existsUnique_model : ∃! w, TangleModel den v w := by
  refine ⟨wfModel den hwf v, wfModel_isModel den hwf v, ?_⟩
  intro w hw
  have key : ∀ c, w c ↔ wfModel den hwf v c := by
    intro c
    induction c using hwf.induction with
    | _ c ih =>
      rw [hw c, (wfModel_isModel den hwf v) c]
      exact eval_congr_of_occurs v _ _ fun c' hc' => ih c' hc'
  funext c
  exact propext (key c)

include hwf in
/-- **Conservativity for well-founded tangled hierarchies of arbitrary height.** -/
theorem wf_conservative (T : Set (Frm α ι)) (hT : ∀ φ ∈ T, TrFree φ)
    (ψ : Frm α ι) (hψ : TrFree ψ) :
    Conseq (T ∪ tarskiAx den) ψ ↔ Conseq T ψ :=
  conservative_of_exists_model den
    (fun v => ⟨wfModel den hwf v, wfModel_isModel den hwf v⟩) T hT ψ hψ

end WellFounded

/-- `ℕ`-graded hierarchies are well-founded: height `≤ ω` is a special case. -/
theorem wellFounded_of_rank (den : ι → Frm α ι) (rk : ι → ℕ)
    (hrk : ∀ c c', Occurs c' (den c) → rk c' < rk c) : WellFounded (depends den) :=
  Subrelation.wf (fun {c'} {c} h => hrk c c' h) (InvImage.wf rk Nat.lt_wfRel.wf)

/-! ## Height collapse: well-foundedness is exactly `ℕ`-rank -/

/-- The (finite) list of names occurring in a formula. -/
def nameList : Frm α ι → List ι
  | .atom _ => []
  | .fls => []
  | .imp φ ψ => nameList φ ++ nameList ψ
  | .tr c => [c]

lemma mem_nameList : ∀ (φ : Frm α ι) (c : ι), c ∈ nameList φ ↔ Occurs c φ := by
  intro φ
  induction φ with
  | atom a => intro c; simp [nameList, Occurs]
  | fls => intro c; simp [nameList, Occurs]
  | imp φ ψ ihφ ihψ => intro c; simp [nameList, Occurs, ihφ, ihψ]
  | tr c' => intro c; simp [nameList, Occurs, eq_comm]

/-- Maximum of a family indexed by the members of a list. -/
def listMax : (l : List ι) → ((c : ι) → c ∈ l → ℕ) → ℕ
  | [], _ => 0
  | a :: t, f => max (f a (by simp)) (listMax t (fun c h => f c (by simp [h])))

lemma le_listMax : ∀ (l : List ι) (f : (c : ι) → c ∈ l → ℕ) (c : ι) (h : c ∈ l),
    f c h ≤ listMax l f := by
  intro l
  induction l with
  | nil => intro f c h; exact absurd h (by simp)
  | cons a t ih =>
      intro f c h
      rcases List.mem_cons.1 h with rfl | h'
      · exact le_max_left _ _
      · exact le_trans (ih (fun c hc => f c (by simp [hc])) c h') (le_max_right _ _)

/-- The canonical `ℕ`-rank of a well-founded tangle: one more than the maximum
rank of the finitely many names its sentence mentions. -/
noncomputable def wfRank (den : ι → Frm α ι) (hwf : WellFounded (depends den)) : ι → ℕ :=
  hwf.fix (fun c g => listMax (nameList (den c)) (fun c' h => g c' ((mem_nameList _ _).1 h)) + 1)

theorem wfRank_lt (den : ι → Frm α ι) (hwf : WellFounded (depends den)) (c c' : ι)
    (h : Occurs c' (den c)) : wfRank den hwf c' < wfRank den hwf c := by
  have hfix := WellFounded.fix_eq hwf
    (fun c g => listMax (nameList (den c)) (fun c' h => g c' ((mem_nameList _ _).1 h)) + 1) c
  have hc : wfRank den hwf c
      = listMax (nameList (den c)) (fun c' _ => wfRank den hwf c') + 1 := hfix
  rw [hc]
  have hmem : c' ∈ nameList (den c) := (mem_nameList (den c) c').2 h
  have := le_listMax (nameList (den c)) (fun c' _ => wfRank den hwf c') c' hmem
  omega

/-- **Height collapse.**  Because every sentence mentions only finitely many
names, a tangled hierarchy is well-founded if and only if it admits an
`ℕ`-valued rank with strictly descending dependencies.  A finitary tangle can be
infinitely tall, but never transfinitely tall: no name lives above level `ω`. -/
theorem wellFounded_iff_rank (den : ι → Frm α ι) :
    WellFounded (depends den) ↔
      ∃ rk : ι → ℕ, ∀ c c', Occurs c' (den c) → rk c' < rk c := by
  constructor
  · intro hwf
    exact ⟨wfRank den hwf, fun c c' h => wfRank_lt den hwf c c' h⟩
  · rintro ⟨rk, hrk⟩
    exact wellFounded_of_rank den rk hrk

/-! ## An infinitely tall tangle -/

/-- Names: `ℕ ⊕ Unit`, thought of as the levels `0, 1, 2, …` together with one
extra name looking back down at level `0`.  Every link is a negation, so the
tangle is nowhere positive, and the levels are unbounded. -/
def omegaDen : (ℕ ⊕ Unit) → Frm Unit (ℕ ⊕ Unit)
  | .inl 0 => Frm.fls
  | .inl (n + 1) => fnot (Frm.tr (.inl n))
  | .inr () => Frm.tr (.inl 0)

lemma omegaDen_depends {c' c : ℕ ⊕ Unit} (h : depends omegaDen c' c) :
    (∃ n, c = .inl (n + 1) ∧ c' = .inl n) ∨ (c = .inr () ∧ c' = .inl 0) := by
  match c with
  | .inl 0 => exact absurd h (by simp [depends, omegaDen, Occurs])
  | .inl (n + 1) =>
      refine Or.inl ⟨n, rfl, ?_⟩
      have : (Sum.inl n : ℕ ⊕ Unit) = c' := by
        simpa [depends, omegaDen, Occurs, fnot] using h
      exact this.symm
  | .inr () =>
      refine Or.inr ⟨rfl, ?_⟩
      have : (Sum.inl 0 : ℕ ⊕ Unit) = c' := by
        simpa [depends, omegaDen, Occurs] using h
      exact this.symm

/-- The infinitely tall tangle is well-founded, with alternating (negative)
links all the way down. -/
theorem omegaDen_wellFounded : WellFounded (depends omegaDen) := by
  have hrk : ∀ c c' : ℕ ⊕ Unit, depends omegaDen c' c →
      (Sum.elim (fun n => n) (fun _ => 0) c' : ℕ) < Sum.elim (fun n => n) (fun _ => 0) c ∨
        (c = .inr () ∧ c' = .inl 0) := by
    intro c c' h
    rcases omegaDen_depends h with ⟨n, rfl, rfl⟩ | ⟨rfl, rfl⟩
    · exact Or.inl (by simp)
    · exact Or.inr ⟨rfl, rfl⟩
  constructor
  intro c
  have haccl : ∀ n : ℕ, Acc (depends omegaDen) (.inl n) := by
    intro n
    induction n with
    | zero =>
        constructor
        intro y hy
        exact absurd hy (by simp [depends, omegaDen, Occurs])
    | succ n ih =>
        constructor
        intro y hy
        rcases omegaDen_depends hy with ⟨m, hm, rfl⟩ | ⟨hm, _⟩
        · have : m = n := (by simpa using hm : n = m).symm
          subst this
          exact ih
        · exact absurd hm (by simp)
  match c with
  | .inl n => exact haccl n
  | .inr () =>
      constructor
      intro y hy
      rcases omegaDen_depends hy with ⟨m, hm, _⟩ | ⟨_, rfl⟩
      · exact absurd hm (by simp)
      · exact haccl 0

/-- The infinitely tall tangle is conservative, although it is nowhere positive
(all its links are negations). -/
theorem omegaDen_conservative (T : Set (Frm Unit (ℕ ⊕ Unit))) (hT : ∀ φ ∈ T, TrFree φ)
    (ψ : Frm Unit (ℕ ⊕ Unit)) (hψ : TrFree ψ) :
    Conseq (T ∪ tarskiAx omegaDen) ψ ↔ Conseq T ψ :=
  wf_conservative omegaDen omegaDen_wellFounded T hT ψ hψ

/-- Its truth predicate is nevertheless completely determined: alternating
negations along infinitely many levels leave no freedom at all. -/
theorem omegaDen_determined (v : Unit → Prop) :
    ∃! w, TangleModel omegaDen v w :=
  wf_existsUnique_model omegaDen omegaDen_wellFounded v

end TangledHierarchy