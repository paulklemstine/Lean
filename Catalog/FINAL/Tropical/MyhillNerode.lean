import Mathlib

/-!
# Tropical Myhill–Nerode Theorem

This file develops a Myhill–Nerode theory for tropical (min-plus) weighted languages
over the semiring `WithTop ℕ`, where:
- tropical addition = `min` (= `⊓`)
- tropical multiplication = `+`
- zero = `⊤` (infinity)
- one = `0`

## Main results

* `tropical_recognizable_iff_finite_nerode` — A weighted language `L : List α → WithTop ℕ`
  is recognizable by a finite-state tropical DFA iff it has finitely many residual
  languages (finite Nerode index).
* `nerode_automaton_recognizes` — The Nerode automaton (whose states are residual
  languages) recognizes the original language.
* `nerode_index_le_card` — The number of Nerode classes (residuals) is at most the
  number of states of any recognizing automaton (minimality).
* `tropical_recognizable_iff_finite_syntactic` — Recognizability is equivalent to
  finiteness of the syntactic tropical transition monoid.
-/

namespace TropicalMyhillNerode

/-! ## Core Definitions -/

/-- A deterministic tropical (min-plus) finite automaton.
    States are of type `σ`, alphabet of type `α`.
    The automaton assigns a cost via `out` to the state reached after processing a word. -/
structure TropicalDFA (α σ : Type*) where
  step : σ → α → σ
  init : σ
  out  : σ → WithTop ℕ

variable {α σ τ : Type*}

/-- The state reached after processing a word from a given starting state. -/
def evalState (A : TropicalDFA α σ) : σ → List α → σ
  | q, []     => q
  | q, a :: w => evalState A (A.step q a) w

/-- The cost/weight assigned to a word by the automaton. -/
def evalCost (A : TropicalDFA α σ) (w : List α) : WithTop ℕ :=
  A.out (evalState A A.init w)

/-- An automaton recognizes a weighted language if it computes the same cost for every word. -/
def recognizes (A : TropicalDFA α σ) (L : List α → WithTop ℕ) : Prop :=
  ∀ w, evalCost A w = L w

/-- The right residual (derivative) of a weighted language at prefix `u`:
    `Residual L u` maps suffix `w` to `L(u ++ w)`. -/
def Residual (L : List α → WithTop ℕ) (u : List α) : List α → WithTop ℕ :=
  fun w => L (u ++ w)

/-- Tropical Nerode equivalence: `u` and `v` are equivalent iff they have identical
    residual languages, i.e., `L(u ++ w) = L(v ++ w)` for all suffixes `w`. -/
def NerodeEq (L : List α → WithTop ℕ) (u v : List α) : Prop :=
  ∀ w, L (u ++ w) = L (v ++ w)

/-- A language has finite Nerode index if the set of distinct residual functions is finite. -/
def FiniteNerodeIndex (L : List α → WithTop ℕ) : Prop :=
  Set.Finite (Set.range (Residual L))

/-- A weighted language is tropically recognizable if some finite-state DFA recognizes it. -/
def TropicalRecognizable (L : List α → WithTop ℕ) : Prop :=
  ∃ (S : Type) (_ : Fintype S), ∃ A : TropicalDFA α S, recognizes A L

/-! ## Basic Lemmas about `evalState` -/

@[simp]
lemma evalState_nil (A : TropicalDFA α σ) (q : σ) :
    evalState A q [] = q := rfl

@[simp]
lemma evalState_cons (A : TropicalDFA α σ) (q : σ) (a : α) (w : List α) :
    evalState A q (a :: w) = evalState A (A.step q a) w := rfl

/-
Processing a concatenation is the same as processing the prefix then the suffix.
-/
lemma evalState_append (A : TropicalDFA α σ) (q : σ) (u v : List α) :
    evalState A q (u ++ v) = evalState A (evalState A q u) v := by
  induction u generalizing q <;> aesop

/-! ## Properties of Residuals -/

@[simp]
lemma Residual_nil (L : List α → WithTop ℕ) :
    Residual L [] = L := by
  -- By definition of Residual, we have Residual L [] w = L ([] ++ w) = L w.
  funext w; simp [Residual]

lemma Residual_append (L : List α → WithTop ℕ) (u v : List α) :
    Residual L (u ++ v) = Residual (Residual L u) v := by
  exact funext fun w => by simp +decide [ Residual ] ;

lemma Residual_singleton_cons (L : List α → WithTop ℕ) (a : α) (w : List α) :
    Residual L [a] w = L (a :: w) := by
  rfl

/-
Nerode equivalence is exactly equality of residual functions.
-/
lemma NerodeEq_iff_Residual_eq (L : List α → WithTop ℕ) (u v : List α) :
    NerodeEq L u v ↔ Residual L u = Residual L v := by
  exact ⟨ fun h => funext h, fun h w => congr_fun h w ⟩

/-! ## Recognizable implies Finite Nerode Index -/

/-- The "future behavior" function of a state: maps suffixes to output costs. -/
def residualOfState (A : TropicalDFA α σ) (q : σ) : List α → WithTop ℕ :=
  fun w => A.out (evalState A q w)

/-
The residual at prefix `u` equals the future behavior of the state reached by `u`.
-/
lemma residual_eq_residualOfState (A : TropicalDFA α σ)
    (L : List α → WithTop ℕ) (hA : recognizes A L) (u : List α) :
    Residual L u = residualOfState A (evalState A A.init u) := by
  -- By definition of residual, we have that Residual L u w = L (u ++ w).
  funext w; simp [Residual];
  rw [ ← hA ];
  exact congr_arg _ ( evalState_append A _ _ _ )

/-
The range of residuals is contained in the range of state-residuals.
-/
lemma range_Residual_subset_range_residualOfState (A : TropicalDFA α σ)
    (L : List α → WithTop ℕ) (hA : recognizes A L) :
    Set.range (Residual L) ⊆ Set.range (residualOfState A) := by
  exact Set.range_subset_iff.2 fun u => ⟨ _, residual_eq_residualOfState A L hA u |> Eq.symm ⟩

/-
If a finite-state automaton recognizes `L`, then `L` has finite Nerode index.
-/
theorem recognizable_implies_finite_nerode
    [Fintype σ]
    (A : TropicalDFA α σ) (L : List α → WithTop ℕ)
    (hA : recognizes A L) :
    FiniteNerodeIndex L := by
  exact Set.Finite.subset ( Set.toFinite ( Set.range ( fun q : σ => residualOfState A q ) ) ) ( range_Residual_subset_range_residualOfState A L hA )

/-! ## Nerode Automaton Construction -/

/-- The step function on residual languages: given a residual and a letter,
    produce the residual after appending that letter. -/
def nerodeStep (L : List α → WithTop ℕ)
    (f : ↥(Set.range (Residual L))) (a : α) : ↥(Set.range (Residual L)) :=
  ⟨fun w => f.val (a :: w), by
    obtain ⟨u, hu⟩ := f.prop
    exact ⟨u ++ [a], funext fun w => by simp [Residual, ← hu, List.append_assoc]⟩⟩

/-- The Nerode automaton: states are residual languages, transitions append letters,
    output is evaluation at the empty word. -/
def nerodeAutomaton (L : List α → WithTop ℕ) :
    TropicalDFA α ↥(Set.range (Residual L)) where
  step := nerodeStep L
  init := ⟨Residual L [], ⟨[], rfl⟩⟩
  out := fun ⟨f, _⟩ => f []

/-
The Nerode step on a concrete residual produces the residual at the extended prefix.
-/
lemma nerodeStep_Residual (L : List α → WithTop ℕ) (u : List α)
    (hu : Residual L u ∈ Set.range (Residual L)) (a : α) :
    nerodeStep L ⟨Residual L u, hu⟩ a =
    ⟨Residual L (u ++ [a]), ⟨u ++ [a], rfl⟩⟩ := by
  -- To show two residuals are equal, we use the fact that their definitions agree on all words.
  apply Subtype.ext
  ext w
  simp [nerodeStep, Residual]

/-
Evaluating the Nerode automaton from a residual state yields the concatenated residual.
-/
lemma nerode_evalState_val (L : List α → WithTop ℕ)
    (u w : List α) (hu : Residual L u ∈ Set.range (Residual L)) :
    (evalState (nerodeAutomaton L) ⟨Residual L u, hu⟩ w).val = Residual L (u ++ w) := by
  induction' w using List.reverseRecOn with w a ihgeneralizing u hu;
  · aesop;
  · unfold Residual at *;
    simp_all +decide [ nerodeAutomaton, evalState_append ];
    convert congr_arg ( fun f => fun w_1 => f ( a :: w_1 ) ) ihgeneralizing using 1

/-
The Nerode automaton recognizes the original language.
-/
theorem nerode_automaton_recognizes (L : List α → WithTop ℕ) :
    recognizes (nerodeAutomaton L) L := by
  intro w;
  convert congr_arg ( fun f : List α → WithTop ℕ => f [] ) ( nerode_evalState_val L [] w ( Set.mem_range_self _ ) ) using 1;
  simp +decide [ Residual ]

/-! ## Finite Nerode Index implies Recognizable -/

/-
If a language has finite Nerode index, it is tropically recognizable
    (via the Nerode automaton).
-/
theorem finite_nerode_implies_recognizable
    (L : List α → WithTop ℕ)
    (hfin : FiniteNerodeIndex L) :
    TropicalRecognizable L := by
  have := @hfin;
  obtain ⟨s, hs⟩ := this;
  rename_i k hk₁ hk₂;
  refine' ⟨ Fin k, inferInstance, _, _ ⟩;
  exact ⟨ fun q a => s ( nerodeStep L ( hs q ) a ), s ⟨ Residual L [ ], ⟨ [ ], rfl ⟩ ⟩, fun q => ( hs q ).1 [ ] ⟩;
  intro w;
  -- By definition of `evalState`, we have:
  have h_evalState : ∀ (q : Fin k) (w : List α), evalState { step := fun q a => s (nerodeStep L (hs q) a), init := s ⟨Residual L [], ⟨[], rfl⟩⟩, out := fun q => (hs q).val [] } q w = s (evalState (nerodeAutomaton L) (hs q) w) := by
                                                              intro q w; induction' w with a w ih generalizing q <;> simp_all +decide [ evalState ] ;
                                                              · grind +qlia;
                                                              · rw [ hk₁ ];
                                                                rfl;
  convert congr_arg ( fun q => ( hs q ).val [] ) ( h_evalState ( s ⟨ Residual L [], ⟨ [], rfl ⟩ ⟩ ) w ) using 1;
  simp +decide [ hk₁ _ ];
  convert nerode_automaton_recognizes L w |> Eq.symm using 1

/-! ## Main Biconditional: Tropical Myhill–Nerode Theorem -/

/-
**Tropical Myhill–Nerode Theorem.**
    A weighted language `L : List α → WithTop ℕ` is recognizable by a finite-state
    tropical DFA if and only if it has finitely many distinct residual languages.
-/
theorem tropical_recognizable_iff_finite_nerode
    (L : List α → WithTop ℕ) :
    TropicalRecognizable L ↔ FiniteNerodeIndex L := by
  constructor
  · rintro ⟨S, hS, A, hA⟩
    exact recognizable_implies_finite_nerode A L hA
  · exact fun a => finite_nerode_implies_recognizable L a

/-! ## Minimality of the Nerode Automaton -/

/-
**Minimality theorem.** The number of Nerode classes (= states of the Nerode automaton)
    is at most the number of states of any recognizing automaton.
-/
theorem nerode_index_le_card
    [Fintype σ]
    (A : TropicalDFA α σ)
    (L : List α → WithTop ℕ)
    (hA : recognizes A L) :
    Set.ncard (Set.range (Residual L)) ≤ Fintype.card σ := by
  -- Apply the fact that the image of a function can't have more elements than its domain.
  have h_card_le : (Set.range (residualOfState A)).ncard ≤ Fintype.card σ := by
    rw [ Set.ncard_eq_toFinset_card _ ];
    refine' le_trans ( Finset.card_le_card _ ) _;
    exact Set.toFinset ( Set.range ( residualOfState A ) );
    · aesop_cat;
    · simp +zetaDelta at *;
      exact Fintype.card_le_of_surjective _ ( show Function.Surjective ( fun q : σ => ⟨ residualOfState A q, Set.mem_range_self q ⟩ ) from fun x => by cases x; aesop );
  exact le_trans ( Set.ncard_le_ncard ( range_Residual_subset_range_residualOfState A L hA ) ( Set.toFinite _ ) ) h_card_le

/-! ## Syntactic Congruence and Transition Monoid -/

/-- The syntactic profile of a word `u` captures its full two-sided behavior in `L`. -/
def SyntacticProfile (L : List α → WithTop ℕ) (u : List α) :
    List α → List α → WithTop ℕ :=
  fun x y => L (x ++ u ++ y)

/-- Syntactic equivalence: `u` and `v` are syntactically equivalent iff they behave
    identically in all two-sided contexts. -/
def SyntacticEq (L : List α → WithTop ℕ) (u v : List α) : Prop :=
  ∀ x y, L (x ++ u ++ y) = L (x ++ v ++ y)

/-- Finite syntactic index: finitely many distinct syntactic profiles. -/
def FiniteSyntacticIndex (L : List α → WithTop ℕ) : Prop :=
  Set.Finite (Set.range (SyntacticProfile L))

/-
Syntactic equivalence implies Nerode equivalence (by restricting the left context to `[]`).
-/
lemma syntacticEq_implies_nerodeEq (L : List α → WithTop ℕ) (u v : List α)
    (h : SyntacticEq L u v) : NerodeEq L u v := by
  exact fun w => by simpa using h [] w;

/-
Finite syntactic index implies finite Nerode index.
-/
lemma finite_syntactic_implies_finite_nerode
    (L : List α → WithTop ℕ)
    (h : FiniteSyntacticIndex L) :
    FiniteNerodeIndex L := by
  refine' Set.Finite.subset ( h.image _ ) _;
  exact fun p y => p [] y;
  rintro _ ⟨ u, rfl ⟩ ; use SyntacticProfile L u; aesop;

/-- The transition function of a word on an automaton: maps a state to the state
    reached after processing the word. -/
def transitionFun (A : TropicalDFA α σ) (w : List α) : σ → σ :=
  fun q => evalState A q w

/-
Equal transition functions imply syntactic equivalence.
-/
lemma transitionFun_eq_implies_syntacticEq
    (A : TropicalDFA α σ) (L : List α → WithTop ℕ)
    (hA : recognizes A L) (u v : List α)
    (h : transitionFun A u = transitionFun A v) :
    SyntacticEq L u v := by
  intro x y;
  rw [ ← hA, ← hA ];
  simp +decide [ evalCost, evalState_append ];
  exact congr_arg _ ( congr_arg ( fun f => evalState A ( f ( evalState A A.init x ) ) y ) h )

/-
If a finite-state automaton recognizes `L`, then `L` has finite syntactic index.
-/
theorem recognizable_implies_finite_syntactic
    [Fintype σ]
    (A : TropicalDFA α σ) (L : List α → WithTop ℕ)
    (hA : recognizes A L) :
    FiniteSyntacticIndex L := by
  refine' Set.Finite.subset ( Set.toFinite ( Set.range ( fun f : σ → σ => fun x y => A.out ( f ( evalState A A.init x ) |> fun q => evalState A q y ) ) ) ) _;
  rintro _ ⟨ u, rfl ⟩;
  use fun q => evalState A q u;
  ext x y; simp +decide [ SyntacticProfile ] ;
  convert hA ( x ++ u ++ y ) using 1;
  · simp +decide [ evalCost, evalState_append ];
  · rw [ List.append_assoc ]

/-
**Tropical syntactic characterization.**
    A weighted language is tropically recognizable iff it has finitely many
    syntactic profiles (equivalently, iff its syntactic transition monoid is finite).
-/
theorem tropical_recognizable_iff_finite_syntactic
    (L : List α → WithTop ℕ) :
    TropicalRecognizable L ↔ FiniteSyntacticIndex L := by
  constructor
  · rintro ⟨S, hS, A, hA⟩
    exact recognizable_implies_finite_syntactic A L hA
  · exact fun h => finite_nerode_implies_recognizable L (finite_syntactic_implies_finite_nerode L h)

end TropicalMyhillNerode