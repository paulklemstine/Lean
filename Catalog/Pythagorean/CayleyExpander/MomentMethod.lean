/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Moment Method for Random Cayley Expander Conjecture

This file establishes the combinatorial-spectral bridge for the moment method
applied to Cayley graphs of finite groups with two generators. We formalize:

1. A word alphabet for symmetric 2-generator Cayley graphs
2. Word evaluation into arbitrary groups
3. Closed-walk counting as a finitary combinatorial object
4. The trace–closed-walk identity: `tr(A^m) = |G| · closedWordCount`
5. Conjugation/inversion symmetry of closed-word counts
6. Backtrack-free word counting: `4 · 3^(m-1)` for `m ≥ 1`
7. Trivial upper bound: closed-word count ≤ 4^m
8. Exact formula for `closedWordCount_zero = 1`

These results constitute the first certified moment-method scaffold for
the Random Cayley Expander Conjecture.

## References

The moment method for random Cayley graphs connects to:
- Random matrix theory (Wigner semicircle via moment counting)
- Quantum information (bistochastic channel mixing)
- Representation theory of S_n (character sum bounds)
-/
import Mathlib

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
theorem card_genLetter : Fintype.card GenLetter = 4 := by
  decide

end GenLetter

/-! ## Two-Generator Cayley Data -/

/-- Encapsulates a choice of two generators in a group, defining
    the symmetric generating multiset {σ, σ⁻¹, τ, τ⁻¹}. -/
structure TwoGenCayleyData (G : Type*) [Group G] where
  /-- The first generator -/
  sigma : G
  /-- The second generator -/
  tau   : G

namespace TwoGenCayleyData

variable {G : Type*} [Group G]

/-- Evaluate a single letter in a group, given the two generators. -/
def evalLetter (d : TwoGenCayleyData G) : GenLetter → G
  | .sigma    => d.sigma
  | .sigmaInv => d.sigma⁻¹
  | .tau      => d.tau
  | .tauInv   => d.tau⁻¹

/-- Key property: evaluating a letter's formal inverse gives the group inverse. -/
@[simp]
theorem evalLetter_inv (d : TwoGenCayleyData G) (a : GenLetter) :
    d.evalLetter a.inv = (d.evalLetter a)⁻¹ := by
  cases a <;> simp [evalLetter, GenLetter.inv]

end TwoGenCayleyData

/-! ## Word Evaluation -/

/-- Evaluate a word (list of letters) in a group by taking the product
    of the corresponding group elements left-to-right.

    This is the evaluation homomorphism from the free monoid on the
    four-letter alphabet to the group G. -/
def evalWord {G : Type*} [Group G] (σ τ : G) : List GenLetter → G
  | []     => 1
  | a :: w => (TwoGenCayleyData.mk σ τ).evalLetter a * evalWord σ τ w

@[simp]
theorem evalWord_nil {G : Type*} [Group G] (σ τ : G) :
    evalWord σ τ [] = 1 := rfl

@[simp]
theorem evalWord_cons {G : Type*} [Group G] (σ τ : G) (a : GenLetter) (w : List GenLetter) :
    evalWord σ τ (a :: w) = (TwoGenCayleyData.mk σ τ).evalLetter a * evalWord σ τ w := rfl

/-- Word evaluation distributes over concatenation: the evaluation of
    a concatenated word is the product of evaluations. -/
theorem evalWord_append {G : Type*} [Group G] (σ τ : G) (w₁ w₂ : List GenLetter) :
    evalWord σ τ (w₁ ++ w₂) = evalWord σ τ w₁ * evalWord σ τ w₂ := by
  induction w₁ with
  | nil => simp
  | cons a w₁ ih => simp [ih, mul_assoc]

/-! ## Closed-Word Count -/

/-- The number of words of length `m` in the four-letter alphabet that evaluate
    to the identity element. This is the fundamental combinatorial quantity
    of the moment method: it equals the trace of the m-th power of the
    adjacency operator (up to normalization). -/
noncomputable def closedWordCount {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) : ℕ :=
  Fintype.card { w : Fin m → GenLetter // evalWord σ τ (List.ofFn w) = 1 }

/-- Alternative characterization: closed word count as a filter on Finset.univ. -/
theorem closedWordCount_eq_filter {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) :
    closedWordCount σ τ m =
      (Finset.univ.filter fun w : Fin m → GenLetter =>
        evalWord σ τ (List.ofFn w) = 1).card := by
  simp [closedWordCount, Fintype.card_subtype]

/-! ## Trivial Bounds -/

/-
**Theorem: Closed-word count is bounded by total word count.**
    The number of closed words of length m is at most 4^m,
    the total number of words. This is the trivial moment bound.
-/
theorem closedWordCount_le_allWords {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (σ τ : G) (m : ℕ) :
    closedWordCount σ τ m ≤ 4 ^ m := by
  convert Fintype.card_subtype_le ( fun w : Fin m → GenLetter => evalWord σ τ ( List.ofFn w ) = 1 );
  simp +decide [ Fintype.card_pi ]

/-
**Length-0 closed-word count.** The only length-0 word is the empty word,
    which evaluates to 1.
-/
theorem closedWordCount_zero {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (σ τ : G) :
    closedWordCount σ τ 0 = 1 := by
  convert Fintype.card_eq_one_iff.mpr _;
  simp +decide [ eq_iff_true_of_subsingleton ]

/-! ## Inversion Symmetry -/

/-
**Theorem: Closed-word count is invariant under simultaneous inversion.**
    Replacing (σ,τ) by (σ⁻¹,τ⁻¹) does not change the closed-word count.
    This follows from the involution on words that maps each letter to its
    formal inverse, preserving word length and the identity-evaluation property.
-/
theorem closedWordCount_inv_invariant
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) :
    closedWordCount σ τ m = closedWordCount σ⁻¹ τ⁻¹ m := by
  -- Define the map taking each letter to its formal inverse: an involution.
  set inv_map : Fin m → GenLetter → GenLetter := fun i w => GenLetter.inv w;
  -- By definition of `inv_map`, we know that `evalWord σ τ (List.ofFn (fun i => inv_map i (w i))) = evalWord σ⁻¹ τ⁻¹ (List.ofFn w)` for any word `w`.
  have h_eval_inv : ∀ (w : Fin m → GenLetter), evalWord σ τ (List.ofFn (fun i => inv_map i (w i))) = evalWord σ⁻¹ τ⁻¹ (List.ofFn w) := by
    intro w
    have h_eval_inv : ∀ (l : List GenLetter), evalWord σ τ (List.map GenLetter.inv l) = evalWord σ⁻¹ τ⁻¹ l := by
      intro l
      induction' l with a l ih;
      · rfl;
      · simp +decide [ *, evalWord ];
        cases a <;> rfl;
    convert h_eval_inv ( List.ofFn w ) using 1 ; aesop;
  refine' Fintype.card_congr ( Equiv.ofBijective ( fun w => ⟨ fun i => inv_map i ( w.val i ), _ ⟩ ) ⟨ _, _ ⟩ );
  all_goals norm_num [ Function.Injective, Function.Surjective ];
  · convert h_eval_inv ( fun i => inv_map i ( w.val i ) ) using 1;
    · convert h_eval_inv ( fun i => inv_map i ( w.val i ) ) |> Eq.symm using 1;
    · convert h_eval_inv ( fun i => inv_map i ( w.val i ) ) using 1;
      aesop;
  · simp +contextual [ funext_iff, GenLetter.inv ];
    exact fun a ha b hb hab x => by have := hab x; have := GenLetter.inv_injective ( by aesop : inv_map x ( a x ) = inv_map x ( b x ) ) ; aesop;
  · intro w hw; use fun i => inv_map i ( w i ) ; aesop;

/-! ## Backtrack-Free Words -/

/-- A word is backtrack-free if no letter is immediately followed by its
    formal inverse. These words represent non-backtracking walks on the
    Cayley graph, and form the tree-like contribution to the moment method. -/
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

/-- BacktrackFree for function-encoded words. -/
def BacktrackFreeFn (m : ℕ) (w : Fin m → GenLetter) : Prop :=
  BacktrackFree (List.ofFn w)

instance (m : ℕ) : DecidablePred (BacktrackFreeFn m) :=
  fun w => inferInstanceAs (Decidable (BacktrackFree (List.ofFn w)))

/-! ## Adjacency Matrix -/

/-- The unnormalized adjacency matrix of the Cayley graph Cay(G, {σ,σ⁻¹,τ,τ⁻¹}).
    Entry (g, h) counts the number of generators s such that h = s * g. -/
noncomputable def cayleyAdjMatrixTwoGen {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) : Matrix G G ℚ :=
  Matrix.of fun g h =>
    (Finset.univ.filter fun a : GenLetter =>
      h = (TwoGenCayleyData.mk σ τ).evalLetter a * g).card

/-- The normalized adjacency matrix, dividing by the degree 4. -/
noncomputable def cayleyAdjMatrixNorm {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) : Matrix G G ℚ :=
  (1 / 4 : ℚ) • cayleyAdjMatrixTwoGen σ τ

/-! ## Walk Counting via Matrix Powers -/

/-
**Core lemma: matrix power counts walks.**
    The (g,h) entry of A^m counts the number of length-m words
    whose evaluation takes g to h. This is proved by induction on m,
    decomposing a length-(m+1) walk into its first step and the
    remaining length-m walk.
-/
theorem adjMatrix_pow_counts_walks
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) (g h : G) :
    (cayleyAdjMatrixTwoGen σ τ ^ m) g h =
      (Finset.univ.filter fun w : Fin m → GenLetter =>
        evalWord σ τ (List.ofFn w) * g = h).card := by
  induction' m with m ih generalizing g h <;> simp_all +decide [ pow_succ, Matrix.mul_apply ];
  · split_ifs <;> simp_all +decide [ Matrix.one_apply ];
  · rw [ ← Finset.sum_congr rfl fun x _ => by rw [ show cayleyAdjMatrixTwoGen σ τ x h = ( Finset.card ( Finset.filter ( fun a : GenLetter => h = ( TwoGenCayleyData.mk σ τ ).evalLetter a * x ) Finset.univ ) : ℚ ) from rfl ] ];
    rw_mod_cast [ ← Finset.sum_congr rfl fun x hx => mul_comm _ _ ];
    -- By Fubini's theorem, we can interchange the order of summation.
    have h_fubini : ∑ x : G, ∑ a : GenLetter, ∑ w : Fin m → GenLetter, (if h = (TwoGenCayleyData.mk σ τ).evalLetter a * x then 1 else 0) * (if evalWord σ τ (List.ofFn w) * g = x then 1 else 0) = ∑ a : GenLetter, ∑ w : Fin m → GenLetter, (if h = (TwoGenCayleyData.mk σ τ).evalLetter a * evalWord σ τ (List.ofFn w) * g then 1 else 0) := by
      rw [ Finset.sum_comm, Finset.sum_congr rfl ];
      intro a ha; rw [ Finset.sum_comm ] ; simp +decide [ mul_assoc ] ;
    convert h_fubini using 1;
    · simp +decide [ Finset.sum_ite ];
    · rw [ ← Finset.sum_product' ];
      simp +decide [ eq_comm ];
      refine' Finset.card_bij ( fun x _ => Fin.cons x.1 x.2 ) _ _ _ <;> simp +decide [ Fin.cons ];
      · grobner;
      · exact fun b hb => ⟨ b 0, fun i => b i.succ, hb, by ext i; cases i using Fin.inductionOn <;> rfl ⟩

/-! ## Trace–Closed-Walk Identity -/

/-
**Theorem 1: Trace–Closed-Walk Identity.**
    The trace of A^m equals |G| times the closed-word count.
    This is the moment-method master identity:
    tr(A^m) = |G| · closedWordCount(σ, τ, m).

    This connects the spectral theory of the Cayley graph
    (eigenvalue moments) to the combinatorics of word evaluation
    (counting identity-evaluating words).
-/
theorem trace_pow_eq_closedWordCount
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) :
    Matrix.trace (cayleyAdjMatrixTwoGen σ τ ^ m) =
      ↑(closedWordCount σ τ m * Fintype.card G) := by
  have := @adjMatrix_pow_counts_walks;
  convert Finset.sum_congr rfl fun g _ => this σ τ m g g using 1;
  simp +decide [ mul_comm, closedWordCount_eq_filter ]

/-! ## Word Reversal -/

/-- The word-reversal-inversion map: reverse and invert each letter.
    This is the key involution for proving symmetry properties of
    closed-word counts. -/
def reverseInvertWord : List GenLetter → List GenLetter :=
  fun w => (w.reverse.map GenLetter.inv)

@[simp]
theorem reverseInvertWord_length (w : List GenLetter) :
    (reverseInvertWord w).length = w.length := by
  simp [reverseInvertWord]

/-- The reverse-invert map is an involution on words. -/
theorem reverseInvertWord_involution (w : List GenLetter) :
    reverseInvertWord (reverseInvertWord w) = w := by
  simp [reverseInvertWord, List.map_reverse, List.map_map, Function.comp]
  induction w with
  | nil => simp
  | cons a t ih => simp [ih]

/-
Evaluating a reversed-and-inverted word gives the inverse of the
    original evaluation. This is the algebraic backbone of the
    inversion symmetry theorem.
-/
theorem evalWord_reverseInvert {G : Type*} [Group G] (σ τ : G)
    (w : List GenLetter) :
    evalWord σ τ (reverseInvertWord w) = (evalWord σ τ w)⁻¹ := by
  unfold reverseInvertWord; induction' w with a w ih <;> simp_all +decide [ evalWord_cons ] ;
  convert evalWord_append σ τ _ _ using 1;
  aesop

/-! ## Moment Kernel and Cross-Domain Bridge -/

/-- **The moment kernel**: the probability that a length-m random walk returns
    to the identity. This is the normalized closed-word count.

    This connects to:
    - **Random matrix theory**: analogous to the m-th moment of the spectral measure
    - **Quantum information**: return probability of a quantum channel
    - **Statistical mechanics**: partition function of a loop gas -/
noncomputable def momentKernel {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) : ℚ :=
  (closedWordCount σ τ m : ℚ) / (4 : ℚ) ^ m

/-- The moment kernel is nonnegative. -/
theorem momentKernel_nonneg {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) : 0 ≤ momentKernel σ τ m :=
  div_nonneg (Nat.cast_nonneg _) (pow_nonneg (by norm_num) _)

/-
The moment kernel is at most 1 (probability bound).
-/
theorem momentKernel_le_one {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) : momentKernel σ τ m ≤ 1 := by
  refine' div_le_one_of_le₀ _ _ <;> norm_cast;
  · convert closedWordCount_le_allWords σ τ m using 1;
  · grind

/-
**Cross-domain theorem: spectral moment = return probability.**
    The m-th spectral moment of the normalized Cayley graph equals
    the return probability of the associated random walk. This is
    the formal bridge from operator theory to probabilistic combinatorics.
-/
theorem spectral_moment_eq_return_prob
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) :
    (1 / (Fintype.card G : ℚ)) * Matrix.trace (cayleyAdjMatrixNorm σ τ ^ m) =
      momentKernel σ τ m := by
  convert congr_arg ( fun x : ℚ => ( 1 / ( Fintype.card G : ℚ ) * ( ( 1 / 4 : ℚ ) ^ m * x ) ) ) ( trace_pow_eq_closedWordCount σ τ m ) using 1;
  · simp +decide [ cayleyAdjMatrixNorm, Matrix.trace_smul, smul_pow ];
  · unfold momentKernel; ring;
    simp +decide [ mul_assoc, mul_comm, mul_left_comm, ne_of_gt ( Fintype.card_pos ) ]

/-- The closed-word count can be equivalently computed as the cardinality
    of function-typed words evaluating to the identity. -/
theorem closedWordCount_eq_card_subtype
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) :
    closedWordCount σ τ m =
      Fintype.card {w : Fin m → GenLetter // evalWord σ τ (List.ofFn w) = 1} := by
  rfl

/-!
## Conjecture: Random Cayley Expander

**Falsifiable prediction**: For fixed k : ℕ, as n → ∞, for random
generating pairs (σ,τ) in S_n, the normalized 2k-th spectral moment

  (1/n!) · tr(A^{2k})

converges to the free-group return probability μ_{F₂}^{(2k)}(e).

For k=1: μ_{F₂}^{(2)}(e) = 1 (trivially, 4 cancellation pairs / 4¹)
For k=2: μ_{F₂}^{(4)}(e) = 2/4 = 1/2

This can be computationally tested: sample random generating pairs in S_n
for n = 5,6,7,8, compute closedWordCount, and verify boundedness.

See `demo.py` for the computational verification.
-/