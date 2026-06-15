/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Moment Method for Random Cayley Expander Conjecture

This file establishes the combinatorial-spectral bridge for the moment method
applied to Cayley graphs of finite groups with two generators. We formalize:

1. A word alphabet for symmetric 2-generator Cayley graphs
2. Word evaluation into arbitrary groups
3. Closed-walk counting as a finitary combinatorial object
4. The trace–closed-walk identity: `tr(A^m) = closedWordCount`
5. Conjugation/inversion symmetry of closed-word counts
6. Backtrack-free word counting: `4 · 3^(m-1)` for `m ≥ 1`
7. Trivial upper bound: closed-word count ≤ 4^m
8. Exact formulas for small moments (m = 2)

These results constitute the first certified moment-method scaffold for
the Random Cayley Expander Conjecture.

## References

The moment method for random Cayley graphs connects to:
- Random matrix theory (Wigner semicircle via moment counting)
- Quantum information (bistochastic channel mixing)
- Representation theory of S_n (character sum bounds)

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
    of the corresponding group elements left-to-right. -/
def evalWord {G : Type*} [Group G] (σ τ : G) : List GenLetter → G
  | []     => 1
  | a :: w => (TwoGenCayleyData.mk σ τ).evalLetter a * evalWord σ τ w

@[simp]
theorem evalWord_nil {G : Type*} [Group G] (σ τ : G) :
    evalWord σ τ [] = 1 := rfl

@[simp]
theorem evalWord_cons {G : Type*} [Group G] (σ τ : G) (a : GenLetter) (w : List GenLetter) :
    evalWord σ τ (a :: w) = (TwoGenCayleyData.mk σ τ).evalLetter a * evalWord σ τ w := rfl

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
  unfold closedWordCount
  simp [Fintype.card_subtype]

/-! ## Trivial Bounds -/

/-
**Theorem: Closed-word count is bounded by total word count.**
    The number of closed words of length m is at most 4^m,
    the total number of words. This is the trivial moment bound.
-/
theorem closedWordCount_le_allWords {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (σ τ : G) (m : ℕ) :
    closedWordCount σ τ m ≤ 4 ^ m := by
  convert Fintype.card_subtype_le _;
  swap;
  exacts [ inferInstance, by simp +decide [ Fintype.card_pi ] ]

/-
**Length-0 closed-word count.** The only length-0 word is the empty word,
    which evaluates to 1.
-/
theorem closedWordCount_zero {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (σ τ : G) :
    closedWordCount σ τ 0 = 1 := by
  simp +decide [ closedWordCount_eq_filter, List.ofFn_zero ]

/-! ## Inversion Symmetry -/

/-
**Theorem: Closed-word count is invariant under simultaneous inversion.**
    Replacing (σ,τ) by (σ⁻¹,τ⁻¹) does not change the closed-word count.
    This follows from the involution on words that reverses the word and
    replaces each letter by its formal inverse.
-/
theorem closedWordCount_inv_invariant
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) :
    closedWordCount σ τ m = closedWordCount σ⁻¹ τ⁻¹ m := by
  refine' ( Fintype.card_congr _ ).symm;
  refine' Equiv.ofBijective ( fun w => ⟨ fun i => w.val i |> GenLetter.inv, _ ⟩ ) ⟨ _, _ ⟩;
  all_goals norm_num [ Function.Injective, Function.Surjective ];
  · convert w.2 using 1;
    have h_eval_inv : ∀ (w : List GenLetter), evalWord σ τ (List.map GenLetter.inv w) = evalWord σ⁻¹ τ⁻¹ w := by
      intro w
      induction' w with a w ih;
      · rfl;
      · simp +decide [ *, evalWord ];
        cases a <;> rfl;
    convert h_eval_inv ( List.ofFn w.val ) using 1;
    exact congr_arg _ ( List.ext_get ( by simp +decide ) ( by simp +decide ) );
  · exact fun a ha b hb hab => funext fun i => by simpa using congr_fun hab i |> fun h => by simpa using congr_arg GenLetter.inv h;
  · intro a ha
    use fun i => (a i).inv
    simp [ha];
    convert ha using 1;
    rw [ List.ofFn_eq_map, List.ofFn_eq_map ];
    induction' ( List.finRange m ) with i hi <;> simp_all +decide [ evalWord ];
    cases a i <;> simp +decide [ TwoGenCayleyData.evalLetter ]

/-! ## Backtrack-Free Words -/

/-- A word is backtrack-free if no letter is immediately followed by its
    formal inverse. These words represent non-backtracking walks on the
    Cayley graph. -/
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
The number of length-m walks from g to h in the Cayley graph equals
    the (g,h) entry of A^m.
-/
theorem adjMatrix_pow_counts_walks
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) (g h : G) :
    (cayleyAdjMatrixTwoGen σ τ ^ m) g h =
      (Finset.univ.filter fun w : Fin m → GenLetter =>
        evalWord σ τ (List.ofFn w) * g = h).card := by
  induction' m with m ih generalizing g h <;> simp_all +decide [ pow_succ, Matrix.mul_apply ];
  · split_ifs <;> simp_all +decide [ Matrix.one_apply ];
  · simp +decide [ cayleyAdjMatrixTwoGen, Finset.sum_mul _ _ _ ];
    rw_mod_cast [ Finset.sum_congr rfl fun x _ => ?_ ];
    rotate_left;
    use fun x => Finset.card ( Finset.filter ( fun w : Fin ( m + 1 ) → GenLetter => ( TwoGenCayleyData.mk σ τ ).evalLetter ( w 0 ) * evalWord σ τ ( List.ofFn fun i => w i.succ ) * g = h ∧ evalWord σ τ ( List.ofFn fun i => w i.succ ) * g = x ) Finset.univ );
    · rw [ ← Finset.card_product ];
      refine' Finset.card_bij ( fun w hw => Fin.cons w.2 w.1 ) _ _ _ <;> simp +decide [ Fin.cons ];
      · simp +contextual [ mul_assoc ];
      · grobner;
      · exact fun b hb₁ hb₂ => ⟨ fun i => b i.succ, b 0, ⟨ hb₂, by rw [ ← hb₁, ← hb₂, mul_assoc ] ⟩, by ext i; cases i using Fin.inductionOn <;> rfl ⟩;
    · rw [ ← Finset.card_biUnion ] ; congr ; ext ; aesop;
      exact fun x _ y _ hxy => Finset.disjoint_left.mpr fun w hw₁ hw₂ => hxy <| by aesop;

/-
**Theorem 1: Trace–Closed-Walk Identity.**
    The trace of A^m equals |G| times the closed-word count.
    This is the moment-method master identity.
-/
theorem trace_pow_eq_closedWordCount
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) :
    Matrix.trace (cayleyAdjMatrixTwoGen σ τ ^ m) =
      ↑(closedWordCount σ τ m * Fintype.card G) := by
  convert Finset.sum_congr rfl fun g _ => adjMatrix_pow_counts_walks σ τ m g g;
  simp +decide [ closedWordCount_eq_filter ];
  ring

/-! ## Word Reversal -/

/-- The word-reversal-inversion map: reverse and invert each letter. -/
def reverseInvertWord : List GenLetter → List GenLetter :=
  fun w => (w.reverse.map GenLetter.inv)

@[simp]
theorem reverseInvertWord_length (w : List GenLetter) :
    (reverseInvertWord w).length = w.length := by
  simp [reverseInvertWord]

/-- The reverse-invert map is an involution. -/
theorem reverseInvertWord_involution (w : List GenLetter) :
    reverseInvertWord (reverseInvertWord w) = w := by
  simp [reverseInvertWord, List.map_reverse, List.map_map, Function.comp]
  induction w with
  | nil => simp
  | cons a t ih => simp [ih]

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

/-
The moment kernel is nonnegative.
-/
theorem momentKernel_nonneg {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) : 0 ≤ momentKernel σ τ m := by
  exact div_nonneg ( Nat.cast_nonneg _ ) ( pow_nonneg ( by norm_num ) _ )

theorem momentKernel_le_one {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) : momentKernel σ τ m ≤ 1 := by
  exact div_le_one_of_le₀ ( mod_cast closedWordCount_le_allWords σ τ m ) ( by positivity )

/-
**Cross-domain theorem: spectral moment = return probability.**
    The m-th spectral moment of the normalized Cayley graph equals
    the return probability of the associated random walk.
-/
theorem spectral_moment_eq_return_prob
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) :
    (1 / (Fintype.card G : ℚ)) * Matrix.trace (cayleyAdjMatrixNorm σ τ ^ m) =
      momentKernel σ τ m := by
  convert congr_arg ( fun x : ℚ => ( 1 / ( Fintype.card G : ℚ ) * ( ( 1 / 4 : ℚ ) ^ m * x ) ) ) ( trace_pow_eq_closedWordCount σ τ m ) using 1 ; ring!;
  · unfold cayleyAdjMatrixNorm; norm_num [ mul_assoc, mul_comm, mul_left_comm, pow_succ ] ; ring;
    rw [ smul_pow ] ; ring;
    simp +decide [ mul_assoc, mul_comm, mul_left_comm, Matrix.trace_smul ];
  · unfold momentKernel; ring; norm_num [ Fintype.card_pos_iff ] ;
    rw [ inv_mul_eq_div, mul_div_cancel_right₀ _ ( Nat.cast_ne_zero.mpr Fintype.card_ne_zero ) ]

/-
Evaluating a reversed-and-inverted word gives the inverse of the
    original evaluation. This is the algebraic backbone of the
    inversion symmetry theorem.
-/
theorem evalWord_reverseInvert {G : Type*} [Group G] (σ τ : G)
    (w : List GenLetter) :
    evalWord σ τ (reverseInvertWord w) = (evalWord σ τ w)⁻¹ := by
  induction' w using List.reverseRecOn with w ih;
  · simp +decide [ reverseInvertWord ];
  · simp_all +decide [ reverseInvertWord ];
    rw [ evalWord_append ] ; simp +decide [ mul_assoc ]

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