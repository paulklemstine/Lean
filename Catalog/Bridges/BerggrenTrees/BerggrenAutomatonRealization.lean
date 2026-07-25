import Mathlib

/-! # Berggren Automaton Realization Theory

We formalize a Myhill–Nerode realization theorem for weighted streams on the Berggren
alphabet `{A, B, C}`, the three generators of the ternary tree enumerating all primitive
Pythagorean triples via the Berggren matrices.

## Main results

* `berggren_finite_rank_iff_recognizable` : A Berggren stream has finite residual rank
  if and only if it is recognized by a finite-state automaton.
* `hankel_iff_residual` : Hankel finite rank is equivalent to finite residual rank.
* `berggren_minimality` : Any recognizing automaton has at least as many states as
  there are distinct residuals, establishing minimality of the canonical residual automaton.
* `berggren_myhill_nerode` : Specialization to `Bool`-valued streams gives the classical
  Myhill–Nerode theorem for languages over the Berggren alphabet.
-/

noncomputable section
open Classical

/-! ## Definitions -/

/-- The three Berggren generators, labeling the three branches of the ternary tree of
primitive Pythagorean triples. Every primitive Pythagorean triple is obtained from
`(3,4,5)` by a unique finite word over these generators. -/
inductive BerggrenLetter : Type
  | A | B | C
  deriving DecidableEq, Fintype

/-- A Berggren stream over `K`: a function assigning a value in `K` to each word
over the Berggren alphabet. -/
def BerggrenStream (K : Type) := List BerggrenLetter → K

/-- Left residual: `leftResidual S u` is the stream `v ↦ S(u ++ v)`. -/
def leftResidual {K : Type} (S : BerggrenStream K) (u : List BerggrenLetter) :
    BerggrenStream K :=
  fun v => S (u ++ v)

/-- The Berggren–Hankel kernel: `berggrenHankel S u v = S(u ++ v)`. -/
def berggrenHankel {K : Type} (S : BerggrenStream K) :
    List BerggrenLetter → List BerggrenLetter → K :=
  fun u v => S (u ++ v)

/-- The residual family of `S`: the set of all left residuals `{leftResidual S u | u}`. -/
def ResidualFamily {K : Type} (S : BerggrenStream K) : Set (BerggrenStream K) :=
  Set.range (leftResidual S)

/-- A stream has finite residual rank if its residual family is a finite set. -/
def FiniteResidualRank {K : Type} (S : BerggrenStream K) : Prop :=
  Set.Finite (ResidualFamily S)

/-- Hankel finite rank: the set of row functions of the Hankel kernel is finite.
Since `berggrenHankel S u = leftResidual S u`, this coincides with finite residual rank. -/
def HankelFiniteRank {K : Type} (S : BerggrenStream K) : Prop :=
  Set.Finite (Set.range (berggrenHankel S))

/-- A finite-state weighted Berggren automaton. The state space `Q` is a finite type,
transitions are deterministic, and `output` assigns a value in `K` to each state. -/
structure BerggrenWA (K : Type) where
  Q : Type
  instFintype : Fintype Q
  step : Q → BerggrenLetter → Q
  initState : Q
  output : Q → K

attribute [instance] BerggrenWA.instFintype

/-- The state reached by processing word `w` from the initial state. -/
def BerggrenWA.run {K : Type} (A : BerggrenWA K) (w : List BerggrenLetter) : A.Q :=
  w.foldl A.step A.initState

/-- An automaton recognizes a stream if `S(w) = output(run(w))` for all words `w`. -/
def BerggrenWA.recognizes {K : Type} (A : BerggrenWA K) (S : BerggrenStream K) : Prop :=
  ∀ w, S w = A.output (A.run w)

/-- A stream is recognizable if some finite automaton recognizes it. -/
def BerggrenRecognizable {K : Type} (S : BerggrenStream K) : Prop :=
  ∃ A : BerggrenWA K, A.recognizes S

/-! ## Basic Lemmas -/

@[simp]
lemma leftResidual_nil {K : Type} (S : BerggrenStream K) :
    leftResidual S [] = S := by
  funext v; simp [leftResidual]

lemma leftResidual_append {K : Type} (S : BerggrenStream K)
    (u w : List BerggrenLetter) :
    leftResidual S (u ++ w) = leftResidual (leftResidual S u) w := by
  funext v; simp [leftResidual, List.append_assoc]

@[simp]
lemma leftResidual_eval_nil {K : Type} (S : BerggrenStream K)
    (u : List BerggrenLetter) : leftResidual S u [] = S u := by
  unfold leftResidual; simp

lemma stream_mem_residualFamily {K : Type} (S : BerggrenStream K) :
    S ∈ ResidualFamily S :=
  ⟨[], by simp⟩

lemma leftResidual_mem_residualFamily {K : Type} (S : BerggrenStream K)
    (u : List BerggrenLetter) :
    leftResidual S u ∈ ResidualFamily S :=
  ⟨u, rfl⟩

lemma residual_letter_closed {K : Type} (S : BerggrenStream K)
    {f : BerggrenStream K} (hf : f ∈ ResidualFamily S) (a : BerggrenLetter) :
    leftResidual f [a] ∈ ResidualFamily S := by
  obtain ⟨u, rfl⟩ := hf
  exact ⟨u ++ [a], leftResidual_append S u [a]⟩

@[simp]
lemma BerggrenWA.run_nil {K : Type} (A : BerggrenWA K) :
    A.run [] = A.initState := rfl

lemma BerggrenWA.run_append {K : Type} (A : BerggrenWA K)
    (u v : List BerggrenLetter) :
    A.run (u ++ v) = v.foldl A.step (A.run u) := by
  simp [BerggrenWA.run, List.foldl_append]

/-! ## Residual Automaton Construction -/

/-- Step function on the residual family subtype: given a residual and a letter,
produce the extended residual. -/
def residualStep {K : Type} (S : BerggrenStream K) :
    ↥(ResidualFamily S) → BerggrenLetter → ↥(ResidualFamily S) :=
  fun x a => ⟨leftResidual x.val [a], residual_letter_closed S x.prop a⟩

@[simp]
lemma residualStep_val {K : Type} (S : BerggrenStream K)
    (x : ↥(ResidualFamily S)) (a : BerggrenLetter) :
    (residualStep S x a).val = leftResidual x.val [a] := rfl

/-
Key inductive lemma: running the residual step function on a word `w`
starting from state `x` yields `leftResidual x.val w`.
-/
lemma residual_foldl_val {K : Type} (S : BerggrenStream K)
    (x : ↥(ResidualFamily S)) (w : List BerggrenLetter) :
    (w.foldl (residualStep S) x).val = leftResidual x.val w := by
  induction' w using List.reverseRecOn with w ih;
  · rfl;
  · unfold leftResidual at *; aesop;

/-! ## Main Theorems -/

/-
**Backward direction**: any recognizable stream has finite residual rank.
The residuals are determined by automaton states, so there are at most `|Q|` of them.
-/
theorem recognizable_imp_finite_rank {K : Type} (S : BerggrenStream K)
    (h : BerggrenRecognizable S) : FiniteResidualRank S := by
  obtain ⟨ A, hA ⟩ := h;
  -- Define g : A.Q → BerggrenStream K by g q = fun v => A.output (v.foldl A.step q).
  set g : A.Q → BerggrenStream K := fun q => fun v => A.output (v.foldl A.step q);
  -- Show that ResidualFamily S ⊆ Set.range g.
  have h_subset : ResidualFamily S ⊆ Set.range g := by
    intro f hf
    obtain ⟨ u, rfl ⟩ := hf
    use A.run u
    funext v
    simp [g];
    convert hA ( u ++ v ) |> Eq.symm using 1;
    rw [ BerggrenWA.run_append ];
  exact Set.Finite.subset ( Set.toFinite _ ) h_subset

/-
**Forward direction**: any stream with finite residual rank is recognizable.
The canonical residual automaton recognizes it.
-/
theorem finite_rank_imp_recognizable {K : Type} (S : BerggrenStream K)
    (h : FiniteResidualRank S) : BerggrenRecognizable S := by
  constructor;
  swap;
  constructor;
  convert Set.Finite.fintype h;
  exact fun x a => ⟨ leftResidual x.val [ a ], residual_letter_closed S x.2 a ⟩;
  exact ⟨ S, stream_mem_residualFamily S ⟩;
  exact fun x => x.val [];
  intro w; simp +decide [ BerggrenWA.run ] ;
  convert leftResidual_eval_nil S w |> Eq.symm;
  convert residual_foldl_val S ⟨ S, stream_mem_residualFamily S ⟩ w

/-- **Main equivalence (Berggren Realization Theorem)**: a Berggren stream has finite
residual rank if and only if it is recognized by a finite-state automaton. This is the
Schützenberger–Myhill–Nerode realization theorem specialized to the Berggren alphabet. -/
theorem berggren_finite_rank_iff_recognizable {K : Type}
    (S : BerggrenStream K) :
    FiniteResidualRank S ↔ BerggrenRecognizable S :=
  ⟨finite_rank_imp_recognizable S, recognizable_imp_finite_rank S⟩

/-
Hankel finite rank is equivalent to finite residual rank.
This follows because Hankel rows are exactly left residuals.
-/
theorem hankel_iff_residual {K : Type} (S : BerggrenStream K) :
    HankelFiniteRank S ↔ FiniteResidualRank S := by
  constructor <;> intro h <;> convert h

/-
**Minimality**: the residual family of `S` is contained in the image of any
recognizing automaton's state space under the state-to-residual map. Hence any
recognizing automaton has at least as many states as there are distinct residuals.
-/
theorem berggren_minimality {K : Type} (S : BerggrenStream K)
    (A : BerggrenWA K) (hA : A.recognizes S) :
    ResidualFamily S ⊆
      Set.range (fun q : A.Q => fun v : List BerggrenLetter =>
        A.output (v.foldl A.step q)) := by
  intro f hf
  obtain ⟨u, hu⟩ := hf
  use A.run u
  funext v
  rw [← hu, leftResidual, hA (u ++ v), BerggrenWA.run_append]

/-
**Minimality cardinality bound**: the number of distinct residuals is at most
the number of states in any recognizing automaton.
-/
theorem berggren_minimality_card {K : Type} (S : BerggrenStream K)
    (A : BerggrenWA K) (hA : A.recognizes S) :
    Nat.card ↥(ResidualFamily S) ≤ Fintype.card A.Q := by
  have h_subset : ResidualFamily S ⊆ Set.range (fun q : A.Q => fun v : List BerggrenLetter => A.output (v.foldl A.step q)) := by
    exact berggren_minimality S A hA;
  have h_card_le : Nat.card (Set.range (fun q : A.Q => fun v : List BerggrenLetter => A.output (v.foldl A.step q))) ≤ Fintype.card A.Q := by
    rw [ Nat.card_eq_fintype_card ] ; exact Fintype.card_range_le _;
  refine le_trans ?_ h_card_le;
  apply_rules [ Nat.card_mono ];
  exact Set.toFinite _

/-- **Corollary (Berggren Myhill–Nerode)**: a `Bool`-valued stream (language) over
the Berggren alphabet has finite residual rank iff it is recognized by a finite-state
automaton. -/
theorem berggren_myhill_nerode (L : BerggrenStream Bool) :
    FiniteResidualRank L ↔ BerggrenRecognizable L :=
  berggren_finite_rank_iff_recognizable L

end