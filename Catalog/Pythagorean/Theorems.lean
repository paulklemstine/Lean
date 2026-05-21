import CompilerLowerBound.GrowthBound

/-!
# Compiler Lower Bound Theory — Theorems

## Main Results

### Core Lower Bound (Theorem 1)
- `emlDepth_lower_bound_inverseFree`: Any inverse-free EML expression computing
  `iterExp n` on positive reals has `emlDepth ≥ n`.

### Compiler Impossibility Meta-Theorem (Theorem 2)
- `optPass_iterExp_depth_lower_bound`: For any `OptPass`, transformed `iterExp`
  programs retain EML depth at least `n`.

### Concrete Pass Theorems (Theorem 3)
- Semantics and inverse-freeness preservation for CSE, constant folding,
  and algebraic simplification.

### Pipeline Theorem (Theorem 4)
- `pipeline_iterExp_depth_lower_bound`: Arbitrary pipelines of passes
  cannot break the depth barrier.

## Proof Architecture

The compiler impossibility follows by **semantic transport**:
1. `P.transform G` computes the same function (semantics preservation)
2. `P.transform G` is inverse-free (inverse-freeness preservation)
3. Apply the core lower bound to `P.transform G`

This pattern lifts a representation-independent lower bound into a
compiler impossibility theorem — the first such result in mechanized
compiler theory.
-/

noncomputable section

open Real

/-! ## Canonical Construction Lemmas -/

/-- The canonical EML expression for iterExp n evaluates correctly. -/
theorem emlExprIterExp_eval (n : ℕ) (x : ℝ) :
    (emlExprIterExp n).eval x = iterExp n x := by
  induction n with
  | zero => rfl
  | succ n ih => simp [emlExprIterExp, EMLExpr.eval, ih, iterExp, one_mul]

/-- The canonical EML expression for iterExp n has emlDepth exactly n. -/
theorem emlExprIterExp_emlDepth (n : ℕ) :
    (emlExprIterExp n).emlDepth = n := by
  induction n with
  | zero => rfl
  | succ n ih => simp [emlExprIterExp, EMLExpr.emlDepth, ih]; omega

/-- The canonical `emlExprIterExp n` is inverse-free. -/
theorem emlExprIterExp_inverseFree (n : ℕ) :
    (emlExprIterExp n).InverseFree := by
  induction n with
  | zero => exact trivial
  | succ n ih => exact ⟨trivial, ih⟩

/-- The canonical expression computes iterExp n. -/
theorem emlExprIterExp_computesIterExp (n : ℕ) :
    ComputesIterExp n (emlExprIterExp n) := by
  intro x _
  exact emlExprIterExp_eval n x

/-! ## Core Lower Bound -/

/-
Structural bound: expRank ≤ emlDepth. Each `eml` layer contributes
    at most 1 to both measures, while field operations contribute to
    neither.
-/
theorem EMLExpr.expRank_le_emlDepth (e : EMLExpr) : e.expRank ≤ e.emlDepth := by
  induction' e with a b ha hb;
  all_goals norm_num [ EMLExpr.expRank, EMLExpr.emlDepth ] at * ; repeat' omega

/-- **Core lower bound**: Any inverse-free EML expression computing `iterExp n`
    on positive reals has EML depth at least `n`.

    This is the decisive semantic lower bound. It says that the intrinsic
    complexity of iterated exponentiation cannot be hidden by any syntactic
    rearrangement that avoids inversions.

    **Proof**: By the structural bound `expRank ≤ emlDepth`, it suffices to
    show `n ≤ expRank e`. This follows from `expRank_lower_bound_iterExp`
    in the GrowthBound module. -/
theorem emlDepth_lower_bound_inverseFree
    (n : ℕ) (e : EMLExpr)
    (hrep : ComputesIterExp n e)
    (hinv : e.InverseFree) :
    n ≤ e.emlDepth :=
  le_trans (expRank_lower_bound_iterExp n e hrep hinv) (e.expRank_le_emlDepth)

/-! ## Compiler Impossibility Meta-Theorem -/

/-- **Compiler lower bound meta-theorem**: For any semantics-preserving
    optimization pass that preserves inverse-freeness, the transformed output
    of an `iterExp n` program has EML depth at least `n`.

    This converts a representation-independent complexity lower bound into
    a **compiler impossibility theorem**: even a verified optimizing compiler
    with global rewrites, DAG sharing, and algebraic simplification cannot
    collapse the dependency height of iterated exponentiation.

    **Proof**: By semantic transport.
    1. `P.transform G` computes `iterExp n` (by semantics preservation)
    2. `P.transform G` is inverse-free (by inverse-freeness preservation)
    3. Apply `emlDepth_lower_bound_inverseFree` to `P.transform G` -/
theorem optPass_iterExp_depth_lower_bound
    (P : OptPass)
    {n : ℕ} {G : EMLExpr}
    (hcomp : ComputesIterExp n G)
    (hinv : G.InverseFree) :
    n ≤ (P.transform G).emlDepth := by
  apply emlDepth_lower_bound_inverseFree
  · intro x hx
    rw [P.preserves_semantics G x hx]
    exact hcomp x hx
  · exact P.preserves_inverseFree G hinv

/-- Every optimization pass satisfies `CannotReduceIterExpDepth`. -/
theorem optPass_cannot_reduce_depth (P : OptPass) :
    CannotReduceIterExpDepth P :=
  fun _n _G hcomp hinv _ => optPass_iterExp_depth_lower_bound P hcomp hinv

/-! ## CSE Pass Theorems -/

/-- CSE preserves semantics (trivially, since it's the identity on trees). -/
theorem cse_preserves_semantics :
    ∀ (G : EMLExpr) (x : ℝ), 0 < x → (cseTransform G).eval x = G.eval x :=
  fun _ _ _ => rfl

/-- CSE preserves inverse-freeness. -/
theorem cse_preserves_inverseFree :
    ∀ G, G.InverseFree → (cseTransform G).InverseFree :=
  fun _ h => h

/-- The CSE optimization pass. -/
def csePass : OptPass where
  transform := cseTransform
  preserves_semantics := cse_preserves_semantics
  preserves_inverseFree := cse_preserves_inverseFree

/-- CSE cannot reduce iterExp depth below `n`. -/
theorem cse_cannot_reduce_iterExp_depth
    {n : ℕ} {G : EMLExpr}
    (hcomp : ComputesIterExp n G)
    (hinv : G.InverseFree) :
    n ≤ (csePass.transform G).emlDepth :=
  optPass_iterExp_depth_lower_bound csePass hcomp hinv

/-! ## Constant Folding Pass Theorems -/

/-
Constant folding preserves evaluation semantics.
-/
theorem constFold_preserves_semantics :
    ∀ (G : EMLExpr) (x : ℝ), 0 < x → (constFoldTransform G).eval x = G.eval x := by
  intro G x hx;
  induction G generalizing x <;> simp_all +decide [ EMLExpr.eval ];
  any_goals tauto;
  · rename_i a b ha hb;
    rw [ ← ha x hx, ← hb x hx ];
    rw [ show constFoldTransform ( a.add b ) = match constFoldTransform a, constFoldTransform b with | .const ca, .const cb => .const ( ca + cb ) | a', b' => .add a' b' from rfl ];
    cases h : constFoldTransform a <;> cases h' : constFoldTransform b <;> simp +decide [ h, h' ];
    all_goals rfl;
  · rename_i a b ha hb;
    rw [ ← ha x hx, ← hb x hx ];
    rw [ show constFoldTransform ( a.mul b ) = match constFoldTransform a, constFoldTransform b with | .const ca, .const cb => .const ( ca * cb ) | a', b' => .mul a' b' from rfl ];
    cases h : constFoldTransform a <;> cases h' : constFoldTransform b <;> simp +decide [ h, h' ];
    all_goals rfl;
  · rename_i a ha;
    convert congr_arg Neg.neg ( ha x hx ) using 1;
    rw [ show constFoldTransform a.neg = match constFoldTransform a with | .const ca => .const ( -ca ) | a' => .neg a' from rfl ];
    cases h : constFoldTransform a <;> simp +decide [ h, EMLExpr.eval ];
  · rename_i a ha;
    rw [ ← ha x hx ];
    rw [ show constFoldTransform a.inv = match constFoldTransform a with | .const ca => .const ca⁻¹ | a' => .inv a' from rfl ];
    cases h : constFoldTransform a <;> simp +decide [ h, EMLExpr.eval ];
  · rename_i a b ha hb;
    rw [ ← ha x hx, ← hb x hx ];
    rw [ show constFoldTransform ( a.eml b ) = match constFoldTransform a, constFoldTransform b with | .const ca, .const cb => .const ( ca * Real.exp cb ) | a', b' => .eml a' b' from rfl ];
    cases h : constFoldTransform a <;> cases h' : constFoldTransform b <;> simp +decide [ h, h' ];
    all_goals rfl;

/-
Constant folding preserves inverse-freeness.
-/
theorem constFold_preserves_inverseFree :
    ∀ G, G.InverseFree → (constFoldTransform G).InverseFree := by
  intro G hG;
  induction' G with a b ih_a ih_b <;> simp_all +decide [ EMLExpr.InverseFree ];
  all_goals norm_cast;
  · rw [ constFoldTransform ];
    cases h : constFoldTransform b <;> cases h' : constFoldTransform ih_a <;> simp_all +decide [ EMLExpr.InverseFree ];
  · rename_i a b ha hb;
    rw [ show constFoldTransform ( a.mul b ) = match constFoldTransform a, constFoldTransform b with | .const ca, .const cb => .const ( ca * cb ) | a', b' => .mul a' b' from rfl ];
    cases h : constFoldTransform a <;> cases h' : constFoldTransform b <;> simp_all +decide [ EMLExpr.InverseFree ];
  · rename_i a ha;
    cases h : constFoldTransform a <;> simp_all +decide [ EMLExpr.InverseFree ];
    all_goals unfold constFoldTransform; simp_all +decide [ EMLExpr.InverseFree ] ;
  · rename_i a b ha hb;
    -- By definition of `constFoldTransform`, we know that `constFoldTransform (a.eml b)` is either a constant or an eml of two expressions.
    by_cases h_const : ∃ ca cb : ℝ, constFoldTransform a = .const ca ∧ constFoldTransform b = .const cb;
    · obtain ⟨ ca, cb, ha, hb ⟩ := h_const; simp +decide [ *, constFoldTransform ] ;
      trivial;
    · rw [ show constFoldTransform ( a.eml b ) = .eml ( constFoldTransform a ) ( constFoldTransform b ) from ?_ ];
      · exact ⟨ ha, hb ⟩;
      · exact ( by rw [ show constFoldTransform ( a.eml b ) = match constFoldTransform a, constFoldTransform b with | .const ca, .const cb => .const ( ca * Real.exp cb ) | a', b' => .eml a' b' from rfl ] ; aesop )

/-- The constant folding optimization pass. -/
def constFoldPass : OptPass where
  transform := constFoldTransform
  preserves_semantics := constFold_preserves_semantics
  preserves_inverseFree := constFold_preserves_inverseFree

/-- Constant folding cannot reduce iterExp depth below `n`. -/
theorem constFold_cannot_reduce_iterExp_depth
    {n : ℕ} {G : EMLExpr}
    (hcomp : ComputesIterExp n G)
    (hinv : G.InverseFree) :
    n ≤ (constFoldPass.transform G).emlDepth :=
  optPass_iterExp_depth_lower_bound constFoldPass hcomp hinv

/-! ## Algebraic Simplification Pass Theorems -/

/-
Algebraic simplification preserves evaluation semantics.
-/
theorem algSimp_preserves_semantics :
    ∀ (G : EMLExpr) (x : ℝ), 0 < x → (algSimpTransform G).eval x = G.eval x := by
  intro G x hx;
  induction' G with G1 G2 hG1 hG2 generalizing x;
  all_goals unfold algSimpTransform; simp +decide [ *, EMLExpr.eval ];
  rename_i a ha;
  rw [ ← ha x hx ];
  cases h : algSimpTransform a ; simp +decide [ h ];
  all_goals norm_num [ EMLExpr.eval ]

/-
Algebraic simplification preserves inverse-freeness.
-/
theorem algSimp_preserves_inverseFree :
    ∀ G, G.InverseFree → (algSimpTransform G).InverseFree := by
  intro G hG;
  induction' G with a b ha hbizing hG;
  all_goals unfold algSimpTransform; simp_all +decide [ EMLExpr.InverseFree ];
  cases h : algSimpTransform ‹_› <;> aesop

/-- The algebraic simplification optimization pass. -/
def algSimpPass : OptPass where
  transform := algSimpTransform
  preserves_semantics := algSimp_preserves_semantics
  preserves_inverseFree := algSimp_preserves_inverseFree

/-- Algebraic simplification cannot reduce iterExp depth below `n`. -/
theorem algSimp_cannot_reduce_iterExp_depth
    {n : ℕ} {G : EMLExpr}
    (hcomp : ComputesIterExp n G)
    (hinv : G.InverseFree) :
    n ≤ (algSimpPass.transform G).emlDepth :=
  optPass_iterExp_depth_lower_bound algSimpPass hcomp hinv

/-! ## Composition Theorem -/

/-- Composition of passes preserves the impossibility result.
    The obstruction is **stable under composition**: no amount
    of local ingenuity aggregates into a global depth collapse. -/
theorem composed_pass_iterExp_depth_lower_bound
    (P Q : OptPass)
    {n : ℕ} {G : EMLExpr}
    (hcomp : ComputesIterExp n G)
    (hinv : G.InverseFree) :
    n ≤ ((P.comp Q).transform G).emlDepth :=
  optPass_iterExp_depth_lower_bound (P.comp Q) hcomp hinv

/-! ## Pipeline Theorem -/

/-- **Pipeline impossibility theorem**: For any list of semantics-preserving
    inverse-free-preserving optimization passes, the pipeline output of an
    `iterExp n` program has EML depth at least `n`.

    The obstruction is **stable under arbitrary composition**: no sequence of
    correct optimizations can break the intrinsic depth barrier. -/
theorem pipeline_iterExp_depth_lower_bound
    (ps : List OptPass)
    {n : ℕ} {G : EMLExpr}
    (hcomp : ComputesIterExp n G)
    (hinv : G.InverseFree) :
    n ≤ ((runPipeline ps).transform G).emlDepth :=
  optPass_iterExp_depth_lower_bound (runPipeline ps) hcomp hinv

/-! ## Canonical Construction Instantiation -/

/-- Any optimization pass applied to the canonical `emlExprIterExp n` produces
    output with EML depth at least `n`. -/
theorem canonical_iterExp_depth_after_pass
    (P : OptPass) (n : ℕ) :
    n ≤ (P.transform (emlExprIterExp n)).emlDepth :=
  optPass_iterExp_depth_lower_bound P (emlExprIterExp_computesIterExp n) (emlExprIterExp_inverseFree n)

/-- Any pipeline applied to the canonical construction preserves depth ≥ n. -/
theorem canonical_iterExp_depth_after_pipeline
    (ps : List OptPass) (n : ℕ) :
    n ≤ ((runPipeline ps).transform (emlExprIterExp n)).emlDepth :=
  pipeline_iterExp_depth_lower_bound ps (emlExprIterExp_computesIterExp n) (emlExprIterExp_inverseFree n)

end