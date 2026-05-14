import Mathlib

/-!
# Tropical Myhill–Nerode Theorem: Canonical Package

This file develops the full Myhill–Nerode theory for tropical (min-plus) weighted
languages over `WithTop ℕ`, including:

1. **Weighted Nerode equivalence** and the recognizability characterization
2. **Right congruence** structure of Nerode equivalence
3. **Canonical Nerode automaton** construction with correctness proof
4. **Minimality theorem**: every recognizing automaton has at least as many
   reachable states as the Nerode automaton
5. **Syntactic monoid characterization** of tropical recognizability
6. **Dynamic programming / shortest-path bridge**

## Main Results

* `tropical_recognizable_iff_finite_nerode` — The main Myhill–Nerode biconditional
* `nerode_right_congr` — Nerode equivalence is a right congruence
* `nerodeAutomaton_correct` — The Nerode automaton recognizes its language
* `nerode_index_le_card` — Minimality: Nerode states ≤ states of any recognizing DFA
* `tropical_recognizable_iff_finite_syntactic` — Syntactic characterization
* `dp_bellman_residual` — Bridge to dynamic programming semantics
-/

universe u

namespace TropicalMyhillNerode

/-! ## Core Definitions -/

/-- Tropical weight type: natural numbers extended with infinity. -/
abbrev TropWeight := WithTop ℕ

/-- A tropical weighted language: assigns a cost in `WithTop ℕ` to each word. -/
abbrev TropLang (α : Type*) := List α → TropWeight

/-- A deterministic tropical (min-plus) finite automaton. -/
structure TropicalDFA (α σ : Type*) where
  step : σ → α → σ
  init : σ
  out  : σ → TropWeight

variable {α σ τ : Type*}

/-- State reached after processing a word from state `q`. -/
def evalFrom (A : TropicalDFA α σ) (q : σ) (w : List α) : σ :=
  w.foldl A.step q

/-- Cost assigned to a word by the automaton. -/
def evalCost (A : TropicalDFA α σ) (w : List α) : TropWeight :=
  A.out (evalFrom A A.init w)

/-- An automaton recognizes a weighted language. -/
def recognizes (A : TropicalDFA α σ) (L : TropLang α) : Prop :=
  ∀ w, evalCost A w = L w

/-! ## Residuals and Nerode Equivalence -/

/-- The right residual of a weighted language at prefix `u`. -/
def residual (L : TropLang α) (u : List α) : TropLang α :=
  fun v => L (u ++ v)

/-- Nerode equivalence: equality of residual languages. -/
def NerodeEq (L : TropLang α) (u v : List α) : Prop :=
  residual L u = residual L v

/-- Nerode equivalence as a setoid. -/
def NerodeSetoid (L : TropLang α) : Setoid (List α) where
  r := NerodeEq L
  iseqv := ⟨fun _ => rfl, fun h => h.symm, fun h₁ h₂ => h₁.trans h₂⟩

/-- Finite Nerode index: finitely many distinct residuals. -/
def FiniteNerodeIndex (L : TropLang α) : Prop :=
  Set.Finite (Set.range (residual L))

/-- Tropical recognizability. -/
def TropicalRecognizable {α : Type u} (L : TropLang α) : Prop :=
  ∃ (S : Type u) (_ : Fintype S), ∃ A : TropicalDFA α S, recognizes A L

/-! ## Basic Lemmas -/

@[simp]
lemma evalFrom_nil (A : TropicalDFA α σ) (q : σ) :
    evalFrom A q [] = q := rfl

@[simp]
lemma evalFrom_cons (A : TropicalDFA α σ) (q : σ) (a : α) (w : List α) :
    evalFrom A q (a :: w) = evalFrom A (A.step q a) w := rfl

lemma evalFrom_append (A : TropicalDFA α σ) (q : σ) (u v : List α) :
    evalFrom A q (u ++ v) = evalFrom A (evalFrom A q u) v := by
  simp [evalFrom, List.foldl_append]

lemma residual_nil (L : TropLang α) : residual L [] = L :=
  funext fun _ => rfl

lemma residual_append (L : TropLang α) (u v : List α) :
    residual L (u ++ v) = residual (residual L u) v :=
  funext fun w => by simp [residual, List.append_assoc]

lemma NerodeEq_iff_forall (L : TropLang α) (u v : List α) :
    NerodeEq L u v ↔ ∀ w, L (u ++ w) = L (v ++ w) :=
  ⟨fun h w => congr_fun h w, fun h => funext h⟩

/-! ## Right Congruence -/

/-- **Right congruence**: Nerode equivalence is preserved by appending any word. -/
theorem nerode_right_congr (L : TropLang α) {u v : List α} (w : List α)
    (h : NerodeEq L u v) : NerodeEq L (u ++ w) (v ++ w) := by
  simp only [NerodeEq]
  rw [residual_append, residual_append, h]

/-- Right congruence, one-letter version. -/
theorem nerode_step_congr (L : TropLang α) {u v : List α} (a : α)
    (h : NerodeEq L u v) : NerodeEq L (u ++ [a]) (v ++ [a]) :=
  nerode_right_congr L [a] h

/-- Nerode equivalence implies equal language values. -/
theorem nerode_output_well_defined (L : TropLang α) {u v : List α}
    (h : NerodeEq L u v) : L u = L v := by
  have := congr_fun h []
  simp [residual] at this
  exact this

/-! ## Recognizable ⇒ Finite Nerode Index -/

/-- Future-cost function of a state. -/
def residualOfState (A : TropicalDFA α σ) (q : σ) : TropLang α :=
  fun w => A.out (evalFrom A q w)

lemma residual_eq_residualOfState (A : TropicalDFA α σ)
    (L : TropLang α) (hA : recognizes A L) (u : List α) :
    residual L u = residualOfState A (evalFrom A A.init u) := by
  funext w
  simp [residual, residualOfState]
  rw [← hA]
  simp [evalCost, evalFrom_append]

lemma range_residual_subset (A : TropicalDFA α σ)
    (L : TropLang α) (hA : recognizes A L) :
    Set.range (residual L) ⊆ Set.range (residualOfState A) := by
  rintro _ ⟨u, rfl⟩
  exact ⟨evalFrom A A.init u, (residual_eq_residualOfState A L hA u).symm⟩

theorem recognizable_implies_finite_nerode [Fintype σ]
    (A : TropicalDFA α σ) (L : TropLang α)
    (hA : recognizes A L) : FiniteNerodeIndex L :=
  Set.Finite.subset (Set.toFinite (Set.range (residualOfState A)))
    (range_residual_subset A L hA)

/-! ## Nerode Automaton Construction -/

/-- Step on residual classes. -/
noncomputable def nerodeStep (L : TropLang α)
    (f : ↥(Set.range (residual L))) (a : α) : ↥(Set.range (residual L)) :=
  ⟨fun w => f.val (a :: w), by
    obtain ⟨u, hu⟩ := f.prop
    exact ⟨u ++ [a], funext fun w => by simp [residual, ← hu, List.append_assoc]⟩⟩

/-- The canonical Nerode automaton. -/
noncomputable def nerodeAutomaton (L : TropLang α) :
    TropicalDFA α ↥(Set.range (residual L)) where
  step := nerodeStep L
  init := ⟨L, ⟨[], residual_nil L⟩⟩
  out := fun ⟨f, _⟩ => f []

lemma nerodeStep_val (L : TropLang α) (u : List α)
    (hu : residual L u ∈ Set.range (residual L)) (a : α) :
    (nerodeStep L ⟨residual L u, hu⟩ a).val = residual L (u ++ [a]) := by
  ext w
  simp [nerodeStep, residual, List.append_assoc]

lemma nerode_evalFrom_eq (L : TropLang α) (u w : List α)
    (hu : residual L u ∈ Set.range (residual L)) :
    (evalFrom (nerodeAutomaton L) ⟨residual L u, hu⟩ w).val =
    residual L (u ++ w) := by
  induction w generalizing u with
  | nil => simp [residual_append, residual_nil]
  | cons a w ih =>
    simp only [evalFrom_cons, nerodeAutomaton]
    have hmem : residual L (u ++ [a]) ∈ Set.range (residual L) :=
      Set.mem_range.mpr ⟨u ++ [a], rfl⟩
    have hstep : nerodeStep L ⟨residual L u, hu⟩ a =
      ⟨residual L (u ++ [a]), hmem⟩ := Subtype.ext (nerodeStep_val L u hu a)
    rw [hstep]
    change (evalFrom (nerodeAutomaton L) ⟨residual L (u ++ [a]), hmem⟩ w).val = _
    rw [ih (u ++ [a]) hmem]
    congr 1; simp [List.append_assoc]

/-- **Correctness**: The Nerode automaton recognizes the language. -/
theorem nerodeAutomaton_correct (L : TropLang α) :
    recognizes (nerodeAutomaton L) L := by
  intro w
  simp only [evalCost, nerodeAutomaton]
  -- init state is ⟨L, _⟩ = ⟨residual L [], _⟩
  have hinit : (nerodeAutomaton L).init = ⟨residual L [], ⟨[], residual_nil L⟩⟩ := by
    simp [nerodeAutomaton, residual_nil]
  have hmem : residual L [] ∈ Set.range (residual L) := ⟨[], rfl⟩
  have h := nerode_evalFrom_eq L [] w hmem
  simp at h
  show (evalFrom (nerodeAutomaton L) ⟨L, ⟨[], residual_nil L⟩⟩ w).val [] = L w
  have : residual L [] = L := residual_nil L
  conv_lhs => rw [show (⟨L, ⟨[], residual_nil L⟩⟩ : ↥(Set.range (residual L))) =
    ⟨residual L [], hmem⟩ from Subtype.ext this.symm]
  rw [h]; simp [residual]

/-! ## Finite Nerode Index ⇒ Recognizable -/

theorem finite_nerode_implies_recognizable (L : TropLang α)
    (hfin : FiniteNerodeIndex L) : TropicalRecognizable L := by
  haveI : Fintype ↥(Set.range (residual L)) := hfin.fintype
  exact ⟨↥(Set.range (residual L)), inferInstance, nerodeAutomaton L, nerodeAutomaton_correct L⟩

/-! ## Main Biconditional -/

/-- **Tropical Myhill–Nerode Theorem.** -/
theorem tropical_recognizable_iff_finite_nerode (L : TropLang α) :
    TropicalRecognizable L ↔ FiniteNerodeIndex L :=
  ⟨fun ⟨_, _, A, hA⟩ => recognizable_implies_finite_nerode A L hA,
   finite_nerode_implies_recognizable L⟩

/-! ## Minimality -/

/-- Same automaton state implies Nerode equivalence. -/
lemma same_state_nerodeEq (A : TropicalDFA α σ)
    (L : TropLang α) (hA : recognizes A L) (u v : List α)
    (h : evalFrom A A.init u = evalFrom A A.init v) :
    NerodeEq L u v := by
  rw [NerodeEq_iff_forall]
  intro w
  rw [← hA (u ++ w), ← hA (v ++ w)]
  simp [evalCost, evalFrom_append, h]

/-
**Minimality**: Nerode classes ≤ states of any recognizing DFA.
-/
theorem nerode_index_le_card [Fintype σ]
    (A : TropicalDFA α σ) (L : TropLang α) (hA : recognizes A L) :
    Set.ncard (Set.range (residual L)) ≤ Fintype.card σ := by
      -- The range of residual L is a subset of the range of residualOfState A.
      have h_subset : Set.range (residual L) ⊆ Set.range (residualOfState A) :=
        range_residual_subset A L hA
      refine' le_trans ( Set.ncard_le_ncard h_subset ) _;
      rw [ Set.ncard_eq_toFinset_card _ ] ; simp +decide [ Finset.card_image_of_injective, Function.Injective ] ;
      exact Fintype.card_le_of_surjective _ ( show Function.Surjective ( fun q : σ => ⟨ residualOfState A q, Set.mem_range_self q ⟩ ) from fun x => by aesop )

/-! ## Syntactic Congruence and Transition Monoid -/

/-- Syntactic profile of a word. -/
def SyntacticProfile (L : TropLang α) (u : List α) :
    List α → List α → TropWeight :=
  fun x y => L (x ++ u ++ y)

/-- Syntactic equivalence. -/
def SyntacticEq (L : TropLang α) (u v : List α) : Prop :=
  ∀ x y, L (x ++ u ++ y) = L (x ++ v ++ y)

/-- Finite syntactic index. -/
def FiniteSyntacticIndex (L : TropLang α) : Prop :=
  Set.Finite (Set.range (SyntacticProfile L))

lemma syntacticEq_implies_nerodeEq (L : TropLang α) (u v : List α)
    (h : SyntacticEq L u v) : NerodeEq L u v :=
  funext fun w => h [] w

lemma finite_syntactic_implies_finite_nerode (L : TropLang α)
    (h : FiniteSyntacticIndex L) : FiniteNerodeIndex L := by
  apply Set.Finite.subset (h.image (fun p => fun y => p [] y))
  rintro _ ⟨u, rfl⟩
  exact ⟨SyntacticProfile L u, Set.mem_range.mpr ⟨u, rfl⟩, funext fun _ => rfl⟩

/-- Transition function of a word. -/
def transitionFun (A : TropicalDFA α σ) (w : List α) : σ → σ :=
  fun q => evalFrom A q w

theorem recognizable_implies_finite_syntactic [Fintype σ]
    (A : TropicalDFA α σ) (L : TropLang α) (hA : recognizes A L) :
    FiniteSyntacticIndex L := by
      refine' Set.Finite.subset ( Set.toFinite ( Set.range fun f : σ → σ => fun x y => ( A.out ( evalFrom A ( f ( evalFrom A A.init x ) ) y ) ) ) ) _;
      rintro _ ⟨ u, rfl ⟩;
      use fun q => evalFrom A q u;
      grind +locals

/-- **Syntactic characterization.** -/
theorem tropical_recognizable_iff_finite_syntactic (L : TropLang α) :
    TropicalRecognizable L ↔ FiniteSyntacticIndex L :=
  ⟨fun ⟨_, _, A, hA⟩ => recognizable_implies_finite_syntactic A L hA,
   fun h => finite_nerode_implies_recognizable L
     (finite_syntactic_implies_finite_nerode L h)⟩

/-! ## Dynamic Programming Bridge -/

/-- Value function at prefix `u`: the residual = future cost-to-go. -/
def dpValueFunction (L : TropLang α) (u : List α) : TropLang α :=
  residual L u

/-- **Bellman principle**: extending a prefix by one letter shifts the value function. -/
theorem dp_bellman_residual (L : TropLang α) (u : List α) (a : α) :
    dpValueFunction L (u ++ [a]) = fun w => dpValueFunction L u (a :: w) := by
  funext w; simp [dpValueFunction, residual, List.append_assoc]

/-- Nerode equivalence = same future cost-to-go function (state compression). -/
theorem dp_state_compression (L : TropLang α) (u v : List α) :
    NerodeEq L u v ↔ dpValueFunction L u = dpValueFunction L v := Iff.rfl

end TropicalMyhillNerode