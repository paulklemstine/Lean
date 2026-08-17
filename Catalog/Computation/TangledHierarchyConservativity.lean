/-
# Conservativity for Tangled Hierarchies

A formal counterpart of Hofstadter's claim that *strange loops do not corrupt the
levels they sit above*.

We work with a propositional language `Frm α ι` whose atoms are indexed by `α`
and which contains, besides `⊥` and `→`, a family of **internal truth atoms**
`tr c` for `c : ι`.  A *tangled hierarchy* is a denotation function
`den : ι → Frm α ι`: the name `c` denotes the sentence `den c`, and `den c` is
allowed to mention `tr c` itself (a self-loop) or to run around an arbitrarily
long cycle of names.  The associated theory is the set of Tarski biconditionals
`tr c ↔ den c`.

Main results.

* `conservative_of_exists_model`: a tangled extension of a truth-free base theory
  is conservative as soon as every valuation of the old atoms extends to a model
  of the tangle.
* `conseq_tarski_iff_of_positive` (**Conservativity**): if every loop of the
  tangle is *positive* (each `den c` has all its truth atoms in positive
  position), then for every base theory `T` of truth-free sentences and every
  truth-free `ψ`, the tangled extension `T ∪ tarskiAx den` entails `ψ` iff `T`
  does.  The strange loops cost the old theory *nothing*.
* `stratified_conservative` (**Grounded hierarchies**): the same conclusion for
  arbitrary polarity as soon as the dependency relation of the tangle is bounded
  by a rank function (Tarski's stratification), together with
  `stratified_existsUnique_model`: there the internal truth predicate is
  *uniquely* determined.
* `liar_not_conservative` (**Sharpness**): the negative self-loop (the liar)
  destroys conservativity outright — the tangled theory becomes inconsistent.
* `selfLoop_model_ncard_trichotomy` (**The cost of one loop**): for a single
  name, a grounded denotation has exactly one model, a positive self-loop
  exactly two, and a negative self-loop none.
-/
import Mathlib

namespace TangledHierarchy

universe u v

variable {α : Type u} {ι : Type v}

/-! ## Syntax -/

/-- Propositional formulas with atoms from `α` and internal truth atoms from `ι`. -/
inductive Frm (α : Type u) (ι : Type v) where
  | atom : α → Frm α ι
  | fls : Frm α ι
  | imp : Frm α ι → Frm α ι → Frm α ι
  | tr : ι → Frm α ι

/-- Negation. -/
def fnot (φ : Frm α ι) : Frm α ι := Frm.imp φ Frm.fls

/-- Biconditional, encoded with `→` and `⊥`. -/
def fiff (φ ψ : Frm α ι) : Frm α ι :=
  fnot (Frm.imp (Frm.imp φ ψ) (fnot (Frm.imp ψ φ)))

/-- Truth-value of a formula under an atomic valuation `v` and an assignment `w`
of truth values to the names. -/
def eval (v : α → Prop) (w : ι → Prop) : Frm α ι → Prop
  | .atom a => v a
  | .fls => False
  | .imp φ ψ => eval v w φ → eval v w ψ
  | .tr c => w c

/-- Formulas not mentioning the internal truth predicate: the *old* language. -/
def TrFree : Frm α ι → Prop
  | .atom _ => True
  | .fls => True
  | .imp φ ψ => TrFree φ ∧ TrFree ψ
  | .tr _ => False

/-- `Occurs c φ`: the name `c` occurs in `φ`. -/
def Occurs (c : ι) : Frm α ι → Prop
  | .atom _ => False
  | .fls => False
  | .imp φ ψ => Occurs c φ ∨ Occurs c ψ
  | .tr c' => c' = c

/-- `Polar true φ` : every truth atom of `φ` occurs positively;
`Polar false φ` : every truth atom of `φ` occurs negatively. -/
def Polar : Bool → Frm α ι → Prop
  | _, .atom _ => True
  | _, .fls => True
  | b, .imp φ ψ => Polar (!b) φ ∧ Polar b ψ
  | b, .tr _ => b = true

/-! ## Semantics of the tangle -/

/-- A model of the tangled hierarchy: the truth assignment `w` obeys every
Tarski biconditional `w c ↔ eval (den c)`. -/
def TangleModel (den : ι → Frm α ι) (v : α → Prop) (w : ι → Prop) : Prop :=
  ∀ c, w c ↔ eval v w (den c)

/-- The theory of Tarski biconditionals attached to a tangled hierarchy. -/
def tarskiAx (den : ι → Frm α ι) : Set (Frm α ι) :=
  {φ | ∃ c, φ = fiff (Frm.tr c) (den c)}

/-- Satisfaction of a set of formulas. -/
def Sat (v : α → Prop) (w : ι → Prop) (T : Set (Frm α ι)) : Prop :=
  ∀ φ ∈ T, eval v w φ

/-- Semantic consequence. -/
def Conseq (T : Set (Frm α ι)) (ψ : Frm α ι) : Prop :=
  ∀ v w, Sat v w T → eval v w ψ

/-! ## Basic lemmas -/

@[simp] lemma eval_fnot (v : α → Prop) (w : ι → Prop) (φ : Frm α ι) :
    eval v w (fnot φ) ↔ ¬ eval v w φ := by
  simp [fnot, eval]

@[simp] lemma eval_fiff (v : α → Prop) (w : ι → Prop) (φ ψ : Frm α ι) :
    eval v w (fiff φ ψ) ↔ (eval v w φ ↔ eval v w ψ) := by
  simp only [fiff, eval_fnot, eval]
  tauto

lemma sat_tarskiAx_iff (den : ι → Frm α ι) (v : α → Prop) (w : ι → Prop) :
    Sat v w (tarskiAx den) ↔ TangleModel den v w := by
  constructor
  · intro h c
    have := h _ ⟨c, rfl⟩
    simpa [eval] using this
  · rintro h φ ⟨c, rfl⟩
    simpa [eval] using h c

/-- Truth-free formulas do not see the internal truth assignment. -/
lemma eval_congr_of_trFree (v : α → Prop) (w w' : ι → Prop) :
    ∀ {φ : Frm α ι}, TrFree φ → (eval v w φ ↔ eval v w' φ) := by
  intro φ
  induction φ with
  | atom a => intro _; rfl
  | fls => intro _; rfl
  | imp φ ψ ihφ ihψ =>
      rintro ⟨hφ, hψ⟩
      simp only [eval]
      rw [ihφ hφ, ihψ hψ]
  | tr c => intro h; exact absurd h (by simp [TrFree])

/-- Formulas agree under assignments that agree on the occurring names. -/
lemma eval_congr_of_occurs (v : α → Prop) (w w' : ι → Prop) :
    ∀ {φ : Frm α ι}, (∀ c, Occurs c φ → (w c ↔ w' c)) → (eval v w φ ↔ eval v w' φ) := by
  intro φ
  induction φ with
  | atom a => intro _; rfl
  | fls => intro _; rfl
  | imp φ ψ ihφ ihψ =>
      intro h
      simp only [eval]
      rw [ihφ fun c hc => h c (Or.inl hc), ihψ fun c hc => h c (Or.inr hc)]
  | tr c => intro h; exact h c rfl

/-- Monotonicity/antitonicity of evaluation according to polarity. -/
lemma eval_polar (v : α → Prop) {w w' : ι → Prop} (hw : ∀ c, w c → w' c) :
    ∀ (φ : Frm α ι),
      (Polar true φ → eval v w φ → eval v w' φ) ∧
      (Polar false φ → eval v w' φ → eval v w φ) := by
  intro φ
  induction φ with
  | atom a => exact ⟨fun _ h => h, fun _ h => h⟩
  | fls => exact ⟨fun _ h => h, fun _ h => h⟩
  | imp φ ψ ihφ ihψ =>
      refine ⟨?_, ?_⟩
      · rintro ⟨hφ, hψ⟩ h hx
        exact ihψ.1 hψ (h (ihφ.2 (by simpa using hφ) hx))
      · rintro ⟨hφ, hψ⟩ h hx
        exact ihψ.2 hψ (h (ihφ.1 (by simpa using hφ) hx))
  | tr c =>
      refine ⟨fun _ h => hw c h, ?_⟩
      intro h; exact absurd h (by simp [Polar])

/-! ## The abstract conservativity criterion -/

/-- **Conservativity criterion.**  If every valuation of the old atoms extends to
a model of the tangle, the tangled theory has exactly the old truth-free
consequences. -/
theorem conservative_of_exists_model (den : ι → Frm α ι)
    (hex : ∀ v : α → Prop, ∃ w, TangleModel den v w)
    (T : Set (Frm α ι)) (hT : ∀ φ ∈ T, TrFree φ) (ψ : Frm α ι) (hψ : TrFree ψ) :
    Conseq (T ∪ tarskiAx den) ψ ↔ Conseq T ψ := by
  constructor
  · intro h v w hTw
    obtain ⟨w', hw'⟩ := hex v
    have hSat : Sat v w' (T ∪ tarskiAx den) := by
      rintro φ (hφ | hφ)
      · exact (eval_congr_of_trFree v w w' (hT φ hφ)).1 (hTw φ hφ)
      · exact ((sat_tarskiAx_iff den v w').2 hw') φ hφ
    exact (eval_congr_of_trFree v w' w hψ).1 (h v w' hSat)
  · intro h v w hTw
    exact h v w fun φ hφ => hTw φ (Or.inl hφ)

/-- Evaluation only depends on the atomic valuation up to pointwise equivalence. -/
lemma eval_congr_of_atoms (v v' : α → Prop) (w : ι → Prop) (h : ∀ a, v a ↔ v' a) :
    ∀ φ : Frm α ι, eval v w φ ↔ eval v' w φ := by
  intro φ
  induction φ with
  | atom a => exact h a
  | fls => rfl
  | imp φ ψ ihφ ihψ => simp only [eval]; rw [ihφ, ihψ]
  | tr c => rfl

/-- The truth-free diagram of a valuation. -/
def diagram (v : α → Prop) : Set (Frm α ι) :=
  {φ | TrFree φ ∧ eval v (fun _ => False) φ}

lemma diagram_trFree (v : α → Prop) : ∀ φ ∈ (diagram v : Set (Frm α ι)), TrFree φ :=
  fun _ h => h.1

lemma sat_diagram (v : α → Prop) (w : ι → Prop) : Sat v w (diagram (ι := ι) v) :=
  fun _ hφ => (eval_congr_of_trFree v (fun _ => False) w hφ.1).1 hφ.2

/-- Any model of the diagram of `v` has the same atomic valuation as `v`. -/
lemma atoms_of_sat_diagram {v v' : α → Prop} {w : ι → Prop}
    (h : Sat v' w (diagram (ι := ι) v)) (a : α) : v a ↔ v' a := by
  by_cases ha : v a
  · have : eval v' w (Frm.atom a : Frm α ι) :=
      h _ ⟨by simp [TrFree], by simpa [eval] using ha⟩
    simpa [eval, ha] using this
  · have : eval v' w (fnot (Frm.atom a) : Frm α ι) :=
      h _ ⟨by simp [TrFree, fnot], by simpa [eval] using ha⟩
    simp only [eval_fnot, eval] at this
    simp [ha, this]

/-- **Characterization of conservativity.**  A tangled hierarchy is conservative
over *every* truth-free base theory precisely when every valuation of the old
atoms can be expanded to a model of the tangle.  So conservativity is exactly
the solvability of the loop equations. -/
theorem conservative_iff_exists_model (den : ι → Frm α ι) :
    (∀ v : α → Prop, ∃ w, TangleModel den v w) ↔
      (∀ T : Set (Frm α ι), (∀ φ ∈ T, TrFree φ) → ∀ ψ : Frm α ι, TrFree ψ →
        (Conseq (T ∪ tarskiAx den) ψ ↔ Conseq T ψ)) := by
  constructor
  · intro hex T hT ψ hψ
    exact conservative_of_exists_model den hex T hT ψ hψ
  · intro h v
    by_contra hno
    push_neg at hno
    have hcons : Conseq ((diagram (ι := ι) v) ∪ tarskiAx den) Frm.fls := by
      intro v' w' hSat
      have hv : ∀ a, v a ↔ v' a :=
        atoms_of_sat_diagram (fun φ hφ => hSat φ (Or.inl hφ))
      have hmod : TangleModel den v' w' :=
        (sat_tarskiAx_iff den v' w').1 fun φ hφ => hSat φ (Or.inr hφ)
      have hmodv : TangleModel den v w' := by
        intro c
        rw [hmod c]
        exact (eval_congr_of_atoms v v' w' hv (den c)).symm
      exact absurd hmodv (hno w')
    have := (h (diagram v) (diagram_trFree v) Frm.fls (by simp [TrFree])).1 hcons
    have hfls := this v (fun _ => False) (sat_diagram v _)
    simp [eval] at hfls

/-! ## Existence of models for positive tangles (Knaster–Tarski) -/

/-- The one-step "truth revision" operator of a positive tangle, as a monotone map. -/
def revise (den : ι → Frm α ι) (hpos : ∀ c, Polar true (den c)) (v : α → Prop) :
    (ι → Prop) →o (ι → Prop) where
  toFun w := fun c => eval v w (den c)
  monotone' := by
    intro w w' hww c
    exact fun h => (eval_polar v (fun d hd => hww d hd) (den c)).1 (hpos c) h

/-- **Every positive tangled hierarchy has a model**, over any valuation of the
old atoms: the least fixed point of the revision operator. -/
theorem exists_tangleModel_of_positive (den : ι → Frm α ι)
    (hpos : ∀ c, Polar true (den c)) (v : α → Prop) :
    ∃ w, TangleModel den v w := by
  refine ⟨OrderHom.lfp (revise den hpos v), ?_⟩
  intro c
  have h := OrderHom.map_lfp (revise den hpos v)
  have hc := congrFun h c
  exact (iff_of_eq hc).symm

/-- **Conservativity for positive tangled hierarchies.**  Adding all Tarski
biconditionals of an arbitrary positively-looped tangle to a truth-free base
theory produces no new truth-free consequences: the strange loops are free. -/
theorem conseq_tarski_iff_of_positive (den : ι → Frm α ι)
    (hpos : ∀ c, Polar true (den c)) (T : Set (Frm α ι)) (hT : ∀ φ ∈ T, TrFree φ)
    (ψ : Frm α ι) (hψ : TrFree ψ) :
    Conseq (T ∪ tarskiAx den) ψ ↔ Conseq T ψ :=
  conservative_of_exists_model den (exists_tangleModel_of_positive den hpos) T hT ψ hψ

/-- Corollary: a truth-free base theory stays consistent after tangling, as long
as the tangle is positive. -/
theorem consistent_of_positive (den : ι → Frm α ι) (hpos : ∀ c, Polar true (den c))
    (T : Set (Frm α ι)) (hT : ∀ φ ∈ T, TrFree φ)
    (hcon : ¬ Conseq T (Frm.fls : Frm α ι)) :
    ¬ Conseq (T ∪ tarskiAx den) (Frm.fls : Frm α ι) := fun h =>
  hcon ((conseq_tarski_iff_of_positive den hpos T hT Frm.fls (by simp [TrFree])).1 h)

/-! ## Grounded (stratified) hierarchies: existence *and* uniqueness -/

/-- The revision sequence started from the empty extension. -/
def reviseIter (den : ι → Frm α ι) (v : α → Prop) : ℕ → (ι → Prop)
  | 0 => fun _ => False
  | n + 1 => fun c => eval v (reviseIter den v n) (den c)

section Stratified

variable (den : ι → Frm α ι) (rk : ι → ℕ)
  (hrk : ∀ c c', Occurs c' (den c) → rk c' < rk c) (v : α → Prop)

include hrk in
/-- In a stratified tangle the revision sequence is stable strictly above the rank. -/
lemma reviseIter_stable :
    ∀ n, ∀ c, rk c < n → ∀ m, rk c < m →
      (reviseIter den v n c ↔ reviseIter den v m c) := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    intro c hcn m hcm
    match n, m with
    | 0, _ => exact absurd hcn (by omega)
    | n + 1, 0 => exact absurd hcm (by omega)
    | n + 1, m + 1 =>
        simp only [reviseIter]
        refine eval_congr_of_occurs v _ _ ?_
        intro c' hc'
        have hlt : rk c' < rk c := hrk c c' hc'
        exact ih n (by omega) c' (by omega) m (by omega)

/-- The canonical truth assignment of a stratified tangle. -/
def stratModel : ι → Prop := fun c => reviseIter den v (rk c + 1) c

include hrk in
lemma stratModel_isModel : TangleModel den v (stratModel den rk v) := by
  intro c
  have h1 : stratModel den rk v c ↔ eval v (reviseIter den v (rk c)) (den c) := by
    simp [stratModel, reviseIter]
  rw [h1]
  refine eval_congr_of_occurs v _ _ ?_ |>.symm
  intro c' hc'
  have hlt : rk c' < rk c := hrk c c' hc'
  have := reviseIter_stable den rk hrk v (rk c' + 1) c' (by omega) (rk c) (by omega)
  simpa [stratModel] using this

include hrk in
/-- **Stratified tangles have a unique model.** -/
theorem stratified_existsUnique_model : ∃! w, TangleModel den v w := by
  refine ⟨stratModel den rk v, stratModel_isModel den rk hrk v, ?_⟩
  intro w hw
  have key : ∀ n, ∀ c, rk c ≤ n → (w c ↔ stratModel den rk v c) := by
    intro n
    induction n using Nat.strong_induction_on with
    | _ n ih =>
      intro c hcn
      have hm := stratModel_isModel den rk hrk v c
      rw [hw c, hm]
      refine eval_congr_of_occurs v _ _ ?_
      intro c' hc'
      have hlt : rk c' < rk c := hrk c c' hc'
      exact ih (rk c') (by omega) c' le_rfl
  funext c
  exact propext (key (rk c) c le_rfl)

include hrk in
/-- **Conservativity for grounded hierarchies**, with no positivity assumption:
a level-respecting tangle adds nothing to the old theory. -/
theorem stratified_conservative (T : Set (Frm α ι)) (hT : ∀ φ ∈ T, TrFree φ)
    (ψ : Frm α ι) (hψ : TrFree ψ) :
    Conseq (T ∪ tarskiAx den) ψ ↔ Conseq T ψ :=
  conservative_of_exists_model den
    (fun v => ⟨stratModel den rk v, stratModel_isModel den rk hrk v⟩) T hT ψ hψ

end Stratified

/-! ## Internal soundness for the old theory costs nothing -/

lemma trFree_not_occurs : ∀ {φ : Frm α ι}, TrFree φ → ∀ c, ¬ Occurs c φ := by
  intro φ
  induction φ with
  | atom a => intro _ c h; exact h
  | fls => intro _ c h; exact h
  | imp φ ψ ihφ ihψ =>
      rintro ⟨hφ, hψ⟩ c (h | h)
      · exact ihφ hφ c h
      · exact ihψ hψ c h
  | tr c' => intro h; exact absurd h (by simp [TrFree])

/-- A *naming of the old theory*: every name denotes a truth-free sentence.  The
associated Tarski biconditionals are exactly the internal soundness (and
completeness) statements for the old language. -/
theorem groundedNaming_conservative (den : ι → Frm α ι) (hden : ∀ c, TrFree (den c))
    (T : Set (Frm α ι)) (hT : ∀ φ ∈ T, TrFree φ) (ψ : Frm α ι) (hψ : TrFree ψ) :
    Conseq (T ∪ tarskiAx den) ψ ↔ Conseq T ψ :=
  stratified_conservative den (fun _ => 0)
    (fun c c' h => absurd h (trFree_not_occurs (hden c) c')) T hT ψ hψ

/-- Moreover the internal truth predicate of such a naming is uniquely
determined: adding internal soundness for the old theory costs neither a new
theorem nor a new degree of freedom. -/
theorem groundedNaming_unique (den : ι → Frm α ι) (hden : ∀ c, TrFree (den c))
    (v : α → Prop) : ∃! w, TangleModel den v w :=
  stratified_existsUnique_model den (fun _ => 0)
    (fun c c' h => absurd h (trFree_not_occurs (hden c) c')) v

/-! ## Sharpness: the liar loop is not conservative -/

/-- The liar tangle on a single name. -/
def liarDen : Unit → Frm Unit Unit := fun _ => fnot (Frm.tr ())

theorem liar_no_model (v : Unit → Prop) : ¬ ∃ w, TangleModel liarDen v w := by
  rintro ⟨w, hw⟩
  have h := hw ()
  simp only [liarDen, eval_fnot, eval] at h
  tauto

/-- **The negative self-loop destroys conservativity**: the tangled theory over
the empty base theory is inconsistent, while the empty theory is not. -/
theorem liar_not_conservative :
    Conseq ((∅ : Set (Frm Unit Unit)) ∪ tarskiAx liarDen) Frm.fls ∧
      ¬ Conseq (∅ : Set (Frm Unit Unit)) Frm.fls := by
  constructor
  · intro v w hSat
    refine absurd ⟨w, ?_⟩ (liar_no_model v)
    exact (sat_tarskiAx_iff liarDen v w).1 fun φ hφ => hSat φ (Or.inr hφ)
  · intro h
    have := h (fun _ => True) (fun _ => True) (by intro φ hφ; exact absurd hφ (by simp))
    simp [eval] at this

/-! ## The cost of one loop -/

/-- The truth-teller tangle on a single name. -/
def tellerDen : Unit → Frm Unit Unit := fun _ => Frm.tr ()

/-- A grounded denotation on a single name. -/
def groundedDen : Unit → Frm Unit Unit := fun _ => Frm.fls

lemma unit_fun_eq {w : Unit → Prop} {p : Prop} (h : w () ↔ p) : w = fun _ => p := by
  funext u
  cases u
  exact propext h

/-- **The cost of one loop.**  With a single name: a grounded denotation pins the
truth predicate down (one model), a positive self-loop leaves it free (two
models), and a negative self-loop is contradictory (no models). -/
theorem selfLoop_model_ncard_trichotomy (v : Unit → Prop) :
    {w : Unit → Prop | TangleModel groundedDen v w}.ncard = 1 ∧
    {w : Unit → Prop | TangleModel tellerDen v w}.ncard = 2 ∧
    {w : Unit → Prop | TangleModel liarDen v w}.ncard = 0 := by
  refine ⟨?_, ?_, ?_⟩
  · have hset : {w : Unit → Prop | TangleModel groundedDen v w} = {fun _ => False} := by
      ext w
      simp only [Set.mem_setOf_eq, Set.mem_singleton_iff, TangleModel]
      constructor
      · intro h
        exact unit_fun_eq (by simpa [groundedDen, eval] using h ())
      · rintro rfl c
        simp [groundedDen, eval]
    rw [hset, Set.ncard_singleton]
  · have hset : {w : Unit → Prop | TangleModel tellerDen v w}
        = {(fun _ => False), (fun _ => True)} := by
      ext w
      simp only [Set.mem_setOf_eq, Set.mem_insert_iff, Set.mem_singleton_iff, TangleModel]
      constructor
      · intro _
        rcases Classical.em (w ()) with h | h
        · exact Or.inr (unit_fun_eq (by simp [h]))
        · exact Or.inl (unit_fun_eq (by simp [h]))
      · rintro (rfl | rfl) <;> intro c <;> simp [tellerDen, eval]
    rw [hset]
    refine Set.ncard_pair ?_
    intro h
    have := congrFun h ()
    simp at this
  · have hset : {w : Unit → Prop | TangleModel liarDen v w} = ∅ := by
      ext w
      simp only [Set.mem_setOf_eq, Set.mem_empty_iff_false, iff_false]
      exact fun h => liar_no_model v ⟨w, h⟩
    rw [hset, Set.ncard_empty]

/-- The positive self-loop leaves its own truth value undecided: neither it nor
its negation follows from the tangled theory. -/
theorem teller_undecided :
    ¬ Conseq (tarskiAx tellerDen) (Frm.tr ()) ∧
      ¬ Conseq (tarskiAx tellerDen) (fnot (Frm.tr ())) := by
  constructor
  · intro h
    have hmod : TangleModel tellerDen (fun _ => True) (fun _ => False) := by
      intro c; simp [tellerDen, eval]
    have := h (fun _ => True) (fun _ => False)
      ((sat_tarskiAx_iff tellerDen _ _).2 hmod)
    simp [eval] at this
  · intro h
    have hmod : TangleModel tellerDen (fun _ => True) (fun _ => True) := by
      intro c; simp [tellerDen, eval]
    have := h (fun _ => True) (fun _ => True)
      ((sat_tarskiAx_iff tellerDen _ _).2 hmod)
    simp [eval] at this

end TangledHierarchy