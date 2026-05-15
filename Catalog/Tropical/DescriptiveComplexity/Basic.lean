/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Tropical Descriptive Complexity: Formula Evaluation is Tropically Recognizable

This file establishes a formal bridge between logical definability with free variables
and tropical (min-plus) automata recognizability. The main result shows that every
quantitative formula, when evaluated on annotated words that encode variable assignments,
yields a tropically recognizable series.

## Main Results

* `tropRecognizable_const` — constant functions are tropically recognizable
* `tropRecognizable_letterCost` — per-position cost sums are recognizable
* `tropRecognizable_existsPos` — existential position predicates are recognizable
* `TropRecognizable.min` — closure under pointwise minimum
* `TropRecognizable.add` — closure under pointwise addition
* `formula_tropically_recognizable` — every tropical formula is recognizable
* `evalWith_decode_tropRecognizable` — corollary for annotated words with free variables

## Mathematical Significance

This is a tropical analogue of the classical Büchi–Elgot–Trakhtenbrot correspondence
between logical definability and automata recognizability, extended to quantitative
(min-plus) semantics with free variable annotations.
-/

import Mathlib

namespace TropicalDescriptiveComplexity

open scoped ENNReal

/-! ## Annotated Symbols -/

/-- An annotated symbol: a base symbol together with a boolean annotation for each
free variable. The annotation `ann v = true` means variable `v` is "witnessed"
at this position. -/
@[ext]
structure AnnotatedSymbol (σ Var : Type) where
  base : σ
  ann : Var → Bool

/-- Decoded structure extracted from an annotated word. -/
structure DecodedStructure (σ Var : Type) where
  baseWord : List σ
  varPositions : Var → List ℕ

/-- Decode an annotated word into a base word and variable position lists. -/
def decode {σ Var : Type} (w : List (AnnotatedSymbol σ Var)) : DecodedStructure σ Var where
  baseWord := w.map AnnotatedSymbol.base
  varPositions v := (List.range w.length).filter fun i =>
    match w[i]? with
    | some a => a.ann v
    | none => false

/-! ## Tropical Weighted Automaton -/

/-- A tropical (min-plus) weighted automaton with finite state set `S`.
The automaton assigns initial costs to states, transition costs to state-symbol-state
triples, and final (accepting) costs to states. -/
structure TropAut (α : Type) where
  /-- The state type -/
  S : Type
  /-- States form a finite type -/
  finS : Fintype S
  /-- Initial cost for each state -/
  init : S → ℝ≥0∞
  /-- Transition cost: source state → symbol → target state → cost -/
  transition : S → α → S → ℝ≥0∞
  /-- Final (accepting) cost for each state -/
  terminal : S → ℝ≥0∞

instance (A : TropAut α) : Fintype A.S := A.finS

/-- The cost of processing word `w` starting from state `q`. -/
noncomputable def TropAut.runCost (A : TropAut α) : List α → A.S → ℝ≥0∞
  | [], q => A.terminal q
  | a :: w, q => ⨅ q' : A.S, A.transition q a q' + A.runCost w q'

/-- The value assigned to word `w` by the automaton: min over states of init + runCost. -/
noncomputable def TropAut.eval (A : TropAut α) (w : List α) : ℝ≥0∞ :=
  ⨅ q : A.S, A.init q + A.runCost w q

/-- A function is tropically recognizable if some tropical automaton computes it. -/
def TropRecognizable (f : List α → ℝ≥0∞) : Prop :=
  ∃ A : TropAut α, ∀ w, A.eval w = f w

/-! ## Tropical Formula Syntax -/

/-- Quantitative tropical formulas over alphabet `α`. -/
inductive TropFormula (α : Type) where
  | const : ℝ≥0∞ → TropFormula α
  | letterCost : (α → ℝ≥0∞) → TropFormula α
  | existsPos : (α → Bool) → TropFormula α
  | forallPos : (α → Bool) → TropFormula α
  | tmin : TropFormula α → TropFormula α → TropFormula α
  | tplus : TropFormula α → TropFormula α → TropFormula α

/-- Evaluation of a tropical formula on a word. -/
noncomputable def TropFormula.eval : TropFormula α → List α → ℝ≥0∞
  | .const c, _ => c
  | .letterCost f, w => (w.map f).sum
  | .existsPos p, w => if w.any p then 0 else ⊤
  | .forallPos p, w => if w.all p then 0 else ⊤
  | .tmin φ ψ, w => min (φ.eval w) (ψ.eval w)
  | .tplus φ ψ, w => φ.eval w + ψ.eval w

/-! ## Automaton Constructions -/

/-- The constant automaton: a single state, yields constant value `c`. -/
def constAut (α : Type) (c : ℝ≥0∞) : TropAut α where
  S := Unit
  finS := inferInstance
  init := fun () => c
  transition := fun () _ () => 0
  terminal := fun () => 0

/-- The letter-cost automaton: a single state accumulating per-position costs. -/
def letterCostAut (f : α → ℝ≥0∞) : TropAut α where
  S := Unit
  finS := inferInstance
  init := fun () => 0
  transition := fun () a () => f a
  terminal := fun () => 0

/-- The existential automaton: two states tracking whether predicate was witnessed. -/
def existsAut (p : α → Bool) : TropAut α where
  S := Bool
  finS := inferInstance
  init := fun b => if b then ⊤ else 0
  transition := fun q a q' =>
    match q, q' with
    | false, false => 0
    | false, true => if p a then 0 else ⊤
    | true, true => 0
    | true, false => ⊤
  terminal := fun b => if b then 0 else ⊤

/-- The disjoint-union automaton for minimum. -/
noncomputable def minAut (A₁ A₂ : TropAut α) : TropAut α where
  S := A₁.S ⊕ A₂.S
  finS := inferInstance
  init := fun q => match q with
    | .inl q₁ => A₁.init q₁
    | .inr q₂ => A₂.init q₂
  transition := fun q a q' => match q, q' with
    | .inl q₁, .inl q₁' => A₁.transition q₁ a q₁'
    | .inr q₂, .inr q₂' => A₂.transition q₂ a q₂'
    | _, _ => ⊤
  terminal := fun q => match q with
    | .inl q₁ => A₁.terminal q₁
    | .inr q₂ => A₂.terminal q₂

/-- The product automaton for addition. -/
noncomputable def addAut (A₁ A₂ : TropAut α) : TropAut α where
  S := A₁.S × A₂.S
  finS := inferInstance
  init := fun ⟨q₁, q₂⟩ => A₁.init q₁ + A₂.init q₂
  transition := fun ⟨q₁, q₂⟩ a ⟨q₁', q₂'⟩ => A₁.transition q₁ a q₁' + A₂.transition q₂ a q₂'
  terminal := fun ⟨q₁, q₂⟩ => A₁.terminal q₁ + A₂.terminal q₂

/-! ## Correctness of Automaton Constructions -/

theorem constAut_runCost (c : ℝ≥0∞) (w : List α) :
    (constAut α c).runCost w () = 0 := by
  induction w <;> simp_all +decide [ constAut ];
  · rfl;
  · simp_all +decide [ TropAut.runCost ]

theorem constAut_eval (c : ℝ≥0∞) (w : List α) :
    (constAut α c).eval w = c := by
  unfold TropAut.eval;
  unfold constAut;
  induction w <;> simp_all +decide [ TropAut.runCost ]

theorem letterCostAut_runCost (f : α → ℝ≥0∞) (w : List α) :
    (letterCostAut f).runCost w () = (w.map f).sum := by
  induction w <;> simp_all +decide [ add_assoc ];
  · rfl;
  · rename_i a w ih; erw [ show ( letterCostAut f ).runCost ( a :: w ) () = ⨅ q' : Unit, f a + ( letterCostAut f ).runCost w q' from rfl ] ;
    exact ih.symm ▸ le_antisymm ( ciInf_le ( Finite.bddBelow_range _ ) () ) ( le_ciInf fun q' => by cases q' ; aesop )

theorem letterCostAut_eval (f : α → ℝ≥0∞) (w : List α) :
    (letterCostAut f).eval w = (w.map f).sum := by
  unfold TropAut.eval;
  convert letterCostAut_runCost f w using 1;
  simp +decide [ letterCostAut ]

theorem existsAut_runCost_true (p : α → Bool) (w : List α) :
    (existsAut p).runCost w true = 0 := by
  induction' w with a w ih;
  · rfl;
  · -- By definition of `runCost`, we have:
    have h_runCost : (existsAut p).runCost (a :: w) true = ⨅ q' : Bool, (existsAut p).transition true a q' + (existsAut p).runCost w q' := by
      rfl;
    refine' le_antisymm _ _ <;> simp_all +decide [ iInf ];
    exact Or.inr ( by unfold existsAut; aesop )

theorem existsAut_runCost_false (p : α → Bool) (w : List α) :
    (existsAut p).runCost w false = if w.any p then 0 else ⊤ := by
  induction' w with a w ihizing p;
  · rfl;
  · rw [ show ( existsAut p ).runCost ( a :: w ) false = ⨅ q' : Bool, ( existsAut p ).transition false a q' + ( existsAut p ).runCost w q' from rfl ];
    rw [ @ciInf_eq_of_forall_ge_of_forall_gt_exists_lt ];
    · cases h : p a <;> simp_all +decide [ existsAut ] ;
    · split_ifs <;> simp_all +decide [ existsAut ];
      intro x hx; split_ifs <;> simp_all +decide [ existsAut_runCost_true ] ;
      exact lt_of_le_of_lt ( le_of_eq ( existsAut_runCost_true _ _ ) ) hx

theorem existsAut_eval (p : α → Bool) (w : List α) :
    (existsAut p).eval w = if w.any p then 0 else ⊤ := by
  convert existsAut_runCost_false p w using 1;
  unfold TropAut.eval;
  refine' le_antisymm _ _ <;> norm_num [ existsAut ];
  · exact ciInf_le_of_le ⟨ 0, Set.forall_mem_range.mpr fun _ => zero_le _ ⟩ false ( by simp +decide [ existsAut ] );
  · intro i; cases i <;> simp +decide [ existsAut ] ;

theorem forallPos_eq_letterCost (p : α → Bool) (w : List α) :
    (if w.all p then (0 : ℝ≥0∞) else ⊤) = (w.map fun a => if p a then 0 else ⊤).sum := by
  induction' w with a w ih;
  · simp +decide;
  · by_cases ha : p a <;> simp_all +decide [ List.all_cons ]

theorem minAut_runCost_inl (A₁ A₂ : TropAut α) (w : List α) (q : A₁.S) :
    (minAut A₁ A₂).runCost w (.inl q) = A₁.runCost w q := by
  induction' w with a w ih generalizing q <;> simp_all +decide [ TropAut.runCost ];
  · rfl;
  · refine' le_antisymm _ _ <;> simp +decide [ iInf_le_iff ];
    · intro i b hb; specialize hb ( Sum.inl i ) ; aesop;
    · rintro ( i | i ) b hb <;> simp_all +decide [ minAut ]

theorem minAut_runCost_inr (A₁ A₂ : TropAut α) (w : List α) (q : A₂.S) :
    (minAut A₁ A₂).runCost w (.inr q) = A₂.runCost w q := by
  induction w generalizing q <;> simp_all +decide [ TropAut.runCost ];
  · rfl;
  · refine' le_antisymm _ _;
    · refine' le_iInf fun q' => _;
      refine' le_trans ( ciInf_le _ ( Sum.inr q' ) ) _;
      · exact ⟨ 0, Set.forall_mem_range.mpr fun q' => zero_le _ ⟩;
      · aesop;
    · refine' le_iInf fun q' => _;
      cases q' <;> simp_all +decide [ minAut ];
      exact ciInf_le ( Finite.bddBelow_range _ ) _

theorem minAut_eval (A₁ A₂ : TropAut α) (w : List α) :
    (minAut A₁ A₂).eval w = min (A₁.eval w) (A₂.eval w) := by
  unfold TropAut.eval;
  unfold minAut;
  rw [ @iInf_sum ];
  congr! 2;
  · exact funext fun q => congr_arg₂ _ rfl ( minAut_runCost_inl A₁ A₂ w q );
  · exact funext fun q => congr_arg₂ _ rfl ( minAut_runCost_inr _ _ _ _ )

theorem addAut_runCost (A₁ A₂ : TropAut α) (w : List α) (q₁ : A₁.S) (q₂ : A₂.S) :
    (addAut A₁ A₂).runCost w (q₁, q₂) = A₁.runCost w q₁ + A₂.runCost w q₂ := by
  -- By definition of runCost, we can expand the expression for the product automaton.
  have h_expand : ∀ w : List α, ∀ q₁ : A₁.S, ∀ q₂ : A₂.S, (addAut A₁ A₂).runCost w (q₁, q₂) = A₁.runCost w q₁ + A₂.runCost w q₂ := by
    intro w q₁ q₂;
    induction' w with a w ih generalizing q₁ q₂;
    · rfl;
    · -- Apply the induction hypothesis to rewrite the runCost of the product automaton.
      have h_ind : ⨅ (q₁' : A₁.S) (q₂' : A₂.S), (A₁.transition q₁ a q₁' + A₂.transition q₂ a q₂') + (A₁.runCost w q₁' + A₂.runCost w q₂') = (⨅ (q₁' : A₁.S), A₁.transition q₁ a q₁' + A₁.runCost w q₁') + (⨅ (q₂' : A₂.S), A₂.transition q₂ a q₂' + A₂.runCost w q₂') := by
        have h_inf_sum : ∀ (f : A₁.S → ℝ≥0∞) (g : A₂.S → ℝ≥0∞), ⨅ (q₁' : A₁.S) (q₂' : A₂.S), f q₁' + g q₂' = (⨅ (q₁' : A₁.S), f q₁') + (⨅ (q₂' : A₂.S), g q₂') := by
          intro f g;
          rw [ ENNReal.iInf_add ];
          congr! 2;
          rw [ ENNReal.add_iInf ];
        convert h_inf_sum ( fun q₁' => A₁.transition q₁ a q₁' + A₁.runCost w q₁' ) ( fun q₂' => A₂.transition q₂ a q₂' + A₂.runCost w q₂' ) using 3 ; ring;
        grind;
      convert h_ind using 1;
      rw [ show ( addAut A₁ A₂ ).runCost ( a :: w ) ( q₁, q₂ ) = ⨅ q : A₁.S × A₂.S, ( addAut A₁ A₂ ).transition ( q₁, q₂ ) a q + ( addAut A₁ A₂ ).runCost w q from rfl ];
      rw [ @iInf_prod ];
      exact iInf_congr fun q₁' => iInf_congr fun q₂' => by rw [ ih ] ; rfl;
  exact h_expand _ _ _

theorem iInf_prod_add {ι₁ ι₂ : Type} [Fintype ι₁] [Fintype ι₂]
    (f : ι₁ → ℝ≥0∞) (g : ι₂ → ℝ≥0∞) :
    (⨅ p : ι₁ × ι₂, f p.1 + g p.2) = (⨅ i, f i) + (⨅ j, g j) := by
  refine' le_antisymm _ _;
  · rcases isEmpty_or_nonempty ι₁ with h₁ | h₁ <;> rcases isEmpty_or_nonempty ι₂ with h₂ | h₂ <;> simp_all +decide [ ENNReal.iInf_add, ENNReal.add_iInf ];
    exact fun i j => ciInf_le ( Finite.bddBelow_range _ ) ( j, i );
  · exact le_iInf fun p => add_le_add ( iInf_le _ _ ) ( iInf_le _ _ )

theorem addAut_eval (A₁ A₂ : TropAut α) (w : List α) :
    (addAut A₁ A₂).eval w = A₁.eval w + A₂.eval w := by
  convert iInf_prod_add ( fun q₁ => A₁.init q₁ + A₁.runCost w q₁ ) ( fun q₂ => A₂.init q₂ + A₂.runCost w q₂ ) using 2;
  convert rfl using 2;
  unfold TropAut.eval;
  convert rfl using 3;
  rename_i x;
  convert congr_arg₂ ( · + · ) rfl ( addAut_runCost A₁ A₂ w x.1 x.2 ) using 1;
  unfold addAut; ring;
  cases x ; ring

/-! ## Closure Theorems -/

theorem tropRecognizable_const (c : ℝ≥0∞) :
    TropRecognizable (fun _ : List α => c) :=
  ⟨constAut α c, constAut_eval c⟩

theorem tropRecognizable_letterCost (f : α → ℝ≥0∞) :
    TropRecognizable (fun w : List α => (w.map f).sum) :=
  ⟨letterCostAut f, letterCostAut_eval f⟩

theorem tropRecognizable_existsPos (p : α → Bool) :
    TropRecognizable (fun w : List α => if w.any p then 0 else ⊤) :=
  ⟨existsAut p, existsAut_eval p⟩

theorem tropRecognizable_forallPos (p : α → Bool) :
    TropRecognizable (fun w : List α => if w.all p then 0 else ⊤) := by
  have h : (fun w : List α => if w.all p then (0 : ℝ≥0∞) else ⊤) =
           (fun w => (w.map fun a => if p a then 0 else ⊤).sum) := by
    ext w; exact forallPos_eq_letterCost p w
  rw [h]
  exact tropRecognizable_letterCost _

theorem TropRecognizable.min {f g : List α → ℝ≥0∞}
    (hf : TropRecognizable f) (hg : TropRecognizable g) :
    TropRecognizable (fun w => min (f w) (g w)) := by
  obtain ⟨A₁, h₁⟩ := hf
  obtain ⟨A₂, h₂⟩ := hg
  exact ⟨minAut A₁ A₂, fun w => by rw [minAut_eval, h₁, h₂]⟩

theorem TropRecognizable.add {f g : List α → ℝ≥0∞}
    (hf : TropRecognizable f) (hg : TropRecognizable g) :
    TropRecognizable (fun w => f w + g w) := by
  obtain ⟨A₁, h₁⟩ := hf
  obtain ⟨A₂, h₂⟩ := hg
  exact ⟨addAut A₁ A₂, fun w => by rw [addAut_eval, h₁, h₂]⟩

/-! ## Main Theorem -/

/-- **Main Theorem**: Every tropical formula evaluates to a tropically recognizable
function. The proof proceeds by structural induction on formulas. -/
theorem formula_tropically_recognizable :
    ∀ φ : TropFormula α, TropRecognizable (φ.eval) := by
  intro φ
  induction φ with
  | const c => exact tropRecognizable_const c
  | letterCost f => exact tropRecognizable_letterCost f
  | existsPos p => exact tropRecognizable_existsPos p
  | forallPos p => exact tropRecognizable_forallPos p
  | tmin φ ψ ih₁ ih₂ => exact ih₁.min ih₂
  | tplus φ ψ ih₁ ih₂ => exact ih₁.add ih₂

/-! ## Application to Annotated Words -/

/-- Formulas with free variables over a base alphabet. -/
abbrev FormulaWithVars (σ Var : Type) := TropFormula (AnnotatedSymbol σ Var)

/-- **Corollary**: For every formula with free variables, the evaluation function
on annotated words is tropically recognizable. -/
theorem evalWith_decode_tropRecognizable {σ Var : Type} :
    ∀ φ : FormulaWithVars σ Var,
      TropRecognizable (fun w : List (AnnotatedSymbol σ Var) => φ.eval w) :=
  formula_tropically_recognizable

/-! ## Concrete Formula Examples -/

/-- Check if variable `v` is annotated at some position with base label `a`. -/
def varAtLabel [DecidableEq σ] (v : Var) (a : σ) : FormulaWithVars σ Var :=
  .existsPos fun s => s.ann v && (s.base == a)

/-- Count positions where variable `v` is annotated. -/
def varCount (v : Var) : FormulaWithVars σ Var :=
  .letterCost fun s => if s.ann v then 1 else 0

/-- Word length as a tropical cost. -/
def wordLength : FormulaWithVars σ Var :=
  .letterCost fun _ => 1

theorem varAtLabel_recognizable [DecidableEq σ] (v : Var) (a : σ) :
    TropRecognizable (fun w => (varAtLabel v a : FormulaWithVars σ Var).eval w) :=
  formula_tropically_recognizable _

theorem varCount_recognizable (v : Var) :
    TropRecognizable (fun w => (varCount v : FormulaWithVars σ Var).eval w) :=
  formula_tropically_recognizable _

end TropicalDescriptiveComplexity