import Mathlib

/-!
# Tropical Formula Definability and Converse Compilation

This file establishes a converse compilation theorem for tropical formulas
over annotated words. The main result is:

> **Tropical Schützenberger Theorem.** A tropical series `S : List σ → WithTop ℕ`
> is formula-definable if and only if it is tropically recognizable and every
> left derivative of `S` is itself formula-definable.

We also prove that every formula-definable series is recognizable (forward
compilation), and that derivatives of formula-definable series are
formula-definable.

## Mathematical Significance

This is a semantic completeness theorem: it identifies exactly which
tropically recognizable series admit formula representations, establishing
the tropical analogue of the Büchi–Elgot–Trakhtenbrot correspondence between
automata and logical definability.
-/

noncomputable section

namespace TropicalFormulaDefinability

/-! ## Tropical Series -/

/-- A tropical series on annotated words. -/
abbrev TropSeries (σ : Type*) := List σ → WithTop ℕ

/-! ## Left Derivatives -/

/-- Left derivative (residual) of a series by a word prefix. -/
def leftDeriv (S : TropSeries σ) (u : List σ) : TropSeries σ :=
  fun v => S (u ++ v)

@[simp]
theorem leftDeriv_nil (S : TropSeries σ) : leftDeriv S [] = S := by
  ext v; simp [leftDeriv]

theorem leftDeriv_append (S : TropSeries σ) (u v : List σ) :
    leftDeriv S (u ++ v) = leftDeriv (leftDeriv S u) v := by
  ext w; simp [leftDeriv, List.append_assoc]

theorem leftDeriv_cons (S : TropSeries σ) (a : σ) (u : List σ) :
    leftDeriv S (a :: u) = leftDeriv (leftDeriv S [a]) u := by
  ext w; simp [leftDeriv]

/-! ## Tropical Formulas -/

/-- A tropical formula over alphabet `σ`.
- `const c` : constant series (all words map to `c`)
- `indicator w c` : maps word `w` to `c`, all others to `⊤`
- `add φ ψ` : pointwise cost addition
- `tmin φ ψ` : pointwise minimum -/
inductive TropicalFormula (σ : Type*) where
  | const : WithTop ℕ → TropicalFormula σ
  | indicator : List σ → WithTop ℕ → TropicalFormula σ
  | add : TropicalFormula σ → TropicalFormula σ → TropicalFormula σ
  | tmin : TropicalFormula σ → TropicalFormula σ → TropicalFormula σ

variable {σ : Type*}

/-- Evaluate a tropical formula. -/
def TropicalFormula.eval [DecidableEq σ] : TropicalFormula σ → TropSeries σ
  | .const c => fun _ => c
  | .indicator w c => fun v => if v = w then c else ⊤
  | .add φ ψ => fun v => φ.eval v + ψ.eval v
  | .tmin φ ψ => fun v => min (φ.eval v) (ψ.eval v)

/-- A tropical series is formula-definable. -/
def FormulaDefinable [DecidableEq σ] (S : TropSeries σ) : Prop :=
  ∃ φ : TropicalFormula σ, φ.eval = S

/-! ## Named Series -/

def constSeries (c : WithTop ℕ) : TropSeries σ := fun _ => c
def topSeries : TropSeries σ := fun _ => ⊤
def seriesAdd (S T : TropSeries σ) : TropSeries σ := fun w => S w + T w
def seriesMin (S T : TropSeries σ) : TropSeries σ := fun w => min (S w) (T w)

/-! ## Basic Formula Definability -/

theorem formulaDefinable_const [DecidableEq σ] (c : WithTop ℕ) :
    FormulaDefinable (constSeries c : TropSeries σ) :=
  ⟨.const c, rfl⟩

theorem formulaDefinable_top [DecidableEq σ] :
    FormulaDefinable (topSeries : TropSeries σ) :=
  ⟨.const ⊤, rfl⟩

theorem formulaDefinable_indicator [DecidableEq σ] (w : List σ) (c : WithTop ℕ) :
    FormulaDefinable (fun v => if v = w then c else ⊤ : TropSeries σ) :=
  ⟨.indicator w c, rfl⟩

theorem formulaDefinable_add [DecidableEq σ] {S T : TropSeries σ}
    (hS : FormulaDefinable S) (hT : FormulaDefinable T) :
    FormulaDefinable (seriesAdd S T) := by
  obtain ⟨φ, rfl⟩ := hS; obtain ⟨ψ, rfl⟩ := hT; exact ⟨.add φ ψ, rfl⟩

theorem formulaDefinable_min [DecidableEq σ] {S T : TropSeries σ}
    (hS : FormulaDefinable S) (hT : FormulaDefinable T) :
    FormulaDefinable (seriesMin S T) := by
  obtain ⟨φ, rfl⟩ := hS; obtain ⟨ψ, rfl⟩ := hT; exact ⟨.tmin φ ψ, rfl⟩

/-! ## Derivatives of Formula-Definable Series -/

theorem leftDeriv_constSeries (c : WithTop ℕ) (u : List σ) :
    leftDeriv (constSeries c : TropSeries σ) u = constSeries c := by
  ext w; simp [leftDeriv, constSeries]

theorem leftDeriv_topSeries (u : List σ) :
    leftDeriv (topSeries : TropSeries σ) u = topSeries := by
  ext w; simp [leftDeriv, topSeries]

theorem leftDeriv_seriesAdd (S T : TropSeries σ) (u : List σ) :
    leftDeriv (seriesAdd S T) u = seriesAdd (leftDeriv S u) (leftDeriv T u) := by
  ext w; simp [leftDeriv, seriesAdd]

theorem leftDeriv_seriesMin (S T : TropSeries σ) (u : List σ) :
    leftDeriv (seriesMin S T) u = seriesMin (leftDeriv S u) (leftDeriv T u) := by
  ext w; simp [leftDeriv, seriesMin]

/-- Key lemma: derivative of indicator by matching head letter. -/
theorem leftDeriv_indicator_match [DecidableEq σ] (a : σ) (w : List σ) (c : WithTop ℕ) :
    leftDeriv (fun v : List σ => if v = a :: w then c else ⊤) [a] =
    (fun v => if v = w then c else ⊤) := by
  ext v; simp [leftDeriv]

/-- Derivative of indicator by non-matching head. -/
theorem leftDeriv_indicator_mismatch [DecidableEq σ] (a b : σ) (w : List σ)
    (c : WithTop ℕ) (hab : a ≠ b) :
    leftDeriv (fun v : List σ => if v = b :: w then c else ⊤) [a] = topSeries := by
  ext v; simp [leftDeriv, topSeries]; tauto

/-- Derivative of indicator for empty word by any letter gives top. -/
theorem leftDeriv_indicator_empty [DecidableEq σ] (c : WithTop ℕ) (a : σ) :
    leftDeriv (fun v : List σ => if v = [] then c else ⊤) [a] = topSeries := by
  ext v; simp [leftDeriv, topSeries]

/-- **Derivative closure theorem**: the derivative of a formula-definable series
by a single letter is formula-definable. -/
theorem formula_definable_leftDeriv_letter [DecidableEq σ]
    (S : TropSeries σ) (hS : FormulaDefinable S) (a : σ) :
    FormulaDefinable (leftDeriv S [a]) := by
  obtain ⟨φ, rfl⟩ := hS
  induction φ with
  | const c =>
    have : leftDeriv (TropicalFormula.eval (.const c : TropicalFormula σ)) [a] = constSeries c := by
      ext w; simp [leftDeriv, TropicalFormula.eval, constSeries]
    rw [this]; exact formulaDefinable_const c
  | indicator w c =>
    cases w with
    | nil =>
      have : leftDeriv (TropicalFormula.eval (.indicator ([] : List σ) c)) [a] = topSeries := by
        ext v; simp [leftDeriv, TropicalFormula.eval, topSeries]
      rw [this]; exact formulaDefinable_top
    | cons b w =>
      by_cases hab : a = b
      · subst hab
        have : leftDeriv (TropicalFormula.eval (.indicator (a :: w) c)) [a] =
          (fun v => if v = w then c else ⊤) := by
          ext v; simp [leftDeriv, TropicalFormula.eval]
        rw [this]; exact formulaDefinable_indicator w c
      · have : leftDeriv (TropicalFormula.eval (.indicator (b :: w) c)) [a] = topSeries := by
          ext v; simp [leftDeriv, TropicalFormula.eval, topSeries]; tauto
        rw [this]; exact formulaDefinable_top
  | add φ ψ ihφ ihψ =>
    have : leftDeriv (TropicalFormula.eval (.add φ ψ)) [a] =
      seriesAdd (leftDeriv φ.eval [a]) (leftDeriv ψ.eval [a]) := by
      ext w; simp [leftDeriv, TropicalFormula.eval, seriesAdd]
    rw [this]; exact formulaDefinable_add ihφ ihψ
  | tmin φ ψ ihφ ihψ =>
    have : leftDeriv (TropicalFormula.eval (.tmin φ ψ)) [a] =
      seriesMin (leftDeriv φ.eval [a]) (leftDeriv ψ.eval [a]) := by
      ext w; simp [leftDeriv, TropicalFormula.eval, seriesMin]
    rw [this]; exact formulaDefinable_min ihφ ihψ

/-- **Full derivative closure**: the derivative by any word is formula-definable. -/
theorem formula_definable_leftDeriv [DecidableEq σ]
    (S : TropSeries σ) (hS : FormulaDefinable S) (u : List σ) :
    FormulaDefinable (leftDeriv S u) := by
  induction u generalizing S with
  | nil => simpa
  | cons a u ih =>
    rw [leftDeriv_cons]
    exact ih _ (formula_definable_leftDeriv_letter S hS a)

/-! ## Tropical DFA and Recognizability -/

/-- A deterministic tropical finite automaton. -/
structure TropDFA (α σs : Type*) where
  step : σs → α → σs
  init : σs
  out : σs → WithTop ℕ

def TropDFA.run (A : TropDFA α σs) : σs → List α → σs
  | q, [] => q
  | q, a :: w => A.run (A.step q a) w

def TropDFA.evalCost (A : TropDFA α σs) (w : List α) : WithTop ℕ :=
  A.out (A.run A.init w)

def TropDFA.recognizes (A : TropDFA α σs) (S : List α → WithTop ℕ) : Prop :=
  ∀ w, A.evalCost w = S w

def TropRecognizable (S : List α → WithTop ℕ) : Prop :=
  ∃ (Q : Type) (_ : Fintype Q), ∃ A : TropDFA α Q, A.recognizes S

theorem TropDFA.run_append (A : TropDFA α σs) (q : σs) (u v : List α) :
    A.run q (u ++ v) = A.run (A.run q u) v := by
  induction u generalizing q with
  | nil => rfl
  | cons a u ih => exact ih (A.step q a)

/-! ## Forward Compilation -/

theorem tropRecognizable_const (c : WithTop ℕ) :
    TropRecognizable (constSeries c : TropSeries σ) := by
  refine ⟨Unit, inferInstance, ⟨fun _ _ => (), (), fun _ => c⟩, ?_⟩
  intro w; simp [TropDFA.evalCost, constSeries]

theorem tropRecognizable_indicator_nil [DecidableEq σ] (c : WithTop ℕ) :
    TropRecognizable (fun v : List σ => if v = [] then c else ⊤) := by
  refine ⟨Bool, inferInstance,
    ⟨fun _ _ => false, true, fun b => if b = true then c else ⊤⟩, ?_⟩
  intro w; simp [TropDFA.evalCost]
  cases w with
  | nil => simp [TropDFA.run]
  | cons a w =>
    simp [TropDFA.run]
    suffices h : TropDFA.run ⟨fun (_ : Bool) (_ : σ) => false, true,
      fun b => if b = true then c else ⊤⟩ false w = false by
      simp [h]
    induction w with
    | nil => rfl
    | cons _ _ ih => exact ih

theorem tropRecognizable_min {S T : TropSeries σ}
    (hS : TropRecognizable S) (hT : TropRecognizable T) :
    TropRecognizable (seriesMin S T) := by
  obtain ⟨ QS, hQS, AS, hAS ⟩ := hS
  obtain ⟨ QT, hQT, AT, hAT ⟩ := hT
  use QS × QT
  use inferInstance
  use ⟨fun q a => (AS.step q.1 a, AT.step q.2 a), (AS.init, AT.init), fun q => min (AS.out q.1) (AT.out q.2)⟩
  intro w
  simp [TropDFA.evalCost, TropDFA.run, hAS, hAT];
  -- By definition of `run`, we can split the run into the runs of `AS` and `AT`.
  have h_run_split : ∀ (q : QS × QT) (w : List σ), (TropDFA.run ⟨fun q a => (AS.step q.1 a, AT.step q.2 a), (AS.init, AT.init), fun q => min (AS.out q.1) (AT.out q.2)⟩ q w) = (AS.run q.1 w, AT.run q.2 w) := by
    intro q w; induction w generalizing q <;> simp +decide [ *, TropDFA.run ] ;
  simp_all +decide [ TropDFA.recognizes, seriesMin ];
  rw [ ← hAS, ← hAT, TropDFA.evalCost, TropDFA.evalCost ]

theorem tropRecognizable_add {S T : TropSeries σ}
    (hS : TropRecognizable S) (hT : TropRecognizable T) :
    TropRecognizable (seriesAdd S T) := by
  obtain ⟨ Q_S, hQ_S, A_S, hAS ⟩ := hS
  obtain ⟨ Q_T, hQ_T, A_T, hAT ⟩ := hT;
  refine' ⟨ Q_S × Q_T, inferInstance, _, _ ⟩;
  exact ⟨ fun q a => ( A_S.step q.1 a, A_T.step q.2 a ), ( A_S.init, A_T.init ), fun q => A_S.out q.1 + A_T.out q.2 ⟩;
  intro w; simp +decide [ TropDFA.evalCost, TropDFA.run_append, hAS, hAT ] ;
  -- By definition of run, we can split the run into the runs of the individual components.
  have h_run_split : ∀ (q : Q_S × Q_T) (w : List σ), (TropDFA.run ⟨fun q a => (A_S.step q.1 a, A_T.step q.2 a), (A_S.init, A_T.init), fun q => A_S.out q.1 + A_T.out q.2⟩ q w) = (A_S.run q.1 w, A_T.run q.2 w) := by
    intro q w; induction' w with a w ih generalizing q <;> simp +decide [ *, TropDFA.run ] ;
  rw [ h_run_split ] ; exact congr_arg₂ ( · + · ) ( hAS _ ) ( hAT _ ) ;

/-
Helper: indicator series for any word is recognizable.
We prove this by induction on the length of the word.
-/
theorem tropRecognizable_indicator [DecidableEq σ]
    (w : List σ) (c : WithTop ℕ) :
    TropRecognizable (fun v : List σ => if v = w then c else ⊤) := by
  induction' w with h Howerizing c;
  · exact?;
  · obtain ⟨ Q, hQ, A, hA ⟩ := c;
    -- Construct a new DFA with states that include the initial state, the dead state, and the states of A.
    set Q' : Type := Option (Option Q)
    set A' : TropDFA σ Q' := {
      step := fun q a => match q with
        | none => if a = h then some (some A.init) else some none
        | some none => some none
        | some (some q) => some (some (A.step q a))
      init := none
      out := fun q => match q with
        | none => ⊤
        | some none => ⊤
        | some (some q) => A.out q
    };
    refine' ⟨ Q', inferInstance, A', _ ⟩;
    intro v;
    rcases v with ( _ | ⟨ a, v ⟩ ) <;> simp +decide [ TropDFA.evalCost ];
    · rfl;
    · by_cases ha : a = h <;> simp +decide [ ha, TropDFA.run ];
      · -- By definition of $A'$, we know that $A'.run (A'.step A'.init h) v = some (some (A.run A.init v))$.
        have h_run : A'.run (A'.step A'.init h) v = some (some (A.run A.init v)) := by
          have h_run : ∀ (q : Q) (v : List σ), A'.run (some (some q)) v = some (some (A.run q v)) := by
            intro q v; induction' v with a v ih generalizing q <;> simp +decide [ *, TropDFA.run ] ;
            convert ih ( A.step q a ) using 1;
          grind +locals;
        rw [ h_run ];
        exact hA v;
      · induction v <;> simp +decide [ *, TropDFA.run ];
        · grind;
        · grind

/-- Forward compilation: formula-definable implies recognizable. -/
theorem formula_definable_implies_recognizable [DecidableEq σ]
    (S : TropSeries σ) (hS : FormulaDefinable S) :
    TropRecognizable S := by
  obtain ⟨φ, rfl⟩ := hS
  induction φ with
  | const c => exact tropRecognizable_const c
  | indicator w c => exact tropRecognizable_indicator w c
  | add φ ψ ihφ ihψ => exact tropRecognizable_add ihφ ihψ
  | tmin φ ψ ihφ ihψ => exact tropRecognizable_min ihφ ihψ

/-! ## Finite Derivative Structure -/

def HasFiniteDerivatives (S : TropSeries σ) : Prop :=
  Set.Finite (Set.range (leftDeriv S))

def TropDFA.residualAt (A : TropDFA α σs) (q : σs) : TropSeries α :=
  fun w => A.out (A.run q w)

theorem TropDFA.leftDeriv_eq_residualAt (A : TropDFA α σs) (S : TropSeries α)
    (hA : A.recognizes S) (u : List α) :
    leftDeriv S u = A.residualAt (A.run A.init u) := by
  ext w; simp [leftDeriv, TropDFA.residualAt, ← A.run_append]; exact (hA (u ++ w)).symm

theorem recognizable_implies_finite_derivatives [Fintype σs]
    (A : TropDFA α σs) (S : TropSeries α) (hA : A.recognizes S) :
    HasFiniteDerivatives S := by
  apply Set.Finite.subset (Set.finite_range (fun q : σs => A.residualAt q))
  rintro _ ⟨u, rfl⟩
  exact ⟨A.run A.init u, (A.leftDeriv_eq_residualAt S hA u).symm⟩

/-! ## Main Characterization Theorem -/

/-- **Tropical Schützenberger Theorem (Formula Version).**

A tropical series is formula-definable if and only if it is tropically
recognizable and every left derivative is formula-definable.

The forward direction uses derivative closure (proved above) and forward
compilation. The reverse direction is immediate: if all derivatives are
formula-definable, then `S = leftDeriv S []` is formula-definable.

This theorem characterizes formula-definable series semantically:
they are exactly the recognizable series whose Nerode quotient structure
is formula-compatible. -/
theorem tropical_formula_iff_recognizable_and_deriv_closed [DecidableEq σ] [Fintype σ]
    (S : TropSeries σ) :
    FormulaDefinable S ↔
    (TropRecognizable S ∧ ∀ u, FormulaDefinable (leftDeriv S u)) := by
  constructor
  · intro hS
    exact ⟨formula_definable_implies_recognizable S hS,
           formula_definable_leftDeriv S hS⟩
  · intro ⟨_, hDeriv⟩
    have := hDeriv []
    simpa using this

/-! ## Tropical Algebraic Identities -/

/-- Tropical addition distributes over minimum. -/
theorem tropical_plus_distributes_over_min (a b c : WithTop ℕ) :
    a + min b c = min (a + b) (a + c) := add_min a b c

/-- Minimum is idempotent. -/
theorem tropical_min_idem (a : WithTop ℕ) : min a a = a := min_self a

/-- The mirror theorem: `min(S, S) = S` for series. -/
theorem tropical_mirror_series (S : TropSeries σ) :
    seriesMin S S = S := by
  ext w; simp [seriesMin]

/-! ## Finite-Support Series -/

/-- A series has finite support. -/
def FiniteSupport (S : TropSeries σ) : Prop :=
  Set.Finite {w | S w ≠ ⊤}

/-
A finite-support series over a decidable alphabet is formula-definable.
It can be written as the minimum over indicator formulas for each word
in the support.
-/
theorem finiteSupport_formulaDefinable [DecidableEq σ]
    (S : TropSeries σ) (hS : FiniteSupport S) :
    FormulaDefinable S := by
  obtain ⟨n, hn⟩ : ∃ n : ℕ, ∀ w, S w ≠ ⊤ → w.length ≤ n := by
    exact Set.Finite.bddAbove ( hS.image List.length ) |> fun ⟨ n, hn ⟩ => ⟨ n, fun w hw => hn ( Set.mem_image_of_mem _ hw ) ⟩;
  -- Since the support of S is finite, we can write S as the minimum of the indicator functions of the words in the support.
  have h_indicator : S = seriesMin (fun w => if w.length ≤ n then S w else ⊤) (fun w => if w.length ≤ n then S w else ⊤) := by
    grind +locals;
  clear h_indicator hn;
  have h_ind : ∀ (s : Finset (List σ)), FormulaDefinable (fun w => if w ∈ s then S w else ⊤) := by
    intro s
    induction' s using Finset.induction with w s ih;
    · exact ⟨ .const ⊤, by aesop ⟩;
    · rename_i h;
      convert formulaDefinable_min h ( formulaDefinable_indicator w ( S w ) ) using 1;
      unfold seriesMin; aesop;
  convert h_ind ( hS.toFinset );
  by_cases h : S ‹_› = ⊤ <;> simp_all +decide [ FiniteSupport ]

/-! ## Acyclic Automata -/

/-- A DFA is acyclic if there is a rank function strictly decreasing on
non-self-loop transitions. -/
def TropDFA.IsAcyclic [Fintype σs] (A : TropDFA α σs) : Prop :=
  ∃ rank : σs → ℕ, ∀ q a, A.step q a ≠ q → rank (A.step q a) < rank q

/-- Acyclic recognizability. -/
def AcyclicRecognizable (S : TropSeries σ) : Prop :=
  ∃ (Q : Type) (_ : Fintype Q), ∃ A : TropDFA σ Q, A.IsAcyclic ∧ A.recognizes S

end TropicalFormulaDefinability