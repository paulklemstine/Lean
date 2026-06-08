/-
# Depth Rigidity of Recursive Ternary Majority

This file formalizes the recursive ternary majority function and proves
depth rigidity theorems: the monotone formula depth (and hence circuit depth)
of recursive majority is tightly bounded by the recursion depth.

## Main Results

1. `recMaj_monotone`: Recursive majority is a monotone Boolean function.
2. `recMajFormula_depth_eq`: The canonical monotone formula has depth exactly `3n`.
3. `recMajFormula_eval_correct`: The canonical formula computes `recMaj` correctly.
4. `varSet_card_le_two_pow_depth`: A binary formula of depth `d` has ≤ `2^d` leaves.
5. `recMaj_depends_on_var`: Each of the `3^n` input variables is pivotal.
6. `recMaj_formula_depth_lower`: Any formula computing `recMaj n` has depth ≥ `n`.
7. `recMaj_circuit_depth_lower`: Transfer to monotone circuits via unfolding.

## Architecture

Uses the catalog's proof pattern: formula lower bounds transfer to circuit
lower bounds through DAG unfolding. The key insight is that recursive majority
has a self-similar structure that forces linear depth in any monotone computation.

## Catalog References

- `Pythagorean/MonotoneCircuitComplexity.lean`: Theorems 2, 4 (depth transfer)
- `Pythagorean/DagDepthHierarchy/Theorems.lean`: DAG rigidity pattern for EML
-/
import Mathlib

/-! ## Monotone Boolean Formula (from catalog) -/

/-- A monotone Boolean formula (tree) with variables indexed by ℕ.
    Only AND and OR connectives are allowed (no negation). -/
inductive MBoolFormula where
  | var (n : ℕ)
  | and (l r : MBoolFormula)
  | or (l r : MBoolFormula)
  deriving Inhabited

namespace MBoolFormula

/-- Evaluate a monotone formula under a Boolean assignment. -/
def eval : MBoolFormula → (ℕ → Bool) → Bool
  | var n, σ => σ n
  | and l r, σ => l.eval σ && r.eval σ
  | or l r, σ => l.eval σ || r.eval σ

/-- Depth of a monotone formula (longest root-to-leaf path). -/
def depth : MBoolFormula → ℕ
  | var _ => 0
  | and l r => 1 + max l.depth r.depth
  | or l r => 1 + max l.depth r.depth

/-- The set of variable indices appearing in a formula. -/
def varSet : MBoolFormula → Finset ℕ
  | .var n => {n}
  | .and l r => l.varSet ∪ r.varSet
  | .or l r => l.varSet ∪ r.varSet

/-
A formula of depth `d` has at most `2^d` distinct variable occurrences.
-/
theorem varSet_card_le_two_pow_depth (F : MBoolFormula) :
    F.varSet.card ≤ 2 ^ F.depth := by
  induction' F using MBoolFormula.recOn with n F1 F2 ih1 ih2;
  · simp [varSet, depth];
  · refine' le_trans ( Finset.card_union_le _ _ ) _;
    rw [ show ( F1.and F2 ).depth = 1 + Max.max F1.depth F2.depth by rfl ];
    cases max_cases F1.depth F2.depth <;> simp_all +decide [ pow_add ];
    · linarith [ pow_le_pow_right₀ ( by decide : 1 ≤ 2 ) ‹_› ];
    · linarith [ pow_le_pow_right₀ ( by decide : 1 ≤ 2 ) ( by linarith : F1.depth ≤ F2.depth ) ];
  · rename_i l r hl hr;
    -- The cardinality of the union of two sets is at most the sum of their cardinalities.
    have h_union : (l.varSet ∪ r.varSet).card ≤ l.varSet.card + r.varSet.card := by
      exact Finset.card_union_le _ _;
    exact le_trans h_union ( by erw [ show ( l.or r ).depth = 1 + Max.max l.depth r.depth by rfl ] ; rw [ pow_add ] ; norm_num ; cases max_cases l.depth r.depth <;> cases max_cases ( 2 ^ l.depth ) ( 2 ^ r.depth ) <;> linarith [ pow_pos ( zero_lt_two' ℕ ) l.depth, pow_pos ( zero_lt_two' ℕ ) r.depth, pow_le_pow_right₀ ( show 1 ≤ 2 by decide ) ( show l.depth ≤ Max.max l.depth r.depth by exact le_max_left _ _ ), pow_le_pow_right₀ ( show 1 ≤ 2 by decide ) ( show r.depth ≤ Max.max l.depth r.depth by exact le_max_right _ _ ) ] )

/-
If variable `i` does not appear in `F`, then `F.eval` is independent of `σ i`.
-/
theorem eval_indep_of_not_mem_varSet (F : MBoolFormula) (i : ℕ)
    (σ : ℕ → Bool) (b : Bool) (hni : i ∉ F.varSet) :
    F.eval (Function.update σ i b) = F.eval σ := by
  induction' F with l r hl hr generalizing σ;
  · cases eq_or_ne i l <;> simp_all +decide [ MBoolFormula.varSet, MBoolFormula.eval ];
    rw [ Function.update_of_ne ( Ne.symm ‹_› ) ];
  · simp_all +decide [ Finset.mem_union, MBoolFormula.varSet ];
    convert congr_arg₂ ( · && · ) ( hr σ ) ( ‹∀ σ : ℕ → Bool, hl.eval ( Function.update σ i b ) = hl.eval σ› σ ) using 1;
  · simp_all +decide [ Finset.mem_union, MBoolFormula.varSet ];
    simp_all +decide [ MBoolFormula.eval ]

/-
Monotone formulas compute monotone functions.
-/
theorem eval_mono (F : MBoolFormula) {σ τ : ℕ → Bool}
    (h : ∀ n, σ n = true → τ n = true) :
    F.eval σ = true → F.eval τ = true := by
  induction F <;> simp_all +decide [ MBoolFormula.eval ];
  bv_decide

end MBoolFormula

/-! ## Monotone Boolean Circuit (from catalog) -/

/-- Specification of a node in a monotone Boolean circuit. -/
inductive MBoolNodeSpec where
  | input (var : ℕ)
  | andGate (left right : ℕ)
  | orGate (left right : ℕ)
  deriving Inhabited

/-- Child indices referenced by a node specification. -/
def MBoolNodeSpec.children : MBoolNodeSpec → List ℕ
  | .input _ => []
  | .andGate l r => [l, r]
  | .orGate l r => [l, r]

/-- A monotone Boolean circuit (DAG). -/
structure MBoolCircuit where
  size : ℕ
  spec : Fin size → MBoolNodeSpec
  wf : ∀ (i : Fin size) (c : ℕ), c ∈ (spec i).children → c < i.val

namespace MBoolCircuit

/-- Evaluate the circuit at vertex index `k`. -/
def evalNode (C : MBoolCircuit) (σ : ℕ → Bool) (k : ℕ) (hk : k < C.size) : Bool :=
  match h : C.spec ⟨k, hk⟩ with
  | .input v => σ v
  | .andGate l r =>
    have hl : l < k := C.wf ⟨k, hk⟩ l (by simp [MBoolNodeSpec.children, h])
    have hr : r < k := C.wf ⟨k, hk⟩ r (by simp [MBoolNodeSpec.children, h])
    C.evalNode σ l (by omega) && C.evalNode σ r (by omega)
  | .orGate l r =>
    have hl : l < k := C.wf ⟨k, hk⟩ l (by simp [MBoolNodeSpec.children, h])
    have hr : r < k := C.wf ⟨k, hk⟩ r (by simp [MBoolNodeSpec.children, h])
    C.evalNode σ l (by omega) || C.evalNode σ r (by omega)
  termination_by k

def eval (C : MBoolCircuit) (σ : ℕ → Bool) (v : Fin C.size) : Bool :=
  C.evalNode σ v.val v.isLt

/-- DAG depth at vertex `k`. -/
def nodeDepth (C : MBoolCircuit) (k : ℕ) (hk : k < C.size) : ℕ :=
  match h : C.spec ⟨k, hk⟩ with
  | .input _ => 0
  | .andGate l r =>
    have hl : l < k := C.wf ⟨k, hk⟩ l (by simp [MBoolNodeSpec.children, h])
    have hr : r < k := C.wf ⟨k, hk⟩ r (by simp [MBoolNodeSpec.children, h])
    1 + max (C.nodeDepth l (by omega)) (C.nodeDepth r (by omega))
  | .orGate l r =>
    have hl : l < k := C.wf ⟨k, hk⟩ l (by simp [MBoolNodeSpec.children, h])
    have hr : r < k := C.wf ⟨k, hk⟩ r (by simp [MBoolNodeSpec.children, h])
    1 + max (C.nodeDepth l (by omega)) (C.nodeDepth r (by omega))
  termination_by k

def dagDepth (C : MBoolCircuit) (v : Fin C.size) : ℕ :=
  C.nodeDepth v.val v.isLt

/-- Unfold the circuit at vertex `k` into a formula. -/
def unfoldNode (C : MBoolCircuit) (k : ℕ) (hk : k < C.size) : MBoolFormula :=
  match h : C.spec ⟨k, hk⟩ with
  | .input v => .var v
  | .andGate l r =>
    have hl : l < k := C.wf ⟨k, hk⟩ l (by simp [MBoolNodeSpec.children, h])
    have hr : r < k := C.wf ⟨k, hk⟩ r (by simp [MBoolNodeSpec.children, h])
    .and (C.unfoldNode l (by omega)) (C.unfoldNode r (by omega))
  | .orGate l r =>
    have hl : l < k := C.wf ⟨k, hk⟩ l (by simp [MBoolNodeSpec.children, h])
    have hr : r < k := C.wf ⟨k, hk⟩ r (by simp [MBoolNodeSpec.children, h])
    .or (C.unfoldNode l (by omega)) (C.unfoldNode r (by omega))
  termination_by k

def unfold (C : MBoolCircuit) (v : Fin C.size) : MBoolFormula :=
  C.unfoldNode v.val v.isLt

/-- Unfolding preserves semantics (Catalog Theorem 1). -/
theorem unfold_eval_eq (C : MBoolCircuit) (σ : ℕ → Bool) (k : ℕ) (hk : k < C.size) :
    (C.unfoldNode k hk).eval σ = C.evalNode σ k hk := by
  induction k using Nat.strongRecOn with
  | _ k ih =>
    unfold MBoolCircuit.unfoldNode MBoolCircuit.evalNode
    split
    · simp [MBoolFormula.eval]
    · next l r h =>
      simp only [MBoolFormula.eval]
      congr 1
      · exact ih l (C.wf ⟨k, hk⟩ l (by simp [MBoolNodeSpec.children, h])) _
      · exact ih r (C.wf ⟨k, hk⟩ r (by simp [MBoolNodeSpec.children, h])) _
    · next l r h =>
      simp only [MBoolFormula.eval]
      congr 1
      · exact ih l (C.wf ⟨k, hk⟩ l (by simp [MBoolNodeSpec.children, h])) _
      · exact ih r (C.wf ⟨k, hk⟩ r (by simp [MBoolNodeSpec.children, h])) _

/-- Unfolding preserves depth (Catalog Theorem 2). -/
theorem unfold_depth_eq (C : MBoolCircuit) (k : ℕ) (hk : k < C.size) :
    (C.unfoldNode k hk).depth = C.nodeDepth k hk := by
  induction k using Nat.strongRecOn with
  | _ k ih =>
    unfold MBoolCircuit.unfoldNode MBoolCircuit.nodeDepth
    split
    · simp [MBoolFormula.depth]
    · next l r h =>
      simp only [MBoolFormula.depth]
      congr 1; congr 1
      · exact ih l (C.wf ⟨k, hk⟩ l (by simp [MBoolNodeSpec.children, h])) _
      · exact ih r (C.wf ⟨k, hk⟩ r (by simp [MBoolNodeSpec.children, h])) _
    · next l r h =>
      simp only [MBoolFormula.depth]
      congr 1; congr 1
      · exact ih l (C.wf ⟨k, hk⟩ l (by simp [MBoolNodeSpec.children, h])) _
      · exact ih r (C.wf ⟨k, hk⟩ r (by simp [MBoolNodeSpec.children, h])) _

/-
**Transfer Theorem** (Catalog Theorem 4): Formula lower bounds transfer
    to circuit lower bounds through unfolding.
-/
theorem circuit_depth_lb_of_formula_depth_lb
    (C : MBoolCircuit) (v : Fin C.size) (d : ℕ)
    (hlb : ∀ F : MBoolFormula, (∀ σ, F.eval σ = C.eval σ v) → d ≤ F.depth) :
    d ≤ C.dagDepth v := by
  contrapose! hlb;
  exact ⟨ C.unfold v, fun σ => C.unfold_eval_eq σ v.val v.isLt, lt_of_le_of_lt ( C.unfold_depth_eq v.val v.isLt |> le_of_eq ) hlb ⟩

end MBoolCircuit

/-! ## Core Definitions: Recursive Majority -/

namespace RecursiveMajority

/-- Ternary majority gate: returns `true` iff at least 2 of 3 inputs are `true`. -/
def maj3 (a b c : Bool) : Bool := (a && b) || (a && c) || (b && c)

/-- Recursive ternary majority on `3^n` inputs (indexed by `ℕ`).
    - Level 0: returns `σ 0`.
    - Level `n+1`: applies `maj3` to three recursive sub-instances
      on consecutive blocks of size `3^n`. -/
def recMaj : ℕ → (ℕ → Bool) → Bool
  | 0 => fun σ => σ 0
  | n + 1 => fun σ => maj3
      (recMaj n σ)
      (recMaj n (fun j => σ (3 ^ n + j)))
      (recMaj n (fun j => σ (2 * 3 ^ n + j)))

/-- Profile structure encoding the recursive majority configuration.
    A new formal notion capturing the self-similar structure. -/
structure RecursiveMajorityProfile where
  /-- Recursion depth / number of majority layers. -/
  level : ℕ
  /-- Number of input variables: `3^level`. -/
  inputCount : ℕ := 3 ^ level
  /-- Depth of the canonical binary AND/OR formula: `3 * level`. -/
  canonicalFormulaDepth : ℕ := 3 * level

/-! ## Properties of `maj3` -/

/-
`maj3` is monotone in all three arguments.
-/
theorem maj3_monotone {a₁ b₁ c₁ a₂ b₂ c₂ : Bool}
    (ha : a₁ = true → a₂ = true)
    (hb : b₁ = true → b₂ = true)
    (hc : c₁ = true → c₂ = true) :
    maj3 a₁ b₁ c₁ = true → maj3 a₂ b₂ c₂ = true := by
  cases a₁ <;> cases b₁ <;> cases c₁ <;> cases a₂ <;> cases b₂ <;> cases c₂ <;> simp_all +decide only

/-
`maj3` is symmetric in the first two arguments.
-/
theorem maj3_swap12 (a b c : Bool) : maj3 a b c = maj3 b a c := by
  decide +revert

/-! ## Theorem 1: Monotonicity of `recMaj` -/

/-
**Theorem 1** (Monotonicity): `recMaj n` is monotone.
    Proof by induction on `n`, using monotonicity of `maj3` at each level.
-/
theorem recMaj_monotone (n : ℕ) {σ τ : ℕ → Bool}
    (h : ∀ i, σ i = true → τ i = true) :
    recMaj n σ = true → recMaj n τ = true := by
  induction' n with n ih generalizing σ τ;
  · exact fun h' => h 0 h';
  · -- Apply the monotonicity of `maj3` to each argument.
    have h_maj3 : ∀ (a₁ b₁ c₁ a₂ b₂ c₂ : Bool), (a₁ = true → a₂ = true) → (b₁ = true → b₂ = true) → (c₁ = true → c₂ = true) → (maj3 a₁ b₁ c₁ = true → maj3 a₂ b₂ c₂ = true) := by
      decide +revert;
    exact h_maj3 _ _ _ _ _ _ ( ih fun i hi => h i hi ) ( ih fun i hi => h ( 3 ^ n + i ) hi ) ( ih fun i hi => h ( 2 * 3 ^ n + i ) hi )

/-! ## Evaluation on Constant Inputs -/

theorem recMaj_all_true (n : ℕ) : recMaj n (fun _ => true) = true := by
  induction' n with n ih;
  · rfl;
  · simp +decide [ recMaj, ih ]

theorem recMaj_all_false (n : ℕ) : recMaj n (fun _ => false) = false := by
  induction' n with d hd <;> simp_all +decide [ recMaj, maj3 ]

/-! ## Theorem 2: Canonical Formula Construction and Exact Depth -/

/-- Build the canonical monotone formula for `recMaj n`.
    Variables are indexed from `off` through `off + 3^n - 1`.
    `maj3(a,b,c)` is encoded as `(a ∧ b) ∨ ((a ∧ c) ∨ (b ∧ c))`. -/
def recMajFormula : ℕ → ℕ → MBoolFormula
  | 0, off => .var off
  | n + 1, off =>
    let a := recMajFormula n off
    let b := recMajFormula n (off + 3 ^ n)
    let c := recMajFormula n (off + 2 * 3 ^ n)
    .or (.and a b) (.or (.and a c) (.and b c))

/-
**Theorem 2a** (Correctness): The canonical formula evaluates to the
    same result as `recMaj n` with inputs shifted by `off`.
-/
theorem recMajFormula_eval_correct (n : ℕ) (off : ℕ) (σ : ℕ → Bool) :
    (recMajFormula n off).eval σ = recMaj n (fun j => σ (off + j)) := by
  induction' n with n ih generalizing off;
  · rfl;
  · convert congr_arg₂ ( · || · ) ( congr_arg₂ ( · && · ) ( ih off ) ( ih ( off + 3 ^ n ) ) ) ( congr_arg₂ ( · || · ) ( congr_arg₂ ( · && · ) ( ih off ) ( ih ( off + 2 * 3 ^ n ) ) ) ( congr_arg₂ ( · && · ) ( ih ( off + 3 ^ n ) ) ( ih ( off + 2 * 3 ^ n ) ) ) ) using 1;
    -- By definition of `recMaj`, we have:
    simp [RecursiveMajority.recMaj];
    simp +decide only [maj3, add_assoc];
    grind

/-
Corollary: at offset 0, the formula computes `recMaj n` exactly.
-/
theorem recMajFormula_eval_zero (n : ℕ) (σ : ℕ → Bool) :
    (recMajFormula n 0).eval σ = recMaj n σ := by
  convert recMajFormula_eval_correct n 0 σ using 1;
  norm_num

/-
**Theorem 2b** (Exact Depth): The canonical formula has depth exactly `3 * n`.
-/
theorem recMajFormula_depth_eq (n : ℕ) (off : ℕ) :
    (recMajFormula n off).depth = 3 * n := by
  induction' n with n ih generalizing off;
  · rfl;
  · simp +arith +decide [ recMajFormula, ih ];
    simp +arith +decide [ MBoolFormula.depth, ih ]

/-! ## Theorem 3: Formula Depth Lower Bound via Variable Counting -/

/-- `maj3` acts as identity on the first argument when the second is `true`
    and the third is `false`. -/
theorem maj3_id_true_false (x : Bool) : maj3 x true false = x := by
  cases x <;> decide

/-
`recMaj n` only depends on the first `3^n` inputs.
-/
theorem recMaj_eq_of_agree (n : ℕ) (σ τ : ℕ → Bool)
    (h : ∀ j, j < 3 ^ n → σ j = τ j) :
    recMaj n σ = recMaj n τ := by
  induction' n with n ih generalizing σ τ <;> simp_all +decide [ recMaj ];
  congr! 1;
  · exact ih σ τ fun j hj => h j ( lt_of_lt_of_le hj ( Nat.pow_le_pow_right ( by decide ) ( Nat.le_succ _ ) ) );
  · exact ih _ _ fun j hj => h _ ( by rw [ pow_succ' ] ; linarith );
  · exact ih _ _ fun j hj => h _ ( by rw [ pow_succ' ] ; linarith )

/-
`recMaj n` depends on variable `i` for each `i < 3^n`:
    flipping `σ i` can change the output.
-/
theorem recMaj_depends_on_var (n : ℕ) (i : ℕ) (hi : i < 3 ^ n) :
    ∃ σ : ℕ → Bool,
      recMaj n σ ≠ recMaj n (Function.update σ i (!σ i)) := by
  induction' n with n ih generalizing i <;> simp_all +decide [ pow_succ' ];
  · exists fun _ => Bool.true;
  · -- Consider three cases: $i < 3^n$, $3^n \leq i < 2 \cdot 3^n$, and $2 \cdot 3^n \leq i < 3 \cdot 3^n$.
    by_cases h_case : i < 3 ^ n ∨ 3 ^ n ≤ i ∧ i < 2 * 3 ^ n ∨ 2 * 3 ^ n ≤ i ∧ i < 3 * 3 ^ n;
    · rcases h_case with ( h | h | h );
      · obtain ⟨ σ, hσ ⟩ := ih i h;
        use fun j => if j < 3 ^ n then σ j else if j < 2 * 3 ^ n then true else false;
        simp +decide [ recMaj, hσ ];
        -- By definition of `recMaj`, we can split the evaluation into the three blocks.
        have h_split : recMaj n (fun j => if j < 3 ^ n then σ j else decide (j < 2 * 3 ^ n)) = recMaj n σ ∧ recMaj n (fun j => decide (3 ^ n + j < 2 * 3 ^ n)) = true ∧ recMaj n (fun j => decide (2 * 3 ^ n + j < 3 ^ n) && σ (2 * 3 ^ n + j)) = false := by
          refine' ⟨ _, _, _ ⟩;
          · exact recMaj_eq_of_agree n _ _ fun j hj => if_pos hj;
          · convert recMaj_all_true n using 1;
            convert recMaj_eq_of_agree n _ _ _ using 2 ; simp +arith +decide [ two_mul ];
          · convert recMaj_all_false n using 1;
            grind;
        have h_split_update : recMaj n (Function.update (fun j => if j < 3 ^ n then σ j else decide (j < 2 * 3 ^ n)) i (!if i < 3 ^ n then σ i else decide (i < 2 * 3 ^ n))) = recMaj n (Function.update σ i (!σ i)) ∧ recMaj n (fun j => Function.update (fun j => if j < 3 ^ n then σ j else decide (j < 2 * 3 ^ n)) i (!if i < 3 ^ n then σ i else decide (i < 2 * 3 ^ n)) (3 ^ n + j)) = true ∧ recMaj n (fun j => Function.update (fun j => if j < 3 ^ n then σ j else decide (j < 2 * 3 ^ n)) i (!if i < 3 ^ n then σ i else decide (i < 2 * 3 ^ n)) (2 * 3 ^ n + j)) = false := by
          refine' ⟨ _, _, _ ⟩;
          · refine' recMaj_eq_of_agree n _ _ _;
            intro j hj; by_cases hj' : j = i <;> simp +decide [ *, Function.update_apply ] ;
          · convert h_split.2.1 using 1;
            congr! 1;
            grind +splitImp;
          · convert h_split.2.2 using 1;
            congr! 1;
            grind;
        simp_all +decide [ maj3 ];
      · obtain ⟨ σ, hσ ⟩ := ih ( i - 3^n ) ( by omega );
        refine' ⟨ fun j => if j < 3 ^ n then true else if j < 2 * 3 ^ n then σ ( j - 3 ^ n ) else false, _ ⟩ ; simp_all +decide [ recMaj ];
        convert hσ using 1;
        rw [ show recMaj n ( fun j => decide ( 3 ^ n + j < 2 * 3 ^ n ) && σ j ) = recMaj n σ from ?_, show recMaj n ( fun j => decide ( 2 * 3 ^ n + j < 3 ^ n ) ) = false from ?_ ];
        · rw [ show recMaj n ( fun j => Function.update ( fun j => decide ( j < 3 ^ n ) || decide ( j < 2 * 3 ^ n ) && σ ( j - 3 ^ n ) ) i ( !decide ( i < 3 ^ n ) && !σ ( i - 3 ^ n ) ) ( 3 ^ n + j ) ) = recMaj n ( Function.update σ ( i - 3 ^ n ) !σ ( i - 3 ^ n ) ) from ?_, show recMaj n ( fun j => Function.update ( fun j => decide ( j < 3 ^ n ) || decide ( j < 2 * 3 ^ n ) && σ ( j - 3 ^ n ) ) i ( !decide ( i < 3 ^ n ) && !σ ( i - 3 ^ n ) ) ( 2 * 3 ^ n + j ) ) = false from ?_ ];
          · rw [ show recMaj n ( fun j => decide ( j < 3 ^ n ) || decide ( j < 2 * 3 ^ n ) && σ ( j - 3 ^ n ) ) = true from ?_, show recMaj n ( Function.update ( fun j => decide ( j < 3 ^ n ) || decide ( j < 2 * 3 ^ n ) && σ ( j - 3 ^ n ) ) i ( !decide ( i < 3 ^ n ) && !σ ( i - 3 ^ n ) ) ) = true from ?_ ];
            · cases recMaj n σ <;> cases recMaj n ( Function.update σ ( i - 3 ^ n ) !σ ( i - 3 ^ n ) ) <;> simp +decide [ * ];
            · convert recMaj_all_true n using 1;
              rw [ recMaj_eq_of_agree ];
              grind +splitImp;
            · convert recMaj_all_true n using 1;
              exact recMaj_eq_of_agree n _ _ fun j hj => by aesop;
          · convert recMaj_all_false n using 1;
            grind;
          · convert recMaj_eq_of_agree n _ _ _ using 1;
            grind;
        · convert recMaj_all_false n using 1;
          exact congr_arg _ ( funext fun x => by rw [ decide_eq_false ( by linarith [ pow_pos ( by decide : 0 < 3 ) n ] ) ] );
        · convert recMaj_eq_of_agree n _ _ _ using 1;
          grind;
      · obtain ⟨ σ, hσ ⟩ := ih ( i - 2 * 3 ^ n ) ( by omega );
        refine' ⟨ fun j => if j < 3 ^ n then true else if j < 2 * 3 ^ n then false else σ ( j - 2 * 3 ^ n ), _ ⟩ ; simp_all +decide [ recMaj ];
        simp_all +decide [ Function.update_apply, Nat.not_lt_of_ge h.1, Nat.not_lt_of_ge ( show i ≥ 3 ^ n by linarith [ pow_pos ( show 0 < 3 by decide ) n ] ) ];
        convert hσ using 1;
        rw [ show recMaj n ( fun j => decide ( j < 3 ^ n ) || !decide ( j < 2 * 3 ^ n ) && σ ( j - 2 * 3 ^ n ) ) = true from ?_, show recMaj n ( fun j => !decide ( 3 ^ n + j < 2 * 3 ^ n ) && σ ( 3 ^ n + j - 2 * 3 ^ n ) ) = false from ?_ ];
        · rw [ show recMaj n ( Function.update ( fun j => decide ( j < 3 ^ n ) || !decide ( j < 2 * 3 ^ n ) && σ ( j - 2 * 3 ^ n ) ) i !σ ( i - 2 * 3 ^ n ) ) = true from ?_, show recMaj n ( fun j => if 3 ^ n + j = i then !σ ( i - 2 * 3 ^ n ) else !decide ( 3 ^ n + j < 2 * 3 ^ n ) && σ ( 3 ^ n + j - 2 * 3 ^ n ) ) = false from ?_ ];
          · rw [ show recMaj n ( fun j => decide ( 2 * 3 ^ n + j < 3 ^ n ) || σ j ) = recMaj n σ from ?_, show recMaj n ( fun j => if 2 * 3 ^ n + j = i then !σ ( i - 2 * 3 ^ n ) else decide ( 2 * 3 ^ n + j < 3 ^ n ) || σ j ) = recMaj n ( Function.update σ ( i - 2 * 3 ^ n ) !σ ( i - 2 * 3 ^ n ) ) from ?_ ];
            · cases recMaj n σ <;> cases recMaj n ( Function.update σ ( i - 2 * 3 ^ n ) !σ ( i - 2 * 3 ^ n ) ) <;> simp +decide [ * ];
            · convert recMaj_eq_of_agree n _ _ _ using 2;
              grind;
            · exact recMaj_eq_of_agree n _ _ fun j hj => by simp +decide [ show 2 * 3 ^ n + j ≥ 3 ^ n by linarith ] ;
          · convert recMaj_all_false n using 1;
            convert recMaj_eq_of_agree n _ _ _ using 2;
            grind;
          · convert recMaj_all_true n using 1;
            refine' recMaj_eq_of_agree _ _ _ _;
            grind +revert;
        · convert recMaj_all_false n using 1;
          exact recMaj_eq_of_agree n _ _ fun j hj => by simp +decide [ show 3 ^ n + j < 2 * 3 ^ n by linarith ] ;
        · convert recMaj_all_true n using 1;
          exact recMaj_eq_of_agree n _ _ fun j hj => by aesop;
    · omega

/-
Any formula computing `recMaj n` must mention all variables in `[0, 3^n)`.
-/
theorem formula_for_recMaj_uses_all_vars (n : ℕ) (F : MBoolFormula)
    (hF : ∀ σ, F.eval σ = recMaj n σ)
    (i : ℕ) (hi : i < 3 ^ n) :
    i ∈ F.varSet := by
  by_contra h_not_in;
  -- By recMaj_depends_on_var, there exists some σ such that recMaj n σ ≠ recMaj n (Function.update σ i (!σ i)).
  obtain ⟨σ, hσ⟩ : ∃ σ : ℕ → Bool, recMaj n σ ≠ recMaj n (Function.update σ i (!σ i)) := by
    exact recMaj_depends_on_var n i hi;
  exact hσ ( by rw [ ← hF, ← hF, MBoolFormula.eval_indep_of_not_mem_varSet F i σ ( !σ i ) h_not_in ] )

/-
Key arithmetic: `3^n > 2^n` for `n ≥ 1`.
-/
theorem three_pow_gt_two_pow (n : ℕ) (hn : 1 ≤ n) : 2 ^ n < 3 ^ n := by
  gcongr ; norm_num

/-
**Theorem 3** (Formula Depth Lower Bound): Any monotone formula computing
    `recMaj n` has depth at least `n`.

    Proof architecture: `recMaj n` depends on `3^n` variables, a depth-`d`
    formula has at most `2^d` variables, and `3^n > 2^n` for `n ≥ 1`,
    so `depth ≥ n+1 > n`. For `n = 0`: trivial.
-/
theorem recMaj_formula_depth_lower (n : ℕ) (F : MBoolFormula)
    (hF : ∀ σ, F.eval σ = recMaj n σ) :
    n ≤ F.depth := by
  -- By formula_for_recMaj_uses_all_vars, F.varSet contains all variables in [0, 3^n).
  have h_vars : Finset.range (3 ^ n) ⊆ F.varSet := by
    exact fun x hx => formula_for_recMaj_uses_all_vars n F hF x ( Finset.mem_range.mp hx );
  have := Finset.card_mono h_vars; simp_all +decide [ Finset.card_range ] ;
  exact le_of_not_gt fun h => by linarith [ Nat.pow_le_pow_left ( show 2 ≤ 3 by decide ) n, MBoolFormula.varSet_card_le_two_pow_depth F, pow_lt_pow_right₀ ( show 1 < 2 by decide ) h ] ;

/-! ## Theorem 4: Circuit Depth Lower Bound via Transfer -/

/-
**Theorem 4** (Circuit Lower Bound): Any monotone circuit computing
    `recMaj n` has DAG depth ≥ `n`.

    Uses the transfer theorem: since every formula computing `recMaj n`
    has depth ≥ `n`, the circuit's DAG depth (which equals the unfolded
    formula's depth) is also ≥ `n`.
-/
theorem recMaj_circuit_depth_lower (n : ℕ) (C : MBoolCircuit) (v : Fin C.size)
    (hC : ∀ σ, C.eval σ v = recMaj n σ) :
    n ≤ C.dagDepth v := by
  convert MBoolCircuit.circuit_depth_lb_of_formula_depth_lb C v n _;
  exact fun F hF => recMaj_formula_depth_lower n F fun σ => hF σ ▸ hC σ ▸ rfl

/-! ## Depth Rigidity Summary -/

/-
Upper bound: there exists a formula of depth `3n` computing `recMaj n`.
-/
theorem recMaj_formula_depth_upper (n : ℕ) :
    ∃ F : MBoolFormula, (∀ σ, F.eval σ = recMaj n σ) ∧ F.depth = 3 * n := by
  exact ⟨ recMajFormula n 0, fun σ => recMajFormula_eval_zero n σ, recMajFormula_depth_eq n 0 ⟩

/-
**Depth Rigidity**: The monotone formula/circuit depth of `recMaj n`
    is sandwiched between `n` and `3n`.
-/
theorem recMaj_depth_rigidity (n : ℕ) :
    ∃ F : MBoolFormula,
      (∀ σ, F.eval σ = recMaj n σ) ∧ n ≤ F.depth ∧ F.depth ≤ 3 * n := by
  exact ⟨ recMajFormula n 0, fun σ => by simpa using recMajFormula_eval_zero n σ, by linarith [ recMajFormula_depth_eq n 0, recMaj_formula_depth_lower n ( recMajFormula n 0 ) fun σ => by simpa using recMajFormula_eval_zero n σ ], by linarith [ recMajFormula_depth_eq n 0 ] ⟩

end RecursiveMajority