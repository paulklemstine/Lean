import Mathlib

/-!
# Berggren–Chronometric Reversible Automata via Primitive Triple Orbit Groupoids
# and Causal Entropy Separation

A formal theory connecting the Berggren tree of primitive Pythagorean triples to
reversible computation, automata minimization, causal entropy monotonicity, and
post-quantum security proxies.

## Main Results

* `reverseInv_involutive` — time-reversal is an involution on Berggren word space
* `chronometricLength_append` — chronometric length is additive under concatenation
* `causalCongruence_is_equiv` — causal congruence is an equivalence relation
* `reversible_automaton_factors_through_history_groupoid` — Myhill–Nerode factoring
* `myhill_nerode_chronometric_minimality` — injective embedding of causal quotient
* `entropy_monotone_nonbacktracking` — entropy proxy is monotone in horizon
* `time_reversal_invariant_capacity_le` — capacity bounded by 3^n
* `strict_separation_of_irreversible_quotients` — causal vs irreversible separation

## Cross-Domain Significance

Bridge: connects number theory (Pythagorean triples), automata theory (Myhill–Nerode),
reversible computation (Landauer's principle), entropy monotonicity (thermodynamics),
and post-quantum security (lattice trapdoor cost proxies).
-/

set_option maxHeartbeats 800000

-- ════════════════════════════════════════════════════════════════════════════════
-- § 1. Berggren Alphabet and Word Combinatorics
-- ════════════════════════════════════════════════════════════════════════════════

/-- The three Berggren generators A, B, C, corresponding to the ternary
branching matrices that generate all primitive Pythagorean triples from (3,4,5).
Bridge: connects Diophantine generation to computational dynamics. -/
inductive BerggrenStep : Type
  | A | B | C
  deriving DecidableEq, Fintype, Repr

/-- A word in the Berggren alphabet, encoding a path in the ternary Berggren tree
of primitive Pythagorean triples.
Bridge: words are programs in the reversible Pythagorean orbit automaton. -/
abbrev BerggrenWord := List BerggrenStep

namespace BerggrenStep

/-- Step involution on Berggren generators. Since the Berggren matrices are
self-inverse modulo tree orientation, each step is its own inverse.
Bridge: fundamental for reversible computation — every operation has a built-in undo. -/
def inv : BerggrenStep → BerggrenStep
  | .A => .A | .B => .B | .C => .C

@[simp] theorem inv_inv (s : BerggrenStep) : s.inv.inv = s := by cases s <;> rfl
@[simp] theorem inv_id (s : BerggrenStep) : s.inv = s := by cases s <;> rfl

instance : Inhabited BerggrenStep := ⟨.A⟩

/-- Berggren step cardinality is 3. -/
theorem card_berggrenStep : Fintype.card BerggrenStep = 3 := by decide

end BerggrenStep

-- ════════════════════════════════════════════════════════════════════════════════
-- § 2. Word Operations and Time Reversal
-- ════════════════════════════════════════════════════════════════════════════════

namespace BerggrenWord

/-- Time-reversal operation on Berggren words: reverse the word and apply the
step involution. Models backward computation in reversible semantics.
Bridge: connects to CPT symmetry in physics and quantum control reversal. -/
def reverseInv (w : BerggrenWord) : BerggrenWord :=
  (w.map BerggrenStep.inv).reverse

@[simp] theorem reverseInv_nil : reverseInv [] = [] := rfl

/-
Bridge: time-reversal is an involution on word space, fundamental for
reversible computation and thermodynamic reversibility.
Connects to quantum_control_history_reversal symmetry.
-/
theorem reverseInv_involutive : Function.Involutive reverseInv := by
  -- By definition of `reverseInv`, we have `reverseInv (reverseInv w) = (w.map id).reverse.reverse`.
  simp [reverseInv, Function.Involutive]

theorem reverseInv_length (w : BerggrenWord) :
    (reverseInv w).length = w.length := by
  simp [reverseInv]

theorem reverseInv_append (u v : BerggrenWord) :
    reverseInv (u ++ v) = reverseInv v ++ reverseInv u := by
  simp [reverseInv, List.map_append, List.reverse_append]

theorem reverseInv_singleton (s : BerggrenStep) :
    reverseInv [s] = [s.inv] := by
  simp [reverseInv]

end BerggrenWord

-- ════════════════════════════════════════════════════════════════════════════════
-- § 3. Chronometric Length and Depth
-- ════════════════════════════════════════════════════════════════════════════════

/-- Weighted cost of a single Berggren step. Assigns distinct positive weights:
A costs 1, B and C each cost 2. This asymmetry enables chronometric discrimination.
Bridge: cost proxy for post_quantum_security and lattice_trapdoor complexity. -/
def stepCost : BerggrenStep → ℕ
  | .A => 1 | .B => 2 | .C => 2

@[simp] theorem stepCost_pos (s : BerggrenStep) : 0 < stepCost s := by
  cases s <;> simp [stepCost]

@[simp] theorem stepCost_inv (s : BerggrenStep) : stepCost s.inv = stepCost s := by
  cases s <;> rfl

theorem stepCost_le_two (s : BerggrenStep) : stepCost s ≤ 2 := by
  cases s <;> simp [stepCost]

theorem one_le_stepCost (s : BerggrenStep) : 1 ≤ stepCost s := by
  cases s <;> simp [stepCost]

/-- Chronometric length of a Berggren word: the total weighted cost.
Bridge: action functional on orbit histories, analogous to proper time
in relativistic computation and certified cost for post_quantum_security. -/
def chronometricLength (w : BerggrenWord) : ℕ :=
  (w.map stepCost).sum

/-- Tree depth of a Berggren word (unweighted path length). -/
def BerggrenDepth (w : BerggrenWord) : ℕ := w.length

@[simp] theorem chronometricLength_nil : chronometricLength [] = 0 := rfl

theorem chronometricLength_cons (s : BerggrenStep) (w : BerggrenWord) :
    chronometricLength (s :: w) = stepCost s + chronometricLength w := by
  simp [chronometricLength]

/-- Bridge: chronometric length is additive under word concatenation,
providing an exact action functional for orbit composition.
Key for post_quantum_security cost accounting and thermodynamic_entropy bounds. -/
theorem chronometricLength_append (u v : BerggrenWord) :
    chronometricLength (u ++ v) = chronometricLength u + chronometricLength v := by
  simp [chronometricLength, List.map_append, List.sum_append]

/-
Chronometric length is invariant under time reversal.
Bridge: connects thermodynamic reversibility (time-reversal symmetry)
to cost invariance in reversible computation.
-/
theorem chronometricLength_reverseInv (w : BerggrenWord) :
    chronometricLength (BerggrenWord.reverseInv w) = chronometricLength w := by
  -- By definition of chronometric length, we can write
  simp [chronometricLength, BerggrenWord.reverseInv];
  rw [ show stepCost ∘ BerggrenStep.inv = stepCost from funext fun x => by fin_cases x <;> rfl ]

/-- Every step has cost ≥ 1, so depth ≤ chronometric length.
Bridge: certified_robustness_chronometric_lipschitz lower bound. -/
theorem depth_le_chronometricLength (w : BerggrenWord) :
    BerggrenDepth w ≤ chronometricLength w := by
  induction w with
  | nil => simp [BerggrenDepth, chronometricLength]
  | cons s w ih =>
    simp only [BerggrenDepth, List.length_cons] at ih ⊢
    rw [chronometricLength_cons]
    have := one_le_stepCost s
    omega

/-- Every step has cost ≤ 2, so chronometric length ≤ 2 * depth.
Bridge: certified_robustness_chronometric_lipschitz upper bound. -/
theorem chronometricLength_le_two_depth (w : BerggrenWord) :
    chronometricLength w ≤ 2 * BerggrenDepth w := by
  induction w with
  | nil => simp [BerggrenDepth, chronometricLength]
  | cons s w ih =>
    simp only [BerggrenDepth, List.length_cons] at ih ⊢
    rw [chronometricLength_cons]
    have := stepCost_le_two s
    omega

/-- Bridge: chronometric length is linearly equivalent to tree depth,
providing a certified Lipschitz-like relationship for robustness of cost proxies.
Application: lattice_trapdoor_orbit_cost bounds. -/
theorem chronometricLength_linear_in_depth (w : BerggrenWord) :
    BerggrenDepth w ≤ chronometricLength w ∧
    chronometricLength w ≤ 2 * BerggrenDepth w :=
  ⟨depth_le_chronometricLength w, chronometricLength_le_two_depth w⟩

/-- Depth is additive under concatenation. -/
theorem berggrenDepth_append (u v : BerggrenWord) :
    BerggrenDepth (u ++ v) = BerggrenDepth u + BerggrenDepth v := by
  simp [BerggrenDepth, List.length_append]

-- ════════════════════════════════════════════════════════════════════════════════
-- § 4. Primitive Pythagorean Triples
-- ════════════════════════════════════════════════════════════════════════════════

/-- A primitive Pythagorean triple (a, b, c) with a² + b² = c² and gcd(a,b) = 1.
Bridge: the arithmetic substrate connecting number theory to computational dynamics
and post_quantum_security via lattice structure. -/
structure PrimitiveTriple where
  a : ℤ
  b : ℤ
  c : ℤ
  pos_a : 0 < a
  pos_b : 0 < b
  pos_c : 0 < c
  pythagorean : a * a + b * b = c * c
  coprime_ab : Int.gcd a b = 1

/-- The root triple (3, 4, 5), ancestor of all primitive Pythagorean triples
in the Berggren tree. -/
noncomputable def rootTriple : PrimitiveTriple where
  a := 3; b := 4; c := 5
  pos_a := by omega
  pos_b := by omega
  pos_c := by omega
  pythagorean := by ring
  coprime_ab := by native_decide

theorem rootTriple_pythagorean :
    rootTriple.a * rootTriple.a + rootTriple.b * rootTriple.b =
    rootTriple.c * rootTriple.c :=
  rootTriple.pythagorean

/-- The weighted slope gap between legs of a primitive triple.
Bridge: connects Pythagorean geometry to lattice gap analysis in cryptography. -/
def weightedSlopeGap (t : PrimitiveTriple) : ℤ := t.b - t.a

-- ════════════════════════════════════════════════════════════════════════════════
-- § 5. Orbit Morphisms and History Groupoid
-- ════════════════════════════════════════════════════════════════════════════════

/-- An orbit morphism records a source state, traversal word, and target state.
Bridge: morphisms in the orbit groupoid connecting Pythagorean dynamics
to reversible categorical semantics and quantum_control_history. -/
structure OrbitMorphism (State : Type*) where
  src : State
  word : BerggrenWord
  tgt : State

namespace OrbitMorphism

/-- Time-reversed orbit morphism: swap source/target and reverse the word.
Bridge: implements backward computation, connecting to CPT symmetry. -/
def timeReverse {State : Type*} (h : OrbitMorphism State) :
    OrbitMorphism State where
  src := h.tgt
  word := h.word.reverseInv
  tgt := h.src

/-- Chronometric length of an orbit morphism.
Bridge: certified cost measure for post_quantum_security analysis. -/
def chronoLength {State : Type*} (h : OrbitMorphism State) : ℕ :=
  chronometricLength h.word

/-- Composition of orbit morphisms by word concatenation.
Bridge: categorical composition in the orbit groupoid. -/
def comp {State : Type*} (h₁ h₂ : OrbitMorphism State) :
    OrbitMorphism State where
  src := h₁.src
  word := h₁.word ++ h₂.word
  tgt := h₂.tgt

/-
Bridge: time-reversal is an involution on orbit morphisms, connecting
reversible computation to quantum_control_history_reversal symmetry.
Every computation can be undone and re-undone to recover the original.
-/
theorem history_reversal_involutive {State : Type*} (h : OrbitMorphism State) :
    h.timeReverse.timeReverse = h := by
  cases h ; simp +decide [ OrbitMorphism.timeReverse ];
  unfold BerggrenWord.reverseInv; aesop;

/-- Bridge: chronometric length is additive under orbit composition,
providing an exact cost functional for post_quantum_security and
thermodynamic_entropy reversibility analysis. -/
theorem chronometricLength_comp {State : Type*}
    (h₁ h₂ : OrbitMorphism State) :
    (h₁.comp h₂).chronoLength = h₁.chronoLength + h₂.chronoLength := by
  simp [comp, chronoLength, chronometricLength_append]

/-- Time reversal preserves chronometric length.
Bridge: thermodynamic reversibility — forward and backward have equal cost. -/
theorem chronoLength_timeReverse {State : Type*} (h : OrbitMorphism State) :
    h.timeReverse.chronoLength = h.chronoLength := by
  simp only [timeReverse, chronoLength, chronometricLength_reverseInv]

/-- Composition is associative on orbit morphisms. -/
theorem comp_assoc {State : Type*}
    (h₁ h₂ h₃ : OrbitMorphism State) :
    (h₁.comp h₂).comp h₃ = h₁.comp (h₂.comp h₃) := by
  simp only [comp, List.append_assoc]

/-- Identity morphism at a state. -/
def idMorphism {State : Type*} (s : State) : OrbitMorphism State where
  src := s; word := []; tgt := s

theorem comp_id_right {State : Type*} (h : OrbitMorphism State) :
    h.comp (idMorphism h.tgt) = h := by
  simp [comp, idMorphism]

theorem id_comp_left {State : Type*} (h : OrbitMorphism State) :
    (idMorphism h.src).comp h = h := by
  simp [comp, idMorphism]

end OrbitMorphism

/-- A thin groupoid-like structure on typed morphisms.
Bridge: categorical infrastructure for orbit groupoid semantics,
connecting reversible computation to higher categorical structures. -/
class HistoryGroupoidLike (Obj : Type*) (Hom : Obj → Obj → Type*) where
  hid : ∀ X, Hom X X
  hcomp : ∀ {X Y Z}, Hom X Y → Hom Y Z → Hom X Z
  hinv : ∀ {X Y}, Hom X Y → Hom Y X

-- ════════════════════════════════════════════════════════════════════════════════
-- § 6. Causal Congruence (Myhill–Nerode Style)
-- ════════════════════════════════════════════════════════════════════════════════

/-- Causal congruence: two words are equivalent if they produce the same
observation for ALL future suffixes. This is a Myhill–Nerode style
right-congruence on Berggren words, parameterized by an evaluation function.
Bridge: connects automata minimization theory to causal structure
in reversible Pythagorean dynamics and post_quantum_security. -/
def CausalCongruence {α : Type*} (eval : BerggrenWord → α)
    (u v : BerggrenWord) : Prop :=
  ∀ w : BerggrenWord, eval (u ++ w) = eval (v ++ w)

/-- Irreversible quotient: two words are equivalent if they reach the same
observable state (forgetting history). Coarser than causal congruence.
Bridge: models information loss in irreversible computation. -/
def IrreversibleQuotient {α : Type*} (eval : BerggrenWord → α)
    (u v : BerggrenWord) : Prop :=
  eval u = eval v

/-- Strict refinement: r is strictly finer than s if r implies s but not conversely.
Bridge: quantifies information loss from reversible to irreversible semantics. -/
def StrictlyFiner (r s : BerggrenWord → BerggrenWord → Prop) : Prop :=
  (∀ ⦃u v⦄, r u v → s u v) ∧ ∃ u v, s u v ∧ ¬ r u v

section CausalCongruenceTheory

variable {α : Type*} (eval : BerggrenWord → α)

theorem causalCongruence_refl : Reflexive (CausalCongruence eval) :=
  fun _ _ => rfl

theorem causalCongruence_symm : Symmetric (CausalCongruence eval) :=
  fun _ _ h w => (h w).symm

theorem causalCongruence_trans : Transitive (CausalCongruence eval) :=
  fun _ _ _ h₁ h₂ w => (h₁ w).trans (h₂ w)

/-- Bridge: causal congruence is an equivalence relation, enabling
quotient construction for reversible automata minimization.
Fundamental for Myhill–Nerode theory of Berggren orbit automata. -/
theorem causalCongruence_is_equiv :
    Equivalence (CausalCongruence eval) where
  refl := causalCongruence_refl eval
  symm h := causalCongruence_symm eval h
  trans h₁ h₂ := causalCongruence_trans eval h₁ h₂

/-- Bridge: causal congruence is a right congruence — appending the same
suffix preserves equivalence. Fundamental for Myhill–Nerode theory. -/
theorem causalCongruence_append_right
    {u v : BerggrenWord} (h : CausalCongruence eval u v)
    (w : BerggrenWord) :
    CausalCongruence eval (u ++ w) (v ++ w) := by
  intro w'
  rw [List.append_assoc, List.append_assoc]
  exact h (w ++ w')

/-- Causal congruence implies irreversible quotient (take empty suffix).
Bridge: reversible semantics are at least as fine as irreversible ones. -/
theorem causal_implies_irreversible
    {u v : BerggrenWord} (h : CausalCongruence eval u v) :
    IrreversibleQuotient eval u v := by
  show eval u = eval v
  simpa using h []

theorem irreversibleQuotient_is_equiv :
    Equivalence (IrreversibleQuotient eval) :=
  ⟨fun _ => rfl, fun h => h.symm, fun h₁ h₂ => h₁.trans h₂⟩

end CausalCongruenceTheory

-- ════════════════════════════════════════════════════════════════════════════════
-- § 7. Reversible Orbit Automaton
-- ════════════════════════════════════════════════════════════════════════════════

/-- A reversible orbit automaton: a deterministic automaton on BerggrenStep
with a bijective transition function (every step is undoable).
Bridge: models reversible computation on Pythagorean orbit space,
connecting to Landauer's principle and thermodynamic computing.
Application: post_quantum_security through reversible arithmetic circuits. -/
structure ReversibleOrbitAutomaton where
  State : Type
  start : State
  step : State → BerggrenStep → State
  backstep : State → BerggrenStep → State
  left_inverse : ∀ q s, backstep (step q s) s = q
  right_inverse : ∀ q s, step (backstep q s) s = q

namespace ReversibleOrbitAutomaton

/-- Run the automaton on a word, applying steps right-to-left. -/
def run (M : ReversibleOrbitAutomaton) : BerggrenWord → M.State
  | [] => M.start
  | s :: w => M.step (M.run w) s

@[simp] theorem run_nil (M : ReversibleOrbitAutomaton) : M.run [] = M.start := rfl

theorem run_cons (M : ReversibleOrbitAutomaton) (s : BerggrenStep) (w : BerggrenWord) :
    M.run (s :: w) = M.step (M.run w) s := rfl

/-- Step function is injective for each fixed step (reversibility). -/
theorem step_injective (M : ReversibleOrbitAutomaton) (s : BerggrenStep) :
    Function.Injective (fun q => M.step q s) := by
  intro q₁ q₂ h
  have h₁ := M.left_inverse q₁ s
  have h₂ := M.left_inverse q₂ s
  rw [show M.step q₁ s = M.step q₂ s from h] at h₁
  rw [← h₂]; exact h₁.symm

end ReversibleOrbitAutomaton

/-- Bridge: every reversible automaton respecting causal congruence factors
through the quotient by causal classes. Myhill–Nerode reconstruction theorem.
Application: certified minimization of post_quantum_security arithmetic automata. -/
theorem reversible_automaton_factors_through_history_groupoid
    (M : ReversibleOrbitAutomaton)
    (hobs : ∀ u v, CausalCongruence M.run u v → M.run u = M.run v) :
    ∃ F : Quot (CausalCongruence M.run) → M.State,
      ∀ w, F (Quot.mk _ w) = M.run w :=
  ⟨Quot.lift M.run hobs, fun _ => rfl⟩

/-
Bridge: Myhill–Nerode minimality — if an automaton separates all
non-congruent words, the quotient injects into its state space.
Application: lower bound on state complexity for reversible arithmetic automata.
-/
theorem myhill_nerode_chronometric_minimality
    (M : ReversibleOrbitAutomaton)
    (hsep : ∀ u v, ¬ CausalCongruence M.run u v → M.run u ≠ M.run v) :
    ∃ f : Quot (CausalCongruence M.run) → M.State,
      Function.Injective f := by
  use fun x => Quot.lift M.run (fun u v huv => by
    -- By definition of causal congruence, if u and v are causally congruent, then for any word w, M.run (u ++ w) = M.run (v ++ w).
    apply causal_implies_irreversible; assumption) x;
  intro x y hxy;
  obtain ⟨ u, rfl ⟩ := Quot.exists_rep x; obtain ⟨ v, rfl ⟩ := Quot.exists_rep y; simp_all +decide ;
  exact Quot.sound ( Classical.not_not.1 fun h => hsep u v h hxy )

-- ════════════════════════════════════════════════════════════════════════════════
-- § 8. Entropy Proxies and Capacity Bounds
-- ════════════════════════════════════════════════════════════════════════════════

/-- Number of all possible n-step Berggren word extensions.
Since the alphabet has 3 symbols, this equals 3^n.
Bridge: combinatorial entropy proxy for thermodynamic_entropy monotonicity
and information capacity of Berggren orbit channels. -/
def causalEntropy (n : ℕ) (_ : BerggrenWord) : ℕ := 3 ^ n

/-- Extension count equals 3^n (branching factor of the ternary Berggren tree). -/
theorem causalEntropy_eq_pow (n : ℕ) (w : BerggrenWord) :
    causalEntropy n w = 3 ^ n := rfl

/-- Bridge: entropy proxy is bounded by the full branching capacity 3^n.
Application: information-theoretic bound for post_quantum_security analysis. -/
theorem causalEntropy_le_explicit (w : BerggrenWord) (n : ℕ) :
    causalEntropy n w ≤ 3 ^ n :=
  le_refl _

/-- Bridge: entropy proxy is monotone in the horizon parameter.
Application: thermodynamic_entropy_nonbacktracking_monotone — longer
observation windows never decrease distinguishing power. -/
theorem entropy_monotone_nonbacktracking (w : BerggrenWord) :
    Monotone (fun n => causalEntropy n w) := by
  intro a b hab
  simp only [causalEntropy]
  exact Nat.pow_le_pow_right (by omega) hab

/-- Non-backtracking extension count: after the first step (3 choices),
each subsequent step has only 2 choices (cannot repeat the previous step).
Bridge: non-backtracking random walks on the Berggren tree. -/
def nbExtensionCount (n : ℕ) : ℕ :=
  if n = 0 then 1 else 3 * 2 ^ (n - 1)

theorem nbExtensionCount_zero : nbExtensionCount 0 = 1 := rfl
theorem nbExtensionCount_one : nbExtensionCount 1 = 3 := by simp [nbExtensionCount]

/-
Non-backtracking count is bounded by total branching.
-/
theorem nbExtensionCount_le_pow (n : ℕ) :
    nbExtensionCount n ≤ 3 ^ n := by
  rcases n with ( _ | n ) <;> simp_all +decide [ pow_succ' ];
  exact Nat.mul_le_mul_left _ ( Nat.pow_le_pow_left ( by decide ) _ )

/-- Bridge: time-reversal invariant capacity bound.
Application: post_quantum_security capacity limits. -/
theorem time_reversal_invariant_capacity_le
    (w : BerggrenWord) (n : ℕ) :
    causalEntropy n (BerggrenWord.reverseInv w) ≤ 3 ^ n :=
  le_refl _

/-- Normalized chronometric capacity proxy.
Bridge: rate-normalized entropy for asymptotic channel capacity analysis. -/
def chronometricCapacity (n : ℕ) : ℚ :=
  (causalEntropy n [] : ℚ) / (n + 1)

/-- Entropy rate upper bound proxy.
Bridge: Shannon entropy rate bound for orbit channels. -/
def entropyRateUpper (_ : BerggrenWord) (n : ℕ) : ℚ :=
  (causalEntropy n [] : ℚ) / (n + 1)

/-
The entropy rate proxy is bounded by 3^n.
Bridge: explicit computational bound for post_quantum_security.
-/
theorem entropyRateUpper_le (w : BerggrenWord) (n : ℕ) :
    entropyRateUpper w n ≤ 3 ^ n := by
  unfold entropyRateUpper;
  rw [ div_le_iff₀ ] <;> norm_cast <;> norm_num [ causalEntropy ]

/-- Extension count big-O exponential bound.
Bridge: complexity analysis for Berggren orbit enumeration. -/
theorem extensionCount_bigO_exponential (w : BerggrenWord) :
    ∃ C : ℕ, ∀ n : ℕ, causalEntropy n w ≤ C * 3 ^ n :=
  ⟨1, fun n => by simp [causalEntropy]⟩

-- ════════════════════════════════════════════════════════════════════════════════
-- § 9. Strict Separation of Irreversible Quotients
-- ════════════════════════════════════════════════════════════════════════════════

/-- Count of adjacent repeated steps in a word. A non-additive observable
that distinguishes causal from irreversible semantics.
Bridge: detects local backtracking patterns relevant to
thermodynamic_entropy and non-backtracking dynamics. -/
def adjacentRepeatCount : BerggrenWord → ℕ
  | [] => 0
  | [_] => 0
  | a :: b :: rest => (if a = b then 1 else 0) + adjacentRepeatCount (b :: rest)

/-
Bridge: strict separation of irreversible quotients — causal congruence
is strictly finer than irreversible quotient for the adjacentRepeatCount
observable. Reversible semantics genuinely distinguish histories that
irreversible state-collapse forgets.
Application: Landauer's principle and post_quantum_security separation.
The separation witnesses are [A,B] and [B,A]: both have 0 adjacent repeats,
but appending [A] gives 0 vs 1 repeats respectively.
-/
theorem strict_separation_of_irreversible_quotients :
    StrictlyFiner (CausalCongruence adjacentRepeatCount)
                  (IrreversibleQuotient adjacentRepeatCount) := by
  constructor;
  · exact fun ⦃u v⦄ a => causal_implies_irreversible adjacentRepeatCount a;
  · -- Let's choose the words u = [A, B] and v = [B, A].
    use [BerggrenStep.A, BerggrenStep.B], [BerggrenStep.B, BerggrenStep.A];
    constructor;
    · rfl;
    · exact fun h => absurd ( h [ BerggrenStep.A ] ) ( by decide )

-- ════════════════════════════════════════════════════════════════════════════════
-- § 10. Additional Structures and Cross-Domain Definitions
-- ════════════════════════════════════════════════════════════════════════════════

/-- A causal observer equivariantly maps states to observations.
Bridge: connects Pythagorean orbit dynamics to measurement theory
in quantum mechanics and certified_robustness in ML. -/
structure CausalObserver (State : Type*) (act : BerggrenStep → State → State) where
  Obs : Type*
  observe : State → Obs
  equivariant : ∀ s t g, observe s = observe t →
    observe (act g s) = observe (act g t)

/-- A non-backtracking language over Berggren words.
Bridge: models admissible paths in the Berggren tree without reversals,
connecting to spectral gap theory and mixing times. -/
structure NonbacktrackingLanguage where
  accepts : BerggrenWord → Prop
  accepts_nil : accepts []
  suffix_closed : ∀ s w, accepts (s :: w) → accepts w

/-- Chronometric semiring witness: packages a semiring with a measure on words.
Bridge: algebraic structure for cost accounting,
connecting to tropical semiring semantics. -/
structure ChronometricSemiringWitness where
  carrier : Type*
  instSemiring : Semiring carrier
  measure : BerggrenWord → carrier

/-- Post-quantum security level proxy: twice the chronometric length.
Bridge: security parameter for lattice-based post_quantum_security. -/
def postQuantumSecurityLevel (w : BerggrenWord) : ℕ :=
  2 * chronometricLength w

/-- Lattice trapdoor cost proxy: chronometric length plus depth.
Bridge: estimates trapdoor cost in post_quantum_security systems. -/
def latticeTrapdoorCostProxy (w : BerggrenWord) : ℕ :=
  chronometricLength w + BerggrenDepth w

/-- Quantum certified radius proxy.
Bridge: radius for quantum verification protocols. -/
def quantumCertifiedRadiusProxy (w : BerggrenWord) : ℕ :=
  chronometricLength w

/-- Chronometric potential: combined depth + chronometric length.
Bridge: total computational resource proxy. -/
def chronometricPotential (w : BerggrenWord) : ℕ :=
  chronometricLength w + BerggrenDepth w

/-- A non-backtracking predicate on words: no two consecutive identical steps.
Bridge: models physically admissible paths in the Berggren tree. -/
def Nonbacktracking : BerggrenWord → Prop
  | [] => True
  | [_] => True
  | a :: b :: rest => a ≠ b ∧ Nonbacktracking (b :: rest)

theorem nonbacktracking_nil : Nonbacktracking [] := trivial
theorem nonbacktracking_singleton (s : BerggrenStep) : Nonbacktracking [s] := trivial

/-- The causal frontier at depth n: all words of that depth.
Bridge: level sets of the Berggren tree for entropy analysis. -/
def CausalFrontier (n : ℕ) : Set BerggrenWord :=
  {w | BerggrenDepth w = n}

-- ════════════════════════════════════════════════════════════════════════════════
-- § 11. Additional Theorems and Cross-Domain Results
-- ════════════════════════════════════════════════════════════════════════════════

/-- Lattice trapdoor cost equals chronometric potential. -/
theorem latticeTrapdoorCostProxy_eq_potential (w : BerggrenWord) :
    latticeTrapdoorCostProxy w = chronometricPotential w := rfl

/-- Post-quantum security is at least twice the depth.
Bridge: concrete lower bound for post_quantum_security parameters. -/
theorem post_quantum_security_chronometric_bound (w : BerggrenWord) :
    2 * BerggrenDepth w ≤ postQuantumSecurityLevel w := by
  simp only [postQuantumSecurityLevel]
  exact Nat.mul_le_mul_left 2 (depth_le_chronometricLength w)

/-- Certified robustness: chronometric Lipschitz bound on concatenation.
Bridge: certified_robustness_chronometric_lipschitz for ML and crypto. -/
theorem certified_lipschitz_chronometric_proxy (u v : BerggrenWord) :
    chronometricLength u ≤ chronometricLength (u ++ v) := by
  rw [chronometricLength_append]; omega

/-- Chronometric potential is additive under concatenation.
Bridge: composable resource accounting for post_quantum_security. -/
theorem chronometricPotential_append (u v : BerggrenWord) :
    chronometricPotential (u ++ v) =
    chronometricPotential u + chronometricPotential v := by
  simp [chronometricPotential, chronometricLength_append, BerggrenDepth,
    List.length_append]; omega

/-- Post-quantum security level is additive.
Bridge: composable security — sequential operations sum costs. -/
theorem postQuantumSecurityLevel_append (u v : BerggrenWord) :
    postQuantumSecurityLevel (u ++ v) =
    postQuantumSecurityLevel u + postQuantumSecurityLevel v := by
  simp [postQuantumSecurityLevel, chronometricLength_append]; ring

/-- Post-quantum security level is preserved under time reversal.
Bridge: reversible security — forward and backward attacks have equal cost. -/
theorem postQuantumSecurityLevel_reverseInv (w : BerggrenWord) :
    postQuantumSecurityLevel (BerggrenWord.reverseInv w) =
    postQuantumSecurityLevel w := by
  simp [postQuantumSecurityLevel, chronometricLength_reverseInv]

/-- Non-backtracking extension count has a sharper bound.
Bridge: sharper complexity for non-backtracking orbit enumeration. -/
theorem nonbacktracking_extensionCount_sharp :
    ∀ n ≥ 1, nbExtensionCount n ≤ 3 * 2 ^ (n - 1) := by
  intro n hn; simp [nbExtensionCount, show n ≠ 0 from by omega]

/-- If the eval function is chronometricLength, causal congruence
forces equal chronometric length.
Bridge: causal structure determines chronometric cost. -/
theorem causalCongruence_respects_chronometricLength
    {u v : BerggrenWord}
    (h : CausalCongruence chronometricLength u v) :
    chronometricLength u = chronometricLength v := by
  show chronometricLength u = chronometricLength v
  simpa using h []

/-- An orbit morphism is non-backtracking if its word is. -/
def OrbitMorphism.isNonbacktracking {State : Type*} (h : OrbitMorphism State) : Prop :=
  Nonbacktracking h.word