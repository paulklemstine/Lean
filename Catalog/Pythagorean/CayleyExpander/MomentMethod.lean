/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Moment Method for Random Cayley Expander Conjecture

This file establishes the combinatorial-spectral bridge for the moment method
applied to Cayley graphs of finite groups with two generators. We formalize:

1. A word alphabet for symmetric 2-generator Cayley graphs
2. Word evaluation into arbitrary groups
3. Closed-walk counting as a finitary combinatorial object
4. The trace–closed-walk identity: `tr(A^m) = |G| * closedWordCount`
5. Conjugation/inversion symmetry of closed-word counts
6. Backtrack-free word counting: `4 · 3^(m-1)` for `m ≥ 1`
7. Trivial upper bound: closed-word count ≤ 4^m
8. Exact formulas for small moments

## Catalog Leverage

This file imports and builds on:
- `Pythagorean.CayleyExpander.Defs` for Dirichlet energy and spectral data
- `Pythagorean.CayleyExpander.Connectivity` for `word_in_generators_of_mem_closure`
-/
import Mathlib
import Pythagorean.CayleyExpander.Defs
import Pythagorean.CayleyExpander.Connectivity

open Finset BigOperators Matrix

/-! ## Word Alphabet and Evaluation -/

/-- The four-letter alphabet for a symmetric 2-generator Cayley graph:
    σ, σ⁻¹, τ, τ⁻¹. This encodes the step set of the random walk. -/
inductive GenLetter
  | sigma | sigmaInv | tau | tauInv
  deriving DecidableEq, Repr, Fintype

namespace GenLetter

/-- The formal inverse map on the alphabet. This is an involution. -/
def inv : GenLetter → GenLetter
  | sigma    => sigmaInv
  | sigmaInv => sigma
  | tau      => tauInv
  | tauInv   => tau

@[simp]
theorem inv_inv (a : GenLetter) : a.inv.inv = a := by
  cases a <;> rfl

@[simp]
theorem inv_ne_self (a : GenLetter) : a.inv ≠ a := by
  cases a <;> simp [inv]

theorem inv_injective : Function.Injective inv := by
  intro a b h; cases a <;> cases b <;> simp_all [inv]

/-- The cardinality of the alphabet is 4. -/
@[simp]
theorem card_genLetter : Fintype.card GenLetter = 4 := by decide

end GenLetter

/-! ## Two-Generator Cayley Data -/

/-- Encapsulates a choice of two generators in a group. -/
structure TwoGenCayleyData (G : Type*) [Group G] where
  /-- The first generator -/
  sigma : G
  /-- The second generator -/
  tau   : G

namespace TwoGenCayleyData

variable {G : Type*} [Group G]

/-- Evaluate a single letter in a group. -/
def evalLetter (d : TwoGenCayleyData G) : GenLetter → G
  | .sigma    => d.sigma
  | .sigmaInv => d.sigma⁻¹
  | .tau      => d.tau
  | .tauInv   => d.tau⁻¹

/-- Evaluating a letter's formal inverse gives the group inverse. -/
@[simp]
theorem evalLetter_inv (d : TwoGenCayleyData G) (a : GenLetter) :
    d.evalLetter a.inv = (d.evalLetter a)⁻¹ := by
  cases a <;> simp [evalLetter, GenLetter.inv]

end TwoGenCayleyData

/-! ## Word Evaluation -/

/-- Evaluate a word (list of letters) in a group by left-to-right product. -/
def evalWord {G : Type*} [Group G] (σ τ : G) : List GenLetter → G
  | []     => 1
  | a :: w => (TwoGenCayleyData.mk σ τ).evalLetter a * evalWord σ τ w

@[simp]
theorem evalWord_nil {G : Type*} [Group G] (σ τ : G) :
    evalWord σ τ [] = 1 := rfl

@[simp]
theorem evalWord_cons {G : Type*} [Group G] (σ τ : G) (a : GenLetter) (w : List GenLetter) :
    evalWord σ τ (a :: w) = (TwoGenCayleyData.mk σ τ).evalLetter a * evalWord σ τ w := rfl

/-- Word evaluation respects concatenation. -/
theorem evalWord_append {G : Type*} [Group G] (σ τ : G) (w₁ w₂ : List GenLetter) :
    evalWord σ τ (w₁ ++ w₂) = evalWord σ τ w₁ * evalWord σ τ w₂ := by
  induction w₁ with
  | nil => simp
  | cons a w₁ ih => simp [ih, mul_assoc]

/-! ## Closed-Word Count -/

/-- The number of words of length `m` in the four-letter alphabet that evaluate
    to the identity element. This is the fundamental combinatorial quantity
    of the moment method. -/
noncomputable def closedWordCount {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) : ℕ :=
  Fintype.card { w : Fin m → GenLetter // evalWord σ τ (List.ofFn w) = 1 }

/-- Alternative characterization via Finset.filter. -/
theorem closedWordCount_eq_filter {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) :
    closedWordCount σ τ m =
      (Finset.univ.filter fun w : Fin m → GenLetter =>
        evalWord σ τ (List.ofFn w) = 1).card := by
  simp [closedWordCount, Fintype.card_subtype]

/-! ## Trivial Bounds -/

/-- **Closed-word count is bounded by total word count**: at most 4^m. -/
theorem closedWordCount_le_allWords {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (σ τ : G) (m : ℕ) :
    closedWordCount σ τ m ≤ 4 ^ m := by
  rw [closedWordCount_eq_filter]
  calc (Finset.univ.filter fun w : Fin m → GenLetter =>
          evalWord σ τ (List.ofFn w) = 1).card
      ≤ Finset.univ.card := Finset.card_filter_le _ _
    _ = Fintype.card (Fin m → GenLetter) := rfl
    _ = 4 ^ m := by simp [Fintype.card_fun, Fintype.card_fin, GenLetter.card_genLetter]

/-- Length-0 closed-word count is 1: the empty word evaluates to 1. -/
theorem closedWordCount_zero {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (σ τ : G) :
    closedWordCount σ τ 0 = 1 := by
  simp [closedWordCount_eq_filter, Finset.filter_true_of_mem, List.ofFn_zero]

/-! ## Inversion Symmetry -/

/-- Map each letter to its inverse. -/
def invertLetters (m : ℕ) : (Fin m → GenLetter) → (Fin m → GenLetter) :=
  fun w i => (w i).inv

theorem invertLetters_involutive (m : ℕ) : Function.Involutive (invertLetters m) := by
  intro w; ext i; simp [invertLetters]

/-- Evaluating an inverted word with (σ,τ) = evaluating original with (σ⁻¹,τ⁻¹). -/
theorem evalWord_map_inv {G : Type*} [Group G] (σ τ : G) (w : List GenLetter) :
    evalWord σ τ (w.map GenLetter.inv) = evalWord σ⁻¹ τ⁻¹ w := by
  induction w with
  | nil => simp
  | cons a w ih =>
    simp [ih]
    cases a <;> simp [TwoGenCayleyData.evalLetter, GenLetter.inv]

theorem ofFn_invertLetters (m : ℕ) (w : Fin m → GenLetter) :
    List.ofFn (invertLetters m w) = (List.ofFn w).map GenLetter.inv := by
  apply List.ext_getElem
  · simp [invertLetters]
  · intro i h₁ h₂
    simp [invertLetters]

/-
**Closed-word count is invariant under simultaneous inversion.**
-/
theorem closedWordCount_inv_invariant
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) :
    closedWordCount σ τ m = closedWordCount σ⁻¹ τ⁻¹ m := by
  convert Finset.card_bij ( fun w hw => invertLetters m w ) _ _ _;
  convert closedWordCount_eq_filter σ τ m using 1;
  convert closedWordCount_eq_filter σ⁻¹ τ⁻¹ m using 1;
  · simp +contextual [ ← evalWord_map_inv, ofFn_invertLetters ];
    intro a ha; convert ha using 2; ext i; simp +decide [ invertLetters ] ;
  · simp +contextual [ funext_iff, invertLetters ];
    exact fun a₁ ha₁ a₂ ha₂ h x => by simpa using congr_arg GenLetter.inv ( h x ) ;
  · intro w hw; use invertLetters m w; simp_all +decide [ invertLetters_involutive ] ;
    exact ⟨ by rw [ ofFn_invertLetters, evalWord_map_inv ] ; exact hw, by ext i; simp +decide [ invertLetters ] ⟩

/-! ## Backtrack-Free Words -/

/-- A word is backtrack-free if no letter is immediately followed by its
    formal inverse. -/
def BacktrackFree : List GenLetter → Prop
  | []          => True
  | [_]         => True
  | a :: b :: w => (b ≠ a.inv) ∧ BacktrackFree (b :: w)

instance : DecidablePred BacktrackFree := by
  intro l
  induction l with
  | nil => exact isTrue trivial
  | cons a l ih =>
    cases l with
    | nil => exact isTrue trivial
    | cons b w =>
      exact @instDecidableAnd _ _ (inferInstance) ih

/-! ## Word Reversal -/

/-- Reverse-and-invert: reverse the word and invert each letter. -/
def reverseInvertWord : List GenLetter → List GenLetter :=
  fun w => (w.reverse.map GenLetter.inv)

/-- The reverse-invert map is an involution. -/
theorem reverseInvertWord_involution (w : List GenLetter) :
    reverseInvertWord (reverseInvertWord w) = w := by
  simp [reverseInvertWord, List.map_reverse, List.map_map]
  induction w with
  | nil => simp
  | cons a t ih => simp [ih]

/-
Evaluating a reversed-and-inverted word gives the inverse of the original.
-/
theorem evalWord_reverseInvert {G : Type*} [Group G] (σ τ : G)
    (w : List GenLetter) :
    evalWord σ τ (reverseInvertWord w) = (evalWord σ τ w)⁻¹ := by
  induction' w using List.reverseRecOn with w a ih;
  · simp +decide [ reverseInvertWord ];
  · unfold reverseInvertWord at *; simp_all +decide [ List.map_append, List.reverse_append ] ;
    rw [ evalWord_append ] ; simp +decide [ mul_assoc, mul_comm, mul_left_comm ] ;

/-! ## Moment Kernel and Cross-Domain Bridge -/

/-- **The moment kernel**: the probability that a length-m random walk returns
    to the identity. Connects to random matrix theory, quantum information,
    and statistical mechanics as the m-th spectral moment. -/
noncomputable def momentKernel {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) : ℚ :=
  (closedWordCount σ τ m : ℚ) / (4 : ℚ) ^ m

/-- The moment kernel is nonnegative. -/
theorem momentKernel_nonneg {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) : 0 ≤ momentKernel σ τ m :=
  div_nonneg (Nat.cast_nonneg _) (pow_nonneg (by norm_num) _)

/-- The moment kernel is at most 1. -/
theorem momentKernel_le_one {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) : momentKernel σ τ m ≤ 1 :=
  div_le_one_of_le₀ (by exact_mod_cast closedWordCount_le_allWords σ τ m) (by positivity)

/-- Moment kernel at length 0 is 1. -/
theorem momentKernel_zero {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) : momentKernel σ τ 0 = 1 := by
  simp [momentKernel, closedWordCount_zero]

/-! ## Adjacency Matrix -/

/-- The unnormalized adjacency matrix of Cay(G, {σ,σ⁻¹,τ,τ⁻¹}).
    Entry (g, h) counts generators s with h = s * g. -/
noncomputable def cayleyAdjMatrixTwoGen {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) : Matrix G G ℚ :=
  Matrix.of fun g h =>
    ((Finset.univ.filter fun a : GenLetter =>
      h = (TwoGenCayleyData.mk σ τ).evalLetter a * g).card : ℚ)

/-- The normalized adjacency matrix, dividing by degree 4. -/
noncomputable def cayleyAdjMatrixNorm {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) : Matrix G G ℚ :=
  (1 / 4 : ℚ) • cayleyAdjMatrixTwoGen σ τ

/-! ## Walk Counting via Matrix Powers -/

/-
The (g,h) entry of A^m counts length-m walks from g to h.
-/
theorem adjMatrix_pow_counts_walks
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) (g h : G) :
    (cayleyAdjMatrixTwoGen σ τ ^ m) g h =
      ((Finset.univ.filter fun w : Fin m → GenLetter =>
        evalWord σ τ (List.ofFn w) * g = h).card : ℚ) := by
  induction' m with m ih generalizing g h;
  · by_cases hg : g = h <;> simp +decide [ hg, evalWord ];
  · rw [ pow_succ, Matrix.mul_apply ];
    -- By definition of $cayleyAdjMatrixTwoGen$, we know that
    have h_adj : ∀ j h : G, (cayleyAdjMatrixTwoGen σ τ j h : ℚ) = (Finset.card (Finset.filter (fun a : GenLetter => h = (TwoGenCayleyData.mk σ τ).evalLetter a * j) Finset.univ) : ℚ) := by
      aesop;
    simp +decide only [h_adj, ih, Nat.cast_mul];
    norm_cast;
    simp +decide only [card_eq_sum_ones, Finset.sum_mul _ _ _];
    simp +decide only [Finset.sum_sigma', one_mul];
    refine' Finset.sum_bij ( fun x _ => fun i => if h : i = ⟨ 0, Nat.succ_pos m ⟩ then x.2.2 else x.2.1 ( Fin.pred i h ) ) _ _ _ _ <;> simp +decide;
    · simp +contextual [ mul_assoc ];
    · intro a₁ ha₁ ha₂ a₂ ha₃ ha₄ h; simp_all +decide [ funext_iff, Fin.forall_fin_succ ] ;
      ext <;> aesop;
    · intro b hb;
      refine' ⟨ fun i => b i.succ, b 0, _, _ ⟩ <;> simp +decide [ ← mul_assoc, hb ];
      exact funext fun i => by cases i using Fin.inductionOn <;> simp +decide ;

/-
**Theorem 1: Trace–Closed-Walk Identity.**
    The trace of A^m equals |G| times the closed-word count.
    This is the master identity of the moment method.
-/
theorem trace_pow_eq_closedWordCount
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) :
    Matrix.trace (cayleyAdjMatrixTwoGen σ τ ^ m) =
      ((closedWordCount σ τ m : ℚ) * (Fintype.card G : ℚ)) := by
  convert Finset.sum_congr rfl fun g _ => adjMatrix_pow_counts_walks σ τ m g g;
  simp +decide [ mul_comm, closedWordCount_eq_filter ]

/-
**Cross-domain: spectral moment = return probability.**
    The m-th spectral moment of the normalized Cayley graph equals
    the return probability of the associated random walk (moment kernel).
-/
theorem spectral_moment_eq_return_prob
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) :
    (1 / (Fintype.card G : ℚ)) * Matrix.trace (cayleyAdjMatrixNorm σ τ ^ m) =
      momentKernel σ τ m := by
  convert congr_arg ( fun x : ℚ => ( 1 / ( Fintype.card G : ℚ ) * ( ( 1 / 4 : ℚ ) ^ m * x ) ) ) ( trace_pow_eq_closedWordCount σ τ m ) using 1 ; ring!;
  · rw [ mul_assoc ] ; rw [ show cayleyAdjMatrixNorm σ τ = ( 1 / 4 : ℚ ) • cayleyAdjMatrixTwoGen σ τ from rfl ] ; rw [ smul_pow ] ; norm_num ; ring;
  · unfold momentKernel; ring;
    simp +decide [ mul_assoc, mul_comm, mul_left_comm, ne_of_gt ( Fintype.card_pos ) ]

/-! ## Counting Lemma for m = 1 -/

/-
At length 1, a word is closed iff the single generator equals 1.
-/
theorem closedWordCount_one_eq {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (σ τ : G) :
    closedWordCount σ τ 1 =
      (Finset.univ.filter fun a : GenLetter =>
        (TwoGenCayleyData.mk σ τ).evalLetter a = 1).card := by
  convert Fintype.card_subtype ( fun w : Fin 1 → GenLetter => evalWord σ τ ( List.ofFn w ) = 1 ) using 1;
  refine' Finset.card_bij ( fun x _ => fun _ => x ) _ _ _ <;> simp +decide [ evalWord ];
  · exact fun a₁ ha₁ a₂ ha₂ h => congr_fun h 0;
  · exact fun b hb => ⟨ b 0, hb, by ext i; fin_cases i; rfl ⟩

/-! ## Conjugation Invariance -/

/-
**Closed-word count is invariant under simultaneous conjugation.**
    For any h, replacing (σ,τ) by (hσh⁻¹, hτh⁻¹) doesn't change the count.
-/
theorem closedWordCount_conj_invariant
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ h : G) (m : ℕ) :
    closedWordCount (h * σ * h⁻¹) (h * τ * h⁻¹) m = closedWordCount σ τ m := by
  -- By definition of `evalWord`, we know that `evalWord (h * σ * h⁻¹) (h * τ * h⁻¹) w = h * evalWord σ τ w * h⁻¹`.
  have h_eval_conj : ∀ w : List GenLetter, evalWord (h * σ * h⁻¹) (h * τ * h⁻¹) w = h * evalWord σ τ w * h⁻¹ := by
    intro w
    induction' w with a w ih;
    · simp +decide [ evalWord ];
    · -- By definition of `evalWord`, we can split the evaluation into the evaluation of the first letter and the evaluation of the rest of the word.
      simp [evalWord, ih];
      rcases a with ( _ | _ | _ | _ ) <;> simp +decide [ mul_assoc ];
      · simp +decide [ mul_assoc, TwoGenCayleyData.evalLetter ];
      · simp +decide [ TwoGenCayleyData.evalLetter, mul_assoc ];
      · simp +decide [ mul_assoc, TwoGenCayleyData.evalLetter ];
      · simp +decide [ mul_assoc, TwoGenCayleyData.evalLetter ];
  convert Fintype.card_subtype ( fun w : Fin m → GenLetter => evalWord ( h * σ * h⁻¹ ) ( h * τ * h⁻¹ ) ( List.ofFn w ) = 1 ) using 1;
  convert Fintype.card_subtype ( fun w : Fin m → GenLetter => evalWord σ τ ( List.ofFn w ) = 1 ) using 1;
  simp +decide [ h_eval_conj, mul_eq_one_iff_eq_inv ]

/-! ## Length-2 Lower Bound -/

/-
For any group, there are always at least 4 closed words of length 2:
    the four immediate-cancellation words (a, a.inv) for each letter a.
-/
theorem closedWordCount_two_ge_four
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (σ τ : G) :
    4 ≤ closedWordCount σ τ 2 := by
  convert Set.one_lt_encard_iff.mp _ using 1;
  rotate_left;
  exact Fin 2 → GenLetter;
  exact { fun i => if i = 0 then GenLetter.sigma else GenLetter.sigmaInv, fun i => if i = 0 then GenLetter.sigmaInv else GenLetter.sigma, fun i => if i = 0 then GenLetter.tau else GenLetter.tauInv, fun i => if i = 0 then GenLetter.tauInv else GenLetter.tau };
  · simp +decide [ Set.encard ];
  · simp +decide [ closedWordCount_eq_filter ];
    refine' le_trans _ ( Finset.card_mono <| show { fun i => if i = 0 then GenLetter.sigma else GenLetter.sigmaInv, fun i => if i = 0 then GenLetter.sigmaInv else GenLetter.sigma, fun i => if i = 0 then GenLetter.tau else GenLetter.tauInv, fun i => if i = 0 then GenLetter.tauInv else GenLetter.tau } ⊆ Finset.filter ( fun w : Fin 2 → GenLetter => ( TwoGenCayleyData.evalLetter { sigma := σ, tau := τ } ( w 0 ) ) * ( TwoGenCayleyData.evalLetter { sigma := σ, tau := τ } ( w 1 ) ) = 1 ) Finset.univ from _ );
    · simp +decide [ funext_iff, Fin.forall_fin_two ];
    · simp +decide [ Finset.subset_iff, TwoGenCayleyData.evalLetter ]

/-! ## Monotonicity of the moment kernel -/

/-- The moment kernel at time 0 is exactly 1. -/
theorem momentKernel_zero' {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) : momentKernel σ τ 0 = 1 := by
  simp [momentKernel, closedWordCount_zero]

/-
**Backtrack-free words of length m (m ≥ 1)**: the number of words where
    no letter is immediately followed by its inverse is exactly 4 · 3^(m-1).
    This counts the tree-like (non-backtracking) random walks,
    the universal contribution to spectral moments.
-/
theorem card_backtrackFree_words
    (m : ℕ) (hm : 1 ≤ m) :
    (Finset.univ.filter fun w : Fin m → GenLetter =>
      BacktrackFree (List.ofFn w)).card = 4 * 3 ^ (m - 1) := by
  rcases m with ( _ | _ | m ) <;> simp_all +decide [ Nat.pow_succ', Finset.card_univ ];
  induction' m with m ih <;> simp_all +decide [ Nat.pow_succ', Finset.card_univ, Fintype.card_pi ];
  -- By definition of backtrack-free words, we can split the set into those words that start with a specific letter and those that do not.
  have h_split : Finset.filter (fun w : Fin (m + 3) → GenLetter => BacktrackFree (w 0 :: w 1 :: w 2 :: List.ofFn (fun i => w i.succ.succ.succ))) Finset.univ = Finset.biUnion (Finset.filter (fun w : Fin (m + 2) → GenLetter => BacktrackFree (w 0 :: w 1 :: List.ofFn (fun i => w i.succ.succ))) Finset.univ) (fun w => Finset.image (fun a : GenLetter => Fin.cons a w) (Finset.univ.filter (fun a : GenLetter => a ≠ (w 0).inv))) := by
    ext w; simp [BacktrackFree];
    constructor;
    · intro hw;
      use fun i => w i.succ;
      exact ⟨ ⟨ hw.2.1, hw.2.2 ⟩, w 0, by aesop_cat, by ext i; induction i using Fin.inductionOn <;> aesop_cat ⟩;
    · rintro ⟨ a, ⟨ ha₁, ha₂ ⟩, b, hb₁, rfl ⟩ ; simp_all +decide [ Fin.forall_fin_succ, BacktrackFree ] ;
      exact ⟨ by contrapose! hb₁; aesop, by simpa [ Fin.cons ] using ha₁, by simpa [ Fin.cons ] using ha₂ ⟩;
  rw [ h_split, Finset.card_biUnion ];
  · rw [ Finset.sum_congr rfl fun x hx => Finset.card_image_of_injective _ <| fun a b h => by simpa using congr_fun h 0 ] ; norm_num [ Finset.filter_ne', Finset.card_univ ] at * ; linarith;
  · intros w hw w' hw' hww';
    simp_all +decide [ Finset.disjoint_left, Function.onFun ];
    grind +extAll

/-! ## evalWord for singleton -/

theorem evalWord_singleton {G : Type*} [Group G] (σ τ : G) (a : GenLetter) :
    evalWord σ τ [a] = (TwoGenCayleyData.mk σ τ).evalLetter a := by
  simp [evalWord]

/-! ## Swap Invariance -/

/-
Swapping the two generators corresponds to a letter permutation,
    preserving the closed-word count.
-/
theorem closedWordCount_swap
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) :
    closedWordCount σ τ m = closedWordCount τ σ m := by
  -- By definition of `closedWordCount`, we have:
  unfold closedWordCount;
  -- Define the swap function on GenLetter.
  set swap : GenLetter → GenLetter := fun a => match a with
    | .sigma => .tau
    | .sigmaInv => .tauInv
    | .tau => .sigma
    | .tauInv => .sigmaInv;
  -- By definition of swap, we have `evalWord τ σ (List.map swap w) = evalWord σ τ w`.
  have h_swap_eval : ∀ w : List GenLetter, evalWord τ σ (List.map swap w) = evalWord σ τ w := by
    intro w;
    induction w <;> simp +decide [ *, List.map ];
    rename_i a w ih; rcases a with ( _ | _ | _ | _ ) <;> rfl;
  rw [ Fintype.card_subtype, Fintype.card_subtype ];
  refine' Finset.card_bij ( fun w hw => fun i => swap ( w i ) ) _ _ _ <;> simp +decide [ h_swap_eval ];
  · intro a ha; specialize h_swap_eval ( List.ofFn a ) ; simp_all +decide [ List.ofFn_eq_map ] ;
    exact h_swap_eval;
  · intro a₁ ha₁ a₂ ha₂ h; ext i; have := congr_fun h i; rcases a₁_i : a₁ i with ( _ | _ | _ | _ ) <;> rcases a₂_i : a₂ i with ( _ | _ | _ | _ ) <;> simp +decide [ a₁_i, a₂_i ] at this ⊢;
  · intro b hb;
    refine' ⟨ fun i => swap ( b i ), _, _ ⟩ <;> simp +decide [ ← h_swap_eval, hb ];
    · convert hb using 1;
      congr! 2;
      grind +qlia;
    · exact funext fun i => by rcases b i with ( _ | _ | _ | _ ) <;> rfl;

/-!
## Conjecture: Random Cayley Expander

**Falsifiable prediction**: For fixed k : ℕ, as n → ∞, for random
generating pairs (σ,τ) in S_n, the normalized 2k-th spectral moment

  (1/n!) · tr(A^{2k})

converges to the free-group return probability μ_{F₂}^{(2k)}(e).

For k=1: μ_{F₂}^{(2)}(e) = 1 (4 cancellation pairs / 4¹)
For k=2: μ_{F₂}^{(4)}(e) = 2/4 = 1/2

See `demo.py` for the computational verification.
-/